KIMI-P3 | búsqueda realizada el 6–7 de octubre de 2026 | 18 referencias leídas a texto completo / 5 solo resumen

# Decisión metodológica sobre HED y datos faltantes en el estudio de mortalidad atribuible al alcohol en Chile (FONDECYT 1240138): investigación de respaldo

**Nota de alcance.** Este informe solo responde las decisiones D-a a D-d y las preguntas Q1–Q6 del encargo, con evidencia localizada y verificada. No reestima datos ni rediseña el estudio. Toda afirmación sustantiva lleva cita con DOI/URL estable y página/ecuación/tabla cuando existe; lo no encontrado se declara como **NO ENCONTRADO** y lo no verificable como **NO VERIFICADO**. Las citas marcadas **(solo resumen)** indican que solo se leyó el resumen o metadatos. Los extractos textuales se marcan **[TEXTO]** (con cita de <30 palabras cuando fue posible) y las deducciones propias como **[INFERENCIA]**.

---

## 1. Veredicto por opción (D-a a D-d)

| Decisión | Opción | Apoyo | Referencias clave | Por qué |
|---|---|---|---|---|
| **D-a** (faltantes HED 88/99) | **A** (status por recencia; HED faltante="no" en origen; cantidad faltante → MAR por celda con gamma de casos completos y p_actual elevado) | **Mixto: recencia = fuerte; faltante="no" = contrario; MAR por celda = débil** | GHO-IMR 459/458 (OMS); Sherk 2017 (guía InterMAHP, p. 24); Ruiz-Tagle Maturana 2026 (§2.4.1) | La clasificación por recencia (actual = último mes; ex-bebedor = último año sin último mes) es la convención documentada **[TEXTO]**. En cambio, codificar no-respuesta como "no" contradice la convención OMS: el denominador es "participants responding to the corresponding question(s)… plus abstainers" **[TEXTO]**, es decir, no-respondentes fuera del denominador. No se encontró precedente de MAR por celda en literatura AAF (**NO ENCONTRADO**). |
| **D-a** | **B** (caso completo; implementación actual) | **Moderado** | Rehm 2010 (PHM 8:3, exclusión de 298 faltantes); GHO-IMR 459; Ruiz-Tagle Maturana 2026 | Es la práctica dominante y equivale a la convención OMS para el indicador HED. El problema no es excluir el faltante del ítem HED sino **dejar que esa exclusión cascadée hacia los denominadores de volumen y prevalencia de bebedor actual** — la convención OMS usa denominadores distintos por indicador (GHO 458 vs. 459) **[INFERENCIA a partir de TEXTO]**. |
| **D-a** | **C** (reportar A y B como cotas) | **Débil** | — | No se encontró enfoque de cotas ("bounds") para no-respuesta de ítem en la literatura AAF (**NO ENCONTRADO**). Defendible como análisis de sensibilidad declarado, no como convención. |
| **D-a** | **D** (imputación múltiple) | **Débil** | — | No se encontró precedente de imputación múltiple para ítems de consumo en estudios AAF/InterMAHP/OMS (**NO ENCONTRADO**). Metodológicamente estándar en encuestas, pero rompería la comparabilidad con la serie GSRAHTSUD y exigiría re-anclar la calibración a consumo per cápita. |
| **D-b** (ítem 5+/4+ tragos ≈12 g vs. umbral RR de 60 g) | **Tratar como proxy y declarar la discrepancia (con tamaño de trago explícito)** | **Fuerte** | Ruiz-Tagle Maturana 2026 (§2.4.1); MINSAL 2011 (p. 56 ss.); GHO-IMR 459; NIAAA; Vinader-Caerols 2017 | El propio antecedente del proyecto declara: "The 60 g threshold was therefore used only within the integration step, rather than as a direct classification criterion in the survey data" **[TEXTO]**. El ítem 5+/4+ es el indicador oficial de SENDA. Con el trago chileno de ≈14 g (MINSAL 2011, basado en la ENS: 15,5 g **[TEXTO]**), el ítem equivale a ≈70 g (H) y ≈56 g (M) — idéntico al patrón NIAAA (5+/4+ × 14 g). |
| **D-b** | Ajustar el ítem a 60 g exactos | **Débil / no recomendado** | Sherk 2017 (p. 27: umbral c_w/c_m definible por el usuario) | InterMAHP permite umbrales por sexo definidos por el usuario, pero la ENPG no tiene un ítem de 6+ tragos para mujeres: ajustar requeriría redistribuir respuestas entre categorías, sin base empírica local. |
| **D-b** | Mantener 12 g por trago sin declarar | **Contrario** | MINSAL 2011; código del repositorio FONDECYT 1240138 | 12 g no tiene fuente chilena localizada (**ASUMIDO**). Con 12 g el umbral femenino queda en 48 g, para el que **no se encontró ningún precedente** en OMS, NIAAA, adaptación española ni SMART (**NO ENCONTRADO**). Con 14 g (MINSAL) o 13 g (código del proyecto) el umbral femenino es 56–52 g, cercano al 50–56 g de los precedentes con umbral por sexo. |
| **D-c** (valores de categorías superiores de cantidad usual; ocasiones HED a valor umbral) | Puntos medios en categorías cerradas + categoría abierta valorada en su piso con subestimación declarada | **Moderado-fuerte** | Greenfield 2009 (PMC3011820); Moskalewicz & Sieroslawski 2010 (guía SMART); código FONDECYT 1240138 | Puntos medios aritméticos son la convención para categorías cerradas **[TEXTO, Greenfield 2009]**. Para la categoría abierta, la media empírica supera los valores convencionales bajos (EUA: 12+ → media 15,5 tragos; Australia: 20+ → 23,5) **[TEXTO]**. SMART valora explícitamente "6+ = only 6 drinks and 12+ = 12 drinks only" como "conservative assumption" **[TEXTO]** y plantea deducir la frecuencia binge de la frecuencia QF para evitar doble conteo **[TEXTO]**. |
| **D-c** | Valores actuales 7,5 ("7–8") y 9 ("9 o más") | **Contrario si el cuestionario dice "7 a 9" y "10 o más"** | Código FONDECYT 1240138 (etiquetas 2008: "7-8"/"9 o mas"); Greenfield 2009 | Si las categorías reales son 7–9 y 10+, entonces 7,5 está **bajo** el punto medio (8) y 9 está **bajo el piso** de la categoría (10): subestimación doble, no corregida por la recalibración per cápita dentro de celdas (la recalibración escala la media, pero la forma subestimada persiste) **[INFERENCIA]**. La redacción por ola no pudo verificarse salvo etiquetas 2008 y nota al pie 2024 → **NO VERIFICADO** (ver §8). |
| **D-d** (gamma por momentos ponderados vs. MV; razón DE/media fija; tope 150 g/día) | Gamma uniparamétrica con σ/μ = 1,171 (H) / 1,258 (M), calibrada a per cápita, integración hasta 150 g/día | **Fuerte (como convención), con limitación declarada** | Kehoe 2012 (10.1186/1478-7954-10-6); Rehm 2010 (10.1186/1478-7954-8-3); OMS-EURO 2025 (Fórmula S.4, p. 4); Sherk 2017 (pp. 29, 39–40) | Es la convención canónica InterMAHP/OMS: σ_shifted = (1,171 + 0,087·sexo)·μ_shifted **[TEXTO, OMS-EURO p. 4]**. Kehoe 2012 usa MV; el método de momentos ponderado con razón fija reproduce la misma familia uniparamétrica **[INFERENCIA]**. El antecedente chileno (mismo FONDECYT) ajusta gamma por `fitdist` (MV) por sexo-edad **[TEXTO, código]**. |
| **D-d** | Alternativas (gamma generalizada, selección por KS; tope >150) | **Débil-moderado (crítica documentada)** | Parish 2017 (10.1111/add.13880); Gmel 2013 (10.1186/1471-2288-13-24) | Parish: la gamma "rarely provided the best fit" y los AAF son sensibles a la distribución elegida **[TEXTO]**. El tope de 150 g/día subestima la carga: InterMAHP documenta hasta 25,5 % (H) y 8,0 % (M) menos muertes al truncar (citando a Gmel 2013) y permite elevar z (MAPs ≈250 g/día) **[TEXTO, guía pp. 39–40]**. |

