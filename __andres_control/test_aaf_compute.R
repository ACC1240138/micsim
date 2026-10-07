# =============================================================================
# test_aaf_compute.R
# Tests for the transparent compute_*_aaf_from_registry() family that now lives
# in aaf_unified.R (single engine, explicit per-question knobs). Covers:
#   [STRUCT]  output table names + ordering for cancer / cv / injuries
#   [SHARED]  locan/opcan share the oral-pharynx RR -> identical points
#   [PARITY]  compute_cv point == the old ihd_is_binge_aaf .cv_cell point
#             (proves compute_cv replaces the retired binge file faithfully)
#   [KNOBS]   per-question neff/design_factor + consumption neff run and are
#             recorded transparently in the audit
#
# Run:
#   & 'C:\Program Files\R\R-4.4.1\bin\Rscript.exe' __andres_control\test_aaf_compute.R
# =============================================================================
setwd_control <- function() {
  if (file.exists("aaf_unified.R")) return(invisible())
  if (file.exists("__andres_control/aaf_unified.R")) { setwd("__andres_control"); return(invisible()) }
  stop("Cannot find aaf_unified.R")
}
setwd_control()
suppressMessages({
  source("rr_registry_adam.R")        # data/loader
  source("aaf_unified.R")             # engine + compute_*
  source("ihd_is_binge_aaf.R")        # legacy .cv_cell, for the cap parity check
})
options(width = 150)

n_fail <- 0L
check <- function(cond, msg, extra = "") {
  cat(sprintf("[%s] %s%s\n", if (isTRUE(cond)) "PASS" else { n_fail <<- n_fail + 1L; "FAIL" },
              msg, if (nzchar(extra)) paste0("  -> ", extra) else ""))
}
ordered_ok <- function(df) {
  pts <- unlist(df[grep("_point$", names(df))]); los <- unlist(df[grep("_lower$", names(df))])
  ups <- unlist(df[grep("_upper$", names(df))])
  # 2026-10-07 cc-cloud: B12. raw MC percentiles: require lower <= upper only; report the point-outside count.
  cat(sprintf("  B12: %d of %d cells with the point outside its interval\n", sum(los > pts + 1e-9 | pts > ups + 1e-9), length(pts)))
  all(is.finite(c(pts, los, ups))) && all(los <= ups + 1e-9) && all(ups <= 1 + 1e-9)
}
x <- seq(0.1, 150, length.out = 700)
mg <- list("2008" = lapply(1:4, function(j) list(estimate = c(shape = 2, rate = 0.08))))
mp <- list("2008" = setNames(as.list(c(0.20, 0.18, 0.16, 0.14)), paste0("edad_tramo_", 1:4)))
mf <- list("2008" = setNames(as.list(c(0.10, 0.09, 0.08, 0.07)), paste0("edad_tramo_", 1:4)))
ghed <- list("2008" = lapply(1:4, function(j) list(nhed = list(estimate = c(shape = 0.70, rate = 0.030)),
                                                    hed  = list(estimate = c(shape = 0.95, rate = 0.020)))))
phed <- lapply(1:4, function(j) c(0.30))

cat("\n========== [STRUCT] cancer (17 tables) ==========\n")
reg_c <- load_adam_rr_registry(scope = "cancer")
cc <- compute_cancer_aaf_from_registry(reg_c, mg, mg, mp, mp, mf, mf, x_vals = x,
        years = 2008, age_groups = 1:4, n_sim = 120, n_pca = 120, seed = 2125, use_parallel = FALSE)
check(length(cc$tables) == 17, "cancer produces 17 output tables", sprintf("got %d", length(cc$tables)))
check(all(vapply(cc$tables, ordered_ok, logical(1))), "all cancer tables ordered, finite, <= 1")
check(identical(cc$tables$locan_female$Fem1_point, cc$tables$opcan_female$Fem1_point),
      "locan/opcan share the oral-pharynx RR -> identical point")

