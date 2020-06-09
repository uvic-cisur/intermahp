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

      }
    )
  }
)



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
