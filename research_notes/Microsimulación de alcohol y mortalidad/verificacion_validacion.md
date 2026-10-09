# Verification, calibration and validation practice for health microsimulation models (focus: alcohol policy), and what a first "verifiable but not yet epidemiologically validated" Chilean model should demonstrate

Scope note (read first). These notes were compiled on 2026-10-09. Many full texts were retrieved from PubMed/PMC through the PubMed connector (PubMed-retrieved items are cited with their DOI links). Several sites were blocked by the egress proxy in this session (doi.org landing pages, zenodo.org, oecd.org, oecdpublichealthexplorer.org, eprints.whiterose.ac.uk), so the SIMAH Zenodo record/repository, the SIMAH protocol technical review PDF, the SIMAH/Lancet supplementary ODD appendix and the OECD SPHeP-NCDs technical documentation could NOT be read directly. Items marked "(recalled, not re-fetched)" are standard references whose content I state from prior knowledge; verify before quoting them in a paper.

## 1. Verification (internal validity) tests used in practice: null policy, extreme values, accounting identities, analytic reproduction, seed/replication stability, unit tests. Which models/guidelines document them?

### Takeaway
Guidelines all name verification as a distinct step, but only the HTA verification literature (TECH-VER, AdViSHE, Dasbach & Elbasha) turns it into concrete tests. The tests are black-box tests first (extreme values, null and zero effects, conservation checks), then white-box re-calculation of key formulas, then replication against a parallel model. Published alcohol microsimulations (SIMAH, STAPM/SAPM) document ODD descriptions, calibration and holdout validation, but they do not publish a verification test suite. A Chilean model therefore has to define its own suite. Its strongest cheap tests are: a null policy giving zero difference, RR = 1 giving zero attributable deaths, exact population and death accounting, and the microsimulated PAF/PIF converging to the analytic CRA PAF/PIF under static exposure. The last test is the analogue of Krijkamp's microsimulation-to-cohort convergence test.

