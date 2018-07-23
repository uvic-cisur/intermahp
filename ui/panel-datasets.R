# intermaphr-shiny - Sam Churchill 2018
# --- Datasets UI --- #

# wellPanel(
  tabsetPanel(
    id = "tabset_datasets",
    tabPanel(
      title = "Upload New Datasets",
      value = "tabset_datasets_new",
      br(),
      fileInput(
        inputId = "datasets_upload_pc", label = "Prevalence and Consumption Data",
        accept = c("text/csv", "text/comma-separated-values", "text/plain", ".csv")
      ),
      fileInput(
        inputId = "datasets_upload_rr", label = "Relative Risk Data",
        accept = c("text/csv", "text/comma-separated-values", "text/plain", ".csv")
      ),
      fileInput(
        inputId = "datasets_upload_mm", label = "Morbidity and Mortality Data",
        accept = c("text/csv", "text/comma-separated-values", "text/plain", ".csv")
      ),
      withBusyIndicator(
        actionButton(
          "upload_files_btn",
          "Upload data",
          class = "btn-primary"
        )
      )
    ),
    
    tabPanel(
      title = "Load Saved Dataset",
      value = "tabset_datasets_saved",
      br(),
      fileInput(
        inputId = "datasets_load_saved", label = "Saved InterMAHP file",
        accept = c(".rda", ".RData")
      )
    ),
    
    tabPanel(
      title = "Use Sample Datasets",
      value = "tabsets_datasets_sample",
      br(),
      selectInput(
        inputId = "datasets_sample_pc",
        label = "Sample Prevalence and Consumption Data",
        choices = c("BC, 2007-2014", "NL", "placeholder") 
      ),
      
      selectInput(
        inputId = "datasets_sample_rr",
        label = "Sample Relative Risk Data",
        choices = c("Zhao", "Roerecke") 
      )
    )
  )
# )
