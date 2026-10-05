###############################################################################
# build_enpg_design_waves_2012_2024_list.R
#
# Purpose
# -------
# Build a lightweight RDS cache with only the ENPG variables needed to audit
# survey design and alcohol-related uncertainty from 2012 to 2024.
#
# Why this is a separate script
# -----------------------------
# The cache is an input artifact, not the design-analysis itself. Keeping this
# separate makes it clear when the raw Stata/RDS files were parsed and prevents
# the main extension script from silently rebuilding data.
#
# Output
# ------
# Raw data/enpg_design_waves_2012_2024_list.RDS
#
# The cache contains:
#   - waves: a named list of compact data frames, one per ENPG year.
#   - metadata: source file, row count, and selected variable count.
#   - variable_map: the raw variables used to build harmonized IDs/design fields.
#
# This intentionally excludes 2008 and 2010.
###############################################################################

.t0 <- Sys.time()

if (!requireNamespace("haven", quietly = TRUE)) {
  stop("Package 'haven' is required.", call. = FALSE)
}
if (!exists("acc_root")) source(here::here("_tools", "acc_data.R"))
repo_root <- acc_root()
# Raw ENPG waves come from the encrypted bundle (decrypted once per session into tempdir()).
raw_dir <- acc_data("_enpg/enpg.tar.xz.enc")
if (!dir.exists(raw_dir)) {
  stop("Raw data directory was not found: ", raw_dir, call. = FALSE)
}
# The cache is written to tempdir(). If it is rebuilt, PACK THE ENPG BUNDLE AGAIN so that
# derived/enpg_design_waves_2012_2024_list.RDS inside _enpg/enpg.tar.xz.enc is replaced, e.g.:
#   acc_pack(<folder "enpg" with the raw files plus derived/enpg_design_waves_2012_2024_list.RDS>,
#            file.path(repo_root, "_enpg", "enpg.tar.xz.enc"))
cache_path <- file.path(tempdir(), "enpg_design_waves_2012_2024_list.RDS")

