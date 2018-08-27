## intermahp - International Model of Alcohol Harms and Policies
## Copyright (C) 2018 Canadian Institute for Substance Use Research

# --- Analyst UI --- #

conditionalPanel(
  condition = "output.estimatesGenerated",
  uiOutput("analyst_download_render"),
  br(),
  uiOutput("analyst_view_select_render"),
  DT::dataTableOutput("analyst_view_dt_render")
)

