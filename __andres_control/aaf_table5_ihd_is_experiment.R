# =============================================================================
# Table 5 IHD/IS AAF experiment
# -----------------------------------------------------------------------------
# Purpose:
#   Re-run the unified cardiovascular AAF engine for Ischaemic Heart Disease
#   (IHD) and Ischaemic Stroke (IS), changing only the current-drinker RR curves:
#   use the Chile 2014 Table 5 sex-specific RR parameters instead of the
#   age-banded GENERAL_ihd_RR_2018_03_16.R / GENERAL_IS_RR_2018_03_16.R records.
#
# Non-disruptive design:
#   - Does not edit notebooks, Quarto files, GENERAL_*.R, or current Adam objects.
#   - Reads the latest aaf_engine_inputs_bundle_*.rds for exposure inputs.
#   - Reuses aaf_unified.R and compute_cv_aaf_from_registry().
#   - Writes dated sensitivity artifacts under __andres_control.
#   - Exposes helper functions for an explicit, local replacement of only IHD/IS.
#
# Run:
#   & 'C:\Program Files\R\R-4.4.1\bin\Rscript.exe' `
#     __andres_control\aaf_table5_ihd_is_experiment.R
#
# Optional quick smoke test without writing dated artifacts:
#   $env:AAF_TABLE5_N_SIM = "100"
#   $env:AAF_TABLE5_N_PCA = "100"
#   $env:AAF_TABLE5_AUTORUN = "false"
#   & 'C:\Program Files\R\R-4.4.1\bin\Rscript.exe' -e `
#     "source('__andres_control/aaf_table5_ihd_is_experiment.R'); run_table5_ihd_is_experiment(write_outputs = FALSE)"
#
# Notebook integration, before Figure 1 and after aaf_fem_adam/aaf_male_adam
# exist:
#   source("__andres_control/aaf_table5_ihd_is_experiment.R")
#   patched <- table5_replace_cv_rows(
#     aaf_fem = aaf_fem_adam,
#     aaf_male = aaf_male_adam,
#     table5_result = aaf_table5_result
#   )
#   aaf_fem_table5_cv <- patched$female
#   aaf_male_table5_cv <- patched$male
#   # Then point the downstream aaf_long/mortality join to these sensitivity
#   # objects if, and only if, you want the Table 5 CV sensitivity to drive figures.
# =============================================================================

.t0 <- proc.time()[["elapsed"]]

table5_elapsed_min <- function(.start = .t0) {
  round((proc.time()[["elapsed"]] - .start) / 60, 2)
}

table5_message <- function(...) {
  message(sprintf(...))
}

table5_find_control_dir <- function() {
  candidates <- unique(c(
    normalizePath(".", winslash = "/", mustWork = FALSE),
    normalizePath(file.path(".", "__andres_control"), winslash = "/", mustWork = FALSE),
    normalizePath(file.path("..", "__andres_control"), winslash = "/", mustWork = FALSE)
  ))
  hits <- candidates[file.exists(file.path(candidates, "aaf_unified.R"))]
  if (!length(hits)) {
    stop("Could not find __andres_control/aaf_unified.R from getwd(): ", getwd())
  }
  normalizePath(hits[[1L]], winslash = "/", mustWork = TRUE)
}

table5_latest_file <- function(control_dir, pattern) {
  files <- list.files(control_dir, pattern = pattern, full.names = TRUE)
  if (!length(files)) {
    stop("No files matching ", pattern, " under ", control_dir)
  }
  info <- file.info(files)
  files[order(info$mtime, decreasing = TRUE)][[1L]]
}

table5_env_int <- function(name, default) {
  value <- Sys.getenv(name, unset = NA_character_)
  if (is.na(value) || !nzchar(value)) {
    return(default)
  }
  out <- suppressWarnings(as.integer(value))
  if (!is.finite(out) || out <= 0L) {
    stop("Environment variable ", name, " must be a positive integer.")
  }
  out
}

