# Microsimulación de alcohol en Chile (FONDECYT 1240138): armonización ENPG–EPS, uso de la estructura ordinal y de datos externos, anualización y criterios para revistas

Mi recomendación es mantener la matriz empírica "A", con tres cambios que casi no agregan decisiones de parametrización. Primero, en las filas pequeñas, encoger hacia la fila vecina alineada por movimiento relativo, en vez de hacerlo hacia celdas más grandes. Segundo, fusionar C3 y C4 o restringir el generador a saltos adyacentes. Tercero, ajustar por raking (IPF) los flujos anuales para que reproduzcan las prevalencias de la ENPG. SIMAH, la referencia del proyecto, hizo esencialmente lo mismo: terminó con 3 categorías de bebedor y no 4, y calibró a una encuesta transversal en vez de confiar solo en el panel.

## TL;DR

- **HED en la ENPG:** el texto literal solo lo verifiqué en el cuestionario 2018 (OH_7). Pregunta, en los últimos 30 días, el número de veces con "5 o más tragos" (hombres) o "4 o más tragos" (mujeres) "en una sola ocasión", entendida como un período de unas dos horas, y se hace a quienes bebieron en el último mes. Los informes de SENDA usan la misma definición en la serie de embriaguez 2012–2024 (52,1; 43,7; 51,1; 56,3; 50,2; 50,7 y 47,2 % de quienes bebieron en el último mes).\[1\] El umbral 4+ para mujeres consta en informes desde 2012. Para 2008 y 2010 no encontré cuestionario ni indicador comparable.
- **Inestabilidad de la permanencia anual:** con 29 personas de origen en C4, el error de muestreo por sí solo hace que la permanencia anual implícita pueda ir de ~0,60 a ~0,83, es decir, una duración media en C4 de 2,5 a 6 años. Tomarle la raíz de ~4 años a una matriz amplifica ese ruido. Una permanencia anual baja en las categorías altas no es necesariamente un error: con NESARC, Puka et al. (*Addiction* 2023) estimaron permanencias anuales de 90,1 % en no bebedores y 90,2 % en categoría I, pero de solo 31,8 % en la categoría II (intermedia) y 52,2 % en la categoría III (la más alta).
- **Qué hacer:** (1) encoger cada fila débil hacia la fila vecina con un prior Dirichlet; el único supuesto es que el patrón relativo (quedarse, bajar uno, subir uno) se parece al del vecino. (2) Fusionar C3+C4 o permitir solo transiciones adyacentes en Q. (3) Calibrar los flujos a las prevalencias bienales de la ENPG con IPF/RAS. (4) Juzgar los modelos por su efecto en la prevalencia proyectada de C3–C4 y en las muertes atribuibles, no por diferencias pequeñas de log loss. Si las diferencias quedan dentro del intervalo de confianza de la ENPG, no deberían condicionar la publicación.

---

## A. ENPG: redacción del consumo episódico excesivo (HED, "embriaguez") por ola

**Qué está verificado y qué no.** Solo pude leer completo el cuestionario oficial ENPG 2018 (PDF de SENDA). Los PDF de los informes 2012, 2016 y 2020, que traen el cuestionario como anexo, bloquearon la descarga automática. Para esas olas tengo solo la definición que usan los informes, no el texto literal. No invento redacciones: donde no vi el cuestionario, lo indico.

**Redacción verificada (ENPG 2018, Módulo Alcohol, secuencia autoaplicada):**
- **OH_7:** "Pensando en los últimos 30 días y tomando en cuenta todos los tipos de bebidas alcohólicas: No considere Fiestas Patrias. Si es hombre: ¿Cuántas veces tomó 5 o más tragos en una sola ocasión? (Mostrar tarjeta 5.1). Si es mujer: ¿Cuántas veces tomó 4 o más tragos en una sola ocasión? (Mostrar tarjeta 5.2). Por 'ocasión' nos referimos a un mismo momento, por ejemplo, en un período de dos horas". Respuesta: "N° de veces" (88 No sabe, 99 No contesta).\[2\]
- **Tarjeta 5.1 (hombres):** "5 latas de cerveza o … 1 litro y medio (1.600 ml aprox.)"; "5 copas de vino o … 1 botella (700 ml aprox.)"; "5 combinados suaves o 3 combinados fuertes (200 ml de ron, pisco, vodka u otro licor aprox.)".\[2\]
- **Tarjeta 5.2 (mujeres):** "4 latas … (1.300 ml)"; "4 copas de vino … ¾ de botella (550 ml)"; "4 combinados suaves o un poco menos de 3 fuertes (160 ml de licor)".\[2\]
- **Filtro:** OH_7 se hace a quienes respondieron "Durante los últimos 30 días" en OH_4 (última vez que consumió). Quienes respondieron "hace más de un mes pero menos de un año" saltan a OH_12.\[2\] Por eso el indicador de SENDA se calcula sobre los "prevalentes de último mes".\[3\]
- **Definición de trago (Tarjeta 6):** 1 trago = "una botella o lata individual de cerveza (333 cc.)", "un vaso de vino (140 cc.)", "un trago de licor (40 cc.) … solo o combinado". 1 litro de cerveza = 3 tragos; 1 botella de vino (750 cc) = 6 tragos; 1 caja de vino (1 L) = 8; 1 botella de licor (750 cc) = 18.\[2\] El cuestionario **no da equivalencia en gramos**. Mi cálculo (inferencia, no fuente SENDA) con densidad del etanol de 0,789 g/ml: 333 cc al 4,5–5 % ≈ 12–13 g; 140 cc al 12–13 % ≈ 13–14 g; 40 cc al 35–40 % ≈ 11–13 g. Usar 12 g por trago, como en el algoritmo EPS, es razonable.
- **Inconsistencia interna:** la Tarjeta 5.1 dice que 5 copas son ≈ 1 botella de 700 ml, mientras la Tarjeta 6 dice que 1 botella de 750 cc son 6 tragos.\[2\] Conviene mencionarlo como fuente de error de medición.
- **Otra pregunta de "6 o más":** OH_14 (ítem 3 del AUDIT) pregunta "¿Qué tan seguido toma usted 6 o más tragos en una sola ocasión?" (Nunca / Menos de una vez al mes / Mensualmente / Semanalmente / Todos o casi todos los días).\[2\] No hay que confundirla con OH_7.

