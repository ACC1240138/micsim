# =============================================================================
# ypll_icd_defs.R   [2026-07-14]
# -----------------------------------------------------------------------------
# The death-record layer for the YPLL/YLL rebuild: the ICD-10 map, the per-death
# indicator columns, the age bands, and the two resolvers that let us reconcile a
# rebuilt death base against the death counts the PIF pipeline already uses.
#
# *** THIS FILE DUPLICATES THE ICD-10 MAP THAT LIVES IN expand_pif.ipynb. ***
# That duplication is a real hazard and it is deliberate: a .ipynb cannot be
# source()d, so a build script has no way to reuse the notebook's map. If the
# notebook ever changes its map (a code list, a DIAG1-vs-DIAG2 rule, an age band),
# THIS FILE SILENTLY DIVERGES and the YPLL starts describing a different population
# than the PIF it gets multiplied by.
#
# Because this file duplicates the ICD-10 map that lives in expand_pif.ipynb, the two
# can drift apart silently if either one changes. That divergence would mean the YPLL
# is computed for a different set of deaths than the PIF it is later multiplied by, so
# the attributable and avoidable YPLL figures would no longer match the rest of the
# pipeline.
#
# test_ypll_death_base.R is the safeguard: it rebuilds the deaths from these
# definitions and asserts they reproduce the pipeline's own counts exactly, cell for
# cell (1188/1188, max |diff| = 0). It is a hard stop(). Run it whenever the AAF bundle,
# the mortality export, or expand_pif.ipynb changes. A failing test means the YPLL base
# is out of sync with the pipeline and must be reconciled before any result is used;
# do not paper over a partial match.
#
# Source of the map: expand_pif.ipynb, cells `mort-trends-age-sex-chile11-...` and
# `mort-trends-age-sex-chile12-join-aaf-w-mortality` (Shield et al. 2025, Table S6).
# =============================================================================

suppressPackageStartupMessages({
  library(dplyr); library(purrr); library(tibble)
})

# --- ICD-10 helpers (Shield 2025 Table S6 normalisation) ----------------------
# icd_codes_s6("C", 22) -> C220..C229, C22X : a 3-character stem expanded over its
# 4th-character suffixes. clean_icd10 strips punctuation and upper-cases, because the
# DEIS files are inconsistent about "C22.0" vs "C220".
icd_codes_s6 <- function(letter, numbers, suffix = c(0:9, "X")) {
  as.vector(outer(sprintf("%s%02d", letter, numbers), suffix, paste0))
}
icd_stems_s6 <- function(stems, suffix = c(0:9, "X")) as.vector(outer(stems, suffix, paste0))
clean_icd10  <- function(x) toupper(gsub("[^A-Za-z0-9]", "", x))

# --- Code lists ---------------------------------------------------------------
# Two exclusions are load-bearing and easy to lose:
#   K860  : alcohol-induced chronic pancreatitis -> it is 100% attributable, so it is
#           NOT part of the Acute Pancreatitis dose-response cause.
#   X65   : alcohol self-poisoning -> likewise 100% attributable, removed from
#           self-harm so it is not double-counted.
pancreati_oh_codes <- "K860"
x65_alcohol_self_poisoning_codes_aff1 <- icd_stems_s6("X65")

epilepsy_codes <- icd_codes_s6("G", 40:41)
hhd_codes      <- icd_codes_s6("I", 10:15)
ihd_codes      <- icd_codes_s6("I", 20:25)
ich_codes <- unique(c(icd_codes_s6("I", 60:62), c("I670", "I671"), c("I690", "I691", "I692")))
is_codes  <- unique(c(icd_codes_s6("G", 45), paste0("G46", 0:8), icd_codes_s6("I", 63),
                      icd_codes_s6("I", 65:66), paste0("I67", 2:8), c("I693", "I694")))
