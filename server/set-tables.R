# Set Viewable (wide) tables and chartable (long) tables ----
#* Add long tables to dataValues ----
setLongScenarioTable <- function(.data, name, status = "Ready", gather_vars) {
  if(is.null(.data) | nrow(.data) == 0) return(NULL)
  if(status == "Combined") {
    setLongScenarioTable(filter(.data, grepl("Morb", outcome)), name = paste(name, "Morbidity"), status = "Ready", gather_vars = gather_vars)
    setLongScenarioTable(filter(.data, grepl("Mort", outcome)), name = paste(name, "Mortality"), status = "Ready", gather_vars = gather_vars)
  } else {
    
    long_data <- gather(.data, key = "status", value = !!name, paste0("AAF: ", gather_vars))
    long_data[["status"]] <- substring(long_data[["status"]], first = 5)
    # long_data <- factorizeVars(long_data)
    
    dataValues$long[[name]] <- long_data
  }
}



#* Add wide tables to output ----
setWideTable <- function(.data, name, status = "Ready", is.scenario = F) {
  if(is.null(.data) | nrow(.data) == 0) return(NULL)
  if(status == "Combined") {
    setWideTable(filter(.data, grepl("Morb", outcome)), name = paste(name, "Morbidity"), status = "Ready")
    setWideTable(filter(.data, grepl("Mort", outcome)), name = paste(name, "Mortality"), status = "Ready")
  } else {
    prefix <- if(is.scenario) "InterMAHP Scenario " else "InterMAHP "
    
    dataValues$wide[[name]] <- factorizeVars(.data)
    output[[paste0("View ", name)]] <- renderStandardDataTable(factorizeVars(.data))
    output[[paste0("Download ", name)]] <- downloadHandler(
      filename = function() {
        paste(prefix, name, ".csv", sep = "")
      },
      content = function(file) {
        write.csv(x = .data, row.names = F, file = file)
      }
    )
  }
}

# zzz utility functions ----
#* Turn the relevent variables into factors for easier filtering
factorizeVars <- function(.data) {
  to_factor <- intersect(c(simple_analysis_vars, "condition", "outcome"), names(.data))
  .data[to_factor] <- lapply(.data[to_factor], factor)
  .data
}

