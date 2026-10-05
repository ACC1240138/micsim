###############################################################################
# revision_diseno_enpg.R
#
# Goal
# ----
# Build a reusable ENPG wave cache and measure the additional variance factor
# due to clustering, after the Kish effective sample size has already captured
# the weight dispersion.
#
# Important design decision
# -------------------------
# The applied residual clustering factor is calibrated at REGION granularity.
# This follows the original logic:
#
#   1. The older waves are used with region-level stratification.
#   2. The comparable calibration is therefore 2022 and 2024 with UPM as PSU
#      and REGION as the stratum.
#   3. The 2024 ESTRATO design is useful as a sensitivity check, but it is not
#      the factor to carry back to older waves if the older-wave analysis uses
#      region-level strata.
#
# Outputs
# -------
# Raw data/enpg_design_waves_2012_2024_list.RDS
# __andres_control/enpg_cluster_structure.csv
# __andres_control/enpg_cluster_factors.csv
# __andres_control/enpg_region_factor_calibration.csv
#
# Notes
# -----
# - 2008 and 2010 are intentionally excluded from the cached list and from the
#   factor-calibration table.
# - 2016 receives its external expansion factor file before being cached.
# - 2020 is kept in the cache because it is part of the later ENPG series, but
#   it does not have a clearly validated PSU in the available public RDS. For
#   that reason, the script reports Kish/weight diagnostics for 2020 but leaves
#   the residual clustering factor as NA.
# - All code comments and messages are in English by project convention.
###############################################################################

.t0 <- Sys.time()

required_packages <- c("haven", "survey")
missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]
if (length(missing_packages) > 0L) {
  stop(
    "Missing required packages: ",
    paste(missing_packages, collapse = ", "),
    call. = FALSE
  )
}

options(survey.lonely.psu = "adjust")

repo_root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
raw_dir <- file.path(
  repo_root,
  "Sex-and-age-differences-in-alcohol-attributable-mortality-in-Chile-between-2008-and-2022-main",
  "Raw data"
)
if (!dir.exists(raw_dir)) {
  raw_dir <- file.path(repo_root, "Raw data")
}
if (!dir.exists(raw_dir)) {
  stop("Raw data directory was not found from getwd().", call. = FALSE)
}

out_dir <- file.path(repo_root, "__andres_control")
if (!dir.exists(out_dir)) {
  dir.create(out_dir, recursive = TRUE)
}

cache_path <- file.path(raw_dir, "enpg_design_waves_2012_2024_list.RDS")

to_numeric <- function(x) {
  # haven_labelled vectors should be stripped before arithmetic or comparisons.
  suppressWarnings(as.numeric(haven::zap_labels(x)))
}

first_existing <- function(data, candidates) {
  hit <- candidates[candidates %in% names(data)]
  if (length(hit) == 0L) {
    return(NA_character_)
  }
  hit[[1L]]
}

find_commune_var <- function(data) {
  # Some public files use accented names, mixed case, or old p/c prefixes.
  # Prefer a numeric commune code when it exists, because the region can then
  # be reconstructed as floor(commune_code / 1000).
  candidates <- names(data)[
    grepl("comuna|codcom|pcodcom|COD_COMUNA", names(data), ignore.case = TRUE)
  ]
  if (length(candidates) == 0L) {
    return(NA_character_)
  }

  numeric_candidates <- candidates[vapply(candidates, function(v) {
    z <- to_numeric(data[[v]])
    any(!is.na(z)) && stats::median(z, na.rm = TRUE) >= 1000
  }, logical(1))]
  if (length(numeric_candidates) > 0L) {
    return(numeric_candidates[[1L]])
  }

  candidates[[1L]]
}

region_from_commune <- function(x) {
  z <- to_numeric(x)
  out <- rep(NA_real_, length(z))
  out[!is.na(z)] <- floor(z[!is.na(z)] / 1000)
  out
}