### Cited Findings
**Guideline taxonomy**
- ISPOR-SMDM Task Force 7 (Eddy et al. 2012) defines five validation types:
  - face validity (experts evaluate structure, data sources, assumptions and results);
  - verification or internal validity ("check accuracy of coding");
  - cross validity (comparison with other models on the same problem);
  - external validity (comparison with real-world results);
  - predictive validity (comparison with prospectively observed events).

  External and predictive validity are "the strongest form of validation". The report also asks for a nontechnical description, plus technical documentation detailed enough that an expert could evaluate and potentially reproduce the model. — [Eddy et al. 2012, Value Health](https://doi.org/10.1016/j.jval.2012.04.012); same report in [Med Decis Making](https://doi.org/10.1177/0272989X12454579)
- Eddy et al. also classify external validations as "dependent", "partially dependent" or "independent", according to whether the comparison data were used to build or calibrate the model (recalled, not re-fetched; the full text was not available through PMC). — [Eddy et al. 2012](https://doi.org/10.1016/j.jval.2012.04.012)

**Kopec et al. 2010 (population-based chronic-disease simulation)**
- Kopec's framework says evidence of credibility comes from three places: (1) the model development process (conceptual model, parameters, computer implementation); (2) model performance (plausibility/face validity, internal consistency, parameter sensitivity, between-model comparison, external comparison with historical and prospective data); and (3) the quality of decisions based on the model. — [Kopec et al. 2010, BMC Public Health](https://doi.org/10.1186/1471-2458-10-710)
- Kopec et al.: "Internal consistency should be assessed by considering functional and logical relationships between different output variables. Internal consistency should be tested under a wide range of conditions, including extreme values of the input parameters." — [Kopec et al. 2010](https://doi.org/10.1186/1471-2458-10-710)
- Kopec et al. note that external review of source code is rare. They recommend documenting the results of program debugging tests and opening the model's equations to scrutiny, and they mention formal methods for models where mistakes are very costly. — [Kopec et al. 2010](https://doi.org/10.1186/1471-2458-10-710)

**TECH-VER (Büyükkaramikli et al. 2019)**
- TECH-VER organises verification into five domains: (1) input calculations; (2) event-state (patient flow) calculations; (3) result calculations; (4) uncertainty analysis calculations; (5) other overall checks (e.g. validity or interface). Within each domain it prescribes, in this order:
  - completeness and consistency checks;
  - black-box tests ("checking if model calculations are in line with the expectations");
  - white-box tests, only for a priori selected essential calculations, or to locate the root cause of a black-box failure;
  - replication-based tests, only when white-box tests fail or the code is too opaque.

  — [Büyükkaramikli et al. 2019, PharmacoEconomics](https://doi.org/10.1007/s40273-019-00844-y)
- Concrete TECH-VER examples include checking that all transition probabilities are ≥ 0. The case studies show errors that such tests catch: double-counting of adverse-event hospitalisation costs, time-unit mismatches that produced utilities below zero, and post-progression survival being re-sampled every cycle. — [Büyükkaramikli et al. 2019](https://doi.org/10.1007/s40273-019-00844-y)
- TECH-VER quotes earlier practice on extreme values: "Extreme values of the input variables were used, and the model's actual outputs were compared with expected outcomes" (Hammerschmidt et al.). It also quotes "artificial simulations designed to reveal errors in both logic and programming" (Willis et al.). — [Büyükkaramikli et al. 2019](https://doi.org/10.1007/s40273-019-00844-y)

**AdViSHE and Dasbach & Elbasha**
- AdViSHE (Delphi with 47 experts, plus about 50 workshop discussants) has 13 items in four groups: conceptual model, input data, implemented software program and model outcomes. A final open question asks about other validation techniques. AdViSHE deliberately gives no validity score or pass threshold; developers report what was done, how, and where the results are. — [Vemer et al. 2016, PharmacoEconomics](https://doi.org/10.1007/s40273-015-0327-2)
- The individual AdViSHE items under "implemented software program" (external review, extreme-value testing, testing of traces, unit testing) and under "model outcomes" (face validity, cross-validation, validation against outcomes used in development, validation against independent outcomes) are recalled, not re-fetched; they are in Fig. 2 of the paper, which the connector did not return. — [Vemer et al. 2016](https://doi.org/10.1007/s40273-015-0327-2)
- Dasbach & Elbasha (2017) bring software-engineering verification methods into HTA modelling and call for a task force to define best practice, because model code "is seldom verified". — [Dasbach & Elbasha 2017, PharmacoEconomics](https://doi.org/10.1007/s40273-017-0508-2)

**Analytic reproduction and seeds (Krijkamp et al. 2018)**
- When there is no memory and no baseline heterogeneity, microsimulation outcomes "should asymptotically converge to those from a deterministic cohort model as the number of individuals simulated … increases". The tutorial uses plots of the mean estimate against the number of simulated individuals, and microsimulation-versus-Markov state traces, as graphical convergence diagnostics. — [Krijkamp et al. 2018, Med Decis Making](https://doi.org/10.1177/0272989X18754513)
- Krijkamp et al. recommend using pre-sampled values or "explicitly setting a seed number per individual", so that the same hypothetical individual faces intervention and control. This removes Monte Carlo noise from the comparison and makes results reproducible. — [Krijkamp et al. 2018](https://doi.org/10.1177/0272989X18754513)

**What SIMAH documents (alcohol)**
- Kilian et al. 2025 document the model with the ODD protocol (appendix pp 3–22), adhere to GATHER, and state three global assumptions: data validity and generalisability; adequate Markov and ordinal-model structures; and valid policy mechanisms. The text that could be retrieved contains no verification test suite (null policy, extreme values, accounting). — [Kilian et al. 2025, Lancet Public Health](https://doi.org/10.1016/S2468-2667(25)00165-3)
- SIMAH's annual process: the baseline year is 2000 with 1-year steps. Each year, individuals enter through "births" (reaching age 18) and in-migration, and leave through death and out-migration. Education changes via Markov transition probabilities (PSID 2005–2019). Alcohol category changes via ordinal logistic regression on pseudo-longitudinal BRFSS 2000–10. — [Kilian et al. 2025](https://doi.org/10.1016/S2468-2667(25)00165-3)
- SIMAH (2026, JAMA Health Forum) states the rule that "Only individuals newly receiving BI due to expanded ASBI were assigned intervention effects because the effects of existing interventions are assumed to be already captured in historical alcohol use data". This is a no-double-counting rule that a verification test can check. The paper is also documented in ODD and follows CHEERS. — [SIMAH ASBI 2026, JAMA Health Forum](https://doi.org/10.1001/jamahealthforum.2026.2348)
- In that paper the screening-only scenario produced YLL changes whose credible interval included zero (men −8.0 per 100 000, CrI −19.6 to 2.4). The paper reported this explicitly, as "statistically indistinguishable from zero". — [SIMAH ASBI 2026](https://doi.org/10.1001/jamahealthforum.2026.2348)

**What STAPM/SAPM documents (alcohol)**
- STAPM reports the "£0.50 (unchanged)" scenario as a 0.0% change in every table, which is effectively a null-policy row. Intervention and control share initialisation (2017) and the 2018 MUP, and diverge only from 2019. — [Holmes et al. (STAPM Scotland MUP), PLoS Med](https://doi.org/10.1371/journal.pmed.1004792)
- STAPM updates mortality and morbidity rates with the Potential Impact Fraction method, using lagged consumption, and then samples deaths individually. — [STAPM, PLoS Med](https://doi.org/10.1371/journal.pmed.1004792)
- The Sheffield Alcohol Policy Model v2.0 has a full algebraic "mathematical description" (47 health conditions). This is a documentation route that makes white-box verification by third parties possible. — [Brennan et al. 2015, Health Econ](https://doi.org/10.1002/hec.3105)

**OECD SPHeP-NCDs**
- OECD describes SPHeP-NCDs as calibrated so that disease incidence and prevalence match international datasets. Risk factors act independently (no mediators), and future risk-factor trends are not projected beyond demographic change. — [OECD Mental health promotion and prevention, Methodology](https://www.oecd-ilibrary.org/en/publications/mental-health-promotion-and-prevention_88bbe914-en/full-report/methodology_b5bd871e.html); [OECD SPHeP-NCDs model chapter](https://www.oecd.org/en/publications/the-health-and-economic-benefits-of-tackling-non-communicable-diseases_e20cbbc3-en/full-report/the-oecd-sphep-ncds-model_21046dae.html)

### Inferences
**Proposed minimum verification suite for the Chilean model (V-tests).** Tolerances are proposals derived from Monte Carlo standard error (MCSE) logic (Section 3). They are not published standards.

- **V1 Null policy.** Apply the policy module with a 0% price change, or with elasticity = 0, using common random numbers (same seeds and streams in both arms). Individual consumption, categories, deaths and YPLL must be identical (difference exactly 0, bitwise or to 1e-12). Without CRN, |Δ| must be < 3 × MCSE(Δ). This mirrors STAPM's "unchanged" row and Krijkamp's per-individual seeds.
- **V2 RR = 1 everywhere** (all exposure levels, current and former drinkers, HED). Every PAF/AAF = 0, attributable deaths = 0 and PIF = 0 for all scenarios. Wholly attributable (AAF = 1) causes must be handled explicitly: they are either excluded from this test or must still show AAF = 1, which flags that they bypass the RR machinery.
- **V3 Elasticity = 0, or participation elasticity = 0 only.** Consumption is unchanged, or only the intensive margin changes. The share leaving drinking must equal the sampled participation response, to within sampling error.
- **V4 Extreme effect.**
  - With a 100% abstention counterfactual, the PIF must equal the PAF computed with the same reference category. This holds only if the counterfactual uses the lifetime-abstainer reference. If quitters become former drinkers with former-drinker RRs, PIF(100%) < PAF by construction. This is a key check for the former-drinker component.
  - Wholly attributable deaths go to 0 under full abstention.
  - Monotonicity: larger price increases give weakly larger reductions. STAPM's tables show this monotone pattern from £0.40 to £0.80.
- **V5 Accounting identities.** These are integer-exact (tolerance 0):
  - N(t+1) = N(t) + entries at the minimum age + immigrants − deaths − emigrants − exits at the maximum age, by sex and age;
  - the sum of cause-specific deaths equals total deaths;
  - attributable deaths ≤ observed deaths in every stratum;
  - YPLL = Σ max(0, reference age − age at death);
  - no individual dies twice or has negative consumption;
  - category recode boundaries are consistent with continuous g/day.

  The SIMAH entry and exit flows (Kilian 2025) give the template.
- **V6 Analytic reproduction (static exposure).** Freeze transitions, so the exposure distribution equals the CRA input distribution (e.g. the fitted gamma per sex and age). The microsimulated PAF, computed as Σ p_i(RR_i − 1) / [Σ p_i(RR_i − 1) + 1] over individuals, or as the mean-RR form, must converge to the integral CRA PAF as N grows. Tolerance: |microsim − analytic| < 3 × MCSE, with MCSE shrinking ∝ 1/√N. This is the alcohol analogue of Krijkamp's microsimulation-to-cohort convergence.
- **V7 Seed and replication stability.** Re-running with the same seed reproduces outputs exactly. Across R seeds, report the MCSE of key outputs and confirm that it scales ∝ 1/√(N·R).
- **V8 Unit tests (white-box).** Write unit tests for each RR function (value at 0 g/day = 1, monotone where expected, cap at the top of the supported range), for PIF/PAF helpers, for the elasticity application order and for recoding. These map to TECH-VER domains 1–3.

Each test output should be logged as an artefact. That fits TRACE "implementation verification" (Section 4) and AdViSHE's "where reported" logic.

### Gaps
- I found no published alcohol-microsimulation paper (SIMAH, SAPM/STAPM, SPHeP-NCDs) that reports a formal verification test suite with tolerances. The SIMAH ODD appendix (eMethods) and the SIMAH code (Zenodo 10.5281/zenodo.15641639) could not be accessed in this session. A GitHub search for "SIMAH microsimulation alcohol" returned no public repository. Whether SIMAH uses common random numbers across reference and policy runs is unverified; the Lancet 2025 text only says that each parameter combination was run "ten times with varying random seeds".
- The full TECH-VER test tables and the AdViSHE item wording (figures and ESM) were not retrievable, so concrete test names beyond those quoted above are recalled.
- I found no published tolerance standard for "microsim PAF = CRA PAF". The MCSE-based tolerance above is my proposal.

## 2. Calibration practice: targets, goodness of fit, methods (IMIS vs history matching, Nelder–Mead, LHS, ABC, Bayesian), survey design variance, breaks in survey series, train/holdout, and when reproducing targets must not be called validation

### Takeaway
SIMAH uses Bayesian history matching with an implausibility cutoff (< 3) and temporal holdouts. Calibration windows are ACS 2000–10 and BRFSS 2011–15 (or 2000–15 in the 2026 paper); validation windows are ACS 2011–19 and BRFSS 2016–19. It does not calibrate mortality: it rescales base mortality rates to match vital statistics. I found no evidence that SIMAH uses IMIS, so the brief's premise "IMIS in SIMAH" appears incorrect. Matching any target the model was fitted or scaled to (including base-rate-scaled deaths) is calibration fit, not validation. Validation requires data withheld from calibration, preferably a different source or period.

### Cited Findings
**SIMAH calibration and validation**
- Kilian et al. 2025 calibrate in two steps within "a Bayesian probabilistic framework":
  - Step 1: education transition probabilities, targets from ACS 2000–10.
  - Step 2: alcohol-category regression coefficients, targets from BRFSS 2011–15.
  - Method: "Bayesian history matching". Parameter sets are retained if non-implausible, with "a mean implausibility metric <3".
  - Validation: on "reserved data from ACS 2011–19 (step 1) and BRFSS 2016–19 (step 2)".
  - Training data: the alcohol transition model itself was estimated on BRFSS 2000–10.

  — [Kilian et al. 2025](https://doi.org/10.1016/S2468-2667(25)00165-3)
- SIMAH 2026 states calibration with "ACS data (2000-2010) for education and BRFSS data (2000-2015) for alcohol use", and validation against "ACS (2011-2019) and BRFSS (2016-2019)". This BRFSS calibration window differs from the 2011–15 window in Kilian 2025; see Gaps. — [SIMAH ASBI 2026](https://doi.org/10.1001/jamahealthforum.2026.2348)
- SIMAH 2026: "Mortality risks are not calibrated; instead, reference mortality rates are adjusted to align mortality outcomes from the model with the US National Vital Statistics System data and US Census Bureau projections." — [SIMAH ASBI 2026](https://doi.org/10.1001/jamahealthforum.2026.2348)
- The SIMAH design paper (AJE 2023) uses an "implausibility" goodness-of-fit metric that weighs the simulated-versus-target difference against sampling uncertainty from both sources. At that stage, full Bayesian calibration had not yet been run. Early validation compared SES (education) proportions with census, ACS and PSID, giving RMSEs of 1.7%, 7.1% and 5.6%. Age-standardised cause-specific mortality was compared with observed 2000–2018 data. Per capita consumption was used to correct survey under-reporting. These details come from a search summary; the full text came back empty through the connector. — [Probst et al. 2023, Am J Epidemiol](https://doi.org/10.1093/aje/kwad018); [PMC version](https://pmc.ncbi.nlm.nih.gov/articles/PMC10423629/)

**Calibration in other alcohol models**
- STAPM calibrates LCFS price-paid data (2006–Q1 2019) to observed 2017 Scottish sales. An "upshift" sensitivity analysis raises survey consumption to 80% of per capita sales (the GBD convention). This reduced the modelled consumption impact of a £0.65 MUP by 53.8% and the death impact by 55.5%. An alternative elasticity matrix reduced them by 69.2% and 62.8%. — [STAPM, PLoS Med](https://doi.org/10.1371/journal.pmed.1004792)
- STAPM notes that the growing body of MUP evaluations (observed sales down 3.0–3.5% and wholly attributable deaths down 13.4%) "affords opportunities … to calibrate such tools". This implies that observed MUP effects have not yet been used as formal calibration or validation targets. — [STAPM, PLoS Med](https://doi.org/10.1371/journal.pmed.1004792)
- I did not find a published study that compares Sheffield model predictions with observed post-MUP outcomes as a formal predictive validation. — [search summary; SARG MUP page](https://sarg-sheffield.ac.uk/minimum-alcohol-pricing/)

**General calibration guidance**
- Vanni et al. set out seven calibration steps:
  1. Which parameters to vary.
  2. Which targets.
  3. Which goodness-of-fit (GOF) measure.
  4. Which search strategy.
  5. Which convergence criteria define acceptable sets.
  6. Which stopping rule.
  7. How to integrate results with the economic analysis.

  — [Vanni et al. 2011, PharmacoEconomics](https://doi.org/10.2165/11584600-000000000-00000)
- Karnon & Vanni (2011) compared GOF measures. Chi-squared GOF discriminated between parameter sets "to a far greater degree" than likelihood GOF, and a guided search gave higher mean estimates and narrower output ranges than random search. — [Karnon & Vanni 2011, PharmacoEconomics](https://doi.org/10.2165/11584610-000000000-00000)
- Alarid-Escudero et al. used Nelder–Mead with likelihood profiles and a collinearity index. Equally fitting parameter sets (non-identifiability) gave different treatment benefits: 0.67 versus 0.31 life-years. Adding a second target made the model identifiable (collinearity index 3.5). — [Alarid-Escudero et al. 2018, Med Decis Making](https://doi.org/10.1177/0272989X18792283)
- Menzies et al. present Bayesian calibration as priors + model structure + likelihood. They advise treating calibration as "an exercise in creating a reasonable model that produces valid evidence for policy, rather than as a technique for identifying a unique theoretically optimal summary". — [Menzies et al. 2017, PharmacoEconomics](https://doi.org/10.1007/s40273-017-0494-4)
- Rutter et al. (2010 review): Bayesian calibration "provide[s] interval estimates that describe the variability in both parameter estimates and model predictions due to parameter estimation, sampling variability of the selected calibration data, and simulation variability". — [Rutter et al. 2010, Med Decis Making](https://doi.org/10.1177/0272989X10369005)
- IMABC (incremental mixture approximate Bayesian computation) was developed for the CRC-SPIN microsimulation and builds on the ideas of IMIS. IMIS itself is the incremental mixture importance sampling of Raftery & Bao 2010 (recalled, not re-fetched). — [Rutter et al. IMABC (OSTI)](https://www.osti.gov/servlets/purl/1607644); [Raftery & Bao 2010, Biometrics](https://doi.org/10.1111/j.1541-0420.2010.01399.x)
- History-matching implausibility is usually I(θ) = |z − E[f(θ)]| / √(V_obs + V_model-discrepancy + V_ensemble/stochastic), with cutoff 3 by Pukelsheim's three-sigma rule (recalled, not re-fetched). — [Andrianakis et al. 2015, PLoS Comput Biol](https://doi.org/10.1371/journal.pcbi.1003968)
- Stout et al. reviewed calibration methods in cancer simulation models and proposed calibration reporting guidelines (recalled, not re-fetched). — [Stout et al. 2009, PharmacoEconomics](https://doi.org/10.2165/11314830-000000000-00000)

**Calibration versus validation**
- Rutter et al. define validation as "the process of assessing whether a model is consistent with data not used for calibration". Because this requires holding data out, many models are not validated, or are validated only on loosely related trials. — [Rutter et al. 2010](https://doi.org/10.1177/0272989X10369005)
- Kopec et al.: validation data "should be different from the data used to populate and calibrate the model … withholding part of the data for predictive model validation is appropriate". Their example is to calibrate on incidence and validate on mortality. Cross-validation and bootstrap had "not … been applied to validate disease simulation models". — [Kopec et al. 2010](https://doi.org/10.1186/1471-2458-10-710)
- Kopec et al.: "If parameters are estimated through calibration, the model should be recalibrated as part of uncertainty/sensitivity analysis." — [Kopec et al. 2010](https://doi.org/10.1186/1471-2458-10-710)

**Breaks in survey series**
- BRFSS changed methodology in 2011, adding cell-phone samples and moving to raking weights. CDC warned that 2011+ prevalence estimates are not directly comparable with earlier years (recalled, not re-fetched). — [CDC MMWR 2012;61(22):410–413](https://www.cdc.gov/mmwr/preview/mmwrhtml/mm6122a3.htm)

### Inferences
**Labelling rule for the Chilean model**
- Report as calibration fit (TRACE "model output verification", Eddy "dependent" validation): agreement with targets used in estimation, calibration or base-rate scaling. This includes DEIS deaths if baseline mortality rates are scaled to DEIS, ENPG prevalence by category if transitions were tuned to it, and population counts if INE projections drive entries and exits. Do not call this "validation".
- Call it "validation" only for comparisons with data withheld from calibration: (a) temporal holdout, e.g. calibrate on early ENPG waves and validate on later waves, as SIMAH does; (b) a different source, e.g. per capita recorded consumption (WHO/sales) for total volume, or cause-specific mortality trends that were not used for scaling; (c) prospective data (predictive validity).

**Survey design variance**
- Take the target variance V_obs from ENPG's complex design (strata, PSUs, weights), not from simple-random-sampling formulas.
- Add an ensemble or stochastic variance term from replicate runs.
- Add an explicit model-discrepancy term.

This is exactly the structure of SIMAH's implausibility metric (sampling uncertainty from both sources). An implausibility below 3 is a defensible, citable acceptance threshold.

**Breaks in series**
- If an ENPG wave changes mode, questionnaire or weighting, either (a) keep calibration and validation windows on the same side of the break, or (b) add a wave-specific bias or discrepancy term. Do not silently pool across the break.
- SIMAH's 2011–15 BRFSS calibration window starts exactly at the 2011 BRFSS break. That may be deliberate, but it is not stated.

**Under-reporting**
- Decide in advance whether survey consumption is upshifted to per capita (e.g. 80% coverage). STAPM shows this choice can roughly halve policy effects, so it must appear in the sensitivity analyses.

**Method choice for a first model**
- A small parameter vector (transition intercepts and mortality scalars) can be calibrated by LHS plus history matching (implausibility < 3), as SIMAH does. This is simpler and better precedented in alcohol models than IMIS or ABC.
- Run a non-identifiability check (collinearity or likelihood profiles), because consumption transitions and HED may be weakly identified from repeated cross-sections.

### Gaps
- The SIMAH appendix's history-matching details could not be read: number of waves, LHS sample size, emulators or not, variance terms. The discrepancy between the two papers' BRFSS calibration windows (2011–15 versus 2000–15) is unresolved; it may reflect different model versions.
- I found no source documenting IMIS use in SIMAH. If the project's documents assert it, check the original citation.
- I found no published Chilean (ENPG/SENDA) series-break documentation in this session. Another researcher should cover ENPG methodology changes.
- No formal external or predictive validation of STAPM/SAPM against observed MUP effects was located.

## 3. Monte Carlo error: population size, number of runs, common random numbers for policy differences, and reporting MC intervals versus parameter uncertainty (PSA)

### Takeaway
Treat first-order (stochastic, Monte Carlo) and second-order (parameter) uncertainty separately. SIMAH averages stochastic replicates within each parameter set and reports intervals across parameter sets: 60 × 10 runs in 2025 (interval = min to max) and 70 × 20 runs in 2026 (2.5th–97.5th percentiles). STAPM uses a 200,000-person synthetic population and reports point estimates. The number of individuals and replications should be justified with an MCSE target for the policy difference, not for levels. CRN (per-individual seeds or streams) is the main tool for making differences precise.

### Cited Findings
**What SIMAH and STAPM do**
- Kilian et al. 2025 paired 60 calibrated parameter combinations with draws of beverage-specific elasticities. "Each combination was simulated ten times with varying random seeds and averaged across these iterations to account for stochasticity", giving 600 runs and 60 effect estimates per scenario. Credible intervals "reflecting parameter uncertainty" were "the minimum and maximum effect estimates across these combinations". — [Kilian et al. 2025](https://doi.org/10.1016/S2468-2667(25)00165-3)
- SIMAH 2026: "70 parameters sets with 20 stochastic replications each (1400 runs per scenario)". The 95% CrI "represents the 2.5th and 97.5th percentile of outcomes across the 70 parameter sets and reflects uncertainty in model inputs following calibration". — [SIMAH ASBI 2026](https://doi.org/10.1001/jamahealthforum.2026.2348)
- SIMAH 2026 argues that both scenarios share identical pandemic-era adjustments, so the projected differences are "largely driven by the modeled expansion". In other words, structural assumptions common to both arms cancel in the difference. — [SIMAH ASBI 2026](https://doi.org/10.1001/jamahealthforum.2026.2348)
- STAPM models "a synthetic population of 200,000 individuals" based on the Scottish Health Survey 2016–2018 across 800 subgroups. The main text reports point estimates without intervals. — [STAPM, PLoS Med](https://doi.org/10.1371/journal.pmed.1004792)

**Monte Carlo error principles**
- Kopec et al.: "In stochastic models, it is also important to assess the amount of stochastic variability (Monte Carlo error) through multiple runs … Stochastic error can be reduced by increasing the size of the simulated population". "In probabilistic models, the Monte Carlo error should be estimated." — [Kopec et al. 2010](https://doi.org/10.1186/1471-2458-10-710)
- Krijkamp et al. call the variability around the mean the "Monte Carlo Standard Error (MCSE)". The number of individuals "is related to the magnitude of the MCSE", and the tutorial assesses convergence graphically, plotting mean outcomes against N. — [Krijkamp et al. 2018](https://doi.org/10.1177/0272989X18754513)
- Rutter et al. list the sources of microsimulation variability: population heterogeneity, parameter estimation, choice of calibration data, sampling variability of calibration data, simulation (Monte Carlo) variability and structural assumptions. — [Rutter et al. 2010](https://doi.org/10.1177/0272989X10369005)

**Common random numbers**
- Stout & Goldie: CRN is "the coordinated or synchronized use of random numbers such that the same random numbers are 'common' to the same stochastic events across all model runs". It induces correlated output, so "fewer individuals need to be simulated to produce stable estimates of the differences". It does not reduce variance within a single run, and it enables individual-level counterfactual statistics. — [Stout & Goldie 2008, Health Care Manag Sci](https://doi.org/10.1007/s10729-008-9067-6)
- Stout & Goldie assign separate random-number sequences to different stochastic events. They recommend generators with independent streams and substreams (L'Ecuyer's RngStream), or the Mersenne Twister. Reinitialising the generator per individual can add computation, a cost they describe as "by far outweighed" by being able to simulate smaller cohorts. — [Stout & Goldie 2008](https://doi.org/10.1007/s10729-008-9067-6)

**Sizing runs and PSA**
- O'Hagan et al. give an ANOVA-based method for PSA in patient-level simulation, with formulae for the optimal number of patients per run versus the number of parameter draws. The authors' summary claims a computational saving of at least a factor of 20. — [O'Hagan et al. 2007, Health Econ](https://doi.org/10.1002/hec.1199); [author abstract page](https://tonyohagan.co.uk/academic/abs/MCPSA.html)
- Hatswell et al. note that the number of PSA iterations is usually justified only as "sufficient" or "converged", with convergence seldom defined. Their proposed criterion is to run until the 95% CI of incremental net benefit excludes zero, which they acknowledge is somewhat arbitrary. — [Hatswell et al. 2018 (UCL repository)](https://discovery-pp.ucl.ac.uk/10054165/3/Hatswell_2018-07-10_Probabilistic%20sensitivity%20tutorial_v4-2%20CLEAN.pdf)
- A conference systematic review of chronic-disease microsimulations found that only 21% (13 studies) ran PSA, only 4 used second-order Monte Carlo, and only 2 justified the number of PSA replicates. — [ISPOR Europe 2021 abstract](https://www.ispor.org/heor-resources/presentations-database/presentation/euro2021-3408/112836)
- An ISPOR Europe 2026 poster (a hypertension microsimulation; conference-level evidence only) estimated Monte Carlo error from 50 seeds with fixed parameters:
  - Rates stabilised at about 8,000–15,000 patients and QALYs at about 15,000–20,000.
  - The coefficient of variation for QALYs fell from 3.74% to 0.51% between N = 20,000 and 1,000,000.
  - The poster also claims that 100 pooled runs of 1,000 were less stable than one run of 100,000. That contradicts simple iid averaging, unless each run also re-samples the baseline population or contains other between-run variance, so treat it with caution.

  — [ISPOR 2026 poster](https://www.ispor.org/heor-resources/presentations-database/presentation-cti/ispor-europe-2026/poster-session-5-4/how-many-patients-does-a-microsimulation-need-convergence-in-patient-level-simulation-and-the-diminishing-marginal-benefit-of-size)
- Formal MCSE formulas for simulation summaries: the MCSE of a mean over R independent replicates is SD/√R, and MCSE should be reported with every simulated quantity (recalled, not re-fetched). — [Koehler, Brown & Haneuse 2009, Am Stat](https://doi.org/10.1198/tast.2009.0030); [Morris, White & Crowther 2019, Stat Med](https://doi.org/10.1002/sim.8086)
- ISPOR-SMDM Task Force 6 covers parameter estimation and uncertainty analysis, including PSA and the distinction between first- and second-order uncertainty (recalled, not re-fetched). — [Briggs et al. 2012, Med Decis Making](https://doi.org/10.1177/0272989X12458348)

### Inferences
**Sizing rule for the Chilean model.** Size by the rarest policy-relevant output.
- For a prevalence p in a stratum with n simulated people, MCSE ≈ √(p(1−p)/n). For example, p = 0.10 and n = 100,000 give about 0.095 percentage points.
- For cause-specific deaths with expected count D per stratum-year, the relative MCSE ≈ 1/√D. Liver cirrhosis or AUD deaths by sex, age and year in a scaled-down population can have D in the tens, i.e. 10–30% noise. So either simulate at full scale (or a large fraction of it), pool years and age groups for reporting, or rely on CRN differences.
- Target: MCSE(policy difference) ≤ 10% of the expected difference, or ≤ ⅓ of the half-width of the parameter-uncertainty interval, whichever is stricter. Then increase N or R until that target holds. This is a proposal; no published alcohol standard was found.

**CRN implementation**
- Give each individual (and each stochastic process: mortality draw, transition draw, participation draw, beverage assignment) its own seed or stream. Then the reference and policy arms consume identical random numbers until the policy changes an individual's state.
- Report the variance reduction: compare Var(Δ) with and without CRN.
- The V1 null-policy test (Section 1) is the CRN sanity check.

**Reporting**
- Report two kinds of interval separately: (a) MC intervals across seeds at fixed parameters, which are first-order and should become negligible; and (b) parameter-uncertainty intervals across calibrated parameter sets and elasticity draws, which are second-order.
- Prefer percentile intervals over min–max. SIMAH moved from min–max with 60 sets to 2.5–97.5 percentiles with 70 sets, and min–max with a few dozen sets is unstable.

**Minimum for a "verifiable" first model**
- (i) Fixed seeds and reproducibility (V7).
- (ii) A convergence plot of key outputs against N.
- (iii) MCSE reported for levels and differences.
- (iv) CRN demonstrated.

A full PSA may come later, but its absence must be stated.

### Gaps
- I found no alcohol-model-specific guidance on choosing N. SIMAH's synthetic population size (and any scaling factor) was not in the retrieved main texts; it is presumably in the ODD appendix, which was not accessible.
- It is unknown whether SIMAH's replicate seeds are shared between reference and policy arms (i.e. whether it uses CRN).
- OECD SPHeP-NCDs population size and iteration counts were not retrievable (the documentation site was blocked).

## 4. Reporting standards: ODD, TRACE, CHEERS 2022 (modelling-transparency items), STRESS; minimum documentation for a model description paper

### Takeaway
The alcohol microsimulation precedent is ODD for model description (SIMAH 2025 and 2026), plus a reporting checklist for the application paper (GATHER in SIMAH 2025, CHEERS in SIMAH 2026). TRACE adds what ODD lacks: a structured record of data evaluation, implementation verification, output verification (calibration fit) and output corroboration (independent validation). That makes TRACE the natural container for the V-tests and for the calibration-versus-validation labelling. STRESS adds simulation-experiment details (run length, replications, RNG).

### Cited Findings
**Alcohol precedent**
- SIMAH: "Policy effect estimates are generated by a computer model, which has been developed and documented using the overview, design concepts and details protocol (pp 3–22), a recognised reporting standard for simulation models". The study also adheres to GATHER. — [Kilian et al. 2025](https://doi.org/10.1016/S2468-2667(25)00165-3)
- SIMAH 2026: "The underlying computer model is documented using the … ODD protocol available in the eMethods … a recognized best practice for reporting simulation models. We followed the [CHEERS] reporting guideline." — [SIMAH ASBI 2026](https://doi.org/10.1001/jamahealthforum.2026.2348)
- SAPM provides a full algebraic description, with data synthesis and risk functions for 47 conditions, as a stand-alone methods paper. STAPM points to separate full methodological reports. — [Brennan et al. 2015](https://doi.org/10.1002/hec.3105); [STAPM, PLoS Med](https://doi.org/10.1371/journal.pmed.1004792)

**Guidance on transparency and documentation**
- Eddy et al.: provide a nontechnical description covering:
  - model type and intended applications;
  - funding;
  - structure, inputs, outputs and their relationships;
  - data sources;
  - validation methods and results;
  - limitations.

  Separately, provide technical documentation detailed enough to reproduce the model. — [Eddy et al. 2012](https://doi.org/10.1016/j.jval.2012.04.012)

**ODD (Grimm et al. 2020)**
- Seven elements (recalled, not re-fetched):
  1. Purpose and patterns.
  2. Entities, state variables and scales.
  3. Process overview and scheduling.
  4. Design concepts (basic principles, emergence, adaptation, objectives, learning, prediction, sensing, interaction, stochasticity, collectives, observation).
  5. Initialization.
  6. Input data.
  7. Submodels.

  — [Grimm et al. 2020, JASSS](https://doi.org/10.18564/jasss.4259)

**TRACE (Grimm et al. 2014)**
- Eight elements (recalled, not re-fetched):
  1. Problem formulation.
  2. Model description.
  3. Data evaluation.
  4. Conceptual model evaluation.
  5. Implementation verification.
  6. Model output verification (comparison with the patterns and data used in calibration).
  7. Model analysis (sensitivity and uncertainty).
  8. Model output corroboration (comparison with independent data not used in development).

  TRACE builds on the "evaludation" concept. — [Grimm et al. 2014, Ecol Model](https://doi.org/10.1016/j.ecolmodel.2014.01.018); [Augusiak et al. 2014, Ecol Model](https://doi.org/10.1016/j.ecolmodel.2013.11.009)

**STRESS (Monks et al. 2019)**
- Variants STRESS-ABS, -DES and -SD, with sections on objectives, logic, data, experimentation (initialisation/warm-up, run length, estimation approach including the number of replications), implementation (software, random sampling/RNG, model execution, system specification) and code access (recalled, not re-fetched). — [Monks et al. 2019, J Simulation](https://doi.org/10.1080/17477778.2018.1442155)

**CHEERS 2022 (Husereau et al. 2022)**
- The modelling-relevant items are (recalled, not re-fetched; check item wording against the published checklist):
  - item 15, rationale and description of the model, including whether and where the model is publicly available;
  - item 16, analytics and assumptions, including "approaches for validating any model used";
  - items 17–18, heterogeneity and distributional effects;
  - item 19, characterizing uncertainty.

  — [Husereau et al. 2022, BMJ](https://doi.org/10.1136/bmj-2021-067975)
- AdViSHE was designed to accompany reimbursement dossiers or manuscripts. Its key feature is reporting how each validation was done and where the results are, not only whether it was done. — [Vemer et al. 2016](https://doi.org/10.1007/s40273-015-0327-2)
- A coding framework for decision models in R (folder structure, functions, unit tests) has been proposed to improve transparency (recalled, not re-fetched). — [Alarid-Escudero et al. 2019, PharmacoEconomics](https://doi.org/10.1007/s40273-019-00837-x)

### Inferences
**Minimum documentation package for the Chilean model description paper or technical report**
1. An ODD description. Its seven elements map one-to-one to the project's AGENTS.md list: entities, state variables, annual process order, stochasticity, initialization, inputs and submodels.
2. A TRACE document. Element 5 holds the V1–V8 test results with tolerances and pass/fail. Element 6 holds the calibration fit to ENPG, DEIS-scaled mortality and INE population, explicitly labelled as calibration. Element 8 holds independent-holdout comparisons, or an explicit statement that none were done yet.
3. A STRESS-style experiment table: N, scaling factor, R replications, seeds/RNG and streams, CRN yes/no, warm-up/burn-in years, software and versions (renv lock), and run time.
4. A calibration report following Vanni's seven steps (or Stout's reporting items): parameters varied, targets with design-based variances, GOF/implausibility, search (LHS size, waves), acceptance (implausibility < 3), stopping rule, and the number of retained sets.
5. An uncertainty section that separates MCSE from parameter uncertainty. If PSA is not yet done, say so.
6. A completed AdViSHE-style table (13 items plus "other"), stating what was done and where the results are.
7. Code and data availability: the Zenodo DOI of the release, the commit hash, and how the encrypted microdata are handled.

A paper can honestly call the model "verified and calibrated, not yet validated" when 1–7 exist, all V-tests pass, and section 8 of TRACE (output corroboration) is empty or limited to a temporal holdout.

### Gaps
- The ODD, TRACE, STRESS and CHEERS item texts were not re-fetched in this session; the element lists above come from memory of the original papers.
- The SIMAH ODD appendix (the best concrete template for an alcohol microsimulation) was not accessible: Lancet supplement and Zenodo were blocked. Obtain it directly, via the Zenodo DOI 10.5281/zenodo.15641639 or from the authors, before writing the Chilean ODD.
- The OECD SPHeP-NCDs technical documentation (oecdpublichealthexplorer.org/ncd-doc) was blocked, so its validation section, if any, could not be summarised.
