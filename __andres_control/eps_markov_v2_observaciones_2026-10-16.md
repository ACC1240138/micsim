# Observaciones del usuario para la v2 de `eps_markov_transitions_EN`

Versión 3 de esta nota: 2026-10-16, noche. Reemplaza las dos versiones anteriores del mismo día. Agrega la revisión de los cuestionarios y del diseño de la EPS (rondas VI, VII y VIII) y una sección exclusiva de indicaciones para mejorar el ipynb.
Origen: tres mensajes de Andrés González Santa Cruz del 16-oct-2026 (14:46, 15:36 y 17:51), después de leer las explicaciones del notebook. Las citas son textuales, con los errores de tipeo corregidos.
Uso previsto: instrucciones para que Claude Code prepare la v2 del entregable `eps_markov_transitions_EN` (sección "Indicaciones para mejorar el ipynb") y contexto para entender por qué.
Alcance: no se editó ningún notebook, `.html`, `.qmd` ni código, y nada se volvió a ejecutar. Las cifras vienen del código y de las salidas agregadas del notebook (`eps_markov_outputs/` y tablas del `.html`), de los cuestionarios, informes y notas de `micsim/_enpg` y `micsim/_eps`, de la auditoría `__andres_control/auditoria_microsim_2026-10-09/hed_diagnostic.md` y de una investigación web del 16-oct (fuentes al final). No se leyó ningún microdato. La carpeta `_eps` revisada es la de `C:\Users\andre\Documents\micsim` (la ruta `C:\Users\nDP\...` no está en el computador conectado; es el mismo repositorio).

Cómo leerla. La parte 0 resume lo que sirve para decidir. La sección "Indicaciones para mejorar el ipynb" es la lista de trabajo para Claude Code. La parte 1 ordena las observaciones del usuario por tema. La parte 2 son explicaciones simples que la v2 debería incorporar. La parte 3 reúne los datos de apoyo. La parte 4 propone métricas nuevas. La parte 5 son sugerencias de Claude, que no son del usuario. La parte 6 lista lo que no se pudo verificar.

## 0. Lo esencial

1. La matriz A reproduce bien las prevalencias por categoría fuera de muestra. En C3+C4 predice 1,47 % frente a 1,44 % observado, y el ordinal en dos partes 1,44 %. Lognormal predice 1,09 % (24 % menos) y gamma 0,82 % (43 % menos; en C4 sola, 74 % menos). La condición del usuario para preferir A ("si no reproduce bien las prevalencias por categoría, nada que hacer") se cumple a nivel global. Falta comprobarla por estado de origen y subgrupo (parte 4).
2. En log loss, lognormal, ordinal simple y multinomial están prácticamente empatados (0,7055 a 0,7081). A y gamma quedan alrededor de 1 % atrás en probabilidad típica (log loss 0,7148 y 0,7176; probabilidad típica 48,9 % y 48,8 % frente a 49,4 % de lognormal). Educación, sus interacciones y la historia previa no aportan nada detectable (todos sus intervalos cruzan 0). Ninguna de estas diferencias condicionaría una publicación.
3. Lo que sí mueve resultados, de mayor a menor: (a) los gramos por trago: con 15,7 g en vez de 12 g, la proporción predicha en C3+C4 sube entre 1,7 y 2,2 veces (predicciones de gamma y lognormal, que ya subestiman la cola); (b) la aproximación de HED: ≈20 % de los bebedores en la EPS frente a 44 a 56 % en la ENPG según la ola; miden cosas distintas (cantidad típica frente a al menos una ocasión en 30 días), y cuánto de la brecha se debe a eso y cuánto a la población y al año no está separado (sugerencia 5.5); (c) la capa anual: con gamma, ajustes casi igual de buenos difieren hasta 10,5 puntos, y la permanencia anual de C4 sale 0,10 con gamma y 0,40 con A, ambas compatibles con los datos; (d) las colas con pocos casos: 29 pares con origen C4. Esto es lo que miraría un revisor.
4. HED en la ENPG: la misma pregunta desde 2012 hasta 2024 (número de veces en los últimos 30 días con 5 o más tragos los hombres y 4 o más las mujeres "en una sola ocasión", unas dos horas). Verificada en los cuestionarios 2012, 2014, 2016, 2022 y 2024, y en el oficial de 2018. 2008 y 2010 no tienen esa pregunta. Cambios menores entre olas: exclusión de festividades desde 2016, y una tarjeta de mujeres que muestra los volúmenes de los hombres en 2022 y 2024 (desde 2020 según la auditoría del proyecto).
5. Para la capa anual, lo de menor costo es fusionar C3+C4 (equivale a la categoría más alta de SIMAH y NESARC: ≥40 g mujeres, ≥60 g hombres), encoger la fila C4 hacia C3 y mostrar bandas de incertidumbre. De costo medio: permitir solo transiciones entre categorías vecinas (msm) y calibrar a la ENPG. Con NESARC, un modelo con transiciones solo entre vecinas predijo las proporciones a 11 años con diferencias de 1 % o menos (modelo de cantidad).
6. La capa anual también está calculada para A, con intervalos del jackknife (`annual_pooled_matrices_design_CI.csv`, en la carpeta local de salidas): permanencia anual N0 0,913, FD 0,871, C1 0,818, C2 0,535, C3 0,443 y C4 0,403 (IC 0,085 a 0,830). Está en el mismo orden de magnitud que NESARC. La sensibilidad a reinicios y penalización solo se calculó para gamma.
7. La referencia del proyecto (Kilian et al. 2025, SIMAH) no estimó las transiciones de consumo con un panel. Usó regresión logística ordinal sobre un pseudo-panel de BRFSS 2000 a 2010, calibrada con history matching contra BRFSS 2011 a 2015 y validada con BRFSS 2016 a 2019. Se parece más al enfoque de JRT (polr + pseudo-panel) que a la EPS.
8. Los cuestionarios de la EPS preguntan el alcohol igual en las rondas VI, VII presencial y VIII (F.13 consumo por bebida, F.14 días a la semana en el último mes, F.15 vasos o copas por ocasión), con cambios menores de códigos (3.15). La VII de continuidad y la re-entrevista, hechas en pandemia, no tienen ese módulo; por eso el notebook usa solo la VII presencial. El diseño oficial selecciona una comuna por estrato, lo que explica los 32 estratos con una sola UPM, y el informe técnico de la VIII recomienda linealización con `cluster_ID`, `strata_ID` y el peso final, con la opción `certainty` para esos estratos. El notebook sigue esa guía y usa `adjust` como opción principal, que es más conservadora (3.9).

## Indicaciones para mejorar el ipynb (para Claude Code)

Reglas de trabajo:
- Pedir permiso explícito al usuario antes de crear o editar cualquier notebook. Trabajar en una copia nueva (`eps_markov_transitions_EN_v2.ipynb`) y escribir las salidas nuevas en `eps_markov_outputs_v2/`; no tocar la versión actual ni sus salidas.
- Mantener el estilo del notebook: `paquete::función`; cada chunk empieza con `.t0` y termina informando los minutos transcurridos; comentarios y mensajes en inglés.
- No renombrar objetos ni columnas existentes; agregar columnas o archivos nuevos.
- Dejar como parámetros las partes caras (`ep_repeats`, `ep_B`, sensibilidad de la capa anual) y registrar el tiempo de cada celda. Hoy el notebook completo tarda unos 21 min, de los cuales 18,4 son la celda de jackknife y bootstrap.
- Al terminar, ejecutar con los datos reales, correr los checks de "Executed checks on real EPS data" y decir qué se ejecutó y qué no.
- Antes de empezar, mostrar al usuario el plan y la estimación del tiempo de ejecución.

Orden sugerido: I-2, I-1, I-4, I-5, I-6, I-3 e I-7; después la prioridad 2 y la 3.

### Prioridad 1: antes de usar el motor en la microsimulación