## 1b. Tabla de parámetros

| ID | Parámetro / decisión | Valor | Fuente (DOI + página/tabla/ecuación) | Estimado / Asumido | Transportabilidad a Chile |
|---|---|---|---|---|---|
| P1 | Ítem HED de la encuesta | ≥1 ocasión con 5+ tragos (H) / 4+ (M) en últimos 30 días | SENDA 2025, 16° ENPG, nota al pie: "Embriaguez: 5 o más tragos para hombres, 4 o más para mujeres" **[TEXTO]** (URL en §7); Ruiz-Tagle Maturana 2026, §1, doi:10.1016/j.puhip.2026.100798 | Estimado (definición oficial) | Directa: es el ítem chileno |
| P2 | Umbral HED en las funciones RR | ≥60 g de alcohol puro por ocasión, ambos sexos, último mes | OMS GHO IMR 459 (who.int/data/gho/indicator-metadata-registry/imr-details/459) **[TEXTO]**; OMS 2024, §2.1.5 **[TEXTO]**; OMS-EURO 2025, p. 3 **[TEXTO]** | Definición de la fuente de RR | Directa: así están construidas las RR |
| P3 | Gramos por "trago" en Chile | ≈14 g (guía MINSAL 2011; la ENS 2009-10 midió 15,5 g); 13 g en el código del proyecto (variante "MINSAL" de 16 g) | MINSAL 2011, Guía técnica de intervenciones breves, sección "Tragos: unidades de bebida estándar" **[TEXTO]** (diprece.minsal.cl); `DATA PREPARATION ENPG.R`, líneas `voltotal = (volbinge+volalchab)*13` y `voltotMS = …*16`, doi:10.5281/zenodo.18375712 **[TEXTO código]** | 14/13 g: estimado; 12 g: **asumido sin fuente local** | Alta para 14 g (evidencia ENS chilena) |
| P4 | Umbral HED implícito en gramos | 5×14 = 70 g (H); 4×14 = 56 g (M); con 13 g: 65/52 g; con 12 g: 60/48 g | Cálculo propio sobre P1×P3 **[INFERENCIA]**; equivalencia NIAAA 5+/4+ × 14 g = 70/56 g (niaaa.nih.gov) **[TEXTO]** | Estimado | Directa |
| P5 | Precedentes de umbral por sexo | NIAAA: 5+/4+ tragos de 14 g (70/56 g); adaptación española: 6+/5+ UBE de 10 g (60/50 g); SIMAH: >60/>40 g/día (volumen diario) | NIAAA (niaaa.nih.gov/alcohols-effects-health/que-es-una-bebida-estandar) **[TEXTO]**; Vinader-Caerols 2017, doi:10.3389/fpsyg.2017.01720, Introducción **[TEXTO]**; Kilian 2025, doi:10.1016/S2468-2667(25)00165-3 **(solo resumen)** | Estimado | Media: miden lo mismo con otra unidad; el valor exacto 48 g no tiene precedente (**NO ENCONTRADO**) |
| P6 | Valores de categorías cerradas de cantidad usual (AUDIT-2) | Puntos medios: "0-2"→1; "3-4"→3,5; "5-6"→5,5 | Greenfield 2009, PMC3011820 **[TEXTO]**; mismo esquema en `DATA PREPARATION ENPG.R` **[TEXTO código]** | Convención estimada | Alta |
| P7 | Categorías superiores de cantidad usual | Si la redacción es "7 a 9": punto medio = 8 (no 7,5); si la abierta es "10 o más": valorar ≥10 con subestimación declarada; media empírica de la categoría abierta supera el piso (EUA 12+ → 15,5; Australia 20+ → 23,5) | Greenfield 2009, PMC3011820 **[TEXTO]** | Estimado | Media: la media empírica citada es de EUA/Australia; no se localizó media empírica chilena (**NO ENCONTRADO**) |
| P8 | Valoración de la ocasión HED en el volumen | Umbral 5/4 tragos (implementación actual) vs. 6 tragos por ocasión binge (código del proyecto: `volbinge = dias_binge*6`) vs. valoración conservadora SMART (6+ = 6; 12+ = 12) | `DATA PREPARATION ENPG.R` **[TEXTO código]**; Moskalewicz & Sieroslawski 2010 (SMART), sección de ajuste RSOD **[TEXTO]** | Estimado | Media-alta |
| P9 | Distribución del consumo | Gamma uniparamétrica; σ/μ = 1,171 (H) y 1,258 (M); en OMS-EURO: σ = (1,171 + 0,087·sexo)·μ | Kehoe 2012, doi:10.1186/1478-7954-10-6 **[TEXTO]**; Rehm 2010, doi:10.1186/1478-7954-8-3 (coeficientes 1,174/1,258 documentados en Parish 2017, ecs. 4–5) **[TEXTO]**; OMS-EURO 2025, p. 4, Fórmula S.4 **[TEXTO]**; Sherk 2017, p. 29 **[TEXTO]** | Estimado (regresión sobre encuestas internacionales) | Media: no validado con datos chilenos |
| P10 | Estimador de la gamma | MV por celda (Kehoe 2012; `fitdist` en el código del proyecto) o momentos ponderados con razón fija (equivalente uniparamétrico InterMAHP) | Kehoe 2012 **[TEXTO]**; `Paper mortality trends.R` (fitdistrplus) **[TEXTO código]**; Sherk 2017, p. 29 **[TEXTO]** | Convención | Alta |
| P11 | Límites de integración | 0,03–150 g/día (InterMAHP); implementación actual 0,1–150 g/día; tope 150 también en OMS-EURO (Fórmula S.2b) y en el estudio chileno | Sherk 2017, pp. 27, 39–40 **[TEXTO]**; OMS-EURO 2025, p. 2 **[TEXTO]**; Ruiz-Tagle Maturana 2026, §2.3 **[TEXTO]** | Convención | Alta; truncar subestima: hasta −25,5 % (H) y −8,0 % (M) en muertes (guía InterMAHP citando a Gmel 2013) **[TEXTO]** |
| P12 | Estado de consumo por recencia | Actual = último mes; ex-bebedor = último año sin último mes; abstencionista = nunca/vida | Ruiz-Tagle Maturana 2026, §2.4.1: "consumed alcohol in the previous year but not within the previous month" **[TEXTO]**; Sherk 2017, p. 24 (P_CD = ≥1 trago estándar en el último año) **[TEXTO]**; GHO IMR 458 **[TEXTO]** | Convención | Alta |
| P13 | Denominador del indicador HED | Población: respondedores + abstinentes (abstinentes = 0 ocasiones); solo bebedores: respondedores que bebieron ≥1 trago en 12 meses | OMS GHO IMR 459 y 458 **[TEXTO]** | Convención OMS | Alta |
| P14 | AAF de lesiones en dos componentes | P_CD·(RR−1) = ∫₀⁶⁰P_NHED·RR_NHED + ∫₀⁶⁰P_HED·RR_HED + ∫₆₀¹⁵⁰P_HED·RR_HED − P_CD; RR_BINGE(x) = max(RR(x), 1); factores binge de lesiones 1,49/1,70/1,48 | OMS-EURO 2025, p. 2, Fórmulas S.2a–S.2b **[TEXTO]**; Sherk 2017, pp. 44–46, Fórmula 3.9 y §3.6 (NHIS, n = 134 237) **[TEXTO]** | Estimado | Media: factores binge de lesiones provienen de NHIS (EUA) |
| P15 | p_HED | Proporción de bebedores actuales con HED (último mes) | OMS-EURO 2025, p. 3 **[TEXTO]**; `Paper mortality trends.R`: `hed = ifelse(dias_binge>0,1,0)` **[TEXTO código]** | Estimado | Directa |
| P16 | Calibración a consumo per cápita | Factor anual = APC OMS (L × 0,789 × 1000) / media encuesta; factores 2,52–5,53 según año; corrección de cobertura 0,8 en OMS-EURO | `DATA PREPARATION ENPG.R` **[TEXTO código]**; OMS-EURO 2025, p. 3 **[TEXTO]** | Estimado | Directa |

