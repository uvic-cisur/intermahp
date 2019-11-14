## intermahp - International Model of Alcohol Harms and Policies
## Copyright (C) 2018 Canadian Institute for Substance Use Research

# --- Datasets UI --- #

tagList(
  tabsetPanel(
    id = "tabset_datasets",
    tabPanel(
      title = "Choose datasets",
      value = "tabset_datasets_new",
      br(),
      p("Upload datasets that satisfy the specifications outlined in the InterMAHP user guide."),
      p("The sample datasets provided satisfy these specfications (see guide for more details)."),
      # br(),
      checkboxInput(
        inputId = "datasets_use_sample",
        label = "Use sample data",
        value = FALSE
      ),
      div(
        id = "datasets_sample_pc_div",
        uiOutput("datasets_sample_years_render")
      ),
      div(
        id = "datasets_upload_pc_div",
        fileInput(
          inputId = "datasets_upload_pc",
          label = div(
            "Prevalence and consumption data",
            br(),
            downloadLink(
              "samplePC",
              div(
                "Sample prevalence and consumption data sheet"
              )
            )
          ),
          accept = c("text/csv", "text/comma-separated-values", "text/plain", ".csv")
        )
      ),
      div(
        id = "datasets_pc_error_alert"
      ),
      selectInput(
        inputId = "datasets_choose_rr",
        label = "Relative risk source",
        choices = c(GBD = 'ihme', CSUCH = 'csuch')
      ),

      div(
        br(),
        tags$b("Morbidity and mortality options"),
        checkboxInput(
          inputId = "high_level_flag",
          label = "Produce high level results",
          value = FALSE
        ),
        checkboxInput(
          inputId = "calibrate_wac_flag",
          label = "Calibrate absolute risk curves for wholly attributable conditions",
          value = FALSE
        )
      ),
      
      hidden(
        div(
          id = "datasets_mm_needed",
          fileInput(
            inputId = "datasets_upload_mm",
            label = div(
              br(),
              "Morbidity and mortality data",
              downloadLink(
                "sampleMM",
                div(
                  "Sample morbidity and mortality data sheet"
                )
              )
            ),
            accept = c("text/csv", "text/comma-separated-values", "text/plain", ".csv")
          ),
          div(
            id = "datasets_mm_error_alert"
          )
        )
      ),
      
      
      # fileInput(
      #   inputId = "datasets_upload_rr",
      #   label = div(
      #     "Relative risk data",
      #     br(),
      #     downloadLink(
      #       outputId = "sampleRR",
      #       label = "Sample relative risk data sheet"
      #     )
      #   ),
      #   accept = c("text/csv", "text/comma-separated-values", "text/plain", ".csv")
      # ),
      # fileInput(
      #   inputId = "datasets_upload_mm",
      #   label = div(
      #     "Morbidity and mortality data",
      #     downloadLink(
      #       "sampleMM",
      #       div(
      #         "Sample morbidity and mortality data sheet"
      #       )
      #     )
      #   ),
      #   accept = c("text/csv", "text/comma-separated-values", "text/plain", ".csv")
      # ),
      disabled(
        materialSwitch(
          inputId = "datasets_confirm_switch",
          label = "Confirm data", 
          value = FALSE,
          status = "primary"
        ),
        div(
          id = "datasets_est_switch_warn"
        )
        
        
        
        # withBusyIndicator(
        #   actionButton(
        #     "datasets_confirm_data_btn",
        #     "Confirm data",
        #     class = "btn-primary"
        #   )
        # )
      )
    ),

    # tabPanel(
    #   title = "Use sample datasets",
    #   value = "tabsets_datasets_sample",
    #   br(),
    #   
    #   p("Use sample data to explore Canadian mortality between 2007 and 2016."),
    #   
    #   p("To begin, select years of study and ischaemic heart disease treatment."),
    #   
    #   br(),
    #   
    #   # uiOutput("datasets_sample_years_render"),
    #   
    #   
    #   selectInput(
    #     inputId = "datasets_sample_rr",
    #     label = div(
    #       "Ischaemic heart disease treatment",
    #       popover(
    #         content = "Ischaemic heart disease relative risk is stratified at the meta-analysis level by treatment of abstainer bias.
    #         <br /><br />
    #         Zhao explicitly controls for abstainer bias by selecting studies with no bias and other methods.
    #         <br /><br />
    #         Roerecke reweights relative risk results from studies which pooled former and never drinkers as abstainers using a standard methodology.
    #         <br /><br />
    #         For more information, refer to the articles themselves:<br />
    #         <a href=https://www.jsad.com/doi/abs/10.15288/jsad.2017.78.375>Zhao</a>
    #         <br />
    #         <a href=https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1360-0443.2012.03780.x>Roerecke</a>
    #         ",
    #         pos = "right",
    #         icon("info-circle")
    #         
    #       )
    #     ),
    #     choices = c("Zhao", "Roerecke") 
    #   ),
    #   
    #   withBusyIndicator(
    #     actionButton(
    #       "datasets_sample_load_btn",
    #       "Load data",
    #       class = "btn-primary"
    #     )
    #   )
    # ),
    
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
    actionLink("datasets_to_settings", "review and confirm settings.")
  )
)