table5_lognormal_var_from_ci <- function(lower, upper) {
  ((log(upper) - log(lower)) / (2 * stats::qnorm(0.975)))^2
}

table5_rr_ihd_male <- function(x, beta) {
  # Table 5: ln(RR) = B1 * x^0.5 + B2 * x^3.
  exp(beta[[1L]] * sqrt(x) + beta[[2L]] * x^3)
}

table5_rr_ihd_female <- function(x, beta) {
  # Table 5: ln(RR) = B1 * x + B2 * x * ln(x).
  exp(beta[[1L]] * x + beta[[2L]] * x * log(x))
}

table5_rr_is_male <- function(x, beta) {
  # Table 5: ln(RR) = B1 * x^0.5 + B2 * x^0.5 * ln(x).
  exp(beta[[1L]] * sqrt(x) + beta[[2L]] * sqrt(x) * log(x))
}

table5_rr_is_female <- function(x, beta) {
  # Table 5: ln(RR) = B1 * x^0.5 + B2 * x.
  exp(beta[[1L]] * sqrt(x) + beta[[2L]] * x)
}

table5_rr_parameters <- function() {
  data.frame(
    family = c("ihd", "ihd", "is", "is"),
    disease = c(
      "Ischaemic Heart Disease", "Ischaemic Heart Disease",
      "Ischaemic Stroke", "Ischaemic Stroke"
    ),
    sex = c("male", "female", "male", "female"),
    source_object = c(
      "table5_ihd_male", "table5_ihd_female",
      "table5_is_male", "table5_is_female"
    ),
    b1 = c(-0.046271, -0.052526, -0.141950, -0.249674),
    se_b1 = c(0.024037, 0.032510, 0.012866, 0.019163),
    b2 = c(0.000001, 0.014704, 0.039613, 0.037207),
    se_b2 = c(0.000000, 0.007925, 0.001782, 0.000523),
    fact = c(1 / 3, 1 / 20, 1, 1),
    rr_former = c(1.25, 1.54, 0.97, 0.97),
    rr_former_lower = c(1.15, 1.17, 0.83, 0.83),
    rr_former_upper = c(1.36, 2.03, 1.14, 1.14),
    stringsAsFactors = FALSE
  )
}

table5_make_record <- function(row, age_band) {
  rr_fun <- switch(
    paste(row$family, row$sex, sep = "_"),
    ihd_male = table5_rr_ihd_male,
    ihd_female = table5_rr_ihd_female,
    is_male = table5_rr_is_male,
    is_female = table5_rr_is_female,
    stop("Unsupported Table 5 RR row: ", row$family, " / ", row$sex)
  )
  list(
    disease = row$disease,
    pipeline_disease = row$disease,
    rr_endpoint = row$disease,
    source_note = paste(
      "Chile 2014 Table 5 sex-specific RR sensitivity;",
      "same RR repeated across age bands because Table 5 is not age-banded.",
      "The 'fact' column is stored as metadata and is not used as a hidden x-scale."
    ),
    pipeline_icd10 = if (identical(row$family, "ihd")) "I20-I25" else "G45-G46.8/I63/I65-I66/I67.2-I67.8/I69.3-I69.4",
    sex = row$sex,
    source_file = "Table 5, Chile 2014; parameters entered in aaf_table5_ihd_is_experiment.R",
    source_object = paste0(row$source_object, "_", gsub("[^0-9A-Za-z]+", "_", age_band)),
    adam_age_band = age_band,
    RRCurrent = rr_fun,
    betaCurrent = c(row$b1, row$b2),
    covBetaCurrent = diag(c(row$se_b1^2, row$se_b2^2), 2L),
    lnRRFormer = log(row$rr_former),
    varLnRRFormer = table5_lognormal_var_from_ci(row$rr_former_lower, row$rr_former_upper),
    table5_fact = row$fact,
    table5_rr_former_ci = c(row$rr_former_lower, row$rr_former_upper)
  )
}