build_key <- function(data, vars) {
  # Build a stable key from one or more columns. This prevents accidental
  # collisions when a PSU code is only unique within commune or region.
  if (length(vars) == 0L) {
    return(rep(NA_character_, nrow(data)))
  }

  pieces <- lapply(vars, function(v) {
    if (identical(v, "commune_auto")) {
      return(as.character(data$commune_auto))
    }
    if (identical(v, "region_auto")) {
      return(as.character(data$region_auto))
    }
    as.character(haven::zap_labels(data[[v]]))
  })
  as.character(do.call(interaction, c(pieces, list(drop = TRUE, lex.order = TRUE))))
}

make_current_month <- function(data, lifetime_var, last_var) {
  # Binary prevalence: consumed alcohol during the last 30 days.
  # The value 1 in the "last use" question means "during the last 30 days".
  lifetime <- if (!is.na(lifetime_var) && lifetime_var %in% names(data)) {
    to_numeric(data[[lifetime_var]])
  } else {
    rep(NA_real_, nrow(data))
  }
  last_use <- to_numeric(data[[last_var]])

  out <- rep(NA_real_, nrow(data))
  out[last_use == 1] <- 1
  out[last_use %in% c(2, 3)] <- 0
  out[is.na(last_use) & lifetime == 2] <- 0
  out
}

make_ever_drinker <- function(data, lifetime_var) {
  # Binary prevalence: ever drank alcohol. Values 88/99 and equivalent
  # nonresponse codes are left as missing by construction.
  if (is.na(lifetime_var) || !lifetime_var %in% names(data)) {
    return(rep(NA_real_, nrow(data)))
  }
  z <- to_numeric(data[[lifetime_var]])
  out <- rep(NA_real_, nrow(data))
  out[z == 1] <- 1
  out[z == 2] <- 0
  out
}

make_hed_frequency_any <- function(data, hed_var, zero_values, positive_values) {
  # Binary HED measure from the frequency item: any 6+ drink occasion versus
  # never. The coding differs in 2018, so zero and positive values are passed
  # explicitly through the wave specification.
  if (is.null(hed_var) || is.na(hed_var) || !hed_var %in% names(data)) {
    return(rep(NA_real_, nrow(data)))
  }

  z <- to_numeric(data[[hed_var]])
  out <- rep(NA_real_, nrow(data))
  out[z %in% zero_values] <- 0
  out[z %in% positive_values] <- 1
  out
}

make_max_drinks_6plus <- function(data, max_drinks_var) {
  # Binary HED measure from the maximum number of drinks in the last 30 days.
  # This item is not available in all later public files, so missing variables
  # produce an all-NA column rather than a failed run.
  if (is.null(max_drinks_var) || is.na(max_drinks_var) || !max_drinks_var %in% names(data)) {
    return(rep(NA_real_, nrow(data)))
  }

  z <- to_numeric(data[[max_drinks_var]])
  out <- rep(NA_real_, nrow(data))
  valid <- !is.na(z) & z >= 0 & z < 88
  out[valid] <- as.numeric(z[valid] >= 6)
  out
}

read_wave_file <- function(spec) {
  path <- file.path(raw_dir, spec$file)
  if (!file.exists(path)) {
    stop("Missing file for ENPG ", spec$year, ": ", path, call. = FALSE)
  }

  data <- if (identical(spec$reader, "rds")) {
    readRDS(path)
  } else {
    haven::read_dta(path)
  }
  as.data.frame(data)
}

