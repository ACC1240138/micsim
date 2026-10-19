---
title: "TSM: alcohol consumption transitions harmonized with the EPS engine"
subtitle: "Rounds 7–11, whole-person bootstrap and cross-check against EPS"
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

**Quick orientation:** the same people are followed across five rounds of the Termómetro de la Salud Mental (TSM), rounds 7 to 11, and their drinking category at one round is used to predict the category at the next. The computation is the EPS transition engine ported to this panel: the same six states, the same models, the same person-blocked validation and the same annual layer. What changes is the data layer, because TSM has short intervals, no survey design variables and alcohol items without a recall window. Every result in this notebook comes from the saved tables; the text explains how to read them and does not restate numbers.

## How this notebook relates to version 2 and to the EPS engine

Version 2 of the TSM analysis was built on its own conventions. Version 3 keeps its data reading and linking, which are checked against the version 2 counts, and replaces everything downstream with the EPS engine so that the two Chilean panels produce matrices that can be read side by side. The crosswalk below lists each decision in the three vocabularies.

| Decision | TSM v2 | TSM v3 (this notebook) | EPS engine |
|---|---|---|---|
| States | ND_unknown, FD, cat1–cat4 | N0, FD, C1–C4 | N0, FD, C1–C4 |
| Destination classes | six states | NC, C1–C4 (NC splits into N0/FD by origin history) | NC, C1–C4 |
| Sex labels | Male, Female | Men, Women | Men, Women |
| Age groups | continuous age and age squared | 18–29, 30–44, 45–59, 60–65 at origin | same |
| Intervals | four adjacent links, wave term | R7→R8, R8→R9, R9→R10, R10→R11, each with its elapsed months | VI→VII, VII→VIII, each with its elapsed years |
| Link rule | same `IdPanel` | same `IdPanel`, same sex, age change within the EPS bounds widened by one year, because TSM ages are roster values corrected sporadically; strict EPS bounds as sensitivity | same `folio`, same sex, age change compatible with the elapsed years |
| Former-drinker (FD) rule | drinking observed in any earlier wave | drinking observed earlier and carried along the chain of compatible consecutive interviews; past-only | same chain, plus direct links to every earlier wave; over multi-year links, so EPS FD has abstained for years while TSM FD drank at a compatible interview months earlier |
| Education | reached level (three levels) | completion-based level inferred from level, last grade approved and attendance; strict and reached variants as sensitivities | completion-based level from the EPS items |
| HED signal | 6+ item or typical-quantity band | typical-quantity signal as auxiliary; 6+ item reported separately | typical-quantity signal from beverage quantities |
| Conversion | lookup, drinks × grams per drink | same lookup; 12 g primary, 15.7 g sensitivity, upper band sensitivity | beverage frequency × quantity; 12 g primary, 15.7 g sensitivity |
| Weights | origin `Fact_Exp` × follow-up IPW | origin `Fact_Exp` × three-stage IPW with two constant stages; floor, clipping, fixed period mass | official or cross-sectional weight × three-stage IPW |
| Models | empirical, Gamma, lognormal, ordinal | EPS set: A, Multinomial, Gamma, Lognormal, two-part ordinal, non-proportional two-part, single ordinal, JRT reference, education variants, plus a TSM-extras lognormal | same set without the TSM extras |
| Validation | five person folds | five person folds, three repeats, inner tuning of shrinkage, paired contrasts with person clusters | same with PSU/strata clusters |
| Uncertainty | pair and person bootstrap | whole-person bootstrap only, IPW refitted | JKn design replicates primary, person bootstrap as sensitivity |
| Annual layer | none | continuous-time generator fitted to the four intervals jointly | generator fitted to the two intervals jointly |

The first code cell sets the session; the two cells that follow it contain the data layer and the model layer, embedded verbatim so that the notebook is self-contained.

<!-- code:tsm-session-setup -->

## Data, population and states

