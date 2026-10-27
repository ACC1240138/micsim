.t0 <- Sys.time()
# Retain every variable required by eca_casen_read; original ZIPs remain external.
source(here::here("_tools", "acc_data.R"))
source(here::here("__andres_control", "enpg_casen_aps.R"))
stopifnot(nzchar(Sys.getenv("ACC_DATA_KEY")))
for (year in c(2017L, 2024L)) {
  zip <- if (year == 2017L) "_casen/casen_2017_dta.zip.tar.xz.enc" else
    "_casen/casen_2024stata.zip.tar.xz.enc"
  z <- acc_data(zip)
  expected <- c(`2017` = "e3a753aafc68a7f4101ef811aa5d9c37",
    `2024` = "e173d2f5aa0bffef8d9bdf5259cea128")
  stopifnot(identical(unname(tools::md5sum(z)), unname(expected[as.character(year)])))
  inside <- utils::unzip(z, list = TRUE)$Name
  inside <- inside[grepl("[.]dta$", inside, ignore.case = TRUE)]
  stopifnot(length(inside) == 1, !grepl("(^/|[.][.])", inside))
  dest <- file.path(tempdir(), sprintf("reduce_casen_%d", year))
  utils::unzip(z, files = inside, exdir = dest)
  f <- file.path(dest, inside)
  original <- list()
  for (health in c(FALSE, TRUE)) for (rural in c(FALSE, TRUE)) {
    vars <- c("edad", "sexo", "e6a", "e6b", "expr", "varstrat", "varunit", "educc",
      if (year >= 2022) "e6c_completo", if (rural) "area", if (health)
        c("region", "folio", if (year == 2017) "o" else "id_persona",
          if (year == 2017) c("s19a", "s19b", "s26a", "s26c") else c("s20a_preg", "s20b", "s26a", "s26c")))
    d <- haven::read_dta(f, col_select = dplyr::all_of(vars))
    if (rural) names(d)[names(d) == "area"] <- "zona"
    original[[paste(health, rural)]] <- d
  }
  d <- original[["TRUE TRUE"]]
  names(d)[names(d) == "zona"] <- "area"
  plain <- file.path(tempdir(), sprintf("casen_%d_eca.rds", year))
  saveRDS(d, plain, compress = FALSE)
  out <- here::here("_casen", sprintf("casen_%d_eca.rds.tar.xz.enc", year))
  if (!file.exists(out)) acc_pack(plain, out)
  restored <- readRDS(acc_data(file.path("_casen", basename(out))))
  stopifnot(identical(d, restored), file.size(out) < 50 * 1024^2)
  for (health in c(FALSE, TRUE)) for (rural in c(FALSE, TRUE)) {
    vars <- names(original[[paste(health, rural)]])
    vars[vars == "zona"] <- "area"
    check <- restored[, vars]
    if (rural) names(check)[names(check) == "area"] <- "zona"
    if (!identical(check, original[[paste(health, rural)]])) {
      stop(paste(c(year, health, rural, all.equal(check, original[[paste(health, rural)]])), collapse = ": "))
    }
    stopifnot(identical(eca_casen_read(year, health, rural), original[[paste(health, rural)]]))
  }
  cat(sprintf("PASS %d: %d rows, %d columns, four exact comparisons, %.2f MiB\n",
    year, nrow(d), ncol(d), file.size(out) / 1024^2))
  unlink(plain)
}
message(sprintf("Elapsed: %.2f min", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
