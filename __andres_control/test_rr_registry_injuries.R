control_dir <- if (file.exists("rr_registry_adam.R")) "." else "__andres_control"
source(file.path(control_dir, "rr_registry_adam.R"))

assert <- function(ok, msg) {
  if (!isTRUE(ok)) stop(msg, call. = FALSE)
}

registry <- load_adam_rr_registry(scope = "injuries")
validate_adam_rr_registry(registry)

expected_objects <- c(
  "injuries_MVA", "injuries_MVA",
  "injuries_other_unit", "injuries_other_unit",
  "injuries_other_int", "injuries_other_int"
)
registry_objects <- unname(vapply(registry, `[[`, character(1), "source_object"))
expected_table <- table(expected_objects)
registry_table <- table(registry_objects)
assert(
  setequal(names(registry_table), names(expected_table)) &&
    all(as.integer(registry_table[names(expected_table)]) == as.integer(expected_table)),
  "Injury registry objects mismatch"
)

for (record in registry) {
  assert(.adam_record_has_binge(record), paste(record$source_object, "missing binge fields"))
  assert(identical(dim(record$covBetaCurrent_binge), c(length(record$betaCurrent_binge), length(record$betaCurrent_binge))), paste(record$source_object, "binge beta/cov mismatch"))
  assert(record$covBetaCurrent_binge[2, 2] > 0, paste(record$source_object, "binge beta2 variance should be positive"))
  assert(is.finite(record$varLnRRFormer), paste(record$source_object, "former-drinker variance should be recorded"))
}

metadata <- adam_rr_registry_metadata(registry)
assert(all(metadata$has_binge_rr), "Injury metadata should mark binge RR availability")
assert(all(is.finite(metadata$binge_beta2_used)), "Injury metadata should record binge beta2")
assert(all(is.finite(metadata$binge_beta2_var_used)), "Injury metadata should record binge beta2 variance")
assert(all(metadata$varLnRRFormer_used == FALSE), "Former-drinker variance should not be used yet")

# AAF compute smoke moved to test_aaf_compute.R (compute_* now live in aaf_unified.R).
cat("All rr_registry_adam injury DATA tests passed.\n")
