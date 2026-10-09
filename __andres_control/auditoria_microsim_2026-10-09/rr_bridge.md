# RR bridge: person-level consumption in the microsim to cause-specific RR from the expand_pif machinery

Date: 2026-10-09. Scratch deliverable. No repository file was edited.
Scripts, logs and CSVs are in this folder (`audit/`). Paths below are repo-relative unless they point to `audit/`.

**Labels.** **[RUN]** means I verified it by running code. Real ENPG microdata were read only through `acc_data()`, and only aggregates were written. **[READ]** means I read it in code or documents and did not execute it.

## 0. What was run

| Item | Result |
|---|---|
| `test_rr_registry_general.R`, `_agebanded.R`, `_cancer.R`, `_hhd.R`, `_injuries.R` | PASS (5/5) [RUN] |
| `test_pif3_primary_rr_sources.R` | PASS. It uses synthetic data only [RUN] |
| `test_hed_exit_knobs.R` | PASS: 64 `[PASS]` lines, 0 failures [RUN] |
| `test_aaf_compute.R` | **FAIL**: `source("ihd_is_binge_aaf.R")` (line 24), and that file is not in the repo. This is known issue B9 (`__andres_control/expand_pif_registro_2026-10-06.md:51`). A scratch copy without the legacy `[PARITY]` block (`audit/test_aaf_compute_noparity.R`) passes 9/9 [RUN] |
| `test_aaf_unified.R` | **FAIL**: the same missing file (line 60) [RUN] |
| `audit/rr_bridge_eval.R` | RR at 0/10/20/40/60/100 g/day for all 65 registry entries (23 causes). Contract self-checks 6/6 PASS [RUN] |
| `audit/rr_bridge_consistency.R` | 2024: person-level AAF/PIF compared with the saved expand_pif/pif2 outputs in 196 cells, plus deaths from the DEIS death base [RUN] |
| `audit/rr_bridge_data_checks.R` | ENPG microdata checks: scale identity, HED identity, former-drinker composition [RUN] |
| `audit/rr_bridge_hed_sensitivity.R` | Effect of a -4.5 pp HED bias on AAF [RUN] |

How to run: `LANG=C.UTF-8 Rscript --vanilla audit/<script>.R`. Use R 4.3.3 (apt). No packages were missing (MASS, readxl, purrr, haven are present; `fitdistrplus` is absent but is not needed here). **Use a UTF-8 locale.** Under the container default (`C`), the literal `">1 año"` does not match the UTF-8 factor level of `oh2`, and 4,244 of the 6,963 former drinkers in 2024 silently become "unknown" [RUN]. The same comparison appears in `expand_pif.ipynb` `enpg-consolidate` and in microsim `ms-survey-inputs`. They are fine on Windows/UTF-8, and would break in a C locale [READ].

The microsim engine itself (`ms-annual-engine`) was **not** run or modified. Every check used a synthetic weighted population built from the saved expand_pif inputs. Section (c) shows that this population is the one the engine produces when its draws match ENPG.

---

## (a) The RR contract a person-level engine must call

```
rr_individual(pop, cause, spec, source = "principal", age_scope = "15_65", x_min = 0.1, x_max = 150) -> numeric RR_i
```
(prototype: `audit/rr_bridge_lib.R`; `spec <- bridge_load()` builds the registry the way the tests do: `source("rr_registry_adam.R"); source("aaf_unified.R")` + Table 5 records from `aaf_table5_ihd_is_experiment.R` with `AAF_TABLE5_AUTORUN=false`)

| Input column | Definition | Source in the engine |
|---|---|---|
| `sex` | `"female"` or `"male"` | `pop$sex` |
| `age_group` | expand_pif *tramo*: 1 = 15-29, 2 = 30-44, 3 = 45-59, 4 = 60-65 | `ms_age_group(age)`, same cut points (`findInterval(age, c(15,30,45,60))`) [READ] |
| `status` | `never` / `former` / `current`, on the 30-day definition | `pop$alc_status`. It maps 1:1 to expand_pif `cvolaj` = `ltabs` / `fd` / `cat1-4,cur_na` [READ] |
| `gpd_apc` | **g/day on the WHO/APC-anchored scale** = `gpd_survey * factor_CH[year]` | `pop$gpd_survey` × `__andres_control/oms_factor_by_year.csv$factor_CH` (see (c)) |
| `hed` | HED in the past 30 days (≥1 episode of 5+/4+ drinks), current drinkers only | `pop$hed` |

Rules, per cause and per person:
- `never`: RR = 1.
- `former`: RR = `exp(lnRRFormer)` (sex-specific; injuries = 1).
- `current`: x = clamp(`gpd_apc`, 0.1, 150).
  - Family `none` (cancers, HHD, the 8 general chronic causes): RR = `RRCurrent(x, betaCurrent)`. The HED flag is ignored.
  - Family `cap` (IHD, IS): RR = `RRCurrent(x)` if not HED; RR = `max(RRCurrent(x), 1)` if HED. Binge drinkers lose the J-curve protection.
  - Family `explicit` (the 3 injury causes): RR = `RRCurrent(x, betaCurrent)` if not HED; RR = `RRCurrent_binge(x, betaCurrent_binge)` if HED (beta1 shared, beta2 = binge term).
- IHD/IS record selection: Adam band = `aaf_age_band_mapping("15_65")$adam_age_band[age_group]`, that is, tramo 1 → 15-34 and tramos 2-4 → 35-64. Table 5 IS uses one record for every band.
- Output: RR_i. It is NA where the cause has no record for that sex (male breast cancer).

