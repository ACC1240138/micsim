.t0 <- Sys.time()
# Standalone helpers for the authorized TSM pooled analysis. No microdata exports.
tp_states <- c("ND_unknown", "FD", "cat1", "cat2", "cat3", "cat4")
tp_labels <- c(ND_unknown = "No consumo; historia desconocida", FD = "FD observado",
               cat1 = "cat1", cat2 = "cat2", cat3 = "cat3", cat4 = "cat4")
tp_age_labels <- c("18-29", "30-44", "45-59", "60-65")
tp_status_levels <- c("ND_unknown", "FD", "Current")
tp_valid <- function(x, codes) ifelse(x %in% codes, as.numeric(x), NA_real_)

tp_history <- function(d) {
  d <- d[order(d$id, d$wave), , drop = FALSE]
  d$n_prior <- ave(d$wave, d$id, FUN = function(x) seq_along(x) - 1L)
  d$ever_before <- ave(as.integer(d$drinker), d$id,
    FUN = function(x) c(0, head(cummax(x), -1L))) > 0
  d$ever_known <- d$ever_before | d$drinker
  d$first_wave <- ave(d$wave, d$id, FUN = min)
  d$fd <- !d$drinker & d$ever_before
  d$status <- ifelse(d$drinker, "Current", ifelse(d$fd, "FD", "ND_unknown"))
  rownames(d) <- NULL
  d
}

tp_load <- function(root = ".") {
  paths <- file.path(root, paste0("TSM Ronda ", 7:11, ".sav"))
  expected <- c("2cd97e506625b0af12767e2bd6763c37", "7fcf74c1deb83ec53fe1ebdb27b09173",
    "8139effe4619401a8a82879eb76cc07e", "2e27dc6dfa3e889ee947fbe6dc80b100",
    "dbe0d638df8f36b0a06731fea09eedea")
  stopifnot(identical(unname(tools::md5sum(paths)), expected))
  raw <- stats::setNames(lapply(paths, haven::read_sav), 7:11)
  people <- lapply(raw, function(x) as.data.frame(x[x$Entrevistado %in% 1, ]))
  rows <- lapply(seq_along(people), function(k) {
    p <- people[[k]]
    stopifnot(!anyNA(p$IdPanel), !anyDuplicated(p$IdPanel),
      all(p$e3a1 %in% 1:5), all(p$a2 %in% 1:2), !anyNA(p$a3),
      all(p$e3a2[p$e3a1 > 1] %in% 1:5), all(p$e3a3[p$e3a1 > 1] %in% 1:5),
      all(is.finite(p$Fact_Exp)), all(p$Fact_Exp > 0))
    freq <- as.numeric(p$e3a1); qty <- tp_valid(p$e3a2, 1:5)
    hed <- tp_valid(p$e3a3, 1:5); drinker <- freq > 1
    ed <- ifelse(p$b4a %in% 1:4, "Basic", ifelse(p$b4a %in% 5:6, "Secondary",
      ifelse(p$b4a %in% 7:9, "Higher", "Unknown")))
    employment <- ifelse(p$c1 %in% 1 | p$c2 %in% 1 | p$c3 %in% 1:9, "Yes",
      ifelse(p$c3 %in% 10, "No", "Unknown"))
    region <- ifelse(p$IdRegion == 13, "RM", ifelse(p$IdRegion %in% c(1:4, 15), "North",
      ifelse(p$IdRegion %in% 5:7, "Centre", "South")))
    phq2 <- tp_valid(p$f15a, 1:4) + tp_valid(p$f15b, 1:4) - 2
    stopifnot(!anyNA(phq2), all(phq2 >= 0 & phq2 <= 6))
    data.frame(id = as.character(p$IdPanel), wave = k + 6L, q = as.numeric(p$Fact_Exp),
      age = as.numeric(p$a3), sex = ifelse(p$a2 == 1, "Male", "Female"),
      education = ed, partnered = ifelse(p$a6 %in% 1:2, "Yes",
        ifelse(p$a6 %in% 3:7, "No", "Unknown")), region = region,
      employment = employment, housing = ifelse(p$f1 %in% 2, "Owner",
        ifelse(p$f1 %in% c(1, 3, 4), "Other", "Unknown")),
      phq2 = phq2, freq = freq, qty = qty, hed = hed, drinker = drinker,
      hed_monthly = as.integer(drinker & hed %in% 3:5),
      skip_conflict = !drinker & (!is.na(qty) | !is.na(hed)))
  })
  d <- tp_history(do.call(rbind, rows))
  d$age_group <- as.character(cut(d$age, c(18, 30, 45, 60, 66),
    right = FALSE, labels = tp_age_labels))
  vars <- c("IdPanel", "IdEncuesta", "IdPersona", "Entrevistado", "Fact_Exp", "IdRegion",
    "a2", "a3", "a4", "a6", "a7", "a8", "a9", "a9a", "a10", "a12", "a12b",
    "b1", "b4a", "b4b", "b5", "c1", "c2", "c3", "c10", "c11", "d1", "d1m",
    "d5", "d5m", "f1", paste0("f15", letters[1:9]), "e3a1", "e3a2", "e3a3", "e3b")
  dictionary <- do.call(rbind, lapply(names(raw), function(w) {
    x <- raw[[w]]
    do.call(rbind, lapply(intersect(vars, names(x)), function(v) {
      lab <- attr(x[[v]], "label"); val <- attr(x[[v]], "labels")
      data.frame(wave = as.integer(w), variable = v,
        label = if (is.null(lab)) "" else lab,
        codes = if (length(val)) paste(paste0(unname(val), "=", names(val)), collapse = "; ")
          else "Numeric or text; no value labels")
    }))
  }))
  list(data = d, dictionary = dictionary,
    hashes = data.frame(wave = 7:11, file = basename(paths), md5 = expected),
    roster = vapply(raw, nrow, integer(1)))
}

