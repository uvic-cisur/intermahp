
output$analyst_dl_tab <- renderUI({
  if(input$analyst_dl_type == "zip") {
    if(length(rv$interactive) < 1) return(NULL)
    files <- pickerInput(
      inputId = "dl_as_zip",
      label = "Choose Files",
      choices = names(rv$interactive),
      selected = names(rv$interactive),
      multiple = T,
      options = list(
        `actions-box` = TRUE, 
        `selected-text-format` = "count > 2",
        `count-selected-text` = "{0}/{1} Files"
      )
    )
    save_as <- textInput(inputId = "save_zip_as", label = "Save as", value = paste0("InterMAHP-", format(Sys.time(),  "%Y-%m-%d-%H%M")))
    button <- downloadButton(outputId = "analyst_dl_zip")
    return_list <- list(files, hr(), save_as, button)
  } else {
    files <- lapply(
      names(rv$interactive),
      function(.label) {
        list(
          downloadButton(outputId = paste0("dl_", .label), label = .label),
          br(), br()
        )
      }
    )
    return_list <- list(files)
  }
  return_list
})



output$analyst_dl_zip <- downloadHandler(
  filename = function() {
    paste0(input$save_zip_as, ".zip")
  },
  content = function(fname) {
    owd <- setwd(tempdir())
    on.exit(setwd(owd))
    fs <- NULL;
    to_zip <- input$dl_as_zip
    fs <- paste0(to_zip, ".csv")
    for(i in seq_len(length(fs))) {
      write.csv(rv$interactive[[to_zip[i]]]$.data, file = fs[i])
    }
    zip(zipfile = fname, files = fs)
  },
  contentType = "application/zip"
)



