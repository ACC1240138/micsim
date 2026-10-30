KIMI-P5 | 2026-10-07 | 11 referencias leídas a texto completo / 9 solo resumen o página oficial

# PIF y muertes evitables por alcohol en escenarios de política: evidencia metodológica para FONDECYT 1240138

**Alcance.** Este informe responde a las decisiones D-a–D-e y a las preguntas Q1–Q7 sobre métodos para calcular fracciones de impacto potencial (PIF) y muertes evitables por alcohol en escenarios de política, con trazabilidad verificable (DOI/PMID/URL). No evalúa la implementación actual del estudio (resumida en el anexo "IMPLEMENTACIÓN ACTUAL" del encargo), solo la evidencia publicada que la sustenta o la contradice.

---

## 1. Veredicto por opción (D-a a D-e)

| Decisión | Opción | Apoyo | Referencias clave | Por qué |
|---|---|---|---|---|
| D-a (causas 100% en el PIF) | **A. Declarar el PIF "parcial, solo causas con RR"** | **Fuerte** | Sherk et al. 2017 (Guía InterMAHP §1.5); GBD 2016 (PMID 30146330); Shield et al. 2025 (doi:10.1016/S2468-2667(25)00174-4) | Es la convención de los dos marcos de CRA dominantes: InterMAHP fija AAF = 1 por definición y no les aplica contrafactual de exposición; GBD asume PAF = 1 para trastornos por uso de alcohol; el CRA de OMS 2024 reporta las muertes por AUD sin intervalo de incertidumbre (entran como AAF = 1). La identidad PIF = (AAF − AAF_cf)/(1 − AAF_cf) no es computable si AAF = AAF_cf = 1. |
| D-a | **B. Submodelo con escalamiento por cambio en volumen per cápita / prevalencia HED** | **Moderado** | Holmes et al. 2026 (doi:10.1371/journal.pmed.1004792); Probst et al. 2023 (doi:10.1093/aje/kwad018); Wyper et al. 2023 (PMID 36963415) | Existe precedente publicado de modelar contrafactually las causas 100%: STAPM ajusta "absolute risk functions" para causas totalmente atribuibles agudas y crónicas y reporta sus muertes bajo política (2.578 muertes 100% atribuibles menos en 20 años con MUP £0,65); SIMAH modela AUD con RR continua exp(β·g/día). Wyper 2023 muestra empíricamente que estas muertes sí responden a política (−13,4%). El escalamiento por consumo per cápita es una simplificación pragmática sin validación directa publicada: de ahí "moderado" y no "fuerte". |
| D-a | **C. Otro método publicado** | **Ninguno encontrado** | — | NO ENCONTRADO: más allá de las convenciones A/B (InterMAHP/GBD) y las funciones de riesgo absoluto (SAPM/STAPM) o RR continuas por causa (SIMAH), no se halló un tercer método publicado con revisión por pares para el contrafactual de causas 100% atribuibles. |
| D-b (λ de salida de HED) | **λ = 0 como principal** | **Moderado** | Barendregt y Veerman 2010 (doi:10.1136/jech.2009.090274); Sherk et al. 2017 | Conservador: solo mueve el término HED del PIF sin alterar el volumen. Coherente con la estructura InterMAHP, donde volumen y HED son dimensiones separadas del riesgo. No implica un cambio de consumo no observado. |
| D-b | **λ = 1 (redistribuir a la distribución de volumen de no-HED)** | **Débil** | Ninguna fuente publicada | NO ENCONTRADO origen publicado de esta redistribución ("usado por Ruiz-Tagle et al." no se verificó; ver §8). Además implica un cambio de consumo medio de −26,5% con −50% de prevalencia HED (supuesto conductual fuerte, ASUMIDO, no estimado), que debe declararse. |
| D-b | **Reportar ambos λ con el cambio de consumo implícito** | **Fuerte (como práctica de reporte)** | Holmes et al. 2026 (cuatro análisis de sensibilidad reportados); Ruiz-Tagle et al. 2026 (10.000 draws Monte Carlo para incertidumbre) | La práctica publicada en modelos de política alcohólica es reportar análisis de sensibilidad explícitos ante supuestos no identificados; transparentar el consumo implícito convierte el supuesto en auditable. |
| D-c (quitters inducidos por política) | **Moverlos a exbebedores con RR_fd (mover el término exbebedor)** | **Moderado** | Código SIMAH v0.1.1 (`update_former_drinker.R`, `AUD.R`, `IHD.R`, doi:10.5281/zenodo.15641639); Stockwell et al. 2016 (doi:10.15288/jsad.2016.77.185) | SIMAH envía a los quitters a abstención y les asigna estocásticamente condición de exbebedor (probabilidad edad×sexo), con RR de exbebedor en AUD e IHD; Stockwell 2016 estima exceso de riesgo de exbebedores (RR 1,22; 1,38 ajustado). Capta el riesgo residual → estimación más conservadora del beneficio. |
| D-c | **Mantener el término exbebedor fijo** | **Moderado (alternativa conservadora-extrema)** | Sherk et al. 2017 (§3.2.5) | La guía InterMAHP mantiene el RR categórico de exbebedor en el AAF; en PIF de escenarios que no cambian la composición abstemio/exbebedor/bebedor, fijar el término es la práctica por defecto. Con escenarios que sí inducen abandono, fijarlo equivale a asumir que los quitters adquieren riesgo de abstemio inmediatamente. |
| D-d (estado estacionario vs rezagos) | **Estado estacionario como análisis principal** | **Fuerte** | Sherk et al. 2017; Shield et al. 2025; GBD 2016 | Los marcos CRA (InterMAHP, GBD, OMS) no aplican rezagos: el AAF/PIF es una fracción de la carga bajo exposición sostenida. Es coherente con el AAF ya reportado por el equipo y con el horizonte "cuanto antes" de un PIF estático. |
| D-d | **Rezagos por causa como análisis de sensibilidad** | **Fuerte si se reporta dinámica temporal** | Holmes et al. 2012, Tabla 2 (doi:10.1016/j.drugalcdep.2011.12.005); Holmes et al. 2026 | SAPM/STAPM aplican rezagos específicos por causa (p. ej., cánceres: sin efecto antes del año 10, efecto pleno al año 20) y muestran que el perfil anual de muertes evitadas alcanza meseta hacia el año 5–10. SIMAH, en cambio, usa consumo del año en curso (riesgo concurrente, verificado en `simulate_mortality.R`): la práctica publicada es mixta. |
| D-e (PIF negativos) | **Mantener signo, reportar causas específicas + totales netos + sensibilidad sin efectos protectores** | **Fuerte** | Holmes et al. 2026 (aumentos de ECV reportados como compensaciones dentro del neto; SA que remueve efectos protectores); Shield et al. 2025 (PAF negativos publicados con signo: diabetes −0,1%, ACV isquémico −0,7% de las muertes) | Es la práctica publicada tanto en el modelo de política más reciente como en el CRA de OMS. Permite auditoría y evita ocultar compensaciones. |
| D-e | Truncar a cero / excluir causas con curva J | **Contrario a la práctica publicada** | Shield et al. 2025; Holmes et al. 2026 | Ninguna de las dos fuentes trunca ni excluye: reportan con signo y usan análisis de sensibilidad para cuantificar la contribución de los efectos protectores. |

