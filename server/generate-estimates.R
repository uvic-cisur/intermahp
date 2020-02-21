## intermahp - International Model of Alcohol Harms and Policies
## Copyright (C) 2018 Canadian Institute for Substance Use Research

# --- Generate Estimates Server Logic --- #

# hide model progress initially
shinyjs::hide(id = "model_progress_content")

# Script when a new model is generated ----
observeEvent(
  input$generate_estimates,
  {
    withBusyIndicator(
      "generate_estimates",
      {
        withCallingHandlers(
          {
            # show("model_progress_content")
            # Initialize the fractions
            smahp()$init_fractions()
            
            # Renew long counts if applicable
            if(!is.null(smahp()$mm)) dataValues$long = smahp()$get_long_counts()
          },
          warning = function(w) {
            # browser()
            
            # Adds the received warning to the datasets tab
            html(
              id = "generate_estimates_error_alert",
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
        
        # Adds a warning to the settings tab
        if(!is.null(smahp()$af)) {
          output$estimatesGenerated <- reactive({TRUE})
          enable(selector = '#estimates_dep')
          if('high_level_flag' %in% input$mm_flags) {enable('nav_high')} else {disable('nav_high')}
          show('generate_estimates_nextMsg')
        }
        
        # html(id = "header_settings_changed_alert",
        #      '
        #      <div class="alert alert-warning alert-dismissible">
        #      <a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
        #      <strong>Note:</strong> Estimates must be re-generated for setting changes to take effect.
        #      </div>   
        #      ')
        
        # show("generate_estimates_nextMsg")
      }
    )
  }
)


# OLD Script when a new model is generated ----
# observeEvent(input$generate_estimates, {
#   if(!is.null(dataValues$model)) {
#     shinyalert(
#       title = "Estimates already generated",
#       text = "You've already generated estimates. Clear data and generate new estimates?",
#       type = "warning",
#       closeOnEsc = T,
#       closeOnClickOutside = T,
#       showCancelButton = T,
#       showConfirmButton = T,
#       confirmButtonText = "Yes",
#       cancelButtonText = "No",
#       callbackR = function(continue) {
#         if(continue) {
#           dataValues$model <- NULL
#           dataValues$wide <- NULL
#           dataValues$long <- NULL
#           generateEstimates()
#         } else {
#           return()
#         }
#       }
#     )
#   } else {
#     generateEstimates()
#   }
# })

last_settings <- list()

generateEstimates <- function() {
  withBusyIndicator("generate_estimates", {
    show("model_progress_content")
    html(id = "model_progress", "Generating Estimates:<br />")
    withCallingHandlers(
      {
        last_settings <<- current_settings()
        html(id = "model_progress", "Stage 1/3 (dataset preparation)<br />&emsp;", TRUE)
        pc <- intermahpr::preparePC(
          dataValues$pc_in, 
          bb = current_settings()$bb,
          lb = current_settings()$lb, 
          ub = current_settings()$ub)
        
        setWideTable(
          .data = factorizeVars(intermahpr::renderPCWide(pc)),
          name = "Prevalence and Consumption",
          status = "Ready",
          is.scenario = FALSE)
        
        html(id = "model_progress", "&emsp;", TRUE)
        rr <- intermahpr::prepareRR(
          dataValues$rr_in, 
          ext = if(current_settings()$ext == "TRUE") TRUE else FALSE)
        
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
        
        dataValues$model <- list(
          model = model,
          scenarios = list(),
          rr = rr,
          pc = pc,
          mm = mm,
          settings = current_settings())
        
        message("Stage 3/3 (evaluating base scenario)")
        
        processNewScenario(name = "Base", scale = 1)
        
        output$estimatesGenerated <- reactive({ TRUE })
        
        shinyjs::addClass(id = "header_to_generate_estimates_instruction", class = "closed")
        
        # Adds a warning to the settings tab
        html(id = "header_settings_changed_alert",
             '
            <div class="alert alert-warning alert-dismissible">
              <a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
              <strong>Note:</strong> Estimates must be re-generated for setting changes to take effect.
            </div>   
          ')
        
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

#* next message render ----
output$generate_estimates_nextMsg_render = renderUI({
  div(
    "Finally, add new ",
    actionLink("generate_estimates_to_scenarios", "scenarios"),
    " and ",
    actionLink("generate_estimates_to_drinking_groups", "drinking groups"),
    " or examine the ",
    if('high_level_flag' %in% input$mm_flags) {
      list(actionLink("generate_estimates_to_high", "high level"), " and ")
    },
    actionLink("generate_estimates_to_analyst", "analyst level"),
    " results."
  )
})


# nextMsg links ----
observeEvent(input$generate_estimates_to_scenarios, set_nav("scenarios"))
observeEvent(input$generate_estimates_to_drinking_groups, set_nav("drinking_groups"))
observeEvent(input$generate_estimates_to_high, set_nav("high"))
observeEvent(input$generate_estimates_to_analyst, set_nav("analyst"))
