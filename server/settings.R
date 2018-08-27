## intermahp - International Model of Alcohol Harms and Policies
## Copyright (C) 2018 Canadian Institute for Substance Use Research

# Drinking Group Server Logic ----

#* disable estimation generation button initially ----
shinyjs::disable(id = "add_group_btn")

#* ensure group name is alphanumeric ----
checkGroupNameValidity <- function(string) {
  !(grepl("[^[:alnum:] ]", string) || nchar(string) == 0 || string %in% c("Entire Population", "Current Drinkers", "Former Drinkers"))
}

observe({
  if(!is.null(input$new_group_name) && checkGroupNameValidity(input$new_group_name)) shinyjs::enable(id = "add_group_btn") else shinyjs::disable(id = "add_group_btn")
})

#* drinking group reactive list ----
base_groups <- list(
  "Entire Population" = list(
    .label = "Entire Population",
    .command = function(.data) {
      intermahpr::computeTotalFraction(.data)
    },
    .popover = paste(
      "The entire population stratified by gender and age subgrouping.
      <br />
      <br />
      Metrics for this group are always computed."
    )
  ),
  "Current Drinkers" = list(
    .label = "Current Drinkers",
    .command = function(.data) {
      intermahpr::computeCurrentFraction(.data)
    },
    .popover = paste(
      "Current drinkers are people who have consumed at least one standard drink in the past year."
    )
  ),
  "Former Drinkers" = list(
    .label = "Former Drinkers",
    .command = function(.data) {
      intermahpr::computeFormerFraction(.data)
    },
    .popover = paste(
      "Former drinkers are people who have consumed at least one standard",
      "in their lifetime, but have not consumed one or more standard drinks in",
      "the past year."
    )
  )
)

dataValues$drinking_groups <- base_groups

#* Render current group checkboxes ----
output$group_checkboxes <- renderUI({
  boxes <- lapply(
    dataValues$drinking_groups,
    function(group) {
      id <- paste("Include", group$.label)
      
      element <- tags$div(
        checkboxInput(
          inputId = id,
          label = div(
            group$.label,
            popover(content = group$.popover, pos = "right", icon("info-circle"))
          ),
          value = if(is.null(input[[id]])) TRUE else input[[id]]
        )
      )
      
      if(id == "Include Entire Population") shinyjs::disabled(element) else element
    }
  )
  
  tagList(boxes)
})

#* Make sure the drinking group checkboxes and their values always exist ----
outputOptions(output, 'group_checkboxes', suspendWhenHidden = FALSE)

#* Logic when a new drinking group is added ----
observeEvent(input$add_group_btn, {
  lower_strata <- c()
  upper_strata <- c()
  
  popover_text <- paste(
    "Membership in the user-defined group",
    input$new_group_name,
    "is specified by the following consumption ranges in average daily grams-ethanol:<br /> "
  )
  
  for(gender in dataValues$genders) {
    lower_strata[[gender]] = input[[gsub(" ","_", paste0(gender, " lower bound"))]]
    upper_strata[[gender]] = input[[gsub(" ","_", paste0(gender, " upper bound"))]]
    popover_text <- paste0(
      popover_text,
      gender,
      ": ",
      round(input[[gsub(" ","_", paste0(gender, " lower bound"))]] * drinking_unit(), 2),
      " to ",
      round(input[[gsub(" ","_", paste0(gender, " upper bound"))]] * drinking_unit(), 2),
      "<br />"
    )
  }
  
  dataValues$drinking_groups[[input$new_group_name]] <- list(
    .label = input$new_group_name,
    .command = function(.data) {
      intermahpr::computeGenderStratifiedIntervalFraction(
        .data, 
        lower_strata = lower_strata * drinking_unit(),
        upper_strata = upper_strata * drinking_unit()
      )
    },
    .popover = popover_text
  )
})


truncated_group_div <- function(.label) {
  div(class = "truncate",
      style = paste0("width:", session$clientData$output_dummy_6in8in9_width, ";"),
      .label)
}


