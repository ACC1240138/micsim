# renv for this repository. R runs only the .Rprofile of the folder it starts in, so every folder with R code has a
# stub .Rprofile (a copy of _tools/.Rprofile) that runs this file from the root: renv then loads the same way when R
# starts in the root or in any folder with R code, from any tool. Check: _tools/test_renv_activation.R
# - R reads ONE .Renviron at start: the one in the start folder if it exists, else ~/.Renviron. Read both here, user file
#   first and root file (git-ignored machine settings) second, so the result does not depend on where R starts or on
#   whether a root .Renviron exists. R_ENVIRON_USER, when set, replaces ~/.Renviron as R itself does.
# - renv names the project library after a hash of the project path, so the path must be canonical: Positron starts R
#   in "c:/..." instead of "C:/...", and renv would then bootstrap a second, empty library. normalizePath() fixes local
#   paths; sub() also fixes the drive letter of mapped network drives, which normalizePath() leaves as given.
# - Non-interactive R (Rscript, PSOCK workers, Jupyter kernels) skips renv's ~7 s library/lockfile check at load.
local(for (f in c(Sys.getenv("R_ENVIRON_USER", "~/.Renviron"), ".Renviron")) if (nzchar(f) && file.exists(f)) readRenviron(f))
Sys.setenv(RENV_PROJECT = sub("^([a-z]):", "\\U\\1:", normalizePath(getwd(), winslash = "/"), perl = TRUE))
if (!interactive()) options(renv.config.synchronized.check = FALSE)
source("renv/activate.R")
