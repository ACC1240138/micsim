# Predictores para la probabilidad inversa de atrición en EPS (homologables a TSM): conjunto núcleo, extensión y veredicto sobre las auxiliares exclusivas de la EPS

**Respuesta corta:** usa un núcleo de 11 predictores medidos en la línea base: estado de consumo colapsado, log g/día, sexo × edad, educación, región/macrozona, tenencia de vivienda, pareja, trabajo, tabaquismo, PHQ-9 y salud autopercibida. Todos predicen tanto la atrición como el consumo de alcohol, y todos existen en la EPS 2015 y en el TSM. La recomendación de "Uso de Variables Exclusivas de la EPS como Auxiliares" **no** es lo bastante buena como para priorizarlas sobre este núcleo. Predicen la atrición, sobre todo la mudanza y el número de visitas, pero casi no hay evidencia de que se correlacionen con el consumo de alcohol o con su cambio. Además, no son homologables al TSM, su disponibilidad es incierta y no explican el mecanismo dominante de VI→VII, que fue el corte del trabajo de campo por la pandemia según región.

## TL;DR

- **Núcleo (11 variables, todas homologables):** estado de origen colapsado (N0/FD/C1/C2/C3+C4), log g/día previos, sexo × grupo de edad, educación (3 niveles), macrozona/región, tenencia de la vivienda, pareja, trabajó la semana pasada, fuma actualmente, PHQ-9 ≥10 y salud autopercibida mala/regular. Van con pocas categorías y sin interacciones salvo sexo × edad.
- **Auxiliares exclusivas de la EPS:** veredicto **NO priorizar**. Úsalas solo (i) en la etapa de localización/contacto de VII→VIII, (ii) como análisis de sensibilidad y (iii) como diagnóstico del "continuum of resistance". La única evidencia cuantitativa que las vincula con el alcohol es modesta. En la Health Survey for England, las mujeres que necesitaron 7 o más visitas tenían OR 1,19 de superar el límite diario y OR 1,23 de consumo episódico intenso; en hombres el efecto no fue significativo tras el ajuste.
- **SuperLearner:** usa una biblioteca pequeña y regularizada, ajuste con validación cruzada (cross-fitting) y pesos estabilizados cuyo numerador contenga exactamente las covariables del modelo de transición. Evalúa por balance y por tamaño efectivo de muestra (ESS) dentro de cada estado de origen, no por AUC. Colapsa C3+C4, y si hace falta C2–C4, dentro del modelo de atrición. La muerte y el impedimento se sacan del conjunto en riesgo; no son atrición.

## Hallazgos clave

**1. Qué predice la atrición en paneles de hogares (marco localización → contacto → cooperación).**
- **Mudanza y vivienda (localización/contacto):** es el predictor más consistente entre paneles.
  - En HILDA, haberse mudado tiene un coeficiente probit de −0,754 en el modelo de contacto. La probabilidad media predicha de contacto fue 95,5 % en quienes se mudaron frente a 99,1 % en quienes no. Arrendar resta −0,230 en el contacto (Watson & Wooden 2006/2009).\[1\]
  - Lepkowski & Couper 2002, Lillard & Panis 1998, Zabel 1998 y el ECHP (Watson 2003) muestran la misma dirección.\[1\]
- **Composición del hogar y ciclo de vida:** en HILDA, ser soltero (−0,346), separado o divorciado reduce el contacto. La edad aumenta la cooperación.\[1\]
  - Quienes abandonaron entre las olas 1 y 2 de HILDA eran más a menudo jóvenes, solteros o convivientes, nacidos fuera de países angloparlantes, indígenas, sin estudios postsecundarios y residentes en departamentos. El sexo **no** fue significativo.\[2\]
- **Educación (cooperación):** en HILDA el gradiente es monótono, de +0,06 (Year 12) a +0,265 (universitario) en la respuesta dado el contacto.\[1\]
- **Empleo:** facilita el contacto (+0,19 a +0,20), probablemente por redes sociales más amplias. Las jornadas de 55 horas o más reducen la cooperación (−0,14).\[1\]
- **Salud:** una condición de salud seria y de larga duración reduce la cooperación (−0,216 en HILDA).\[1\]
- **Paradatos de la ola previa:** el número de visitas (−0,022 por visita en el contacto y −0,029 en la respuesta), las observaciones del entrevistador sobre cooperación o suspicacia y la falta de respuesta a ítems predicen la atrición en la ola siguiente.\[1\]
  - Dar contactos alternativos **no** fue significativo en HILDA, a diferencia del BHPS.\[1\]
  - En el Millennium Cohort Study, las observaciones más predictivas fueron "probabilidad de participar en la próxima ola" y "disfrutó la entrevista" (Plewis, Calderwood & Mostafa 2017).\[3\]
