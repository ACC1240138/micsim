# expand_pif*: qué cambiar y qué revisar (hallazgos 14–21 sep 2026)

**Primero (5 min):** abre la celda de `expand_pif.ipynb` que crea `volajohdiams` y mira el denominador del factor OMS (V1, §2). Es el único punto que puede mover mucho los AAF.

Nada de esto está aplicado: son `.ipynb` y requieren tu permiso. Rutas relativas a la raíz del proyecto.

---

## 1. Respuesta corta

- **Estrato = comuna no cambia ningún resultado puntual** de `expand_pif*` (AAF, PIF, muertes atribuibles, YPLL). Sólo intervalos y draws.
- **Tampoco agrega diferencias puntuales con JRT.** Las que existen o existirían están en §6.
- **Lo que sí puede mover resultados son cuatro verificaciones (§2):** una puede ser grande (V1), dos medianas (V2, V3), una chica (V4).

---

## 2. Pueden mover resultados: verificar en este orden

| # | Qué revisar | Dónde | Impacto si hay que cambiar | Tiempo |
|---|---|---|---|---|
| V1 | Denominador del factor OMS: debe ser g/día **per cápita** (abstemios y ex = 0), no la media entre bebedores | `expand_pif.ipynb`, celda que crea `volajohdiams` | Si usa la media entre bebedores, el factor queda multiplicado por la prevalencia del mes (0,35–0,49) → g/día corregidos 2–3 veces más bajos → AAF de causas crónicas muy subestimados. **Grande** | 5 min revisar; 30 min corregir y re-correr |
| V2 | Ex-bebedor: hoy `fd` = no bebió en los últimos 30 días. Los RR de ex y la definición OMS de bebedor actual usan 12 meses | celda que arma `cvolaj` | Quien bebió hace 1–12 meses recibe RR de ex en vez de RR de consumo bajo. Dirección esperada: AAF más altos en causas donde RR de ex > RR de consumo bajo. **Mediano a grande: medir antes de decidir** | 45 min (sensibilidad 2024) |
| V3 | HED: (a) faltantes de `db` excluidos (SENDA los cuenta como "no"); (b) umbral 5+ hombres / 4+ mujeres en cada ola; (c) que ninguna ola use el ítem AUDIT de frecuencia ("6 o más tragos"; `OH_10` en 2024) en vez del ítem de 30 días | celda que arma `db`/`hed` y escribe `data_binge_sensitivity.rds` | Con faltantes excluidos, HED entre bebedores queda ≈ 3–6 pts sobre SENDA (5–14 % relativo) → AAF de lesiones y PIF de escenarios HED algo altos. **Mediano, sólo lesiones y HED** | 30 min |
| V4 | Archivo DEIS: `DEFUNCIONES_FUENTE_DEIS_2024_2026_15092026.parquet`, con los dos filtros (año 2024; edad en años) | celda que lee defunciones (`mort24`) | Muertes 2024 suben por inscripciones tardías. AAF igual; muertes atribuibles y YPLL 2024 suben en la misma proporción. **Chico** | 15 min |

### V1. Chequeo (5 min)

```r
.t0 <- Sys.time()
# The survey per-capita mean must count lifetime abstainers and former drinkers as 0 g/day.
d <- readr::read_rds("data_binge_sensitivity.rds")   # adjust path: object written by expand_pif.ipynb
chk <- d |>
  dplyr::mutate(g_pop = dplyr::if_else(cvolaj %in% c("ltabs", "fd"), 0, volajohdia)) |>
  dplyr::group_by(year) |>                           # year: the wave column used in expand_pif
  dplyr::summarise(
    mean_drinkers = stats::weighted.mean(volajohdia, wt, na.rm = TRUE),  # wt: the weight column used in expand_pif
    mean_percap   = stats::weighted.mean(g_pop, wt, na.rm = TRUE),
    .groups = "drop") |>
  dplyr::mutate(ratio = mean_percap / mean_drinkers)  # should be close to past-month prevalence (0.35-0.49)
print(chk)
cat(sprintf("Elapsed: %.2f minutes\n", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
```

Compara con el denominador que usa la celda del factor:

1. Coincide con `mean_percap` → bien. No tocar.
2. La celda calcula "media entre bebedores = APC per cápita / prevalencia de bebedores" → también bien (es lo mismo, estilo InterMAHP).
3. Coincide con `mean_drinkers` → mal. Cambiar el denominador a `mean_percap`, re-correr y validar (§7).