| Ola | Documento | ¿Cuestionario verificado? | Pregunta / indicador | Umbral H/M | Período | Formato | Filtro | Valor publicado (entre prevalentes mes) |
|---|---|---|---|---|---|---|---|---|
| 2008 | — | No encontrado | No encontré un indicador de embriaguez 5+/4+ | — | — | — | — | — |
| 2010 | — | No encontrado | No encontrado (según el informe 2018 el indicador se "creó en 2012") | — | — | — | — | — |
| 2012 | Informe "Décimo Estudio Nacional" (con Anexo II "Cuestionario aplicado") | No (solo informe) | "cinco o más tragos en una sola ocasión (cuatro o más para mujeres) durante los últimos 30 días" | 5+/4+ | 30 días | No verificado | Prevalentes mes | 52,1 %\[1\] |
| 2014 | Presentación ENPG 2024 (serie); ficha bibliodrogas SENDA/MINSAL 2015 | No | Misma definición | 5+/4+ | 30 días | No verificado | Prevalentes mes | 43,7 % (la ficha bibliodrogas dice 43,6 %)\[4\] |
| 2016 | Informe ENPG 2016; informe 2018 | No | Misma definición | 5+/4+ | 30 días | No verificado | Prevalentes mes | 51,1 %\[3\] |
| 2018 | Cuestionario ENPG 2018, OH_7 | **Sí** | Texto literal arriba | 5+/4+ | Últimos 30 días, sin Fiestas Patrias | N° de veces (conteo) | OH_4 = últimos 30 días | 56,3 % (H 59,5 %, M 51,4 %)\[3\] |
| 2020 | Informe Décimo Cuarto Estudio 2020 | No (cuestionario en anexo, no accesible) | "cinco o más tragos en una sola ocasión (cuatro o más para mujeres) durante los últimos 30 días" | 5+/4+ | 30 días | No verificado | Prevalentes mes | 50,2 %\[5\] |
| 2022 | Presentación ENPG 2024 (serie) | No | Misma definición | 5+/4+ | 30 días | No verificado | Prevalentes mes | 50,7 % |
| 2024 | Presentación de resultados del 16° Estudio (SENDA, 4 de diciembre de 2025; nota de prensa oficial en senda.gob.cl) | No | "Embriaguez: 5 o más tragos para hombres, 4 o más para mujeres" | 5+/4+ | Último mes | No verificado | Prevalentes mes | 47,2 %\[6\] |

**Conclusiones para el modelo.**
1. El umbral diferenciado por sexo (5+ hombres / 4+ mujeres) aparece en todos los informes desde 2012. No encontré evidencia de una versión anterior con 5+ para ambos sexos en población general. El estudio escolar sí usa 5+ para todos, así que no hay que mezclar las dos series.\[7\]
2. La serie comparable de HED es 2012–2024. Para 2008–2010 hay que extrapolar o declarar el dato como faltante.
3. El HED de la ENPG mide "**al menos una ocasión** en 30 días", mientras la aproximación EPS mide "**cantidad típica** ≥5/≥4". Son constructos distintos: la de la EPS subestimará el HED de la ENPG, sobre todo en bebedores de baja frecuencia.
4. Un detalle de modo: en 2018 el alcohol iba en una "secuencia autoaplicada" (SA_1), en la que el entrevistado elegía contestar por sí mismo o en voz alta.\[2\] La EPS se aplica cara a cara, lo que puede producir diferencias de reporte.

## B. ENPG: inventario de variables útiles

**Diseño (verificado para 2024 en la ficha técnica):** "Muestreo probabilístico y en tres etapas"; "Muestra representativa de nivel nacional y regional"; "18.668 personas entre 12-65 años, que representan a 11.396.772 habitantes de 109 comunas"; entrevista cara a cara; trabajo de campo de Ipsos.\[6\] El hecho de que represente a la población de 109 comunas, y no a todo el país, confirma que la cobertura es **urbana/comunal y no completa**.\[5\] El diseño de 2018 identifica Región, Comuna, Zona, Segmento, Vivienda y Hogar (portada del cuestionario 2018), lo que apunta a conglomerados (zona/segmento) dentro de comunas.\[2\] **No verifiqué** los nombres de las variables de estrato, conglomerado y factor de expansión en las bases. Hay que revisarlos en el libro de códigos de cada ola.

