.t0 <- Sys.time()
# EPS v4 analysis sections for eps_markov_transitions_v4_EN.ipynb. Each "# @@label" line starts one notebook cell.
# They run after the v1 and v2 cells, read their globals (ep_W, ep_des, ep_v2_ex, ep_v2_cov, ...) and never modify them.

# @@eps-v4-config
ep_v4_globals_before <- lapply(c("ep_W", "ep_risk", "ep_d", "ep_time", "ep_period_mass", "ep_v2_risk"), function(k) ep_v4_digest(get(k)))
ep_v4_cfg_table <- data.frame(setting = names(ep_v4_cfg), value = vapply(ep_v4_cfg, function(x) paste(x, collapse = "-"), ""))
ep_show(ep_v4_cfg_table, "v4 configuration", "v4 configuration")
ok <- !is.na(ep_W$cat)
ep_check(identical(ep_v4_cat(ep_W$current, ep_W$grams, ep_W$sex, "JRT")[ok], ep_W$cat[ok]), "The JRT rule of ep_v4_cat equals the v1 ep_cat")
ep_v4_ties <- ep_v4_border_ties(ep_W); ep_save(ep_v4_ties, "v4_border_ties")
ep_show(ep_v4_ties[ep_v4_ties$wave == "All", ], "Exact observations at each border, by sex (12 g, VI-VIII)", "Exact observations at each border, by sex (12 g, VI-VIII)")
dr <- ep_W[ep_W$current %in% 1 & ep_W$grams > 0 & !is.na(ep_W$cat), ]
ep_v4_migration <- as.data.frame(table(sex = dr$sex, wave = dr$wave,
  v1_rule = ep_v4_merge(ep_v4_cat(1, dr$grams, dr$sex, "JRT")), WHO_rule = ep_v4_merge(ep_v4_cat(1, dr$grams, dr$sex, "WHO"))))
ep_v4_migration <- ep_v4_migration[ep_v4_migration$Freq > 0 & as.character(ep_v4_migration$v1_rule) != as.character(ep_v4_migration$WHO_rule), ]
ep_save(ep_v4_migration, "v4_border_migration")
ep_show(ep_v4_migration, "Rows whose class changes from the v1 rule to the WHO rule", "Rows whose class changes from the v1 rule to the WHO rule")
ep_check(all(ep_v4_migration$sex == "Men" & ep_v4_migration$v1_rule == "C3plus" & ep_v4_migration$WHO_rule == "C2"),
  "The WHO rule only moves men at exactly 60 g/day from C3plus to C2")

# @@eps-v4-history-2009
# Regression switch: with v4 switches off, the v4 wave builder reproduces the v1 wave table exactly.
ep_check(identical(ep_v4_waves(12, NULL, ep_time, ep_cat), ep_W), "v4 waves with the v4 switches off equal the v1 waves")
ep_v4_h09 <- ep_v4_load09()
ep_v4_t0 <- ep_v4_time(ep_v4_cfg$tol, FALSE); ep_v4_t9 <- ep_v4_time(ep_v4_cfg$tol, TRUE)
who <- function(c, g, s) ep_v4_cat(c, g, s, ep_v4_cfg$rule)
ep_v4_W0 <- ep_v4_waves(ep_v4_cfg$grams, NULL, ep_v4_t0, who, propagate = ep_v4_cfg$propagate_longterm)
ep_v4_W9 <- ep_v4_waves(ep_v4_cfg$grams, ep_v4_h09, ep_v4_t9, who, propagate = ep_v4_cfg$propagate_longterm)
ep_v4_la <- ep_v4_link_audit(ep_v4_h09, ep_v4_W0)
ep_save(ep_v4_la$accepted, "v4_2009_link_audit"); ep_save(ep_v4_la$gap_distribution, "v4_2009_gap_distribution")
ep_show(ep_v4_la$accepted, "2009 to VI links accepted by window and tolerance", "2009 to VI links accepted by window and tolerance")
ep_v4_rc <- ep_v4_reclass(ep_v4_W0, ep_v4_W9); ep_save(ep_v4_rc, "v4_2009_reclassification")
ep_show(ep_v4_rc[ep_v4_rc$level != "wave x sex x age", ], "N0 to FD reclassified and long-term abstention candidates, with versus without 2009 history (ages 18-65)",
  "N0 to FD reclassified and long-term abstention candidates, with versus without 2009 history (ages 18-65)")