## 1b. Tabla de parámetros y decisiones

| ID | Parámetro/decisión | Valor/opción | Fuente (DOI + página/tabla/sección) | Estimado/Asumido | Transportabilidad a Chile |
|---|---|---|---|---|---|
| P1 | Fórmula PIF para causas parciales con término exbebedor | InterMAHP Fórmulas 3.1–3.5 (volumen gamma + HED + exbebedor categórico) | Sherk et al. 2017, §3.2, Fórmulas 3.1–3.5 (uvic.ca, URL verificada) | Asumido (convención) | **Alta**: es la fórmula ya usada en Chile por Ruiz-Tagle et al. 2026 (Ec. 1) |
| P2 | Causas 100% atribuibles | AAF = 1 por definición; entran a muertes atribuibles, no al PIF | Sherk et al. 2017, §1.5; GBD 2016 (PMID 30146330), Methods | Asumido (convención) | **Alta**: convención internacional, sin componente local |
| P3 | Submodelo para causas 100% (opción B) | Funciones de riesgo absoluto (STAPM) o RR continua exp(β·g/día) (SIMAH AUD); escalamiento por consumo per cápita = simplificación sin validación directa | Holmes et al. 2026, Methods ("Consumption to harm"); código SIMAH `AUD.R` (topes 122,51 g/día hombres, 114,12 g/día mujeres) | Estimado (UK/EE.UU.) para las funciones; Asumido para el escalamiento | **Media**: las funciones absolutas requieren tasas basales chilenas por nivel de consumo (no disponibles en el encargo); la RR continua de AUD es transportable con recalibración |
| P4 | λ = 0 (salida de HED sin cambio de volumen) | Principal | Sin fuente directa; coherente con separación volumen/HED de InterMAHP (Sherk et al. 2017, §3.2) | Asumido | No aplica (convención interna) |
| P5 | λ = 1 (redistribución de volumen) | Solo sensibilidad; implica −26,5% de consumo medio con −50% HED | NO ENCONTRADO (ver §8) | Asumido | No aplica |
| P6 | Quitters → exbebedores con RR_fd | Probabilidad edad×sexo de ser exbebedor entre no bebedores (SIMAH) | Código SIMAH v0.1.1 `update_former_drinker.R` (doi:10.5281/zenodo.15641639) | Asumido (regla de modelo) | **Alta** como regla; requiere prevalencias chilenas de exbebedor por edad×sexo (ENPG) |
| P7 | Exceso de riesgo de exbebedores | RR 1,22 (IC95% 1,14–1,31); 1,38 (1,24–1,54) totalmente ajustado vs abstemios de por vida (mortalidad) | Stockwell et al. 2016 (doi:10.15288/jsad.2016.77.185), abstract (solo resumen) | Estimado (meta-análisis, 87 estudios) | **Media**: estudios mayoritariamente de Norteamérica/Europa; sin RR_fd por causa para Chile |
| P8 | Estructura de rezagos | Tabla 2 de Holmes et al. 2012: p. ej., G31.2/G62.1/G72.1/I42.6 primer efecto inmediato → pleno a 20 años (lineal); K70: primer efecto año 1 → pleno 20 años (Norström); K29.2 inmediato → 10 años (geométrica 0,5); K86.0 inmediato → 20 años (geométrica 0,8); cánceres: sin efecto <10 años → pleno a 20 años (lineal) | Holmes et al. 2012, Tabla 2 (doi:10.1016/j.drugalcdep.2011.12.005) | Asumido (de revisiones de series temporales agregadas) | **Media**: rezagos agregados internacionales; la forma funcional importa más que el país |
| P9 | Denominador de muertes evitables | Muertes totales de la causa × PIF (no muertes atribuibles × PIF) | OMS Q&A CRA 2024 (who.int, URL en §7); Steenland y Armstrong 2006 (PMID 16804473) | Asumido (convención CRA) | **Alta** |
| P10 | PIF agregado entre causas | Σ muertes evitables / Σ muertes totales | Derivado de P9 (la multiplicación es por causa, edad y sexo; la agregación es cociente de sumas) | Asumido (convención) | **Alta** |

---

## 2. Respuestas Q1–Q7

### Q1. ¿Cómo tratan InterMAHP, GBD, SAPM y SIMAH el cambio contrafactual en condiciones 100% atribuibles?

**InterMAHP**: las condiciones totalmente atribuibles [TEXTO] "have, by definition, AAFs = 1.0" (Guía, §1.5); no se les aplica distribución contrafactual de exposición: entran al total atribuible, no al PIF. **GBD 2016**: [TEXTO] para los trastornos por uso de alcohol, "we assumed a PAF of 1" (Methods, PMID 30146330). **SAPM/STAPM**: no usan PIF para estas causas; [TEXTO] "We fit absolute risk functions for wholly-attributable acute and chronic conditions" y luego "applies the Potential Impact Fraction method to update mortality and morbidity rates" (Holmes et al. 2026, Methods). **SIMAH**: no usa AAF ≡ 1; AUD se modela con RR continua exp(β·g/día) con topes (código `AUD.R`), con sobrescritura para exbebedores.

| Modelo | Tratamiento de AAF = 1 | Métrica de exposición | Fórmula | Ubicación |
|---|---|---|---|---|
| InterMAHP | AAF ≡ 1, sin contrafactual | Volumen (g/día, gamma) + HED + exbebedor | No aplica (AAF = 1) | Guía §1.5 |
| GBD 2016 | PAF ≡ 1 asumido | TMREL = 0 (0–0,8 tragos estándar/día) | No aplica | Lancet 2018, Methods |
| SAPM/STAPM | Funciones de riesgo absoluto ajustadas | Consumo (g/día o unidades/semana) con rezagos | Tasa(c) ajustada a datos; PIF actualiza tasas | Holmes 2026, Methods; Holmes 2012, Tabla 2 |
| SIMAH v0.1.1 | RR continua por causa (AUD agrega causas 100%) | g/día continuo (tope 200) | RR = exp(β·g/día); topes 122,51 (H)/114,12 (M) | `AUD.R`, Zenodo 15641639 |

