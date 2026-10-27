# ENPG–CASEN and APS-contact inputs

Entry points: [notebook](../enpg_casen_aps.ipynb),
[plain-language interactive explanation](../enpg_casen_aps_explicado.html),
[computational source](../enpg_casen_aps.R). CASEN 2017 and 2024 now use
encrypted, column-reduced inputs; their original source hashes and the exact
regeneration and equivalence checks are documented in [_casen/README.md](../../_casen/README.md).
The existing outputs and their source manifests describe the original analysis.

## Execution and boundaries

All substantive outputs were generated from the real encrypted ENPG/EPS/CASEN
inputs. The saved notebook executes eleven R cells that read and verify these
results, with no cell errors. It was evaluated sequentially in a fresh Rscript
process, not a Jupyter kernel. By default it does not rerun the microdata analysis.
The saved notebook includes 29 HTML tables and four embedded figures, captured through IRdisplay's
`jupyter.base_display_func` during the Rscript execution. This captures the MIME
outputs; it is not a live-kernel test. Rendering follows the existing
`expand_pif2/3` pattern: `IRdisplay::display_html()` in Jupyter and
`htmltools::browsable()` outside Jupyter. Tables include captions, escaped values
and scrollable containers, with no JavaScript or external assets. The browsable
return path was checked; no separate macOS/Linux application was run.

Set `ECA_REBUILD=1` before running the notebook to regenerate the analysis.
Rebuilding can take several minutes and requires `ACC_DATA_KEY` through the
usual environment; do not put the key in code or on a command line.

Other notebooks, the simulation engine, and original input tables were not
changed. No AAF/PIF or DIR-effect model was run. No commit/push was performed.

## Consumption and education contract

| File | Purpose |
|---|---|
| `casen_targets_enpg_years.csv` | 56 sex × age-group × ENPG-year rows: education proportions and national sex-age shares |
| `casen_single_age_targets_enpg_years.csv` | 714 sex × single-age × ENPG-year rows, education profiles for initialization |
| `casen_targets_by_round.csv` | Actual CASEN-round group estimates and design standard errors |
| `casen_single_age_rounds.csv` | Single-age point estimates, n, weight-only Kish size, smoothed values; no design SE inferred from Kish |
| `casen_education_validation.csv` | Agreement with Ministry education classification, missingness and population totals |
| `casen_existing_targets_differences.csv` | New minus old repository proportions, in percentage points |
| `enpg_variable_map.csv` / `enpg_audit.csv` | Per-wave fields, head-of-household routing, exclusions and missing education |
| `enpg_factors_educ3.csv` | 168 factors by year × sex × age group × education; target, original and achieved proportions |
| `enpg_factors_sexo_edad.csv` | 56 additional factors to match national sex-age shares |
| `enpg_consumption_comparison.csv` | Original, education-only and national-composition prevalence, using identical valid outcome records |
| `enpg_poststrat_nacional.rds.tar.xz.enc` | Individual original IDs, sex/age, education, consumption outcomes and all three weights |
| `enpg_poststrat_educ3.rds.tar.xz.enc` | Intermediate education-only individual weights, also encrypted |

Sex: 1 men, 2 women. Education: 1 basic or less, 2 secondary, 3 completed
tertiary. ENPG/education age range: 15–65; groups 15–29, 30–44, 45–59, 60–65.
`id` retains the original survey-specific ID as text. Join on `anio + id`, with
a one-to-one assertion, never by row order. The code does not infer a survey PSU
or stratum for ENPG.

`peso_educ` preserves the ENPG sex-age totals. `peso_nacional` additionally
matches CASEN sex-age shares, preserving only each year's original ENPG total.
Neither weight turns that total into the CASEN national population count.
Missing education retains the original weight under the educational adjustment;
it receives the sex-age factor under national adjustment. Targets for education
are achieved among known education, not asserted for the missing population.

The maximum difference from old repository targets is 1.98946 percentage points.
Regenerated proportions exactly matched the user's updated `salidas_educ3`
group-target file in the confirmed CASEN source folder. Old repository files
were preserved. Single-age smoothing uses distinct available neighbours at the
boundaries; the earlier script duplicated boundary ages. These profiles do not
identify individual educational transitions.

For 2024, monthly consumption is 35.946% with original weights, 35.562% with
educational weights, and approximately 36.025% with national-composition weights
(use the CSV for exact values). Changes are reweighting effects, not measured
true consumption bias. CASEN target uncertainty was not propagated to ENPG
confidence intervals. Kish effective sizes describe weights only.

## Geography and health contract

