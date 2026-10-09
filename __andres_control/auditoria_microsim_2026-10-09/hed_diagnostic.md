# HED underestimation in the person-level engine: real-data audit

2026-10-09 | cc-cloud | Claude (subagent). Engine: `__andres_control/microsim_recalib_ACC_2012_2024.ipynb`, 7-wave `interp_hold` reconstruction 2012–2024. Nothing in the repo was edited. Scripts and aggregated outputs are in this folder (all files prefixed `hed_`).

## Verdict

The −4.5 pp HED bias comes from **hypothesis (a), assignment by volume**. The HED glm is fitted on *observed* g/day, but the engine applies it to *its own* g/day law, a zero mass plus a Gamma with shape 0.38–0.61. That law has the right mean and the wrong shape. This term alone is **−4.38 of −4.50 pp**.

- **(b) indicator/target:** coding is correct (raw item = `db` in 100% of cases). The target choice (complete-case) moves the HED *level* 2.2–5.9 pp above SENDA's official series, but it is not an engine error. Its only effect on the engine is the NA-g/day coverage term, **−0.12 pp**.
- **(c) individual dynamics:** contributes **0.00 pp**. The copula keeps the HED margin invariant to rho, both by proof and by simulation.
- **Wave effects:** the glm has no time term. It cancels on average (0.00 pp) but costs **−4.9 pp in 2018**, a real spike that SENDA's series also shows.

The smallest fix re-solves the HED intercepts by cell × wave against the engine's own g/day law (uniroot). It brings the bias from −4.50 to +0.06 pp, RMSE from 6.39 to 0.65 pp, and coverage from 30/48 to 48/48.

Volume coherence needs one more line in the engine: HED by volume rank, through a decile lookup plus offsets. The HED-by-volume-quintile RMSE then falls from 13.9 to 0.4 pp. Both results are **in-sample calibration, not validation**. On held-out waves (fit ≤ 2020, test 2022/2024), every variant is at about 5 pp RMSE.

## What was run vs inferred

| Item | Status |
|---|---|
| Cells `ms-setup`, `ms-survey-inputs`, `ms-demography-inputs`, `ms-calibration-functions`, `ms-annual-engine` extracted verbatim (`hed_cells/`) and executed with `Rscript --vanilla` on decrypted ENPG/DEIS/INE/HMD (`hed_00_load_engine.R`) | **Run.** Adaptations: no arrow (DEIS parquet read by `python3 -I` into R `tempdir()`), `ms_table()` prints nothing, UTF-8 locale |
| `ms_fit(2024, "interp_hold")` HED coefficients equal the stored `microsim_recalib_outputs/model_parameters.csv` (`reconstruction2024_interp_hold`) | **Run**: identical to 1e-14 |
| Re-run of the reconstruction, 5 seeds × rho 0/0.8/0.95 | **Run.** rho 0.8 bias −4.497 pp, coverage 30/48. Stored: −4.464 pp, 31/48. Per-cell max diff 2.1 pp, mean −0.03 pp (MC sd per cell ≈ 1.3 pp). The stream likely diverges because the DEIS 2024 vintage (`06102026`) changes the mortality multiplier (inferred) |
| Decomposition, fixes, holdout, persistence grid | **Run** (see scripts) |
| SENDA series 52.1/43.7/51.1/56.3/50.2/50.7/47.2 | **Read** from `__andres_control/p3kimi_investigacion_HED_faltantes_AAF_Chile.md:92,107`; not re-verified against SENDA |
| Questionnaire wording by wave | **Read** from `_enpg/notes/enpg_questionnaire_pages.csv`, `_enpg/notes/enpg_findings.md` §3, §5 and `__andres_control/eps_alcohol_outputs/enpg_wave_crosswalk.csv` |

## 1. How HED is defined, by wave

**In the code (all waves):** `hed = episodes > 0`. Here `episodes` = `ENPG_BINGE$db`; values ≥ 88, < 0 or non-finite become NA. Non-current drinkers get 0 and unknown status gets NA (`ms-survey-inputs` lines 79, 86). The target is `svymean(~hed, na.rm = TRUE)` among current drinkers (past-30-day users) per sex × age group (`ms-survey-inputs` lines 125–128), i.e. **complete-case HED among current drinkers**.