### Q2. ¿Desplazar la curva de riesgo equivale a reescalar la distribución de exposición?

[TEXTO] Barendregt y Veerman (2010) distinguen tres métodos de cambio contrafactual —cambio de proporciones, cambio de distribución y cambio de RR— y reportan: "The 'RR shift' and 'distribution shift' calculation produce virtually the same results" (abstract, solo resumen). Recomiendan RR-shift para estrategias de alto riesgo y distribution-shift para estrategias poblacionales. La Guía InterMAHP anota que su Fórmula 3.5 es matemáticamente idéntica a la referencia [53] "save for differing limits of integration" [TEXTO] — es decir, la equivalencia pasa por los límites de integración. [INFERENCIA] Por cambio de variable x′ = k·x: ∫RR(kx)f(x)dx sobre (0,03; z) equivale a ∫RR(x′)·f(x′/k)/k dx′ sobre (0,03/k; z/k): la densidad queda reescalada y los límites transformados. [INFERENCIA] Con distribución gamma fija y tope en 150 g/día, la equivalencia es exacta solo si el tope también se reescala.

### Q3. ¿Qué asumen los modelos publicados sobre quienes abandonan HED? ¿Existe fuente revisada por pares de la "redistribución de Ruiz-Tagle et al."?

**NO ENCONTRADO** para la redistribución de volumen atribuida a Ruiz-Tagle et al. Búsquedas: (i) texto completo de Ruiz-Tagle et al. 2026 (Public Health in Practice; contiene AAF tipo InterMAHP con Ec. 2 para HED ≥60 g, pero ningún escenario PIF ni parámetro λ); (ii) búsqueda web "Ruiz-Tagle 'potential impact fraction' alcohol Chile heavy episodic drinking" (0 resultados); (iii) búsqueda de autor en Semantic Scholar (solo trabajos no relacionados). Lo publicado más cercano: SIMAH/Kilian et al. 2025 envían a quienes abandonan el consumo a **abstinencia completa** (alc_gpd = 0), muestreados por probabilidad de abandono específica de categoría (`apply_tax_policy.R`) — una redistribución aún más extrema que λ = 1. [INFERENCIA] Ningún modelo revisado por pares publicado redistribuye a ex-HED a la distribución de volumen de bebedores no-HED.

### Q4. ¿Cómo tratan los modelos de política el riesgo residual de exbebedores y a los quitters inducidos por política?

**InterMAHP** mantiene un RR categórico de exbebedor (Guía §3.2.5) dentro del AAF; sus escenarios PIF no suelen cambiar la composición abstemio/exbebedor/bebedor [INFERENCIA a partir de las Fórmulas 3.1–3.5]. **SIMAH**: los quitters por política pasan a alc_gpd = 0 y el módulo `update_former_drinker.R` les asigna estocásticamente condición de exbebedor según la proporción observada por edad×sexo; los módulos `AUD.R` e `IHD.R` sobrescriben la RR con la de exbebedor cuando aplica — es decir, **el término exbebedor sí se mueve** en el contrafactual. Evidencia empírica del exceso de riesgo: Stockwell et al. 2016 (meta-análisis, 87 estudios): exbebedores RR 1,22 (IC95% 1,14–1,31), 1,38 (1,24–1,54) totalmente ajustado frente a abstemios de por vida (abstract, solo resumen). [INFERENCIA] Tratar quitters como abstemios sobrestima el beneficio de la política.

### Q5. ¿Cómo agregan/comunican las publicaciones de política los PIF negativos (curvas J)?

**STAPM (Holmes et al. 2026)**: mantiene los aumentos de enfermedad cardiovascular dentro de los totales netos, los comunica explícitamente (las muertes por algunas ECV aumentan al subir el MUP) y reporta un análisis de sensibilidad que remueve los efectos protectores (impacto sobre muertes +5,6% mayor). **CRA-OMS (Shield et al. 2025)**: publica los PAF negativos con signo en su tabla de causas (diabetes −0,1% y ACV isquémico −0,7% de las muertes, Tabla 1). [TEXTO/INFERENCIA] La práctica publicada converge en: (i) no truncar ni excluir; (ii) reportar resultados por causa además del neto; (iii) cuantificar la contribución de los efectos protectores con sensibilidad. Ninguna fuente leída promedia PIF entre causas: la agregación publicada es cociente de sumas de muertes (evitables/totales).

### Q6. ¿Estado estacionario o rezagos temporales? ¿Qué estructuras de rezago usan SAPM, SIMAH y otros?

Práctica mixta y documentada. **SAPM/STAPM**: rezagos por causa de Holmes et al. 2012, Tabla 2 — G31.2/G62.1/G72.1/I42.6: primer efecto inmediato, pleno a 20 años (lineal); K70: año 1 → 20 años (Norström); K29.2: inmediato → 10 años (geométrica 0,5); K86.0: inmediato → 20 años (geométrica 0,8); cánceres: sin efecto antes del año 10, pleno al año 20. Consecuencia observable: en Holmes et al. 2026 la reducción anual de muertes [TEXTO] "increases from Year 1 to a peak in Year 5, remains stable to Year 10, and then increases each year from Year 11 onwards" por el inicio de los efectos en cáncer. **SIMAH**: usa el consumo del año en curso (riesgo concurrente; verificado en `simulate_mortality.R`, risk = RR × tasa). **InterMAHP/GBD/OMS-CRA**: estado estacionario, sin rezagos. [INFERENCIA] El estado estacionario es el estándar para PIF tipo CRA; los rezagos son estándar solo en microsimulación dinámica de política.

### Q7. ¿Es "muertes totales de la causa × PIF" el denominador aceptado? ¿Algún texto advierte contra aplicar AAF sobre PIF?

Sí, el denominador es la carga **total** de la causa. [TEXTO] OMS (Q&A de CRA, 2024): "The attributable disease burden is then estimated by multiplying the total burden by the PAF for each relevant health outcome and by age and sex". Steenland y Armstrong (2006; abstract, solo resumen) describen el mismo procedimiento (fracción × casos totales = carga atribuible) y revisan sus supuestos. Rockhill et al. (1998) documentan malos usos del PAF (interpretación causal, suma de PAF > 100%, sesgo por confusión), pero **NO ENCONTRADO**: un texto metodológico que advierta explícitamente contra "aplicar el AAF sobre el PIF" o usar como denominador solo las muertes atribuibles. [INFERENCIA] Aplicar el PIF a las muertes atribuibles (AAF × totales) en lugar de a las totales contaría dos veces la atribución; la identidad validada por el equipo (PIF = (AAF − AAF_cf)/(1 − AAF_cf)) confirma algebraicamente que el denominador correcto son las muertes totales de la causa.

