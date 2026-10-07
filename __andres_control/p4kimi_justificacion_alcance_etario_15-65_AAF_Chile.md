# Justificación del alcance etario (Decisión D1) para la estimación de fracciones atribuibles al alcohol en Chile, 2012-2024

KIMI-P4 | 2026-10-07 | 8 referencias leídas a texto completo / 7 solo resumen

---

## 1. Tabla de veredicto — Decisión D1 (exposición para 66-76 años)

| Decisión | Opción | Apoyo | Referencias clave | Por qué |
|---|---|---|---|---|
| D1 | **A) Mantener 15-65 y declarar limitación** | **Moderado** | Esser 2022 (solo resumen); Shield 2020 (solo resumen); GBD 2016 | Precedente directo: ARDI restringe a 20-64 [TEXTO]. Es la opción más transparente, pero omite las edades donde se concentra la mortalidad crónica atribuible; globalmente el 52.4% de las muertes AA ocurre antes de los 60, es decir, casi la mitad ocurre después [TEXTO (solo resumen)]. |
| D1 | **B) Puente de razones ENPG 60-65 × razón EPS 66-70/60-65** | **Débil** | Calvo 2020; Calvo 2021; Stockwell 2014 (solo resumen); Stockwell 2016 | Sin precedente publicado del puente exacto (NO ENCONTRADO). La evidencia chilena (EPS) apoya una razón <1 solo para cantidad y consumo pesado; para frecuencia la razón sería >1 («the old-old drink more frequently but less quantity», Calvo 2020) [TEXTO]. La EPS no mide HED ni consumo alguna vez [TEXTO], y el sub-reporte diferencial por edad sesga la razón transportada [TEXTO]. |
| D1 | **C) Usar ENS 2009-2010/2016-2017 para 65+** | **Moderado** | MINSAL 2017; Calvo 2021; GBD 2016 | Medición directa chilena en 65+ (sobremuestreo), por sexo, con AUDIT (frecuencia, cantidad y frecuencia de atracón en sus ítems 1-3) [TEXTO/INFERENCIA]. Debilidades prácticas: solo 2 olas para una serie bienal 2012-2024, instrumento distinto al de ENPG, y estimador inestable en mujeres 65+ (0.0%) [TEXTO]. |
| D1 | **D) Otro método publicado** | **D1-carry-forward: contrario (salvo como cota superior de sensibilidad). D1-modelado tipo OMS: moderado, baja factibilidad** | Maturana 2026; Shield 2025; GBD 2016 | El arrastre del último grupo tiene precedente directo en el propio proyecto (Maturana 2026, FONDECYT 1240138) [TEXTO], pero contradice los gradientes etarios documentados para Chile (declive de cantidad y consumo pesado; Calvo 2021) [TEXTO], por lo que sobreestimaría la exposición 65+. La predicción modelada (Dirichlet + respuesta fraccional, OMS/Shield 2025) es la convención internacional [TEXTO], pero exige ajustar modelos globales fuera del alcance del estudio. |

## 1b. Tabla de parámetros y decisiones

| ID registro | Parámetro/decisión | Valor u opción | Fuente (DOI + página/tabla) | Estimado/Asumido | Transportabilidad a Chile |
|---|---|---|---|---|---|
| P1 | Exposición 65+ en CRA global OMS | Predicción por regresión de Dirichlet (estatus) y respuesta fraccional (HED), covariables de edad hasta ≥65, interacción edad×sexo | Shield 2025, DOI 10.1016/S2468-2667(25)00174-4, métodos y apéndice 1 p.52 | Estimado | Media-alta: método transportable, pero requiere replicar el modelado global |
| P2 | Subgrupos etarios del modelo | Sexo × 15-34 / 35-64 / 65+ | Sherk 2017 (Guía InterMAHP), pp. 9 y 20, URL en BibTeX | Asumido (convención) | Alta: es el marco que el estudio emula |
| P3 | Exposición 65+ en AAF Chile publicada | Arrastre del grupo mayor disponible («similar to those observed in the oldest age group available») | Maturana 2026, §2.3 y §4, URL PMC en BibTeX | Asumido | Alta (mismo país/proyecto), pero contraindicada por P5 |
| P4 | Alcance restringido por diseño | 20-64 años (ARDI, EE.UU.) | Esser 2022 (solo resumen), URL PubMed en BibTeX | Asumido (decisión de alcance) | Media: contexto EE.UU.; allí la encuesta sí cubre 65+ |
| P5 | Gradiente etario Chile (EPS) | Consumo pesado ~12% (50 años) → ~6-7% (80 años); RR edad 0.98/año (IC95% 0.97-0.99), máximo a los 60 | Calvo 2021, DOI 10.1111/add.15292, Tab. 2 y Figs. 2 y 4 (valores Chile leídos de figuras) | Estimado | Alta (curva específica de Chile) |
| P6 | Razón 65+/50-64 de consumo pesado (21 países agrupados) | 4.34%/7.89% ≈ 0.55 | Calvo 2020, DOI 10.1016/j.drugalcdep.2020.108219, Tab. 3 | Estimado | Media: agrupado multinacional, no específico de Chile |
| P7 | Prevalencia de consumo riesgoso 65+ en Chile (AUDIT ≥8) | 4.8% total; hombres 11.1%; mujeres 0.0% (2016-17). 2009-10: 4.1%; 8.6%; 0.7% | MINSAL 2017, ENS 2016-2017 Primeros Resultados, URL en BibTeX | Estimado | Alta (fuente nacional directa); mujeres 65+ inestable |
| P8 | Uplift de encuesta a ventas per cápita | 73% (ARDI); 80% (estudios globales); 90% del APC (Buckley 2022) | Esser 2022 (solo resumen); Shield 2025; Buckley 2022, DOI 10.7895/ijadr.383, pp. 27-28 | Asumido (convención), criticado | Media: sin validación chilena; criticado por Stockwell 2018 |
| P9 | Sesgo del puente por sub-reporte diferencial | Subestimación 82.9% (<edad legal) vs 70.4% (65+), P<0.001 | Stockwell 2014 (solo resumen), DOI 10.1111/add.12609 | Estimado | Media (Canadá; patrón replicado en 4 países, Stockwell 2016) |