---

## 2. Respuestas Q1–Q6

**Q1. ¿Qué definiciones de HED asumen las fuentes de RR y cómo mapear el ítem 5+/4+?**
Todas las fuentes de RR relevantes definen HED como **≥60 g de alcohol puro en una ocasión, al menos una vez en el último mes, en ambos sexos**: OMS 2024 ("consumption of at least 60 grams of pure alcohol on one occasion, or more often, in the last month", §2.1.5) **[TEXTO]**; GHO IMR 459 **[TEXTO]**; OMS-EURO 2025 (p. 3) **[TEXTO]**; Shield 2025 armoniza encuestas con covariables de regresión para umbral (referencia ≥60 g) y marco temporal (referencia último mes/28 días) **[TEXTO]**. InterMAHP permite umbral binge por sexo definido por el usuario (guía, p. 27) **[TEXTO]**. El mapeo del ítem chileno depende del tamaño del trago: con 14 g (MINSAL 2011) equivale a 70/56 g — idéntico a NIAAA **[TEXTO]**; con 12 g, a 60/48 g. Precedentes de umbral específico por sexo: NIAAA (70/56 g), adaptación española 6/5 UBE de 10 g (60/50 g; Vinader-Caerols 2017) **[TEXTO]**; SIMAH usa umbrales de volumen diario por sexo (>60/>40 g/día; Kilian 2025, **solo resumen**) **[TEXTO]**. Un umbral femenino de **48 g: NO ENCONTRADO** en ninguna fuente.

**Q2. Trago estándar en Chile y valor usado en estudios chilenos de AAF.**
No se encontró una norma legal chilena que fije gramos por trago (**NO ENCONTRADO** como regulación). La referencia técnica oficial es la guía MINSAL 2011 de intervenciones breves: "en nuestro país el trago estándar contiene 15,5 gramos" (medición de la ENS, Minsal-PUC 2010) y "entenderemos por trago una bebida alcohólica que contiene aproximadamente 14 gramos de alcohol puro" **[TEXTO]**; la misma guía adapta el ítem 3 del AUDIT de 6+ a 5+ tragos porque el AUDIT original fue diseñado con tragos de 10 g **[TEXTO]**. En el estudio AAF chileno reciente (mismo FONDECYT 1240138), el código convierte a **13 g por trago** (y una variante "MINSAL" de 16 g) **[TEXTO código]**; el artículo publicado no declara el valor (Ruiz-Tagle Maturana 2026, §2.3) **[TEXTO]**. La conversión de Castillo-Carniglia 2013 (doi:10.1093/alcalc/agt066, **solo resumen**) no pudo verificarse → **NO VERIFICADO**.

**Q3. Convenciones de datos faltantes en insumos AAF, no-respuesta SENDA y enfoques de cotas.**
Convenciones localizadas: (i) GHO IMR 459 — denominador = "participants responding to the corresponding question(s) in the survey plus abstainers", con "abstainers were coded as having 0 occasions" **[TEXTO]**; (ii) GHO IMR 458 (solo bebedores) — denominador = respondedores que consumieron ≥1 trago estándar en 12 meses **[TEXTO]**; (iii) Rehm 2010 excluyó a los no-respondentes (n = 298) **[TEXTO]**; (iv) clasificación por recencia en Sherk 2017 (p. 24) y Ruiz-Tagle Maturana 2026 **[TEXTO]**. Implicación: codificar el faltante como "no" contradice (i); lo convencional es excluir al no-respondente **solo del denominador de ese indicador**, sin cascada hacia volumen ni prevalencia de bebedor **[INFERENCIA]**. Documentación de SENDA sobre el tratamiento de los códigos 88/99: **NO ENCONTRADO** (informe completo ENPG 2022 y páginas sidoc no accesibles; ver §8). Enfoques de cotas o de imputación múltiple específicos de la literatura AAF: **NO ENCONTRADO**.

**Q4. Fuente metodológica del AAF de lesiones en dos componentes con p_HED entre bebedores actuales.**
La fuente verificable es el anexo web de OMS-EURO 2025 (WHO/EURO:2025-12985-52759-82187), p. 2: Fórmula S.2a (PAF con ex-bebedores y bebedores actuales) y **Fórmula S.2b**: P_CD·(RR−1) = ∫₀⁶⁰ P_NHED·RR_NHED dx + ∫₀⁶⁰ P_HED·RR_HED dx + ∫₆₀¹⁵⁰ P_HED·RR_HED dx − P_CD, con HED "defined as drinking 60 grams or more of pure alcohol on one occasion in the past month **among current drinkers**" (p. 3) **[TEXTO]**. Misma estructura en la guía InterMAHP (Sherk 2017, §3.5–3.6, pp. 44–46): Fórmula 3.9, RR_BINGE(x) = max(RR(x), 1) **[TEXTO]**, y factores binge de lesiones 1,49 (vehicular) / 1,70 (intencional) / 1,48 (no intencional) desde NHIS (n = 134 237) **[TEXTO]**. La implementación chilena replica S.2b (Ruiz-Tagle Maturana 2026, Ec. 2) **[TEXTO]**. **Discrepancia a reportar**: el candidato Gmel 2011 (doi:10.1186/1471-2288-11-48) **no** es la fuente de esta fórmula — es el artículo de **incertidumbre** de los AAF (Monte Carlo) **[TEXTO]**.

