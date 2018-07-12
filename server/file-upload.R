# intermaphr-shiny - Sam Churchill 2018
# --- File upload server --- #


## Upload ----
## TODO: Combine upload/prep into a single function that throws errors on
## data that does not conform to our data standards
observe({
  inFile <- input$uploaded_rr
  if(is.null(inFile)) {return(NULL)}
  tryCatch(
    expr = {
      .data <- readr::read_csv(inFile$datapath)
      prepareRR(.data, input$ext)
      errorHide()
    }, error = errorShow)
})


rrUpped <- reactive({
  inFile <- input$uploaded_rr
  if(is.null(inFile)) {return(NULL)}
  readr::read_csv(inFile$datapath)
})

rrPrepped <- reactive({
  intermahpr::prepareRR(rrUpped(), input$ext)
})

pcUpped <- reactive({
  inFile <- input$uploaded_pc
  if(is.null(inFile)) {return(NULL)}
  readr::read_csv(inFile$datapath)
})

pcPrepped <- reactive({
  intermahpr::preparePC(
    pcUpped(), 
    bb = list(
      "Female" = input$bb_f,
      "Male" = input$bb_m
    ),
    lb = 0.03,
    ub = input$ub
  )
})

## TODO: conform to new data structure
observeEvent(input$uploaded_pc, {
  setTable(
    label = "Prevalence and Consumption",
    .data = intermahpr::displayPC(pcPrepped())
  )
})

dhUpped <- reactive({
  if(is.null(input$uploaded_dh)) return(dh_replacement)
  
  inFile <- input$uploaded_dh
  if(is.null(inFile)) {return(NULL)}
  readr::read_csv(inFile$datapath)
})

dhPrepped <- reactive({
  intermahpr::prepareDH(dhUpped())
})



output$rr_validation <- renderUI({
  validate(
    need(!(is.null(input$uploaded_rr) & input$new_model), "Relative risk data required to build a model.")
  )
})

output$pc_validation <- renderUI({
  validate(
    need(!(is.null(input$uploaded_pc) & input$new_model), "Prevalence and Consumption data required to build a model.")
  )
})

## enable estimation when valid, using "pc and rr uploaded" as validity proxy
dataPrepped <- observe({
  if(!is.null(pcUpped()) && !is.null(rrUpped())) {
    shinyjs::enable("new_model")
  }
})

