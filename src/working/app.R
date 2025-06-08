library(shiny)
library(purrr)
library(glue)

source("styles.R")

all_datasets <- ls("package:datasets") |>
  set_names() |>
  map(\(x) get(x, "package:datasets")) |>
  keep(is.data.frame)

ui <- fluidPage(
  tags$head(tags$style(app_styles)),
  div(
    class = "centered-content",
    tags$h3("Dynamic Observer Demo"),
    selectInput(
      inputId = "dataset_select",
      label = "Select a dataset:",
      choices = names(all_datasets),
      width = "100%"
    ),
    uiOutput("column_select_ui"),
    uiOutput("cards_ui", class = "card-container")
  )
)

server <- function(input, output, session) {
  dynamic_observers <- reactiveVal(list())

  dataset <- shiny::reactive({
    all_datasets[[input$dataset_select]]
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
          label = "\u2716",
          class = "btn btn-xs btn-danger"
        )
      )
    })
  })

  observe({
    walk(isolate(dynamic_observers()), \(i) i$destroy())

    dynamic_observers(
      map(input$column_select, function(i) {
        close_btn_id <- paste0(i, "_close")
        observeEvent(
          input[[close_btn_id]],
          {
            updateSelectInput(
              inputId = "column_select",
              selected = discard(input$column_select, \(j) j == i)
            )
          },
          ignoreInit = TRUE,
        )
      })
    )
  })
}

shinyApp(ui, server)
