# Respuestas a tus preguntas sobre la microsimulación (20-sep-2026)

> **Actualizado 21-sep-2026.** Cambios: §7 (qué cambiar), §8 (reescrito corto) y **Addendum 2** al final (§16–§26: persistencia, nunca bebedores, mayores de 65, error de mortalidad, HMD vs DEIS, QC/2014/embriaguez, estrato = comuna, factor OMS y el **prompt en inglés para Kimi/Gemini en §25**). Acompañan: `expand_pif_cambios_hallazgos_2026-09-21.md` (cambios a notebooks), el plan de trabajo actualizado y `entrada_2026-09-21_para_codex_handoff_adam_rr_full_override_caveman.md` (para pegar al final del handoff canónico).

Cada sección responde una de tus notas, en el mismo orden. Cuando cito números, vienen de `microsim_base_outputs/` (notebook base) o `microsim_recalib_outputs/` (notebook de recalibración). Para la pregunta de los pesos 2022 leí `__enpg/ENPG-2022.pdf` (pp. 12–23) y las secciones equivalentes de `ENPG-2020-WEB.pdf` y `enpg2024.pdf`.

---

## 1. "No entiendo: persistencia `rho = 0,8`, indicador de haber bebido, «ex» ≠ un año de abstinencia"

Son tres cosas distintas empaquetadas en un párrafo. Separadas:

**a) Qué es la persistencia (`rho`).**
La ENPG te dice, cada dos años, *qué porcentaje* de hombres de 30–44 bebió en el último mes. No te dice *si son los mismos hombres* que bebieron en la ola anterior. Para simular personas año a año hay que decidir eso, y `rho` es esa decisión:

- `rho = 1`: cada persona repite exactamente su estado (el que bebe, bebe siempre; el que no, nunca).
- `rho = 0`: cada año se sortea de nuevo quién bebe, sin memoria.
- `rho = 0,8`: mucha memoria, algo de cambio. Con este valor, ~20 % de las personas cambian de estado (bebe ↔ no bebe) cada año.

Técnicamente, cada persona tiene una "propensión" latente `Z` que evoluciona como `Z_{t+1} = rho·Z_t + ruido`, y bebe en el año `t` si su `Z_t` está por encima del umbral que reproduce la prevalencia observada de su celda sexo × edad. La prevalencia (el margen) queda clavada a la encuesta pase lo que pase con `rho`; lo que cambia con `rho` es **quién** está arriba o abajo del umbral cada año.

**b) "Haber bebido alguna vez" nunca retrocede.**
Cada persona simulada tiene una bandera `ever` (¿bebió alguna vez en la vida?). Una vez que bebe, la bandera queda en `TRUE` para siempre — no tiene sentido que alguien "deje de haber bebido". Se menciona porque es una regla del motor que afecta a cuántos "nunca bebedores" hay en 2024 (ver pregunta 8).

**c) Qué significa "ex" aquí.**
En la ENPG (`oh2`) la última vez que bebió puede ser "últimos 30 días", "hace más de 30 días" o "hace más de un año". El pipeline heredado (expand_pif) llama **ex-bebedor** a todo el que bebió alguna vez pero *no en los últimos 30 días*. Eso incluye a alguien que bebió hace 6 semanas. Las fuentes de RR (Rehm, GBD) definen ex-bebedor como **≥ 12 meses** sin beber. Son definiciones distintas; el notebook usa la heredada y lo advierte para que no se alimente un RR de ex-bebedor (que asume abstinencia prolongada) con gente que dejó de beber hace un mes.

---

## 2. "La mortalidad hasta aquí no depende del consumo de alcohol"

Cada persona simulada muere con la probabilidad `qx` de la tabla de vida de HMD para su edad y sexo (escalada por un multiplicador para cuadrar con DEIS). Esa probabilidad es la misma para un abstemio y para alguien que bebe 80 g/día. El modelo **todavía no** tiene el paso "consumo → riesgo relativo → probabilidad de muerte individual".

Consecuencia práctica: el modelo hoy sirve para describir población y consumo juntos, pero **no puede** calcular muertes evitadas por una política, ni mortalidad atribuible, ni YPLL. Eso se ve en la proyección: las tres reglas de proyección dan **exactamente las mismas** 35.693 muertes esperadas en 2034 aunque una tiene prevalencia 37 % y otra 15 %. Ese vínculo es el trabajo pendiente del módulo de integración.

---

## 3. "Las salidas y entradas son residuales"

Cada 1 de enero el motor compara cuántas personas simuladas hay de cada edad y sexo con cuántas dice INE que debe haber. Si faltan, crea personas nuevas; si sobran, elimina al azar. Esas creaciones/eliminaciones son las "entradas y salidas residuales".

Qué absorben: inmigración, emigración, diferencias entre la mortalidad del modelo y la real, redondeo, y diferencias de vintage entre fuentes. Por eso **no** son una estimación de migración: son el ajuste contable que hace que el stock cuadre con INE. Y por eso "la población simulada coincide con INE" no es una validación — coincide por construcción.

Lo que sí es informativo: su magnitud. En la corrida de proyección, las entradas residuales son 65–301 personas sintéticas por año sobre ~25.000–30.000 (0,3–1 %), concentradas en 2016–2019 y 2021–2022, que es cuando INE registra más inmigración. Coherente, pero no validado.

---

## 4. "Si uso 2012–2020 como criterio y contrasto 2022–2024: prevalencia sobreestimada, 16/16 mal; intensidad 12/16 bien"

Corrección menor: el entrenamiento es **2012–2020** (no 2010). Lo demás es correcto y el porqué es este:

- La prevalencia observada sube de 2012 a 2014, se mantiene plana hasta 2020 y **cae** en 2022 y 2024. Una recta ajustada a 2012–2020 tiene pendiente positiva (porque 2012 está bajo) y sigue subiendo justo cuando la realidad baja. Resultado: sobreestimación de +9,75 puntos en promedio, ninguna celda dentro del intervalo (0/16).
- La intensidad (g/día entre bebedores) no tiene esa forma: es casi plana en todo el período, así que extrapolar una recta casi plana funciona (12/16 dentro del intervalo, RMSE 1,08 g/día).

En el notebook de recalibración esto se confirma con cuatro curvas distintas: la tendencia lineal es la peor en **todos** los cortes temporales, no sólo en 2020→2022.

---

## 5. "Mortalidad 2024, más que DEIS: 5 % hombres, 3 % mujeres"

Esos números son del notebook **base**: el multiplicador de mortalidad se calibró sólo con DEIS 2012–2020 y luego se aplicó a 2021–2024. En 2024 el modelo espera 5,2 % más muertes que DEIS en hombres y 3,2 % en mujeres.

En el notebook de recalibración, con el multiplicador calibrado sobre 2012–2024 completo, el error en 2024 baja a +3,8 % (hombres) y +2,5 % (mujeres), pero aparece el patrón completo: el error va de **−3,1 % en 2012 a +3,8 % en 2024**, monótono. Es decir, HMD y DEIS se separan gradualmente en el período y un multiplicador único promedia esa deriva.

Causas candidatas (ninguna verificada todavía):

1. Vintage: la tabla HMD "2024" y el stock INE base CPV-2024 no son necesariamente coherentes con los conteos DEIS 2024 (archivo provisional, fechado junio 2026).
2. Edad fija en enero: el motor usa la edad al 1 de enero para toda la muerte del año; DEIS registra edad al morir.
3. HMD y DEIS comparten el mismo registro civil, así que un desajuste entre ambos habla de procesamiento, no de epidemiología.

Qué hacer: un multiplicador por año (o con tendencia) lo elimina por construcción. Es una decisión de calibración, hay que etiquetarla así.

---

## 6. "EXPLORAR: PSU 2016 incompleto, estrato 2024 disponible y PSU 2020 no validado"

Qué es cada cosa y por qué importa:

