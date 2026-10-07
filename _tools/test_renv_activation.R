# _tools/test_renv_activation.R -- renv must load this project the same way whatever folder with R code R starts in.
# Run from the repo root: Rscript --vanilla _tools/test_renv_activation.R  -> prints "renv activation: PASS" or stops.
# 1. Every folder with tracked R code (.R, .Rmd, .qmd, .ipynb) has the .Rprofile stub, identical to _tools/.Rprofile.
# 2. R started in the root or in any of those folders (on Windows also with a lower-case drive letter, as Positron
#    starts it) gets RENV_PROJECT = canonical root from the .Rprofile chain (renv's autoloader off).
# 3. With the autoloader on, every one of those starts loads the root project, and renv itself, from the same library.
#    renv loaded from another library means activate.R hashed a non-canonical path and bootstrapped a second library.
.t0 <- Sys.time()
if (!exists("acc_root")) source(file.path("_tools", "acc_data.R"))
root <- acc_root()
if (nzchar(Sys.getenv("R_PROFILE_USER"))) stop("R_PROFILE_USER is set, so R ignores every project .Rprofile: unset it")

files <- system2("git", c("-C", shQuote(root), "-c", "core.quotepath=off", "ls-files"), stdout = TRUE)
dirs <- setdiff(unique(dirname(grep("\\.(R|r|Rmd|qmd|ipynb)$", files, value = TRUE))), ".")
dirs <- sort(dirs[!grepl("^renv(/|$)", dirs)])  # renv/activate.R is renv's own bootstrap
if (!length(dirs)) stop("git ls-files found no folder with R code under ", root)
ref <- readLines(file.path(root, "_tools", ".Rprofile"))
missing <- dirs[!file.exists(file.path(root, dirs, ".Rprofile"))]
if (length(missing)) stop("No .Rprofile stub (copy _tools/.Rprofile) in: ", paste(missing, collapse = ", "))
differ <- dirs[!vapply(dirs, function(d) identical(readLines(file.path(root, d, ".Rprofile")), ref), logical(1))]
if (length(differ)) stop(".Rprofile differs from _tools/.Rprofile in: ", paste(differ, collapse = ", "))

# Children start clean: nothing inherited from this session tells them where the project or its library is.
Sys.unsetenv(c("RENV_PROJECT", "R_LIBS", "R_LIBS_USER", "R_LIBS_SITE"))
# On Linux/macOS, Rscript --vanilla exports these as "" (R shell script); "" would make the children skip every startup file.
for (v in c("R_PROFILE_USER", "R_PROFILE", "R_ENVIRON_USER", "R_ENVIRON")) if (identical(Sys.getenv(v, NA), "")) Sys.unsetenv(v)
Sys.setenv(RENV_CONFIG_USER_PROFILE = "FALSE")
probe <- tempfile(fileext = ".R")
writeLines(c(
  'lib <- function(p) normalizePath(p, winslash = "/", mustWork = FALSE)',
  'cat("\\nPROBE", Sys.getenv("RENV_PROJECT"), if (isNamespaceLoaded("renv")) c(renv::project(), lib(.libPaths()[1]),',
  '  lib(renv::paths$library()), lib(dirname(getNamespaceInfo("renv", "path")))) else rep("", 4), "\\n", sep = "|")'
), probe)
rscript <- file.path(R.home("bin"), "Rscript")
probe_from <- function(start, autoload) {
  Sys.setenv(RENV_CONFIG_AUTOLOADER_ENABLED = autoload)
  old <- setwd(start)
  on.exit(setwd(old))
  for (attempt in 1:3) {  # 2 retries: R itself sometimes crashes at start-up on Windows (status 5 = 0xC0000005, Sophos)
    out <- suppressWarnings(system2(rscript, shQuote(probe), stdout = TRUE, stderr = TRUE))
    hit <- grep("^PROBE[|]", out, value = TRUE)
    if (length(hit) == 1L) break
  }
  if (length(hit) != 1L) stop("No probe output from R started in ", start, " (3 attempts, last exit status ",
                              attr(out, "status"), "):\n", paste(out, collapse = "\n"))
  p <- strsplit(hit, "|", fixed = TRUE)[[1]]
  stats::setNames(c(p[-1], rep("", 5))[1:5], c("env", "project", "libpath", "library", "renvlib"))
}

starts <- normalizePath(file.path(root, c(".", dirs)), winslash = "/")
if (.Platform$OS.type == "windows") starts <- unique(c(starts, sub("^([A-Z]):", "\\L\\1:", starts, perl = TRUE)))
for (s in starts) {
  p <- probe_from(s, "FALSE")
  if (!identical(p[["env"]], root)) stop("R started in ", s, " set RENV_PROJECT to '", p[["env"]], "', not ", root,
                                         " (R_PROFILE_USER set, e.g. in ~/.Renviron? R then skips the project .Rprofile)")
}
libs <- vapply(starts, function(s) {
  p <- probe_from(s, "TRUE")
  if (!identical(p[["project"]], root)) stop("R started in ", s, " loaded renv project '", p[["project"]], "', not ", root)
  if (!identical(p[["libpath"]], p[["library"]])) stop("R started in ", s, " has .libPaths()[1] = ", p[["libpath"]],
                                                     ", not the renv library ", p[["library"]])
  if (!identical(p[["renvlib"]], p[["library"]])) stop("R started in ", s, " loaded renv itself from ", p[["renvlib"]],
                                                     ", not from the project library ", p[["library"]])
  p[["library"]]
}, character(1))
if (length(unique(libs)) != 1L) stop("Different renv libraries by start folder:\n", paste(starts, libs, sep = " -> ", collapse = "\n"))
message(sprintf("renv activation: PASS (root + %d folders, %d starts, library %s) | %.2f min", length(dirs), length(starts),
                libs[[1]], as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
