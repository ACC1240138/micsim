"""Build the notebook and a portable Spanish explanation from verified aggregates."""
import csv
import json
import hashlib
import base64
from pathlib import Path

ROOT = Path(__file__).resolve().parent
while not (ROOT / ".acc_root").exists():
    if ROOT.parent == ROOT:
        raise RuntimeError("Project root marker not found")
    ROOT = ROOT.parent
CONTROL = ROOT / "__andres_control"
OUT = CONTROL / "enpg_casen_aps_outputs"


def read(name, folder=OUT):
    with (folder / (name + ".csv")).open(encoding="utf-8-sig", newline="") as f:
        rows = list(csv.DictReader(f))
    for row in rows:
        for key, value in row.items():
            if value in ("NA", "NaN", ""):
                row[key] = None
            elif value in ("TRUE", "FALSE"):
                row[key] = value == "TRUE"
            else:
                try:
                    row[key] = float(value)
                except ValueError:
                    pass
    return rows


def notebook():
    cells = []

    def md(text):
        cells.append(dict(cell_type="markdown", metadata={}, source=text.splitlines(True)))

    def code(text):
        text = '.t0 <- Sys.time()\n' + text + '\nmessage(sprintf("Elapsed: %.2f min", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))\n'
        cells.append(dict(cell_type="code", metadata={}, source=text.splitlines(True), execution_count=None, outputs=[]))

    md("""# ENPG, CASEN y oportunidades de contacto con APS

**FONDECYT 1240138 · actualizado el 27 de octubre de 2026.** Insumos independientes para el microsimulador.
El ajuste corrige composición observada bajo supuestos de transporte; no identifica todo el sesgo de consumo.
La exploración comunal distingue población residente, contacto sanitario declarado y utilización de APS.

Este notebook **lee y verifica resultados de una ejecución real de los microdatos** por defecto.
Para reconstruirlos, ejecutar con `ECA_REBUILD=1`; cada sección llama al mismo código que generó los archivos.
Las salidas guardadas incluyen tablas HTML y cuatro figuras con IRdisplay, sin JavaScript ni recursos externos.
Fuera de Jupyter se usa htmltools::browsable(), como en expand_pif2/3.
Las salidas guardadas no son una nueva ejecución integral del microsimulador. No se modificaron sus notebooks.
Los identificadores, pesos y filas individuales se conservan únicamente en bundles cifrados.

Código: [enpg_casen_aps.R](enpg_casen_aps.R) y [enpg_casen_rural_prelim.R](enpg_casen_rural_prelim.R).
Explicación: [enpg_casen_aps_explicado.html](enpg_casen_aps_explicado.html).
""")
    code('''source(here::here("__andres_control", "enpg_casen_aps.R"))
rebuild <- identical(Sys.getenv("ECA_REBUILD"), "1")
cat("Rebuild from microdata:", rebuild, "\\n")
eca_tests()
read_result <- function(name) utils::read.csv(file.path(eca_dir, paste0(name, ".csv")))

# Same Jupyter / browsable dispatch as expand_pif2 and expand_pif3.
eca_show_table <- function(data, caption, digits = 3L) {
  tag <- htmltools::div(
    style = "max-height:520px;max-width:100%;overflow:auto;",
    tabindex = "0", role = "region", `aria-label` = caption,
    htmltools::tags$style(".eca-table{border-collapse:collapse;font-size:14px;width:100%}.eca-table th,.eca-table td{padding:6px 10px;border-bottom:1px solid #ccc}.eca-table caption{text-align:left;font-weight:bold;padding:8px 0}"),
    htmltools::HTML(knitr::kable(as.data.frame(data), format = "html",
      digits = digits, row.names = FALSE, caption = caption, escape = TRUE,
      table.attr = 'class="eca-table"')))
  if (isTRUE(getOption("jupyter.in_kernel"))) {
    IRdisplay::display_html(as.character(tag))
    invisible(tag)
  } else htmltools::browsable(tag)
}''')
    md("""## 1. Reconstruir la referencia nacional

CASEN 2013–2024, población de 15–65 años; `expr_c2017_nm` en 2013/2015 y `expr` desde 2017.
Se reutiliza la regla `e3` del script anterior, sin ejecutar sus rutas ni sobrescribir sus salidas.
El diseño completo usa `varunit` y `varstrat` antes de seleccionar el dominio. Se ajustan los estratos con
una sola UPM en el dominio (`survey.lonely.psu='adjust'` y `survey.adjust.domain.lonely=TRUE`).
La concordancia con la variable del Ministerio valida la recodificación, no el transporte de consumo.

Las proporciones educativas excluyen educación desconocida. La distribución sexo–edad incluye a todas las
personas elegibles. Los años intermedios se interpolan linealmente; 2012 usa 2013, sin extrapolar una tendencia.
Las metas antiguas del repositorio se comparan con la reconstrucción: **no se toman como actualizadas por su nombre**.
""")
    code('''if (rebuild) eca_casen_targets()
eca_show_table(read_result("casen_education_validation"), "Validación educativa por ronda CASEN")
eca_show_table(read_result("casen_year_interpolation"), "Fuentes CASEN para cada año ENPG")
eca_show_table(read_result("casen_existing_targets_check"), "Comparación con las metas anteriores")
targets <- read_result("casen_targets_enpg_years")
stopifnot(nrow(targets) == 56, all(abs(rowSums(targets[c("e1", "e2", "e3")]) - 1) < 1e-8))
eca_show_table(targets, "Metas de sexo, edad y educación: todos los años")''')
    md("""## 2. Armonizar educación del entrevistado y ajustar la ENPG

2012: `p184/p185`; 2014: `dp9/dp10`; 2016: `dp_9/dp_10`; 2018: `T_DP_12/T_DP_13`.
En esas cuatro olas se selecciona la columna del jefe de hogar **solo cuando el entrevistado es el jefe**.
Desde 2020 se usa `DP_12/DP_13`. En 2014/2016, las preguntas 12/13 se refieren a ingresos.
La finalización desconocida queda faltante, en lugar de tratarla automáticamente como nivel incompleto.

**Ajuste educativo:** `peso_educ = peso × p_CASEN(educación|sexo,edad) / p_ENPG(educación|sexo,edad)`.
El denominador usa solo educación conocida. Quien no tiene educación conocida conserva `peso`.
Por eso se conservan exactamente los totales originales de sexo–edad y las proporciones educativas se cumplen
entre quienes tienen educación conocida. La fórmula del contexto, con desconocidos dentro del denominador,
no conservaría los totales si luego se mantienen sus pesos.

**Ajuste nacional adicional:** `peso_nacional = peso_educ × p_CASEN(sexo,edad) / p_ENPG(sexo,edad)`.
Este sí cambia la distribución de sexo–edad y conserva el total de pesos ENPG de cada año. No convierte ese
total en un conteo nacional CASEN. Los casos sin educación también reciben el factor sexo–edad, pero no el educativo.
El supuesto de ausencia selectiva de educación no queda validado por estas igualdades.
""")
    code('''if (rebuild) { eca_enpg(); eca_national_weights() }
eca_show_table(read_result("enpg_variable_map"), "Variables originales por ola ENPG")
eca_show_table(read_result("enpg_audit"), "Muestra y educación faltante por ola ENPG")
eca_show_table(read_result("enpg_consumption_comparison"), "Consumo antes y después de ajustar los pesos", digits = 5)
eca_show_table(read_result("enpg_weight_diagnostics"), "Diagnóstico de pesos: ajuste educativo")
eca_show_table(read_result("enpg_national_weight_diagnostics"), "Diagnóstico de pesos: composición nacional")
totals <- read_result("enpg_total_checks")
national <- read_result("enpg_national_target_checks")
stopifnot(all(abs(totals$after / totals$before - 1) < 1e-8), all(abs(national$p - national$p_sexo_edad) < 1e-8))''')
    md("""Las comparaciones son prevalencia del último mes y del último año entre respuestas válidas, con los mismos
registros antes y después. Son estimaciones puntuales ponderadas; no se fabrican UPM o estratos ENPG ni se presentan
intervalos de encuesta sin una armonización completa del diseño. `neff_kish` mide dispersión de pesos, no incorpora
correlación intraclúster. La incertidumbre de las metas CASEN no se propagó a los resultados ENPG.

Los pesos se pueden unir al motor por `anio + id` usando el identificador original de cada ola. Antes de integrarlos
hay que verificar una unión uno a uno y la población analítica del motor; no se aplicaron a PIF/AAF en este trabajo.
""")
    md("""## 3. Edad simple para inicialización; tramos para pesos

Se entregan perfiles por edad 15–65, promediados con las edades vecinas disponibles. En los extremos se usan dos
edades distintas; el código antiguo duplicaba la edad del extremo y dividía por tres. El archivo conserva la
procedencia anual por separado. Estos perfiles son cortes transversales: **sus diferencias no identifican
transiciones educativas individuales**. No se usa este archivo para crear 306 celdas de pesos ENPG.
""")
    code('''age <- read_result("casen_single_age_targets_enpg_years")
stopifnot(nrow(age) == 714, all(abs(rowSums(age[c("e1", "e2", "e3")]) - 1) < 1e-8))
eca_show_table(age |> dplyr::count(anio, name = "rows"), "Cobertura del insumo por edad simple", digits = 0)
eca_show_table(age[age$sexo == 1 & age$edad == 30, ], "Ejemplo: hombres de 30 años, serie completa")''')
    md("""## 4. Población por sexo, edad y comuna

Se reutilizan las proyecciones INE que ya usa `eps_reid.R`, sumando áreas urbana y rural.
La fuente es la serie comunal existente, basada en Censo 2017; no se presenta como una nueva serie comunal del Censo 2024.
Incluye 346 comunas y 2012–2024. Por sus edades quinquenales, esta tabla usa **15–64**, con último tramo 60–64.
No se inventa el número de personas de 65 años dividiendo el grupo 65–69.

Se entregan dos denominadores: `p_sexo_edad_en_comuna` suma uno dentro de comuna; `p_comuna_dado_sexo_edad`
suma uno entre comunas para cada sexo–edad. Ninguno es un porcentaje de uso de APS.
""")
    code('''if (rebuild) eca_demography()
population <- read_result("ine_sexo_edad_comuna_2012_2024")
stopifnot(nrow(population) == 19376)
eca_show_table(population |> dplyr::count(anio, name = "rows"), "Cobertura del insumo comunal", digits = 0)
eca_show_table(population[population$comuna == 13101 & population$sexo == 1 & population$ag == "30-44", ], "Ejemplo agregado: Santiago, hombres de 30–44 años")''')
    md("""## 5. Qué mide CASEN sobre contacto sanitario

Se procesan las seis rondas: **2013, 2015, 2017, 2020, 2022 y 2024**, a nivel nacional, regional y comunal.
En 2013 (`s22a/s22b`, `s29a/s29c`) y 2015/2017 (`s19a/s19b`, `s26a/s26c`) las consultas generales y
controles tienen referencia de tres meses. Consultorio general o posta rural (códigos 1/2) permite una
aproximación específica a APS: personas con alguna de ambas prestaciones, sin duplicarlas.

En **2020** el cuestionario telefónico no incluye esas preguntas de prestación/establecimiento.
Se conserva por separado la consulta por enfermedad o accidente en tres meses (`s16/s17`), de cualquier
sector. **No reemplaza el indicador público ni el de APS.**

En **2022/2024**, `s20a_preg/s20b` mide medicina general en tres meses y `s26a/s26c` controles en doce meses.
Solo distingue público/privado/otro. Público no equivale a APS. No se mezclan controles de tres y doce meses.
Las preguntas identifican el último establecimiento declarado, no todos los establecimientos visitados.

El denominador es la población 15–64 con respuesta válida, no solo usuarios ni solo afiliados a FONASA.
Las no atenciones explícitas son cero; las respuestas desconocidas permanecen faltantes. Se informa su peso.
Estratos/UPM oficiales; `expr` para país/región y `expc` para comuna. El IC logit usa linealización y aproximación
normal; no se fuerza un IC cuando la proporción observada es cero o uno.
Cada ronda conserva su registro completo de advertencias por dominios con una sola UPM y una auditoría de
la unión geográfica. Se armonizan los códigos antiguos de Ñuble a la geografía INE actual mediante las etiquetas
oficiales; no se modifican estratos ni UPM. Los factores comunales oficiales se unen por folio + o hasta 2017,
y por folio + id_persona desde 2020. En 2015 solo 139 comunas tienen factor comunal oficial;
las demás quedan sin estimación comunal directa. Las estimaciones regionales incluyen toda la muestra.
Los factores comunales históricos tienen una base censal distinta del factor regional actualizado de 2013/2015.

Filtro exploratorio de precisión (decisión de este trabajo, no norma oficial): n válido ≥60, Kish ≥30,
≥5 casos y ≥5 no casos, ≥2 UPM, CV ≤30% y peso de faltantes ≤10%. Superarlo no valida una tasa comunal para el motor.
""")
    code('''if (rebuild) eca_health()
health <- read_result("casen_health_domains")
eca_show_table(health |> dplyr::group_by(anio_casen, geography, outcome) |>
  dplyr::summarise(cells = dplyr::n(), pass = sum(passes_screen), .groups = "drop"),
  "Celdas de salud disponibles y filtro exploratorio", digits = 0)
eca_show_table(health[health$geography == "national", c("anio_casen", "sexo", "ag", "outcome", "p", "se", "lo95", "hi95", "n_valid")], "Contacto observado: estimaciones nacionales por ronda", digits = 4)
eca_show_table(read_result("health_year_alignment"), "Alineación temporal del contacto sanitario")
eca_show_table(read_result("casen_health_indicator_availability"), "Indicadores disponibles en cada ronda CASEN")
contact <- read_result("insumo_contacto_comuna_anios_enpg")
stopifnot(nrow(contact) == 19376, setequal(unique(contact$anio), seq(2012, 2024, 2)),
  all(is.na(contact$p_aps_3m[contact$anio >= 2018])),
  all(is.na(contact$p_observed_commune[contact$anio < 2022])))
eca_show_table(contact[contact$comuna == 13101 & contact$sexo == 1 & contact$ag == "30-44",
  c("anio", "comuna", "p_observed_commune", "p_scenario_commune", "p_scenario_region", "source_a", "source_b", "weight_b")], "Contacto observado y escenarios: Santiago, hombres de 30–44 años", digits = 4)''')
    md("""El insumo cubre **2012, 2014, 2016, 2018, 2020, 2022 y 2024**, con 2.768 filas por año.
Para contacto público general: 2012 usa 2013; 2014 combina 2013/2015; 2016 combina 2015/2017;
2018 y 2020 usan escenarios entre 2017/2022 (pesos de 2022: 20% y 60%). Estos dos escenarios
cruzan la pandemia y **no reconstruyen su efecto**. 2022/2024 sí tienen medición del mismo año.
`p_observed_*` solo contiene mediciones del mismo año; `p_scenario_*` también contiene proxies e
interpolaciones. El escenario regional aplica la misma tasa a comunas del mismo sexo–edad y región.
La interpolación comunal exige ambas celdas fuente; una ausente sigue ausente. No se fabrican IC temporales.
`p_aps_3m` solo tiene un escenario regional histórico para 2012/2014/2016; desde 2018 permanece NA.
Las tasas APS observadas de 2013/2015/2017 se conservan en la tabla por ronda, también a nivel comunal.
Para estimar APS actual se necesita una fuente que identifique el nivel de atención y personas únicas; los
recuentos REM de atenciones por sí solos no son probabilidades individuales. Contacto tampoco implica tamizaje,
intervención breve, aceptación o respuesta al tratamiento: son etapas diferentes del programa DIR.
""")
    md(r"""## 6. Estimación preliminar: composición rural y categorías WHO

**Dos preguntas, dos resultados.** La comparación principal aplica directamente `peso` y `peso_nacional`
a las mismas respuestas válidas: muestra cuánto cambia ENPG con los pesos CASEN ya entregados. Incluye a
quienes tienen educación desconocida, con el tratamiento previamente documentado, y reproduce
35,946% → 36,025% para consumo del mes en 2024.
El cálculo rural posterior usa educación conocida y calibra cada grupo de respuestas válidas a su meta;
es una estandarización exploratoria distinta. Sus denominadores no se mezclan con la comparación principal.

Se muestran, en este orden, **nunca bebieron (lifetime abstainer)**, consumo en 30 días, categorías WHO y HED.
Nunca bebieron se deriva de `oh1 == 'No'`, nunca de ausencia de consumo en el mes. HED usa `db > 0`,
con el umbral del proyecto 5+/4+ por ocasión en 30 días; la referencia 5+/4+ no se presenta como un umbral
WHO universal. Un no consumidor del mes sin un reporte de episodios contradictorio tiene HED=0;
un consumidor con frecuencia desconocida, o una contradicción de estado/episodios, queda como NA.
Los indicadores no son categorías que puedan sumarse: HED puede coexistir con C1, C2 o C3+.

Se añaden **los siete años ENPG**, sin cambiar los pesos entregados anteriormente ni el motor.
Para cada sexo × edad × educación estimamos el consumo con ENPG y conservamos ese promedio al cambiar
la composición. Comparamos tres escenarios: ENPG original, composición CASEN urbana y composición CASEN nacional.
El contraste **urbano − nacional** aísla el componente composicional asociado a ruralidad:
positivo sugiere sobreestimación composicional; negativo, subestimación composicional.
La diferencia original − nacional incluye además otros desbalances del marco y de la muestra.

\[
\mu_U=\sum_x q_U(x)m_{ENPG}(x),\quad \mu_N=\sum_x q_N(x)m_{ENPG}(x),\quad B_{comp}=\mu_U-\mu_N.
\]

**No es una estimación del sesgo rural total.** CASEN urbana también incluye localidades urbanas pequeñas
fuera del marco ENPG. El consumo rural dentro de cada celda se supone igual al urbano; no se observa.
Con sexo, edad y educación fijos, este contraste es cero por construcción: por educación mostramos su
**aporte al contraste del grupo**, no un efecto rural dentro del nivel educativo.

Las metas nacionales son las ya verificadas. Se estima la fracción rural dentro de cada celda CASEN
(variable `zona` en 2013/2015, `area` desde 2017; 1 urbana, 2 rural) con los factores actualizados.
En años intermedios se interpola esa fracción según el calendario educativo; después se deriva
qU ∝ qN × (1 − fracción rural). Así se conserva exactamente la meta nacional. 2012 usa 2013.
Son estimaciones puntuales ponderadas; todavía no se propaga la varianza de las dos encuestas ni la interpolación.

Se aplica la [decisión de clasificación vigente del proyecto](decision_categorias_who_12g_2026-10-26.md):
NC = sin consumo en 30 días; C1: (0,20] g/día mujeres y (0,40] hombres; C2: (20,40] y (40,60];
C3+: >40 y >60, respectivamente. Los bordes exactos quedan en la categoría inferior.
Los cortes se documentan en WHO (2000), *International guide for monitoring alcohol consumption and related harm*,
[tabla 2.2.2, p. 54](https://www.who.int/docs/default-source/substance-use/who-msd-msb-00-4.pdf).
“Actualizada” se refiere a la regla vigente del proyecto, no a una nueva guía WHO de 2026; C1 no significa consumo seguro.

Dos escalas: **reportada, 12 g por trago**, y **anclada**, multiplicada por el factor APC anual ya usado por el
proyecto (`oms_factor_by_year.csv`, versión existente de junio de 2026; 2024 usa APC 2023).
El factor se mantiene fijo en los tres escenarios: recalibrarlo después escondería parte del cambio.
El volumen usa días, cantidad típica y episodios 5+/4+ de `ENPG_BINGE.RDS`, unido por año e ID original.
NC tiene volumen cero; un consumidor actual sin volumen válido permanece faltante.
Se excluyen educación desconocida y desenlace faltante; las metas se aplican entre respuestas válidas en cada celda,
lo que exige que esas respuestas representen a las faltantes dentro de la celda. Por ello el denominador puede
diferir de las tablas anteriores. NC/C1/C2/C3+ comparten denominador, pero “consumo actual” puede tener más respuestas válidas.
""")
    code('''source(here::here("__andres_control", "enpg_casen_rural_prelim.R"))
if (rebuild) eca_rural_preliminary()
eca_rural_tests()
rural <- read_result("rural_preliminary_estimates")
rural_cells <- read_result("rural_education_contributions")
stopifnot(nrow(rural) == 1680, nrow(rural_cells) == 2688,
  setequal(unique(rural$anio), seq(2012, 2024, 2)))
indicators <- read_result("enpg_indicators_by_group")
eca_show_table(indicators[indicators$anio == 2024 & indicators$scale == "anchored" & indicators$sexo == 0 & indicators$ag == "All" & indicators$outcome != "grams",
  c("outcome", "n", "original", "national", "change")],
  "Comparación principal 2024: pesos originales y nacionales, proporciones 0–1", digits = 4)
eca_show_table(read_result("rural_enpg_join_audit"), "Unión por año e ID y respuestas faltantes", digits = 0)
eca_show_table(read_result("rural_casen_dictionary"), "Variable urbano/rural comprobada en cada CASEN")
eca_show_table(rural[rural$scale == "anchored" & rural$outcome == "C3plus" & rural$sexo == 0 & rural$ag == "All",
 c("anio", "n", "original", "urban", "national", "rural_composition_gap", "unsupported_target_share")],
 "C3+ anclado: los siete años; proporciones 0–1", digits = 4)
eca_show_table(rural[rural$anio == 2024 & rural$scale == "anchored" & rural$outcome == "C3plus" & rural$sexo > 0 & rural$ag != "All",
 c("sexo", "ag", "n", "kish", "original", "urban", "national", "rural_composition_gap", "unsupported_target_share")],
 "Ejemplos 2024 por sexo y edad: C3+ anclado, proporciones 0–1", digits = 4)
eca_show_table(rural_cells[rural_cells$anio == 2024 & rural_cells$scale == "anchored" & rural_cells$outcome == "C3plus",
 c("sexo", "ag", "educ3", "n", "kish", "events", "missing_share", "m", "contribution", "screen")],
 "Educación: aporte al contraste, tamaño muestral y filtro exploratorio", digits = 4)''')
    md("""### Ver el cambio y el soporte de los datos

El love plot muestra diferencias estandarizadas de las proporciones marginales frente a CASEN;
usa como denominador la desviación estándar binaria de la meta. La línea 0,10 es orientativa.
El ajuste exacto también verifica las 24 celdas conjuntas. Balancear estas variables no demuestra
intercambiabilidad ni elimina el problema de cobertura rural.

Para educación se informa n, Kish y eventos. El filtro exploratorio exige n ≥60, Kish ≥30,
≥5 casos y ≥5 no casos en indicadores binarios, y ≤10% del peso con desenlace faltante.
Kish solo resume dispersión de pesos: no incorpora conglomerados ni es una garantía de precisión.
La masa objetivo que no supera el filtro sigue visible; sus valores no se convierten en cero ni se ocultan.
No se ajustan interacciones adicionales por educación. Las figuras contienen puntos, no IC.
""")
    code('''eca_show_figure <- function(name, caption) {
  path <- file.path(eca_dir, "figures", paste0(name, ".png"))
  raw <- readBin(path, "raw", n = file.info(path)$size)
  tag <- htmltools::tags$figure(
    htmltools::tags$img(src = paste0("data:image/png;base64,", jsonlite::base64_enc(raw)),
      alt = caption, style = "max-width:100%;height:auto"), htmltools::tags$figcaption(caption))
  if (isTRUE(getOption("jupyter.in_kernel"))) {
    IRdisplay::display_html(as.character(tag)); invisible(tag)
  } else htmltools::browsable(tag)
}
eca_show_figure("loveplot_composition", "Balance antes y después en los siete años ENPG")
eca_show_figure("who_targets_2024", "C3+ en 2024: perfil original, urbano y nacional en dos escalas")
eca_show_figure("rural_composition_heatmap", "Dirección y magnitud del contraste composicional en todos los años")
eca_show_figure("education_contributions_2024", "Aporte educativo al contraste y celdas que superan el filtro")''')
    md(r"""### Relación con Yang, Kim y Song (2020)

Yang, S., Kim, J. K., & Song, R. (2020). Doubly Robust Inference when Combining Probability and
Non-Probability Samples with High Dimensional Data. *JRSS B*, **82**(2), 445–465.
[doi:10.1111/rssb.12354](https://doi.org/10.1111/rssb.12354).

El artículo combina una muestra probabilística de referencia con otra no probabilística que observa
el desenlace. Combina un modelo de participación con uno del desenlace; bajo sus supuestos,
la consistencia puede mantenerse si uno de los dos está correctamente especificado. Su procedimiento
incluye selección penalizada de variables y estimación posterior orientada a reducir sesgo.
Requiere participación positiva y selección ignorable condicionada a las covariables; la doble robustez
no sustituye esos supuestos. Su estimador aumentado tiene la forma:

\[
\widehat\mu_{DR}=N^{-1}\left\{\sum_{i\in A}d_i\widehat m(X_i)
 +\sum_{i\in B}\frac{Y_i-\widehat m(X_i)}{\widehat\pi_B(X_i)}\right\}.
\]

**Aplicación a este proyecto.** CASEN puede aportar la distribución de referencia; la ENPG es una encuesta
probabilística con cobertura restringida, por lo que no equivale sin adaptación a la muestra B del artículo.
Incluir ruralidad explicita la falta de soporte ENPG rural; omitirla permite calcular pesos, pero impone
el supuesto no comprobado de transporte dentro de sexo × edad × educación.

| Componente | Situación y consecuencia |
|---|---|
| Covariables compartidas | Sexo, edad y educación armonizados; consumo no medido aquí en CASEN. |
| Positividad nacional | Falta soporte observado rural en ENPG; una regresión no crea observaciones rurales. |
| Años intermedios | Las metas interpoladas no son una muestra probabilística observada de ese año. |
| Modelos de selección y resultado | No se implementa la selección penalizada ni la inferencia de alta dimensión de Yang. |
| Incertidumbre | Pendiente propagación conjunta de diseños, modelos, no respuesta e interpolación. |
| Paso defendible | Evaluar primero transporte dentro del marco cubierto y obtener ruralidad EPS oficial con consumo comparable antes de extrapolar. |

Como comprobación algebraica, la expresión aumentada con pesos que calibran exactamente las mismas celdas
y un predictor constante por celda devuelve la postestratificación. Aquí se usa un predictor constante global
para verificar esa identidad. **La coincidencia no es una prueba de doble robustez ni una implementación del método
de Yang**: ambas expresiones reutilizan la misma información. Se conserva su diferencia numérica en el CSV.
""")
    code('''identity_check <- read_result("rural_augmented_identity")
balance_check <- read_result("rural_balance")
stopifnot(nrow(identity_check) == 112, all(identity_check$abs_difference < 1e-10),
  !any(identity_check$is_yang_high_dimensional_fit), max(abs(balance_check$smd_after)) < 1e-10)
eca_show_table(identity_check |> dplyr::group_by(anio) |>
  dplyr::summarise(max_difference = max(abs_difference), .groups = "drop"),
  "Identidad aumentada: comprobación algebraica, no validación de doble robustez", digits = 12)''')
    md("""## 7. Uso y límites de `eps_reid.R`

Se preserva el script original. Su búsqueda automática de sexo/edad falla con las etiquetas actuales de EPS VIII.
Se ejecuta `eps_reid_casen_aps.R`, una copia con selección explícita de `a8/a9` del módulo del entrevistado
y lectura portable del CSV INE. Se preservan **todos los candidatos**, asignaciones, alternativas y márgenes;
su etiqueta de confianza se renombra para aclarar que no es una probabilidad validada. La asignación utiliza
tamaño, perfil sexo–edad, región laboral y respuesta «posta rural». Usar luego esa misma respuesta para validar
una tasa de APS generaría circularidad. La asignación ecológica tampoco observa residencia ni ruralidad individual.

Las asociaciones rurales previas se conservan como referencia histórica, con bandera `models_reexecuted=FALSE`.
Un IC que incluye uno no prueba equivalencia urbano–rural ni que la diferencia sea pequeña.
No se aplica un multiplicador rural al modelo base ni se unen personas EPS a comunas como dato confirmado.

La explicación también usa `rg_T2_gaps.csv`: diferencias entre áreas 100% rurales y 100% urbanas,
por sexo y educación, con control regional. Son modelos anteriores que suponen la misma diferencia
para las edades; no demuestran un efecto rural específico de 30–44 años. `rg_T3_enpg_bias_cells.csv`
aporta n descriptivos de 18–65 años; no un tamaño efectivo ni una validación de esos modelos.
Estas tablas no aportan un efecto rural para lifetime abstainer ni las categorías WHO vigentes.
“Consumo actual” EPS requiere armonización antes de equipararlo al último mes ENPG.
""")
    code('''if (rebuild) eca_eps_audit()
eca_show_table(read_result("eps_script_audit"), "Auditoría del script EPS")
eca_show_table(read_result("eps_rural_historical_reference"), "Referencia rural histórica: modelos no reestimados")
eps_gaps <- utils::read.csv(here::here("__andres_control", "rg_T2_gaps.csv"))
eca_show_table(eps_gaps[eps_gaps$exposure == "rural_asg", ],
  "EPS histórica: diferencias entre áreas por sexo y educación, comunes a las edades; no reestimadas", digits = 3)
eps <- read_result("eps_heuristic_assignment_audit")
eca_show_table(as.data.frame(table(eps$heuristic_label_not_probability)), "Asignaciones EPS por etiqueta heurística", digits = 0)''')
    md("""## 8. Contrato de integración y comprobaciones

Las tablas objetivo y factores son agregados en CSV. Los pesos individuales se leen así, sin exportar filas:

```r
weights <- readRDS(acc_data("__andres_control/enpg_casen_aps_outputs/enpg_poststrat_nacional.rds.tar.xz.enc"))
```

Usar `peso_educ` si se desea preservar sexo–edad ENPG; `peso_nacional` si se desea la distribución sexo–edad CASEN.
Elegir uno y reconstruir las metas del motor, sin multiplicar ambos ajustes otra vez. Los factores no corrigen
subdeclaración, falta de respuesta dependiente del consumo o diferencias rurales residuales.

La arquitectura de referencia del proyecto sigue siendo Kilian et al. (2025), DOI
[10.1016/S2468-2667(25)00165-3](https://doi.org/10.1016/S2468-2667(25)00165-3), y SIMAH 0.1.1,
[10.5281/zenodo.15641639](https://doi.org/10.5281/zenodo.15641639). Aquí no se implementa ni valida su ciclo anual.
""")
    code('''eca_tests()
f <- read_result("enpg_factors_educ3")
stopifnot(all(abs(f$p_after[f$p_casen > 0] - f$p_casen[f$p_casen > 0]) < 1e-8),
  !anyDuplicated(contact[c("anio", "comuna", "sexo", "ag")]),
  all(health$p >= 0 & health$p <= 1, na.rm = TRUE))
cat("PASS: target shares, preserved totals, sex-age national shares, commune keys and probability bounds\\n")
print(sessionInfo())''')
    for i, cell in enumerate(cells):
        cell["id"] = f"eca-{i:02d}"
    doc = dict(cells=cells, nbformat=4, nbformat_minor=5, metadata={
        "kernelspec": {"display_name": "R", "language": "R", "name": "ir"},
        "language_info": {"name": "R", "file_extension": ".r", "mimetype": "text/x-r-source"},
        "eca": {"default_execution": "Read and verify real-data outputs; ECA_REBUILD=1 regenerates them",
                "helper_sha256": hashlib.sha256((CONTROL / "enpg_casen_aps.R").read_bytes()).hexdigest(),
                "rural_helper_sha256": hashlib.sha256((CONTROL / "enpg_casen_rural_prelim.R").read_bytes()).hexdigest()}})
    (CONTROL / "enpg_casen_aps.ipynb").write_text(json.dumps(doc, ensure_ascii=False, indent=1), encoding="utf-8")


