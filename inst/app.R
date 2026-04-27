# ─────────────────────────────────────────────────────────────────
# ShinyLabel — app.R
# Works regardless of what your R working directory is set to.
# ─────────────────────────────────────────────────────────────────

# ── Resolve the folder containing this app.R ──────────────────────────────
app_dir <- tryCatch(
  normalizePath(dirname(sys.frame(1)$ofile), mustWork = FALSE),
  error = function(e) NULL
)
if (is.null(app_dir) || !nzchar(app_dir)) {
  app_dir <- normalizePath(getwd(), mustWork = TRUE)
}

# Safety check — give a clear message if something is wrong
if (!dir.exists(file.path(app_dir, "www"))) {
  stop(
    "\nCannot find the www/ folder. Please do ONE of:\n\n",
    "  Option A (recommended):\n",
    "    setwd('path/to/shinylabel')\n",
    "    shiny::runApp('app.R')\n\n",
    "  Option B:\n",
    "    shiny::runApp('path/to/shinylabel/app.R')\n"
  )
}

cat("[ShinyLabel] Running from:", app_dir, "\n")

# ── Source all R modules ───────────────────────────────────────────────────
r_files <- list.files(file.path(app_dir, "R"), pattern = "\\.R$", full.names = TRUE)
for (f in r_files) source(f, local = FALSE)

# ── Register static assets with absolute paths ────────────────────────────
shiny::addResourcePath("css", file.path(app_dir, "www", "css"))
shiny::addResourcePath("js",  file.path(app_dir, "www", "js"))
shiny::addResourcePath("img", file.path(app_dir, "www", "img"))
# exports/ folder — created on first export, served for direct file download
exports_dir <- file.path(app_dir, "www", "exports")
dir.create(exports_dir, showWarnings = FALSE, recursive = TRUE)
shiny::addResourcePath("exports", exports_dir)

# ── Database (lives next to app.R, easy to find and back up) ──────────────
DB_PATH <- file.path(app_dir, "shinylabel.db")
# Team use — point everyone to the same file on a shared drive:
# DB_PATH <- "//yourserver/shared/project/annotations.db"

# ── Launch ─────────────────────────────────────────────────────────────────
shiny::shinyApp(
  ui     = sl_ui(),
  server = sl_server(db_path = DB_PATH)
)
