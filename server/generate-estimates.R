# intermaphr-shiny - Sam Churchill 2018
# --- Generate Estimates Server Logic --- #


## disable estimation generation button initially
# shinyjs::disable(id = "generate_estimates")

# hide model progress initially
shinyjs::hide(id = "model_progress_content")

# Script when a new model is generated ----
observeEvent(input$generate_estimates, {
  if(!is.null(dataValues$model)) {
    shinyalert(
      title = "Estimates already generated",
      text = "You've already generated estimates. Clear data and generate new estimates?",
      type = "warning",
      closeOnEsc = T,
      closeOnClickOutside = T,
      showCancelButton = T,
      showConfirmButton = T,
      confirmButtonText = "Yes",
      cancelButtonText = "No",
      callbackR = function(continue) {
        if(continue) {
          dataValues$model <- NULL
          dataValues$wide <- NULL
          dataValues$long <- NULL
          generateEstimates()
        } else {
          return()
        }
      }
    )
  } else {
    generateEstimates()
  }
})

  
generateEstimates <- function() {
  withBusyIndicator("generate_estimates", {
    show("model_progress_content")
    html(id = "model_progress", "Generating Estimates:<br />")
    withCallingHandlers(
      {
        html(id = "model_progress", "Stage 1/3 (dataset preparation)<br />&emsp;", TRUE)
          pc <- intermahpr::preparePC(
          dataValues$pc_in, 
          bb = binge_barriers(),
          lb = 0.03, 
          ub = input$settings_ub_in_units * drinking_unit())
        
        setWideTable(
          .data = factorizeVars(intermahpr::renderPCWide(pc)),
          name = "Prevalence and Consumption",
          status = "Ready",
          is.scenario = FALSE)
        
        html(id = "model_progress", "&emsp;", TRUE)
        rr <- intermahpr::prepareRR(dataValues$rr_in, input$ext)
        
        html(id = "model_progress", "&emsp;", TRUE)
        mm <- intermahpr::prepareMM(dataValues$mm_in)
        
        html(id = "model_progress", "Stage 2/3 (building factories)<br />&emsp;", TRUE)
        free_rr <- rr %>%
          intermahpr::filterFree() %>%
          intermahpr::makeFreeFactories() %>%
          inner_join(pc, by = c("gender"))
        
        html(id = "model_progress", "&emsp;", TRUE)
        calibrated_rr <- rr %>%
          intermahpr::filterCalibrated() %>%
          intermahpr::makeCalibratedFactories(pc = pc, mm = mm)
        
        model <- bind_rows(free_rr, calibrated_rr) %>%
          select(intermahpr::getExpectedVars("model"))
        
        dataValues$model <- list(model = model, scenarios = list(), rr = rr, pc = pc, mm = mm)
        
        message("Stage 3/3 (evaluating base scenario)")
        
        processNewScenario(name = "Base", scale = 1)
        
        output$estimatesGenerated <- reactive({ TRUE })
        
        shinyjs::addClass(id = "header_generate_estimates_instruction", class = "closed")
        
        message("Estimates generated.")
        
        show("generate_estimates_nextMsg")
      },
      message = function(m) {
        html("model_progress", m$message, TRUE)
      },
      warning = function(m) {
        html("model_progress", paste0(m$message, "\n"), TRUE)
      }
    )
  })
}

# nextMsg links ----
observeEvent(input$generate_estimates_to_new_scenarios, set_nav("new_scenarios"))
observeEvent(input$generate_estimates_to_high, set_nav("high"))
observeEvent(input$generate_estimates_to_analyst, set_nav("analyst"))
