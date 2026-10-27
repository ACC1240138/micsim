# Ruralidad y consumo de alcohol: guía de las tablas

Cinco tablas exploratorias (octubre 2026) para la pregunta: **¿la ENPG está sesgada porque no cubre la población rural?**
Todas son agregadas (no hay filas por persona). Los números usan punto decimal.

Contexto común:

- La **ENPG 2024** define áreas urbanas de 109 comunas. Aquí las comunas con encuestados aproximan la lista del marco; ausencia no equivale a menos de 30.000 habitantes. El cálculo provisional homogéneo de **2024, 15–64 años**, da **21,95% excluido**: 17,62% en comunas no observadas (urbano + rural) y 4,33% rural dentro de las observadas. Véanse [cálculo, escenarios y límites](README_enpg_geographic_coverage_2024.md).
- El **INE** (estimaciones y proyecciones 2002–2035 por comuna y área urbana/rural) proyecta la población de cada comuna, separada en urbana y rural.
- La **EPS** (Encuesta de Protección Social) sí incluye zonas rurales, pero no trae una variable urbano/rural por persona. Para las tablas `rg_*` se usó la **ruralidad estimada del área de muestreo** de cada persona. Es una aproximación con supuestos fuertes (ver "Límites").
- Grupos de edad: ENPG 15–29, 30–44, 45–59, 60–65; EPS 18–29, 30–44, 45–59, 60–65. Educación (EPS): básica o menos / media (incluye superior incompleta) / superior completa.

---

## 1. `enpg_rural_coverage.csv`: qué parte del país cae dentro de las comunas de la ENPG

Fuentes: ENPG (comuna de cada encuestado) e INE. Una fila por año de la ENPG (2012–2024, cada dos años).

| Columna | Significado |
|---|---|
| `year` | Año de la ENPG. La población INE se toma del mismo año. |
| `comunas_enpg` | Número de comunas con al menos un encuestado ese año. |
| `comunas_total` | Comunas del país en la tabla INE (346). |
| `pct_pop_in_enpg_comunas` | % de la población de 15–64 años que vive en esas comunas (urbana + rural). |
| `pct_rural_pop_in_enpg_comunas` | % de la población **rural** de 15–64 años que vive en esas comunas. |
| `enpg_pct_weight_comunas_r0` | % del peso expandido de la ENPG que cae en comunas sin población rural (0% rural). |

Cómo leerla: las comunas observadas concentran ~82% de la población de 15–64 años, sumando urbano y rural; eso no equivale a cobertura. En 2024 la población urbana en esas comunas representa 78,05% y el complemento geográfico provisional es 21,95%. Ninguna población rural se considera cubierta. Las comunas observadas contienen ~40% del rural nacional de 15–64; ese porcentaje tiene un denominador diferente. El generador original y las comprobaciones se documentan en el [registro de cálculo](README_enpg_geographic_coverage_2024.md).

---

## 2. `enpg_rural_bias.csv`: qué tan rurales son las comunas de los encuestados ENPG, comparado con el país

Fuentes: ENPG e INE. A cada persona se le asigna el **% rural de su comuna** (INE, mismo año). Se compara el promedio de ese % en la ENPG con el promedio que tendría la población real del país.

Filas: año × sexo (`Hombre`, `Mujer`, `Total`) × edad (`15-29`, `30-44`, `45-59`, `60-65` y `15-65` = todas las edades).

| Columna | Significado |
|---|---|
| `year`, `sex`, `age` | Celda. |
| `n` | Encuestados ENPG en la celda. |
| `n_comunas` | Comunas distintas con encuestados en la celda. |
| `enpg_mean` | Promedio del % rural de la comuna, ponderado con el factor de expansión ENPG. |
| `enpg_median` | Mediana ponderada del mismo indicador. |
| `enpg_mean_unw` | Promedio sin ponderar (solo referencia). |
| `pop_mean` | Lo mismo para la población real del país en esa celda (INE): el promedio del % rural comunal que "vive" una persona típica. Es una referencia descriptiva de composición comunal, no una estimación de cobertura o sesgo de consumo. |
| `pop_median` | Mediana poblacional del mismo indicador. |
| `pop_pct_rural` | % de la población de la celda que es efectivamente rural (INE). |
| `ratio_mean` | `enpg_mean / pop_mean`. 1 = igualdad de promedios; ~0,4 = las comunas observadas son menos rurales en promedio. No mide sesgo de consumo. |

