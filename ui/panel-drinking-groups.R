## intermahp - International Model of Alcohol Harms and Policies
## Copyright (C) 2018 Canadian Institute for Substance Use Research

# --- Drinking Groups UI --- #

conditionalPanel(
  condition = "output.estimatesGenerated",
  # wellPanel(
    div(
      id = "drinking_groups_content",
      br(),
      column(
        8,
        wellPanel(
        h3("New groups"),
        textInput(
          inputId = "new_group_name",
          label = div(
            "Group name",
            popover(content = "Only alphanumeric group names accepted.", pos = "right", icon("info-circle"))
          ),
          placeholder = "Light Drinkers"
        ),
        hr(),
        fixedRow(
          column(
            6,
            actionButton(
              inputId = "drinking_groups_min_lb",
              label = "Use minimum",
              icon = icon("angle-double-down"),
              class = "btn-block btn-primary"
            ),
            plotOutput(outputId = "dummy_6in8in9", height = 0)
          ),
          column(
            6,
            actionButton(
              inputId = "drinking_groups_max_ub",
              label = "Use maximum",
              icon = icon("angle-double-up"),
              class = "btn-block btn-primary"
            )
          )
        ),
        hr(),
        uiOutput("drinking_groups_bounds_render"),
        hr(),
        actionButton(inputId = "add_group_btn", label = "Add new group", icon = icon("plus"), class = "btn-danger btn-block")
        )
      ),
      
      column(4, h3("Existing groups"), uiOutput("drinking_groups_checkboxes"))

    )
  # )
)