**Raw item vs `db`** (`hed_04_definition.R` → `hed_def_raw_vs_db.csv`): `db` agrees with the raw questionnaire item for 100% of current drinkers with HED observed. The NA pattern is identical in every wave.

| Wave | Raw item | Current 15–65 (n) | HED observed (n) | Codes treated as missing | Wording/instrument notes |
|---|---|---:|---:|---|---|
| 2012 | `p16` | 6,893 | 6,629 | 257 (88/99) + 7 counts of 500–10,000 | 5+ men / 4+ women, past 30 d, ~2-h occasion; no holiday exclusion |
| 2014 | `oh7` | 8,904 | 8,147 | 755 | same wording; **12.8% weighted HED-unknown** (highest) |
| 2016 | `oh_7a`/`oh_7b` | 7,304 | 6,840 | 463 | adds "No considere Fiestas Patrias" (unconditional); drink cards with mL |
| 2018 | `OH_7H`/`OH_7M` | 7,484 | 6,931 | 549 (888/999) + 4 (88/99) | Fiestas Patrias excluded; 888/999 vs 88/99 code ambiguity |
| 2020 | `OH_7` | 6,512 | 5,985 | 527 | New Year excluded if interviewed Jan 2021; pandemic fieldwork; **female card repeats male volumes** (1,600/700/200 mL) |
| 2022 | `OH_7` | 5,999 | 5,649 | 350 | New Year conditional; same female-card issue |
| 2024 | `OH_7` | 5,528 | 5,180 | 348 | Fiestas Patrias (17/09–21/10) and New Year conditional; same female-card issue |

**Definition breaks to flag:**

1. Holiday-exclusion rules change in 2016, 2020 and 2024.
2. From 2020, the female 4-drink card shows male volumes, which raises the effective threshold for women.
3. The 2018 missing codes differ.
4. The 7 extreme 2012 counts are coded NA, though they are almost surely HED-positive (7 cases; negligible).

None of these explains the 2018 spike, which has the same wording as 2016. Its cause is not identifiable from the files in hand.

**Design-weighted HED among current drinkers, 15–65** (`hed_def_pooled_vs_senda.csv`, `hed_def_senda_denominator.csv`):

| Wave | Complete-case (model target) | Unknown counted as "no" | SENDA published (12–65) | HED unknown, weighted |
|---|---:|---:|---:|---:|
| 2012 | 54.7 | 51.8 | 52.1 | 5.3% |
| 2014 | 49.7 | 43.2 | 43.7 | 12.8% |
| 2016 | 53.4 | 50.8 | 51.1 | 4.7% |
| 2018 | 59.7 | 55.9 | 56.3 | 6.6% |
| 2020 | 53.0 | 50.0 | 50.2 | 5.6% |
| 2022 | 53.2 | 50.5 | 50.7 | 5.0% |
| 2024 | 49.3 | 46.6 | 47.2 | 5.6% |

The two middle columns use all ages in the file, 12–65. The model target uses 15–65; the difference is ≤ 0.1 pp.

SENDA's series is reproduced within −0.2 to −0.6 pp when unknown HED is counted as "no" in the past-month-user denominator. The model's complete-case target sits **2.2–5.9 pp higher** than the official series. It assumes HED missing at random among current drinkers. This is a definitional choice that matters when results are compared with official SENDA figures; it does not cause the engine bias.

Cell targets (%, wave columns, from `hed_def_cell_targets.csv`): male 15–29 falls from 71.3 (2012) to 50.1 (2024). Female 60–65 ranges from 21.0 to 47.7. Six of the 8 cells peak in 2018; the exceptions are men 15–29, who peak in 2012, and men 60–65, who peak in 2022.

## 2. Coverage: drinkers the HED model never sees

The glm sample is current drinkers with finite g/day > 0 and HED observed: 44,868 of the 45,361 current drinkers who have HED observed (all waves, 15–65). The other 481 have HED observed but g/day NA. For 448 of them, drinking days (`oh3`) are missing; for 33, the usual-quantity item (`audit2`) is missing.