- **Poder explicativo bajo, como es normal:** el pseudo-R² fue 0,228 para el contacto y 0,090 para la respuesta en HILDA. Watson & Wooden lo consideran "a desired outcome".\[1\] El pseudo-R² bajo de los modelos oficiales de la EPS no es en sí una falla.
- **Paneles chilenos y latinoamericanos:** la evidencia publicada es escasa.
  - La propuesta técnica de la EPS VIII anuncia un análisis de atrición por edad, sexo, localización geográfica, situación laboral y educación, más un modelo de probabilidad de participación.\[4\] No encontré resultados publicados con magnitudes.
  - La ronda V (2012) tuvo problemas graves de respuesta y factores de expansión. Según un informe de la Subsecretaría de Previsión Social citado por La Tercera, el trabajo de campo a cargo del Observatorio Social de la Universidad Alberto Hurtado (OSUAH) tuvo tasas de respuesta "muy por debajo de lo esperado, aproximadamente 20 puntos porcentuales menos" que en rondas previas, con casos logrados "inferior a lo establecido en el contrato" y sesgos por sexo, edad y ubicación geográfica.
  - No encontré análisis de atrición publicados con coeficientes para CASEN Panel, ELSOC, ELPI ni MxFLS. **La evidencia local es débil.**

**2. Alcohol, tabaco y salud mental como predictores de no respuesta: patrón en U, efectos modestos.**
- **HUNT (Torvik et al. 2012):** tanto los bebedores intensos (OR 1,27) como los abstemios (OR 1,64) abandonaron más que los bebedores habituales moderados. El malestar mental alto también lo predijo (OR 1,84). Las asociaciones se debilitan al ajustar por otras variables. Los autores lo resumen así: "moderately associated with non-response, though probably not a major cause".\[5\]
- **Lahaut et al. 2002:** hay evidencia fuerte de sobrerrepresentación de abstemios entre los no respondentes, pero débil para los bebedores excesivos frecuentes.\[6\]
- **NESARC 1→2:** los no usuarios abandonaron más, pero entre los usuarios abandonaron más los de consumo frecuente. Es otra U.\[7\]
- **Christensen et al. 2015 (Dinamarca, vinculación con registros):** los no respondentes tuvieron HR 1,56 de morbilidad relacionada con el alcohol y HR 1,88 de mortalidad relacionada con el alcohol.\[8\]
  - En términos absolutos la diferencia es pequeña: morbilidad de 2,04 % frente a 3,10 % y mortalidad de 0,36 % frente a 0,67 % (Fergusson & Boden 2015).\[9\]
  - **Dato clave para el diseño:** los no respondentes *no contactables* y los *enfermos o discapacitados* tuvieron HR más altos que quienes *rechazaron*.\[10\] El sesgo ligado al alcohol se concentra en la localización/contacto y en la incapacidad, no en el rechazo.
- **Escocia (Gorman et al. 2014, 2017):** los respondentes de la Scottish Health Survey tenían cerca de dos tercios de la tasa poblacional de daño atribuible al alcohol (RR 0,69).\[11\] La corrección con registros subió el consumo estimado sobre todo en hombres en edad laboral.\[12\]
- **Continuum of resistance (Boniface, Scholes, Shelton & Connor 2017, PLOS ONE, HSE 2011–13, contactos agrupados en 1–6 frente a 7 o más):** las mujeres que necesitaron 7 o más visitas tenían OR 1,19 de superar el límite diario y OR 1,23 de consumo episódico intenso; en hombres no fue significativo tras el ajuste.\[11\]
  - Extrapolando a los no respondentes, el consumo medio sube 1,8 unidades por semana en hombres (+12,6 %) y 1,5 en mujeres (+20,5 %).\[11\]
  - Es una extrapolación que depende de un **supuesto** no validado: que quienes necesitaron 7 o más visitas "have similar alcohol consumption to non-participants".
