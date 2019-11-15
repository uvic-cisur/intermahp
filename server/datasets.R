## intermahp - International Model of Alcohol Harms and Policies
## Copyright (C) 2018 Canadian Institute for Substance Use Research

# --- datasets server --- #

# Use uploaded PC dataset if possible, otherwise return imahp3 warnings  ----
observeEvent(
  input$datasets_upload_pc,
  {
    .data <- readr::read_csv(input$datasets_upload_pc$datapath)
    ## If the supplied pc sheet has old gender values ('Male' and 'Female') we'll
    ## switch them to 'm' and 'w'
    ## THIS IS INVISIBLE BACKCOMPATIBILITY
    ## names(.data) is already put to_lower in imahp3 screen_vars method, but
    ## we've gotta check gender values before attempting to add pc
    names(.data) = str_to_lower(names(.data))
    if('gender' %in% names(.data)) {
      if(setequal(unique(.data$gender), c('Male', 'Female'))) {
        .data$gender[.data$gender == 'Male'] <- 'm'
        .data$gender[.data$gender == 'Female'] <- 'w'
        gold_pc <- TRUE
        dataValues$genders <- c('Male', 'Female')
      } 
    }
    
    tryCatch(
      smahp()$add_pc(.data),
      warning = function(w) {
        
        # Adds the received warning to the datasets tab
        html(
          id = "datasets_pc_error_alert",
          paste0(
            '
             <div class="alert alert-warning alert-dismissible">
               <a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
               <strong>Warning:</strong> ',
            htmlmsg(w$message),
            '</div>   
               '
          )
        )
      }
    )
  }
)


# only enable the confirmation buttons when input is acceptable ----
# Adapted from the ddPCR R package written by Dean Attali
observeEvent(
  {
    input$datasets_upload_pc
    input$high_level_flag
    input$calibrate_wac_flag
    input$datasets_upload_mm
  },
  ignoreNULL = FALSE,
  {
    # browser()
    if(
      is.null(smahp()$pc) |
      ((input$high_level_flag | input$calibrate_wac_flag) & is.null(smahp()$mm))
    ) {
      disable("datasets_confirm_switch")
    } else {
      enable("datasets_confirm_switch")
    }
  }
)

# only enable the morb/mort upload when wanted ----
observeEvent(
  {
    input$datasets_use_sample
    input$high_level_flag
    input$calibrate_wac_flag
  },
  ignoreNULL = FALSE,
  {
    if(!input$datasets_use_sample & (input$high_level_flag || input$calibrate_wac_flag)) {
      enable("datasets_upload_mm")
      show("datasets_mm_needed")
    } else {
      disable("datasets_upload_mm")
      hide("datasets_mm_needed")
    }
  }
)

# Use uploaded PC dataset if possible, otherwise return imahp3 warnings  ----
observeEvent(
  input$datasets_upload_mm,
  {
    .data <- readr::read_csv(input$datasets_upload_mm$datapath)
    ## If the supplied mm sheet has old gender values ('Male' and 'Female') we'll
    ## switch them to 'm' and 'w'
    ## THIS IS INVISIBLE BACKCOMPATIBILITY
    ## names(.data) is already put to_lower in imahp3 screen_vars method, but
    ## we've gotta check gender values before attempting to add pc
    names(.data) = str_to_lower(names(.data))
    if('gender' %in% names(.data)) {
      if(setequal(unique(.data$gender), c('Male', 'Female'))) {
        .data$gender[.data$gender == 'Male'] <- 'm'
        .data$gender[.data$gender == 'Female'] <- 'w'
        gold_mm <- TRUE
        dataValues$genders <- c('Male', 'Female')
      } else {
        dataValues$genders <- c('m', 'w')
      }
    }
    
    tryCatch(
      smahp()$add_mm(.data),
      warning = function(w) {
        # browser()
        
        # Adds the received warning to the datasets tab
        html(
          id = "datasets_mm_error_alert",
          paste0(
            '
            <div class="alert alert-warning alert-dismissible">
            <a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
            <strong>Warning:</strong> ',
            htmlmsg(w$message),
            '</div>   
            '
          )
        )
      }
    )
  }
)

