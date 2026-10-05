control_dir <- if (file.exists("rr_registry_adam.R")) "." else "__andres_control"
source(file.path(control_dir, "rr_registry_adam.R"))

assert <- function(ok, msg) {
  if (!isTRUE(ok)) stop(msg, call. = FALSE)
}

registry <- load_adam_rr_registry(scope = "general")
validate_adam_rr_registry(registry)

expected_objects <- c(
  "epilepsyfemale", "epilepsymale",
  "diabetesfemale", "diabetesmale",
  "tuberculosisfemale", "tuberculosismale",
  "HIVfemale", "HIVmale",
  "lowerrespfemale", "lowerrespmale",
  "livercirrhosisfemale", "livercirrhosismale",
  "pancreatitisfemale", "pancreatitismale",
  "hemorrhagicstrokefemale", "hemorrhagicstrokemale"
)
assert(setequal(vapply(registry, `[[`, character(1), "source_object"), expected_objects), "General registry objects mismatch")
assert(!any(grepl("atrial|conduction", expected_objects, ignore.case = TRUE)), "Atrial/conduction should not be in the general registry")

metadata <- adam_rr_registry_metadata(registry)
assert(all(c("lnRRFormer", "rr_form_used", "varLnRRFormer_recorded", "varLnRRFormer_used") %in% names(metadata)), "Former-drinker audit fields missing")
assert(all(metadata$varLnRRFormer_used == FALSE), "Former-drinker variance should be recorded but not used")
assert(all(is.finite(metadata$rr_form_used)), "Former-drinker RR metadata should be finite")

# AAF compute smoke moved to test_aaf_compute.R (compute_* now live in aaf_unified.R).
cat("All rr_registry_adam general DATA tests passed.\n")
