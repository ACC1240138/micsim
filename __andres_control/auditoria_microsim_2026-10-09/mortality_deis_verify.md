# Verification of `mortality_deis.md` (baseline mortality, DEIS/INE)

Independent verifier, 2026-10-09. No repository file was edited and no notebook was run.

**How it was checked.** I wrote my own scripts in `audit/verify_mort/` and ran them with `Rscript --vanilla` on system R 4.3.3:

- `v01_extract.R` re-extracts DEIS with its own code. It uses pandas, not pyarrow, to read the parquet. It reads 2024 from `acc_deis()` (the `06102026` file, CSV md5 `636c10f4…`).
- `v02_drift_lexis.R` covers the multipliers, the drift, HMD and the age-at-1-January conversion.
- `v03_ine_vintages.R` compares the INE population vintages.
- `v04_causes.R` covers small cells, the 66+ shares, R99 and road injuries, the pipeline reconciliation and the 66+ extrapolation.
- `v05_hazard_loyo.R` tests the hazard normalisation, the single-age LOYO (leave-one-year-out) test with its noise floor, and the Monte Carlo (MC) numbers.
- `v06_loyo_band.R` repeats the band-level LOYO test.

Only aggregated counts are written, to `verify_mort/agg_v/` and `verify_mort/v0*.csv`. The ICD lists come from `__andres_control/ypll_icd_defs.R`. The AAF=1 lists were re-read from `expand_pif.ipynb`, cell `mort-trends-age-sex-chile11-mortalidad-etiqueta`, lines 50–71.

**Status key:**

- CONFIRMED: recomputed and within rounding.
- CORRECTED: the number or the identity needs a qualifier or a fix.
- REFUTED: wrong as written.
- UNVERIFIABLE: cannot be tested here.

## A. Numeric claims (recomputed)