| Variable | Código 2018 | Tipo de pregunta | Nivel de medición | Categorías / rango | Olas | Estado |
|---|---|---|---|---|---|---|
| Alcohol alguna vez | OH_1 | Sí/No | Nominal binaria | 1 Sí, 2 No, 88, 99 | Serie 1994– | Verificado 2018 |
| Primera vez | OH_2 | Cerrada (Tarjeta 2) | Ordinal | Últimos 30 días / >1 mes y <1 año / >1 año | — | Verificado 2018 |
| Edad de inicio | OH_3 | Abierta | Discreta (años) | Años cumplidos | — | Verificado 2018 |
| Última vez (→ prevalencia año/mes) | OH_4 | Cerrada | Ordinal | 30 días / <1 año / >1 año | Serie | Verificado 2018 |
| Días de consumo en 30 días | OH_5 | Abierta | Discreta 1–30 | N° de días | — | Verificado 2018 |
| Bebida más frecuente en 30 días | OH_6 | Cerrada | Nominal | Cerveza; Vino/espumantes; Licores/destilados/combinados; Otro | — | Verificado 2018 |
| HED / embriaguez | OH_7 | Abierta | Discreta (conteo) | N° de veces | 2012– (indicador) | Verificado 2018 |
| Máximo de tragos en una ocasión | OH_8 | Abierta | Discreta | N° de tragos | — | Verificado 2018 |
| Gasto en alcohol en 30 días | OH_9 | Abierta | Continua ($) | Pesos | — | Verificado 2018 |
| Consumo en la última semana | OH_10 | Sí/No | Binaria | — | — | Verificado 2018 |
| Tragos por día, últimos 7 días | OH_11 | Diario de 7 días | Discreta por día | Día 1…Día 7 | — | Verificado 2018 |
| AUDIT 1–10 | OH_12–OH_21 | Escala | Ordinal (0–4) | OH_12 frecuencia (Nunca … 4+/semana); OH_13 tragos en día típico (0–2, 3–4, 5–6, 7–9, 10+); OH_14 6+ tragos | — | Verificado 2018 |
| Lugar de compra | OH_22–23 | Respuesta múltiple | Nominal | Bares, botillerías, supermercados, etc. | — | Verificado 2018 |
| Problemas por alcohol (12 meses) | OH_24–27 | Sí/No | Binaria | — | — | Verificado 2018 |
| Autopercepción de salud | ST_1 | Cerrada | Ordinal (6) | Muy malo … Excelente | — | Verificado 2018 |
| Sexo, edad | — | — | Nominal / discreta | 12–65 años | Todas | Inferido de informes (desagregan por sexo y tramos 12–18, 19–25, 26–34, 35–44, 45–64) |
| Nivel socioeconómico (NSE) | — | — | Ordinal (Bajo/Medio/Alto) | — | Todas | Inferido de informes ("NSE Medio"); **no verifiqué su construcción** |
| Educación, estado civil, actividad, ocupación, ingreso, previsión de salud, pueblo originario, tamaño del hogar | — | — | — | — | — | **No verificado** (el módulo sociodemográfico no se recuperó). Revisar libro de códigos |

**Cómo obtener gramos/día con la ENPG (más defendible primero):**
- OH_11, el diario de 7 días por 12 g, dividido por 7.\[2\] Es lo más parecido a una medición de volumen, pero la semana de referencia no es representativa del individuo: no sirve para clasificarlo, sí para obtener prevalencias agregadas.
- OH_5 (días/30) por el punto medio de OH_13 (tragos típicos). OH_13 está en categorías gruesas y el tramo abierto "10 o más" es crítico para C4.\[2\]

## C. EPS: módulo de alcohol, sociodemográficas y diseño

**No pude verificar el cuestionario EPS en fuente primaria.** La página "Documentos EPS y otras encuestas" de la Subsecretaría de Previsión Social lista "Cuestionario-eps-2015", "Informe-metodologico-factoresexpansión-eps-2015", "Manual-de-usuarios-eps-2015", "Cuestionarios EPS VII Ronda" y "Cuestionario EPS VIII Ronda".\[8\] No pude abrir esos PDF, así que la redacción de F13–F15 que sigue es la del contexto del proyecto, **no** está citada del cuestionario.

| Elemento | Información | Estado |
|---|---|---|
| F13 | Consumo de bebidas (por tipo), sin período de referencia explícito | Según el usuario; no verificado |
| F14 | Frecuencia en el último mes, por bebida | Según el usuario; no verificado |
| F15 | Cantidad típica por bebida | Según el usuario; no verificado |
| Módulo | "Módulo F – Salud" (la base de salud es aparte en la EPS 2009: "Base Salud: … todo el módulo F") | Verificado (EPS 2009 instrucciones; nota ciudadana 16)\[9\]\[10\] |
| Rondas | 2002, 2004, 2006, 2009, 2012, 2015 y 2019. La VII ronda tuvo campo de Ipsos de diciembre 2019 a diciembre 2020.\[11\] Existe cuestionario de una VIII ronda | Verificado (sitio SPS)\[8\] |
| Tamaño | "alrededor de 16.000 encuestados distribuidos en todas las regiones del país" (sitio SPS) frente a "tamaño de muestra panel … aproximadamente 24.000 personas" (nota ciudadana 16) | **Conflicto entre fuentes oficiales**; probablemente se refieren a rondas o definiciones distintas\[10\]\[11\] |
| Cobertura | Todas las regiones; incluye población rural (inferido del marco de afiliados/no afiliados) | Parcialmente inferido |
| Factores de expansión | Existe un informe metodológico de factores de expansión 2015 | Existencia verificada; contenido no |

## D. Variables comunes ENPG–EPS y recodificación armonizable

