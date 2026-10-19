# TSM v3 reproducibility check

Status: **PASS**

- Independent fresh R sessions: 2 (one language); completed code cells: 14.
- Byte-identical aggregate CSV files: 63; aggregate rows: 17404.
- Source SHA256 in notebook metadata: data_sha256 `655c2b107e8ee9cf50006992251eff7222a09626cda00bde2f84da514ec515e0`, models_sha256 `fb252bf8303fc5f538a1961d08846380239af3f8704725e56665d954bf79301b`, sections_sha256 `f895ee9fcbd9eb7ca952264f5ad362c42a5fdda4e7c3c3fd6efa98f9690febc1`, narrative_sha256 `b3c1cb9da2c23d0c4f5976da8401eec5af685bb421ae50ae2a12baedd0c74c4a`.
- Main execution: 51.23 minutes; final cell completed 2026-10-19T21:47:18.856895+00:00.
- Person replicates: 1000; every replicate succeeded.
- Every recorded real-data R check passed; the notebook contains no error output.
- Supported transition rows sum to one and available probability intervals include their estimates within [0,1].
- File-level hashes: `reproducibility_check.csv`.
- Rendered HTML: all assets embedded; 12 embedded images; 3 MathML display equations (`render_validation.json`).

Scientific sensitivity: for Gamma, annual probabilities differ by up to 8.9 percentage points across restarts at the primary penalty, and 8.9 across the combined penalty/start grid. Computational PASS does not resolve this instability. The EPS cross-check is external consistency, not validation.

Reproduce from the project root after obtaining the encrypted data key through the usual local environment:

```text
python _tools/build_tsm_markov_notebook.py
python _tools/execute_eps_notebook.py __andres_control/TSM_ENPG_v3_EN.ipynb --output-env TSM_MARKOV_OUTPUT
python _tools/execute_eps_notebook.py __andres_control/TSM_ENPG_v3_EN.ipynb --output-env TSM_MARKOV_OUTPUT --output-dir .quarto/tsm_markov_reproduction_en
python _tools/verify_tsm_reproduction.py
```

Use the project's existing R/renv and Python notebook environment. Optional process affinity is a local runtime argument, not a project default.
This verifies computational reproduction, not external validation or the truth of the statistical assumptions.
