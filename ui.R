# intermahpr R package - Sam Churchill June 2018
# --- Main UI file for shiny app --- #
# 

library(shiny)
library(shinyjs)
library(shinyWidgets)
library(intermahpr)
library(tidyverse)

source(file.path("ui", "helpers.R"))

fluidPage(
  title = "InterMAHP",
  
  fluidRow(
    column(6, h1("InterMAHP")),
    column(
      6,
      div(
        radioGroupButtons(
          inputId = "view",
          label = "",
          choices = c("High Level" = "high", "Analyst" = "analyst"),
          selected = "analyst", size = "normal",
          direction = "horizontal"),
        style = "float:right"
      )
    )
  ),
  
  # Add custom JS and CSS
  shiny::singleton(tags$head(includeCSS(file.path("www", "intermahp.css")))),
  
  # Sidebar with a slider input for number of bins
  fluidRow(
    column(
      3,
      wellPanel(
        fileInput(
          inputId = "uploaded_pc", label = "Prevalence and Consumption Data",
          accept = c("text/csv", "text/comma-separated-values", "text/plain", ".csv"),
          buttonLabel = "Choose File", placeholder = "PrevCons.csv"
        ),
        uiOutput("pc_validation"),
        fileInput(
          inputId = "uploaded_rr", label = "Relative Risk Data",
          accept = c("text/csv", "text/comma-separated-values", "text/plain", ".csv"),
          buttonLabel = "Choose File", placeholder = "RelRisks.csv"
        ),
        uiOutput("rr_validation"),
        fileInput(
          inputId = "uploaded_dh", label = "Morbidity and Mortality Data",
          accept = c("text/csv", "text/comma-separated-values", "text/plain", ".csv"),
          buttonLabel = "Choose File", placeholder = "MorbMort.csv"
        ),
        uiOutput("dh_validation"),
        numericInput(inputId = "bb_f", label = "Female Binge Barrier", value = 50, min = 0, step = 1),
        numericInput(inputId = "bb_m", label = "Male Binge Barrier", value = 65, min = 0, step = 1),
        numericInput(inputId = "ub", label = "Upper Limit of Consumption", value = 250, min = 0, step = 1),
        selectInput(
          inputId = "ext", label = "Dose Response Extrapolation Method",
          c("Linear" = T, "Capped" = F), selected = T),
        actionButton(inputId = "new_model", label = "Generate Estimates")
      )
      ## This is not the functionality you're looking for
      # , wellPanel(
      #     textInput("scenario_name", "Scenario Name"),
      #     numericInput(inputId = "scenario_diff", label = "Percent Change in Consumption", value = 0.00),
      #     actionButton(inputId = "new_scenario", label = "Generate Scenario"
      #     )
      #   )
    ),
    column(
      9,
      conditionalPanel(
        condition = "input.view == 'high'",
        uiOutput("high_level")
      ),
      conditionalPanel(
        condition = "input.view == 'analyst'",
        tabsetPanel(
          tabPanel(
            title = "Context",
            br(),
            DT::dataTableOutput("Prevalence and Consumption")
          ),
          tabPanel(
            title = "Morbidity",
            br(),
            DT::dataTableOutput("Morbidity AAFs")
          ),
          tabPanel(
            title = "Mortality",
            br(),
            DT::dataTableOutput("Mortality AAFs")
          ),
          tabPanel(
            title = "Downloads",
            br(),
            radioGroupButtons(
              inputId = "analyst_dl_type", 
              label = "Download Preference",
              choices = c("One .zip file" = "zip", "Individual files" = "ind"),
              selected = "zip",
              direction = "horizontal"),
            hr(),
            uiOutput("analyst_dl_tab"),
            uiOutput("chekit")
          )
        )
      )
    )
  )
)