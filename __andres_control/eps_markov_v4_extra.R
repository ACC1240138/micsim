.t0 <- Sys.time()
# EPS v4: additional definitions for eps_markov_transitions_v4_EN.ipynb, layered over the executed v2 notebook.
# Functions only, prefixed ep_v4_. They reuse the v1 core (eps_markov_core.R) and the v2 layer (eps_markov_v2_extra.R)
# without modifying them. Decisions (2026-10-26, __andres_control/decision_categorias_who_12g_2026-10-26.md): WHO border
# convention without gaps, 12 g per drink, C3 and C4 always merged into C3plus (C4 kept only as a tail diagnostic),
# EPS 2009 (round IV) used only as history, widened age tolerance for links. Row-level objects stay in memory; every
# export is an aggregate. Each '# @@eps-v4-def-<topic>' line starts a chunk that the notebook shows and explains.

# @@eps-v4-def-config
# One named list holds every v4 switch, so the reproducibility table can print it and the regression test can turn
# all v4 changes off at once (ep_v4_off reproduces the v1/v2 classification, links and history).
ep_v4_cfg <- list(rule = "WHO", grams = 12, tol = 3L, use09 = TRUE, win09 = c(6, 8), propagate_longterm = TRUE)
ep_v4_off <- modifyList(ep_v4_cfg, list(rule = "JRT", tol = 0L, use09 = FALSE, propagate_longterm = FALSE))
ep_v4_ST <- c("N0", "FD", "C1", "C2", "C3plus")
# Object fingerprint used to prove that the v4 sections leave the v1/v2 objects untouched.
ep_v4_digest <- function(x) { f <- tempfile(); on.exit(unlink(f)); saveRDS(x, f, compress = FALSE); unname(tools::md5sum(f)) }
ep_v4_Y <- c("NC", "C1", "C2", "C3plus")

# @@eps-v4-def-scoped
# Several v1/v2 functions read the globals ep_time (link windows) and ep_period_mass (pair counts used to renormalise
# weights). v4 needs other values for some calls but must leave the v1/v2 cells untouched, so it swaps the globals only
# while one expression runs and restores them on exit, even after an error.
ep_v4_scoped <- function(vals, expr) {
  env <- globalenv(); had <- vapply(names(vals), exists, TRUE, envir = env, inherits = FALSE)
  old <- mget(names(vals)[had], envir = env)
  on.exit({ for (k in names(old)) assign(k, old[[k]], envir = env)
            rm(list = names(vals)[!had], envir = env) }, add = TRUE)
  for (k in names(vals)) assign(k, vals[[k]], envir = env)
  force(expr)
}

# @@eps-v4-def-classification
# Grams per day are compared on the observation lattice: with 12 g per drink and 'less than weekly' coded as 0.5 days,
# EPS grams per day are multiples of grams / 14 (6/7 g). Working in lattice units k = g * 14 / grams avoids floating-point
# ties such as 59.99999. WHO: the exact border value goes to the LOWER class (C1 g <= lo, C2 lo < g <= hi,
# C3 hi < g <= top, C4 g > top). JRT/v1: lower borders go up (g < lo, lo <= g < hi), top stays in C3 (g <= top).
# Both rules are contiguous, so every current drinker with g > 0 gets exactly one class (no gaps).
ep_v4_cuts <- function(sex) list(lo = ifelse(sex == "Women", 20, 40), hi = ifelse(sex == "Women", 40, 60),
                                 top = ifelse(sex == "Women", 60, 100))
ep_v4_cat <- function(current, g, sex, rule = ep_v4_cfg$rule, grams = ep_v4_cfg$grams) {
  rule <- match.arg(rule, c("WHO", "JRT")); u <- 14 / grams; ct <- ep_v4_cuts(sex)
  k <- round(g * u, 6); lo <- round(ct$lo * u, 6); hi <- round(ct$hi * u, 6); top <- round(ct$top * u, 6)
  ans <- rep(NA_character_, length(g)); ok <- current %in% 1 & is.finite(g) & g > 0
  if (rule == "WHO") {
    ans[ok & k <= lo] <- "C1"; ans[ok & k > lo & k <= hi] <- "C2"; ans[ok & k > hi & k <= top] <- "C3"; ans[ok & k > top] <- "C4"
  } else {
    ans[ok & k < lo] <- "C1"; ans[ok & k >= lo & k < hi] <- "C2"; ans[ok & k >= hi & k <= top] <- "C3"; ans[ok & k > top] <- "C4"
  }
  stopifnot(all(!is.na(ans[ok])))   # contiguous classes: no gaps
  ans
}
ep_v4_merge <- function(x) ifelse(x %in% c("C3", "C4"), "C3plus", as.character(x))
ep_v4_border_ties <- function(W) {
  d <- W[W$current %in% 1 & is.finite(W$grams) & W$grams > 0, ]
  do.call(rbind, lapply(c(20, 40, 60, 100), function(b) do.call(rbind, lapply(c("Women", "Men"), function(s) do.call(rbind,
    lapply(c(sort(unique(d$wave)), "All"), function(w) {
      i <- d$sex == s & (w == "All" | d$wave == w); hit <- i & abs(d$grams - b) < 1e-8
      data.frame(border = b, sex = s, wave = w, drinkers = sum(i), exact = sum(hit), exact_weighted = sum(d$weight_xs[hit]),
        is_a_cut_for_sex = b %in% unlist(ep_v4_cuts(s)))
    }))))))
}

# @@eps-v4-def-history2009
# EPS 2009 (round IV) has the same three alcohol items as VI-VIII under zero-padded names (f13_01, f14_01, f15_01, ...).
# One coding difference matters: 2009 F14 runs 1..8 (1 = less than one day a week, 8 = every day; 88/99 missing)
# while VI-VIII run 0..7, so 2009 is shifted down by one before the unchanged eps_alcohol() conversion. Sex and age
# come from entrevistado.dta (a8, a9); the 2009 file has a cross-sectional weight but no PSU or stratum, so 2009 is
# used only as history for later waves, never as a transition interval.
ep_v4_load09 <- function(grams = ep_v4_cfg$grams) {
  dir09 <- file.path(eps_root, "2009", "2009")
  s <- haven::read_dta(file.path(dir09, "salud.dta"))
  e <- haven::read_dta(file.path(dir09, "entrevistado.dta"), col_select = c("folio_n20", "a8", "a9"))
  w <- haven::read_dta(file.path(dir09, "factor_EPS09.dta"))
  id <- as.character(s$folio_n20)
  stopifnot(!anyNA(id), !anyDuplicated(id), setequal(id, as.character(e$folio_n20)), setequal(id, as.character(w$folio_n20)))
  j <- match(id, as.character(e$folio_n20)); k <- match(id, as.character(w$folio_n20))
  sex <- ifelse(as.numeric(e$a8[j]) == 1, "Men", ifelse(as.numeric(e$a8[j]) == 2, "Women", NA_character_))
  item <- function(p) vapply(1:3, function(i) as.numeric(s[[sprintf("%s_%02d", p, i)]]), numeric(length(id)))
  s13 <- item("f13"); f14 <- item("f14"); q15 <- item("f15")
  f14 <- ifelse(f14 %in% 1:8, f14 - 1, NA_real_)   # 2009 codes 1..8 -> VI codes 0..7
  stopifnot(all(is.na(f14) | s13 %in% 1))           # skip pattern: frequency is answered only by beverage drinkers
  al <- eps_alcohol(s13, f14, q15, sex, grams = grams)
  stopifnot(sum(al$contradiction, na.rm = TRUE) == 0)
  data.frame(id = id, age = as.numeric(e$a9[j]), sex = sex, weight = as.numeric(w$factor_EPS09[k]),
             current = al$current, grams_day = al$grams_day, contradiction = al$contradiction)
}
ep_v4_link_audit <- function(h09, W, windows = list(c(6, 8), c(5, 7), c(4, 8)), tols = 0:3) {
  v <- W[W$wave == "VI", ]; j <- match(v$id, h09$id); ok <- !is.na(j)
  gap <- v$age[ok] - h09$age[j[ok]]; same <- v$sex[ok] == h09$sex[j[ok]]
  dist <- as.data.frame(table(gap = pmin(pmax(gap[same %in% TRUE], 2), 10)))
  acc <- do.call(rbind, lapply(windows, function(wi) do.call(rbind, lapply(tols, function(t)
    data.frame(window = sprintf("[%g,%g]", wi[1], wi[2]), tol = t, VI_respondents = nrow(v), with_2009_record = sum(ok),
      sex_mismatch = sum(!same, na.rm = TRUE), accepted = sum(same & gap >= wi[1] - t & gap <= wi[2] + t, na.rm = TRUE))))))
  list(accepted = acc, gap_distribution = dist)
}

