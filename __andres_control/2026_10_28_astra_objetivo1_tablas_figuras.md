# Objetivo 1: referentes y menú independiente de tablas y figuras

Fecha: 2026-10-28. Documento de investigación de Astra para Andrés González, Chile.

## Decisiones del usuario posteriores a la entrega

Respuestas exactas: **«1. C y A / 2. A primero, B segundo, si es posible C / 3. Suplementaria»**.

Interpretación conforme a las opciones presentadas:

1. **C y A:** historias defendibles para alimentar el motor, junto con describir el cambio del consumo en Chile.
2. **A primero, B segundo, si es posible C:** primero matrices de transición; segundo heterogeneidad entre grupos; cantidad/frecuencia/HED si es posible.
3. **Soporte etario en material suplementario.** Esto decide la ubicación de su documentación, no el rango etario definitivo.

El usuario solicitó conservar toda esta documentación en un Markdown cuyo nombre comience por `2026_10_28_*`, dentro de `_andres_control`. La carpeta existente del proyecto se denomina `__andres_control` (dos guiones bajos).

### Selección provisional derivada de esas preferencias — propuesta, NO decisión del usuario

- Un bloque central de **matrices observadas y estimadas**, distinguiendo intervalos reales y horizontes modelados: T5/F2, con las comparaciones pertinentes de T8/F5.
- Un segundo bloque de **heterogeneidad**: T6/F3, limitado por tamaños efectivos y precisión.
- Un bloque explícito de **evaluación de las historias que alimentarán el motor**: T10–T11/F5–F7. La comprobación de distribuciones ENPG no reemplaza la evaluación longitudinal. F8 sería ilustrativo, no necesario por defecto.
- **Soporte etario al suplemento:** T14 y/o F12, sin fijar todavía edades elegibles.
- **Cantidad, frecuencia y HED de forma condicional:** T7/F4 y/o F11 cuando medición, soporte y espacio permitan una interpretación válida. No equiparar HED entre instrumentos ni imponerlo a ELSOC.
- Mantener trazabilidad de medición, estados, atrición y pesos (T1–T4/T9/T12) en métodos o suplemento según extensión; no esconder decisiones críticas por una preferencia de formato.

Esta propuesta no ejecuta modelos, no produce resultados nuevos y no constituye una selección editorial final.

## Resumen de la investigación

La búsqueda sugiere tres familias complementarias: estudios poblacionales para presentar el cambio; estudios de simulación para documentar cómo se generan historias; y estudios metodológicos para comparar modelos y comprobar su ajuste. No encontré una razón para adoptar íntegramente la estructura de un solo paper.

