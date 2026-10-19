.t0 <- Sys.time()
# Reuse the verified loader, observed histories, survey weights and continuous fits.
source("tsm_pooled_core.R", encoding = "UTF-8")

v2_prepare <- function(d) {
  d$e3a1 <- d$freq; d$e3a2 <- d$qty; d$e3a3 <- d$hed
  d$days_week <- c(0, .5 * 7 / (365.25 / 12), 3 * 7 / (365.25 / 12), 2.5, 5.5)[d$freq]
  d$typical_drinks <- ifelse(d$drinker, c(1, 3.5, 5.5, 8, 10)[d$qty], 0)
  d$drinks_day <- d$days_week * d$typical_drinks / 7
  lower <- c(0, 3, 5, 7, 10)[d$qty]
  threshold <- ifelse(d$sex == "Male", 5, 4)
  d$hed6_reported <- as.integer(d$drinker & d$hed %in% 2:5)
  d$hed54_typical_signal <- as.integer(d$drinker & !is.na(lower) & lower >= threshold)
  d$hed54_proxy <- as.integer(d$hed6_reported == 1 | d$hed54_typical_signal == 1)
  d$hed54_ambiguous <- as.integer(d$drinker & d$sex == "Female" & d$qty %in% 2 & d$hed6_reported == 0)
  stopifnot(!anyNA(d$drinks_day), !anyNA(d$hed54_proxy),
    all(d$drinks_day[d$drinker] > 0), all(d$drinks_day[!d$drinker] == 0))
  d
}

# Preserve original fields; substitute the explicit 5/4 proxy only in model matrices.
v2_original_design <- tp_design
tp_design <- function(d, response = TRUE) {
  d$hed_monthly <- d$hed54_proxy
  X <- v2_original_design(d, response)
  colnames(X)[colnames(X) == "hed_monthly"] <- "hed54_proxy"
  X
}

v2_fit_empirical <- function(d, response, grams, multiplicity = rep(1, nrow(d))) {
  from <- tp_category(d$drinks_day, d$sex, d$status, grams)
  to <- tp_category(d$drinks_day_to, d$sex, d$status_to, grams)
  ok <- d$R == 1 & multiplicity > 0
  w <- response$weights * multiplicity
  counts <- stats::xtabs(w[ok] ~ factor(from[ok], levels = tp_states) +
    factor(to[ok], levels = tp_states), drop.unused.levels = FALSE)
  counts <- as.matrix(counts)
  prob <- counts; fallback <- logical(length(tp_states))
  for (i in seq_along(tp_states)) {
    allowed <- !tp_structural(tp_states[i], tp_states, 1L)
    z <- counts[i, ]
    if (sum(z) == 0) {
      # shortcut: unsupported training origins use the allowed pooled destination margin.
      # This is reported; more data or prespecified hierarchical pooling is the upgrade.
      z <- colSums(counts) * allowed; fallback[i] <- TRUE
    }
    if (sum(z) == 0) z <- as.numeric(allowed)
    prob[i, ] <- z / sum(z)
  }
  dimnames(prob) <- list(tp_states, tp_states)
  list(prob = prob, grams = grams, fallback = stats::setNames(fallback, tp_states), counts = counts)
}

v2_predict_empirical <- function(fit, d) {
  s <- tp_category(d$drinks_day, d$sex, d$status, fit$grams)
  fit$prob[match(s, tp_states), , drop = FALSE]
}

v2_families <- c("Empirical", "Gamma", "Lognormal", "Ordinal")

v2_fit <- function(d, grams = c(12, 15.7), multiplicity = rep(1, nrow(d))) {
  response <- tp_fit_response(d, multiplicity)
  continuous <- tp_fit_hurdle(d, response, multiplicity)
  categorical <- lapply(grams, function(g) list(
    empirical = v2_fit_empirical(d, response, g, multiplicity),
    ordinal = v2_fit_ordinal(d, response, g, multiplicity)))
  names(categorical) <- as.character(grams)
  list(response = response, continuous = continuous, categorical = categorical)
}

v2_predict <- function(fit, d, grams, model) {
  p <- switch(model,
    Empirical = v2_predict_empirical(fit$categorical[[as.character(grams)]]$empirical, d),
    Gamma = tp_predict_hurdle(fit$continuous, d, "Gamma", grams)$prob,
    Lognormal = tp_predict_hurdle(fit$continuous, d, "Lognormal", grams)$prob,
    Ordinal = v2_predict_ordinal(fit$categorical[[as.character(grams)]]$ordinal, d))
  stopifnot(identical(colnames(p), tp_states), all(is.finite(p)), min(p) >= -1e-10,
    max(abs(rowSums(p) - 1)) < 1e-8)
  p <- matrix(as.numeric(p), nrow = nrow(d), ncol = length(tp_states),
    dimnames = list(NULL, tp_states))
  p <- pmax(p, 0); p / rowSums(p)
}

