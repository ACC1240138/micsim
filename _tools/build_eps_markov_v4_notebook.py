"""Build the EPS v4 notebook from the executed v2 notebook plus the v4 narrative and R layers.

Sources (all under __andres_control/): eps_markov_transitions_v2_EN.ipynb (base: cells copied with outputs
stripped), eps_markov_core.R (re-embedded split into explained chunks; the split must reproduce it exactly),
eps_alcohol_prevalencia_persistencia.ipynb (the three cells that ep_load() evaluates are reproduced as markdown and
verified by md5 at run time), eps_markov_v4_extra.R ("# @@eps-v4-def-*" chunks), eps_markov_v4_sections.R
("# @@eps-v4-*" bodies) and eps_markov_v4_narrative.md ("<!-- code:label -->" placeholders).
Decisions: __andres_control/decision_categorias_who_12g_2026-10-26.md.

Testing hooks: EPS_V4_LAYER_DIR (environment) points at a folder with stand-in v4 R layers; --out writes elsewhere.
"""
from pathlib import Path
import argparse
import hashlib
import json
import os
import re
import sys
import nbformat as nb

parser = argparse.ArgumentParser()
parser.add_argument("--out", help="Notebook path to write (default __andres_control/eps_markov_transitions_v4_EN.ipynb)")
ARGS = parser.parse_args()

ROOT = next(p for p in Path(__file__).resolve().parents if (p / ".acc_root").is_file())
DIR = ROOT / "__andres_control"
LAYERS = Path(os.environ.get("EPS_V4_LAYER_DIR", DIR))
BASE = DIR / "eps_markov_transitions_v2_EN.ipynb"
ALCOHOL = DIR / "eps_alcohol_prevalencia_persistencia.ipynb"
OUT = Path(ARGS.out) if ARGS.out else DIR / "eps_markov_transitions_v4_EN.ipynb"
TARGET = "__andres_control/eps_markov_transitions_v4_EN.ipynb"
TITLE = "EPS: alcohol consumption transitions, version 4"
SUBTITLE = "WHO categories without gaps, 12 g/drink, C3+C4 merged, EPS 2009 history, widened links and a formal comparison of tail models"
V4_LABELS = ["eps-v4-def-config", "eps-v4-def-scoped", "eps-v4-def-classification", "eps-v4-config",
             "eps-v4-def-history2009", "eps-v4-def-waves-risk", "eps-v4-def-history-tables", "eps-v4-history-2009",
             "eps-v4-def-amount-models", "eps-v4-def-metrics", "eps-v4-amount-models",
             "eps-v4-def-matrices", "eps-v4-matrices", "eps-v4-def-figures", "eps-v4-figures", "eps-v4-reproducibility"]
ELAPSED = '\ncat(sprintf("Elapsed: %.2f minutes\\n", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))\n'

