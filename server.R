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
    ## store for all datasets.
    ## an element is a list whose name is the UI label and whose elements are
    ##    .data (tibble)
    ##    .download (download handler or NULL)
    ##    .chart (long, chartable form of data or NULL)
    ##    .view (wide, viewable form of data or NULL)
    datasets = list(),
    show_hl_chart_panel = FALSE)
  
  rv <- reactiveValues(interactive = list())

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