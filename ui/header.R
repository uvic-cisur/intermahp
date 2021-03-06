## intermahp - International Model of Alcohol Harms and Policies
## Copyright (C) 2018 Canadian Institute for Substance Use Research

div(
  id = "header_data_description",
  conditionalPanel(
    condition = "!output.dataChosen",
    div(
      id = "header_to_select_data_instruction",
      h2(actionLink("header_to_datasets", "Select datasets"), " to begin"),
      br()
    )
  ),
  conditionalPanel(
    condition = "output.dataChosen",
    div(
      id = "header_to_generate_estimates_instruction",
      class = "slidedown",
      h2(actionLink("header_to_generate_estimates", "Generate estimates"), " to proceed"),
      br()
    )
  )
)