.t0 <- Sys.time()
# ELSOC weighting scenarios: ponderador_long_total, ponderador_long_panel and unweighted, per interval.
# Reads the encrypted wide SAV through acc_data(); writes only aggregate tables prefixed "weights_" into
# `intervals/` (or ELSOC_WEIGHTS_OUTPUT); never modifies the published unweighted tables (checked by hash).
# Design and decisions: WEIGHTING_PLAN.md in this folder.
if (.Platform$OS.type == "windows") invisible(Sys.setlocale("LC_CTYPE", "English_United States.utf8"))
root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
while (!file.exists(file.path(root, ".acc_root")) && dirname(root) != root) root <- dirname(root)
stopifnot(file.exists(file.path(root, ".acc_root")))
source(file.path(root, "_tools", "acc_data.R")); root <- acc_root(root)
base <- file.path(root, "__andres_control", "elsoc_2021_2023_exploration")
pub <- file.path(base, "intervals")
out <- Sys.getenv("ELSOC_WEIGHTS_OUTPUT", unset = "")
out <- if (nzchar(out)) file.path(root, out) else pub
out_rel <- sub(paste0("^", root, "/?"), "", out)
dir.create(out, recursive = TRUE, showWarnings = FALSE)
options(survey.lonely.psu = "adjust")
stopifnot(all(vapply(c("haven", "tidyselect", "survey"), requireNamespace, logical(1), quietly = TRUE)))
B <- 1999L
seeds <- c("2016-2018" = 20231022L, "2018-2021" = 20231023L, "2021-2023" = 20231021L)
save_table <- function(x, name) utils::write.csv(x, file.path(out, paste0("weights_", name, ".csv")), row.names = FALSE, na = "", fileEncoding = "UTF-8")
read_pub <- function(name) utils::read.csv(file.path(pub, paste0(name, ".csv")), stringsAsFactors = FALSE)
pub_files <- list.files(pub, full.names = TRUE); pub_files <- pub_files[!grepl("^weights_", basename(pub_files))]
pub_hash <- tools::md5sum(pub_files)
file <- acc_data("_elsoc/elsoc_wide_2016_2023.tar.xz.enc")
provenance <- utils::read.csv(file.path(base, "tables", "provenance.csv"))
stopifnot(unname(tools::md5sum(file)) == provenance$md5)
meta <- haven::read_sav(file, n_max = 0, user_na = TRUE)
keep <- names(meta)[grepl("^(idencuesta|muestra|tipo_atricion|segmento_disenno|estrato_disenno)$|^(ola|fecha_entr|cuestion_completo)_w0[1-7]$|^(s09|s10|m0_sexo|m0_edad|m01|ponderador01|ponderador02|ponderador_long_total|ponderador_long_panel)_w0[1357]$", names(meta))]
d <- as.data.frame(haven::read_sav(file, col_select = tidyselect::all_of(keep), user_na = TRUE))
for (v in names(d)) if (is.numeric(d[[v]])) d[[v]] <- as.numeric(d[[v]])
stopifnot(!anyNA(d$idencuesta), !anyDuplicated(d$idencuesta), all(d$muestra %in% 1:2))
n_all <- nrow(d); ones <- rep(1, n_all)
getv <- function(v, w) d[[paste0(v, "_w", w)]]
present <- function(w) getv("ola", w) %in% 1
regular <- function(x) ifelse(x %in% 1:2, x, NA_real_)
frequency <- function(s09, s10) ifelse(s09 %in% 1 & s10 %in% 1:8, s10, NA_real_)
sample_label <- ifelse(d$muestra == 1, "M1", "M2")
seg <- as.character(d$segmento_disenno); strat <- d$estrato_disenno
stopifnot(all(tapply(strat, seg, function(z) length(unique(z))) == 1))
checks <- list(); check <- function(name, ok, kind = "data_check") { checks[[length(checks) + 1]] <<- data.frame(check = name, kind = kind, passed = isTRUE(ok)); if (!isTRUE(ok)) warning("Check failed: ", name, call. = FALSE) }
check("unique_longitudinal_ids", !anyDuplicated(d$idencuesta) && !anyNA(d$idencuesta)); check("md5_matches_published_provenance", unname(tools::md5sum(file)) == provenance$md5)
pairs <- data.frame(interval = c("2016-2018", "2018-2021", "2021-2023"), origin = c("01", "03", "05"), destination = c("03", "05", "07"), middle = c("02", "04", "06"), year0 = c(2016, 2018, 2021), year1 = c(2018, 2021, 2023), stringsAsFactors = FALSE)
groups_of <- function(sex, age_group, edu) {
  g <- list(All = rep(TRUE, n_all), M1 = sample_label == "M1", M2 = sample_label == "M2")
  for (s in c("Men", "Women")) for (a in c("18-29", "30-44", "45-59", "60-65")) g[[paste(s, a, sep = "_")]] <- sex == s & !is.na(age_group) & age_group == a
  for (e in c("Basic_or_less", "Secondary", "Higher", "Unknown")) g[[paste0("Education_", e)]] <- edu == e
  lapply(g, function(z) { z[is.na(z)] <- FALSE; z })
}
head_groups <- c("All", "M1", "M2", paste(rep(c("Men", "Women"), each = 4), c("18-29", "30-44", "45-59", "60-65"), sep = "_"))
summ <- function(x) { x <- x[is.finite(x)]; c(n = length(x), min = if (length(x)) min(x) else NA, q25 = if (length(x)) unname(stats::quantile(x, .25)) else NA, median = if (length(x)) stats::median(x) else NA, q75 = if (length(x)) unname(stats::quantile(x, .75)) else NA, max = if (length(x)) max(x) else NA, mean = if (length(x)) mean(x) else NA) }
ess_of <- function(w) if (length(w)) sum(w)^2 / sum(w^2) else NA_real_
smd <- function(p1, p2) ifelse(p1 == p2, 0, (p1 - p2) / sqrt((p1 * (1 - p1) + p2 * (1 - p2)) / 2))
all_tables <- list(); membership <- list()
add <- function(x, name, period) { all_tables[[name]] <<- rbind(all_tables[[name]], cbind(interval = period, x)) }
estimators <- data.frame(
  estimator = c("unweighted_general", "total_general", "unweighted_panel_subset", "panel_panel_subset", "total_panel_subset", "unweighted_general_minus_panel", "total_general_trimmed", "panel_panel_subset_trimmed", "total_panel_subset_trimmed", "total_general_origin_wave", "panel_panel_subset_origin_wave"),
  sample_set = c("general", "general", "panel_subset", "panel_subset", "panel_subset", "general_minus_panel", "general", "panel_subset", "panel_subset", "general", "panel_subset"),
  weight_family = c("none", "total", "none", "panel", "total", "none", "total", "panel", "total", "total", "panel"),
  weight_wave = c("none", "destination", "none", "destination", "destination", "none", "destination", "destination", "destination", "origin", "origin"),
  trimmed = c(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, TRUE, TRUE, FALSE, FALSE), main = c(rep(TRUE, 6), rep(FALSE, 5)), stringsAsFactors = FALSE)