## 2. Respuestas Q1-Q4

**Q1. ¿Qué hacen los estudios AAF nacionales (InterMAHP, Shield 2020 y 2025, OMS) cuando las encuestas topan en 64/65?**
[TEXTO] InterMAHP exige exposición por sexo × 15-34/35-64/65+, pero no prescribe método cuando la encuesta topa antes: «It is currently beyond the scope of this document to discuss general survey calculations... this expertise falls to each region» (Sherk 2017, pp. 9-10; requisito de grupos en pp. 9 y 20). [TEXTO] OMS/Shield 2025 no arrastra el último grupo: predice estatus de consumo y HED con regresión de Dirichlet y de respuesta fraccional, covariables de edad hasta ≥65 e interacciones edad×sexo, calibrado a APC (540 encuestas, 174 países). [TEXTO] El precedente chileno (Maturana 2026, FONDECYT 1240138) sí arrastra: «we assumed that the consumption distribution for older age groups was similar to those observed in the oldest age group available», declarándolo limitación. [TEXTO (solo resumen)] Esser 2022 restringe ARDI a 20-64; Castillo-Carniglia 2013 trianguló ENPG-2008 con APC para 15+ sin detallar 65+ en el resumen.

**Q2. Gradientes etarios en 50+ según Calvo 2020 y 2021; ¿incluyen Chile y con qué encuesta? ¿Sostienen un puente de razones 60-65→66-76?**
[TEXTO] Calvo 2020 (21 países; Chile vía EPS 2009-2016, N=8,942): comparando 50-64 vs 65+, el consumo pesado cae 7.89%→4.34%, el moderado 32.37%→28.22% y los abstemios actuales suben 17.38%→23.71%; «the old-old drink more frequently but less quantity» (frecuencia 2.41→2.76 días/semana; cantidad 2.83→2.29 tragos estándar). [TEXTO] Calvo 2021 (22 países, incluye EPS-Chile): el consumo declina con la edad (RR≈0.98/año, IC95% 0.97-0.99; máximo a los 60) con heterogeneidad significativa entre países (p<0.001); en Chile el consumo pesado baja de ~12% a los 50 a ~6-7% a los 80 (Fig. 4). [INFERENCIA] Apoyan una razón <1 solo para cantidad/consumo pesado; para frecuencia sería >1. La EPS no mide HED ni consumo alguna vez, y los gradientes transversales mezclan cohortes: el puente es sostenible solo dimensión por dimensión.

**Q3. ¿Qué estudios usan ítems de alcohol de la EPS o de la ENS 2009-2010/2016-2017 para describir consumo en 65+? ¿Qué prevalencias por edad y sexo?**
[TEXTO] Los únicos estudios publicados identificados que usan ítems de alcohol de la EPS en 65+ son Calvo 2020 y Calvo 2021 (ver Q2). [TEXTO] ENS 2016-2017 (MINSAL 2017; población 15+ con sobremuestreo de >65): consumo riesgoso (AUDIT ≥8) en 65+ = 4.8% total (hombres 11.1%, mujeres 0.0%); en ENS 2009-10 = 4.1% (8.6% y 0.7%); «se observa diferencia estadísticamente significativa entre el grupo de 65 años y más y el resto de los grupos». Nacional 2016-17: 11.7%. [TEXTO (solo resumen)] Tala 2024 (encuesta SENDA en personas mayores, 2021): uso combinado de alcohol y fármacos de prescripción 12.8%. [INFERENCIA] El 0.0% en mujeres 65+ señala estimadores inestables en subgrupos extremos; la ENS es hoy la única fuente chilena con prevalencias publicadas por sexo en 65+.

