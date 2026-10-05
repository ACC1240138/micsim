# _tools/smoke_data.R -- quick content checks on decrypted data (run from the repo root, needs ACC_DATA_KEY).
# Rscript _tools/smoke_data.R  -> "smoke_data: PASS" or stops at the first failed check.
.t0 <- Sys.time()
if (!exists("acc_root")) source(file.path("_tools", "acc_data.R"))
d <- nanoparquet::read_parquet(acc_data("_deis/DEFUNCIONES_DEIS_2012_2023_15plus.tar.xz.enc"))
stopifnot(identical(names(d), c("year", "gender", "age", "age_group", "comuna", "region", "diag1", "diag2")),
          nrow(d) == 1328981L, sum(d$age <= 65) == 368030L, sum(d$age <= 29) == 30953L)
w <- acc_deis()
w24 <- w[w[[1]] == 2024, ]
# 2024 was identical in the 09-06, 15-09 and 29-09 releases; a change here means DEIS revised 2024.
stopifnot(nrow(w24) == 126928L,
          sum(w24$EDAD_TIPO == 1 & w24$EDAD_CANT >= 15 & w24$EDAD_CANT <= 65, na.rm = TRUE) == 31806L)
b <- readRDS(acc_data("_enpg/enpg.tar.xz.enc", "derived/ENPG_BINGE.RDS"))
message(sprintf("ENPG_BINGE: %d rows x %d columns", nrow(b), ncol(b)))
message(sprintf("smoke_data: PASS (%.2f min)", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