# New data confirmation switch behaviour ----
observeEvent(
  input$datasets_confirm_switch,
  {
    if(input$datasets_confirm_switch == TRUE) {
      ## Add last setting to smahp
      smahp()$choose_rr(input$datasets_choose_rr)
      
      ## disable all input elements while datasets are confirmed
      disable(selector = "#datasets_input")
      
      ## Allow navigation to Settings
      shinyjs::enable("nav_settings")
      
      ## Prompt to continue
      show("datasets_nextMsg")
      
      ## Raise data confirmation flag
      output$dataConfirmed <- reactive({ TRUE })
      
      
      
    } else {
      ## Always re-enable the input
      enable(selector = "#datasets_input")
      
      ## If AFs exist warn that changing datasets requires re-generation
      if(!is.null(smahp()$af)) {
        html(
          id = "datasets_est_switch_warn",
          paste0(
            '
            <div class="alert alert-warning alert-dismissible">
            <a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
            <strong>Note:</strong> Estimates must be re-generated for dataset changes to take effect.
            </div>   
            '
          )
        )
      }
    }
  }
)


# New data upload button ----
# observeEvent(input$datasets_new_upload_btn, {
#   withBusyIndicator("datasets_new_upload_btn", {
#     pc <- readr::read_csv(input$datasets_upload_pc$datapath)
#     rr <- readr::read_csv(input$datasets_upload_rr$datapath)
#     mm <- readr::read_csv(input$datasets_upload_mm$datapath)
#     
#     ## Morbidity/Mortality not strictly necessary data.  If there are no observations, make a dummy table.
#     if(nrow(mm) == 0) mm <- tibble::tibble(
#       region = "None", 
#       year = 0,
#       gender = "Male",
#       age_group = "None",
#       im = "(0).(0)",
#       outcome = "None", 
#       count = 0
#     )
#     
#     ## We want descriptive, helpful error messages when the input data is malformed.
#     
#     
#     ## First, check all datasets for missing vars
#     pc_missingvars_flag <- FALSE
#     clean_pc <- tryCatch(
#       {
#         clean(pc, intermahpr::getExpectedVars("pc"))
#       },
#       error = function(e) {
#         pc_missingvars_flag <<- TRUE
#         gsub("A supplied", "Prevalence and consumption", e$message)
#       }
#     )
# 
#     rr_missingvars_flag <- FALSE
#     clean_rr <- tryCatch(
#       {
#         clean(rr, intermahpr::getExpectedVars("rr"))
#       },
#       error = function(e) {
#         rr_missingvars_flag <<- TRUE
#         e$message
#         gsub("A supplied", "Relative risk", e$message)
#       }
#     )
#     
#     mm_missingvars_flag <- FALSE
#     clean_mm <- tryCatch(
#       {
#         clean(mm, intermahpr::getExpectedVars("mm"))
#       },
#       error = function(e) {
#         mm_missingvars_flag <<- TRUE
#         gsub("A supplied", "Morbidity and mortality", e$message)
#       }
#     )
#     
#     ## If any table has missing vars, the associcated error message is stored in
#     ## the variable clean_XX and its corresp flag is set to true.
#     missingvars_flags <- c(pc_missingvars_flag, rr_missingvars_flag, mm_missingvars_flag)
#     
#     if(sum(missingvars_flags)) {
#       stop(
#         c(
#           "\n",
#           if(pc_missingvars_flag) clean_pc else "",
#           if(rr_missingvars_flag) clean_rr else "",
#           if(mm_missingvars_flag) clean_mm else ""
#         )
#       )
#     }
#     
#     ## Otherwise, the clean_XX vars are datatables, and we can continue.
#     prep_rr <- prepareRR(clean_rr, ext = T)
#     
#     # Ensure data cohesion (currently tests: gender levels match)
#     # 
#     stop_message <- ""
#     
#     g_flag <- !(prod(clean_pc$gender %in% prep_rr$gender) && prod(clean_mm$gender %in% prep_rr$gender))
#     
#     if(g_flag) {
#       stop_message <- paste(
#         stop_message,
#         "Gender levels are not consistent between uploaded datasets."
#       )
#     }
#     
#     # If any cohesion flag is raised, send an error
#     flags <- c(g_flag)
#     if(sum(flags)) stop(stop_message)
#     
#     # Set variables
#     dataValues$genders <- unique(as.character(prep_rr$gender))
#     
#     dataValues$pc_raw <- pc
#     dataValues$pc_in <- clean_pc
#     
#     dataValues$rr_raw <- rr
#     dataValues$rr_in <- clean_rr
#     
#     dataValues$mm_raw <- mm
#     dataValues$mm_in <- clean_mm
#     
#     output$dataChosen <- reactive({ TRUE })
#     
#     shinyjs::enable("nav_settings")
#     # shinyjs::enable("nav_generate_estimates")
#     # shinyjs::enable("generate_estimates")
#   })
# })


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
    label = "Prevalence and consumption data",
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

