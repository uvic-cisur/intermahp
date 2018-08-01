# intermaphr-shiny - Sam Churchill 2018
# --- High Level UI --- #


tagList(
  wellPanel(
    fluidRow(
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
  br(),
  
  wellPanel(
    div(id = "high_chart_div", chartOutput("high_chart", lib = "highcharts")),
    br(),
    fluidRow(
      column(6, uiOutput("high_major_render")),
      column(6, uiOutput("high_minor_render"))
    )
  ),
  wellPanel(
    h3("Charted Data"),
    uiOutput("high_summary_render")
  )
  
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
  
  
  # Dummy plot to track session width of a 3-in-9 column
  , column(3, plotOutput(outputId = "dummy_filtration", height = 0))
  # Dummy plot to track session width of a 9 column
  , plotOutput(outputId = "dummy_chart", height = 0)
)
