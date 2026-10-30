# DIR inputs for review

Prepared on 29 October 2026 and transferred into the repository. Aggregate data are packaged in encrypted bundles; the DIR module has not been integrated into the model. Source REM ZIP files remain outside the repository and are not included here.

## Contents

- `rem.tar.xz.enc`: REM Series A and P extracts for 2019–2024, including 2020. Each `.csv.gz` retains the original header, all 57 columns, selected rows, blanks and duplicates. Fields are semicolon-delimited; preserve codes as text. Each file covers one year and one series.
- `codebook/`: original SA and SP dictionaries extracted from the corresponding annual ZIP files. Check code definitions and column mappings for each year.
- `fonasa.tar.xz.enc`: APS enrolment in September 2022 (ZIP) and December 2023 (CSV), and 2022 beneficiaries (ZIP). Their reference dates and populations differ. A–D has not been shown to mean validated enrolment; the meaning of X is unresolved.
- `est/`: DEIS facility catalogues for 2019–2024 and the 2024 dictionary. Facility level does not establish participation in DIR.
- `doc/`: manuals, P-series workbook, specifications and independent review. The earlier [v7 mapping](../__andres_control/dir_rem_mapeo_metricas_2026-10-16.md) is historical; v8 remains a proposal. Copied documents may retain links relative to their original locations.
- `preparar_extractos.py` records the extraction procedure and selected codes. It expects the original annual ZIPs in the parent of this folder and writes files locally; those ZIPs are not included in the repository. `controles_rem.json` records SHA256 hashes, source members and CRCs, counts, months, national sums and absent requested codes. Blanks are treated as zero for control sums only; extracts retain the original blanks. `MANIFEST_SHA256.csv` records the original pre-packaging delivery, including ignored plaintext copies; use the bundle `.md5.csv` sidecars to verify the encrypted inputs.

## Reading the encrypted inputs

From the project root, with `ACC_DATA_KEY` configured:

```r
.t0 <- Sys.time()
source(here::here("_tools", "acc_data.R"))
rem_dir <- acc_data("_dir/rem.tar.xz.enc")
fonasa_dir <- acc_data("_dir/fonasa.tar.xz.enc")
rem_2024_a <- file.path(rem_dir, "REM_2024_A.csv.gz")
inscritos_2023 <- file.path(fonasa_dir, "Inscritos APS 2023 12.csv")
message("Elapsed minutes: ", round(as.numeric(difftime(Sys.time(), .t0, units = "mins")), 2))
```

`acc_data()` extracts into a session temporary directory; no plaintext copy in the repository is required. The local `_dir/rem/` and `_dir/fonasa/` folders are ignored and are not included in a clone. The two bundles and their `.md5.csv` sidecars must be versioned together. Bundle and sidecar sizes were checked below 50,000,000 bytes, and all 15 files passed a decrypt-and-MD5 round trip.

## Original REM ZIP files and provenance

The source is Chile's Ministry of Health, Department of Health Statistics and Information (DEIS), [health information systems](https://deis.minsal.cl/sistemas/). The annual original archives used for these extracts are:

- [SERIE_REM_2019.zip](https://repositoriodeis.minsal.cl/DatosAbiertos/REM/SERIE_REM_2019.zip), [2020](https://repositoriodeis.minsal.cl/DatosAbiertos/REM/SERIE_REM_2020.zip), [2021](https://repositoriodeis.minsal.cl/DatosAbiertos/REM/SERIE_REM_2021.zip), [2022](https://repositoriodeis.minsal.cl/DatosAbiertos/REM/SERIE_REM_2022.zip), [2023](https://repositoriodeis.minsal.cl/DatosAbiertos/REM/SERIE_REM_2023.zip) and [2024](https://repositoriodeis.minsal.cl/DatosAbiertos/REM/SERIE_REM_2024.zip).

These URLs were recovered from the original files' Windows download metadata. An independent review on 29 October 2026 reported that the server sizes matched the local 2019–2024 files; remote content hashes were not compared. The source ZIP SHA256 hashes, exact member names and CRCs of the copies actually used are recorded in `controles_rem.json`. Files at these URLs can be revised: compare SHA256 before assuming a newly downloaded ZIP reproduces the extracts. Original download dates are not established. The original archives each exceed 50,000,000 bytes and are kept outside the repository.

To regenerate, obtain the matching archives separately, verify each SHA256 against `controles_rem.json`, and run `preparar_extractos.py` with those archives in the parent folder of `_dir`. The script writes extracts and dictionaries, so run it on a working copy to avoid overwriting reviewed files. Gzip metadata can differ between runs even when decompressed rows match. For ordinary use, read the archived extracts with `acc_data()` above; source ZIPs are not required.

## Scope and limitations

Series A includes selected codes from A03 D.1, A27, A02, A05 and A07. Series P includes identified P6 codes and predecessors; verify historical mappings and labels against the dictionaries. Rows refer to facility, month and service, not unique people. A27 does not provide an age-by-sex cross-tabulation. Ratios of interventions to screening results are not individual probabilities. The specification records proposed 2024 inputs and the provisional 11.7% modelling assumption.

The local REM 2025 copy was excluded: the independent review found an incomplete final record, and DEIS published a newer version. The [2025 ZIP](https://repositoriodeis.minsal.cl/DatosAbiertos/REM/SERIE_REM_2025.zip) and [2026 ZIP](https://repositoriodeis.minsal.cl/DatosAbiertos/REM/SERIE_REM_2026.zip) identified by HEAD exceed 50 MB and were not downloaded. Check the source weekly and record date, size, ETag and hash; the publication frequency of ZIP files remains unconfirmed. Check content, completeness and dictionaries before incorporating either version.

Deaths, relative risks, DEIS and HMD life tables belong to other project modules. This delivery does not contain a mortality model or calculate YLL or YPLL. The truncated 2023 nominal beneficiary file is excluded.

## Before using or updating

Review the selection, labels, controls and v7/v8 decisions. Every file must be strictly smaller than 50,000,000 bytes. Measure each new encrypted bundle and sidecar separately, then verify decryption in `tempdir()` and hashes before replacing anything. Keep public documentation, dictionaries and publishable aggregate results in plain text; handle derived extracts according to project policy.
