# Verification of `hed_diagnostic.md` (HED underestimation)

2026-10-09 | cc-cloud | Claude (independent verifier subagent). No repo file was edited. My scripts and aggregated outputs are in `audit/verify_hed/`.

## How this was checked

- **Notebook cells.** I re-extracted the cells of `__andres_control/microsim_recalib_ACC_2012_2024.ipynb` with my own json parser into `verify_hed/cells/`. All 14 labelled cells are byte-identical to the agent's `hed_cells/`. I then ran them through **my own loader** (`v0_loader.R`). It makes only two substitutions: the DEIS 2012–2023 parquet is read with python into R's `tempdir()`, and `ms_table` is a no-op.
- **HED target (`v1_targets.R`).** I rebuilt it from `derived/ENPG_BINGE.RDS` and the design-weight cache **without** the notebook cells, using my own data.table code.
- **Engine expectations (`v2_engine.R`, `v3_attribution.R`).** I computed these with a 200,000-point quasi-MC u-grid that mirrors `ms_exposure`, not the agent's `integrate()`. I re-ran the simulations myself, adding a second seed block (3125–3129).
- **Run vs read.** Everything in the table is **RUN** on decrypted ENPG, DEIS (`06102026`), INE and HMD data, unless the note says "read".

## Claims table

| # | Claim (report / summary) | Status | My number | Note |
|---|---|---|---|---|
| 1 | Notebook HED glm coefficients equal the stored `model_parameters.csv` (`reconstruction2024_interp_hold`) | CONFIRMED | max \|diff\| 4.9e-15 | `v2_log.txt` |
| 2 | Re-run base bias −4.50 pp, 30/48 coverage; stored −4.46 pp, 31/48 | CONFIRMED | −4.497 pp, 30/48 (seeds 2125–2129); stored −4.464 pp, 31/48; per-cell max \|sim − stored\| 2.08 pp | Seeds 3125–3129 give −4.58 pp, 30/48 |
| 2b | The gap to the stored run is "likely the DEIS vintage" (inferred in the report) | CONFIRMED (now verified) | Mortality multiplier F 0.9645 vs 0.9700 stored; M 0.9413 vs 0.9449 | Stored provenance names `..._09062026.parquet`; `acc_deis()` now loads `06102026` (`microsim_recalib_outputs/input_provenance.csv`) |
| 3 | "−4.5 pp" is the engine's HED bias | CORRECTED (framing) | Unweighted mean of 56 cells −4.50 pp. **Population-weighted −5.3 pp.** Pooled 15–65 by wave (cells weighted by survey current-drinker weights): −6.0, −3.2, −4.5, **−11.0 (2018)**, −4.8, −4.6, −2.4 pp | −4.5 pp is the notebook's cell-average metric, not the national gap. Cite −5.2/−5.3 pp when the national level is meant (`v2_sim_metrics.csv`, `v2_log.txt`) |
| 4 | Decomposition: A−T −0.12, B−A 0.00, **C−B −4.38**, S−C 0.00 pp; C−B < 0 in 53/56 cells; −5.53 men / −3.23 women; 2018 time term −4.93 | CONFIRMED (arithmetic) | −0.116 / −0.001 / **−4.382** / +0.002 pp; 53/56; −5.53 / −3.23; 2018 −4.93 | Grid method, independent of `integrate()` (`v2_decomposition_grid.csv`) |
| 5 | Verdict: "(a) assignment by volume explains −4.38 of −4.50 pp"; the glm's steeper HED-by-volume curve is another cause | **CORRECTED (interpretation)** | ENPG's own HED-by-g/day curve applied to the engine's Gamma law: **−8.54 pp** (RMSE 9.66, 17/48). The notebook glm applied to an **empirical g/day law** (weighted quantiles by cell, pooled waves, rescaled to each year's mean): **−0.22 pp** (RMSE 4.07, 42/48), with no new HED parameters | The split is path-dependent. The defect is the **g/day law** (Gamma shape), not the HED assignment step. The glm's steeper curve *offsets* about half of it; it does not add to it. 30.0% of simulated female and 18.7% of male drinkers draw < 0.4 g/day, the ENPG minimum (1 day × 1 drink × 12 g / 30). Analytic, not simulated (`v3_attribution.R`) |
| 6 | Engine puts 44% of women / 29% of men below 1 g/day vs 33% / 16% observed; men at 20–40 g/day 7.3% vs 4.3% | CONFIRMED | 43.8% / 29.1% vs 33.2% / 15.8%; 7.3% vs 4.3% | Means of cell shares (4 ages × 7 waves). Survey-weighted pooled observed: 31.3% / 15.2% (`v1_obs_bins.csv`) |
| 7 | Coverage: 481 of 45,361 current drinkers have HED known but g/day NA; 0.88% of the weighted denominator; 1.13% of HED cases; −0.12 pp | CONFIRMED | 481 / 45,361 (448 days NA, 33 drinks NA); 0.88%; 1.13%; −0.116 pp (range −0.75..+0.43); 0 HED cases below the floor | Shares are means over 56 cells; pooled: 0.89% / 1.16% |
| 8 | Complete-case target sits 2.2–5.9 pp above SENDA; unknown-as-"no" reproduces SENDA within 0.6 pp | CONFIRMED (data side); SENDA series UNVERIFIED | 12–65: +2.15..+5.88 (CC), −0.23..−0.61 (UAN). 15–65: +2.12..+5.98, −0.19..−0.64 | SENDA values read from `p3kimi_investigacion_HED_faltantes_AAF_Chile.md:92,107`, which cites the SENDA 2025 presentation; not checked against SENDA. The report's table mixes a 15–65 CC column with a 12–65 UAN column (≤ 0.1 pp effect) |
| 9 | HED margin invariant to rho: bias −4.44 / −4.50 / −4.45 pp for rho 0 / 0.8 / 0.95 | CONFIRMED | −4.44 / −4.50 / −4.45 pp; coverage 31 / 30 / 33 of 48 | Holds by code: latents iid N(0,1) (`ms-annual-engine` lines 9, 125–126); deaths depend only on sex/age/year (85–87); outflow random within sex×age (111) |
| 10 | B_wave fix: bias +0.06, RMSE 0.65, 48/48 | CONFIRMED | +0.064 / 0.648 / 48/48 (seeds 2125–2129); −0.11 / 0.74 / 48/48 (3125–3129) | My own uniroot on the grid. 48/48 holds by construction (56 offsets for 56 targets), as the report states |
| 11 | E_bins_wave: bias −0.06, RMSE 0.59, 48/48; HED-by-volume-quintile error 0.42 pp | UNVERIFIABLE (not recomputed); read as in-sample | — | From reading `hed_00b_hooks.R` and `hed_06_fix.R`: the decile table and the quintile check use the same ENPG ranks (`u_r`, one seed), so 0.42 pp is near-tautological. The match is on volume *rank*, not on absolute g/day |
| 12 | Holdout (fit ≤ 2020): base −2.22 / 4.99 pp, 12/16; wave-offset variants = naive "hold 2020" +1.25 / 5.39 pp | CONFIRMED | base −2.220 / 4.992, 12/16; hold-2020 +1.252 / 5.388, 13/16 | B/D/E equal "hold 2020" by construction (offsets solved on 2020, `approx(rule = 2)`) |
| 13 | P(HED next yr \| HED) rises from 0.65 to 0.84 with rho_hed; margin unchanged | CONFIRMED for base; E not re-run | base: 0.674 (rho_hed 0), 0.786 (0.8), 0.828 (1); margin 0.473–0.476 | 0.65 and 0.84 are the E_bins values. Base runs 0.67–0.83 |
| 14 | EPS has no HED item; heavy-proxy VI→VII has 17 men 50+ at origin; AR(1) endpoint 0.478 vs product 0.333 | CONFIRMED (read) | — | `eps_alcohol_prevalencia_persistencia_informe.md:47,97`; `eps_alcohol_outputs/category_transitions_50plus.csv` (n_valid = 17) |
| 15 | Questionnaire: holiday exclusions "from 2016, 2020 and 2024"; female card shows male volumes from 2020; 2018 codes 888/999 | CORRECTED (wording) | — | `_enpg/notes/enpg_findings.md:11`: Fiestas Patrias excluded in **2016 and 2018**; New Year conditionally excluded in 2020 and 2022; both in 2024. The rules *change* in 2016/2020/2024; they are not limited to those years. Card and code claims are correct |
| 16 | Code locations: `ms-survey-inputs` 79, 86, 125–128; `ms-annual-engine` 9, 29, 73, 87, 111, 125–126 | CONFIRMED | — | Line numbers count the `#\| label` line as line 1 of the cell |
| 17 | "For Monday use E_bins (one-line engine change) so HED is consistent with ENPG in level and volume gradient" | **REFUTED as written** | See rows 5, 6, 11 | E_bins needs a new calibration table, 56 offsets, a drivers override and the engine line. It fits HED in-sample by construction. It leaves the absolute g/day law wrong, which is exactly what the RR step consumes |

