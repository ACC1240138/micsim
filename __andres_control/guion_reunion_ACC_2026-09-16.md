# Guion reunión con ACC — miércoles 16-sep-2026, 12:00

Todo lo que dice "verificado" está contrastado contra archivos de `ACC1240138_private` (no contra la presentación de abril). Fechas = última modificación de los archivos.

---

## 0. Para abrir (30 segundos)

"Desde mayo dejé cerrado y validado el módulo de mortalidad (AAF/PAF, PIF para las 23 causas y YPLL), audité y reconstruí desde el microdato INE el módulo de elasticidad, armé la ENPG 2012–2024 (7 olas) armonizada con diseño complejo, y sometí a prueba la hipótesis cocaína→alcohol con pseudo-paneles: **no se sostiene** (desistimiento, no sustitución). Lo que **no** se ha tocado desde abril es el motor de simulación ni la integración, y ése es el cuello de botella. Propongo cerrarlo en 8 semanas usando el código de SIMAH como plantilla, con dos políticas: tamizaje + intervención breve (97% de consenso en el Delphi) y precio (paper de JRT)."

---

## 1. Qué he hecho en el FONDECYT (mayo → septiembre)

| Cuándo | Qué | Estado | Evidencia (archivo) |
|---|---|---|---|
| 15-may | Inventario y mapa del material de JRT (3 repos, objetos RDS duplicados, dependencias) | ✅ | `01_mapa_material_jrt.md`, `04_avance_para_reunion_15_mayo.md` |
| jun–jul | **Mortalidad AAF/PAF rehecha**: motor único `aaf_unified.R` + registro RR (WHO 2024 / Shield 2025 / Adam-Sherk; GENERAL_*_RR como fuente validada); `expand_pif.ipynb` = AAF 2012–2024, 15–65, 23 causas RR + bloque AAF=1; corrección de diseño ENPG (Kish + conglomerado); cruce de cáncer con JRT exacto | ✅ corrida completa validada 23-jul (`EXPAND_PIF_ARTIFACT_VALIDATION=PASS`), draws sincronizados con manifiesto SHA-256 | `aaf_unified.R`, `expand_pif.ipynb`, `aaf_nested_by_disease_20260723.rds`, `Mortality Estimates WHO 2024_20260723.xlsx` |
| 10–14 jul | **PIF activado para las 23 causas** (antes sólo lesiones): escenarios volumen 10/20/30 %, HED 10/25/50 % y combinados; ex-bebedores incluidos vía RR de FD; denominador = muertes totales; identidad PAF = PIF(eliminación total) verificada; "perillas" λ/ρ para que el ex-HED siga bebiendo (criterio de JRT) | ✅ 29/29 celdas, 23-jul. **Pendiente**: sub-modelo para causas AAF=1 dentro del PIF (hoy subestima lo evitable) | `expand_pif2.ipynb`, `pif2_pif_results_full_20260723.rds` |
| 14-jul | **YPLL reconstruido** para 23 causas con tablas de vida chilenas (HMD/INE), tres métricas; muertes reconciliadas 1188/1188 contra JRT. Hallazgo: la convención legacy (e0 − edad, piso 0) pierde ~50 % de los años en 60+ | ✅ | `build_ypll.R`, `life_tables_20260714.R`, `test_ypll_death_base.R` |
| 15–20 jul | `expand_pif3.ipynb`: figuras reproducibles; IHD/IS con RR Table 5 (PUC) vs WHO/Adam | ✅ | `expand_pif3.ipynb`, `figures_expand_pif3/` |
| 4-jul | **Plan de fase siguiente (8 semanas)**: sem. 1–4 (mortalidad, YPLL, PIF) ejecutadas; 5–6 (elasticidad) parcial; **7–8 (simulación + integración) no** | ⚠️ | `plan_fase_siguiente_micsim_2026-07-04.md` |
| 4–6 ago | **ENPG 2012–2024 (7 olas) armonizada** con diseño complejo: registro por ola verificado contra `expand_pif` (una sola divergencia, justificada: PSU 2016); escolaridad, baterías DSM-IV, modo de aplicación; audit de celdas. Sobre esa base, el estudio cocaína→alcohol (punto 2) | ✅ base; estudio con resultado negativo | `pseudopanel_deaton_fase1.ipynb`, `pseudopanel_*.md`, `pseudopanel_fase1/` |
| 10-ago (últ. toque 1-sep) | **Auditoría del módulo Elasticidad heredado**: 10 bugs documentados; pipeline reproducible desde microdato INE (exacto contra los .rds); diagnóstico de que el "precio" Deaton a nivel de estrato es en 52–69 % afluencia del cluster; margen extensivo **no estimable** con la EPF (separación); factibilidad de Deaton completo para elasticidades propias (confiabilidad 0,80–0,95) | ✅ auditoría; decisiones abiertas | `elasticidad_epf_handoff.md`, `elasticidad_consolidado.ipynb` |

