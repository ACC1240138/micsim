# Extensión de las categorías de consumo de alcohol más allá de los 65 años en una microsimulación tipo SIMAH para Chile

> **Procedencia.** Informe generado con la herramienta de investigación avanzada de Claude el 29-oct-2026, a partir de la pregunta «¿categorías de consumo son extrapolables después de los 65, por ejemplo hasta los 75?». Las cifras de EPS provienen de las salidas del proyecto (`prevalence_50plus.csv`, `binary_transitions.csv`, `rho_age_sex.csv`). Las citas de la literatura no fueron verificadas una por una contra los artículos originales. Antes de citar en un manuscrito, abrir cada fuente. Nota local, no versionada en GitHub.

# ¿Se pueden extrapolar las categorías de consumo de alcohol más allá de los 65 años (p. ej., hasta 75)? Evidencia y recomendaciones para una microsimulación tipo SIMAH en Chile

Sí: hasta ~75–79 años es razonable extender el motor, pero no por simple extrapolación de lo estimado a 15–65, sino combinando (a) distribuciones marginales por categoría estimadas directamente con EPS/ENCAVI y calibradas a ENPG en el tramo 60–65, (b) transiciones de bebedor/no bebedor estimadas directamente en EPS con pendiente de edad, y (c) transiciones de C2/C3+ "prestadas" de edades 50–65 (sin interacción edad) y luego calibradas a las marginales observadas; más allá de ~77 años la evidencia es demasiado escasa para algo distinto de un supuesto explícito.

## TL;DR

- **Distribución (prevalencias por categoría):** se puede estimar directamente hasta ~76 años con EPS (n≈400–700 por sexo y tramo) y ENCAVI (5.019 personas ≥65), siempre que se calibre el instrumento a ENPG en 60–65. La literatura internacional (HRS, ELSA, Whitehall II, SHARE/MHAS) muestra una caída gradual y monótona del consumo después de los 60–65, sin quiebres abruptos hasta ~75, lo que hace defendible una función suave de edad; después de ~77–80 la caída se acelera y la evidencia empírica chilena es frágil (n efectivo 162 hombres y 246 mujeres en 77+).
- **Transiciones/persistencia:** la persistencia de beber estimada a 60–65 es transportable a 66–76 con una pendiente de edad modesta (sus propios datos: P(seguir bebiendo en ~7,7 años) 0,55 a 60–65 y 0,46 a 71–76 en hombres, IC superpuestos), pero no es transportable sin ajuste la tasa de abandono por enfermedad ("sick quitting"), que la literatura muestra que aumenta con la edad. Las transiciones entre C1, C2 y C3+ no son estimables después de 65 en Chile (C2/C3+ ≈0–1,8%): deben tomarse prestadas y validarse solo contra marginales.
- **Qué hacer:** extender a 79 (como SIMAH, 18–79), anclar las marginales 66–79 con EPS/ENCAVI, modelar el volumen entre bebedores con una gamma cuya media decline con la edad (DE ≈1,17×media en hombres, 1,26×media en mujeres) para obtener las colas C2/C3+, y validar con predicción fuera de muestra (estimar en ≤70, predecir 71–76), comparación de pseudo-cohortes VI→VIII y mortalidad diferencial por categoría.

## Hallazgos clave

### 1. Qué muestra la evidencia longitudinal sobre el consumo después de los 65

**La caída es gradual, mayor en cantidad que en frecuencia, y empieza alrededor de los 60.**

