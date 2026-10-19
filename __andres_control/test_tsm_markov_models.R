.t0 <- Sys.time()
# test_tsm_markov_models.R -- synthetic-data test of the TSM v3 model layer (tsm_markov_models.R).
# No real microdata: a synthetic ts_risk / ts_W pair honouring the schema contract exercises every function.
# Stand-in copies of the data-layer primitives (EPS ep_* ported; IPW stages a and c constant) are defined
# only when the data layer is not already loaded. Run from the repository root (renv activates via .Rprofile).
suppressMessages(here::i_am("__andres_control/test_tsm_markov_models.R"))
if (.Platform$OS.type == "windows") invisible(Sys.setlocale("LC_CTYPE", "English_United States.utf8"))
blk <- function(label, expr) {
  t <- Sys.time(); v <- expr
  cat(sprintf("[%s] %.2f minutes\n", label, as.numeric(difftime(Sys.time(), t, units = "mins")))); invisible(v)
}
ts_checks <- list(); ts_warnings <- character()
ts_out <- here::here(".quarto", "tsm_models_test"); dir.create(ts_out, showWarnings = FALSE, recursive = TRUE)
if (!exists("ts_ipw_fit")) {
  ts_seed <- 1240138L; ts_B <- 1000L; ts_repeats <- 3L; ts_K <- 5L; ts_kgrid <- c(10, 30, 100, 300, 1000)
  ts_ST <- c("N0", "FD", "C1", "C2", "C3", "C4"); ts_Y <- c("NC", "C1", "C2", "C3", "C4")
  ts_ages <- c("18-29", "30-44", "45-59", "60-65"); ts_periods <- c("R7_R8", "R8_R9", "R9_R10", "R10_R11")
  ts_edu_levels <- c("Primary completed or less", "Secondary completed or less", "Tertiary completed or higher")
  ts_palette <- c(blue = "#216A83", rust = "#B16031", olive = "#637A44", grey = "#777777",
                  light = "#F4F7F8", heat = "#679CAC", pale = "#E8EFF1")
  ts_round_months <- data.frame(wave = 7:11, year_month = c("2023-04", "2023-12", "2024-04", "2024-11", "2025-04"),
                                months = c(0, 8, 12, 19, 24))
  .m <- diff(ts_round_months$months)
  ts_time <- data.frame(period = ts_periods, from = 7:10, to = 8:11, months = .m, years = .m / 12,
                        min_years = (.m - 1) / 12, max_years = (.m + 1) / 12)
  ts_compatible <- function(sex_a, sex_b, age_a, age_b, months) {
    ok <- as.character(sex_a) == as.character(sex_b) & (age_b - age_a) >= floor((months - 1) / 12) &
      (age_b - age_a) <= ceiling((months + 1) / 12)
    ok %in% TRUE
  }
  ts_check <- function(ok, label) { stopifnot(isTRUE(ok)); ts_checks[[label]] <<- TRUE; invisible(TRUE) }
  ts_theme <- function() ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(panel.grid.minor = ggplot2::element_blank(), legend.position = "bottom",
                   plot.title = ggplot2::element_text(face = "bold"))
  ts_save <- function(x, name) utils::write.csv(x, file.path(ts_out, paste0(name, ".csv")), row.names = FALSE, na = "", fileEncoding = "UTF-8")
  ts_show <- function(x, caption, digits = 3) { cat("--", caption, "\n"); print(utils::head(x, 12), digits = digits) }
  ts_fig <- function(p, name, w = 10, h = 6) {
    dest <- file.path(ts_out, "en"); dir.create(dest, showWarnings = FALSE, recursive = TRUE)
    ggplot2::ggsave(file.path(dest, paste0(name, ".png")), p, width = w, height = h, dpi = 100, bg = "white")
  }
  ts_warn <- function(expr) withCallingHandlers(expr, warning = function(w) {
    ts_warnings <<- c(ts_warnings, conditionMessage(w)); invokeRestart("muffleWarning")
  })
  ts_age <- function(a) factor(as.character(cut(a, c(18, 30, 45, 60, 66), right = FALSE, labels = ts_ages)), levels = ts_ages)
  ts_key <- function(d, v) if (length(v)) do.call(paste, c(lapply(d[v], as.character), sep = "|")) else rep("All", nrow(d))
  ts_binary_fit <- function(d, y, formula, w) {
    X <- ts_x(d, formula); keep <- w > 0 & is.finite(y) & stats::complete.cases(X)
    if (!any(keep)) stop("No usable training rows in binary model")
    if (length(unique(y[keep])) == 1L) return(list(constant = y[keep][1]))
    X <- X[keep, , drop = FALSE]; ww <- w[keep] / mean(w[keep])
    q <- qr(X * sqrt(ww)); cols <- sort(q$pivot[seq_len(q$rank)])
    fit <- ts_warn(stats::glm.fit(X[, cols, drop = FALSE], y[keep], weights = ww,
      family = stats::quasibinomial(), control = stats::glm.control(maxit = 80)))
    if (!isTRUE(fit$converged)) fit <- ts_warn(stats::glm.fit(X[, cols, drop = FALSE], y[keep], weights = ww,
      family = stats::quasibinomial(), control = stats::glm.control(maxit = 250), start = fit$coefficients))
    stopifnot(isTRUE(fit$converged), all(is.finite(fit$coefficients)))
    list(coef = fit$coefficients, formula = formula, columns = colnames(X)[cols], converged = fit$converged)
  }
  ts_binary_prob <- function(o, d) {
    if (!is.null(o$constant)) return(rep(o$constant, nrow(d)))
    as.numeric(stats::plogis(ts_x(d, o$formula, o$columns) %*% o$coef))
  }
  ts_wquant <- function(x, w, p) {
    i <- order(x); xx <- x[i]; ww <- w[i]; cp <- cumsum(ww) / sum(ww)
    vapply(p, function(pp) xx[which(cp >= pp)[1]], 1)
  }
  ts_ipw_fit <- function(r) {
    lapply(stats::setNames(ts_periods, ts_periods), function(p) {
      d <- r[r$period == p, ]; w <- d$wbase * d$mult
      f1 <- ~ period + state0 + sex + age_group + edu_num + edu_missing + lg0 + signal0f + hed6_0 + phq2 + region +
        employment + partnered + owner + log_history + after_R7
      a <- list(constant = 1)
      i <- d$s0; b <- ts_binary_fit(d[i, ], as.numeric(d$linked[i]), f1, w[i])
      c <- list(constant = 1)
      z <- d[d$complete, ]; prob <- pmax(ts_binary_prob(a, z) * ts_binary_prob(b, z) * ts_binary_prob(c, z), .02)
      raw <- z$wbase / prob
      list(base = a, link = b, final = c, cap = ts_wquant(raw, z$mult, c(.01, .99)))
    })
  }
  ts_ipw_apply <- function(r, fit) {
    out <- lapply(ts_periods, function(p) {
      z <- r[r$period == p & r$complete, ]; if (!nrow(z)) return(z)
      o <- fit[[p]]
      z$p_obs <- pmax(ts_binary_prob(o$base, z) * ts_binary_prob(o$link, z) * ts_binary_prob(o$final, z), .02)
      z$untrimmed <- z$wbase / z$p_obs
      z$wcorrected <- pmin(pmax(z$untrimmed, o$cap[1]), o$cap[2])
      z$wn <- z$wcorrected * z$mult
      z$wn <- z$wn / sum(z$wn) * ts_period_mass[[p]]
      z
    })
    d <- do.call(rbind, out); rownames(d) <- NULL; d
  }
}
source(here::here("__andres_control", "tsm_markov_models.R"))
# ---- synthetic wave table and risk set (schema contract) ----
syn_waves <- function(n_persons = 2500, seed = 20261019) {
  set.seed(seed); rm <- ts_round_months
  sex <- sample(c("Men", "Women"), n_persons, TRUE); age7 <- sample(17:64, n_persons, TRUE); birth <- stats::runif(n_persons, 0, 12)
  first <- sample(7:10, n_persons, TRUE, prob = c(.55, .2, .15, .1)); nw <- sample(1:4, n_persons, TRUE, prob = c(.15, .2, .25, .4))
  edu <- sample(c(ts_edu_levels, "Missing"), n_persons, TRUE, prob = c(.3, .45, .2, .05))
  region <- sample(c("RM", "North", "Centre", "South"), n_persons, TRUE, prob = c(.4, .15, .25, .2))
  employment <- sample(c("No", "Yes", "Unknown"), n_persons, TRUE, prob = c(.35, .6, .05))
  partnered <- stats::rbinom(n_persons, 1, .5); owner <- stats::rbinom(n_persons, 1, .6); u <- stats::rnorm(n_persons)
  rows <- vector("list", n_persons)
  for (i in seq_len(n_persons)) {
    waves <- first[i]:min(11L, first[i] + nw[i]); waves <- waves[c(TRUE, stats::runif(length(waves) - 1) < .85)]
    n <- length(waves); cur <- integer(n); g <- numeric(n); age <- integer(n); lg <- NA
    for (k in seq_len(n)) {
      months <- rm$months[rm$wave == waves[k]]; age[k] <- age7[i] + floor((months + birth[i]) / 12)
      cur[k] <- if (k == 1) stats::rbinom(1, 1, stats::plogis(-.2 + .8 * u[i] + .4 * (sex[i] == "Men"))) else
        if (cur[k - 1] == 1) stats::rbinom(1, 1, stats::plogis(1.4 + .6 * u[i])) else
          stats::rbinom(1, 1, stats::plogis(-1.5 + .6 * u[i] + .3 * (sex[i] == "Men") - .01 * (age[k] - 40)))
      mu <- log(10) + .5 * (sex[i] == "Men") + .4 * u[i]
      if (cur[k] == 1) lg <- if (is.na(lg)) stats::rnorm(1, mu, .8) else .6 * lg + .4 * mu + stats::rnorm(1, 0, .5)
      g[k] <- if (cur[k] == 1) min(exp(lg), 94.29) else 0   # C4 unreachable at 12 g with the 10-drink top value
    }
    qty <- ifelse(cur == 1, as.integer(cut(g / 12, c(-Inf, 2, 4.5, 6.5, 9, Inf))), NA_integer_)
    rows[[i]] <- data.frame(id = sprintf("P%04d", i), wave = waves, age = age, sex = sex[i],
      weight_xs = 100 * exp(stats::rnorm(n, 0, .5)), current = cur, grams = g,
      e3a1 = ifelse(cur == 1, sample(2:5, n, TRUE), 1L), e3a2 = qty,
      e3a3 = ifelse(cur == 1, sample(1:5, n, TRUE, prob = c(.6, .2, .1, .07, .03)), NA_integer_),
      phq2 = pmin(6L, stats::rpois(n, 1.2)), b1 = sample(1:2, n, TRUE), b4a = sample(1:10, n, TRUE), b4b = sample(1:6, n, TRUE),
      edu = edu[i], region = region[i], employment = employment[i], partnered = partnered[i], owner = owner[i],
      stringsAsFactors = FALSE)
  }
  W <- do.call(rbind, rows); W$first <- stats::ave(W$wave, W$id, FUN = min)
  # Incompatible destination records: age jumps and sex changes that the link rule must reject.
  later <- which(W$wave > W$first); jump <- sample(later, round(.02 * length(later))); flip <- sample(setdiff(later, jump), round(.01 * length(later)))
  W$age[jump] <- W$age[jump] + 5L; W$sex[flip] <- ifelse(W$sex[flip] == "Men", "Women", "Men")
  W$hed6 <- as.integer(W$e3a3 %in% 2:5); W$signal <- ifelse(W$current == 1, as.numeric(W$e3a2 >= 3), NA_real_)
  rownames(W) <- NULL; W
}
syn_states <- function(W) {
  W <- W[order(W$id, W$wave), ]; lo <- ifelse(W$sex == "Women", 20, 40); hi <- ifelse(W$sex == "Women", 40, 60)
  W$cat <- ifelse(W$current == 1, ifelse(W$grams < lo, "C1", ifelse(W$grams < hi, "C2", ifelse(W$grams <= 100, "C3", "C4"))), NA)
  W$n_prior <- stats::ave(W$wave, W$id, FUN = seq_along) - 1
  W$prior_use <- FALSE; key <- paste(W$id, W$wave)
  for (L in 1:4) {
    j <- match(paste(W$id, W$wave - L), key)
    ok <- !is.na(j) & ts_compatible(W$sex[j], W$sex, W$age[j], W$age, ts_months_between(W$wave - L, W$wave)) & W$current[j] %in% 1
    W$prior_use <- W$prior_use | ok
  }
  W$state <- ifelse(W$current == 1, W$cat, ifelse(W$prior_use, "FD", "N0"))
  rownames(W) <- NULL; W
}
syn_risk <- function(W) {
  W <- syn_states(W)
  out <- lapply(ts_periods, function(p) {
    tm <- ts_time[ts_time$period == p, ]; w <- ts_wave_of(p)
    a <- W[W$wave == w & W$age >= 18 & W$age <= 65, ]; b <- W[W$wave == w + 1, ]
    j <- match(a$id, b$id); present <- !is.na(j)
    compatible <- present & ts_compatible(a$sex, b$sex[j], a$age, b$age[j], tm$months); linked <- present & compatible
    data.frame(id = a$id, period = p, age = a$age, sex = a$sex, edu = a$edu, wbase = a$weight_xs, years = tm$years,
      state0 = a$state, state1 = ifelse(linked, b$state[j], NA), linked = linked, grams0 = a$grams, grams1 = ifelse(linked, b$grams[j], NA),
      signal0 = a$signal, signal1 = ifelse(linked, b$signal[j], NA), hed6_0 = a$hed6, hed6_1 = ifelse(linked, b$hed6[j], NA),
      phq2 = a$phq2, region = a$region, employment = a$employment, partnered = a$partnered, owner = a$owner,
      log_history = log1p(a$n_prior), after_R7 = as.numeric(a$first > 7), freq = a$e3a1, qty = a$e3a2,
      destination_present = present, compatible = compatible, stringsAsFactors = FALSE)
  })
  d <- do.call(rbind, out)
  d$period <- factor(d$period, levels = ts_periods); d$sex <- factor(d$sex, levels = c("Men", "Women")); d$age_group <- ts_age(d$age)
  d$edu_missing <- as.numeric(d$edu == "Missing"); d$edu_num <- match(d$edu, ts_edu_levels) - 1; d$edu_num[is.na(d$edu_num)] <- 0
  d$edu <- factor(d$edu, levels = c(ts_edu_levels, "Missing"))
  d$region <- factor(d$region, levels = c("RM", "North", "Centre", "South")); d$employment <- factor(d$employment, levels = c("No", "Yes", "Unknown"))
  d$state0 <- factor(d$state0, levels = ts_ST); d$current0 <- as.numeric(d$state0 %in% paste0("C", 1:4))
  d$lg0 <- ifelse(d$current0 == 1 & d$grams0 > 0, log(d$grams0), 0)
  d$signal0f <- factor(ifelse(d$current0 == 0, "Noncurrent", as.character(d$signal0)), levels = c("Noncurrent", "0", "1"))
  d$s0 <- TRUE; d$s1 <- d$linked; d$complete <- d$s0 & d$linked & d$s1
  d$y1 <- factor(ifelse(d$state1 %in% c("N0", "FD"), "NC", d$state1), levels = ts_Y)
  d$row_id <- paste(d$id, d$period, sep = ":"); d$mult <- 1
  rownames(d) <- NULL; d
}
ts_W <- blk("synthetic waves", syn_states(syn_waves()))
ts_risk <- blk("synthetic risk", syn_risk(ts_W))
ts_period_mass <- vapply(ts_periods, function(p) sum(ts_risk$period == p & ts_risk$complete), 1); names(ts_period_mass) <- ts_periods
ts_ip <- ts_ipw_fit(ts_risk); ts_d <- ts_ipw_apply(ts_risk, ts_ip)
cat("wave rows:", nrow(ts_W), " risk rows:", nrow(ts_risk), " complete pairs:", nrow(ts_d), " persons:", length(unique(ts_d$id)), "\n")
print(table(pairs_per_person = table(ts_d$id)))
print(table(origin = ts_d$state0, destination = ts_d$y1))
print(table(period = ts_risk$period, present = ts_risk$destination_present, compatible = ts_risk$compatible))
stopifnot(nrow(ts_d) == length(unique(ts_d$row_id)), all(ts_d$wn > 0), all(is.finite(ts_d$wn)),
  !any(ts_d$state1 == "C4"), sum(ts_d$state1 == "C3") > 0, sum(ts_risk$destination_present & !ts_risk$compatible) > 0,
  all(ts_d$age >= 18 & ts_d$age <= 65), nlevels(droplevels(ts_d$edu)) == 4,
  abs(sum(ts_d$wn) - sum(ts_period_mass)) < 1e-8)
