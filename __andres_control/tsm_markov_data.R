# Since 2026-10-27 TSM_ENPG_v4_EN.ipynb is the single source of the TSM v4 analysis and is edited directly; this file no
# longer builds it. It is still sourced by tsm_r7_r11_direct.R, tsm_r7_r11_comparators.R, encavi_tsm_explicado.R and the
# tests. The notebook holds identical copies of these definitions (2026-10-26): a change on either side must be mirrored.
.t0 <- Sys.time()
# TSM version 4 data layer (version 3 plus five states, WHO borders and a two-year link tolerance, 2026-10-26): the v2 loader, observed history and adjacent pairs ported to the EPS engine conventions.
# Contract: __andres_control/tsm_v3_plan_2026-10-19.md (decisions 1-9, 18, 19). Row-level objects stay in memory;
# only aggregates are written. The notebook setup cell creates ts_checks (list) and ts_warnings (character).
ts_seed <- 1240138L
# Dry-run hooks: TSM_B and TSM_REPEATS shrink the bootstrap and the CV repeats; the verifier requires the defaults.
ts_B <- as.integer(Sys.getenv("TSM_B", "1000"))
ts_repeats <- as.integer(Sys.getenv("TSM_REPEATS", "3"))
ts_K <- 5L
# Wider than EPS (10-1000): TSM cells are sparser and the tuned value reached the EPS boundary in the dry run.
ts_kgrid <- c(10, 30, 100, 300, 1000, 3000, 10000)
# C3 and C4 are always merged into C3plus (decision 2026-10-26; too sparse for two states, as in Puka 2022 and Kilian 2025).
ts_ST <- c("N0", "FD", "C1", "C2", "C3plus")
ts_Y <- c("NC", "C1", "C2", "C3plus")
ts_ages <- c("18-29", "30-44", "45-59", "60-65")
ts_periods <- c("R7_R8", "R8_R9", "R9_R10", "R10_R11")
ts_edu_levels <- c("Primary completed or less", "Secondary completed or less", "Tertiary completed or higher")
ts_palette <- c(blue = "#216A83", rust = "#B16031", olive = "#637A44", grey = "#777777",
                light = "#F4F7F8", heat = "#679CAC", pale = "#E8EFF1")
# Approximate fieldwork months (decision 3; R11 unverified) and the elapsed months of every interval.
ts_round_months <- data.frame(wave = 7:11, year_month = c("2023-04", "2023-12", "2024-04", "2024-11", "2025-04"))
ts_round_months$months <- 12 * (as.integer(substr(ts_round_months$year_month, 1, 4)) - 2023) +
  as.integer(substr(ts_round_months$year_month, 6, 7)) - 4
ts_months <- function(from, to) ts_round_months$months[match(to, ts_round_months$wave)] -
  ts_round_months$months[match(from, ts_round_months$wave)]
ts_time <- data.frame(period = ts_periods, from = 7:10, to = 8:11)
ts_time$months <- ts_months(ts_time$from, ts_time$to)
ts_time$years <- ts_time$months / 12
ts_time$min_years <- (ts_time$months - 1) / 12
ts_time$max_years <- (ts_time$months + 1) / 12
ts_check <- function(ok, label) {
  stopifnot(isTRUE(ok))
  ts_checks[[label]] <<- TRUE
  invisible(TRUE)
}
ts_warn <- function(expr) withCallingHandlers(expr, warning = function(w) {
  ts_warnings <<- c(ts_warnings, conditionMessage(w))
  invokeRestart("muffleWarning")
})
ts_theme <- function() ggplot2::theme_minimal(base_size = 12) +
  ggplot2::theme(panel.grid.minor = ggplot2::element_blank(), legend.position = "bottom",
                 plot.title = ggplot2::element_text(face = "bold"))
ts_save <- function(x, name) utils::write.csv(x, file.path(ts_out, paste0(name, ".csv")),
                                           row.names = FALSE, na = "", fileEncoding = "UTF-8")