- En la síntesis de nueve cohortes británicas (Britton et al., BMC Medicine 2015; doi 10.1186/s12916-015-0273-z), el volumen medio en hombres se estabiliza en la mediana edad y "declina desde alrededor de los 60 años"; la pendiente más pronunciada se observó en hombres de ELSA, con caídas de casi una unidad/semana por año desde los 45. El beber frecuente (diario o casi diario) superó el 50% en hombres de 65+ en Whitehall II y solo declinó en la vejez avanzada.
- En la HRS (Platt, Sloan y Costanzo, J Stud Alcohol Drugs 2010; doi 10.15288/jsad.2010.71.169; n=6.787 de 51–61 años en 1992, seguidos 14 años), el consumo medio bajó de 0,60 a 0,36 tragos/día y la proporción de abstemios subió de 35,2% a 66,3%, con la mayor parte del cambio en los primeros 5 años; en cambio, la proporción de bebedores intensos se mantuvo relativamente estable. Ese estudio excluyó a quienes murieron (17,9% de la muestra inicial), es decir, describe sobrevivientes.
- Los datos armonizados de 21 países (Calvo et al., Drug Alcohol Depend 2020; doi 10.1016/j.drugalcdep.2020.108219), que incluyen la EPS chilena y MHAS, muestran que el grupo 65+ bebe menos cantidad pero con más frecuencia que el de 50–64, y que la prevalencia de consumo en mayores aumentó en el tiempo en Chile (uno de 13 países con alza) mientras bajó en México.
- En un análisis transversal de 22 países (Calvo et al., Addiction 2021; doi 10.1111/add.15292; n=106.180), cada año adicional de edad se asoció a un RR=0,98 en tragos estándar/semana, con variación sustancial entre países en la pendiente de edad; México mostró una caída moderada de la prevalencia de consumo intenso con la edad.
- Según NHS England Digital (Health Survey for England 2021, parte 1), beber en los últimos 12 meses fue 85% a 55–74 y 77% a 75+, pero el número medio de días de consumo en la semana fue máximo a 75+ (3,7 días): la frecuencia se mantiene mientras la prevalencia y la cantidad caen.

**Interpretación:** una caída de ~2% anual en volumen y de algunos puntos porcentuales por década en prevalencia es lo esperable entre 65 y 75; ninguna fuente sugiere un quiebre que invalide una función suave de edad en ese tramo. Los datos EPS del proyecto son coherentes: en la ola VIII la prevalencia en hombres pasa de 43,1% (60–65) a 36,8% (66–70 y 71–76) y a 27,5% (77+); en mujeres de 20,7% a 20,4%, 14,8% y 12,0%.

**Efectos de cohorte vs. edad.** La comparación transversal subestima el cambio intra-individual: en la EPS, los hombres de 60–65 en la ola VI (49,3%) aparecen ~7,7 años después en los tramos 66–70/71–76 de la ola VIII con 36,8%, una caída de ~12 puntos, casi el doble de la diferencia transversal de ~6 puntos entre 60–65 y 66–70 en la misma ola. Parte de esto es período (la prevalencia a 60–65 bajó de 49,3% a 43,1% entre olas). Karlamangla et al. (Addiction 2006; doi 10.1111/j.1360-0443.2005.01299.x) no encontraron efecto de cohorte en el consumo intenso en NHANES I, pero el modelo Sheffield original asumió explícitamente "no hay efectos de cohorte" y los análisis APC británicos sí encuentran cohortes que llevan su consumo hacia la vejez. Conclusión práctica: modelar edad y período por separado y no usar la curva transversal de una sola ola como trayectoria individual.

**Diferencias por sexo y nivel socioeconómico.**

- Los hombres tienen mayor prevalencia y volumen, pero declinan más rápido en algunas cohortes (Moore et al., AJPH 2005; doi 10.2105/AJPH.2003.019471), mientras que en otras el consumo intenso declina más lento en hombres y fumadores (Karlamangla 2006).
- Los bebedores más intensos al inicio reducen más rápido en términos absolutos (Moore 2005; Kerr 2004), lo que es compatible con regresión a la media y con abandono por enfermedad.
- En HRS, quienes aumentan su consumo después de los 50 son más a menudo de mayor ingreso (RRR 1,09) y educación (RRR 1,20), hombres y con historia de problemas con el alcohol (Platt 2010). En el estudio telefónico SENDA 2021 de personas mayores chilenas, el uso más intenso se concentró en personas con educación básica (66,4%) y media (65,7%) frente a superior (51,3%).
- El gradiente educativo existe pero es de magnitud modesta frente al efecto de sexo; vale la pena conservarlo como covariable, pero no cabe esperar poder estimar interacciones edad×educación×categoría con EPS después de 65.

### 2. ¿Son transportables las transiciones de 50–65 a 66–75?

**Parte binaria (beber/no beber): sí, con pendiente de edad.**

