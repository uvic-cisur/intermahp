## computations and prep ----
renderStandardDataTable <- function(.data) {
  DT::renderDataTable({
    options <- base_options
    DT::datatable(
      rownames = FALSE,
      data = .data,
      filter = "top",
      extensions = "Buttons",
      options = options
    )
  })
}

## TODO: Conform to new data standards
setTable <- function(label, .data) {
  if(is.null(label) | is.null(.data)) return(NULL)
  if(("im" %in% names(.data)) & !("cc" %in% names(.data))) {
    .data <- mutate(.data, cc = substring(im, first = 1, last = 3))
    .data <- right_join(condition_category_ref, .data, by = "cc")
  }
  
  to_factor <- intersect(
    c(analysis_vars, "condition", "outcome"),
    names(.data)
  )
  .data[to_factor] <- lapply(.data[to_factor], factor)
  
  
  rv$interactive[[label]]$.data <- .data
  
  output[[paste0("dl_", label)]] <- downloadHandler(
    filename = function() {
      paste(label, ".csv", sep = "")
    },
    content = function(file) {
      write.csv(x = .data, file = file)
    }
  )
  
  output[[label]] <- renderStandardDataTable(.data)
}

## TODO: either make this work in general or delete it entirely
observeEvent(input$test, {
  pc <- preparePC(readr::read_csv("C:/Users/samuelch.UVIC/Documents/shiny-inputs/pc_master.csv"))
  rr <- prepareRR(readr::read_csv("C:/Users/samuelch.UVIC/Documents/shiny-inputs/rr_master.csv"), T)
  dh <- prepareDH(readr::read_csv("C:/Users/samuelch.UVIC/Documents/shiny-inputs/dh_master.csv"))
  
  rv$model <- intermahpr::makeNewModel(rr, pc, dh)
  
  base_table <- left_join(
    intermahpr::formatForShinyOutput(rv$model$scenarios$base), 
    rv$model$dh, 
    by = c("region", "year", "gender", "age_group", "im", "outcome")
  )
  
  base_morb <- dplyr::filter(base_table, grepl("Morb", outcome))
  base_mort <- dplyr::filter(base_table, grepl("Mort", outcome))
  setTable(label = "Combined AAFs", .data = base_table)
  setTable(label = "Morbidity AAFs", .data = base_morb)
  setTable(label = "Mortality AAFs", .data = base_mort)
})


## disable estimation generation button initially
shinyjs::disable(id = "new_model")

## TODO: Conform to new data standards
observeEvent(input$new_model, {
  
  if(is.null(input$uploaded_rr) | is.null(input$uploaded_pc)) return(NULL)
  if(is.null(input$uploaded_dh)) showNotification("Morbidity/Mortality counts were not uploaded for the current model. They are required for some InterMAHP features.")
  
  rv$model <- intermahpr::makeNewModel(rrPrepped(), pcPrepped(), dhPrepped())
  
  base_table <- left_join(
    intermahpr::formatForShinyOutput(rv$model$scenarios$base), 
    rv$model$dh, 
    by = c("region", "year", "gender", "age_group", "im", "outcome")
  )
  
  base_morb <- dplyr::filter(base_table, grepl("Morb", outcome))
  base_mort <- dplyr::filter(base_table, grepl("Mort", outcome))
  setTable(label = "Combined AAFs", .data = base_table)
  setTable(label = "Morbidity AAFs", .data = base_morb)
  setTable(label = "Mortality AAFs", .data = base_mort)
})

## TODO:
##    Conform to new data standards
##    change scenario name as discussed w/ adam
observeEvent(input$new_scenario, {
  validate(
    need(!is.null(input$scenario_name), "Please provide a unique name for your new scenario."),
    need(is.null(rv$model$scenarios[[input$scenario_name]]), "There is already a scenario with the given name.")
  )
  
  scale <- 1+(0.01*input$scenario_diff)
  name <- input$scenario_name
  rv$model <- intermahpr::makeScenario(rv$model, scenario_name = name, scale = scale)
  setTable(name, intermahpr::formatForShinyOutput(rv$model$scenarios[[name]]))
  setTable("summary", intermahpr::distillModel(rv$model))
})