build_wave_cache <- function(specs, cache_path) {
  # The cache is a named list so later runs do not need to repeatedly parse
  # large Stata files. It intentionally excludes 2008 and 2010.
  waves <- list()
  metadata <- data.frame(
    year = integer(),
    source_file = character(),
    source_reader = character(),
    rows = integer(),
    columns = integer(),
    stringsAsFactors = FALSE
  )

  for (spec in specs) {
    message("Caching ENPG ", spec$year, " from ", spec$file)
    data <- read_wave_file(spec)

    if (identical(spec$year, 2016L)) {
      # The 2016 public general file does not carry the expansion factor in the
      # same file. Merge it once here so the cached wave is analysis-ready.
      expansion_path <- file.path(raw_dir, "enpg16_factoresdeexpansion.dta")
      expansion <- as.data.frame(haven::read_dta(expansion_path))
      expansion <- expansion[, c("idencuesta", "Fexp"), drop = FALSE]
      data <- merge(data, expansion, by = "idencuesta", all.x = TRUE, sort = FALSE)
    }

    waves[[as.character(spec$year)]] <- data
    metadata <- rbind(
      metadata,
      data.frame(
        year = spec$year,
        source_file = spec$file,
        source_reader = spec$reader,
        rows = nrow(data),
        columns = ncol(data),
        stringsAsFactors = FALSE
      )
    )
  }

  cache <- list(
    created_at = format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"),
    excluded_years = c(2008L, 2010L),
    raw_dir = raw_dir,
    waves = waves,
    metadata = metadata
  )
  # Write the cache without compression. This is larger, but it avoids leaving
  # a fragile compressed RDS when the source objects include very large labelled
  # vectors and one source RDS already emits a compression warning on read.
  saveRDS(cache, cache_path, compress = FALSE)
  invisible(readRDS(cache_path))
  cache
}

prepare_design_data <- function(data, spec) {
  # Add harmonized design and alcohol-prevalence columns used by the design
  # checks. The original raw columns are left untouched.
  commune_var <- if (!is.null(spec$commune_var) && !is.na(spec$commune_var)) {
    spec$commune_var
  } else {
    find_commune_var(data)
  }

  region_var <- first_existing(data, spec$region_candidates)
  if (!is.na(region_var)) {
    data$region_auto <- to_numeric(data[[region_var]])
  } else if (!is.na(commune_var)) {
    data$region_auto <- region_from_commune(data[[commune_var]])
  } else {
    data$region_auto <- NA_real_
  }

  if (!is.na(commune_var)) {
    data$commune_auto <- as.character(haven::zap_labels(data[[commune_var]]))
  } else {
    data$commune_auto <- as.character(data$region_auto)
  }

  data$design_weight <- to_numeric(data[[spec$weight_var]])
  data$ever_drinker <- make_ever_drinker(data, spec$lifetime_var)
  data$current_month <- make_current_month(data, spec$lifetime_var, spec$last_var)
  data$hed_frequency_any <- make_hed_frequency_any(
    data,
    spec$hed_frequency_var,
    spec$hed_frequency_zero,
    spec$hed_frequency_positive
  )
  data$max_drinks_6plus_30d <- make_max_drinks_6plus(data, spec$max_drinks_var)

  data
}

icc_oneway <- function(y, cluster) {
  # Simple unweighted ICC used only as a descriptive clustering diagnostic.
  ok <- !is.na(y) & !is.na(cluster)
  y <- y[ok]
  cluster <- droplevels(as.factor(cluster[ok]))

  if (length(y) < 2L || length(unique(cluster)) < 2L) {
    return(NA_real_)
  }

  n_i <- as.numeric(table(cluster))
  if (all(n_i <= 1L)) {
    return(NA_real_)
  }

  grand_mean <- mean(y)
  cluster_mean <- stats::ave(y, cluster, FUN = mean)
  ss_between <- sum(n_i * (tapply(y, cluster, mean) - grand_mean)^2)
  ss_within <- sum((y - cluster_mean)^2)
  df_between <- length(n_i) - 1
  df_within <- length(y) - length(n_i)

  if (df_between <= 0L || df_within <= 0L) {
    return(NA_real_)
  }

  ms_between <- ss_between / df_between
  ms_within <- ss_within / df_within
  k_bar <- (length(y) - sum(n_i^2) / length(y)) / df_between
  icc <- (ms_between - ms_within) / (ms_between + (k_bar - 1) * ms_within)
  max(min(icc, 1), -1)
}

