# Stub, identical in every folder with R code: R runs only the .Rprofile of the folder it starts in, so find the
# repository root (marked by .acc_root) and run the root .Rprofile from there, which activates renv.
local({
  d <- normalizePath(getwd(), winslash = "/")
  while (!file.exists(file.path(d, ".acc_root")) && dirname(d) != d) d <- dirname(d)
  if (file.exists(file.path(d, ".acc_root"))) source(file.path(d, ".Rprofile"), chdir = TRUE)
})