Their HED rate is high (34–73% by wave), but they are only 0.88% of the weighted denominator. They hold 1.13% of weighted HED cases (max 4.55% in one cell). Zero-g/day current drinkers (12, all in 2014) are HED = 0 by construction. In ENPG g/day is built *from* the HED count, so any HED episode forces g/day ≥ 2.0 (men) / 1.6 (women). Verified: 0 HED cases below that floor.

**Implied bias (A − T): −0.12 pp on average** (range −0.75 to +0.43 pp by cell; −0.32 pp in 2018).

The engine does not "exclude" these people: every simulated drinker receives a g/day draw. The loss is only that the glm is trained on a subset whose HED rate differs slightly from the target denominator.

## 3. Target vs simulator denominator

- **Target:** design-weighted mean of `hed` over current drinkers with HED observed. Verified: equal to the weighted mean to 1e-10.
- **Simulator:** `mean(hed[current])` over all simulated current drinkers at 1 January, before deaths (`ms-annual-engine` line 73). Zero-g/day drinkers are forced to HED = 0 (`positive &`, line 29).

**Conceptually consistent, under MAR for unknown HED.** The only numerical mismatch is the coverage term above (−0.12 pp). The simulator has no within-cell age gradient for HED: intercepts are by cell and g/day has one mean per cell. That is not a bias source for cell-level metrics.

## 4. Model misspecification: exact decomposition

Each of the 56 cells is decomposed exactly as `S − T = (A − T) + (B − A) + (C − B) + (S − C)` (`hed_05_decomposition.R` → `hed_decomposition_cells.csv`):

- **T**: the target.
- **A**: observed HED in the glm sample.
- **B**: the glm prediction averaged over *observed* g/day of that wave.
- **C**: the glm prediction integrated over the *engine's* g/day law for that cell and year, `(1 − p0) ∫ plogis(a + b log1p(g)) dGamma(g; shape, mu)`.
- **S**: simulated, 5 seeds, rho = 0.8.

| Cause | Term | pp (mean of 56 cells) | Notes |
|---|---|---:|---|
| Coverage / denominator (b) | A − T | −0.12 | NA g/day drinkers |
| No time term in the HED glm | B − A | 0.00 | 2018: −4.93; 2016: +1.74; 2024: +1.35; range −11.6 to +6.4 by cell |
| **Engine g/day law ≠ observed g/day (a)** | C − B | **−4.38** | negative in 53/56 cells; \|term\| > 2 SE in 12 cells |
| Dynamics, MC, age mix (c) | S − C | 0.00 | range −1.1 to +2.1 (MC) |
| **Total** | S − T | **−4.50** | stored run: −4.46 |

**By sex:** the distribution term is −3.23 pp for women and −5.53 pp for men. It is worst for men 45–59 (−7.94).

**By year (total):** 2012 −3.64, 2014 −2.40, 2016 −3.56, **2018 −10.87** (distribution −5.74, time −4.93), 2020 −3.86, 2022 −4.74, 2024 −2.41.

**In-sample calibration of the glm:** pooled over waves it is exact by construction (cell intercepts, weighted score equations). By wave, B − A is the time residual above.

**Why the g/day law matters:** the fitted Gamma has the same mean as observed but a much heavier spike near zero. Mean log1p(g/day) in the engine is 0.08–0.22 lower than observed with the same mean g/day, for example 0.92 vs 1.07 for women 45–59. With slope 2.30 per log1p unit, that lowers the logit by about 0.2–0.5. HED rates by g/day bin, mean over ages and waves (`hed_volume_bins.csv`):

| Sex | g/day bin | Share obs | Share engine | HED rate obs | HED rate engine |
|---|---|---:|---:|---:|---:|
| Women | [0,1) | 0.33 | 0.44 | 0.00 | 0.09 |
| Women | [1,2) | 0.21 | 0.13 | 0.42 | 0.30 |
| Women | [2,5) | 0.25 | 0.20 | 0.73 | 0.59 |
| Women | [10,20) | 0.06 | 0.07 | 0.72 | 0.96 |
| Men | [0,1) | 0.16 | 0.29 | 0.00 | 0.07 |
| Men | [2,5) | 0.29 | 0.20 | 0.69 | 0.49 |
| Men | [20,40) | 0.04 | 0.07 | 0.93 | 0.98 |

