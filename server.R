## intermahp - International Model of Alcohol Harms and Policies
## Copyright (C) 2018 Canadian Institute for Substance Use Research

# --- Main server file for shiny app --- #
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
library(stringr) ## add to documentation

source(file.path("server", "helpers.R"))
source("js-utils.R")

function(input, output, session) {
  # session mahp object
  smahp = reactive({mahp$new()})
  gold_pc = reactive({FALSE})
  gold_mm = reactive({FALSE})
  
  # server side reactive data store ----
  dataValues <- reactiveValues(
    grps_dict = list(),
    wide = list(),
    long = list())
  
  # preloaded data initialization ----
  # RR
  # preloaded_dataset_rr_zhao <- read_rds(file.path("data", "zhao.rds"))
  # preloaded_dataset_rr_roerecke <- read_rds(file.path("data", "roerecke.rds"))
  # preloaded_dataset_rr_sample <- read_rds(file.path("data", "intermahpr_sample_rr.rds"))
  # output$sampleRR <- downloadHandler(
  #   filename = "intermahpr_sample_rr.csv",
  #   content = function(fname) {
  #     write_csv(preloaded_dataset_rr_sample, fname)
  #   }
  # )
  
  # PC & MM
  preloaded_dataset_pc <- read_rds(file.path("data", "intermahp3_sample_pc.rds"))
  output$samplePC <- downloadHandler(
    filename = "intermahpr_sample_pc.csv",
    content = function(fname) {
      write_csv(preloaded_dataset_pc, fname)
    }
  )
  
  preloaded_dataset_mm <- read_rds(file.path("data", "intermahp3_sample_mm.rds"))
  output$sampleMM <- downloadHandler(
    filename = "intermahpr_sample_mm.csv",
    content = function(fname) {
      write_csv(preloaded_dataset_mm, fname)
    }
  )
  
  # we need to have a quasi-variable flag to indicate whether or not
  # we have data to work with or if we're waiting for data to be chosen
  # Adapted from the ddPCR R package written by Dean Attali
  output$dataConfirmed <- reactive({ FALSE })
  outputOptions(output, 'dataConfirmed', suspendWhenHidden = FALSE)

  # similar to above, indicates whether settings have been confirmed
  output$settingsConfirmed <- reactive({ FALSE })
  outputOptions(output, 'settingsConfirmed', suspendWhenHidden = FALSE)
    
  # similar to above, indicates whether estimates have been generated
  output$estimatesGenerated <- reactive({ FALSE })
  outputOptions(output, 'estimatesGenerated', suspendWhenHidden = FALSE)
    
  # similar to above
  current_nav <- reactive({NULL})
  
  # When a main or secondary tab is switched, clear the error message
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
  source(file.path("server", "drinking-groups.R"), local = TRUE)$value
  source(file.path("server", "set-tables.R"), local = TRUE)$value
  source(file.path("server", "high.R"), local = TRUE)$value
  source(file.path("server", "analyst.R"), local = TRUE)$value
  
  # Initialize nav
  set_nav("about")
  hide("datasets_nextMsg")
  hide("settings_nextMsg")
  hide("generate_estimates_nextMsg")
  
  # hide the loading message ----
  hide("loading-content", TRUE, "fade") 
}