How the engine uses RR_i (proposal; the identity below is verified, the engine wiring is not built):
- Cause hazard: `h_ic = h0_c[year,sex,tramo] * RR_ic`, with `h0_c = D_c / Σ_i w_i RR_ic`.
  - D_c is the DEIS death count of the cell. Use `ypll_pipeline_deaths()` in `ypll_icd_defs.R`, which gives n = mort/aaf.
  - w_i is the person's INE weight.
- Other-cause hazard: (HMD/DEIS all-cause) − Σ_c D_c/N.
- Annual death probability: `q_i = 1 - exp(-(H_other + Σ_c h_ic))`.
- Intervention arm: keep `h0_c` and `factor_CH` fixed and recompute only RR_ic. Expected deaths averted = Σ_i w_i h0 (RR_ic − RR'_ic). In the static case this equals D_c × PIF_c, which matches expand_pif ("muertes evitadas = muertes TOTALES × PIF", `aaf_unified.R:29-33`).
- Uncertainty (not in the prototype): draw `beta ~ MASS::mvrnorm(betaCurrent, covBetaCurrent)` and `ln RR_FD ~ N(lnRRFormer, varLnRRFormer)` once per replicate. Use common random numbers across arms, as `.aaf_draw_rr()` does.

## (b) Cause list

ICD-10 codes are from `ypll_icd_defs.R:44-102` (Shield 2025 Table S6). DIAG1 is used for chronic causes; DIAG1 or DIAG2 for injuries. RR_FD is shown as F/M. "Principal" follows the canonical handoff (2026-10-06/07 entries: IHD WHO principal, IS Table 5 PUC principal, C16/C25 outside the principal set, AAF=1 outside the PIF, age 15-65, `yll_hmd`).

| Cause (expand_pif output) | ICD-10 | RR family / source object | HED component | RR_FD F/M | Age band | Principal |
|---|---|---|---|---|---|---|
| Oral Cavity and Pharynx Cancer (`locan_*`) | C00-C08 | WHO 2024 (Adam) `oralcancer_*`, `GENERAL_chronic_RR_2024_08_23.R` | none | 1.20/1.20 | none | yes |
| Other Pharyngeal Cancer (`opcan_*`) | C09-C10, C12-C14 | same RR as oral cavity (identical AAF by design) | none | 1.20/1.20 | none | yes |
| Oesophagus Cancer | C15 | `oesophaguscancer_*` | none | 1.16/1.16 | none | yes |
| Colon and rectum Cancer | C18-C21 | `colorectalcancer_*` | none | 1.05/2.19 | none | yes |
| Liver Cancer | C22 | `Livercancer_*` (RR_FD has no public table, per the handoff) | none | 2.68/2.23 | none | yes |
| Larynx Cancer | C32 | `Larynxcancer_*` | none | 1.18/1.18 | none | yes |
| Breast Cancer (F only) | C50 | `Breastcancer_female` | none | 1.00/– | none | yes |
| Stomach Cancer | C16 | `Stomachcancer_*` | none | 1.44/1.21 | none | **no** (handoff Q10; reported separately) |
| Pancreatic Cancer | C25 | `Pancreascancer_*` | none | 1.44/1.21 | none | **no** (Q10) |
| Hypertensive Heart Disease | I10-I15 | Liu 2020 `hypertension_*` (hypertension endpoint) | none | 1.00/1.05 | none | yes |
| Epilepsy | G40-G41 | `epilepsy*` | none | 1/1 | none | yes |
| DM2 | E10-E14 excl. .2 | `diabetes*` (protective in F) | none | 1.14/1.18 | none | yes |
| Tuberculosis | A15-A19, B90 | `tuberculosis*` (flat beyond 150 g) | none | 1/1 | none | yes |
| HIV | B20-B24 | `HIV*` (step at 49 F / 61 M g/day) | none | 1/1 | none | yes |
| Lower Respiratory Infection | J09-J22, P23, U04 | `lowerresp*` | none | 1/1 | none | yes |
| Liver Cirrhosis | K70, K74 | `livercirrhosis*` | none | 3.26/3.26 | none | yes |
| Acute Pancreatitis | K85-K86 excl. K86.0 | `pancreatitis*` | none | 2.20/2.20 | none | yes |
| Intracerebral Haemorrhage | I60-I62, I67.0-1, I69.0-2 | `hemorrhagicstroke*` | none | 1.36/1.36 | none | yes |
| Ischaemic Heart Disease | I20-I25 | WHO/InterMAHP `IHD*MORT_1..3` (`GENERAL_ihd_RR_2018_03_16.R`) | cap | 1.54/1.25 | 15-34 / 35-64 / 65+ (tramo 4 → 35-64) | yes (WHO). Table 5 = sensitivity |
| Ischaemic Stroke | G45, G46.0-8, I63, I65-I66, I67.2-8, I69.3-4 | **Table 5 PUC** `table5_is_*` (`aaf_table5_ihd_is_experiment.R:96-120`) | cap | 0.97/0.97 | none (same record in every band) | yes (Table 5). WHO `ischemicstroke*_1..3` = sensitivity (RR_FD 1) |
| Road Injuries | V01-V04, V06, V09-V80, V87, V89, V99 | `injuries_MVA` (Corrao 2014 + binge beta2) | explicit | 1/1 | none | yes |
| Unintentional Injuries (non-road) | falls W00-W19, drowning W65-W74, fire X00-X19, poisonings X40/X43/X46-X49 (X45 excluded, AAF = 1), mechanical forces, other V/W/X/Y (`ypll_icd_defs.R:76-92`) | `injuries_other_unit` | explicit | 1/1 | none | yes |
| Intentional Injuries | X60-X84 (excl. X65), Y87.0, X85-Y09, Y87.1 | `injuries_other_int` | explicit | 1/1 | none | yes |
| **AAF = 1 block** | F10, G31.2, G62.1, G72.1, I42.6, K29.2, K86.0, Q86.0, X45, X65, Y15 (`expand_pif.ipynb` `mort-trends-age-sex-chile11`) | no RR; attributable by definition | – | – | – | Outside the PIF (handoff: "PIF parcial, 23 causas con RR"). Engine for Monday: carry the DEIS counts as attributable and do not let them respond to the intervention. Later: hazard only among current/former drinkers. |

The registry has 65 rows: 23 causes × sex × (3 bands for IHD/IS) × (2 sources for IHD/IS) [RUN].

## (c) The WHO/APC correction, and how the microsim must reproduce it

**What expand_pif does** (`expand_pif.ipynb` cell `enpg-consolidate`) [READ, and checked in [A] below]:
1. Survey volume (12 g/drink, 30-day quantity-frequency including binge): `volCH = ((oh3 − db)+ × prom_tragos + db × 5|4) × 12 / 30 × 365` (g/year).
2. Per-capita volume over the whole 15-65 population, with never and former drinkers at 0 g: `pc_totalvolCH = p_current × weighted.mean(volCH | current)`. A current drinker with a missing volume counts as current at the drinker mean (V1 + B1).
3. `factor_CH[year] = APC_litres × 0.8 × 0.789 × 1000 / pc_totalvolCH`. APC is the WHO GHO total, 2024 = 2023 carried forward. The factor is exported to `__andres_control/oms_factor_by_year.csv`.
   - Values 2012-2024: 4.991, 4.480, 4.347, 4.349, 4.570, 5.200, 5.972.
   - It is one scalar per year, the same for every sex and age group, and it is applied **before** the HED split and the gamma fits: `volajohdia = volCH × factor_CH / 365`.
   - Using 15.7 g/drink gives the same `volajohdia` (B19: the drink size cancels).
4. Gamma fits (survey-weighted method of moments, `fit_gamma_weighted`) per year × sex × tramo, on `volajohdia > 0`.
   - Pooled fit for the no-HED causes: `g_*_list`.
   - NHED/HED split for IHD/IS and injuries: `g_*_hed_list`, with `p_hed` = weighted HED share among drinkers with volume > 0.
   - Integration over `x_vals = seq(0.1, 150, length.out = 1500)`. `.aaf_risk` renormalises the density on [0.1, 150], so mass above 150 g/day is redistributed proportionally, not capped.

**The microsim must do the same.** `ms-survey-inputs` computes `gpd_survey` with the same formula as `volCH/365`, explicitly "this survey scale has no WHO multiplier". So each person's input to RR is:

```
gpd_apc_i = gpd_survey_i × factor_CH[year]     # one fixed factor per calendar year, identical in all arms
```

- **[A] [RUN]**: weighted MoM gammas of `gpd_survey × factor_CH[2024]`, from the raw ENPG 2024 microdata (5,120 current drinkers with gpd > 0, 8 sex × tramo cells), reproduce `aaf_engine_inputs_bundle_20261007.rds`. Max relative difference: 4.4e-16 for shape, 3.3e-16 for rate, 2.2e-16 for the HED mean, 4.4e-16 for the NHED mean.
- **[B] [RUN]**: the microsim HED definition (episodes > 0 among current drinkers with gpd > 0) reproduces the bundle `p_hed` (max |diff| 5.6e-17).
- Projection years: hold the last factor, or an APC-projected one. **Never re-anchor the factor to the simulated consumption of an intervention arm**, because that would undo the intervention.

**The identity.** For a cell (year, sex, tramo) with weights w_i, summed over *all* people (never, former, current):

```
AAF_cell = Σ_i w_i (RR_i − 1) / Σ_i w_i RR_i          PIF_cell = 1 − Σ_i w_i RR'_i / Σ_i w_i RR_i
```

This is `.aaf_core`/`.aaf_pop_R` (`aaf_unified.R:252-264, 530-554`) with the integrals replaced by sums. It equals the expand_pif AAF when, in each cell:
1. the never/former/current shares are p_abs / p_form / 1 − p_abs − p_form;
2. current drinkers' `gpd_apc` follows the expand_pif gamma truncated to [0.1, 150] (pooled for no-HED causes; NHED/HED split with share p_hed for cap/explicit causes);
3. RR follows (a).

**Verification for 2024** (`audit/rr_bridge_consistency.R`, `audit/rr_bridge_consistency_2024.csv`) [RUN]. The weighted synthetic population has exact shares and 20,000 stratified gamma quantiles per drinker group, over 196 cells (49 cause × sex × source entries × 4 tramos; 164 principal):

| Check | Result |
|---|---|
| [1] `aaf_point()` on the saved inputs vs the saved expand_pif points | max \|diff\| 1.4e-17 (196 cells). The artefacts are mutually consistent. |
| [2] **person-level AAF vs saved expand_pif AAF** | **max \|diff\| 5.8e-4**. Worst cell: oral cavity F 60-65, 0.2011 vs 0.2016. Max relative 3.5%, in a cell with \|AAF\| = 0.0013. |
| [3] person-level PIF, volume −10%, vs `pif2_pif_results_full_20261008.rds` / `_table5_` | max \|diff\| 1.4e-4 (196 cells) |
| [4] person-level PIF, HED −10% (λ = 0, ρ = 1), vs pif2 | max \|diff\| 2.8e-6 (56 cells) |
| [8] chain test with the DEIS death base, 2024, 15-65, 21 principal causes | 16,306 deaths. Attributable: 3,257.4 (expand_pif) vs 3,258.0 (person-level). Averted, volume −10%: 217.4 (pif2) vs 217.5 (person-level). |

## (d) Definition mismatches to resolve

1. **Former drinker.** The premise "engine = 30 days vs expand_pif = >12 months" does **not** hold in the code.
   - Both pipelines use the 30-day definition, `oh2 ∈ {">30", ">1 año"}`: expand_pif `cvolaj == "fd"` (cell `enpg-consolidate`) and microsim `status == "former"` (`ms-survey-inputs`) [READ]. The microsim `data_audit.csv` former count for 2024 (6,963) equals my count [RUN].
   - The real mismatch is with the RR source. WHO/InterMAHP define current = drank in the past 12 months, and former = no drink in the past 12 months.
   - ENPG 2024: 2,719 of 6,963 formers (**42.1% weighted**) drank 31 days to 12 months ago. Across 2012-2024 the weighted share is 38.8-53.4% (`audit/rr_bridge_former_composition.csv`) [RUN]. These people receive RR_FD (cirrhosis 3.26, liver cancer 2.23/2.68).
   - Bound, 2024: if that group carried RR(0.1 g/day) instead, the mean AAF over the 4 tramos would change as follows (`audit/rr_bridge_former_definition_aaf_2024.csv`) [RUN]. This is a lower bound for the former term, because they drank something in the past year.

     | Cause | Sex | expand_pif AAF | With RR(0.1 g/day) |
     |---|---|---|---|
     | Liver cancer | M | 0.341 | 0.248 |
     | Liver cancer | F | 0.417 | 0.305 |
     | IHD | M | 0.072 | 0.036 |
     | IHD | F | 0.188 | 0.124 |
     | Colorectal cancer | M | 0.358 | 0.273 |
     | Cirrhosis | M | 0.697 | 0.662 |

   - Engine-specific risk: the microsim moves people between current and former every year through `z_current` (ρ = 0.8). A person who quits instantly jumps from RR(x) to RR_FD. An intervention must therefore change **gpd/hed only, never status**; this is what the expand_pif volume and HED scenarios do (`p_form × RR_FD` stays untouched). A participation or quitting effect needs an explicit rule, for example "intervention quitters take RR(0.1) for k years".
2. **HED.** The engine and expand_pif are identical ([B]). Against the RR source:
   - The item is 5+ drinks (men) / 4+ (women), which is 60/48 g at 12 g per drink, while the RR threshold is ≥60 g (see `__andres_control/p3kimi_investigacion_HED_faltantes_AAF_Chile.md`). Declare it; do not recode.
   - The joint (x, HED) distribution differs. expand_pif uses separate NHED and HED gammas. The microsim uses `P(HED | x) = plogis(a_cell + b·log1p(gpd))`. For cap/explicit causes the AAF depends on that joint distribution, so check it by cell with the [2]-type check, not only the HED prevalence.
   - Size of the current HED bias [RUN, `audit/rr_bridge_hed_bias_2024.csv`]: a −4.5 pp p_hed moves the 2024 injury AAFs by **−6.6% to −9.3% relative** and IHD by −1.1% (F) / −3.4% (M).
3. **Pooled vs split consumption inside expand_pif.**
   - No-HED causes use the pooled gamma; IHD/IS/injuries use the NHED/HED mixture. One microsim population cannot match both.
   - Using the mixture for the no-HED causes moves their AAF by up to **0.030** (oral cavity F 60-65: 0.201 → 0.171), median 0.002 over 124 cells [RUN, check 5].
   - Decide which one is the target. Suggestion: the mixture, which is closer to the data. Re-run expand_pif with the mixture only if parity matters more.
4. **Support above 150 g/day.**
   - expand_pif *truncates and renormalises*. Clamping x at 150 instead changes the principal AAF by up to **0.103** (TB M 45-59: 0.359 → 0.462). 62 of 164 principal cells change by more than 0.01, and 0.5-6.1% of the APC-scale gamma mass lies above 150 [RUN, check 6]. Table 5 IHD M rises from 0.166 to 0.372 (x³ term).
   - For parity, draw `gpd_apc` from the gamma truncated to [0.1, 150] (re-draw anything above 150). `rr_individual()` clamps only as a guard.
5. **Scale.** If the APC factor is forgotten (survey g/day used directly), AAF drops to a median of **0.53×** the correct value; max |diff| is 0.36 [RUN, check 7].
6. **x = 0.** Table 5 IHD (F) and IS (M) return NaN at x = 0 (0·log 0). The WHO forms use linear interpolation below 1 g. Clamping at 0.1 = grid start, which is what expand_pif does [RUN].
7. **Age band.** Banding is by tramo: ages 30-34 take the 35-64 band, and tramo 4 (60-65) takes 35-64. For the >65 extension, the registry already has the 65+ IHD/IS records (see (e), rows marked \*), but `aaf_age_band_mapping()` needs a 5th group. `15_plus` maps tramo 4 → 65+ and must not be used with single-year ages.
8. **Time.** RR applies in the same year (steady state, as in expand_pif). Lags (Holmes 2012) are a later microsim feature (handoff 2026-10-07).

## (e) RR values computed

Through `rr_individual()` for bands 15-34 and 35-64. Rows marked \* (65+) are the raw record, which is not reachable with `15_65`. x is APC-scale g/day; x = 0 is clamped to 0.1. Full table with variances and raw RR(0): `audit/rr_bridge_table.csv` [RUN].

| Cause | Sex | Band | Source | Princ. | HED | RR_FD | NHED 0 | NHED 10 | NHED 20 | NHED 40 | NHED 60 | NHED 100 | HED 0 | HED 10 | HED 20 | HED 40 | HED 60 | HED 100 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Oral Cavity and Pharynx Cancer | F | all | WHO/Adam | Y | none | 1.20 | 1.002 | 1.276 | 1.614 | 2.523 | 3.821 | 7.957 | - | - | - | - | - | - |
| Oral Cavity and Pharynx Cancer | M | all | WHO/Adam | Y | none | 1.20 | 1.002 | 1.276 | 1.614 | 2.523 | 3.821 | 7.957 | - | - | - | - | - | - |
| Other Pharyngeal Cancer | F | all | WHO/Adam | Y | none | 1.20 | 1.002 | 1.276 | 1.614 | 2.523 | 3.821 | 7.957 | - | - | - | - | - | - |
| Other Pharyngeal Cancer | M | all | WHO/Adam | Y | none | 1.20 | 1.002 | 1.276 | 1.614 | 2.523 | 3.821 | 7.957 | - | - | - | - | - | - |
| Oesophagus Cancer | F | all | WHO/Adam | Y | none | 1.16 | 1.001 | 1.141 | 1.302 | 1.691 | 2.189 | 3.594 | - | - | - | - | - | - |
| Oesophagus Cancer | M | all | WHO/Adam | Y | none | 1.16 | 1.001 | 1.141 | 1.302 | 1.691 | 2.189 | 3.594 | - | - | - | - | - | - |
| Colon and rectum Cancer | F | all | WHO/Adam | Y | none | 1.05 | 1.001 | 1.070 | 1.145 | 1.311 | 1.501 | 1.967 | - | - | - | - | - | - |
| Colon and rectum Cancer | M | all | WHO/Adam | Y | none | 2.19 | 1.001 | 1.070 | 1.145 | 1.311 | 1.501 | 1.967 | - | - | - | - | - | - |
| Liver Cancer | F | all | WHO/Adam | Y | none | 2.68 | 1.000 | 1.040 | 1.082 | 1.170 | 1.265 | 1.480 | - | - | - | - | - | - |
| Liver Cancer | M | all | WHO/Adam | Y | none | 2.23 | 1.000 | 1.040 | 1.082 | 1.170 | 1.265 | 1.480 | - | - | - | - | - | - |
| Larynx Cancer | F | all | WHO/Adam | Y | none | 1.18 | 1.001 | 1.155 | 1.329 | 1.738 | 2.237 | 3.532 | - | - | - | - | - | - |
| Larynx Cancer | M | all | WHO/Adam | Y | none | 1.18 | 1.001 | 1.155 | 1.329 | 1.738 | 2.237 | 3.532 | - | - | - | - | - | - |
| Breast Cancer | F | all | WHO/Adam | Y | none | 1.00 | 1.001 | 1.099 | 1.178 | 1.237 | 1.274 | 1.351 | - | - | - | - | - | - |
| Stomach Cancer | F | all | WHO/Adam | n | none | 1.44 | 1.000 | 0.998 | 1.002 | 1.032 | 1.092 | 1.326 | - | - | - | - | - | - |
| Stomach Cancer | M | all | WHO/Adam | n | none | 1.21 | 1.000 | 0.998 | 1.002 | 1.032 | 1.092 | 1.326 | - | - | - | - | - | - |
| Pancreatic Cancer | F | all | WHO/Adam | n | none | 1.44 | 1.000 | 1.021 | 1.043 | 1.087 | 1.134 | 1.232 | - | - | - | - | - | - |
| Pancreatic Cancer | M | all | WHO/Adam | n | none | 1.21 | 1.000 | 1.021 | 1.043 | 1.087 | 1.134 | 1.232 | - | - | - | - | - | - |
| Hypertensive Heart Disease | F | all | WHO/Adam | Y | none | 1.00 | 1.001 | 1.060 | 1.118 | 1.248 | 1.396 | 1.747 | - | - | - | - | - | - |
| Hypertensive Heart Disease | M | all | WHO/Adam | Y | none | 1.05 | 1.001 | 1.150 | 1.232 | 1.359 | 1.442 | 1.622 | - | - | - | - | - | - |
| Epilepsy | F | all | WHO/Adam | Y | none | 1.00 | 1.007 | 1.138 | 1.286 | 1.645 | 2.103 | 3.438 | - | - | - | - | - | - |
| Epilepsy | M | all | WHO/Adam | Y | none | 1.00 | 1.007 | 1.138 | 1.286 | 1.645 | 2.103 | 3.438 | - | - | - | - | - | - |
| DM2 | F | all | WHO/Adam | Y | none | 1.14 | 0.996 | 0.725 | 0.709 | 0.785 | 0.863 | 1.043 | - | - | - | - | - | - |
| DM2 | M | all | WHO/Adam | Y | none | 1.18 | 1.000 | 1.011 | 1.023 | 1.047 | 1.071 | 1.120 | - | - | - | - | - | - |
| Tuberculosis | F | all | WHO/Adam | Y | none | 1.00 | 1.002 | 1.197 | 1.432 | 2.052 | 2.939 | 6.031 | - | - | - | - | - | - |
| Tuberculosis | M | all | WHO/Adam | Y | none | 1.00 | 1.002 | 1.197 | 1.432 | 2.052 | 2.939 | 6.031 | - | - | - | - | - | - |
| HIV | F | all | WHO/Adam | Y | none | 1.00 | 1.000 | 1.000 | 1.000 | 1.000 | 1.540 | 1.540 | - | - | - | - | - | - |
| HIV | M | all | WHO/Adam | Y | none | 1.00 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | 1.540 | - | - | - | - | - | - |
| Lower Respiratory Infection | F | all | WHO/Adam | Y | none | 1.00 | 1.001 | 1.049 | 1.100 | 1.210 | 1.331 | 1.611 | - | - | - | - | - | - |
| Lower Respiratory Infection | M | all | WHO/Adam | Y | none | 1.00 | 1.001 | 1.049 | 1.100 | 1.210 | 1.331 | 1.611 | - | - | - | - | - | - |
| Liver Cirrhosis | F | all | WHO/Adam | Y | none | 3.26 | 1.042 | 2.821 | 4.308 | 7.855 | 12.461 | 25.914 | - | - | - | - | - | - |
| Liver Cirrhosis | M | all | WHO/Adam | Y | none | 3.26 | 1.003 | 1.329 | 1.757 | 3.071 | 5.370 | 16.416 | - | - | - | - | - | - |
| Acute Pancreatitis | F | all | WHO/Adam | Y | none | 2.20 | 0.997 | 0.773 | 0.716 | 1.148 | 2.186 | 7.927 | - | - | - | - | - | - |
| Acute Pancreatitis | M | all | WHO/Adam | Y | none | 2.20 | 1.002 | 1.189 | 1.415 | 2.001 | 2.831 | 5.666 | - | - | - | - | - | - |
| Intracerebral Haemorrhage | F | all | WHO/Adam | Y | none | 1.36 | 1.001 | 1.158 | 1.341 | 1.798 | 2.411 | 4.334 | - | - | - | - | - | - |
| Intracerebral Haemorrhage | M | all | WHO/Adam | Y | none | 1.36 | 1.001 | 1.071 | 1.148 | 1.318 | 1.513 | 1.994 | - | - | - | - | - | - |
| Ischaemic Heart Disease | F | 15-34 | WHO/Adam | Y | cap | 1.54 | 0.989 | 0.827 | 0.867 | 1.101 | 1.345 | 2.006 | 1.000 | 1.000 | 1.000 | 1.101 | 1.345 | 2.006 |
| Ischaemic Heart Disease | F | 15-34 | T5 PUC | n | cap | 1.54 | 0.991 | 0.830 | 0.844 | 1.071 | 1.585 | 4.567 | 1.000 | 1.000 | 1.000 | 1.071 | 1.585 | 4.567 |
| Ischaemic Stroke | F | 15-34 | WHO/Adam | n | cap | 1.00 | 0.979 | 0.630 | 0.662 | 0.905 | 1.393 | 3.887 | 1.000 | 1.000 | 1.000 | 1.000 | 1.393 | 3.887 |
| Ischaemic Stroke | F | 15-34 | T5 PUC | Y | cap | 0.97 | 0.928 | 0.659 | 0.689 | 0.913 | 1.348 | 3.401 | 1.000 | 1.000 | 1.000 | 1.000 | 1.348 | 3.401 |
| Ischaemic Heart Disease | F | 35-64 | WHO/Adam | Y | cap | 1.54 | 0.990 | 0.838 | 0.875 | 1.094 | 1.317 | 1.911 | 1.000 | 1.000 | 1.000 | 1.094 | 1.317 | 1.911 |
| Ischaemic Heart Disease | F | 35-64 | T5 PUC | n | cap | 1.54 | 0.991 | 0.830 | 0.844 | 1.071 | 1.585 | 4.567 | 1.000 | 1.000 | 1.000 | 1.071 | 1.585 | 4.567 |
| Ischaemic Stroke | F | 35-64 | WHO/Adam | n | cap | 1.00 | 0.980 | 0.650 | 0.681 | 0.911 | 1.362 | 3.542 | 1.000 | 1.000 | 1.000 | 1.000 | 1.362 | 3.542 |
| Ischaemic Stroke | F | 35-64 | T5 PUC | Y | cap | 0.97 | 0.928 | 0.659 | 0.689 | 0.913 | 1.348 | 3.401 | 1.000 | 1.000 | 1.000 | 1.000 | 1.348 | 3.401 |
| Ischaemic Heart Disease | F | 65+* | WHO/Adam | Y | cap | 1.54 | 0.993 | 0.879 | 0.907 | 1.068 | 1.223 | 1.605 | 1.000 | 1.000 | 1.000 | 1.068 | 1.223 | 1.605 |
| Ischaemic Heart Disease | F | 65+* | T5 PUC | n | cap | 1.54 | 0.991 | 0.830 | 0.844 | 1.071 | 1.585 | 4.567 | 1.000 | 1.000 | 1.000 | 1.071 | 1.585 | 4.567 |
| Ischaemic Stroke | F | 65+* | WHO/Adam | n | cap | 1.00 | 0.985 | 0.730 | 0.755 | 0.934 | 1.253 | 2.521 | 1.000 | 1.000 | 1.000 | 1.000 | 1.253 | 2.521 |
| Ischaemic Stroke | F | 65+* | T5 PUC | Y | cap | 0.97 | 0.928 | 0.659 | 0.689 | 0.913 | 1.348 | 3.401 | 1.000 | 1.000 | 1.000 | 1.000 | 1.348 | 3.401 |
| Ischaemic Heart Disease | M | 15-34 | WHO/Adam | Y | cap | 1.25 | 0.982 | 0.844 | 0.796 | 0.793 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 |
| Ischaemic Heart Disease | M | 15-34 | T5 PUC | n | cap | 1.25 | 0.985 | 0.865 | 0.820 | 0.796 | 0.867 | 1.711 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | 1.711 |
| Ischaemic Stroke | M | 15-34 | WHO/Adam | n | cap | 1.00 | 0.986 | 0.842 | 0.896 | 1.034 | 1.193 | 1.565 | 1.000 | 1.000 | 1.000 | 1.034 | 1.193 | 1.565 |
| Ischaemic Stroke | M | 15-34 | T5 PUC | Y | cap | 0.97 | 0.929 | 0.852 | 0.901 | 1.027 | 1.170 | 1.499 | 1.000 | 1.000 | 1.000 | 1.027 | 1.170 | 1.499 |
| Ischaemic Heart Disease | M | 35-64 | WHO/Adam | Y | cap | 1.25 | 0.983 | 0.854 | 0.808 | 0.806 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 |
| Ischaemic Heart Disease | M | 35-64 | T5 PUC | n | cap | 1.25 | 0.985 | 0.865 | 0.820 | 0.796 | 0.867 | 1.711 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | 1.711 |
| Ischaemic Stroke | M | 35-64 | WHO/Adam | n | cap | 1.00 | 0.987 | 0.852 | 0.903 | 1.032 | 1.179 | 1.518 | 1.000 | 1.000 | 1.000 | 1.032 | 1.179 | 1.518 |
| Ischaemic Stroke | M | 35-64 | T5 PUC | Y | cap | 0.97 | 0.929 | 0.852 | 0.901 | 1.027 | 1.170 | 1.499 | 1.000 | 1.000 | 1.000 | 1.027 | 1.170 | 1.499 |
| Ischaemic Heart Disease | M | 65+* | WHO/Adam | Y | cap | 1.25 | 0.988 | 0.891 | 0.856 | 0.854 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 |
| Ischaemic Heart Disease | M | 65+* | T5 PUC | n | cap | 1.25 | 0.985 | 0.865 | 0.820 | 0.796 | 0.867 | 1.711 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | 1.711 |
| Ischaemic Stroke | M | 65+* | WHO/Adam | n | cap | 1.00 | 0.990 | 0.889 | 0.928 | 1.023 | 1.128 | 1.357 | 1.000 | 1.000 | 1.000 | 1.023 | 1.128 | 1.357 |
| Ischaemic Stroke | M | 65+* | T5 PUC | Y | cap | 0.97 | 0.929 | 0.852 | 0.901 | 1.027 | 1.170 | 1.499 | 1.000 | 1.000 | 1.000 | 1.027 | 1.170 | 1.499 |
| Road Injuries | F | all | WHO/Adam | Y | explicit | 1.00 | 1.003 | 1.030 | 1.062 | 1.127 | 1.197 | 1.349 | 2.618 | 2.689 | 2.771 | 2.942 | 3.124 | 3.522 |
| Road Injuries | M | all | WHO/Adam | Y | explicit | 1.00 | 1.003 | 1.030 | 1.062 | 1.127 | 1.197 | 1.349 | 2.618 | 2.689 | 2.771 | 2.942 | 3.124 | 3.522 |
| Unintentional Injuries | F | all | WHO/Adam | Y | explicit | 1.00 | 1.002 | 1.020 | 1.041 | 1.083 | 1.127 | 1.221 | 2.024 | 2.061 | 2.102 | 2.188 | 2.277 | 2.467 |
| Unintentional Injuries | M | all | WHO/Adam | Y | explicit | 1.00 | 1.002 | 1.020 | 1.041 | 1.083 | 1.127 | 1.221 | 2.024 | 2.061 | 2.102 | 2.188 | 2.277 | 2.467 |
| Intentional Injuries | F | all | WHO/Adam | Y | explicit | 1.00 | 1.002 | 1.020 | 1.041 | 1.083 | 1.127 | 1.221 | 1.764 | 1.796 | 1.832 | 1.906 | 1.984 | 2.149 |
| Intentional Injuries | M | all | WHO/Adam | Y | explicit | 1.00 | 1.002 | 1.020 | 1.041 | 1.083 | 1.127 | 1.221 | 1.764 | 1.796 | 1.832 | 1.906 | 1.984 | 2.149 |

How to read it:
- WHO IHD M has NHED RR = 1.000 at ≥60 g/day (step from 0.957 just below 60; see the handoff).
- The injury HED RR at very low x is already `exp(b1 + b2)` = 1.76-2.62.
- DM2 F and Acute Pancreatitis F are protective at low doses.
- Table 5 IHD M rises from 0.867 at 60 g/day to 1.711 at 100 g/day.

## (f) Minimal R sketch

### Contract (full version: `audit/rr_bridge_lib.R`)

```r
rr_individual <- function(pop, cause, spec, source = "principal", age_scope = "15_65", x_min = 0.1, x_max = 150) {
  ent <- spec[spec$cause == cause & (if (source == "principal") spec$principal else spec$rr_source == source), ]
  band <- aaf_age_band_mapping(age_scope)$adam_age_band[pop$age_group]
  rr <- rep(NA_real_, nrow(pop))
  for (k in seq_len(nrow(ent))) {
    rec <- ent$record[[k]]
    sel <- pop$sex == ent$sex[k] & (is.na(ent$band[k]) | band == ent$band[k])
    rr[sel & pop$status == "never"]  <- 1
    rr[sel & pop$status == "former"] <- exp(rec$lnRRFormer)
    cu <- which(sel & pop$status == "current"); if (!length(cu)) next
    x <- pmin(pmax(pop$gpd_apc[cu], x_min), x_max); h <- pop$hed[cu] %in% TRUE
    r <- rep_len(rec$RRCurrent(x, rec$betaCurrent), length(x))
    if (ent$hed_mode[k] == "cap")      r[h] <- pmax(r[h], 1)
    if (ent$hed_mode[k] == "explicit") r[h] <- rec$RRCurrent_binge(x[h], rec$betaCurrent_binge)
    rr[cu] <- r
  }
  rr
}
aaf_from_people <- function(rr, w) { ok <- !is.na(rr); sum(w[ok] * (rr[ok] - 1)) / sum(w[ok] * rr[ok]) }
```

### Consistency check: microsim AAF vs expand_pif AAF for one year

Run this inside the engine, after `ms_exposure()` for year Y. `pop$w` = INE stock / N_sim per sex × age.

```r
fac  <- read.csv("__andres_control/oms_factor_by_year.csv")
pop$gpd_apc   <- pop$gpd_survey * fac$factor_CH[fac$year == Y]   # same factor in every arm
pop$status    <- pop$alc_status                                  # never / former / current
pop$age_group <- ms_age_group(pop$age)
aafs <- readRDS("__andres_control/aaf_nested_by_disease_20261007.rds")$by_disease
t5   <- readRDS("__andres_control/aaf_table5_result_20261007.rds")$by_age_scope[["15_64"]]$standard_tables
cmp <- do.call(rbind, lapply(unique(spec$cause[spec$principal]), function(cs) {
  e <- unique(spec[spec$cause == cs & spec$principal, c("sex", "output", "rr_source")])
  do.call(rbind, lapply(seq_len(nrow(e)), function(j) do.call(rbind, lapply(1:4, function(g) {
    p <- pop[pop$sex == e$sex[j] & pop$age_group == g, ]
    ref <- if (e$rr_source[j] == "table5_puc") { tb <- t5[[e$sex[j]]]; tb[tb$disease == cs & tb$Year == Y, paste0("AAF_ag", g)] } else {
      tb <- aafs[[cs]]$outputs[[e$output[j]]]$table; tb[tb$Year == Y, paste0(if (e$sex[j] == "female") "Fem" else "Male", g, "_point")] }
    data.frame(cause = cs, sex = e$sex[j], age_group = g, aaf_micro = aaf_from_people(rr_individual(p, cs, spec), p$w), aaf_expand_pif = ref)
  }))))
}))
stopifnot(max(abs(cmp$aaf_micro - cmp$aaf_expand_pif)) < tol)   # tol: MC error of N_sim; 5.8e-4 reached with exact inputs
```

[RUN] `audit/test_sketch.R` runs this block verbatim on a random 2024 population: 40,000 people per sex × tramo, NHED/HED mixture draws, truncated to [0.1, 150]. Over 164 principal cells, max |diff| = 0.031 and median = 0.0017. The maximum is the pooled-vs-mixture gap in (d)3 plus Monte Carlo error.

The tolerance has to cover two things: Monte Carlo error at N = 25,000, and the **deliberate** gaps listed in (d)3 (pooled vs mixture, up to 0.03) and (d)4 (truncation). Report the per-cell difference against the [2] baseline rather than relying on one threshold.

### Saved artefacts to compare against

All are tracked, plain RDS/XLSX/CSV with aggregates only.

| What | Path | Where in the object |
|---|---|---|
| expand_pif AAF (WHO/Adam, incl. IHD principal and IS sensitivity) | `__andres_control/aaf_nested_by_disease_20261007.rds` | `$by_disease[[cause]]$outputs[[output_name]]$table`, columns `<Fem\|Male><g>_point/_lower/_upper` by `Year` (7 waves) |
| AAF inputs, the exposure "truth" for parity | `__andres_control/aaf_engine_inputs_bundle_20261007.rds` | `$exposure_inputs`: `g_*_list`, `g_*_hed_list`, `p_abs/p_form` (`[["year"]][["edad_tramo_g"]]`), `p_hed` (`[[g]][year_index]`), `x_vals` |
| IS principal (Table 5 PUC) AAF | `__andres_control/aaf_table5_result_20261007.rds` | `$by_age_scope[["15_64"]]$standard_tables$<female\|male>`, `AAF_ag<g>` |
| PIF (scenarios incl. `volume_reduction_10`, `hed_reduction_10`) | `__andres_control/pif2_pif_results_full_20261008.rds`, `pif2_pif_results_table5_full_20261008.rds` | `pif` by `output_name`, `year`, `age_group`, `scenario_id` |
| APC factor | `__andres_control/oms_factor_by_year.csv` | `factor_CH` |
| DEIS death base (h0 calibration) | `__andres_control/Mortality Estimates WHO 2024_20261007.xlsx` + the nested AAF via `ypll_pipeline_deaths()` (`ypll_icd_defs.R:298`) | n = mort / aaf |

## Not done, and risks

- The prototype is not wired into `ms-annual-engine`. The engine's own simulated population was not compared; that is the next step, using the check above.
- Monte Carlo uncertainty for RR and RR_FD is not propagated in the contract (central betas only).
- The AAF = 1 causes have no person-level mechanism yet.
- `test_aaf_compute.R` and `test_aaf_unified.R` fail on a fresh checkout until `ihd_is_binge_aaf.R` is restored or the dependency is removed (B9).
- Run R with a UTF-8 locale, or the former-drinker count is wrong.
