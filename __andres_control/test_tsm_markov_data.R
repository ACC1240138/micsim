.t0 <- Sys.time()
# Real-data test of the TSM v3 data layer (__andres_control/tsm_markov_data.R). Run from the repository root,
# pinned to the E-cores on this machine. Writes only to .quarto/tsm_data_test (git-ignored); prints aggregates only.
Sys.setenv(TSM_MARKOV_OUTPUT = ".quarto/tsm_data_test")
if (.Platform$OS.type == "windows") invisible(Sys.setlocale("LC_ALL", "English_United States.utf8"))
ts_checks <- list(); ts_warnings <- character()
source(here::here("__andres_control", "tsm_markov_data.R"))
ts_load()
stopifnot(file.exists(file.path(ts_out, "input_manifest.csv")), file.exists(file.path(ts_out, "variable_dictionary.csv")))
print(utils::read.csv(file.path(ts_out, "input_manifest.csv"))[c("wave", "bytes", "household_rows", "respondents")], row.names = FALSE)
stopifnot(identical(ts_time$months, c(8, 4, 7, 5)), identical(ts_round_months$months, c(0, 8, 12, 19, 24)))
ts_W <- ts_waves()
ts_risk <- ts_make_risk(ts_W)
ts_period_mass <- vapply(ts_periods, function(p) sum(ts_risk$period == p & ts_risk$complete), 1)
names(ts_period_mass) <- ts_periods

# Decision 19: regression against version 2 before the link-compatibility rule.
ts_v2 <- ts_v2_regression(ts_W, ts_risk)
print(ts_v2[c("quantity", "v3", "v2_baseline", "match")], row.names = FALSE)
stopifnot(is.logical(ts_v2$match), all(ts_v2$match))

# Schema contract: column order, types and levels.
ty <- c(id = "character", period = "factor", age = "numeric", sex = "factor", edu = "factor", edu_num = "numeric",
  edu_missing = "numeric", wbase = "numeric", years = "numeric", state0 = "factor", state1 = "character", linked = "logical",
  grams0 = "numeric", grams1 = "numeric", signal0 = "numeric", signal1 = "numeric", hed6_0 = "numeric", hed6_1 = "numeric",
  age_group = "factor", current0 = "numeric", lg0 = "numeric", s0 = "logical", s1 = "logical", complete = "logical",
  y1 = "factor", row_id = "character", mult = "numeric", phq2 = "numeric", region = "factor", employment = "factor",
  partnered = "numeric", owner = "numeric", log_history = "numeric", after_R7 = "numeric", freq = "numeric", qty = "numeric",
  signal0f = "factor", destination_present = "logical", compatible = "logical")
stopifnot(identical(names(ts_risk), names(ty)), all(vapply(names(ty), function(v) class(ts_risk[[v]])[1] == ty[[v]], TRUE)))
stopifnot(identical(levels(ts_risk$period), ts_periods), identical(levels(ts_risk$sex), c("Men", "Women")),
  identical(levels(ts_risk$edu), c(ts_edu_levels, "Missing")), identical(levels(ts_risk$state0), ts_ST),
  identical(levels(ts_risk$age_group), ts_ages), identical(levels(ts_risk$y1), ts_Y),
  identical(levels(ts_risk$signal0f), c("Noncurrent", "0", "1")), identical(levels(ts_risk$region), c("RM", "North", "Centre", "South")),
  identical(levels(ts_risk$employment), c("No", "Yes", "Unknown")))
