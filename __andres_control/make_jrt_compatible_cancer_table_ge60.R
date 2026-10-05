.t0 <- Sys.time()  # start timer for elapsed-time reporting
.verbose <- TRUE
# ------------------------------------------------------------------
# 1. Resolve script location and project root
# ------------------------------------------------------------------
args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
script_dir <- if (length(file_arg) == 1) {
  # Running via Rscript: get the folder that contains this script
  dirname(normalizePath(sub("^--file=", "", file_arg), winslash = "/", mustWork = TRUE))
} else {
  # Sourced interactively: fall back to current working directory
  normalizePath(getwd(), winslash = "/", mustWork = TRUE)
}
project_root <- if (basename(script_dir) == "__andres_control") {
  # When script lives inside __andres_control, project root is one level up
  normalizePath(file.path(script_dir, ".."), winslash = "/", mustWork = TRUE)
} else {
  normalizePath(script_dir, winslash = "/", mustWork = TRUE)
}
if (!exists("acc_root")) source(file.path(project_root, "_tools", "acc_data.R"))
verbose_message <- function(...) {
  if (isTRUE(.verbose)) {
    message(...)
  }
}
elapsed_minutes <- function() {
  as.numeric(difftime(Sys.time(), .t0, units = "mins"))
}
format_file_size <- function(path) {
  size_bytes <- file.info(path)$size
  if (is.na(size_bytes)) {
    return("size unavailable")
  }
  paste0(round(size_bytes / 1024^2, 2), " MB")
}
format_integer <- function(x) {
  format(x, big.mark = ",", scientific = FALSE, trim = TRUE)
}
verbose_message("Starting JRT-compatible cancer comparison rebuild.")
verbose_message("Script directory: ", script_dir)
verbose_message("Project root: ", project_root)
# ------------------------------------------------------------------
# 2. Helper to resolve the newest dated project file
# ------------------------------------------------------------------
# Finds files with names like:
#   aaf_nested_by_disease_20260709.rds
# and returns the path with the latest YYYYMMDD date embedded in the file name.
latest_dated_project_file <- function(directory, prefix, extension) {
  if (!dir.exists(directory)) {
    stop("Directory does not exist: ", directory)
  }
  verbose_message(
    "Searching for latest dated file in ",
    directory,
    " with pattern ",
    prefix,
    "YYYYMMDD",
    extension,
    "."
  )
  escaped_prefix <- gsub("([][{}()+*^$|\\\\?.])", "\\\\\\1", prefix)
  escaped_extension <- gsub("([][{}()+*^$|\\\\?.])", "\\\\\\1", extension)
  file_pattern <- paste0("^", escaped_prefix, "([0-9]{8})", escaped_extension, "$")
  candidate_paths <- list.files(
    path = directory,
    pattern = file_pattern,
    full.names = TRUE
  )
  if (length(candidate_paths) == 0L) {
    stop(
      "No files matching ",
      prefix,
      "YYYYMMDD",
      extension,
      " were found in: ",
      directory
    )
  }
  candidate_names <- basename(candidate_paths)
  candidate_dates_chr <- sub(file_pattern, "\\1", candidate_names)
  candidate_dates <- as.Date(candidate_dates_chr, format = "%Y%m%d")
  if (anyNA(candidate_dates)) {
    stop(
      "At least one candidate file has an invalid YYYYMMDD date: ",
      paste(candidate_names[is.na(candidate_dates)], collapse = "; ")
    )
  }
  selected_index <- which.max(candidate_dates)
  verbose_message(
    "Found ",
    length(candidate_paths),
    " candidate file(s): ",
    paste(candidate_names[order(candidate_dates)], collapse = "; ")
  )
  verbose_message("Selected latest dated file: ", candidate_names[[selected_index]])
  candidate_paths[[selected_index]]
}
# ------------------------------------------------------------------
# 3. Define input/output paths
# ------------------------------------------------------------------
path_jrt <- file.path(
  project_root,
  "jrt", "cancer_20260702",
  "Alcohol Attributable mortality (CANCER).txt"
)
path_aaf <- latest_dated_project_file(
  directory = file.path(project_root, "__andres_control"),
  prefix = "aaf_nested_by_disease_",
  extension = ".rds"
)
path_deis_2012_2023 <- acc_data("_deis/DEFUNCIONES_DEIS_2012_2023_15plus.tar.xz.enc")
# DEIS 2024+ is read with acc_deis() (newest weekly bundle, or the one pinned by ACC_DEIS_VERSION); this is only a label.
path_deis_2024 <- "_deis/ newest DEFUNCIONES_FUENTE_DEIS_2024_2026 bundle (acc_deis())"
out_dir <- file.path(project_root, "jrt", "cancer_20260702")
verbose_message("Input path - JRT cancer table: ", path_jrt)
verbose_message("Input path - AAF nested bundle: ", path_aaf)
verbose_message("Input path - DEIS 2012-2023 parquet: ", path_deis_2012_2023)
verbose_message("Input path - DEIS 2024 CSV: ", path_deis_2024)
verbose_message("Output directory: ", out_dir)
# ------------------------------------------------------------------
# 4. Sanity-check required files
# ------------------------------------------------------------------
required_files <- c(path_jrt, path_aaf, path_deis_2012_2023)
missing_files <- required_files[!file.exists(required_files)]
if (length(missing_files) > 0) {
  stop("Missing required file(s): ", paste(missing_files, collapse = "; "))
}
verbose_message("All required input files exist.")
for (path_i in required_files) {
  verbose_message("  - ", basename(path_i), " (", format_file_size(path_i), ")")
}
# ------------------------------------------------------------------
# 5. Helper functions
# ------------------------------------------------------------------
# Generate ICD-10 codes at 3-character + suffix level.
# letter  = leading letter (e.g. "C")
# numbers = numeric stems (e.g. 18:21)
# suffix  = final digit/character (default 0-9 + X)
icd_codes_s6 <- function(letter, numbers, suffix = c(0:9, "X")) {
  as.vector(outer(sprintf("%s%02d", letter, numbers), suffix, paste0))
}
# Strip non-alphanumeric characters and force upper-case for ICD-10 codes
clean_icd10 <- function(x) {
  out <- toupper(gsub("[^A-Za-z0-9]", "", as.character(x)))
  out[is.na(x)] <- NA_character_
  out
}
# Extract one component (point, lower, upper) from strings like "0.12 (0.08,0.16)"
parse_aaf_ci <- function(x, group_index) {
  match <- stringr::str_match(
    x,
    "^\\s*(-?[0-9.]+)\\s*\\((-?[0-9.]+),\\s*(-?[0-9.]+)\\)\\s*$"
  )
  as.numeric(match[, group_index])
}
# Pull one cancer AAF table out of aaf_unified and reshape to long format
extract_aaf_unified_table <- function(cancer_tables, table_name, disease_i, sex_i) {
  tbl <- cancer_tables[[table_name]]
  if (is.null(tbl)) {
    stop("Missing aaf_unified cancer table: ", table_name)
  }
  prefix <- if (sex_i == "Female") "Fem" else "Male"
  age_group_map <- c("1" = "15-29", "2" = "30-44", "3" = "45-59", "4" = "60+")
  dplyr::bind_rows(lapply(names(age_group_map), function(group_i) {
    tbl |>
      dplyr::transmute(
        Year = as.integer(Year),
        disease = disease_i,
        sex = sex_i,
        age_group = unname(age_group_map[[group_i]]),
        AAF = .data[[paste0(prefix, group_i, "_point")]],
        LL = .data[[paste0(prefix, group_i, "_lower")]],
        UL = .data[[paste0(prefix, group_i, "_upper")]]
      )
  }))
}
# ------------------------------------------------------------------
# 6. Load JRT reference table (Excel exported as tab-delimited)
# ------------------------------------------------------------------
verbose_message("[", sprintf("%.2f", elapsed_minutes()), " min] Reading JRT reference table.")
ref_cancer <- readr::read_tsv(
  path_jrt,
  locale = readr::locale(decimal_mark = ","),
  show_col_types = FALSE
)
# Keep the unique Year x disease x sex x age_group combinations present in JRT
ref_keys <- ref_cancer |>
  dplyr::distinct(Year, disease, sex, age_group)
