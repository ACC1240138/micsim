# Since 2026-10-27 TSM_ENPG_v4_EN.ipynb is the single source of the TSM v4 analysis and is edited directly; this file no
# longer builds it. It is still sourced by tsm_r7_r11_direct.R, tsm_r7_r11_comparators.R, encavi_tsm_explicado.R and the
# tests. The notebook holds identical copies of these definitions (2026-10-26): a change on either side must be mirrored.
.t0 <- Sys.time()
# tsm_markov_models.R -- model layer of TSM v4 (v3 engine, five states): port of the EPS engine (eps_markov_core.R) to the TSM risk set.
# Port rules: same algorithms, numerical conventions and output column names as the ep_* functions; four TSM
# periods with their own interval lengths; no survey design (the whole-person bootstrap is the primary
# uncertainty); destination and state vectors are parameters (defaults ts_Y / ts_ST: five states with C3 and C4
# merged into C3plus since 2026-10-26). All confidential row-level objects stay in memory.
#
# Expected globals (defined by the data layer tsm_markov_data.R or by the notebook sections before use):
#   constants : ts_seed, ts_B, ts_repeats, ts_K, ts_kgrid, ts_ST, ts_Y, ts_ages, ts_periods, ts_edu_levels,
#               ts_time (period, from, to, months, years, min_years, max_years),
#               ts_round_months (wave, year_month, months since R7)
#   primitives: ts_binary_fit(d, y, formula, w), ts_binary_prob(o, d), ts_ipw_fit(r), ts_ipw_apply(r, fit),
#               ts_wquant(x, w, p), ts_save(x, name), ts_show, ts_fig(p, name, w, h), ts_check(ok, label),
#               ts_warn(expr), ts_theme(), ts_palette, ts_age(a), ts_key(d, v),
#               ts_compatible(sex_a, sex_b, age_a, age_b, months)
#   data      : ts_risk (schema in the plan), ts_d (after IPW: p_obs, untrimmed, wcorrected, wn),
#               ts_period_mass, ts_W (id, wave, age, sex, current, grams, state, ...), ts_out, ts_checks, ts_warnings
#   model run : ts_k (tuned shrinkage c(A, A_education)), ts_fits, ts_cvtab
#   plots     : ts_rank_tab, ts_pool_tab, ts_counts, ts_contrasts, ts_cal, ts_cal_cells, ts_ci, ts_sensitivity,
#               ts_cross (result of ts_crosscheck_eps)
# ts_x is defined here (contract) with the same row guard as the data layer, so sourcing order cannot drop it.
ts_x <- function(d, formula, terms_keep = NULL) {
  x <- stats::model.matrix(formula, d)
  stopifnot(nrow(x) == nrow(d))   # a NA covariate would silently drop rows and misalign predictions
  if (!is.null(terms_keep)) x <- x[, terms_keep, drop = FALSE]
  x
}
# Origin states implied by a destination vector: N0, FD, then the drinking categories.
ts_states <- function(Y = ts_Y) c("N0", "FD", Y[-1])
ts_formula <- function(education = "ordinal", history = FALSE, literal_jrt = FALSE, extras = FALSE) {
  if (literal_jrt) return(~ state0 * age_group + state0 * sex + sex * age_group + period)
  ed <- switch(education, none = "", ordinal = " + edu_num + edu_missing",
    interaction = " + edu_num * (current0 + sex + age_group) + edu_missing",
    categorical = " + edu")
  stats::as.formula(paste0("~ state0 + sex * age_group + period + lg0", ed,
                           if (history) " + earlier_state + earlier_lg" else "",
                           if (extras) " + signal0f + hed6_0 + phq2 + region + employment + log_history" else ""))
}
ts_matrix_fit <- function(d, formula, y, family) {
  X <- ts_x(d, formula); w <- d$wn / mean(d$wn[d$wn > 0]); keep <- w > 0
  q <- qr(X[keep, , drop = FALSE] * sqrt(w[keep])); cols <- sort(q$pivot[seq_len(q$rank)])
  XX <- X[, cols, drop = FALSE]; positive <- y > 0 & keep
  if (family == "gamma") {
    fit <- ts_warn(tryCatch(stats::glm.fit(XX[positive, , drop = FALSE], y[positive], weights = w[positive],
      family = stats::Gamma("log"), control = stats::glm.control(maxit = 100)), error = function(e) list(converged = FALSE)))
    XXp <- XX[positive, , drop = FALSE]
    if (!isTRUE(fit$converged) || any(!is.finite(fit$coefficients))) {
      # IRLS can fail on sparse TSM folds and resamples; the v2 Desktop fallback minimises the same convex Gamma
      # log-mean objective. Columns collinear among the positive rows are dropped first (the returned columns follow).
      ww0 <- w[positive] / sum(w[positive]); ly <- log(y[positive])
      q2 <- qr(XXp * sqrt(ww0)); keep2 <- sort(q2$pivot[seq_len(q2$rank)]); XXp <- XXp[, keep2, drop = FALSE]; cols <- cols[keep2]
      objective <- function(beta) { eta <- as.numeric(XXp %*% beta); sum(ww0 * (eta + exp(ly - eta))) }
      gradient <- function(beta) { eta <- as.numeric(XXp %*% beta); as.numeric(crossprod(XXp, ww0 * (1 - exp(ly - eta)))) }
      beta <- stats::lm.wfit(XXp, ly, ww0)$coefficients
      for (attempt in 1:5) {
        opt <- stats::optim(beta, objective, gradient, method = "BFGS", control = list(maxit = 5000, reltol = 1e-14))
        beta <- opt$par
        if (max(abs(gradient(beta))) < 1e-4) break
      }
      stopifnot(all(is.finite(beta)), max(abs(gradient(beta))) < 1e-4)
      fit <- list(coefficients = stats::setNames(beta, colnames(XXp)), converged = TRUE)
      ts_warnings <<- c(ts_warnings, "Gamma amount model fitted by BFGS fallback after IRLS nonconvergence")
    }
    mu <- as.numeric(exp(XXp %*% fit$coefficients))
    ratio <- y[positive] / mu; ww <- w[positive] / sum(w[positive])
    # Survey weights are frequency importance weights, not inverse residual variances.
    loss <- function(a) { sh <- exp(a); -sum(ww * (sh * log(sh) - lgamma(sh) + (sh - 1) * log(ratio) - sh * ratio)) }
    shape <- exp(stats::optimize(loss, c(log(.03), log(1000)))$minimum)
    list(coef = fit$coefficients, formula = formula, columns = colnames(X)[cols], shape = shape, kind = family)
  } else {
    fit <- stats::lm.wfit(XX[positive, , drop = FALSE], log(y[positive]), w[positive])
    sigma <- sqrt(sum(w[positive] * fit$residuals^2) / sum(w[positive]))
    list(coef = fit$coefficients, formula = formula, columns = colnames(X)[cols], sigma = sigma, kind = family)
  }
}
ts_class_fit <- function(d, formula, kind, positive = FALSE, Y = ts_Y) {
  cls <- if (positive) Y[-1] else Y
  y <- factor(as.character(d$y1), levels = cls, ordered = kind == "ordinal")
  good <- d$wn > 0 & !is.na(y); d <- d[good, ]; y <- droplevels(y[good])
  w <- d$wn / mean(d$wn)
  if (nlevels(y) == 1) return(list(constant = levels(y), classes = cls))
  X <- ts_x(d, formula)
  X <- X[, colnames(X) != "(Intercept)", drop = FALSE]
  q <- qr(cbind(1, X) * sqrt(w)); keep <- setdiff(sort(q$pivot[seq_len(q$rank)]), 1) - 1
  cols <- colnames(X)[keep]; XX <- X[, keep, drop = FALSE]
  dat <- data.frame(y = y, XX, w = w, check.names = FALSE)
  names(dat)[seq_along(cols) + 1] <- paste0("x", seq_along(cols))
  f <- stats::as.formula(paste("y ~", paste(paste0("x", seq_along(cols)), collapse = " + ")))
  if (kind == "ordinal" && nlevels(y) > 2) {
    fit <- tryCatch(ts_warn(MASS::polr(f, data = dat, weights = w,
      method = "logistic", Hess = FALSE, control = list(maxit = 500))), error = identity)
    valid <- !inherits(fit, "error") && isTRUE(fit$convergence == 0) && all(is.finite(stats::coef(fit)))
    if (!valid) {
      # Sparse samples can make polr's binary-GLM starting values nonfinite.
      # Weighted marginal thresholds with zero slopes give a finite ordered start.
      mass <- as.numeric(tapply(w, y, sum)); cuts <- stats::qlogis(head(cumsum(mass) / sum(mass), -1))
      stopifnot(all(is.finite(cuts)), all(diff(cuts) > 0))
      fit <- ts_warn(MASS::polr(f, data = dat, weights = w, method = "logistic", Hess = FALSE,
        start = c(rep(0, length(cols)), cuts), control = list(maxit = 1000)))
      ts_warnings <<- c(ts_warnings, "Ordinal fit restarted from weighted marginal thresholds")
    }
  } else fit <- ts_warn(nnet::multinom(f, data = dat, weights = w, decay = .1, trace = FALSE, maxit = 500))
  if (!is.null(fit$convergence)) stopifnot(fit$convergence == 0)
  stopifnot(all(is.finite(stats::coef(fit))))
  list(fit = fit, formula = formula, columns = cols, classes = cls, observed = levels(y))
}
ts_class_prob <- function(o, d) {
  ans <- matrix(0, nrow(d), length(o$classes), dimnames = list(NULL, o$classes))
  if (!is.null(o$constant)) { ans[, o$constant] <- 1; return(ans) }
  x <- ts_x(d, o$formula, o$columns); nd <- as.data.frame(x); names(nd) <- paste0("x", seq_len(ncol(nd)))
  p <- ts_warn(stats::predict(o$fit, nd, type = "probs"))
  if (is.null(dim(p))) {
    if (nrow(d) == 1 && length(p) == length(o$observed)) p <- matrix(p, 1, dimnames = list(NULL, o$observed))
    # cbind() names the columns "" and "p"; the two observed classes must be set explicitly (latent in the EPS core).
    else if (length(o$observed) == 2) { p <- cbind(1 - p, p); colnames(p) <- o$observed }
    else stop("Unexpected probability dimensions")
  }
  if (is.null(colnames(p))) colnames(p) <- o$observed
  stopifnot(all(colnames(p) %in% o$classes))
  ans[, colnames(p)] <- p
  ans
}
ts_Afit <- function(d, k = 100, education = FALSE, Y = ts_Y) {
  ST <- ts_states(Y); by <- c("sex", "age_group", if (education) "edu")
  count <- function(z) {
    t <- tapply(z$wn, list(factor(z$state0, ST), factor(z$y1, Y)), sum)
    t[is.na(t)] <- 0; t
  }
  shrink <- function(x, p, k) (x + k * p) / (rowSums(x) + k)
  global <- shrink(count(d), matrix(1 / length(Y), length(ST), length(Y)), .5)
  per <- lapply(split(d, d$period, drop = TRUE), function(dp) {
    pg <- shrink(count(dp), global, k)
    ps <- lapply(split(dp, dp$sex, drop = TRUE), function(ds) shrink(count(ds), pg, k))
    cells <- lapply(split(dp, ts_key(dp, by)), function(z) shrink(count(z), ps[[as.character(z$sex[1])]], k))
    list(global = pg, sex = ps, cells = cells)
  })
  list(per = per, global = global, by = by, k = k, classes = Y)
}
ts_Aprob <- function(o, d) {
  keys <- ts_key(d, o$by); Y <- if (is.null(o$classes)) ts_Y else o$classes
  ans <- matrix(NA_real_, nrow(d), length(Y), dimnames = list(NULL, Y))
  for (i in seq_len(nrow(d))) {
    op <- o$per[[as.character(d$period[i])]]
    mat <- if (is.null(op)) o$global else if (!is.null(op$cells[[keys[i]]])) op$cells[[keys[i]]] else op$global
    ans[i, ] <- mat[as.character(d$state0[i]), ]
  }
  ans
}
ts_models <- list(
  A = list(kind = "matrix", education = FALSE), A_education = list(kind = "matrix", education = TRUE),
  Multinomial = list(kind = "multinomial", education = "ordinal"),
  Gamma = list(kind = "gamma", education = "ordinal"),
  Lognormal = list(kind = "lognormal", education = "ordinal"),
  Ordinal_two_part = list(kind = "ordinal", education = "ordinal"),
  NonPO_two_part = list(kind = "nonpo", education = "ordinal"),
  Ordinal_single = list(kind = "single", education = "ordinal"),
  JRT_reference = list(kind = "jrt", education = "none"),
  Gamma_no_education = list(kind = "gamma", education = "none"),
  Gamma_education_interaction = list(kind = "gamma", education = "interaction"),
  Lognormal_education_interaction = list(kind = "lognormal", education = "interaction"),
  Lognormal_tsm_extras = list(kind = "lognormal", education = "ordinal", extras = TRUE))