v2_estimands <- function(fit, d, grams = c(12, 15.7), multiplicity = rep(1, nrow(d))) {
  out <- list()
  for (g in grams) for (model in v2_families) {
    p <- v2_predict(fit, d, g, model)
    from <- tp_category(d$drinks_day, d$sex, d$status, g)
    for (ed in c("All", "Basic", "Secondary", "Higher")) for (s in tp_states) {
      take <- from == s & (ed == "All" | d$education == ed)
      w <- d$q * multiplicity * take; den <- sum(w)
      z <- if (den > 0) colSums(p * w) / den else rep(NA_real_, length(tp_states))
      out[[length(out) + 1L]] <- data.frame(grams = g, model = model, education = ed,
        from = s, to = tp_states, estimate = z, origin_rows = sum(take),
        origin_ids = length(unique(d$id[take])), structural = tp_structural(s, tp_states, 1L))
    }
  }
  do.call(rbind, out)
}

v2_cv <- function(d, grams = c(12, 15.7), K = 5L, seed = 1240138L) {
  set.seed(seed)
  ids <- sort(unique(d$id)); fi <- sample(rep(seq_len(K), length.out = length(ids)))
  fold <- fi[match(d$id, ids)]
  predictions <- audits <- list()
  for (k in seq_len(K)) {
    train <- d[fold != k, , drop = FALSE]; test <- d[fold == k, , drop = FALSE]
    stopifnot(!any(train$id %in% test$id))
    fit <- v2_fit(train, grams)
    wt <- test$q * test$R / tp_predict_response(fit$response, test)
    obs <- test$R == 1
    for (g in grams) for (model in v2_families) {
      p <- v2_predict(fit, test, g, model)
      actual <- tp_category(test$drinks_day_to, test$sex, test$status_to, g)
      from <- tp_category(test$drinks_day, test$sex, test$status, g)
      y <- match(actual[obs], tp_states)
      pr <- p[obs, , drop = FALSE]; onehot <- diag(length(tp_states))[y, , drop = FALSE]
      py <- pr[cbind(seq_along(y), y)]
      # Common numerical floor changes only the log-score, never probabilities or Brier.
      pred <- tp_states[max.col(pr, ties.method = "first")]
      z <- data.frame(id = test$id[obs], fold = k, grams = g, model = model,
        from = from[obs], actual = actual[obs], predicted = pred, w = wt[obs],
        education = test$education[obs], sex = test$sex[obs], age_group = test$age_group[obs],
        brier = rowSums((pr - onehot)^2), logloss_clipped = -log(pmax(py, 1e-12)),
        logloss_raw = -log(py), true_probability_zero = py == 0,
        logloss_floored = py < 1e-12, correct = pred == actual[obs])
      predictions[[length(predictions) + 1L]] <- cbind(z, as.data.frame(pr))
      empirical <- fit$categorical[[as.character(g)]]$empirical
      ordinal <- fit$categorical[[as.character(g)]]$ordinal
      audits[[length(audits) + 1L]] <- data.frame(fold = k, grams = g, model = model,
        train_pairs = sum(train$R), test_pairs = sum(test$R), train_ids = length(unique(train$id)),
        test_ids = length(unique(test$id)), disjoint_ids = !any(train$id %in% test$id),
        zero_probability_true_outcomes = sum(py == 0), floored_scores = sum(py < 1e-12),
        fallback_predictions = if (model == "Empirical") sum(empirical$fallback[from[obs]]) else 0,
        fallback_ids = if (model == "Empirical") length(unique(test$id[obs][empirical$fallback[from[obs]]])) else 0,
        fallback_weight_share = if (model == "Empirical") sum(wt[obs] * empirical$fallback[from[obs]]) / sum(wt[obs]) else 0,
        absent_training_destinations = paste(tp_states[!tp_states %in%
          tp_category(train$drinks_day_to[train$R == 1], train$sex[train$R == 1], train$status_to[train$R == 1], g)], collapse = ";"))
    }
    cat(sprintf("Completed categorical CV fold %d/%d\n", k, K)); flush.console()
  }
  list(predictions = do.call(rbind, predictions), audit = do.call(rbind, audits),
    folds = data.frame(fold = seq_len(K), origin_rows = tabulate(fold, K), origin_ids = tabulate(fi, K)))
}

