# intermahpr-shiny - Sam Churchill 2018
# --- Main UI file for shiny app --- #
# 

library(shiny)
library(shinyjs)
library(shinyWidgets)
library(intermahpr)
library(tidyverse)
library(rCharts)

source(file.path("ui", "helpers.R"))
source("popover_fns.R")

tagList(
  useShinyjs(),
  
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
        source(file.path("ui", "params-panel.R"), local = TRUE)$value
      ),
      column(
        9,
        source(file.path("ui", "high-level-view.R"), local = TRUE)$value,
        source(file.path("ui", "analyst-view.R"), local = TRUE)$value
      )
    ),
    
    # Error messages ----
    fluidRow(column(12, hidden(div(id = "errorDiv", div(icon("exclamation-circle"), tags$b("Error: "), span(id = "errorMsg"))))))
  )
)
