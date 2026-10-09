# Independent verification of `persistence.md`

Date 2026-10-09. I am a skeptical second reader. No repository file was edited. My scripts are in
`audit/verify_pers/` and their aggregated outputs in `audit/verify_pers/out/`. Notebook cells were re-extracted
independently into `audit/verify_pers/cells/`. They are byte-identical to the audited `nbsrc/` copies.

**What I re-ran, and how.**

- **EPS, from the published CSV.** I re-fitted the model in Python (scipy, dense grid plus L-BFGS-B). This is a
  different implementation from the audited R `optim` fit.
- **EPS, from microdata.** I wrote my own weighted tetrachoric, my own PSU bootstrap and my own amount copula. Only
  the data preparation reuses the project notebook's harmonisation cells.
- **ENPG.** My own weighted shares, built straight from `derived/ENPG_BINGE.RDS` plus the design weights and the raw
  `.dta` items. I did not reuse `p3_enpg_targets.R`.
- **Engine.** I did not re-run the engine. I read the code, used the audited CSVs, and used a 5-seed × 3-rho engine
  run made by another agent (`hed_sim_baseline_rho0-0.8-0.95_5seeds.csv`).

## Claim table

| # | Claim (persistence.md) | Status | My number | Note |
|---|---|---|---|---|
| 1 | Trait+AR(1) on the EPS same-people 50+ correlations (n = 1,744): λ = 0.453, φ = 0.679, objective 0.48. The three correlations re-derived from microdata match the published CSV exactly. | **CONFIRMED** | λ 0.4529, φ 0.6786, obj 0.479. My own tetrachoric: 0.5659 / 0.5881 / 0.4783, n = 1,744, identical to the CSV. | `v1_eps_fit.py`, `v4_eps.R`. The note's (0.45, 0.65) gives obj 1.08, inside the fit region. Source: handoff L8082, `microsim_respuestas_preguntas_2026-09-20.md` L425, `plan_trabajo_post_reunion_ACC_2026-09-17.md` L14. |
| 2 | Pure AR(1) rejected (obj 7.70, Δ 7.2 on 1 df). The engine's (0, 0.8) scores 62.5. In 400/400 bootstrap replicates, r(7.7 y) > r(3.7)·r(4.0). | **CONFIRMED** | AR(1) obj 7.703 (φ 0.882); engine 62.53. GLS with the bootstrap correlation of the atanh r (0.10/0.31/0.19): AR(1) Δ = 10.8 (p = 0.001), engine 47.7. Own PSU bootstrap: 400/400 replicates with long > product, smallest margin 0.022. | The bootstrap rests on only **103 PSUs**. Observed r(7.7) − r(3.7)·r(4.0) = 0.145. |
| 3 | Uncertainty: λ 0.27–0.54, φ 0.40–0.81 (PSU bootstrap); r(10 y) 0.35–0.54; joint region r(1 y) 0.53–0.88. | **CONFIRMED** (within MC error) | Own bootstrap: λ 0.28–0.56, φ 0.36–0.81, r(10 y) 0.35–0.56, r(1 y) 0.70–0.87. Joint region on a finer grid: λ 0.085–0.575, φ 0.001–0.867, r(1 y) 0.51–0.88. | The audited grid starts at φ = 0.05, so its region edges are slightly narrower. |
| 4 | "Engine ~20% annual switching is about right; its 10-year correlation is 0.11 against **0.46 in EPS**." | **CORRECTED** | 0.8^10 = 0.107 and the fit gives 0.464. Switching at p = 0.45 is 20.3% for the engine and 19.0% for the fit. Across the EPS-compatible r(1 y) of 0.51–0.88, switching ranges **15.6–32.7%**; across the bootstrap r(1 y) of 0.70–0.87 it ranges 16–25%. | 0.46 is a model extrapolation beyond the longest observed lag (r(7.7 y) observed = 0.478), not an EPS observation. EPS cannot confirm "about right" for the 1-year step, so read that as "not contradicted". |
| 5 | "No real difference by sex, age or education." | **CORRECTED** (wording; strata not recomputed) | — | The audited table itself shows λ 0.00–0.72 at ages 30–44, women at the φ = 0 boundary, and men at (0.31, 0.77). The correct statement is "not detectable with these samples". Pooling is a defensible choice; homogeneity is not shown. |
| 6 | Attrition about 60%, similar by baseline status. | **CONFIRMED** | `retention_by_baseline_status.csv`: VI→VII 39.6% vs 39.6%; VI→VIII on the official panel weight 36.9% vs 39.2%. | Not mentioned in the report: on endpoint re-interview, VI→VIII retention is 48.0% (non-drinkers) vs 52.2% (drinkers), a 4.2 pp gap. |
| 7 | ENPG 15–65, 2014–2022: never 16.4–20.8%, former (any) 30.8–38.6%; 2024: 25.8 / 38.3%. Engine 2024: 6.3 / 57.5%. | **CONFIRMED** | Never by wave: 27.5, 18.2, 16.7, 19.4, 16.4, 20.8, 25.8. Former: 29.2, 30.8, 35.0, 34.9, 36.9, 38.6, 38.3. Identical with the raw `exp` weight. Engine: repo `persistence_sensitivity.csv` 6.12 / 57.55; audited re-run 6.27 / 57.46. | `v2_enpg.R`, `out/v2_enpg_overall.csv`. Denominator: known status, ages 15–65 (n_known 15,977–19,195 per wave). Unknown status is 0.4–1.4%. The definitions match `ms-survey-inputs` L69–71, and engine "former" = ever & not 30-day, so the comparison is like for like. |
| 8 | 2012 and 2024 "never" jump +7 to +15 pp within the same birth cohorts. Use 2014–2022. | **CORRECTED** | The two quoted series are exact: women born 1975–79 24.5, 17.2, 16.2, 23.4, 16.9, 18.8, 31.5; men born 1970–74 14.9 … 14.1, 25.8. Across all 5-year cohorts born ≤ 1985, the deviation from each cohort's 2014–22 mean is **+1.9 to +12.3 pp in 2012 (median 7.0)** and **+4.5 to +15.2 pp in 2024 (median 8.3)**. The raw 2024−2022 jump is −1.6 to +12.7 (median 5.5; women 7.1, men 3.7). | `out/v2_enpg_pseudocohort.csv`. The wave effect is real but its size varies, and it is larger in women. **2018 women are also elevated** (median +4.6 pp over the 2016/2020 average), so 2014–2022 is not fully clean. Lead, not verified: the 2024 `OH_1` wording drops the beverage list ("¿Ha tomado Ud. alcohol alguna vez en su vida?") (`_enpg/notes/enpg_variable_audit.csv`). |
| 9a | `OH_2` ("first time ever drank"): 88.5% (2012, 1,602/1,811) to 94.6% (2024, 1,338/1,415) of "first drink within 12 months" respondents report an onset age below age − 1. Do not use `init12`. | **CONFIRMED** | 1,602/1,811 = 88.5%; 1,338/1,415 = 94.6%. All waves: 88.5–94.6% of those with a known onset age (83–91% of all such respondents). | `out/v2_enpg_oh2_validity.csv`. The denominator is respondents with a known onset age. |
| 9b | "The item behaves like 'last time'." | **REFUTED** | Raw `OH_2` equals raw `OH_4` (last time) for only **31–43%** of ever-drinkers. "First use within 12 months" covers 5.7–21.2% of ever-drinkers, against 69.7–80.7% for last use. | `out/v2_enpg_item_identity.csv`. `OH_2` is inconsistent but it is not a relabelled last-use item. Also verified: the engine's recency variable (derived `oh2`) equals raw `OH_4`/`p13` (last time) for **100%** of ever-drinkers in all 7 waves, so `ms-survey-inputs` uses the correct item. |
| 9c | Retrospective never-by-15 is implausibly high; onset ages are telescoped upward. | **CONFIRMED** (stronger) | Ages aligned (retrospective never by the end of age a vs cross-section at a + 1, 2014–2022, respondents aged ≤ 32): men 85 vs 46% at 16, 56 vs 22% at 18; women 90 vs 47% at 16, 51 vs 26% at 18. The gap is under 3 pp from about age 22. | `v6_onset.R`. Cross-sectional never plateaus at about 11–13% (men) and 16% (women) from age 21–25. |
| 10 | Pure latent model: 0/18 grid cells compatible; the closest cell (0.6, 0.9) is "still 7–14 pp short on never". | **CORRECTED** | Under the engine's own rule (`never_annual`, ever updated at the yearly snapshot), the (0.6, 0.9) cell gives men 20.0 / 13.1 / 10.5 against targets of 11.9 / 14.2 / 15.9, and women 32.9 / 24.5 / 21.2 against 18.9 / 22.5 / 31.6. That is **too high at 30–34** (+8 / +14 pp) and too low at 60–65. | The verdict in `p4d_compat.py` uses the monthly-updated `never`, not the engine rule, and uses pooled 2012–2024 targets that include the wave effects. More fundamentally, the test compares one synthetic cohort with a cross-sectional age profile whose rise in never with age is a cohort effect, which no absorbing-never single-cohort model can match. The qualitative conclusion stands on better evidence: the real engine run, where never falls to 6.3% by 2024. |
| 11 | Mover–stayer refit: movers `trait_share` 0.32, `ar_phi` 0.66; region λ 0–0.44, φ 0.40–0.84 (s = 0.20). "ENPG never at 45–65 ≈ 0.20 matches s ≈ 0.20." | **CORRECTED** (point estimate confirmed; conclusion depends on s) | Own refit using the **observed** VII margin (0.326; audited code assumed 0.3025): s = 0.20 gives (0.32, 0.66), obj 1.02. At **s = 0.25 the legacy AR(1) ρ = 0.8 for movers has Δ = 4.5** (not rejected at 5.99). At s = 0.30, Δ = 4.7. | `v5_mover_stayer.py`. EPS cannot identify s (the notebook's lifetime-abstainer bounds are 0–35% for men and 0–62% for women). The EPS 50+ panel is 61% women, aged 50–91 (median 61). ENPG 2014–22 never at 60–65 with that sex mix is 22.5% (men 13.8, women 28.1), and ages 66–91 are unobserved. So the trait among movers is weakly identified, and 0.32 only holds conditional on s = 0.20. |
| 12 | Scratch engine with stayers plus (0.32, 0.66): never/former 2014–2022 cells mean \|dev\| 2.8 / 2.9 pp (90 / 85% within ±5), against 9.5 / 9.4 now; in-engine correlations inside the EPS CIs. | **Numbers CONFIRMED (from the audited CSV, not re-run); REFUTED as evidence for (0.32, 0.66)** | AR(1) 0.8 plus stayers gives the **same** 2.78 / 2.92. Simply assigning every 2014–22 cell its **pooled 2012–2024 ENPG never share** (the prototype's own stayer input, `s_target`) gives **2.75 pp, 92.5% within ±5** for never and for former (former = 1 − wave current − pooled never). | `out/v2_enpg_pooled_plugin_vs_waves.csv`. The metric is in-sample: stayers are seeded from ENPG never and `p_ever_noncurrent` is pooled over the training waves (`ms-calibration-functions` L59–62). What it shows is that stayers stop the erosion of never (valid). It does not validate λ or φ. In-engine EPS correlations at ages 50–57 also fall inside the CIs for AR(1) + stayers (0.606 / 0.612 / 0.420). Only the 18–49 check separates the two (WLS 9.8 vs 1.7), on 1 seed. |
| 13a | g/day persistence is flat across lags (0.33 / 0.39 / 0.38); rho = 0.8 implies 0.18 at 7.7 years. | **CONFIRMED** | Common sample (the same 446 people drinking > 0 g at all three interviews): 0.32 / 0.40 / 0.35 (PSU bootstrap 0.15–0.43 / 0.31–0.49 / 0.25–0.44). Unweighted Spearman 0.27 / 0.38 / 0.30. 0.8^7.693 = 0.180 is below the 7.7-year CI. | `v4_eps.R`. The audited figures used different people at each lag (n = 764 / 686 / 659). On a common sample the picture is unchanged. |
| 13b | Persistence cannot explain the −4.5 pp HED bias (HED margin does not depend on rho; "read, not run"). | **CONFIRMED (now run)** | HED among current drinkers across rho 0 / 0.8 / 0.95 (5 seeds each): spread at most **0.37 pp** in any year 2012–2024, against a seed SD of 0.24–0.67 pp. | `v3_hed_rho.py`. Code reason: `z_hed` is drawn independently of `z_current` and `z_amount` (`ms-annual-engine` L9). The update at L125–126 keeps N(0,1) and independence. Deaths and stock exits do not depend on z. |

## Code-location claims

| Claim | Status | Note |
|---|---|---|
| `ms-annual-engine` L28–29 (HED rule) and L125–126 (rho update) | CONFIRMED | Line 1 is the `#| label:` line. |
| `eps-panel-diagnostics`: VII→VIII lag 4.022 (3.554–4.490) | CONFIRMED | L19. |
| `ms-survey-inputs`: never = `oh1 == "No"`, current = "30 dias" | CONFIRMED | L69–71. The derived `oh2` is the last-use item (row 9b). |
| Handoff "line ~8100: `trait_share`, `ar_phi`" | **CORRECTED** | Handoff L8082 holds "λ 0,45; φ 0,65" plus a grid. The names `trait_share` / `ar_phi` never appear in the handoff. They come from `expand_pif_cambios_hallazgos_2026-09-21.md` L115 and `expand_pif_registro_2026-10-06.md` L734 and L1083. |
| `microsim_respuestas_preguntas_2026-09-20.md` §16b L376–390 (0.48 / 0.58) | CONFIRMED | Table at about L379–383. |
| `persistence_sensitivity.csv` 0.2000 / 0.3634 / 0.0612 / 0.5755; rho 0 / 0.8 / 0.95 never 1.7 / 6.1 / 12.6, former 61.6 / 57.5 / 51.5 | CONFIRMED | — |
| `retention_by_baseline_status.csv` 39.6 / 36.9 / 39.2% | CONFIRMED | — |

## Not checked

- I did not re-run the engine prototype; its single seed means there are no MC intervals. The audited prototype also
  breaks seed alignment with the verbatim engine through extra draws, so its "regression" check compares different RNG
  paths.
- I did not recompute the strata fits in §2, the young-age gap in §4, the 12-month vs 30-day intermittency proxy, or
  the HED-proxy tetrachorics.

## Scripts

| Script | What | Runtime |
|---|---|---|
| `verify_pers/extract_cells.py` | Re-extracts the notebook cells by label | <0.1 min |
| `verify_pers/v1_eps_fit.py` | Re-fit from the CSV, joint region, GLS, switching | <0.1 min |
| `verify_pers/v2_enpg.R` | ENPG shares, pseudo-cohorts, OH_2/OH_4 identity and validity, pooled plug-in circularity test | 0.2 min |
| `verify_pers/v3_hed_rho.py` | HED margin across rho from the 5-seed engine CSV | <0.1 min |
| `verify_pers/v4_eps.R` | Own tetrachoric, PSU bootstrap, amount copula on a common sample, 50+ margins | 0.1 min |
| `verify_pers/v5_mover_stayer.py` | Mover–stayer refit with the observed VII margin, s = 0 / 0.20 / 0.25 / 0.30 | 0.7 min |
| `verify_pers/v6_onset.R` | Retrospective vs cross-sectional never by single age | 0.2 min |
