# micsim — FONDECYT 1240138

Microsimulation of alcohol policies in Chile: alcohol-attributable mortality (PAF/AAF, YPLL), policy counterfactuals (PIF), price elasticities (EPF) and simulation. The repository holds the working notebooks, the scripts they load, their recent aggregate results, and the project guidelines (`AGENTS.md`).

The **microdata** (ENPG, EPS, DEIS, EPF) are in the repository **only in encrypted form**, never as plain text.

**Setting up a new computer:** follow [INSTALL.md](INSTALL.md) (clone, `renv::restore()`, data key, checks).

## Data and key

Bundles are `*.tar.xz.enc` files (tar.xz + AES-256-CTR + HMAC-SHA256), each with a `*.md5.csv` sidecar (file names, sizes and md5; no data). The key is the environment variable `ACC_DATA_KEY`:

1. Ask the team for it (or recover it from the password manager).
2. Add it to `~/.Renviron` with `usethis::edit_r_environ()` (`ACC_DATA_KEY=...`) and restart R.
3. Check it without printing it: `nzchar(Sys.getenv("ACC_DATA_KEY"))`.

The key must **never** go into files, onto a command line or into a chat. On GitHub it lives as a repository secret.

All data access goes through `_tools/acc_data.R` (`source(here::here("_tools", "acc_data.R"))`): `acc_data()` decrypts a bundle once per session into `tempdir()`, `acc_deis()` returns DEIS 2024 onwards, and `acc_pack()` writes a new bundle. Intermediates derived from microdata are written with `acc_pack()`, never as plain files inside the repo.

| Folder | Contents | Details |
|---|---|---|
| `_enpg/` | ENPG 2008–2024 and derived inputs | [README](_enpg/README.md) |
| `_eps/` | EPS 2012–2023 | [README](_eps/README.md) |
| `_deis/` | DEIS deaths 2012–2023 and 2024+ | [README](_deis/README.md) |
| `_epf/` | EPF (harmonised cache and raw INE files) | [README](_epf/README.md) |
| `_bib/` | Encrypted reference PDFs and `references.bib` | [README](_bib/README.md) |
| `_sessions/` | Encrypted Claude Code chat transcripts | see below |
| `jrt/` | Reference code and outputs from the JRT team | [README](jrt/README.md) |
| `notes/` | Historical (non-canonical) handoffs | — |
| `__andres_control/` | Notebooks, scripts, artefacts and outputs | — |

## R packages

R ≥ 4.4. Core (data loader and tests): `openssl`, `data.table`, `nanoparquet`, `arrow`, `haven`, `here`, `jsonlite`.

The notebooks also use: `dplyr`, `tidyr`, `purrr`, `tibble`, `stringr`, `forcats`, `tidyselect`, `readr`, `readxl`, `writexl`, `rio`, `janitor`, `ggplot2`, `scales`, `gridExtra`, `patchwork`, `htmltools`, `DT`, `knitr`, `IRdisplay`, `quarto`, `survey`, `sandwich`, `MASS`, `mvtnorm`, `fitdistrplus`, `gtools`, `MicSim`, `digest`, `withr`, `rvest`, `xml2`, `zip`, `IRkernel` and `devtools` (the latter only for the session information). The list comes from the package vectors in each notebook; most notebooks report a missing package at the start.

## Reproducible R environment (renv)

`renv.lock` pins the **exact versions** of 169 packages (those in `DESCRIPTION` plus their dependencies) and the repository: a **dated** Posit Package Manager snapshot (`https://packagemanager.posit.co/cran/2026-04-23`). The environment is therefore the same today as a year from now.