- **PSU** (unidad primaria de muestreo) = la manzana donde se sortearon las viviendas. **Estrato** = el grupo geográfico dentro del cual se sortearon manzanas. Ambos se necesitan para calcular **errores estándar** correctos. **No afectan las prevalencias**, sólo qué tan anchos son los intervalos de confianza.
- **2016**: la caché de diseño tenía un identificador de PSU corto que mezclaba manzanas distintas. Lo resolví leyendo `base ENPG 2016 publico general.dta` y armando el PSU con comuna + distrito + zona + manzana. Ya está hecho, no hay que explorar más.
- **2024**: la base pública trae la variable `ESTRATO` explícita; se usó. Las otras olas usan la región como estrato "proxy" porque no tienen la variable.
- **2020**: la caché no tiene ninguna variable de conglomerado. Los errores estándar de 2020 se calculan como si fuera muestreo aleatorio simple con pesos, lo que **subestima** el error. Por eso 2020 queda fuera de los cálculos de cobertura de intervalos.

Qué explorar, concretamente: si `enpg2020.RDS` o `factoresdeexpansion.dta` (en `__enpg/`) traen una variable tipo `varunit`/`conglomerado`/`manzana`. Si existe, se reconstruye el PSU de 2020 y desaparece la excepción. Es una tarea de 20 minutos con respuesta sí/no.

---

## 7. "EXPLICAR, ver si esto se hizo con expand_pif: volumen corregido guardado falta en todos los no consumidores"

**Corto: sí viene de expand_pif, no es un error y no cambia ningún AAF. Sólo hay que evitar un mal uso.**

`data_binge_sensitivity.rds` lo escribe `expand_pif.ipynb` (celda 6, `write_rds(data, .../data_binge_sensitivity.rds)`). Ahí `volajohdia` (g/día) es `NA` para abstemios y ex-bebedores (`cvolaj` = `ltabs` o `fd`), porque el volumen sólo se calcula para quien reporta consumo. El AAF usa categorías (`cat1–cat4`, `ltabs`, `fd`), así que da igual.

El riesgo: la media ponderada de `volajohdia` de ese archivo es la media **entre bebedores**, no el consumo per cápita. Si alguien la usa como per cápita o como meta de calibración poblacional, se equivoca. Por eso el notebook de microsimulación usa los g/día crudos de la encuesta y deja el factor OMS como decisión aparte (§24).

**Qué cambiar (act. 21-sep; propuesta: es un `.ipynb`, no se aplica sin tu permiso)**

| # | Dónde | Cambio | Tiempo | ¿Cambia resultados? |
|---|---|---|---|---|
| 1 | `expand_pif.ipynb`, celda que escribe `data_binge_sensitivity.rds` | Agregar columna per cápita (código abajo). Igual para `volajohdiams` si se exporta | 5 min | No |
| 2 | Misma celda | Comentario de advertencia (primera línea del código abajo) | 1 min | No |
| 3 | Scripts o notebooks que leen ese `.rds` | Buscar `volajohdia`; donde se calcule "per cápita", usar `volajohdia_pop` | 10 min | Sólo si alguien lo usó mal |

```r
# volajohdia is NA for ltabs/fd: its weighted mean is among drinkers, NOT per capita.
data <- data |>
  dplyr::mutate(volajohdia_pop = dplyr::if_else(cvolaj %in% c("ltabs", "fd"), 0, volajohdia))
```

Buscar usos (PowerShell, desde la raíz del proyecto):

```powershell
Get-ChildItem -Recurse -Include *.R, *.ipynb, *.qmd | Select-String -Pattern "volajohdia" | Select-Object Path, LineNumber
```

---

## 8. "POR QUÉ SERÍA UN PROBLEMA: DEIS 2024 se restringe a ese año y a edades en años cumplidos"

**Corto: no es un problema. Son dos filtros de seguridad. Nada más.**

| # | Filtro | Qué evita |
|---|---|---|
| 1 | Quedarse sólo con muertes **del año 2024** | El archivo DEIS trae también muertes de 2025 y 2026 (provisionales). Sin el filtro, se sumarían a 2024. |
| 2 | Edad en años = `EDAD_CANT` **sólo si** `EDAD_TIPO == 1` (años). Si `EDAD_TIPO` es 2 (meses) o 3 (días) → edad = 0 | Un bebé de 15 meses tiene `EDAD_CANT = 15`. Sin mirar `EDAD_TIPO`, aparece como muerte a los 15 años. Es el bug que se corrigió en julio en expand_pif ("bug edad_tipo en mort24"). |

Regla para recordar: **año correcto + edad en años.**

Con el archivo nuevo (`DEFUNCIONES_FUENTE_DEIS_2024_2026_15092026.parquet`) se aplican los mismos dos filtros.

```r
.t0 <- Sys.time()
deis_2024 <- deis |>
  dplyr::filter(year == 2024) |>                                     # filter 1: year of death
  dplyr::mutate(age = dplyr::if_else(EDAD_TIPO == 1, EDAD_CANT, 0))  # filter 2: months/days -> age 0
cat(sprintf("Elapsed: %.2f minutes\n", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
```

(`year` = la columna de año de defunción que ya usa tu código.)

---

## 9. "SE SUPONE QUE SE FIJÓ EN RHO = 0,8, ¿NO?"

Sí. **Todas las corridas principales usan `rho = 0,8`.** La tabla con 0 / 0,8 / 0,95 es un **análisis de sensibilidad**: se repite la misma corrida (misma semilla, misma demografía) cambiando sólo `rho`, para mostrar qué depende de ese supuesto.

Lo que muestra:

| rho | Cambian de estado cada año | Prevalencia 2024 | "Nunca bebió" en 2024 |
|---:|---:|---:|---:|
| 0 | 48 % | 36,7 % | 1,7 % |
| **0,8** | 20 % | 36,3 % | 6,1 % |
| 0,95 | 10 % | 35,9 % | 12,6 % |

(Números del notebook de recalibración; los del base son análogos con prevalencia ~48 % porque usaba la curva lineal.)

Lectura: la prevalencia es la misma en las tres filas (está calibrada), pero la proporción de gente que **nunca** bebió varía de 1,7 % a 12,6 %. Si `rho` es bajo, casi todos han bebido alguna vez en 13 años; si es alto, muchos nunca. Como los RR de ex-bebedores y nunca-bebedores son distintos, esa incertidumbre pasaría directo a la mortalidad atribuible. Por eso insisto en que esas historias no están validadas.

---

## 10. "No entiendo persistencia individual; ¿el seguimiento después de los 65 no debiera proyectarse 5 años para los de 61–65?"

**Persistencia individual** = lo mismo que `rho` (pregunta 1): cuánto se parece el consumo de una persona en el año t+1 a su consumo en t. Es "individual" porque es una propiedad de la trayectoria de cada persona, no del promedio poblacional.

**Sobre los mayores de 65.** Tienes razón en que es una limitación y en que se puede extender. Hoy el motor saca a la gente al cumplir 66 porque la ENPG sólo encuesta hasta los 65: no hay dato de consumo para 66+. Opciones, de menor a mayor esfuerzo:

1. **Cola cerrada** (lo que propones): las personas que están en el modelo siguen hasta los 70 (o más) con su estado latente evolucionando con el mismo `rho` y con los parámetros de la celda 60–65 congelados. INE y HMD tienen stocks y `qx` para esas edades, así que la demografía funciona. No entran personas nuevas de 66+ (no sabríamos qué consumo darles). Cambio pequeño en el motor: `max_age` y reutilizar los drivers del grupo 4.
2. **Cohorte abierta 66+**: además se agregan personas de 66+ desde INE, asignándoles consumo con un supuesto (p. ej. mismo que 60–65, o un descenso por edad tomado de otra encuesta como ENS). Requiere una decisión sobre ese supuesto.

Por qué importa más de lo que parece: la mayor parte de las muertes atribuibles a alcohol (cáncer, hepáticas, cardiovasculares) ocurre **después de los 65**. Un modelo que corta en 66 subestima sistemáticamente los beneficios de cualquier política. La opción 1 es el mínimo defendible y la recomendaría como siguiente cambio estructural, una vez que exista el vínculo mortalidad–consumo.

---

## 11. "No entiendo: puente encuesta–APC y definiciones de HED / ex-bebedor"

