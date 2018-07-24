# intermaphr-shiny - Sam Churchill 2018
# --- File upload server --- #

# only enable the upload buttons when their corresponding input has a file selected ----
# Adapted from the ddPCR R package written by Dean Attali
observeEvent(
  {
    input$upload_rr
    input$upload_pc
    input$upload_dh
  },
  ignoreNULL = FALSE,
  {
    toggleState(
      "upload_files_btn",
      !is.null(input$upload_pc) && !is.null(input$upload_rr) && !is.null(input$upload_dh)
    )
  }
)

# New data upload button ----
observeEvent(input$datasets_new_upload_btn, {
  withBusyIndicator("datasets_new_upload_btn", {
    pc <- readr::read_csv(input$datasets_upload_pc$datapath)
    rr <- readr::read_csv(input$datasets_upload_rr$datapath)
    mm <- readr::read_csv(input$datasets_upload_mm$datapath)
    
    check_pc <- clean(pc, intermahpr::getExpectedVars("pc"))
    check_rr <- prepareRR(rr, T)
    check_mm <- clean(mm, intermahpr::getExpectedVars("mm"))
    
    # Ensure data cohesion (gender levels match, etc)
    # 
    stop_message <- ""
    
    g_flag <- !(setequal(check_pc$gender, check_rr$gender) && setequal(check_rr$gender, check_mm$gender))
    
    if(g_flag) {
      stop_message <- paste(
        stop_message,
        "Gender levels are not consistent between uploaded datasets."
      )
    }
    
    # If any flag is raised, send an error
    flags <- c(g_flag)
    if(sum(flags)) stop(stop_message)
    
    # Set variables
    dataValues$genders <- unique(as.character(check_rr$gender))
    
    dataValues$pc_in <- pc
    dataValues$rr_in <- rr
    dataValues$mm_in <- mm
    
    output$datasetsChosen <- reactive({ TRUE })
    
    shinyjs::enable("nav_settings")
    shinyjs::enable("nav_generate_estimates")
  })
})


# Saved data upload button ----
observeEvent(input$datasets_saved_upload_btn, {
  withBusyIndicator("datasets_saved_upload_btn", {
    showNotification("Not Implemented Yet")
  })
})

# Sample data load ----
# * Select input render ----
output$datasets_sample_years_render <- renderUI({
  selectInput(
    inputId = "datasets_sample_years",
    label = "Sample Years",
    choices = as.factor(preloaded_dataset_pc$year),
    selected = as.factor(preloaded_dataset_pc$year),
    selectize = T,
    multiple = T
  )  
})

output$datasets_sample_provinces_render <- renderUI({
  selectInput(
    inputId = "datasets_sample_provinces",
    label = "Sample Provinces",
    choices = as.factor(preloaded_dataset_pc$region),
    selected = as.factor(preloaded_dataset_pc$region),
    selectize = T,
    multiple = T
  )
})

# * Button ----
observeEvent(input$datasets_sample_load_btn, {
  withBusyIndicator("datasets_sample_load_btn", {
    if(input$datasets_sample_rr == "Zhao") dataValues$pc_in <- preloaded_dataset_rr_zhao
    if(input$datasets_sample_rr == "Roerecke") dataValues$pc_in <- preloaded_dataset_rr_roerecke
    
    dataValues$pc_in <- dplyr::filter(
      preloaded_dataset_pc, 
      year %in% input$dataset_sample_years &&
        region %in% input$dataset_sample_provinces)
    
    dataValues$mm_in <- dplyr::filter(
      preloaded_dataset_mm, 
      year %in% input$dataset_sample_years &&
        region %in% input$dataset_sample_provinces)
    
    # Set variables
    dataValues$genders <- c("Male", "Female")
    
    output$datasetsChosen <- reactive({ TRUE })
    
    shinyjs::enable("nav_settings")
    shinyjs::enable("nav_generate_estimates")
    shinyjs::enable("generate_estimates")
  })
})
