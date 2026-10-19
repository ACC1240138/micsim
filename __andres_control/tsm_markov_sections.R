# Cell bodies of TSM_ENPG_v3_EN.ipynb, one per "# @@label" line. The builder
# (_tools/build_tsm_markov_notebook.py) adds the timing lines; nothing here is
# executed on its own. Functions and constants come from tsm_markov_data.R and
# tsm_markov_models.R (contract: __andres_control/tsm_v3_plan_2026-10-19.md).

# @@tsm-session-setup
ts_lang <- "en"
if (.Platform$OS.type == "windows") invisible(Sys.setlocale("LC_ALL", "English_United States.utf8")) else invisible(Sys.setlocale("LC_CTYPE", ""))
suppressMessages(here::i_am("__andres_control/TSM_ENPG_v3_EN.ipynb"))
required <- c("survey","haven","nnet","MASS","ggplot2","jsonlite","IRdisplay","htmltools","knitr")
stopifnot(all(vapply(required, requireNamespace, logical(1), quietly = TRUE)))
ts_checks <- list(); ts_warnings <- character()

# @@tsm-data-design
ts_load()
ts_W <- ts_waves(12)
ts_risk <- ts_make_risk(ts_W)
ts_period_mass <- vapply(ts_periods, function(p) sum(ts_risk$period == p & ts_risk$complete), 1)
names(ts_period_mass) <- ts_periods
ts_ip <- ts_ipw_fit(ts_risk)
ts_d <- ts_ipw_apply(ts_risk, ts_ip)
ts_check(nrow(ts_d) == length(unique(ts_d$row_id)), "One row per person and interval")
ts_check(all(ts_d$wn > 0) && all(is.finite(ts_d$wn)), "Positive finite main weights")
ts_check(!any(ts_d$state0 != "N0" & ts_d$state1 == "N0") && !any(ts_d$state0 == "N0" & ts_d$state1 == "FD"),
 "Observed pairs respect the history-state transition map")
ts_v2 <- ts_v2_regression(ts_W, ts_risk)
ts_save(ts_v2, "v2_regression_check")
ts_check(is.logical(ts_v2$match) && all(ts_v2$match), "v2 regression quantities match")
ts_link <- ts_link_audit(ts_W, ts_risk); ts_save(ts_link, "link_audit")
ts_counts <- as.data.frame(table(period = ts_d$period, sex = ts_d$sex, age_group = ts_d$age_group, state0 = ts_d$state0))
names(ts_counts)[5] <- "n"
ts_save(ts_counts, "row_counts_state0_by_stratum")
ts_cohort <- do.call(rbind, lapply(ts_periods, function(p) {
 r <- ts_risk[ts_risk$period == p, ]; d <- ts_d[ts_d$period == p, ]; tm <- ts_time[ts_time$period == p, ]
 data.frame(period = p, months = tm$months, years = tm$years, risk_set = nrow(r), destination_present = sum(r$destination_present),
   incompatible_links = sum(r$destination_present & !r$compatible), usable_pairs = nrow(d), persons = length(unique(d$id)),
   age_min = min(d$age), age_max = max(d$age), weight_ESS = sum(d$wn)^2 / sum(d$wn^2),
   main_weight = "Origin Fact_Exp + link IPW (stages a and c constant)")
}))
ts_hist_audit <- ts_history_audit(ts_W)
ts_edu_audit <- ts_education_audit(ts_W)
ts_harmonization <- do.call(rbind, lapply(split(ts_W, ts_W$wave), function(d)
 data.frame(wave = d$wave[1], respondents = nrow(d), aged_18_65 = sum(d$age >= 18 & d$age <= 65, na.rm = TRUE),
  current = sum(d$current %in% 1), N0 = sum(d$state %in% "N0"), FD = sum(d$state %in% "FD"),
  C1 = sum(d$cat %in% "C1"), C2 = sum(d$cat %in% "C2"), C3 = sum(d$cat %in% "C3"), C4 = sum(d$cat %in% "C4"),
  signal_1 = sum(d$signal %in% 1), signal_0 = sum(d$signal %in% 0), hed6_1 = sum(d$hed6 %in% 1),
  grams_max = max(d$grams, na.rm = TRUE), prior_use = sum(d$prior_use %in% TRUE))))
