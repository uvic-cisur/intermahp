library(shiny)
library(shinyjs)
library(shinyWidgets)
library(intermahpr)
library(tidyverse)
library(rCharts)

source("helpers.R")


function(input, output, session) {
  shinyjs::disable(id = "new_model")
  
  rv <- reactiveValues(
    interactive = list(),
    show_hl_chart_panel = FALSE)

  dataPrepped <- observe({
    if(!is.null(pcUpped()) && !is.null(rrUpped())) {
      shinyjs::enable("new_model")
    }
  })
  
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
      c(analysis_vars, "condition", "outcome"),
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
  
  observeEvent(input$hl_data_selector_btn, {
    toggleElement("hl_ds_div")
    hideElement("hl_fs_div")
    hideElement("hl_dc_div")
    
    toggleClass(id = "hl_data_selector_btn", class = "active")
    removeClass(id = "hl_filtration_systems_btn", class = "active")
    removeClass(id = "hl_download_chart_btn", class = "active")
  })
  
  observeEvent(input$hl_filtration_systems_btn, {
    hideElement("hl_ds_div")
    toggleElement("hl_fs_div")
    hideElement("hl_dc_div")
    
    removeClass(id = "hl_data_selector_btn", class = "active")
    toggleClass(id = "hl_filtration_systems_btn", class = "active")
    removeClass(id = "hl_download_chart_btn", class = "active")
    
  })
  
  observeEvent(input$hl_download_chart_btn, {
    hideElement("hl_ds_div")
    hideElement("hl_fs_div")
    toggleElement("hl_dc_div")
    
    removeClass(id = "hl_data_selector_btn", class = "active")
    removeClass(id = "hl_filtration_systems_btn", class = "active")
    toggleClass(id = "hl_download_chart_btn", class = "active")
    
  })
  
  showElement("hl_ds_div")
  hideElement("hl_fs_div")
  hideElement("hl_dc_div")
  
  addClass(id = "hl_data_selector_btn", class = "active")
  removeClass(id = "hl_filtration_systems_btn", class = "active")
  removeClass(id = "hl_download_chart_btn", class = "active")
  
  output$hl_download_chart <- renderUI({return(NULL)})
  
  output$hl_data_selector <- renderUI({
    dataset_selector <- selectInput(
      inputId = "hl_current",
      label = "Dataset",
      choices = names(rv$interactive),
      selected = input$hl_current
    )
    
    outcome_selector <- selectInput(
      inputId = "hl_y1",
      label = "Outcome",
      choices = current_outcomes(),
      selected = input$hl_y1
    )
    
    metric_selector <- selectInput(
      inputId = "hl_y2",
      label = "Metric",
      choices = c("Count"),
      selected = input$hl_y2
    )
    
    pop_selector <- selectInput(
      inputId = "hl_y3",
      label = "Population",
      choices = c(
        "Entire Population" = "aaf",
        "Current drinkers" = "aaf_cd",
        "Former drinkers" = "aaf_fd"),
      selected = input$hl_y3
    )
    
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
        column(4, minor_selector),
        column(4, outcome_selector),
        column(4, metric_selector),
        column(4, pop_selector)
      )
    )
  })
  
  
  current_data <- reactive({
    if(is.null(input$hl_current)) return(NULL)
    rv$interactive[[input$hl_current]]$.data
  })
  
  current_var <- function(var) {levels(current_data()[[var]])}
  
  current_regions <- reactive({current_var("region")})
  current_years <- reactive({current_var("year")})
  current_genders <- reactive({current_var("gender")})
  current_age_groups <- reactive({current_var("age_group")})
  current_outcomes <- reactive({current_var("outcome")})
  current_condition_categories <- reactive({current_var("condition_category")})
  
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
    .data <- current_data()
    
    if(is.null(.data)) return(NULL)
    
    .data <- dplyr::filter(.data, grepl(input$hl_y1, outcome))
    
    for(var in analysis_vars) {
      id <- paste("hl", var, "filter", sep = "_")
      var_sym <- rlang::sym(var)
      if(!is.null(input[[id]])) {
        .data <- dplyr::filter(.data, !!var_sym %in% input[[id]])
      }
    }
    
    .data$metric = .data$count * .data[[input$hl_y3]]
    
    rv$current_total <- sum(.data$metric, na.rm = TRUE)
    
    .data
  })
  
  # observe({
  #   if(!is.null(current_data())) showElement("hl_chart_div")
  # })
  # 
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
    .data_[[input$hl_y2]] <- .data_$metric
    .data_$metric <-  NULL

    hl <- nPlot(
      y = input$hl_y2,
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
  
  outputOptions(output, "show_hl_chart_panel", suspendWhenHidden = FALSE)
  outputOptions(output, "hl_chart", suspendWhenHidden = FALSE)
  
  
  output$logo_img <- renderUI({
    img(src="imahp_logo.png")
  })
  
  output$hl_build_inspector <- renderUI({
    .data <- highLevelSummary()
    label <- "hl_choices"
    
    setTable(.data = .data, label = label)
    tagList(
      DT::dataTableOutput("hl_choices")
    )
  })
  
  output$hl_chart_title <- renderUI({
    number <- if(is.null(rv$current_total)) 0 else rv$current_total
    
    tags$div(
      style = "text-align: center;",
      h3(paste("Total:", round(number)))
    )
  })

  
  observe({
    # x1 <- input$hl_x1
    # x2 <- input$hl_x2
    
    # choices1 <- x1_choices[!(x1_choices %in% x2)]
    # choices2 <- x2_choices[!(x2_choices %in% x1)]
    
    # updateSelectInput(session = session, inputId = "hl_x1", choices = choices1, selected = x1)
    # updateSelectInput(session = session, inputId = "hl_x2", choices = choices2, selected = x2)
  })
  
 
}