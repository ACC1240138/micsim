# Drinking-participation persistence: replacing the assumed rho = 0.8

Audit date 2026-10-09. Scope: item 1 of the user's plan (consumption trajectories), participation component
(`z_current`), with consequences for `z_amount`/`z_hed`. No repository file was edited. Scripts and aggregated
outputs live in this folder (`audit/`, `audit/out/`). Every number below names the script that produced it.

## Bottom line

1. **The algebra holds and the published proposal is reproduced.** Fitting `corr(z_t, z_{t+d}) = lambda + (1-lambda) phi^d`
   to the three same-people EPS correlations (50+, n = 1,744) by WLS gives **lambda = 0.453, phi = 0.679**. The note's
   (0.45, 0.65) lies inside the fit region (objective 1.08 vs. 0.48 at the optimum). Pure AR(1) is rejected
   (objective 7.70, ΔWLS = 7.2 on 1 df). The current engine (lambda = 0, phi = 0.8) scores 62.5, and a PSU bootstrap
   shows r(7.7 y) > r(3.7 y)·r(4.0 y) in **400/400** replicates.
2. **EPS identifies long memory, not the 1-year step.** All lags are ≥ 3.7 years. The joint 95% region spans
   r(1 y) = 0.53–0.88. Even so, the engine's year-to-year switching (~20%/year) is about right. What it gets wrong is
   10-year memory: r(10 y) is **0.11** in the engine against **0.46** (95% CI 0.35–0.54) in EPS.
3. **No grid cell of the pure latent model fits ENPG (0 of 18).** Even λ = 0.6, φ = 0.9 leaves the never-drinker share
   7–14 pp too low, and the former-drinker (>12 months) share is too high in every cell. The engine has 6.3% never-drinkers
   and 57.5% former drinkers in 2024. ENPG has **16.4–20.8% never and 30.8–38.6% former in 2014–2022** (25.8% / 38.3% in 2024).
   The cause is structural: lifetime abstainers are not "people far from a threshold" on a shared Gaussian process.
4. **Mover–stayer + trait + AR(1) fits both sources.** Never-drinkers aged 25+ are kept as lifetime abstainers ("stayers",
   absorbing). Movers then need **trait_share ≈ 0.32, ar_phi ≈ 0.66** to match EPS. A scratch copy of the real engine with
   these settings brings the 2014–2022 ENPG never/former cells to a mean absolute deviation of **2.8 / 2.9 pp** (now 9.5 / 9.4 pp).
   The margins are unchanged, and EPS-type correlations computed inside the simulated panel sit within the EPS CIs.
5. **Amount and the HED proxy are trait-dominated.** Within-person correlations of g/day among people drinking at both
   interviews are flat across lags (0.33 / 0.39 / 0.38 at 3.7 / 4.0 / 7.7 years). The current rho = 0.8 makes them decay
   to 0.18 at 7.7 years. Persistence of `z_hed` cannot cause the −4.5 pp HED bias: the engine keeps `z_hed` ~ N(0,1),
   independent of g/day, so the HED margin does not depend on rho. I read this in the code; I did not run it.

## 0. What was run vs. read

| Step | Verified by running code | Inferred by reading |
|---|---|---|
| 1 | WLS fit, profile, parametric and PSU bootstrap (`p1_fit_csv.R`, `p2_eps_microdata.R`, `p1c_reliability_transitions.R`). EPS same-people correlations re-derived from microdata match the published CSV to <1e-6 (`out/p2_reproduction_check.csv`). | Lag of VII→VIII = 4.022 y (3.554–4.490), taken from the code of notebook cell `eps-panel-diagnostics` |
| 2 | Same-people triples by baseline age/sex, including ages < 50 (`p2_eps_microdata.R`). Pair-based fits by age × sex × education (`p2c_pairs_strata.R`) | — |
| 3 | ENPG 2012–2024 design-based targets, onset hazard and pseudo-cohorts (`p3_enpg_targets.R`) | Variable meaning from `_enpg/notes/enpg_variable_audit.csv` and `__andres_control/eps_alcohol_outputs/enpg_wave_crosswalk.csv` |
| 4 | Latent-model grid and mover–stayer refit (`p4_grid.py`, `p4b_mover_stayer.py`, `p4c_young.py`, `p4d_compat.py`, `p4e_cohort_s.py`, `p4f_sens_sets.py`) | — |
| 5 | Verbatim engine reproduction plus a scratch prototype (`p5_engine_proto.R`, `p5b_compare.py`) | HED-margin invariance (`ms-annual-engine` lines 28–29, 125–126) |

