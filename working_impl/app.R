library(shiny)

app_styles <- HTML("
.centered-content {
  max-width: 48rem;
  margin: 0 auto;
}
.card {
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2px solid black;
  padding: 10px;
  margin: 10px;
}
")

ui <- fluidPage(
  tags$head(tags$style(app_styles)),
  div(
    class = "centered-content",
    selectInput(
      inputId = "dataset_select",
      label = "Select a dataset:",
      choices = c("iris", "mtcars")
    ),
    uiOutput("column_select_ui"),
    uiOutput("cards_ui")
  )
)

server <- function(input, output, session) {
  dynamic_observers <- reactiveVal(list())

  dataset <- shiny::reactive({
    Filter(
      is.numeric,
      get(input$dataset_select, envir = asNamespace("datasets"))
    )
  })

  output$column_select_ui <- renderUI({
    selectInput(
      inputId = "column_select",
      label = "Select a column:",
      choices = c("Select a column to get started" = "", names(dataset())),
      multiple = TRUE
    )
  })

  output$cards_ui <- renderUI({
    lapply(isolate(dynamic_observers()), \(i) i$destroy())

    dynamic_observers(
      lapply(input$column_select, function(i) {
        close_btn_id <- paste0(i, "_close")
        observeEvent(
          input[[close_btn_id]],
          {
            updateSelectInput(
              inputId = "column_select",
              selected = Filter(
                \(j) j != i,
                input$column_select
              )
            )
          },
          ignoreInit = TRUE,
        )
      })
    )

    lapply(input$column_select, function(i) {
      fluidRow(
        class = "card",
        column(
          width = 10,
          "Column ", tags$strong(i), " has a mean value of: ",
          round(mean(dataset()[[i]], na.rm = TRUE), 2)
        ),
        column(
          width = 2,
          actionButton(
            inputId = paste0(i, "_close"),
            label = "\u2716",
            class = "btn btn-danger"
          )
        )
      )
    })
  })
}

shinyApp(ui, server)
