# EPS reproducibility check

Status: **PASS**

- Independent fresh R sessions: 2; completed code cells each: 11.
- Byte-identical aggregate CSV files: 42; aggregate rows: 7246.
- Common computation SHA256: `effd6bbeea3757def30c7017cb6baefd488ecd8eaeb445e4939233a8434e4445`.
- ES execution: 21.27 minutes; final cell completed 2026-10-16T00:08:34.675235+00:00.
- EN execution: 20.88 minutes; final cell completed 2026-10-16T00:08:11.298955+00:00.
- JKn replicates: 111; person replicates: 1000.
- Every recorded real-data R check passed; neither notebook contains an error output.
- All replicate fits succeeded; supported transition rows sum to one and available probability intervals include their estimates within [0,1].
- Shared computation is identical; setup language and notebook locator differ.
- File-level hashes: `reproducibility_check.csv`.

Scientific sensitivity: annual probabilities differ by up to 10.5 percentage points across restarts at the primary penalty, and 33.8 across the combined penalty/start grid. Computational PASS does not resolve this instability. Annual intervals condition on the primary penalty and initialization.

Reproduce from the project root after obtaining the encrypted data key through the usual local environment:

```text
python _tools/build_eps_markov_notebooks.py
python _tools/execute_eps_notebook.py __andres_control/eps_markov_transiciones.ipynb
python _tools/execute_eps_notebook.py __andres_control/eps_markov_transitions_EN.ipynb --output-dir .quarto/eps_markov_reproduction_en
python _tools/verify_eps_reproduction.py
```

Use the project's existing R/renv and Python notebook environment. Optional process affinity is a local runtime argument, not a project default.
This verifies computational reproduction, not external validation or the truth of the statistical assumptions.