**Environment.** Rscript --vanilla on R 4.3.3, with system packages plus `r-cran-mvtnorm` (apt) for the tetrachoric
function. renv.lock and DESCRIPTION are untouched.

**Engine reproduction.** I re-ran the verbatim engine (seed 2125, n_sim 25,000) and got switching 0.1988, current 0.3627,
never 0.0627 and former 0.5746. The repo's `microsim_recalib_outputs/persistence_sensitivity.csv` has 0.2000, 0.3634,
0.0612 and 0.5755. The gap is consistent with the newer DEIS 2024 file (`..._06102026`) changing `mortality_scale` and
therefore the RNG path. This is plausible, not proven.

## 1. Trait + AR(1) on the three same-people EPS correlations

**Model.** `z = sqrt(lambda) u + sqrt(1-lambda) a_t`, where `u ~ N(0,1)` is fixed and `a_t` is AR(1) with annual phi and unit
variance. Both components are independent. Then `Var z = 1` and `Cov(z_t, z_{t+d}) = lambda + (1-lambda) phi^d`. The
threshold rule `pnorm(z) < p_cell` keeps every margin, so lambda = 0 is exactly the current engine. Under the latent-threshold
model the tetrachoric correlation of the binary status estimates this latent correlation, assuming no misclassification.

**Inputs.** `eps_alcohol_outputs/rho_same_people_three_interviews.csv` (All: n = 1,744, n_eff = 1,214.6) and
`interview_interval_assumptions.csv`. Lags are 3.671 (3.285–4.057), 4.022 (3.554–4.490) and 7.693 (7.110–8.277) years.
WLS works on the Fisher-z scale, with SE = (atanh(upper) − atanh(lower)) / (2 × 1.96) from the published 95% CIs.

| Fit (50+, same people) | lambda | phi | WLS obj (df) | r(1 y) | r(10 y) |
|---|---:|---:|---:|---:|---:|
| **Trait + AR(1), All** | **0.453** | **0.679** | 0.48 (1) | 0.824 | 0.464 |
| Pure AR(1), All | 0 | 0.882 | 7.70 (2) | 0.882 | 0.285 |
| Note's proposal (0.45, 0.65) | 0.45 | 0.65 | 1.08 | 0.808 | 0.457 |
| Current engine | 0 | 0.80 | 62.5 | 0.800 | 0.107 |
| Men (n = 684) | 0.306 | 0.775 | 0.08 | 0.844 | 0.360 |
| Women (n = 1,060) | 0.487 | ≈0 (boundary) | 2.63 | 0.488 | 0.487 |
| Full pairs VI–VII, VI–VIII 50+ (not same people; exactly identified) | 0.478 | 0.575 | — | 0.778 | 0.479 |

Source: `out/p1_fit_same_people_csv.csv`, `out/p1_fit_full_pairs_50plus.csv`. The full-pairs row reproduces the note's
0.48 / 0.58 (`microsim_respuestas_preguntas_2026-09-20.md` §16b, lines 376–390).

| Pair | Lag | Observed (95% CI) | Trait + AR(1) | Pure AR(1) | (0.45, 0.65) | Engine 0.8^d |
|---|---:|---|---:|---:|---:|---:|
| VI→VII | 3.67 | 0.566 (0.479–0.641) | 0.585 | 0.632 | 0.563 | 0.441 |
| VII→VIII | 4.02 | 0.588 (0.507–0.659) | 0.568 | 0.605 | 0.547 | 0.408 |
| VI→VIII | 7.69 | 0.478 (0.391–0.557) | 0.481 | 0.382 | 0.470 | 0.180 |

(`out/p1_fitted_vs_observed_all.csv`)

**Uncertainty (All, 50+)**

- **Profile, Δ ≤ 3.84:** lambda 0.22–0.55; phi 0.05–0.83. Profile in lambda: Δ = 7.3 at 0, 4.05 at 0.20, 0 at 0.45,
  3.06 at 0.55, 10.2 at 0.60. Joint region (Δ ≤ 5.99): lambda 0.10–0.57, phi 0.05–0.86, with **implied r(1 y) 0.53–0.88**
  and **r(10 y) 0.30–0.57**. The whole grid is in `out/p1_profile_grid_all.csv`.
- **Parametric bootstrap** (B = 4,000, independent normal errors on atanh r): lambda 0.22–0.56, phi 0.0004–0.84.
  lambda < 0.05 in 0.6% of draws.
- **PSU bootstrap on microdata** (R = 400, clusters resampled, strata ignored because singleton strata make the
  subbootstrap undefined, which is conservative): lambda **0.267–0.541**, phi **0.400–0.813**, r(1 y) 0.722–0.872,
  r(10 y) 0.346–0.544. Bootstrap correlations among the three atanh r are 0.10 / 0.31 / 0.19, so the
  independent-errors assumption above is only mildly wrong. Source: `out/p2_boot_lambda_phi_by_age_sex.csv`.
