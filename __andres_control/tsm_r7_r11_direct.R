.t0 <- Sys.time()
# Exploratory, separate analysis: the same TSM people compared directly between R7 and R11 (about 24 months), with no
# intermediate interview required and no chaining or annualising of matrices. It only reuses the TSM v3 data layer
# (tsm_markov_data.R, TSM v4: five states, two-year link tolerance); no notebook or core file is modified. Run from the repository root, pinned to the E-cores on this
# PC. Writes aggregates only to __andres_control/tsm_r7_r11_direct_outputs/ (no person-level rows).
if (.Platform$OS.type == "windows") invisible(Sys.setlocale("LC_ALL", "English_United States.utf8"))
Sys.setenv(TSM_MARKOV_OUTPUT = ".quarto/tsm_r7_r11_scratch")   # ts_load() metadata goes to a git-ignored folder
ts_checks <- list(); ts_warnings <- character()
source(here::here("__andres_control", "tsm_markov_data.R"))
out <- here::here("__andres_control", "tsm_r7_r11_direct_outputs")
dir.create(out, showWarnings = FALSE, recursive = TRUE)
save_csv <- function(x, name) utils::write.csv(x, file.path(out, paste0(name, ".csv")), row.names = FALSE, na = "", fileEncoding = "UTF-8")
ts_load()
W <- ts_waves()
months <- ts_months(7, 11)
stopifnot(months == 24)

# ---- 1. Cohort and link steps -------------------------------------------------------------------------------------
a <- W[W$wave == 7 & W$age >= 18 & W$age <= 65, ]
b <- W[W$wave == 11, ]
j <- match(a$id, b$id); z <- b[j, ]; present <- !is.na(j)
link <- function(tol) present & ts_compatible(a$sex, z$sex, a$age, z$age, months, tol)
D <- data.frame(sex = factor(a$sex, c("Men", "Women")), age_group = ts_age(a$age),
  edu = factor(ifelse(is.na(a$education), "Missing", a$education), c(ts_edu_levels, "Missing")),
  w = a$weight_xs, present = present, linked = link(ts_link_tolerance), linked_strict = link(0L),
  origin = ifelse(a$state == "N0", "NC", a$state),
  dest = ifelse(link(ts_link_tolerance), ifelse(z$state %in% c("N0", "FD"), "NC", z$state), NA_character_),
  stringsAsFactors = FALSE)
D$origin[D$origin == "FD"] <- NA   # cannot occur at the first wave; kept as unclassified if it ever did
D$classified <- !is.na(D$origin) & !is.na(D$dest)
D$analyzable <- D$linked & D$classified
D$analyzable_strict <- D$linked_strict & !is.na(D$origin) & !is.na(ifelse(z$state %in% c("N0", "FD"), "NC", z$state))
stopifnot(!anyDuplicated(a$id), !anyNA(a$sex), !anyNA(a$weight_xs), all(a$weight_xs > 0), all(a$state %in% c("N0", "C1", "C2", "C3plus")))
steps <- data.frame(step = c("R7 respondents aged 18-65 at R7", "Interviewed again in R11 (any age or sex)",
  paste0("Link compatible, tolerance +-", ts_link_tolerance, " years (project rule, primary)"), "Analyzable: origin and destination classified",
  "Sensitivity: strict EPS link bounds (tolerance 0), analyzable"),
  n = c(nrow(D), sum(D$present), sum(D$linked), sum(D$analyzable), sum(D$analyzable_strict)))
save_csv(steps, "link_steps")
cat("link steps:\n"); print(steps, row.names = FALSE)