Anotar de paso, sin cambiar nada hoy: APC es 15+ y `expand_pif` es 15–65; ¿incluye alcohol no registrado?; ¿qué año o serie de APC?

### V2. Encargo listo para Codex (45 min)

> Sensibilidad de la definición de ex-bebedor, sólo 2024. No edites notebooks; crea `__andres_control/sens_former_12m_2024.R`. (1) Con la ENPG 2024 (`OH_1` alguna vez, `OH_4` última vez) arma tres estados: nunca; ex = última vez hace más de un año; actual 12 m = bebió en los últimos 12 meses. Proporciones ponderadas por sexo × tramo (15–29, 30–44, 45–59, 60–65) con el diseño de la caché. (2) Corre el motor AAF de `expand_pif` (`aaf_unified.R`) dos veces para 2024: proporciones actuales vs proporciones 12 m. Quien bebió hace 1–12 meses entra como bebedor actual con la distribución de g/día de `cat1` de su celda. RR, factor OMS y override Adam/WHO sin cambios. (3) Exporta `sens_former_12m_2024.csv`: AAF y muertes atribuibles por causa × sexo × tramo, las dos versiones y la diferencia relativa. Reporta el tiempo en minutos.

Regla de decisión:

1. Ninguna causa cambia más de 5 % relativo → dejar la definición heredada y declararla en métodos.
2. Alguna cambia más → llevar a ACC: cambiarla rompe la comparabilidad con JRT.

### V3. Encargo listo para Codex (30 min)

> Auditoría de la definición de HED, sin editar notebooks. Crea `__andres_control/hed_definition_audit.R`. Para cada ola 2012–2024: (1) qué variable alimenta `db` en `ENPG_BINGE.RDS` y en `expand_pif.ipynb`, y su texto en el cuestionario de `__enpg/` (número de tragos, si difiere por sexo, período: 30 días o 12 meses); (2) % de bebedores del mes con `db` faltante; (3) % HED entre bebedores del mes con faltantes excluidos y con faltantes = "no", al lado de la cifra publicada por SENDA ("embriaguez"). Exporta `hed_definition_audit.csv` con una columna `flag_audit_item` = TRUE si la ola usa el ítem AUDIT de frecuencia ("6 o más tragos") en vez del ítem de 30 días.

Regla del proyecto: V3 toca dos módulos, AAF de lesiones (`expand_pif`) y escenarios HED (`expand_pif2`). Decide explícitamente si el cambio va en ambos; no se traslada solo.

### V4. Conteo y cambio (15 min)

```r
.t0 <- Sys.time()
# Same two filters as section 8 of the answers file: year of death + age in completed years.
count_2024 <- function(path) {
  arrow::read_parquet(path) |>
    dplyr::filter(year == 2024) |>                                     # year: your year-of-death column
    dplyr::mutate(age = dplyr::if_else(EDAD_TIPO == 1, EDAD_CANT, 0)) |>
    dplyr::filter(age >= 15, age <= 65) |>
    dplyr::count(sex, name = "deaths")                                 # sex: your sex column
}
old <- count_2024("DEFUNCIONES_FUENTE_DEIS_2024_2026_09062026.parquet")
new <- count_2024("DEFUNCIONES_FUENTE_DEIS_2024_2026_15092026.parquet")
print(dplyr::full_join(old, new, by = "sex", suffix = c("_0906", "_1509")))
cat(sprintf("Elapsed: %.2f minutes\n", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
```

Cambio en `expand_pif.ipynb`: reemplazar la ruta en la celda que lee defunciones, mantener los dos filtros, re-correr y validar (§7). Si la reconciliación de muertes con JRT (1188/1188) incluye 2024, dejará de calzar en 2024: es esperado, anotarlo.

---

## 3. Sólo mueven intervalos, o nada