# @@eps-v4-def-waves-risk
# ep_v4_time widens every link window by tol years on both sides (as TSM does) and, when 2009 is used, appends one
# history-only row IV_2009 -> VI. It stays history-only because the risk set, IPW, CV and annual layer loop over
# ep_periods, not over ep_time. ep_v4_waves is a copy of ep_waves (eps_markov_core.R) with four edits: it may append the
# 2009 rows, it also builds history AT wave VI, it reads link bounds from 'time', and it takes the classification
# function. With tol = 0, no 2009 and ep_cat it returns exactly ep_waves(12) (checked in the reproducibility section).
# Long-term abstention follows Calvo et al. (2020): no drinking for at least four years and no evidence of earlier
# drinking. A negative pair at least four years apart sets it; with propagate = TRUE a current non-drinker linked to an
# earlier long-term abstainer keeps the flag (the four-year span then holds a fortiori). Any observed drinking clears it.
ep_v4_time <- function(tol = ep_v4_cfg$tol, history09 = ep_v4_cfg$use09, win09 = ep_v4_cfg$win09, base = ep_time) {
  t <- base; t$min_years <- t$min_years - tol; t$max_years <- t$max_years + tol
  t$strict_min <- base$min_years
  if (history09) t <- rbind(data.frame(period = "IV_VI", from = "IV_2009", to = "VI", years = NA_real_,
    min_years = win09[1] - tol, max_years = win09[2] + tol, strict_min = win09[1]), t)
  t
}
ep_v4_waves <- function(grams = 12, h09 = NULL, time = ep_time, cat_fun = ep_cat, propagate = FALSE, longterm_min = 4) {
  W <- do.call(rbind, lapply(names(eps_data), function(w) {
    d <- eps_data[[w]]; j <- match(d$id, ep_design_map$id); g <- d$grams_day * grams / 12
    data.frame(id = d$id, wave = w, age = d$age, sex = d$sex, education = d$education,
      weight_xs = d$weight, psu = ep_design_map$psu[j], strata = ep_design_map$strata[j],
      current = ifelse(d$contradiction, NA_real_, d$current), grams = g,
      cat = ifelse(d$contradiction, NA_character_, cat_fun(d$current, g, d$sex)), signal = ep_qsignal(d))
  }))
  if (!is.null(h09)) {
    g <- h09$grams_day * grams / 12
    W <- rbind(W, data.frame(id = h09$id, wave = "IV_2009", age = h09$age, sex = h09$sex, education = NA_character_,
      weight_xs = h09$weight, psu = NA_character_, strata = NA_character_,
      current = ifelse(h09$contradiction, NA_real_, h09$current), grams = g,
      cat = ifelse(h09$contradiction, NA_character_, cat_fun(h09$current, g, h09$sex)), signal = NA_real_))
  }
  W$prior_use <- FALSE; W$longterm <- FALSE; W$two_wave_negative <- FALSE
  for (w in c("VI", "VII_presencial", "VIII")) {
    ii <- which(W$wave == w)
    for (j in which(time$to == w)) {
      tm <- time[j, ]; a <- W[W$wave == tm$from, ]; if (!nrow(a)) next
      ix <- match(W$id[ii], a$id)
      # time already carries any tolerance; floor/ceiling as in the v1 rule
      ok <- !is.na(ix) & a$sex[ix] == W$sex[ii] & W$age[ii] - a$age[ix] >= floor(tm$min_years) &
        W$age[ii] - a$age[ix] <= ceiling(tm$max_years)
      ok <- ok %in% TRUE
      W$prior_use[ii] <- W$prior_use[ii] | (ok & (a$current[ix] %in% 1 | a$prior_use[ix] %in% TRUE))
      neg <- ok & a$current[ix] %in% 0 & W$current[ii] %in% 0
      W$two_wave_negative[ii] <- W$two_wave_negative[ii] | neg
      # The four-year Calvo span is judged on the strict (unwidened) window when ep_v4_time supplied it.
      span <- if (!is.null(tm$strict_min)) tm$strict_min else tm$min_years
      if (span >= longterm_min) W$longterm[ii] <- W$longterm[ii] | neg
      if (propagate) W$longterm[ii] <- W$longterm[ii] | (ok & W$current[ii] %in% 0 & a$longterm[ix] %in% TRUE)
    }
  }
  W$longterm <- W$longterm & !W$prior_use
  W$two_wave_negative <- W$two_wave_negative & !W$prior_use
  W$state <- ifelse(W$current %in% 1, W$cat,
                     ifelse(W$current %in% 0, ifelse(W$prior_use, "FD", "N0"), NA_character_))
  W
}
# v4 risk set: the v2 risk set (deaths and impeded removed, v2 covariates attached) built from v4 waves and v4 link
# windows, kept in six states for the v1 IPW (whose response model uses state0), with merged five-state copies added.
ep_v4_make_risk <- function(W, time, exits, cov) {
  r <- ep_v4_scoped(list(ep_time = time), ep_v2_make_risk(W, exits, cov))
  r$state0_6 <- r$state0; r$state1_6 <- r$state1
  r$state0_5 <- factor(ep_v4_merge(r$state0), levels = ep_v4_ST)
  r$state1_5 <- ep_v4_merge(r$state1)
  r$y1_5 <- factor(ifelse(r$state1_5 %in% c("N0", "FD"), "NC", r$state1_5), levels = ep_v4_Y)
  r
}
ep_v4_period_mass <- function(r) vapply(ep_periods, function(p) sum(r$period == p & r$complete), 1)
# v1 IPW refitted on a v4 risk set and applied with that risk set's own pair counts.
ep_v4_ipw <- function(r) {
  mass <- ep_v4_period_mass(r)
  ep_v4_scoped(list(ep_period_mass = mass), ep_ipw_apply(r, ep_ipw_fit(r)))
}

