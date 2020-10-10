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
      div(
        id = "datasets_input",
        checkboxGroupButtons(
          inputId = "datasets_use_sample",
          label = '',
          choices = c("Use sample data"),
          selected = c()
        ),
        
        
        # checkboxInput(
        #   inputId = "datasets_use_sample",
        #   label = "Use sample data",
        #   value = FALSE
        # ),
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
          label = div(
            "Relative risk source",
            popover(
              content =
                "
              Choices are:<br />
              Relative risks used for the 2016 Global Burden of Disease compiled by the Institute for Health Metrics and Evaluation<br /><br />
              Relative risks used for the 2018 Global Status Report on Alcohol and Health compiled by the World Health Organizaion<br /><br />
              Relative risks used for the 2017 Canadian Substance Use Costs and Harms compiled by the Canadian Centre on Substance Use and Addiction and the Canadian Institute for Substance Use Research
              ",
              pos = "right", 
              icon("info-circle"))
          ),
          choices = c(
            `IHME 2016 GBD` = 'ihme',
            `WHO 2018 GSRAH` = 'who',
            `CCSA/CISUR 2017 CSUCH` = 'cisur')
        ),
        
        div(
          br(),
          div(
            tags$b("Morbidity and mortality options"),
            popover(
              content =
                "
                The following options are only available if morbidity and/or
                mortality data are uploaded. When morbidity/mortality data are
                uploaded InterMAHP will produce attributable fractions and
                counts only for the uploaded conditions counts.
                
                <br /><br />
                
                The high level results panel contains an interactive plot
                builder with a variety of options.
                
                <br /><br />
                
                Calibrating absolute risk curves is an option available for
                conditions wholly-attributable to alcohol, and these curves are
                derived from population statistics and morbidity/mortality
                counts following the methodology described
                <a href='https://journals.sagepub.com/doi/10.1177/0962280220907113'>here</a>.
                These curves are used to estimate attributable morbidity/mortality in
                user-defined drinking groups and scenarios, so this option is
                only necessary when drinking groups or scenarios are being
                constructed.  Otherwise, the attributable fraction is exactly 1.
                ",
              pos = "right", 
              icon("info-circle"))
          ),
          div(
            checkboxGroupButtons(
              inputId = "mm_flags",
              label = '',
              choices = c(
                "Produce high level results" = "high_level_flag",
                "Calibrate absolute risk curves" = "calibrate_wac_flag"),
              selected = c(),
              direction = 'vertical'
            ),
            style = 'text-align:left;'
          )
          # ,
          # 
          # checkboxInput(
          #   inputId = "high_level_flag",
          #   label = "Produce high level results",
          #   value = FALSE
          # ),
          # checkboxInput(
          #   inputId = "calibrate_wac_flag",
          #   label = "Calibrate absolute risk curves for wholly attributable conditions",
          #   value = FALSE
          # )
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
        condition = "output.dataConfirmed",
        div(
          id = "metadata_div",
          div(
            id = "pc_meta_div",
            uiOutput("pc_metadata", inline = TRUE)
          ),
          # div(
          #   id = "rr_meta_div",
          #   uiOutput("rr_metadata", inline = TRUE)
          # ),
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
            "Morbidity and mortality" = "mm"
          )
        ),
        DT::dataTableOutput("datasets_summary_dt_render")
      )
    )
  ),
  # Next step message ----
  hidden(
    div(
      id = "datasets_nextMsg",
      class = "next-msg",
      "Next, ",
      actionLink("datasets_to_settings", "review and confirm settings.")
    )
  )
  
  # div(
  #   id = "datasets_nextMsg", 
  #   class = "next-msg",
  #   "Next, ",
  #   actionLink("datasets_to_settings", "review and confirm settings.")
  # )
)
