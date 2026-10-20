# Cell bodies of eps_markov_transitions_v2_EN.ipynb, one per "# @@label" line. The builder
# (_tools/build_eps_markov_v2_notebook.py) adds the timing lines; nothing here runs on its own.
# Functions come from eps_markov_core.R (version 1, unchanged) and eps_markov_v2_extra.R
# (contract: __andres_control/eps_ipw_v2_plan_2026-10-19.md).

# @@eps-v2-attrition
ep_v2_ex <- ep_v2_exits()
ep_v2_cov <- ep_v2_covariates()
ep_v2_attr <- ep_v2_attrition(ep_W, ep_v2_ex, ep_v2_cov)
ep_v2_risk <- ep_v2_make_risk(ep_W, ep_v2_ex, ep_v2_cov)
ep_v2_period_mass <- vapply(ep_periods, function(p) sum(ep_v2_risk$period == p & ep_v2_risk$complete), 1)
names(ep_v2_period_mass) <- ep_periods
ep_v2_exits_audit <- do.call(rbind, lapply(c("dead7", "imped7", "dead8", "imped8", "phone7"), function(k) {
 ids <- ep_v2_ex[[k]]; p <- if (grepl("7$", k)) "VI_VII" else "VII_VIII"; origin <- ep_W[ep_W$wave == ep_time$from[ep_time$period == p], ]
 data.frame(exit = k, period = p, n_file = length(ids), in_origin_respondents_18_65 = sum(origin$id %in% ids & origin$age >= 18 & origin$age <= 65),
  in_risk_set_v1 = sum(ep_risk$id[ep_risk$period == p] %in% ids), in_risk_set_v2 = sum(ep_v2_risk$id[ep_v2_risk$period == p] %in% ids))
}))
ep_save(ep_v2_exits_audit, "v2_exits_audit"); ep_save(ep_v2_attr, "v2_attrition_table")
ep_check(all(ep_v2_exits_audit$n_file[1:4] == c(516, 339, 882, 432)), "v2: exit files hold 516/339 (VII) and 882/432 (VIII) unique ids")
ep_check(all(ep_v2_exits_audit$in_risk_set_v2[1:4] == 0), "v2: no deceased or impeded person remains in risk set v2")
ep_check(all(with(ep_v2_attr, baseline == deceased + impeded + phone_only + completed + lost)), "v2: attrition table adds up")
ep_check(all(is.na(ep_v2_attr$pct_followed_of_survivors) | (ep_v2_attr$pct_followed_of_survivors >= 0 & ep_v2_attr$pct_followed_of_survivors <= 1)),
 "v2: share followed within [0, 1]")
ep_check(all(vapply(ep_periods, function(p) sum(ep_v2_attr$completed[ep_v2_attr$period == p & ep_v2_attr$state5 %in% ep_v2_states]) == ep_v2_period_mass[[p]], TRUE)),
 "v2: completed pairs in the attrition table equal the v2 period masses")
ep_show(ep_v2_exits_audit, "Exits and phone-only follow-ups: file counts and presence in the risk sets", "Exits and phone-only follow-ups: file counts and presence in the risk sets")
ep_show(ep_v2_attr, "Attrition by interval and origin state; the share followed is among survivors who could be followed",
 "Attrition by interval and origin state; the share followed is among survivors who could be followed", 3)
ep_show(ep_v2_covariate_audit(ep_v2_cov), "Origin covariates by wave: missingness after recoding non-response, and share Yes",
 "Origin covariates by wave: missingness after recoding non-response, and share Yes", 2)