ts_show <- function(x, caption, digits = 3) {
  IRdisplay::display_html(as.character(htmltools::div(style = "overflow-x:auto;max-height:640px;overflow-y:auto",
    htmltools::HTML(knitr::kable(x, format = "html", digits = digits, row.names = FALSE, caption = caption)))))
}
ts_fig <- function(p, name, w = 10, h = 6) {
  dest <- file.path(ts_out, "en")
  dir.create(dest, showWarnings = FALSE, recursive = TRUE)
  ggplot2::ggsave(file.path(dest, paste0(name, ".png")), p, width = w, height = h, dpi = 170, bg = "white")
  ggplot2::ggsave(file.path(dest, paste0(name, ".pdf")), p, width = w, height = h,
                 device = grDevices::cairo_pdf, bg = "white")
  IRdisplay::display_png(file = file.path(dest, paste0(name, ".png")))
}
ts_age <- function(a) factor(as.character(cut(a, c(18, 30, 45, 60, 66), right = FALSE,
                                             labels = ts_ages)), levels = ts_ages)
ts_key <- function(d, v) if (length(v)) do.call(paste, c(lapply(d[v], as.character), sep = "|")) else rep("All", nrow(d))
ts_wquant <- function(x, w, p) {
  i <- order(x); xx <- x[i]; ww <- w[i]; cp <- cumsum(ww) / sum(ww)
  vapply(p, function(pp) xx[which(cp >= pp)[1]], 1)
}
# Rule 4: same sex and an age change inside [floor((m - 1) / 12), ceiling((m + 1) / 12)] for m elapsed months.
# Primary link tolerance (review 2026-10-19): the TSM age (a3) is a household-roster value that interviewers revise
# only when they notice it, so a +2 change over a few months marks a corrected age of the same person, and the strict
# EPS bounds would drop pairs that start drinking more often than the retained ones. The EPS bounds are therefore
# widened by ts_link_tolerance years on both sides; the strict EPS bounds (tolerance 0) are a sensitivity.
# Tolerance 2 (data-based, 2026-10-26, same criterion as EPS v4): pairs 1-2 years beyond the strict bounds disagree on
# education about as often as strict pairs (15.1% and 11.4% vs 10.5%); beyond 2 years 3 of 14 disagree and only 4 pairs are gained.
ts_link_tolerance <- 2L
ts_compatible <- function(sex_a, sex_b, age_a, age_b, months, tolerance = ts_link_tolerance) {
  gap <- age_b - age_a
  (sex_a == sex_b & gap >= floor((months - 1) / 12) - tolerance & gap <= ceiling((months + 1) / 12) + tolerance) %in% TRUE
}
ts_cat <- function(current, g, sex) {
  lo <- ifelse(sex == "Women", 20, 40); hi <- ifelse(sex == "Women", 40, 60)
  # WHO borders without gaps (decision 2026-10-26): the exact border value goes to the LOWER class. No TSM observation
  # falls exactly on 20/40/60 g/day, so this changes no label relative to the earlier lower-borders-up rule.
  # C3 and C4 merged: C3plus is above 40 g/day (women) or 60 g/day (men).
  ans <- rep(NA_character_, length(g)); ok <- current %in% 1 & is.finite(g) & g > 0
  ans[ok & g <= lo] <- "C1"; ans[ok & g > lo & g <= hi] <- "C2"; ans[ok & g > hi] <- "C3plus"
  ans
}
# Decision 8: typical-quantity signal (1 = band lower bound of at least 5 drinks) and the ambiguous women-in-band-2 flag.
ts_signal <- function(current, qty, sex) {
  cur <- current %in% 1
  data.frame(signal = ifelse(cur, ifelse(qty %in% 3:5, 1, ifelse(qty %in% 1:2, 0, NA_real_)), NA_real_),
             ambiguous = cur & sex == "Women" & qty %in% 2)
}
# Decision 7: EPS completion-based levels; returns the level string or NA (Missing).
ts_education <- function(b4a, b4b, b1, rule = c("lenient", "strict", "reached")) {
  rule <- match.arg(rule)
  b4a <- as.numeric(b4a); b4b <- as.numeric(b4b); attending <- as.numeric(b1) %in% 1
  level <- rep(NA_real_, length(b4a))
  level[b4a %in% 1:4] <- 1
  if (rule == "reached") {
    level[b4a %in% 5:6] <- 2; level[b4a %in% 7:9] <- 3
  } else {
    tec <- if (rule == "strict") 3 else 2; uni <- if (rule == "strict") 5 else 4
    level[b4a %in% 5:6] <- 1; level[b4a %in% 7:8] <- 2; level[b4a %in% 9] <- 3   # level reached but not completed
    # An unknown last grade leaves completion unknown (Missing), as in EPS; this does not occur in R7-R11.
    level[b4a %in% 5:8 & !attending & is.na(b4b)] <- NA
    done <- !attending & !is.na(b4b)   # b1 == 1: b4b is the current grade, so the level is not completed
    level[b4a %in% 5:6 & done & b4b >= 4] <- 2
    level[b4a %in% 7 & done & b4b >= tec] <- 3
    level[b4a %in% 8 & done & b4b >= uni] <- 3
  }
  ts_edu_levels[level]
}
ts_load <- function() {
  source(here::here("_tools", "acc_data.R"))
  ts_out <<- here::here(Sys.getenv("TSM_MARKOV_OUTPUT", "__andres_control/tsm_markov_outputs_v4"))
  dir.create(file.path(ts_out, "en"), showWarnings = FALSE, recursive = TRUE)
  bundle <- "_tsm/tsm.tar.xz.enc"
  ts_root <<- acc_data(bundle)   # decrypted once per session into tempdir(); never into the repository
  files <- file.path(ts_root, paste0("TSM Ronda ", 7:11, ".sav"))
  sidecar <- utils::read.csv(here::here(paste0(bundle, ".md5.csv")), stringsAsFactors = FALSE)
  expected <- sidecar$md5[match(paste0("tsm/", basename(files)), sidecar$file)]
  observed <- unname(tools::md5sum(files))
  if (anyNA(expected) || !identical(observed, expected)) stop("SAV md5 mismatch against ", bundle, ".md5.csv")
  raw <- lapply(files, haven::read_sav)
  ts_raw <<- stats::setNames(lapply(raw, function(x) as.data.frame(x[x$Entrevistado %in% 1, ])), 7:11)
  for (p in ts_raw) stopifnot(!anyNA(p$IdPanel), !anyDuplicated(p$IdPanel), all(p$e3a1 %in% 1:5),
    all(p$a2 %in% 1:2), !anyNA(p$a3), all(p$e3a2[p$e3a1 > 1] %in% 1:5), all(p$e3a3[p$e3a1 > 1] %in% 1:5),
    all(is.finite(p$Fact_Exp) & p$Fact_Exp > 0), all(p$f15a %in% 1:4), all(p$f15b %in% 1:4), all(p$IdRegion %in% 1:16))
  manifest <- data.frame(file = c(bundle, paste0(bundle, " > tsm/", basename(files))), wave = c(NA, 7:11),
    bytes = c(file.size(here::here(bundle)), file.size(files)),
    md5 = c(unname(tools::md5sum(here::here(bundle))), observed), md5_sidecar = c(NA, expected),
    household_rows = c(NA, vapply(raw, nrow, 1L)), respondents = c(NA, vapply(ts_raw, nrow, 1L)))
  ts_save(manifest, "input_manifest")
  vars <- c("IdPanel", "IdEncuesta", "IdPersona", "Entrevistado", "Fact_Exp", "IdRegion",
    "a2", "a3", "a4", "a6", "a7", "a8", "a9", "a9a", "a10", "a12", "a12b",
    "b1", "b4a", "b4b", "b5", "c1", "c2", "c3", "c10", "c11", "d1", "d1m",
    "d5", "d5m", "f1", paste0("f15", letters[1:9]), "e3a1", "e3a2", "e3a3", "e3b")
  dictionary <- do.call(rbind, lapply(7:11, function(w) {
    x <- raw[[w - 6L]]
    do.call(rbind, lapply(intersect(vars, names(x)), function(v) {
      lab <- attr(x[[v]], "label"); val <- attr(x[[v]], "labels")
      data.frame(wave = w, variable = v, label = if (is.null(lab)) "" else lab,
        codes = if (length(val)) paste(paste0(unname(val), "=", names(val)), collapse = "; ") else "Numeric or text; no value labels")
    }))
  }))
  ts_save(dictionary, "variable_dictionary")
  invisible(manifest)
}
ts_waves <- function(grams = 12, top_quantity = 10, education_rule = "lenient", tolerance = ts_link_tolerance) {
  stopifnot(education_rule %in% c("lenient", "strict", "reached"))
  W <- do.call(rbind, lapply(7:11, function(w) {
    p <- ts_raw[[as.character(w)]]
    num <- function(v) as.numeric(p[[v]])
    freq <- num("e3a1"); qty <- num("e3a2"); hed <- num("e3a3")
    qty[!qty %in% 1:5] <- NA; hed[!hed %in% 1:5] <- NA
    current <- as.numeric(freq > 1)   # e3a1 is the current-drinking answer even when a skip was not applied
    # Decision 6: drinks/day = days per week x typical drinks / 7, months of 30.4375 days, open band at top_quantity.
    days_week <- c(0, .5 * 7 / 30.4375, 3 * 7 / 30.4375, 2.5, 5.5)[freq]
    drinks <- c(1, 3.5, 5.5, 8, top_quantity)[qty]
    g <- ifelse(current == 1, grams * days_week * drinks / 7, 0)
    sex <- ifelse(num("a2") == 1, "Men", "Women")
    sg <- ts_signal(current, qty, sex)
    region <- num("IdRegion"); c1 <- num("c1"); c2 <- num("c2"); c3 <- num("c3")
    data.frame(id = as.character(p$IdPanel), wave = w, age = num("a3"), sex = sex,
      edu_lenient = ts_education(p$b4a, p$b4b, p$b1, "lenient"), edu_strict = ts_education(p$b4a, p$b4b, p$b1, "strict"),
      edu_reached = ts_education(p$b4a, p$b4b, p$b1, "reached"), weight_xs = num("Fact_Exp"),
      current = current, grams = g, cat = ts_cat(current, g, sex), signal = sg$signal, signal_ambiguous = sg$ambiguous,
      hed6 = as.numeric(current == 1 & hed %in% 2:5), e3a1 = freq, e3a2 = num("e3a2"), e3a3 = num("e3a3"),
      b1 = num("b1"), b4a = num("b4a"), b4b = num("b4b"), phq2 = num("f15a") + num("f15b") - 2,
      region = ifelse(region == 13, "RM", ifelse(region %in% c(1:4, 15), "North", ifelse(region %in% 5:7, "Centre", "South"))),
      employment = ifelse(c1 %in% 1 | c2 %in% 1 | c3 %in% 1:9, "Yes", ifelse(c3 %in% 10, "No", "Unknown")),
      partnered = as.numeric(num("a6") %in% 1:2), owner = as.numeric(num("f1") %in% 2), freq = freq, qty = qty,
      stringsAsFactors = FALSE)
  }))
  W$education <- W[[paste0("edu_", education_rule)]]
  stopifnot(!anyNA(W$grams), all(W$grams[W$current == 1] > 0), all(W$grams[W$current == 0] == 0),
            !anyNA(W$phq2), all(W$phq2 >= 0 & W$phq2 <= 6), !anyNA(W$cat[W$current == 1]))
  # Decision 5, past-only history. prior_use (used): the flag travels along the person's observed trajectory, from each
  # interview to the next observed one, when that link is compatible by rule 4 with the months between the two rounds.
  # EPS ORs the flag over every compatible link to an earlier wave (chain and direct, each with its own bounds); TSM keeps
  # only the chain through the nearest observed earlier interview, the only variant with zero N0/FD map violations here
  # (strict bounds, linked pairs: chain 0, EPS rule 2, direct links only 16). prior_use_direct (direct links only),
  # prior_use_eps (EPS rule) and prior_use_any (v2, no compatibility) are kept for the audits.
  W$n_prior <- stats::ave(W$wave, W$id, FUN = function(x) rank(x) - 1)
  W$first_wave <- stats::ave(W$wave, W$id, FUN = min)
  W$prior_use <- FALSE; W$prior_use_direct <- FALSE; W$prior_use_any <- FALSE; W$prior_use_eps <- FALSE
  for (w in 8:11) {
    ii <- which(W$wave == w); prev <- rep(NA_integer_, length(ii))
    for (v in (w - 1):7) {
      a <- which(W$wave == v); ix <- match(W$id[ii], W$id[a]); drank <- W$current[a][ix] %in% 1
      hit <- is.na(prev) & !is.na(ix); prev[hit] <- a[ix[hit]]
      comp <- !is.na(ix) & ts_compatible(W$sex[a][ix], W$sex[ii], W$age[a][ix], W$age[ii], ts_months(v, w), tolerance)
      W$prior_use_any[ii] <- W$prior_use_any[ii] | drank
      W$prior_use_direct[ii] <- W$prior_use_direct[ii] | (drank & comp)
      # EPS emulation: the flag travels along every compatible link to an earlier wave (chain and direct).
      W$prior_use_eps[ii] <- W$prior_use_eps[ii] | (comp & (drank | W$prior_use_eps[a][ix] %in% TRUE))
    }
    ok <- !is.na(prev); ii <- ii[ok]; prev <- prev[ok]
    W$prior_use[ii] <- (W$current[prev] == 1 | W$prior_use[prev]) &
      ts_compatible(W$sex[prev], W$sex[ii], W$age[prev], W$age[ii], ts_months(W$wave[prev], w), tolerance)
  }
  W$state <- ifelse(W$current == 1, W$cat, ifelse(W$prior_use, "FD", "N0"))
  rownames(W) <- NULL
  W
}
ts_make_risk <- function(W, tolerance = ts_link_tolerance) {
  out <- lapply(seq_len(nrow(ts_time)), function(k) {
    tm <- ts_time[k, ]; a <- W[W$wave == tm$from & W$age >= 18 & W$age <= 65, ]; b <- W[W$wave == tm$to, ]
    j <- match(a$id, b$id); z <- b[j, ]; present <- !is.na(j)
    compatible <- present & ts_compatible(a$sex, z$sex, a$age, z$age, tm$months, tolerance)
    data.frame(id = a$id, period = tm$period, age = a$age, sex = a$sex, edu = a$education, wbase = a$weight_xs,
      years = tm$years, state0 = a$state, state1 = ifelse(compatible, z$state, NA_character_), linked = compatible,
      grams0 = a$grams, grams1 = ifelse(compatible, z$grams, NA_real_),
      signal0 = a$signal, signal1 = ifelse(compatible, z$signal, NA_real_),
      hed6_0 = a$hed6, hed6_1 = ifelse(compatible, z$hed6, NA_real_),
      phq2 = a$phq2, region = a$region, employment = a$employment, partnered = a$partnered, owner = a$owner,
      log_history = log1p(a$n_prior), after_R7 = as.numeric(a$first_wave > 7), freq = a$freq, qty = a$qty,
      destination_present = present, compatible = compatible, stringsAsFactors = FALSE)
  })
  d <- do.call(rbind, out)
  d$period <- factor(d$period, levels = ts_periods); d$sex <- factor(d$sex, levels = c("Men", "Women"))
  d$age_group <- ts_age(d$age)
  d$edu_missing <- as.numeric(is.na(d$edu)); d$edu_num <- match(d$edu, ts_edu_levels) - 1
  d$edu_num[is.na(d$edu_num)] <- 0
  d$edu <- factor(ifelse(is.na(d$edu), "Missing", d$edu), levels = c(ts_edu_levels, "Missing"))
  d$state0 <- factor(d$state0, levels = ts_ST)
  d$current0 <- as.numeric(d$state0 %in% ts_ST[-(1:2)])
  d$lg0 <- ifelse(d$current0 == 1 & d$grams0 > 0, log(d$grams0), 0)
  d$s0 <- !is.na(d$state0); d$s1 <- d$linked & !is.na(d$state1); d$complete <- d$s0 & d$linked & d$s1
  d$y1 <- factor(ifelse(d$state1 %in% c("N0", "FD"), "NC", d$state1), levels = ts_Y)
  d$row_id <- paste(d$id, d$period, sep = ":")
  d$mult <- 1
  d$region <- factor(d$region, levels = c("RM", "North", "Centre", "South"))
  d$employment <- factor(d$employment, levels = c("No", "Yes", "Unknown"))
  d$signal0f <- factor(ifelse(d$current0 == 0, "Noncurrent", as.character(d$signal0)), levels = c("Noncurrent", "0", "1"))
  d <- d[c("id", "period", "age", "sex", "edu", "edu_num", "edu_missing", "wbase", "years", "state0", "state1", "linked",
    "grams0", "grams1", "signal0", "signal1", "hed6_0", "hed6_1", "age_group", "current0", "lg0", "s0", "s1", "complete",
    "y1", "row_id", "mult", "phq2", "region", "employment", "partnered", "owner", "log_history", "after_R7", "freq", "qty",
    "signal0f", "destination_present", "compatible")]
  rownames(d) <- NULL
  d
}
ts_x <- function(d, formula, terms_keep = NULL) {
  x <- stats::model.matrix(formula, d)
  stopifnot(nrow(x) == nrow(d))   # a missing covariate would silently drop rows
  if (!is.null(terms_keep)) x <- x[, terms_keep, drop = FALSE]
  x
}
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
# Decision 9: stage a (origin classified) and stage c (destination classified given linked) are constant 1 in TSM;
# stage b is one quasibinomial fit with period as a factor; caps and masses are per period.
ts_ipw_formula <- list(base = ~ sex + age_group + edu_num + edu_missing,
  link = ~ period + state0 + sex + age_group + edu_num + edu_missing + lg0 + signal0f + hed6_0 + phq2 + region +
    employment + partnered + owner + log_history + after_R7)