Notas:
- Las medianas son cercanas a 1–3% en ambos casos (distribución muy cargada a cero) y casi no discriminan. Usar los promedios.
- La tabla histórica compara ENPG 15–65 con INE 15–64; en `60-65`, la referencia INE usa 60–64. No se usa esta comparación de edades distintas para el nuevo porcentaje de exclusión, que utiliza 15–64 en todo el cálculo.
- Esta tabla describe la ruralidad de las comunas observadas. No estima la población excluida ni un piso del sesgo en alcohol; para la exclusión geográfica se calcula A + B por separado.

---

## 3. `rg_T1_ratios.csv`: ¿se bebe distinto en lo rural? (resumen nacional)

Fuente: EPS (rondas 2015/16, 2019/20 y 2023/24). Compara el consumo según la ruralidad del área de muestreo, **dentro** de cada celda año × sexo × edad × educación.

Una fila por indicador × especificación.

| Columna | Significado |
|---|---|
| `outcome` | Indicador: `Current drinker` (bebe actualmente), `Grams/day (population)` (gramos de alcohol puro al día, contando 0 a quien no bebe), `Risky` (≥20 g/día mujeres, ≥40 g/día hombres), `HED 5+/4+` (al menos una ocasión con 5+ tragos hombres / 4+ mujeres, sobre toda la población). |
| `waves` | `VIII` = solo ronda 2023/24 (**principal**); `ALL` = las tres rondas juntas (sensibilidad). |
| `exposure` | `rural_asg` = ruralidad estimada del área (versión principal); `rural_exp` = misma idea con otra forma de estimarla (sensibilidad); `noncov_asg` = proporción de la población del área que queda **fuera del marco ENPG** (rural + urbano fuera de las comunas observadas), en vez de solo la rural. |
| `region_FE` | `TRUE` = controla por región (**principal**); `FALSE` = sin ese control. |
| `RR` | Razón entre un área 100% rural y una 100% urbana (o 100% fuera vs 100% dentro del marco ENPG). 1 = sin diferencia; 0,67 = lo rural tiene un 33% menos; 1,31 = un 31% más. |
| `lo95`, `hi95` | Intervalo de confianza 95% (errores robustos por área de muestreo). Si incluye 1, la diferencia no es estadísticamente clara. |
| `p` | Valor p de la diferencia (0 = < 0,001). |

Fila clave para leer primero: `waves = VIII`, `exposure = rural_asg`, `region_FE = TRUE`.

---

## 4. `rg_T2_gaps.csv`: diferencia rural − urbana en unidades reales, por sexo y educación

Fuente: EPS ronda 2023/24, con control por región. Una fila por exposición × indicador × sexo × educación (2 × 3 × 2 × 3 = 36 filas).

| Columna | Significado |
|---|---|
| `exposure` | `rural_asg` (rural vs urbano) o `noncov_asg` (fuera vs dentro del marco ENPG). |
| `outcome` | `Current drinker`, `Grams/day (population)` o `HED 5+/4+ (population)`. |
| `sex` | `Men` / `Women`. |
| `edu` | Nivel educativo (básica o menos / media / superior completa). |
| `delta` | Diferencia absoluta entre un área 100% rural y una 100% urbana. Para `Current drinker` y `HED` está en **proporción** (−0,241 = 24 puntos porcentuales menos en lo rural). Para gramos, en **g/día** (2,87 = casi 3 gramos más al día). |
| `lo95`, `hi95` | Intervalo de confianza 95%. |

