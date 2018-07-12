# intermaphr-shiny - Sam Churchill 2018
# --- Main server file for shiny app --- #

library(shiny)
library(shinyjs)
library(shinyWidgets)
library(intermahpr)
library(tidyverse)
library(rCharts)

source("helpers.R")


function(input, output, session) {
  # server side reactive data store ----
  rv <- reactiveValues(
    ## store for all datasets.
    ## an element is a list whose name is the UI label and whose elements are
    ##    .data (tibble)
    ##    .downloadable (boolean flag)
    ##    .chartable (boolean flag)
    ##    .viewable (boolean flag)
    datasets = list(),
    interactive = list(),
    show_hl_chart_panel = FALSE)

  # Set logo image
  output$logo_img <- renderUI({
    img(src="imahp_logo.png")
  })
  
  # Include logic for each major facet ----
  source(file.path("server", "file-upload.R"), local = TRUE)$value
  source(file.path("server", "data-analysis.R"), local = TRUE)$value
  source(file.path("server", "high-level-btns.R"), local = TRUE)$value
  source(file.path("server", "high-level.R"), local = TRUE)$value
  source(file.path("server", "analyst-btns.R"), local = TRUE)$value
  source(file.path("server", "analyst.R"), local = TRUE)$value
  
  
  # hide the loading message ----
  hide("loading-content", TRUE, "fade") 
}