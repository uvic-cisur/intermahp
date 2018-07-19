# intermaphr-shiny - Sam Churchill 2018
# --- Parameter UI --- #

wellPanel(
  
  # Button group to choose view ----
  radioGroupButtons(
    inputId = "view",
    choices = c("High Level View" = "high", "Analyst View" = "analyst"),
    selected = "high",
    direction = "horizontal",
    justified = T
  ),
  
  hr(),
  
  # InterMAHP Logo ----
  uiOutput("logo_img"),
  
  hr(),
  
  # File upload dropdown ----
  dropdownButton(
    circle = F,
    status = "primary btn-block",
    label = "File Upload",
    inputId = "upload_dropdown_button",
    fileInput(
      inputId = "upload_pc", label = "Prevalence and Consumption Data",
      accept = c("text/csv", "text/comma-separated-values", "text/plain", ".csv")
    ),
    fileInput(
      inputId = "upload_rr", label = "Relative Risk Data",
      accept = c("text/csv", "text/comma-separated-values", "text/plain", ".csv")
    ),
    fileInput(
      inputId = "upload_dh", label = "Morbidity and Mortality Data",
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
  
  br(),
  
  # Additional parameter input dropdown ----
  # TODO: Add country standard drink options
  dropdownButton(
    circle = F,
    status = "primary btn-block", 
    label = "Global Parameters",
    inputId = "params_dropdown_button",
    numericInput(inputId = "bb_f", label = "Female Binge Barrier", value = 50, min = 0, step = 1),
    numericInput(inputId = "bb_m", label = "Male Binge Barrier", value = 65, min = 0, step = 1),
    numericInput(inputId = "ub", label = "Upper Limit of Consumption", value = 250, min = 0, step = 1),
    selectInput(
      inputId = "ext", label = "Dose Response Extrapolation Method",
      c("Linear" = T, "Capped" = F), selected = T)
  ),
  
  br(),
  
  # drinking group input dropdown ----
  dropdownButton(
    circle = F,
    status = "primary btn-block", 
    label = "Drinking Groups",
    inputId = "groups_dropdown_button",
    right = TRUE,
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
  ),
  
  hr(),
  
  # Estimate Generation ----
  # TODO: Add working scenario generation
  actionButton(inputId = "new_model", label = "Generate Estimates", class = "btn-block")
  # actionButton(inputId = "test", label = "Test with default parameters", class = "btn-danger btn-block")
)