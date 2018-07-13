## disable estimation generation button initially
shinyjs::disable(id = "add_group_btn")

checkGroupNameValidity <- function(string) {
  !(grepl("[^[:alnum:] ]", string) || nchar(string) == 0)
}

observe({
  if(!is.null(input$new_group_name) && checkGroupNameValidity(input$new_group_name)) shinyjs::enable(id = "add_group_btn")
})


dataValues$drinking_groups <- list(
  "Former Drinkers" = list(
    .label = "Former Drinkers",
    .command = function(.data) {
      intermahpr::computeFormerFraction(.data)
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
      intermahpr::computeCurrentFraction(.data)
    },
    .popover = paste(
      "Current drinkers are people who have consumed one standard drink or",
      "more in the past year."
    )
  ),
  "Entire Population" = list(
    .label = "Entire Population",
    .command = function(.data) {
      intermahpr::computeTotalFraction(.data)
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
      id <- paste("Include", group$.label)
      
      tags$div(
        checkboxInput(
          inputId = id,
          label = div(
            group$.label,
            popover(content = group$.popover, pos = "right", icon("question-circle"))
          ),
          value = if(is.null(input[[id]])) TRUE else input[[id]]
        )
      )
    }
  )
  tagList(boxes)
})

# Make sure the checkboxes and their values always exist
outputOptions(output, 'group_checkboxes', suspendWhenHidden = FALSE)

observeEvent(input$add_group_btn, {
  dataValues$drinking_groups[[input$new_group_name]] <- list(
    .label = input$new_group_name,
    .command = function(.data) {
      intermahpr::computeGenderStratifiedIntervalFraction(
        .data, 
        lower_strata = list(Female = input$f_lb, Male = input$m_lb),
        upper_strata = list(Female = input$f_ub, Male = input$m_ub)
      )
    },
    .popover = paste(
      "Membership in the user defined group", input$new_group_name, "is", 
      "defined by an average daily consumption of between", input$f_lb, "and",
      input$f_ub, "for Females and between", input$m_lb, "and", input$m_ub,
      "for Males.")
  )
})