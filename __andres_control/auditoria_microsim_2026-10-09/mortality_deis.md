# Baseline mortality for the microsimulation engine: DEIS deaths and INE populations

FONDECYT 1240138. Real-data design note for plan items 3–5 (mortality and RR, brief intervention, ageing). Audit date 2026-10-09.
Scope: no repository file was edited. Every table below holds aggregated counts only. The scripts that produced it are listed in section 0.

**Bottom line**

1. The engine's mortality drift is a **denominator problem, not a mortality problem**. HMD uses the same DEIS deaths (they match exactly at ages 15–65 in 2012–2023), but its exposures are HMD's own census-based estimates. They fall further and further below the INE stocks the engine runs on: −2.5%/−4.1% (women/men) in 2012, −6.3%/−9.5% in 2024. Applying HMD `qx` to INE stocks therefore drifts upward by about 0.26 (women) and 0.53 (men) percentage points per year. One constant sex multiplier cannot remove that.
2. Replace `HMD qx × multiplier` with **DEIS/INE rates** (the same INE file that drives the population), converted to the engine's **age at 1 January**. With that conversion, expected deaths match the cohort-consistent DEIS target within ±0.2% every year, with no fitted parameter.
3. In the engine's cells, cause-specific deaths are sparse: 30% of year × sex × band × cause cells at ages 15–65 have fewer than 10 deaths. The rule that predicts held-out years best is a **Poisson log-linear trend per cause × sex, with a natural spline in single age, fitted on 2012–2024 without 2020–2021**. Its held-out deviance is about 1 per cell (Poisson noise level), against 2.2 for rates held flat within each age band.
4. The 66 cut hides most of the burden. At ages 66+ fall 79.5% of all deaths among women aged 15+ and 66.2% among men, and 26–31% of AAF = 1 deaths. A crude extrapolation using the 60–65 AAFs puts **about 45% (men) and 68% (women)** of attributable deaths at 66+. This figure is an assumption-heavy upper-side figure, not an estimate.
5. Two existing artefacts are stale or provisional. The saved `mortality_concordance.csv` files (base and recalib) were built from the pre-fix DEIS parquet: 1,815 extra deaths at 15–65, all from the infant age-unit bug. DEIS 2024 is provisional: R99 deaths are +33% above 2018–2023 and road injuries −20%.

---

## 0. Inputs, provenance and what was run

