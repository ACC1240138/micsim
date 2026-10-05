# _deis/build_deis_2012_2023.R -- rebuild DEFUNCIONES_DEIS_2012_2023_15plus.parquet and pack it encrypted.
# Run from the repo root: Rscript _deis/build_deis_2012_2023.R
#
# Source (not in the repo; DEIS open data, Latin-1, ';', 27 columns):
#   DEFUNCIONES_FUENTE_DEIS_1990_2023_CIFRAS_OFICIALES.csv, 829 MB, md5 54295f6503c93cf5e8025a4e20a391b0
#   Set ACC_DEIS_1990_2023=<path to that CSV> (e.g. in ~/.Renviron or Sys.setenv()).
# Recipe: years 2012-2023; EDAD_TIPO == 1 (age in completed years); EDAD_CANT >= 15.
#   Columns: year, gender, age, age_group (1 = 15-29, 2 = 30-44, 3 = 45-59, 4 = 60+), comuna, region, diag1, diag2.
# Fix vs. the previous file DEFUNCIONES_DEIS_12_23_15plus.parquet (md5 edb4f60848fb891aadf2c7d113f52aeb,
#   1,330,807 rows = same recipe without EDAD_TIPO == 1): 1,826 infant deaths aged in days (1,384),
#   hours (440) or unknown unit (2) entered as people aged 15+; 1,824 fell in ages 15-65 and 1,799 in 15-29.
.t0 <- Sys.time()
if (!exists("acc_root")) source(file.path("_tools", "acc_data.R"))
src <- Sys.getenv("ACC_DEIS_1990_2023")
if (!file.exists(src)) stop("Set ACC_DEIS_1990_2023 to the official DEIS 1990-2023 CSV.")
d <- data.table::fread(src, sep = ";", encoding = "Latin-1", data.table = FALSE, showProgress = FALSE,
                       select = c(1L, 3L, 4L, 5L, 7L, 8L, 9L, 18L), colClasses = "character")
names(d) <- c("year", "gender", "edad_tipo", "age", "comuna", "region", "diag1", "diag2")
d$year <- as.integer(d$year)
d$age <- suppressWarnings(as.integer(d$age))
d <- d[d$year %in% 2012:2023 & d$edad_tipo %in% "1" & !is.na(d$age) & d$age >= 15L, ]
d$age_group <- as.numeric(findInterval(d$age, c(15, 30, 45, 60)))
d$diag2[d$diag2 == ""] <- NA
for (v in c("gender", "comuna", "region", "diag1", "diag2")) d[[v]] <- enc2utf8(d[[v]])
d <- d[, c("year", "gender", "age", "age_group", "comuna", "region", "diag1", "diag2")]
rownames(d) <- NULL
expected <- c(96209L, 97391L, 99476L, 101000L, 101787L, 104288L, 104752L, 107672L, 124569L, 136060L, 135274L, 120503L)
stopifnot(identical(as.integer(names(table(d$year))), 2012:2023), all(as.integer(table(d$year)) == expected),
          sum(d$age <= 65) == 368030L, sum(d$age <= 29) == 30953L)
pq <- file.path(tempdir(), "DEFUNCIONES_DEIS_2012_2023_15plus.parquet")
nanoparquet::write_parquet(d, pq, compression = "zstd")
acc_pack(pq, file.path(acc_root(), "_deis", "DEFUNCIONES_DEIS_2012_2023_15plus.tar.xz.enc"))
unlink(pq)
message(sprintf("DEIS 2012-2023: %d rows packed | %.2f min", nrow(d), as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
