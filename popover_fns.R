popoverInit <- function() {
  tags$head(
    tags$script(
      "$(document).ready(function(){
      $('body').popover({
      selector: '[data-toggle=\"popover\"]',
      trigger: 'hover'        
      });});"
    )
  )
  }

popover <- function(content, pos, ...) {
  tagList(
    singleton(popoverInit()),
    tags$a(href = "#pop", `data-toggle` = "popover", `data-placement` = paste("auto", pos),
           `data-original-title` = "", title = "", `data-trigger` = "hover",
           `data-html` = "true", `data-content` = content, ...)
  )
}