stopifnot(all(ts_risk$s0), identical(ts_risk$s1, ts_risk$linked), identical(ts_risk$complete, ts_risk$linked),
  all(ts_risk$mult == 1), !anyDuplicated(ts_risk$row_id), all(ts_risk$row_id == paste(ts_risk$id, ts_risk$period, sep = ":")),
  all(ts_risk$edu_num %in% 0:2), all(ts_risk$edu_missing %in% 0:1), all((ts_risk$edu_missing == 1) == (ts_risk$edu == "Missing")),
  all(ts_risk$edu_num[ts_risk$edu_missing == 1] == 0), all(ts_risk$age >= 18 & ts_risk$age <= 65), !anyNA(ts_risk$age_group),
  all(ts_risk$wbase > 0), all(ts_risk$years == ts_time$years[match(ts_risk$period, ts_time$period)]),
  all(ts_risk$current0 == (ts_risk$state0 %in% c("C1", "C2", "C3plus"))), all(ts_risk$lg0[ts_risk$current0 == 0] == 0),
  all(abs(ts_risk$lg0[ts_risk$current0 == 1] - log(ts_risk$grams0[ts_risk$current0 == 1])) < 1e-12),
  all(ts_risk$phq2 %in% 0:6), all(ts_risk$partnered %in% 0:1), all(ts_risk$owner %in% 0:1), all(ts_risk$after_R7 %in% 0:1),
  all(ts_risk$after_R7[ts_risk$period == "R7_R8"] == 0), all(ts_risk$log_history >= 0), all(ts_risk$freq %in% 1:5),
  all(is.na(ts_risk$qty) | ts_risk$qty %in% 1:5), all(ts_risk$hed6_0 %in% 0:1), !anyNA(ts_risk$signal0f))

# States, grams and signals.
stopifnot(!anyNA(ts_risk$state0), all(ts_W$state %in% ts_ST),
  all(is.finite(ts_risk$grams0[ts_risk$current0 == 1]) & ts_risk$grams0[ts_risk$current0 == 1] > 0),
  all(ts_risk$grams0[ts_risk$current0 == 0] == 0), max(ts_W$grams[ts_W$sex == "Men"]) < 100,
  all(vapply(c(20, 40, 60, 100), function(b) !any(ts_W$current %in% 1 & abs(ts_W$grams - b) < 1e-9), TRUE)), all(ts_W$cat[ts_W$grams > ifelse(ts_W$sex == "Women", 40, 60)] %in% "C3plus", na.rm = TRUE),   # no exact border values: WHO equals the earlier rule
  all(is.na(ts_risk$signal0) == (ts_risk$current0 == 0)), all(is.na(ts_W$signal) == (ts_W$current == 0)),
  all(ts_W$signal[ts_W$signal_ambiguous] == 0), all(ts_W$sex[ts_W$signal_ambiguous] == "Women"),
  all(ts_W$hed6[ts_W$current == 0] == 0), all(ts_W$state[ts_W$wave == 7 & ts_W$current == 0] == "N0"))
stopifnot(all(is.na(ts_risk$state1) == !ts_risk$linked), all(is.na(ts_risk$grams1) == !ts_risk$linked),
  all(is.na(ts_risk$hed6_1) == !ts_risk$linked), all(is.na(ts_risk$y1) == !ts_risk$linked), all(is.na(ts_risk$signal1[!ts_risk$linked])),
  all(is.na(ts_risk$signal1[ts_risk$linked]) == (ts_risk$state1[ts_risk$linked] %in% c("N0", "FD"))),
  all(ts_risk$y1[ts_risk$linked & ts_risk$state1 %in% c("N0", "FD")] == "NC"),
  all(as.character(ts_risk$y1[ts_risk$linked & !ts_risk$state1 %in% c("N0", "FD")]) == ts_risk$state1[ts_risk$linked & !ts_risk$state1 %in% c("N0", "FD")]))
cat("skip conflicts (e3a1 = 1 with e3a2 or e3a3 answered):", sum(ts_W$current == 0 & (!is.na(ts_W$e3a2) | !is.na(ts_W$e3a3))), "\n")
lk <- ts_risk[ts_risk$linked, ]
cat("transition map violations among linked pairs: non-N0 -> N0 =", sum(lk$state0 != "N0" & lk$state1 == "N0"),
    "; N0 -> FD =", sum(lk$state0 == "N0" & lk$state1 == "FD"), "\n")
stopifnot(!any(lk$state0 != "N0" & lk$state1 == "N0"), !any(lk$state0 == "N0" & lk$state1 == "FD"))

# Links (rule 4).
stopifnot(all(ts_risk$linked == (ts_risk$destination_present & ts_risk$compatible)), all(!ts_risk$compatible | ts_risk$destination_present))
ts_link <- ts_link_audit(ts_W, ts_risk); print(ts_link, row.names = FALSE)
ev <- ts_link_tolerance_evidence(ts_W); print(ev, row.names = FALSE)
stopifnot(ev$compatible_at_tolerance[ev$same_sex & ev$years_outside_strict_bounds == as.character(ts_link_tolerance)] == sum(ts_risk$compatible),
  sum(ev$pairs) == sum(ts_risk$destination_present))
