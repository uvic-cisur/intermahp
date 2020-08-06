## intermahp - International Model of Alcohol Harms and Policies
## Copyright (C) 2018 Canadian Institute for Substance Use Research

# hide model progress initially
shinyjs::hide(id = "scenario_progress_content")

#* New scenario
observeEvent(
  input$add_scenario,
  {
    withBusyIndicator(
      "add_scenario",
      {
        scale = round(1 + (0.01 * input$scenarios_rescale_percent), 4)
        tryCatch(
          {
            smahp()$def_scenario(scale)
            dataValues$sn = c(1, smahp()$sn)
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
              id = "scenarios_error_alert",
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
  }
)

dataValues$sn = 1

#* Render active scenario list ----
output$scenarios_active <- renderUI({
  sn_list = lapply(
    sort(dataValues$sn),
    function(sn) {
      .suffix = sprintf("%01.4f", sn)
      .rm_id = paste('rm', .suffix)
      .name = if(sn == 1) {
        'Baseline'
      } else {
        paste0(sprintf('%02.2+f', 100 * (sn - 1)), '%')
      }
      
      element =
        div(
          actionLink(
            inputId = .rm_id,
            label = NULL,
            icon = icon('times-circle'),
            style = if(
              sn == 1
            ) {'visibility: hidden;'} else {''}
          ),
          .name
          # popover(content = group$.popover, pos = 'right', icon("info-circle"))
        )
    }
  )
  
  
  tagList(sn_list)
})

#* remove scenario buttons ----
observeEvent(
  lapply(
    dataValues$sn,
    function(sn) {
      .suffix = sprintf("%01.4f", sn)
      .rm_id = paste('rm', .suffix)
      input[[.rm_id]]
    }
  ),
  ignoreNULL = FALSE,
  {
    lapply(
      dataValues$sn,
      function(sn) {
        .suffix = sprintf("%01.4f", sn)
        .rm_id = paste('rm', .suffix)
        if(!is.null(input[[.rm_id]]))
        {
          if(input[[.rm_id]] > 0) {
            smahp()$rm_scenario(sn)
            dataValues$sn = dataValues$sn[dataValues$sn != sn]
            runjs(paste0('Shiny.onInputChange("', .rm_id,'" , 0)'))
          }
        }
        # Renew long counts if applicable
        if(!is.null(smahp()$mm)) dataValues$long = smahp()$get_long_counts()
      }
    )
  }
)

# Monitor "add new scenario" button
# observeEvent(input$new_scenario, {
#   withBusyIndicator("new_scenario", {
#     show("scenario_progress_content")
#     withCallingHandlers(
#       {
#         scale <- 1 + (0.01 * input$new_scenarios_rescale_percent)
#         scenario_name <- paste0(scale*100, "% Consumption")
#         
#         html("scenario_progress", paste0("Adding Scenario: ", scenario_name, "<br />"), add = FALSE)
#         
#         processNewScenario(name = scenario_name, scale = scale)
#         message("Scenario added.")
#       }, message = function(m) {
#         html("scenario_progress", m$message, TRUE)
#       },
#       warning = function(m) {
#         html("scenario_progress", paste0(m$message, "\n"), TRUE)
#       }
#     )
#   })
# })

cleanTableForSetting <- function(.data) {
  .data[c("current_fraction", "former_fraction")] <- NULL
  .data <- left_join(.data, dataValues$model$mm, by = c("region", "year", "gender", "age_group", "im", "outcome"))
  .data <- mutate(.data, cc = substring(im, first = 2, last = 2))
  .data <- right_join(condition_category_ref, .data, by = "cc")
}

# Create a new scenario ----
processNewScenario <- function(name, scale)
{
  message("&emsp;Evaluating factories... ", appendLF = FALSE)
  
  dataValues$model <- intermahpr::makeScenario(dataValues$model, scenario_name = name, scale = scale)
  
  .data <- dataValues$model$scenarios[[name]]
  
  ## Entire population aafs are always computed as they are needed for adjustment
  ## ratios.  We do this here, and use them where needed.
  this_total <- dataValues$drinking_groups[["Entire Population"]]$.command(.data)
  
  ## 0 aafs can occur under some computation circumstances for both partially
  ## and wholly attributable conditions.  They are fine when adjusting partial
  ## conditions but must be replaced for whole conditions.
  this_total <- ifelse(
    (this_total == 0) & (.data$attributability == "Wholly"),
    1, this_total
  )
  
  ## Base case entire population aafs are needed for adjustment ratios in all
  ## new scenarios, so we keep them in the base reactive dataValues store.
  if(name == "Base") dataValues$base_total <- this_total
  
  ## When not base scenario, use adjusted aafs to estimate harms
  ## For wholly attributable conditions, this is 1 / base aaf total
  ## For partially attributable conditions, this is (1 - base_aaf) / (1 - this_aaf),
  ## both aaf totals.
  long_adjuster <-
    ifelse(
      .data$attributability == "Wholly",
      1 / dataValues$base_total,
      (1 - dataValues$base_total) / (1 - this_total)
    )
  
  ## Wide will display 1 as AAFs for wholly attributable conditions, and the adjustments
  ## are performed via the intermahpr distill_model.
  wide_adjuster <-
    ifelse(
      .data$attributability == "Wholly",
      1 / dataValues$base_total,
      1
    )
  
  # this_total <- map2_dbl(
  #   .x = .data$current_fraction,
  #   .y = .data$attributability,
  #   .f = ~if(.y == "Wholly") {.x(current_settings()$ub) - .x(0.03)} else {1}
  # )
  # 
  # this_total <- ifelse(this_total == 0, 1, this_total)
  ## Modify by attributability (wholly attributable conditions are the only ones affected)
  # this_attr <- ((.data$attributability == "Wholly") / this_total) + (.data$attributability == "Partially")
  # 
  # if(name == "Base") dataValues$base_attr <- this_attr
  # 
  # base_attr <- dataValues$base_attr
  # 
  
  long_table <- wide_table <- .data
  
  message("Done")
  message(paste0("&emsp;Computing attributable fractions for:"))
  
  for(group in dataValues$model$settings$include_groups) {
    message(paste0("&emsp;&emsp;", group, "... "), appendLF = FALSE)
    aafs <- if(group == "Entire Population") {
      this_total
    } else {
      dataValues$drinking_groups[[group]]$.command(.data)
    }
    long_table[[paste0("AAF: ", group)]] <- aafs * long_adjuster
    wide_table[[paste0("AAF: ", group)]] <- aafs * wide_adjuster
    message("Done")
  }
  
  if(length(dataValues$model$scenarios) > 1 && input$new_scenarios_compute_summary) {
    message("&emsp;Creating summary table... ", appendLF = FALSE)
    scenario_summary <- intermahpr::distillModel(dataValues$model)
    setWideTable(.data = scenario_summary, name = "Summary", status = "Ready", is.scenario = FALSE)
    message("Done")
  }
  
  message("&emsp;Preparing data for viewing... ", appendLF = FALSE)
  
  setLongScenarioTable(
    .data = cleanTableForSetting(long_table),
    name = name, status = "Combined", gather_vars = last_settings$include_groups)
  
  setWideTable(
    .data = cleanTableForSetting(wide_table),
    name = name, status = "Combined", is.scenario = TRUE)
  
  message("Done")
}

#* next message render ----
output$scenarios_nextMsg_render = renderUI({
  div(
    id = "scenarios_nextMsg",
    class = "next-msg",
    "Finally, add ",
    actionLink("scenarios_to_drinking_groups", "drinking groups"),
    " or examine the ",
    if('high_level_flag' %in% input$mm_flags) {
      # div(
        list(actionLink("scenarios_to_high", "high level"),
        " and ")
      # )
    },
    actionLink("scenarios_to_analyst", "analyst level"),
    " results."
  )
})

# nextMsg links ----
observeEvent(input$scenarios_to_drinking_groups, set_nav("drinking_groups"))
observeEvent(input$scenarios_to_high, set_nav("high"))
observeEvent(input$scenarios_to_analyst, set_nav("analyst"))