ts_main_models <- c("A", "Multinomial", "Gamma", "Lognormal", "Ordinal_two_part", "Ordinal_single", "JRT_reference")
ts_fit <- function(d, name, k = 100, history = FALSE, Y = ts_Y) {
  spec <- ts_models[[name]]
  if (spec$kind == "matrix") return(list(kind = "matrix", amount = ts_Afit(d, k, spec$education, Y), classes = Y))
  f <- ts_formula(spec$education, history = history, literal_jrt = spec$kind == "jrt", extras = isTRUE(spec$extras))
  if (spec$kind %in% c("single", "jrt", "multinomial")) return(list(kind = "class",
    amount = ts_class_fit(d, f, if (spec$kind == "multinomial") "multinomial" else "ordinal", FALSE, Y), classes = Y))
  p <- ts_binary_fit(d, as.numeric(d$y1 != "NC"), f, d$wn)
  dc <- d[d$y1 != "NC", ]
  amount <- if (spec$kind %in% c("ordinal", "nonpo")) ts_class_fit(dc, f, if (spec$kind == "ordinal") "ordinal" else "multinomial", TRUE, Y) else ts_matrix_fit(dc, f, dc$grams1, spec$kind)
  list(kind = spec$kind, participation = p, amount = amount, classes = Y)
}
ts_prob <- function(o, d) {
  Y <- if (is.null(o$classes)) ts_Y else o$classes
  if (o$kind == "matrix") p <- ts_Aprob(o$amount, d)
  else if (o$kind == "class") p <- ts_class_prob(o$amount, d)
  else {
    pc <- ts_binary_prob(o$participation, d)
    if (o$kind %in% c("ordinal", "nonpo")) pa <- ts_class_prob(o$amount, d)
    else {
      a <- o$amount; eta <- as.numeric(ts_x(d, a$formula, a$columns) %*% a$coef)
      cuts <- cbind(ifelse(d$sex == "Women", 20, 40), ifelse(d$sex == "Women", 40, 60), ifelse(d$sex == "Women", 60, 100))[, seq_len(length(Y) - 2), drop = FALSE]
      F <- if (o$kind == "gamma") stats::pgamma(cuts, shape = a$shape, scale = exp(eta) / a$shape) else
        stats::pnorm((log(cuts) - eta) / a$sigma)
      pa <- cbind(F[, 1], if (ncol(F) > 1) F[, -1, drop = FALSE] - F[, -ncol(F), drop = FALSE], 1 - F[, ncol(F)])
    }
    p <- cbind(1 - pc, pc * pa); colnames(p) <- Y
  }
  p <- pmax(p, 0); p <- p / rowSums(p)
  stopifnot(all(is.finite(p)), max(abs(rowSums(p) - 1)) < 1e-10, identical(colnames(p), Y))
  p
}
ts_loss <- function(P, y) {
  # One numerical floor and one scoring implementation for scores AND paired contrasts.
  Q <- pmax(P, 1e-8); Q <- Q / rowSums(Q)
  Y <- diag(ncol(P))[as.integer(y), , drop = FALSE]
  data.frame(logloss = -log(Q[cbind(seq_len(nrow(Q)), as.integer(y))]),
    brier = rowSums((P - Y)^2), correct = max.col(P, ties.method = "first") == as.integer(y))
}
ts_fold <- function(ids, k = 5, seed = ts_seed) {
  set.seed(seed); uu <- sort(unique(ids)); stats::setNames(sample(rep(seq_len(k), length.out = length(uu))), uu)
}
ts_tune <- function(r, education = FALSE, seed = ts_seed, Y = ts_Y) {
  f <- ts_fold(r$id, 3, seed); loss <- matrix(0, 3, length(ts_kgrid)); mass <- numeric(3)
  for (j in 1:3) {
    tr <- r[f[r$id] != j, ]; te <- r[f[r$id] == j, ]; nu <- ts_ipw_fit(tr)
    a <- ts_ipw_apply(tr, nu); b <- ts_ipw_apply(te, nu)
    mass[j] <- sum(b$wn)
    for (k in seq_along(ts_kgrid)) {
      pr <- ts_Aprob(ts_Afit(a, ts_kgrid[k], education, Y), b)
      loss[j, k] <- sum(b$wn * ts_loss(pr, b$y1)$logloss)
    }
  }
  s <- colSums(loss) / sum(mass)
  list(k = ts_kgrid[which.min(s)], scores = data.frame(k = ts_kgrid, logloss = s, education = education))
}
ts_cv <- function(r, model_names = names(ts_models), repeats = ts_repeats, K = ts_K, d = ts_d, Y = ts_Y) {
  ids <- d$row_id; N <- length(ids); nY <- length(Y)
  pred <- lapply(model_names, function(z) array(NA_real_, c(N, nY, repeats)))
  names(pred) <- model_names; weights <- matrix(NA_real_, N, repeats); audits <- list(); tunes <- list(); kk <- 0
  tune_edu <- "A_education" %in% model_names
  for (rep in seq_len(repeats)) {
    folds <- ts_fold(r$id, K, ts_seed + rep)
    for (f in seq_len(K)) {
      tr <- r[folds[r$id] != f, ]; te <- r[folds[r$id] == f, ]
      ts_check(!length(intersect(tr$id, te$id)), paste0("Disjoint persons CV ", rep, ":", f))
      nu <- ts_ipw_fit(tr); a <- ts_ipw_apply(tr, nu); b <- ts_ipw_apply(te, nu)
      ix <- match(b$row_id, ids); weights[ix, rep] <- b$wcorrected
      ka <- ts_tune(tr, FALSE, ts_seed + 100 * rep + f, Y = Y)
      ke <- if (tune_edu) ts_tune(tr, TRUE, ts_seed + 100 * rep + f, Y = Y) else NULL
      kk <- kk + 1
      tunes[[kk]] <- rbind(data.frame(rep = rep, fold = f, ka$scores), if (tune_edu) data.frame(rep = rep, fold = f, ke$scores))
      audits[[kk]] <- data.frame(rep = rep, fold = f, train_persons = length(unique(tr$id)), test_persons = length(unique(te$id)),
        test_pairs = nrow(b), overlap = 0L, IPW_training_only = TRUE, k_A = ka$k, k_A_education = if (tune_edu) ke$k else NA_real_)
      for (nm in model_names) pred[[nm]][ix, , rep] <- ts_prob(ts_fit(a, nm, if (nm == "A_education") ke$k else ka$k, Y = Y), b)
      cat(sprintf("CV repeat %d/%d, fold %d/%d complete\n", rep, repeats, f, K))
    }
    # Undo fold-specific normalisation in scores by fixing period totals, not equal fold totals.
    for (p in ts_periods) { ii <- d$period == p; weights[ii, rep] <- weights[ii, rep] / sum(weights[ii, rep]) * ts_period_mass[[p]] }
  }
  ts_check(all(vapply(pred, function(x) all(is.finite(x)), TRUE)), "Every held-out prediction is finite")
  list(pred = pred, weights = weights, audit = do.call(rbind, audits), tuning = do.call(rbind, tunes))
}
ts_cv_tables <- function(cv, d = ts_d, Y = ts_Y) {
  scores <- list(); losses <- list(); means <- list()
  for (nm in names(cv$pred)) {
    ar <- cv$pred[[nm]]; lr <- lapply(seq_len(dim(ar)[3]), function(j) ts_loss(ar[, , j], d$y1))
    losses[[nm]] <- Reduce("+", lapply(seq_along(lr), function(j) as.matrix(lr[[j]]) * cv$weights[, j])) /
      rowSums(cv$weights)
    means[[nm]] <- Reduce("+", lapply(seq_len(dim(ar)[3]), function(j) ar[, , j] * cv$weights[, j])) / rowSums(cv$weights)
    colnames(means[[nm]]) <- Y
    for (j in seq_along(lr)) scores[[length(scores) + 1]] <- data.frame(model = nm, repeat_id = j,
      logloss = stats::weighted.mean(lr[[j]]$logloss, cv$weights[, j]),
      brier = stats::weighted.mean(lr[[j]]$brier, cv$weights[, j]),
      accuracy = stats::weighted.mean(lr[[j]]$correct, cv$weights[, j]))
  }
  s <- do.call(rbind, scores); summary <- stats::aggregate(cbind(logloss, brier, accuracy) ~ model, s, mean)
  summary <- summary[order(summary$logloss), ]; rownames(summary) <- NULL
  list(scores = s, summary = summary, loss = losses, prob = means, w = rowMeans(cv$weights))
}
ts_score_contrasts <- function(cvtab, d = ts_d) {
  d$wcv <- cvtab$w
  ds <- survey::svydesign(ids = ~id, weights = ~wcv, data = d)
  # EPS contrasts first (same order), then the remaining pairs among the main models (JRT as reference),
  # the EPS education contrasts and the TSM-only extras contrast. Pairs absent from cvtab are skipped.
  pairs <- list(c("Lognormal", "Gamma"), c("Gamma", "A"), c("Lognormal", "A"),
    c("NonPO_two_part", "Ordinal_two_part"),
    c("Ordinal_two_part", "Gamma"), c("Ordinal_single", "Gamma"), c("Multinomial", "Gamma"),
    c("Multinomial", "A"), c("Ordinal_two_part", "A"), c("Ordinal_single", "A"),
    c("Multinomial", "Lognormal"), c("Ordinal_two_part", "Lognormal"), c("Ordinal_single", "Lognormal"),
    c("Ordinal_two_part", "Multinomial"), c("Ordinal_single", "Multinomial"), c("Ordinal_single", "Ordinal_two_part"),
    c("A", "JRT_reference"), c("Multinomial", "JRT_reference"), c("Gamma", "JRT_reference"), c("Lognormal", "JRT_reference"),
    c("Ordinal_two_part", "JRT_reference"), c("Ordinal_single", "JRT_reference"),
    c("A_education", "A"), c("Gamma", "Gamma_no_education"), c("Gamma_education_interaction", "Gamma"),
    c("Lognormal_education_interaction", "Lognormal"), c("Lognormal_tsm_extras", "Lognormal"))
  pairs <- Filter(function(z) all(z %in% names(cvtab$loss)), pairs)
  crit <- stats::qt(.975, survey::degf(ds))
  out <- lapply(pairs, function(z) {
    ds$variables$difference <- cvtab$loss[[z[1]]][, "logloss"] - cvtab$loss[[z[2]]][, "logloss"]
    m <- survey::svymean(~difference, ds); se <- sqrt(stats::vcov(m)[1, 1]); v <- as.numeric(stats::coef(m))
    data.frame(model = z[1], reference = z[2], difference = v, se_person = se, lower = v - crit * se, upper = v + crit * se,
      relative_geometric_probability_gain_pct = 100 * (exp(-v) - 1),
      mean_absolute_class_probability_change_pp = 100 * stats::weighted.mean(rowMeans(abs(cvtab$prob[[z[1]]] - cvtab$prob[[z[2]]])), cvtab$w),
      interval_basis = "person-cluster Taylor; conditional on fitted OOF predictions")
  })
  do.call(rbind, out)
}
ts_matrices <- function(d, P, model, by = c("period", "sex", "age_group"), Y = ts_Y) {
  ST <- ts_states(Y); nS <- length(ST); nY <- length(Y)
  groups <- split(seq_len(nrow(d)), ts_key(d, by))
  rows <- lapply(groups, function(ii) {
    z <- d[ii, ]; out <- lapply(ST, function(st) {
      ix <- ii[as.character(z$state0) == st]; n <- sum(d$mult[ix] > 0)
      p5 <- if (length(ix) && sum(d$wn[ix]) > 0) colSums(P[ix, , drop = FALSE] * d$wn[ix]) / sum(d$wn[ix]) else rep(NA_real_, nY)
      p6 <- rep(0, nS); p6[3:nS] <- p5[-1]; p6[if (st == "N0") 1 else 2] <- p5[1]
      structural <- !(ST %in% c(if (st == "N0") "N0" else "FD", ST[3:nS]))
      data.frame(model = model, group = ts_key(z[1, ], by), z[rep(1, nS), by, drop = FALSE],
        from = st, to = ST, n_origin = n, estimate = if (n) p6 else NA_real_, structural = structural,
        support = if (n == 0) "unobserved origin" else if (n < 30) "sparse" else "observed", row.names = NULL)
    })
    do.call(rbind, out)
  })
  do.call(rbind, rows)
}
ts_targets <- function(d, fits) {
  tabs <- lapply(names(fits), function(nm) {
    p <- ts_prob(fits[[nm]], d)
    ts_matrices(d, p, nm, Y = colnames(p))
  })
  do.call(rbind, tabs)
}
ts_vector <- function(tab) {
  k <- paste(tab$model, tab$group, tab$from, tab$to, sep = "::")
  stats::setNames(tab$estimate, k)
}
ts_coef <- function(fits) {
  out <- list()
  for (nm in c("Gamma", "Lognormal")) {
    o <- fits[[nm]]
    for (part in c("participation", "amount")) {
      b <- o[[part]]$coef
      out[[length(out) + 1]] <- data.frame(model = nm, component = part, term = names(b), estimate = as.numeric(b))
    }
    v <- if (nm == "Gamma") o$amount$shape else o$amount$sigma
    out[[length(out) + 1]] <- data.frame(model = nm, component = "amount", term = if (nm == "Gamma") "shape" else "sigma", estimate = v)
  }
  do.call(rbind, out)
}
# The three summary probabilities of the EPS conversion_sensitivity table from a probability matrix.
ts_quantities <- function(pr, d) {
  c1 <- d$state0 == "C1"; nc <- ncol(pr)
  c(Drinking_t1 = stats::weighted.mean(1 - pr[, 1], d$wn),
    Escalation_from_C1 = stats::weighted.mean(rowSums(pr[c1, 3:nc, drop = FALSE]), d$wn[c1]),
    C3_C4_t1 = stats::weighted.mean(rowSums(pr[, 4:nc, drop = FALSE]), d$wn))
}
ts_person_mult <- function(master) {
  mult <- tabulate(sample.int(length(master), length(master), replace = TRUE), nbins = length(master))
  stats::setNames(mult, master)
}
ts_replicate <- function(mult, model_names = ts_main_models, annual = FALSE) {
  master <- sort(unique(ts_risk$id)); r <- ts_risk; r$mult <- as.numeric(mult)[match(r$id, master)]
  ip <- ts_ipw_fit(r); d <- ts_ipw_apply(r, ip)
  fits <- lapply(stats::setNames(model_names, model_names), function(nm) ts_fit(d, nm, ts_k[[if (nm == "A_education") 2 else 1]]))
  # Targets by period x sex x age group (as EPS) plus the pooled sex x age group and "All" matrices, so the
  # pooled tables also get person intervals; keys never collide (group "R7_R8|Men|18-29" vs "Men|18-29" vs "All").
  dd <- d; dd$pooled <- "All"
  target <- unlist(lapply(model_names, function(nm) {
    P <- ts_prob(fits[[nm]], d); Y <- colnames(P)
    c(ts_vector(ts_matrices(d, P, nm, Y = Y)), ts_vector(ts_matrices(d, P, nm, by = c("sex", "age_group"), Y = Y)),
      ts_vector(ts_matrices(dd, P, nm, by = "pooled", Y = Y)))
  }))
  co <- if (all(c("Gamma", "Lognormal") %in% model_names)) ts_coef(fits) else NULL
  ans <- list(target = target, coefficients = if (!is.null(co)) stats::setNames(co$estimate,
    paste(co$model, co$component, co$term, sep = "::")) else NULL)
  if (annual) {
    am <- intersect(c("A", "Gamma", "Lognormal"), model_names)
    ans$annual <- unlist(lapply(fits[am], function(f) as.vector(ts_annual(d, f, starts = .05)$P)))
  }
  ans
}
ts_bootstrap_person <- function(model_names = c("A", "Gamma", "Lognormal", "Ordinal_single"), annual = TRUE, B = ts_B) {
  set.seed(ts_seed + 600L)
  master <- sort(unique(ts_risk$id)); ans <- vector("list", B); audits <- vector("list", B)
  for (b in seq_len(B)) {
    m <- ts_person_mult(master)
    ans[[b]] <- tryCatch(ts_replicate(as.numeric(m), model_names = model_names, annual = annual), error = function(e) list(error = conditionMessage(e)))
    audits[[b]] <- data.frame(replicate = b, success = is.null(ans[[b]]$error),
      error = if (is.null(ans[[b]]$error)) "" else ans[[b]]$error)
    if (b %% 100 == 0 || b == B) cat(sprintf("Person bootstrap %d/%d; IPW refitted\n", b, B))
  }
  audit <- do.call(rbind, audits); ts_save(audit, "person_bootstrap_audit")
  if (!all(audit$success)) stop("Person bootstrap failures: inspect person_bootstrap_audit.csv; no incomplete-bootstrap CI")
  ans
}
ts_interval <- function(point, reps, probability = TRUE) {
  # EPS ep_interval(method = "person"): bootstrap SD, normal critical value, logit scale for probabilities.
  good <- is.finite(point) & apply(reps, 2, function(x) all(is.finite(x)))
  s <- apply(reps, 2, stats::sd); crit <- stats::qnorm(.975)
  if (probability) {
    lo <- hi <- rep(NA_real_, length(point))
    interior <- which(good & point > 0 & point < 1)
    # Keep the actual centre, including very small tail probabilities.
    p <- point[interior]; step <- crit * s[interior] / pmax(p * (1 - p), .Machine$double.xmin)
    lo[interior] <- stats::plogis(stats::qlogis(p) - step)
    hi[interior] <- stats::plogis(stats::qlogis(p) + step)
    boundary <- which(good & (point == 0 | point == 1))
    lo[boundary] <- pmax(0, point[boundary] - crit * s[boundary])
    hi[boundary] <- pmin(1, point[boundary] + crit * s[boundary])
  } else { lo <- point - crit * s; hi <- point + crit * s }
  lo[!good] <- hi[!good] <- NA_real_
  ts_check(all(lo[good] <= point[good] + 1e-14 & hi[good] >= point[good] - 1e-14),
           "Every available interval includes its point estimate")
  data.frame(se = s, lower = lo, upper = hi, valid_replicates = colSums(is.finite(reps)),
    interval_status = ifelse(good, "available", "origin unsupported in at least one replicate"))
}
ts_bootstrap_stability <- function(mat, sizes = c(100, 250, 500, 1000)) {
  # Port of the EPS ep_mc block; the reference SD uses every replicate in mat (ts_B in the real run).
  sizes <- sort(unique(c(sizes[sizes < nrow(mat)], nrow(mat))))
  ref <- apply(mat, 2, stats::sd)
  do.call(rbind, lapply(sizes, function(B) {
    s <- apply(mat[seq_len(B), , drop = FALSE], 2, stats::sd); good <- is.finite(s) & is.finite(ref) & ref > 0
    data.frame(replicates = B, median_SE_ratio_to_1000 = stats::median(s[good] / ref[good]),
      p90_absolute_relative_difference = as.numeric(stats::quantile(abs(s[good] / ref[good] - 1), .9)))
  }))
}
ts_calibration_cells <- function(cvtab, d = ts_d,
                                 models = c("A", "Gamma", "Lognormal", "Ordinal_two_part", "Ordinal_single", "Multinomial")) {
  models <- intersect(models, names(cvtab$prob)); w <- cvtab$w
  cells <- split(seq_len(nrow(d)), ts_key(d, c("state0", "sex", "age_group")))
  out <- lapply(models, function(nm) {
    P <- cvtab$prob[[nm]]; Y <- colnames(P)
    do.call(rbind, lapply(cells, function(ii) {
      z <- d[ii[1], ]; sw <- sum(w[ii])
      obs <- vapply(Y, function(s) sum(w[ii] * (d$y1[ii] == s)) / sw, 1); pred <- colSums(P[ii, , drop = FALSE] * w[ii]) / sw
      data.frame(model = nm, state0 = as.character(z$state0), sex = as.character(z$sex), age_group = as.character(z$age_group),
        destination = Y, n_origin = length(ii), observed = unname(obs), predicted = unname(pred),
        difference = unname(pred - obs), absolute_difference = unname(abs(pred - obs)),
        relative_difference = unname(ifelse(obs > 0, (pred - obs) / obs, NA_real_)), sparse = length(ii) < 30, row.names = NULL)
    }))
  })
  do.call(rbind, out)
}
# Continuous-time generator: free rates N0->C, FD->C, C->FD and C->C; annual rows remain model-derived scenarios.
ts_ij_fun <- function(n) rbind(cbind(1, 3:n), cbind(2, 3:n), cbind(3:n, 2),
                               do.call(rbind, lapply(3:n, function(i) cbind(i, setdiff(3:n, i)))))