- **Salud mental:** en NEMESIS, la psicopatología "did not have a strong impact on attrition", con 79,4 % de reentrevista.\[13\] En NEMESIS-2, la atrición se asoció sobre todo a menor edad y menor educación.\[14\]
  - **Lectura:** la depresión y el malestar predicen la atrición de forma débil a moderada. Su valor está en que también predicen el consumo.

**3. ¿Sesga la atrición las TRANSICIONES, no solo las prevalencias?** La evidencia directa es **escasa e indirecta**.
- **Thygesen et al. 2008 (Copenhagen City Heart Study, 28 años):** la atrición no fue aleatoria y se asoció a mortalidad, cánceres digestivos altos y hepatopatía alcohólica. Aun así, la asociación entre alcohol y mortalidad "did not differ by statistical method for handling missing data".\[15\] Las *asociaciones* condicionales fueron más robustas que las prevalencias.
- Esto concuerda con la teoría: si la atrición depende del estado de origen y de covariables que también están en el modelo de transición, condicionar en ellas protege las probabilidades de transición.
- El sesgo aparece si la atrición depende del **cambio** de consumo entre olas, por ejemplo cuando alguien empeora, se muda y se pierde. Eso es MNAR respecto a la línea base y ningún peso basado en la línea base lo corrige del todo. Los cambios en la vida entre olas, como la mudanza o el cambio de empleo, se asocian más con la atrición que el estado previo (Voorpostel & Lipps 2011; Trappmann et al. 2015).\[16\]
- **Práctica de los paneles usados para transiciones de alcohol:**
  - **NESARC Ola 2:** peso final de la Ola 1 × 3 factores.\[17\] El primero ajusta la no respuesta según características sociodemográficas y **presencia de cualquier trastorno por uso de sustancias en la Ola 1**; después se postestratifica por región, edad, sexo y raza.\[18\] La respuesta de la Ola 2 fue 86,7 % (acumulada 70,2 %).\[19\]\[20\]
  - **Puka et al. (Addiction 2022/2023):** estimaron matrices de Markov de estados de consumo con NESARC I–II, usando los pesos oficiales "that account for the non-response and sample attrition".\[19\]
  - **Precedente directo:** en el estudio SIMAH, el peso de atrición incluía una variable de sustancias en la línea base además de demografía y educación. Tu diseño, que incluye el estado de origen, es coherente con ese estándar.

**4. Regla de selección de variables.**
- **Little & Vartivarian 2005:** una covariable reduce el sesgo solo si se asocia **tanto** con la respuesta **como** con el resultado. Si se asocia solo con la respuesta, añade varianza sin reducir el sesgo. Si se asocia con el resultado, puede incluso reducir la varianza.\[21\]\[22\]
- **Kreuter et al. 2010:** en cinco encuestas, la mayoría de las auxiliares y paradatos tuvieron |ρ| con la respuesta menor que 0,1 y |ρ| con el resultado menor que 0,2. Eso no alcanza para reducir el sesgo de forma importante.\[23\]
- **Biemer, Chen & Wang 2013 (NSDUH, encuesta de sustancias):** el modelo de callbacks, basado en paradatos de esfuerzo, "could not remove" el sesgo no ignorable. Los modelos más complejos a veces *aumentaron* el sesgo aunque mejorara el ajuste.\[24\]\[25\]
- Este es el argumento central contra priorizar los paradatos, y es análogo a la regla de Brookhart et al. 2006 para propensity scores: incluir predictores del resultado y evitar los que solo predicen la exposición.

## Detalles

### (a) Conjunto NÚCLEO para el modelo de atrición/seguimiento (ordenado por prioridad)

