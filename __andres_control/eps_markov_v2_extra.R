.t0 <- Sys.time()
# EPS IPW v2: additional definitions embedded as the cell eps-v2-definitions of eps_markov_transitions_v2_EN.ipynb
# (contract: __andres_control/eps_ipw_v2_plan_2026-10-19.md). Functions only, prefixed ep_v2_; they use the globals
# of the executed EN notebook (eps_raw, eps_root, eps_phone, eps_panel_weights, ep_W, ep_risk, ep_d, ep_des, ep_k,
# ep_cvtab and the ep_* helpers). Deaths and impeded are competing exits: they leave the risk set and the response
# model in both intervals; phone-only VII respondents are followed without the alcohol module (missing outcome).
# Row-level objects stay in memory; every export is an aggregate.
ep_v2_formula <- ~ state5 + lg0 + sex * age_group + edu_num + edu_missing + own_home + partnered + working + smokes + phq9_ge10 + health_poor
ep_v2_covs <- c("own_home", "partnered", "working", "smokes", "phq9_ge10", "health_poor")
ep_v2_states <- c("N0", "FD", "C1", "C2", "C3plus")
ep_v2_exits <- function() {
  f7 <- file.path(eps_root, "Bases y Documentos EPS 2020", "2020", "Bases_EPS2020_presencial")
  f8 <- file.path(eps_root, "Bases de datos EPS VIII Ronda")
  ids <- function(f) {
    x <- haven::read_dta(f, col_select = "folio_n20")$folio_n20
    stopifnot(!anyNA(x), !anyDuplicated(x)); as.character(x)
  }
  phone <- unique(unlist(lapply(eps_phone, function(z) as.character(z$folio_n20))))
  list(dead7 = ids(file.path(f7, "02_Fallecidos presencial", "MODULO_M_in.dta")),
    imped7 = ids(file.path(f7, "03_Impedidos presencial", "MODULO_P_in.dta")),
    dead8 = ids(file.path(f8, "BBDD_FALL", "MODULO_M_ENTREVISTADO.dta")),
    imped8 = ids(file.path(f8, "BBDD_PSD", "MODULO_P_ENTREVISTADO.dta")),
    phone7 = setdiff(phone, as.character(eps_raw$VII_presencial$a$folio_n20)))
}
ep_v2_code <- function(x) {
  # Labelled non-response codes (No responde / No sabe) become missing; unlabelled items fall back to the usual codes.
  vl <- attr(x, "labels")
  nr <- if (is.null(vl)) c(8, 9, 88, 99, 888, 999) else vl[grepl("^no (responde|sabe)", names(vl), ignore.case = TRUE)]
  x <- as.numeric(x); x[x %in% nr] <- NA_real_; x
}
ep_v2_yn <- function(yes, no) factor(ifelse(yes %in% TRUE, "Yes", ifelse(no %in% TRUE, "No", "Missing")), levels = c("Yes", "No", "Missing"))
ep_v2_covariate_audit <- function(cov) do.call(rbind, lapply(split(cov, cov$wave), function(z) do.call(rbind, lapply(ep_v2_covs, function(v)
  data.frame(wave = z$wave[1], covariate = v, n = nrow(z), n_missing = sum(z[[v]] == "Missing"),
    pct_missing = 100 * mean(z[[v]] == "Missing"), share_yes = mean(z[[v]] == "Yes"))))))
