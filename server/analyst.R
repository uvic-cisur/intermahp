output$analyst_download_render <- renderUI({
  tagList(
    pickerInput(
      inputId = "analyst_select_zip_data",
      label = "Download data",
      choices = names(dataValues$wide),
      selected = names(dataValues$wide),
      multiple = T,
      options = list(
        `actions-box` = TRUE,
        `selected-text-format` = "count > 2",
        `count-selected-text` = paste("{0}/{1}", "Files")
      )
    ),
    downloadButton(
      outputId = "analyst_zip_data",
      label = "Download .zip"
    )
  )
})

output$analyst_zip_data <- downloadHandler(
  filename = function() {
    paste0("InterMAHP estimates-", Sys.Date(), ".zip")
  },
  content = function(fname) {
    fs <- c()
    tmpdir <- tempdir()
    old <- setwd(tempdir())
    on.exit(setwd(old))

    for(.label in input$analyst_select_zip_data) {
      path <- paste0("InterMAHP ", .label, ".csv")
      fs <- c(fs, path)
      write_csv(dataValues$wide[[.label]], path)
    }
    zip(zipfile=fname, files=fs)
  },
  contentType = "application/zip"
)


output$analyst_view_select_render <- renderUI({
  selectInput(
    inputId = "analyst_view_select",
    label = "View data",
    choices = names(dataValues$wide)
  )
})

current_analyst_data <- reactive({
  if(is.null(input$analyst_view_select)) return(NULL)
  dataValues$wide[[input$analyst_view_select]]
})

analyst_view_dt <- reactive({
  DT::datatable(
    rownames = FALSE,
    data = current_analyst_data(),
    filter = "top",
    extensions = "Buttons",
    options = list(
      dom = "Bfrtip",
      buttons = c("colvis", "pageLength", "csv"),
      pageLength = 12,
      lengthMenu = c(12,18,36,72),
      scrollX = TRUE,
      autoWidth = FALSE
    )
  )
})

output$analyst_view_dt_render <- DT::renderDataTable({
  analyst_view_dt()
})
