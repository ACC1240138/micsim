---
title: "ELSOC: weighting scenarios for transitions in regular drinking"
subtitle: "ponderador_long_total, ponderador_long_panel and unweighted, three observed intervals 2016–2023"
author: "Andres Gonzalez Santa Cruz"
lang: en
format:
  html:
    theme: journal
    css: [_lib/styles.css, _lib/prediction_metrics_compact.css]
    toc: true
    toc-location: left
    toc-depth: 2
    number-sections: false
    code-fold: true
    code-summary: "Show R code"
    code-tools: true
    embed-resources: true
    self-contained: true
    html-math-method: mathml
execute:
  echo: true
  warning: false
  error: false
---

**Quick orientation.** The same ELSOC respondents are observed at two interviews, 2016→2018, 2018→2021 and 2021→2023, and their answers to two alcohol items are compared: S09, whether they drink alcoholic beverages regularly, and S10, on how many days a week they drank in the last month, asked only to regular drinkers. The previous notebook ([elsoc_transiciones_2016_2023.ipynb](__andres_control/elsoc_transiciones_2016_2023.ipynb)) estimated these transitions without weights. This notebook asks what changes when the official longitudinal weights are applied, and separates two things that are easy to confuse: the effect of **weighting** the same people and the effect of **selecting** the balanced panel to which the panel weight applies. A second part, added at the user's request, builds the full transition matrix with **non-regular use as a state**: non-regular plus the eight S10 categories of regular drinkers. It is estimated three ways, as in the EPS engine (observed proportions, matrix A and a two-part lognormal), under the same three weights, by sex, initial age and origin wave and pooled over the three intervals, with intervals that keep all pairs of a person together. Every number comes from the tables written by [weight_scenarios.R](__andres_control/elsoc_2021_2023_exploration/weight_scenarios.R) and [state_transitions.R](__andres_control/elsoc_2021_2023_exploration/state_transitions.R); the text explains how to read them and deliberately does not restate them.

Three rules of reading apply throughout. "Non-regular" is a declared answer, not abstinence, and giving the same answer at both ends does not prove that nothing happened in between. S10 keeps its eight original categories, the skip is never recoded as zero, and frequency transitions exist only for people who were regular with a valid frequency at both ends. S09 and S10 are not AUDIT and are not grams per day or heavy episodic drinking. S15, the quantity at the last occasion available only for the original sample in 2023, is outside this analysis.

**Decisions taken by the user on 2026-10-21** and implemented here: the three scenarios are compared on every interval, including 2021→2023 with the 2023 weights, whose construction is taken as an assumption documented below rather than a reason to postpone; the unweighted estimate stays the reference; a pair whose destination interview date is missing is **kept**, because the date is only needed for the elapsed time, not for the transition; the panel-weight scenario is reported for all three intervals with its population stated plainly. The design document with the verified sources is [WEIGHTING_PLAN.md](__andres_control/elsoc_2021_2023_exploration/WEIGHTING_PLAN.md); the findings in Spanish are in [hallazgos_elsoc_ponderacion.md](__andres_control/hallazgos_elsoc_ponderacion.md).

## What the first cell does

The first code cell sets the session and sources the analysis script. The script reads the encrypted wide file through `acc_data()`, checks its MD5 against the published provenance, rebuilds the three pair samples with the same rules as the previous notebook, reproduces the published unweighted tables cell by cell with the same bootstrap replicates before estimating anything new, then estimates every scenario and writes aggregate tables prefixed `weights_` into `intervals/`. It never modifies the published tables, which is verified by hash at the end, and it exports no microdata.

<!-- code:elsoc-w-run -->

<!-- code:elsoc-w-display -->

## Data, version and the two longitudinal weights

