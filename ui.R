# intermahpr R package - Sam Churchill June 2018
# --- Main UI file for shiny app --- #
# 

library(shiny)
library(shinyjs)
library(shinyWidgets)
library(intermahpr)
library(tidyverse)
library(rCharts)

source("helpers.R")

fluidPage(
  useShinyjs(),
  
  title = "InterMAHP",
  
  # Add custom JS and CSS
  shiny::singleton(tags$head(includeCSS(file.path("www", "intermahp.css")))),
  
  br(),
  fluidRow(
    column(
      3,
      wellPanel(
        radioGroupButtons(
          inputId = "view",
          choices = c("High Level View" = "high", "Analyst View" = "analyst"),
          selected = "high",
          direction = "horizontal",
          justified = T
        ),
        hr(),
        uiOutput("logo_img"),
        hr(),
        dropdownButton(
          circle = F,
          status = "primary btn-block", 
          label = "File Upload",
          inputId = "upload_dropdown_button",
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
          uiOutput("dh_validation")
        ),
        br(),
        dropdownButton(
          circle = F,
          status = "primary btn-block", 
          label = "Additional Parameters",
          inputId = "params_dropdown_button",
          numericInput(inputId = "bb_f", label = "Female Binge Barrier", value = 50, min = 0, step = 1),
          numericInput(inputId = "bb_m", label = "Male Binge Barrier", value = 65, min = 0, step = 1),
          numericInput(inputId = "ub", label = "Upper Limit of Consumption", value = 250, min = 0, step = 1),
          selectInput(
            inputId = "ext", label = "Dose Response Extrapolation Method",
            c("Linear" = T, "Capped" = F), selected = T)
          
        ),
        hr(),
        actionButton(inputId = "new_model", label = "Generate Estimates", class = "btn-block")
        , actionButton(
          inputId = "test",
          label = "Test with default parameters",
          class = "btn-primary btn-block")
      )
      # This is not the functionality you're looking for
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
          column(
            4,
            actionButton(
              inputId = "hl_data_selector_btn",
              label = "Display", 
              icon = icon("gear"),
              class = "btn-primary btn-block"
            )
          ) ## end column
          , column(
            4,
            actionButton(
              inputId = "hl_filtration_systems_btn",
              label = "Filter", 
              icon = icon("filter"),
              class = "btn-primary btn-block"
            )
          ) ## end column
          , column(
            4,
            actionButton(
              inputId = "hl_download_chart_btn",
              label = "Download", 
              icon = icon("download"),
              class = "btn-primary btn-block"
            )
          ) ## end column
        ) ## end fluidRow
        , br()
        , fluidRow(
          tags$div(
            id = "hl_ds_div",
            wellPanel(uiOutput("hl_data_selector"))
          ),
          tags$div(
            id = "hl_fs_div",
            wellPanel(uiOutput("hl_filtration_systems"))
          ),
          tags$div(
            id = "hl_dc_div",
            wellPanel(uiOutput("hl_download_chart"))
          )
        )
        , conditionalPanel(
          condition = "output.show_hl_chart_panel",
          wellPanel(
            uiOutput("hl_chart_title"),
            showOutput("hl_chart", "nvd3"),
            plotOutput("dummy")
          )
        ),
        
        
        fluidRow(
          uiOutput("hl_mainview")
        ) ## end fluidRow
      ) ## end conditionalPanel
      , conditionalPanel(
        condition = "input.view == 'analyst'",
        wellPanel(
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
    ) ## end column
  ) ## end fluidRow
) ## end fluidPage
