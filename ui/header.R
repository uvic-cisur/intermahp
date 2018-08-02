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
  ),
  conditionalPanel(
    condition = "output.estimatesGenerated",
    div(
      id = "header_settings_changed_alert",
      class = "alert alert-danger",
      strong("Note:"),
      "Some settings have changed. Re-run the analysis for changes to take effect"
    )
  )
)