# intermaphr-shiny - Sam Churchill 2018
# --- Generate Estimates UI --- #

wellPanel(
  div(id = "generate_estimates_content",
    p("Generate attributable fraction estimates for each population subgroup and each attributable condition.",
      br(),
      "This may take several minutes depending on the number of population subgroups."),
    
    withBusyIndicator(
      actionButton(
        inputId = "generate_estimates",
        label = "Generate Estimates",
        class = "btn-primary btn-lg"
      )
    )
  ),
  br(),
  div(
    id = "model_progress_content",
    pre(id = "model_progress")
  )
)
