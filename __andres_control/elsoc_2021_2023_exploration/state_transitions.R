.t0 <- Sys.time()
# ELSOC transition matrices with non-regular use as a state: NR (S09 = 2) plus the eight original S10 categories of
# regular drinkers (F1 = <1 day/week ... F8 = 7 days/week). Three estimators, as in the EPS engine:
#   Observed  = survey-weighted proportions;
#   A         = matrix model with the EPS hierarchical shrinkage (cell -> sex -> interval -> all intervals), k tuned by
#               person-blocked cross-validation (eps_markov_core.R: ep_Afit, ep_tune);
#   Lognormal = two-part model (EPS ep_fit): logit for being regular at destination, then an interval-censored
#               lognormal for days per week among regular drinkers, integrated over the S10 category limits.
# Three weights (none, ponderador_long_total and ponderador_long_panel of the destination wave), by interval x sex x
# initial age and pooled over intervals. Uncertainty: one stratified bootstrap of design segments shared by the three
# intervals, so all pairs of a person move together; Taylor (strata + segments, and clustered by person) for Observed.
# Reads the encrypted SAV through acc_data(); writes aggregate tables "states_*" into intervals/ (or
# ELSOC_STATES_OUTPUT). Design notes: WEIGHTING_PLAN.md and hallazgos_elsoc_ponderacion.md.
if (.Platform$OS.type == "windows") invisible(Sys.setlocale("LC_CTYPE", "English_United States.utf8"))
root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
while (!file.exists(file.path(root, ".acc_root")) && dirname(root) != root) root <- dirname(root)
stopifnot(file.exists(file.path(root, ".acc_root")))
source(file.path(root, "_tools", "acc_data.R")); root <- acc_root(root)
base <- file.path(root, "__andres_control", "elsoc_2021_2023_exploration")
pub <- file.path(base, "intervals")
out <- Sys.getenv("ELSOC_STATES_OUTPUT", unset = ""); out <- if (nzchar(out)) file.path(root, out) else pub
out_rel <- sub(paste0("^", root, "/?"), "", out)
dir.create(out, recursive = TRUE, showWarnings = FALSE)
options(survey.lonely.psu = "adjust")
stopifnot(all(vapply(c("haven", "tidyselect", "survey", "survival"), requireNamespace, logical(1), quietly = TRUE)))
B <- as.integer(Sys.getenv("ELSOC_STATES_B", unset = "1999"))
# EPS grid (10..1000) extended to 3000 and 10000: with the weighted schemes the cross-validated optimum sat at 1000.
seed_boot <- 20231024L; seed_cv <- 1240138L; K_folds <- 5L; n_repeats <- 3L; kgrid <- c(10, 30, 100, 300, 1000, 3000, 10000)
ST <- c("NR", paste0("F", 1:8)); NS <- length(ST)
st_label <- c(NR = "Non-regular", F1 = "<1 day/week", F2 = "1 day/week", F3 = "2 days/week", F4 = "3 days/week",
  F5 = "4 days/week", F6 = "5 days/week", F7 = "6 days/week", F8 = "7 days/week")
IV <- c("2016-2018", "2018-2021", "2021-2023")
SA <- paste(rep(c("Men", "Women"), each = 4), c("18-29", "30-44", "45-59", "60-65"), sep = "_")
SCHEMES <- c("unweighted", "total", "panel")
save_table <- function(x, name) { dbl <- vapply(x, is.double, TRUE); x[dbl] <- lapply(x[dbl], signif, 7)
  utils::write.csv(x, file.path(out, paste0("states_", name, ".csv")), row.names = FALSE, na = "", fileEncoding = "UTF-8") }
pub_files <- list.files(pub, full.names = TRUE); pub_files <- pub_files[!grepl("^states_", basename(pub_files))]
pub_hash <- tools::md5sum(pub_files)
checks <- list(); check <- function(name, ok, kind = "data_check") { checks[[length(checks) + 1]] <<- data.frame(check = name, kind = kind, passed = isTRUE(ok)); if (!isTRUE(ok)) warning("Check failed: ", name, call. = FALSE) }