ts_ij <- ts_ij_fun(length(ts_ST))
ts_Q <- function(theta, ij = ts_ij) {
  n <- max(ij); q <- matrix(0, n, n); q[ij] <- exp(pmin(pmax(theta, -14), 2)); diag(q) <- -rowSums(q); q
}
ts_expm <- function(A) {
  s <- max(0, ceiling(log2(max(abs(A), 1e-12))) + 1); a <- A / 2^s; E <- diag(nrow(a)); term <- E
  for (k in 1:22) { term <- term %*% a / k; E <- E + term }
  if (s > 0) for (k in seq_len(s)) E <- E %*% E
  E
}
ts_generator <- function(targets, total, lambda = 5e-5, starts = c(.02, .05, .1), check_gradient = FALSE) {
  # targets: list of list(P = n x (n-1) matrix with NC first, n = row masses, delta = years); roww = n / total.
  n <- nrow(targets[[1]]$P); ij <- ts_ij_fun(n)
  # Exact Frechet derivative in an eigensystem avoids numerical gradients in every replicate.
  # A fixed weak ridge is disclosed and remains fixed in bootstrap replicates.
  last <- NULL; cache <- NULL
  evaluate <- function(th) {
    if (!is.null(last) && identical(th, last)) return(cache)
    q <- ts_Q(th, ij); eig <- eigen(q); V <- eig$vectors; S <- solve(V); ev <- eig$values
    value <- 0; grad <- numeric(length(th))
    for (z in targets) {
      evexp <- exp(ev * z$delta); pp <- Re(V %*% diag(evexp, n) %*% S)
      p5 <- cbind(pp[, 1] + pp[, 2], pp[, 3:n, drop = FALSE]); err <- p5 - z$P; roww <- z$n / total
      value <- value + sum(roww * rowSums(err^2))
      den <- outer(ev, ev, "-"); num <- outer(evexp, evexp, "-")
      F <- num / den; equal <- abs(den) < 1e-8
      lim <- z$delta * exp(outer(ev, ev, "+") * z$delta / 2); F[equal] <- lim[equal]
      for (k in seq_along(th)) {
        i <- ij[k, 1]; j <- ij[k, 2]
        E <- outer(S[, i], V[j, ] - V[i, ]) * exp(th[k])
        dp <- Re(V %*% (F * E) %*% S); dp5 <- cbind(dp[, 1] + dp[, 2], dp[, 3:n, drop = FALSE])
        grad[k] <- grad[k] + 2 * sum(roww * rowSums(err * dp5))
      }
    }
    penalty <- lambda * mean((th - log(.05))^2)
    last <<- th; cache <<- list(value = value + penalty, gradient = grad + 2 * lambda * (th - log(.05)) / length(th), raw = value)
    cache
  }
  loss <- function(th) evaluate(th)$value
  gradient <- function(th) evaluate(th)$gradient
  gradient_error <- NA_real_
  if (check_gradient) {
    th <- rep(log(.05), nrow(ij)); analytic <- gradient(th)
    numerical <- vapply(seq_along(th), function(j) { a <- b <- th; a[j] <- a[j] + 1e-5; b[j] <- b[j] - 1e-5; (loss(a) - loss(b)) / 2e-5 }, 1)
    gradient_error <- max(abs(analytic - numerical)); stopifnot(gradient_error < 1e-6)
  }
  fits <- lapply(starts, function(x) {
    z <- stats::optim(rep(log(x), nrow(ij)), loss, gr = gradient, method = "L-BFGS-B", lower = -14, upper = 2,
                      control = list(maxit = 150, factr = 1e8))
    if (z$convergence != 0) z <- stats::optim(z$par, loss, gr = gradient, method = "L-BFGS-B", lower = -14, upper = 2, control = list(maxit = 500, factr = 1e8))
    z
  })
  vals <- vapply(fits, function(x) x$value, 1); best <- fits[[which.min(vals)]]
  stopifnot(best$convergence == 0)
  q <- ts_Q(best$par, ij); p <- ts_expm(q)
  list(P = p, Q = q, rmse = sqrt(evaluate(best$par)$raw), convergence = best$convergence,
    start_objective_range = diff(range(vals)), gradient_error = gradient_error,
    semigroup_error = max(abs(ts_expm(q * 2) - p %*% p)), ij = ij)
}
ts_annual <- function(d, fit, lambda = 5e-5, starts = c(.02, .05, .1), check_gradient = FALSE, levels = ts_ST) {
  P <- ts_prob(fit, d); n <- length(levels)
  targets <- lapply(ts_periods, function(p) {
    t <- matrix(0, n, n - 1); nr <- numeric(n)
    for (j in 1:n) {
      ii <- d$period == p & as.character(d$state0) == levels[j]
      nr[j] <- sum(d$wn[ii]); if (nr[j] > 0) t[j, ] <- colSums(P[ii, , drop = FALSE] * d$wn[ii]) / nr[j]
    }
    list(P = t, n = nr, delta = ts_time$years[match(p, ts_time$period)])
  })
  ts_generator(targets, total = sum(d$wn), lambda = lambda, starts = starts, check_gradient = check_gradient)
}
ts_transport <- function(risk = ts_risk, models = ts_main_models) {
  # Leave-one-interval-out: IPW is fitted per period on training persons (stage b needs the held-out period's
  # rows, as in EPS); outcome models use the other three periods; held-out rows take the period level of the
  # training period closest in elapsed months (proxy_period), as EPS assigned the source period.
  rows <- list(); coverage <- list(); folds <- ts_fold(risk$id, 5, ts_seed + 900)
  months <- ts_time$months[match(ts_periods, ts_time$period)]
  for (held in ts_periods) {
    train_periods <- setdiff(ts_periods, held)
    dm <- abs(months[match(train_periods, ts_periods)] - months[match(held, ts_periods)]); proxy <- train_periods[which(dm == min(dm))[1]]
    for (f in 1:5) {
      trainrisk <- risk[folds[risk$id] != f, ]; test <- risk[folds[risk$id] == f, ]
      nu <- ts_ipw_fit(trainrisk); a <- ts_ipw_apply(trainrisk, nu); b <- ts_ipw_apply(test, nu)
      a <- a[a$period %in% train_periods, ]; b <- b[b$period == held, ]
      ts_check(!length(intersect(a$id, b$id)), paste0("Transport IDs disjoint ", held, " ", f))
      state_ok <- as.character(b$state0) %in% as.character(unique(a$state0))
      age_ok <- b$age >= max(18, min(a$age)) & b$age <= min(65, max(a$age)); supported <- state_ok & age_ok
      coverage[[length(coverage) + 1]] <- data.frame(held_out = held, train_periods = paste(train_periods, collapse = "+"),
        proxy_period = proxy, fold = f, candidate_pairs = nrow(b), common_support = sum(supported),
        excluded_FD = sum(!supported & b$state0 == "FD"), excluded_state = sum(!state_ok), excluded_age = sum(state_ok & !age_ok))
      b <- b[supported, ]; b$period <- factor(proxy, levels = ts_periods)
      for (nm in models) {
        # Prespecified transport shrinkage avoids using held-out outcomes for tuning.
        fit <- ts_fit(a, nm, 100); P <- ts_prob(fit, b); loss <- ts_loss(P, b$y1)
        rows[[length(rows) + 1]] <- data.frame(held_out = held, proxy_period = proxy, fold = f, model = nm,
          logloss = stats::weighted.mean(loss$logloss, b$wcorrected), brier = stats::weighted.mean(loss$brier, b$wcorrected),
          weight_sum = sum(b$wcorrected), n = nrow(b))
      }
    }
  }
  list(scores = do.call(rbind, rows), coverage = do.call(rbind, coverage))
}
ts_coupling <- function(from, to, w, Y = ts_Y) {
  a <- vapply(Y, function(s) sum(w[from == s]), 1); b <- vapply(Y, function(s) sum(w[to == s]), 1)
  a <- a / sum(a); b <- b / sum(b); ca <- c(0, cumsum(a)); cb <- c(0, cumsum(b)); n <- length(Y)
  M <- matrix(0, n, n, dimnames = list(Y, Y))
  for (i in 1:n) for (j in 1:n) M[i, j] <- max(0, min(ca[i + 1], cb[j + 1]) - max(ca[i], cb[j]))
  stopifnot(max(abs(rowSums(M) - a)) < 1e-10, max(abs(colSums(M) - b)) < 1e-10)
  M
}
ts_rank <- function(d) {
  n <- length(ts_Y)
  out <- lapply(ts_periods, function(p) {
    x <- d[d$period == p, ]; x$from <- ifelse(x$state0 %in% c("N0", "FD"), "NC", as.character(x$state0))
    M <- matrix(0, n, n, dimnames = list(ts_Y, ts_Y))
    for (ii in split(seq_len(nrow(x)), ts_key(x, c("sex", "age_group")))) {
      z <- x[ii, ]; M <- M + ts_coupling(z$from, as.character(z$y1), z$wn) * sum(z$wn)
    }
    real <- tapply(x$wn, list(factor(x$from, ts_Y), factor(x$y1, ts_Y)), sum); real[is.na(real)] <- 0
    ts_check(max(abs(rowSums(M) - rowSums(real))) < 1e-7 && max(abs(colSums(M) - colSums(real))) < 1e-7,
             paste("Rank matching preserves both weighted margins", p))
    do.call(rbind, lapply(c("Observed_panel", "Rank_matching"), function(nm) {
      X <- if (nm == "Observed_panel") real else M
      X <- X / ifelse(rowSums(X) > 0, rowSums(X), NA)
      data.frame(period = p, source = nm, from = rep(ts_Y, each = n), to = rep(ts_Y, n), probability = as.vector(t(X)))
    }))
  })
  do.call(rbind, out)
}
# Earlier-wave history of each pair: the record at the wave before the origin (w-1), compatible by the link rule.
ts_wave_of <- function(period) as.integer(sub("^R([0-9]+)_R[0-9]+$", "\\1", as.character(period)))
ts_months_between <- function(w1, w2) ts_round_months$months[match(w2, ts_round_months$wave)] -
  ts_round_months$months[match(w1, ts_round_months$wave)]