**Q4. ¿Precedentes de puentes de razones entre encuestas con instrumentos distintos para exposición al alcohol? ¿Supuestos y sesgos?**
[TEXTO] No hay precedente publicado del puente exacto D1-B (NO ENCONTRADO); los puentes publicados entre instrumentos distintos son de otra clase: (i) reasignación de estatus de abstención entre encuestas — Buckley 2022 imputó categorías (abstemio de por vida / ex-consumidor / bebedor anual) al BRFSS con distribuciones de la NAS 2005 por edad (18-34/35-64/65+)×sexo×raza, con supuestos explícitos (APC ideal; las encuestas estiman válidamente la abstención) y la advertencia «no evidence... how groups might differentially under-report»; (ii) reescalado a ventas per cápita — GBD 2016 agrega la exposición individual edad×sexo al stock poblacional; uplift de 73% (ARDI) u 80% (global), criticado por Stockwell 2018. [TEXTO] Sesgo clave: el sub-reporte varía por edad — 82.9% en menores de edad legal vs 70.4% en 65+ (Stockwell 2014); «not evenly distributed across age and gender subgroups» (Stockwell 2016) — por lo que una razón 60-65→66-76 transportada entre encuestas hereda ese sesgo.

## 3. Tabla de evidencia

| Referencia | DOI/PMID/URL | Diseño/población | Qué sostiene | Números (página/tabla, unidad, denominador, período; estimado vs asumido) | Transportabilidad a Chile | Calidad/limitaciones |
|---|---|---|---|---|---|---|
| Sherk et al. 2017, Guía InterMAHP v1.0 (CISUR, U. Victoria) | URL: https://www.drugsandalcohol.ie/28421/ | Guía técnica del modelo InterMAHP | Requisito de 6 subgrupos sexo×(15-34/35-64/65+); el método de procesamiento de encuestas se delega a cada región | p. 9: insumos (i)-(vi); pp. 9-10: «It is currently beyond the scope of this document... this expertise falls to each region»; p. 20: hoja de entrada por grupo de edad. Asumido (convención del modelo) | Alta: define el marco que el estudio emula | No prescribe método cuando la encuesta topa en 65 |
| Shield et al. 2025, Lancet Public Health 10(9):e751-e761 | DOI 10.1016/S2468-2667(25)00174-4; PMID 40883042 | Modelado CRA global 2000-2020; 540 encuestas, 174 países | Convención OMS: exposición 65+ por predicción de regresión, no arrastre | Regresión de Dirichlet (estatus) + respuesta fraccional (HED); covariables de edad hasta ≥65, interacción edad×sexo; APC por edad/sexo (apéndice 1, p. 52); factor 0.8. 2.6 millones de muertes AA (4.7%) y 116.0 millones de DALYs (4.6%) en 2019, mundo. Estimado | Media-alta: método transportable; requiere ajustar modelos | Modelo global; no usa microdatos chilenos directamente |
| Shield et al. 2020, Lancet Public Health 5(1):e51-e61 (solo resumen) | DOI 10.1016/S2468-2667(19)30231-2; PMID 31910980 | CRA global 2000-2016 | Magnitud de la carga; mezcla de fuentes de exposición | 3.0 millones de muertes AA (5.3%) y 131.4 millones de DALYs (5.0%) en 2016; 52.4% de las muertes AA en <60 años; exposición «obtained from production and taxation statistics and from national surveys». Estimado | Media | Solo resumen (texto completo bloqueado); detalle del método 65+ no verificable |
| Maturana et al. 2026, Public Health in Practice, vol. 11 | URL PMC: https://pmc.ncbi.nlm.nih.gov/articles/PMC13195772/ | AAF Chile 2008-2022; ENPG 2008-2022 + mortalidad DEIS; FONDECYT 1240138 | Precedente chileno directo: carry-forward a >64 | §2.3: «In the absence of consumption data for individuals older than 64 years, we assumed that the consumption distribution for older age groups was similar to those observed in the oldest age group available»; ENPG cubre 12-64 años. 14.6% (IC95% 10.9-18.4) de muertes AA en 2008 → 9.6% (7.2-12.2) en 2022, Chile. Asumido | Alta: mismo país, mismo proyecto | Asunción declarada como limitación; contradicha por gradientes etarios (Calvo 2021) |
| Castillo-Carniglia et al. 2013, Alcohol Alcohol 48(6):729-736 (solo resumen) | DOI 10.1093/alcalc/agt066; PMID 23831731 | AAF y AVPP Chile 2009, población 15+ | Precedente chileno de triangulación encuesta+APC | Exposición «by triangulating the records of alcohol per capita consumption in Chile with information from the Eighth National Study of Drugs in the General Population (2008)»; 8,753 muertes AA (9.8%; IC95% 7.01-12.98); 195,475 AVPP (21.5%), Chile 2009. Estimado | Alta | Solo resumen; tratamiento de la exposición 65+ no detallado en el resumen |
| Esser et al. 2022, JAMA Netw Open 5(11):e2239485 (solo resumen) | PMID 36318209 | Estimaciones ARDI, EE.UU., 2015-2019 | Precedente de la opción A (restricción de alcance) y del uplift | Estimaciones restringidas a 20-64 años; auto-reporte ajustado al 73% de las ventas per cápita; estudios globales usan 80%. Asumido (decisión de alcance + convención) | Media: contexto EE.UU.; BRFSS sí cubre 65+ (la restricción no responde a un tope de encuesta) | Solo resumen |
| Calvo et al. 2020, Drug Alcohol Depend 215:108219 | DOI 10.1016/j.drugalcdep.2020.108219; PMID 32795884 | Armonización ex post de 7 encuestas, 21 países, 179,881 personas 50+ (1998-2016); Chile: EPS 2009-2016, N=8,942 | Gradientes 50-64 vs 65+; cobertura y límites de la EPS | Tab. 3 (muestra armonizada total): pesado 7.89%→4.34%; moderado 32.37%→28.22%; ocasional 17.26%→14.36%; abstemios actuales 17.38%→23.71%; frecuencia 2.41→2.76 días/sem; cantidad 2.83→2.29 tragos estándar/día de consumo; «the old-old drink more frequently but less quantity»; «In surveys that do not ask this question (ELSA and EPS), we separate current from long-term abstainers». Validación: r=.86 (abstención vs OMS); r≈0.80 (bebida actual vs GBD 2010). Estimado | Alta: usa la EPS chilena | Transversal; categorías armonizadas; números agrupados multinacionales, no Chile-específicos |
| Calvo et al. 2021, Addiction 116(6):1399-1412 | DOI 10.1111/add.15292; PMID 33241648 | 8 encuestas, 22 países, 106,180 personas 50+ (~2010); incluye EPS-Chile | Gradiente etario país-específico: base empírica del puente | RR edad 0.988/año (IC95% 0.97-0.99; Tab. 2 M1); máximo a los 60 años; heterogeneidad entre países (razón de verosimilitudes p<0.001); Chile: consumo pesado ~12% (50 años) → ~6-7% (80 años) (Fig. 4); SDU/sem ~1.6→~1.0 (Fig. 2); IDH/precios explican ~31% de la varianza. Estimado (valores Chile leídos de figuras) | Alta: incluye curva específica de Chile | Transversal: confunde edad y cohorte (declarado por los autores) |
| MINSAL 2017, ENS 2016-2017 Primeros Resultados | URL: https://www.minsal.cl/wp-content/uploads/2017/11/ENS-2016-17_PRIMEROS-RESULTADOS.pdf | Informe oficial; encuesta nacional 15+ con sobremuestreo de >65 | Prevalencias chilenas 65+ por sexo (opción C) | Consumo riesgoso (AUDIT ≥8) 65+: 4.8% (2016-17) vs 4.1% (2009-10); hombres 65+: 11.1% vs 8.6%; mujeres 65+: 0.0% vs 0.7%; nacional 2016-17: 11.7%; «Se observa diferencia estadísticamente significativa entre el grupo de 65 años y más y el resto de los grupos (IC95%)». Estimado | Alta: fuente nacional directa | 0.0% en mujeres 65+ indica estimador inestable; instrumento AUDIT ≠ ítems ENPG |
| Tala et al. 2024, Rev Med Chil 152(8):867-874 (solo resumen) | DOI 10.4067/s0034-98872024000800867; PMID 39853079 | Encuesta nacional SENDA en personas mayores, Chile 2021 | Marco chileno sobre consumo en mayores | Uso combinado de alcohol y medicamentos de prescripción con riesgo: 12.8% en personas mayores. Estimado | Media | Solo resumen; indicador combinado, no exposición alcohólica pura por edad×sexo |
| Buckley et al. 2022, IJADR 10(1):24-33 | DOI 10.7895/ijadr.383 | Ajuste de datos individuales BRFSS 1984-2020 (EE.UU.) a APC | Precedente de puente entre encuestas con instrumentos distintos + uplift | Reasignación de abstemios de 30 días a categorías (por vida / ex-consumidor / bebedor anual) con distribuciones NAS 2005 por edad (18-34/35-64/65+)×sexo×raza (p. 27); upshift al 90% del APC con razón r^(2/3), mayor ajuste a bebedores pesados (pp. 27-28); cobertura 45%→77% (p. 28); supuestos: APC ideal, encuestas válidas para abstención, poblaciones especiales beben +50% (p. 30); «there is currently no evidence to suggest how groups might differentially under-report alcohol consumption» (p. 31). Estimado + asumido | Media: método transportable; supuestos no verificables con datos chilenos | Requiere encuesta donante con categorías completas; heterogeneidad individual de sub-reporte no corregible |
| GBD 2016 Alcohol Collaborators (Griswold et al.) 2018, Lancet 392(10152):1015-1035 | URL PMC: https://pmc.ncbi.nlm.nih.gov/articles/PMC6148333/ | CRA global, 195 países, grupos quinquenales 15 a 95+, 1990-2016 | Reescalado de exposición individual a stock poblacional; advertencia contra el arrastre | «We rescaled age-specific and sex-specific estimates of individual-level consumption so that they aggregated to the estimates of population-level consumption» (métodos); sobre <15 años: «assuming consumption patterns of older age groups or trying to extrapolate past levels of alcohol consumption, are likely to introduce additional bias or error» (limitaciones); 694 fuentes; 2.8 millones de muertes AA en 2016. Estimado | Media-alta | Los crosswalks entre definiciones alternativas se describen solo en apéndice 1 (pp. 18-49), no verificado |
| Stockwell et al. 2014, Addiction 109(10):1657-1666 (solo resumen) | DOI 10.1111/add.12609; PMID 24825591 | CADUMS 2008-2010, Canadá, n=43,371; método «yesterday» | Sub-reporte diferencial por edad: sesgo del puente de razones | Subestimación del consumo: 82.9% (±1.19) en menores de edad legal vs 70.4% (±1.54) en 65+, P<0.001; bebedores de bajo riesgo subestiman más que los de alto riesgo (76.25%±0.34 vs 49.22%±3.01); sin diferencia por sexo. Estimado | Media: Canadá; patrón cualitativo replicado en 4 países (Stockwell 2016) | Solo resumen |
| Stockwell et al. 2016, Addiction 111(7):1203-1213 | DOI 10.1111/add.13373; PMID 26948693 | 4 encuestas nacionales (Australia, Canadá, EE.UU., Inglaterra), n total ≈86,600, 2008-2011 | No uniformidad del sub-reporte; cobertura de las encuestas QF | «Under reporting of alcohol consumption is not evenly distributed across age and gender subgroups»; cobertura de ventas per cápita: 31% (Canadá) a 57.5% (Inglaterra) (Tab. 6); subestimación neta de frecuencia: 2% (hombres)-16% (mujeres) EE.UU., 16-24% Australia, 43-53% Canadá; sesgo sobre los AAF por subgrupo explícito. Estimado | Media: sin Chile; se asume transportabilidad del patrón cualitativo | Método «yesterday»; cantidad no corregible en todos los países |
| Stockwell et al. 2018, Addiction 113(12):2245-2249 (solo resumen) | DOI 10.1111/add.14392 | Comentario editorial | Crítica a la convención de uplift al 80% | «The current practice of uplifting survey estimates to 80% of total [per capita consumption]» subestima por sub-muestreo de bebedores pesados en encuestas y cohortes. Asumido (la convención que critica) | Media | Comentario, no estudio primario |