# ---- pairs: same rules as weight_scenarios.R -------------------------------------------------------------------------
file <- acc_data("_elsoc/elsoc_wide_2016_2023.tar.xz.enc")
provenance <- utils::read.csv(file.path(base, "tables", "provenance.csv"))
check("md5_matches_published_provenance", unname(tools::md5sum(file)) == provenance$md5)
meta <- haven::read_sav(file, n_max = 0, user_na = TRUE)
keep <- names(meta)[grepl("^(idencuesta|muestra|segmento_disenno|estrato_disenno)$|^(ola|fecha_entr)_w0[1-7]$|^(s09|s10|m0_sexo|m0_edad|ponderador_long_total|ponderador_long_panel)_w0[1357]$", names(meta))]
d <- as.data.frame(haven::read_sav(file, col_select = tidyselect::all_of(keep), user_na = TRUE))
for (v in names(d)) if (is.numeric(d[[v]])) d[[v]] <- as.numeric(d[[v]])
check("unique_longitudinal_ids", !anyNA(d$idencuesta) && !anyDuplicated(d$idencuesta))
getv <- function(v, w) d[[paste0(v, "_w", w)]]
present <- function(w) getv("ola", w) %in% 1
regular <- function(x) ifelse(x %in% 1:2, x, NA_real_)
state_of <- function(s09, s10) ifelse(s09 %in% 2, "NR", ifelse(s09 %in% 1 & s10 %in% 1:8, paste0("F", s10), NA_character_))
stopifnot(identical(state_of(c(2, 1, 1, 1, -888), c(NA, 3, -999, 8, NA)), c("NR", "F3", NA, "F8", NA)))
sample_label <- ifelse(d$muestra == 1, "M1", "M2"); seg <- as.character(d$segmento_disenno); strat <- d$estrato_disenno
pairs <- data.frame(interval = IV, origin = c("01", "03", "05"), destination = c("03", "05", "07"), year0 = c(2016, 2018, 2021), year1 = c(2018, 2021, 2023), stringsAsFactors = FALSE)
flow_pub <- utils::read.csv(file.path(pub, "weights_sample_flow.csv"), stringsAsFactors = FALSE)
s_pub <- utils::read.csv(file.path(pub, "weights_transition_matrices.csv"), stringsAsFactors = FALSE)
rows <- flow <- base_units <- list(); reproduce_ok <- TRUE
for (pi in seq_len(nrow(pairs))) {
  p <- pairs[pi, ]; w0 <- p$origin; w1 <- p$destination
  date0 <- as.Date(getv("fecha_entr", w0), format = "%Y-%m-%d"); date1 <- as.Date(getv("fecha_entr", w1), format = "%Y-%m-%d")
  age0 <- getv("m0_edad", w0); age1 <- getv("m0_edad", w1); sex0 <- getv("m0_sexo", w0); sex1 <- getv("m0_sexo", w1)
  baseline <- present(w0) & !is.na(age0) & age0 >= 18 & age0 <= 65; linked <- baseline & present(w1)
  years1 <- if (w1 == "07") c(2023, 2024) else p$year1
  dates_present <- !is.na(date0) & !is.na(date1)
  year_ok <- dates_present & date1 > date0 & as.integer(format(date0, "%Y")) == p$year0 & as.integer(format(date1, "%Y")) %in% years1
  # A missing interview date does not exclude the pair (user decision 21-10-2026); a present date is still checked.
  dates_ok <- year_ok | (!dates_present & (is.na(date0) | as.integer(format(date0, "%Y")) == p$year0) & (is.na(date1) | as.integer(format(date1, "%Y")) %in% years1))
  sex_ok <- sex0 %in% 1:2 & sex1 %in% 1:2 & sex0 == sex1
  quality <- linked & sex_ok & dates_ok & !is.na(age1) & age1 >= 18 & age1 <= 110
  rp <- quality & !is.na(regular(getv("s09", w0))) & !is.na(regular(getv("s09", w1)))
  s0 <- state_of(getv("s09", w0), getv("s10", w0)); s1 <- state_of(getv("s09", w1), getv("s10", w1))
  g9 <- rp & !is.na(s0) & !is.na(s1)
  w_total <- getv("ponderador_long_total", w1); w_panel <- getv("ponderador_long_panel", w1); panel <- is.finite(w_panel) & w_panel > 0
  age_group <- as.character(cut(age0, c(17, 29, 44, 59, 65), labels = c("18-29", "30-44", "45-59", "60-65")))
  for (s in c("All", "M1", "M2")) {
    ss <- if (s == "All") rep(TRUE, nrow(d)) else sample_label == s
    fz <- flow_pub[flow_pub$interval == p$interval & flow_pub$sample == s, ]
    mine <- c(primary_links = sum(quality & ss), s09_classifiable_pairs = sum(rp & ss), s10_classifiable_pairs = sum(g9 & s0 != "NR" & s1 != "NR" & ss), s09_pairs_panel_eligible = sum(rp & panel & ss))
    for (st in names(mine)) { pn <- fz$n[fz$stage == st]; if (length(pn) != 1 || pn != mine[[st]]) reproduce_ok <- FALSE }
    flow[[length(flow) + 1]] <- data.frame(interval = p$interval, sample = s, s09_pairs = sum(rp & ss), origin_regular_frequency_unknown = sum(rp & ss & is.na(s0)),
      destination_regular_frequency_unknown = sum(rp & ss & !is.na(s0) & is.na(s1)), state_pairs = sum(g9 & ss), state_pairs_panel_subset = sum(g9 & panel & ss),
      origin_NR = sum(g9 & ss & s0 == "NR"), origin_regular = sum(g9 & ss & s0 != "NR"), destination_NR = sum(g9 & ss & s1 == "NR"), destination_regular = sum(g9 & ss & s1 != "NR"))
  }
  base_units[[pi]] <- data.frame(segment = seg[baseline], stratum = strat[baseline])
  rows[[pi]] <- data.frame(interval = p$interval, id = d$idencuesta[g9], sample = sample_label[g9], segment = seg[g9], stratum = strat[g9],
    sex = ifelse(sex0[g9] == 1, "Men", "Women"), age_group = age_group[g9], from = s0[g9], to = s1[g9], w_total = w_total[g9], w_panel = w_panel[g9], panel = panel[g9], stringsAsFactors = FALSE)
}
check("pair_counts_match_weighting_notebook_flow", reproduce_ok)
pp <- do.call(rbind, rows); rm(d)
check("total_weight_positive_for_all_state_pairs", all(is.finite(pp$w_total) & pp$w_total > 0))
check("panel_weight_positive_for_panel_state_pairs", all(is.finite(pp$w_panel[pp$panel]) & pp$w_panel[pp$panel] > 0))
pp$sexage <- paste(pp$sex, pp$age_group, sep = "_")
pp$from <- factor(pp$from, ST); pp$to <- factor(pp$to, ST)
pp$sex_f <- factor(pp$sex, c("Men", "Women")); pp$age_f <- factor(pp$age_group, c("18-29", "30-44", "45-59", "60-65")); pp$int_f <- factor(pp$interval, IV)
units <- unique(do.call(rbind, base_units)); stopifnot(!anyDuplicated(units$segment))
pp$unit <- match(pp$segment, units$segment); stopifnot(!anyNA(pp$unit)); NU <- nrow(units)

