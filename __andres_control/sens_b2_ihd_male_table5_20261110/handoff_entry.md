
## 2026-11-10 B2 ROUNDING SENS — Table5 IHD_M (precision sens, NOT correction/CI)
- script: __andres_control/sens_b2_ihd_male_table5_20261110/sens_b2_ihd_male_table5.R; pif_point(); validates vs pif2_pif_results_table5_full_20261008 (616 cells, max dev 2.8e-16). No notebook edited; IHD primary stays WHO/Adam.
- printed B2=0,000001 (6dp, 1 sig fig), EE2=0,000000. rounding=>B2∈[0.5e-6,1.5e-6); truncation=>[1e-6,2e-6); report silent. EE2=0 ≠ no uncertainty.
- held fixed: B1=-0.046271, RRformer 1.25, cap HED, x 0.1–150, bundle 20261007, 22 scen (λ0/.5/1), 7y×4 ages. Fact=1/3 stored NOT applied (unvalidated).
- RR: nadir 47/36/31 g; RR=1 at 97/73/62 g (B2 .5/1/1.5e-6). RR@125g 1.58/4.20/11.2; <30g ~identical.
- HED male density >60g 26–32%, >100g 8–13% (2024).
- mean PIF (28 cells, unweighted) vol-10: .008/.050/.181; vol-30: .012/.083/.262; HED-50 λ0: .020/.015/.010; comb30/50 λ0: .032/.099/.274. WHO vol-10 .004.
- AAF mean .064/.138/.317.
- sign: 0 neg cells any B2. magnitude: cell ratio hi/lo median 8.3 (0.44–54). ranking flips in rounding range (low B2: HED-50 > vol-30; pub: vol-30 >> HED-50).
- verdict: Table5 IHD_M NOT interpretable sensitivity at published precision; at most precision band w/ explicit caveat; ask authors full-precision B2 (+Fact, vcov).
- context only (not used to pick B2): WHO base IHD_M same form on (x+.01)/100 → B1≈-0.0487, B2≈1.55e-6 ×beta3; B1≠Table5 → not same fit. WHO base IHD_F reparam B1=-0.05253 = Table5 B1; B2 .01539 vs .01470.
- rho=-0.99 for IHD_F also assumption, not recovered vcov.
