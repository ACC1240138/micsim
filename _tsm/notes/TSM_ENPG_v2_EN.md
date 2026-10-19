---
title: "TSM: pooled drinking transitions aligned with ENPG"
subtitle: "Category-based validation of empirical, Gamma, lognormal and ordinal models"
author: "Andres Gonzalez Santa Cruz"
date: last-modified
lang: en
format:
  html:
    theme: journal
    css: [_lib/styles.css, _lib/prediction_metrics_compact.css]
    toc: true
    toc-location: left
    toc-depth: 2
    number-sections: true
    code-fold: true
    code-summary: "Show R code"
    code-tools: true
    embed-resources: true
    self-contained: true
    html-math-method: mathml
    fig-cap-location: top
execute:
  echo: true
  warning: true
  error: false
lightbox: auto
---

::: {.callout-note}
## What this version estimates

Next-wave drinking probabilities from **all available consecutive observations of the same people** in R7–R11. The six output states are **ND_unknown, FD, cat1, cat2, cat3 and cat4**. Models share information across age, sex and education; separate education matrices are predictions from these pooled fits.

**12 g per drink is primary; 15.7 g is a separate sensitivity.** These match the two raw conversion paths in `expand_pif.ipynb`. No APC adjustment or ENPG calibration is applied here. Validation compares predicted **categories and their probabilities**, without RMSE.
:::

<!-- code:setup -->

## Analysis flow

<!-- code:flow -->

## People, pairs and observed history

The study target remains **ages 15–65**. TSM supplies transitions for **ages 18–65 at origin**; estimates for ages 15–17 are not supplied. The linkage key is `IdPanel`, restricting each file to `Entrevistado = 1`. All four adjacent links, R7→R8 through R10→R11, contribute. A person can contribute several pairs, enter later or return after an absence. Different people are never matched to manufacture a transition.

| Output state | Operational definition |
|---|---|
| `ND_unknown` | No current drinking reported and no drinking observed in any earlier available wave. Lifetime abstinence is **not** established. |
| `FD` | No current drinking reported, with drinking observed in **any earlier available wave**. An approximation to ENPG former drinking, without its verified 30-day window. |
| `cat1`–`cat4` | Current drinking, classified by reconstructed grams/day using the ENPG cutoffs below. |

History is constructed before age restriction, using only earlier waves. Current drinking establishes known drinking history for future predictions. Thus an observed current drinker who stops enters `FD`; someone in `ND_unknown` who remains a non-drinker stays in `ND_unknown`. All original alcohol codes remain in memory as `e3a1`, `e3a2` and `e3a3`; new variables do not overwrite them.

<!-- code:inputs -->

“Absent follow-up” does not distinguish non-contact, refusal, ineligibility or death. “First observed” does not by itself establish official panel replenishment. IPW addresses observed follow-up conditional on measured predictors; it cannot recover unobserved lifetime drinking history. Later entries with no prior positive report retain `ND_unknown` when they do not drink.

## From response bands to ENPG categories {#conversion}

