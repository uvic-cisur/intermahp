# intermaphr-shiny - Sam Churchill 2018
# --- Analyst UI --- #

conditionalPanel(
  condition = "output.estimatesGenerated",
  uiOutput("analyst_download_render"),
  br(),
  uiOutput("analyst_view_select_render"),
  DT::dataTableOutput("analyst_view_dt_render")
)

