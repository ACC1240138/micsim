# Brief de evidencia para la microsimulación de alcohol en Chile (FONDECYT 1240138): escalamiento del programa DIR, mortalidad y AVPP

**Respuesta principal:** El precedente más cercano y mejor documentado para el Objetivo 2 es Lemp et al. (2026, *JAMA Health Forum*). Este trabajo confirma tres decisiones de la propuesta: aplicar el efecto −20 g/semana de Kaner 2018 solo a las intervenciones breves (IB) *nuevas*, usar RD = −0,07 para HED y anclar la mortalidad de referencia a las estadísticas vitales. También corrige dos supuestos: (i) un escenario de "solo tamizaje" no produce un efecto distinguible de cero, y (ii) la persistencia de efecto "4 años completos y luego decaimiento lineal hasta 10 años" no tiene respaldo en ensayos de IB breves; el único ensayo con mantención a 48 meses (Project TrEAT) usó una intervención más intensa que la del DIR.

## TL;DR
- **Efecto y elegibilidad:** usar −20 g/semana (IC95% −28 a −12; certeza moderada; 12 meses; Kaner 2018) ≈ −2,86 g/día, escalado al consumo individual como hizo Lemp 2026. En sensibilidad usar −1,71 y −4,01 g/día, y −12% (hombres) / −15,8% (mujeres) relativo como en Manthey 2021. Para HED, transición HED→no-HED con RD −0,07 (−0,02 a −0,12). Simular solo IB nuevas y no asignar efecto a la referencia asistida (AUDIT ≥16).
- **Durabilidad y lag:** la evidencia sostiene un efecto pleno a 6–12 meses con atenuación posterior. El caso base debería ser un decaimiento a 0 hacia los 2–4 años; la mantención de 4 años (Fleming 2002) queda como escenario optimista. Los rezagos consumo→mortalidad están revisados en Holmes 2012 (efecto inicial inmediato para la mayoría de los daños). El trabajo "Maharaj et al. 2023" sobre rezagos **no existe tal como se cita**: el Maharaj 2023 verificable trata sobre precio mínimo por unidad y hospitalizaciones.
- **Doble conteo y exbebedores:** calibrar tasas de mortalidad "basales libres de alcohol" (tasa observada / RR medio poblacional) y aplicar RR individuales, o calcular el PIF contra el brazo de referencia de cada año. Mantener a los exbebedores como categoría propia con RR específico (Zhao 2023 muestra que el sesgo del exbebedor explica la aparente protección). En Chile, la estimación publicada verificable es 9,8% de las muertes y 21,5% de los AVPP atribuibles al alcohol en 2009 (Castillo-Carniglia et al., 2013).

## Convenciones
- **(a) Evidencia directa:** dato publicado y verificado en esta revisión.
- **(b) Extrapolación/supuesto:** decisión de modelación propuesta a partir de la evidencia.
- **(c) Incertidumbre:** vacío, conflicto o dato no verificado.

---

## P1. Modelos de escalamiento de SBI/SBIRT

### Hallazgos clave
**Lemp et al. (2026), SIMAH, EE. UU. (a)**
- **Cita:** *JAMA Health Forum* 7(7):e262348; DOI 10.1001/jamahealthforum.2026.2348; PMID 42536386.\[1\]
- **Diseño:** microsimulación individual dinámica en pasos anuales, población EE. UU. 18–79 años, 2000–2030; expansión desde 2025 y resultados a 2030.\[1\]
- **Elegibilidad para IB:** consumo de riesgo, >20 g/día en mujeres y >40 g/día en hombres (categorías OMS).\[1\]
- **Cascada:** acceso a atención → tamizaje → IB, modelada con regresiones sobre NSDUH 2013–2019.\[1\]
- **Escenarios:**
  - S1: +20 millones de tamizajes (cobertura 55,7%→66,9%).\[1\]
  - S2: +4 millones de IB.
  - S3: +8 millones de IB.
  - S4: ASBI universal en quienes acceden a atención.\[1\]
- **Efecto:**
  - −2,86 g/día (EE 0,58), muestreado de la distribución de efectos por ensayo del Cochrane y escalado al consumo actual de cada individuo.\[1\]
  - HED: una proporción igual a RD −0,07 (IC95% −0,02 a −0,12) pasa a no-HED, muestreada de forma independiente de la reducción en g/día.\[1\]
  - Sensibilidad: −1,71 y −4,01 g/día.\[1\]
- **Evitar doble conteo:** solo los individuos que reciben IB *nueva* por la expansión obtienen efecto, porque los efectos de las IB históricas "ya están capturados en los datos históricos de consumo". Primero se muestrea a quienes habrían recibido IB con las tasas históricas y luego a los adicionales entre el resto.\[1\]
- **IB repetida:** el muestreo de cada año es independiente del anterior, de modo que un individuo puede volver a recibir IB.\[1\] El texto principal no especifica si los efectos se acumulan **(c)**.
- **Decaimiento:** no se describe en el texto principal; puede estar en el eMethods del Suplemento 1 **(c)**.
- **Resultados:** AVPP antes de los 75 años por 5 causas (TUA, enfermedad hepática y cirrosis, lesiones de tránsito, otras lesiones no intencionales, suicidio). Se excluyen los cánceres "por su latencia sustancial".\[1\] Reducciones anuales al 2030 por 100.000:

| Escenario | Hombres | Mujeres |
|---|---|---|
| S1 solo tamizaje | −8,0 (−19,6 a 2,4) | −1,9 (−8,8 a 4,9) |
| S2 +4M IB | −29,0 (−42,8 a −14,0) | −15,1 (−22,9 a −5,8) |
| S3 +8M IB | −51,3 (−73,2 a −32,8) | −34,1 (−54,5 a −16,1) |
| S4 universal | −68,9 (−102,2 a −44,8) | −52,0 (−75,0 a −30,2) |

- **Solo tamizaje:** los autores concluyen que S1 produjo reducciones "estadísticamente indistinguibles de cero".\[1\]
- **Mortalidad:** "los riesgos de mortalidad no se calibran; las tasas de mortalidad de referencia se ajustan para alinear la mortalidad del modelo con NVSS y las proyecciones del Census".\[1\]
- **Incertidumbre:** 70 conjuntos de parámetros × 20 réplicas estocásticas (1.400 corridas por escenario).\[1\]
- **Documentación:** protocolo ODD (eMethods 1) y CHEERS.\[1\]
- **Lo que no se modeló:** la referencia a tratamiento especializado, porque la evidencia de que ASBI aumente el uso de atención especializada es inconsistente (citan a Glass et al. 2015).\[1\]
- **Implicancia para Chile (b):** S3 implica ≈3,6 veces las IB del escenario de referencia.\[1\] Hace falta una expansión grande de IB, no solo de tamizaje, para observar efectos en AVPP en un horizonte de 6 años.

**Manthey et al. (2021), Alemania (a)**
- **Cita:** *PLoS ONE* 16(8):e0255843.\[2\]
- **Diseño:** simulación de 10 años (2009–2018) por sexo, edad y educación.\[3\]
- **Parámetros:**
  - Tamizaje basal: 2,9% de pacientes de APS.\[4\]
  - Probabilidad de IB o referencia (RT) tras tamizaje positivo: 50%.\[5\]
  - Umbrales: mujeres 21 y 41 g/día; hombres 41 y 61 g/día.\[5\]
