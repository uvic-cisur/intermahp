output$a_data_selector <- renderUI({
  dataset_selector <- selectInput(
    inputId = "a_current",
    label = "Dataset",
    choices = names(dataValues$wide),
    selected = input$a_current
  )
  
  list(
    fluidRow(
      column(4, dataset_selector)
    )
  )
})

output$a_filtration_systems <- renderUI({
  
  
})

output$a_download_table <- renderUI({
  zip_picker <- pickerInput(
    inputId = "zip_these",
    label = "Choose files",
    choices = names(dataValues$wide),
    selected = names(dataValues$wide),
    multiple = T,
    options = list(
      `actions-box` = TRUE, 
      `selected-text-format` = "count > 2",
      `count-selected-text` = paste("{0}/{1}", "Tables")
    )
  )
  
  zip_dl_btn <- downloadButton(outputId = "dl_zipped", label = "Download")
  
  first_in_list_of_single_dl_buttons = T
  
  single_btns <- lapply(
    names(dataValues$wide),
    function(.label) {
      tags$div(
        if(first_in_list_of_single_dl_buttons) {
          # an irresposible use of <<-
          first_in_list_of_single_dl_buttons <<- F
          NULL
        } else {
          br()
        },
        downloadButton(outputId = paste0("Download ", .label), label = .label)
      )
    }
  )
  
  tagList(
    if(!is.null(input$a_dl_as_zip) && input$a_dl_as_zip) {
      tagList(
        zip_picker,
        hr(),
        zip_dl_btn
      )
    } else {
      single_btns
    }
  )
})

output$dl_zipped <- downloadHandler(
  filename = function() {
    paste0("InterMAHP tables-", Sys.Date(), ".zip")
  },
  content = function(fname) {
    fs <- c()
    tmpdir <- tempdir()
    old <- setwd(tempdir())
    on.exit(setwd(old))
    
    for(.label in input$zip_these) {
      path <- paste0("InterMAHP ", .label, ".csv")
      fs <- c(fs, path)
      write_csv(dataValues$wide[[.label]], path)
    }
    zip(zipfile=fname, files=fs)
  },
  contentType = "application/zip"
)

output$a_table <- renderUI({
  DT::dataTableOutput(paste0("View ", input$a_current))
})

output$show_a_table_panel <- reactive({
  dataValues$show_a_table_panel
})

# update table panel when not visible
outputOptions(output, "show_a_table_panel", suspendWhenHidden = FALSE)

# update table when not visible
outputOptions(output, "a_table", suspendWhenHidden = FALSE)