| # | Constructo | EPS 2015 | TSM | Codificación armonizada | Mecanismo | Evidencia (atrición) | ¿Predice alcohol? |
|---|---|---|---|---|---|---|---|
| 1 | Estado de consumo en origen | F.13–F.15 → N0/FD/C1–C4 | AUDIT-C (frecuencia, cantidad, ≥6) | 4–5 niveles: N0, FD, C1, C2, C3+C4 (si ESS bajo: C2–C4). En TSM: no bebe / bajo / riesgo / HED mensual+ | Resultado; cooperación (U) | Moderada: HUNT OR 1,27 intensos y 1,64 abstemios; Lahaut 2002; NESARC | **Sí (es el resultado)** |
| 2 | Intensidad previa | log(g/día+1) | log cantidad × frecuencia | Continuo, spline con ≤3 df | Resultado | Indirecta (Boniface 2017; Christensen 2015) | **Sí** |
| 3 | Sexo × grupo de edad | Sexo, edad | a-módulo sexo/edad | 2 × 4 (18–29, 30–44, 45–59, 60–65) | Contacto/cooperación | Fuerte y consistente (HILDA, BHPS, NEMESIS-2) | **Sí, fuerte** |
| 4 | Educación | A.12.n | b4a | 3 niveles | Cooperación | Fuerte (HILDA: +0,06 a +0,27; NEMESIS-2) | **Sí** (gradiente social del consumo) |
| 5 | Región/macrozona | Región | Región (macrozona) | 4–5 macrozonas; en VI→VII, región (o el propensity oficial de visita) | Contacto (diseño de campo) | **Dominante en VI→VII** (logit oficial −1,1 a +0,7) | Moderado (heterogeneidad regional) |
| 6 | Tenencia de vivienda | D.7 | f1 (en R7 solo nuevos: arrastrar de rondas previas) | Propia vs. no propia | Localización | Fuerte (HILDA arrendatario −0,23; mudanza −0,75) | Débil–moderado (proxy de estabilidad/NSE) |
| 7 | Pareja | I.1 | a6 | Con pareja vs. sin pareja | Contacto/localización | Fuerte (HILDA soltero −0,35) | **Sí** (estado civil y trayectorias de consumo) |
| 8 | Trabajó semana pasada | B.2 | c1 | Sí/No | Contacto | Moderada (HILDA +0,19) | Moderado |
| 9 | Fuma actualmente | F.12.a | e4a | Sí/No | Cooperación/salud | Moderada (Christensen: morbilidad por tabaco HR 1,15) | **Sí, fuerte** (co-uso) |
| 10 | Síntomas depresivos | F.69 (PHQ-9) | f15a–i (PHQ-9) | PHQ-9 ≥10 vs. <10 (o PHQ-2 ≥3 si se armoniza con TSM) | Cooperación/incapacidad | Débil–moderada (HUNT malestar OR 1,84 crudo, atenuado; NEMESIS débil) | **Sí** |
| 11 | Salud autopercibida | A.10 (6 pts) | f7a (1–7) | Mala/regular vs. buena o mejor | Incapacidad/cooperación | Moderada (HILDA −0,22; ill/disabled con HR altos en Christensen) | Moderado (incluye "sick quitters") |

Notas de uso:
- Las variables 1 a 4 (más el período) **ya están** en el modelo de transición. Deben ir en el modelo de atrición **y** en el numerador de la estabilización. Así el peso solo corrige el desbalance residual que causan las variables 5 a 11.
- No uses interacciones salvo sexo × edad. Si quieres un efecto de período, permite período × macrozona, porque el corte por la pandemia es específico de VI→VII.
- Para las variables con faltantes por ítem por debajo de 5 %, usa imputación simple con indicador de faltante o una imputación múltiple ligera. Por encima de 10 %, saca la variable del núcleo (ver e).

### (b) Conjunto de EXTENSIÓN (solo para sensibilidad)

| Constructo | EPS / TSM | Codificación | Por qué en extensión |
|---|---|---|---|
| Sistema de salud | F.1 / f7b2 | FONASA A–B / FONASA C–D / ISAPRE-otro | Proxy de NSE redundante con educación |
| Enfermedades crónicas | F.38 / f7b | 0 / ≥1 | Solapa con salud autopercibida |
| Discapacidad | EPS / TSM | Sí/No | Pocas celdas; útil para separar el impedimento |
| Satisfacción con la vida | J.0.b / f14 | ≤5 / 6–7 / ≥8 | Correlato del malestar; evidencia de atrición indirecta |
| Migrante, pueblo indígena | EPS / TSM | Sí/No | Predicen atrición (HILDA: nacidos fuera −0,26 a −0,50), pero son celdas pequeñas |
| Auxiliares exclusivas de la EPS | Portada/hoja de contacto | Ver (c) | No homologables; disponibilidad incierta |

### (c) Veredicto sobre las "Variables Exclusivas de la EPS como Auxiliares"

