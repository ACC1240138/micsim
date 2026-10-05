control_dir <- if (file.exists("rr_registry_adam.R")) "." else "__andres_control"
source(file.path(control_dir, "rr_registry_adam.R"))
source(file.path(control_dir, "aaf_unified.R"))   # aaf_age_band_mapping lives here now

assert <- function(ok, msg) {
  if (!isTRUE(ok)) stop(msg, call. = FALSE)
}

# Age-band mapping (moved to aaf_unified.R). 15_64 folds group 4 (60-64) into the
# Adam 35-64 band; 15_plus keeps the legacy 65+ band for group 4.
assert(identical(aaf_age_band_mapping("15_64")$adam_age_band, c("15-34", "35-64", "35-64", "35-64")),
       "15_64 Adam age-band mapping changed")
assert(identical(aaf_age_band_mapping("15_plus")$adam_age_band, c("15-34", "35-64", "35-64", "65+")),
       "15_plus Adam age-band mapping changed")

registry_ihd <- load_adam_rr_registry(scope = "ihd")
registry_is <- load_adam_rr_registry(scope = "is")
validate_adam_rr_registry(registry_ihd)
validate_adam_rr_registry(registry_is)

assert(length(registry_ihd) == 6L, "IHD registry should have 3 age bands per sex")
assert(length(registry_is) == 6L, "IS registry should have 3 age bands per sex")
assert(setequal(unique(vapply(registry_ihd, `[[`, character(1), "adam_age_band")), c("15-34", "35-64", "65+")), "IHD Adam age bands mismatch")
assert(setequal(unique(vapply(registry_is, `[[`, character(1), "adam_age_band")), c("15-34", "35-64", "65+")), "IS Adam age bands mismatch")

# AAF compute smoke for the cap (J-curve+binge) path moved to test_aaf_compute.R,
# which also checks compute_cv point == the retired .cv_cell point.
cat("All rr_registry_adam age-banded DATA tests passed.\n")
