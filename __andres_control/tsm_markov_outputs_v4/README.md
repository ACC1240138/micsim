# TSM v4 transition outputs

Aggregate results of `TSM_ENPG_v4_EN.ipynb`, executed on the five TSM rounds read from the encrypted bundle `_tsm/tsm.tar.xz.enc`. No person-level dataset is exported here. Since 2026-10-26 the states are N0, FD, C1, C2 and C3plus (WHO C3 and C4 merged; WHO borders without gaps) and the link tolerance is two years.

## Main results

| Files | Purpose |
|---|---|
| `cohort.csv`, `link_audit.csv`, `link_audit_strict_bounds.csv`, `origin_counts.csv`, `row_counts_state0_by_stratum.csv` | Pairs per interval, the link-compatibility audit (primary widened bounds and strict EPS bounds) and origin support. |
| `v2_regression_check.csv` | Every version 2 count reproduced before the link rule. |
| `variable_dictionary.csv`, `harmonization_audit.csv`, `education_rule_audit.csv`, `abstention_history_audit.csv`, `fd_tenure_audit.csv`, `input_manifest.csv` | Original codes, education rules, past-only history flags (chain, EPS rule, direct rule), FD by tenure and months since drinking, bundle md5. |
| `ipw_audit.csv`, `weight_scale_invariance.csv`, `weight_refit_sensitivity.csv` | Link IPW diagnostics and the four weighting scenarios. |
| `cv_scores.csv`, `CV_repeated_scores.csv`, `CV_paired_comparisons.csv`, `CV_fold_audit.csv`, `CV_inner_tuning.csv`, `full_fit_shrinkage_tuning.csv` | Person-blocked scores (5 x 3), paired person-cluster contrasts and shrinkage tuning. |
| `calibration_destination.csv`, `calibration_by_origin_cell.csv`, `model_decision_summary.csv` | Held-out calibration by destination and by origin cell. |
| `transition_matrices_person_CI.csv`, `transition_matrices_pooled_person_CI.csv`, `transition_matrices_education.csv`, `engine_coefficients_person_CI.csv`, `bootstrap_stability.csv`, `person_bootstrap_audit.csv` | Matrices by period x sex x age, pooled and by education; whole-person bootstrap intervals (1,000 replicates, IPW refitted). |
| `annual_pooled_matrices_person_CI.csv`, `annual_generator_sensitivity.csv`, `annual_interval_fits.csv` | Model-derived annual probabilities with support flags, penalty/restart sensitivity and each interval fitted alone. |
| `eps_crosscheck_annual.csv`, `eps_crosscheck_projection_*.csv` | TSM versus EPS annual staying probabilities and projections in both directions (external consistency, not validation). |
| `link_tolerance_evidence.csv` | Education disagreement by years outside the strict EPS age bounds: the data behind the two-year link tolerance. |
| `transport_*.csv`, `adjusted_history_validation.csv`, `chapman_kolmogorov_descriptive.csv`, `rank_matching_vs_panel.csv` | Leave-one-interval-out transport, earlier-history check, Chapman-Kolmogorov diagnostic and rank matching. |
| `conversion_sensitivity.csv`, `transition_matrices_15_7g.csv`, `upper_band_*.csv`, `education_sensitivity*.csv`, `link_bounds_*.csv`, `typical_quantity_signal_*.csv`, `hed6_item_by_category.csv` | Sensitivities and auxiliary signals. |
| `analysis_checks.csv`, `analysis_configuration.csv`, `fit_warnings.csv`, `session_info.txt` | Executed checks, configuration, fit warnings and environment. |

## Checks and interpretation

`reproducibility_report.md` records two fresh-kernel executions with byte-identical CSV files (`reproducibility_check.csv`) and `render_validation.json` the embedded-asset check of the HTML. Rows whose origin state has no observed pairs are reported as unobserved; rows with fewer than 30 origin pairs are flagged sparse. The annual layer and the EPS cross-check are exploratory: TSM intervals are months long and the alcohol items have no recall window, so annual staying probabilities are lower than the EPS ones by construction.

Figures are in `en/` (PNG and PDF). The computation is embedded in the notebook from `../tsm_markov_data.R` and `../tsm_markov_models.R`; the plan is `../tsm_v3_plan_2026-10-19.md`, the critical review `../tsm_v3_review.md` and the Spanish findings `../hallazgos_tsm_v3.md`.