**Q5. Métodos de frecuencia-cantidad graduada con ocasiones binge; subestimación y categoría abierta.**
La recomendación internacional es la QF expandida de tres ítems (frecuencia, cantidad usual, frecuencia HED): "Including question about heavy episodic drinking can counter underestimates of alcohol consumption from the traditional QF questionnaire" (Tevik 2021, PMC8675766, Introducción) **[TEXTO]**. Para valorar: puntos medios en categorías cerradas son aceptables; el problema es la **categoría abierta**, cuya media empírica supera los valores convencionales (EUA 12+ → 15,5 tragos vs. 13 usados; Australia 20+ → 23,5; "the mean value for the highest level… typically been set too low", Greenfield 2009, PMC3011820) **[TEXTO]**. SMART valora las ocasiones binge de forma explícitamente conservadora ("6+ drinks always means only 6 drinks and 12+ drinks always means 12 drinks only") y plantea deducir la frecuencia binge de la frecuencia QF para evitar doble conteo (Moskalewicz & Sieroslawski 2010) **[TEXTO]**. El código del proyecto usa puntos medios 1/3,5/5,5/7,5/9 y 6 tragos por ocasión binge **[TEXTO código]**. La subestimación por valorar en el umbral está documentada; la recalibración per cápita la compensa en media, no en forma **[INFERENCIA]**.

**Q6. Modelo de distribución (gamma, razón DE/media, momentos vs. MV) y límite superior de integración.**
La convención es gamma uniparamétrica con σ/μ = 1,171 (hombres) y 1,258 (mujeres), de la regresión de Kehoe 2012 (doi:10.1186/1478-7954-10-6) **[TEXTO]**, replicada en Rehm 2010 (coeficientes 1,174/1,258, documentados en Parish 2017, ecs. 4–5) **[TEXTO]**, en InterMAHP (p. 29) **[TEXTO]** y en OMS-EURO 2025 (p. 4, Fórmula S.4: σ = (1,171 + 0,087·sexo)·μ) **[TEXTO]**. Kehoe 2012 estima por **MV**; el código del proyecto usa `fitdist` (MV por defecto en fitdistrplus) **[TEXTO código]**; el método de momentos ponderado con razón fija reproduce la misma familia **[INFERENCIA]**. Crítica: la gamma "rarely provided the best fit" y los AAF son sensibles a la distribución (Parish 2017; alternativa: gamma generalizada con selección por KS) **[TEXTO]**. Límite superior 150 g/día: convención OMS/InterMAHP (guía, pp. 39–40) **[TEXTO]** con subestimación documentada (hasta −25,5 % H / −8,0 % M al truncar; guía citando a Gmel 2013) **[TEXTO]**; InterMAHP permite elevar z (MAPs ≈250 g/día) **[TEXTO]**. Límite inferior: 0,03 g/día en InterMAHP vs. 0,1 en la implementación actual — diferencia de masa despreciable **[INFERENCIA]**.

## 3. Tabla de evidencia

Tipos: **(a)** chilena, **(b)** latinoamericana, **(c)** internacional empírica, **(d)** convención de modelo.

| # | Referencia | Tipo | Afirmación que respalda | Localización | Leído |
|---|---|---|---|---|---|
| 1 | OMS, GHO IMR 459 (HED, población) | d | HED = ≥60 g, ≥1 ocasión, últimos 30 días; denominador = respondedores + abstinentes; abstinentes = 0 ocasiones | Página IMR 459, "Definition" y "Method of estimation" | Texto completo |
| 2 | OMS, GHO IMR 458 (HED, solo bebedores) | d | Denominador = respondedores con ≥1 trago estándar (10 g) en 12 meses; 60 g ≈ 6 tragos | Página IMR 458, "Definition" | Texto completo |
| 3 | OMS 2024, GSRAHTSUD | d | HED = ≥60 g por ocasión, ≥1 vez en el último mes; HCD = ≥60 g/día; prevalencia 2019: 17 % (15+), 38 % de bebedores (27 % M / 45 % H) | §2.1.5 | Texto completo (extractos del informe) |
| 4 | Shield 2025, Lancet Public Health 10(9):e751–e761, doi:10.1016/S2468-2667(25)00174-4 | c/d | Armonización de encuestas con covariables para umbral HED (referencia ≥60 g) y marco temporal (referencia último mes/28 días); fuente de las RR usadas | Métodos (armonización de exposición) | Texto completo |
| 5 | Kilian 2025, Lancet Public Health 10(10):e815–e823, doi:10.1016/S2468-2667(25)00165-3 | c/d | Microsimulación tipo SIMAH; "high alcohol use" = >60 g/día (H), >40 g/día (M): precedente de umbral en gramos por sexo | Resumen/metadatos | Solo resumen |
| 6 | OMS-EURO 2025, anexo web lesiones, WHO/EURO:2025-12985-52759-82187 | d | Fórmulas S.2a/S.2b (AAF dos componentes con p_HED entre bebedores actuales); HED = 60 g último mes; factor de corrección 0,8; gamma σ = (1,171+0,087·sexo)·μ | pp. 2–4 (Fórmulas S.2a, S.2b, S.4) | Texto completo |
| 7 | Sherk 2017, guía InterMAHP v1.0 | d | P_CD = ≥1 trago último año (p. 24); umbral binge por sexo definible (p. 27); gamma uniparamétrica con razones de Kehoe (p. 29); tope 150 g/día y subestimación por truncamiento (pp. 39–40); Fórmula 3.9 max(RR,1) y factores binge de lesiones 1,49/1,70/1,48, NHIS n = 134 237 (pp. 44–46) | pp. 24, 27, 29, 39–40, 44–46 | Texto completo |
| 8 | Kehoe 2012, Popul Health Metr 10:6, doi:10.1186/1478-7954-10-6 | c/d | Gamma como mejor compromiso para modelar consumo; MV; regresión σ/μ (1,171 H / 1,258 M); análisis de truncamiento 96/120/150/200 g/día | Artículo completo | Texto completo |
| 9 | Rehm 2010, Popul Health Metr 8:3, doi:10.1186/1478-7954-8-3 | d | Método de "upshift" a per cápita; σ = 1,174·μ (H) / 1,258·μ (M); exclusión de faltantes (n = 298) | Artículo; coeficientes verificados además en Parish 2017, ecs. 4–5 | Texto completo |
| 10 | Gmel 2011, BMC Med Res Methodol 11:48, doi:10.1186/1471-2288-11-48 | c/d | **Verificación de candidato**: trata la **incertidumbre** de los AAF (simulación Monte Carlo), no la fórmula de lesiones en dos componentes | Título y resumen | Solo resumen |
| 11 | Gmel 2013, BMC Med Res Methodol 13:24, doi:10.1186/1471-2288-13-24 | c | Efecto de topes de consumo (150 g/día) sobre muertes atribuibles: truncar reduce las estimaciones | Resumen; magnitudes vía guía InterMAHP pp. 39–40 | Solo resumen |
| 12 | Parish 2017, Addiction 112(11):2053–2063, doi:10.1111/add.13880 | c | La gamma "rarely provided the best fit"; AAF sensibles a la distribución; gamma generalizada + KS como alternativa; NHSDA usa días con 5+ tragos en 30 días y 14 g/trago | Introducción, Métodos, Resultados | Texto completo |
| 13 | Moskalewicz & Sieroslawski 2010, guía SMART | d | Valoración conservadora de ocasiones binge ("6+ = 6", "12+ = 12"); doble conteo frecuencia QF vs. binge planteado explícitamente; 60 g → BAC 0,73 ‰ (H) / 0,95 ‰ (M) (100 kg, 2 h) | Secciones de ajuste RSOD | Texto completo |
| 14 | Greenfield 2009, Contemp Drug Probl 36(3–4), PMC3011820 | c | Puntos medios adecuados en categorías cerradas; media empírica de la categoría abierta superior a los valores convencionales (EUA 12+ → 15,5; Australia 20+ → 23,5) | Resultados | Texto completo |
| 15 | Tevik 2021, PLoS ONE, PMC8675766, PMID 34914759 | c | QF expandida con ítem HED contrarresta la subestimación de la QF tradicional; 19 patrones y 7/12/21 definiciones distintas de abstinencia/consumo actual/riesgo: no hay estandarización | Introducción, Resultados, Discusión | Texto completo |
| 16 | NIAAA, "What is a standard drink?" | d | Trago estándar EUA = 14 g; binge = 5+/4+ tragos en ~2 h (≈70/56 g) | Página web | Texto completo |
| 17 | Vinader-Caerols 2017, Front Psychol 8:1720, doi:10.3389/fpsyg.2017.01720 | c | Adaptación española del criterio NIAAA: 6/5 tragos de 10 g ≈ 60/50 g (H/M); BAC objetivo 0,8 g/L | Introducción | Texto completo |
| 18 | Herrero-Montes 2022, J Clin Med 11(1):53, doi:10.3390/jcm11010053 | c | Operacionalización 60/50 g (6+/5+ tragos), ≥1 ocasión en 30 días (cita a Parada et al.) | Métodos (§2.3.1, vía extracto) | Solo resumen |
| 19 | SENDA 2025, 16° ENPG 2024, Principales Resultados | a | Definición oficial de embriaguez (5+/4+ tragos); serie 52,1/43,7/51,1/56,3/50,2/50,7/47,2 (2012–2024) sobre "total de prevalentes mes"; ficha técnica: 18 668 personas, 12–65 años, 109 comunas | Nota al pie y láminas de la presentación | Texto completo |
| 20 | Ruiz-Tagle Maturana, Román & Castillo-Carniglia 2026, Public Health Pract 11:100798, doi:10.1016/j.puhip.2026.100798 (FONDECYT 1240138) | a | AAF Chile 2008–2022 con ENPG (AUDIT-1/2/3); gamma por sexo-edad vía fitdist; tope 150 g/día; calibración a APC OMS; ex-bebedor = último año sin último mes; umbral 60 g "used only within the integration step"; Ec. 2 = S.2b | §2.3, §2.4.1, Ec. (1)–(2) | Texto completo |
| 21 | Repositorio de código de (20), doi:10.5281/zenodo.18375712 | a | Conversión 13 g/trago (variante 16 g); puntos medios 1/3,5/5,5/7,5/9; días binge 0/0,5/1/4/20; 6 tragos por ocasión binge; factores de calibración 2,52–5,53; días no-binge truncados en 0 | `DATA PREPARATION ENPG.R`, `Paper mortality trends.R` | Texto completo (código) |
| 22 | Castillo-Carniglia, Kaufman & Pino 2013, Alcohol Alcohol 48(6):729–736, doi:10.1093/alcalc/agt066 | a | Primer estudio AAF chileno moderno: 8 753 muertes (9,8 %) en 2009; triangulación per cápita + ENPG | Resumen/metadatos | Solo resumen |
| 23 | MINSAL Chile 2011, Guía técnica de intervenciones breves | a | Trago chileno ≈14 g; ENS 2009-10 midió 15,5 g; factor 0,79; adaptación AUDIT 6+→5+ por trago de 10 g original | Sección "Tragos: unidades de bebida estándar" | Texto completo (extractos) |