table5_make_registry <- function(family = c("ihd", "is")) {
  family <- match.arg(family)
  pars <- table5_rr_parameters()
  pars <- pars[pars$family == family, , drop = FALSE]
  age_bands <- c("15-34", "35-64", "65+")
  records <- list()
  for (i in seq_len(nrow(pars))) {
    for (band in age_bands) {
      rec <- table5_make_record(pars[i, , drop = FALSE], band)
      records[[paste(rec$sex, rec$source_object, sep = "::")]] <- rec
    }
  }
  class(records) <- c("adam_rr_registry", "list")
  attr(records, "summary") <- table5_registry_summary(records)
  records
}

table5_registry_summary <- function(registry) {
  do.call(rbind, lapply(registry, function(record) {
    data.frame(
      source_object = record$source_object,
      sex = record$sex,
      pipeline_disease = record$pipeline_disease,
      adam_age_band = record$adam_age_band,
      n_betas = length(record$betaCurrent),
      rr_former = exp(record$lnRRFormer),
      table5_fact = record$table5_fact,
      stringsAsFactors = FALSE
    )
  }))
}

table5_registry_metadata <- function(registry) {
  do.call(rbind, lapply(registry, function(record) {
    data.frame(
      disease = record$disease,
      pipeline_disease = record$pipeline_disease,
      rr_endpoint = record$rr_endpoint,
      source_note = record$source_note,
      pipeline_icd10 = record$pipeline_icd10,
      sex = record$sex,
      adam_age_band = record$adam_age_band,
      source_file = record$source_file,
      source_object = record$source_object,
      betaCurrent = paste(format(record$betaCurrent), collapse = "; "),
      covBetaCurrent = paste(format(as.vector(record$covBetaCurrent)), collapse = "; "),
      lnRRFormer = record$lnRRFormer,
      rr_form_used = exp(record$lnRRFormer),
      varLnRRFormer_recorded = record$varLnRRFormer,
      table5_fact = record$table5_fact,
      table5_rr_former_ci = paste(format(record$table5_rr_former_ci), collapse = "; "),
      stringsAsFactors = FALSE
    )
  }))
}

table5_wide_to_standard <- function(df, prefix) {
  out <- data.frame(
    Year = df$Year,
    disease = df$disease,
    stringsAsFactors = FALSE
  )
  for (ag in 1:4) {
    out[[paste0("AAF_ag", ag)]] <- df[[paste0(prefix, ag, "_point")]]
    out[[paste0("LL_ag", ag)]] <- df[[paste0(prefix, ag, "_lower")]]
    out[[paste0("UL_ag", ag)]] <- df[[paste0(prefix, ag, "_upper")]]
  }
  out
}

table5_standard_to_long <- function(female, male) {
  rows <- list()
  i <- 1L
  add_rows <- function(df, gender) {
    for (r in seq_len(nrow(df))) {
      for (ag in 1:4) {
        rows[[i]] <<- data.frame(
          year = df$Year[[r]],
          age_group = ag,
          gender = gender,
          disease = df$disease[[r]],
          point = df[[paste0("AAF_ag", ag)]][[r]],
          lower = df[[paste0("LL_ag", ag)]][[r]],
          upper = df[[paste0("UL_ag", ag)]][[r]],
          stringsAsFactors = FALSE
        )
        i <<- i + 1L
      }
    }
    invisible(NULL)
  }
  add_rows(female, "Mujer")
  add_rows(male, "Hombre")
  do.call(rbind, rows)
}

table5_cv_standard_tables <- function(ihd_result, is_result) {
  female <- rbind(
    table5_wide_to_standard(ihd_result$tables$ihd_female, "Fem"),
    table5_wide_to_standard(is_result$tables$is_female, "Fem")
  )
  male <- rbind(
    table5_wide_to_standard(ihd_result$tables$ihd_male, "Male"),
    table5_wide_to_standard(is_result$tables$is_male, "Male")
  )
  list(
    female = female,
    male = male,
    long = table5_standard_to_long(female, male)
  )
}