| Variable | ENPG | EPS | Recodificación propuesta | Advertencias | ¿Predictor de transición (EPS) y disponible en población sintética (ENPG + INE)? |
|---|---|---|---|---|---|
| Sexo | Sí | Sí | Binaria | — | **Sí** |
| Edad | 12–65 | Panel adulto | Tramos 18–25, 26–34, 35–44, 45–54, 55–65 | La ENPG llega a 65 (los informes usan 45–64); la EPS se usa para 18–65 en el origen | **Sí** |
| Región | Sí | Sí | 16 regiones o macrozonas | La ENPG cubre comunas urbanas | **Sí** (mejor en macrozona) |
| Urbano/rural | Implícito (solo urbano) | Sí | Restringir la EPS a urbano para la estimación o el análisis de sensibilidad | **Sesgo de cobertura** | Solo como restricción, no como predictor |
| Educación / NSE | NSE (ordinal), educación no verificada | Educación detallada | 3 niveles (básica o menos / media / superior) | Construcción del NSE de la ENPG no verificada | **Sí, si la ENPG trae educación**; si no, imputar desde CASEN |
| Estado de alcohol N0/FD | OH_1 + OH_4 | Historia (vida/ex) | N0 = nunca; FD = bebió alguna vez pero no en el último año (ENPG) | En la ENPG "exbebedor" es "no en 12 meses"; en la EPS depende de F13 | **Sí** (estado de origen) |
| Gramos/día C1–C4 | OH_11 (7 días) u OH_5 × OH_13 | F14 × F15 × 12/7 | Mismos cortes por sexo | Período distinto (semana/mes frente a mes); OH_13 está en categorías | **Sí** (estado) |
| Bebida preferida | OH_6 (más frecuente) | F13–F15 por bebida | Cerveza / vino / destilados | La EPS permite obtener la proporción por bebida | Útil para las políticas de precio (como SIMAH) |
| HED | OH_7 (ocasión ≥5/≥4 en 30 días) | Aproximación con cantidad típica | Para comparar: en la ENPG usar OH_13 ≥ "5 a 6" en hombres. En mujeres el corte en 4 no se puede separar (tramo "3 a 4") | **No equivalentes** | No como estado; sí como objetivo de calibración agregado |
| Estado civil, actividad, ingreso, previsión, pueblo originario | No verificado | Sí | — | Verificar en el libro de códigos ENPG | Solo si existen en ambas fuentes y en las proyecciones INE/CASEN |

**Recomendación:** sexo, edad, educación (3 niveles) y estado de alcohol de origen son el conjunto mínimo, y con él el modelo es defendible. Es exactamente el de SIMAH, que usa sexo, edad, raza/etnia y educación más el consumo previo.\[12\]\[13\]

## E. "Compartir información entre categorías": qué significa y cómo hacerlo sin perder la matriz A

**La idea en simple.** La fila C4 de la matriz A sale de 29 personas. Las filas C2 y C3 tienen cientos. Si C4 se comporta "parecido" a C3 en términos **relativos** (cuántos se quedan, cuántos bajan un escalón, cuántos dejan de beber), podemos tomar prestada información de C3 para estabilizar C4. Lo que hay que decidir es qué significa "parecido", y esa decisión es el supuesto de cada opción.

**Ejemplo numérico (ilustrativo, cifras inventadas para mostrar el cálculo).** Supongamos que en la EPS, de los 29 en C4, 9 se quedan en C4 (31 %), 10 bajan a C3, 6 a C2 y 4 pasan a FD. En C3 (n=200), en movimiento relativo: se quedan 45 %, bajan un escalón 30 %, bajan dos 12 %, suben uno 5 %, FD 8 %. Con un prior Dirichlet centrado en el patrón de C3 y "peso" k=30 pseudo-personas:
- Permanencia en C4 = (9 + 30×0,45) / (29 + 30) = 22,5/59 = **0,38**, frente a 0,31 empírico.
- La fila sigue siendo una tabla empírica; el único parámetro nuevo es k, que puede elegirse por validación cruzada o por máxima verosimilitud marginal Dirichlet-multinomial. Es la misma lógica de encogimiento que ya usan, pero hacia la **fila vecina alineada por movimiento relativo** y no hacia una celda agregada de sexo y edad.
- El intervalo de confianza de la permanencia en C4 con n=29 es aproximadamente 0,31 ± 0,17. Con el prior se estrecha mucho.

| Opción | Cómo comparte información | Supuesto mínimo | Decisiones añadidas | Compatible con "A" |
|---|---|---|---|---|
| Encogimiento Dirichlet hacia la fila adyacente (movimiento relativo) | Pseudo-conteos desde C3 hacia C4 | El patrón relativo de C4 ≈ el de C3 | 1 (k) | **Sí, la más simple** |
| Suavizado entre filas adyacentes (kernel sobre el origen) | Promedio ponderado de filas vecinas | La matriz cambia suavemente con el origen | 1 (ancho de banda) | Sí |
| Dirichlet-multinomial jerárquico bayesiano con estructura ordinal | El prior de cada fila depende de la fila vecina (camino aleatorio) | Suavidad entre filas | 1–2 hiperparámetros | Sí (posterior = matriz A suavizada con incertidumbre) |
| Proportional odds (logit acumulativo) | El origen desplaza toda la distribución de destino | Un solo efecto del origen para todos los cortes (odds proporcionales) | Varias (linealidad, PO) | No (paramétrico) |
| Partial proportional odds | Relaja PO en algunos cortes | PO solo donde no se viola | Más | No |
| Continuation-ratio | Modela "¿pasa del escalón j dado que llegó a j?" | Proceso secuencial | Varias | No |
| Adjacent-category | Log-odds entre categorías contiguas | Efectos constantes entre pares | Varias | No |
| Multiestado con transiciones adyacentes (msm) | Q con ceros fuera de i→i±1 (+FD) | No hay saltos instantáneos de más de un nivel | Estructura de Q | Sí, como generador de A |
| Fusionar C3+C4 | Elimina la fila débil | Riesgo homogéneo dentro de la categoría fusionada (luego se reasigna g/día dentro de ella) | 1 | Sí |

