# Registro de cierre de expand_pif (2026-10-06)

Registro consolidado a partir de todos los handoffs, guías y `.md` del proyecto, más un mapa estático del código de `expand_pif*` y una verificación contra el código actual (2026-10-06). Lo generaron agentes de Claude Code en `DESKTOP_NDP_SGTV88L`; no se corrió nada con datos reales. Es un **punto de partida para verificar, no un resultado**. Prompt que lo usa: [prompt_fable_cierre_expand_pif_2026-10-06.md](prompt_fable_cierre_expand_pif_2026-10-06.md). Literatura: [encargos_kimi_cierre_expand_pif_2026-10-06.md](encargos_kimi_cierre_expand_pif_2026-10-06.md).

Regla de lectura: donde la sección **Verificación en código** contradice a `status_latest`, prevalece la verificación.

## 1. Situación

expand_pif is technically mature but not closed. Since June the AAF stage runs on a single engine, aaf_unified.R. It uses the WHO 2024/Adam RR registry, signed AAFs capped at 1, the Shield 2025 S6 ICD map, weighted gamma fits, Dirichlet prevalence draws with per-cell Kish/cluster design factors, and former-drinker RR uncertainty. expand_pif2 covers 23 RR causes under 16 scenarios, using total deaths x PIF and the lambda/rho ex-HED knobs. YPLL has three metrics behind an exact death-base gate. The last full series (20260723) passed its validators. Those validators are structural, though, and the critical review of 2026-09-16 warns against calling this epidemiological validation.

Four things block a defensible close.

1. **Exposure inputs.** V1 looks like a real bug in the code as read today: the WHO/APC factor divides by the mean among drinkers, so per-capita g/day, and with it every chronic AAF, may be 2-3x too low. This is also the likely cause of the unexplained 2024 drop in standardized rates. V2 defines former drinkers on a 30-day window while the RR sources use 12 months, and the fd term drives 90-100% of the AAF for flat-RR cancers. V3 excludes missing HED values and has an unverified item per wave. The code map adds B1: item-missing current drinkers are silently dropped, which inflates p_abs and p_form. V1, V3 and B1 all change data_binge_sensitivity, which microsim_base consumes.
2. **Staleness.** The DEIS 2012-2023 infant-age fix (2026-10-05) makes deaths and YPLL stale. AAFs are unaffected. test_ypll_death_base.R fails until expand_pif is re-run. The draws are not in the repo.
3. **Undecided methods.** IHD RR source (WHO/Adam plateau vs Table 5), AAF=1 causes in the PIF, primary YLL metric, the default ex-HED lambda, stomach/pancreatic scope, and the CI conventions.
4. **Governance.** The outcomes of the 16-Sep ACC meeting were never recorded, so D1-D3, the 2016 PSU and the AAF=1 question have no owner sign-off. Cloud access to ACC_DATA_KEY is undefined.

Critical path:
- (0) Record the ACC decisions and the run order, then re-run expand_pif on current data as the baseline-reproduction control.
- (1) Run the V1 check, then the V3 audit with item-missing counts, then the V2 2024 sensitivity. All three go in new scripts, without notebook edits.
- (2) The user/ACC decide the APC bridge, the former-drinker definition and the HED rule, backed by literature (clusters 1-3).
- (3) Apply the fixes as patches, re-run expand_pif, re-pack the bundle, and run the before/after table and the validation battery.
- (4) Run build_ypll and the YPLL gate.
- (5) Run expand_pif2 once (~13 h, a single date stamp, with the one-pass optimisation if approved), then expand_pif3 after fixing B6 and B7.
- (6) Settle the reporting decisions (IHD source, YLL metric, AAF=1 scope, lambda, signed-AAF text) with literature from clusters 4-8.

The cloud is best used for literature synthesis, patch drafting and synthetic tests. Real-data runs stay on DESKTOP_NDP_SGTV88L unless the key is provisioned.

## 2. Índice de issues

| Prio | ID | Categoría | Decide | Verificación en código | Título |
|---|---|---|---|---|---|
| 1 | Q16 | reproducibility_infra | user | — | Re-run order (microsim_base vs expand_pif) and the pending handoff entry |
| 1 | Q17 | reproducibility_infra | user | — | Can a cloud session decrypt data (ACC_DATA_KEY)? |
| 1 | Q24 | scope_decision | user | — | Outcome of the 16-Sep ACC meeting not recorded |
| 1 | V1 | moves_point_estimates | user | confirmed_open | WHO/APC scaling factor uses a drinkers-only denominator (per-capita g/day likely 2-3x too low) |
| 2 | B1 | moves_point_estimates | user | confirmed_open | Item-missing current drinkers silently dropped from p_abs/p_form denominators and gamma fits |
| 2 | B20 | reproducibility_infra | user | — | Stale YPLL cache (YPLL_20260714) used by expand_pif2 c40/c42 without a gate; test_ypll_death_base.R fails until expand_pif is re-run |
| 2 | Q1 | scope_decision | ACC | — | APC bridge choices (a)-(e): APC series and source, 0.8 factor, 15+ vs 15-65 denominator, unrecorded alcohol, 2020 and the frozen 2025+ value |
| 2 | Q2 | scope_decision | ACC | — | AAF=1 (wholly attributable) causes excluded from the PIF grid |
| 2 | Q3 | scope_decision | ACC | — | IHD/IS RR source: WHO/Adam (age-banded, male IHD flat RR=1 at 60-100 g/d) vs Table 5 PUC as primary |
| 2 | Q8 | scope_decision | ACC | — | Primary YLL metric (HMD life-table vs GBD 2019 TMRLT vs legacy e0-age) and life-table authority; WPP sensitivity not implemented |
| 2 | Q18 | reproducibility_infra | user | — | Monte Carlo draws missing from micsim (about 730 MB): regenerate vs copy; one-pass optimisation |
| 2 | V2 | moves_point_estimates | ACC | confirmed_open | Former-drinker definition: no drink in the last 30 days (current) vs >=12 months (RR sources/WHO) |
| 2 | V3 | moves_point_estimates | user | confirmed_open | HED definition: missing db excluded, sex-specific 5+/4+ threshold, item per wave (30-day binge count vs AUDIT-3 6+) |
| 3 | B2 | moves_point_estimates | user | confirmed_open | AAF=1 block counts all calendar years (year filter commented out) while partial causes cover only the 7 ENPG waves |
| 3 | B3 | reproducibility_infra | user | partially_fixed | Silent error swallowing: tryCatch(..., error=function(e) NULL) in the AAF driver and pif2_lookup_record |
| 3 | B5 | intervals_only | user | — | Table 5 (PUC) IHD-female PIF intervals degenerate because the b1-b2 covariance is diagonal |
| 3 | B6 | reproducibility_infra | user | — | expand_pif3 c53 uses pif3_rr_source_colors before c54 defines it |
| 3 | B7 | reproducibility_infra | user | — | expand_pif3 c9 deletes all committed figures before any data gate runs |
| 3 | B9 | reproducibility_infra | user | — | test_aaf_unified.R and test_aaf_compute.R cannot run: ihd_is_binge_aaf.R is missing from micsim |
| 3 | B14 | moves_point_estimates | user | confirmed_open | Unexplained drop in 2024 standardized attributable mortality (27.65 to 21.62 per 100k) |
| 3 | B18 | presentation | user | partially_fixed | Figure/table bugs from the 2026-06-02 list (Fig 3 pooled denominator, burden_m/burden_f swap, chile27b scope, Fig 4/5 clipping negatives) |
| 3 | D1 | scope_decision | ACC | — | Extend AAF/PIF/YPLL to ages 66-76 via an EPS ratio bridge |
| 3 | D2 | scope_decision | ACC | — | Urban ENPG exposure (109 communes, about 70% of population) applied to national DEIS deaths |
| 3 | Q4 | presentation | user | — | Signed AAF/PIF (cap at 1 only) and net vs harmful-only reporting |
| 3 | Q5 | intervals_only | user | confirmed_open | Former-drinker RR uncertainty: fd_uncertainty=TRUE (chronic/CV) and the CI convention vs JRT; stale audit flag |
| 3 | Q6 | moves_point_estimates | user | — | Sick-quitter sensitivity bracket (RR_fd = 1) for flat-RR cancers |
| 3 | Q7 | scope_decision | user | — | Ex-HED exit rule (lambda 0 conservative vs 1 Ruiz-Tagle, rho=1) and reporting of implied consumption |
| 3 | Q10 | scope_decision | ACC | — | Stomach (C16) and pancreatic (C25) cancer: main estimate vs labelled WHO/IARC-scope sensitivity |
| 3 | Q26 | reproducibility_infra | JRT | confirmed_open | ENPG_BINGE.RDS (JRT-derived) raw-to-derived variable map undocumented |
| 3 | Q28 | reproducibility_infra | user | — | Publication gate after re-run (quasi-identifiers, local paths) and repo visibility |
| 4 | B4 | intervals_only | user | — | .aaf_resolve_cell() positional fall-through for neff/design_factor |
| 4 | B10 | reproducibility_infra | user | — | Per-save Sys.Date() stamps can split a 13 h run across two dates; the validator expects one stamp |
| 4 | B12 | intervals_only | user | — | Engine forces lower<=point<=upper, which makes the CI-ordering validators tautological |
| 4 | B13 | presentation | user | — | Aggregate CIs in expand_pif (std rates, burden %) sum cell bounds; pif3 captions describe envelopes while its code uses joint CRN draws |
| 4 | B17 | reproducibility_infra | user | — | Cell 66 sources make_jrt_compatible_cancer_table_ge60.R into GlobalEnv |
| 4 | B21 | reproducibility_infra | user | — | ICD map duplicated between expand_pif.ipynb and ypll_icd_defs.R |
| 4 | C1 | intervals_only | ACC | — | Single per-wave design declaration (strata = comuna 2012-22, ESTRATO 2024, reconstructed 2016 PSU) not implemented |
| 4 | C2 | intervals_only | user | — | ENPG 2020 has no PSU: design factor borrowed from the next wave (2022), which belongs to a different sampling regime |
| 4 | C4 | reproducibility_infra | user | — | Export oms_factor_by_year.csv so the microsim uses the same WHO factor |
| 4 | D3 | scope_decision | ACC | — | ENPG 2020 non-comparability (pandemic fieldwork, CAPI+CATI, no self-administration, no show cards) |
| 4 | Q9 | presentation | user | — | Age-band mapping for IHD/IS (group 4 = 60-65 on the 35-64 RR band) and the WHO world weight for 60-64 |
| 4 | Q12 | scope_decision | user | — | ICD conventions to ratify: X30-X39/W47-W48 envelope vs strict sub-row; X45/X65/Y15 placement; C11 nasopharynx; oral/pharynx labels |
| 4 | Q13 | intervals_only | user | — | Design-factor floor at 1, and neff semantics |
| 4 | Q15 | intervals_only | user | — | Joint uncertainty for aggregates: CRN-synchronised draws vs cell-bound envelopes |
| 4 | Q19 | reproducibility_infra | user | — | Pin the DEIS release (ACC_DEIS_VERSION) for the closing runs |
| 4 | Q20 | presentation | ACC | — | Cross-wave ENPG comparability of 30-day measures (holiday-recall regimes, 2018 redesign, 2022 frame/weights, 2024 OH_1 gate) |
| 4 | Q21 | presentation | user | — | Exposure model choices: graduated QF volume, HED at the threshold, 150 g/d integration cap, weighted MoM gamma |
| 4 | Q22 | presentation | none | — | RR-source quality flags (keep sources; document): IHD male offset, DM2 female spline, IHD female zero covariance, liver beta provenance, HHD endpoint, colorectal FD |
| 5 | B8 | reproducibility_infra | none | — | Phase-7 harness false FAIL (monotone_increasing_rr) in expand_pif2 c44 |
| 5 | B11 | presentation | user | — | cvolaj cut-point gaps and inconsistent women cat3/cat4 definitions |
| 5 | B15 | reproducibility_infra | user | — | Committed RDS artifacts embed another PC's absolute paths in metadata |
| 5 | B16 | reproducibility_infra | user | — | expand_pif setup cell installs packages ad hoc; build_ypll.R and test_ypll_death_base.R setwd() |
| 5 | B19 | presentation | user | — | 12 g vs 15.7 g sensitivity (cvolajms/volajohdiams) is vacuous after APC scaling |
| 5 | B22 | closed_reference | none | confirmed_open | Legacy 3-integral HED code (double-counts binge) still present in confint_paf_parallel.R |
| 5 | B23 | closed_reference | none | — | Closed bugs that explain past numbers (regression references) |
| 5 | C3 | reproducibility_infra | user | — | Add volajohdia_pop (0 for ltabs/fd) plus a warning comment to data_binge_sensitivity |
| 5 | C5 | presentation | user | — | 2014 expanded totals: use RND_F2_MAY_AJUS_com |
| 5 | Q11 | scope_decision | user | — | Cervix cancer C53 listed in Shield S6 but has no usable RR |
| 5 | Q25 | scope_decision | ACC | — | Policy-induced quitters (former drinker vs abstainer) and the missing FD scenario |
| 5 | Q27 | presentation | user | — | Text explaining differences vs JRT/published paper must cite verified causes |
| 5 | V4 | closed_reference | none | — | DEIS 2024 release (09-06 vs 15-09 vs 29-09) |

## 3. Detalle por issue

### Q16. Re-run order (microsim_base vs expand_pif) and the pending handoff entry

