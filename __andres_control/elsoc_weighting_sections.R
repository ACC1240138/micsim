# Cell bodies of elsoc_weighting_scenarios_EN.ipynb, one per "# @@label" line. The builder
# (_tools/build_elsoc_weighting_notebook.py) adds the timing lines; nothing here runs on its own.
# All estimates come from __andres_control/elsoc_2021_2023_exploration/weight_scenarios.R.

# @@elsoc-w-run
if (.Platform$OS.type == "windows") invisible(Sys.setlocale("LC_ALL", "English_United States.utf8"))
elsoc_root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
while (!file.exists(file.path(elsoc_root, ".acc_root")) && dirname(elsoc_root) != elsoc_root) elsoc_root <- dirname(elsoc_root)
stopifnot(file.exists(file.path(elsoc_root, ".acc_root")))
source(file.path(elsoc_root, "_tools", "acc_data.R")); elsoc_root <- acc_root(elsoc_root)
elsoc_base <- file.path(elsoc_root, "__andres_control", "elsoc_2021_2023_exploration")
stopifnot(all(vapply(c("haven", "tidyselect", "survey", "ggplot2", "scales", "IRdisplay", "htmltools", "knitr"), requireNamespace, logical(1), quietly = TRUE)))
source(file.path(elsoc_base, "weight_scenarios.R"), local = new.env(parent = globalenv()))

# @@elsoc-w-display
w_dir <- { o <- Sys.getenv("ELSOC_WEIGHTS_OUTPUT", ""); if (nzchar(o)) file.path(elsoc_root, o) else file.path(elsoc_base, "intervals") }
wt <- function(name) utils::read.csv(file.path(w_dir, paste0("weights_", name, ".csv")), stringsAsFactors = FALSE)
show_table <- function(x, caption, digits = 1) IRdisplay::display_html(as.character(htmltools::div(style = "overflow-x:auto;max-height:660px;overflow-y:auto", htmltools::HTML(knitr::kable(x, format = "html", digits = digits, row.names = FALSE, caption = caption)))))
pct <- function(x) ifelse(is.na(x), "—", sprintf("%.1f%%", 100 * x))
ci <- function(est, lo, hi, small = FALSE) paste0(pct(est), ifelse(is.na(lo), " [no CI]", paste0(" [", pct(lo), "; ", pct(hi), "]")), ifelse(!is.na(small) & small, " *", ""))
est_label <- c(unweighted_general = "E1 unweighted, general", total_general = "E2 total weight, general", unweighted_panel_subset = "E3 unweighted, panel subset", panel_panel_subset = "E4 panel weight, panel subset", total_panel_subset = "E5 total weight, panel subset", unweighted_general_minus_panel = "E6 unweighted, outside the balanced panel",
  total_general_trimmed = "E2 trimmed at p99", panel_panel_subset_trimmed = "E4 trimmed at p99", total_panel_subset_trimmed = "E5 trimmed at p99", total_general_origin_wave = "E2 with origin-wave weight", panel_panel_subset_origin_wave = "E4 with origin-wave weight")
qty_label <- c(s09_same = "S09 same answer", regular_stay = "Regular → regular", nonregular_stay = "Non-regular → non-regular", regular_net_change = "Net change in regular share", s10_same = "S10 same category", s10_increase = "S10 increase", s10_decrease = "S10 decrease")
contrast_label <- c(weighting_total_general = "Weighting: E2 − E1 (same people, G)", weighting_panel_subset = "Weighting: E4 − E3 (same people, P)", weight_variable_panel_subset = "Weight variable: E4 − E5 (same people, P)", selection_unweighted = "Selection, unweighted: E3 − E1", selection_unweighted_vs_lost = "Selection, unweighted: E3 − E6 (balanced panel vs rest of G)", selection_total_family = "Selection under total weights: E5 − E2", scenario_difference = "Scenario difference: E4 − E2 (identity)")
group_label <- function(x) { x <- gsub("Men_", "Men ", x, fixed = TRUE); x <- gsub("Women_", "Women ", x, fixed = TRUE); x <- gsub("Education_Basic_or_less", "Basic or less", x, fixed = TRUE); x <- gsub("Education_Secondary", "Secondary", x, fixed = TRUE); x <- gsub("Education_Higher", "Higher", x, fixed = TRUE); gsub("Education_Unknown", "Unknown", x, fixed = TRUE) }
comparison <- wt("comparison"); deltas <- wt("deltas"); matrices <- wt("transition_matrices"); changes <- wt("change_summary"); estimators <- wt("estimators")
main_est <- estimators$estimator[estimators$main]
periods <- unique(comparison$interval)
key_q <- c("s09_same", "regular_stay", "nonregular_stay", "s10_same", "s10_increase", "s10_decrease")
est_colors <- c("#444444", "#2a78d6", "#9aa4b1", "#eb6834", "#1baf7a", "#8e44ad")
show_plot <- function(p, name, width = 10, height = 5.5) { ggplot2::ggsave(file.path(w_dir, paste0("weights_", name, ".png")), p, width = width, height = height, dpi = 170, bg = "white"); ggplot2::ggsave(file.path(w_dir, paste0("weights_", name, ".pdf")), p, width = width, height = height, device = grDevices::cairo_pdf, bg = "white"); IRdisplay::display_png(file = file.path(w_dir, paste0("weights_", name, ".png"))) }
plot_theme <- function() ggplot2::theme_minimal(base_size = 12) + ggplot2::theme(panel.grid.minor = ggplot2::element_blank(), legend.position = "bottom", plot.title = ggplot2::element_text(face = "bold"))