table5_replace_cv_rows <- function(aaf_fem, aaf_male, table5_result, age_scope = "15_64") {
  cv_diseases <- c("Ischaemic Heart Disease", "Ischaemic Stroke")
  tables <- table5_result$by_age_scope[[age_scope]]$standard_tables
  if (is.null(tables)) {
    stop("No standard tables found for age_scope = ", age_scope)
  }
  replace_one <- function(existing, replacement) {
    common <- intersect(names(existing), names(replacement))
    out <- existing
    for (disease_name in cv_diseases) {
      idx <- which(out$disease == disease_name)
      repl <- replacement[replacement$disease == disease_name, , drop = FALSE]
      if (!length(idx)) {
        out <- rbind(out, repl[, names(out), drop = FALSE])
        next
      }
      year_match <- match(out$Year[idx], repl$Year)
      if (anyNA(year_match)) {
        stop("Replacement rows for ", disease_name, " do not cover all existing years.")
      }
      out[idx, common] <- repl[year_match, common, drop = FALSE]
    }
    out
  }
  list(
    female = replace_one(aaf_fem, tables$female),
    male = replace_one(aaf_male, tables$male)
  )
}

table5_death_weighted_aaf <- function(mortality_results, table5_result, age_scope = "15_64") {
  # Optional post-join summary. The mortality_results object must already contain
  # raw deaths in column n and keys year, age_group, gender, disease.
  required <- c("year", "age_group", "gender", "disease", "n")
  missing <- setdiff(required, names(mortality_results))
  if (length(missing)) {
    stop("mortality_results is missing columns: ", paste(missing, collapse = ", "))
  }
  cv_diseases <- c("Ischaemic Heart Disease", "Ischaemic Stroke")
  aaf_long <- table5_result$by_age_scope[[age_scope]]$standard_tables$long
  mr <- mortality_results[mortality_results$disease %in% cv_diseases, required, drop = FALSE]
  merged <- merge(
    mr,
    aaf_long,
    by = c("year", "age_group", "gender", "disease"),
    all.x = FALSE,
    all.y = FALSE
  )
  if (!nrow(merged)) {
    stop("No overlapping rows between mortality_results and Table 5 AAF rows.")
  }
  keys <- unique(merged[c("year", "gender", "disease")])
  rows <- vector("list", nrow(keys))
  for (i in seq_len(nrow(keys))) {
    idx <- merged$year == keys$year[[i]] &
      merged$gender == keys$gender[[i]] &
      merged$disease == keys$disease[[i]]
    x <- merged[idx, , drop = FALSE]
    deaths <- sum(x$n, na.rm = TRUE)
    rows[[i]] <- data.frame(
      year = keys$year[[i]],
      gender = keys$gender[[i]],
      disease = keys$disease[[i]],
      deaths = deaths,
      point = stats::weighted.mean(x$point, x$n, na.rm = TRUE),
      lower = stats::weighted.mean(x$lower, x$n, na.rm = TRUE),
      upper = stats::weighted.mean(x$upper, x$n, na.rm = TRUE),
      stringsAsFactors = FALSE
    )
  }
  do.call(rbind, rows)
}

table5_write_outputs <- function(result, control_dir, stem) {
  rds_path <- file.path(control_dir, paste0(stem, ".rds"))
  saveRDS(result, rds_path)

  for (scope in names(result$by_age_scope)) {
    tables <- result$by_age_scope[[scope]]$standard_tables
    utils::write.csv(
      tables$female,
      file.path(control_dir, paste0(stem, "_", scope, "_female_wide.csv")),
      row.names = FALSE,
      fileEncoding = "UTF-8"
    )
    utils::write.csv(
      tables$male,
      file.path(control_dir, paste0(stem, "_", scope, "_male_wide.csv")),
      row.names = FALSE,
      fileEncoding = "UTF-8"
    )
    utils::write.csv(
      tables$long,
      file.path(control_dir, paste0(stem, "_", scope, "_long.csv")),
      row.names = FALSE,
      fileEncoding = "UTF-8"
    )
  }

  rds_path
}

