# Linking individual drinking to cause-specific mortality in alcohol and chronic-disease microsimulations: RR-based hazards calibrated to vital statistics, and averted deaths (policy vs counterfactual)

Scope note (read first). Researched 2026-10-09. Source code was read directly from public repositories at pinned commits:
- SIMAH R package `charlotteprobst/simah`, tag v1.0.1, commit `2fd8c1ea8c95de0a7137e31db2560a5ceb60339d` (2026-08-24). I could not open Zenodo (egress blocked), so I could **not** confirm that this GitHub release matches Zenodo DOI 10.5281/zenodo.15641639 ("release 0.1.1" per project AGENTS.md). Treat the mapping as unverified.
- STAPM `tobalcepi` (Sheffield) GitHub mirror `stapm/tobalcepi`, commit `054ca37190ad901aa5028bd6222e831083472eaa` (2026-07-03).
- IMPACTncd England `ChristK/IMPACTncd_Engl`, commit `3c44cbf4a6ec974b0730c181381d6ebfcb0d0ba4` (2026-09-14).
Blocked domains (zenodo.org, pmc.ncbi.nlm.nih.gov web pages, oecd.org, vivarium.readthedocs.io, ebi.ac.uk) mean the Kilian 2025 supplement PDF, the Lemp 2026 eAppendix, and the OECD SPHeP-NCDs technical documentation were **not** read; the main texts of Kilian 2025, Lemp 2026, Meier 2016 (SAPM), Rehm 2010, Krijkamp 2018 and Stout & Goldie 2008 were read via PubMed Central full text.

## Q1. SIMAH (Kilian 2025; Lemp 2026; released code): how are cause-specific mortality rates assigned to individuals, how are former drinkers, HED and residual mortality handled, which causes, any lag?

### Takeaway
SIMAH does **not** compute `m_stratum / mean(RR)` at run time. Each person-year's cause-specific risk is `risk_ic = RR_c(gpd_i, HED_i, former_i) × base_rate_c(stratum, year)`, where `base_rate` is a precomputed, calibrated "rate at the theoretical minimum risk exposure level" for sex × 10-year age × race × education × year. Lemp 2026 states that these reference rates are adjusted so that model mortality matches NVSS. All non-modelled causes ("REST") are removed by sampling observed death counts per stratum. Rates for ages 18–64 are inflated ×28 (×3 for ages 65–79) to cut Monte Carlo noise, then de-inflated. There is no exposure-to-mortality lag, and cancers are excluded because of latency. Former-drinker status is randomly reassigned every year and is "not tracked over time".

