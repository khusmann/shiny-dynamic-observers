src_dir <- "src"
out_dir <- "build"

if (!dir.exists(out_dir)) {
  dir.create(out_dir)
}

apps <- list.dirs(src_dir, full.names = FALSE, recursive = FALSE)

for (app in apps) {
  input_path <- file.path(src_dir, app)
  
  message("Exporting ", app, "...")
  shinylive::export(
    appdir = input_path,
    destdir = out_dir,
    subdir = app,
    quiet = TRUE
  )
}

cat('View the site with httpuv::runStaticServer("build")')