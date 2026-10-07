# =============================================================================
# build_ypll.R   [updated 2026-07-22]
# -----------------------------------------------------------------------------
# Rebuilds the YPLL/YLL cache for the 23 modelled causes, 2012-2024, ages 15-65,
# from the DEIS death microdata -- with THREE metrics side by side, because they are
# three DIFFERENT quantities and must never be added together or silently swapped.
#
#   yll_hmd   Chile HMD period life table.   yll = e(x | year, sex, exact age)
#             The NATIONAL YLL. Remaining life expectancy at the age of death, from
#             Chile's own life table, by year and sex. This is the recommended primary.
#
#   yll_gbd   GBD 2019 reference life table. yll = e_gbd(age)
#             The INTERNATIONALLY COMPARABLE YLL, and what the literature this project
#             emulates uses (Kilian et al., Lancet Public Health 2025).
#
#   ypll_ref  Legacy reference-age YPLL.     ypll = max(e0(year, sex) - age, 0)
#             The Ruiz-Tagle / injuries convention. Kept ONLY for continuity with that
#             published work. IT IS BIASED OUTSIDE ITS DOMAIN -- see the warning below.
#
# *** WHY ypll_ref MUST NOT BE USED AS THE HEADLINE FOR THIS GRID ***
# It is not merely "crude". It is SYSTEMATICALLY BIASED DOWNWARD, by selection: someone
# who has already SURVIVED to age x has a longer remaining expectancy than e(0) - x.
# Measured on the real tables (Chilean man, death in 2022):
#     age 20 -> ypll_ref 57.10 vs true e(x) 57.17   (+0%   : harmless)
#     age 50 -> ypll_ref 27.10 vs true e(x) 29.61   (+9%)
#     age 60 -> ypll_ref 17.10 vs true e(x) 21.30   (+25%)
#     age 65 -> ypll_ref 12.10 vs true e(x) 17.44   (+44%)
# The Ruiz-Tagle paper is about INJURIES, whose deaths cluster in the young, where the
# bias is ~0% -- so the convention worked there. THIS grid is 23 causes including
# cancers, cirrhosis and IHD, whose deaths cluster at 45-65, which is exactly where the
# metric's blind spot lands. The convention is defensible for injuries and indefensible
# for chronic causes.
#
# (A second, even larger defect of the legacy ARTIFACT -- not of this rebuild -- is that
# its band 4 was 60+ OPEN. Under pmax(e0 - age, 0) every death above e0 (~77 male /
# ~82 female) scores EXACTLY ZERO years lost: 51% of its >65 injury deaths contributed
# nothing, and it lost 66% of the real years in that band. Our frame is 15-65 CLOSED, so
# no death can exceed e0 and that floor never bites. See the caveman handoff, 2026-07-14.)
#
# PRECONDITION: test_ypll_death_base.R MUST PASS FIRST. It is re-asserted below, because
# a YPLL built on a death base that does not match the PIF's population is worthless and
# nothing downstream would notice.
#
# Run:  Rscript __andres_control/build_ypll.R
# =============================================================================
.t0 <- Sys.time()

if (!exists("acc_root")) source(here::here("_tools", "acc_data.R"))
# 2026-10-06 cc-cloud: B16. No setwd(); every path is anchored to acc_root().
source(file.path(acc_root(), "__andres_control", "ypll_icd_defs.R"))
source(file.path(acc_root(), "__andres_control", "life_tables_20260714.R"))

# Dated output, like every other artifact in this pipeline: the notebook's picker
# prefers the newest embedded YYYYMMDD, so a rebuild produces YPLL_<today>.rds and wins
# over both the previous build and the legacy YPLL.rds without overwriting either.
OUT <- file.path(YPLL_ROOT, "Mortalidad", "Matrices",
                 sprintf("YPLL_%s.rds", format(Sys.Date(), "%Y%m%d")))

cat("=============================================================\n")
cat(" YPLL / YLL REBUILD -- 23 causes, 2012-2024, ages 15-65\n")
cat("=============================================================\n\n")

# ---- (1) the per-death frame -------------------------------------------------
def <- ypll_build_deaths()
cat(sprintf("[deaths] per-death rows: %d | years %d-%d | ages %d-%d\n",
            nrow(def), min(def$year), max(def$year), min(def$age), max(def$age)))