---

## 3. Tabla de evidencia

| Referencia | DOI/PMID/URL | Diseño/población | Qué sostiene | Números clave (ubicación; estimado/asumido) | Transportabilidad a Chile | Calidad/limitaciones |
|---|---|---|---|---|---|---|
| Sherk et al. 2017, Guía InterMAHP | uvic.ca/research/centres/cisur/assets/docs/intermahp-guide.pdf (verificada) | Manual técnico del modelo InterMAHP | AAF = 1 por definición (§1.5); Fórmulas 3.1–3.5 con término exbebedor (§3.2.5); equivalencia "save for differing limits of integration" | Valores por defecto: factor de corrección 0,8; z = 250 g/día; extrapolación con tope sobre 150 g/día (asumidos, convención) | Alta: mismo marco usado por el equipo (Ruiz-Tagle 2026) | Manual no revisado por pares; versión 2017 (verificar si hay versión más reciente: NO ENCONTRADA) |
| GBD 2016 Alcohol Collaborators, Lancet 2018 | doi:10.1016/S0140-6736(18)31310-2; PMID 30146330 | CRA sistemático, 195 países, 1990–2016 | PAF = 1 asumido para trastornos por uso de alcohol; TMREL = 0 | TMREL 0 (IC95% 0–0,8 tragos estándar/día), Methods (estimado de la curva de riesgo) | Alta (convención) | Revisión por pares; supuesto de PAF = 1 es definicional, no empírico |
| Holmes et al. 2012, Drug Alcohol Depend | doi:10.1016/j.drugalcdep.2011.12.005; PMID 22197480 | Revisión sistemática de especificaciones de rezago en series temporales agregadas | Estructuras de rezago por causa usadas por SAPM/STAPM | Tabla 2: formas lineal/geométrica/Norström; cánceres sin efecto <10 años, pleno a 20 años (asumidos desde literatura agregada) | Media: rezagos agregados, no específicos de Chile | Las funciones provienen de series temporales de consumo per cápita, no de cohortes individuales |
| Holmes et al. 2026, PLoS Med (STAPM) | doi:10.1371/journal.pmed.1004792 | Microsimulación dinámica, Escocia; MUP £0,50 → £0,65–£0,80 | Funciones de riesgo absoluto para causas 100%; PIF para actualizar tasas con rezagos; comunica compensaciones ECV y SA sin efectos protectores | £0,65: −12,0% consumo; 3.385 muertes totales y 2.578 muertes 100% atribuibles menos en 20 años (Abstract; estimados del modelo) | Media: precios/impuestos UK; estructura transportable | Modelo con supuestos declarados; 4 SA reportados |
| Purshouse et al. 2010, Lancet (SAPM) (solo resumen) | doi:10.1016/S0140-6736(10)60058-X; PMID 20338629 | Modelo epidemiológico, Inglaterra | Funciones de riesgo "from systematic reviews and meta-analyses, or derived from attributable fractions" (abstract) | — | Media | Solo resumen leído; la forma funcional de causas 100% en SAPM v1–v3 remite a Jones 2013 (NO LEÍDO) |
| Kilian et al. 2025, Lancet Public Health | doi:10.1016/S2468-2667(25)00165-3; PMID 40885207 | Microsimulación SIMAH, EE.UU. 18–79 años, 2000–2019; 4 escenarios de precio | Quitters muestreados por probabilidad de abandono específica de categoría (elasticidad de participación); elasticidades precio propio por bebida | Relación elasticidad–consumo en U (r = 0,60); resultados por subgrupo (texto completo) | Media-alta (mecanismo), baja (cifras EE.UU.) | Revisión por pares; apéndice (pp. 3–22) NO LEÍDO directamente |
| Probst et al. 2023, Am J Epidemiol (protocolo SIMAH) | doi:10.1093/aje/kwad018; PMID 36702471 | Protocolo de microsimulación | Arquitectura SIMAH; contrafactual de abstención; calibración | — | Alta (arquitectura a replicar) | Protocolo; los coeficientes definitivos están en el código, no en el protocolo |
| SIMAH release v0.1.1 (código R) | doi:10.5281/zenodo.15641639 (v0.1.1, 2025-06-11) | Código fuente abierto | AUD: RR = exp(β·g/día) con topes 122,51 (H)/114,12 (M) g/día y sobrescritura exbebedor; quitters → abstención + recalibración estocástica de exbebedor; mortalidad con riesgo concurrente (sin rezago) | `AUD.R`, `update_former_drinker.R`, `IHD.R`, `simulate_mortality.R` (leídos); YLL = 79 − edad (convención del código) | Alta: es el código que el estudio planea replicar | Código: la "fuente" es la implementación, no un artículo; sin DOI por archivo |
| Shield et al. 2025, Lancet Public Health (CRA base del informe OMS 2024) | doi:10.1016/S2468-2667(25)00174-4; PMID 40883042 | CRA global; 540 encuestas, 174 países | PAF negativos publicados con signo; muertes por AUD sin intervalo de incertidumbre (tratadas como 100%) | 2019: 2,6 (2,3–3,1) millones de muertes atribuibles (4,7% de todas); diabetes −0,1% y ACV isquémico −0,7% de las muertes (Tabla 1); 156,5 mil muertes AUD sin UI (estimados) | Alta (convenciones del CRA que genera las RR usadas por el estudio) | Revisión por pares; métodos detallados en apéndice |
| OMS 2024, Global status report (GSRAHTSUD) | who.int/publications/i/item/9789240096745 | Informe oficial, 334 pp. | Fuente de las funciones RR en forma canónica InterMAHP usadas por el estudio; magnitud global | 2,6 millones de muertes atribuibles en 2019 (página oficial) | Alta (fuente primaria del estudio) | Página oficial leída, no las 334 pp.; las RR específicas remiten a Shield et al. 2025 |
| OMS 2024, Q&A "Estimations of attributable burden of disease" | who.int/news-room/questions-and-answers/item/environmental-health-estimations-of-attributable-burden-of-disease-due-to-a-risk-factor | Página metodológica | Denominador: "multiplying the total burden by the PAF" por resultado, edad y sexo | — | Alta | Página divulgativa; remite a Ezzati 2002/WHO 2009 |
| Steenland y Armstrong 2006, Epidemiology (solo resumen) | doi:10.1097/01.ede.0000229155.05644.43; PMID 16804473 | Revisión metodológica | Marco general: fracción atribuible × casos totales = carga atribuible; usos del PAF/PIF | — | Alta | Solo resumen; año 2006 (clásico, no reciente) |
| Rockhill et al. 1998, Am J Public Health | doi:10.2105/AJPH.88.1.15; PMC1508384 | Comentario metodológico | Usos y malos usos del PAF (causalidad, suma de PAF, confusión) | — | Alta (conceptual) | Antiguo; no cubre PIF de escenarios |
| Barendregt y Veerman 2010, J Epidemiol Community Health (solo resumen) | doi:10.1136/jech.2009.090274; PMID 19692711 | Nota metodológica | Taxonomía de 3 métodos contrafactuales; equivalencia RR-shift ≈ distribution-shift; evitar proportions-shift | "virtually the same results" (abstract) | Alta (metodológico) | Solo resumen; demostración algebraica no contenida en el abstract |
| Stockwell et al. 2016, J Stud Alcohol Drugs (solo resumen) | doi:10.15288/jsad.2016.77.185; PMID 26997174 | Revisión sistemática + meta-análisis, 87 estudios | Exceso de riesgo de exbebedores vs abstemios de por vida | RR 1,22 (1,14–1,31); 1,38 (1,24–1,54) totalmente ajustado (abstract; estimado) | Media: poblaciones mayormente Norteamérica/Europa | Heterogeneidad entre estudios; sesgo de "abstemios enfermos" discutido por los propios autores |
| Wyper et al. 2023, Lancet | PMID 36963415; PMC10154457 (discrepancia de DOI, ver §8) | Experimento natural: MUP Escocia 2018; series temporales interrumpidas + control sintético | Las muertes 100% atribuibles sí responden a política de precio | −13,4% (IC95% −18,4 a −8,3) muertes totalmente atribuibles; ≈156 muertes/año evitadas; dependencia −23,0%; enfermedad hepática alcohólica −11,7%; causas agudas +6,6% (NO significativo al 5%) (Resultados; estimados) | Media: política de precio escocesa; signo y orden de magnitud informativos para Chile | Seguimiento 2018–2020 (incluye inicio de pandemia); causas agudas con IC amplio que incluye efecto nulo |
| Ruiz-Tagle et al. 2026, Public Health in Practice | doi:10.1016/j.puhip.2026.100798; PMC13195772 | CRA Chile, 2008–2022; ENPG + DEIS | AAF tipo InterMAHP con término exbebedor (Ec. 1); HED ≥60 g para IHD/ACV isquémico/lesiones (Ec. 2); NO contiene PIF ni λ | 14,6% (2008) → 9,6% (2022) de todas las muertes atribuibles al alcohol; 10.000 draws Monte Carlo; tope 150 g/día (estimados) | Alta: es Chile y el mismo equipo FONDECYT | Existe corrigendum (verificar qué corrige antes de citar cifras: PENDIENTE); exbebedor = bebió en el último año pero no en el último mes |
| Castillo-Carniglia et al. 2013, Alcohol Alcohol (solo resumen) | doi:10.1093/alcalc/agt066; PMID 23831731 | AAF Chile, año 2009; ENPG 2008 | Carga atribuible nacional previa | 8.750 muertes atribuibles; 9,8% (IC95% 7,0–13,0) de las muertes de 2009 (abstract; estimado) | Alta | Solo resumen; datos de 2008–2009 |
| Castillo-Carniglia et al. 2025, Addiction (solo resumen) | doi:10.1111/add.70031; PMID 40000011 | Revisión narrativa, perfil de políticas Chile | Contexto de políticas; escasez de evaluaciones | "only a few studies focusing specifically on policy evaluation" (abstract) | Alta | Revisión narrativa, no estimación |
| Cherpitel et al. 2018, Rev Panam Salud Pública (solo resumen) | doi:10.26633/RPSP.2018.7; PMID 29628742 | Caso-cruzado; 1.024 pacientes de urgencias con lesión violenta, 11 países (LatAm/Caribe) | Riesgo agudo dosis-respuesta por consumo previo al evento (dimensión HED) | RR 5,6 con <2 tragos; 32,7% de lesiones violentas atribuibles (38% hombres; 12,3% mujeres) (abstract; estimados) | Media-alta (LatAm; lesiones agudas) | Solo urgencias, lesiones violentas; no mortalidad |

