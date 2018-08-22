# intermahpr-shiny - Sam Churchill 2018
# --- Main server file for shiny app --- #
# 

library(shiny)
library(shinyjs)
library(shinyWidgets)
library(shinyalert)
library(intermahpr)
library(tidyverse)
library(magrittr)
library(rCharts)
library(gtools)

source(file.path("server", "helpers.R"))
source("js-utils.R")

function(input, output, session) {
  # server side reactive data store ----
  dataValues <- reactiveValues(
    wide = list(),
    long = list())
  
  # preloaded data initialization ----
  # RR
  preloaded_dataset_rr_zhao <- read_rds(file.path("data", "zhao.rds"))
  preloaded_dataset_rr_roerecke <- read_rds(file.path("data", "roerecke.rds"))
  preloaded_dataset_rr_sample <- read_rds(file.path("data", "intermahpr_sample_rr.rds"))
  output$sampleRR <- downloadHandler(
    filename = "intermahpr_sample_rr.csv",
    content = function(fname) {
      write_csv(preloaded_dataset_rr_sample, fname)
    }
  )
  
  # PC & MM
  preloaded_dataset_pc <- read_rds(file.path("data", "intermahpr_sample_pc.rds"))
  output$samplePC <- downloadHandler(
    filename = "intermahpr_sample_pc.csv",
    content = function(fname) {
      write_csv(preloaded_dataset_pc, fname)
    }
  )
  
  preloaded_dataset_mm <- read_rds(file.path("data", "intermahpr_sample_mm.rds"))
  output$sampleMM <- downloadHandler(
    filename = "intermahpr_sample_mm.csv",
    content = function(fname) {
      write_csv(preloaded_dataset_mm, fname)
    }
  )
  
  # we need to have a quasi-variable flag to indicate whether or not
  # we have data to work with or if we're waiting for data to be chosen
  # Adapted from the ddPCR R package written by Dean Attali
  output$dataChosen <- reactive({ FALSE })
  outputOptions(output, 'dataChosen', suspendWhenHidden = FALSE)
  
  # similar to above, indicates whether estimates have been generated
  output$estimatesGenerated <- reactive({ FALSE })
  outputOptions(output, 'estimatesGenerated', suspendWhenHidden = FALSE)
    
  # similar to above
  current_nav <- reactive({NULL})
  
  # save button (downloads model object)
  output$saveButton <- downloadHandler(
    filename = function() {
      "InterMAHP-estimator.rds"
    },
    content = function(file) {
      write_rds(x = dataValues$model, file)
    }
  )
  
  # When a main or secondary tab is switched, clear the error message
  # and don't show the dataset info on the About tab
  observe({
    input$tabset_datasets
    input$tabset_settings

    # clear the error message
    hide("errorDiv")
  })
  
  output$nextMsg_content <- renderUI({ NULL })
  
  # Set logo image
  output$logo_img <- renderUI({
    img(src="imahp_logo.png")
  })

  
  # Include logic for each major facet ----
  source(file.path("server", "header.R"), local = TRUE)$value
  source(file.path("server", "nav-buttons.R"), local = TRUE)$value
  source(file.path("server", "datasets.R"), local = TRUE)$value
  source(file.path("server", "settings.R"), local = TRUE)$value
  source(file.path("server", "generate-estimates.R"), local = TRUE)$value
  source(file.path("server", "new-scenarios.R"), local = TRUE)$value
  source(file.path("server", "set-tables.R"), local = TRUE)$value
  source(file.path("server", "high.R"), local = TRUE)$value
  source(file.path("server", "analyst.R"), local = TRUE)$value
  
  # Initialize nav
  set_nav("datasets")
  hide("datasets_nextMsg")
  hide("generate_estimates_nextMsg")
  hide("new_scenarios_nextMsg")
  
  # hide the loading message ----
  hide("loading-content", TRUE, "fade") 
}