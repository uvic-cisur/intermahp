library(shiny)
library(shinyjs)
library(shinyWidgets)
library(intermahpr)
library(tidyverse)

source("helper.R") # Have helpers available

ui <- fluidPage(
  title = "InterMAHP",
  
  fluidRow(
    column(6, h1("InterMAHP")),
    column(
      6,
      div(
        radioGroupButtons(
          inputId = "view",
          label = "",
          choices = c("High Level" = "high", "Analyst" = "analyst"),
          selected = "analyst", size = "normal",
          direction = "horizontal"),
        style = "float:right"
      )
    )
  ),

  # Add custom JS and CSS
  shiny::singleton(tags$head(includeCSS(file.path("www", "intermahp.css")))),
  
  # Sidebar with a slider input for number of bins
  fluidRow(
    column(
      3,
      wellPanel(
        fileInput(
          inputId = "uploaded_pc", label = "Prevalence and Consumption Data",
          accept = c("text/csv", "text/comma-separated-values", "text/plain", ".csv"),
          buttonLabel = "Choose File", placeholder = "PrevCons.csv"
        ),
        uiOutput("pc_validation"),
        fileInput(
          inputId = "uploaded_rr", label = "Relative Risk Data",
          accept = c("text/csv", "text/comma-separated-values", "text/plain", ".csv"),
          buttonLabel = "Choose File", placeholder = "RelRisks.csv"
        ),
        uiOutput("rr_validation"),
        fileInput(
          inputId = "uploaded_dh", label = "Morbidity and Mortality Data",
          accept = c("text/csv", "text/comma-separated-values", "text/plain", ".csv"),
          buttonLabel = "Choose File", placeholder = "MorbMort.csv"
        ),
        uiOutput("dh_validation"),
        numericInput(inputId = "bb_f", label = "Female Binge Barrier", value = 50, min = 0, step = 1),
        numericInput(inputId = "bb_m", label = "Male Binge Barrier", value = 65, min = 0, step = 1),
        numericInput(inputId = "ub", label = "Upper Limit of Consumption", value = 250, min = 0, step = 1),
        selectInput(
          inputId = "ext", label = "Dose Response Extrapolation Method",
          c("Linear" = T, "Capped" = F), selected = T),
        actionButton(inputId = "new_model", label = "Generate Estimates")
      )
      ## This is not the functionality you're looking for
      # , wellPanel(
      #     textInput("scenario_name", "Scenario Name"),
      #     numericInput(inputId = "scenario_diff", label = "Percent Change in Consumption", value = 0.00),
      #     actionButton(inputId = "new_scenario", label = "Generate Scenario"
      #     )
      #   )
    ),
    column(
      9,
      conditionalPanel(
        condition = "input.view == 'high'"
        
      ),
      conditionalPanel(
        condition = "input.view == 'analyst'",
        tabsetPanel(uiOutput("analyst_tabs"))
        
        tabsetPanel(
          
          
          tabPanel(
            title = "Scenarios",
            hr(),
            wellPanel(
              uiOutput("scenario_tabs")
            )
          ),
          tabPanel(
            title = "Summaries",
            hr(),
            wellPanel(
              # uiOutput("summary_tabs")
              uiOutput("dl_summary_btn"),
              DT::dataTableOutput("summary")
            )
          )
        )
      )
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  rv <- reactiveValues()
  
  dh_replacement <- tibble(
    im = "(0).(0)", 
    region = "Unspecified", 
    year = 0, 
    gender = "None",
    age_group = "None", 
    outcome = "None", 
    count = 0
  )
  
  rrUpped <- reactive({
    inFile <- input$uploaded_rr
    if(is.null(inFile)) {return(NULL)}
    readr::read_csv(inFile$datapath)
  })
  
  rrPrepped <- reactive({
    intermahpr::prepareRR(rrUpped(), input$ext)
  })
  
  pcUpped <- reactive({
    inFile <- input$uploaded_pc
    if(is.null(inFile)) {return(NULL)}
    readr::read_csv(inFile$datapath)
  })
  
  pcPrepped <- reactive({
    intermahpr::preparePC(
      pcUpped(), 
      bb = list(
        "Female" = input$bb_f,
        "Male" = input$bb_m
      ),
      lb = 0.03,
      ub = input$ub
    )
  })
  
  dhUpped <- reactive({
    if(is.null(input$uploaded_dh)) return(dh_replacement)

    inFile <- input$uploaded_dh
    if(is.null(inFile)) {return(NULL)}
    readr::read_csv(inFile$datapath)
  })
  
  dhPrepped <- reactive({
    intermahpr::prepareDH(dhUpped())
  })
  
  renderStandardDataTable <- function(.data) {
    DT::renderDataTable({
      options <- base_options
      DT::datatable(
        data = .data,
        filter = "top",
        extensions = "Buttons",
        options = options
      )
    })
  }
  
  setTable <- function(name, .data) {
    output[[name]] <- renderStandardDataTable(.data)
    output[[paste0("dl_", name)]] <- downloadHandler(
      filename = function() {
        paste(name, ".csv", sep = "")
      },
      content = function(file) {
        write_csv(x = .data, path = file)
      }
    )
    
  }
  
  observeEvent(input$new_model, {
    if(is.null(input$uploaded_rr) | is.null(input$uploaded_pc)) return(NULL)
    if(is.null(input$uploaded_dh)) showNotification("Morbidity/Mortality counts were not uploaded for the current model. They are required for some InterMAHP features.")

    rv$model <- intermahpr::makeNewModel(rrPrepped(), pcPrepped(), dhPrepped())
    setTable("base", intermahpr::formatForShinyOutput(rv$model$scenarios$base))
  })
  
  observeEvent(input$new_scenario, {
    validate(
      need(!is.null(input$scenario_name), "Please provide a unique name for your new scenario."),
      need(is.null(rv$model$scenarios[[input$scenario_name]]), "There is already a scenario with the given name.")
    )
    
    scale <- 1+(0.01*input$scenario_diff)
    name <- input$scenario_name
    rv$model <- intermahpr::makeScenario(rv$model, scenario_name = name, scale = scale)
    setTable(name, intermahpr::formatForShinyOutput(rv$model$scenarios[[name]]))
    setTable("summary", intermahpr::distillModel(rv$model))
  })

  output$scenario_tabs <- renderUI({
    if(is.null(rv$model)) return(NULL)
    
    tabs <- lapply(
      names(rv$model$scenarios),
      function(name) {
        tabPanel(
          title = name,
          hr(),
          downloadButton(outputId = paste0("dl_", name), "Download"),
          hr(),
          DT::dataTableOutput(name)
        )
      }
    )
    do.call(tabsetPanel, tabs)
  })
  
  output$dl_summary_btn <- renderUI({
    if(is.null(rv$model) | (length(rv$model$scenarios))<2) return(NULL)
    list(
      downloadButton(outputId = "dl_summary", "Download"),
      hr()
    )
  })
  
  output$rr_validation <- renderUI({
    validate(
      need(!(is.null(input$uploaded_rr) & input$new_model), "Relative risk data required to build a model.")
    )
  })
  
  output$pc_validation <- renderUI({
    validate(
      need(!(is.null(input$uploaded_pc) & input$new_model), "Prevalence and Consumption data required to build a model.")
    )
  })
  
  output$show_dl_master <- renderUI({
    if(is.null(rv$model)) return(NULL)
    actionButton(inputId = "dl_master", label = "Download", icon = icon(name = "download"))
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

