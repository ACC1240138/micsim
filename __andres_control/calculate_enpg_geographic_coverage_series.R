.t0 <- Sys.time()
# Same-year, ages 15-64 geographic coverage using observed communes, not official frame lists.
source(here::here("_tools", "acc_data.R"))
out_dir <- file.path(acc_root(), "__andres_control")
ine_path <- list.files(out_dir, "EEPP comuna area", full.names = TRUE)
stopifnot(length(ine_path) == 1L)
ine <- utils::read.csv2(ine_path, check.names = FALSE, fileEncoding = "UTF-8-BOM")
names(ine)[c(5, 7, 8, 9)] <- c("comuna", "sex", "area", "age")
ages <- sprintf("De %d a %d años", seq(15, 60, 5), seq(19, 64, 5))
g <- ine[ine$age %in% ages, ]
stopifnot(nrow(g) == 346L * 2L * 2L * 10L,
          !anyDuplicated(g[c("comuna", "sex", "area", "age")]))
cache <- acc_data("_enpg/enpg.tar.xz.enc", "derived/enpg_design_waves_2012_2024_list.RDS")
waves <- readRDS(cache)$waves
old <- utils::read.csv(file.path(out_dir, "enpg_rural_coverage.csv"))
results <- audit <- list()
for (year in old$year) {
  ids <- unique(as.integer(waves[[as.character(year)]]$commune))
  ids[ids == 8401L] <- 16101L # Match historical Chillan to INE's current commune code.
  stopifnot(!anyNA(ids), all(ids %in% g$comuna))
  inside <- g$comuna %in% ids
  pop <- g[[paste("Poblacion", year)]]
  stopifnot(!anyNA(pop), all(pop >= 0))
  A <- sum(pop[!inside])
  B <- sum(pop[inside & g$area == 2])
  C <- sum(pop[inside & g$area == 1])
  total <- sum(pop)
  excluded <- 100 * (A + B) / total
  complement <- 100 * (1 - C / total)
  historical <- old[old$year == year, ]
  stopifnot(A + B + C == total, abs(excluded - complement) < 1e-12,
    length(ids) == historical$comunas_enpg,
    abs(100 * (B + C) / total - historical$pct_pop_in_enpg_comunas) < 1e-10,
    abs(100 * B / sum(pop[g$area == 2]) - historical$pct_rural_pop_in_enpg_comunas) < 1e-10)
  results[[as.character(year)]] <- data.frame(year, age = "15-64", communes = length(ids),
    population_total = total, population_covered = C, component_A = A, component_B = B,
    excluded_pct = excluded, complement_pct = complement)
  audit[[as.character(year)]] <- data.frame(year, comuna = sort(ids))
}
results <- do.call(rbind, results)
ref <- utils::read.csv(file.path(out_dir, "enpg_geographic_coverage_2024.csv"))
stopifnot(results$population_covered[results$year == 2024] ==
            ref$population_covered[ref$scenario == "observed_2024"])
utils::write.csv(results, file.path(out_dir, "enpg_geographic_coverage_2012_2024.csv"), row.names = FALSE)
utils::write.csv(do.call(rbind, audit), file.path(out_dir, "enpg_geographic_coverage_2012_2024_communes.csv"), row.names = FALSE)
utils::write.csv(data.frame(source = c(basename(ine_path), "derived/enpg_design_waves_2012_2024_list.RDS"),
  md5 = unname(tools::md5sum(c(ine_path, cache)))),
  file.path(out_dir, "enpg_geographic_coverage_2012_2024_sources.csv"), row.names = FALSE)
print(results, row.names = FALSE)
cat(sprintf("Elapsed: %.2f min\n", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
