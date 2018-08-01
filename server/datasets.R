# intermaphr-shiny - Sam Churchill 2018
# --- datasets server --- #

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
    shinyjs::enable("generate_estimates")
  })
})


# Saved data upload button ----
observeEvent(input$datasets_saved_upload_btn, {
  withBusyIndicator("datasets_saved_upload_btn", {
    showNotification("Not Implemented Yet")
  })
})

# Sample data load ----
# * Select sample datasets render ----
output$datasets_sample_years_render <- renderUI({
  pickerInput(
    inputId = "datasets_sample_years",
    label = "Sample years",
    choices = unique(preloaded_dataset_pc$year),
    selected = unique(preloaded_dataset_pc$year)[1],
    multiple = T,
    options = list(
      `actions-box` = TRUE, 
      `selected-text-format` = "count > 2",
      `count-selected-text` = paste("{0}/{1}", "years")
    )
  )  
})


output$datasets_sample_provinces_render <- renderUI({
  pickerInput(
    inputId = "datasets_sample_provinces",
    label = "Sample provinces",
    choices = unique(preloaded_dataset_pc$region),
    selected = unique(preloaded_dataset_pc$region)[1],
    multiple = T,
    options = list(
      `actions-box` = TRUE, 
      `selected-text-format` = "count > 2",
      `count-selected-text` = paste("{0}/{1}", "provinces")
    )
  )
})

observe({
  if(
    (length(input$datasets_sample_provinces) > 0) &&
    (length(input$datasets_sample_years) > 0)
  ) {
    enable(id = "datasets_sample_load_btn")
  } else{
    disable(id = "datasets_sample_load_btn")
  }
})

#* Update samples when not visible
outputOptions(output, "datasets_sample_years_render", suspendWhenHidden = FALSE)
outputOptions(output, "datasets_sample_provinces_render", suspendWhenHidden = FALSE)

# * Button ----
observeEvent(input$datasets_sample_load_btn, {
  withBusyIndicator("datasets_sample_load_btn", {
    if(input$datasets_sample_rr == "Zhao") dataValues$rr_in <- preloaded_dataset_rr_zhao
    if(input$datasets_sample_rr == "Roerecke") dataValues$rr_in <- preloaded_dataset_rr_roerecke
    
    dataValues$pc_in <- dplyr::filter(
      preloaded_dataset_pc,
      year %in% input$datasets_sample_years &
        region %in% input$datasets_sample_provinces
    )
    
    dataValues$mm_in <- dplyr::filter(
      preloaded_dataset_mm, 
      year %in% input$datasets_sample_years &
        region %in% input$datasets_sample_provinces
    )
    
    # Set variables
    dataValues$genders <- c("Male", "Female")
    
    shinyjs::enable("nav_settings")
    shinyjs::enable("nav_generate_estimates")
    shinyjs::enable("generate_estimates")
    
    output$datasetsChosen <- reactive({ TRUE })
  })
})