- Los datos EPS muestran persistencia de beber a ~7,7 años de 0,55 en hombres de 60–65 y 66–70, 0,46 en 71–76 y 0,42 en 77+, con IC fuertemente superpuestos. Si se tradujera ingenuamente a una tasa anual sin re-entrada (p^(1/7,7)), esto equivale a ~0,925 (60–70), ~0,90 (71–76) y ~0,89 (77+) en hombres, y ~0,87–0,88 en mujeres hasta 76 y ~0,81 en mujeres 77+ (este último con n efectivo 3,9, no interpretable). Es decir, una caída de 1–3 puntos en persistencia anual entre 60–65 y 71–76: real en dirección, pequeña en magnitud y dentro del ruido muestral.
- Los rho latentes anuales (hombres 0,82–0,93 y mujeres 0,76–0,93 a 66–76, superpuestas con 60–65) apuntan a lo mismo. El hallazgo de un componente de rasgo estable más allá de un AR(1)/Markov es coherente con la literatura: un componente persistente explicaría que la persistencia observada a 7,7 años sea mayor que la que implicaría elevar a la potencia una probabilidad anual Markov.

**Abandono por enfermedad ("sick quitting"): aumenta con la edad y no debe transportarse sin ajuste.**

- En NESARC, los correlatos del abandono del alcohol varían a lo largo de la vida: a edades mayores son importantes la enfermedad cardiovascular incidente y la salud autopercibida (Dawson, Goldstein y Grant, Addiction 2013; doi 10.1111/add.12079).
- En Whitehall II (Britton y Bell, PLoS One 2015; doi 10.1371/journal.pone.0119421; n=6.011 de 61–85 años), 40% había reducido su consumo en la década previa y 11% lo había aumentado; las personas de ≥70 años tenían más probabilidad de reducir por enfermedad.
- En ELSA, con 10 años de seguimiento (Holdsworth et al., J Epidemiol Community Health 2016;70(8):764–70), quienes tenían salud autopercibida regular/mala de forma continua o en deterioro "experimentaron una reducción más pronunciada en la frecuencia de su consumo a lo largo del tiempo".
- En datos longitudinales representativos de EE.UU., el efecto de la mala salud sobre la reducción del consumo creció con la edad y fue máximo en la vejez, pero no se extendió a los bebedores con trastorno por consumo de alcohol: en algunos casos la mala salud incluso predijo menos remisión (Lee et al., Innovation in Aging 2021).

**Implicancia:** la tasa de transición a exbebedor debería tener un término de edad (o mejor, un término de salud/enfermedad si el motor lo incluye) que no está identificado solo con datos de 50–65. La EPS permite estimar ese término hasta ~76 para la parte binaria.

**Transiciones entre C1, C2 y C3+: no son estimables después de 65 en Chile.**

- Con prevalencias de C2/C3+ entre 0% y 1,8%, una celda de 400–700 personas aporta entre 0 y ~12 casos de alto consumo; no hay transiciones observables.
- Como referencia externa de magnitud, las probabilidades anuales de permanecer en el mismo estado estimadas con NESARC para personas con historia de trastorno por alcohol fueron 0,93 (abstinencia), 0,81 (riesgo bajo), 0,49 (medio), 0,51 (alto) y 0,63 (muy alto) (Barbosa et al., Med Decis Making 2019; doi 10.1177/0272989X19873627). Es decir, las categorías intermedias y altas son mucho menos persistentes que la abstinencia, en cualquier edad.
- La mejor opción es usar los parámetros de 50–65 para C1↔C2↔C3+ sin interacción de edad (o con la pendiente de edad común del modelo ordinal) y dejar que la calibración a las marginales 66–79 corrija el nivel.

**Sesgo de supervivencia y de atrición.**

