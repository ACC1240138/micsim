# CASEN inputs for ENPG composition and health-contact exploration

These encrypted bundles preserve the source files used by
`__andres_control/enpg_casen_aps.ipynb`. Read them only through
`_tools/acc_data.R::acc_data()`. Each bundle has a plain MD5 sidecar.
Original local files were preserved; each new bundle was restored and its MD5
compared with its source before analysis.

## Reduced 2017 and 2024 inputs

The original encrypted 2017 and 2024 ZIP bundles exceeded the repository CI
limit of 50 MiB. They were replaced by encrypted subsets for the ENPG–CASEN
pipeline; the observations, order, missing values, survey weights, design
variables and variable labels used by that pipeline are preserved. The subset
is not a general-purpose replacement for the complete CASEN survey. To use
other variables, obtain the full source and rebuild the subset with the required
variables, then revalidate the affected analyses.

| Year | Original ZIP MD5 | Original encrypted bundle MD5 | Reduced data | Reduced RDS MD5 |
|---|---|---|---|---|
| 2017 | `e3a753aafc68a7f4101ef811aa5d9c37` | `fbbb8cd1d5cf763088b3023f5fd7e960` | `casen_2017_eca.rds.tar.xz.enc` (216,439 rows, 16 variables) | `c832d06da10e91d861b7631910e2b4f8` |
| 2024 | `e173d2f5aa0bffef8d9bdf5259cea128` | `0f80b6af673e389ce91a5f64af219614` | `casen_2024_eca.rds.tar.xz.enc` (218,367 rows, 17 variables) | `87850e0635a4fcc8991ce26bb08bed59` |

The reduction retains the union of the columns selected by `eca_casen_read()`
for education, health and rurality, including person linkage keys and the
original PSU, stratum and weights. It does not filter observations. The script
compares the original and reduced reader outputs exactly for all four
health/rural combinations in each year, including attributes. CASEN 2013,
2015, 2020 and 2022 and the separate geography and revised-weight files are
unchanged. `casen_sources.csv` records the full source hashes from the original
analysis and is retained as historical provenance.

To reproduce, restore the two original **encrypted** bundles and their sidecars
from Git commit `b6a3122` into `_casen/`, or supply identical source files;
the original ZIP MD5 values above must match. For example, from the repository
root, this writes only encrypted files and sidecars:

```powershell
@'
from pathlib import Path
import subprocess
names = ['casen_2017_dta.zip.tar.xz.enc', 'casen_2024stata.zip.tar.xz.enc']
for name in names:
    for suffix in ('', '.md5.csv'):
        path = '_casen/' + name + suffix
        Path(path).write_bytes(subprocess.check_output(['git', 'show', 'b6a3122:' + path]))
'@ | python -
Rscript _casen/reduce_casen_bundles.R
```

The script uses `acc_data()` and `acc_pack()`, decrypts only into the R session's
temporary directory, verifies each original ZIP MD5 and compares all four reader
configurations. If the reduced files already exist it validates them without
overwriting; otherwise it creates them with MD5 sidecars. Encryption uses a
random salt and IV, so encrypted-file hashes change across regenerations even
when the decoded RDS is identical. The original large bundles should be removed
from the working tree after verification to satisfy CI; retain a separate
encrypted backup if required. Current full-source backups are local and untracked.

Education uses CASEN 2013, 2015, 2017, 2020, 2022 and 2024. The 2013/2015
`expr_c2017_nm` files replace the old expansion factors through a checked
one-to-one join on `folio + o`. The education rule is reused from
`__andres_control/casen_educ3_insumo.R`; its old local-path configuration is
not executed. The source bundles came from the user's existing CASEN folder.
Their original download dates/versions were not independently established;
sidecar hashes identify the exact files used.

Health exploration processes all six rounds, 2013–2024. Official geography
files were downloaded on 2026-10-26; [geography_sources.csv](geography_sources.csv)
records the 2013–2022 URLs, hashes and row counts. The 2024 source is linked below.
Joins use `folio + o` through 2017 and `folio + id_persona` from 2020 onward,
with duplicate and unmatched-row checks. Region rates use the revised 2013/2015
`expr` weights and later `expr`; commune estimates use official `expc`.
Old Ñuble codes are harmonized to the INE commune grid through official labels.
PSU `varunit` and stratum `varstrat` stay unchanged; no geography-derived design
variables are invented.

2020 lacks the comparable general-care/provider items. Its separate illness/
accident consultation indicator includes every sector. Only 2013/2015/2017 can
identify consultorio/posta for general care or control; 2022/2024 distinguish
public/private sectors, not APS. Reference periods are preserved in outcome names.

Sources:

- [CASEN 2024 and documentation](https://observatorio.ministeriodesarrollosocial.gob.cl/encuesta-casen-2024)
- [Official geography file](https://bid-ckan.ministeriodesarrollosocial.gob.cl/dataset/105286d9-10a8-410a-b060-a335f3168a46/resource/8a8136a7-a842-47fc-8c2f-50806131645a/download/casen_2024_provincia_comuna.dta)
- [2024 linkage and data-use note](https://observatorio.ministeriodesarrollosocial.gob.cl/storage/docs/casen/2024/Nota_uso_bases_de_datos_Casen_2024.pdf)
- [2024 sampling design and commune expansion factor](https://observatorio.ministeriodesarrollosocial.gob.cl/storage/docs/casen/2024/Diseno_Muestral_Casen_2024.pdf)
- [2017 investigator manual: health reference periods](https://observatorio.ministeriodesarrollosocial.gob.cl/storage/docs/casen/2017/Manual_del_Investigador_Casen_2017.pdf)

No direct commune estimate is automatically approved for the microsimulator.
The 2024 health questions distinguish public/private care, not APS/hospital.
The 2013/2015/2017 APS indicators concern the last recorded establishment for general
consultation and health controls, not all possible contacts with APS.

The official 2015 geography file has `expc` only for 139 communes (52,770
sample records lack this weight). Other communes receive no direct commune
estimate; they remain represented in the national/regional analysis. For commune
variance estimation the full-sample PSU/stratum structure is retained, and
records without an official commune weight are excluded as a domain before
estimation. A computational placeholder outside that domain never contributes
to any estimate or denominator. Historic commune weights retain their original
census base; they are not relabelled as updated Censo-2017 regional weights.
See the [official 2015 sampling report](https://observatorio.ministeriodesarrollosocial.gob.cl/storage/docs/casen/2015/Metodologia_de_Diseno_Muestral_Casen_2015.pdf).
