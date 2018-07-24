# intermaphr-shiny - Sam Churchill 2018
# --- Generate Estimates Server Logic --- #


## disable estimation generation button initially
shinyjs::disable(id = "generate_estimates")

# hide model progress initially
shinyjs::hide(id = "model_progress_content")

# Script when a new model is generated ----
observeEvent(input$generate_estimates, {
  withBusyIndicator("generate_estimates", {
    show("model_progress_content")
    html(id = "model_progress", "Generating Estimates")
    withCallingHandlers(
      {
        pc <- intermahpr::preparePC(
          dataValues$pc_in, 
          bb = binge_barriers(),
          lb = 0.03, 
          ub = input$ub)
        
        setWideTable(.data = factorizeVars(intermahpr::renderPCWide(pc)), name = "Prevalence and Consumption", status = "Ready", is.scenario = FALSE)
        
        rr <- intermahpr::prepareRR(dataValues$rr_in, input$ext)
        
        mm <- intermahpr::prepareMM(dataValues$mm_in)
        
        free_rr <- rr %>%
          intermahpr::filterFree() %>%
          intermahpr::makeFreeFactories() %>%
          inner_join(pc, by = c("gender"))
        
        calibrated_rr <- rr %>%
          intermahpr::filterCalibrated() %>%
          intermahpr::makeCalibratedFactories(pc = pc, dh = dh)
        
        model <- bind_rows(free_rr, calibrated_rr) %>%
          select(intermahpr::getExpectedVars("model"))
        
        dataValues$model <- list(model = model, scenarios = list(), rr = rr, pc = pc, dh = dh)
        
        processNewScenario(name = "Base", scale = 1, updateProgress = updateProgress)
        
        shinyjs::enable(id = "add_scenario_btn")
        
      },
      message = function(m) {
        html("model_progress", m$message, TRUE)
      },
      warning = function(m) {
        html("model_progress", paste0(m$message, "\n"), TRUE)
      }
    )
  })
  
  
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
  
  
  updateProgress(0.05, detail = "Preparing relative risk input")
  
  
  updateProgress(0.1, detail = "Preparing morbidity and mortality input")
  
  
  updateProgress(value = 0.15, detail = "Building unconstrained factories")
  
  
  updateProgress(value = 0.30, detail = "Building and calibrating constrained factories")
  
})

include_group <- function(group) {
  input[[paste("Include", group)]]
}