# @@elsoc-w-documentation
doc <- wt("documentation")
show_table(doc[, c("interval", "sample", "weight_family", "variable", "origin_is_first_wave_of_sample", "n_s09_pairs", "positive_s09", "missing_s09", "nonpositive_s09", "sum_s09", "ess_s09", "min_s09", "max_s09", "n_s10_pairs", "positive_s10", "official_check_max_smd_pairs_vs_wave", "official_check_max_smd_pairs_vs_panel")],
  "Destination-wave longitudinal weights on the S09 and S10 pairs of this notebook (missing dates kept): coverage, sums, Kish effective sample size and the official composition check at the origin wave", digits = 3)
show_table(unique(doc[, c("weight_family", "population", "participation_pattern", "components", "source_report", "source_code", "decision")]), "What each weight is, who holds it, how it was built and where that is documented")
show_table(estimators, "Estimators: sample set, weight family, wave of the weight, trimming; the first six are the main ones")
show_table(wt("configuration"), "Configuration of this run")

# @@elsoc-w-flow
flow <- wt("sample_flow")
stage_labels <- c(origin_participants = "Origin-wave respondents (all ages)", destination_participants = "Destination-wave respondents (all ages)", origin_age_missing = "Origin age missing", origin_age18_65 = "Aged 18–65 at origin (baseline domain)", reinterviewed = "Re-interviewed at destination", sex_consistent = "Sex valid and identical at both ends",
  destination_date_missing = "Destination interview date missing (kept)", origin_date_missing = "Origin interview date missing (kept)", date_order_or_year_invalid = "Dates unordered or outside the nominal years (excluded)", kept_missing_date_links = "Links kept with a missing date (no duration)", dates_valid_after_sex = "Both dates valid (published rule)", primary_links_published_rule = "Primary links under the published rule", primary_links = "Primary links, missing dates kept (this notebook)",
  strict_age_consistent_links = "Strict age–time consistency (sensitivity only)", s09_classifiable_pairs = "S09 valid at both ends: pairs G", regular_both = "Regular at both ends", s10_classifiable_pairs = "S10 valid at both ends (regular both): S10 pairs", panel_eligible_links = "Panel-eligible links (ponderador_long_panel > 0)", s09_pairs_panel_eligible = "S09 pairs in the panel-eligible subset P", s10_pairs_panel_eligible = "S10 pairs in the panel-eligible subset",
  s09_pairs_general_minus_panel = "S09 pairs outside the panel subset (G minus P)", absent_middle_return = "Absent at the intermediate wave, present at both ends", destination_present_origin_absent = "Destination respondents absent at origin (all ages; context only)")
for (period in periods) { z <- flow[flow$interval == period, ]; stages <- unique(z$stage); tab <- data.frame(Stage = stage_labels[stages]); for (s in c("All", "M1", "M2")) { zz <- z[z$sample == s, ]; tab[[s]] <- zz$n[match(stages, zz$stage)] }; show_table(tab, paste0("Flow ", period, ": within an interval participants = pairs = persons")) }
show_table(wt("unique_persons"), "Unique persons across the three intervals: the three N are not independent persons")
du <- wt("durations"); du <- du[du$sample == "All" & du$item == "s09", c("interval", "sample_set", "n_pairs", "n_with_dates", "median", "min", "max", "q25", "q75")]
show_table(du, "Elapsed years between the two interviews from individual dates, S09 pairs; pairs without a destination date are kept and counted without a duration", digits = 3)
show_table(wt("rule_sensitivity"), "Published date rule versus missing dates kept: unweighted N and headline shares", digits = 4)

# @@elsoc-w-comparison
cmp <- comparison[comparison$estimator %in% main_est, ]
for (period in periods) {
  z <- cmp[cmp$interval == period & cmp$group == "All" & cmp$quantity %in% key_q, ]; z <- z[order(match(z$quantity, key_q), match(z$estimator, main_est)), ]
  show_table(data.frame(Quantity = qty_label[z$quantity], Estimator = est_label[z$estimator], N = z$n, ESS = round(z$ess), Estimate = ci(z$estimate, z$lower, z$upper), Width = sprintf("%.1f pp", 100 * z$width), `SE bootstrap` = sprintf("%.3f", z$se_boot), `SE Taylor` = ifelse(is.na(z$se_taylor), "—", sprintf("%.3f", z$se_taylor)), check.names = FALSE),
    paste0(period, ": the six main estimators on all pairs. N is unweighted; percentages are weighted where the estimator has weights; 95% segment-bootstrap intervals"))
}
z <- cmp[cmp$group == "All" & cmp$quantity %in% key_q, ]
z$quantity <- factor(qty_label[z$quantity], levels = qty_label[key_q]); z$estimator <- factor(est_label[z$estimator], levels = est_label[main_est])
p <- ggplot2::ggplot(z, ggplot2::aes(x = interval, y = estimate, colour = estimator)) + ggplot2::geom_pointrange(ggplot2::aes(ymin = lower, ymax = upper), position = ggplot2::position_dodge(width = .7), size = .3) + ggplot2::facet_wrap(~quantity, scales = "free_y", ncol = 3) + ggplot2::scale_y_continuous(labels = scales::percent) + ggplot2::scale_colour_manual(values = est_colors) + ggplot2::labs(x = NULL, y = NULL, colour = NULL, title = "Headline quantities under the six estimators, by interval") + plot_theme() + ggplot2::guides(colour = ggplot2::guide_legend(nrow = 2))
show_plot(p, "comparison", 11, 7)

