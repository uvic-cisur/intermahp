## intermahp - International Model of Alcohol Harms and Policies
## Copyright (C) 2018 Canadian Institute for Substance Use Research

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
    
    stamp <- format(Sys.time(),"%Y-%m-%d-%H%M")
    dir.create(stamp)
    
    for(.label in input$analyst_select_zip_data) {
      path <- file.path(stamp, paste0("InterMAHP ", .label, ".csv"))
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

output$analyst_download <- downloadHandler(
  filename = "InterMAHP.csv",
  content = function(fname) {
    write_csv(current_analyst_data(), fname)
  }
)

current_analyst_data <- reactive({
  if(is.null(input$analyst_view_select)) return(NULL)
  dataValues[[input$analyst_view_select]]
})

analyst_view_dt <- reactive({
  DT::datatable(
    rownames = FALSE,
    data = current_analyst_data(),
    filter = "top",
    extensions = "Buttons",
    options = list(
      dom = "Bfrtip",
      buttons = c("colvis", "pageLength"),
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