# ---- cells (interval x sex x age) and reporting groups ---------------------------------------------------------------------
cells <- expand.grid(sexage = SA, interval = IV, stringsAsFactors = FALSE); NC <- nrow(cells)
cells$sex <- sub("_.*", "", cells$sexage); cells$age_group <- sub(".*_", "", cells$sexage)
pp$cell <- match(paste(pp$interval, pp$sexage), paste(cells$interval, cells$sexage)); stopifnot(!anyNA(pp$cell))
groups <- expand.grid(group = c("All", SA), level = c(IV, "pooled"), stringsAsFactors = FALSE); NG <- nrow(groups)
groups$sex <- ifelse(groups$group == "All", "All", sub("_.*", "", groups$group)); groups$age_group <- ifelse(groups$group == "All", "All", sub(".*_", "", groups$group))
M <- outer(seq_len(NG), seq_len(NC), Vectorize(function(g, c) as.numeric(groups$level[g] %in% c("pooled", cells$interval[c]) && groups$group[g] %in% c("All", cells$sexage[c]))))
stopifnot(all(colSums(M) == 4))
gmask <- lapply(seq_len(NG), function(g) M[g, pp$cell] == 1)
key <- (pp$cell - 1L) * NS * NS + (as.integer(pp$from) - 1L) * NS + as.integer(pp$to)   # "to" fastest, then "from", then cell
fml <- ~ from + sex_f * age_f + int_f
Xall <- stats::model.matrix(fml, pp)
grid <- data.frame(from = factor(rep(ST, NC), ST), cell = rep(seq_len(NC), each = NS))
grid$sex_f <- factor(cells$sex[grid$cell], levels(pp$sex_f)); grid$age_f <- factor(cells$age_group[grid$cell], levels(pp$age_f)); grid$int_f <- factor(cells$interval[grid$cell], IV)
Xgrid <- stats::model.matrix(fml, grid); stopifnot(identical(colnames(Xgrid), colnames(Xall)))