# @@elsoc-w-deltas
for (period in periods) {
  z <- deltas[deltas$interval == period & deltas$group == "All" & deltas$quantity %in% key_q, ]; z <- z[order(match(z$quantity, key_q), match(z$contrast, names(contrast_label))), ]
  show_table(data.frame(Quantity = qty_label[z$quantity], Contrast = contrast_label[z$contrast], `N a` = z$n_a, `N b` = z$n_b, a = pct(z$estimate_a), b = pct(z$estimate_b), Delta = sprintf("%+.1f pp", 100 * z$delta), `95% CI` = ifelse(is.na(z$lower), "—", sprintf("[%+.1f; %+.1f]", 100 * z$lower, 100 * z$upper)), check.names = FALSE),
    paste0(period, ": paired differences a − b computed replicate by replicate on the common segment bootstrap, in percentage points"))
}
z <- deltas[deltas$group == "All" & deltas$quantity %in% key_q & deltas$contrast != "scenario_difference", ]
z$quantity <- factor(qty_label[z$quantity], levels = qty_label[key_q]); z$contrast <- factor(contrast_label[z$contrast], levels = contrast_label[names(contrast_label) != "scenario_difference"])
p <- ggplot2::ggplot(z, ggplot2::aes(x = interval, y = 100 * delta, colour = contrast)) + ggplot2::geom_hline(yintercept = 0, colour = "grey60") + ggplot2::geom_pointrange(ggplot2::aes(ymin = 100 * lower, ymax = 100 * upper), position = ggplot2::position_dodge(width = .7), size = .3) + ggplot2::facet_wrap(~quantity, ncol = 3) + ggplot2::labs(x = NULL, y = "percentage points", colour = NULL, title = "Weighting effects versus selection effects, by interval") + plot_theme() + ggplot2::guides(colour = ggplot2::guide_legend(nrow = 3))
show_plot(p, "deltas", 11, 7.5)

# @@elsoc-w-groups
sa <- comparison[comparison$estimator %in% main_est[1:4] & grepl("^(Men|Women)_", comparison$group) & comparison$quantity %in% c("regular_stay", "nonregular_stay"), ]
for (period in periods) for (q in c("nonregular_stay", "regular_stay")) { z <- sa[sa$interval == period & sa$quantity == q, ]; z <- z[order(z$group, match(z$estimator, main_est)), ]
  show_table(data.frame(Group = group_label(z$group), Estimator = est_label[z$estimator], N = z$n, ESS = round(z$ess), Estimate = ci(z$estimate, z$lower, z$upper, z$n < 30 | z$ess < 30)), paste0(period, ": ", qty_label[q], " by sex and initial age; * origin N or ESS below 30")) }
z <- sa[sa$estimator %in% c("unweighted_general", "total_general", "panel_panel_subset"), ]
z$estimator <- factor(est_label[z$estimator], levels = est_label[c("unweighted_general", "total_general", "panel_panel_subset")]); z$quantity <- qty_label[z$quantity]; z$group <- group_label(z$group)
p <- ggplot2::ggplot(z, ggplot2::aes(x = group, y = estimate, colour = estimator)) + ggplot2::geom_pointrange(ggplot2::aes(ymin = lower, ymax = upper), position = ggplot2::position_dodge(width = .6), size = .25) + ggplot2::facet_grid(quantity ~ interval) + ggplot2::coord_flip() + ggplot2::scale_y_continuous(labels = scales::percent) + ggplot2::scale_colour_manual(values = est_colors[c(1, 2, 4)]) + ggplot2::labs(x = NULL, y = NULL, colour = NULL, title = "Permanence by sex and initial age: unweighted, total-weighted and panel-weighted") + plot_theme()
show_plot(p, "groups", 11, 8)

# @@elsoc-w-s10
z <- comparison[comparison$estimator %in% main_est & comparison$group %in% c("All", "M1", "M2") & comparison$quantity %in% c("s10_same", "s10_increase", "s10_decrease"), ]
for (period in periods) { y <- z[z$interval == period, ]; y <- y[order(y$group, match(y$quantity, key_q), match(y$estimator, main_est)), ]
  show_table(data.frame(Group = y$group, Quantity = qty_label[y$quantity], Estimator = est_label[y$estimator], N = y$n, ESS = round(y$ess), Estimate = ci(y$estimate, y$lower, y$upper, y$ess < 30)), paste0(period, ": direction of change in S10 among regular drinkers with a valid frequency at both ends; * ESS below 30")) }