Tu preocupación por el paso adicional de decisiones (linealidad, aditividad, ordinalidad) es legítima. Las tres primeras filas de la tabla **no** requieren linealidad ni aditividad: solo una regla de vecindad y un peso. Por eso las prefiero a los modelos ordinales.

## F. "Datos externos": cómo combinar el panel EPS con la ENPG transversal

**Qué se busca.** El panel EPS informa *quién se mueve*. La ENPG, bienal desde 2008 y con n≈18.000 en 2024, informa *cuántos hay en cada estado cada año*. Si A, aplicada a la población de 2016, no reproduce la ENPG 2018, 2020 y 2022 por sexo y edad, se corrige A con el mínimo cambio posible.

**Opciones, de menos a más decisiones:**
1. **Raking/IPF (RAS) de la tabla de flujos.** Semilla: n_t(origen) × A. Se reescala alternadamente filas (deben sumar la prevalencia de origen en t) y columnas (deben sumar la prevalencia ENPG en t+1, interpolada entre olas) hasta converger. Preserva las razones de odds internas de A, es decir, "quién se mueve", y es el ajuste de mínima divergencia de Kullback-Leibler respecto de A. SIMAH usó IPF para construir la población sintética.\[12\]
   - *Ejemplo:* si A proyecta 3,0 % en C4 para hombres de 26–34 y la ENPG (traducida a gramos) muestra 2,2 %, el raking reduce proporcionalmente las entradas a C4 y redistribuye esa masa según las proporciones relativas de A.
   - *Supuesto mínimo:* A acierta en la estructura de asociación, y el error está en los márgenes.
2. **Mínimos cuadrados o máxima verosimilitud agregada** (Lee, Judge y Zellner; Kalbfleisch, Lawless y Vollmer 1983 en *Biometrics*, "Estimation in Markov models from aggregate data"). Estima P solo con prevalencias sucesivas.\[14\]\[15\] Por sí sola está mal identificada, pero usada con A como prior funciona bien.
3. **Pseudo-paneles (Moffitt 1990/1993; Pelzer, Eisinga y Franses).** Modelos de Markov para cohortes sintéticas a partir de cortes repetidos. Son útiles para transiciones binarias, como beber o no beber en el año.\[16\]\[17\]
4. **Calibración bayesiana / ABC / history matching.** Es lo que hizo SIMAH. Los coeficientes estimados son el prior; la posterior se obtiene comparando prevalencias simuladas con BRFSS 2011–15 y se retienen parámetros con implausibilidad media <3. La validación se hace con BRFSS 2016–19, reservado.\[13\]
5. **Calibración clásica a datos transversales.** Ejemplo: Goldhaber-Fiebert y Brandeau ("Modeling and Calibration for Exposure to Time-Varying, Modifiable Risk Factors: The Example of Smoking Behavior in India", *Med Decis Making* 2015) calibraron tasas de inicio, cese y recaída del tabaquismo con encuestas transversales. Van de Kassteele, Hoogenveen, Engelfriet, van Baal y Boshuizen (*Stat Med* 2012;31(6):533–543, RIVM) estimaron probabilidades netas de transición de factores de riesgo para modelos de enfermedad crónica desde datos transversales, con P-splines multinomiales sobre prevalencias por edad aplicados al IMC y bajo el supuesto de que las transiciones se mantienen estables en el tiempo.

**Advertencia clave para la ENPG:** la prevalencia de consumo del mes cayó de 43,3 % (2018) y 44,3 % (2020)\[18\] a 39,2 % (2022)\[19\] y 34,6 % (2024), "el nivel más bajo de toda la serie".\[6\] Una matriz estacionaria estimada con la EPS 2015–2023 no reproducirá esa tendencia sin calibración dependiente del período.

## G. Cómo lo resolvió SIMAH (Kilian et al. 2025 y publicaciones relacionadas)

| Aspecto | Protocolo SIMAH (Probst et al., *Am J Epidemiol* 2023) | Kilian et al., *Lancet Public Health* 2025 (modelo final) |
|---|---|---|
| Fuente de transiciones | NESARC I–II, con msm en tiempo continuo ("Annual transition probabilities will be estimated using continuous-time, multistate Markov models")\[12\] | "ordinal logistic regression modelling of pseudo-longitudinal BRFSS data (2000–10)"\[13\] |
| Categorías | 5: abstemios + I a IV (IV: >61 g mujeres / >100 g hombres)\[12\] | 4: abstemios (12 meses) + 1 a 3 (3: >40 g mujeres / >60 g hombres)\[13\] |
| Covariables | Educación, raza/etnia, edad, sexo | Las mismas más el consumo previo\[13\] |
| Calibración | ABC con métrica de implausibilidad (plan)\[12\] | Bayesian history matching contra BRFSS 2011–15; validación con BRFSS 2016–19\[13\] |
| Incertidumbre | — | 60 combinaciones de parámetros × 10 semillas = 600 corridas; intervalos de credibilidad min–máx\[13\] |
| Paso | Anual | Anual, 2000–2019\[13\] |
| Educación | Markov multiestado con PSID\[12\] | Markov con PSID 2005–2019, calibrado con ACS\[13\] |

