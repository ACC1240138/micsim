# Sensitivity of Table 5 (PUC) IHD-male mortality RR to the published precision of B2.
# Standalone: does NOT edit any notebook. Reuses aaf_unified.R::pif_point() and the
# exposure bundle used by expand_pif2. Only B2 changes; B1, former-drinker RR, cap-mode HED,
# x grid (0.1-150), Fact convention (stored, NOT applied), scenarios and exposures are identical.
# This is a precision sensitivity, not an estimate of B2, its distribution, or a CI.
.t0 <- base::Sys.time()
args <- base::commandArgs(trailingOnly = TRUE)
ctrl <- if (base::length(args) >= 1L) args[[1L]] else "."
out  <- if (base::length(args) >= 2L) args[[2L]] else "."
base::source(base::file.path(ctrl, "aaf_unified.R"))

bundle <- base::readRDS(base::file.path(ctrl, "aaf_engine_inputs_bundle_20261007.rds"))
ex <- bundle$exposure_inputs
ref <- base::readRDS(base::file.path(ctrl, "pif2_pif_results_table5_full_20261008.rds"))
ref <- ref[ref$output_name == "ihd_male", ]
years <- bundle$metadata$survey_years
groups <- 1:4

# Table 5 row "Mortalidad - E. Isquemica del corazon Hombres" (identical to table5_rr_parameters()).
B1 <- -0.046271
rr_fd <- 1.25
rr_ihd_m <- function(x, beta) base::exp(beta[[1L]] * base::sqrt(x) + beta[[2L]] * x^3)

# B2 grid. Conventional rounding to 6 dp => true B2 in [0.5e-6, 1.5e-6).
# Truncation to 6 dp would instead imply [1e-6, 2e-6); 2e-6 is reported as a labelled
# truncation bound only, not as part of the rounding sensitivity.
b2_grid <- tibble::tibble(
  b2 = c(0.5e-6, 0.75e-6, 1.0e-6, 1.25e-6, 1.5e-6, 2.0e-6),
  b2_label = c("0.50e-6 (round low)", "0.75e-6", "1.00e-6 (published)", "1.25e-6",
               "1.50e-6 (round high)", "2.00e-6 (truncation bound)"),
  interval = c(base::rep("rounding", 5L), "truncation_only"))

# Scenario grid as in expand_pif2 (10 conservative + 6 Ruiz-Tagle lambda=1 + 6 lambda=0.5).
base_sc <- tibble::tribble(
  ~scenario_id,          ~engine, ~shift_vol, ~shift_hed,
  "baseline",            "volume", 1.00, 1.00,
  "volume_reduction_10", "volume", 0.90, 1.00,
  "volume_reduction_20", "volume", 0.80, 1.00,
  "volume_reduction_30", "volume", 0.70, 1.00,
  "hed_reduction_10",    "hed",    1.00, 0.90,
  "hed_reduction_25",    "hed",    1.00, 0.75,
  "hed_reduction_50",    "hed",    1.00, 0.50,
  "combined_v10_h25",    "both",   0.90, 0.75,
  "combined_v20_h50",    "both",   0.80, 0.50,
  "combined_v30_h50",    "both",   0.70, 0.50)
base_sc$lambda <- 0
hed_like <- base_sc[base_sc$engine != "volume", ]
sc <- dplyr::bind_rows(
  base_sc,
  dplyr::mutate(hed_like, scenario_id = base::paste0(scenario_id, "_rt"),  lambda = 1),
  dplyr::mutate(hed_like, scenario_id = base::paste0(scenario_id, "_mid"), lambda = 0.5))
base::stopifnot(base::setequal(sc$scenario_id, base::unique(ref$scenario_id)))

cell_inputs <- function(year, group) {
  h <- ex$g_male_hed_list[[base::as.character(year)]][[group]]
  list(gamma = h$nhed, gamma_hed = h$hed,
       p_abs = .aaf_pick_prop(ex$p_abs_list_male, year, group),
       p_form = .aaf_pick_prop(ex$p_form_list_male, year, group),
       p_hed = .aaf_prop_from_group_list(ex$p_hed_list_male, base::which(years == year), group, year))
}