locan_codes   <- icd_codes_s6("C", 0:8)                                        # lip & oral cavity
opcan_codes   <- unique(c(icd_codes_s6("C", 9:10), icd_codes_s6("C", 12:14)))  # other pharyngeal
oescan_codes  <- icd_codes_s6("C", 15)
crcan_codes   <- icd_codes_s6("C", 18:21)
lican_codes   <- icd_codes_s6("C", 22)
lxcan_codes   <- icd_codes_s6("C", 32)
brcan_codes   <- icd_codes_s6("C", 50)
stom_codes    <- icd_codes_s6("C", 16)
panccan_codes <- icd_codes_s6("C", 25)
dm2_codes  <- setdiff(icd_codes_s6("E", 10:14), c("E102", "E112", "E122", "E132", "E142"))
tb_codes   <- unique(c(icd_codes_s6("A", 15:19), icd_codes_s6("B", 90)))
hiv_codes  <- icd_codes_s6("B", 20:24)
lri_codes  <- unique(c(icd_codes_s6("J", 9:22), icd_codes_s6("P", 23), icd_codes_s6("U", 4)))
lc_codes   <- unique(c(icd_codes_s6("K", 70), icd_codes_s6("K", 74)))
panc_codes <- setdiff(icd_codes_s6("K", 85:86), pancreati_oh_codes)

ri_codes <- unique(c(icd_stems_s6(sprintf("V0%d", 1:4)), icd_stems_s6("V06"),
                     icd_stems_s6(sprintf("V%02d", 9:80)), icd_stems_s6("V87"),
                     icd_stems_s6("V89"), icd_stems_s6("V99")))
poisonings_codes <- unique(c(icd_stems_s6("X40"), icd_stems_s6("X43"),
                             icd_stems_s6(sprintf("X%02d", 46:48)), icd_stems_s6("X49")))
falls_codes             <- icd_codes_s6("W", 0:19)
fire_heat_codes         <- icd_codes_s6("X", 0:19)
drowning_codes          <- icd_codes_s6("W", 65:74)
mechanical_forces_codes <- unique(c(icd_codes_s6("W", 20:38), icd_codes_s6("W", 40:43),
  icd_stems_s6("W45"), icd_stems_s6("W46"), icd_codes_s6("W", 49:52),
  icd_stems_s6("W75"), icd_stems_s6("W76")))
all_v_codes <- icd_codes_s6("V", 1:99)
other_unintentional_codes <- unique(c(setdiff(all_v_codes, ri_codes), icd_stems_s6("W39"),
  icd_stems_s6("W44"), icd_codes_s6("W", 53:64), icd_codes_s6("W", 77:99),
  icd_codes_s6("X", 20:29), icd_codes_s6("X", 50:59), icd_codes_s6("Y", 40:86),
  icd_stems_s6("Y88"), icd_stems_s6("Y89")))
unint_inj_codes <- unique(c(ri_codes, poisonings_codes, falls_codes, fire_heat_codes,
                            drowning_codes, mechanical_forces_codes, other_unintentional_codes))
self_harm_codes <- setdiff(unique(c(icd_codes_s6("X", 60:84), "Y870")),
                           x65_alcohol_self_poisoning_codes_aff1)
interpersonal_violence_codes <- unique(c(icd_codes_s6("X", 85:99), icd_codes_s6("Y", 0:9), "Y871"))
int_inj_codes <- unique(c(self_harm_codes, interpersonal_violence_codes))