tp_volume <- function(d, top_quantity = 10, top_frequency = 5.5) {
  # Midpoints for bounded bins; lower bound for the open quantity bin.
  frequency_day <- c(0, 0.5 / (365.25 / 12), 3 / (365.25 / 12),
    2.5 / 7, top_frequency / 7)[d$freq]
  quantity <- c(1, 3.5, 5.5, 8, top_quantity)[d$qty]
  d$drinks_day <- ifelse(d$drinker, frequency_day * quantity, 0)
  stopifnot(!anyNA(d$drinks_day), all(d$drinks_day[d$drinker] > 0))
  d
}

tp_category <- function(drinks_day, sex, status, grams = 12, split_fd = TRUE) {
  g <- drinks_day * grams
  low <- ifelse(sex == "Female", 20, 40)
  high <- ifelse(sex == "Female", 40, 60)
  z <- ifelse(g > 100, "cat4", ifelse(g >= high, "cat3",
    ifelse(g >= low, "cat2", "cat1")))
  z[status != "Current" & !is.na(status)] <- if (split_fd) status[status != "Current" & !is.na(status)] else "ND"
  z[is.na(drinks_day) | is.na(status)] <- NA_character_
  z
}

tp_pairs <- function(d, lag = 1L, first_origin = 8L) {
  result <- lapply(first_origin:(11L - lag), function(w) {
    a <- d[d$wave == w & d$age >= 18 & d$age <= 65, , drop = FALSE]
    b <- d[d$wave == w + lag, , drop = FALSE]
    j <- match(a$id, b$id)
    a$wave_to <- w + lag; a$lag <- lag; a$interval <- paste0("R", w, "-R", w + lag)
    a$R <- as.integer(!is.na(j))
    for (v in c("status", "drinks_day", "drinker", "age", "sex", "ever_before", "skip_conflict"))
      a[[paste0(v, "_to")]] <- b[[v]][j]
    a$demographic_flag <- a$R == 1 & (a$sex != a$sex_to | a$age_to < a$age | a$age_to - a$age > lag)
    a$pair_id <- paste(a$id, a$wave, a$wave_to, sep = "_")
    stopifnot(!anyDuplicated(a$id), all(!is.na(a$status_to[a$R == 1])))
    a
  })
  do.call(rbind, result)
}

