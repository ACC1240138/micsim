# renv for this repository. R runs only the .Rprofile of the folder it starts in, so every folder with R code has a
# stub .Rprofile (a copy of _tools/.Rprofile) that runs this file from the root: renv then loads the same way when R
# starts in the root or in any folder with R code, from any tool. Check: _tools/test_renv_activation.R
# - R reads a root .Renviron (git-ignored machine settings) only when it starts in the root: read it for stub starts too.
# - renv names the project library after a hash of the project path, so the path must be canonical: Positron starts R
#   in "c:/..." instead of "C:/...", and renv would then bootstrap a second, empty library. normalizePath() fixes local
#   paths; sub() also fixes the drive letter of mapped network drives, which normalizePath() leaves as given.
# - Non-interactive R (Rscript, PSOCK workers, Jupyter kernels) skips renv's ~7 s library/lockfile check at load.
if (file.exists(".Renviron")) readRenviron(".Renviron")
Sys.setenv(RENV_PROJECT = sub("^([a-z]):", "\\U\\1:", normalizePath(getwd(), winslash = "/"), perl = TRUE))
if (!interactive()) options(renv.config.synchronized.check = FALSE)
source("renv/activate.R")