# ---- 2. Sample-size tables ------------------------------------------------------------------------------------------
flag_n <- function(n) ifelse(n == 0, "empty", ifelse(n < 10, "suppress(<10)", ifelse(n < 30, "small(<30)", "ok")))
size_row <- function(d, label) {
  an <- d[d$analyzable, ]
  data.frame(group = label, n_initial = nrow(d), n_observed_R11 = sum(d$present),
    pct_followup = 100 * sum(d$present) / nrow(d), n_link_dropped = sum(d$present & !d$linked),
    n_analyzable = nrow(an), pct_analyzable_of_initial = 100 * nrow(an) / nrow(d),
    n_unclassified_origin = sum(is.na(d$origin)), n_unclassified_destination = sum(d$linked & is.na(d$dest)),
    o_NC = sum(an$origin == "NC"), o_C1 = sum(an$origin == "C1"), o_C2 = sum(an$origin == "C2"),
    o_C3plus = sum(an$origin == "C3plus"), stringsAsFactors = FALSE)
}
sex_age <- do.call(rbind, c(lapply(levels(D$sex), function(s) do.call(rbind, c(
    lapply(levels(D$age_group), function(g) cbind(sex = s, age_group = g, size_row(D[D$sex == s & D$age_group == g, ], paste(s, g)))),
    list(cbind(sex = s, age_group = "All", size_row(D[D$sex == s, ], paste(s, "all"))))))),
  list(cbind(sex = "All", age_group = "All", size_row(D, "Total")))))
edu <- do.call(rbind, c(lapply(levels(D$edu), function(e) cbind(education = e, size_row(D[D$edu == e, ], e))),
  list(cbind(education = "All", size_row(D, "Total")))))
by_origin <- do.call(rbind, lapply(c("NC", "C1", "C2", "C3plus", "Unclassified"), function(o) {
  d <- if (o == "Unclassified") D[is.na(D$origin), ] else D[D$origin %in% o, ]
  data.frame(origin_R7 = o, n_initial = nrow(d), n_observed_R11 = sum(d$present), pct_followup = ifelse(nrow(d), 100 * sum(d$present) / nrow(d), NA),
    n_analyzable = sum(d$analyzable))
}))
edu_origin <- do.call(rbind, lapply(levels(D$edu), function(e) do.call(rbind, lapply(c("NC", "C1"), function(o) {
  d <- D[D$edu == e & D$origin %in% o, ]
  data.frame(education = e, origin_R7 = o, n_initial = nrow(d), n_observed_R11 = sum(d$present),
    pct_followup = ifelse(nrow(d), 100 * sum(d$present) / nrow(d), NA), n_analyzable = sum(d$analyzable))
}))))
for (nm in c("sex_age", "edu")) {
  x <- get(nm)
  x$flag_analyzable <- flag_n(x$n_analyzable); x$flag_o_NC <- flag_n(x$o_NC); x$flag_o_C1 <- flag_n(x$o_C1)
  assign(nm, x)
}
save_csv(sex_age, "sample_sex_age"); save_csv(edu, "sample_education")
save_csv(by_origin, "followup_by_origin"); save_csv(edu_origin, "followup_education_by_origin")
cat("sex x age:\n"); print(sex_age[c("group", "n_initial", "n_observed_R11", "pct_followup", "n_analyzable", "o_NC", "o_C1", "o_C2", "o_C3plus")], row.names = FALSE, digits = 3)
cat("education:\n"); print(edu[c("group", "n_initial", "n_observed_R11", "pct_followup", "n_analyzable", "o_NC", "o_C1", "o_C2")], row.names = FALSE, digits = 3)
cat("follow-up by origin:\n"); print(by_origin, row.names = FALSE, digits = 3)

# ---- 3. Observed 24-month transitions ----------------------------------------------------------------------------
# Estimates use the R7 cross-sectional weight (Fact_Exp) with no attrition correction (the TSM IPW is per short period and
# does not transfer to a 24-month link); the CI is a percentile person bootstrap over the analyzable pairs.
# Reliability rule (all tables): origin n = 0 empty; 1-9 counts only; 10-29 small, shown but flagged unstable; >= 30 reported.
AN <- D[D$analyzable, ]
AN$origin2 <- ifelse(AN$origin %in% c("C2", "C3plus"), "C2plus", AN$origin)
AN$dest2 <- ifelse(AN$dest %in% c("C2", "C3plus"), "C2plus", AN$dest)
dest_fine <- c("NC", "C1", "C2", "C3plus"); dest_coarse <- c("NC", "C1", "C2plus")
group_sets <- list(
  Global = function(d) rep("All", nrow(d)),
  Sex_age = function(d) paste(d$sex, d$age_group),
  Sex = function(d) as.character(d$sex),
  Education = function(d) as.character(d$edu))