ts_earlier <- function(r, W = ts_W) {
  w <- ts_wave_of(r$period); j <- match(paste(r$id, w - 1L), paste(W$id, W$wave))
  ok <- !is.na(j) & ts_compatible(W$sex[j], r$sex, W$age[j], r$age, ts_months_between(w - 1L, w))
  r$history_available <- ok %in% TRUE & !is.na(W$state[j])
  r$earlier_state <- factor(W$state[j], levels = ts_ST)
  r$earlier_lg <- ifelse(W$current[j] %in% 1 & W$grams[j] > 0, log(W$grams[j]), 0)
  r
}
ts_history_check <- function(risk = ts_risk, W = ts_W, models = c("Gamma", "Gamma_education_interaction")) {
  r <- ts_earlier(risk, W); r <- r[r$history_available, ]
  f <- ts_fold(r$id, 5, ts_seed + 1000); result <- list()
  for (k in 1:5) {
    trids <- r$id[f[r$id] != k]; teids <- r$id[f[r$id] == k]
    nu <- ts_ipw_fit(risk[!risk$id %in% teids, ])
    weighted <- ts_ipw_apply(risk, nu); d <- weighted[weighted$row_id %in% r$row_id, ]
    j <- match(d$row_id, r$row_id); d$earlier_state <- r$earlier_state[j]; d$earlier_lg <- r$earlier_lg[j]
    tr <- d[d$id %in% trids, ]; te <- d[d$id %in% teids, ]
    for (nm in models) {
      p0 <- ts_prob(ts_fit(tr, nm, history = FALSE), te); p1 <- ts_prob(ts_fit(tr, nm, history = TRUE), te)
      result[[length(result) + 1]] <- data.frame(id = te$id, model = nm, w = te$wcorrected,
        diff = ts_loss(p1, te$y1)$logloss - ts_loss(p0, te$y1)$logloss)
    }
  }
  all <- do.call(rbind, result)
  do.call(rbind, lapply(split(all, all$model), function(z) {
    ds <- survey::svydesign(ids = ~id, weights = ~w, data = z)
    v <- survey::svymean(~diff, ds); ci <- stats::confint(v, df = survey::degf(ds))
    data.frame(model = z$model[1], n_pairs = nrow(z), n_persons = length(unique(z$id)),
      difference_history_minus_current = as.numeric(stats::coef(v)), lower = ci[1], upper = ci[2],
      population = "pairs with a compatible earlier wave; person-cluster Taylor; conditional OOF comparison")
  }))
}
ts_ck <- function(d = ts_d, W = ts_W, B = 200, seed = ts_seed + 700L) {
  d <- ts_earlier(d, W); d <- d[d$history_available, ]
  collapse <- function(s) factor(ifelse(s %in% c("N0", "FD"), "NC", ifelse(s %in% c("C1", "C2"), "C1-C2", "C3plus")),
                                 levels = c("NC", "C1-C2", "C3plus"))
  d$a <- collapse(as.character(d$earlier_state)); d$b <- collapse(as.character(d$state0)); d$c <- collapse(d$state1)
  calc <- function(z, w) {
    mat <- function(x, y) { m <- tapply(w, list(x, y), sum); m[is.na(m)] <- 0; m / rowSums(m) }
    zero <- function(m) { m[!is.finite(m)] <- 0; m }   # an unobserved origin row has no mass: it contributes nothing
    p <- mat(z$a, z$c); ab <- mat(z$a, z$b); product <- zero(ab) %*% zero(mat(z$b, z$c))
    product[!is.finite(ab[, 1]), ] <- NA_real_         # the diagnostic is undefined for an unobserved earlier state
    list(p = p, product = product, diff = as.vector(p - product))
  }
  set.seed(seed); ids <- sort(unique(d$id))
  mults <- vapply(seq_len(B), function(b) as.numeric(ts_person_mult(ids)), numeric(length(ids)))
  strata <- c("All", as.character(unique(d$period)))
  do.call(rbind, lapply(strata, function(s) {
    z <- if (s == "All") d else d[d$period == s, ]; point <- calc(z, z$wn)
    rr <- t(vapply(seq_len(B), function(b) calc(z, z$wn * mults[match(z$id, ids), b])$diff, numeric(9)))
    ci <- ts_interval(point$diff, rr, probability = FALSE)
    data.frame(period = s, from = rep(levels(d$a), 3), to = rep(levels(d$a), each = 3), n_pairs = nrow(z),
      observed = as.vector(point$p), chained = as.vector(point$product), difference = point$diff, ci,
      note = "Marginal composition diagnostic, three-wave cohorts; IPW fixed, person bootstrap; no formal conditional Markov test")
  }))
}
ts_hed <- function(d = ts_d) {
  d <- d[d$y1 != "NC" & !is.na(d$signal1), ]; d$y1 <- droplevels(d$y1)
  d$signal0f <- factor(ifelse(d$current0 == 0, "Noncurrent", ifelse(is.na(d$signal0), "Unknown", as.character(d$signal0))))
  ds <- survey::svydesign(ids = ~id, weights = ~wn, data = d)
  fit <- survey::svyglm(signal1 ~ y1 + sex + age_group + signal0f + period, design = ds, family = stats::quasibinomial())
  co <- summary(fit)$coefficients
  tab <- data.frame(term = rownames(co), estimate = co[, 1], se_person_fixed_IPW = co[, 2], row.names = NULL)
  desc <- do.call(rbind, lapply(split(d, ts_key(d, c("y1", "sex"))), function(z)
    data.frame(category = as.character(z$y1[1]), sex = as.character(z$sex[1]), n = nrow(z), signal = stats::weighted.mean(z$signal1, z$wn))))
  list(coef = tab, proportions = desc)
}
ts_crosscheck_eps <- function(d, fits, annual_full, cvtab = NULL, annual_ci = NULL) {
  # External consistency with the EPS aggregates (never validation): annual staying probabilities,
  # EPS generator projected to the TSM intervals and scored on TSM pairs, TSM generator projected to EPS lengths.
  dir <- here::here("__andres_control", "eps_markov_outputs")
  ea <- utils::read.csv(file.path(dir, "annual_pooled_matrices_design_CI.csv"), stringsAsFactors = FALSE)
  et <- utils::read.csv(file.path(dir, "transition_matrices_design_CI.csv"), stringsAsFactors = FALSE)
  eps_years <- c(VI_VII = 3.671, VII_VIII = 4.03); nS <- length(ts_ST)
  models <- intersect(c("A", "Gamma", "Lognormal"), intersect(names(annual_full), unique(ea$model)))
  collapse <- function(pp) { x <- cbind(pp[, 1] + pp[, 2], pp[, 3:nS]); colnames(x) <- ts_Y; x }
  # The EPS v1 engine keeps C3 and C4 apart: merge them into C3plus. Columns are summed; the two rows are averaged with
  # the observed EPS origin pairs as weights (an approximation for an annual matrix; intervals of merged cells are dropped).
  ST6 <- c("N0", "FD", "C1", "C2", "C3", "C4"); m34 <- function(s) ifelse(s %in% c("C3", "C4"), "C3plus", s)
  o <- unique(et[et$model == "A", c("group", "from", "n_origin")]); n34 <- c(sum(o$n_origin[o$from == "C3"]), sum(o$n_origin[o$from == "C4"]))
  eps_P <- function(m) {
    z <- ea[ea$model == m, ]; P <- matrix(NA_real_, 6, 6, dimnames = list(ST6, ST6))
    P[cbind(match(z$from, ST6), match(z$to, ST6))] <- z$estimate
    stopifnot(all(is.finite(P)))
    P[, "C3"] <- P[, "C3"] + P[, "C4"]; P["C3", ] <- (n34[1] * P["C3", ] + n34[2] * P["C4", ]) / sum(n34)
    P <- P[1:5, 1:5]; dimnames(P) <- list(ts_ST, ts_ST); P
  }
  annual <- do.call(rbind, lapply(models, function(m) {
    tsm <- data.frame(source = "TSM", model = m, from = rep(ts_ST, nS), to = rep(ts_ST, each = nS),
      estimate = as.vector(annual_full[[m]]$P), lower = NA_real_, upper = NA_real_)
    if (!is.null(annual_ci)) {
      z <- annual_ci[annual_ci$model == m, ]; j <- match(paste(tsm$from, tsm$to), paste(z$from, z$to))
      tsm$lower <- z$lower[j]; tsm$upper <- z$upper[j]
    }
    z <- ea[ea$model == m, ]; e <- data.frame(source = "EPS", model = m, from = rep(ts_ST, nS), to = rep(ts_ST, each = nS),
      estimate = as.vector(eps_P(m))); j <- match(paste(e$from, e$to), paste(z$from, z$to))
    rbind(tsm, cbind(e, lower = z$lower[j], upper = z$upper[j]))
  }))
  annual$staying <- annual$from == annual$to
  score <- function(loss, w, source, m, extra = NA_real_) {
    one <- function(ii, label) data.frame(source = source, model = m, period = label,
      logloss = stats::weighted.mean(loss$logloss[ii], w[ii]), brier = stats::weighted.mean(loss$brier[ii], w[ii]),
      n = length(ii), recovery_rmse = extra)
    rbind(one(seq_len(nrow(d)), "All"), do.call(rbind, lapply(ts_periods, function(p) one(which(d$period == p), p))))
  }
  mats <- list(); eps_scores <- lapply(models, function(m) {
    P1 <- eps_P(m)
    g <- ts_generator(list(list(P = collapse(P1), n = rep(1, nS), delta = 1)), total = nS)
    per <- lapply(ts_periods, function(p) collapse(ts_expm(g$Q * ts_time$years[match(p, ts_time$period)]))); names(per) <- ts_periods
    mats[[m]] <<- do.call(rbind, lapply(ts_periods, function(p) data.frame(model = m, period = p,
      years = ts_time$years[match(p, ts_time$period)], from = rep(ts_ST, length(ts_Y)), to = rep(ts_Y, each = nS), estimate = as.vector(per[[p]]))))
    P <- matrix(NA_real_, nrow(d), length(ts_Y), dimnames = list(NULL, ts_Y))
    for (p in ts_periods) { ii <- which(d$period == p); P[ii, ] <- per[[p]][as.integer(d$state0[ii]), ] }
    score(ts_loss(P, d$y1), d$wn, "EPS_projection", m, g$rmse)
  })
  own <- lapply(models, function(m) {
    rbind(if (m %in% names(fits)) score(ts_loss(ts_prob(fits[[m]], d), d$y1), d$wn, "TSM_model_insample", m),
          if (!is.null(cvtab) && m %in% names(cvtab$loss)) score(as.data.frame(cvtab$loss[[m]]), cvtab$w, "TSM_model_heldout", m))
  })
  # TSM -> EPS: compare on the five collapsed destinations (NC = N0 + FD), the space the generator is fitted on;
  # the EPS N0 -> FD cell is a structural zero, while a generator distributes within-interval N0 -> C -> FD mass.
  eA <- et[et$model == "A" & is.finite(et$estimate), ]
  eA$period <- as.character(eA$period); den <- unique(eA[c("period", "group", "from", "n_origin")]); den$from <- m34(den$from)
  eA$from <- m34(eA$from); eA$to <- ifelse(eA$to %in% c("N0", "FD"), "NC", m34(eA$to))
  num <- stats::aggregate(cbind(weighted = estimate * n_origin) ~ period + from + to, eA, sum)
  den <- stats::aggregate(n_origin ~ period + from, den, sum)
  pooled <- merge(num, den, by = c("period", "from")); pooled$estimate <- pooled$weighted / pooled$n_origin
  observed_origins <- names(which(table(factor(as.character(d$state0), levels = ts_ST)) > 0))
  cells <- do.call(rbind, lapply(models, function(m) do.call(rbind, lapply(names(eps_years), function(ep) {
    pp <- collapse(ts_expm(annual_full[[m]]$Q * eps_years[[ep]])); rownames(pp) <- ts_ST
    z <- pooled[pooled$period == ep & pooled$from %in% observed_origins, ]
    data.frame(model = m, eps_period = ep, years = eps_years[[ep]], from = z$from, to = z$to, n_origin = z$n_origin,
      eps_observed = z$estimate, tsm_projected = pp[cbind(match(z$from, ts_ST), match(z$to, ts_Y))])
  }))))
  cells$difference <- cells$tsm_projected - cells$eps_observed
  cells$comparable <- cells$from != "FD"   # TSM FD drank months earlier; EPS FD abstained for years: different constructs
  summarise <- function(cc, label) do.call(rbind, lapply(split(cc, paste(cc$model, cc$eps_period)), function(z)
    data.frame(model = z$model[1], eps_period = z$eps_period[1], years = z$years[1], cells_included = label, cells = nrow(z),
      weighted_RMSE = sqrt(sum(z$n_origin * z$difference^2) / sum(z$n_origin)), max_absolute_difference = max(abs(z$difference)))))
  summary <- rbind(summarise(cells, "supported origins"), summarise(cells[cells$comparable, ], "excluding FD origin"))
  rownames(summary) <- NULL
  list(annual = annual, projection_eps_to_tsm = rbind(do.call(rbind, eps_scores), do.call(rbind, own)),
       projection_eps_matrices = do.call(rbind, mats), projection_tsm_to_eps = cells, projection_tsm_to_eps_summary = summary)
}
ts_point_sensitivity <- function(risks, models, label, k = NULL) {
  # CV-free pooled point estimates for already-built risk sets (education rules, upper band); IPW refitted.
  if (is.null(k)) k <- if (exists("ts_k")) ts_k[[1]] else 100
  out <- lapply(names(risks), function(nm) {
    r <- risks[[nm]]
    # Each variant keeps its own period masses (its complete pairs), as ts_variant_cv does in the notebook.
    old_mass <- ts_period_mass
    ts_period_mass <<- stats::setNames(vapply(ts_periods, function(p) sum(r$period == p & r$complete), 1), ts_periods)
    on.exit(ts_period_mass <<- old_mass, add = TRUE)
    d <- ts_ipw_apply(r, ts_ipw_fit(r)); dd <- d; dd$pooled <- "All"
    res <- lapply(models, function(m) {
      pr <- ts_prob(ts_fit(d, m, k), d); q <- ts_quantities(pr, d)
      s <- data.frame(nm, model = m, quantity = names(q), probability = unname(q)); names(s)[1] <- label
      p <- cbind(stats::setNames(data.frame(nm), label), ts_matrices(dd, pr, m, by = "pooled"))
      list(summary = s, pooled = p)
    })
    list(summary = do.call(rbind, lapply(res, `[[`, "summary")), pooled = do.call(rbind, lapply(res, `[[`, "pooled")))
  })
  list(summary = do.call(rbind, lapply(out, `[[`, "summary")), pooled = do.call(rbind, lapply(out, `[[`, "pooled")))
}
# Both return list(summary, pooled); with no risk sets given they build them through the data layer (ts_waves, ts_make_risk).
ts_education_sensitivity <- function(risks = NULL, models = c("A", "Lognormal")) {
  if (is.null(risks)) risks <- list(lenient = ts_risk, strict = ts_make_risk(ts_waves(education_rule = "strict")),
                                    reached = ts_make_risk(ts_waves(education_rule = "reached")))
  ts_point_sensitivity(risks, models, "rule")
}
ts_upper_band_sensitivity <- function(risk16 = NULL, models = c("A", "Gamma", "Lognormal")) {
  if (is.null(risk16)) risk16 <- ts_make_risk(ts_waves(top_quantity = 16))
  ts_point_sensitivity(list(top_16_drinks = risk16), models, "scenario")
}
ts_diagram <- function(labels, edges, title, name, cols = 3) {
  n <- length(labels); dat <- data.frame(id = seq_len(n), x = (seq_len(n) - 1) %% cols, y = -((seq_len(n) - 1) %/% cols), label = labels)
  if (name == "fig_flowchart") {
    dat$label <- labels[c(1, 4, 2, 3, 5, 6, 7, 8, 9)]
    dat$x[4:6] <- 2:0
    edges <- cbind(seq_len(n - 1), 2:n)
  }
  ed <- data.frame(x = dat$x[edges[, 1]], y = dat$y[edges[, 1]], xend = dat$x[edges[, 2]], yend = dat$y[edges[, 2]])
  dx <- ed$xend - ed$x; dy <- ed$yend - ed$y
  ed$x <- ed$x + .43 * sign(dx); ed$xend <- ed$xend - .43 * sign(dx)
  ed$y <- ed$y + .2 * sign(dy); ed$yend <- ed$yend - .2 * sign(dy)
  p <- ggplot2::ggplot() + ggplot2::geom_segment(data = ed, ggplot2::aes(x = x, y = y, xend = xend, yend = yend),
    arrow = grid::arrow(length = grid::unit(.15, "inches")), color = ts_palette["grey"], linewidth = .7) +
    ggplot2::geom_rect(data = dat, ggplot2::aes(xmin = x - .43, xmax = x + .43, ymin = y - .2, ymax = y + .2), fill = ts_palette["pale"], color = ts_palette["blue"], linewidth = .5) +
    ggplot2::geom_text(data = dat, ggplot2::aes(x, y, label = label), color = ts_palette["blue"], size = 3.5) + ggplot2::theme_void() +
    ggplot2::labs(title = title) + ggplot2::theme(plot.title = ggplot2::element_text(face = "bold", size = 14, hjust = .5),
      plot.margin = grid::unit(rep(1, 4), "cm")) + ggplot2::coord_cartesian(xlim = c(-.55, cols - .45), ylim = c(min(dat$y) - .45, .45), clip = "off")
  ts_fig(p, name, 12, max(4, 2 * ceiling(n / cols)))
}
ts_intervals_figure <- function() {
  rm <- ts_round_months[order(ts_round_months$wave), ]
  rounds <- data.frame(x = rm$months, label = paste0("R", rm$wave, "\n", rm$year_month))
  tm <- ts_time[match(ts_periods, ts_time$period), ]
  x0 <- rm$months[match(ts_wave_of(tm$period), rm$wave)]
  segs <- data.frame(x = x0, xend = x0 + tm$months, label = paste0(tm$period, "\n", tm$months, " months"))
  p <- ggplot2::ggplot() +
    ggplot2::geom_segment(data = segs, ggplot2::aes(x = x + .3, xend = xend - .3, y = 0, yend = 0),
      arrow = grid::arrow(length = grid::unit(.15, "inches")), color = ts_palette["grey"], linewidth = .7) +
    ggplot2::geom_point(data = rounds, ggplot2::aes(x, 0), size = 6, color = ts_palette["blue"]) +
    ggplot2::geom_text(data = rounds, ggplot2::aes(x, -.25, label = label), color = ts_palette["blue"], size = 3.5) +
    ggplot2::geom_text(data = segs, ggplot2::aes((x + xend) / 2, .25, label = label), color = ts_palette["rust"], size = 3.5) +
    ggplot2::theme_void() + ggplot2::coord_cartesian(ylim = c(-.5, .5), clip = "off") +
    ggplot2::labs(title = "Five TSM rounds, four adjacent intervals; pairs are the same person in consecutive rounds") +
    ggplot2::theme(plot.title = ggplot2::element_text(face = "bold", size = 14, hjust = .5), plot.margin = grid::unit(rep(1, 4), "cm"))
  ts_fig(p, "fig_intervals_pairs", 12, 4)
}
ts_diagrams <- function() {
  ts_diagram(c("TSM rounds R7-R11\nRespondents, Fact_Exp", "Same person\nAdjacent rounds, 4-8 months", "Fact_Exp + link IPW\nPeriod mass fixed",
    "Observed origin states\nN0 / FD / C1, C2, C3plus", "Person-blocked validation\nIPW fit inside training", "Pooled models\nCategory probabilities",
    "Whole-person bootstrap\nOne multiplier per person", "Annual generator\nFour interval lengths", "EPS cross-check\nConsistency, not validation"),
    matrix(c(1, 2, 2, 3, 3, 6, 6, 5, 5, 4, 4, 7, 7, 8, 8, 9), byrow = TRUE, ncol = 2),
    "From survey responses to transition probabilities", "fig_flowchart")
  ts_intervals_figure()
  ts_diagram(c("At t: N0 / FD / C1, C2, C3plus\nSex, age, education, prior grams", "Participation model\nP(drinking at t+1)",
    "Amount if drinking\nGamma / lognormal / ordinal", "Non-drinking\nN0 or FD from past history", "Integrate category cutpoints\nP(C1), P(C2), P(C3plus)", "Next-round distribution\nNot just the predicted mean"),
    matrix(c(1, 2, 2, 3, 2, 4, 3, 5, 4, 6, 5, 6), ncol = 2, byrow = TRUE), "Two-part models", "fig_two_part")
}
ts_plots <- function() {
  pal <- function(n) if (n <= 4) unname(ts_palette[c("blue", "rust", "olive", "grey")])[seq_len(n)] else
    grDevices::colorRampPalette(unname(ts_palette[c("blue", "heat", "olive", "rust", "grey")]))(n)
  heat <- function(z, fill, title, subtitle, facets, name, h = 7) {
    z$from <- factor(z$from, levels = rev(unique(as.character(z$from)))); z$to <- factor(z$to, levels = unique(as.character(z$to)))
    z$value <- z[[fill]]
    p <- ggplot2::ggplot(z, ggplot2::aes(to, from, fill = value)) + ggplot2::geom_tile(color = "white") +
      ggplot2::geom_text(ggplot2::aes(label = ifelse(is.na(value), "NA", sprintf("%.1f", 100 * value))), size = 3.2) +
      ggplot2::facet_grid(facets) + ggplot2::scale_fill_gradient(low = ts_palette["light"], high = ts_palette["heat"], limits = c(0, 1), na.value = "grey85") +
      ggplot2::labs(title = title, subtitle = subtitle, x = "Destination", y = "Origin", fill = "Probability") + ts_theme()
    ts_fig(p, name, 12, h)
  }
  heat(ts_rank_tab, "probability", "Real panel and rank matching (%)",
    "Same people, weights, baseline age groups and endpoint margins", period ~ source, "fig_rank_matching", 12)
  heat(ts_pool_tab, "estimate", "Pooled next-round probabilities (%)",
    "Observed-origin standardisation; actual prior quantity and education", . ~ model, "fig_pooled_matrices", 5)
  s <- ts_counts
  p <- ggplot2::ggplot(s, ggplot2::aes(age_group, state0, fill = pmin(n, 200))) + ggplot2::geom_tile(color = "white") +
    ggplot2::geom_text(ggplot2::aes(label = n), size = 3) + ggplot2::facet_grid(period ~ sex) +
    ggplot2::scale_fill_gradient(low = ts_palette["light"], high = ts_palette["heat"], name = "n (max 200)") + ts_theme() +
    ggplot2::labs(title = "How much information supports each origin?",
      subtitle = "Unweighted observed pairs; zero does not imply a zero transition probability", x = "Age at origin", y = "Origin state")
  ts_fig(p, "fig_sparsity", 10, 10)
  q <- ts_contrasts
  q$comparison <- paste(q$model, "-", q$reference)
  p <- ggplot2::ggplot(q, ggplot2::aes(difference, stats::reorder(comparison, -difference))) + ggplot2::geom_vline(xintercept = 0, linetype = 2, color = ts_palette["grey"]) +
    ggplot2::geom_pointrange(ggplot2::aes(xmin = lower, xmax = upper), color = ts_palette["blue"]) + ts_theme() +
    ggplot2::labs(title = "Do small score differences distinguish models?",
      subtitle = "95% intervals cluster on persons; conditional on held-out predictions",
      x = "Difference in log loss (negative favours the first model)", y = NULL)
  ts_fig(p, "fig_cv_logloss", 12, 9)
  p <- ggplot2::ggplot(ts_cal, ggplot2::aes(predicted, observed, color = model)) + ggplot2::geom_abline(linetype = 2) +
    ggplot2::geom_point(size = 2.5) + ggplot2::facet_wrap(~category, scales = "free") +
    ggplot2::scale_color_manual(values = pal(length(unique(ts_cal$model)))) + ts_theme() +
    ggplot2::labs(title = "Held-out calibration by category", x = "Predicted share", y = "Observed weighted share")
  ts_fig(p, "fig_calibration", 12, 6)
  cc <- ts_cal_cells
  p <- ggplot2::ggplot(cc, ggplot2::aes(predicted, observed, color = state0, shape = sparse)) + ggplot2::geom_abline(linetype = 2) +
    ggplot2::geom_point(size = 2, alpha = .8) + ggplot2::facet_wrap(~model) +
    ggplot2::scale_color_manual(values = pal(length(unique(cc$state0)))) + ggplot2::scale_shape_manual(values = c(`FALSE` = 16, `TRUE` = 1)) + ts_theme() +
    ggplot2::labs(title = "Held-out calibration by origin cell (origin x sex x age group x destination)",
      subtitle = "Open symbols: fewer than 30 origin pairs in the cell", x = "Predicted mean probability", y = "Observed weighted share")
  ts_fig(p, "fig_calibration_by_origin", 12, 8)
  b <- ts_ci[ts_ci$model %in% c("Gamma", "Lognormal") & ts_ci$from %in% c("N0", "FD", "C1") & ts_ci$to == "C1", ]
  p <- ggplot2::ggplot(b, ggplot2::aes(age_group, estimate, color = model)) +
    ggplot2::geom_pointrange(ggplot2::aes(ymin = lower, ymax = upper), position = ggplot2::position_dodge(.4), na.rm = TRUE) +
    ggplot2::facet_grid(from ~ period + sex) + ggplot2::scale_color_manual(values = pal(2)) + ts_theme() +
    ggplot2::labs(title = "Uncertainty from the whole-person bootstrap",
      subtitle = "IPW and outcome models refitted in every replicate; no interval for unsupported rows",
      x = "Age at origin", y = "P(C1)")
  ts_fig(p, "fig_person_intervals", 16, 8)
  a <- ts_cross$annual[ts_cross$annual$staying, ]; a$from <- factor(a$from, levels = ts_ST)
  p <- ggplot2::ggplot(a, ggplot2::aes(from, estimate, color = source)) +
    ggplot2::geom_pointrange(ggplot2::aes(ymin = lower, ymax = upper), position = ggplot2::position_dodge(.5), na.rm = TRUE) +
    ggplot2::facet_wrap(~model) + ggplot2::scale_color_manual(values = pal(2)) + ts_theme() +
    ggplot2::labs(title = "Annual staying probabilities: TSM versus EPS (model-derived scenarios)",
      subtitle = "TSM: person bootstrap; EPS: design JKn. External consistency, not validation", x = "State", y = "P(stay one year)")
  ts_fig(p, "fig_annual_tsm_vs_eps", 11, 5)
  p <- ggplot2::ggplot(ts_sensitivity, ggplot2::aes(grams_per_drink, probability, color = model)) + ggplot2::geom_line() + ggplot2::geom_point(size = 2) +
    ggplot2::facet_wrap(~quantity, scales = "free_y") + ggplot2::scale_color_manual(values = pal(length(unique(ts_sensitivity$model)))) + ts_theme() +
    ggplot2::labs(title = "12 versus 15.7 grams per drink", x = "Grams per drink", y = "Probability")
  ts_fig(p, "fig_conversion_sensitivity", 11, 5)
}
cat(sprintf("Elapsed: %.2f minutes\n", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
