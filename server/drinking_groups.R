dataValues$drinking_groups <- list(
  "Former Drinkers" = list(
    .label = "Former Drinkers",
    .command = function(.data) {
      intermahpr::addFormerFraction(.data, var_name = "AAF - Former Drinkers")
    },
    .popover = paste(
      "Former drinkers are people who have consumed one standard drink or more",
      "in their lifetime, but have not consumed at least one standard drink in",
      "the past year."
    )
  ),
  "Current Drinkers" = list(
    .label = "Current Drinkers",
    .command = function(.data) {
      intermahpr::addCurrentFraction(.data, var_name = "AAF - Current Drinkers")
    },
    .popover = paste(
      "Current drinkers are people who have consumed one standard drink or",
      "more in the past year."
    )
  ),
  "Entire Population" = list(
    .label = "Entire Population",
    .command = function(.data) {
      intermahpr::addTotalFraction(.data, var_name = "AAF - Entire Population")
    },
    .popover = paste(
      "The entire population stratified by gender and age subgrouping."
    )
  )
)

output$group_checkboxes <- renderUI({
  boxes <- lapply(
    dataValues$drinking_groups,
    function(group) {
      id <- paste0("Include", gsub(" ", "", group$.label, fixed = TRUE))
      
      tags$div(
        checkboxInput(
          inputId = id,
          label = div(
            group$.label,
            popover(content = group$.popover, pos = "right", icon("question-circle"))
          )   
        )
      )
    }
  )
  tagList(boxes)
})

checkGroupNameValidity <- function(string) {
  length(string > 0) && !grepl("[^[:alnum:] ]", string)
}

output$add_group_ui <- renderUI({
  enter_name <- textInput(
    inputId = "new_group_name",
    label = div(
      "Group name",
      popover(content = "Only alphanumeric group names accepted.", pos = "right", icon("question-circle"))
    ),
    placeholder = "Light/Heavy Drinkers")
  
  male_bounds <- fluidRow(
    column(
      6,
      numericInput(
        inputId = "m_lb",
        label = "Male Lower Bound",
        value = 15,
        min = 0, 
        max = 250,
        step = 1)
    ),
    column(
      6,
      numericInput(
        inputId = "m_ub",
        label = "Male Upper Bound",
        value = 30,
        min = 0, 
        max = 250,
        step = 1)
    )
  )
  
  female_bounds <- fluidRow(
    column(
      6,
      numericInput(
        inputId = "f_lb",
        label = "Female Lower Bound",
        value = if(is.null(input$f_lb)) 10 else input$f_lb,
        min = 0, 
        max = 250,
        step = 1)
    ),
    column(
      6,
      numericInput(
        inputId = "f_ub",
        label = "Female Upper Bound",
        value = if(is.null(input$f_ub)) 20 else input$f_ub,
        min = 0, 
        max = 250,
        step = 1)
    )
  )
  
  button <- actionButton(
    inputId = "add_group_btn", 
    label = "Add new group", 
    icon = icon("plus"),
    class = "btn-danger btn-block"
  )
  
  
  ## disable estimation generation button initially
  shinyjs::disable(id = "add_group_btn")
  if(!is.null(input$new_group_name) && checkGroupNameValidity(input$new_group_name)) shinyjs::enable(id = "add_group_btn")
  
  tagList(enter_name, female_bounds, male_bounds, button)
})

observeEvent(input$add_group_btn, {
  dataValues$drinking_groups[[input$newgroup_name]] <- list(
    
    
  )
  
})