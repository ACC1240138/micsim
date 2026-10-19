"""Build the English TSM v3 notebook from the narrative, the cell bodies and the two R layers.

Sources (all under __andres_control/): TSM_ENPG_v3_EN.md (markdown with
"<!-- code:label -->" placeholders), tsm_markov_sections.R (bodies separated by
"# @@label" lines), tsm_markov_data.R and tsm_markov_models.R (embedded verbatim
as definition cells right after tsm-session-setup).

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
parser.add_argument("--out", help="Notebook path to write (default __andres_control/TSM_ENPG_v3_EN.ipynb); for tests")
ARGS = parser.parse_args()

ROOT = next(p for p in Path(__file__).resolve().parents if (p / ".acc_root").is_file())
DIR = ROOT / "__andres_control"
LAYERS = Path(os.environ.get("TSM_LAYER_DIR", DIR))
OUT = Path(ARGS.out) if ARGS.out else DIR / "TSM_ENPG_v3_EN.ipynb"
ELAPSED = '\ncat(sprintf("Elapsed: %.2f minutes\\n", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))\n'

def read(path):
    if not path.is_file():
        sys.exit(f"Missing source file: {path}")
    return path.read_text(encoding="utf-8")

DATA = read(LAYERS / "tsm_markov_data.R")
MODELS = read(LAYERS / "tsm_markov_models.R")
SECTIONS = read(DIR / "tsm_markov_sections.R")
NARRATIVE = read(DIR / "TSM_ENPG_v3_EN.md")

def code(label, body):
    return nb.v4.new_code_cell(f"#| label: {label}\n.t0 <- Sys.time()\n" + body.strip() + ELAPSED)

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
        cells.append(code("tsm-data-definitions", DATA))
        cells.append(code("tsm-model-definitions", MODELS))
cells.append(nb.v4.new_markdown_cell(chunks[-1].strip() + "\n"))

sha = lambda text: hashlib.sha256(text.encode("utf-8")).hexdigest()
doc = nb.v4.new_notebook(cells=cells, metadata={
    "kernelspec": {"display_name": "R", "language": "R", "name": "ir"},
    "language_info": {"name": "R"},
    "tsm_revision": {"language": "en", "data_sha256": sha(DATA), "models_sha256": sha(MODELS),
                     "sections_sha256": sha(SECTIONS), "narrative_sha256": sha(NARRATIVE)}})
if ARGS.keep_outputs and OUT.exists():
    old = nb.read(OUT, as_version=4)
    executed = {c.source: c for c in old.cells if c.cell_type == "code"}
    doc.cells = [executed.get(c.source, c) if c.cell_type == "code" else c for c in doc.cells]
nb.validate(doc)
nb.write(doc, OUT)
print(f"{OUT.name}: {len(cells)} cells, {sum(c.cell_type == 'code' for c in cells)} code cells, labels {', '.join(labels)}")
