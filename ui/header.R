div(
  id = "header_data_description",
  conditionalPanel(
    condition = "!output.dataChosen",
    div(
      id = "header_select_data_instruction",
      h2(actionLink("header_to_datasets", "Select datasets"), " to begin"),
      br()
    )
  ),
  conditionalPanel(
    condition = "output.dataChosen",
    div(
      id = "header_to_generate_estimates_instruction",
      class = "slidedown active",
      h2(actionLink("header_to_generate_estimates", "Generate estimates"), " to proceed"),
      br()
    )
  )
)