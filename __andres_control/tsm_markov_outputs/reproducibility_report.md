# TSM v3 reproducibility check

Status: **PASS**

- Independent fresh R sessions: 2 (one language); completed code cells: 14.
- Byte-identical aggregate CSV files: 63; aggregate rows: 17405.
- Source SHA256 in notebook metadata: data_sha256 `5659c7d2a96cf4141af1ab7dc6bb8ad1abd6be1243606cd554f8fe3b3db398ce`, models_sha256 `fc127cccf651572164ca3491aab7d9671af38dbc47a69e10272541f36981a2c3`, sections_sha256 `f895ee9fcbd9eb7ca952264f5ad362c42a5fdda4e7c3c3fd6efa98f9690febc1`, narrative_sha256 `41db24b00d97908b1e64de1b0f5fc6b1d482eb34491e5f0b0abd0e4a28bef29a`.
- Main execution: 51.27 minutes; final cell completed 2026-10-26T23:47:35.845330+00:00.
- Person replicates: 1000; every replicate succeeded.
- Every recorded real-data R check passed; the notebook contains no error output.
- Supported transition rows sum to one and available probability intervals include their estimates within [0,1].
- File-level hashes: `reproducibility_check.csv`.

Scientific sensitivity: for Gamma, annual probabilities differ by up to 9.0 percentage points across restarts at the primary penalty, and 21.4 across the combined penalty/start grid. Computational PASS does not resolve this instability. The EPS cross-check is external consistency, not validation.

Reproduce from the project root after obtaining the encrypted data key through the usual local environment:

```text
python _tools/build_tsm_markov_notebook.py
python _tools/execute_eps_notebook.py __andres_control/TSM_ENPG_v3_EN.ipynb --output-env TSM_MARKOV_OUTPUT
python _tools/execute_eps_notebook.py __andres_control/TSM_ENPG_v3_EN.ipynb --output-env TSM_MARKOV_OUTPUT --output-dir .quarto/tsm_markov_reproduction_en
python _tools/verify_tsm_reproduction.py
```

Use the project's existing R/renv and Python notebook environment. Optional process affinity is a local runtime argument, not a project default.
This verifies computational reproduction, not external validation or the truth of the statistical assumptions.
