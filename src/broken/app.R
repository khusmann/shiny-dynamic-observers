library(shiny)
library(purrr)
library(glue)

source("styles.R")

ui <- fluidPage(
  tags$head(tags$style(app_styles)),
  div(
    class = "centered-content",
    tags$h3("Attempt #1"),
    tags$hr(),
    selectInput(
      inputId = "dataset_select",
      label = "Select a dataset:",
      choices = c("iris", "mtcars"),
      width = "100%"
    ),
    uiOutput("column_select_ui"),
    uiOutput("cards_ui")
  )
)

server <- function(input, output, session) {
  dataset <- shiny::reactive({
    input$dataset_select |>
      get(envir = asNamespace("datasets")) |>
      keep(is.numeric)
  })

  output$column_select_ui <- renderUI({
    selectizeInput(
      inputId = "column_select",
      label = "Select a column:",
      choices = c("Select a column to get started" = "", names(dataset())),
      multiple = TRUE,
      width = "100%",
      options = list(closeAfterSelect = TRUE)
    )
  })

  output$cards_ui <- renderUI({
    tags$div(
      class = "card-container",
      map(rev(input$column_select), function(i) {
        i_mean <- round(mean(dataset()[[i]], na.rm = TRUE), 2)
        tags$div(
          class = "card",
          tags$div(tags$strong(i), glue("(mean: {i_mean})")),
          actionButton(
            inputId = glue("{i}_close"),
            label = "\u2716",
            class = "btn btn-xs btn-danger"
          )
        )
      })
    )
  })

  observe({
    walk(input$column_select, function(i) {
      close_btn_id <- glue("{i}_close")
      observeEvent(
        input[[close_btn_id]],
        {
          updateSelectInput(
            inputId = "column_select",
            selected = discard(input$column_select, \(j) j == i)
          )
        }
      )
    })
  })
}

shinyApp(ui, server)