**Estudio NESARC de transiciones (Puka, Buckley, Mulia, Purshouse et al., *Addiction* 2023):** msm homogéneo en tiempo continuo con NESARC I (2001–02) y II (2004–05), n = 34.165.\[20\]\[21\] La cantidad se modeló mejor con **4 estados** (no bebedor, I, II, III).\[22\] La permanencia anual fue de 90,1 % (IC 89,7–90,5) en no bebedores y de 90,2 % (IC 89,9–90,5) en categoría I, frente a 31,8 % (IC 29,7–33,9) en la categoría II (intermedia: 21–40 g mujeres, 41–60 g hombres) y 52,2 % (IC 46,0–58,5) en la categoría III (la más alta: ≥41 g mujeres, ≥61 g hombres). En la validación externa, un modelo que solo permitía transiciones instantáneas entre estados adyacentes, aplicado repetidamente a NESARC I, predijo proporciones a 11 años que "differing by 1% or less" de las observadas en NESARC III (2,2 % o menos en el modelo de patrón HED). Es un precedente directo de la Q adyacente.

**Lecciones para tu proyecto:**
- SIMAH enfrentó tu mismo problema, con un panel de ~3 años e intervalos multianuales, y terminó con tres decisiones: (a) colapsar las categorías altas (de I–IV a 1–3), (b) estimar las transiciones con una fuente de más tamaño y calibrar a una serie transversal, y (c) propagar la incertidumbre por calibración.
- Las permanencias anuales de 31,8 % (categoría II) y 52,2 % (categoría III) en NESARC indican que una permanencia baja en C4 en la EPS puede ser real (o reflejar regresión a la media), no un defecto del método.
- **Repositorio:** el artículo dice que los datos y el código "will be made publicly available via GitHub".\[13\] El repositorio del propio proyecto FONDECYT (ACC1240138/micsim) cita el paquete SIMAH por DOI 10.5281/zenodo.15641639.\[23\] No pude verificar la versión ni la URL de GitHub del código SIMAH.

## H. El problema de la permanencia anual, explicado, y cómo mejorarla

**Por qué ocurre.** Observas P(Δ) con Δ ≈ 3,7–4 años y buscas P(1) tal que P(1)^Δ ≈ P(Δ), es decir, Q con exp(QΔ) = P(Δ). Hay tres problemas.
1. **Amplificación del ruido.** Con una sola transición observada por persona, la permanencia anual se aproxima como p_anual ≈ p_Δ^(1/Δ). Si en C4 p_Δ = 0,31 con IC95 % 0,14–0,48 (n=29), entonces p_anual ≈ 0,74, con un rango de **0,60 a 0,83**. Las duraciones medias en C4 (1/(1−p)) van de **2,5 a 5,9 años**. Como la prevalencia de equilibrio de C4 es aproximadamente entrada/(entrada+salida), un factor de ~2,4 en la tasa de salida mueve la prevalencia simulada de C4 en un orden de magnitud parecido. Es un cálculo ilustrativo que ignora los retornos.
2. **Problema de embedding.** Una matriz empírica de 4 años puede no tener un generador válido: el logaritmo matricial da tasas negativas fuera de la diagonal. Israel, Rosenthal y Wei (2001, *Mathematical Finance* 11:245–265) dan condiciones de existencia y unicidad y proponen corregir el logaritmo.\[24\]\[25\] Kreinin y Sidelnikova (2001) proponen algoritmos de regularización que minimizan ‖P − exp(Q)‖.\[26\]\[27\] Hughes y Werner (2016, *Risks*) resuelven la optimización no lineal directa e incorporan restricciones. En el caso de calificaciones crediticias, la ordinalidad se ha impuesto como monotonicidad estocástica.\[24\]\[28\] Higham y Lin no los verifiqué en esta búsqueda.
3. **Error de medición y no-Markovianidad.** F14 mide un solo mes. Parte de los "movimientos" C4→C2 son ruido de medición que el modelo de Markov interpreta como movilidad real. Esto acorta artificialmente la permanencia y, al proyectar, empuja la población hacia el centro.

**Opciones, ordenadas por costo en decisiones:**

| Opción | Qué hace | Supuesto mínimo | Efecto esperado en C4 |
|---|---|---|---|
| Fusionar C3+C4 (como SIMAH) | Elimina la fila de 29; los g/día dentro de C3+ se asignan por distribución empírica | Riesgo dentro de la categoría capturado por g/día individuales | Estabilidad alta |
| msm con Q solo adyacente (i↔i±1, Ci→FD, N0→C1, FD→C1) | Menos tasas libres; los saltos largos se explican como pasos sucesivos | Sin saltos instantáneos de más de un nivel | Reduce varianza; la permanencia queda determinada por menos tasas |
| msm con intervalos individuales (Jackson 2011, *J Stat Softw* 38(8); Kalbfleisch y Lawless 1985) | Usa el tiempo exacto entre entrevistas de cada persona\[29\] | Homogeneidad temporal (o por período) | Aprovecha la variación de Δ |
| Encogimiento Dirichlet hacia la fila vecina (sección E) antes de anualizar | Estabiliza P(Δ) | Similitud del patrón relativo | Reduce varianza |
| Regularización del generador (Kreinin y Sidelnikova; Israel et al.) | Q válido más cercano | Ninguno sustantivo | Evita tasas negativas |
| Raking a la ENPG (sección F) | Corrige márgenes | A acierta en la estructura | Ajusta la prevalencia de C4 al objetivo |
| Propagar incertidumbre (bootstrap de personas o posterior Dirichlet) | Reporta un rango en lugar de un punto | — | Hace visible y honesto el problema |
| Modelo de error de medición (Markov oculto, msm con `ematrix`) | Separa ruido de transición real | Estructura de clasificación errónea | Aumenta la permanencia "verdadera"; requiere más decisiones |