| File | Purpose |
|---|---|
| `ine_sexo_edad_comuna_2012_2024.csv` | 19,376 rows, 346 communes, two explicit conditional population shares |
| `casen_health_domains.csv` | Survey estimates, SE, logit-delta 95% interval, n, events, Kish, UPM count, missing-weight fraction and precision screen |
| `casen_health_dictionary.csv` | Actual source variable labels and response codes used |
| `insumo_contacto_comuna_anios_enpg.csv` | 19,376 rows: all seven ENPG years, observed values, temporal scenarios, source years and sample sizes |
| `health_year_alignment.csv` | Explicit source rounds and interpolation weights for each ENPG year |
| `casen_health_indicator_availability.csv` | Which of the five distinct indicators exists in each CASEN round |
| `casen_health_domains_YEAR.csv` | Observed national, regional and commune estimates for each of the six rounds |
| `casen_health_warnings_YEAR.csv` / `casen_health_join_audit_YEAR.csv` | Full warning frequencies and checked geography joins per round |
| `casen_health_geography_crosswalk_YEAR.csv` | Old commune codes mapped by official labels to the current INE geography |
| `insumo_contacto_publico_comuna_2024.csv` | Preserved initial 2024-only delivery; use the all-year file above for new work |

Geography/health age range is **15–64**, groups 15–29, 30–44, 45–59, 60–64.
The existing INE commune projections have quinquennial ages and cannot isolate
age 65. They are the existing Censo-2017-based series, not a Censo-2024-based
commune projection. `p_sexo_edad_en_comuna` sums to one within commune/year;
`p_comuna_dado_sexo_edad` sums to one across communes within sex-age/year.

Health denominators include valid respondents aged 15–64, not only users or
FONASA affiliates. The period and service are part of each outcome name:

- 2013/2015/2017: `public_general_3m`, `public_control_3m`, and
  `aps_general_or_control_3m`. Public = provider codes 1–7; consultorio/posta = 1/2.
  APS is the person-level union of general consultation and control, not their sum.
- 2020: `illness_consultation_3m`, consultation following illness or accident, any
  sector. The abbreviated telephone questionnaire has no comparable general-care,
  control/provider or APS indicator. This measure is kept separate.
- 2022/2024: `public_general_3m` and `public_control_12m`. These distinguish public
  care, not APS. Controls measured over 3 and 12 months are different outcomes.

National/region weights: revised `expr` in 2013/2015, `expr` in later rounds.
Commune estimates use official `expc`, joined on `folio + o` through 2017 and
`folio + id_persona` since 2020. Source geography URLs and hashes are in
[`_casen/geography_sources.csv`](../../_casen/geography_sources.csv).
Ñuble's old commune codes are mapped by unique official labels to the INE grid;
all regional results use these fixed current boundaries. PSU `varunit` and stratum `varstrat` come from CASEN.
Design is created before domain subsetting. Single-PSU/domain adjustments use
`survey.lonely.psu='adjust'` and `survey.adjust.domain.lonely=TRUE`.
Each round now records all warnings emitted by its domain calculations in
`casen_health_warnings_YEAR.csv`. The earlier targeted diagnostic is retained.
These warnings are not evidence
that precision is good. The logit-delta interval uses a normal approximation;
boundary proportions have no forced interval.

The exploratory screen requires n≥60, Kish≥30, ≥5 events and ≥5 nonevents,
≥2 UPM, CV≤30%, and ≤10% missing weighted outcome. It is a project rule, not
an official CASEN certification. Of 2,654 observed commune sex-age cells,
359 passed for public general contact and 507 for public controls.
The full INE grid retains absent CASEN cells as missing, never as zero.

The aligned contact table covers ENPG 2012, 2014, 2016, 2018, 2020, 2022 and 2024:

| ENPG year | Public-general contact source | Status |
|---|---|---|
| 2012 | CASEN 2013 | nearest-round proxy |
| 2014 | 50% 2013 + 50% 2015 | temporal interpolation |
| 2016 | 50% 2015 + 50% 2017 | temporal interpolation |
| 2018 | 80% 2017 + 20% 2022 | scenario crossing the pandemic |
| 2020 | 40% 2017 + 60% 2022 | unobserved comparable measure; scenario crossing the pandemic |
| 2022 | CASEN 2022 | same-year observation |
| 2024 | CASEN 2024 | same-year observation |