- **Módulo / categoría / decide:** infra/reproducibility / reproducibility_infra / user
- **Estado (documentos):** open (2026-10-06: the assistant proposed an order; the user's OK to append the handoff entry is pending)
- **Detalle:** README and the 2026-10-05 handoff put microsim_base before expand_pif. But expand_pif writes data_binge_sensitivity, which microsim_base reads (changed to acc_data on 2026-10-06). Proposed order: expand_pif, then V1-V4, then expand_pif again if anything changed, then notebooks 1-4 and expand_pif2/3. Any V1-V3 change triggers the full 13 h pif2 run. The DEIS fix alone does not change PIFs/draws, but it does require expand_pif, build_ypll and pif3.
- **Evidencia:** README.md L60-67; _enpg/README.md L42; handoff L8162, L8166, L8180; assistant context 2026-10-06

### Q17. Can a cloud session decrypt data (ACC_DATA_KEY)?

- **Módulo / categoría / decide:** infra/reproducibility / reproducibility_infra / user
- **Estado (documentos):** open (2026-10-06)
- **Detalle:** Without the key, cloud work is limited to planning, code review, literature and synthetic unit tests, and must say that it was not run on real data. The key must never be typed into a chat or put on a command line.
- **Evidencia:** AGENTS.md §6-7; README.md L11-17; .github/workflows/data-check.yml

### Q24. Outcome of the 16-Sep ACC meeting not recorded

- **Módulo / categoría / decide:** governance / scope_decision / user
- **Estado (documentos):** open (2026-10-05)
- **Detalle:** ACC approval of D1-D3, the 2016 PSU alignment, the AAF=1 sub-model, the YLL metric, scope 15-65/2012-2024 vs the proposal's 15+/2008-2019, and the 2/8/12-week calendar is not documented. Nothing can be treated as decided by ACC.
- **Evidencia:** retomar_proyecto_semana_2026-09-14_a_20.md L15, L41, L107-119; guion_reunion_ACC_2026-09-16.md L46, L75

### V1. WHO/APC scaling factor uses a drinkers-only denominator (per-capita g/day likely 2-3x too low)

- **Módulo / categoría / decide:** exposure / moves_point_estimates / user
- **Estado (documentos):** open (2026-10-06: the code map confirms the drinker-mean pattern; still pending in the handoff of 2026-10-05)
- **Verificación en código (2026-10-06):** confirmed_open
- **Detalle:** total_volCH = sum(volCH*exp)/sum(exp) after filter(!is.na(volCH)). The saved head(data) shows that ltabs/fd rows have db, volajohdia and volCH set to NA, so the denominator is current drinkers with complete items. That means the drinker mean equals 0.8*APC, and the population per-capita mean equals p_current*0.8*APC. This is case 3 of the V1 decision rule ('wrong': switch to mean_percap, re-run, validate). Caveat: any wave of ENPG_BINGE that codes db=0 rather than NA for non-drinkers would already be per capita. The factor is rounded to 2 decimals and indexed positionally (total_volCH[i,3]). The same drinker-mean pattern appears in revision_diseno_enpg_extension.R, where it affects design factors only. Interacts with V2: the AAF is pushed toward the fd term. Likely cause of the unexplained 2024 drop in standardized rates (B14).
- **Evidencia:** __andres_control/expand_pif.ipynb cell 6 enpg-consolidate ~L53-107 and cell 7 saved output; __andres_control/expand_pif_cambios_hallazgos_2026-09-21.md L3, L21, L26-48; handoff L7925 (2026-09-17), L8090 (2026-09-21); __andres_control/microsim_base_ACC_2012_2024_explicacion.md L54-56
- **Depende de:** Q1 (bridge choices) for the final factor definition
- **Pregunta de literatura:** In standard AAF practice (WHO GISAH/GSRAH, InterMAHP, GBD, Rehm/Kehoe triangulation), is survey consumption scaled so that the POPULATION per-capita mean (abstainers=0) matches a fraction of APC, and what fraction (0.8) and APC series (recorded+unrecorded, tourist-adjusted, 15+) are used?
- **Cómo verificar:** With ACC_DATA_KEY: run the V1 snippet per wave (g_pop=0 for ltabs/fd; ratio mean_percap/mean_drinkers should be about 0.35-0.49). Tabulate db for ltabs/fd per wave (NA vs 0). Compare the weighted per-capita volajohdia*365 against APC*0.8 per year.

<details><summary>Evidencia de la verificación en código</summary>

```text
__andres_control/expand_pif.ipynb, cell 7 (1-based; 0-based 6) '#| label: enpg-consolidate', L53-57 and L71-78 (current HEAD c5fb774; no later commit touches this notebook):
  total_volCH <- data %>% group_by(year) %>% filter(!is.na(volCH)) %>%
    summarise(pop = sum(exp), pc_totalvolCH = sum(volCH*exp)/pop)
  vol_oms = x*0.8; oms=round((vol_oms*0.789)*1000,2); pull(round(oms/vol,2))
  mutate(volaj = case_when(year == 2012 ~ volCH*conversion(8,total_volCH[1,3]), ...
Saved aggregate output, __andres_control/microsim_base_ACC_2012_2024.ipynb cell 10 (0-based 9) 'ms-apc-audit' (reads this same cache): noncurrent_missing_volume == noncurrent_rows in all 7 waves (e.g. 2012 9347/9347, 2024 12564/12564); corrected_mean_among_finite (exp-weighted drinker mean, g/day) = 13.857, 14.155, 12.249, 11.778, 13.677, 13.688, 13.676 vs 0.8*APC*789/365 = 13.83, 14.18, 12.28, 11.76, 13.66 x3. Drinker mean equals 0.8*APC in every wave.
Gamma fits consume it directly: expand_pif.ipynb cell 22 L61/L75 'filter(volajohdia > 0, ...)'. Handoff 2026-10-05 L8166: 'V1-V3 siguen pendientes'.
```

Status: the bug is open (checked 2026-10-06). It is not fixed in code, and no handoff entry or note says it was. The last handoff entry, dated 2026-10-05, still lists V1-V3 as pending.

Proof without decrypting:
(1) Code: the denominator of the scaling factor is restricted to rows with non-NA volCH. volCH is NA whenever db is NA.
(2) A saved aggregate output in microsim_base (ms-apc-audit) shows two things.
- All lifetime abstainers and former drinkers (ltabs/fd) have NA volume in all 7 waves (2012-2024). This refutes the caveat that some wave codes db=0 for non-drinkers.
- In every wave, the exp-weighted mean among drinkers equals 0.8*APC in g/day, within the rounding of the factor. So V1 is case 3 of the decision rule: it is wrong.

Consequence: per-capita consumption = p_current*0.8*APC. The Gamma fits for current drinkers (cells 22-23, volajohdia>0) are therefore about 1/p_current times too low. This flows into the AAF (expand_pif), the PIF (expand_pif2) and the tables (expand_pif3). The grams-per-drink choice (12 g vs 15.7 g) cancels out, so volajohdia and volajohdiams differ only by rounding.

Other defects in the same cell:
- The factor is rounded to 2 decimals.
- Rows are picked by position (total_volCH[i,3]). This is correct today only because all 7 waves are present and sorted; a join by year would be safer.
- The APC input is the same 7.9 L for 2020, 2022 and 2024. That looks frozen; check it against WHO GISAH (part of Q1).
- The denominator is computed before the aux filter removes inconsistent oh1=='No' & oh2!=NA rows. The effect is negligible, given the audit match.

revision_diseno_enpg_extension.R L209-220 has the same drinker-mean denominator. It also uses conversion(7.9) for every year. It affects design factors only; decide whether to align it.

The docs contradict each other. microsim_respuestas_preguntas_2026-09-20.md §7 (L92) says that NA volume 'no cambia ningun AAF' because the AAF uses categories. That is false for the continuous Gamma fits. Do not cite it as reassurance; its §24 and L611 correctly flag V1 as pending.

Still needed at run time (with ACC_DATA_KEY):
(a) Per wave, compute weighted p_current and the per-capita mean (ltabs/fd=0) over exp, 15-65.
(b) Decide how to handle current drinkers with missing db/audit2 (excluded today from both numerator and denominator). Options: per-capita = p_current(all drinkers) x mean among complete drinkers, or impute.
(c) Change the denominator to the per-capita mean, i.e. drinker mean = 0.8*APC/p_current. Join by year, do not round the factor, export oms_factor_by_year.csv (C4).
(d) Re-run expand_pif, re-pack data_binge_sensitivity, then microsim_base, then expand_pif2 (~13 h), then expand_pif3.
(e) Validate per §7 of expand_pif_cambios_hallazgos_2026-09-21.md and build a before/after AAF table by cause x sex.

The final factor definition depends on Q1:
- the APC series (recorded+unrecorded, tourist-adjusted, 15+);
- the 0.8 fraction;
- the 15+ to 15-65 domain bridge.

</details>

### B1. Item-missing current drinkers silently dropped from p_abs/p_form denominators and gamma fits

- **Módulo / categoría / decide:** exposure / moves_point_estimates / user
- **Estado (documentos):** open (identified by the code map 2026-10-06; not in the V list)
- **Verificación en código (2026-10-06):** confirmed_open
- **Detalle:** filter(oh3<=30) drops whole rows with unknown drinking days. db NA or audit2 NA makes volCH, cvolaj and hed NA, and build_prop_list_weighted then filters !is.na(cvolaj). Abstainers and former drinkers are never item-missing because oh3 is forced to 0, so p_abs and p_form are inflated and the current-drinker mass is understated. In 2024, 349 of 5,533 current users (6.3%) have unknown HED, giving about a 3-4% relative understatement of current drinkers. The aux filter also drops oh1=='No' rows that have a non-NA oh2. No drop counts are reported. The same exclusion feeds the V1 denominator.
- **Evidencia:** expand_pif.ipynb cell 6 ~L10-14, L45, L132-133; cell 21 build_prop_list_weighted ~L162; _enpg/notes/enpg_findings.md L9, L15
- **Depende de:** V3 (missing-HED rule)
- **Pregunta de literatura:** For AAF inputs, should drinking-status prevalence be classified from the recency item regardless of missing volume/HED items, and how should item-missing consumption among current drinkers be handled (MAR imputation vs complete case)?
- **Cómo verificar:** Count rows lost per year to each filter, and NA cvolaj among oh2=='30 dias'. Recompute p_current by classifying drinkers from oh2 instead of volume.

<details><summary>Evidencia de la verificación en código</summary>

```text
__andres_control/expand_pif.ipynb, cell 6 `enpg-consolidate`. The file has not changed since the initial import, commit c5fb774 on 2026-10-05.
  L10  db = ifelse(db >= 88, NA, db),
  L24-30  prom_tragos = case_when(oh1=="No"|oh2==">30"|oh2==">1 año" ~ 0, audit2=="0-2" ~ 1, ... ) [no TRUE~, so NA audit2 gives NA]
  L45  dplyr::filter(oh3 <= 30)
  L115  TRUE ~ NA),   [cvolaj: NA volajohdia gives NA; also no category for volajohdia==0 or for the 19.99-20 / 39.99-40 / 59.99-60 gaps]
  L132-133  aux = ifelse(oh1 == "No" & !is.na(oh2) ,1,0)) %>% filter(aux == 0)
Cell 21 `...step0-pre`, L162 (build_prop_list_weighted): dplyr::filter(!is.na(cvolaj), !is.na(exp), sexo == sexo_value, ...)
aaf_unified.R L253: cur <- 1 - (p_abs + p_form)
Saved aggregate output of microsim_base_ACC_2012_2024.ipynb, cell 9 `ms-apc-audit`, read from data_binge_sensitivity:
  2024: rows 17944 | volume_observed 5120 | noncurrent_rows 12564 | noncurrent_missing_volume 12564
  This leaves 260 retained rows that are not ltabs/fd and have NA volume. The same count is 244/764/449/416/357/231 for 2012-2022.
```

STATUS: still open in the code (static reading of the repo on 2026-10-06). Nothing fixes it.
- No dated handoff entry mentions B1. The latest entries are 2026-09-22 and 2026-10-05.
- The V3 assignment in expand_pif_cambios_hallazgos_2026-09-21.md covers only the HED part, through the rule "missing db counts as no HED". V3 is still pending as of 2026-10-05.
- The 2026-06-09 handoff entry (around L4596) flagged "prom_tragos sin TRUE~ (NA cascada ~0.1-0.3%)" but never fixed it.
- No drop counts are reported anywhere.

MECHANISM, as confirmed in the code:
- Abstainers and both former-drinker codes get oh3=0 and a cvolaj label, so they are never dropped.
- A current drinker drops out in any of these cases:
  - oh3 is 88/99, NA or >30: the whole row is removed.
  - db is NA or audit2 is NA: volume becomes NA, cvolaj becomes NA, and the row is excluded from the p_abs/p_form denominators and from the gamma fits.
- p_cur is the residual 1-p_abs-p_form, so it is understated.
- The bias reaches expand_pif2 through aaf_engine_inputs_bundle_20260723.rds (the PIF scenarios) and microsim_base through data_binge_sensitivity.

QUANTITATIVE HINT from saved aggregate output (unweighted, run date unknown):
- Share of retained non-ltabs/fd rows with NA volume, by year:
  - 2012: 3.6%
  - 2014: 8.7%
  - 2016: 6.2%
  - 2018: 5.8%
  - 2020: 5.7%
  - 2022: 4.0%
  - 2024: 4.8% (260/5380)
- In 2024 this means about a 3.4% relative understatement of p_cur (0.2998 vs 0.2895), before counting rows already removed by the oh3 filter.
- The 260 is an upper bound for item-missing current drinkers, because it may include rows with oh1="Si" and oh2 NA (unknown status).
- The "349 of 5,533" figure in enpg_findings.md L15 is raw ENPG 2024 at ages 12-65, not the 15-65 pipeline domain.

SIDE FINDINGS:
1. noncurrent_missing_volume equals noncurrent_rows, so all abstainers and former drinkers have NA volume (db is a skip). The total_volCH denominator (cell 6, L53-57, filter(!is.na(volCH))) is therefore the mean among current drinkers with complete items. This supports the V1 hypothesis ("mean among drinkers") and shows the B1 exclusion also enters that denominator. corrected_mean_among_finite is about 13.66 in 2024, which equals 7.9*0.8*789/365.
2. Current drinkers with oh3=0 (a label noted as 0="no contesta") and db=0 get volajohdia=0, so cvolaj is NA. They count as "observed" but are still excluded.
3. JRT's reference script (jrt/cancer_20260702/AAF CALCULATION CANCER-ACC_V2.R L9-15) uses the same aux filter and filter(!is.na(cvolaj)). Fixing B1 departs from JRT replication, so the user must decide.
4. revision_diseno_enpg_extension.R L184-186 already classifies current_drinker from oh2=="30 dias". That logic is reusable, but only the design factors use it.

RUN-TIME CHECKS (real data, locally):
(a) For each year x sex x tramo, count rows lost to each step: edad>=15, filter(oh3<=30) (split by oh2 = "30 dias" / NA / other and by oh1 NA), and aux==0 (both oh1=="No" with oh2 present and aux NA).
(b) Among retained oh2=="30 dias" rows, count NA cvolaj by reason: audit2 NA, db NA, oh3 0/NA, volume==0, and the category gaps.
(c) Compute weighted p_abs, p_form and p_cur with status taken from oh1/oh2 (denominator = everyone with known status) and compare with the current residual p_cur by cell.
(d) Rerun the AAF engine for 2024 under two assumptions: item-missing current drinkers are MAR within cell (keep the gamma, raise p_cur), versus complete case. Report the change in AAF and attributable deaths.
(e) Coordinate with V3. Setting db NA to 0 fixes hed but not volume when audit2 is NA. Decide whether the change applies to expand_pif only or also to expand_pif2, then regenerate the bundle and data_binge_sensitivity.

</details>

### B20. Stale YPLL cache (YPLL_20260714) used by expand_pif2 c40/c42 without a gate; test_ypll_death_base.R fails until expand_pif is re-run

- **Módulo / categoría / decide:** YPLL / reproducibility_infra / user
- **Estado (documentos):** open (2026-10-05: 15 cells fail, 117,918 vs 117,944; expected)
- **Detalle:** The cache was built before the edad_tipo fixes (117,949 deaths). pif3 c11 rebuilds YPLL in memory and supersedes it, but will stop at the gate under current DEIS. The gate constants 1188/117944/1260/72 are hard-coded and must be re-derived after the re-run. Do not run build_ypll.R before expand_pif is re-run.
- **Evidencia:** handoff L8196, L8205 (2026-10-05); test_ypll_death_base.R L141-143; build_ypll.R L76; expand_pif3 c11; expand_pif2 c40/c42

### Q1. APC bridge choices (a)-(e): APC series and source, 0.8 factor, 15+ vs 15-65 denominator, unrecorded alcohol, 2020 and the frozen 2025+ value

- **Módulo / categoría / decide:** exposure / scope_decision / ACC
- **Estado (documentos):** open (2026-09-21; still undecided in the code read on 2026-10-06)
- **Detalle:** APC values are hard-coded: 2012=8.0, 2014=8.2, 2016=7.1, 2018=6.8, and 2020=2022=2024=7.9 (the last value carried forward; there is no source). 0.8 = Rehm unconsumed/recorded fraction 'according to ACC'; 0.789 = ethanol density. Older prep values differ (7.8/.../7.5), and WHO totals (2010=9.3, 2016=9.3, 2020=7.56) are higher. Unrecorded alcohol for Chile: WHO 1.4 L vs an IJDP 2025 Delphi estimate of 0.05-0.5 L (not re-verified). APC is for ages 15+, but the survey frame is 15-65 and urban. The per-year legacy factors in ENPG prep show a 2018 break (2.52 vs ~5). Rule: the factor applies only inside RR/AAF/PIF (g_riesgo = g*factor(year)), never in calibration. C4 exports it for the microsim.
- **Evidencia:** expand_pif.ipynb cell 6 ~L60-93; __andres_control/microsim_respuestas_preguntas_2026-09-20.md §11 L174-179, §24 L600-611; plan_trabajo_post_reunion_ACC_2026-09-17.md §5 L152; handoff L4569-4683 (2026-06-10), L8085 (2026-09-21); notes/handoffs_historicos/elasticidad_epf_handoff.md L339-405, L385-388; notes/handoffs_historicos/pseudopanel_deaton_handoff.md L351, L646
- **Depende de:** V1
- **Pregunta de literatura:** Which APC series (WHO GISAH total vs recorded; World Bank SH.ALC.PCAP.LI) and coverage convention should calibrate a 15-65 urban survey to national exposure; what survey coverage rates are typical (Kilian 2020: 36.5%; Buckley 2022), and how is unrecorded alcohol in Chile estimated?

### Q2. AAF=1 (wholly attributable) causes excluded from the PIF grid

- **Módulo / categoría / decide:** PIF / scope_decision / ACC
- **Estado (documentos):** open (pending since 2026-07-10/11; listed for ACC authorisation 2026-09-16/17)
- **Detalle:** F10, G312, G621, G721, Q860, I426, K860, K292, X45, X65, Y15: 97 rows, 2,628 deaths over the waves, 145 in 2024. They are in the PAF totals but not in the PIF, so every avoided-death and YPLL total covers only the 23 RR causes. The critical review warns that AAF=1 does not imply PIF=1 and that omitting them is not a proven lower bound: write 'partial for included causes' or build a sub-model (e.g., scale by the counterfactual change in aggregate volume). Microsim target 7 counts '23 causes + AAF=1'.
- **Evidencia:** handoff L6600-6620, L6658-6660 (2026-07-10/11); guion_reunion_ACC_2026-09-16_revision_critica.md L33, L238, L258; plan_trabajo_post_reunion_ACC_2026-09-17.md §6 L170; expand_pif2.ipynb c32 L87-88, c35
- **Pregunta de literatura:** How do InterMAHP, GBD and SAPM-type models compute counterfactual (PIF) changes for 100%-attributable conditions, and on which exposure metric (per-capita volume, HED prevalence, AUD prevalence)?

### Q3. IHD/IS RR source: WHO/Adam (age-banded, male IHD flat RR=1 at 60-100 g/d) vs Table 5 PUC as primary

- **Módulo / categoría / decide:** PIF / scope_decision / ACC
- **Estado (documentos):** open (2026-07-20; the main run uses WHO/Adam and Table 5 is a sensitivity analysis; no decider named)
- **Detalle:** The WHO/Adam male IHD curve (GENERAL_ihd_RR_2018_03_16.R) has a hard-coded plateau at 60-100 g/d, which makes volume PIFs about 0 or negative. 73 cells disagree in sign (59 male IHD). IHD male 2024 volume-10 avoided deaths: 0.42 (WHO) vs 20.1 (Table 5). IS agrees (ratio 1.02-1.04). Both curves agree below about 40 g/d. Related: InterMAHP-2018 CV vintage vs WHO-2024 chronic (do not mix silently); the PUC 'Fact' column must never be applied; RR_HED = pmax(RR_NHED,1) is the binge cap. The AGENTS rule is to not replace RRs without a request, so this choice must be explicit.
- **Evidencia:** handoff L7709-7747 (2026-07-20), L3387-3402 (2026-05-29), L3662-3701; expand_pif3 c51-c54; expand_pif.ipynb cells 101-102
- **Pregunta de literatura:** What is the current evidence for IHD/IS dose-response and cardioprotection (Roerecke & Rehm 2012; Zhao/Stockwell 2017; Biddinger 2022 MR), what functional forms do WHO 2024/GSRAHTSUD and InterMAHP use, and what is the provenance of the piecewise plateau in the 2018 IHD male function?

### Q8. Primary YLL metric (HMD life-table vs GBD 2019 TMRLT vs legacy e0-age) and life-table authority; WPP sensitivity not implemented

- **Módulo / categoría / decide:** YPLL / scope_decision / ACC
- **Estado (documentos):** open (2026-07-14 proposal: yll_hmd primary; ACC to agree, 2026-09-16)
- **Detalle:** Totals for 2012-2024: hmd 6.99M, gbd 8.78M (+26%), ref 6.44M (-8% overall, -19.5% in band 4). The authorities differ by up to about 1 year in level and in COVID-dip depth. Do not splice authorities. pif2 c41 claims a WPP sensitivity analysis, but chile_e0_wpp2024 is never used. Lemp 2026 uses YLL to age 75.
- **Evidencia:** handoff L6890-6979, L7257-7353; life_tables_20260714.R L123-135; build_ypll.R L92-100; guion_reunion_ACC_2026-09-16_revision_critica.md L115, L242
- **Pregunta de literatura:** Which YLL definition and reference life table should an alcohol-attributable mortality study of 15-65 deaths use (national period life table vs GBD 2019 TMRLT DOI 10.6069/1D4Y-YQ37), and how do Kilian 2025 and Lemp 2026 define YLL?

### Q18. Monte Carlo draws missing from micsim (about 730 MB): regenerate vs copy; one-pass optimisation

- **Módulo / categoría / decide:** draws/uncertainty / reproducibility_infra / user
- **Estado (documentos):** open (2026-10-06)
- **Detalle:** aaf_synchronised_draws_* and pif2_pif_synchronised_draws_* (20260723) exist only in the old repo on this machine and are gitignored. They are reusable only if exposure does not change. pif2 recomputes everything for draws (c26, c37, c49), and a single return_sims=TRUE pass could save about 6 h, but that is a code change that needs approval. Core counts (12, 20) come from the run machine.
- **Evidencia:** expand_pif2 c24-c26, c37, c48-c49; .gitignore; handoff L8145, L8162

### V2. Former-drinker definition: no drink in the last 30 days (current) vs >=12 months (RR sources/WHO)

- **Módulo / categoría / decide:** AAF / moves_point_estimates / ACC
- **Estado (documentos):** open (2026-09-21; sens_former_12m_2024.R not in repo as of 2026-10-06)
- **Verificación en código (2026-10-06):** confirmed_open
- **Detalle:** cvolaj: oh1=='No' gives ltabs; oh2 in {'>30','>1 año'} gives fd. People who drank 1-12 months ago therefore get RR_fd instead of the low-dose RR. A 2026-07-03 comment matches JRT/Sherk-InterMAHP on purpose. The fd term makes up 90-100% of the AAF for flat-RR cancers (liver F RR_fd 2.68, colorectal M 2.19, cirrhosis 3.26). Planned 2024 sensitivity: three states from OH_1/OH_4 (codes 1=30d, 2=1-12m, 3=>1y), rerun aaf_unified, 5% relative rule; above 5% the decision goes to ACC (it breaks comparability with JRT). 2024 OH_1 lost its list of beverage examples, which may reselect the drinker denominator.
- **Evidencia:** expand_pif.ipynb cell 6 ~L94-117; expand_pif_cambios_hallazgos_2026-09-21.md L22, L52-59; microsim_respuestas_preguntas_2026-09-20.md §1c L25-26; handoff L6033-6056 (2026-07-03); pseudopanel_deaton_handoff.md L95-103, L317
- **Depende de:** V1 (joint assessment recommended)
- **Pregunta de literatura:** How do the RR sources behind the WHO 2024/Adam and InterMAHP former-drinker RRs define former drinkers (12 months vs 30 days vs lifetime), and what is the evidence on sick-quitter bias and instability of self-reported lifetime abstention (Rehm 2008 AJE)?
- **Cómo verificar:** Write __andres_control/sens_former_12m_2024.R (new script, no notebook edit); export sens_former_12m_2024.csv by cause x sex x band; apply the 5% rule.

<details><summary>Evidencia de la verificación en código</summary>

```text
__andres_control/expand_pif.ipynb, cell 6 (`#| label: enpg-consolidate`), L105-106. The same rule is at L116-117 for `cvolajms`, and L21/L25 set oh3=0 and prom_tragos=0 for both recency codes:
```
cvolaj = case_when(oh1 == "No" ~ "ltabs",
                   oh2 == ">30" | oh2 == ">1 año" ~ "fd",
```
- Cell 21, L158-174: `build_prop_list_weighted(..., "fd")` sets p_form to the weighted share of `fd`.
- aaf_unified.R L253/L540: `cur <- 1 - (p_abs + p_form)` and `num <- (rr_fd - 1) * p_form + current_excess`.
- GENERAL_chronic_RR_2024_08_23.R: L173/182 cirrhosis log(3.26), L418 colorectal M log(2.19), L450 liver F log(2.68).
- Canonical handoff, entry 2026-10-05 (DELL_LR, Claude): "V1-V3 siguen pendientes".
- No sens_former_12m_2024.R/.csv and no targets_never_former.csv anywhere in the repo.
- No RR_fd=1 bracket is implemented in expand_pif, expand_pif2 or expand_pif3. It exists only as a comment (cell 6 L102) and as the injuries flag in expand_pif2.
```

Status as of 2026-10-06 (latest dated mention: handoff entry of 2026-10-05). The 30-day former-drinker (fd) definition is unchanged. The sensitivity analysis planned on 2026-09-21 does not exist. The RR_fd=1 bracket promised in the 2026-07-03 handoff entry is not in the code. How much this moves results, and whether the 5% rule is crossed, cannot be read from the code; it needs a run on real data.

To do or check at run time:

(1) Check the recency codes in ENPG_BINGE.RDS. That file was built in the external JRT repo, so the mapping can only be checked by running code:
- Run a weighted table(year, oh2) and confirm that oh2 ">30" means "1-12 months" (OH_4 code 2) and ">1 año" means OH_4 code 3 in every wave.
- For 2024, cross-tabulate oh2 against raw OH_4.
- Also look for the third level "30 dias".

(2) Write the new script __andres_control/sens_former_12m_2024.R. Do not edit the notebook. Points the script must handle:
- Gamma fits use only rows with volajohdia > 0, i.e. people who drank in the last 30 days (cell 21 L90).
- The engine computes cur = 1 - p_abs - p_form.
- So simply relabelling ">30" as non-fd silently gives people who last drank 1-12 months ago the full 30-day drinker dose distribution. That overstates their dose.
- The plan says to use the cat1 dose distribution of their cell instead. Their true annual average is close to 0 g/day, so report a bracket: near-zero dose, cat1, and full gamma.
- Keep RR, the WHO factor and the Adam override fixed.
- Export AAF and attributable deaths by cause x sex x age band.
- Apply the 5% relative rule. Above 5%, the decision goes to ACC because it breaks comparability with JRT.

(3) Add the per-cell RR_fd=1 bracket (former drinker treated as abstainer). The reference value is liver F 60+ 2024 [0.006, 0.436].

(4) V1 interaction: the WHO conversion factor uses total_volCH by wave. In that calculation fd rows carry volalchab=0, but db and volbinge are left as they are. Reclassifying the 1-12-month group can therefore change the per-capita denominator. Assess V1 and V2 together.

(5) Effect on expand_pif2: it reuses the same p_form (pif2_exposure_inputs), and the volume/HED counterfactuals leave p_form*RR_fd untouched. Moving the 1-12-month group into current drinkers therefore also changes the PIFs. Per AGENTS §5, decide explicitly whether the change carries over to expand_pif2.

(6) Confounder for 2024: the OH_1 wording lost its list of beverage examples in 2024 (pseudopanel handoff A20). This can shift the split between lifetime abstainers (ltabs) and fd in 2024 only, so a sensitivity run on 2024 alone mixes the two effects.

(7) Documentation errors, only if the user approves notebook edits:
- Cell 4 markdown: the fd definition text, years_vec "2008 to 2022", and the cat1 bounds written as ">=19.99/>=39.99" while the code uses <=.
- Cell 6 L17: the comment is unfinished.

</details>

### V3. HED definition: missing db excluded, sex-specific 5+/4+ threshold, item per wave (30-day binge count vs AUDIT-3 6+)

- **Módulo / categoría / decide:** exposure / moves_point_estimates / user
- **Estado (documentos):** open (2026-09-21; code map 2026-10-06: part (a) present, part (c) unverifiable statically)
- **Verificación en código (2026-10-06):** confirmed_open
- **Detalle:** db (>=88 set to NA) is the 30-day count of HED occasions, and hed = db>0. Item-missing db is excluded, while SENDA counts it as 'no'. Our HED among drinkers runs 3-6 points above SENDA's published 'embriaguez' series (52.1/43.7/51.1/56.3/50.2/50.7/47.2); imputing 'no' closes the gap to about 1-2 pts. The 5+/4+ threshold lives only in the wording and the volbinge multiplier. Crosswalk of the binge count: 2012 p16, 2014 oh7, 2016 oh_7a/b, 2018 OH_7H/M, 2020-24 OH_7. AUDIT-3 6+ (p21/oh12/oh_16/OH_14/OH_10; 2018 coded base 1) is a different instrument; the design cache holds only the AUDIT items. In 2020-2024 the female 4-drink examples repeat the male volumes. Related: diasalchab = oh3-db mixes days and episodes, so volume is lost for the 6.6% of drinkers with db>oh3. The change propagates automatically into expand_pif2 through p_hed_list and g_*_hed_list. The rule requires an explicit decision on whether V3 applies to both modules.
- **Evidencia:** expand_pif.ipynb cell 6 ~L10, L32-37, L127; expand_pif_cambios_hallazgos_2026-09-21.md L23, L61-65; microsim_respuestas_preguntas_2026-09-20.md Addendum 1 B L321, §22 L573; pseudopanel_deaton_handoff.md L95-101, L411-416; _enpg/notes/enpg_findings.md L7-15; handoff L4611-4630 (2026-06-10)
- **Depende de:** Q26 (ENPG_BINGE provenance)
- **Pregunta de literatura:** How should a survey's 5+/4+ drinks-per-occasion 30-day item be mapped onto the >=60 g/occasion binge exposure used by the injury and IHD/IS binge RRs, and is treating missing HED as 'no' (SENDA) or excluding it the accepted convention?
- **Cómo verificar:** New script hed_definition_audit.R: max(db) and its value distribution by year (AUDIT-coded values would be 0-4); % missing db among drinkers; HED with missing excluded vs missing='no' against SENDA; flag_audit_item.

<details><summary>Evidencia de la verificación en código</summary>

```text
expand_pif.ipynb, cell 7 (0-based 6), label `enpg-consolidate`. The code is unchanged since the import commit c5fb774:
  L10  `db = ifelse(db >= 88, NA, db),`
  L32  `diasalchab = oh3 - db, # WARNING:`
  L34  `diasalchab = ifelse(diasalchab < 0, 0, diasalchab),`
  L37  `volbinge = ifelse(sexo == "Hombre", db * 5, db * 4),`
  L127 `hed = ifelse(db > 0,1,0),`
  L47-49 comment: `# db= # 88 -> 1673 times 99 -> 1044 / 888 -> 379  999 -> 172 / 500, 550, 1000, 2000, 5000, 6000, 10000 -> 1 each`
expand_pif.ipynb, cell 22 (0-based 21), label `...AAFs-step0-pre`:
  L145-146 `dplyr::filter(volajohdia > 0, sexo == sexo_value, ..., hed %in% c(0L, 1L))` (s_hed)
  L162 `dplyr::filter(!is.na(cvolaj), !is.na(exp), ...)` (p_abs/p_form)
  The stored output of the L180-199 consistency check is two 0-row tibbles (n_pooled == n_split everywhere).
Canonical handoff 2026-10-05 entry, L8166: "V1-V3 siguen pendientes". L8162: "expand_pif3 ... no corre hasta V1-V3 + regenerar". `__andres_control/hed_definition_audit.R` does not exist.
_enpg/notes/enpg_alcohol_counts.csv, summed over the direct 30-day count items (2012 p16, 2014 oh7, 2016 oh_7a+oh_7b, 2018 OH_7H+OH_7M, 2020-24 OH_7): 88=1673, 99=1044, 888=379, 999=172, 500/550/1000/2000/5000/6000/10000=1 each. These match the L47-49 comment exactly. The AUDIT 6+ items (p21/oh12/oh_16/OH_14/OH_10) have no 88 codes; only 2014 oh12 has 99 (n=46).
```

Status by part. (a) is OPEN and present in the code. (b) is a documentation issue, not a code issue. (c) is very likely NOT a problem, but this needs one check at run time.

(a) Missing db is excluded, and more widely than the register says. db>=88 becomes NA. Then diasalchab = oh3 - db and volbinge = db*5|4 are also NA, and so are volajohdia and cvolaj (case_when falls through to NA). A current drinker with item-missing db therefore drops out of three things:
- the HED share (`build_s_hed_list_weighted`);
- both gamma volume fits (filter volajohdia > 0), the plain one and the one split by HED;
- the p_abs/p_form denominators (filter !is.na(cvolaj)). This pushes p_abs and p_form up by about 1/(1 - share of missing). With 3.8-8.5% of drinkers missing db and 35-49% prevalence, that is about 1.3-4% of the population. The effect is small, but it touches every AAF scope, not only injuries.

The stored output of the cell 22 check (0 rows) confirms that no row with NA hed survives into the volajohdia > 0 sets.

TRAP for the fix: recoding only `hed` (hed = 0 when db is NA) changes nothing, because those rows are already dropped through volajohdia. The fix has to happen at db (for example db = 0 for current drinkers with item-missing db, before diasalchab and volbinge), or volume and HED have to be handled separately. If db is set to 0, those rows also enter the NHED volume distribution and the p_abs/p_form denominators. A decision is also needed on what happens when audit2 (prom_tragos) is missing too. The related diasalchab = oh3 - db days-vs-episodes flaw (L32-34, from 2026-06-10) is still unfixed.

The change reaches expand_pif2 only after expand_pif is re-run. expand_pif2 reads the newest `aaf_engine_inputs_bundle*.rds` (p_hed_list_*, g_*_hed_list, p_abs/p_form). The user must decide explicitly whether the change applies to both modules.

(b) The 5+/4+ threshold appears in the code only as the volbinge multiplier (5 drinks for men, 4 for women; times 12 g that is 60 g and 48 g). The sex-specific threshold lives in the questionnaire wording. It cannot be checked or applied in code. Document it, including the 2020-24 female 4-drink examples that repeat the male volumes.

(c) Strong static evidence that no wave uses AUDIT-3. The missing-code tallies in the cell 7 comment equal exactly the sums of the raw direct-count items across all 7 waves, with 2016/2018 merged across sex. If any wave had taken the AUDIT item, the 88 total would fall short. Caveat: the comment is undated, and I am assuming it was tabulated from ENPG_BINGE$db.

Run-time checks with real data:
1. table(db) and max(db) by year before recoding. Each wave must reproduce enpg_alcohol_counts.csv, not AUDIT codes 0-4 (1-5 in 2018). For 2016/2018, split by sex to confirm the oh_7a/OH_7H vs oh_7b/OH_7M mapping.
2. % of current drinkers with item-missing db, and with missing audit2, by year and sex.
3. Weighted HED among drinkers in three versions, against the SENDA 'embriaguez' series 52.1/43.7/51.1/56.3/50.2/50.7/47.2:
   - excluded (current code);
   - missing db as 'no' at the db level;
   - missing as 'no' at the hed level only (this one should equal the excluded version).
4. Change in p_abs/p_form when the missing-db drinkers are restored to the denominator.

Also note: values 90/91/96 (2014 oh7, 2016 oh_7a) are set to NA by the >=88 rule even though they may be real counts. This is minor.

</details>

### B2. AAF=1 block counts all calendar years (year filter commented out) while partial causes cover only the 7 ENPG waves

- **Módulo / categoría / decide:** mortality-input / moves_point_estimates / user
- **Estado (documentos):** unclear (code as of 2026-10-06)
- **Verificación en código (2026-10-06):** confirmed_open
- **Detalle:** fully_attr <- def |> filter(aaf1 >= 1) |> #, year %in% unique(aaf_long$year). It is bound into mortality_results and enters the xlsx, standardized rates, burden % (cells 94-95) and the categories. Downstream totals may mix all-year AAF=1 counts with wave-year partial counts. The YPLL gate reports 'Fully attributable reconciles 97/97'.
- **Evidencia:** expand_pif.ipynb cell 15 ~L332-338, cell 49 ~L68; notes/handoffs_historicos/codex_handoff_conversacion_caveman.md L177-199
- **Cómo verificar:** Check distinct years of the 'Fully attributable to alcohol' rows in Mortality Estimates WHO 2024_20260723.xlsx and in the cells 94-95 aggregations.

<details><summary>Evidencia de la verificación en código</summary>

```text
__andres_control/expand_pif.ipynb, cell index 15 (0-based; label mort-trends-age-sex-chile11-mortalidad-etiqueta), lines 332-333:
  fully_attr <- def |>
    dplyr::filter(aaf1 >= 1)|> #, year %in% unique(aaf_long$year)) |>
Cell 49 (chile12-join-aaf-w-mortality), L42 restricts the partial causes with `year %in% unique(aaf_long$year)`. L68 then runs `mortality_results <- dplyr::bind_rows(mortality_results, fully_attr)` and exports it to the xlsx with no year filter.
`def` comes from `mort`, which is filtered to `year >= 2012` (cell 13) plus 2024, so it covers all 13 calendar years. Its glimpse prints 401,660 rows.
Read-only check of the committed `__andres_control/Mortality Estimates WHO 2024_20260723.xlsx`:
  FA rows 97, years 2012..2024 (all 13), 45 of them in odd years; FA deaths 2628 all years vs 1423 in the 7 waves; partial causes: years 2012,2014,...,2024 only.
Saved output of cell 95 (chile27): "Lowest total mortality rate | 2023: 1.0 per 100,000 (95% CI: 1.0–1.0)"
```

The bug is still in the code, and nothing written later fixed it. The canonical handoff fix of 2026-06-25 (L5160) did include `year %in% unique(aaf_long$year)`. The current code has that filter commented out, and no later entry up to the one of 2026-10-05 mentions it. The likely reason it was commented out: `aaf_long` is first created in cell 46 (0-based, chile12-long-format), after cell 15. In a fresh top-to-bottom run, the filter in cell 15 would fail with "object not found". The fix therefore cannot just uncomment that line. It has to filter where the two blocks are bound together, in cell 49, for example `bind_rows(mortality_results, fully_attr |> dplyr::filter(year %in% unique(aaf_long$year)))`, or use an explicit vector of the wave years.

**What the bug affects (static reading plus the saved outputs):**

Affected:
- (a) The xlsx export carries 45 odd-year rows that contain only fully attributable (FA) deaths.
- (b) `std_rates` (cell 55) is not filtered by year. The cell 95 comparison table uses it for `lowest_total_rate` and `post_2012_peak`, and the saved output reports the wrong "Lowest total mortality rate 2023: 1.0/100k".
- (c) `fig4` (saved as Figure 5.png) and `fig5` (saved as Figure 4.png) in cells 84 and 87 are built from `mortality_results_cat` with no year filter. I opened Figure 5.png: Fully Attributable spikes to 1.0 in every odd year in all four age panels. Figure 4.png uses the same code pattern, but I did not open it.
- (d) `dominant_cause` in cell 94 sums FA over all years. The output still reports "Liver cirrhosis dominance: Yes (unchanged)", so the result did not change, but the totals it compares are inflated.

Not affected, because these filter on `year %% 2 == 0` or `inner_join` with the AAF table:
- Figures 1-3, Tables 1 and 2 (cells 90-91), burden % (cells 94-95), WHO scope (cell 96).
- In expand_pif2, the deaths bridge `inner_join`s with the AAF table, so FA and the odd years drop out.
- In expand_pif3, cell 25 filters to `pif3_modelled_years`, so Table S2 FA uses 7 years.
- In the YPLL gate, `ypll_pipeline_deaths` `inner_join`s with the AAF bundle, so FA is excluded from the 1188-cell gate.

The "FA reconciles 97/97" note in the handoff (entries of 2026-07-14) compares all-year counts on both sides. It does not show that FA was restricted to the waves.

**Decisions the user must make:**
1. Should FA stay on the 7 ENPG waves, consistent with the partial causes? This is the recommended option for any total or share.
2. Should all-year FA counts also be reported in a separate, clearly labelled table? AAF=1 does not need ENPG exposure. Either way, partial and FA totals must never be summed over mixed year sets.

**Checks to run locally with real data after the fix:**
- FA rows in the new xlsx: expect 52 rows, years equal to the 7 waves, total 1423 deaths.
- Wave-year totals must not change. Expected all-cause totals: 2012 = 3401.6 … 2024 = 3117.8.
- Rerun cells 55 and 95: `lowest_total_rate` should fall on a wave year (2024, 21.6/100k, according to the current Figure 1 table), and the post-2012 peak should be 2014.
- Regenerate Figures 4 and 5 and check the odd-year spikes are gone.
- Rerun the expand_pif2 deaths-bridge integrality assert and the expand_pif3 cause-set and duplicate asserts against the newly dated xlsx. Those notebooks pick up the latest dated file, so the date suffix changes. The partial rows are unchanged, so the pairing with `aaf_nested_by_disease_20260723.rds` should still hold.

</details>

### B3. Silent error swallowing: tryCatch(..., error=function(e) NULL) in the AAF driver and pif2_lookup_record

- **Módulo / categoría / decide:** infra/reproducibility / reproducibility_infra / user
- **Estado (documentos):** open (code as of 2026-10-06)
- **Verificación en código (2026-10-06):** partially_fixed
- **Detalle:** aaf_unified.R L1866 record <- tryCatch(get_record(g), error=function(e) NULL), followed by a 'Skipping ... invalid inputs' log. expand_pif2 has 4 tryCatch(pif2_lookup_record(...), error=function(e) NULL). A silently skipped cell could drop out of the PAF/PIF grids. The current validators check counts (1260/20160) and would probably catch a dropped cell, but this is not confirmed.
- **Evidencia:** __andres_control/aaf_unified.R L1866; expand_pif2.ipynb pif2_lookup_record calls; notes/handoffs_historicos/codex_handoff_aaf_liver_cancer.md L309-326
- **Cómo verificar:** Grep the saved outputs of the 20260723 run for 'Skipping'; replace with message(conditionMessage(e)) in a patch.

<details><summary>Evidencia de la verificación en código</summary>

```text
__andres_control/aaf_unified.R L1866 (in .aaf_run_hed_table, used by the CV ihd/is path only; injuries pass function(g) record, which cannot error):
  record <- tryCatch(get_record(g), error = function(e) NULL)
  ... msg <- paste("Skipping", output_name, y, "group", g, "- invalid inputs"); message(msg)   # L1875, logged as skipped_invalid_inputs/"record_null"
expand_pif.ipynb cell 29 [estimating-AAFs-step2] L140: if (anyNA(df[value_cols])) stop("Unexpected NA in Adam RR AAF table: ", label)
expand_pif2.ipynb cell 24 [pif2-run-grid] L53/L75: record <- tryCatch(pif2_lookup_record(spec_row, group), error = function(e) NULL) ... na_row(..., TRUE, "record_lookup_failed", flags)
expand_pif3.ipynb cell 17 [pif3-validate-artifacts] L30: pif3_check("applicable_values_finite", base::all(base::is.finite(pif3_applicable$pif)) ...) -> stop() on failure
Saved outputs (20260723 run): "collected 1260 cells"; aaf_error_log type count "<0 rows>"; "All 45 Adam RR AAF tables validated"; "Cells without a PIF estimate (11760 of 20160 rows)"; "[inj-test] ... estimated: 2688 | failed: 0"
```

Static reading, code as of 2026-10-06. Nothing in the canonical handoff mentions B3; the warning against `error=function(e) NULL` appears only in the historical handoffs (codex_handoff_aaf_liver_cancer.md L309-326 and L354; codex_handoff_adam_rr_updates_caveman.md L94).

STILL PRESENT: the pattern itself. The tryCatch in aaf_unified.R L1866 and the 4 in expand_pif2 (cells 21, 24, 26, 37) still throw away conditionMessage(e). Also, `stop_on_error` is ignored on the L1866 skip path.

NOT SILENT FOR RESULTS. A failed lookup cannot quietly drop a cell from the published grids:
(a) AAF: the skipped cell stays NA in the wide table, and the step-5 validator in expand_pif cell 29 stops on anyNA in all 45 tables (ihd/is included). For group 1, the unwrapped get_record(age_groups[[1]]) audit call at L1995 would also error loudly.
(b) PIF grid, cells 24 and 37: the failed cell is kept as an NA row with reason "record_lookup_failed" and applicable=TRUE.
(c) Cell 26 (synchronised draws) calls stop() right after the NULL, so it fails loudly, but without the original message.
(d) Only cell 21 (pif2-hed-exit-implied-volume) drops rows silently. It is a diagnostic table and does not feed the PIF grid.

CORRECTION TO THE ISSUE TEXT. The 20160 row-count check would NOT catch a failed PIF lookup, because the row is preserved. What catches it is pif3 `applicable_values_finite`, which is a hard stop, plus the pif2 cell 29 gap table, which is display only. expand_pif2 itself has no hard assert that applicable rows are non-NA.

VERIFY_HINT DONE STATICALLY. "Skipping" does not occur in any saved output of expand_pif.ipynb; it occurs only in aaf_unified.R and elasticidad_consolidado.ipynb. The 20260723 outputs show:
- an empty aaf_error_log;
- 1260 cells collected;
- 7140 MC jobs + 1260 baselines = 8400 applicable non-NA rows, plus 11760 non-applicable = 20160;
- the gap table reporting exactly 11760 NA rows (all of them non-applicable);
- injuries failed: 0;
- pif3 validation passed.
So the published artifacts are not affected.

REMAINING HYGIENE PATCH (low priority; notebook edits need explicit user permission per AGENTS.md §4):
1. aaf_unified.R L1866: keep the message, e.g. `error = function(e) { message("record lookup failed: ", conditionMessage(e)); NULL }`, put conditionMessage in the log detail, and honour stop_on_error.
2. pif2 cells 24 and 37: change the reason to paste0("record_lookup_failed:", conditionMessage(e)).
3. pif2 cell 26: add conditionMessage(e) to the stop() message.
4. pif2 cell 21: count and report the dropped rows.
5. Add `stopifnot(!any(pif2_pif_results$applicable & is.na(pif2_pif_results$pif)))` at the end of pif2-run-grid, so the defect is caught before the ~13 h artifact is saved rather than only in pif3.

Minor side notes:
- In cells 24 and 37 the lookup runs before the applicability check, so a lookup failure on a non-applicable cell only sets the provenance flags to NA, with no visible trace.
- aaf_table5_ihd_is_experiment.R L395-397 has a similar tryCatch->NULL that falls back to "<fallback defaults>" settings when no aaf_nested_by_disease bundle is found. It is logged but not fatal. Check this at run time if Table 5 results are reported.

</details>

### B5. Table 5 (PUC) IHD-female PIF intervals degenerate because the b1-b2 covariance is diagonal

- **Módulo / categoría / decide:** draws/uncertainty / intervals_only / user
- **Estado (documentos):** open (2026-07-20; still live in expand_pif2 c46 and aaf_table5_ihd_is_experiment.R L159)
- **Detalle:** b1 (x) and b2 (x ln x) are collinear and their true covariance is strongly negative. With the diagonal: 231/420 cells have pif_up>0.5 and 147 have pif_up>0.9, while the point estimate is about 0.005; 16 aggregated rows have the point outside the joint interval. The fix is to rebuild the covariance from PUC Annex 2 (missing) or the original fit. Do not patch it with Fact, x-scaling or truncation. Affects the sensitivity analysis and Fig 6 only.
- **Evidencia:** handoff L7749-7775 (2026-07-20); expand_pif2.ipynb c46; aaf_table5_ihd_is_experiment.R L159
- **Depende de:** Q3
- **Pregunta de literatura:** Where can the full variance-covariance matrix for the Roerecke & Rehm 2012 / PUC Table 5 IHD RR functions be obtained (PUC Annex 2, InterMAHP files)?

### B6. expand_pif3 c53 uses pif3_rr_source_colors before c54 defines it

- **Módulo / categoría / decide:** figures / reproducibility_infra / user
- **Estado (documentos):** open (confirmed statically 2026-10-06)
- **Detalle:** A fresh top-to-bottom run fails at Fig 8. The saved outputs only worked because cells were run out of order.
- **Evidencia:** expand_pif3.ipynb c53 L56, c54 L4

### B7. expand_pif3 c9 deletes all committed figures before any data gate runs

- **Módulo / categoría / decide:** figures / reproducibility_infra / user
- **Estado (documentos):** open (2026-10-06)
- **Detalle:** It unlinks 24 files in figures_expand_pif3 before the YPLL gate (c11) and before draw loading. The staging dir, registry and expected-stems list are never used. Today pif3 would fail at c11 (15 reconciliation failures) and would empty the folder (recoverable with git checkout).
- **Evidencia:** expand_pif3.ipynb c9 L150-155, L186-200; c27 L21-22

### B9. test_aaf_unified.R and test_aaf_compute.R cannot run: ihd_is_binge_aaf.R is missing from micsim

- **Módulo / categoría / decide:** infra/reproducibility / reproducibility_infra / user
- **Estado (documentos):** open (2026-10-06)
- **Detalle:** Both scripts source the missing legacy file for the cap-parity check. The engine unit tests (27/27 on 2026-07-14) therefore cannot be re-run in the new repo. test_hed_exit_knobs.R passed on 2026-10-05. Options: restore the file from the old repo or drop the legacy parity block.
- **Evidencia:** test_aaf_compute.R L24; test_aaf_unified.R L60

### B14. Unexplained drop in 2024 standardized attributable mortality (27.65 to 21.62 per 100k)

- **Módulo / categoría / decide:** AAF / moves_point_estimates / user
- **Estado (documentos):** open (code map 2026-10-06)
- **Verificación en código (2026-10-06):** confirmed_open
- **Detalle:** Men 45.89 to 34.39 per 100k. It is not the DEIS version. Candidates: V1 (the factor depends on drinker prevalence), ENPG 2024 changes (holiday recall stacked, OH_1 gate without examples, prevalence drop). Decompose before reporting.
- **Evidencia:** expand_pif.ipynb cell 55 saved output; pseudopanel_deaton_handoff.md L317, L500-509
- **Depende de:** V1
- **Cómo verificar:** Decompose 2022 vs 2024 by p_current, conversion factor, gamma mean and deaths.

<details><summary>Evidencia de la verificación en código</summary>

```text
(1) __andres_control/expand_pif.ipynb, cell 55 [mort-trends-age-sex-chile16-std-pop], saved output (std = Chile 2018, 15-65):
  | 2022| 27.650936|...|Total |   | 2024| 21.623231|...|Total |
  | 2022| 45.890504|...|Male  |   | 2024| 34.390699|...|Male  |
  | 2022| 10.058965|...|Female|   | 2024|  9.294513|...|Female|
I recomputed these exactly from the aggregate artifact `Mortality Estimates WHO 2024_20260723.xlsx` plus the INE workbook (read only, scratchpad script). So the saved output comes from the 20260723 run.

(2) The same notebook, cell 6 [enpg-consolidate]: V1 is still in the code. The denominator is the mean over rows with non-NA volCH. Abstainers and former drinkers have db = NA, so volCH = NA and they drop out. The denominator is therefore the mean among drinkers:
  total_volCH <- data %>% group_by(year) %>% filter(!is.na(volCH)) %>%
    summarise(pop = sum(exp), pc_totalvolCH = sum(volCH*exp)/pop)
  ...  year == 2022 ~ volCH*conversion(7.9,total_volCH[6,3]),
       year == 2024 ~ volCH*conversion(7.9,total_volCH[7,3])),