The alcohol module is answered by one panel respondent per household. The analysis population is respondents aged 18 to 65 at the origin round; the destination age is not restricted. A destination record is accepted as the same person only when it has the same sex and an age change compatible with the months elapsed between the two rounds; otherwise it is treated as not linked and counted in the link audit. The EPS bounds are widened by one year on both sides: the TSM age is a household-roster value that interviewers revise only when they notice it, so an age that jumps by two years between rounds a few months apart marks a corrected age of the same person, and the strict EPS bounds would remove a group that starts drinking more often than the retained pairs. The strict bounds are kept as a sensitivity with its own link audit. The same rule decides which past interviews may inform the drinking history: the flag that drinking was observed travels from each interview of a person to the next observed one when that link is compatible, so an earlier report reaches a later round only through a chain of compatible interviews. EPS also lets the flag travel along direct links to every earlier wave; with TSM's approximate round dates that variant and the direct-only variant both produce a few pairs that contradict the N0/FD map, so the chain is kept, and the EPS-rule and direct-rule counts are exported in the history audit.

**NC means current non-consumption: N0 + FD.** Destinations are modelled in five classes, NC and C1–C4, and the origin history then splits NC into N0 or FD, which gives the six-state matrices. FD is a declared limitation: it requires drinking observed at an earlier compatible interview, so a person whose drinking years precede the panel is N0, and respondents who enter at round 7 are N0 whenever they do not drink. N0 is incomplete history, not lifetime abstention.

| State | Definition |
|---|---|
| N0 | Currently not drinking; no earlier drinking reached this interview through compatible links. |
| FD | Currently not drinking; drinking observed at an earlier interview and carried through compatible links. In TSM this means drinking reported a few months to two years earlier, a different quantity from the multi-year former drinker of EPS; a tenure audit shows how FD grows with the number of earlier interviews. |
| C1 | Women: more than 0 and less than 20 g/day; men: more than 0 and less than 40. |
| C2 | Women: 20 to less than 40; men: 40 to less than 60. |
| C3 | Women: 40 to 100; men: 60 to 100, including 100. |
| C4 | More than 100 g/day in either sex. |

**From response bands to grams.** The frequency item gives drinking days per week and the typical-quantity item gives drinks per drinking day; both are banded. Following the frequency × quantity / 7 logic of Calvo and colleagues, average drinks per day and grams per day are

$$
D=\frac{F\times Q}{7},\qquad G=g\,D,\qquad g\in\{12,\ 15.7\}.
$$

The lookup assigns each band a single value: the midpoint of closed bands, half an occasion per month for "monthly or less", five and a half days per week for "four or more per week", and the lower bound for the open "ten or more" band.

| Frequency code | Label | Days per week | Quantity code | Label | Typical drinks |
|---|---|---|---|---|---|
| 1 | Never | 0 | 1 | 0–2 | 1 |
| 2 | Monthly or less | 0.5 × 7 / 30.4375 | 2 | 3–4 | 3.5 |
| 3 | Two to four times a month | 3 × 7 / 30.4375 | 3 | 5–6 | 5.5 |
| 4 | Two to three times a week | 2.5 | 4 | 7–9 | 8 |
| 5 | Four or more times a week | 5.5 | 5 | 10 or more | 10 |

With this lookup the largest reconstructable exposure at 12 g per drink is below the C4 threshold, so **C4 cannot be observed at 12 g**; the parametric models can still assign probability to it through their tails, and the 15.7 g and upper-band sensitivities show how much the classification moves. The raw codes stay in memory next to the derived variables.

**Education.** EPS classifies people by the level they completed. TSM asks three things: whether the person is currently attending (`b1`), the level reached, worded as "nivel más alto alcanzado o el nivel educacional actual" (`b4a`), and the last grade approved in that level, worded as "último curso que aprobó (para los que no están estudiando), o que cursa actualmente (para los que están estudiando)" (`b4b`). Completion is therefore inferred: a level counts as completed when the last approved grade reaches the length of that level, and a person currently attending has not completed the level in progress, because for them `b4b` is the current grade. Three rules are compared.

