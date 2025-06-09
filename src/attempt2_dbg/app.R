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
    tags$h3("Attempt #2"),
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
    uiOutput("cards_ui", class = "card-container"),
    tags$div(
      class = "message-container",
      verbatimTextOutput("messages_text")
    )
  )
)

server <- function(input, output, session) {
  messages <- shiny::reactiveVal(list(n = 1, msg = "Messages will log here\n"))

  appendMessage <- function(msg) {
    old_message <- isolate(messages())
    messages(
      list(
        n = old_message$n + 1,
        msg = glue("({old_message$n}) {msg}\n{old_message$msg}")
      )
    )
  }

  output$messages_text <- renderText(messages()$msg)

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
      if (is.numeric(dataset()[[i]])) {
        i_mean <- round(mean(dataset()[[i]], na.rm = TRUE), 2)
        extra <- glue("(mean: {i_mean})")
      } else {
        extra <- NULL
      }
      tags$div(
        class = "card",
        tags$div(tags$strong(i), extra),
        actionButton(
          inputId = glue("{i}_close"),
          label = icon("times"),
          class = "btn btn-xs btn-danger"
        )
      )
    })
  })

  observeEvent(input$column_select, {
    walk(input$column_select, function(i) {
      close_btn_id <- glue("{i}_close")
      observeEvent(
        input[[close_btn_id]],
        {
          appendMessage(glue("Closing {i}"))
          updateSelectInput(
            inputId = "column_select",
            selected = discard(input$column_select, \(j) j == i)
          )
        },
        ignoreInit = TRUE
      )
    })
  })
}

shinyApp(ui, server)