**Mi recomendación:** fusionar C3+C4 o usar Q adyacente, más encogimiento hacia la fila vecina, más raking a la ENPG, y reportar las bandas de incertidumbre.

## I. Relevancia práctica y editorial: cómo juzgar si las diferencias importan

Lo que esperan los revisores, según ISPOR-SMDM Task Force-7 (Eddy et al. 2012, *Value Health* 15:843–850 / *Med Decis Making* 32:733–743):\[30\]\[31\]
- Documentación no técnica y técnica suficiente para reproducir el modelo.\[30\]
- Validez aparente (expertos), verificación o validez interna (código), validez cruzada (otros modelos), validez externa (comparar con datos reales) y validez predictiva (eventos prospectivos).\[32\]
- SIMAH agrega dos prácticas: el protocolo ODD (overview, design concepts, details) y la separación entre datos de calibración y de validación.\[13\]\[33\]

**Criterios aplicables (lista corta):**
1. **Calibración por categoría y subgrupo:** la prevalencia simulada de N0, FD y C1–C4 por sexo y edad debe quedar dentro del IC95 % de la ENPG en las olas de calibración y en una ola reservada (por ejemplo, 2024).
2. **Traducir métricas a resultados:** una diferencia de log loss de, digamos, 0,005 nats por transición puede ser estadísticamente significativa con miles de transiciones y aun así cambiar la prevalencia proyectada de C3+ en décimas de punto. Lo que conviene reportar es Δ prevalencia de C3–C4 a 10 años y Δ muertes atribuibles.
3. **Margen de equivalencia práctica, definido antes de comparar:** por ejemplo, considerar equivalentes los modelos si la prevalencia de C3+ difiere menos que el IC95 % de la ENPG para ese subgrupo y las muertes atribuibles proyectadas difieren menos de ~5 %. Si se cumple, se elige el modelo más simple y transparente (la A suavizada).
4. **Pesar más el error en las categorías altas:** el riesgo crece de forma más que lineal con la dosis (Kilian et al. 2025 lo describen como "generally exponential").\[13\] Un error de 0,5 puntos en C4 importa más que uno de 2 puntos en C1.
5. **Incertidumbre propagada:** si la incertidumbre de la fila C4 domina el intervalo de las muertes atribuibles, hay que decirlo. Un revisor lo aceptará mucho mejor que una matriz estable pero no justificada.

**Juicio editorial:** que el modelo multinomial u ordinal sea marginalmente mejor que A en log loss no condiciona la publicación. Sí la condicionarían tres cosas: (a) no reproducir las prevalencias por categoría de la ENPG, (b) no reportar la incertidumbre de las categorías altas o (c) no validar con datos reservados.

## Caveats

- La redacción literal del HED solo está verificada para 2018. Las demás olas salen de informes y presentaciones; la de 2024, de la presentación de resultados de SENDA del 4 de diciembre de 2025, cuya nota de prensa oficial informa que "el 47,2% de quienes consumieron alcohol reportó un episodio de embriaguez en el último mes".
- No verifiqué el cuestionario EPS (F13–F15) ni el módulo sociodemográfico de la ENPG. Las filas correspondientes de las tablas B–D deben contrastarse con los libros de códigos.
- El ejemplo numérico de C4 es ilustrativo; los conteos reales de tu matriz cambiarán las cifras, pero no la lógica.
- Las cifras sobre el tamaño de muestra de la EPS (16.000 frente a 24.000) están en conflicto entre documentos oficiales.

## Fuentes