m <- matrices[matrices$item == "s10" & matrices$estimator %in% c("total_general", "panel_panel_subset") & matrices$group == "All" & matrices$n_origin > 0, ]
fl <- stats::aggregate(cbind(flagged = m$small_ess | m$small_origin | m$rare_event, cells = 1), by = list(interval = m$interval, estimator = est_label[m$estimator]), FUN = sum)
show_table(fl, "Weighted S10 8×8 matrices for all pairs: cells with a non-empty origin flagged for small origin, rare event or ESS below 30; the matrices stay in weights_transition_matrices.csv")

# @@elsoc-w-composition
co <- wt("composition_official")
sm <- do.call(rbind, lapply(split(co, list(co$interval, co$wave, co$sample), drop = TRUE), function(z) data.frame(interval = z$interval[1], wave = sprintf("w%s", z$wave[1]), sample = z$sample[1], n_pairs = z$n_pairs[1], n_wave_18_65 = z$n_wave[1], n_balanced_panel_18_65 = z$n_panel[1],
  max_abs_smd_pairs_vs_wave = max(abs(z$smd_pairs_vs_wave)), max_abs_smd_pairs_vs_panel = max(abs(z$smd_pairs_vs_panel)), closer_to = ifelse(max(abs(z$smd_pairs_vs_wave)) <= max(abs(z$smd_pairs_vs_panel)), "all respondents (total weight)", "balanced panel (panel weight)"))))
show_table(sm[order(sm$interval, sm$wave, sm$sample), ], "Official composition check, unweighted sex × five INE age bands among people aged 18 to 65 at the origin wave: are the pairs closer to all respondents of that wave or to the balanced panel?", digits = 3)
smd <- wt("composition_smd"); smd$abs <- abs(smd$smd)
top <- do.call(rbind, lapply(split(smd, list(smd$interval, smd$contrast), drop = TRUE), function(z) { i <- which.max(z$abs); data.frame(interval = z$interval[1], contrast = contrast_label[z$contrast[1]], max_abs_smd = z$abs[i], at = paste(z$covariate[i], z$level[i]), share_a = z$share_a[i], share_b = z$share_b[i], levels_above_0_1 = sum(z$abs > .1)) }))
show_table(top[order(top$interval, match(top$contrast, contrast_label)), ], "EPS-style balance: largest standardized mean difference per contrast over sex, initial age, sample, education and S09 origin state", digits = 3)
bal <- wt("composition_balance"); b <- bal[bal$estimator %in% main_est[1:4] & bal$covariate == "age_group", ]
b$estimator <- factor(est_label[b$estimator], levels = est_label[main_est[1:4]])
p <- ggplot2::ggplot(b, ggplot2::aes(x = level, y = share, fill = estimator)) + ggplot2::geom_col(position = "dodge") + ggplot2::facet_wrap(~interval) + ggplot2::scale_y_continuous(labels = scales::percent) + ggplot2::scale_fill_manual(values = est_colors[1:4]) + ggplot2::labs(x = "initial age group", y = "share of S09 pairs", fill = NULL, title = "What the weights and the panel selection do to the age composition of the pairs") + plot_theme()
show_plot(p, "composition", 10, 5)

# @@elsoc-w-precision
dg <- wt("diagnostics"); dg <- dg[dg$item == "s09", c("interval", "estimator", "n", "sum_w", "ess", "unequal_weighting_effect", "max_over_mean", "top1_share")]; dg$estimator <- est_label[dg$estimator]
show_table(dg, "Weight diagnostics on S09 pairs: Kish effective sample size, unequal weighting effect n/ESS and concentration of the weights", digits = 2)
tc <- wt("taylor_check"); tc <- tc[tc$estimator %in% main_est, ]
ts <- do.call(rbind, lapply(split(tc, list(tc$interval, tc$estimator), drop = TRUE), function(z) data.frame(interval = z$interval[1], estimator = est_label[z$estimator[1]], cells = nrow(z), median_ratio = stats::median(z$se_ratio, na.rm = TRUE), p10 = stats::quantile(z$se_ratio, .1, na.rm = TRUE), p90 = stats::quantile(z$se_ratio, .9, na.rm = TRUE), flagged = sum(z$se_ratio_flag), flagged_max_origin_n = if (any(z$se_ratio_flag)) max(z$n_origin[z$se_ratio_flag]) else NA)))
show_table(ts[order(ts$interval, match(ts$estimator, est_label)), ], "Bootstrap SE divided by Taylor SE with the same clustering (segments within strata) over the headline cells; flagged outside 0.8–1.25", digits = 3)
cb <- comparison[comparison$group == "All" & comparison$quantity %in% key_q, ]
tr <- merge(cb[cb$estimator %in% c("total_general", "panel_panel_subset", "total_panel_subset"), c("interval", "quantity", "estimator", "estimate", "width")], cb[cb$estimator %in% c("total_general_trimmed", "panel_panel_subset_trimmed", "total_panel_subset_trimmed"), c("interval", "quantity", "estimator", "estimate", "width")], by = c("interval", "quantity"), suffixes = c("", "_trimmed"))
tr <- tr[sub("_trimmed$", "", tr$estimator_trimmed) == tr$estimator, ]; tr <- tr[order(tr$interval, match(tr$quantity, key_q), tr$estimator), ]
show_table(data.frame(interval = tr$interval, quantity = qty_label[tr$quantity], estimator = est_label[tr$estimator], untrimmed = pct(tr$estimate), trimmed_p99 = pct(tr$estimate_trimmed), shift_pp = sprintf("%+.2f", 100 * (tr$estimate_trimmed - tr$estimate)), width_untrimmed_pp = sprintf("%.1f", 100 * tr$width), width_trimmed_pp = sprintf("%.1f", 100 * tr$width_trimmed)), "Trimming sensitivity: destination weights capped at the 99th percentile of their wave × sample, no re-raking")
show_table(wt("trimming"), "Caps, pairs affected, ESS gain and the shift induced in the weighted sex × age-band shares of the pairs", digits = 3)
ow <- merge(cb[cb$estimator %in% c("total_general", "panel_panel_subset"), c("interval", "quantity", "estimator", "estimate")], cb[cb$estimator %in% c("total_general_origin_wave", "panel_panel_subset_origin_wave"), c("interval", "quantity", "estimator", "estimate")], by = c("interval", "quantity"), suffixes = c("", "_origin"))
ow <- ow[sub("_origin_wave$", "", ow$estimator_origin) == ow$estimator, ]; ow <- ow[order(ow$interval, match(ow$quantity, key_q), ow$estimator), ]
show_table(data.frame(interval = ow$interval, quantity = qty_label[ow$quantity], estimator = est_label[ow$estimator], destination_wave_weight = pct(ow$estimate), origin_wave_weight = pct(ow$estimate_origin), shift_pp = sprintf("%+.2f", 100 * (ow$estimate_origin - ow$estimate))), "Sensitivity to the wave of the weight: destination-wave weight (main) versus origin-wave weight")
show_table(wt("by_stratum"), "Destination weight by design stratum on the S09 pairs: where the dispersion of the weights comes from", digits = 3)