all_groups <- list(Global = "All", Sex_age = as.vector(outer(levels(D$sex), levels(D$age_group), paste)), Sex = levels(D$sex), Education = levels(D$edu))
cells_for <- function(d, set, ocol, dcol, dlevels, olevels) {
  g <- factor(group_sets[[set]](d), levels = all_groups[[set]]); o <- factor(d[[ocol]], levels = olevels)
  key <- interaction(g, o, drop = FALSE, sep = "|", lex.order = TRUE)
  M <- vapply(dlevels, function(l) as.numeric(d[[dcol]] == l), numeric(nrow(d)))
  num <- rowsum(M * d$w, key, reorder = FALSE); den <- rowsum(d$w, key, reorder = FALSE)
  n <- as.vector(table(key)); lv <- levels(key)
  nm <- rowsum(M, key, reorder = FALSE)
  list(key = lv, n = n, counts = nm[match(lv, rownames(nm)), , drop = FALSE], wprop = num[match(lv, rownames(num)), , drop = FALSE] / as.vector(den[match(lv, rownames(den))]))
}
trans_table <- function(d, set, ocol, dcol, dlevels, olevels, B = 1000L) {
  est <- cells_for(d, set, ocol, dcol, dlevels, olevels)
  set.seed(ts_seed)
  boots <- array(NA_real_, c(length(est$key), length(dlevels), B))
  for (r in seq_len(B)) boots[, , r] <- cells_for(d[sample.int(nrow(d), replace = TRUE), ], set, ocol, dcol, dlevels, olevels)$wprop
  do.call(rbind, lapply(seq_along(est$key), function(i) {
    p <- strsplit(est$key[i], "|", fixed = TRUE)[[1]]
    do.call(rbind, lapply(seq_along(dlevels), function(k) {
      bk <- boots[i, k, ]
      data.frame(set = set, group = p[1], origin = p[2], destination = dlevels[k], n_origin = est$n[i], n_cell = est$counts[i, k],
        p_unweighted = ifelse(est$n[i] > 0, est$counts[i, k] / est$n[i], NA_real_), p_weighted = est$wprop[i, k],
        lo = unname(stats::quantile(bk, .025, na.rm = TRUE)), hi = unname(stats::quantile(bk, .975, na.rm = TRUE)),
        boot_valid = sum(!is.na(bk)), flag = flag_n(est$n[i]), stringsAsFactors = FALSE)
    }))
  }))
}
tr_global <- trans_table(AN, "Global", "origin", "dest", dest_fine, dest_fine)
tr_sexage <- rbind(trans_table(AN, "Global", "origin2", "dest2", dest_coarse, c("NC", "C1", "C2plus")),
  trans_table(AN, "Sex", "origin2", "dest2", dest_coarse, c("NC", "C1", "C2plus")),
  trans_table(AN, "Sex_age", "origin2", "dest2", dest_coarse, c("NC", "C1", "C2plus")))
tr_edu <- trans_table(AN, "Education", "origin2", "dest2", dest_coarse, c("NC", "C1", "C2plus"))
# Strict-link sensitivity on the pooled coarse matrix.
ANs <- D[D$analyzable_strict, ]
ANs$dest <- ifelse(z$state[D$analyzable_strict] %in% c("N0", "FD"), "NC", z$state[D$analyzable_strict])
ANs$origin2 <- ifelse(ANs$origin %in% c("C2", "C3plus"), "C2plus", ANs$origin)
ANs$dest2 <- ifelse(ANs$dest %in% c("C2", "C3plus"), "C2plus", ANs$dest)
tr_strict <- trans_table(ANs, "Global", "origin2", "dest2", dest_coarse, c("NC", "C1", "C2plus"))
tr_strict$set <- "Global_strict_link"
save_csv(tr_global, "transitions_global_fine"); save_csv(tr_sexage, "transitions_sex_age")
save_csv(tr_edu, "transitions_education"); save_csv(tr_strict, "transitions_global_strict_link")
cat("global fine:\n"); print(tr_global[tr_global$n_origin > 0, c("origin", "destination", "n_origin", "n_cell", "p_unweighted", "p_weighted", "lo", "hi")], row.names = FALSE, digits = 3)

