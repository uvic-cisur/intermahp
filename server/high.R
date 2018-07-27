# intermahpr-shiny - Sam Churchill 2018
# --- High server --- #

# zzz utility functions ----
current_var <- function(var) unique(high_selected_scenarios()[[var]])

truncated_filtration_div <- function(.label) {
  div(class = "truncate",
      style = paste0("width:", session$clientData$output_dummy_filtration_width, ";"),
      .label)
}

# Grouping Variables ----
#* Grouping Selections
output$high_major_render <- renderUI({
  selectInput(
    inputId = "high_major",
    label = "Major Grouping",
    choices = major_choices
    # selected = if(is.null(input$high_major)) "Condition Category" else input$high_major
  )
})

output$high_minor_render <- renderUI({
  selectInput(
    inputId = "high_minor",
    label = "Minor Grouping",
    choices = minor_choices
    # selected = if(is.null(input$high_minor)) "Region" else input$high_minor
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
    label = truncated_filtration_div("Outcome"),
    choices = unique(dataValues$model$mm$outcome),
    selected = unique(dataValues$model$mm$outcome)[1]
  )
})

# scenarios names filtered by selected outcome
filtered_scenario_names <- reactive({
  if(is.null(input$high_outcome_filter)) return(NULL)
  unique(high_selected_outcomes()[["scenario"]])
})

# Filter by scenario (dependent on grouping)
output$high_scenario_filter_render <- renderUI({
  pickerInput(
    inputId = "high_scenario_filter",
    label = truncated_filtration_div("Scenarios"),
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
          label = truncated_filtration_div(.label),
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
      label = div(class = "truncate", "Drinking Status"),
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

# Reactive datasets ----
#* reactive dataset after outcome filtering
high_selected_outcomes <- reactive({
  input$high_outcome_filter
  
  if(length(dataValues$long) == 0) return(NULL)
  scenario_names <- names(dataValues$long)
  valid_scenarios <- scenario_names[grep(input$high_outcome_filter, scenario_names)]
  .data <- reduce(.x = dataValues$long[valid_scenarios], .f = inner_join)
  .data <- gather(.data, key = "scenario", value = "aaf", valid_scenarios)
  .data$scenario <- gsub('.{10}$', '', .data$scenario)
  .data
})

#* reactive dataset after outcome filtering
high_selected_scenarios <- reactive({
  input$high_scenario_filter
  
  .data <- high_selected_outcomes()
  if(is.null(.data)) return(NULL)
  
  filtered <- filter(.data, scenario %in% input$high_scenario_filter)
  
  filtered
  
})

#* reactive dataset with full filtering
high_filtered_data <- reactive({
  .data <- high_selected_scenarios()
  
  if(is.null(.data)) return(NULL)
  
  for(var in major_choices) {
    id <- paste("high", var, "filter", sep = "_")
    var_sym <- rlang::sym(var)
    if(!is.null(input[[id]])) {
      .data <- dplyr::filter(.data, !!var_sym %in% input[[id]])
    }
  }

  .data$metric = .data$count * .data$aaf
  
  dataValues$current_total <- .data %>%
    group_by(status, scenario) %>%
    summarise(total = sum(metric, na.rm = TRUE))
  
  .data
  
})

#* render current chart
high_current_chart <- reactive({
  .data <- high_filtered_data()
  
  if(is.null(.data)) {
    return(NULL)
  }
  
  major <- rlang::sym(input$high_major)
  minor <- if(input$high_minor == "none") NULL else rlang::sym(input$high_minor)
  
  .data <- if(input$high_minor == "none") group_by(.data, !!major) else group_by(.data, !!major, !!minor)
  .data <- summarise(.data, metric = sum(metric, na.rm = T))
  .data[["Attributable Count"]] <- .data$metric
  .data$metric <-  NULL
  
  cc <- 
  
  # nPlot(
  #   speed ~ dist,
  #   data = cars,
  #   type = "multiBarChart"
  # )
    
  nPlot(
    x = major,
    y = "Attributable Count",
    group = minor,
    data = .data,
    type = "multiBarHorizontalChart"
  )
  
  cc$set(width = 0.975*session$clientData$output_dummy_chart_width)
  cc$set(dom = "high_chart")
  
  x_names <- .data[[major]]
  left_margin <- if(is.character(x_names) && length(x_names)) max(8*max(nchar(x_names)), 55) else 0

  cc$chart(margin = list("left" = left_margin))
  
  if(is_grouped_by_status() || is_grouped_by_scenario() || is.null(minor)) cc$chart(showControls = FALSE)
  
  return(cc)
})


#* display current chart
output$high_chart <- renderChart({
  # browser()
  
  hc <- high_current_chart()

  if(is.null(hc)) {
    return(rCharts$new())
  }
  
  return(hc)
})


#Update chart when not visible
outputOptions(output, "high_chart", suspendWhenHidden = FALSE)


# update all filtration systems when not visible
# outputOptions(output, "high_outcome_filter_render", suspendWhenHidden = FALSE)
# outputOptions(output, "high_scenario_filter_render", suspendWhenHidden = FALSE)
# outputOptions(output, "high_simple_filters_render", suspendWhenHidden = FALSE)
# outputOptions(output, "high_status_filter_render", suspendWhenHidden = FALSE)