Producto paralelo de JRT ya listo (leído hoy): manuscrito **"Beer, wine and spirits price elasticities in Chile"** (Ruiz-Tagle, Guitart, Purshouse, Castillo-Carniglia): cerveza −1,06; vino −0,78; destilados −0,97; sin sustitución cruzada; sin diferencias por quintil; señal marginal por intensidad sólo en cerveza. Estimando **condicional a comprar** (margen intensivo, off-premise). El propio paper dice que son insumos para la microsimulación "una vez combinados con supuestos de participación y daño" → ése es exactamente el puente que falta.

---

## 2. Trayectorias / pseudo-paneles: qué pasó (1 minuto)

- **Hipótesis**: con la edad, el consumo problemático (CP) migra de cocaínas a alcohol; descomposición "ecológica a nivel individual" vía pseudo-panel de cohortes (Deaton).
- **Por qué el pseudo-panel clásico no puede**: 558 eventos de CP de cocaínas en 7 olas, **mediana 4 por celda** cohorte×sexo×ola (con bandas de 20 años sigue en 4,5). Y desde marginales repetidas las transiciones no están identificadas: cotas de Fréchet **exactamente [0, 1]**.
- **Lo que sí se pudo**: usar la **edad de inicio** como cuarta coordenada temporal (5.122 expuestos con ≥5 años desde el inicio). La predicción dinámica ("a más tiempo desde el inicio, más alcohol") **se rechaza en 6 especificaciones**: β_inicio ≈ 0 (p = 0,82) vs β_edad = −0,034 (p < 0,001); el valor que exige la hipótesis queda a 3 EE fuera del IC (no es falta de poder). Los expuestos **desisten más rápido** (interacción edad×expuesto −0,014, p = 0,015).
- **Lo que sobrevive y es publicable**: escalera dosis-respuesta de abuso de alcohol 3,0 % → 16,0 % → 27,5 % → 59,5 % (nunca / ex-usuario / uso actual / CP actual), RP ajustadas 4,1 / 5,8 / 13,4; enriquecimiento de historia de cocaínas en los 10 estratos edad×sexo (RP 2,3–17,9). Lectura: **responsabilidad común + desistimiento, no sustitución**. Amenaza no descartada: supervivencia diferencial (se puede acotar con la mortalidad de `expand_pif`).
- **Decisión para ACC**: ¿se escribe como *research report* (Addiction; resultado negativo bien diseñado, con marihuana como segunda exposición de firma opuesta) o se estaciona? En cualquier caso, la base ENPG de 7 olas **sirve directamente al modelo de transiciones** de la microsimulación.

---

## 3. Roadmap: dónde estamos de verdad

Según el cronograma de la propuesta (Tabla 2) estamos en el **año 3**: "Paper 1 – The Chilean alcohol microsimulation model" estaba programado para Y2Q3–Y3Q1, y "Specify and model the effect of policy changes" corre Y3Q1–Y4Q2. O sea: el motor es lo urgente.

