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
      inputId = "uploaded_pc", label = "Prevalence and Consumption Data",
      accept = c("text/csv", "text/comma-separated-values", "text/plain", ".csv"),
      buttonLabel = "Choose File", placeholder = "PrevCons.csv"
    ),
    uiOutput("pc_validation"),
    fileInput(
      inputId = "uploaded_rr", label = "Relative Risk Data",
      accept = c("text/csv", "text/comma-separated-values", "text/plain", ".csv"),
      buttonLabel = "Choose File", placeholder = "RelRisks.csv"
    ),
    uiOutput("rr_validation"),
    fileInput(
      inputId = "uploaded_dh", label = "Morbidity and Mortality Data",
      accept = c("text/csv", "text/comma-separated-values", "text/plain", ".csv"),
      buttonLabel = "Choose File", placeholder = "MorbMort.csv"
    ),
    uiOutput("dh_validation")
  ),
  
  br(),
  
  # Additional parameter input dropdown ----
  # TODO: Add country standard dirnk options
  dropdownButton(
    circle = F,
    status = "primary btn-block", 
    label = "Additional Parameters",
    inputId = "params_dropdown_button",
    numericInput(inputId = "bb_f", label = "Female Binge Barrier", value = 50, min = 0, step = 1),
    numericInput(inputId = "bb_m", label = "Male Binge Barrier", value = 65, min = 0, step = 1),
    numericInput(inputId = "ub", label = "Upper Limit of Consumption", value = 250, min = 0, step = 1),
    selectInput(
      inputId = "ext", label = "Dose Response Extrapolation Method",
      c("Linear" = T, "Capped" = F), selected = T)
  ),
  
  hr(),
  
  # Estimate Generation ----
  # TODO: Add working scenario generation
  actionButton(inputId = "new_model", label = "Generate Estimates", class = "btn-block"),
  actionButton(inputId = "test", label = "Test with default parameters", class = "btn-danger btn-block")
)