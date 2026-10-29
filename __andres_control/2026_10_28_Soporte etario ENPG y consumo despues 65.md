# Soporte etario ENPG y consumo después de los 65

Oct 28, 2026 · @andresito

## Alcance

Esta revisión usa solo documentación, código y salidas que ya existen; no se ejecutó ningún análisis ni se modificó ningún archivo. El script `enpg_soporte_edad_2026_10_28.R` nunca se corrió: la carpeta `enpg_soporte_edad_outputs/` no existe, así que ninguna de sus tablas es un resultado.

**Marcas:** **\[E\]** evidencia verificada en un archivo; **\[I\]** inferencia; **\[P\]** propuesta.

## a) Cinco conclusiones verificadas para José

1. **\[E\] ENPG cubre de 12 a 65 años en todas las rondas.** Las edades observadas en 2012–2024 van de 12 a 65 y nadie pasa de 65 (`_enpg/notes/enpg_wave_inventory.csv`, n\_over65 = 0). El código del motor y `enpg_casen_aps.R` conservan 15–65. Hay personas de 15–17 en las siete rondas, pero solo existe una salida separada para ellas, la de 2024. Ninguna salida separa los 65 años exactos.
2. **\[E\] El soporte de cantidad y HED depende del sexo y de la edad.**
   - **60–65:** por sexo y ronda hay entre 270 y 422 bebedores con cantidad válida, y entre 64 y 216 personas con HED positivo.
   - **15–17 en 2024:** 22 hombres y 17 mujeres beben en 30 días; 9 y 11 tienen HED. El HED entre bebedores tiene intervalos de casi 0 a 1, con 1–2 grados de libertad.
3. **\[E\] La conversión de tragos usa cortes equivocados en todas las rondas.** Los cuestionarios y las etiquetas originales de 2012 a 2024 usan 0–2 / 3–4 / 5–6 / 7–9 / 10 o más. El código del motor y el de `expand_pif` asignan 7,5 y 9 a las dos categorías altas. El punto medio de 7–9 es 8, y 9 queda bajo el límite inferior de «10 o más». En 2018 el ítem viene codificado 1–5, en vez de 0–4 como en las demás rondas.
4. **\[E\] La persistencia del motor no viene de EPS.** El motor usa ρ = 0,8 fijo para participación, cantidad y HED (sensibilidad con 0 y 0,95). EPS sí estima persistencia binaria y un ρ latente anual de 0,80 a 0,93, pero el motor no lee esas salidas.
5. **\[E\] Pasados los 65, ENPG no tiene datos, pero EPS y ENCAVI sí.**
   - **El motor** saca de la población a quien cumple 66 (`age_exits`), sin registrarlo como muerte.
   - **EPS** tiene personas hasta los 98–107 años y pares longitudinales de beber / no beber para 66–70, 71–76 y 77+.
   - **ENCAVI 2023–24** tiene 5.019 personas de 65+. Mide consumo en 30 días y en el año, y el AUDIT-C; no mide días de consumo ni HED 5+/4+.

## b) Afirmaciones corregidas

