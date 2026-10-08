.t0 <- base::Sys.time()

# Select Table 5 PUC only for IS, without changing the upstream artifacts.
pif3_select_primary_rr <- function(who_results, table5_results, who_draws, table5_draws) {
  check <- function(ok, message) {
    if (!base::isTRUE(ok)) base::stop(message, call. = FALSE)
  }
  keys <- base::c("output_name", "sex", "year", "age_group", "scenario_id")
  cell_key <- function(data) base::do.call(paste, base::c(data[keys], sep = "|"))
  required <- base::c(keys, "disease", "applicable", "n_sim", "pif", "pif_low", "pif_up")
  check(base::all(required %in% base::names(who_results)) && base::all(required %in% base::names(table5_results)),
        "Primary RR selection: result-grid schema is incomplete.")
  check(!base::anyDuplicated(cell_key(who_results)) && !base::anyDuplicated(cell_key(table5_results)),
        "Primary RR selection: duplicated analytical cells.")
  is_who <- who_results$disease == "Ischaemic Stroke"
  is_table5 <- table5_results$disease == "Ischaemic Stroke"
  check(base::any(is_who) && base::any(is_table5), "Primary RR selection: IS cells are missing.")
  replacement <- table5_results[is_table5, , drop = FALSE]
  match_is <- base::match(cell_key(who_results[is_who, , drop = FALSE]), cell_key(replacement))
  check(base::nrow(replacement) == base::sum(is_who) && !base::anyNA(match_is),
        "Primary RR selection: WHO and Table 5 IS cells have different coverage.")
  replacement <- replacement[match_is, , drop = FALSE]
  check(base::identical(base::as.logical(who_results$applicable[is_who]), base::as.logical(replacement$applicable)) &&
          base::identical(base::as.integer(who_results$n_sim[is_who]), base::as.integer(replacement$n_sim)),
        "Primary RR selection: IS applicability or simulation depth differs.")
  for (field in base::c("schema_version", "seed", "n_sim", "draw_id")) {
    check(base::identical(who_draws[[field]], table5_draws[[field]]) && !base::is.null(who_draws[[field]]),
          base::paste("Primary RR selection: incompatible synchronized", field))
  }
  check(base::identical(who_draws$rr_source, "who_adam") &&
          base::identical(table5_draws$rr_source, "table5_puc"),
        "Primary RR selection: unexpected draw-bundle source.")
  for (field in base::c("engine_sha256", "run_config_sha256", "scenario_grid_sha256")) {
    a <- who_draws$provenance[[field]]
    b <- table5_draws$provenance[[field]]
    if (!base::is.null(a) || !base::is.null(b)) {
      check(base::identical(a, b), base::paste("Primary RR selection: source artifacts disagree in", field))
    }
  }
  for (bundle in base::list(who_draws, table5_draws)) {
    metadata <- bundle$metadata
    check(base::all(base::c(keys, "cell_key", "draw_key", "rr_source", "disease") %in% base::names(metadata)),
          "Primary RR selection: draw metadata are incomplete.")
    check(base::nrow(metadata) == bundle$n_jobs && base::length(bundle$pif_draws) == bundle$n_jobs &&
            !base::anyDuplicated(metadata$cell_key) &&
            base::identical(base::as.character(metadata$cell_key), cell_key(metadata)) &&
            base::all(metadata$rr_source == bundle$rr_source) &&
            base::identical(base::as.character(metadata$draw_key), base::paste(metadata$rr_source, metadata$cell_key, sep = "|")) &&
            base::identical(base::names(bundle$pif_draws), base::as.character(metadata$draw_key)),
          "Primary RR selection: draw metadata and vectors are not aligned.")
  }
  selected <- who_results
  selected$rr_source <- "who_adam"
  shared <- base::setdiff(base::names(who_results), "rr_source")
  check(base::all(shared %in% base::names(replacement)), "Primary RR selection: replacement loses result columns.")
  selected[is_who, shared] <- replacement[, shared, drop = FALSE]
  selected$rr_source[is_who] <- "table5_puc"
  selected_meta <- who_draws$metadata
  is_meta <- selected_meta$disease == "Ischaemic Stroke"
  alt_meta <- table5_draws$metadata[table5_draws$metadata$disease == "Ischaemic Stroke", , drop = FALSE]
  alt_pos <- base::match(selected_meta$cell_key[is_meta], alt_meta$cell_key)
  check(base::nrow(alt_meta) == base::sum(is_meta) && !base::anyNA(alt_pos),
        "Primary RR selection: IS draw coverage differs.")
  check(base::all(base::names(selected_meta) %in% base::names(alt_meta)),
        "Primary RR selection: replacement loses draw metadata columns.")
  selected_meta[is_meta, ] <- alt_meta[alt_pos, base::names(selected_meta), drop = FALSE]
  selected_draws <- who_draws$pif_draws
  selected_draws[is_meta] <- table5_draws$pif_draws[base::as.character(selected_meta$draw_key[is_meta])]
  base::names(selected_draws) <- base::as.character(selected_meta$draw_key)
  check(!base::any(base::vapply(selected_draws, base::is.null, logical(1L))), "Primary RR selection: a selected draw is missing.")
  bundle <- who_draws
  bundle$rr_source <- base::unique(base::as.character(selected_meta$rr_source))
  bundle$metadata <- selected_meta
  bundle$pif_draws <- selected_draws
  bundle$primary_rr_rule <- "IS: Table 5 PUC; IHD and all other causes: WHO/Adam"
  bundle$provenance <- base::list(primary_rr_rule = bundle$primary_rr_rule,
                            who_adam = who_draws$provenance,
                            table5_puc = table5_draws$provenance,
                            note = "In-memory consumer selection; producer files are unchanged.")
  check(base::identical(cell_key(selected), cell_key(who_results)) &&
          base::identical(selected[!is_who, shared, drop = FALSE], who_results[!is_who, shared, drop = FALSE]),
        "Primary RR selection changed non-IS cells or row order.")
  base::list(results = selected, draw_bundle = bundle)
}

base::message(base::sprintf("pif3_primary_rr_sources elapsed minutes: %.2f",
                base::as.numeric(base::difftime(base::Sys.time(), .t0, units = "mins"))))