| ID | Qué hacer | Por qué | Listo cuando |
|---|---|---|---|
| I-1 | Calibración fuera de muestra por fila: origen (N0, FD, C1 a C4) × sexo × grupo de edad × destino, para A, A_education, lognormal, gamma, ordinal simple, ordinal en dos partes, multinomial y JRT. Columnas: n de origen, observado, predicho, diferencia absoluta y relativa. Marcar celdas con menos de 30 pares de origen | La condición del usuario para A (O20) solo está comprobada a nivel global | `calibration_by_origin_cell.csv`, una figura por origen y un párrafo que diga dónde falla cada motor |
| I-2 | Capa anual de A a la vista y con la misma sensibilidad que gamma: mostrar la tabla de permanencias de A, gamma y lognormal (ya está en `annual_pooled_matrices_design_CI.csv`) y extender `annual_generator_sensitivity` a A y lognormal (penalización 1e-5, 5e-5 y 2e-4; varios puntos de partida) | A es el motor preferido (O20); hoy la tabla visible y la sensibilidad son solo de gamma | `annual_generator_sensitivity.csv` con columna `model` para los tres motores; texto que diga cuál es el motor principal y por qué |
| I-3 | Validación de trayectoria: con la matriz anual de cada motor, proyectar a las personas observadas en VI y VIII desde su estado en VI hasta VIII (7,693 años según `ep_time`) y comparar con lo observado en VIII por sexo × grupo de edad, con IC del jackknife | La micsim aplica la matriz muchas veces; un buen paso único no garantiza una buena trayectoria (O13, O21) | `trajectory_validation_VI_VIII.csv` y una figura observado frente a proyectado |
| I-4 | Variante con C3+C4 fusionadas (destinos NC, C1, C2, C3+): reestimar A, lognormal y la capa anual; comparar permanencias, intervalos y calibración de C3+ | C4 tiene 29 pares de origen y su permanencia anual sale 0,10 o 0,40 según el motor; C3+C4 equivale a la categoría más alta de SIMAH y NESARC | Tabla lado a lado con y sin fusión |
| I-5 | A con préstamo entre filas vecinas (`A_ordinal`): encoger las filas C4 y C3 hacia la fila vecina expresada en movimientos relativos (quedarse, bajar uno, bajar dos, dejar de beber), con un peso elegido por CV interna como el k actual | Estabiliza las colas sin supuestos de linealidad ni aditividad (O19, O20) | Fila nueva en la CV, contraste con A y calibración por categoría |
| I-6 | A con C1 partido por gramos previos (2 o 3 tramos por sexo, por ejemplo terciles ponderados de g/día dentro de C1); sigue siendo una tabla | Probar si A recupera parte de lo que lognormal gana con `lg0` (≈0,009 de log loss) | Contrastes de `A_C1split` frente a A y frente a lognormal |
| I-7 | Gramos por trago: fijar 12 g con fuente (tarjeta 6 de la ENPG 2018: 333 cc de cerveza, 140 cc de vino, 40 cc de licor) y correr la sensibilidad de 15,7 g para todos los motores, incluido A, y para la capa anual | Con 15,7 g la proporción predicha en C3+C4 sube entre 1,7 y 2,2 veces; la EPS pregunta "vasos o copas" sin volumen | Tabla de sensibilidad con A, gamma y lognormal |

### Prioridad 2: para el artículo y los revisores

| ID | Qué hacer | Por qué | Listo cuando |
|---|---|---|---|
| I-8 | Contrastes pareados completos entre lognormal, ordinal simple, ordinal en dos partes, multinomial, A, gamma y JRT_reference | Hoy faltan las parejas entre los mejores modelos y todas las de JRT (O17, O22) | Matriz de contrastes con IC |
| I-9 | Más repeticiones de CV, al menos para los contrastes con JRT: dejar `ep_repeats` como parámetro y probar 5×50 (≈27 min si escala lineal) | JRT cambia de signo frente a gamma entre repeticiones (O2) | Desviación de cada contraste entre repeticiones, con 5×3 y con 5×50 |
| I-10 | Métricas nuevas: RPS ordinal, descomposición del Brier (fiabilidad, resolución, incertidumbre), log loss por estado de origen, mejora relativa sobre el nulo y escalera de modelos (nulo, solo origen, A, más educación, más gramos previos, paramétricos) | Muestran qué aporta cada pieza y dónde difieren los modelos (O17) | `cv_metrics_extended.csv` y una tabla en el texto |
| I-11 | Transporte con intervalos (SE de diseño pareado) y con los conteos de exclusión (forward 450 = 412 FD + 38 por edad; retro 794 por edad) | Sin intervalos no se pueden juzgar diferencias de 0,01 (O4) | Tabla de transporte con IC y exclusiones |
| I-12 | Diseño: reportar Kish y el n_eff o deff de diseño para las prevalencias clave; explicar que el enfoque sigue la recomendación oficial de la EPS (3.9), que `adjust` es la opción principal y `certainty` (la oficial) la sensibilidad, y por qué no hay probabilidades por etapa, FPC ni incertidumbre de los pesos oficiales; verificar cómo quedan codificadas las comunas autorrepresentadas | O8 y O9 | Párrafo de diseño con cita a los informes de la EPS y tabla Kish/deff |
| I-13 | HED: llamar "señal de cantidad típica" a la medida de la EPS; agregar la tabla de redacción por ola de la ENPG (3.7); calcular la misma señal en la ENPG (hombres con día típico de 5 o más tragos en el ítem AUDIT) para compararla con la EPS | Separar constructo distinto de población distinta (O7, O14) | Tabla comparativa por sexo y grupo de edad |
| I-14 | Preparar la calibración a la ENPG sin hacerla en este notebook: exportar las matrices anuales por sexo × grupo de edad y las prevalencias proyectadas en el formato que usará el raking | La prevalencia de consumo del mes en la ENPG cayó de 43,3 % (2018) a 34,6 % (2024) y una matriz fija no reproduce esa caída | `annual_matrices_for_calibration.csv` y la descripción del formato |
| I-15 | Especificación alternativa con covariables comunes, como sensibilidad: previsión de salud (Fonasa A y B, Fonasa C y D, Isapre, otra), tabaco actual (EPS F.12.a), estado civil y macrozona, en lognormal u ordinal; solo las que existan en la población sintética | O11 y O18 | Contrastes con el modelo base |

### Prioridad 3: texto y presentación

| ID | Qué hacer | Por qué | Listo cuando |
|---|---|---|---|
| I-16 | Definir NC una vez y declarar la limitación de FD una vez; explicar las métricas con el ejemplo X/Y y la probabilidad típica; definir el transporte; rotular el rank matching como entre rondas; explicar en simple el bootstrap de 500 frente a 1.000 y la permanencia anual (ejemplo de dos estados y de C4); agregar la tabla de predictores; aclarar que el bootstrap reestima solo IPW, gamma y lognormal | O1 a O6, O10, O12, O13, O15, O16 y O21 | Textos nuevos en las celdas markdown correspondientes |
| I-17 | Reemplazar el argumento "cambio medio de 0,35 puntos; se retiene gamma" por la calibración por categoría y declarar qué motor es el principal para la micsim y por qué | El cambio medio diluye las colas; gamma subestima C3+C4 en 43 % | Celda de conclusión reescrita |
| I-18 | Agregar al `harmonization_audit` la redacción y los códigos de F.13 a F.15 por ronda (3.15) y una nota de que la VII de continuidad y la re-entrevista no tienen ese módulo | Trazabilidad del cuestionario | Tabla nueva en el notebook |

## 1. Observaciones del usuario, por tema

Tipos: D = decisión o límite aceptado. E = pide una explicación más clara. Q = pregunta que puede cambiar el análisis. P = propuesta de especificación. O1 a O13 son de la primera ronda (14:46); O14 a O22, de la segunda (15:36).

### T1. Notación y límites aceptados
- O10 (D). "basta con mencionarlo una vez: NC es no consumo actual (N0 más FD)." Para la v2: definir NC una sola vez.
- O6 (D). Sobre FD y la ventana de recuerdo: "es una limitación pero es lo que tenemos. hay que operar con eso." Para la v2: declarar la limitación una vez y operar con FD tal como está.

### T2. HED
- O7 (D). "EL HED, se tendrá que operar con eso, con la cantidad típica, no hay más." y "cómo lo hace la enpg a diferencia de eps?" Para la v2: mantener la señal de cantidad típica, documentar la diferencia con la ENPG y no llamarla HED observado (3.7).
- O14 (Q). "verifica la redacción por ola de 2010 a 2022, con expand_pifs". Hecho (3.7). Para la v2: citar la tabla por ola.

### T3. Diseño e incertidumbre
- O8 (E). "cuál es el peso efectivo por el diseño y además por la dispersión de pesos?" Para la v2: reportar ambos (3.8).
- O9 (Q). "por qué no se hace esto conjuntamente con los IPW? no se reconstruyen probabilidades de inclusión por etapa, ni correcciones por población finita, ni la incertidumbre de los pesos oficiales." Para la v2: explicar por qué no entra y decidir si se intenta (3.9).
- O12 (E). "No entiendo esto: Con 500 réplicas de personas el error estándar mediano ya es el 99,9 % del de 1.000. Qué implicancias tiene?" Para la v2: reescribir en simple (3.11).
- O15 (E). "El jackknife y el bootstrap rehacen la muestra y miden cuánto se mueven matrices y coeficientes. esto no lo entendí". Para la v2: explicación simple (2.2).

