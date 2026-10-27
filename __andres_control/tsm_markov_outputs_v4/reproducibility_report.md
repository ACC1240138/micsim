# TSM v4 reproducibility check

Status: **PASS**

- Independent fresh R sessions: 2 (one language); completed code cells: 28.
- Byte-identical aggregate CSV files: 61; aggregate rows: 13029.
- Source SHA256 in notebook metadata: data_sha256 `148086d5f72aa0b585ad427727d41a3a0ff67fc306b25260a2e1997692f838e2`, models_sha256 `d9909dbf629847b3d9057d9e9d16b2e587cb6f08446df8eaa22b51c1815f0743`, sections_sha256 `b76b6efc8429ee9ad65a95ef3714c425314eb2c09c220afc8a0db40852d5e7a9`, narrative_sha256 `b783591d5daa936727b0fde16b52bd7c6d946b43ff481130e99d3fdcc419caab`.
- Main execution: 41.91 minutes; final cell completed 2026-10-27T02:16:23.907929+00:00.
- Person replicates: 1000; every replicate succeeded.
- Every recorded real-data R check passed; the notebook contains no error output.
- Supported transition rows sum to one and available probability intervals include their estimates within [0,1].
- File-level hashes: `reproducibility_check.csv`.
- Rendered HTML: all assets embedded; 12 embedded images; 3 MathML display equations (`render_validation.json`).

Scientific sensitivity: for A, annual probabilities differ by up to 0.2 percentage points across restarts at the primary penalty, and 3.1 across the combined penalty/start grid. Computational PASS does not resolve this instability. The EPS cross-check is external consistency, not validation.

Reproduce from the project root after obtaining the encrypted data key through the usual local environment:

```text
python _tools/build_tsm_markov_notebook.py
python _tools/execute_eps_notebook.py __andres_control/TSM_ENPG_v4_EN.ipynb --output-env TSM_MARKOV_OUTPUT
python _tools/execute_eps_notebook.py __andres_control/TSM_ENPG_v4_EN.ipynb --output-env TSM_MARKOV_OUTPUT --output-dir .quarto/tsm_markov_reproduction_v4_en
python _tools/verify_tsm_reproduction.py
```

Use the project's existing R/renv and Python notebook environment. Optional process affinity is a local runtime argument, not a project default.
This verifies computational reproduction, not external validation or the truth of the statistical assumptions.