target_years <- sort(unique(ref_cancer$Year))
verbose_message("JRT rows read: ", format_integer(nrow(ref_cancer)))
verbose_message("Distinct JRT comparison keys: ", format_integer(nrow(ref_keys)))
verbose_message("Target years: ", paste(target_years, collapse = ", "))
verbose_message("Cancer diseases in JRT: ", paste(sort(unique(ref_cancer$disease)), collapse = "; "))
# ------------------------------------------------------------------
# 7. Read and reshape aaf_unified cancer AAF estimates
# ------------------------------------------------------------------
verbose_message("[", sprintf("%.2f", elapsed_minutes()), " min] Reading AAF bundle.")
aaf_unified <- readRDS(path_aaf)
cancer_tables <- aaf_unified[["family_bundles"]][["cancer"]][["raw_result"]][["tables"]]
if (is.null(cancer_tables)) {
  stop("Could not find cancer aaf_unified tables in: ", path_aaf)
}
verbose_message("Cancer AAF tables available: ", length(cancer_tables))
verbose_message("Cancer AAF table names: ", paste(names(cancer_tables), collapse = "; "))
# Map each internal aaf_unified cancer table name to disease label and sex
aaf_table_map <- data.frame(
  table_name = c(
    "bcan_female",
    "crcan_female", "crcan_male",
    "lxcan_female", "lxcan_male",
    "lican_female", "lican_male",
    "oescan_female", "oescan_male",
    "locan_female", "locan_male",
    "panccan_female", "panccan_male",
    "stomcan_female", "stomcan_male"
  ),
  disease = c(
    "Breast Cancer",
    "Colorectal Cancer", "Colorectal Cancer",
    "Larynx Cancer", "Larynx Cancer",
    "Liver Cancer", "Liver Cancer",
    "Oesophagus Cancer", "Oesophagus Cancer",
    "Oral Cavity and Pharynx Cancer", "Oral Cavity and Pharynx Cancer",
    "Pancreatic Cancer", "Pancreatic Cancer",
    "Stomach Cancer", "Stomach Cancer"
  ),
  sex = c(
    "Female",
    "Female", "Male",
    "Female", "Male",
    "Female", "Male",
    "Female", "Male",
    "Female", "Male",
    "Female", "Male",
    "Female", "Male"
  ),
  stringsAsFactors = FALSE
)
# Combine all cancer AAF tables into one long data frame, restricted to JRT years
aaf_long_can <- dplyr::bind_rows(lapply(seq_len(nrow(aaf_table_map)), function(i) {
  extract_aaf_unified_table(
    cancer_tables = cancer_tables,
    table_name = aaf_table_map$table_name[[i]],
    disease_i = aaf_table_map$disease[[i]],
    sex_i = aaf_table_map$sex[[i]]
  )
})) |>
  dplyr::filter(Year %in% target_years)