- La atrición en estudios longitudinales de alcohol no es aleatoria: quienes se pierden tienen mayor mortalidad e incidencia de enfermedades relacionadas con el alcohol (Thygesen et al., Addiction 2008; doi 10.1111/j.1360-0443.2008.02241.x).
- Los meta-análisis de alcohol y mortalidad muestran que las cohortes reclutadas a edades mayores están más expuestas a sesgos de selección de por vida: más exbebedores enfermos en el grupo de referencia y eliminación desproporcionada de bebedores que murieron (Stockwell et al., J Stud Alcohol Drugs 2016; doi 10.15288/jsad.2016.77.185; Zhao et al., JAMA Netw Open 2023).
- **Implicancia para el motor:** si la mortalidad del motor ya depende de la categoría de consumo, las transiciones deben estimarse condicionadas a sobrevivir (como en los pares VI→VIII de EPS) y la caída poblacional de C2/C3+ con la edad emergerá en parte de la mortalidad diferencial. Si además se impone la caída transversal observada en las marginales, se cuenta dos veces el efecto de selección.

### 3. Cómo manejan las edades mayores los modelos publicados

| Modelo | Rango de edad | Consumo y transiciones a edades mayores | Validación reportada por edad |
|---|---|---|---|
| SIMAH (Kilian et al., Lancet Public Health 2025; Probst et al., Am J Epidemiol 2023) | 18–79 | Transiciones entre categorías OMS con regresión logística ordinal sobre datos pseudo-longitudinales BRFSS 2000–10; calibración Bayesiana por history matching (implausibilidad media <3) contra BRFSS 2011–15 y validación con BRFSS 2016–19 | El texto principal reporta resultados por sexo, educación y categoría, no por edad; el protocolo de 2023 planeaba Markov multiestado con NESARC, luego reemplazado |
| Sheffield SAPM (versiones originales) | 9 bandas, incluidas 65–74 y 75+ | Enfoque de cohorte por edad: supone distribución estable de consumo dentro de cada banda de edad; sin efectos de cohorte | No específica por edad |
| Sheffield STAPM/TAX-sim (Escocia, Gales, Inglaterra) | 18–89 | Microsimulación dinámica; en la aplicación galesa 2025 se asumió que los patrones de consumo por edad permanecen como en el corte transversal 2022, de modo que el cambio en el brazo control solo viene del envejecimiento poblacional; preferencias de bebida con un único grupo 50+ | No reportada por edad en el informe |
| InterMAHP / metodología OMS-GBD | Grupos de edad amplios, incluido 65+ | Prevalencia de bebedores por edad y sexo + distribución gamma de g/día entre bebedores, con DE predicha a partir de la media | No aplica (modelo de fracciones atribuibles) |

**Lectura:** ninguno de los modelos de referencia "extrapola" ciegamente; SIMAH usa datos observados hasta 79 (BRFSS cubre todas las edades) y Sheffield usa encuestas que cubren hasta 89 con supuestos de estabilidad por edad. El problema de micsim es distinto, porque ENPG se corta en 65; por eso necesita un anclaje externo (EPS/ENCAVI), no una extrapolación paramétrica pura.

### 4. Medición en personas mayores

- **Gramos por trago:** el supuesto de 12 g/vaso de la EPS está dentro del rango de 10–14 g por trago estándar usado en la armonización internacional de Calvo et al. 2020. El error es mayor para el vino (vasos más grandes en el hogar) y los destilados servidos en casa; un error sistemático de ±2 g/trago mueve a la gente poco entre C1 y C2 porque la mayoría de las personas mayores bebe muy por debajo de los umbrales de 40/60 g.
- **AUDIT-C (ENCAVI):** en adultos mayores de la comunidad (van Gils et al., IJERPH 2021;18(17):9266; n=1.577, donde 27,3% de los hombres y 12,3% de las mujeres bebían >10 unidades/semana), el punto de corte óptimo del AUDIT-C para consumo >10 unidades/semana fue ≥5 en hombres (sensibilidad 76,5%, especificidad 85,3%) y ≥4 en mujeres (sensibilidad 100%, especificidad 74,1%). En residentes de hogares de ancianos, con etilglucurónido en cabello como referencia, un AUDIT-C ≥4 en hombres y ≥2 en mujeres detectó consumo ≥10 g/día. Un estudio finlandés de validez predictiva (Addiction, doi 10.1111/add.70473; cinco encuestas poblacionales 2011–2017 vinculadas a registros nacionales hasta 2023, n=103.567) sugiere cortes de 5 en hombres de 65–79 y 3 en hombres ≥80, y de 3 en mujeres de 65–79 y 2 en mujeres ≥80. Como el AUDIT-C es una escala ordinal de frecuencia × cantidad, sirve para estimar prevalencia de bebedores y para calibrar, pero convertirlo a g/día requiere supuestos sobre el punto medio de cada categoría.
- **Umbrales de HED:** la guía de NIAAA (Rethinking Drinking) aconseja que hombres y mujeres mayores de 65 años no tomen más de 3 tragos en un mismo día ni más de 7 por semana. Los umbrales de 5+/4+ son menos informativos en mayores; la ausencia de ítems HED en EPS y ENCAVI limita el modelado de patrones episódicos pero no afecta a las categorías basadas en volumen medio.
- **Ventana temporal:** el ítem EPS "¿bebe?" sin ventana explícita y la prevalencia mensual de 42,6% (hombres 51,6%, mujeres 34,2%) del estudio telefónico SENDA 2021 en mayores sugieren que las prevalencias dependen fuertemente del instrumento; por eso es indispensable la calibración a ENPG en 60–65 en lugar de usar los niveles EPS tal cual. La ENS 2016–17 reportó 4,8% de consumo riesgoso (AUDIT) en 65+.

