control_dir <- if (file.exists("rr_registry_adam.R")) "." else "__andres_control"
source(file.path(control_dir, "rr_registry_adam.R"))

assert <- function(ok, msg) {
  if (!isTRUE(ok)) stop(msg, call. = FALSE)
}

registry <- load_adam_rr_registry(scope = "hhd")
validate_adam_rr_registry(registry)

required_fields <- c(
  "disease", "pipeline_disease", "rr_endpoint", "source_note", "pipeline_icd10",
  "sex", "source_file", "source_object", "RRCurrent", "betaCurrent",
  "covBetaCurrent", "lnRRFormer", "varLnRRFormer"
)
x_check <- c(0.1, 1, 10, 30, 60, 100, 150)

source_env <- new.env(parent = globalenv())
sys.source(file.path(control_dir, "GENERAL_chronic_RR_2024_08_23.R"), envir = source_env)

assert(length(registry) == 2L, "HHD registry should contain male and female hypertension records")

for (record in registry) {
  assert(all(required_fields %in% names(record)), paste(record$source_object, "missing required fields"))
  assert(identical(record$pipeline_disease, "Hypertensive Heart Disease"), "HHD pipeline disease mismatch")
  assert(identical(record$rr_endpoint, "Hypertension"), "HHD RR endpoint mismatch")
  assert(identical(record$pipeline_icd10, "I10-I15"), "HHD ICD-10 mapping mismatch")
  assert(
    identical(dim(record$covBetaCurrent), c(length(record$betaCurrent), length(record$betaCurrent))),
    paste(record$source_object, "beta/cov dimension mismatch")
  )
  assert(
    isTRUE(all.equal(record$covBetaCurrent, t(record$covBetaCurrent), tolerance = 1e-12)),
    paste(record$source_object, "covariance matrix is not symmetric")
  )
  assert(
    all(diag(record$covBetaCurrent) >= -1e-12),
    paste(record$source_object, "negative covariance diagonal")
  )

  rr_registry <- record$RRCurrent(x_check, record$betaCurrent)
  assert(length(rr_registry) == length(x_check), paste(record$source_object, "RR length mismatch"))
  assert(all(is.finite(rr_registry)), paste(record$source_object, "RR has non-finite values"))
  assert(all(rr_registry >= 0), paste(record$source_object, "RR has negative values"))

  source_object <- get(record$source_object, envir = source_env, inherits = FALSE)
  rr_source <- source_object$RRCurrent(x_check, source_object$betaCurrent)
  assert(
    isTRUE(all.equal(rr_registry, rr_source, tolerance = 1e-12)),
    paste(record$source_object, "registry RR differs from Adam source")
  )
}

# AAF compute smoke moved to test_aaf_compute.R (compute_* now live in aaf_unified.R).
cat("All rr_registry_adam HHD DATA tests passed.\n")