- **Fieldwork-date envelope:** lambda 0.449–0.457, phi 0.642–0.709. Negligible.
- **Misclassification:** a common reliability Rel attenuates every correlation and is not identified with two distinct
  lags. Rel = 0.9 gives lambda 0.489, phi 0.729, r(1 y) 0.861. Rel = 0.8 gives 0.509, 0.803, 0.904
  (`out/p1c_reliability_sensitivity.csv`). True persistence is therefore at least the estimate.

**What the numbers mean for the annual step.** At prevalence 0.45, annual switching is 20.3% for the engine and 19.0% for
(0.453, 0.679). The probabilities of staying a drinker are 0.774 vs. 0.789 (`out/p1c_transitions_candidates.csv`). The two
models differ in memory: r(5 y) is 0.33 vs. 0.53 and r(10 y) is 0.11 vs. 0.46. One-year EPS correlations do not exist. The
ENPG 12-month vs. 30-day contrast supports r(1 y) ≈ 0.80–0.85 (§4), but only under a strong assumption.

## 2. Does persistence differ by sex, age or education?

Same-people triples re-derived from microdata now include baseline ages < 50. The published triple was restricted to 50+.

| Baseline age (VI, 2016) | Sex | n | r 3.7 / 4.0 / 7.7 y | lambda (95% PSU boot) | phi (95%) | r(1 y) (95%) |
|---|---|---:|---|---|---|---|
| 18–29 | All | 1,240 | 0.565 / 0.586 / 0.468 | 0.44 (0.26–0.55) | 0.69 (0.48–0.80) | 0.83 (0.74–0.87) |
| 30–44 | All | 537 | 0.630 / 0.741 / 0.547 | 0.51 (0.00–0.72) | 0.74 (0.00–0.90) | 0.87 (0.66–0.91) |
| 45–59 | All | 1,088 | 0.543 / 0.605 / 0.513 | 0.51 (0.37–0.58) | 0.55 (0.00–0.74) | 0.78 (0.52–0.86) |
| 50+ | All | 1,744 | 0.566 / 0.588 / 0.478 | 0.45 (0.27–0.54) | 0.68 (0.40–0.81) | 0.82 (0.72–0.87) |
| 60+ | All | 978 | 0.630 / 0.633 / 0.529 | 0.49 (0.12–0.62) | 0.72 (0.37–0.87) | 0.86 (0.74–0.90) |
| 18+ | All | 3,843 | 0.600 / 0.664 / 0.525 | 0.51 (0.38–0.61) | 0.68 (0.53–0.79) | 0.84 (0.80–0.87) |
| 18+ | Men | 1,448 | 0.581 / 0.630 / 0.464 | 0.41 (0.00–0.59) | 0.75 (0.53–0.87) | 0.85 (0.79–0.89) |
| 18+ | Women | 2,395 | 0.518 / 0.615 / 0.465 | 0.46 (0.30–0.56) | 0.64 (0.00–0.77) | 0.80 (0.54–0.84) |

Source: `out/p2_boot_lambda_phi_by_age_sex.csv`, `out/p2_triple_rho_by_age_sex.csv`.

- **Age.** There is no detectable gradient. Point lambdas run 0.44–0.51 and all intervals overlap. The youngest band (18–29
  at baseline, so roughly 18–37 over the follow-up) looks like 50+.
- **Sex.** Differences are not significant. Women aged 45–59 (and the 50+ group that contains them) hit the phi = 0 boundary because r(3.7 y) < r(7.7 y), which a
  stationary model cannot produce. Exactly identified pair fits (`out/p2c_pairs_lambda_phi_age_sex.csv`) are noisy for the
  same reason: lambda ranges 0.00–0.56, and 6 of 17 cells hit a boundary. **Use a pooled (lambda, phi) with no sex or age
  terms.**
- **Education** (descriptive, Fisher-z pooled across age × sex cells, `out/p2c_education_pooled.csv`): lambda is 0.45
  (primary), 0.35 (secondary) and 0.24 (tertiary), but r at 3.7 y is nearly equal (0.47 / 0.47 / 0.58), SE_z 0.04–0.08.
  There is no robust gradient.
- **A non-stationarity hint.** r(VII→VIII) exceeds r(VI→VII) in 19 of 21 strata despite similar lags. That fits
  wave-specific reliability: VI is weights-only and its fieldwork differs; VII was in person just before COVID. A
  three-correlation model cannot separate this. It is a reason not to over-read phi.