**Puente encuesta–APC.**
- Las encuestas subestiman el consumo: si sumas los gramos que declara la gente, llegas a entre 30 % y 60 % del alcohol que realmente se vende. La OMS estima el consumo real con datos de ventas/producción: **APC** (*alcohol per capita*, litros de alcohol puro por persona de 15+ por año).
- Para usar RR (que están calibrados contra consumo real), la práctica habitual es **escalar** los gramos de encuesta hacia arriba hasta que el promedio coincida con el APC. Ese escalamiento es el "puente".
- Por qué no está resuelto: hay que decidir (a) el denominador (APC es 15+, el modelo es 15–65); (b) si se incluye alcohol no registrado; (c) si se escala a todos por igual (mueve a gente entre categorías de riesgo, pero no cambia quién bebe); (d) qué año/serie de APC usar; (e) qué hacer con el 2020. expand_pif ya aplica una corrección (`volajohdiams`) sólo a bebedores; el notebook de microsimulación trabaja en escala de encuesta y deja la decisión explícita. Para "cerrar" esto hay que elegir (a)–(e) y documentarlo; es una reunión, no un análisis.

**HED.**
- En la ENPG el indicador viene de `db` (días con 5+ tragos en el último mes); en el notebook `hed = db > 0`. Los RR de "binge" (p. ej. para lesiones) se definen como ≥ 60 g en una ocasión, que no es exactamente "5 tragos de 12 g = 60 g" para mujeres (donde el umbral suele ser 4 tragos / 48 g). Además, hay que verificar en los cuestionarios (`__enpg/Cuestionario*.pdf`) si la pregunta y el umbral fueron idénticos en las siete olas. Cerrar = una tabla ola × pregunta × umbral, y una definición única para el modelo.

**Ex-bebedor.**
- Pregunta 1c. Cerrar = decidir si "ex" es ">30 días" (heredado) o "≥ 12 meses" (compatible con los RR), y si se usa la respuesta de recencia de la encuesta o la historia simulada.

Ninguno de los tres se cierra con código; se cierran con una decisión escrita que después el código implementa.

---

## 12. "Los pesos de 2022 se calcularon de otra forma o el diseño cambió — explora el PDF"

Lo exploré. Respuesta: **las dos cosas**, y el informe lo documenta.

Lo que dice `ENPG-2022.pdf`:

| Aspecto | 2020 | 2022 | 2024 |
|---|---|---|---|
| Marco muestral | Marco de manzanas MMM 2015 | **Nuevo** marco de viviendas MMV 2020 (urbano/rural, Censo 2017) | MMV 2021 |
| Modalidad | CAPI **+ CATI (telefónica)** por pandemia; sin módulo autoaplicado; preguntas refraseadas; sin tarjetas | 100 % CAPI presencial, tablet | 100 % CAPI |
| Pesos | suavizado + calibración a proyecciones por comuna/región/sexo/edad | 8 pasos: … + **suavizado (truncamiento) mixto CM + R-K** + **raking** a proyecciones INE al 28-feb-2023 | Igual que 2022 |
| Población que representan los pesos (12–65) | — | **12.941.545** (de 7,8 M sin calibrar) | **11.396.772** (de 10,4 M sin calibrar) |
| Tasa de logro | — | 75,1 % (Atacama 45 %, RM 108 %) | — |
| Terreno | — | 186 días (nov-2022 → ~may-2023) | — |

Qué explica cada cosa que vimos en la auditoría:

- **CV de pesos 1,05 (vs 1,6–1,9)**: el suavizado trunca los pesos grandes y el raking los comprime. 2024 usa el mismo método pero su CV volvió a 1,6, así que el truncamiento de 2022 fue más agresivo o el ajuste por no respuesta más desigual (logro 45 %–108 % según región).
- **Población implícita 91 % de INE (vs 77–80 %)**: en 2022 el raking se hizo contra totales **regionales urbanos** completos; en 2024, contra "la suma de las comunas en la muestra". Es decir, los pesos de 2022 representan un universo más grande que los de 2024. El propio informe 2022 muestra el salto: población estimada 12–64 de 10,89 M (2020) a **12,47 M** (2022).

Qué significa para nosotros:

1. Para **prevalencias** (razones), un universo más grande no cambia por sí solo el promedio; sí lo cambia la compresión de los pesos, porque redistribuye el peso relativo entre encuestados. El efecto puede ser pequeño, pero es medible: recalcular la prevalencia 2022 con pesos *sin* calibrar (si `factoresdeexpansion.dta` los trae) y ver cuánto se mueve.
2. **2020 es la ola con más riesgo de no comparabilidad de medición** (teléfono, sin autoaplicación, preguntas refraseadas), no 2022. Eso refuerza el análisis de sensibilidad que ya hicimos (con/sin 2020).
3. **El cambio de marco muestral en 2022** (de manzanas 2015 a viviendas 2020) es un quiebre de serie legítimo: distinta cobertura de viviendas nuevas, distinta estratificación.

Si quieres formularlo como pregunta a SENDA/INE, esta es la versión corta:

> "¿Los factores de expansión de la ENPG 2022 fueron calibrados a los totales regionales urbanos completos de las proyecciones INE (12,94 M personas de 12–65), mientras que los de 2024 lo fueron a la suma de las comunas en muestra (11,40 M)? ¿Está disponible el factor de expansión previo a la calibración para 2020, 2022 y 2024? ¿Qué umbral de truncamiento se aplicó en el suavizado de cada ola?"

---

## 13. "¿Y si en vez de cortes sucesivos hago validación cruzada por grupos edad–sexo?"

Se puede, pero responde a **otra pregunta**. Hay que tener claro cuál:

- **Cortes sucesivos (lo hecho)** responden: *"si sólo conociera hasta el año X, ¿cuánto erraría el año X+2?"* Es la pregunta de proyección. Es la única que dice algo sobre el futuro.
- **Validación cruzada por celdas** (dejar fuera una celda sexo × edad, ajustar con las otras siete, predecir la que falta) responde: *"¿cuánto se parecen las celdas entre sí?"* o, para `spline_shared`, *"¿la curva compartida que estimo con siete celdas sirve para la octava?"*. Es una pregunta de **préstamo de información entre grupos**, no de tiempo.

Para tres de las cuatro curvas ni siquiera aplica: `static2012`, `interp_hold` y `linear_all` se ajustan celda por celda y no usan nada de las otras celdas; dejar fuera una celda no deja nada con qué predecirla. Sólo `spline_shared` (intercepto por celda + curva común) comparte información, y ahí sí tendría sentido: dejar una celda fuera, estimar la forma temporal con las otras siete, y ver si esa forma le sirve. Es barato (todo al nivel de drivers, sin simular), y lo puedo agregar como celda al notebook si te interesa.

Lo que **no** haría es reemplazar los cortes temporales por eso: la pregunta de ACC es "¿qué pasa después de 2024?", y una celda que se predice bien desde sus vecinas en 2018 no dice nada sobre 2026.

**"Predecir 2022 es realmente difícil por lo visto."** Sí, y el resultado clave es más fuerte que "difícil": ninguna regla que use sólo datos hasta 2020 acierta 2022 salvo la que ya venía doblando hacia abajo desde 2014, y esa misma falla en 2020 y se cae al quitar la ola 2020. Las prevalencias marginales no contienen una señal estable de dirección más allá de una ola. Por eso la propuesta es hold-last como escenario central y etiquetar todo lo posterior a 2024 como condicional.

---

## 14. "¿Por qué en 3e dices 'calibración reproducida, no validación'? ¿Qué falta?"

Porque el 0,5 % de error en prevalencia y el 0,11 g/día en intensidad se obtienen comparando la simulación **con los mismos siete puntos que se usaron para construirla**. `interp_hold` pasa por definición por cada valor de la ENPG; el motor reproduce esos valores salvo ruido de Monte Carlo. Que coincidan demuestra que el motor hace lo que dicen las ecuaciones, no que las ecuaciones describan a Chile.

Es como ajustar una recta a dos puntos y decir que la recta "predice" esos dos puntos.

Qué faltaría para hablar de validación, en orden de valor:

| Qué | Qué validaría |
|---|---|
| Una ola nueva (2026) no usada en nada | Proyección a una ola (la regla elegida) |
| Encuesta independiente con la misma definición de "bebió en los últimos 30 días" (ENS, CASEN si tienen el ítem) | Nivel de prevalencia e intensidad fuera de la ENPG |
| Ventas / APC | Volumen total (previo puente, pregunta 11) |
| Cualquier dato longitudinal (panel, cohorte, historia retrospectiva de inicio/abandono) | `rho`, historias nunca/ex, transiciones |
| Mortalidad por causa con RR | El vínculo consumo → muerte, cuando exista |

Lo que sí es validado hoy, y vale decirlo: el motor (contabilidad, edad, identidades) y la concordancia de mortalidad total con DEIS (que es concordancia, no independencia, porque HMD y DEIS vienen del mismo registro).

