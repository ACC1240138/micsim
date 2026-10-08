"""Patch expand_pif.ipynb: stale markdown (2026-10-07 review) + both Figure 5 PNGs with even years only.

Run from any folder inside the project (finds the root by the .acc_root marker):

    python -I __andres_control/patch_expand_pif_20261008.py            # patch only
    python -I __andres_control/patch_expand_pif_20261008.py --execute  # patch + Run All (Positron's ark kernel)

Idempotent: an edit already applied is skipped; an anchor that is neither old nor new stops the
script before writing anything. Cells are matched by their notebook id, not by position.
Cells 27/51 (coord_cartesian, unused colour scale, Cardiovascular "dashed") are already in git (1beb02b).
--execute reruns the notebook with ark (what Positron does): only the Figure 5 PNG changes need it.
"""
import json, os, sys, time
from pathlib import Path

root = next(p for p in [Path.cwd(), *Path.cwd().parents] if (p / ".acc_root").exists())
NB = root / "__andres_control" / "expand_pif.ipynb"

# (cell id, old text, new text). Old text must occur exactly once in that cell.
EDITS = [
    # --- ENPG (cell 5): period, years_vec, cat1-cat4 bounds as coded in `enpg-consolidate` ---
    ("047f1a0c",
     "National Household Survey on Drug Use: 2008-2022, three-stage sampling,",
     "National Household Survey on Drug Use (ENPG): 2012-2024, seven biennial waves (2012, 2014, 2016, 2018, 2020, 2022, 2024), three-stage sampling,"),
    ("047f1a0c",
     "- `years_vec`: analyzed years, 2008 to 2022.",
     "- `years_vec`: analyzed years, 2012 to 2024 (seven waves)."),
    ("047f1a0c",
     "- `cat1`: >=19.99 g/day in women, >=39.99 g/day in men.  \n"
     "- `cat2`: 20>=39.99 g/day in women, 40>=59.99 g/day in men.  \n"
     "- `cat3`: 40>=60 g/day in women, >=60-100 g/day in men.  \n"
     "- `cat4`: >60 g/day in women, >100 g/day in men.  \n",
     "- `cat1`: >0 to 19.99 g/day in women, >0 to 39.99 g/day in men.  \n"
     "- `cat2`: 20 to 39.99 g/day in women, 40 to 59.99 g/day in men.  \n"
     "- `cat3`: 40 to 100 g/day in women, 60 to 100 g/day in men.  \n"
     "- `cat4`: >100 g/day in women and men.  \n\n"
     "`cat1`-`cat4` are descriptive only: the AAF/PIF engine uses `cvolaj` only for the `ltabs`/`fd` prevalences "
     "and integrates current drinkers' continuous volume (`volajohdia > 0`) through the weighted gamma fit. "
     "`cat3` in women is closed at 100 g/day (WHO category III is open from 40 g/day) and `cat4` (>100 g/day) is "
     "project-specific; document this before the categories are used in the simulation module.  \n"),
    # --- Correct variability (cell 9): 2020 borrows 2018, not the next wave ---
    ("d4bb4921",
     "an explicit fallback from the next wave is provided only for engine use.",
     "an explicit fallback from the previous validated wave of the same cell is provided only for engine use: "
     "2020 borrows 2018, which shares the MM2015 sampling frame (2022 uses the MMV 2020 frame) "
     "(`factor_for_engine_source = fallback_prev_valid_year_same_cell`)."),
    # --- Mortality (cell 12): sources, years, ages ---
    ("e43f8b0e",
     "We read two official death records (one from 1990-2023 and anohter from 2025-2026, available from https://deis.minsal.cl/#datosabiertos), "
     "cleaned and standardized their columns  (`gender`, `age_group`. `region`, `comuna`), filtered individuals aged 15 and older from 2008 onward, "
     "and saved them as a single file ready for analysis. \n\n"
     "As an update, we included records updated one week later (2026-06-09), and we did not restrict to external causes (`DIAG2`).",
     "We read the official DEIS death records (https://deis.minsal.cl/#datosabiertos): the encrypted bundle "
     "`_deis/DEFUNCIONES_DEIS_2012_2023_15plus` for 2012-2023 and, for 2024, the newest DEIS 2024-2026 release returned by "
     "`acc_deis()` (`ACC_DEIS_VERSION` pins one; the release used is printed in the `[acc_deis]` line of the output). "
     "Columns were cleaned and standardized (`gender`, `age_group`, `region`, `comuna`), deaths were restricted to ages 15-65 "
     "inclusive (age in years, `edad_tipo == 1`) from 2012 onward, and both sources were bound into a single table.\n\n"
     "We did not restrict to external causes (`DIAG2`)."),
    # --- mortality code comment (cell 14): comment only, no code change ---
    ("mortality-consolidate-and-update",
     "# JRT took it from DEFUNCIONES_FUENTE_DEIS_2024_2026_02062026, I took from 09062026",
     "# JRT took it from DEFUNCIONES_FUENTE_DEIS_2024_2026_02062026; acc_deis() loads the newest release (see [acc_deis] in the output)"),
    # --- Group by diseases (cell 15): age restriction ---
    ("cd5ede81",
     "As of 2026-06-30, we also restricted mortality to <65 years old for comparability with SENDAs use estimates.",
     "Since 2026-07-10, mortality is restricted to ages 15-65 inclusive (`age <= 65`), matching the ENPG (SENDA) age range "
     "(2026-06-30 used <65)."),
    # --- AAFs (cell 17): former-drinker variance is propagated ---
    ("b3dfffba",
     "Former-drinker variance is recorded but not used in the current version, whereas injury HED/binge uncertainty",
     "Former-drinker RR variance (`varLnRRFormer`) is propagated in the AAF confidence intervals (`fd_uncertainty = TRUE`) "
     "for the chronic/HHD and cardiovascular families and switched off for injuries (`fd_uncertainty = FALSE`, `rr_fd` = 1), "
     "whereas injury HED/binge uncertainty"),
    # --- Change log (cell 19): mark as history ---
    ("0b8b0459",
     "#### Change log\n",
     "#### Change log\n\n*Dated entries are kept as history; the method sections above describe the current pipeline and supersede them.*\n"),
    # --- cell 43: claim not backed by a current output ---
    ("9025df3c",
     "In the 60-65 age group, the attributable risk is lower using survey weights.",
     "**Pending revalidation:** this paragraph describes an earlier unweighted vs survey-weighted comparison; "
     "no current output in this notebook reproduces it.\n\n"
     "In the 60-65 age group, the attributable risk is lower using survey weights."),
    # --- cell 66: age filter is now <= 65 ---
    ("d2e3b9c1",
     "rather than the restricted `60-64` subset that had entered the shared notebook mortality object after the `edad_cant < 65` filter.",
     "rather than the restricted subset of the shared notebook mortality object (`60-64` under the former `edad_cant < 65` filter; "
     "`60-65` since 2026-07-10, `<= 65`)."),
    # --- cell 107: deaths, not AAFs; current numbers; IHD decision ---
    ("3ef5217b",
     "The greatest detected differences in AAFs were in IHD among men aged 45–59 and 60–65, with ~25 more attributable deaths, "
     "respectively. These were followed by men with IHD in the 30–44 age group, with ~9 more attributable deaths.",
     "Largest differences in attributable deaths (PUC Table 5 − WHO 2024), range across the 2012-2024 waves "
     "(2026-10-07 run; the numbers drift with reruns, read the table above):\n\n"
     "- IHD, men 45–59: +71.2 to +95.2 deaths (AAF difference 0.080–0.101).\n"
     "- IHD, men 60–65: +25.7 to +55.4 deaths (AAF difference 0.041–0.070).\n"
     "- IHD, men 30–44: +12.2 to +23.0 deaths (AAF difference 0.080–0.105).\n\n"
     "Since 2026-10-07, WHO is the main IHD RR source (both sexes) and Table 5 is a sensitivity analysis; "
     "ischaemic stroke keeps Table 5 as main (see the handoff)."),
    # --- cell 51 (Figure 5 PNG): even years only, like the displayed plot ---
    ("178073df",
     'fig4 <- mortality_results_cat %>%\n  filter(gender == "Hombre") %>%\n',
     'fig4 <- mortality_results_cat %>%\n  dplyr::filter(year %% 2 == 0, year >= 2012) %>%  # even ENPG waves, as in the displayed plot\n'
     '  filter(gender == "Hombre") %>%\n'),
    # --- cell 52 (Figure 5 without stomach/pancreas): even years in the displayed and saved plot ---
    ("1fed57c8",
     ' mortality_results_cat_not_stomach_pancreas_cancer %>%\n  filter(gender == "Hombre") %>%\n',
     ' mortality_results_cat_not_stomach_pancreas_cancer %>%\n'
     '  dplyr::filter(year %% 2 == 0, year >= 2012) %>%  # even ENPG waves, as in Figure 5\n'
     '  filter(gender == "Hombre") %>%\n'),
]