**Evidencia latinoamericana (b):** no se localizó ninguna fuente latinoamericana (fuera de Chile) que documente convenciones de datos faltantes o de valoración de categorías en estudios AAF → **NO ENCONTRADO** (búsquedas: combinaciones de "alcohol-attributable", "América Latina", "missing/no respuesta", "trago estándar"; ver §8).

## 4. Evidencia chilena y latinoamericana

**(a) Chile.**

- **Redacción del ítem HED por ola.** Verificado: ENPG 2008 — ítems AUDIT-1/2/3 (q18/q19/q20), con categorías de cantidad etiquetadas en los datos como "0-2", "3-4", "5-6", "7-8", "9 o mas" **[TEXTO, etiquetas del código del proyecto, no el cuestionario impreso]**. ENPG 2024 — nota al pie oficial: "Embriaguez: 5 o más tragos para hombres, 4 o más para mujeres", prevalencia sobre "total de prevalentes mes" **[TEXTO, SENDA 2025]**. La redacción literal por ola (2010–2022) y las categorías "7 a 9"/"10 o más" que indica el equipo: **NO VERIFICADO** — el informe completo ENPG 2022 no fue accesible (tiempos de espera agotados) y la página sidoc.senda.gob.cl falló; si el cuestionario efectivamente dice "7 a 9" y "10 o más", los valores 7,5 y 9 de la implementación actual están bajo el punto medio y bajo el piso respectivamente (ver D-c).
- **Trago estándar.** Sin norma legal localizada (**NO ENCONTRADO**). Referencia técnica: MINSAL 2011 — ≈14 g por trago, con medición ENS de 15,5 g **[TEXTO]**. En la práctica AAF del mismo proyecto: 13 g (y 16 g en variante) **[TEXTO código]**. El valor de 12 g de la implementación actual no tiene fuente chilena localizada → **ASUMIDO**.
- **Convención de no-respuesta de SENDA (códigos 88/99).** **NO ENCONTRADO**: la presentación oficial de principales resultados (SENDA 2025) incluye ficha técnica (diseño, ponderadores, trabajo de campo Ipsos) pero no documenta el tratamiento de no-respuesta de ítem; el informe completo con el capítulo metodológico no fue accesible.
- **Serie publicada de embriaguez SENDA.** 52,1 (2012), 43,7 (2014), 51,1 (2016), 56,3 (2018), 50,2 (2020), 50,7 (2022), 47,2 (2024), denominador "total de prevalentes mes" **[TEXTO, SENDA 2025]**. Que la serie propia del equipo supere a esta en 3–6 puntos es consistente con denominadores ligeramente distintos (exclusión de 88/99) y/o con valoraciones distintas del ítem; no resoluble sin el informe completo **[INFERENCIA]**.
- **Nota sobre el antecedente Public Health in Practice 2026:** tiene un corrigendum (las figuras 1–5 fueron duplicadas por error; "the underlying analyses are correct… the scientific conclusions remain unchanged", doi:10.1016/j.puhip.2026.100812) **[TEXTO]**. El financiamiento declarado es FONDECYT Regular N° 1240138 **[TEXTO]** — es decir, es el antecedente metodológico del mismo proyecto.

**(b) Latinoamérica.** NO ENCONTRADO (ver §3 y §8).

## 5. Recomendación por decisión

