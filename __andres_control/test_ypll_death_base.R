# =============================================================================
# test_ypll_death_base.R   [updated 2026-07-22]
# -----------------------------------------------------------------------------
# THE GATE. Nothing about the YPLL/YLL rebuild is valid unless this passes.
#
# WHY IT EXISTS. A YPLL is only meaningful if it is multiplied by a PIF computed on the
# SAME population. We rebuild the death base from the DEIS microdata using our own copy
# of the ICD-10 map (ypll_icd_defs.R). The PIF pipeline derives its death counts a
# completely different way -- as n = mort / AAF, out of the mortality export and the AAF
# bundle. If those two disagree by even one death, the YPLL describes a different
# population than the PIF it gets multiplied by, and every avoidable-YLL figure in the
# paper is quietly wrong. No downstream test would catch it.
#
# It is also the ONLY guard against the ICD-map duplication: ypll_icd_defs.R copies the
# map out of expand_pif.ipynb (a notebook cannot be source()d). If the notebook's map
# ever changes, this test goes red. That is the entire point.
#
# WHAT MUST HOLD -- all of these are hard stop()s, not warnings:
#     joined cells                  == 1188
#     mismatched cells              == 0
#     orphan cells, either side     == 0
#     max |n_rebuilt - n_pipeline|  == 0        (exactly zero, not "small")
#     total deaths                  == 117,918   (2026-10-06 cc-cloud: was 117,944 before the DEIS infant fix)
#     n_pipeline is integral to     <  1e-9     (proves the xlsx and the bundle are
#                                                from the SAME engine run)
#
# RE-RUN IT whenever the AAF bundle date, the mortality xlsx, or expand_pif.ipynb's ICD
# map changes. If it fails, the YPLL is invalid. Do NOT relax the tolerance; do NOT
# paper over a partial match. Find out why the death sets diverged.
#
# Run:  Rscript __andres_control/test_ypll_death_base.R
# =============================================================================
.t0 <- Sys.time()

if (!exists("acc_root")) source(here::here("_tools", "acc_data.R"))
# 2026-10-06 cc-cloud: B16. No setwd(); every path is anchored to acc_root().
source(file.path(acc_root(), "__andres_control", "ypll_icd_defs.R"))

cat("=============================================================\n")
cat(" GATE: does the rebuilt death base reproduce the PIF pipeline's own counts?\n")
cat("=============================================================\n")
cat("  deaths microdata : ", YPLL_DEATH_DIR, "\n")
cat("  mortality export : ", basename(YPLL_MORTALITY_XLSX), " (path HARD-CODED; see ypll_icd_defs.R)\n")
cat("  AAF bundle       : ", basename(YPLL_AAF_BUNDLE), "\n\n")

# ---- (1) our rebuild, from the microdata + our copy of the ICD map ------------
def  <- ypll_build_deaths()
mine <- ypll_deaths_long(def)
cat(sprintf("[rebuild ] per-death rows: %d | long cells: %d | total deaths: %d\n",
            nrow(def), nrow(mine), sum(mine$deaths)))

# ---- (2) the pipeline's own counts, recovered as n = mort / AAF ---------------
pipe <- ypll_pipeline_deaths()

# The integrality assert. n = mort/AAF must be a whole number, because it IS the raw
# ICD-coded death count. If it is not, the mortality export and the AAF bundle came from
# DIFFERENT engine runs, and nothing downstream can be trusted. This assert is the only
# thing binding those two artifacts together.
resid <- max(abs(pipe$n - round(pipe$n)))
cat(sprintf("[pipeline] cells: %d | max non-integer residual: %.3e\n", nrow(pipe), resid))
if (resid > 1e-9) {
  stop("GATE FAILED: n = mort/AAF is not integral (max residual ", format(resid), ").\n",
       "  The mortality export and the AAF bundle are NOT from the same engine run.\n",
       "  Do not build the YPLL until they are re-paired.")
}
pipe$n <- round(pipe$n)