# --- indicator column -> disease string, and which sexes the cause exists for ----
# These 23 strings ARE the join keys. They must match pif2_aaf_long / the mortality
# export byte for byte, or the join silently drops rows.
# Breast Cancer is female-only: emitting a male row would create a cell the AAF side
# does not have.
ypll_disease_filters <- list(
  "Breast Cancer"                  = list(col = "bcan",             genders = "Mujer"),
  "Liver Cancer"                   = list(col = "lican",            genders = c("Mujer", "Hombre")),
  "Larynx Cancer"                  = list(col = "lxcan",            genders = c("Mujer", "Hombre")),
  "Oesophagus Cancer"              = list(col = "oescan",           genders = c("Mujer", "Hombre")),
  "Oral Cavity and Pharynx Cancer" = list(col = "locan",            genders = c("Mujer", "Hombre")),
  "Other Pharyngeal Cancer"        = list(col = "opcan",            genders = c("Mujer", "Hombre")),
  "Colon and rectum Cancer"        = list(col = "crcan",            genders = c("Mujer", "Hombre")),
  "Stomach Cancer"                 = list(col = "stomcan",          genders = c("Mujer", "Hombre")),
  "Pancreatic Cancer"              = list(col = "panccan",          genders = c("Mujer", "Hombre")),
  "Acute Pancreatitis"             = list(col = "panc",             genders = c("Mujer", "Hombre")),
  "Epilepsy"                       = list(col = "epi",              genders = c("Mujer", "Hombre")),
  "DM2"                            = list(col = "dm2",              genders = c("Mujer", "Hombre")),
  "HIV"                            = list(col = "hiv",              genders = c("Mujer", "Hombre")),
  "Hypertensive Heart Disease"     = list(col = "hhd",              genders = c("Mujer", "Hombre")),
  "Intracerebral Haemorrhage"      = list(col = "ich",              genders = c("Mujer", "Hombre")),
  "Ischaemic Heart Disease"        = list(col = "ihd",              genders = c("Mujer", "Hombre")),
  "Ischaemic Stroke"               = list(col = "is",               genders = c("Mujer", "Hombre")),
  "Liver Cirrhosis"                = list(col = "lc",               genders = c("Mujer", "Hombre")),
  "Lower Respiratory Infection"    = list(col = "lri",              genders = c("Mujer", "Hombre")),
  "Road Injuries"                  = list(col = "ri_inj",           genders = c("Mujer", "Hombre")),
  "Tuberculosis"                   = list(col = "tb",               genders = c("Mujer", "Hombre")),
  "Unintentional Injuries"         = list(col = "unint_inj_noroad", genders = c("Mujer", "Hombre")),
  "Intentional Injuries"           = list(col = "int_inj",          genders = c("Mujer", "Hombre"))
)

# =============================================================================
# PATHS. Anchored to the project root (acc_root()); no machine-specific path. Files are still
# resolved BY EMBEDDED DATE, never by modified time -- see the stale-file trap below.
# =============================================================================
if (!exists("acc_root")) source(here::here("_tools", "acc_data.R"))   # acc_root(), acc_data(), acc_deis()
YPLL_ROOT      <- acc_root()
YPLL_CONTROL   <- file.path(YPLL_ROOT, "__andres_control")
YPLL_DEATH_DIR <- file.path(YPLL_ROOT, "_deis")   # encrypted DEIS bundles, read through acc_data() / acc_deis()

# [2026-07-15] RESOLVE BY EMBEDDED DATE, not by a hard-coded name.
# History: expand_pif.ipynb used to write the mortality export UNDATED
# ("Mortality Estimates WHO 2024.xlsx"). Three undated files matched the notebook's
# picker (WHO 2024 / _adam / _ags), so selection fell back to MODIFIED TIME -- and
# merely re-saving _adam.xlsx would silently switch the whole mortality basis. That is
# why this used to be a hard-coded name.
# As of 2026-07-15 expand_pif.ipynb writes the export WITH a date stamp
# ("Mortality Estimates WHO 2024_YYYYMMDD.xlsx"), matching how it already stamps the AAF
# bundles. So "latest embedded date" is now unambiguous and safe, and it keeps this
# toolchain in lock-step with the notebook's own picker instead of drifting to a stale
# hard-coded pair after a re-run.
.ypll_latest_by_date <- function(dir, pattern, fallback = NULL) {
  files <- list.files(dir, pattern = pattern, full.names = TRUE)
  if (!length(files)) {
    if (!is.null(fallback) && file.exists(fallback)) return(fallback)
    stop(".ypll_latest_by_date: no file matches '", pattern, "' in ", dir)
  }
  dates <- as.Date(sub(".*?([0-9]{8}).*", "\\1", basename(files)), format = "%Y%m%d")
  # Undated files (no YYYYMMDD) get NA; keep them only as a last resort behind the
  # dated ones, so a fresh dated export always wins over the legacy undated one.
  ord <- order(dates, file.mtime(files), decreasing = TRUE, na.last = TRUE)
  files[ord][1L]
}

