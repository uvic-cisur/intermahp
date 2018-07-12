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

x1_choices <- c(
  "Condition Category" = "condition_category",
  "Region" = "region",
  "Year" = "year",
  "Gender" = "gender",
  "Age Group" = "age_group"
)

x2_choices <- c(
  "None" = "none",
  "Condition Category" = "condition_category",
  "Region" = "region",
  "Year" = "year",
  "Gender" = "gender",
  "Age Group" = "age_group"
)

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

analysis_vars <- c(
  "Condition Category" = "condition_category",
  "Region" = "region",
  "Year" = "year",
  "Gender" = "gender",
  "Age Group" = "age_group"
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

#### Error message display ----

errorShow <- function(err) {
  errMessage <- gsub("^InterMAHPr: (.*)", "\\1", err$message)
  html("errorMsg", errMessage)
  show("errorDiv", TRUE, "fade")
}

errorHide <- function() {
  showNotification("errorHide() called")
}
