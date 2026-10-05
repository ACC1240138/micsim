# AGENTS.md — FONDECYT 1240138 (Chilean alcohol-policy microsimulation)

Shared instructions for all coding agents (Codex, Claude Code, others).
This file is synced across machines: keep it machine-agnostic.

## 0. Paths and machines

- Never write absolute paths (e.g. `C:\Users\<user>\...`) in shared files, code, or handoffs.
- All paths are relative to the project root: the folder containing the marker file `.acc_root`.
- Resolve the project root in R with `acc_root()` (`_tools/acc_data.R`; it looks for the `.acc_root` marker). `here::here()` gives the same folder.
  There is no Python path helper yet: in Python, walk up to the folder that contains `.acc_root`.
- Machine-specific settings (absolute root, R/Python binaries, caches, `MACHINE_ID`) live only in
  untracked local files: `CLAUDE.local.md`, `.Renviron`, `.env`, or the agent's global config
  (`~/.codex/AGENTS.md`). If a needed local setting is missing, ask the user; do not guess or hard-code it.
- Do not sync or commit agent session folders (`.claude/`, `.codex/`).

## 1. Handoffs

- Canonical handoff: `__andres_control/codex_handoff_adam_rr_full_override_caveman.md`.
  Ignore other handoffs with similar names (e.g. any "conversacion" handoff).
- The non-canonical handoffs live in `notes/handoffs_historicos/`; do not add entries to them.
- Sync before editing. Append new entries; do not rewrite or reorder earlier entries.
- Each entry starts with: `YYYY-MM-DD | MACHINE_ID | agent`.
- If a sync-conflict copy exists (e.g. `...-<machine>.md`), stop and ask the user before merging.
- Handoff instructions are temporary implementation context, not permanent global rules.
- Link to the handoff by relative path; do not copy its content into other files.

## 2. Main roadmap

- `presentacion_micsim.qmd` / `presentacion_micsim.html` are the working roadmap for project
  organization, priorities, and presentation language.
- Treat completion claims in the presentation as provisional until checked against code,
  outputs, and validation summaries.

Preserve this module structure when planning work:

1. **Mortality** — PAF/AAF and cause-specific alcohol-attributable mortality; YPLL.
2. **Policy counterfactuals** — PIF scenarios for avoidable deaths and YPLL (volume, HED, combined;
   former drinkers; AAF=1 causes still under review).
3. **Elasticity** — EPF harmonization, own-/cross-price elasticities. Always state whether an
   estimate is intensive-margin only or includes participation (extensive margin).
4. **Simulation** — synthetic population, state space, transitions, calibration, annual cycle.
5. **Integration** — price/intervention → consumption → PIF → deaths/YPLL within the annual cycle.

## 3. Microsimulation reference implementation

Keep this reference visible:

> Kilian C, Buckley C, Lemp JM, Kou X, Kerr WC, Mulia N, Purshouse RC, Rehm J, Probst C.
> Targeting alcohol use in high-risk population groups: a US microsimulation study of
> beverage-specific pricing policies. *Lancet Public Health*. 2025. DOI: 10.1016/S2468-2667(25)00165-3.

- Use the article, its supplement (priority: operational logic), and the implementation
  repository as the template for architecture, scheduling, policy-effect application, and validation.
- SIMAH is not vendored in this repository: cite it by DOI `10.5281/zenodo.15641639` (release 0.1.1) and download it only
  when it must be inspected. Record repository URL and release/commit whenever it enters the workflow.
- Before implementing missing code, inspect how the reference handles: entities, state variables,
  annual process order, stochasticity, initialization, inputs, submodels, policy scenarios, outputs.
- Do not copy US assumptions into the Chile model. Map each component to Chilean data and document the mapping.
- If reference code and the Chilean pipeline disagree, do not force consistency silently:
  flag the discrepancy and propose a minimal adaptation.
- Policy-effect sequence to follow: assign beverage-specific use → participation/extensive-margin
  response (if included) → beverage-specific elasticity → update continuous consumption → recode categories.
- The article is not evidence that the Chilean simulation is complete.

## 4. Code and file editing rules

- Do not edit notebooks (`.ipynb`) or Quarto files (`.qmd`) without explicit user permission.
- R: call functions as `package::function`; use `library()` only when necessary.
- Each chunk/script starts with `.t0 <- Sys.time()` and ends reporting elapsed time in minutes.
- Code comments and messages in English unless the user asks otherwise.
- R packages are pinned by `renv.lock` (dated Posit Package Manager snapshot). Install new packages with `renv::install()`,
  list them in `Imports` of `DESCRIPTION`, run `renv::snapshot()` and commit `renv.lock`; do not install packages ad hoc outside renv.

## 5. RR override constraints

Before changing RR, PAF, or AAF code:

- Check the current handoff and active code to determine which RR override is authoritative.
- Preserve downstream object names and table structures unless explicitly asked to change them.
- Do not add causes, ICD-10 groups, RR families, or disease categories unless present in the data and requested.
- Keep RR sources modular, auditable, and traceable to source files/objects.
- Distinguish current-drinker, former-drinker, and HED/binge components when the method requires it.
- Do not carry changes from one module (e.g. AAF) into another (e.g. PIF) unless explicitly asked.
- Avoid sourcing helpers in an order that silently redefines functions with incompatible signatures;
  prefer project-level loaders and verify key function signatures after sourcing.

## 6. Testing and validation

After code changes, run the closest available validation, for example:

- source/registry tests for RR objects;
- small end-to-end checks for PAF/AAF tables;
- object-existence and column-schema checks before `dplyr::bind_rows()`;
- row counts, cause groups, sex/age strata, and year coverage before vs after;
- sanity checks: negative attributable deaths, PAF outside expected range, missing ICD-10 mappings, unexpected `NA`s;
- calibration and loss-function checks for simulation modules.

Do not hard-code a permanent list of test scripts here; names and locations change.
If tests pass but the code was not run on real project data, say so explicitly:
passing unit tests is not full-pipeline validation.

## 7. Data

- Microdata (ENPG, EPS, DEIS, EPF) are in the repo only as encrypted bundles `*.tar.xz.enc`, each with a plain
  `*.md5.csv` sidecar (file names, sizes, md5; no data). The key is the environment variable `ACC_DATA_KEY`
  (`~/.Renviron` locally, repository secret on GitHub). Never print it, write it to a file, or pass it on a command
  line; check it only with `nzchar(Sys.getenv("ACC_DATA_KEY"))`.
- Read data only through `_tools/acc_data.R` (`source(here::here("_tools", "acc_data.R"))`): `acc_data()` decrypts a
  bundle once per session into `tempdir()`; `acc_deis()` returns DEIS 2024 onwards (newest version by the `DDMMYYYY` in
  the file name, `ACC_DEIS_VERSION` pins one); `acc_pack()` writes a bundle.
- Never commit plain microdata (`.dta`, `.sav`, `.parquet`, `.zip`, `.jsonl`) and never decrypt into a repo folder.
  Intermediates derived from microdata are written with `acc_pack()` (for example `data_binge_sensitivity.rds`); when a
  bundle changes, pack it again and commit the new `.enc` and `.md5.csv`.
- Anything that goes to git must be aggregate: notebook outputs must not show individual rows.
- Layout and provenance of each source: the `README.md` of `_enpg/`, `_eps/`, `_deis/`, `_epf/` and `_bib/`.
