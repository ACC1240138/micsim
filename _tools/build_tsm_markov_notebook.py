"""Build the English TSM v4 notebook from the narrative, the cell bodies and the two R layers.

Sources (all under __andres_control/): TSM_ENPG_v4_EN.md (markdown with
"<!-- code:label -->" placeholders), tsm_markov_sections.R (bodies separated by
"# @@label" lines), tsm_markov_data.R and tsm_markov_models.R (embedded right after
tsm-session-setup, split into explained chunks that concatenate back to each file
byte for byte, so the notebook needs no sourced R file besides the data decryptor).
Version 4 (2026-10-26): five states (C3 and C4 merged into C3plus), WHO borders,
data-based two-year link tolerance. The executed v3 notebook is kept as history.

Testing hooks: TSM_LAYER_DIR (environment) points at a folder holding stand-in
tsm_markov_data.R / tsm_markov_models.R, and --out writes the notebook elsewhere.
"""
from pathlib import Path
import argparse
import hashlib
import os
import re
import sys
import nbformat as nb

parser = argparse.ArgumentParser()
parser.add_argument("--keep-outputs", action="store_true", help="Preserve executed cells only when their complete code is unchanged")
parser.add_argument("--out", help="Notebook path to write (default __andres_control/TSM_ENPG_v4_EN.ipynb); for tests")
ARGS = parser.parse_args()

ROOT = next(p for p in Path(__file__).resolve().parents if (p / ".acc_root").is_file())
DIR = ROOT / "__andres_control"
LAYERS = Path(os.environ.get("TSM_LAYER_DIR", DIR))
OUT = Path(ARGS.out) if ARGS.out else DIR / "TSM_ENPG_v4_EN.ipynb"
ELAPSED = '\ncat(sprintf("Elapsed: %.2f minutes\\n", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))\n'

def read(path):
    if not path.is_file():
        sys.exit(f"Missing source file: {path}")
    return path.read_text(encoding="utf-8")

DATA = read(LAYERS / "tsm_markov_data.R")
MODELS = read(LAYERS / "tsm_markov_models.R")
SECTIONS = read(DIR / "tsm_markov_sections.R")
NARRATIVE = read(DIR / "TSM_ENPG_v4_EN.md")

def code(label, body):
    return nb.v4.new_code_cell(f"#| label: {label}\n.t0 <- Sys.time()\n" + body.strip() + ELAPSED)