tp_design <- function(d, response = TRUE) {
  f <- data.frame(wave = factor(d$wave, levels = 7:10),
    status = factor(d$status, levels = tp_status_levels),
    age_z = (d$age - 40) / 15, sex = factor(d$sex, levels = c("Male", "Female")),
    education = factor(d$education, levels = c("Basic", "Secondary", "Higher", "Unknown")),
    log_quantity = log1p(d$drinks_day), hed_monthly = d$hed_monthly,
    log_history = log1p(d$n_prior), phq2 = d$phq2,
    frequency = factor(d$freq, levels = 1:5), quantity = ifelse(d$drinker, c(1, 3.5, 5.5, 8, 10)[d$qty], 0),
    region = factor(d$region, levels = c("RM", "North", "Centre", "South")),
    employment = factor(d$employment, levels = c("No", "Yes", "Unknown")),
    partnered_verified = as.integer(d$partnered == "Yes"),
    owner_verified = as.integer(d$housing == "Owner"),
    after_R7 = as.integer(d$first_wave > 7))
  form <- if (response)
    ~ wave + status + age_z + I(age_z^2) + sex + education + log_quantity +
      frequency + quantity + hed_monthly + log_history + phq2 +
      region + employment + partnered_verified + owner_verified + after_R7 else
    ~ wave + status + age_z + I(age_z^2) + sex + education + log_quantity +
      hed_monthly + log_history
  X <- stats::model.matrix(form, f)
  stopifnot(nrow(X) == nrow(d), !anyNA(X), all(is.finite(X)))
  X
}

tp_glm <- function(X, y, w, family) {
  ok <- is.finite(y) & is.finite(w) & w > 0
  qrx <- qr(X[ok, , drop = FALSE] * sqrt(w[ok]))
  keep <- sort(qrx$pivot[seq_len(qrx$rank)])
  z <- stats::glm.fit(X[ok, keep, drop = FALSE], y[ok],
    weights = w[ok] / mean(w[ok]), family = family,
    control = stats::glm.control(maxit = 100, epsilon = 1e-8))
  stopifnot(z$converged, all(is.finite(z$coefficients)))
  list(coefficients = z$coefficients, keep = keep, columns = colnames(X)[keep],
    fit = z, dropped = setdiff(colnames(X), colnames(X)[keep]))
}

tp_fit_response <- function(d, multiplicity = rep(1, nrow(d))) {
  X0 <- tp_design(d, TRUE)
  mq <- d$q / mean(d$q[multiplicity > 0])
  fit <- tp_glm(X0, d$R, mq * multiplicity, stats::quasibinomial())
  X <- X0[, fit$columns, drop = FALSE]
  pi <- stats::plogis(as.numeric(X %*% fit$coefficients))
  stopifnot(all(is.finite(pi)), all(pi > 0 & pi < 1))
  list(pi = pi, weights = d$q * d$R / pi, X = X, mq = mq,
       coefficients = fit$coefficients, columns = fit$columns, dropped = fit$dropped)
}

tp_predict_response <- function(fit, d) {
  stats::plogis(as.numeric(tp_design(d, TRUE)[, fit$columns, drop = FALSE] %*% fit$coefficients))
}

tp_structural <- function(from, to, lag = 1L) {
  (from != "ND_unknown" & to == "ND_unknown") |
    (lag == 1L & from == "ND_unknown" & to == "FD")
}