## 4. Evidencia chilena y latinoamericana (separada)

**Chile.** La evidencia directa para la decisión D1 es: (i) Maturana 2026 — único estudio AAF chileno con series temporales (2008-2022), financiado por el mismo FONDECYT 1240138, que resolvió el tope 12-64 de la ENPG asumiendo la distribución del grupo mayor disponible y lo declaró como limitación que «potentially underestimates the total burden» [TEXTO]; (ii) Castillo-Carniglia 2013 — AAF 2009 para 15+ triangulando ENPG-2008 con APC, sin detallar 65+ en el resumen [TEXTO (solo resumen)]; (iii) MINSAL 2017 — únicas prevalencias publicadas de consumo riesgoso en 65+ por sexo (ENS) [TEXTO]; (iv) Tala 2024 — encuesta SENDA en personas mayores, indicador combinado [TEXTO (solo resumen)]; (v) Calvo 2020 y 2021 — la EPS chilena aporta los gradientes etarios 50+ dentro de armonizaciones multinacionales [TEXTO].

**Latinoamérica.** Calvo 2020 y 2021 incluyen además México (MHAS/ENASEM) y Costa Rica (CRELES), y documentan heterogeneidad significativa de los gradientes etarios entre países (p<0.001) [TEXTO]: los gradientes de otros países no son transportables a Chile. No se identificaron otros estudios AAF nacionales latinoamericanos con tratamiento documentado de la exposición 65+ (ver lista NO ENCONTRADO).