**Veredicto: útiles pero NO prioritarias.** No las pongas por encima del núcleo ni las uses en el modelo principal homologado. Por qué:
1. **Predicen la atrición, pero casi no hay evidencia de que predigan el alcohol.**
   - Mudanza o intención de mudarse: es el predictor de no contacto más robusto. En Understanding Society, Salvatore, Lugtig & Struminskaya (2026, JSSAM) encontraron que "expecting to move in the next year is associated with a higher risk of attrition (non-contact and other)"; un RRR de alrededor de 1,9 reportado de forma secundaria no pude confirmarlo. En la BHPS, Uhrig (2008) concluye que la "high likelihood of geographic mobility" predice el no contacto posterior.
   - Número de visitas: efecto modesto en la atrición (HILDA, −0,02 a −0,03 por visita).
   - Contactos alternativos: no significativo en HILDA.
   - Correo electrónico: no encontré evidencia publicada para ninguno de sus usos.
   - **Vínculo con el alcohol:** solo el esfuerzo de campo (visitas) tiene un vínculo cuantificado, y es modesto: OR de alrededor de 1,2 solo en mujeres de la HSE, transversal.
   - No encontré estudios que vinculen la intención de mudarse, los contactos alternativos o el correo electrónico con el nivel de consumo o con su cambio.
   - Por Little & Vartivarian y Kreuter et al., esto implica más varianza sin una reducción de sesgo demostrada. En NSDUH, ajustar con paradatos de esfuerzo no eliminó el sesgo.\[24\]
2. **No son homologables al TSM**, y tu objetivo incluye que el modelo sea comparable entre los dos paneles.
3. **Disponibilidad incierta:** no figuran en el manual público de la EPS 2015. Habría que pedir la base confidencial de trabajo de campo.
4. **En VI→VII, el mecanismo dominante es el corte por la pandemia**, que depende de la región y del orden de la ruta de campo, no de la movilidad de la persona. Las variables de localización no explican ese mecanismo. Además, "se cambió de dirección desde la ronda anterior" se mide en la ola de destino, solo para quienes respondieron, y es posterior a la línea base: **no se puede usar** como predictor en VI→VII.
5. **Matiz a favor:** Christensen et al. 2015 muestra que los *no contactables* tienen más daño por alcohol que quienes *rechazan*. Por eso la etapa de localización/contacto sí importa para el sesgo por alcohol, y la mudanza podría ser un proxy de inestabilidad vital. Es evidencia indirecta, no un vínculo medido.

**Cómo usarlas de todos modos:**
- **Modelo por etapas en VII→VIII:** en la etapa de *localización/contacto*, agrega la mudanza entre VI y VII (medida en VII, que en esa transición es la línea base), la intención de mudarse y el número de visitas en VII. No las incluyas en la etapa de cooperación.
- **Sensibilidad:** reestima las matrices con y sin estas variables. Si las transiciones desde C2–C4 cambian menos de alrededor de 1–2 puntos porcentuales y el ESS empeora, quédate con el núcleo.
- **Diagnóstico del continuum of resistance:** entre los respondentes, compara la distribución de los estados de consumo según el número de visitas (1, 2, 3 o más). Si la gente difícil de contactar bebe más *dentro* de las celdas de sexo × edad × educación, eso sugiere MNAR residual. Repórtalo como análisis de sensibilidad, por ejemplo con delta-ajuste o pattern-mixture, en vez de meterlo en los pesos.

### (d) Recomendaciones para el SuperLearner

- **Biblioteca, pequeña y regularizada:**
  1. GLM logístico con efectos principales del núcleo.
  2. GLM con sexo × edad × estado de origen colapsado.
  3. glmnet (elastic net).
  4. GAM con splines de ≤3 df para log g/día y edad.
  5. ranger con árboles poco profundos y min.node.size grande (≥50).
  6. xgboost o GBM con profundidad 2, eta ≤0,05 y early stopping.
  - Con alrededor de 8.000 pares y celdas de consumo alto de decenas, los aprendices flexibles sobreajustan justo donde menos datos hay.
  - Lee, Lessler & Stuart (2010, 2011) muestran que el boosted CART da pesos menos extremos que la regresión logística mal especificada. También muestran que truncar los pesos del boosting o de random forest no mejora y puede inducir sesgo.\[26\]
