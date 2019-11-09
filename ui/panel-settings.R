## intermahp - International Model of Alcohol Harms and Policies
## Copyright (C) 2018 Canadian Institute for Substance Use Research

# --- Settings UI --- #

conditionalPanel(
  condition = "output.dataChosen",
  conditionalPanel(
    condition = "output.estimatesGenerated",
    div(
      id = "header_settings_changed_alert"
    )
  ),
  
  br(),
  
  
  column(12, tags$b(tags$i("Global settings"))),
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
      inputId = "ext", label = "Dose response extrapolation method",
      c("Linear" = "linear", "Capped" = "capped"), selected = T)
  ),
  column(12, tags$b(tags$i("Binge definitions"))),
  uiOutput("settings_global_binge_barrier_render"),
  br(),
  column(12, tags$b(tags$i("Squamous cell carcinoma proportions"))),
  uiOutput("settings_global_scc_proportions_render"),
  column(
    12,
    withBusyIndicator(
      actionButton(
        "settings_confirm_btn",
        "Confirm settings",
        class = "btn-primary"
      )
    )
  ),
  
  
  
  
  
  
  # Next step message ----
  column(
    12,
    div(
      id = "settings_nextMsg",
      class = "next-msg",
      "Now that you've confirmed settings, proceed to ",
      actionLink("settings_to_generate_estimates", "generate estimates.")
    )
  )
  
)