The engine misallocates drinkers twice: too many sit below 1 g/day, where ENPG HED is structurally 0, and too few sit at 1–5 g/day. Its HED-volume gradient is also much steeper than observed. Observed HED plateaus at about 0.72–0.93 above 5 g/day; the engine goes to about 0.96–1.00.

The ENPG indicator construction feeds this (b → a coupling). g/day contains the HED episodes, which creates a floor and a lumpy distribution. A smooth logit-log1p curve on a Gamma cannot reproduce both.

**Side finding for item 3 (RR):** the same Gamma also misplaces exposure. For men, 7.3% of drinkers are at 20–40 g/day in the engine vs 4.3% observed. Volume RR are nonlinear, so check the g/day distribution, not only its mean, before the RR integration.

## 5. Dynamics: persistence cannot move the cross-sectional HED margin

**Analytic.** All three latents start as iid N(0,1) (`ms-annual-engine` line 9). They are updated as `z' = rho z + sqrt(1 − rho²) e` with independent innovations (lines 125–126). Each stays N(0,1), and the cross-covariances stay `rho² · 0 = 0`.

Exits do not depend on z: deaths depend on sex and age only (line 87), age-exit on age, and residual outflow is a random sample within sex × age (line 111). Entrants are fresh N(0,1). So for every survivor, given (sex, age, year), (z_current, z_amount, z_hed) are iid N(0,1). That gives

`E[HED | current, cell, year] = (1 − p0) · E_U[p_hed(g(U))]`,

which does not depend on rho. This is the C term.

**Simulation, 5 seeds, all 56 cells:** bias −4.44 (rho 0), −4.50 (rho 0.8), −4.45 (rho 0.95). The S − C term averages 0.00 pp. Fixed 2024 cohort, 6 annual updates (`hed_persistence_grid.csv`): the HED margin is 0.473–0.474 for every rho_hed in {0, 0.5, 0.8, 0.95, 1}.

**Where dynamics will start to matter (inferred, not run).** Once deaths depend on HED/volume through RR, mortality selects on z, and rho then shifts the survivors' margin. The size should be small: annual 15–65 death risk is about 0.2–0.3%, from 395,106 simulated deaths over 13 years in `persistence_sensitivity.csv` and an INE stock of about 12–13 M. Check it after integration. Persistence also governs intervention-effect decay and individual HED histories.

## 6. Fixes and before/after

All variants re-run with the full 7-wave reconstruction: 5 seeds (2125–2129), rho 0.8, n = 25,000, common random numbers (`hed_06_fix.R`, `hed_00b_hooks.R` → `hed_fix_metrics.csv`, `hed_fix_cells.csv`). Current-drinking and g/day errors are unchanged in every variant (max |err| 0.015 and 0.31 g/day); the fix touches only HED.

The engine change is one substituted line, `p_hed <- hed_prob(d, u, gpd)`, plus a hook in `ms_drivers`.

| Variant | What changes | Bias (pp) | RMSE (pp) | MAE (pp) | Coverage (non-2020) | 2018 bias (pp) | Quintile-curve RMSE (pp) | 5-seed run (min) |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| base (notebook) | — | **−4.50** | 6.39 | 5.06 | 30/48 (62.5%) | −10.87 | 13.90 | 0.18 |
| A_cell | cell intercepts re-solved on the engine g/day law, no time | +0.07 | 4.21 | 3.16 | 41/48 | −6.49 | 11.11 | 0.18 |
| **B_wave** (smallest) | cell × wave intercepts re-solved (uniroot), interpolated between waves | +0.06 | 0.65 | 0.49 | 48/48 | +0.15 | 10.98 | 0.19 |
| C_rank | logit-rank link, no time | +0.17 | 5.22 | 4.07 | 36/48 | −6.49 | 8.72 | 0.18 |
| D_rank_wave | C + cell × wave offsets | +0.09 | 0.70 | 0.56 | 48/48 | +0.16 | 8.77 | 0.18 |
| **E_bins_wave** (recommended) | observed HED by volume-rank decile per cell (pooled waves) + cell × wave logit offsets | −0.06 | 0.59 | 0.47 | 48/48 | −0.06 | **0.42** | 0.18 |