## 5. Recomendación

**Opción recomendada: C (usar la ENS 2009-2010/2016-2017 para la exposición 66-76), con fuerza MEDIA.** Es la única vía con medición directa chilena en 65+ por sexo, con sobremuestreo de mayores y un instrumento (AUDIT) cuyos tres primeros ítems cubren frecuencia, cantidad y frecuencia de atracón — dimensiones que la EPS no mide y que el modelo requiere (P2). Se complementa con dos análisis de sensibilidad que acotan el resultado: opción A como cota inferior y carry-forward (Maturana 2026) como cota superior, dado que la evidencia de gradientes (P5) ubica la exposición real 66-76 por debajo del arrastre.

**Qué la cambiaría:** (i) verificar en microdatos ENS que el ítem de atracón (AUDIT-3) y la distinción abstemio de por vida vs ex-consumidor tengan n suficiente por sexo en 65-69 y 70-76; si falla, caer a la opción A con limitación declarada; (ii) publicación de una ola ENS adicional con módulo de alcohol (mejoraría la interpolación de la serie bienal); (iii) un crosswalk validado entre AUDIT-ENS e ítems ENPG; (iv) si el objetivo fueran solo tendencias relativas y no niveles absolutos, la opción A sería preferible por simplicidad y comparabilidad interna.