| # | Claim | Status | My number (denominator) | Note |
|---|---|---|---|---|
| 1 | The engine's expected deaths drift from −1.6% (women) and −3.0% (men) in 2012 to +2.0% and +3.5% in 2024. The slope is +0.26 and +0.53 pp/yr. | CONFIRMED | −1.56%→+1.96% (F); −2.98%→+3.46% (M). Slopes 0.262 and 0.527 pp/yr. | Expected = Σ INE Jan stock × q_engine, ages 15–65, with the multiplier refitted on the current bundle (`v02`). |
| 2 | HMD deaths equal DEIS deaths at 15–65 (within 0.02%). | CONFIRMED | Max \|diff\| 0.014% (2024 M), 26 year × sex cells | `Deaths_lexis.txt`, both triangles. |
| 3 | HMD exposure is below the INE June stock: 2.5%→6.3% (F) and 4.1%→9.5% (M). | CONFIRMED, with a precision caveat | −2.54%→−6.29% (F); −4.09%→−9.46% (M) | The exposure is implied as D/mx, and HMD prints mx to 5 decimals. Worst-case bounds are ±0.8 pp for women and ±0.3 pp for men. The trend (+3.8 and +5.4 pp) is far larger than this, so the conclusion stands. |
| 4 | The saved concordance totals have 805 (F) and 1,010 (M) extra deaths, 1,815 in all. Base and recalib outputs are identical. 2024 agrees. | CONFIRMED | 805 / 1,010. Diff by year falls from 168 (2012) to 116 (2023), and 0 in 2024. `microsim_base_outputs` = `microsim_recalib_outputs` observed deaths. | Both `input_provenance.csv` files list parquet md5 `edb4f608…`, which is the pre-fix file per `_deis/README.md`. |
| 5 | The saved multipliers 0.9700/0.9449 reproduce from the saved totals. With the current bundle they are 0.9645/0.9413. | CONFIRMED | 0.969977 / 0.944949 (saved totals). 0.964468 / 0.941262 (current bundle, default `uniroot` tol). 0.964464 / 0.941254 (tol 1e-12). | |
| 6 | The 9-death gap against the README's 1,824 is "unexplained". | CORRECTED (resolved by deduction) | New bundle 2012–2023, 15–65: 368,030 (equals the README). Saved outputs: 368,030 + 1,815 = 369,845. README old file: 369,854. | The new bundle has only Hombre/Mujer, and the build has no sex filter (`_deis/build_deis_2012_2023.R`). It differs from the old file only by `EDAD_TIPO == 1`. So the 9 must be infant records of indeterminate sex, which the notebook's `Hombre`/`Mujer` filter drops. The old file itself was not inspected. |
| 7 | The cohort-consistent target (DEIS 15–65 − ½D15 + ½D66) is about 3% above DEIS 15–65. The parallelogram q_jan hits it within ±0.2%. The naive form is 0.8–1.6% low. | CONFIRMED | Target − DEIS: +2.94% to +3.56% (F), +2.52% to +3.24% (M). Parallelogram vs target: −0.22% to +0.05%. Naive: −0.85% to −1.65%. | 13 years × 2 sexes. |
| 8 | Single-age m = DEIS/INE June works in 1,326 cells, with at least 13 deaths each. | CONFIRMED | 1,326 cells; minimum 13 | |
| 9 | Only one INE vintage is in the repo, because `ine_proyecciones_2012_2024.xlsx` equals the June stocks of `ine_basedatos.xlsx`. | **REFUTED** (the equality part holds) | `ine_proyecciones_2012_2024.xlsx` = June stocks (max relative diff 0). But `ine_proyecciones.xlsx` (sheets Hombres/Mujeres, even years 2008–2022; Mujeres has no 2017) is a **different vintage**. At 15–65 it differs by −0.4% to +0.3% in 2012–2018, +0.9% (F) / +1.6% (M) in 2020, and +0.3% / +1.2% in 2022. All-age total in 2022: 19,828,563 against 19,581,575. | HMD exposure is still 2.6–9.5% below this vintage, so the drift conclusion is unchanged. That the newer file is lower in 2020–2022 is consistent with a downward-revised (post-census) series. This supports the notebook's "Base CPV 2024" label but does not prove it (`v03`). |
| 10 | Cause cells at 15–65: 798 of 2,652 have fewer than 10 deaths, and 214 are zero. | CONFIRMED | 798 / 2,652; 214 zero | Year × sex × 4 bands × 26 groups, no male breast. |
| 11 | The cause map equals the expand_pif counts in all 1,188 cells (max diff 2.3e-13). AAF=1 matches exactly. No death has more than one flag. | CONFIRMED | 1,188 cells, max \|n − mine\| 2.27e-13, 0 cells off by more than 0.5. AAF=1 max diff 0. Multi-flag deaths 0 (all ages). | My counts were checked against `ypll_pipeline_deaths()`, which uses `Mortality Estimates WHO 2024_20261007.xlsx` and `aaf_nested_by_disease_20261007.rds`. |
| 12 | Share of deaths at ages 66+: all causes 79.5% (F) / 66.2% (M); AAF=1 26.1% / 30.5%; partial causes 78.0% / 58.4%. | CONFIRMED | 79.50 / 66.22; 26.14 / 30.52; 78.03 / 58.38 (deaths aged 15+, 2012–2024) | |
| 13 | The 66+ attributable extrapolation puts 68.0% (F) / 44.5% (M) at 66+; 60.9% / 38.9% without cardiovascular causes and DM. Women's IHD contributes 3,346 of 11,342. | CONFIRMED (the arithmetic only) | 67.97% / 44.48%; 60.85% / 38.87%; IHD (F) 3,346.3 of 11,342.0. Ages 66–79 pooled: 31.3% (F) / 27.5% (M). | 31 of 240,911 deaths at 66+ have no AAF cell and are dropped. This is an assumption-driven upper-side figure, as the report itself says. Do not quote it as an estimate. |
| 14 | DEIS 2024: R99 at 15–65 is 810 against a 2018–2023 mean of 609. Road injuries are 1,224 against 1,395–1,659. | CONFIRMED, with a corrected range | R99: 810 vs 608.5. Road injuries 2024: 1,224. The 2019–2023 range is 1,395–1,659, but the 2012–2023 range is **1,363**–1,659 (2017 = 1,363). R-chapter share at 15–65: 1.8% (2012), 3.25% (2024). | The "provisional / pending medico-legal" reading is an inference. The README says the 2024 rows were identical across the June–October 2026 releases. |
| 15 | The 2024 file has 41 exact duplicate rows (0.03%). After the filters, no death is missing sex or age. | CONFIRMED | 41 / 126,928 = 0.032%. 0 indeterminate-sex records among `EDAD_TIPO == 1` and age 15+. | |
| 16 | Band-level LOYO: S4 (trend without 2020–21) scores 1.65 per cell and S2 (mean of other years) scores 2.57. | CONFIRMED | S4 1.649, S2 2.574 (1,568 cells). Noise floor 1.007 per cell. | S4 is about 64% above pure Poisson noise, so overdispersion remains. |
| 17 | Single-age LOYO: spline 1.03 per cell, "Poisson-noise level"; flat-within-band 2.19. | **CORRECTED** | Spline 1.034, flat 2.185 (20,808 cells). The **noise floor is 0.90 per cell, not 1**. | Many single-age cells are sparse, and sparse cells have an expected deviance below 1. The spline is 15% above noise overall. It is 29–39% above for the three injury groups, 21% for "other", and 2.2× for COVID. The ranking stands; "at noise level" does not. |
| 18 | MC granularity: INE January 2024 stock at 15–65 is 13,796,488. IHD has 2,648 deaths/yr, giving 19.2 deaths and a 22.8% relative SE at 100k agents. | CONFIRMED | 13,796,488; 2,648; 19.2; 22.8% | |

