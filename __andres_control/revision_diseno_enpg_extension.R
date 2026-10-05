###############################################################################
# revision_diseno_enpg_extension.R
#
# Advanced ENPG design extension for PIF/AAF uncertainty.
#
# What this file does
# -------------------
# 1. Reads a lightweight ENPG design cache created by:
#      __andres_control/build_enpg_design_waves_2012_2024_list.R
#
# 2. Joins that cache back to ENPG_BINGE.RDS by year and respondent ID.
#
# 3. Derives the PIF/AAF-relevant alcohol variables:
#      abs         : lifetime abstainer indicator.
#      form        : former drinker indicator.
#      hed         : HED among current drinkers.
#      consumption : mean daily alcohol grams from the CHMS-calibrated variable.
#
# 4. Estimates, where possible, a cell-specific residual clustering factor:
#      factor = (SE_survey_design / SE_Kish_only)^2
#
#    The cell is:
#      year x age_group x sex x variable
#
#    The survey design is:
#      PSU + REGION
#
#    This is deliberately REGION-level stratification. REGION is the comparable
#    stratum used in the older-wave workflow. The 2024 ESTRATO design is not
#    used here because the goal is a cell-specific replacement for the older
#    REGION-level approximation, not a separate official-2024-only design.
#
# What is and is not possible
# ---------------------------
# It is possible to estimate own clustering factors by year, variable, age tramo,
# and sex for waves with a validated PSU in the available files:
#   2012, 2014, 2016, 2018, 2022, 2024.
#
# It is not possible from the current public 2020 RDS because there is no
# validated PSU identifier exposed in the microdata. This does not mean that
# the 2020 field design had no clustering; the public report describes a
# clustered sample frame. It means that the available RDS only exposes
# "seccion", which is too coarse to treat as a validated PSU without additional
# documentation or a true manzana/conglomerate identifier.
#
# Outputs
# -------
# __andres_control/enpg_design_join_audit.csv
# __andres_control/enpg_cluster_factors_by_year_variable_tramo.csv
# __andres_control/enpg_design_table_cells_extension.csv
#
# No notebooks or Quarto files are edited by this script.
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

if (!exists("acc_root")) source(here::here("_tools", "acc_data.R"))
repo_root <- acc_root()

control_dir <- file.path(repo_root, "__andres_control")
# Design cache and ENPG_BINGE.RDS come from the encrypted ENPG bundle (derived/ folder).
cache_path <- acc_data("_enpg/enpg.tar.xz.enc", "derived/enpg_design_waves_2012_2024_list.RDS")
binge_path <- acc_data("_enpg/enpg.tar.xz.enc", "derived/ENPG_BINGE.RDS")

if (!file.exists(cache_path)) {
  stop(
    "Missing lightweight ENPG design cache: ", cache_path, "\n",
    "Run __andres_control/build_enpg_design_waves_2012_2024_list.R first.",
    call. = FALSE
  )
}
if (!file.exists(binge_path)) {
  stop("Missing ENPG_BINGE.RDS: ", binge_path, call. = FALSE)
}

to_numeric <- function(x) {
  suppressWarnings(as.numeric(haven::zap_labels(x)))
}

weighted_var <- function(x, w) {
  ok <- is.finite(x) & is.finite(w) & w > 0
  x <- x[ok]
  w <- w[ok]
  if (length(x) < 2L || sum(w) <= 0) {
    return(NA_real_)
  }
  mu <- sum(w * x) / sum(w)
  sum(w * (x - mu)^2) / sum(w)
}

make_age_group <- function(age) {
  # Exposure convention used by the notebook objects:
  #   1 = 15-29, 2 = 30-44, 3 = 45-59, 4 = 60-65.
  out <- rep(NA_integer_, length(age))
  out[age >= 15 & age <= 29] <- 1L
  out[age >= 30 & age <= 44] <- 2L
  out[age >= 45 & age <= 59] <- 3L
  out[age >= 60 & age <= 65] <- 4L
  out
}

age_group_label <- function(age_group) {
  c("1" = "15-29", "2" = "30-44", "3" = "45-59", "4" = "60-65")[
    as.character(age_group)
  ]
}

make_psu_key <- function(year, commune, psu) {
  # PSU codes can repeat across communes and waves. Keep the key conservative.
  paste(year, commune, psu, sep = "|")
}