def artifact():
    data = {k: read(v) for k, v in {
        "targets": "casen_targets_enpg_years", "ages": "casen_single_age_targets_enpg_years",
        "consumption": "enpg_consumption_comparison", "audit": "enpg_audit",
        "validation": "casen_education_validation", "differences": "casen_existing_targets_differences",
        "health": "casen_health_domains", "contact": "insumo_contacto_comuna_anios_enpg",
        "alignment": "health_year_alignment", "availability": "casen_health_indicator_availability",
        "eps": "eps_script_audit", "rural": "eps_rural_historical_reference",
        "ruralEstimates": "rural_preliminary_estimates", "ruralCells": "rural_education_contributions"}.items()}
    data["indicators"] = read("enpg_indicators_by_group")
    data["epsGaps"] = [r for r in read("rg_T2_gaps", CONTROL) if r["exposure"] == "rural_asg"]
    data["epsCells"] = read("rg_T3_enpg_bias_cells", CONTROL)
    data["health"] = [r for r in data["health"] if r["geography"] == "national"]
    html = (ROOT / "_tools" / "enpg_casen_aps_template.html").read_text(encoding="utf-8")
    html = html.replace("__DATA__", json.dumps(data, ensure_ascii=False, allow_nan=False).replace("</", "<\\/"))
    for name in ("loveplot_composition", "rural_composition_heatmap"):
        html = html.replace("__FIG_" + name + "__", base64.b64encode((OUT / "figures" / (name + ".png")).read_bytes()).decode("ascii"))
    (CONTROL / "enpg_casen_aps_explicado.html").write_text(html, encoding="utf-8")


if __name__ == "__main__":
    notebook()
    artifact()
    print("Built notebook and self-contained explanation from verified aggregate tables.")
