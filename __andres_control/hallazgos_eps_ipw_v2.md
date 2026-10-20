# EPS IPW v2: el modelo de desgaste con los predictores acordados y qué cambia en las matrices

[Cuaderno ejecutado](eps_markov_transitions_v2_EN.ipynb) · [HTML autocontenido](../eps_markov_transitions_v2_EN.html) · [Salidas agregadas](eps_markov_outputs_v2/) · [Plan y contrato](eps_ipw_v2_plan_2026-10-19.md) · [Página didáctica](https://claude.ai/artifact/TzobL2tzGrPhahuGQXZB5M) (copia local: [eps_ipw_v2_explicado.html](eps_ipw_v2_explicado.html))

Fecha: 2026-10-19. Datos reales: EPS VI (2015), VII presencial (2020) y VIII (2023), leídas de los paquetes cifrados. Una ejecución en kernel nuevo fijado a los núcleos E; las celdas de la versión 1 corren sin cambios dentro del cuaderno y sus 42 tablas CSV son idénticas byte a byte a las de `eps_markov_outputs/`; 60 comprobaciones registradas (48 de la versión 1 y 12 nuevas), todas superadas. Tiempo total 26,4 minutos, de los que 4,5 son de la versión 2. El cuaderno original, `eps_markov_core.R` y `eps_markov_outputs/` quedan intactos.

**Decisión principal:** la elección del modelo de desgaste no mueve las matrices de transición de la EPS. Con los predictores acordados y un SuperLearner elegido antes de las réplicas, el cambio absoluto medio por celda frente al peso oficial es de 0,004 y el mayor cambio en una celda con soporte es de 0,022 (hombres de 30 a 44, C1→C1, 302 pares), muy por dentro de los intervalos de diseño. Los pesos sí corrigen el desequilibrio que el peso oficial dejaba en VII→VIII (sexo y gramos previos), pero no pueden equilibrar las filas C2 y C3+ de ese intervalo, que tienen 63 y 47 personas seguidas. El motor puede seguir con la IPW v1 o adoptar la v2 sin cambios materiales; la discusión relevante es la calibración con la ENPG.

## Fallecidos e impedidos: documentado antes de estimar

En la versión 1, VI→VII se restringe a los tenedores del peso longitudinal oficial, que solo existe para los reentrevistados presenciales en VII: fallecidos, impedidos y seguimientos telefónicos nunca entran, el peso oficial trae el ajuste por desgaste y la IPW adicional corrige solo clasificación faltante y enlaces inválidos. En VII→VIII la versión 1 quita a los fallecidos del archivo de VIII pero deja a los impedidos, que cuentan como desgaste (faltantes al azar dadas las covariables).

La versión 2 trata a fallecidos e impedidos como **salidas competitivas**, no como desgaste: dejan el conjunto de riesgo y el modelo de pesos en ambos intervalos y se reportan solo como conteos. Los seguidos por teléfono en VII (sin módulo de alcohol) son resultado faltante, no salida. La mortalidad pertenece al módulo de mortalidad de la microsimulación.

| Archivo | Personas | Respondientes de origen 18–65 | En el conjunto de riesgo v1 | En v2 |
|---|---:|---:|---:|---:|
| Fallecidos a VII (MODULO_M) | 516 | 70 | 0 | 0 |
| Impedidos a VII (MODULO_P) | 339 | 75 | 0 | 0 |
| Fallecidos a VIII (MODULO_M) | 882 | 60 | 0 | 0 |
| Impedidos a VIII (MODULO_P) | 432 | 32 | 32 | 0 |
| Solo teléfono en VII | 5.031 | 3.441 | 0 | 0 |

Tabla de desgaste por intervalo (estado de origen C3 y C4 fusionados en el modelo de desgaste):

| Intervalo | En riesgo | Fallecidos | Impedidos | Con módulo | Perdidos | Seguidos entre sobrevivientes |
|---|---:|---:|---:|---:|---:|---:|
| VI→VII | 5.252 | 0 | 0 | 4.835 | 417 | 92,1 % (N0 94,6; C1 88,5; C2 91,8; C3+ 85,0) |
| VII→VIII | 6.107 | 60 | 32 | 3.582 | 2.433 | 59,6 % (N0 62,8; FD 66,0; C1 55,3; C2 51,2; C3+ 51,1) |

En VI→VII fallecidos, impedidos y teléfono son cero por construcción (la base son los tenedores del peso de panel). Una fila «sin clasificar» (153 y 354 personas sin estado de origen) entra en los totales pero no en el modelo de respuesta. El conjunto de riesgo v2 con origen clasificado tiene 5.099 y 5.667 personas, de las que 4.702 y 3.393 fueron seguidas con el módulo.

## Predictores y modelo de respuesta

Predictores medidos en la ola de origen, con sus nombres en los archivos públicos: estado de origen (f13/f14/f15 armonizados), log(g/día + 1), sexo × edad (a8, a9), educación completada (a12n/a12e/a12d; a12_n/a12_e/a12_d) más indicador de faltante, tenencia de la vivienda (d7: propia 1–3), pareja (i1 ∈ {1, 2, 9} en VI; {1, 2, 4} en VII y VIII), trabajó la semana pasada (VI: episodio en curso de `MODULOB_historia_laboral` con b2 = 1; VII: b2a_SO = 1; VIII: b2a_so = 1), fuma (f12a / f12_a = 1), PHQ-9 ≥ 10 (f69_1…f69_9, suma de código − 1), salud mala o regular (a10 ∈ 4–6). **Macrozona y región quedan fuera**: los archivos públicos solo traen el lugar de nacimiento (a6a) y los identificadores anónimos de estrato y conglomerado. Los códigos de no respuesta pasan a faltante y cada binaria lleva un nivel «sin dato», así que no se pierde ninguna fila.

Logística ponderada por el diseño (conglomerados y estratos publicados, peso de origen) de «módulo de alcohol observado en el destino», por intervalo. Odds ratios con intervalos de diseño del 95 %:

- **VI→VII** (5.099 personas, 4.702 seguidas): gramos previos 0,77 [0,64; 0,94] por unidad de log(g/día + 1); educación sin dato 0,20 [0,07; 0,63] (22 personas); vivienda no propia 1,31 [0,98; 1,75]; no fuma 1,29 [0,95; 1,77]; el resto cruza 1. El nivel «pareja sin dato» (4 personas, las 4 seguidas) separa perfectamente (OR de seis cifras): no aporta información y no afecta a los pesos de la versión 2.
- **VII→VIII** (5.667 personas, 3.393 seguidas): origen FD 1,48 [1,15; 1,91] frente a N0; gramos previos 0,85 [0,74; 0,97]; mujeres 1,61 [1,25; 2,08]; 60–65 años 1,94 [1,31; 2,88]; educación 0,84 [0,75; 0,95] por nivel; sin pareja 1,20 [1,03; 1,40]; 30–44 años 0,77 [0,56; 1,05]. Vivienda, trabajo, tabaco, PHQ-9 y salud cruzan 1.

Las personas que beben más al origen tienen menos probabilidad de ser seguidas en ambos intervalos; es la razón para reponderar. Este modelo es el resumen legible; no es el peso de la versión 2.

## SuperLearner: el paso previo a las réplicas

Por intervalo, biblioteca SL.mean, SL.glm, SL.glmnet y SL.ranger (500 árboles, nodo mínimo 50), cinco grupos estratificados, peso de origen como peso de observación, semilla fija, una sola vez antes de las réplicas jackknife (las réplicas miden variación muestral alrededor de un modelo de pesos fijo en lugar de reelegir el modelo).

| Intervalo | Media ponderada | Logística | glmnet | ranger | Ganador | Coeficientes (media, glm, glmnet, ranger) |
|---|---:|---:|---:|---:|---|---|
| VI→VII | 0,0783 | 0,0780 | 0,0778 | 0,0782 | glmnet | 0,38 · 0,33 · 0,00 · 0,29 |
| VII→VIII | 0,2485 | 0,2401 | 0,2396 | 0,2405 | glmnet | 0,00 · 0,22 · 0,42 · 0,36 |

El desgaste es poco predecible con estas covariables: el mejor aprendiz baja el riesgo validado un 0,6 % en VI→VII y un 3,6 % en VII→VIII. Los coeficientes del ensamble se reparten entre aprendices que predicen casi lo mismo; la tabla de riesgos es la que hay que leer. Las probabilidades del ensamble correlacionan 0,94 y 0,95 con las de la logística, con la misma mediana (0,92 y 0,60) y colas más cortas (mínimos 0,56 y 0,30 frente a 0,24 y 0,21); nadie cae bajo el piso de 0,02. Los pesos siguen la receta de la versión 1: piso, recorte en los percentiles 1 y 99 ponderados dentro del intervalo (47 y 33 casos en cada cola), masa fija en los pares observados.

## Tres esquemas de pesos: la matriz no se mueve

Modelos A (matriz de referencia con contracción) y lognormal, mismo conjunto de riesgo, 111 réplicas JKn: (1) solo peso oficial; (2) oficial × IPW v1, reajustada en cada réplica; (3) oficial × IPW v2 del SuperLearner, con probabilidades fijas (los intervalos condicionan en el modelo de pesos y son algo más estrechos).

| Permanencia (ambos intervalos) | Pares | Oficial | IPW v1 | IPW v2 |
|---|---:|---|---|---|
| N0→N0 (A) | 4.622 | 0,782 [0,758; 0,805] | 0,778 [0,754; 0,800] | 0,779 [0,756; 0,800] |
| FD→FD (A) | 412 | 0,672 [0,601; 0,737] | 0,663 [0,588; 0,731] | 0,663 [0,590; 0,729] |
| C1→C1 (A) | 2.822 | 0,567 [0,533; 0,601] | 0,563 [0,535; 0,592] | 0,562 [0,533; 0,591] |
| C2→C2 (A) | 141 | 0,106 [0,062; 0,175] | 0,106 [0,063; 0,172] | 0,108 [0,064; 0,176] |

Cambio celda a celda frente al esquema oficial (255 celdas en el agrupado):

| Modelo | Comparación | Cambio absoluto medio | Máximo | Celda del máximo (pares) |
|---|---|---:|---:|---|
| A | IPW v1 − oficial | 0,0043 | 0,028 | hombres 18–29, C4→C1 (16) |
| A | IPW v2 − oficial | 0,0039 | 0,022 | hombres 30–44, C1→C1 (302): 0,650 → 0,628 |
| Lognormal | IPW v1 − oficial | 0,0044 | 0,032 | hombres 30–44, C2→C1 (8) |
| Lognormal | IPW v2 − oficial | 0,0040 | 0,033 | hombres 30–44, C2→C1 (8) |

Por intervalo los máximos caen en celdas con 3 a 13 pares de origen. Regla para juzgar un cambio: dos conjuntos de probabilidades son equivalentes en la práctica cuando la prevalencia que proyectan para un subgrupo difiere en menos que el intervalo de confianza de la ENPG para ese subgrupo; ninguna fila con soporte se acerca a ese umbral.

## Equilibrio y precio de los pesos

Diferencias de medias estandarizadas (SMD) entre la muestra seguida ponderada y el conjunto en riesgo, 32 niveles de predictor:

| Esquema | VI→VII: máx |SMD| (niveles > 0,1) | VII→VIII: máx |SMD| (niveles > 0,1) |
|---|---|---|
| Solo oficial | 0,028 (0) | 0,127 sexo, 0,107 gramos previos (3) |
| Oficial × IPW v1 | 0,052 (0) | 0,048 (0) |
| Oficial × IPW v2 | 0,050 (0) | 0,060 (0) |

Por origen, el equilibrio falla donde hay pocas personas seguidas: en VII→VIII, C2 (63 seguidas) tiene 16 / 11 / 12 niveles por encima de 0,1 (oficial / v1 / v2) y C3+ (47) 12 / 15 / 15; en VI→VII, C3+ (51) 3 / 5 / 2. Las filas N0 y C1 quedan equilibradas con cualquier IPW.

| Esquema | Intervalo | ESS de Kish | Peso máximo / medio | 1 % superior | Recortes |
|---|---|---:|---:|---:|---|
| Solo oficial | VI→VII | 2.180 de 4.702 | 41,4 | 7,9 % | sin recorte |
| Oficial × IPW v1 | VI→VII | 3.154 | 4,4 | 4,5 % | 47 / 47 |
| Oficial × IPW v2 | VI→VII | 3.164 | 4,4 | 4,5 % | 47 / 47 |
| Solo oficial | VII→VIII | 1.839 de 3.393 | 15,1 | 7,1 % | sin recorte |
| Oficial × IPW v1 | VII→VIII | 1.935 | 5,5 | 5,5 % | 33 / 33 |
| Oficial × IPW v2 | VII→VIII | 2.017 | 5,3 | 5,3 % | 33 / 33 |

**Aviso:** el esquema oficial no se recorta y los dos esquemas IPW recortan el peso completado en p1/p99, lo que también corta las colas del peso oficial; la subida del ESS refleja el recorte, no una ganancia de precisión de la corrección por probabilidad inversa.

## Consistencia temporal dentro de cada intervalo

Con las predicciones fuera de muestra de la validación cruzada de la versión 1: proporción observada, predicha y diferencia por intervalo × origen × destino, con intervalos de diseño. En los destinos con masa (NC y C1) ninguna celda con soporte muestra un fallo sistemático; las mayores diferencias con soporte son −7,9 pp para A (VII→VIII, C3→C1, 36 pares) y +9,4 pp para la lognormal (VI→VII, C3→C1, 33 pares), ambas con intervalos que cruzan cero. Las celdas cuyo intervalo excluye cero tienen proporción observada exactamente cero (desde C3 en VI→VII nadie quedó en C2 ni en C3; desde C2 nadie llegó a C4) y el modelo asigna 1 a 6 %: un modelo paramétrico no pone ceros exactos y el error estándar de una proporción observada cero se degenera. C4 como origen (18 y 11 pares) está marcado escaso.

## Limitaciones

- Los intervalos de la IPW v2 condicionan en el modelo de pesos; los de la v1 incluyen esa incertidumbre. La diferencia es pequeña porque el modelo de pesos aporta poco.
- Macrozona y región no existen en los archivos públicos.
- Quien quedó impedido sin morir se trata como salida en este intervalo, igual que un fallecido; revisar si el panel se usa para incidencia.
- C2 y C3+ en VII→VIII: ningún esquema equilibra y la incertidumbre de esas filas es la de la versión 1.
- Una sola ejecución; sin verificador externo para esta versión (alcance pragmático). Las tablas de la versión 1 se reescriben en `eps_markov_outputs_v2/` y resultaron idénticas a las de la carpeta original.

## Archivos y reproducción

- Fuentes: `eps_markov_v2_extra.R` (funciones `ep_v2_*`, incrustado como celda), `eps_markov_v2_sections.R` (cuerpos de celda), `eps_markov_v2_narrative.md` (narrativa en inglés); el cuaderno v2 se construye con `_tools/build_eps_markov_v2_notebook.py` a partir del cuaderno EN ejecutado, sin tocar el original.
- Prueba sobre datos reales: `test_eps_v2_extra.R` (5 minutos, salidas en `.quarto/eps_v2_test`).
- Ejecutar: `python _tools/execute_eps_notebook.py __andres_control/eps_markov_transitions_v2_EN.ipynb --output-dir __andres_control/eps_markov_outputs_v2` (en este equipo con `--affinity` a los núcleos E, ~30 minutos); renderizar desde `__andres_control` con `quarto render eps_markov_transitions_v2_EN.ipynb --to html --no-execute` (el HTML cae en la raíz).
- Paquetes nuevos vía renv: `SuperLearner` 2.0-40, `glmnet`, `ranger`; `DESCRIPTION` y `renv.lock` pendientes de commit.
- Salidas: `eps_markov_outputs_v2/` (14 tablas `v2_*.csv`, figuras `fig_v2_*` en `en/`, README).