| Input | Version used | How read |
|---|---|---|
| DEIS 2012–2023 | `_deis/DEFUNCIONES_DEIS_2012_2023_15plus.tar.xz.enc` (parquet md5 `8652ad19…`, 1,328,981 rows, post 2026-10-05 `EDAD_TIPO == 1` fix) | `acc_data()` → pyarrow → CSV in R `tempdir()` (deleted after read) |
| DEIS 2024 (provisional) | newest weekly file `DEFUNCIONES_FUENTE_DEIS_2024_2026_06102026` (CSV md5 `636c10f4…`), year 2024 only, `EDAD_TIPO == 1`, age ≥ 15 | `acc_deis()` |
| INE population | `__andres_control/ine_proyecciones_rebuild/ine_basedatos.xlsx`, sheet `BBDD_EEPP-2024_0101`, 1 January and 30 June stocks, ages 0–100+ (same file and sheet as `ms-demography-inputs`) | `readxl` |
| HMD | `fltper_1x1.txt`, `mltper_1x1.txt`, `Deaths_lexis.txt`, `CHLdeath.txt`, `CHLcom.pdf` (HMD last modified 12 Jan 2026) | text |
| ICD-10 map | partial causes: `__andres_control/ypll_icd_defs.R` (the project's own copy of the `expand_pif.ipynb` map); AAF = 1 lists copied from `expand_pif.ipynb` cell `mort-trends-age-sex-chile11-mortalidad-etiqueta` | `source()` |
| expand_pif AAF and attributable deaths | `aaf_nested_by_disease_20261007.rds`, `Mortality Estimates WHO 2024_20261007.xlsx` (scope: ages 15–65, 4 bands, 7 ENPG wave years) | `ypll_pipeline_deaths()` from `ypll_icd_defs.R` |

Scripts in `audit/` (run with `Rscript --vanilla`; renv cannot be restored here, so these are system R 4.3.3 packages):

- `01_extract_deis.R` reads the decrypted microdata and writes only aggregated counts to `agg/`.
- `02_drift_rates.R` reproduces the drift and builds m and q by single age (item 1).
- `03_cause_specific.R` builds the cause tables and the leave-one-year-out smoothing test (item 2).
- `04_age66plus_aaf.R` computes the 66+ shares, the reconciliation with expand_pif and the attributable extrapolation (item 3).
- `05_hazard_formula_selfcheck.R` is a synthetic-agent reference implementation of the proposed hazard, with assertions (item 5).
- `06_population_vintages.R` compares the INE files with the HMD exposures.
- `07_tables.py` formats this report.

**Verified by running code:** every number in the tables.

**Verified by reading only:** the engine logic cited by notebook cell label and line within the cell, and the expand_pif definitions.

**Not verified:** the INE vintage label ("Base CPV 2024" in `ms-demography-inputs`; HMD's documentation says CPV-2024-based INE estimates were not released as of 2026-01-06), and anything about the engine after a real re-run (no notebook was executed).

---

## 1. Item 1: the drift, and DEIS/INE rates by single age

### 1.1 The engine's multiplier reproduces exactly, and the saved outputs are stale

The engine fits one all-cause multiplier per sex (`ms-calibration-functions`, cell lines 80–84). It solves Σ `pop_jan · (1 − (1 − qx)^s)` = Σ DEIS deaths over 2012–2024, then applies `q = 1 − (1 − qx)^s` to every agent (`ms-annual-engine`, lines 82–87). The same `uniroot` call reproduces the saved multipliers to within 1e-6 (asserted), but only when fed the death totals stored in the saved outputs:

| sex | reproduced from saved outputs' DEIS totals | with corrected DEIS bundle | saved in model_parameters.csv |
|---|---|---|---|
| female | 0.969977 | 0.964468 | 0.969977 |
| male | 0.944949 | 0.941262 | 0.944949 |

Those totals are not the current bundle. `microsim_recalib_outputs/input_provenance.csv` and `microsim_base_outputs/input_provenance.csv` list the old parquet (md5 `edb4f608…`), which still contained the infants recorded in days or hours:

| sex | DEIS 15-65 2012-2024, current bundle | observed_deaths in microsim_recalib_outputs/mortality_concordance.csv | difference |
|---|---|---|---|
| female | 141,199 | 142,004 | 805 |
| male | 258,637 | 259,647 | 1,010 |

2024 agrees exactly. The README reports 1,824 misclassified deaths at 15–65 across 2012–2023. The 9-death gap from the 1,815 here is unexplained; one possibility, not checked, is records of indeterminate sex that the notebook's `Hombre`/`Mujer` filter drops.

### 1.2 What drives the drift (multiplier recalibrated on the corrected bundle)

"engine exp." is `pop_jan × q_engine` with the recalibrated multiplier. The last six columns decompose the drift: the HMD rate on INE June stocks, the HMD exposure against the INE June stock, and HMD deaths (`Deaths_lexis.txt`, both triangles) against DEIS.

| year | DEIS F | engine exp. F | rel. err F | DEIS M | engine exp. M | rel. err M | HMD mx x INE June / DEIS F | same M | HMD exposure vs INE June F | same M  | HMD deaths vs DEIS F | same  M |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 2012 | 9,916 | 9,761 | -1.6% | 17,908 | 17,374 | -3.0% | +3.7% | +4.8% | -2.5% | -4.1% | +0.0% | +0.0% |
| 2013 | 10,065 | 9,937 | -1.3% | 18,663 | 18,185 | -2.6% | +4.0% | +5.2% | -2.8% | -4.2% | +0.0% | +0.0% |
| 2014 | 9,986 | 9,895 | -0.9% | 18,649 | 18,267 | -2.0% | +4.2% | +5.6% | -3.0% | -4.5% | +0.0% | +0.0% |
| 2015 | 10,321 | 10,234 | -0.8% | 18,880 | 18,546 | -1.8% | +4.3% | +5.9% | -3.3% | -4.7% | +0.0% | -0.0% |
| 2016 | 10,223 | 10,151 | -0.7% | 18,520 | 18,257 | -1.4% | +4.5% | +6.4% | -3.6% | -5.3% | +0.0% | +0.0% |
| 2017 | 10,122 | 10,080 | -0.4% | 18,479 | 18,302 | -1.0% | +4.8% | +6.9% | -4.0% | -6.0% | +0.0% | +0.0% |
| 2018 | 10,333 | 10,313 | -0.2% | 18,403 | 18,339 | -0.3% | +5.0% | +7.5% | -4.7% | -6.8% | +0.0% | +0.0% |
| 2019 | 10,535 | 10,556 | +0.2% | 18,988 | 19,053 | +0.3% | +5.2% | +8.0% | -5.1% | -7.5% | +0.0% | +0.0% |
| 2020 | 11,983 | 12,030 | +0.4% | 22,151 | 22,328 | +0.8% | +5.3% | +8.4% | -5.1% | -7.8% | +0.0% | +0.0% |
| 2021 | 13,072 | 13,129 | +0.4% | 25,067 | 25,365 | +1.2% | +5.4% | +8.9% | -5.2% | -8.1% | +0.0% | +0.0% |
| 2022 | 11,832 | 11,919 | +0.7% | 22,458 | 22,887 | +1.9% | +5.6% | +9.6% | -5.4% | -8.5% | +0.0% | +0.0% |
| 2023 | 11,202 | 11,358 | +1.4% | 20,274 | 20,839 | +2.8% | +6.2% | +10.4% | -5.9% | -9.0% | +0.0% | +0.0% |
| 2024 | 11,609 | 11,836 | +2.0% | 20,197 | 20,895 | +3.5% | +6.6% | +11.0% | -6.3% | -9.5% | +0.0% | +0.0% |

- **The numerator is not the problem.** HMD deaths equal DEIS deaths at ages 15–65 in every year (differences under 0.02%; HMD spreads unknown ages proportionally). `CHLdeath.txt` counts 2020 twice under two reference codes, so the Lexis file was used.
- **The denominator is.** The HMD exposure implied by `Deaths / mx` runs 2.5–6.3% (women) and 4.1–9.5% (men) below the INE June stock, and the gap widens steadily. HMD's country notes (`CHLcom.pdf`, pp. 5–9) say it uses census counts with its own intercensal estimates rather than INE's official estimates, and that official estimates run above the 2017 and 2024 censuses at working ages, with migration as a likely cause.
- **The size matches.** Over 2012–2024 the HMD/INE exposure ratio moves 3.8 pp (women) and 5.4 pp (men). The engine's relative error moves 3.5 pp (from −1.6% to +2.0%) and 6.4 pp (from −3.0% to +3.5%). Fitted linear drift: +0.26 pp per year for women and +0.53 pp per year for men (`out_A1_drift_year_sex.csv`).
- **No alternative INE vintage exists in the repo.** `ine_proyecciones_2012_2024.xlsx` is identical to the 30 June stocks of `ine_basedatos.xlsx` (difference 0.0% in all 26 year × sex totals):

| year | sex | pop_old_workbook | pop_mid_cpv2024 | hmd_implied_exposure | old_vs_mid | hmd_vs_mid |
|---|---|---|---|---|---|---|
| 2012 | female | 6,096,866 | 6,096,866 | 5,942,106 | +0.0% | -2.5% |
| 2012 | male | 6,005,952 | 6,005,952 | 5,760,290 | +0.0% | -4.1% |
| 2017 | female | 6,465,665 | 6,465,665 | 6,204,558 | +0.0% | -4.0% |
| 2017 | male | 6,401,463 | 6,401,463 | 6,014,748 | +0.0% | -6.0% |
| 2020 | female | 6,716,451 | 6,716,451 | 6,375,525 | +0.0% | -5.1% |
| 2020 | male | 6,657,593 | 6,657,593 | 6,136,699 | +0.0% | -7.8% |
| 2024 | female | 6,953,441 | 6,953,441 | 6,516,323 | +0.0% | -6.3% |
| 2024 | male | 6,900,361 | 6,900,361 | 6,247,528 | +0.0% | -9.5% |

**Conclusion.** Use rates whose numerator (DEIS) and denominator (the INE stocks that drive the engine's population) come from one system. Expected deaths = rate × INE stock then reproduces DEIS by construction. If INE stocks overstate the population (as HMD suggests), the rates are understated by the same factor, but **death counts, and so deaths avoided, are right**. Revisit when INE publishes its CPV-2024-based series. Keep HMD only as an external comparator.

### 1.3 m = DEIS / INE June stock, q = m / (1 + m/2), single ages 15–65

Full table: `out_A2_m_q_year_sex_age.csv` (1,326 cells, none empty; minimum 13 deaths per cell). Selected ages below; q is per 1,000, and the CV and trend use 2012–2019:

| sex | age | 2012 | 2016 | 2019 | 2021 | 2024 | mean_deaths | cv_q_2012_2019 | cv_poisson | trend_pct_per_year_2012_2019 |
|---|---|---|---|---|---|---|---|---|---|---|
| female | 15 | 0.21 | 0.20 | 0.22 | 0.24 | 0.15 | 25 | 25.5% | 19.2% | -1.0% |
| female | 20 | 0.26 | 0.33 | 0.30 | 0.33 | 0.39 | 39 | 15.8% | 16.3% | +2.8% |
| female | 25 | 0.33 | 0.28 | 0.26 | 0.42 | 0.39 | 51 | 17.2% | 14.3% | -2.8% |
| female | 30 | 0.36 | 0.48 | 0.33 | 0.47 | 0.49 | 61 | 17.5% | 13.7% | -0.3% |
| female | 35 | 0.64 | 0.55 | 0.56 | 0.70 | 0.57 | 80 | 6.6% | 11.8% | -1.2% |
| female | 40 | 0.88 | 0.80 | 0.89 | 0.91 | 0.84 | 118 | 5.4% | 9.6% | +0.4% |
| female | 45 | 1.38 | 1.24 | 1.10 | 1.72 | 1.53 | 174 | 10.6% | 7.7% | -2.5% |
| female | 50 | 2.19 | 2.24 | 1.88 | 2.17 | 1.75 | 264 | 7.0% | 6.1% | -2.3% |
| female | 55 | 3.40 | 3.02 | 2.86 | 3.41 | 3.14 | 389 | 6.9% | 5.2% | -2.4% |
| female | 60 | 5.39 | 5.33 | 4.34 | 6.18 | 4.26 | 545 | 7.4% | 4.5% | -2.7% |
| female | 65 | 9.49 | 7.93 | 8.11 | 8.84 | 7.26 | 713 | 6.4% | 3.9% | -1.9% |
| male | 15 | 0.40 | 0.32 | 0.38 | 0.24 | 0.37 | 46 | 15.8% | 14.5% | -4.3% |
| male | 20 | 0.82 | 0.85 | 0.79 | 0.86 | 0.85 | 116 | 5.9% | 9.2% | -1.2% |
| male | 25 | 0.94 | 0.83 | 1.14 | 1.17 | 1.05 | 155 | 10.9% | 8.2% | +2.5% |
| male | 30 | 1.34 | 1.12 | 1.06 | 1.33 | 1.09 | 180 | 11.7% | 7.8% | -3.3% |
| male | 35 | 1.28 | 1.43 | 1.26 | 1.65 | 1.36 | 197 | 5.5% | 7.5% | -0.6% |
| male | 40 | 1.74 | 1.95 | 1.60 | 2.35 | 1.63 | 245 | 10.8% | 6.6% | -2.2% |
| male | 45 | 2.98 | 2.45 | 2.27 | 2.96 | 2.47 | 329 | 8.6% | 5.6% | -3.1% |
| male | 50 | 4.28 | 4.03 | 3.69 | 4.89 | 3.37 | 482 | 7.5% | 4.6% | -2.2% |
| male | 55 | 6.51 | 5.44 | 5.41 | 7.61 | 5.46 | 686 | 6.6% | 3.9% | -2.3% |
| male | 60 | 9.56 | 8.49 | 8.26 | 10.96 | 8.56 | 913 | 5.7% | 3.5% | -1.9% |
| male | 65 | 15.81 | 13.59 | 13.18 | 16.97 | 12.53 | 1106 | 9.1% | 3.2% | -3.5% |

Stability by band, as medians over the single ages in each band:

| sex | band | ages | mean_deaths_per_age | min_deaths | median_cv_q | median_cv_poisson | median_trend_pct | median_covid_ratio |
|---|---|---|---|---|---|---|---|---|
| female | 15-29 | 15 | 45 | 13 | 16.4% | 15.0% | -1.0% | 1.09 |
| female | 30-44 | 15 | 103 | 37 | 9.5% | 10.8% | -0.6% | 1.13 |
| female | 45-59 | 15 | 325 | 147 | 7.0% | 5.7% | -2.1% | 1.13 |
| female | 60-65 | 6 | 628 | 452 | 6.7% | 4.2% | -2.1% | 1.11 |
| male | 15-29 | 15 | 127 | 29 | 8.2% | 8.4% | -0.7% | 1.08 |
| male | 30-44 | 15 | 225 | 129 | 9.1% | 7.1% | -1.1% | 1.15 |
| male | 45-59 | 15 | 574 | 296 | 7.5% | 4.2% | -2.6% | 1.23 |
| male | 60-65 | 6 | 1002 | 719 | 6.5% | 3.4% | -1.8% | 1.17 |

How to read these:

- Year-to-year variation in single-age q is mostly Poisson noise plus a trend. The observed CV is close to the Poisson-only CV (16% vs 15% for women aged 15–29). Before COVID, rates were falling by about 1–3% per year (median −1.8% to −2.6% at ages 45–65).
- In 2020–2022, q was 8–23% above 2019 (band medians). Those years are real excess mortality and must not enter a projection trend.
- Single-age all-cause rates are usable year by year for the 2012–2024 reconstruction. For projections, use a log-linear trend fitted without 2020–2021.

### 1.4 Age at death versus age on 1 January (a level error of about 3%)

DEIS ages are ages at death. The engine applies q to the age an agent has on 1 January and keeps that agent until December. Someone aged a on 1 January dies at age a or a + 1, so the coherent annual probability is the "parallelogram" form `q_jan(a) = 1 − exp(−½[m(a) + m(a+1)])`. Its natural target is DEIS deaths at 15–65 minus half the deaths at 15, plus half the deaths at 66.

Ranges over 2012–2024:

| sex | naive_min | naive_max | par_min | par_max | edge_min | edge_max | d15 | d66 |
|---|---|---|---|---|---|---|---|---|
| female | -1.6% | -0.8% | +2.9% | +3.4% | -0.2% | +0.1% | 25 | 753 |
| male | -1.6% | -0.9% | +2.3% | +3.2% | -0.2% | +0.1% | 46 | 1,166 |

- **Naive form** (age-at-death q applied to the January stock): 0.8–1.6% below DEIS 15–65.
- **Parallelogram form:** 2.3–3.4% above DEIS 15–65, but within −0.2% to +0.1% of the cohort-consistent target.

So the engine's own cohort should die about 3% more often than the DEIS 15–65 total implies. Calibrating to that total quietly absorbs this error into the sex multiplier. It also needs DEIS rates at age 66 for agents aged 65, which are available (the bundle covers all ages 15+).

---

## 2. Item 2: cause-specific deaths and smoothing

### 2.1 Mapping, and reconciliation with expand_pif

The ICD-10 lists are the project's own (`ypll_icd_defs.R` plus the AAF = 1 block of `expand_pif.ipynb`). Chronic causes match on DIAG1; injuries match on DIAG1 or DIAG2; X45, X65 and Y15 match on DIAG2. Three checks hold:

- **Reconciliation with the pipeline (verified).** At ages 15–65 in the wave years, our counts equal the pipeline's own `n = mort / aaf` in all 1,188 cells (max |diff| = 2.3e-13). AAF = 1 counts equal `Fully attributable to alcohol` in the export (max |diff| = 0).
- **The causes are mutually exclusive in practice.** Zero deaths match more than one of the 24 expand_pif flags (all ages, 2012–2024), so the engine can treat them as competing causes without a hierarchy.
- **DEIS coding.** Every external-cause death has DIAG1 = S or T (nature of injury) and DIAG2 = V–Y (external cause); no S or T death has an empty DIAG2 (`agg/diag1_diag2_letters.csv`). That is why the DIAG1-or-DIAG2 rule for injuries is required.

Groups used: the 23 expand_pif diseases, the AAF = 1 block, COVID-19 (U07/U09/U10, split out because it is a period shock) and all other causes. Breast cancer in men is moved to "all other", as in expand_pif.

### 2.2 Counts and rates

Cell format: mean annual deaths 2012–2024 (rate per 100,000, pooled), then [number of years out of 13 with fewer than 10 deaths]. Rows are sorted by deaths at 15–65. Full data: `out_B1_cells_year_sex_band_cause.csv` and `out_B2_summary_cause_sex_band.csv`.

**Women**

| cause | 15-29 | 30-44 | 45-59 | 60-65 | 66-79 | 80+ |
|---|---|---|---|---|---|---|
| All other causes | 308 (14.9) [0] | 726 (35.6) [0] | 2453 (132.1) [0] | 2007 (344.8) [0] | 7940 (940.9) [0] | 15086 (4687.9) [0] |
| Ischaemic Heart Disease | 5 (0.2) [12] | 41 (2.0) [0] | 260 (14.0) [0] | 239 (41.1) [0] | 944 (111.9) [0] | 1746 (542.5) [0] |
| Intentional Injuries | 124 (6.0) [0] | 122 (6.0) [0] | 97 (5.2) [0] | 22 (3.8) [0] | 29 (3.5) [0] | 9 (2.7) [7] |
| Unintentional Injuries | 52 (2.5) [0] | 58 (2.8) [0] | 85 (4.6) [0] | 45 (7.8) [0] | 190 (22.6) [0] | 618 (192.0) [0] |
| Liver Cirrhosis | 2 (0.1) [13] | 40 (2.0) [0] | 154 (8.3) [0] | 86 (14.8) [0] | 211 (25.0) [0] | 83 (25.6) [0] |
| Road Injuries | 96 (4.6) [0] | 78 (3.8) [0] | 77 (4.2) [0] | 31 (5.3) [0] | 64 (7.6) [0] | 30 (9.2) [0] |
| COVID-19 (U07/U09/U10) | 14 (0.7) [10] | 47 (2.3) [9] | 187 (10.0) [8] | 172 (29.6) [8] | 638 (75.6) [8] | 946 (293.9) [8] |
| Stomach Cancer | 5 (0.2) [13] | 44 (2.1) [0] | 137 (7.4) [0] | 104 (17.9) [0] | 392 (46.5) [0] | 392 (121.7) [0] |
| Colon and rectum Cancer | 4 (0.2) [13] | 50 (2.4) [0] | 213 (11.5) [0] | 149 (25.7) [0] | 507 (60.0) [0] | 548 (170.3) [0] |
| Intracerebral Haemorrhage | 10 (0.5) [5] | 54 (2.6) [0] | 192 (10.4) [0] | 118 (20.2) [0] | 408 (48.4) [0] | 464 (144.1) [0] |
| Breast Cancer | 6 (0.3) [11] | 128 (6.3) [0] | 401 (21.6) [0] | 201 (34.5) [0] | 456 (54.1) [0] | 397 (123.2) [0] |
| DM2 | 4 (0.2) [13] | 17 (0.8) [0] | 109 (5.9) [0] | 110 (18.9) [0] | 472 (55.9) [0] | 798 (247.9) [0] |
| Hypertensive Heart Disease | 2 (0.1) [13] | 12 (0.6) [4] | 95 (5.1) [0] | 109 (18.8) [0] | 702 (83.2) [0] | 2869 (891.6) [0] |
| Lower Respiratory Infection | 8 (0.4) [9] | 21 (1.0) [1] | 65 (3.5) [0] | 59 (10.1) [0] | 366 (43.4) [0] | 1593 (495.1) [0] |
| Pancreatic Cancer | 1 (0.0) [13] | 11 (0.5) [7] | 103 (5.6) [0] | 105 (18.0) [0] | 342 (40.5) [0] | 261 (81.2) [0] |
| HIV | 6 (0.3) [12] | 33 (1.6) [0] | 26 (1.4) [0] | 6 (1.0) [11] | 7 (0.8) [12] | 2 (0.5) [13] |
| Ischaemic Stroke | 2 (0.1) [13] | 14 (0.7) [0] | 62 (3.3) [0] | 66 (11.4) [0] | 432 (51.2) [0] | 1140 (354.4) [0] |
| Liver Cancer | 1 (0.1) [13] | 7 (0.3) [11] | 65 (3.5) [0] | 73 (12.6) [0] | 292 (34.6) [0] | 193 (59.9) [0] |
| Fully attributable (AAF=1) | 1 (0.0) [13] | 5 (0.2) [12] | 11 (0.6) [6] | 4 (0.6) [12] | 6 (0.7) [12] | 1 (0.4) [13] |
| Epilepsy | 12 (0.6) [1] | 16 (0.8) [1] | 23 (1.3) [0] | 13 (2.3) [3] | 28 (3.4) [0] | 35 (10.8) [0] |
| Tuberculosis | 3 (0.1) [13] | 7 (0.4) [11] | 15 (0.8) [2] | 10 (1.7) [7] | 41 (4.8) [0] | 55 (17.0) [0] |
| Acute Pancreatitis | 3 (0.1) [13] | 8 (0.4) [10] | 17 (0.9) [1] | 13 (2.3) [3] | 45 (5.4) [0] | 59 (18.2) [0] |
| Oesophagus Cancer | 0 (0.0) [13] | 1 (0.1) [13] | 15 (0.8) [0] | 16 (2.7) [1] | 87 (10.3) [0] | 113 (35.2) [0] |
| Oral Cavity and Pharynx Cancer | 0 (0.0) [13] | 3 (0.2) [13] | 9 (0.5) [6] | 6 (1.1) [12] | 20 (2.4) [0] | 31 (9.5) [0] |
| Larynx Cancer | 0 (0.0) [13] | 0 (0.0) [13] | 3 (0.1) [13] | 2 (0.3) [13] | 8 (1.0) [8] | 7 (2.1) [11] |
| Other Pharyngeal Cancer | 0 (0.0) [13] | 1 (0.0) [13] | 4 (0.2) [13] | 3 (0.4) [13] | 8 (0.9) [9] | 8 (2.5) [9] |

**Men**

| cause | 15-29 | 30-44 | 45-59 | 60-65 | 66-79 | 80+ |
|---|---|---|---|---|---|---|
| All other causes | 453 (21.3) [0] | 917 (44.7) [0] | 3106 (176.4) [0] | 2570 (488.5) [0] | 9627 (1380.4) [0] | 10765 (5652.6) [0] |
| Ischaemic Heart Disease | 21 (1.0) [0] | 170 (8.3) [0] | 941 (53.4) [0] | 704 (133.9) [0] | 1897 (272.0) [0] | 1444 (758.3) [0] |
| Intentional Injuries | 599 (28.1) [0] | 643 (31.3) [0] | 462 (26.3) [0] | 123 (23.5) [0] | 169 (24.2) [0] | 62 (32.7) [0] |
| Unintentional Injuries | 312 (14.6) [0] | 415 (20.2) [0] | 495 (28.1) [0] | 193 (36.8) [0] | 421 (60.4) [0] | 351 (184.5) [0] |
| Liver Cirrhosis | 7 (0.3) [10] | 176 (8.6) [0] | 786 (44.6) [0] | 346 (65.9) [0] | 532 (76.3) [0] | 106 (55.8) [0] |
| Road Injuries | 371 (17.4) [0] | 372 (18.1) [0] | 358 (20.4) [0] | 125 (23.7) [0] | 181 (26.0) [0] | 52 (27.5) [0] |
| COVID-19 (U07/U09/U10) | 17 (0.8) [10] | 89 (4.3) [9] | 341 (19.4) [8] | 280 (53.2) [8] | 917 (131.5) [8] | 868 (456.0) [8] |
| Stomach Cancer | 4 (0.2) [13] | 46 (2.3) [0] | 319 (18.1) [0] | 295 (56.0) [0] | 930 (133.3) [0] | 526 (276.5) [0] |
| Colon and rectum Cancer | 8 (0.4) [12] | 49 (2.4) [0] | 236 (13.4) [0] | 190 (36.1) [0] | 603 (86.4) [0] | 398 (208.9) [0] |
| Intracerebral Haemorrhage | 14 (0.7) [1] | 75 (3.6) [0] | 257 (14.6) [0] | 160 (30.3) [0] | 425 (60.9) [0] | 291 (152.7) [0] |
| DM2 | 5 (0.3) [13] | 26 (1.3) [0] | 167 (9.5) [0] | 161 (30.5) [0] | 595 (85.3) [0] | 532 (279.2) [0] |
| Hypertensive Heart Disease | 3 (0.1) [13] | 26 (1.3) [0] | 173 (9.8) [0] | 175 (33.3) [0] | 779 (111.7) [0] | 1479 (776.8) [0] |
| Lower Respiratory Infection | 11 (0.5) [7] | 51 (2.5) [0] | 163 (9.2) [0] | 111 (21.0) [0] | 517 (74.1) [0] | 1139 (598.1) [0] |
| Pancreatic Cancer | 1 (0.0) [13] | 15 (0.7) [0] | 118 (6.7) [0] | 107 (20.3) [0] | 301 (43.1) [0] | 148 (77.6) [0] |
| HIV | 38 (1.8) [0] | 156 (7.6) [0] | 137 (7.8) [0] | 25 (4.7) [0] | 26 (3.7) [0] | 5 (2.4) [12] |
| Ischaemic Stroke | 2 (0.1) [13] | 13 (0.6) [2] | 109 (6.2) [0] | 134 (25.4) [0] | 687 (98.5) [0] | 860 (451.4) [0] |
| Liver Cancer | 2 (0.1) [13] | 11 (0.5) [3] | 97 (5.5) [0] | 113 (21.5) [0] | 354 (50.8) [0] | 160 (83.9) [0] |
| Fully attributable (AAF=1) | 5 (0.2) [12] | 36 (1.7) [0] | 100 (5.7) [0] | 41 (7.8) [0] | 66 (9.5) [0] | 14 (7.1) [3] |
| Epilepsy | 19 (0.9) [0] | 31 (1.5) [0] | 47 (2.7) [0] | 19 (3.7) [0] | 42 (6.0) [0] | 26 (13.7) [0] |
| Tuberculosis | 6 (0.3) [9] | 24 (1.2) [0] | 61 (3.5) [0] | 28 (5.3) [0] | 69 (9.9) [0] | 49 (25.9) [0] |
| Acute Pancreatitis | 5 (0.2) [13] | 21 (1.0) [0] | 45 (2.5) [0] | 21 (4.0) [0] | 59 (8.4) [0] | 37 (19.3) [0] |
| Oesophagus Cancer | 0 (0.0) [13] | 3 (0.2) [13] | 35 (2.0) [0] | 46 (8.7) [0] | 173 (24.8) [0] | 127 (66.9) [0] |
| Oral Cavity and Pharynx Cancer | 1 (0.0) [13] | 4 (0.2) [13] | 23 (1.3) [0] | 18 (3.5) [0] | 40 (5.7) [0] | 26 (13.7) [0] |
| Larynx Cancer | 0 (0.0) [13] | 1 (0.1) [13] | 16 (0.9) [2] | 18 (3.4) [1] | 53 (7.6) [0] | 32 (16.7) [0] |
| Other Pharyngeal Cancer | 0 (0.0) [13] | 1 (0.1) [13] | 11 (0.7) [3] | 13 (2.5) [1] | 29 (4.2) [0] | 13 (7.1) [4] |

Small cells (year × sex × band × cause):

| scope | cells | cells_lt10 | cells_zero |
|---|---|---|---|
| 15-65 (engine) | 2,652 | 798 | 214 |
| 66+ | 1,326 | 145 | 40 |

Year-to-year CV of the band rate (2012–2019; medians across the 49 cause × sex rows per band, COVID excluded), against the CV that Poisson noise alone would give:

| band | cells | mean_deaths_median | cv_rate_median | cv_poisson_median | causes_with_any_year_lt10 | causes_all_years_lt10 |
|---|---|---|---|---|---|---|
| 15-29 | 49 | 5 | 40.5% | 45.1% | 38 | 26 |
| 30-44 | 49 | 26 | 21.7% | 19.5% | 18 | 8 |
| 45-59 | 49 | 100 | 14.7% | 10.0% | 8 | 2 |
| 60-65 | 49 | 86 | 18.6% | 10.8% | 11 | 2 |

At 15–29 the observed CV (40%) is no larger than the Poisson CV (45%): those cells are noise. At 45–65 the observed CV exceeds the Poisson CV (15–19% vs 10–11%), so trends are real and a constant rate is not enough.

### 2.3 Which smoothing rule? (leave-one-year-out test, verified)

Method: hold out each year from 2013 to 2023, predict its cause × sex × band deaths from the other years, and score with the Poisson deviance. The ranking below excludes the COVID cause and the held-out years 2020–2022. A pure-noise forecast scores about 1 per cell.

| method | cells_excl_covid | deviance_excl_2020_22_and_covid_cause | deviance_per_cell_excl_covid | poisson_deviance | mae_deaths | floored |
|---|---|---|---|---|---|---|
| S4_trend_excl_2020_21 | 1,568 | 2,585 | 1.65 | 64,109 | 17.2 | 46 |
| S3_trend_by_band | 1,568 | 2,672 | 1.70 | 41,816 | 18.3 | 46 |
| S1_neighbours | 1,568 | 2,759 | 1.76 | 13,694 | 13.9 | 130 |
| S5_trend_shared_across_bands | 1,568 | 2,929 | 1.87 | 42,219 | 18.8 | 43 |
| S2_mean_other_years | 1,568 | 4,036 | 2.57 | 52,914 | 22.4 | 44 |

The S methods differ as follows:

- S1: the two neighbouring years pooled.
- S2: the mean of all other years.
- S3: a log-linear trend per cause × sex × band.
- S4: S3 fitted without 2020–2021.
- S5: one trend shared across the bands of a cause × sex.

"floored" counts predictions raised to 0.1 expected deaths because the pooled rate was zero.

At single age (what the engine needs), compare two shapes, both with a linear year trend fitted without 2020–2021: a rate held flat within each band, and a natural spline in age with knots at the band edges (29.5, 44.5, 59.5):

| cause | cells | flat/cell | spline/cell |
|---|---|---|---|
| All other causes | 816 | 13.71 | 1.21 |
| Breast Cancer | 408 | 2.43 | 0.91 |
| Colon and rectum Cancer | 816 | 2.18 | 1.02 |
| Fully attributable (AAF=1) | 816 | 1.10 | 0.97 |
| Intentional Injuries | 816 | 1.79 | 1.32 |
| Ischaemic Heart Disease | 816 | 4.54 | 1.01 |
| Liver Cirrhosis | 816 | 2.82 | 1.02 |
| Road Injuries | 816 | 1.53 | 1.37 |
| TOTAL | 20,808 | 2.19 | 1.03 |

**Recommended rule:**

1. For each cause c and sex, fit `log m_c(a, t) = ns(a; knots 29.5, 44.5, 59.5) + β_c,s · (t − 2018)` as a Poisson GLM with offset log(INE June stock). Use single ages 15–66 (66 is needed for the January-age conversion) and years 2012–2024 without 2020–2021.
2. Sparse causes (larynx, other pharyngeal, oral, oesophagus at 15–44) may need fewer spline degrees of freedom, or pooling with sibling causes that share an RR curve, such as "upper aerodigestive cancers" pooled for the baseline and split by their 2012–2024 shares.
3. For the residual ("all other causes"), use the observed year-specific all-cause rate minus the smoothed alcohol-related rates in reconstruction years, so that all-cause matches DEIS exactly. For projections, use the smoothed residual without COVID codes. Assert the residual is ≥ 0 in every cell.
4. Keep COVID as its own hazard, observed and year-specific for 2020–2023, and zero in projections.

**Why expected deaths, not realized draws, must carry the result.** The INE 2024 January population aged 15–65 is 13,796,488.

| cause | deaths_per_year | sim_deaths_per_year_n25k | sim_deaths_per_year_n100k | mc_rel_se_n100k_realized |
|---|---|---|---|---|
| All other causes | 13,488 | 24.44 | 97.8 | 10.1% |
| Ischaemic Heart Disease | 2,648 | 4.80 | 19.2 | 22.8% |
| Intentional Injuries | 2,403 | 4.35 | 17.4 | 24.0% |
| Unintentional Injuries | 1,942 | 3.52 | 14.1 | 26.7% |
| Road Injuries | 1,470 | 2.66 | 10.7 | 30.6% |
| Liver Cirrhosis | 1,432 | 2.59 | 10.4 | 31.0% |
| Colon and rectum Cancer | 1,135 | 2.06 | 8.2 | 34.9% |
| COVID-19 (U07/U09/U10) | 991 | 1.80 | 7.2 | 37.3% |
| Stomach Cancer | 888 | 1.61 | 6.4 | 39.4% |
| Intracerebral Haemorrhage | 845 | 1.53 | 6.1 | 40.4% |
| Breast Cancer | 802 | 1.45 | 5.8 | 41.5% |
| Hypertensive Heart Disease | 686 | 1.24 | 5.0 | 44.8% |
| DM2 | 638 | 1.16 | 4.6 | 46.5% |
| Lower Respiratory Infection | 579 | 1.05 | 4.2 | 48.8% |
| Pancreatic Cancer | 496 | 0.90 | 3.6 | 52.7% |
| Ischaemic Stroke | 426 | 0.77 | 3.1 | 56.9% |
| Liver Cancer | 399 | 0.72 | 2.9 | 58.8% |
| HIV | 336 | 0.61 | 2.4 | 64.1% |
| Epilepsy | 204 | 0.37 | 1.5 | 82.3% |
| Tuberculosis | 169 | 0.31 | 1.2 | 90.4% |
| Fully attributable (AAF=1) | 160 | 0.29 | 1.2 | 93.0% |
| Acute Pancreatitis | 132 | 0.24 | 1.0 | 102.2% |
| Oesophagus Cancer | 107 | 0.19 | 0.8 | 113.7% |
| Oral Cavity and Pharynx Cancer | 75 | 0.14 | 0.5 | 135.9% |
| Larynx Cancer | 37 | 0.07 | 0.3 | 192.2% |
| Other Pharyngeal Cancer | 37 | 0.07 | 0.3 | 194.0% |

In a 25,000-agent run, most causes see fewer than 2 realized deaths per year. Even with 100,000 agents, a realized-death estimate has a Monte Carlo relative SE of 23% (IHD) to over 190% (larynx). Report **expected deaths**, the sum of each agent's annual death probability, by cause, and compare arms with common random numbers. Use the realized draw only to remove agents.

---

## 3. Item 3: what the cut at 66 loses

### 3.1 Observed deaths (all ages ≥ 15, 2012–2024 pooled)

| group | sex | d15_65 | d66_79 | d80p | share_66_79 | share_66plus |
|---|---|---|---|---|---|---|
| AAF=1 causes | female | 260 | 75 | 17 | 21.3% | 26.1% |
| AAF=1 causes | male | 2,368 | 864 | 176 | 25.4% | 30.5% |
| All causes | female | 141,199 | 190,260 | 357,253 | 27.6% | 79.5% |
| All causes | male | 258,637 | 253,397 | 253,636 | 33.1% | 66.2% |
| Non-alcohol causes | female | 76,890 | 111,505 | 208,420 | 28.1% | 80.6% |
| Non-alcohol causes | male | 101,050 | 137,078 | 151,230 | 35.2% | 74.0% |
| Partially attributable causes (23 expand_pif diseases) | female | 64,049 | 78,680 | 148,816 | 27.0% | 78.0% |
| Partially attributable causes (23 expand_pif diseases) | male | 155,219 | 115,455 | 102,230 | 31.0% | 58.4% |

Range across years of the 66+ share:

| sex | all_min | all_max | aaf1_min | aaf1_max | partial_min | partial_max |
|---|---|---|---|---|---|---|
| female | 78.0% | 81.7% | 12.5% | 42.3% | 76.6% | 79.3% |
| male | 63.8% | 68.9% | 20.6% | 42.3% | 56.4% | 61.0% |

Share at 66+ by cause, pooled 2012–2024 (`out_C1_share66_cause_sex.csv`):

| cause | female | male |
|---|---|---|
| Hypertensive Heart Disease | 94.2% | 85.7% |
| Ischaemic Stroke | 91.6% | 85.7% |
| Lower Respiratory Infection | 92.8% | 83.1% |
| Oesophagus Cancer | 86.2% | 78.2% |
| DM2 | 84.1% | 75.8% |
| All other causes | 80.7% | 74.3% |
| COVID-19 (U07/U09/U10) | 79.0% | 71.1% |
| Larynx Cancer | 75.4% | 71.0% |
| Liver Cancer | 76.7% | 69.7% |
| Stomach Cancer | 73.1% | 68.7% |
| Colon and rectum Cancer | 71.7% | 67.5% |
| Pancreatic Cancer | 73.3% | 65.1% |
| Ischaemic Heart Disease | 83.1% | 64.5% |
| Other Pharyngeal Cancer | 67.4% | 62.3% |
| Oral Cavity and Pharynx Cancer | 73.3% | 58.7% |
| Intracerebral Haemorrhage | 70.0% | 58.6% |
| Acute Pancreatitis | 71.6% | 51.0% |
| Tuberculosis | 73.0% | 49.6% |
| Epilepsy | 49.5% | 36.7% |
| Unintentional Injuries | 77.1% | 35.3% |
| Liver Cirrhosis | 50.9% | 32.7% |
| Fully attributable (AAF=1) | 26.1% | 30.5% |
| Road Injuries | 25.0% | 16.0% |
| Intentional Injuries | 9.5% | 11.2% |
| HIV | 10.7% | 7.9% |
| Breast Cancer | 53.7% |  |

### 3.2 Alcohol-attributable deaths at 66+ (crude extrapolation, an assumption)

**Scope of the saved expand_pif tables.** `Mortality Estimates WHO 2024_20261007.xlsx`, `aaf_nested_by_disease_20261007.rds` and `tables_expand_pif3/*.csv` cover only ages 15–65, in four bands, and the 7 ENPG wave years. They contain no attributable deaths at 66+, so the excluded share cannot be read from them.

**Extrapolation.** Each disease's 60–65 AAF (same year and sex) was applied to its deaths at 66–79 and at 80+, and the observed AAF = 1 deaths at 66+ were added. Wave years pooled:

| sex | attr_15_65 | attr66p_net | aaf1_66_79 | aaf1_80p | attr_15_65_harm_only | attr66p_harm | share_net | share_harm |
|---|---|---|---|---|---|---|---|---|
| female | 5,344 | 11,342 | 44 | 9 | 5,375 | 11,620 | 68.0% | 68.4% |
| male | 22,243 | 17,817 | 463 | 89 | 22,245 | 17,842 | 44.5% | 44.5% |

By wave year:

| year | sex | attr_15_65 | attr66p_net | share_attr_66p_net | share_attr_66_79_net |
|---|---|---|---|---|---|
| 2012 | female | 705 | 1,257 | 64.1% | 31.4% |
| 2012 | male | 3,220 | 2,118 | 39.7% | 26.0% |
| 2014 | female | 692 | 1,354 | 66.2% | 31.3% |
| 2014 | male | 3,156 | 2,258 | 41.7% | 25.9% |
| 2016 | female | 775 | 1,543 | 66.6% | 31.1% |
| 2016 | male | 3,181 | 2,408 | 43.1% | 27.1% |
| 2018 | female | 738 | 1,653 | 69.1% | 32.1% |
| 2018 | male | 3,056 | 2,373 | 43.7% | 26.7% |
| 2020 | female | 819 | 1,731 | 67.9% | 30.7% |
| 2020 | male | 3,267 | 2,716 | 45.4% | 27.4% |
| 2022 | female | 822 | 1,928 | 70.1% | 31.1% |
| 2022 | male | 3,579 | 3,088 | 46.3% | 28.2% |
| 2024 | female | 794 | 1,876 | 70.3% | 31.3% |
| 2024 | male | 2,784 | 2,856 | 50.6% | 30.5% |

Sensitivity: drop the causes whose RR is age-attenuated or J-shaped (IHD, ischaemic stroke, ICH, HHD, diabetes) from both sides:

| sex | attr66p_partial | attr_15_65 | aaf1_66p | share_66p |
|---|---|---|---|---|
| female | 6,321 | 4,100 | 53 | 60.9% |
| male | 12,298 | 20,208 | 552 | 38.9% |

Largest contributors at 66+ (summed over wave years):

| sex | disease | deaths_66p | aaf_60_65_mean | attr_66_79 | attr_80p |
|---|---|---|---|---|---|
| female | Ischaemic Heart Disease | 18,850 | 0.177 | 1,167 | 2,179 |
| female | Liver Cancer | 3,347 | 0.414 | 830 | 566 |
| female | Liver Cirrhosis | 2,099 | 0.630 | 942 | 377 |
| female | Intracerebral Haemorrhage | 6,084 | 0.189 | 542 | 609 |
| female | Stomach Cancer | 5,503 | 0.156 | 425 | 432 |
| female | Pancreatic Cancer | 4,271 | 0.160 | 392 | 299 |
| male | Liver Cirrhosis | 4,574 | 0.680 | 2,564 | 545 |
| male | Colon and rectum Cancer | 7,098 | 0.363 | 1,577 | 1,030 |
| male | Hypertensive Heart Disease | 16,072 | 0.106 | 579 | 1,119 |
| male | Ischaemic Heart Disease | 23,519 | 0.069 | 927 | 716 |
| male | Liver Cancer | 3,629 | 0.349 | 894 | 388 |
| male | Unintentional Injuries | 5,509 | 0.184 | 548 | 463 |

**How to read it.** The AAF = 1 part (552 deaths in men and 53 in women across the 7 wave years) is observed, not modelled. The partial-cause part is probably an upper bound. Drinking prevalence falls after 65, ENPG has no data above 65, and the 60–65 AAF for women's IHD is **+0.18**, which drives 3,346 of the women's 11,342 deaths at 66+; IHD RRs are usually attenuated with age. Even so, the order of magnitude is robust: **excluding everything from 66 onward removes between a third and two thirds of the attributable burden**, and ages 66–79 alone account for 26–32% of it. This puts item 5 (ageing) close to the critical path for any claim about deaths avoided. It is not "posterior" for interpretation, even if it is for the Monday deliverable.

---

## 4. Data quality

| check | value |
|---|---|
| rows | 1328981 |
| gender values | Hombre 700663; Mujer 628318 |
| identical rows (year,gender,age,comuna,region,diag1,diag2) | 124704 |
| diag1 missing | 0 |
| diag2 non-missing | 92227 |
| source version | 06102026 |
| rows 2024 | 126928 |
| 2024 EDAD_TIPO counts | 0 9; 1 125964; 2 224; 3 356; 4 375 |
| 2024 sex counts | Hombre 65838; Indeterminado 3; Mujer 61087 |
| 2024 exact duplicate rows (all 27 columns) | 41 |
| 2024 EDAD_CANT missing (EDAD_TIPO==1) | 0 |
| 2024 diag1 missing | 0 |

- **Missing age and sex.** The 2012–2023 bundle keeps only `EDAD_TIPO == 1` and age ≥ 15, so missing age is filtered at build (README: 2 records with an unknown unit). Its sexes are only Hombre and Mujer. In 2024, 9 records with an unknown age unit and 955 records with age in units other than years (`EDAD_TIPO` 2–4, infants) are excluded. The 3 records of indeterminate sex are not among the records aged 15+ in completed years. After filters, sex is missing in 0 deaths.
- **Duplicates.** The 2024 file has 41 rows identical across all 27 columns (0.03%), including date, comuna and ICD subcategory. They are possible duplicates, but small; expand_pif does not drop them either. In 2012–2023 the bundle has no date or ID, so the 124,704 rows identical on its 7 columns cannot be read as duplicates.

**Ill-defined causes (R00–R99)**, share of deaths by year and band:

| year | 15-29 | 30-44 | 45-59 | 60-65 | 66-79 | 80+ |
|---|---|---|---|---|---|---|
| 2012 | 2.6% | 2.5% | 1.8% | 1.3% | 1.5% | 3.9% |
| 2013 | 2.2% | 2.3% | 1.5% | 1.1% | 1.1% | 3.3% |
| 2014 | 2.8% | 3.0% | 2.0% | 1.3% | 1.5% | 3.6% |
| 2015 | 2.4% | 2.7% | 1.6% | 1.3% | 1.3% | 3.2% |
| 2016 | 2.9% | 3.4% | 2.4% | 1.7% | 1.6% | 3.5% |
| 2017 | 4.5% | 4.1% | 2.5% | 1.6% | 1.5% | 3.1% |
| 2018 | 3.8% | 4.2% | 2.3% | 1.6% | 1.3% | 3.1% |
| 2019 | 3.6% | 3.3% | 2.2% | 1.6% | 1.6% | 3.2% |
| 2020 | 3.2% | 2.8% | 2.3% | 1.6% | 1.5% | 3.0% |
| 2021 | 2.7% | 2.8% | 2.2% | 1.6% | 1.4% | 2.7% |
| 2022 | 3.2% | 3.3% | 2.4% | 1.6% | 1.6% | 2.9% |
| 2023 | 2.6% | 3.1% | 2.4% | 1.9% | 1.7% | 2.8% |
| 2024 | 4.1% | 4.2% | 3.3% | 2.5% | 2.3% | 3.6% |

R codes at ages 15–65:

| year | R96 | R98 | R99 | other R |
|---|---|---|---|---|
| 2012 | 14 | 9 | 401 | 85 |
| 2013 | 21 | 7 | 366 | 58 |
| 2014 | 14 | 27 | 432 | 108 |
| 2015 | 15 | 14 | 437 | 49 |
| 2016 | 15 | 42 | 569 | 60 |
| 2017 | 37 | 32 | 613 | 65 |
| 2018 | 8 | 7 | 643 | 59 |
| 2019 | 14 | 30 | 539 | 97 |
| 2020 | 43 | 23 | 600 | 94 |
| 2021 | 56 | 5 | 626 | 114 |
| 2022 | 45 | 8 | 642 | 117 |
| 2023 | 37 | 7 | 601 | 110 |
| 2024 | 41 | 5 | 810 | 178 |

Injury deaths and all other causes at 15–65:

| year | All other causes | Intentional Injuries | Road Injuries | Unintentional Injuries |
|---|---|---|---|---|
| 2019 | 12,576 | 2,115 | 1,514 | 1,838 |
| 2020 | 12,458 | 1,898 | 1,395 | 1,945 |
| 2021 | 13,204 | 1,852 | 1,629 | 1,706 |
| 2022 | 13,260 | 2,552 | 1,659 | 1,926 |
| 2023 | 13,376 | 2,392 | 1,526 | 1,840 |
| 2024 | 13,829 | 2,264 | 1,224 | 2,061 |

**2024 is provisional for cause of death.**

- R99 deaths at 15–65 jumped to 810 from 539–643 in 2018–2023, about +200 above the 2018–2023 mean of 609.
- Road injuries fell to 1,224 from 1,395–1,659.
- This pattern is consistent with deaths pending medico-legal classification. The weekly file did not change 2024 between the June and October 2026 releases (README), so waiting a week will not fix it.
- **Recommendation:** use the smoothed hazard for 2024 injuries, not the observed one. As a sensitivity, reallocate the 2024 R99 excess to external causes in proportion to their 2018–2023 shares at 15–44.

The ill-defined share rises from 1.3–2.6% (2012) to 2.5–4.2% (2024) at 15–65. It sits in "all other causes", so the alcohol-related hazards are slightly understated in later years.

COVID-19 deaths (U07/U09/U10) by year:

| year | 15-65 | 66+ |
|---|---|---|
| 2020 | 4,824 | 13,827 |
| 2021 | 7,116 | 15,804 |
| 2022 | 2,308 | 11,086 |
| 2023 | 478 | 2,233 |
| 2024 | 188 | 848 |

---

## 5. Recommendation for the engine (items 3–5)

### 5.1 Hazard

**Notation.**

- k = (year t, sex s, single age a on 1 January); b(k) = its ENPG band.
- M_c(s, a, t) = the smoothed DEIS/INE rate for cause c at age at death a (section 2.3).

**Convert to January age:**
`h_c(k) = ½ [M_c(s, a, t) + M_c(s, a + 1, t)]`

**Person-level hazard** for agent i with exposure x_i (status never / former / current, g/day, HED):

```
h_ic   = h_c(k) · RR_c(x_i) / R̄_c(s, b, t)          partial causes (23 expand_pif diseases)
R̄_c   = mean over baseline-arm agents j in (s, b, t) of RR_c(x_j)
h_i1   = h_1(k) · w(x_i) / w̄(s, b, t)                AAF = 1 block
h_i0   = h_res(k) + h_covid(k)                        not alcohol-dependent
q_i    = 1 − exp(−Σ_c h_ic)                           one annual draw; cause drawn ∝ h_ic
```

**Why normalize at the band, not the single age.** With 25,000 agents a single-age × sex cell has about 245 agents, which is too few for a stable mean RR. Normalizing at the band keeps hazards at single age while expected deaths reproduce DEIS by construction. Then `1 − 1/R̄_c` is exactly the simulated AAF for the band (asserted in `05_hazard_formula_selfcheck.R`).

**Same RR as expand_pif.** RR_c(x) should come from the same registry that expand_pif uses (WHO/Adam; Table 5 PUC for ischaemic stroke as in pif3). Use the former-drinker RR where the registry has one, and the HED component for injuries. Agents need the fields the engine already carries: `ever`, `current`, `gpd_survey` and `hed`.

**AAF = 1 causes.** RR is undefined for these causes, so use a weight instead:

- **Never drinkers:** w = 0, so their hazard is exactly zero.
- **Current drinkers:** w = g/day. This is a linear absolute-risk assumption, as in Sheffield-type models; the source is to be confirmed. A sensitivity uses w = g/day above a threshold, or HED-weighted.
- **Former drinkers:** w = φ · w̄ of current drinkers. Default φ = 0.5, with sensitivity φ ∈ {0, 1}. Alcohol use disorder (F10) and alcoholic cardiomyopathy (I42.6) deaths include sick quitters.

Under linear w, a 10% volume cut among current drinkers removes exactly 10% of their AAF = 1 hazard (asserted).

### 5.2 Intervention arm (item 4)

- **Freeze the denominators.** The scenario arm uses `h'_ic = h_c(k) · RR_c(x'_i) / R̄_c(baseline)`, with R̄ taken from the baseline arm in the same year and seed. Expected avoided deaths in a band are then `deaths × (1 − mean RR' / mean RR)`, the same PIF that expand_pif uses (`1 − R_cf / R_obs`). Re-normalizing inside the scenario arm **cancels the effect exactly** (assert V5 in the self-check).
- **Do not reconcile the intervention arm to INE stocks.** Today, every January the engine adds or removes random agents until each sex × age matches the INE stock (`ms-annual-engine`, lines 103–120). In the intervention arm that step deletes the survivors the intervention created. Instead, replay the baseline arm's net inflow and outflow counts by sex × age as fixed flows. Only the baseline arm reconciles to INE.
- **Timing (an assumption to document).** For injuries and AAF = 1 poisonings, apply the change in the same year. For chronic causes, the minimum deliverable may also apply it immediately, but label the result as a short-run upper bound; a lag function is a later refinement.
- **Exits at 66 (until item 5).** Report deaths avoided at 15–65 only, and state that 26–32% (66–79) or more of the attributable burden lies outside scope (section 3).

### 5.3 What to calibrate and what to validate

- **Calibrate (by construction, no fitting):** h_c(k) from DEIS/INE, and the R̄ and w̄ normalizations. Drop the HMD path and the sex multiplier.
- **Validate (do not tune to these):**
  - (a) The simulated AAF `1 − 1/R̄_c` by cause × sex × band × wave year, against the expand_pif AAF (`aaf_nested_by_disease_<date>.rds`).
  - (b) The PIF from engine runs of −10% and −20% volume, against the expand_pif / pif2 PIF for the same scenarios.
  - (c) Injury AAFs once the HED calibration (item 2 of the plan) is fixed.

  Differences mainly measure the gap between the engine's Gamma consumption distribution and ENPG's empirical one, which is a finding to report rather than tune away.
- **Monitor:** realized against expected deaths.

### 5.4 Verification checks and tolerances

| # | Check | Tolerance |
|---|---|---|
| V1 | Baseline arm: Σ_{i∈(s,b,t)} h_ic = N · h̄_c for every cause and cell | relative error < 1e-10 |
| V2 | Σ_c h_c(k) = observed all-cause h(k) in reconstruction years; no negative residual | < 1e-10; 0 negative cells (else cap and report) |
| V3 | Weighted expected deaths against the cohort-consistent DEIS target (DEIS 15–65 − ½D15 + ½D66), by year × sex | < 0.5% (section 1.4 gives ±0.2% before population-size noise); by band < 2% |
| V4 | Realized against expected deaths, by year × sex and seed | |z| ≤ 3 |
| V5 | Null intervention (x' = x) with common random numbers | avoided deaths `identical()` to 0 |
| V6 | Denominator guard: R̄ and w̄ used in the scenario arm `identical()` to the baseline arm's | exact |
| V7 | Never drinkers have h_i1 = 0; −10% volume gives −10% AAF = 1 hazard among current drinkers (linear w) | exact |
| V8 | Volume cut gives avoided deaths ≥ 0 for causes with monotone RR; the sign for IHD, IS and DM follows the RR shape | sign |
| V9 | Population accounting with fixed flows: intervention-arm population − baseline = cumulative avoided deaths | exact (integer) |
| V10 | Simulated AAF against expand_pif AAF (validation, not calibration) | report |Δ|; flag > 0.05 absolute or outside the expand_pif 95% interval |
| V11 | Engine PIF (−10% volume) against the expand_pif PIF, by cause group | report; flag a relative gap > 25% |

`05_hazard_formula_selfcheck.R` implements V1, V2 (the AAF identity), V5, the frozen-denominator PIF identity, the re-normalization pitfall, V7 and the competing-risks and January-age conversions. It uses synthetic agents with a stand-in RR curve, and all assertions pass.

### 5.5 Minimum for the Monday deliverable (mortality side)

1. A table of h_c(k) for 2012–2024 × 2 sexes × ages 15–65 × 26 causes, from the GLM in section 2.3 plus the observed residual. Sources: `agg/deaths_year_sex_age_cause.csv` and `agg/ine_pop_2012_2025.csv`, which are already aggregated.
2. The hazard formula in 5.1 inside the engine loop, with V1–V7 as `stopifnot()`.
3. One intervention arm with frozen R̄ and fixed flows, reporting expected deaths and deaths avoided by cause group at 15–65.

**Pending: what this design does not establish**

- Epidemiological validity of the RR curves.
- Lag structure.
- Ages 66+.
- The INE vintage.
- Final 2024 causes of death.
