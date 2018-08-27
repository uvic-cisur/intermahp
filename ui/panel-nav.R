## intermahp - International Model of Alcohol Harms and Policies
## Copyright (C) 2018 Canadian Institute for Substance Use Research

# --- Navigation UI --- #

wellPanel(
  
  
  # InterMAHP Logo ----
  uiOutput("logo_img"),
  
  hr(),
  
  actionButton(inputId = "nav_datasets", label = "Datasets", icon = icon("upload"), class = "btn-primary btn-block"),
  actionButton(inputId = "nav_settings", label = "Settings", icon = icon("cogs"), class = "btn-primary btn-block"),
  
  hr(),
  
  actionButton(inputId = "nav_generate_estimates", label = "Generate Estimates", icon = icon("calculator"), class = "btn-primary btn-block"),
  actionButton(inputId = "nav_new_scenarios", label = "New Scenarios", icon = icon("plus"), class = "btn-primary btn-block"),
  
  hr(),
  
  actionButton(inputId = "nav_high", label = "High Level Results", icon = icon("bar-chart"), class = "btn-primary btn-block"),
  actionButton(inputId = "nav_analyst", label = "Analyst Level Results", icon = icon("table"), class = "btn-primary btn-block")
)
