library(shiny)
library(shinyjs)
library(shinyWidgets)
library(intermahpr)
library(tidyverse)
library(rCharts)

source(file.path("server", "helpers.R"))


function(input, output, session) {
  rv <- reactiveValues(interactive = list())
  
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
  
  observeEvent(input$uploaded_pc, {
    setTable(
      label = "Prevalence and Consumption",
      .data = intermahpr::displayPC(pcPrepped())
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
        rownames = FALSE,
        data = .data,
        filter = "top",
        extensions = "Buttons",
        options = options
      )
    })
  }
  
  setTable <- function(label, .data) {
    if(is.null(label) | is.null(.data)) return(NULL)
    if(("im" %in% names(.data)) & !("cc" %in% names(.data))) {
      .data <- mutate(.data, cc = substring(im, first = 1, last = 3))
      .data <- right_join(condition_category_ref, .data, by = "cc")
    }
    
    to_factor <- intersect(
      c("region", "year", "gender", "age_group", "condition", "condition_category"),
      names(.data)
    )
    .data[to_factor] <- lapply(.data[to_factor], factor)
    
    
    rv$interactive[[label]]$.data <- .data
    
    output[[paste0("dl_", label)]] <- downloadHandler(
      filename = function() {
        paste(label, ".csv", sep = "")
      },
      content = function(file) {
        write.csv(x = .data, file = file)
      }
    )
    
    output[[label]] <- renderStandardDataTable(.data)
  }
  
  observeEvent(input$test, {
    pc <- preparePC(readr::read_csv("C:/Users/samuelch.UVIC/Documents/shiny-inputs/pc_master.csv"))
    rr <- prepareRR(readr::read_csv("C:/Users/samuelch.UVIC/Documents/shiny-inputs/rr_master.csv"), T)
    dh <- prepareDH(readr::read_csv("C:/Users/samuelch.UVIC/Documents/shiny-inputs/dh_master.csv"))
    
    rv$model <- intermahpr::makeNewModel(rr, pc, dh)
    
    base_table <- left_join(
      intermahpr::formatForShinyOutput(rv$model$scenarios$base), 
      rv$model$dh, 
      by = c("region", "year", "gender", "age_group", "im", "outcome")
    )
    
    base_table$count <- ifelse(is.na(base_table$count) && input$impute_missing_dh, 0, base_table$count)
    
    to_factor <- c("region", "year", "gender", "age_group", "condition")
    base_table[to_factor] <- lapply(base_table[to_factor], factor)
    base_morb <- dplyr::filter(base_table, grepl("Morb", outcome))
    base_mort <- dplyr::filter(base_table, grepl("Mort", outcome))
    setTable(label = "Combined AAFs", .data = base_table)
    setTable(label = "Morbidity AAFs", .data = base_morb)
    setTable(label = "Mortality AAFs", .data = base_mort)
  })
  
  observeEvent(input$new_model, {
    if(is.null(input$uploaded_rr) | is.null(input$uploaded_pc)) return(NULL)
    if(is.null(input$uploaded_dh)) showNotification("Morbidity/Mortality counts were not uploaded for the current model. They are required for some InterMAHP features.")
    
    rv$model <- intermahpr::makeNewModel(rrPrepped(), pcPrepped(), dhPrepped())

    base_table <- left_join(
      intermahpr::formatForShinyOutput(rv$model$scenarios$base), 
      rv$model$dh, 
      by = c("region", "year", "gender", "age_group", "im", "outcome")
    )
    
    to_factor <- c("region", "year", "gender", "age_group", "condition")
    base_table[to_factor] <- lapply(base_table[to_factor], factor)
    
    # base_table <- 
    
    # if(nrow(dhPrepped()) > 1) {

      # %>%
      #   select(
      #     est_fd = count * aaf_fd,
      #     est_cd = count * aaf_cd,
      #     est = count * aaf)
    # }
    
    base_morb <- dplyr::filter(base_table, grepl("Morb", outcome))
    base_mort <- dplyr::filter(base_table, grepl("Mort", outcome))
    setTable(label = "Combined AAFs", .data = base_table)
    setTable(label = "Morbidity AAFs", .data = base_morb)
    setTable(label = "Mortality AAFs", .data = base_mort)
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
  
  output$analyst_dl_zip <- downloadHandler(
    filename = function() {
      paste0(input$save_zip_as, ".zip")
    },
    content = function(fname) {
      owd <- setwd(tempdir())
      on.exit(setwd(owd))
      fs <- NULL;
      to_zip <- input$dl_as_zip
      fs <- paste0(to_zip, ".csv")
      for(i in seq_len(length(fs))) {
        write.csv(rv$interactive[[to_zip[i]]]$.data, file = fs[i])
      }
      zip(zipfile = fname, files = fs)
    },
    contentType = "application/zip"
  )
  
  
  output$analyst_dl_tab <- renderUI({
    if(input$analyst_dl_type == "zip") {
      if(length(rv$interactive) < 1) return(NULL)
      files <- pickerInput(
        inputId = "dl_as_zip",
        label = "Choose Files",
        choices = names(rv$interactive),
        selected = names(rv$interactive),
        multiple = T,
        options = list(
          `actions-box` = TRUE, 
          `selected-text-format` = "count > 2",
          `count-selected-text` = "{0}/{1} Files"
        )
      )
      save_as <- textInput(inputId = "save_zip_as", label = "Save as", value = paste0("InterMAHP-", format(Sys.time(),  "%Y-%m-%d-%H%M")))
      button <- downloadButton(outputId = "analyst_dl_zip")
      return_list <- list(files, hr(), save_as, button)
    } else {
      files <- lapply(
        names(rv$interactive),
        function(.label) {
          list(
            downloadButton(outputId = paste0("dl_", .label), label = .label),
            br(), br()
          )
        }
      )
      return_list <- list(files)
    }
    return_list
  })
  
  highLevelSummary <- reactive({
    if(
      (is.null(rv$interactive[["Combined AAFs"]]) | nrow(dhUpped()) <= 1) &
      input$test < 1
    ) {
      return(NULL) 
    }
    
    .data <- rv$interactive[["Combined AAFs"]]$.data
    
    .data <- dplyr::filter(.data, grepl(input$hl_y1, outcome))
    
    .data$metric = .data$count * .data[[input$hl_y3]]
    
    .data
  })
  
  output$hl_chart <- renderChart({
    .data <- highLevelSummary()
    
    if(is.null(.data)) return(function(...) NULL)
    
    .data_ <- .data %>%
      group_by_(input$hl_x1) %>%
      summarise(metric = sum(metric))
    
    hl <- nPlot(
      x = "metric" ~ input$hl_x1,
      data = .data_,
      type = "multiBarChart",
      dom = "hl_chart"
    )
    
    browser()
    return(hl)
  })
  
  
  output$hl_build_inspector <- renderUI({
    .data <- highLevelSummary()
    label <- "hl_choices"
    
    
    
    
    setTable(.data = .data, label = label)
    tagList(
      DT::dataTableOutput("hl_choices")
    )
  })
  
  x1_x2_choices <- c(
    "Region" = "region",
    "Year" = "year",
    "Gender" = "gender",
    "Age Group" = "age_group",
    "Condition Category" = "condition_category"
  )
  
  observe({
    x1 <- input$hl_x1
    x2 <- input$hl_x2
    
    choice1 <- x1_x2_choices[!(x1_x2_choices %in% x2)]
    choice2 <- c("None" = "none", x1_x2_choices[!(x1_x2_choices %in% x1)])

    updateSelectInput(session, "hl_x1", choices = choice1, selected = x1)
    updateSelectInput(session, "hl_x2", choices = choice2, selected = x2)
  })
  
}