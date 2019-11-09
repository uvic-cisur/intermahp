## intermahp - International Model of Alcohol Harms and Policies
## Copyright (C) 2018 Canadian Institute for Substance Use Research





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
        column(
          6,
          numericInput(
            inputId = paste0(gender, " binge barrier"),
            label = gender, #paste0(gender, " binge barrier"),
            min = 10,
            value = round(value/drinking_unit(), 2),
            max = 100,
            step = 1
          )
        )
      )
    }
  )
  
  tagList(inputs)
})


#* Dynamic scc proportions barriers ----
output$settings_global_scc_proportions_render <- renderUI({
  inputs <- lapply(
    dataValues$genders,
    function(gender) {
      value = 0.5
      if(grepl("^[Mm]", gender)) value = .33
      if(grepl("^[Ff]", gender)) value = .66
      tagList(
        # hr(),
        column(
          6,
          numericInput(
            inputId = paste0(gender, " scc proportion"),
            label = gender, #paste0(gender, " binge barrier"),
            min = 0,
            value = value,
            max = 1,
            step = 0.01
          )
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



current_settings <- reactive({
  list(
    bb = binge_barriers(),
    lb = 0.03,
    ub = input$settings_ub_in_units * drinking_unit(),
    ext = input$ext,
    include_groups = include_groups()
  )
})

## Confirm settings button ----
observeEvent(input$settings_confirm_btn, {
  smahp$set_ext(input$ext)
  smahp$set_ub(input$settings_ub_in_units * drinking_unit())
  # smahp$set_bb(list('w' = , 'm' = ))
  # smahp$set_scc()
  
  
  
  show("settings_nextMsg")
  output$settingsConfirmed <- reactive({ TRUE })
})

# nextMsg links ----
observeEvent(input$settings_to_generate_estimates, set_nav("generate_estimates"))