| `b4a` level reached | Lenient rule (primary) | Strict rule | Reached rule (v2) |
|---|---|---|---|
| Basic or lower (codes 1–4) | Primary completed or less | same | Primary completed or less |
| Secondary, scientific-humanist or technical (5, 6) | Secondary completed if `b4b` is at least 4, otherwise Primary | same | Secondary completed |
| Higher technical (7) | Tertiary if `b4b` is at least 2, otherwise Secondary | Tertiary if `b4b` is at least 3 | Tertiary |
| University (8) | Tertiary if `b4b` is at least 4, otherwise Secondary | Tertiary if `b4b` is at least 5 | Tertiary |
| Postgraduate (9) | Tertiary | same | Tertiary |
| Attending (`b1` = 1) | the level in progress is not completed: secondary in progress → Primary; higher in progress → Secondary; postgraduate in progress → Tertiary | same | not used |
| None or missing (10, NA) | Missing | Missing | Missing |

Education enters the models as an ordinal score with a separate missing indicator, as in EPS; the level-by-grade counts of every round are exported so the rule can be audited.

**Typical-quantity signal.** EPS carries an auxiliary signal for high typical quantity. In TSM the harmonized signal is positive when a current drinker reports a typical-quantity band whose lower bound is five or more drinks, which lies above both sex-specific thresholds, and zero for the two lowest bands; women in the three-to-four band cannot be separated from the four-drink threshold and are coded zero with an ambiguity flag, so for women the signal is a lower bound and is not comparable with the EPS share. TSM also has a direct item on six or more drinks on one occasion, with no recall window; it is TSM-only, is not a predictor in the main models and is reported separately by destination category. Neither signal is ENPG's 30-day heavy episodic drinking.

<!-- code:tsm-data-design -->

## Weights and inverse probability weighting

The only released weight is the round-specific cross-sectional expansion factor `Fact_Exp`; there is no longitudinal weight, no primary sampling unit and no stratum. The origin weight is combined with the EPS three-stage inverse-probability correction. The three stages are the probability that the origin classification is observed, the probability that the destination record is linked given the origin, and the probability that the destination classification is observed given the link. In TSM the first and third stages are constant: every respondent in the risk set has a complete alcohol module at origin, and every compatible destination record has one too, so only the link stage is estimated. Its model uses the interval, origin state, sex, age group, education, log grams, the typical-quantity signal, the 6+ item, the depression screener, region, employment, partnership, home ownership, the number of earlier interviews and an indicator of entry after round 7.

Observation probabilities have a floor, completed weights are clipped at the training percentiles within each period, and each period keeps the mass of its observed complete pairs, so the pooled data are an analytical mixture of four weighted populations rather than one annual cohort. The link model and the clipping percentiles are learned inside every training fold and every bootstrap replicate, never on the held-out people; the probability floor is a fixed constant. Kish's effective sample size summarises weight dispersion and is not multiplied into any interval.

<!-- code:tsm-weight-audit -->

## Models and fair comparison

The regression models receive the same information: previous state, log grams at origin for drinkers, sex, age group and their interaction, the interval and education. A uses only the origin-state cells by sex, age group and interval, and JRT_reference is the published specification without grams or education. The common right-hand side of the regression models is

$$
\text{state}_0 + \text{sex}\times\text{age group} + \text{period} + \log g_0 + \text{edu} + \text{edu missing}.
$$

| Model | What it does |
|---|---|
| A | Shrunken empirical matrix: cell counts borrow from sex, period and global margins; shrinkage strength tuned inside training. |
| A_education | The same matrix stratified additionally by education level. |
| Multinomial | Multinomial regression on the five destination classes. |
| Gamma | Two parts: participation at the next round, then a Gamma distribution of grams; class probabilities integrate the fitted distribution between the cutpoints. |
| Lognormal | Same two parts with a lognormal amount. |
| Ordinal_two_part | Participation, then a proportional-odds model over C1–C4. |
| NonPO_two_part | Participation, then a multinomial amount model, to test proportional odds through prediction. |
| Ordinal_single | One proportional-odds model over NC and C1–C4. |
| JRT_reference | The published JRT specification: state × age group, state × sex, sex × age group and period; no grams, no education. |
| Gamma_no_education, Gamma_education_interaction, Lognormal_education_interaction | Education removed or interacted with baseline drinking, sex and age. |
| Lognormal_tsm_extras | The common formula plus the TSM-only origin covariates (signal, 6+ item, depression screener, region, employment, history length). |

