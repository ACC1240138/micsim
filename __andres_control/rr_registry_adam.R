adam_find_control_dir <- function(control_dir = NULL) {
  if (!is.null(control_dir)) {
    if (!dir.exists(control_dir)) stop("control_dir does not exist: ", control_dir)
    return(normalizePath(control_dir, winslash = "/", mustWork = TRUE))
  }

  candidates <- c(
    getwd(),
    file.path(getwd(), "__andres_control")
  )
  marker <- "GENERAL_chronic_RR_2024_08_23.R"
  hit <- candidates[file.exists(file.path(candidates, marker))]
  if (!length(hit)) {
    stop("Could not locate ", marker, " from getwd(): ", getwd())
  }
  normalizePath(hit[[1]], winslash = "/", mustWork = TRUE)
}

.adam_source_private <- function(path) {
  env <- new.env(parent = globalenv())
  sys.source(path, envir = env, keep.source = TRUE)
  env
}

.adam_required_fields <- c(
  "disease", "RRCurrent", "betaCurrent", "covBetaCurrent",
  "lnRRFormer", "varLnRRFormer"
)

.adam_get_record <- function(
    env,
    object_name,
    sex,
    source_file,
    pipeline_disease = NULL,
    rr_endpoint = NULL,
    source_note = NULL,
    pipeline_icd10 = NULL,
    include_binge = FALSE
) {
  if (!exists(object_name, envir = env, inherits = FALSE)) {
    stop("Missing Adam RR object: ", object_name)
  }
  obj <- get(object_name, envir = env, inherits = FALSE)
  missing_fields <- setdiff(.adam_required_fields, names(obj))
  if (length(missing_fields)) {
    stop(
      "Adam RR object ", object_name, " is missing fields: ",
      paste(missing_fields, collapse = ", ")
    )
  }

  beta <- as.numeric(obj$betaCurrent)
  cov_beta <- as.matrix(obj$covBetaCurrent)
  if (!identical(dim(cov_beta), c(length(beta), length(beta)))) {
    stop("covBetaCurrent dimensions do not match betaCurrent for ", object_name)
  }

  record <- list(
    disease = as.character(obj$disease),
    pipeline_disease = if (is.null(pipeline_disease)) as.character(obj$disease) else pipeline_disease,
    rr_endpoint = if (is.null(rr_endpoint)) as.character(obj$disease) else rr_endpoint,
    source_note = if (is.null(source_note)) NA_character_ else source_note,
    pipeline_icd10 = if (is.null(pipeline_icd10)) NA_character_ else pipeline_icd10,
    sex = sex,
    source_file = source_file,
    source_object = object_name,
    RRCurrent = obj$RRCurrent,
    betaCurrent = beta,
    covBetaCurrent = cov_beta,
    lnRRFormer = as.numeric(obj$lnRRFormer),
    varLnRRFormer = as.numeric(obj$varLnRRFormer)
  )

  if (isTRUE(include_binge)) {
    binge_required <- c(
      "RRCurrent_binge", "betaCurrent_binge", "covBetaCurrent_binge",
      "lnRRFormer_binge", "varLnRRFormer_binge"
    )
    missing_binge <- setdiff(binge_required, names(obj))
    if (length(missing_binge)) {
      stop(
        "Adam RR object ", object_name, " is missing binge fields: ",
        paste(missing_binge, collapse = ", ")
      )
    }
    beta_binge <- as.numeric(obj$betaCurrent_binge)
    cov_beta_binge <- as.matrix(obj$covBetaCurrent_binge)
    if (!identical(dim(cov_beta_binge), c(length(beta_binge), length(beta_binge)))) {
      stop("covBetaCurrent_binge dimensions do not match betaCurrent_binge for ", object_name)
    }
    record$RRCurrent_binge <- obj$RRCurrent_binge
    record$betaCurrent_binge <- beta_binge
    record$covBetaCurrent_binge <- cov_beta_binge
    record$lnRRFormer_binge <- as.numeric(obj$lnRRFormer_binge)
    record$varLnRRFormer_binge <- as.numeric(obj$varLnRRFormer_binge)
  }

  record
}