ts_save(ts_cohort, "cohort"); ts_save(ts_hist_audit, "abstention_history_audit")
ts_save(ts_edu_audit, "education_rule_audit"); ts_save(ts_harmonization, "harmonization_audit")
ts_save(as.data.frame(table(origin = ts_d$state0)), "origin_counts")
ts_fd_tenure <- ts_fd_tenure_audit(ts_W); ts_save(ts_fd_tenure, "fd_tenure_audit")
ts_show(ts_cohort, "Adjacent-round analysis populations; months between rounds are approximate")
ts_show(data.frame(pairs = nrow(ts_d), persons = length(unique(ts_d$id)), persons_with_two_or_more_pairs = sum(table(ts_d$id) >= 2),
 persons_with_four_pairs = sum(table(ts_d$id) == 4)), "Pairs and distinct people")
ts_show(ts_v2, "Regression against version 2 before the link-compatibility rule")
ts_show(ts_link, "Link audit: destination records present, compatible and used")
ts_show(ts_hist_audit, "Past-only history flags by round; all available ages")
ts_show(ts_fd_tenure, "FD depends on panel tenure: non-drinkers by number of earlier interviews, and FD by months since the last observed drinking")
ts_show(ts_harmonization, "Harmonized wave table by round; counts only")
ts_diagrams()

# @@tsm-weight-audit
ts_weight_audit <- do.call(rbind, lapply(split(ts_d, ts_d$period), function(d)
 data.frame(period = d$period[1], min_probability = min(d$p_obs), median_weight = stats::median(d$wn), max_weight = max(d$wn),
  clipped = sum(d$untrimmed != d$wcorrected), weight_ESS = sum(d$wn)^2 / sum(d$wn^2))))
ts_save(ts_weight_audit, "ipw_audit")
ts_kish <- do.call(rbind, lapply(split(ts_d, ts_key(ts_d, c("period", "sex"))), function(d)
 data.frame(period = d$period[1], sex = d$sex[1], n = nrow(d), weight_ESS = sum(d$wn)^2 / sum(d$wn^2),
  kish_design_effect = nrow(d) * sum(d$wn^2) / sum(d$wn)^2)))
# shortcut: the Kish table is displayed only (not in the plan's audit-table list); save it if a CSV is wanted.
ts_show(ts_weight_audit, "Weight diagnostics; ESS reflects weight dispersion only, no PSU or strata exist")
ts_show(ts_kish, "Kish effective sample size and design effect by period and sex; descriptive, not an interval multiplier")

# @@tsm-model-validation
ts_tunes <- list(ts_tune(ts_risk, FALSE), ts_tune(ts_risk, TRUE))
ts_k <- vapply(ts_tunes, function(x) x$k, 1)
ts_save(rbind(ts_tunes[[1]]$scores, ts_tunes[[2]]$scores), "full_fit_shrinkage_tuning")
ts_fits <- lapply(stats::setNames(names(ts_models), names(ts_models)), function(nm) ts_fit(ts_d, nm, ts_k[if (nm == "A_education") 2 else 1]))
ts_scale_test <- lapply(c("Gamma", "Lognormal", "Multinomial", "Ordinal_two_part"), function(nm) {
 d <- ts_d; d$wn <- 10 * d$wn
 diff <- max(abs(ts_prob(ts_fits[[nm]], ts_d) - ts_prob(ts_fit(d, nm, ts_k[1]), ts_d)))
 ts_check(diff < 1e-7, paste("Weight-scale invariance", nm))
 data.frame(model = nm, max_absolute_difference = diff)
})
ts_save(do.call(rbind, ts_scale_test), "weight_scale_invariance")
ts_cv_result <- ts_cv(ts_risk)
ts_cvtab <- ts_cv_tables(ts_cv_result)
ts_contrasts <- ts_score_contrasts(ts_cvtab)
ts_save(ts_cv_result$audit, "CV_fold_audit"); ts_save(ts_cv_result$tuning, "CV_inner_tuning")
ts_save(ts_cvtab$scores, "CV_repeated_scores"); ts_save(ts_cvtab$summary, "cv_scores")
ts_save(ts_contrasts, "CV_paired_comparisons")
ts_show(ts_cvtab$summary, "Held-out category scores; lower log loss and Brier are better", 5)
ts_show(ts_contrasts[, 1:8], "Paired comparisons; intervals use person clusters, conditional on held-out predictions", 5)