def find_cell(cells, key):
    """Match by cell id, or by Quarto label for cells whose id we did not pin."""
    hits = [c for c in cells if c.get("id") == key or f"#| label: {key}\n" in "".join(c["source"])]
    if len(hits) != 1:
        sys.exit(f"cell '{key}': {len(hits)} matches, expected 1. Nothing written.")
    return hits[0]


def patch():
    raw = NB.read_text(encoding="utf-8")
    nb = json.loads(raw)
    if json.dumps(nb, indent=1, ensure_ascii=False) + "\n" != raw:
        sys.exit("notebook JSON layout differs from indent=1; refusing to rewrite it. Nothing written.")
    applied = skipped = 0
    for key, old, new in EDITS:
        cell = find_cell(nb["cells"], key)
        src = "".join(cell["source"])
        if new in src:  # already applied (checked first: some new texts contain the old one)
            skipped += 1
            continue
        if src.count(old) != 1:
            sys.exit(f"cell '{key}': old text found {src.count(old)} times, expected 1:\n  {old[:90]!r}\nNothing written.")
        cell["source"] = src.replace(old, new).splitlines(keepends=True)
        applied += 1
    if applied:
        NB.write_text(json.dumps(nb, indent=1, ensure_ascii=False) + "\n", encoding="utf-8", newline="")
    print(f"{NB.name}: {applied} edits applied, {skipped} already present.")


