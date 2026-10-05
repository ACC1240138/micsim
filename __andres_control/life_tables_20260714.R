# =============================================================================
# life_tables_20260714.R
# -----------------------------------------------------------------------------
# Life-expectancy inputs for the YPLL / YLL rebuild.  RETRIEVED 2026-07-14.
#
# NOTHING IN THIS FILE IS FROM MEMORY. Every number below was read out of a file
# downloaded from the cited source, and then CROSS-VERIFIED against a second,
# INDEPENDENT authority. Where the two authorities disagree, the disagreement is
# reported here rather than averaged away.
#
# THIS FILE IS DATA, NOT LOGIC. It defines no YPLL. It is meant to be READ and
# CHECKED by a human before any figure is computed from it.
#
# -----------------------------------------------------------------------------
# THE ONE THING TO UNDERSTAND BEFORE USING THIS FILE
# -----------------------------------------------------------------------------
# The two tables below are NOT two versions of the same quantity. They are two
# DIFFERENT METRICS, and they answer different questions:
#
#   (1) chile_e0  -> a REFERENCE-AGE YPLL.  ypll_i = max(e0(year, sex) - age_i, 0)
#       "How many years short of the national average lifespan did this person die?"
#       e0 is life expectancy AT BIRTH. It is NOT remaining life expectancy at the
#       age of death. This is the crude, classic YPLL, and it is the convention the
#       Ruiz-Tagle / injuries work used (see Mortalidad/Scripts/PIF-BINGE.R:980,
#       which hard-codes a flat 76/82). Use it for CONTINUITY with that literature.
#
#   (2) gbd2019_tmrlt -> a STANDARD YLL.    yll_i = e_gbd(age_i)
#       "How many years of life were lost against a normative maximum-lifespan
#       standard?" e(x) IS remaining life expectancy at the age of death. This is
#       what GBD, WHO and the Lancet Public Health literature (Kilian et al. 2025,
#       the paper this project emulates) mean by YLL. Use it for COMPARABILITY.
#
# They will not agree, and they are not supposed to. Report both, in separate
# columns, and never add them together.
#
# WHY NOT A PROPER CHILEAN e(x)?  Because it does not exist for this vintage. INE
# has published NO base-2024 life table (the abridged-life-table URL 404s). The only
# INE life-table workbook is base-2017, whose values from 2018 onward are PRE-COVID
# PROJECTIONS. Pulling e(x) from base-2017 while quoting e(0) from base-2024 would
# silently mix vintages and would OVERSTATE remaining life expectancy in exactly the
# COVID years. If a national-life-table YLL is wanted, wait for the INE base-2024
# life tables; do not improvise one.
# =============================================================================