### T4. Validación y comparación de modelos
- O1 (E). "explica las métricas de CV utilizadas." (2.1, 3.1)
- O2 (Q). "haber hecho un 5x50 rep no habría sido mejor para estabilidad en vez de 5x3? habría sido muy lento? o el bootstrap ya captura esa variabilidad?" (3.3)
- O3 (E). "qué predictores usan?" (3.4)
- O4 (E). "qué significa el transporte entre periodos?" (3.5)
- O16 (E). "todavía no entiendo ese 49,4 % vs 48,8 % del log loss, no es intuitivo, muéstralo con una figura o algo en simple." Para la v2: explicación con ejemplo y figura (2.1).
- O17 (Q). "me faltan más métricas para complementar la CV, creo yo. TODAVÍA NO SE VE CLARA LA CONTRIBUCIÓN DE CADA UNO Y SI EN VERDAD UNA ES MEJOR QUE OTRA." Para la v2: tabla de contribuciones (3.1) y métricas nuevas (parte 4).
- O22 (Q). "En general, me falta entender la magnitud de las desviaciones o problemas que indicas. También de las diferencias entre los mejores modelos para juzgar si son verdaderamente relevantes o si en verdad condicionarían su aceptación en una revista científica. Ustedes las IAs a veces exageran diferencias que no son clínicamente relevantes." Para la v2: tabla de magnitudes con un criterio de relevancia fijado antes de comparar (2.5).

### T5. Especificación del motor
- O11 (P). "Los modelos no pueden ser alimentados por otra información sociodemográfica o jerárquica que sea común a ENPG y a EPS? Esto como especificación alternativa (ej., jerárquica que permita extrapolar en condiciones de data sparsity, o incorporando como predictores [no como estratificadores] determinadas variables comunes, para alimentar la simulación de manera más válida)." (2.4, 3.12)
- O18 (Q). "Investiga sobre la ENPG sobre las variables comunes, tipos de pregunta, niveles de medición y que pudieran compartirse con el EPS." (3.12)
- O19 (E). "No entiendo qué indicas tú que ayudaría: dijiste información entre categorías (la estructura ordinal) y datos externos. Explica y busca mejor eso." (2.4)
- O20 (D). "Mi gran desafío respecto a eso es que requiere hacer un paso de más de toma de decisiones: la parametrización, supuestos de linealidad, ordinalidad, aditividad, etc. Por eso lo ideal era la matriz A. Pero si anda mal o no reproduce bien las prevalencias por categoría, nada que hacer." Lectura: preferencia por A, condicionada a que reproduzca prevalencias por categoría. Hoy lo hace a nivel global (3.2); falta por origen y subgrupo.

### T6. Dinámica anual
- O5 (E). "los porcentajes de exageración de persistencias son escalados a un año o periodo entre encuestas?" Para la v2: rotularlos como entre rondas, 3,671 y 4,03 años (3.6).
- O13 y O21 (E, Q). "NO entiendo eso de la permanencia anual" y "sigo sin entender el problema de la permanencia anual y qué opciones ves para mejorarlas. Pon otros ejemplos, más fáciles." Para la v2: ejemplos simples y opciones (2.3, 3.10).

Instrucciones del usuario (no son observaciones): "Actualiza el .md y las observaciones ordenadas. Tómate tu tiempo" (15:36); "revisa los cuestionarios de EPS para v3" y "Al .md, agrega una sección exclusiva de indicaciones para mejorar el ipynb" (17:51).

## 2. Explicaciones simples para la v2

### 2.1 Log loss
- Para cada persona se mira qué probabilidad le había dado el modelo a lo que de verdad le pasó. El log loss resume esas probabilidades con un promedio "geométrico", que castiga mucho haberle dado una probabilidad muy baja a algo que sí ocurrió. Probabilidad típica = e^(-log loss).
- Ejemplo con 3 personas. El modelo X les da 50 %, 50 % y 50 % a lo que les pasó. El modelo Y les da 70 %, 70 % y 20 %. El promedio simple de Y es mayor (53 %), pero su probabilidad típica es 46 % y la de X es 50 %, porque Y falló feo una vez. El log loss prefiere a X (0,693 frente a 0,774).
- En la EPS, probabilidad típica fuera de muestra: sin modelo (solo las proporciones generales) 44,3 %; JRT 48,6 %; gamma 48,8 %; A 48,9 %; ordinal en dos partes 49,1 %; multinomial y ordinal simple 49,3 %; lognormal 49,4 %. Todos ganan entre 4,3 (JRT) y 5,1 puntos (lognormal) sobre no tener modelo. Entre el mejor y el peor hay 0,8 puntos.
- Algunas de estas diferencias se detectan con los contrastes pareados (lognormal frente a gamma y frente a A; multinomial frente a gamma) y otras no (gamma frente a A; ordinal frente a gamma); JRT no se contrastó. El promedio tampoco dice dónde está la diferencia: entre lognormal y gamma está en las colas (3.2).

### 2.2 Jackknife y bootstrap frente a validación cruzada
- El jackknife y el bootstrap responden: si la encuesta hubiera caído en otras viviendas, ¿cuánto cambiaría la matriz? No se puede repetir la encuesta, así que se imita. El jackknife saca una UPM por vez (111 veces) y vuelve a estimar el IPW, los modelos principales y la capa anual; el bootstrap sortea personas con reposición (1.000 veces) y vuelve a estimar el IPW, gamma y lognormal. Lo que se mueve el resultado entre esas repeticiones es su error estándar. Ejemplo de la salida: la permanencia en C1 de hombres de 18 a 29 años en VI→VII es 0,671, con intervalo 0,621 a 0,718 (modelo gamma).
- La validación cruzada responde otra cosa: con la misma muestra, ¿qué tan bien predice el modelo a personas que no vio? Repetirla con otros sorteos de pliegues (5×3, 5×50) solo mide cuánto depende la nota de ese sorteo.
- Por eso uno no reemplaza al otro: el jackknife y el bootstrap miden la incertidumbre de muestreo de la matriz; las repeticiones de la CV miden el ruido de la nota de validación.

### 2.3 Permanencia anual
- La encuesta es una foto cada 3,7 a 4 años y la micsim necesita la película año a año. La permanencia anual es la probabilidad de seguir en el mismo estado un año después.
- Ejemplo 1 (inventado, dos estados). Cada año el 20 % de los bebedores deja de beber y el 10 % de los no bebedores empieza. De 100 bebedores quedan 80 al año 1, 66 al año 2, 56 al año 3 y 49 al año 4. De esos 49, 41 nunca dejaron (0,8 elevado a 4) y 8 dejaron y volvieron. La encuesta solo ve el año 0 y el año 4 y desde ahí hay que deducir el 80 % anual. Con dos estados, y viendo las dos filas (al año 4 beben 49 de 100 bebedores iniciales y 25 de 100 no bebedores iniciales), la cuenta tiene una sola respuesta; con una sola fila no alcanza.
- Ejemplo 2 (C1, datos reales). La capa anual da 0,812 para C1 (gamma). La proporción que estaría en C1 en cada aniversario es 0,812 elevado a 3,67 ≈ 47 % (43 % con 4,03 años). Entre rondas se observa más: 58,3 % (VI→VII) y 52,3 % (VII→VIII). La diferencia viene de quienes salen y vuelven y de que el ajuste no es exacto (RMSE 0,063).
- Ejemplo 3 (por qué C4 casi no tiene información). Empiezan 29 personas en C4. Con una permanencia anual de 10 %, después de 3,7 años quedarían 0,0 personas sin haber salido; con 25 %, 0,2; con 40 %, 1,0; con 52 % (la categoría más alta de NESARC), 2,6. Se observó 2,1 % (VI→VII) y 0 % (VII→VIII), o sea 0 o 1 persona. Eso es compatible con casi cualquier permanencia anual entre 0 y alrededor de 0,5 (cálculo simplificado de Claude que ignora los retornos). Lo confirma el notebook: con los mismos datos, la permanencia anual de C4 sale 0,10 con gamma (IC 0 a 1) y 0,40 con A (IC 0,09 a 0,83), y las dos reproducen lo observado a 4 años.
- Con seis estados y pocos casos, además, varias películas distintas producen fotos casi iguales. Con gamma, ajustes con la misma calidad cambian una probabilidad anual hasta 10,5 puntos, y hasta 33,8 si además se cambia la penalización.
- Comparación con NESARC (EE.UU.; Puka et al., msm con transiciones solo entre estados vecinos): no bebedores 90,1 %, I 90,2 %, II 31,8 %, III 52,2 %. EPS, capa anual con A: N0 91,3 %, FD 87,1 %, C1 81,8 %, C2 53,5 %, C3 44,3 %, C4 40,3 %; con gamma: 91,1 %, 87,1 %, 81,2 %, 51,7 %, 42,2 % y 10,3 %. C1 y C2 de la EPS usan los mismos cortes que I y II; C3+C4 corresponde a III. El orden de magnitud coincide; en la EPS, C1 es más móvil y C2 más estable que en NESARC.