# Each R layer is split before these top-level definitions (with the comment lines just above them); every chunk
# is preceded by an English explanation. (None, ...) is the first chunk of the file.
DATA_CHUNKS = [
    (None, "tsm-def-constants", "**Constants and small helpers.** Seed, bootstrap and cross-validation sizes, the five origin states (`ts_ST`: N0, FD, C1, C2, C3plus) and four destination classes (`ts_Y`: NC, C1, C2, C3plus), age groups, the approximate fieldwork month of each round and the elapsed months of each interval. `ts_check` stops on a failed assertion and records it in `ts_checks`; `ts_save` writes aggregate CSVs only; `ts_show`/`ts_fig` display tables and figures; `ts_warn` collects warnings; `ts_age`, `ts_key` and `ts_wquant` build age groups, group keys and weighted quantiles."),
    ("ts_link_tolerance", "tsm-def-link-categories", "**Link rule and drinking categories.** `ts_compatible` accepts a record as the same person when sex agrees and the age change lies within the bounds implied by the months elapsed, widened by `ts_link_tolerance` = 2 years (chosen from the data; see the link audit below). `ts_cat` applies the WHO borders without gaps, the exact border value going to the lower class, with C3 and C4 merged into C3plus (above 40 g/day for women, 60 for men). `ts_signal` builds the typical-quantity signal and `ts_education` the three education rules."),
    ("ts_load", "tsm-def-load", "**Reading the data.** `ts_load` decrypts the TSM bundle into a temporary folder through `_tools/acc_data.R` (the only file sourced), checks every SAV file against the md5 sidecar, keeps the panel respondent of each household, validates the codes used later and exports the input manifest and the variable dictionary. Nothing person-level is written."),
    ("ts_waves", "tsm-def-waves", "**Wave table, history and adjacent pairs.** `ts_waves` converts the frequency and quantity bands to grams per day, assigns the category and builds the past-only drinking history: the flag travels along the chain of compatible interviews, so FD means drinking observed at an earlier compatible interview. `ts_make_risk` pairs each origin respondent aged 18-65 with the next round, keeps the destination only when the link is compatible and defines the model variables."),
    ("ts_x", "tsm-def-ipw", "**Attrition weights.** `ts_x` builds design matrices with a fixed column set; `ts_binary_fit`/`ts_binary_prob` fit weighted logistic models. `ts_ipw_fit` and `ts_ipw_apply` give each complete pair its cross-sectional weight times an inverse-probability-of-linkage weight, trimmed at fixed percentiles and renormalised to the number of complete pairs of each interval."),
    ("ts_link_audit", "tsm-def-audits", "**Audits.** The link audit counts destination records present, compatible and rejected by sex or age; `ts_link_tolerance_evidence` tabulates, by years outside the strict EPS age bounds, how often the reached education level differs between rounds, which is the evidence for the two-year tolerance. The education, history and FD-tenure audits and the regression against the version 2 counts follow."),
]
MODEL_CHUNKS = [
    (None, "tsm-def-model-forms", "**Model formulas and amount models.** `ts_states` lists the origin states implied by the destination classes; `ts_formula` builds the right-hand side (origin state, sex x age, period, log grams at origin, education, optional history and TSM extras). `ts_matrix_fit` fits the amount of drinking among destination drinkers: a Gamma GLM with a BFGS fallback and a weighted shape, or a weighted lognormal."),
    ("ts_class_fit", "tsm-def-class-models", "**Class models and model A.** `ts_class_fit`/`ts_class_prob` fit proportional-odds or multinomial models over the destination classes. Model A is a shrunken empirical matrix: each sex x age (x education) cell of each period is pulled toward its sex matrix, which is pulled toward the period matrix, with strength `k` chosen by inner cross-validation."),
    ("ts_models", "tsm-def-fit-predict", "**Model catalogue, fitting and prediction.** `ts_models` lists every candidate; `ts_fit` fits participation plus amount, a class model, or A. `ts_prob` returns destination probabilities: for Gamma and lognormal it integrates the amount distribution between the WHO cuts (20 and 40 g/day for women, 40 and 60 for men), so the top class C3plus is everything above the second cut."),
    ("ts_loss", "tsm-def-cv", "**Scores and cross-validation.** Log loss (with one numerical floor), Brier and accuracy; person-blocked folds; the inner tuning of A's shrinkage; repeated person-blocked cross-validation with the IPW refitted inside every training fold; score tables and paired contrasts with person-cluster Taylor intervals."),
    ("ts_matrices", "tsm-def-matrices", "**Transition matrices.** `ts_matrices` averages the predicted destination probabilities within period x sex x age x origin (or any grouping), splits NC into N0 or FD by origin history, and flags unobserved and sparse origins and structural zeros. `ts_targets`, `ts_vector` and `ts_coef` collect the quantities the bootstrap re-estimates; `ts_quantities` gives drinking, escalation from C1 and the C3plus share."),
    ("ts_person_mult", "tsm-def-bootstrap", "**Whole-person bootstrap.** Each replicate resamples people (all their pairs together), refits the IPW and every model, and recomputes matrices, coefficients and optionally the annual layer. `ts_interval` turns the replicate SDs into normal intervals, on the logit scale for probabilities; `ts_bootstrap_stability` checks how the SEs settle as replicates are added; `ts_calibration_cells` compares held-out predicted and observed shares by origin x sex x age."),
    ("ts_ij_fun", "tsm-def-annual", "**Annual layer.** A continuous-time generator with free rates N0->C, FD->C, C->FD and C->C is fitted to the model-predicted interval matrices of the four periods (each with its own length), with exact gradients and a weak fixed ridge; `ts_annual` returns the one-year matrix exp(Q). It is a model-derived scenario, not an observed annual transition."),
    ("ts_transport", "tsm-def-diagnostics", "**Diagnostics.** Leave-one-interval-out transport; comonotone rank coupling of the margins (the category form of JRT rank matching) against the panel; whether the state one round earlier adds information; a descriptive Chapman-Kolmogorov comparison; and the regression of the typical-quantity signal on the destination class."),
    ("ts_crosscheck_eps", "tsm-def-crosscheck", "**Cross-check against EPS.** Reads the EPS version 1 aggregate CSVs (six states) and merges C3 and C4 into C3plus: destination columns are summed and the two origin rows averaged with the observed EPS origin pairs. It then compares annual staying probabilities, scores the EPS generator projected to the TSM intervals on TSM pairs, and projects the TSM generator to the EPS interval lengths."),
    ("ts_point_sensitivity", "tsm-def-sensitivity", "**Point sensitivities.** Pooled point estimates for alternative risk sets (education rules, the upper quantity band), with the IPW refitted and each variant's own period masses."),
    ("ts_diagram", "tsm-def-figures", "**Figures.** Flowcharts, the interval timeline and the result plots; each figure is saved as PNG and PDF in the output folder and displayed."),
]