# ---- estimator building blocks -----------------------------------------------------------------------------------------------
norm_w <- function(wm, m, iv) { a <- tapply(m, iv, sum) / tapply(wm, iv, sum); as.numeric(wm * a[as.character(iv)]) }   # mean 1 per interval, as EPS period mass
cnt_array <- function(v) aperm(array(v, c(NS, NS, NC)), c(3, 2, 1))                                     # key vector -> [cell, from, to]
cnt_rows <- function(rows, x) { v <- numeric(NC * NS * NS); s <- rowsum(x, key[rows]); v[as.integer(rownames(s))] <- s[, 1]; cnt_array(v) }
A_shrink <- function(cnt, k) {   # eps_markov_core.R ep_Afit: (x + k p) / (rowSums(x) + k) along the hierarchy
  sh <- function(x, p, kk) (x + kk * p) / (rowSums(x) + kk)
  glob <- sh(colSums(cnt, dims = 1), matrix(1 / NS, NS, NS), .5); res <- array(NA_real_, dim(cnt))
  for (iv in IV) { ci <- which(cells$interval == iv); pg <- sh(colSums(cnt[ci, , , drop = FALSE], dims = 1), glob, k)
    for (sx in c("Men", "Women")) { cs <- ci[cells$sex[ci] == sx]; ps <- sh(colSums(cnt[cs, , , drop = FALSE], dims = 1), pg, k)
      for (cc in cs) res[cc, , ] <- sh(cnt[cc, , ], ps, k) } }
  res
}
CUT_FLOOR <- 1:7; CUT_ROUND <- 1:7 - .5   # code k read as [k-1, k) days (main) or rounded to the nearest day (sensitivity)
ln_fit <- function(rows, wn, strict = FALSE, cuts = CUT_FLOOR) {   # eps_markov_core.R ep_fit kind "lognormal", amount observed in day bands
  X <- Xall[rows, , drop = FALSE]; y <- as.numeric(pp$to[rows] != "NR")
  q <- qr(X * sqrt(wn)); c1 <- sort(q$pivot[seq_len(q$rank)])
  f1 <- tryCatch(stats::glm.fit(X[, c1, drop = FALSE], y, weights = wn, family = stats::quasibinomial(), control = stats::glm.control(maxit = 100)), warning = function(w) NULL, error = function(e) NULL)
  if (is.null(f1) || !isTRUE(f1$converged) || any(!is.finite(f1$coefficients))) { if (strict) stop("participation model failed"); return(NULL) }
  reg <- y == 1; X2 <- X[reg, , drop = FALSE]; w2 <- wn[reg]
  q2 <- qr(X2 * sqrt(w2)); c2 <- sort(q2$pivot[seq_len(q2$rank)]); X2c <- X2[, c2, drop = FALSE]
  code <- as.integer(pp$to[rows][reg]) - 1L                                  # S10 code 1..8
  # Latent average drinking days per week D between cuts: main reading code 1 = D < 1, code k = [k-1, k), code 8 = D >= 7.
  yy <- survival::Surv(ifelse(code == 1L, NA_real_, cuts[pmax(code - 1L, 1L)]), ifelse(code == 8L, NA_real_, cuts[pmin(code, 7L)]), type = "interval2")
  f2 <- tryCatch(survival::survreg(yy ~ 0 + X2c, weights = w2, dist = "lognormal", control = survival::survreg.control(maxiter = 100)), warning = function(w) NULL, error = function(e) NULL)
  if (is.null(f2) || any(!is.finite(stats::coef(f2))) || !is.finite(f2$scale)) { if (strict) stop("frequency model failed"); return(NULL) }
  list(b1 = f1$coefficients, c1 = c1, b2 = stats::coef(f2), c2 = c2, sigma = f2$scale, cuts = cuts)
}
ln_cells <- function(f) {
  if (is.null(f)) return(array(NA_real_, c(NC, NS, NS)))
  miss <- function(cols) { dr <- setdiff(seq_len(ncol(Xgrid)), cols); if (length(dr)) rowSums(Xgrid[, dr, drop = FALSE] != 0) > 0 else rep(FALSE, nrow(Xgrid)) }
  preg <- as.numeric(stats::plogis(Xgrid[, f$c1, drop = FALSE] %*% f$b1)); mu <- as.numeric(Xgrid[, f$c2, drop = FALSE] %*% f$b2)
  Fc <- vapply(f$cuts, function(cc) stats::pnorm((log(cc) - mu) / f$sigma), numeric(length(mu)))
  P <- cbind(1 - preg, preg * cbind(Fc[, 1], Fc[, 2:7] - Fc[, 1:6], 1 - Fc[, 7])); P[miss(f$c1) | miss(f$c2), ] <- NA
  aperm(array(P, c(NS, NC, NS)), c(2, 1, 3))
}
agg_cells <- function(Pc, mass) {   # group estimate = cell rows averaged with the group's weighted origin mass per cell
  outa <- array(NA_real_, c(NG, NS, NS)); tot <- rowSums(mass)
  for (i in seq_len(NS)) {
    a <- M * rep(mass[, i], each = NG); fb <- rowSums(a) == 0
    if (any(fb)) a[fb, ] <- M[fb, , drop = FALSE] * rep(tot, each = sum(fb))   # origin unobserved in the group: mix cells by size
    Pi <- Pc[, i, ]; na_c <- is.na(Pi[, 1]); Pi[na_c, ] <- 0
    r <- (a %*% Pi) / rowSums(a); r[(a[, na_c, drop = FALSE] %*% rep(1, sum(na_c))) > 0, ] <- NA; r[!is.finite(r[, 1]), ] <- NA
    outa[, i, ] <- r
  }
  outa
}
obs_groups <- function(cnt) { G <- array(M %*% matrix(cnt, NC, NS * NS), c(NG, NS, NS)); D <- rowSums(G, dims = 2); P <- sweep(G, c(1, 2), D, "/"); P[D == 0] <- NA; P }
predict_rows <- function(Pc, rr) { i <- cbind(pp$cell[rr], as.integer(pp$from[rr])); vapply(seq_len(NS), function(j) Pc[cbind(i, j)], numeric(length(rr))) }
logloss <- function(P, y) { Q <- pmax(P, 1e-8); Q <- Q / rowSums(Q); -log(Q[cbind(seq_len(nrow(Q)), as.integer(y))]) }
brier <- function(P, y) rowSums((P - diag(NS)[as.integer(y), , drop = FALSE])^2)
cv_folds <- function(ids, k, seed) { set.seed(seed); uu <- sort(unique(ids)); stats::setNames(sample(rep(seq_len(k), length.out = length(uu))), uu) }
tune_k <- function(rr, w, seed) {   # eps_markov_core.R ep_tune: 3 person-blocked folds, weighted log loss over kgrid
  f <- cv_folds(pp$id[rr], 3, seed); fr <- f[as.character(pp$id[rr])]; loss <- numeric(length(kgrid)); mass <- 0
  for (j in 1:3) { tr <- rr[fr != j]; te <- rr[fr == j]; cnt <- cnt_rows(tr, norm_w(w[tr], rep(1, length(tr)), pp$interval[tr])); mass <- mass + sum(w[te])
    for (kk in seq_along(kgrid)) loss[kk] <- loss[kk] + sum(w[te] * logloss(predict_rows(A_shrink(cnt, kgrid[kk]), te), pp$to[te])) }
  list(k = kgrid[which.min(loss)], scores = data.frame(k = kgrid, logloss = loss / mass))
}
w_scheme <- function(s) switch(s, unweighted = rep(1, nrow(pp)), total = pp$w_total, panel = ifelse(pp$panel, pp$w_panel, 0))
unit_mat <- function(x, rr) { v <- matrix(0, NU, NC * NS * NS); s <- rowsum(x[rr], (key[rr] - 1L) * NU + pp$unit[rr]); v[as.integer(rownames(s))] <- s[, 1]; v }
ci_of <- function(arr) { q <- apply(arr, 1:3, function(x) { x <- x[!is.na(x)]; if (length(x) >= .95 * B) stats::quantile(x, c(.025, .975), names = FALSE) else c(NA_real_, NA_real_) })
  list(lower = q[1, , , ], upper = q[2, , , ], valid = apply(!is.na(arr), 1:3, sum), se = apply(arr, 1:3, stats::sd, na.rm = TRUE)) }
logit_ci <- function(p, se) { ok <- is.finite(p) & is.finite(se) & se > 0 & p > 0 & p < 1; lo <- hi <- rep(NA_real_, length(p))
  lo[ok] <- stats::plogis(stats::qlogis(p[ok]) - 1.96 * se[ok] / (p[ok] * (1 - p[ok]))); hi[ok] <- stats::plogis(stats::qlogis(p[ok]) + 1.96 * se[ok] / (p[ok] * (1 - p[ok]))); list(lower = lo, upper = hi) }

# ---- one shared stratified bootstrap of design segments --------------------------------------------------------------------
set.seed(seed_boot); boot <- matrix(0L, NU, B)
for (h in unique(units$stratum)) { ix <- which(units$stratum == h); stopifnot(length(ix) > 1); boot[ix, ] <- stats::rmultinom(B, length(ix), rep(1 / length(ix), length(ix))) }