# ---- 4. Model two-year predictions (point estimates) -------------------------------------------------------------
# Annual matrices of each model, squared (the model's own 2-year prediction under time homogeneity; the semigroup error
# of the annual matrices is ~0, so this equals exp(2Q)). Destinations collapsed as TSM v3 does: NC = N0 + FD.
# TSM has five states (C3plus); the EPS v1 engine keeps six (C3 and C4 apart). Both collapse to NC, C1, C2plus here.
as_mat <- function(x, ST) { P <- matrix(NA_real_, length(ST), length(ST), dimnames = list(ST, ST)); P[cbind(match(x$from, ST), match(x$to, ST))] <- x$estimate; miss <- is.na(P); P[miss] <- 0   # shortcut: an unobserved origin row (NA) is treated as absorbing; it only enters through the top cells, all in C2plus
  for (r in names(which(rowSums(miss) > 0))) P[r, r] <- 1
  list(P = P, unobserved_rows = names(which(rowSums(miss) > 0))) }
collapse2 <- function(P2) cbind(NC = P2[, "N0"] + P2[, "FD"], C1 = P2[, "C1"], C2plus = rowSums(P2[, 4:ncol(P2), drop = FALSE]))
ea <- utils::read.csv(here::here("__andres_control", "eps_markov_outputs", "annual_pooled_matrices_design_CI.csv"), stringsAsFactors = FALSE)
ta <- utils::read.csv(here::here("__andres_control", "tsm_markov_outputs_v4", "annual_pooled_matrices_person_CI.csv"), stringsAsFactors = FALSE)
pred <- do.call(rbind, lapply(list(list("EPS", ea, c("N0", "FD", "C1", "C2", "C3", "C4")), list("TSM", ta, ts_ST)), function(src) do.call(rbind, lapply(c("A", "Lognormal"), function(m) {
  ST <- src[[3]]; am <- as_mat(src[[2]][src[[2]]$model == m, ], ST); P <- am$P; P2 <- collapse2(P %*% P)
  ok <- setdiff(ST, am$unobserved_rows)   # origins with a defined row
  stopifnot(max(src[[2]]$semigroup_error[src[[2]]$model == m]) < 1e-6)
  stopifnot(all(abs(rowSums(P2)[c("N0", "FD", "C1")] - 1) < 1e-6))   # N0, FD, C1 origins are fully defined after squaring
  do.call(rbind, lapply(ST, function(o) data.frame(source = src[[1]], model = m, origin = o, destination = dest_coarse, p_2y = unname(P2[o, ]))))
}))))
save_csv(pred, "model_two_year_predictions")

# ---- 5. Comparison table -----------------------------------------------------------------------------------------
obs <- tr_sexage[tr_sexage$set == "Global" & tr_sexage$group == "All", ]
cmp <- do.call(rbind, lapply(c("NC", "C1"), function(o) do.call(rbind, lapply(dest_coarse, function(dd) {
  ob <- obs[obs$origin == o & obs$destination == dd, ]
  g <- function(s, m, oo) pred$p_2y[pred$source == s & pred$model == m & pred$origin == oo & pred$destination == dd]
  data.frame(origin_R7 = o, destination_R11 = dd, n_origin = ob$n_origin, n_cell = ob$n_cell,
    observed_unweighted = ob$p_unweighted, observed_weighted = ob$p_weighted, observed_lo = ob$lo, observed_hi = ob$hi,
    tsm_A_2y = g("TSM", "A", if (o == "NC") "N0" else o), tsm_Lognormal_2y = g("TSM", "Lognormal", if (o == "NC") "N0" else o),
    eps_A_2y_N0row = if (o == "NC") g("EPS", "A", "N0") else NA_real_, eps_A_2y_FDrow = if (o == "NC") g("EPS", "A", "FD") else NA_real_,
    eps_A_2y = if (o == "C1") g("EPS", "A", "C1") else NA_real_,
    eps_Lognormal_2y_N0row = if (o == "NC") g("EPS", "Lognormal", "N0") else NA_real_, eps_Lognormal_2y_FDrow = if (o == "NC") g("EPS", "Lognormal", "FD") else NA_real_,
    eps_Lognormal_2y = if (o == "C1") g("EPS", "Lognormal", "C1") else NA_real_, stringsAsFactors = FALSE)
}))))
save_csv(cmp, "comparison_observed_vs_models")
cat("comparison:\n"); print(cmp, row.names = FALSE, digits = 3)
stopifnot(all(abs(tapply(cmp$observed_weighted, cmp$origin_R7, sum) - 1) < 1e-9))
cat(sprintf("Elapsed: %.2f minutes\n", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