| Antes | Corrección |
| --- | --- |
| «Solo hay datos de 15–17 en 2024» | **\[E\]** Solo encontramos una salida separada para 2024: `eps_alcohol_outputs/enpg2024_current_HED_age_sex.csv`, del 5-oct, con diseño UPM/ESTRATO. Los microdatos de 2012–2022 también tienen personas de 15–17, pero no están tabuladas aparte. Las salidas del 27-oct solo usan el tramo 15–29. |
| «Excluye 431–832 filas por ronda, casi todas de 12–14» | **\[E\]** `enpg_audit.csv` informa n\_excluded por ronda, pero no el motivo. Las filas salen por edad bajo 15, por sexo distinto de 1/2 o por peso ≤0. **\[I\]** Que casi todas sean de 12–14 es plausible, pero no está verificado. |
| «60–65: 33,0% con Kish 364» | **\[E\]** En `enpg_indicators_by_group.csv` (27-oct, `enpg_casen_rural_prelim.R`), el porcentaje (`original`) usa el peso original, pero la columna `kish` usa `peso_nacional`, el peso postestratificado a CASEN. Ese Kish solo refleja la dispersión de pesos y no reemplaza el error del diseño. La salida de 2024 da un n efectivo de 368 y un IC de diseño de 28,3–38,1%. |
| «HED válido» (15.976 en 2012…) | **\[E\]** Esta cifra incluye ceros estructurales: quien no bebió en 30 días y no reporta episodios cuenta como HED = 0 (`eca_history`). Un bebedor sin respuesta queda faltante. Esa salida no separa a los bebedores con HED válido; solo el archivo de 2024 lo hace (denominador «Current 30-day drinkers»). |
| «Toda persistencia del motor es un supuesto calibrado» | **\[E\]** Es un supuesto no identificado y no calibrado. El propio código lo anota: «marginal targets do not identify rho». ENPG es transversal repetida, así que no identifica persistencia individual. EPS y TSM sí tienen pares de las mismas personas. Detalle en la evaluación de la propuesta, más abajo. |
| «Puntos medios 1 / 3,5 / 5,5 / 7,5 / 9» | **\[E\]** `ENPG_BINGE` etiqueta las categorías como «7-8» y «9 o más», pero los datos originales dicen 7–9 y 10 o más en todas las rondas. Lo correcto es 8 para 7–9. Para «10 o más» hace falta un valor de 10 o más, justificado, o una sensibilidad. |
| «`OH_9` … (cuestionario 2024)» como ítem común a todas las rondas | **\[E\]** El código del ítem cambia entre rondas: 2012 `p20`; 2014 `oh11`; 2016 `oh_15`; 2018 `OH_13`; 2020–2024 `OH_9`. En 2014 y 2018, la variable llamada `oh9`/`OH_9` es otra pregunta, con valores de hasta 400.000, y no corresponde a tragos. |
| Educación «1 = básica o menos» | **\[E\]** El nivel 1 de `eca_educ` incluye media incompleta. La etiqueta fiel es: 1 = media incompleta o menos; 2 = media completa o superior incompleta; 3 = superior completa. EPS tiene el mismo problema: «Primary completed or less» también incluye media incompleta. |
| «Adolescentes: CASEN por edad simple sirve mejor» | **\[I\]** CASEN calibra la composición por edad, pero no resuelve que la educación alcanzada a los 15–17 no es un estrato socioeconómico comparable con la educación final de un adulto. **\[I\]** En 2012–2018 existen columnas de educación del jefe de hogar (`p184_2`, `dp9_2`, `dp_9_b`, `T_DP_12_2`), que podrían servir como proxy socioeconómico del hogar. En 2020–2024 no existen. Hay que verificarlo en los microdatos. |
| «Más de 65: no hay ningún dato» | **\[E\]** Faltan datos en ENPG, no en general. EPS y ENCAVI tienen observaciones sobre 65. Además, el motor puede seguir envejeciendo a las personas simuladas: hoy no lo hace solo porque `max_age = 65`. |
| «60–65 alcanza para prevalencia y cantidad» | **\[E\]** Ese n es de personas, no de bebedores. Con educación superior, en 60–65 hay 96 a 208 hombres y 134 a 345 mujeres por ronda (`enpg_factors_educ3.csv`). Cuántos de ellos beben, tienen HED o están en C3+ no está tabulado. No declaro suficiente ninguna celda. |

## c) Pendientes que requieren microdatos o ejecución

**ENPG**

- [ ] Tabular por ronda las personas de 15–17, 60–64 y 65 años, por sexo, con denominadores separados: personas encuestadas; consumo en 30 días conocido; bebedores en 30 días; bebedores con cantidad válida; bebedores con HED válido, sin ceros estructurales. Incluir educación cuando haya soporte, n sin ponderar, % ponderado, Kish con el peso original y error de diseño donde el diseño lo permita (2024 con UPM/ESTRATO; 2022 con estratos aproximados). El script del 28-oct cubre casi todo esto, pero antes de correrlo hay que decidir si conserva los puntos medios 7,5/9.
- [ ] Cruzar `audit2` de `ENPG_BINGE` con el ítem original de cada ronda, sobre todo `OH_13` de 2018.
- [ ] Desglosar las exclusiones por motivo: edad, sexo o peso.

**EPS**

- [ ] Contar personas de 65 exactos, 66–74, 75–79 y 80+ por sexo y ola (las salidas actuales usan 60–65, 66–70, 71–76 y 77+). Separar personas observadas; bebedores sin ponderar; pares con consumo válido en ambos extremos; educación.
- [ ] Separar la pérdida por muerte de la pérdida por no respuesta en los pares de 66+.

**ENCAVI**

- [ ] Tabular `p5_20`–`p5_24` para 65, 66–74, 75–79 y 80+, por sexo y educación, con `w_personas_cal`, `varunit` y `varstrat`. Hoy no existe ninguna tabla de ENCAVI para mayores de 65: `encavi_tsm_explicado.R` filtra a 18–65 urbano.
- [ ] Comparar ENCAVI con ENPG en 60–65, usando el mismo AUDIT-C y el mismo consumo en 30 días.