---

## 4. Evidencia chilena y latinoamericana (separada)

### 4a. Chile

- **Ruiz-Tagle, Román y Castillo-Carniglia 2026** (Public Health in Practice 11:100798; doi:10.1016/j.puhip.2026.100798; PMC13195772; **texto completo**): tendencias de mortalidad atribuible al alcohol en Chile 2008–2022 por sexo y edad, con la fórmula tipo InterMAHP y término de exbebedor (Ec. 1), desagregación HED ≥60 g para IHD, ACV isquémico y lesiones (Ec. 2), suavizado gamma con tope 150 g/día y 10.000 draws Monte Carlo. Resultado central: la fracción atribuible **bajó de 14,6% (2008) a 9,6% (2022)** de todas las muertes (estimado, con IC por MC). Es la referencia de coherencia metodológica inmediata para el PIF del presente estudio. **No contiene escenarios PIF ni parámetro λ**: la atribución "redistribución usada por Ruiz-Tagle et al." no se pudo verificar (§8). Existe un corrigendum publicado: **PENDIENTE** verificar su alcance antes de citar cifras específicas.
- **Castillo-Carniglia et al. 2013** (Alcohol Alcohol 48(6):729–736; doi:10.1093/alcalc/agt066; **solo resumen**): 8.750 muertes atribuibles y 9,8% (IC95% 7,0–13,0) de las muertes de 2009; fuente de exposición ENPG 2008. Referencia histórica de magnitud.
- **MINSAL, Estudio de Carga de Enfermedad 2008** (**cita secundaria** vía Ruiz-Tagle et al. 2026; informe no leído directamente): 8.366 muertes atribuibles (9,7%) en 2004. Una estimación posterior basada en 2014 (13%; 13.260 muertes) también se cita dentro de Ruiz-Tagle et al. 2026 — ambas se reportan aquí solo como citas secundarias, sin verificación del documento original.
- **Castillo-Carniglia et al. 2025** (Addiction 120(7):1466–1474; doi:10.1111/add.70031; **solo resumen**): perfil nacional de políticas; constata [TEXTO] "only a few studies focusing specifically on policy evaluation" en Chile — el vacío que este estudio contribuye a llenar.

### 4b. América Latina

- **Cherpitel et al. 2018** (Rev Panam Salud Pública 42:e7; doi:10.26633/RPSP.2018.7; **solo resumen**): caso-cruzado en 1.024 pacientes de urgencias de 11 países; dosis-respuesta aguda por consumo previo al evento (RR 5,6 ya con <2 tragos); 32,7% de las lesiones violentas atribuibles al alcohol (38% hombres, 12,3% mujeres) (estimados). Relevancia: sustenta empíricamente, en población latinoamericana, la dimensión HED/ocasión para lesiones que el PIF modela.