verbose_message("Cancer AAF map rows requested: ", format_integer(nrow(aaf_table_map)))
verbose_message("Long cancer AAF rows after year filter: ", format_integer(nrow(aaf_long_can)))
verbose_message(
  "Long cancer AAF diseases: ",
  paste(sort(unique(aaf_long_can$disease)), collapse = "; ")
)
# ------------------------------------------------------------------
# 8. Load DEIS mortality data (2012-2023 parquet + 2024 CSV)
# ------------------------------------------------------------------
# 2026-07-07= Use nanoparquet instead
verbose_message("[", sprintf("%.2f", elapsed_minutes()), " min] Reading DEIS 2012-2023 parquet.")
deis_2012_2023 <- nanoparquet::read_parquet(path_deis_2012_2023) |>
  dplyr::transmute(
    year = as.integer(year),
    gender = as.character(gender),
    age = as.integer(age),
    diag1 = as.character(diag1),
    diag2 = as.character(diag2)
  )
verbose_message("DEIS 2012-2023 rows after column standardization: ", format_integer(nrow(deis_2012_2023)))
# 2024 file has a different layout; detect the year column by position
verbose_message("[", sprintf("%.2f", elapsed_minutes()), " min] Reading DEIS 2024 CSV.")
deis_2024_raw <- acc_deis()
year_col_2024 <- names(deis_2024_raw)[1]
verbose_message("DEIS 2024 raw rows: ", format_integer(nrow(deis_2024_raw)))
verbose_message("DEIS 2024 year column detected by position: ", year_col_2024)
# Keep only 2024 records with completed age (EDAD_TIPO == 1)
deis_2024 <- deis_2024_raw |>
  dplyr::transmute(
    year = as.integer(.data[[year_col_2024]]),
    gender = as.character(.data[["SEXO_NOMBRE"]]),
    age_type = as.integer(.data[["EDAD_TIPO"]]),
    age = as.integer(.data[["EDAD_CANT"]]),
    diag1 = as.character(.data[["DIAG1"]]),
    diag2 = as.character(.data[["DIAG2"]])
  ) |>
  dplyr::filter(year == 2024, age_type == 1) |>
  dplyr::select(-age_type)