---

## 15. "¿Por qué dices que los `rho` no están identificados?"

"Identificado" quiere decir: los datos pueden distinguir un valor de otro. `rho` **no** está identificado por encuestas transversales porque dos mundos con `rho` distinto producen exactamente los mismos datos de ENPG.

Ejemplo con números redondos. Población de 100 hombres de 30–44; la ENPG dice 50 % bebió el último mes, en 2018 y en 2020.

- **Mundo A (`rho = 1`)**: los mismos 50 beben siempre; los otros 50 nunca.
- **Mundo B (`rho = 0`)**: cada año se sortea al azar quién bebe; en 2020, 25 de los que bebían en 2018 siguen y 25 nuevos empiezan.

Encuesta 2018 en A: 50 %. En B: 50 %. Encuesta 2020 en A: 50 %. En B: 50 %. Intensidad, HED, todo igual. **No hay ninguna tabla de la ENPG que sea distinta entre A y B.** Por lo tanto los datos no pueden decir cuál mundo es el verdadero, y cualquier `rho` que elija ajusta la encuesta igual de bien. Eso es no identificación.

Lo único que distingue A de B es entrevistar **a la misma persona dos veces**. Por eso la tabla de "información adicional" pone el panel/cohorte primero. Y por eso `rho = 0,8` está etiquetado como supuesto de trabajo y se reporta con sensibilidad, no como estimación.

Consecuencia práctica: cualquier resultado que dependa de historias individuales (cuántos nunca bebieron, cuántos son ex-bebedores de largo plazo, cuánto tarda un beneficio en aparecer) hereda esa incertidumbre, y la única forma honesta de mostrarla es correr el modelo con varios `rho`, que es lo que hace la tabla de la pregunta 9.

---

## Resumen de acciones que salen de estas respuestas

1. Revisar `enpg2020.RDS` / `factoresdeexpansion.dta` por variables de conglomerado (2020) y pesos pre-calibración (2020/2022/2024). Sí/no, 20 minutos.
2. Tabla ola × pregunta × umbral para HED y recencia, desde los cuestionarios en `__enpg/`.
3. Decisiones escritas: definición de ex-bebedor, definición de HED, puente APC (a–e).
4. Extender el motor a 66–70 con cola cerrada (cuando exista el vínculo mortalidad–consumo, o antes si quieres probar la demografía).
5. Multiplicador de mortalidad por año, etiquetado como calibración.
6. Opcional: celda de validación cruzada por celdas para `spline_shared`, si te sirve para el argumento de préstamo entre grupos.


---

# Addendum (20-sep-2026, noche): cruce con tu `enpg_2012_2024_revision_metodologica.json`

Leí tu revisión completa. Es más completa que lo que saqué de los PDF y corrige/precisa tres cosas de arriba. Además, con los archivos locales pude **cerrar dos de tus verificaciones pendientes de prioridad 1** y correr tu control de calidad. Todo lo de esta sección se verificó hoy con código (`Rscript`) sobre los archivos del repo; no hay nada de memoria.

## A. Tus pendientes de prioridad 1: qué se cierra

| Tu ítem | Resultado | Fuente |
|---|---|---|
| Marginales de calibración 2022: ¿población regional total o urbana de 109 comunas? | **Regional urbana completa** (no restringida a las 109 comunas). El informe 2022 dice "el ajuste o ponderación se realiza a nivel regional urbano". Evidencia numérica: la suma de pesos 15–65 de 2022 es el **91,1 %** del stock INE nacional 15–65 (junio 2022); la proporción urbana de Chile es ~87,8 % (Censo 2017). En 2020 y 2024 esa razón es 78,9 % y 78,5 %, coherente con "109 comunas ≈ 70–80 % de la población". | `ENPG-2022.pdf` p. 20; `microsim_recalib_outputs/wave_comparability_audit.csv` |
| Marco y marginales de calibración 2024 | **MMV 2021** (actualización del MMV 2020, Censo 2017); 100 % CAPI; 8 ajustes iguales a 2022; raking con referencia **30-mar-2025**; marginales nacionales por sexo × 3 tramos, y regionales **"para la suma de las comunas en el estudio"**. Suma antes/después de calibrar: 10.358.624 → 11.396.772. Cobertura del marco 86,4 % viviendas / 86,2 % UPM (idéntica a 2022). | `__enpg/enpg2024.pdf` pp. 10–11, 22 |
| ¿Existe ESTRATO en la base 2022? | **No.** Entre las 382 variables, las únicas de diseño son `FACTOR_EXPANSION` (13.562 valores distintos) y `UPM` (2.654 UPM). Ninguna variable de baja cardinalidad se llama o se comporta como estrato. Conclusión igual a la tuya: `strata = COD_COMUNA`, que es el estrato por definición del diseño 2022. | `__enpg/enpg2022.RDS` |
| (prioridad 2) 2020 sin conglomerado | Confirmado. La única variable con nombre sugerente es `seccion`, con **10 valores distintos** en 16.662 casos: es un código de sección del cuestionario, no una UPM. | `__enpg/enpg2020.RDS` |
| `factoresdeexpansion.dta` (2016) | 19.147 filas × 2 columnas: `idencuesta`, `Fexp`. Tiene identificador, así que el merge es por `idencuesta`, no por orden de fila. La caché de diseño del proyecto ya lo une así (verificado al 100 % en el notebook base). | `__enpg/factoresdeexpansion.dta` |

Con esto, el zigzag de universos que señalas (11,16 M → 12,94 M → 11,40 M) queda explicado por completo: **2022 calibró a la población urbana regional entera; 2020 y 2024, a las comunas en muestra.** No es demografía, es el vector de marginales.

## B. Tu control de calidad: la serie publicada se reproduce desde nuestros microdatos

Prevalencia de alcohol último mes, ponderada, **12–64 años**, calculada desde `ENPG_BINGE.RDS` + pesos de la caché de diseño (los mismos objetos que alimentan la microsimulación):

| Ola | Reproducida 12–64 | Publicada (ficha 2024) | Diferencia | Suma de pesos (caché) | Universo publicado |
|---:|---:|---:|---:|---:|---:|
| 2012 | 41,0 | 40,8 | +0,2 | 9.940.512 | 9.940.512 ✓ |
| 2014 | 49,2 | 48,9 | +0,3 | 10.088.222 | 10.088.247 (versión RND) |
| 2016 | 46,4 | 46,0 | +0,4 | 10.356.863 | 10.356.863 ✓ |
| 2018 | 43,9 | 43,3 | +0,6 | 10.992.349 | 10.992.349 ✓ |
| 2020 | 44,5 | 44,3 | +0,2 | 11.159.046 | 11.159.046 ✓ |
| 2022 | 39,4 | 39,2 | +0,2 | 12.941.545 | 12.941.545 ✓ |
| 2024 | 34,8 | 34,6 | +0,2 | 11.396.772 | 11.396.772 ✓ |

- Las siete olas se reproducen dentro de 0,2–0,6 puntos. El sesgo pequeño y siempre positivo viene de que yo excluyo el estatus desconocido (0,5–1,8 % por ola) y SENDA probablemente lo cuenta como "no bebió". No hay problema de ponderador ni de población analítica.
- 2014: la caché usa el peso **sin redondear** (`F2_MAY_AJUS_com`, suma 10.088.222) y no el `RND_` (10.088.247). Diferencia de 25 personas; irrelevante para proporciones, pero si alguna vez se reportan totales 2014, hay que cambiar a la versión RND. Lo dejo anotado.
- Con 12–65 (nuestra población del modelo) los valores bajan 0,2–0,4 puntos respecto de 12–64, como esperabas: los de 65 beben menos.

**Embriaguez entre bebedores del mes** (publicado 52,1 / 43,7 / 51,1 / 56,3 / 50,2 / 50,7 / 47,2): con nuestro indicador `db > 0` obtengo 55,0 / 49,9 / 53,7 / 60,4 / 53,2 / 53,4 / 50,1, es decir **3–6 puntos más alto** en todas las olas. Dos causas, ambas identificables: (i) `db` falta en 3,8–8,5 % de los bebedores y yo lo excluyo, mientras SENDA lo cuenta como "no"; al imputar "no" la diferencia baja a ~1–2 puntos; (ii) la definición oficial es 5+ tragos hombres / **4+ mujeres**, y hay que confirmar contra el cuestionario que `db` use ese umbral por sexo. Esto entra directo en el ítem "calibrar HED" de la pregunta 11: antes de calibrar hay que fijar la definición.