stopifnot(all(ts_link$destination_present == ts_link$compatible + ts_link$incompatible),
  all(ts_link$incompatible == ts_link$incompatible_sex + ts_link$incompatible_age), sum(ts_link$compatible) == sum(ts_risk$linked))

# Education: only the four allowed levels; audit totals equal the wave rows.
for (rule in c("lenient", "strict", "reached")) stopifnot(all(is.na(ts_W[[paste0("edu_", rule)]]) | ts_W[[paste0("edu_", rule)]] %in% ts_edu_levels))
stopifnot(!anyNA(ts_risk$edu), all(ts_risk$edu %in% c(ts_edu_levels, "Missing")))
ts_edu <- ts_education_audit(ts_W)
detail <- ts_edu[!is.na(ts_edu$b4a), ]
stopifnot(all(tapply(detail$n, detail$rule, sum) == nrow(ts_W)))
print(stats::xtabs(n ~ level + rule, detail))
print(ts_edu[is.na(ts_edu$b4a), c("wave", "level", "n")], row.names = FALSE)
print(stats::xtabs(n ~ b4a + level, detail[detail$rule == "lenient" & detail$attending == 0, ]))

# History.
ts_hist <- ts_history_audit(ts_W); print(ts_hist, row.names = FALSE)
stopifnot(ts_hist$FD[ts_hist$wave == 7] == 0, all(ts_hist$N0 + ts_hist$FD + ts_hist$current == ts_hist$respondents),
  all(ts_hist$FD <= ts_hist$FD_any_history))

# Compact aggregate tables.
print(table(period = ts_risk$period, linked = ts_risk$linked))
print(table(period = ts_risk$period, state0 = ts_risk$state0))
print(table(origin = lk$state0, destination = factor(lk$state1, levels = ts_ST)))
print(table(signal0f = ts_risk$signal0f, hed6_0 = ts_risk$hed6_0))

# IPW: three stages, floor, clipping, period masses; refits on subsets and multiplicities.
t1 <- Sys.time(); ts_ip <- ts_ipw_fit(ts_risk); ts_d <- ts_ipw_apply(ts_risk, ts_ip)
cat(sprintf("IPW fit + apply on the full risk set: %.2f seconds\n", as.numeric(difftime(Sys.time(), t1, units = "secs"))))
stopifnot(identical(ts_ip$base$constant, 1), identical(ts_ip$final$constant, 1), is.null(ts_ip$link$constant), isTRUE(ts_ip$link$converged))
stopifnot(nrow(ts_d) == sum(ts_risk$complete), nrow(ts_d) == length(unique(ts_d$row_id)), all(ts_d$p_obs >= .02), all(ts_d$p_obs <= 1),
  all(is.finite(ts_d$wn) & ts_d$wn > 0), all(is.finite(ts_d$wcorrected) & ts_d$wcorrected > 0),
  all(ts_d$wcorrected <= ts_d$untrimmed + 1e-12 | ts_d$wcorrected >= ts_d$untrimmed - 1e-12))
mass <- tapply(ts_d$wn, ts_d$period, sum)
stopifnot(max(abs(mass - ts_period_mass[names(mass)])) < 1e-9)
ipw_audit <- do.call(rbind, lapply(split(ts_d, ts_d$period), function(d)
  data.frame(period = d$period[1], min_probability = min(d$p_obs), median_weight = stats::median(d$wn), max_weight = max(d$wn),
    clipped = sum(d$untrimmed != d$wcorrected), weight_ESS = sum(d$wn)^2 / sum(d$wn^2))))
