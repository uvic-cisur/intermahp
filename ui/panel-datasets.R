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
        inputId = "datasets_upload_pc", label = "Prevalence and consumption data",
        accept = c("text/csv", "text/comma-separated-values", "text/plain", ".csv")
      ),
      fileInput(
        inputId = "datasets_upload_rr", label = "Relative risk data",
        accept = c("text/csv", "text/comma-separated-values", "text/plain", ".csv")
      ),
      fileInput(
        inputId = "datasets_upload_mm", label = "Morbidity and mortality data",
        accept = c("text/csv", "text/comma-separated-values", "text/plain", ".csv")
      ),
      withBusyIndicator(
        actionButton(
          "datasets_new_upload_btn",
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
      ),
      withBusyIndicator(
        actionButton(
          "datasets_saved_upload_btn",
          "Upload data",
          class = "btn-primary"
        )
      )
    ),
    
    tabPanel(
      title = "Use Sample Datasets",
      value = "tabsets_datasets_sample",
      br(),
      
      uiOutput("datasets_sample_years_render"),
      uiOutput("datasets_sample_provinces_render"),
      
      
      selectInput(
        inputId = "datasets_sample_rr",
        label = "Sample relative risk data",
        choices = c("Zhao", "Roerecke") 
      ),
      
      withBusyIndicator(
        actionButton(
          "datasets_sample_load_btn",
          "Load data",
          class = "btn-primary"
        )
      )
    )
  )
# )