## C. Correcciones a mis respuestas de arriba

1. **Sección 12, tabla**: "raking contra totales regionales urbanos completos" queda confirmado para 2022; para 2024 el texto oficial es "para la suma de las comunas en el estudio". Fecha de referencia 2024: 30-mar-2025 (no la tenía).
2. **Sección 12, fila "Marco muestral"**: tu revisión precisa lo que yo resumí mal: hasta 2020 la UPM es la **manzana** y el estrato es comuna × grupo de tamaño de manzana; desde 2022 la UPM es un **área de ~200 viviendas** y el estrato es la comuna. Consecuencia que yo no había dicho: los DEFF de 2018 y 2022 no son comparables, y las variables de diseño no deben mezclarse entre regímenes. En el notebook cada ola se declara por separado, así que no hay mezcla; pero sí hay una mejora pendiente (punto D).
3. **Sección 6**: mi "20 minutos de exploración" para 2020 ya se hizo: no hay conglomerado. Queda como está (pesos solamente, limitación declarada) o se pide a SENDA/INE por el canal que documentas.
4. **Sección 12, "tasa de logro 75,1 %"**: tu revisión aporta la tasa AAPOR real, **TRR1 = 45,0 %**. Para cualquier manuscrito se reporta esa, no el "nivel de logro".
5. **Erratum del informe 2022** (p. 7 dice terreno nov-2023–may-2024): lo detectaste tú; yo cité las fechas correctas (nov-2022–may-2023) sin haber notado la errata. Queda registrado para no citar la p. 7.

## D. Qué cambia para los notebooks (propuesta, no aplicado)

Los notebooks usan la caché de diseño con `strata = region` como aproximación para 2012–2022 y `ESTRATO` en 2024. Tu tabla de declaraciones de diseño es mejor y está disponible con los campos que ya tiene la caché (`commune`):

| Ola | Ahora en el notebook | Propuesta (tu revisión) | Efecto |
|---|---|---|---|
| 2012–2018 | `ids = psu, strata = region` | `strata = comuna` (aprox. conservadora del estrato real comuna × tamaño) | IC algo más estrechos y más correctos |
| 2020 | pesos sin conglomerado | igual; declarar limitación (o comuna como pseudo-PSU como cota superior) | ninguno |
| 2022 | `ids = psu (UPM), strata = region` | `strata = COD_COMUNA` — **es el estrato exacto**, no una aproximación | IC correctos por definición |
| 2024 | `ids = UPM, strata = ESTRATO` | igual | ninguno |

Es un cambio de una línea en la celda `ms-survey-inputs` (`stratum = commune` en vez de `region` para 2012–2022). Cambia sólo errores estándar y, por tanto, los pesos de calibración (inversa de la varianza) y la cobertura de intervalos; **no cambia las prevalencias ni la reconstrucción**. Como toca un `.ipynb`, no lo aplico sin que me lo pidas.

Otras dos implicancias de tu revisión que adopto como reglas del modelo:

- **Usar siempre proporciones ponderadas, nunca conteos expandidos** (tu advertencia transversal). Ya es así: la microsimulación toma prevalencias e intensidades por celda y escala la población con INE, no con la suma de pesos. Por eso el salto de universo 2022 **no entra** al modelo.
- **Universo del modelo**: la ENPG es urbana de 109 comunas (~70–80 % de la población), pero el motor reconcilia contra el stock INE **nacional** 15–65. Eso equivale a asumir que el consumo rural y de comunas pequeñas es igual al urbano muestreado. Es exactamente el supuesto que 2022 hace de facto en sus pesos y las demás olas no. Hay que declararlo en el notebook y, si se quiere relajar, imputar el segmento rural con ENS/CASEN como propones.

## E. Ítems que tu revisión resuelve y mi lista de acciones ya no necesita

- Acción 1 (variables de diseño 2020 / pesos pre-calibración): **hecha**, resultado negativo para 2020; los pesos pre-calibración no vienen en ninguna base pública (sólo la suma antes/después en los informes 2022 y 2024).
- La pregunta para SENDA/INE que redacté en la sección 12 se puede acortar a una sola: *"¿pueden entregar el estrato de muestreo exacto (comuna × grupo de tamaño de manzana) para 2012–2020 y el identificador de UPM para 2020?"* Lo demás ya está respondido por los informes.


---

# Addendum 2 (21-sep-2026): preguntas del 21-sep

Formato: la respuesta va en la primera línea, en negrita. Después, sólo lo necesario para actuar. Los números de la EPS vienen de `eps_alcohol_prevalencia_persistencia.ipynb` (ejecución local del 21-sep); los de λ y φ los calculé hoy a partir de esas correlaciones.

## 16. Persistencia (`rho`): ¿hay un valor publicado? ¿Cómo paso de 2 años a 1? ¿Qué hace JRT?

**Corto: no hay un "rho = X" publicado para un motor como el tuyo. Tu mejor evidencia es tu propia EPS, y dice: 0,8 anual está bien para el año a año, pero el AR(1) puro "olvida" demasiado a 10 años.**

### 16a. Lo que dice tu EPS (50+, bebe sí/no)

| Lapso entre entrevistas | r latente (tetracórica) | rho anual si fuera AR(1) puro |
|---|---:|---:|
| VI → VII (3,7 años) | 0,546 | 0,848 |
| VI → VIII (7,7 años) | 0,485 | 0,910 |

Si el AR(1) puro fuera correcto, la última columna daría lo mismo en las dos filas. No da lo mismo. Y en las mismas 1.744 personas, r(7,7 años) = 0,478 es **mayor** que r(3,7) × r(4,0) = 0,333.

Traducción: cada persona tiene una **parte estable** (hay gente que casi nunca bebe y gente que casi siempre bebe) más una **parte que cambia** año a año.

### 16b. El modelo que sí calza: rasgo estable + AR(1)

`Z = √λ·U + √(1−λ)·A`: `U` es fijo por persona; `A` cambia con autocorrelación `φ` por año. Ajustado a tus números EPS:

| Ajuste | λ (parte estable) | φ (por año) | r a 1 año | r a 10 años |
|---|---:|---:|---:|---:|
| Paneles completos (VI→VII y VI→VIII) | 0,48 | 0,58 | 0,78 | 0,48 |
| Mismas 1.744 personas (3 entrevistas) | 0,45 | 0,68 | 0,82 | 0,46 |
| **Tu motor hoy** (AR(1) puro, rho = 0,8) | 0 | 0,80 | 0,80 | **0,11** |

- A 1 año casi no hay diferencia con tu 0,8.
- A 10 años tu motor supone que casi nadie "recuerda" su pasado (0,11); la EPS dice ≈ 0,47. Diez años es justo tu horizonte de políticas, y esto explica por qué la simulación deja tan pocos "nunca bebió" en 2024 (6,1 %, §9).
- Por sexo el ajuste es inestable (hombres λ ≈ 0,31, φ ≈ 0,77; en mujeres no se separa). Usar el conjunto.
- Cautelas: sólo 50+; la pregunta F13 de la EPS no tiene plazo (no es "últimos 30 días"); el error de medición baja las correlaciones (la parte estable real probablemente es mayor); selección de sobrevivientes. Son **órdenes de magnitud**, no parámetros finales.

### 16c. Cómo pasar de 2 años a 1 año

| Si trabajas con… | Conversión correcta | Qué NO hacer |
|---|---|---|
| Correlación, AR(1) puro | rho₁ = rho₂^(1/2) | — |
| Correlación, rasgo + AR(1) | Hacen falta **dos lapsos distintos** para separar λ de φ (la EPS los tiene: 3,7 y 7,7 años) | Anualizar con un solo lapso |
| Matriz de transición | Raíz de la matriz, o mejor un **Markov en tiempo continuo** (`msm`): acepta intervalos distintos por persona y da P(1 año) = exp(Q) | Elevar cada probabilidad a 0,5 por separado |

### 16d. Qué hace JRT (según el plan del 17-sep y sus scripts)

