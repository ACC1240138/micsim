## Why a version 4

Versions 1 and 2 above run unchanged. Version 4 makes five changes, all agreed on 2026-10-26 and recorded in `__andres_control/decision_categorias_who_12g_2026-10-26.md`:

1. **WHO categories without gaps.** The exact border value goes to the lower class: women C1 up to 20, C2 above 20 and up to 40, C3 above 40 and up to 60, C4 above 60 g/day; men 40, 60 and 100. Versions 1 and 2 put the lower borders in the upper class (the JRT convention), with the women's top cut already at 60 since 2026-10-26.
2. **12 g per drink**, the convention adopted by JRT after the reviewer comments on ADD-25-1576. No sensitivity with 13 g or with the JRT border convention is run.
3. **C3 and C4 always merged into C3plus.** The heavy tail is too sparse for two states. This follows Puka et al. (2022), who use non-drinker plus three WHO categories with the top one at 41 g (women) and 61 g (men) or more, and Kilian et al. (2025). Puka et al. also merge lifetime abstainers and former drinkers into one non-drinker state because lifetime abstention is reported inconsistently. C4 is kept only as a diagnostic of how well each model recovers the tail.
4. **EPS 2009 (round IV) as history.** It identifies former drinkers at VI, which versions 1 and 2 could not, and long-term abstainers in the sense of Calvo et al. (2020). It is never used as a transition interval.
5. **Widened age tolerance for links.** Every link window is widened by three years on each side (decision 2026-10-26). EPS identifiers (`folio_n20`) are stable person codes and the public files carry no birth or interview dates, so the age check only guards against gross coding errors: pairs gained between one and three years of tolerance look like the same people (education agrees as often as in strict pairs), while gaps beyond three years show twice the education inconsistencies and stay excluded. Pairs whose sex differs between waves are excluded.

The amount models are then compared formally: the v1 lognormal and gamma, a lognormal with variance by sex and age, a lognormal with a Pareto tail and a hurdle mixture. All use the same held-out predictions and the same metrics, with recovery of the observed C3plus and C4 shares as the priority. The adoption rule was written down before any result was seen.

The code is shown in chunks, each explained first, so the notebook can be audited without opening other files. The v1 core (`eps_markov_core.R`) is also split into explained chunks near the top, and the three cells that `ep_load()` runs from the alcohol persistence notebook are reproduced and checked against their source.

## v4 switches and the scoped swap

All v4 settings live in one list, `ep_v4_cfg`. A second list, `ep_v4_off`, turns every v4 change off; with it, the v4 code reproduces the v1/v2 classification, links and history. That gives one exact regression test for everything v4 adds.

<!-- code:eps-v4-def-config -->

Some v1/v2 functions read two global objects: the link windows (`ep_time`) and the per-interval pair counts used to renormalise weights (`ep_period_mass`). v4 needs other values for some calls, but the v1/v2 cells above must keep theirs. `ep_v4_scoped()` swaps the globals only while one expression runs and restores them on exit, even after an error. The reproducibility section checks that every v1/v2 object is unchanged at the end.

<!-- code:eps-v4-def-scoped -->

## Categories: the WHO border rule

With 12 g per drink and "less than weekly" coded as half a day, EPS grams per day are multiples of 6/7 g. Comparisons are therefore made in lattice units (grams × 14 / 12), so a value of exactly 60 g cannot become 59.9999 through floating point. Both rules are contiguous, and the function stops if any current drinker with positive grams is left without a class.

<!-- code:eps-v4-def-classification -->

The table below counts the observations that fall exactly on a border. At 12 g only 60 g/day can occur exactly (70 × 6/7), so the WHO rule changes the class of men at exactly 60 g/day, from C3plus to C2, and nobody else.

<!-- code:eps-v4-config -->

## EPS 2009 as history

The 2009 survey asks the same three alcohol questions as VI–VIII, under zero-padded names (`f13_01`, `f14_01`, `f15_01`, and so on). One coding difference matters. The 2009 frequency question runs from 1 (less than one day a week) to 8 (every day), while later waves run from 0 to 7. 2009 is therefore shifted down by one before the unchanged conversion `eps_alcohol()`. Without the shift, daily drinkers would become missing and everyone else would gain a day per week. Sex and age come from `entrevistado.dta` (`a8`, `a9`). The 2009 file has a cross-sectional weight but no PSU or stratum.

<!-- code:eps-v4-def-history2009 -->

The link from 2009 to VI uses an age window of 6 to 8 years, widened by the tolerance. The 2009 fieldwork dates were not found, so the window comes from the observed age differences, whose mode is 7. History flows along the chain of compatible interviews: 2009 to VI, VI to VII, VII to VIII and VI to VIII. Direct links from 2009 to VII or VIII are not used.

Long-term abstention follows Calvo et al. (2020): no drinking for at least four years and no evidence of earlier drinking. A negative pair at least four years apart sets the flag. A current non-drinker linked to an earlier long-term abstainer keeps it, since the four-year span then holds a fortiori. Any observed drinking clears it. This is a proxy: 843 to 929 people who drank at VI had reported not drinking in 2009, so a negative report is not proof of never drinking.