**D-a (faltantes en el ítem HED).** Recomendada: **opción B corregida en el conteo de origen + A solo en su componente de recencia**. Concretamente: (i) clasificar status por recencia (actual = último mes; ex-bebedor = último año sin último mes) — apoyo **fuerte** (InterMAHP p. 24; Ruiz-Tagle Maturana 2026; GHO 458); (ii) para el indicador HED, excluir al no-respondente del denominador de ese indicador (convención GHO 459), **sin** excluirlo de los denominadores de volumen ni de prevalencia de bebedor actual — la cascada actual es la fuente de la subestimación de ~3–4 % y no tiene respaldo; (iii) **no** recodificar faltante = "no": contrario a la convención OMS; (iv) como sensibilidad interna, reportar la prevalencia HED bajo "faltante = no" y bajo exclusión (equivalente a la opción C como chequeo, no como convención — apoyo **débil**). Imputación múltiple (D): **débil**, no necesaria si se corrige el conteo y se declara la limitación. *Qué cambiaría esta recomendación:* documentación interna de SENDA mostrando que 88/99 se asignan a una categoría substantiva, o un estudio de no-respuesta de ítem en ENPG. *Limitación a declarar:* prevalencia HED entre bebedores estimada sobre respondedores del ítem; subestimación relativa de bebedores actuales de ~3–4 % bajo la implementación anterior.

**D-b (ítem 5+/4+ vs. umbral RR de 60 g).** Recomendada: **mantener el ítem 5+/4+ como proxy y declarar la equivalencia en gramos con trago chileno explícito** — apoyo **fuerte**. Usar 14 g (MINSAL 2011, con respaldo ENS de 15,5 g) o 13 g (convención del propio proyecto); declarar que el ítem ≈70 g (H) / ≈56 g (M) frente a la referencia RR de 60 g/60 g, que ello lo hace levemente más restrictivo en hombres y levemente menos en mujeres, y que el umbral de 60 g opera en el paso de integración (Ruiz-Tagle Maturana 2026, §2.4.1). Abandonar el 12 g silencioso: el 48 g femenino resultante no tiene precedente (**NO ENCONTRADO**). *Qué la cambiaría:* publicación de las RR con umbral distinto de 60 g, o un ítem ENPG con umbrales en gramos. *Limitación a declarar:* discrepancia ítem–umbral y tamaño de trago asumido; sensibilidad nula en el volumen total por la recalibración per cápita (el tamaño del trago se cancela; solo importa vía umbral HED) **[según lo declarado por el equipo]** — verifíquese que la recalibración efectivamente se aplica antes de la estratificación HED.

**D-c (valores de cantidad usual superiores y valoración de ocasiones HED).** Recomendada: **puntos medios en cerradas (1 / 3,5 / 5,5); si la redacción es "7 a 9" usar 8 (no 7,5); categoría abierta "10 o más": valorar en su piso (10) con subestimación declarada, o idealmente estimar la media empírica** — apoyo **moderado-fuerte** (Greenfield 2009; SMART 2010). Para las ocasiones HED en el volumen, la valoración en el umbral (5/4 tragos) es conservadora y comparable con SMART ("6+ = 6"); la variante del propio proyecto usa 6 tragos por ocasión; elegir una y declararla. *Qué la cambiaría:* una media empírica chilena de la categoría abierta (estimable con microdatos ENPG si la escala 2018+ es continua, o con la ENS) — actualmente **NO ENCONTRADO**. *Limitación a declarar:* subestimación del volumen en la cola superior antes de la recalibración; la recalibración corrige la media, no la forma **[INFERENCIA]**.

**D-d (distribución gamma e integración).** Recomendada: **mantener gamma uniparamétrica con σ/μ = 1,171/1,258 calibrada a per cápita e integración hasta 150 g/día, con MV por celda (o momentos ponderados con la razón fija, que reproduce la misma familia) y limitaciones declaradas** — apoyo **fuerte como convención** (Kehoe 2012; Rehm 2010; InterMAHP p. 29; OMS-EURO S.4; antecedente chileno con fitdist). Declarar la crítica documentada: la gamma rara vez es la de mejor ajuste y los AAF son sensibles a la distribución (Parish 2017); el tope de 150 g/día subestima (hasta −25,5 % H / −8,0 % M; InterMAHP pp. 39–40 citando a Gmel 2013). Considerar como robustez (no como convención): gamma generalizada con selección KS por celda y tope elevado (p. ej., 250 g/día, valor de MAPs en InterMAHP). Armonizar el límite inferior a 0,03 g/día por comparabilidad con InterMAHP. *Qué la cambiaría:* validación empírica de σ/μ con microdatos chilenos (regresión análoga a Kehoe sobre ENPG). *Limitación a declarar:* coeficientes σ/μ estimados en encuestas internacionales, no chilenas.

## 6. Párrafos de métodos (inglés)

**Paragraph 1 — Exposure measurement and heavy episodic drinking.**
Alcohol exposure was estimated from the biennial Chilean National Drug Surveys of the General Population (ENPG, SENDA; urban household samples aged 15–65 years), following the expanded quantity–frequency approach recommended for population surveys, which combines drinking frequency, usual quantity per occasion, and the frequency of heavy episodic drinking (HED) to reduce the underestimation of traditional quantity–frequency measures (Tevik et al., 2021). HED was defined by the survey instrument as at least one occasion with five or more drinks for men and four or more for women in the past 30 days (SENDA, 2025). Because the relative risk functions are calibrated to a threshold of 60 g of pure alcohol per occasion (WHO, 2024; WHO Regional Office for Europe, 2025), drinks were converted using the Chilean standard drink of approximately 14 g (MINSAL, 2011), so the survey item approximates 70 g in men and 56 g in women; this discrepancy is declared rather than adjusted, and the 60 g threshold is applied only within the integration step (Ruiz-Tagle Maturana et al., 2026). *(139 palabras)*

**Paragraph 2 — Consumption distribution, missing data and integration.**
Within each year × age × sex × HED stratum, consumption among current drinkers was modelled with a one-parameter gamma distribution using the international SD-to-mean ratios of 1.171 (men) and 1.258 (women) (Kehoe et al., 2012; Sherk et al., 2017), rescaled to recorded per-capita consumption (Rehm et al., 2010), and integrated over 0.03–150 g/day. For ischaemic heart disease, ischaemic stroke and injuries, current drinkers were stratified by HED status with RR_HED(x) = max(RR(x), 1) and a two-component attributable-fraction formula (WHO Regional Office for Europe, 2025, p. 2, Formula S.2b; Sherk et al., 2017, Formula 3.9). Item non-response in the HED question was excluded only from that indicator's denominator, following the WHO convention of respondents plus abstainers (WHO GHO, indicators 458–459), and was never recoded as "no"; complete-case estimates are reported with the resulting underestimation of current-drinker prevalence declared. *(132 palabras)*

## 7. BibTeX