load_adam_rr_registry <- function(
    scope = c("cancer", "hhd", "general", "ihd", "is", "injuries"),
    control_dir = NULL,
    source_path = NULL,     # explicit path to the GENERAL_*_RR_*.R file; NULL -> auto
    verbose = TRUE          # narrate what is being located/loaded and flag failures
) {
  scope <- match.arg(scope)
  say <- function(...) if (isTRUE(verbose)) message(...)
  say("[load_adam_rr_registry] scope = '", scope, "'")

  if (is.null(source_path)) {
    control_dir <- adam_find_control_dir(control_dir)
    say("  control_dir resolved to: ", control_dir)
    source_path <- switch(
      scope,
      cancer = file.path(control_dir, "GENERAL_chronic_RR_2024_08_23.R"),
      hhd = file.path(control_dir, "GENERAL_chronic_RR_2024_08_23.R"),
      general = file.path(control_dir, "GENERAL_chronic_RR_2024_08_23.R"),
      ihd = file.path(control_dir, "GENERAL_ihd_RR_2018_03_16.R"),
      is = file.path(control_dir, "GENERAL_IS_RR_2018_03_16.R"),
      injuries = file.path(control_dir, "GENERAL_injuries_RR_2018_03_16.R")
    )
  } else {
    if (dir.exists(source_path)) {
      stop("[load_adam_rr_registry] source_path must be a FILE (a specific ",
           "GENERAL_*_RR_*.R), not a directory. For the folder use control_dir. Got: ", source_path)
    }
    say("  using explicit source_path (control_dir ignored)")
  }
  if (!file.exists(source_path)) {
    stop("[load_adam_rr_registry] RR source file not found: ", source_path)
  }
  say("  sourcing RR definitions from: ", source_path)
  source_env <- .adam_source_private(source_path)
  source_path <- normalizePath(source_path, winslash = "/", mustWork = TRUE)

  cancer_map <- data.frame(
    source_object = c(
      "oralcancer_male",
      "oralcancer_female",
      "oesophaguscancer_male",
      "oesophaguscancer_female",
      "colorectalcancer_male",
      "colorectalcancer_female",
      "Livercancer_male",
      "Livercancer_female",
      "Larynxcancer_male",
      "Larynxcancer_female",
      "Breastcancer_female",
      "Stomachcancer_male",
      "Stomachcancer_female",
      "Pancreascancer_male",
      "Pancreascancer_female"
    ),
    sex = c(
      "male", "female",
      "male", "female",
      "male", "female",
      "male", "female",
      "male", "female",
      "female",
      "male", "female",
      "male", "female"
    ),
    pipeline_disease = c(
      "Oral Cavity and Pharynx Cancer",
      "Oral Cavity and Pharynx Cancer",
      "Oesophagus Cancer",
      "Oesophagus Cancer",
      "Colon and rectum Cancer",
      "Colon and rectum Cancer",
      "Liver Cancer",
      "Liver Cancer",
      "Larynx Cancer",
      "Larynx Cancer",
      "Breast Cancer",
      "Stomach Cancer",
      "Stomach Cancer",
      "Pancreatic Cancer",
      "Pancreatic Cancer"
    ),
    stringsAsFactors = FALSE
  )

  chronic_source_note <- "WHO 2024 GSRAHTSUD RR record provided by Adam; pipeline disease label preserved from current AAF output."
  general_map <- data.frame(
    source_object = c(
      "epilepsyfemale", "epilepsymale",
      "diabetesfemale", "diabetesmale",
      "tuberculosisfemale", "tuberculosismale",
      "HIVfemale", "HIVmale",
      "lowerrespfemale", "lowerrespmale",
      "livercirrhosisfemale", "livercirrhosismale",
      "pancreatitisfemale", "pancreatitismale",
      "hemorrhagicstrokefemale", "hemorrhagicstrokemale"
    ),
    sex = c(
      "female", "male",
      "female", "male",
      "female", "male",
      "female", "male",
      "female", "male",
      "female", "male",
      "female", "male",
      "female", "male"
    ),
    pipeline_disease = c(
      "Epilepsy", "Epilepsy",
      "DM2", "DM2",
      "Tuberculosis", "Tuberculosis",
      "HIV", "HIV",
      "Lower Respiratory Infection", "Lower Respiratory Infection",
      "Liver Cirrhosis", "Liver Cirrhosis",
      "Acute Pancreatitis", "Acute Pancreatitis",
      "Intracerebral Haemorrhage", "Intracerebral Haemorrhage"
    ),
    source_note = chronic_source_note,
    stringsAsFactors = FALSE
  )

  ihd_source_note <- paste(
    "WHO/Adam IHD mortality RR; age-banded source records are mapped",
    "from Adam's 15-34, 35-64, 65+ bands to the pipeline's four age groups."
  )
  ihd_map <- data.frame(
    source_object = c(
      "IHDfemaleMORT_1", "IHDfemaleMORT_2", "IHDfemaleMORT_3",
      "IHDmaleMORT_1", "IHDmaleMORT_2", "IHDmaleMORT_3"
    ),
    sex = c("female", "female", "female", "male", "male", "male"),
    pipeline_disease = "Ischaemic Heart Disease",
    adam_age_band = c("15-34", "35-64", "65+", "15-34", "35-64", "65+"),
    source_note = ihd_source_note,
    stringsAsFactors = FALSE
  )

  is_source_note <- paste(
    "WHO/Adam Ischaemic Stroke mortality RR; age-banded source records are mapped",
    "from Adam's 15-34, 35-64, 65+ bands to the pipeline's four age groups."
  )
  is_map <- data.frame(
    source_object = c(
      "ischemicstrokefemale_1", "ischemicstrokefemale_2", "ischemicstrokefemale_3",
      "ischemicstrokemale_1", "ischemicstrokemale_2", "ischemicstrokemale_3"
    ),
    sex = c("female", "female", "female", "male", "male", "male"),
    pipeline_disease = "Ischaemic Stroke",
    adam_age_band = c("15-34", "35-64", "65+", "15-34", "35-64", "65+"),
    source_note = is_source_note,
    stringsAsFactors = FALSE
  )

  injury_source_note <- paste(
    "WHO/Adam injury RR with NHED and HED/binge terms;",
    "HED/binge beta uncertainty is propagated for AAF, former-drinker variance is recorded only."
  )
  injuries_map <- data.frame(
    source_object = c(
      "injuries_MVA", "injuries_MVA",
      "injuries_other_unit", "injuries_other_unit",
      "injuries_other_int", "injuries_other_int"
    ),
    sex = c("female", "male", "female", "male", "female", "male"),
    pipeline_disease = c(
      "Road Injuries", "Road Injuries",
      "Unintentional Injuries", "Unintentional Injuries",
      "Intentional Injuries", "Intentional Injuries"
    ),
    source_note = injury_source_note,
    include_binge = TRUE,
    stringsAsFactors = FALSE
  )

  hhd_source_note <- paste(
    "Liu et al. 2020 via Adam;",
    "Hypertension RR endpoint applied to Hypertensive Heart Disease",
    "because Shields/GHE maps hypertension RR to ICD-10 I10-I15."
  )
  hhd_map <- data.frame(
    source_object = c("hypertension_male", "hypertension_female"),
    sex = c("male", "female"),
    pipeline_disease = c("Hypertensive Heart Disease", "Hypertensive Heart Disease"),
    rr_endpoint = c("Hypertension", "Hypertension"),
    source_note = c(hhd_source_note, hhd_source_note),
    pipeline_icd10 = c("I10-I15", "I10-I15"),
    stringsAsFactors = FALSE
  )

  registry_map <- switch(
    scope,
    cancer = cancer_map,
    hhd = hhd_map,
    general = general_map,
    ihd = ihd_map,
    is = is_map,
    injuries = injuries_map
  )
  map_value <- function(name, i, default = NULL) {
    if (name %in% names(registry_map)) registry_map[[name]][[i]] else default
  }

  # Sequential per-record load: each record is flagged on success/failure so a
  # missing or malformed RR object is obvious instead of failing silently deep
  # inside lapply().
  say("  loading ", nrow(registry_map), " record(s):")
  records <- vector("list", nrow(registry_map))
  for (i in seq_len(nrow(registry_map))) {
    obj <- registry_map$source_object[[i]]; sx <- registry_map$sex[[i]]
    records[[i]] <- tryCatch(
      .adam_get_record(
        env = source_env,
        object_name = obj,
        sex = sx,
        source_file = source_path,
        pipeline_disease = registry_map$pipeline_disease[[i]],
        rr_endpoint = map_value("rr_endpoint", i),
        source_note = map_value("source_note", i),
        pipeline_icd10 = map_value("pipeline_icd10", i),
        include_binge = isTRUE(map_value("include_binge", i, FALSE))
      ),
      error = function(e) {
        stop("[load_adam_rr_registry] FAILED on '", obj, "' (", sx, "): ", conditionMessage(e))
      }
    )
    if ("adam_age_band" %in% names(registry_map)) {
      records[[i]]$adam_age_band <- registry_map$adam_age_band[[i]]
    }
    say(sprintf("    [ok] %-26s %-7s %-32s betas=%d%s", obj, sx,
                records[[i]]$pipeline_disease, length(records[[i]]$betaCurrent),
                if (.adam_record_has_binge(records[[i]])) " +binge" else ""))
  }
  names(records) <- paste(registry_map$sex, registry_map$source_object, sep = "::")
  class(records) <- c("adam_rr_registry", "list")
  attr(records, "source_path") <- source_path
  attr(records, "summary") <- registry_summary(records)
  if (isTRUE(verbose)) {
    say("  done. summary (also in registry_summary(reg) / attr(reg,'summary')):")
    print(attr(records, "summary"))
  }
  records
}

