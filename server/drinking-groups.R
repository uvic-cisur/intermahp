## intermahp - International Model of Alcohol Harms and Policies
## Copyright (C) 2018 Canadian Institute for Substance Use Research


# Drinking Group Server Logic ----

#* disable add group button initially ----
shinyjs::disable(id = "add_group_btn")


#* ensure group name is alphanumeric ----
checkGroupNameValidity <- function(string) {
  !(grepl("[^[:alnum:] ]", string) || nchar(string) == 0 || string %in% c("Entire Population", "Current Drinkers", "Former Drinkers"))
}

observeEvent(
  {
    input$new_group_name
    input$Men_upper_bound
    input$Men_lower_bound
    input$Women_upper_bound
    input$Women_lower_bound
  },
  {
    if(
      !is.null(input$new_group_name) &&
      checkGroupNameValidity(input$new_group_name) &&
      input$Men_upper_bound >= input$Men_lower_bound &&
      input$Women_upper_bound >= input$Women_lower_bound
    ) {
      shinyjs::enable(id = "add_group_btn")
    } else {
      shinyjs::disable(id = "add_group_btn")
    }
  }
)

#* drinking group reactive list ----
base_groups <- list(
  "Entire Population" = list(
    .label = "Entire Population",
    .command = function(.data) {
      intermahpr::computeTotalFraction(.data)
    },
    .popover =
      "The entire population stratified by gender and age subgrouping.
      <br />
      <br />
      Metrics for this group are always computed."
  ),
  "Current Drinkers" = list(
    .label = "Current Drinkers",
    .command = function(.data) {
      intermahpr::computeCurrentFraction(.data)
    },
    .popover = 
      "Current drinkers are people who have consumed at least one standard drink in the past year.
      <br />
      <br />
      Metrics for this group are always computed."
  ),
  "Former Drinkers" = list(
    .label = "Former Drinkers",
    .command = function(.data) {
      intermahpr::computeFormerFraction(.data)
    },
    .popover =
      "Former drinkers are people who have consumed at least one standard drink
      in their lifetime, but have not consumed one or more standard drinks in
      the past year.
      <br />
      <br />
      Metrics for this group are always computed."
  )
)

dataValues$drinking_groups <- base_groups

#* Render active group list ----
output$drinking_groups_active <- renderUI({
  group_list = lapply(
    dataValues$drinking_groups,
    function(group) {
      .name = group$.label
      .rm_id = paste('rm', .name)
      element =
        div(
          actionLink(
            inputId = .rm_id,
            label = NULL,
            icon = icon('times-circle'),
            style = if(
              .name %in% c(
                "Entire Population",
                "Current Drinkers",
                "Former Drinkers")
            ) {'visibility: hidden;'} else {''}
          ),
          .name,
          popover(content = group$.popover, pos = 'right', icon("info-circle"))
        )
    }
  )
  
  
  tagList(group_list)
})


#* Remove group buttons ----
observeEvent(
  lapply(
    dataValues$drinking_groups,
    function(group) {
      input[[paste('rm', group$.label)]]
    }
  ),
  ignoreNULL = FALSE,
  {
    lapply(
      dataValues$drinking_groups,
      function(group) {
        .rm_id = paste('rm', group$.label)
        if(!is.null(input[[.rm_id]]))
        {
          if(input[[.rm_id]] > 0) {
            smahp()$rm_group(group$.label)
            dataValues$drinking_groups[[group$.label]] <- NULL
            runjs(paste0('Shiny.onInputChange("', .rm_id,'" , 0)'))
          }
        }
        # Renew long counts if applicable
        if(!is.null(smahp()$mm)) dataValues$long = smahp()$get_long_counts()
      }
    )
  }
)


#* Render current group checkboxes ----
output$drinking_groups_checkboxes <- renderUI({
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
      
      if(id == "Include Entire Population" | id == "Include Current Drinkers") shinyjs::disabled(element) else element
    }
  )
  
  tagList(boxes)
})

#* Make sure the drinking group checkboxes and their values always exist ----
outputOptions(output, 'drinking_groups_checkboxes', suspendWhenHidden = FALSE)
outputOptions(output, 'drinking_groups_active', suspendWhenHidden = FALSE)

#* Logic when a new drinking group is added ----
observeEvent(
  input$add_group_btn,
  {
    
    lower_strata <- c()
    upper_strata <- c()
    
    popover_text <- paste(
      "Membership in the user-defined group",
      input$new_group_name,
      "is specified by the following consumption ranges in average daily grams-ethanol:<br /> "
    )
    
    for(gender in c('Men', 'Women')) {
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
    
    tryCatch(
      {
        smahp()$def_group(
          input$new_group_name,
          list(
            m = c(lower_strata[['Men']], upper_strata[['Men']]),
            w = c(lower_strata[['Women']], upper_strata[['Women']])
          )
        )
        
        # Renew long counts if applicable
        if(!is.null(smahp()$mm))
        {
          dataValues$long = smahp()$get_long_counts()
        } else {
          dataValues$long = smahp()$get_long_afs()
        }
      },
      warning = function(w) {
        # Adds the received warning to the open tab
        html(
          id = "drinking_groups_error_alert",
          paste0(
            '
            <div class="alert alert-warning alert-dismissible">
            <a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
            <strong>Warning:</strong> ',
            htmlmsg(w$message),
            '</div>   
            '
          )
        )
      }
    )
  }
)


truncated_group_div <- function(.label) {
  div(class = "truncate",
      style = paste0("width:", session$clientData$output_dummy_6in8in9_width, ";"),
      .label)
}

#* Produce a dynamic lower/upper bound input for each gender for drinking group addition ----
output$drinking_groups_bounds_render <- renderUI({
  inputs <- lapply(
    c("Men", "Women"),
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
observeEvent(input$drinking_groups_min_lb, {
  for(gender in dataValues$genders) {
    updateNumericInput(session, inputId = gsub(" ","_", paste0(gender, " lower bound")), value = 0)
  }
})

observeEvent(input$drinking_groups_max_ub, {
  for(gender in dataValues$genders) {
    updateNumericInput(session, inputId = gsub(" ","_", paste0(gender, " upper bound")), value = input$settings_ub_in_units)
  }
})

#* shift buttons functionality


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


#* Make sure the previous renders always exist ----
outputOptions(output, 'drinking_groups_bounds_render', suspendWhenHidden = FALSE)

#* next message render ----
output$drinking_groups_nextMsg_render = renderUI({
  column(
    12,
    div(
      id = "drinking_groups_nextMsg",
      class = "next-msg",
      "Finally, add new ",
      actionLink("drinking_groups_to_scenarios", "scenarios"),
      " or examine the ",
      if('high_level_flag' %in% input$mm_flags) {
        # div(
          list(actionLink("drinking_groups_to_high", "high level"),
          " and ")
        # )
      },
      actionLink("drinking_groups_to_analyst", "analyst level"),
      " results."
    )
  )
})

# nextMsg links ----
observeEvent(input$drinking_groups_to_scenarios, set_nav("scenarios"))
observeEvent(input$drinking_groups_to_high, set_nav("high"))
observeEvent(input$drinking_groups_to_analyst, set_nav("analyst"))