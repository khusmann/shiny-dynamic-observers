library(shiny)
library(purrr)
library(glue)

source("styles.R")

all_datasets <- ls("package:datasets") |>
  (\(v) v[order(tolower(v), v)])() |> # Case insensitive ordering
  set_names() |>
  map(\(x) get(x, "package:datasets")) |>
  keep(is.data.frame)

ui <- fluidPage(
  tags$head(tags$style(app_styles)),
  div(
    class = "centered-content",
    tags$h3("App Setup"),
    selectInput(
      inputId = "dataset_select",
      label = "Select a dataset:",
      choices = names(all_datasets),
      width = "100%"
    ),
    selectizeInput(
      inputId = "column_select",
      label = "Select a column:",
      choices = c("Select a column to get started" = ""),
      multiple = TRUE,
      width = "100%",
      options = list(closeAfterSelect = TRUE)
    ),
    uiOutput("cards_ui", class = "card-container")
  )
)

server <- function(input, output, session) {
  dataset <- shiny::reactive({
    all_datasets[[input$dataset_select]]
  })

  observe({
    updateSelectizeInput(
      inputId = "column_select",
      choices = c("Select a column to get started" = "", names(dataset())),
    )
  })

  output$cards_ui <- renderUI({
    map(rev(input$column_select), function(i) {
      tags$div(
        class = "card",
        tags$div(tags$strong(i), glue("({class(dataset()[[i]])[1]})")),
        actionButton(
          inputId = glue("{i}_close"),
          label = icon("times"),
          class = "btn btn-xs btn-danger"
        )
      )
    })
  })
}

shinyApp(ui, server)
