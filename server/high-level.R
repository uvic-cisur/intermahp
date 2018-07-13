# intermahpr-shiny - Sam Churchill 2018
# --- High Level view server --- #

output$hl_download_chart <- renderUI({return(NULL)})

output$hl_data_selector <- renderUI({
  dataset_selector <- selectInput(
    inputId = "hl_current",
    label = "Dataset",
    choices = names(dataValues$long),
    selected = input$hl_current
  )
  
  # outcome_selector <- selectInput(
  #   inputId = "hl_y1",
  #   label = "Outcome",
  #   choices = current_outcomes(),
  #   selected = input$hl_y1
  # )
  
  # metric_selector <- selectInput(
  #   inputId = "hl_y2",
  #   label = "Metric",
  #   choices = c("Count"),
  #   selected = input$hl_y2
  # )
  
  # pop_selector <- selectInput(
  #   inputId = "hl_y3",
  #   label = "Population",
  #   choices = c(
  #     "Entire Population" = "aaf",
  #     "Current drinkers" = "aaf_cd",
  #     "Former drinkers" = "aaf_fd"),
  #   selected = input$hl_y3
  # )
  
  major_selector <- selectInput(
    inputId = "hl_x1",
    label = "Major Grouping",
    choices = x1_choices,
    selected = if(is.null(input$hl_x1)) "Condition Category" else input$hl_x1
  )
  
  minor_selector <- selectInput(
    inputId = "hl_x2",
    label = "Minor Grouping",
    choices = x2_choices,
    selected = if(is.null(input$hl_x2)) "Region" else input$hl_x2
  )
  
  list(
    fluidRow(
      column(4, dataset_selector),
      column(4, major_selector),
      column(4, minor_selector)
      # column(4, outcome_selector),
      # column(4, metric_selector),
      # column(4, pop_selector)
    )
  )
})


current_data <- reactive({
  if(is.null(input$hl_current)) return(NULL)
  dataValues$long[[input$hl_current]]
})

current_var <- function(var) {levels(current_data()[[var]])}

current_regions <- reactive({current_var("region")})
current_years <- reactive({current_var("year")})
current_genders <- reactive({current_var("gender")})
current_age_groups <- reactive({current_var("age_group")})
current_outcomes <- reactive({current_var("outcome")})
current_condition_categories <- reactive({current_var("condition_category")})
current_popuation <- reactive({current_var("population")})

output$hl_filtration_systems <- renderUI({
  pickers <- lapply(
    names(analysis_vars),
    function(.label) {
      .data <- current_data()
      factors <- current_var(analysis_vars[.label])
      list(
        column(
          4,
          pickerInput(
            inputId = paste("hl", analysis_vars[.label], "filter", sep = "_"),
            label = .label,
            choices = current_var(analysis_vars[.label]),
            selected = factors,
            multiple = T,
            options = list(
              `actions-box` = TRUE, 
              `selected-text-format` = "count > 2",
              `count-selected-text` = paste("{0}/{1}", pluralise(.label))
            )
          )
        )
      )
    }
  )
  
  fluidRow(pickers)
})


highLevelSummary <- reactive({
  .data <- current_data()
  
  if(is.null(.data)) return(NULL)
  
  for(var in analysis_vars) {
    id <- paste("hl", var, "filter", sep = "_")
    var_sym <- rlang::sym(var)
    if(!is.null(input[[id]])) {
      .data <- dplyr::filter(.data, !!var_sym %in% input[[id]])
    }
  }
  
  .data$metric = .data$count * .data$aaf
  
  dataValues$current_total <- sum(.data$metric, na.rm = TRUE)
  
  .data
})

output$hl_chart <- renderChart({
  hideElement("hl_chart_div")
  
  .data <- highLevelSummary()
  
  if(is.null(.data)) {
    return(rCharts$new())
  }
  
  x1 <- rlang::sym(input$hl_x1)
  x2 <- if(input$hl_x2 == "none") NULL else rlang::sym(input$hl_x2)
  
  
  .data_ <- if(input$hl_x2 == "none") group_by(.data, !!x1) else group_by(.data, !!x1, !!x2)
  .data_ <- summarise(.data_, metric = sum(metric, na.rm = T))
  .data_$Count <- .data_$metric
  .data_$metric <-  NULL
  
  hl <- nPlot(
    y = "Count",
    x = x1,
    group = x2,
    data = .data_,
    type = "multiBarChart",
    dom = "hl_chart"
  )
  
  rv$show_hl_chart_panel <- TRUE
  
  hl$set(width = 0.95*session$clientData$output_dummy_width)
  
  showElement("hl_chart_div")
  
  return(hl)
})

output$show_hl_chart_panel <- reactive({
  rv$show_hl_chart_panel
})


output$hl_chart_title <- renderUI({
  number <- if(is.null(dataValues$current_total)) 0 else dataValues$current_total
  
  tags$div(
    style = "text-align: center;",
    h3(paste("Total:", round(number)))
  )
})


outputOptions(output, "show_hl_chart_panel", suspendWhenHidden = FALSE)
outputOptions(output, "hl_chart", suspendWhenHidden = FALSE)