# Validate the fresh AAF/PIF summary and synchronized-draw artifacts.
.t0 <- base::Sys.time()

args <- base::commandArgs(trailingOnly = TRUE)
if (base::length(args) != 1L || !args[[1L]] %in% c("expand_pif", "expand_pif2")) {
  base::stop("Usage: Rscript validate_paf_draw_regeneration.R expand_pif|expand_pif2")
}
stage <- args[[1L]]
control_dir <- base::normalizePath(base::getwd(), winslash = "/", mustWork = TRUE)
if (!base::identical(base::basename(control_dir), "__andres_control")) {
  base::stop("Run this validator from the __andres_control directory.")
}
run_started_epoch <- base::suppressWarnings(base::as.numeric(base::Sys.getenv("PIF_RUN_STARTED_EPOCH")))
stamp_env <- base::Sys.getenv("PIF_ARTIFACT_STAMP", unset = "")
stamp <- if (base::nzchar(stamp_env)) {
  stamp_env
} else if (base::is.finite(run_started_epoch)) {
  base::format(
    base::as.POSIXct(run_started_epoch, origin = "1970-01-01", tz = "America/Santiago"),
    "%Y%m%d"
  )
} else {
  base::format(base::Sys.Date(), "%Y%m%d")
}

assert_true <- function(condition, message) {
  if (!base::isTRUE(condition)) base::stop(message, call. = FALSE)
  base::invisible(TRUE)
}

artifact_path <- function(stem, extension = "rds") {
  base::file.path(control_dir, base::paste0(stem, "_", stamp, ".", extension))
}

assert_fresh_file <- function(path) {
  assert_true(base::file.exists(path), base::paste0("Missing artifact: ", path))
  info <- base::file.info(path)
  assert_true(!base::is.na(info$size) && info$size > 0, base::paste0("Empty artifact: ", path))
  if (base::is.finite(run_started_epoch)) {
    assert_true(
      base::as.numeric(info$mtime) >= run_started_epoch,
      base::paste0("Artifact predates this run: ", path)
    )
  }
  base::invisible(path)
}

assert_manifest <- function(artifact, summary) {
  manifest_path <- base::sub("\\.rds$", ".manifest.rds", artifact)
  assert_fresh_file(manifest_path)
  manifest <- base::readRDS(manifest_path)
  assert_true(base::identical(manifest$artifact, base::basename(artifact)), "Manifest artifact name mismatch.")
  assert_true(base::identical(manifest$summary_artifact, base::basename(summary)), "Manifest summary name mismatch.")
  assert_true(
    base::identical(manifest$artifact_sha256, digest::digest(file = artifact, algo = "sha256")),
    base::paste0("Artifact SHA-256 mismatch: ", artifact)
  )
  assert_true(
    base::identical(manifest$summary_sha256, digest::digest(file = summary, algo = "sha256")),
    base::paste0("Summary SHA-256 mismatch: ", summary)
  )
  base::invisible(TRUE)
}

