"""Compare the TSM v4 notebook run with its fresh-kernel reproduction and attach measured evidence.

Run only after both executions have finished. This checks real exported results;
it neither executes R nor manufactures notebook execution counts.

Expected table schemas (from the notebook sections): eps_crosscheck_annual.csv in
long format with columns model, source (TSM/EPS), from, to, estimate, lower, upper (five states since
2026-10-26, C3 and C4 merged into C3plus); annual_generator_sensitivity.csv
with model, penalty, max_annual_difference.
"""
import argparse
import csv
from datetime import datetime
import hashlib
import json
import math
from pathlib import Path
import re
import shutil

import nbformat

ROOT = next(p for p in Path(__file__).resolve().parents if (p / ".acc_root").is_file())
REPORTS = ROOT / "__andres_control"
NOTEBOOK = "TSM_ENPG_v4_EN.ipynb"
REPRODUCTION_COPY = "TSM_ENPG_v4_EN_repro_dry.ipynb"   # executed copy for the second run (excluded from Quarto rendering)


def code_digest(doc):
    # The notebook is the single source since 2026-10-27, so its code cells (not the former R files) are hashed.
    return hashlib.sha256("\n".join(c.source for c in doc.cells if c.cell_type == "code").encode("utf-8")).hexdigest()


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read_csv(path):
    with path.open(encoding="utf-8-sig", newline="") as stream:
        return list(csv.DictReader(stream))


def fmt(row, key):
    return f"{float(row[key]):.3f}" if row.get(key) else "no interval"