## Recomendaciones

1. **Extender el motor a 79 años, no a 99.** Es el límite que usa SIMAH y es donde EPS y ENCAVI todavía tienen muestras útiles. Para 80+ solo se justificaría un bloque con supuesto explícito y análisis de sensibilidad.
2. **Marginales 66–79 por sexo:** estimar un modelo de dos partes (participación logística + volumen gamma entre bebedores) con spline natural de edad en datos pooled EPS (olas VI–VIII) y ENCAVI, incluyendo un indicador de fuente/instrumento. Calibrar el nivel a ENPG mediante un desplazamiento en la escala logit (participación) y log (volumen) estimado en 60–65, suponiendo que el sesgo del instrumento no cambia con la edad; probar la sensibilidad a ese supuesto.
3. **Colas C2/C3+:** no estimarlas celda por celda. Derivarlas de la gamma con DE = 1,171×media (hombres) y 1,258×media (mujeres) (Kehoe et al., Popul Health Metr 2012; doi 10.1186/1478-7954-10-6), donde la media entre bebedores declina suavemente con la edad. Contrastar las prevalencias implícitas de C2/C3+ con el rango observado de 0–1,8%.
4. **Transiciones:** para la parte binaria, estimar directamente en EPS 50–76 con término de edad continuo y efecto aleatorio individual (componente de rasgo). Para C1↔C2↔C3+, usar el modelo ordinal de 50–65 sin interacción edad×categoría y recalibrar el intercepto con history matching contra las marginales del punto 2, como hace SIMAH.
5. **Validación mínima:**
   - Predicción fuera de muestra por edad: estimar en ≤70, predecir prevalencias y persistencia en 71–76.
   - Pseudo-cohortes: simular desde la distribución de 60–65 en la ola VI y comparar con 66–76 en la ola VIII (incluido el efecto de período).
   - Comparar transiciones implícitas a 7,7 años del modelo anual con las observadas en los pares VI→VIII; si el modelo Markov subestima la persistencia, incorporar el componente de rasgo.
   - Revisar que la mortalidad diferencial por categoría no duplique la caída de C2/C3+.
6. **Reportar incertidumbre de forma proporcional:** las diferencias de 1–3 puntos porcentuales en persistencia anual entre 60–65 y 71–76 no son relevantes en la práctica frente a la incertidumbre del nivel de prevalencia; concentrar los análisis de sensibilidad en el nivel de C2/C3+ y en la tasa de abandono por enfermedad, que sí mueven los resultados de carga atribuible.

## Advertencias

- La mayor parte de la evidencia longitudinal viene de países de altos ingresos (EE.UU., Inglaterra, Europa); la evidencia latinoamericana (MHAS, EPS) es mayormente descriptiva o transversal, y la pendiente de edad varía entre países.
- Los estudios de trayectorias (p. ej., HRS) están condicionados a sobrevivir y responder, por lo que tienden a subestimar la salida de las categorías altas por muerte.
- No se pudo verificar en el apéndice de SIMAH qué categorías de edad usa el modelo ordinal ni si reporta ajuste específico para 65–79; tampoco se pudo confirmar en la documentación técnica de TAX-sim cómo se modela el consumo a edades mayores más allá del supuesto de estabilidad del informe galés.
- Las prevalencias de bebedores en mayores chilenos difieren mucho según el instrumento (EPS, ENS, ENCAVI, SENDA 2021), por lo que cualquier anclaje debe tratarse como dependiente del instrumento.
- En mujeres de 77+ el n efectivo de transiciones (3,9) hace que esas estimaciones no sean interpretables; tratarlas como ausentes, no como evidencia de una caída abrupta.

