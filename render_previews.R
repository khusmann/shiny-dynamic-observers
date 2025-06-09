library(shiny)
library(webshot2)
library(processx)
library(httr)
library(purrr)

screenshot_shiny_app <- function(
    app_path,
    output_file,
    width = 576,
    height = 450,
    port = 1234,
    wait_time = 30) {
  url <- sprintf("http://127.0.0.1:%d", port)

  message("Launching app: ", app_path)

  shiny_proc <- process$new(
    "Rscript",
    c("-e", sprintf("shiny::runApp('%s', port=%d, launch.browser=FALSE)", app_path, port)),
    stdout = "|", stderr = "|"
  )

  # Wait for the app to start
  for (i in seq_len(wait_time)) {
    Sys.sleep(1)
    result <- tryCatch(GET(url), error = function(e) NULL)
    if (!is.null(result) && status_code(result) == 200) {
      message("App started at attempt ", i)
      break
    }
    if (i == wait_time) {
      shiny_proc$kill()
      stop("App did not start in time: ", app_path)
    }
  }

  # Take screenshot
  webshot(url, file = output_file, vwidth = width, vheight = height)

  # Kill the app
  shiny_proc$kill()
  message("Saved preview to: ", output_file)
}

# -- Run for all apps in src/solution/ that don't start with "_" --

app_dir <- "src"
out_dir <- "build"


# Get subdirectories not starting with "_"
shiny_apps <- list.dirs(app_dir, recursive = FALSE, full.names = TRUE) |>
  keep(\(x) !startsWith(basename(x), "_"))

# Launch and screenshot each app
iwalk(shiny_apps, function(app_path, i) {
  port <- 1234 + i
  app_name <- basename(app_path)
  out_file_dir <- file.path(out_dir, app_name)
  out_file <- file.path(out_file_dir, "preview.png")

  if (!dir.exists(out_file_dir)) dir.create(out_file_dir, recursive = TRUE)
  
  screenshot_shiny_app(
    app_path,
    out_file,
    port = port,
    width = 576,
    height = 450
  )
})