# ---- tuning and full fits ----
ts_tunes <- blk("ts_tune", list(ts_tune(ts_risk, FALSE), ts_tune(ts_risk, TRUE)))
ts_k <- vapply(ts_tunes, function(x) x$k, 1); print(ts_k)
stopifnot(all(ts_k %in% ts_kgrid), all(is.finite(ts_tunes[[1]]$scores$logloss)))
ts_fits <- blk("ts_fit all models", lapply(stats::setNames(names(ts_models), names(ts_models)),
  function(nm) ts_fit(ts_d, nm, ts_k[if (nm == "A_education") 2 else 1])))
for (nm in names(ts_fits)) {
  P <- ts_prob(ts_fits[[nm]], ts_d)
  stopifnot(all(is.finite(P)), max(abs(rowSums(P) - 1)) < 1e-10, identical(colnames(P), ts_Y), nrow(P) == nrow(ts_d))
}
ts_scale <- blk("weight-scale invariance", do.call(rbind, lapply(c("Gamma", "Lognormal", "Multinomial", "Ordinal_two_part", "Lognormal_tsm_extras"), function(nm) {
  d <- ts_d; d$wn <- 10 * d$wn
  diff <- max(abs(ts_prob(ts_fits[[nm]], ts_d) - ts_prob(ts_fit(d, nm, ts_k[1]), ts_d)))
  ts_check(diff < 1e-7, paste("Weight-scale invariance", nm)); data.frame(model = nm, max_absolute_difference = diff)
})))
print(ts_scale)
# ---- cross-validation (local override: 1 repeat, 3 folds) ----
ts_repeats <- 1L; ts_K <- 3L
ts_cv_result <- blk("ts_cv", ts_cv(ts_risk))
stopifnot(nrow(ts_cv_result$audit) == 3, !anyNA(ts_cv_result$weights), all(ts_cv_result$audit$k_A %in% ts_kgrid),
  max(abs(vapply(ts_periods, function(p) sum(ts_cv_result$weights[ts_d$period == p, 1]), 1) - ts_period_mass)) < 1e-8)