The main models compared in every table are A, Multinomial, Gamma, Lognormal, Ordinal_two_part, Ordinal_single and JRT_reference. The parametric amount models "share information" in the sense that a person's predicted distribution is informed by everyone with similar covariates, which allows a positive probability of C3 and C4 even where no such destination was observed; the price is dependence on the assumed shape. Dispersion is estimated with normalised weights, so multiplying every weight by ten must leave the predictions unchanged, and this is checked.

**Log loss, in plain words.** Each model assigns a probability to the category that actually happened. Log loss is minus the logarithm of that probability, averaged over the observed pairs with their weights. Suppose three people are observed: the first stays in C1 and the model gave that outcome probability 0.8, the second moves to NC with probability 0.5, and the third moves to C3 with probability 0.1. Their individual losses are −log 0.8, −log 0.5 and −log 0.1, and the average is the log loss. Exponentiating minus the log loss returns the "typical probability" the model gave to what happened, a geometric mean that is easier to read than the loss itself. The Brier score instead sums squared differences between the probability vector and the observed indicator, and accuracy only asks whether the most probable class was the observed one. All three are computed on held-out people.

**Bootstrap versus cross-validation.** Cross-validation answers "how well does the model predict people it has not seen?": the people are split into five groups, each group is predicted by models trained on the other four, with IPW and shrinkage learned on the training part, and the split is repeated three times with different seeds. The bootstrap answers "how much would the estimates move if a different sample of people had been interviewed?": people are resampled with replacement, all pairs of a person move together, IPW and models are refitted, and the spread of the refitted estimates gives the interval. The first measures predictive quality, the second measures sampling uncertainty; neither replaces the other.

Paired contrasts are differences in log loss between two models on the same held-out pairs, with intervals that treat each person as a cluster; they are conditional on the fitted held-out predictions. Every pair among the main models is reported.

<!-- code:tsm-model-validation -->

## Calibration and the model decision

Calibration compares, for each destination class, the weighted share actually observed with the mean predicted probability, on held-out predictions. The same comparison is repeated within each origin cell, defined by origin state, sex and age group, so that a model that is right on average but wrong for a particular group can be seen; cells with few origin rows are flagged as sparse and should be read with that in mind.

The decision table records which model has the best average log loss and which has the best Brier score, and the paired contrast between Lognormal and A with its interval and its mean change in class probabilities. A contrast whose interval excludes zero separates the two scores clearly; one that includes zero does not, and a clear separation can still be small in practical terms.

<!-- code:tsm-calibration -->

## Matrices and whole-person bootstrap intervals

Each matrix row averages the predicted probabilities among the people actually observed in that origin state, keeping their own grams and education. Rows without people are left empty and marked as unsupported; structural zeros, such as N0 to FD, are marked separately. Matrices are reported by period, sex and age group, pooled by sex and age group, pooled over everyone, and by education level. The pooled tables mix the four interval lengths, weighted by their pairs, so they are not probabilities over a defined horizon; the per-interval matrices are the primary TSM product.

Because TSM has no sampling design variables, the only uncertainty computed is the whole-person bootstrap: each replicate resamples people, applies the same multiplier to all pairs of a person, refits the link model, the weights and the outcome models, and recomputes every matrix and the annual generator. Intervals are built on the logit scale from the replicate standard deviation and are bounded at zero and one; rows unsupported in any replicate receive no interval rather than a fabricated one. Any failed replicate stops the inference. A stability table shows how the interval widths change with the number of replicates, and the Gamma and lognormal coefficients are exported with the same intervals.

<!-- code:tsm-person-inference -->

## Transport, earlier history and rank matching

Transport trains the models on three intervals and tests on the fourth, with the test people removed from training, and repeats this for each interval; held-out rows borrow the period effect of the training interval closest in elapsed months, and the link weights of the held-out interval are fitted on training people only. It asks whether what is learned in some periods predicts another period of the same panel; it does not predict a future calendar period.

