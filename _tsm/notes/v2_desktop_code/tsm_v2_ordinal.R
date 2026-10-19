.t0 <- Sys.time()
# Proportional-odds comparator using the existing additive predictor matrix.
# Source tsm_pooled_core.R first. No microdata are written by these helpers.

v2_ordinal_levels <- c("Non_drinker", "cat1", "cat2", "cat3", "cat4")
v2_ordinal_final_states <- c("ND_unknown", "FD", "cat1", "cat2", "cat3", "cat4")

v2_ordinal_error <- function(message, diagnostics) {
  stop(structure(list(message = message, call = NULL, diagnostics = diagnostics),
    class = c("v2_ordinal_fit_error", "error", "condition")))
}

v2_ordinal_design <- function(d, rows, weights) {
  raw <- tp_design(d, FALSE)
  raw <- raw[, colnames(raw) != "(Intercept)", drop = FALSE]
  q <- weights / sum(weights)
  center <- colSums(raw[rows, , drop = FALSE] * q)
  centered <- sweep(raw, 2L, center, "-")
  scale <- sqrt(colSums(centered[rows, , drop = FALSE]^2 * q))
  varying <- is.finite(scale) & scale > sqrt(.Machine$double.eps)
  candidate <- centered[, varying, drop = FALSE]
  if (ncol(candidate)) {
    candidate <- sweep(candidate, 2L, scale[varying], "/")
    qr_x <- qr(candidate[rows, , drop = FALSE] * sqrt(weights))
    keep <- sort(qr_x$pivot[seq_len(qr_x$rank)])
    X <- candidate[, keep, drop = FALSE]
  } else X <- matrix(numeric(), nrow(d), 0L)
  columns <- colnames(X)
  list(X = X, columns = columns, center = center[columns], scale = scale[columns],
    dropped = setdiff(colnames(raw), columns))
}

v2_fit_ordinal <- function(d, response, grams, multiplicity = rep(1, nrow(d))) {
  stopifnot(length(response$weights) == nrow(d), length(multiplicity) == nrow(d),
    all(is.finite(multiplicity)), all(multiplicity >= 0),
    all(is.finite(response$weights)), all(response$weights >= 0))
  destination <- tp_category(d$drinks_day_to, d$sex, d$status_to, grams)
  destination[destination %in% c("ND_unknown", "FD")] <- "Non_drinker"
  w <- response$weights * multiplicity
  rows <- d$R == 1 & !is.na(destination) & w > 0
  if (!any(rows)) stop("Ordinal model has no observed destinations with positive weight.")
  stopifnot(all(destination[rows] %in% v2_ordinal_levels))
  support <- do.call(rbind, lapply(v2_ordinal_levels, function(s) {
    ii <- rows & !is.na(destination) & destination == s
    data.frame(category = s, observed_rows = sum(ii),
      observed_persons = length(unique(d$id[ii])),
      weighted_total = sum(w[ii]), training_present = any(ii),
      prediction_rule = if (any(ii)) "Fitted category" else "Absent in training: zero mass")
  }))
  present <- support$category[support$training_present]
  design <- v2_ordinal_design(d, rows, w[rows])
  X <- design$X[rows, , drop = FALSE]
  normalized_w <- w[rows] / mean(w[rows])
  y <- ordered(destination[rows], levels = present)
  warnings <- character()
  diagnostics <- list(grams = grams, training_rows = sum(rows),
    training_persons = length(unique(d$id[rows])), category_support = support,
    absent_categories = setdiff(v2_ordinal_levels, present),
    dropped_columns = design$dropped, predictor_columns = design$columns,
    shared_predictor = "tp_design(d, FALSE); training-only centering, scaling and QR",
    zero_state_rule = "Non-drinker mass assigned by origin ever_known; ND and FD are not ordered",
    proportional_odds_assumed = TRUE, proportional_odds_tested = FALSE,
    warnings = warnings, convergence = NA_integer_)
  result <- list(grams = grams, levels = present, columns = design$columns,
    center = design$center, scale = design$scale, support = support,
    absent_categories = diagnostics$absent_categories, diagnostics = diagnostics,
    coefficients = numeric(), thresholds = numeric(), fit = NULL)
  if (length(present) == 1L) {
    result$kind <- "constant"
    result$diagnostics$model <- "Constant training outcome; point-mass prediction"
    result$diagnostics$convergence <- 0L
    return(result)
  }
  capture_warning <- function(warning) {
    warnings <<- c(warnings, conditionMessage(warning))
    invokeRestart("muffleWarning")
  }
  if (length(present) == 2L) {
    fitted <- tryCatch(withCallingHandlers(stats::glm.fit(
      cbind("(Intercept)" = 1, X), as.integer(y) - 1L, weights = normalized_w,
      family = stats::quasibinomial(),
      control = stats::glm.control(maxit = 200L, epsilon = 1e-9)),
      warning = capture_warning), error = function(e) e)
    diagnostics$warnings <- unique(warnings)
    if (inherits(fitted, "error") || !isTRUE(fitted$converged) ||
        any(!is.finite(fitted$coefficients))) {
      detail <- if (inherits(fitted, "error")) conditionMessage(fitted) else "nonconvergence or nonfinite coefficients"
      v2_ordinal_error(paste("Binary ordinal limit failed:", detail), diagnostics)
    }
    result$kind <- "binary"
    result$coefficients <- fitted$coefficients
    result$fit <- fitted
    diagnostics$model <- "Binary cumulative-logit limit: two categories observed"
    diagnostics$convergence <- 0L
  } else {
    safe_columns <- if (ncol(X)) paste0("x", seq_len(ncol(X))) else character()
    frame <- as.data.frame(X)
    names(frame) <- safe_columns
    frame$outcome <- y
    frame$case_weight <- normalized_w
    formula <- if (length(safe_columns)) stats::reformulate(safe_columns, response = "outcome") else outcome ~ 1
    cumulative <- cumsum(support$weighted_total[support$training_present])
    cut_start <- stats::qlogis(head(cumulative / sum(w[rows]), -1L))
    # Weighted empirical cutpoints avoid a fragile auxiliary binomial starting fit.
    start <- c(rep(0, ncol(X)), cut_start)
    fitted <- tryCatch(withCallingHandlers(MASS::polr(formula, data = frame,
      weights = case_weight, start = start, method = "logistic", Hess = TRUE,
      model = FALSE, control = list(maxit = 1000L, reltol = 1e-10)),
      warning = capture_warning), error = function(e) e)
    diagnostics$warnings <- unique(warnings)
    if (inherits(fitted, "error") || !identical(fitted$convergence, 0L) ||
        any(!is.finite(fitted$coefficients)) || any(!is.finite(fitted$zeta)) ||
        any(diff(fitted$zeta) <= 0)) {
      detail <- if (inherits(fitted, "error")) conditionMessage(fitted) else "nonconvergence or invalid coefficients/cutpoints"
      v2_ordinal_error(paste("Unpenalized proportional-odds fit failed:", detail), diagnostics)
    }
    result$kind <- "polr"
    result$coefficients <- unname(fitted$coefficients)
    result$thresholds <- unname(fitted$zeta)
    result$fit <- fitted
    diagnostics$model <- "MASS::polr, unpenalized proportional odds"
    diagnostics$convergence <- fitted$convergence
    diagnostics$hessian_condition <- kappa(fitted$Hessian)
    diagnostics$minimum_hessian_eigenvalue <- min(eigen(fitted$Hessian, symmetric = TRUE, only.values = TRUE)$values)
    diagnostics$maximum_absolute_coefficient <- max(c(0, abs(fitted$coefficients)))
  }
  result$diagnostics <- diagnostics
  result
}

