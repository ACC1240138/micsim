.t0 <- Sys.time()
.t_cmp0 <- .t0   # the sourced files reset .t0
# Exploratory, separate: two-year comparators for the direct TSM R7 -> R11 comparison (tsm_r7_r11_direct.R).
# Comparators: (1) observed TSM R7 -> R11; (2) EPS engine (A, Lognormal) at two years; (3) the original JRT method
# (ENPG rank-matched pseudo-panel + MASS::polr), reconstructed on the available ENPG waves; (4) JRT_reference of the EPS
# notebook (JRT formula fitted to real EPS pairs) at two years; (5) TSM engine (A, Lognormal) fitted to short intervals,
# projected to two years. Rank coupling of the cohort's own R7 and R11 margins is an additional two-year quantity.
# Reads only existing aggregate outputs, the TSM bundle (through the direct script) and the ENPG JRT-format bundle.
# No engine, notebook or outline is modified. Aggregates only are written to tsm_r7_r11_direct_outputs/.
# Run from the repository root, pinned to the E-cores on this PC.
source(here::here("__andres_control", "tsm_r7_r11_direct.R"))   # cohort D / AN, observed tables (deterministic rewrite)
.t1 <- Sys.time()
source(here::here("__andres_control", "tsm_markov_models.R"))    # ts_generator, ts_expm (definitions only)
source(here::here("__andres_control", "eps_markov_core.R"))      # ep_ij, ep_coupling (definitions only)
stopifnot(identical(unname(ep_ij), unname(ts_ij_fun(6))))   # the TSM generator code reproduces the six-state EPS structure
# States per engine: TSM has five (C3 and C4 merged into C3plus since 2026-10-26); the EPS v1 engine keeps six.
eng_ST <- function(src) if (src == "EPS") ep_ST else ts_ST
eng_Y <- function(src) if (src == "EPS") ep_Y else ts_Y
cmp_csv <- function(x, name) save_csv(x, paste0("cmp_", name))
SA <- expand.grid(age_group = ts_ages, sex = c("Men", "Women"), stringsAsFactors = FALSE)[, 2:1]
SA$stratum <- paste(SA$sex, SA$age_group)

