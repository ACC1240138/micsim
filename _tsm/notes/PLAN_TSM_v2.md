# TSM ENPG version 2

Authorized scope: new executed English notebook and standalone Quarto HTML; preserve all earlier files. Keep ENPG categories 1–4, observed former drinking and unknown history. Use Calvo 2020 frequency-times-quantity conversion, 12 g primary and 15.7 g sensitivity. Keep all consecutive-wave pairs. Compare empirical weighted transitions, Gamma, lognormal and proportional-odds ordinal predictions using held-out consumption categories, not RMSE. Explain JRT predictors and TSM's incomplete measurement of the 5/4 ENPG HED target.

1. Verify sources and definitions. Check: JRT formula and conversion lines read, no false claim that HED enters JRT. Output: provenance table in notebook.
2. Reuse tested loader/history/weights and add only model-comparison functions. Check: structural zeros, no future leakage, absent outcome categories, ID-disjoint folds, probability sums.
3. Execute on real SAV data. Check: expected 4,175 observed pairs and 1,934 IDs; categorical scoring and resampling audited. Output: aggregate CSVs and saved notebook outputs.
4. Render and review. Check: display equations really render, figures and styles are embedded, old hashes match. Output: notebook, English HTML and short findings note.

Independent reviews assigned: ordinal fitting and sparse outcomes; provenance/diagram/equation rendering; panel/CV logic. Ponytail instruction: reuse the existing core, avoid new dependencies, and mark any necessary simplification with its limit.

Current findings: cvolaj uses the 12 g pathway before APC, cvolajms the 15.7 g pathway. JRT adjusts for previous category, age group, sex and their pairwise interactions; HED is carried but not in the fit. Original notebook equations used escaped bracket delimiters that Pandoc did not interpret as math. New notebook will use dollar math delimiters and offline-renderable math.

Execution complete: 13 code cells ran on the actual SAV files; 4,175 pairs and 1,934 linked people verified. Five person folds completed with identical test rows and weights across four models. Both 500-replicate bootstrap branches completed without failed refits. Independent model, panel and provenance reviews found no remaining analytical blockers after a table-to-matrix coercion fix. The new HTML embeds all ten figures; 30 delivery checks pass and 172 earlier files retain their hashes.

Browser review complete: the default KaTeX method dynamically requested CDN resources despite the standalone HTML setting. The final notebook instead uses native MathML: 32 mathematical expressions, including six display equations, render without network access. All six display equations were visually inspected in real Chrome screenshots with networking disabled. No equation errors or browser runtime errors were found. HTML, notebook and aggregate findings are ready.