ep_v4_r0 <- ep_v4_make_risk(ep_v4_W0, ep_v4_t0, ep_v2_ex, ep_v2_cov)
ep_v4_r9 <- ep_v4_make_risk(ep_v4_W9, ep_v4_t9, ep_v2_ex, ep_v2_cov)
ep_check(identical(ep_v4_r0$row_id, ep_v4_r9$row_id) && identical(ep_v4_r0$complete, ep_v4_r9$complete) && identical(ep_v4_r0$y1_5, ep_v4_r9$y1_5),
  "2009 history changes origin labels only: identical pairs and destinations")
ep_check(!any(ep_v4_r9$complete & ep_v4_r9$state0_5 == "N0" & ep_v4_r9$state1_5 == "FD") &&
  !any(ep_v4_r9$complete & ep_v4_r9$state0_5 != "N0" & ep_v4_r9$state1_5 == "N0"), "v4 pairs respect the history-state transition map")
ep_v4_d0 <- ep_v4_ipw(ep_v4_r0); ep_v4_d9 <- ep_v4_ipw(ep_v4_r9)
ep_v4_d9_fixed <- ep_v4_scoped(list(ep_period_mass = ep_v4_period_mass(ep_v4_r9)), ep_ipw_apply(ep_v4_r9, ep_ipw_fit(ep_v4_r0)))
ep_v4_shift09 <- rbind(cbind(ipw = "refitted", ep_v4_matrix_shift(ep_v4_d0, ep_v4_d9, "period")),
  cbind(ipw = "refitted", ep_v4_matrix_shift(ep_v4_d0, ep_v4_d9, c("period", "sex"))),
  cbind(ipw = "fixed at the no-2009 fit", ep_v4_matrix_shift(ep_v4_d0, ep_v4_d9_fixed, c("period", "sex"))))
ep_save(ep_v4_shift09, "v4_2009_matrix_shift")
ep_check(max(abs(ep_v4_shift09$change[ep_v4_shift09$ipw != "refitted" & ep_v4_shift09$from %in% c("C1", "C2", "C3plus")]), na.rm = TRUE) < 1e-12,
  "With the IPW fixed, 2009 history leaves the drinker rows unchanged")
ep_v4_origins <- as.data.frame(table(variant = rep(c("without 2009", "with 2009"), c(sum(ep_v4_r0$complete), sum(ep_v4_r9$complete))),
  period = c(as.character(ep_v4_r0$period[ep_v4_r0$complete]), as.character(ep_v4_r9$period[ep_v4_r9$complete])),
  origin = c(as.character(ep_v4_r0$state0_5[ep_v4_r0$complete]), as.character(ep_v4_r9$state0_5[ep_v4_r9$complete]))))
ep_save(ep_v4_origins, "v4_2009_pair_origins")
ep_show(stats::xtabs(Freq ~ variant + period + origin, ep_v4_origins) |> as.data.frame() |> stats::reshape(idvar = c("variant", "period"),
  timevar = "origin", direction = "wide"), "Complete-pair origins, five states", "Complete-pair origins, five states")
ep_show(ep_v4_shift09[ep_v4_shift09$ipw == "refitted" & ep_v4_shift09$group %in% ep_periods & ep_v4_shift09$from %in% c("N0", "FD"), ],
  "Observed weighted N0 and FD rows with and without 2009 history", "Observed weighted N0 and FD rows with and without 2009 history")