# Mortality export. Prefer the newest DATED file; fall back to the legacy undated name
# so this still resolves before the first dated re-run exists.
YPLL_MORTALITY_XLSX <- .ypll_latest_by_date(
  YPLL_CONTROL,
  pattern  = "^Mortality Estimates WHO 2024(_[0-9]{8})?\\.xlsx$",
  fallback = file.path(YPLL_CONTROL, "Mortality Estimates WHO 2024.xlsx")
)

# AAF bundle. Must be the SAME run the mortality export came from: deaths_total = mort/aaf
# must be a whole number, and the gate test's integrality assert is the ONLY thing tying
# the two artifacts together. Picking the latest of each is consistent AS LONG AS both are
# regenerated by the same expand_pif run (they share Sys.Date()); if they ever get out of
# step, the gate fires -- which is exactly what it is for. Re-run test_ypll_death_base.R
# after any expand_pif re-run.
YPLL_AAF_BUNDLE <- .ypll_latest_by_date(
  YPLL_CONTROL,
  pattern = "^aaf_nested_by_disease_[0-9]{8}\\.rds$"
)

# =============================================================================
# ypll_build_deaths(): the per-death frame, 15-65, 2012-2024, with the disease flags
# =============================================================================
# Reproduces expand_pif.ipynb's own load + filter + indicator block exactly.
#
# NOTE ON THE AGE BANDS. The case_when says `age >= 60 ~ 4`, but a `filter(age <= 65)`
# runs BEFORE it, so band 4 is effectively 60-65, CLOSED. That closure matters more
# than it looks: the legacy YPLL artifact left band 4 OPEN at 60+, which under its
# pmax(e0 - age, 0) convention assigned EXACTLY ZERO years lost to every death above
# e0 (~77 male / ~82 female). 51% of its >65 injury deaths contributed zero. Our closed
# 15-65 frame is immune to that: no death in 60-65 can exceed e0, so the floor never bites.
#
# NOTE ON DIAG1 vs DIAG2. Chronic causes match on the underlying cause (DIAG1) only.
# The three injury causes match on DIAG1 *or* DIAG2, because external causes are coded
# in the secondary field. Getting this backwards silently changes the injury counts.
#
# RESOLVED 2026-07-15 (edad_tipo). In the 2024 file, `edad_cant` is measured in
# years only when `edad_tipo == 1`. Both expand_pif.ipynb and this independent
# rebuild now apply that guard before the 15-65 filter. The resulting wave-year
# base contains 117,918 deaths (117,944 before the 2026-10-05 DEIS 2012-2023 infant fix) and reconciles exactly in all 1,188 cells. Keeping
# the same guard on both sides prevents infants recorded in days or hours from
# being misclassified as adults.
ypll_build_deaths <- function(death_dir = YPLL_DEATH_DIR) {
  # death_dir is kept only so existing callers do not break; the deaths come from the encrypted bundles.
  m21 <- rio::import(acc_data("_deis/DEFUNCIONES_DEIS_2012_2023_15plus.tar.xz.enc")) |>
    janitor::clean_names() |>
    dplyr::filter(age <= 65) |>
    dplyr::filter(year >= 2012, age >= 15)

  m24 <- acc_deis() |>
    janitor::clean_names() |>
    dplyr::filter(edad_tipo == 1, edad_cant <=65) |>   # 2026-07-15 edad_tipo==1 => age in YEARS; exclude infants with days/hours old
    dplyr::transmute(
      year = ano, gender = sexo_nombre, age = edad_cant,
      age_group = dplyr::case_when(dplyr::between(age, 15, 29) ~ 1,
                                   dplyr::between(age, 30, 44) ~ 2,
                                   dplyr::between(age, 45, 59) ~ 3,
                                   age >= 60 ~ 4),
      diag1, diag2) |>
    dplyr::filter(year == 2024, age >= 15)

  # The notebook also carries comuna/region here, via iconv(., "latin1", "UTF-8"). We
  # drop them: the YPLL needs none of it, and that iconv is exactly the mojibake source
  # AGENTS.md warns about (it emits "input string is invalid UTF-8" on the real file).
  # Keep only the columns both files share, so rbind cannot bind by position.
  keep <- c("year", "gender", "age", "age_group", "diag1", "diag2")
  mort <- rbind.data.frame(m21[, keep], m24[, keep])

  mort |>
    dplyr::mutate(DIAG1_s6 = clean_icd10(diag1), DIAG2_s6 = clean_icd10(diag2)) |>
    dplyr::mutate(
      # --- chronic causes: underlying cause (DIAG1) only ---
      epi     = dplyr::if_else(DIAG1_s6 %in% epilepsy_codes, 1, 0),
      ich     = dplyr::if_else(DIAG1_s6 %in% ich_codes, 1, 0),
      is      = dplyr::if_else(DIAG1_s6 %in% is_codes, 1, 0),
      hhd     = dplyr::if_else(DIAG1_s6 %in% hhd_codes, 1, 0),
      bcan    = dplyr::if_else(DIAG1_s6 %in% brcan_codes, 1, 0),
      crcan   = dplyr::if_else(DIAG1_s6 %in% crcan_codes, 1, 0),
      lxcan   = dplyr::if_else(DIAG1_s6 %in% lxcan_codes, 1, 0),
      lican   = dplyr::if_else(DIAG1_s6 %in% lican_codes, 1, 0),
      oescan  = dplyr::if_else(DIAG1_s6 %in% oescan_codes, 1, 0),
      locan   = dplyr::if_else(DIAG1_s6 %in% locan_codes, 1, 0),
      opcan   = dplyr::if_else(DIAG1_s6 %in% opcan_codes, 1, 0),
      stomcan = dplyr::if_else(DIAG1_s6 %in% stom_codes, 1, 0),
      panccan = dplyr::if_else(DIAG1_s6 %in% panccan_codes, 1, 0),
      dm2     = dplyr::if_else(DIAG1_s6 %in% dm2_codes, 1, 0),
      ihd     = dplyr::if_else(DIAG1_s6 %in% ihd_codes, 1, 0),
      lri     = dplyr::if_else(DIAG1_s6 %in% lri_codes, 1, 0),
      tb      = dplyr::if_else(DIAG1_s6 %in% tb_codes, 1, 0),
      panc    = dplyr::if_else(DIAG1_s6 %in% panc_codes, 1, 0),
      lc      = dplyr::if_else(DIAG1_s6 %in% lc_codes, 1, 0),
      hiv     = dplyr::if_else(DIAG1_s6 %in% hiv_codes, 1, 0),
      # --- injuries: DIAG1 OR DIAG2 ---
      ri_inj  = dplyr::if_else(DIAG1_s6 %in% ri_codes | DIAG2_s6 %in% ri_codes, 1, 0),
      int_inj = dplyr::if_else(DIAG1_s6 %in% int_inj_codes | DIAG2_s6 %in% int_inj_codes, 1, 0),
      unint_inj_noroad = dplyr::if_else(
        (DIAG1_s6 %in% unint_inj_codes | DIAG2_s6 %in% unint_inj_codes) &
          !(DIAG1_s6 %in% ri_codes | DIAG2_s6 %in% ri_codes), 1, 0)
    ) |>
    dplyr::mutate(age_group = dplyr::case_when(
      dplyr::between(age, 15, 29) ~ 1, dplyr::between(age, 30, 44) ~ 2,
      dplyr::between(age, 45, 59) ~ 3, age >= 60 ~ 4)) |>
    dplyr::filter(age >= 15)
}

