# KIMI-P10 — Elección de métrica de años de vida perdidos y tabla de vida de referencia para mortalidad atribuible al alcohol en Chile (FONDECYT 1240138)

KIMI-P10 | búsqueda realizada el 2026-10-07 | 16 referencias leídas a texto completo (o documento oficial/dataset completo) / 4 solo resumen / 3 documentos oficiales consultados vía extractos verbatim de búsqueda (protocolo HMD v6, apéndice 1 de GBD 2021, boletín INE marzo-2025)

**Alcance:** estudio de mortalidad atribuible al alcohol en Chile, 15–65 años, 2012–2024; defunciones DEIS-MINSAL (CIE-10), exposición SENDA; YLL atribuible = YLL de la causa × FAA; evitable = YLL × PIF; etapa siguiente: microsimulación tipo SIMAH. Todo lo que sigue usa como referencia temporal la fecha de búsqueda (2026-10-07).

---

## 1. Tabla de veredicto por opción — Decisión D-a

| Decisión | Opción | Apoyo | Referencias clave | Por qué |
|---|---|---|---|---|
| D-a | **A. YLL con tabla de vida nacional de período (HMD Chile) como primaria + GBD TMRLT para comparabilidad** | **Fuerte** | Martínez 2019 ([DOI](https://doi.org/10.1093/ije/dyy254)); Vos 2020 ([DOI](https://doi.org/10.1016/S0140-6736(20)30925-9)); Devleesschauwer 2020 ([DOI](https://doi.org/10.1007/s00038-020-01430-2)); Haneef 2021 ([DOI](https://doi.org/10.1186/s13690-021-00652-x)); HMD Protocol v6 ([URL](https://www.mortality.org/File/GetDocument/Public/Docs/MethodsProtocolV6.pdf)) | La fórmula YLL = defunciones × esperanza de vida restante a la edad de muerte es el estándar metodológico sin cortes arbitrarios [TEXTO: "it avoids arbitrary judgements about age cut-offs, which are never methodologically justifiable" — Martínez 2019]. La tabla nacional es coherente con las defunciones DEIS (misma estadística vital que alimenta HMD/INE) e interpretable para política nacional; la TMRLT como secundaria da comparabilidad internacional (convención GBD). Dos sesgos documentados deben manejarse con sensibilidades (ver opción D): la paradoja de la tabla nacional año-específica en crisis de mortalidad (Devleesschauwer 2020) y la posible invalidación de comparaciones temporales al cambiar de tabla cada año (Haneef 2021). |
| D-a | **B. YLL con TMRLT GBD 2019 como primaria** | Moderado (fuerte solo si el objetivo declarado es comparabilidad internacional) | GHDx/IHME 2021 ([DOI](https://doi.org/10.6069/1D4Y-YQ37)); Naghavi 2024 ([DOI](https://doi.org/10.1016/S0140-6736(24)00367-2)); Wyper 2022 ([DOI](https://doi.org/10.1007/s10654-022-00846-9)); Ballin 2022 ([DOI](https://doi.org/10.1136/bmjopen-2022-066258)) | Es la convención GBD 2019/2021: tabla de referencia construida con las tasas de mortalidad por edad más bajas observadas en localidades >5 millones (e0 = 88,9 años), fija entre años y países — ideal para comparar con GBD/OMS [TEXTO: "Standard life expectancy is calculated from the lowest age-specific mortality rate between countries" — Naghavi 2024]. En contra como primaria para Chile: es un estándar aspiracional que infla el YLL (~+26 % vs HMD según el propio cálculo del proyecto) y sobreestima la pérdida en edades avanzadas respecto a la mortalidad real chilena [TEXTO: "aspirational life tables assume idealised populations with optimised life expectancy: 88.9 years at birth" — Ballin 2022]. |
| D-a | **C. YPLL con edad de referencia (e0 − edad, o umbral fijo 75) como primaria** | **Débil como primaria** (contrario como primaria; moderado como sensibilidad) | Martínez 2019 ([DOI](https://doi.org/10.1093/ije/dyy254)); Lemp 2026 ([DOI](https://doi.org/10.1001/jamahealthforum.2026.2348)); Castillo-Carniglia 2013 ([DOI](https://doi.org/10.1093/alcalc/agt066), solo resumen) | El corte fijo es una decisión arbitraria que excluye muertes en mayores y distorsiona el grupo 60–65 (en el propio piloto: −19,5 % en 60–65 con e0 − edad) [TEXTO: "avoids arbitrary judgements about age cut-offs… and exclusions of older population groups" — Martínez 2019]. Tiene precedente nacional (Castillo-Carniglia 2013 usó YPLL para Chile 2009) y en agencias de EE. UU. (Lemp 2026 usa 75), por lo que es defendible **solo** como métrica secundaria de comparación con esa literatura. |
| D-a | **D. Añadir WPP 2024 (o INE) como análisis de sensibilidad** | **Fuerte** | UN DESA WPP 2024 ([URL](https://population.un.org/wpp/)); INE Anuario 2022 ([URL](https://www.ine.gob.cl/docs/default-source/nacimientos-matrimonios-y-defunciones/publicaciones-y-anuarios/anuarios-de-estad%C3%ADsticas-vitales/anuario-de-estad%C3%ADsticas-vitales-2022.pdf?sfvrsn=88100883_4)); Aburto 2022 ([DOI](https://doi.org/10.1093/ije/dyab207)) | Las tres fuentes difieren hasta ~1,3 años en e0 (máximo documentado: mujeres 2019, HMD 83,81 vs WPP 82,55; tabla §4). El costo de la sensibilidad es bajo y documenta la robustez ante la elección de tabla; además WPP 2024 ya incorpora revisión pandémica coherente 2012–2024 (estimaciones 1950–2023 + variante media 2024). |

**Síntesis del veredicto:** adoptar **A + D** (YLL-HMD primario, TMRLT secundario para comparabilidad, sensibilidades WPP 2024/INE/tabla fija 2019); usar **C** solo como métrica secundaria adicional si se quiere comparación directa con Lemp 2026 o con la tradición chilena (Castillo-Carniglia 2013); no adoptar B como primaria salvo que la audiencia principal sea internacional-GBD.

## 1b. Tabla de parámetros

| ID | Parámetro/decisión | Valor u opción | Fuente (DOI/URL + página/tabla) | Estimado/Asumido | Transportabilidad a Chile |
|---|---|---|---|---|---|
| P1 | Fórmula YLL primaria | YLL(c,s,a,t) = D(c,s,a,t) × SLE(a), SLE de tabla de vida de período | Martínez 2019, p. 1368 (fórmula) ([DOI](https://doi.org/10.1093/ije/dyy254)); idéntica estructura en OMS GHE 2024, §2, p. 6: YLL = N × L(s,a) ([URL](https://cdn.who.int/media/docs/default-source/gho-documents/global-health-estimates/ghe2021_daly_methods.pdf)) | Asumido (convención) | Alta — fórmula universal; la tabla SLE es la que varía |
| P2 | Tabla de vida primaria | HMD Chile, tablas de período 1×1 (método: tasas m_x→q_x con a0 Andreev-Kingkade, suavizado Kannisto ≥80) | HMD Methods Protocol v6, última revisión 2025-08-05 ([URL](https://www.mortality.org/File/GetDocument/Public/Docs/MethodsProtocolV6.pdf)); valores Chile 2016–2020 vía datos suplementarios de Aburto 2022, File008 ([DOI](https://doi.org/10.1093/ije/dyab207)) | Estimado (HMD procesa estadísticas vitales chilenas) | Alta — construida con datos chilenos DEIS/INE |
| P3 | Tabla de comparabilidad internacional | GBD 2019 Reference Life Table (TMRLT), e0 = 88,9 años; e(85) = 9,99; e(90) = 7,62; e(95) = 5,92 | GHDx/IHME 2021 ([DOI](https://doi.org/10.6069/1D4Y-YQ37)); valores puntuales en Ballin 2022, discusión ([DOI](https://doi.org/10.1136/bmjopen-2022-066258)) | Asumido (estándar normativo) | Alta como estándar fijo; no refleja mortalidad chilena (esa es su función) |
| P4 | Construcción TMRLT | Tasas de mortalidad por edad más bajas observadas por localidad y sexo, todas las localidades >5 M de habitantes, año 2016 | GHDx/IHME 2021, descripción verbatim ([DOI](https://doi.org/10.6069/1D4Y-YQ37)); reafirmado para GBD 2021 en Naghavi 2024, métodos ([DOI](https://doi.org/10.1016/S0140-6736(24)00367-2)) | Asumido | Alta |
| P5 | Función de pérdida OMS (referencia adicional) | OMS GHE 2021 (publicado 2024-05): frontera proyectada 2050 de WPP 2024; pérdida neonatal 92,65 años (texto: "life expectancy at birth of 92.7 years"; el resumen ejecutivo redondea a 90) | OMS GHE Technical Paper WHO/DDI/DNA/GHE/2024.3, §2.2 y Tabla 2.1, pp. 8–9 ([URL](https://cdn.who.int/media/docs/default-source/gho-documents/global-health-estimates/ghe2021_daly_methods.pdf)) | Asumido | Media — estándar aún más aspiracional que TMRLT; útil solo si se compara con GHE |
| P6 | Descuento temporal y ponderación por edad | No aplicar (convención vigente desde GBD 2010 y OMS GHE) | Murray 2012, resumen ([DOI](https://doi.org/10.1016/S0140-6736(12)61689-4)): "Neither YLLs nor YLDs were age-weighted or discounted" (solo resumen); OMS GHE 2024, §2.3, p. 9: "Age-weighting and time discounting are dropped" | Asumido (convención) | Alta |
| P7 | YPLL con umbral fijo (sensibilidad) | Umbral 75 años: YPLL = (75 − edad al morir)⁺, tasas por 100 000 adultos | Lemp 2026, métodos ([DOI](https://doi.org/10.1001/jamahealthforum.2026.2348)): "YLL was calculated as the difference between a benchmark age of 75 years … and the age at death and standardized per 100 000 adults" | Asumido | Media — práctica de agencias de EE. UU.; en Chile existe precedente con otro umbral (Castillo-Carniglia 2013, umbral NO ENCONTRADO en el resumen) |
| P8 | Sensibilidad de tabla nacional | WPP 2024 (Rev.1, julio 2024): serie anual Chile 2012–2023 (estimaciones) + 2024 (variante media); INE: Anuario 2022 (2015–2022) y presentación 27-05-2026 (2023; 2025(p)) | UN DESA 2024, archivo WPP2024_GEN_F01_DEMOGRAPHIC_INDICATORS_COMPACT.xlsx, POP/DB/WPP/Rev.2024/GEN/F01/Rev.1 ([URL](https://population.un.org/wpp/)); INE 2024/2026 ([URL](https://www.ine.gob.cl/docs/default-source/prensa-y-comunicacion/270526-presentaci%C3%B3n-eevv-2023-2025%28p%29version-final.pdf?sfvrsn=e35568ac_2)) | Estimado | Alta — WPP ajusta con demografía de modelos; INE es la serie oficial nacional |
| P9 | Sesgo tabla nacional año-específica en 2020–2021 | Reconocer paradoja: caída de e0 reduce YLL por muerte justo cuando mueren más personas; mitigar con tabla fija 2019 o TMRLT en esos años | Devleesschauwer 2020, p. 719 ([DOI](https://doi.org/10.1007/s00038-020-01430-2)): "increased mortality risks… could cause life expectancy to go down, which could result in a contradictory reduction in estimates of YLL"; Haneef 2021 ([DOI](https://doi.org/10.1186/s13690-021-00652-x)) | Estimado (mecanismo demostrado) | Alta — Chile tuvo caída de e0 de −1,71 años (2019→2021, ambos sexos, INE) |
| P10 | Atribución | YLL atribuible(c,s,a,t) = YLL(c,s,a,t) × FAA(c,s,a,t) (multiplicar PAF por la cantidad de resultado) | Murray 2020 (GBD 2019 RF), resumen ([DOI](https://doi.org/10.1016/S0140-6736(20)30752-2)): "computed by multiplying population attributable fractions (PAFs) by the relevant outcome quantity for each age-sex-location-year" | Asumido (convención CRA) | Alta — coincide con el diseño del proyecto |

---

## 2. Respuestas a las preguntas (máx. 150 palabras c/u)

**Q1. ¿YLL con tabla de vida o YPLL con edad de referencia para alcohol? Sesgos de e0 − edad en edades mayores.**

La literatura metodológica favorece el YLL con esperanza de vida restante (tabla de vida): evita cortes de edad arbitrarios "never methodologically justifiable" y la exclusión de muertes en mayores, y pondera más las muertes jóvenes sin imponer un umbral [TEXTO, Martínez 2019](https://doi.org/10.1093/ije/dyy254). El esquema e0 − edad es un híbrido con dos sesgos documentados en edades mayores: (i) los fallecidos por sobre la e0 reciben pérdida cero (piso en 0), subestimando sistemáticamente el grupo 60–65 —consistente con el −19,5 % observado en el piloto—; (ii) aplica a todos la misma esperanza residual de un recién nacido en vez de la esperanza condicional a la edad, que siempre es mayor en quienes sobrevivieron [INFERENCIA a partir de la definición de e_x condicional, [HMD Protocol v6, ec. 83](https://www.mortality.org/File/GetDocument/Public/Docs/MethodsProtocolV6.pdf)]. Precedente chileno con YPLL: Castillo-Carniglia 2013 (solo resumen; umbral NO ENCONTRADO).

**Q2. ¿Cuándo tabla nacional (HMD/INE) vs TMRLT GBD? ¿Qué recomiendan GBD/OMS-GHE y la literatura?**

GBD usa siempre la tabla de referencia (TMRLT; construcción reafirmada en GBD 2021: "Standard life expectancy is calculated from the lowest age-specific mortality rate between countries" [TEXTO, Naghavi 2024](https://doi.org/10.1016/S0140-6736(24)00367-2)); OMS-GHE usa su propia frontera (92,65; Tabla 2.1 del [documento técnico 2024](https://cdn.who.int/media/docs/default-source/gho-documents/global-health-estimates/ghe2021_daly_methods.pdf)). Ambas priorizan comparabilidad entre países/años. La literatura advierte dos problemas de tablas nacionales año-específicas: la paradoja de crisis (menor e0 ⇒ menor YLL por muerte [TEXTO, Devleesschauwer 2020](https://doi.org/10.1007/s00038-020-01430-2)) y la incomparabilidad temporal si la tabla cambia cada año [TEXTO, Haneef 2021](https://doi.org/10.1186/s13690-021-00652-x): "choosing a local life table for each year of estimation may invalidate comparisons over time". Contraargumento ético-comparativo a favor del estándar aspiracional: [Wyper 2022](https://doi.org/10.1007/s10654-022-00846-9). Conclusión: nacional para relevancia de política; TMRLT para comparabilidad; reportar ambas [INFERENCIA].

**Q3. ¿Cómo definen YLL Kilian et al. 2025 y Lemp et al. 2026?**

**Kilian et al. 2025** (Lancet Public Health 10(10):e815–e823, [DOI](https://doi.org/10.1016/S2468-2667(25)00165-3), texto completo): **no define ni reporta YLL** — sus resultados son consumo de alcohol (g/día) y categorías OMS bajo políticas de precios; 0 ocurrencias de "life lost"/"YLL" en el texto completo [TEXTO, hallazgo negativo verificado en XML de PMC]. NO ENCONTRADO: horizonte/tabla/descuento de YLL en Kilian 2025 (no existen). **Lemp et al. 2026** (JAMA Health Forum 7(7):e262348, [DOI](https://doi.org/10.1001/jamahealthforum.2026.2348), texto completo): "YLL was calculated as the difference between a benchmark age of 75 years (following the general practice of most federal and state agencies' YLL calculations) and the age at death and standardized per 100 000 adults" [TEXTO]. Es decir: YPLL con horizonte fijo 75, **sin tabla de vida** (0 ocurrencias de "life table") y **sin descuento** (0 ocurrencias de "discount") [TEXTO, hallazgos negativos verificados].

**Q4. Diferencias documentadas de e0 Chile 2012–2024 entre HMD, INE y WPP 2024 (incl. 2020–2021) y manejo de sensibilidad.**

Brechas máximas absolutas (tabla completa en §4): INE − WPP 2024 entre −0,17 y **+0,54 años** (ambos sexos, 2015–2023); HMD − WPP hasta **+1,26 años** (mujeres 2019: 83,81 vs 82,55) y −0,45 (hombres 2017); HMD − INE +0,15 a +0,34 [ESTIMADO, cálculo propio sobre fuentes citadas]. En 2020–2021 todas las fuentes coinciden en la caída (INE: ambos sexos 80,85→79,14, "disminución absoluta de 1,71 años entre 2019 y 2021" [TEXTO, [INE 2026, p. 14](https://www.ine.gob.cl/docs/default-source/prensa-y-comunicacion/270526-presentaci%C3%B3n-eevv-2023-2025%28p%29version-final.pdf?sfvrsn=e35568ac_2)]; WPP: 80,32→78,88; HMD hombres: −1,27 en 2020 [TEXTO, Aburto 2022, mat. sup.]). Manejo: reportar YLL con las tres series (sin promediar — regla del encargo), declarar la paradoja pandemia (P9) y agregar sensibilidad con tabla fija 2019 [INFERENCIA].

**Q5. ¿Usa la literatura reciente de alcohol-YLL descuento o ponderación por edad?**

No. La convención vigente desde GBD 2010 elimina ambos: "Neither YLLs nor YLDs were age-weighted or discounted" [TEXTO, Murray 2012, [DOI](https://doi.org/10.1016/S0140-6736(12)61689-4), solo resumen]; OMS-GHE: "Age-weighting and time discounting are dropped" [TEXTO, OMS 2024, p. 5](https://cdn.who.int/media/docs/default-source/gho-documents/global-health-estimates/ghe2021_daly_methods.pdf). En los estudios de alcohol revisados: Lemp 2026 sin descuento (0 ocurrencias de "discount" en el texto completo) [TEXTO, verificación negativa]; Castillo-Carniglia 2013 no menciona descuento en el resumen (solo resumen — NO VERIFICADO en texto completo, de pago). El GBD 1990 sí usaba 3 % de descuento y pesos por edad ([OMS 2024, §2.3](https://cdn.who.int/media/docs/default-source/gho-documents/global-health-estimates/ghe2021_daly_methods.pdf)), práctica abandonada — señalar esta contradicción de versiones si se comparan con estudios pre-2010.

---

## 3. Tabla de evidencia

| Referencia | DOI/PMID/URL | Diseño/población | Qué sostiene | Números (página/tabla; unidad; denominador; período; estimado/asumido) | Transportabilidad | Calidad/limitaciones |
|---|---|---|---|---|---|---|
| Martínez R, Soliz P, Caixeta R, Ordunez P. 2019. *Int J Epidemiol* 48(4):1367–1376 | [10.1093/ije/dyy254](https://doi.org/10.1093/ije/dyy254) | Revisión metodológica (OPS) | Definición y ventajas del YLL con SLE; fórmula YLL = D × SLE(a); historia GBD 1990→2013 | Fórmula p. 1368; ventajas (i)–(iv) p. 1368-69; sin valores numéricos propios (asumido: convención) | Alta | Texto completo leído; es una reflexión metodológica, no un estudio empírico |
| Vos T et al. (GBD 2019 DALYs). 2020. *Lancet* 396:1204–1222 | [10.1016/S0140-6736(20)30925-9](https://doi.org/10.1016/S0140-6736(20)30925-9); PMC7567026 | Estudio sistemático global, 204 países, 1990–2019 | Convención GBD 2019 de YLL | "Deaths were multiplied by standard life expectancy at each age to calculate YLLs" (resumen, métodos) (asumido: convención) | Alta (define el estándar de comparación) | Texto completo leído; detalles de la tabla en apéndice |
| Murray CJL et al. (GBD 2019 RF). 2020. *Lancet* 396:1223–1249 | [10.1016/S0140-6736(20)30752-2](https://doi.org/10.1016/S0140-6736(20)30752-2); PMC7566194 | Comparative risk assessment, 87 riesgos | Atribución: PAF × resultado | "computed by multiplying population attributable fractions (PAFs) by the relevant outcome quantity for each age-sex-location-year" (resumen) | Alta — misma operación que el proyecto (YLL × FAA) | Texto completo leído |
| Wang H et al. (GBD 2019 Demographics). 2020. *Lancet* 396:1160–1203 | [10.1016/S0140-6736(20)30977-6](https://doi.org/10.1016/S0140-6736(20)30977-6); PMC7566045 | Demografía GBD, 1950–2019 | Base demográfica del estándar GBD; citado por GBD 2021 como fuente de la "standard life expectancy" | GBD 2021 ref. 10 apunta a este paper para la esperanza de vida estándar (ver Naghavi 2024) | Alta | Texto completo leído; la construcción explícita de la TMRLT está en apéndice/GHDx |
| GBD Collaborative Network. 2021. *GBD 2019 Reference Life Table (TMRLT)*. IHME | [10.6069/1D4Y-YQ37](https://doi.org/10.6069/1D4Y-YQ37); [registro GHDx](https://ghdx.healthdata.org/record/ihme-data/gbd-2019-reference-life-table) | Dataset de referencia (tabla de vida) | Definición y construcción de la TMRLT | "constructed based on the lowest observed age-specific mortality rates by location and sex across all estimation years from all locations with populations over 5 million in 2016"; e(x) para 0 a 95+ en intervalos quinquenales (asumido: estándar) | Alta | Página GHDx leída completa; dataset requiere descarga; e0 = 88,9 verificado vía Ballin 2022 y apéndice GBD 2021 (extracto) |
| Naghavi M et al. (GBD 2021 COD). 2024. *Lancet* 403(10440):2100–2132 | [10.1016/S0140-6736(24)00367-2](https://doi.org/10.1016/S0140-6736(24)00367-2); PMC11126520 | 288 causas de muerte, 204 países, 1990–2021 | GBD 2021 mantiene la tabla de referencia tipo GBD 2019 | "Standard life expectancy is calculated from the lowest age-specific mortality rate between countries" (métodos, cita a Wang 2020); apéndice 1 §6.3: "lowest observed age-specific mortality rates… locations with total populations greater than 5 million in 2016" (extracto de búsqueda del PDF oficial) | Alta | Texto completo leído; apéndice citado vía extracto (acceso directo bloqueado, HTTP 403) |
| Murray CJL et al. (GBD 2010 DALYs). 2012. *Lancet* 380(9859):2197–2223 | [10.1016/S0140-6736(12)61689-4](https://doi.org/10.1016/S0140-6736(12)61689-4); PMID 23245608 | GBD 2010, 291 causas | Fin de descuento y ponderación por edad en GBD | "Neither YLLs nor YLDs were age-weighted or discounted" (resumen) | Alta | **Solo resumen** leído |
| OMS. 2024. *WHO methods and data sources for global burden of disease estimates 2000–2021 (DALY)*. WHO/DDI/DNA/GHE/2024.3 | [PDF oficial](https://cdn.who.int/media/docs/default-source/gho-documents/global-health-estimates/ghe2021_daly_methods.pdf) | Documento técnico oficial (GHE 2021, mayo 2024) | Función de pérdida OMS-GHE (frontera WPP 2024, 2050); historia GBD 1990/2010; sin descuento | Tabla 2.1, p. 9: pérdida neonatal GBD 1990 (con descuento/pesos) 33,27/33,38; GBD 1990 sin pesos 79,94/82,43; GBD 2010 86,01; OMS GHE **92,65** (años perdidos por muerte neonatal; asumido: estándar); §2.2: e0 frontera 92,7 (resumen redondea a 90) | Media-Alta | PDF leído completo; la discrepancia 90 vs 92,7 es de redondeo interno del documento |
| Devleesschauwer B, McDonald SA, Speybroeck N, Wyper GMA. 2020. *Int J Public Health* 65(6):719–720 | [10.1007/s00038-020-01430-2](https://doi.org/10.1007/s00038-020-01430-2); PMC7370635 | Comentario metodológico (COVID-19) | Paradoja de la tabla nacional año-específica; argumento a favor de tabla estándar aspiracional | "Using a national life table furthermore creates a paradox by which increased mortality risks… could cause life expectancy to go down, which could result in a contradictory reduction in estimates of YLL" (p. 719) | Alta — directamente aplicable a Chile 2020–2021 | Texto completo leído; comentario, no evaluación empírica |
| Wyper GMA, Devleesschauwer B, Mathers CD, McDonald SA, Speybroeck N. 2022. *Eur J Epidemiol* 37(2):215–216 | [10.1007/s10654-022-00846-9](https://doi.org/10.1007/s10654-022-00846-9); PMC8894819 | Comentario metodológico | Defensa del estándar aspiracional por equidad y comparabilidad | "the counterfactual to be applied in the estimation of YLL is that of an ideal, aspirational, standard based upon desirably low mortality risks" | Media-Alta | Texto completo leído; comentario |
| Haneef R et al. 2021. *Arch Public Health* 79 | [10.1186/s13690-021-00652-x](https://doi.org/10.1186/s13690-021-00652-x); PMC8262070 | Recomendaciones InfAct (UE) para estudios nacionales de carga de enfermedad | Advertencia sobre tablas locales año-específicas | "choosing a local life table for each year of estimation may invalidate comparisons over time unless the life table is retrospectively applied to previous years" | Alta | Texto completo leído; guía de planificación, no estudio de resultados |
| Ballin M et al. 2022. *BMJ Open* 12(11):e066258 | [10.1136/bmjopen-2022-066258](https://doi.org/10.1136/bmjopen-2022-066258); PMC9692138 | Cohorte emparejada, residentes de hogares de ancianos suecos (n = 3 604 + 3 731) | Valores puntuales de la TMRLT; cautela de sobreestimación en poblaciones frágiles | TMRLT: "88.9 years at birth; 9.99 years at age 85; 7.62 at age 90; 5.92 at age 95" (discusión); estimado por los autores: sobreestimación 5–10× del YLL en su población | Media (el punto sobre fragilidad aplica a poblaciones muy seleccionadas) | Texto completo leído; los valores TMRLT se citan como referencia, no como resultado del estudio |
| Lemp JM et al. 2026. *JAMA Health Forum* 7(7):e262348 | [10.1001/jamahealthforum.2026.2348](https://doi.org/10.1001/jamahealthforum.2026.2348); PMC13428287 | Microsimulación (SIMAH), EE. UU. | YPLL-75 como métrica de YLL; sin tabla de vida ni descuento | Cita verbatim en Q3; referencias de respaldo 13–15 = Missouri DHSS, SHADAC, MMWR 2024 (práctica de agencias) | Media — convención de agencias de EE. UU. | Texto completo leído |
| Kilian C et al. 2025. *Lancet Public Health* 10(10):e815–e823 | [10.1016/S2468-2667(25)00165-3](https://doi.org/10.1016/S2468-2667(25)00165-3); PMC12478644 | Microsimulación (SIMAH), EE. UU., políticas de precios por bebida | **No aplica a YLL**: resultados en g/día y categorías OMS | 0 ocurrencias de "life lost"/"YLL"/"life expectancy" en el texto completo (hallazgo negativo verificado) | Baja para la decisión D-a | Texto completo leído |
| Probst C et al. 2023. *Am J Epidemiol* 192(5):690–702 | [10.1093/aje/kwad018](https://doi.org/10.1093/aje/kwad018); PMID 36702471 | Protocolo SIMAH (EE. UU.) | Marco de la etapa siguiente del proyecto (microsimulación; integra mortalidad por causa atribuible a alcohol por edad/sexo/NES) | Sin números de YLL (resumen) | Alta (diseño de la siguiente etapa) | **Solo resumen** leído |
| Aburto JM et al. 2022. *Int J Epidemiol* 51(1):63–74 + material suplementario | [10.1093/ije/dyab207](https://doi.org/10.1093/ije/dyab207); PMC8500096 | 37 países, datos HMD y similares, 2015–2020 (Chile desde 2016) | Serie e0 Chile basada en HMD 2016–2020; caída 2020 | File008, hoja "Life expectancy at birth": Chile 2019 H 78,22 / M 83,81; 2020 H 76,94 / M 82,96; cambio 2019→2020: H **−1,27** (−1,42; −1,14), M **−0,85** (−1,01; −0,68) (años; ESTIMADO por los autores sobre HMD) | Alta — es la columna HMD de la tabla §4 | Texto completo + suplementario leídos; Chile sin dato 2015 |
| Castillo-Carniglia A, Kaufman JS, Pino P. 2013. *Alcohol Alcohol* 48(6):729–736 | [10.1093/alcalc/agt066](https://doi.org/10.1093/alcalc/agt066); PMID 23831731 | Estudio de atribución (FAA), Chile 2009, ≥15 años | Precedente nacional de YPLL atribuible al alcohol | 8 753 muertes atribuibles (IC95 % 6 257–11 584; 9,8 % de todas las muertes); **195 475 YPLL** (IC95 % 164 287–227 726; 21,5 % del YPLL total) (Chile, 2009; ESTIMADO por los autores) | Alta (estudio chileno) | **Solo resumen**; umbral del YPLL NO ENCONTRADO (texto completo de pago) |
| Mena G, Aburto JM. 2022. *BMJ Open* 12(8):e059201 | [10.1136/bmjopen-2021-059201](https://doi.org/10.1136/bmjopen-2021-059201); PMID 35985781 | Transversal demográfico, zonas urbanas de Chile, 2020 | Evidencia chilena de caída de e0 en 2020 con datos INE | Sin números extraídos (solo resumen) | Media (solo zonas urbanas) | **Solo resumen** leído |
| INE. 2024/2025. *Anuario de Estadísticas Vitales 2022* | [PDF oficial](https://www.ine.gob.cl/docs/default-source/nacimientos-matrimonios-y-defunciones/publicaciones-y-anuarios/anuarios-de-estad%C3%ADsticas-vitales/anuario-de-estad%C3%ADsticas-vitales-2022.pdf?sfvrsn=88100883_4) | Estadísticas vitales oficiales Chile | Serie oficial nacional e0 2015–2022 | Gráfico 29, p. 51: ver tabla §4; nota metodológica: 2015–2021 ambos sexos = ponderación por población de cada sexo; 2022 = tabla de mortalidad observada (ESTIMADO oficial) | Alta — fuente oficial | Extractos verbatim vía búsqueda + texto del anuario; base Censo 2017 |
| INE. 2026-05-27. *Presentación "Las Estadísticas Vitales" (EEVV 2023–2025(p))* | [PDF oficial](https://www.ine.gob.cl/docs/default-source/prensa-y-comunicacion/270526-presentaci%C3%B3n-eevv-2023-2025%28p%29version-final.pdf?sfvrsn=e35568ac_2) | Presentación oficial INE | Serie e0 2010–2025(p) con valores revisados | p. 14: 2010 (78,45/75,34/81,44); 2019 (80,85/78,06/83,56); 2020 (79,81/76,74/82,81); 2021 (79,14/76,14/82,08); 2022 (79,72/76,81/82,59); 2023 (81,10/78,33/83,78); 2025(p) (81,46/78,77/84,07); 2024(p) sin etiqueta legible; "disminución absoluta de 1,71 años entre 2019 y 2021" (ambos sexos) | Alta — versión más reciente; contradice/revisa el provisional 2023 (81,39→81,10) | PDF leído completo (24 pp.); valores por sexo leídos de etiquetas del gráfico (posición verificada por coordenadas) |
| UN DESA Population Division. 2024. *World Population Prospects 2024* (Rev.1, julio 2024) | [Portal WPP](https://population.un.org/wpp/); archivo `WPP2024_GEN_F01_DEMOGRAPHIC_INDICATORS_COMPACT.xlsx` (POP/DB/WPP/Rev.2024/GEN/F01/Rev.1) | Estimaciones demográficas oficiales ONU | Columna WPP 2024 de la tabla §4 | Chile e0 2012–2023 (hoja "Estimates, 1950–2023") y 2024 (hoja "Medium variant"); valores exactos en §4 (ESTIMADO por ONU con modelos) | Alta | Archivo leído directamente; coincide al centésimo con WDI del Banco Mundial (que usa UN WPP como fuente) |
| HMD. *Methods Protocol for the Human Mortality Database*, Version 6 (última revisión 2025-08-05) | [PDF oficial](https://www.mortality.org/File/GetDocument/Public/Docs/MethodsProtocolV6.pdf) | Protocolo metodológico oficial | Método de las tablas de período HMD (m_x→q_x; a0 Andreev-Kingkade; suavizado Kannisto ≥80; e_x = T_x/l_x, ec. 83) | "Last Revised: August 5, 2025 (Version 6)"; ecuaciones 74–83 | Alta — define la tabla primaria propuesta | Extractos verbatim del PDF oficial vía búsqueda (documento de 78 pp. no leído íntegro) |

---

## 4. Evidencia chilena y latinoamericana

**(a) Chilena.** (i) Castillo-Carniglia et al. 2013 estimaron para Chile 2009 (≥15 años) 8 753 muertes atribuibles al alcohol (9,8 % del total) y **195 475 YPLL atribuibles (21,5 % del YPLL nacional)** con FAA basadas en encuesta nacional de drogas + consumo per cápita ([DOI](https://doi.org/10.1093/alcalc/agt066), solo resumen) — precedente nacional directo del diseño del proyecto, con YPLL de umbral no identificado en el resumen (NO ENCONTRADO). (ii) INE publica la serie oficial nacional de e0 (Anuario 2022; presentación EEVV 27-05-2026) con la caída pandémica documentada: "en 2021 la e(0) fue de 79,14 años para ambos sexos, una disminución absoluta de 1,71 años entre 2019 y 2021" [TEXTO, INE 2026, p. 14]. (iii) Aburto et al. 2022 (con datos HMD para Chile desde 2016) cuantificaron la caída 2020: hombres −1,27 años, mujeres −0,85 [TEXTO, material suplementario File008]. (iv) Mena & Aburto 2022 documentaron el impacto desigual de 2020 en zonas urbanas de Chile con datos INE ([DOI](https://doi.org/10.1136/bmjopen-2021-059201), solo resumen).

**(b) Latinoamericana.** NO ENCONTRADO: no se identificaron guías latinoamericanas regionales sobre elección de tabla de vida para YLL. El documento metodológico de Martínez et al. 2019 es de autores OPS/OMS (aplicable a la región; clasificado aquí como guía internacional con autoría regional).

**(c) Internacional y (d) convenciones (GBD/OMS):** tablas §1–§3.

### Tabla de e0 de Chile por fuente (años; consulta de todas las fuentes: 2026-10-07)

| Año | Sexo | HMD (vía Aburto 2022, mat. sup.) | INE (Anuario 2022 / presentación 2026) | WPP 2024 (Rev.1) | Versión / notas |
|---|---|---|---|---|---|
| 2012 | AS / H / M | n/d | NO ENCONTRADO (serie oficial publicada parte en 2015) | 79,22 / 76,90 / 81,51 | WPP: hoja "Estimates" |
| 2013 | AS / H / M | n/d | NO ENCONTRADO | 79,55 / 77,30 / 81,76 | " |
| 2014 | AS / H / M | n/d | NO ENCONTRADO | 79,71 / 77,41 / 81,98 | " |
| 2015 | AS / H / M | n/d (Chile entra a HMD-series de ese paper en 2016) | 79,97 / 77,00 / 82,84 | 80,01 / 77,69 / 82,30 | INE: Anuario 2022, Gráf. 29, p. 51 |
| 2016 | AS / H / M | n/d / 77,71 / 83,39 | 80,27 / 77,41 / 83,05 | 80,30 / 78,01 / 82,55 | HMD: IC95 % H (77,60–77,82), M (83,27–83,51) |
| 2017 | AS / H / M | n/d / 77,95 / 83,46 | 80,44 / 77,62 / 83,18 | 80,61 / 78,40 / 82,78 | " |
| 2018 | AS / H / M | n/d / 78,28 / 83,85 | 80,77 / 77,96 / 83,51 | 80,56 / 78,32 / 82,78 | " |
| 2019 | AS / H / M | n/d / 78,22 / 83,81 | 80,85 / 78,06 / 83,56 | 80,32 / 78,10 / 82,55 | Brecha máxima HMD–WPP mujeres: **1,26 años** |
| 2020 | AS / H / M | n/d / 76,94 / 82,96 | 79,81 / 76,74 / 82,81 | 79,35 / 76,76 / 82,03 | Año pandemia |
| 2021 | AS / H / M | n/d (serie del paper termina en 2020) | 79,14 / 76,14 / 82,08 | 78,88 / 76,35 / 81,49 | Mínimo pandémico en las tres fuentes |
| 2022 | AS / H / M | n/d | 79,72 / 76,81 / 82,59 | 79,18 / 76,83 / 81,57 | INE 2022: ambos sexos observado en tabla de mortalidad |
| 2023 | AS / H / M | n/d | 81,10 / 78,33 / 83,78 | 81,17 / 79,24 / 83,08 | INE: presentación 27-05-2026, p. 14 (revisa el provisional 81,39 del boletín marzo-2025) |
| 2024 | AS / H / M | n/d | NO ENCONTRADO (punto 2024(p) sin etiqueta legible en el gráfico, p. 14) | 81,36 / 79,45 / 83,23 | WPP: hoja "Medium variant" (proyección) |

AS = ambos sexos; H = hombres; M = mujeres; n/d = no disponible en la fuente consultada. **Versiones consultadas:** HMD valores = datos suplementarios de Aburto et al. 2022 (File008, hoja "Life expectancy at birth"; descarga directa de HMD bloqueada por muro de registro); INE = Anuario de Estadísticas Vitales 2022 (PDF, consultado 2026-10-07) y presentación EEVV 2023–2025(p) del 27-05-2026 (PDF, consultado 2026-10-07); WPP = WPP 2024 Online Edition Rev.1 (julio 2024), archivo Excel oficial descargado 2026-10-07. La serie WDI del Banco Mundial (fuente: UN WPP; última actualización 2026-07-13) coincide al centésimo con estos valores WPP 2024. Los valores INE 2015–2021 de ambos sexos son ponderaciones de las series por sexo (nota al Gráf. 29 del Anuario 2022) — no promediar con tablas de ambos sexos calculadas directamente.

![Chile: esperanza de vida al nacer por fuente, 2012–2024](figura_e0_chile_fuentes.png)

---

## 5. Recomendación

**Métrica primaria:** YLL con tabla de vida de período nacional — **HMD Chile** (opción A), calculado como YLL(c,s,a,t) = D(c,s,a,t) × e_x(tabla HMD del año), sin descuento ni ponderación por edad (P1, P2, P6). Razones: coherencia interna con las defunciones DEIS (misma estadística vital subyacente), interpretabilidad para política sanitaria chilena, y conformidad con la fórmula estándar de la literatura (Martínez 2019; Vos 2020).

**Tabla/métrica secundaria de comparabilidad:** YLL con **TMRLT GBD 2019** (e0 = 88,9) para comparar con GBD/OMS y con la literatura internacional de alcohol; declarar explícitamente que es un estándar aspiracional y que su magnitud será sistemáticamente mayor (~+26 % según el piloto del proyecto).

**Sensibilidades a reportar (obligatorias):** (1) **WPP 2024** (serie anual completa 2012–2024 ya extraída en §4); (2) **INE** oficial (2015–2023); (3) **tabla fija 2019** (prepandémica) aplicada a todos los años, para neutralizar la paradoja documentada de la tabla año-específica en 2020–2021 (Devleesschauwer 2020; Haneef 2021); (4) opcional: **YPLL-75** (Lemp 2026) y/o YPLL con el umbral del estudio chileno previo, para comparabilidad con esas tradiciones.

**Fuerza de la recomendación: ALTA** para A + D + sensibilidad con tabla fija 2019; **MEDIA** para incluir YPLL-75 (depende de la audiencia).

**Qué la cambiaría:** (i) si el artículo objetivo fuera una revista/audiencia GBD-internacional como vehículo principal, promover la TMRLT a primaria (opción B); (ii) si HMD interrumpiera la serie de Chile o la calidad de las defunciones por edad se degradara (p. ej., aumento de edad no especificada), migrar la primaria a WPP 2024/INE; (iii) si apareciera una guía chilena/latinoamericana oficial de carga de enfermedad con convención distinta (hoy NO ENCONTRADO), adoptarla como sensibilidad adicional.

---

## 6. Methods paragraphs (English)

**Option A (primary) — YLL with national period life tables.** We estimated years of life lost (YLL) as the number of deaths by cause, sex, age and year multiplied by the remaining life expectancy at the age of death from Chilean period life tables published in the Human Mortality Database, which are constructed from national vital registration using standardized methods (Andreev–Kingkade separation factors and Kannisto old-age smoothing) (Martinez et al., 2019; Wilmoth et al., 2025). Alcohol-attributable YLL were obtained by multiplying cause-specific YLL by alcohol-attributable fractions, consistent with comparative risk assessment practice (Murray et al., 2020). No discounting or age weighting was applied, following current GBD and WHO convention (Murray et al., 2012; WHO, 2024). Because year-specific national life tables can yield counterintuitive reductions in YLL during mortality crises such as the COVID-19 pandemic (Devleesschauwer et al., 2020; Haneef et al., 2021), we report sensitivity analyses using a fixed 2019 pre-pandemic life table, WPP 2024 tables, and the GBD 2019 reference life table (GBD Collaborative Network, 2021).

**Option C (secondary/comparability) — YPLL to a fixed reference age.** For comparability with United States federal and state agency practice and with recent alcohol-policy microsimulation studies, we additionally report years of potential life lost computed as the difference between a fixed benchmark age of 75 years and age at death, standardized per 100 000 adults (Lemp et al., 2026). This fixed-cutoff metric is not used as the primary measure because arbitrary age cut-offs are not methodologically justifiable and exclude deaths at older ages (Martinez et al., 2019); in our data this specification reduced total YLL by about 8% and by about one fifth in the 60–65 age group relative to the life-table approach (project pilot results). A Chilean precedent exists: alcohol-attributable mortality in 2009 was reported as YPLL (Castillo-Carniglia et al., 2013). Where a Chilean-historical benchmark is required, the fixed-cutoff series can be recomputed with alternative thresholds as a further sensitivity analysis; results from the benchmark-75 specification are labelled YPLL-75 throughout to distinguish them from life-table YLL.

---

## 7. BibTeX

```bibtex
@article{martinez2019yll,
  author = {Martinez, Ramon and Soliz, Patricia and Caixeta, Roberta and Ordunez, Pedro},
  title = {Reflection on modern methods: years of life lost due to premature mortality---a versatile and comprehensive measure for monitoring population health},
  journal = {International Journal of Epidemiology},
  year = {2019},
  volume = {48},
  number = {4},
  pages = {1367--1376},
  doi = {10.1093/ije/dyy254}
}
@article{vos2020gbd,
  author = {Vos, Theo and others},
  title = {Global burden of 369 diseases and injuries in 204 countries and territories, 1990--2019: a systematic analysis for the Global Burden of Disease Study 2019},
  journal = {The Lancet},
  year = {2020},
  volume = {396},
  number = {10258},
  pages = {1204--1222},
  doi = {10.1016/S0140-6736(20)30925-9}
}
@article{murray2020gbdrf,
  author = {Murray, Christopher J. L. and others},
  title = {Global burden of 87 risk factors in 204 countries and territories, 1990--2019: a systematic analysis for the Global Burden of Disease Study 2019},
  journal = {The Lancet},
  year = {2020},
  volume = {396},
  number = {10258},
  pages = {1223--1249},
  doi = {10.1016/S0140-6736(20)30752-2}
}
@article{wang2020gbddem,
  author = {Wang, Haidong and others},
  title = {Global age-sex-specific fertility, mortality, healthy life expectancy (HALE), and population estimates in 204 countries and territories, 1950--2019: a comprehensive demographic analysis for the Global Burden of Disease Study 2019},
  journal = {The Lancet},
  year = {2020},
  volume = {396},
  number = {10258},
  pages = {1160--1203},
  doi = {10.1016/S0140-6736(20)30977-6}
}
@misc{gbd2021tmrlt,
  author = {{Global Burden of Disease Collaborative Network}},
  title = {Global Burden of Disease Study 2019 (GBD 2019) Reference Life Table},
  year = {2021},
  publisher = {Institute for Health Metrics and Evaluation (IHME), Seattle},
  doi = {10.6069/1D4Y-YQ37}
}
@article{naghavi2024gbd,
  author = {Naghavi, Mohsen and others},
  title = {Global burden of 288 causes of death and life expectancy decomposition in 204 countries and territories and 811 subnational locations, 1990--2021: a systematic analysis for the Global Burden of Disease Study 2021},
  journal = {The Lancet},
  year = {2024},
  volume = {403},
  number = {10440},
  pages = {2100--2132},
  doi = {10.1016/S0140-6736(24)00367-2}
}
@article{murray2012gbd,
  author = {Murray, Christopher J. L. and others},
  title = {Disability-adjusted life years (DALYs) for 291 diseases and injuries in 21 regions, 1990--2010: a systematic analysis for the Global Burden of Disease Study 2010},
  journal = {The Lancet},
  year = {2012},
  volume = {380},
  number = {9859},
  pages = {2197--2223},
  doi = {10.1016/S0140-6736(12)61689-4}
}
@techreport{who2024ghe,
  author = {{World Health Organization}},
  title = {WHO methods and data sources for global burden of disease estimates 2000--2021: Technical Paper WHO/DDI/DNA/GHE/2024.3},
  institution = {World Health Organization},
  year = {2024},
  url = {https://cdn.who.int/media/docs/default-source/gho-documents/global-health-estimates/ghe2021_daly_methods.pdf}
}
@article{devleesschauwer2020yll,
  author = {Devleesschauwer, Brecht and McDonald, Scott A. and Speybroeck, Niko and Wyper, Grant M. A.},
  title = {Valuing the years of life lost due to COVID-19: the differences and pitfalls},
  journal = {International Journal of Public Health},
  year = {2020},
  volume = {65},
  number = {6},
  pages = {719--720},
  doi = {10.1007/s00038-020-01430-2}
}
@article{wyper2022yll,
  author = {Wyper, Grant M. A. and Devleesschauwer, Brecht and Mathers, Colin D. and McDonald, Scott A. and Speybroeck, Niko},
  title = {Years of life lost methods must remain fully equitable and accountable},
  journal = {European Journal of Epidemiology},
  year = {2022},
  volume = {37},
  number = {2},
  pages = {215--216},
  doi = {10.1007/s10654-022-00846-9}
}
@article{haneef2021bod,
  author = {Haneef, Romana and Schmidt, J{\"u}rgen and Gallay, Anne and Devleesschauwer, Brecht and Grant, Ian and Rommel, Alexander and Wyper, Grant M. A. and Van Oyen, Herman and Hilderink, Henk and Ziese, Thomas and Newton, John},
  title = {Recommendations to plan a national burden of disease study},
  journal = {Archives of Public Health},
  year = {2021},
  volume = {79},
  number = {1},
  doi = {10.1186/s13690-021-00652-x}
}
@article{ballin2022ltc,
  author = {Ballin, Marcel and others},
  title = {Time-varying risk of death after SARS-CoV-2 infection in Swedish long-term care facility residents: a matched cohort study},
  journal = {BMJ Open},
  year = {2022},
  volume = {12},
  number = {11},
  pages = {e066258},
  doi = {10.1136/bmjopen-2022-066258}
}
@article{lemp2026simah,
  author = {Lemp, Julia M. and Kilian, Carolin and Kou, Xinyi and Buckley, Charlotte and Llamosas-Falc{\'o}n, Laura and Zhu, Yachen and Rehm, J{\"u}rgen and Mulia, Nina and Purshouse, Robin and Probst, Charlotte},
  title = {Estimated Effects of Alcohol Tax Policies on Health and Health Equity in the US},
  journal = {JAMA Health Forum},
  year = {2026},
  volume = {7},
  number = {7},
  pages = {e262348},
  doi = {10.1001/jamahealthforum.2026.2348}
}
@article{kilian2025simah,
  author = {Kilian, Carolin and Buckley, Charlotte and Lemp, Julia M. and Kou, Xinyi and Kerr, William C. and Mulia, Nina and Purshouse, Robin C. and Rehm, J{\"u}rgen and Probst, Charlotte},
  title = {Targeting alcohol use in high-risk population groups: a US microsimulation study of beverage-specific pricing policies},
  journal = {The Lancet Public Health},
  year = {2025},
  volume = {10},
  number = {10},
  pages = {e815--e823},
  doi = {10.1016/S2468-2667(25)00165-3}
}
@article{probst2023simah,
  author = {Probst, Charlotte and Buckley, Charlotte and Lasserre, Aur{\'e}lie M. and Kerr, William C. and Mulia, Nina and Puka, Klajdi and Purshouse, Robin C. and Ye, Yu and Rehm, J{\"u}rgen},
  title = {Simulation of Alcohol Control Policies for Health Equity (SIMAH) Project: Study Design and First Results},
  journal = {American Journal of Epidemiology},
  year = {2023},
  volume = {192},
  number = {5},
  pages = {690--702},
  doi = {10.1093/aje/kwad018}
}
@article{aburto2022le,
  author = {Aburto, Jos{\'e} Manuel and Sch{\"o}ley, Jonas and Kashnitsky, Ilya and Zhang, Luyin and Rahal, Charles and Missov, Trifon I. and Mills, Melinda C. and Dowd, Jennifer B. and Kashyap, Ridhi},
  title = {Quantifying impacts of the COVID-19 pandemic through life-expectancy losses: a population-level study of 29 countries},
  journal = {International Journal of Epidemiology},
  year = {2022},
  volume = {51},
  number = {1},
  pages = {63--74},
  doi = {10.1093/ije/dyab207}
}
@article{castillocarniglia2013chile,
  author = {Castillo-Carniglia, {\'A}lvaro and Kaufman, Jay S. and Pino, Paulina},
  title = {Alcohol-attributable mortality and years of potential life lost in Chile in 2009},
  journal = {Alcohol and Alcoholism},
  year = {2013},
  volume = {48},
  number = {6},
  pages = {729--736},
  doi = {10.1093/alcalc/agt066}
}
@article{mena2022chile,
  author = {Mena, Gonzalo and Aburto, Jos{\'e} Manuel},
  title = {Unequal impact of the COVID-19 pandemic in 2020 on life expectancy across urban areas in Chile: a cross-sectional demographic study},
  journal = {BMJ Open},
  year = {2022},
  volume = {12},
  number = {8},
  pages = {e059201},
  doi = {10.1136/bmjopen-2021-059201}
}
@misc{ine2024anuario,
  author = {{Instituto Nacional de Estad{\'i}sticas (INE), Chile}},
  title = {Anuario de Estad{\'i}sticas Vitales, per{\'i}odo de informaci{\'o}n 2022},
  year = {2024},
  url = {https://www.ine.gob.cl/docs/default-source/nacimientos-matrimonios-y-defunciones/publicaciones-y-anuarios/anuarios-de-estadisticas-vitales/anuario-de-estadisticas-vitales-2022.pdf}
}
@misc{ine2026eevv,
  author = {{Instituto Nacional de Estad{\'i}sticas (INE), Chile}},
  title = {Las Estad{\'i}sticas Vitales (EEVV 2023--2025(p)): presentaci{\'o}n 27-05-2026},
  year = {2026},
  url = {https://www.ine.gob.cl/docs/default-source/prensa-y-comunicacion/270526-presentacion-eevv-2023-2025(p)version-final.pdf}
}
@misc{undesa2024wpp,
  author = {{United Nations, Department of Economic and Social Affairs, Population Division}},
  title = {World Population Prospects 2024, Online Edition (Rev.1): Demographic Indicators Compact (POP/DB/WPP/Rev.2024/GEN/F01/Rev.1)},
  year = {2024},
  url = {https://population.un.org/wpp/}
}
@misc{hmd2025protocol,
  author = {Wilmoth, John R. and Andreev, Kirill and Jdanov, Dmitri and Glei, Dana A. and Riffe, Tim and others},
  title = {Methods Protocol for the Human Mortality Database, Version 6 (last revised August 5, 2025)},
  institution = {University of California, Berkeley, and Max Planck Institute for Demographic Research, Rostock},
  year = {2025},
  url = {https://www.mortality.org/File/GetDocument/Public/Docs/MethodsProtocolV6.pdf}
}
```

---

## 8. NO ENCONTRADO / NO VERIFICADO y discrepancias

**NO ENCONTRADO (con descripción de la búsqueda):**

1. **Datos HMD Chile directos (archivos E0per/tbl de vida).** mortality.org exige registro; las URL de datos devuelven la página de login. Búsquedas: sitio HMD país Chile (página leída, con advertencia de calidad de datos), intentos de descarga directa (2026-10-07). Mitigación: serie HMD-Chile 2016–2020 tomada del material suplementario de Aburto et al. 2022 (descargado vía Europe PMC), que documenta e0 por sexo con IC95 %.
2. **Umbral de edad del YPLL de Castillo-Carniglia et al. 2013.** El resumen (Europe PMC, PMID 23831731) no lo declara; el texto completo (Oxford Academic) es de pago. Búsquedas: PubMed (PMID corregido tras fallo inicial), Europe PMC, acceso directo OUP (403). Marcado "(solo resumen)" donde se usa.
3. **e0 anual oficial INE para 2012–2014.** Revisados: Anuario de Estadísticas Vitales 2020 (PDF completo, 195 pp.), Anuario 2021 (índice; la Tabla 5 "Esperanza de vida al nacer, años seleccionados", p. 55 impresa, no fue legible por corrupción del PDF en la descarga por rangos), Anuario 2022 (Gráf. 29 parte en 2015), presentación INE 27-05-2026 (solo 2010 etiquetado antes de 2019). Como contexto quinquenal existe la serie DEIS-MINSAL 2010–2015: 79,10 (AS) / 76,12 (H) / 82,20 (M) ([repositorio DEIS](https://repositoriodeis.minsal.cl/deis/ev/esperanza_de_vida/esperanza_de_vida_por_quinquenios_sexo.htm), consultado 2026-10-07; base: proyecciones INE 2004 — versión antigua, usar con cautela).
4. **Valor exacto INE de e0 para 2024(p).** El gráfico de la presentación 27-05-2026 (p. 14) incluye el punto 2024(p) pero sin etiqueta numérica legible (verificado por posición de etiquetas); 2025(p) sí está etiquetado (81,46/78,77/84,07).
5. **Definición de YLL en Kilian et al. 2025.** No existe: el estudio no usa YLL (verificado en texto completo; 0 ocurrencias de "life lost", "YLL", "life expectancy"). Sus resultados son gramos de alcohol/día y categorías de consumo OMS.
6. **Apéndice 1 de Naghavi et al. 2024 (GBD 2021).** Acceso directo al PDF del apéndice bloqueado por thelancet.com (HTTP 403); la §6.3 ("Years of life lost calculation") se cita desde el extracto verbatim recuperado por el buscador del PDF oficial: "we used the lowest observed age-specific mortality rates by location and sex across all estimation years from locations with total populations greater than 5 million in 2016 to establish a theoretical minimum risk reference life table".
7. **Guía latinoamericana regional de tablas de vida para YLL.** No identificada en las búsquedas realizadas.

**NO VERIFICADO / advertencias de versión:**

8. **Descuento en Castillo-Carniglia 2013:** no mencionado en el resumen; no verificable sin el texto completo (de pago).
9. **Contradicción interna del documento OMS-GHE 2024:** el resumen de métodos redondea la frontera a "90 años" mientras §2.2 y la Tabla 2.1 fijan 92,7/92,65; se adopta 92,65 (Tabla 2.1) como valor de referencia.
10. **INE 2023 revisado vs provisional:** el boletín provisional (marzo 2025) reportó 2023(p) = 81,39/78,70/84,02; la presentación de 27-05-2026 reporta 2023 = 81,10/78,33/83,78. Se usa la versión más reciente (2026); ambas se listan por separado (no se promedian).
11. **WDI del Banco Mundial vs WPP 2024:** los valores WDI coinciden al centésimo con el archivo oficial WPP 2024 Rev.1 para Chile 2012–2024; se cita el archivo WPP como fuente primaria (descargado 2026-10-07).

**Discrepancias de DOI / referencias candidatas del encargo:** las cinco referencias candidatas fueron verificadas **sin discrepancias**: GBD 2019 TMRLT (DOI 10.6069/1D4Y-YQ37, registro GHDx, IHME 2021); HMD Methods Protocol v6 (vigente, última revisión 2025-08-05); UN WPP 2024 (Online Edition Rev.1, julio 2024); Lemp et al. 2026 (JAMA Health Forum 7(7):e262348, DOI 10.1001/jamahealthforum.2026.2348, publicado 2026-07-31); Kilian et al. 2025 (Lancet Public Health 10(10):e815–e823, DOI 10.1016/S2468-2667(25)00165-3). **Corrección propia respecto a notas de trabajo anteriores:** la referencia sobre la "paradoja de la tabla nacional" es Devleesschauwer et al. 2020 (Int J Public Health 65:719–720), no "Wyper 2020/2021" (Wyper es cuarto autor); y el comentario afín es Wyper et al. **2022** (Eur J Epidemiol 37:215–216), año 2022 y no 2021.

---

*Nota de alcance: contenido con fines exclusivamente informativos para la decisión metodológica del proyecto FONDECYT 1240138; no constituye asesoría estadística oficial ni sanitaria. Los cálculos de brechas de e0 entre fuentes son estimaciones propias derivadas de las fuentes citadas; no implican efecto causal ni juicio sobre la calidad de cada serie.*
