# intermahpr R package - Sam Churchill June 2018
# --- Main UI file for shiny app --- #
# 

library(shiny)
library(shinyjs)
library(shinyWidgets)
library(intermahpr)
library(tidyverse)
library(rCharts)

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
          selected = "high", size = "normal",
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
        actionButton(inputId = "test", label = "Test, default params"),
        hr(),
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
        checkboxInput(inputId = "impute_missing_dh", label = "Impute missing values as 0", value = T),
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
        fluidRow(
          dropdownButton(
            tags$h3("Y:"),
            selectInput(
              inputId = "hl_y1",
              label = "Outcome", 
              choices = c("Morbidity", "Mortality"), 
              selected = "Morbidity"),
            selectInput(
              inputId = "hl_y2",
              label = "Metric", 
              choices = c(
                "Count"
                # , "Weighted AAF"
              ), 
              selected = "Count"),
            selectInput(
              inputId = "hl_y3",
              label = "Population",
              choices = c("Entire Population" = "aaf", "Current drinkers" = "aaf_cd", "Former drinkers" = "aaf_fd"),
              selected = "Entire Population"
            ),
            tags$h3("X:"),
            selectInput(
              inputId = "hl_x1",
              label = "Major",
              choices = c(
                "Condition Category" = "condition_category",
                "Region" = "region",
                "Year" = "year",
                "Gender" = "gender",
                "Age Group" = "age_group"
              ),
              selected = "Condition Category"
            ),
            selectInput(
              inputId = "hl_x2",
              label = "Minor",
              choices = c(
                "None" = "none",
                "Condition Category" = "condition_category",
                "Region" = "region",
                "Year" = "year",
                "Gender" = "gender",
                "Age Group" = "age_group"
              ),
              selected = "None"
            ),
            circle = TRUE, status = "danger", icon = icon("gear"), width = "300px",
            tooltip = tooltipOptions(title = "Variable Selection")
          ) ## end dropdownButton
          , showOutput("hl_chart", "nvd3")
          , uiOutput("hl_build_inspector")
        ) ## end fluidRow
      ) ## end conditionalPanel
      , conditionalPanel(
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
    ) ## end column
  ) ## end fluidRow
) ## end fluidPage
