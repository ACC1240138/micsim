"""Build the EPS IPW v2 notebook from the executed EN notebook plus the v2 narrative and R layers.

Sources (all under __andres_control/): eps_markov_transitions_EN.ipynb (base: its
cells are copied with outputs stripped and the verifier-inserted cells dropped),
eps_markov_v2_narrative.md (markdown with "<!-- code:label -->" placeholders),
eps_markov_v2_sections.R (bodies separated by "# @@label" lines) and
eps_markov_v2_extra.R (embedded verbatim as the eps-v2-definitions cell).
Contract: __andres_control/eps_ipw_v2_plan_2026-10-19.md.

Testing hooks: EPS_V2_LAYER_DIR (environment) points at a folder holding stand-in
eps_markov_v2_extra.R / eps_markov_v2_sections.R, and --out writes the notebook elsewhere.
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
parser.add_argument("--out", help="Notebook path to write (default __andres_control/eps_markov_transitions_v2_EN.ipynb); for tests")
ARGS = parser.parse_args()

ROOT = next(p for p in Path(__file__).resolve().parents if (p / ".acc_root").is_file())
DIR = ROOT / "__andres_control"
LAYERS = Path(os.environ.get("EPS_V2_LAYER_DIR", DIR))
BASE = DIR / "eps_markov_transitions_EN.ipynb"
OUT = Path(ARGS.out) if ARGS.out else DIR / "eps_markov_transitions_v2_EN.ipynb"
TARGET = "__andres_control/eps_markov_transitions_v2_EN.ipynb"
TITLE = "EPS: alcohol consumption transitions, IPW v2"
SUBTITLE = "Attrition model with the agreed predictors, SuperLearner weights, three weighting schemes and diagnostics"
V2_LABELS = ["eps-v2-attrition", "eps-v2-ipw", "eps-v2-schemes", "eps-v2-diagnostics",
             "eps-v2-calibration-interval", "eps-v2-reproducibility"]
V2_PACKAGES = 'stopifnot(all(vapply(c("SuperLearner","glmnet","ranger"),requireNamespace,logical(1),quietly=TRUE)))'
ELAPSED = '\ncat(sprintf("Elapsed: %.2f minutes\\n", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))\n'

def read(path):
    if not path.is_file():
        sys.exit(f"Missing source file: {path}")
    return path.read_text(encoding="utf-8")

EXTRA = read(LAYERS / "eps_markov_v2_extra.R")
SECTIONS = read(LAYERS / "eps_markov_v2_sections.R")
NARRATIVE = read(DIR / "eps_markov_v2_narrative.md")
if not BASE.is_file():
    sys.exit(f"Missing source file: {BASE}")
sha = lambda text: hashlib.sha256(text.encode("utf-8")).hexdigest()
base_sha = hashlib.sha256(BASE.read_bytes()).hexdigest()

def code(label, body):
    return nb.v4.new_code_cell(f"#| label: {label}\n.t0 <- Sys.time()\n" + body.strip() + ELAPSED)

def label_of(cell):
    m = re.match(r"#\| label: (\S+)", cell.source) if cell.cell_type == "code" else None
    return m.group(1) if m else None

def sub_once(pattern, repl, text, what):
    new, n = re.subn(pattern, repl, text, flags=re.M)
    assert n == 1, f"Expected exactly one match for {what}, found {n}"
    return new

# Base notebook: drop verifier-inserted cells, strip execution state.
base = nb.read(BASE, as_version=4)
cells = [c for c in base.cells if not (c.metadata.get("eps_result_summary") or c.metadata.get("eps_reproduction"))]
for c in cells:
    if c.cell_type == "code":
        c.outputs, c.execution_count = [], None
        c.metadata.pop("execution", None)
assert cells[0].cell_type == "markdown" and cells[0].source.startswith("---"), "First cell is not the YAML header"
cells[0].source = sub_once(r'^title: ".*"$', f'title: "{TITLE}"', cells[0].source, "title")
cells[0].source = sub_once(r'^subtitle: ".*"$', f'subtitle: "{SUBTITLE}"', cells[0].source, "subtitle")
labels = [label_of(c) for c in cells]
setup = cells[labels.index("eps-session-setup")]
setup.source = sub_once(r'here::i_am\("__andres_control/eps_markov_transitions_EN\.ipynb"\)',
                        f'here::i_am("{TARGET}")', setup.source, "here::i_am")
setup.source = sub_once(r"^(stopifnot\(all\(vapply\(required,.*\)\)\))$", r"\1\n" + V2_PACKAGES,
                        setup.source, "required-packages check")
cells.insert(labels.index("eps-shared-definitions") + 1, code("eps-v2-definitions", EXTRA))

# v2 narrative and bodies.
parts = re.split(r"^# @@(\S+)[ \t]*$", SECTIONS, flags=re.M)
bodies = {parts[i]: parts[i + 1] for i in range(1, len(parts), 2)}
chunks = re.split(r"<!-- code:(\S+) -->", NARRATIVE)
placeholders = chunks[1::2]
assert placeholders == V2_LABELS, f"Placeholders {placeholders} differ from the contract order {V2_LABELS}"
assert set(placeholders) == set(bodies), f"Placeholders without body: {set(placeholders) - set(bodies)}; bodies without placeholder: {set(bodies) - set(placeholders)}"
assert all(b.strip() for b in bodies.values()), "Empty cell body"
v2_cells = []
for i, label in enumerate(placeholders):
    v2_cells.append(nb.v4.new_markdown_cell(chunks[2 * i].strip() + "\n"))
    v2_cells.append(code(label, bodies[label]))
if chunks[-1].strip():
    v2_cells.append(nb.v4.new_markdown_cell(chunks[-1].strip() + "\n"))
refs = [i for i, c in enumerate(cells) if c.cell_type == "markdown" and c.source.startswith("## References")]
assert len(refs) == 1, "References cell not found exactly once"
cells[refs[0]:refs[0]] = v2_cells

doc = nb.v4.new_notebook(cells=cells, metadata={
    "kernelspec": {"display_name": "R", "language": "R", "name": "ir"},
    "language_info": base.metadata.get("language_info", {"name": "R"}),
    "eps_v2_revision": {"language": "en", "extra_sha256": sha(EXTRA), "sections_sha256": sha(SECTIONS),
                        "narrative_sha256": sha(NARRATIVE), "base_notebook_sha256": base_sha}})
if ARGS.keep_outputs and OUT.exists():
    old = nb.read(OUT, as_version=4)
    executed = {c.source: c for c in old.cells if c.cell_type == "code"}
    doc.cells = [executed.get(c.source, c) if c.cell_type == "code" else c for c in doc.cells]
nb.validate(doc)
nb.write(doc, OUT)
all_labels = [l for l in map(label_of, doc.cells) if l]
print(f"{OUT.name}: {len(doc.cells)} cells, {len(all_labels)} code cells, labels {', '.join(all_labels)}")