### Cited Findings
- **Individual risk formula.** For each modelled cause, `risk_<cause> = RR_<cause> * rate_<cause>`. Causes are stacked cumulatively, one U(0,1) draw per person per year assigns at most one modelled cause of death, and YLL = 75 − age for deaths under 75 — [simulate_mortality.R L34–L113](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/simulate_mortality.R)
- **Competing modelled causes.** If any individual's cumulative risk exceeds 1, "All risk columns are going to be normalised by max_risk" (every risk is divided by the maximum) — [simulate_mortality.R L67–L83](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/simulate_mortality.R)
- **Base rates.** The main loop merges `base_rates` by `cat = sex+age10+race+education` and year, with the comment "merge mortality rates at the theoretical minimal risk exposure level" — [microsimulation.R L251–L270](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/microsimulation.R). The package documents `base_rates` as "cause-specific mortality base rates by population subgroup and year, representing mortality rates at the theoretical minimal risk exposure level" — [read_data.R L11–L12](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/read_data.R)
- **Shipped `base_rates.rds`** (inspected locally). It has 5,208 rows for years 2000–2030, columns `rate_LVDC, rate_HLVDC, rate_DM, rate_IHD, rate_ISTR, rate_HYPHD, rate_AUD, rate_UIJ, rate_MVACC, rate_IJ`, plus `samplenum`, `seed=2463` and `mortalitymodel_num`. This points to output from a separate calibration run; the derivation code is not in the package — [inst/extdata/base_rates.rds](https://github.com/charlotteprobst/simah/tree/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/inst/extdata)
- **Calibration statement.** "Mortality risks are not calibrated; instead, reference mortality rates are adjusted to align mortality outcomes from the model with the US National Vital Statistics System data and US Census Bureau projections." Mortality from 2024 onward was projected with Census Bureau death projections — Lemp et al. 2026, JAMA Health Forum, [DOI 10.1001/jamahealthforum.2026.2348](https://doi.org/10.1001/jamahealthforum.2026.2348)
- **Inflation trick.** Defaults are `inflation_factors = c(28, 3)` for age groups 18–64 and 65–79, "applied to age categories with low observed mortality rates … to stabilize simulated mortality" — [microsimulation.R L10–L41](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/microsimulation.R). Simulated deaths and YLL are divided by the factor when summarised — [summary_disease.R](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/summary_disease.R). Only `round(n / inflation_factor)` of the people staged to die in each stratum are actually removed, sampled with probability proportional to their RR by systematic πps sampling (`ppswor`) — [remove_individuals.R L35–L50](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/remove_individuals.R)
  - Supporting check, my reading of the shipped data: base rates already carry the inflation. For example, `rate_IHD` for 2015 White men aged 55–64 with ≤ high school is 0.0819 (≈ 0.29%/yr after ÷28), and `rate_MVACC` for 18–24 is ≈ 0.0075 (≈ 27/100k after ÷28) — [base_rates.rds](https://github.com/charlotteprobst/simah/tree/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/inst/extdata)
- **Residual (non-alcohol) mortality ("REST").** `apply_death_counts()` turns observed cause-specific death counts per stratum into proportions (`proportion = count / n`, `cprob = cumsum(proportion)`), samples a cause for each individual, and removes only those drawn into causes not explicitly modelled (`mort_REST`) — [apply_death_counts.R L41–L42 and helper](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/apply_death_counts.R). This runs before the modelled-cause step each year — [microsimulation.R L233](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/microsimulation.R)
- **Annual process order** in `microsimulation()`:
  1. update HED;
  2. apply the policy if this is a policy year, then recode alcohol categories;
  3. summarise outputs;
  4. REST deaths from observed counts;
  5. assign RRs;
  6. merge base rates and simulate modelled-cause deaths;
  7. remove the deceased;
  8. education transitions;
  9. alcohol transitions, then allocate grams/day, then reassign former-drinker status;
  10. age +1, add 18-year-olds and migrants, remove emigrants.

  — [microsimulation.R L119–L330](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/microsimulation.R)
- **Causes modelled** (default `diseases`): AUD, DM, HLVDC (HCV-related cirrhosis), HYPHD, IHD, IJ (intentional injury), ISTR, LVDC (liver disease and cirrhosis), MVACC, UIJ (other unintentional injury) — [microsimulation.R L40](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/microsimulation.R). Lemp 2026 reports YLL for AUD (including poisonings), liver disease and cirrhosis (including HCV-related), motor-vehicle injuries, other unintentional injuries and suicide, each with AAF ≥ 15% in the US. It applies "two distinct cause-specific relative risk functions … within the liver disease and cirrhosis category" — [Lemp 2026](https://doi.org/10.1001/jamahealthforum.2026.2348)
- **RR functional forms.** All are log-linear or log-quadratic in g/day, capped above a reference intake, with a former-drinker override:
  - LVDC: `RR = exp(b1·gpd + b2·gpd²)`, capped at 179.44 g (men) and 94.15 g (women); former drinkers get `exp(LVDC_FORMERDRINKER)` — [assign_rr_lvdc.R](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/assign_rr_lvdc.R)
  - AUD: `exp(b·gpd)`, capped at 122.51 g (men) and 114.12 g (women) — [assign_rr_aud.R](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/assign_rr_aud.R)
  - IHD: categorical cut-points 1.3, 25, 45 and 65 g; abstainers RR = 1 — [assign_rr_ihd.R](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/assign_rr_ihd.R)
  - ISTR: categories <12, ≤24, ≤48 and >48 g — [assign_rr_istr.R](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/assign_rr_istr.R)
  - HLVDC (HCV-related cirrhosis): log-quadratic, capped at 146.3 g, with no former-drinker term — [assign_rr_hlvdc.R](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/assign_rr_hlvdc.R)
- **HED component (injuries only).**
  - For MVACC and UIJ, `RR = exp(B1·gpd)` for non-HED drinkers under 60 g; `exp(B1·gpd + B2)` if HED or gpd ≥ 60; capped at 150 g; former drinkers `exp(…_FORMERDRINKER)` — [assign_rr_mvacc.R](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/assign_rr_mvacc.R), [assign_rr_uij.R](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/assign_rr_uij.R)
  - Shipped parameters: B_MVACC2 = 1.050 (×2.86) and B_UIJ2 = 0.615 (×1.85) — [risk_param.rds](https://github.com/charlotteprobst/simah/tree/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/inst/extdata)
  - HED status for drinkers at 1–60 g/day is predicted yearly by XGBoost models (young men, old men, everyone else) and classified with a 0.5 threshold — [update_hed.R](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/update_hed.R)
  - Lemp 2026: HED "is updated annually and modifies the cause-specific risk functions for injuries" — [Lemp 2026](https://doi.org/10.1001/jamahealthforum.2026.2348)
- **Former-drinker RRs in shipped `risk_param.rds`** (log scale; exponentiated by me):

  | Cause | Men | Women |
  |---|---|---|
  | LVDC | 2.07 | 2.07 |
  | AUD | 1.75 | 3.38 |
  | IHD | 1.46 | 1.15 |
  | IJ | 1.32 | 1.62 |
  | DM | 1.37 | 1.05 |
  | HYPHD | 1.07 | 1.07 |
  | ISTR, MVACC, UIJ | 1.00 | 1.00 |

  — [risk_param.rds](https://github.com/charlotteprobst/simah/tree/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/inst/extdata). The file also contains education-specific parameters (`B_LVDC_College/SomeC/LEHS`, `B_AUD_*`, `B_IHD_*_LEHS`) that the v1.0.1 `assign_rr_*` functions do not use (observation from code).
- **AUD special case.** AUD risk is set to zero for lifetime abstainers (`drinkingstatus == FALSE & formerdrinker == FALSE`) — [simulate_mortality.R L28–L35](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/simulate_mortality.R)
- **Former-drinker status.** Each year the proportion of former drinkers among abstainers is computed by age group × sex. Every abstainer's `formerdrinker` flag is then redrawn by a uniform draw against that proportion. The main loop comments: "allocate former drinker status - note: this is not tracked over time" — [update_former_drinker.R](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/update_former_drinker.R), [microsimulation.R L312–L313](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/microsimulation.R)
- **Counterfactual (TMREL) scenario.** `counterfactual == 1` sets `alc_gpd = 0`, `formerdrinker = FALSE`, `drinkingstatus = FALSE` and `hed_binary = FALSE` for everyone and stops alcohol updating — [microsimulation.R L127–L134](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/microsimulation.R)
- **No lag.** RRs are recomputed every year from current g/day; there is no lag code in the package (code inspection). The policy is applied before mortality in the policy year, so it affects mortality in that same year — [microsimulation.R L137–L147, L233–L270](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/microsimulation.R). Lemp 2026 excluded alcohol-related cancers: "they cannot be adequately represented within the present modeling framework based on annual drinking transitions and comparatively short-term follow-up" — [Lemp 2026](https://doi.org/10.1001/jamahealthforum.2026.2348)
- **Validation output.** `postprocess_mortality()` can join observed death counts by stratum next to simulated counts, to compare simulated and observed mortality by cause — [postprocess_mortality.R](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/postprocess_mortality.R)
- **Kilian 2025 outcomes.** Kilian 2025 reports consumption outcomes only. Mortality "within each subgroup was based on individual death records" from NVSS for population dynamics. Policies were applied in 2019: participation elasticity first (quitters sampled proportionally by alcohol-use category), then beverage-specific own-price elasticities with a U-shaped elasticity–consumption correlation (r = 0.60) — Kilian et al. 2025, Lancet Public Health, [DOI 10.1016/S2468-2667(25)00165-3](https://doi.org/10.1016/S2468-2667(25)00165-3)
- **Policy code in v1.0.1 differs from Kilian 2025.** The released `apply_basic_policy()` applies a single beverage-non-specific elasticity (default −0.1078, SE 0.0442, r_sim_obs = 0.8) to drinkers only, flooring g/day at 0. It does not implement the beverage-specific and participation steps described in Kilian 2025 — [apply_basic_policy.R](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/apply_basic_policy.R), [microsimulation.R L36–L48](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/microsimulation.R)

### Inferences
- **What SIMAH's base rate represents.** It plays the same role as `m_stratum / mean(RR)` (a stratum hazard at RR = 1), but it is obtained by external calibration ("adjusted to align"), not by closed-form normalisation in the code. I could not confirm whether the starting values were `m_obs / mean RR`.
- **Practical consequence.** Because the base rates are fixed inputs per stratum and year, the same base rates are used in the reference and policy runs. The policy effect therefore comes entirely from RR changes, which is the right design for averted deaths.
- **The ×28 inflation is a form of importance sampling** on the death event: about 28× more "staged" deaths are counted (then ÷28), so the relative Monte Carlo error of death counts for ages 18–64 falls by roughly √28 ≈ 5.3. Only 1/28 of those staged are removed, so population dynamics stay correct in expectation.
  - Caveat: with ×28 the inflated cumulative risk can exceed 1 for very heavy drinkers, which triggers the global renormalisation by `max_risk`.
  - Caveat: that renormalisation divides everyone's risk, not just the extreme person's — a potential distortion to check if Chile copies this.
- **For Chile.** SIMAH's structure (residual causes from observed counts + modelled causes as RR × stratum base rate + HED modifying injury RRs + former-drinker override + YLL) maps directly onto a DEIS-based design. The two components SIMAH lacks are lags and tracked former-drinker histories; these need explicit choices (Q2, Q6).

### Gaps
- The exact algorithm SIMAH used to produce `base_rates.rds` (initial values, calibration target, metric, iterations) is not in the released package. It is presumably in the Kilian 2025 supplement or Lemp 2026 eAppendix, which I could not open. Unverified.
- I could not confirm that GitHub tag v1.0.1 equals Zenodo 10.5281/zenodo.15641639 (release 0.1.1), and I could not inspect the code version actually used for Kilian 2025 (beverage-specific and participation policy).
- The SIMAH design paper (Probst et al. 2023, Am J Epidemiol, [DOI 10.1093/aje/kwad018](https://doi.org/10.1093/aje/kwad018)) full text was not retrievable (PMC returned an empty body). Only its abstract was read.

## Q2. SAPM (and STAPM) time lags and potential impact fractions: how should a microsimulation phase in mortality changes?

### Takeaway
SAPM (cohort-based) applies a PIF-style ratio of aggregated risk (post-policy vs baseline) to baseline cause-specific mortality rates. It phases effects in with disease-specific lag weights from Holmes et al. 2012, reaching the full effect after 20 years. STAPM (individual-level) moved the lag onto each person: the current RR is a weighted average of that person's last 20 years of RRs, with weights equal to the Holmes/SAPM lag percentages. Acute causes take effect 100% in year 1.

### Cited Findings
- **SAPM mechanics.** "The model operates in 1-y cycles: within each year the 43 risk functions are used to calculate the condition-specific alcohol-attributable mortality risk for individuals within each cohort given their consumption level. This risk is aggregated across all individuals in the cohort and compared to the baseline risk under pre-policy consumption levels, and the ratio between the two is used to adjust the baseline mortality rate and estimate the corresponding number of deaths for that cohort and condition in that year." — Meier et al. 2016, PLoS Med (SAPM v3), [DOI 10.1371/journal.pmed.1001963](https://doi.org/10.1371/journal.pmed.1001963)
- **SAPM lags.** "All consumption changes are assumed to occur in the first year after intervention, but delays (time lags) … vary by disease. Lag parameters were taken from a recent systematic review … Maximum intervention effects in the model are reached after 20 y (the longest identified lag time), and all harm results are reported for the 20th year following policy implementation." — [Meier 2016](https://doi.org/10.1371/journal.pmed.1001963)
- **SAPM risk functions and AAF = 1 causes.** Chronic partly-attributable conditions use meta-analytic RR functions. Acute conditions use functions linking drinking frequency, occasion-specific consumption and variability to injury risk. For wholly attributable conditions, "we fitted linear functions relating average or maximum daily consumption to absolute numbers of cases" — [Meier 2016](https://doi.org/10.1371/journal.pmed.1001963)
- **SAPM transitions and uncertainty.** SAPM v3 applies a percentage change in consumption to each individual. It does "not model any transition between drinkers and abstainers", and baseline moderate drinkers stay classified by baseline status. It is "fully deterministic". Uncertainty came from 30 partial PSA runs (bootstrap of survey data, sampled elasticities and RR uncertainty). The cohort-based harm model has a "mortality selection" limitation — [Meier 2016](https://doi.org/10.1371/journal.pmed.1001963)
- **Holmes et al. 2012 is in *Drug and Alcohol Dependence*, not *Addiction*.** Holmes J, Meier PS, Booth A, Guo Y, Brennan A. "The temporal relationship between per capita alcohol consumption and harm: a systematic review of time lag specifications in aggregate time series analyses." Drug Alcohol Depend 2012;123(1–3):7–14. It covers 36 studies dominated by liver cirrhosis, heart disease and suicide, and finds "strong evidence of an immediate first effect following a change in consumption for most harms"; "recommended lag specifications are proposed" — [DOI 10.1016/j.drugalcdep.2011.12.005](https://doi.org/10.1016/j.drugalcdep.2011.12.005)
- **Holmes lag numbers ("the numbers used in the current version of SAPM").** Annual % of the eventual risk change realised in years 1…20, from `tobalcepi::AlcLags()` — [AlcLags.R L60–L118](https://github.com/stapm/tobalcepi/blob/054ca37190ad901aa5028bd6222e831083472eaa/R/AlcLags.R):

  | Condition group | Lag profile (years 1…20) |
  |---|---|
  | Default / acute | 100% in year 1 |
  | Cancers (pharynx, oral, oesophageal SCC, colorectal, liver, larynx, pancreas, breast) | 0 for years 1–10, 10%/yr for years 11–20 |
  | IHD, haemorrhagic and ischaemic stroke | 30.87, 21.61, 15.13, 10.59, 7.41, 5.19, 3.63, 2.54, 1.78, 1.25, then 0 |
  | Diabetes, hypertensive heart disease, arrhythmias | 22.41, 17.92, 14.34, 11.47, 9.18, 7.34, 5.87, 4.70, 3.76, 3.01, then 0 |
  | Liver cirrhosis, pancreatitis | 20.23, 16.19, 12.95, 10.36, 8.29, 6.63, 5.30, 4.24, 3.39, 2.72, … declining to 0.29 at year 20 |
  | Alcoholic liver disease | 20.67, 13.16, 9.20, 7.04, … 1.65 at year 20 |
  | Alcohol-specific chronic conditions (cardiomyopathy, polyneuropathy, myopathy, degeneration) | 5%/yr for 20 years |
  | Epilepsy | 43.4, 26.0, 15.6, 9.4, 5.6 |
  | Respiratory infections | 60.6, 24.2, 9.7, 3.9, 1.6 |

- **STAPM individual-level adaptation.** "In each year of the simulation, the current relative risk of an individual is adjusted to take account of each individual's stored drinking histories. This adjustment takes the form of a weighted average of current and past relative risk, where the weights are proportional to the disease-specific lag function … This method is slightly different to the method that was developed for SAPM" — [tobalcepi RRFunc.R L24–L39](https://github.com/stapm/tobalcepi/blob/054ca37190ad901aa5028bd6222e831083472eaa/R/RRFunc.R)
  - Details: each person's RR history is back-filled with their first stored RR for years before model entry.
  - A 2025-02-25 QA fix changed the weights from `(1 + prop)` to the Holmes values themselves.
  - When all weights are zero (e.g., cancers within the first 10 years), the first stored RR is used — [RRFunc.R ~L612–L760](https://github.com/stapm/tobalcepi/blob/054ca37190ad901aa5028bd6222e831083472eaa/R/RRFunc.R)
- **STAPM PIF by ratio of mean RRs.** `subgroupRisk()` computes the average RR per subgroup "so that when we later calculate the ratio of this aggregated relative risk between treatment and control arms, the ratio is not influenced by differences in the number of individuals i.e. we want to calculate the ratio of the expected value of individual risk in each arm" — [subgroupRisk.R ~L196–L203](https://github.com/stapm/tobalcepi/blob/054ca37190ad901aa5028bd6222e831083472eaa/R/subgroupRisk.R)
- **Wholly attributable conditions in STAPM.** They use absolute rather than relative risk ("List of diseases for which absolute rather than relative risk is used … all the wholly attributable acute and chronic conditions for alcohol") — [subgroupRisk.R](https://github.com/stapm/tobalcepi/blob/054ca37190ad901aa5028bd6222e831083472eaa/R/subgroupRisk.R)
- **Lemp 2026 timing.** It quantified "the mortality cost of delaying expansion": cumulative YLL averted over 2025–2030 fell with each year of delay (e.g., 3-year delay in scenario 3 cost 116.8 YLL/100k men). No lag structure was described for the included acute and liver causes — [Lemp 2026](https://doi.org/10.1001/jamahealthforum.2026.2348)

### Inferences
- **Where to put the lag in Chile's annual cycle**, given the age 15–65 window, SIMAH-like structure and 2012–2034 horizon:
  - **Option A (STAPM).** Store each person's per-cause RR history (or g/day history) and use `RR_lagged,t = Σ_k w_k RR_{t−k+1} / Σ_k w_k`, with Holmes weights `w_k`.
  - **Option B (SAPM-like, cheaper).** Compute the unlagged policy-vs-reference ratio of expected deaths per stratum and cause, then phase it in with the cumulative lag: `effect_t = Σ_{k≤t} w_k/100 × full_effect`. For a one-off permanent policy shift, A and B agree. For changing exposures, A is more faithful.
- **Interpreting the lag table.** The table is annual increments: they sum to about 100 per condition. The documentation describes "cumulative proportion", but the QA comment shows the cumulative transform was flagged as an error. Use the values as weights, as STAPM does after the QA fix.
- **Effect of a lag on the comparison.** Lags shrink averted deaths early in the horizon. Reporting at year 20 (SAPM) versus cumulatively over 2025–2034 gives very different numbers, so the reporting horizon must be explicit. For a 15–65 window, cohort ageing out at 66 truncates the lagged benefits (relevant for cancers and IHD).

### Gaps
- I did not read the Holmes 2012 full text, so the lag values are taken from the SAPM/STAPM implementation that says they come from it, not from the paper's own table.
- I found no published sensitivity analysis comparing STAPM's individual-history lag with SAPM's PIF-lag for the same policy. The code comment says the difference "might have an influence on results" — [RRFunc.R](https://github.com/stapm/tobalcepi/blob/054ca37190ad901aa5028bd6222e831083472eaa/R/RRFunc.R)
- I found no Rehm-group time-lag papers beyond Holmes 2012 in this session (search budget).

## Q3. Other chronic-disease microsimulations (IMPACTncd, OECD SPHeP-NCDs, PRIMEtime, POHEM, DYNAMO-HIA): baseline hazards with risk factors, competing risks, calibration to observed mortality, drift

### Takeaway
IMPACTncd literally implements RR normalisation: `PARF = 1 − N/ΣRR_i` per stratum (age × sex × deprivation × ethnicity × region), and `m0 = mu × (1 − PARF) = mu / mean(RR)`, with individual hazard `= m0 × ΠRR_i × calibration factor`. It then adds iterative calibration factors (intercept, trend^(year−init) and an ONS factor) to correct residual drift. PRIMEtime and DYNAMO-HIA are cohort or multistate life tables that apply PIFs to incidence. OECD SPHeP-NCDs uses GBD RRs and calibrates incidence and prevalence (documentation not readable here).

### Cited Findings
- **IMPACTncd mortality PARF and m0.**
  - `parf_mrtl = 1 - .N / sum(.rr_prod_mrtl)` keyed by `age, sex, dimd, ethnicity, sha` — [Disease_class.R L512–L519](https://github.com/ChristK/IMPACTncd_Engl/blob/3c44cbf4a6ec974b0730c181381d6ebfcb0d0ba4/Rpackage/IMPACTncd_England_model_pkg/R/Disease_class.R)
  - `parf_dt[, "m0" := mu * (1 - parf_mrtl)]` — [Disease_class.R L552](https://github.com/ChristK/IMPACTncd_Engl/blob/3c44cbf4a6ec974b0730c181381d6ebfcb0d0ba4/Rpackage/IMPACTncd_England_model_pkg/R/Disease_class.R)
- **IMPACTncd incidence.** Individual incidence probability = `clamp(uf * p0 * risk_product * clbfctr)`. A code note warns: "product above not expected to be equal to incidence because p0 estimated using mean lags and RR, while each mc run samples from their distribution." — [Disease_class.R ~L1162–L1172](https://github.com/ChristK/IMPACTncd_Engl/blob/3c44cbf4a6ec974b0730c181381d6ebfcb0d0ba4/Rpackage/IMPACTncd_England_model_pkg/R/Disease_class.R)
- **IMPACTncd mortality calibration.** The calibration factor is `clbfctr × clbintrc × clbons(=1.45) × mrtl_clbr × clbtrend^(year − init_year)`, with the comment "ONS calibration was calculated with this in place. Do not remove or change unless you plan to redo the calibration" — [Disease_class.R L1505–L1527](https://github.com/ChristK/IMPACTncd_Engl/blob/3c44cbf4a6ec974b0730c181381d6ebfcb0d0ba4/Rpackage/IMPACTncd_England_model_pkg/R/Disease_class.R). The calibration method "runs a Monte Carlo set, then iteratively adjusts disease-specific calibration factors (`*_incd_clbr_fctr`, `*_ftlt_clbr_fctr`) so simulated incidence and mortality match observed targets" — [Simulation_class_calibration.R L24–L35](https://github.com/ChristK/IMPACTncd_Engl/blob/3c44cbf4a6ec974b0730c181381d6ebfcb0d0ba4/Rpackage/IMPACTncd_England_model_pkg/R/Simulation_class_calibration.R)
- **IMPACTncd exposure lags.** Each RR carries a `lag` (exposure measured `lag` years earlier). Initial disease prevalence for disease-as-exposure is set by shifting `year` back by the lag — [Disease_class.R ~L155, L405–L425](https://github.com/ChristK/IMPACTncd_Engl/blob/3c44cbf4a6ec974b0730c181381d6ebfcb0d0ba4/Rpackage/IMPACTncd_England_model_pkg/R/Disease_class.R)
- **PRIMEtime CE** is "a multistate life table model" that changes the risk-factor distribution and quantifies "the subsequent effect on population mortality and morbidity". It requires "age and sex specific data on baseline disease incidence, prevalence, case fatality, and trends", and was cross-validated against the UK Health Forum microsimulation and IMPACT CHD with mixed results — Briggs et al. 2019, BMC Health Serv Res, [DOI 10.1186/s12913-019-4292-x](https://doi.org/10.1186/s12913-019-4292-x)
- **DYNAMO-HIA** is a Markov-based tool with "explicit risk-factor states" and "a built-in parameter estimation module" requiring only "incidence, prevalence, relative risks, and mortality". It compares a reference scenario with intervention scenarios, and an alcohol example is included — Lhachimi et al. 2012, PLoS One, [DOI 10.1371/journal.pone.0033317](https://doi.org/10.1371/journal.pone.0033317) (abstract only read).
- **OECD SPHeP-NCDs** (from search-result summaries; pages not fetched because oecd.org was blocked — treat as unverified):
  - each year an individual "has a certain risk of developing a disease" based on their characteristics;
  - RRs are "based on the Global Burden of Disease study, amongst others";
  - risk factors are "distributed independently" with no mediators;
  - incidence and prevalence "are calibrated to match estimates from international datasets";
  - the model "maintains current (age‑ and gender-specific) rates for risk factors".

  — [OECD SPHeP-NCDs model chapter](https://www.oecd.org/en/publications/the-health-and-economic-benefits-of-tackling-non-communicable-diseases_e20cbbc3-en/full-report/the-oecd-sphep-ncds-model_21046dae.html); [OECD mental health methodology](https://www.oecd-ilibrary.org/en/publications/mental-health-promotion-and-prevention_88bbe914-en/full-report/methodology_b5bd871e.html). Technical documentation is said to be at http://oecdpublichealthexplorer.org/ncd-doc (not opened).
- **POHEM** (Statistics Canada) is cited as a microsimulation that "simulates the lifecycle of the Canadian population" — Krijkamp et al. 2018, [DOI 10.1177/0272989X18754513](https://doi.org/10.1177/0272989X18754513). No methodological detail on its mortality calibration was retrieved.
- **SAPM drift handling.** SAPM takes baseline all-cause and condition-specific mortality from ONS data and apportions condition-specific rates to socioeconomic groups using published gradients; the policy ratio multiplies these baseline rates — [Meier 2016](https://doi.org/10.1371/journal.pmed.1001963). SIMAH uses Census Bureau death projections after 2024 — [Lemp 2026](https://doi.org/10.1001/jamahealthforum.2026.2348)

### Inferences
- **Recommended Chilean hazard** (closest to IMPACTncd + SIMAH): `h_ic,t = m0_c(s,a,t) × RR_c,i,t` with
  `m0_c(s,a,t) = m_DEIS_c(s,a,t) / mean_{i∈(s,a)} RR_c,i,t (reference scenario)`.
  - This reproduces DEIS deaths exactly in each calibration year when the simulated exposure distribution is the one that drives the RR.
  - DEIS reproduction therefore becomes an identity, not a validation. Validate instead on held-out years, or on unmodelled targets such as cause mix by drinking status, or AAF agreement (Q4).
- **Drift.** For 2012–2024, either recompute `m0` yearly (an exact fit) or fit `m0` with a smooth trend in log space (IMPACTncd's `clbtrend^(year−init)`). Use the trend for projections to 2034. The second option leaves residual misfit visible and is more defensible for projections.
- **Competing risks within the annual step.** SIMAH draws one uniform for all modelled causes (mutually exclusive). An equivalent hazard-based form is `P(die of c) = (h_c/Σh) × (1 − exp(−Σh))` if rates are continuous-time; this matters only where Σh is non-negligible (older ages, heavy drinkers).

### Gaps
- OECD SPHeP-NCDs technical documentation (how baseline incidence and mortality are made "risk-deleted" and calibrated) could not be read; the claims above are search snippets only.
- No primary source on POHEM's mortality alignment was retrieved.
- IMPACTncd's methods papers (Kypridemos et al.) were not read; findings come from code only.
- Vivarium (IHME) docs on PAF-based "risk-deleted" rates were blocked.

## Q4. When do microsimulation attributable deaths agree with comparative-risk-assessment PAF/AAF, and where do they diverge?

### Takeaway
In a single static year, microsimulation attributable deaths equal CRA when four conditions hold: (i) the same exposure distribution (including former drinkers and HED); (ii) the same RR functions and caps; (iii) RR-normalised baseline hazards; and (iv) a TMREL counterfactual equal to "everyone a lifetime abstainer". This follows because the CRA AAF equals `1 − 1/mean(RR)`, which is exactly IMPACTncd's PARF. Divergence arises from dynamics: depletion of high-RR individuals (survival/mortality selection), lags, former-drinker and sick-quitter handling, competing risks that redistribute averted deaths to other causes, exposure capping, and stochastic versus mean RR.

### Cited Findings
- **CRA AAF with former drinkers** (Rehm et al. 2010). AAFs "based on continuous distributions" use the proportion of lifetime abstainers, the proportion of former drinkers, `P(x)` the distribution among drinkers, `RR_former`, and `RR(x)` the RR in g/day. A sensitivity analysis capped consumption at 150 g/day. CIs came from 10,000 bootstrap simulations — Rehm et al. 2010, Popul Health Metr, [DOI 10.1186/1478-7954-8-3](https://doi.org/10.1186/1478-7954-8-3). The typeset formula was an image and not extractable, so I verified the components but not the exact typography.
- **Implemented AAF.** `PAF = Σ w_i (RR_i − 1) / (Σ w_i (RR_i − 1) + 1)` with normalised weights `w_i`, "using the method as in Bellis & Jones 2014, which is also equivalent to the method described in the Brennan et al. 2015 SAPM mathematical description paper" — [tobalcepi subgroupRisk.R L1–L8, L265–L276](https://github.com/stapm/tobalcepi/blob/054ca37190ad901aa5028bd6222e831083472eaa/R/subgroupRisk.R). (With Σw = 1, this equals `1 − 1/mean(RR)`; my algebra, see Inferences.)
- **IMPACTncd PARF.** `1 − N/ΣRR` — [Disease_class.R L515](https://github.com/ChristK/IMPACTncd_Engl/blob/3c44cbf4a6ec974b0730c181381d6ebfcb0d0ba4/Rpackage/IMPACTncd_England_model_pkg/R/Disease_class.R)
- **AAF definition.** AAF is "the percentage of mortality that would not occur if everyone was a lifetime abstainer"; wholly attributable conditions have AAF = 1 — Shield et al. 2013, Subst Abuse Treat Prev Policy, [DOI 10.1186/1747-597X-8-21](https://doi.org/10.1186/1747-597X-8-21). The same paper estimated treatment effects by computing "AAFs … before and after interventions" on 100,000 simulated drinkers (a static PIF), not a dynamic simulation — [same](https://doi.org/10.1186/1747-597X-8-21)
- **Microsimulation equivalent of the AAF counterfactual.** SIMAH's TMREL run sets every agent to gpd = 0, non-former and non-HED, i.e., "lifetime abstainer" — [microsimulation.R L127–L134](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/microsimulation.R)
- **Capping matters.** Capping the exposure distribution and RR functions at 150 g/day may underestimate EU alcohol-attributable mortality by 25.5% (men) and 8.0% (women) — Gmel et al. 2013, BMC Med Res Methodol, [DOI 10.1186/1471-2288-13-24](https://doi.org/10.1186/1471-2288-13-24). SIMAH caps RRs at cause-specific reference intakes (e.g., LVDC 179.44 g men) — [assign_rr_lvdc.R](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/assign_rr_lvdc.R)
- **PIF calculation method.** The "proportion shift" calculation "produces non-linear artefacts and is best avoided". "RR shift" and "distribution shift" give virtually the same results — Barendregt & Veerman 2010, J Epidemiol Community Health, [DOI 10.1136/jech.2009.090274](https://doi.org/10.1136/jech.2009.090274)
- **Mortality selection.** SAPM acknowledges "mortality selection" as a limitation of cohort-based harm modelling, "likely to be only a minor source of error" — [Meier 2016](https://doi.org/10.1371/journal.pmed.1001963)
- **Mean vs sampled RR.** In IMPACTncd, baseline `p0` is estimated with mean lags and RR, while each Monte Carlo run samples from their distribution, so simulated incidence is "not expected to be equal" to observed. This is why an extra calibration factor exists — [Disease_class.R ~L1170](https://github.com/ChristK/IMPACTncd_Engl/blob/3c44cbf4a6ec974b0730c181381d6ebfcb0d0ba4/Rpackage/IMPACTncd_England_model_pkg/R/Disease_class.R)
- **Microsimulation converges to the cohort model.** "Outcomes from microsimulation models where no 'memory' and no heterogeneity at baseline across individuals is assumed, should asymptotically converge to those from a deterministic cohort model as the number of individuals simulated … increases" — [Krijkamp 2018](https://doi.org/10.1177/0272989X18754513)

### Inferences
- **Algebraic identity (my derivation).** With `m0 = m_obs / mean(RR)`, the expected deaths in a stratum are `m0·Σ RR_i = m_obs·N`. Under TMREL they are `m0·N`. Attributable deaths are therefore `m_obs·N·(1 − 1/mean RR) = AAF × observed deaths`. Static agreement with the existing expand_pif AAF tables is exact iff the same exposure (after APC/underreporting scaling), the same RR functions (including former and HED components and caps) and the same strata are used. This is a strong unit test to implement.
- **Expected divergences in a dynamic multi-year run:**
  - (a) Heavy drinkers die first, lowering mean RR in survivors (selection). Cumulative microsimulation attributable deaths fall below summed annual AAF × deaths.
  - (b) People "saved" from an alcohol cause remain at risk from other causes in later years. Net all-cause deaths averted over a horizon is below the sum of cause-specific averted deaths.
  - (c) With lags, a counterfactual started in year t does not remove attributable deaths immediately (cancers 0% for 10 years).
  - (d) If former-drinker status is assigned randomly (SIMAH), the former-drinker contribution matches CRA in aggregate but not person-level histories.
  - (e) For AAF = 1 causes, RR-normalisation is undefined (the TMREL rate is 0). Use absolute-risk functions as SAPM and STAPM do, or SIMAH's AUD device (zero risk for lifetime abstainers; for drinkers the stratum "base rate" acts as a scale parameter for `exp(b·gpd)`).
- **Do not normalise the policy arm.** Renormalising `m0` within the policy arm (dividing by the policy-arm mean RR) would force policy deaths to equal observed deaths and cancel the effect. `m0` must come from the reference arm only. This is a key implementation pitfall; it follows from the SAPM and STAPM ratio designs.

### Gaps
- I found no peer-reviewed alcohol-specific paper that quantifies microsimulation-vs-CRA discrepancies empirically (e.g., SIMAH TMREL-run deaths vs WHO/GBD AAF deaths for the same US years). This is a potential validation exercise for Chile.
- I did not retrieve Bellis & Jones 2014 or Brennan et al. 2015 (SAPM mathematical description) directly; they are cited via tobalcepi.

## Q5. Statistical design of policy comparisons: common random numbers, expected-value vs sampled deaths, agents/runs for acceptable Monte Carlo error, first- vs second-order uncertainty

### Takeaway
Run the policy and reference arms with common random numbers, with the same agents and synchronised random streams per process (transitions, HED, mortality). Estimate averted deaths as the sum over person-years of hazard differences (expected-value accounting), and keep sampled deaths only to update the population. Separate Monte Carlo (first-order) noise from parameter (second-order) uncertainty with a parameter-set × replication design: SIMAH used 70 × 20 (Lemp 2026) and 60 × 10 (Kilian 2025).

### Cited Findings
- **CRN definition.** CRN is "the coordinated or synchronized use of random numbers such that the same random numbers are 'common' to the same stochastic events across all model runs". Separate streams should be assigned to groups of events, with per-individual substreams. CRN enables individual-level counterfactual comparisons — Stout & Goldie 2008, Health Care Manag Sci, [DOI 10.1007/s10729-008-9067-6](https://doi.org/10.1007/s10729-008-9067-6)
- **CRN magnitude.** In their example, CRN reduced the variance of between-run differences by 82%, versus 71% for a ten-fold larger cohort. Use paired tests, not two-sample tests, on CRN outputs. Recommended generators are Mersenne Twister or L'Ecuyer RngStream — [Stout & Goldie 2008](https://doi.org/10.1007/s10729-008-9067-6)
- **Same individuals across arms.** Simulated individuals should be "as similar as possible across comparators, except for the intervention", achieved "by using pre-sampled values … by explicitly setting a seed number per individual". The variability around the mean is the Monte Carlo standard error (MCSE). Microsimulation alone represents "first-order uncertainty"; PSA is "second-order Monte Carlo simulation" — [Krijkamp 2018](https://doi.org/10.1177/0272989X18754513)
- **Choosing sample sizes.** O'Hagan, Stevenson & Madan (2007) give ANOVA-based estimators of the mean and variance of patient-level simulation output under PSA, "with formulae for determining optimal sample sizes" (individuals per run vs number of parameter draws) — [DOI 10.1002/hec.1199](https://doi.org/10.1002/hec.1199) (abstract only; formulas not extracted).
- **Good-practice guidance.** The ISPOR-SMDM state-transition modelling task force defines individual-based (first-order Monte Carlo) microsimulation and gives best-practice recommendations — Siebert et al. 2012, Value Health, [DOI 10.1016/j.jval.2012.06.014](https://doi.org/10.1016/j.jval.2012.06.014) (abstract only).
- **SIMAH, Lemp 2026.** "70 parameters sets with 20 stochastic replications each (1400 runs per scenario)". The 95% CrI is the 2.5th–97.5th percentile across the 70 parameter sets and "reflects uncertainty in model inputs following calibration" — [Lemp 2026](https://doi.org/10.1001/jamahealthforum.2026.2348)
- **SIMAH, Kilian 2025.** "60 unique combinations of parameter settings … paired with distinct beverage-specific mean consumption elasticities". Each was simulated 10 times with different seeds and averaged (600 runs), and CIs were the minimum–maximum across the 60 — [Kilian 2025](https://doi.org/10.1016/S2468-2667(25)00165-3)
- **SIMAH sampled-death mechanics.** SIMAH counts sampled deaths (uniform draw against stacked risks) and reduces their noise with the ×28 / ×3 inflation plus de-inflation — [simulate_mortality.R](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/simulate_mortality.R), [summary_disease.R](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/summary_disease.R). SIMAH seeds once per run with `set.seed(seed)` — [microsimulation.R](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/microsimulation.R). It has no per-process or per-individual streams in v1.0.1 (code inspection). Arms with different code paths therefore desynchronise random numbers after the policy year.
- **SAPM.** SAPM v3 is deterministic (expected values), with 30 partial PSA runs — [Meier 2016](https://doi.org/10.1371/journal.pmed.1001963)

### Inferences
These are standard probability results applied to this setting; they are not from a single cited source.

- **Sampled deaths in arm k.** `D_k = Σ_i Bernoulli(h_ik)`, so `Var(D_k) = Σ h_ik(1 − h_ik) ≈ E[D_k]`.
  - Independent streams: `SD(D_0 − D_1) ≈ √(E[D_0] + E[D_1])`.
  - CRN with one shared uniform per person-year-cause and `h_i1 ≤ h_i0`: deaths differ only when `h_i1 < u_i ≤ h_i0`, so `Var(D_0 − D_1) ≈ Σ (h_i0 − h_i1) ≈ E[A]` and `SD ≈ √A`.
  - Expected-value accounting: `A_t = Σ_i (h_i0,t − h_i1,t)` removes the death-draw noise for year t completely. Remaining Monte Carlo noise comes only from stochastic exposure transitions, which CRN also couples.
- **Hypothetical illustration (not Chilean data).** Assume 4,000 modelled-cause deaths per year in the reference arm at 1:1 scale and a policy averting 1% (40).
  - Independent sampling: SD ≈ 89 — the effect is undetectable in a single run.
  - CRN-sampled: SD ≈ 6.3.
  - Expected-value: ≈ 0 from death draws.
  - With a 1:10 synthetic population (each agent = 10 people), real-unit SDs grow by √10 (CRN ≈ 20; independent ≈ 283).
  - Scaling rule: required replications `R ≥ (SD_run / target MCSE)²`.
- **Recommended design for Chile:**
  - (1) CRN per process (alcohol transitions, HED, former-status, mortality) and per individual. In R, pre-draw uniform matrices per process-year or derive streams from `(seed, person_id, year, process)`.
  - (2) Report averted deaths and YPLL as expected values (sum of hazard differences). Keep sampled deaths for removing people, with the same uniforms in both arms.
  - (3) Use outer loop = parameter draws (RR coefficients, elasticities, calibrated transition parameters) and inner loop = a few replications. Report the second-order interval across parameter sets, and report the Monte Carlo SE separately, e.g., via the O'Hagan ANOVA split.
  - (4) Never compare arms with different seeds or different population draws.

### Gaps
- I did not extract the explicit O'Hagan 2007 sample-size formulas (paywalled; abstract only).
- I found no published alcohol-microsimulation paper reporting the Monte Carlo SE of averted deaths separately from the parameter interval.
- Chile-specific death counts for the illustration are hypothetical; actual DEIS counts for the modelled causes (ages 15–65) should replace them.

## Q6. Former drinkers: definition, RR assignment, and treatment of policy-induced quitters

### Takeaway
CRA defines former drinkers as people who drank ≥ 1 standard drink in life but not in the past 12 months, and assigns cause-specific former-drinker RRs (partly reflecting "sick quitters"). Microsimulations differ:
- **SIMAH** applies cause-specific former-drinker RRs (e.g., cirrhosis 2.07) but redraws former status each year at the observed age × sex proportion among abstainers ("not tracked over time").
- **STAPM** has no former-drinker state; RR simply follows consumption to zero.
- **SAPM** does not model transitions to abstention at all.

None tracks time since quitting. A policy that induces quitting will therefore give some quitters an RR above 1 for several causes, unless the former RR is lagged or restricted.

### Cited Findings
- **Definitions.** Current drinkers are "people who have consumed at least one standard drink of alcohol in the past year". Former drinkers are "people who have consumed at least one standard drink of alcohol, but did not do so in the past year". Lifetime abstainers are "people who have never consumed at least one standard drink" — [Shield et al. 2013](https://doi.org/10.1186/1747-597X-8-21)
- **CRA formula.** The AAF uses separate proportions of lifetime abstainers and former drinkers and a former-drinker RR — [Rehm et al. 2010](https://doi.org/10.1186/1478-7954-8-3)
- **Sick quitters.** For CVD CRA, the "risk of former drinkers was modelled taking into account global differences in the prevalence of sick quitters among former drinkers" — Rehm et al. 2016, BMC Public Health, [DOI 10.1186/s12889-016-3026-9](https://doi.org/10.1186/s12889-016-3026-9)
- **SIMAH former-drinker mechanics.** Former-drinker RRs override the dose–response RR (`RR = exp(…_FORMERDRINKER)`) for LVDC, AUD, IJ, IHD, DM, HYPHD, ISTR, MVACC and UIJ, with the shipped values in Q1. Former status is redrawn yearly for all abstainers by age group × sex — [assign_rr_*.R](https://github.com/charlotteprobst/simah/tree/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R), [update_former_drinker.R](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/update_former_drinker.R)
- **STAPM.** "Unlike tobacco, there is no 'former drinker' state in our alcohol modelling, meaning that individuals are not recorded as being former drinkers -- instead their alcohol consumption just falls to zero and their relative risk for disease changes accordingly." — [tobalcepi RRFunc.R L18–L22](https://github.com/stapm/tobalcepi/blob/054ca37190ad901aa5028bd6222e831083472eaa/R/RRFunc.R)
- **SAPM.** SAPM v3 does "not model any transition between drinkers and abstainers", which the authors say likely underestimates policy effects — [Meier 2016](https://doi.org/10.1371/journal.pmed.1001963)
- **Kilian 2025 quitters.** Kilian 2025 samples policy-induced quitters via participation elasticity, weighted by each category's probability of transitioning to abstinence. The text does not say what former-drinker status quitters receive — [Kilian 2025](https://doi.org/10.1016/S2468-2667(25)00165-3). In the released loop, `update_former_drinker()` runs after alcohol transitions each year — [microsimulation.R L306–L313](https://github.com/charlotteprobst/simah/blob/2fd8c1ea8c95de0a7137e31db2560a5ceb60339d/R/microsimulation.R)

### Inferences
- **How SIMAH treats policy-induced quitters.** They become abstainers and are then randomly assigned former status at the prevailing abstainer proportion. Because that proportion is recomputed from the simulated population, more quitters raise the former share only through carried-over flags (inference from code; unverified for the Kilian 2025 build).
- **Chilean design options** (state the choice explicitly):
  - (a) **Tracked status.** Track `years_since_quit` and define former = abstinent > 12 months (consistent with ENPG and CRA). Quitters spend year 1 as "current, 0 g" with RR = 1 (or their lagged RR, Q2).
  - (b) **Lagged blend.** Apply former-drinker RRs to policy quitters only via a lag-weighted blend from their pre-quit RR towards the former RR. This is closer to the sick-quitter rationale: former-drinker excess risk mostly reflects people who quit because they were ill, which a price-induced quitter is not.
  - (c) **Sensitivity bounds.** Run quitters = lifetime-abstainer RR (upper bound of benefit) versus quitters = former-drinker RR (lower bound).

  Applying full former-drinker RRs (e.g., cirrhosis 2.07, AUD up to 3.38 in SIMAH) to price-induced quitters can make participation responses look harmful in the short run. This should be flagged.
- **Consistency with the AAF/PIF module (AGENTS.md §5).** The microsimulation's former-drinker prevalence by sex × age should match ENPG at baseline. The static AAF check (Q4) must use the same former-drinker RRs as the AAF module.

### Gaps
- No primary source found on how SIMAH's Kilian 2025 build set `formerdrinker` for participation-elasticity quitters (supplement not accessible).
- No peer-reviewed estimate was found of former-drinker RR as a function of time since quitting for alcohol (the tobacco analogue exists in `tobalcepi::TobLags`, not reviewed).
- WHO/GBD former-drinker RR sources for each cause were not re-verified in this session; the project's existing RR registry should remain authoritative.