```bibtex
@misc{who_gho_459,
  author = {{World Health Organization}},
  title  = {Alcohol, heavy episodic drinking (population) past 30 days — Indicator Metadata Registry 459},
  url    = {https://www.who.int/data/gho/indicator-metadata-registry/imr-details/459},
  note   = {Consultado el 7 de octubre de 2026}
}

@misc{who_gho_458,
  author = {{World Health Organization}},
  title  = {Alcohol, heavy episodic drinking (drinkers only) past 30 days — Indicator Metadata Registry 458},
  url    = {https://www.who.int/data/gho/indicator-metadata-registry/imr-details/458},
  note   = {Consultado el 7 de octubre de 2026}
}

@report{who_gsrahtsud_2024,
  author      = {{World Health Organization}},
  title       = {Global status report on alcohol and health and treatment of substance use disorders},
  institution = {World Health Organization},
  address     = {Geneva},
  year        = {2024},
  url         = {https://www.who.int/publications/i/item/9789240096745}
}

@article{shield_2025,
  author  = {Shield, Kevin and Franklin, Amélie and Wettlaufer, Ashley and others},
  title   = {National, regional, and global statistics on alcohol consumption and associated burden of disease 2000–20: a modelling study and comparative risk assessment},
  journal = {The Lancet Public Health},
  year    = {2025},
  volume  = {10},
  number  = {9},
  pages   = {e751--e761},
  doi     = {10.1016/S2468-2667(25)00174-4}
}

@article{kilian_2025,
  author  = {Kilian, Carolin and Buckley, Charlotte and Lemp, Julia M. and Kou, Xinyi and Kerr, William C. and Mulia, Nina and others},
  title   = {Targeting alcohol use in high-risk population groups: a US microsimulation study of beverage-specific pricing policies},
  journal = {The Lancet Public Health},
  year    = {2025},
  volume  = {10},
  number  = {10},
  pages   = {e815--e823},
  doi     = {10.1016/S2468-2667(25)00165-3}
}

@techreport{who_euro_2025_injuries,
  author      = {{WHO Regional Office for Europe}},
  title       = {Alcohol-attributable injuries in the {WHO European Region}: web annex – data sources and methods underlying the 2019 estimates},
  institution = {WHO Regional Office for Europe},
  address     = {Copenhagen},
  year        = {2025},
  note        = {WHO/EURO:2025-12985-52759-82187},
  url         = {https://www.who.int/europe/publications/i/item/WHO-EURO-2025-12985-52759-82187}
}

@techreport{sherk_2017_intermahp,
  author = {Sherk, Adam and Stockwell, Tim and Rehm, Jürgen and Dorocicz, Jessica and Shield, Kevin D.},
  title  = {{InterMAHP}: a comprehensive guide to the estimation of alcohol-attributable morbidity and mortality. Version 1.0},
  year   = {2017},
  url    = {https://www.drugsandalcohol.ie/28421/1/InterMAHP%20A%20comprehensive_guide_to_%20estimation_of_alcohol-attributable_morbidity-and_mortality.pdf}
}

@article{kehoe_2012,
  author  = {Kehoe, Tara and Gmel, Gerhard and Shield, Kevin D. and Gmel, Gerrit and Rehm, Jürgen},
  title   = {Determining the best population-level alcohol consumption model and its impact on estimates of alcohol-attributable harms},
  journal = {Population Health Metrics},
  year    = {2012},
  volume  = {10},
  pages   = {6},
  doi     = {10.1186/1478-7954-10-6}
}

@article{rehm_2010_modeling,
  author  = {Rehm, Jürgen and Kehoe, Tara and Gmel, Gerhard and Stinson, Frederick and Grant, Bridget and Gmel, Gerrit},
  title   = {Statistical modeling of volume of alcohol exposure for epidemiological studies of population health: the {US} example},
  journal = {Population Health Metrics},
  year    = {2010},
  volume  = {8},
  pages   = {3},
  doi     = {10.1186/1478-7954-8-3}
}

@article{gmel_2011_uncertainty,
  author  = {Gmel, Gerrit and Shield, Kevin D. and Frick, Hanna and Kehoe, Tara and Gmel, Gerhard and Rehm, Jürgen},
  title   = {Estimating uncertainty of alcohol-attributable fractions for infectious and chronic diseases},
  journal = {BMC Medical Research Methodology},
  year    = {2011},
  volume  = {11},
  pages   = {48},
  doi     = {10.1186/1471-2288-11-48}
}

@article{gmel_2013_capping,
  author  = {Gmel, Gerrit and Shield, Kevin D. and Rehm, Jürgen},
  title   = {Developing a method to derive alcohol-attributable fractions for individual studies: capping of alcohol consumption at 150 g/day},
  journal = {BMC Medical Research Methodology},
  year    = {2013},
  volume  = {13},
  pages   = {24},
  doi     = {10.1186/1471-2288-13-24}
}

@article{parish_2017,
  author  = {Parish, William J. and Aldridge, Arnie P. and Allaire, Benjamin and Ekwueme, Donatus U. and Poehler, Diana and Guy, Gery P. and others},
  title   = {A new methodological approach to adjust alcohol exposure distributions to improve the estimation of alcohol-attributable fractions},
  journal = {Addiction},
  year    = {2017},
  volume  = {112},
  number  = {11},
  pages   = {2053--2063},
  doi     = {10.1111/add.13880}
}

@techreport{moskalewicz_2010_smart,
  author      = {Moskalewicz, Jacek and Sieroslawski, Janusz},
  title       = {Drinking population surveys: guidance document for standardized approach. Final report prepared for the project {Standardizing Measurement of Alcohol-Related Troubles} ({SMART})},
  institution = {Institute of Psychiatry and Neurology},
  address     = {Warsaw},
  year        = {2010},
  url         = {https://www.drugsandalcohol.ie/15682/1/EU_Comm_Drinking_population_surveys.pdf}
}

@article{greenfield_2009,
  author  = {Greenfield, Thomas K. and Kerr, William C. and Bond, Jason and Ye, Yu and Stockwell, Tim},
  title   = {Improving graduated frequencies alcohol measures for monitoring consumption patterns: results from an {Australian} national survey and a {US} diary validity study},
  journal = {Contemporary Drug Problems},
  year    = {2009},
  volume  = {36},
  number  = {3--4},
  pages   = {705--733},
  doi     = {10.1177/009145090903600320}
}

@article{tevik_2021,
  author  = {Tevik, Kjerstin and Bergh, Sverre and Selbæk, Geir and Johannessen, Aud and Helvik, Anne-Sofie},
  title   = {A systematic review of self-report measures used in epidemiological studies to assess alcohol consumption among older adults},
  journal = {PLOS ONE},
  year    = {2021},
  volume  = {16},
  number  = {12},
  pages   = {e0261292},
  doi     = {10.1371/journal.pone.0261292}
}

@misc{niaaa_standard_drink,
  author = {{National Institute on Alcohol Abuse and Alcoholism}},
  title  = {What is a standard drink? / ¿Qué es una bebida estándar?},
  url    = {https://www.niaaa.nih.gov/alcohols-effects-health/que-es-una-bebida-estandar},
  note   = {Consultado el 7 de octubre de 2026}
}

@article{vinader_2017,
  author  = {Vinader-Caerols, Concepción and Talk, Andrew and Montañés, Adriana and Duque, Arantxa and Monleón, Santiago and Parra, Andrés},
  title   = {Blood alcohol concentration-related lower performance in immediate visual memory and working memory in adolescent binge drinkers},
  journal = {Frontiers in Psychology},
  year    = {2017},
  volume  = {8},
  pages   = {1720},
  doi     = {10.3389/fpsyg.2017.01720}
}

@article{herrero_2022,
  author  = {Herrero-Montes, Manuel and others},
  title   = {Relationship between depressive symptoms, personality, and binge drinking among university students in {Spain}},
  journal = {Journal of Clinical Medicine},
  year    = {2022},
  volume  = {11},
  number  = {1},
  pages   = {53},
  doi     = {10.3390/jcm11010053}
}

@techreport{senda_enpg_2024,
  author      = {{Servicio Nacional para la Prevención y Rehabilitación del Consumo de Drogas y Alcohol (SENDA)}},
  title       = {16° {Estudio Nacional de Drogas en Población General de Chile} 2024: principales resultados [presentación oficial, 4 de diciembre de 2025]},
  institution = {SENDA},
  address     = {Santiago de Chile},
  year        = {2025},
  url         = {https://psiconecta.org/blog/16-estudio-nacional-de-drogas-en-poblacion-general}
}

@article{ruiztagle_2026,
  author  = {Ruiz-Tagle Maturana, José and Román Mella, Francisca and Castillo-Carniglia, Álvaro},
  title   = {Sex and age differences in alcohol-attributable mortality in {Chile} between 2008 and 2022},
  journal = {Public Health in Practice},
  year    = {2026},
  volume  = {11},
  pages   = {100798},
  doi     = {10.1016/j.puhip.2026.100798}
}

@article{ruiztagle_2026_corrigendum,
  author  = {Ruiz-Tagle Maturana, José and Román Mella, Francisca and Castillo-Carniglia, Álvaro},
  title   = {Corrigendum to “{Sex and age differences in alcohol-attributable mortality in Chile between 2008 and 2022}”},
  journal = {Public Health in Practice},
  year    = {2026},
  volume  = {12},
  pages   = {100812},
  doi     = {10.1016/j.puhip.2026.100812}
}

@misc{ruiztagle_code,
  author = {Ruiz-Tagle Maturana, José and Román Mella, Francisca and Castillo-Carniglia, Álvaro},
  title  = {Data and code: {Sex and age differences in alcohol-attributable mortality in Chile between 2008 and 2022}},
  year   = {2026},
  doi    = {10.5281/zenodo.18375712},
  url    = {https://github.com/ACC1240138/Sex-and-age-differences-in-alcohol-attributable-mortality-in-Chile-between-2008-and-2022}
}

@article{castillo_2013,
  author  = {Castillo-Carniglia, Álvaro and Kaufman, Jay S. and Pino, Paulina},
  title   = {Alcohol-attributable mortality and years of potential life lost in {Chile} in 2009},
  journal = {Alcohol and Alcoholism},
  year    = {2013},
  volume  = {48},
  number  = {6},
  pages   = {729--736},
  doi     = {10.1093/alcalc/agt066}
}

@techreport{minsal_2011_ib,
  author      = {{Ministerio de Salud de Chile}},
  title       = {Intervenciones breves para reducir el consumo de alcohol: guía técnica resumida},
  institution = {Ministerio de Salud de Chile},
  address     = {Santiago de Chile},
  year        = {2011},
  url         = {https://diprece.minsal.cl/wrdprss_minsal/wp-content/uploads/2016/02/5.-MINSAL_2011_-Intervenciones-breves-alcohol.pdf}
}
```