**Limitación a declarar en cualquier caso:** la exposición 66-76 proviene de una encuesta e instrumento distintos (ENS/AUDIT vs ENPG), con solo dos olas interpoladas para 2012-2024; el estimador de mujeres 65+ es inestable (0.0% en 2016-17); y no existe corrección chilena del sub-reporte diferencial por edad, que la literatura muestra significativa (P9).

## 6. Methods and limitations paragraphs (English)

**Option C (primary).** Alcohol exposure for adults aged 66-76 was estimated from the Chilean National Health Survey (ENS 2009-2010 and 2016-2017), which covers the population aged 15 years and older with oversampling of adults over 65 and applies the AUDIT instrument, whose first three items capture drinking frequency, quantity, and heavy episodic drinking frequency. Risky drinking prevalence (AUDIT >=8) among adults aged 65+ was 4.8% in 2016-2017 (11.1% in men; 0.0% in women) and 4.1% in 2009-2010 (MINSAL 2017). Age- and sex-specific exposure for ages 66-76 was anchored to these waves and interpolated for intermediate years, and the resulting distribution was uplifted to recorded adult per capita consumption following international practice (GBD 2016 Alcohol Collaborators 2018; Esser et al. 2022). Limitations: ENS and ENPG use different instruments; only two ENS waves were available; the 65+ female estimate (0.0%) indicates unstable subgroup precision; and cross-sectional age gradients may conflate age and cohort effects (Calvo et al. 2021).

**Option A (restricted scope, lower-bound sensitivity).** As a conservative alternative, the analysis was restricted to the population aged 15-65 years, the range directly covered by the ENPG, and the exclusion of older adults was declared a limitation. This restricted-scope approach follows the US ARDI practice of reporting alcohol-attributable outcomes for ages 20-64 when estimates target premature mortality (Esser et al. 2022). Because survey-based exposure was uplifted to a fixed share of per capita consumption (73% in ARDI; 80% in global studies), the restriction affects absolute death and YLL counts more than within-scope attributable fractions (Esser et al. 2022; Stockwell et al. 2018). The restriction omits ages at which chronic alcohol-attributable mortality concentrates: globally, 52.4% of alcohol-attributable deaths occurred before age 60, implying that nearly half occur later (Shield et al. 2020). We therefore report the 15-65 estimates as a lower bound, complemented by a sensitivity analysis carrying the oldest observed exposure distribution forward to ages 66-76 (Maturana et al. 2026).

## 7. BibTeX

