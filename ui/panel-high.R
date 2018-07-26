# intermaphr-shiny - Sam Churchill 2018
# --- High Level UI --- #


tagList(
  wellPanel(
    fluidRow(
      h4("Filters"),
      column(
        3,
        uiOutput("high_outcome_filter_render"),
        uiOutput("high_scenario_filter_render"),
        style = "border-right-style: solid; border-right-width: thin;"),
      column(
        9,
        uiOutput("high_simple_filters_render"),
        uiOutput("high_status_filter_render")
      )
    )
  ),
  br()
  # Panel that contains the chart output ----
  # conditionalPanel(
  #   condition = "output.show_hl_chart_panel",
  #   wellPanel(
  #     uiOutput("hl_chart_title"),
  #     showOutput("hl_chart", "nvd3"),
  #     downloadButton(outputId = "hl_download_current_chart", label = "Download")
  #     # ,
  #     # actionButton(inputId = "hl_reserve_current_chart", label = "Reserve", icon = icon("bookmark"))
  #   ),
  #   wellPanel(
  #     uiOutput("hl_popn_summaries")
  #   ),
  #   plotOutput("dummy")
  # )
)