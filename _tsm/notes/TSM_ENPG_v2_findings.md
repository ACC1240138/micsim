# TSM ENPG version 2: findings

Open the [English HTML](TSM_ENPG_v2_EN.html) or the [executed notebook](TSM_ENPG_v2_EN.ipynb).

- **Sample:** 4,175 consecutive-wave pairs from 1,934 people; 7,337 eligible origin opportunities. Age 18–65 at origin; the study's broader 15–65 target remains explicit.
- **States:** ENPG cat1–cat4, observed former drinking (`FD`) and non-drinking without a known previous positive report (`ND_unknown`). This does not identify lifetime abstinence.
- **Conversion:** Calvo's frequency × quantity / 7, then 12 g/drink as primary and 15.7 g separately. No APC adjustment. Raw codes and assumptions remain explicit.
- **HED:** the ENPG target is 5+/4+. TSM supports a labelled proxy combining its 6+ item and typical-quantity bands; exact past-30-day ENPG HED is not identifiable.
- **JRT:** its ordinal formula uses previous category, age, sex and their pairwise interactions. HED is retained in its data but is **not** a regression predictor. The new ordinal comparator uses a shared additive TSM predictor set, including education and HED proxy, rather than claiming a literal replication.

## Held-out category prediction

Five folds hold out entire people. All models use the same held-out observations and evaluation weights. Lower Brier is better.

| Grams/drink | Empirical matrix | Gamma | Lognormal | Ordinal |
|---|---:|---:|---:|---:|
| 12 | 0.35791 | 0.35014 | 0.35001 | 0.34864 |
| 15.7 | 0.36647 | 0.36018 | 0.36059 | 0.36079 |

These small differences do not establish a definitive winner. Gamma and lognormal remain useful candidates. Category probabilities integrate their full predicted distributions; classifying only a predicted mean would discard this information.

Compare models within each row. A score difference between 12 and 15.7 g cannot choose the correct conversion because the outcome labels change.

Raw log loss is infinite for the empirical matrix in both conversions and for ordinal at 15.7 g. The latter occurs because the only cat4 outcome is held out from a training fold with no cat4. Raw and clipped scores are both disclosed; the numerical floor does not change predictions or Brier.

## Where information is insufficient

At 12 g there are only **15 cat2 and 3 cat3 destination pairs**, and **no cat4**. Cat4 is impossible under the primary response-band reconstruction: the maximum is 94.29 g/day. At 15.7 g the counts are 19, 7 and 1. A good overall score cannot validate these sparse high-consumption transitions. Parametric tail probabilities are extrapolations conditional on the measurement and distributional assumptions.

Education enters the pooled regression models. Education-specific matrices average predictions from those fits, retaining the full sample for estimation. These descriptive differences also reflect the observed covariate composition of each education group.

## Weights and uncertainty

Origin `Fact_Exp` is combined with fitted inverse follow-up probability. Both uncertainty branches completed **500/500 successful refits**, including IPW: pairs and whole people. Full model bootstrap intervals cover the primary 12 g scenario; 15.7 g has point estimates, CV and empirical joint-IPW intervals. No UPM or strata were inferred and no extra Kish multiplier was applied.

The strongest measurement limitation remains the **unverified recall window**. Calibration to ENPG and independent Chilean validation remain future work.

## Files and reproducibility

- [Category scores](outputs_tsm_enpg_v2/CV_category_metrics.csv), [per-class recall](outputs_tsm_enpg_v2/CV_class_recall_precision.csv), and [support counts](outputs_tsm_enpg_v2/category_support.csv).
- [All pooled and education matrices](outputs_tsm_enpg_v2/predicted_transition_matrices.csv).
- [Person-resampled intervals](outputs_tsm_enpg_v2/model_CI_person_12g.csv) and [pair-resampled intervals](outputs_tsm_enpg_v2/model_CI_pair_12g.csv).
- [Verification record](outputs_tsm_enpg_v2/delivery_verification.json): all 13 notebook code cells executed; **30 checks passed and 172 earlier files unchanged**. Equations use native MathML embedded in the HTML; all six display equations were visually checked in Chrome with networking disabled.

To reproduce from this folder: run `build_tsm_v2.py`, then `execute_tsm_v2.py` in the Python environment with `nbclient` and the existing `ir44` kernel; render with `quarto render TSM_ENPG_v2_EN.ipynb --to html --no-execute`; run `check_tsm_v2_browser.py`, then `verify_tsm_v2.py`. R helpers reuse the preserved original loader and continuous fits. Only aggregate outputs are written.