# ---- descriptive N per group and origin ---------------------------------------------------------------------------------------
desc <- list(); strata <- list()
for (s in SCHEMES) { w <- w_scheme(s); inset <- w > 0
  for (g in seq_len(NG)) { z <- gmask[[g]] & inset
    strata[[length(strata) + 1]] <- data.frame(scheme = s, level = groups$level[g], group = groups$group[g], sex = groups$sex[g], age_group = groups$age_group[g], n_pairs = sum(z),
      n_persons = length(unique(pp$id[z])), n_segments = length(unique(pp$segment[z])), sum_w = sum(w[z]), ess = if (any(z)) sum(w[z])^2 / sum(w[z]^2) else NA_real_,
      t(stats::setNames(vapply(ST, function(i) sum(z & pp$from == i), 0L), paste0("n_", ST))))
    for (i in ST) { zi <- z & pp$from == i
      desc[[length(desc) + 1]] <- data.frame(scheme = s, level = groups$level[g], group = groups$group[g], from = i, to = ST, n_stratum = sum(z), n_persons_stratum = length(unique(pp$id[z])),
        n_origin = sum(zi), n_event = vapply(ST, function(j) sum(zi & pp$to == j), 0L), n_segments_origin = length(unique(pp$segment[zi])), sum_w_origin = sum(w[zi]),
        ess_origin = if (any(zi)) sum(w[zi])^2 / sum(w[zi]^2) else NA_real_) } } }
desc <- do.call(rbind, desc); strata <- do.call(rbind, strata)

