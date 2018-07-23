# intermaphr-shiny - Sam Churchill 2018
# --- Settings UI --- #

tabsetPanel(
  id = "tabset_settings",
  
  tabPanel(
    title = "Global Parameters",
    value = "tabset_settings_global",
    
    br(),
    
    numericInput(inputId = "bb_f", label = "Female Binge Barrier", value = 50, min = 0, step = 1),
    numericInput(inputId = "bb_m", label = "Male Binge Barrier", value = 65, min = 0, step = 1),
    numericInput(inputId = "ub", label = "Upper Limit of Consumption", value = 250, min = 0, step = 1),
    selectInput(
      inputId = "ext", label = "Dose Response Extrapolation Method",
      c("Linear" = T, "Capped" = F), selected = T)
  ),
  
  tabPanel(
    title = "Drinking Groups",
    value = "tabset_settings_groups",
    
    br(),
    
    uiOutput("group_checkboxes"),
    hr(),
    textInput(
      inputId = "new_group_name",
      label = div(
        "Group name",
        popover(content = "Only alphanumeric group names accepted.", pos = "right", icon("question-circle"))
      ),
      placeholder = "Light Drinkers"
    ),
    fluidRow(
      column(
        6,
        numericInput(inputId = "m_lb", label = "Male bounds", value = 15, min = 0,  max = 250, step = 1),
        numericInput(inputId = "m_ub", label = "To", value = 30, min = 0,  max = 250, step = 1)
      ),
      column(
        6,
        numericInput(inputId = "f_lb", label = "Female Bounds", value = 10, min = 0,  max = 250, step = 1),
        numericInput(inputId = "f_ub", label = "To", value = 20, min = 0,  max = 250, step = 1)
      )
    ),
    # fluidRow(
    #   h5("Male bounds"),
    #   column(5, numericInput(inputId = "m_lb", label = "", value = 15, min = 0,  max = 250, step = 1)),
    #   column(2, "to"),
    #   column(5, numericInput(inputId = "m_ub", label = "", value = 30, min = 0,  max = 250, step = 1))),
    # fluidRow(
    #   column(6, numericInput(inputId = "f_lb", label = "Female Lower Bound", value = 10, min = 0,  max = 250, step = 1)),
    #   column(6, numericInput(inputId = "f_ub", label = "Female Upper Bound", value = 20, min = 0,  max = 250, step = 1))
    # ),
    actionButton(inputId = "add_group_btn", label = "Add new group", icon = icon("plus"), class = "btn-danger btn-block")
    
    
  )
  
  
  
)