1. **Pseudo-panel por *rank matching*** entre olas ENPG (2012→2014→…→2022): la persona en la posición k de una ola se empareja con la posición k de la siguiente. Eso es **asumir** la máxima persistencia compatible con las marginales (cota superior de Fréchet), no estimarla.
2. **`polr`** sobre esas parejas t → t+2.
3. **Anualización con α = 0,5** en log-probabilidades (`run_simulation_alcohol`).

Test de 30 min para el paso 3 (Chapman–Kolmogorov): toma su matriz anual `A` y la de 2 años `P2` de una celda; calcula `A %*% A`. Si alguna entrada difiere de `P2` en más de 0,02, la anualización está sesgada.

Ejemplo numérico (2 estados, `P2` = [0,81 0,19; 0,10 0,90]):

| Método anual | Permanencia anual (fila 1) | Aplicado 2 veces | ¿Reproduce 0,81? |
|---|---:|---:|---|
| α = 0,5 a **cada** probabilidad y renormalizar | 0,67 | 0,54 | No: demasiado cambio |
| α = 0,5 sólo a la diagonal (resto repartido en proporción) | 0,90 | 0,815 | Casi (con 3 estados el error sube a ~0,02) |
| Raíz de la matriz | 0,90 | 0,81 | Sí, exacto |

No sé cuál de las dos primeras usa `run_simulation_alcohol`: el test lo dice.

### 16e. SIMAH / Kilian 2025

El paquete vendorizado (`SIMAH/supp/`) trae `transition_alcohol_ordinal_regression` y `update_former_drinker`. No afirmo de memoria qué panel ni qué conversión anual usan: lo verifican la búsqueda lanzada hoy y el prompt de §25. Atajo de 10 min: abrir esos dos archivos y buscar `interval`, `annual`, `msm`, `sqrt`, `^0.5`, `expm`.

### 16f. Qué usar ya

Cambiar `z_current` a rasgo + AR(1). No cambia umbrales ni prevalencias (Z sigue siendo N(0,1)). Con λ = 0 vuelve exactamente a tu motor actual.

- Partida: **λ = 0,45; φ = 0,65**.
- Sensibilidad: λ ∈ {0; 0,3; 0,45; 0,6} × φ ∈ {0,6; 0,7; 0,8}.
- Elegir el par que reproduce las **tres metas** de §17 a la vez.

```r
# Trait + AR(1) latent propensity. Z stays N(0,1), so cell thresholds are unchanged.
# lambda: share of stable (trait) variance, 0 <= lambda < 1. phi: annual carryover of the transient part.
init_latent <- function(z, lambda) {
  # z: initial draw already consistent with the observed 2012 status (as the engine does now)
  u <- sqrt(lambda) * z + sqrt(1 - lambda) * stats::rnorm(length(z))  # stable trait
  a <- (z - sqrt(lambda) * u) / sqrt(1 - lambda)                       # transient part, independent of u
  list(u = u, a = a)
}
step_latent <- function(u, a, lambda, phi) {
  a <- phi * a + sqrt(1 - phi^2) * stats::rnorm(length(a))
  list(u = u, a = a, z = sqrt(lambda) * u + sqrt(1 - lambda) * a)
}
# Drinking rule unchanged: drinks <- stats::pnorm(z) < p_cell
# New entrants (age 15): draw z consistent with their observed status, then call init_latent().
```

---

## 17. ¿Basta con que rho reproduzca una proporción realista de "nunca bebedores"?

**Corto: es necesario, no suficiente. Es tu mejor ancla dentro de la ENPG, pero hay que usarla junto a otras dos metas.**

Por qué ayuda: la ENPG sí pregunta "¿ha tomado alcohol alguna vez en su vida?" (`OH_1`). El % de nunca bebedores por sexo × edad es un dato **observado** y depende de cuánta gente cruza el umbral al menos una vez → informa sobre la parte estable (λ).

Por qué no basta:

1. Informa del paso nunca → alguna vez; no de dejar o volver a beber, ni de volumen o HED.
2. La abstinencia de por vida autodeclarada es inestable en paneles (hay quienes "olvidan" que bebieron; Rehm et al. 2008, *Am J Epidemiol*; verificar con §25).
3. Un solo número agregado es débil: hay que calzarlo por sexo × edad.

**Argumento defendible = tres metas a la vez:**

| Meta | Fuente | Qué ancla |
|---|---|---|
| % nunca bebió, por ola × sexo × edad | ENPG `OH_1` (observado) | λ e inicio |
| % ex-bebedor (> 12 meses sin beber), por ola × sexo × edad | ENPG `OH_4` (observado) | salida del consumo |
| r entre entrevistas a 3,7 y 7,7 años, 50+ | EPS (ya calculado) | λ y φ |

Primer paso (20 min): calcular el % observado de "nunca bebió" ENPG 2012 y 2024, 15–65, por sexo × tramo, y ponerlo al lado de la tabla de §9 (1,7 / 6,1 / 12,6 %).

- Si ENPG 2024 cae cerca de algún valor → ese rango de persistencia es plausible.
- Si queda muy por encima de 12,6 % → el problema no es el valor de rho sino la **estructura**: hoy nunca bebedores y ex-bebedores comparten el mismo Z, y un abstemio de toda la vida empieza a beber mucho menos que un ex que recae. Arreglo (v0.5, octubre): módulo de inicio propio para nunca bebedores, con la edad del primer consumo de la ENPG (`OH_3`) por cohorte.

Encargo listo para Claude Code / Codex:

> Con los mismos objetos que reprodujeron la serie SENDA (addendum 1, tabla B: `ENPG_BINGE.RDS` + pesos de la caché de diseño), calcula por ola × sexo × tramo (15–29, 30–44, 45–59, 60–65) la proporción ponderada de `cvolaj == "ltabs"` y la de "última vez que bebió hace más de un año", con IC 95 % de diseño. Exporta `targets_never_former.csv`. No edites notebooks existentes; crea un script nuevo en `__andres_control/`.

---

## 18. Mayores de 55–65: ¿qué tomo de fuera de la ENPG?

**Corto: de la EPS, la forma por edad y la persistencia; de la ENPG, el nivel.**

1. **Nivel 66–70 y 71–76 (puente por razón):** `p_ENPG(66–70) = p_ENPG(60–65) × p_EPS(66–70) / p_EPS(60–65)`, por sexo, con EPS VIII y ENPG 2024 (o lo mismo en escala logit). Así no mezclas la pregunta EPS (sin plazo) con la ENPG (30 días): la EPS sólo dice cuánto baja con la edad.
2. **Persistencia 50+:** λ ≈ 0,45; φ ≈ 0,6–0,7 (§16).
3. **Mortalidad 66–76:** tasas DEIS/INE (§21).
4. **Calvo et al. 2021** sirve para justificar la caída del consumo con la edad (22 países, transversal); no estima rho.

Dato EPS VIII (consumo declarado): hombres 36,8 % (66–70) y 36,8 % (71–76); mujeres 20,4 % y 14,8 %.

---

## 19. "El error va de −3,1 % (2012) a +3,8 % (2024), monótono: ¿es sistemático?"

**Corto: sí. Un error aleatorio no sube parejo 13 años seguidos. Es una deriva de ~0,6 puntos por año entre los insumos del modelo (qx de HMD × población INE) y los conteos DEIS. El multiplicador único sólo la centra.**

Qué sesga: el nivel de muertes de cada año (± 3–4 %) y, por lo tanto, las muertes y YPLL evitados **en números absolutos**. Las comparaciones relativas entre escenarios casi no se afectan (el sesgo es común a todos).

Causas candidatas (ninguna verificada):

1. **Denominadores de distinta vintage:** la población INE base Censo 2024 que usa el motor vs la exposición con la que HMD calculó sus qx.
2. **DEIS 2024 incompleto** (archivo de junio 2026): explica sólo el último año, no la pendiente desde 2012.
3. **Edad al 1 de enero** vs edad al morir: produce más bien un sesgo de nivel que de tendencia.

**Diagnóstico de 30 min** (por año 2012–2024, por sexo, 15–65):

- `población INE / exposición HMD` (HMD `Exposures_1x1`)
- `muertes HMD / muertes DEIS` (HMD `Deaths_1x1`)

Si el primer cociente cambia con el tiempo y el segundo es ≈ 1 → la causa es (1). Si el segundo cambia → numeradores distintos.

