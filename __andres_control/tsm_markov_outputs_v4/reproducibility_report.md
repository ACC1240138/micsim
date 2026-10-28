# TSM v4 reproducibility check

Status: **PASS**

- Independent fresh R sessions: 2 (one language); completed code cells: 29.
- Byte-identical aggregate CSV files: 74; aggregate rows: 19213.
- SHA256 of the notebook code cells (the single source since 2026-10-27): `eff24e531ecc05c86070a88d3b09a51096c96aa2a6be6daa0e107dd05447fe3f`.
- Main execution: 58.75 minutes; final cell completed 2026-10-27T20:33:33.575582+00:00.
- Person replicates: 1000; every replicate succeeded.
- Every recorded real-data R check passed; the notebook contains no error output.
- Supported transition rows sum to one and available probability intervals include their estimates within [0,1].
- File-level hashes: `reproducibility_check.csv`.
- Rendered HTML: all assets embedded; 14 embedded images; 4 MathML display equations (`render_validation.json`).

Scientific sensitivity: for A, annual probabilities differ by up to 0.2 percentage points across restarts at the primary penalty, and 3.1 across the combined penalty/start grid. Computational PASS does not resolve this instability. The EPS cross-check is external consistency, not validation.

Reproduce from the project root after obtaining the encrypted data key through the usual local environment:

```text
copy __andres_control/TSM_ENPG_v4_EN.ipynb to __andres_control/TSM_ENPG_v4_EN_repro_dry.ipynb
python _tools/execute_eps_notebook.py __andres_control/TSM_ENPG_v4_EN.ipynb --output-env TSM_MARKOV_OUTPUT
python _tools/execute_eps_notebook.py __andres_control/TSM_ENPG_v4_EN_repro_dry.ipynb --output-env TSM_MARKOV_OUTPUT --output-dir .quarto/tsm_markov_reproduction_v4_en
python _tools/verify_tsm_reproduction.py
```

Use the project's existing R/renv and Python notebook environment. Optional process affinity is a local runtime argument, not a project default.
This verifies computational reproduction, not external validation or the truth of the statistical assumptions.