observe({
  if(
    (length(input$datasets_sample_years) > 0)
  ) {
    enable(id = "datasets_sample_load_btn")
  } else{
    disable(id = "datasets_sample_load_btn")
  }
})

#* Update samples when not visible
outputOptions(output, "datasets_sample_years_render", suspendWhenHidden = FALSE)


# Use sample data checkbox ----
observeEvent(
  input$datasets_use_sample,
  {
    if(input$datasets_use_sample == TRUE) {
      hide("datasets_upload_pc_div")
      show("datasets_sample_pc_div")
    } else {
      hide("datasets_sample_pc_div")
      show("datasets_upload_pc_div")
    }
  }
)

# * Button ----
observeEvent(input$datasets_sample_load_btn, {
  withBusyIndicator("datasets_sample_load_btn", {
    
    if(input$datasets_sample_rr == "Zhao") dataValues$rr_in <- preloaded_dataset_rr_zhao
    if(input$datasets_sample_rr == "Roerecke") dataValues$rr_in <- preloaded_dataset_rr_roerecke
    
    dataValues$pc_in <- dplyr::filter(
      preloaded_dataset_pc,
      year %in% input$datasets_sample_years 
    )
    
    dataValues$mm_in <- dplyr::filter(
      preloaded_dataset_mm, 
      year %in% input$datasets_sample_years 
    )
    
    dataValues$rr_raw <- dataValues$rr_in
    dataValues$pc_raw <- dataValues$pc_in
    dataValues$mm_raw <- dataValues$mm_in
    
    # Set variables
    dataValues$genders <- c("Male", "Female")
    
    show("datasets_nextMsg")
    
    output$dataChosen <- reactive({ TRUE })
  })
})

# Metadata for loaded datasets ----
#* 

output$pc_metadata <- renderUI({
  pc <- dataValues$pc_in
  if(is.null(pc)) return("")
  
  obs <- nrow(pc)
  years <- length(unique(pc$year))
  regions <- length(unique(pc$region))
  cohorts <- length(unique(pc$gender)) * length(unique(pc$age_group))
  
  div(
    class = "data-info",
    paste0("Prevalence and consumption:"),
    div(
      class = "padded-data-info",
      paste0(
        obs,
        " observation", if(obs >= 2) "s",
        " over ",
        years,
        " year", if(years >= 2) "s",
        ", ",
        regions,
        " region", if(regions >= 2) "s",
        " and ",
        cohorts,
        " gender-age group", if(cohorts >= 2) "s",
        "."
      )
    )
  )
})

output$rr_metadata <- renderUI({
  rr <- dataValues$rr_in
  if(is.null(rr)) return("")
  
  obs <- nrow(rr)
  conditions <- length(unique(rr$im))
  
  div(
    class = "data-info",
    paste0("Relative risks:"),
    div(
      class = "padded-data-info",
      paste0(
        obs,
        " function specification", if(obs >= 2) "s",
        " across ",
        conditions,
        " condition", if(conditions >= 2) "s",
        "."
      )
    )
  )
})


output$mm_metadata <- renderUI({
  mm <- dataValues$mm_in
  if(is.null(mm)) return("")
  
  years <- length(unique(mm$year))
  regions <- length(unique(mm$region))
  cohorts <- length(unique(mm$gender)) * length(unique(mm$age_group))
  conditions <- length(unique(mm$im))
  morbidities <- nrow(filter(mm, grepl("Morb", outcome)))
  mortalities <- nrow(filter(mm, grepl("Mort", outcome)))
  
  div(
    class = "data-info",
    paste0("Morbidity and mortality:"),
    div(
      class = "padded-data-info",
      paste0(
        morbidities,
        " morbidity and ",
        mortalities,
        " mortality counts over ",
        years,
        " year", if(years >= 2) "s",
        ", ",
        regions,
        " region", if(regions >= 2) "s",
        " and ",
        cohorts,
        " gender-age group", if(cohorts >= 2) "s",
        " across ",
        conditions,
        " condition", if(conditions >= 2) "s",
        "."
      )
    )
  )
})

current_loaded_data <- reactive({
  dataValues[[paste0(input$loaded_raw_data, "_raw")]]
})

datasets_summary_dt <- reactive({
  DT::datatable(
    rownames = FALSE,
    data = current_loaded_data(),
    filter = "top",
    extensions = "Buttons",
    options = base_options
  )
})

output$datasets_summary_dt_render <- DT::renderDataTable(datasets_summary_dt())

# nextMsg links ----
observeEvent(input$datasets_to_settings, set_nav("settings"))
observeEvent(input$datasets_to_generate_estimates, set_nav("generate_estimates"))