verbose_message("DEIS 2024 rows after year and completed-age filters: ", format_integer(nrow(deis_2024)))
# ------------------------------------------------------------------
# 9. Standardize combined mortality: sex, age group, clean DIAG1
# ------------------------------------------------------------------
verbose_message("[", sprintf("%.2f", elapsed_minutes()), " min] Standardizing combined mortality records.")
mortality <- dplyr::bind_rows(deis_2012_2023, deis_2024) |>
  dplyr::filter(year %in% target_years, age >= 15) |>
  dplyr::mutate(
    sex = dplyr::case_when(
      gender == "Mujer" ~ "Female",
      gender == "Hombre" ~ "Male",
      TRUE ~ NA_character_
    ),
    age_group = dplyr::case_when(
      dplyr::between(age, 15, 29) ~ "15-29",
      dplyr::between(age, 30, 44) ~ "30-44",
      dplyr::between(age, 45, 59) ~ "45-59",
      age >= 60 ~ "60+",
      TRUE ~ NA_character_
    ),
    DIAG1_s6 = clean_icd10(diag1)
  ) |>
  dplyr::filter(!is.na(sex), !is.na(age_group))
verbose_message("Combined mortality rows after filters: ", format_integer(nrow(mortality)))
verbose_message("Mortality years retained: ", paste(sort(unique(mortality$year)), collapse = ", "))
verbose_message("Mortality age groups retained: ", paste(sort(unique(mortality$age_group)), collapse = ", "))
# ------------------------------------------------------------------
# 10. Map ICD-10 codes to cancer disease categories
# ------------------------------------------------------------------
cancer_code_map <- list(
  "Breast Cancer" = icd_codes_s6("C", 50),
  "Colorectal Cancer" = icd_codes_s6("C", 18:21),
  "Larynx Cancer" = icd_codes_s6("C", 32),
  "Liver Cancer" = icd_codes_s6("C", 22),
  "Oesophagus Cancer" = icd_codes_s6("C", 15),
  # 2026-07-02= I did exclude C11: C00-C10 + C12-C14 
  # Shield / OMS-aligned = C00-C08 + C09-C10 + C12-C14
  # 2026-07-04= This JRT comparison intentionally includes C11 through C00-C14.
  "Oral Cavity and Pharynx Cancer" = icd_codes_s6("C", 0:14),
  "Pancreatic Cancer" = icd_codes_s6("C", 25),
  "Stomach Cancer" = icd_codes_s6("C", 16)
)
# Count deaths by Year/disease/sex/age_group for each cancer category
verbose_message("[", sprintf("%.2f", elapsed_minutes()), " min] Counting deaths by cancer category.")
verbose_message("Cancer ICD-10 category count: ", length(cancer_code_map))
mortality_counts <- dplyr::bind_rows(lapply(names(cancer_code_map), function(disease_i) {
  mortality |>
    dplyr::filter(DIAG1_s6 %in% cancer_code_map[[disease_i]]) |>
    dplyr::count(
      Year = year,
      disease = disease_i,
      sex,
      age_group,
      name = "muertes"
    )
}))
verbose_message("Mortality count rows: ", format_integer(nrow(mortality_counts)))
verbose_message("Total cancer deaths counted across mapped categories: ", format_integer(sum(mortality_counts$muertes)))
# ------------------------------------------------------------------
# 11. Build pipeline cancer alcohol-attributable mortality estimates
# ------------------------------------------------------------------
verbose_message("[", sprintf("%.2f", elapsed_minutes()), " min] Joining JRT keys, AAF values, and mortality counts.")
pipeline_cancer <- ref_keys |>
  dplyr::left_join(
    aaf_long_can,
    by = c("Year", "disease", "sex", "age_group")
  ) |>
  dplyr::left_join(
    mortality_counts,
    by = c("Year", "disease", "sex", "age_group")
  ) |>
  dplyr::mutate(
    muertes = dplyr::coalesce(muertes, 0L),
    att_mort = round(AAF * muertes),
    att_mort_low = round(LL * muertes),
    att_mort_up = round(UL * muertes)
  ) |>
  dplyr::arrange(disease, Year, sex, age_group) |>
  dplyr::select(
    Year, disease, sex, age_group, AAF, LL, UL, muertes,
    att_mort, att_mort_low, att_mort_up
  )