# =============================================================================
# TABLE 1 - CHILE, LIFE EXPECTANCY AT BIRTH e(0), BY YEAR AND SEX
# =============================================================================
# SOURCE (primary, and the one these numbers come from):
#   INE Chile - "Estimaciones y Proyecciones de Poblacion de Chile 1992-2070,
#   base 2024" (EEPP base CPV 2024; released 2026-01-28). This is the CURRENT INE
#   vintage; it supersedes the base-2017 edition.
#   File : estimaciones-y-proyecciones-de-poblacion-1992-2070_base-2024_tabulados.xlsx
#          (403,467 bytes; md5 31709ec5b052b741db05903fa087bdfc)
#   Sheet: "Resultados Indicadores"
#   Rows : "Esperanza de vida al Nacer, hombres" / "..., mujeres"
#   URL  : https://www.ine.gob.cl/docs/default-source/proyecciones-de-poblacion/
#          cuadros-estadisticos/proyecci%C3%B3n-base-2024/
#          estimaciones-y-proyecciones-de-poblaci%C3%B3n-1992-2070_base-2024_tabulados.xlsx
#   Retrieved: 2026-07-14, downloaded from ine.gob.cl itself (not from a mirror).
#
# DEFINITION: PERIOD life expectancy at birth (not cohort). Published to ONE decimal;
# there is no higher-precision e(0) in this vintage.
#
# STATUS - BETTER THAN EXPECTED: in the base-2024 vintage, 2012-2024 are ALL
# ESTIMATES, not projections. INE: "A partir del proceso de conciliacion demografica
# se estimo el periodo 1992 al 2024. Este ultimo ano se establece como poblacion base
# para las proyecciones." Only 2025-2070 are projected. CAVEAT: 2024 is the base year
# and leans on still-provisional 2024 vital statistics, so it is the value most likely
# to be revised.
#
# COVID IS IN THE SERIES: e(0) both sexes 80.9 (2019) -> 79.9 (2020) -> 79.2 (2021),
# the 1.7-year drop INE documents explicitly. It is not smoothed away.
#
# ROW/COLUMN ALIGNMENT WAS PROVEN, not assumed. Four figures INE publishes in prose
# reproduce exactly from the cells read: 1992 both = 74.6; 2026 = 81.8/79.5/84.3;
# 2070 = 88.4/86.7/90.2; and the 2019->2021 drop of exactly 1.7 years.
# -----------------------------------------------------------------------------
chile_e0_ine_base2024 <- data.frame(
  year      = 2012:2024,
  male_e0   = c(76.7, 76.8, 77.0, 77.3, 77.7, 78.0, 78.3, 78.4, 77.1, 76.4, 77.1, 78.8, 78.9),
  female_e0 = c(82.0, 82.4, 82.5, 82.7, 83.0, 83.1, 83.5, 83.6, 82.8, 82.1, 82.5, 83.8, 83.7)
)
attr(chile_e0_ine_base2024, "source")    <- "INE Chile, EEPP base CPV 2024 (released 2026-01-28)"
attr(chile_e0_ine_base2024, "retrieved") <- "2026-07-14"
attr(chile_e0_ine_base2024, "metric")    <- "period life expectancy at BIRTH, e(0), by sex"


# -----------------------------------------------------------------------------
# *** THE CROSS-CHECK FAILED, AND YOU MUST READ THIS BEFORE PUBLISHING ***
# -----------------------------------------------------------------------------
# The TRANSCRIPTION above is clean: an independent agent re-downloaded the same INE
# workbook (byte-identical md5) and re-parsed it, and all 26 values reproduce exactly.
# Nothing was mis-indexed and nothing was invented.
#
# But the SOURCE CHOICE does not survive an independent authority. Against UN WPP 2024,
# EVERY one of the 26 values differs, and 19 of 26 exceed a 0.3-year threshold:
#
#   FEMALE: INE is systematically HIGHER than WPP in ALL 13 years, by +0.32 to +1.05
#           years (worst: 2019, INE 83.6 vs WPP 82.55). 12 of 13 breach 0.3 y.
#   MALE:   the sign FLIPS mid-series. INE is 0.2-0.5 y BELOW WPP in 2012-2017, then
#           0.05-0.34 y ABOVE it in 2019-2022, then 0.44-0.55 y BELOW again in 2023-24.
#           So the two authorities disagree not only on the LEVEL but on the SHAPE of
#           the male trend and on the depth of the COVID trough.
#   WHO GHO is a THIRD distinct answer, and it stops at 2021.
#
# CONSEQUENCE FOR THE PAPER. A systematic ~0.5-1.0 y difference in female e(0), plus a
# sign-flipping male difference, is large enough to move an alcohol-attributable YPLL
# total AND to change the DIRECTION of a 2012-2024 trend. You therefore cannot present
# the YPLL as if the life-expectancy input were a settled fact. You must:
#   (a) NAME the authority in the methods (INE base-2024);
#   (b) JUSTIFY it -- and it IS defensible: INE is the national statistical office, it
#       uses Censo 2024 and Chilean vital registration, and it is the ONLY source that
#       covers 2022-2024 as ESTIMATES rather than projections (WHO stops at 2021; WPP's
#       2024 value is a projection);
#   (c) RUN A SENSITIVITY ANALYSIS against WPP 2024. The alternate series is provided
#       below precisely so that this is a one-line change, not a research project.
#   (d) NEVER SPLICE authorities. Do not take INE 2012-2022 and WPP 2023-2024: WPP shows
#       a much steeper post-COVID male rebound (+2.41 y) than INE (+1.7 y), so splicing
#       would inject an artificial jump into the series.
# -----------------------------------------------------------------------------