collapse_design_cache <- function(cache) {
  rows <- lapply(cache$waves, function(wave) {
    keep <- c(
      "year", "id_join", "weight", "region", "commune", "psu",
      "psu_validated", "psu_source"
    )
    missing <- setdiff(keep, names(wave))
    if (length(missing) > 0L) {
      stop("Cached wave is missing columns: ", paste(missing, collapse = ", "))
    }
    wave[, keep, drop = FALSE]
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out$id_join <- as.character(out$id_join)
  out$year <- as.integer(out$year)
  out$weight <- as.numeric(out$weight)
  out$region <- as.character(out$region)
  out$commune <- as.character(out$commune)
  out$psu <- as.character(out$psu)
  out$psu_validated <- as.logical(out$psu_validated)
  out
}

audit_join <- function(data) {
  years <- sort(unique(data$year))
  rows <- lapply(years, function(y) {
    d <- data[data$year == y, , drop = FALSE]
    data.frame(
      year = y,
      rows = nrow(d),
      matched_design = sum(!is.na(d$weight)),
      unmatched_design = sum(is.na(d$weight)),
      match_rate = mean(!is.na(d$weight)),
      validated_psu_rows = sum((d$psu_validated %in% TRUE) & !is.na(d$psu)),
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

conversion <- function(x, vol) {
  # Conversion factor sent by ACC and used in expand_pif.ipynb.
  vol_oms <- x * 0.8
  oms <- round((vol_oms * 0.789) * 1000, 2)
  oms / vol
}

derive_alcohol_variables <- function(data) {
  # This block mirrors the existing PIF/AAF alcohol derivation, but keeps the
  # survey design fields attached. Non-current drinkers keep missing consumption
  # means, while abstainer/former indicators remain defined.
  data$db_num <- to_numeric(data$db)
  data$db_num[data$db_num >= 88] <- NA_real_

  data$oh3_num <- to_numeric(data$oh3)
  data$oh3_num[data$oh3_num %in% c(88, 99)] <- NA_real_

  data$current_drinker <- !is.na(data$oh2) & data$oh2 == "30 dias"
  data$abstainer <- !is.na(data$oh1) & data$oh1 == "No"
  data$former_drinker <- !is.na(data$oh1) & data$oh1 == "Si" & !data$current_drinker

  data$oh3_clean <- data$oh3_num
  data$oh3_clean[!data$current_drinker] <- 0

  data$prom_tragos <- NA_real_
  data$prom_tragos[!data$current_drinker | data$abstainer] <- 0
  data$prom_tragos[data$audit2 == "0-2"] <- 1
  data$prom_tragos[data$audit2 == "3-4"] <- 3.5
  data$prom_tragos[data$audit2 == "5-6"] <- 5.5
  data$prom_tragos[data$audit2 == "7-8"] <- 7.5
  data$prom_tragos[data$audit2 == "9 o mas"] <- 9

  data$diasalchab <- pmax(data$oh3_clean - data$db_num, 0)
  data$volalchab <- data$diasalchab * data$prom_tragos
  data$volbinge <- ifelse(data$sexo == "Hombre", data$db_num * 5, data$db_num * 4)
  data$voltotMS <- (data$volbinge + data$volalchab) * 15.7
  data$voltotMINSAL <- data$voltotMS / 30
  data$volCHMS <- data$voltotMINSAL * 365

  data$analysis_weight <- ifelse(is.finite(data$weight) & data$weight > 0, data$weight, data$exp)

  pc_by_year <- tapply(seq_len(nrow(data)), data$year, function(idx) {
    d <- data[idx, , drop = FALSE]
    ok <- is.finite(d$volCHMS) & is.finite(d$analysis_weight) &
      d$analysis_weight > 0 & d$oh3_clean <= 30
    if (!any(ok)) {
      return(NA_real_)
    }
    sum(d$volCHMS[ok] * d$analysis_weight[ok]) / sum(d$analysis_weight[ok])
  })

  data$pc_totalvolCHMS <- as.numeric(pc_by_year[as.character(data$year)])
  data$volajms <- data$volCHMS * conversion(7.9, data$pc_totalvolCHMS)
  data$volajohdiams <- data$volajms / 365

  data$cvolajms <- NA_character_
  data$cvolajms[data$abstainer] <- "ltabs"
  data$cvolajms[data$former_drinker] <- "fd"

  female <- data$sexo == "Mujer"
  male <- data$sexo == "Hombre"
  v <- data$volajohdiams

  data$cvolajms[female & v > 0 & v <= 19.99] <- "cat1"
  data$cvolajms[female & v >= 20 & v <= 39.99] <- "cat2"
  data$cvolajms[female & v >= 40 & v <= 100] <- "cat3"
  data$cvolajms[female & v > 100] <- "cat4"
  data$cvolajms[male & v > 0 & v <= 39.99] <- "cat1"
  data$cvolajms[male & v >= 40 & v <= 59.99] <- "cat2"
  data$cvolajms[male & v >= 60 & v <= 100] <- "cat3"
  data$cvolajms[male & v > 100] <- "cat4"

  data$abs <- as.integer(data$cvolajms == "ltabs")
  data$form <- as.integer(data$cvolajms == "fd")
  data$hed <- ifelse(data$current_drinker & !is.na(data$db_num), as.integer(data$db_num > 0), NA_integer_)
  data$consumption <- data$volajohdiams

  data$age_group <- make_age_group(as.numeric(data$edad))
  data$age_group_label <- age_group_label(data$age_group)
  data$sex <- ifelse(data$sexo == "Hombre", "male", ifelse(data$sexo == "Mujer", "female", NA_character_))
  data$psu_key <- make_psu_key(data$year, data$commune, data$psu)
  data
}

cell_design_stats <- function(data) {
  if (nrow(data) == 0L || !any(data$psu_validated)) {
    return(list(n_psu = NA_integer_, n_strata = NA_integer_, lonely_strata = NA_integer_))
  }
  psu_by_stratum <- unique(data[, c("region", "psu_key"), drop = FALSE])
  n_by_stratum <- table(psu_by_stratum$region)
  list(
    n_psu = length(unique(data$psu_key)),
    n_strata = length(unique(data$region)),
    lonely_strata = sum(n_by_stratum == 1L)
  )
}

estimate_cell_factor <- function(data, variable, y_col, kind) {
  y <- as.numeric(data[[y_col]])
  w <- as.numeric(data$analysis_weight)
  ok <- is.finite(y) & is.finite(w) & w > 0 & !is.na(data$year) &
    !is.na(data$age_group) & !is.na(data$sex)
  d <- data[ok, , drop = FALSE]
  y <- y[ok]
  w <- w[ok]

  stats <- cell_design_stats(d)
  n <- nrow(d)
  weighted_n <- if (n > 0L) sum(w) else NA_real_
  neff_kish <- if (n > 0L) sum(w)^2 / sum(w^2) else NA_real_

  prevalence_or_mean <- NA_real_
  se_kish <- NA_real_
  factor_additional <- NA_real_
  se_design <- NA_real_
  factor_source <- "not_estimated"

  if (n < 2L || !is.finite(neff_kish) || neff_kish <= 0) {
    factor_source <- "insufficient_complete_cases"
  } else {
    prevalence_or_mean <- sum(y * w) / sum(w)
    if (identical(kind, "mean")) {
      se_kish <- sqrt(weighted_var(y, w) / neff_kish)
    } else {
      se_kish <- sqrt(prevalence_or_mean * (1 - prevalence_or_mean) / neff_kish)
    }

    has_design <- all(d$psu_validated) && all(!is.na(d$psu_key)) && all(!is.na(d$region))
    has_variation <- length(unique(y)) > 1L && is.finite(se_kish) && se_kish > 0

    if (!has_design) {
      factor_source <- "no_validated_psu_for_year"
    } else if (!has_variation) {
      factor_source <- "no_variation_in_cell"
    } else if (length(unique(d$psu_key)) < 2L) {
      factor_source <- "less_than_two_psu"
    } else {
      design_data <- data.frame(
        y = y,
        design_weight = w,
        design_psu = d$psu_key,
        design_strata = d$region
      )
      design_result <- tryCatch({
        design <- survey::svydesign(
          ids = stats::as.formula("~design_psu"),
          strata = stats::as.formula("~design_strata"),
          weights = stats::as.formula("~design_weight"),
          data = design_data,
          nest = TRUE
        )
        mean_obj <- survey::svymean(stats::as.formula("~y"), design)
        as.numeric(survey::SE(mean_obj))
      }, error = function(e) NA_real_)

      se_design <- design_result
      if (is.finite(se_design) && se_design >= 0) {
        factor_additional <- (se_design / se_kish)^2
        factor_source <- "cell_specific_psu_region"
      } else {
        factor_source <- "survey_estimation_failed"
      }
    }
  }

  data.frame(
    variable = variable,
    n = n,
    weighted_n = weighted_n,
    n_psu = stats$n_psu,
    n_strata = stats$n_strata,
    lonely_strata = stats$lonely_strata,
    estimate = prevalence_or_mean,
    neff_kish = neff_kish,
    se_design = se_design,
    se_kish = se_kish,
    factor_additional = factor_additional,
    factor_source = factor_source,
    stringsAsFactors = FALSE
  )
}

estimate_all_cells <- function(data, variable_specs) {
  cell_keys <- unique(data[!is.na(data$age_group) & !is.na(data$sex),
                           c("year", "age_group", "age_group_label", "sex"),
                           drop = FALSE])
  cell_keys <- cell_keys[order(cell_keys$year, cell_keys$sex, cell_keys$age_group), ]

  rows <- list()
  for (i in seq_len(nrow(cell_keys))) {
    key <- cell_keys[i, , drop = FALSE]
    cell_data <- data[
      data$year == key$year &
        data$age_group == key$age_group &
        data$sex == key$sex,
      ,
      drop = FALSE
    ]

    for (j in seq_len(nrow(variable_specs))) {
      v <- variable_specs[j, , drop = FALSE]
      res <- estimate_cell_factor(cell_data, v$variable, v$column, v$kind)
      rows[[length(rows) + 1L]] <- cbind(key, res)
    }
  }

  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

add_engine_fallback <- function(cell_factors) {
  # Strict factor_additional is the own cell-specific estimate. The engine column
  # fills only cells where strict estimation is impossible, mainly 2020.
  #
  # Primary fallback rule:
  #   use the closest following wave with a validated factor for the same
  #   variable x age_group x sex cell. For the current data this means that
  #   2020 borrows 2022 within the same cell.
  #
  # Secondary fallback rule:
  #   if no following validated year exists, use the median validated factor
  #   for the same variable. This keeps the output usable while making the
  #   source flag explicit.
  fallback <- stats::aggregate(
    factor_additional ~ variable,
    data = cell_factors[is.finite(cell_factors$factor_additional), , drop = FALSE],
    FUN = stats::median
  )
  names(fallback)[names(fallback) == "factor_additional"] <- "fallback_factor_median_validated_cells"
  out <- merge(cell_factors, fallback, by = "variable", all.x = TRUE, sort = FALSE)

  out$fallback_next_valid_year <- NA_integer_
  out$fallback_factor_next_valid_year <- NA_real_
  missing_strict <- !is.finite(out$factor_additional)

  for (i in which(missing_strict)) {
    same_cell <- out[
      out$variable == out$variable[i] &
        out$age_group == out$age_group[i] &
        out$sex == out$sex[i] &
        out$year > out$year[i] &
        is.finite(out$factor_additional),
      ,
      drop = FALSE
    ]

    if (nrow(same_cell) > 0L) {
      same_cell <- same_cell[order(same_cell$year), , drop = FALSE]
      out$fallback_next_valid_year[i] <- same_cell$year[[1L]]
      out$fallback_factor_next_valid_year[i] <- same_cell$factor_additional[[1L]]
    }
  }

  out$factor_for_engine <- out$factor_additional
  missing_factor <- !is.finite(out$factor_for_engine)
  has_next_year <- missing_factor & is.finite(out$fallback_factor_next_valid_year)
  out$factor_for_engine[has_next_year] <- out$fallback_factor_next_valid_year[has_next_year]

  still_missing <- !is.finite(out$factor_for_engine)
  out$factor_for_engine[still_missing] <- out$fallback_factor_median_validated_cells[still_missing]
  out$factor_for_engine_source <- ifelse(
    is.finite(out$factor_additional),
    "own_cell_specific",
    ifelse(
      has_next_year,
      "fallback_next_valid_year_same_cell",
      "fallback_median_validated_cells_same_variable"
    )
  )
  out$neff_corr_strict <- out$neff_kish / out$factor_additional
  out$neff_corr_engine <- out$neff_kish / out$factor_for_engine
  out
}

design_table_to_engine_lists <- function(tbl = design_table_cells, neff_default = 1000, factor_default = 1) {
  # Return objects compatible with aaf_unified.R. The design_factor function
  # returns a per-question list(abs, form, hed) for each cell. This is what lets
  # aaf_unified use different clustering factors by year, tramo, sex, and
  # prevalence variable.
  key <- paste(tbl$year, tbl$age_group, tbl$sex, tbl$variable, sep = "|")
  neff_map <- stats::setNames(tbl$neff_kish, key)
  factor_map <- stats::setNames(tbl$factor_for_engine, key)

  get_value <- function(map, year, group, sex, variable, default) {
    v <- map[[paste(year, group, sex, variable, sep = "|")]]
    if (is.null(v) || !is.finite(v)) default else as.numeric(v)
  }

  neff_fun <- function(year, group, sex) {
    get_value(neff_map, year, group, sex, "abs", neff_default)
  }
  design_factor_fun <- function(year, group, sex) {
    list(
      abs = get_value(factor_map, year, group, sex, "abs", factor_default),
      form = get_value(factor_map, year, group, sex, "form", factor_default),
      hed = get_value(factor_map, year, group, sex, "hed", factor_default)
    )
  }
  neff_consumption_fun <- function(year, group, sex) {
    get_value(neff_map, year, group, sex, "consumption", neff_default)
  }
  design_factor_consumption_fun <- function(year, group, sex) {
    get_value(factor_map, year, group, sex, "consumption", factor_default)
  }

  list(
    neff = neff_fun,
    design_factor = design_factor_fun,
    neff_consumption = neff_consumption_fun,
    design_factor_consumption = design_factor_consumption_fun
  )
}

message("Reading lightweight ENPG design cache.")
design_cache <- readRDS(cache_path)
design_lookup <- collapse_design_cache(design_cache)

message("Reading ENPG_BINGE.RDS and joining design variables.")
enpg_binge <- as.data.frame(readRDS(binge_path))
enpg_binge$year <- as.integer(enpg_binge$year)
enpg_binge$id_join <- as.character(enpg_binge$id)

analysis_data <- merge(
  enpg_binge,
  design_lookup,
  by = c("year", "id_join"),
  all.x = TRUE,
  sort = FALSE
)
if ("region.y" %in% names(analysis_data)) {
  analysis_data$source_region <- analysis_data$region.x
  analysis_data$region <- analysis_data$region.y
}

join_audit <- audit_join(analysis_data)

message("Deriving alcohol variables and age/sex tramos.")
analysis_data <- derive_alcohol_variables(analysis_data)

variable_specs <- data.frame(
  variable = c("abs", "form", "hed", "consumption"),
  column = c("abs", "form", "hed", "consumption"),
  kind = c("binary", "binary", "binary", "mean"),
  stringsAsFactors = FALSE
)

message("Estimating cell-specific PSU + REGION factors where possible.")
cell_factors_strict <- estimate_all_cells(analysis_data, variable_specs)
design_table_cells <- add_engine_fallback(cell_factors_strict)

# Keep the compact variable names used by the engine, but add the exact source
# variable/expression from the exposure-preparation chunk for auditability.
variable_source_from_chunk <- c(
  abs = "cvolajms == \"ltabs\"",
  form = "cvolajms == \"fd\"",
  hed = "hed; derived as db > 0",
  consumption = "volajohdiams"
)
design_table_cells$variable_source_from_chunk <- unname(
  variable_source_from_chunk[design_table_cells$variable]
)

numeric_cols <- vapply(design_table_cells, is.numeric, logical(1))
design_table_cells[numeric_cols] <- lapply(
  design_table_cells[numeric_cols],
  function(x) round(x, 6)
)

join_audit$match_rate <- round(join_audit$match_rate, 6)

join_audit_path <- file.path(control_dir, "enpg_design_join_audit.csv")
factor_path <- file.path(control_dir, "enpg_cluster_factors_by_year_variable_tramo.csv")
engine_path <- file.path(control_dir, "enpg_design_table_cells_extension.csv")

utils::write.csv(join_audit, join_audit_path, row.names = FALSE, fileEncoding = "UTF-8")
utils::write.csv(design_table_cells, factor_path, row.names = FALSE, fileEncoding = "UTF-8")
utils::write.csv(design_table_cells, engine_path, row.names = FALSE, fileEncoding = "UTF-8")

message("\nJoin audit:")
print(join_audit)

# message("\nCell-specific clustering factors (head):")
# print(utils::head(design_table_cells, 16))

message("\nFactor source counts:")
print(table(design_table_cells$factor_source, useNA = "ifany"))
print(table(design_table_cells$factor_for_engine_source, useNA = "ifany"))

message("\nReady for aaf_unified.R:")
message("  kish <- design_table_to_engine_lists()")
message("  pass kish$neff, kish$design_factor, kish$neff_consumption,")
message("  and kish$design_factor_consumption into compute_*_aaf_from_registry().")

elapsed <- as.numeric(difftime(Sys.time(), .t0, units = "mins"))
message(sprintf("\nElapsed time: %.2f minutes", elapsed))
message("Wrote: ", join_audit_path)
message("Wrote: ", factor_path)
message("Wrote: ", engine_path)
