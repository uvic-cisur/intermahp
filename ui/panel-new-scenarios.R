## intermahp - International Model of Alcohol Harms and Policies
## Copyright (C) 2018 Samuel Churchill

# --- New Scenarios UI --- #

conditionalPanel(
  condition = "output.estimatesGenerated",
  wellPanel(
    div(
      id = "new_scenarios_content",
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
      ),
      checkboxInput(
        inputId = "new_scenarios_compute_summary",
        label = div(
          "Compute summary table",
          popover(
            content =
              "
              Computing a summary table can add several minutes of computation
              and does not need to be computed for every new scenario.  
              <br />
              <br />
              In  the interest of saving your time, it is recommended that you
              compute the summary table when evaluating your final scenario.
            ",
            pos = "right", 
            icon("question-circle"))
        ),
        value = FALSE
      )
    ),
    br(),
    div(
      id = "scenario_progress_content",
      pre(id = "scenario_progress")
    )
  )
)