ts_cvtab <- blk("ts_cv_tables", ts_cv_tables(ts_cv_result))
stopifnot(setequal(ts_cvtab$summary$model, names(ts_models)), all(is.finite(ts_cvtab$summary$logloss)),
  all(vapply(ts_cvtab$loss, function(x) all(is.finite(x)), TRUE)))
print(ts_cvtab$summary, digits = 4)
ts_contrasts <- blk("ts_score_contrasts", ts_score_contrasts(ts_cvtab))
stopifnot(nrow(ts_contrasts) == 27, all(ts_contrasts$lower <= ts_contrasts$difference & ts_contrasts$difference <= ts_contrasts$upper),
  all(ts_contrasts$interval_basis == "person-cluster Taylor; conditional on fitted OOF predictions"))
print(ts_contrasts[, 1:6], digits = 4)
ts_cal <- do.call(rbind, lapply(c("A", "Gamma", "Lognormal", "Ordinal_two_part", "Ordinal_single", "Multinomial"), function(nm) {
  P <- ts_cvtab$prob[[nm]]
  data.frame(model = nm, category = ts_Y, observed = vapply(ts_Y, function(s) stats::weighted.mean(ts_d$y1 == s, ts_cvtab$w), 1),
    predicted = colSums(P * ts_cvtab$w) / sum(ts_cvtab$w))
}))
ts_cal_cells <- blk("ts_calibration_cells", ts_calibration_cells(ts_cvtab, ts_d))
sums <- stats::aggregate(cbind(observed, predicted) ~ model + state0 + sex + age_group, ts_cal_cells, sum)
stopifnot(identical(names(ts_cal_cells), c("model", "state0", "sex", "age_group", "destination", "n_origin", "observed", "predicted",
  "difference", "absolute_difference", "relative_difference", "sparse")), max(abs(sums$observed - 1)) < 1e-10, max(abs(sums$predicted - 1)) < 1e-10,
  length(unique(ts_cal_cells$model)) == 6, is.logical(ts_cal_cells$sparse), any(ts_cal_cells$sparse))
