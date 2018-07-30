
# hide model progress initially
shinyjs::hide(id = "scenario_progress_content")

# Monitor "add new scenario" button
observeEvent(input$new_scenario, {
  withBusyIndicator("new_scenario", {
    show("scenario_progress_content")
    html("scenario_progress", paste("Adding Scenario - rescale consumption by", input$new_scenarios_rescale_percent, "percent<br />"), add = FALSE)
    withCallingHandlers(
      {
        scale <- 1 + (0.01 * input$new_scenarios_rescale_percent)
        sign <- if(scale < 1) "" else "+"
        
        processNewScenario(paste0(sign, input$new_scenarios_rescale_percent, "% Consumption"), scale = scale)
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
  
  total <- intermahpr::computeTotalFraction(.data)
  total <- ifelse(total == 0, 1, total)
  
  ## Modify by attributability (wholly attributable conditions are the only ones affected)
  attr <- ((.data$attributability == "Wholly") / total) + (.data$attributability == "Partially")
  
  message("Done")
  message(paste0("&emsp;Computing attributable fractions for:"))
  
  include_groups <- vapply(
    X = names(dataValues$drinking_groups),
    FUN = function(group) {if(include_group(group)) group else "!"},
    FUN.VALUE = "0")
  
  include_groups <- include_groups[include_groups != "!"]
  
  for(group in include_groups) {
    message(paste0("&emsp;&emsp;", group, "... "), appendLF = FALSE)
    .data[[paste0("AAF - ", group)]] <- dataValues$drinking_groups[[group]]$.command(.data) * attr
    message("Done")
  }
  
  message("&emsp;Preparing data for viewing... ", appendLF = FALSE)
  
  .data[c("current_fraction", "former_fraction")] <- NULL
  
  ### MOVE THIS
  .data <- left_join(.data, dataValues$model$mm, by = c("region", "year", "gender", "age_group", "im", "outcome"))
  ###
  .data <- mutate(.data, cc = substring(im, first = 2, last = 2))
  .data <- right_join(condition_category_ref, .data, by = "cc")
  # .data <- factorizeVars(.data)
  
  setWideTable(.data = .data, name = name, status = "Combined", is.scenario = TRUE)
  
  setLongScenarioTable(.data = .data, name = name, status = "Combined", gather_vars = include_groups)
  
  message("Done")
}

# zzz utility functions ----
#* group inclusion logic names
include_group <- function(group) {
  input[[paste("Include", group)]]
}