Leí el [outline actual](https://docs.google.com/document/d/1b956oF98shatdGzVO_0ZupY5-kzB1OHpnuIPAXlRDEA/edit), sin modificarlo. **Keyes2020 quedó excluido. No investigué el artículo 2.**

## Alcance y transparencia

Búsqueda exploratoria de literatura inglesa mediante búsquedas temáticas, referencias retrospectivas y búsquedas posteriores a las semillas. Incluí fuentes primarias editoriales, PMC y repositorios de autores/universidades. **No es una revisión sistemática ni una búsqueda exhaustiva de citas.**

Las semillas fueron puntos de partida opcionales, no un corpus cerrado ni recomendaciones editoriales heredadas. La ampliación incluyó Leggat, Knott, van den Ende, Delucchi–Weisner y Olsen–Schafer.

Los números de figuras/tablas siguientes se verificaron en texto completo, captions o tablas indexadas; no equivalen a una inspección visual exhaustiva de cada imagen. Los suplementos no descargados están señalados. No se contactó a autores ni se modificaron documentos durante la investigación. Este archivo se crea después, por solicitud expresa del usuario, sin nueva investigación.

### Límites del encargo y criterios de adaptación

- Objetivo 1: persistencia y transiciones de consumo para historias individuales simuladas, no resultados de mortalidad, YLL, costos ni análisis del artículo 2.
- EPS longitudinal VI 2015, VII 2019/20 y VIII 2023/24; TSM panel rondas 7–11. ENPG transversal 2012–24 como referencia poblacional; ELSOC para triangulación sin equiparar mediciones.
- Modelos candidatos: matrices empíricas regularizadas, dos partes lognormal/Gamma y ordinal. La comparación debe usar estimandos y datos evaluables comunes.
- Estados N0, FD, C1, C2 y C3+: **N0 significa no consumo con historia desconocida; no abstinencia de vida**. La clasificación FD necesita historia suficiente y reglas explícitas.
- HED cambia de definición entre instrumentos. Cantidad, frecuencia, gramos/día y HED no son intercambiables.
- No se fija rango etario definitivo. Los 15–17 años carecen de soporte directo en los paneles indicados; EPS puede contener mayores de 65 aunque el filtro actual de código sea 18–65. Cobertura de encuesta y filtro analítico son distintos.
- Examinar pesos de diseño, ponderadores longitudinales e IPW, evitando doble ajuste; reportar atrición, intervalos desiguales y precisión de celdas raras.
- Reservar evaluación independiente antes de ajustar/calibrar; ajustar marginales no demuestra validez de las transiciones ni de toda la historia individual.
- El mismo estado en dos entrevistas no identifica permanencia ininterrumpida. Separar horizonte observado y modelado; no tratar una matriz multianual como anual.

## 1. Doce referentes: qué tomar y qué no

### A. Estudios poblacionales

### 1. Puka et al., 2023 — NESARC, Estados Unidos

34.165 adultos, dos olas separadas aproximadamente tres años; modelo multiestado de tiempo continuo para cantidad y HED.

- **Verificado:** Tabla 1, participantes; Tabla 2, matrices anuales con IC; Tablas 3–4, asociaciones con intensidades de transición; Figura 1, transiciones instantáneas permitidas; Figura 2, probabilidades según estado inicial y tiempo.
- **Suplemento identificado:** S6–S7, comparación externa; Figuras S1–S8, desagregaciones. Verifiqué el índice y referencias del cuerpo, no todos los archivos.
- **Útil:** separar cantidad de patrón y presentar incertidumbre.
- **No trasladar:** categorías/HED, coeficientes estadounidenses, restricciones entre estados o procedimiento de ponderación sin evaluación propia. Su comparación con otra encuesta verifica distribuciones, no todas las historias individuales.
- **Acceso:** texto completo.

[Texto completo](https://onlinelibrary.wiley.com/doi/full/10.1111/add.16024)

### 2. Leggat et al., 2022 — HILDA, Australia

18 olas, 2001–2018; 20.593 participantes de 15 años o más; modelos multinivel por sexo.

- **Verificado:** Tablas 1–2, muestras de cantidad/frecuencia y de consumo episódico; Figuras 1–4, respectivamente volumen diario, cantidad habitual por ocasión, frecuencia y frecuencia de episodios de riesgo, según edad.
- **Útil:** mostrar que volumen, frecuencia y episodios intensos pueden evolucionar de manera distinta.
- **No trasladar:** curvas medias como matrices individuales; umbrales australianos de RSOD como equivalentes de TSM/ENPG. Su cobertura adolescente no resuelve la ausencia de soporte longitudinal chileno.
- **Acceso:** texto completo; descarga del suplemento falló.

[Artículo y figuras](https://onlinelibrary.wiley.com/doi/full/10.1111/add.15849)

### 3. Knott, Bell y Britton, 2018 — Whitehall II

10.210 funcionarios británicos; siete mediciones durante aproximadamente 28 años; modelos de crecimiento.

- **Verificado:** Tabla 1, volumen y cambio por década según categoría basal y sexo; Figuras 1–2, curvas lineales y no lineales; Figura 3, transición a no consumo según edad y categoría basal.
- **Útil:** separar reducción de cantidad y abandono; mostrar historia previa dentro de categorías actuales.
- **No trasladar:** población ocupacional como representativa nacional; categoría basal como estado actualizado. Los autores consideran regresión a la media.
- **Acceso:** texto completo; apéndices identificados, no inspeccionados integralmente.

[Artículo](https://onlinelibrary.wiley.com/doi/full/10.1111/add.13949)

### 4. Britton et al., 2015 — nueve cohortes británicas

59.397 personas y 174.666 observaciones; edades superpuestas desde adolescencia hasta vejez; armonización y modelos multinivel.

- **Verificado:** Tabla 1, inventario de cohortes; Tabla 2, coeficientes; Figuras 1–2, volumen por edad en hombres y mujeres; Figura 3, curvas combinadas; Figuras 4–5, frecuencias por edad.
- **Útil:** organizar cobertura de fuentes y visualizar dominios superpuestos sin ocultar diferencias.
- **No trasladar:** ensamblaje de curvas como seguimiento de una persona durante toda su vida; promedios como persistencia individual.
- **Acceso:** texto completo; archivos adicionales localizados.

[Artículo](https://link.springer.com/article/10.1186/s12916-015-0273-z)

### 5. Van den Ende et al., 2024 — Framingham

Datos longitudinales y redes sociales de las cohortes original y descendiente, 1971–2001; estados no consumo/moderado/alto.

- **Verificado:** Tabla 1, muestras por examen; Tabla 2, proporciones de transición; Figura 1, sensibilidad de estabilidad al umbral moderado–alto.
- **Útil:** inspiración concreta para mostrar cuánto depende la clasificación de sus cortes.
- **No trasladar:** mecanismo de contagio social sin redes chilenas; inferencias causales de influencia; supuestos de anualización y estabilidad entre entrevistas. No es muestra nacional.
- **Acceso:** texto completo.

[Artículo](https://www.nature.com/articles/s41598-024-54155-0)

### B. Construcción y comprobación de historias

### 6. Barbosa et al., 2019

Personas con AUD de vida y tratamiento/apoyo informal: NESARC para transiciones cortas, cohorte californiana para calibración hasta 16 años y NESARC-III para comparación externa.

- **Verificado:** Tabla 1, fuentes/muestras; Tabla 2, comparabilidad tras matching; Figura 1, estados; Figura 2, proceso de calibración; Figura 3, distancia al objetivo durante optimización.
- **Útil:** transparencia sobre cada fuente y cada paso de calibración.
- **No trasladar:** probabilidades de una población seleccionada por AUD/tratamiento a población general chilena. La calibración larga proviene de una muestra geográficamente limitada.
- **Acceso:** texto completo indexado y apéndices en PMC; acceso directo intermitente.

[Artículo](https://pmc.ncbi.nlm.nih.gov/articles/PMC6842126/)

### 7. Moid et al., 2026

NLSY97 y NSDUH; seis estados, combinando consumo y dependencia; estimación, calibración y simulación por edad y sexo.

- **Verificado:** Tabla 1, fuentes; Figura 1, estados; Figuras 2–3, transiciones con intervalos; Figuras 4–5, distribución simulada por edad; Figuras 6–7, flujos.
- **Útil:** repertorio de visualizaciones de la salida del motor.
- **No trasladar:** dependencia como estado adicional no observado en los paneles chilenos, extrapolaciones adolescentes o decisiones estadounidenses.
- **Advertencia:** el texto describe repetir calibración después de revisar resultados de “validación”; no copiar ese procedimiento como validación independiente intacta.
- **Acceso:** texto completo; apéndices referenciados, no verificados íntegramente.

[Artículo](https://pmc.ncbi.nlm.nih.gov/articles/PMC12949772/)

### 8. Delucchi y Weisner, 2010

1.350 personas inicialmente con consumo problemático, reclutadas en población y tratamiento; seguimientos a 1, 3, 5 y 7 años.

- **Verificado:** Tabla 2b, matrices observadas consecutivas; Tabla 3, comparación de Markov, mover–stayer, modelos latentes y homogeneidad temporal; Figura 1, probabilidades del modelo final; Tabla 4, secuencias/clases.
- **Útil:** distinguir observación y modelo, y documentar selección.
- **No trasladar:** sus estados combinan consumo, síntomas y consecuencias; no son C1–C3+ ni representan población general.
- **Acceso:** texto/tablas indexados de PMC; apertura directa con CAPTCHA.

[Artículo](https://pmc.ncbi.nlm.nih.gov/articles/PMC2841731/)

### C. Componentes estadísticos

### 9. Liu et al., 2016; publicación electrónica 2012

Ensayo de dependencia alcohólica; registros diarios; compara distribuciones positivas en modelos longitudinales de dos partes.

- **Útil:** justificar comparación lognormal versus alternativas, incluida gamma generalizada, y examinar heterocedasticidad.
- **No trasladar:** que una distribución gane en un ensayo implica que ganará en EPS/TSM. Gamma generalizada tampoco es simplemente el mismo modelo que Gamma.
- **Acceso verificado:** abstract y página editorial; **no verifiqué números de tablas/figuras**.

[Resumen primario](https://pubmed.ncbi.nlm.nih.gov/22474003/)

### 10. Buta et al., 2018

COMBINE; análisis de semanas de tratamiento; modelo conjunto de abstinencia, frecuencia e intensidad con efectos aleatorios correlacionados.

- **Verificado:** Figura 1, distribuciones; Figura 2, componentes en el tiempo; Figura 3, comprobaciones predictivas posteriores; Tabla 1, parámetros e intervalos por componente y método.
- **Útil:** separar participación y cantidad, y revisar si el modelo reproduce ceros y dispersión.
- **No trasladar:** escala semanal/diaria y medición detallada a unas pocas entrevistas multianuales; complejidad de efectos aleatorios sin suficiente información.
- **Acceso:** texto completo.

[Artículo](https://pmc.ncbi.nlm.nih.gov/articles/PMC6527419/)

### 11. Shirley et al., 2010

240 participantes de ensayo, 168 días; Markov y Markov oculto sobre consumo ordinal.

- **Verificado:** Figura 1, secuencia de una persona; Figura 2, conjunto de 240 series.
- **Útil:** alternativas visuales a una curva media y distinción entre observación y estado latente.
- **No trasladar:** evidencia de identificación de estados latentes con registros diarios a EPS con pocas olas.
- **Acceso:** PDF del autor.

[Artículo](https://kennyshirley.com/papers/shirley_etal_2010.pdf)

### 12. Olsen y Schafer, 2001

Desarrollo de modelo longitudinal de dos partes; aplicación al consumo adolescente, grados escolares 7–11.

- **Útil:** fundamento para distinguir probabilidad de consumo y cantidad positiva, permitiendo dependencia entre componentes.
- **No trasladar:** población escolar y objetivo de crecimiento como estimador automático de transiciones chilenas.
- **Acceso verificado:** abstract editorial; **sin figuras/tablas comprobadas**.

[Artículo](https://www.tandfonline.com/doi/abs/10.1198/016214501753168389)

## 2. Menú propio de tablas

**Son alternativas, no una propuesta de publicar todas.** P = candidata al principal; S = suplemento. La ubicación depende de la historia elegida. Las preferencias posteriores del usuario están al inicio; las etiquetas siguientes conservan el menú completo original, no una decisión final.

Reglas comunes: estimaciones ponderadas con denominadores no ponderados; incertidumbre que respete diseño y repetición de personas; separar estimación, calibración y evaluación. Cada intervalo debe identificarse como observado o modelado. No fijo rango etario definitivo.

| ID y título propuesto en inglés | Pregunta y estructura | Población, horizonte e insumos | Incertidumbre, factibilidad y riesgo | Lugar |
|---|---|---|---|---|
| **T1. Data Sources and Measurement Compatibility** | ¿Qué aporta cada encuesta? Filas: fuente/ola; columnas: cobertura, instrumento, ventana, cantidad, frecuencia, HED, pesos y función analítica. | EPS, TSM, ENPG, ELSOC; periodos propios. | Alta factibilidad documental. Riesgo: presentar armonización como equivalencia. | P/S |
| **T2. Longitudinal Sample Construction and Follow-up** | ¿Quién aporta transiciones? Filas: pares de olas; columnas: elegibles, enlazados, excluidos, personas, pares e intervalo. | EPS VI–VIII; TSM R7–11; ELSOC separado. | Carga baja-media; no confundir pares con personas independientes. | P |
| **T3. Drinking-State Definitions and Historical Information** | ¿Cómo se asignan N0, FD y C1–C3+? Filas: estado; columnas: regla, historia requerida, fuente, ambigüedad. | Cada instrumento y ventana observada; EPS 2009 cuando aporte historia. | Alta factibilidad; explicitar N0 como historia desconocida, no abstinencia vital. | P/S |
| **T4. Baseline Characteristics and Follow-up Participation** | ¿Quién permanece y quién se pierde? Filas: características; columnas: muestra inicial, seguida, perdida y contraste estandarizado. | Cada panel y periodo, separadamente. | IC y tamaños; pesos de origen. Carga media; comparaciones descriptivas, no prueba de MAR. | P/S |
| **T5. Observed Drinking-State Transition Matrices** | ¿Qué cambios registra el panel? Filas: origen; columnas: destino, porcentaje e IC; paneles por fuente/intervalo. | Pares observados EPS/TSM; horizonte real. | Denominadores por origen, celdas escasas. Carga media; no llamar anuales a matrices multianuales. | P |
| **T6. Standardized Transition Probabilities by Population Group** | ¿Qué heterogeneidad permanece tras estandarizar? Filas: transiciones seleccionadas; columnas: sexo, edad o educación. | Dominio con soporte; horizonte común explícitamente modelado. | Intervalos y distribución de estandarización; carga alta; evitar subdivisión excesiva. | P/S |
| **T7. Participation and Positive-Consumption Model Results** | ¿Qué cambia en consumo/no consumo y en cantidad positiva? Filas: predictores/componentes; columnas: efectos interpretables e IC. | EPS/TSM por separado; siguiente entrevista o horizonte definido. | Distinguir efectos condicionales/marginales. Carga media-alta; no llenar principal de coeficientes. | P/S |
| **T8. Predictive Performance of Candidate Transition Models** | ¿Qué motor reproduce mejor datos no usados para ajustar? Filas: matriz regularizada, dos partes LN/Gamma, ordinal; columnas: métricas comunes, estabilidad y complejidad. | Particiones por persona y/o tiempo; horizontes observados. | Incertidumbre de diferencias; mismos datos evaluables. Carga alta; AIC no sustituye desempeño externo. | P |
| **T9. Attrition Adjustment and Weight Diagnostics** | ¿Cuánto depende el resultado de pesos/IPW? Filas: estrategia; columnas: ESS, percentiles, extremos, balance y estimandos clave. | Paneles y pares; horizonte observado. | Sensibilidad al truncamiento; revisar doble ajuste con ponderadores longitudinales. Carga media. | S/P |
| **T10. Calibration Targets and Held-out Evaluation Results** | ¿Qué se ajustó y qué se dejó intacto? Filas: target/estimando; columnas: fuente/año, uso, observado, predicho y discrepancia. | ENPG 2012–24 y datos longitudinales reservados, roles separados. | IC del target y simulación. Carga alta; ajuste marginal no valida transiciones. | P |
| **T11. Simulated Exposure-History Summaries** | ¿Qué historias genera cada motor? Filas: estado inicial/grupo; columnas: tiempo por estado, cambios, abandono, retorno y exposición acumulada. | Población inicial elegida; horizontes 1/5/10 años como opciones, no decisión cerrada. | Incertidumbre paramétrica y Monte Carlo separadas. Carga alta; historia simulada ≠ observada. | P/S |
| **T12. Sensitivity to Measurement and Modelling Assumptions** | ¿Qué decisiones cambian conclusiones? Filas: cortes, gramos/trago, categorías abiertas, N0/FD, intervalos, especificación y atrición. Columnas: escenario y cambio en estimandos. | Dominio y horizonte de cada análisis. | Rango entre escenarios, no “IC” único. Carga alta; priorizar incertidumbres plausibles. | S/P |
| **T13. Cross-Source Triangulation of Drinking Dynamics** | ¿Coinciden patrones cualitativos? Filas: persistencia, aumento, reducción, no consumo; columnas: EPS, TSM, ELSOC y compatibilidad. | Ventanas propias; ELSOC con su medición original. | Estimaciones e IC propios; no promediar efectos no equivalentes. Carga media. | P/S |
| **T14. Empirical Support Across Age Groups** | ¿Dónde hay información directa y dónde extrapolación? Filas: grupos etarios posibles; columnas: personas, pares, positivos, estados raros y cobertura. | Todas las fuentes, incluyendo 15–17 y &gt;65 cuando existan. | ESS y precisión; carga media. No convierte filtro actual 18–65 en decisión científica definitiva. | P/S; usuario posteriormente eligió S |

## 3. Menú propio de figuras

| ID y título propuesto en inglés | Pregunta, ejes o estructura | Población/horizonte e insumos | Incertidumbre, carga y riesgo | Lugar |
|---|---|---|---|---|
| **F1. Study Timeline and Evidence Coverage** | ¿Dónde y cuándo observamos? Eje x: año; filas: fuentes; olas, intervalos y cobertura etaria. | Todas las fuentes, periodos reales. | Documental; carga baja. Diferenciar cobertura poblacional de muestra analizada. | P/S |
| **F2. Observed Drinking-State Transition Patterns** | ¿Dónde se concentra el cambio? Heatmaps origen × destino, por fuente/intervalo. | Pares EPS/TSM. | Mostrar n y precisión con anotaciones o panel complementario. Carga media; mismo color no implica igual horizonte. | P |
| **F3. Persistence and Change Across Population Groups** | ¿Qué grupos difieren? Forest plot de probabilidades estandarizadas o contrastes; filas: grupos/transiciones. | Dominio con soporte; horizonte común declarado. | IC y referencia explícita. Carga media-alta; no sobreestratificar. | P/S |
| **F4. Drinking Participation and Positive Consumption Over Time** | ¿Qué parte explica el cambio? Paneles: probabilidad de consumo y distribución/cantidad positiva; x: tiempo o edad. | EPS/TSM separados; periodo observado. | Bandas y datos de apoyo. Carga media; curvas medias no son historias individuales. | P/S |
| **F5. Observed and Predicted Transition Probabilities** | ¿Dónde falla cada modelo? x: observado; y: predicho, diagonal de identidad; facetas por modelo. | Muestra longitudinal reservada; cada intervalo real. | Incertidumbre de ambos lados; carga alta. No usar datos de entrenamiento como validación. | P |
| **F6. Population Distributions Before and After Calibration** | ¿Qué modifica calibrar? x: año/edad; y: proporción por estado; observado, antes y después. | ENPG y simulación en población comparable. | IC de encuesta y bandas simuladas; carga alta. Identificar años target y reservados. | P/S |
| **F7. Predicted Drinking-State Occupancy by Initial State** | ¿Cómo cambia la composición desde distintos puntos de partida? x: años; y: probabilidad; paneles por estado inicial. | Cohorte simulada, horizontes elegidos. | Bandas paramétricas. Carga media-alta; no presentar ocupación como permanencia continua. | P |
| **F8. Individual Exposure Sequences Under Alternative Models** | ¿Motores con marginales similares producen historias distintas? x: tiempo; filas: personas simuladas; color: estado. | Misma población inicial y escenarios; hasta horizonte elegido. | Varias réplicas/resúmenes, no una muestra “bonita”. Carga alta; ilustración, no evidencia individual observada. | P/S |
| **F9. Retention and Weighting Diagnostics** | ¿Dónde se pierde representatividad? Paneles de retención por estado inicial y distribución de pesos/ESS. | Cada panel e intervalo. | IC de retención; carga media. No afirmar que ponderar elimina sesgo no observado. | S/P |
| **F10. Sensitivity of Exposure Histories to Key Assumptions** | ¿Qué supuesto domina? x: cambio en estimando; filas: escenarios de medición/modelo; puntos o rangos. | Horizontes y población fijos dentro de comparación. | Separar escenario de incertidumbre estadística. Carga alta; no mezclar estimandos con unidades distintas. | P/S |
| **F11. Drinking Frequency and Heavy-Episodic Patterns Across Sources** | ¿Se conserva dirección del cambio con mediciones distintas? Paneles separados por fuente, x: edad/ola; y: medida propia. | TSM/ENPG y ELSOC solo donde pertinente. | IC propios; carga media. Nunca una única escala que simule equivalencia de HED. | S/P |
| **F12. Age-Specific Information and Extrapolation Boundaries** | ¿Dónde descansa el resultado en datos? x: edad; y: pares/ESS o precisión; bandas de cobertura. | EPS, TSM y ENPG por fuente. | Incertidumbre y celdas escasas; carga media. Evitar ocultar &gt;65 por filtro analítico o asumir soporte 15–17. | P/S; usuario posteriormente eligió S |

### Alternativas de relato conservadas para trazabilidad

- **Relato poblacional:** T5/F2 y T6/F3 como centro; modelos y diagnósticos al servicio del cambio observado.
- **Relato metodológico:** T8/F5 como centro; mostrar cuándo motores distintos producen historias similares o diferentes.
- **Relato de construcción del insumo:** T10/F6 y T11/F7–F8 como centro; dejar trazable cómo los paneles alimentan historias simuladas.

El comparador **rank-matching ENPG** puede aparecer en T8, T11 y F8, rotulado como reconstrucción sintética bajo conservación de rango, **no como estimador de transiciones observadas**. No debería “ganar” por reproducir marginales que ya utiliza como insumo.

## 4. Preguntas originales de priorización y estado

Se conservan como registro de la propuesta. El usuario ya respondió con la priorización resumida al inicio; no deben tratarse como preguntas todavía pendientes ni repetirse automáticamente.

1. **¿Qué te gustaría que el lector pudiera afirmar al cerrar este primer artículo: cómo cambia el consumo en Chile, qué modelo representa mejor ese cambio, o cuán defendibles son las historias que alimentarán el motor? Puedes ordenar las tres.**
2. **¿Qué resultados quieres comparar primero para decidir: matrices de transición, diferencias por grupos, cantidad/frecuencia/HED, o historias simuladas? Elige dos, sin decidir todavía principal versus suplemento.**
3. **¿Prefieres que evaluemos las opciones etarias con una tabla de soporte empírico antes de fijar la población, y que reservemos datos de validación antes de escoger entre modelos? ¿Hay alguna restricción editorial o analítica que deba gobernar esas dos decisiones?**

## 5. Estado de ejecución y pendientes reales

- Investigación y menú entregados; preferencias del usuario incorporadas como decisiones y selección provisional claramente distinguida.
- No se generaron figuras, código, modelos ni nuevos resultados. No se investigó el artículo 2.
- No se decidió el rango etario final, el modelo ganador ni la selección editorial definitiva.
- Persisten límites de acceso declarados: suplementos no inspeccionados íntegramente y abstract-only para Liu y Olsen–Schafer en esta búsqueda.
- La factibilidad de los productos depende de revisar datos, tamaños efectivos, medición y particiones de evaluación; las propuestas no afirman que ese análisis ya se haya realizado.

