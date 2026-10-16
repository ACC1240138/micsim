# EPS transition notebook: critical review

This review concerns the revised Spanish and English notebooks and their shared
source, `eps_markov_core.R`. The prior notebook and outputs were backed up before
replacement. The analysis uses real EPS VI, in-person VII and VIII records.

## Findings addressed

| Finding | Change and evidence |
|---|---|
| Available sampling design was omitted from transition uncertainty. | Published `cluster_ID` and `strata_ID` are retained. A common person master contains 7,800 people, 111 PSUs and 33 strata. Design-code agreement is checked across published weight files. VI's weights-only placeholder design is discarded. |
| Repeated pairs could be treated as independent. | Each person's complete trajectory receives one replicate multiplier. PSU-level JKn preserves all pairs together. Markov conditional-history assumptions do not imply independence of overlapping pairs. |
| Official longitudinal weighting could be followed by duplicate attrition correction. | VI→VII uses its official longitudinal weight plus item/link-validity IPW. VII→VIII uses VII cross-sectional weights plus follow-up/item IPW. The three-wave official panel weight is not mislabelled as a VII→VIII weight. |
| Uncertainty from fitted IPW was omitted. | Primary JKn and the separate person bootstrap with 1,000 replicates refit IPW, clipping and outcome models. Period mixture masses remain fixed at the original analytic pair counts. |
| Singleton strata require an explicit convention. | JKn uses `survey.lonely.psu="adjust"`, with original-design degrees of freedom for t intervals. The `certainty` convention is a descriptive sensitivity, not an assertion about selection probabilities. There are 32 singleton strata; the original design has 78 degrees of freedom, versus 110 for the adjusted replicate design. |
| JKn replicates cannot be interpreted as bootstrap draws. | Variances use the supplied scale/rscales and full-estimate centring. The diagonal calculation is checked against `survey::svrVar`. Interior probabilities use a logit transform, with bounded normal limits at exact 0/1. Failed fits stop inference rather than being silently dropped. |
| Clipping a tiny probability before the logit transformation could move its interval above the estimate. | Exact interior centres are retained; only derivative underflow is guarded. Exact 0/1 boundaries use bounded normal limits. Tests include 1e-16 and exact boundaries; every available interval must contain its point estimate. |
| CV used previously fitted IPW and reused tuning decisions. | People remain in one outer fold; IPW and clipping are learned in training. Matrix shrinkage is tuned in inner folds. Five outer folds are repeated three times. |
| Family comparisons used different information. | Main parametric comparators share origin category, prior grams, sex, age, period and education. Two-part models share participation. The literal JRT-style model is labelled a separate specification. |
| Weight scale could change Gamma/lognormal dispersion. | Dispersion uses normalized weights. Multiplying weights by ten is tested to leave predicted probabilities unchanged. |
| Category predictions could be confused with a classified predicted mean. | Gamma/lognormal integrate their positive distributions between the sex-specific C1–C4 cutpoints, then combine these probabilities with participation. |
| Missing classes and coefficient ordering could corrupt replication. | Class names and coefficient names are aligned explicitly. Unsupported origin rows receive NA intervals and an informative status. No missing FD class is recoded as N0. |
| An ordinal transport fit had nonfinite automatic starting values. | A failed/nonconverged ordinal fit restarts with zero slopes and ordered weighted-marginal thresholds. The model and objective are unchanged; convergence and finite coefficients remain required. All transport directions and remaining analysis functions passed a real-data check before restarting both full runs. |
| A person lost known drinking history by VIII. | Previous-use flags propagate through compatible links. The one erroneous FD→N0 destination is corrected. Pair counts and origin categories are unchanged. Structural history checks are executed. |
| N0 was described as initiation/lifetime abstention. | N0 denotes current non-consumption with unresolved previous use. Strict four-year abstention is a separate past-only proxy. No eligible origins exist in the present adjacent pairs under that strict rule. |
| The alcohol reference period and Calvo implementation were misstated. | F14 explicitly refers to the last month; F13 has no explicit period. Calvo's EPS supplement uses a maximum across beverages. Summation here is the stated ENPG/JRT-oriented adaptation, not an exact Calvo replication. |
| Tiny score differences were interpreted without their magnitude. | Paired score differences have PSU/stratum-based conditional intervals, geometric-probability gains and mean changes in category probabilities. No arbitrary clinical equivalence threshold is introduced. |
| Education and prior history needed adjusted comparisons. | Education stratification, ordinal additive education and interactions are compared. Earlier-history prediction is tested after current state/grams, sex, age and education, including the interaction specification. |
| Rank matching compared different weights/margins. | Observed and rank-coupled transitions use the same people, baseline groups, weights and endpoint margins. Exact agreement of margins is asserted. |
| Reverse transport could leak the same person across periods. | Forward and reverse-period evaluation exclude all test IDs from training, restrict common age support and report unsupported FD origins. EPS V alcohol validation is not claimed. |
| Annualization can imply more identification than the data support. | One pooled continuous-time generator is fitted, with nonnegative rates and an explicit penalty. Starting values, penalty sensitivity, stochasticity and composition are checked. The generator is refitted in JKn replicas. |