- **Conditioning.** Every estimate conditions on survival to and response at VI, VII (in person) and VIII. The F13 item
  has no reference period, and ages under 18 are never observed. Retention among 50+ was VI→VII 39.6% for both baseline
  non-drinkers and drinkers; VI→VIII (official panel weight) 36.9% vs. 39.2% (`eps_alcohol_outputs/retention_by_baseline_status.csv`).
  Differential selection on status is therefore small, but total attrition is about 60% and selection on unobservables is
  untested. Deaths are excluded, so no mortality–persistence link is identified.

## 3. ENPG: partial-longitudinal targets (2012–2024, ages 15–65)

The definitions follow notebook cell `ms-survey-inputs`. never = `oh1 == "No"`. current = last use within 30 days. 12-month
use = last use within 30 days or 1–12 months. former>12m = last use more than a year ago. The weights, PSU and strata are
those of `ms-survey-inputs`, with the design built on the full wave before taking domains. Script: `p3_enpg_targets.R`.

**Whole 15–65 domain by wave: % (design SE)**

| | 2012 | 2014 | 2016 | 2018 | 2020* | 2022 | 2024 |
|---|---|---|---|---|---|---|---|
| n | 16,240 | 19,195 | 18,157 | 18,392 | 15,977 | 16,915 | 18,092 |
| never | 27.5 (1.0) | 18.2 (0.6) | 16.7 (0.6) | 19.4 (0.7) | 16.4 (0.6) | 20.8 (0.6) | 25.8 (0.7) |
| former, any (= engine "former") | 29.2 | 30.8 | 35.0 | 34.9 | 36.9 | 38.6 | 38.3 |
| former > 12 months | 13.7 | 15.9 | 16.3 | 16.5 | 22.3 | 23.6 | 22.2 |
| 30-day | 43.3 | 51.0 | 48.4 | 45.7 | 46.7 | 40.6 | 35.9 |

\*2020 SE is weights-only. Engine 2024 at rho = 0 / 0.8 / 0.95: never 1.7 / 6.1 / 12.6%, former 61.6 / 57.5 / 51.5%
(`microsim_recalib_outputs/persistence_sensitivity.csv`). Source: `out/enpg_targets_wave_overall.csv`. Wave × sex × age
group with SE is in `out/enpg_targets_wave_sex_agegroup.csv`.

**Pooled 2012–2024 (waves weighted equally), %** (`out/enpg_pooled_sex_agefine.csv`; n = never denominator)

| Sex | Age | n | 30-day | 12-month | never | former > 12 m | P(not 30 d \| 12 m) |
|---|---|---:|---:|---:|---:|---:|---:|
| F | 15–17 | 2,518 | 16.1 | 34.9 | 49.0 | 16.1 | 53.7 |
| F | 18–20 | 3,134 | 36.6 | 55.9 | 29.5 | 14.6 | 34.5 |
| F | 25–29 | 6,966 | 45.2 | 64.7 | 17.7 | 17.6 | 30.1 |
| F | 30–34 | 7,094 | 41.9 | 60.2 | 18.9 | 21.0 | 30.3 |
| F | 45–49 | 6,683 | 40.0 | 58.5 | 22.5 | 19.0 | 31.7 |
| F | 60–65 | 11,653 | 26.8 | 41.2 | 31.6 | 27.2 | 34.9 |
| M | 15–17 | 2,485 | 23.0 | 39.2 | 48.3 | 12.6 | 41.4 |
| M | 18–20 | 2,898 | 47.0 | 64.3 | 22.8 | 13.0 | 26.8 |
| M | 25–29 | 5,321 | 61.0 | 74.6 | 12.1 | 13.3 | 18.2 |
| M | 30–34 | 5,430 | 59.7 | 74.2 | 11.9 | 13.9 | 19.5 |
| M | 45–49 | 4,893 | 53.8 | 69.3 | 14.2 | 16.5 | 22.4 |
| M | 60–65 | 6,944 | 43.9 | 56.6 | 15.9 | 27.6 | 22.4 |

**Onset and initiation**

- **`OH_2` ("first time ever drank") is not usable for incidence.** Among respondents who say their first drink was within
  the last 12 months, 88.5% (2012, 1,602/1,811) to 94.6% (2024, 1,338/1,415) report an onset age (`OH_3`) below their
  current age minus 1. The item behaves like "last time" (`out/enpg_oh2_first_time_validity.csv`). This explains the
  impossible 20–60%/year "initiation" rates for ages 30–65 in `out/enpg_targets_wave_sex_agegroup.csv` (variable `init12`).
  **Do not use `init12` as a target.**