Opciones para mejorar la capa anual, de menor a mayor costo:

| Opción | Qué cambia | Supuesto que agrega | Costo |
|---|---|---|---|
| Fusionar C3+C4 | Elimina la fila de 29 personas; la fila nueva tiene 98 pares de origen | La dinámica es común dentro de ≥40 g mujeres / ≥60 g hombres; los g/día dentro de la categoría se reparten con su distribución observada | Bajo |
| Encoger las filas débiles hacia la fila vecina antes de anualizar | Estabiliza C4 con C3 | El patrón relativo (quedarse, bajar uno, dejar de beber) se parece al de la vecina | Bajo |
| Bandas de incertidumbre | Correr la micsim con varias matrices plausibles en vez de una | Ninguno | Bajo a medio |
| Solo transiciones entre categorías vecinas (msm, como NESARC) | Menos tasas libres; un salto de C1 a C4 se explica como pasos | No hay saltos instantáneos de más de un nivel | Medio |
| msm con la fecha de entrevista de cada persona | Usa intervalos individuales en vez de los promedios 3,671 y 4,03 | Tasas constantes en el tiempo, o por período | Medio |
| Calibrar a la ENPG | Entre los ajustes casi iguales, elige el que reproduce las prevalencias bienales | La ENPG mide bien la prevalencia por categoría | Medio |

### 2.4 "Compartir información entre categorías" y "datos externos"
- Hoy la matriz A estima cada fila por separado. La fila C4 toma prestado de la misma fila en grupos demográficos más grandes (sexo, período, total), pero esos grupos siguen sumando solo 29 pares. Nunca usa lo que pasa en C3.
- Lo que muestra la EPS en VI→VII: desde C4, 34,5 % pasa a no consumo, 38,1 % a C1, 25,3 % a C3 y 2,1 % se queda. Desde C3, 25,1 % pasa a no consumo y 74,9 % a C1. Los 29 pares con origen C4 se reparten entre los dos períodos, así que la fila C4 de VI→VII tiene a lo más 27 pares: cada persona pesa en promedio 3,7 puntos o más de la fila.
- Compartir entre categorías es que la fila C4 aprenda también de C3 (y de C2) con una regla de parecido. La opción con menos supuestos: encoger la fila C4 hacia la fila C3 expresada en movimientos relativos (quedarse, bajar uno, bajar dos, dejar de beber), con un solo peso k elegido por CV, como el k que A ya usa. No exige linealidad ni aditividad, y la fila sigue siendo una tabla.
- Lo que ya hacen los modelos paramétricos: lognormal y gamma usan los gramos previos como número continuo y cortan una misma curva en C1 a C4, así que C3 y C4 salen de la misma curva que C1 y C2. Por eso extrapolan suave, pero si la forma de la curva está mal se equivocan en la cola (gamma predice C4 en 0,10 % frente a 0,39 % observado).
- Datos externos: el panel EPS informa quién se mueve; la ENPG informa cuántos hay en cada categoría cada dos años (n ≈ 18.000). Usarla significa ajustar el motor para que, proyectado año a año, reproduzca las prevalencias de la ENPG por sexo y edad. La forma con menos supuestos es el raking (IPF): mantiene la estructura de "quién se mueve" de A y solo corrige los márgenes. SIMAH hizo algo análogo: calibró los parámetros del modelo con history matching para reproducir las prevalencias por categoría de BRFSS 2011 a 2015.
- Advertencia: la prevalencia de consumo de alcohol del último mes en la ENPG fue 43,3 % (2018), 44,3 % (2020), 39,2 % (2022) y 34,6 % (2024), "el más bajo reportado" según el informe 2024 (`_enpg/docs/2024/enpg2024.pdf`). Una matriz fija estimada con la EPS 2015 a 2023 no reproducirá esa caída sin un ajuste por período.

### 2.5 Magnitudes: qué importa y qué no
Criterio propuesto, a fijar antes de comparar (propuesta, no decisión): dos modelos son equivalentes en la práctica si la prevalencia proyectada de C3+C4 difiere menos que el IC 95 % de la ENPG para ese subgrupo y las muertes atribuibles proyectadas difieren menos de 5 %.

| Tema | Magnitud | ¿Cambia la micsim? | ¿Lo objetaría un revisor? | Qué hacer |
|---|---|---|---|---|
| Lognormal, ordinal simple y multinomial entre sí | Log loss 0,7055 a 0,7081; probabilidad típica 49,4 % a 49,3 % | No | No | Elegir por calibración y simplicidad |
| A frente a lognormal | 0,0093 (IC 0,0034 a 0,0151); 48,9 % frente a 49,4 %; las probabilidades individuales cambian 2,1 puntos en promedio | Poco en prevalencias, porque A calibra bien; algo en quién se mueve dentro de una categoría | No, si se muestra la calibración | Mantener A como candidato; probar A con C1 partido por gramos previos |
| Gamma en las colas | C3+C4 43 % menos; C4 74 % menos | Sí: subestima a los más expuestos | Sí, si no se corrige | No usar gamma como motor principal sin calibrar |
| Lognormal en las colas | C3+C4 24 % menos; C4 28 % menos | Moderado | Probablemente pediría calibración | Calibrar a la ENPG |
| Educación, interacciones, historia previa | Diferencias de 0,0007 a 0,0034, con intervalos que cruzan 0 | No | No | Dejar como sensibilidad |
| Gramos por trago (12 frente a 15,7 g) | C3+C4 predicho pasa de 0,8 a 1,1 % a 1,8 a 1,9 % (gamma y lognormal) | Sí, mucho | Sí: hay que justificar el valor | Fijarlo con fuente y mostrar la sensibilidad (3.13) |
| Aproximación de HED en la EPS | ≈20 % de los bebedores frente a 44 a 56 % en la ENPG | Sí, si se usa para el nivel | Sí, si se la llama HED | Nivel desde la ENPG; la EPS solo para persistencia |
| Capa anual | Con gamma, hasta 10,5 puntos entre ajustes equivalentes (33,8 con otra penalización); C4: 0,10 con gamma y 0,40 con A, ambos compatibles con los datos | Sí | Sí | Opciones de 2.3, bandas de incertidumbre y la misma sensibilidad para A |
| Estratos con una sola UPM (32 de 33) | El error estándar cambia 9 % según la convención | Poco | Poco; basta documentarlo | Mantener "adjust" y reportar la sensibilidad |
| Repeticiones de la CV | Desviación del contraste lognormal menos gamma 0,0007 frente a un error estándar de 0,0036; JRT cambia de signo frente a gamma | No, salvo para JRT | No | 5×50 solo si se quiere afirmar algo sobre JRT |
| Bootstrap de 500 frente a 1.000 réplicas | Error estándar mediano 99,9 % | No | No | 500 en pruebas, 1.000 en la corrida final |
| Peso efectivo | n_eff ≈ 2.000 a 2.400 de 8.095 pares para la prevalencia de consumo | Define la precisión | Pedirían que se reporte | Reportarlo |

## 3. Datos de apoyo

### 3.1 Métricas de CV y contrastes pareados
Fuentes: `cv_scores.csv`, `CV_repeated_scores.csv`, tabla "Paired comparisons" del `.html`, `ep_loss`, `ep_score_contrasts`.
- Log loss: -ln de la probabilidad asignada a la categoría observada (piso 1e-8), promedio ponderado; menor es mejor. Brier: suma sobre las 5 categorías de destino de (P - 1 o 0)^2, entre 0 y 2. Exactitud: la categoría más probable coincide con la observada (0,690 a 0,695 en todos los modelos; predecir siempre "no consume" acierta 60,64 %).
- Modelo nulo (solo proporciones de destino): log loss 0,815 y Brier 0,502 (cálculo de Claude). Mejora relativa sobre el nulo en log loss: JRT 11,4 %, gamma 11,9 %, A 12,3 %, ordinal en dos partes 12,8 %, multinomial y ordinal simple 13,1 %, lognormal 13,4 %. En Brier: JRT 15,9 %, A 16,0 %, los demás 16,9 a 17,0 %.
- Contrastes pareados (diferencia de log loss; negativo favorece al primero; IC t con 78 gl; SE con UPM y estratos, condicional a las predicciones fuera de muestra):