# @@tsm-calibration
ts_cal <- do.call(rbind, lapply(c("A", "Gamma", "Lognormal", "Ordinal_two_part", "Ordinal_single", "Multinomial"), function(nm) {
 P <- ts_cvtab$prob[[nm]]
 data.frame(model = nm, category = ts_Y,
  observed = vapply(ts_Y, function(s) stats::weighted.mean(ts_d$y1 == s, ts_cvtab$w), 1),
  predicted = colSums(P * ts_cvtab$w) / sum(ts_cvtab$w))
}))
ts_save(ts_cal, "calibration_destination")
ts_show(ts_cal, "Held-out observed and predicted destination shares", 4)
ts_cal_cells <- ts_calibration_cells(ts_cvtab, ts_d)
ts_save(ts_cal_cells, "calibration_by_origin_cell")
ts_cal_show <- ts_cal_cells[!ts_cal_cells$sparse, ]
ts_show(utils::head(ts_cal_show[order(-abs(ts_cal_show$predicted - ts_cal_show$observed)), ], 15),
 "Largest held-out gaps among supported origin cells (n_origin of at least 30)", 4)
ts_la <- which(ts_contrasts$model == "Lognormal" & ts_contrasts$reference == "A")
stopifnot(length(ts_la) == 1)
ts_model_answer <- data.frame(best_logloss = ts_cvtab$summary$model[1],
 best_brier = ts_cvtab$summary$model[which.min(ts_cvtab$summary$brier)],
 lognormal_minus_A = ts_contrasts$difference[ts_la], lower = ts_contrasts$lower[ts_la], upper = ts_contrasts$upper[ts_la],
 mean_absolute_class_probability_change_pp = ts_contrasts$mean_absolute_class_probability_change_pp[ts_la],
 clear_lognormal_A_separation = ts_contrasts$lower[ts_la] > 0 | ts_contrasts$upper[ts_la] < 0)
ts_save(ts_model_answer, "model_decision_summary")
ts_show(ts_model_answer, "Current result, not a predetermined winner", 5)

# @@tsm-person-inference
ts_points <- ts_targets(ts_d, ts_fits[ts_main_models])
ts_pool_sexage <- do.call(rbind, lapply(ts_main_models, function(nm)
 ts_matrices(ts_d, ts_prob(ts_fits[[nm]], ts_d), nm, by = c("sex", "age_group"))))
ts_pool_tab <- do.call(rbind, lapply(ts_main_models, function(nm) {
 d <- ts_d; d$pooled <- "All"
 ts_matrices(d, ts_prob(ts_fits[[nm]], d), nm, by = "pooled")
}))
ts_edu_tab <- do.call(rbind, lapply(ts_main_models, function(nm) ts_matrices(ts_d, ts_prob(ts_fits[[nm]], ts_d), nm, by = "edu")))
ts_save(ts_edu_tab, "transition_matrices_education")
ts_show(ts_pool_tab[ts_pool_tab$from == ts_pool_tab$to & ts_pool_tab$model %in% c("A", "Gamma", "Lognormal"), c("model", "from", "n_origin", "estimate", "support")],
 "Pooled staying probabilities to the next round: a mixture of the four 4-8-month intervals weighted by their pairs; point estimates")
ts_ci_models <- c("A", "Gamma", "Lognormal", "Ordinal_single")
ts_person <- ts_bootstrap_person(model_names = ts_ci_models, annual = TRUE)
ts_person_ci <- function(tab) {
 keys <- names(ts_vector(tab))
 reps <- do.call(rbind, lapply(ts_person, function(x) x$target[keys]))
 ci <- cbind(tab, ts_interval(ts_vector(tab), reps))
 ci$interval_status[!ci$model %in% ts_ci_models] <- "not bootstrapped"
 ci
}
ts_ci <- ts_person_ci(ts_points)
ts_save(ts_ci, "transition_matrices_person_CI")
# The two pooled groupings carry different grouping columns; align them before binding.
ts_pool_ci <- ts_person_ci(ts_pool_sexage); ts_all_ci <- ts_person_ci(ts_pool_tab)
ts_pool_ci$pooled <- NA_character_; ts_all_ci$sex <- NA_character_; ts_all_ci$age_group <- NA_character_
ts_pool_ci <- rbind(ts_pool_ci, ts_all_ci[names(ts_pool_ci)])
ts_save(ts_pool_ci, "transition_matrices_pooled_person_CI")
ts_check(any(ts_pool_ci$interval_status == "available"), "Pooled person intervals available")
ts_personmat <- do.call(rbind, lapply(ts_person, function(x) x$target[names(ts_vector(ts_points[ts_points$model %in% ts_ci_models, ]))]))
ts_engine <- ts_coef(ts_fits)
ts_coef_names <- paste(ts_engine$model, ts_engine$component, ts_engine$term, sep = "::")
ts_engine <- cbind(ts_engine, ts_interval(ts_engine$estimate,
 do.call(rbind, lapply(ts_person, function(x) x$coefficients[ts_coef_names])), probability = FALSE))