- **`OH_3` (onset age).** Median 17 (men) and 18 (women) in every wave. Onset after age 25: men 1.8–2.7%, women 7.0–9.2%
  of ever-drinkers with a known onset age (`out/enpg_onset_age_quantiles.csv`). Onset age is missing for 96–688
  ever-drinkers per wave (`out/enpg_onset_missing_audit.csv`).
- **Retrospective life-table hazard** (pooled, respondents older than a, `out/enpg_retrospective_onset_hazard.csv`). The
  hazard peaks at 18 (men 0.335, women 0.217). It is 1.6–2.5%/year at 26–29 and ≤ 0.7%/year from 31 on, except at heaped
  ages (women 0.130 at 25, 0.091 at 30, 0.032 at 35, 0.041 at 40). The never-at-age curve flattens at about 15% (men) and 28% (women) from age 30. Initiation is
  essentially over by 25.
- **Retrospective never at 15 is implausibly high.** Recent cohorts give 67–79% never by 15
  (`out/enpg_retrospective_ever_by_age_cohort.csv`), while the cross-section shows 48–49% never at 15–17. Retrospective
  onset ages appear to be telescoped upward. Calibrate entry from the cross-section, not from `OH_3`.
- **Pseudo-cohorts show wave effects in "never"** (`out/enpg_pseudocohort_never.csv`, cohort cells n ≈ 600–1,700). For
  women born 1975–79 the series is 24.5, 17.2, 16.2, 23.4, 16.9, 18.8, **31.5%** (2012→2024). For men born 1970–74 it is
  14.9 … 14.1, **25.8%**. An absorbing "ever" cannot rise, and these jumps far exceed the design SEs of 1–2 pp. 2012 and
  2024 carry wave-level effects of +7 to +15 pp (questionnaire, mode or fieldwork; cause not verified). **Use 2014–2022 for
  never/former validation and treat 2012/2024 as sensitivity.**

## 4. Latent-model simulation grid (no microdata)

**Set-up** (`p4_grid.py`). One synthetic cohort per sex, n = 100,000, enters at 15 and is followed to 65. The latent process
is simulated monthly with phi_m = phi^(1/12), so that "drank in the last 12 months" is defined. A person drinks in a month
if `Phi(z) < p30(age, sex)`, the pooled ENPG 30-day profile interpolated on the logit. The entry never share is set to the
retrospective never by 15 for cohorts born 1990–2004. Never-drinkers at entry are the non-current with the highest z.
The engine's rule (random among non-current) changes never shares by less than 2 pp. `never_annual` mimics the engine
(ever updated only at the yearly snapshot). Margin self-check: |simulated − target 30-day| ≤ 0.3 pp.

**Pure trait + AR(1): the main cells** (% for ages 30–34 / 45–49 / 60–65; full table in `out/p4_grid.csv`; verdicts in
`out/p4d_compatibility.csv`)

| lambda, phi | r(1 y) | EPS 50+ Δ | Men never | Men former > 12 m | Women never | Women former > 12 m | Men / women P(not 30 d \| 12 m), 30–34 |
|---|---:|---:|---|---|---|---|---|
| **ENPG target** | — | — | 11.9 / 14.2 / 15.9 | 13.9 / 16.5 / 27.6 | 18.9 / 22.5 / 31.6 | 21.0 / 19.0 / 27.2 | 19.5 / 30.3 |
| 0, 0.8 (engine) | 0.80 | 62.1 | 1.1 / 0.0 / 0.0 | 23.9 / 29.7 / 37.9 | 3.7 / 0.3 / 0.0 | 37.3 / 43.9 / 56.9 | 20.1 / 28.2 |
| 0.45, 0.68 (EPS fit) | 0.82 | 0.0 | 3.7 / 1.2 / 0.8 | 21.7 / 28.8 / 37.8 | 9.1 / 4.2 / 2.9 | 32.5 / 40.4 / 54.5 | **19.5 / 27.3** |
| 0.45, 0.70 | 0.84 | 0.2 | 4.1 / 1.4 / 0.9 | 21.9 / 29.2 / 38.2 | 9.7 / 4.6 / 3.2 | 32.4 / 40.5 / 54.8 | 18.9 / 26.6 |
| 0.30, 0.80 | 0.86 | 2.1 | 4.2 / 1.0 / 0.4 | 23.1 / 31.1 / 40.1 | 10.0 / 3.7 / 2.1 | 33.5 / 43.0 / 57.3 | 17.5 / 24.8 |
| 0.60, 0.90 | 0.96 | 332.6 | 17.0 / 10.5 / 8.3 | 16.1 / 27.5 / 38.7 | 29.0 / 20.7 / 17.5 | 21.1 / 32.3 / 47.7 | 10.4 / 15.0 |

