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


# Standard drinks dictionary
unit_options <- c(
  "Grams-ethanol",
  "Australia",
  "Austria",
  "Canada",
  "Denmark",
  "Finland",
  "France",
  "Germany",
  "Hong Kong",
  "Hungary",
  "Iceland",
  "Ireland",
  "Italy",
  "Japan",
  "Netherlands",
  "New Zealand",
  "Poland",
  "Portugal",
  "Spain",
  "Switzerland",
  "United Kingdom",
  "United States"
)

units <- list(
  "Grams-ethanol" = 1,
  "Australia" = 10,
  "Austria" = 20,
  "Canada" = 13.45,
  "Denmark" = 12,
  "Finland" = 12,
  "France" = 10,
  "Germany" = 10,
  "Hong Kong" = 10,
  "Hungary" = 17,
  "Iceland" = 8,
  "Ireland" = 10,
  "Italy" = 10,
  "Japan" = 19.75,
  "Netherlands" = 10,
  "New Zealand" = 10,
  "Poland" = 10,
  "Portugal" = 14,
  "Spain" = 10,
  "Switzerland" = 12,
  "United Kingdom" = 8,
  "United States" = 14
)

country_as_adjective <- list(
  "Australia" = "Australian",
  "Austria" = "Austrian",
  "Canada" = "Canadian",
  "Denmark" = "Danish",
  "Finland" = "Finnish",
  "France" = "French",
  "Germany" = "German",
  "Hong Kong" = "Hong Kong",
  "Hungary" = "Hungarian",
  "Iceland" = "Icelandic",
  "Ireland" = "Irish",
  "Italy" = "Italian",
  "Japan" = "Japanese",
  "Netherlands" = "Dutch",
  "New Zealand" = "New Zealand",
  "Poland" = "Polish",
  "Portugal" = "Portugese",
  "Spain" = "Spanish",
  "Switzerland" = "Swiss",
  "United Kingdom" = "British",
  "United States" = "American"
)
