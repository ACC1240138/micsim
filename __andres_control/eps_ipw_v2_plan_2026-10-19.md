# EPS IPW v2 (2026-10-19): attrition model with the agreed predictors, three weighting schemes, diagnostics

Decisions by the user (2026-10-19, evening): SuperLearner added to renv; macrozone and region left out; the three-scheme comparison on A and Lognormal; permission given for the copy `eps_markov_transitions_v2_EN.ipynb`. The original notebook, `eps_markov_core.R` and `eps_markov_outputs/` stay untouched (the EPS verifier checks the core hash). This is one part of the study: pragmatic scope, same deliverables as TSM v3 (notebook, HTML at the root, Spanish findings, didactic page).

## What happens to deaths and impeded (documented before building)

- **Version 1 (current notebook).** VI->VII: the official longitudinal weight exists only for people re-interviewed in person at VII, so the risk set is already "survivors re-interviewed"; deaths, impeded and phone-only follow-ups never enter it, the official weight carries the attrition adjustment, and the extra IPW corrects only missing classification and invalid links. VII->VIII: the 882 people in the VIII deceased file are removed from the risk set; the 432 people in the VIII impeded file are not removed, so they count as attrition and the IPW treats them as missing at random given covariates.
- **Version 2.** Deaths and impeded are competing exits, not attrition: they leave the risk set and the weight model in both intervals (VII deceased 516 and impeded 339 cannot enter VI->VII anyway, because they have no panel weight; VIII deceased 882 and impeded 432 are removed from VII->VIII). The attrition table reports them only as exit counts, so the denominator is transparent; the percentage followed is computed among survivors who could be followed. Phone-only VII respondents (continuidad 5,031, reentrevista 2,082) are "followed without the alcohol module" and count as missing outcome, not as exits. Mortality belongs to the microsimulation's own mortality module.

## Predictors of the attrition model (actual EPS variables)

| Construct | VI (2015) | VII presencial (2020) | VIII (2023) | Coding |
|---|---|---|---|---|
| Origin state | f13/f14/f15 (harmonized) | same | same | N0, FD, C1, C2, C3plus (C3+C4 merged in the attrition model) |
| Prior intensity | grams_day (harmonized) | same | same | log(g/day + 1) |
| Sex x age group | a8, a9 | same | same | 2 x 4 (18-29, 30-44, 45-59, 60-65) |
| Education completed | a12n/a12e/a12d (harmonized) | a12_n/a12_e/a12_d | same | three EPS levels + missing indicator |
| Housing tenure D.7 | d7 | d7 | d7 | own (1-3) vs not own; missing as its own level |
| Partner I.1 | i1 in {1, 2, 9} | i1 in {1, 2, 4} | i1 in {1, 2, 4} | with vs without partner |
| Worked last week B.2 | MODULOB_historia_laboral: ongoing episode (latest start, open end) with b2 == 1 | b2a_SO == 1 | b2a_so == 1 | working vs not |
| Smokes F.12.a | f12a == 1 | f12a == 1 | f12_a == 1 | yes vs no |
| Depressive symptoms F.69 | f69_1..f69_9 | same | same | PHQ-9 = sum(code - 1) over nine items, >= 10 vs < 10; missing if any item missing |
| Self-rated health A.10 | a10 | a10 | a10 | mala o regular (4-6) vs better |
| Macrozone / region | not in the public files (only birthplace a6a and anonymous strata/cluster ids) | same | same | **left out** |

Non-response codes (8, 9, 88, 99, 888, 999 as labelled) become missing; every binary predictor carries a "Missing" level so no row is dropped.

## Design