# @@elsoc-w-education
ed <- changes[changes$estimator %in% c("unweighted_general", "total_general") & grepl("^Education_", changes$group) & changes$item == "s09" & changes$event == "same", ]
nr <- matrices[matrices$estimator %in% c("unweighted_general", "total_general") & grepl("^Education_", matrices$group) & matrices$item == "s09" & matrices$from == 2 & matrices$to == 2, ]
tab <- merge(data.frame(interval = ed$interval, education = group_label(ed$group), estimator = est_label[ed$estimator], N = ed$n_origin, `S09 same answer` = ci(ed$estimate, ed$lower, ed$upper, ed$small_origin), check.names = FALSE),
  data.frame(interval = nr$interval, education = group_label(nr$group), estimator = est_label[nr$estimator], `N non-regular at origin` = nr$n_origin, `Non-regular → non-regular` = ci(nr$estimate, nr$lower, nr$upper, nr$small_origin), check.names = FALSE), by = c("interval", "education", "estimator"))
show_table(tab[order(tab$interval, tab$education, tab$estimator), ], "Education completed at origin (approximate three-level recode of m01) as an additional margin, unweighted and total-weighted; * origin N below 30")

# @@elsoc-w-validation
val <- wt("validation"); stopifnot(all(val$passed)); show_table(val, "Weighting scenarios: checks executed on the real data in this run")
sv <- stt("validation"); stopifnot(all(sv$passed)); show_table(sv, "State transitions: checks run in this execution (kind: data check, identity of two computations, or declaration)")
cat(length(list.files(s_dir, pattern = "^states_.*\\.csv$")), "states_*.csv tables in", basename(s_dir), "\n")
up <- wt("unique_persons"); cs <- changes[changes$group == "All" & changes$item == "s09" & changes$event == "same" & changes$estimator == "unweighted_general", ]
stopifnot(up$n_pairs_total[up$item == "s09"] == sum(cs$n_origin))
files <- list.files(w_dir, pattern = "^weights_.*\\.csv$"); cat(length(files), "weights_*.csv tables in", basename(w_dir), "\n")
cat("Published unweighted tables unchanged (hash check); no pooled independent-person inference; no microdata exported.\n")

# @@elsoc-s-run
source(file.path(elsoc_base, "state_transitions.R"), local = new.env(parent = globalenv()))
s_dir <- { o <- Sys.getenv("ELSOC_STATES_OUTPUT", ""); if (nzchar(o)) file.path(elsoc_root, o) else file.path(elsoc_base, "intervals") }
stt <- function(name) utils::read.csv(file.path(s_dir, paste0("states_", name, ".csv")), stringsAsFactors = FALSE)
SM <- stt("matrices"); SST <- stt("strata")
ST <- c("NR", paste0("F", 1:8)); st_short <- c(NR = "NR", F1 = "<1 d", F2 = "1 d", F3 = "2 d", F4 = "3 d", F5 = "4 d", F6 = "5 d", F7 = "6 d", F8 = "7 d")
SA <- paste(rep(c("Men", "Women"), each = 4), c("18-29", "30-44", "45-59", "60-65"), sep = "_")
LV <- c("2016-2018", "2018-2021", "2021-2023", "pooled"); lv_label <- c(`2016-2018` = "2016→2018", `2018-2021` = "2018→2021", `2021-2023` = "2021→2023", pooled = "Pooled 2016–2023")
SCH <- c("unweighted", "total", "panel"); sch_label <- c(unweighted = "Unweighted (general sample)", total = "ponderador_long_total (general sample)", panel = "ponderador_long_panel (panel-eligible subset)")
EST <- c("Observed", "A", "Lognormal")
pc1 <- function(x) ifelse(is.na(x), "—", sprintf("%.1f", 100 * x))
show_plot_s <- function(p, name, width, height, dpi = 150) { f <- file.path(s_dir, paste0("states_", name, ".png")); ggplot2::ggsave(f, p, width = width, height = height, dpi = dpi, bg = "white")
  ggplot2::ggsave(sub("png$", "pdf", f), p, width = width, height = height, device = grDevices::cairo_pdf, bg = "white"); IRdisplay::display_png(file = f) }