cat("calibration cells:", nrow(ts_cal_cells), " sparse share:", mean(ts_cal_cells$sparse), "\n")
# ---- matrices on the three groupings and by education ----
ts_points <- blk("ts_targets", ts_targets(ts_d, ts_fits[ts_main_models]))
check_tab <- function(tab) {
  key <- paste(tab$model, tab$group, tab$from); s <- tapply(tab$estimate, key, sum); n <- tapply(tab$n_origin, key, function(x) x[1])
  stopifnot(all(abs(s[n > 0] - 1) < 1e-10), all(is.na(s[n == 0])), all(tab$estimate[tab$structural & tab$n_origin > 0] == 0),
    all(tab$support %in% c("unobserved origin", "sparse", "observed")))
}
check_tab(ts_points)
stopifnot(nrow(ts_points) == 7 * 36 * length(unique(ts_key(ts_d, c("period", "sex", "age_group")))))
ts_pool_sa <- ts_matrices(ts_d, ts_prob(ts_fits$A, ts_d), "A", by = c("sex", "age_group")); check_tab(ts_pool_sa)
ts_pool_tab <- do.call(rbind, lapply(c("A", "Gamma", "Lognormal"), function(nm) {
  d <- ts_d; d$pooled <- "All"; ts_matrices(d, ts_prob(ts_fits[[nm]], d), nm, by = "pooled")
})); check_tab(ts_pool_tab)
ts_edu_tab <- ts_matrices(ts_d, ts_prob(ts_fits$Gamma, ts_d), "Gamma", by = "edu"); check_tab(ts_edu_tab)
stopifnot(nrow(ts_pool_sa) == 8 * 36, nrow(ts_pool_tab) == 3 * 36, nrow(ts_edu_tab) == 4 * 36)
print(ts_pool_tab[ts_pool_tab$model == "Gamma" & ts_pool_tab$from == "C1", c("from", "to", "n_origin", "estimate", "support")], digits = 3)
ts_engine <- ts_coef(ts_fits)
stopifnot(all(c("shape", "sigma") %in% ts_engine$term), setequal(unique(ts_engine$model), c("Gamma", "Lognormal")), all(is.finite(ts_engine$estimate)))
# ---- one replicate (timing for the bootstrap budget) and the person bootstrap ----
boot_models <- c("A", "Gamma", "Lognormal", "Ordinal_single")
t_rep <- Sys.time(); rep1 <- ts_replicate(rep(1, length(unique(ts_risk$id))), boot_models, annual = TRUE)
rep_minutes <- as.numeric(difftime(Sys.time(), t_rep, units = "mins"))
cat(sprintf("One ts_replicate call (4 models + 3 annual generators, %d persons, %d pairs): %.3f minutes\n", length(unique(ts_risk$id)), nrow(ts_d), rep_minutes))
v <- unlist(lapply(boot_models, function(nm) {   # full-data targets: by period, pooled sex x age, "All"
  P <- ts_prob(ts_fits[[nm]], ts_d); dd <- ts_d; dd$pooled <- "All"
  c(ts_vector(ts_matrices(ts_d, P, nm)), ts_vector(ts_matrices(ts_d, P, nm, by = c("sex", "age_group"))), ts_vector(ts_matrices(dd, P, nm, by = "pooled")))
}))
stopifnot(setequal(names(rep1$target), names(v)), max(abs(rep1$target - v[names(rep1$target)]), na.rm = TRUE) < 1e-8,
  all(names(ts_vector(ts_pool_tab)) %in% names(rep1$target)), length(rep1$annual) == 3 * 36, all(is.finite(rep1$coefficients)))