to_numeric <- function(x) {
  suppressWarnings(as.numeric(haven::zap_labels(x)))
}
first_existing <- function(data, candidates) {
  hit <- candidates[candidates %in% names(data)]
  if (length(hit) == 0L) {
    return(NA_character_)
  }
  hit[[1L]]
}
find_commune_code <- function(data) {
  candidates <- names(data)[grepl("comuna|codcom", names(data), ignore.case = TRUE)]
  if (length(candidates) == 0L) {
    return(NA_character_)
  }

  numeric_candidates <- candidates[vapply(candidates, function(v) {
    z <- to_numeric(data[[v]])
    any(!is.na(z)) && stats::median(z, na.rm = TRUE) >= 1000
  }, logical(1))]
  if (length(numeric_candidates) > 0L) {
    return(numeric_candidates[[1L]])
  }

  candidates[[1L]]
}
read_wave <- function(spec) {
  path <- file.path(raw_dir, spec$file)
  if (!file.exists(path)) {
    stop("Missing source file for ", spec$year, ": ", path, call. = FALSE)
  }
  if (identical(spec$reader, "dta")) {
    data <- as.data.frame(haven::read_dta(path))
  } else {
    data <- as.data.frame(readRDS(path))
  }
  if (identical(spec$year, 2016L)) {
    expansion_path <- file.path(raw_dir, "enpg16_factoresdeexpansion.dta")
    expansion <- as.data.frame(haven::read_dta(expansion_path))
    expansion <- expansion[, c("idencuesta", "Fexp"), drop = FALSE]
    data <- merge(data, expansion, by = "idencuesta", all.x = TRUE, sort = FALSE)
  }
  data
}
make_compact_wave <- function(spec) {
  data <- read_wave(spec)
  id_var <- first_existing(data, spec$id_candidates)
  if (is.na(id_var)) {
    stop("No ID variable found for ", spec$year, call. = FALSE)
  }
  weight_var <- first_existing(data, spec$weight_candidates)
  region_var <- first_existing(data, spec$region_candidates)
  commune_var <- find_commune_code(data)
  if (is.na(commune_var)) {
    commune_var <- first_existing(data, spec$commune_candidates)
  }
  psu_var <- first_existing(data, spec$psu_candidates)
  sex_var <- first_existing(data, spec$sex_candidates)
  age_var <- first_existing(data, spec$age_candidates)

  raw_keep <- unique(c(
    id_var,
    weight_var,
    region_var,
    commune_var,
    psu_var,
    sex_var,
    age_var,
    spec$alcohol_vars,
    spec$psu_candidate_vars
  ))
  raw_keep <- raw_keep[!is.na(raw_keep) & raw_keep %in% names(data)]
  compact <- data[, raw_keep, drop = FALSE]
  compact$year <- spec$year
  compact$id_join <- as.character(haven::zap_labels(data[[id_var]]))
  compact$weight <- if (!is.na(weight_var)) to_numeric(data[[weight_var]]) else NA_real_
  compact$region <- if (!is.na(region_var)) {
    to_numeric(data[[region_var]])
  } else if (!is.na(commune_var)) {
    floor(to_numeric(data[[commune_var]]) / 1000)
  } else {
    NA_real_
  }
  compact$commune <- if (!is.na(commune_var)) {
    as.character(haven::zap_labels(data[[commune_var]]))
  } else {
    NA_character_
  }
  compact$psu <- if (!is.na(psu_var)) {
    as.character(haven::zap_labels(data[[psu_var]]))
  } else {
    NA_character_
  }
  compact$psu_validated <- spec$psu_validated
  compact$psu_source <- if (!is.na(psu_var)) psu_var else NA_character_
  compact$sex_raw <- if (!is.na(sex_var)) to_numeric(data[[sex_var]]) else NA_real_
  compact$age_raw <- if (!is.na(age_var)) to_numeric(data[[age_var]]) else NA_real_
  attr(compact, "source_file") <- spec$file
  attr(compact, "id_var") <- id_var
  attr(compact, "weight_var") <- weight_var
  attr(compact, "region_var") <- region_var
  attr(compact, "commune_var") <- commune_var
  attr(compact, "psu_var") <- psu_var
  compact
}
wave_specs <- list(
  list(
    year = 2012L,
    reader = "dta",
    file = "Base de datos ENPG 2012 (PG).DTA.dta",
    id_candidates = c("idencuesta"),
    weight_candidates = c("PONDERADOR"),
    region_candidates = character(0),
    commune_candidates = c("codigo_comuna", "código_comuna", "comuna"),
    psu_candidates = c("manzana"),
    psu_candidate_vars = c("manzana"),
    psu_validated = TRUE,
    sex_candidates = c("sexo", "SEXO"),
    age_candidates = c("edad", "EDAD"),
    alcohol_vars = c("p10", "p13", "p17", "p21")
  ),
  list(
    year = 2014L,
    reader = "dta",
    file = "Base de datos ENPG 2014 (PG).DTA.dta",
    id_candidates = c("idencuesta"),
    weight_candidates = c("F2_MAY_AJUS_com"),
    region_candidates = c("Region"),
    commune_candidates = c("Comuna"),
    psu_candidates = c("Segmento_n"),
    psu_candidate_vars = c("Segmento_n", "Segmento_t"),
    psu_validated = TRUE,
    sex_candidates = c("sexo", "SEXO"),
    age_candidates = c("edad", "EDAD"),
    alcohol_vars = c("oh1", "oh4", "oh8", "oh12")
  ),
  list(
    year = 2016L,
    reader = "dta",
    file = "base ENPG 2016 publico general.dta",
    id_candidates = c("idencuesta"),
    weight_candidates = c("Fexp"),
    region_candidates = character(0),
    commune_candidates = c("comuna"),
    psu_candidates = c("manzana"),
    psu_candidate_vars = c("manzana"),
    psu_validated = TRUE,
    sex_candidates = c("sexo", "SEXO"),
    age_candidates = c("edad", "EDAD"),
    alcohol_vars = c("oh_1", "oh_4", "oh_8", "oh_16")
  ),
  list(
    year = 2018L,
    reader = "dta",
    file = "Base de datos ENPG 2018 (PG).DTA",
    id_candidates = c("SbjNum"),
    weight_candidates = c("Fexp"),
    region_candidates = c("Region"),
    commune_candidates = c("comuna"),
    psu_candidates = c("idmanzana"),
    psu_candidate_vars = c("idmanzana", "Seccion"),
    psu_validated = TRUE,
    sex_candidates = c("SEXO", "sexo"),
    age_candidates = c("EDAD", "edad"),
    alcohol_vars = c("OH_1", "OH_4", "OH_8", "OH_14")
  ),
  list(
    year = 2020L,
    reader = "rds",
    file = "enpg2020.RDS",
    id_candidates = c("SbjNum"),
    weight_candidates = c("FACT_PERS_COMUNA"),
    region_candidates = c("REGION"),
    commune_candidates = c("Nom_comuna"),
    # The public 2020 RDS exposes "seccion" but not a validated manzana/UPM ID.
    # Keep "seccion" as an audit variable only; do not promote it to PSU here.
    psu_candidates = character(0),
    psu_candidate_vars = c("seccion"),
    psu_validated = FALSE,
    sex_candidates = c("SEXO", "sexo"),
    age_candidates = c("EDAD", "edad"),
    alcohol_vars = c("OH_1", "OH_4", "OH_10")
  ),
  list(
    year = 2022L,
    reader = "dta",
    file = "BD - ENPG 2022 (Stata 16).dta",   # identical to the former enpg2022.RDS (checked column by column)
    id_candidates = c("FOLIO"),
    weight_candidates = c("FACTOR_EXPANSION"),
    region_candidates = c("REGION"),
    commune_candidates = c("COD_COMUNA"),
    psu_candidates = c("UPM"),
    psu_candidate_vars = c("UPM"),
    psu_validated = TRUE,
    sex_candidates = c("SEXO", "sexo"),
    age_candidates = c("EDAD", "edad"),
    alcohol_vars = c("OH_1", "OH_4", "OH_10")
  ),
  list(
    year = 2024L,
    reader = "dta",
    file = "Base Publica ENPG 2024 (Stata 16).dta",
    id_candidates = c("RESPONDENT_SERIAL"),
    weight_candidates = c("FACTOR_EXPANSION"),
    region_candidates = c("REGION"),
    commune_candidates = c("COD_COMUNA"),
    psu_candidates = c("UPM"),
    psu_candidate_vars = c("UPM", "ESTRATO"),
    psu_validated = TRUE,
    sex_candidates = c("SEXO", "sexo"),
    age_candidates = c("EDAD", "edad"),
    alcohol_vars = c("OH_1", "OH_4", "OH_10")
  )
)
waves <- list()
metadata <- data.frame()
variable_map <- data.frame()