`p_observed_commune` / `p_observed_region` contain only same-year observations
(2022/2024). `p_scenario_commune` / `p_scenario_region` include the explicitly
mapped historical proxies and interpolations. Commune interpolation needs both
source cells; absent cells remain NA. Regional scenarios copy the regional
sex-age probability to each commune and do not estimate within-region variation.
Source sample sizes and precision flags remain attached; interpolations do not
get invented sample sizes or design confidence intervals. Temporal model error
and covariance across rounds were not estimated. The 2018/2020 scenarios do not
reconstruct the effect of the pandemic and should not be treated as measured
historical service use. Questionnaire changes may also affect comparability.

`p_aps_3m` contains a **regional temporal scenario** for 2012/2014/2016 only, based
on the 2013/2015/2017 consultorio/posta union. From 2018 onward it remains NA.
Observed APS estimates by commune and region remain available in the source-round
tables. Neither public contact nor affiliation is interchangeable with APS use.
No annualization or intervention reach/effect is inferred from these probabilities.

## Preliminary rural composition contrast (2026-10-27)

[Computational source](../enpg_casen_rural_prelim.R) adds 2012–2024 point estimates
without changing the existing individual calibration weights. It holds the ENPG
outcome mean within sex × age band × education fixed, then contrasts CASEN urban
with national composition. Positive `rural_composition_gap = urban - national`
means compositional overestimation of the selected outcome; negative means
compositional underestimation. `original_minus_national` additionally includes
other sample/frame composition differences. Neither estimates total rural bias.
CASEN urban also covers small localities outside the ENPG frame.

`rural_composition_targets.csv` preserves the existing national targets exactly.
Within-cell rural shares use official `zona` (2013/2015) or `area` (2017 onward),
with revised regional weights in 2013/2015. The shares are interpolated with the
education calendar, then qU is proportional to qN × (1 − rural share); 2012 uses 2013.
Rural outcome transport conditional on the calibration variables is an assumption.

| File | Content |
|---|---|
| `enpg_indicators_by_group.csv` | 1,680 rows: direct original versus existing national weights, keeping missing education under the established weight rule; reproduces the original 2024 headline |
| `rural_preliminary_estimates.csv` | 1,680 rows: 7 years × 2 volume scales × 8 outcomes × 15 sex/age domains; means, signed contrast, n, Kish and unsupported target mass |
| `rural_education_contributions.csv` | 2,688 cell rows; education shares and contribution `(p_urban - p_national) * cell_mean` within sex/age |
| `rural_casen_by_round.csv`, `rural_casen_dictionary.csv` | Actual-round rural shares, source n and checked variable labels/codes |
| `rural_enpg_join_audit.csv` | All 124,104 records joined by original year/ID; education, status and volume missingness |
| `rural_volume_recipe_check.csv` | Current valid volumes agree with the existing project derivation within 1.2e-13 g/day in all seven years |
| `rural_balance.csv` | 63 marginal balance rows; SMD denominator is target binary SD; joint 24-cell calibration is also asserted |
| `rural_augmented_identity.csv` | 112 algebraic checks; explicitly not a fitted Yang high-dimensional method |
| `figures/` | Love plot, 2024 WHO contrasts, seven-year heatmap and education contributions, PNG/PDF |

The main before/after table applies the previously delivered individual weights
directly, including respondents with missing education. It matches 35.946% to
36.025% for last-month consumption in 2024. The optional rural-composition contrast
excludes missing education and standardizes valid responses within each cell to
its target; the two estimands are presented separately, not as interchangeable
versions of the same estimate.

Lifetime abstention is the explicit `oh1 == "No"` response from the ID-linked source.
HED is any reported 5+/4+ occasion in 30 days (`db > 0`, the project definition).
Known non-current respondents without contradictory positive episodes get zero;
unknown episodes among current respondents or contradictory responses stay NA.
The current/lifetime/HED results are invariant to the volume-scale selection.
The presentation orders lifetime abstention, last-month use, WHO categories and HED;
these rows do not form mutually exclusive states and must not be added together.