summarise_structure <- function(data, spec) {
  # Structure is always summarized with REGION as the stratum because this is
  # the granularity used to carry the residual factor back to older waves.
  data$design_psu <- build_key(data, spec$psu_vars)
  data$design_strata <- as.character(data$region_auto)

  ok_vars <- c("design_weight", "design_strata")
  if (length(spec$psu_vars) > 0L) {
    ok_vars <- c(ok_vars, "design_psu")
  }

  ok <- stats::complete.cases(data[, ok_vars, drop = FALSE]) & data$design_weight > 0
  d <- data[ok, , drop = FALSE]

  if (length(spec$psu_vars) == 0L) {
    return(data.frame(
      year = spec$year,
      design_label = "REGION only - no validated PSU",
      n = nrow(d),
      n_strata = length(unique(d$design_strata)),
      n_psu = NA_integer_,
      lonely_strata = NA_integer_,
      psu_cross_strata = NA_integer_,
      persons_per_psu_median = NA_real_,
      persons_per_psu_mean = NA_real_,
      persons_per_psu_max = NA_real_,
      stringsAsFactors = FALSE
    ))
  }

  cluster_sizes <- as.numeric(table(d$design_psu))
  strata_psu <- unique(d[, c("design_strata", "design_psu"), drop = FALSE])
  psu_by_strata <- table(strata_psu$design_strata)
  strata_by_psu <- table(strata_psu$design_psu)

  data.frame(
    year = spec$year,
    design_label = "PSU + REGION",
    n = nrow(d),
    n_strata = length(unique(d$design_strata)),
    n_psu = length(cluster_sizes),
    lonely_strata = sum(psu_by_strata == 1L),
    psu_cross_strata = sum(strata_by_psu > 1L),
    persons_per_psu_median = stats::median(cluster_sizes),
    persons_per_psu_mean = mean(cluster_sizes),
    persons_per_psu_max = max(cluster_sizes),
    stringsAsFactors = FALSE
  )
}

estimate_variable_factor <- function(data, spec, variable_name) {
  # The additional factor is:
  #
  #   factor_additional = (SE_design / SE_kish)^2
  #
  # where SE_design uses PSU + REGION, and SE_kish uses only the Kish effective
  # sample size from weights. This isolates the residual clustering component.
  data$design_psu <- build_key(data, spec$psu_vars)
  data$design_strata <- as.character(data$region_auto)
  data$y <- data[[variable_name]]

  ok <- stats::complete.cases(
    data[, c("y", "design_weight", "design_strata"), drop = FALSE]
  ) & data$design_weight > 0
  if (length(spec$psu_vars) > 0L) {
    ok <- ok & !is.na(data$design_psu)
  }
  d <- data[ok, , drop = FALSE]

  blank_result <- function() {
    data.frame(
      year = spec$year,
      variable = variable_name,
      design_label = if (length(spec$psu_vars) > 0L) "PSU + REGION" else "REGION only - no validated PSU",
      has_validated_psu = length(spec$psu_vars) > 0L,
      n = nrow(d),
      weighted_n = if (nrow(d) > 0L) sum(d$design_weight) else NA_real_,
      prevalence = NA_real_,
      neff_kish = NA_real_,
      deff_weights = NA_real_,
      se_design = NA_real_,
      se_kish = NA_real_,
      factor_additional = NA_real_,
      icc_unweighted = NA_real_,
      stringsAsFactors = FALSE
    )
  }

  if (nrow(d) < 2L || length(unique(d$y)) < 2L) {
    return(blank_result())
  }

  neff <- sum(d$design_weight)^2 / sum(d$design_weight^2)
  p <- sum(d$y * d$design_weight) / sum(d$design_weight)
  se_kish <- sqrt(p * (1 - p) / neff)

  if (length(spec$psu_vars) == 0L) {
    out <- blank_result()
    out$prevalence <- p
    out$neff_kish <- neff
    out$deff_weights <- nrow(d) / neff
    out$se_kish <- se_kish
    return(out)
  }

  design_data <- d[, c("y", "design_psu", "design_strata", "design_weight"), drop = FALSE]
  design <- survey::svydesign(
    ids = stats::as.formula("~design_psu"),
    strata = stats::as.formula("~design_strata"),
    weights = stats::as.formula("~design_weight"),
    data = design_data,
    nest = TRUE
  )
  mean_obj <- survey::svymean(stats::as.formula("~y"), design)
  se_design <- as.numeric(survey::SE(mean_obj))

  data.frame(
    year = spec$year,
    variable = variable_name,
    design_label = "PSU + REGION",
    has_validated_psu = TRUE,
    n = nrow(d),
    weighted_n = sum(d$design_weight),
    prevalence = as.numeric(stats::coef(mean_obj)),
    neff_kish = neff,
    deff_weights = nrow(d) / neff,
    se_design = se_design,
    se_kish = se_kish,
    factor_additional = (se_design / se_kish)^2,
    icc_unweighted = icc_oneway(d$y, d$design_psu),
    stringsAsFactors = FALSE
  )
}

