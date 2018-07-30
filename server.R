# intermaphr-shiny - Sam Churchill 2018
# --- Main server file for shiny app --- #

library(shiny)
library(shinyjs)
library(shinyWidgets)
library(intermahpr)
library(tidyverse)
library(rCharts)

source(file.path("server", "helpers.R"))
source("js-utils.R")

function(input, output, session) {
  # server side reactive data store ----
  dataValues <- reactiveValues(
    wide = list(),
    long = list())
  
  # preloaded data initialization ----
  # RR
  preloaded_dataset_rr_zhao <- read_csv(file.path("data", "zhao.csv"))
  preloaded_dataset_rr_roerecke <- read_csv(file.path("data", "roerecke.csv"))
  # PC & MM
  preloaded_dataset_pc <- read_csv(file.path("data", "all_pc.csv"))
  preloaded_dataset_mm <- read_csv(file.path("data", "all_mm.csv"))
  
  
  # Disable most buttons
  shinyjs::disable(id = "nav_settings")
  
  shinyjs::disable(id = "nav_generate_estimates")
  shinyjs::disable(id = "nav_new_scenarios")
  
  shinyjs::disable(id = "nav_high")
  shinyjs::hide("high_chart_div")
  shinyjs::disable(id = "nav_analyst")
  
  # Set logo image
  output$logo_img <- renderUI({
    img(src="imahp_logo.png")
  })

  
  # Include logic for each major facet ----
  source(file.path("server", "nav-buttons.R"), local = TRUE)$value
  source(file.path("server", "datasets.R"), local = TRUE)$value
  source(file.path("server", "settings.R"), local = TRUE)$value
  source(file.path("server", "generate-estimates.R"), local = TRUE)$value
  source(file.path("server", "new-scenarios.R"), local = TRUE)$value
  source(file.path("server", "set-tables.R"), local = TRUE)$value
  source(file.path("server", "high.R"), local = TRUE)$value
  
  # source(file.path("server", "data-handlers.R"), local = TRUE)$value
  # source(file.path("server", "drinking_groups.R"), local = TRUE)$value
  # source(file.path("server", "data-analysis.R"), local = TRUE)$value
  # source(file.path("server", "high-level-btns.R"), local = TRUE)$value
  # source(file.path("server", "high-level.R"), local = TRUE)$value
  # source(file.path("server", "analyst-btns.R"), local = TRUE)$value
  # source(file.path("server", "analyst.R"), local = TRUE)$value
  
  
  # hide the loading message ----
  hide("loading-content", TRUE, "fade") 
}