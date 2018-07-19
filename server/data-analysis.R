## disable estimation generation button initially
shinyjs::disable(id = "new_model")

## disable estimation generation button initially
shinyjs::disable(id = "add_scenario_btn")

## TODO: Conform to new data standards
observeEvent(input$new_model, {
  style <- "notification"
  # Create a Progress object
  progress <- shiny::Progress$new(style = style)
  progress$set(message = "Generating Estimate Modeler", value = 0)
  # Close the progress when this reactive exits (regardless of why)
  on.exit(progress$close())
  
  # Closure that updates progress.
  # Each time this is called, if 'value' is NULL it will push the progress bar
  # 1/5 of the remaining distance.  Else, it will set the bar to that value.
  # Also accepts optional detail text.
  updateProgress <- function(value = NULL, detail = NULL) {
    if(is.null(value)) {
      value <- progress$getValue()
      value <- value + (progress$getMax() - value) / 5
    }
    progress$set(value = value, detail = detail)
  }
  
  updateProgress(0, detail = "Preparing prevalence and consumption input")
  
  pc <- intermahpr::preparePC(
        dataValues$pc_in, 
        bb = list(
          "Female" = input$bb_f, 
          "Male" = input$bb_m
        ),
        lb = 0.03, 
        ub = input$ub)
  
  setWideTable(.data = factorizeVars(intermahpr::renderPCWide(pc)), name = "Prevalence and Consumption", status = "Ready", is.scenario = FALSE)

  updateProgress(0.05, detail = "Preparing relative risk input")
  
  rr <- intermahpr::prepareRR(dataValues$rr_in, input$ext)
  
  updateProgress(0.1, detail = "Preparing morbidity and mortality input")
  
  dh <- intermahpr::prepareDH(dataValues$dh_in)
  
  updateProgress(value = 0.15, detail = "Building unconstrained factories")
  
  free_rr <- rr %>%
    intermahpr::filterFree() %>%
    intermahpr::makeFreeFactories() %>%
    inner_join(pc, by = c("gender"))
  
  updateProgress(value = 0.30, detail = "Building and calibrating constrained factories")
  
  calibrated_rr <- rr %>%
    intermahpr::filterCalibrated() %>%
    intermahpr::makeCalibratedFactories(pc = pc, dh = dh)
  
  model <- bind_rows(free_rr, calibrated_rr) %>%
      select(intermahpr::getExpectedVars("model"))
      
  dataValues$model <- list(model = model, scenarios = list(), rr = rr, pc = pc, dh = dh)
      
  processNewScenario(name = "Base", scale = 1, updateProgress = updateProgress)
  
  shinyjs::enable(id = "add_scenario_btn")
})

include_group <- function(group) {
  input[[paste("Include", group)]]
}

observeEvent(input$add_scenario_btn, {
  scale <- 1 + (0.01 * input$new_scenario_rescale_percent)
  
  style <- "notification"
  # Create a Progress object
  progress <- shiny::Progress$new(style = style)
  progress$set(message = paste("Adding New Scenario (rescale consumption by ", input$new_scenario_rescale_percent, " percent)"), value = 0)
  # Close the progress when this reactive exits (regardless of why)
  on.exit(progress$close())
  
  # Closure that updates progress.
  # Each time this is called, if 'value' is NULL it will push the progress bar
  # 1/5 of the remaining distance.  Else, it will set the bar to that value.
  # Also accepts optional detail text.
  updateProgress <- function(value = NULL, detail = NULL) {
    if(is.null(value)) {
      value <- progress$getValue()
      value <- value + (progress$getMax() - value) / 5
    }
    progress$set(value = value, detail = detail)
  }
  
  processNewScenario(paste("Scenario - Rescale consumption by ", input$new_scenario_rescale_percent, " percent"), scale = scale, updateProgress = updateProgress)
})

# Create a new scenario
processNewScenario <- function(name, scale, updateProgress = NULL) {
  updateProgress(detail = paste("Generating", name, "scenario"))
  dataValues$model <- intermahpr::makeScenario(dataValues$model, scenario_name = name, scale = scale)
  
  .data <- dataValues$model$scenarios[[name]]
  
  total <- intermahpr::computeTotalFraction(.data)
  total <- ifelse(total == 0, 1, total)
  
  ## Modify by attributability (wholly attributable conditions are the only ones affected)
  attr <- ((.data$attributability == "Wholly") / total) + (.data$attributability == "Partially")
  
  include_groups <- vapply(
    X = names(dataValues$drinking_groups),
    FUN = function(group) {if(include_group(group)) group},
    FUN.VALUE = "0")
  
  for(group in include_groups) {
    updateProgress(detail = paste("Computing alcohol attributable fractions for ", group))
    .data[[paste0("AAF - ", group)]] <- dataValues$drinking_groups[[group]]$.command(.data) * attr
  }
  
  .data[c("current_fraction", "former_fraction")] <- NULL

  .data <- left_join(.data, dataValues$model$dh, by = c("region", "year", "gender", "age_group", "im", "outcome"))
  .data <- mutate(.data, cc = substring(im, first = 2, last = 2))
  .data <- right_join(condition_category_ref, .data, by = "cc")
  .data <- factorizeVars(.data)
  
  updateProgress(detail = "Adding to analyst view")
  setWideTable(.data = .data, name = name, status = "Combined", is.scenario = TRUE)
  
  updateProgress(detail = "Adding to high level view")
  setLongScenarioTable(.data = .data, name = name, status = "Combined", gather_vars = include_groups)
  
  updateProgress(value = 1, detail = "Done")
  Sys.sleep(0.5)
}

