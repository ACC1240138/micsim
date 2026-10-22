"""Build the English ELSOC weighting-scenarios notebook from the narrative and the cell bodies.

Sources (under __andres_control/): elsoc_weighting_scenarios_EN.md (markdown with
"<!-- code:label -->" placeholders) and elsoc_weighting_sections.R (bodies separated by
"# @@label" lines). The analyses are elsoc_2021_2023_exploration/weight_scenarios.R and state_transitions.R,
sourced by their code cells; their hashes are recorded in the notebook metadata.
"""
from pathlib import Path
import argparse
import hashlib
import re
import sys
import nbformat as nb

parser = argparse.ArgumentParser()
parser.add_argument("--keep-outputs", action="store_true", help="Preserve executed cells whose complete code is unchanged")
parser.add_argument("--out", help="Notebook path to write (default __andres_control/elsoc_weighting_scenarios_EN.ipynb)")
ARGS = parser.parse_args()

ROOT = next(p for p in Path(__file__).resolve().parents if (p / ".acc_root").is_file())
DIR = ROOT / "__andres_control"
OUT = Path(ARGS.out) if ARGS.out else DIR / "elsoc_weighting_scenarios_EN.ipynb"
ELAPSED = '\ncat(sprintf("Elapsed: %.2f minutes\\n", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))\n'

def read(path):
    if not path.is_file():
        sys.exit(f"Missing source file: {path}")
    return path.read_text(encoding="utf-8")

SECTIONS = read(DIR / "elsoc_weighting_sections.R")
NARRATIVE = read(DIR / "elsoc_weighting_scenarios_EN.md")
SCRIPT = read(DIR / "elsoc_2021_2023_exploration" / "weight_scenarios.R")
STATES = read(DIR / "elsoc_2021_2023_exploration" / "state_transitions.R")

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
cells.append(nb.v4.new_markdown_cell(chunks[-1].strip() + "\n"))

sha = lambda text: hashlib.sha256(text.encode("utf-8")).hexdigest()
doc = nb.v4.new_notebook(cells=cells, metadata={
    "kernelspec": {"display_name": "R", "language": "R", "name": "ir"},
    "language_info": {"name": "R"},
    "elsoc_weighting_revision": {"language": "en", "script_sha256": sha(SCRIPT), "states_script_sha256": sha(STATES), "sections_sha256": sha(SECTIONS), "narrative_sha256": sha(NARRATIVE)}})
if ARGS.keep_outputs and OUT.exists():
    old = nb.read(OUT, as_version=4)
    executed = {c.source: c for c in old.cells if c.cell_type == "code"}
    doc.cells = [executed.get(c.source, c) if c.cell_type == "code" else c for c in doc.cells]
nb.validate(doc)
nb.write(doc, OUT)
print(f"{OUT.name}: {len(cells)} cells, {sum(c.cell_type == 'code' for c in cells)} code cells, labels {', '.join(labels)}")