| Comparación | Diferencia | IC 95 % | Probabilidad típica | Cambio medio de probabilidad (puntos) |
|---|---|---|---|---|
| Lognormal menos gamma | -0,01211 | -0,01919 a -0,00504 | +1,22 % | 0,35 |
| Gamma menos A | 0,00285 | -0,00781 a 0,01350 | -0,28 % | 2,13 |
| Lognormal menos A | -0,00927 | -0,01513 a -0,00340 | +0,93 % | 2,07 |
| NonPO dos partes menos ordinal dos partes | -0,00235 | -0,00763 a 0,00294 | +0,24 % | 0,29 |
| Ordinal dos partes menos gamma | -0,00712 | -0,01717 a 0,00292 | +0,71 % | 0,37 |
| Ordinal simple menos gamma | -0,00959 | -0,01920 a 0,00001 | +0,96 % | 0,82 |
| Multinomial menos gamma | -0,00959 | -0,01801 a -0,00116 | +0,96 % | 0,49 |
| A con educación menos A | 0,00125 | -0,00064 a 0,00314 | -0,13 % | 0,62 |
| Gamma menos gamma sin educación | -0,00127 | -0,00344 a 0,00091 | +0,13 % | 0,84 |
| Gamma con interacciones de educación menos gamma | 0,00166 | -0,00050 a 0,00382 | -0,17 % | 0,58 |
| Lognormal con interacciones de educación menos lognormal | 0,00066 | -0,00111 a 0,00243 | -0,07 % | 0,57 |
| Historia previa menos estado actual (gamma, 2.730 personas) | 0,00343 | -0,00504 a 0,01191 | | |

- Lectura de la contribución de cada pieza: lo que separa a lognormal de A (≈0,009) probablemente viene de los gramos previos (`lg0`) y de compartir información entre celdas, pero ningún contraste lo aísla (la edad usa los mismos 4 grupos en ambos); la forma de la distribución separa lognormal de gamma (≈0,012, concentrado en las colas); educación, sus interacciones y la historia previa no aportan nada detectable. No hay contrastes entre lognormal, ordinal simple y multinomial, ni con JRT.

### 3.2 Calibración por categoría fuera de muestra
Fuente: tabla "Held-out observed and predicted shares" del `.html` (celda `eps-calibration`).

| Modelo | No consume | C1 | C2 | C3 | C4 | C3+C4 |
|---|---|---|---|---|---|---|
| Observado | 60,64 % | 36,05 % | 1,87 % | 1,05 % | 0,39 % | 1,44 % |
| A | 60,34 % | 36,29 % | 1,89 % | 1,07 % | 0,40 % | 1,47 % |
| Ordinal dos partes | 60,62 % | 36,07 % | 1,87 % | 1,05 % | 0,39 % | 1,44 % |
| Lognormal | 60,62 % | 36,50 % | 1,79 % | 0,81 % | 0,28 % | 1,09 % |
| Gamma | 60,62 % | 36,29 % | 2,28 % | 0,72 % | 0,10 % | 0,82 % |

- Error relativo: A +1 % a +3 % en C2 a C4; ordinal en dos partes 0 %; lognormal -4 %, -23 % y -28 % en C2, C3 y C4; gamma +22 %, -31 % y -74 %. Es un total por categoría (todas las filas de origen juntas) y de un paso. Ordinal simple y multinomial no están en la tabla.

### 3.3 Repeticiones de la CV
Fuente: `CV_repeated_scores.csv` (cálculos de Claude sobre ese archivo).
- Desviación estándar del log loss entre las 3 repeticiones: ordinal simple 0,00011; A 0,00179; lognormal 0,00226; gamma 0,00284; JRT_reference 0,00452.
- La repetición 3 empeoró a casi todos los modelos (de +0,003 a +0,005 respecto del promedio de las repeticiones 1 y 2). El ordinal simple no se movió (+0,0002) y JRT_reference mejoró 0,0078.
- Lognormal menos gamma por repetición: -0,01228, -0,01133 y -0,01273 (desviación 0,00071, frente a un SE de diseño de 0,00355). JRT_reference menos gamma: +0,0084, +0,0089 y -0,0040; JRT pasa de último a octavo de doce.
- El jackknife y el bootstrap no miden esta variación (2.2).
- Costo: la celda `eps-model-validation` (15 particiones) tardó 1,60 min; 250 particiones (5×50) serían ≈27 min si escala lineal. La celda `eps-design-inference` (jackknife y bootstrap) tardó 18,44 min.

### 3.4 Predictores
Fuentes: celda 8 del notebook, `ep_formula`, `ep_Afit`, `ep_ipw_fit`.

| Modelo | Predictores |
|---|---|
| Gamma, lognormal, multinomial, ordinales | Estado de origen, sexo × grupo de edad (18 a 29, 30 a 44, 45 a 59, 60 a 65), período, log de g/día previos (`lg0`, 0 si no bebía), educación (`edu_num` 0 a 2 y `edu_missing`). Variantes sin educación y con interacciones de educación |
| JRT_reference | `state0 * age_group + state0 * sex + sex * age_group + period`; sin educación ni gramos previos |
| A | Sin regresores: tabla origen × sexo × grupo de edad × período con encogimiento (2.4); `A_education` agrega educación |
| IPW (3 logísticas por período) | Clasificación en el origen: sexo, grupo de edad, educación; vínculo y seguimiento: además el estado de origen |

No se usan región, zona, ocupación, ingreso ni estado civil.

### 3.5 Transporte entre períodos
Fuentes: `transport_summary.csv`, `transport_support.csv`, `ep_transport`.
- Se entrena con las transiciones de un intervalo y se prueba con las del otro, con pliegues por persona. Forward: entrena VI→VII y predice VII→VIII (n = 2.943 de 3.393; se excluyen 450 pares: 412 con origen FD, porque VI→VII no tiene FD, y 38 por el soporte común de edad). Retro: entrena VII→VIII y predice VI→VII (n = 3.908 de 4.702; se excluyen 794 pares por el soporte de edad). k = 100 fijo para A.

| Dirección | A | Gamma | JRT | Lognormal | Multinomial | Ordinal simple | Ordinal dos partes |
|---|---|---|---|---|---|---|---|
| Forward | 0,6702 | 0,6718 | 0,6701 | 0,6613 | 0,6686 | 0,6637 | 0,6929 |
| Retro | 0,7918 | 0,8455 | 0,7874 | 0,7937 | 0,7743 | 0,7887 | 0,8233 |

- Lognormal gana en forward y multinomial en retro; gamma queda penúltimo y último. En retro gamma tiene el peor log loss con un Brier dentro del rango del resto (0,4454 a 0,4485), otra señal de error en las colas. La tabla no trae intervalos.

### 3.6 Rank matching
Fuente: `rank_matching_vs_panel.csv`. Probabilidades entre rondas (3,671 y 4,03 años), no anualizadas.

| Período | C1 observada | C1 rank matching | NC observada | NC rank matching |
|---|---|---|---|---|
| VI→VII | 58,3 % | 94,0 % | 73,4 % | 96,1 % |
| VII→VIII | 52,3 % | 77,4 % | 82,1 % | 100 % |

- La ENPG es bienal y el `polr` de JRT es t→t+2 anualizado con α = 0,5 (`claude/plan_trabajo_post_reunion_ACC_2026-09-17.md`); las cifras a 2 años y a 3,7 a 4,0 años no se trasladan tal cual. El rank matching da la cota inferior de movilidad y ELSOC la superior (`claude/elsoc_auditoria_alcohol_2026-10.md`).

### 3.7 HED: redacción por ola en la ENPG y diferencia con la EPS
Fuentes: cuestionarios en `micsim/_enpg/docs/` (texto extraído en `_enpg/notes/codex_temp_audit_enpg/`), inventario `_enpg/notes/enpg_variable_audit.csv`, cuestionario oficial 2018 (SENDA, investigación web), `hed_diagnostic.md` (auditoría del 9-oct). La serie de SENDA viene de `hed_diagnostic.md` y del informe de prensa 2024.

