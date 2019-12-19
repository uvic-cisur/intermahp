## intermahp - International Model of Alcohol Harms and Policies
## Copyright (C) 2018 Canadian Institute for Substance Use Research

# --- About --- #
wellPanel(
  # tagList(
    includeMarkdown(file.path("text", "about.md")),
    h2("Version"),
    "InterMAHP version", as.character(utils::packageVersion("intermahp3"))
  # )
)