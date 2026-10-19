# TSM notebook audit and revised copy

Audit date: 2026-10-15. Original: [TSM_transiciones_IPW.ipynb](TSM_transiciones_IPW.ipynb). Revised copy: [TSM_transiciones_IPW_auditado.ipynb](TSM_transiciones_IPW_auditado.ipynb), [rendered HTML](TSM_transiciones_IPW_auditado.html).

## Scope and preservation

The initial audit was read-only. It inspected the executed notebook, its builder, saved aggregate outputs, all five real SAV files and the available questionnaire material. Independent reviews covered consumption coding, panel construction and inference. The revised copy writes only to `outputs_tsm_auditado/`. Original notebook, HTML, builder, SAVs and original output files are protected by a SHA-256 manifest in [originales_sha256.json](outputs_tsm_auditado/originales_sha256.json).

## Findings and concrete changes

| Finding | Evidence | Change in the copy |
| --- | --- | --- |
| The requested project volume categories were missing | Original `tsm-harmonize` and `tsm-quantity-transitions` implement A/D/H and typical-quantity categories | Add A + cat1–cat4 under explicit conversion scenarios; retain observed-state analysis |
| Frequency/quantity responses do not identify grams/day | Ordinal response bins, open upper quantity, no TSM grams/drink or recall window identified | Publish conversion assumptions, 36 scenarios, and interval-compatible categories; never label proxy as observed volume |
| High-volume states have insufficient transition support | Reference mapping gives only 2/3/1 observed annual origins for cat2/cat3/cat4 | Show counts and people; retain empty rows as undefined; suppress degenerate boundary SE/CI |
| Age consistency was too permissive | Original `tsm-risksets` allowed an age increase of lag+1 | Derive a maximum increment from calendar fieldwork envelopes; report flags and update sensitivity, preserving primary inclusion |
| Overall IPW balance concealed within-state imbalance | Main annual max absolute SMD 0.0201 globally, but employment SMD 0.1337 within H | Add state- and interval-specific balance and a limited state-by-employment response-model sensitivity |
| Event counts did not describe effective information | H origins: 331 pairs, 288 people, weight-only ESS 97.69; strong event-weight concentration in some cells | Report people, event/complement support, and largest person contributions alongside weight-only ESS |
| Bootstrap checked H-to-H only | Original `tsm-ipw-bootstrap` exported one transition | Refit response weights in 500 whole-person resamples and check all nine A/D/H cells |
| History display used a different age origin and no survey weights | Original `tsm-history` selected age at the first of three waves | Use age and Fact_Exp at the middle/current-state wave; label complete-triple selection and lack of triple-response adjustment |

The original A/D/H point estimates and stacked-equation SEs are retained and checked against the original CSV. The age refinement changes only quality diagnostics and the explicitly selected sensitivity. The interaction model remains a sensitivity rather than silently replacing the original model.

## Consumption categories and assumptions

Current category definitions were recovered from `micsim` source `__andres_control/expand_pif.ipynb`, chunk `enpg-consolidate`, definition of `cvolaj`:

| Category | Women, g/day | Men, g/day |
| --- | --- | --- |
| A | e3a1=1, drinking history unknown | Same |
| cat1 | >0 and <20 | >0 and <40 |
| cat2 | >=20 and <40 | >=40 and <60 |
| cat3 | >=40 and <=100 | >=60 and <=100 |
| cat4 | >100 | >100 |

The continuous intervals in the copy avoid the tiny gaps left by literal comparisons ending at 19.99/39.99/59.99 in the source implementation. This audit does not change the ENPG source. Cat4 is a project category and is not labelled a WHO category.

The ENPG categories use `volajohdia` after `factor_CH` calibration. TSM scenarios are on an uncalibrated survey scale. Identical thresholds therefore do not establish comparable exposure distributions. No ENPG calibration factor is transferred to TSM.

Reference proxy assumptions: 0.5 and 3 drinking days/month, 2.5 and 5.5 days/week; typical quantities 1, 3.5, 5.5, 8 and 12 drinks; 12 g/drink. A month is 365.25/12 days. Treating frequency as drinking days and typical quantity as a mean are additional assumptions. Twelve grams and an alternative 15.7 g occur in the project; neither verifies TSM drink size. The copy crosses 10/12/14/15.7 g with upper-bin quantities 10/12/16 and upper-bin frequencies 4/5.5/7 days per week. These are scenarios, not fitted or validated conversion parameters.