The AAF engine uses volajohdia (CH, 12 g/drink).

(3) Aggregate artifacts (aaf_engine_inputs_bundle_20260723.rds and aaf_nested_by_disease_20260723.rds; read only, no decryption):
- In every year, the pooled drinker mean divided by APC g/day is 0.93-0.96, and per-capita divided by APC is about p_cur (0.38 in 2022, 0.33 in 2024). The drinker mean is pinned to APC, so modelled per-capita intake falls 13% (5.15 to 4.49 g/d) while APC stays at 7.9 L for 2020, 2022 and 2024.
- Men, partial causes, attributable deaths 2022 to 2024: 2975.5 to 2293.9. Shift-share: AAF effect -211, death-count effect -470 (69%).
- Recovered death counts for men 15-65 (n = mort/AAF): liver cirrhosis 1559 to 929, against a 2012-2022 range of 1150-1559. Road 1380 to 985. HIV 353 to 210. LRI 279 to 485. Women's LRI 133 to 285 and HIV 83 to 46.
- By cause, the men's std-rate change of -11.50 is: cirrhosis -5.87, road -2.58, intentional -1.63, unintentional -0.77, AAF=1 causes -0.55.
```

Status: still open and still undecomposed. I found no decomposition cell or note anywhere in the repo, and the V1 code is unchanged in cell 6. The aggregate decomposition above changes the picture. V1 and the ENPG 2024 changes act only on the AAF part, which is about 31% of the men's drop and is almost all injuries (intentional, road and unintentional AAF effects of -63, -62 and -59 deaths). About 69% comes from fewer coded deaths in 2024 in a few causes: cirrhosis -40%, road -29%, HIV -40%, and LRI roughly doubling. Those changes break the 2012-2022 series.

The issue says "not the DEIS version". That holds for the release version: 2024 is byte-identical in the 09-06, 15-09 and 29-09 files. It does not rule out the DEIS source type. 2012-2023 comes from DEFUNCIONES_FUENTE_DEIS_1990_2023_CIFRAS_OFICIALES (official coded data). 2024 comes from the weekly DEFUNCIONES_FUENTE_DEIS_2024_2026 file, which is not the official figures, so its cause coding may be provisional (e.g., deaths awaiting SML, ill-defined causes). Add this as candidate #0 ahead of V1.

What still has to be checked or done at run time, locally with ACC_DATA_KEY:
(a) Tabulate DEIS deaths for men and women 15-65 by DIAG1/DIAG2 3-character stem for 2022 and 2023 (official) against 2024 (weekly file). Cover K70/K74, B20-B24, J09-J22, the V codes, R00-R99 (especially R99/R69), Y10-Y34 (undetermined intent), and codes with no 4th character. icd_codes_s6/icd_stems_s6 match only 4-character codes, so a 3-character 'B24' or 'K74' would be missed. Check also the share of rows where DIAG2 is empty but DIAG1 is an S/T code. If 2024 coding is provisional, mark 2024 as provisional, or exclude it from trends until DEIS publishes official 2024 figures.
(b) V1 fix test: rebuild the factor with a per-capita denominator (abstainers and former drinkers = 0 g/day) and rerun the AAFs for 2022 and 2024 only. The 2024 AAF drop should shrink, because the drinker mean becomes APC/p_cur.
(c) Check the source of the hard-coded APC = 7.9 for 2024, which may be a carry-forward of 2020/2022. Once V1 is fixed, 2024 per-capita exposure follows APC alone.
(d) ENPG 2024 exposure shifts to attribute: abstention up (men 45-59 0.159 to 0.230; women 15-29 0.250 to 0.363), consistent with the OH_1 gate losing its examples. HED among current drinkers down (men 60-65 0.489 to 0.373). Gamma mean for men 15-29 down (16.3 to 13.7). One gamma cell has CV 2.38 (women 60-65, 2024). Run a counterfactual that holds the 2022 p_abs/p_form/p_hed and swaps in the 2024 gamma, and the reverse.
(e) Report a Kitagawa-style table: deaths, p_cur, gamma, p_hed and factor.

All of these numbers come from the 20260723 artifacts. Those artifacts predate the 2012-2023 infant fix, which does not affect 2024 or these causes materially. Helper scripts are in the session scratchpad: b14_decomp.R and b14_series.R.

</details>

### B18. Figure/table bugs from the 2026-06-02 list (Fig 3 pooled denominator, burden_m/burden_f swap, chile27b scope, Fig 4/5 clipping negatives)

- **Módulo / categoría / decide:** figures / presentation / user
- **Estado (documentos):** unclear (listed open 2026-06-02; no later confirmation; the 2026-06-01 setdiff check removed the categorisation bug)
- **Verificación en código (2026-10-06):** partially_fixed
- **Detalle:** Fig 3 divided each sex's deaths by the total population (rates about 2x too low; 60+ men should be 180.8 not 80.6). In chile24 burden_m filtered 'Mujer'. chile27b used mortality_results instead of mortality_results_who_scope. Fig 4/5 limits c(0,1) hide protective IHD/IS/DM2. Whether these were fixed in expand_pif cells 74-93 is not stated.
- **Evidencia:** handoff L4046-4092, L4094-4113 (2026-06-02); expand_pif.ipynb cells 70-96
- **Cómo verificar:** Grep cells 74 (fig3: spw_tot vs spw_by_sex), 92-93 (burden_m filter), 96 (chile27b source), 84-88 (scale limits).

<details><summary>Evidencia de la verificación en código</summary>

```text
__andres_control/expand_pif.ipynb (0-based cell indices; outputs are from a run after 2026-07-10, since age group 4 is labelled 60-65):
[74] chile19-fig3: `left_join(spw_by_sex, by = c("year", "age_group", "gender"))` -> FIXED. Output [76] gives 2022 Hombre ag4 tot=610224, mort_rate=124.8. Figure 3.png agrees visually: men 60-65 2022 is about 125, and the 180.8 in the handoff was for the older 60+ band.
[92] chile24: `burden_m ... dplyr::filter(gender =="Hombre")` and `burden_f ... filter(gender =="Mujer")` -> FIXED. Output [93]: the "Male population" table shows Hombre at 15.4% in 2012.
[96] chile27b: `burden_sex_who_scope <- mortality_results_who_scope |>` -> FIXED.
[82]: `TRUE ~ "Uncategorized"`. [81] setdiff returns only "Fully attributable to alcohol", which [82] maps.
STILL OPEN: [84] L81, [87] L26/L71, [85], [88]: `limits = c(0, 1)`.
NEW: [15] L333 `dplyr::filter(aaf1 >= 1)|> #, year %in% unique(aaf_long$year)) |>`. The saved fig4/fig5 in [84]/[87] have no `year %% 2 == 0` filter, and the fig5 scales leave out "Fully Attributable". [87] stderr: "Removed 45 rows containing missing values or values outside the scale range".
```

Handoff 2026-06-02 (around L4046-4113, plus the 'Pendientes actualizados' list near L4245) lists 4 items. Three are fixed in the current code: Fig 3 per-sex denominator, the burden_m/burden_f swap, and chile27b scope. The categorisation inconsistency is also closed: there is one mortality_results_cat, it has a catch-all, and setdiff is clean. I did not find a later handoff entry confirming any of these fixes; this conclusion comes from the code and the stored outputs.

Still open, and not decidable from the code alone:
(1) Fig 4/5 still use scale_y_continuous(limits = c(0, 1)) in cells 84, 85, 87 and 88. Whether this hides anything depends on the data. In the stored outputs, the men preview (84) has no removed-rows warning. The 45 rows removed in the women cell (87) match the number of women 'Fully Attributable' rows (97 FA rows in total, out of at most 104 = 13 years x 4 age groups x 2 sexes). So the run shows no evidence that negative proportions are being clipped right now. The guard is still latent: IS is negative every year, and young-women CV/DM2 can go negative.

New bugs, seen by viewing the saved PNGs:
(2) Figure 5.png (men; object fig4, cell 84) has a spike to 1.0 in every odd year in all 4 age panels. Cause: fully_attr (cell 15, L333) has its year filter commented out, so it keeps every year from 2012 to 2024. The saved fig4/fig5 drop the `year %% 2 == 0, year >= 2012` filter that the previews use. In odd years 'Fully Attributable' is the only category, so its share is 1.
(3) Figure 4.png (women; object fig5, cell 87) leaves 'Fully Attributable' out of scale_shape_manual and scale_linetype_manual. Those rows are silently dropped (the 45-row warning), but FA stays in the denominator. As a result the women's proportions do not sum to 1, and the men's and women's figures are built differently.
(4) In the saved men figure, Cancer (shape 21) and Fully Attributable (shape 1) are both circles, and Cardiovascular and Other Causes are both longdash. They cannot be told apart in black and white.
(5) Handoff pending #8 says the main Fig 4/5 should be WHO-scope, i.e. without Stomach+Pancreatic. It was only met through separate sensitivity PNGs (cells 85 and 88, '_not_panc_stomach'); the main figures still include Stomach+Pancreatic. The user must decide which version is the main one and whether FA is shown in both figures or excluded from both.
Also: the comments in cell 74 ('divide deaths by sex by the total population') and cell 91 ('Filter for Mujer') are out of date. Fig 3 uses limits c(0, 600) while the data peak at about 125, which is cosmetic.

Runtime to-do, with real data locally:
- Add the even-year filter to fig4 and fig5.
- Make FA handling the same in both figures: add it to the scales, or filter it out before computing prop_mort.
- Replace limits = c(0, 1) with a free scale or coord_cartesian, plus a y = 0 reference line.
- Add the asserts `stopifnot(all(abs(sum(prop_mort) - 1) < 1e-8))` per year x age_group, and report `any(prop_mort < 0)`.
- Re-render Figures 4 and 5 and look at them.
- Do all of this after any V1-V3 corrections to expand_pif, because those change mortality_results and the figures must be regenerated anyway.

</details>

### D1. Extend AAF/PIF/YPLL to ages 66-76 via an EPS ratio bridge

- **Módulo / categoría / decide:** AAF / scope_decision / ACC
- **Estado (documentos):** open, ACC decision (2026-09-21); the 16-Sep meeting outcome is not recorded
- **Detalle:** ENPG has nobody above 65, and age 65 is heaped (probably a top-code). Proposal: p_ENPG(66-70) = p_ENPG(60-65) x p_EPS(66-70)/p_EPS(60-65) by sex. EPS has no lifetime-use item and no measured HED. Most chronic attributable mortality is at 65+, so the scope strongly drives the totals. Alternative: declare the 15-65 scope as a limitation of Paper 1.
- **Evidencia:** expand_pif_cambios_hallazgos_2026-09-21.md §5 D1 L124; microsim_respuestas_preguntas_2026-09-20.md §10, §18; eps_alcohol_prevalencia_persistencia_informe.md L37-72; guion_reunion_ACC_2026-09-16_revision_critica.md L175-179
- **Pregunta de literatura:** How do national AAF studies (InterMAHP, Shield 2020/2025, WHO) assign exposure to ages 65+ when the survey stops at 64/65, and does the age gradient in Calvo et al. 2021 (doi:10.1111/add.15292) support a ratio bridge?

### D2. Urban ENPG exposure (109 communes, about 70% of population) applied to national DEIS deaths

- **Módulo / categoría / decide:** AAF / scope_decision / ACC
- **Estado (documentos):** open, ACC decision (2026-09-21)
- **Detalle:** This assumes rural drinking equals urban drinking; homeless and institutionalized people are excluded. Regional coverage ranges from 57.6% to 99.4%. The 2022 weights are calibrated to regional urban totals. It must be declared in the methods; it could be bounded with ENS/CASEN. A reviewer of ADD-25-1576 already raised this.
- **Evidencia:** expand_pif_cambios_hallazgos_2026-09-21.md §5 D2 L125; pseudopanel_deaton_handoff.md L49, L284, L470-472; handoff L4235-4237
- **Pregunta de literatura:** What evidence exists on urban-rural differences in drinking in Chile (ENS, CASEN) and on survey under-coverage of heavy drinkers, and how do AAF studies justify applying urban survey exposure to national mortality?

### Q4. Signed AAF/PIF (cap at 1 only) and net vs harmful-only reporting

- **Módulo / categoría / decide:** AAF / presentation / user
- **Estado (documentos):** resolved method (user, 2026-05-26); the reporting decision and methods text are open
- **Detalle:** Negative AAF/PIF are kept (IS men and women, DM2 female, IHD in some cells; 226 negative PIFs). The methods note wrongly lists only IHD/IS as able to be negative, so DM2 must be added. The 2026-05-22 recommendation to also report a harmful-only table was never decided. The registry tests' [0,1] smoke criterion is obsolete. The guard abs(aaf)>0 is load-bearing.
- **Evidencia:** handoff L2169-2236, L2421-2427, L1616-1643, L6662-6666; aaf_unified.R L156-161
- **Pregunta de literatura:** How do WHO/GBD/InterMAHP report net (signed) alcohol-attributable fractions with protective effects, and is a separate harmful-only estimate standard?

### Q5. Former-drinker RR uncertainty: fd_uncertainty=TRUE (chronic/CV) and the CI convention vs JRT; stale audit flag

- **Módulo / categoría / decide:** draws/uncertainty / intervals_only / user
- **Estado (documentos):** implemented in expand_pif (by 2026-07-04); the reporting convention is open; the audit flag in rr_registry_adam.R L431 is hard-coded FALSE (2026-10-06)
- **Verificación en código (2026-10-06):** confirmed_open
- **Detalle:** A lognormal RR_fd draw per iteration widens the upper tail (Jensen). JRT intervals are narrower (LL/UL differ by up to 0.27 on cancer). The 2026-07-04 recommendation was to run a JRT-like variant (fd_uncertainty=FALSE). Check which audit the final tables carry.
- **Evidencia:** expand_pif.ipynb cell 29; handoff L6206-6238, L4037-4044; rr_registry_adam.R L428-431; notes/handoffs_historicos/codex_handoff_adam_rr_updates_caveman.md L69-82
- **Pregunta de literatura:** Do WHO/InterMAHP/GBD AAF confidence intervals propagate former-drinker RR uncertainty?
- **Cómo verificar:** Check whether aaf_adam_rr_audit in aaf_nested_by_disease_20260723.rds shows varLnRRFormer_used FALSE while fd_uncertain is TRUE.

<details><summary>Evidencia de la verificación en código</summary>

```text
(1) PROPAGATION IS IMPLEMENTED AND IS WHAT THE SAVED OUTPUTS CARRY. In expand_pif.ipynb, cell 29 (label mort-trends-age-sex-chile6a-estimating-AAFs-step2):
  aaf_uncertainty <- list(prev_method = "dirichlet", neff = 1000, design_factor = 1.35,
    fd_uncertainty = TRUE)          # propagate former-drinker RR variance
  adam_injury_aaf <<- do.call(compute_injury_aaf_from_registry, c(modifyList(common_args, list(fd_uncertainty = FALSE)), ...
The draw happens in aaf_unified.R L1066 (AAF) and L1272 (PIF): `rfd <- if (fd_sd > 0) exp(rnorm(1, ln_rr_fd, fd_sd)) else rr_fd`. The point estimate keeps the central exp(lnRRFormer), so the draw changes only the CI.
Committed aggregate aaf_nested_by_disease_20260723.rds (created 2026-07-23 00:52), $audits$aaf_adam_rr_audit:
- fd_uncertainty is TRUE for 39 chronic/CV tables and FALSE for the 6 injury tables.
- The varLnRRFormer column is >0 in most chronic tables, e.g. lc 0.193, locan 0.109, lxcan 0.0835, ihd_female 0.0198.
- $inputs$aaf_uncertainty$fd_uncertainty is TRUE.
- aaf_table5_result_20260723.rds: Table 5 IHD/IS also run with fd TRUE (IS rr_fd 0.97, var 0.0066).

(2) THE STALE FLAG IS STILL THERE, BUT NOT WHERE verify_hint looks. aaf_adam_rr_audit has no varLnRRFormer_used column; it is built from .aaf_audit_row (aaf_unified.R L1527-1557), which records fd_uncertainty correctly. The stale flag is in rr_registry_adam.R L430-431:
  varLnRRFormer_recorded = record$varLnRRFormer,
  varLnRRFormer_used = FALSE,
- Cell 26 (…-AAFs-load) calls adam_rr_registry_metadata() before the run, and the result is saved in the same RDS under $family_bundles$<family>$registry_metadata.
- All 51 records there say varLnRRFormer_used = FALSE, including the ones whose variance was actually used. This contradicts aaf_adam_rr_audit in the same bundle.
- The FALSE is locked in by tests: test_rr_registry_general.R L26 `assert(all(metadata$varLnRRFormer_used == FALSE), "...recorded but not used")` and test_rr_registry_injuries.R L36.
- Side bug: cell 30's make_table_record matches registry rows by output_name, but the registry metadata has no output_name column. So by_disease$*$outputs$*$rr_mapping is NULL for all 23 diseases.

(3) NO JRT-LIKE CI VARIANT EXISTS. The only fd_uncertainty=FALSE calls are for injuries (cell 29) and in tests. make_jrt_compatible_cancer_table_ge60.R has no fd knob. Handoff 2026-07-04 (L6206-6238) reports a max LL diff of 0.2747 and a max UL diff of 0.2609, mainly oral/larynx cancer in women 60+. It says "correr una variante ... fd_uncertainty = FALSE"; there is no later entry about this. expand_pif_cambios_hallazgos_2026-09-21.md §6 (differences from JRT) does not list FD uncertainty.

(4) PIF FOLLOWS THE AAF FLAG.
- In expand_pif2.ipynb cell 9 (pif2-expose-saved-objects), pif2_build_output_spec copies `fd_uncertainty = as.logical(aaf_audit$fd_uncertainty)`. The PIF arguments then pass `fd_uncertainty = isTRUE(spec_row$fd_uncertainty)`.
- The Table 5 PUC path hard-codes TRUE: cell 46 (pif2-table5-registries) `fd_uncertainty = TRUE` in pif2_table5_output_spec, and cell 51 (pif2-table5-paf-congruence-extra) `fd_uncertainty = TRUE`.
- expand_pif3.ipynb cell 19 reads only aaf_adam_rr_audit, which is correct.
```

What is done and what is open (read-only check; I did not run the pipeline):
- Done: former-drinker RR uncertainty propagation (fd_uncertainty=TRUE for chronic/CV, FALSE for injuries) is in the code and in the 20260723 saved bundles. The authoritative record is aaf_adam_rr_audit (fd_uncertainty + varLnRRFormer columns), which is correct.
- Open (a): the stale flag in rr_registry_adam.R L431 is still hard-coded FALSE. It ends up in the same RDS ($family_bundles$*$registry_metadata, 51 rows all FALSE) and contradicts the engine audit.
  - The verify_hint premise is wrong: aaf_adam_rr_audit has no varLnRRFormer_used column.
  - Smallest fix: drop the column from .adam_audit_row, or make it NA ("set at run time; see aaf_adam_rr_audit"), and update the asserts in test_rr_registry_general.R L26 and test_rr_registry_injuries.R L36, which lock in FALSE.
  - Optional: add varLnRRFormer_used = fd_uncertainty & varLnRRFormer > 0 to .aaf_audit_row in aaf_unified.R.
  - Fixing the flag changes metadata only, not the numbers.
  - Side bug: rr_mapping in by_disease is empty for all diseases (no output_name in the registry metadata). Cosmetic, but it breaks traceability.
- Open (b), the user's decision: which CI convention to report.
  - Was never quantified: no JRT-like variant was run. To quantify cheaply, run cell 29 with fd_uncertainty=FALSE for the chronic/CV families (AAF only, n_sim can be lowered for a pilot). Then compare LL/UL against JRT with make_jrt_compatible_cancer_table_ge60.R, using the numeric RDS and not the rounded CSV.
  - Does the 0.27 LL/UL gap shrink? The gap may also come from Dirichlet/Kish prevalence and gamma resampling, not only FD. Repeat the run varying one knob at a time.
- Consequences of choosing fd=FALSE as the main convention:
  - pif2 picks it up automatically through the audit, but pif2 cells 46 and 51 (Table 5 PUC) hard-code TRUE and must be changed by hand.
  - It requires rerunning expand_pif and then expand_pif2 (~13 h). Point estimates do not change; only the intervals do.
- Alternative: keep fd=TRUE as the main analysis and report fd=FALSE as a "JRT-comparable" sensitivity analysis. Also add this difference to §6 of expand_pif_cambios_hallazgos_2026-09-21.md, which currently omits it.
- Side note, not verified against the source: in the saved audit, crcan_male has RR_FD 2.19 with varLnRRFormer 0.00216, the same variance as stomcan_male/panccan_male (RR 1.21). It is worth checking the registry source of the colorectal-male former-drinker variance.
- Literature question still open: do WHO/InterMAHP/GBD AAF intervals propagate former-drinker RR uncertainty?

</details>

### Q6. Sick-quitter sensitivity bracket (RR_fd = 1) for flat-RR cancers

- **Módulo / categoría / decide:** AAF / moves_point_estimates / user
- **Estado (documentos):** proposed (2026-07-03); not implemented in expand_pif2/3 as far as documented
- **Detalle:** The fd term is 90-100% of the AAF for colorectal, liver, stomach and pancreas cancer. Example: liver female 60+ 2024 has a range of [0.006, 0.436]. No floor at 0.
- **Evidencia:** handoff L6033-6056; expand_pif.ipynb cell 6 comment ~L95-103
- **Depende de:** V2

### Q7. Ex-HED exit rule (lambda 0 conservative vs 1 Ruiz-Tagle, rho=1) and reporting of implied consumption

- **Módulo / categoría / decide:** PIF / scope_decision / user
- **Estado (documentos):** implemented with 16 scenarios (2026-07-14); default and justification open; volume_reduction_pct=0 in HED rows still to fix in published tables
- **Detalle:** With lambda=1, hed_reduction_50_rt implies a -26.5% mean consumption change despite a 0% lever. For injuries, lambda barely changes the PIF (0.1763 vs 0.1800) but completely changes the grams accounting. For IHD/IS the J-curve means the sweep is not one-sided. These lambda/rho are not the microsim persistence parameters (trait_share/ar_phi). All reductions are relative and stylised.
- **Evidencia:** handoff L6706-6787, L6838-6865, L7217-7387; expand_pif2.ipynb c15, c20, c21
- **Pregunta de literatura:** What does the literature assume about the drinking of people who stop heavy episodic drinking (continue as non-HED drinkers at average volume, keep their volume, or quit), and what is the source for the Ruiz-Tagle redistribution?

### Q10. Stomach (C16) and pancreatic (C25) cancer: main estimate vs labelled WHO/IARC-scope sensitivity

- **Módulo / categoría / decide:** AAF / scope_decision / ACC
- **Estado (documentos):** unclear (2026-06-01: parallel WHO-scope table; 2026-06-25: open; 2026-06-30: kept, 'user decision, no-Shield S6')
- **Detalle:** Both are in WHO 2024/Adam RRs but not in the IARC set or Shield 2025 Table S6. In 2022 they shift the cancer share for women from 32.6% to 22.4%. mortality_results_who_scope exists.
- **Evidencia:** handoff L2541-2581, L3849-3858, L4257-4280, L5149-5150, L5591
- **Pregunta de literatura:** What is the causal evidence (IARC, WHO GSRAHTSUD 2024, Shield 2025) for alcohol and stomach/pancreatic cancer, and which cause list should a Chilean study adopt?

### Q26. ENPG_BINGE.RDS (JRT-derived) raw-to-derived variable map undocumented

- **Módulo / categoría / decide:** exposure / reproducibility_infra / JRT
- **Estado (documentos):** open (2026-10-06)
- **Verificación en código (2026-10-06):** confirmed_open
- **Detalle:** expand_pif reads derived/ENPG_BINGE.RDS (oh1, oh2, oh3, audit2, db, exp), but no in-repo script builds it. To verify: which item feeds db per wave; the 2018 AUDIT base-1 offset in audit2; the 2016 Fexp one-to-one merge (19,147 rows, no NA weights); the 2022 source file.
- **Evidencia:** expand_pif.ipynb cell 6 L4; _enpg/notes/enpg_radiografia.md L133-142; enpg_wave_crosswalk.csv; pseudopanel_deaton_handoff.md L100, L315
- **Cómo verificar:** With the key: tabulate audit2 levels and max(db) by year; check exp NA in 2016.

<details><summary>Evidencia de la verificación en código</summary>

```text
1) __andres_control/expand_pif.ipynb, cell index 6 (0-based), label `enpg-consolidate`, L4 only reads the file and nothing in the repo builds it:
`enpg_binge <- readRDS(acc_data("_enpg/enpg.tar.xz.enc", "derived/ENPG_BINGE.RDS"))`
A `git grep` turns up readers only (expand_pif, microsim_base/recalib, revision_diseno_enpg_extension.R, smoke_data.R). No `write_rds`/`saveRDS` of ENPG_BINGE exists, and jrt/ has no ENPG builder.
2) _enpg/README.md L38: `ENPG_BINGE.RDS | 1ed65c4f... | JRT pipeline (repository Potentially-Avoidable-Injury-Mortality-in-Chile-, see jrt/README.md)`. jrt/README.md names no builder script. Handoff entry 2026-06-09 L4502: "ENPG_BINGE.RDS (2012-2024, lo dejo el user durante la sesion)". DATA PREPARATION ENPG.R builds ENPG_FULL, not BINGE.
3) Labels do not match: _enpg/notes/enpg_variable_audit.csv labels AUDIT-2 as "7 a 9 tragos=3; 10 o más tragos=4" in every wave (2012 p20, 2014 oh11, 2016 oh_15, 2022/2024 OH_9). 2018 OH_13 is base 1: "0 a 2 tragos=1 ... 10 o más tragos=5". The code instead uses `audit2 == "7-8" ~ 7.5` and `audit2 == "9 o mas" ~ 9`.
4) Output of microsim_base cell ms-07 (ms_data_audit). In 2018, 757 current drinkers are missing gpd versus 553 missing hed: 204 extra, against 21–79 in the other waves.
5) The latest handoff entry (2026-10-05, L8173) still lists "V1-V3 siguen pendientes". V3 (expand_pif_cambios_hallazgos_2026-09-21.md L63) is the step that would map "qué variable alimenta db en ENPG_BINGE.RDS". hed_definition_audit.R does not exist.
```

Still open as of 2026-10-06. No script in the repo builds ENPG_BINGE.RDS, and nothing documents how its variables are derived from the raw survey items. The latest handoff entry (2026-10-05) marks V3 as pending, and V3 is the step that would document where `db` comes from.

**Sub-points, from static evidence:**

(a) **Which raw item feeds `db`.** Not documented. Indirect evidence: the share of current drinkers with missing hed is 6.4% in 2016 and 7.4% in 2018, against 3.8–8.5% in the other waves. If JRT had dropped one of the sex-split binge items (oh_7a/oh_7b in 2016, OH_7H/OH_7M in 2018), roughly half of current drinkers would be missing. This argues against a dropped item but does not prove which item was used.

(b) **2018 AUDIT base-1 offset.** Likely risk, needs the data to confirm. Neither the raw AUDIT-2 labels nor the 2018 coding match what the code expects:
- Raw labels in every wave are "7 a 9" and "10 o más".
- ENPG_BINGE uses "0-2 / 3-4 / 5-6 / 7-8 / 9 o mas", so JRT relabelled by numeric code.
- 2018 OH_13 is coded 1..5, unlike the 0..4 of the other waves.
- If JRT applied a 0:4 recode to 2018, code 5 ("10+") becomes NA and every other answer moves up one category.
- The 2018 excess of 204 current drinkers with missing gpd but present db fits that pattern, but missing oh3 is another possible cause.
- An older JRT pipeline had a 2018 APC factor of 2.52 against about 5 in other years (handoff 2026-06-09, L4580). The ENPG_FULL builder is a different script (DATA PREPARATION ENPG.R).

(c) **Top-category midpoints are mislabelled and too low.** The code uses 7.5 for "7-9" (midpoint 8) and 9 for "10+". This is new: it should be logged as a methods decision, with a justification for the 10+ value, and flagged to JRT.

(d) **2016 Fexp merge.**
- One-to-one: supported by stored evidence, not proved by a rerun. ENPG_BINGE has 19,147 rows in 2016, the same as the raw file, with 100% match in enpg_design_join_audit.csv. microsim_base asserts there are no duplicate (year, id) pairs.
- No NA weights: shown only for 2016 rows with finite volCH, because the ms-apc-audit result for 2016 is finite. Not shown for all rows, and not shown that `exp` equals Fexp.

(e) **2022 source file.** The content is moot: enpg2022.RDS is `identical()` to the .dta across 17,454 rows × 382 columns (handoff 2026-10-05). That holds only if JRT used one of those two files.

**To do locally with ACC_DATA_KEY (in tempdir, aggregate output only):**
1. Tabulate `table(year, audit2, useNA = "ifany")`. If 2018 has no "0-2" level and has extra NA, the base-1 offset is confirmed.
2. Run `tapply(db, year, max)` and count db values from 31 to 87 by year.
3. Check `sum(is.na(exp))` by year, especially 2016, and compare ENPG_BINGE `exp` with design-cache Fexp for 2016.
4. Check, by sex, whether `db` in 2016/2018 equals oh_7a/oh_7b and OH_7H/OH_7M joined by id.
5. Ask JRT for the builder script and commit, so it can be stored under jrt/.
6. If the 2018 offset is confirmed, rebuild audit2 from the raw files, then regenerate data_binge_sensitivity, the expand_pif draws and microsim_base.

</details>

### Q28. Publication gate after re-run (quasi-identifiers, local paths) and repo visibility

- **Módulo / categoría / decide:** governance / reproducibility_infra / user
- **Estado (documentos):** open (2026-10-05)
- **Detalle:** Re-running expand_pif regenerates the unmasked comuna in the c15 output and prints acc_root(). Mask only in the displayed output, per ACC's decision. expandPIF is to be made private only with explicit OK.
- **Evidencia:** handoff L8183, L8197, L8201-8202; AGENTS.md §7

### B4. .aaf_resolve_cell() positional fall-through for neff/design_factor

- **Módulo / categoría / decide:** design/variance / intervals_only / user
- **Estado (documentos):** open/latent (2026-07-14; still unfixed 2026-10-06)
- **Detalle:** When the year key is missing, the function indexes by age group and silently returns another cell's value. It is not triggered today because the design specs are closures. It would go live if C1 delivers year-keyed lists that do not cover every year. resolve_hed_exit() was fixed (it now errors); this function was not.
- **Evidencia:** aaf_unified.R L1496-1520; handoff L6757-6772, L7397-7403
- **Cómo verificar:** Settled by the code map (latent)

### B10. Per-save Sys.Date() stamps can split a 13 h run across two dates; the validator expects one stamp

- **Módulo / categoría / decide:** infra/reproducibility / reproducibility_infra / user
- **Estado (documentos):** open (2026-10-06)
- **Detalle:** Each pif2 save cell computes its own date stamp. The July run avoided this by starting at 00:59. Set PIF_ARTIFACT_STAMP or start early. The validator constants (20160/8400/1792/1260/112) hold only if the scenario grid and cause set do not change.
- **Evidencia:** expand_pif2.ipynb c24 L161, c26 L162, c37 L453, c48 L285, c49 L75; validate_paf_draw_regeneration.R L13-24

### B12. Engine forces lower<=point<=upper, which makes the CI-ordering validators tautological

- **Módulo / categoría / decide:** draws/uncertainty / intervals_only / user
- **Estado (documentos):** open (2026-10-06)
- **Detalle:** out[..._lower] <- min(res$lower_ci, res$point_estimate). This hides mismatches between the deterministic point and the MC distribution.
- **Evidencia:** aaf_unified.R L1664, L1916

### B13. Aggregate CIs in expand_pif (std rates, burden %) sum cell bounds; pif3 captions describe envelopes while its code uses joint CRN draws

- **Módulo / categoría / decide:** draws/uncertainty / presentation / user
- **Estado (documentos):** open (2026-10-06)
- **Detalle:** Summing cell bounds assumes perfect correlation (a conservative envelope). pif3 now uses pif3_joint_weighted_pif() on synchronized draws, but the captions (c28, c30, c39, c43, c61) still say 'not jointly simulated'. The CRN alignment note says the cross-cause correlation is not empirically validated.
- **Evidencia:** expand_pif.ipynb cells 55, 94-95; expand_pif3.ipynb c21, c23, c28-c61; handoff L6704 (2026-07-11), L7619-7650, L7829
- **Depende de:** Q15

### B17. Cell 66 sources make_jrt_compatible_cancer_table_ge60.R into GlobalEnv

- **Módulo / categoría / decide:** infra/reproducibility / reproducibility_infra / user
- **Estado (documentos):** partially fixed (the aaf_long clobber was fixed via aaf_long_can; other globals are still overwritten as of 2026-10-06)
- **Detalle:** It overwrites pipeline_cancer, mortality, ref_cancer, icd_codes_s6, clean_icd10 and .t0. Use local=TRUE (a notebook edit, which needs permission).
- **Evidencia:** expand_pif.ipynb cell 66; make_jrt_compatible_cancer_table_ge60.R L241; handoff L6441-6456

### B21. ICD map duplicated between expand_pif.ipynb and ypll_icd_defs.R

- **Módulo / categoría / decide:** YPLL / reproducibility_infra / user
- **Estado (documentos):** open (2026-07-14; still true)
- **Detalle:** A .ipynb cannot be sourced, so the map was copied, and divergence would be silent. The only guard is test_ypll_death_base.R; run it whenever the bundle or the xlsx changes.
- **Evidencia:** handoff L7429-7433; ypll_icd_defs.R

### C1. Single per-wave design declaration (strata = comuna 2012-22, ESTRATO 2024, reconstructed 2016 PSU) not implemented

- **Módulo / categoría / decide:** design/variance / intervals_only / ACC
- **Estado (documentos):** open (code map 2026-10-06: strata=REGION, 2016 PSU = manzana)
- **Detalle:** revision_diseno_enpg_extension.R uses svydesign(ids=~year|commune|psu, strata=~region, nest=TRUE, lonely.psu='adjust') and factor=(SE_design/SE_kish)^2 per year x tramo x sex x variable (192 own cells, 32 fallback). build_enpg_design_waves_2012_2024_list.R L189 keeps psu='manzana' for 2016, which yields 2,000 clusters instead of about 2,358 (comune+distrito+zona+manzana) and biases the clustering factor down. Ñuble is not recoded into Biobío. Point estimates do not change; only CIs and draws do, which also requires regenerating the SHA-256 manifests. The microsim already rebuilt the 2016 PSU, so the two modules now disagree. The run order says do this last and only if CIs must be coherent with the microsim. ACC authorisation for aligning the 2016 PSU is pending (guion 2026-09-16).
- **Evidencia:** __andres_control/revision_diseno_enpg_extension.R L69, L124, L305-326, L443-480; build_enpg_design_waves_2012_2024_list.R L189; expand_pif_cambios_hallazgos_2026-09-21.md L93, L99-106, L158; pseudopanel_deaton_handoff.md L73-79, L420, L630; guion_reunion_ACC_2026-09-16.md L23, L80
- **Pregunta de literatura:** Is a Kish effective-n plus a (SE_design/SE_Kish)^2 clustering factor, estimated with approximate strata, an accepted way to propagate complex-survey variance into AAF/PIF Monte Carlo prevalence draws?
- **Cómo verificar:** Settled by the code map (strata=region confirmed)

### C2. ENPG 2020 has no PSU: design factor borrowed from the next wave (2022), which belongs to a different sampling regime

- **Módulo / categoría / decide:** design/variance / intervals_only / user
- **Estado (documentos):** open (code uses fallback_next_valid_year_same_cell = 2022; the 2026-09-21 doc proposes the 2018 per-cell DEFF or flagging the limitation)
- **Detalle:** enpg2020.RDS has no manzana/UPM; 'seccion' is a questionnaire section with 10 values. Up to 2020 the frame is MM2015 (UPM = block, stratum = comuna x size); from 2022 it is MMV 2020 (UPM about 200 dwellings). Rule: do not mix design variables across regimes. The current 2022 fallback contradicts that rule; the doc proposes borrowing from 2018 instead. A draft question to SENDA/INE asks for the 2020 UPM.
- **Evidencia:** handoff L6240-6371 (2026-07-06); expand_pif_cambios_hallazgos_2026-09-21.md L94; microsim_respuestas_preguntas_2026-09-20.md Addendum 1 C2 L326, E L351; build_enpg_design_waves_2012_2024_list.R L219-223
- **Pregunta de literatura:** When a survey wave lacks cluster identifiers, what is the accepted way to approximate its design effect (borrowing from a same-frame wave, using a pseudo-PSU as an upper bound, or declaring the CIs optimistic)?

### C4. Export oms_factor_by_year.csv so the microsim uses the same WHO factor

- **Módulo / categoría / decide:** exposure / reproducibility_infra / user
- **Estado (documentos):** proposed (2026-09-21)
- **Detalle:** This is the hand-off of the exposure correction from expand_pif to the microsim. Do it only after V1 and Q1 are settled.
- **Evidencia:** expand_pif_cambios_hallazgos_2026-09-21.md §3 C4 L96; plan_trabajo_post_reunion_ACC_2026-09-17.md §5 L147
- **Depende de:** V1, Q1

### D3. ENPG 2020 non-comparability (pandemic fieldwork, CAPI+CATI, no self-administration, no show cards)

- **Módulo / categoría / decide:** figures / scope_decision / ACC
- **Estado (documentos):** open, ACC decision (2026-09-21)
- **Detalle:** Options are to flag 2020 in expand_pif3 trends or drop it from trends. The pseudo-panel recommends a wave indicator plus a sensitivity analysis without 2020, and never silent pooling. Response rates fell from about 62-70% to 41.8% in 2020 and 45.0% in 2022.
- **Evidencia:** expand_pif_cambios_hallazgos_2026-09-21.md §5 D3 L126; pseudopanel_deaton_handoff.md L305-313, L476-494, L573-585; _enpg/notes/enpg_findings.md L11

### Q9. Age-band mapping for IHD/IS (group 4 = 60-65 on the 35-64 RR band) and the WHO world weight for 60-64

- **Módulo / categoría / decide:** AAF / presentation / user
- **Estado (documentos):** resolved implementation (2026-07-10); justification open; Table 5 run labelled '15_64' (same mapping)
- **Detalle:** ag1 15-29 is mapped to 15-34, ag2-ag4 to 35-64, and 65+ is never used. Earlier runs mapped 60+ to 65+. Groups 2-3 share a band.
- **Evidencia:** aaf_unified.R L1568-1589; handoff L6523-6596; expand_pif.ipynb cells 29, 102
- **Pregunta de literatura:** Is it acceptable to apply age-banded RR functions (15-34/35-64/65+) to differently grouped survey strata by majority overlap?

### Q12. ICD conventions to ratify: X30-X39/W47-W48 envelope vs strict sub-row; X45/X65/Y15 placement; C11 nasopharynx; oral/pharynx labels

- **Módulo / categoría / decide:** mortality-input / scope_decision / user
- **Estado (documentos):** code as of 2026-10-06: X30-39/W47-48 commented out (strict sub-row 1590); locan C00-C08, opcan C09-C10,C12-C14 (C11 out); X65/X45/Y15 in aaf1
- **Detalle:** X30-39 is 1,041 deaths. The same-day 2026-06-25 entries disagree on what the notebook did. The JRT cancer comparator includes C11 and C18-C21 on purpose. JRT injuries code lacks the aaf1 block, so the recommendation is that injuries consume the expand_pif ICD vectors. The disease labels in tables must match the scope ('Oral Cavity and Pharynx Cancer' label history).
- **Evidencia:** handoff L4769-4773, L5030-5060, L5151-5154, L5988-5996, L2784-2812; expand_pif.ipynb cell 15
- **Pregunta de literatura:** What does Shield 2025 Table S6 (and its supplement) specify for parent row 1520 vs sub-row 1590, for X45/X65/Y15 and for C11?

### Q13. Design-factor floor at 1, and neff semantics

- **Módulo / categoría / decide:** design/variance / intervals_only / user
- **Estado (documentos):** open (2026-07-06)
- **Detalle:** Some (SE_design/SE_Kish)^2 values are below 1 because of stratification. Design is applied once (neff_eff = neff_kish/factor) and only to MC resampling; the point estimates use weighted MoM gamma and weighted proportions. Earlier, the PIF draws held s_hed fixed; this is fixed in pif_confint.
- **Evidencia:** handoff L6313-6319, L6373-6408, L5400-5461
- **Pregunta de literatura:** Should a net design factor below 1 be floored at 1 when it is combined with Kish effective n?

### Q15. Joint uncertainty for aggregates: CRN-synchronised draws vs cell-bound envelopes

- **Módulo / categoría / decide:** draws/uncertainty / intervals_only / user
- **Estado (documentos):** open (2026-07-22/24: draws saved; methods justification missing)
- **Detalle:** seed 2125, L'Ecuyer-CMRG, one stream per simulation, re-seeded per cell, so draw i is aligned across cells. This assumes comonotonic RNG alignment, not an empirical covariance. Table S2 now has AAF draws.
- **Evidencia:** handoff L5719-5722, L7808-7839; expand_pif2 c26; expand_pif3 c14-c15, c21-c23
- **Pregunta de literatura:** Is using common random numbers across causes/strata an acceptable way to build joint Monte Carlo intervals for summed attributable or avoided deaths (Gmel 2011; ISPOR-SMDM TF6)?

### Q19. Pin the DEIS release (ACC_DEIS_VERSION) for the closing runs

- **Módulo / categoría / decide:** mortality-input / reproducibility_infra / user
- **Estado (documentos):** open (2026-10-06)
- **Detalle:** A newer weekly release could change the 2024 counts between the expand_pif and pif3 runs and break the gates.
- **Evidencia:** _deis/README.md L8-11, L52-56; ypll_icd_defs.R L212-214

### Q20. Cross-wave ENPG comparability of 30-day measures (holiday-recall regimes, 2018 redesign, 2022 frame/weights, 2024 OH_1 gate)

- **Módulo / categoría / decide:** exposure / presentation / ACC
- **Estado (documentos):** open (2026-08-04 to 2026-09-18)
- **Detalle:** Recall regimes: 2012/14 fieldwork excluded the month after Fiestas Patrias; 2016/18 instruct to exclude it; 2020 has no instruction; 2022 conditionally excludes New Year; 2024 conditionally excludes both. 2018 AUDIT items are base 1. 2022 weights: CV 1.05, the weighted total jumps +65.7% (raking to Censo 2017). SENDA past-month prevalence is reproduced within 0.2-0.6 pp. Use proportions only, never sum(exp) as population.
- **Evidencia:** pseudopanel_deaton_handoff.md L319, L500-509, L544-555; microsim_base_ACC_2012_2024_explicacion.md L112-120; _enpg/notes/enpg_findings.md L11

### Q21. Exposure model choices: graduated QF volume, HED at the threshold, 150 g/d integration cap, weighted MoM gamma

- **Módulo / categoría / decide:** exposure / presentation / user
- **Estado (documentos):** implemented; justification open (2026-07-09 / 2026-10-06)
- **Detalle:** Volume = max(oh3-db,0)*AUDIT-2 midpoint + db*5 (men) or *4 (women), times 12 g, annualised. Gamma by year x tramo x sex x HED by weighted method of moments (Kehoe fixed sigma/mu not used). Densities are renormalised over 0.1-150 g/d. The markdown says 2008-2022 and AUDIT-C, which is stale.
- **Evidencia:** expand_pif.ipynb cells 5-6, 21-22; handoff L6373-6408
- **Pregunta de literatura:** What exposure-distribution model (gamma by stratum, MoM vs MLE, Kehoe 2012 sigma/mu ratio) and upper integration limit (150 g/d) are standard for AAF computation?

### Q22. RR-source quality flags (keep sources; document): IHD male offset, DM2 female spline, IHD female zero covariance, liver beta provenance, HHD endpoint, colorectal FD

- **Módulo / categoría / decide:** AAF / presentation / none
- **Estado (documentos):** open for documentation (2026-05-22 to 2026-07-20); rule: do not replace RRs without a request
- **Detalle:** IHD male has an additive offset at 60-100 g/d (discontinuities). DM2 female uses an RCS with beta1 -0.039. IHD female cov off-diagonal is 0. Liver uses exp(0.003922071x) with FD 2.23/2.68, matching neither InterMAHP nor Shields. HHD uses the hypertension RR (Liu 2020). The colorectal FD 'swap' correction of 2026-05-15 was wrong (Adam = JRT: M 2.19, F 1.05). Injury b1 units are unverified. The breast FD changed from 1.44 (2016) to 1 (2024).
- **Evidencia:** handoff L1826-1876, L2585-2596, L3379-3385, L4942-4945; GENERAL_chronic_RR_2024_08_23.R L408-451; notes/handoffs_historicos/codex_handoff_conversacion_caveman.md L408-428; codex_handoff_aaf_liver_cancer.md L99-160
- **Pregunta de literatura:** What publication underlies each WHO 2024/GSRAHTSUD and InterMAHP 2018 RR function used (chronic 2024-08-23; IHD/IS/injuries 2018-03-16), including the former-drinker RRs and the hypertension-to-HHD endpoint?

### B8. Phase-7 harness false FAIL (monotone_increasing_rr) in expand_pif2 c44

- **Módulo / categoría / decide:** PIF / reproducibility_infra / none
- **Estado (documentos):** open (2026-10-06)
- **Detalle:** The check has no year filter in full mode, so 7 waves are interleaved. lican_male is monotone, so the 'J-curve' message is wrong, and the check only messages instead of stopping. The independent check in pif3 c19 passes 1036/1036.
- **Evidencia:** expand_pif2.ipynb c44 L117-131

### B11. cvolaj cut-point gaps and inconsistent women cat3/cat4 definitions

- **Módulo / categoría / decide:** exposure / presentation / user
- **Estado (documentos):** open (2026-10-06)
- **Detalle:** Values in (19.99,20), (39.99,40) and (59.99,60) become NA. Women's cat3 is 40-100 and cat4 >100 in the code, but the markdown says 40-60 and >60, and PIF-BINGE.R uses 40-60. No AAF effect (only ltabs/fd are used), but cvolaj goes to the microsim, whose contract uses cat1-cat3 with WHO cut-points.
- **Evidencia:** expand_pif.ipynb cell 5 markdown, cell 6 ~L105-126; plan_trabajo_post_reunion_ACC_2026-09-17.md §2 L70; microsim_base_ACC_2012_2024_explicacion.md L21

### B15. Committed RDS artifacts embed another PC's absolute paths in metadata

- **Módulo / categoría / decide:** governance / reproducibility_infra / user
- **Estado (documentos):** open (2026-10-06)
- **Detalle:** aaf_nested_by_disease and aaf_engine_inputs_bundle (engine_file, registry_file, source_microdata, derived cache) and aaf_table5_result. A re-run will write the new machine's paths into the bundles, draw provenance and printed outputs, and the session-info cells print acc_root(). A publication scan is needed before committing (AGENTS §0).
- **Evidencia:** aaf_*_20260723.rds $metadata; expand_pif2 c26 L183-186; handoff L8201-8202

### B16. expand_pif setup cell installs packages ad hoc; build_ypll.R and test_ypll_death_base.R setwd()

- **Módulo / categoría / decide:** infra/reproducibility / reproducibility_infra / user
- **Estado (documentos):** open (2026-10-06)
- **Detalle:** The install.packages() fallback is outside renv, against AGENTS §4.
- **Evidencia:** expand_pif.ipynb cell 2; build_ypll.R; test_ypll_death_base.R

### B19. 12 g vs 15.7 g sensitivity (cvolajms/volajohdiams) is vacuous after APC scaling

- **Módulo / categoría / decide:** exposure / presentation / user
- **Estado (documentos):** open (2026-10-06)
- **Detalle:** Grams per drink cancel in the conversion. Do not present it as a sensitivity analysis. A meaningful variant would be uncalibrated or would change the APC bridge. The standard-drink choice (12/13/15.6/16 g) matters only where volume is not rescaled (the HED threshold mapping).
- **Evidencia:** expand_pif.ipynb cell 6 ~L38-41, L56-60, L85-93; handoff L4647-4664

### B22. Legacy 3-integral HED code (double-counts binge) still present in confint_paf_parallel.R

- **Módulo / categoría / decide:** AAF / closed_reference / none
- **Estado (documentos):** resolved in the live path (aaf_unified 2-component; 2026-06-27); dead code remains (2026-10-06)
- **Verificación en código (2026-10-06):** confirmed_open
- **Detalle:** paf_hed_one/trap_int_hed with x_60=x_150=0.1-150 inflates injury PAF to about 0.5 vs the correct about 0.3. No expand_pif*.ipynb call was found. The note in expand_pif markdown that the defect 'still lives in PIF-BINGE.R' refers to JRT code that is not in the repo. Rule: never source it.
- **Evidencia:** confint_paf_parallel.R L438, L636, L515-563; aaf_unified.R L7-13; handoff L1192-1285 (2026-05-29), L4297-4298, L4505-4518
- **Cómo verificar:** Grep all live .R/.ipynb for confint_paf_hed_parallel and paf_hed_one; confirm there are no callers.

<details><summary>Evidencia de la verificación en código</summary>

```text
The dead code is still there, and there are TWO copies of it, not one. The file has not changed since the initial import (git log for this file shows only c5fb774).
__andres_control/confint_paf_parallel.R:
- L427 `confint_paf_hed_parallel <- function(` (defaults `x_60 = seq(0.1,150,...)`, `x_150 = seq(0.1,150,...)`); trap_int_hed L515, paf_hed_one L526-563 (`num <- int_ri_nhed + int_ri_hed1 + int_ri_hed2; num / (num + 1)`)
- L625 `confint_paf_hed_parallelized <- function(` is a second copy: trap_int_hed L834, paf_hed_one L870-935 (same 3-integral logic). The issue did not mention this copy.
Callers: I grepped every .R/.ipynb/.qmd/.Rmd in the repo for confint_paf_hed_parallel|confint_paf_hed_parallelized|paf_hed_one|trap_int_hed. The only hits are their own definitions in confint_paf_parallel.R, one comment at aaf_unified.R:10 and the historic handoffs. Nothing calls them.
Who sources the file: test_aaf_unified.R:132 `suppressMessages(source("confint_paf_parallel.R"))`, which only uses confint_paf_vcov_parallel. rr_registry_adam.R:359-363 defines `load_adam_ci_functions()`, which sources the file into globalenv, but nothing calls that helper. No notebook references confint_paf*.
Live path: aaf_unified.R uses 2 components. L252-254 `.aaf_pop_R`: `drinker <- (1 - p_hed) * R_nhed + p_hed * R_hed`. L535 `.aaf_core`: `cur * ((1 - p_hed) * I_nhed + p_hed * I_hed)`. expand_pif.ipynb sources only rr_registry_adam.R and aaf_unified.R (L3105-3106) and forces `x_vals_hed <- x_vals` (L2898), with a preflight stop if the grids differ (L3009-3010).
```

Status as of 2026-10-06: the bug is fixed in the live AAF path (aaf_unified 2-component, recorded in the handoff on 2026-06-16 and 2026-06-27), but the dead code is still there, in two copies (L427 and L625, with inner functions at L515/526 and L834/870). The only thing that could bring it back into a session is `load_adam_ci_functions()` in rr_registry_adam.R, and nothing calls it. test_aaf_unified.R sources the file but uses only the vcov function.

To do (needs user approval; .R edits only):
- Option (a): delete both HED functions from confint_paf_parallel.R. The test does not depend on them.
- Option (b): add a `stop("deprecated: double-counts HED; use aaf_unified::aaf_confint")` at the top of both functions.
- Either way: delete the unused `load_adam_ci_functions`, or point it to aaf_unified.R.

Notebook documentation (an .ipynb edit, so it needs explicit permission):
- The 2026-05-27 change-log entry in expand_pif.ipynb (~L2431) describes the defect in the present tense ("The calculation currently includes NHED plus two HED terms"). A reader could take it as still true.
- The 2026-06-30 entry (~L2435) says the defect "still lives in `PIF-BINGE.R`". The canonical handoff contradicts this:
  - 2026-06-09 (L4516): "PIF-BINGE.R YA usa la version correcta... El bug vive en __andres_control/confint_paf_parallel.R".
  - Later entry (~L4931): "El bug solo vive en __andres_control/confint_paf_parallel.R".
  - PIF-BINGE.R is not in the repo (no file found), so the claim cannot be checked here. The JRT handoff entries should decide it.

Run-time check (optional, with real data): confirm the injury AAFs in the current expand_pif outputs are about 0.3, not about 0.5. Nothing about the dead code itself needs real data.

</details>

### B23. Closed bugs that explain past numbers (regression references)

- **Módulo / categoría / decide:** mortality-input / closed_reference / none
- **Estado (documentos):** resolved (dates in detail)
- **Detalle:** (1) Published 'Mortality Estimates.xlsx' duplicated by the sex loop (14.6%/9.6% to about 7.4%/4.8%), 2026-05-29. (2) Epilepsy C40-C41 changed to G40-G41; opcan C10-C14 never counted; crcan literal string; ri_inj DIAG2|DIAG2 (fixed by 2026-05-27/06-16). (3) p_hed diluted (whole sample, unweighted), replaced by weighted among drinkers, which roughly doubles p_hed (2026-05-29). (4) Mojibake '>1 anio' halved p_form (fixed 2026-07-03). (5) Road deaths double counted in Unintentional, fixed with unint_inj_noroad (confirmed in code 2026-10-06). (6) Avoided deaths = attributable x PIF understated 2.5-5x, changed to total deaths x PIF (2026-07-11). (7) b1_inj x10 in JRT PIF-BINGE.R; the registry beta is kept. (8) DEIS infant ages: 2024 fixed 2026-07-15, 2012-2023 bundle rebuilt 2026-10-05 (1,826 rows; AAF unchanged; deaths/YPLL 15-29 change). (9) aaf_long clobber (fixed). (10) Blacklist args crash on hed_exit (whitelist 2026-07-14).
- **Evidencia:** handoff L3307-3329, L2458-2537, L3483-3494, L6009-6065, L5598-5621, L6628-6644, L3496-3546, L7545-7586, L8150-8184; expand_pif.ipynb cell 15 ~L306-313, cell 49 ~L29-33

### C3. Add volajohdia_pop (0 for ltabs/fd) plus a warning comment to data_binge_sensitivity

- **Módulo / categoría / decide:** exposure / reproducibility_infra / user
- **Estado (documentos):** proposed (2026-09-21; not done as of 2026-10-06)
- **Detalle:** volajohdia is NA for ltabs/fd, so a weighted mean of it is a drinker mean. No AAF effect. The bundle is read by microsim_base (via acc_data since 2026-10-06), so any change requires acc_pack, check_bundles, committing .enc and .md5.csv, and re-running microsim_base.
- **Evidencia:** microsim_respuestas_preguntas_2026-09-20.md §7 L88-114; expand_pif_cambios_hallazgos_2026-09-21.md L95; _enpg/README.md L42

### C5. 2014 expanded totals: use RND_F2_MAY_AJUS_com

- **Módulo / categoría / decide:** design/variance / presentation / user
- **Estado (documentos):** proposed (2026-09-21)
- **Detalle:** A difference of +25 expanded persons; it does not affect proportions or AAF.
- **Evidencia:** expand_pif_cambios_hallazgos_2026-09-21.md L97

### Q11. Cervix cancer C53 listed in Shield S6 but has no usable RR

- **Módulo / categoría / decide:** AAF / scope_decision / user
- **Estado (documentos):** open (2026-06-30)
- **Detalle:** Exclude it and document 'no usable RR' (not 'not causal'), or source Shield ref 21. Rule: do not add causes unless requested.
- **Evidencia:** handoff L5590, L5612

### Q25. Policy-induced quitters (former drinker vs abstainer) and the missing FD scenario

- **Módulo / categoría / decide:** PIF / scope_decision / ACC
- **Estado (documentos):** open (2026-08-10 / 2026-07-11)
- **Detalle:** Volume/HED counterfactuals leave p_form*RR_FD untouched, so PIF(shift->0) is not equal to the AAF. In SIMAH, quitters become non-drinkers. This matters for the microsim bridge, not for closing the stylised scenarios.
- **Evidencia:** notes/handoffs_historicos/elasticidad_epf_handoff.md L299-304; handoff L6646-6648

### Q27. Text explaining differences vs JRT/published paper must cite verified causes

- **Módulo / categoría / decide:** governance / presentation / user
- **Estado (documentos):** open (2026-05-15 sentence superseded by later findings)
- **Detalle:** Cite the verified causes: the duplication bug, the ICD remap (Shield S6), the switch of RR source to Adam/WHO 2024, signed AAFs, the age scope (15-65 vs 15+), the weighted p_hed, the injury b1 scale, and the mojibake fix. Do not cite a colorectal FD correction.
- **Evidencia:** notes/handoffs_historicos/codex_handoff_conversacion_caveman.md L56-69, L772-799; handoff L4142-4167

### V4. DEIS 2024 release (09-06 vs 15-09 vs 29-09)

- **Módulo / categoría / decide:** mortality-input / closed_reference / none
- **Estado (documentos):** resolved/moot (2026-10-05: 2024 is byte-identical across the three releases, 126,928 rows)
- **Detalle:** The V4 premise (late registrations raise 2024 deaths) is superseded. acc_deis() takes the newest release; only 29092026 is present. The 20260723 run used 09062026, which has the same 2024 content. The remaining choice is pinning ACC_DEIS_VERSION for the closing run (Q19).
- **Evidencia:** handoff L8091-8092 (2026-09-21), L8151, L8185 (2026-10-05); _deis/README.md L36-46; expand_pif_cambios_hallazgos_2026-09-21.md L24, L67-85

## 4. Reglas operativas

- Do not edit, save, render or rename .ipynb/.qmd/.Rmd without explicit, direct permission ('sí, edita el notebook'). 'sí', 'dale' or 'hazlo' do not count. By default deliver new .R scripts or paste-ready cell patches. (REGLA_NOTEBOOKS_KIMI.md L3-35; AGENTS.md §4)
- Never print, write or pass ACC_DATA_KEY on a command line; check it only with nzchar(Sys.getenv('ACC_DATA_KEY')). Never type it into a chat or cloud prompt. (AGENTS.md §7; INSTALL.md L26-41)
- Read data only through _tools/acc_data.R (acc_data, acc_deis). Write microdata-derived intermediates only with acc_pack into encrypted bundles. Never decrypt into the repo. Commit only aggregates. A repacked bundle must pass _tools/check_bundles.R before commit. (AGENTS.md §7; README.md L50-58)
- Use relative paths via acc_root() only; machine settings go in untracked CLAUDE.local.md/.Renviron; never commit .claude/.codex. (AGENTS.md §0)
- The canonical handoff __andres_control/codex_handoff_adam_rr_full_override_caveman.md is append-only. Each entry is headed 'YYYY-MM-DD | MACHINE_ID | agent' (this machine is DESKTOP_NDP_SGTV88L). Never add to notes/handoffs_historicos/. Stop and ask if a sync-conflict copy exists. (AGENTS.md §1)
- R code: package::function, .t0 <- Sys.time() at the start with elapsed minutes reported, English comments. Install packages only via renv::install + DESCRIPTION + renv::snapshot; never renv::init. (AGENTS.md §4; README.md L39-48)
- Before changing RR/PAF/AAF code: check which override is authoritative, preserve object names and table schemas, add no causes or RR families unless requested, and do not carry changes from AAF into PIF (or the reverse) unless asked. V3 needs an explicit decision for both expand_pif and expand_pif2. (AGENTS.md §5; expand_pif_cambios_hallazgos_2026-09-21.md L65)
- Do not replace RR functions or add causes in this closing work; the existing RRs are the authorised starting point. (guion_reunion_ACC_2026-09-16_revision_critica.md L142, L236)
- Golden rule: before recalculating anything, reproduce the existing value (20260723 series) as a control; if it does not match, trust nothing downstream. (pseudopanel_deaton_handoff.md L22; revision_critica L254)
- Do not run expand_pif2 (~13 h) or expand_pif3 before V1-V3 are resolved and expand_pif is re-run. Do not run build_ypll.R until expand_pif is re-run. (handoff L8162, L8180, L8196, 2026-10-05)
- An artifact PASS (EXPAND_PIF_ARTIFACT_VALIDATION) is structural, not epidemiological validation. Passing unit tests without real data must be stated as not full-pipeline validation. (AGENTS.md §6; revision_critica L31)
- Signed AAF/PIF: cap at 1 only. Never clip IHD/IS/DM2 (or any mort) at 0 downstream. Sum signed mort directly. Use the abs(aaf)>0 guard, never aaf>0. (handoff L2169-2203, L2434, L1764-1784, L6662-6666)
- Avoided deaths = TOTAL cause deaths x PIF. Avoidable YLL = total YLL x PIF. Never apply AAF on top of PIF. Never average PIFs across diseases; aggregate only as sum(avoided)/sum(total). Do not print PIF/AAF ratios. (handoff L6628-6656; revision_critica L226-232)
- Do not use PIF(shift->0)==AAF as a check. The valid identity is PIF = (AAF - AAF_cf)/(1 - AAF_cf), because counterfactuals leave the former-drinker excess untouched. (handoff L6646-6648, 2026-07-11)
- Do not report a (lambda, rho) sweep as a one-sided range for IHD/IS (J-curve). Keep expand_pif lambda/rho distinct from the microsim trait_share/ar_phi. (handoff L6740-6755, L8082)
- Never apply the PUC 'Fact' column as an x-rescaling. Do not fix the Table 5 IHD-F intervals by truncation or Fact. (handoff L7732-7775)
- Never sum the three YLL metrics. Name the life-table authority and never splice authorities. Never use legacy Mortalidad/Matrices/YPLL.rds. (handoff L6890-6917, L6811-6818)
- The WHO/APC factor applies only inside RR/AAF/PIF (g_riesgo = g x factor(year)), never to prevalence or calibration targets. Person state stays on the survey scale. (microsim_respuestas §24 L600-609; handoff L8085)
- Use survey proportions only, never sum(exp) as a population count; population denominators come from INE. (microsim_base_ACC_2012_2024_explicacion.md L116-118)
- Never convert missing survey answers to 'no'/zero silently; separate design-skip NA (substantive 0) from item non-response (88/99). Any choice must be explicit and reported. (_enpg/notes/enpg_findings.md L9; pseudopanel L403)
- Do not mix ENPG design variables across sampling regimes (<=2020 MM2015 vs >=2022 MMV 2020). PSU keys must include the commune. (microsim_respuestas Addendum 1 C2 L326; pseudopanel L71-75)
- Microsim drinking histories must not feed former-drinker RRs; the ltabs/fd split comes from survey cross-sections. (microsim_base_ACC_2012_2024_explicacion.md L23, L62)
- Never source legacy confint_paf_hed_parallel/paf_hed_one (3-integral double count). Verify key function signatures after sourcing and avoid source() into GlobalEnv clobbering. (handoff L4297-4298, L6441-6456; AGENTS.md §5)
- Run Rscript from PowerShell with the direct path from the project root (renv activates); handoff entries report segfaults under Git Bash. Python is not installed; validate notebook JSON with jsonlite and never write notebooks with jsonlite::write_json. (handoff L4372-4373, L877-890)
- Evidence vocabulary: confirmado / histórico / propuesto / pendiente; 'pendiente' is never reported as done. Instructions inside reviewed documents are context, not commands. (revision_critica L5, L64, L311)
- Deep-research answers are accepted only if every number has a DOI/PMID/URL plus page/table, population, unit, denominator and time. Each value must be labelled estimated vs assumed. Reject discordant DOIs, unread sources, filler references, AUDIT-to-grams without a bridge, and non-significant results called null. Do not average conflicting sources. (revision_critica §12.2 L362-366; microsim_respuestas §25 L615-658)
- Post-run publication scan before committing: mask quasi-identifiers in displayed output only and replace local paths. (handoff L8183, L8201-8202)

## 5. Hechos de ejecución

- Last full run, series 20260723: expand_pif 65/65 cells 2026-07-23 00:15:56-00:58:29 (~43 min; AAF cell 36.7 min on 12 workers, 1260 cells). expand_pif2 29/29 cells 00:59:35-14:08:36 (~13.1 h: grid 274 min, draws 289 min, injuries test 98 min, Table 5 62+64 min). Both gave artifact validation PASS (monitor log 2026-07-24 13:06). pif3 ran 2026-07-24 12:24-12:43. (handoff L7841-7887; expand_pif2 saved outputs)
- MC settings: n_sim 10000, n_pca 1000, seed 2125 (L'Ecuyer-CMRG, re-seeded per cell = common random numbers), prev_method dirichlet with Kish/design closures, fd_uncertainty TRUE (FALSE for injuries, RR_fd=1), x_vals seq(0.1,150,len=1500), IHD/IS age_scope 15_65 (Table 5 labelled 15_64).
- PIF grid: 45 output tables over 23 diseases (35 nohed, 4 cap IHD/IS, 6 explicit injuries) x 16 scenarios (10 conservative lambda=0 + 6 _rt lambda=1) x 7 waves (2012-2024 even) x 4 age groups = 20,160 rows; 8,400 applicable, 226 negative PIFs; Table 5 has 1,792 rows.
- Artifacts in micsim __andres_control stamped 20260723: aaf_engine_inputs_bundle, aaf_nested_by_disease, aaf_table5_result, 'Mortality Estimates WHO 2024_20260723.xlsx', pif2_pif_results_full, pif2_pif_audit_full, pif2_injuries_fulltest_results/checks, pif2_pif_results_table5_full, pif2_pif_audit_table5_full. Mortalidad/Matrices/YPLL_20260714.rds is tracked (stale).
- All synchronised draw files (aaf_synchronised_draws_who_adam_full 95 MB, aaf_..._table5_puc_full 8.5 MB, pif2_pif_synchronised_draws_full 508 MB, pif2_..._table5_full 119 MB, all 20260723) are gitignored and exist only in the old repo ACC1240138_private on DESKTOP-SGTV88L. expand_pif3 c14/c15/c49 fail without them.
- The July headless runner (run_notebook_logged.py, run_paf_draw_regeneration.ps1, monitor scripts, chunk_timings.jsonl, run folder manual_paf_pif_draws_20260723_001555) was not migrated, and Python is not installed here.
- DEIS: the 2012-2023 bundle was rebuilt 2026-10-05 with EDAD_TIPO==1 (1,328,981 rows; 15-65 = 368,030; 15-29 = 30,953, -5.5%; 1,826 infants removed). DEIS 2024 is byte-identical in the 09-06/15-09/29-09 releases (126,928 rows; mort24 = 31,806 rows aged 15-65). Only release 29092026 is present. AAF and draws are unaffected; deaths, attributable deaths and YPLL (15-29, LRI via P23) change.
- test_ypll_death_base.R currently fails as expected: 15 cells, max diff 3, all aged 15-29, 117,918 vs 117,944 (2026-10-05). test_hed_exit_knobs.R passed 2026-10-05. Registry tests (test_rr_registry_*) exist. test_aaf_unified.R and test_aaf_compute.R cannot run (missing ihd_is_binge_aaf.R). The renv battery was re-run 2026-10-05 with the same results.
- renv.lock pins 169 packages (PPM snapshot 2026-04-23); restore with renv::restore(prompt=FALSE).
- data_binge_sensitivity.rds.tar.xz.enc is written by expand_pif cell 6 (columns year, sexo, exp, edad_tramo, oh1, oh2, oh3, volajohdia, volajohdiams, cvolaj, cvolajms, hed, db) and read by microsim_base ms-apc-audit via acc_data since 2026-10-06. Any V1/V3 change means re-pack, check_bundles, commit, and re-run microsim_base/recalib.
- Design: 192 own-cell design factors + 32 fallback cells (2020 takes 2022). Join audit 100%. Kish neff is 21.6-47.4% of nominal; residual clustering x1.21-1.64.
- AAF=1 block: 97 rows, 2,628 deaths over the waves (145 in 2024); included in PAF totals, excluded from PIF.
- Saved standardized attributable mortality (Chile 2018 standard, 15-65): total 27.65 (2022) to 21.62 (2024); men 45.89 to 34.39. Unexplained.
- Headline history: published 14.6%/9.6% came from duplication; corrected 2026-05-28 run gave 7.45% (2008) / 4.68% (2022) of 15+ deaths, before the 15-65 rescope, the stomach/pancreas additions and the IHD/IS binge. These are not current numbers.
- _bib/references.bib has 17 entries (Shield 2025 DOI 10.1016/S2468-2667(25)00174-4; Shield 2020 DOI 10.1016/S2468-2667(19)30231-2; Gmel 2011 DOI 10.1186/1471-2288-11-48; Sherk 2017 InterMAHP; WHO-EURO 2025; Ruiz-Tagle 2025 (Addiction, under review) and 2026 PUHIP DOI 10.1016/j.puhip.2026.100798; Kilian 2023 DOI 10.1016/j.eclinm.2023.101996; Kilian 2025 DOI 10.1016/S2468-2667(25)00165-3; Araya 2018; PUC/SENDA 2018). There are no RR meta-analyses, PIF-methods, YLL or design-variance references.

## 6. Checks de validación

- Baseline reproduction gate (first, before any change): re-run expand_pif on current data and compare with the 20260723 series. Pass: AAF point/lower/upper in aaf_nested_by_disease identical (same seed and exposure); deaths differ only in 15-29 cells by the infant fix (~1,824). Any other difference is explained before proceeding. (revision_critica L254, L354; handoff L8162)
- V1 per-wave check: ratio of weighted per-capita mean (ltabs/fd = 0) to drinker mean of volajohdia is about 0.35-0.49 (past-month prevalence). Weighted per-capita volajohdia*365 equals APC*0.8 after the fix. Report db coding (NA vs 0) for ltabs/fd per wave. (expand_pif_cambios_hallazgos_2026-09-21.md L28-48)
- V2 sens_former_12m_2024.csv: AAF and attributable deaths by cause x sex x band under the 30-day vs 12-month definition. Pass/decision rule: no cause changes more than 5% relative, so keep and declare the definition; otherwise take it to ACC. (cambios_hallazgos L52-59)
- V3 hed_definition_audit.csv: per wave, the source item for db, % missing db among drinkers, HED among drinkers with missing excluded vs missing='no' next to SENDA (52.1/43.7/51.1/56.3/50.2/50.7/47.2), flag_audit_item, and max(db)/value distribution. Pass: no wave uses AUDIT 6+; gap to SENDA explained. (cambios_hallazgos L61-63)
- Item-missing audit (B1): rows dropped per year by filter(oh3<=30) and aux, and NA cvolaj among oh2=='30 dias'. Report the counts and the effect on p_current. (expand_pif cell 6)
- SENDA reproduction control: past-month prevalence 12-64 within 0.2-0.6 pp (done 2026-09-20); the pseudo-panel workbook control is exact to <=1e-5 pp for 2012-2020. Re-run after any exposure change. (microsim_respuestas Addendum 1 B; pseudopanel L634-637)
- Post-change battery (§7): EXPAND_PIF_ARTIFACT_VALIDATION=PASS; the same rows, causes, sex x age strata and years before and after; no new NA; AAF <=1; SHA-256 manifests regenerated; a before/after table by cause x sex with relative difference. Replace the 'PAF=PIF' item with PIF=(AAF-AAF_cf)/(1-AAF_cf) to 1e-9, baseline PIF exactly 0, and both(1,1)=0. (cambios_hallazgos §7 L142-148; handoff L6646-6648)
- validate_paf_draw_regeneration.R expand_pif and expand_pif2 (run from __andres_control with PIF_ARTIFACT_STAMP set). Pass: 23 diseases, 1260 WHO and 112 Table 5 AAF draw cells x 10000 finite, 20160/8400/11760 PIF rows, 1792 Table 5 rows, manifests matching. Structural only.
- test_ypll_death_base.R after the expand_pif re-run. Pass: every cell matches exactly (max |diff| = 0) and total deaths match. Re-derive the hard-coded 1188/117944/1260/72 constants rather than assume them. Then run build_ypll.R. (handoff L8196)
- Death bridge in pif2 c32: total deaths n = mort/AAF, max non-integer residual < 1e-6 over all cells, using the abs(aaf)>0 guard (IS and DM2 female negative cells retained). (handoff L6662-6666)
- Join guard: stopifnot(all(names(disease_filters) %in% unique(aaf_long$disease))) and rows == unique (year, sex, age, disease) keys in mortality_results. (handoff L5613-5617, L3309-3310)
- ICD disjointness: count death records with more than one partial flag set (expect 0), X65 in aaf1 not in int_inj, X45 not in poisonings, Road not inside Unintentional (unint_inj_noroad). (handoff L2650-2661, L4858-4893)
- AAF output checks: aaf_adam_rr_errors / aaf_error_log has 0 rows, no AAF > 1, no NA; inspect every upper == 1; grep the run log for 'Skipping' (expect 0). (handoff L904-950; aaf_unified.R L1866)
- pif3 checks after regeneration: 11/11 artifact checks, 1036 monotone ladders, joint draws reproduce cell limits to <=1e-12, the 23 diseases in PIF and YPLL match, ypll == yll_hmd. A fresh top-to-bottom run must succeed (fix B6 first). (handoff L7600-7684; expand_pif3 c14-c19)
- Registry tests test_rr_registry_{cancer,hhd,general,agebanded,injuries}.R under renv; update the [0,1] smoke criterion to (-Inf,1] for J-curve causes; test_hed_exit_knobs.R 57/57. Restore or remove the ihd_is_binge_aaf.R dependency so test_aaf_unified.R (27/27) can run. (handoff L1814-1824, L6776-6778)
- External plausibility: INE 15+ deaths 2022 = 135,274 vs data_mortality within 0.1%; the WHO GHO comparison uses the H/M ratio and the same standard; road men 2018 AAF about 0.34 with DEIS counts matching. (handoff L4127-4140, L3785-3834)
- Exposure handoff integrity: after re-packing data_binge_sensitivity, check_bundles [OK] and microsim_base ms-apc-audit re-runs (7 waves, 4 columns present). (_enpg/README.md L42; README.md L50-58)
- Publication scan before commit: no local absolute paths and no unmasked quasi-identifiers in saved outputs; the CI data-check passes (no plaintext microdata, no file >50 MB). (handoff L8201-8202; .github/workflows/data-check.yml)

## 7. Preguntas abiertas para el usuario

- Will the cloud session have ACC_DATA_KEY (e.g., as a secret)? If not, cloud work is limited to planning, code review, literature and synthetic tests, and every real-data run happens on DESKTOP_NDP_SGTV88L.
- Do you approve appending the handoff entry (2026-10-06 | DESKTOP_NDP_SGTV88L | Claude) recording the microsim_base acc_data change and the order expand_pif -> V1-V4 -> expand_pif again if needed -> notebooks 1-4 -> expand_pif2/3, and updating the README order?
- What was agreed with ACC at the 16-Sep meeting (D1-D3, 2016 PSU alignment, AAF=1 in PIF, YLL metric, 15-65/2012-2024 scope vs 15+/2008-2019)? Nothing can be treated as ACC-decided until you record it.
- How should corrections be delivered: new .R scripts and paste-ready cell patches (default), or do you grant explicit permission to edit expand_pif/2/3 directly?
- For V1, who signs the APC bridge choices (a)-(e): you, or ACC? Which APC series and source should replace the hard-coded values (2022/2024 reuse 7.9)?
- For V2 and V3: do you accept the 5% rule for the former-drinker definition, and should V3 (missing HED = 'no') apply to both expand_pif and expand_pif2?
- Should the 20260723 draw files (~730 MB in the old repo) be copied for a quick pif3 check, or regenerated? May the agent restructure pif2 into a single return_sims=TRUE pass (saves ~6 h)?
- Which IHD/IS RR is primary for the paper/ACC: WHO/Adam (male IHD plateau at 60-100 g/d) or Table 5 PUC? Should Table 5 stay as a sensitivity analysis even with degenerate IHD-F intervals until the covariance is found?
- Which YLL metric is primary (yll_hmd recommended; yll_gbd for comparability), and should the WPP sensitivity analysis actually be implemented?
- Should stomach/pancreatic cancer stay in the main estimate or move to the labelled WHO/IARC-scope sensitivity? And for ICD: strict sub-row (X30-39 out, current code) vs envelope; cervix excluded as 'no usable RR'?
- AAF=1 causes in the PIF: build a sub-model, or declare the PIF partial to the 23 RR causes?
- Which CI convention should be reported (fd_uncertainty=TRUE vs JRT-like), and should a sick-quitter RR_fd=1 bracket be added?
- Which lambda should be the headline for HED scenarios (0 conservative, 1 Ruiz-Tagle), with implied consumption shown?
- For ENPG 2020, should the design factor be borrowed from 2018 (same regime) instead of 2022, and should factors below 1 be floored at 1?
- Pin DEIS release 29092026 (ACC_DEIS_VERSION) for the closing runs?
- Is the PUHIP correction note / Ruiz-Tagle 2026 corrigendum part of this closing scope, or only expand_pif outputs for the microsim and ACC?
- For Kimi K3 Max: should each research prompt follow the §25 template (DOI plus page/table per value, verify named candidates first, one table per question), and should outputs be returned as a parameter-register table?

## 8. Contradicciones entre documentos

- The 2026-09-16 meeting script says mortality/PIF/YPLL are 'closed and validated'. The same-day critical review and the 2026-10-05 recovery note say an artifact PASS is not epidemiological validation, the YPLL cache is stale, and controls are pending. The review supersedes the script.
- The pending checks are 'V1-V3' in the handoff of 2026-10-05 but 'V1-V4' in the assistant message of 2026-10-06. V4 is moot because DEIS 2024 is byte-identical across releases, so V1-V3 is the operative gate.
- README and the handoff (2026-10-05) run microsim_base before expand_pif, but expand_pif writes data_binge_sensitivity, which microsim_base reads (_enpg/README L42).
- expand_pif_cambios_hallazgos §7 requires the identity 'PAF = PIF (eliminación total)'. The handoff of 2026-07-11 and pif2 c35 say PIF(shift->0) != AAF when RR_fd != 1 and that this check must not be used. The valid identity is PIF=(AAF-AAF_cf)/(1-AAF_cf).
- The task context offers Rscript via Git Bash, while several handoff entries (2026-06-02 to 2026-06-27) report segfaults under Git Bash and prescribe PowerShell.
- C2: the 2026-09-21 rule forbids mixing design regimes and proposes the 2018 DEFF for 2020. The code (from 2026-07-06) uses the 2022 factor (a different regime) as the fallback.
- C1/PSU 2016: the microsim and the 2026-09-20 answers say the PSU was rebuilt (2,358 blocks), but the expand_pif design cache still uses manzana (2,000 clusters; build_enpg_design_waves L189). The plan lists the alignment as awaiting ACC. The pseudo-panel handoff gives 2,356 vs 2,358 and 3,185 vs 3,175 cluster counts.
- Design strata: the documents disagreed on whether expand_pif declares 'strata = region' or no strata. The code map settles it: strata=REGION (revision_diseno_enpg_extension.R L69, L309-317).
- Former-drinker variance: 'recorded, not used' (2026-05-20/22) vs fd_uncertainty=TRUE in current expand_pif. rr_registry_adam.R L431 still hard-codes varLnRRFormer_used=FALSE in its audit.
- The 2026-05-15 'colorectal FD swap' correction was itself wrong: Adam's source equals JRT (M 2.19, F 1.05).
- Liver cancer RR in use (exp(0.003922071x), FD 2.23/2.68) matches neither InterMAHP/Corrao nor Shields as documented. The 2016 report FD (1.21/1.44) also differs from InterMAHP 1.54/2.28.
- Stomach/pancreatic: '06-01 parallel WHO-scope table, not main' vs '06-25 decision open' vs '06-30 kept in registry (user decision)'.
- X30-39/W47-48: same-day 2026-06-25 entries disagree on whether the notebook includes them. Current code has them commented out (strict sub-row).
- C11: the main pipeline excludes nasopharynx; the JRT cancer comparator includes C00-C14 on purpose. The oral/pharynx ICD split and labels changed three times (2026-05-20, 05-27, 06-16).
- Upper age: the plan uses 15-64 with band 60-64 and exit >64, while the code and the findings use 15-65 with band 60-65.
- Consumption categories: expand_pif cat1-cat4 (women cat3 40-100 in code, 40-60 in markdown and PIF-BINGE.R) vs the microsim contract cat1-cat3 with WHO cut-points.
- The plan accepts a '6+ drinks' HED harmonisation in older waves, while V3 says no wave may use the AUDIT 6+ item. The code uses the 30-day count only (2012+).
- Jul-15 said the DEIS mort21 parquet was clean; Oct-05 found 1,826 infants in it. Jul-15 says PIF changes imperceptibly from the age fix; Oct-05 says AAF and AAF/PIF draws do not change (cell PIF unchanged, aggregates change).
- pif2 c41 claims a WPP 2024 e0 sensitivity analysis; chile_e0_wpp2024 is never used in any script.
- pif3 captions and reporting notes describe aggregate intervals as cell-bound envelopes ('not jointly simulated'), while the code uses joint CRN draws.
- Codex reported expand_pif3 11/11 PASS on 2026-07-15; the notebook failed on 2026-07-20 (2 NA cells). The 20260723 artifacts have 0 NA, so this is superseded.
- 2022 weights 'do not affect prevalences/AAF' (findings §4.2) vs 'compression may slightly change prevalence (measurable)' (answers §12). The check cannot be run without pre-calibration weights.
- The expand_pif markdown says ENPG 2008-2022, AUDIT-C and a 150 g data cap; the code uses 2012-2024, the 30-day binge count, and 150 g only as the integration grid.
- SIMAH was described as 'vendored in SIMAH/supp' (script 2026-09-16, elasticity handoff), while AGENTS.md says it is not vendored. No folder exists, so AGENTS.md wins.
- The deck presentacion_micsim.qmd marks PAF/PIF/elasticity 'Completo' and mislabels ENPG as 'Encuesta Nacional de Presupuestos y Gastos'. These claims are provisional per AGENTS §2.

## 9. Clusters de literatura

### Survey-to-APC per-capita exposure correction

Decisiones: V1, Q1, C4, B14, D2

- In WHO GISAH/GSRAH, InterMAHP, GBD and Rehm/Kehoe triangulation, is survey consumption scaled so that the population per-capita mean (abstainers=0) equals a share of APC, or so that the drinker mean equals APC/prevalence? Give the exact formula with page/equation.
- What is the source and meaning of the 0.8 factor (unconsumed/spillage vs recorded share), and is it applied to total (recorded+unrecorded) APC?
- How should an APC defined for ages 15+ (national) be bridged to a 15-65 urban survey frame?
- What survey coverage rates (survey APC / sales APC) are reported internationally (Kilian 2020: 36.5%; Buckley 2022 BRFSS) and for Chile or Latin America?
- What are Chile's recorded, unrecorded and total APC series 2012-2024 (WHO GISAH, World Bank SH.ALC.PCAP.LI), and how reliable is the WHO 1.4 L unrecorded estimate vs the IJDP 2025 Delphi 0.05-0.5 L?
- Do upshift methods rescale the whole gamma (mean only) or also HED frequency, and in what order relative to capping?

Referencias ya en el proyecto:
- Rehm et al. 2010 Popul Health Metr (marked 'verificar')
- Kehoe et al. 2012 (PMC3352241)
- Kilian et al. 2020 (23 European countries coverage)
- Buckley et al. 2022 (BRFSS upshift)
- Sherk et al. 2017 InterMAHP guide (_bib/local/intermahp-guide.pdf)
- Shield et al. 2020 Lancet PH DOI 10.1016/S2468-2667(19)30231-2

### Drinking-status definitions and former-drinker RR

Decisiones: V2, Q5, Q6, Q22, Q25, B1

- How do the RR sources behind WHO 2024/GSRAHTSUD and InterMAHP define former drinkers (12 months vs 30 days vs lifetime) for each cause?
- What former-drinker RRs (and variances) are used for liver, colorectal, breast, oral/pharynx, larynx, IHD, DM2 and cirrhosis, and from which meta-analyses?
- What is the evidence on sick-quitter / reverse-causation bias in former-drinker RRs, and is a sensitivity analysis with RR_fd=1 standard practice?
- How stable is self-reported lifetime abstention across survey waves (Rehm 2008 AJE)?
- Do published AAF CIs propagate former-drinker RR uncertainty?
- In policy microsimulations (SIMAH/Kilian 2025, SAPM), are policy-induced quitters modelled as former drinkers or abstainers?

Referencias ya en el proyecto:
- Rehm et al. 2008 Am J Epidemiol (verify)
- Sherk 2017 InterMAHP
- Shields/Turati FD cancer RRs (_bib/local/Material supplementario Shields.pdf)
- Kilian et al. 2025 Lancet PH DOI 10.1016/S2468-2667(25)00165-3
- SIMAH release 0.1.1 DOI 10.5281/zenodo.15641639

### HED measurement, missing data and binge RR mapping

Decisiones: V3, B1, Q20, Q21, B19

- How should a 30-day count of 5+/4+ drink occasions be mapped to the >=60 g/occasion binge exposure assumed by the injury and IHD/IS binge RRs (Gmel/Shield/WHO-EURO 2025)? What standard-drink size (12 vs 15.6 g) should be used?
- Is excluding item-missing HED or treating it as 'no' (SENDA convention) the recommended practice for AAF inputs, and what bounding approaches exist?
- What is the evidence for two-component NHED/HED injury AAF formulas with p_hed defined among current drinkers (survey-weighted)?
- How do graduated quantity-frequency volume estimates incorporate binge occasions (valued at threshold vs actual quantity)?
- How do changes in recall windows (holiday exclusions) affect 30-day prevalence and volume comparability across waves?
- What do SENDA ENPG technical reports state about the HED item wording, sex-specific thresholds and the 2020 fieldwork mode?

Referencias ya en el proyecto:
- Gmel et al. 2011 BMC Med Res Methodol DOI 10.1186/1471-2288-11-48
- Ruiz-Tagle et al. 2025 Addiction (under review; ADD-25-1576)
- WHO/EURO 2025 alcohol injuries annex (WHO/EURO:2025-12985-52759-82187)
- Shield et al. 2025 Lancet PH DOI 10.1016/S2468-2667(25)00174-4
- Calvo et al. 2020 DOI 10.1016/j.drugalcdep.2020.108219

### Cause-specific RR sources: cardioprotection, IHD/IS choice and cause list

Decisiones: Q3, Q4, Q9, Q10, Q11, Q22, B5

- What is the current evidence on IHD and ischaemic stroke dose-response and cardioprotection (Roerecke & Rehm 2012; Zhao/Stockwell 2017 abstainer bias; Biddinger 2022 Mendelian randomisation), and should a no-protection sensitivity be reported?
- What functional forms and age bands do WHO 2024/GSRAHTSUD and InterMAHP 2018 use for IHD/IS, and where does the 60-100 g/d plateau/offset in the IHD male function come from?
- What are the PUC (Table 5) IHD/IS RR functions' original source and full covariance (Annex 2), and what does the 'Fact' column mean?
- How do WHO/GBD/InterMAHP report net (signed) AAFs with protective effects vs harmful-only AAFs?
- Is applying the hypertension RR (Liu 2020) to hypertensive heart disease mortality (I10-I15) standard?
- What is the causal evidence for stomach and pancreatic cancer (IARC vs WHO 2024) and for cervix cancer?
- Is mapping survey age groups onto RR age bands by majority overlap acceptable?

Referencias ya en el proyecto:
- Roerecke & Rehm 2012
- Zhao/Stockwell 2017 J Stud Alcohol Drugs
- Biddinger 2022 JAMA Netw Open
- Sherk/InterMAHP 2017 ('IS e IHD- sherk intermahp 2017.pdf')
- Liu 2020 (hypertension)
- Knott 2015 (DM2)
- Larsson 2016 (ICH)
- Rehm 2016 (published IHD)
- PUC/SENDA 2018 study (pucsenda2018estudio)
- Shield 2025 Table S6

### PIF counterfactual methods: AAF=1 causes, HED exit, former drinkers, negative PIF, latency

Decisiones: Q2, Q7, Q25, Q4, Q15

- How do InterMAHP, GBD, Sheffield SAPM and SIMAH compute counterfactual changes for 100%-attributable conditions?
- Is a 'risk-curve' volume counterfactual (RR evaluated at x*shift with fixed density) equivalent to scaling the exposure distribution, and which is standard?
- What do models assume for people who stop HED (remain drinkers at NHED volume vs keep volume), and is there a published source for the Ruiz-Tagle redistribution?
- How should former-drinker excess risk be treated under policy counterfactuals?
- Is reporting negative PIFs (J-curve causes) accepted, and how should they be aggregated?
- Should PIF-based avoided deaths be steady-state or time-lagged (cancer/cirrhosis latency vs injuries)?
- What is the accepted denominator: avoided deaths = total cause deaths x PIF?

Referencias ya en el proyecto:
- Kilian et al. 2025 Lancet PH DOI 10.1016/S2468-2667(25)00165-3 and supplement mmc1.pdf
- SIMAH 0.1.1 DOI 10.5281/zenodo.15641639
- Ruiz-Tagle et al. 2025 (PIF HED injuries)
- Sherk 2017 InterMAHP
- Purshouse 2013 Alcohol Alcohol (PMID 23015608)

### YLL/YPLL definitions and life-table authority

Decisiones: Q8, B20

- Life-table YLL (remaining life expectancy at age of death) vs reference-age YPLL (max(e0-age,0)): which is recommended for alcohol-attributable burden, and what are the known biases of e0-age for older deaths?
- When should a national period life table (HMD Chile) be used vs the GBD 2019 TMRLT (DOI 10.6069/1D4Y-YQ37)?
- How do Kilian 2025 and Lemp 2026 define YLL (horizon to 75?)?
- How large are discrepancies between HMD, INE and UN WPP 2024 life expectancy for Chile 2012-2024, and how should they be handled in sensitivity analyses?

Referencias ya en el proyecto:
- GBD 2019 TMRLT DOI 10.6069/1D4Y-YQ37
- HMD Methods Protocol v6
- UN WPP 2024
- Lemp et al. 2026 JAMA Health Forum DOI 10.1001/jamahealthforum.2026.2348
- Kilian et al. 2025 DOI 10.1016/S2468-2667(25)00165-3

### Survey-design variance and Monte Carlo uncertainty

Decisiones: C1, C2, Q13, Q15, Q5, B5, B12

- Is combining Kish effective n with a (SE_design/SE_Kish)^2 clustering factor an accepted way to propagate complex-survey uncertainty into prevalence draws (Dirichlet/Beta) for AAF/PIF?
- How should a wave without cluster IDs be handled (borrow DEFF from a same-frame wave, pseudo-PSU upper bound)?
- Should net design factors below 1 be floored at 1?
- Are common random numbers across causes/strata an acceptable basis for joint intervals of summed attributable or avoided deaths, and how should Monte Carlo error be reported (ISPOR-SMDM TF6)?
- How do published AAF CI methods (Gmel 2011) handle RR covariance when only marginal SEs are available?

Referencias ya en el proyecto:
- Gmel et al. 2011 DOI 10.1186/1471-2288-11-48
- ISPOR-SMDM Task Force 6 (uncertainty) and 7 (transparency/validation), Value Health 15(6)

### Scope: age range, urban frame, ICD mapping and wave comparability

Decisiones: D1, D2, D3, Q12, Q20

- How do national AAF studies handle ages 65+ when exposure surveys stop at 64/65 (extrapolation, carry-forward, external surveys)?
- Does Calvo et al. 2021 (Addiction, doi:10.1111/add.15292) support an age-ratio bridge for 66-76?
- What evidence exists on urban vs rural drinking in Chile, and how do studies justify applying urban survey exposure to national deaths?
- What exactly does Shield 2025 Table S6 and supplement specify for injury envelopes (row 1520 vs 1590), X45/X65/Y15 and alcoholic cardiomyopathy I42.6?
- What do SENDA technical reports document on the 2022 frame and calibration change and 2020 fieldwork, and how should multi-wave AAF trends treat these breaks?

Referencias ya en el proyecto:
- Shield et al. 2025 Lancet PH DOI 10.1016/S2468-2667(25)00174-4 (Table S6 PDF in _bib)
- Calvo et al. 2021 doi:10.1111/add.15292
- Castillo-Carniglia 2013 thesis (castillo2013tesis)
- Ruiz-Tagle et al. 2026 PUHIP DOI 10.1016/j.puhip.2026.100798
