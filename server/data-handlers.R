# add interactive data entry to output ----

addDataOutput <- function(.label) {
  # dataset under consideration
  .data <- dataValues[[.label]]$.data
  
  data_label <- paste(.label, "Data")
  
  # add condition categories if applicable
  if(("im" %in% names(.data)) & !("cc" %in% names(.data))) {
    .data <- mutate(.data, cc = substring(im, first = 1, last = 3))
    .data <- right_join(condition_category_ref, .data, by = "cc")
  }
  
  # factorize relevant variables for easier filtering
  to_factor <- intersect(
    c(analysis_vars, "condition", "outcome"),
    names(.data)
  )
  .data[to_factor] <- lapply(.data[to_factor], factor)
  
  browser()
  
  # add to associated section is applicable
  if(dataValues[[.label]]$.viewable) {
    view_data_label
    
    output$data$view[[.label]] <- renderStandardDataTable(.data)
  }
  
  if(dataValues[[.label]]$.chartable) {
    output$data$chart[[.label]] <- .data
  }
  
  if(dataValues[[.label]]$.downloadable) {
    output$data$download[[.label]] <- downloadHandler(
      filename = function() {
        paste(.label, ".csv", sep = "")
      },
      content = function(file) {
        write.csv(x = .data, file = file)
      }
    )
  }
}

# remove interactive entry from output ----
removeDataOutput <- function(.label) {
  output$data$view[[.label]] <- NULL
  output$data$chart[[.label]] <- NULL
  output$data$download[[.label]] <- NULL
}