for (spec in wave_specs) {
  message("Building lightweight ENPG design cache for ", spec$year)
  compact <- make_compact_wave(spec)
  waves[[as.character(spec$year)]] <- compact
  metadata <- rbind(
    metadata,
    data.frame(
      year = spec$year,
      source_file = spec$file,
      rows = nrow(compact),
      columns = ncol(compact),
      psu_validated = spec$psu_validated,
      stringsAsFactors = FALSE
    )
  )
  variable_map <- rbind(
    variable_map,
    data.frame(
      year = spec$year,
      id_var = attr(compact, "id_var"),
      weight_var = attr(compact, "weight_var"),
      region_var = attr(compact, "region_var"),
      commune_var = attr(compact, "commune_var"),
      psu_var = attr(compact, "psu_var"),
      stringsAsFactors = FALSE
    )
  )
}
cache <- list(
  created_at = format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"),
  excluded_years = c(2008L, 2010L),
  raw_dir = raw_dir,
  waves = waves,
  metadata = metadata,
  variable_map = variable_map
)
saveRDS(cache, cache_path, compress = "xz")
read_back <- readRDS(cache_path)
if (!identical(names(read_back$waves), names(waves))) {
  stop("Cache read-back failed: wave names changed.", call. = FALSE)
}
message("\nWrote lightweight cache: ", cache_path)
print(metadata)
print(variable_map)

elapsed <- as.numeric(difftime(Sys.time(), .t0, units = "mins"))
message(sprintf("Elapsed time: %.2f minutes", elapsed))
