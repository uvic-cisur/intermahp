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
  
  # tabsetPanel(
  #   id = "tabset_settings",
  #   
  #   tabPanel(
  #     title = "Global parameters",
  #     value = "tabset_settings_global",
      
      br(),
      
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
          c("Linear" = T, "Capped" = F), selected = T)
      ),
      column(12, tags$b(tags$i("Binge definitions"))),
      # br(),br(),
      uiOutput("settings_global_binge_barrier_render"),
      br(),
      column(12, tags$b(tags$i("Squamous cell carcinoma proportions"))),
      # br(),br(),
      uiOutput("settings_global_scc_proportions_render"),

    # ),
    
    # tabPanel(
    #   title = "Drinking groups",
    #   value = "tabset_settings_groups",
      
      # br(),
      # column(
      #   8,
      #   h3("New groups"),
      #   textInput(
      #     inputId = "new_group_name",
      #     label = div(
      #       "Group name",
      #       popover(content = "Only alphanumeric group names accepted.", pos = "right", icon("info-circle"))
      #     ),
      #     placeholder = "Light Drinkers"
      #   ),
      #   hr(),
      #   fluidRow(
      #     column(
      #       6,
      #       actionButton(
      #         inputId = "settings_min_lb",
      #         label = "Use minimum",
      #         icon = icon("angle-double-down"),
      #         class = "btn-block btn-primary"
      #       ),
      #       plotOutput(outputId = "dummy_6in8in9", height = 0)
      #     ),
      #     column(
      #       6,
      #       actionButton(
      #         inputId = "settings_max_ub",
      #         label = "Use maximum",
      #         icon = icon("angle-double-up"),
      #         class = "btn-block btn-primary"
      #       )
      #     )
      #   ),
      #   hr(),
      #   uiOutput("settings_drinking_group_bounds_render"),
      #   hr(),
      #   actionButton(inputId = "add_group_btn", label = "Add new group", icon = icon("plus"), class = "btn-danger btn-block")
      # ),
      # 
      # column(4, h3("Existing groups"), uiOutput("group_checkboxes"))
  #   )
  # ),
  # Next step message ----
  column(
    12,
    div(
      id = "settings_nextMsg",
      class = "next-msg",
      "When you're finished with the settings, proceed to ",
      actionLink("settings_to_generate_estimates", "generate estimates.")
    )
  )
)