assert_draw_bundle <- function(path, rr_source, draw_name, expected_cells, summary_path) {
  assert_fresh_file(path)
  bundle <- base::readRDS(path)
  draws <- bundle[[draw_name]]
  assert_true(base::identical(bundle$schema_version, "1.0"), "Unexpected draw schema version.")
  assert_true(base::identical(bundle$rr_source, rr_source), "Bundle rr_source mismatch.")
  assert_true(base::identical(base::as.integer(bundle$n_sim), 10000L), "Expected n_sim = 10000.")
  observed_cells <- if (!base::is.null(bundle$n_cells)) bundle$n_cells else bundle$n_jobs
  assert_true(base::identical(base::as.integer(observed_cells), base::as.integer(expected_cells)), "Unexpected draw cell count.")
  assert_true(base::length(draws) == expected_cells, "Draw-list length differs from expected cell count.")
  assert_true(base::nrow(bundle$metadata) == expected_cells, "Metadata row count differs from expected cell count.")
  assert_true(base::identical(base::names(draws), bundle$metadata$draw_key), "Draw names and metadata keys differ.")
  assert_true(!base::anyDuplicated(bundle$metadata$draw_key), "Duplicated source-qualified draw key.")
  assert_true(base::all(bundle$metadata$rr_source == rr_source), "Row-level rr_source mismatch.")
  assert_true(
    base::all(base::startsWith(bundle$metadata$draw_key, base::paste0(rr_source, "|"))),
    "A draw key lacks the required rr_source prefix."
  )
  assert_true(
    base::all(base::vapply(draws, base::length, integer(1)) == 10000L),
    "At least one draw vector is ragged."
  )
  assert_true(
    base::all(base::vapply(draws, function(x) base::all(base::is.finite(x)), logical(1))),
    "At least one draw vector contains a non-finite value."
  )
  assert_manifest(path, summary_path)
  base::rm(bundle, draws)
  base::invisible(base::gc(full = TRUE))
  base::invisible(TRUE)
}

if (!base::requireNamespace("digest", quietly = TRUE)) {
  base::stop("Package 'digest' is required for artifact validation.")
}

if (base::identical(stage, "expand_pif")) {
  nested_path <- artifact_path("aaf_nested_by_disease")
  table5_path <- artifact_path("aaf_table5_result")
  mortality_path <- artifact_path("Mortality Estimates WHO 2024", extension = "xlsx")
  input_path <- artifact_path("aaf_engine_inputs_bundle")
  who_draw_path <- artifact_path("aaf_synchronised_draws_who_adam_full")
  table5_draw_path <- artifact_path("aaf_synchronised_draws_table5_puc_full")
  base::lapply(c(nested_path, table5_path, mortality_path, input_path), assert_fresh_file)

  nested <- base::readRDS(nested_path)
  assert_true(base::length(nested$by_disease) == 23L, "Expected 23 modeled diseases in the nested AAF bundle.")
  raw_results <- base::lapply(nested$family_bundles, function(x) x$raw_result)
  assert_true(
    !base::any(base::vapply(raw_results, function(x) "draws" %in% base::names(x), logical(1))),
    "The compact nested AAF summary unexpectedly duplicates draw vectors."
  )
  assert_true(
    base::is.null(nested$audits$aaf_adam_rr_errors) || !base::nrow(nested$audits$aaf_adam_rr_errors),
    "The main AAF audit contains cell errors."
  )
  base::rm(nested, raw_results)
  base::invisible(base::gc(full = TRUE))

  table5 <- base::readRDS(table5_path)
  assert_true(base::all(c("metadata", "config", "raw", "by_age_scope") %in% base::names(table5)), "Invalid Table 5 AAF summary schema.")
  assert_true(
    !base::any(base::vapply(table5$raw, function(x) "draws" %in% base::names(x), logical(1))),
    "The compact Table 5 AAF summary unexpectedly duplicates draw vectors."
  )
  assert_true(base::nrow(table5$by_age_scope[["15_64"]]$standard_tables$long) == 112L, "Expected 112 Table 5 AAF cells.")
  base::rm(table5)
  base::invisible(base::gc(full = TRUE))

  assert_draw_bundle(who_draw_path, "who_adam", "aaf_draws", 1260L, nested_path)
  assert_draw_bundle(table5_draw_path, "table5_puc", "aaf_draws", 112L, table5_path)
  mortality <- readxl::read_xlsx(mortality_path)
  assert_true(base::nrow(mortality) > 0L, "The mortality workbook is empty.")
  assert_true(base::all(c("year", "gender", "age_group", "disease", "mort") %in% base::names(mortality)), "Mortality workbook schema mismatch.")
  base::message("EXPAND_PIF_ARTIFACT_VALIDATION=PASS")
}