# ALTERNATE SERIES, FOR THE SENSITIVITY ANALYSIS ONLY. Do NOT blend with the above.
# Source: UN WPP 2024 revision (via the World Bank API, indicators SP.DYN.LE00.MA.IN /
# SP.DYN.LE00.FE.IN; API "lastupdated" 2026-07-13). NOTE: WPP estimates END at 2023;
# the 2024 values here are PROJECTIONS, unlike INE's, which are estimates.
chile_e0_wpp2024 <- data.frame(
  year      = 2012:2024,
  male_e0   = c(76.901, 77.302, 77.414, 77.689, 78.008, 78.401, 78.323, 78.098,
                76.760, 76.348, 76.828, 79.240, 79.454),
  female_e0 = c(81.508, 81.763, 81.983, 82.297, 82.549, 82.783, 82.776, 82.549,
                82.031, 81.486, 81.566, 83.084, 83.228)
)
attr(chile_e0_wpp2024, "source")    <- "UN WPP 2024 revision, via World Bank API (lastupdated 2026-07-13)"
attr(chile_e0_wpp2024, "retrieved") <- "2026-07-14"
attr(chile_e0_wpp2024, "warning")   <- "SENSITIVITY ONLY. 2024 is a PROJECTION here. Never splice with INE."


# =============================================================================
# TABLE 1b - [2026-07-14, ADDED AFTER TRIANGULATION] CHILE HMD PERIOD LIFE TABLE
#            e(x) BY YEAR, SEX AND SINGLE YEAR OF AGE
# =============================================================================
# THIS IS THE TABLE THAT WAS "MISSING". It was not missing -- it was in the repo,
# under a directory named after something else.
#
# SOURCE: Human Mortality Database (mortality.org) -- "Chile, Life tables (period
#   1x1)", Methods Protocol v6 (2017), last modified 2026-01-12. HMD reconstructs a
#   period life table from raw vital registration + census data under a single
#   international protocol, so it is directly comparable across countries and does
#   not depend on any national agency's reconciliation choices.
#   Files (already in this repo, supplied by the user 2026-07-14):
#     __andres_control/ine_proyecciones_rebuild/mltper_1x1.txt   (males)
#     __andres_control/ine_proyecciones_rebuild/fltper_1x1.txt   (females)
#   (The 5x1 files in the same directory are the abridged version. We use 1x1: the
#   death microdata carries SINGLE YEARS of age, so abridging would throw that away.)
#
# WHY THIS SUPERSEDES THE e(0) APPROACH FOR A NATIONAL YLL.
#   e(x) is REMAINING life expectancy at exact age x. The legacy convention
#   (ypll = max(e0 - age, 0)) is NOT that: it subtracts age from life expectancy AT
#   BIRTH, which systematically UNDERSTATES years lost at older ages, because someone
#   who has already SURVIVED to age x has a longer remaining expectancy than e(0) - x.
#   Measured on this table -- a man dying at 60 in 2022:
#       legacy (INE e0 = 77.1):  77.1 - 60 = 17.10 years lost
#       true life table e(60) :             21.30 years lost   (+24.6%)
#   The bias grows with age, and age band 4 (60-65) is exactly where the deaths are.
#   This is a SYSTEMATIC bias, not noise: the legacy YPLL is not merely "crude".
#
# TRIANGULATION AGAINST THE OTHER TWO AUTHORITIES (e(0), 2012-2024):
#   MALES  : HMD is BELOW BOTH in every one of the 13 years. vs INE: -0.41 (2012)
#            widening to -1.05 (2024). vs WPP: -0.35 to -1.60.
#   FEMALES: HMD sits BETWEEN them -- below INE (-0.17 to -0.55), above WPP
#            (+0.11 to +0.76, except 2024).
#   COVID  : HMD shows the DEEPEST male loss, e(0) 77.75 (2019) -> 75.63 (2021) =
#            -2.12 years, vs INE -2.00 and WPP -1.75.
#   => The three authorities disagree by up to ~1 year on the LEVEL and on the DEPTH
#      of the COVID trough. Name the authority in the methods and run the sensitivity;
#      do not present the life-expectancy input as a settled fact.
# -----------------------------------------------------------------------------
if (!exists("acc_root")) source(here::here("_tools", "acc_data.R"))
chile_hmd_dir <- file.path(acc_root(), "__andres_control", "ine_proyecciones_rebuild")