# @@eps-v4-def-history-tables
# What EPS 2009 changes, before any amount model: who moves from N0 to FD, who becomes a long-term abstention candidate,
# and how the observed VI->VII and VII->VIII matrices move. W0/W9 differ only in the 2009 history (same rule, tolerance).
ep_v4_reclass <- function(W0, W9, waves = c("VI", "VII_presencial", "VIII")) {
  a <- W0[W0$wave %in% waves & W0$age >= 18 & W0$age <= 65, ]; b <- W9[match(paste(a$id, a$wave), paste(W9$id, W9$wave)), ]
  stopifnot(!anyNA(b$wave))
  other <- (a$state %in% b$state | (is.na(a$state) & is.na(b$state))) | (a$state %in% "N0" & b$state %in% "FD")
  stopifnot(all(other))   # the only allowed state change is N0 -> FD
  a$age_group <- ep_age(a$age); a$to_fd <- a$state %in% "N0" & b$state %in% "FD"; a$new_lt <- !a$longterm & b$longterm
  a$n0 <- a$state %in% "N0"; a$lt9 <- b$longterm %in% TRUE
  key <- function(d, by) split(d, d[by], drop = TRUE)
  rows <- function(by) do.call(rbind, lapply(key(a, by), function(z) data.frame(z[1, by, drop = FALSE],
    N0_without_2009 = sum(z$n0), N0_to_FD = sum(z$to_fd), pct_of_N0 = 100 * sum(z$to_fd) / max(sum(z$n0), 1),
    N0_to_FD_weighted = sum(z$weight_xs[z$to_fd]), longterm_without_2009 = sum(z$longterm), longterm_with_2009 = sum(z$lt9),
    longterm_cleared_by_2009_drinking = sum(z$longterm & !z$lt9),
    new_longterm = sum(z$new_lt), new_longterm_weighted = sum(z$weight_xs[z$new_lt]))))
  out <- rbind(cbind(level = "wave x sex x age", rows(c("wave", "sex", "age_group"))),
               cbind(level = "wave x sex", rows(c("wave", "sex")), age_group = "All"),
               cbind(level = "wave", rows("wave"), sex = "All", age_group = "All"))
  out <- out[c("level", "wave", "sex", "age_group", setdiff(names(out), c("level", "wave", "sex", "age_group")))]
  rownames(out) <- NULL; out
}
# Weighted observed transition matrix (five states x four destinations) of complete pairs, by period and sex.
ep_v4_obs_matrix <- function(d, by = c("period", "sex")) {
  d$grp <- if (length(by)) do.call(paste, c(lapply(d[by], as.character), sep = "|")) else "All"
  do.call(rbind, lapply(split(d, d$grp), function(z) {
    m <- stats::xtabs(wn ~ state0_5 + y1_5, z); n <- table(z$state0_5)
    out <- as.data.frame(as.table(m), stringsAsFactors = FALSE); names(out) <- c("from", "to", "weighted")
    tot <- tapply(out$weighted, out$from, sum); out$estimate <- ifelse(tot[out$from] > 0, out$weighted / tot[out$from], NA_real_)
    out$n_origin <- as.integer(n[out$from]); out$group <- z$grp[1]; out
  }))
}
ep_v4_matrix_shift <- function(d0, d9, by = c("period", "sex")) {
  m0 <- ep_v4_obs_matrix(d0, by); m9 <- ep_v4_obs_matrix(d9, by)
  k <- paste(m0$group, m0$from, m0$to); m9 <- m9[match(k, paste(m9$group, m9$from, m9$to)), ]
  data.frame(group = m0$group, from = m0$from, to = m0$to, n_origin_without_2009 = m0$n_origin, n_origin_with_2009 = m9$n_origin,
    p_without_2009 = m0$estimate, p_with_2009 = m9$estimate, change = m9$estimate - m0$estimate, row.names = NULL)
}