# @@eps-v4-amount-models
ep_v4_cv <- ep_v4_amount_cv(ep_v4_r9, models = c(ep_v4_amount_models, "Hurdle_Pareto_ridge"))
ep_v4_met <- ep_v4_amount_metrics(ep_v4_cv); ep_v4_dec <- ep_v4_decide(ep_v4_met)
for (nm in names(ep_v4_met)) ep_save(ep_v4_met[[nm]], paste0("v4_amount_", nm))
ep_save(ep_v4_dec$table, "v4_amount_decision"); ep_save(ep_v4_cv$tuning, "v4_amount_sexage_tuning"); ep_save(ep_v4_cv$tail_audit, "v4_amount_tail_audit")
ep_check(!any(ep_v4_cv$tail_audit$pooled_fallback), "Every tail exponent was estimated within sex (no pooled fallback)")
ep_show(ep_v4_met$scores, "Held-out scores (five folds x three repeats; same participation model for all amount models)",
  "Held-out scores (five folds x three repeats; same participation model for all amount models)", 4)
ep_show(ep_v4_met$contrasts, "Paired logloss difference against the v1 lognormal (PSU/strata Taylor intervals)",
  "Paired logloss difference against the v1 lognormal (PSU/strata Taylor intervals)", 5)
ep_show(ep_v4_met$recovery[ep_v4_met$recovery$outcome %in% c("C3plus, all pairs", "C4 diagnostic, all pairs"), ],
  "Recovery of observed C3plus and C4 (C4 is a tail diagnostic only)", "Recovery of observed C3plus and C4 (C4 is a tail diagnostic only)", 4)
ep_show(ep_v4_met$tail_mean, "Mean grams/day among C3plus destinations, truncated at 150 g/day", "Mean grams/day among C3plus destinations, truncated at 150 g/day", 1)
ep_show(ep_v4_met$pit, "Randomized PIT: all destination drinkers and the tail above the training 90th percentile",
  "Randomized PIT: all destination drinkers and the tail above the training 90th percentile", 3)
ep_show(ep_v4_dec$table, "Pre-registered adoption rule", "Pre-registered adoption rule", 3)
ep_v4_winner <- ep_v4_dec$winner
cat("Adopted amount model:", ep_v4_winner, "\n")
# Quasi-separation audit of the hurdle logistic on all v4 pairs: C3plus events by sex x age and the largest coefficients.
d <- ep_v4_d9; d$state0 <- d$state0_5; d$y1 <- d$y1_5; dc <- d[d$y1 != "NC" & d$grams1 > 0, ]
ep_v4_events <- as.data.frame(table(sex = dc$sex, age_group = dc$age_group, C3plus = dc$y1 == "C3plus"))
ep_v4_events <- ep_v4_events[ep_v4_events$C3plus == "TRUE", c("sex", "age_group", "Freq")]; names(ep_v4_events)[3] <- "C3plus_destinations"
hp <- ep_binary_fit(dc, as.numeric(dc$y1 == "C3plus"), ep_v4_formula(), dc$wn)
ep_v4_sep <- data.frame(term = names(hp$coef), coefficient = as.numeric(hp$coef))
ep_save(ep_v4_events, "v4_hurdle_events_by_sex_age"); ep_save(ep_v4_sep, "v4_hurdle_coefficients")
ep_show(ep_v4_events, "C3plus destinations by sex and age (events behind the hurdle logistic)", "C3plus destinations by sex and age (events behind the hurdle logistic)")
ep_show(ep_v4_sep[abs(ep_v4_sep$coefficient) > 5, ], "Hurdle coefficients above 5 in absolute value (quasi-separation)",
  "Hurdle coefficients above 5 in absolute value (quasi-separation)")

