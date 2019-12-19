## intermahp - International Model of Alcohol Harms and Policies
## Copyright (C) 2018 Canadian Institute for Substance Use Research

# --- Generate Estimates UI --- #

conditionalPanel(
  condition = "output.dataConfirmed & output.settingsConfirmed",
  
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
      id = "generate_estimates_error_alert"
    ),
    div(
      id = "model_progress_content",
      pre(id = "model_progress")
    )
  ),
  # Next step message ----
  # conditionalPanel(
  #   "output.estimatesGenerated", 
  hidden(
    div(
      id = "generate_estimates_nextMsg",
      class = "next-msg",
      uiOutput("generate_estimates_nextMsg_render", inline = TRUE)
    )
  )
  # )
  
# 
# 
#   div(
#     id = "generate_estimates_nextMsg",
#     class = "next-msg",
#     "Finally, add new ",
#     actionLink("generate_estimates_to_scenarios", "scenarios"),
#     " and ",
#     actionLink("generate_estimates_to_drinking_groups", "drinking groups"),
#     " or examine the ",
#     actionLink("generate_estimates_to_high", "high level"),
#     " and ",
#     actionLink("generate_estimates_to_analyst", "analyst level"),
#     " results."
#   )
)