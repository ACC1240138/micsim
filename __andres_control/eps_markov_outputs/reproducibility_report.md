# EPS reproducibility check

Status: **PASS**

- Independent fresh R sessions: 2; completed code cells each: 11.
- Byte-identical aggregate CSV files: 42; aggregate rows: 7246.
- Common computation SHA256: `927133dfef8e5051a8abed1164b92fba44ed1970b315558f2683bb397b0bd2e8`.
- ES execution: 21.16 minutes; final cell completed 2026-10-26T16:00:35.976978+00:00.
- EN execution: 21.07 minutes; final cell completed 2026-10-26T16:21:44.232431+00:00.
- JKn replicates: 111; person replicates: 1000.
- Every recorded real-data R check passed; neither notebook contains an error output.
- All replicate fits succeeded; supported transition rows sum to one and available probability intervals include their estimates within [0,1].
- Shared computation is identical; setup language and notebook locator differ.
- File-level hashes: `reproducibility_check.csv`.

Scientific sensitivity: annual probabilities differ by up to 7.9 percentage points across restarts at the primary penalty, and 27.9 across the combined penalty/start grid. Computational PASS does not resolve this instability. Annual intervals condition on the primary penalty and initialization.

Reproduce from the project root after obtaining the encrypted data key through the usual local environment:

```text
python _tools/build_eps_markov_notebooks.py
python _tools/execute_eps_notebook.py __andres_control/eps_markov_transiciones.ipynb
python _tools/execute_eps_notebook.py __andres_control/eps_markov_transitions_EN.ipynb --output-dir .quarto/eps_markov_reproduction_en
python _tools/verify_eps_reproduction.py
```

Use the project's existing R/renv and Python notebook environment. Optional process affinity is a local runtime argument, not a project default.
This verifies computational reproduction, not external validation or the truth of the statistical assumptions.
