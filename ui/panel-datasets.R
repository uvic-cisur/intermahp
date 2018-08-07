# intermaphr-shiny - Sam Churchill 2018
# --- Datasets UI --- #

tagList(
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
    # 
    # tabPanel(
    #   title = "Load Saved Dataset",
    #   value = "tabset_datasets_saved",
    #   br(),
    #   fileInput(
    #     inputId = "datasets_load_saved", label = "Saved InterMAHP file",
    #     accept = c(".rda", ".RData")
    #   ),
    #   withBusyIndicator(
    #     actionButton(
    #       "datasets_saved_upload_btn",
    #       "Upload data",
    #       class = "btn-primary"
    #     )
    #   )
    # ),
    # 
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
    ),
    
    tabPanel(
      title = "Review loaded data",
      value = "tabsets_loaded_data",
      br(),
      conditionalPanel(
        condition = "output.dataChosen",
        div(
          id = "metadata_div",
          div(
            id = "pc_meta_div",
            uiOutput("pc_metadata", inline = TRUE)
          ),
          div(
            id = "rr_meta_div",
            uiOutput("rr_metadata", inline = TRUE)
          ),
          div(
            id = "mm_meta_div",
            uiOutput("mm_metadata", inline = TRUE)
          )
        ),
        br(),
        selectInput(
          inputId = "loaded_raw_data",
          label = "View loaded data",
          choices = list(
            "Prevalence and consumption" = "pc",
            "Relative risks" = "rr",
            "Morbidity and mortality" = "mm"
          )
        ),
        DT::dataTableOutput("datasets_summary_dt_render")
      )
    )
  ),
  # Next step message ----
  div(
    id = "datasets_nextMsg", 
    class = "next-msg",
    "Next, ",
    actionLink("datasets_to_settings", "review and tweak settings"),
    " or ",
    actionLink("datasets_to_generate_estimates", "generate estimates.")
  )
)