ep_v2_covariates <- function() {
  f7 <- "Bases y Documentos EPS 2020/2020/Bases_EPS2020_presencial/01_Vivos presencial"
  f8 <- "Bases de datos EPS VIII Ronda/BBDD_VIVOS"
  paths <- list(
    VI = c(d = "2015/2015/MODULOD_entrevistado.dta", i = "2015/2015/MODULOI_entrevistado.dta", b = "2015/2015/MODULOB_historia_laboral.dta"),
    VII_presencial = c(d = file.path(f7, "MODULO_D_Entrevistado_in.dta"), i = file.path(f7, "MODULO_I_Entrevistado_in.dta"),
      b = file.path(f7, "MODULO_B_Situacion_Actual_in.dta")),
    VIII = c(d = file.path(f8, "MODULO_D_ENTREVISTADO.dta"), i = file.path(f8, "MODULO_I_ENTREVISTADO.dta"),
      b = file.path(f8, "MODULO_B_SITUACION_ACTUAL.dta")))
  read <- function(p) haven::read_dta(file.path(eps_root, p))
  pick <- function(z, v, id) ep_v2_code(z[[v]])[match(id, as.character(z$folio_n20))]
  out <- lapply(names(paths), function(w) {
    a <- eps_raw[[w]]$a; f <- eps_raw[[w]]$f; id <- as.character(a$folio_n20)
    D <- read(paths[[w]]["d"]); I <- read(paths[[w]]["i"]); B <- read(paths[[w]]["b"])
    if (w == "VI") {
      # Ongoing episode of the 2015 work history: latest start (year, month); ties by latest end and episode order.
      B <- B[order(as.character(B$folio_n20), as.numeric(B$b1ia), as.numeric(B$b1im), as.numeric(B$b1ta), as.numeric(B$b1tm), as.numeric(B$orden)), ]
      B <- B[!duplicated(as.character(B$folio_n20), fromLast = TRUE), ]
    }
    d7 <- pick(D, "d7", id); i1 <- pick(I, "i1", id); a10 <- pick(a, "a10", id)
    work <- pick(B, switch(w, VI = "b2", VII_presencial = "b2a_SO", VIII = "b2a_so"), id)
    smoke <- pick(f, if (w == "VIII") "f12_a" else "f12a", id)
    phq <- rowSums(vapply(1:9, function(k) pick(f, paste0("f69_", k), id), numeric(length(id))) - 1)
    partner <- if (w == "VI") c(1, 2, 9) else c(1, 2, 4)
    data.frame(id = id, wave = w, own_home = ep_v2_yn(d7 %in% 1:3, !is.na(d7) & !d7 %in% 1:3),
      partnered = ep_v2_yn(i1 %in% partner, !is.na(i1) & !i1 %in% partner), working = ep_v2_yn(work %in% 1, !is.na(work) & work != 1),
      smokes = ep_v2_yn(smoke %in% 1, smoke %in% 2), phq9_ge10 = ep_v2_yn(phq >= 10, phq < 10),
      health_poor = ep_v2_yn(a10 %in% 4:6, a10 %in% 1:3), phq9_score = phq)
  })
  cov <- do.call(rbind, out); rownames(cov) <- NULL
  ep_save(ep_v2_covariate_audit(cov), "v2_covariate_audit")
  cov
}
ep_v2_attrition <- function(W = ep_W, exits, cov) {
  out <- lapply(ep_periods, function(p) {
    tm <- ep_time[ep_time$period == p, ]; a <- W[W$wave == tm$from, ]; b <- W[W$wave == tm$to, ]
    a <- a[a$age >= 18 & a$age <= 65 & !is.na(a$sex), ]
    if (p == "VI_VII") a <- a[a$id %in% as.character(eps_panel_weights$VI_VII$folio_n20), ]
    dead <- if (p == "VI_VII") exits$dead7 else exits$dead8; imp <- if (p == "VI_VII") exits$imped7 else exits$imped8
    phone <- if (p == "VI_VII") exits$phone7 else character()
    j <- match(a$id, b$id); z <- b[j, ]
    valid <- (!is.na(j) & a$sex == z$sex & z$age - a$age >= floor(tm$min_years) & z$age - a$age <= ceiling(tm$max_years)) %in% TRUE
    followed <- valid & !is.na(z$state)
    status <- ifelse(a$id %in% dead, "deceased", ifelse(a$id %in% imp, "impeded",
      ifelse(followed, "completed", ifelse(a$id %in% phone, "phone_only", "lost"))))
    # Unknown = no usable alcohol classification at origin; these rows are in All but cannot form a completed pair.
    s5 <- ifelse(is.na(a$state), "Unknown", ifelse(a$state %in% c("C3", "C4"), "C3plus", a$state))
    do.call(rbind, lapply(c(ep_v2_states, "Unknown", "All"), function(st) {
      ii <- if (st == "All") rep(TRUE, nrow(a)) else s5 == st; n <- function(k) sum(status[ii] == k)
      survivors <- sum(ii) - n("deceased") - n("impeded")
      data.frame(period = p, state5 = st, baseline = sum(ii), deceased = n("deceased"), impeded = n("impeded"), phone_only = n("phone_only"),
        completed = n("completed"), lost = n("lost"), pct_followed_of_survivors = if (survivors > 0) n("completed") / survivors else NA_real_)
    }))
  })
  d <- do.call(rbind, out); rownames(d) <- NULL; d
}
ep_v2_make_risk <- function(W = ep_W, exits, cov) {
  r <- ep_make_risk(W)
  gone <- (r$period == "VI_VII" & r$id %in% c(exits$dead7, exits$imped7)) | (r$period == "VII_VIII" & r$id %in% c(exits$dead8, exits$imped8))
  r <- r[!gone, ]
  j <- match(paste(r$id, ifelse(r$period == "VI_VII", "VI", "VII_presencial")), paste(cov$id, cov$wave))
  stopifnot(!anyNA(j))
  for (v in c(ep_v2_covs, "phq9_score")) r[[v]] <- cov[[v]][j]
  r$state5 <- factor(ifelse(r$state0 %in% c("C3", "C4"), "C3plus", as.character(r$state0)), levels = ep_v2_states)
  rownames(r) <- NULL; r
}
ep_v2_glm <- function(r) {
  opts <- options(survey.lonely.psu = "adjust", survey.adjust.domain.lonely = TRUE); on.exit(options(opts))
  prob <- rep(NA_real_, nrow(r)); rows <- list()
  for (p in ep_periods) {
    # Rows without an origin classification cannot be completed pairs and have no state5; version 1 models them in its first stage.
    ii <- which(r$period == p & !is.na(r$state5)); d <- droplevels(r[ii, ]); d$complete <- as.numeric(d$complete)
    stopifnot(!anyNA(d$psu), !anyNA(d$strata))
    ds <- survey::svydesign(ids = ~psu, strata = ~strata, weights = ~wbase, data = d, nest = TRUE)
    fit <- ep_warn(survey::svyglm(stats::update(ep_v2_formula, complete ~ .), design = ds, family = stats::quasibinomial()))
    co <- summary(fit)$coefficients; crit <- stats::qt(.975, survey::degf(ds))
    # Rows where each term is active: a tiny Missing level followed in full gives a quasi-separated, uninterpretable OR.
    X <- stats::model.matrix(ep_v2_formula, d); active <- colSums(X != 0); active_complete <- colSums(X[d$complete == 1, , drop = FALSE] != 0)
    rows[[p]] <- data.frame(period = p, term = rownames(co), OR = exp(co[, 1]), lower = exp(co[, 1] - crit * co[, 2]),
      upper = exp(co[, 1] + crit * co[, 2]), se = co[, 2], n = nrow(d), n_complete = sum(d$complete),
      n_nonzero = as.integer(active[rownames(co)]), n_nonzero_complete = as.integer(active_complete[rownames(co)]), row.names = NULL)
    prob[ii] <- as.numeric(stats::fitted(fit))
  }
  list(odds_ratios = do.call(rbind, rows), prob = prob)
}
ep_v2_superlearner <- function(r, V = 5, seed = ep_seed) {
  # Learners are resolved through the SuperLearner namespace, so nothing is attached and the tuned ranger stays local.
  env <- new.env(parent = asNamespace("SuperLearner"))
  learner <- SuperLearner::create.Learner("SL.ranger", params = list(num.trees = 500, min.node.size = 50, verbose = FALSE),
    name_prefix = "SL.ranger_v2", env = env)
  assign("SL.ranger_v2", get(learner$names[1], envir = env), envir = env)
  lib <- c("SL.mean", "SL.glm", "SL.glmnet", "SL.ranger_v2")
  prob <- rep(NA_real_, nrow(r)); rows <- list()
  for (p in ep_periods) {
    t <- Sys.time(); ii <- which(r$period == p & !is.na(r$state5)); d <- droplevels(r[ii, ])
    X <- as.data.frame(stats::model.matrix(ep_v2_formula, d)[, -1, drop = FALSE]); names(X) <- make.names(names(X), unique = TRUE)
    set.seed(seed + match(p, ep_periods))
    fit <- ep_warn(SuperLearner::SuperLearner(Y = as.numeric(d$complete), X = X, family = stats::binomial(), SL.library = lib,
      obsWeights = d$wbase / mean(d$wbase), cvControl = list(V = V, stratifyCV = TRUE, shuffle = TRUE), env = env))
    secs <- as.numeric(difftime(Sys.time(), t, units = "secs"))
    rows[[p]] <- data.frame(period = p, learner = sub("_All$", "", names(fit$cvRisk)), cv_risk = as.numeric(fit$cvRisk),
      coef = as.numeric(fit$coef), discrete_winner = seq_along(fit$cvRisk) == which.min(fit$cvRisk), n = nrow(d),
      n_complete = sum(d$complete), fit_seconds = secs, row.names = NULL)
    prob[ii] <- as.numeric(fit$SL.predict)
  }
  list(risks = do.call(rbind, rows), prob = prob, library = lib)
}
ep_v2_ipw_apply <- function(r, prob, label) {
  out <- lapply(ep_periods, function(p) {
    ii <- which(r$period == p & r$complete); z <- r[ii, ]; if (!nrow(z)) return(z)
    stopifnot(all(is.finite(prob[ii])))
    z$p_obs <- pmax(prob[ii], .02); z$untrimmed <- z$wbase / z$p_obs
    cap <- ep_wquant(z$untrimmed, z$mult, c(.01, .99))
    z$wcorrected <- pmin(pmax(z$untrimmed, cap[1]), cap[2])
    z$wn <- z$wcorrected * z$mult; z$wn <- z$wn / sum(z$wn) * ep_v2_period_mass[[p]]
    z$at_floor <- prob[ii] <= .02; z$at_lower <- z$untrimmed < cap[1]; z$at_upper <- z$untrimmed > cap[2]; z$scheme <- label
    z
  })
  d <- do.call(rbind, out); rownames(d) <- NULL; d
}
ep_v2_schemes <- function(r, sl_prob, audit = TRUE) {
  renorm <- function(z) { for (p in ep_periods) { ii <- z$period == p; z$wn[ii] <- z$wn[ii] / sum(z$wn[ii]) * ep_v2_period_mass[[p]] }; z }
  flag <- function(z, label) {
    z$at_floor <- z$p_obs <= .02; z$at_lower <- z$untrimmed < z$wcorrected; z$at_upper <- z$untrimmed > z$wcorrected; z$scheme <- label; z
  }
  official <- r[r$complete, ]; official$p_obs <- NA_real_; official$untrimmed <- NA_real_; official$wcorrected <- NA_real_
  official$wn <- official$wbase * official$mult
  out <- list(official = flag(renorm(official), "official"), ipw_v1 = flag(renorm(ep_ipw_apply(r, ep_ipw_fit(r))), "ipw_v1"),
    ipw_v2_sl = ep_v2_ipw_apply(r, sl_prob, "ipw_v2_sl"))
  if (audit) ep_save(do.call(rbind, lapply(out, function(z) do.call(rbind, lapply(split(z, z$period), function(d)
    data.frame(scheme = d$scheme[1], period = d$period[1], n_complete = nrow(d), weight_sum = sum(d$wn), weight_ESS = sum(d$wn)^2 / sum(d$wn^2),
      min_probability = min(d$p_obs), median_weight = stats::median(d$wn), max_weight = max(d$wn), n_at_floor = sum(d$at_floor),
      n_at_lower = sum(d$at_lower), n_at_upper = sum(d$at_upper)))))), "v2_scheme_weights_audit")
  out
}
ep_v2_scheme_matrices <- function(r, schemes, sl_prob, models = c("A", "Lognormal")) {
  cols <- c("model", "group", "period", "sex", "age_group", "from", "to", "n_origin", "estimate", "structural", "support")
  three <- function(d, P, model) {
    a <- ep_matrices(d, P, model, c("period", "sex", "age_group"))
    b <- ep_matrices(d, P, model, c("sex", "age_group")); b$period <- "All"
    d$pooled <- "All"; cc <- ep_matrices(d, P, model, "pooled"); cc$period <- "All"; cc$sex <- "All"; cc$age_group <- "All"
    x <- rbind(a[cols], b[cols], cc[cols]); x[] <- lapply(x, function(v) if (is.factor(v)) as.character(v) else v); x
  }
  targets <- function(sch) do.call(rbind, lapply(names(sch), function(s) do.call(rbind, lapply(models, function(m) {
    d <- sch[[s]]; cbind(scheme = s, three(d, ep_prob(ep_fit(d, m, ep_k[1]), d), m))
  }))))
  key <- function(x) paste(x$scheme, x$model, x$group, x$from, x$to, sep = "::")
  point <- targets(schemes); rownames(point) <- NULL
  J <- ncol(ep_des$multipliers); reps <- matrix(NA_real_, J, nrow(point))
  for (j in seq_len(J)) {
    t <- Sys.time(); rj <- r; rj$mult <- ep_des$multipliers[match(rj$id, ep_des$master$id), j]
    # Official: multiplier only; ipw_v1: refitted; ipw_v2_sl: SuperLearner probabilities fixed, caps recomputed.
    tj <- targets(ep_v2_schemes(rj, sl_prob, audit = FALSE))
    stopifnot(identical(key(tj), key(point))); reps[j, ] <- tj$estimate
    secs <- as.numeric(difftime(Sys.time(), t, units = "secs"))
    if (j == 1) cat(sprintf("v2 JKn replicate 1: %.1f s; projected %.1f minutes for %d replicates x %d schemes\n", secs, secs * J / 60, J, length(schemes)))
    if (j %% 10 == 0 || j == J) cat(sprintf("v2 design JKn %d/%d\n", j, J))
  }
  matrices <- cbind(point, ep_interval(point$estimate, reps))
  shift <- do.call(rbind, lapply(split(point, paste(point$model, point$period)), function(z) {
    base <- z[z$scheme == "official", ]; k <- paste(base$group, base$from, base$to)
    do.call(rbind, lapply(setdiff(names(schemes), "official"), function(s) {
      alt <- z[z$scheme == s, ]; alt <- alt[match(k, paste(alt$group, alt$from, alt$to)), ]
      diff <- alt$estimate - base$estimate; ok <- which(is.finite(diff) & !base$structural); i <- ok[which.max(abs(diff[ok]))]
      data.frame(period = z$period[1], model = z$model[1], comparison = paste(s, "minus official"), cells = length(ok),
        mean_abs_shift = mean(abs(diff[ok])), max_abs_shift = abs(diff[i]), max_cell = paste0(base$group[i], " ", base$from[i], "->", base$to[i]),
        max_cell_n_origin = base$n_origin[i], official = base$estimate[i], alternative = alt$estimate[i])
    }))
  }))
  rownames(shift) <- NULL
  list(matrices = matrices, shift = shift)
}
ep_v2_diagnostics <- function(r, schemes) {
  vars <- c("state5", "sex", "age_group", ep_v2_covs)
  indic <- function(d) {
    m <- do.call(cbind, lapply(vars, function(v) {
      x <- vapply(levels(d[[v]]), function(l) as.numeric(d[[v]] == l), numeric(nrow(d))); colnames(x) <- paste0(v, ":", levels(d[[v]])); x
    }))
    cbind(m, lg0 = d$lg0, edu_num = d$edu_num, edu_missing = d$edu_missing)
  }
  stat <- function(X, w) {
    if (!length(w) || sum(w) <= 0) return(list(m = NA_real_, v = NA_real_))
    m <- colSums(X * w) / sum(w); list(m = m, v = colSums(sweep(X, 2, m)^2 * w) / sum(w))
  }
  base <- r[!is.na(r$state5), ]; Xb <- indic(base); cols <- colnames(Xb); K <- length(cols)
  smd <- list(); wt <- list()
  for (s in names(schemes)) {
    z <- schemes[[s]]; Xz <- indic(z)
    for (p in ep_periods) for (st in c(ep_v2_states, "All")) {
      ib <- base$period == p & (st == "All" | base$state5 == st); iz <- z$period == p & (st == "All" | z$state5 == st)
      b0 <- stat(Xb[ib, , drop = FALSE], base$wbase[ib]); b1 <- stat(Xz[iz, , drop = FALSE], z$wn[iz])
      m0 <- rep_len(b0$m, K); m1 <- rep_len(b1$m, K); den <- sqrt((rep_len(b0$v, K) + rep_len(b1$v, K)) / 2)
      smd[[length(smd) + 1]] <- data.frame(scheme = s, period = p, state5 = st, covariate = cols, mean_baseline = m0, mean_completed_weighted = m1,
        smd = ifelse(is.finite(den) & den > 0, (m1 - m0) / den, ifelse(is.finite(m0) & is.finite(m1) & abs(m1 - m0) < 1e-12, 0, NA_real_)), row.names = NULL)
      w <- z$wn[iz]; n <- length(w)
      wt[[length(wt) + 1]] <- data.frame(scheme = s, period = p, state5 = st, n_complete = n, ESS = if (n) sum(w)^2 / sum(w^2) else NA_real_,
        mean_weight = if (n) mean(w) else NA_real_, max_weight = if (n) max(w) else NA_real_, max_over_mean = if (n) max(w) / mean(w) else NA_real_,
        top1_share = if (n) sum(sort(w, decreasing = TRUE)[seq_len(ceiling(.01 * n))]) / sum(w) else NA_real_,
        n_at_floor = sum(z$at_floor[iz]), n_at_lower = sum(z$at_lower[iz]), n_at_upper = sum(z$at_upper[iz]))
    }
  }
  list(smd = do.call(rbind, smd), weights = do.call(rbind, wt))
}
ep_v2_calibration_interval <- function(cvtab = ep_cvtab, d = ep_d, models = c("A", "Lognormal")) {
  opts <- options(survey.lonely.psu = "adjust", survey.adjust.domain.lonely = TRUE); on.exit(options(opts))
  d$wcv <- cvtab$w; n <- table(as.character(d$period), as.character(d$state0))
  do.call(rbind, lapply(models, function(m) {
    P <- cvtab$prob[[m]]
    do.call(rbind, lapply(ep_Y, function(s) {
      d$obs <- as.numeric(d$y1 == s); d$pred <- P[, s]; d$diff <- d$obs - d$pred
      ds <- survey::svydesign(ids = ~psu, strata = ~strata, weights = ~wcv, data = d, nest = TRUE)
      b <- survey::svyby(~obs + pred + diff, ~period + state0, ds, survey::svymean, keep.var = TRUE)
      crit <- stats::qt(.975, survey::degf(ds)); nn <- n[cbind(as.character(b$period), as.character(b$state0))]
      data.frame(model = m, period = as.character(b$period), state0 = as.character(b$state0), destination = s, n_origin = as.integer(nn),
        observed = b$obs, predicted = b$pred, difference = b$diff, se = b$se.diff, lower = b$diff - crit * b$se.diff,
        upper = b$diff + crit * b$se.diff, sparse = nn < 30, row.names = NULL)
    }))
  }))
}
ep_v2_plots <- function() {
  a <- ep_v2_attr[!ep_v2_attr$state5 %in% c("All", "Unknown"), ]; st <- c("completed", "phone_only", "lost", "impeded", "deceased")
  long <- do.call(rbind, lapply(st, function(v) data.frame(period = a$period, state5 = factor(a$state5, ep_v2_states), status = factor(v, st), n = a[[v]])))
  p <- ggplot2::ggplot(long, ggplot2::aes(state5, n, fill = status)) + ggplot2::geom_col(position = "fill") + ggplot2::facet_wrap(~period) +
    ggplot2::scale_fill_manual(values = unname(ep_palette[c("blue", "heat", "olive", "rust", "grey")])) + ep_theme() +
    ggplot2::labs(title = "Where do the baseline respondents go?",
      subtitle = "Deceased and impeded are competing exits; phone-only VII respondents lack the alcohol module", x = "Origin state", y = "Share of baseline", fill = NULL)
  ep_fig(p, "fig_v2_attrition", 10, 5)
  o <- ep_v2_or[ep_v2_or$term != "(Intercept)" & ep_v2_or$n_nonzero >= 30, ]
  p <- ggplot2::ggplot(o, ggplot2::aes(OR, term)) + ggplot2::geom_vline(xintercept = 1, linetype = 2, color = ep_palette["grey"]) +
    ggplot2::geom_pointrange(ggplot2::aes(xmin = lower, xmax = upper), color = ep_palette["blue"]) + ggplot2::facet_wrap(~period) +
    ggplot2::scale_x_log10() + ep_theme() + ggplot2::labs(title = "Who is followed with the alcohol module?",
      subtitle = "Survey-weighted logistic response model; design-based 95% intervals; terms active in fewer than 30 rows omitted",
      x = "Odds ratio (log scale)", y = NULL)
  ep_fig(p, "fig_v2_odds_ratios", 11, 8)
  m <- ep_v2_mat[ep_v2_mat$period != "All" & !ep_v2_mat$structural & is.finite(ep_v2_mat$estimate), ]
  base <- m[m$scheme == "official", ]; alt <- m[m$scheme != "official", ]
  alt$official <- base$estimate[match(paste(alt$model, alt$group, alt$from, alt$to), paste(base$model, base$group, base$from, base$to))]
  p <- ggplot2::ggplot(alt, ggplot2::aes(official, estimate, color = scheme)) + ggplot2::geom_abline(linetype = 2, color = ep_palette["grey"]) +
    ggplot2::geom_point(alpha = .6) + ggplot2::facet_grid(model ~ period) + ggplot2::scale_color_manual(values = unname(ep_palette[c("blue", "rust")])) +
    ep_theme() + ggplot2::labs(title = "Do the weighting schemes move the transition probabilities?",
      subtitle = "Interval x sex x age cells; official weight only on the x axis", x = "Official weight only", y = "Official x IPW")
  ep_fig(p, "fig_v2_scheme_shift", 10, 7)
  s <- ep_v2_smd[ep_v2_smd$state5 == "All" & is.finite(ep_v2_smd$smd), ]
  p <- ggplot2::ggplot(s, ggplot2::aes(abs(smd), covariate, color = scheme)) + ggplot2::geom_vline(xintercept = .1, linetype = 2, color = ep_palette["grey"]) +
    ggplot2::geom_point(position = ggplot2::position_dodge(.5)) + ggplot2::facet_wrap(~period) +
    ggplot2::scale_color_manual(values = unname(ep_palette[c("grey", "blue", "rust")])) + ep_theme() +
    ggplot2::labs(title = "Balance after weighting", subtitle = "|SMD| of the completed weighted sample against the baseline risk set; target below 0.1", x = "|SMD|", y = NULL)
  ep_fig(p, "fig_v2_smd", 11, 9)
  k <- ep_v2_calint[!ep_v2_calint$sparse, ]; k$state0 <- factor(k$state0, ep_ST); k$destination <- factor(k$destination, ep_Y)
  p <- ggplot2::ggplot(k, ggplot2::aes(state0, difference, color = destination)) + ggplot2::geom_hline(yintercept = 0, linetype = 2, color = ep_palette["grey"]) +
    ggplot2::geom_pointrange(ggplot2::aes(ymin = lower, ymax = upper), position = ggplot2::position_dodge(.6)) + ggplot2::facet_grid(model ~ period) +
    ggplot2::scale_color_manual(values = unname(ep_palette[c("blue", "rust", "olive", "grey", "heat")])) + ep_theme() +
    ggplot2::labs(title = "Held-out observed minus predicted share by interval and origin state",
      subtitle = "Design-based 95% intervals; origin cells with fewer than 30 rows omitted", x = "Origin state", y = "Observed - predicted")
  ep_fig(p, "fig_v2_calibration_interval", 11, 7)
}
cat(sprintf("Elapsed: %.2f minutes\n", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
