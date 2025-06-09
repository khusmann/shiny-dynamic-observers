library(shiny)
library(webshot2)
library(processx)
library(httr)

# Path to your app (can be ".")
app_dir <- "src/solution"
out_dir <- "build"
port <- 1234
url <- sprintf("http://127.0.0.1:%d", port)

if (!dir.exists(out_dir)) {
  dir.create(out_dir)
}

# Start the app in background
shiny_proc <- process$new(
  "Rscript",
  c("-e", sprintf("shiny::runApp('%s', port=%d, launch.browser=FALSE)", app_dir, port)),
  stdout = "|", stderr = "|"
)

# Wait for the app to start (check up to 20 times)
for (i in 1:20) {
  print(paste0("Attempt ", i))
  Sys.sleep(1)
  result <- tryCatch(GET(url), error = function(e) NULL)
  if (!is.null(result) && status_code(result) == 200) {
    break
  }
  if (i == 20) stop("App did not start in time")
}

# Take screenshot
webshot(url, file = "build/preview.png", vwidth = 576, vheight = 450)

# Kill the app
shiny_proc$kill()