one <- function(b2, year, group, s) {
  inp <- cell_inputs(year, group)
  shift <- if (s$engine == "hed") s$shift_hed else s$shift_vol
  pif_point(x = ex$x_vals, rr_nhed = rr_ihd_m, beta = c(B1, b2),
            p_abs = inp$p_abs, p_form = inp$p_form, rr_fd = rr_fd,
            gamma = inp$gamma, gamma_hed = inp$gamma_hed, p_hed = inp$p_hed,
            rr_hed = "cap", scenario = s$engine, shift = shift, shift_hed = s$shift_hed,
            hed_exit_mix = s$lambda, hed_exit_shift = 1)
}

grid <- base::expand.grid(b2_i = base::seq_len(base::nrow(b2_grid)), year = years,
                          age_group = groups, sc_i = base::seq_len(base::nrow(sc)))
grid$pif <- base::mapply(function(i, y, g, k) one(b2_grid$b2[[i]], y, g, sc[k, ]),
                         grid$b2_i, grid$year, grid$age_group, grid$sc_i)
res <- tibble::as_tibble(grid) |>
  dplyr::mutate(b2 = b2_grid$b2[b2_i], b2_label = b2_grid$b2_label[b2_i],
                interval = b2_grid$interval[b2_i], scenario_id = sc$scenario_id[sc_i]) |>
  dplyr::select(-b2_i, -sc_i)

# Validation: published B2 must reproduce the stored expand_pif2 Table 5 point PIF.
chk <- dplyr::inner_join(
  res[res$b2 == 1e-6, c("year", "age_group", "scenario_id", "pif")],
  ref[, c("year", "age_group", "scenario_id", "pif")],
  by = c("year", "age_group", "scenario_id"), suffix = c("_mine", "_stored"))
max_dev <- base::max(base::abs(chk$pif_mine - chk$pif_stored))
base::stopifnot(base::nrow(chk) == 7L * 4L * 22L, max_dev < 1e-10)
base::message(base::sprintf("[validate] %d cells, max |PIF_mine - PIF_stored| = %.2e", base::nrow(chk), max_dev))

# Also report baseline AAF per B2 (the PAF the PIF denominators rest on).
aaf <- base::expand.grid(b2_i = base::seq_len(base::nrow(b2_grid)), year = years, age_group = groups)
aaf$aaf <- base::mapply(function(i, y, g) {
  inp <- cell_inputs(y, g)
  aaf_point(x = ex$x_vals, rr_nhed = rr_ihd_m, beta = c(B1, b2_grid$b2[[i]]),
            p_abs = inp$p_abs, p_form = inp$p_form, rr_fd = rr_fd, gamma = inp$gamma,
            gamma_hed = inp$gamma_hed, p_hed = inp$p_hed, rr_hed = "cap")
}, aaf$b2_i, aaf$year, aaf$age_group)
aaf$b2 <- b2_grid$b2[aaf$b2_i]; aaf$b2_i <- NULL

# RR curves 0-150 g/day.
xg <- c(0.1, base::seq(5, 150, by = 5))
curves <- base::expand.grid(x = xg, b2 = b2_grid$b2)
curves$rr <- base::exp(B1 * base::sqrt(curves$x) + curves$b2 * curves$x^3)
crossing <- tibble::tibble(b2 = b2_grid$b2,
  x_min_rr = base::sapply(b2_grid$b2, function(b) stats::optimize(function(x) B1 * base::sqrt(x) + b * x^3, c(0.01, 150))$minimum),
  x_rr_eq_1 = base::sapply(b2_grid$b2, function(b) stats::uniroot(function(x) B1 * base::sqrt(x) + b * x^3, c(1, 400))$root))

utils::write.csv(res, base::file.path(out, "b2_sens_pif_cells.csv"), row.names = FALSE)
utils::write.csv(aaf, base::file.path(out, "b2_sens_aaf_cells.csv"), row.names = FALSE)
utils::write.csv(curves, base::file.path(out, "b2_sens_rr_curves.csv"), row.names = FALSE)
utils::write.csv(crossing, base::file.path(out, "b2_sens_rr_landmarks.csv"), row.names = FALSE)
base::message(base::sprintf("sens_b2_ihd_male_table5 elapsed minutes: %.2f",
  base::as.numeric(base::difftime(base::Sys.time(), .t0, units = "mins"))))