# The v1 core, split at these top-level definitions; each chunk is preceded by an English explanation.
CORE_CHUNKS = [
    (None, "eps-shared-definitions", "**Constants and helpers.** Seed, bootstrap and cross-validation sizes, the six origin states (`ep_ST`: N0, FD, C1-C4) and five destination classes (`ep_Y`: NC, C1-C4), age groups and intervals, plus small helpers: `ep_check` records every assertion in `ep_checks`, `ep_save` writes aggregate CSVs to the output folder, `ep_show`/`ep_fig` display tables and figures, `ep_warn` collects warnings, `ep_age` builds age groups and `ep_key` builds group keys."),
    ("ep_cat", "eps-shared-definitions-categories", "**v1 categories and the typical-quantity signal.** `ep_cat` is the v1 rule (lower borders to the upper class, women's top cut 60 g/day since 2026-10-26); v4 replaces it with `ep_v4_cat` below but keeps it for the regression test. `ep_qsignal` flags a typical quantity of at least 4 (women) or 5 (men) drinks, the EPS proxy for heavy episodic drinking."),
    ("ep_load", "eps-shared-definitions-load", "**Loading.** `ep_load` decrypts the EPS bundle and evaluates three cells of `eps_alcohol_prevalencia_persistencia.ipynb` (reproduced and verified below the definitions), sets the output folder from `EPS_MARKOV_OUTPUT`, builds the link windows `ep_time` (VI->VII, VII->VIII and the history-only VI->VIII), maps published PSU and stratum codes, and lists known VIII deaths."),
    ("ep_waves", "eps-shared-definitions-waves", "**Waves and risk set.** `ep_waves` builds one row per person and wave with grams/day at a chosen grams per drink, the category, and history flags carried along compatible links (same sex, age change within the window). `ep_make_risk` turns waves into origin-destination pairs for each interval, ages 18-65 at origin, with official panel weights for VI->VII and known deaths removed for VII->VIII."),
    ("ep_x", "eps-shared-definitions-weights", "**Response models, IPW and design.** Weighted logistic fits (`ep_binary_fit`), weighted quantiles, the three-stage v1 inverse-probability weights (classified at origin, linked, classified at destination; capped at the 1st and 99th percentiles and renormalised to each interval's pair count), the published PSU/stratum design and its JKn replicate multipliers, and person bootstrap multipliers."),
    ("ep_formula", "eps-shared-definitions-models", "**Transition models.** The common formula (origin state, sex x age group, interval, log prior grams, education), the lognormal and gamma amount fits, ordinal/multinomial class fits, the shrinkage matrix model A, the model catalogue, and `ep_prob`, which turns participation plus amount into class probabilities by integrating between the cuts."),
    ("ep_loss", "eps-shared-definitions-cv", "**Scores and cross-validation.** Logloss, Brier and accuracy; person-blocked folds; the inner tuning of A's shrinkage; the 5 x 3 cross-validation with IPW refitted inside each training fold; score tables and design-based paired contrasts."),
    ("ep_matrices", "eps-shared-definitions-inference", "**Matrices and uncertainty.** Group matrices from predicted probabilities (NC written to N0 or FD by origin history), the targets and coefficients exported, the stratified JKn replicates and their variance, interval construction on the probability scale, and the person bootstrap."),
    ("ep_ij", "eps-shared-definitions-annual", "**Annual layer.** A continuous-time generator with allowed transitions `ep_ij`, the matrix exponential, and a penalised fit of the generator to the interval matrices to obtain one-year probabilities."),
    ("ep_transport", "eps-shared-definitions-diagnostics", "**Diagnostics.** Transport between intervals, rank coupling versus the panel, earlier history, Taylor sensitivity, Chapman-Kolmogorov and the HED item checks. `ep_history_check` and `ep_ck` keep the strict 3-5 year VI->VII window; v4 does not reuse them."),
    ("ep_diagram", "eps-shared-definitions-plots", "**Diagrams and figures** of versions 1 and 2."),
]
HIDDEN = ["eps-setup", "eps-inputs", "eps-harmonize"]

def read(path):
    if not path.is_file():
        sys.exit(f"Missing source file: {path}")
    return path.read_text(encoding="utf-8")

CORE = read(DIR / "eps_markov_core.R")
EXTRA = read(LAYERS / "eps_markov_v4_extra.R")
SECTIONS = read(LAYERS / "eps_markov_v4_sections.R")
NARRATIVE = read(DIR / "eps_markov_v4_narrative.md")
sha = lambda text: hashlib.sha256(text.encode("utf-8")).hexdigest()
md5 = lambda text: hashlib.md5(text.encode("utf-8")).hexdigest()

def code(label, body, wrap=True):
    head = f"#| label: {label}\n"
    return nb.v4.new_code_cell(head + (".t0 <- Sys.time()\n" + body.strip() + ELAPSED if wrap else body))

def label_of(cell):
    m = re.match(r"#\| label: (\S+)", cell.source) if cell.cell_type == "code" else None
    return m.group(1) if m else None

def sub_once(pattern, repl, text, what):
    new, n = re.subn(pattern, repl, text, flags=re.M)
    assert n == 1, f"Expected exactly one match for {what}, found {n}"
    return new

# Base: the v2 notebook, outputs stripped; its embedded core must equal the current core file.
base = nb.read(BASE, as_version=4)
cells = [c for c in base.cells if not (c.metadata.get("eps_result_summary") or c.metadata.get("eps_reproduction"))]
for c in cells:
    if c.cell_type == "code":
        c.outputs, c.execution_count = [], None
        c.metadata.pop("execution", None)