**Arreglo:** tasas con las **mismas fuentes** que usa el modelo: muertes DEIS / población INE (§21). La deriva desaparece por construcción; declararlo como insumo calibrado, no como validación.

Encargo listo para Claude Code / Codex:

> Con HMD Chile (`Exposures_1x1`, `Deaths_1x1`), INE (`__andres_control/ine_proyecciones_rebuild`) y DEIS `DEFUNCIONES_FUENTE_DEIS_2024_2026_15092026.parquet` (los dos filtros de §8), calcula por año 2012–2024 y sexo, 15–65: (a) población INE a mitad de año / exposición HMD; (b) muertes HMD / muertes DEIS; (c) muertes DEIS 2024 en el archivo 09-06-2026 vs 15-09-2026. Exporta `mortality_input_diagnostic.csv` y una figura de (a) y (b) por año. No edites notebooks.

---

## 20. ¿El patrón de errores es sistemático en general? ¿Lo arregla otra fuente o jerarquías espaciales?

**Corto: hay dos errores sistemáticos distintos y ninguno se arregla con jerarquías espaciales. Otra fuente sirve para confirmar, no para arreglar.**

| Error | Patrón | Tipo | Qué lo arregla |
|---|---|---|---|
| Mortalidad total | −3,1 → +3,8 %, monótono | Deriva de insumos | Insumos coherentes DEIS/INE (§19, §21) |
| Prevalencia proyectada (entrena 2012–2020, predice 2022–24) | 16/16 celdas sobreestimadas, +9,75 pts | Quiebre de período común a todas las celdas | No extrapolar tendencia (hold-last) + confirmar el quiebre con otra fuente |
| Intensidad g/día | 12/16 dentro del IC, RMSE 1,08 | Sin patrón claro | Nada urgente |

**Jerarquías espaciales:** un modelo jerárquico (región o comuna) presta información entre celdas y **achica la varianza** de las celdas chicas. No corrige un sesgo que comparten **todas** las celdas a la vez (en 2022–24 bajan todas). Útil en 2027 sólo si necesitas resultados o políticas por región (densidad de locales, horarios).

**Otra fuente, para confirmar el quiebre 2022–24:**

1. EPS VI (2016) → VIII (2023–24), 18–65: si también baja, la caída ENPG es real y no un efecto del cambio de marco muestral de 2022. Ya está en `eps_alcohol_outputs/prevalence_age_sex.csv` (comparar tendencias, no niveles).
2. Consumo registrado per cápita OMS (APC) 2012–2024: dice si el volumen total también bajó.
3. Si la caída viene de cohortes jóvenes que beben menos, hold-last por celda sobreestima el futuro (no ve envejecer a esas cohortes). Una proyección por cohorte lo captaría. Decisión de octubre, no de v0.

---

## 21. HMD vs DEIS: ¿cuál uso? ¿Sirven el Lexis o `ine_proyecciones_rebuild`?

**Corto: DEIS (archivo 15-09-2026) como numerador e INE como denominador. HMD queda como control. El Lexis es opcional.**

HMD no es más "oficial": es una base académica (Max Planck / Berkeley) que reprocesa datos oficiales con métodos estándar. Las fuentes oficiales chilenas son DEIS (muertes) e INE (población). La ventaja de HMD es la comparabilidad internacional y el tratamiento de edades muy altas, que tu rango 15–76 casi no necesita.

| Insumo | Uso | ¿Necesario? |
|---|---|---|
| DEIS `..._15092026.parquet` | Muertes por sexo × edad simple × año, 2012–2024. 2025 (provisional) sólo como chequeo | Sí |
| INE (`ine_proyecciones_rebuild`) | Población a mitad de año 2012–2034 (denominador). Si trae muertes proyectadas por edad, úsalas para qx 2025–2034 coherentes con INE | Sí |
| HMD `Deaths_1x1`, `Exposures_1x1` | Diagnóstico §19 y control externo | Control |
| HMD `Deaths_lexis` | Pasar de "edad al morir" a "edad al 1 de enero" (la que usa tu motor) | Opcional. Alternativa simple: usar q en x + 0,5 ≈ promedio de q(x) y q(x+1) |

Cálculo: `m(x,t) = muertes_DEIS(x,t) / población_INE_mitad_de_año(x,t)`; `q(x,t) = m / (1 + 0,5·m)`.

Chequeo de vintage (15 min): contar muertes 2024 en el archivo 09-06-2026 y en el 15-09-2026. La diferencia son inscripciones tardías; anótala y fija **un** archivo en el manifiesto, con su fecha.

Extra: DEIS 2025 provisional sirve como **primera validación fuera de muestra** de la proyección (año 2025), marcada como provisional.

---

## 22. ¿Qué es el "QC"? ¿Qué pasó en 2014 con "25 personas"? ¿De dónde sale "embriaguez"?

**QC** = *quality control*, control de calidad: recalcular con tus microdatos y pesos la prevalencia que publica SENDA y ver si da lo mismo. No es un test estadístico. Resultado: las 7 olas dan dentro de 0,2–0,6 puntos → población analítica y pesos correctos.

**2014, "25 personas": nadie entró ni salió.** La base 2014 trae dos versiones del mismo peso:

| Variable | Qué es | Suma |
|---|---|---:|
| `F2_MAY_AJUS_com` | Peso con decimales (el que usa tu caché) | 10.088.222 |
| `RND_F2_MAY_AJUS_com` | El mismo peso redondeado a entero (el que usa SENDA para el total publicado) | 10.088.247 |

Al redondear 20.113 pesos, la suma sube 25 personas **expandidas** (población representada), no 25 encuestados. Para porcentajes da igual. Sólo importa si algún día reportas **totales** de 2014: ahí usa la versión RND.

**"Embriaguez":** es el nombre que usa SENDA en sus informes para su indicador de consumo intenso en una ocasión entre quienes bebieron en el último mes (según la ficha, 5+ tragos hombres / 4+ mujeres; confirmar en los cuestionarios). Aparece porque se usó como segundo QC: comparar tu `hed = db > 0` con esa cifra publicada. Tu indicador da 3–6 puntos más por dos razones: (1) los faltantes de `db` (3,8–8,5 % de los bebedores) se excluyen en vez de contarse como "no"; (2) falta confirmar el umbral por sexo en las 7 olas. Por eso "definir HED" va antes de "calibrar HED".

---

## 23. Estrato = comuna: ¿genera discrepancias con expand_pif y con JRT?

**Corto: no en estimaciones puntuales (prevalencias, AAF, PIF, muertes atribuibles, YPLL). Sí en los intervalos. El riesgo real es tener dos declaraciones de diseño distintas en dos módulos.**

| Qué | ¿Cambia con estrato = comuna? |
|---|---|
| Prevalencias, AAF, PIF, muertes, YPLL (puntuales) | No: el estrato no entra en la media ponderada |
| EE, IC 95 %, draws de incertidumbre | Sí: IC algo más estrechos (y más correctos) |
| Pesos de calibración de la microsim (inversa de la varianza) | Sí, un poco |
| Diferencia con JRT | Ya existe desde julio: según el guion del 16-sep, la corrección de diseño (Kish + conglomerado) es parte de tu rehecho, no del código heredado. Estrato = comuna no agrega diferencias en puntuales |

Regla: **una sola declaración de diseño por ola**, en `build_enpg_design_waves_2012_2024_list.R`, y que expand_pif y la microsim la lean de ahí.

Verificación de 1 min (PowerShell, raíz del proyecto):

```powershell
Get-ChildItem -Recurse -Include expand_pif*.ipynb, microsim*.ipynb | Select-String -Pattern "svydesign|strata|Kish" | Select-Object Path, LineNumber
```

Si expand_pif no declara estratos (sólo Kish + conglomerado), no hay nada que cambiar ahí. Lista completa de cambios a expand_pif, con impacto: `expand_pif_cambios_hallazgos_2026-09-21.md`.

---

## 24. Factor OMS (APC) en un modelo por ciclos: ¿por qué ACC dice "no para calibrar, tal vez sí para mortalidad"?

**Corto: porque son dos pasos distintos. El motor simula conducta y se calibra contra la encuesta; el factor OMS corrige la exposición y sólo importa donde el consumo se convierte en riesgo (RR). ACC tiene razón.**