The main reference gives 9,060 person-wave observations aged 18–65: A=4,468; cat1=4,564; cat2=21; cat3=5; cat4=2. These are repeated observations, not 9,060 different people. For nominal annual transitions, observed origins are only 2 in cat2, 3 in cat3 and 1 in cat4. Fine stratification by age, sex, education and HED cannot supply reliable transition estimates for those states. A reported 0%/100% from a sparse cell is not evidence of a deterministic transition.

Changing only scenario points understates full bin uncertainty. The additional compatibility table retains the open upper quantity interval under an explicit 12 g assumption and shows all project categories intersected by a response range. These are conditional compatibility sets, not identified bounds for true long-term consumption.

## Panel, calendar and renewal

Real-data checks confirmed 13,085 respondent records and 5,323 distinct IdPanel values, with complete and unique respondent IDs within wave. All interviewed adults have classifiable A/D/H responses; skipped abstainer items are structural. A transition always links the same person. Independent subjects are never paired.

The principal nominal annual pool is R7-to-R9 plus R9-to-R11: 4,260 origin opportunities from 3,061 people and 2,260 observed transitions from 1,579 people. It retains 698 observed endpoint pairs missing the middle interview. R8-to-R10 is an 11-month sensitivity. Adjacent intervals have nominal durations 8, 4, 7 and 5 months; they are not annualized or treated as equal-duration processes.

Direct t+2 endpoint probabilities do not require first-order Markov. Reusing an aggregated matrix as a homogeneous annual microsimulation process requires further assumptions and validation. The descriptive history comparison cannot establish or refute this property.

The annual endpoint absence proportions are 42.1% for R7-to-R9 and 51.8% for R9-to-R11. These are interval absence proportions, not permanent dropout estimates. First appearance after R7 can include later recruitment, return from pre-R7 participation or a change of selected household respondent; the files do not establish official refreshment sampling.

The original age screen allowed +2 years over t+1 and +3 over t+2. Published-slide fieldwork envelopes imply maxima of +1 for adjacent waves and R8-to-R10, and +2 for R7-to-R9/R9-to-R11. Among observed annual pairs, 9 ages decrease and 60 increase by more than two years; one sex value changes. These are measurement-coherence flags, not proof that IDs are wrong. The primary sample is retained and a sensitivity is reported.