- **Validación cruzada y cross-fitting:** usa V = 10, estratificado por el indicador de observación **y** por el estado de origen colapsado, para que cada fold tenga casos C3+C4. Usa predicciones fuera de fold para construir los pesos. Agrupa por hogar si hay más de un miembro.
- **Criterio:** el SuperLearner minimiza la log-verosimilitud, pero la elección final debe basarse en el **balance** y el **ESS**, no en el AUC. Kern, Klausch & Kreuter (2019) y los modelos preentrenados de paneles alcanzan AUROC de 0,84–0,88, pero una buena predicción de la atrición no garantiza reducir el sesgo.\[27\]
- **Pesos estabilizados:** sw = P(O=1 | estado de origen colapsado, sexo × edad, período, educación) / P(O=1 | núcleo completo). El numerador debe usar exactamente las covariables del modelo de transición y estimarse por GLM en la misma muestra. Multiplica por el peso longitudinal o de la línea base oficial **solo** si lo usas también en la estimación de las matrices, y evita modelar dos veces la región. Verifica con el balance contra la muestra completa de la línea base ponderada por el peso transversal.
- **Truncamiento:** mantén el piso de probabilidad en 0,02 y reporta cuántos casos lo tocan. Compara los pesos sin truncar con p1/p99 y p0,5/p99,5. Si el truncamiento cambia las transiciones desde C3+C4, es una señal de no positividad, y la respuesta correcta es simplificar el modelo, no truncar más (Seaman & White 2013).\[28\]
- **Diagnósticos obligatorios, por estado de origen:**
  1. Diferencia de medias estandarizada (SMD) entre los retenidos ponderados y la línea base completa, para cada predictor del núcleo y de la extensión. La meta es |SMD| < 0,1.
  2. ESS de Kish = (Σw)²/Σw² en cada estado de origen y período. Señal de alarma: ESS de C3+C4 menor que alrededor de 50 % de n.
  3. Peso máximo / peso medio y la proporción del peso total que concentra el 1 % superior.
  4. Media de los pesos estabilizados cercana a 1, también en cada estrato.
  5. Las matrices de transición sin ponderar, con el IPW actual y con el nuevo, lado a lado.
- **Celdas escasas:** con solo 69 pares C3 y 29 C4 observados, cualquier término específico de C3 o C4 en el modelo de atrición se estima con muy pocos eventos. Colapsa C3+C4, o C2–C4 si el ESS cae, y deja que log g/día capture el gradiente dentro de ese grupo. Como regla convencional, apunta a al menos 10–20 eventos de atrición por parámetro. Si no se cumple, quita primero las variables 6 a 8 del modelo **de esas celdas**, no las de salud.
- **Alternativa robusta:** si el ESS de los estados altos queda bajo, estima las transiciones con un estimador doblemente robusto (AIPW/TMLE con el mismo SuperLearner). Así el sesgo se protege por el modelo de resultado aunque los pesos sean imperfectos.

### (e) Qué NO incluir, y cómo tratar la muerte y el impedimento

- **Variables medidas después de la línea base:** cambio de domicilio en la ola de destino, modo de la entrevista en la ola de destino y cualquier cosa recogida en las encuestas telefónicas de Continuidad o Re-entrevista para predecir la observación en esa misma transición. Todas condicionan en el futuro.
- **Variables que predicen solo la atrición:** carga de trabajo o identidad del entrevistador, fecha de visita, número de llamadas sin una correlación demostrada con el consumo y contactos alternativos. Van solo en la sensibilidad (c).
- **Variables con mucho faltante o no homologables en el modelo principal:** tenencia de la vivienda en TSM R7 para los antiguos (arrastrar de rondas previas o excluir en el TSM), ingreso y estrés financiero (este último existe solo en el TSM).
- **Muerte:** no es atrición. En un microsimulador estilo SIMAH la mortalidad se modela por separado. Las transiciones de consumo son condicionales a sobrevivir, así que los fallecidos, identificados por el cuestionario de fallecidos, salen del conjunto en riesgo del modelo de seguimiento, como en HILDA, que excluye a fallecidos y emigrados del denominador.\[1\]
- **Impedidos:** sácalos también del conjunto en riesgo de la "pérdida de seguimiento". Repórtalos como un estado de salida aparte, porque son el grupo con más daño por alcohol entre los no respondentes (Christensen 2015).\[8\] Haz una sensibilidad en la que se traten como no observados con consumo imputado según su estado de origen.
- **Entrevistas por proxy y telefónicas sin módulo de alcohol:** cuentan como "localizado y cooperó, pero falta el resultado". Si modelas por etapas, la etapa final es "módulo de alcohol observado | entrevistado", y en VI→VII depende sobre todo de la región y de la fecha del corte.

