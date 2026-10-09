# Independent verification of `audit/rr_bridge.md`

Date: 2026-10-09. Verifier: a separate agent. No repository file was edited (`git status` is clean after the test re-runs).
Scripts, logs and aggregate CSVs are in `audit/verify_rr/`. Every script starts with `.t0` and reports elapsed minutes. All of them were run as `LANG=C.UTF-8 Rscript --vanilla`. Microdata were read only through `acc_data()` / `acc_deis()`, and only aggregates were written.

**Method.** I wrote my own code for each claim I tested and did not re-run the report's scripts:
- **Deaths:** counted directly from both packed DEIS 2024-2026 files.
- **ENPG:** status, g/day and HED were rebuilt by copying the microsim `ms-survey-inputs` logic, with the design weights the microsim actually uses.
- **AAF/PIF:** computed with a 150,001-point exact-integral grid instead of `aaf_point()` or the report's synthetic quantiles.

The RR records come from the repo registry through `bridge_load()`. I read it line by line, and the record mapping is validated because my integrator reproduces all 196 stored 2024 AAFs (see claim 1).

Labels: **[RUN]** = recomputed by me; **[READ]** = checked by reading the code.

## Numeric claims

| # | Claim (report) | Status | My number | Note |
|---|---|---|---|---|
| 1 | Person-level AAF matches saved expand_pif within 5.8e-4 (196 cells) | CONFIRMED | 5.83e-4, same worst cell (oral cavity F 60-65: stored 0.20106 vs exact 0.20164) [RUN, `v4_aaf_numerics.R`] | The residual is **quadrature error in the stored expand_pif value**: the 1500-point trapezoid grid struggles with gamma shape 0.18 in F 60-65. It is not person-level error, because my exact integral gives the same 0.20164. The tolerance for any engine-parity test must therefore be at least about 6e-4 even with infinite N. Synthetic population, not the engine. |
| 2 | Five registry tests pass; `test_aaf_compute.R` / `test_aaf_unified.R` fail on the missing `ihd_is_binge_aaf.R` | CONFIRMED (partly) | Registry tests (general, agebanded, cancer, hhd, injuries): exit 0, 0 `[FAIL]`. `test_aaf_compute.R` exit 1 [RUN] | The file is absent from the repo, as cited (`test_aaf_compute.R:24`, `test_aaf_unified.R:60`) [READ]. I did not re-run `test_pif3_primary_rr_sources.R`, `test_hed_exit_knobs.R` or the no-parity copy. |
| 4 | 23 causes, 65 registry rows; IHD WHO principal, IS Table 5 principal, C16/C25 out | CONFIRMED | Rows: 17 cancer + 2 HHD + 16 general + 24 IHD/IS + 6 injuries = 65 [RUN log] | Handoff: `codex_handoff_adam_rr_full_override_caveman.md:8364` (IHD WHO, IS T5), `:8381` (IS T5 principal), `:8323` (C16/C25 out). AAF=1 codes F10, G31.2, G62.1, G72.1, I42.6, K29.2, K86.0, Q86.0, X45, X65, Y15 all appear in `expand_pif.ipynb` cell `mort-trends-age-sex-chile11-mortalidad-etiqueta` [READ]. |
| 5a | `factor_CH` 2024 = 5.972; series 4.991 … 5.972 | CONFIRMED | Recomputed from ENPG microdata with the `enpg-consolidate` logic: 4.99103, 4.47958, 4.34733, 4.34854, 4.57030, 5.20005, 5.97168. Identical to `oms_factor_by_year.csv` in all 7 years [RUN, `v2_enpg.R`] | ENPG maximum age is 65 in every wave, so 15+ = 15-65. |
| 5b | Microsim `gpd_survey × factor_CH` reproduces the bundle gammas to about 1e-16 (2024) | CONFIRMED | Max relative difference 2.2e-16 (mean) and 4.4e-16 (shape). Same result with `exp` weights and with the microsim's design weights [RUN] | 2024 design weights equal `exp` exactly. **In 2014 they differ by up to 7.8%** (rounded `exp`), so the identity is year-specific. Check each year before reusing it. |
| 5c | [B] The microsim HED definition reproduces bundle `p_hed` (5.6e-17) | CORRECTED | Exact (5.6e-17) only on the subset of current drinkers with gpd > 0. The microsim **calibration target** `hed_mean` (`ms-survey-inputs` lines 124-143: all current drinkers with known HED, which includes 60 of the 5,528 current drinkers who have missing gpd) differs from bundle `p_hed` by up to **0.60 pp** (F 45-59: 0.4144 vs 0.4084) [RUN] | The engine assigns HED only when gpd > 0 (`ms-annual-engine` line 29), but it is calibrated to a slightly different denominator. Small, but it is not an identity. |
| 6 | Person-level PIF, volume −10%, vs pif2 within 1.4e-4 | CONFIRMED | 1.41e-4 over 196 cells, own integrator, RR evaluated at 0.9x (`aaf_unified.R:53-54`) [RUN] | I did not recompute the HED −10% figure (2.8e-6). |
| 7 | 2024, 15-65, 21 principal causes: 16,306 deaths; attributable 3,257.4; averted (vol −10%) 217.4 | CONFIRMED | Direct DEIS count: 16,306 deaths, attributable 3,257.4, averted 217.4. 152 of 164 cells have at least 1 death [RUN, `v1_deaths.R`] | Both packed DEIS files (29092026, 06102026) give identical 2024 cells. `ypll_pipeline_deaths()` (n = mort/aaf) equals my direct count to 2.3e-13 in 152/152 cells, with no cell dropped. Caveats: (i) the 2024 deaths come from the **weekly "FUENTE 2024-2026" file**, not a closed annual base; (ii) "person-level 3,258.0 / 217.5" is the synthetic population, **not microsim output**; (iii) 5 negative-AAF cells contribute −3.7. The AAF=1 block is excluded. |
| 8a | Both pipelines define former drinkers by 30 days | CONFIRMED | – | `expand_pif` `enpg-consolidate` lines 104-105 (`cvolaj == "fd"`); `ms-survey-inputs` lines 69-71 [READ]. `data_audit.csv` 2024 former_n = 6,963 [READ]. |
| 8b | 2,719 of 6,963 (42.1% weighted) of 2024 formers drank 31 d-12 m ago; 38.8-53.4% across waves | CONFIRMED | 2,719 / 6,963; 42.07% with `exp` and with design weights; range 38.80% (2022) to 53.41% (2016) [RUN] | By sex × tramo: 28.6% (M 60-65) to 50.5% (M 15-29) (`verify_rr/v2_former_share_2024.csv`). |
| 8c | Giving them RR(0.1 g/day): liver cancer M 0.341 → 0.248, IHD M 0.072 → 0.036 (a "lower bound") | CORRECTED (numbers confirmed, framing not) | 0.3414 → 0.2485 and 0.0718 → 0.0355; F liver 0.417 → 0.305; F IHD 0.188 → 0.124 [RUN] | (i) These are **unweighted means of the 4 tramo AAFs**, not population AAFs; do not quote them as "the" AAF. (ii) "Lower bound" holds only for monotone RR. For IHD (J-curve) RR(0.1) ≈ 0.98 is above the nadir (≈ 0.79), so it is not a bound there. |
| 9 | Someone who quits instantly takes RR_FD (cirrhosis 3.26), "so a quitting effect would raise risk" | CORRECTED | Share of 2024 current drinkers (exposure density) with RR(x) < RR_FD, for whom quitting raises RR: liver cancer 100%, DM2 98-100%, IHD F 91-97% / M 96-98%, colorectal M 96-98% / F 33-55%. Cirrhosis: F 47-65%, M 71-76%. Oral cavity 29-56%. HHD M 17-28% [RUN] | It depends on cause and dose. Brief intervention targets heavy drinkers, and for most of them RR(x) > RR_FD on cirrhosis, oral, oesophagus, larynx, ICH and HHD, so quitting would **lower** their risk. The recommendation (interventions move gpd/HED only, not status) still stands, but as a design choice to avoid the RR_FD discontinuity, not because quitting always raises risk. |
| 10 | A −4.5 pp HED bias lowers injury AAFs by 6.6-9.3% and IHD by 1.1-3.4% | CORRECTED | The arithmetic reproduces (injuries −6.6% to −9.3%, IHD −1.15% F / −3.47% M). The premise does not hold for 2024 [RUN] | −4.46 pp is the **unweighted mean of 56 cells over 7 waves**, pulled by 2018 (−11.0 pp) (`microsim_recalib_outputs/reconstruction_metrics.csv`). The 2024 errors (`reconstruction_comparison.csv`) average **−2.26 pp**: F −2.0/−5.4/−5.3/−2.7, M +1.4/−0.3/−4.3/+0.4. With the 2024 cell errors: male injuries −0.8% to −0.9%, female −7.3% to −7.9%, IHD M −0.5%, F −1.0%. In deaths (IHD+IS+injuries, 2024, base 1,436.4 attributable): **−27.6** with the 2024 errors vs **−84.1** with a uniform −4.5 pp, about 3× overstated. |
| 11 | Pooled vs NHED/HED mixture gap up to 0.030 AAF | CONFIRMED | 0.0296 (oral cavity F 60-65: 0.201 → 0.171); median 0.0020 over 124 cells [RUN, `v5_mixture.R`] | – |
| 12a | Clamping at 150 instead of truncating: up to 0.103; 62 of 164 principal cells > 0.01 | CONFIRMED | 0.1028 (TB M 45-59); 62/164; all 196 cells max 0.2054 (T5 IHD M, sensitivity) [RUN] | – |
| 12b | Forgetting the APC factor gives a median of 0.53× the AAF | CONFIRMED | 0.534 over 161 principal cells with \|AAF\| > 0.01; max \|diff\| 0.364 [RUN] | – |
| 13 | Comparison files and object paths | CONFIRMED (one caveat) | – | All files and slots exist as described [RUN/READ]. `aaf_table5_result_20261007.rds` has only `15_64` and `15_plus` scopes, with no `15_65`, so the 15-65 principal analysis reads the `15_64` slot. Band mapping and exposure are identical (`aaf_unified.R:1576-1594`), so this is numerically fine, but the label is inconsistent. Some `$outputs[[...]]$sex` fields are NA (`*_fem` outputs), so code must not rely on `$sex`. |
| 14 | In the C locale the `">1 año"` match fails and 4,244 of 6,963 formers become "unknown"; the same comparison sits in expand_pif and the microsim | CONFIRMED | `LANG=C`: 0 matches, even for the `"ñ"` escape that expand_pif and ms-survey-inputs use; `C.UTF-8`: 4,244 matches. 6,963 − 2,719 = 4,244 [RUN, `v3_locale.R`] | – |