ts_save(ts_engine, "engine_coefficients_person_CI")
ts_mc <- ts_bootstrap_stability(ts_personmat)
ts_save(ts_mc, "bootstrap_stability")
ts_show(ts_ci[ts_ci$model == "Gamma" & ts_ci$from == "C1" & ts_ci$to == "C1", c("period", "sex", "age_group", "n_origin", "estimate", "lower", "upper", "interval_status")],
 "Example: remaining in C1, Gamma model, whole-person bootstrap")
ts_show(ts_mc, "Bootstrap stability; whole-person replicates with IPW refitted")

# @@tsm-transport-history
ts_trans <- ts_transport(); ts_save(ts_trans$scores, "transport_scores"); ts_save(ts_trans$coverage, "transport_support")
ts_trans_text <- names(ts_trans$scores)[vapply(ts_trans$scores, function(v) is.character(v) || is.factor(v), TRUE)]
ts_transport_summary <- do.call(rbind, lapply(split(ts_trans$scores, ts_key(ts_trans$scores, ts_trans_text)), function(z)
 data.frame(z[1, ts_trans_text, drop = FALSE], logloss = stats::weighted.mean(z$logloss, z$weight_sum),
  brier = stats::weighted.mean(z$brier, z$weight_sum), n = sum(z$n), row.names = NULL)))
ts_save(ts_transport_summary, "transport_summary")
ts_show(ts_transport_summary, "Leave-one-interval-out transport; person-disjoint training and test", 4)
ts_hist <- ts_history_check(); ts_save(ts_hist, "adjusted_history_validation")
ts_show(ts_hist, "Does the state one round earlier add predictive information after adjustment?", 5)
ts_ck_tab <- ts_ck(); ts_save(ts_ck_tab, "chapman_kolmogorov_descriptive")
ts_rank_tab <- ts_rank(ts_d); ts_save(ts_rank_tab, "rank_matching_vs_panel")
ts_show(ts_rank_tab[ts_rank_tab$from == "C1" & ts_rank_tab$to == "C1", ],
 "C1 persistence: matched margins, different dependence", 3)