# @@eps-v4-def-amount-models
# Amount of drinking among destination drinkers. Every model returns a CDF of grams/day given covariates, so class
# probabilities come from the same integration for all of them: P(C1) = F(lo), P(C2) = F(hi) - F(lo), P(C3plus) =
# 1 - F(hi) and, as a tail diagnostic only, P(C4) = 1 - F(top). For a continuous CDF, <= and < give the same
# probability, so the WHO border rule changes observed labels, not predictions. Weights are the IPW pair weights
# normalised to mean one (frequency weights, as in v1). Covariates are the v1 formula with the five-state origin.
#   Lognormal, Gamma: the v1 fits (ep_matrix_fit), unchanged.
#   Lognormal_sexage: log-grams variance by sex x age group, shrunk toward the pooled variance with strength k
#     (sigma2_g = (sum w r^2 + k sigma2_0) / (sum w + k)); location refitted by weighted least squares with weights
#     w / sigma2_g, three alternations. k = Inf gives the v1 lognormal; k is tuned by inner cross-validation.
#   Lognormal_Pareto: lognormal up to a sex-specific threshold u (training weighted 90th percentile of grams among
#     drinkers, required below the C3plus cut); above u, a Pareto tail 1 - F(t) = (1 - F_LN(u | x)) (u / t)^alpha_sex with
#     the weighted Hill estimator alpha = sum(w) / sum(w log(g / u)) over exceedances. The mass above u still comes from
#     the lognormal; only the shape of the tail changes.
#   Hurdle_Pareto (mixture): a logistic model gives pi(x) = P(g > hi | drinking, x); below hi the lognormal is
#     truncated to (0, hi]; above hi a Pareto tail with alpha_sex estimated on exceedances of hi.
# The C3plus share is set directly by the logistic part in Hurdle_Pareto, so its aggregate calibration is good by
# construction; the per-cell calibration (interval x origin, sex x age) is what can separate it from the others.
ep_v4_formula <- function() ep_formula("ordinal")
ep_v4_h <- function(grams = ep_v4_cfg$grams) grams / 14   # lattice step of observed grams/day (6/7 g at 12 g)
ep_v4_hill <- function(g, w, u) { e <- g > u; if (sum(e) < 5) return(NA_real_); sum(w[e]) / sum(w[e] * log(g[e] / u)) }
# Tail exponent by sex; a sex with fewer than 5 exceedances falls back to the exponent pooled over both sexes
# (exceedances of each sex's own threshold), and the fallback is recorded.
ep_v4_alpha <- function(dc, w, u) {
  sx <- c("Men", "Women"); a <- vapply(sx, function(s) { i <- dc$sex == s; ep_v4_hill(dc$grams1[i], w[i], u[[s]]) }, 1)
  n <- vapply(sx, function(s) sum(dc$sex == s & dc$grams1 > u[[s]]), 1)
  pooled <- { e <- dc$grams1 > u[as.character(dc$sex)]
    if (sum(e) < 5) stop("Fewer than 5 tail exceedances in both sexes: the Pareto exponent is not estimable")
    sum(w[e]) / sum(w[e] * log(dc$grams1[e] / u[as.character(dc$sex)][e])) }
  fb <- !is.finite(a); a[fb] <- pooled; stopifnot(all(is.finite(a)), all(a > 0))
  structure(a, exceedances = n, fallback = fb)
}
ep_v4_cap <- 150   # grams/day cap for tail draws and tail means (the AAF integration bound in JRT and ADD-25-1576)
ep_v4_lnfit <- function(dc) ep_matrix_fit(dc, ep_v4_formula(), dc$grams1, "lognormal")
ep_v4_eta <- function(o, d) as.numeric(ep_x(d, o$formula, o$columns) %*% o$coef)
ep_v4_sexage_fit <- function(dc, k, base = ep_v4_lnfit(dc), iter = 3) {
  o <- base; if (is.infinite(k)) { o$sigma_g <- NULL; return(o) }
  X <- ep_x(dc, o$formula, o$columns); y <- log(dc$grams1); w <- dc$wn / mean(dc$wn); g <- paste(dc$sex, dc$age_group)
  for (i in seq_len(iter)) {
    r <- y - as.numeric(X %*% o$coef); s0 <- sum(w * r^2) / sum(w)
    s2 <- c(tapply(w * r^2, g, sum)); ws <- c(tapply(w, g, sum)); s2 <- (s2 + k * s0) / (ws + k)
    o$coef <- stats::lm.wfit(X, y, as.numeric(w / s2[g]))$coefficients; o$coef[!is.finite(o$coef)] <- 0
  }
  r <- y - as.numeric(X %*% o$coef); s0 <- sum(w * r^2) / sum(w)
  s2 <- (c(tapply(w * r^2, g, sum)) + k * s0) / (c(tapply(w, g, sum)) + k)
  o$sigma_g <- sqrt(s2); o$sigma <- sqrt(s0); o$k <- k; o
}
ep_v4_sigma <- function(o, d) {
  if (is.null(o$sigma_g)) return(rep(o$sigma, nrow(d)))
  s <- o$sigma_g[paste(d$sex, d$age_group)]; s[is.na(s)] <- o$sigma; as.numeric(s)
}
# Fit one amount model on training destination drinkers dc; returns list(kind, cdf = function(t, d) -> matrix).
ep_v4_amount_fit <- function(dc, kind, k = NULL) {
  hi <- function(sex) ep_v4_cuts(sex)$hi; w <- dc$wn / mean(dc$wn)
  ln <- ep_v4_lnfit(dc)
  lncdf <- function(o) function(t, d) stats::pnorm((log(pmax(t, 1e-12)) - ep_v4_eta(o, d)) / ep_v4_sigma(o, d))
  if (kind == "Lognormal") return(list(kind = kind, cdf = lncdf(ln), fit = ln))
  if (kind == "Gamma") {
    ga <- ep_matrix_fit(dc, ep_v4_formula(), dc$grams1, "gamma")
    return(list(kind = kind, fit = ga, cdf = function(t, d) {
      mu <- exp(ep_v4_eta(ga, d)); stats::pgamma(t, shape = ga$shape, scale = mu / ga$shape) }))
  }
  if (kind == "Lognormal_sexage") { o <- ep_v4_sexage_fit(dc, k, ln); return(list(kind = kind, cdf = lncdf(o), fit = o, k = k)) }
  if (kind == "Lognormal_Pareto") {
    sx <- c("Men", "Women")
    u <- vapply(sx, function(s) { i <- dc$sex == s; ep_wquant(dc$grams1[i], w[i], .9) }, 1)
    u <- pmin(u, vapply(sx, hi, 1) - ep_v4_h())   # keep the splice below the C3plus cut
    a <- ep_v4_alpha(dc, w, u)
    F0 <- lncdf(ln)
    return(list(kind = kind, u = u, alpha = a, fit = ln, cdf = function(t, d) {
      uu <- u[as.character(d$sex)]; aa <- a[as.character(d$sex)]; Fu <- F0(matrix(uu), d)[, 1]
      tail <- 1 - (1 - Fu) * (uu / pmax(t, 1e-12))^aa
      ifelse(t <= uu, F0(t, d), tail) }))
  }
  if (kind %in% c("Hurdle_Pareto", "Hurdle_Pareto_ridge")) {
    h <- hi(dc$sex); top_class <- dc$grams1 > h
    # The tail indicator must be the observed WHO label (lattice-rounded cuts), not a separate float comparison.
    if (!is.null(dc$y1_5)) stopifnot(identical(top_class, as.character(dc$y1_5) == "C3plus"))
    pm <- if (kind == "Hurdle_Pareto") ep_binary_fit(dc, as.numeric(top_class), ep_v4_formula(), dc$wn) else
      ep_v4_ridge_fit(dc, as.numeric(top_class), ep_v4_formula(), dc$wn)
    pfun <- if (kind == "Hurdle_Pareto") ep_binary_prob else ep_v4_ridge_prob
    sx <- c("Men", "Women")
    a <- ep_v4_alpha(dc, w, stats::setNames(vapply(sx, hi, 1), sx))
    F0 <- lncdf(ln)
    return(list(kind = kind, alpha = a, fit = ln, tail_model = pm, cdf = function(t, d) {
      hh <- hi(d$sex); pi <- pfun(pm, d); aa <- a[as.character(d$sex)]; Fh <- F0(matrix(hh), d)[, 1]
      body <- (1 - pi) * F0(t, d) / Fh; tail <- 1 - pi * (hh / pmax(t, 1e-12))^aa
      ifelse(t <= hh, body, tail) }))
  }
  stop("unknown amount model ", kind)
}
# Sensitivity only (added after the pre-registered comparison, not eligible for adoption): the unpenalised hurdle
# logistic is quasi-separated (women 60-65 have no C3plus destination, and edu_missing is nearly empty), which makes
# P(C3plus) a structural zero for those cells. A ridge logistic (glmnet, alpha = 0, lambda by 5-fold CV with
# person-blocked folds) keeps those probabilities small but positive.
ep_v4_ridge_fit <- function(d, y, formula, w, seed = ep_seed) {
  X <- ep_x(d, formula); X <- X[, colnames(X) != "(Intercept)", drop = FALSE]; ww <- w / mean(w)
  ids <- unique(d$id); set.seed(seed); fid <- stats::setNames(sample(rep(1:5, length.out = length(ids))), ids)
  cv <- glmnet::cv.glmnet(X, y, family = "binomial", weights = ww, alpha = 0, foldid = as.integer(fid[d$id]))
  list(fit = cv, formula = formula, columns = colnames(X), lambda = cv$lambda.min)
}
ep_v4_ridge_prob <- function(o, d) {
  X <- ep_x(d, o$formula); X <- X[, o$columns, drop = FALSE]
  as.numeric(stats::predict(o$fit, newx = X, s = o$lambda, type = "response"))
}
# Grams lattice log score of observed destination grams: -log P(g - h/2 < G <= g + h/2).
ep_v4_cellscore <- function(fit, d, g) {
  h <- ep_v4_h(); up <- fit$cdf(matrix(g + h / 2), d)[, 1]; lo <- fit$cdf(matrix(pmax(g - h / 2, 0)), d)[, 1]
  -log(pmax(up - lo, 1e-12))
}
# Truncated tail moments for E[g | hi < g <= cap]: num = E[g 1{hi < G <= cap}], den = P(hi < G <= cap), by the identity
# E[G 1{a < G <= b}] = a (F(b) - F(a)) + integral_a^b (F(b) - F(t)) dt, integrated on a 200-point grid (trapezoid).
ep_v4_tailmean <- function(fit, d, cap = ep_v4_cap, n = 200) {
  a <- ep_v4_cuts(d$sex)$hi; s <- seq(0, 1, length.out = n); T <- outer(cap - a, s) + a
  F <- fit$cdf(T, d); Fb <- F[, n]; inner <- (Fb - F); dt <- (cap - a) / (n - 1)
  integral <- dt * (rowSums(inner) - (inner[, 1] + inner[, n]) / 2)
  list(num = a * (Fb - F[, 1]) + integral, den = pmax(Fb - F[, 1], 0))
}
# Inner 3-fold tuning of k for Lognormal_sexage on training drinkers, by the lattice log score.
ep_v4_tune_sexage <- function(dc, grid = c(ep_kgrid, Inf), seed = ep_seed) {
  f <- ep_fold(dc$id, 3, seed); s <- matrix(0, 3, length(grid))
  for (j in 1:3) {
    tr <- dc[f[dc$id] != j, ]; te <- dc[f[dc$id] == j, ]; base <- ep_v4_lnfit(tr)
    for (k in seq_along(grid)) {
      o <- ep_v4_sexage_fit(tr, grid[k], base)
      fit <- list(cdf = function(t, d) stats::pnorm((log(pmax(t, 1e-12)) - ep_v4_eta(o, d)) / ep_v4_sigma(o, d)))
      s[j, k] <- sum(te$wn * ep_v4_cellscore(fit, te, te$grams1))
    }
  }
  sc <- colSums(s) / sum(dc$wn); list(k = grid[which.min(sc)], scores = data.frame(k = grid, cell_logscore = sc))
}
# Four-class probabilities (NC, C1, C2, C3plus) and the C4 diagnostic from participation and an amount CDF.
ep_v4_class_probs <- function(pc, fit, d) {
  ct <- ep_v4_cuts(d$sex); F <- fit$cdf(cbind(ct$lo, ct$hi, ct$top), d)
  pa <- cbind(C1 = F[, 1], C2 = F[, 2] - F[, 1], C3plus = 1 - F[, 2]); pa <- pmax(pa, 0); pa <- pa / rowSums(pa)
  P <- cbind(NC = 1 - pc, pc * pa); colnames(P) <- ep_v4_Y
  stopifnot(all(is.finite(P)), max(abs(rowSums(P) - 1)) < 1e-10)
  list(P = P, pa = pa, c4 = pmax(1 - F[, 3], 0))
}

