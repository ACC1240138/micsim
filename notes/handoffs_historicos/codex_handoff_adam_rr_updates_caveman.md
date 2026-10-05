# Codex handoff caveman: Adam RR updates for AAF pipeline

Date: 2026-05-20

This note is for another Codex session, probably on another computer. It explains what was discussed and what was changed in the AAF pipeline after receiving updated RR objects from Adam.

## Big picture

We had an existing R/notebook pipeline that calculates alcohol-attributable fractions (AAFs). The old pipeline used older RR functions and coefficients.

Adam provided updated RR objects, mainly in:

- `__andres_control/GENERAL_chronic_RR_2024_08_23.R`

The goal was not to rewrite the whole AAF pipeline. The goal was:

1. Load Adam's RR objects in a controlled registry.
2. Replace only selected disease tables progressively.
3. Keep a clear audit trail of which RR source was used.
4. Test heavily before trusting the new outputs.
5. Do not yet propagate former-drinker RR uncertainty into confidence intervals.

## Main files touched

- `__andres_control/rr_registry_adam.R`
- `__andres_control/test_rr_registry_cancer.R`
- `__andres_control/test_rr_registry_hhd.R`
- `__andres_control/revision_datos.ipynb`

## New Adam RR registry

A new module exists:

- `__andres_control/rr_registry_adam.R`

Important functions:

- `load_adam_rr_registry(scope = "cancer")`
- `load_adam_rr_registry(scope = "hhd")`
- `validate_adam_rr_registry(registry)`
- `adam_rr_registry_metadata(registry)`
- `compute_aaf_from_rr_record(...)`
- `compute_cancer_aaf_from_registry(...)`
- `compute_hhd_aaf_from_registry(...)`

The registry loads Adam objects from `GENERAL_chronic_RR_2024_08_23.R` into private environments and normalizes them into auditable records.

Each record keeps at least:

- `disease`
- `pipeline_disease`
- `sex`
- `source_file`
- `source_object`
- `RRCurrent`
- `betaCurrent`
- `covBetaCurrent`
- `lnRRFormer`
- `varLnRRFormer`

Some records also keep:

- `rr_shared_group`
- `rr_shared_rr_note`
- `rr_endpoint`
- `source_note`
- `pipeline_icd10`

## Former drinker uncertainty

Important: we are not using `varLnRRFormer` in the confidence intervals yet.

Current behavior:

- The former-drinker RR used in the AAF is fixed as `rr_form = exp(lnRRFormer)`.
- `varLnRRFormer` is stored in audit.
- Audit column `varLnRRFormer_used` is `FALSE`.

Reason:

- Adding former-drinker RR uncertainty would require changing the CI logic.
- That has not been implemented yet.

## CI logic for Adam current-drinker RR

`compute_aaf_from_rr_record()` decides which CI helper to use based on Adam's `betaCurrent` and `covBetaCurrent`.

Current behavior:

- If one coefficient is active/uncertain, use `confint_paf_parallel()`.
- If more than one coefficient is active/uncertain, use `confint_paf_vcov_parallel()`.
- Always reconstruct the full `betaCurrent` vector, so formulas using positions like `beta[2]`, `beta[3]`, or `beta[4]` keep working.
- Normalize output names to `point`, `lower`, `upper`.
- Report explicit errors. Do not silently swallow failures with `error = function(e) NULL`.

## Cancer updates already implemented

The notebook now overwrites the old cancer AAF tables before the final `bind_rows()`.

Updated from Adam:

- `oescan_female`
- `oescan_male`
- `crcan_female`
- `crcan_male`
- `lican_female`
- `lican_male`
- `lxcan_female`
- `lxcan_male`
- `bcan_female`
- `locan_female`
- `locan_male`
- `opcan_female`
- `opcan_male`

Disease mapping:

- Oesophagus Cancer uses Adam `Oesophagus_Cancer`.
- Colon and rectum Cancer uses Adam `Colorectal_Cancer`.
- Liver Cancer uses Adam `Liver_Cancer`.
- Larynx Cancer uses Adam `Larynx_Cancer`.
- Breast Cancer uses Adam `Breast_Cancer`, female only.
- Lip and oral cavity Cancer uses Adam `Oral_Cavity_and_Pharynx_Cancer`.
- Other pharynx Cancer also uses Adam `Oral_Cavity_and_Pharynx_Cancer`.

## Important locan/opcan decision

Adam provides a combined RR:

- `Oral_Cavity_and_Pharynx_Cancer`

The pipeline has two separate output causes:

- `locan`: Lip and oral cavity Cancer
- `opcan`: Other pharynx Cancer

Decision:

- Keep `locan` and `opcan` as separate output tables.
- Use the same Adam combined RR for both.
- Record this explicitly in `aaf_cancer_rr_audit`.

Audit fields include:

- `rr_shared_group`
- `rr_shared_rr_note`

Expected note idea:

`locan` and `opcan` are separate pipeline outputs but share Adam's combined `Oral_Cavity_and_Pharynx_Cancer` RR.

## HHD / hypertension update already implemented

At first HHD was not overwritten because Adam's source object is named around hypertension, while the pipeline output is Hypertensive Heart Disease.

User then decided: overwrite it.

Implemented now:

- `hhd_female` is overwritten.
- `hhd_male` is overwritten.

Adam source objects:

- `hypertension_female`
- `hypertension_male`

Pipeline disease:

- `Hypertensive Heart Disease`

RR endpoint:

- `Hypertension`

