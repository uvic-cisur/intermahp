## intermahp - International Model of Alcohol Harms and Policies
## Copyright (C) 2018 Canadian Institute for Substance Use Research

# --- Analyst UI --- #

conditionalPanel(
  condition = "output.estimatesGenerated",
  # uiOutput("analyst_download_render"),
  
  # br(),
  selectInput(
    inputId = "analyst_view_select",
    label = "View data",
    choices = c(
      "Computed Population Metrics" = 'pop_metrics',
      "Results" = 'long'
    )
  ),
  # uiOutput("analyst_view_select_render"),
  DT::dataTableOutput("analyst_view_dt_render")
)