| Ola | Ítem en la base | Redacción y cambios | Fuente de la verificación | SENDA, embriaguez (% de bebedores del mes) |
|---|---|---|---|---|
| 2008 | No existe | Solo cantidad en un día típico (AUDIT, `q19`) | Inventario de variables | No aplica |
| 2010 | No existe | Solo cantidad en un día típico (AUDIT, `p020`) | Inventario de variables | No aplica |
| 2012 | `p16` (P16) | "Pensando en los últimos 30 días y tomando en cuenta todos los tipos de bebidas alcohólicas, Si es hombre: ¿Cuántas veces tomó 5 o más tragos en una sola ocasión? (Mostrar tarjeta 4.1) Si es mujer: ¿Cuántas veces tomó 4 o más tragos en una sola ocasión? (Mostrar tarjeta 4.2) Por 'ocasión' nos referimos a un mismo momento, por ejemplo en un período de dos horas" | Cuestionario 2012 | 52,1 |
| 2014 | `oh7` (OH_7) | Igual a 2012, con tarjetas 5.1 y 5.2 | Cuestionario 2014 | 43,7 |
| 2016 | `oh_7a`, `oh_7b` | Igual, más "No considere Fiestas Patrias" | Cuestionario 2016 | 51,1 |
| 2018 | `OH_7H`, `OH_7M` | Igual, con Fiestas Patrias excluidas; tarjeta de mujeres con 1.300 ml de cerveza y 550 ml de vino; códigos 888/999 | Cuestionario oficial SENDA (web) | 56,3 |
| 2020 | `OH_7` | Según la auditoría: excluye Año Nuevo si la entrevista fue en enero; tarjeta de mujeres con volúmenes de hombres | `hed_diagnostic.md` (cuestionario no disponible localmente) | 50,2 |
| 2022 | `OH_7` | "Pensando en los últimos 30 días: ... ¿Cuántas veces tomó 5 o más tragos en una sola ocasión? entendiendo que 5 tragos son: 5 latas de cerveza (1.600 ml aprox.), 5 copas de vino (700 ml aprox.), 5 combinados suaves o 3 combinados fuertes (200 ml de licor aprox.)"; para mujeres "4 o más", pero con los mismos 1.600 ml y 700 ml | Cuestionario 2022 | 50,7 |
| 2024 | `OH_7` | Igual a 2022, con Fiestas Patrias y Año Nuevo excluidos según la fecha | Cuestionario 2024 | 47,2 |

- Respuesta: número de veces (conteo). Se pregunta a quienes bebieron en los últimos 30 días.
- No confundir con el ítem 3 del AUDIT, "¿Qué tan seguido toma usted 6 o más tragos en una sola ocasión?" (`OH_10` en 2022 y 2024).
- En el código del proyecto, HED = conteo > 0 a partir de `db` (`ENPG_BINGE`), que coincide con el ítem crudo en el 100 % de los casos. Con los "no sabe" excluidos, el HED queda 2,2 a 5,9 puntos sobre la serie de SENDA; contándolos como "no" se reproduce la serie con diferencias de 0,2 a 0,6 puntos (`hed_diagnostic.md`).
- EPS: no hay pregunta de HED. La señal de `ep_qsignal` vale 1 si alguna bebida declarada en F13 tiene cantidad típica (F15) ≥5 en hombres o ≥4 en mujeres. Por celda, en proporciones ponderadas: C1 19,7 % en hombres y 10,6 % en mujeres; C2 59,8 % y 62,0 %; C3 90,3 % y 67,6 %; C4 100 % en los 25 casos. Promediando las celdas según su n, ≈20 % de los bebedores de destino. El coeficiente de la señal previa en `ep_hed` es 0,995 (SE 0,168); el de C4 (17,1) refleja separación casi perfecta y su SE no es creíble.
- La ENPG mide al menos una ocasión en 30 días; la EPS mide la cantidad típica. Un hombre con 5 tragos un día a la semana queda en C1 (≈8,6 g/día) con señal positiva; uno que bebe 2 tragos casi siempre y 6 en un cumpleaños tiene HED en la ENPG y señal 0 en la EPS.

### 3.8 Peso efectivo
Fuentes: `ipw_audit.csv`, `singleton_convention_sensitivity.csv`.
- Por dispersión de pesos (Kish): VI→VII 3.154 de 4.702 pares (deff 1,49); VII→VIII 1.937,5 de 3.393 (1,75); conjunto ≈5.060 de 8.095 (1,60).
- Por diseño y pesos, solo para la prevalencia de consumo actual en el destino (39,3 %): SE 0,010887 con "adjust" y 0,009967 con "certainty"; n_eff ≈2.013 (deff 4,02) y ≈2.402 (3,37). Juntos, los conglomerados y las personas repetidas multiplican el deff de pesos por ≈2,5 (con "adjust") o ≈2,1 (con "certainty"). Ese SE trata el IPW como fijo. No hay deff por celda.

### 3.9 Diseño e IPW
- Peso oficial (longitudinal en VI→VII; transversal de VII en VII→VIII) × IPW de tres etapas (clasificación en el origen, vínculo, seguimiento), con piso 0,02 en la probabilidad y recorte en p1 y p99; cada período suma su número de pares.
- El IPW se reestima dentro de cada réplica del jackknife (111) y del bootstrap (1.000). El k de encogimiento y la familia del modelo quedan fijos en las réplicas, así que los intervalos son condicionales a esas elecciones.
- Diseño oficial (informe técnico de la VIII ronda, `_eps/notes/34_Informe Técnico EPS VIII Ronda.txt`, y metodológico de la VII, `16_EPS - Informe Metodologico-Muestreo, Atrición, Factores, Errores Muestrales.txt`): muestreo por conglomerados en dos etapas, sin reemplazo y con probabilidades desiguales. En la primera etapa se eligen comunas: las autorrepresentadas entran con probabilidad 1; con el resto se forman estratos de unos 100.000 habitantes y se elige una comuna por estrato con probabilidad proporcional al tamaño. En la segunda etapa se eligen personas según afiliación, sexo y edad. Como cada estrato aporta una sola comuna, el informe dice que cluster y estrato coinciden; de ahí los 32 estratos con una sola UPM. Por diferencia, el estrato restante agrupa 79 UPM, probablemente las comunas autorrepresentadas (no verificado).
- Pesos oficiales: factor base, ajuste por atrición y no respuesta (propensión agrupada en ventiles) y post-estratificación. En la VIII se agregaron "nacimientos": personas que cumplieron 18 años entre julio de 2015 y junio de 2023.
- Varianza oficial: linealización de Taylor que solo usa la primera etapa (el informe dice que "el sub-muestreo al interior de cada cluster pasa a ser irrelevante"; es el estimador de conglomerado último). El informe da como ejemplo `svyset cluster_ID [pweight=factor_XS], strata(strata_ID), singleunit(certainty)` y dice que también sirven bootstrap, jackknife o BRR. El notebook hace lo mismo con réplicas JKn, con `adjust` como opción principal (más conservadora) y `certainty` como sensibilidad: con `certainty` el error estándar de la prevalencia de consumo es 8 % menor.
- Por qué no entran las probabilidades por etapa, la FPC ni la incertidumbre de los pesos oficiales: la guía oficial no las usa y el notebook solo recibe los identificadores publicados de UPM y estrato y el peso final. Para las comunas no autorrepresentadas la FPC es despreciable (una comuna de varias por estrato). Para las autorrepresentadas lo correcto sería tratarlas como estratos con unidades de segunda etapa como UPM, algo que los identificadores publicados no permiten; el sentido de ese error no está claro. Tampoco está claro el sentido del efecto de tratar los pesos oficiales como fijos (con pesos estimados o calibrados suele ser conservador). Ninguno de estos efectos está medido.
- Para la ENPG (objetivos de calibración), el diseño cambia por ola: estratos = comuna en 2012 a 2022, `ESTRATO` en 2024, PSU reconstruida en 2016, 2020 sin conglomerado (`expand_pif_cambios_hallazgos_2026-09-21.md`, C1).

### 3.10 Capa anual
Fuentes: `annual_pooled_matrices_design_CI.csv` (carpeta local `__andres_control/eps_markov_outputs/`; no estaba en la copia revisada antes), `annual_generator_sensitivity.csv`, tabla de permanencias del `.html` (celda 16), `ep_annual`.
- Generador continuo Q con P(Δ) = exp(QΔ), uno solo para ambos períodos, N0 y FD colapsados a NC en los destinos, penalización ridge 5e-5. Se ajusta para A, gamma y lognormal, con intervalos del jackknife (111 réplicas válidas en todos).

| Estado | A | Gamma | Lognormal |
|---|---|---|---|
| N0 | 0,913 (0,903 a 0,922) | 0,911 (0,901 a 0,920) | 0,911 (0,901 a 0,921) |
| FD | 0,871 (0,818 a 0,910) | 0,871 (0,829 a 0,904) | 0,872 (0,830 a 0,905) |
| C1 | 0,818 (0,789 a 0,844) | 0,812 (0,785 a 0,836) | 0,815 (0,790 a 0,837) |
| C2 | 0,535 (0,367 a 0,696) | 0,517 (0,432 a 0,601) | 0,481 (0,389 a 0,574) |
| C3 | 0,443 (0,245 a 0,661) | 0,422 (0,226 a 0,646) | 0,434 (0,326 a 0,547) |
| C4 | 0,403 (0,085 a 0,830) | 0,103 (0 a 1) | 0,181 (0 a 0,998) |

- RMSE de reconstrucción de gamma ≈0,063 (0,0628, 0,0633 y 0,0641 con penalización 1e-5, 5e-5 y 2e-4). Con la penalización usada, distintos reinicios cambian una probabilidad anual de gamma hasta 10,5 puntos; el máximo del archivo es 33,8 (penalización 1e-5). Esa sensibilidad solo existe para gamma. El notebook muestra solo la tabla de gamma y dice que todavía no es un motor anual estable.