## Recomendaciones (orden de ejecución)

1. Define el conjunto en riesgo: respondentes de la línea base de 18 a 65 años, menos los fallecidos y los impedidos (que se analizan aparte).
2. Ajusta el modelo de observación en VI→VII y VII→VIII por separado, o en un modelo conjunto con interacciones período × macrozona, usando el núcleo de 11 variables.
3. En VI→VII, modela de forma explícita la etapa "visitado antes del corte" con región/macrozona, o usa como covariable el propensity oficial de visita. No inviertas esfuerzo en paradatos individuales para esa transición.
4. Construye pesos estabilizados con el numerador igual a las covariables de la transición y revisa SMD y ESS por estado de origen.
5. Corre la sensibilidad con las auxiliares exclusivas de la EPS (solo VII→VIII, etapa de contacto) y el diagnóstico del continuum of resistance.
6. Para homologar con el TSM, usa el mismo núcleo con las codificaciones de la tabla. La única adaptación necesaria es que el estado de consumo del TSM sale del AUDIT-C y no distingue FD sin historia previa.

## Advertencias

- La evidencia de que la atrición sesga las **transiciones** de alcohol, y no solo las prevalencias, es indirecta. El estudio más directo (Thygesen 2008) sugiere que las asociaciones condicionales son relativamente robustas, pero no evaluó matrices de Markov.
- Casi toda la evidencia sobre alcohol y no respuesta viene de encuestas transversales o cohortes nórdicas y británicas. Su transferencia a Chile es incierta, y no encontré análisis publicados de atrición por alcohol en paneles chilenos (EPS, ELSOC, ENS, ENPG).
- El RRR de alrededor de 1,9 para la intención de mudarse se atribuye a Salvatore, Lugtig & Struminskaya (2026, JSSAM, con datos de Understanding Society) según una fuente secundaria, y no pude confirmarlo. Uhrig (2008) respalda en la BHPS solo la dirección del efecto.
- El TSM es telefónico, sobre una muestra de viviendas entrevistadas antes en persona y representativa de la población urbana adulta (2.547 casos en R11 según la infografía oficial, con tasa de respuesta de 70 %; la nota de prensa de ACHS habla de "más de 2.300 personas"). Sus resultados no son directamente extrapolables a la EPS, que es nacional y presencial.
- Ningún peso basado en la línea base corrige la atrición que depende del cambio de consumo no observado entre olas (MNAR). Para eso hace falta un análisis de sensibilidad explícito.
- Las fuentes se citan por autor y año en el texto.

## Fuentes