**Official-source conflict for R8:** the methodology presentation, page 6, prints December 1–31, 2023. [UC/CEEL news](https://encuestas.uc.cl/?p=2239) instead describes November–December interviews. The copy preserves slide-reported dates and adds a conservative November 1 lower boundary for sensitivity; November 1 is an assumption, not a verified start date. Under this envelope the permitted R8-to-R10 age increment becomes two years. The demographic exclusion sensitivity uses this more permissive envelope and reports both flags. Main nominal annual links are unaffected.

From the published fieldwork dates, R7-to-R9 can span 371–426 days and R9-to-R11 314–388 days. These are possible endpoint envelopes, not observed individual intervals. The April round labels do not establish exactly one-year follow-up.

## Weighting, selection and uncertainty

The estimator is a ratio with q=Fact_Exp at the origin. Complete-endpoint estimates use qR; IPW estimates use qR/pi. It does not multiply origin and destination survey weights. Pooled origins represent a population-weighted mixture of person-period opportunities, not an equal-person cohort or an equal-year average. The copy reports actual origin-wave contributions to each state denominator.

The response model uses origin information and directly models the destination interview. It accommodates return after intermediate absence; no monotone-dropout weight product is imposed. The response model itself is fitted with rescaled q. The same baseline response model is retained for proxy-state scenarios; it does not adequately balance the rare volume states (maximum absolute SMD approximately 1.50 for cat2 and 0.64 for cat3). IPW does not repair their support problem.

Identification depends on conditional response exchangeability, positivity and a sufficient response model. Death, ineligibility, contact loss and refusal cannot be separated from observed absence. An alcohol outcome may be undefined after death. IPW does not resolve this or recover people already missing at the origin. Initial-cohort and all-available-origin analyses have different selection histories.

The joint estimating-equation sandwich includes response-model uncertainty and sums influence contributions by IdPanel, including nuisance contributions from origin nonrespondents. Independent numerical differentiation reproduced the original annual H-to-H probability 0.47651318 and SE 0.05009864. Whole-person bootstrap refits support this implementation under its working assumptions, not MAR or the unknown sampling design.

Original annual balance was good globally but residual employment imbalance within H was 0.1337. Adding state-by-employment interaction reduced that imbalance to approximately 0.065 and changed H-to-H from 0.4765 to approximately 0.4753 in the audit. This is a limited diagnostic sensitivity, not proof of correct response specification. The original model remains the primary comparison.

The displayed ESS is `(sum weights)^2/sum(weights^2)`: a weight-dispersion diagnostic for contributing rows. It is not an estimate of the complete survey design effect or the number of independent people. No extra Kish multiplier is applied to a variance already incorporating unequal weights. Boundary probabilities export no artificial zero-width SE/CI. Sparse-support flags are descriptive review rules, not formal guarantees for cells that pass them.

## Sampling design statement

Official presentations describe an urban sample derived from households previously interviewed in person, but do not identify the original primary sampling units or strata ([Round 10 presentation, p. 6](https://www.achs.cl/docs/librariesprovider2/default-document-library/presentacion-tsm-r10.pdf)). This does not establish that the original design lacked clustering or stratification; rather, these design identifiers were not identified in the publicly released materials reviewed.

Analyses use the wave-specific expansion factor (Fact_Exp) from the origin interview, combined with follow-up response weights where specified. These are not released longitudinal survey weights. Confidence intervals incorporate unequal weighting and within-person dependence, and IPW intervals account for response-model estimation. They remain working approximations because the original sampling structure could not be reconstructed. The expansion factors are treated as fixed; their construction uncertainty is not reproduced.

Neither IdRegion nor IdEncuesta is declared an original stratum or PSU. Grouping by IdEncuesta is only an interview-group sensitivity. The direction and magnitude of the remaining variance discrepancy are unknown. No regional wild-bootstrap analysis is claimed.

Methodological references: [survey design declarations](https://r-survey.r-forge.r-project.org/survey/html/svydesign.html), [svrep nonresponse adjustments](https://bschneidr.github.io/svrep/articles/nonresponse-adjustments.html), and [Cole and Hernan on weighting assumptions and diagnostics](https://pmc.ncbi.nlm.nih.gov/articles/PMC2732954/). Their principles support explicit design declarations, reestimated response weights and diagnostics; they do not supply missing TSM design variables.

## Reproduction

Run from this folder, using the existing installed packages and R kernel:

```text
python refinar_notebook_tsm.py
python ejecutar_copia_tsm.py
quarto render TSM_transiciones_IPW_auditado.ipynb --to html --no-execute
```

`refinar_notebook_tsm.py` uses `extension_auditoria_tsm.py`, builds only the audited copy and clears that copy's outputs before execution. The execution helper saves partial outputs if a cell fails. Neither script rewrites the original notebook. The HTML preserves the journal theme and embedded CSS, tables and figures. CSV download links require `outputs_tsm_auditado/` alongside it.

## Completed verification

- Executed the revised notebook on the five real SAV files: 28 code cells completed, with no saved errors. This is a real-data execution, not only a parsing or synthetic check.
- All 34 original-file hashes match their pre-edit values.
- All 198 original A/D/H scheme-method-cell probabilities and SEs are reproduced to numerical precision; maximum differences are approximately 5.0e-16 and 1.7e-16.
- The independently differentiated joint estimating equations reproduce the analytical H-to-H SE within 2.6e-13.
- All nine annual A/D/H cells completed 500 successful whole-person bootstrap replicates with response-model refitting.
- The reference volume export has 550 rows; 100 rows lack observed transitions from the origin state, and 278 have boundary probabilities. All such rows have unavailable inferential quantities explicitly represented as NA. Zero origins and zero observed follow-up are distinguished.
- The volume sensitivity export contains 1,800 rows covering 36 unique mappings. All estimable probability rows sum to one.
- The complete reference count grid preserves all 9,060 person-wave observations: 200 wave-age-sex-category cells and 1,600 cells additionally crossing education and HED. Structurally impossible A-with-HED cells are flagged separately from sampling zeros.
- Rendered a self-contained HTML with 62 tables and embedded images, scripts and styles; no external rendering resources were found. The journal theme and the existing custom styles were retained.

The unresolved limitations remain substantive: exposure measurement and temporal window, sparse high-volume states, unknown response dispositions and refreshment mechanism, and unreconstructed original survey design. Execution checks do not remove these limitations or validate a homogeneous microsimulation transition model.
