## intermahp - International Model of Alcohol Harms and Policies
## Copyright (C) 2018 Canadian Institute for Substance Use Research

# --- Main UI file for shiny app --- #
# 

library(shiny)
library(shinyjs)
library(shinyWidgets)
library(shinyalert)
library(intermahpr)
library(intermahp3)
library(dplyr)
library(purrr)
library(readr)
library(tidyr)
library(magrittr)
library(rCharts)
library(gtools)
library(rmarkdown)

source(file.path("ui", "helpers.R"))
source("js-utils.R")

tagList(
  useShinyjs(),
  useShinyalert(),
  
  # Add custom JS and CSS ----
  tags$head(
    tags$link(href = "style.css", rel = "stylesheet")
  ),
  
  # Loading screen ----
  div(id = "loading-content", "Loading...",
      img(src = "ajax-loader-bar.gif")),
  
  fluidPage(
    title = "InterMAHP",
    
    br(),
    fluidRow(
      column(
        3,
        source(file.path("ui", "panel-nav.R"), local = TRUE)$value
      ),
      column(
        9,
        
        div(id = "header", source(file.path("ui", "header.R"), local = TRUE)$value),
        
        div(id = "panel_datasets", source(file.path("ui", "panel-datasets.R"), local = TRUE)$value),
        div(id = "panel_settings", source(file.path("ui", "panel-settings.R"), local = TRUE)$value),

        div(id = "panel_generate_estimates", source(file.path("ui", "panel-generate-estimates.R"), local = TRUE)$value),
        div(id = "panel_new_scenarios", source(file.path("ui", "panel-new-scenarios.R"), local = TRUE)$value),

        div(id = "panel_high", source(file.path("ui", "panel-high.R"), local = TRUE)$value),
        div(id = "panel_analyst", source(file.path("ui", "panel-analyst.R"), local = TRUE)$value),
        
        div(id = "panel_about", source(file.path("ui", "panel-about.R"), local = TRUE)$value),
        
        # Error messages ----
        fluidRow(column(12, hidden(div(id = "errorDiv", div(icon("exclamation-circle"), tags$b("Error: "), span(id = "errorMsg"))))))
      )
    )
    
  )
)