1. [HILDA PROJECT DISCUSSION PAPER SERIES No. 2/06, December 2006](https://melbourneinstitute.unimelb.edu.au/assets/documents/hilda-bibliography/hilda-discussion-papers/hdps206.pdf)
2. [HILDA PROJECT TECHNICAL PAPER SERIES No. 5/04, July 2004](https://melbourneinstitute.unimelb.edu.au/assets/documents/hilda-bibliography/hilda-technical-papers/htec504.pdf)
3. [Can Interviewer Observations of the Interview Predict Future Response?](https://mda.gesis.org/index.php/mda/article/view/2016.010)
4. [PROPUESTA TÉCNICA](https://www.camara.cl/verDoc.aspx?prmID=293209&prmTIPO=DOCUMENTO_COMISION)
5. [Alcohol use and mental distress as predictors of non-response in a general population health survey: the HUNT study - PubMed](https://pubmed.ncbi.nlm.nih.gov/21544604/?dopt=Abstract)
6. [Non-response bias in a sample survey on alcohol consumption — Tilburg University Research Portal](https://research.tilburguniversity.edu/en/publications/non-response-bias-in-a-sample-survey-on-alcohol-consumption)
7. [The importance of post hoc approaches for overcoming non-response and attrition bias in population-sampled studies](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4720721/)
8. [What is wrong with non‐respondents? Alcohol‐, drug‐ and smoking‐related mortality and morbidity in a 12‐year follow‐up study of respondents and non‐respondents in the Danish Health and Morbidity Survey](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4538793/)
9. [Exploring issues arising from survey non‐response - Fergusson - 2015 - Addiction - Wiley Online Library](https://onlinelibrary.wiley.com/doi/10.1111/add.12968)
10. [What is wrong with non‐respondents? Alcohol‐, drug‐ and smoking‐related mortality and morbidity in a 12‐year follow‐up study of respondents and non‐respondents in the Danish Health and Morbidity Survey - Christensen - 2015 - Addiction - Wiley Online Library](https://onlinelibrary.wiley.com/doi/10.1111/add.12939)
11. [Assessment of Non-Response Bias in Estimates of Alcohol Consumption: Applying the Continuum of Resistance Model in a General Population Survey in England](https://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0170892)
12. [Adjustment for survey non‐representativeness using record‐linkage: refined estimates of alcohol consumption by deprivation in Scotland](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5467727/)
13. [(PDF) The Structure and Stability of Common Mental Disorders](https://www.researchgate.net/publication/242573897_The_Structure_and_Stability_of_Common_Mental_Disorders)
14. [Sociodemographic and psychiatric predictors of attrition in the Netherlands Mental Health Survey and Incidence Study-2 (NEMESIS-2)](https://www.researchgate.net/publication/243966171_Sociodemographic_and_psychiatric_predictors_of_attrition_in_the_Netherlands_Mental_Health_Survey_and_Incidence_Study-2_NEMESIS-2)
15. [Effects of sample attrition in a longitudinal study of the association between alcohol intake and all‐cause mortality - Thygesen - 2008 - Addiction - Wiley Online Library](https://onlinelibrary.wiley.com/doi/10.1111/j.1360-0443.2008.02241.x)
16. [The HILDA survey four years on](https://www.researchgate.net/publication/4988578_The_HILDA_survey_four_years_on)
17. [Socioeconomic status, alcohol use disorders, and depression: A population-based study - ScienceDirect](https://www.sciencedirect.com/science/article/pii/S016503272101452X)
18. [(PDF) Prospective Follow-Up of Empirically Derived Alcohol Dependence Subtypes in Wave 2 of the National Epidemiologic Survey on Alcohol and Related Conditions (NESARC): Recovery Status, Alcohol Use Disorders and Diagnostic Criteria, Alcohol Consumption Behavio](https://www.researchgate.net/publication/43072191_Prospective_Follow-Up_of_Empirically_Derived_Alcohol_Dependence_Subtypes_in_Wave_2_of_the_National_Epidemiologic_Survey_on_Alcohol_and_Related_Conditions_NESARC_Recovery_Status_Alcohol_Use_Disorders_a)
19. [Behavioral stability of alcohol consumption and socio‐demographic correlates of change among a nationally representative cohort of US adults - Puka - 2023 - Addiction - Wiley Online Library](https://onlinelibrary.wiley.com/doi/10.1111/add.16024)
20. [The National Epidemiologic Survey on Alcohol and Related Conditions (NESARC) Waves 1 and 2: Review and summary of findings - PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC4618096/)
21. [Does Weighting for Nonresponse Increase the Variance of Survey Means?](https://www.researchgate.net/publication/4744554_Does_Weighting_for_Nonresponse_Increase_the_Variance_of_Survey_Means)
22. [EconPapers: Does Weighting for Nonresponse Increase the Variance of Survey Means?](https://econpapers.repec.org/RePEc:bep:mchbio:1034)
23. <https://jpsm.umd.edu/sites/jpsm.umd.edu/files/pubs/Using%20proxy%20measures%20and%20other%20coorelates%20of%20survey%20outcomes.pdf>
24. [2013 - National Survey on Drug Use and Health - NCBI Bookshelf](https://www.ncbi.nlm.nih.gov/books/NBK519719/)
25. [Incorporating Level of Effort Paradata in the NSDUH Nonresponse Adjustment Process \[Internet\] - PubMed](https://pubmed.ncbi.nlm.nih.gov/30199188/)
26. [Weight Trimming and Propensity Score Weighting](https://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0018174)
27. [Survey Research Methods (2025) Vol. 19, No. 2, pp. 123-137](https://ojs.ub.uni-konstanz.de/srm/article/download/8473/version/8019/7663)
28. [Review of inverse probability weighting for... : Statistical Methods in Medical Research](https://www.ovid.com/journals/smmr/fulltext/10.1177/0962280210395740~review-of-inverse-probability-weighting-for-dealing-with)