# Add long tables to dataValues
setLongScenarioTable <- function(.data, name, status = "Ready", gather_vars) {
  if(is.null(.data) | nrow(.data) == 0) return(NULL)
  if(status == "Combined") {
    setLongScenarioTable(filter(.data, grepl("Morb", outcome)), name = paste(name, "Morbidity"), status = "Ready", gather_vars = gather_vars)
    setLongScenarioTable(filter(.data, grepl("Mort", outcome)), name = paste(name, "Mortality"), status = "Ready", gather_vars = gather_vars)
  } else {

    
    long_data <- gather(.data, key = "population", value = "aaf", paste0("AAF - ", gather_vars))
    long_data$population <- substring(long_data$population, first = 7)
    long_data <- factorizeVars(long_data)
  
    dataValues$long[[name]] <- long_data
  }
}



# Add wide tables to output
setWideTable <- function(.data, name, status = "Ready", is.scenario = F) {
  if(is.null(.data) | nrow(.data) == 0) return(NULL)
  if(status == "Combined") {
    setWideTable(filter(.data, grepl("Morb", outcome)), name = paste(name, "Morbidity"), status = "Ready")
    setWideTable(filter(.data, grepl("Mort", outcome)), name = paste(name, "Mortality"), status = "Ready")
  } else {
    prefix <- if(is.scenario) "InterMAHP Scenario " else "InterMAHP "
    
    dataValues$wide[[name]] <- .data
    output[[paste0("View ", name)]] <- renderStandardDataTable(factorizeVars(.data))
    output[[paste0("Download ", name)]] <- downloadHandler(
      filename = function() {
        paste(prefix, name, ".csv", sep = "")
      },
      content = function(file) {
        write.csv(x = .data, row.names = F, file = file)
      }
    )
  }
}

# Turn the relevent variables into factors for easier filtering
factorizeVars <- function(.data) {
  to_factor <- intersect(c(analysis_vars, "condition", "outcome"), names(.data))
  .data[to_factor] <- lapply(.data[to_factor], factor)
  .data
}

# render a datatable with standard preferences
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

## TODO: Conform to new data standards
# setTable <- function(.label, .data, .downloadable, .chartable, .viewable) {
#   if(is.null(label) | is.null(.data)) return(NULL)
#   if(("im" %in% names(.data)) & !("cc" %in% names(.data))) {
#     .data <- mutate(.data, cc = substring(im, first = 1, last = 3))
#     .data <- right_join(condition_category_ref, .data, by = "cc")
#   }
#   
#   to_factor <- intersect(
#     c(analysis_vars, "condition", "outcome"),
#     names(.data)
#   )
#   .data[to_factor] <- lapply(.data[to_factor], factor)
#   
#   
#   rv$interactive[[label]]$.data <- .data
#   
#   output[[paste0("dl_", label)]] <- downloadHandler(
#     filename = function() {
#       paste(label, ".csv", sep = "")
#     },
#     content = function(file) {
#       write.csv(x = .data, file = file)
#     }
#   )
#   
#   output[[label]] <- renderStandardDataTable(.data)
# }

## TODO: either make this work in general or delete it entirely
# observeEvent(input$test, {
#   pc <- preparePC(readr::read_csv("C:/Users/samuelch.UVIC/Documents/shiny-inputs/pc_master.csv"))
#   rr <- prepareRR(readr::read_csv("C:/Users/samuelch.UVIC/Documents/shiny-inputs/rr_master.csv"), T)
#   dh <- prepareDH(readr::read_csv("C:/Users/samuelch.UVIC/Documents/shiny-inputs/dh_master.csv"))
#   
#   rv$model <- intermahpr::makeNewModel(rr, pc, dh)
#   
#   base_table <- left_join(
#     intermahpr::formatForShinyOutput(rv$model$scenarios$base), 
#     rv$model$dh, 
#     by = c("region", "year", "gender", "age_group", "im", "outcome")
#   )
#   
#   base_morb <- dplyr::filter(base_table, grepl("Morb", outcome))
#   base_mort <- dplyr::filter(base_table, grepl("Mort", outcome))
#   setTable(label = "Combined AAFs", .data = base_table)
#   setTable(label = "Morbidity AAFs", .data = base_morb)
#   setTable(label = "Mortality AAFs", .data = base_mort)
# })



## TODO:
##    Conform to new data standards
##    change scenario name as discussed w/ adam
# observeEvent(input$new_scenario, {
#   validate(
#     need(!is.null(input$scenario_name), "Please provide a unique name for your new scenario."),
#     need(is.null(rv$model$scenarios[[input$scenario_name]]), "There is already a scenario with the given name.")
#   )
#   
#   scale <- 1+(0.01*input$scenario_diff)
#   name <- input$scenario_name
#   rv$model <- intermahpr::makeScenario(rv$model, scenario_name = name, scale = scale)
#   setTable(name, intermahpr::formatForShinyOutput(rv$model$scenarios[[name]]))
#   setTable("summary", intermahpr::distillModel(rv$model))
# })