| Módulo | Presentación abril | Hoy (verificado) |
|---|---|---|
| Mortalidad: PAF/AAF | "completo" (2008–2022) | **Rehecho** 2012–2024, 15–65, RR WHO 2024/Shield 2025, diseño ENPG, validado 23-jul ✅ |
| Mortalidad: YPLL | no existía | ✅ 23 causas, tablas de vida oficiales |
| Contrafactuales: PIF | sólo lesiones | ✅ 23 causas, FD incluidos, volumen/HED/combinado. Falta AAF=1 |
| Elasticidad | "completo" | Paper JRT listo (intensivo/condicional). Auditoría mía: participación no estimable con EPF → importar de literatura (SIMAH la toma de Ruhm 2012, −0,297, y de hecho no la activa) o fijar 0 |
| Simulación: población sintética + transiciones | MWE MicSim + `polr` sin calibrar | **Sin cambios desde abril** ⚠️. Plantilla disponible: SIMAH release 0.1.1 vendorizado en `SIMAH/supp/` (paquete R completo: `run_microsim_alt`, `transition_alcohol_ordinal_regression`, `apply_tax_policy`, `update_former_drinker`, `simulate_mortality`…) |
| Integración (precio → consumo → PIF → muertes/YPLL en el ciclo anual) | no | **no** ⚠️ = el cuello de botella |
| Aim 1 (Delphi) | — | Ronda 1 cerrada (37 expertos). Consenso: **tamizaje + IB 97,3 %**, capacitación en IB 97,3 %, detección temprana 91,9 %; impuesto volumétrico 78,4 %; PMU 75,7 %; densidad/distancias/zonas 86–89 %; horarios 86,5 %. Subir el **impuesto ad valorem** (el esquema actual del ILA): sólo 29,7 %. Ronda 2 en curso |

---

## 4. Propuesta: 8 semanas, dos políticas, un ciclo anual

Principio: dejar de perfeccionar mortalidad; construir el ciclo anual de Kilian et al. (Fig. S1) y enchufar dos políticas. Población sintética desde ENPG (15–65), sexo × edad × educación × categoría OMS (+HED), un ciclo por año, horizonte 2024 → 2034.

| Semanas | Objetivo | Entregable | Decisión que necesito |
|---|---|---|---|
| 1–2 | **Motor mínimo** discreto anual (R, `data.table`) portando `run_microsim_alt.R` de SIMAH: población sintética ENPG 2022/2024, envejecimiento, entradas/salidas INE, mortalidad por causa vía el motor AAF que ya existe | Baseline 2024→2034 que reproduce la mortalidad 2012–2024 (calibración) | ¿Discreto anual tipo SIMAH (recomiendo) o MicSim en tiempo continuo (propuesta)? MicSim queda como validación |
| 3–4 | **Transiciones de consumo**: recalibrar el `polr` de JRT (los 3 esquemas de calibración ya están codificados) sobre la ENPG 7 olas; holdout 2022/2024; comparar con `transition_alcohol_ordinal_regression` de SIMAH | Prevalencias simuladas vs observadas por sexo × edad × categoría, figura calibrada | Año de arranque (2012 vs 2022); ¿educación entra ya como eje? |
| 5–6 | **Política 1: tamizaje + intervención breve** (módulo SBI de Sheffield): cada año, fracción con contacto en APS × tamizada; AUDIT-C positivo (≥4 M / ≥5 H) → IB → **reducción 12,3 % del consumo** con **rebote lineal a 7 años** (Kaner, Cochrane; SAPM Inglaterra/Italia); recodificar categoría → PIF → muertes/YPLL evitados | Primera tabla de muertes y YPLL evitados por sexo × edad para 3 escenarios: statu quo (~35.000 IB/año, ref. propuesta), "en próximo control" (~40–63 % de la población en 10 años), "en próxima consulta" (~96 %) | Parámetros chilenos: cobertura APS por sexo/edad (FONASA/REM), sensibilidad del AUDIT validado en Chile (Alvarado 2009, ref. 50 de la propuesta), tasa de entrega. Pedir a la colega del Delphi qué formato de IB priorizan (ronda 2) |
| 7–8 | **Política 2: precio** (secuencia Kilian: bebida → participación → elasticidad → recodificar) con las elasticidades de JRT; participación −0,297 como sensibilidad (o 0); forma lineal acotada en −1; **sin cruzadas** (coherente con el paper). Escenario principal: pasar del ILA ad valorem a **impuesto específico por gramo** (Morris 2024 como plantilla) y PMU | Escenarios impuesto volumétrico y PMU con IC | Reparto del consumo por bebida por sexo × edad × categoría (shares EPF vs ENS); magnitudes desde la ronda 2 |
| Transversal | Incertidumbre (draws sincronizados AAF/PIF ya existen; LHS para elasticidades e IB); repo `R/` modular + tests (arquitectura del plan del 4-jul); pre-registro OSF (compromiso de la propuesta) | Paper 1 = descripción del modelo + baseline | — |