make_calibration_table <- function(factor_out) {
  # The applied calibration comes from 2022 and 2024 only, with REGION strata.
  # The "current_month" row should reproduce the original ~1.35 result.
  ref <- factor_out[
    factor_out$year %in% c(2022L, 2024L) &
      factor_out$has_validated_psu &
      is.finite(factor_out$factor_additional),
    ,
    drop = FALSE
  ]

  rows <- lapply(split(ref, ref$variable), function(d) {
    data.frame(
      variable = d$variable[[1L]],
      calibration_years = paste(d$year, collapse = ","),
      n_years = nrow(d),
      factor_mean_2022_2024_region = mean(d$factor_additional),
      factor_median_2022_2024_region = stats::median(d$factor_additional),
      factor_min_2022_2024_region = min(d$factor_additional),
      factor_max_2022_2024_region = max(d$factor_additional),
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

wave_specs <- list(
  list(
    year = 2012L,
    reader = "dta",
    file = "Base de datos ENPG 2012 (PG).DTA.dta",
    psu_vars = c("commune_auto", "manzana"),
    weight_var = "PONDERADOR",
    region_candidates = character(0),
    commune_var = NA_character_,
    lifetime_var = "p10",
    last_var = "p13",
    hed_frequency_var = "p21",
    hed_frequency_zero = 0,
    hed_frequency_positive = 1:4,
    max_drinks_var = "p17"
  ),
  list(
    year = 2014L,
    reader = "dta",
    file = "Base de datos ENPG 2014 (PG).DTA.dta",
    psu_vars = c("commune_auto", "Segmento_n"),
    weight_var = "F2_MAY_AJUS_com",
    region_candidates = c("Region"),
    commune_var = "Comuna",
    lifetime_var = "oh1",
    last_var = "oh4",
    hed_frequency_var = "oh12",
    hed_frequency_zero = 0,
    hed_frequency_positive = 1:4,
    max_drinks_var = "oh8"
  ),
  list(
    year = 2016L,
    reader = "dta",
    file = "base ENPG 2016 publico general.dta",
    psu_vars = c("commune_auto", "manzana"),
    weight_var = "Fexp",
    region_candidates = character(0),
    commune_var = "comuna",
    lifetime_var = "oh_1",
    last_var = "oh_4",
    hed_frequency_var = "oh_16",
    hed_frequency_zero = 0,
    hed_frequency_positive = 1:4,
    max_drinks_var = "oh_8"
  ),
  list(
    year = 2018L,
    reader = "dta",
    file = "Base de datos ENPG 2018 (PG).DTA",
    psu_vars = c("commune_auto", "idmanzana"),
    weight_var = "Fexp",
    region_candidates = c("Region"),
    commune_var = "comuna",
    lifetime_var = "OH_1",
    last_var = "OH_4",
    hed_frequency_var = "OH_14",
    hed_frequency_zero = 1,
    hed_frequency_positive = 2:5,
    max_drinks_var = "OH_8"
  ),
  list(
    year = 2020L,
    reader = "rds",
    file = "enpg2020.RDS",
    psu_vars = character(0),
    weight_var = "FACT_PERS_COMUNA",
    region_candidates = c("REGION"),
    commune_var = "Nom_comuna",
    lifetime_var = "OH_1",
    last_var = "OH_4",
    hed_frequency_var = "OH_10",
    hed_frequency_zero = 0,
    hed_frequency_positive = 1:4,
    max_drinks_var = NA_character_
  ),
  list(
    year = 2022L,
    reader = "rds",
    file = "enpg2022.RDS",
    psu_vars = c("commune_auto", "UPM"),
    weight_var = "FACTOR_EXPANSION",
    region_candidates = c("REGION"),
    commune_var = "COD_COMUNA",
    lifetime_var = "OH_1",
    last_var = "OH_4",
    hed_frequency_var = "OH_10",
    hed_frequency_zero = 0,
    hed_frequency_positive = 1:4,
    max_drinks_var = NA_character_
  ),
  list(
    year = 2024L,
    reader = "dta",
    file = "Base Publica ENPG 2024 (Stata 16).dta",
    psu_vars = c("commune_auto", "UPM"),
    weight_var = "FACTOR_EXPANSION",
    region_candidates = c("REGION"),
    commune_var = "COD_COMUNA",
    lifetime_var = "OH_1",
    last_var = "OH_4",
    hed_frequency_var = "OH_10",
    hed_frequency_zero = 0,
    hed_frequency_positive = 1:4,
    max_drinks_var = NA_character_
  )
)

message("Building cached ENPG list in the raw-data folder.")
wave_cache <- build_wave_cache(wave_specs, cache_path)

variables_to_check <- c(
  "ever_drinker",
  "current_month",
  "hed_frequency_any",
  "max_drinks_6plus_30d"
)

structure_rows <- list()
factor_rows <- list()

for (spec in wave_specs) {
  message("Evaluating ENPG ", spec$year, " with REGION-level strata.")
  data <- wave_cache$waves[[as.character(spec$year)]]
  data <- prepare_design_data(data, spec)

  structure_rows[[length(structure_rows) + 1L]] <- summarise_structure(data, spec)

  for (variable_name in variables_to_check) {
    factor_rows[[length(factor_rows) + 1L]] <- estimate_variable_factor(
      data,
      spec,
      variable_name
    )
  }
}

structure_out <- do.call(rbind, structure_rows)
factor_out <- do.call(rbind, factor_rows)
calibration_out <- make_calibration_table(factor_out)

factor_out <- merge(
  factor_out,
  calibration_out[, c("variable", "factor_mean_2022_2024_region"), drop = FALSE],
  by = "variable",
  all.x = TRUE,
  sort = FALSE
)
names(factor_out)[names(factor_out) == "factor_mean_2022_2024_region"] <-
  "applied_region_factor_from_2022_2024"

numeric_cols_structure <- vapply(structure_out, is.numeric, logical(1))
structure_out[numeric_cols_structure] <- lapply(
  structure_out[numeric_cols_structure],
  function(x) round(x, 4)
)

numeric_cols_factors <- vapply(factor_out, is.numeric, logical(1))
factor_out[numeric_cols_factors] <- lapply(
  factor_out[numeric_cols_factors],
  function(x) round(x, 6)
)

numeric_cols_calibration <- vapply(calibration_out, is.numeric, logical(1))
calibration_out[numeric_cols_calibration] <- lapply(
  calibration_out[numeric_cols_calibration],
  function(x) round(x, 6)
)

structure_path <- file.path(out_dir, "enpg_cluster_structure.csv")
factor_path <- file.path(out_dir, "enpg_cluster_factors.csv")
calibration_path <- file.path(out_dir, "enpg_region_factor_calibration.csv")

utils::write.csv(structure_out, structure_path, row.names = FALSE, fileEncoding = "UTF-8")
utils::write.csv(factor_out, factor_path, row.names = FALSE, fileEncoding = "UTF-8")
utils::write.csv(calibration_out, calibration_path, row.names = FALSE, fileEncoding = "UTF-8")

message("\nCached wave list:")
print(wave_cache$metadata)

message("\nREGION-level cluster structure:")
print(structure_out)

message("\nPer-year and per-variable diagnostics:")
print(factor_out)

message("\nApplied REGION-level calibration from 2022 and 2024:")
print(calibration_out)

elapsed <- as.numeric(difftime(Sys.time(), .t0, units = "mins"))
message(sprintf("\nElapsed time: %.2f minutes", elapsed))
message("Wrote: ", cache_path)
message("Wrote: ", structure_path)
message("Wrote: ", factor_path)
message("Wrote: ", calibration_path)
