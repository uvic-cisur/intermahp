
# hide model progress initially
shinyjs::hide(id = "scenario_progress_content")

# Monitor "add new scenario" button
observeEvent(input$new_scenario, {
  withBusyIndicator("new_scenario", {
    show("scenario_progress_content")
    withCallingHandlers(
      {
        scale <- 1 + (0.01 * input$new_scenarios_rescale_percent)
        scenario_name <- paste0(scale*100, "% Consumption")
        # if(scale < 1) scenario_name <- paste0("0", scenario_name)
        
        html("scenario_progress", paste0("Adding Scenario: ", scenario_name, "<br />"), add = FALSE)
        
        processNewScenario(name = scenario_name, scale = scale)
        message("Scenario added.")
      }, message = function(m) {
        html("scenario_progress", m$message, TRUE)
      },
      warning = function(m) {
        html("scenario_progress", paste0(m$message, "\n"), TRUE)
      }
    )
  })
})


# Create a new scenario ----
processNewScenario <- function(name, scale)
{
  message("&emsp;Evaluating factories... ", appendLF = FALSE)
  dataValues$model <- intermahpr::makeScenario(dataValues$model, scenario_name = name, scale = scale)
  
  .data <- dataValues$model$scenarios[[name]]
  
  this_total <- intermahpr::computeTotalFraction(.data)
  this_total <- ifelse(this_total == 0, 1, this_total)
  
  base_total <- if(name == "Base") this_total else intermahpr::computeTotalFraction(dataValues$model$scenarios[["Base"]])
  base_total <- if(name == "Base") this_total else ifelse(base_total == 0, 1, base_total)
  
  ## Modify by attributability (wholly attributable conditions are the only ones affected)
  this_attr <- ((.data$attributability == "Wholly") / this_total) + (.data$attributability == "Partially")
  base_attr <- ((.data$attributability == "Wholly") / base_total) + (.data$attributability == "Partially")
  
  long_table <- wide_table <- .data
  
  message("Done")
  message(paste0("&emsp;Computing attributable fractions for:"))
  
  for(group in dataValues$model$settings$include_groups) {
    message(paste0("&emsp;&emsp;", group, "... "), appendLF = FALSE)
    aafs <- dataValues$drinking_groups[[group]]$.command(.data)
    long_table[[paste0("AAF: ", group)]] <- aafs * base_attr
    wide_table[[paste0("AAF: ", group)]] <- aafs * this_attr
    message("Done")
  }
  
  if(length(dataValues$model$scenarios) > 1 && input$new_scenarios_compute_summary) {
    message("&emsp;Creating summary table... ", appendLF = FALSE)
    scenario_summary <- intermahpr::distillModel(dataValues$model)
    setWideTable(.data = scenario_summary, name = "Summary", status = "Ready", is.scenario = FALSE)
    message("Done")
  }
  
  message("&emsp;Preparing data for viewing... ", appendLF = FALSE)
  
  long_table[c("current_fraction", "former_fraction")] <- NULL
  long_table <- left_join(long_table, dataValues$model$mm, by = c("region", "year", "gender", "age_group", "im", "outcome"))
  long_table <- mutate(long_table, cc = substring(im, first = 2, last = 2))
  long_table <- right_join(condition_category_ref, long_table, by = "cc")
  setLongScenarioTable(.data = long_table, name = name, status = "Combined", gather_vars = last_settings$include_groups)
  
  wide_table[c("current_fraction", "former_fraction")] <- NULL
  wide_table <- left_join(wide_table, dataValues$model$mm, by = c("region", "year", "gender", "age_group", "im", "outcome"))
  wide_table <- mutate(wide_table, cc = substring(im, first = 2, last = 2))
  wide_table <- right_join(condition_category_ref, wide_table, by = "cc")
  setWideTable(.data = wide_table, name = name, status = "Combined", is.scenario = TRUE)
  
  message("Done")
}