verbose_message("Pipeline cancer rows: ", format_integer(nrow(pipeline_cancer)))
verbose_message("Pipeline cancer rows with zero mortality counts: ", format_integer(sum(pipeline_cancer$muertes == 0L)))
verbose_message("Pipeline cancer total deaths: ", format_integer(sum(pipeline_cancer$muertes)))
verbose_message("Pipeline cancer total attributable deaths: ", format_integer(sum(pipeline_cancer$att_mort, na.rm = TRUE)))
# Stop if any AAF/CI values are missing after the join
if (anyNA(pipeline_cancer[c("AAF", "LL", "UL")])) {
  missing_aaf <- pipeline_cancer |>
    dplyr::filter(is.na(AAF) | is.na(LL) | is.na(UL)) |>
    dplyr::select(Year, disease, sex, age_group)
  stop("Missing aaf_unified values after join: ", utils::capture.output(print(missing_aaf)))
}
verbose_message("AAF, LL, and UL columns have no missing values after join.")
# 2026-07-02= I did not include the 60+ age group in the original JRT table, 
# but I will include it here for comparison.
pipeline_cancer_60plus <- pipeline_cancer |>
  dplyr::filter(age_group == "60+")
verbose_message("Pipeline cancer 60+ rows: ", format_integer(nrow(pipeline_cancer_60plus)))
# ------------------------------------------------------------------
# 12. Compare pipeline estimates against JRT reference
# ------------------------------------------------------------------
verbose_message("[", sprintf("%.2f", elapsed_minutes()), " min] Comparing pipeline estimates against JRT reference.")
cancer_compare_comparable <- pipeline_cancer |>
  dplyr::full_join(
    ref_cancer,
    by = c("Year", "disease", "sex", "age_group"),
    suffix = c("_pipeline", "_jrt")
  ) |>
  dplyr::mutate(
    diff_AAF = AAF_pipeline - AAF_jrt,
    diff_muertes = muertes_pipeline - muertes_jrt,
    diff_att_mort = att_mort_pipeline - att_mort_jrt
  ) |>
  dplyr::arrange(disease, Year, sex, age_group)

cancer_compare_60plus <- cancer_compare_comparable |>
  dplyr::filter(age_group == "60+")
verbose_message("All-age comparison rows: ", format_integer(nrow(cancer_compare_comparable)))
verbose_message("60+ comparison rows: ", format_integer(nrow(cancer_compare_60plus)))
# ------------------------------------------------------------------
# 13. Write outputs
# ------------------------------------------------------------------
verbose_message("[", sprintf("%.2f", elapsed_minutes()), " min] Writing output tables.")
readr::write_tsv(
  pipeline_cancer,
  file.path(out_dir, "pipeline_cancer_aam_jrt_compatible_all_ages.txt")
)
readr::write_tsv(
  pipeline_cancer_60plus,
  file.path(out_dir, "pipeline_cancer_aam_jrt_compatible_60plus.txt")
)
readr::write_csv(
  cancer_compare_comparable,
  file.path(out_dir, "pipeline_vs_jrt_cancer_all_ages.csv")
)
readr::write_csv(
  cancer_compare_60plus,
  file.path(out_dir, "pipeline_vs_jrt_cancer_60plus.csv")
)
verbose_message("Wrote: ", file.path(out_dir, "pipeline_cancer_aam_jrt_compatible_all_ages.txt"))
verbose_message("Wrote: ", file.path(out_dir, "pipeline_cancer_aam_jrt_compatible_60plus.txt"))
verbose_message("Wrote: ", file.path(out_dir, "pipeline_vs_jrt_cancer_all_ages.csv"))
verbose_message("Wrote: ", file.path(out_dir, "pipeline_vs_jrt_cancer_60plus.csv"))
# ------------------------------------------------------------------
# 14. Validation checks
# ------------------------------------------------------------------
verbose_message("[", sprintf("%.2f", elapsed_minutes()), " min] Running validation checks.")
if (nrow(pipeline_cancer) != 420L) {
  stop("Unexpected all-age row count: ", nrow(pipeline_cancer))
}
if (nrow(pipeline_cancer_60plus) != 105L) {
  stop("Unexpected 60+ row count: ", nrow(pipeline_cancer_60plus))
}
if (nrow(cancer_compare_comparable) != 420L) {
  stop("Unexpected comparison row count: ", nrow(cancer_compare_comparable))
}
if (nrow(cancer_compare_60plus) != 105L) {
  stop("Unexpected 60+ comparison row count: ", nrow(cancer_compare_60plus))
}
verbose_message("Validation checks passed.")
# ------------------------------------------------------------------
# 15. Summary messages and elapsed time
# ------------------------------------------------------------------
max_abs_diff_muertes <- max(abs(cancer_compare_comparable$diff_muertes), na.rm = TRUE)
message("Final comparison rows: ", nrow(cancer_compare_comparable))
message("Max abs mortality-count difference: ", max_abs_diff_muertes)
message(sprintf(
  "[%.2f min] Rebuilt JRT-compatible cancer comparison.",
  elapsed_minutes()
))
