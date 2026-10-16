# EPS transitions revision

Scope: replace the working Spanish notebook and add an English counterpart, using
the same computation and the TSM palette. The previous notebook, HTML, report,
and outputs were preserved in the ignored `.quarto/eps_markov_backup/` folder.

1. **Evidence audit:** verify actual design identifiers, weight purposes, history
   definitions, and EPS V availability. Check: source passages and live metadata.
2. **Estimation:** retain C1–C4, use appropriate EPS weights plus additional IPW,
   preserve person trajectories, refit IPW during replication, and compare models
   with common predictors. Check: probability sums, class alignment, weight-scale
   invariance, grouped validation, and real-data support.
3. **Presentation:** Spanish and English notebooks, explicit equations and state
   definitions, diagrams, a consistent blue/terracotta/olive palette, and concise
   conclusions generated from current results. Check: rendered figures/tables.
4. **Review and reproduction:** independent statistical review, two fresh runs,
   aggregate-output comparison, and self-contained Quarto HTML. Check: successful
   execution, deterministic numeric artifacts, and embedded resources.

Decisions confirmed by the user: EPS sampling design is primary; repeated pairs
from one person must remain together. Person-only bootstrap is a sensitivity.
No UPM or stratum is invented. The user subsequently authorized committing and
pushing the completed, verified work with the exact message
`Prueba de EPS como motor de transicion de consumo`. Microdata remain encrypted.

Progress evidence:

- Evidence audit completed: published EPS design and weight purposes checked;
  prospective history rule and EPS V limitations resolved.
- Independent model and inference reviews completed. They confirmed design
  replication preserves repeated IDs and identified no remaining source blocker.
- Candidate execution completed all 111 JKn fits and 1,000 person bootstrap fits.
  A numerical tail-interval issue was corrected and tested, with unchanged point
  estimates and SEs. A later ordinal transport initialization failure was then
  corrected using finite weighted-marginal starts.
- A real-data check of every remaining function passed: transport, adjusted
  history, rank matching, annualization, conversions, high-quantity signal and
  plots. Both final fresh-session runs completed: 11 code cells each, no errors,
  all 111 JKn fits and 1,000 whole-person bootstrap fits successful per run.
- Numeric reproduction passed: 42 byte-identical CSVs, 7,246 aggregate rows,
  and all 47 recorded real-data assertions passed. Final computation took
  21.27 minutes in Spanish and 20.88 minutes in English.
- Final render checks passed for both self-contained HTML files: ten embedded
  figures each, MathML equations, no external asset dependencies or absolute
  user paths. Spanish rank matching/CV and English pooled matrices were
  visually inspected; the diagrams had also been inspected during preparation.
- Annual sensitivity is substantial (10.5 percentage points across starts at
  the primary penalty; 33.8 across the combined penalty/start grid). This is
  documented prominently; computational reproduction does not establish a
  stable annual engine. Between-wave estimates remain the main result.
- The completed deliverables are ready for the authorized commit and push.