1. **Risk set v2.** Same origin rules as version 1 (18-65 at origin, compatible links, VI->VII restricted to official panel-weight holders, VII->VIII on the VII cross-sectional weight), minus deceased and impeded at the destination round; the v2 covariates measured at origin are merged in. The version 1 cells of the notebook keep their own risk set and outputs, so version 1 results reproduce inside the v2 notebook.
2. **Attrition table** by interval x origin state: baseline respondents, deceased, impeded, followed by phone without the alcohol module (VII), interviewed with the alcohol module, lost (not located or refused), percentage followed among survivors.
3. **Response model `ep_ipw_fit_v2`.** Per interval, outcome = alcohol module observed at destination (complete), predictors from the table, survey-weighted logistic regression with the published design (`survey::svyglm`, ids = cluster_ID, strata = strata_ID, weights = origin weight); odds ratios with design-based 95% intervals.
4. **SuperLearner (one-time pre-step).** Per interval, same outcome and predictors, `SuperLearner::SuperLearner` with family binomial, `cvControl(V = 5, stratifyCV = TRUE)`, library SL.mean, SL.glm, SL.glmnet, SL.ranger (num.trees 500, min.node.size 50; SuperLearner's wrapper does not forward max.depth), observation weights = origin weight. Reported: cross-validated risk per learner, ensemble coefficients, discrete winner. The ensemble predictions are the IPW v2 probabilities (floor 0.02, trimming at p1/p99 of the completed weight within interval, mass fixed at the observed pair count, as in version 1).
5. **Three weighting schemes:** (1) official weight only; (2) official x version 1 IPW (`ep_ipw_fit`/`ep_ipw_apply`); (3) official x IPW v2 (SuperLearner). Transition matrices for A and Lognormal (period x sex x age group, pooled sex x age, pooled all) under each scheme, with JKn design replicates (111): the version 1 IPW is refitted inside replicates as before; the SuperLearner probabilities are held fixed (intervals conditional on the weight model, disclosed). Shift table: scheme 2 minus 1 and scheme 3 minus 1 per cell, with the largest absolute shift per period and model.
6. **Diagnostics by interval and origin state** for the three schemes: standardized mean differences of every predictor between the completed, weighted sample and the full baseline risk set (target |SMD| < 0.1), Kish ESS, maximum and mean weight, share of total weight in the top 1%, number of cases at the 0.02 floor and at the p1/p99 trimming bounds.
7. **Temporal consistency.** Transport already answers whether one interval predicts the other; what is missing is observed versus predicted by interval and origin state. Added from the held-out predictions of the version 1 cross-validation: observed share, predicted share and their difference per interval x origin x destination with design-based intervals.
8. **Reproducibility.** One execution in a fresh kernel pinned to the E-cores, checks table and configuration, HTML rendered to the repository root, asset check. A second execution is not run (pragmatic scope); the verifier is not extended.

## Files

| Item | Location |
|---|---|
| Extra definitions (new functions only) | `__andres_control/eps_markov_v2_extra.R`, embedded as a cell |
| Builder | `_tools/build_eps_markov_v2_notebook.py` (copies the executed EN notebook, strips outputs, inserts the v2 cells) |
| Notebook, outputs, HTML | `__andres_control/eps_markov_transitions_v2_EN.ipynb`, `__andres_control/eps_markov_outputs_v2/`, `eps_markov_transitions_v2_EN.html` at the root |
| Findings, page | `__andres_control/hallazgos_eps_ipw_v2.md`, `__andres_control/eps_ipw_v2_explicado.html` (published artifact) |
| Packages | `SuperLearner`, `glmnet`, `ranger` added through renv, listed in `DESCRIPTION`, recorded in `renv.lock` (to be committed by the user) |

## Function and cell contract

All new code lives in `__andres_control/eps_markov_v2_extra.R` (functions only, prefixed `ep_v2_`, every cell body starts with `.t0` and ends with elapsed minutes via the builder) and uses the globals of the executed EN notebook: `eps_data`, `eps_raw`, `eps_root`, `eps_panel_weights`, `eps_phone`, `ep_W`, `ep_risk`, `ep_d`, `ep_des` (master, survey, replicate, multipliers), `ep_period_mass`, `ep_k`, `ep_fits`, `ep_cvtab`, `ep_time`, `ep_periods`, `ep_ST`, `ep_Y`, `ep_dead8`, `ep_design_map`, and the helpers `ep_save`, `ep_show`, `ep_check`, `ep_warn`, `ep_fig`, `ep_theme`, `ep_palette`, `ep_x`, `ep_wquant`, `ep_ipw_fit`, `ep_ipw_apply`, `ep_fit`, `ep_prob`, `ep_matrices`, `ep_targets`, `ep_vector`, `ep_interval`, `ep_person_mult`, `ep_age`, `ep_key`.

| Function | Returns |
|---|---|
| `ep_v2_exits()` | list `dead7`, `imped7`, `dead8`, `imped8`, `phone7` (character folio ids) read from the VII and VIII deceased (MODULO_M) and impeded (MODULO_P) files and from the VII phone files (`eps_phone`) minus the in-person ids |
| `ep_v2_covariates()` | data.frame `id`, `wave` (VI, VII_presencial, VIII), `own_home`, `partnered`, `working`, `smokes`, `phq9_ge10`, `health_poor` (factors with levels Yes, No, Missing) and `phq9_score`; also writes `v2_covariate_audit.csv` (per wave: n, missing per covariate, share Yes) |
| `ep_v2_attrition(W = ep_W, exits, cov)` | data.frame per period x state5 (N0, FD, C1, C2, C3plus, All): `baseline`, `deceased`, `impeded`, `phone_only`, `completed`, `lost`, `pct_followed_of_survivors`; baseline = origin respondents 18-65 under the period's weight rule (VI->VII: panel-weight holders, as version 1; VII->VIII: VII in-person respondents) |
| `ep_v2_make_risk(W = ep_W, exits, cov)` | risk set like `ep_make_risk(W)` with deceased and impeded at the destination removed in both periods, the covariates at origin merged, `state5` (factor N0, FD, C1, C2, C3plus), `lg0`, and the version 1 columns (`complete`, `y1`, `wbase`, `psu`, `strata`, `period`, `mult`); period masses `ep_v2_period_mass` set by the cell |
| `ep_v2_formula` | `~ state5 + lg0 + sex * age_group + edu_num + edu_missing + own_home + partnered + working + smokes + phq9_ge10 + health_poor` |
| `ep_v2_glm(r)` | per period `survey::svyglm(complete ~ ...)` with ids = ~psu, strata = ~strata, weights = ~wbase, nest = TRUE, quasibinomial; returns `odds_ratios` (period, term, OR, lower, upper, se, n, n_complete) and `prob` (fitted probabilities aligned with r) |
| `ep_v2_superlearner(r, V = 5, seed)` | per period `SuperLearner::SuperLearner(Y = complete, X = design matrix of the formula without intercept, family = binomial(), obsWeights = wbase, cvControl = list(V = V, stratifyCV = TRUE, shuffle = TRUE), SL.library = c("SL.mean", "SL.glm", "SL.glmnet", "SL.ranger_v2"))` where `SL.ranger_v2` is `SuperLearner::create.Learner("SL.ranger", params = list(num.trees = 500, min.node.size = 50))`; returns `risks` (period, learner, cv_risk, coef, discrete_winner), `prob` (ensemble predictions aligned with r), `library` |
| `ep_v2_ipw_apply(r, prob, label)` | completed rows with `p_obs` (floored at 0.02), `untrimmed`, `wcorrected` (clipped at the p1/p99 weighted quantiles within period), `wn` (normalised to `ep_v2_period_mass`), flags `at_floor`, `at_lower`, `at_upper`, and `scheme = label` |
| `ep_v2_schemes(r, sl_prob)` | list of three data frames: `official` (wn = wbase normalised to the period mass over completed rows), `ipw_v1` (`ep_ipw_fit`/`ep_ipw_apply` on r), `ipw_v2_sl` (`ep_v2_ipw_apply` with the SuperLearner probabilities); writes `v2_scheme_weights_audit.csv` |
| `ep_v2_scheme_matrices(r, schemes, sl_prob, models = c("A", "Lognormal"))` | point matrices (period x sex x age, pooled sex x age, pooled All) per scheme and model and JKn intervals from `ep_des$multipliers` (official: multiplier only; ipw_v1: IPW refitted; ipw_v2_sl: probabilities fixed, caps recomputed); returns `matrices` (scheme, model, group, period, sex, age_group, from, to, n_origin, estimate, structural, support, se, lower, upper, valid_replicates, interval_status) and `shift` (per period, model, comparison: cells, mean_abs_shift, max_abs_shift, cell with the max) |
| `ep_v2_diagnostics(r, schemes)` | `smd` (scheme, period, state5 or All, covariate level, mean_baseline, mean_completed_weighted, smd) and `weights` (scheme, period, state5 or All, n_complete, ESS, mean_weight, max_weight, max_over_mean, top1_share, n_at_floor, n_at_lower, n_at_upper) |
| `ep_v2_calibration_interval(cvtab = ep_cvtab, d = ep_d, models = c("A", "Lognormal"))` | observed and predicted destination shares by period x state0 x destination with design-based intervals of the difference (`survey::svyby`), n_origin and a sparse flag |
| `ep_v2_plots()` | fig_v2_attrition, fig_v2_odds_ratios, fig_v2_scheme_shift, fig_v2_smd, fig_v2_calibration_interval |

Cell bodies in `__andres_control/eps_markov_v2_sections.R` (separated by `# @@label` lines): `eps-v2-attrition` (exits, covariates, attrition table, risk set, period masses, checks), `eps-v2-ipw` (GLM odds ratios, SuperLearner, probability summary), `eps-v2-schemes` (three schemes, matrices with JKn, shift table), `eps-v2-diagnostics` (SMD, weight diagnostics), `eps-v2-calibration-interval`, `eps-v2-reproducibility` (checks, configuration). Narrative in `__andres_control/eps_markov_v2_narrative.md` with `<!-- code:label -->` placeholders, one didactic section per cell, in English. Builder `_tools/build_eps_markov_v2_notebook.py`: copy the executed EN notebook, strip outputs and the verifier-inserted cells, retarget `here::i_am` and the title, insert `eps-v2-definitions` after `eps-shared-definitions`, append the v2 markdown and code pairs before the references cell, metadata `eps_v2_revision` with source hashes. Outputs: `v2_exits_audit`, `v2_attrition_table`, `v2_covariate_audit`, `v2_ipw_glm_odds_ratios`, `v2_superlearner_risks`, `v2_ipw_probabilities_summary`, `v2_scheme_weights_audit`, `v2_transition_matrices_schemes_design_CI`, `v2_scheme_shift_table`, `v2_balance_smd`, `v2_weight_diagnostics`, `v2_calibration_by_interval_origin`, `v2_analysis_checks`, `v2_analysis_configuration`.
