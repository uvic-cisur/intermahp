# Drinking Group Server Logic ----

# disable estimation generation button initially
shinyjs::disable(id = "add_group_btn")

# ensure group name is alphanumeric
checkGroupNameValidity <- function(string) {
  !(grepl("[^[:alnum:] ]", string) || nchar(string) == 0)
}

observe({
  if(!is.null(input$new_group_name) && checkGroupNameValidity(input$new_group_name)) shinyjs::enable(id = "add_group_btn")
})

# drinking group reactive list
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
      "Current drinkers are people who have consumed one standard drink or",
      "more in the past year."
    )
  ),
  "Former Drinkers" = list(
    .label = "Former Drinkers",
    .command = function(.data) {
      intermahpr::computeFormerFraction(.data)
    },
    .popover = paste(
      "Former drinkers are people who have consumed one standard drink or more",
      "in their lifetime, but have not consumed at least one standard drink in",
      "the past year."
    )
  )
)

dataValues$drinking_groups <- base_groups

# Render current group checkboxes
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
            popover(content = group$.popover, pos = "right", icon("question-circle"))
          ),
          value = if(is.null(input[[id]])) TRUE else input[[id]]
        )
      )
      
      if(id == "Include Entire Population") shinyjs::disabled(element) else element
    }
  )
  
  tagList(boxes)
})


# Make sure the checkboxes and their values always exist
outputOptions(output, 'group_checkboxes', suspendWhenHidden = FALSE)

# Logic when a new group is added
observeEvent(input$add_group_btn, {
  lower_strata <- c()
  upper_strata <- c()
  
  popover_text <- paste(
    "Membership in the user defined group",
    input$new_group_name,
    "specified by an average daily consumption of between "
  )
  
  for(gender in dataValues$genders) {
    lower_strata[[gender]] = input[[paste0(gender, " lower bound")]]
    upper_strata[[gender]] = input[[paste0(gender, " upper bound")]]
    popover_text <- paste0(
      popover_text,
      if(dataValues$genders[length(dataValues$genders)] == gender) "and " else NULL,
      round(input[[paste0(gender, " lower bound")]] * drinking_unit(), 2),
      " and ",
      round(input[[paste0(gender, " upper bound")]] * drinking_unit(), 2),
      " daily grams-ethanol for gender ",
      gender,
      ", ")
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

# Produce a lower/upper bound input for each gender for drinknig group addition
output$settings_drinking_group_bounds_render <- renderUI({
  inputs <- lapply(
    dataValues$genders,
    function(gender) {
      tagList(
        hr(),
        numericInput(
          inputId = paste0(gender, " lower bound"),
          label = paste0(gender, " lower bound"),
          min = 0,
          value = round(15/drinking_unit(), 2),
          max = 1000
        ),
        numericInput(
          inputId = paste0(gender, " upper bound"),
          label = paste0(gender, " upper bound"),
          min = 0,
          value = round(30/drinking_unit(), 2),
          max = 1000
        )
      )
    }
  )
  tagList(inputs)
})

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

output$settings_global_upper_limit <- renderUI({
  numericInput(
    inputId = "setting_ub_in_units",
    label = "Upper limit of consumption",
    value = round(250/drinking_unit(), 2),
    min = 0,
    max = 1000
  )
})

# Make sure the previous renders always exist
outputOptions(output, 'settings_drinking_group_bounds_render', suspendWhenHidden = FALSE)
outputOptions(output, 'settings_global_binge_barrier_render', suspendWhenHidden = FALSE)
outputOptions(output, 'settings_global_upper_limit', suspendWhenHidden = FALSE)

unit_popover_content <- reactive({
  content <- if(drinking_unit() == 1) {
    "All units currently in grams-ethanol.<br /><br />Choose a country to convert to standard drinks."
  } else {
    paste(
      "The",
      input$settings_unit,
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
      popover(content = unit_popover_content(), pos = "right", icon("question-circle"))
    ),
    choices = unit_options,
    selected = input$settings_unit
  )
})

drinking_unit <- reactive({
  if(is.null(input$settings_unit)) return(1)
  as.numeric(units[[input$settings_unit]])
})

# Reactive lists

binge_barriers <- reactive({
  barriers <- list()
  
  for(gender in dataValues$genders) {
    barriers[[gender]] =input[[paste0(gender, " binge barrier")]] * drinking_unit()
  }
  
  barriers
})