tp_empirical <- function(d, grams, response = NULL, unit = "person", split_fd = TRUE,
                         custom_weights = NULL) {
  lev <- if (split_fd) tp_states else c("ND", "cat1", "cat2", "cat3", "cat4")
  s0 <- tp_category(d$drinks_day, d$sex, d$status, grams, split_fd)
  # Origin sex defines both thresholds; discordant records are flagged separately.
  s1 <- tp_category(d$drinks_day_to, d$sex, d$status_to, grams, split_fd)
  w <- if (!is.null(custom_weights)) custom_weights else
    if (is.null(response)) d$q * d$R else response$weights
  joint <- !is.null(response) && is.null(custom_weights)
  cluster <- if (unit == "person") d$id else d$pair_id
  G <- length(unique(cluster))
  if (joint) {
    X <- response$X; pi <- response$pi
    scores <- X * as.numeric(response$mq * (d$R - pi))
    A <- crossprod(X, X * as.numeric(response$mq * pi * (1 - pi)))
    Ainv <- solve(A)
  }
  grid <- expand.grid(from = lev, to = lev, stringsAsFactors = FALSE)
  out <- lapply(seq_len(nrow(grid)), function(j) {
    a <- grid$from[j]; b <- grid$to[j]
    ia <- as.numeric(s0 == a); yy <- as.numeric(!is.na(s1) & s1 == b)
    den <- sum(w * ia); ev <- d$R == 1 & ia == 1 & yy == 1
    nn <- sum(d$R * ia); ne <- sum(ev)
    ids <- length(unique(d$id[d$R == 1 & ia == 1]))
    ev_ids <- length(unique(d$id[ev]))
    co_ids <- length(unique(d$id[d$R == 1 & ia == 1 & yy == 0]))
    structural <- split_fd && tp_structural(a, b, unique(d$lag)[1])
    p <- if (den > 0) sum(w * ia * yy) / den else NA_real_
    se <- lo <- hi <- NA_real_
    if (is.finite(p) && p > 0 && p < 1) {
      score <- w * ia * (yy - p)
      infl <- score
      if (joint) {
        C <- crossprod(X, score * (1 - pi))
        infl <- score - as.numeric(scores %*% (Ainv %*% C))
      }
      cl <- rowsum(matrix(infl / den, ncol = 1), cluster, reorder = FALSE)
      se <- sqrt(sum(cl^2) * G / (G - 1))
      ci <- stats::plogis(stats::qlogis(p) + c(-1, 1) * stats::qnorm(.975) * se / (p * (1 - p)))
      lo <- ci[1]; hi <- ci[2]
    }
    support <- if (sum(ia) == 0) "No origins" else if (den == 0) "No observed follow-up" else
      if (structural) "Structural zero" else if (p %in% c(0, 1)) "Sample boundary; CI unavailable" else
      if (ids < 30 || ev_ids < 10 || co_ids < 10) "Sparse; exploratory CI" else "Working CI"
    data.frame(grams = grams, from = a, to = b, p = p, se = se, lower = lo, upper = hi,
      origin_n = sum(ia), observed_pairs = nn, observed_ids = ids, events = ne, event_ids = ev_ids,
      complement_ids = co_ids, ESS_weights = if (den > 0) den^2 / sum((w * ia)^2) else NA_real_,
      denominator = den, structural = structural, support = support, unit = unit,
      method = if (is.null(response)) "Fact_Exp" else "Fact_Exp x IPW")
  })
  ans <- do.call(rbind, out)
  stopifnot(all(!ans$structural | is.na(ans$p) | ans$p == 0))
  for (a in lev) if (any(is.finite(ans$p[ans$from == a])))
    stopifnot(abs(sum(ans$p[ans$from == a]) - 1) < 1e-9)
  ans
}

tp_gamma <- function(X, y, w) {
  z <- suppressWarnings(tryCatch(tp_glm(X, y, w, stats::Gamma("log")),
    error = function(e) NULL))
  if (!is.null(z)) { z$solver <- "IRLS"; return(z) }
  # The fallback minimizes the same convex Gamma log-mean objective.
  ok <- is.finite(y) & y > 0 & is.finite(w) & w > 0
  qrx <- qr(X[ok, , drop = FALSE] * sqrt(w[ok]))
  keep <- sort(qrx$pivot[seq_len(qrx$rank)])
  xx <- X[ok, keep, drop = FALSE]; ww <- w[ok] / sum(w[ok])
  ly <- log(y[ok])
  initial <- stats::lm.wfit(xx, ly, ww)$coefficients
  objective <- function(beta) {
    eta <- as.numeric(xx %*% beta)
    sum(ww * (eta + exp(ly - eta)))
  }
  gradient <- function(beta) {
    eta <- as.numeric(xx %*% beta)
    as.numeric(crossprod(xx, ww * (1 - exp(ly - eta))))
  }
  opt <- stats::optim(initial, objective, gradient, method = "BFGS",
    control = list(maxit = 2000, reltol = 1e-12))
  stopifnot(opt$convergence == 0, max(abs(gradient(opt$par))) < 1e-5)
  list(coefficients = opt$par, keep = keep, columns = colnames(X)[keep],
    fit = NULL, dropped = setdiff(colnames(X), colnames(X)[keep]), solver = "BFGS fallback")
}