**Síntesis de la sección:** no se encontró ningún estudio chileno o latinoamericano publicado que compute PIF de escenarios de política alcohólica; la evidencia regional es de carga atribuible (CRA) y de riesgo agudo. Las convenciones de PIF provienen íntegramente de modelos internacionales (Canadá/UK/EE.UU./OMS).

---

## 5. Recomendaciones por decisión

**D-a (causas 100% en el PIF).** Recomendación: **Opción A como declaración principal** (fuerza: **alta**) + **Opción B como extensión complementaria declarada** (fuerza: **media**). Qué la cambiaría: para A, nada plausible — es la convención de los dos CRA dominantes; para B, la publicación revisada por pares de un submodelo calibrado con tasas basales chilenas por nivel de consumo, o validación externa tipo Wyper 2023 en datos latinoamericanos. Limitación a declarar: el submodelo B escala las muertes 100% atribuibles por el cambio en consumo per cápita (o prevalencia HED) como *proxy*; no existen funciones de riesgo absoluto ni RR por g/día específicas para Chile de F10/G31.2/G62.1/G72.1/Q86.0/I42.6/K86.0/K29.2/X45/X65/Y15; los topes de SIMAH (122,51/114,12 g/día) provienen de cohortes de EE.UU.

**D-b (λ de salida de HED).** Recomendación: **λ = 0 como escenario principal y reporte de ambos λ con el cambio de consumo implícito** (fuerza: **media**). Qué la cambiaría: evidencia longitudinal (idealmente chilena) sobre la trayectoria de volumen de quienes abandonan HED; o un documento publicado que formalice la redistribución λ = 1. Limitación a declarar: λ es un **supuesto conductual no estimado**; λ = 1 con −50% de prevalencia HED implica −26,5% de cambio en consumo medio, cifra que debe figurar junto al resultado para hacer el supuesto auditable.

**D-c (quitters y término exbebedor).** Recomendación: **mover los quitters a la categoría de exbebedores con RR_fd** (es decir, dejar que el término de exbebedor se mueva en el contrafactual), con la asignación edad×sexo de SIMAH como plantilla (fuerza: **media**); sensibilidad con el término fijo (opción InterMAHP). Qué la cambiaría: RR de exbebedor específicos por causa para Chile/LatAm, o evidencia de que los quitters inducidos por política difieren de los quitters "naturales". Limitación a declarar: los RR_fd disponibles (Stockwell 2016) son para mortalidad total, no por causa, y provienen de poblaciones del Norte Global.

**D-d (estado estacionario vs rezagos).** Recomendación: **estado estacionario como resultado principal** (fuerza: **alta**; coherente con el AAF ya reportado y con InterMAHP/GBD/OMS) **+ análisis de sensibilidad con la estructura de rezagos de Holmes 2012 Tabla 2** si se reporta un perfil temporal (fuerza: **media-alta**). Qué la cambiaría: un mandato explícito de horizonte de política de corto plazo (p. ej., presupuesto anual MINSAL), que haría principal al análisis con rezagos. Limitación a declarar: el estado estacionario sobrestima el efecto en los primeros años y lo subestima nunca; los perfiles de Holmes 2012 provienen de series agregadas internacionales.

**D-e (PIF negativos).** Recomendación: **mantener el signo, presentar causas específicas y totales netos, y añadir sensibilidad sin efectos protectores** (fuerza: **alta**). Qué la cambiaría: un requisito de revista o de contraparte; nada metodológico. Limitación a declarar: los PIF negativos dependen de las RR de IHD/ACV isquémico/diabetes a bajas dosis (curva J), cuya causalidad está disputada (Stockwell 2016 estima que desaparece con ajuste completo); por eso la sensibilidad sin protectores no es opcional sino parte del resultado.

---

## 6. Methods paragraphs (English)

**D-a, Option A (PIF restricted to partially attributable causes).** We computed potential impact fractions only for the 23 partially attributable causes, applying the InterMAHP formulation in which exposure is modelled as a gamma-distributed continuous volume (g/day) with a categorical heavy-episodic-drinking term and a fixed former-drinker relative risk term (Sherk et al., 2017, §3.2). Wholly (100%) alcohol-attributable conditions were excluded from the PIF by construction, following the InterMAHP convention that such conditions "have, by definition, AAFs = 1.0" (Sherk et al., 2017, §1.5) and the Global Burden of Disease practice of assuming a population attributable fraction of one for alcohol use disorders (GBD 2016 Alcohol Collaborators, 2018). These conditions therefore enter the attributable-mortality totals but are held invariant across counterfactual scenarios, as in the comparative risk assessment underlying the WHO Global Status Report (Shield et al., 2025). The PIF was validated against the identity PIF = (AAF − AAF_cf)/(1 − AAF_cf).

**D-a, Option B (scaled submodel for wholly attributable causes).** As a complementary analysis, wholly attributable deaths were allowed to respond to policy through a separate submodel, scaled by the counterfactual change in per-capita consumption and heavy-episodic-drinking prevalence. This follows the precedent of the Sheffield Tobacco and Alcohol Policy Model, which fits absolute risk functions for wholly attributable acute and chronic conditions and reports their deaths under policy scenarios (Holmes et al., 2026), and of SIMAH, which models alcohol use disorders with a continuous dose–response function, RR = exp(β × g/day), capped at 122.51 g/day (men) and 114.12 g/day (women) (Probst et al., 2023; SIMAH release v0.1.1, 2025). Empirical support that such deaths respond to pricing policy comes from the Scottish minimum unit pricing evaluation, which estimated a 13.4% reduction (95% CI −18.4 to −8.3) in wholly attributable deaths (Wyper et al., 2023). Because no Chile-specific absolute risk functions exist, the scaling factor is declared as an assumption.

**D-b, Option λ = 0 as principal scenario.** In the principal scenario, drinkers who exit heavy episodic drinking (HED) retain their baseline volume distribution and only lose the HED-related component of injury and ischaemic risk. This is the conservative specification: it does not impute an unobserved reduction in mean consumption and keeps the volume and HED dimensions of the risk function separable, consistent with the InterMAHP structure in which both enter the attributable fraction as distinct terms (Sherk et al., 2017). Methodological work on counterfactual exposure modelling shows that the choice between shifting the risk curve and shifting the exposure distribution is consequential mainly at the tails and should be aligned with the intervention's mechanism (Barendregt and Veerman, 2010); a HED-prevalence intervention does not, by itself, imply volume displacement. Published microsimulations adopt an even more conservative-absorbing rule, moving policy-induced quitters to complete abstention (Kilian et al., 2025).