## What must not be used as written

1. **"The cause is hypothesis (a), HED assignment by volume (−4.38 of −4.50 pp)."** The arithmetic is right; the attribution is not. The engine's zero-heavy Gamma g/day law is the root cause:
   - ENPG's own HED curve on that law gives −8.5 pp.
   - The existing glm on an empirical g/day law gives −0.2 pp.
   - The glm's "steeper curve" is a compensating error, not a second cause.
2. **"Bias −4.5 pp"** as a national figure. Population-weighted it is −5.3 pp, and −11.0 pp in 2018.
3. **"Use E_bins for Monday; HED coherent with ENPG in level and gradient."** That coherence is an in-sample identity on volume rank. The absolute g/day used by the volume RR stays mis-shaped (30% of simulated women below the ENPG minimum of 0.4 g/day; men at 20–40 g/day 7.3% vs 4.3%).
   - Minimal alternative: replace the Gamma with the empirical weighted quantile law by sex × age, rescaled to each year's mean. One `qgamma` call is replaced by a lookup.
   - Analytic result: −0.22 pp bias, 42/48 coverage, with the existing glm.
   - Remaining gap: the 2018 wave (−6.7 pp).
   - Not yet simulated end to end.
4. **The holiday-exclusion phrasing** in the summary (see row 15).

## Not checked

- E_bins was not re-implemented.
- The SENDA series was not verified against SENDA.
- The raw-item vs `db` agreement was checked by reading `hed_04_definition.R` and its CSV, not re-run.
- Nothing was run on mortality, RR, or ages 66+.

## Files

`verify_hed/`:
- `v0_loader.R`, `v1_targets.R`, `v2_engine.R` (log in `v2_log.txt`), `v3_attribution.R`
- `v1_*.csv`, `v2_*.csv`, `v3_attribution.csv`: aggregated only

Run each with `LANG=C.UTF-8 LC_ALL=C.UTF-8 Rscript --vanilla <script>`. Runtimes: v1 0.19 min, v2 1.84 min, v3 0.25 min.