# @@eps-v4-matrices
ep_v4_models_final <- unique(c(ep_v4_winner, "Lognormal_Pareto", "Lognormal", "Hurdle_Pareto_ridge"))
ep_v4_mat <- ep_v4_final_matrices(ep_v4_r9, ep_v4_models_final)
ep_save(ep_v4_mat, "v4_transition_matrices_design_CI")
rs <- stats::aggregate(estimate ~ model + group + from, ep_v4_mat[is.finite(ep_v4_mat$estimate), ], sum)
ep_check(max(abs(rs$estimate - 1)) < 1e-10, "Every v4 matrix row sums to one")
ep_check(all(ep_v4_mat$estimate[ep_v4_mat$structural & is.finite(ep_v4_mat$estimate)] == 0), "Structural zeros of the history map hold")
pooled <- ep_v4_mat[ep_v4_mat$group == "All", c("model", "from", "to", "n_origin", "estimate", "lower", "upper")]
ep_show(pooled[pooled$model == ep_v4_winner, ], paste("Pooled five-state matrix,", ep_v4_winner, "(JKn 95% intervals)"),
  paste("Pooled five-state matrix,", ep_v4_winner, "(JKn 95% intervals)"), 3)
# v2 versus v4 on the pooled matrix: the v2 Lognormal (official weight) collapsed to five states. Destinations C3 and
# C4 are summed within each origin; origins C3 and C4 are combined with their origin counts as weights.
v2 <- ep_v2_mat[ep_v2_mat$scheme == "official" & ep_v2_mat$model == "Lognormal" & ep_v2_mat$group == "All" & is.finite(ep_v2_mat$estimate), ]
v2$to <- ep_v4_merge(v2$to); v2 <- stats::aggregate(estimate ~ from + to + n_origin, v2, sum); v2$from <- ep_v4_merge(v2$from)
v2 <- do.call(rbind, lapply(split(v2, paste(v2$from, v2$to)), function(z)
  data.frame(from = z$from[1], to = z$to[1], estimate = stats::weighted.mean(z$estimate, z$n_origin))))
ep_v4_vs_v2 <- merge(v2, pooled[pooled$model == ep_v4_winner, c("from", "to", "estimate")], by = c("from", "to"), suffixes = c("_v2_lognormal", "_v4"))
ep_v4_vs_v2$change <- ep_v4_vs_v2$estimate_v4 - ep_v4_vs_v2$estimate_v2_lognormal
ep_save(ep_v4_vs_v2, "v4_vs_v2_pooled")
ep_show(ep_v4_vs_v2, "Pooled matrix: v2 (Lognormal, official weight, C3 + C4 summed) versus v4", "Pooled matrix: v2 (Lognormal, official weight, C3 + C4 summed) versus v4", 3)

# @@eps-v4-figures
ep_v4_plots()

# @@eps-v4-reproducibility
ep_v4_globals_after <- lapply(c("ep_W", "ep_risk", "ep_d", "ep_time", "ep_period_mass", "ep_v2_risk"), function(k) ep_v4_digest(get(k)))
ep_check(identical(ep_v4_globals_before, ep_v4_globals_after), "The v4 sections leave the v1/v2 objects unchanged")
src <- function(f) here::here("__andres_control", f)
ep_v4_sources <- data.frame(file = c("eps_markov_core.R", "eps_markov_v2_extra.R", "eps_markov_v4_extra.R", "eps_markov_v4_sections.R"),
  md5 = unname(tools::md5sum(src(c("eps_markov_core.R", "eps_markov_v2_extra.R", "eps_markov_v4_extra.R", "eps_markov_v4_sections.R")))))
ep_save(ep_v4_sources, "v4_source_md5")
ep_v4_checks_table <- data.frame(check = names(ep_checks), passed = unlist(ep_checks), row.names = NULL)
ep_save(ep_v4_checks_table, "v4_checks"); ep_save(ep_v4_cfg_table, "v4_configuration")
ep_show(ep_v4_sources, "Source files of this run (md5)", "Source files of this run (md5)")
ep_show(utils::tail(ep_v4_checks_table, 20), "Last checks recorded (all must be TRUE)", "Last checks recorded (all must be TRUE)")
stopifnot(all(ep_v4_checks_table$passed))