<!-- code:eps-v4-def-waves-risk -->

<!-- code:eps-v4-def-history-tables -->

The 2009 history is evaluated before any amount model is fitted, in three steps. Which N0 respondents become FD, and who becomes a long-term abstention candidate. Whether the transition pairs themselves change (they must not). How the observed VI→VII and VII→VIII matrices move. Two IPW variants are shown. With the weights refitted on the v4 risk set, drinker rows can move slightly, because the response model uses the origin state. With the weights fixed at the fit without 2009, only the N0 and FD rows can move, and the notebook checks that they are the only ones that do.

<!-- code:eps-v4-history-2009 -->

## Amount models: one harness, identical metrics

Every amount model returns a distribution of grams per day for destination drinkers, given covariates. Class probabilities are then obtained in the same way for all of them, by integrating that distribution between the cuts. For a continuous distribution, ≤ and < give the same probability, so the border rule changes the observed labels but not the predictions.

The candidates are listed below.

- **Lognormal**: the v1 model, unchanged.
- **Gamma**: the v1 model, unchanged.
- **Lognormal_sexage**: the variance of log grams is allowed to differ by sex and age group, shrunk toward the pooled variance with a strength chosen by inner cross-validation. With infinite shrinkage it is the v1 lognormal.
- **Lognormal_Pareto**: a lognormal up to each sex's training 90th percentile, then a Pareto tail with a Hill exponent. The mass above the splice point still comes from the lognormal; only the shape of the tail changes.
- **Hurdle_Pareto** (the mixture): a logistic model for crossing the C3plus cut, a lognormal truncated below the cut, and a Pareto tail above it.

<!-- code:eps-v4-def-amount-models -->

The cross-validation reuses the v1 person-blocked folds (five folds, three repeats, same seeds), refits the v1 IPW inside each training fold, and fits one participation model per fold that every amount model shares. The non-drinking column is therefore identical across models, and every score difference comes from the amount model. Model A is carried along as a benchmark. It is not eligible for adoption, because it gives class probabilities but no grams distribution.

The metrics are the same for every model:

- four-class logloss, Brier score and accuracy, plus the paired logloss difference from the lognormal with a design-based (PSU/strata Taylor) interval;
- logloss given drinking, and the log score of the observed grams on their 6/7 g lattice cell;
- predicted against observed shares of C3plus and C4, pooled and by sex, with design intervals;
- C3plus calibration by interval × origin and by sex × age group;
- the observed tail (shares above the cuts and the 95th and 99th percentiles), and the mean grams among C3plus destinations truncated at 150 g/day, the bound of the AAF integration;
- a randomized PIT for all destination drinkers, and a tail PIT conditional on exceeding the training 90th percentile, which should be uniform if the tail shape is right.

**Adoption rule, written down before the results were seen.** A candidate replaces the lognormal only if all three conditions hold:

1. Its C3plus calibration error, |log(predicted / observed)|, is smaller than the lognormal's pooled and in each sex, and the interval for predicted minus observed covers zero.
2. The lower bound of its paired logloss difference from the lognormal is at most zero, i.e. it is not shown to be worse.
3. It creates no new biased cell: no non-sparse C3plus cell has an interval that excludes zero where the lognormal's did not.

Ties are broken by the largest cell error, then by C4 recovery, then by the grams log score.

<!-- code:eps-v4-def-metrics -->

<!-- code:eps-v4-amount-models -->

**How to read the decision.** The hurdle mixture fits a logistic model directly to the C3plus indicator, so its pooled C3plus calibration is close to exact by construction. What separates it from the lognormal with a Pareto tail is the cell-level error. The unpenalised hurdle logistic is quasi-separated: women aged 60–65 have no C3plus destination, and the education-missing indicator is nearly empty. It therefore assigns a C3plus probability close to zero to those cells, which would be a structural zero in a microsimulation. A ridge-penalised hurdle is reported as a declared sensitivity. It was added after the pre-registered comparison and is not eligible for adoption. Any Pareto tail is truncated at 150 g/day when grams are drawn.

## Final five-state matrices

<!-- code:eps-v4-def-matrices -->

The matrices are fitted on all v4 pairs for the adopted model, the runner-up, the v1 lognormal and the ridge sensitivity. Intervals come from the v1 stratified jackknife, with IPW, participation and amount models refitted in every replicate. The last table compares the pooled v4 matrix with the v2 lognormal collapsed to five states.

<!-- code:eps-v4-matrices -->

<!-- code:eps-v4-def-figures -->

<!-- code:eps-v4-figures -->

## Reproducibility of version 4

The last cell proves that the v4 cells left every v1/v2 object unchanged, records the md5 of the source files, and stops if any check failed. The annual (continuous-time) layer for the five-state matrices is not part of version 4; it is the next step for the microsimulation.

<!-- code:eps-v4-reproducibility -->
