## intermahp - International Model of Alcohol Harms and Policies
## Copyright (C) 2018 Canadian Institute for Substance Use Research

# --- New Scenarios UI --- #

conditionalPanel(
  condition = "output.estimatesGenerated",
  column(
    8,
    wellPanel(
      div(
        id = "scenarios_content",
        # p("Evaluate estimates under a new consumption scenario.",
          # br(),
          # "This may take several minutes depending on the number of population subgroups."),
        
        tagList(
          singleton(proxyclickInit()),
          tagAppendAttributes(
            numericInput(
              inputId = "scenarios_rescale_percent",
              label = "Percent change in consumption",
              min = -100,
              value = 0,
              max = 100,
              width = "225px"
            ),
            `data-proxy-click` = "scenario"
          )
        ),
        withBusyIndicator(
          actionButton(
            inputId = "add_scenario",
            label = "Add Scenario",
            class = "btn-primary btn-lg"
          )
        )
        # checkboxInput(
        #   inputId = "scenarios_compute_summary",
        #   label = div(
        #     "Compute summary table",
        #     popover(
        #       content =
        #         "
        #         Computing the summary table can add several minutes of computation
        #         and the summary table need not be computed at every new scenario.  
        #         <br />
        #         <br />
        #         In  the interest of saving your time, it is recommended that you
        #         compute the summary table only when evaluating your final scenario.
        #       ",
        #       pos = "right", 
        #       icon("info-circle"))
        #   ),
        #   value = FALSE
        # )
      ),
      br(),
      div(
        id = "scenario_progress_content"
        # pre(id = "scenario_progress")
      )
    )
  ),
  column(4, h3("Existing scenarios"), uiOutput("scenarios_active")),
  column(
    12,
    div(
      id = "scenarios_error_alert"
    ),
    # Next step message ----
    div(
      id = "scenarios_nextMsg",
      class = "next-msg",
      "Finally, add ",
      actionLink("scenarios_to_drinking_groups", "drinking groups"),
      " or examine the ",
      actionLink("scenarios_to_high", "high level"),
      " and ",
      actionLink("scenarios_to_analyst", "analyst level"),
      " results."
    )
  )
)