```bibtex
@article{shield2020lancetph,
  author  = {Shield, Kevin and Manthey, Jakob and Rylett, Margaret and Probst, Charlotte and Wettlaufer, Ashley and Hasan, Omer S. M. and Rehm, J{\"u}rgen},
  title   = {National, regional, and global burdens of disease from 2000 to 2016 attributable to alcohol use: a comparative risk assessment study},
  journal = {The Lancet Public Health},
  year    = {2020},
  volume  = {5},
  number  = {1},
  pages   = {e51--e61},
  doi     = {10.1016/S2468-2667(19)30231-2}
}
@article{shield2025lancetph,
  author  = {Shield, Kevin and Franklin, Audrey and Wettlaufer, Ashley and Hasan, Omer S. M. and Sohi, Ivneet and Probst, Charlotte and Llamosas-Falcon, Laura and Levesque, Christine and Manthey, Jakob and Rehm, J{\"u}rgen},
  title   = {National, regional, and global statistics on alcohol consumption and associated burden of disease 2000--20: a modelling study and comparative risk assessment},
  journal = {The Lancet Public Health},
  year    = {2025},
  volume  = {10},
  number  = {9},
  pages   = {e751--e761},
  doi     = {10.1016/S2468-2667(25)00174-4}
}
@techreport{sherk2017intermahp,
  author      = {Sherk, Adam and Stockwell, Tim and Rehm, J{\"u}rgen and Dorocicz, Jessica and Shield, Kevin D.},
  title       = {InterMAHP: A comprehensive guide to the estimation of alcohol-attributable morbidity and mortality (Version 1.0)},
  institution = {Canadian Institute for Substance Use Research, University of Victoria},
  year        = {2017},
  url         = {https://www.drugsandalcohol.ie/28421/}
}
@article{maturana2026chile,
  author  = {Maturana, Jos{\'e} Ruiz-Tagle and Rom{\'a}n Mella, Francisca and Castillo-Carniglia, {\'A}lvaro},
  title   = {Sex and age differences in alcohol-attributable mortality in Chile between 2008 and 2022},
  journal = {Public Health in Practice},
  year    = {2026},
  volume  = {11},
  url     = {https://pmc.ncbi.nlm.nih.gov/articles/PMC13195772/}
}
@article{castillo2013chile,
  author  = {Castillo-Carniglia, {\'A}lvaro and Kaufman, Jay S. and Pino, Paulina},
  title   = {Alcohol-attributable mortality and years of potential life lost in Chile in 2009},
  journal = {Alcohol and Alcoholism},
  year    = {2013},
  volume  = {48},
  number  = {6},
  pages   = {729--736},
  doi     = {10.1093/alcalc/agt066}
}
@article{esser2022ardi,
  author  = {Esser, Marissa B. and Leung, Gregory and Sherk, Adam and Bohm, Michele K. and Liu, Yong and Lu, Hua and Naimi, Timothy S.},
  title   = {Estimated Deaths Attributable to Excessive Alcohol Use Among US Adults Aged 20 to 64 Years, 2015 to 2019},
  journal = {JAMA Network Open},
  year    = {2022},
  volume  = {5},
  number  = {11},
  pages   = {e2239485},
  url     = {https://pubmed.ncbi.nlm.nih.gov/36318209/}
}
@article{calvo2020dad,
  author  = {Calvo, Esteban and Medina, Josefina T. and Ornstein, Katherine A. and Staudinger, Ursula M. and Fried, Linda P. and Keyes, Katherine M.},
  title   = {Cross-country comparability of harmonized alcohol use measures in aging studies: A validation study in 21 countries},
  journal = {Drug and Alcohol Dependence},
  year    = {2020},
  volume  = {215},
  pages   = {108219},
  doi     = {10.1016/j.drugalcdep.2020.108219}
}
@article{calvo2021addiction,
  author  = {Calvo, Esteban and Allel, Kasim and Staudinger, Ursula M. and Castillo-Carniglia, {\'A}lvaro and Medina, Josefina T. and Keyes, Katherine M.},
  title   = {Cross-country differences in age trends in alcohol consumption among older adults: a cross-sectional study of individuals aged 50 years and older in 22 countries},
  journal = {Addiction},
  year    = {2021},
  volume  = {116},
  number  = {6},
  pages   = {1399--1412},
  doi     = {10.1111/add.15292}
}
@techreport{minsal2017ens,
  author      = {{Ministerio de Salud de Chile}},
  title       = {Encuesta Nacional de Salud 2016--2017: Primeros Resultados},
  institution = {MINSAL, Gobierno de Chile},
  year        = {2017},
  url         = {https://www.minsal.cl/wp-content/uploads/2017/11/ENS-2016-17_PRIMEROS-RESULTADOS.pdf}
}
@article{tala2024revmedchil,
  author  = {Tala, Y. and others},
  title   = {Uso combinado de alcohol y medicamentos de prescripci{\'o}n en personas mayores en Chile},
  journal = {Revista M{\'e}dica de Chile},
  year    = {2024},
  volume  = {152},
  number  = {8},
  pages   = {867--874},
  doi     = {10.4067/s0034-98872024000800867}
}
@article{buckley2022ijadr,
  author  = {Buckley, Charlotte and Brennan, Alan and Kerr, William C. and Probst, Charlotte and Puka, Klajdi and Purshouse, Robin C. and Rehm, J{\"u}rgen},
  title   = {Improved estimates for individual and population-level alcohol use in the United States, 1984--2020},
  journal = {International Journal of Alcohol and Drug Research},
  year    = {2022},
  volume  = {10},
  number  = {1},
  pages   = {24--33},
  doi     = {10.7895/ijadr.383}
}
@article{gbd2016alcohol,
  author  = {{GBD 2016 Alcohol Collaborators}},
  title   = {Alcohol use and burden for 195 countries and territories, 1990--2016: a systematic analysis for the Global Burden of Disease Study 2016},
  journal = {The Lancet},
  year    = {2018},
  volume  = {392},
  number  = {10152},
  pages   = {1015--1035},
  url     = {https://pmc.ncbi.nlm.nih.gov/articles/PMC6148333/}
}
@article{stockwell2014addiction,
  author  = {Stockwell, Tim and Zhao, Jinhui and Macdonald, Scott},
  title   = {Who under-reports their alcohol consumption in telephone surveys and by how much? An application of the 'yesterday method' in a national Canadian substance use survey},
  journal = {Addiction},
  year    = {2014},
  volume  = {109},
  number  = {10},
  pages   = {1657--1666},
  doi     = {10.1111/add.12609}
}
@article{stockwell2016addiction,
  author  = {Stockwell, Tim and Zhao, Jinhui and Greenfield, Thomas and Li, Jessica and Livingston, Michael and Meng, Yang},
  title   = {Estimating under- and over-reporting of drinking in national surveys of alcohol consumption: identification of consistent biases across four English-speaking countries},
  journal = {Addiction},
  year    = {2016},
  volume  = {111},
  number  = {7},
  pages   = {1203--1213},
  doi     = {10.1111/add.13373}
}
@article{stockwell2018addiction,
  author  = {Stockwell, Tim and Zhao, Jinhui and Sherk, Adam and Rehm, J{\"u}rgen and Shield, Kevin and Naimi, Timothy},
  title   = {Underestimation of alcohol consumption in cohort studies and implications for alcohol's contribution to the global burden of disease},
  journal = {Addiction},
  year    = {2018},
  volume  = {113},
  number  = {12},
  pages   = {2245--2249},
  doi     = {10.1111/add.14392}
}
```

