# Summaries of the B2 precision sensitivity (unweighted mean over 7 survey years x 4 age groups).
.t0 <- base::Sys.time()
ctrl <- if (base::length(base::commandArgs(TRUE)) >= 1L) base::commandArgs(TRUE)[[1L]] else ".."
r <- utils::read.csv("b2_sens_pif_cells.csv")
who <- base::readRDS(base::file.path(ctrl, "pif2_pif_results_full_20261008.rds"))
who <- who[who$output_name == "ihd_male", c("year", "age_group", "scenario_id", "pif")]
sc_keep <- c("volume_reduction_10","volume_reduction_20","volume_reduction_30","hed_reduction_10","hed_reduction_25","hed_reduction_50",
             "hed_reduction_50_rt","combined_v10_h25","combined_v20_h50","combined_v30_h50","combined_v30_h50_rt")
s <- stats::aggregate(pif ~ b2 + scenario_id, r, function(v) c(mean = base::mean(v), min = base::min(v), max = base::max(v), n_neg = base::sum(v < 0)))
s <- base::do.call(base::data.frame, s)
wide <- stats::reshape(s[s$scenario_id %in% sc_keep, c("scenario_id", "b2", "pif.mean")], idvar = "scenario_id", timevar = "b2", direction = "wide")
wm <- stats::aggregate(pif ~ scenario_id, who, base::mean); names(wm)[2] <- "who_mean"
wide <- base::merge(wide, wm, by = "scenario_id"); wide <- wide[base::match(sc_keep, wide$scenario_id), ]
num <- base::sapply(wide, base::is.numeric); wide[num] <- base::round(wide[num], 4)
base::print(wide, row.names = FALSE)
pub <- r[r$b2 == 1e-6, ]; lo <- r[r$b2 == 0.5e-6, ]; hi <- r[r$b2 == 1.5e-6, ]
k <- c("year","age_group","scenario_id")
m <- base::merge(base::merge(pub, lo, by = k, suffixes = c("_pub","_lo")), hi[, c(k, "pif")], by = k)
m <- m[m$scenario_id != "baseline", ]
base::cat("\nCells (non-baseline):", base::nrow(m), "\n")
base::cat("Negative PIF cells by B2:\n"); base::print(base::tapply(r$pif[r$scenario_id != "baseline"] < 0, r$b2[r$scenario_id != "baseline"], base::sum))
base::cat("Ratio hi/lo of PIF (cells, non-baseline): median", base::round(stats::median(m$pif / m$pif_lo), 2), "range", base::round(base::range(m$pif / m$pif_lo), 2), "\n")
base::cat("Ratio pub/lo median", base::round(stats::median(m$pif_pub / m$pif_lo), 2), "; hi/pub median", base::round(stats::median(m$pif / m$pif_pub), 2), "\n")
# ranking of scenarios preserved?
rk <- base::sapply(base::split(s[s$scenario_id %in% sc_keep, ], s$b2[s$scenario_id %in% sc_keep]), function(d) base::paste(d$scenario_id[base::order(-d$pif.mean)], collapse = ">"))
base::cat("Scenario ranking identical across B2 (rounding range only):", base::length(base::unique(rk[base::names(rk) != "2e-06"])) == 1L, "\n")
# 2024 by age, volume -30% and HED -50%
for (scn in c("volume_reduction_10","volume_reduction_30","hed_reduction_50")) {
  t <- stats::reshape(r[r$year == 2024 & r$scenario_id == scn, c("age_group","b2","pif")], idvar = "age_group", timevar = "b2", direction = "wide")
  base::cat("\n2024", scn, "\n"); base::print(base::round(t, 4), row.names = FALSE)
}
base::message(base::sprintf("summarise_b2 elapsed minutes: %.2f", base::as.numeric(base::difftime(base::Sys.time(), .t0, units = "mins"))))
