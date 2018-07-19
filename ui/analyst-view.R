# intermaphr-shiny - Sam Churchill 2018
# --- Analyst UI --- #

conditionalPanel(
  condition = "input.view == 'analyst'",
  
  # display/filter/download buttons ----
  fluidRow(
    column(6, actionButton(inputId = "a_data_selector_btn", label = "Display", icon = icon("gear"), class = "btn-primary btn-block")),
    # column(4, actionButton(inputId = "a_filtration_systems_btn", label = "Filter", icon = icon("filter"), class = "btn-primary btn-block")),
    column(6, actionButton(inputId = "a_download_table_btn", label = "Download", icon = icon("download"), class = "btn-primary btn-block"))
  ),
  
  br(), 
  
  # panels to show when display/filter/download selected ----
  
    tags$div(id = "a_ds_div", wellPanel(uiOutput("a_data_selector"))),
    # tags$div(id = "a_fs_div", uiOutput("a_filtration_systems")),
    tags$div(
      id = "a_dc_div",
      wellPanel(
        radioGroupButtons(
          inputId = "a_dl_type",
          label = "Download Preference",
          choices = c("One .zip file" = "zip", "Individual files" = "ind"),
          selected = "zip",
          direction = "horizontal"),
        hr(),
        uiOutput("a_download_table")
      )
    ),
    
  # Panel that contains the table output ----
  # conditionalPanel(
  #   condition = "output.show_a_table_panel",
    wellPanel(
      uiOutput("a_table")
    )

)