tp_fit_hurdle <- function(d, response, multiplicity = rep(1, nrow(d))) {
  X <- tp_design(d, FALSE)
  w <- response$weights * multiplicity
  drink <- as.numeric(d$drinker_to)
  binary <- tp_glm(X, drink, w, stats::quasibinomial())
  positive <- d$R == 1 & d$drinker_to %in% TRUE & multiplicity > 0
  y <- d$drinks_day_to
  gamma <- tp_gamma(X[positive, , drop = FALSE], y[positive], w[positive])
  mu <- exp(as.numeric(X[positive, gamma$columns, drop = FALSE] %*% gamma$coefficients))
  wp <- w[positive] / sum(w[positive])
  shape <- exp(stats::optimize(function(logshape) {
    -sum(wp * stats::dgamma(y[positive], shape = exp(logshape), scale = mu / exp(logshape), log = TRUE))
  }, interval = c(-5, 8))$minimum)
  lognormal <- tp_glm(X[positive, , drop = FALSE], log(y[positive]), w[positive], stats::gaussian())
  eta <- as.numeric(X[positive, lognormal$columns, drop = FALSE] %*% lognormal$coefficients)
  sigma <- sqrt(sum(wp * (log(y[positive]) - eta)^2))
  stopifnot(is.finite(shape), shape > 0, is.finite(sigma), sigma > 0)
  list(binary = binary, gamma = gamma, shape = shape, lognormal = lognormal, sigma = sigma,
       n_positive = sum(positive))
}

tp_predict_hurdle <- function(fit, d, family = "Gamma", grams = 12) {
  X <- tp_design(d, FALSE)
  pr <- stats::plogis(as.numeric(X[, fit$binary$columns, drop = FALSE] %*% fit$binary$coefficients))
  if (family == "Gamma") {
    mu <- exp(as.numeric(X[, fit$gamma$columns, drop = FALSE] %*% fit$gamma$coefficients))
    eta <- log(mu)
    cdf <- function(g) stats::pgamma(g / grams, shape = fit$shape, scale = mu / fit$shape)
    density <- function(g) stats::dgamma(g, shape = fit$shape, scale = grams * mu / fit$shape, log = TRUE)
  } else {
    eta <- as.numeric(X[, fit$lognormal$columns, drop = FALSE] %*% fit$lognormal$coefficients)
    mu <- exp(eta + fit$sigma^2 / 2)
    cdf <- function(g) stats::plnorm(g / grams, meanlog = eta, sdlog = fit$sigma)
    density <- function(g) stats::dlnorm(g, meanlog = eta + log(grams), sdlog = fit$sigma, log = TRUE)
  }
  low <- ifelse(d$sex == "Female", 20, 40); high <- ifelse(d$sex == "Female", 40, 60)
  c1 <- cdf(low); c2 <- cdf(high); c3 <- cdf(100)
  prob <- cbind((1 - pr) * !d$ever_known, (1 - pr) * d$ever_known,
    pr * c1, pr * (c2 - c1), pr * (c3 - c2), pr * (1 - c3))
  colnames(prob) <- tp_states
  stopifnot(all(is.finite(prob)), min(prob) > -1e-10, max(abs(rowSums(prob) - 1)) < 1e-9)
  prob <- pmax(prob, 0); prob <- prob / rowSums(prob)
  logdens <- rep(NA_real_, nrow(d))
  if ("drinks_day_to" %in% names(d)) {
    yy <- d$drinks_day_to * grams; pos <- !is.na(yy) & yy > 0
    logdens[!is.na(yy) & yy == 0] <- log1p(-pr[!is.na(yy) & yy == 0])
    ld <- density(ifelse(pos, yy, 1))
    logdens[pos] <- log(pr[pos]) + ld[pos]
  }
  list(prob = prob, drink = pr, positive_mean = mu * grams,
       mean = pr * mu * grams, logdensity = logdens)
}