# @@eps-v2-ipw
ep_v2_glm_fit <- ep_v2_glm(ep_v2_risk)
ep_v2_or <- ep_v2_glm_fit$odds_ratios
ep_save(ep_v2_or, "v2_ipw_glm_odds_ratios")
ep_v2_sl <- ep_v2_superlearner(ep_v2_risk, V = 5, seed = ep_seed)
ep_save(ep_v2_sl$risks, "v2_superlearner_risks")
ep_v2_prob_summary <- do.call(rbind, lapply(ep_periods, function(p) {
 ii <- ep_v2_risk$period == p & ep_v2_risk$complete
 do.call(rbind, lapply(c("GLM", "SuperLearner"), function(k) {
  x <- if (k == "GLM") ep_v2_glm_fit$prob[ii] else ep_v2_sl$prob[ii]; q <- stats::quantile(x, c(.01, .5, .99))
  data.frame(period = p, model = k, n_complete = sum(ii), min = min(x), p01 = q[[1]], median = q[[2]], mean = mean(x), p99 = q[[3]], max = max(x),
   n_below_floor = sum(x < .02), correlation_glm_sl = stats::cor(ep_v2_glm_fit$prob[ii], ep_v2_sl$prob[ii]))
 }))
}))
ep_save(ep_v2_prob_summary, "v2_ipw_probabilities_summary")
ep_check(all(is.finite(ep_v2_or$OR)) && all(ep_v2_or$lower <= ep_v2_or$OR & ep_v2_or$OR <= ep_v2_or$upper), "v2: GLM odds ratios finite and inside their intervals")
ep_check(all(abs(tapply(ep_v2_sl$risks$coef, ep_v2_sl$risks$period, sum) - 1) < 1e-8) && all(is.finite(ep_v2_sl$risks$cv_risk)),
 "v2: SuperLearner weights sum to one with finite cross-validated risks")
ep_check(all(is.finite(ep_v2_sl$prob[ep_v2_risk$complete])) && all(ep_v2_sl$prob[ep_v2_risk$complete] > 0 & ep_v2_sl$prob[ep_v2_risk$complete] <= 1),
 "v2: SuperLearner probabilities of completed pairs lie in (0, 1]")
ep_show(ep_v2_or[ep_v2_or$term != "(Intercept)", ], "Survey-weighted logistic response model: odds of being followed with the alcohol module",
 "Survey-weighted logistic response model: odds of being followed with the alcohol module", 3)
ep_show(ep_v2_sl$risks, "SuperLearner per interval: cross-validated risk, ensemble weight, discrete winner and seconds",
 "SuperLearner per interval: cross-validated risk, ensemble weight, discrete winner and seconds", 4)
ep_show(ep_v2_prob_summary, "Observation probabilities among completed pairs; the SuperLearner ensemble feeds IPW v2",
 "Observation probabilities among completed pairs; the SuperLearner ensemble feeds IPW v2", 3)

# @@eps-v2-schemes
ep_v2_sch <- ep_v2_schemes(ep_v2_risk, ep_v2_sl$prob)
ep_check(all(vapply(ep_v2_sch, function(z) { m <- tapply(z$wn, z$period, sum); all(abs(m - ep_v2_period_mass[names(m)]) < 1e-6) }, TRUE)),
 "v2: every scheme reproduces the period masses")
ep_v2_mx <- ep_v2_scheme_matrices(ep_v2_risk, ep_v2_sch, ep_v2_sl$prob)
ep_v2_mat <- ep_v2_mx$matrices; ep_v2_shift <- ep_v2_mx$shift
ep_save(ep_v2_mat, "v2_transition_matrices_schemes_design_CI"); ep_save(ep_v2_shift, "v2_scheme_shift_table")
ep_v2_rowsum <- stats::aggregate(estimate ~ scheme + model + group + from, ep_v2_mat[!is.na(ep_v2_mat$estimate), ], sum)
ep_check(max(abs(ep_v2_rowsum$estimate - 1)) < 1e-8, "v2: every available matrix row sums to one")
ep_show(ep_v2_shift, "Shifts between weighting schemes per interval and model, probability scale; the largest cell is named",
 "Shifts between weighting schemes per interval and model, probability scale; the largest cell is named", 4)
ep_show(ep_v2_mat[ep_v2_mat$group == "All" & ep_v2_mat$from == "C1" & !ep_v2_mat$structural, c("scheme", "model", "from", "to", "n_origin", "estimate", "lower", "upper")],
 "Example: pooled next-wave probabilities from C1 under the three schemes, JKn intervals",
 "Example: pooled next-wave probabilities from C1 under the three schemes, JKn intervals", 3)