v2_metrics <- function(pr) {
  metrics <- class_metrics <- confusion <- calibration <- list()
  for (g in unique(pr$grams)) for (model in v2_families) {
    d <- pr[pr$grams == g & pr$model == model, ]; w <- d$w / sum(d$w)
    rec <- numeric()
    for (s in tp_states) {
      ia <- d$actual == s; ip <- d$predicted == s
      recall <- if (sum(w[ia]) > 0) sum(w[ia & ip]) / sum(w[ia]) else NA_real_
      precision <- if (sum(w[ip]) > 0) sum(w[ia & ip]) / sum(w[ip]) else NA_real_
      rec <- c(rec, recall)
      class_metrics[[length(class_metrics) + 1L]] <- data.frame(grams = g, model = model, state = s,
        observed_pairs = sum(ia), observed_ids = length(unique(d$id[ia])), recall = recall, precision = precision)
      calibration[[length(calibration) + 1L]] <- data.frame(grams = g, model = model, state = s,
        observed = sum(w * ia), predicted = sum(w * d[[s]]), n = sum(ia))
      for (b in tp_states) confusion[[length(confusion) + 1L]] <- data.frame(grams = g, model = model,
        actual = s, predicted = b, n = sum(ia & d$predicted == b),
        row_probability = if (sum(w[ia]) > 0) sum(w[ia & d$predicted == b]) / sum(w[ia]) else NA_real_)
    }
    metrics[[length(metrics) + 1L]] <- data.frame(grams = g, model = model,
      pairs = nrow(d), persons = length(unique(d$id)), Brier = sum(w * d$brier),
      logloss_clipped = sum(w * d$logloss_clipped), logloss_raw = sum(w * d$logloss_raw),
      zero_probability_outcomes = sum(d$true_probability_zero),
      zero_probability_weight_share = sum(w * d$true_probability_zero), accuracy = sum(w * d$correct),
      balanced_accuracy = mean(rec, na.rm = TRUE), classes_with_outcomes = sum(is.finite(rec)),
      floored_log_scores = sum(d$logloss_floored))
  }
  list(metrics = do.call(rbind, metrics), by_class = do.call(rbind, class_metrics),
    confusion = do.call(rbind, confusion), calibration = do.call(rbind, calibration))
}

v2_bootstrap <- function(d, B = 500L, unit = "person", grams = 12, seed = 1240139L) {
  set.seed(seed)
  ids <- unique(d$id); index <- match(d$id, ids)
  template <- v2_estimands(v2_fit(d, grams), d, grams)
  draws <- matrix(NA_real_, B, nrow(template)); failures <- character(B)
  for (b in seq_len(B)) {
    m <- if (unit == "person") tabulate(sample.int(length(ids), length(ids), replace = TRUE), length(ids))[index]
      else tabulate(sample.int(nrow(d), nrow(d), replace = TRUE), nrow(d))
    z <- tryCatch(v2_estimands(v2_fit(d, grams, m), d, grams, m)$estimate,
      error = function(e) { failures[b] <<- conditionMessage(e); NULL })
    if (!is.null(z)) draws[b, ] <- z
    if (b %% 25L == 0) { cat(sprintf("V2 bootstrap %s %d/%d; failed %d\n", unit, b, B, sum(nzchar(failures)))); flush.console() }
  }
  template$valid_replicates <- colSums(is.finite(draws))
  template$lower <- apply(draws, 2, function(x) if (any(is.finite(x)))
    stats::quantile(x, .025, na.rm = TRUE, names = FALSE) else NA_real_)
  template$upper <- apply(draws, 2, function(x) if (any(is.finite(x)))
    stats::quantile(x, .975, na.rm = TRUE, names = FALSE) else NA_real_)
  template$unit <- unit; template$requested_replicates <- B
  no_ci <- template$structural | template$origin_ids < 10 | template$valid_replicates < .9 * B |
    !is.finite(template$estimate) | template$estimate %in% c(0, 1) | template$upper <= template$lower
  no_ci[is.na(no_ci)] <- TRUE
  template$lower[no_ci] <- template$upper[no_ci] <- NA_real_
  template$support <- ifelse(no_ci, "CI suppressed: structural, sparse, boundary or incomplete refits", "Conditional bootstrap CI")
  list(summary = template, audit = data.frame(unit = unit, replicate = seq_len(B), success = !nzchar(failures), error = failures))
}

cat(sprintf("V2 helpers loaded; elapsed minutes: %.3f\n", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