**Compatible cells: 0 of 18.** The criteria were EPS Δ ≤ 5.99 for both 50+ and 18+, plus never and former > 12 m within
±5 pp in all three bands. The closest cell, (0.6, 0.9), is still 7–14 pp short on never, and EPS rejects it (Δ = 333 against 50+). Former > 12 m
is too high in every cell (largest band deviation 20–33 pp): ever-drinkers' non-drinking spells come out too long.

**The intermittency proxy independently supports r(1 y) ≈ 0.8.** For men the EPS-fit cell gives 19.5 / 22.3 against ENPG
19.5 / 22.4. For women it gives 27.3 / 28.4 against 30.3 / 31.7. This proxy assumes that the annual latent process also
runs at monthly resolution (continuous-time OU), which is a strong assumption; treat it as consistent with the evidence,
not as identifying.

**Mover–stayer.** A share s never drinks. Movers get the threshold `Phi^-1(p/(1-s))`, so margins stay intact
(`p4b_mover_stayer.py`). Stayers inflate the observed tetrachoric correlation. The movers' parameters were therefore
refitted to EPS through the exact mixture correlation: `P11 = (1-s) Phi2(t0', t1'; r_m)`, then inverted to tetrachoric
(`out/p4b_eps_fit_mover_stayer.csv`). Cross-check: s = 0 returns (0.45, 0.68).

| s (50+ panel) | lambda_m | phi_m | WLS obj | Pure AR(1) for movers, best obj | Engine (0, 0.8) obj |
|---:|---:|---:|---:|---:|---:|
| 0 | 0.45 | 0.68 | 0.48 | 7.79 | 62.5 |
| 0.10 | 0.39 | 0.68 | 0.68 | 7.04 | 33.8 |
| **0.20** | **0.32** | **0.66** | 1.01 | 5.84 | 11.7 |
| 0.30 | 0.20 | 0.66 | 1.66 | 4.05 | 5.2 |

The ENPG never share at 45–65 pooled over sexes is about 0.20, matching an s near 0.20 for the EPS 50+ panel. At s = 0.20
the joint 95% region for movers is lambda_m 0–0.44 and phi_m 0.40–0.84 (`out/p4f_region_s020.csv`). Once stayers are
explicit, a trait among movers is only weakly favoured over pure AR(1): Δ = 4.7 at phi = 0.84. The real gain comes from
the stayers.

With s matched to each band's own never share (cohort-specific), men with s = 0.14/0.15 and women with s = 0.21/0.30 reach
never 14.2 / 15.2 / 21.6 / 30.4 against targets 14.2 / 15.9 / 22.5 / 31.6. Former > 12 m reaches 18.1 / 24.9 / 24.6 / 27.8
against 16.5 / 27.6 / 19.0 / 27.2 (`out/p4e_cohort_specific_stayer.csv`). Intermittency is 3–5 pp low.

**Remaining gap at ages 18–24.** With either entry rule the model keeps 5–15 pp more never-drinkers than ENPG: men 18–20 are
33–35% in the model against 22.8% in ENPG (`out/p4c_young_never*.csv`). Initiation in the data is faster than a persistent
latent crossing allows. An explicit initiation hazard for not-yet-initiated movers, calibrated to cross-sectional never
by single age, belongs to a later version, not to Monday.

## 5. The real engine with the change (scratch prototype, one seed, n_sim 25,000, 2012–2024)

`p5_engine_proto.R` runs cells `ms-survey-inputs`, `ms-demography-inputs` (DEIS parquet counts via python),
`ms-calibration-functions` and `ms-annual-engine` verbatim, followed by a modified copy of the loop:

- `z_current = sqrt(trait_share) u + sqrt(1-trait_share) a`, with `a <- ar_phi a + sqrt(1-ar_phi^2) e`.
- Stayers drawn at entry. Every never-drinker aged 30+ is a stayer (s = never_cell). Ages 15–29 get s = pooled ENPG never
  at 25–29 (12.1% men, 17.7% women).
- Movers' threshold is `p_current / (1 - stayer share of the cell)`. Fresh movers' `ever` is drawn so that each cell's
  never share matches.

`z_amount` and `z_hed` keep rho = 0.8 so that the participation effect is isolated.