## 8. Lista de NO ENCONTRADO / NO VERIFICADO y discrepancias

**Discrepancias de candidatos verificados:**

1. **Gmel 2011 (doi:10.1186/1471-2288-11-48).** El DOI existe y es correcto, pero el artículo trata la **estimación de incertidumbre** de los AAF (simulación Monte Carlo para IC), **no** la fórmula de AAF de lesiones en dos componentes que el encargo le atribuía como candidato. La fuente real de esa fórmula es el anexo web de OMS-EURO 2025 (p. 2, Fórmulas S.2a–S.2b) y la guía InterMAHP (Sherk 2017, pp. 44–46, Fórmula 3.9). Reportado aquí en lugar de reemplazarlo en silencio, según lo instruido.
2. Los demás candidatos coinciden: Shield 2025 (10.1016/S2468-2667(25)00174-4), Kehoe 2012 (10.1186/1478-7954-10-6; PMC3352241), WHO-EURO 2025 (WHO/EURO:2025-12985-52759-82187 = anexo web de lesiones, 57 pp., publicado el 3 de diciembre de 2025), guía InterMAHP (sin DOI; drugsandalcohol.ie), Kilian 2025 (10.1016/S2468-2667(25)00165-3; verificado vía Crossref).

**NO ENCONTRADO (se describe lo buscado):**

3. **Precedente de umbral femenino de 48 g** (4 tragos × 12 g). Buscado en: definiciones OMS GHO (458/459), OMS 2024 GSRAHTSUD, OMS-EURO 2025, InterMAHP, NIAAA, adaptación española del criterio NIAAA, guía SMART y Shield 2025. Los umbrales por sexo localizados son 70/56 g (NIAAA, trago de 14 g), 60/50 g (España, UBE de 10 g) y >60/>40 g/día de volumen diario (Kilian 2025). Ninguna fuente usa 48 g.
4. **Documentación de SENDA sobre el tratamiento de la no-respuesta (códigos 88/99) en ENPG.** Buscado en: presentación oficial de principales resultados ENPG 2024 (leída completa: contiene ficha técnica pero no el tratamiento de no-respuesta de ítem), informe completo ENPG 2022 (descarga fallida por tiempo de espera, dos intentos) y páginas sidoc.senda.gob.cl (error de acceso).
5. **Definición legal/reglamentaria chilena del trago estándar en gramos.** Buscado en: MINSAL, SENDA, normas sanitarias de alimentos. Lo más cercano es la guía técnica MINSAL 2011 (≈14 g, con base en la ENS: 15,5 g), que es un documento técnico, no una norma.
6. **Convenciones de cotas ("bounds") o de imputación múltiple para no-respuesta de ítem en la literatura AAF/InterMAHP/OMS.** Buscado en las fuentes 1–23 del §3 y en búsquedas dirigidas ("multiple imputation", "bounds", "item nonresponse" + "alcohol-attributable fraction"). No se localizó ninguna; la práctica documentada es caso completo por indicador (GHO; Rehm 2010).
7. **Evidencia latinoamericana (fuera de Chile) sobre convenciones de datos faltantes o valoración de categorías en estudios AAF.** Buscado con combinaciones en español e inglés; no se localizó ninguna fuente pertinente revisada por pares.
8. **Media empírica de la categoría abierta de cantidad usual en Chile** (análoga a 12+ → 15,5 en EUA de Greenfield 2009). No publicada; estimable con microdatos ENPG o ENS.

**NO VERIFICADO:**

9. **Redacción literal del ítem HED y de las categorías de cantidad por ola ENPG (2010–2022)** ("7 a 9"/"10 o más"; inicio de la escala 2018 en 1). Solo se verificaron: etiquetas de datos 2008 ("0-2"…"9 o mas", vía código del proyecto) y la nota al pie oficial 2024 ("5 o más tragos para hombres, 4 o más para mujeres"). El informe completo ENPG 2022 y las páginas sidoc no fueron accesibles.
10. **Conversión a gramos por trago usada en Castillo-Carniglia 2013** (doi:10.1093/alcalc/agt066): artículo con acceso restringido (leído solo el resumen/metadatos); la página de la tesis asociada (bibliodigital.saludpublica.uchile.cl) falló al acceder.
11. **Detalle operacional del HED en Kilian 2025** más allá de los umbrales de volumen diario por sexo (>60/>40 g/día): leído solo el resumen/metadatos.

---

*Contenido con fines exclusivamente informativos y de apoyo metodológico; no constituye asesoría profesional en salud pública ni sustituye el juicio del equipo investigador. Las cifras marcadas como ESTIMADO provienen de las fuentes citadas; las marcadas ASUMIDO carecen de fuente localizada y se señalan como tales.*