run_table5_ihd_is_experiment <- function(
    control_dir = table5_find_control_dir(),
    n_sim = NULL,
    n_pca = NULL,
    n_cores = NULL,
    use_parallel = TRUE,
    write_outputs = TRUE) {
  table5_message("Table 5 IHD/IS experiment started.")
  table5_message("Control directory: %s", control_dir)

  engine_file <- file.path(control_dir, "aaf_unified.R")
  source(engine_file, local = TRUE)

  input_bundle_file <- table5_latest_file(control_dir, "^aaf_engine_inputs_bundle_.*\\.rds$")
  settings_file <- tryCatch(
    table5_latest_file(control_dir, "^aaf_nested_by_disease_.*\\.rds$"),
    error = function(e) NULL
  )
  table5_message("Exposure input bundle: %s", basename(input_bundle_file))
  table5_message("Settings bundle: %s", if (is.null(settings_file)) "<fallback defaults>" else basename(settings_file))

  input_bundle <- readRDS(input_bundle_file)
  exposure <- input_bundle$exposure_inputs
  years <- as.integer(input_bundle$metadata$survey_years)
  if (!length(years)) {
    years <- as.integer(names(exposure$g_fem_hed_list))
  }

  settings <- if (!is.null(settings_file)) readRDS(settings_file)$inputs else list()
  aaf_mc <- settings$aaf_mc
  aaf_uncertainty <- settings$aaf_uncertainty
  if (is.null(aaf_mc)) {
    aaf_mc <- list(n_sim = 10000L, n_pca = 1000L, seed = 2125L, n_cores = NULL)
  }
  if (is.null(aaf_uncertainty)) {
    aaf_uncertainty <- list(
      prev_method = "dirichlet",
      neff = 1000,
      design_factor = 1.35,
      fd_uncertainty = TRUE,
      neff_consumption = NULL,
      design_factor_consumption = 1
    )
  }

  n_sim <- table5_env_int("AAF_TABLE5_N_SIM", if (is.null(n_sim)) as.integer(aaf_mc$n_sim) else as.integer(n_sim))
  n_pca <- table5_env_int("AAF_TABLE5_N_PCA", if (is.null(n_pca)) as.integer(aaf_mc$n_pca) else as.integer(n_pca))
  if (is.null(n_cores)) {
    n_cores <- if (is.null(aaf_mc$n_cores)) NULL else as.integer(aaf_mc$n_cores)
  }

  table5_message(
    "Monte Carlo settings: n_sim=%d, n_pca=%d, seed=%d, n_cores=%s, use_parallel=%s",
    n_sim,
    n_pca,
    as.integer(aaf_mc$seed),
    if (is.null(n_cores)) "auto" else as.character(n_cores),
    as.character(isTRUE(use_parallel))
  )

  registry_ihd <- table5_make_registry("ihd")
  registry_is <- table5_make_registry("is")
  table5_message("IHD registry records: %d", length(registry_ihd))
  table5_message("IS registry records: %d", length(registry_is))

  common_args <- list(
    g_fem_hed_list = exposure$g_fem_hed_list,
    g_male_hed_list = exposure$g_male_hed_list,
    p_abs_list_fem = exposure$p_abs_list_fem,
    p_abs_list_male = exposure$p_abs_list_male,
    p_form_list_fem = exposure$p_form_list_fem,
    p_form_list_male = exposure$p_form_list_male,
    p_hed_list_fem = exposure$p_hed_list_fem,
    p_hed_list_male = exposure$p_hed_list_male,
    x_vals = exposure$x_vals,
    years = years,
    age_groups = 1:4,
    prev_method = aaf_uncertainty$prev_method,
    neff = aaf_uncertainty$neff,
    design_factor = aaf_uncertainty$design_factor,
    fd_uncertainty = isTRUE(aaf_uncertainty$fd_uncertainty),
    neff_consumption = aaf_uncertainty$neff_consumption,
    design_factor_consumption = aaf_uncertainty$design_factor_consumption,
    n_sim = n_sim,
    n_pca = n_pca,
    seed = as.integer(aaf_mc$seed),
    n_cores = n_cores,
    use_parallel = use_parallel,
    stop_on_error = FALSE
  )

  table5_message("Running current pipeline age scope: 15_64 (tramo 4 = 60-64).")
  aaf_error_log_reset()
  ihd_15_64 <- do.call(
    compute_cv_aaf_from_registry,
    c(common_args, list(registry = registry_ihd, age_scope = "15_64"))
  )
  is_15_64 <- do.call(
    compute_cv_aaf_from_registry,
    c(common_args, list(registry = registry_is, age_scope = "15_64"))
  )
  errors_15_64 <- aaf_error_log()

  standard_15_64 <- table5_cv_standard_tables(ihd_15_64, is_15_64)

  # Table 5 has no age-banded current-drinker RR. Therefore 15_plus and 15_64
  # produce identical AAFs in this experiment; the difference matters later only
  # when mortality denominators include true 65+ deaths.
  by_age_scope <- list(
    "15_64" = list(
      age_scope = "15_64",
      note = "Current pipeline scope; tramo 4 is 60-64.",
      ihd = ihd_15_64,
      ischaemic_stroke = is_15_64,
      standard_tables = standard_15_64,
      errors = errors_15_64
    ),
    "15_plus" = list(
      age_scope = "15_plus",
      note = paste(
        "Alias of 15_64 AAFs because Table 5 RR is sex-specific, not age-banded.",
        "Use death denominators that include 65+ if you need a true 15+ aggregate."
      ),
      ihd = ihd_15_64,
      ischaemic_stroke = is_15_64,
      standard_tables = standard_15_64,
      errors = errors_15_64
    )
  )

  result <- list(
    metadata = list(
      created_at = format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"),
      elapsed_min = table5_elapsed_min(),
      script = normalizePath(sys.frame(1)$ofile %||% "aaf_table5_ihd_is_experiment.R", winslash = "/", mustWork = FALSE),
      engine_file = engine_file,
      input_bundle_file = input_bundle_file,
      settings_file = settings_file,
      years = years,
      note = paste(
        "Sensitivity experiment only. It does not modify Adam/WHO objects.",
        "The 'fact' column from Table 5 is stored in metadata and not applied as an x-scale."
      )
    ),
    config = list(
      n_sim = n_sim,
      n_pca = n_pca,
      seed = as.integer(aaf_mc$seed),
      n_cores = n_cores,
      use_parallel = use_parallel,
      prev_method = aaf_uncertainty$prev_method,
      fd_uncertainty = isTRUE(aaf_uncertainty$fd_uncertainty)
    ),
    table5_parameters = table5_rr_parameters(),
    registries = list(
      ihd = table5_registry_metadata(registry_ihd),
      ischaemic_stroke = table5_registry_metadata(registry_is)
    ),
    by_age_scope = by_age_scope
  )

  if (isTRUE(write_outputs)) {
    stem <- paste0("aaf_table5_ihd_is_experiment_", format(Sys.Date(), "%Y%m%d"))
    path <- table5_write_outputs(result, control_dir, stem)
    result$metadata$output_rds <- path
    saveRDS(result, path)
    table5_message("Saved result bundle: %s", path)
  }

  table5_message("Done in %.2f minutes.", table5_elapsed_min())
  result
}

`%||%` <- function(x, y) {
  if (is.null(x) || !length(x) || is.na(x)) y else x
}

if (!identical(tolower(Sys.getenv("AAF_TABLE5_AUTORUN", unset = "true")), "false")) {
  aaf_table5_result <- run_table5_ihd_is_experiment()
}