# @@tsm-annual-layer
# Single start 0.05 as in EPS so the point estimate matches the bootstrap replicates; the three-start grid is in the sensitivity table.
ts_annual_full <- lapply(ts_fits[c("A", "Gamma", "Lognormal")], function(f) ts_annual(ts_d, f, starts = .05, check_gradient = TRUE))
ts_ann_point <- unlist(lapply(ts_annual_full, function(x) as.vector(x$P)))
ts_ann_rep <- do.call(rbind, lapply(ts_person, function(x) x$annual))
ts_ann <- do.call(rbind, lapply(names(ts_annual_full), function(nm) {
 z <- ts_annual_full[[nm]]
 ts_check(max(abs(rowSums(z$P) - 1)) < 1e-8 && min(z$P) > -1e-10, paste("Annual stochastic matrix", nm))
 ts_check(z$semigroup_error < 1e-8, paste("Annual semigroup", nm))
 data.frame(model = nm, from = rep(ts_ST, 6), to = rep(ts_ST, each = 6), estimate = as.vector(z$P),
  weighted_reconstruction_RMSE = z$rmse, optimizer_code = z$convergence, gradient_error = z$gradient_error, semigroup_error = z$semigroup_error)
}))
ts_ann <- cbind(ts_ann, ts_interval(ts_ann_point, ts_ann_rep))
# Rows whose origin state has no observed pairs are penalty-driven, not estimated: report them as unsupported.
ts_ann_support <- function(tab, d) {
 n0 <- table(factor(as.character(d$state0), levels = unique(tab$from)))
 tab$n_origin <- as.integer(n0[as.character(tab$from)])
 tab$support <- ifelse(tab$n_origin == 0, "unobserved origin", ifelse(tab$n_origin < 30, "sparse", "observed"))
 bad <- tab$n_origin == 0
 for (v in intersect(c("estimate", "se", "lower", "upper"), names(tab))) tab[[v]][bad] <- NA_real_
 if ("interval_status" %in% names(tab)) tab$interval_status[bad] <- "unobserved origin"
 tab
}
ts_ann <- ts_ann_support(ts_ann, ts_d)
ts_save(ts_ann, "annual_pooled_matrices_person_CI")
ts_ann_sens <- do.call(rbind, lapply(c("A", "Gamma", "Lognormal"), function(nm) do.call(rbind, lapply(c(1e-5, 5e-5, 2e-4), function(pen) {
 z <- ts_annual(ts_d, ts_fits[[nm]], lambda = pen)
 data.frame(model = nm, penalty = pen, weighted_reconstruction_RMSE = z$rmse, start_objective_range = z$start_objective_range,
  max_annual_difference = max(abs(z$P - ts_annual_full[[nm]]$P)), optimizer_code = z$convergence)
}))))
ts_save(ts_ann_sens, "annual_generator_sensitivity")
# Time-homogeneity check: each interval fitted alone (primary penalty and start) against the joint generator.
ts_ann_intervals <- do.call(rbind, lapply(c("A", "Gamma", "Lognormal"), function(nm) do.call(rbind, lapply(ts_periods, function(p) {
 ii <- ts_d$period == p; z <- ts_annual(ts_d[ii, ], ts_fits[[nm]], starts = .05)
 P <- ts_prob(ts_fits[[nm]], ts_d[ii, ]); yrs <- ts_time$years[match(p, ts_time$period)]
 pj <- ts_expm(ts_annual_full[[nm]]$Q * yrs); pj5 <- cbind(pj[, 1] + pj[, 2], pj[, 3:6])
 err <- 0; mass <- 0
 for (s in seq_along(ts_ST)) { jj <- as.character(ts_d$state0[ii]) == ts_ST[s]; if (any(jj)) {
  target <- colSums(P[jj, , drop = FALSE] * ts_d$wn[ii][jj]) / sum(ts_d$wn[ii][jj])
  err <- err + sum(ts_d$wn[ii][jj]) * sum((pj5[s, ] - target)^2); mass <- mass + sum(ts_d$wn[ii][jj]) } }
 data.frame(model = nm, period = p, years = yrs, single_fit_RMSE = z$rmse, joint_fit_within_interval_RMSE = sqrt(err / mass),
  single_fit_annual_stay_N0 = z$P[1, 1], single_fit_annual_stay_FD = z$P[2, 2], single_fit_annual_stay_C1 = z$P[3, 3],
  joint_annual_stay_N0 = ts_annual_full[[nm]]$P[1, 1], joint_annual_stay_FD = ts_annual_full[[nm]]$P[2, 2],
  joint_annual_stay_C1 = ts_annual_full[[nm]]$P[3, 3], optimizer_code = z$convergence)
}))))
ts_save(ts_ann_intervals, "annual_interval_fits")
ts_show(ts_ann[ts_ann$from == ts_ann$to, c("model", "from", "to", "n_origin", "support", "estimate", "lower", "upper", "interval_status")],
 "Annual staying probabilities: model-derived, pooled; whole-person bootstrap intervals; unobserved origins are not estimated")
ts_show(ts_ann_sens, "Annual reconstruction sensitivity to penalty and restarts", 5)
ts_show(ts_ann_intervals[, c("model", "period", "years", "single_fit_RMSE", "joint_fit_within_interval_RMSE",
 "single_fit_annual_stay_N0", "joint_annual_stay_N0", "single_fit_annual_stay_C1", "joint_annual_stay_C1")],
 "Each interval fitted alone versus the joint generator: a time-homogeneity check; C2-C4 rows are not shown because they are penalty-driven", 4)