**D-b, Option report both λ values with implied consumption.** Because no peer-reviewed source could be located for redistributing former HED drinkers onto the non-HED volume distribution (λ = 1), both λ values are reported as a sensitivity analysis, and each λ is accompanied by its implied change in mean consumption (λ = 1 with a 50% HED-prevalence reduction implies −26.5% mean consumption). Reporting assumption-dependent scenarios side by side, with explicit sensitivity analyses, follows current practice in alcohol policy microsimulation, where four or more sensitivity analyses are routinely presented (Holmes et al., 2026), and follows the uncertainty-reporting standard of Chilean attributable-fraction work, which propagates uncertainty through 10,000 Monte Carlo draws (Ruiz-Tagle et al., 2026). Presenting the implied consumption change converts an invisible modelling choice into an auditable behavioural assumption and bounds the plausibility of the λ = 1 scenario against observed post-policy consumption responses.

---

## 7. BibTeX

```bibtex
@techreport{sherk2017intermahp,
  author      = {Sherk, Adam and others},
  title       = {InterMAHP: The International Model of Alcohol Harms and Policies. A Comprehensive Guide to the Estimation of Attributable Harms},
  institution = {Canadian Institute for Substance Use Research, University of Victoria},
  year        = {2017},
  url         = {https://www.uvic.ca/research/centres/cisur/assets/docs/intermahp-guide.pdf}
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

@article{holmes2012temporal,
  author  = {Holmes, John and Meier, Petra S. and Booth, Andrew and Guo, Yelan and Brennan, Alan},
  title   = {The temporal relationship between per capita alcohol consumption and harm: a systematic review of time lag specifications in aggregate time series analyses},
  journal = {Drug and Alcohol Dependence},
  year    = {2012},
  volume  = {123},
  number  = {1--3},
  pages   = {7--14},
  doi     = {10.1016/j.drugalcdep.2011.12.005}
}

@article{holmes2026public,
  author  = {Holmes, John and others},
  title   = {Public health impacts of increasing the minimum unit price for alcohol in Scotland: A model-based appraisal},
  journal = {PLoS Medicine},
  year    = {2026},
  volume  = {23},
  number  = {1},
  pages   = {e1004792},
  doi     = {10.1371/journal.pmed.1004792}
}

@article{purshouse2010estimated,
  author  = {Purshouse, Robin C. and others},
  title   = {Estimated effect of alcohol pricing policies on health and health economic outcomes in England: an epidemiological model},
  journal = {The Lancet},
  year    = {2010},
  volume  = {375},
  number  = {9723},
  pages   = {1355--1364},
  doi     = {10.1016/S0140-6736(10)60058-X}
}

@article{kilian2025targeting,
  author  = {Kilian, Carolin and others},
  title   = {Targeting alcohol use in high-risk population groups: a US microsimulation study of beverage-specific pricing policies},
  journal = {The Lancet Public Health},
  year    = {2025},
  volume  = {10},
  number  = {10},
  pages   = {e815--e823},
  doi     = {10.1016/S2468-2667(25)00165-3}
}

@article{probst2023simulation,
  author  = {Probst, Charlotte and Buckley, Charlotte and Lasserre, Aurelie M. and Kerr, William C. and Mulia, Nina and Puka, Klajdi and Purshouse, Robin C. and Ye, Yu and Rehm, Jurgen and others},
  title   = {Simulation of Alcohol Control Policies for Health Equity (SIMAH) Project: Study Protocol},
  journal = {American Journal of Epidemiology},
  year    = {2023},
  doi     = {10.1093/aje/kwad018}
}

@misc{simah2025release,
  author       = {Probst, Charlotte and {SIMAH team}},
  title        = {SIMAH release v0.1.1},
  year         = {2025},
  publisher    = {Zenodo},
  doi          = {10.5281/zenodo.15641639},
  url          = {https://zenodo.org/records/15641639}
}

@article{shield2025national,
  author  = {Shield, Kevin and others},
  title   = {National, regional, and global statistics on alcohol consumption and associated burden of disease 2000--20: a modelling study and comparative risk assessment},
  journal = {The Lancet Public Health},
  year    = {2025},
  volume  = {10},
  number  = {9},
  pages   = {e751--e761},
  doi     = {10.1016/S2468-2667(25)00174-4}
}

@report{who2024global,
  author      = {{World Health Organization}},
  title       = {Global status report on alcohol and health and treatment of substance use disorders},
  institution = {World Health Organization},
  address     = {Geneva},
  year        = {2024},
  url         = {https://www.who.int/publications/i/item/9789240096745}
}

@misc{who2024burdenqa,
  author = {{World Health Organization}},
  title  = {Environmental health: Estimations of attributable burden of disease due to a risk factor (Q\&A)},
  year   = {2024},
  url    = {https://www.who.int/news-room/questions-and-answers/item/environmental-health-estimations-of-attributable-burden-of-disease-due-to-a-risk-factor},
  note   = {Accessed 2026-10-07}
}

@article{steenland2006overview,
  author  = {Steenland, Kyle and Armstrong, Ben},
  title   = {An overview of methods for calculating the burden of disease due to specific risk factors},
  journal = {Epidemiology},
  year    = {2006},
  volume  = {17},
  number  = {5},
  pages   = {512--519},
  doi     = {10.1097/01.ede.0000229155.05644.43}
}

@article{rockhill1998use,
  author  = {Rockhill, Beverly and Newman, Beth and Weinberg, Clarice},
  title   = {Use and misuse of population attributable fractions},
  journal = {American Journal of Public Health},
  year    = {1998},
  volume  = {88},
  number  = {1},
  pages   = {15--19},
  doi     = {10.2105/AJPH.88.1.15}
}

@article{barendregt2010categorical,
  author  = {Barendregt, Jan J. and Veerman, J. Lennert},
  title   = {Categorical versus continuous risk factors and the calculation of potential impact fractions},
  journal = {Journal of Epidemiology and Community Health},
  year    = {2010},
  volume  = {64},
  number  = {3},
  pages   = {209--212},
  doi     = {10.1136/jech.2009.090274}
}

@article{stockwell2016moderate,
  author  = {Stockwell, Tim and Zhao, Jinhui and Panwar, Sapna and Roemer, Audra and Naimi, Timothy and Chikritzhs, Tanya},
  title   = {Do "Moderate" Drinkers Have Reduced Mortality Risk? A Systematic Review and Meta-Analysis of Alcohol Consumption and All-Cause Mortality},
  journal = {Journal of Studies on Alcohol and Drugs},
  year    = {2016},
  volume  = {77},
  number  = {2},
  pages   = {185--198},
  doi     = {10.15288/jsad.2016.77.185}
}

@article{wyper2023evaluating,
  author  = {Wyper, Grant M. A. and Mackay, Daniel F. and Fraser, Catriona and Lewsey, Jim and Robinson, Mark and Beeston, Clare and Giles, Lucie},
  title   = {Evaluating the impact of minimum unit pricing for alcohol in Scotland: a natural experiment study of alcohol-attributable deaths and hospital admissions},
  journal = {The Lancet},
  year    = {2023},
  note    = {PMID: 36963415; PMCID: PMC10154457. DOI omitted: conflicting DOIs across publisher records (see report, section 8)},
  url     = {https://pmc.ncbi.nlm.nih.gov/articles/PMC10154457/}
}

@article{ruiztagle2026sex,
  author  = {Ruiz-Tagle Maturana, Jaime and Rom{\'a}n Mella, Francisca and Castillo-Carniglia, {\'A}lvaro},
  title   = {Sex and age differences in alcohol-attributable mortality in Chile between 2008 and 2022},
  journal = {Public Health in Practice},
  year    = {2026},
  volume  = {11},
  pages   = {100798},
  doi     = {10.1016/j.puhip.2026.100798}
}

@article{castillo2013alcohol,
  author  = {Castillo-Carniglia, {\'A}lvaro and others},
  title   = {Alcohol-attributable mortality and years of potential life lost in Chile in 2009},
  journal = {Alcohol and Alcoholism},
  year    = {2013},
  volume  = {48},
  number  = {6},
  pages   = {729--736},
  doi     = {10.1093/alcalc/agt066}
}

@article{castillo2025national,
  author  = {Castillo-Carniglia, {\'A}lvaro and others},
  title   = {National profile on substance use, substance use-related problems and policy: The case of Chile},
  journal = {Addiction},
  year    = {2025},
  volume  = {120},
  number  = {7},
  pages   = {1466--1474},
  doi     = {10.1111/add.70031}
}

@article{cherpitel2018risk,
  author  = {Cherpitel, Cheryl J. and others},
  title   = {Risk of violence-related injury from alcohol consumption and its burden to society in Latin America and the Caribbean},
  journal = {Revista Panamericana de Salud P{\'u}blica},
  year    = {2018},
  volume  = {42},
  pages   = {e7},
  doi     = {10.26633/RPSP.2018.7}
}
```

