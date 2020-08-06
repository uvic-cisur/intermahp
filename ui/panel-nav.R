## intermahp - International Model of Alcohol Harms and Policies
## Copyright (C) 2018 Canadian Institute for Substance Use Research

# --- Navigation UI --- #

wellPanel(
  
  
  # InterMAHP Logo ----
  uiOutput("logo_img"),
  
  hr(),
  
  actionButton(inputId = "nav_about", label = div(icon("info-circle"), "About", class = 'truncate'), class = "btn-primary btn-block btn-nav"),
  
  hr(),
  
  actionButton(inputId = "nav_datasets", label = div(icon('upload'), "Datasets", class = 'truncate'), class = "btn-primary btn-block btn-nav"),
  ' ',
  div(
    id = 'datasets_dep',
    style = 'margin-top: 5px;',
    disabled(actionButton(inputId = "nav_settings", label = div(icon('cogs'), "Settings", class = 'truncate'), class = "btn-primary btn-block btn-nav")),
    
    hr(),
    
    div(
      id = 'settings_dep',
      disabled(actionButton(inputId = "nav_generate_estimates", label = div(icon("calculator"), "Generate Estimates", class = 'truncate'), class = "btn-primary btn-block btn-nav")),
      
      div(
        id = 'estimates_dep',
        style = 'margin-top: 5px; margin-bottom: 5px;',
        disabled(actionButton(inputId = "nav_scenarios", label = div(icon('plus'), "Scenarios", class = 'truncate'), class = "btn-primary btn-block btn-nav")),
        disabled(actionButton(inputId = "nav_drinking_groups", label = div(icon('users'), "Drinking Groups", class = 'truncate'), class = "btn-primary btn-block btn-nav")),
        
        hr(),
        disabled(actionButton(inputId = "nav_analyst", label = div(icon('table'), "Analyst Level Results", class = 'truncate'), class = "btn-primary btn-block btn-nav"))
      ), 
      
      disabled(actionButton(inputId = "nav_high", label = div(icon('bar-chart'), "High Level Results", class = 'truncate'), class = "btn-primary btn-block btn-nav")),
      
      hr()
    )
  )
  
  # , actionButton("debug", "Debug", class = "btn-primary btn-block")
)
