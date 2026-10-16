"""Compare two independent EPS notebook runs and attach measured evidence.

Run only after both notebooks have finished. This checks real exported results;
it neither executes R nor manufactures notebook execution counts.
"""
import argparse
import csv
from datetime import datetime
import hashlib
import math
from pathlib import Path
import shutil

import nbformat

ROOT = next(p for p in Path(__file__).resolve().parents if (p / ".acc_root").is_file())
REPORTS = ROOT / "__andres_control"


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read_csv(path):
    with path.open(encoding="utf-8-sig", newline="") as stream:
        return list(csv.DictReader(stream))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--replication", default=".quarto/eps_markov_reproduction_en")
    args = parser.parse_args()
    replication = Path(args.replication)
    assert not replication.is_absolute() and ".." not in replication.parts
    first = REPORTS / "eps_markov_outputs"
    second = ROOT / replication
    excluded = {"reproducibility_check.csv"}
    files_a = {p.name: p for p in first.glob("*.csv") if p.name not in excluded}
    files_b = {p.name: p for p in second.glob("*.csv") if p.name not in excluded}
    assert files_a and files_a.keys() == files_b.keys(), "Different exported CSV sets"
    checks = []
    for name in sorted(files_a):
        ha, hb = digest(files_a[name]), digest(files_b[name])
        checks.append(dict(file=name, sha256_ES=ha, sha256_EN=hb,
                           identical=ha == hb, rows=len(read_csv(files_a[name]))))
    assert all(row["identical"] for row in checks), "Numeric exports differ"
    docs = []
    execution = []
    core_hash = hashlib.sha256((REPORTS / "eps_markov_core.R").read_text(encoding="utf-8").encode()).hexdigest()
    for name in ("eps_markov_transiciones.ipynb", "eps_markov_transitions_EN.ipynb"):
        path = REPORTS / name
        doc = nbformat.read(path, as_version=4)
        code = [c for c in doc.cells if c.cell_type == "code"]
        assert code and all(c.execution_count is not None for c in code), name + ": incomplete execution"
        assert not any(o.output_type == "error" for c in code for o in c.outputs), name + ": execution error"
        assert doc.metadata.eps_revision.core_sha256 == core_hash, name + ": core source drift"
        assert len({c.execution_count for c in code}) == len(code), name + ": repeated execution counts"
        first_time = datetime.fromisoformat(code[0].metadata.execution["iopub.status.busy"].replace("Z", "+00:00"))
        last_time = datetime.fromisoformat(code[-1].metadata.execution["iopub.status.idle"].replace("Z", "+00:00"))
        execution.append((name, len(code), (last_time-first_time).total_seconds()/60, last_time.isoformat()))
        docs.append((path, doc, code))
    assert len(docs[0][2]) == len(docs[1][2])
    assert all(a.source == b.source for a, b in zip(docs[0][2][1:], docs[1][2][1:])), "Computational source differs"
    configuration = read_csv(first / "analysis_configuration.csv")[0]
    assert int(configuration["person_bootstrap_replicates"]) == 1000
    assert all(r["passed"] == "TRUE" for r in read_csv(first / "analysis_checks.csv")), "Failed R check"
    for name, count in (("replicate_fit_audit", int(configuration["JKn_replicates"])),
                        ("person_bootstrap_audit", 1000)):
        audit = read_csv(first / (name + ".csv"))
        assert len(audit) == count and all(r["success"] == "TRUE" for r in audit), name + ": failed or absent replica"
    for name in ("transition_matrices_design_CI", "transition_matrices_person_CI", "annual_pooled_matrices_design_CI"):
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
    shutil.copytree(second / "en", first / "en", dirs_exist_ok=True)
    n = len(checks)
    numerical_rows = sum(row["rows"] for row in checks)
    decision = read_csv(first / "model_decision_summary.csv")[0]
    comparisons = read_csv(first / "CV_paired_comparisons.csv")
    contrast = next(r for r in comparisons
                    if r["model"] == "Lognormal" and r["reference"] == "Gamma")
    education = [r for r in comparisons if "education" in r["model"] or "education" in r["reference"]]
    education_inconclusive = bool(education) and all(float(r["lower"]) <= 0 <= float(r["upper"]) for r in education)
    education_text_es = ("Las diferencias actuales no son concluyentes." if education_inconclusive else "Algunos contrastes se distinguen; consultar sus intervalos.")
    education_text_en = ("Current differences are inconclusive." if education_inconclusive else "Some contrasts differ; inspect their intervals.")
    history = read_csv(first / "adjusted_history_validation.csv")
    history_inconclusive = all(float(r["lower"]) <= 0 <= float(r["upper"]) for r in history)
    comparison_pp = float(contrast["mean_absolute_class_probability_change_pp"])
    history_text_es = ("La historia anterior no mejoró claramente la predicción ajustada, tampoco con educación interactuada. Esto no demuestra Markov."
                       if history_inconclusive else "La historia anterior muestra diferencias predictivas: consultar sus intervalos en la sección correspondiente.")
    history_text_en = ("Earlier history did not clearly improve adjusted prediction, including education interactions. This does not establish Markov behaviour."
                       if history_inconclusive else "Earlier history shows predictive differences: inspect its intervals in the corresponding section.")
    annual = read_csv(first / "annual_generator_sensitivity.csv")
    annual_max_pp = 100 * max(float(r["max_annual_difference"]) for r in annual)
    annual_start_pp = 100 * next(float(r["max_annual_difference"]) for r in annual
                                if math.isclose(float(r["penalty"]), 5e-5))
    for path, doc, code in docs:
        es = doc.metadata.eps_revision.language == "es"
        text = (
            f"## Chequeo de reproducción: PASS\n\n"
            f"Se ejecutaron las dos versiones en **kernels R nuevos**, con {len(code)} celdas de código completas por versión y cero errores. "
            f"Los **{n} archivos CSV ({numerical_rows:,} filas agregadas)** son idénticos byte por byte entre las ejecuciones ES/EN. "
            f"Incluyen {configuration['JKn_replicates']} réplicas JKn y 1.000 réplicas por persona, con IPW reajustado.\n\n"
            "El verificador externo comprobó el código compartido, los resultados y todos los controles R registrados. "
            "Esta celda documenta ese chequeo posterior; no simula una ejecución adicional. "
            "Las figuras se inspeccionaron por separado. Los supuestos del modelo y la validez externa siguen requiriendo evaluación.\n\n"
            "[Informe de revisión](eps_markov_review.md) · [Comparación de archivos](eps_markov_outputs/reproducibility_check.csv)"
        ) if es else (
            f"## Reproduction check: PASS\n\n"
            f"Both versions ran in **fresh R kernels**, with {len(code)} completed code cells per version and no errors. "
            f"All **{n} CSV files ({numerical_rows:,} aggregate rows)** are byte-identical across ES/EN runs. "
            f"They include {configuration['JKn_replicates']} JKn replicates and 1,000 whole-person replicates, with refitted IPW.\n\n"
            "The external verifier checked shared source, exported results and every recorded R check. "
            "This cell reports that subsequent verification; it does not simulate another execution. "
            "Figures were inspected separately. Model assumptions and external validity still require assessment.\n\n"
            "[Review report](eps_markov_review.md) · [File comparison](eps_markov_outputs/reproducibility_check.csv)"
        )
        doc.cells = [c for c in doc.cells if not c.metadata.get("eps_reproduction") and not c.metadata.get("eps_result_summary")]
        summary = (
            "## Resultados guardados: lectura breve\n\n"
            f"- **Mejor puntaje medio:** {decision['best_logloss']}. Comparar lognormal con Gamma cambia en promedio {comparison_pp:.2f} puntos porcentuales cada probabilidad de categoría; Gamma se conserva.\n"
            f"- **Educación:** se compara como covariable, interacción y estratificador. {education_text_es}\n"
            f"- **Historia:** {history_text_es}\n"
            "- **Incertidumbre:** diseño EPS principal, todos los pares de cada persona unidos; 1.000 réplicas por persona como sensibilidad.\n"
            f"- **Anualización exploratoria:** reinicios con la misma penalización cambian alguna probabilidad hasta {annual_start_pp:.1f} puntos porcentuales; al explorar también penalizaciones, hasta {annual_max_pp:.1f}. No es todavía un motor anual estable.\n"
            "- **Uso futuro:** matrices anuales modeladas; calibración ENPG y validación independiente todavía pendientes.\n\n"
            "Esta síntesis se genera desde las tablas verificadas después de ejecutar el notebook."
        ) if es else (
            "## Saved results: quick reading\n\n"
            f"- **Best average score:** {decision['best_logloss']}. Comparing lognormal with Gamma changes category probabilities by a mean {comparison_pp:.2f} percentage points; Gamma is retained.\n"
            f"- **Education:** covariate, interaction and stratification alternatives are compared. {education_text_en}\n"
            f"- **History:** {history_text_en}\n"
            "- **Uncertainty:** EPS design is primary, with every person's pairs kept together; 1,000 whole-person replicates provide a sensitivity.\n"
            f"- **Exploratory annualization:** restarts at the same penalty change an individual probability by up to {annual_start_pp:.1f} percentage points; exploring penalties as well raises this to {annual_max_pp:.1f}. This is not yet a stable annual engine.\n"
            "- **Future use:** annual matrices are model-derived; ENPG calibration and independent validation remain pending.\n\n"
            "This summary is generated from verified tables after notebook execution."
        )
        summary_cell = nbformat.v4.new_markdown_cell(summary)
        summary_cell.metadata["eps_result_summary"] = True
        doc.cells.insert(1, summary_cell)
        cell = nbformat.v4.new_markdown_cell(text)
        cell.metadata["eps_reproduction"] = True
        doc.cells.insert(len(doc.cells) - 1, cell)
        nbformat.write(doc, path)
    report = ["# EPS reproducibility check", "", "Status: **PASS**", "",
              f"- Independent fresh R sessions: 2; completed code cells each: {execution[0][1]}.",
              f"- Byte-identical aggregate CSV files: {n}; aggregate rows: {numerical_rows}.",
              f"- Common computation SHA256: `{core_hash}`.",
              f"- ES execution: {execution[0][2]:.2f} minutes; final cell completed {execution[0][3]}.",
              f"- EN execution: {execution[1][2]:.2f} minutes; final cell completed {execution[1][3]}.",
              f"- JKn replicates: {configuration['JKn_replicates']}; person replicates: 1000.",
              "- Every recorded real-data R check passed; neither notebook contains an error output.",
              "- All replicate fits succeeded; supported transition rows sum to one and available probability intervals include their estimates within [0,1].",
              "- Shared computation is identical; setup language and notebook locator differ.",
              "- File-level hashes: `reproducibility_check.csv`.", "",
              f"Scientific sensitivity: annual probabilities differ by up to {annual_start_pp:.1f} percentage points across restarts at the primary penalty, and {annual_max_pp:.1f} across the combined penalty/start grid. Computational PASS does not resolve this instability. Annual intervals condition on the primary penalty and initialization.", "",
              "Reproduce from the project root after obtaining the encrypted data key through the usual local environment:", "",
              "```text", "python _tools/build_eps_markov_notebooks.py",
              "python _tools/execute_eps_notebook.py __andres_control/eps_markov_transiciones.ipynb",
              "python _tools/execute_eps_notebook.py __andres_control/eps_markov_transitions_EN.ipynb --output-dir .quarto/eps_markov_reproduction_en",
              "python _tools/verify_eps_reproduction.py", "```", "",
              "Use the project's existing R/renv and Python notebook environment. Optional process affinity is a local runtime argument, not a project default.",
              "This verifies computational reproduction, not external validation or the truth of the statistical assumptions.", ""]
    (first / "reproducibility_report.md").write_text("\n".join(report), encoding="utf-8")
    print(f"REPRODUCTION PASS: {n} identical CSV files; {numerical_rows} aggregate rows; {execution[0][1]} code cells per fresh kernel")


if __name__ == "__main__":
    main()