ICD mapping recorded:

- `I10-I15`

Reasoning recorded in audit:

- The RR endpoint is hypertension from Liu et al. 2020 via Adam.
- It is applied to the HHD pipeline cause because Shields/GHE maps hypertension RRs to Hypertensive Heart Disease (`I10-I15`).

Important audit objects:

- `aaf_hhd_rr_audit`
- `aaf_hhd_rr_errors`
- `aaf_adam_rr_audit`
- `aaf_adam_rr_errors`

`aaf_adam_rr_audit` combines cancer + HHD audit.

## Notebook integration

The key cell is in:

- `__andres_control/revision_datos.ipynb`

Label:

- `mort-trends-age-sex-chile6b-adam-rr-overrides`

This cell sits before the final `bind_rows()` of AAF tables.

It does this:

1. Sources `rr_registry_adam.R`.
2. Loads `scope = "cancer"`.
3. Loads `scope = "hhd"`.
4. Validates both registries.
5. Runs smoke tests with smaller `n_sim`.
6. Runs full Adam overrides.
7. Uses `list2env(...)` to overwrite the existing table objects in `.GlobalEnv`.
8. Creates audit and error objects.
9. Validates that updated tables have finite values and `0 <= lower <= point <= upper <= 1`.
10. Creates `adam_rr_upper_eq_1`, plus cancer/HHD subsets, to inspect suspicious intervals where upper equals 1.

Important: this is an overwrite before `bind_rows()`. It is not just a side calculation.

## Text inserted in notebook

There is a markdown cell after the Adam override cell:

Heading:

`#### Correction provided by Adam`

It says, in substance:

- Cancer AAFs were updated using Adam's RR registry for oesophagus, colorectal, liver, larynx, female breast, lip/oral cavity, and other pharyngeal cancer.
- `locan` and `opcan` remain separate outputs but share Adam's combined `Oral_Cavity_and_Pharynx_Cancer` RR.
- HHD AAFs were overwritten using Adam's `hypertension_male` and `hypertension_female`.
- Hypertension RR endpoint is applied to HHD because Shields/GHE maps hypertension RRs to `I10-I15`.
- Former-drinker RR uncertainty is recorded but not propagated into CIs yet.

## Things intentionally not updated yet

Do not assume the entire pipeline is Adam-updated.

Not updated yet:

- IHD
- injuries
- HED/binge components
- former-drinker RR uncertainty in CIs

IHD is explicitly for later.

`RRCurrent_binge` / `RRCurrentbinge` was interpreted as HED, meaning heavy episodic drinking. It has not been integrated yet.

Age-group issue noted:

- Some Adam/HED structures may use 3 groups: 15-34, 35-64, 65+.
- The current pipeline uses 4 groups: 15-29, 30-44, 45-59, 60+.
- This needs careful mapping before using HED/binge RR in the pipeline.

## Tests

Cancer test:

- `__andres_control/test_rr_registry_cancer.R`

HHD test:

- `__andres_control/test_rr_registry_hhd.R`

Commands run successfully:

```powershell
& 'C:\Program Files\R\R-4.4.1\bin\Rscript.exe' '__andres_control/test_rr_registry_cancer.R'
& 'C:\Program Files\R\R-4.4.1\bin\Rscript.exe' '__andres_control/test_rr_registry_hhd.R'
python -m json.tool '__andres_control/revision_datos.ipynb' | Out-Null
```

Observed results:

- `All rr_registry_adam cancer tests passed.`
- `All rr_registry_adam HHD tests passed.`
- Notebook JSON validated.

## What cancer tests check

The cancer tests check:

- All records have required fields.
- `length(betaCurrent)` matches `dim(covBetaCurrent)`.
- covariance matrices are symmetric.
- covariance diagonals are non-negative.
- `RRCurrent(x, betaCurrent)` is finite and non-negative at test values.
- Registry RR values match Adam source object RR values.
- Smoke AAF calculation works with small `n_sim`.
- Smoke results are finite and between 0 and 1.

## What HHD tests check

The HHD tests check:

- Registry has only the expected HHD records.
- `pipeline_disease == "Hypertensive Heart Disease"`.
- `rr_endpoint == "Hypertension"`.
- `pipeline_icd10 == "I10-I15"`.
- RR functions match Adam source objects.
- Smoke AAF calculation works for `hhd_female` and `hhd_male`.
- Audit records the hypertension-to-HHD mapping.
- Smoke results are finite and between 0 and 1.

## Practical next steps

Next Codex should not restart this from zero.

Recommended next steps:

1. Run the Adam override cell in the notebook.
2. Inspect `aaf_cancer_rr_audit`.
3. Inspect `aaf_hhd_rr_audit`.
4. Inspect `aaf_adam_rr_errors`; it should be empty.
5. Inspect `adam_rr_upper_eq_1`; any `upper == 1` should be investigated.
6. Compare updated outputs against AGS/JRT, but mark these causes as `inputs/formula changed`.
7. Handle IHD separately later.
8. Handle injuries separately later.
9. Do not add former-drinker uncertainty to CIs until the CI functions are deliberately redesigned.

## Short caveman summary

Adam gave new RR.

We made registry.

Cancer tables now overwritten before final bind.

`locan` and `opcan` stay separate, but use same Adam oral/pharynx RR.

HHD now overwritten too, using Adam hypertension RR.

Audit records all of it.

Former drinker uncertainty saved, not used yet.

IHD and injuries wait.

Tests pass.
