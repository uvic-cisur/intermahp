# intermaphr-shiny - Sam Churchill 2018
# --- New Scenarios UI --- #

wellPanel(
  div(id = "new_scenarios_content",
      p("Evaluate estimates under a new consumption scenario.",
        br(),
        "This may take several minutes depending on the number of population subgroups."),
      
      tagList(
        singleton(proxyclickInit()),
        tagAppendAttributes(
          numericInput(
            inputId = "new_scenarios_rescale_percent",
            label = "Percent change in consumption",
            min = -100,
            value = 0,
            max = 100,
            width = "225px"
          ),
          `data-proxy-click` = "new_scenario"
        )
      ),
      
      withBusyIndicator(
        actionButton(
          inputId = "new_scenario",
          label = "New Scenario",
          class = "btn-primary btn-lg"
        )
      )
  ),
  br(),
  div(
    id = "scenario_progress_content",
    pre(id = "scenario_progress")
  )
)