- **In a clone:** start R in the repository root or in any folder with R code, with any tool (Positron, Jupyter, `Rscript`; in RStudio open `micsim.Rproj`): `.Rprofile` activates `renv` automatically. Run `renv::restore()` (the first time from the Positron console or a terminal, see [INSTALL.md](INSTALL.md)), then `Rscript _tools/test_acc_data.R`.
- **How renv activates:** R runs only the `.Rprofile` of the folder it starts in. The root `.Rprofile` activates `renv` with the canonical project path (Positron starts R in `c:/…`, which would otherwise give a second, empty library); every folder with R code has an identical stub `.Rprofile` (a copy of `_tools/.Rprofile`) that runs the root one. A new folder with R code needs a copy of the stub. If `.libPaths()` shows no `renv` path, R started in a folder without `.Rprofile` (outside the repository, or a folder without R code such as `_enpg/`): `setwd()` to the root and restart R. Non-interactive R (Rscript, PSOCK workers, Jupyter kernels) skips renv's load-time library/lockfile check (~7 s); run `renv::status()` to see it.
- **The library is not in git:** it lives in the user's `renv` cache (`renv::paths$library()`); what is versioned is `renv.lock`.
- **To add a package:** `renv::install("package")`, list it under `Imports` in `DESCRIPTION`, run `renv::snapshot()` and commit `renv.lock`.
- **To rebuild from scratch** (only to change the date or the package set): `Rscript _tools/renv_setup.R`. The date is the day after the newest package version in the dependency closure when it was created (`ggplot2` 4.0.3 and `curl` 7.1.0, both published 2026-04-22).
- `.renvignore` excludes `jrt/`, `notes/` and the document folders: their inherited code loads packages that are not part of the project. R started in those folders still loads the project library (they have the stub), so that reference code cannot find packages outside `renv.lock`.
- CI goes through `renv` like everything else: `data-check` restores only `openssl` and `data.table` (`renv::restore(packages = …)`, lockfile versions and dated snapshot); `renv-check` checks the activation on Linux, Windows and macOS.

## Tests (from the repository root)

```
Rscript _tools/test_acc_data.R   # encryption/decryption unit test (~1 s)
Rscript _tools/check_bundles.R   # decrypts every bundle and compares its md5 with the .md5.csv sidecar (~2 min)
Rscript _tools/smoke_data.R      # basic read of each source
Rscript --vanilla _tools/test_renv_activation.R   # renv loads the same library from the root and every folder with R code (~20 s)
```

`.github/workflows/data-check.yml` runs the bundle verification on GitHub (it needs the `ACC_DATA_KEY` secret); `renv-check.yml` runs the renv activation test.

## Notebook order (`__andres_control/`)

1. `eps_alcohol_prevalencia_persistencia.ipynb` (EPS; ~1 min) — report: `eps_alcohol_prevalencia_persistencia_informe.md`.
2. `elasticidad_consolidado.ipynb` (EPF).
3. `microsim_base_ACC_2012_2024.ipynb` and `microsim_recalib_ACC_2012_2024.ipynb` (~1 min each) — explanation: `microsim_base_ACC_2012_2024_explicacion.md`.
4. `expand_pif.ipynb` (~45 min): AAF, attributable mortality and YPLL.
5. `expand_pif2.ipynb` (~13 h) and `expand_pif3.ipynb`: PIF with synchronised draws, and tables/figures. **The draws are not in the repository**; regenerate them with `expand_pif` → `expand_pif2`.
6. `guion_reunion_ACC_2026-09-16_revision_critica.ipynb`: critical review (reads saved artefacts).

The canonical handoff is `__andres_control/codex_handoff_adam_rr_full_override_caveman.md` (see `AGENTS.md` §1). Roadmap: `presentacion_micsim.qmd` / `.html`.

## Weekly DEIS update

Download `DEFUNCIONES_FUENTE_DEIS_2024_2026_<DDMMYYYY>.zip` into `_deis/` (git ignores it) and run `source("_tools/acc_data.R"); acc_deis_update()`. Details in [_deis/README.md](_deis/README.md).

## Claude Code chats

To resume a conversation, run from the repository root:

```r
source("_tools/acc_data.R")
# Claude Code keeps chats in <home>/.claude/projects/<clone path with non-alphanumerics as "-">.
# On Windows R's "~" is Documents, so use USERPROFILE (HOME on macOS/Linux).
home <- Sys.getenv(if (.Platform$OS.type == "windows") "USERPROFILE" else "HOME")
p <- file.path(home, ".claude", "projects", gsub("[^A-Za-z0-9]", "-", normalizePath(getwd())))
dir.create(p, showWarnings = FALSE, recursive = TRUE)
acc_unpack_all("_sessions", p)
```

## Data policy

- No plain microdata: no `.dta`, `.sav`, `.parquet`, `.zip` or `.jsonl` in git (see `.gitignore`).
- The sources are public and anonymized: notebook outputs may show example rows, with clear quasi-identifiers (e.g. `comuna`) masked only in what is displayed. Raw microdata go to git only as encrypted bundles.
- The SIMAH package is cited by DOI (`10.5281/zenodo.15641639`) instead of being vendored.