| # | Cambio | Impacto | Tiempo |
|---|---|---|---|
| C1 | Diseño: que `expand_pif` lea la declaración única por ola de `build_enpg_design_waves_2012_2024_list.R` (strata = comuna 2012–2022, exacta en 2022; `ESTRATO` 2024; PSU 2016 reconstruida; 2020 sin conglomerado). Regenerar el manifiesto SHA-256 de los draws | IC y draws; puntuales iguales | 20 min + re-corrida |
| C2 | 2020 sin conglomerado: marcar sus IC como subestimados, o inflar su varianza con el DEFF de 2018 por celda (mismo régimen: UPM = manzana, marco MMM 2015) | IC 2020 | 15 min |
| C3 | `volajohdia_pop` + comentario de advertencia en la celda que escribe `data_binge_sensitivity.rds` (§7 del archivo de respuestas) | Ninguno | 5 min |
| C4 | Exportar el factor OMS por año a `oms_factor_by_year.csv`, para que la microsim use exactamente el mismo | Ninguno en `expand_pif`; coherencia con la microsim | 10 min |
| C5 | 2014: si reportas totales expandidos, usar `RND_F2_MAY_AJUS_com` | Totales 2014 (+25 personas expandidas) | 2 min |

Para saber si C1 cambia algo (1 min, PowerShell, raíz del proyecto):

```powershell
Get-ChildItem -Recurse -Include expand_pif*.ipynb | Select-String -Pattern "svydesign|strata|ids *=" | Select-Object Path, LineNumber, Line
```

- No aparece `strata` → hoy hay conglomerado sin estratos: C1 estrecha un poco los IC.
- Aparece `strata = region` → C1 lo cambia a comuna.

---

## 4. Hallazgos de la semana que NO obligan a tocar expand_pif

1. QC: la serie de SENDA se reproduce (0,2–0,6 pts, 7 olas) → pesos y población analítica correctos.
2. Pesos 2022 calibrados a toda la población urbana regional → sólo afecta totales expandidos; prevalencias y AAF no.
3. Deriva de mortalidad HMD vs DEIS (−3,1 → +3,8 %) → sólo la microsim; `expand_pif` usa conteos DEIS directos.
4. Persistencia EPS (rasgo + AR(1)) → sólo la microsim. Ojo con los nombres: la λ/ρ de `expand_pif2` (el ex-HED sigue bebiendo) no es la λ/φ de persistencia; en la microsim usar `trait_share` y `ar_phi`.
5. Factor OMS fuera de la calibración (§24 del archivo de respuestas) → `expand_pif` ya lo usa sólo en RR: sin cambio.

---

## 5. Decisiones de alcance (ACC), no correcciones

| # | Decisión | Qué cambiaría | Tamaño |
|---|---|---|---|
| D1 | Extender AAF/PIF/YPLL a 66–76 con el puente EPS (§18 del archivo de respuestas) | Muertes atribuibles y YPLL mucho mayores: el grueso de la mortalidad crónica atribuible está en 65+ | Muy grande en absolutos |
| D2 | Universo: exposición urbana (109 comunas) aplicada a muertes nacionales | Supuesto implícito "rural = urbano"; declararlo en métodos | Desconocido; se acota con ENS/CASEN |
| D3 | ENPG 2020 (teléfono, sin autoaplicado, preguntas refraseadas) | Marcar AAF 2020 como no comparable en las figuras de `expand_pif3`, o sacarlo de las tendencias | Sólo presentación |

---

## 6. Diferencias con JRT: qué hay y qué sería nuevo

| Diferencia | Desde | ¿Mueve puntuales? |
|---|---|---|
| Diseño complejo (Kish + conglomerado) | julio | No |
| Estrato = comuna (C1) | propuesta 20-sep | No |
| DEIS 15-09-2026 (V4) | propuesta 21-sep | Sí, sólo conteos 2024 |
| Ex-bebedor a 12 meses (V2), si se adopta | propuesta | Sí |
| HED con faltantes = "no" (V3), si se adopta | propuesta | Sí, lesiones y escenarios HED |

---

## 7. Después de cualquier cambio: validar

1. `EXPAND_PIF_ARTIFACT_VALIDATION=PASS`.
2. Identidad PAF = PIF (eliminación total) y 29/29 celdas de PIF.
3. Mismas filas, causas, estratos sexo × edad y años antes y después; sin `NA` nuevos; AAF dentro de rango.
4. Manifiesto SHA-256 de draws regenerado.
5. Tabla antes/después por causa × sexo, con diferencia relativa.

---

## 8. Orden (≈ 2 h)

1. 5 min — V1.
2. 15 min — V4 (es el mismo conteo de §21 del archivo de respuestas).
3. 45 min — V2, sensibilidad 2024.
4. 30 min — V3, auditoría HED.
5. 20 min — C1, sólo si quieres IC coherentes con la microsim.