| Run | Annual switching | Current 2024 | Never 2024 | Former 2024 | Never, 2014–22 cells: mean \|dev\| (share ≤ 5 pp) | Former, 2014–22 cells: mean \|dev\| (share ≤ 5 pp) | EPS WLS 50–57 / 18–49 |
|---|---:|---:|---:|---:|---|---|---|
| Verbatim engine, rho 0.8 | 19.9% | 36.3% | 6.3% | 57.5% | — | — | — |
| Prototype, trait 0, phi 0.8 (regression) | 19.9% | 36.4% | 6.3% | 57.3% | 9.5 pp (18%) | 9.4 pp (20%) | 55.3 / 81.0 |
| Trait 0.45, phi 0.68, no stayers | 18.7% | 36.7% | 8.1% | 55.2% | 8.4 pp (20%) | 8.1 pp (28%) | 2.0 / 5.8 |
| AR(1) 0.8 + stayers | 16.8% | 36.2% | 17.4% | 46.4% | 2.8 pp (90%) | 2.9 pp (85%) | 3.2 / 9.8 |
| **Trait 0.32, phi 0.66 + stayers** | 17.9% | 36.4% | **17.4%** | **46.2%** | **2.8 pp (90%)** | **2.9 pp (85%)** | **2.3 / 1.7** |

Sources: `out/p5_engine_proto_2024.csv`, `out/p5b_engine_vs_enpg_summary.csv` (40 wave × sex × age cells), and
`out/p5_engine_eps_wls.csv`. The last file holds tetrachoric correlations computed inside the simulated panel for status
2012→2016, 2016→2020 and 2012→2020, compared with EPS 50+ and with EPS 18–49 re-derived from microdata.

For the central run, the in-engine correlations at 50–57 are 0.606 / 0.610 / 0.519, against EPS 0.566 / 0.588 / 0.478.
All three fall within the EPS CIs. Against ENPG 2024 the stayer runs still miss never by −7.6 pp and former by +7.3 pp
(the 2012 and 2024 cells), because ENPG's never share rises in 2024, which an absorbing state cannot reproduce. The
current-drinking margin is unchanged (36.2–36.7% in every run).

## 6. Recommendation

**Structure for `z_current`** (names follow the handoff, `codex_handoff_adam_rr_full_override_caveman.md` line ~8100:
`trait_share`, `ar_phi`):

1. **`stayer`** (lifetime abstainer, absorbing). For the initial population, every observed never-drinker aged 25+ is a
   stayer. For ages 15–24, and for entrants at 15, the stayer share is s(sex) = pooled 2014–2022 ENPG never at 25–29
   (≈ 12% men, 18% women; the 2012–2024 pooled values are 12.1 / 17.7%). The flag is fixed for life.
2. **Movers**: `z = sqrt(trait_share) u + sqrt(1-trait_share) a_t`, `a_t = ar_phi a_{t-1} + sqrt(1-ar_phi^2) e_t`. Drinking
   if `pnorm(z) < p_cell / (1 - s_cell)`. Assert the movers' threshold is below 1.
3. **Former** = ever & !current, as now, but defined only among movers. The RR split between former and never now has a
   defensible denominator.

| Set | trait_share | ar_phi | stayer | Use |
|---|---:|---:|---|---|
| **Central** | **0.32** | **0.66** | on (ENPG never) | main runs |
| Low trait (ridge end) | 0.12 | 0.80 | on | sensitivity, Δ 2.4 |
| High trait (ridge end) | 0.40 | 0.52 | on | sensitivity, Δ 1.3 |
| Stayer ±25% | refit 0.36 / 0.26 | 0.67 | s × 0.75 / × 1.25 | sensitivity |
| No stayers, EPS-only fit | 0.45 | 0.68 | off | shows the structural effect |
| Legacy | 0 | 0.80 | off | comparability only: rejected by EPS (Δ 62) and ENPG (never 6% vs 16–21%) |

Ridge-end Δ values come from `out/p4f_region_s020.csv` (s = 0.20).

**`z_amount`.** EPS g/day among people drinking at both interviews gives normal-scores (copula) correlations of 0.326
(0.238–0.414), 0.387 (0.319–0.453) and 0.377 (0.308–0.465) at 3.7 / 4.0 / 7.7 years (All 18+, n = 764 / 686 / 659, PSU
bootstrap; `out/p2b_amount_hiq_persistence.csv`). There is no decay. The trait + AR(1) fit gives lambda_a ≈ 0.37 with phi_a
at its boundary near 0. Pure AR(1) is rejected (obj 28.1 vs. 1.23; `out/p2b_amount_trait_ar1_fit.csv`). EPS volume is
crude (frequency × typical glasses × 12 g), so true persistence is higher. **Recommend `z_amount`: trait_share_a = 0.40
(sensitivity 0.30 / 0.60), ar_phi_a = 0.5 (sensitivity 0 / 0.8).** The current rho = 0.8 implies 0.44 / 0.41 / 0.18:
too much medium-term and too little long-term memory. The cross-correlation between the u's of participation and
amount is not estimated; keep them independent, as now, and flag it.