cat("\n========== [STRUCT] injuries (6 tables, explicit HED) ==========\n")
reg_i <- load_adam_rr_registry(scope = "injuries")
inj <- compute_injury_aaf_from_registry(reg_i, ghed, ghed, mp, mp, mf, mf, phed, phed,
        x_vals_nhed = x, years = 2008, age_groups = 1:4, n_sim = 120, n_pca = 120, seed = 2125, use_parallel = FALSE)
check(length(inj$tables) == 6, "injuries produces 6 output tables", sprintf("got %d", length(inj$tables)))
check(all(vapply(inj$tables, ordered_ok, logical(1))), "all injury tables ordered, finite, <= 1")

cat("\n========== [STRUCT] cv ihd/is + age_scope 15_64 (group 4 -> band 35-64) ==========\n")
reg_ihd <- load_adam_rr_registry(scope = "ihd")
cv <- compute_cv_aaf_from_registry(reg_ihd, ghed, ghed, mp, mp, mf, mf, phed, phed, x_vals = x,
        years = 2008, age_groups = 1:4, age_scope = "15_64", n_sim = 120, n_pca = 120, seed = 2125, use_parallel = FALSE)
check(setequal(names(cv$tables), c("ihd_female", "ihd_male")), "cv produces ihd_female + ihd_male")
check(identical(aaf_age_band_mapping("15_64")$adam_age_band[[4]], "35-64"), "age_scope 15_64: group 4 -> 35-64")

cat("\n========== [PARITY] compute_cv point == legacy .cv_cell point (cap math) ==========\n")
# Same cell (male, 2008, group 2 -> band 35-64): the deterministic point must match.
rr_obj <- .aaf_find_one(reg_ihd, sex = "male", adam_age_band = "35-64")
g_n <- ghed[["2008"]][[2]]$nhed; g_h <- ghed[["2008"]][[2]]$hed
legacy_pt <- .cv_cell(rr_obj, g_n, g_h, p_abs = 0.18, p_form = 0.09, p_hed = 0.30,
                      x = x, n_sim = 50, n_pca = 50, seed = 2125)$point
cv_one <- compute_cv_aaf_from_registry(reg_ihd, ghed, ghed, mp, mp, mf, mf, phed, phed, x_vals = x,
            years = 2008, age_groups = 2, age_scope = "15_64", target_output_names = "ihd_male",
            n_sim = 50, n_pca = 50, seed = 2125, use_parallel = FALSE)$tables$ihd_male$Male2_point
check(abs(cv_one - legacy_pt) < 1e-3, "compute_cv point matches retired .cv_cell point",
      sprintf("compute_cv=%.5f  legacy=%.5f", cv_one, legacy_pt))

cat("\n========== [KNOBS] per-question neff/design + consumption neff (transparent audit) ==========\n")
cc2 <- compute_cancer_aaf_from_registry(reg_c, mg, mg, mp, mp, mf, mf, x_vals = x,
        years = 2008, age_groups = 1, target_output_names = "lican_male",
        prev_method = "dirichlet",
        neff = list(abs = 2500, form = 400, hed = 200),
        design_factor = list(abs = 1.2, form = 1.6, hed = 1.4),
        neff_consumption = 150, design_factor_consumption = 1.3,
        n_sim = 200, n_pca = 150, seed = 2125, use_parallel = FALSE)
check(ordered_ok(cc2$tables$lican_male), "per-question knobs: cell ordered, finite, <= 1")
check(grepl("abs=2500", cc2$audit$neff) && grepl("form=1.6", cc2$audit$design_factor),
      "audit records the per-question neff/design transparently")

cat("\n=============================================================\n")
if (n_fail == 0L) cat("ALL aaf_compute TESTS PASSED.\n") else { cat(sprintf("%d test(s) FAILED.\n", n_fail)); quit(status = 1L) }