- **Efecto (verificado):** reducción proporcional del consumo diario de **−15,8% en mujeres (−31,1 a −1,1%)** y **−12,0% en hombres (−18,6 a −5,7%)**, recalculada desde un metaanálisis. HED: RD −0,07 (−0,12 a −0,02). El efecto de RT se *asume* igual al de la IB.\[5\]
- **Resultado:** solo consumo (sin mortalidad). Con tamizaje del 50%, 21% de los adultos habría recibido IB o RT y el consumo poblacional sería 12% menor en 2018, **sin impacto en la prevalencia de HED**.\[3\]
- **Atención:** el preprint (medRxiv) describe un análisis de sensibilidad sobre la duración del efecto cuyo detalle no se pudo extraer **(c)**.

**Modelo de Políticas de Alcohol de Sheffield (SAPM, Sheffield Alcohol Policy Model) (a)**
- **Inglaterra:** Purshouse et al. 2013, *Alcohol Alcohol* 48(2):180–188, costo-efectividad de SBI en APS.\[6\] Parámetros no extraídos en esta revisión **(c)**.
- **Italia:** Angus et al. 2014, *BMC Fam Pract* 15:26; PMID 24502342. ICER de €550/AVAC con SBI en el próximo registro en APS y €590/AVAC con SBI en la próxima consulta; resultados robustos salvo bajo los supuestos más pesimistas.\[7\]
- **Revisión sistemática:** Angus et al. 2014, *Front Psychiatry* 5:114.\[6\]\[8\]
- **Europa:** Angus et al. 2017, *Eur J Public Health* 27(2):345, meta-modelo SAPM para 27 países. Para Inglaterra, cobertura poblacional de 39,8% e ICER de €4.533/AVAC.\[9\]
- **ODHIN:** Angus et al. 2019, *Eur J Public Health* 29(2):219, estrategias para aumentar la entrega de SBI (capacitación, reembolso, eBI) en Inglaterra, Polonia y Países Bajos.\[10\]
- **Descripción matemática del SAPM:** Brennan et al. 2015, *Health Econ* (DOI 10.1002/hec.3105).\[11\]

**Otros modelos (c)**
- **Chisholm et al. (WHO-CHOICE, incluida América Latina) y OECD/Sassi:** no verificados en esta revisión; se agotó el presupuesto de búsqueda.
- **Modelación de SBI chilena o latinoamericana:** no se encontró ninguna. El vacío es un argumento de originalidad para el proyecto.

### Tabla de parámetros P1

| Parámetro | Valor | Unidad | Fuente | Aplicabilidad a Chile |
|---|---|---|---|---|
| Efecto de IB (media) | −2,86 (EE 0,58) | g/día (≈ −20 g/sem) | Lemp 2026 / Kaner 2018 | Extrapolado |
| Efecto de IB (sensibilidad) | −1,71 / −4,01 | g/día | Lemp 2026 | Extrapolado |
| Efecto relativo de IB | −12,0% H; −15,8% M | % del consumo diario | Manthey 2021 | Extrapolado |
| HED→no-HED | RD −0,07 (−0,02 a −0,12) | proporción | Lemp 2026; Manthey 2021 | Extrapolado |
| Elegibilidad | >20 g/d M; >40 g/d H | g/día | Lemp 2026 | Extrapolado (DIR usa AUDIT 8–15) |
| Efecto de solo tamizaje | indistinguible de 0 | AVPP | Lemp 2026 | Extrapolado |
| Efecto de la referencia | no modelado / igual a IB | — | Lemp 2026 / Manthey 2021 | Supuesto |
| Cobertura de tamizaje DIR | 14,5% (8,9% AUDIT en EMP) | % inscritos 15–64/año | REM 2024 (propuesta) | Directo (no verificado aquí) |

---

## P2. Tamaño y durabilidad del efecto de la IB

### Hallazgos clave
**Kaner et al. 2018, Cochrane CD004148.pub4 (a)**
- **Cita:** PMID 29476653.
- **Alcance:** 69 estudios en total; el metaanálisis primario incluye 34 estudios y 15.197 participantes.\[12\]\[13\]\[14\]
- **Efecto principal:** −20 g/semana (IC95% −28 a −12) a 12 meses; certeza moderada; I² = 73%.\[15\]\[16\]
- **Otros desenlaces:**
  - Frecuencia de binge: −0,08 episodios/semana.\[17\]\[18\]
  - Días de consumo: −0,13 días/semana.\[17\]
  - Sin impacto en la cantidad por día de consumo.\[19\]
- **Extendida vs nada/mínima:** −20 g/semana (−40 a 1).\[15\]\[16\]
- **Subgrupos:** efecto similar en hombres y mujeres.\[12\]
- **Por entorno:** según Platt et al. 2016 (citado en UpToDate), la reducción fue de 26 g/semana (IC95% −37 a −14) en APS (24 ensayos; n = 8.811) y de 9,7 g/semana (IC95% −17,5 a −1,9) en urgencias (10 ensayos; n = 6.386).
- **Control con folleto:** cuando el control recibió consejo mínimo o folleto, la ventaja cayó a 13 g/semana.\[19\] Es el comparador relevante para Barticevic 2021.
- **Tendencia:** el efecto bajó desde −38 g/semana en la versión de 2007, posiblemente porque se enrolan bebedores menos intensos.\[14\]\[16\]
- **Línea base:** consumo medio de los ensayos presenciales ≈244 g/semana.\[20\] Por eso −20 g/semana ≈ −8% relativo, lo que es consistente con la propuesta **(b)**.

**Otros estudios**
- **Beyer et al. 2019** (*Alcohol Alcohol*; PMID 31062859) **(a)**: es una *destilación* del Cochrane 2018 y **no** un metaanálisis IPD, como se cita en la propuesta.\[13\]\[21\]
- **Platt et al. 2016** (*BMJ Open* 6:e011473) **(a)**: metarregresión por entorno, profesional y contenido. Reporta −26 g/semana (IC95% −37 a −14) en APS y −9,7 g/semana (IC95% −17,5 a −1,9) en urgencias (cifras tomadas de UpToDate).
- **O'Donnell et al. 2014** (*Alcohol Alcohol* 49(1):66) **(a)**, revisión de revisiones: "los tamaños de efecto son mayores en los seguimientos más tempranos, con decaimiento posterior".\[22\]
- **Tanner-Smith et al. 2022** (*Addiction* 117(4):877–889) **(a)**: IB en entornos médicos generales; efectos pequeños pero significativos para alcohol; los *boosters* se asociaron a reducciones significativas.\[23\]\[24\] Es el mejor apoyo indirecto a la IB repetida o con refuerzo.
- **Tanner-Smith & Lipsey 2015** (*J Subst Abuse Treat* 51:1–18) **(a)**: en adultos jóvenes el efecto sobre consumo se atenuó hasta no ser significativo a los 2 años.\[25\]
- **Mun et al. 2023** (*Prev Sci* 24(8):1608–1621) **(a)**, IPD en universitarios: IB eficaces hasta los 6 meses.\[26\]\[27\]
- **Fleming et al. 2002, Project TrEAT** (*ACER* 26(1):36–43; PMID 11821652) **(a)**: el efecto "apareció dentro de 6 meses y se mantuvo durante 48 meses".\[28\]
  - La intervención fue de 2 visitas médicas + 2 llamadas de enfermería, más intensa que la IB del DIR.\[28\]
  - A 12 meses: 19,1→11,5 tragos/7 días en el grupo intervenido vs 18,9→15,5 en controles (Fleming 1997, *JAMA* 277:1039–45).\[29\]