# @@eps-v4-def-metrics
# One cross-validation harness for every amount model: the v1 folds (5 person-blocked folds x 3 repeats, same seeds),
# the v1 IPW refitted inside each training fold, and ONE participation model per fold shared by all amount models, so
# the NC column is identical across models and every score difference comes from the amount model. Test weights are
# renormalised to each interval's pair count, as in v1. Model A (six-state origins, destinations C3 + C4 collapsed) is
# carried as a non-eligible benchmark because it gives class probabilities but no grams distribution.
ep_v4_amount_models <- c("Lognormal", "Gamma", "Lognormal_sexage", "Lognormal_Pareto", "Hurdle_Pareto")
ep_v4_amount_cv <- function(r, models = ep_v4_amount_models, repeats = ep_repeats, K = ep_K) {
  rr <- r; rr$state0 <- rr$state0_6
  d_all <- ep_v4_ipw(rr); ids <- d_all$row_id; N <- length(ids); M <- c(models, "A")
  P <- lapply(stats::setNames(M, M), function(z) array(NA_real_, c(N, 4, repeats)))
  C4 <- lapply(stats::setNames(models, models), function(z) matrix(NA_real_, N, repeats))
  CELL <- lapply(stats::setNames(models, models), function(z) matrix(NA_real_, N, repeats))
  PIT <- lapply(stats::setNames(models, models), function(z) matrix(NA_real_, N, repeats))
  PITC <- lapply(stats::setNames(models, models), function(z) matrix(NA_real_, N, repeats))
  TN <- lapply(stats::setNames(models, models), function(z) matrix(NA_real_, N, repeats)); TD <- TN
  W <- matrix(NA_real_, N, repeats); tun <- list(); aud <- list()
  for (rep in seq_len(repeats)) {
    folds <- ep_fold(rr$id, K, ep_seed + rep)
    for (f in seq_len(K)) {
      tr <- rr[folds[rr$id] != f, ]; te <- rr[folds[rr$id] == f, ]
      stopifnot(!length(intersect(tr$id, te$id)))
      mass <- ep_v4_period_mass(tr)
      nu <- ep_ipw_fit(tr)
      a <- ep_v4_scoped(list(ep_period_mass = mass), ep_ipw_apply(tr, nu))
      b <- ep_v4_scoped(list(ep_period_mass = ep_v4_period_mass(te)), ep_ipw_apply(te, nu))
      ix <- match(b$row_id, ids); W[ix, rep] <- b$wcorrected
      # A benchmark on six-state data, destinations collapsed afterwards.
      ka <- ep_v4_scoped(list(ep_period_mass = mass), ep_tune(tr, FALSE, ep_seed + 100 * rep + f))$k
      pA <- ep_Aprob(ep_Afit(a, ka, FALSE), b); P$A[ix, , rep] <- cbind(pA[, 1], pA[, 2], pA[, 3], pA[, 4] + pA[, 5])
      # Five-state origin for the amount models.
      a$state0 <- a$state0_5; b$state0 <- b$state0_5; a$y1 <- a$y1_5; b$y1 <- b$y1_5
      pm <- ep_binary_fit(a, as.numeric(a$y1 != "NC"), ep_v4_formula(), a$wn); pc <- ep_binary_prob(pm, b)
      dc <- a[a$y1 != "NC" & a$grams1 > 0, ]
      ks <- ep_v4_tune_sexage(dc, seed = ep_seed + 200 * rep + f)
      tun[[length(tun) + 1]] <- cbind(rep = rep, fold = f, ks$scores, chosen = ks$k)
      bd <- b$y1 != "NC" & is.finite(b$grams1) & b$grams1 > 0
      # Tail threshold for the conditional PIT: training weighted 90th percentile of destination grams, by sex.
      u90 <- vapply(c("Men", "Women"), function(s) { i <- dc$sex == s; ep_wquant(dc$grams1[i], dc$wn[i], .9) }, 1)
      for (m in models) {
        fit <- ep_v4_amount_fit(dc, m, if (m == "Lognormal_sexage") ks$k else NULL)
        cp <- ep_v4_class_probs(pc, fit, b)
        P[[m]][ix, , rep] <- cp$P; C4[[m]][ix, rep] <- pc * cp$c4
        tm <- ep_v4_tailmean(fit, b); TN[[m]][ix, rep] <- pc * tm$num; TD[[m]][ix, rep] <- pc * tm$den
        g <- b$grams1[bd]; db <- b[bd, ]; h <- ep_v4_h()
        CELL[[m]][ix[bd], rep] <- ep_v4_cellscore(fit, db, g)
        lo <- fit$cdf(matrix(pmax(g - h / 2, 0)), db)[, 1]; up <- fit$cdf(matrix(g + h / 2), db)[, 1]
        set.seed(ep_seed + 300 * rep + f); U <- lo + stats::runif(length(g)) * (up - lo); PIT[[m]][ix[bd], rep] <- U
        uu <- u90[as.character(db$sex)]; tl <- g > uu; Fu <- fit$cdf(matrix(uu), db)[, 1]
        PITC[[m]][ix[bd][tl], rep] <- pmin(pmax((U[tl] - Fu[tl]) / pmax(1 - Fu[tl], 1e-12), 0), 1)
        if (m %in% c("Lognormal_Pareto", "Hurdle_Pareto", "Hurdle_Pareto_ridge"))
          aud[[length(aud) + 1]] <- data.frame(rep = rep, fold = f, model = m, sex = names(fit$alpha), alpha = as.numeric(fit$alpha),
            exceedances = as.numeric(attr(fit$alpha, "exceedances")), pooled_fallback = attr(fit$alpha, "fallback"),
            u = if (is.null(fit$u)) as.numeric(ep_v4_cuts(names(fit$alpha))$hi) else as.numeric(fit$u))
      }
      cat(sprintf("v4 amount CV repeat %d/%d, fold %d/%d (k sexage = %s)\n", rep, repeats, f, K, format(ks$k)))
    }
    for (p in ep_periods) { ii <- d_all$period == p; W[ii, rep] <- W[ii, rep] / sum(W[ii, rep]) * sum(d_all$period == p) }
  }
  stopifnot(all(vapply(P, function(x) all(is.finite(x)), TRUE)))
  d_all$state0 <- d_all$state0_5; d_all$y1 <- d_all$y1_5
  list(d = d_all, P = P, C4 = C4, CELL = CELL, PIT = PIT, PITC = PITC, TN = TN, TD = TD, W = W, tuning = do.call(rbind, tun), tail_audit = do.call(rbind, aud))
}
ep_v4_loss <- function(P, y) {
  Q <- pmax(P, 1e-8); Q <- Q / rowSums(Q); Y <- diag(ncol(P))[as.integer(y), , drop = FALSE]
  data.frame(logloss = -log(Q[cbind(seq_len(nrow(Q)), as.integer(y))]), brier = rowSums((P - Y)^2),
             correct = max.col(P, ties.method = "first") == as.integer(y))
}
# Metrics M1-M7 on the out-of-fold predictions (identical inputs for every model).
ep_v4_amount_metrics <- function(cv) {
  d <- cv$d; R <- ncol(cv$W); wbar <- rowMeans(cv$W); M <- names(cv$P)
  top <- ep_v4_cuts(d$sex)$top; drink <- d$y1 != "NC"; obs3 <- as.numeric(d$y1 == "C3plus")
  obs4 <- as.numeric(drink & is.finite(d$grams1) & d$grams1 > top)
  avg <- function(x) if (length(dim(x)) == 3) Reduce("+", lapply(seq_len(R), function(j) x[, , j] * cv$W[, j])) / rowSums(cv$W) else
    rowSums(x * cv$W) / rowSums(cv$W)
  # M1 overall four-class scores (per repeat, then averaged), M2 conditional on drinking, M3 lattice score.
  m1 <- do.call(rbind, lapply(M, function(m) do.call(rbind, lapply(seq_len(R), function(j) {
    P <- cv$P[[m]][, , j]; l <- ep_v4_loss(P, d$y1); w <- cv$W[, j]
    pa <- P[, -1, drop = FALSE] / pmax(rowSums(P[, -1, drop = FALSE]), 1e-12); yd <- as.integer(d$y1) - 1
    data.frame(model = m, repeat_id = j, logloss = stats::weighted.mean(l$logloss, w), brier = stats::weighted.mean(l$brier, w),
      accuracy = stats::weighted.mean(l$correct, w),
      logloss_given_drinking = stats::weighted.mean(-log(pmax(pa[cbind(which(drink), yd[drink])], 1e-8)), w[drink]),
      grams_cell_logscore = if (m %in% names(cv$CELL)) stats::weighted.mean(cv$CELL[[m]][drink, j], w[drink]) else NA_real_)
  }))))
  scores <- stats::aggregate(. ~ model, m1[setdiff(names(m1), "repeat_id")], mean, na.action = stats::na.pass)
  # M1b paired logloss difference vs Lognormal with a PSU/strata Taylor interval (OOF predictions averaged over repeats).
  opts <- options(survey.lonely.psu = "adjust", survey.adjust.domain.lonely = TRUE); on.exit(options(opts))
  d$wcv <- wbar; ds <- survey::svydesign(ids = ~psu, strata = ~strata, weights = ~wcv, data = d, nest = TRUE)
  crit <- stats::qt(.975, survey::degf(ds)); Pbar <- lapply(cv$P, function(x) { z <- avg(x); colnames(z) <- ep_v4_Y; z })
  contr <- do.call(rbind, lapply(setdiff(M, "Lognormal"), function(m) {
    ds$variables$diff <- ep_v4_loss(Pbar[[m]], d$y1)$logloss - ep_v4_loss(Pbar$Lognormal, d$y1)$logloss
    e <- survey::svymean(~diff, ds); v <- as.numeric(stats::coef(e)); se <- sqrt(as.numeric(stats::vcov(e)))
    data.frame(model = m, reference = "Lognormal", logloss_difference = v, se = se, lower = v - crit * se, upper = v + crit * se)
  }))
  # M4 C3plus and C4 recovery: observed vs predicted shares, all pairs and destination drinkers, pooled and by sex.
  C4bar <- lapply(cv$C4, avg)
  calib <- function(pred, obs, label, domain) do.call(rbind, lapply(c("All", "Men", "Women"), function(s) {
    keep <- (s == "All" | d$sex == s) & domain; ds$variables$o <- obs; ds$variables$p <- pred; ds$variables$df <- pred - obs
    sub <- subset(ds, keep); e <- survey::svymean(~o + p + df, sub); cf <- stats::coef(e); se <- sqrt(diag(stats::vcov(e)))
    data.frame(outcome = label, sex = s, n = sum(keep), observed = cf[["o"]], predicted = cf[["p"]], ratio_P_over_O = cf[["p"]] / cf[["o"]],
      difference_P_minus_O = cf[["df"]], lower = cf[["df"]] - crit * se[["df"]], upper = cf[["df"]] + crit * se[["df"]])
  }))
  rec <- do.call(rbind, lapply(M, function(m) {
    pa <- Pbar[[m]][, "C3plus"] / pmax(1 - Pbar[[m]][, "NC"], 1e-12)
    x <- rbind(calib(Pbar[[m]][, "C3plus"], obs3, "C3plus, all pairs", rep(TRUE, nrow(d))),
               calib(pa, obs3, "C3plus | destination drinker", drink))
    if (m %in% names(C4bar)) x <- rbind(x, calib(C4bar[[m]], obs4, "C4 diagnostic, all pairs", rep(TRUE, nrow(d))),
      calib(C4bar[[m]] / pmax(1 - Pbar[[m]][, "NC"], 1e-12), obs4, "C4 diagnostic | destination drinker", drink))
    cbind(model = m, x)
  }))
  rownames(rec) <- NULL
  # M5 C3plus calibration by interval x origin and by sex x age group.
  cells <- do.call(rbind, lapply(M, function(m) do.call(rbind, lapply(list(c("period", "state0"), c("sex", "age_group")), function(by) {
    ds$variables$o <- obs3; ds$variables$p <- Pbar[[m]][, "C3plus"]; ds$variables$df <- ds$variables$p - obs3
    b <- survey::svyby(~o + p + df, stats::as.formula(paste("~", paste(by, collapse = "+"))), ds, survey::svymean, keep.var = TRUE)
    n <- as.integer(table(do.call(paste, d[by]))[do.call(paste, lapply(by, function(v) as.character(b[[v]])))])
    data.frame(model = m, by = paste(by, collapse = " x "), cell = do.call(paste, c(lapply(by, function(v) as.character(b[[v]])), sep = " | ")),
      n = n, observed = b$o, predicted = b$p, difference = b$df, lower = b$df - crit * b$se.df, upper = b$df + crit * b$se.df,
      sparse = n < 30, row.names = NULL)
  }))))
  # M6 tail recovery among destination drinkers: predicted vs observed share above hi, top and the sex-specific q95/q99.
  dd <- d[drink & is.finite(d$grams1), ]; wd <- wbar[drink & is.finite(d$grams1)]
  tailrows <- do.call(rbind, lapply(c("Men", "Women"), function(s) {
    i <- dd$sex == s; ct <- ep_v4_cuts(s); q <- ep_wquant(dd$grams1[i], wd[i], c(.95, .99))
    ts <- c(hi = ct$hi, top = ct$top, q95 = q[1], q99 = q[2])
    do.call(rbind, lapply(names(ts), function(nm) data.frame(sex = s, threshold = nm, grams = ts[[nm]],
      observed = stats::weighted.mean(dd$grams1[i] > ts[[nm]], wd[i]))))
  }))
  # Predicted exceedance needs each model's CDF on test rows; the harness stores only class probabilities, so the
  # hi and top rows are taken from them and q95/q99 are compared through the PIT below.
  # M7 randomized PIT among destination drinkers (all), and the tail PIT conditional on exceeding the training 90th
  # percentile u: (F(g) - F(u)) / (1 - F(u)), uniform if the tail shape is right. Ideal: mean 0.5, KS near 0.
  pit <- do.call(rbind, lapply(names(cv$PIT), function(m) do.call(rbind, lapply(c("all drinkers", "tail above training q90"), function(sub) {
    U <- (if (sub == "all drinkers") cv$PIT else cv$PITC)[[m]][drink, , drop = FALSE]; ww <- cv$W[drink, , drop = FALSE]
    u <- as.numeric(U); w <- as.numeric(ww); ok <- is.finite(u); keep <- rowSums(is.finite(U)) > 0; u <- u[ok]; w <- w[ok] / sum(w[ok])
    o <- order(u); ecdf <- cumsum(w[o]); ks <- max(abs(ecdf - u[o]))
    data.frame(model = m, subset = sub, n = sum(keep), mean_U = sum(w * u), share_U_above_0.9 = sum(w * (u > .9)), weighted_KS = ks)
  }))))
  # M6b tail mean among C3plus destinations, truncated at the cap: predicted sum(w num) / sum(w den) vs observed.
  tmean <- do.call(rbind, lapply(names(cv$TN), function(m) do.call(rbind, lapply(c("All", "Men", "Women"), function(s) {
    keep <- s == "All" | d$sex == s; tn <- avg(cv$TN[[m]]); td <- avg(cv$TD[[m]])
    ob <- keep & d$y1 == "C3plus" & d$grams1 <= ep_v4_cap
    data.frame(model = m, sex = s, predicted_mean_grams_C3plus = sum(wbar[keep] * tn[keep]) / sum(wbar[keep] * td[keep]),
      observed_mean_grams_C3plus = stats::weighted.mean(d$grams1[ob], wbar[ob]), n_observed = sum(ob),
      observed_above_cap = sum(keep & d$y1 == "C3plus" & d$grams1 > ep_v4_cap))
  }))))
  list(scores = scores, scores_by_repeat = m1, contrasts = contr, recovery = rec, cells = cells, tail_observed = tailrows, pit = pit,
       tail_mean = tmean)
}
# Pre-registered adoption rule: a candidate replaces Lognormal only if (1) |log(P/O)| for C3plus (all pairs) is
# smaller than Lognormal's pooled and in each sex and its pooled P - O interval covers 0; (2) the lower bound of its
# paired logloss difference vs Lognormal is <= 0 (it is not worse); (3) no non-sparse C3plus cell has an interval that
# excludes 0 where Lognormal's did not. Ties: max |P - O| over non-sparse cells, then C4 |log(P/O)|, then the lattice score.
ep_v4_decide <- function(met, candidates = setdiff(ep_v4_amount_models, "Lognormal")) {
  rc <- met$recovery[met$recovery$outcome == "C3plus, all pairs", ]
  alr <- function(m, s) { z <- rc[rc$model == m & rc$sex == s, ]; abs(log(z$ratio_P_over_O)) }
  cl <- met$cells[!met$cells$sparse, ]; key <- paste(cl$by, cl$cell)
  bad <- function(m) { z <- cl[cl$model == m, ]; z$lower > 0 | z$upper < 0 }
  ref_bad <- bad("Lognormal"); names(ref_bad) <- key[cl$model == "Lognormal"]
  out <- do.call(rbind, lapply(candidates, function(m) {
    z <- rc[rc$model == m & rc$sex == "All", ]; ct <- met$contrasts[met$contrasts$model == m, ]
    mb <- bad(m); names(mb) <- key[cl$model == m]; newbias <- any(mb & !ref_bad[names(mb)])
    c1 <- all(vapply(c("All", "Men", "Women"), function(s) alr(m, s) < alr("Lognormal", s), TRUE)) && z$lower <= 0 && z$upper >= 0
    c2 <- ct$lower <= 0; c3 <- !newbias
    c4 <- met$recovery[met$recovery$model == m & met$recovery$outcome == "C4 diagnostic, all pairs" & met$recovery$sex == "All", ]
    data.frame(model = m, C3plus_abs_log_ratio = alr(m, "All"), lognormal_abs_log_ratio = alr("Lognormal", "All"),
      rule1_C3plus_calibration = c1, rule2_logloss_not_worse = c2, rule3_no_new_cell_bias = c3, eligible = c1 && c2 && c3,
      max_abs_cell_difference = max(abs(cl$difference[cl$model == m])), C4_abs_log_ratio = abs(log(c4$ratio_P_over_O)),
      grams_cell_logscore = met$scores$grams_cell_logscore[met$scores$model == m])
  }))
  el <- out[out$eligible, ]
  winner <- if (nrow(el)) el$model[order(el$max_abs_cell_difference, el$C4_abs_log_ratio, el$grams_cell_logscore)][1] else "Lognormal"
  list(table = out, winner = winner)
}

