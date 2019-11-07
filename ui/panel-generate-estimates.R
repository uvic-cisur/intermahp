## intermahp - International Model of Alcohol Harms and Policies
## Copyright (C) 2018 Canadian Institute for Substance Use Research

# --- Generate Estimates UI --- #

conditionalPanel(
  condition = "output.dataChosen & output.settingsConfirmed",
  
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
  ),
  # Next step message ----
  div(
    id = "generate_estimates_nextMsg",
    class = "next-msg",
    "Finally, add ",
    actionLink("generate_estimates_to_new_scenarios", "new scenarios"),
    " and ",
    actionLink("generate_estimates_to_drinking_groups", "drinking groups"),
    " or examine the ",
    actionLink("generate_estimates_to_high", "high level"),
    " and ",
    actionLink("generate_estimates_to_analyst", "analyst level"),
    " results."
  )
)