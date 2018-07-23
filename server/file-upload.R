# intermaphr-shiny - Sam Churchill 2018
# --- File upload server --- #

# only enable the upload buttons when their corresponding input has a file selected ----
# Adapted from the ddPCR R package written by Dean Attali
observeEvent(
  {
    input$upload_rr
    input$upload_pc
    input$upload_dh
  },
  ignoreNULL = FALSE,
  {
    toggleState(
      "upload_files_btn",
      !is.null(input$upload_pc) && !is.null(input$upload_rr) && !is.null(input$upload_dh)
    )
  }
)

# When the "Upload Data" button is clicked ----
observeEvent(input$upload_files_btn, {
  withBusyIndicator("upload_files_btn", {
    pc <- readr::read_csv(input$upload_pc$datapath)
    rr <- readr::read_csv(input$upload_rr$datapath)
    dh <- readr::read_csv(input$upload_dh$datapath)
    
    clean(pc, intermahpr::getExpectedVars("pc"))
    clean(rr, intermahpr::getExpectedVars("rr"))
    clean(dh, intermahpr::getExpectedVars("dh"))
    
    dataValues$pc_in <- pc
    dataValues$rr_in <- rr
    dataValues$dh_in <- dh
    
    # Ensure data cohesion (gender levels match, etc)

    output$datasetsChosen <- reactive({ TRUE })
    
    
    
    shinyjs::enable("new_model")
  })
})


# 
# output$rr_validation <- renderUI({
#   validate(
#     need(!(is.null(input$uploaded_rr) & input$new_model), "Relative risk data required to build a model.")
#   )
# })
# 
# output$pc_validation <- renderUI({
#   validate(
#     need(!(is.null(input$uploaded_pc) & input$new_model), "Prevalence and Consumption data required to build a model.")
#   )
# })

## enable estimation when valid, using "pc and rr uploaded" as validity proxy
# dataPrepped <- observe({
#   if(!is.null(pcUpped()) && !is.null(rrUpped())) {
#     shinyjs::enable("new_model")
#   }
# })
# 