- **Intervenciones muy breves** **(a)**: Poikolainen 1999 (*Prev Med*) no encontró efecto significativo de las intervenciones de 5–20 minutos. Hombres −42 g/semana (−105 a 21); mujeres −4 g/semana (−50 a 43).\[30\]\[31\]
- **"So et al. 2025"** **(c)**: **no se pudo verificar**. La evidencia más cercana es Poikolainen 1999.
- **HED en USPSTF (Jonas 2012; O'Connor 2018)** **(c)**: no verificados en esta revisión. Lemp cita la recomendación USPSTF de Curry et al. 2018 (*JAMA* 320(18):1899–1909).\[1\] Para HED, el parámetro operativo disponible es RD −0,07 y −0,08 episodios/semana en Kaner.
- **IB en dependencia o referencia** **(a)**: Glass et al. 2015 (*Addiction* 110(9):1404–1415) es el metaanálisis citado por Lemp para no modelar la referencia.\[1\]

**Ensayos chilenos (a)**
- **Barticevic et al. 2021** (*Addict Sci Clin Pract* 16:39; PMID 34130748):
  - Diseño: IB entregada por TENS; 5 CESFAM de Santiago; AUDIT 8–15; 18–45 años; comparador folleto.\[32\]\[33\]\[34\]
  - AUDIT a 6 meses: diferencia ajustada 0,86 puntos (0,08–1,69).\[34\]\[35\]
  - AUDIT-C: diferencia ajustada 0,44 (0–0,88).\[35\]
  - Reanálisis bayesiano (PMID 35578369): 96% de probabilidad de OR <1 para consumo de riesgo y 84% de OR <0,8.\[36\]
  - Limitación: el desenlace fue un AUDIT retrospectivo de 12 meses, poco sensible a los cambios ocurridos en 6 meses.\[37\]
- **Poblete et al. 2017** (*Addiction* 112(8):1462–1469):\[38\]
  - IB ligada a ASSIST; 12.217 personas tamizadas y 806 aleatorizadas, de 19–55 años.\[39\]
  - Lugares: 19 centros de APS, 8 SAPU/urgencias y 5 comisarías.\[40\]
  - Resultado para alcohol: sin diferencia frente al folleto. Según la revisión PMC6860910, "no hubo evidencia suficiente para afirmar que la intervención breve redujera el puntaje ASSIST para alcohol" (media 12,94, DE 6,34 vs 13,12, DE 6,41 en el control). Un protocolo posterior en JMIR (doi 10.2196/75628) la describe como una sesión única de unos 17 minutos en promedio.

### Rangos de sensibilidad propuestos (b)

| Parámetro | Bajo | Base | Alto | Justificación |
|---|---|---|---|---|
| Efecto a 12 meses | −13 g/sem (≈ −5%) | −20 g/sem (≈ −8%) | −28 g/sem o −12%/−15,8% | Kaner con control folleto / Kaner principal / IC superior y Manthey |
| Duración del efecto pleno | 1 año | 1 año, luego lineal a 0 en el año 3–4 | 4 años (TrEAT), luego lineal a 0 en el año 10 | O'Donnell 2014; Tanner-Smith 2015; Fleming 2002 |
| HED→no-HED | −0,02 | −0,07 | −0,12 | IC de la RD |
| Efecto de la referencia (AUDIT ≥16) | 0 | 0 | igual a IB × tasa de llegada (10–33%) | Glass 2015; Lemp; Manthey |
| IB repetida | sin efecto adicional | reinicia el reloj de decaimiento sin sumar | aditiva con *booster* | Tanner-Smith 2022 (c) |

---

## P3. Rezagos consumo→mortalidad

### Hallazgos clave
- **Holmes et al. 2012** (*Drug Alcohol Depend* 123(1–3):7–14; PMID 22197480) **(a)**:
  - Revisión sistemática de especificaciones de rezago en series temporales agregadas: tiempo al primer efecto, tiempo al efecto completo y forma funcional.\[41\]
  - Encontró "evidencia fuerte de un primer efecto inmediato tras un cambio en el consumo para la mayoría de los daños" y propone especificaciones por daño.\[41\]\[42\]
  - Los valores numéricos por causa no se extrajeron **(c)**.
- **Rehm et al. 2017** (*Addiction* 112:968–1001; publicado en línea en 2016) **(a)**: actualización de las dimensiones de exposición (volumen, patrón, HED). Recomienda "incorporar mejor los rezagos" en futuras evaluaciones comparativas de riesgo y cita a Holmes 2012.\[43\]
- **Lemp 2026** **(a)**: excluye los cánceres porque su latencia no es representable con transiciones anuales y horizonte corto. Por eso sus resultados capturan solo impactos de corto y mediano plazo.\[1\]
- **"Maharaj et al. 2023"** **(c)**: no existe como artículo sobre rezagos. El Maharaj 2023 verificable es Maharaj, Angus, Fitzgerald et al., *BMJ Open* 13:e065220, una revisión sistemática del precio mínimo por unidad y desenlaces hospitalarios.\[44\] El trabajo que probablemente se quiso citar es **Holmes et al. 2012**.
- **Reversibilidad del riesgo tras dejar de beber** (Roerecke/Rehm para cirrosis, cardiopatía isquémica, ACV y cánceres) **(c)**: no verificada en esta revisión.
- **Implementación de rezagos en SAPM, Kilian 2025 y Card-Gowers 2025** **(c)**: no extraída.
  - Card-Gowers et al. 2025 (*PLoS ONE* 20(1):e0314870) aplica un RR anual a 9 enfermedades a partir del consumo asignado.\[45\]\[46\] No se verificó si incorpora rezago.

### Recomendación (b)
- **Agudas** (lesiones, intoxicación, componente HED): rezago 0; el efecto aplica el mismo año.
- **Crónicas** (cirrosis, cardiovasculares): función de acumulación del riesgo, por ejemplo una media móvil ponderada de la exposición de los últimos 5–10 años.
- **Cánceres:** usar un rezago largo (≥10 años) o excluirlos del horizonte 2025–2034 como hizo Lemp. Lo segundo es más defendible con un horizonte de 10 años y reduce el riesgo de sobreestimar.

---

## P4. Estándares de reporte y buenas prácticas

- **(a)** Lemp 2026 y Kilian 2025 documentaron sus modelos con el protocolo ODD y CHEERS.\[1\] Es el estándar de facto de SIMAH y se recomienda replicarlo.
- **(a)** Puka et al. 2023 validó externamente su modelo de transición aplicando las probabilidades anuales 11 veces sobre NESARC I y comparando con NESARC III (diferencias ≤1%).\[47\] Es una plantilla directa de validación para EPS→ENPG.
- **(a)** Lemp 2026 usó calibración bayesiana con un periodo de calibración (2000–2015) y otro de validación (2016–2019), y reportó la incertidumbre como percentiles 2,5–97,5 sobre 70 conjuntos de parámetros calibrados × 20 réplicas.\[1\] Recomendación **(b)**: separar la incertidumbre de parámetros del error Monte Carlo (réplicas estocásticas).
- **(c)** Las siguientes referencias **no fueron verificadas en esta revisión** y deben confirmarse con DOI antes de citarse:
  - Grimm et al. 2006/2010/2020 (ODD; *Ecol Model* / *JASSS*).
  - Caro et al. 2012, Briggs et al. 2012, Eddy et al. 2012, Karnon et al. 2012 (ISPOR-SMDM; *Value Health* y *Med Decis Making*).
  - Rutter et al. 2011 (*Epidemiol Rev*).
  - Krijkamp et al. 2018 (*Med Decis Making*).
  - Vanni et al. 2011 (*PharmacoEconomics*).
  - Whyte et al. 2011.
  - O'Hagan et al. 2007 (*Health Econ*).
  - Koerkamp et al. 2010 (*Med Decis Making*).

---

## P5. Exbebedores ("sick quitters")

### Hallazgos clave (a)
- **Zhao et al. 2023** (*JAMA Netw Open* 6(3):e236185; corregido en mayo de 2023 por IC erróneos en una figura):\[48\]
  - 107 cohortes, 4.838.825 participantes y 425.564 muertes.\[49\]\[50\]
  - Tras ajustar por sesgo del exbebedor y otros sesgos, el consumo ocasional o bajo **no** se asoció a menor mortalidad frente a abstemios de por vida.\[51\]\[52\]
  - El riesgo aumentó desde ≥25 g/día y fue significativo desde ≥45 g/día, con umbrales más bajos en mujeres.\[53\]\[54\]
- **Puka 2023:** probó separar a los no bebedores en abstemios de por vida y exbebedores, pero el modelo final los agrupó.\[47\]
- **Lemp 2026:** "no bebedor" significa ausencia de consumo en los últimos 12 meses. El texto principal no detalla un RR específico para exbebedores **(c)**.
- **No verificados en esta revisión (c):** Stockwell et al. 2016/2024 y GBD 2020 Alcohol Collaborators (*Lancet* 2022).

### Recomendación (b)
- Mantener tres estados de no consumo: abstemio de por vida, exbebedor y no bebedor con historia desconocida.
- Asignar al exbebedor un RR propio (>1 para varias causas crónicas), con persistencia del RR elevado por años desde el cese.
- Asignar a "historia desconocida" una mezcla ponderada por la proporción de exbebedores en ENPG.
- No modelar efecto protector del consumo bajo como caso base; dejar el RR de Zhao 2023 como sensibilidad para todas las causas.
- La IB **no** debe mover personas hacia el estado "exbebedor" con su RR elevado sin justificación. De lo contrario, la intervención podría aumentar artificialmente la mortalidad.

---

## P6. Doble conteo del alcohol en la mortalidad basal

### Hallazgos clave
- **(a)** Lemp 2026 ancla la mortalidad ajustando las tasas de referencia para que el modelo reproduzca NVSS. Las funciones de RR por causa no se calibran.\[1\]
- **(a)** Barendregt & Veerman 2010 (*J Epidemiol Community Health* 64(3):209–212; DOI 10.1136/jech.2009.090274) describen el cálculo del PIF para exposiciones categóricas y continuas. Categorizar una exposición continua tiende a subestimar el PIF.\[55\]\[56\]

### Recomendación operativa (b)
1. **Tasa basal "contrafactual libre de alcohol" por causa c, edad, sexo y educación:** m₀,c = m_obs,c / Σᵢ pᵢ·RRᵢ,c, con la distribución de exposición del año base, incluidos los exbebedores y HED. Equivale a m_obs·(1 − PAF).
2. **Hazard individual:** hᵢ,c = m₀,c · RRᵢ,c(g/día, HED, exbebedor, rezago).
3. **Mortalidad por otras causas** (no relacionadas con alcohol): común a ambos brazos. Así se cumple la convención "mortalidad general independiente del alcohol".
4. **Alternativa con PIF:** si se mantiene el enfoque PIF sobre las muertes proyectadas, calcular cada año PIF_t = 1 − Σp′RR / ΣpRR, con p = distribución del brazo de referencia y p′ = distribución del brazo intervenido en ese año. Aplicarlo solo a las causas parcialmente atribuibles y no a la mortalidad total.
5. **Causas 100% atribuibles** (por ejemplo, TUA y cirrosis alcohólica): modelarlas de forma proporcional al exceso de riesgo, no con un RR estándar.

- **(c)** No se extrajeron las implementaciones de los suplementos de Kilian 2025, del SAPM ni de Card-Gowers 2025. Conviene revisar el eMethods de Lemp 2026 (sección 1.3.6).

---

## P7. Brechas del Objetivo 1 (resumen)

- **Puka et al. 2023** (*Addiction* 118(1):61–70; DOI 10.1111/add.16024) **(a)**:
  - Datos: NESARC 2001–02/2004–05, n = 34.165.\[47\]
  - Modelo: Markov multiestado homogéneo en tiempo continuo, paquete **msm** v1.6.9; solo transiciones a estados adyacentes; ajuste por edad, sexo, raza y educación.\[47\]
  - Esta es la plantilla directa para anualizar las transiciones cuatrienales de la EPS.
- **Persistencia anual en Puka** **(a)**:
  - Por volumen: no bebedor 90,1%, categoría I 90,2%, categoría II 31,8%, categoría III 52,2%.\[47\]
  - Por patrón: no-HED 82,4%, HED ocasional 45,8%, HED mensual 22,9%, HED semanal 65,5%.\[47\]
- **Discrepancia con la propuesta** **(c)**: la cifra de "72–98% de persistencia interanual y 42–63% a 5 años" para HED **no coincide** con la tabla anual de Puka (HED 22,9–65,5%). Las cifras a 5 años solo aparecen en figuras y no pudieron verificarse. Recomendación: reemplazar por los valores de la tabla 2 de Puka.
- **Categorías OMS** **(a)**, según la clasificación OMS citada por Puka:
  - Categoría III: 41–60 g/día en mujeres y 61–100 g/día en hombres.\[47\]
  - Categoría IV: ≥61 g/día en mujeres y ≥101 g/día en hombres.\[47\]
  - Esto confirma >60 g/día en mujeres como la categoría más alta. La fuente primaria (WHO 2000, *International guide*) no se verificó directamente **(c)**.
- **No verificados (c):** Jackson msm (*J Stat Softw* 2011), Kalbfleisch & Lawless 1985, Moid 2026, Kasajima 2020, Deaton 1985, Keyes 2020, Torvik 2011 y el anexo JRT del suplemento de SIMAH.

---

## P8. Chile

- **(a)** Programa DIR (SBIRT nacional): creado en 2011 en la red de APS pública, que atiende a cerca del 80% de la población (Barticevic 2021).\[35\]
- **(a)** **Peña et al. 2021** (*Addiction* 116(3):438–456; DOI 10.1111/add.15208; en línea en julio de 2020):
  - Chile ha legislado en los 10 dominios de política de la OMS, pero solo hay evaluaciones de impacto para conducción bajo influencia del alcohol.\[57\]
  - Ha tenido avances modestos en impuestos, no ha regulado el marketing y ha debilitado las reglas de disponibilidad desde 1960.\[38\]
  - Consumo per cápita: 9,3 L.\[38\]
  - El PDF está en el Drive del usuario.\[58\]
- **(a)** **Castillo-Carniglia 2025** (*Addiction* 120(7):1466–1474; DOI 10.1111/add.70031; PMID 40000011): autor único; el título es "National profile…". Describe una prevalencia alta de alcohol frente a Sudamérica y un consumo estable.\[59\]
- **(a)** **Paraje, Araya & Monteiro 2024** (*Int J Drug Policy* 124:104316; DOI 10.1016/j.drugpo.2024.104316; PMID 38219676): elasticidades de demanda *off-premise* en 5 países, incluido Chile.\[60\]\[61\] Es el "Paraje 2024" más probable. No es un estudio sobre pisco. Según el resumen de PubMed, las elasticidades precio propias del alcohol puro fueron "negativas, inelásticas y significativas al 1%" en los 5 países, pero el resumen no da la cifra para Chile. Como referencia, el artículo usa la mediana de −0,77 de Elder et al. 2010 para países desarrollados.
- **(a)** **Araya & Paraje 2018** (*PLoS ONE* 13(10):e0205932):
  - Demanda inelástica. Según el resumen de PubMed (PMID 30346989), las elasticidades precio son −0,14 en destilados, −0,77 en vinos y −0,93 en cervezas (todas P<0,01). Las elasticidades de gasto son 0,71 en destilados, 0,98 en cerveza y 1,16 en vino.
  - Sustitución hacia pisco o vino más barato.\[62\]
  - Recomiendan pasar a un impuesto específico.\[62\]
- **(a)** **Cornejo et al. 2025** (*Int J Drug Policy* 143:104907; PMID 40639198): el consumo no registrado es menor que las estimaciones previas (14,8–15,9% del total). El alcohol casero es la principal fuente (31%);\[63\]\[64\] el denominador debe confirmarse **(c)**.
- **(a)** **Castillo-Carniglia, Kaufman & Pino 2013** (*Alcohol Alcohol* 48(6):729–736; DOI 10.1093/alcalc/agt066):
  - 2009: 8.750 muertes (9,8% del total; IC95% 7,0–13,0%) y 195.475 AVPP (21,5%) atribuibles al alcohol.\[65\]\[66\]
  - Exposición estimada con datos per cápita + ENPG 2008.\[65\]
  - Es la línea base publicada de fracción atribuible (AAF/PAF).
- **(c)** Ruiz-Tagle Maturana et al. 2026 (*Public Health in Practice*, 100798; PMC13195772) actualiza la mortalidad atribuible 2008–2022, pero sus resultados no se pudieron extraer. El Drive del usuario contiene una planilla de parámetros de fracciones atribuibles para Chile 2014 cuya fuente publicada no se identificó.\[58\]\[66\]
- **(c)** **Trago estándar:** presentaciones de SENDA ante la Cámara citan **15,5 g** por trago (SENDA-MINSAL 2016, con base en la ENS 2009–10), no 15,7 g.\[67\]\[68\] No se encontró una fuente oficial para 12 g. Antes de convertir AUDIT-C a g/día, debe verificarse en el informe ENS 2009–10.

---

## Recomendaciones para el Objetivo 2 (síntesis de decisiones)
1. **Simular solo IB nuevas** (convención SIMAH/Lemp), con muestreo en dos etapas: primero los receptores históricos del DIR y luego los adicionales.
2. **Escenarios:** (i) solo más tamizaje EMP; (ii) cobertura de IB en AUDIT 8–15 del 52%→80%; (iii) tamizaje + IB escalados; (iv) universal. Se espera que (i) sea ≈0, lo que es en sí un mensaje de política.
3. **Elegibilidad:** mapear AUDIT 8–15 a g/día con una relación AUDIT-C↔g/día estimada en el Termómetro/ENPG. Fijar la conversión del trago estándar (15,5 g vs 12 g) como parámetro de sensibilidad explícito.
4. **Efecto:** proporcional al consumo (−8% base), muestreado de una distribución (EE ≈ 0,58 g/día). HED con RD −0,07. Referencia sin efecto en el caso base.
5. **Durabilidad:** caso base con decaimiento a 0 en el año 3–4; optimista con 4 años plenos (TrEAT); pesimista con 1 año.
6. **Mortalidad:** tasas basales contrafactuales por causa; cánceres fuera del horizonte o con rezago largo; exbebedores con RR propio.
7. **Documentar** con ODD + CHEERS y validar las transiciones con predicción fuera de muestra sobre ENPG (estilo Puka).

## Advertencias
- Varios parámetros de Lemp (decaimiento, IB repetida) y de SAPM están en suplementos que no se revisaron.
- Las cifras REM 2024 de la propuesta no se verificaron de forma independiente.
- La transferibilidad del efecto de ensayos de países de altos ingresos a una IB entregada por TENS en Chile es incierta. La evidencia chilena (−0,86 puntos AUDIT vs folleto) es consistente con un efecto pequeño.\[34\]\[35\]

---

## Referencias (APA 7)

**Verificadas (DOI o PMID confirmado en esta revisión)**
- Angus, C., Scafato, E., Ghirini, S., Torbica, A., Ferre, F., Struzzo, P., Purshouse, R., & Brennan, A. (2014). Cost-effectiveness of a programme of screening and brief interventions for alcohol in primary care in Italy. *BMC Family Practice, 15*, 26. https://doi.org/10.1186/1471-2296-15-26 [verified DOI; PMID 24502342]
- Angus, C., Latimer, N., Preston, L., Li, J., & Purshouse, R. (2014). What are the implications for policy makers? A systematic review of the cost-effectiveness of screening and brief interventions for alcohol misuse in primary care. *Frontiers in Psychiatry, 5*, 114. https://doi.org/10.3389/fpsyt.2014.00114 [verified DOI]
- Araya, D., & Paraje, G. (2018). The impact of prices on alcoholic beverage consumption in Chile. *PLoS ONE, 13*(10), e0205932. https://doi.org/10.1371/journal.pone.0205932 [verified DOI]
- Barendregt, J. J., & Veerman, J. L. (2010). Categorical versus continuous risk factors and the calculation of potential impact fractions. *Journal of Epidemiology and Community Health, 64*(3), 209–212. https://doi.org/10.1136/jech.2009.090274 [verified DOI]
- Barticevic, N. A., Poblete, F., Zuzulich, S. M., Rodriguez, V., Quevedo, D., Sena, B. F., & Bradshaw, L. (2021). A health technician-delivered brief intervention linked to AUDIT for reduction of alcohol use in Chilean primary care: A randomized controlled trial. *Addiction Science & Clinical Practice, 16*, 39. https://doi.org/10.1186/s13722-021-00248-4 [verified DOI; PMID 34130748]
- Beyer, F. R., Campbell, F., Bertholet, N., Daeppen, J. B., Saunders, J. B., Pienaar, E. D., Muirhead, C. R., & Kaner, E. F. S. (2019). The Cochrane 2018 review on brief interventions in primary care for hazardous and harmful alcohol consumption: A distillation for clinicians and policy makers. *Alcohol and Alcoholism, 54*(4), 417–427. [verified PMID 31062859; pages/DOI not confirmed]
- Card-Gowers, J., Boniface, S., Brown, J., Kock, L., Martin, A., Retat, L., et al. (2025). Long-term health consequences and costs of changes in alcohol consumption in England during the COVID-19 pandemic. *PLoS ONE, 20*(1), e0314870. https://doi.org/10.1371/journal.pone.0314870 [verified DOI; PMID 39820181]
- Castillo-Carniglia, Á. (2025). National profile on substance use, substance use-related problems and policy: The case of Chile. *Addiction, 120*(7), 1466–1474. https://doi.org/10.1111/add.70031 [verified DOI; PMID 40000011]
- Castillo-Carniglia, Á., Kaufman, J. S., & Pino, P. (2013). Alcohol-attributable mortality and years of potential life lost in Chile in 2009. *Alcohol and Alcoholism, 48*(6), 729–736. https://doi.org/10.1093/alcalc/agt066 [verified DOI]
- Cornejo, C., Gilmore, D. M., Mateo Pinones, M., Norambuena Cardenas, P., Lachenmeier, D. W., Rehm, J., Monteiro, M., & Castillo-Carniglia, Á. (2025). Enhancing the estimation of unrecorded alcohol consumption in Chile: A multi-methods study. *International Journal of Drug Policy, 143*, 104907. https://doi.org/10.1016/j.drugpo.2025.104907 [verified DOI; PMID 40639198]
- Fleming, M. F., Mundt, M. P., French, M. T., Manwell, L. B., Stauffacher, E. A., & Barry, K. L. (2002). Brief physician advice for problem drinkers: Long-term efficacy and benefit-cost analysis. *Alcoholism: Clinical and Experimental Research, 26*(1), 36–43. https://doi.org/10.1111/j.1530-0277.2002.tb02429.x [verified DOI; PMID 11821652]
- Fleming, M. F., Barry, K. L., Manwell, L. B., Johnson, K., & London, R. (1997). Brief physician advice for problem alcohol drinkers: A randomized controlled trial in community-based primary care practices. *JAMA, 277*(13), 1039–1045. [verified PMID 9091691]
- Glass, J. E., Hamilton, A. M., Powell, B. J., Perron, B. E., Brown, R. T., & Ilgen, M. A. (2015). Specialty substance use disorder services following brief alcohol intervention: A meta-analysis of randomized controlled trials. *Addiction, 110*(9), 1404–1415. [verified via Lemp 2026 reference list; DOI not confirmed]
- Holmes, J., Meier, P. S., Booth, A., Guo, Y., & Brennan, A. (2012). The temporal relationship between per capita alcohol consumption and harm: A systematic review of time lag specifications in aggregate time series analyses. *Drug and Alcohol Dependence, 123*(1–3), 7–14. [verified PMID 22197480]
- Kaner, E. F. S., Beyer, F. R., Muirhead, C., Campbell, F., Pienaar, E. D., Bertholet, N., Daeppen, J. B., Saunders, J. B., & Burnand, B. (2018). Effectiveness of brief alcohol interventions in primary care populations. *Cochrane Database of Systematic Reviews, 2*, CD004148. https://doi.org/10.1002/14651858.CD004148.pub4 [verified DOI; PMID 29476653]
- Kilian, C., Buckley, C., Lemp, J. M., Kou, X., et al. (2025). Targeting alcohol use in high-risk population groups: A US microsimulation study of beverage-specific pricing policies. *The Lancet Public Health, 10*(10), e815–e823. https://doi.org/10.1016/S2468-2667(25)00165-3 [verified DOI]
- Lemp, J. M., Kilian, C., Kou, X., Buckley, C., Llamosas-Falcón, L., Zhu, Y., Rehm, J., Mulia, N., Purshouse, R., & Probst, C. (2026). Expanded alcohol screening and brief intervention to address premature mortality. *JAMA Health Forum, 7*(7), e262348. https://doi.org/10.1001/jamahealthforum.2026.2348 [verified DOI; PMID 42536386]
- Manthey, J., Solovei, A., Anderson, P., Carr, S., & Rehm, J. (2021). Can alcohol consumption in Germany be reduced by alcohol screening, brief intervention and referral to treatment in primary health care? Results of a simulation study. *PLoS ONE, 16*(8), e0255843. https://doi.org/10.1371/journal.pone.0255843 [verified DOI]
- Mun, E.-Y., Zhou, Z., Huh, D., Tan, L., Li, D., Tanner-Smith, E. E., Walters, S. T., & Larimer, M. E. (2023). Brief alcohol interventions are effective through 6 months: Findings from marginalized zero-inflated Poisson and negative binomial models in a two-step IPD meta-analysis. *Prevention Science, 24*(8), 1608–1621. https://doi.org/10.1007/s11121-022-01420-1 [verified DOI; PMID 35976524]
- Paraje, G., Araya, D., & Monteiro, M. G. (2024). Off-premises demand elasticities for pure alcohol in five Latin American countries: The case of Argentina, Chile, Costa Rica, Honduras, and Uruguay. *International Journal of Drug Policy, 124*, 104316. https://doi.org/10.1016/j.drugpo.2024.104316 [verified DOI; PMID 38219676]
- Peña, S., Sierralta, P., Norambuena, P., Leyton, F., Pemjean, A., & Román, F. (2021). Alcohol policy in Chile: A systematic review of policy developments and evaluations. *Addiction, 116*(3), 438–456. https://doi.org/10.1111/add.15208 [verified DOI]
- Platt, L., Melendez-Torres, G. J., O'Donnell, A., et al. (2016). How effective are brief interventions in reducing alcohol consumption: Do the setting, practitioner group and content matter? Findings from a systematic review and metaregression analysis. *BMJ Open, 6*, e011473. [verified article ID; DOI not confirmed]
- Poblete, F., Barticevic, N. A., Zuzulich, M. S., Portilla, R., Castillo-Carniglia, Á., Sapag, J. C., Villarroel, L., Sena, B. F., & Galarce, M. (2017). A randomized controlled trial of a brief intervention for alcohol and drugs linked to the Alcohol, Smoking and Substance Involvement Screening Test (ASSIST) in primary health care in Chile. *Addiction, 112*(8), 1462–1469. https://doi.org/10.1111/add.13808 [verified DOI]
- Puka, K., Buckley, C., Mulia, N., Purshouse, R. C., Lasserre, A. M., Kerr, W., Rehm, J., & Probst, C. (2023). Behavioral stability of alcohol consumption and socio-demographic correlates of change among a nationally representative cohort of US adults. *Addiction, 118*(1), 61–70. https://doi.org/10.1111/add.16024 [verified DOI]
- Purshouse, R. C., Brennan, A., Rafia, R., Latimer, N. R., Archer, R. J., Angus, C. R., Preston, L. R., & Meier, P. S. (2013). Modelling the cost-effectiveness of alcohol screening and brief interventions in primary care in England. *Alcohol and Alcoholism, 48*(2), 180–188. [verified citation; DOI not confirmed]
- Rehm, J., Gmel, G. E., Sr., Gmel, G., Hasan, O. S. M., Imtiaz, S., Popova, S., Probst, C., Roerecke, M., Room, R., Samokhvalov, A. V., Shield, K. D., & Shuper, P. A. (2017). The relationship between different dimensions of alcohol use and the burden of disease—an update. *Addiction, 112*(6), 968–1001. https://doi.org/10.1111/add.13757 [verified DOI; author list not fully confirmed]
- Tanner-Smith, E. E., & Lipsey, M. W. (2015). Brief alcohol interventions for adolescents and young adults: A systematic review and meta-analysis. *Journal of Substance Abuse Treatment, 51*, 1–18. [verified citation; DOI not confirmed]
- Tanner-Smith, E. E., Parr, N. J., Schweer-Collins, M., & Saitz, R. (2022). Effects of brief substance use interventions delivered in general medical settings: A systematic review and meta-analysis. *Addiction, 117*(4), 877–889. [verified citation; DOI not confirmed]
- Zhao, J., Stockwell, T., Naimi, T., Churchill, S., Clay, J., & Sherk, A. (2023). Association between daily alcohol intake and risk of all-cause mortality: A systematic review and meta-analyses. *JAMA Network Open, 6*(3), e236185. https://doi.org/10.1001/jamanetworkopen.2023.6185 [verified DOI]

**No verificadas en esta revisión [could not verify — confirmar antes de citar]**
- Probst, C., et al. (2023). Simulation of Alcohol Control Policies for Health Equity (SIMAH) project: Study design and first results. *American Journal of Epidemiology, 192*(5), 690–. [volume/issue seen; DOI and pages not confirmed]
- Angus, C., Thomas, C., Anderson, P., Meier, P. S., & Brennan, A. (2017). Estimating the cost-effectiveness of brief interventions for heavy drinking in primary health care across Europe. *European Journal of Public Health, 27*(2), 345–. [DOI not confirmed]
- Chisholm et al. (WHO-CHOICE); OECD/Sassi; Stockwell et al. 2016/2024; GBD 2020 Alcohol Collaborators (2022); Jonas et al. 2012 and O'Connor et al. 2018 (USPSTF); Grimm et al. 2006/2010/2020; Caro, Briggs, Eddy, Karnon et al. 2012; Rutter et al. 2011; Krijkamp et al. 2018; Vanni et al. 2011; Whyte et al. 2011; O'Hagan et al. 2007; Koerkamp et al. 2010; Jackson 2011 (msm); Kalbfleisch & Lawless 1985; Deaton 1985; Kasajima 2020; Keyes 2020; Torvik 2011; WHO 2000 International Guide; Roerecke & Rehm (reversibility); Ruiz-Tagle Maturana et al. 2026 (results not extracted).

**Referencias de la propuesta que no se encontraron y trabajo más probable**

| Cita en la propuesta | Estado | Trabajo más probable |
|---|---|---|
| Maharaj et al. 2023 (rezagos) | No existe como estudio de rezagos | Holmes et al. 2012, *Drug Alcohol Depend* (PMID 22197480); el Maharaj 2023 real es sobre precio mínimo por unidad (*BMJ Open* 13:e065220) |
| Paraje et al. 2024 (bebidas/pisco/precios) | No hay estudio de pisco | Paraje, Araya & Monteiro 2024, *Int J Drug Policy* 124:104316; para pisco y sustitución, Araya & Paraje 2018 |
| So et al. 2025 (consejo muy breve sin efecto) | No verificado | Poikolainen 1999, *Prev Med* (efecto no significativo de IB muy breves) |
| Beyer et al. 2019 "IPD" | No es IPD | Destilación del Cochrane 2018 (PMID 31062859) |
| Peña et al. 2020 | Año del número: 2021 | Peña et al. 2021, *Addiction* 116(3):438–456 |
| Rehm et al. 2016 (dimensiones) | Año del número: 2017 | Rehm et al. 2017, *Addiction* 112:968–1001 |
| Castillo-Carniglia et al. 2025 "country profile" | Autor único; título "National profile" | Castillo-Carniglia 2025, *Addiction* 120(7):1466–1474 |
| Trago estándar de 15,7 g (ENS 2009) | 15,5 g encontrado; 12 g sin fuente | SENDA-MINSAL 2016 (con base en la ENS 2009–10) |

## Fuentes

1. [Expanded Alcohol Screening and Brief Intervention to Address Premature Mortality](https://jamanetwork.com/journals/jama-health-forum/fullarticle/2851858)
2. [Can alcohol consumption in Germany be reduced by alcohol screening, brief intervention and referral to treatment in primary health care? Results of a simulation study](https://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0255843)
3. [Can alcohol consumption in Germany be reduced by alcohol screening, brief intervention and referral to treatment in primary health care? Results of a simulation study](https://www.medrxiv.org/content/10.1101/2021.05.18.21257405v1)
4. [Adriana SOLOVEI](https://www.researchgate.net/profile/Adriana-Solovei)
5. [Can alcohol consumption in Germany be reduced by alcohol screening, brief intervention and referral to treatment in primary health care? Results of a simulation study - PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC8341530/)
6. [Mr Colin Angus](https://sheffield.ac.uk/smph/colin-angus)
7. [Cost-effectiveness of a programme of screening and brief interventions for alcohol in primary care in Italy - PubMed](https://pubmed.ncbi.nlm.nih.gov/24502342/?dopt=Abstract)
8. [www.frontiersin.org](https://www.frontiersin.org/articles/10.3389/fpsyt.2014.00114/pdf)
9. [Estimating the cost-effectiveness of brief interventions for heavy drinking in primary health care across Europe](https://academic.oup.com/eurpub/article/27/2/345/2622407)
10. [Cost-effectiveness of strategies to improve delivery of brief interventions for heavy drinking in primary care: results from the ODHIN trial](https://academic.oup.com/eurpub/article/29/2/219/5098723)
11. [The Sheffield Alcohol Policy Model](https://onlinelibrary.wiley.com/doi/full/10.1002/hec.3105)
12. [The Cochrane 2018 review on brief interventions in primary care for hazardous and harmful alcohol consumption: a distillation for clinicians and policy makers - White Rose Research Online](https://eprints.whiterose.ac.uk/147518/)
13. [The Cochrane 2018 Review on Brief Interventions in Primary Care for Hazardous and Harmful Alcohol Consumption: A Distillation for Clinicians and Policy Makers](https://www.researchgate.net/publication/333894386_The_Cochrane_2018_Review_on_Brief_Interventions_in_Primary_Care_for_Hazardous_and_Harmful_Alcohol_Consumption_A_Distillation_for_Clinicians_and_Policy_Makers)
14. [Brief Interventions in Primary Care: an Evidence Overview of Practitioner and Digital Intervention Programmes - Current Addiction Reports](https://link.springer.com/article/10.1007/s40429-018-0198-7)
15. [Effectiveness of brief alcohol interventions in primary care populations](https://www.cochrane.org/evidence/CD004148_effectiveness-brief-alcohol-interventions-primary-care-populations)
16. [Effectiveness of brief alcohol interventions in primary care populations - Kaner, EFS - 2018](https://www.cochranelibrary.com/cdsr/doi/10.1002/14651858.CD004148.pub4/full)
17. [Effectiveness of brief alcohol interventions in primary care ...](https://alkohologsamfund.dk/sites/alkohologsamfund.dk/files/media/document/Effectiveness%20of%20brief%20alcohol%20interventions%20in%20primary%20care%20populations%202018.pdf)
18. [Cochrane Library Cochrane Database of Systematic Reviews](https://prevention-collaborative.org/wp-content/uploads/2021/08/Kaner_et_al-2018-Cochrane_Database_of_Systematic_Reviews.pdf)
19. [Effectiveness of brief alcohol interventions in primary care populations](https://findings.org.uk/PHP/dl.php?file=Kaner_E_12.txt&s=eb)
20. [(PDF) Effectiveness of brief alcohol interventions in primary care populations](https://www.researchgate.net/publication/323386007_Effectiveness_of_brief_alcohol_interventions_in_primary_care_populations)
21. [The Cochrane 2018 Review on Brief Interventions in Primary Care for Hazardous and Harmful Alcohol Consumption: A Distillation for Clinicians and Policy Makers - PubMed](https://pubmed.ncbi.nlm.nih.gov/31062859/?dopt=Abstract)
22. [Impact of Brief Alcohol Interventions in Primary Healthcare: A Systematic Review of Reviews](https://academic.oup.com/alcalc/article/49/1/66/145551)
23. [Brief Drug Interventions Delivered in General Medical Settings: a Systematic Review and Meta-analysis of Cannabis Use Outcomes](https://link.springer.com/article/10.1007/s11121-025-01826-7)
24. [Commentary on Tanner‐Smith et al.: Complexity matters—why we need to move beyond ‘what works’ when evaluating substance use interventions - O'Donnell - 2022 - Addiction - Wiley Online Library](https://onlinelibrary.wiley.com/doi/10.1111/add.15762)
25. [Brief Alcohol Interventions for Adolescents and Young Adults: A Systematic Review and Meta-Analysis - ScienceDirect](https://www.sciencedirect.com/science/article/pii/S0740547214001925)
26. [Brief Alcohol Interventions are Effective through 6 Months: Findings from Marginalized Zero-inflated Poisson and Negative Binomial Models in a Two-step IPD Meta-analysis - Mendeley Data](https://data.mendeley.com/datasets/h2sd5y6fxp/1)
27. [Brief Alcohol Interventions are Effective through 6 Months: Findings from Marginalized Zero-inflated Poisson and Negative Binomial Models in a Two-step IPD Meta-analysis - PubMed](https://pubmed.ncbi.nlm.nih.gov/35976524/)
28. [Brief physician advice for problem drinkers: long-term efficacy and benefit-cost analysis - PubMed](https://pubmed.ncbi.nlm.nih.gov/11821652/)
29. [Brief Physician Advice for Problem Alcohol Drinkers: A Randomized Controlled Trial in Community-Based Primary Care Practices](https://jamanetwork.com/journals/jama/article-abstract/414915)
30. [Effectiveness of Brief Interventions to Reduce Alcohol Intake in Primary Health Care Populations: A Meta-analysis - ScienceDirect](https://www.sciencedirect.com/science/article/abs/pii/S009174359990467X)
31. [Effectiveness of brief interventions to reduce alcohol intake in primary health care populations: a meta-analysis - Database of Abstracts of Reviews of Effects (DARE): Quality-assessed Reviews - NCBI Bookshelf](https://www.ncbi.nlm.nih.gov/books/NBK67598/)
32. [A Health Technician-delivered Brief Intervention linked to AUDIT for reduction of alcohol use in Chilean primary care: a randomized controlled trial](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8207593/)
33. [Alcohol Brief Counseling in Primary Care](https://clinicaltrials.gov/study/NCT02642757)
34. mcp\_\_Google\_Drive\_\_read\_file\_content
35. [A Health Technician-delivered Brief Intervention linked to AUDIT for reduction of alcohol use in Chilean primary care: a randomized controlled trial - PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC8207593/)
36. [Effectiveness of a health technician-delivered brief intervention for alcohol: a Bayesian reanalysis of a clinical trial - PubMed](https://pubmed.ncbi.nlm.nih.gov/35578369/)
37. [Effectiveness of a health technician-delivered brief intervention for alcohol: a Bayesian reanalysis of a clinical trial - PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC9109285/)
38. [Alcohol policy in Chile : Addiction](https://www.ovid.com/journals/addic/fulltext/10.1111/add.15208~alcohol-policy-in-chile-a-systematic-review-of-policy)
39. [(PDF) A randomised controlled trial of a brief intervention for illicit drug use linked to ASSIST screening in a primary healthcare setting: Results from the Australian component of the World Health Organization Phase III ASSIST studies](https://www.researchgate.net/publication/323411833_A_randomised_controlled_trial_of_a_brief_intervention_for_illicit_drug_use_linked_to_ASSIST_screening_in_a_primary_healthcare_setting_Results_from_the_Australian_component_of_the_World_Health_Organiza)
40. [A randomized controlled trial of a brief intervention for alcohol and drugs linked to the Alcohol, Smoking and Substance Involvement Screening Test (ASSIST) in primary health care in Chile - Poblete - 2017 - Addiction - Wiley Online Library](https://onlinelibrary.wiley.com/doi/10.1111/add.13808)
41. [The temporal relationship between per capita alcohol consumption and harm: a systematic review of time lag specifications in aggregate time series analyses - PubMed](https://pubmed.ncbi.nlm.nih.gov/22197480/?dopt=Abstract)
42. [The temporal relationship between per capita alcohol consumption and harm: a systematic review of time lag specifications in aggregate time series analyses - PubMed](https://pubmed.ncbi.nlm.nih.gov/22197480/)
43. [The relationship between different dimensions of alcohol use and the burden of disease—an update - Rehm - 2017 - Addiction - Wiley Online Library](https://onlinelibrary.wiley.com/doi/full/10.1111/add.13757)
44. [Evaluating the impact of alcohol minimum unit pricing on deaths and hospitalisations in Scotland: a controlled interrupted time series study - The Lancet](<https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(23)00497-X/fulltext>)
45. [Long-term health consequences and costs of changes in alcohol consumption in England during the COVID-19 pandemic - PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC11737736/)
46. [Long-term health consequences and costs of changes in alcohol consumption in England during the COVID-19 pandemic - PubMed](https://pubmed.ncbi.nlm.nih.gov/39820181/)
47. <https://eprints.whiterose.ac.uk/id/eprint/190647/1/Addiction%20-%202022%20-%20Puka%20-%20Behavioral%20stability%20of%20alcohol%20consumption%20and%20socio%E2%80%90demographic%20correlates%20of%20change%20among%20a.pdf>
48. [profiles.bu.edu](https://profiles.bu.edu/Timothy.Naimi)
49. [Daily Alcohol Intake Appears More Dangerous than Not, Even in Small Doses and Particularly for Women](https://www.patientcareonline.com/view/daily-alcohol-intake-appears-more-dangerous-than-not-even-in-small-doses-and-particularly-for-women)
50. [Errors in Figure and Supplement](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC10170333/)
51. [No protection against mortality with low or moderate alcohol use, mortality risk increases at higher levels](https://www.recoveryanswers.org/research-post/no-protection-against-mortality-low-moderate-alcohol-use-mortality-risk-increases-higher-levels/)
52. [High Alcohol Consumption Increases Risk of All-Cause Mortality](https://www.pcrm.org/news/health-nutrition/high-alcohol-consumption-increases-risk-all-cause-mortality)
53. [Association between daily alcohol intake and risk of all-cause mortality: a systematic review and meta-analyses - University of Portsmouth](https://researchportal.port.ac.uk/en/publications/association-between-daily-alcohol-intake-and-risk-of-all-cause-mo/)
54. [New Comprehensive Meta-Analysis Finds Low-Volume Alcohol Use Increases Risk of All-Cause Mortality - Movendi International](https://movendi.ngo/science-digest/comprehensive-meta-analysis-finds-low-volume-alcohol-use-increases-risk-of-all-cause-mortality/)
55. [Population attributable fraction for continuously distributed exposures](https://www.medrxiv.org/content/10.1101/2020.10.15.20212886v1.full)
56. [Population attributable fractions for continuously distributed exposures](https://www.degruyterbrill.com/document/doi/10.1515/em-2019-0037/html)
57. [Alcohol policy in Chile: a systematic review of policy developments and evaluations - Peña - 2021 - Addiction - Wiley Online Library](https://onlinelibrary.wiley.com/doi/10.1111/add.15208)
58. mcp\_\_Google\_Drive\_\_search\_files
59. [National profile on substance use, substance use-related problems and policy: The case of Chile - PubMed](https://pubmed.ncbi.nlm.nih.gov/40000011/)
60. [Off-premises demand elasticities for pure alcohol in five Latin American countries: The case of Argentina, Chile, Costa Rica, Honduras, and Uruguay - PubMed](https://pubmed.ncbi.nlm.nih.gov/38219676/)
61. [Off-premises demand elasticities for pure alcohol in five Latin American countries: The case of Argentina, Chile, Costa Rica, Honduras, and Uruguay - ScienceDirect](https://www.sciencedirect.com/science/article/abs/pii/S095539592400001X)
62. [The impact of prices on alcoholic beverage consumption in Chile](https://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0205932)
63. [Enhancing the estimation of unrecorded alcohol consumption in Chile: a multi-methods study - PubMed](https://pubmed.ncbi.nlm.nih.gov/40639198/)
64. [Enhancing the estimation of unrecorded alcohol consumption in Chile: a multi-methods study - ScienceDirect](https://www.sciencedirect.com/science/article/abs/pii/S0955395925002075)
65. [(PDF) Edad mínima legal de consumo de alcohol en el contexto chileno](https://researchgate.net/publication/298913801_Minimum_legal_drinking_age_in_the_Chilean_context)
66. [Sex and age differences in alcohol-attributable mortality in Chile between 2008 and 2022 - ScienceDirect](https://www.sciencedirect.com/science/article/pii/S2666535226000777)
67. [CONSUMO DE ALCOHOL EN CHILE. Carlos Charme F. Director Nacional SENDA](https://www.camara.cl/verDoc.aspx?prmID=166896&prmTIPO=DOCUMENTOCOMISION)
68. [El problema del consumo abusivo de alcohol en Chile. Comisión de Salud](https://www.camara.cl/verDoc.aspx?prmID=171677&prmTIPO=DOCUMENTOCOMISION)