tp_model_estimands <- function(fit, d, grams, family, multiplicity = rep(1, nrow(d))) {
  pred <- tp_predict_hurdle(fit, d, family, grams)
  s0 <- tp_category(d$drinks_day, d$sex, d$status, grams)
  out <- list()
  for (a in tp_states) {
    ia <- s0 == a; w <- d$q * multiplicity * ia; den <- sum(w)
    for (b in tp_states) out[[length(out) + 1L]] <- data.frame(
      grams = grams, family = family, measure = "transition", from = a, to = b,
      estimate = if (den > 0) sum(w * pred$prob[, b]) / den else NA_real_,
      origin_n = sum(ia), origin_ids = length(unique(d$id[ia])),
      structural = tp_structural(a, b, 1L))
  }
  for (a in tp_status_levels) {
    ia <- d$status == a; w <- d$q * multiplicity * ia; den <- sum(w)
    for (measure in c("participation", "mean_gpd")) {
      target <- if (measure == "participation") pred$drink else pred$mean
      out[[length(out) + 1L]] <- data.frame(grams = grams, family = family,
        measure = measure, from = a, to = if (measure == "participation") "Drink" else "Mean",
        estimate = if (den > 0) sum(w * target) / den else NA_real_,
        origin_n = sum(ia), origin_ids = length(unique(d$id[ia])), structural = FALSE)
    }
  }
  do.call(rbind, out)
}

tp_crossvalidate <- function(d, K = 5L, seed = 1240138L) {
  set.seed(seed)
  ids <- sort(unique(d$id))
  fold_ids <- sample(rep(seq_len(K), length.out = length(ids)))
  fold <- fold_ids[match(d$id, ids)]
  metrics <- calibration <- predictions <- list()
  for (k in seq_len(K)) {
    train <- d[fold != k, , drop = FALSE]; test <- d[fold == k, , drop = FALSE]
    stopifnot(!any(train$id %in% test$id))
    resp <- tp_fit_response(train); fitted <- tp_fit_hurdle(train, resp)
    pi_test <- tp_predict_response(resp, test)
    wt <- test$q * test$R / pi_test
    for (g in c(12, 15.7)) for (family in c("Gamma", "Lognormal")) {
      p <- tp_predict_hurdle(fitted, test, family, g)
      obs <- test$R == 1
      actual <- tp_category(test$drinks_day_to, test$sex, test$status_to, g)
      ymat <- sapply(tp_states, function(s) as.numeric(!is.na(actual) & actual == s))
      lp <- rep(NA_real_, nrow(test))
      lp[obs] <- -log(pmax(p$prob[cbind(which(obs), match(actual[obs], tp_states))], 1e-12))
      rows <- data.frame(fold = k, grams = g, family = family, id = test$id, status = test$status,
        sex = test$sex, age_group = test$age_group, observed = obs, w = wt, actual = actual,
        actual_gpd = test$drinks_day_to * g, predicted_gpd = p$mean, drink_actual = test$drinker_to,
        drink_pred = p$drink, nll = -p$logdensity,
        logloss = lp, brier = rowSums((p$prob - ymat)^2))
      rows <- cbind(rows, as.data.frame(p$prob))
      predictions[[length(predictions) + 1L]] <- rows[obs, , drop = FALSE]
    }
    cat(sprintf("Completed person CV fold %d/%d\n", k, K)); flush.console()
  }
  pr <- do.call(rbind, predictions)
  for (g in c(12, 15.7)) for (family in c("Gamma", "Lognormal")) {
    z <- pr[pr$grams == g & pr$family == family, ]; w <- z$w / sum(z$w)
    metrics[[length(metrics) + 1L]] <- data.frame(grams = g, family = family,
      pairs = nrow(z), persons = length(unique(z$id)), NLL_proxy = sum(w * z$nll),
      category_logloss = sum(w * z$logloss), category_Brier = sum(w * z$brier),
      RMSE_gpd = sqrt(sum(w * (z$actual_gpd - z$predicted_gpd)^2)),
      drinking_Brier = sum(w * (z$drink_actual - z$drink_pred)^2))
    for (s in tp_states) calibration[[length(calibration) + 1L]] <- data.frame(
      grams = g, family = family, state = s, observed = sum(w * (z$actual == s)),
      predicted = sum(w * z[[s]]), n = sum(z$actual == s))
  }
  list(metrics = do.call(rbind, metrics), calibration = do.call(rbind, calibration), predictions = pr,
       folds = data.frame(fold = seq_len(K),
         origin_rows = tabulate(fold, K), origin_ids = tabulate(fold_ids, K)))
}

