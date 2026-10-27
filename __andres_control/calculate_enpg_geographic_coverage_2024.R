.t0 <- Sys.time()
# Geographic approximation only; do not run consumption models.
source(here::here("_tools", "acc_data.R"))
out_dir <- file.path(acc_root(), "__andres_control")
ine_path <- list.files(out_dir, "EEPP comuna area", full.names = TRUE)
stopifnot(length(ine_path) == 1L)
ine <- utils::read.csv2(ine_path, check.names = FALSE, fileEncoding = "UTF-8-BOM")
names(ine)[c(5, 6, 7, 8, 9)] <- c("comuna", "name", "sex", "area", "age")
ages <- sprintf("De %d a %d años", seq(15, 60, 5), seq(19, 64, 5))
stopifnot(all(ages %in% ine$age), !anyDuplicated(ine[c("comuna", "sex", "area", "age")]))
g <- ine[ine$age %in% ages, ]
stopifnot(nrow(g) == 346L * 2L * 2L * 10L, !anyNA(g[["Poblacion 2024"]]),
          all(g[["Poblacion 2024"]] >= 0))
raw_files <- c(`2024` = "Base Publica ENPG 2024 (Stata 16).dta",
               `2022` = "BD - ENPG 2022 (Stata 16).dta")
sets <- list()
source_paths <- ine_path
for (y in names(raw_files)) {
  p <- acc_data("_enpg/enpg.tar.xz.enc", raw_files[[y]])
  d <- haven::read_dta(p, col_select = c("COD_COMUNA", "EDAD", "SEXO", "FACTOR_EXPANSION"))
  stopifnot(!anyNA(d$COD_COMUNA))
  sets[[paste0("observed_", y)]] <- sort(unique(as.integer(d$COD_COMUNA)))
  if (y == "2024") {
    valid <- !is.na(d$EDAD) & d$EDAD >= 15 & d$EDAD <= 65 &
      !is.na(d$SEXO) & d$SEXO %in% c(1, 2) & !is.na(d$FACTOR_EXPANSION) & d$FACTOR_EXPANSION > 0
    sets$observed_2024_filtered_15_65 <- sort(unique(as.integer(d$COD_COMUNA[valid])))
  }
  source_paths <- c(source_paths, p)
}
all_pop <- tapply(ine[["Poblacion 2024"]], ine$comuna, sum)
# This is a hypothetical size-rule scenario, not the documented ENPG frame.
sets$hypothetical_30000_2024 <- as.integer(names(all_pop)[all_pop >= 30000])
communes <- sort(unique(g$comuna))
audit <- data.frame(comuna = communes, name = ine$name[match(communes, ine$comuna)],
                    population_all_ages_2024 = as.numeric(all_pop[as.character(communes)]))
audit$urban_15_64 <- as.numeric(tapply(g[["Poblacion 2024"]] * (g$area == 1), g$comuna, sum)[as.character(communes)])
audit$rural_15_64 <- as.numeric(tapply(g[["Poblacion 2024"]] * (g$area == 2), g$comuna, sum)[as.character(communes)])
results <- list()
for (scenario in names(sets)) {
  ids <- sets[[scenario]]
  stopifnot(all(ids %in% communes))
  inside <- g$comuna %in% ids
  a <- !inside
  b <- inside & g$area == 2
  covered <- inside & g$area == 1
  stopifnot(all(as.integer(a) + as.integer(b) + as.integer(covered) == 1L))
  total <- sum(g[["Poblacion 2024"]])
  A <- sum(g[["Poblacion 2024"]][a])
  B <- sum(g[["Poblacion 2024"]][b])
  C <- sum(g[["Poblacion 2024"]][covered])
  overlap <- sum(g[["Poblacion 2024"]][a & g$area == 2])
  excluded <- 100 * (A + B) / total
  complement <- 100 * (1 - C / total)
  stopifnot(A + B + C == total, abs(excluded - complement) < 1e-12)
  results[[scenario]] <- data.frame(scenario, year = 2024, age = "15-64", communes = length(ids),
    population_total = total, population_covered = C, component_A = A, component_B = B,
    excluded_pct = excluded, complement_pct = complement, A_pct = 100 * A / total,
    B_pct = 100 * B / total, rural_outside_overlap = overlap)
  audit[[scenario]] <- audit$comuna %in% ids
}
results <- do.call(rbind, results)
old <- utils::read.csv(file.path(out_dir, "enpg_rural_coverage.csv"))
r <- results[results$scenario == "observed_2024_filtered_15_65", ]
stopifnot(abs(100 - r$A_pct - old$pct_pop_in_enpg_comunas[old$year == 2024]) < 1e-10)
utils::write.csv(results, file.path(out_dir, "enpg_geographic_coverage_2024.csv"), row.names = FALSE)
utils::write.csv(audit, file.path(out_dir, "enpg_geographic_coverage_2024_communes.csv"), row.names = FALSE)
source_paths <- c(source_paths, file.path(acc_root(), "_enpg/docs/2024/enpg2024.pdf"))
utils::write.csv(data.frame(source = c(basename(ine_path), unname(raw_files), "_enpg/docs/2024/enpg2024.pdf"),
  md5 = unname(tools::md5sum(source_paths))), file.path(out_dir, "enpg_geographic_coverage_2024_sources.csv"), row.names = FALSE)
print(results, row.names = FALSE)
cat(sprintf("Elapsed: %.2f min\n", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
