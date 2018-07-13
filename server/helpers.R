### Common DT options ----
base_options <- list(
  dom = "Bfrtip",
  buttons = c("colvis", "pageLength"),
  pageLength = 12,
  lengthMenu = c(12,18,36,72),
  scrollX = TRUE,
  autoWidth = TRUE
)

# * columnDefs elements ----

cd_hide0 <- list(
  targets = 0,
  visible = FALSE
)

cd_hidex <- function(target) {
  list(
    targets = target,
    visible = FALSE
  )
}

cd_dots <- function(targets, maxlength, after) {
  list(
    targets = targets,
    render = DT::JS(
      "function(data, type, row, meta) {",
      "return type === 'display' && data.length > ",
      maxlength,
      " ? '<span title=\"' + data + '\">' + data.substr(0,",
      after,
      ") + '...</span>' : data;}"
    )
  )
}

# * Column formatting ----

reformat <- function(tbl, type, col) {
  if(type == "dec") {
    tbl <- DT::formatRound(
      table = tbl,
      columns = col,
      digits = 4)
  }
  else {
    tbl <- DT::formatPercentage(
      table = tbl,
      columns = col,
      digits = 2)
  }
  tbl
}

# * Dummy, grammar, and reference tables ----

analysis_vars <- c(
  "Condition Category" = "condition_category",
  "Region" = "region",
  "Year" = "year",
  "Gender" = "gender",
  "Age Group" = "age_group",
  "Population" = "population"
)

x1_choices <- analysis_vars

x2_choices <- c("None" = "none", x1_choices)

pluralise <- function(var) {
  switch(
    var,
    "Condition Category" = "Categories",
    "Age Group" = "Age Groups",
    "Region" = "Regions",
    "Gender" = "Genders",
    "Year" = "Years"
  )
}

condition_category_ref <- tibble(
  cc = paste0("(", 1:9, ")"),
  condition_category = c(
    "Communicable",
    "Cancer",
    "Endocrine",
    "Neuro",
    "Cardio",
    "Digestive",
    "Collisions",
    "Unintentional",
    "Intentional"
  )
)

dh_replacement <- tibble(
  im = "(0).(0)", 
  region = "Unspecified", 
  year = 0, 
  gender = "None",
  age_group = "None", 
  outcome = "None", 
  count = 0
)

# Button with "busy" indicator ----
# Adapted from the ddPCR R package written by Dean Attali
  
# For better user experience, when a button is pressed this will disable
# the button while the action is being taken, show a loading indicator, and
# show a checkmark when it's done. If an error occurs, show the error message. 
# This works best if the given button was set up with `withBusyIndicator` in
# the UI (otherwise it will only disable the button and take care of errors,
# but won't show the loading/done indicators)
withBusyIndicator <- function(buttonId, expr) {
  
  loadingEl <- sprintf("[data-for-btn=%s] .btn-loading-indicator", buttonId)
  doneEl <- sprintf("[data-for-btn=%s] .btn-done-indicator", buttonId)
  disable(buttonId)
  show(selector = loadingEl)
  hide(selector = doneEl)
  hide("errorDiv")
  on.exit({
    enable(buttonId)
    hide(selector = loadingEl)
  })
  
  # tryCatch({
    value <- expr
    show(selector = doneEl)
    delay(2000, hide(
      selector = doneEl, anim = TRUE, animType = "fade",
      time = 0.5))
    value
  # }, error = errorFunc)
}

# Error message display ----
# Adapted from the ddPCR R package written by Dean Attali

# Error handler that gets used in many tryCatch blocks
errorShow <- function(err) {
  html("errorMsg", err$message)
  show("errorDiv", TRUE, "fade")
}

errorHide <- function() {
  showNotification("errorHide() called")
}