---

## 8. NO ENCONTRADO / NO VERIFICADO / discrepancias

1. **Fuente de la redistribución λ = 1 ("usado por Ruiz-Tagle et al.")** — **NO ENCONTRADO**. Búsquedas realizadas: (i) texto completo de Ruiz-Tagle et al. 2026 (PMC13195772): contiene AAF tipo InterMAHP y Ec. 2 de HED, pero ningún escenario PIF ni parámetro λ; (ii) búsqueda web `Ruiz-Tagle "potential impact fraction" alcohol Chile heavy episodic drinking`: 0 resultados; (iii) búsqueda de autor en Semantic Scholar: solo trabajos ajenos (cannabis, tratamiento). Recomendación: pedir al equipo la referencia interna o citar λ como supuesto propio.
2. **Tercer método publicado para D-a (opción C)** — **NO ENCONTRADO** más allá de las convenciones AAF = 1 (InterMAHP/GBD), funciones de riesgo absoluto (SAPM/STAPM) y RR continuas por causa (SIMAH).
3. **Advertencia explícita contra "aplicar AAF sobre PIF"** — **NO ENCONTRADO** como enunciado textual. Rockhill et al. 1998 documentan malos usos generales del PAF; OMS 2024 define el denominador correcto (carga total). La advertencia específica se sostiene aquí por [INFERENCIA] algebraica, no por cita.
4. **Apéndice de Kilian et al. 2025 (pp. 3–22)** — **NO LEÍDO** directamente; las afirmaciones sobre Kilian 2025 provienen del texto principal (PMC12478644). Si el estudio replica elasticidades específicas, leer el apéndice antes de fijar valores.
5. **Jones 2013 (funciones de riesgo absoluto de SAPM para causas 100%)** — **NO LEÍDO**; la descripción de STAPM se tomó de Holmes et al. 2026 (versión más reciente del modelo), que lo cita.
6. **Purshouse et al. 2013** (Alcohol Alcohol 48(2):180–188; doi:10.1093/alcalc/ags103; PMID 23015608) — **existencia verificada**, pero su resumen trata de costo-efectividad de intervenciones breves y **no documenta rezagos ni condiciones 100%**; según lo instruido, no se usó para esos temas.
7. **Wyper et al. 2023 — discrepancia de DOI**: el registro PMC/idconv da `10.1016/S0140-6736(23)00497-X`; la página del artículo en PMC mostró `…00435-X` y la página de The Lancet `…00415-4`. Sin forma de resolver la discrepancia desde las fuentes, se cita por **PMID 36963415 / PMCID PMC10154457** y se omitió el DOI en el BibTeX.
8. **OMS GSRAHTSUD 2024 — corrección de URL**: la URL candidata del encargo (`…/9789240096645`) no existe; la página oficial verificada es `https://www.who.int/publications/i/item/9789240096745` (Ginebra: OMS, 2024; 334 pp.; CC BY-NC-SA 3.0 IGO). El informe se citó solo a nivel de página oficial; las RR específicas remiten a Shield et al. 2025.
9. **GBD 2020** (alcohol, The Lancet 2022) — verificado solo a nivel PMID 35843246/PMC9289789; **no se usó** en este informe porque GBD 2016 bastaba para la convención PAF = 1 y no quiso citarse material no leído en profundidad.
10. **Guía InterMAHP (Sherk et al. 2017)** — se verificó la URL y se leyeron §1.5 y §3.2 en versión PDF; **no se encontró una versión más reciente** del manual. Las citas de sección (§1.5, §3.2.5, Fórmulas 3.1–3.5) corresponden a esa versión.
11. **Corrigendum de Ruiz-Tagle et al. 2026** — existe; **PENDIENTE** leerlo para confirmar si altera las cifras citadas (14,6% → 9,6%).
12. **MINSAL Carga de Enfermedad 2008 y estimación 2014** — citados solo como **citas secundarias** dentro de Ruiz-Tagle et al. 2026; los documentos originales no fueron localizados/leídos.

---

*Nota: este informe es metodológico y tiene fines exclusivamente informativos para el diseño del estudio; no constituye asesoría médica, epidemiológica oficial ni recomendación de política pública.*