# Compact, presentable table of what a loaded registry contains. Pass the result
# to knitr::kable() in the notebook for a transparent "what was loaded" panel.
registry_summary <- function(registry) {
  do.call(rbind, lapply(registry, function(r) data.frame(
    source_object = r$source_object,
    sex = r$sex,
    pipeline_disease = if (is.null(r$pipeline_disease)) r$disease else r$pipeline_disease,
    adam_age_band = if (is.null(r$adam_age_band)) NA_character_ else r$adam_age_band,
    n_betas = length(r$betaCurrent),
    rr_form = round(exp(r$lnRRFormer), 4),
    has_binge = .adam_record_has_binge(r),
    stringsAsFactors = FALSE
  )))
}

load_adam_ci_functions <- function(control_dir = NULL, envir = globalenv()) {
  control_dir <- adam_find_control_dir(control_dir)
  ci_path <- file.path(control_dir, "confint_paf_parallel.R")
  source(ci_path, local = envir)
  invisible(TRUE)
}

.adam_numeric_string <- function(x) {
  if (is.null(x)) return(NA_character_)
  x <- as.numeric(x)
  if (!length(x)) return(NA_character_)
  paste(signif(x, 12), collapse = "; ")
}

.adam_record_has_binge <- function(record) {
  all(c(
    "RRCurrent_binge", "betaCurrent_binge", "covBetaCurrent_binge",
    "lnRRFormer_binge", "varLnRRFormer_binge"
  ) %in% names(record))
}

