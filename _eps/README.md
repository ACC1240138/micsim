# _eps — Social Protection Survey (EPS)

**Encrypted** microdata in `eps.tar.xz.enc` (115 `.dta` files, inner folder `eps/`, same folder structure as the original). Read them with `acc_data()`:

```r
source(here::here("_tools", "acc_data.R"))
eps_root <- acc_data("_eps/eps.tar.xz.enc")   # decrypted eps/ folder in tempdir()
```

`eps.tar.xz.enc.md5.csv` lists every file with its size and md5 (the same as the originals).

## Rounds

Field dates and sample sizes follow `__andres_control/eps_alcohol_prevalencia_persistencia_informe.md` (§2) and each round's reports (in `docs/`).

| Folder in the bundle | Round | Fieldwork | Living respondents | Note |
|---|---|---|---|---|
| `2012/` (21 files) | V | — | 15,998 records | No F13–F15 (alcohol) in the delivered files; the official dossier advises against statistical inference with this round (p. 23) |
| `2015/` (17) | VI | March–August 2016 | 16,906 | Modules A/F and `factor_EPS2015`; no public PSU/strata |
| `Bases y Documentos EPS 2020/2020/` (38) and `Factores de Expansion EPS 2020/` (10) | VII | in person 2019-12-14 to 2020-03-22; telephone (continuity and re-interview) second half of 2020 | in person 7,800; continuity 5,031; re-interview 2,082 | No refresh sample: weights calibrated to 23+. The telephone survey measures "less/same/more than usual". The re-interview overlaps the in-person sample: do not add the three files |
| `Bases de datos EPS VIII Ronda/` (29: `BBDD_VIVOS` 19, `BBDD_FALL` 3, `BBDD_PSD` 3, `FACT_EXP` 4) | VIII | 2023-10-11 to 2024-06-10 | 15,788 | Refresh sample, 18+ coverage, cross-sectional and panel weights, PSU/strata. "2023" does not mean interviews only in 2023 |

## Documents (`docs/`, plain)

PDFs, codebooks and dictionaries, with the same internal structure as the original:

- `2012/`: results dossier, expansion factors, technical guide, reports (Casas, Heeringa, Marshall, STATCOM supervision).
- `2015/instrucciones/`: questionnaires, fieldwork reports, imputation, factors and user manual.
- `Bases y Documentos EPS 2020/`: codebooks (`.xlsx`), user guide, fieldwork, imputation, coding and methodology reports, and the VII-round questionnaires.
- `Bases de datos EPS VIII Ronda/Diccionario de variables VIII EPS.xlsx` and `Documentos EPS VIII Ronda/` (final and technical reports, fieldwork, data treatment, booklets).

## Notes (`notes/`)

Text extractions of those PDFs (`tmp/eps_audit/*.txt`, numbered) and `calvo_refinement.md`.