Esta tabla es la base del cálculo de sesgo de la tabla 5. Las diferencias son por sexo × educación (se supone la misma para todas las edades dentro de ese grupo).

---

## 5. `rg_T3_enpg_bias_cells.csv`: sesgo implícito de la ENPG en cada celda sexo × edad × educación

Fuente: EPS ronda 2023/24 (tablas 4 y medias de cada celda). Una fila por celda (2 sexos × 4 edades × 3 niveles educativos = 24 filas).

Idea: la ENPG mide en la práctica a la población urbana cubierta. El valor real de la celda incluye además a quienes quedan fuera. El error relativo de la ENPG es aproximadamente −(proporción fuera) × (diferencia) / (media real de la celda).

| Columna | Significado |
|---|---|
| `sex`, `ageg`, `edu` | Celda (`Prim` = básica o menos, `Sec` = media, `Tert` = superior completa). |
| `n` | Personas EPS en la celda. Celdas con n < ~150 son poco confiables. |
| `share_rural` | % promedio de ruralidad del área para las personas de la celda (aprox. qué parte de la celda es rural). |
| `share_noncov` | % promedio de población fuera del marco ENPG en el área de las personas de la celda. |
| `mean_current` | Proporción que bebe actualmente (EPS, celda completa). |
| `mean_pop_grams` | Gramos/día promedio (EPS, celda completa, 0 para quien no bebe). |
| `mean_hed` | Proporción con consumo intenso episódico (EPS, celda completa). |
| `rural_current`, `rural_pop_grams`, `rural_hed` | **Error relativo de la ENPG (%) si solo faltara la población rural**, con IC 95% entre corchetes. |
| `noncov_current`, `noncov_pop_grams`, `noncov_hed` | **Error relativo de la ENPG (%) por todo lo que queda fuera de su marco** (rural + urbano fuera de comunas observadas), bajo el supuesto contextual del modelo; no es una medición directa de sesgo ni del marco completo. |

Cómo leer las columnas de sesgo:
- Formato `estimación [límite inferior, límite superior]`, en %.
- **Positivo** = la ENPG **sobreestima** esa celda; **negativo** = la **subestima**.
- Si el intervalo no cruza 0, el sesgo es estadísticamente claro.
- `+Inf` aparece cuando la media de la celda es 0 en la EPS (no se puede calcular un error relativo).
- Intervalos muy anchos (p. ej. ±100%) indican celdas chicas o con medias cercanas a 0: no interpretar.

---

## Límites (aplican a las tablas `rg_*`)

- `noncov_asg` procede de INE 2023, todas las edades, con la unión de comunas observadas ENPG 2022/2024. Es una exposición contextual asignada a áreas EPS, distinta de la exclusión nacional 2024 de 15–64 años. No se recalcularon los modelos ni sus intervalos en esta corrección.

- La ruralidad de cada persona es la **estimada del área donde fue muestreada**, no un dato individual ni necesariamente su residencia actual. Esto tiende a **atenuar** las diferencias (los resultados son más bien un piso).
- La comparación supone que vivir en un área más rural no cambia el consumo por sí mismo más allá de la mezcla de personas rurales y urbanas (supuesto ecológico).
- Las definiciones de consumo de la EPS y la ENPG no son idénticas: usar estas tablas para la **dirección y el orden de magnitud** del sesgo, no como factores de corrección exactos.
- Resultados no replicados en una segunda corrida.

## Extensión histórica de cobertura

El [cálculo homogéneo 2012–2024](README_enpg_geographic_coverage_2024.md#extensión-a-20122024-2026-10-26) usa 15–64 años y población INE del mismo año en cada ola. La exclusión geográfica provisional pasa de 23,14% en 2012 a 21,95% en 2024, con comunas observadas como aproximación al marco. La serie se conserva en `enpg_geographic_coverage_2012_2024.csv`; no es una serie de sesgo de consumo.