The stored notebook output for base is −4.46 pp, coverage 31/48 (64.6%). The quintile curve is HED by within-cell volume-rank quintile, observed vs engine, mean over 4 ages × 7 waves (`hed_fix_volume_quintiles.csv`). For example, men in quintile 2: observed 0.46, base 0.18, B 0.26, E 0.46.

**Held-out check** (`hed_07_holdout_persistence.R` → `hed_holdout_2022_2024.csv`). Fit on waves ≤ 2020; drivers and offsets held at 2020 (interp_hold rule); 16 cells in 2022/2024; analytic engine expectation.

| Variant | Bias (pp) | RMSE (pp) | Coverage |
|---|---:|---:|---:|
| base | −2.22 | 4.99 | 12/16 |
| A_cell | +2.33 | 5.39 | 13/16 |
| B / D / E (wave offsets held) | +1.25 | 5.39 | 13/16 |
| naive "hold 2020 target" | +1.25 | 5.39 | 13/16 |

The wave-offset variants are exactly the naive hold forecast. The base model's lower held-out RMSE is luck: its −4.4 pp structural bias offsets the 2022→2024 fall in HED. **Conclusion:** the fix removes the structural bias in reconstruction. Projecting HED beyond the last wave stays an explicit assumption with about ±5 pp error.

Runtime: data load + targets + demography 0.55 min. Each 5-seed 2012–2024 reconstruction 0.18 min. `hed_06_fix.R` 1.1 min total; `hed_07` 0.5 min; `hed_05` 0.6 min. 4-core container.

## 7. HED persistence: what the data offer, and a recommendation

**Data:**

- ENPG is repeated cross-sections, so individual HED persistence is not identifiable (`_enpg/notes/enpg_findings.md` §2).
- EPS has **no direct HED item**. F15 is the typical quantity per occasion (`__andres_control/eps_alcohol_prevalencia_persistencia_informe.md` §3).
- Its "heavy" volume proxy has 17 men 50+ at origin for VI→VII (`eps_alcohol_outputs/category_transitions_50plus.csv`), which is unusable.
- EPS gives only *participation* persistence: annual rho about 0.85–0.91 for ages 50+. The same-people AR(1) check fails (endpoint 0.478 vs product 0.333), so it is not a validated AR(1) (informe §5).

**What rho_hed does** (fixed 2024 cohort, rho_current = rho_amount = 0.8, `hed_persistence_grid.csv`):

| rho_hed | P(HED next yr \| HED), base / E | P(HED next yr \| no HED), base / E | Ever HED in 6 yr, base / E | Always HED in 6 yr, base / E |
|---:|---|---|---|---|
| 0 | 0.67 / 0.65 | 0.30 / 0.35 | 0.87 / 0.89 | 0.11 / 0.08 |
| 0.5 | 0.74 / 0.73 | 0.24 / 0.27 | 0.84 / 0.87 | 0.14 / 0.13 |
| 0.8 | 0.79 / 0.78 | 0.19 / 0.22 | 0.79 / 0.82 | 0.18 / 0.19 |
| 0.95 | 0.82 / 0.82 | 0.17 / 0.18 | 0.75 / 0.77 | 0.22 / 0.24 |
| 1 | 0.83 / 0.84 | 0.16 / 0.16 | 0.74 / 0.73 | 0.24 / 0.27 |

Columns other than rho_hed show base / E_bins_wave. The ever/always columns are among people current in all 6 years (n = 21,884 of 200,000). Even rho_hed = 0 gives P(HED | HED) ≈ 0.65, because HED is tied to volume rank (z_amount, rho 0.8) and to current status.

**Recommendation:**

1. **Keep z_hed independent of z_amount within a year.** Under E_bins, P(HED | volume rank) is calibrated, so correlating the latents would double-count volume.
2. Set **rho_hed = rho_amount = 0.8 as the default** and state it as an assumption.
3. Run a **sensitivity grid rho_hed ∈ {0, 0.5, 0.8, 0.95}**. Report P(HED next year | HED) of 0.65–0.82 next to deaths averted.
4. Before fixing a value, look for external panel evidence on annual binge persistence (not searched in this audit).
5. Revisit rho for amount and current status with a trait + AR structure. The EPS endpoint-vs-product discrepancy points to stable heterogeneity, which one AR(1) rho cannot represent.