**Mortalidad**

- [ ] Verificar la cobertura sobre 65: `DEFUNCIONES_DEIS_2012_2023_15plus` incluye muertes de 15 años y más, según su README (el motor filtra a 15–65); las tablas de vida INE llegan a 110+.
- [ ] Revisar los RR para 65+. El handoff menciona bandas 65+ en los RR de Adam/OMS, pero no está verificado.

## d) Discrepancias que podrían afectar resultados

| # | Discrepancia | Qué resultados dependen de ella | Magnitud conocida |
| --- | --- | --- | --- |
| 1 | Puntos medios 7,5 y 9 (deberían ser 8 y 10 o más) | g/día del motor (`ms-survey-inputs`) y de `expand_pif` (volajohdia); clases C1–C3+; ajustes Gamma; PAF/AAF crónicas; factor de anclaje OMS; reconstrucción de HED; factores de diseño de `consumption` | **\[E\]** Las dos categorías altas reúnen del 2,4% (2024) al 3,8% (2012) de quienes responden el ítem (bebedores del último año, sin ponderar; `enpg_alcohol_counts.csv`). En cada día sin HED se subestima 0,5 trago (6 g) en 7–9 y al menos 1 trago (12 g) en 10+. **\[I\]** El efecto sobre la media debería ser chico; sobre la cola (C3+) puede no serlo. Hay que recalcular para saberlo. |
| 2 | 2018 codificado 1–5 | Toda la serie de g/día de 2018 | **\[E\]** No hay script que construya `ENPG_BINGE` (registro Q26). En 2018 el error de reconstrucción del HED es de −11 pp, contra −2,3 a −4,8 en las demás olas. **\[I\]** Coincide con un desfase de codificación, pero no lo prueba. |
| 3 | Inconsistencia entre fuentes | Comparaciones ENPG–TSM | **\[E\]** TSM usa 8 y 10 para las mismas categorías (`TSM_pooled_metodo.md`). |
| 4 | **\[I\]** Episodios HED valorados en 5 (hombres) o 4 (mujeres) tragos, aunque el trago típico declarado sea mayor | g/día de bebedores intensos | Sin cuantificar |
| 5 | El motor saca a la gente a los 66 | No hay mortalidad atribuible desde los 66; la mortalidad a los 65 se toma del grupo 65–69 | **\[E\]** Código del motor (celdas 9 y 15) |
| 6 | Pares EPS de mayores solo con sobrevivientes reentrevistados | Persistencia en 66+ | No cuantificado |

## Mayores de 65: lo que existe

EPS tiene observaciones y pares longitudinales después de los 65; ENCAVI tiene una ronda con 5.019 personas de 65+, todavía sin tabular para esas edades.

### EPS

**\[E\] Edades disponibles en las olas** (`harmonization_audit.csv`, 5-oct):

| Ola | n | Edad mínima–máxima |
| --- | --- | --- |
| VI | 16.906 | 18–99 |
| VII presencial | 7.800 | 22–98 |
| VIII | 15.788 | 18–107 (el 107 parece un problema de calidad) |

**\[E\] Exclusiones del código** (aparte de lo que trae la encuesta):

- El cuaderno de prevalencia y persistencia (`eps_alcohol_prevalencia_persistencia.ipynb`) conserva 18–115.
- El Markov v4 de cinco estados limita el origen a 18–65 (`eps_markov_core.R` l.142), así que no hay transiciones por categoría para 66+.
- TSM también limita el origen a 18–65.

**\[E\] Qué mide EPS:** por bebida, `f13` (si bebe, sin ventana temporal explícita), `f14` (días por semana del último mes) y `f15` (vasos por ocasión). Esta es la descripción de la auditoría del proyecto; el enunciado literal no se verificó en esta revisión. Para pasar a g/día hay que suponer cuántos gramos tiene cada vaso (12 g). EPS no mide HED: su categoría «Heavy» se define por volumen (40 g/día o más en mujeres, 60 o más en hombres).

**\[E\] Personas con estado válido y % ponderado de consumo declarado** (`prevalence_50plus.csv`, 5-oct). Cada celda: n sin ponderar (%).