contrasts <- data.frame(contrast = c("weighting_total_general", "weighting_panel_subset", "weight_variable_panel_subset", "selection_unweighted", "selection_unweighted_vs_lost", "selection_total_family", "scenario_difference"),
  a = c("total_general", "panel_panel_subset", "panel_panel_subset", "unweighted_panel_subset", "unweighted_panel_subset", "total_panel_subset", "panel_panel_subset"),
  b = c("unweighted_general", "unweighted_panel_subset", "total_panel_subset", "unweighted_general", "unweighted_general_minus_panel", "total_general", "total_general"), stringsAsFactors = FALSE)
pub_matrices <- read_pub("transition_matrices_unweighted"); pub_changes <- read_pub("change_summary_unweighted"); pub_net <- read_pub("paired_regular_share_change"); pub_flow <- read_pub("sample_flow")
reproduce_ok <- TRUE; same_num <- function(a, b, tol = 1e-9) (is.na(a) & is.na(b)) | (!is.na(a) & !is.na(b) & abs(a - b) <= tol)
for (pi in seq_len(nrow(pairs))) {
  p <- pairs[pi, ]; w0 <- p$origin; w1 <- p$destination; period <- p$interval
  date0 <- as.Date(getv("fecha_entr", w0), format = "%Y-%m-%d"); date1 <- as.Date(getv("fecha_entr", w1), format = "%Y-%m-%d")
  elapsed <- as.numeric(date1 - date0) / 365.2425
  age0 <- getv("m0_edad", w0); age1 <- getv("m0_edad", w1); sex0 <- getv("m0_sexo", w0); sex1 <- getv("m0_sexo", w1)
  baseline <- present(w0) & !is.na(age0) & age0 >= 18 & age0 <= 65; linked <- baseline & present(w1)
  year_ok <- !is.na(date0) & !is.na(date1) & date1 > date0 & as.integer(format(date0, "%Y")) == p$year0 & as.integer(format(date1, "%Y")) %in% if (w1 == "07") c(2023, 2024) else p$year1
  dates_present <- !is.na(date0) & !is.na(date1)
  valid_dates_pub <- year_ok                                   # published rule: both dates present, ordered, nominal years
  years1 <- if (w1 == "07") c(2023, 2024) else p$year1
  # User decision 21-10-2026: a missing interview date does not exclude the pair; any date that is present is still checked.
  dates_ok <- year_ok | (!dates_present & (is.na(date0) | as.integer(format(date0, "%Y")) == p$year0) & (is.na(date1) | as.integer(format(date1, "%Y")) %in% years1))
  sex_ok <- sex0 %in% 1:2 & sex1 %in% 1:2 & sex0 == sex1
  age_ok <- !is.na(age1 - age0 - elapsed) & abs(age1 - age0 - elapsed) <= 1.05
  dest_age_ok <- !is.na(age1) & age1 >= 18 & age1 <= 110
  quality_pub <- linked & sex_ok & valid_dates_pub & dest_age_ok
  quality <- linked & sex_ok & dates_ok & dest_age_ok
  strict_quality <- quality & dates_present & age_ok
  r0 <- regular(getv("s09", w0)); r1 <- regular(getv("s09", w1)); f0 <- frequency(getv("s09", w0), getv("s10", w0)); f1 <- frequency(getv("s09", w1), getv("s10", w1))
  rp_pub <- quality_pub & !is.na(r0) & !is.na(r1); fp_pub <- quality_pub & !is.na(f0) & !is.na(f1)
  rp <- quality & !is.na(r0) & !is.na(r1); fp <- quality & !is.na(f0) & !is.na(f1)
  w_total <- getv("ponderador_long_total", w1); w_panel <- getv("ponderador_long_panel", w1)
  w_total0 <- getv("ponderador_long_total", w0); w_panel0 <- getv("ponderador_long_panel", w0)
  panel <- is.finite(w_panel) & w_panel > 0
  check(paste0("panel_weight_equals_tipo_atricion_", period), identical(panel & linked, (d$tipo_atricion %in% 1) & linked))
  check(paste0("total_weight_positive_for_all_pairs_", period), all(is.finite(w_total[rp]) & w_total[rp] > 0) && all(is.finite(w_total0[rp]) & w_total0[rp] > 0))
  cap <- function(w, holders) { caps <- tapply(w[holders], sample_label[holders], stats::quantile, probs = .99, names = FALSE); pmin(w, caps[sample_label]) }
  w_total_trim <- cap(w_total, present(w1)); w_panel_trim <- cap(w_panel, present(w1) & panel)
  membership[[period]] <- list(s09 = rp, s10 = fp, primary = quality, panel_s09 = rp & panel, panel_s10 = fp & panel)
  for (s in c("M1", "M2")) for (fam in c("total", "panel")) { w <- if (fam == "total") w_total else w_panel
    for (item in c("s09", "s10")) { z <- (if (item == "s09") rp else fp) & sample_label == s; good <- z & is.finite(w) & w > 0
      add(data.frame(sample = s, weight_family = fam, variable = paste0("ponderador_long_", fam, "_w", w1), item = item, n = sum(z), positive = sum(good), missing = sum(z & is.na(w)), nonpositive = sum(z & !is.na(w) & w <= 0), sum_weight = sum(w[good]), ess = if (any(good)) ess_of(w[good]) else NA_real_, min = if (any(good)) min(w[good]) else NA_real_, max = if (any(good)) max(w[good]) else NA_real_), "coverage", period) } }
  age_group <- as.character(cut(age0, c(17, 29, 44, 59, 65), labels = c("18-29", "30-44", "45-59", "60-65")))
  tramo5 <- function(a) as.character(cut(a, c(17, 29, 39, 49, 59, 65, Inf), labels = c("18-29", "30-39", "40-49", "50-59", "60-65", "66+")))
  sex <- ifelse(sex0 == 1, "Men", ifelse(sex0 == 2, "Women", "Unknown"))
  education <- getv("m01", w0)
  edu <- ifelse(education %in% 1:4, "Basic_or_less", ifelse(education %in% c(5, 6, 8), "Secondary", ifelse(education %in% c(7, 9, 10), "Higher", "Unknown")))
  groups <- groups_of(sex, age_group, edu)
  # ---- flow, durations, unique persons -------------------------------------------------------------
  masks <- list(origin_participants = present(w0), destination_participants = present(w1), origin_age_missing = present(w0) & is.na(age0), origin_age18_65 = baseline,
    reinterviewed = linked, sex_consistent = linked & sex_ok, destination_date_missing = linked & sex_ok & is.na(date1), origin_date_missing = linked & sex_ok & !is.na(date1) & is.na(date0),
    date_order_or_year_invalid = linked & sex_ok & !dates_ok, kept_missing_date_links = quality & !dates_present, dates_valid_after_sex = linked & sex_ok & valid_dates_pub, primary_links_published_rule = quality_pub,
    primary_links = quality, strict_age_consistent_links = strict_quality, s09_classifiable_pairs = rp, regular_both = quality & r0 %in% 1 & r1 %in% 1, s10_classifiable_pairs = fp,
    panel_eligible_links = quality & panel, s09_pairs_panel_eligible = rp & panel, s10_pairs_panel_eligible = fp & panel, s09_pairs_general_minus_panel = rp & !panel,
    absent_middle_return = quality & !present(p$middle), destination_present_origin_absent = present(w1) & !present(w0))
  for (s in c("All", "M1", "M2")) {
    ss <- if (s == "All") rep(TRUE, n_all) else sample_label == s
    add(data.frame(sample = s, stage = names(masks), n = vapply(masks, function(z) sum(z & ss), 0L)), "sample_flow", period)
    for (set in c("general", "panel_subset", "general_minus_panel")) for (item in c("s09", "s10")) {
      z <- (if (item == "s09") rp else fp) & ss & switch(set, general = TRUE, panel_subset = panel, general_minus_panel = !panel)
      add(data.frame(sample = s, sample_set = set, item = item, n_pairs = sum(z), n_with_dates = sum(z & dates_present), t(summ(elapsed[z]))), "durations", period)
    }
  }
  for (st in c("origin_age18_65", "reinterviewed", "sex_consistent", "dates_valid_after_sex", "primary_links", "strict_age_consistent_links", "s09_classifiable_pairs", "regular_both", "s10_classifiable_pairs", "absent_middle_return")) {
    pub_n <- pub_flow$n[pub_flow$interval == period & pub_flow$sample == "All" & pub_flow$stage == st]
    mine <- if (st == "primary_links") sum(masks$primary_links_published_rule) else if (st == "strict_age_consistent_links") sum(quality_pub & age_ok) else if (st == "s09_classifiable_pairs") sum(rp_pub) else if (st == "regular_both") sum(quality_pub & r0 %in% 1 & r1 %in% 1) else if (st == "s10_classifiable_pairs") sum(fp_pub) else if (st == "absent_middle_return") sum(quality_pub & !present(p$middle)) else sum(masks[[st]])
    if (length(pub_n) != 1 || pub_n != mine) reproduce_ok <- FALSE
  }
  # ---- bootstrap replicates (same units and seeds as the published unweighted tables) ---------------
  units <- unique(data.frame(segment = seg[baseline], stratum = strat[baseline]))
  set.seed(seeds[[period]]); boot <- matrix(0, nrow(units), B)
  for (h in unique(units$stratum)) { ix <- which(units$stratum == h); stopifnot(length(ix) > 1); boot[ix, ] <- stats::rmultinom(B, length(ix), rep(1 / length(ix), length(ix))) }
  unit_index <- match(seg, units$segment)
  seg_totals <- function(x, z) { tot <- numeric(nrow(units)); if (any(z)) { a <- rowsum(x[z], unit_index[z]); tot[as.integer(rownames(a))] <- a }; tot }
  estimate_w <- function(den, num, w) {
    stopifnot(all(!num | den), length(w) == n_all, all(is.finite(w[den]) & w[den] > 0))
    n <- sum(den); k <- sum(num); g <- length(unique(seg[den])); sw <- sum(w[den]); sk <- sum(w[num])
    pr <- if (n) sk / sw else NA_real_; reps <- rep(NA_real_, B); lo <- hi <- NA_real_
    status <- if (!n) "empty_origin" else if (g < 10) "fewer_than_10_segments" else if (k == 0 || k == n) "boundary_no_interval" else "exploratory_segment_bootstrap"
    if (n && g >= 10 && k > 0 && k < n) {
      dd <- as.numeric(crossprod(seg_totals(w, den), boot)); nn <- as.numeric(crossprod(seg_totals(w, num), boot))
      reps <- ifelse(dd > 0, nn / dd, NA_real_)
      if (sum(!is.na(reps)) >= .95 * B) { ci <- stats::quantile(reps[!is.na(reps)], c(.025, .975), names = FALSE); lo <- ci[1]; hi <- ci[2] } else status <- "insufficient_bootstrap_support"
    }
    es <- if (n) ess_of(w[den]) else NA_real_
    list(row = data.frame(n_origin = n, n_event = k, n_segments = g, sum_w_origin = sw, sum_w_event = sk, ess_origin = es, estimate = pr, lower = lo, upper = hi,
      se_boot = if (any(!is.na(reps))) stats::sd(reps, na.rm = TRUE) else NA_real_, deff_boot = if (any(!is.na(reps)) && n && pr > 0 && pr < 1) stats::var(reps, na.rm = TRUE) / (pr * (1 - pr) / n) else NA_real_,
      small_origin = n < 30, rare_event = if (n) min(k, n - k) < 5 else TRUE, small_ess = if (n) es < 30 else TRUE, ci_status = status), reps = reps)
  }
  net_w <- function(z, w) {
    v <- as.numeric(r1 %in% 1) - as.numeric(r0 %in% 1); n <- sum(z); reps <- rep(NA_real_, B); ci <- c(NA_real_, NA_real_)
    if (n && length(unique(seg[z])) >= 10 && length(unique(v[z])) > 1) {
      dd <- as.numeric(crossprod(seg_totals(w, z), boot)); nn <- as.numeric(crossprod(seg_totals(w * v, z), boot))
      reps <- ifelse(dd > 0, nn / dd, NA_real_); ci <- stats::quantile(reps[!is.na(reps)], c(.025, .975), names = FALSE)
    }
    list(row = data.frame(n = n, sum_w = sum(w[z]), regular_origin = sum(z & r0 %in% 1), regular_destination = sum(z & r1 %in% 1), regular_origin_share = if (n) sum(w[z & r0 %in% 1]) / sum(w[z]) else NA_real_,
      regular_destination_share = if (n) sum(w[z & r1 %in% 1]) / sum(w[z]) else NA_real_, difference = if (n) sum(w[z] * v[z]) / sum(w[z]) else NA_real_, lower = ci[1], upper = ci[2]), reps = reps)
  }
  # ---- reproduce the published unweighted tables with the published rule before estimating anything ----
  for (g in names(groups)) for (item in c("s09", "s10")) {
    mask <- if (item == "s09") rp_pub else fp_pub; a <- if (item == "s09") r0 else f0; b <- if (item == "s09") r1 else f1; cats <- if (item == "s09") 1:2 else 1:8
    for (fr in cats) for (to in cats) {
      e <- estimate_w(mask & groups[[g]] & a %in% fr, mask & groups[[g]] & a %in% fr & b %in% to, ones)$row
      q <- pub_matrices[pub_matrices$interval == period & pub_matrices$group == g & pub_matrices$item == item & pub_matrices$from == fr & pub_matrices$to == to, ]
      if (nrow(q) != 1 || q$n_origin != e$n_origin || q$n_event != e$n_event || q$n_segments != e$n_segments || !same_num(q$estimate, e$estimate) || !same_num(q$lower, e$lower) || !same_num(q$upper, e$upper) || q$ci_status != e$ci_status) reproduce_ok <- FALSE
    }
    den <- mask & groups[[g]]; events <- if (item == "s09") list(same = r0 == r1, entry_regular = r0 == 2 & r1 == 1, exit_regular = r0 == 1 & r1 == 2) else list(same = f0 == f1, increase = f1 > f0, decrease = f1 < f0)
    for (ev in names(events)) {
      ee <- events[[ev]]; ee[is.na(ee)] <- FALSE; e <- estimate_w(den, den & ee, ones)$row
      q <- pub_changes[pub_changes$interval == period & pub_changes$group == g & pub_changes$item == item & pub_changes$event == ev, ]
      if (nrow(q) != 1 || q$n_origin != e$n_origin || q$n_event != e$n_event || !same_num(q$estimate, e$estimate) || !same_num(q$lower, e$lower) || !same_num(q$upper, e$upper)) reproduce_ok <- FALSE
    }
    if (item == "s09") {
      e <- net_w(mask & groups[[g]], ones)$row; q <- pub_net[pub_net$interval == period & pub_net$group == g, ]
      if (nrow(q) != 1 || q$n != e$n || q$regular_origin != e$regular_origin || !same_num(q$difference, e$difference) || !same_num(q$lower, e$lower) || !same_num(q$upper, e$upper)) reproduce_ok <- FALSE
    }
  }
  # ---- weights per estimator -------------------------------------------------------------------------
  weight_of <- function(id) switch(estimators$weight_family[estimators$estimator == id], none = ones,
    total = if (estimators$weight_wave[estimators$estimator == id] == "origin") w_total0 else if (estimators$trimmed[estimators$estimator == id]) w_total_trim else w_total,
    panel = if (estimators$weight_wave[estimators$estimator == id] == "origin") w_panel0 else if (estimators$trimmed[estimators$estimator == id]) w_panel_trim else w_panel)
  set_of <- function(id) switch(estimators$sample_set[estimators$estimator == id], general = rep(TRUE, n_all), panel_subset = panel, general_minus_panel = !panel)
  reps_store <- new.env()
  for (id in estimators$estimator) {
    w <- weight_of(id); inset <- set_of(id); tag <- data.frame(estimator = id, sample_set = estimators$sample_set[estimators$estimator == id], weight_variable = switch(estimators$weight_family[estimators$estimator == id], none = "none", total = paste0("ponderador_long_total_w", if (estimators$weight_wave[estimators$estimator == id] == "origin") w0 else w1), panel = paste0("ponderador_long_panel_w", if (estimators$weight_wave[estimators$estimator == id] == "origin") w0 else w1)), trimmed = estimators$trimmed[estimators$estimator == id])
    for (g in names(groups)) for (item in c("s09", "s10")) {
      mask <- (if (item == "s09") rp else fp) & inset & groups[[g]]; a <- if (item == "s09") r0 else f0; b <- if (item == "s09") r1 else f1; cats <- if (item == "s09") 1:2 else 1:8
      for (fr in cats) for (to in cats) {
        e <- estimate_w(mask & a %in% fr, mask & a %in% fr & b %in% to, w)
        add(cbind(tag, group = g, item = item, from = fr, to = to, e$row), "transition_matrices", period)
        if (item == "s09") assign(paste(id, g, item, fr, to, sep = "|"), e$reps, envir = reps_store)
      }
      events <- if (item == "s09") list(same = r0 == r1, entry_regular = r0 == 2 & r1 == 1, exit_regular = r0 == 1 & r1 == 2) else list(same = f0 == f1, increase = f1 > f0, decrease = f1 < f0)
      for (ev in names(events)) {
        ee <- events[[ev]]; ee[is.na(ee)] <- FALSE; e <- estimate_w(mask, mask & ee, w)
        add(cbind(tag, group = g, item = item, event = ev, e$row), "change_summary", period)
        assign(paste(id, g, item, "event", ev, sep = "|"), e$reps, envir = reps_store)
      }
      if (item == "s09") { e <- net_w(mask, w); add(cbind(tag, group = g, e$row), "paired_regular_share_change", period); assign(paste(id, g, "s09", "net", "net", sep = "|"), e$reps, envir = reps_store) }
    }
  }
  # ---- deltas on aligned replicates (main estimators) ----------------------------------------------
  quantity_keys <- rbind(data.frame(quantity = c("s09_same", "regular_stay", "nonregular_stay", "s09_entry_regular", "s09_exit_regular", "regular_net_change", "s10_same", "s10_increase", "s10_decrease"),
    key = c("s09|event|same", "s09|1|1", "s09|2|2", "s09|event|entry_regular", "s09|event|exit_regular", "s09|net|net", "s10|event|same", "s10|event|increase", "s10|event|decrease"), stringsAsFactors = FALSE))
  point_of <- function(id, g, qk) {
    parts <- strsplit(qk, "|", fixed = TRUE)[[1]]
    if (parts[2] == "event") { z <- all_tables$change_summary; z <- z[z$interval == period & z$estimator == id & z$group == g & z$item == parts[1] & z$event == parts[3], ]; c(z$estimate, z$n_origin) }
    else if (parts[2] == "net") { z <- all_tables$paired_regular_share_change; z <- z[z$interval == period & z$estimator == id & z$group == g, ]; c(z$difference, z$n) }
    else { z <- all_tables$transition_matrices; z <- z[z$interval == period & z$estimator == id & z$group == g & z$item == parts[1] & z$from == as.integer(parts[2]) & z$to == as.integer(parts[3]), ]; c(z$estimate, z$n_origin) }
  }
  for (ci in seq_len(nrow(contrasts))) for (g in names(groups)) for (qi in seq_len(nrow(quantity_keys))) {
    qk <- quantity_keys$key[qi]; ra <- get(paste(contrasts$a[ci], g, qk, sep = "|"), envir = reps_store); rb <- get(paste(contrasts$b[ci], g, qk, sep = "|"), envir = reps_store)
    pa <- point_of(contrasts$a[ci], g, qk); pb <- point_of(contrasts$b[ci], g, qk); dr <- ra - rb; ok <- sum(!is.na(dr))
    ci95 <- if (ok >= .95 * B) stats::quantile(dr[!is.na(dr)], c(.025, .975), names = FALSE) else c(NA_real_, NA_real_)
    add(data.frame(contrast = contrasts$contrast[ci], estimator_a = contrasts$a[ci], estimator_b = contrasts$b[ci], group = g, quantity = quantity_keys$quantity[qi], n_a = pa[2], n_b = pb[2], estimate_a = pa[1], estimate_b = pb[1], delta = pa[1] - pb[1], lower = ci95[1], upper = ci95[2], paired_replicates = ok,
      ci_status = if (ok >= .95 * B) "exploratory_segment_bootstrap" else "insufficient_bootstrap_support"), "deltas", period)
  }
  # ---- Taylor cross-check (main estimators, headline groups) ------------------------------------------
  base_rows <- which(baseline)
  for (id in estimators$estimator[estimators$main]) {
    w <- weight_of(id); inset <- set_of(id); wd <- ifelse(is.finite(w) & w > 0, w, 1)
    des <- survey::svydesign(ids = ~segment, strata = ~stratum, weights = ~wd, nest = TRUE, data = data.frame(segment = seg[base_rows], stratum = strat[base_rows], wd = wd[base_rows]))
    for (g in head_groups) {
      for (item in c("s09", "s10")) {
        mask <- (if (item == "s09") rp else fp) & inset & groups[[g]]; a <- if (item == "s09") r0 else f0; b <- if (item == "s09") r1 else f1
        tasks <- if (item == "s09") list(c("1|1", "s09|1|1"), c("2|2", "s09|2|2"), c("event|same", "s09|event|same"), c("event|entry_regular", "s09|event|entry_regular"), c("event|exit_regular", "s09|event|exit_regular")) else list(c("event|same", "s10|event|same"), c("event|increase", "s10|event|increase"), c("event|decrease", "s10|event|decrease"))
        for (tk in tasks) {
          parts <- strsplit(tk[1], "|", fixed = TRUE)[[1]]
          if (parts[1] == "event") { den <- mask; y <- switch(parts[2], same = a == b, entry_regular = a == 2 & b == 1, exit_regular = a == 1 & b == 2, increase = b > a, decrease = b < a) }
          else { den <- mask & a %in% as.integer(parts[1]); y <- b %in% as.integer(parts[2]) }
          y[is.na(y)] <- FALSE; n <- sum(den); if (n < 2) next
          dsub <- subset(des, den[base_rows]); dsub$variables$y <- as.numeric(y[base_rows][den[base_rows]])
          m <- tryCatch(survey::svymean(~y, dsub), error = function(e) NULL); if (is.null(m)) next
          qk <- quantity_keys$quantity[quantity_keys$key == tk[2]]; pt <- point_of(id, g, tk[2]); rr <- get(paste(id, g, tk[2], sep = "|"), envir = reps_store); sb <- if (any(!is.na(rr))) stats::sd(rr, na.rm = TRUE) else NA_real_
          add(data.frame(estimator = id, group = g, quantity = qk, n_origin = n, estimate = pt[1], estimate_taylor = as.numeric(stats::coef(m)), se_boot = sb, se_taylor = as.numeric(survey::SE(m)), se_ratio = sb / as.numeric(survey::SE(m)), se_ratio_flag = is.na(sb) | sb / as.numeric(survey::SE(m)) > 1.25 | sb / as.numeric(survey::SE(m)) < .8), "taylor_check", period)
        }
      }
    }
  }
  # ---- composition: official check and EPS-style balance -------------------------------------------
  for (w in w0) for (s in c("M1", "M2")) {   # origin wave only: at destination the pairs exceed 65 while the reference domains stop there
    aw <- getv("m0_edad", w); sw <- getv("m0_sexo", w); hold <- is.finite(getv("ponderador_long_panel", w)) & getv("ponderador_long_panel", w) > 0
    doms <- list(wave_age18_65 = present(w) & sample_label == s & !is.na(aw) & aw >= 18 & aw <= 65, balanced_panel_age18_65 = present(w) & sample_label == s & !is.na(aw) & aw >= 18 & aw <= 65 & hold, s09_pairs = rp & sample_label == s, s09_pairs_panel_subset = rp & panel & sample_label == s)
    if (!any(doms$s09_pairs)) next
    tr_levels <- c("18-29", "30-39", "40-49", "50-59", "60-65", "66+")
    shares <- lapply(doms, function(z) { tb <- table(factor(sw[z], levels = 1:2), factor(tramo5(aw[z]), levels = tr_levels)); as.numeric(tb) / sum(tb) })
    add(data.frame(wave = w, sample = s, sex = rep(c("Men", "Women"), times = 6), tramo = rep(tr_levels, each = 2), n_wave = sum(doms$wave_age18_65), n_panel = sum(doms$balanced_panel_age18_65), n_pairs = sum(doms$s09_pairs), share_wave = shares$wave_age18_65, share_panel = shares$balanced_panel_age18_65, share_pairs = shares$s09_pairs, share_pairs_panel_subset = shares$s09_pairs_panel_subset,
      smd_pairs_vs_wave = smd(shares$s09_pairs, shares$wave_age18_65), smd_pairs_vs_panel = smd(shares$s09_pairs, shares$balanced_panel_age18_65)), "composition_official", period)
  }
  covs <- list(sex = sex, age_group = age_group, sample = sample_label, education = edu, s09_origin = ifelse(r0 %in% 1, "regular", ifelse(r0 %in% 2, "non_regular", "unknown")))
  bal <- list()
  for (id in estimators$estimator[estimators$main]) { w <- weight_of(id); z <- rp & set_of(id)
    for (cv in names(covs)) for (lv in sort(unique(covs[[cv]][rp]))) { if (is.na(lv)) next; bal[[length(bal) + 1]] <- data.frame(estimator = id, covariate = cv, level = lv, n = sum(z & covs[[cv]] %in% lv), share = sum(w[z & covs[[cv]] %in% lv]) / sum(w[z])) } }
  bal <- do.call(rbind, bal); add(bal, "composition_balance", period)
  for (ci in seq_len(nrow(contrasts))) { za <- bal[bal$estimator == contrasts$a[ci], ]; zb <- bal[bal$estimator == contrasts$b[ci], ]; m <- merge(za, zb, by = c("covariate", "level"), suffixes = c("_a", "_b"))
    add(data.frame(contrast = contrasts$contrast[ci], covariate = m$covariate, level = m$level, share_a = m$share_a, share_b = m$share_b, smd = smd(m$share_a, m$share_b)), "composition_smd", period) }
  # ---- diagnostics, trimming, by-stratum ---------------------------------------------------------------
  for (id in estimators$estimator) for (item in c("s09", "s10")) { w <- weight_of(id); z <- (if (item == "s09") rp else fp) & set_of(id); x <- w[z]; if (!length(x)) next
    add(data.frame(estimator = id, item = item, n = length(x), sum_w = sum(x), ess = ess_of(x), unequal_weighting_effect = length(x) / ess_of(x), mean_w = mean(x), median_w = stats::median(x), max_w = max(x), max_over_mean = max(x) / mean(x), top1_share = sum(sort(x, decreasing = TRUE)[seq_len(max(1, floor(.01 * length(x))))]) / sum(x), n_at_cap = if (grepl("trimmed", id)) sum(x >= max(x) - 1e-12) else NA_integer_), "diagnostics", period) }
  for (fam in c("total", "panel")) for (s in c("M1", "M2")) { w <- if (fam == "total") w_total else w_panel; z <- rp & sample_label == s & (fam == "total" | panel); if (!any(z)) next
    for (h in sort(unique(strat[z]))) { x <- w[z & strat == h]; add(data.frame(weight_family = fam, sample = s, stratum = h, n = length(x), median_w = stats::median(x), p05 = stats::quantile(x, .05, names = FALSE), p95 = stats::quantile(x, .95, names = FALSE), max_w = max(x)), "by_stratum", period) } }
  for (fam in c("total", "panel")) for (s in c("M1", "M2")) { w <- if (fam == "total") w_total else w_panel; wt <- if (fam == "total") w_total_trim else w_panel_trim; z <- rp & sample_label == s & (fam == "total" | panel); if (!any(z)) next
    capv <- max(wt[z]); sh <- function(ww) { tb <- tapply(ww[z], list(factor(sex0[z], levels = 1:2), factor(tramo5(age0[z]), levels = c("18-29", "30-39", "40-49", "50-59", "60-65"))), sum); tb[is.na(tb)] <- 0; as.numeric(tb) / sum(tb) }
    add(data.frame(weight_family = fam, sample = s, cap_p99 = unname(capv), n_pairs = sum(z), n_capped = sum(w[z] > capv), ess_untrimmed = ess_of(w[z]), ess_trimmed = ess_of(wt[z]), max_abs_shift_sex_tramo_share = max(abs(sh(w) - sh(wt))), mean_abs_shift_sex_tramo_share = mean(abs(sh(w) - sh(wt)))), "trimming", period) }
  # ---- sensitivity of the rule change (published rule vs kept missing dates), unweighted ---------------
  for (item in c("s09", "s10")) { a <- if (item == "s09") r0 else f0; b <- if (item == "s09") r1 else f1
    for (rule in c("published_rule", "missing_dates_kept")) { z <- if (rule == "published_rule") (if (item == "s09") rp_pub else fp_pub) else (if (item == "s09") rp else fp)
      add(data.frame(rule = rule, item = item, n = sum(z), same = sum(z & a == b, na.rm = TRUE) / sum(z), stay_1 = sum(z & a == 1 & b == 1) / sum(z & a == 1), stay_2 = sum(z & a == 2 & b == 2) / sum(z & a == 2)), "rule_sensitivity", period) } }
  message(sprintf("%s done: S09 pairs %d (published rule %d), S10 %d, panel subset %d. %.1f min", period, sum(rp), sum(rp_pub), sum(fp), sum(rp & panel), as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
}
check("flow_counts_and_published_unweighted_tables_reproduced", reproduce_ok)
# ---- headline comparison and shift tables -----------------------------------------------------------
tm <- all_tables$transition_matrices; cs <- all_tables$change_summary; nt <- all_tables$paired_regular_share_change; tc <- all_tables$taylor_check
pick <- function(period, id, g, q) {
  if (q %in% c("regular_stay", "nonregular_stay")) { fr <- if (q == "regular_stay") 1 else 2; z <- tm[tm$interval == period & tm$estimator == id & tm$group == g & tm$item == "s09" & tm$from == fr & tm$to == fr, ]; data.frame(n = z$n_origin, ess = z$ess_origin, estimate = z$estimate, lower = z$lower, upper = z$upper, se_boot = z$se_boot, deff_boot = z$deff_boot, ci_status = z$ci_status) }
  else if (q == "regular_net_change") { z <- nt[nt$interval == period & nt$estimator == id & nt$group == g, ]; data.frame(n = z$n, ess = NA_real_, estimate = z$difference, lower = z$lower, upper = z$upper, se_boot = NA_real_, deff_boot = NA_real_, ci_status = ifelse(is.na(z$lower), "no_interval", "exploratory_segment_bootstrap")) }
  else { item <- substr(q, 1, 3); ev <- sub("^s(09|10)_", "", q); z <- cs[cs$interval == period & cs$estimator == id & cs$group == g & cs$item == item & cs$event == ev, ]; data.frame(n = z$n_origin, ess = z$ess_origin, estimate = z$estimate, lower = z$lower, upper = z$upper, se_boot = z$se_boot, deff_boot = z$deff_boot, ci_status = z$ci_status) }
}
comparison <- list()
for (period in pairs$interval) for (g in head_groups) for (q in c("s09_same", "regular_stay", "nonregular_stay", "regular_net_change", "s10_same", "s10_increase", "s10_decrease")) for (id in estimators$estimator) {
  z <- pick(period, id, g, q); if (!nrow(z)) next
  tz <- tc[tc$interval == period & tc$estimator == id & tc$group == g & tc$quantity == q, ]
  comparison[[length(comparison) + 1]] <- cbind(data.frame(interval = period, group = g, quantity = q, estimator = id, sample_set = estimators$sample_set[estimators$estimator == id], weight_family = estimators$weight_family[estimators$estimator == id], weight_wave = estimators$weight_wave[estimators$estimator == id], trimmed = estimators$trimmed[estimators$estimator == id]), z, width = z$upper - z$lower,
    se_taylor = if (nrow(tz)) tz$se_taylor else NA_real_, se_ratio = if (nrow(tz)) tz$se_ratio else NA_real_, se_ratio_flag = if (nrow(tz)) tz$se_ratio_flag else NA)
}
all_tables$comparison <- do.call(rbind, comparison)
shift <- list()
for (period in pairs$interval) for (item in c("s09", "s10")) for (ci in seq_len(nrow(contrasts))) {
  za <- tm[tm$interval == period & tm$item == item & tm$estimator == contrasts$a[ci] & tm$group %in% head_groups, ]; zb <- tm[tm$interval == period & tm$item == item & tm$estimator == contrasts$b[ci] & tm$group %in% head_groups, ]
  m <- merge(za, zb, by = c("group", "from", "to"), suffixes = c("_a", "_b")); m <- m[m$n_origin_a > 0 & m$n_origin_b > 0, ]; if (!nrow(m)) next
  sh <- abs(m$estimate_a - m$estimate_b); i <- which.max(sh)
  shift[[length(shift) + 1]] <- data.frame(interval = period, item = item, contrast = contrasts$contrast[ci], cells = nrow(m), mean_abs_shift = mean(sh), max_abs_shift = sh[i], max_cell = sprintf("%s %d->%d", m$group[i], m$from[i], m$to[i]), max_cell_n_origin_a = m$n_origin_a[i], max_cell_n_origin_b = m$n_origin_b[i], estimate_a = m$estimate_a[i], estimate_b = m$estimate_b[i])
}
all_tables$shift_table <- do.call(rbind, shift)
# ---- unique persons across intervals, documentation ------------------------------------------------
uq <- list()
for (item in c("primary", "s09", "s10", "panel_s09", "panel_s10")) { mm <- sapply(membership, function(x) x[[item]]); uq[[length(uq) + 1]] <- data.frame(item = item, n_pairs_total = sum(mm), n_unique_persons = sum(rowSums(mm) > 0), n_in_two_intervals = sum(rowSums(mm) == 2), n_in_three_intervals = sum(rowSums(mm) == 3)) }
all_tables$unique_persons <- do.call(rbind, uq)
cv <- all_tables$coverage; doc <- list()
for (pi in seq_len(nrow(pairs))) for (s in c("M1", "M2")) for (fam in c("total", "panel")) {
  period <- pairs$interval[pi]; w1 <- pairs$destination[pi]; w0 <- pairs$origin[pi]; vn <- paste0("ponderador_long_", fam, "_w", w1)
  z9 <- cv[cv$interval == period & cv$sample == s & cv$weight_family == fam & cv$item == "s09", ]; z10 <- cv[cv$interval == period & cv$sample == s & cv$weight_family == fam & cv$item == "s10", ]
  if (!nrow(z9) || z9$n == 0) next
  co <- all_tables$composition_official; co <- co[co$interval == period & co$wave == w0 & co$sample == s, ]   # origin wave: like-for-like age window
  doc[[length(doc) + 1]] <- data.frame(interval = period, sample = s, weight_family = fam, variable = vn, weight_wave = w1, file = "ELSOC_Wide_2016_2023.sav", dataverse = "doi:10.7910/DVN/LD4BPH version 3.0 (2024-12-27)", md5 = provenance$md5,
    population = if (fam == "total") "all respondents of the wave within the sample" else "balanced panel of the sample (all waves through 2023) = tipo_atricion==1",
    participation_pattern = if (fam == "total") "any pattern incl. returns; adjusts P(present at wave | first-wave participant)" else "present at every wave of the cohort",
    components = "design weight; first wave: block non-response; later waves: GEE participation cells (quartile x stratum x year); p5/p95 trim once over all waves; raking INE urban 18+ sex x 5 age bands per year; rescaled to n per sample x wave",
    origin_is_first_wave_of_sample = (s == "M1" && period == "2016-2018") || (s == "M2" && period == "2018-2021"),
    n_s09_pairs = z9$n, positive_s09 = z9$positive, missing_s09 = z9$missing, nonpositive_s09 = z9$nonpositive, sum_s09 = z9$sum_weight, ess_s09 = z9$ess, min_s09 = z9$min, max_s09 = z9$max,
    n_s10_pairs = z10$n, positive_s10 = z10$positive, missing_s10 = z10$missing, nonpositive_s10 = z10$nonpositive,
    official_check_max_smd_pairs_vs_wave = if (nrow(co)) max(abs(co$smd_pairs_vs_wave)) else NA_real_, official_check_max_smd_pairs_vs_panel = if (nrow(co)) max(abs(co$smd_pairs_vs_panel)) else NA_real_,
    source_report = "Ponderadores longitudinales ELSOC, Equipo ELSOC, marzo 2023 (pondedradores-long-elsoc.netlify.app)", source_code = "github.com/elsoc-coes/ponderadores-long commit 475c7e32 (data 2016-2022); 2023 run not published",
    decision = if (fam == "total") "scenario 1: destination-wave weight on the general pair sample" else "scenario 2: destination-wave weight on the panel-eligible subset (documented selection)")
}
all_tables$documentation <- do.call(rbind, doc)
# ---- validation ------------------------------------------------------------------------------------------
for (period in pairs$interval) for (id in estimators$estimator) { z <- tm[tm$interval == period & tm$estimator == id, ]
  for (item in c("s09", "s10")) for (g in unique(z$group)) { y <- z[z$item == item & z$group == g, ]; for (fr in unique(y$from)) { a <- y[y$from == fr, ]; if (a$n_origin[1] > 0) { if (abs(sum(a$estimate) - 1) > 1e-9 || sum(a$n_event) != a$n_origin[1] || abs(sum(a$sum_w_event) - a$sum_w_origin[1]) > 1e-6) check(paste("row_sums", period, id, item, g, fr), FALSE) } } } }
check("weighted_rows_sum_to_one_and_events_to_origin", all(vapply(checks, function(x) x$passed, TRUE)))
check("deltas_paired_on_full_length_replicates", all(all_tables$deltas$paired_replicates <= B) && all(is.na(all_tables$deltas$lower) == (all_tables$deltas$paired_replicates < .95 * B)), kind = "identity")
check("taylor_available_for_headline_cells", nrow(tc) > 0 && all(is.finite(tc$se_taylor)))
check("missing_date_pairs_kept_not_excluded", { fl <- all_tables$sample_flow; all(fl$n[fl$stage == "primary_links"] - fl$n[fl$stage == "primary_links_published_rule"] == fl$n[fl$stage == "kept_missing_date_links"]) && all(fl$n[fl$stage == "kept_missing_date_links"] <= fl$n[fl$stage == "destination_date_missing"] + fl$n[fl$stage == "origin_date_missing"]) }, kind = "identity")
check("no_pooled_independence_assumption", TRUE, kind = "declaration")
check("published_tables_unchanged", identical(pub_hash, tools::md5sum(pub_files)))
all_tables$validation <- do.call(rbind, checks)
all_tables$configuration <- data.frame(bootstrap_replicates = B, seeds = paste(names(seeds), seeds, sep = "=", collapse = "; "), weight_wave = "destination (origin-wave as sensitivity)", trimming = "none in main; sensitivity cap at p99 within destination wave x sample, no re-raking",
  taylor = "survey::svydesign(ids=segmento_disenno, strata=estrato_disenno, nest=TRUE) on the baseline domain, subset() to each cell; lonely PSU adjust", date_rule = "missing interview date does not exclude a pair (user decision 2026-10-21); published rule kept as validation and sensitivity",
  estimators = paste(estimators$estimator, collapse = "; "), contrasts = paste(contrasts$contrast, collapse = "; "), sav_md5 = provenance$md5, output_dir = out_rel)
all_tables$estimators <- estimators; all_tables$contrasts <- contrasts
for (name in names(all_tables)) save_table(all_tables[[name]], name)
utils::capture.output(utils::sessionInfo(), file = file.path(out, "weights_session_info.txt"))
message(sprintf("Weighting scenarios finished: %d tables written to %s. Elapsed %.2f minutes.", length(all_tables), out_rel, as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