cells[0].source = sub_once(r'^title: ".*"$', f'title: "{TITLE}"', cells[0].source, "title")
cells[0].source = sub_once(r'^subtitle: ".*"$', f'subtitle: "{SUBTITLE}"', cells[0].source, "subtitle")
labels = [label_of(c) for c in cells]
setup = cells[labels.index("eps-session-setup")]
setup.source = sub_once(r'here::i_am\("__andres_control/eps_markov_transitions_v2_EN\.ipynb"\)', f'here::i_am("{TARGET}")', setup.source, "here::i_am")
core_cell = cells[labels.index("eps-shared-definitions")]
assert CORE.strip() in core_cell.source, "The v2 notebook embeds a different eps_markov_core.R: rebuild/re-execute v2 first"

# Split the core into explained chunks; the pieces must concatenate back to the core exactly.
lines = CORE.splitlines(keepends=True)
starts = [0] + [next(i for i, l in enumerate(lines) if re.match(rf"^{re.escape(name)} <- ", l)) for name, _, _ in CORE_CHUNKS[1:]]
assert starts == sorted(starts), "Core chunk markers out of order"
pieces = ["".join(lines[a:b]) for a, b in zip(starts, starts[1:] + [len(lines)])]
assert "".join(pieces) == CORE, "Core split does not reproduce eps_markov_core.R"
core_cells = []
for (name, label, text), piece in zip(CORE_CHUNKS, pieces):
    core_cells.append(nb.v4.new_markdown_cell(text))
    core_cells.append(code(label, piece))
i = labels.index("eps-shared-definitions")
intro = nb.v4.new_markdown_cell("## Shared definitions, explained\n\nThe v1 engine `eps_markov_core.R` is embedded below in chunks, each with a short explanation; together they are the file byte for byte (checked by the notebook builder). The v2 additions follow as one cell.")
cells[i:i + 1] = [intro] + core_cells
k = [label_of(c) for c in cells].index("eps-v2-definitions")
cells.insert(k, nb.v4.new_markdown_cell("**Version 2 additions** (`eps_markov_v2_extra.R`): the agreed attrition covariates read from the public EPS modules, deaths and impeded respondents as competing exits, the survey-weighted response model and the SuperLearner response model, the three weighting schemes with their jackknife matrices, balance diagnostics and the calibration by interval and origin. They are explained where they are used, in the version 2 sections below."))

# The three cells that ep_load() evaluates from the alcohol notebook: shown as markdown, verified by md5 at run time.
alc = json.loads(read(ALCOHOL))["cells"]
src = {}
for c in alc:
    s = "".join(c["source"])
    m = re.match(r"#\| label: (\S+)\n", s)
    if m and m.group(1) in HIDDEN:
        src[m.group(1)] = s
assert set(src) == set(HIDDEN), f"Hidden cells not found: {set(HIDDEN) - set(src)}"
hidden_md = ["## Cells run by `ep_load()` from the alcohol persistence notebook\n\n`ep_load()` does not read data on its own: it evaluates three labelled cells of `eps_alcohol_prevalencia_persistencia.ipynb`. They are reproduced here so the conversion can be audited: `eps-setup` decrypts the EPS bundle and defines readers; `eps-inputs` lists the files read per wave (VI 2015, VII in person 2020, VIII 2023) with their weights; `eps-harmonize` converts the alcohol items. Its function `eps_alcohol()` keeps beverage answers yes/no, frequency codes 0-7 (days per week; 0 = less than weekly, counted as 0.5 days) and quantities (glasses per occasion; non-response codes become missing), and computes grams/day = 12 g x days x glasses / 7, summed over beer, wine and spirits. A 'no' for a beverage with a positive frequency or quantity is a contradiction and becomes missing. The cell after this listing recomputes the md5 of each cell from the notebook file and stops if any differs from the version shown."]
for k in HIDDEN:
    hidden_md.append(f"### `{k}` (md5 `{md5(src[k])}`)\n\n```r\n{src[k].rstrip()}\n```")
check_body = ("cells <- jsonlite::read_json(here::here(\"__andres_control\", \"eps_alcohol_prevalencia_persistencia.ipynb\"))$cells\n"
              "shown <- c(" + ", ".join(f'"{k}" = "{md5(src[k])}"' for k in HIDDEN) + ")\n"
              "now <- vapply(names(shown), function(k) {\n"
              "  s <- vapply(cells, function(x) paste(unlist(x$source), collapse = \"\"), \"\")\n"
              "  s <- s[startsWith(s, paste0(\"#| label: \", k, \"\\n\"))]; stopifnot(length(s) == 1)\n"
              "  f <- tempfile(); on.exit(unlink(f)); con <- file(f, \"wb\"); writeBin(charToRaw(enc2utf8(s)), con); close(con)\n"
              "  unname(tools::md5sum(f)) }, \"\")\n"
              "ep_check(identical(unname(now), unname(shown)), \"Cells run by ep_load() equal the listing shown in this notebook\")")