| Ola | Edad | Hombres | Mujeres |
| --- | --- | --- | --- |
| VI | 60–65 | 611 (49,3%) | 660 (21,4%) |
| VI | 66–70 | 415 (42,8%) | 458 (17,4%) |
| VI | 71–76 | 408 (38,8%) | 406 (15,7%) |
| VI | 77+ | 440 (30,3%) | 540 (13,6%) |
| VIII | 60–65 | 583 (43,1%) | 763 (20,7%) |
| VIII | 66–70 | 447 (36,8%) | 535 (20,4%) |
| VIII | 71–76 | 423 (36,8%) | 471 (14,8%) |
| VIII | 77+ | 432 (27,5%) | 523 (12,0%) |

- **Kish:** VIII 77+ tiene un Kish de 162 en hombres y 246 en mujeres.
- **Bebedores:** no hay conteo de bebedores sin ponderar; está pendiente.
- **Educación (n de personas):** en 66–70, 71–76 y 77+, las celdas de educación superior tienen entre 15 y 72 personas por sexo y ola.
- **«Heavy»:** entre 0% y 1,8% después de los 65.

**\[E\] Pares longitudinales** (`binary_transitions.csv`; unos 7,7 años en VI→VIII). Cada celda: no bebedores / bebedores al inicio; P(sigue bebiendo) \[IC95%\].

| Edad al inicio | VI→VIII, hombres | VI→VIII, mujeres |
| --- | --- | --- |
| 60–65 (referencia) | 113 / 115; 0,55 \[0,45–0,66\] | 252 / 82; 0,34 \[0,24–0,45\] |
| 66–70 | 98 / 68; 0,55 \[0,40–0,70\] | 170 / 53; 0,38 \[0,24–0,54\] |
| 71–76 | 78 / 52; 0,46 \[0,31–0,62\] | 136 / 24; 0,33 \[0,14–0,59\]\* |
| 77+ | 41 / 21; 0,42 \[0,20–0,67\]\* | 73 / 11; 0,19 \[0,03–0,66\]\* (n efectivo 3,9) |

\* Marcado `sparse_or_low_df`.

- **ρ anual latente** (`rho_age_sex.csv`): 0,82–0,93 en hombres de 66–76 y 0,76–0,93 en mujeres, con intervalos que se superponen con los de 60–65.
- **Diagnóstico de las mismas personas en tres entrevistas** (`ar1_same_people_diagnostic.csv`, todas las edades): la correlación observada en el intervalo largo es 0,48, contra 0,33 implicada por un AR(1). El Markov simple no basta; por eso se propuso el modelo rasgo + AR(1), que no está implementado.

### ENCAVI 2023–24

**\[E\] Diseño:** muestra nacional urbana y rural de 15 años y más, con 16.590 personas (README) y 5.019 casos de 65+, el 16% ponderado (manual, Tabla 1). Es una sola ronda transversal.

**\[E\] Preguntas de alcohol** (manual del libro de códigos):

| Código | Enunciado | Alternativas |
| --- | --- | --- |
| `p5_20` | «¿Ha tomado Ud. alcohol alguna vez en su vida?» | 1 Sí; 2 No; 8 No sabe; 9 No responde |
| `p5_21` | «¿Cuándo fue la última vez que Ud. consumió alcohol?» | 1 Durante los últimos 30 días; 2 Hace más de un mes, pero menos de un año; 3 Hace más de un año; 8; 9 |
| `p5_22` | «¿Qué tan seguido toma Ud. alguna bebida alcohólica?» | 1 Nunca; 2 1 vez al mes o menos; 3 2 a 4 veces al mes; 4 2 a 3 veces a la semana; 5 4 o más veces a la semana |
| `p5_23` | «¿Cuántos tragos suele tomar en un día típico de consumo de alcohol?» | 1 1 o 2; 2 3 o 4; 3 5 o 6; 4 «7 o 9» (así figura en el manual); 5 10 o más |
| `p5_24` | «¿Qué tan seguido toma Ud. 6 o más tragos en una sola ocasión?» | 1 Nunca; 2 Menos de una vez al mes; 3 Mensualmente; 4 Semanalmente; 5 Todos o casi todos los días |

- **Sí permite medir:** consumo alguna vez, consumo en 30 días, consumo en el último año, y frecuencia y cantidad típica en categorías.
- **No permite medir:** días de consumo en 30 días, HED 5+/4+ en 30 días, ni g/día directo. Solo se puede aproximar g/día multiplicando dos categorías ordinales. El ítem de 6 tragos o más tiene otro umbral y no tiene ventana temporal.
- **\[E\]** `p5_22`–`p5_31` solo las responden quienes bebieron en el último año (README). La categoría más baja de `p5_23` es «1 o 2»; en ENPG es «0 a 2».

