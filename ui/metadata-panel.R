conditionalPanel(
  condition = "output.dataChosen",
  wellPanel(
    div(
      id = "metadata_div",
      div(
        id = "pc_meta_div",
        uiOutput("pc_metadata", inline = TRUE)
      ),
      div(
        id = "rr_meta_div",
        uiOutput("rr_metadata", inline = TRUE)
      ),
      div(
        id = "mm_meta_div",
        uiOutput("mm_metadata", inline = TRUE)
      )
    )
  )
)