def split_layer(text, specs, name):
    lines = text.splitlines(keepends=True)
    starts = [0]
    for fn, _, _ in specs[1:]:
        i = next(i for i, l in enumerate(lines) if l.startswith(f"{fn} <- "))
        while i > 0 and lines[i - 1].startswith("#"):
            i -= 1
        starts.append(i)
    assert starts == sorted(starts) and len(set(starts)) == len(starts), f"{name}: chunk markers out of order"
    pieces = ["".join(lines[a:b]) for a, b in zip(starts, starts[1:] + [len(lines)])]
    assert "".join(pieces) == text, f"{name}: split does not reproduce the file"
    out = []
    for (_, label, explanation), piece in zip(specs, pieces):
        out += [nb.v4.new_markdown_cell(explanation), code(label, piece)]
    return out


DEFINITIONS = [nb.v4.new_markdown_cell("## Function definitions, explained\n\nEvery function the notebook uses is defined in the cells below, each preceded by a short explanation, so the analysis can be audited here without opening other files. They are the data layer `tsm_markov_data.R` and the model layer `tsm_markov_models.R`, split into chunks that concatenate back to the two files byte for byte (checked by the notebook builder). The only file sourced is `_tools/acc_data.R`, which decrypts the data bundle.")]
DEFINITIONS += split_layer(DATA, DATA_CHUNKS, "tsm_markov_data.R") + split_layer(MODELS, MODEL_CHUNKS, "tsm_markov_models.R")

parts = re.split(r"^# @@(\S+)[ \t]*$", SECTIONS, flags=re.M)
bodies = {parts[i]: parts[i + 1] for i in range(1, len(parts), 2)}
chunks = re.split(r"<!-- code:(\S+) -->", NARRATIVE)
labels = chunks[1::2]
assert len(labels) == len(set(labels)), "Repeated placeholder label"
assert set(labels) == set(bodies), f"Placeholders without body: {set(labels) - set(bodies)}; bodies without placeholder: {set(bodies) - set(labels)}"
assert all(b.strip() for b in bodies.values()), "Empty cell body"

cells = []
for i, label in enumerate(labels):
    cells.append(nb.v4.new_markdown_cell(chunks[2 * i].strip() + "\n"))
    cells.append(code(label, bodies[label]))
    if label == "tsm-session-setup":
        cells.extend(DEFINITIONS)
cells.append(nb.v4.new_markdown_cell(chunks[-1].strip() + "\n"))

sha = lambda text: hashlib.sha256(text.encode("utf-8")).hexdigest()
doc = nb.v4.new_notebook(cells=cells, metadata={
    "kernelspec": {"display_name": "R", "language": "R", "name": "ir"},
    "language_info": {"name": "R"},
    "tsm_revision": {"version": "v4", "language": "en", "data_sha256": sha(DATA), "models_sha256": sha(MODELS),
                     "sections_sha256": sha(SECTIONS), "narrative_sha256": sha(NARRATIVE)}})
if ARGS.keep_outputs and OUT.exists():
    old = nb.read(OUT, as_version=4)
    executed = {c.source: c for c in old.cells if c.cell_type == "code"}
    doc.cells = [executed.get(c.source, c) if c.cell_type == "code" else c for c in doc.cells]
nb.validate(doc)
nb.write(doc, OUT)
print(f"{OUT.name}: {len(cells)} cells, {sum(c.cell_type == 'code' for c in cells)} code cells, labels {', '.join(labels)}")
