# intermaphr-shiny - Sam Churchill 2018
# --- High Level UI --- #

conditionalPanel(
  condition = "input.view == 'high'",
  
  # display/filter/download buttons ----
  fluidRow(
    column(4, actionButton(inputId = "hl_data_selector_btn", label = "Display", icon = icon("gear"), class = "btn-primary btn-block")),
    column(4, actionButton(inputId = "hl_filtration_systems_btn", label = "Filter", icon = icon("filter"), class = "btn-primary btn-block")),
    column(4, actionButton(inputId = "hl_download_chart_btn", label = "Download", icon = icon("download"), class = "btn-primary btn-block"))
  ),
  
  br(), 
  
  # panels to show when display/filter/download selected ----
  fluidRow(
    tags$div(id = "hl_ds_div", wellPanel(uiOutput("hl_data_selector"))),
    tags$div(id = "hl_fs_div", wellPanel(uiOutput("hl_filtration_systems"))),
    tags$div(id = "hl_dc_div", wellPanel(uiOutput("hl_download_chart")))
  ),
  
  # Panel that contains the chart output ----
  conditionalPanel(
    condition = "output.show_hl_chart_panel",
    wellPanel(
      uiOutput("hl_chart_title"),
      showOutput("hl_chart", "nvd3"),
      plotOutput("dummy")
    )
  )
)