### 3.11 Bootstrap de 500 frente a 1.000 réplicas
Fuente: `bootstrap_stability.csv`.

| Réplicas | Razón mediana del SE respecto de 1.000 | Diferencia relativa absoluta, percentil 90 |
|---|---|---|
| 100 | 0,984 | 14,8 % |
| 250 | 0,986 | 8,4 % |
| 500 | 0,9989 | 6,0 % |
| 1.000 | 1 | 0 |

- En simple: el bootstrap rehace el análisis muchas veces para medir cuánto se movería el resultado con otra muestra. La tabla pregunta cuántas veces basta. Con 500 el error estándar típico ya es el 99,9 % del de 1.000 y en el 90 % de las celdas difiere menos de 6 %. Implicancia: 1.000 sobra y 500 sirve para pruebas. No dice que el error estándar sea el correcto: las 500 están dentro de las 1.000. La inferencia principal es el jackknife.

### 3.12 Variables comunes a ENPG y EPS
Fuentes: `_enpg/notes/enpg_variable_audit.csv` (inventario 2008 a 2024), cuestionarios EPS de las rondas VI (2015), VII presencial y VIII (`_eps/notes/8_`, `22_` y `28_`), investigación web. Los ítems de la EPS de esta tabla están en las tres rondas.

| Variable | ENPG | EPS 2015 | Nivel de medición | Armonización | Advertencia | ¿Predictor y en población sintética? |
|---|---|---|---|---|---|---|
| Sexo | Todas las olas (`sexo`, `S01`, `SEXO`) | Sí | Nominal | Directa | | Sí |
| Edad | Todas (12 a 65 años) | Sí (18+) | Discreta | Tramos | Rangos distintos | Sí |
| Educación | Nivel más alto alcanzado: `q279` 2008, `p184_1` 2012, `dp9_1` 2014, `dp_9_a` 2016, `DP_12` 2022 y 2024 | A.12.n nivel más alto alcanzado (13 categorías) y A.12.e completitud | Ordinal | 3 niveles (básica o menos, media, superior) | 2010 y 2018 a 2020 no identificados en el inventario | Sí (ya está en la micsim) |
| Región | Todas | Sí | Nominal | 16 regiones o macrozonas | La ENPG 2024 cubre el área urbana de 109 comunas de 30.000 habitantes o más (informe 2024) | Sí, mejor como macrozona |
| Zona urbana o rural | No hay variable; muestra urbana | Hay población rural | | Restringir la EPS a zonas comparables, al menos como sensibilidad | Sesgo de cobertura | Solo como restricción |
| Estado civil | `DP_2` 2014 a 2024 (`p282` 2010; en 2012 solo "¿tiene pareja?") | I.1 estado civil actual | Nominal | Soltero, casado o conviviente, separado o viudo | 2012 distinto | Posible |
| Previsión de salud | `p284` 2010, `p181` 2012, `dp6` 2014, `dp_6` 2016, `DP_9` 2018 a 2024 | F.1 "¿A qué sistema previsional de salud pertenece Ud.?" | Nominal | Fonasa A y B, Fonasa C y D, Isapre, otro o ninguno | | Posible, como aproximación al nivel socioeconómico |
| Actividad laboral | Módulo CO ("¿trabajó la semana pasada?") 2012 a 2024 | Módulo de empleo | Nominal | Ocupado, desocupado, inactivo | No verificado en la EPS | Posible |
| Ingreso | Formatos distintos por ola | Módulo C | Continua o tramos | Costosa | | No por ahora |
| Pueblo originario | 2008 a 2024 | A.10.b "¿Pertenece o es descendiente de alguno de ellos?" (9 pueblos) | Nominal | Pertenece o no | | Posible |
| Tabaco | Última vez que fumó y días que fumó en los últimos 30 días, todas las olas | F.12.a "¿Usted fuma actualmente?" y F.12.b cigarrillos al mes | Nominal y discreta | Fuma actualmente sí o no | Períodos distintos (30 días frente a "actualmente") | Posible y útil: el tabaco se asocia con el consumo de alcohol |
| Autopercepción de salud | "¿Cómo calificaría su salud?" en 2008, 2012 a 2016 y 2024 | A.10 "Diría que su salud es:" (de excelente a muy mala, 6 categorías) | Ordinal | Buena o mejor frente a regular o peor | Escalas distintas | Posible |
| Días de consumo | `OH_5` (1 a 30 días en el último mes), todas las olas | F.14 "En el último mes, ¿cuántos días a la semana consumió alguna bebida alcohólica?" (0 = menos de 1; 1 a 7), por bebida | Discreta | Días al mes ÷ 4,3 frente a días a la semana | La ENPG pregunta el total; la EPS, por bebida | Define el estado (g/día) |
| Cantidad típica | AUDIT "¿Cuántos tragos suele tomar usted en un día típico de consumo?" (0 a 2, 3 a 4, 5 a 6, 7 a 9, 10 o más), todas las olas | F.15 "De las veces que tomó bebidas alcohólicas, ¿cuántos vasos o copas tomó aproximadamente?", por bebida | Ordinal frente a discreta | Tramos del AUDIT | La EPS no define el volumen del vaso | Define el estado; permite una señal comparable en hombres (≥5) |
| HED 30 días | `p16` / `OH_7`, 2012 a 2024 | No existe | Discreta (conteo) | | | Objetivo de calibración |
| Pesos y diseño | `exp`, `factor_ajustado_com`, `PONDERADOR`, `Fexp`, `FACT_PERS_COMUNA`, `FACTOR_EXPANSION`; `UPM` 2022 y 2024; `ESTRATO` 2024 | Factores de expansión de la EPS | | | Diseño de la ENPG heterogéneo por ola | |

- F.13 de la EPS 2015: "¿Consume Usted bebidas alcohólicas como….?" (cerveza; vino; pisco u otro licor), sin período de referencia.
- Conjunto mínimo defendible para predictores comunes: sexo, edad, educación (3 niveles) y estado de origen. Es el mismo que usa SIMAH (más raza/etnia).

### 3.13 Gramos por trago
Fuente: tabla "Conversion sensitivity, refitted models" del `.html` (celda 18).

| g por trago | Modelo | Bebe en t1 | Escala desde C1 | C3+C4 en t1 |
|---|---|---|---|---|
| 12 | Gamma | 39,32 % | 5,49 % | 0,81 % |
| 12 | Lognormal | 39,32 % | 4,98 % | 1,09 % |
| 15,7 | Gamma | 39,31 % | 8,93 % | 1,80 % |
| 15,7 | Lognormal | 39,31 % | 7,28 % | 1,88 % |

- Tarjeta 6 de la ENPG 2018: 1 trago = 333 cc de cerveza, 140 cc de vino o 40 cc de licor; el cuestionario no da gramos (≈11 a 14 g según la graduación, cálculo de la investigación). La EPS pregunta "vasos o copas" sin volumen.

### 3.14 Referencias SIMAH y NESARC
- Kilian et al. 2025: "changes in alcohol use categories are informed by ordinal logistic regression modelling of pseudo-longitudinal BRFSS data (2000–10)". Categorías: abstemios (12 meses), 1 (hasta 20 g mujeres y 40 g hombres), 2 (20 a 40 y 40 a 60), 3 (más de 40 y 60). Calibración bayesiana por history matching (implausibilidad media < 3) contra BRFSS 2011 a 2015; validación con BRFSS 2016 a 2019; 60 combinaciones de parámetros × 10 semillas = 600 corridas. Código: GitHub vía DOI 10.5281/zenodo.15641639. Las transiciones de educación sí son Markov (PSID 2005 a 2019).
- Puka et al. (Addiction, NESARC I y II, n = 34.165): Markov multiestado homogéneo en tiempo continuo (msm), transiciones instantáneas solo entre estados vecinos. Permanencia anual: no bebedores 90,1 % (89,7 a 90,5), I 90,2 % (89,9 a 90,5), II 31,8 % (29,7 a 33,9), III 52,2 % (46,0 a 58,5). Aplicadas 11 veces sobre NESARC I, predijeron las proporciones de NESARC III con diferencias de 1 % o menos en el modelo de cantidad (2,2 % o menos en el de patrón de consumo).

### 3.15 Cuestionarios EPS por ronda: módulo de alcohol
Fuentes: `_eps/notes/8_Cuestionario EPS 2015.txt` (VI); `22_EPS PRESENCIAL VIVOS.txt`, `19_EPS CONTINUIDAD VIVOS.txt` y `24_EPS REENTREVISTA VIVOS.txt` (VII); `28_Cuadernillo EPS VIII Ronda - Personas Vivas.txt` y `30_Tarjetero VIII Ronda EPS.txt` (VIII).

