# _tools/check_bundles.R -- decrypt every bundle and compare md5 with its sidecar. Used locally and by CI.
# Run from the repo root: Rscript _tools/check_bundles.R
.t0 <- Sys.time()
if (!exists("acc_root")) source(file.path("_tools", "acc_data.R"))
root <- acc_root()
sidecars <- list.files(root, "\\.tar\\.xz\\.enc\\.md5\\.csv$", recursive = TRUE, full.names = TRUE)
if (!length(sidecars)) stop("No bundles found under ", root)
bad <- 0L
for (s in sidecars) {
  enc <- sub("\\.md5\\.csv$", "", s)
  ex <- tempfile("chk_")
  m <- utils::read.csv(s, stringsAsFactors = FALSE, encoding = "UTF-8")
  ok <- tryCatch({
    acc_unpack(enc, ex)
    identical(unname(tools::md5sum(file.path(ex, m$file))), m$md5)
  }, error = function(e) FALSE)
  if (!ok) bad <- bad + 1L
  message(sprintf("[%s] %s (%d files)", if (ok) "OK" else "FAIL", substring(enc, nchar(root) + 2L), nrow(m)))
  unlink(ex, recursive = TRUE)
}
message(sprintf("%d bundle(s) checked in %.1f min", length(sidecars), as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
if (bad) stop(bad, " bundle(s) failed")