# @@elsoc-s-flow
show_table(stt("dictionary"), "States: non-regular (S09 = 2) and the eight original S10 categories of regular drinkers, with the latent average drinking days per week used by the lognormal")
fl <- stt("flow"); names(fl) <- c("Interval", "Sample", "S09 pairs", "Regular at origin, S10 not valid", "Regular at destination, S10 not valid", "Pairs with a state at both ends", "Of which panel-eligible", "Origin NR", "Origin regular", "Destination NR", "Destination regular")
show_table(fl, "From S09 pairs to pairs with a state at both ends: only regular drinkers without a valid S10 answer drop out", digits = 0)
for (lv in LV) { z <- SST[SST$level == lv, ]; g <- z[z$scheme == "unweighted", ]; tt <- z[z$scheme == "total", ]; pn <- z[z$scheme == "panel", ]
  tab <- data.frame(Group = group_label(g$group), Pairs = g$n_pairs, Persons = g$n_persons, `ESS total` = round(tt$ess[match(g$group, tt$group)]), `Panel subset pairs` = pn$n_pairs[match(g$group, pn$group)],
    `ESS panel` = round(pn$ess[match(g$group, pn$group)]), g[, paste0("n_", ST)], check.names = FALSE)
  names(tab)[7:15] <- paste("n", st_short[ST])
  show_table(tab, paste0(lv_label[lv], ": n of the strata. Pairs and origin-state counts are unweighted (general sample); persons are counted once", if (lv == "pooled") ", although many contribute two or three pairs" else ""), digits = 0) }

# @@elsoc-s-models
tu <- stt("A_tuning"); tw <- stats::reshape(tu[, c("scheme", "k", "logloss")], idvar = "k", timevar = "scheme", direction = "wide"); names(tw) <- sub("^logloss\\.", "", names(tw))
ch <- tu[tu$chosen, c("scheme", "k")]
show_table(tw, paste0("Matrix A: person-blocked 3-fold cross-validated log loss by shrinkage strength k (EPS grid extended to 3000 and 10000); chosen k: ", paste(ch$scheme, ch$k, sep = " = ", collapse = ", ")), digits = 4)
co <- stt("lognormal_coefficients"); cw <- stats::reshape(co, idvar = c("part", "term"), timevar = "scheme", direction = "wide"); names(cw) <- sub("^estimate\\.", "", names(cw))
show_table(cw, "Two-part lognormal: coefficients of the participation logit and of log days per week, by weighting scheme (reference: origin NR, men 18–29, 2016→2018)", digits = 3)
sh <- stt("lognormal_shape")
p <- ggplot2::ggplot(sh[sh$interval == "All", ], ggplot2::aes(log(cut_days), probit, colour = scheme)) + ggplot2::geom_point() + ggplot2::geom_smooth(method = "lm", formula = y ~ x, se = FALSE, linewidth = .5) +
  ggplot2::scale_x_continuous(breaks = log(1:7), labels = 1:7) + ggplot2::labs(x = "days per week (log scale): cumulative share of S10 codes up to that limit", y = "probit of the cumulative share", colour = NULL, title = "Cumulative S10 shares against log days") + plot_theme()
show_plot_s(p, "lognormal_shape", 7.5, 4.5)
show_table(unique(sh[, c("scheme", "interval", "n_regular_destinations", "slope", "implied_sigma", "r_squared", "r_squared_rounding", "r_squared_linear_days")]),
  "Probit of the cumulative S10 distribution: slope on log days, implied lognormal sigma and R squared under the main reading (code k = k − 1 to k days), the rounded-day reading (limits 0.5 to 6.5) and a linear day scale, by scheme and interval", digits = 3)
cvc <- stt("cv_comparison"); dci <- function(d, se) sprintf("%+.4f [%+.4f; %+.4f]", d, d - 1.96 * se, d + 1.96 * se)
cvc$`Lognormal − A [95% CI]` <- dci(cvc$logloss_difference, cvc$logloss_difference_se); cvc$`Rounded-day reading − main reading [95% CI]` <- dci(cvc$rounding_minus_floor, cvc$rounding_minus_floor_se)
show_table(cvc[, c("scheme", "interval", "n_pairs", "logloss_A", "logloss_Lognormal", "Lognormal − A [95% CI]", "brier_A", "brier_Lognormal", "logloss_Lognormal_rounding", "Rounded-day reading − main reading [95% CI]")],
  "Out-of-fold comparison, 5 person-blocked folds × 3 repeats: weighted log loss and Brier score; negative differences favour the first model named. The last columns refit the lognormal reading S10 codes as days rounded to the nearest day", digits = 4)
