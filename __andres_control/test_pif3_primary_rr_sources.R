.t0 <- base::Sys.time()
test_env <- base::new.env(parent = base::baseenv())
test_script_arg <- base::grep("^--file=", base::commandArgs(), value = TRUE)
test_script <- base::sub("^--file=", "", test_script_arg[[1L]])
base::sys.source(base::file.path(base::dirname(test_script), "pif3_primary_rr_sources.R"), envir = test_env)

# Synthetic cells deliberately use different source values and shuffled Table 5 rows.
make_grid <- function() {
  base::data.frame(output_name = base::c("ihd_male", "is_male", "ihd_female", "is_female"),
             sex = base::c("male", "male", "female", "female"), year = 2024L, age_group = 2L,
             scenario_id = "volume_reduction_20",
             disease = base::c("Ischaemic Heart Disease", "Ischaemic Stroke",
                         "Ischaemic Heart Disease", "Ischaemic Stroke"),
             applicable = TRUE, n_sim = 4L, pif = base::c(0.1, 0.2, 0.3, 0.4),
             pif_low = 0.01, pif_up = 0.99, stringsAsFactors = FALSE)
}
make_bundle <- function(grid, source) {
  meta <- grid[base::c("output_name", "sex", "year", "age_group", "scenario_id", "disease")]
  meta$cell_key <- base::do.call(paste, base::c(meta[base::c("output_name", "sex", "year", "age_group", "scenario_id")], sep = "|"))
  meta$rr_source <- source
  meta$draw_key <- base::paste(source, meta$cell_key, sep = "|")
  draws <- base::lapply(grid$pif, function(point) point + base::c(-0.03, -0.01, 0.01, 0.03))
  base::names(draws) <- meta$draw_key
  base::list(schema_version = "1.0", seed = 123L, n_sim = 4L, draw_id = 1:4,
       n_jobs = base::nrow(meta), rr_source = source, metadata = meta, pif_draws = draws)
}
who <- make_grid()
table5 <- who[base::c(4L, 3L, 2L, 1L), ]
table5$pif <- table5$pif + 0.05
table5$rr_source <- "table5_puc"
who_bundle <- make_bundle(who, "who_adam")
table5_bundle <- make_bundle(table5, "table5_puc")
selected <- test_env$pif3_select_primary_rr(who, table5, who_bundle, table5_bundle)
base::stopifnot(base::identical(selected$results$pif, base::c(0.1, 0.25, 0.3, 0.45)),
          base::identical(selected$results$rr_source, base::c("who_adam", "table5_puc", "who_adam", "table5_puc")),
          base::identical(selected$draw_bundle$pif_draws[base::c(1L, 3L)], who_bundle$pif_draws[base::c(1L, 3L)]),
          base::identical(selected$draw_bundle$pif_draws[[2L]], table5_bundle$pif_draws[[3L]]),
          base::identical(selected$draw_bundle$pif_draws[[4L]], table5_bundle$pif_draws[[1L]]),
          base::identical(base::names(selected$draw_bundle$pif_draws), selected$draw_bundle$metadata$draw_key))
must_fail <- function(call) base::stopifnot(base::inherits(base::tryCatch(call, error = base::identity), "error"))
must_fail(test_env$pif3_select_primary_rr(who, table5[-1L, ], who_bundle, table5_bundle))
bad_seed <- table5_bundle; bad_seed$seed <- 124L
must_fail(test_env$pif3_select_primary_rr(who, table5, who_bundle, bad_seed))
bad_keys <- table5_bundle; bad_keys$metadata$rr_source <- "who_adam"
must_fail(test_env$pif3_select_primary_rr(who, table5, who_bundle, bad_keys))
bad_id <- table5_bundle; bad_id$draw_id <- 4:1
must_fail(test_env$pif3_select_primary_rr(who, table5, who_bundle, bad_id))
bad_engine <- table5_bundle; bad_engine$provenance <- base::list(engine_sha256 = "different")
must_fail(test_env$pif3_select_primary_rr(who, table5, who_bundle, bad_engine))
base::message("PIF3_PRIMARY_RR_TEST=PASS (synthetic data only; full-pipeline validation pending)")
base::message(base::sprintf("test_pif3_primary_rr_sources elapsed minutes: %.2f",
                base::as.numeric(base::difftime(base::Sys.time(), .t0, units = "mins"))))