# Parse an HMD 1x1 period life table. HMD files are fixed-width-ish text with a
# 2-line header; data rows start with a 4-digit year. The last column is ex.
# The terminal age row is "110+", so `age` is kept as CHARACTER and converted with an
# explicit guard -- silently coercing "110+" to NA would drop the open interval
# without anyone noticing.
.read_hmd_1x1 <- function(path, sex) {
  x <- readLines(path, warn = FALSE)
  x <- x[grepl("^[[:space:]]+[0-9]{4}[[:space:]]", x)]
  if (!length(x)) stop("read_hmd: no data rows found in ", path)
  p <- strsplit(trimws(gsub("[[:space:]]+", " ", x)), " ")
  data.frame(
    year = as.integer(vapply(p, `[`, character(1), 1L)),
    age  = vapply(p, `[`, character(1), 2L),           # "0".."109", "110+"
    ex   = as.numeric(vapply(p, function(z) z[length(z)], character(1))),
    sex  = sex,
    stringsAsFactors = FALSE
  )
}

chile_hmd_lifetable <- rbind(
  .read_hmd_1x1(file.path(chile_hmd_dir, "mltper_1x1.txt"), "male"),
  .read_hmd_1x1(file.path(chile_hmd_dir, "fltper_1x1.txt"), "female")
)
attr(chile_hmd_lifetable, "source")    <- "Human Mortality Database (mortality.org), Chile period life table 1x1, Methods Protocol v6, last modified 2026-01-12"
attr(chile_hmd_lifetable, "retrieved") <- "2026-07-14"
attr(chile_hmd_lifetable, "metric")    <- "e(x) = remaining life expectancy at exact age x, by year and sex"

# e(x) for one (year, sex, single-year age). Errors rather than extrapolating: a
# silent NA here would become a silently-dropped death downstream.
chile_hmd_ex <- function(year, sex, age) {
  key <- paste(year, sex, age)
  lut <- chile_hmd_lifetable
  idx <- match(key, paste(lut$year, lut$sex, lut$age))
  if (anyNA(idx)) {
    bad <- unique(key[is.na(idx)])
    stop("chile_hmd_ex: no HMD life-table entry for: ",
         paste(utils::head(bad, 5), collapse = " | "),
         if (length(bad) > 5) paste0(" (and ", length(bad) - 5, " more)") else "",
         ". Refusing to guess.")
  }
  lut$ex[idx]
}