ts_B <- 8L
ts_person <- blk("ts_bootstrap_person B=8", ts_bootstrap_person(boot_models, annual = TRUE, B = ts_B))
stopifnot(length(ts_person) == 8, file.exists(file.path(ts_out, "person_bootstrap_audit.csv")))
ts_personmat <- do.call(rbind, lapply(ts_person, function(x) x$target))
ts_perpoint <- ts_points[ts_points$model %in% boot_models, ]
ts_ci <- cbind(ts_perpoint, ts_interval(ts_vector(ts_perpoint), ts_personmat[, names(ts_vector(ts_perpoint)), drop = FALSE]))
ok <- ts_ci$interval_status == "available"
stopifnot(any(ok), all(ts_ci$lower[ok] <= ts_ci$estimate[ok] + 1e-14 & ts_ci$upper[ok] >= ts_ci$estimate[ok] - 1e-14),
  all(ts_ci$lower[ok] >= 0 & ts_ci$upper[ok] <= 1), all(is.na(ts_ci$lower[!ok])), all(ts_ci$valid_replicates <= 8))
print(table(ts_ci$interval_status, ts_ci$support))
pool_keys <- names(ts_vector(ts_pool_tab))
ts_pool_ci <- cbind(ts_pool_tab, ts_interval(ts_vector(ts_pool_tab), do.call(rbind, lapply(ts_person, function(x) x$target[pool_keys]))))
stopifnot(sum(ts_pool_ci$interval_status == "available") == sum(ts_pool_ci$n_origin > 0))
print(ts_pool_ci[ts_pool_ci$model == "Gamma" & ts_pool_ci$from == ts_pool_ci$to, c("model", "from", "n_origin", "estimate", "lower", "upper", "interval_status")], digits = 3)
coef_names <- paste(ts_engine$model, ts_engine$component, ts_engine$term, sep = "::")
ts_engine_ci <- cbind(ts_engine, ts_interval(ts_engine$estimate, do.call(rbind, lapply(ts_person, function(x) x$coefficients[coef_names])), probability = FALSE))
stopifnot(all(ts_engine_ci$lower <= ts_engine_ci$estimate & ts_engine_ci$estimate <= ts_engine_ci$upper))
ts_mc <- ts_bootstrap_stability(ts_personmat); print(ts_mc)
stopifnot(nrow(ts_mc) == 1, ts_mc$replicates == 8, abs(ts_mc$median_SE_ratio_to_1000 - 1) < 1e-12)
# ---- annual generator ----
ts_annual_full <- blk("ts_annual A/Gamma/Lognormal with gradient check",
  lapply(ts_fits[c("A", "Gamma", "Lognormal")], function(f) ts_annual(ts_d, f, starts = .05, check_gradient = TRUE)))
