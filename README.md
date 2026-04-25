# ShinyLabel 🏷️

**A fully R-native image annotation tool for YOLO object detection.**  
Built as an alternative to LabelImg — no Python, no external tools, runs entirely in R + Shiny.

---

## Features

| Feature | Details |
|---|---|
| **Draw** | Click-drag bounding boxes on any image |
| **Edit** | Select, move, resize (8 handles), delete boxes |
| **Undo** | Full undo stack (Ctrl+Z) |
| **Classes** | Dynamic class management with color coding |
| **Load** | Upload files, point to local folder, or load from URL |
| **Team** | Multi-annotator with username tracking |
| **Auto-save** | Annotations saved automatically on image navigation |
| **Storage** | SQLite (WAL mode) — serverless, concurrent, zero install |
| **Export** | YOLO Ultralytics `.txt` + `data.yaml` + COCO JSON |
| **Dashboard** | Progress stats, boxes per class, annotator breakdown |

---

## Quick Start

### Option 1: Run directly (no install needed)
```r
# Install dependencies first
install.packages(c(
  "shiny", "bslib", "DBI", "RSQLite", "magick",
  "shinyFiles", "shinyjs", "jsonlite", "ggplot2",
  "DT", "dplyr", "lubridate", "zip", "yaml",
  "scales", "colourpicker", "base64enc", "fs"
))

# Run from the shinylabel/ directory
shiny::runApp("app.R")
```

### Option 2: Install as package
```r
# From the parent directory of shinylabel/
devtools::install("shinylabel")
library(shinylabel)
run_shinylabel()
```

### Team Setup (shared network drive)
```r
# All annotators point to the same .db file
run_shinylabel(
  db_path = "//yourserver/shared/project/annotations.db",
  host    = "0.0.0.0",   # expose on LAN
  port    = 3838
)
```

---

## How It Works

### Canvas Engine
The annotation canvas is built with plain **HTML5 Canvas + vanilla JavaScript**
(no external JS frameworks). Boxes are drawn with mouse events:

- `mousedown` → start draw or select/drag
- `mousemove` → draw ghost box or move/resize
- `mouseup`   → finalize

Coordinates are tracked in **image pixel space** (not canvas display space),
so zoom/scaling never affects annotation accuracy.

### Coordinate Flow
```
User draws on canvas
  ↓
JS canvas.js tracks pixel coords (image space)
  ↓
Shiny.setInputValue("canvas_boxes", payload)
  ↓
R server receives pixel coords
  ↓
px_to_yolo_norm() converts to YOLO normalized (0-1)
  ↓
SQLite stores both (pixel + normalized)
  ↓
Export writes YOLO .txt files
```

### YOLO Format Output
```
# labels/train/image001.txt
# class_id  x_center  y_center  width  height  (all normalized 0-1)
0 0.523438 0.412500 0.178125 0.250000
1 0.234375 0.687500 0.093750 0.125000
```

```yaml
# data.yaml
path: ./yolo_dataset
train: images/train
val:   images/val
nc: 4
names: [person, car, animal, object]
```

---

## Database Schema

```sql
images       — filepath, dimensions, status, who added
classes      — class_id, name, color
annotations  — bounding boxes (pixel + normalized), annotator, timestamp
sessions     — login log per annotator
```

---

## Keyboard Shortcuts

| Key | Action |
|---|---|
| Drag | Draw new box |
| Click box | Select |
| Delete / Backspace | Delete selected box |
| Ctrl+Z | Undo |
| Escape | Deselect |
| Arrow Left/Right | Previous/Next image |

---

## Architecture (Package Structure)

```
shinylabel/
├── app.R                  # Run without install
├── DESCRIPTION
├── R/
│   ├── db.R               # SQLite init, CRUD operations
│   ├── export.R           # YOLO + COCO export
│   ├── image_utils.R      # Image reading, b64 encoding, URL fetch
│   ├── ui.R               # Shiny UI definition
│   ├── server.R           # Shiny server logic
│   └── run.R              # run_shinylabel() entry point
└── www/
    ├── css/style.css      # Dark industrial UI theme
    └── js/
        ├── canvas.js          # HTML5 Canvas annotation engine
        └── shiny_handlers.js  # R↔JS message bridge
```

---

## Road to YOLOR Package Integration

This package is designed to be the annotation front-end for a future `yolor` R package.
The export format matches Ultralytics YOLO exactly. The planned integration:

```r
# Future API
library(yolor)
library(shinylabel)

# Step 1: Annotate
run_shinylabel(db_path = "project.db")

# Step 2: Export
sl_export_yolo("project.db", output_dir = "dataset/")

# Step 3: Train (future yolor package)
model <- yolor_train(data = "dataset/data.yaml", epochs = 100)
```

---

## License

MIT