The history check uses pairs whose origin round has itself a compatible earlier round and compares models with and without the earlier state and grams. If adding the earlier state does not improve held-out prediction after adjustment, the data do not contradict the first-order Markov simplification; they do not prove it either. The Chapman–Kolmogorov diagnostic compares, on three-round cohorts with collapsed states, the direct two-step transition with the product of the two one-step matrices; it is a marginal composition check with a bootstrap interval, not a test.

Rank matching reproduces the margins of the observed panel within each sex and age group by coupling ranks instead of following individuals; comparing its matrix with the observed one shows how much persistence is created by the coupling itself.

<!-- code:tsm-transport-history -->

## Annual probabilities: an additional modelling layer

The four intervals have different lengths. A single continuous-time generator with non-negative off-diagonal rates is fitted to all four jointly, each with its elapsed years, and the annual matrix is its exponential:

$$
P(\Delta)=\exp(Q\Delta),\qquad P(1)=\exp(Q).
$$

**What the annual staying probability means.** Take two states, drinking and not drinking, and suppose the observed matrix over an interval of half a year shows that a drinker is still a drinker at the end with probability 0.9. The annual staying probability is not 0.9 squared, because during the year the person can leave and come back; the generator describes the rates of leaving and returning per unit time, and the annual matrix is what those rates produce over one year. At 12 g per drink no pair starts in C4, so its annual row is not estimated: it is reported as an unobserved origin with a blank estimate and no interval. The rows that rest on few people are C2 and C3, flagged sparse: their annual probabilities are model-derived numbers that depend on the penalty and the starting values of the optimiser, and their bootstrap intervals are wide. The sensitivity table repeats the fit with a weak, a primary and a stronger penalty and reports the largest change in any annual probability; large changes keep this layer exploratory. Time-homogeneous rates are an assumption, and the four intervals test it: each interval is also fitted alone, and a table compares its reconstruction error and staying probabilities with the joint generator's. A joint error well above the single-interval errors means the intervals imply different rates, so the annual matrix is a compromise between them, and short windows turn within-year fluctuation of infrequent drinkers into annual exits. Annual intervals come from the bootstrap replicates and condition on the primary penalty and start.

<!-- code:tsm-annual-layer -->

## Cross-check against EPS

The EPS notebook exports annual matrices for A, Gamma and Lognormal with design-based intervals, and the observed-origin matrices of its two intervals. Three comparisons are made with aggregates only. First, the annual staying probabilities of the two panels are placed side by side, each with its own interval. Second, a generator is recovered from each EPS annual matrix, projected to the TSM interval lengths and scored on the observed TSM pairs, next to the TSM models' in-sample and held-out scores and an origin-only TSM matrix, which is the like-for-like reference because the EPS projection also conditions on the origin state alone. Third, the TSM generator is projected to the EPS interval lengths and compared with the EPS observed-origin pooled matrices on the five collapsed destinations; the FD origin is flagged as not comparable, because TSM FD and EPS FD are different constructs.

This is external consistency, not validation. The populations differ, the periods differ, the instruments differ in wording and recall window, and the TSM intervals are months while the EPS intervals are years, so agreement does not establish that either engine is right and disagreement does not identify which one is wrong.

<!-- code:tsm-eps-crosscheck -->

## Merged C3 + C4 variant

The SIMAH microsimulation and the NESARC-based transition literature it draws on use a top category that merges the two highest volume levels. The variant here merges C3 and C4 into C3plus at origin and destination, refits A, Lognormal and Ordinal_single, repeats the cross-validation (one repeat), the pooled matrices and the annual layer, and places the staying probabilities next to the six-state ones. The scores are not comparable across variants because the outcome classes differ; the matrices show what the merge does to the top row.

<!-- code:tsm-merged-C3plus -->

## Sensitivities

