# table5_ihd_cov_handoff | 2026-11-10 | FONDECYT 1240138 | PIF expand_pif3

## SRC
- PUC/SENDA 2018 "Costo Económico y Social Consumo Alcohol Chile 2017–Act.2018" (Margozzini PI; Zitko epi). Local: micsim/_bib/local/PUC-SENDA Estudios de costos alcohol.pdf (from ACC email 2026-05-12).
- Tabla5 p61 (pdf) = RR fn params {B1,EE1,B2,EE2,Fact,comparador,RR_former}. GSheet copy: 1bNCtpMnR18fK6CTLbzsa2KNiILdrg8VkAswrYuScgMk (tabs "tabla 5","anexo 2").
- p161 (pdf; printed 160) verbatim: "Los anexos se adjuntan en CD en formato electrónico". Anexo1=consumption-distribution fitting; Anexo2=Tablas y Figuras cap IV (RR spec); Anexo3=AVISA; Anexo4=PAF by sex×age. Not public.
- Email to Zitko 2026-10-07 (pedrozitko@gmail.com) requesting Anexo2: NO reply as of 2026-11-10.

## MODEL (mortality rows used in PIF)
x=g/day; RR=exp(lnRR); no intercept (RR(0)=1)
- IHD_F: lnRR=B1*x+B2*x*ln(x); B1=-0.052526(EE .032510); B2=0.014704(EE .007925); Fact=1/20; RRformer=1.54[1.17-2.03]
- IHD_M: lnRR=B1*sqrt(x)+B2*x^3; B1=-0.046271(EE .024037); B2=0.000001(EE 0); Fact=1/3; RRformer=1.25[1.15-1.36]
- IS_F:  lnRR=B1*sqrt(x)+B2*x; B1=-0.249674(EE .019163); B2=0.037207(EE .000523); Fact=1
- IS_M:  lnRR=B1*sqrt(x)+B2*sqrt(x)*ln(x); B1=-0.141950(EE .012866); B2=0.039613(EE .001782); Fact=1
- B1=protective term(<0); B2=harmful term(>0); J-curve = B1 vs B2 net.

## CODE STATE
- table5_make_record(): covBetaCurrent=diag(EE1^2,EE2^2) => rho(B1,B2)=0 assumed.
- Fact stored, NOT applied as x-scale.
- Same RR repeated across Adam age bands (15-34,35-64,65+).
- Roles (user decisions 2026-10-07/08): IHD primary=WHO/Adam, Table5=sensitivity; IS primary=Table5.
- Neg PIF retained+flagged, no clip, no monotonicity.

## PROBLEM
- expand_pif3.html: "Table 5 IHD-female upper limit is degenerate (missing b1/b2 covariance)"; 336/588 non-baseline cells UL>50%; 237 UL>90%. IHD_M, IS: none >90%.
- Point PIFs fine; only MC UL explodes.

## MECHANISM (IHD_F)
- rel SE: EE1/|B1|=0.62; EE2/B2=0.54.
- x=5: z=x*ln(x)=8.05; terms -0.263,+0.118; lnRR=-0.144; RR=0.866; SE_ln(indep)=0.175; IC95 RR 0.615–1.22.
- x=50: z=195.6; terms -2.626,+2.876; lnRR=0.250; RR=1.284; per-term SE 1.626,1.550; Var=5.045; SE_ln=2.246; exp(SE)=9.451; factor=9.451^1.96=81.6; IC95 RR 0.0157–104.8.
- 1-SE adverse draw (B1+EE1,B2+EE2) @50: lnRR=3.425; RR=30.7.
- cause: lnRR = small diff of 2 large terms; indep draws break compensation; exp() asymmetry => UL only.
- MC check (10k draws, rho=0): RR>10 in 17%@50g, 33%@75g, 44%@100g.

## FORMULA
Var(lnRR)=a^2+b^2+2*rho*a*b; a=EE1*f1(x); b=EE2*f2(x); cov=rho*EE1*EE2
IC_RR = RR * exp(SE_ln)^(±1.96)
R: 1.283793*9.451259^c(-1.96,1.96)

## RHO SENSITIVITY IHD_F @50g (IC95 RR)
rho +0.5: 0.006–282 | 0: 0.016–105 (current) | -0.5: 0.06–29 | -0.9: 0.32–5.2 | -0.99: 0.81–2.0
@5g: rho0 0.62–1.22; rho-0.9 0.70–1.07 (minor).

## RHO INFERENCE (assumption, not data)
- no-intercept 2-col LS => corr(B1,B2)=f(design cols x, x*ln(x)) only.
- plausible dose grids {6..45},{5,15,30,50,80},{2..120}, equal or 1/x weights => rho∈[-0.996,-0.986].
- check: implied EE1/EE2 = 3.4–4.5; Table5 observed 0.03251/0.007925=4.10 (computed, not printed) => consistent.
- demo: B1±1EE with refit B2 (B1 -0.085→B2 .0225; B1 -0.020→B2 .0069) gives near-identical curve 5–80g => non-identifiability.
- best guess rho≈-0.99; sensitivity -0.98,-0.99. Unverified.

## IHD_M
- B2=0.000001 rounded (6 dp) on x^3 term; B2∈[5e-7,1.5e-6] => RR@100g 1.04–2.8; @125g 1.6–11. Point estimate unreliable.
- EE2=0 => no MC uncertainty => IC too narrow (opposite of F).

## PUC OWN CIs (same coefs) — narrow
- Tabla6 p63 FA mort IHD 18.1% (14.7–21.2); IHME -6.1% (-11.5–0.4); PUC flags as largest discrepancy p64.
- Tabla7 deaths IHD 2053 (1672–2413); Tabla8 AVISA 35673 (29182–42220). rel width ±18%.
- PUC shifted consumption ÷0.2205 (coverage ratio) => mass at 50–100g; still narrow => they used vcov OR didn't propagate RR param uncertainty OR other method. Method in Anexos (CD). Only MC described (p75, 10k) = direct costs.
- not directly comparable: pooled sex, incl former drinkers.

## FACT
- unexplained in report body. Hypothesis: x-scale (x*Fact) for fractional polynomial. If applied, IHD_F eval at x/20 => RR≈<1 across range. Unverified.

## ASK AUTHORS (Zitko/SENDA E.Pizarro via ACC?)
1. vcov(B1,B2) per function.
2. Fact definition/application.
3. full-precision coefs (esp IHD_M B2, cirrosis_M B2).
4. Anexos 1,2,4.

## PROPOSED (not implemented)
- Table5 IHD: report point-only sensitivity, no IC, until vcov.
- optional: rho=-0.98/-0.99 sensitivity in table5_make_record() covBetaCurrent, declared as assumption.
- IS unaffected.

## CAVEATS
- delta-method + standalone RR MC only; full PIF not rerun.
- expand_pif3.html read via summarizer; verify 237/588.
- dose grids assumed.