## Recommendation for Monday (items 2 and 4 of the plan)

- **Minimum (margin only): B_wave.** About 15 lines in `ms-calibration-functions` (uniroot per cell × wave over the engine's g/day law) and 3 in `ms_drivers`; no engine change. It does **not** meet the "distribution coherent with ENPG" criterion: the quintile curve is off by 11 pp.
- **Preferred: E_bins_wave.** A decile table of observed HED by volume rank per cell, plus cell × wave logit offsets (uniroot), plus a one-line engine change: p_hed uses the volume rank `u = pnorm(z_amount)` instead of log1p(g/day). It reproduces the margin and the HED-by-volume curve in-sample, with structural zeros in the lowest volume deciles as ENPG has. Optional: smooth the deciles monotonically with `stats::isoreg`, since some deciles in the 60–65 cells are noisy (male 60–65, decile 7 = 0.43).
- **Consequence for the brief intervention (item 4).** Under E_bins, HED responds to the volume *rank*. Apply the BI effect as a shift in z_amount, which moves g/day and HED together, and/or as an explicit HED logit shift. Reducing g/day after the draw would leave HED unchanged. Under the log1p link, HED responds mechanically to g/day with slope 2.30 per log1p unit. That is steeper than the observed gradient and could overstate the HED effect.
- Report HED against the complete-case target **and** state that it sits 2.2–5.9 pp above SENDA's official series because of the unknown-HED denominator.

## Scripts (this folder) and outputs

| Script | Purpose | Output |
|---|---|---|
| `hed_00_load_engine.R` | rebuild `ms_enpg`, `ms_targets`, `ms_mortality` and the engine from the verbatim cells (`hed_cells/*.R`) | — |
| `hed_00b_hooks.R` | `hed_prob()` hook, `ms_drivers` override, `build_hed_variants(last_year)` | — |
| `hed_01_smoke.R`, `hed_02a_explore.R`, `hed_02b_rawnames.R` | load check, ENPG_BINGE inventory, raw item names | console |
| `hed_03_baseline_sim.R` | 5 seeds × rho 0/0.8/0.95 baseline reconstruction | `hed_sim_baseline_rho0-0.8-0.95_5seeds.csv` |
| `hed_04_definition.R`, `hed_04b_senda_denominator.R` | raw vs `db`, pooled HED vs SENDA, cell targets | `hed_def_*.csv` |
| `hed_05_decomposition.R` | A/B/C/S decomposition, volume bins | `hed_decomposition_cells.csv`, `hed_volume_bins.csv` |
| `hed_06_fix.R` | 6 variants × 5 seeds, metrics, quintile curve | `hed_fix_metrics.csv`, `hed_fix_cells.csv`, `hed_fix_volume_quintiles.csv` |
| `hed_07_holdout_persistence.R` | 2022/2024 holdout; rho_hed grid | `hed_holdout_2022_2024.csv`, `hed_persistence_grid.csv` |

Run each with `LANG=C.UTF-8 LC_ALL=C.UTF-8 Rscript --vanilla <script>`. The C locale breaks the DEIS "AÑO" header match. All CSVs are aggregated: cell or wave level, no person rows. Decrypted data stayed in R `tempdir()`.

## Caveats

- **Calibration, not validation.** B/D/E use 56 HED parameters for 56 targets, so 48/48 coverage is by construction. The held-out RMSE (about 5 pp) is the honest skill measure, and it is no better than holding the last wave.
- **Design SEs.** Coverage uses the notebook's working SEs (PSU + proxy strata; 2020 excluded). The E_bins deciles use a randomized PIT for ties (seed 20261009). The deciles and the quintile check share the same data.
- **What was not run.** The decomposition C term and the holdout are analytic engine expectations. Simulation agreement (S − C = 0.00 pp on average) was verified for base only. Nothing was run on 66+, on mortality/RR integration, or on the selection effect after RR.
- **Open causes.** The cause of the 2018 spike and the effect of the 2020+ female-card change are not identified. SENDA methodology reports would be needed.
- **Reproduction.** The notebook's stored reconstruction is reproduced statistically (−4.50 vs −4.46 pp), not bit-for-bit (DEIS vintage `06102026`).