# @@tsm-eps-crosscheck
ts_cross <- ts_crosscheck_eps(ts_d, ts_fits, ts_annual_full, cvtab = ts_cvtab, annual_ci = ts_ann)
ts_unobserved <- names(which(table(factor(as.character(ts_d$state0), levels = ts_ST)) == 0))
ts_j <- match(paste(ts_cross$annual$model, ts_cross$annual$from), paste(ts_ann$model, ts_ann$from))
ts_cross$annual$n_origin <- ifelse(ts_cross$annual$source == "TSM", ts_ann$n_origin[ts_j], NA_integer_)
ts_cross$annual$support <- ifelse(ts_cross$annual$source == "TSM", ts_ann$support[ts_j], "EPS")
ts_cross$annual$comparable <- ts_cross$annual$from != "FD"   # TSM FD drank months earlier; EPS FD abstained for years
ts_bad <- ts_cross$annual$source == "TSM" & ts_cross$annual$from %in% ts_unobserved
ts_cross$annual$estimate[ts_bad] <- NA_real_; ts_cross$annual$lower[ts_bad] <- NA_real_; ts_cross$annual$upper[ts_bad] <- NA_real_
# Origin-only TSM baseline: the EPS projection also conditions on the origin state alone, so this is its like-for-like reference.
ts_origin_only <- local({
 w <- ts_d$wn; m <- tapply(w, list(factor(as.character(ts_d$state0), levels = ts_ST), ts_d$y1), sum); m[is.na(m)] <- 0
 m <- m / rowSums(m); m[!is.finite(m)] <- 0
 P <- m[as.character(ts_d$state0), , drop = FALSE]; loss <- ts_loss(P, ts_d$y1)
 one <- function(ii, label) data.frame(source = "TSM_origin_only_insample", model = "origin_only", period = label,
  logloss = stats::weighted.mean(loss$logloss[ii], w[ii]), brier = stats::weighted.mean(loss$brier[ii], w[ii]), n = length(ii), recovery_rmse = NA_real_)
 rbind(one(seq_len(nrow(ts_d)), "All"), do.call(rbind, lapply(ts_periods, function(p) one(which(ts_d$period == p), p))))
})
ts_cross$projection_eps_to_tsm <- rbind(ts_cross$projection_eps_to_tsm, ts_origin_only)
ts_save(ts_cross$annual, "eps_crosscheck_annual")
ts_save(ts_cross$projection_eps_to_tsm, "eps_crosscheck_projection_eps_to_tsm")
ts_save(ts_cross$projection_eps_matrices, "eps_crosscheck_projection_eps_matrices")
ts_save(ts_cross$projection_tsm_to_eps, "eps_crosscheck_projection_tsm_to_eps")
ts_save(ts_cross$projection_tsm_to_eps_summary, "eps_crosscheck_projection_tsm_to_eps_summary")
ts_show(ts_cross$annual[ts_cross$annual$from == ts_cross$annual$to, ],
 "Annual staying probabilities, TSM and EPS, each with its own interval; external consistency, not validation")
ts_show(ts_cross$projection_eps_to_tsm, "EPS generators projected to the TSM intervals and scored on TSM pairs, next to the TSM models", 4)
ts_show(ts_cross$projection_tsm_to_eps_summary, "TSM generators projected to the EPS interval lengths versus the EPS observed-origin pooled matrices", 4)

# @@tsm-merged-C3plus
ts_merged <- ts_merged_variant(ts_risk)
ts_save(ts_merged$cv_scores, "merged_C3plus_cv_scores")
ts_save(ts_merged$pooled, "merged_C3plus_pooled_matrices")
ts_merged$annual <- ts_ann_support(ts_merged$annual, ts_merged$d)
ts_save(ts_merged$annual, "merged_C3plus_annual")
ts_stay6 <- ts_pool_tab[ts_pool_tab$from == ts_pool_tab$to & ts_pool_tab$model %in% unique(ts_merged$pooled$model), c("model", "from", "n_origin", "estimate")]
ts_stay_m <- ts_merged$pooled[ts_merged$pooled$from == ts_merged$pooled$to, c("model", "from", "n_origin", "estimate")]
names(ts_stay6)[2:4] <- paste0("six_state_", names(ts_stay6)[2:4]); names(ts_stay_m)[2:4] <- paste0("merged_", names(ts_stay_m)[2:4])
ts_stay6$row <- stats::ave(seq_len(nrow(ts_stay6)), ts_stay6$model, FUN = seq_along)
ts_stay_m$row <- stats::ave(seq_len(nrow(ts_stay_m)), ts_stay_m$model, FUN = seq_along)
ts_show(merge(ts_stay6, ts_stay_m, by = c("model", "row"), all = TRUE)[, -2],
 "Pooled staying probabilities side by side: six states versus merged C3plus")