# ---- 1. Two-year projection of the engines, per sex x age stratum --------------------------------------------------
# The engines' annual matrices come from a generator fitted to the model-predicted interval matrices of each period
# (EPS: six states, destinations NC, C1-C4; TSM: five states, destinations NC, C1, C2, C3plus; ts_annual / ep_annual). The exported group matrices are the same predictions averaged
# within period x sex x age x origin (ep_matrices), so the same generator is refitted per stratum and exponentiated at two
# years: P2 = expm(2 Q). Row masses are origin counts (the published pooled fit used weighted masses); origins with no
# rows keep zero mass, so their rates are set by the fixed ridge only.
eng_targets <- function(tab, periods, years, rows = rep(TRUE, nrow(tab)), wmass = NULL, ST = ts_ST, Y = ts_Y) {
  if (!is.null(wmass)) tab$n_origin <- wmass$mass[match(paste(tab$group, tab$from), paste(wmass$group, wmass$from))]
  tab$n_origin[is.na(tab$n_origin)] <- 0
  lapply(seq_along(periods), function(k) {
    z <- tab[rows & tab$period == periods[k], ]
    P <- matrix(0, length(ST), length(Y)); n <- numeric(length(ST))
    for (j in seq_along(ST)) {
      zz <- z[z$from == ST[j], ]
      if (!nrow(zz)) next
      # sum over groups with count masses (a single group when stratum-specific)
      m <- stats::aggregate(cbind(mass = n_origin) ~ group, unique(zz[c("group", "n_origin")]), sum)
      tot <- sum(m$mass); if (tot == 0) next
      e <- zz; e$estimate[is.na(e$estimate)] <- 0
      e$to5 <- ifelse(e$to %in% c("N0", "FD"), "NC", e$to)
      num <- tapply(e$estimate * e$n_origin, factor(e$to5, Y), sum)
      P[j, ] <- as.numeric(num) / tot; n[j] <- tot
    }
    list(P = P, n = n, delta = years[k])
  })
}
eng_fit <- function(targets, ST = ts_ST) {
  total <- sum(vapply(targets, function(z) sum(z$n), 1))
  g <- tryCatch(ts_generator(targets, total = total), error = function(e) NULL)
  if (is.null(g)) return(NULL)
  P2 <- ts_expm(g$Q * 2); dimnames(P2) <- list(ST, ST); dimnames(g$P) <- list(ST, ST)
  list(P1 = g$P, P2 = P2, rmse = g$rmse, convergence = g$convergence, semigroup = g$semigroup_error, n_rows = targets[[1]]$n)
}
et <- utils::read.csv(here::here("__andres_control", "eps_markov_outputs", "transition_matrices_design_CI.csv"), stringsAsFactors = FALSE)
tt <- utils::read.csv(here::here("__andres_control", "tsm_markov_outputs_v4", "transition_matrices_person_CI.csv"), stringsAsFactors = FALSE)
ea <- utils::read.csv(here::here("__andres_control", "eps_markov_outputs", "annual_pooled_matrices_design_CI.csv"), stringsAsFactors = FALSE)
ta <- utils::read.csv(here::here("__andres_control", "tsm_markov_outputs_v4", "annual_pooled_matrices_person_CI.csv"), stringsAsFactors = FALSE)
eps_periods <- c("VI_VII", "VII_VIII"); eps_years <- c(3.671, 4.03)   # ep_time$years in eps_markov_core.R
engines <- list(
  list(source = "EPS", model = "A", tab = et, periods = eps_periods, years = eps_years, published = ea),
  list(source = "EPS", model = "Lognormal", tab = et, periods = eps_periods, years = eps_years, published = ea),
  list(source = "EPS", model = "JRT_reference", tab = et, periods = eps_periods, years = eps_years, published = NULL),
  list(source = "TSM", model = "A", tab = tt, periods = ts_time$period, years = ts_time$years, published = ta),
  list(source = "TSM", model = "Lognormal", tab = tt, periods = ts_time$period, years = ts_time$years, published = ta))

# Weighted row masses (sum of the engines' main weight wn per period x sex x age x origin), rebuilt with the engines'
# own loaders and IPW functions (no model is refitted). The published pooled fit used these masses.
ts_risk <- ts_make_risk(W)
ts_period_mass <- vapply(ts_periods, function(p) sum(ts_risk$period == p & ts_risk$complete), 1); names(ts_period_mass) <- ts_periods
ts_dw <- ts_ipw_apply(ts_risk, ts_ipw_fit(ts_risk))
mass_of <- function(d) { m <- stats::aggregate(cbind(mass = wn) ~ period + sex + age_group + state0, d, sum)
  data.frame(group = paste(m$period, m$sex, m$age_group, sep = "|"), from = as.character(m$state0), mass = m$mass) }
tsm_wmass <- mass_of(ts_dw)
Sys.setenv(EPS_MARKOV_OUTPUT = ".quarto/eps_r7r11_scratch"); ep_lang <- "en"; ep_checks <- list(); ep_warnings <- character()
ep_load(); ep_W <- ep_waves(12); ep_risk <- ep_make_risk(ep_W)
ep_period_mass <- vapply(ep_periods, function(p) sum(ep_risk$period == p & ep_risk$complete), 1); names(ep_period_mass) <- ep_periods
ep_dw <- ep_ipw_apply(ep_risk, ep_ipw_fit(ep_risk))
eps_wmass <- mass_of(ep_dw)
stopifnot(nrow(ts_dw) == sum(tt$n_origin[tt$model == "A" & tt$to == "N0"], na.rm = TRUE),
          nrow(ep_dw) == sum(et$n_origin[et$model == "A" & et$to == "N0"], na.rm = TRUE))   # same pairs as the outputs
