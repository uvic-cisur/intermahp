# intermaphr-shiny - Sam Churchill 2018
# --- Settings UI --- #

tabsetPanel(
  id = "tabset_settings",
  
  tabPanel(
    title = "Global Parameters",
    value = "tabset_settings_global",
    
    br(),
    
    column(
      6,
      uiOutput("settings_unit_render"),
      uiOutput("settings_global_upper_limit"),
      selectInput(
        inputId = "ext", label = "Dose response extrapolation method",
        c("Linear" = T, "Capped" = F), selected = T)
    ),
    
    column(
      6,
      uiOutput("settings_global_binge_barrier_render")
    )
  ),
  
  tabPanel(
    title = "Drinking Groups",
    value = "tabset_settings_groups",
    
    br(),
    
    column(6, uiOutput("group_checkboxes")),
    column(
      6,
      textInput(
        inputId = "new_group_name",
        label = div(
          "Group name",
          popover(content = "Only alphanumeric group names accepted.", pos = "right", icon("question-circle"))
        ),
        placeholder = "Light Drinkers"
      ),
      uiOutput("settings_drinking_group_bounds_render"),
      
      actionButton(inputId = "add_group_btn", label = "Add new group", icon = icon("plus"), class = "btn-danger btn-block")
    )
  )
)