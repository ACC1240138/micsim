.t0 <- Sys.time()
source(file.path("_tools", "acc_data.R"))
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 3L || !args[1] %in% c("pack", "decrypt")) stop("Expected: pack|decrypt input output")
key <- acc_key() # Require the secret on every invocation, including repeated recovery.
if (args[1] == "pack") {
  acc_pack(args[2], args[3], key = key)
} else {
  archive <- acc_decrypt_archive(args[2], key = key)
  tryCatch({
    if (!file.copy(archive, args[3], overwrite = FALSE)) stop("Cannot write temporary archive")
  }, finally = unlink(archive))
}
message(sprintf("Session crypto: %.2f min", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