# =============================================================================
# TABLE 2 - GBD 2019 REFERENCE LIFE TABLE (TMRLT), e(x) BY AGE
# =============================================================================
# SOURCE:
#   Global Burden of Disease Collaborative Network. Global Burden of Disease Study
#   2019 (GBD 2019) Reference Life Table. Seattle: Institute for Health Metrics and
#   Evaluation (IHME), 2021.  DOI: 10.6069/1D4Y-YQ37
#   File: IHME_GBD_2019_TMRLT_Y2021M01D05.CSV (351 bytes)
#   GHDx: https://ghdx.healthdata.org/record/ihme-data/
#         global-burden-disease-study-2019-gbd-2019-reference-life-table
#   Retrieved: 2026-07-14.
#
# DEFINITION: e(x) = REMAINING life expectancy at exact age x. A single normative
# table: NOT sex-specific, NOT country-specific, NOT year-specific. Built from the
# lowest observed age-specific mortality rates across all locations with population
# > 5 million in 2016. YLL for a death at age x = e(x). Fingerprint: e(0) = 88.8718951.
#
# *** VERIFICATION: PASSED, DIGIT FOR DIGIT. ***
# GHDx is login-gated (HTTP 403 to an unauthenticated fetch), so the primary retrieval
# used two independent public copies. An independent verifier then retrieved IHME'S OWN
# FILE from an ihme/healthdata.org server path via the Internet Archive's byte-preserving
# endpoint, and diffed it: ALL 21 ROWS IDENTICAL, zero numeric mismatches, matching MD5
# on LF-normalised text. Two Wayback snapshots 19 months apart are byte-identical to each
# other, so the file was never silently revised. The 351-byte size matches what GHDx
# publishes for the official release.
#
# *** DO NOT LABEL THIS "GBD 2017" OR "GBD 2021". ***
# GBD 2017 is a genuinely DIFFERENT table: ages 0-110+ (not 0-95+), and every value is
# about ONE YEAR LOWER (e(0) 87.886 vs 88.872; e(15) 73.069 vs 74.067; e(65) 24.735 vs
# 25.681). Citing this table as GBD 2017 would misstate every YLL by roughly one life-year
# per death (~1.3% at age 15, ~3.8% at age 65). For GBD 2021 no separate reference-life-table
# record is published at all. Cite strictly as GBD 2019, DOI 10.6069/1D4Y-YQ37.
#
# *** DO NOT SUBSTITUTE THE WHO GHE TABLE. ***
# The WHO GHE/DALY methods documents do NOT reproduce this table -- WHO deliberately uses a
# DIFFERENT standard (a projected-frontier table, e(0) ~ 90 in GHE2019 and ~92.7 in GHE2021).
# Anyone reaching for "the WHO YLL methods doc" as a cross-check will silently get the wrong
# table and inflate every YLL figure. The two must never be mixed in one paper.
#
# PRECISION: full IHME precision is retained below. Do NOT round before multiplying by death
# counts; round only at presentation.
# -----------------------------------------------------------------------------
gbd2019_tmrlt <- data.frame(
  age = c(0, 1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95),
  ex  = c(88.8718951, 88.00051053, 84.03008056, 79.04633476, 74.0665492,
          69.10756792, 64.14930031, 59.1962771,  54.25261364, 49.31739311,
          44.43332057, 39.63473787, 34.91488095, 30.25343822, 25.68089534,
          21.28820012, 17.10351469, 13.23872477,  9.990181244, 7.617724915,
           5.922359078)
)
attr(gbd2019_tmrlt, "source")    <- "IHME GBD 2019 Reference Life Table (TMRLT), DOI 10.6069/1D4Y-YQ37"
attr(gbd2019_tmrlt, "retrieved") <- "2026-07-14"
attr(gbd2019_tmrlt, "metric")    <- "e(x) = remaining life expectancy at exact age x"


# -----------------------------------------------------------------------------
# INTERPOLATION TO SINGLE YEARS OF AGE
# -----------------------------------------------------------------------------
# The GBD table is published at 5-year steps, but OUR DEATHS CARRY INDIVIDUAL AGE
# (the DEIS microdata is single-year). That is a real advantage: we are NOT forced to
# assign e(60) to every death in a 60-64 band, which would systematically OVERSTATE
# YLL (the mean death in that band falls near age 62). We interpolate instead.
#
# Linear interpolation between the published ages. Over 15-65 the table is close to
# linear (each 5-year step drops ~4.9 years), so linear vs spline is a sub-0.1%
# difference -- but the CHOICE is documented here rather than left implicit, because it
# is exactly the kind of silent multi-percent decision no unit test would catch.
#
# Returns e(x) for any age in [15, 65]; errors outside the frame rather than
# extrapolating.
gbd2019_ex <- function(age) {
  if (any(!is.finite(age))) stop("gbd2019_ex: non-finite age.")
  if (any(age < 0 | age > 95)) {
    stop("gbd2019_ex: age outside the published range [0, 95]. Refusing to extrapolate.")
  }
  stats::approx(x = gbd2019_tmrlt$age, y = gbd2019_tmrlt$ex, xout = age, method = "linear")$y
}


