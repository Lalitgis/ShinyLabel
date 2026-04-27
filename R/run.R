#' Launch ShinyLabel
#'
#' Starts the ShinyLabel annotation tool as a Shiny application.
#'
#' @param db_path   Path to the SQLite database file. Created if it doesn't exist.
#'                  Defaults to "shinylabel.db" in the current working directory.
#'                  For team use, point all annotators to the same file on a
#'                  shared network drive.
#' @param host      Host to run on. Use "0.0.0.0" to expose on LAN for team access.
#' @param port      Port number. NULL = auto-assign.
#' @param launch.browser Whether to open browser automatically.
#'
#' @examples
#' \dontrun{
#'   # Solo use
#'   run_shinylabel()
#'
#'   # Team use (shared network path)
#'   run_shinylabel(
#'     db_path = "//server/shared/project/annotations.db",
#'     host = "0.0.0.0",
#'     port = 3838
#'   )
#' }
#' @export
run_shinylabel <- function(
  db_path        = "shinylabel.db",
  host           = "127.0.0.1",
  port           = NULL,
  launch.browser = TRUE
) {
  # Locate www directory inside installed package
  www_dir <- system.file("www", package = "shinylabel")

  if (!nzchar(www_dir)) {
    stop("Could not find 'www' directory. Please reinstall the package.",
         call. = FALSE)
  }

  # Register static resource paths
  shiny::addResourcePath("css", file.path(www_dir, "css"))
  shiny::addResourcePath("js",  file.path(www_dir, "js"))
  shiny::addResourcePath("img", file.path(www_dir, "img"))

  # Create Shiny app
  app <- shiny::shinyApp(
    ui     = sl_ui(),
    server = sl_server(db_path = db_path)
  )

  # Run app
  shiny::runApp(
    app,
    host           = host,
    port           = port,
    launch.browser = launch.browser
  )
}