## Evaluación de la propuesta

La propuesta es coherente con el motor, pero parte de un supuesto que hoy no se cumple: el motor no usa la persistencia estimada con EPS.

**Una precisión primero \[E\]:** hoy el motor usa ρ = 0,8, ni siquiera la estimación EPS hasta 65. El primer paso sería integrar la estimación EPS en el tramo 15/18–65.

**Persistencia después de 65 \[E/I\]:** EPS permite estimarla directamente, pero solo la persistencia binaria (beber / no beber).

- En hombres de 66–76 hay de 52 a 74 bebedores al inicio por grupo de edad e intervalo.
- En mujeres de 71 o más, y en cualquier persona de 77 o más, el soporte es insuficiente.
- No hay transiciones por categoría (C1/C2/C3+) para 66+: el código del Markov v4 las excluye.
- No hay transiciones de HED.

Por eso no hace falta extrapolar la persistencia binaria entre 66 y 76. **\[P\]** Puede estimarse en un modelo de 50 años y más con un término de edad, y contrastar si la pendiente cambia después de 65.

**Persistencia constante no es cantidad constante \[I\].** En el motor, cada persona tiene una variable latente z que sigue un AR(1) con ρ, y la distribución de consumo de cada edad se aplica sobre esa z. Con ρ fijo, cada persona tiende a conservar su posición relativa, mientras la prevalencia y el g/día de cada edad pueden bajar. Un ρ fijo combinado con una prevalencia que baja con la edad implica tasas de transición concretas, que hay que contrastar con los pares observados en EPS.

| Componente después de 65 | Estimable | Transportado | Validación faltante |
| --- | --- | --- | --- |
| Prevalencia por edad y sexo | Sí: 3 olas EPS (consumo declarado sin ventana explícita) y ENCAVI (30 días, pendiente de tabular) | — | Comparar ENPG, EPS y ENCAVI en 60–65, donde se superponen |
| g/día entre bebedores | Parcial, con EPS (requiere suponer 12 g por vaso) | La escala ENPG (anclada a OMS), llevada a EPS mediante una razón calculada en 50–65 | Comprobar que esa razón es estable con la edad |
| Modelo paramétrico **\[P\]** | Dos partes: logit de participación con spline de edad × sexo, más lognormal del g/día (la lognormal ganó en EPS v4), ajustado en 50–85 para cruzar el borde de 65 | — | Ajustar hasta 70 y predecir 71–80 fuera de muestra |
| HED | No | Sí: la probabilidad de HED dado el g/día, estimada en ENPG 50–65, o el ítem de 6 tragos o más de ENCAVI como proxy | Ninguna fuente valida HED 5+/4+ después de 65 |
| Persistencia binaria | Sí, hasta 76 | 77+ | Transiciones implicadas por el motor frente a las observadas en EPS 66+; sesgo de sobrevivencia |
| Persistencia por categoría y de HED | No (hoy excluida por código) | Sí | Requiere correr el Markov v4 sin el tope de 65 al origen |
| Educación en 66+ | Solo como término principal, no en cruces | Gradiente educativo | Celdas de educación superior de 15 a 72 personas, aún sin contar bebedores |

## Lo que podemos sostener hoy

Nada de esto obliga a excluir a quienes cumplen 65; la decisión es qué fuente alimenta cada parámetro en esas edades.

**Consumo después de 65**

- **\[E\] Fuentes:** ENPG no lo observa; EPS lo observa en tres olas con pares de las mismas personas, y ENCAVI en una ronda.
- **\[E\] Prevalencia en EPS:** baja con la edad (hombres en VIII: 43% a los 60–65, 37% a los 66–76 y 27,5% a los 77+).
- **\[E\] Persistencia binaria en EPS:** en 66–70 es similar a la de 60–65.
- **\[E\] Límites:** después de 65 no hay HED comparable ni g/día sin supuestos.

**Mortalidad después de 65**

- **\[E\] Motor:** hoy no la sigue; la gente sale de la población a los 66.
- **\[E\] Datos de entrada:** DEIS y las tablas de vida INE cubren esas edades.
- **\[I\] Dónde está la limitación:** en el código y en los parámetros de consumo, no en los datos demográficos.

**Qué falta verificar**

- Las tablas de EPS y ENCAVI con los cortes 65 / 66–74 / 75–79 / 80+.
- Cuánto de la pérdida de los pares EPS se debe a muertes.
- Los RR para 65+.
- La conversión de tragos de ENPG, incluida la codificación 2018.