# Gate (fixed before looking): the generator refitted to the pooled targets must reproduce the published pooled annual
# matrix within 0.02 in every identified cell; otherwise stratum projections are not reported. First run with count
# masses (failed for three engines); rerun with the engines' weighted masses, which the published fit used.
# Since 2026-10-26 C4 is never reported: for the six-state EPS engine both annual matrices are merged to C3plus with the
# same weights (columns summed, the C3 and C4 rows averaged with the observed EPS origin pairs) before the comparison.
o34 <- unique(et[et$model == "A", c("group", "from", "n_origin")]); n34 <- c(sum(o34$n_origin[o34$from == "C3"]), sum(o34$n_origin[o34$from == "C4"]))
merge34 <- function(P) {
  if (!"C4" %in% rownames(P)) return(P)
  P[, "C3"] <- P[, "C3"] + P[, "C4"]; P["C3", ] <- (n34[1] * P["C3", ] + n34[2] * P["C4", ]) / sum(n34)
  P <- P[rownames(P) != "C4", colnames(P) != "C4"]; rownames(P)[rownames(P) == "C3"] <- colnames(P)[colnames(P) == "C3"] <- "C3plus"; P
}
gate <- do.call(rbind, lapply(engines, function(e) do.call(rbind, lapply(c("counts", "weighted"), function(mt) {
  tab <- e$tab[e$tab$model == e$model, ]; ST <- eng_ST(e$source)
  wm <- if (mt == "counts") NULL else if (e$source == "EPS") eps_wmass else tsm_wmass
  f <- eng_fit(eng_targets(tab, e$periods, e$years, wmass = wm, ST = ST, Y = eng_Y(e$source)), ST)
  if (is.null(e$published)) return(data.frame(source = e$source, model = e$model, masses = mt, max_abs_diff_annual = NA_real_,
    max_abs_diff_2y_reported_cells = NA_real_, rmse = f$rmse, pass = NA, note = "no published annual matrix: conversion derived here"))
  pub <- e$published[e$published$model == e$model, ]
  Pp <- matrix(NA_real_, length(ST), length(ST), dimnames = list(ST, ST)); Pp[cbind(match(pub$from, ST), match(pub$to, ST))] <- pub$estimate
  ok <- is.finite(Pp)
  P2p <- Pp; P2p[!ok] <- 0; for (r in rownames(Pp)[rowSums(!ok) > 0]) P2p[r, r] <- 1; P2p <- P2p %*% P2p
  nc <- function(P, o) P[o, "N0"] + P[o, "FD"]
  d2 <- max(abs(c(nc(f$P2, "N0") - nc(P2p, "N0"), nc(f$P2, "FD") - nc(P2p, "FD"), f$P2["C1", "C1"] - P2p["C1", "C1"],
                  nc(f$P2, "C1") - nc(P2p, "C1"))))
  ok_m <- is.finite(merge34(Pp)); d1 <- max(abs(merge34(f$P1)[ok_m] - merge34(Pp)[ok_m]))
  data.frame(source = e$source, model = e$model, masses = mt, max_abs_diff_annual = d1, max_abs_diff_2y_reported_cells = d2,
    rmse = f$rmse, pass = d1 < 0.02, note = paste0(if (mt == "counts") "count masses" else "weighted masses (as published)", if (e$source == "EPS") "; annual cells compared after merging C3 and C4" else ""))
}))))
cmp_csv(gate, "generator_gate"); cat("generator gate:\n"); print(gate, row.names = FALSE, digits = 3)

