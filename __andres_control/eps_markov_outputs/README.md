# EPS transition outputs

These are aggregate results from the executed Spanish and English notebooks.
The analysis uses EPS VI, in-person VII and VIII; encrypted source data are read
through `_tools/acc_data.R`. No person-level analysis dataset is exported here.

## Main results

| Files | Purpose |
|---|---|
| `cohort.csv`, `origin_counts.csv`, `row_counts_state0_by_stratum.csv` | Pair counts and origin support, including empty analytical cells. |
| `variable_dictionary.csv`, `harmonization_audit.csv`, `abstention_history_audit.csv` | Original item codes, response conversion and past-only history definitions. |
| `design_audit.csv`, `design_availability.csv`, `ipw_audit.csv` | Published sampling design, weight purpose and additional response adjustment. |
| `cv_scores.csv`, `CV_paired_comparisons.csv` | Person-blocked prediction scores and paired, design-aware conditional comparisons. |
| `transition_matrices_design_CI.csv` | Primary interval matrices with JKn uncertainty; IPW and models are refitted. |
| `engine_coefficients_design_CI.csv` | Gamma/lognormal parameters and design-based replication uncertainty. |
| `transition_matrices_person_CI.csv`, `bootstrap_stability.csv` | Separate whole-person bootstrap sensitivity, with 1,000 refits. |
| `transport_summary.csv`, `transport_support.csv` | Forward and reverse-period prediction, excluding shared test people. |
| `adjusted_history_validation.csv`, `chapman_kolmogorov_descriptive.csv` | Adjusted earlier-history comparison and a separate marginal composition diagnostic. |
| `rank_matching_vs_panel.csv` | Observed panel versus rank coupling with identical margins and weights. |
| `annual_pooled_matrices_design_CI.csv`, `annual_generator_sensitivity.csv` | Model-derived annual probabilities and generator sensitivity. |
| `conversion_sensitivity.csv`, `weight_refit_sensitivity.csv` | Refitted 12/15.7 g-per-drink and weighting alternatives. |
| `typical_quantity_signal_*.csv` | Auxiliary typical-quantity signal; not validated 30-day HED. |

## Checks and interpretation

`reproducibility_report.md` records the result of two fresh executions.
`reproducibility_check.csv` compares their exported CSV hashes. R assertions and
fit outcomes are recorded in `analysis_checks.csv`, `replicate_fit_audit.csv`,
`person_bootstrap_audit.csv` and `fit_warnings.csv`. Input hashes and environment
versions appear in `input_manifest.csv` and `session_info.txt`.

Primary uncertainty retains published PSUs/strata and all pairs of each person.
Person-bootstrap intervals are a separate sensitivity, not an additional
variance multiplier. NA intervals identify unsupported rows; structural zeros
are reported separately. Annual matrices are model-derived and require ENPG
calibration and independent validation before policy use.

Spanish figures are in `es/`; English figures are in `en/`. Each has PNG and PDF
versions. Root-level PNG copies preserve the existing figure locations.

The computation is embedded in both notebooks and generated from
`../eps_markov_core.R`. Reproduction commands are in
`reproducibility_report.md`; the critical review is `../eps_markov_review.md`.
