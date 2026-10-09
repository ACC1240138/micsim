# Microsimulation engine: ponytail audit, SIMAH map and minimal path to the Monday deliverable

Date 2026-10-09. Scope: `__andres_control/microsim_recalib_ACC_2012_2024.ipynb` (all 14 code cells read), its diff
against `microsim_base_ACC_2012_2024.ipynb`, `jrt/simulacion/*.R`, the RR/AAF/PIF pipeline (`aaf_unified.R`,
`rr_registry_adam.R`, `ypll_icd_defs.R`, `pif2_*` artifacts), the user notes (`microsim_respuestas_preguntas_2026-09-20.md`
§16–§26, `guion_reunion_ACC_2026-09-16_revision_critica.md` §6–§7) and the canonical handoff (entries 2026-09-17 → 2026-10-08).
No repo file was edited. Line numbers are cell-internal (`#| label` cell, line N of that cell's source).

## 0. What was verified by running, and what was only read

| Claim | How | Evidence |
|---|---|---|
| Engine cells are identical in base and recalib (`ms-survey-inputs`, `ms-annual-engine`); only `ms_fit`/`ms_drivers`/`ms_curve`, seeds and outputs differ | `diff` of extracted cells | scratch `work/recal/*.R` vs `work/base/*.R` |
| HED bias −4.5 pp is ~98 % a Gamma-shape artefact, not the indicator or the dynamics | ran `ms-survey-inputs` + `ms_fit` HED model on real ENPG; decomposed per cell | `work/run/hed_audit.R` |
| Intercept-offset HED recalibration removes the bias | ran engine 2012–2024, 3 seeds | `work/run/proto.log` §B |
| Synthetic never-drinker share 6.2 % vs ENPG 25.8 % (2024); trait+AR(1) alone does not fix it | ran engine variants | `proto.log` §C, `never_share.R` |
| Exported `microsim_recalib_outputs/*.csv` are stale (pre DEIS infant fix) | rebuilt `ms_mortality` from current bundles | `work/run/demo_check.R` |
| Person-level RR hook reproduces expand_pif AAF/PIF once the [0.1,150] g/d truncation convention is matched | ran fresh 2024 population, 200k people, 2 causes | `work/run/proto3.R` |
| Dual-arm BI run: null scenario = 0 exactly; control arm keeps DEIS level; avoided deaths and their seed SD | 30 runs 2024–2034 (2 sizes × 3 scenarios × 5 seeds) | `work/run/proto2.log` §G |
| Monte Carlo SD of sampled deaths ≈ 3,600–4,400/yr at n_sim 25k | engine `mc_variance` column + runs | `projection_mortality_interp_hold.csv`, `proto2.log` |
| SIMAH schedule, mortality sub-model, population size, run counts | read Kilian 2025 main text + supplement (`_bib/mmc1.pdf`, decrypted to tempdir only) and Lemp 2026 full text (PubMed Central PMC13428287, [DOI](https://doi.org/10.1001/jamahealthforum.2026.2348)) | §1 |
| Everything about JRT scripts, file layout, deletions | read only | §4–§5 |

Sandbox caveats: `arrow` and `ggplot2` are not installed here; DEIS parquet was read through `pyarrow` into R's `tempdir()`
(no plain microdata written to disk outside tempdir). Scratch root: `<scratch>/work/`.
The prototype (`run/proto_integration.R`, `run/proto2.R`) runs the notebook cells verbatim and overrides only the functions named below; it is the tested source of every sketch in §3.

## 1. Architecture map against SIMAH (Kilian 2025 and Lemp 2026)

Kilian 2025 = price policies, consumption outcomes, **all-cause mortality only** (supplement §1.3.3: "The current sub-model accounts for all-cause mortality").
Lemp 2026 = same SIMAH engine with brief intervention (BI) and **cause-specific RR mortality**. For items 3–4 the template is Lemp 2026, not Kilian 2025.
The base notebook (`ms-03`, row "Mortality") attributes RR-normalised cause-specific rates to "the reference implementation"; that matches Lemp 2026, not the Kilian 2025 supplement. Flag, do not silently keep.

| Element | SIMAH (Kilian 2025 / Lemp 2026) | Chile engine today (cell:line) | Gap / ponytail verdict |
|---|---|---|---|
| Entities, size | Synthetic adults 18–79, default 1,000,000 individuals | 15–65, `n_sim` 25,000 (`ms-setup`:10), unit weight 481 (2012 start) / 552 (2024 start) | OK for margins; for policy contrasts use the paired design (§2.6), raise to 100k only for subgroup tables |
| Static vars | sex, race/ethnicity | sex | race/SES deferred (ACC) — keep deferred |
| Dynamic vars | age, education (18–34), drinking status (current/former/abstainer), alcohol category (4), g/day (0–200, capped), beverage shares, HED (Lemp, modifies injury RR) | age, `z_current`, `z_amount`, `z_hed`, `ever`, `current`, `gpd_survey`, `hed`, `alc_cat` (`ms-annual-engine`:6–43) | Missing: `bi_year` (item 4), RR-scale exposure (item 3), trait (item 1). Beverage/education: skip |
| Annual order | record → all-cause death → education → alcohol category (ordinal logit) → g/day redrawn only if category changed → age+1, drop >79 → add 18-y-olds + migration (rates) | record (L69–77) → death (L82–87) → age+1, drop >65 (L100–102) → reconcile INE stocks (L104–120) → AR(1) latent (L125–126) → exposure at attained age (L127, L130) | Order compatible (exposure at attained age is better than SIMAH). Policy hook: SIMAH applies policy *before recording* (immediate) — same slot here: right after exposure |
| Stochasticity | per-person PRN per event; seed varies by run | Gaussian copula latents + `runif` deaths; one `set.seed` per run (L48) | One RNG stream: any arm-specific draw desynchronises everything downstream → dual-arm design (§2.6) |
| Transitions | ordinal logit on rank-matched pseudo-panel, calibrated by history matching | thresholded latent AR(1) with **one rho = 0.8 for all three latents** (L125–126) | Item 1. Rank matching = Fréchet upper bound on persistence; do not import |
| Former vs abstainer | ordinal model has one non-drinker class; **each year a random subset of non-drinkers is re-labelled former by the observed proportion** | irreversible `ever` (L30–33) → never share drifts to 6 % | Use SIMAH's cross-sectional rule for RR (§3 item 3); keep `ever` only as a history diagnostic |
| Intensity | beta within category, redrawn on category change | zero-mass + Gamma, redrawn yearly from `z_amount` (L20–27), shape pooled over waves (`ms-calibration-functions`:49–54) | OK; Gamma lower tail drives the HED bias (§2.2) |
| Initialisation | IPF to census, sample n rows | INE January stocks by exact age, fresh latents (L54–59) | OK |
| Entries/exits | 18-y-olds by ACS count; in/out migration **rates** estimated in a pre-modelling step | age-15 entrants + residual add/remove to hit INE counts every year (L104–120) | Forcing counts erases survival differences between arms (§2.4) |
| Mortality | Kilian: NVSS all-cause counts by subgroup. Lemp: cause-specific RR functions; reference rates "adjusted to align" with NVSS (not calibrated); 5 causes (AUD, liver, MVA, other unintentional, suicide); cancers excluded for latency | HMD qx × one multiplier per sex (`ms-calibration-functions`:79–85), alcohol-independent (L85) | Item 3: RR hook at L85 (§3) |
| Policy | Kilian: beverage → participation → beverage elasticity → recode category. Lemp: BI to *incremental* recipients only; −2.86 (SE 0.58) g/d scaled by consumption; HED drinkers: RD −0.07 to non-HED, sampled separately; eligibility >20/40 g/d (W/M); resampling each year allowed | none | Item 4 |
| Calibration/validation | Bayesian history matching (implausibility < 3), held-out years | deterministic driver curves (`interp_hold` reproduces margins exactly), rolling origin | Keep; do not add history matching now |
| Uncertainty | Kilian 60 parameter sets × 10 seeds = 600 runs/scenario; Lemp 70 × 20 = 1,400 | 5 seeds, no parameter draws | Monday: seeds only, labelled. Parameter draws later (RR draws already exist in pif2) |
| Outputs | consumption by subgroup; Lemp: YLL to 75 per 100k | `summary`, `deaths` (with **expected** and realised), `flows`, `histories` (12 ids) | Add per-cause expected deaths by arm (§3) |

## 2. Correctness risks and bugs (ranked)

### 2.1 Exported results are stale (verified)
`microsim_recalib_outputs/mortality_concordance.csv` was built with DEIS 2012–2023 still containing infants coded in days/hours:
current bundles give **1,815 fewer deaths 2012–2023** (−49 to −110 per sex-year; 2024 identical). Re-fitting gives multipliers
**F 0.9645 / M 0.9413**, not the exported/narrated 0.970 / 0.945 (`ms-mortality-concordance` table, cell 31 text "−3.1 % → +3.8 %").
HMD-based columns are unchanged. Every number in the recalib narrative that depends on DEIS must be recomputed before it is cited (handoff 2026-10-05 says cells were re-executed; the CSVs were not re-exported).

### 2.2 HED underprediction is a distribution-shape artefact (verified)
Rule: `pop$hed <- positive & pnorm(z_hed) < plogis(a_cell + b*log1p(gpd))` (`ms-annual-engine`:28–29), `positive = current & u > p_zero` ⇒ **HED can never be set for gpd == 0 or NA** (gpd is asserted finite, L40). That part is correct.
Decomposition of the reconstruction bias (56 cells, engine expectation computed by integrating the Gamma; total −4.51 pp vs exported −4.46):

| Component | Mean gap (pp) | Note |
|---|---|---|
| Definition/denominator (target includes current drinkers with gpd NA; glm excludes them) | −0.12 | negligible |
| Pooled-year HED model (no time term) | 0.00 mean; **−4.93 in 2018** | 2018 is the year of the AUDIT coding change flagged in `eps_alcohol_outputs/enpg_availability_audit.csv` |
| Gamma vs empirical gpd within cell | **−4.40** | Gamma puts too much mass near 0 (2024 men 15–29: P10 0.17 vs observed 0.40 g/d; P25 0.79 vs 1.40) where p_hed ≈ 0; observed HED is 0 % at (0,1] g/d, 44 % at (1,2], 74 % at (2,4] |

Root cause: `gpd_survey` is built from the same `db` episodes that define HED (`ms-survey-inputs`:84–86: episodes × 4/5 drinks × 12/30 ≥ 1.6–2 g/d), so HED is a step function of gpd that a smooth Gamma does not reproduce. Fix = calibrate the intercept to the margin (§3 item 2): bias −4.64 → **−0.08 pp**, RMSE 6.65 → **1.73 pp**, prevalence and intensity untouched (verified, 3 seeds).

### 2.3 Same rho for z_amount and z_hed; synthetic history (verified + read)
- One `rho` drives all three latents (L125–126). EPS gives only participation (tetrachoric r 0.546 at 3.7 y, 0.485 at 7.7 y, 50+); nothing identifies amount or HED persistence. Not a bug, an undocumented assumption → expose `rho_z` per latent and run sensitivity; do not transfer the EPS participation λ/φ to amount/HED (handoff 2026-09-21 says the same).
- **Never-drinker drift is structural, not a rho value**: 2024 never share 6.2 % (engine, seed 2125) vs ENPG 25.8 %; former 57.3 % vs 38.3 %. Trait (λ 0.45) + AR(1) (φ 0.65) gives 7.6 % — the margin churn still pushes everyone through the threshold once. "Never stayers" (fixed per-person rank vs ENPG never share, irreversible) gives 15.8 %.
- ENPG never share by wave is 27.5, 18.2, 16.7, 19.4, 16.4, 20.8, **25.8 %**: a +9.4 pp rise in 4 years cannot come from cohort turnover (~2–3 %/yr) under irreversible histories. Self-reported lifetime abstention is a reported status, not a history. ⇒ Use it the way expand_pif and SIMAH do (cross-sectional re-labelling) for RR; never as a hard target for `ever`.
- Impact on RR (verified, simulated 2012→2024 history, liver cirrhosis AAF women 60–65): 0.698 with the drifted history vs 0.63 in expand_pif; with the cross-sectional never share 0.61–0.62.

### 2.4 Stock reconciliation vs an intervention (read; consequence verified by design)
- L104–120 forces each sex × exact-age count to INE every January. If an arm saves lives, the extra survivors are removed at random as "residual outflow" (L111) and the INE count is restored → cumulative survival gains are erased, and the different population size changes `rnorm(transition_n)` (L126) and `sample.int` (L111) consumption → the two arms desynchronise and become unpaired.
- BI recipients are not singled out: removals are random within sex × age (outflow is 4–15 synthetic people/yr), so BI history is lost only proportionally. Fresh additions (`ms_new_people`, L115) get new latents and a fresh `ever` drawn from `p_ever_noncurrent` (L30–33) — **yes, older entrants get a fresh history**, which is acceptable for immigrants but means "history" is not a cohort property.
- Monday fix (no reconciliation change needed): **shared survival** — draw deaths from the control hazard only, carry both arms' expected deaths on the same people. Long-horizon fix (later): record control-arm `delta` per (year, sex, age) and replay it in the intervention arm, removing by a pre-drawn per-person uniform (SIMAH applies migration *rates*, not counts, in scenarios).

### 2.5 Mortality model (read + verified)
- `q` uses January age with qx of that age (L83–85) while DEIS records age at death: level bias, documented.
- One multiplier per sex over 2012–2024 averages a monotone HMD–DEIS drift (recalib §16). Year-specific multiplier = one line (§3 item 3), labelled calibration.
- After 2024 qx and multiplier are frozen at 2024 (L82): no mortality improvement in projections; avoided deaths in absolute terms slightly high late in the horizon.
- Alcohol-independent (L81 comment): correct for an all-cause engine; the RR hook must keep the all-cause level (§3).

### 2.6 Monte Carlo precision (verified)
| Quantity (per year, 15–65) | n_sim 25k (w ≈ 552) | n_sim 100k (w ≈ 138) |
|---|---|---|
| SD of *sampled* deaths, one arm | 4,239–4,416 | 2,120–2,208 |
| SD of a difference of two independent arms | ≈ 6,000 | ≈ 3,000 |
| Avoided deaths, BI 35k/yr, 2 causes (LC + road injuries) | 2.5–7.1 | 2.5–6.2 |
| Avoided deaths, BI 350k/yr | 25–44 | 26–47 |
| Seed SD of avoided (paired, expected deaths) | 0.7–1.2 (35k) / 2.1–4.2 (350k) | 0.3–0.8 / 0.8–1.7 |
| Cumulative avoided 2025–2034, mean (seed SD) | 52.0 (2.8) / 407 (13.5) | 53.5 (1.7) / 417 (6.8) |
| Seed SD of control expected deaths | 6–12 | 1–5 |

With sampled deaths the signal-to-noise ratio is ~10⁻³–10⁻²: ~10⁶ independent run pairs would be needed for SE ≈ 5 deaths/yr.
The engine already computes `expected` (L88–91); the minimum complete answer is **expected deaths per arm on a shared population**
(one run carries both arms). Separate scenario runs stay paired too, because the BI uniform is drawn every year whether or not BI is active
(verified: control expected deaths identical across the three scenarios for the same seed). Pre-drawn per-id uniforms are not needed for Monday.
For context: expand_pif3 gives ~265 avoided deaths/yr for a whole-population −10 % volume shift across 23 causes (tableS3, 2012–2024).

### 2.7 Smaller issues (read)
- `alc_cat` thresholds 20/40/60 g are applied to **survey-scale** g/d (`ms-annual-engine`:35–39) while expand_pif, WHO and SIMAH use risk-scale (APC-anchored, ×4.3–6.0 by wave, `oms_factor_by_year.csv`). Survey-scale cat2/cat3 are near-empty; BI eligibility and RR must use `gpd_survey × factor_CH(year)` (factor is per-capita anchored, 12 g/drink; `expand_pif.ipynb` cell 7:63–103).
- Risk-scale tail: 4.3 % of male and 1.2 % of female current drinkers exceed 150 g/d in 2024. `aaf_unified.R` `.aaf_risk` (l.252–257) **truncates and renormalises** the Gamma to the [0.1,150] grid; SIMAH **caps** (0–200). Matching expand_pif requires the truncation convention (§3 item 3); state it.
- HED-indicator definitions: target among current drinkers drops HED-missing (`na.rm`), SENDA "embriaguez" counts missing as no (+3–6 pp gap, answers §22). The calibration target must be fixed once.
- `histories` traces the first 12 ids (all women aged 15) (`ms-annual-engine`:61): the "ever monotone" check covers 12 people. Replace with a whole-population assertion.
- Former = last drink > 30 days (`ms-survey-inputs`:69–71), RR_FD sources assume ≥ 12 months (answers §1c). Inherited from expand_pif; keep, label.
- Injury indicators use DIAG1 **or** DIAG2 (`ypll_icd_defs.R`:117–121): cause shares can overlap; the hazard split needs mutually exclusive shares (prototype made road injuries exclusive of liver cirrhosis; generalise with a precedence order).

## 3. Insertion points and smallest complete changes (sketches tested in the prototype)

All sketches assume the engine functions are loaded unchanged and add/replace only the named function. Base R + `package::function`.

### Item 1 — trajectories (EPS persistence, ENPG margins)
Insertion: `ms_new_people` (`ms-annual-engine`:6–11), `ms_exposure` L18 and L30–33, AR(1) loop L125–126, `ms_drivers` (`ms-calibration-functions`:91–106).
Smallest change: trait + AR(1) for `z_current` only (λ = 0 recovers today's engine); per-latent carry-over; never share as a cross-sectional
status for RR (Monday) and, optionally, never "stayers" for the history diagnostic. Calibrate λ, φ in closed form from EPS (no simulation needed:
the latent correlation is `λ + (1−λ)φ^k`, directly comparable to the EPS tetrachoric r): answers §16b give λ 0.45–0.48, φ 0.58–0.68.
```r
ms_new_people <- function(sex, age, n, first_id) base::data.frame(id = first_id + base::seq_len(n), sex = sex, age = age,
  z_current = stats::rnorm(n), z_amount = stats::rnorm(n), z_hed = stats::rnorm(n),
  trait_current = stats::rnorm(n),   # stable part of drinking propensity (EPS: lambda ~0.45)
  u_never = stats::runif(n),         # fixed rank used to label reported never-drinkers
  bi_year = NA_integer_, ever = base::rep(NA, n), stringsAsFactors = FALSE)
# in ms_exposure, replace line 18:
zc <- base::sqrt(ms_opt$lambda) * pop$trait_current + base::sqrt(1 - ms_opt$lambda) * pop$z_current
pop$current <- stats::pnorm(zc) < d$p_current
# reported status for RR (SIMAH rule with stable ranks; reproduces the ENPG never share by construction):
pop$never_rr <- !pop$current & pop$u_never < d$p_never / (1 - d$p_current)
# in ms_simulate, lines 125-126 (phi for participation, rho for amount/HED):
rho_z <- base::c(z_current = ms_opt$phi, z_amount = rho, z_hed = rho)
for (z in base::names(rho_z)) pop[[z]] <- rho_z[[z]] * pop[[z]] + base::sqrt(1 - rho_z[[z]]^2) * stats::rnorm(base::nrow(pop))
# solve lambda, phi from the two EPS lags (3.67 y, 7.69 y):
f <- function(p) (p[1] + (1 - p[1]) * p[2]^3.67 - 0.546)^2 + (p[1] + (1 - p[1]) * p[2]^7.69 - 0.485)^2
stats::optim(base::c(0.4, 0.7), f, method = "L-BFGS-B", lower = base::c(0, 0.01), upper = base::c(0.95, 0.99))$par
# -> lambda 0.478, phi 0.575 (run; equals answers §16b)
```
Tested vs untested: trait, `rho_z` and the λ/φ fit were run. The one-line `never_rr` rule was **not** run as written; the tested variant
labels never-drinkers with the same fixed `u_never` against the ENPG never share on a fresh 2024 population (AAF check below). Guard
`p_never / (1 - p_current)` with `base::pmin(1, ...)`.
`d$p_never`: add to `ms_drivers` a logit-interpolated cell series of the ENPG weighted never share (same `stats::approx(rule = 2)` as `interp_hold`).
Done when: λ/φ grid {0, 0.3, 0.45, 0.6} × {0.6, 0.7, 0.8} reported with annual status change, 2024 never/former, EPS r(3.7 y), r(7.7 y); rho for amount/HED with sensitivity {0.5, 0.8, 0.95}.
Measured (seed 2125): status change 19.8 % (verbatim) → 19.5 % (trait) → 16.7 % (stayers + trait); current-prevalence RMSE stays ≈ 1 pp.

### Item 2 — HED
Insertion: `ms_drivers`, after `hed_intercept`/`hed_slope` (`ms-calibration-functions`:100–101). One offset per driver row so the engine's
expected HED among current drinkers equals the ENPG target (logit-interpolated between waves, held after the last one).
```r
h <- ms_interp_target(ms_targets[ms_targets$year <= model$last_year, ], "hed_mean", years)  # logit approx, rule = 2
tgt <- h$value[base::match(grid$key, h$key)]
grid$hed_intercept <- grid$hed_intercept + base::vapply(base::seq_len(base::nrow(grid)), function(i) {
  sc <- grid$mu_current[i] / ((1 - grid$p_zero[i]) * grid$shape[i])
  e_hed <- function(dl) (1 - grid$p_zero[i]) * stats::integrate(function(x) stats::dgamma(x, grid$shape[i], scale = sc) *
    stats::plogis(grid$hed_intercept[i] + dl + grid$hed_slope[i] * base::log1p(x)), 0, Inf)$value
  stats::uniroot(function(dl) e_hed(dl) - tgt[i], base::c(-5, 5), tol = 1e-8)$root
}, base::numeric(1))
```
Distribution by volume is kept (slope from the glm); persistence stays in `z_hed`. Skip the empirical-quantile replacement of the Gamma unless the HED-by-volume table fails.
Done when: margin bias < 0.5 pp (achieved −0.08), plus a table of simulated vs ENPG HED by sex × age × risk-scale volume tertile, and the HED definition (missing as no vs excluded) fixed in writing.

### Item 3 — mortality and RR
Insertion: `ms_simulate` L85 (hazard line) + one new function; RR records via `load_adam_rr_registry()` (`rr_registry_adam.R`:102), cause shares from DEIS with the ICD lists of `ypll_icd_defs.R`:40–98 (the map is already duplicated from expand_pif and guarded by `test_ypll_death_base.R`; do not create a third copy).
Form (SIMAH/Lemp "reference rates adjusted to align"): person hazard multiplier `rel_i = 1 + Σ_c s_c,cell (RR_ic / mean_cell RR_c − 1)`, `s_c` = DEIS share of cause c in all-cause deaths (sex × age group × year). It averages exactly 1 within each cell, so the existing all-cause calibration is untouched (verified: control expected deaths within 14 of the verbatim engine's 35,500/yr). The intervention arm reuses the **control** normaliser, otherwise its benefit is normalised away.
```r
ms_rr <- function(rec, status, g, hed) {           # g on the RISK scale; never = 1, former = RR_FD
  rr <- base::rep(1, base::length(g)); rr[status == "former"] <- base::exp(rec$lnRRFormer)
  nh <- status == "current" & !hed; h <- status == "current" & hed
  if (base::any(nh)) rr[nh] <- rec$RRCurrent(g[nh], rec$betaCurrent)
  if (base::any(h)) rr[h] <- if (base::is.null(rec$RRCurrent_binge)) rec$RRCurrent(g[h], rec$betaCurrent) else
    rec$RRCurrent_binge(g[h], rec$betaCurrent_binge)
  rr
}
ms_rel_risk <- function(pop, year, link, gpd1 = pop$gpd_survey, hed1 = pop$hed) {
  f <- link$factor[[base::as.character(year)]]; cell <- base::paste(pop$sex, pop$age_group)
  y <- base::min(year, 2024L); rel0 <- rel1 <- base::rep(1, base::nrow(pop))
  for (cz in base::names(link$records)) {
    rr0 <- rr1 <- base::rep(1, base::nrow(pop))
    for (sx in base::c("female", "male")) { i <- pop$sex == sx; rec <- link$records[[cz]][[sx]]
      rr0[i] <- ms_rr(rec, pop$rr_status[i], pop$gpd_survey[i] * f, pop$hed[i])
      rr1[i] <- ms_rr(rec, pop$rr_status[i], gpd1[i] * f, hed1[i]) }
    rrbar <- stats::ave(rr0, cell)                                   # control-arm normaliser, reused for arm 1
    s <- link$share[[cz]][base::match(base::paste(y, cell), link$share$key)]
    rel0 <- rel0 + s * (rr0 / rrbar - 1); rel1 <- rel1 + s * (rr1 / rrbar - 1)
  }
  base::stopifnot(base::max(base::abs(stats::ave(rel0, cell) - 1)) < 1e-10)
  base::list(rel0 = rel0, rel1 = rel1)
}
# ms_simulate, replacing line 85-87:
log_s <- base::log1p(-mortality$qx[k]) * model$mortality_scale[pop$sex]
rr <- ms_rel_risk(pop, year, link, pop$gpd1, pop$hed1)
q0 <- -base::expm1(log_s * rr$rel0); q1 <- -base::expm1(log_s * rr$rel1)
dead <- stats::runif(start_n) < q0                                 # shared survival: control hazard decides who dies
```
`pop$rr_status` = "never" if `never_rr`, else "former"/"current" (item 1); the prototype used `alc_status` and `pmin(150, g)`. Tail convention: every simulated person needs a hazard, so the engine must cap (SIMAH caps at 200; prototype capped at 150). expand_pif instead truncates and renormalises its Gamma to [0.1, 150], i.e. drops the heaviest drinkers. Use truncation only inside the compatibility check, and report that the engine's attributable burden for men is higher by design (heaviest 4 % of male drinkers kept).
Verified compatibility (2024 cells, 200k fresh people, ENPG never share): AAF max |diff| **0.02** and PIF(volume −10 %) mean relative diff **5.9 %** vs `pif2_pif_results_full_20261008.rds` with truncation; with a cap at 150 the AAF is up to 0.09 higher for men and the PIF 10 % lower. Road injuries (HED-split RR) match within ~0.001 either way. Remaining gap: liver cirrhosis women 60–65 PIF 0.025 vs 0.034 (pooled-wave Gamma shape vs per-wave `fitdistrplus` shapes in `aaf_engine_inputs_bundle_20261007.rds`).
Drift fix (one line in `ms_fit`, `ms-calibration-functions`:79–85): solve the multiplier per `sex × year` (`vapply` over `split(death_train, ~ sex + year)`), hold 2024 after. Calibration, not validation.
Done when: baseline total and by-cause expected deaths reproduce DEIS 2012–2024 by sex × age group (by construction, report residuals), and microsim AAF/PIF(−10 %) by cause × cell within a stated tolerance of expand_pif.

### Item 4 — brief intervention
Insertion: once per year, **after** `bind_rows(pop, new)` (`ms-annual-engine` after L130) and after the initial exposure (L59). Calling it separately for survivors and new entrants double-delivers (bug found in the first prototype run: 69k delivered for a 35k target).
Defaults (each a labelled assumption): eligibility risk-scale > 20 g/d (W) / > 40 g/d (M) (Lemp 2026); incremental recipients only; proportional −12.3 % with linear return to baseline over 7 years (Angus 2014 / Sheffield) as main, Kaner/Lemp −2.86 g/d **on the risk scale** (= −2.86/factor on survey scale) as sensitivity, plus a null-effect scenario; no re-treatment within 7 years; HED responds only through the calibrated volume link (Lemp's separate RD −0.07 as sensitivity). Applied after continuous exposure and before category recoding (AGENTS §3 sequence; no participation response for BI).
```r
ms_bi <- function(pop, year, drivers, bi, unit_weight) {
  u <- stats::runif(base::nrow(pop))                      # always drawn: keeps scenario runs on the same RNG stream
  pop$gpd1 <- pop$gpd_survey; pop$hed1 <- pop$hed
  if (base::is.null(bi)) return(pop)
  f <- link$factor[[base::as.character(year)]]
  eligible <- pop$current & pop$gpd_survey * f > base::ifelse(pop$sex == "female", 20, 40)
  open <- eligible & (base::is.na(pop$bi_year) | year - pop$bi_year >= bi$repeat_after)
  p <- if (year >= bi$start) base::min(1, bi$n_target / (base::sum(open) * unit_weight)) else 0
  new <- open & u < p
  pop$bi_year[new] <- year
  tau <- year - pop$bi_year
  pop$gpd1 <- pop$gpd_survey * base::ifelse(base::is.na(tau), 1, 1 - bi$effect * base::pmax(0, 1 - tau / bi$duration))
  k <- base::match(base::paste(year, pop$sex, pop$age_group, sep = ":"), drivers$key)
  pop$hed1 <- pop$hed & stats::pnorm(pop$z_hed) < stats::plogis(drivers$hed_intercept[k] + drivers$hed_slope[k] * base::log1p(pop$gpd1))
  pop
}
bi_main <- base::list(start = 2025L, n_target = 35000, effect = 0.123, duration = 7, repeat_after = 7)
```
The `open` denominator is a fix made after the run (the run used all eligible as denominator and delivered 32.6–37.0k for a 35k target and only 234–354k for 350k, because the 7-year no-repeat window saturates ~1.6M eligible); not re-run.
Measured (liver cirrhosis + road injuries only, 2025–2034): 35k BI/yr → 52–53 deaths avoided cumulatively (2.5–7/yr); 350k BI/yr → 407–417. Null scenario = 0 exactly. Mean survey-scale g/d among drinkers in 2025 moves 5.33 → 5.32 (35k) and 5.33 → 5.22 (350k). Effects at full 23-cause scope will be larger; cancers need a latency decision (Lemp excludes them).
Done when: arm table (§ Monday) + null/decay/effect-scale sensitivities.

### Item 5 — ageing beyond 65 (later)
Insertion: `ms_cfg$max_age` (`ms-setup`:10); age filters `15:65` in `ms-demography-inputs`:29, 47, 59, 69–70; hard-coded `51L` counts at :39, :52, :79, :83 → `base::length(15:ms_cfg$max_age)`; `ms_age_group` already maps ≥ 60 to group 4, so the closed-tail option (60–65 drivers carried to 66–80) needs no new driver code. EPS ratio bridge (answers §18) only if ACC wants an age gradient; DEIS bundle is 15+ already; `aaf_age_band_mapping("15_plus")` exists.
Done when: no person disappears at 66 except by death or the new cap; deaths 66+ concord with DEIS by sex.

### Monday deliverable (minimum, all pieces exist in the prototype)
1. Reconstruction model `ms_fit(2024, "interp_hold")` + HED offset (item 2) + `never_rr` (item 1, Monday part).
2. Dual-arm `ms_simulate` 2024–2034 (shared survival, expected deaths per arm) with `ms_rel_risk` for **liver cirrhosis + road + unintentional + intentional injuries** (short latency, all in the registry, Lemp-like set minus AAF=1 causes).
3. Scenarios: none / BI 35k per year / BI ×10; 5 seeds × n_sim 25k (100k for subgroup tables).
4. Output CSV (aggregate only): `year, sex, age_group, cause, scenario, seed, expected_control, expected_bi, avoided, bi_new, bi_active, gpd_control, gpd_bi, hed_control, hed_bi`.
5. Assertions shipped with it: null scenario avoided == 0; `mean_cell(rel0) == 1`; control expected deaths within 0.1 % of the verbatim engine; BI delivered within 5 % of target; microsim AAF/PIF(−10 %) vs pif2 table.
6. Label: "components connected and checked; transitions, HED persistence, BI effect and its duration are assumptions; epidemiological validation pending".

## 4. Where the code should live (AGENTS §4)
- New `__andres_control/microsim_engine.R`: the four engine cells as functions (verbatim) + the hooks above (`ms_interp_target`, HED offset in `ms_drivers`, `ms_new_people`/`ms_exposure` changes, `ms_rr`, `ms_rel_risk`, `ms_bi`, dual-arm `ms_simulate`). Same folder already has the `.Rprofile` renv stub; no new folder, no CI change. Data access stays through `_tools/acc_data.R`.
- New `__andres_control/microsim_bi_demo.R` (or a new notebook if the user prefers; creating one is not editing, but ask) that sources the engine, runs the Monday scenarios and writes `__andres_control/microsim_integration_outputs/*.csv`.
- New `__andres_control/test_microsim_engine.R` with the §Monday assertions (fast: 2 years, 5k people) — matches the existing `test_*.R` pattern.
- Existing notebooks stay untouched and become frozen records. With explicit permission later, `microsim_recalib` cells can `source()` the engine file to end the copy-paste duplication.
- Do NOT build now: data.table/MicSim engine, education/SES, beverage shares, prices/elasticities, costs, parallelisation or speed work, Bayesian history matching, parameter-draw uncertainty (beyond seeds), lagged chronic risk (Holmes lags), AAF=1 causes in the PIF, open 66+ cohort, diverging-survival arms with replayed residual flows (needed only for YLL beyond the first decade), empirical-quantile intensity, per-wave Gamma shape (only if the cause-level PIF gap matters to ACC).

## 5. Delete or stop maintaining
- `microsim_base_ACC_2012_2024.ipynb` + `microsim_base_outputs/`: engine identical to recalib; base-only cells (`ms-apc-audit`, `ms-historical-validation` with the linear-trend spec, `ms-comparison-figures`, `ms-full-refit-projection`) are superseded by recalib `ms-holdout-2020-by-spec` and `ms-projection-rules`. Freeze, mark superseded, do not re-run.
- Recalib model-selection machinery (`static2012`, `linear_all`, `spline_shared`, rolling origin, holdout-by-spec, no-leakage perturbation over 4 specs × 4 cutoffs): keep as the documented evidence, but the integration engine needs only `interp_hold` (reconstruction) and hold-last (projection). Do not port the other specs or the 16-fit leakage test into the engine file; keep one `interp_hold` leakage check in the test file.
- `ms_curve` linear/spline branches and the 12-id `histories` trace: replace the trace with whole-population assertions.
- `jrt/simulacion/MWE.R`: toy MicSim example (N = 25, invented fertility/marriage/education rates, Gompertz death by drinking state, `rm(list = ls())`, `source("Simulacion/patch_micSim.R")` with a dead path). Nothing reusable.
- `jrt/simulacion/Alcohol Transitions FINAL.R` / `_CALIB.R`: rank-matched pseudo-panel (assumes maximal persistence), `polr` on t→t+2, `scale_probs()` raising each probability to α = 0.5 and renormalising (biased annualisation; base notebook `ms-02` shows 0.90/0.10 → 0.75/0.25), `age_transition_step()` moves a person one age category per year. The only idea worth keeping (threshold/cut-point calibration) is already how the engine works. `patch_micSim.R` only serves MicSim. Keep the folder as JRT provenance; stop maintaining; do not source.
- Re-export `microsim_recalib_outputs/` once (stale DEIS, §2.1) or label the folder as superseded; do not edit numbers by hand.

## Summary (15 lines)
1. The recalib and base notebooks share a verbatim engine; only the time-curve spec differs. Base is superseded; freeze it.
2. Exported recalib CSVs are stale: current DEIS has 1,815 fewer deaths 2012–2023 and the multipliers are now F 0.9645 / M 0.9413 (not 0.970/0.945). Re-run before citing.
3. HED bias (−4.5 pp) is a Gamma-tail artefact (−4.4 pp), not the indicator (−0.1) or dynamics (0 on average; −4.9 in 2018). HED can never be set for gpd = 0/NA.
4. A per-cell-year intercept offset (uniroot on the Gamma expectation, inside `ms_drivers`) brings HED bias to −0.08 pp, RMSE 6.6 → 1.7 pp, with prevalence untouched (verified).
5. Never-drinker drift (6 % vs ENPG 26 %) is structural; trait+AR(1) alone gives 8 %. The ENPG never series rises 9 pp in 4 years, so treat "never" as a reported status for RR (SIMAH rule), not as history.
6. Calibrate λ/φ for `z_current` in closed form from EPS (λ + (1−λ)φ^k); keep rho for amount/HED as a stated assumption with sensitivity.
7. Kilian 2025 SIMAH mortality is all-cause only; the BI + cause-specific RR template is Lemp 2026 (same engine). The base notebook's reference row conflates them.
8. RR hook: hazard × (1 + Σ s_c (RR_i/mean RR − 1)), control normaliser reused in the BI arm; it keeps the DEIS-calibrated level exactly in the control arm (verified).
9. Applying expand_pif's [0.1,150] g/d truncation, microsim AAF matches within 0.02 and PIF(−10 %) within ~6 %; the engine must cap instead (every person needs a hazard), which raises male AAF by up to 0.09: state it.
10. Sampled-death MC SD is ~4,200/yr at 25k (2,100 at 100k) vs tens of avoided deaths: realized-death contrasts are useless.
11. One run carrying both arms (shared survival, expected deaths) gives exact pairing; the null scenario returns 0 exactly; seed SD of cumulative avoided is 3–6 % of the effect at 25k.
12. INE reconciliation would erase survivors in a diverging-survival design; shared survival avoids it for Monday; replaying control residual flows is the later fix.
13. BI must be applied once per year after reconciliation; risk-scale eligibility (>20/40 g/d), −12.3 % with 7-year decay, no re-treatment; 35k BI/yr ≈ 52 deaths avoided 2025–2034 for LC + road injuries only.
14. Put the engine and hooks in one `__andres_control/microsim_engine.R`, a demo script and an assertion test; leave notebooks untouched.
15. Skip: data.table/MicSim, JRT transition scripts, SES, beverages, prices, costs, speed work, history matching, lagged risks, AAF=1, open 66+ cohort.