**`z_hed`.** EPS has no HED item. The proxy is a typical occasion of 5+ (men) or 4+ (women) glasses of any beverage,
among people drinking at both interviews. Its tetrachoric correlations are 0.416 / 0.478 / 0.373 (n = 881 / 782 / 708).
The proxy also carries amount persistence, which the engine already passes through g/day. **Recommend trait_share_h = 0.30
(sensitivity 0.15–0.45), ar_phi_h = 0.5.** Persistence does not change the HED margin, so item 2's −4.5 pp bias must be
fixed in the assignment (logistic on `log1p(gpd)` applied to Gamma-simulated g/day) or in the indicator definition,
not here. I read this in `ms-annual-engine` lines 28–29 and 125–126; I did not test it.

The category file `category_transitions_50plus.csv` mixes participation with a frequency split (occasional vs. moderate).
A polychoric correlation on it would conflate `z_current` with `z_amount`, so the microdata copula above replaces it.

## 7. Definition of done for item 1 (each check can fail)

1. **Regression.** trait_share = 0 with stayers off reproduces the current engine's margins and never/former within
   Monte Carlo SE on the same seeds. The prototype gave 6.3 / 57.3% vs. 6.3 / 57.5%.
2. **Margins.** The simulated 30-day prevalence by wave × sex × age group is unchanged against the legacy run (|Δ| < 2 MC SD).
3. **EPS.** Status correlations from a simulated panel (ages 50–57 at t, lags 4 and 8) give a WLS objective ≤ 5.99 against
   the published same-people correlations, and the same holds for 18–49. The diagnostic r(8) > r(4)² must hold.
4. **ENPG never/former** (2014–2022, 40 wave × sex × age cells): mean |deviation| ≤ 3 pp and ≥ 80% of cells within ±5 pp,
   for never and for "former any" (= engine former). The 2012/2024 deviations are reported separately as wave effects.
5. **Absorbing check.** Within simulated birth cohorts, the never share falls by ≤ 2 pp per decade after age 25.
6. **Documentation.** Each parameter's provenance (this file and its `out/` CSVs), the conditioning (survivors,
   respondents, F13 without a reference period, no ages < 18), and the sensitivity table above, each run through to
   never/former 2024 **and** to the Monday outputs (expected and averted deaths). Persistence matters for former-drinker
   RRs and for how fast benefits appear.

Later work, not needed for Monday: an initiation hazard for ages 15–24, a stayer share by birth cohort (pseudo-cohort
plateau), a monthly or "years since last drink" state if former > 12 m is needed as an RR category, and >65 using EPS VIII.

## 8. Scripts and outputs (all under `audit/`)

| Script | What it does | Runtime |
|---|---|---|
| `fit_lib.R` | Model, WLS, two-lag solver, switching helper | — |
| `p1_fit_csv.R` | Step 1 on the published CSVs: fit, profile, parametric bootstrap, full-pair fit | 2.0 min |
| `p1c_reliability_transitions.R` | Reliability sensitivity; 1-year transitions for candidate sets | <0.1 min |
| `p2_eps_microdata.R` | EPS cells re-run (verbatim functions), reproduction check, age/sex triples, PSU bootstrap | 1.4 min |
| `p2b_eps_amount.R` | g/day copula and high-typical-quantity persistence | 0.1 min |
| `p2c_pairs_strata.R` | Pair-based lambda/phi by age × sex × education | <0.1 min |
| `p3_enpg_targets.R` | ENPG targets, OH_2 validity, onset hazard, pseudo-cohorts | 1.8 min |
| `p4_grid.py`, `p4b_mover_stayer.py`, `p4c_young.py`, `p4d_compat.py`, `p4e_cohort_s.py`, `p4f_sens_sets.py` | Latent and mover–stayer simulations, compatibility | ~4 min total |
| `p5_engine_proto.R`, `p5b_compare.py` | Verbatim engine plus scratch prototype; comparison with ENPG and EPS | 0.3 min |

The notebook cell sources used are in `audit/nbsrc/` (extracted with json, unchanged). No decrypted microdata were written
outside R's `tempdir()`. `out/deis_2012_2023_counts_15_65.csv` holds only year × sex × age death counts.

**Not done or not checked.** A single seed for the engine prototype, so there are no MC intervals there. ENPG targets were
not reconciled with published SENDA figures for never/former. The cause of the 2012/2024 never jumps was not
investigated. Reliability and wave-specific measurement were not modelled jointly with lambda/phi. EPS attrition was not
modelled beyond the official panel weights. The stayer rule uses all-wave pooled ENPG never in the prototype; the
2014–2022 pooling recommended above was not run.