## Fuentes

Los títulos no se conservaron en la herramienta de investigación; solo los enlaces.

- https://bmcmedicine.biomedcentral.com/articles/10.1186/s12916-015-0273-z
- https://link.springer.com/article/10.1186/s12916-015-0273-z
- https://d-nb.info/1117914097/34
- https://pmc.ncbi.nlm.nih.gov/articles/PMC2841726/
- https://pmc.ncbi.nlm.nih.gov/articles/PMC7585691/
- https://pmc.ncbi.nlm.nih.gov/articles/PMC8131222
- https://sheffield.ac.uk/media/13085/download
- https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4016750/
- https://onlinelibrary.wiley.com/doi/10.1111/j.1360-0443.2005.01299.x
- https://digital.nhs.uk/data-and-information/publications/statistical/adult-psychiatric-morbidity-survey/survey-of-mental-health-and-wellbeing-england-2023-24/alcohol-dependence
- https://pmc.ncbi.nlm.nih.gov/articles/PMC2891546/
- https://www.desarrollosocialyfamilia.gob.cl/noticias/gobierno-entrega-resultados-del-primer-estudio-sobre-consumo-de-drogas-y-alcohol-en-personas-mayores
- https://onlinelibrary.wiley.com/doi/10.1111/add.12079
- https://onlinelibrary.wiley.com/doi/10.1111/add.12137
- https://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0119421
- https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8679253/
- https://doi.org/10.1177/0272989x19873627
- https://pubmed.ncbi.nlm.nih.gov/18554348/
- https://onlinelibrary.wiley.com/doi/10.1111/j.1360-0443.2008.02241.x
- https://www.researchgate.net/publication/299379564_Do_Moderate_Drinkers_Have_Reduced_Mortality_Risk_A_Systematic_Review_and_Meta-Analysis_of_Alcohol_Consumption_and_All-Cause_Mortality
- https://pmc.ncbi.nlm.nih.gov/articles/PMC10066463/
- https://jamanetwork.com/journals/jamanetworkopen/fullarticle/2802963
- https://pmc.ncbi.nlm.nih.gov/articles/PMC12478644
- https://www.thelancet.com/journals/lanpub/article/PIIS2468-2667(25)00165-3/fulltext
- https://jamanetwork.com/journals/jama-health-forum/fullarticle/2851858
- https://eprints.whiterose.ac.uk/id/eprint/198292/1/SIMAH_protocol_technical%20review.pdf
- https://link.springer.com/article/10.1007/s10479-013-1451-z
- https://www.gov.wales/sites/default/files/statistics-and-research/2025-07/new-modelling-of-alcohol-pricing-policies-alcohol-consumption-and-harm-in-wales_0.pdf
- https://sarg-sheffield.ac.uk/wp-content/uploads/2024/11/sarg-scottish-mup-report-2023.pdf
- https://www.ias.org.uk/2018/01/15/intermahp-a-new-way-of-calculating-alcohol-attributable-fractions/
- https://pmc.ncbi.nlm.nih.gov/articles/PMC3352241
- https://eprints.whiterose.ac.uk/id/eprint/231116/1/1-s2.0-S2468266725001653-main.pdf
- https://pubmed.ncbi.nlm.nih.gov/28719105
- https://www.latercera.com/paula/noticia/alcohol-y-adultos-mayores-el-problema-que-no-queremos-ver/X5EP2J34KRFVRIU2PHVTI5FP5A/
- https://www.emol.com/noticias/Nacional/2019/12/27/971677/Encuesta-Minsal-chilenos-trastorno-alcohol.html
- https://link.springer.com/article/10.1186/1478-7954-10-6
- https://pmc.ncbi.nlm.nih.gov/articles/PMC4850697
