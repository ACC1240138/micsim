# TSM R7 -> R11 direct comparison (exploratory, separate)

Aggregates only. `tsm_r7_r11_direct.R` writes the cohort, sample-size and observed-transition tables;
`tsm_r7_r11_comparators.R` writes the two-year comparator tables (`cmp_*`). Page: `../tsm_r7_r11_directo_explicado.html`.

- `cmp_two_year_comparison.csv` is the main table (observed vs EPS, JRT_reference, TSM engine, reconstructed JRT original, rank coupling; global and per sex x age). Model columns are point estimates.
- `model_two_year_predictions.csv` and `comparison_observed_vs_models.csv` are superseded: they square the pooled annual matrices (training composition, TSM C4 row treated as absorbing). They are kept only for `cmp_pooled_vs_standardised_check.csv`.