The file is `ELSOC_Wide_2016_2023.sav`, the version 3.0 release of the Harvard Dataverse record [10.7910/DVN/LD4BPH](https://doi.org/10.7910/DVN/LD4BPH), identified by MD5. It carries two longitudinal weights per wave. `ponderador_long_total` is meant for all respondents of a wave, both samples together or each one alone. `ponderador_long_panel` is meant for the balanced panel of each sample: people present at every wave of their cohort, seven waves for the original sample M1 and five for the 2018 refreshment sample M2; in the file this set coincides exactly with `tipo_atricion == 1`. The method is public: a report from March 2023 and the code repository [elsoc-coes/ponderadores-long](https://github.com/elsoc-coes/ponderadores-long) (commit 475c7e3). Both cover the 2016–2022 construction. The weights in the 2016–2023 file were recomputed with the 2023 wave, which is why their balanced panel runs through 2023 and their values differ from the 2016–2022 CSV; the 2023 wave itself has no published construction document, so its weight is used under the assumption that the same method was applied.

How the weights are built matters for reading the results. Each wave's weight starts from the design weight, applies a participation adjustment for that wave (response rates within cells formed by quartiles of a GEE-predicted participation probability inside each design stratum), trims the 5 % tails once over all waves pooled, rakes to the INE urban population aged 18 and over by sex and five age bands for that year, and rescales to a mean of one within each sample and wave. For a pair w0→w1 this notebook uses the **destination-wave** weight: its participation adjustment is the one that targets being observed at w1, which is the selection a pair is exposed to. When the origin is the first wave of the sample the adjustment matches the pair's non-reinterview almost exactly; for later origins it also covers people absent at origin, who cannot form pairs, and that residual is counted in the flow. The two weights are never multiplied and no additional attrition adjustment is added.

The documentation table records, for each interval, sample and weight, who holds it, its coverage on the pairs, its sums and effective sample size, and the official composition check described further down. The configuration table records the seeds, the trimming rule for the sensitivity and the date rule.

<!-- code:elsoc-w-documentation -->

## Population, filters and flow

Pairs link the same person by `idencuesta` between the two interviews, require age 18–65 at origin, a valid and identical sex at both ends and a destination age within 18–110. Participation at intermediate waves is not required, so the general pair sample G includes people who missed a wave and returned. Interview dates define the elapsed time; where both dates exist they must be ordered and fall in the nominal field years. Where one interview date is missing the pair is kept and simply has no duration, while any date that is present is still checked against its field year; this only happens in the last interval, for destination dates. The published rule that excluded those pairs is shown side by side so that the change is auditable, and the published tables themselves are untouched. The age–time discrepancy flag is kept as a flag, never as an exclusion.

The panel-eligible subset P is the part of G that holds a positive panel weight. For 2021→2023 this means having answered every wave since the person's first one; for 2016→2018 and 2018→2021 it additionally means having continued to answer through 2023, that is, after the destination. The subset is therefore a different population in each interval and this is exactly why the panel scenario is read next to the unweighted estimate on the same subset rather than against the general sample. People who are in G but not in P are kept as their own group: they missed at least one wave of their cohort, before or after the destination (in 2021→2023 necessarily before, since 2023 is the last wave), so that the selection can be read directly as balanced-panel members versus the rest of G. Transitions are reported per observed interval and are never annualised or converted to a common duration.

Within an interval, participants, pairs and persons are the same count. Across intervals a person can contribute up to three pairs, so the unique-persons table is the one to use when thinking about the three N together. The weighting scenarios compute no pooled matrix or pooled test; the state-transition part below pools the three intervals, with intervals that keep all pairs of a person together.

<!-- code:elsoc-w-flow -->

## Six estimators and what each difference means

| Estimator | People | Weight | Role |
|---|---|---|---|
| E1 | G | none | reference, identical to the published unweighted tables where the pair sample is identical |
| E2 | G | `ponderador_long_total` at destination | scenario 1 |
| E3 | P | none | auxiliary |
| E4 | P | `ponderador_long_panel` at destination | scenario 2 |
| E5 | P | `ponderador_long_total` at destination | auxiliary: same people as E4, other weight family |
| E6 | G minus P | none | auxiliary: pairs outside the balanced panel (missed at least one wave of their cohort) |

The differences are computed replicate by replicate on a common segment bootstrap, so each delta carries its own interval. E2 − E1 and E4 − E3 are **weighting effects**: same people, with and without weights. E4 − E5 isolates the **weight variable** on the same people. E3 − E1, E3 − E6 and E5 − E2 are **selection effects**: different people, same weighting rule. The raw difference between the two delivered scenarios, E4 − E2, is an identity, (E4 − E3) + (E3 − E1) − (E2 − E1), and is listed only as a reading aid. The uncertainty is the stratified bootstrap of design segments already used for the unweighted tables, with 1,999 replicates and the same seeds, verified to reproduce the published limits exactly; for the headline cells a Taylor-linearized standard error with the same clustering is computed with the `survey` package as an independent check, with weights equal to one for the unweighted estimators. Both uncertainty measures are exploratory: the design's city stage is not recoverable and the weights are treated as fixed.

## Headline comparison by interval

Each table shows, for one interval, the six estimators side by side on all pairs: the unweighted N, the Kish effective sample size, the estimate with its interval, the interval width and the two standard errors. The figure stacks the three intervals. The quantities are the share with the same S09 answer, the two conditional permanences (regular → regular and non-regular → non-regular, each divided by its own origin), and the three S10 directions among regular drinkers with valid frequency at both ends. Percentages are weighted where the estimator has weights; N never is.

<!-- code:elsoc-w-comparison -->

## Weighting versus selection

The delta tables are the core of the notebook. Read each row as "estimator a minus estimator b, in percentage points, with its paired interval". A weighting effect that is large while the selection effects are small means the weights move the estimate for the same people; a selection effect that is large while weighting effects are small means the balanced panel is a different population. The figure drops the identity row.

<!-- code:elsoc-w-deltas -->

## Permanence in non-regular and in regular by sex and initial age

Permanence in "non-regular" is the probability of declaring non-regular at destination among those who declared non-regular at origin; its complement is the move to regular. It is shown with its origin N under the first four estimators, by interval and by sex × initial age band (18–29, 30–44, 45–59, 60–65). The last interval has no respondents aged 18–19 at origin. Cells with an origin N or an ESS below 30 are marked and should be read as indicative only. The figure compares the unweighted, total-weighted and panel-weighted versions.

<!-- code:elsoc-w-groups -->

## Frequency among regular drinkers

S10 transitions exist only for people regular at both ends with a valid frequency, so they describe neither all drinkers nor the whole panel, and the selection into this subset changes between periods. The tables show the direction of change (same category, increase, decrease) under the six estimators. The weighted 8×8 matrices are written to the CSV but not displayed: once the weights spread a few hundred pairs over eight origin categories, most cells fall below the effective-sample-size threshold, and the categories are not collapsed because the user asked to keep the original ones.

<!-- code:elsoc-w-s10 -->

## Composition: the official check and the balance diagnostic

The official report recommends, for an analysis that combines waves, to compare the sex × age composition of the filtered set with the composition of all respondents and of the balanced panel, and to use the weight whose population it resembles. The first table implements that check with the five INE age bands at the origin wave, among people aged 18–65 at that wave, where the three sets share the same age window; at the destination wave the pairs reach age 72 while the reference domains would stop at 65, so that comparison is not made. The second table is the EPS-style balance diagnostic: the largest standardized mean difference, per contrast, over sex, initial age, sample, education and the S09 origin state. The figure shows what the weights and the panel selection do to the age composition of the pairs.

<!-- code:elsoc-w-composition -->

## Precision: effective sample size, cross-check and sensitivities

The weights are dispersed by construction: the trimming of the official procedure is applied before calibration and over all waves pooled, so within a wave the tails are intact and the effective sample size is a fraction of N. The diagnostics table reports N, the sum of weights, the Kish ESS, the unequal weighting effect and the concentration in the top 1 %. The Taylor table compares the bootstrap and the linearized standard errors over the headline cells. Two sensitivities follow: capping the weights at the 99th percentile of their wave × sample without re-raking, with the shift this induces in the weighted sex × age shares, and using the origin-wave weight instead of the destination-wave weight. The by-stratum table shows where the dispersion comes from.

<!-- code:elsoc-w-precision -->

## Education as an additional margin

Education at origin is recoded into three completed levels (basic or less, secondary, higher) from the ELSOC item, which asks for the current level when studying and the last approved level otherwise; it is an approximation that loses years, track and student status and does not certify a degree. It is offered as a margin, unweighted and total-weighted, not as a model with interactions.

<!-- code:elsoc-w-education -->

## Transition matrices with non-regular use as a state

The scenarios above read S09 and S10 separately: S09 as a two-by-two table and S10 only for people regular at both interviews. A microsimulation needs one matrix in which non-regular use sits next to the frequency of regular drinkers, so that leaving regular use, entering it and changing frequency are read together, as the EPS engine does with its N0, FD and C1–C4 states. This part builds that matrix with nine states: **NR**, non-regular (S09 = 2), and **F1–F8**, regular drinkers by the eight original S10 categories (less than one day a week, then one to seven days). The S10 skip is never recoded: NR is a state of its own and carries no frequency. A regular respondent without a valid S10 answer cannot be placed in a frequency state, so the pair is left out and counted in the flow table; every other S09 pair keeps its place, which is why the NR→NR counts and the frequency block reproduce the published S09 and S10 tables exactly.

Three estimators are computed for every stratum, following the EPS engine (`eps_markov_core.R`):

- **Observed**: the survey-weighted share of pairs from each origin that reach each destination.
- **Matrix A**: the EPS matrix model. Weighted transition counts by interval × sex × age group are shrunk toward the matrix of the same sex in that interval, which is shrunk toward the interval matrix, which is shrunk toward the matrix of all intervals; the strength k is chosen by person-blocked cross-validation. The EPS grid of k (10 to 1000) is extended to 3000 and 10000 because with the weighted schemes the optimum sat at 1000. With the weights the chosen k lies in that upper part of the grid, at its very top for the panel weight, where the log-loss curve is flat. One k is used at every level and the weighted counts carry an effective sample of roughly a quarter to a third of the pairs, so under the weights A pulls every stratum and interval onto the matrix of all intervals: its rows barely change across sex × age groups, keep only part of the differences between origin waves and, under the panel weight, almost none. This reflects noisy weighted counts, not homogeneous groups, so the weighted A matrices should not be read as specific to a stratum or a wave. Without weights the optimum is interior and A keeps about half of the observed spread across groups. A never borrows across neighbouring frequency categories.
- **Lognormal**: the EPS two-part model adapted to an ordinal frequency. A logit gives the probability of being regular at destination; for regular drinkers, a lognormal describes the average number of drinking days per week, D, which S10 reports only by category: code 1 means D below one, code k from 2 to 7 means k − 1 ≤ D < k, and code 8 means D ≥ 7. The likelihood integrates the lognormal over each category, and the probability of each S10 category is the lognormal mass between its limits. Both parts use the origin state, sex × age group and interval, which is the EPS specification without its continuous origin amount and education. Reading code k as k − 1 to k days is an assumption. The shape table shows that the probit of the pooled cumulative S10 distribution is close to a straight line in log days, much closer than on a linear day scale, but reading the codes as days rounded to the nearest day fits that line about as well, and a pooled distribution cannot test the common σ of the conditional model. The cross-validation therefore also refits the lognormal with the rounded-day limits (0.5, 1.5, …, 6.5) as a sensitivity analysis.

Each estimator is computed under the three weights used above: none, `ponderador_long_total` and `ponderador_long_panel` of the destination wave, the latter on the panel-eligible subset. The models are fitted with weights rescaled to mean one within each interval, as EPS fixes the mass of each period. Strata are the origin wave (2016, 2018 or 2021) × sex × age group at origin, all pairs of each interval, and the same groups pooled over the three intervals. The pooled observed estimate is the survey-weighted share over all pairs of the three intervals; the pooled model estimates average the interval cells with the group's weighted origin mass, so they mix intervals in the same way. A person can contribute up to three pairs to a pooled stratum, and the n tables count persons once.

The pooled matrices are an average over the period, not a matrix for a defined duration. The three intervals last a median of about 2.0, 2.4 and 2.9 years and enter in proportion to their weighted pairs, roughly a third each, except that with the panel weight 2016→2018 contributes about a quarter. Under the panel weight the pool is the balanced panel, which for 2016→2018 and 2018→2021 conditions on answering through 2023; under every weight 2016→2018 contains only the original sample M1, because M2 entered in 2018. None of these matrices should be converted to an annual or cycle-length matrix without a duration assumption.

Uncertainty comes from one stratified bootstrap of design segments shared by the three intervals (1,999 replicates, seed 20231024). Each person belongs to a single segment, so all of a person's pairs move together in every replicate; the models are refitted in every replicate with k held at its tuned value. For the observed estimator two Taylor intervals are added: strata + segments, in which persons are nested, and clustering by person alone (`ids = idencuesta`), the subject-clustered variance for the pooled strata. Taylor intervals are built on the logit scale and bootstrap intervals are percentiles; an observed cell has no interval when it has fewer than 10 segments or an observed share of 0 or 1. For the pooled strata a third Taylor standard error treats the pairs as independent (`ids = ~1`), only to show what clustering by person changes. All of these methods omit the city stage of the design and hold the weights fixed. Interval transitions are per observed interval of two to three years, pooled ones mix the three durations, and none is annualised.

<!-- code:elsoc-s-run -->

### States, flow and n of the strata

The dictionary gives the nine states and the latent days per week behind each S10 code. The flow table shows that only regular respondents without a valid S10 answer drop out. The strata tables give, for every origin wave and for the pooled data, the unweighted number of pairs, persons, the Kish effective sample size under each weight, the panel subset and the number of pairs in each origin state: these are the n behind every row of the matrices.

<!-- code:elsoc-s-flow -->

### Matrix A and the lognormal: tuning, fit and out-of-fold comparison

The first table gives the cross-validated log loss of matrix A for each k and scheme. The coefficient table shows the two parts of the lognormal; the shape figure and table show how close the S10 distribution of regular drinkers is to a lognormal in days, under the two readings of the codes. The comparison follows the EPS engine: five person-blocked folds repeated three times, k tuned inside each training split, weighted log loss and Brier score on the held-out pairs, and the paired difference with a strata + segments interval. The last columns of the comparison give the lognormal refitted with the rounded-day reading of S10. The calibration figure plots out-of-fold predicted against observed shares for origins with at least 30 pairs.

<!-- code:elsoc-s-models -->

### All pairs: the nine-state matrices

One figure per weighting scheme shows the three estimators side by side for all pairs of each interval and for the pooled data, with percentages in each cell. Rows of three days or more almost never reach 30 pairs in an interval and stratum, and many rows of less than one day to two days do not either, so the observed rows are noisy. Matrix A keeps each origin's pattern but, under the weights, replaces it with the row of all intervals. The lognormal smooths across neighbouring categories: it underestimates staying at the common frequencies, less than one day to two days a week and daily, and overestimates it at four to six days, where staying is almost never observed.

<!-- code:elsoc-s-all -->

### By sex, initial age and origin wave

Each block opens one stratum and shows the matrix under the three weights. In each cell the first line is the observed survey-weighted percentage with its 95% segment-bootstrap interval, and the purple line gives the matrix A and lognormal estimates; hovering over that line shows their intervals. The n column is the unweighted number of pairs from that origin, and rows marked with an asterisk have fewer than 30. An origin with no pairs shows a dash for the observed estimator while the models still give a smoothed row, which is a model extrapolation. Only the observed estimator gives sex × age patterns specific to a wave. The lognormal applies the same sex × age and origin effects in every wave, shifted by an interval term as in the EPS specification, and matrix A under the weights is practically one matrix, so differences between waves within a stratum should be read from the observed lines. Every number is in `intervals/states_matrices.csv`, with the bootstrap interval for every estimator, the strata + segments Taylor interval for observed rows and, for pooled observed rows, the person-clustered Taylor interval.

<!-- code:elsoc-s-strata -->

### Pooled over the three intervals

The same blocks for the pooled data come first. The tables that follow give the survey-weighted probabilities of staying non-regular, entering regular use at low frequency, leaving regular use from the three most common frequencies and keeping the same low frequency, with three 95% intervals that all keep a person's pairs together: the segment bootstrap, the Taylor interval with strata and segments, and the Taylor interval clustered by person. The ratio table compares the three standard errors and adds the one that treats pairs as independent: clustering by person is the right assumption and is kept, but it changes the standard errors little, most in staying non-regular over all pairs, the row in which the same persons repeat most. The figure sets the observed estimates beside the two models. These rows mix the three interval durations, as explained above.

<!-- code:elsoc-s-pooled -->

## Validation

The first checks table lists what the weighting scenarios verified on the real data in this run: unique identifiers, the MD5 of the file, the identity between the panel weight and `tipo_atricion`, positive weights on every domain, the exact reproduction of the published unweighted tables and flow counts under the published rule, weighted rows that sum to one and events that sum to their origin, deltas paired on aligned replicates, the availability of the Taylor check, the accounting of the kept missing-date pairs, and the hash of the published tables. The second lists the checks of the state-transition part: pair counts equal to the weighting flow, positive weights, the replicate path reproducing the direct estimates, Taylor point estimates equal to the observed ones, NR→NR and frequency-block counts equal to the published S09 and S10 tables, rows that sum to one, a main lognormal fit that predicts every cell and origin, a tuned k for matrix A that is interior or on a flat stretch at the edge of the grid, lognormal fits in at least 99% of the replicates, complete model estimates for every observed origin, and unchanged earlier tables. Each check is marked as a data check, an identity between two computations, or a declaration; the one declaration records that no pooled interval assumes independent pairs.

<!-- code:elsoc-w-validation -->

## Sources, decisions and reproducibility

- Data: COES, *Estudio Longitudinal Social de Chile 2016-2023*, Harvard Dataverse [doi:10.7910/DVN/LD4BPH](https://doi.org/10.7910/DVN/LD4BPH), version 3.0 (2024-12-27), file `ELSOC_Wide_2016_2023.sav`, CC0 1.0; read from the encrypted repository copy `_elsoc/elsoc_wide_2016_2023.tar.xz.enc`.
- Weights: *Ponderadores longitudinales ELSOC. Documento de referencia* (Equipo ELSOC, March 2023, [pondedradores-long-elsoc.netlify.app](https://pondedradores-long-elsoc.netlify.app/)); code [elsoc-coes/ponderadores-long](https://github.com/elsoc-coes/ponderadores-long), commit `475c7e32becc1451e8d40fb9b8ef0b79d4e5885f`; methodological manual [elsoc-coes/manual-elsoc](https://github.com/elsoc-coes/manual-elsoc/), commit `edd00962c2e7df86ccf90f28bf9fc7fade186b37`; variable listing 2023 and CAPI questionnaires 2023 in `_elsoc/docs/`.
- Items: questionnaires 2016 (p. 23), 2018 (pp. 22–23), 2021 call A (pp. 7 and 10) and 2023 CAPI sheets, all listed in [INTERVALS.md](__andres_control/elsoc_2021_2023_exploration/INTERVALS.md) and [WEIGHTING_PLAN.md](__andres_control/elsoc_2021_2023_exploration/WEIGHTING_PLAN.md); the CATI 2023 instrument and the individual interview mode remain pending.
- Decisions by the user (2026-10-21): all three intervals weighted, 2023 weights used under the stated assumption; unweighted estimates as the reference; missing destination dates do not exclude a pair; panel scenario kept and labelled; destination-wave weight; M1 and M2 shown separately and pooled with the weights as delivered; no additional trimming in the main estimates, p99 cap as sensitivity; no extra attrition adjustment; original S10 categories; intervals reviewed separately before any pooling. Later the same day: transition matrices with non-regular use as a state, by sex, age group and origin wave, with matrix A and the lognormal as in EPS under the three weights, and survey-weighted estimates pooled over the intervals with subject-clustered intervals.
- State transitions: [state_transitions.R](__andres_control/elsoc_2021_2023_exploration/state_transitions.R) writes `intervals/states_*.csv`; it follows `ep_Afit`, `ep_tune`, `ep_fit` and `ep_matrices` of `__andres_control/eps_markov_core.R`, with the k grid extended and the lognormal amount observed in day bands. The interval-censored lognormal is fitted with `survival::survreg`.
- Reproduction: from the repository root, `Rscript __andres_control/elsoc_2021_2023_exploration/weight_scenarios.R` (set `ELSOC_WEIGHTS_OUTPUT` to a project-relative folder for an independent copy), then `Rscript __andres_control/elsoc_2021_2023_exploration/state_transitions.R` (`ELSOC_STATES_OUTPUT` for an independent copy, `ELSOC_STATES_B` to change the number of replicates), then this notebook with the project's R kernel; the HTML is rendered to the repository root by the Quarto project in `__andres_control/`. The notebook is built by `_tools/build_elsoc_weighting_notebook.py` from `elsoc_weighting_scenarios_EN.md` and `elsoc_weighting_sections.R`. `ACC_DATA_KEY` is required locally and is never written anywhere.
- If these estimates are later used to tune the microsimulation, they stop being an independent evaluation of it; the comparison with EPS remains an exploratory triangulation, since ELSOC regularity is not EPS consumption and S10 is not grams per day.