v2_predict_ordinal <- function(fit, d) {
  n <- nrow(d)
  final <- matrix(0, n, length(v2_ordinal_final_states),
    dimnames = list(NULL, v2_ordinal_final_states))
  if (!n) return(final)
  stopifnot(!anyNA(d$ever_known), all(d$ever_known %in% c(FALSE, TRUE)))
  probabilities <- matrix(0, n, length(v2_ordinal_levels),
    dimnames = list(NULL, v2_ordinal_levels))
  if (fit$kind == "constant") {
    probabilities[, fit$levels] <- 1
  } else {
    raw <- tp_design(d, FALSE)
    stopifnot(all(fit$columns %in% colnames(raw)))
    X <- raw[, fit$columns, drop = FALSE]
    if (ncol(X)) X <- sweep(sweep(X, 2L, fit$center, "-"), 2L, fit$scale, "/")
    if (fit$kind == "binary") {
      upper <- stats::plogis(as.numeric(cbind(1, X) %*% fit$coefficients))
      probabilities[, fit$levels[1L]] <- 1 - upper
      probabilities[, fit$levels[2L]] <- upper
    } else {
      eta <- if (ncol(X)) as.numeric(X %*% fit$coefficients) else rep(0, n)
      cuts <- fit$thresholds
      p <- matrix(0, n, length(fit$levels))
      p[, 1L] <- stats::plogis(cuts[1L] - eta)
      p[, ncol(p)] <- stats::plogis(eta - cuts[length(cuts)])
      for (j in seq.int(2L, ncol(p) - 1L)) {
        lo <- cuts[j - 1L] - eta; hi <- cuts[j] - eta
        p[, j] <- ifelse(lo > 0, stats::plogis(-lo) - stats::plogis(-hi),
          stats::plogis(hi) - stats::plogis(lo))
      }
      probabilities[, fit$levels] <- p
    }
  }
  final[, "ND_unknown"] <- probabilities[, "Non_drinker"] * !d$ever_known
  final[, "FD"] <- probabilities[, "Non_drinker"] * d$ever_known
  final[, paste0("cat", 1:4)] <- probabilities[, paste0("cat", 1:4), drop = FALSE]
  stopifnot(all(is.finite(final)), min(final) >= -1e-12,
    max(abs(rowSums(final) - 1)) < 1e-8)
  final <- pmax(final, 0)
  final / rowSums(final)
}

cat(sprintf("Ordinal helpers loaded; elapsed minutes: %.3f\n",
  as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