ts_show(ts_merged$cv_scores, "Merged-variant held-out scores; not comparable with the six-state scores", 5)

# @@tsm-sensitivities
ts_conv <- lapply(c(12, 15.7), function(g) {
 r <- ts_make_risk(ts_waves(g)); d <- ts_ipw_apply(r, ts_ipw_fit(r)); d$pooled <- "All"
 fits <- lapply(stats::setNames(ts_main_models, ts_main_models), function(nm) ts_fit(d, nm, ts_k[1]))
 list(sensitivity = do.call(rbind, lapply(ts_main_models, function(nm) {
  pr <- ts_prob(fits[[nm]], d)
  data.frame(grams_per_drink = g, model = nm, quantity = c("Drinking_t1", "Escalation_from_C1", "C3_C4_t1"),
   probability = c(stats::weighted.mean(1 - pr[, 1], d$wn),
    stats::weighted.mean(rowSums(pr[d$state0 == "C1", 3:5, drop = FALSE]), d$wn[d$state0 == "C1"]),
    stats::weighted.mean(rowSums(pr[, 4:5, drop = FALSE]), d$wn)))
 })), pooled = if (g == 15.7) do.call(rbind, lapply(ts_main_models, function(nm) ts_matrices(d, ts_prob(fits[[nm]], d), nm, by = "pooled"))))
})
ts_sensitivity <- do.call(rbind, lapply(ts_conv, function(x) x$sensitivity))
ts_save(ts_sensitivity, "conversion_sensitivity")
ts_save(ts_conv[[2]]$pooled, "transition_matrices_15_7g")
ts_upper <- ts_upper_band_sensitivity()
ts_save(ts_upper$summary, "upper_band_sensitivity"); ts_save(ts_upper$pooled, "upper_band_pooled_matrices")
# Four weighting scenarios separate the inverse-probability correction from the trimming of extreme expansion factors.
ts_weight_sens <- do.call(rbind, lapply(c("base_only", "base_trimmed", "IPW_untrimmed", "base_plus_IPW"), function(s) {
 d <- ts_d
 for (p in ts_periods) {
  ii <- d$period == p
  w <- switch(s, base_only = d$wbase[ii],
   base_trimmed = { cap <- ts_wquant(d$wbase[ii], d$mult[ii], c(.01, .99)); pmin(pmax(d$wbase[ii], cap[1]), cap[2]) },
   IPW_untrimmed = d$untrimmed[ii], base_plus_IPW = d$wn[ii])
  d$wn[ii] <- w / sum(w) * ts_period_mass[[p]]
 }
 pr <- ts_prob(ts_fit(d, "Gamma", ts_k[1]), d)
 data.frame(scenario = s, current_t1 = stats::weighted.mean(1 - pr[, 1], d$wn), C3_C4_t1 = stats::weighted.mean(rowSums(pr[, 4:5]), d$wn),
  weight_ESS = sum(d$wn)^2 / sum(d$wn^2))
}))
ts_save(ts_weight_sens, "weight_refit_sensitivity")
ts_edu_sens <- ts_education_sensitivity()
ts_save(ts_edu_sens$summary, "education_sensitivity"); ts_save(ts_edu_sens$pooled, "education_sensitivity_pooled_matrices")
# Held-out scores of alternative risk sets (one CV repeat): the period masses follow each variant's own complete pairs.
ts_variant_cv <- function(r, label, models = c("A", "Lognormal")) {
 old_mass <- ts_period_mass
 ts_period_mass <<- stats::setNames(vapply(ts_periods, function(p) sum(r$period == p & r$complete), 1), ts_periods)
 on.exit(ts_period_mass <<- old_mass, add = TRUE)
 d <- ts_ipw_apply(r, ts_ipw_fit(r))
 tab <- ts_cv_tables(ts_cv(r, model_names = models, repeats = 1, d = d), d = d)$summary
 cbind(variant = label, tab, pairs = nrow(d), persons = length(unique(d$id)), row.names = NULL)
}
ts_edu_cv <- rbind(ts_variant_cv(ts_risk, "lenient"),
 ts_variant_cv(ts_make_risk(ts_waves(education_rule = "strict")), "strict"),
 ts_variant_cv(ts_make_risk(ts_waves(education_rule = "reached")), "reached"))