ts_ann <- do.call(rbind, lapply(names(ts_annual_full), function(nm) {
  z <- ts_annual_full[[nm]]
  ts_check(max(abs(rowSums(z$P) - 1)) < 1e-8 && min(z$P) > -1e-10, paste("Annual stochastic matrix", nm))
  ts_check(z$semigroup_error < 1e-8, paste("Annual semigroup", nm))
  stopifnot(z$gradient_error < 1e-6, z$convergence == 0, identical(dim(z$P), c(6L, 6L)))
  data.frame(model = nm, from = rep(ts_ST, 6), to = rep(ts_ST, each = 6), estimate = as.vector(z$P),
    weighted_reconstruction_RMSE = z$rmse, optimizer_code = z$convergence, semigroup_error = z$semigroup_error)
}))
ts_ann <- cbind(ts_ann, ts_interval(ts_ann$estimate, do.call(rbind, lapply(ts_person, function(x) x$annual))))
print(ts_ann[ts_ann$from == ts_ann$to, c("model", "from", "estimate", "lower", "upper", "weighted_reconstruction_RMSE")], digits = 3)
ts_ann_sens <- ts_annual(ts_d, ts_fits$Gamma, lambda = 1e-5); stopifnot(ts_ann_sens$convergence == 0)
# ---- transport, history, Chapman-Kolmogorov, rank matching, HED ----
ts_trans <- blk("ts_transport", ts_transport())
stopifnot(nrow(ts_trans$scores) == 4 * 5 * 7, nrow(ts_trans$coverage) == 20, all(is.finite(ts_trans$scores$logloss)),
  all(ts_trans$coverage$common_support <= ts_trans$coverage$candidate_pairs), setequal(ts_trans$scores$held_out, ts_periods))