WHO categories follow the current project decision: 12 g/drink, exact borders
in the lower category, C3/C4 always merged to C3+. NC combines non-current states
and does not identify lifetime abstainers. Source for the three positive-volume
bands: [WHO (2000), table 2.2.2, p. 54](https://www.who.int/docs/default-source/substance-use/who-msd-msb-00-4.pdf).
The alternative anchored scale uses existing `oms_factor_by_year.csv` factors
unchanged across reweightings (June-2026 vintage; 2024 uses 2023 APC).
Current respondents without valid volume stay missing; known non-current status
has zero volume. Each valid-response cell is standardized to its target, assuming
valid outcomes represent missing outcomes within that cell. This denominator can
differ from earlier overall consumption tables. The status and volume filters are
explicitly analysis-specific; original mortality-pipeline exclusions are not modified.

Education is a contribution decomposition, not an estimated within-education rural
effect. The latter is zero by the compositional construction, not empirical evidence
of equivalence. The exploratory screen uses n ≥60, weight-only Kish ≥30, ≥5 events
(and ≥5 non-events for binary outcomes), and ≤10% weighted missingness. Sparse cells
remain visible. No two-survey design intervals, temporal interpolation variance,
residual rural effects or causal claims are supplied.

[Yang, Kim & Song (2020), JRSS B 82(2):445–465](https://doi.org/10.1111/rssb.12354)
is discussed in the notebook with its positivity/ignorability requirements and the
distinction between non-probability sampling and ENPG's restricted probability frame.
The augmented identity here reduces to poststratification under exact calibration;
its numerical agreement is not validation of double robustness. Penalized variable
selection and the paper's inference procedure were not implemented.

Real-data checks cover thresholds, unique joins, all years, target normalization,
joint calibration, category sums, rural mixture identity and summed educational
contributions. Edge tests exercised all 1,680 filter combinations, the main and both rural CSV
downloads, existing education/contact downloads, embedded figures and mobile width.
Notebook HTML tables/figures use the portable IRdisplay/browsable dispatch.

The revised explanation leads with two separate questions: composition change
using CASEN, and historical contextual consumption differences from EPS. Technical
details sit behind disclosures. It includes an eight-group ranking for the selected
year/outcome and a six-group EPS sex/education selector. EPS VIII references remain
2023–2024 regardless of the selected ENPG year; unsupported EPS indicators are
explicitly marked unavailable. The rural contribution shown in plain-language UI
is national minus urban (the negative of the CSV's `rural_composition_gap` and
education `contribution` fields), so its sign directly describes the change when
including rural composition. CSV contracts retain their documented original sign.

## EPS ecological reference

`eps_reid.R` was preserved. Its current label search cannot find VIII sex/age.
`eps_reid_casen_aps.R` is a compatibility copy: select respondent-file `a8/a9`
explicitly and read the INE CSV independently of the Windows text locale.
Its scoring and greedy assignment rules are unchanged.

`eps_all_comuna_candidates.csv` retains 3,130 candidates;
`eps_heuristic_assignment_audit.csv` retains 77 proposed assignments, including
26 negative alternative margins. They are ecological hypotheses, not confirmed
residence or individual rurality. Confidence labels are not probabilities.
Because posta-rural answers inform the assignment, they cannot provide an
independent validation of APS contact using that same assignment.

`eps_rural_historical_reference.csv` contains earlier EPS VIII contextual-model
results with `models_reexecuted=FALSE`. Wide intervals or nonsignificance do not
prove equivalence or a small residual rural effect. No rural multiplier was
applied to ENPG in this work.

The artifact also reads `../rg_T2_gaps.csv` and `../rg_T3_enpg_bias_cells.csv`.
T2 contrasts hypothetical entirely rural and entirely urban areas by sex and
education, assuming a common difference across ages. T3 supplies descriptive n
for age 18–65, not a fitted age-specific rural effect or design-effective n.
These existing models were not re-estimated. Lifetime abstention and updated WHO
classes are not available as rural contrasts in these historical tables. EPS
current use is not automatically equivalent to the ENPG last-month question.

## Reproducibility and checks

The original source files were packed without deleting them. Every CASEN
bundle was restored and MD5-checked; individual ENPG output bundles were
restored and compared with their in-memory objects. Source manifests identify
input and code hashes. Original source download dates were not independently
established for local files; see [CASEN provenance](../../_casen/README.md).

`eca_tests()` covers education completion/missingness, total preservation,
missing education, duplicate targets, unsupported positive target cells and health non-use versus unknown/provider recoding.
Real-data assertions additionally verify achieved proportions, national
sex-age shares, record keys, geography joins, row counts and probability bounds.
HTML filters and CSV download were tested in a headless installed Edge browser,
including a mobile-width check and screenshot inspection.

The official 2015 geography file has `expc` only for 139 communes (52,770
sample records lack this weight). Other communes receive no direct commune
estimate; they remain represented in the national/regional analysis. For commune
variance estimation the full-sample PSU/stratum structure is retained, and
records without an official commune weight are excluded as a domain before
estimation. A computational placeholder outside that domain never contributes
to any estimate or denominator. Historic commune weights retain their original
census base; they are not relabelled as updated Censo-2017 regional weights.
See the [official 2015 sampling report](https://observatorio.ministeriodesarrollosocial.gob.cl/storage/docs/casen/2015/Metodologia_de_Diseno_Muestral_Casen_2015.pdf).