# @@eps-v4-def-figures
ep_v4_plots <- function() {
  # 1. What 2009 history changes: share of N0 reclassified to FD, by wave and sex.
  z <- ep_v4_rc[ep_v4_rc$level == "wave x sex", ]
  p <- ggplot2::ggplot(z, ggplot2::aes(wave, pct_of_N0, fill = sex)) + ggplot2::geom_col(position = "dodge") +
    ggplot2::scale_fill_manual(values = unname(ep_palette[c("blue", "rust")])) + ep_theme() +
    ggplot2::labs(title = "N0 respondents who drank in 2009", subtitle = "Ages 18-65; reclassified from N0 to FD by the 2009 history",
      x = NULL, y = "% of N0 without 2009 history", fill = NULL)
  ep_fig(p, "fig_v4_2009_reclassification", 9, 5)
  # 2. Recovery of C3plus and C4: predicted minus observed share with design intervals, by model and sex.
  k <- ep_v4_met$recovery[ep_v4_met$recovery$outcome %in% c("C3plus, all pairs", "C4 diagnostic, all pairs"), ]
  p <- ggplot2::ggplot(k, ggplot2::aes(difference_P_minus_O * 100, model, color = sex)) +
    ggplot2::geom_vline(xintercept = 0, linetype = 2, color = ep_palette["grey"]) +
    ggplot2::geom_pointrange(ggplot2::aes(xmin = lower * 100, xmax = upper * 100), position = ggplot2::position_dodge(.5)) +
    ggplot2::facet_wrap(~outcome, scales = "free_x") + ggplot2::scale_color_manual(values = unname(ep_palette[c("grey", "blue", "rust")])) + ep_theme() +
    ggplot2::labs(title = "Do the amount models recover the heavy-drinking tail?", subtitle = "Held-out predicted minus observed share (percentage points); design-based 95% intervals",
      x = "Predicted - observed (pp)", y = NULL, color = NULL)
  ep_fig(p, "fig_v4_tail_recovery", 11, 6)
  # 3. Tail PIT above the training 90th percentile: a flat histogram means the tail shape is right.
  d <- ep_v4_cv$d; drink <- d$y1 != "NC"
  u <- do.call(rbind, lapply(names(ep_v4_cv$PITC), function(m) { x <- as.numeric(ep_v4_cv$PITC[[m]][drink, ]); data.frame(model = m, U = x[is.finite(x)]) }))
  p <- ggplot2::ggplot(u, ggplot2::aes(U)) + ggplot2::geom_histogram(breaks = seq(0, 1, .1), fill = ep_palette["blue"], color = "white") +
    ggplot2::facet_wrap(~model) + ep_theme() +
    ggplot2::labs(title = "Tail calibration above the 90th percentile", subtitle = "Randomized PIT conditional on exceeding the training 90th percentile; flat is good",
      x = "Conditional PIT", y = "Count (three repeats)")
  ep_fig(p, "fig_v4_tail_pit", 11, 6)
  # 4. Pooled five-state matrix of the adopted model.
  m <- ep_v4_mat[ep_v4_mat$group == "All" & ep_v4_mat$model == ep_v4_winner, ]
  m$from <- factor(m$from, ep_v4_ST); m$to <- factor(m$to, ep_v4_ST)
  p <- ggplot2::ggplot(m, ggplot2::aes(to, from, fill = estimate)) + ggplot2::geom_tile(color = "white") +
    ggplot2::geom_text(ggplot2::aes(label = ifelse(is.na(estimate), "NA", sprintf("%.3f", estimate))), size = 3.4) +
    ggplot2::scale_fill_gradient(low = ep_palette[["pale"]], high = ep_palette[["heat"]], na.value = "white") +
    ggplot2::scale_y_discrete(limits = rev(ep_v4_ST)) + ep_theme() +
    ggplot2::labs(title = paste("Pooled five-state transition matrix,", ep_v4_winner), subtitle = "Both intervals pooled; rows are origins; WHO borders, 12 g/drink, 2009 history",
      x = "Destination", y = "Origin", fill = NULL)
  ep_fig(p, "fig_v4_matrix", 8, 6)
}