ts_transport_summary <- do.call(rbind, lapply(split(ts_trans$scores, paste(ts_trans$scores$held_out, ts_trans$scores$model)), function(z)
  data.frame(held_out = z$held_out[1], proxy_period = z$proxy_period[1], model = z$model[1], logloss = stats::weighted.mean(z$logloss, z$weight_sum),
    brier = stats::weighted.mean(z$brier, z$weight_sum), n = sum(z$n))))
print(ts_transport_summary[ts_transport_summary$model %in% c("A", "Gamma"), ], digits = 4)
print(unique(ts_trans$coverage[, c("held_out", "train_periods", "proxy_period")]))
ts_hist <- blk("ts_history_check", ts_history_check())
stopifnot(nrow(ts_hist) == 2, all(is.finite(ts_hist$difference_history_minus_current)),
  all(ts_hist$lower <= ts_hist$difference_history_minus_current & ts_hist$difference_history_minus_current <= ts_hist$upper))
print(ts_hist[, 1:6], digits = 4)
ts_ck_tab <- blk("ts_ck B=50", ts_ck(B = 50))
stopifnot(nrow(ts_ck_tab) == 9 * 4, setequal(ts_ck_tab$period, c("All", ts_periods[-1])),
  all(ts_ck_tab$observed[is.finite(ts_ck_tab$observed)] >= 0 & ts_ck_tab$observed[is.finite(ts_ck_tab$observed)] <= 1))
print(ts_ck_tab[ts_ck_tab$period == "All", c("from", "to", "n_pairs", "observed", "chained", "difference", "lower", "upper")], digits = 3)
ts_rank_tab <- blk("ts_rank", ts_rank(ts_d))
rs <- tapply(ts_rank_tab$probability, paste(ts_rank_tab$period, ts_rank_tab$source, ts_rank_tab$from), sum, na.rm = TRUE)
stopifnot(nrow(ts_rank_tab) == 4 * 2 * 25, all(abs(rs[rs > 0] - 1) < 1e-8))
ts_hed_result <- blk("ts_hed", ts_hed())
stopifnot(nrow(ts_hed_result$coef) > 5, all(is.finite(ts_hed_result$coef$estimate)), nrow(ts_hed_result$proportions) >= 6)
print(ts_hed_result$proportions, digits = 3)
# ---- merged C3plus variant ----
ts_merged <- blk("ts_merged_variant (K=3)", ts_merged_variant(ts_risk, K = 3, repeats = 1))
stopifnot(nrow(ts_merged$cv_scores) == 3, nrow(ts_merged$pooled) == 3 * 25, nrow(ts_merged$annual) == 3 * 25,
  setequal(ts_merged$pooled$from, c("N0", "FD", "C1", "C2", "C3plus")), all(is.finite(ts_merged$cv_scores$logloss)),
  all(ts_merged$annual$semigroup_error < 1e-8), all(ts_merged$annual$optimizer_code == 0))
