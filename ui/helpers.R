# Set up a button to have an animated loading indicator and a checkmark
# for better user experience
# Need to use with the corresponding `withBusyIndicator` server function
# Adapted from the ddPCR R package written by Dean Attali
withBusyIndicator <- function(button) {
  id <- button[['attribs']][['id']]
  tagList(
    button,
    span(
      class = "btn-loading-container",
      `data-for-btn` = id,
      hidden(
        img(src = "ajax-loader-bar.gif", class = "btn-loading-indicator"),
        icon("check", class = "btn-done-indicator")
      )
    )
  )
}