# The abs() guard, made VISIBLE rather than assumed. These cells have a negative AAF and
# a negative `mort`, whose ratio is still the correct POSITIVE death count. A naive
# `aaf > 0` guard would NA every one of them, and they would then vanish silently from
# every na.rm = TRUE sum downstream -- taking all of Ischaemic Stroke with them.
negc <- pipe[pipe$aaf < 0, ]
cat(sprintf("[pipeline] cells recovered through a NEGATIVE AAF (the abs() guard): %d\n",
            nrow(negc)))
if (nrow(negc)) {
  print(as.data.frame(table(negc$disease, negc$gender)) |>
          subset(Freq > 0) |> setNames(c("disease", "gender", "cells")), row.names = FALSE)
}
if (any(negc$n <= 0)) {
  stop("GATE FAILED: a negative-AAF cell recovered a non-positive death count. ",
       "The sign convention broke.")
}
pipe$aaf <- NULL   # not part of the comparison

# ---- (3) reconcile, cell for cell --------------------------------------------
cmp <- merge(mine, pipe, by = c("year", "gender", "age_group", "disease"), all = TRUE)
cmp$deaths[is.na(cmp$deaths)] <- NA_integer_

both     <- cmp[!is.na(cmp$deaths) & !is.na(cmp$n), ]
only_me  <- cmp[!is.na(cmp$deaths) &  is.na(cmp$n), ]
only_pip <- cmp[ is.na(cmp$deaths) & !is.na(cmp$n), ]
bad      <- both[both$deaths != both$n, ]
maxdiff  <- if (nrow(both)) max(abs(both$deaths - both$n)) else NA_real_

cat("\n----------------------- RECONCILIATION -----------------------\n")
cat(sprintf("  cells in BOTH               : %d\n", nrow(both)))
cat(sprintf("    exact matches             : %d\n", nrow(both) - nrow(bad)))
cat(sprintf("    mismatches                : %d\n", nrow(bad)))
cat(sprintf("  cells ONLY in the rebuild   : %d\n", nrow(only_me)))
cat(sprintf("  cells ONLY in the pipeline  : %d\n", nrow(only_pip)))
cat(sprintf("  MAX ABS DISCREPANCY         : %s\n", format(maxdiff)))
cat(sprintf("  total deaths  rebuild=%d  pipeline=%d\n",
            sum(both$deaths), sum(both$n)))
cat("--------------------------------------------------------------\n\n")

if (nrow(bad)) {
  cat("MISMATCHED CELLS (first 20):\n")
  print(utils::head(bad[order(-abs(bad$deaths - bad$n)), ], 20), row.names = FALSE)
}
if (nrow(only_pip)) { cat("\nONLY IN PIPELINE (first 10):\n"); print(utils::head(only_pip, 10), row.names = FALSE) }

# ---- THE ASYMMETRY, AND WHY IT IS CORRECT ------------------------------------
# The two sides do NOT cover the same years, and they are not supposed to:
#   * the DEIS microdata (our rebuild) covers ALL 13 years, 2012-2024;
#   * the PIF/AAF grid only exists for the 7 ENPG survey waves (the EVEN years), because
#     the exposure distribution comes from the survey. There is no 2013 AAF, so there is
#     no 2013 PIF, so there is nothing to multiply a 2013 YPLL by.
# So a rebuild cell in an odd year is EXPECTED and CORRECT: we build the YPLL for all 13
# years (it is a property of the deaths, not of the survey), and the consumer's
# inner_join drops the non-wave years by itself.
#
# What is NOT tolerable, in either direction:
#   * a PIPELINE cell we fail to reproduce  -> our death set is missing deaths the PIF uses;
#   * a REBUILD cell in a WAVE year that the pipeline does not have -> our map invented deaths.
# Both are hard failures. Only "rebuild cell, non-wave year" is allowed, and it is
# reported below rather than swallowed.
waves <- sort(unique(pipe$year))
off_wave <- only_me[!only_me$year %in% waves, ]
on_wave  <- only_me[ only_me$year %in% waves, ]
cat(sprintf("\n  PIF survey waves: %s\n", paste(waves, collapse = ", ")))
cat(sprintf("  rebuild-only cells in NON-WAVE years (expected, kept for the YPLL): %d over years %s\n",
            nrow(off_wave), paste(sort(unique(off_wave$year)), collapse = ", ")))
