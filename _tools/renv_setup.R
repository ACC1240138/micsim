# _tools/renv_setup.R -- builds the reproducible R library of the project (renv + a dated Posit Package Manager snapshot).
# Run ONCE from the repo root, only when the package set has to be rebuilt:  Rscript _tools/renv_setup.R
# Everyone else just runs renv::restore() (see README.md): the lockfile pins exact versions and the repository date.
#
# What it produces (committed): renv.lock, renv/activate.R, renv/settings.json, .Rprofile.  Not committed: renv/library/.
# Why `fecha`: CRAN changes daily; a PPM snapshot URL freezes it. 2026-04-23 is the day after the newest package version in the
#   dependency closure of this project (ggplot2 4.0.3 and curl 7.1.0, both published 2026-04-22).
# Why DESCRIPTION: snapshot.type = "implicit" records what the code uses plus DESCRIPTION; several packages are loaded by name
#   (required_packages vectors), which a code scan cannot see, so they are listed in Imports.
.t0 <- Sys.time()
stopifnot(file.exists(".acc_root"))          # run from the project root
fecha <- "2026-04-23"
paquetes <- c(
  "arrow", "data.table", "digest", "dplyr", "DT", "devtools", "fitdistrplus", "forcats", "ggplot2", "gridExtra", "gtools", "haven",
  "here", "htmltools", "IRdisplay", "IRkernel", "janitor", "jsonlite", "knitr", "MASS", "MicSim", "mvtnorm", "nanoparquet", "openssl", "patchwork",
  "purrr", "quarto", "readr", "readxl", "rio", "rvest", "sandwich", "scales", "stringr", "survey", "tibble", "tidyr", "tidyselect",
  "withr", "writexl", "xml2", "zip"
)
options(
  repos = c(CRAN = paste0("https://packagemanager.posit.co/cran/", fecha)),  # PPM snapshot of that date
  renv.consent = TRUE                                                         # renv does not ask for permission the first time
)
if (!requireNamespace("renv", quietly = TRUE)) install.packages("renv")
renv::init(
  bare = TRUE,                                  # do not look for or install packages yet
  settings = list(snapshot.type = "implicit"),  # renv.lock = what the scripts use + DESCRIPTION
  restart = FALSE                               # do not restart R
)
renv::install(
  packages = paquetes,
  prompt = FALSE
)
renv::snapshot(prompt = FALSE)                  # write exact versions into renv.lock
renv::isolate()                                 # copy the packages into the project (self-contained library)
message(sprintf("renv_setup: %d packages requested | %.2f min", length(paquetes), as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