.adam_record_value <- function(record, name, default = NA_character_) {
  if (is.null(record[[name]])) default else record[[name]]
}

.adam_audit_row <- function(
    record,
    active_idx = NULL,
    ci_method = NULL,
    n_sim = NA_integer_,
    n_pca = NA_integer_,
    seed = NA_integer_,
    n_errors = NA_integer_,
    binge_variance_used_in_current_ci = FALSE
) {
  if (is.null(active_idx)) active_idx <- .adam_active_beta_index(record)
  if (is.null(ci_method)) ci_method <- .adam_ci_method(record)
  has_binge <- .adam_record_has_binge(record)
  beta2_used <- if (has_binge && length(record$betaCurrent_binge) >= 2L) {
    record$betaCurrent_binge[[2L]]
  } else {
    NA_real_
  }
  beta2_var_used <- if (has_binge &&
                        is.matrix(record$covBetaCurrent_binge) &&
                        nrow(record$covBetaCurrent_binge) >= 2L) {
    record$covBetaCurrent_binge[2L, 2L]
  } else {
    NA_real_
  }

  data.frame(
    disease = record$disease,
    pipeline_disease = record$pipeline_disease,
    rr_endpoint = if (is.null(record$rr_endpoint)) record$disease else record$rr_endpoint,
    source_note = if (is.null(record$source_note)) NA_character_ else record$source_note,
    pipeline_icd10 = if (is.null(record$pipeline_icd10)) NA_character_ else record$pipeline_icd10,
    sex = record$sex,
    pipeline_age_group = if (is.null(record$pipeline_age_group)) NA_character_ else record$pipeline_age_group,
    adam_age_band = if (is.null(record$adam_age_band)) NA_character_ else record$adam_age_band,
    age_mapping_note = if (is.null(record$age_mapping_note)) NA_character_ else record$age_mapping_note,
    source_file = record$source_file,
    source_object = record$source_object,
    rr_shared_group = if (is.null(record$rr_shared_group)) NA_character_ else record$rr_shared_group,
    rr_shared_rr_note = if (is.null(record$rr_shared_rr_note)) NA_character_ else record$rr_shared_rr_note,
    betaCurrent = .adam_numeric_string(record$betaCurrent),
    covBetaCurrent = .adam_numeric_string(record$covBetaCurrent),
    active_beta_index = paste(active_idx, collapse = "; "),
    ci_method = ci_method,
    lnRRFormer = record$lnRRFormer,
    rr_form_used = exp(record$lnRRFormer),
    varLnRRFormer_recorded = record$varLnRRFormer,
    varLnRRFormer_used = FALSE,
    has_binge_rr = has_binge,
    betaCurrent_binge = if (has_binge) .adam_numeric_string(record$betaCurrent_binge) else NA_character_,
    covBetaCurrent_binge = if (has_binge) .adam_numeric_string(record$covBetaCurrent_binge) else NA_character_,
    lnRRFormer_binge = if (has_binge) record$lnRRFormer_binge else NA_real_,
    rr_form_binge_used = if (has_binge) exp(record$lnRRFormer_binge) else NA_real_,
    varLnRRFormer_binge = if (has_binge) record$varLnRRFormer_binge else NA_real_,
    binge_beta2_used = beta2_used,
    binge_beta2_var_used = beta2_var_used,
    binge_variance_used_in_current_ci = isTRUE(binge_variance_used_in_current_ci),
    n_sim = n_sim,
    n_pca = n_pca,
    seed = seed,
    n_errors = n_errors,
    stringsAsFactors = FALSE
  )
}