# ---- (2) THE GATE, re-asserted -----------------------------------------------
# Do not build on an unreconciled death base. This duplicates test_ypll_death_base.R on
# purpose: the test can be skipped, this cannot.
long <- ypll_deaths_long(def)
pipe <- ypll_pipeline_deaths()
pipe$n <- round(pipe$n)
chk <- merge(long, pipe[, c("year", "gender", "age_group", "disease", "n")],
             by = c("year", "gender", "age_group", "disease"))
if (nrow(chk) != 1188L || any(chk$deaths != chk$n) || sum(chk$deaths) != 117918L) {   # 2026-10-06 cc-cloud: B20, was 117944 (DEIS infant fix)
  stop("GATE FAILED inside build_ypll.R: the rebuilt death base does not reproduce the ",
       "PIF pipeline's counts (", nrow(chk), " joined cells, ",
       sum(chk$deaths != chk$n), " mismatches, ", sum(chk$deaths), " deaths). ",
       "Run test_ypll_death_base.R and fix the divergence. DO NOT SHIP A YPLL.")
}
cat(sprintf("[gate  ] PASSED: %d/%d cells reconcile exactly, %d deaths.\n",
            nrow(chk), nrow(chk), sum(chk$deaths)))

# ---- (3) the three metrics, PER DEATH ----------------------------------------
# Per death, not per band: the microdata carries SINGLE YEARS of age, so we never have
# to assign a band midpoint. That matters -- giving every death in the 60-64 band e(60)
# would inflate YLL by several percent, and no unit test would catch it.
sex_en <- ifelse(def$gender == "Hombre", "male", "female")

# e0 for the legacy convention, by (year, sex).
e0_lut <- chile_e0_ine_base2024
e0 <- ifelse(sex_en == "male",
             e0_lut$male_e0[match(def$year, e0_lut$year)],
             e0_lut$female_e0[match(def$year, e0_lut$year)])
if (anyNA(e0)) stop("build_ypll: no INE e0 for some (year, sex). Refusing to guess.")

def$ypll_ref <- pmax(e0 - def$age, 0)                                  # legacy / JRT
def$yll_hmd  <- chile_hmd_ex(def$year, sex_en, as.character(def$age))  # national  (errors on a gap)
def$yll_gbd  <- gbd2019_ex(def$age)                                    # comparable (errors on a gap)

# The floor must be inert in this frame. If it ever bites, someone widened the age band
# and silently reintroduced the legacy artifact's worst defect.
n_floored <- sum(def$ypll_ref == 0)
cat(sprintf("[metrics] deaths hitting the pmax(...,0) floor: %d  (must be 0 in a 15-65 frame)\n",
            n_floored))
if (n_floored > 0) {
  stop("build_ypll: ", n_floored, " deaths scored ZERO years lost under the legacy ",
       "convention. In a 15-65 frame no death can exceed e0, so the age filter has been ",
       "widened. That is exactly the defect that destroyed the legacy artifact. Stop.")
}
stopifnot(all(def$yll_hmd > 0), all(def$yll_gbd > 0))

# ---- (4) aggregate to the consumer's schema ----------------------------------
ypll <- purrr::imap_dfr(ypll_disease_filters, function(spec, disease) {
  def |>
    dplyr::filter(.data[[spec$col]] == 1, gender %in% spec$genders) |>
    dplyr::group_by(year, gender, age_group) |>
    dplyr::summarise(deaths   = dplyr::n(),
                     yll_hmd  = sum(yll_hmd),
                     yll_gbd  = sum(yll_gbd),
                     ypll_ref = sum(ypll_ref),
                     .groups  = "drop") |>
    dplyr::mutate(disease = disease)
}) |>
  # `ypll` is the column the existing bridge (pif2_build_attributable_ypll /
  # pif2_apply_pif_to_ypll) joins on. We alias it to the NATIONAL YLL, so the bridge keeps
  # working unchanged, and we say so loudly rather than letting it be a silent default.
  dplyr::mutate(ypll = yll_hmd) |>
  dplyr::select(year, gender, age_group, disease, deaths, ypll, yll_hmd, yll_gbd, ypll_ref) |>
  dplyr::arrange(disease, year, gender, age_group)