Conversion: every main model is refitted at 15.7 g per drink, and the pooled matrices at that conversion are exported; the difference measures how much classification depends on drink size and does not say which size is correct. Upper band: the open "ten or more" band is set to sixteen drinks instead of ten. Weights: base weights alone, base weights trimmed at the same percentiles, untrimmed IPW weights and the primary trimmed IPW weights, so the inverse-probability correction is separated from the trimming. Education: the strict and reached rules replace the lenient one, with cross-validated scores for A and Lognormal and pooled matrices. Link rule: the strict EPS age bounds replace the primary widened bounds, for destination links and for the history chain, with their own link audit, the pairs retained, cross-validated scores and pooled matrices. Typical-quantity signal: its weighted share by destination category and a person-clustered regression on destination, sex, age group, origin signal and period; the 6+ item is tabulated by destination category and by origin state.

<!-- code:tsm-sensitivities -->

## Limitations, review and reproducibility

- The TSM alcohol items have no recall window, so "current drinking", FD and the quantity signals are proxies, not ENPG 30-day constructs.
- No primary sampling units or strata are released; `Fact_Exp` is cross-sectional, and the whole-person bootstrap is the only uncertainty computed. It does not reconstruct the original design variance.
- Round dates are approximate fieldwork months, and the date of round 11 is unverified; the elapsed months, and with them the link rule and the annual layer, inherit this approximation.
- C4 is unreachable at 12 g per drink with the primary lookup; its probabilities come from model tails and from the conversion sensitivities.
- TSM intervals are short compared with the multi-year EPS intervals; short intervals observe fewer changes and make the annual layer depend more on the generator assumptions.
- FD requires observed earlier drinking within the panel; N0 is incomplete history. TSM FD identifies people who drank within the previous year or two, so its relapse rate is a different quantity from the EPS former-drinker row.
- Pooled next-round tables mix four interval lengths; only the annual layer compares with EPS, with the caveat that a generator fitted to months-long windows is a compromise across intervals.

The checks recorded during execution are listed in the table below and exported together with the configuration, the fit warnings and the session information without machine paths. The notebook is executed in a fresh kernel twice, in the working output folder and in a reproduction folder; an external verifier compares the exported tables byte by byte, checks the notebook metadata against the source files and inserts the quick-reading summary and the reproduction check. Reproducing results does not prove the assumptions true.

<!-- code:tsm-reproducibility -->

## References

- Calvo E, Medina JT, Ornstein KA, Staudinger UM, Fried LP, Keyes KM. Cross-country and historical variation in alcohol consumption among older men and women: leveraging recently harmonized survey data in 21 countries. *Drug and Alcohol Dependence*. 2020;215:108219. DOI [10.1016/j.drugalcdep.2020.108219](https://doi.org/10.1016/j.drugalcdep.2020.108219).
- Kilian C, Buckley C, Lemp JM, Kou X, Kerr WC, Mulia N, Purshouse RC, Rehm J, Probst C. Targeting alcohol use in high-risk population groups: a US microsimulation study of beverage-specific pricing policies. *Lancet Public Health*. 2025. DOI [10.1016/S2468-2667(25)00165-3](https://doi.org/10.1016/S2468-2667(25)00165-3).
- Puka K, Buckley C, Mulia N, Lasserre AM, Rehm J, Probst C. Educational attainment and lifestyle risk factors associated with all-cause mortality in the US. *Addiction*. 2023. DOI [10.1111/add.16024](https://doi.org/10.1111/add.16024).
- SIMAH microsimulation, release 0.1.1. DOI [10.5281/zenodo.15641639](https://doi.org/10.5281/zenodo.15641639). This notebook estimates Chilean transition components; it does not execute SIMAH or import US parameter values.
- EPS engine and notebook: `__andres_control/eps_markov_core.R`, `__andres_control/eps_markov_transitions_EN.ipynb`; harmonization source `__andres_control/eps_alcohol_prevalencia_persistencia.ipynb`.
- TSM version 2 notes and outputs: `_tsm/notes/TSM_ENPG_v2_EN.md`, `_tsm/notes/TSM_ENPG_v2_findings.md`, `_tsm/notes/v2_outputs/`; version 3 contract `__andres_control/tsm_v3_plan_2026-10-19.md`; questionnaires in `_tsm/docs/`.