if (base::identical(stage, "expand_pif2")) {
  results_path <- artifact_path("pif2_pif_results_full")
  audit_path <- artifact_path("pif2_pif_audit_full")
  draws_path <- artifact_path("pif2_pif_synchronised_draws_full")
  injury_results_path <- artifact_path("pif2_injuries_fulltest_results")
  injury_checks_path <- artifact_path("pif2_injuries_fulltest_checks")
  table5_results_path <- artifact_path("pif2_pif_results_table5_full")
  table5_audit_path <- artifact_path("pif2_pif_audit_table5_full")
  table5_draws_path <- artifact_path("pif2_pif_synchronised_draws_table5_full")
  base::lapply(
    c(results_path, audit_path, injury_results_path, injury_checks_path,
      table5_results_path, table5_audit_path),
    assert_fresh_file
  )

  results <- base::readRDS(results_path)
  applicable <- results[results$applicable, , drop = FALSE]
  baseline <- applicable[applicable$scenario_id == "baseline", , drop = FALSE]
  assert_true(base::nrow(results) == 20160L, "Expected 20,160 main PIF result rows.")
  assert_true(base::nrow(applicable) == 8400L, "Expected 8,400 applicable main PIF cells.")
  assert_true(base::nrow(results) - base::nrow(applicable) == 11760L, "Unexpected non-applicable main PIF count.")
  assert_true(base::all(base::is.finite(applicable$pif)), "Non-finite applicable main PIF point estimate.")
  assert_true(base::all(base::is.finite(applicable$pif_low)), "Non-finite applicable main PIF lower limit.")
  assert_true(base::all(base::is.finite(applicable$pif_up)), "Non-finite applicable main PIF upper limit.")
  assert_true(base::all(applicable$pif_low <= applicable$pif & applicable$pif <= applicable$pif_up), "Main PIF interval ordering failure.")
  assert_true(base::all(baseline$pif == 0 & baseline$pif_low == 0 & baseline$pif_up == 0), "Main baseline is not exactly zero.")
  base::rm(results, applicable, baseline)
  base::invisible(base::gc(full = TRUE))
  assert_draw_bundle(draws_path, "who_adam", "pif_draws", 8400L, results_path)

  table5_results <- base::readRDS(table5_results_path)
  assert_true(base::nrow(table5_results) == 1792L, "Expected 1,792 Table 5 PIF rows.")
  assert_true(base::all(table5_results$rr_source == "table5_puc"), "Table 5 result rr_source mismatch.")
  table5_applicable <- table5_results[table5_results$applicable, , drop = FALSE]
  assert_true(base::all(base::is.finite(table5_applicable$pif)), "Non-finite applicable Table 5 PIF.")
  assert_true(base::all(table5_applicable$pif_low <= table5_applicable$pif & table5_applicable$pif <= table5_applicable$pif_up), "Table 5 PIF interval ordering failure.")
  base::rm(table5_results, table5_applicable)
  base::invisible(base::gc(full = TRUE))
  assert_draw_bundle(table5_draws_path, "table5_puc", "pif_draws", 1792L, table5_results_path)

  injury_checks <- base::readRDS(injury_checks_path)
  if (base::is.list(injury_checks) && !base::is.null(injury_checks$report)) {
    assert_true(base::all(injury_checks$report$pass[injury_checks$report$severity == "hard"]), "A hard injury validation failed.")
  }
  # Notebook JSON can retain source-code strings, diagnostic messages, and stale
  # rich outputs together. The final validator therefore relies on the serialized
  # artifacts, manifests, schema checks, freshness checks, and hard injury checks
  # above instead of grepping raw notebook text.
  base::message("EXPAND_PIF2_ARTIFACT_VALIDATION=PASS")
}

base::message(base::sprintf(
  "validate-paf-draw-regeneration (%s) elapsed minutes: %.2f",
  stage,
  base::as.numeric(base::difftime(base::Sys.time(), .t0, units = "mins"))
))
