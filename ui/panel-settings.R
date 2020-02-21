## intermahp - International Model of Alcohol Harms and Policies
## Copyright (C) 2018 Canadian Institute for Substance Use Research

# --- Settings UI --- #

column(
  12,
  panel(
    # condition = "output.dataConfirmed",
    # conditionalPanel(
    #   condition = "output.estimatesGenerated",
    #   div(
    #     id = "header_settings_changed_alert"
    #   )
    # ),
    
    br(),
    
    
    column(12, tags$b(tags$i("Global settings"))),
    div(
      id = "settings_input",
      column(
        12,
        uiOutput("settings_unit_render")
      ),
      column(
        6,
        uiOutput("settings_global_upper_limit")
      ),
      column(
        6,
        selectInput(
          inputId = "ext",
          label = div(
            "Dose response extrapolation method",
            popover(
              content =
                "Dose response extrapolation method is used to extrapolate the
              dose response of relative risks beyond 150 grams-ethanol per day
              (100 grams-ethanol per day for ischaemic heart disease).
              <br /><br />
              Capped extrapolation caps the relative risk values at the value
              reached at 150 g/day (100 for IHD).
              <br /><br />
              Linear extrapolation uses a line with slope given by the values
              taken by the relative risk function at 100 and 150 (50 and 100 for
              IHD).
              <br /><br />
              <a target='_blank'
              href='https://github.com/uvic-cisur/intermahp#readme'>
              see the README</a> for more details.",
              pos = "right", 
              icon("info-circle")
            )
          ),
          c("Linear" = "linear", "Capped" = "capped"), selected = T)
      ),
      column(12, tags$b(tags$i("Binge definitions"))),
      uiOutput("settings_global_binge_barrier_render"),
      br(),
      column(12, tags$b(tags$i("Squamous cell carcinoma proportions"))),
      column(
        6,
        numericInput(
          inputId = "m scc proportion",
          label = "Men",
          min = 0,
          value = 0.33,
          max = 1,
          step = 0.01
        )
      ),
      column(
        6,
        numericInput(
          inputId = "w scc proportion",
          label = "Women",
          min = 0,
          value = 0.66,
          max = 1,
          step = 0.01
        )
      )
      # uiOutput("settings_global_scc_proportions_render")
    ),
    column(
      12,
      materialSwitch(
        inputId = "settings_confirm_switch",
        label = "Confirm settings", 
        value = FALSE,
        status = "primary"
      ),
      div(
        id = "settings_est_switch_warn"
      )
      
      # withBusyIndicator(
      #   actionButton(
      #     "settings_confirm_btn",
      #     "Confirm settings",
      #     class = "btn-primary"
      #   )
      # )
    )
  ),
  
  
  
  
  
  
  # Next step message ----
  hidden(
    div(
      id = "settings_nextMsg",
      class = "next-msg",
      "Now that you've confirmed settings, proceed to ",
      actionLink("settings_to_generate_estimates", "generate estimates.")
    )
  )
)