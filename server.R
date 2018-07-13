# intermaphr-shiny - Sam Churchill 2018
# --- Main server file for shiny app --- #

library(shiny)
library(shinyjs)
library(shinyWidgets)
library(intermahpr)
library(tidyverse)
library(rCharts)

source(file.path("server", "helpers.R"))
source("popover_fns.R")

function(input, output, session) {
  # server side reactive data store ----
  dataValues <- reactiveValues(
    wide = list(),
    long = list())
  
  rv <- reactiveValues(interactive = list(),
                       show_hl_chart_panel = FALSE)

  # we need to have a quasi-variable flag to indicate whether or not
  # we have a dataset to work with or if we're waiting for dataset to be chosen
  # Adapted from the ddPCR R package written by Dean Attali
  output$datasetsChosen <- reactive({ FALSE })
  outputOptions(output, 'datasetsChosen', suspendWhenHidden = FALSE)
  
  # Set logo image
  output$logo_img <- renderUI({
    img(src="imahp_logo.png")
  })
  

  
  # Include logic for each major facet ----
  source(file.path("server", "file-upload.R"), local = TRUE)$value
  source(file.path("server", "data-handlers.R"), local = TRUE)$value
  source(file.path("server", "drinking_groups.R"), local = TRUE)$value
  source(file.path("server", "data-analysis.R"), local = TRUE)$value
  source(file.path("server", "high-level-btns.R"), local = TRUE)$value
  source(file.path("server", "high-level.R"), local = TRUE)$value
  source(file.path("server", "analyst-btns.R"), local = TRUE)$value
  source(file.path("server", "analyst.R"), local = TRUE)$value
  
  
  # hide the loading message ----
  hide("loading-content", TRUE, "fade") 
}