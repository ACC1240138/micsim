# TSM version 3 notebook: critical review

This review concerns `TSM_ENPG_v3_EN.ipynb`, its data layer `tsm_markov_data.R` (ported from the version 2 Desktop code in `_tsm/notes/v2_desktop_code/`), its model layer `tsm_markov_models.R` (ported from the EPS engine `eps_markov_core.R`), the cell bodies `tsm_markov_sections.R` and the narrative `TSM_ENPG_v3_EN.md`. The analysis uses the real TSM rounds 7 to 11 from the encrypted bundle `_tsm/tsm.tar.xz.enc`. Three passes shaped the final sources: the implementation reports of the three parallel builders, four dry runs on real data with a shrunken bootstrap, and an adversarial review with four lenses (data layer, model layer, notebook assets, statistical soundness) in which every high or medium finding was challenged by an independent sceptic before being accepted.

## Findings addressed

| Finding | Change and evidence |
|---|---|
| The version 2 state space, labels and covariate conventions did not match the EPS engine. | States N0, FD, C1 to C4 with NC destinations, labels Men/Women, the EPS cutpoints, age groups and the EPS common formula are used throughout. Each count of the version 2 pipeline is reproduced before the new link rule is applied (`v2_regression_check.csv`, 23 quantities, all equal). |
| The literal history rule of the plan (direct compatibility with every earlier wave) contradicted chains of compatible adjacent interviews. | With approximate round dates, direct non-adjacent bounds produced 16 linked pairs that broke the N0/FD map. The chain through the nearest observed earlier interview is used; the direct-link flag, the EPS rule (chain or direct) and the version 2 any-history flag are exported in `abstention_history_audit.csv`. The narrative no longer calls the chain "the EPS rule". |
| The strict EPS age bounds removed 6.9% of present destinations for intervals of four to eight months. | The sceptic reproduced the mechanism on the real data: `a3` is a household-roster age that interviewers correct sporadically (codebook label), the excluded pairs agree with the retained ones on identifiers, region and education, and they start drinking about twice as often. The primary bounds are the EPS bounds widened by one year on both sides (`ts_link_tolerance = 1`), for destination links and the history chain; the strict bounds are a sensitivity with its own link audit, held-out scores and pooled matrices. This is the one confirmed default that was changed on evidence, and it is reversible through one constant. |
| The two-class branch of the class-probability port named its columns "" and "p". | Inherited from the EPS core, where every destination class is observed; in TSM only two positive classes exist in some folds. The columns are now named explicitly. |
| The annual generator reported a C4 row with a tight bootstrap interval although no pair starts in C4 at 12 g. | Rows whose origin state has no observed pairs are reported as unobserved with blank estimates in the annual table, the EPS cross-check and the merged variant; rows with fewer than 30 origin pairs are flagged sparse and carry `n_origin`. |
| The shrinkage grid of matrix A reached its upper boundary. | The grid extends to 3,000 and 10,000; the tuned value is interior in the dry runs. |
| The Chapman-Kolmogorov bootstrap lost most replicates to NA propagation. | An unobserved collapsed origin is treated as zero mass in the matrix product; the diagnostic stays undefined only for that origin. |
| The TSM-to-EPS projection compared six destinations although the generator is fitted on collapsed non-consumption. | Both directions now compare on the five collapsed destinations; the FD origin is flagged as not comparable and a second summary excludes it. |
| The EPS-to-TSM projection was scored next to covariate models only. | An in-sample origin-only TSM matrix is reported as the like-for-like reference, together with in-sample and held-out scores of the TSM models. |
| One time-homogeneous generator across four intervals of different length was not checked. | Each interval is also fitted alone (`annual_interval_fits.csv`), with its reconstruction error and staying probabilities next to the joint generator's within-interval error. The narrative states that the joint matrix is a compromise between intervals. |
| The weight sensitivity confounded the inverse-probability correction with trimming. | Four scenarios separate base weights, trimmed base weights, untrimmed IPW weights and the primary weights, with the effective sample size of each. |
| FD in TSM is not the EPS former-drinker construct. | A tenure audit (`fd_tenure_audit.csv`) reports FD by number of earlier interviews and by months since the last observed drinking; the crosswalk and the state table say that TSM FD means drinking reported months to two years earlier. |
| Pooled next-round tables mix interval lengths. | Captions and the narrative say so; the per-interval matrices are the primary TSM product and only the annual layer compares with EPS. |
| Alternative risk sets were pooled with the primary period masses. | Every variant now uses its own complete-pair masses, both in the point-estimate wrapper and in the cross-validated variant scores. |
| The verifier did not enforce the number of cross-validation repeats, and its summary cell headlined a row supported by five origin pairs. | The verifier asserts three repeats and 1,000 replicates; the summary reports N0 and C1 with their support and counts, and the merged C3plus row with its support. Links in the inserted cells point to the control folder. |
| The Gamma amount model failed to converge by IRLS in one cross-validation fold under the widened link rule. | The convex Gamma log-mean objective is minimised by BFGS when IRLS does not converge, as the version 2 Desktop code did; the fallback is recorded in `fit_warnings.csv`. The EPS core has no such fallback because its folds are larger. |
| A duplicated helper lost its row guard depending on sourcing order. | Both definitions of the design-matrix helper carry the same row-count guard. |

## Interpretations that remain conditional

- **Construct gap, not calibration.** The TSM alcohol items have no recall window, the intervals are four to eight months, and more than half of current drinkers report drinking monthly or less. A generator fitted to such windows turns within-year fluctuation into annual exits, so TSM annual staying probabilities are lower than the EPS ones by construction. The cross-check measures this gap; it cannot say which engine is calibrated.
- **Support.** At 12 g per drink the panel observes transitions between non-drinking and C1 almost exclusively; C2 and C3 origins number in the single digits and C4 does not occur. Every C2 to C4 row, the merged C3plus variant and the C2 to C4 lines of the cross-check are model extrapolation, flagged as sparse or unobserved.
- **FD.** TSM FD identifies people who drank within the previous year or two and relapse often; it is not the multi-year former drinker of EPS and should not be compared with it, which the `comparable` flag records.
- **Link rule.** The widened bounds keep almost every present destination; the remaining exclusions are large age jumps, age decreases beyond one year and one sex change. The strict-bounds sensitivity shows what the EPS rule would have done.
- **Weights.** `Fact_Exp` is cross-sectional; no primary sampling units or strata exist. The whole-person bootstrap is the only uncertainty computed and does not reconstruct the original design variance.
- **Typical-quantity signal.** For women the signal is a lower bound, because the four-drink threshold falls inside the three-to-four band; it is not comparable with the EPS share.
- **Education.** Completion is inferred from the level reached, the last approved grade and attendance; the tertiary thresholds are a judgement call bounded by the strict and reached variants.

## Not done, by decision

- No design-based variance, because TSM releases none.
- No calibration to ENPG prevalences and no independent validation; the plan reserves them for the microsimulation integration.
- No literal replication of the version 2 pair bootstrap, replaced by the whole-person bootstrap of the EPS engine.
- The round date of R11 is unverified; the interval lengths and the annual layer inherit that approximation.

## Reproduction

The notebook is built by `_tools/build_tsm_markov_notebook.py`, executed in a fresh kernel pinned to the E-cores by `_tools/execute_eps_notebook.py` (option `--output-env TSM_MARKOV_OUTPUT`), executed a second time into `.quarto/tsm_markov_reproduction_en`, and verified by `_tools/verify_tsm_reproduction.py`, which requires byte-identical aggregate tables and inserts the quick-reading and reproduction cells. `reproducibility_report.md` in the outputs folder records the result.