check_tab(ts_merged$pooled); print(ts_merged$cv_scores, digits = 4)
# ---- cross-check with the real EPS aggregate CSVs ----
ts_cross <- blk("ts_crosscheck_eps", ts_crosscheck_eps(ts_d, ts_fits, ts_annual_full, ts_cvtab, ts_ann))
eA <- utils::read.csv(here::here("__andres_control", "eps_markov_outputs", "transition_matrices_design_CI.csv"))
eA <- eA[eA$model == "A" & is.finite(eA$estimate), ]; eA$to <- ifelse(eA$to %in% c("N0", "FD"), "NC", eA$to)
observed_origins <- names(which(table(factor(as.character(ts_d$state0), levels = ts_ST)) > 0))
eps_cells <- nrow(unique(eA[eA$from %in% observed_origins, c("period", "from", "to")]))  # collapsed destinations, supported origins
cat("EPS pooled cells (model A, finite):", eps_cells, "
")
stopifnot(nrow(ts_cross$annual) == 2 * 3 * 36, sum(ts_cross$annual$staying) == 2 * 3 * 6,
  nrow(ts_cross$projection_eps_to_tsm) == 3 * 5 * 3, all(is.finite(ts_cross$projection_eps_to_tsm$logloss)),
  nrow(ts_cross$projection_eps_matrices) == 3 * 4 * 30, nrow(ts_cross$projection_tsm_to_eps) == 3 * eps_cells,
  nrow(ts_cross$projection_tsm_to_eps_summary) == 12, all(is.finite(ts_cross$projection_tsm_to_eps_summary$weighted_RMSE)),
  is.logical(ts_cross$projection_tsm_to_eps$comparable), all(ts_cross$projection_tsm_to_eps$to %in% ts_Y))
rec <- ts_cross$projection_eps_to_tsm[ts_cross$projection_eps_to_tsm$source == "EPS_projection" & ts_cross$projection_eps_to_tsm$period == "All", ]
cat("EPS generator recovery RMSE by model:\n"); print(rec[, c("model", "recovery_rmse")], digits = 3)
stopifnot(all(rec$recovery_rmse < 1e-2))
print(ts_cross$projection_eps_to_tsm[ts_cross$projection_eps_to_tsm$period == "All", c("source", "model", "logloss", "brier", "n")], digits = 4)
print(ts_cross$projection_tsm_to_eps_summary, digits = 3)
# ---- sensitivities: conversion (synthetic rebuild), education rule stand-in, upper band stand-in ----
ts_sensitivity <- blk("conversion sensitivity (synthetic rebuild)", do.call(rbind, lapply(c(12, 15.7), function(g) {
  W2 <- ts_W; W2$grams <- W2$grams * g / 12; r <- syn_risk(W2); d <- ts_ipw_apply(r, ts_ipw_fit(r))
  do.call(rbind, lapply(c("A", "Gamma", "Lognormal"), function(nm) {
    q <- ts_quantities(ts_prob(ts_fit(d, nm, ts_k[1]), d), d)
    data.frame(grams_per_drink = g, model = nm, quantity = names(q), probability = unname(q))
  }))
})))
stopifnot(nrow(ts_sensitivity) == 18, all(is.finite(ts_sensitivity$probability)))
r_alt <- ts_risk; r_alt$edu_num <- pmin(r_alt$edu_num + 1, 2)   # stand-in for a second education rule
ts_edu_sens <- blk("ts_education_sensitivity", ts_education_sensitivity(list(lenient = ts_risk, strict = r_alt)))
stopifnot(nrow(ts_edu_sens$summary) == 2 * 2 * 3, identical(names(ts_edu_sens$summary), c("rule", "model", "quantity", "probability")),
  nrow(ts_edu_sens$pooled) == 2 * 2 * 36, "rule" %in% names(ts_edu_sens$pooled))
W16 <- ts_W; W16$grams[W16$e3a2 %in% 5] <- W16$grams[W16$e3a2 %in% 5] * 1.6   # stand-in for the 16-drink top band
ts_band <- blk("ts_upper_band_sensitivity", ts_upper_band_sensitivity(syn_risk(W16)))
stopifnot(nrow(ts_band$summary) == 9, identical(names(ts_band$summary), c("scenario", "model", "quantity", "probability")), nrow(ts_band$pooled) == 3 * 36)
print(ts_edu_sens$summary, digits = 3); print(ts_band$summary, digits = 3)
# ---- diagrams and plots ----
ts_counts <- as.data.frame(table(period = ts_d$period, sex = ts_d$sex, age_group = ts_d$age_group, state0 = ts_d$state0)); names(ts_counts)[5] <- "n"
blk("ts_diagrams", ts_diagrams()); blk("ts_plots", ts_plots())
figs <- c("fig_flowchart", "fig_intervals_pairs", "fig_two_part", "fig_rank_matching", "fig_pooled_matrices", "fig_sparsity", "fig_cv_logloss",
  "fig_calibration", "fig_calibration_by_origin", "fig_person_intervals", "fig_annual_tsm_vs_eps", "fig_conversion_sensitivity")
stopifnot(all(file.exists(file.path(ts_out, "en", paste0(figs, ".png")))))
# ---- wrap up ----
ts_save(data.frame(check = names(ts_checks), passed = unlist(ts_checks), row.names = NULL), "analysis_checks")
cat("checks recorded:", length(ts_checks), " all passed:", all(unlist(ts_checks)), "\n")
cat("fit warnings:", length(ts_warnings), "distinct:", length(unique(ts_warnings)), "\n"); print(utils::head(sort(table(ts_warnings), decreasing = TRUE), 5))
cat(sprintf("One ts_replicate call took %.3f minutes; 1,000 replicates would take about %.1f minutes at this size\n", rep_minutes, 1000 * rep_minutes))
cat("TEST PASSED\n")
cat(sprintf("Elapsed: %.2f minutes\n", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