| Ronda | F.13 | F.14 | F.15 | Códigos de no respuesta | Notas |
|---|---|---|---|---|---|
| VI (2015) | "¿Consume Usted bebidas alcohólicas como….?", leyendo las alternativas cerveza; vino; pisco u otro licor | "En el último mes, ¿cuántos días a la semana consumió alguna bebida alcohólica?"; si no alcanza a un día, "anote 0" (0 = menos de 1 día; 1 a 7 días) | "De las veces que tomó bebidas alcohólicas, ¿cuántos vasos o copas tomó aproximadamente?" | F.13: 8; F.14: 8 y 9; F.15: 8888 y 9999 | |
| VII presencial (2019 a 2020) | Igual, con "mostrar tarjeta 50" | Igual, pero "anote menos de 1 día" | Igual | Igual que en VI | El contenido de la tarjeta 50 no está en la carpeta |
| VII continuidad y re-entrevista | No existe | No existe | No existe | | Solo FC101: en el último mes, "consumiendo más bebidas alcohólicas" (menos de lo habitual, igual, más) |
| VIII | Igual, sin tarjeta | Igual, "anote menos de 1 día" | Igual | F.13: 88; F.14: 88 y 99; F.15: 8888 y 9999 | El tarjetero de la VIII no trae tarjetas de alcohol |

- Consecuencias: el módulo es comparable entre rondas; hay que recodificar los códigos de no respuesta de la VIII (88 y 99); la VII solo aporta alcohol en la muestra presencial (7.800 personas en la armonización, frente a 16.906 en la VI y 15.788 en la VIII); F.13 no tiene período de referencia y F.15 no define el volumen del vaso.
- Otros módulos presentes en las tres rondas: salud autopercibida (A.10), pueblos indígenas (A.10.b), nivel educacional (A.12) y su completitud (A.12.e), sistema previsional de salud (F.1), tabaco (F.12.a y F.12.b) y estado civil (I.1).

## 4. Métricas para agregar en la v2

| Métrica | Qué responde | Cómo leerla |
|---|---|---|
| Escalera de modelos: nulo → solo origen (6 estados) → origen + sexo × edad (A) → + educación → + gramos previos (o A con C1 partido por gramos) → paramétricos | Qué aporta cada pieza | Contrastes pareados como los actuales; diferencias < 0,002 equivalen a nada |
| Calibración por origen × sexo × grupo de edad, fuera de muestra | Si cada fila de la matriz reproduce lo observado | Error absoluto y relativo por celda; pesar más C3 y C4 |
| Calibración de varios pasos: proyectar desde VI con la matriz anual hasta VIII; y desde la ENPG 2016 hasta 2018 a 2024 | Si el motor reproduce prevalencias después de 4 a 8 años | Dentro del IC 95 % de la encuesta |
| RPS (ranked probability score) | Versión ordinal del Brier: confundir C1 con C4 cuesta más que con C2 | Menor es mejor |
| Descomposición del Brier (fiabilidad, resolución, incertidumbre) | Si un modelo pierde por calibración o por discriminación | |
| Log loss por estado de origen (N0, FD, C1, C2 o más) | Dónde difieren los modelos | |
| Contrastes pareados con JRT_reference | Si el motor EPS supera a JRT | |
| Métrica de decisión: prevalencia de C3+C4 a 10 años y muertes atribuibles con cada modelo | Si la elección del modelo cambia la conclusión | Con el criterio de equivalencia de 2.5 |

## 5. Sugerencias de Claude (no son del usuario; a confirmar o descartar)
1. Contrastes pareados de JRT_reference contra los demás y más repeticiones solo para ese modelo (5×50 para todos costaría ≈27 min).
2. Reportar deff y n_eff además de Kish, e intervalos en la tabla de transporte.
3. Revisar el argumento "cambia las probabilidades 0,35 puntos en promedio; se retiene gamma" (celda 1): ese promedio diluye las colas, y gamma subestima C3+C4 en 43 %. No usar gamma como motor principal sin calibración.
4. Probar una A con C1 partido por gramos previos (2 o 3 tramos). Sigue siendo una tabla, sin linealidad, y recoge parte de lo que lognormal gana con `lg0`.
5. Calcular en la ENPG la misma señal de cantidad típica que en la EPS (hombres, día típico ≥5 tragos según el ítem AUDIT) para separar "constructo distinto" de "población distinta".
6. HED: tomar el nivel de la ENPG y usar la EPS solo para la persistencia (opcional y compatible con O7).
7. Fusionar C3+C4 para la capa anual, al menos como sensibilidad.
8. Calibrar a la ENPG con raking como paso explícito, con holdout 2024 (como en el plan del 17-sep).
9. Fijar los gramos por trago con fuente y mostrar siempre la sensibilidad 12 frente a 15,7 g.
10. Mostrar en la v2 la capa anual de A (hoy solo se guarda en el CSV) y correr para A la misma sensibilidad a reinicios y penalización que se corrió para gamma.

## 6. No verificado o pendiente
- Redacción del HED en 2020: el cuestionario no está en la carpeta; la tabla usa la auditoría del proyecto.
- Educación en la ENPG 2010 y 2018 a 2020: no identificada en el inventario (2018 tiene `T_DP_12_1`, de no jefes de hogar; revisar).
- El contenido de la tarjeta 50 de la VII presencial (no está en la carpeta) y la codificación de las comunas autorrepresentadas en `strata_ID` (inferido: un estrato con 79 UPM).
- Actividad laboral e ingreso: no armonizados.
- Cálculos de Claude: probabilidad típica, mejora sobre el nulo, errores relativos de calibración, ejemplos de permanencia, costo de 5×50 y n_eff.
- El criterio de equivalencia de 2.5 es una propuesta.
- La sensibilidad de la capa anual a reinicios y penalización no está calculada para A ni para lognormal.
- Los conteos de origen (C2 141, C3 69, C4 29 pares) vienen de `eps_markov_review.md`; la tabla por período no está en las salidas.
- Nada se ejecutó en esta sesión; nada de esto valida el pipeline completo con datos reales.

## Fuentes
- Cuestionarios ENPG locales: `micsim/_enpg/docs/` (2012, 2014, 2016, 2022, 2024); texto extraído en `_enpg/notes/codex_temp_audit_enpg/`; inventario `_enpg/notes/enpg_variable_audit.csv`.
- Informe ENPG 2024 (cobertura y serie de prevalencia del mes): `micsim/_enpg/docs/2024/enpg2024.pdf`.
- Capa anual de A, gamma y lognormal con intervalos: `__andres_control/eps_markov_outputs/annual_pooled_matrices_design_CI.csv`.
- Auditoría de HED: `__andres_control/auditoria_microsim_2026-10-09/hed_diagnostic.md`.
- Cuestionarios EPS: `_eps/notes/8_Cuestionario EPS 2015.txt` (VI), `22_EPS PRESENCIAL VIVOS.txt`, `19_EPS CONTINUIDAD VIVOS.txt` y `24_EPS REENTREVISTA VIVOS.txt` (VII), `28_Cuadernillo EPS VIII Ronda - Personas Vivas.txt` y `30_Tarjetero VIII Ronda EPS.txt` (VIII).
- Diseño y pesos EPS: `_eps/notes/34_Informe Técnico EPS VIII Ronda.txt`, `16_EPS - Informe Metodologico-Muestreo, Atrición, Factores, Errores Muestrales.txt` y `11_Informe Metodologico FactoresExpansión EPS 2015.txt`.
- Cuestionario ENPG 2018 (SENDA): https://www.senda.gob.cl/wp-content/uploads/2019/12/Cuestionario-ENPG-2018.pdf
- Informe de prensa ENPG 2024: https://psiconecta.org/wp-content/uploads/2025/12/ENPG-2024-Prensa.pdf
- Kilian et al. 2025, Lancet Public Health: https://eprints.whiterose.ac.uk/id/eprint/231116/1/1-s2.0-S2468266725001653-main.pdf
- Puka et al., Addiction (NESARC): https://onlinelibrary.wiley.com/doi/10.1111/add.16024
- Protocolo SIMAH: https://eprints.whiterose.ac.uk/id/eprint/198292/1/SIMAH_protocol_technical%20review.pdf
- Eddy et al. 2012, ISPOR-SMDM, transparencia y validación: https://doi.org/10.1177/0272989x12458977
- Israel, Rosenthal y Wei 2001, generadores de matrices de transición: https://onlinelibrary.wiley.com/doi/abs/10.1111/1467-9965.00114
- Estimación de transiciones con datos agregados: https://www.researchgate.net/publication/229886176_Least-squares_estimation_of_transition_probabilities_from_aggregate_data