adam_rr_registry_metadata <- function(registry) {
  do.call(rbind, lapply(registry, .adam_audit_row))
}

validate_adam_rr_registry <- function(registry, x = c(0.1, 1, 10, 30, 60, 100, 150)) {
  required <- c(
    "disease", "sex", "source_file", "source_object", "RRCurrent",
    "betaCurrent", "covBetaCurrent", "lnRRFormer", "varLnRRFormer"
  )
  for (record in registry) {
    missing_fields <- setdiff(required, names(record))
    if (length(missing_fields)) {
      stop(record$source_object, " missing fields: ", paste(missing_fields, collapse = ", "))
    }
    if (!identical(dim(record$covBetaCurrent), c(length(record$betaCurrent), length(record$betaCurrent)))) {
      stop(record$source_object, ": beta/covariance dimensions do not match.")
    }
    if (!isTRUE(all.equal(record$covBetaCurrent, t(record$covBetaCurrent), tolerance = 1e-12))) {
      stop(record$source_object, ": covBetaCurrent is not symmetric.")
    }
    if (any(diag(record$covBetaCurrent) < -1e-12)) {
      stop(record$source_object, ": covBetaCurrent has a negative diagonal element.")
    }
    rr <- record$RRCurrent(x, record$betaCurrent)
    if (length(rr) != length(x)) {
      stop(record$source_object, ": RRCurrent returned length ", length(rr), " for x length ", length(x))
    }
    if (any(!is.finite(rr)) || any(rr < 0)) {
      stop(record$source_object, ": RRCurrent returned non-finite or negative values.")
    }
    if (.adam_record_has_binge(record)) {
      if (!identical(
        dim(record$covBetaCurrent_binge),
        c(length(record$betaCurrent_binge), length(record$betaCurrent_binge))
      )) {
        stop(record$source_object, ": beta/covariance dimensions do not match for binge fields.")
      }
      if (!isTRUE(all.equal(record$covBetaCurrent_binge, t(record$covBetaCurrent_binge), tolerance = 1e-12))) {
        stop(record$source_object, ": covBetaCurrent_binge is not symmetric.")
      }
      if (any(diag(record$covBetaCurrent_binge) < -1e-12)) {
        stop(record$source_object, ": covBetaCurrent_binge has a negative diagonal element.")
      }
      rr_binge <- record$RRCurrent_binge(x, record$betaCurrent_binge)
      if (length(rr_binge) != length(x)) {
        stop(record$source_object, ": RRCurrent_binge returned length ", length(rr_binge), " for x length ", length(x))
      }
      if (any(!is.finite(rr_binge)) || any(rr_binge < 0)) {
        stop(record$source_object, ": RRCurrent_binge returned non-finite or negative values.")
      }
    }
  }
  invisible(TRUE)
}

.adam_active_beta_index <- function(record, tol = 0) {
  cov_beta <- as.matrix(record$covBetaCurrent)
  active <- which(rowSums(abs(cov_beta)) > tol | colSums(abs(cov_beta)) > tol)
  as.integer(active)
}

.adam_ci_method <- function(record) {
  n_active <- length(.adam_active_beta_index(record))
  if (n_active == 0L) return("fixed")
  if (n_active == 1L) return("scalar")
  "vcov"
}

# =============================================================================
# This file is now DATA/LOADER ONLY: load_adam_rr_registry() builds the RR-curve
# records you pass as `registry =` to the compute_*_aaf_from_registry() functions.
# All AAF/PIF computation lives in aaf_unified.R (single engine + transparent
# compute_* with explicit per-question knobs). Source aaf_unified.R for those.
# =============================================================================
