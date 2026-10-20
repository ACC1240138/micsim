.t0 <- Sys.time(); .t_start <- .t0  # the sourced files re-assign .t0; .t_start keeps the test's own start
# Real-data test of eps_markov_v2_extra.R and eps_markov_v2_sections.R: rebuilds the EN notebook globals, sources the
# v2 definitions, evaluates every section body in order and asserts the contract
# (__andres_control/eps_ipw_v2_plan_2026-10-19.md). Outputs go to EPS_MARKOV_OUTPUT (default .quarto/eps_v2_test,
# git-ignored). Run from the repository root; on this machine R must be pinned to the E-cores.
if (!nzchar(Sys.getenv("EPS_MARKOV_OUTPUT"))) Sys.setenv(EPS_MARKOV_OUTPUT = ".quarto/eps_v2_test")
ep_lang <- "en"
if (.Platform$OS.type == "windows") invisible(Sys.setlocale("LC_ALL", "English_United States.utf8")) else invisible(Sys.setlocale("LC_CTYPE", ""))
suppressMessages(here::i_am("__andres_control/eps_markov_transitions_EN.ipynb"))
ep_checks <- list(); ep_warnings <- character()
source(here::here("__andres_control", "eps_markov_core.R"))
# IRdisplay only renders inside a kernel; outside, ep_show/ep_fig raise one warning each, muffled here to keep the log readable.
quiet <- function(expr) withCallingHandlers(expr, warning = function(w) if (grepl("IRdisplay", conditionMessage(w))) invokeRestart("muffleWarning"))
step <- function(label, expr) {
  t <- Sys.time(); quiet(expr)
  cat(sprintf("[%s] %.2f minutes\n", label, as.numeric(difftime(Sys.time(), t, units = "mins"))))
}
step("eps-data-design", {
  ep_load(); ep_W <- ep_waves(12); ep_risk <- ep_make_risk(ep_W)
  ep_period_mass <- vapply(ep_periods, function(p) sum(ep_risk$period == p & ep_risk$complete), 1); names(ep_period_mass) <- ep_periods
  ep_des <- ep_design(); ep_ip <- ep_ipw_fit(ep_risk); ep_d <- ep_ipw_apply(ep_risk, ep_ip)
})
step("eps-model-validation (ep_k; ep_cvtab with repeats = 1)", {
  ep_tunes <- list(ep_tune(ep_risk, FALSE), ep_tune(ep_risk, TRUE)); ep_k <- vapply(ep_tunes, function(x) x$k, 1)
  ep_cv_result <- ep_cv(ep_risk, repeats = 1); ep_cvtab <- ep_cv_tables(ep_cv_result)
})
source(here::here("__andres_control", "eps_markov_v2_extra.R"))
txt <- readLines(here::here("__andres_control", "eps_markov_v2_sections.R"), encoding = "UTF-8")
at <- grep("^# @@", txt); labels <- sub("^# @@", "", txt[at]); ends <- c(at[-1] - 1, length(txt))
stopifnot(identical(labels, c("eps-v2-attrition", "eps-v2-ipw", "eps-v2-schemes", "eps-v2-diagnostics", "eps-v2-calibration-interval", "eps-v2-reproducibility")))
for (k in seq_along(at)) step(labels[k], eval(parse(text = txt[(at[k] + 1):ends[k]]), globalenv()))

cat("\n== assertions ==\n")
ok <- function(cond, label) { stopifnot(isTRUE(cond)); cat("PASS:", label, "\n") }
ex <- ep_v2_exits_audit; print(ex)
ok(all(ex$n_file[match(c("dead7", "imped7", "dead8", "imped8"), ex$exit)] == c(516, 339, 882, 432)), "exit files: 516/339 (VII) and 882/432 (VIII) unique ids")
ca <- ep_v2_covariate_audit(ep_v2_cov); print(ca)
ok(all(ca$pct_missing < 10), "covariate missingness below 10% in every wave for every predictor")
print(ep_v2_attr)
ok(all(with(ep_v2_attr, baseline == deceased + impeded + phone_only + completed + lost)), "attrition rows add up")
ok(all(is.na(ep_v2_attr$pct_followed_of_survivors) | (ep_v2_attr$pct_followed_of_survivors >= 0 & ep_v2_attr$pct_followed_of_survivors <= 1)), "pct_followed in [0, 1]")
ok(!any(ep_v2_risk$id[ep_v2_risk$period == "VI_VII"] %in% c(ep_v2_ex$dead7, ep_v2_ex$imped7)) &&
   !any(ep_v2_risk$id[ep_v2_risk$period == "VII_VIII"] %in% c(ep_v2_ex$dead8, ep_v2_ex$imped8)), "risk set v2 has no deceased or impeded ids")