Por qué IB primero: (a) 97 % de consenso; (b) el módulo SBI de Sheffield está publicado con parámetros completos y ya está en la bibliografía de la propuesta (ref. 32); (c) no depende del puente de participación que le falta a precio.

---

## 5. Decisiones que le pido a ACC hoy

1. **Motor**: discreto anual tipo SIMAH vs MicSim.
2. **Alcance**: 15–65 / 2012–2024 (lo que tiene el pipeline, alineado a ENPG) vs 15+ / 2008–2019 (propuesta). Implica qué hacemos con >65, donde está el grueso de la mortalidad.
3. **Políticas y orden**: IB primero, precio segundo; ¿disponibilidad/horarios se descartan por falta de parámetros locales, aunque tengan consenso?
4. **Uso del paper de JRT**: elasticidades condicionales + participación importada + cruzadas = 0; sensibilidad con meta-análisis (Wagenaar/Fogarty) como hace SIMAH.
5. **Reparto**: yo motor + integración + módulo IB; JRT módulo precio; colega Delphi parámetros de IB y validación de escenarios con el panel.
6. **Paper cocaína→alcohol**: ¿va (Addiction) o se estaciona?
7. **Autorizaciones pendientes**: (i) alinear la PSU 2016 en `build_enpg_design_waves_2012_2024_list.R` (mueve los IC de 2016); (ii) sub-modelo AAF=1 dentro del PIF.

---

## 6. Si JRT está en la reunión

- ¿El repo público `JoseRTM/MicSim-Chile` tiene sólo el pipeline de elasticidad o ya hay código de simulación? (hoy devuelve 404 desde afuera: ¿privado?)
- Reparto por bebida para el modelo: ¿shares EPF por sexo/edad/quintil o ENS?
- Su modelo de transiciones (`polr` + rank matching): ¿se corrió sobre 2008–2016 solamente? Con la ENPG 2012–2024 armonizada podemos calibrar y validar en 2018–2024.
- Mi diagnóstico de afluencia en el precio Deaton es consistente con la limitación 2 de su paper (R² de primera etapa 6–12 %); no bloquea usar los estimados, pero justifica el análisis de sensibilidad con elasticidades de meta-análisis.

---

## Fuentes revisadas hoy

Propuesta FONDECYT 1240138 (aims, D4–D5, Tabla 2) · `presentacion_micsim.qmd` (abril) · `plan_fase_siguiente_micsim_2026-07-04.md` · `codex_handoff_adam_rr_full_override_caveman.md` (entradas 10-jul → 24-jul) · `pseudopanel_arquitectura_estudio.md`, `pseudopanel_decisiones_metodologicas.md`, `pseudopanel_divergencias_expand_pif.md`, `pseudopanel_deaton_handoff.md` §17 · `elasticidad_epf_handoff.md` · Manuscript_IJDP_FINAL (elasticidad, JRT) · Síntesis resultados ronda 1 (Delphi) · Purshouse et al. 2013 *Alcohol Alcohol* 48(2):180–8 y Angus et al. 2014 *BMC Fam Pract* 15:26 (parámetros SBI de Sheffield: AUDIT-C 4/5, −12,3 %, rebote 7 años, cobertura registro vs consulta).
