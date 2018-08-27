## intermahp - International Model of Alcohol Harms and Policies
## Copyright (C) 2018 Canadian Institute for Substance Use Research

# navigation buttons ----

nav_ids <- c(
  "datasets",
  "settings",
  "generate_estimates",
  "new_scenarios",
  "high",
  "analyst"
)

observeEvent(input$nav_datasets, set_nav("datasets"))
observeEvent(input$nav_settings, set_nav("settings"))

observeEvent(input$nav_generate_estimates, set_nav("generate_estimates"))
observeEvent(input$nav_new_scenarios, set_nav("new_scenarios"))

observeEvent(input$nav_high, set_nav("high"))
observeEvent(input$nav_analyst, set_nav("analyst"))

set_nav <- function(id) {
  for(for_id in setdiff(nav_ids, id)) {
    hideElement(id = paste0("panel_", for_id))
    removeClass(id = paste0("nav_", for_id), class = "active")
  }
  
  showElement(id = paste0("panel_", id))
  addClass(id = paste0("nav_", id), class = "active")

  hide("errorDiv")  
  # hide(selector = "div.next-msg")
}



# NOTE:
# This might be doable via modules...