ts_ipw_fit <- function(r) {
  w <- r$wbase * r$mult
  a <- ts_binary_fit(r, as.numeric(r$s0), ts_ipw_formula$base, w)
  i <- r$s0; b <- ts_binary_fit(r[i, ], as.numeric(r$linked[i]), ts_ipw_formula$link, w[i])
  i <- r$s0 & r$linked; c <- ts_binary_fit(r[i, ], as.numeric(r$s1[i]), ts_ipw_formula$link, w[i])
  z <- r[r$complete, ]
  raw <- z$wbase / pmax(ts_binary_prob(a, z) * ts_binary_prob(b, z) * ts_binary_prob(c, z), .02)
  cap <- lapply(stats::setNames(ts_periods, ts_periods), function(p) {
    k <- z$period == p
    if (any(k)) ts_wquant(raw[k], z$mult[k], c(.01, .99)) else NULL
  })
  # shortcut: a period absent from the training rows (interval transport) uses the pooled training caps.
  list(base = a, link = b, final = c, cap = cap, cap_pooled = ts_wquant(raw, z$mult, c(.01, .99)))
}
ts_ipw_apply <- function(r, fit) {
  out <- lapply(ts_periods, function(p) {
    z <- r[r$period == p & r$complete, ]; if (!nrow(z)) return(NULL)
    cap <- if (is.null(fit$cap[[p]])) fit$cap_pooled else fit$cap[[p]]
    z$p_obs <- pmax(ts_binary_prob(fit$base, z) * ts_binary_prob(fit$link, z) * ts_binary_prob(fit$final, z), .02)
    z$untrimmed <- z$wbase / z$p_obs
    z$wcorrected <- pmin(pmax(z$untrimmed, cap[1]), cap[2])
    z$wn <- z$wcorrected * z$mult
    # Each period keeps its observed complete-pair count (ts_period_mass is set by the notebook cell).
    z$wn <- z$wn / sum(z$wn) * ts_period_mass[[p]]
    z
  })
  d <- do.call(rbind, out); rownames(d) <- NULL; d
}
ts_link_audit <- function(W, risk, tolerance = ts_link_tolerance) {
  do.call(rbind, lapply(seq_len(nrow(ts_time)), function(k) {
    tm <- ts_time[k, ]; r <- risk[risk$period == tm$period, ]; b <- W[W$wave == tm$to, ]; j <- match(r$id, b$id)
    present <- !is.na(j); same_sex <- (b$sex[j] == as.character(r$sex)) %in% TRUE
    lo <- floor(tm$min_years) - tolerance; hi <- ceiling(tm$max_years) + tolerance; gap <- b$age[j] - r$age
    in_bounds <- (gap >= lo & gap <= hi) %in% TRUE
    stopifnot(identical(present, r$destination_present), identical(present & same_sex & in_bounds, r$compatible))
    data.frame(period = tm$period, months = tm$months, age_bounds = sprintf("[%d, %d]", lo, hi), origin_rows = nrow(r),
      destination_present = sum(present), compatible = sum(r$compatible), incompatible = sum(present & !r$compatible),
      incompatible_sex = sum(present & !same_sex), incompatible_age = sum(present & same_sex & !in_bounds),
      age_decrease = sum(present & (gap < 0) %in% TRUE), age_increase_above_bound = sum(present & (gap > hi) %in% TRUE),
      linked_persons = length(unique(r$id[r$linked])))
  }))
}
# Evidence for ts_link_tolerance (same criterion as EPS v4): for every destination-present pair, the years by which the
# age change falls outside the strict EPS bounds, and how often the reached education level differs between the two rounds.
# Pairs that are the same person should disagree on education about as often as strict pairs. Age, sex and education do not
# depend on the tolerance, so any ts_waves() result can be passed.
ts_link_tolerance_evidence <- function(W) {
  z <- do.call(rbind, lapply(seq_len(nrow(ts_time)), function(k) {
    tm <- ts_time[k, ]; a <- W[W$wave == tm$from & W$age >= 18 & W$age <= 65, ]; b <- W[W$wave == tm$to, ]
    j <- match(a$id, b$id); a <- a[!is.na(j), ]; b <- b[j[!is.na(j)], ]
    lo <- floor(tm$min_years); hi <- ceiling(tm$max_years); gap <- b$age - a$age
    ra <- match(a$edu_reached, ts_edu_levels); rb <- match(b$edu_reached, ts_edu_levels)
    data.frame(same_sex = a$sex == b$sex, excess = pmin(ifelse(gap < lo, lo - gap, pmax(gap - hi, 0)), 3),
               known = !is.na(ra) & !is.na(rb), differ = !is.na(ra) & !is.na(rb) & ra != rb)
  }))
  out <- do.call(rbind, lapply(split(z, list(z$same_sex, z$excess), drop = TRUE), function(d) data.frame(
    same_sex = d$same_sex[1], years_outside_strict_bounds = ifelse(d$excess[1] == 3, "3 or more", as.character(d$excess[1])),
    pairs = nrow(d), education_known = sum(d$known), education_differs_pct = 100 * sum(d$differ) / max(1, sum(d$known)),
    compatible_at_tolerance = if (d$same_sex[1]) sum(z$same_sex & z$excess <= d$excess[1]) else NA_integer_)))
  out <- out[order(!out$same_sex, out$years_outside_strict_bounds), ]; rownames(out) <- NULL
  out
}
# Per wave and rule: b4a x b4b x attending -> level counts, plus EPS-style education_mapping_changed rows.
ts_education_audit <- function(W) {
  key <- data.frame(wave = W$wave, b4a = ifelse(is.na(W$b4a), "NA", W$b4a), b4b = ifelse(is.na(W$b4b), "NA", W$b4b),
    attending = as.integer(W$b1 %in% 1), stringsAsFactors = FALSE)
  detail <- do.call(rbind, lapply(c("lenient", "strict", "reached"), function(rule) {
    lev <- W[[paste0("edu_", rule)]]
    k <- cbind(key, level = ifelse(is.na(lev), "Missing", lev), n = 1L)
    a <- stats::aggregate(n ~ wave + b4a + b4b + attending + level, k, sum)
    cbind(rule = rule, a)
  }))
  changed <- do.call(rbind, lapply(split(W, W$wave), function(d) data.frame(rule = "lenient", wave = d$wave[1],
    b4a = NA_character_, b4b = NA_character_, attending = NA_integer_,
    level = c("education_mapping_changed vs reached", "education_mapping_changed vs strict"),
    n = c(sum(d$edu_lenient != d$edu_reached, na.rm = TRUE), sum(d$edu_lenient != d$edu_strict, na.rm = TRUE)))))
  out <- rbind(detail, changed)[c("wave", "rule", "b4a", "b4b", "attending", "level", "n")]
  out <- out[order(out$wave, out$rule, is.na(out$b4a), out$b4a, out$b4b, out$attending), ]
  rownames(out) <- NULL
  out
}
ts_history_audit <- function(W) {
  do.call(rbind, lapply(split(W, W$wave), function(d) data.frame(wave = d$wave[1], respondents = nrow(d),
    first_observed = sum(d$n_prior == 0), with_prior_interview = sum(d$n_prior > 0), current = sum(d$current %in% 1),
    N0 = sum(d$state %in% "N0"), FD = sum(d$state %in% "FD"),
    FD_direct_rule = sum(d$current %in% 0 & d$prior_use_direct),
    FD_eps_rule = sum(d$current %in% 0 & d$prior_use_eps),
    FD_any_history = sum(d$current %in% 0 & d$prior_use_any),
    FD_lost_to_incompatible_links = sum(d$current %in% 0 & d$prior_use_any & !d$prior_use))))
}
# FD depends on panel tenure: non-drinkers by number of earlier interviews, and FD rows by months since the last
# observed drinking interview (TSM FD means drinking reported months earlier, not the multi-year EPS former drinker).
ts_fd_tenure_audit <- function(W) {
  nd <- W[W$current %in% 0, ]
  tenure <- do.call(rbind, lapply(sort(unique(nd$n_prior)), function(k) { z <- nd[nd$n_prior == k, ]
    data.frame(table = "non_drinkers_by_earlier_interviews", key = k, non_drinkers = nrow(z),
      N0 = sum(z$state == "N0"), FD = sum(z$state == "FD")) }))
  fd <- nd[nd$state == "FD", ]
  last <- vapply(seq_len(nrow(fd)), function(i) {
    e <- W$wave[W$id == fd$id[i] & W$wave < fd$wave[i] & W$current %in% 1]
    if (length(e)) ts_months(max(e), fd$wave[i]) else NA_real_ }, numeric(1))
  months <- as.data.frame(table(last), stringsAsFactors = FALSE)
  months <- data.frame(table = "FD_by_months_since_last_observed_drinking", key = as.numeric(months$last),
    non_drinkers = NA_integer_, N0 = NA_integer_, FD = months$Freq)
  rbind(tenure, months)
}
# Decision 19: v3 counts before rule 4 against the version 2 aggregates in _tsm/notes/v2_outputs/.
ts_v2_regression <- function(W, risk) {
  v2 <- function(f) utils::read.csv(here::here("_tsm", "notes", "v2_outputs", f), stringsAsFactors = FALSE)
  wd <- v2("weight_diagnostics.csv"); pf <- v2("panel_followup.csv")
  ct <- v2("counts_age_sex_education_HED_category.csv"); ct <- ct[ct$grams == 12, ]
  adult <- W[W$age >= 18 & W$age <= 65, ]; present <- risk$destination_present
  reached <- ifelse(is.na(adult$edu_reached), "Missing", adult$edu_reached)
  state_any <- ifelse(adult$current == 1, adult$cat, ifelse(adult$prior_use_any, "FD", "N0"))
  v2_edu <- c(Basic = ts_edu_levels[1], Secondary = ts_edu_levels[2], Higher = ts_edu_levels[3], Unknown = "Missing")
  v2_sex <- c(Men = "Male", Women = "Female")
  v2_state <- c(ND_unknown = "N0", FD = "FD", cat1 = "C1", cat2 = "C2", cat3 = "C3plus", cat4 = "C3plus")
  row <- function(quantity, v3, baseline, source) data.frame(quantity = quantity, v3 = as.numeric(v3),
    v2_baseline = as.numeric(baseline), source = source)
  pf$period <- gsub("-", "_", pf$interval)
  out <- rbind(
    row("Wave rows (respondents, R7-R11)", nrow(W), 13085, "tsm_v2_sections.R stopifnot; _tsm/README.md respondents"),
    row("Rows aged 18-65", nrow(adult), sum(ct$n), "counts_age_sex_education_HED_category.csv"),
    row("Origin rows (R7-R10, aged 18-65)", nrow(risk), wd$origin_rows, "weight_diagnostics.csv"),
    row("Destination-present pairs", sum(present), wd$observed_pairs, "weight_diagnostics.csv"),
    row("People with a destination-present pair", length(unique(risk$id[present])), wd$observed_ids, "weight_diagnostics.csv"),
    do.call(rbind, lapply(seq_len(nrow(pf)), function(k) rbind(
      row(paste("Origin rows", pf$period[k]), sum(risk$period == pf$period[k]), pf$origin_rows[k], "panel_followup.csv"),
      row(paste("Destination-present pairs", pf$period[k]), sum(present & risk$period == pf$period[k]), pf$observed_pairs[k], "panel_followup.csv")))),
    do.call(rbind, lapply(names(v2_edu), function(e) row(paste0("Rows aged 18-65, reached rule: ", v2_edu[[e]]),
      sum(reached == v2_edu[[e]]), sum(ct$n[ct$education == e]), paste0("counts_age_sex_education_HED_category.csv (", e, ")")))),
    do.call(rbind, lapply(setdiff(names(v2_state), c("cat3", "cat4")), function(s) row(paste0("Rows aged 18-65 in ", v2_state[[s]], " (any-history FD, 12 g)"),
      sum(state_any == v2_state[[s]]), sum(ct$n[ct$state == s]), paste0("counts_age_sex_education_HED_category.csv (", s, ")")))),
    # The v2 baseline closes women's C3 at 100 g/day; v3 merges C3 and C4 (2026-10-26). C3plus is cut-invariant:
    # v2 cat3 + cat4 (>= 40 g women, >= 60 g men) equals v3 C3plus because no TSM value falls exactly on a border.
    do.call(rbind, lapply(c("Men", "Women"), function(s) row(paste(s, "aged 18-65 in C3plus (any-history FD, 12 g)"),
        sum(state_any %in% "C3plus" & adult$sex == s), sum(ct$n[ct$state %in% c("cat3", "cat4") & ct$sex == v2_sex[[s]]]),
        paste0("counts_age_sex_education_HED_category.csv (cat3 + cat4, ", v2_sex[[s]], ")")))))
  out$match <- out$v3 == out$v2_baseline
  out[c("quantity", "v3", "v2_baseline", "match", "source")]
}
cat(sprintf("Elapsed: %.2f minutes\n", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