Calvo et al. describe the frequency–quantity conversion as: “we multiplied these harmonized frequency and quantity measures and divided the product by seven.” The same arithmetic is used here, with **TSM-specific response-band assumptions**. [Calvo et al., 2020](https://pmc.ncbi.nlm.nih.gov/articles/PMC7585691/)

$$
D_{it}=\frac{F_{it}\,Q_{it}}{7},\qquad G_{it}^{(g)}=gD_{it},\qquad g\in\{12,15.7\}.
$$

$F$ is drinking days/week, $Q$ is drinks per drinking day, $D$ is average drinks/day and $G$ is grams/day. This cites the conversion method, **not Calvo's five drinking-pattern states**. The output keeps the requested ENPG categories.

| State | Women: grams/day | Men: grams/day |
|---|---|---|
| `cat1` | $0<G<20$ | $0<G<40$ |
| `cat2` | $20\leq G<40$ | $40\leq G<60$ |
| `cat3` | $40\leq G\leq100$ | $60\leq G\leq100$ |
| `cat4` | $G>100$ | $G>100$ |

The lookup below uses midpoints for closed bands, **0.5 occasions/month** for “monthly or less”, **5.5 days/week** for “4+/week”, and the **lower bound of 10 drinks** for “10+”. These are assumptions, not observed exact amounts. The 0–2 band is assigned one drink among current drinkers.

<!-- code:conversion -->

::: {.callout-important}
## High consumption is weakly identified

With the primary lookup, the maximum reconstructed exposure is $5.5\times10\times12/7=94.29$ g/day. Consequently **cat4 is absent by construction at 12 g**, even though true consumption could be higher. Gamma and lognormal tails can assign cat4 probability, but the survey proxy cannot validate that tail. At 15.7 g, there is only **one observed cat4 destination**. This is a measurement limitation as well as sparse data.
:::

**Connection to `expand_pif`:** its `enpg-consolidate` cell constructs `voltotal` with 12 g and `voltotMS` with 15.7 g; `cvolaj` and `cvolajms` subsequently apply their respective APC factors. That ENPG reconstruction also uses drinking-day and episode information unavailable in TSM. These are therefore **ENPG category thresholds applied to a TSM proxy**, not identical measurements. Comparing external prevalence can assess agreement, but cannot uniquely identify the correct grams per drink: underreporting, band assumptions and survey wording also affect agreement. Separate APC calibration to the same target can cancel a uniform 12-versus-15.7 multiplier.

## HED: the 5+/4+ target and the available signal

The target is ENPG's **5+ drinks for men / 4+ for women in 30 days**. TSM `e3a3` asks about **6+ drinks for both sexes**, without a verified recall window. Exact ENPG HED cannot be recovered.

| Variable | What it measures in this notebook |
|---|---|
| `hed6_reported` | Any non-never report on the original 6+ item. |
| `hed54_typical_signal` | Typical-quantity band has a lower limit at least 5 for men or 4 for women. |
| `hed54_proxy` | Either signal above. Used as an **origin predictor**, with its proxy status explicit. |
| `hed54_ambiguous` | Woman in the 3–4 band without a direct 6+ report; exactly four drinks cannot be distinguished from three. |

The proxy can miss occasional 5-drink episodes in men and 4–5-drink episodes in women, even when typical quantity is lower. Its absence does not establish the absence of ENPG HED. It is neither used to add extra drinks to the Calvo product nor used to redefine the volume categories. Sensitivities use the 6+ signal alone and count unresolved female 3–4 bands as positive.

<!-- code:hed -->

## Fact_Exp and inverse probability of follow-up

Let $R_{i,t+1}$ indicate observed follow-up and $q_{it}$ denote origin `Fact_Exp`. A survey-weighted logistic model estimates follow-up probability $\pi_{it}$ using origin measurements only.

$$
\widehat\pi_{it}=\Pr(R_{i,t+1}=1\mid X_{it}),\qquad
w_{it}=q_{it}\frac{R_{i,t+1}}{\widehat\pi_{it}}.
$$

Predictors are wave, current/history state, age and age squared, sex, education, quantity, frequency, the HED proxy, history length, PHQ-2, broad region, employment, partnership, home ownership and first appearance after R7. The DAG is an assumption about selection, **not evidence that missingness is ignorable**. The identifying assumptions are conditional exchangeability of follow-up, positive observation probabilities and adequate response-model specification.

<!-- code:weights -->

`Fact_Exp` is the available cross-sectional expansion factor; this product is an analytical follow-up adjustment, not an official longitudinal weight. The reviewed materials do not identify UPM or strata. No such variables are inferred. The intervals below remain conditional approximations, rather than full original-design variance estimates. The reported weight-only effective sample size is a diagnostic; **no additional Kish multiplier** is applied to weighted bootstrap intervals.

## Four competing prediction models

| Model | Specification and role |
|---|---|
| **Empirical (“original”)** | Weighted observed transition proportions within origin state. This is the original notebook's matrix benchmark, not a multinomial regression. |
| **Gamma hurdle** | Logistic probability of drinking, then a Gamma model for positive average drinks/day with a log mean. |
| **Lognormal hurdle** | Same drinking component, then a normal model for log positive drinks/day. |
| **Ordinal** | Proportional-odds model for non-drinker, cat1, cat2, cat3, cat4. The two non-drinking histories are merged for ordering and split afterward using known origin history. |

The three regression alternatives use the **same additive origin predictors**: wave, current/history state, age, age squared, sex, education, log(1 + average drinks/day), HED proxy and history length. They use all observed pairs jointly. Education is a predictor; fitting separate models for every cross-classification is unnecessary.

For positive drinks/day, the Gamma model uses shape $k$ and rate $k/\mu_{it}$; the lognormal model uses mean-log $\eta_{it}$ and log-scale standard deviation $\sigma$. Both share participation probability $p_{it}$.

$$
\log\mu_{it}=X_{it}\beta,\quad D_{i,t+1}\mid D_{i,t+1}>0,X_{it}\sim\operatorname{Gamma}\left(k,\operatorname{rate}=k/\mu_{it}\right).
$$

$$
\log D_{i,t+1}\mid D_{i,t+1}>0,X_{it}\sim N(\eta_{it},\sigma^2),\qquad\eta_{it}=X_{it}\gamma.
$$

For a category bounded by $a_j$ and $b_j$ grams/day, its probability integrates the fitted positive distribution $F_+$:

$$
\Pr(C_{i,t+1}=j\mid X_{it})=p_{it}\left[F_+(b_j/g\mid X_{it})-F_+(a_j/g\mid X_{it})\right].
$$

The remaining $1-p_{it}$ goes to `FD` if drinking is already known at origin, otherwise `ND_unknown`. **Reclassifying only the predicted mean would lose this distribution and underrepresent uncertainty.** Simulation should draw participation and positive quantity, then classify the draw. Parametric models may borrow information efficiently, but that advantage depends on their distributional assumptions; it is not guaranteed by being continuous.

### What JRT actually adjusts for

The inspected `jrt/simulacion/Alcohol Transitions FINAL.R` fits:

```r
state_t2 ~ state_t * agecat + state_t * sex + sex * agecat
```

It includes previous category, age group, sex and their pairwise interactions. **HED is carried in the data and used descriptively, but does not enter that regression. Education and survey weights are also absent from that fit.** It uses rank-matched ENPG cross-sections and four levels through cat3, rather than TSM's observed people and requested cat4.

The ordinal comparator here is **JRT-like in its proportional-odds form**, with the common additive TSM predictors and weights above. It is not a literal replication of JRT's interactions. This deliberate simplification avoids a much larger interaction model with very few high-category events. Proportional odds is an assumption, not established by this comparison. An outcome class absent from training receives zero ordinal probability and is reported in the audit.

<!-- code:models -->

## Cross-validation on consumption categories

Five folds hold out **whole people**, including all their origin rows. Each fold refits IPW and every outcome model using training people only. Test scores use the same observed test pairs and origin weight divided by the training-model response probability. This evaluates new people within the observed waves; it does not claim external validation or forecasting a new calendar period.

The primary score is weighted **multiclass Brier** across all six states. Lower is better. Log loss also evaluates probabilities; accuracy compares the most probable category with the observed category. Balanced accuracy averages class-specific recall over categories with observed outcomes. The per-class table is essential because ND_unknown, FD and cat1 dominate the sample.

Compare models **within each conversion**. Changing grams per drink changes the observed category labels, so comparing the 12 g score with the 15.7 g score cannot determine which conversion is correct.

$$
\operatorname{Brier}=\frac{\sum_i w_i\sum_{j=1}^{6}(\widehat p_{ij}-\mathbb{1}\{Y_i=j\})^2}{\sum_i w_i}.
$$

Raw log loss is infinite if an observed outcome receives zero probability. A separate clipped score uses $\max(\widehat p_{i,Y_i},10^{-12})$ only inside the logarithm; **probabilities and Brier scores are unchanged**. Both scores and the number of affected outcomes are exported. If an empirical training row is empty, its predictions use the allowed pooled training destination proportions; fallback counts and weight shares are audited.

<!-- code:cv -->

**Observed comparison:** at 12 g, Brier is 0.3486 for ordinal, 0.3500 for lognormal, 0.3501 for Gamma and 0.3579 for the empirical matrix. At 15.7 g, Gamma has the lowest Brier (0.3602), followed closely by lognormal (0.3606) and ordinal (0.3608). These are small numerical differences; no superiority test is claimed. **Both continuous alternatives remain candidates.** The empirical model has infinite raw log loss in both conversions; the ordinal model does so at 15.7 g because its only cat4 event falls in a test fold whose training sample has no cat4.

## Pooled transition matrices

Predictions are averaged over **all eligible origin observations**, including those without follow-up, using origin `Fact_Exp`. Outcome fitting uses `Fact_Exp × IPW`. Empirical rows reduce to the observed IPW transition proportions. A matrix row with no observed origin support is left undefined.

These are pooled conditional associations. The fitted wave term permits differences between periods; a stationary transition process is not established merely by pooling. The history state must be retained when these probabilities enter a simulation.

<!-- code:matrices -->

## Education without splitting the estimation sample

Each regression is fitted once to the pooled data; the figure then averages predictions within each education-and-origin-state group. This borrows information from the full sample while allowing education-specific probabilities. All four models' education matrices are exported. The empirical benchmark does not adjust for education, so its probabilities within a given origin state are shared across education groups.

These summaries also reflect each group's observed age, sex and wave composition. They are **not causal education effects**. Undefined or weakly supported rows remain visible.

<!-- code:education -->

## Uncertainty: pair and person branches

For the primary 12 g scenario, each branch runs **500 complete bootstrap refits**, including response weights and all outcome models. Pair resampling treats origin opportunities as independent. Person resampling keeps every observation from a sampled person together. Point estimates agree between branches; uncertainty can differ.

The Markov assumption concerns prediction conditional on the specified state; it does not automatically make a person's repeated contributions independent for every estimating equation. Both branches are retained as requested. Neither reconstructs unavailable survey design variables. The person branch is the more appropriate check for repeated-person dependence; it is not an extra multiplier layered onto the pair intervals.

Intervals are suppressed for structural zeros, boundary estimates, fewer than ten origin people, insufficient successful refits or zero bootstrap width. Ten people is a display safeguard, **not a claim of adequate precision**. The 15.7 g scenario receives category validation and point estimates; the full model bootstrap is limited to the primary conversion. Empirical joint-IPW intervals are exported for both conversions.

<!-- code:bootstrap -->

## Sensitivities and remaining limitations

Additional point-estimate branches exclude R7 origins, use only the direct 6+ HED signal, or mark unresolved female 3–4 bands positive. They do not replace the main analysis.

<!-- code:sensitivity -->

- **Recall window:** the reviewed TSM alcohol items do not establish an explicit recall window. “Current”, FD and HED are therefore proxies, not exact ENPG 30-day constructs.
- **Band reconstruction:** amounts within bands and open-ended responses are unknown. Alternative upper-band values are a necessary future measurement sensitivity before trusting high-consumption transitions.
- **History:** observed prior drinking is incomplete; repeatedly negative interviews do not prove lifetime abstinence. FD detection depends on available follow-up history.
- **Rare outcomes:** overall CV performance cannot establish reliable cat2–cat4 transitions. Continuous models can extrapolate tails; ordinal and empirical models cannot learn absent classes.
- **Transport:** ENPG population calibration and independent Chilean validation remain separate next steps. Calibration can align margins without identifying a unique transition matrix; an independent validation sample should not also set calibration targets.

## Reproducibility checks

Only aggregate outputs are exported. Individual held-out predictions remain in memory. Source SAV checksums are checked by the existing loader; a separate manifest checks that earlier notebooks and outputs are unchanged. The following tests use the actual local survey files.

<!-- code:validation -->

**Source:** Calvo E, Medina JT, Ornstein KA, Staudinger UM, Fried LP, Keyes KM. Cross-country and historical variation in alcohol consumption among older men and women: Leveraging recently harmonized survey data in 21 countries. *Drug Alcohol Depend.* 2020;215:108219. [doi:10.1016/j.drugalcdep.2020.108219](https://doi.org/10.1016/j.drugalcdep.2020.108219).

**Local provenance:** `tsm_pooled_core.R` (preserved loading, history and weighted-model helpers); `expand_pif.ipynb`, cell `enpg-consolidate` (12/15.7 paths and ENPG cutoffs); `Alcohol Transitions FINAL.R`, original model formula at lines 165–168. New analysis code is in `tsm_v2_core.R`, `tsm_v2_ordinal.R`, `tsm_v2_diagrams.R` and `tsm_v2_sections.R`.