ts_save(ts_edu_cv, "education_sensitivity_cv")
# Link rule sensitivity: the strict EPS age bounds (tolerance 0) instead of the primary bounds widened by one year.
ts_W_strict <- ts_waves(tolerance = 0); ts_risk_strict <- ts_make_risk(ts_W_strict, tolerance = 0)
ts_save(ts_link_audit(ts_W_strict, ts_risk_strict, tolerance = 0), "link_audit_strict_bounds")
ts_link_cv <- rbind(ts_variant_cv(ts_risk, "primary_bounds_tolerance_1"), ts_variant_cv(ts_risk_strict, "strict_EPS_bounds"))
ts_link_pooled <- ts_point_sensitivity(list(primary_bounds_tolerance_1 = ts_risk, strict_EPS_bounds = ts_risk_strict), c("A", "Lognormal"), "variant")
ts_save(ts_link_cv, "link_bounds_sensitivity_cv"); ts_save(ts_link_pooled$summary, "link_bounds_sensitivity")
ts_save(ts_link_pooled$pooled, "link_bounds_pooled_matrices")
ts_hed_result <- ts_hed(); ts_save(ts_hed_result$coef, "typical_quantity_signal_coefficients")
ts_save(ts_hed_result$proportions, "typical_quantity_signal_by_category")
z1 <- ts_d[!is.na(ts_d$hed6_1), ]; z0 <- ts_d[!is.na(ts_d$hed6_0), ]
ts_hed6 <- rbind(
 do.call(rbind, lapply(split(z1, ts_key(z1, c("y1", "sex"))), function(z) data.frame(level = "destination", category = as.character(z$y1[1]),
  sex = as.character(z$sex[1]), n = nrow(z), share_hed6 = stats::weighted.mean(z$hed6_1, z$wn)))),
 do.call(rbind, lapply(split(z0, z0$state0, drop = TRUE), function(z) data.frame(level = "origin", category = as.character(z$state0[1]),
  sex = "All", n = nrow(z), share_hed6 = stats::weighted.mean(z$hed6_0, z$wn)))))
rownames(ts_hed6) <- NULL
ts_save(ts_hed6, "hed6_item_by_category")
ts_show(ts_sensitivity, "Conversion sensitivity, refitted main models at 12 and 15.7 g per drink", 4)
ts_show(ts_upper$summary, "Upper band 16 drinks instead of 10; point estimates", 4)
ts_show(ts_weight_sens, "Refitted weight sensitivity: base, trimmed base, untrimmed IPW and primary weights", 4)
ts_show(ts_edu_sens$summary, "Education rule sensitivity: strict and reached-level variants; point estimates", 4)
ts_show(ts_edu_cv, "Education rule sensitivity: held-out scores, one CV repeat", 5)
ts_show(ts_link_cv, "Link rule sensitivity: pairs retained and held-out scores under the strict EPS age bounds", 5)
ts_show(ts_link_pooled$summary, "Link rule sensitivity: pooled point estimates", 4)
ts_show(ts_hed6, "Weighted share reporting the 6+ item by destination category and by origin state", 3)
ts_plots()

# @@tsm-reproducibility
ts_checks_table <- data.frame(check = names(ts_checks), passed = unlist(ts_checks), row.names = NULL)
ts_save(ts_checks_table, "analysis_checks")
ts_save(data.frame(seed = ts_seed, person_bootstrap_replicates = ts_B, CV_repetitions = ts_repeats,
 periods = paste(ts_periods, collapse = ";"), grams_primary = 12, education_rule = "lenient"), "analysis_configuration")
ww <- as.data.frame(table(ts_warnings), stringsAsFactors = FALSE); names(ww) <- c("warning", "n")
ts_save(ww, "fit_warnings")
ts_check(all(ts_checks_table$passed), "All recorded checks passed")
ts_show(ts_checks_table, "Executed checks on real TSM data")
si <- utils::capture.output(utils::sessionInfo())
writeLines(si[!grepl("[A-Za-z]:[/\\\\]", si)], file.path(ts_out, "session_info.txt"))
