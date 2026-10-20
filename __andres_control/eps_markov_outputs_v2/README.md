# EPS transition outputs, IPW version 2

Aggregate results of `eps_markov_transitions_v2_EN.ipynb`: the version 1 cells of the EPS transition notebook, run unchanged,
plus the version 2 attrition model, SuperLearner weights, three weighting schemes and diagnostics. Encrypted source data
are read through `_tools/acc_data.R`; no person-level dataset is exported here. The version 1 tables (every file without the
`v2_` prefix) are rewritten by the version 1 cells and can be compared with `../eps_markov_outputs/`.

## Version 2 tables

| Files | Purpose |
|---|---|
| `v2_exits_audit.csv`, `v2_attrition_table.csv` | People in the VII and VIII deceased and impeded files and the VII phone-only files, and what happened to each baseline respondent by interval and origin state (deceased, impeded, phone only, interviewed with the alcohol module, lost, percentage followed among survivors). |
| `v2_covariate_audit.csv` | Per wave: answers missing per predictor and share answering yes (tenure, partner, work, smoking, PHQ-9 >= 10, poor health). |
| `v2_ipw_glm_odds_ratios.csv` | Design-based logistic response model per interval: odds ratios with 95% intervals and the number of non-zero rows per term. |
| `v2_superlearner_risks.csv`, `v2_ipw_probabilities_summary.csv` | Cross-validated risk and ensemble coefficient of each learner (V = 5, stratified), and the distribution of the GLM and SuperLearner response probabilities with floor counts. |
| `v2_scheme_weights_audit.csv` | Mass, Kish ESS, minimum probability, median and maximum weight, floor and trimming counts of the three schemes (official; official x IPW v1; official x IPW v2). |
| `v2_transition_matrices_schemes_design_CI.csv`, `v2_scheme_shift_table.csv` | Matrices of models A and Lognormal under each scheme (period x sex x age, pooled sex x age, pooled all) with JKn intervals, and the cell-by-cell shifts of each IPW scheme against the official weight. |
| `v2_balance_smd.csv`, `v2_weight_diagnostics.csv` | Standardized mean differences of every predictor level between the weighted followed sample and the baseline risk set, and weight diagnostics (ESS, max/mean, top-1% share, floor and trimming counts), by interval, origin state and overall. |
| `v2_calibration_by_interval_origin.csv` | Observed versus held-out predicted destination shares by interval, origin state and destination, with design-based intervals of the difference and a sparse flag. |
| `v2_analysis_checks.csv`, `v2_analysis_configuration.csv` | Checks executed in the notebook and the configuration (seed, SuperLearner library and tuning, floor, trimming, replicates, exit handling). |

Figures `fig_v2_*` are in `en/` (PNG and PDF). The intervals of the IPW v2 scheme hold the SuperLearner probabilities fixed
inside the replicates (conditional on the weight model); the IPW v1 scheme refits its weight model in every replicate.
The notebook was executed once in a fresh kernel; there is no second execution or external verifier for this version.
Plan: `../eps_ipw_v2_plan_2026-10-19.md`; Spanish findings: `../hallazgos_eps_ipw_v2.md`.