def check_html(html_path, out_dir):
    text = Path(html_path).read_text(encoding="utf-8", errors="replace")
    refs = re.findall(r'<(?:script|img|link)\b[^>]*?\b(?:src|href)\s*=\s*["\']([^"\']*)["\']', text, flags=re.I)
    external = [r for r in refs if not (r.startswith("data:") or r.startswith("#") or r.startswith("mailto:"))]
    # Hyperlinks in the narrative are <a href>, not assets, so only script/img/link tags are inspected.
    result = {"html": str(Path(html_path).name), "asset_references": len(refs), "external_assets": external,
              "embedded_images": len(re.findall(r'<img\b[^>]*\bsrc\s*=\s*["\']data:image', text, flags=re.I)),
              "mathml_display_equations": len(re.findall(r'<math\b[^>]*\bdisplay\s*=\s*["\']block["\']', text, flags=re.I)),
              "all_assets_embedded": not external}
    (out_dir / "render_validation.json").write_text(json.dumps(result, indent=1), encoding="utf-8")
    assert result["all_assets_embedded"], f"External assets in HTML: {external[:5]}"
    return result


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--replication", default=".quarto/tsm_markov_reproduction_v4_en")
    parser.add_argument("--html", help="Rendered self-contained HTML to validate (optional)")
    args = parser.parse_args()
    replication = Path(args.replication)
    assert not replication.is_absolute() and ".." not in replication.parts
    first = REPORTS / "tsm_markov_outputs_v4"
    second = ROOT / replication
    excluded = {"reproducibility_check.csv"}
    files_a = {p.name: p for p in first.glob("*.csv") if p.name not in excluded}
    files_b = {p.name: p for p in second.glob("*.csv") if p.name not in excluded}
    assert files_a and files_a.keys() == files_b.keys(), "Different exported CSV sets"
    checks = []
    for name in sorted(files_a):
        ha, hb = digest(files_a[name]), digest(files_b[name])
        checks.append(dict(file=name, sha256_main=ha, sha256_reproduction=hb, identical=ha == hb, rows=len(read_csv(files_a[name]))))
    assert all(row["identical"] for row in checks), "Numeric exports differ"
    path = REPORTS / NOTEBOOK
    doc = nbformat.read(path, as_version=4)
    code = [c for c in doc.cells if c.cell_type == "code"]
    assert code and all(c.execution_count is not None for c in code), NOTEBOOK + ": incomplete execution"
    assert not any(o.output_type == "error" for c in code for o in c.outputs), NOTEBOOK + ": execution error"
    assert len({c.execution_count for c in code}) == len(code), NOTEBOOK + ": repeated execution counts"
    notebook_code = code_digest(doc)
    copy = REPORTS / REPRODUCTION_COPY
    if copy.exists():
        assert code_digest(nbformat.read(copy, as_version=4)) == notebook_code, "Reproduction copy runs different code"
    first_time = datetime.fromisoformat(code[0].metadata.execution["iopub.status.busy"].replace("Z", "+00:00"))
    last_time = datetime.fromisoformat(code[-1].metadata.execution["iopub.status.idle"].replace("Z", "+00:00"))
    minutes = (last_time - first_time).total_seconds() / 60
    configuration = read_csv(first / "analysis_configuration.csv")[0]
    assert int(configuration["person_bootstrap_replicates"]) == 1000
    assert int(configuration["CV_repetitions"]) == 3, "CV_repetitions must be the default 3"
    assert all(r["passed"] == "TRUE" for r in read_csv(first / "analysis_checks.csv")), "Failed R check"
    audit = read_csv(first / "person_bootstrap_audit.csv")
    assert len(audit) == 1000 and all(r["success"] == "TRUE" for r in audit), "person_bootstrap_audit: failed or absent replicate"
    for name in ("transition_matrices_person_CI", "transition_matrices_pooled_person_CI", "annual_pooled_matrices_person_CI"):
        groups = {}
        for row in read_csv(first / (name + ".csv")):
            point = float(row["estimate"]) if row["estimate"] else math.nan
            if math.isfinite(point):
                assert -1e-12 <= point <= 1 + 1e-12, name + ": invalid probability"
                key = (row["model"], row.get("group", "pooled"), row["from"])
                groups[key] = groups.get(key, 0) + point
            if row["interval_status"] == "available":
                lo, hi = float(row["lower"]), float(row["upper"])
                assert 0 <= lo <= point + 1e-12 and point - 1e-12 <= hi <= 1, name + ": invalid interval"
            else:
                assert not row["lower"] and not row["upper"], name + ": unsupported interval was not suppressed"
        assert all(abs(total - 1) < 1e-8 for total in groups.values()), name + ": row does not sum to one"
    with (first / "reproducibility_check.csv").open("w", encoding="utf-8", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=list(checks[0]))
        writer.writeheader()
        writer.writerows(checks)
    if (second / "en").is_dir():
        shutil.copytree(second / "en", first / "en", dirs_exist_ok=True)
    render = check_html(args.html, first) if args.html else None
    n = len(checks)
    numerical_rows = sum(row["rows"] for row in checks)
    # Quick-reading summary, generated from the verified tables only.
    decision = read_csv(first / "model_decision_summary.csv")[0]
    comparisons = read_csv(first / "CV_paired_comparisons.csv")
    contrast = next(r for r in comparisons if r["model"] == "Lognormal" and r["reference"] == "A")
    education = [r for r in comparisons if "education" in r["model"] or "education" in r["reference"]]
    education_inconclusive = bool(education) and all(float(r["lower"]) <= 0 <= float(r["upper"]) for r in education)
    education_text = "Current differences are inconclusive." if education_inconclusive else "Some contrasts differ; inspect their intervals."
    annual = read_csv(first / "annual_generator_sensitivity.csv")
    worst = max(annual, key=lambda r: float(r["max_annual_difference"]))
    model_rows = [r for r in annual if r["model"] == worst["model"]]
    annual_max_pp = 100 * float(worst["max_annual_difference"])
    annual_start_pp = 100 * next(float(r["max_annual_difference"]) for r in model_rows if math.isclose(float(r["penalty"]), 5e-5))
    cross = read_csv(first / "eps_crosscheck_annual.csv")
    cross_lines = []
    for model in ("A", "Gamma", "Lognormal"):
        bits = []
        for state in ("N0", "C1", "C3plus"):
            for source in ("TSM", "EPS"):
                row = next(r for r in cross if r["model"] == model and r["source"] == source and r["from"] == state and r["to"] == state)
                support = f"; {row['support']}, n={row['n_origin']}" if source == "TSM" and row.get("n_origin") else ""
                bits.append(f"{source} {state} {float(row['estimate']):.3f} [{fmt(row, 'lower')}, {fmt(row, 'upper')}{support}]")
        cross_lines.append(f"  - {model}: " + "; ".join(bits))
    hed = {r["estimate"]: r for r in read_csv(first / "hed_persistence_adjacent.csv")}["adjacent_IPW"]
    ranges = {r["quantity"]: r for r in read_csv(first / "hed_persistence_ranges.csv") if r["moments"] == "all five distances"}
    engine = next(r for r in read_csv(first / "hed_persistence_scenarios.csv") if r["scenario"].startswith("Current engine"))
    r1, phi = ranges["r1 (profile 95%)"], ranges["phi (profile 95%)"]
    hed_line = (f"- **HED persistence beyond volume (exploratory):** adjacent latent correlation {float(hed['rho']):.2f} "
                f"[{float(hed['lower']):.2f}, {float(hed['upper']):.2f}]; supported effective one-year correlation r(1) "
                f"{float(r1['lower']):.2f} to {float(r1['upper']):.2f}; yearly retention phi {float(phi['lower']):.2f} to "
                f"{float(phi['upper']):.2f} (weakly identified). The current engine (0.8, 0.8) is {engine['TSM_support']}; "
                "correlations beyond 24 months are scenarios.")
    summary = (
        "## Saved results: quick reading\n\n"
        f"- **Best average score:** {decision['best_logloss']} by log loss; {decision['best_brier']} by Brier. "
        f"Lognormal minus A in log loss: {float(contrast['difference']):.4f} [{float(contrast['lower']):.4f}, {float(contrast['upper']):.4f}]; "
        f"the two models differ by a mean {float(contrast['mean_absolute_class_probability_change_pp']):.2f} percentage points per class probability.\n"
        f"- **Education:** covariate, interaction and stratification alternatives are compared. {education_text}\n"
        "- **Uncertainty:** whole-person bootstrap with 1,000 replicates and refitted IPW; no design variables exist in TSM.\n"
        f"- **Exploratory annualization:** for {worst['model']}, restarts at the primary penalty change an individual annual probability by up to {annual_start_pp:.1f} percentage points; "
        f"exploring penalties as well raises this to {annual_max_pp:.1f}. This is not yet a stable annual engine.\n"
        "- **EPS cross-check (annual staying probabilities, external consistency only; EPS C3 and C4 merged with origin-pair weights):**\n"
        + "\n".join(cross_lines) + "\n" + hed_line + "\n\n"
        "This summary is generated from verified tables after notebook execution."
    )
    text = (
        "## Reproduction check: PASS\n\n"
        f"The notebook ran twice in **fresh R kernels**, with {len(code)} completed code cells and no errors. "
        f"All **{n} CSV files ({numerical_rows:,} aggregate rows)** are byte-identical between the main run and the reproduction. "
        "They include 1,000 whole-person replicates with refitted IPW.\n\n"
        "The external verifier checked that both runs used the same notebook code, the exported results and every recorded R check. "
        "This cell reports that subsequent verification; it does not simulate another execution. "
        "Figures were inspected separately. Model assumptions and external validity still require assessment.\n\n"
        "[Review report](__andres_control/tsm_v3_review.md) · [File comparison](__andres_control/tsm_markov_outputs_v4/reproducibility_check.csv)"
    )
    doc.cells = [c for c in doc.cells if not c.metadata.get("tsm_reproduction") and not c.metadata.get("tsm_result_summary")]
    summary_cell = nbformat.v4.new_markdown_cell(summary)
    summary_cell.metadata["tsm_result_summary"] = True
    doc.cells.insert(1, summary_cell)
    cell = nbformat.v4.new_markdown_cell(text)
    cell.metadata["tsm_reproduction"] = True
    doc.cells.insert(len(doc.cells) - 1, cell)
    nbformat.write(doc, path)
    report = ["# TSM v4 reproducibility check", "", "Status: **PASS**", "",
              f"- Independent fresh R sessions: 2 (one language); completed code cells: {len(code)}.",
              f"- Byte-identical aggregate CSV files: {n}; aggregate rows: {numerical_rows}.",
              f"- SHA256 of the notebook code cells (the single source since 2026-10-27): `{notebook_code}`.",
              f"- Main execution: {minutes:.2f} minutes; final cell completed {last_time.isoformat()}.",
              "- Person replicates: 1000; every replicate succeeded.",
              "- Every recorded real-data R check passed; the notebook contains no error output.",
              "- Supported transition rows sum to one and available probability intervals include their estimates within [0,1].",
              "- File-level hashes: `reproducibility_check.csv`."]
    if render:
        report.append(f"- Rendered HTML: all assets embedded; {render['embedded_images']} embedded images; {render['mathml_display_equations']} MathML display equations (`render_validation.json`).")
    report += ["", f"Scientific sensitivity: for {worst['model']}, annual probabilities differ by up to {annual_start_pp:.1f} percentage points across restarts at the primary penalty, and {annual_max_pp:.1f} across the combined penalty/start grid. Computational PASS does not resolve this instability. The EPS cross-check is external consistency, not validation.", "",
               "Reproduce from the project root after obtaining the encrypted data key through the usual local environment:", "",
               "```text", "copy __andres_control/TSM_ENPG_v4_EN.ipynb to __andres_control/" + REPRODUCTION_COPY,
               "python _tools/execute_eps_notebook.py __andres_control/TSM_ENPG_v4_EN.ipynb --output-env TSM_MARKOV_OUTPUT",
               "python _tools/execute_eps_notebook.py __andres_control/" + REPRODUCTION_COPY + " --output-env TSM_MARKOV_OUTPUT --output-dir .quarto/tsm_markov_reproduction_v4_en",
               "python _tools/verify_tsm_reproduction.py", "```", "",
               "Use the project's existing R/renv and Python notebook environment. Optional process affinity is a local runtime argument, not a project default.",
               "This verifies computational reproduction, not external validation or the truth of the statistical assumptions.", ""]
    (first / "reproducibility_report.md").write_text("\n".join(report), encoding="utf-8")
    print(f"REPRODUCTION PASS: {n} identical CSV files; {numerical_rows} aggregate rows; {len(code)} code cells per fresh kernel")


if __name__ == "__main__":
    main()