#* Produce a dynamic lower/upper bound input for each gender for drinking group addition ----
output$settings_drinking_group_bounds_render <- renderUI({
  inputs <- lapply(
    dataValues$genders,
    function(gender) {
      tagList(
        fluidRow(
          column(
            6,
            numericInput(
              inputId = gsub(" ","_", paste0(gender, " lower bound")),
              label = truncated_group_div(paste0(gender, " lower bound")),
              min = 0,
              value = round(15/drinking_unit(), 2),
              max = 1000,
              width = validateCssUnit(session$clientData$output_dummy_6in8in9_width)
            )
          ),
          column(
            6,
            numericInput(
              inputId = gsub(" ","_", paste0(gender, " upper bound")),
              label = truncated_group_div(paste0(gender, " upper bound")),
              min = 0,
              value = round(30/drinking_unit(), 2),
              max = 1000,
              width = validateCssUnit(session$clientData$output_dummy_6in8in9_width)
            )
          )
        )
      )
    }
  )
  
  tagList(inputs)
})

#* min/max button functionality
observeEvent(input$settings_min_lb, {
  for(gender in dataValues$genders) {
    updateNumericInput(session, inputId = gsub(" ","_", paste0(gender, " lower bound")), value = 0)
  }
})

observeEvent(input$settings_max_ub, {
  for(gender in dataValues$genders) {
    updateNumericInput(session, inputId = gsub(" ","_", paste0(gender, " upper bound")), value = input$settings_ub_in_units)
  }
})

# Global Parameter Server Logic ----
#* Dynamic binge barriers ----
output$settings_global_binge_barrier_render <- renderUI({
  inputs <- lapply(
    dataValues$genders,
    function(gender) {
      value = 60
      if(grepl("^[Mm]", gender)) value = 65
      if(grepl("^[Ff]", gender)) value = 50
      tagList(
        # hr(),
        numericInput(
          inputId = paste0(gender, " binge barrier"),
          label = paste0(gender, " binge barrier"),
          min = 0,
          value = round(value/drinking_unit(), 2),
          max = 1000
        )
      )
    }
  )
  
  tagList(inputs)
})

#* Global upper bound ----
output$settings_global_upper_limit <- renderUI({
  numericInput(
    inputId = "settings_ub_in_units",
    label = "Upper limit of consumption",
    value = round(250/drinking_unit(), 2),
    min = 0,
    max = 1000
  )
})

#* Make sure the previous renders always exist ----
outputOptions(output, 'settings_drinking_group_bounds_render', suspendWhenHidden = FALSE)
outputOptions(output, 'settings_global_binge_barrier_render', suspendWhenHidden = FALSE)
outputOptions(output, 'settings_global_upper_limit', suspendWhenHidden = FALSE)

#* Drinking Unit ----

unit_popover_content <- reactive({
  content <- if(drinking_unit() == 1) {
    "All units currently in grams-ethanol.<br /><br />Choose a country to convert to standard drinks."
  } else {
    paste(
      "The",
      country_as_adjective[[input$settings_unit]],
      "standard drink is defined as",
      drinking_unit(),
      "grams-ethanol."
    )
  }
})

output$settings_unit_render <- renderUI({
  selectInput(
    inputId = "settings_unit",
    label = div(
      "Unit of average daily consumption",
      popover(content = unit_popover_content(), pos = "right", icon("info-circle"))
    ),
    choices = unit_options,
    selected = input$settings_unit
  )
})

drinking_unit <- reactive({
  if(is.null(input$settings_unit)) return(1)
  as.numeric(units[[input$settings_unit]])
})

#* Reactive lists ----

binge_barriers <- reactive({
  barriers <- list()
  
  for(gender in dataValues$genders) {
    barriers[[gender]] =input[[paste0(gender, " binge barrier")]] * drinking_unit()
  }
  
  barriers
})

#* group inclusion logic names
include_group <- function(group) {
  input[[paste("Include", group)]]
}

include_groups <- reactive({
  X <- vapply(
    X = names(dataValues$drinking_groups),
    FUN = function(group) {if(include_group(group)) group else "!"},
    FUN.VALUE = "0")
  
  X <- X[X != "!"]
  X
})

current_settings <- reactive({
  list(
    bb = binge_barriers(),
    lb = 0.03,
    ub = input$settings_ub_in_units * drinking_unit(),
    ext = input$ext,
    include_groups = include_groups()
  )
})


# nextMsg links ----
observeEvent(input$settings_to_generate_estimates, set_nav("generate_estimates"))