# @@eps-v2-diagnostics
ep_v2_diag <- ep_v2_diagnostics(ep_v2_risk, ep_v2_sch)
ep_v2_smd <- ep_v2_diag$smd; ep_v2_wdiag <- ep_v2_diag$weights
ep_save(ep_v2_smd, "v2_balance_smd"); ep_save(ep_v2_wdiag, "v2_weight_diagnostics")
ep_v2_balance <- do.call(rbind, lapply(split(ep_v2_smd[ep_v2_smd$state5 == "All", ], ep_key(ep_v2_smd[ep_v2_smd$state5 == "All", ], c("scheme", "period"))), function(z)
 data.frame(scheme = z$scheme[1], period = z$period[1], covariate_levels = sum(is.finite(z$smd)), max_abs_smd = max(abs(z$smd), na.rm = TRUE),
  n_abs_smd_at_least_0_1 = sum(abs(z$smd) >= .1, na.rm = TRUE), worst = z$covariate[which.max(abs(z$smd))])))
ep_check(nrow(ep_v2_smd) == length(ep_v2_sch) * length(ep_periods) * (length(ep_v2_states) + 1) * length(unique(ep_v2_smd$covariate)),
 "v2: SMD table covers every scheme, interval, origin state and covariate level")
ep_show(ep_v2_balance, "Balance of the completed weighted sample against the baseline risk set, all origins; |SMD| target below 0.1",
 "Balance of the completed weighted sample against the baseline risk set, all origins; |SMD| target below 0.1", 3)
ep_show(ep_v2_wdiag[ep_v2_wdiag$state5 == "All", ], "Weight diagnostics per scheme and interval: Kish ESS, extremes, top 1% share, floor and trimming counts",
 "Weight diagnostics per scheme and interval: Kish ESS, extremes, top 1% share, floor and trimming counts", 2)

# @@eps-v2-calibration-interval
ep_v2_calint <- ep_v2_calibration_interval(ep_cvtab, ep_d)
ep_save(ep_v2_calint, "v2_calibration_by_interval_origin")
ep_check(all(is.finite(ep_v2_calint$difference)), "v2: held-out calibration differences are finite")
ep_v2_cal_show <- ep_v2_calint[!ep_v2_calint$sparse, ]
ep_show(utils::head(ep_v2_cal_show[order(-abs(ep_v2_cal_show$difference)), ], 15),
 "Largest held-out gaps by interval, origin state and destination; origin cells with at least 30 rows",
 "Largest held-out gaps by interval, origin state and destination; origin cells with at least 30 rows", 4)
ep_v2_plots()

# @@eps-v2-reproducibility
ep_v2_checks_table <- data.frame(check = names(ep_checks), passed = unlist(ep_checks), row.names = NULL)
ep_save(ep_v2_checks_table, "v2_analysis_checks")
ep_save(data.frame(seed = ep_seed, superlearner_V = 5, superlearner_stratified_CV = TRUE, superlearner_library = paste(ep_v2_sl$library, collapse = ";"),
 ranger_num_trees = 500, ranger_min_node_size = 50, probability_floor = .02, weight_trimming = "p1/p99 within interval", JKn_replicates = ncol(ep_des$multipliers), ipw_v1_refitted_in_replicates = TRUE,
 superlearner_fixed_in_replicates = TRUE, schemes = "official;ipw_v1;ipw_v2_sl", models = "A;Lognormal",
 exits = "deceased and impeded removed in both intervals; phone-only VII = missing outcome", macrozone_region = "left out: not in the public files"),
 "v2_analysis_configuration")
ep_check(all(ep_v2_checks_table$passed), "v2: all recorded checks passed")
ep_show(ep_v2_checks_table[grepl("^v2", ep_v2_checks_table$check), ], "Version 2 checks executed on real EPS data", "Version 2 checks executed on real EPS data")