j = [label_of(c) for c in cells].index("eps-data-design")
if cells[j - 1].cell_type == "markdown":
    j -= 1   # keep the section heading next to its code cell
cells[j:j] = [nb.v4.new_markdown_cell(t) for t in hidden_md] + [code("eps-v4-hidden-cells-check", check_body)]

# v4 block: narrative with placeholders, definition chunks and section bodies.
def split_layer(text, prefix):
    parts = re.split(r"^# @@(\S+)[ \t]*$", text, flags=re.M)
    return parts[0], {parts[i]: parts[i + 1] for i in range(1, len(parts), 2)}
extra_head, defs = split_layer(EXTRA, "eps-v4-def-")
_, bodies = split_layer(SECTIONS, "eps-v4-")
assert not set(defs) & set(bodies), "Definition and section labels overlap"
allb = {**defs, **bodies}
chunks = re.split(r"<!-- code:(\S+) -->", NARRATIVE)
placeholders = chunks[1::2]
assert placeholders == V4_LABELS, f"Placeholders {placeholders} differ from {V4_LABELS}"
assert set(placeholders) == set(allb), f"Placeholders without body: {set(placeholders) - set(allb)}; bodies without placeholder: {set(allb) - set(placeholders)}"
v4_cells = []
for i, label in enumerate(placeholders):
    if chunks[2 * i].strip():
        v4_cells.append(nb.v4.new_markdown_cell(chunks[2 * i].strip() + "\n"))
    body = allb[label]
    if label == "eps-v4-def-config":
        body = "\n".join(l for l in extra_head.splitlines() if not l.startswith(".t0")) + "\n" + body
    body = body.replace(ELAPSED.strip(), "")   # the file-level elapsed line is re-added per cell
    v4_cells.append(code(label, body))
if chunks[-1].strip():
    v4_cells.append(nb.v4.new_markdown_cell(chunks[-1].strip() + "\n"))
refs = [i for i, c in enumerate(cells) if c.cell_type == "markdown" and c.source.startswith("## References")]
assert len(refs) == 1, "References cell not found exactly once"
cells[refs[0]:refs[0]] = v4_cells
cells[refs[0] + len(v4_cells)].source = cells[refs[0] + len(v4_cells)].source.rstrip() + (
    "\n- Puka K, Buckley C, Mulia N, Lasserre AM, Rehm J, Probst C (2022). Behavioral stability of alcohol consumption and socio-demographic correlates of change among a nationally representative cohort of US adults. *Addiction* 118(1):61-70. https://doi.org/10.1111/add.16024"
    "\n- Kilian C et al. (2025). Targeting alcohol use in high-risk population groups: a US microsimulation study of beverage-specific pricing policies. *Lancet Public Health*. https://doi.org/10.1016/S2468-2667(25)00165-3"
    "\n- Ruiz-Tagle Maturana J, Roman Mella F, Castillo-Carniglia A (2026). Sex and age differences in alcohol-attributable mortality in Chile between 2008 and 2022. *Public Health in Practice* 11:100798. https://doi.org/10.1016/j.puhip.2026.100798\n")

doc = nb.v4.new_notebook(cells=cells, metadata={
    "kernelspec": {"display_name": "R", "language": "R", "name": "ir"},
    "language_info": base.metadata.get("language_info", {"name": "R"}),
    "eps_v4_revision": {"language": "en", "core_sha256": sha(CORE), "extra_sha256": sha(EXTRA), "sections_sha256": sha(SECTIONS),
                        "narrative_sha256": sha(NARRATIVE), "base_notebook_sha256": hashlib.sha256(BASE.read_bytes()).hexdigest(),
                        "hidden_cells_md5": {k: md5(src[k]) for k in HIDDEN}}})
nb.validate(doc)
nb.write(doc, OUT)
all_labels = [l for l in map(label_of, doc.cells) if l]
assert len(all_labels) == len(set(all_labels)), "Duplicate cell labels"
print(f"{OUT.name}: {len(doc.cells)} cells, {len(all_labels)} code cells")