1. **Calibración del motor:** las metas son prevalencias y g/día por celda de la ENPG. Si inflas los g/día con el factor OMS antes de calibrar, calibras contra algo que la encuesta no midió y mueves gente entre categorías sin evidencia. Además, el APC es un total nacional 15+, sin sexo × edad: no puede ser meta por celda.
2. **Paso de mortalidad (RR):** la práctica estándar de AAF escala el consumo de encuesta hacia el APC antes de aplicar RR (p. ej. Rehm et al. 2010, *Popul Health Metr*; verificar). Ahí sí va el factor. expand_pif ya lo hace (`volajohdiams`).
3. **Políticas:** los efectos (IB −12,3 %, elasticidades) son cambios **porcentuales**: dan igual en escala encuesta o escala OMS.
4. **Proyección:** el factor es anual y no hay APC para 2025–2034 → se congela el último valor (declararlo).

Implementación: `g_riesgo = g_encuesta × factor_OMS(año)` **sólo** dentro de la función que calcula RR/AAF/PIF, y la categoría que usa el RR se recalcula con `g_riesgo`. El estado de la persona (g/día, categoría) queda en escala encuesta. Esto cambia la meta 5 del plan (§5): la intensidad se calibra **sin** factor OMS.

Chequeo pendiente en expand_pif (5 min): el denominador del factor debe ser g/día **per cápita** (abstemios y ex = 0), no la media entre bebedores. Si fuera la media entre bebedores, los g/día corregidos quedan 2–3 veces bajos y los AAF crónicos, subestimados. Código: `expand_pif_cambios_hallazgos_2026-09-21.md`, V1.

---

## 25. Prompt en inglés para Kimi y Gemini

Copiar tal cual en ambos. Está escrito para que no agreguen fuentes que no reporten el dato pedido y para que marquen lo que no pudieron verificar.

```text
ROLE
You are conducting a targeted, verifiable literature search for an alcohol-epidemiology microsimulation. Report only what you can confirm in the primary source. Precision beats coverage.

CONTEXT (defines relevance; do not search for it)
1. Model: individual-level, discrete annual-cycle microsimulation of alcohol use and alcohol-attributable mortality for Chile, ages 15-65 (extension to 76), calibration period 2012-2024, projections to 2034.
2. Data: repeated cross-sections only (Chilean National Drug Survey, ENPG, biennial, seven waves 2012-2024): past-30-day drinking, grams/day, heavy episodic drinking (HED), lifetime abstention, time since last drink. Cross-sections do not identify within-person persistence.
3. Drinking status: latent Gaussian propensity Z(t+1) = rho*Z(t) + sqrt(1 - rho^2)*e; a person drinks if Phi(Z) < the observed prevalence of their sex x age cell. Annual rho = 0.8 is currently an assumption.
4. Chilean panel evidence (Encuesta de Proteccion Social, EPS; adults aged 50+): tetrachoric correlation of current drinking = 0.55 over 3.7 years and 0.49 over 7.7 years. In the same respondents, r(7.7 y) = 0.48 exceeds r(3.7 y) x r(4.0 y) = 0.33, so a pure AR(1) does not fit and a stable between-person (trait) component is likely.

OBJECTIVE
Find peer-reviewed evidence to justify: (a) an annual persistence parameter or annual transition matrix for adult drinking status (secondarily, volume category and HED); (b) the method for converting multi-year panel intervals into annual cycles; (c) precedents for calibrating and validating such models against repeated cross-sectional surveys and mortality.

QUESTIONS (answer each one separately)
Q1. Empirical within-person persistence of drinking in adults. Which panel or cohort studies report year-to-year or multi-year stability of (i) current drinking vs. not drinking, (ii) volume categories, (iii) HED? Prioritize adults aged 50+ and biennial panels (e.g., HRS, ELSA, SHARE, PSID, NESARC, US National Alcohol Survey panels). Extract: statistic (transition probability, tetrachoric/polychoric correlation, ICC, kappa, autoregressive coefficient, random-intercept variance share), value, interval between measurements in years, country, survey, age range, sex.
Q2. How peer-reviewed alcohol microsimulation models derive annual transitions. Cover at minimum: SIMAH as used in Kilian et al., Lancet Public Health 2025 (doi:10.1016/S2468-2667(25)00165-3), including its supplementary appendix and archived code (doi:10.5281/zenodo.15641639); the Sheffield Alcohol Policy Model; CASCADEPOP (Brennan et al., International Journal of Microsimulation, 2020). For each model report: data source of the transitions, measurement interval, states, statistical model (e.g., ordinal or multinomial regression, continuous-time multistate Markov model), how annual probabilities were obtained, whether lifetime abstainers and former drinkers have separate transitions, and how transitions were calibrated and validated.
Q3. Methods to convert multi-year transition data to an annual cycle: generator estimation for continuous-time Markov chains, matrix p-th roots and their regularization, rate-to-probability conversion, with the conditions under which each fails. Also methods that separate stable between-person differences from within-person carryover (random intercept plus AR(1), trait-state models, mover-stayer models), preferably applied to alcohol or other substance use.
Q4. Calibration and validation precedents. Peer-reviewed alcohol simulation or Bayesian models calibrated to repeated cross-sectional survey targets (drinking prevalence, volume or intensity, HED, heavy drinking) and/or to mortality. Report: targets, goodness-of-fit metric, calibration algorithm (e.g., Nelder-Mead, IMIS, ABC, history matching), out-of-sample or holdout validation, and how non-identifiable parameters were handled. Use tobacco models only if no alcohol example reports the same element, and label them "tobacco analog".
Q5. Validity and stability of self-reported lifetime abstention and former drinking in longitudinal data (e.g., inconsistent reports across waves, age-related recall), to judge whether the proportion of never-drinkers can serve as a calibration target.

INCLUSION
Peer-reviewed journal articles; supplementary appendices, technical reports and code archives of peer-reviewed models. Published 1990-2026. English or Spanish.

EXCLUSION
News, blogs and websites without a peer-reviewed counterpart; preprints unless no peer-reviewed version exists (label them "preprint"); general reviews of alcohol harms; price-elasticity and policy-effect meta-analyses; adolescent-only samples (under 15 years); studies that do not report the requested quantity.

RULES
1. Every entry must include a DOI (or PMID, or the URL of the exact document) and the page, table or figure where the value appears.
2. Copy values exactly, with units and measurement interval. Do not annualize, convert or compute values yourself; if the source annualized, state how.
3. If a quantity is not reported, write "not reported". Never infer or estimate.
4. Label each parameter "estimated from data" or "assumed/calibrated".
5. If only the abstract is accessible, write "abstract only" and report no numbers absent from the abstract.
6. Verify these candidates first; do not assume their details are correct: Kerr, Fillmore & Bostrom 2002 (J Stud Alcohol; stability of alcohol consumption over time); Fillmore et al. 1991 (Br J Addict; meta-analysis of life-course variation in drinking); Rehm et al. 2008 (Am J Epidemiol; stability and validity of reported lifetime abstention); Chhatwal, Jayasuriya & Elbasha 2016 (Med Decis Making; changing cycle lengths in state-transition models); Jackson 2011 (J Stat Softw; msm package); Alarid-Escudero et al. 2018 (Med Decis Making; nonidentifiability in model calibration); Calvo et al. 2021 (Addiction; doi:10.1111/add.15292).

OUTPUT
A. One table per question, with columns: Citation (authors, year, title, journal, volume:pages) | DOI/PMID | Data source and country | Design and interval (years) | Ages/sex | Quantity reported (exact value, units) | Estimated vs assumed | Location in source | Relevance to this model (15 words max).
B. At most five bullet points: the defensible annual range for rho (or for trait share and annual carryover), the 2-3 strongest supporting sources, and the recommended annualization method.
C. A list of candidates you could not verify, with the reason.
Write in English.
```

---

## 26. Qué hacer ahora (en orden, con tiempo)

1. **20 min** — Metas ENPG: % nunca bebió y % ex (> 12 meses) por ola × sexo × tramo (encargo §17). Compararlas con §9.
2. **15 min** — DEIS: contar muertes 2024 en el archivo 09-06 vs 15-09 (§21).
3. **30 min** — Diagnóstico de dos cocientes INE/HMD y HMD/DEIS (encargo §19).
4. **2 h** — Rasgo + AR(1) en `z_current` + grilla λ × φ (§16f).
5. **5 min** — Pegar el prompt §25 en Kimi y Gemini.