ca <- stt("calibration_oof"); ca <- ca[ca$n_origin >= 30 & ca$model %in% c("A", "Lognormal"), ]
p <- ggplot2::ggplot(ca, ggplot2::aes(observed, predicted_out_of_fold, colour = interval)) + ggplot2::geom_abline(colour = "grey60") + ggplot2::geom_point(alpha = .7, size = 1.3) + ggplot2::facet_grid(factor(scheme, SCH) ~ factor(model, c("A", "Lognormal"))) +
  ggplot2::coord_equal() + ggplot2::scale_x_continuous(labels = scales::percent) + ggplot2::scale_y_continuous(labels = scales::percent) +
  ggplot2::labs(x = "observed share", y = "out-of-fold predicted share", colour = NULL, title = "Out-of-fold calibration (origins with at least 30 pairs)") + plot_theme()
show_plot_s(p, "calibration_oof", 8.5, 10)

# @@elsoc-s-all
heat <- function(z, title) ggplot2::ggplot(z, ggplot2::aes(factor(to, ST, st_short[ST]), factor(from, rev(ST), st_short[rev(ST)]), fill = estimate)) + ggplot2::geom_tile(colour = "white") +
  ggplot2::geom_text(ggplot2::aes(label = ifelse(is.na(estimate), "", sprintf("%.0f", 100 * estimate)), colour = !is.na(estimate) & estimate > .45), size = 2.2) +
  ggplot2::scale_colour_manual(values = c(`TRUE` = "white", `FALSE` = "black"), guide = "none") + ggplot2::scale_fill_viridis_c(direction = -1, limits = c(0, 1), na.value = "grey92", labels = scales::percent) +
  ggplot2::facet_grid(factor(level, LV, lv_label[LV]) ~ factor(estimator, EST)) + ggplot2::labs(x = "destination", y = "origin", fill = NULL, title = title) + ggplot2::theme_minimal(base_size = 11) +
  ggplot2::theme(panel.grid = ggplot2::element_blank(), plot.title = ggplot2::element_text(face = "bold"), axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
for (s in SCH) show_plot_s(heat(SM[SM$group == "All" & SM$scheme == s, ], paste0("All pairs, ", sch_label[s], ": transition probabilities (%) by interval and estimator")), paste0("heat_all_", s), 10.5, 13.5, dpi = 130)

# @@elsoc-s-strata
st_css <- "<style>details.stm{border:1px solid #d6dbe2;border-radius:6px;margin:6px 0;padding:4px 10px}details.stm summary{cursor:pointer;padding:4px 0}table.stm-t{border-collapse:collapse;font-size:12px;font-variant-numeric:tabular-nums;margin:4px 0 12px}table.stm-t th,table.stm-t td{border:1px solid #e3e7ec;padding:3px 5px;text-align:center;vertical-align:top}table.stm-t td.d{background:#eef4fb}table.stm-t tr.sp th,table.stm-t tr.sp td{color:#7d8791}table.stm-t small{color:#5a6572}table.stm-t span.m{display:block;color:#6b4c9a;font-size:11px;white-space:nowrap}p.stm-h{font-weight:600;margin:8px 0 2px}p.stm-lv{font-size:1.1em;font-weight:700;margin:14px 0 4px}</style>"
mat_table <- function(z) {   # one scheme x level x group, the three estimators
  pick <- function(est) { x <- z[z$estimator == est, ]; x[match(paste(rep(ST, each = 9), rep(ST, 9)), paste(x$from, x$to)), ] }
  ob <- pick("Observed"); a <- pick("A"); ln <- pick("Lognormal")
  head <- paste0("<tr><th>From ↓ to →</th><th>n</th>", paste0("<th>", st_short[ST], "</th>", collapse = ""), "</tr>")
  body <- vapply(seq_len(9), function(i) { r <- (i - 1) * 9 + 1:9; n <- ob$n_origin[r[1]]
    tip <- sprintf("A %s [%s; %s] | lognormal %s [%s; %s]", pc1(a$estimate[r]), pc1(a$lower[r]), pc1(a$upper[r]), pc1(ln$estimate[r]), pc1(ln$lower[r]), pc1(ln$upper[r]))
    obs <- if (n > 0) paste0(pc1(ob$estimate[r]), ifelse(is.na(ob$lower[r]), "", sprintf("<br><small>[%s; %s]</small>", pc1(ob$lower[r]), pc1(ob$upper[r])))) else rep("—", 9)
    cells <- sprintf("<td%s>%s<span class=\"m\" title=\"%s\">A %s · LN %s</span></td>", ifelse(seq_len(9) == i, " class=\"d\"", ""), obs, tip, pc1(a$estimate[r]), pc1(ln$estimate[r]))
    sprintf("<tr%s><th>%s</th><td>%d%s</td>%s</tr>", if (n < 30) " class=\"sp\"" else "", st_short[ST[i]], n, if (n < 30) "*" else "", paste(cells, collapse = "")) }, "")
  paste0("<div style=\"overflow-x:auto\"><table class=\"stm-t\">", head, paste(body, collapse = ""), "</table></div>")
}
block <- function(lv, g) { z <- SM[SM$level == lv & SM$group == g, ]; s0 <- SST[SST$level == lv & SST$group == g, ]
  su <- s0[s0$scheme == "unweighted", ]; tt <- s0[s0$scheme == "total", ]; sp <- s0[s0$scheme == "panel", ]
  head <- sprintf("<summary><b>%s</b> · %d pairs · %d persons · ESS %.0f with ponderador_long_total · panel subset %d pairs, ESS %.0f</summary>", group_label(g), su$n_pairs, su$n_persons, tt$ess, sp$n_pairs, sp$ess)
  paste0("<details class=\"stm\">", head, paste(vapply(SCH, function(s) paste0("<p class=\"stm-h\">", sch_label[s], "</p>", mat_table(z[z$scheme == s, ])), ""), collapse = ""), "</details>") }
IRdisplay::display_html(st_css)
for (lv in LV[1:3]) IRdisplay::display_html(paste0("<p class=\"stm-lv\">Origin wave ", substr(lv, 1, 4), ": ", lv_label[lv], "</p>", paste(vapply(c("All", SA), function(g) block(lv, g), ""), collapse = "")))

# @@elsoc-s-pooled
IRdisplay::display_html(paste0(st_css, "<p class=\"stm-lv\">", lv_label["pooled"], "</p>", paste(vapply(c("All", SA), function(g) block("pooled", g), ""), collapse = "")))
key_tr <- paste(c("NR", "NR", "NR", "F1", "F2", "F3", "F1", "F2"), c("NR", "F1", "F2", "NR", "NR", "NR", "F1", "F2"))
ci3 <- function(lo, hi) ifelse(is.na(lo), "—", sprintf("[%s; %s]", pc1(lo), pc1(hi)))
for (s in SCH) { z <- SM[SM$estimator == "Observed" & SM$level == "pooled" & SM$scheme == s & paste(SM$from, SM$to) %in% key_tr, ]
  z <- z[order(match(z$group, c("All", SA)), match(paste(z$from, z$to), key_tr)), ]
  show_table(data.frame(Group = group_label(z$group), Transition = paste(st_short[z$from], "→", st_short[z$to]), `n origin` = z$n_origin, `Persons in stratum` = z$n_persons_stratum, `Estimate %` = pc1(z$estimate),
    `Segment bootstrap` = ci3(z$lower, z$upper), `Taylor, strata + segments` = ci3(z$lower_taylor_design, z$upper_taylor_design), `Taylor, clustered by person` = ci3(z$lower_taylor_person, z$upper_taylor_person), check.names = FALSE),
    paste0("Pooled 2016–2023, ", sch_label[s], ": survey-weighted transition probabilities with three 95% intervals that keep all pairs of a person together")) }
ob <- SM[SM$estimator == "Observed" & SM$level == "pooled" & is.finite(SM$se_taylor_design) & SM$se_taylor_design > 0, ]
cmp <- do.call(rbind, lapply(split(ob, ob$scheme), function(z) data.frame(scheme = z$scheme[1], cells = nrow(z), `median SE person / independent pairs` = stats::median(z$se_taylor_person / z$se_taylor_independent, na.rm = TRUE),
  `NR → NR, all pairs: person / independent` = z$se_taylor_person[z$group == "All" & z$from == "NR" & z$to == "NR"] / z$se_taylor_independent[z$group == "All" & z$from == "NR" & z$to == "NR"],
  `median SE person / design` = stats::median(z$se_taylor_person / z$se_taylor_design, na.rm = TRUE), `median SE bootstrap / design` = stats::median(z$se_boot / z$se_taylor_design, na.rm = TRUE),
  `90th percentile bootstrap / design` = stats::quantile(z$se_boot / z$se_taylor_design, .9, na.rm = TRUE, names = FALSE), check.names = FALSE)))
show_table(cmp[match(SCH, cmp$scheme), ], "Pooled cells: ratios of standard errors. Independent pairs = Taylor ignoring that a person contributes several pairs; person = clustered by idencuesta; design = strata + segments", digits = 3)
fz <- SM[SM$level == "pooled" & SM$group != "All" & paste(SM$from, SM$to) %in% c("NR NR", "F1 NR", "F2 NR", "F3 NR"), ]
fz$transition <- factor(paste(st_short[fz$from], "→ NR"), paste(st_short[c("NR", "F1", "F2", "F3")], "→ NR"))
p <- ggplot2::ggplot(fz, ggplot2::aes(estimate, factor(group_label(group), rev(group_label(SA))), colour = factor(estimator, EST))) +
  ggplot2::geom_pointrange(ggplot2::aes(xmin = lower, xmax = upper), position = ggplot2::position_dodge(width = .6), size = .2, na.rm = TRUE) + ggplot2::facet_grid(factor(scheme, SCH) ~ transition) +
  ggplot2::scale_x_continuous(labels = scales::percent) + ggplot2::scale_colour_manual(values = c(Observed = "#444444", A = "#2a78d6", Lognormal = "#eb6834")) +
  ggplot2::labs(x = NULL, y = NULL, colour = NULL, title = "Pooled 2016–2023: staying non-regular and moving from regular use to non-regular, by sex and initial age") + plot_theme()
show_plot_s(p, "pooled_key_transitions", 12, 9)