# @@eps-v4-def-matrices
# Final five-state matrices. A model is fitted on all v4 pairs (IPW refitted on the v4 risk set), its four-class
# predictions (NC, C1, C2, C3plus) are averaged with the pair weights within each origin and group, and NC is written
# to N0 for N0 origins and to FD otherwise (the history map: a drinker who stops is FD; N0 cannot become FD).
# Uncertainty: the v1 stratified jackknife (JKn) multipliers, with IPW, participation and amount models refitted in
# every replicate, as in v1/v2.
ep_v4_fit_full <- function(a, model) {
  a$state0 <- a$state0_5; a$y1 <- a$y1_5
  pm <- ep_binary_fit(a, as.numeric(a$y1 != "NC"), ep_v4_formula(), a$wn)
  dc <- a[a$y1 != "NC" & a$grams1 > 0, ]
  list(model = model, participation = pm, amount = ep_v4_amount_fit(dc, model))
}
ep_v4_predict <- function(o, b) { b$state0 <- b$state0_5; ep_v4_class_probs(ep_binary_prob(o$participation, b), o$amount, b)$P }
ep_v4_matrices <- function(d, P, model, by = c("period", "sex", "age_group")) {
  d$state0 <- d$state0_5; groups <- split(seq_len(nrow(d)), ep_key(d, by))
  do.call(rbind, lapply(groups, function(ii) {
    z <- d[ii, ]
    do.call(rbind, lapply(ep_v4_ST, function(st) {
      ix <- ii[as.character(d$state0[ii]) == st]; n <- sum(d$mult[ix] > 0)
      p4 <- if (length(ix) && sum(d$wn[ix]) > 0) colSums(P[ix, , drop = FALSE] * d$wn[ix]) / sum(d$wn[ix]) else rep(NA_real_, 4)
      p5 <- c(N0 = 0, FD = 0, p4[-1]); p5[if (st == "N0") 1 else 2] <- p4[1]
      data.frame(model = model, group = ep_key(z[1, ], by), z[rep(1, 5), by, drop = FALSE], from = st, to = ep_v4_ST,
        n_origin = n, estimate = if (n) p5 else NA_real_, structural = !(ep_v4_ST %in% c(if (st == "N0") "N0" else "FD", ep_v4_ST[3:5])),
        support = if (n == 0) "unobserved origin" else if (n < 30) "sparse" else "observed", row.names = NULL)
    }))
  }))
}
ep_v4_three <- function(d, P, model) {
  cols <- c("model", "group", "period", "sex", "age_group", "from", "to", "n_origin", "estimate", "structural", "support")
  a <- ep_v4_matrices(d, P, model, c("period", "sex", "age_group"))
  b <- ep_v4_matrices(d, P, model, c("sex", "age_group")); b$period <- "All"
  d$pooled <- "All"; cc <- ep_v4_matrices(d, P, model, "pooled"); cc$period <- "All"; cc$sex <- "All"; cc$age_group <- "All"
  x <- rbind(a[cols], b[cols], cc[cols]); x[] <- lapply(x, function(v) if (is.factor(v)) as.character(v) else v); x
}
ep_v4_final_matrices <- function(r, models, B = NULL) {
  targets <- function(rr) {
    d <- ep_v4_ipw(rr)
    do.call(rbind, lapply(models, function(m) ep_v4_three(d, ep_v4_predict(ep_v4_fit_full(d, m), d), m)))
  }
  point <- targets(r); key <- paste(point$model, point$group, point$from, point$to)
  M <- ep_des$multipliers; J <- if (is.null(B)) ncol(M) else min(B, ncol(M)); reps <- matrix(NA_real_, J, nrow(point))
  for (j in seq_len(J)) {
    rj <- r; rj$mult <- M[match(rj$id, ep_des$master$id), j]; tj <- targets(rj)
    stopifnot(identical(paste(tj$model, tj$group, tj$from, tj$to), key)); reps[j, ] <- tj$estimate
    if (j %% 10 == 0 || j == J) cat(sprintf("v4 JKn %d/%d\n", j, J))
  }
  # JKn variance needs every replicate; a truncated run (tests only) returns point estimates without intervals.
  if (J < ncol(M)) return(cbind(point, se = NA_real_, lower = NA_real_, upper = NA_real_, valid_replicates = J, interval_status = "test run: no interval"))
  cbind(point, ep_interval(point$estimate, reps))
}
cat(sprintf("Elapsed: %.2f minutes\n", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