cat(sprintf("  rebuild-only cells in a WAVE year  (NOT tolerable)               : %d\n", nrow(on_wave)))
if (nrow(on_wave)) { cat("\nREBUILD-ONLY IN A WAVE YEAR (first 10):\n"); print(utils::head(on_wave, 10), row.names = FALSE) }

# ---- (4) THE HARD STOPS ------------------------------------------------------
fail <- character(0)
if (nrow(bad))                     fail <- c(fail, sprintf("%d mismatched cells", nrow(bad)))
if (nrow(on_wave))                 fail <- c(fail, sprintf("%d rebuild-only cells INSIDE a survey wave (our ICD map invented deaths the pipeline does not have)", nrow(on_wave)))
if (nrow(only_pip))                fail <- c(fail, sprintf("%d cells only in the pipeline (our death set is MISSING deaths the PIF uses)", nrow(only_pip)))
if (!identical(nrow(both), 1188L)) fail <- c(fail, sprintf("joined %d cells, expected 1188", nrow(both)))
if (!isTRUE(maxdiff == 0))         fail <- c(fail, sprintf("max |diff| = %s, expected exactly 0", format(maxdiff)))
# 2026-10-06 cc-cloud: B20. 117,944 -> 117,918 after the DEIS 2012-2023 infant-age fix (edad_tipo; 26 deaths aged
# 15-29 removed); re-derived from the 20261006 run (1188/1188 cells, max |diff| = 0).
if (sum(both$deaths) != 117918L)   fail <- c(fail, sprintf("total deaths %d, expected 117918", sum(both$deaths)))

if (length(fail)) {
  stop("\n*** GATE FAILED ***\n  ", paste(fail, collapse = "\n  "),
       "\n\nThe rebuilt death base does NOT reproduce the population the PIF is computed on.\n",
       "A YPLL built on it would be multiplied by a PIF from a DIFFERENT population.\n",
       "DO NOT SHIP IT. Find out why the death sets diverged -- most likely the ICD map in\n",
       "expand_pif.ipynb changed and ypll_icd_defs.R did not follow, or the AAF bundle /\n",
       "mortality xlsx pairing changed.\n")
}

# Per-disease cell counts, RESTRICTED TO THE SURVEY WAVES so the two sides are
# comparable. The grid is RAGGED -- a rare cancer with zero deaths in the youngest band
# is simply absent from the export, so e.g. Larynx Cancer has 36 cells and not 56.
# Reproducing that ragged SHAPE, cause by cause, is a far stronger check than the grand
# total, which could match by coincidence while individual causes cancelled out.
cat("PER-DISEASE CELL COUNTS, survey waves only (rebuild vs pipeline):\n")
mine_w <- mine[mine$year %in% waves, ]
pc <- merge(as.data.frame(table(mine_w$disease), responseName = "rebuild"),
            as.data.frame(table(pipe$disease),   responseName = "pipeline"), by = "Var1")
names(pc)[1] <- "disease"
pc$ok <- ifelse(pc$rebuild == pc$pipeline, "ok", "*** MISMATCH ***")
print(pc, row.names = FALSE)
stopifnot(all(pc$rebuild == pc$pipeline))

cat(sprintf("\n=============================================================\nGATE PASSED. %d/%d cells, max |diff| = 0, %d deaths.\nThe rebuilt death base IS the population the PIF is computed on.\nelapsed: %.2f min\n=============================================================\n",
            nrow(both), nrow(both), sum(both$deaths),
            as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