## Interpretations that remain conditional

- **Design uncertainty:** the available design is used, but first-stage
  probabilities, FPC and uncertainty in official weight construction are not
  reconstructed. Singleton adjustment cannot recover that missing information.
  Kish ESS is a weight-dispersion diagnostic, not an additional variance factor.
- **Prediction comparisons:** paired score intervals condition on fitted
  out-of-fold predictions. They do not include complete retraining uncertainty
  or provide simultaneous superiority tests against every candidate.
- **Model selection:** transition intervals condition on the chosen model,
  shrinkage and annual-generator penalty. They do not average over selection.
- **Annual instability found in the final run:** at the primary penalty,
  alternative starts change an annual probability by as much as 10.5 percentage
  points; the combined penalty/start grid reaches 33.8 points. Objective values
  are close despite different probabilities. Primary annual intervals condition
  on one initialization and penalty and do not cover this identification and
  optimization ambiguity. Annualization remains exploratory; between-wave
  predictions are the primary deliverable.
- **Selection:** IPW requires sufficiently measured predictors of observation
  and adequate support. Known VIII deaths are removed; survival remains
  incompletely known among other losses. Missing outcomes are not converted to
  abstention.
- **Sparse tails:** C2/C3/C4 have 141/69/29 origin pairs. Parametric pooling can
  stabilize prediction; it cannot establish rare transitions without assumptions.
  A narrow interval after strong pooling is not evidence of abundant local data.
- **Annual history:** generator fitting compares N0+FD with observed NC. It can
  represent an unobserved N0→drinking→FD path. Annual FD therefore includes
  model-imputed previous use; survey-wave FD requires observed previous use.
  Their decomposition is not identified by collapsed endpoint categories.
- **Transport:** reverse-period evaluation still predicts forward within each
  pair. It is not reconstruction of an earlier wave and is not independent
  external validation.
- **HED:** the 5+/4+ typical-quantity signal is not an observed ENPG 30-day episode.
  Its descriptive regression uses survey design but conditions on fitted IPW.
- **Simulation:** ENPG calibration, independent external validation, and a full
  age-changing simulation remain future work. These notebooks provide candidate
  transition components, not a validated policy engine.

## Sources and reproducible evidence

- [Calvo 2020: main article](https://pmc.ncbi.nlm.nih.gov/articles/PMC7585691/)
  and [Table S2 in the supplement](https://ars.els-cdn.com/content/image/1-s2.0-S0376871620303847-mmc1.docx).
- [Calvo 2021: history definitions](https://pmc.ncbi.nlm.nih.gov/articles/PMC8131222/).
- EPS design: `_eps/notes/34_Informe Técnico EPS VIII Ronda.txt` and
  `_eps/notes/16_EPS - Informe Metodologico-Muestreo, Atrición, Factores, Errores Muestrales.txt`.
- EPS V: all 21 supplied database headers/labels were audited without an alcohol
  item match. `_eps/docs/2012/Dossier_Resultados_VRondaEPS2012.pdf`, p. 23,
  separately discourages statistical inference from that round. The supplied
  official RAR contains documentation, not additional alcohol observations.
- JRT: `jrt/simulacion/Alcohol Transitions FINAL.R`.
- [JKn conversion](https://r-survey.r-forge.r-project.org/pkgdown/docs/reference/as.svrepdesign.html)
  and [replicate variance](https://r-survey.r-forge.r-project.org/pkgdown/docs/reference/svrVar.html).
- Results, original variable dictionary, input hashes and fit audits:
  `eps_markov_outputs/`. External fresh-session verification is recorded in
  `eps_markov_outputs/reproducibility_report.md` and `reproducibility_check.csv`.

Independent source review found no remaining blocking calculation error. The
analytic matrix-exponential gradient was also compared independently with
central differences and `scipy.linalg.expm`: maximum synthetic gradient error
was below 1.4e-11. These synthetic checks supplement, rather than replace, the
real-data runs and their recorded assertions.

## Final execution and presentation checks

Both fresh R sessions completed all 11 code cells, 111 JKn fits and 1,000
whole-person bootstrap fits without errors. All 47 recorded real-data checks
passed. The two runs produced 42 byte-identical CSVs containing 7,246 aggregate
rows. Computation took 21.27 minutes in Spanish and 20.88 minutes in English.
The verifier additionally checks class probabilities, interval bounds,
unsupported rows, source hashes and successful replicate counts.

Warnings remain visible in `fit_warnings.csv`: 153 numerical 0/1-probability
warnings, 412 noninteger-binomial warnings from fractional weights, and three
successful ordinal restarts. Finite converged fits do not rule out sparse-data
separation; the rare-state limitations remain. No failed replica was discarded.

Both HTML files contain ten embedded figures and MathML equations without
external asset dependencies. Selected final matrices, the rank-matching plot
and the paired-score intervals were visually inspected, in addition to the
diagrams checked during preparation. `render_validation.json` records the
artifact checks. The annual instability described above remains an unresolved
scientific limitation, explicitly distinguished from successful computation.
