KIMI-P7 | 2026-10-07 | 12 referencias leídas a texto completo / 8 solo resumen, parciales o indirectas

# Propagación de incertidumbre Monte Carlo en AAF, muertes atribuibles y PIF (FONDECYT 1240138): veredicto metodológico

**Alcance.** Este informe falla sobre las decisiones **D-a–D-g** del encargo, que afectan a los **intervalos** de incertidumbre —no a las estimaciones puntuales— en la estimación Monte Carlo de fracciones atribuibles al alcohol (AAF), muertes atribuibles y fracciones de impacto potencial (PIF) para Chile (exposición ENPG-SENDA, mortalidad DEIS-MINSAL, 15–65 años, 2012–2024), con funciones de riesgo relativo (RR) del informe [OMS 2024](https://www.who.int/publications/i/item/9789240096745) en forma canónica InterMAHP y una etapa posterior de microsimulación tipo SIMAH (referencia aportada por el encargo; **no verificada**, ver §8). Convención de etiquetas: **[TEXTO]** = afirmación literal de la fuente (cita textual <30 palabras cuando fue posible); **[INFERENCIA]** = deducción del analista a partir de las fuentes. Sin cita, no se incluye. Las cifras del pipeline del estudio (p. ej., rangos de factores de diseño) se citan como «dato del encargo» y se tratan como ESTIMADOS internos no auditados.

## 1. Tabla de veredictos por opción (D-a–D-g)

| Decisión [ID] | Opción | Apoyo | Referencias clave | Por qué |
|---|---|---|---|---|
| D-a [C1] | **n_eff = n/deff** con factor combinado (Kish × conglomerado residual) en draws Dirichlet/Beta/gamma | **Moderado** | [Kish 1965]; [Kish 1995]; [Chen & Rust 2017]; [Gmel 2011]; [Briggs 2012] | La descomposición multiplicativa del deff (ponderación × estratificación × conglomeración) tiene justificación basada en modelo y actúa como cota superior aproximada [TEXTO, Chen & Rust 2017]; n* = n/deft² es la forma canónica del tamaño efectivo [TEXTO-indirecto, Kish 1965 pp. 162–163]; Gmel et al. propagaron prevalencias con varianza binomial y n efectivo **asumido** = 1000 [TEXTO: «The effective sample size of each survey … was assumed to be 1000»]; TF-6 avala la familia beta para datos binomiales [TEXTO: «beta distributions are a natural match for binomial data»]. [INFERENCIA] Sustituir el 1000 asumido por un deff empírico de la ENPG es una extensión defensible y más fiel al diseño, pero ningún método AAF publicado la usa: debe declararse como extensión propia (§8 #5). |
| D-a | Pesos réplica (bootstrap/BRR/jackknife) o linealización de Taylor directa | **Fuerte** (método de referencia) | [Rust & Rao 1996]; [Wolter 2007]; [Kish 1995] §9 | Son los métodos estándar de estimación de varianza en encuestas complejas [TEXTO-solo resumen, Rust & Rao 1996]; Kish 1995 §9 los reconoce como el desarrollo central del campo [TEXTO]. [INFERENCIA] Exigen identificadores de UPM/estrato en **todas** las olas —ausentes en ENPG 2020 (dato del encargo)—, por lo que hoy solo son viables como validación parcial, no como sustituto completo. |
| D-a | Muestreo aleatorio simple (ignorar el diseño) | **Contrario** | [Kish 1995]; [Briggs 2012] | Si deff>1, las fórmulas MAS subestiman las varianzas [TEXTO, definición de deff en Kish 1995 p. 56]; el espíritu de TF-6 VI-8 prohíbe excluir fuentes de incertidumbre por falta de información [TEXTO]. |
| D-b [Q13] | **Sin piso**: conservar deff < 1 | **Fuerte** | [Kish 1995]; [Valliant, PracTools]; [Kish 1965] | Con estratificación óptima el deff es «necessarily less than or equal to one» (Cochran 1977, citado en [Valliant]) [TEXTO]; la estratificación reduce la varianza «to the degree that the stratum means diverge and that homogeneity exists within strata» (Kish 1965 p. 76, citado en [Valliant]) [TEXTO-indirecto]; efectos de asignación «may overcome the clustering effects and thus result in deft < 1» (Kish 1995 §8d2) [TEXTO]. |
| D-b | Piso en 1 (truncar deff < 1) | **Débil / condicionado** | [Kish 1995] §6 | Kish solo propone «curtail deft² at 1» para **diferencias de medias** en crossclasses atribuibles a variación aleatoria [TEXTO] — no es el caso de proporciones por celda. [INFERENCIA] Como análisis de sensibilidad conservador (ensancha intervalos) es aceptable; como regla general, contradice la literatura. |
| D-c [C2] | **Donante 2018** (mismo marco muestral) | **Fuerte-moderado** | [Kish 1995] §4d; [Valliant, PracTools] | Los defts son «generalizable ("transferable") … within the same survey, and even to other surveys» (Kish 1995 §1) [TEXTO], pero «these generalizations involve increasing risks with distancing of either survey variables or of sample designs» (§4d) [TEXTO]. [INFERENCIA] 2018 comparte marco con 2020: es la transferencia de menor riesgo disponible. |
| D-c | Pseudo-PSU (conglomerados artificiales gruesos) como cota superior | **Moderado** (sensibilidad) | [Wolter 2007] §2.5 | El estimador de estratos colapsados tiende a sobrestimar la varianza [TEXTO-parcial]. [INFERENCIA] Agregar respondientes en pseudo-conglomerados más grandes que la UPM real infla el deff: sirve como cota superior de ancho, no como estimador central. |
| D-c | Donante 2022 (marco distinto) — práctica actual | **Contrario** | [Valliant, PracTools]; [Kish 1995] §4d | «If the new design will have different strata or cluster definitions than the last, deff's from the previous survey may not apply» [TEXTO]; el riesgo crece con la distancia de diseño [TEXTO]. |
| D-c | Declarar intervalos optimistas y usar MAS | **Contrario** | [Briggs 2012] | «On no account should parameters be excluded from an uncertainty analysis on the grounds that 'there is not enough information to estimate uncertainty'» [TEXTO]. |
| D-d [Q15/B13] | **Draws alineados** (mismo índice/semilla; comonotonía parcial en parámetros compartidos) | **Moderado-fuerte** | [GBD 2019 RF]; [GBD 2016]; [Gmel 2011]; [Law 2015] §11.2 | GBD aplica PAFs «at the draw level» y usa los draws «throughout the entire modelling process» [TEXTO]; la función RR «were assumed to be the same for all regions and age groups» [TEXTO, Gmel 2011] ⇒ el RR es un parámetro **compartido** entre celdas y debe correlacionarse; alinear índices implementa números aleatorios comunes [TEXTO-título, Law §11.2]. [INFERENCIA] La alineación comonotónica en parámetros compartidos produce intervalos de agregados más anchos (conservadores) que la independencia. |
| D-d | Envolvente de límites (sumar límites de celdas) — práctica residual actual | **Contrario** | [INFERENCIA] sobre [GBD 2019 RF] | La suma de cuantiles no es el cuantil de la suma: la envolvente no tiene nivel de cobertura interpretable. Ninguna fuente la avala; toda la literatura AAF/GBD agrega a nivel de draw. |
| D-d | Draws independientes entre celdas | **Débil** (solo como cota inferior de ancho) | [Briggs 2012] VI-10 | «Correlation among parameters should be considered» y la independencia entre parámetros estimados conjuntamente no debe asumirse por defecto [TEXTO]. [INFERENCIA] Útil como sensibilidad de mínima anchura, no como especificación primaria. |
| D-d | Covarianza empírica entre celdas | **Ninguno** | — | NO ENCONTRADO: ningún método AAF publicado estima correlación empírica entre draws de celdas de encuesta (§8 #5). |
| D-e [B5] | **Reconstruir la covarianza** (Greenland–Longnecker / delta) o solicitarla a los autores | **Fuerte** | [Greenland & Longnecker 1992]; [Roerecke & Rehm 2012]; [Sherk 2017]; [Briggs 2012] | GL92: «two methods that account for the correlations but require only the summary estimates and marginal data» [TEXTO-solo resumen]; InterMAHP documenta obtener ecuaciones funcionales no publicadas «directly from members of authorship group» [TEXTO]; TF-6: la normalidad multivariante del predictor lineal con su matriz de covarianza es la forma apropiada [TEXTO]. |
| D-e | Fuente alternativa con draws de **curva completa** (GBD 2020) | **Moderado-fuerte** | [GBD 2020] | «Uncertainty in the relative risk curve, based on 1000 draws of each cause-specific relative risk curve …, was propagated» [TEXTO]: sortear la curva entera evade la covarianza de coeficientes. [INFERENCIA] Aplicable si la causa-sexo existe en GBD 2020 y se acepta su definición de exposición. |
| D-e | Matriz diagonal (independencia entre coeficientes) — práctica actual | **Contrario** | [Briggs 2012] VI-10; [Roerecke & Rehm 2012] | Con términos colineales (x y x·ln x) la independencia deforma la varianza de ln RR a dosis altas [INFERENCIA]; el propio pipeline lo demuestra: 231/420 celdas de mujeres con límite superior PIF > 0,5 y puntual ≈ 0,005 (dato del encargo). Además, los IC continuos «overestimate precision around the curves at low levels of consumption» [TEXTO]. |
| D-e | Reportar solo el puntual | **Contrario** | [Briggs 2012] VI-8 | Prohibido textualmente por TF-6 [TEXTO]. Declarar la limitación sin truncar es la vía honesta si nada más es viable. |
| D-f [B12] | **Media/mediana de draws + IC percentil 2,5/97,5** (convención GBD) | **Fuerte** | [GBD 2016]; [Briggs 2012]; [Law 2015] §4.7 | GBD presenta «the 2·5th and 97·5th percentiles of the draws» [TEXTO]; en modelos no lineales TF-6 exige PSA para generar los valores esperados apropiados [TEXTO]; Law §4.7: «The Danger of Replacing a Probability Distribution by Its Mean» [TEXTO-título]. |
| D-f | Forzar lower ≤ puntual ≤ upper — práctica actual | **Contrario** | [INFERENCIA] sobre [Briggs 2012]; [Law 2015] | El puntual plug-in y la distribución MC son estimadores de cosas distintas en presencia de no linealidad (desigualdad de Jensen); forzar el orden distorsiona ambos y oculta información diagnóstica. |
| D-f | Puntual con advertencia | **Débil** | [INFERENCIA] | Aceptable solo como fila complementaria etiquetada «determinista plug-in», nunca como estimador principal. |
| D-g [C1] | **Clave reconstruida** comuna+distrito+zona (≈2 358 UPM en 2016) si reproduce las etapas reales de selección | **Moderado** | [Valliant, PracTools]; [Kish 1995] §6 | Las definiciones de conglomerado/estrato deben corresponder al diseño real [TEXTO, Valliant]; «Deff decreases toward 1 with the decrease in the cluster sizes» [TEXTO, Kish 1995 §6]. [INFERENCIA] Más UPM de menor tamaño ⇒ deff más cercano a 1: la clave reconstruida no es conservadora, es más fiel **si** coincide con el diseño. |
| D-g | Manzana sola (≈2 000 conglomerados en 2016) | **Moderado** (sensibilidad conservadora) | [Kish 1995] §6 | [INFERENCIA] Menos conglomerados, más grandes ⇒ deff mayor ⇒ intervalos más anchos: cota superior razonable mientras no se confirme el diseño. |
| D-g | Estratos: región vs. comuna | **Condicionado** | [Wolter 2007] §2.5; [Kish 1995] §6 | Usar los estratos del diseño documentado; con pocas UPM por estrato, colapsar estratos (sobreestima varianza, dirección segura) [TEXTO-parcial, Wolter]. [INFERENCIA] Estratos con 1 UPM por celda inestabilizan los deff (Kish 1995 §6 advierte sobre pocas UPM por región). |
| D-g | Mezclar variables de diseño entre marcos (2020↔2022) | **Contrario** | [Valliant, PracTools]; [Kish 1995] §4d | Veredicto ya dado en D-c: los deff no viajan entre marcos distintos [TEXTO]. |

### 1b. Tabla de parámetros

| ID | Parámetro / decisión | Valor / opción | Fuente (DOI + página/tabla) | Estimado / Asumido | Transportabilidad a Chile |
|---|---|---|---|---|---|
| P1 | Tamaño efectivo por celda | n_eff = n / deff; deff = (SE_diseño/SE_Kish)² por año×edad×sexo×variable | [Kish 1965] pp. 162–163 (vía fuentes secundarias); [Chen & Rust 2017] doi:10.1093/jssam/smw036 | **Estimado** (pipeline, dato del encargo) | **Alta**: se estima sobre la propia ENPG; es la opción más local posible. |
| P2 | n efectivo para prevalencias en AAF | 1000 por encuesta | [Gmel 2011] doi:10.1186/1471-2288-11-48, sección Statistical analysis | **Asumido** | **Baja**: constante universal sin relación con el diseño ENPG; motiva reemplazarlo por P1. |
| P3 | Nº de draws para IC 95 % estables | 150 000 (60 000–70 000 suelen bastar; ~40 000 para ±0,01) | [Gmel 2011] doi:10.1186/1471-2288-11-48, Results/Discussion | **Estimado** (simulación) | **Alta**: el error Monte Carlo no depende del país; con 10 000 draws actuales, reportar MCSE ([Koehler 2009]). |
| P4 | Varianza del κ gamma | Var(κ) = 4·Var(β)/β⁶ (método delta) | [Gmel 2011] doi:10.1186/1471-2288-11-48, Statistical analysis | **Estimado** | **Alta**: identidad matemática, independiente de la población. |
| P5 | Factor de corrección de consumo per cápita | 0,8 (default InterMAHP, advisory OMS) | [Sherk 2017] url:drugsandalcohol.ie/28421, guía v1.0 | **Asumido** | **Media**: convención internacional; sensible a la cobertura del registro de ventas chileno. |
| P6 | Límite superior de integración del consumo | z = 250 g/día con extrapolación tope | [Sherk 2017] url:drugsandalcohol.ie/28421, guía v1.0 (fórmula D-2) | **Asumido** | **Alta**: convención del modelo canónico; afecta poco a PIF con colas acotadas. |
| P7 | Forma funcional RR-IHD mujeres (fuente alternativa) | log_RR = x + ln(x)·x (términos x y x·ln x) | [Roerecke & Rehm 2012] doi:10.1111/j.1360-0443.2012.03780.x, Tabla 3 | **Estimado** (meta-análisis de cohortes) | **Media**: cohortes internacionales no chilenas; Roerecke & Rehm advierten precisión sobreestimada a bajas dosis. |
| P8 | Convención de agregación e intervalo | Draws compartidos en todo el pipeline; IC = percentiles 2,5/97,5 de los draws | [GBD 2016] doi:10.1016/S0140-6736(18)31310-2; [GBD 2019 RF] doi:10.1016/S0140-6736(20)30752-2 | **Estimado** (convención) | **Alta**: convención metodológica global, directamente portable. |
| P9 | Carga global de alcohol (contexto) | 2,6 millones de muertes (4,7 % de todas las muertes), 2019 | [OMS 2024] who.int/publications/i/item/9789240096745 (metadatos) | **Estimado** | **Media**: solo contexto; no entra en los intervalos del estudio. |
| P10 | AAF Chile precedente | 14,6 % (IC 95 % 10,9–18,4) en 2008 → 9,6 % (7,2–12,2) en 2022, ≥15 años | [Ruiz-Tagle Maturana 2026] doi:10.1016/j.puhip.2026.100798 | **Estimado** | **Alta** en fuentes (ENPG + DEIS, Monte Carlo), **pero no independiente**: mismo proyecto FONDECYT 1240138. |
| P11 | deff transferido entre olas del mismo marco | Donante 2018 → 2020 | [Kish 1995] §4d, scb.se (URL en §7) | **Asumido** | **Media**: válido si el marco es realmente idéntico; riesgo creciente con la distancia de diseño. |

## 2. Respuestas a Q1–Q7 (≤150 palabras cada una)

**Q1. ¿Cómo propagan los métodos AAF publicados la incertidumbre de prevalencias de encuestas complejas? ¿Se acepta n_eff con deff en draws Beta/Dirichlet?**
Gmel et al. modelan abstención/exconsumo con varianza binomial «considering only sampling variation» y **asumen** n efectivo = 1000 por encuesta, sin derivar deff del diseño ([Gmel 2011](https://doi.org/10.1186/1471-2288-11-48)) [TEXTO: «The effective sample size of each survey … was assumed to be 1000»]. InterMAHP v1 **no** produce incertidumbre cuantitativa y prevé Monte Carlo en versiones futuras ([Sherk 2017](https://www.drugsandalcohol.ie/28421/)) [TEXTO]. GBD propaga 1000 draws de exposición por celda edad-sexo-lugar-año ([GBD 2019 RF](https://doi.org/10.1016/S0140-6736(20)30752-2)) [TEXTO]. De OMS 2024 solo se verificaron metadatos: práctica detallada NO ENCONTRADA (§8 #5). Kish define n* = n/deft² ([Kish 1965]) [TEXTO-indirecto] y TF-6 avala beta/binomial ([Briggs 2012](https://doi.org/10.1016/j.jval.2012.04.014)) [TEXTO]. [INFERENCIA] Sustituir el 1000 asumido por n_eff empírico con deff es una extensión defensible y más fiel a la ENPG, pero debe declararse como extensión propia.

**Q2. ¿Piso en 1 para deff < 1?**
No como regla general. Con estratificación óptima el deff es «necessarily less than or equal to one» (Cochran 1977, citado en [Valliant, PracTools](https://cran.r-project.org/web/packages/PracTools/vignettes/Design-effects.html)) [TEXTO]; la estratificación reduce la varianza «to the degree that the stratum means diverge and that homogeneity exists within strata» (Kish 1965 p. 76, vía [Valliant]) [TEXTO-indirecto]; y los efectos de asignación «may overcome the clustering effects and thus result in deft < 1» ([Kish 1995](https://www.scb.se/contentassets/ca21efb41fee47d293bbee5bf7be7fb3/methods-for-design-effects.pdf) §8d2) [TEXTO]. El único recorte en 1 que propone Kish es para **diferencias de medias** en crossclasses atribuidas al azar («curtail deft² at 1», §6) [TEXTO] — no aplicable a proporciones por celda. [INFERENCIA] Mantener deff<1 es correcto; si se desea prudencia, reportar sensibilidad con piso=1 (ensancha intervalos).

**Q3. ¿Deff aproximado para la ola 2020 sin identificadores de conglomerado?**
Kish avala transferir defts «within the same survey, and even to other surveys» (§1) [TEXTO], pero advierte que las generalizaciones desde encuestas pasadas «involve increasing risks with distancing of either survey variables or of sample designs» (§4d) [TEXTO] ([Kish 1995](https://www.scb.se/contentassets/ca21efb41fee47d293bbee5bf7be7fb3/methods-for-design-effects.pdf)). Valliant: si el nuevo diseño tiene estratos/conglomerados distintos, los deff previos «may not apply» ([PracTools](https://cran.r-project.org/web/packages/PracTools/vignettes/Design-effects.html)) [TEXTO]. [INFERENCIA] 2018 (mismo marco) es la donante preferible; 2022 (marco distinto) debe abandonarse. Como cota superior: pseudo-conglomerados gruesos, análogos al estimador de estratos colapsados que sobreestima la varianza ([Wolter 2007] §2.5) [TEXTO-parcial]. Alternativa: suavizar deff por celda con funciones de varianza generalizada (GVF; [Wolter 2007] cap. 7; [Kish 1995] E.4A). Declarar siempre la transferencia.

**Q4. Números aleatorios comunes para intervalos conjuntos de sumas; TF-6/TF-7 y error Monte Carlo.**
GBD aplica PAFs «at the draw level» con 1000 draws compartidos de riesgo, exposición y TMREL ([GBD 2019 RF](https://doi.org/10.1016/S0140-6736(20)30752-2)) [TEXTO], usados «throughout the entire modelling process» ([GBD 2016](https://doi.org/10.1016/S0140-6736(18)31310-2)) [TEXTO]. Como la función RR es idéntica en todas las celdas ([Gmel 2011](https://doi.org/10.1186/1471-2288-11-48)) [TEXTO], alinear índices implementa números aleatorios comunes ([Law 2015] §11.2) [TEXTO-título]. TF-6 VI-10: «Correlation among parameters should be considered»; la independencia no se asume por defecto ([Briggs 2012](https://doi.org/10.1016/j.jval.2012.04.014)) [TEXTO]. Error Monte Carlo: cuantificarlo y reportarlo ([Koehler 2009](https://doi.org/10.1198/tast.2009.0030)); Gmel usó 150 000 draws para IC 95 % estables — con 10 000 el error de percentiles no es despreciable [INFERENCIA]. TF-7 exige documentación reproducible ([Eddy 2012](https://doi.org/10.1016/j.jval.2012.04.012)) [TEXTO-solo resumen].

**Q5. Covarianza de coeficientes RR cuando solo se publican SE marginales (x y x·ln x colineales).**
Greenland & Longnecker ofrecen «two methods that account for the correlations but require only the summary estimates and marginal data» ([GL 1992](https://doi.org/10.1093/oxfordjournals.aje.a116237)) [TEXTO-solo resumen]. TF-6: «The covariance matrix defines these uncertainties, and the assumption of multivariate normality is appropriate for the regression's linear predictor» ([Briggs 2012](https://doi.org/10.1016/j.jval.2012.04.014)) [TEXTO]; la correlación entre parámetros conjuntamente estimados debe reflejarse (VI-10). Gmel usó la «covariance matrix (obtained from the meta-analyses)» [TEXTO]. GBD 2020 propagó 1000 draws de cada **curva** RR completa, evadiendo la covarianza de coeficientes ([GBD 2020](https://doi.org/10.1016/S0140-6736(22)00847-9)) [TEXTO]. InterMAHP obtuvo ecuaciones no publicadas directamente de los autores ([Sherk 2017](https://www.drugsandalcohol.ie/28421/)) [TEXTO]. Roerecke & Rehm advierten que los IC continuos «overestimate precision around the curves at low levels of consumption» ([R&R 2012](https://doi.org/10.1111/j.1360-0443.2012.03780.x)) [TEXTO]. [INFERENCIA] Matriz diagonal = inaceptable con base colineal; su resultado degenerado (231/420 celdas, dato del encargo) lo confirma empíricamente.

**Q6. Punto determinista fuera del intervalo Monte Carlo.**
En modelos no lineales el valor esperado no es la función evaluada en las medias: TF-6 exige PSA para generar los valores esperados apropiados ([Briggs 2012](https://doi.org/10.1016/j.jval.2012.04.014)) [TEXTO], y Law titula su §4.7 «The Danger of Replacing a Probability Distribution by Its Mean» ([Law 2015]) [TEXTO-título]. La convención GBD reporta percentiles 2,5/97,5 **de los draws** ([GBD 2016](https://doi.org/10.1016/S0140-6736(18)31310-2)) [TEXTO]. [INFERENCIA] Si el puntual plug-in cae fuera del IC, el desplazamiento es información (sesgo de Jensen por la integral no lineal AAF/PIF), no un error de código: el estimador central debe ser la media/mediana Monte Carlo. Forzar lower ≤ puntual ≤ upper distorsiona ambos estimadores y destruye esa señal diagnóstica. Reportar además el plug-in etiquetado «determinista» es aceptable como transparencia, nunca como estimador principal.

**Q7. UPM/estratos cuando el marco muestral cambia entre olas; ¿mezclar variables de diseño entre marcos?**
Valliant: «Using deffs from earlier surveys can have serious limitations … If the new design will have different strata or cluster definitions than the last, deff's from the previous survey may not apply» ([PracTools](https://cran.r-project.org/web/packages/PracTools/vignettes/Design-effects.html)) [TEXTO]. Kish: generalizaciones válidas dentro del mismo marco, con riesgo creciente al alejarse (§4d) [TEXTO]; y dos períodos de una misma encuesta comparten conglomerados, lo que genera covarianzas que reducen el deff de las diferencias temporales (§6) ([Kish 1995](https://www.scb.se/contentassets/ca21efb41fee47d293bbee5bf7be7fb3/methods-for-design-effects.pdf)) [TEXTO]. [INFERENCIA] No mezclar variables de diseño entre marcos: tomar factores de 2022 para 2020 es exactamente eso. Definir UPM/estratos según las etapas reales documentadas de cada ola; si la documentación pública no existe (NO ENCONTRADO, §8 #3), solicitarla a SENDA y, mientras tanto, usar la reconstrucción más fiel más análisis de sensibilidad.

## 3. Tabla de evidencia

| Referencia | DOI / PMID / URL | Diseño / población | Qué sostiene | Números (página/tabla; unidad; denominador; período; estimado/asumido) | Transportabilidad | Calidad / limitaciones |
|---|---|---|---|---|---|---|
| Gmel G, Shield KD, Frick H, Kehoe T, Gmel G, Rehm J. 2011. *Estimating uncertainty of alcohol-attributable fractions for infectious and chronic diseases*. BMC Med Res Methodol 11:48. | doi:10.1186/1471-2288-11-48; PMID:21496313 | Marco metodológico Monte Carlo para AAF; aplicación global por regiones | Q1, Q4, Q5, D-a, D-d, D-e: varianza binomial de prevalencias; n efectivo **asumido** = 1000 por encuesta [TEXTO]; covarianza de coeficientes β de meta-análisis [TEXTO]; misma función RR para todas las regiones/edades [TEXTO]; RR = mayor contribuyente a la varianza en la mayoría de casos [TEXTO] | n_eff = 1000 (asumido); 150 000 draws recomendados para IC 95 % estables, 60 000–70 000 suelen bastar, ~40 000 para ±0,01 (estimado por simulación); Var(κ)=4·Var(β)/β⁶ (delta); período de la aplicación no consignado por falta de verificación | Alta (método canónico AAF-OMS) | Revisado por pares; leído a texto completo. Limitación: el n=1000 no deriva de deff real; la aplicación supone encuestas con solo variación muestral. |
| Briggs AH, et al. 2012. *Model Parameter Estimation and Uncertainty: ISPOR-SMDM TF-6*. Value Health 15(6):835–842. | doi:10.1016/j.jval.2012.04.014; PMID:22999133 (versión leída: Med Decis Making 32(6):722–732, doi:10.1177/0272989X12458348) | Guía de buenas prácticas de modelación en salud (consenso de sociedad) | Q1, Q4, Q5, Q6, D-a, D-e, D-f: VI-7 beta/binomial; VI-8 «On no account should parameters be excluded… 'there is not enough information to estimate uncertainty'» [TEXTO]; VI-10 «Correlation among parameters should be considered» [TEXTO]; normalidad multivariante del predictor lineal [TEXTO]; PSA requerido para valores esperados en no lineales [TEXTO] | Guía cualitativa; sin números transferibles | Alta (guía internacional vigente del campo) | Consenso experto, no evidencia empírica; leído a texto completo (versión MDM). |
| Eddy DM, et al. 2012. *Model Transparency and Validation: ISPOR-SMDM TF-7*. Value Health 15(6):843–850. | doi:10.1016/j.jval.2012.04.012; PMID:22999134 | Guía de transparencia y validación de modelos | Q4: descripción no técnica + documentación técnica suficiente para reproducir el modelo | Sin números | Alta | **Solo resumen** leído; publicación paralela en MDM 32(6):733–743. |
| Kish L. 1965. *Survey Sampling*. Nueva York: Wiley. | Sin DOI; referencia canónica (identificada en este informe) | Texto fundacional de muestreo | Q1, Q2, D-a, D-b: concepto de deff; n* = n/deft² (pp. 162–163); estratificación reduce varianza según diverjan las medias de estrato (p. 76) | deff = 1 + roh(b−1), p. 162 (fórmula; asumido como modelo) | Alta (canónico) | **No leído directamente**: citado vía [Valliant, PracTools] y Schnell 2005 (fuente secundaria). |
| Kish L. 1995. *Methods for Design Effects*. J Off Stat 11(1):55–77. | URL: scb.se/contentassets/ca21efb41fee47d293bbee5bf7be7fb3/methods-for-design-effects.pdf | Revisión metodológica con ejemplos de encuestas internacionales (WFS, DHS) | Q2, Q3, Q7, D-b, D-c, D-g: §1 defts «transferable»; §4d riesgo creciente con distancia de diseño [TEXTO]; §6 «Deff decreases toward 1 with the decrease in the cluster sizes» [TEXTO]; §6 «curtail deft² at 1» solo para diferencias de medias crossclass [TEXTO]; §8d2 deft<1 por asignación [TEXTO]; E.6B: deff por categoría, «choosing only one of the categories … was not sufficiently accurate» [TEXTO]; p. 57: defts como «rough measures for large effects» | Fórmula crossclass deft²(vc) = 1 + pc[deft²(v)−1] (estimado, modelo); ejemplos multiencuesta de 5 países (8 encuestas, E.6B) | Alta | Leído a texto completo; artículo de síntesis, no evaluación empírica de ENPG. |
| Chen S, Rust KF. 2017. *An Extension of Kish's Formula for Design Effects to Two- and Three-Way Designs with Stratification*. J Surv Stat Methodol 5(2):111–130. | doi:10.1093/jssam/smw036; PMC10426793; PMID:37583392 | Extensión teórica + ilustración empírica (encuesta de hogares EE. UU.) | D-a: descomposición Deff* ≤ Deff_w × Deff_S × Deff_C bajo igual tamaño de conglomerados [TEXTO]; justificación basada en modelo (Gabler, Häder & Lahiri 1999); el deff de Kish como estimador «somewhat conservative» | Desigualdad multiplicativa (teorema; asumido como cota); sin cifras chilenas | Alta | Leído a texto completo (PMC); la cota es exacta bajo condiciones que la ENPG cumple solo aproximadamente. |
| Rust KF, Rao JNK. 1996. *Variance estimation for complex surveys using replication techniques*. Stat Methods Med Res 5(3):283–310. | doi:10.1177/096228029600500305; PMID:8931197 | Revisión de métodos de replicación (jackknife, BRR, bootstrap) | D-a: réplicas como método estándar de varianza en encuestas complejas | Sin números transferibles | Alta | **Solo resumen** leído. |
| Wolter KM. 2007. *Introduction to Variance Estimation*. 2.ª ed. Springer. | Sin DOI verificado (libro) | Texto de referencia en estimación de varianza | D-a, D-c, D-g: cap. 7 funciones de varianza generalizada (GVF); §2.5 estimador de estratos colapsados (tiende a sobrestimar la varianza) | Sin números transferibles | Alta | **Leído parcialmente** (estructura y secciones citadas); 2.ª edición estándar del campo. |
| Valliant R. *Design Effects* (vignette del paquete PracTools de R). | URL: cran.r-project.org/web/packages/PracTools/vignettes/Design-effects.html | Vignette técnica (CRAN) basada en Valliant, Dever & Kreuter 2018 | Q2, Q3, Q7, D-b, D-c, D-g: Cochran 1977 §5.6 (deff ≤ 1 con estratificación óptima) [TEXTO]; cita de Kish 1965 p. 76 [TEXTO]; «Using deffs from earlier surveys can have serious limitations … deff's from the previous survey may not apply» [TEXTO] | Sin números transferibles | Alta | Leído a texto completo; no es revisión por pares, pero reproduce fuentes canónicas con citas verificables. |
| GBD 2016 Alcohol Collaborators. 2018. *Alcohol use and burden for 195 countries and territories, 1990–2016*. Lancet 392:1015–1035. | doi:10.1016/S0140-6736(18)31310-2 | Estudio de carga de enfermedad, 195 países, 1990–2016 | Q1, Q4, Q6, D-d, D-f: 1000 draws «throughout the entire modelling process»; «we present the 2·5th and 97·5th percentiles of the draws» [TEXTO] | 1000 draws (convención, asumido como diseño); IC = percentiles 2,5/97,5; población global, 1990–2016 (estimado) | Alta | Leído (métodos, texto completo); agregación global, no diseño de encuesta nacional. |
| GBD 2019 Risk Factors Collaborators. 2020. *Global burden of 87 risk factors in 204 countries and territories, 1990–2019*. Lancet 396:1223–1249. | doi:10.1016/S0140-6736(20)30752-2; PMID:33069327 | Evaluación comparativa de riesgos, 204 países, 1990–2019 | Q4, D-d: «By drawing 1000 samples from the risk function, 1000 distributions of exposure for each age-sex-location-year, and 1000 samples from the TMREL, we propagated all of these sources of uncertainty into the PAF distributions. PAFs were also applied at the draw level» [TEXTO] | 1000 draws por fuente de incertidumbre (asumido como diseño); 87 factores de riesgo; 204 países; 1990–2019 (estimado) | Alta | Leído (sección de métodos, texto completo PMC7566194). |
| GBD 2020 Alcohol Collaborators. 2022. *Population-level risks of alcohol consumption by amount, geography, age, sex, and year*. Lancet 400:185–235. | doi:10.1016/S0140-6736(22)00847-9; PMID:35843246; PMC9289789 | Análisis sistemático GBD 2020, global | Q5, D-e: «Uncertainty in the relative risk curve, based on 1000 draws of each cause-specific relative risk curve and 1000 draws of DALY rates used for weighting, was propagated» [TEXTO]; curvas RR ponderadas por causa | 1,78 millones de muertes atribuibles (IC 95 % 1,39–2,27), global, 2020 (estimado); 1000 draws por curva | Alta | Leído (secciones, texto completo); requiere mapa de causas GBD↔CIE-10 local. |
| Sherk A, Stockwell T, Rehm J, Dorocicz J, Shield KD. 2017. *InterMAHP: A comprehensive guide to the estimation of alcohol-attributable morbidity and mortality*. v1.0. CISUR, Universidad de Victoria. | URL: drugsandalcohol.ie/28421/ (105 p.) | Guía metodológica canónica del modelo InterMAHP | Q1, Q5, D-e: «InterMAHP does not currently produce quantitative uncertainty estimates» [TEXTO]; expansión futura con Monte Carlo; ecuaciones funcionales a menudo no publicadas y obtenidas «directly from members of authorship group» (cirrosis hepática, mujeres) [TEXTO]; fórmula AAF D-2 con P_FD e integral 0,03→z | Factor de corrección 0,8 (asumido, advisory OMS); límite superior z = 250 g/día (asumido); sin default de RR-IHD en hombres; 43 condiciones; GATHER cumplido salvo ítem 16 | Alta (es la forma canónica que usa el estudio) | Leído a texto completo; informe institucional no revisado por pares en revista (admisible como guía de métodos). |
| Roerecke M, Rehm J. 2012. *The cardioprotective association of average alcohol consumption and ischaemic heart disease: a systematic review and meta-analysis*. Addiction 107(7):1246–1260. | doi:10.1111/j.1360-0443.2012.03780.x; PMID:22229788; PMC3348338 | Meta-análisis dosis-respuesta de cohortes internacionales | Q5, D-e: Tabla 3 define la familia funcional (mujeres, mortalidad IHD: log_RR = x + ln(x)·x); pool-first tipo Greenland–Longnecker; «CIs from the continuous analysis thus overestimate precision around the curves at low levels of consumption» [TEXTO] | Formas funcionales por sexo y desenlace, Tabla 3 (estimado); x en g/día; cohortes internacionales | Media (poblaciones no chilenas) | Leído a texto completo (PMC); no publica la matriz de covarianza de los coeficientes — origen del problema D-e. |
| Greenland S, Longnecker MP. 1992. *Methods for trend estimation from summarized dose-response data, with applications to meta-analysis*. Am J Epidemiol 135(11):1301–1309. | doi:10.1093/oxfordjournals.aje.a116237; PMID:1626547 | Métodos estadísticos para datos dosis-respuesta resumidos | Q5, D-e: «two methods that account for the correlations but require only the summary estimates and marginal data» [TEXTO] | Sin números transferibles | Alta | **Solo resumen** leído. |
| Koehler E, Brown E, Haneuse SJPA. 2009. *On the Assessment of Monte Carlo Error in Simulation-Based Statistical Analyses*. Am Stat 63(2):155–162. | doi:10.1198/tast.2009.0030; PMC3337209 | Estudio de simulación metodológico | Q4: el error Monte Carlo de percentiles debe evaluarse y reportarse; fórmulas de MCSE | Estudio de simulación; sin cifras transferibles directas | Alta | Leído a texto completo (PMC). |
| Law AM. 2015. *Simulation Modeling and Analysis*. 5.ª ed. McGraw-Hill. | ISBN 978-0-07-340132-4 (libro) | Texto canónico de simulación | Q4, Q6, D-d, D-f: §11.2 Common Random Numbers (racionalidad, aplicabilidad, sincronización); §4.7 «The Danger of Replacing a Probability Distribution by Its Mean» [TEXTO-título] | Sin números transferibles | Alta | **Leído parcialmente** (secciones citadas verificadas por su índice y contenido). |
| Castillo-Carniglia A, Kaufman JS, Pino P. 2013. *Alcohol-attributable mortality and years of potential life lost in Chile in 2009*. Alcohol Alcohol 48(6):729–736. | doi:10.1093/alcalc/agt066; PMID:23831731 | Estudio AAF Chile; mortalidad 2009 | Precedente chileno AAF con IC (método tipo CRA/Rehm) | 8 750 muertes atribuibles; 9,8 % (IC 95 % 7,0–13,0) de las muertes de 2009 en Chile (estimado; vía resumen e intro de Ruiz-Tagle 2026) | Alta (Chile) | **Solo resumen** leído; detalle de propagación de incertidumbre no verificado. |
| Ruiz-Tagle Maturana J, Román Mella F, Castillo-Carniglia Á. 2026. *Sex and age differences in alcohol-attributable mortality in Chile between 2008 and 2022*. Public Health in Practice 11:100798. | doi:10.1016/j.puhip.2026.100798; PMC13195772 | Análisis secundario de encuestas nacionales de drogas repetidas + mortalidad oficial CIE-10, Chile, ≥15 años (encuestas 15–64; 65+ extrapolado), 2008–2022 | Precedente chileno directo: AAF con funciones RR de meta-análisis + Monte Carlo [TEXTO: «Uncertainty estimates were generated via Monte Carlo simulations»]; limitaciones: encuestas 15–64, AAF 65+ asumida igual al grupo mayor; corrección per cápita sin desagregar; causa única de muerte; «relative risk functions derived from non-local populations represents an additional limitation» [TEXTO] | 14,6 % (IC 95 % 10,9–18,4) de las muertes atribuible en 2008 → 9,6 % (7,2–12,2) en 2022 (estimado); tasa estandarizada mínima 62/100 000 en 2012, 65,4/100 000 en 2022 (estimado) | **Alta** en fuentes (misma familia ENPG/DEIS), **no independiente**: financiado por FONDECYT 1240138 | Leído a texto completo (PMC). **Existe corregendum** (doi:10.1016/j.puhip.2026.100812) **no leído** (§8 #7). |
| OMS. 2024. *Global status report on alcohol and health and treatment of substance use disorders*. Ginebra: OMS. | URL: who.int/publications/i/item/9789240096745; iris.who.int/bitstream/handle/10665/377960/9789240096745-eng.pdf | Informe mundial; datos 2019 | Contexto y fuente de las funciones RR del estudio (según el encargo); definiciones OMS | 2,6 millones de muertes atribuibles al alcohol (4,7 % de todas las muertes), global, 2019 (estimado; cifra de portada) | Media (contexto) | **Solo metadatos/overview leídos**: las funciones RR concretas y su documentación interna NO fueron verificadas (§8 #5). |

## 4. Evidencia chilena y latinoamericana (separada de la metodológica internacional)

**(a) Chile — estudios AAF con intervalos.**
- **Castillo-Carniglia, Kaufman & Pino 2013** ([doi:10.1093/alcalc/agt066](https://doi.org/10.1093/alcalc/agt066), **solo resumen**): mortalidad atribuible al alcohol en Chile 2009; 8 750 muertes, 9,8 % (IC 95 % 7,0–13,0) de las muertes de ese año (estimado; cifras verificadas también en la introducción de Ruiz-Tagle Maturana 2026 [TEXTO-indirecto]). Población: Chile, mortalidad 2009; denominador: total de muertes del año. No se verificó el detalle de su propagación de incertidumbre.
- **Ruiz-Tagle Maturana, Román Mella & Castillo-Carniglia 2026** ([doi:10.1016/j.puhip.2026.100798](https://doi.org/10.1016/j.puhip.2026.100798), texto completo): AAF por sexo, edad y causa, Chile 2008–2022, con encuestas nacionales de drogas repetidas (familia ENPG), mortalidad oficial CIE-10 y «uncertainty estimates … via Monte Carlo simulations» [TEXTO]. Resultados: 14,6 % (10,9–18,4) de las muertes atribuible en 2008; 9,6 % (7,2–12,2) en 2022; tasas estandarizadas mínimas en 2012 (62/100 000) y 65,4/100 000 en 2022 (estimados). Limitaciones declaradas [TEXTO]: encuestas limitadas a 15–64 años con AAF de 65+ **asumida** igual al grupo mayor disponible; corrección per cápita sin desagregación por subpoblación; causa única de muerte; funciones RR «derived from non-local populations». **Advertencia de independencia**: el estudio declara financiamiento «FONDECYT Regular N° 1240138» [TEXTO] — es decir, es un producto del **mismo proyecto** que este encargo; sirve como precedente de diseño y transportabilidad de fuentes, **no** como validación externa. Además existe un **corregendum publicado** (doi:10.1016/j.puhip.2026.100812) que no fue leído: verificar si modifica las cifras citadas antes de reutilizarlas (§8 #7).
- **Estudio de Carga de Enfermedad y Carga Atribuible, MINSAL 2008** (citado en la introducción de Ruiz-Tagle Maturana 2026 [TEXTO-indirecto]): 8 366 muertes atribuibles al alcohol en 2004, 9,7 % del total (estimado). Fuente primaria no leída; se menciona solo como antecedente histórico.

**(b) Chile — efectos de diseño de la ENPG/SENDA.**
**NO ENCONTRADO.** No se localizó ninguna publicación o documento técnico con deff/deft/ρ intraclase de la Encuesta Nacional de Drogas en la Población General, ni el manual público de diseño muestral por ola (estratos, UPM, marcos). Búsqueda ejecutada: «SENDA "Encuesta Nacional de Drogas en la Población General" efecto de diseño OR "design effect" OR deff muestreo estratificado conglomerados» — sin resultados específicos (solo material genérico de muestreo por conglomerados de otros países). [INFERENCIA] Mientras SENDA no publique el diseño, los factores por celda del pipeline (deff combinado; n_eff Kish = 21,6–47,4 % del n nominal; factor residual de conglomerado 1,21–1,64; datos del encargo) son la única evidencia empírica disponible y deben documentarse como estimaciones propias.

**(c) América Latina — efectos de diseño en encuestas de alcohol/drogas.**
**NO ENCONTRADO** en la búsqueda realizada (combinada con la de ENPG; no exhaustiva). No se localizaron reportes de deff para encuestas nacionales de consumo de alcohol de la región comparables a la ENPG. [INFERENCIA] La práctica regional de reportar solo errores estándar sin deff por variable impide la transferencia: la transferencia interna entre olas ENPG del mismo marco (Kish 1995 §4d) sigue siendo la vía menos arriesgada.

**(d) Convenciones de modelos (para claridad de la separación (d)).**
Las convenciones de agregación a nivel de draw, percentiles 2,5/97,5 y draws de curva RR completa provienen de la maquinaria GBD/OMS ([GBD 2016](https://doi.org/10.1016/S0140-6736(18)31310-2); [GBD 2019 RF](https://doi.org/10.1016/S0140-6736(20)30752-2); [GBD 2020](https://doi.org/10.1016/S0140-6736(22)00847-9)) y del canon InterMAHP ([Sherk 2017](https://www.drugsandalcohol.ie/28421/)): son **convenciones de modelado**, no evidencia empírica sobre Chile, y su uso debe declararse como tal.

## 5. Recomendación por decisión

**D-a [C1] — factor combinado Kish × conglomerado.** *Opción recomendada:* mantener el n_eff combinado como método primario pragmático y añadir validación por linealización de Taylor (o réplicas) en las olas con PSU disponibles. *Fuerza:* **media**. *Qué la cambiaría:* obtención de las variables de diseño completas o de pesos réplica oficiales de SENDA para todas las olas → migrar a estimación directa por réplicas (Rust & Rao 1996) y abandonar el factor combinado. *Limitación a declarar:* «Los factores de diseño se estimaron por celda a partir de estratos y conglomerados aproximados y se aplicaron vía tamaño efectivo en draws Dirichlet/Beta/gamma; no constituyen estimación directa de la varianza de diseño del AAF.»

**D-b [Q13] — factores < 1.** *Opción recomendada:* sin piso (conservar deff < 1) en la especificación primaria; análisis de sensibilidad con piso = 1 (dirección conservadora: ensancha intervalos). *Fuerza:* **alta**. *Qué la cambiaría:* evidencia de que los deff < 1 provienen de inestabilidad por pocas UPM por estrato y no de ganancias reales de estratificación → entonces colapsar estratos o suavizar con GVF (Wolter 2007 cap. 7) en lugar de truncar. *Limitación a declarar:* «Factores < 1 reflejan ganancias de estratificación asumidas; su magnitud es incierta en celdas con pocas UPM.»

**D-c [C2] — ola 2020 sin conglomerados.** *Opción recomendada:* tomar el factor de 2018 (mismo marco) como donante primario; pseudo-conglomerados gruesos como cota superior de sensibilidad; **abandonar** la práctica actual de tomar 2022 (marco distinto) y la opción MAS/«optimista». *Fuerza:* **media-alta**. *Qué la cambiaría:* que SENDA entregue los identificadores o el manual de diseño 2020 (si la ola 2020 cambió de marco — p. ej., por la pandemia — la transferencia desde 2018 se debilita y conviene GVF sobre todas las olas). *Limitación a declarar:* «La ola 2020 carece de identificadores de conglomerado; su factor se transfirió de 2018 (mismo marco), con riesgo de no transferibilidad (Kish 1995 §4d); los intervalos de 2020 son los menos firmes de la serie.»

**D-d [Q15/B13] — intervalos de agregados.** *Opción recomendada:* agregación a nivel de draw con alineación comonotónica de los parámetros compartidos (curvas RR, κ gamma) e independencia entre draws de prevalencia celda-específicos; sensibilidad con independencia total como cota inferior de ancho; **eliminar** las envolventes de límites. *Fuerza:* **media-alta**. *Qué la cambiaría:* disponibilidad de draws conjuntos oficiales (OMS/GBD) por causa, con correlación real entre celdas → reemplazar la comonotonía asumida. *Limitación a declarar:* «La correlación entre celdas inducida por draws compartidos es perfecta en el componente RR (cota superior de correlación); los intervalos agregados son conservadores.»

**D-e [B5] — covarianza RR no publicada (IHD, fuente alternativa).** *Opción recomendada:* (i) solicitar la covarianza o las ecuaciones a los autores/OMS — práctica documentada por InterMAHP; (ii) mientras tanto, usar draws de curva completa de GBD 2020 o reconstrucción tipo Greenland–Longnecker/delta; **abandonar** la matriz diagonal y el reporte solo puntual; no truncar. *Fuerza:* **alta**. *Qué la cambiaría:* respuesta de los autores con la covarianza oficial → adoptarla. *Limitación a declarar:* «Para IHD en mujeres la covarianza de coeficientes no es pública; los intervalos provienen de [fuente alternativa adoptada] y son aproximados; Roerecke & Rehm advierten precisión sobreestimada a bajas dosis.»

**D-f [B12] — punto fuera del IC Monte Carlo.** *Opción recomendada:* estimador central = media (o mediana) de los draws con IC percentil 2,5/97,5; eliminar el forzado lower ≤ puntual ≤ upper; el valor determinista plug-in puede mostrarse etiquetado como tal. *Fuerza:* **alta**. *Qué la cambiaría:* demostración de linealidad local del estimador en el rango de los parámetros (improbable en AAF/PIF) → entonces el plug-in sería válido. *Limitación a declarar:* «El estimador central es la media Monte Carlo; el valor plug-in difiere por no linealidad (desigualdad de Jensen) y se reporta solo con fines comparativos.»

**D-g [C1] — clave de conglomerados y estratos.** *Opción recomendada:* usar la clave reconstruida comuna+distrito+zona (≈2 358 UPM en 2016) si reproduce las etapas reales de selección documentadas; manzana sola (≈2 000) como sensibilidad conservadora; estratos según el diseño documentado, colapsando los que tengan 1 UPM; nunca mezclar variables de diseño entre marcos. *Fuerza:* **media**. *Qué la cambiaría:* el manual de diseño ENPG 2016/2018/2020/2022 (solicitarlo a SENDA): si la UPM real fue la manzana sin subselección, manzana sola pasa a ser la especificación primaria. *Limitación a declarar:* «Las variables de diseño son reconstrucciones aproximadas; en algunas regiones el número efectivo de UPM por estrato es pequeño, lo que inestabiliza los deff por celda (Kish 1995 §6).»

## 6. Párrafos de métodos (English; máx. 2 por decisión; 100–150 palabras)

**D-a, opción 1 — design-effect-adjusted effective sample size (especificación primaria).**
Monte Carlo uncertainty in drinking-status prevalences was propagated by drawing category counts from a Dirichlet distribution with concentration parameters equal to the weighted cell proportions multiplied by a design-effect-adjusted effective sample size, n_eff = n/deff (Kish 1965). The design effect was estimated separately for each year × sex × age cell and variable as the squared ratio of the complex-survey standard error, obtained by Taylor linearization over approximate strata and primary sampling units, to the Kish simple-random-sampling standard error, combining weighting, stratification and clustering effects into a single multiplicative factor (Kish 1995; Chen and Rust 2017). Design effects below 1 arising from stratification gains were retained without truncation (Kish 1965; Kish 1995). The same n_eff scaled the Beta draws of binge-drinking prevalence and the gamma consumption parameters. This approach extends the binomial-variance propagation of Gmel et al. (2011) by replacing their assumed effective sample size of 1000 with survey-specific, empirically estimated design effects.

**D-a, opción 2 — linearización/réplicas como validación y donante entre olas.**
For waves in which primary sampling unit and stratum identifiers were available, variances of all prevalence and consumption statistics were estimated by Taylor series linearization, and the resulting cell-level design effects were used as above; balanced repeated replication and bootstrap replicate weights are interchangeable alternatives for the same purpose (Rust and Rao 1996; Wolter 2007). Where cluster identifiers were absent (2020 wave), the cell-level design factor was imported from the most recent wave sharing the same sampling frame (2018), because design effects are transferable within a frame but degrade with design distance (Kish 1995). As an upper-bound sensitivity analysis, respondents were aggregated into coarse pseudo-clusters, an analogue of the collapsed-stratum estimator that tends to overstate variance (Wolter 2007). Design variables were never mixed across sampling frames (Valliant, PracTools vignette).

**D-d, opción 1 — agregación a nivel de draw con alineación (especificación primaria).**
Aggregate outcomes (all-cause alcohol-attributable deaths; population impact fractions pooled over causes) were computed at the draw level. In every Monte Carlo iteration, a single draw of each shared parameter — the cause-sex-specific relative risk curve and the gamma shape parameter — was applied simultaneously to all year × age × sex cells, because the same relative risk functions are used for all regions and age groups (Gmel et al. 2011); cell-specific prevalence draws remained independent across cells. The 2.5th and 97.5th percentiles of the resulting distribution of the aggregate defined its uncertainty interval, following draw-level propagation practice in the Global Burden of Disease study (GBD 2016 Alcohol Collaborators 2018; GBD 2019 Risk Factors Collaborators 2020) and the common-random-numbers principle (Law 2015). Comonotonic alignment of shared parameters yields wider, conservative aggregate intervals relative to full independence.

**D-d, opción 2 — sensibilidad de independencia y control del error Monte Carlo.**
As a lower-bound sensitivity analysis, all parameters, including the relative risk curve draws, were resampled independently across cells within each iteration; the resulting aggregate distribution has minimal width because component errors cancel. The envelope construction — summing cell-level interval limits — was not used: a sum of quantiles is not the quantile of a sum, so envelope limits carry no probabilistic interpretation and no defensible coverage level. Monte Carlo error of all reported percentiles was quantified following Koehler et al. (2009), and the number of iterations was set so that percentile Monte Carlo standard errors were negligible relative to interval widths; Gmel et al. (2011) used 150 000 draws to stabilize 95% intervals. All specifications, seeds and alignment rules were documented to allow independent reproduction (Eddy et al. 2012).

## 7. BibTeX de las referencias citadas en las secciones 3 y 6

```bibtex
@article{gmel2011,
  author  = {Gmel, Gerrit and Shield, Kevin D. and Frick, Hanna and Kehoe, Tara and Gmel, Gerhard and Rehm, J{\"u}rgen},
  title   = {Estimating uncertainty of alcohol-attributable fractions for infectious and chronic diseases},
  journal = {BMC Medical Research Methodology},
  year    = {2011},
  volume  = {11},
  pages   = {48},
  doi     = {10.1186/1471-2288-11-48}
}

@article{briggs2012,
  author  = {Briggs, Andrew H. and Weinstein, Milton C. and Fenwick, Elisabeth A. L. and Karnon, Jonathan and Sculpher, Mark J. and Paltiel, A. David},
  title   = {Model Parameter Estimation and Uncertainty Analysis: A Report of the {ISPOR-SMDM} Modeling Good Research Practices Task Force Working Group--6},
  journal = {Value in Health},
  year    = {2012},
  volume  = {15},
  number  = {6},
  pages   = {835--842},
  doi     = {10.1016/j.jval.2012.04.014},
  note    = {Versi{\'o}n le{\'i}da a texto completo: Medical Decision Making 32(6):722--732, doi:10.1177/0272989X12458348}
}

@article{eddy2012,
  author  = {Eddy, David M. and others},
  title   = {Model Transparency and Validation: A Report of the {ISPOR-SMDM} Modeling Good Research Practices Task Force--7},
  journal = {Value in Health},
  year    = {2012},
  volume  = {15},
  number  = {6},
  pages   = {843--850},
  doi     = {10.1016/j.jval.2012.04.012},
  note    = {Solo resumen le{\'i}do}
}

@book{kish1965,
  author    = {Kish, Leslie},
  title     = {Survey Sampling},
  publisher = {Wiley},
  address   = {New York},
  year      = {1965},
  note      = {Citado a trav{\'e}s de Valliant (vignette PracTools) y otras fuentes secundarias; no le{\'i}do directamente}
}

@article{kish1995,
  author  = {Kish, Leslie},
  title   = {Methods for Design Effects},
  journal = {Journal of Official Statistics},
  year    = {1995},
  volume  = {11},
  number  = {1},
  pages   = {55--77},
  url     = {https://www.scb.se/contentassets/ca21efb41fee47d293bbee5bf7be7fb3/methods-for-design-effects.pdf}
}

@article{chen2017,
  author  = {Chen, Sixia and Rust, Keith F.},
  title   = {An Extension of {Kish's} Formula for Design Effects to Two- and Three-Way Designs with Stratification},
  journal = {Journal of Survey Statistics and Methodology},
  year    = {2017},
  volume  = {5},
  number  = {2},
  pages   = {111--130},
  doi     = {10.1093/jssam/smw036}
}

@article{rust1996,
  author  = {Rust, Keith F. and Rao, J. N. K.},
  title   = {Variance estimation for complex surveys using replication techniques},
  journal = {Statistical Methods in Medical Research},
  year    = {1996},
  volume  = {5},
  number  = {3},
  pages   = {283--310},
  doi     = {10.1177/096228029600500305},
  note    = {Solo resumen le{\'i}do}
}

@book{wolter2007,
  author    = {Wolter, Kirk M.},
  title     = {Introduction to Variance Estimation},
  edition   = {2},
  publisher = {Springer},
  address   = {New York},
  year      = {2007},
  note      = {Le{\'i}do parcialmente (cap{\'i}tulos citados)}
}

@misc{valliantpractools,
  author       = {Valliant, Richard},
  title        = {Design Effects (vignette del paquete {PracTools} de {R})},
  howpublished = {\url{https://cran.r-project.org/web/packages/PracTools/vignettes/Design-effects.html}},
  note         = {Consultado 2026-10-07; reproduce citas de Cochran 1977, Kish 1965 y Valliant, Dever \& Kreuter 2018}
}

@article{gbd2016alcohol,
  author  = {{GBD 2016 Alcohol Collaborators}},
  title   = {Alcohol use and burden for 195 countries and territories, 1990--2016: a systematic analysis for the Global Burden of Disease Study 2016},
  journal = {The Lancet},
  year    = {2018},
  volume  = {392},
  number  = {10152},
  pages   = {1015--1035},
  doi     = {10.1016/S0140-6736(18)31310-2}
}

@article{gbd2019rf,
  author  = {{GBD 2019 Risk Factors Collaborators}},
  title   = {Global burden of 87 risk factors in 204 countries and territories, 1990--2019: a systematic analysis for the Global Burden of Disease Study 2019},
  journal = {The Lancet},
  year    = {2020},
  volume  = {396},
  number  = {10258},
  pages   = {1223--1249},
  doi     = {10.1016/S0140-6736(20)30752-2}
}

@article{gbd2020alcohol,
  author  = {{GBD 2020 Alcohol Collaborators}},
  title   = {Population-level risks of alcohol consumption by amount, geography, age, sex, and year: a systematic analysis for the Global Burden of Disease Study 2020},
  journal = {The Lancet},
  year    = {2022},
  volume  = {400},
  number  = {10347},
  pages   = {185--235},
  doi     = {10.1016/S0140-6736(22)00847-9}
}

@techreport{sherk2017,
  author      = {Sherk, Adam and Stockwell, Tim and Rehm, J{\"u}rgen and Dorocicz, John and Shield, Kevin D.},
  title       = {InterMAHP: The International Model of Alcohol Harms and Policies: A comprehensive guide to the estimation of alcohol-attributable morbidity and mortality},
  institution = {Canadian Institute for Substance Use Research, University of Victoria},
  address     = {Victoria, BC},
  year        = {2017},
  url         = {https://www.drugsandalcohol.ie/28421/},
  note        = {Version 1.0, diciembre 2017, 105 p.}
}

@article{roerecke2012,
  author  = {Roerecke, Michael and Rehm, J{\"u}rgen},
  title   = {The cardioprotective association of average alcohol consumption and ischaemic heart disease: a systematic review and meta-analysis},
  journal = {Addiction},
  year    = {2012},
  volume  = {107},
  number  = {7},
  pages   = {1246--1260},
  doi     = {10.1111/j.1360-0443.2012.03780.x}
}

@article{greenland1992,
  author  = {Greenland, Sander and Longnecker, Matthew P.},
  title   = {Methods for trend estimation from summarized dose-response data, with applications to meta-analysis},
  journal = {American Journal of Epidemiology},
  year    = {1992},
  volume  = {135},
  number  = {11},
  pages   = {1301--1309},
  doi     = {10.1093/oxfordjournals.aje.a116237},
  note    = {Solo resumen le{\'i}do}
}

@article{koehler2009,
  author  = {Koehler, Elizabeth and Brown, Elizabeth and Haneuse, S{\'e}bastien J.-P. A.},
  title   = {On the Assessment of Monte Carlo Error in Simulation-Based Statistical Analyses},
  journal = {The American Statistician},
  year    = {2009},
  volume  = {63},
  number  = {2},
  pages   = {155--162},
  doi     = {10.1198/tast.2009.0030}
}

@book{law2015,
  author    = {Law, Averill M.},
  title     = {Simulation Modeling and Analysis},
  edition   = {5},
  publisher = {McGraw-Hill},
  address   = {New York},
  year      = {2015},
  note      = {ISBN 978-0-07-340132-4; secciones citadas: 4.7 y 11.2; le{\'i}do parcialmente}
}

@article{castillo2013,
  author  = {Castillo-Carniglia, {\'A}lvaro and Kaufman, Jay S. and Pino, Paulina},
  title   = {Alcohol-attributable mortality and years of potential life lost in Chile in 2009},
  journal = {Alcohol and Alcoholism},
  year    = {2013},
  volume  = {48},
  number  = {6},
  pages   = {729--736},
  doi     = {10.1093/alcalc/agt066},
  note    = {Solo resumen le{\'i}do}
}

@article{ruiztagle2026,
  author  = {Ruiz-Tagle Maturana, Jos{\'e} and Rom{\'a}n Mella, Francisca and Castillo-Carniglia, {\'A}lvaro},
  title   = {Sex and age differences in alcohol-attributable mortality in Chile between 2008 and 2022},
  journal = {Public Health in Practice},
  year    = {2026},
  volume  = {11},
  pages   = {100798},
  doi     = {10.1016/j.puhip.2026.100798},
  note    = {Financiado por FONDECYT Regular 1240138; existe corregendum (doi:10.1016/j.puhip.2026.100812) no le{\'i}do}
}

@techreport{who2024,
  author      = {{World Health Organization}},
  title       = {Global status report on alcohol and health and treatment of substance use disorders},
  institution = {World Health Organization},
  address     = {Geneva},
  year        = {2024},
  url         = {https://www.who.int/publications/i/item/9789240096745},
  note        = {Solo metadatos/overview le{\'i}dos; PDF en iris.who.int (handle 10665/377960)}
}
```

## 8. NO ENCONTRADO / NO VERIFICADO y discrepancias

**NO ENCONTRADO (con búsquedas documentadas):**
1. **Efectos de diseño (deff/deft/ρ) publicados de la ENPG-SENDA.** Búsqueda: «SENDA "Encuesta Nacional de Drogas en la Población General" efecto de diseño OR "design effect" OR deff muestreo estratificado conglomerados» → 0 resultados específicos (solo material genérico de muestreo de otros países). Consecuencia: los factores del pipeline son la única evidencia empírica disponible.
2. **Efectos de diseño de encuestas nacionales de alcohol/drogas en América Latina** (ENSANUT-México, PNS-Brasil y similares). Búsqueda combinada con la anterior (no exhaustiva) → nada específico localizado. Queda como deuda de búsqueda ampliada.
3. **Manual/documentación pública del diseño muestral ENPG por ola** (estratos, UPM, marcos 2012–2024) → no localizado; solicitar directamente a SENDA (condiciona D-g y D-c).
4. **Covarianza publicada de los coeficientes de la fuente alternativa de RR-IHD** (ln RR = b1·x + b2·x·ln x): no publicada. Roerecke & Rehm 2012 publican SE marginales y la forma funcional (Tabla 3); InterMAHP documenta que estas ecuaciones «a menudo no se publican» y que se obtuvieron de los autores.
5. **Método AAF publicado que propague prevalencias con n_eff derivado de deff empírico de encuesta compleja** → no encontrado. Gmel 2011 asume n = 1000; GBD propaga draws de exposición; InterMAHP v1 no produce incertidumbre. La práctica metodológica interna de OMS 2024 para sus IC tampoco fue localizada (informe leído solo a nivel de metadatos). Consecuencia: el enfoque D-a es una extensión razonada, no una réplica de un precedente.

**NO VERIFICADO:**
6. **Kilian et al. 2025 (SIMAH), Lancet Public Health, doi:10.1016/S2468-2667(25)00165-3** — aportado por el encargo como contexto de la siguiente etapa; quedó fuera del alcance de verificación acordado y no se usa en ningún veredicto.
7. **Corregendum de Ruiz-Tagle Maturana 2026** (*Public Health in Practice* 12:100812, doi:10.1016/j.puhip.2026.100812) — localizado, **no leído**. Antes de reutilizar las cifras de ese estudio (§4) verificar si el corregendum las modifica.
8. **Kish 1965** — no leído directamente; todas sus citas provienen de fuentes secundarias verificadas (vignette PracTools; Schnell 2005 vía resultados de búsqueda). Si el informe se usa para publicación, contrastar pp. 76 y 162–163 con el original.

**Discrepancias DOI/datos (resueltas):**
9. **GBD 2020 Alcohol:** en un borrador interno previo figuraban páginas erróneas; verificado: *Lancet* 2022;400(10347):185–235, doi:10.1016/S0140-6736(22)00847-9, PMID:35843246.
10. **Candidatos del encargo:** Gmel (doi:10.1186/1471-2288-11-48), TF-6 (*Value in Health* 15(6):835–842, doi:10.1016/j.jval.2012.04.014) y TF-7 (*Value in Health* 15(6):843–850, doi:10.1016/j.jval.2012.04.012) **coinciden** con lo verificado; TF-6 se leyó en su versión paralela de *Medical Decision Making* (32(6):722–732, doi:10.1177/0272989X12458348). «Kish canonical reference» identificada como **Kish L. 1965. *Survey Sampling*. Wiley** (deff y n_eff), complementada con Kish 1995 para transferencia y casos especiales.
11. **OMS 2024 GSRAHTSUD:** URL estables confirmadas (who.int/publications/i/item/9789240096745; iris.who.int handle 10665/377960). Las funciones RR concretas que el estudio extrae del informe **no** fueron objeto de verificación (el encargo las da por sentadas).

---

*Nota final:* este informe es orientación metodológica para el diseño del análisis de incertidumbre del estudio FONDECYT 1240138; no constituye asesoramiento clínico ni de política sanitaria. Las opciones marcadas [INFERENCIA] son deducciones del analista a partir de las fuentes citadas y deben tratarse con el nivel de confianza correspondiente.