proj <- do.call(rbind, lapply(engines, function(e) {
  tab <- e$tab[e$tab$model == e$model, ]; ST <- eng_ST(e$source)
  gp <- gate$pass[gate$source == e$source & gate$model == e$model & gate$masses == "weighted"]
  passed <- is.na(gp) || gp
  do.call(rbind, lapply(seq_len(nrow(SA)), function(s) {
    rows <- tab$sex == SA$sex[s] & tab$age_group == SA$age_group[s]
    f <- if (passed) eng_fit(eng_targets(tab, e$periods, e$years, rows, wmass = if (e$source == "EPS") eps_wmass else tsm_wmass, ST = ST, Y = eng_Y(e$source)), ST) else NULL
    get <- function(o, d) if (is.null(f)) NA_real_ else if (d == "NC") f$P2[o, "N0"] + f$P2[o, "FD"] else f$P2[o, d]
    data.frame(source = e$source, model = e$model, sex = SA$sex[s], age_group = SA$age_group[s], stratum = SA$stratum[s],
      N0_NC = get("N0", "NC"), FD_NC = get("FD", "NC"), C1_C1 = get("C1", "C1"), C1_NC = get("C1", "NC"),
      n_rows_N0 = if (is.null(f)) NA else f$n_rows[1], n_rows_FD = if (is.null(f)) NA else f$n_rows[2],
      n_rows_C1 = if (is.null(f)) NA else f$n_rows[3], n_rows_C3plus = if (is.null(f)) NA else sum(f$n_rows[-(1:4)]),
      rmse = if (is.null(f)) NA_real_ else f$rmse, convergence = if (is.null(f)) NA else f$convergence,
      status = if (is.null(f)) "not available" else "point estimate")
  }))
}))
cmp_csv(proj, "engine_two_year_by_stratum")
# Origins with no rows in a stratum (mass 0) have rates set by the fixed ridge only. Sensitivity: refit every stratum
# with a ridge 10 times weaker and 10 times stronger and report the largest change in the reported cells.
ridge <- do.call(rbind, lapply(engines, function(e) {
  tab <- e$tab[e$tab$model == e$model, ]; wm <- if (e$source == "EPS") eps_wmass else tsm_wmass; ST <- eng_ST(e$source)
  do.call(rbind, lapply(c(5e-6, 5e-4), function(lam) {
    dif <- vapply(seq_len(nrow(SA)), function(s) {
      tg <- eng_targets(tab, e$periods, e$years, tab$sex == SA$sex[s] & tab$age_group == SA$age_group[s], wmass = wm, ST = ST, Y = eng_Y(e$source))
      g <- tryCatch(ts_generator(tg, total = sum(vapply(tg, function(z) sum(z$n), 1)), lambda = lam), error = function(err) NULL)
      if (is.null(g)) return(NA_real_)
      P2 <- ts_expm(g$Q * 2); dimnames(P2) <- list(ST, ST)
      b <- proj[proj$source == e$source & proj$model == e$model & proj$stratum == SA$stratum[s], ]
      max(abs(c(P2["N0", "N0"] + P2["N0", "FD"] - b$N0_NC, P2["FD", "N0"] + P2["FD", "FD"] - b$FD_NC,
                P2["C1", "C1"] - b$C1_C1, P2["C1", "N0"] + P2["C1", "FD"] - b$C1_NC)))
    }, 1)
    data.frame(source = e$source, model = e$model, lambda = lam, max_abs_change_reported_cells = max(dif, na.rm = TRUE), failed_fits = sum(is.na(dif)))
  }))
}))
cmp_csv(ridge, "ridge_sensitivity"); cat("ridge sensitivity:
"); print(ridge, row.names = FALSE, digits = 3)

# ---- 2. Non-drinking origin: NC = N0 + FD destinations; N0/FD origin mixture ----------------------------------------
# R7 non-drinkers cannot be split into never and former drinkers. For engines trained on EPS states, the NC -> NC
# prediction is pi * FD_NC + (1 - pi) * N0_NC: bounds at pi = 0 (all N0) and pi = 1 (all FD), and one scenario with pi
# equal to the EPS FD share among non-drinking origins of the same sex x age (unweighted counts, both EPS periods pooled).
rc <- utils::read.csv(here::here("__andres_control", "eps_markov_outputs", "row_counts_state0_by_stratum.csv"), stringsAsFactors = FALSE)
pi_fd <- do.call(rbind, lapply(seq_len(nrow(SA)), function(s) {
  z <- rc[rc$sex == SA$sex[s] & rc$age_group == SA$age_group[s], ]
  data.frame(stratum = SA$stratum[s], n_N0 = sum(z$n[z$state0 == "N0"]), n_FD = sum(z$n[z$state0 == "FD"]),
             pi_fd = sum(z$n[z$state0 == "FD"]) / sum(z$n[z$state0 %in% c("N0", "FD")]))
}))
cmp_csv(pi_fd, "eps_fd_share_scenario"); print(pi_fd, row.names = FALSE, digits = 3)
proj$pi_fd <- pi_fd$pi_fd[match(proj$stratum, pi_fd$stratum)]
proj$NC_NC_low <- pmin(proj$N0_NC, proj$FD_NC); proj$NC_NC_high <- pmax(proj$N0_NC, proj$FD_NC)
proj$NC_NC_scenario <- ifelse(proj$source == "EPS", proj$pi_fd * proj$FD_NC + (1 - proj$pi_fd) * proj$N0_NC, proj$N0_NC)
# TSM engine: R7 non-drinkers are N0 by construction (first wave), so its N0 row is used with no mixture.
proj$NC_NC_low[proj$source == "TSM"] <- proj$NC_NC_high[proj$source == "TSM"] <- proj$N0_NC[proj$source == "TSM"]

# ---- 3. Rank coupling of the cohort's own R7 and R11 margins (24 months, no conversion) ----------------------------
# ts_coupling (the TSM port of ep_coupling, five destination classes): comonotone coupling of the ordered categories within sex x age, preserving both margins. It is the
# category-level form of the JRT rank matching (ranking by grams orders NC < C1 < ... within a sex), applied here to the
# same people, so it measures the persistence a rank-matched pseudo-panel would infer from these exact margins.
rank_tab <- do.call(rbind, lapply(c("weighted", "unweighted"), function(wt) {
  M_all <- matrix(0, length(ts_Y), length(ts_Y), dimnames = list(ts_Y, ts_Y))
  per <- do.call(rbind, lapply(seq_len(nrow(SA)), function(s) {
    z <- AN[AN$sex == SA$sex[s] & AN$age_group == SA$age_group[s], ]
    w <- if (wt == "weighted") z$w else rep(1, nrow(z))
    M <- ts_coupling(z$origin, z$dest, w); M_all <<- M_all + M * sum(w)
    R <- M / ifelse(rowSums(M) > 0, rowSums(M), NA)
    data.frame(weighting = wt, stratum = SA$stratum[s], NC_NC = R["NC", "NC"], C1_C1 = R["C1", "C1"], C1_NC = R["C1", "NC"])
  }))
  R <- M_all / ifelse(rowSums(M_all) > 0, rowSums(M_all), NA)
  rbind(data.frame(weighting = wt, stratum = "All", NC_NC = R["NC", "NC"], C1_C1 = R["C1", "C1"], C1_NC = R["C1", "NC"]), per)
}))
cmp_csv(rank_tab, "rank_coupling_two_year")
eps_rank <- utils::read.csv(here::here("__andres_control", "eps_markov_outputs", "rank_matching_vs_panel.csv"), stringsAsFactors = FALSE)
eps_rank <- eps_rank[paste(eps_rank$from, eps_rank$to) %in% c("NC NC", "C1 C1", "C1 NC"), ]
eps_rank$years <- eps_years[match(eps_rank$period, eps_periods)]
cmp_csv(eps_rank, "eps_rank_vs_panel_context_4y")

# ---- 4. Original JRT method, reconstructed on the available ENPG waves ----------------------------------------------
# jrt/simulacion/Alcohol Transitions FINAL.R cannot run as is: it load()s a missing RData (the `data` and `baseline_pop`
# objects) and installs packages with pacman. Only its helper definitions are evaluated here, unmodified, in an
# environment whose parent is the dplyr namespace (the helpers call dplyr verbs without a namespace prefix).
jrt_env <- new.env(parent = getNamespace("dplyr"))
jrt_keep <- c("ALC_LEVELS", "recode_enpg_cvolaj_to_state", "as_state_factor", "preprocess_enpg_alcohol",
              "make_pseudopanel_pair", "make_pseudopanel_all", "fit_alcohol_ordinal_final", "scale_probs")
for (ex in parse(here::here("jrt", "simulacion", "Alcohol Transitions FINAL.R"), keep.source = FALSE)) {
  if (is.call(ex) && identical(class(ex[[1]]), "name") && as.character(ex[[1]]) %in% c("<-", "=") && is.name(ex[[2]]) && as.character(ex[[2]]) %in% jrt_keep) eval(ex, jrt_env)
}
stopifnot(all(jrt_keep %in% ls(jrt_env)))
enpg <- as.data.frame(readRDS(acc_data("_enpg/data_binge_sensitivity.rds.tar.xz.enc")))
oms <- utils::read.csv(here::here("__andres_control", "oms_factor_by_year.csv"))
cat("WHO anchoring factors 2012-2016:\n"); print(oms[oms$year %in% c(2012, 2014, 2016), c("year", "factor_CH")], row.names = FALSE)
jrt_years <- c(2012, 2014, 2016)   # original training: 2008-2016 (2008 and 2010 are not harmonised in this format)
# Deviation 1 (needed): in this file never and former drinkers have NA volume; the JRT preprocessing drops NA volumes,
# which would remove every non-drinker. Their volume is set to 0, as the JRT state coding (Non-drinker state) presumes.
enpg$volajohdia[enpg$cvolaj %in% c("ltabs", "fd")] <- 0
recat <- function(v, sexo) ifelse(sexo == "Mujer", as.character(cut(v, c(0, 19.99, 39.99, 100, Inf), labels = c("cat1", "cat2", "cat3", "cat4"))),
                                  as.character(cut(v, c(0, 39.99, 59.99, 100, Inf), labels = c("cat1", "cat2", "cat3", "cat4"))))
jrt_variant <- function(volume) {
  x <- enpg[enpg$year %in% jrt_years, ]
  if (volume == "raw_12g") {   # Deviation 2 (sensitivity): undo the WHO anchoring, closer to the TSM 12 g/drink volume
    cur <- x$cvolaj %in% c("cat1", "cat2", "cat3", "cat4")
    x$volajohdia <- x$volajohdia / oms$factor_CH[match(x$year, oms$year)]
    x$cvolaj[cur] <- recat(x$volajohdia[cur], x$sexo[cur])
  }
  clean <- jrt_env$preprocess_enpg_alcohol(x)
  # Equivalence check of the fast pairing below against the original many-to-many join on one stratum.
  fast_pair <- function(df_t, df_t2) {
    out <- lapply(split(df_t, list(df_t$sex, df_t$agecat), drop = TRUE), function(a) {
      b <- df_t2[df_t2$sex == a$sex[1] & df_t2$agecat == a$agecat[1], ]
      a <- a[order(a$gpd, seq_len(nrow(a))), ]; b <- b[order(b$gpd, seq_len(nrow(b))), ]
      u <- (seq_len(nrow(a)) - .5) / nrow(a); k <- pmin(pmax(round(u * nrow(b)), 1), nrow(b))
      data.frame(id_t = a$id, sex = a$sex, agecat = a$agecat, state_t = a$state_ord, state_t2 = b$state_ord[k],
                 year_t = a$year, year_t2 = b$year[k])
    })
    do.call(rbind, out)
  }
  a1 <- clean[clean$year == jrt_years[1] & clean$sex == "F" & clean$agecat == "4", ]
  b1 <- clean[clean$year == jrt_years[2] & clean$sex == "F" & clean$agecat == "4", ]
  orig <- as.data.frame(jrt_env$make_pseudopanel_pair(a1, b1, seed = 1))
  fast <- fast_pair(a1, b1)
  stopifnot(identical(as.character(orig$state_t2[order(orig$id_t)]), as.character(fast$state_t2[order(fast$id_t)])))
  pp <- do.call(rbind, lapply(seq_len(length(jrt_years) - 1), function(i)
    fast_pair(clean[clean$year == jrt_years[i], ], clean[clean$year == jrt_years[i + 1], ])))
  pp$dt <- pp$year_t2 - pp$year_t
  fit <- jrt_env$fit_alcohol_ordinal_final(pp)
  lev <- jrt_env$ALC_LEVELS
  per <- do.call(rbind, lapply(1:4, function(ag) do.call(rbind, lapply(c("M", "F"), function(sx) {
    nd <- data.frame(state_t = factor(lev, levels = lev), sex = factor(sx, levels = c("F", "M")), agecat = factor(ag, levels = 1:4))
    P <- stats::predict(fit, newdata = nd, type = "probs"); dimnames(P) <- list(lev, lev)
    Pt <- jrt_env$scale_probs(P, alpha = 0.5); dimnames(Pt) <- list(lev, lev); P2t <- Pt %*% Pt
    data.frame(volume = volume, sex = ifelse(sx == "M", "Men", "Women"), age_group = ts_ages[ag],
      NC_NC = P["Non-drinker", "Non-drinker"], C1_C1 = P["Cat1", "Cat1"], C1_NC = P["Cat1", "Non-drinker"],
      tempered2_NC_NC = P2t["Non-drinker", "Non-drinker"], tempered2_C1_C1 = P2t["Cat1", "Cat1"], tempered2_C1_NC = P2t["Cat1", "Non-drinker"])
  }))))
  per$stratum <- paste(per$sex, per$age_group)
  jrt_audit[[volume]] <<- data.frame(volume = volume, training_years = paste(jrt_years, collapse = "-"), pseudo_pairs = nrow(pp),
    rows_after_preprocess = nrow(clean), polr_convergence = fit$convergence, polr_iterations = fit$niter[1],
    nondrinker_share_t = mean(pp$state_t == "Non-drinker"), cat1_share_t = mean(pp$state_t == "Cat1"),
    pairing_equivalence_check = "fast pairing identical to make_pseudopanel_pair (women, agecat 4, 2012-2014)")
  per
}
jrt_audit <- list()
jrt <- rbind(jrt_variant("who_anchored"), jrt_variant("raw_12g"))
cmp_csv(jrt, "jrt_original_reconstructed"); cmp_csv(do.call(rbind, jrt_audit), "jrt_original_audit")
print(do.call(rbind, jrt_audit), row.names = FALSE)

# ---- 5. Comparison table: observed vs comparators, global and per stratum ------------------------------------------
# Global model values are standardised to the cohort: the average of the stratum predictions weighted by the R7
# weights of the analyzable people with that origin in each stratum (the pooled P2 of the published annual matrices
# reflects the training composition and is kept only as a check line).
obs <- tr_sexage[tr_sexage$set %in% c("Global", "Sex_age") & tr_sexage$origin %in% c("NC", "C1") & tr_sexage$destination %in% c("NC", "C1"), ]
obs$stratum <- ifelse(obs$set == "Global", "All", obs$group)
outs <- data.frame(outcome = c("NC_NC", "C1_C1", "C1_NC"), origin = c("NC", "C1", "C1"), dest = c("NC", "C1", "NC"))
mass <- function(o, s) sum(AN$w[AN$origin == o & paste(AN$sex, AN$age_group) == s])
stdz <- function(vals, strata, o) { m <- vapply(strata, function(s) mass(o, s), 1); ok <- is.finite(vals) & m > 0; if (!any(ok)) NA_real_ else sum(vals[ok] * m[ok]) / sum(m[ok]) }
rowsets <- list()
for (k in seq_len(nrow(outs))) for (s in c("All", SA$stratum)) {
  o <- outs$origin[k]; dd <- outs$dest[k]; ob <- obs[obs$stratum == s & obs$origin == o & obs$destination == dd, ]
  pick <- function(src, mdl, col) {
    z <- proj[proj$source == src & proj$model == mdl, ]
    if (s == "All") stdz(z[[col]], z$stratum, o) else z[[col]][z$stratum == s]
  }
  jr <- function(vol, col) { z <- jrt[jrt$volume == vol, ]; if (s == "All") stdz(z[[col]], z$stratum, o) else z[[col]][z$stratum == s] }
  rk <- function(wt) rank_tab[[outs$outcome[k]]][rank_tab$weighting == wt & rank_tab$stratum == s]
  base <- outs$outcome[k]
  ec <- function(mdl) if (base == "NC_NC") c(pick("EPS", mdl, "N0_NC"), pick("EPS", mdl, "FD_NC"), pick("EPS", mdl, "NC_NC_scenario")) else rep(pick("EPS", mdl, base), 3)
  eA <- ec("A"); eL <- ec("Lognormal"); eJ <- ec("JRT_reference")
  rowsets[[length(rowsets) + 1]] <- data.frame(stratum = s, outcome = base, n_origin = ob$n_origin, n_cell = ob$n_cell,
    obs_weighted = ob$p_weighted, obs_lo = ob$lo, obs_hi = ob$hi, obs_unweighted = ob$p_unweighted, flag = ob$flag,
    eps_A = eA[3], eps_A_allN0 = eA[1], eps_A_allFD = eA[2], eps_LN = eL[3], eps_LN_allN0 = eL[1], eps_LN_allFD = eL[2],
    jrt_ref = eJ[3], jrt_ref_allN0 = eJ[1], jrt_ref_allFD = eJ[2],
    tsm_A = pick("TSM", "A", if (base == "NC_NC") "N0_NC" else base), tsm_LN = pick("TSM", "Lognormal", if (base == "NC_NC") "N0_NC" else base),
    jrt_orig_who = jr("who_anchored", base), jrt_orig_raw = jr("raw_12g", base),
    jrt_orig_tempered2_who = jr("who_anchored", paste0("tempered2_", base)),
    rank_weighted = rk("weighted"), rank_unweighted = rk("unweighted"), stringsAsFactors = FALSE)
}
cmp <- do.call(rbind, rowsets)
cmp$stratum <- factor(cmp$stratum, c("All", SA$stratum)); cmp <- cmp[order(cmp$outcome != "NC_NC", cmp$outcome, cmp$stratum), ]
cmp$stratum <- as.character(cmp$stratum)
cmp_csv(cmp, "two_year_comparison")
# Check line: pooled P2 of the published annual matrices vs the cohort-standardised global value.
old <- utils::read.csv(file.path(out, "model_two_year_predictions.csv"), stringsAsFactors = FALSE)
chk <- do.call(rbind, lapply(list(c("EPS", "A", "eps_A"), c("EPS", "Lognormal", "eps_LN"), c("TSM", "A", "tsm_A"), c("TSM", "Lognormal", "tsm_LN")), function(m) {
  g <- function(o, d) old$p_2y[old$source == m[1] & old$model == m[2] & old$origin == o & old$destination == d]
  data.frame(source = m[1], model = m[2],
    C1_C1_pooled_P2 = g("C1", "C1"), C1_C1_standardised = cmp[[m[3]]][cmp$stratum == "All" & cmp$outcome == "C1_C1"],
    C1_NC_pooled_P2 = g("C1", "NC"), C1_NC_standardised = cmp[[m[3]]][cmp$stratum == "All" & cmp$outcome == "C1_NC"],
    N0_NC_pooled_P2 = g("N0", "NC"),
    N0_NC_standardised = if (m[1] == "EPS") cmp[[paste0(m[3], "_allN0")]][cmp$stratum == "All" & cmp$outcome == "NC_NC"] else cmp[[m[3]]][cmp$stratum == "All" & cmp$outcome == "NC_NC"])
}))
cmp_csv(chk, "pooled_vs_standardised_check")
cat("comparison (global):\n"); print(cmp[cmp$stratum == "All", ], row.names = FALSE, digits = 3)
cat("pooled vs standardised:\n"); print(chk, row.names = FALSE, digits = 3)
cat(sprintf("Elapsed: %.2f minutes (comparators %.2f)\n", as.numeric(difftime(Sys.time(), .t_cmp0, units = "mins")),
            as.numeric(difftime(Sys.time(), .t1, units = "mins"))))