# =============================================================================
# SELF-CHECKS. These run on source() and fail loudly. They are here so that a
# corrupted copy-paste of this file cannot silently poison a published figure.
# =============================================================================
local({
  # --- Chile e0 ---
  stopifnot(nrow(chile_e0_ine_base2024) == 13L,
            identical(chile_e0_ine_base2024$year, 2012:2024))
  # Plausibility: Chilean e(0) has been in the 70s/80s for decades. Anything outside
  # this window is a transcription error, not a demographic event.
  stopifnot(all(chile_e0_ine_base2024$male_e0   > 70 & chile_e0_ine_base2024$male_e0   < 85),
            all(chile_e0_ine_base2024$female_e0 > 75 & chile_e0_ine_base2024$female_e0 < 90))
  # Women outlive men in Chile in every year on record. If this ever flips, the columns
  # were swapped.
  stopifnot(all(chile_e0_ine_base2024$female_e0 > chile_e0_ine_base2024$male_e0))
  # The COVID signature INE documents: e(0) must FALL in 2020 and again in 2021.
  m <- chile_e0_ine_base2024$male_e0
  stopifnot(m[9] < m[8], m[10] < m[9])   # 2020 < 2019, 2021 < 2020

  # --- Chile HMD period life table ---
  stopifnot(nrow(chile_hmd_lifetable) == 2L * 33L * 111L)   # 2 sexes x 1992-2024 x ages 0-110+
  stopifnot(!anyNA(chile_hmd_lifetable$ex))
  # The frame this pipeline actually uses: ages 15-65, years 2012-2024, both sexes.
  # Complete coverage, no gaps -- if this ever fails, a death would silently lose its e(x).
  fr <- chile_hmd_lifetable[chile_hmd_lifetable$year %in% 2012:2024 &
                            chile_hmd_lifetable$age %in% as.character(15:65), ]
  stopifnot(nrow(fr) == 51L * 13L * 2L, !anyNA(fr$ex))
  # e(x) must fall with age within any (year, sex).
  s22 <- chile_hmd_lifetable[chile_hmd_lifetable$year == 2022 &
                             chile_hmd_lifetable$sex == "male" &
                             chile_hmd_lifetable$age %in% as.character(15:65), ]
  s22 <- s22[order(as.integer(s22$age)), ]
  stopifnot(all(diff(s22$ex) < 0))
  # Women outlive men at every age.
  stopifnot(chile_hmd_ex(2022, "female", "60") > chile_hmd_ex(2022, "male", "60"))
  # THE BIAS OF THE LEGACY CONVENTION, pinned as a test so nobody forgets it: the true
  # remaining life expectancy at 60 EXCEEDS (e0 - 60) by several years. If this ever
  # stops holding, either the life table or the e0 series has been swapped.
  e0_m22 <- chile_e0_ine_base2024$male_e0[chile_e0_ine_base2024$year == 2022]
  stopifnot(chile_hmd_ex(2022, "male", "60") > (e0_m22 - 60) + 3)
  # Unknown cells must ERROR, never return NA.
  stopifnot(inherits(try(chile_hmd_ex(2050, "male", "60"), silent = TRUE), "try-error"))

  # --- GBD 2019 ---
  stopifnot(nrow(gbd2019_tmrlt) == 21L)
  # The fingerprint. If this is not 88.87, it is a different GBD round (2017 is ~87.89)
  # and every YLL would be off by about a year per death.
  stopifnot(abs(gbd2019_tmrlt$ex[1] - 88.8718951) < 1e-7)
  # e(x) must fall monotonically with age.
  stopifnot(all(diff(gbd2019_tmrlt$ex) < 0))
  # Spot-check the interpolator against published anchors (exact at the knots).
  stopifnot(abs(gbd2019_ex(15) - 74.0665492)  < 1e-9,
            abs(gbd2019_ex(65) - 25.68089534) < 1e-9)
  # And between knots it must sit strictly between them.
  stopifnot(gbd2019_ex(62) < gbd2019_ex(60), gbd2019_ex(62) > gbd2019_ex(65))

  message("[life-tables] OK: Chile e0 (INE base-2024, 2012-2024) and GBD 2019 TMRLT loaded and self-checked.")
})
