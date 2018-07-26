# intermahpr-shiny - Sam Churchill 2018
# --- High server --- #

# zzz utility functions ----
current_var <- function(var) unique(high_selected_scenarios()[[var]])

# Grouping Variables ----
#* Grouping Selections
output$high_major_render <- renderUI({
  selectInput(
    inputId = "high_major",
    label = "Major Grouping",
    choices = major_choices,
    selected = if(is.null(input$high_major)) "Condition Category" else input$high_major
  )
})

output$high_minor_render <- renderUI({
  selectInput(
    inputId = "high_minor",
    label = "Minor Grouping",
    choices = minor_choices,
    selected = if(is.null(input$high_major)) "Region" else input$high_minor
  )
})

#* Grouping checks ----
#* Are we grouping by drinking status?
is_grouped_by_status <- reactive({
  if(!is.null(input$high_major) && input$high_major == "status") return(T)
  else if(!is.null(input$high_minor) && input$high_minor == "status") return(T)
  else return(FALSE)
})

#* Are we grouping by scenario?
is_grouped_by_scenario <- reactive({
  if(!is.null(input$high_major) && input$high_major == "scenario") return(T)
  else if(!is.null(input$high_minor) && input$high_minor == "scenario") return(T)
  else return(FALSE)
})


# Filtration systems ----
# Filter by outcome
output$high_outcome_filter_render <- renderUI({
  selectInput(
    inputId = "high_outcome_filter",
    label = "Outcome",
    choices = c("Morbidity", "Mortality")
  )
})

# scenarios names filtered by selected outcome
filtered_scenario_names <- reactive({
  if(is.null(input$high_outcome_filter)) return(NULL)
  names(dataValues$long)[grep(input$high_outcome_filter, names(dataValues$long))]
})

# Filter by scenario (dependent on grouping)
output$high_scenario_filter_render <- renderUI({
  pickerInput(
    inputId = "high_scenario_filter",
    label = "Scenarios",
    choices = filtered_scenario_names(),
    selected = if(is_grouped_by_scenario()) filtered_scenario_names() else filtered_scenario_names()[1],
    multiple = is_grouped_by_scenario(),
    options = list(
      `actions-box` = TRUE, 
      `selected-text-format` = "count > 2",
      `count-selected-text` = paste("{0}/{1}", "scenarios")
    )
  )
})

# Filter by simple variables
output$high_simple_filters_render <- renderUI({
  lapply(
    names(simple_analysis_vars), 
    function(.label) {
      factors <- current_var(analysis_vars[.label])
      use_id <- paste("high", analysis_vars[.label], "filter", sep = "_")
      column(
        4,
        pickerInput(
          inputId = use_id,
          label = .label,
          choices = factors,
          selected = factors,
          multiple = TRUE,
          options = list(
            `actions-box` = TRUE, 
            `selected-text-format` = "count > 2",
            `count-selected-text` = paste("{0}/{1}", tolower(pluralise(.label)))
          )
        )
      )
    }
  )
})

# Filter by drinking status (dependent on grouping)
output$high_status_filter_render <- renderUI({
  column(
    4,
    pickerInput(
      inputId = "high_status_filter",
      label = "Drinking Status",
      choices = current_var("status"),
      selected = if(is_grouped_by_status()) current_var("status") else "Entire Population",
      multiple = is_grouped_by_status(),
      options = list(
        `actions-box` = TRUE, 
        `selected-text-format` = "count > 2",
        `count-selected-text` = paste("{0}/{1}", "statuses")
      )
    )
  )
})

# reactive dataset after outcome filtering
high_selected_scenarios <- reactive({
  if(length(dataValues$long) == 0 || is.null(input$high_scenario_filter)) return(NULL)
  .data <- reduce(.x = dataValues$long[input$high_scenario_filter], .f = inner_join)
  gather(.data, key = "scenario", value = "aaf", input$high_scenario_filter)
})

# reactive dataset with full filtering
high_filtered_data <- reactive({
  .data <- high_selected_scenarios()
  
  if(is.null(.data)) return(NULL)
  
  for(var in analysis_vars) {
    id <- paste("high", var, "filter", sep = "_")
    var_sym <- rlang::sym(var)
    if(!is.null(input[[id]])) {
      .data <- dplyr::filter(.data, !!var_sym %in% input[[id]])
    }
  }

  .data$metric = .data$count * .data$aaf
  
  dataValues$current_total <- .data %>%
    group_by(status) %>%
    summarise(total = sum(metric, na.rm = TRUE))
  
  .data
  
})

# update all filtration systems when not visible
# outputOptions(output, "high_outcome_filter_render", suspendWhenHidden = FALSE)
# outputOptions(output, "high_scenario_filter_render", suspendWhenHidden = FALSE)
# outputOptions(output, "high_simple_filters_render", suspendWhenHidden = FALSE)
# outputOptions(output, "high_status_filter_render", suspendWhenHidden = FALSE)


