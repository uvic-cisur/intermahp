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
  )
})

output$high_minor_render <- renderUI({
  selectInput(
    inputId = "high_minor",
    label = "Minor Grouping",
    choices = minor_choices
  )
})

#* dueling selectors
observe({
  x1 <- input$high_major
  x2 <- input$high_minor
  
  x1_c <- major_choices[!(major_choices %in% x2)]
  x2_c <- minor_choices[!(minor_choices %in% x1)]
  
  updateSelectInput(session, "high_major", choices = x1_c, selected = x1)
  updateSelectInput(session, "high_minor", choices = x2_c, selected = x2)  
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
  
  # If including rate/10,000 people (drinkers?) as a metric, here is where we still
  # have the variables necessary to join with model$pc[c(key, population)]
  
  .data
  
})

#* summarized chartable data
high_chartable_data <- reactive({
  
  .data <- high_filtered_data()
  
  if(is.null(.data)) {
    return(NULL)
  }
  
  major <- rlang::sym(input$high_major)
  minor <- if(input$high_minor == "none") NULL else rlang::sym(input$high_minor)
  
  .data <- if(is.null(minor)) group_by(.data, !!major) else group_by(.data, !!major, !!minor)
  .data <- summarise(.data, y = round(sum(metric, na.rm = T), 2)) %>% ungroup()

  if(!is.null(minor)) .data <- spread(.data, key = !!minor, value = y)
    
  .data$categories <- .data[[major]]
  .data[[major]] <- NULL
  
  .data
})

high_current_chart <- reactive({
  cc <- Highcharts$new()
  cc$set(dom = "high_chart")
  cc$chart(type = "column")
  cc$yAxis(title = list(text = "Attributable count"))
  cc$xAxis(type = "category")
  
  .data <- high_chartable_data()
  if(is.null(.data) || nrow(.data) == 0) {
    return(cc) 
  }
  
  cc$xAxis(categories = .data$categories)

  if(input$high_minor == "none") {
    cc$legend(enabled = F)
    .data[["Attributable count"]] <- .data$y
    .data$y <- NULL
  }
  
  cc$data(select(.data, -categories))
  
  if(nrow(.data) == 1) {
    cc$xAxis(categories = c(.data$categories, NA))
    if(ncol(.data) == 2) {
      cc$legend(enabled = F)
    }
  }
  
  cc$exporting(enabled = T, formAttributes=list(target='_blank'))
  cc$title(text = chart_title())
  
  cc
})

#* reactive chart title
chart_title <- reactive({
  if(is.null(input$high_outcome_filter) || is.null(input$high_major) || is.null(input$high_minor)) return("")
  
  paste0(
    "Alcohol Attributable ",
    pluralise(as.character(input$high_outcome_filter)),
    " grouped by ",
    choices_reverse_lookup[input$high_major],
    if(input$high_minor != "none") paste0(" and ", choices_reverse_lookup[input$high_minor])
  )
})


#* display current chart
output$high_chart <- renderChart({
  chart <- high_current_chart()
  
  if(is.null(chart)) return(rCharts$new())

  show("high_chart_div")
  return(chart)
})



# Summary table for high-level view

output$high_summary_render <- renderUI({
  .data <- high_chartable_data()
  
  if(is.null(.data)) return(NULL)
  # browser()

  N <- ncol(.data)
  M <- nrow(.data)
  
  summable <- select(.data, -N)
  cats <- select(.data, N)
  cats[[choices_reverse_lookup[input$high_major]]] <- cats$categories
  cats %<>% select(-categories)
  
  if(N == 2 && input$high_minor == "none") {
    summable$`Attributable count` <- summable$y
    summable %<>% select(-y)
  }
    
  if(N > 2 && !(input$high_minor %in% c("status", "scenario")))
    summable %<>% mutate(Total = round(rowSums(.), 2))
  if(M > 1 && !(input$high_major %in% c("status", "scenario"))) {
    summable %<>% rbind(summarise_all(summable, sum))
    cats[M+1, 1] <- "Total"
  }
  
  .data <- cbind(cats, summable)

  options <- list(
    dom = "Bfrtip",
    buttons = list("colvis", "pageLength", list(extend='csv', filename = "InterMAHP High Level Summary")),
    pageLength = 12,
    lengthMenu = c(12,18,36,72),
    scrollX = TRUE,
    autoWidth = FALSE
  )
  
  output$high_summary_dt <- renderStandardDataTable(.data, options)
  
  DT::dataTableOutput("high_summary_dt")
})


# update some elements when not visible
outputOptions(output, "high_major_render", suspendWhenHidden = FALSE)
outputOptions(output, "high_minor_render", suspendWhenHidden = FALSE)

outputOptions(output, "high_scenario_filter_render", suspendWhenHidden = FALSE)
outputOptions(output, "high_simple_filters_render", suspendWhenHidden = FALSE)
outputOptions(output, "high_status_filter_render", suspendWhenHidden = FALSE)

outputOptions(output, "high_chart", suspendWhenHidden = FALSE)