ok(!anyNA(ep_v2_risk$psu) && !anyNA(ep_v2_risk$strata) && all(ep_v2_risk$id %in% ep_des$master$id), "risk set v2 carries the published psu and strata")
ok(all(is.finite(ep_v2_or$OR)) && all(ep_v2_or$lower <= ep_v2_or$OR & ep_v2_or$OR <= ep_v2_or$upper), "GLM odds ratios finite with lower <= OR <= upper")
cat("non-finite OR bounds:", sum(!is.finite(ep_v2_or$lower) | !is.finite(ep_v2_or$upper)), "\n")
print(ep_v2_sl$risks[, c("period", "learner", "cv_risk", "coef", "discrete_winner", "n", "n_complete", "fit_seconds")])
ok(all(abs(tapply(ep_v2_sl$risks$coef, ep_v2_sl$risks$period, sum) - 1) < 1e-8), "SuperLearner coefficients sum to 1 per period")
ok(all(is.finite(ep_v2_sl$risks$cv_risk)), "SuperLearner cv risks finite")
print(ep_v2_prob_summary)
for (s in c("ipw_v1", "ipw_v2_sl")) ok(all(ep_v2_sch[[s]]$p_obs >= .02 & ep_v2_sch[[s]]$p_obs <= 1), paste(s, "probabilities in [0.02, 1]"))
for (s in names(ep_v2_sch)) { m <- tapply(ep_v2_sch[[s]]$wn, ep_v2_sch[[s]]$period, sum); ok(all(abs(m - ep_v2_period_mass[names(m)]) < 1e-6), paste(s, "wn sums to the period mass")) }
rs <- stats::aggregate(estimate ~ scheme + model + group + from, ep_v2_mat[!is.na(ep_v2_mat$estimate), ], sum)
ok(max(abs(rs$estimate - 1)) < 1e-8, "matrix rows sum to one")
av <- ep_v2_mat$interval_status == "available"
ok(sum(av) > 0 && all(ep_v2_mat$lower[av] <= ep_v2_mat$estimate[av] + 1e-12 & ep_v2_mat$upper[av] >= ep_v2_mat$estimate[av] - 1e-12), "available intervals contain their estimate")
cat("matrix rows:", nrow(ep_v2_mat), " available intervals:", sum(av), "\n"); print(ep_v2_shift)
ok(all(nzchar(ep_v2_shift$max_cell)) && all(is.finite(ep_v2_shift$max_abs_shift)), "shift table has the max cell")
need <- expand.grid(scheme = names(ep_v2_sch), period = ep_periods, state5 = c(ep_v2_states, "All"), covariate = unique(ep_v2_smd$covariate), stringsAsFactors = FALSE)
ok(all(paste(need$scheme, need$period, need$state5, need$covariate) %in% paste(ep_v2_smd$scheme, ep_v2_smd$period, ep_v2_smd$state5, ep_v2_smd$covariate)),
   "SMD table has every covariate level for every scheme/period/state5")
print(ep_v2_balance); print(ep_v2_wdiag[ep_v2_wdiag$state5 == "All", ])
ok(all(is.finite(ep_v2_calint$difference)), "calibration differences finite")
figs <- file.path(ep_out, "en", paste0(c("fig_v2_attrition", "fig_v2_odds_ratios", "fig_v2_scheme_shift", "fig_v2_smd", "fig_v2_calibration_interval"), ".png"))
ok(all(file.exists(figs)), "figures written")
outs <- c("v2_exits_audit", "v2_attrition_table", "v2_covariate_audit", "v2_ipw_glm_odds_ratios", "v2_superlearner_risks", "v2_ipw_probabilities_summary",
  "v2_scheme_weights_audit", "v2_transition_matrices_schemes_design_CI", "v2_scheme_shift_table", "v2_balance_smd", "v2_weight_diagnostics",
  "v2_calibration_by_interval_origin", "v2_analysis_checks", "v2_analysis_configuration")
ok(all(file.exists(file.path(ep_out, paste0(outs, ".csv")))), "all fourteen contract tables saved")
ok(all(unlist(ep_checks)), "all notebook checks passed")
cat("warnings collected by ep_warn:", length(ep_warnings), "\n"); print(table(ep_warnings))
cat(sprintf("Elapsed: %.2f minutes\n", as.numeric(difftime(Sys.time(), .t_start, units = "mins"))))
