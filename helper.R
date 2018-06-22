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

### Plot production ----