# ---- estimation per weighting scheme ------------------------------------------------------------------------------------------
res <- list(); tuning <- list(); coefs <- list(); cvs <- list(); cvpair <- list(); calib <- list(); shape <- list(); fitlog <- list()
identity_ok <- TRUE
for (s in SCHEMES) {
  ts <- Sys.time(); w <- w_scheme(s); inset <- w > 0; rr <- which(inset)
  tk <- tune_k(rr, w, seed_cv); k_s <- tk$k; tuning[[s]] <- cbind(scheme = s, tk$scores, chosen = tk$scores$k == k_s)
  S <- unit_mat(w, rr); T_full <- colSums(S); T_rep <- crossprod(S, boot); rm(S)
  Siv <- matrix(0, NU, length(IV)); a <- rowsum(rep(1, length(rr)), (match(pp$interval[rr], IV) - 1L) * NU + pp$unit[rr]); Siv[as.integer(rownames(a))] <- a[, 1]
  N_rep <- crossprod(Siv, boot)                                                                       # pairs x multiplicity per interval
  civ <- match(cells$interval, IV)
  one_rep <- function(Tb, Nb, m, strict = FALSE) {   # Tb: weighted cell totals; Nb: pairs x multiplicity per interval; m: multiplicity per pair
    cnt <- cnt_array(Tb); mass <- rowSums(cnt, dims = 2)
    Wiv <- vapply(seq_along(IV), function(j) sum(cnt[civ == j, , ]), 1)
    Ac <- A_shrink(cnt * (Nb / Wiv)[civ], k_s)
    rows_b <- rr[m[rr] > 0]
    f <- ln_fit(rows_b, norm_w(w[rows_b] * m[rows_b], m[rows_b], pp$interval[rows_b]), strict = strict)
    list(obs = obs_groups(cnt), A = agg_cells(Ac, mass), LN = agg_cells(ln_cells(f), mass), fit = f, Ac = Ac)
  }
  full <- one_rep(T_full, colSums(Siv), rep(1, nrow(pp)), strict = TRUE)
  f0 <- full$fit
  # identity: the replicate path with all multiplicities 1 equals direct computation from the pairs
  cnt_direct <- cnt_rows(rr, w[rr]); obs_direct <- obs_groups(cnt_direct)
  A_direct <- A_shrink(cnt_rows(rr, norm_w(w[rr], rep(1, length(rr)), pp$interval[rr])), k_s)
  identity_ok <- identity_ok && isTRUE(all.equal(full$obs, obs_direct)) && isTRUE(all.equal(full$Ac, A_direct))
  rep_obs <- rep_A <- rep_LN <- array(NA_real_, c(NG, NS, NS, B)); fails <- 0L
  for (b in seq_len(B)) {
    m <- boot[pp$unit, b]; o <- one_rep(T_rep[, b], N_rep[, b], m)
    rep_obs[, , , b] <- o$obs; rep_A[, , , b] <- o$A; rep_LN[, , , b] <- o$LN; if (is.null(o$fit)) fails <- fails + 1L
    if (b %% 250 == 0) message(sprintf("States bootstrap %s: %d/%d replicates (%.1f min)", s, b, B, as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
  }
  fitlog[[s]] <- data.frame(scheme = s, k = k_s, replicates = B, lognormal_failed_replicates = fails, sigma = f0$sigma, minutes = as.numeric(difftime(Sys.time(), ts, units = "mins")))
  coefs[[s]] <- rbind(data.frame(scheme = s, part = "participation (logit, regular at destination)", term = colnames(Xall)[f0$c1], estimate = f0$b1),
    data.frame(scheme = s, part = "frequency (lognormal, days per week)", term = colnames(Xall)[f0$c2], estimate = f0$b2),
    data.frame(scheme = s, part = "frequency (lognormal, days per week)", term = "sigma (log scale)", estimate = f0$sigma))
  # long table per estimator
  for (est in c("Observed", "A", "Lognormal")) {
    pt <- switch(est, Observed = full$obs, A = full$A, Lognormal = full$LN); ra <- switch(est, Observed = rep_obs, A = rep_A, Lognormal = rep_LN); ci <- ci_of(ra)
    idx <- expand.grid(g = seq_len(NG), i = seq_len(NS), j = seq_len(NS))
    res[[length(res) + 1]] <- data.frame(estimator = est, scheme = s, level = groups$level[idx$g], group = groups$group[idx$g], sex = groups$sex[idx$g], age_group = groups$age_group[idx$g],
      from = ST[idx$i], to = ST[idx$j], estimate = pt[as.matrix(idx)], lower = ci$lower[as.matrix(idx)], upper = ci$upper[as.matrix(idx)], se_boot = ci$se[as.matrix(idx)], valid_replicates = ci$valid[as.matrix(idx)])
  }
  rm(rep_obs, rep_A, rep_LN, T_rep)
  # cross-validation (EPS ep_cv): person-blocked 5 folds x 3 repeats, k tuned inside the training folds
  oof <- list(A = array(NA_real_, c(nrow(pp), NS, n_repeats)), Lognormal = array(NA_real_, c(nrow(pp), NS, n_repeats)), Lognormal_rounding = array(NA_real_, c(nrow(pp), NS, n_repeats)))
  for (rp_ in seq_len(n_repeats)) { fo <- cv_folds(pp$id[rr], K_folds, seed_cv + rp_); fr <- fo[as.character(pp$id[rr])]
    for (fq in seq_len(K_folds)) { tr <- rr[fr != fq]; te <- rr[fr == fq]; wn_tr <- norm_w(w[tr], rep(1, length(tr)), pp$interval[tr])
      kin <- tune_k(tr, w, seed_cv + 100L * rp_ + fq)$k
      oof$A[te, , rp_] <- predict_rows(A_shrink(cnt_rows(tr, wn_tr), kin), te)
      oof$Lognormal[te, , rp_] <- predict_rows(ln_cells(ln_fit(tr, wn_tr, strict = TRUE)), te)
      oof$Lognormal_rounding[te, , rp_] <- predict_rows(ln_cells(ln_fit(tr, wn_tr, strict = TRUE, cuts = CUT_ROUND)), te)
      cvs[[length(cvs) + 1]] <- data.frame(scheme = s, `repeat` = rp_, fold = fq, k_inner = kin, n_test = length(te), check.names = FALSE) } }
  ll <- vapply(names(oof), function(nm) rowMeans(vapply(seq_len(n_repeats), function(r) logloss(oof[[nm]][rr, , r], pp$to[rr]), numeric(length(rr)))), numeric(length(rr)))
  br <- vapply(names(oof), function(nm) rowMeans(vapply(seq_len(n_repeats), function(r) brier(oof[[nm]][rr, , r], pp$to[rr]), numeric(length(rr)))), numeric(length(rr)))
  dsg <- data.frame(segment = pp$segment, stratum = pp$stratum, interval = pp$interval, wd = ifelse(inset, w, 1), inset = inset, d_ll = 0, d_br = 0, d_round = 0)
  dsg$d_ll[rr] <- ll[, "Lognormal"] - ll[, "A"]; dsg$d_br[rr] <- br[, "Lognormal"] - br[, "A"]; dsg$d_round[rr] <- ll[, "Lognormal_rounding"] - ll[, "Lognormal"]
  des <- survey::svydesign(ids = ~segment, strata = ~stratum, weights = ~wd, nest = TRUE, data = dsg)
  for (lv in c("All", IV)) { sel <- inset & (lv == "All" | pp$interval == lv); sub <- subset(des, sel); m1 <- survey::svymean(~d_ll + d_br + d_round, sub)
    zz <- rr[(lv == "All") | (pp$interval[rr] == lv)]; wz <- w[zz]; jj <- match(zz, rr)
    cvpair[[length(cvpair) + 1]] <- data.frame(scheme = s, interval = lv, n_pairs = length(zz), logloss_A = sum(wz * ll[jj, "A"]) / sum(wz), logloss_Lognormal = sum(wz * ll[jj, "Lognormal"]) / sum(wz),
      brier_A = sum(wz * br[jj, "A"]) / sum(wz), brier_Lognormal = sum(wz * br[jj, "Lognormal"]) / sum(wz), logloss_difference = stats::coef(m1)[["d_ll"]], logloss_difference_se = survey::SE(m1)[["d_ll"]],
      brier_difference = stats::coef(m1)[["d_br"]], brier_difference_se = survey::SE(m1)[["d_br"]], logloss_Lognormal_rounding = sum(wz * ll[jj, "Lognormal_rounding"]) / sum(wz),
      rounding_minus_floor = stats::coef(m1)[["d_round"]], rounding_minus_floor_se = survey::SE(m1)[["d_round"]], interval_basis = "strata + segments Taylor; conditional on out-of-fold predictions") }
  for (nm in names(oof)) { pr <- apply(oof[[nm]], c(1, 2), mean)
    for (iv in IV) for (i in ST) { zz <- rr[pp$interval[rr] == iv & pp$from[rr] == i]; if (!length(zz)) next; wz <- w[zz]
      calib[[length(calib) + 1]] <- data.frame(scheme = s, model = nm, interval = iv, from = i, to = ST, n_origin = length(zz), observed = vapply(ST, function(j) sum(wz * (pp$to[zz] == j)) / sum(wz), 1),
        predicted_out_of_fold = as.numeric(colSums(pr[zz, , drop = FALSE] * wz) / sum(wz))) } }
  # lognormal shape check: weighted probit of the cumulative S10 distribution against log(days)
  for (iv in c("All", IV)) { zz <- rr[pp$to[rr] != "NR" & (iv == "All" | pp$interval[rr] == iv)]; wz <- w[zz]; cd <- as.integer(pp$to[zz]) - 1L
    Fv <- vapply(1:7, function(cc) sum(wz[cd <= cc]) / sum(wz), 1); z <- stats::qnorm(Fv); lf <- stats::lm(z ~ log(1:7))
    shape[[length(shape) + 1]] <- data.frame(scheme = s, interval = iv, n_regular_destinations = length(zz), cut_days = 1:7, cumulative_share = Fv, probit = z,
      slope = stats::coef(lf)[[2]], implied_sigma = 1 / stats::coef(lf)[[2]], r_squared = summary(lf)$r.squared,
      # same line under the rounded-day reading and on a linear day scale: the shape alone cannot tell the two log readings apart
      r_squared_rounding = summary(stats::lm(z ~ log(1:7 - .5)))$r.squared, r_squared_linear_days = summary(stats::lm(z ~ c(1:7)))$r.squared) }
  message(sprintf("States scheme %s done: k = %d, %d pairs, %.1f min", s, k_s, length(rr), as.numeric(difftime(Sys.time(), ts, units = "mins"))))
}
check("replicate_path_reproduces_direct_estimates", identity_ok, kind = "identity")
res <- do.call(rbind, res)
res <- merge(res, desc, by = c("scheme", "level", "group", "from", "to"), all.x = TRUE, sort = FALSE)
res$support <- ifelse(res$n_origin == 0, "unobserved origin", ifelse(res$n_origin < 30, "sparse", "observed"))
res$ci_status <- ifelse(res$estimator == "Observed",
  ifelse(res$n_origin == 0, "empty_origin", ifelse(res$n_segments_origin < 10, "fewer_than_10_segments", ifelse(res$n_event == 0 | res$n_event == res$n_origin, "boundary_no_interval",
    ifelse(is.na(res$lower), "insufficient_bootstrap_support", "exploratory_segment_bootstrap")))),
  ifelse(is.na(res$lower), "insufficient_bootstrap_support", "exploratory_segment_bootstrap"))
no_ci <- res$estimator == "Observed" & res$ci_status != "exploratory_segment_bootstrap"; res$lower[no_ci] <- NA; res$upper[no_ci] <- NA
res$estimate[res$estimator == "Observed" & res$n_origin == 0] <- NA

# ---- Taylor intervals for Observed: strata + segments (persons nested), and clustered by person ------------------------------
Y <- vapply(ST, function(j) as.numeric(pp$to == j), numeric(nrow(pp))); colnames(Y) <- paste0("y_", ST)
fy <- stats::as.formula(paste("~", paste(colnames(Y), collapse = " + ")))
tay <- list()
for (s in SCHEMES) { w <- w_scheme(s); inset <- w > 0
  dd <- cbind(data.frame(id = pp$id, segment = pp$segment, stratum = pp$stratum, interval = pp$interval, sexage = pp$sexage, wd = ifelse(inset, w, 1)), Y)
  des <- list(design = survey::svydesign(ids = ~segment, strata = ~stratum, weights = ~wd, nest = TRUE, data = dd), person = survey::svydesign(ids = ~id, weights = ~wd, data = dd),
    independent = survey::svydesign(ids = ~1, weights = ~wd, data = dd))
  for (dn in names(des)) for (i in ST) { sel <- inset & pp$from == i; if (!any(sel)) next; sub <- subset(des[[dn]], sel)
    specs <- list(list(by = ~interval + sexage, level = NA, group = NA), list(by = ~interval, level = NA, group = "All"), list(by = ~sexage, level = "pooled", group = NA), list(by = NULL, level = "pooled", group = "All"))
    if (dn != "design") specs <- specs[3:4]
    for (sp in specs) {
      if (is.null(sp$by)) { mm <- survey::svymean(fy, sub); tb <- data.frame(level = "pooled", group = "All", to = ST, est = as.numeric(stats::coef(mm)), se = as.numeric(survey::SE(mm))) }
      else { r <- survey::svyby(fy, sp$by, sub, survey::svymean, keep.var = TRUE); r <- as.data.frame(r)
        lvl <- if (is.na(sp$level)) r$interval else rep(sp$level, nrow(r)); grp <- if (is.na(sp$group)) r$sexage else rep(sp$group, nrow(r))
        tb <- do.call(rbind, lapply(seq_along(ST), function(j) data.frame(level = lvl, group = grp, to = ST[j], est = r[[colnames(Y)[j]]], se = r[[paste0("se.", colnames(Y)[j])]]))) }
      tay[[length(tay) + 1]] <- data.frame(scheme = s, design = dn, from = i, tb) } } }
tay <- do.call(rbind, tay)
for (dn in c("design", "person", "independent")) { z <- tay[tay$design == dn, ]; k <- match(paste(res$scheme, res$level, res$group, res$from, res$to), paste(z$scheme, z$level, z$group, z$from, z$to))
  ob <- res$estimator == "Observed"; se <- ifelse(ob, z$se[k], NA_real_); est_t <- ifelse(ob, z$est[k], NA_real_)
  if (dn == "design") check("taylor_point_equals_observed", !anyNA(est_t[ob & !is.na(res$estimate)]) && all(abs(est_t[ob & !is.na(res$estimate)] - res$estimate[ob & !is.na(res$estimate)]) < 1e-9), kind = "identity")
  ci <- logit_ci(res$estimate, se); okci <- ob & res$n_segments_origin >= 10
  res[[paste0("se_taylor_", dn)]] <- se; if (dn != "independent") { res[[paste0("lower_taylor_", dn)]] <- ifelse(okci, ci$lower, NA_real_); res[[paste0("upper_taylor_", dn)]] <- ifelse(okci, ci$upper, NA_real_) } }

# ---- checks against the published S09 and S10 tables -----------------------------------------------------------------------------
ob_u <- res[res$estimator == "Observed" & res$scheme == "unweighted" & res$level %in% IV, ]
sp <- s_pub[s_pub$estimator == "unweighted_general" & s_pub$group %in% c("All", SA), ]
s10 <- sp[sp$item == "s10", ]; k10 <- match(paste(s10$interval, s10$group, paste0("F", s10$from), paste0("F", s10$to)), paste(ob_u$level, ob_u$group, ob_u$from, ob_u$to))
check("frequency_block_counts_equal_published_S10_matrices", !anyNA(k10) && all(ob_u$n_event[k10] == s10$n_event))
s09 <- sp[sp$item == "s09" & sp$from == 2 & sp$to == 2, ]; k09 <- match(paste(s09$interval, s09$group, "NR", "NR"), paste(ob_u$level, ob_u$group, ob_u$from, ob_u$to))
check("NR_to_NR_counts_equal_published_S09_matrices", !anyNA(k09) && all(ob_u$n_event[k09] == s09$n_event))
rs <- stats::aggregate(estimate ~ estimator + scheme + level + group + from, data = res[!is.na(res$estimate), ], FUN = sum)
check("every_estimated_row_sums_to_one", all(abs(rs$estimate - 1) < 1e-9))
check("lognormal_main_fit_predicts_every_cell_and_origin", all(vapply(SCHEMES, function(s) !anyNA(res$estimate[res$estimator == "Lognormal" & res$scheme == s]), TRUE)))
tu_all <- do.call(rbind, tuning); flat_edge <- vapply(split(tu_all, tu_all$scheme), function(z) { z <- z[order(z$k), ]; i <- which(z$chosen); i < nrow(z) || (z$logloss[i - 1] - z$logloss[i]) / z$logloss[i] < .001 }, TRUE)
check("A_k_interior_or_flat_at_grid_edge", all(flat_edge))
fl <- do.call(rbind, fitlog); check("lognormal_replicates_fitted_at_least_99_percent", all(fl$lognormal_failed_replicates <= .01 * B))
check("model_estimates_complete_for_observed_origins", all(!is.na(res$estimate[res$estimator != "Observed" & res$n_origin > 0])))
check("no_pooled_independence_assumption", TRUE, kind = "declaration")
check("published_tables_unchanged", identical(pub_hash, tools::md5sum(pub_files)))

# ---- write ----------------------------------------------------------------------------------------------------------------------------
lead <- c("estimator", "scheme", "level", "group", "sex", "age_group", "from", "to", "n_stratum", "n_persons_stratum", "n_origin", "n_event", "n_segments_origin", "sum_w_origin", "ess_origin",
  "estimate", "lower", "upper", "se_boot", "valid_replicates", "ci_status", "support")
res <- res[order(match(res$estimator, c("Observed", "A", "Lognormal")), match(res$scheme, SCHEMES), match(res$level, c(IV, "pooled")), match(res$group, c("All", SA)), match(res$from, ST), match(res$to, ST)),
  c(lead, setdiff(names(res), lead))]
save_table(res, "matrices")
save_table(data.frame(state = ST, label = st_label[ST], s09 = c(2, rep(1, 8)), s10 = c(NA, 1:8), latent_days_per_week = c("not asked (S10 skipped)", "D < 1", paste0(1:6, " <= D < ", 2:7), "D >= 7")), "dictionary")
save_table(do.call(rbind, flow), "flow"); save_table(strata, "strata")
save_table(do.call(rbind, tuning), "A_tuning"); save_table(do.call(rbind, coefs), "lognormal_coefficients"); save_table(fl, "fit_log")
save_table(do.call(rbind, cvs), "cv_folds"); save_table(do.call(rbind, cvpair), "cv_comparison"); save_table(do.call(rbind, calib), "calibration_oof"); save_table(do.call(rbind, shape), "lognormal_shape")
save_table(do.call(rbind, checks), "validation")
save_table(data.frame(bootstrap_replicates = B, bootstrap_seed = seed_boot, bootstrap_units = "design segments within the six published strata, shared by the three intervals (all pairs of a person move together)",
  cv = sprintf("%d person-blocked folds x %d repeats, seed %d; k for A tuned inside each training split over %s", K_folds, n_repeats, seed_cv, paste(kgrid, collapse = "/")),
  states = "NR + S10 codes 1-8 among regular drinkers; regular drinkers without a valid S10 at either end are excluded and counted in states_flow",
  weights = "none; ponderador_long_total and ponderador_long_panel of the destination wave (panel scheme on the panel-eligible subset); models fitted with weights normalised to mean 1 per interval",
  lognormal = "logit P(regular at destination) and interval-censored lognormal days per week, both on origin state + sex x age group + interval; code k read as [k-1, k) days, code 1 as < 1 day, code 8 as >= 7 days",
  pooled = "pooled-by-wave estimates average the interval cells with the group's weighted origin mass; Observed pooled = survey-weighted proportion over all pairs of the three intervals",
  taylor = "Observed only: strata + segments (persons nested in segments) for all groups; clustered by person (ids = idencuesta) and unclustered (ids = ~1, SE only) for pooled groups",
  sensitivity = "out-of-fold comparison of the lognormal with S10 codes read as rounded days (cuts 0.5, 1.5, ..., 6.5)", output_dir = out_rel), "configuration")
utils::capture.output(utils::sessionInfo(), file = file.path(out, "states_session_info.txt"))
message(sprintf("State transitions finished: %d matrix rows written to %s. Elapsed %.2f minutes.", nrow(res), out_rel, as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