## 8. NO ENCONTRADO / NO VERIFICADO y discrepancias de DOI

- **NO ENCONTRADO — otros estudios con ítems de alcohol de la EPS en 65+.** Búsquedas: «Encuesta de Protección Social alcohol older adults Chile», «EPS Chile drinking elderly harmonization», y revisión de trabajos que citan Calvo 2020/2021. Solo se identificaron Calvo 2020 y Calvo 2021.
- **NO ENCONTRADO — precedente publicado del puente de razones exacto D1-B** (p_ENPG(66-70) = p_ENPG(60-65) × razón EPS). Búsquedas: «ratio bridge alcohol surveys older age groups», «crosswalk alcohol exposure surveys different instruments», «survey bridging alcohol prevalence estimation». Los precedentes hallados son de otra clase (reasignación de estatus entre encuestas: Buckley 2022; reescalado a ventas: GBD 2016; uplift ARDI/OMS: Esser 2022, Shield 2025).
- **NO ENCONTRADO — otros estudios AAF nacionales latinoamericanos con tratamiento documentado de la exposición 65+** (no se realizó búsqueda exhaustiva por país; ninguna de las fuentes revisadas citó alguno).
- **NO VERIFICADO — texto completo de Shield 2020.** thelancet.com y ScienceDirect devolvieron páginas de desafío JavaScript; se usó el resumen de PubMed (PMID 31910980) y los métodos de Shield 2025 (mismo linaje).
- **NO VERIFICADO — informe OMS 2024 (GSRAHTSUD) página a página.** Se localizó un PDF completo del informe pero no se extrajeron páginas de métodos; la metodología del ejercicio se documenta vía Shield 2025.
- **NO VERIFICADO — derivación de la exposición 65+ en Castillo-Carniglia 2013** (solo resumen; no se accedió al texto completo de OUP).
- **NO VERIFICADO — existencia y contenido del módulo de alcohol de una ENS posterior a 2016-2017 (p. ej., ENS 2023).**
- **NO VERIFICADO — DOI de Maturana 2026 y de Esser 2022** (se citan con URL de PMC/PubMed; no se inventan DOI).
- **Discrepancias de DOI entre los cinco candidatos propuestos: ninguna.** Calvo 2020 (10.1016/j.drugalcdep.2020.108219), Calvo 2021 (10.1111/add.15292), Shield 2020 (10.1016/S2468-2667(19)30231-2), Shield 2025 (10.1016/S2468-2667(25)00174-4) y la Guía InterMAHP (Sherk et al. 2017) coinciden en título, autores, año y contenido.

---

*Nota: este informe compila evidencia metodológica y epidemiológica con fines de investigación; no constituye asesoramiento profesional en salud pública.*