# =============================================================================
# ypll_deaths_long(): one row per (year, gender, age_group, disease) with a death count
# =============================================================================
# Long-form death counts keyed exactly like the AAF side. This is what the gate test
# compares against the pipeline's own n = mort/AAF.
ypll_deaths_long <- function(def) {
  purrr::imap_dfr(ypll_disease_filters, function(spec, disease) {
    def |>
      dplyr::filter(.data[[spec$col]] == 1, gender %in% spec$genders) |>
      dplyr::count(year, gender, age_group, name = "deaths") |>
      dplyr::mutate(disease = disease)
  }) |>
    dplyr::select(year, gender, age_group, disease, deaths) |>
    dplyr::arrange(disease, year, gender, age_group)
}

# =============================================================================
# ypll_pipeline_deaths(): recover the deaths the PIF pipeline ACTUALLY uses
# =============================================================================
# The pipeline never stores total deaths. It reconstructs them at runtime as
#     deaths_total = mort / aaf
# where `mort` is the attributable-death estimate in the mortality export and `aaf` is
# the point AAF from the bundle. (Both are unrounded, so the ratio is the raw ICD count
# to ~1e-13.)
#
# *** THE abs() GUARD IS LOAD-BEARING. ***
# The guard MUST be abs(aaf) > 0, NOT aaf > 0. In cardioprotective cells the AAF is
# NEGATIVE and so is `mort`, and their ratio is still the correct POSITIVE count. Using
# `aaf > 0` NAs exactly 68 cells (Ischaemic Stroke H+M: 56; DM2 Mujer: 12) which then
# vanish silently from every na.rm=TRUE sum -- taking all of Ischaemic Stroke with them.
ypll_pipeline_deaths <- function(xlsx = YPLL_MORTALITY_XLSX, bundle = YPLL_AAF_BUNDLE) {
  mort <- readxl::read_xlsx(xlsx) |>
    dplyr::mutate(year = as.integer(year), age_group = as.integer(age_group))

  b <- readRDS(bundle)
  aaf <- purrr::map_dfr(b$by_disease, function(d) {
    purrr::imap_dfr(d$outputs, function(o, output_name) {
      tb <- o$table
      prefix <- if (any(grepl("^Fem", names(tb)))) "Fem" else "Male"
      gv <- if (identical(prefix, "Fem")) "Mujer" else "Hombre"
      purrr::map_dfr(1:4, function(g) {
        col <- paste0(prefix, g, "_point")
        if (!col %in% names(tb)) return(NULL)
        tibble::tibble(year = as.integer(tb$Year), age_group = as.integer(g),
                       gender = gv, disease = d$disease, point = as.numeric(tb[[col]]))
      })
    })
  }) |>
    # A disease can appear under more than one output_name/family. The notebook keeps
    # the FIRST row per 4-key and discards the rest; replicate that exactly, or the join
    # multiplies rows.
    dplyr::distinct(year, age_group, gender, disease, .keep_all = TRUE) |>
    dplyr::select(year, age_group, gender, disease, aaf = point)

  # `aaf` is carried through on purpose: the gate test reports how many cells were
  # recovered through a NEGATIVE AAF, so the load-bearing guard stays visible instead of
  # being a comment nobody reads.
  dplyr::inner_join(mort, aaf, by = c("year", "age_group", "gender", "disease")) |>
    dplyr::filter(abs(aaf) > 1e-12) |>                      # <- NOT aaf > 0. See above.
    dplyr::transmute(year, gender, age_group, disease, aaf, n = mort / aaf)
}