# ---- (5) sanity checks that would catch a silent corruption -------------------
stopifnot(nrow(ypll) == nrow(long))                          # same ragged shape as the gate
stopifnot(all(ypll$deaths > 0), !anyNA(ypll))
stopifnot(identical(ypll$ypll, ypll$yll_hmd))
# Mean years lost per death must FALL monotonically across the age bands. If it does not,
# the bands or the life-table lookup are wrong.
mb <- ypll |> dplyr::group_by(age_group) |>
  dplyr::summarise(hmd = sum(yll_hmd)/sum(deaths), gbd = sum(yll_gbd)/sum(deaths),
                   ref = sum(ypll_ref)/sum(deaths), .groups = "drop")
cat("\n[check ] mean years lost PER DEATH, by age band (must fall monotonically):\n")
print(as.data.frame(mb), row.names = FALSE)
stopifnot(all(diff(mb$hmd) < 0), all(diff(mb$gbd) < 0), all(diff(mb$ref) < 0))
# And the legacy must sit BELOW the national YLL in every band, by construction.
stopifnot(all(mb$ref < mb$hmd))

cat(sprintf("\n[out   ] cells: %d | diseases: %d | years: %d-%d | total deaths: %d\n",
            nrow(ypll), dplyr::n_distinct(ypll$disease),
            min(ypll$year), max(ypll$year), sum(ypll$deaths)))
cat(sprintf("[out   ] TOTAL years lost:  yll_hmd = %.0f | yll_gbd = %.0f | ypll_ref = %.0f\n",
            sum(ypll$yll_hmd), sum(ypll$yll_gbd), sum(ypll$ypll_ref)))
cat(sprintf("[out   ] the legacy convention understates the national YLL by %.1f%% overall\n",
            100 * (1 - sum(ypll$ypll_ref) / sum(ypll$yll_hmd))))

attr(ypll, "built")    <- format(Sys.Date(), "%Y-%m-%d")
attr(ypll, "metrics")  <- "ypll = yll_hmd (national). yll_gbd = GBD 2019 TMRLT. ypll_ref = legacy e0-age (BIASED for chronic causes; injuries only)."
attr(ypll, "deaths")   <- "DEIS microdata, 15-65, 2012-2024; ICD map = Shield 2025 Table S6 (ypll_icd_defs.R). Reconciles 1188/1188 with the PIF pipeline's own counts."
attr(ypll, "lifetabs") <- "HMD Chile 1x1 (mortality.org, v6, 2026-01-12); INE base-2024 e0; IHME GBD 2019 TMRLT (DOI 10.6069/1D4Y-YQ37)."

dir.create(dirname(OUT), recursive = TRUE, showWarnings = FALSE)
saveRDS(ypll, OUT)
cat(sprintf("\n[saved ] %s\n", OUT))

# ---- (6) THE ARTIFACT-PICKER HAZARD ------------------------------------------
# The consumer reads the cache with pif2_read_latest_artifact(pattern = "^YPLL.*\\.rds$")
# over Mortalidad/Matrices/. The LEGACY YPLL.rds is still there (kept on purpose, by the
# user's decision -- do not delete it). It is a DIFFERENT DEATH SET (pre-Shield ICD map,
# 3 injury causes, band 4 open at 60+, generating script absent from the repo).
# If the picker ever resolves to it instead of this file, avoidable-YLL silently collapses
# back to 3 causes. Report the candidates so the ambiguity is visible, not assumed.
cands <- list.files(dirname(OUT), pattern = "^YPLL.*\\.rds$", full.names = TRUE)
cat("\n----------------------- ARTIFACT PICKER -----------------------\n")
cat("Candidates matching the consumer's pattern '^YPLL.*\\.rds$':\n")
for (f in cands) {
  dt <- regmatches(basename(f), regexpr("[0-9]{8}", basename(f)))
  cat(sprintf("  %-24s  embedded date: %-8s  mtime: %s%s\n",
              basename(f), if (length(dt)) dt else "(none)",
              format(file.mtime(f), "%Y-%m-%d %H:%M"),
              if (basename(f) == basename(OUT)) "   <- THIS BUILD" else "   <- LEGACY, DO NOT USE"))
}
cat("If the picker prefers the latest EMBEDDED date, it takes this build (the legacy has\n",
    "none). If it falls back to mtime, it also takes this build (it is the newest).\n",
    "CONFIRM this before trusting the numbers: if avoidable_ypll_long comes back with 3\n",
    "diseases instead of 23, the picker regressed to the legacy file.\n", sep = "")
cat("--------------------------------------------------------------\n")

cat(sprintf("\nbuild_ypll elapsed minutes: %.2f\n",
            as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