## Code-location claims

| Claim | Status | Note |
|---|---|---|
| `aaf_unified.R:29-33` "muertes evitadas = muertes TOTALES × PIF" | CORRECTED | The quote is at line 36. Lines 29-33 define R_obs/PAF/PIF. |
| `aaf_unified.R:252-264` (`.aaf_risk`, `.aaf_pop_R`) | CONFIRMED (±4 lines) | Lines 256-268. |
| `aaf_unified.R:530-554` (`.aaf_core`) | CONFIRMED (±3 lines) | Lines 533-557. |
| `ypll_icd_defs.R:44-102` code lists, `:76-92` unintentional, `:298` `ypll_pipeline_deaths` | CONFIRMED | Unintentional components are at 79-94. |
| `aaf_table5_ihd_is_experiment.R:96-120` | CONFIRMED (approx.) | RR forms at 90-108, parameter table from 110. |
| `test_aaf_compute.R:24`, `test_aaf_unified.R:60`, `expand_pif_registro_2026-10-06.md:51` (B9) | CONFIRMED | – |
| `enpg-consolidate` formula and factor; `ms-survey-inputs` "no WHO multiplier"; `ms_age_group` = `findInterval(age, c(15,30,45,60))` | CONFIRMED | `ms-survey-inputs` line 82; `ms_age_group` is defined in the notebook source. |
| HED 5+/4+ in both pipelines | CONFIRMED | `enpg-consolidate` line 37; `ms-survey-inputs` line 85. |

## Do not use as written

1. **Claim 10.** The HED-bias impact assumes a uniform −4.5 pp. For 2024 the bias is about −2.3 pp and near zero for men, and the death impact is about 28, not 84, fewer attributable deaths.
2. **Claim 9.** "Quitting raises risk" is cause- and dose-specific. It is false for many heavy drinkers on cirrhosis, oral, oesophagus, larynx, ICH and HHD.
3. **Claim 8c.** The numbers are right, but they are unweighted tramo means, and the result is not a lower bound for IHD.
4. **Claim 5c.** The `p_hed` identity holds only on gpd > 0. The microsim calibration target differs by up to 0.6 pp.
5. **Claims 1, 6 and 7.** "Person-level" means a synthetic population built from the expand_pif gammas, not the engine. The 2024 DEIS deaths come from the provisional weekly file.

Not checked: the HED −10% PIF (2.8e-6), the `test_hed_exit_knobs.R` / pif3 test re-runs, and the RR value table in section (e) beyond the cells used above.