1. [Senda](https://www.senda.gob.cl/wp-content/uploads/2011/04/2012_Decimo_EstudioNacional.pdf)
2. <https://www.senda.gob.cl/wp-content/uploads/2019/12/Cuestionario-ENPG-2018.pdf>
3. [Décimo Tercer Estudio Nacional de Drogas en Población General de Chile, 2018](https://www.senda.gob.cl/wp-content/uploads/2020/02/ENPEG-2018.pdf)
4. [Catálogo en línea Koha › Detalles de: El consumo de alcohol en Chile: Situación epidemiológica.](https://app.bibliodrogas.gob.cl/cgi-bin/koha/opac-detail.pl?biblionumber=6095)
5. [Décimo Cuarto Estudio Nacional de Drogas en Población General de Chile, 2020](https://www.senda.gob.cl/wp-content/uploads/2022/01/Estudio-PG2020.pdf)
6. [par 16° Estudio de Drogas en Población General Observatorio Chileno de Drogas](https://psiconecta.org/wp-content/uploads/2025/12/ENPG-2024-Prensa.pdf)
7. [A. RBD del Colegio: 1. Sexo ①Hombre ②Mujer 2. Edad en años cumplidos:](https://www.senda.gob.cl/wp-content/uploads/2021/01/Cuestionario-2019-VF.pdf)
8. [Documentos EPS y otras encuestas](https://previsionsocial.gob.cl/datos-estadisticos/documentos-eps-y-otras-encuestas/)
9. [ENCUESTA DE PROTECCIÓN SOCIAL 2009 Instrucciones al usuario de la encuesta](https://www.previsionsocial.gob.cl/sps/download/estudios-previsionales/encuesta-de-proteccion-social/bases-de-datos-eps/Instrucciones-EPS-2009.pdf)
10. [protección social y la encuesta de protección social (eps)](https://previsionsocial.gob.cl/wp-content/uploads/2025/12/Nota-ciudadana-16-Proteccion-Social.pdf)
11. [Encuesta de Protección Social - Subsecretaría de Previsión Social](https://www.previsionsocial.gob.cl/sps/biblioteca/encuesta-de-proteccion-social/)
12. <https://eprints.whiterose.ac.uk/id/eprint/198292/1/SIMAH_protocol_technical%20review.pdf>
13. [Targeting alcohol use in high-risk population groups](https://eprints.whiterose.ac.uk/id/eprint/231116/1/1-s2.0-S2468266725001653-main.pdf)
14. [Cross-sectional Markov model for trend analysis of observed discrete distributions of population characteristics](https://arxiv.org/pdf/1510.06787)
15. [Least‐squares estimation of transition probabilities from aggregate data](https://www.researchgate.net/publication/229886176_Least-squares_estimation_of_transition_probabilities_from_aggregate_data)
16. [Estimating transition probabilities from a time series of ...](https://repub.eur.nl/pub/2159/eur_franses_AE73.pdf)
17. [Recovering Transitions From Repeated Cross-Sectional Samples - the University of Groningen research portal](https://research.rug.nl/en/publications/recovering-transitions-from-repeated-cross-sectional-samples/)
18. [Alcohol - Recursos Hablemos de Todo](https://recursoshdt.injuv.gob.cl/wp-content/uploads/2023/04/1_5_5_-_consumo_de_drogas_-_cifras_de_interes.pdf)
19. [Directora de SENDA Atacama presenta resultados del 15° Estudio de Drogas en Población General - SENDA, Gobierno de Chile](https://www.senda.gob.cl/noticia/directora-de-senda-atacama-presenta-resultados-del-15-estudio-de-drogas-en-poblacion-general/)
20. [Behavioral stability of alcohol consumption and socio‐demographic correlates of change among a nationally representative cohort of US adults - Puka - 2023 - Addiction - Wiley Online Library](https://onlinelibrary.wiley.com/doi/10.1111/add.16024)
21. [Behavioral stability of alcohol consumption and socio‐demographic correlates of change among a nationally representative cohort of US adults - White Rose Research Online](https://eprints.whiterose.ac.uk/190647/)
22. [Behavioral stability of alcohol consumption and socio‐ ...](https://eprints.whiterose.ac.uk/id/eprint/190647/1/Addiction%20-%202022%20-%20Puka%20-%20Behavioral%20stability%20of%20alcohol%20consumption%20and%20socio%E2%80%90demographic%20correlates%20of%20change%20among%20a.pdf)
23. [GitHub - ACC1240138/micsim: Alcohol policy microsimulation for Chile (FONDECYT 1240138): alcohol-attributable mortality (PAF/AAF), policy counterfactuals (PIF, YPLL), price elasticities (EPF) and drinking-transition microsimulation using ENPG, EPS and DEIS data. Microdata ship only as encrypted bundles (ACC\_DATA\_KEY). · GitHub](https://github.com/ACC1240138/micsim)
24. [Full article: An extended likelihood framework for modelling discretely observed credit rating transitions](https://www.tandfonline.com/eprint/XRquxdm4n3AUBYiHrtAV/full)
25. [Finding Generators for Markov Chains via Empirical Transition Matrices, with Applications to Credit Ratings - Israel - 2001 - Mathematical Finance - Wiley Online Library](https://onlinelibrary.wiley.com/doi/abs/10.1111/1467-9965.00114)
26. [The Markov chain embedding problem in a low jump frequency context](https://arxiv.org/html/2305.19887v1)
27. [The Markov chain embedding problem in a one-jump setting](https://www.cambridge.org/core/journals/journal-of-applied-probability/article/markov-chain-embedding-problem-in-a-onejump-setting/E7BB3D1ED3AE54F799B3265335A3F525)
28. [Choosing Markovian Credit Migration Matrices by Nonlinear Optimization](https://doi.org/10.3390/risks4030031)
29. [Statistical inference for Markov chains with applications to credit risk](https://link.springer.com/article/10.1007/s00180-020-00978-0)
30. [ISPOR - Model Transparency and Validation: Report 7](https://www.ispor.org/heor-resources/good-practices/article/model-transparency-and-validation)
31. [Transparency and Reproducible Research in Modeling - Crystal M. Smith-Spangler, 2012](https://doi.org/10.1177/0272989x12458977)
32. [Model Transparency and Validation: A Report of the ISPOR-SMDM Modeling Good Research Practices Task Force-7](https://repository.chds.hsph.harvard.edu/repository/2411/)
33. [Targeting alcohol use in high-risk population groups](<https://www.thelancet.com/pdfs/journals/lanpub/PIIS2468-2667(25)00165-3.pdf>)