def run_all_ark():
    """Run All in place with Positron's ark kernel, saving outputs (also on error, as Positron would)."""
    import nbformat
    import nbclient.client as ncc
    from jupyter_client.kernelspec import KernelSpecManager
    from nbformat.v4 import output_from_msg as _orig

    if "ark" not in KernelSpecManager().find_kernel_specs():
        sys.exit("No 'ark' kernelspec (Positron registers it). Run All in Positron instead.")

    def _output_from_msg(msg):  # ark sends metadata=None; nbformat requires a dict
        c = msg.get("content", {})
        if isinstance(c, dict) and c.get("metadata", {}) is None:
            c["metadata"] = {}
        return _orig(msg)

    ncc.output_from_msg = _output_from_msg
    os.environ.pop("HOME", None)  # Git Bash sets HOME; R must resolve ~ as Positron does (finds ~/.Renviron)
    nb = nbformat.read(NB, as_version=4)
    t0 = time.time()
    try:
        ncc.NotebookClient(nb, kernel_name="ark", timeout=None,
                           resources={"metadata": {"path": str(NB.parent)}}).execute()
    finally:
        nbformat.write(nb, NB)
        print(f"Run All (ark) saved {NB.name} | {(time.time() - t0) / 60:.1f} min")


if __name__ == "__main__":
    patch()
    if "--execute" in sys.argv:
        run_all_ark()