tp_bootstrap <- function(d, B = 300L, unit = "person", seed = 1240138L) {
  set.seed(seed)
  ids <- unique(d$id); id_index <- match(d$id, ids)
  resp0 <- tp_fit_response(d); fit0 <- tp_fit_hurdle(d, resp0)
  estimates <- function(fit, m) do.call(rbind, lapply(c(12, 15.7), function(g)
    do.call(rbind, lapply(c("Gamma", "Lognormal"), function(f)
      tp_model_estimands(fit, d, g, f, m)))))
  template <- estimates(fit0, rep(1, nrow(d)))
  draws <- matrix(NA_real_, nrow = B, ncol = nrow(template))
  failures <- character(B); solvers <- character(B)
  for (b in seq_len(B)) {
    m <- if (unit == "person") tabulate(sample.int(length(ids), length(ids), replace = TRUE),
      nbins = length(ids))[id_index] else
        tabulate(sample.int(nrow(d), nrow(d), replace = TRUE), nbins = nrow(d))
    z <- tryCatch({
      resp <- tp_fit_response(d, m)
      fit <- tp_fit_hurdle(d, resp, m)
      solvers[b] <- fit$gamma$solver
      estimates(fit, m)$estimate
    }, error = function(e) { failures[b] <<- conditionMessage(e); NULL })
    if (!is.null(z)) draws[b, ] <- z
    if (b %% 25L == 0L) {
      cat(sprintf("Bootstrap %s: %d/%d; failed fits %d\n", unit, b, B, sum(nzchar(failures))))
      flush.console()
    }
  }
  valid <- colSums(is.finite(draws))
  template$se <- apply(draws, 2, stats::sd, na.rm = TRUE)
  template$lower <- apply(draws, 2, function(x) if (sum(is.finite(x)) > 0)
    stats::quantile(x, .025, na.rm = TRUE, names = FALSE) else NA_real_)
  template$upper <- apply(draws, 2, function(x) if (sum(is.finite(x)) > 0)
    stats::quantile(x, .975, na.rm = TRUE, names = FALSE) else NA_real_)
  template$valid_replicates <- valid; template$requested_replicates <- B
  template$unit <- unit
  template$support <- ifelse(template$origin_n == 0, "No origins",
    ifelse(template$structural, "Structural zero",
      ifelse(template$origin_ids < 10, "Too few origin persons for model CI",
        ifelse(valid < .9 * B, "Insufficient valid bootstrap draws", "Conditional model CI"))))
  suppress <- !is.finite(template$estimate) | template$structural |
    template$origin_ids < 10 | valid < .9 * B
  template$lower[suppress] <- template$upper[suppress] <- template$se[suppress] <- NA_real_
  list(summary = template, failure_log = data.frame(unit = unit, replicate = seq_len(B),
    success = !nzchar(failures), gamma_solver = solvers, error = failures))
}

tp_balance <- function(d, response) {
  X <- response$X
  reference <- colSums(X * d$q) / sum(d$q)
  sd <- sqrt(colSums(sweep(X, 2, reference, "-")^2 * d$q) / sum(d$q))
  smd <- function(w) ifelse(sd > 0, (colSums(X * w) / sum(w) - reference) / sd, NA_real_)
  data.frame(term = colnames(X), SMD_complete = smd(d$q * d$R),
    SMD_IPW = smd(response$weights), stringsAsFactors = FALSE)
}

tp_validate_history <- function() {
  toy <- data.frame(id = c("x", "x", "x", "y", "y", "z"),
    wave = c(7, 8, 9, 7, 9, 9), drinker = c(FALSE, TRUE, FALSE, TRUE, FALSE, FALSE))
  a <- tp_history(toy); b <- tp_history(toy[c(6, 3, 2, 1, 5, 4), ])
  stopifnot(identical(a, b), a$status[a$id == "x" & a$wave == 9] == "FD",
    a$status[a$id == "y" & a$wave == 9] == "FD",
    a$status[a$id == "z"] == "ND_unknown",
    !any(a$fd[a$n_prior == 0]),
    identical(a$status[a$wave <= 8], tp_history(toy[toy$wave <= 8, ])$status))
  invisible(TRUE)
}

cat(sprintf("Core helpers loaded; elapsed minutes: %.3f\n",
  as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