print(ipw_audit, row.names = FALSE)
print(data.frame(term = names(ts_ip$link$coef), estimate = round(ts_ip$link$coef, 3)), row.names = FALSE)
set.seed(ts_seed); ids <- unique(ts_risk$id); fold <- stats::setNames(sample(rep(1:5, length.out = length(ids))), ids)
tr <- ts_risk[fold[ts_risk$id] != 1, ]; te <- ts_risk[fold[ts_risk$id] == 1, ]
nu <- ts_ipw_fit(tr); a <- ts_ipw_apply(tr, nu); b <- ts_ipw_apply(te, nu)
stopifnot(nrow(a) == sum(tr$complete), nrow(b) == sum(te$complete), all(is.finite(b$wn) & b$wn > 0), !length(intersect(a$id, b$id)))
r <- ts_risk; m <- tabulate(sample.int(length(ids), length(ids), replace = TRUE), nbins = length(ids)); r$mult <- m[match(r$id, ids)]
db <- ts_ipw_apply(r, ts_ipw_fit(r))
stopifnot(all(db$wn[db$mult == 0] == 0), all(db$wn[db$mult > 0] > 0), abs(sum(db$wn) - sum(ts_period_mass)) < 1e-9)
three <- ts_risk[ts_risk$period != "R10_R11", ]; nu3 <- ts_ipw_fit(three)
stopifnot(is.null(nu3$cap$R10_R11))
b4 <- ts_ipw_apply(ts_risk[ts_risk$period == "R10_R11", ], nu3)
stopifnot(nrow(b4) == ts_period_mass[["R10_R11"]], all(is.finite(b4$wn) & b4$wn > 0))
t2 <- Sys.time(); for (k in 1:5) invisible(ts_ipw_apply(ts_risk, ts_ipw_fit(ts_risk)))
cat(sprintf("IPW fit + apply, mean of 5 repeats: %.2f seconds\n", as.numeric(difftime(Sys.time(), t2, units = "secs")) / 5))

# Sensitivity variants of the wave table.
W157 <- ts_waves(15.7); stopifnot(nrow(W157) == nrow(ts_W), all(abs(W157$grams - ts_W$grams * 15.7 / 12) < 1e-9))
cat("C3plus rows at 15.7 g:", sum(W157$cat %in% "C3plus"), "; at 12 g:", sum(ts_W$cat %in% "C3plus"), "\n")
W16 <- ts_waves(top_quantity = 16); top <- W16$current == 1 & W16$qty %in% 5
stopifnot(all(W16$grams[top] > ts_W$grams[top]), all(W16$grams[!top] == ts_W$grams[!top]))
for (rule in c("strict", "reached")) { Wr <- ts_waves(education_rule = rule); stopifnot(identical(Wr$education, Wr[[paste0("edu_", rule)]])) }

# The inline cohort of the notebook cell (tsm-data-design) uses these columns.
ts_cohort <- do.call(rbind, lapply(ts_periods, function(p) {
  r <- ts_risk[ts_risk$period == p, ]; d <- ts_d[ts_d$period == p, ]; tm <- ts_time[ts_time$period == p, ]
  data.frame(period = p, months = tm$months, years = round(tm$years, 3), risk_set = nrow(r), destination_present = sum(r$destination_present),
    incompatible_links = sum(r$destination_present & !r$compatible), usable_pairs = nrow(d), persons = length(unique(d$id)),
    age_min = min(d$age), age_max = max(d$age), weight_ESS = round(sum(d$wn)^2 / sum(d$wn^2), 1))
}))
print(ts_cohort, row.names = FALSE)
cat("pairs:", nrow(ts_d), " persons:", length(unique(ts_d$id)), " persons with 4 pairs:", sum(table(ts_d$id) == 4), "\n")

# Display helpers only warn outside Jupyter; files must still be written.
ts_save(ts_link, "test_link_audit")
stopifnot(file.exists(file.path(ts_out, "test_link_audit.csv")))
ts_warn(ts_show(ts_cohort, "test caption"))
ts_warn(ts_fig(ggplot2::ggplot(ts_link, ggplot2::aes(period, compatible)) + ggplot2::geom_col(fill = ts_palette[["blue"]]) + ts_theme(),
  "test_link_audit", 6, 4))
stopifnot(file.exists(file.path(ts_out, "en", "test_link_audit.png")), file.exists(file.path(ts_out, "en", "test_link_audit.pdf")))
ts_check(TRUE, "data layer test"); stopifnot(isTRUE(ts_checks[["data layer test"]]))
cat("captured warnings:", length(ts_warnings), "\n")
cat("TSM_V3_DATA_LAYER_TEST=PASS\n")
cat(sprintf("Elapsed: %.2f minutes\n", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