## B. Design identities (tested on synthetic agents with real single-age DEIS rates)

| # | Claim | Status | My number | Note |
|---|---|---|---|---|
| 19 | Under h_ic = h_c(k)·RR_c(x_i)/R̄_c, with R̄_c the **plain mean** RR over baseline agents in (sex, band, year), expected deaths reproduce DEIS "by construction". Also, 1 − 1/R̄ equals the simulated AAF. Check V1 has tolerance 1e-10. | **CORRECTED; do not implement as written** | Male IHD at 45–59 (2019 single-age rates), 4,000 agents. **V1 error is 3.5e-3** when the former-drinker share rises with age. It is **5.4e-5 from sampling alone**, with no age gradient. Simulated AAF is 0.0826 against 1 − 1/R̄ = 0.0795. | The identities hold only if h is constant within the band. That is what `05_hazard_formula_selfcheck.R` assumed (`m_cell` is constant per cell), so its V1 and V2 could not detect the problem. **Fix:** use the hazard-weighted mean R̄_c = Σ_i h_c(a_i)·RR_i / Σ_i h_c(a_i) per (s, b, t). With it, V1 error is exactly 0, the AAF equals 1 − 1/R̄_w, and the frozen-denominator PIF becomes 1 − R̄′_w/R̄_w. The same applies to w̄ for AAF=1. |
| 20 | Re-normalising inside the intervention arm cancels the effect exactly. | CONFIRMED (algebra) | | Σh is pinned to DEIS in both arms. |
| 21 | AAF=1 weights (0 for never drinkers, g/day for current, φ·w̄ for former) mean a 10% volume cut gives a 10% lower AAF=1 hazard. | CONFIRMED as algebra; the weight itself is UNVERIFIABLE | | This is a design assumption with no cited source (the report itself says "to be confirmed"). It is not a finding. |

## C. Code-location claims (read)

| Claim | Status | Evidence |
|---|---|---|
| One multiplier per sex via `uniroot` | CONFIRMED | `ms-calibration-functions`, cell lines 78–85 (claimed 80–84) |
| q = 1 − (1 − qx)^s applied per agent at age on 1 January | CONFIRMED | `ms-annual-engine`, lines 82–87 |
| January reconciliation to INE stocks | CONFIRMED, with a nuance | `ms-annual-engine`, lines 103–120. It removes **random** agents of that sex × age (`sample.int`), not specifically the survivors. The intervention's population gain is still cancelled, and the extra `sample.int` draws also desynchronise the two arms' RNG streams, which breaks common random numbers. |
| "Report expected deaths, not realized draws" | CORRECTED (partly already done) | The engine already accumulates expected all-cause deaths (`ms-annual-engine`, lines 88–93), and `ms-mortality-concordance` reports them (line 5). Only the by-cause part is new. |
| Same INE file and sheet as the engine; "Base CPV 2024" label | CONFIRMED | `ms-demography-inputs`, lines 14, 21 and 88 |
| AAF=1 lists copied from expand_pif | CONFIRMED | `expand_pif.ipynb`, cell `mort-trends-age-sex-chile11-mortalidad-etiqueta`, lines 50–71 and 88–98 |
| `CHLdeath.txt` counts 2020 twice | CONFIRMED | 2020 rows appear with RefCode 70 (LDB 0) and RefCode 40 (LDB 1) |
| HMD notes (`CHLcom.pdf`, pp. 5–9): official estimates above the census; migration | CONFIRMED | PDF pp. 5, 8 and 9: "official population estimates … higher … much higher in 2024"; the 2024-census-based INE estimates were "not yet released" as of 6 January 2026; "internal and international migration" |

## D. What must not be used as written

1. **"Only one INE vintage is in the repo"** is wrong. `ine_proyecciones.xlsx` is a second vintage, with differences up to +1.6% at 15–65 in 2020. Any sensitivity analysis on the denominator should use it.
2. **The hazard normalisation with a plain-mean R̄** (report §5.1, and checks V1 and V10) is wrong. Replace it with the hazard-weighted R̄ before coding it into the engine, or V1 will fail and the simulated AAF will be biased.
3. **"Single-age spline at Poisson-noise level"** overstates the fit. The noise floor is 0.90 per cell, and injuries are 29–39% above it.
4. **The 66+ shares (68%/44.5%)** are arithmetic on an assumption, not an estimate. The road-injury comparison range should read 1,363–1,659 (2012–2023).

Not done: no re-run of the engine on real data, and no independent check of the INE vintage label. The old pre-fix parquet was not available, so the 9-death explanation is a deduction.
