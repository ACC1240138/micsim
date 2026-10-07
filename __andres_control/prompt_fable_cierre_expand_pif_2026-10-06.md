> **Para Andrés: antes de abrir la sesión en la nube (no pegar este bloque)**
> 1. Commit + push a `main`: este archivo, `expand_pif_registro_2026-10-06.md`, `encargos_kimi_cierre_expand_pif_2026-10-06.md`, `p1kimi_*`–`p5kimi_*`, el handoff canónico, `_deis/README.md` y el bundle `_deis/DEFUNCIONES_FUENTE_DEIS_2024_2026_06102026.tar.xz.enc` + `.md5.csv`.
> 2. En el entorno de la nube, define la variable `ACC_DATA_KEY` (misma clave que `~/.Renviron`).
> 3. Pega todo lo que va desde `--- PEGAR DESDE AQUÍ ---`.

--- PEGAR DESDE AQUÍ ---

# Sesión cloud (Claude Fable): cierre de `expand_pif`

## 1. Objetivo

Dejar AAF, muertes atribuibles, YPLL y PIF (`expand_pif.ipynb` → `expand_pif2.ipynb` → `expand_pif3.ipynb`) corregidos, corridos con datos reales y explicables a ACC, aplicando las decisiones de la §4. Es un cierre **razonable, no exhaustivo**: después el proyecto pasa a la microsimulación, que es la prioridad del usuario (Andrés) y de ACC. Si algo amenaza el plazo, propón declararlo como limitación.

No-objetivos: no trabajar en `microsim_*`, `eps_*` ni `elasticidad_*`; no extender edades más allá de 15–65; no agregar causas, grupos CIE ni familias de RR; no reemplazar funciones RR (AGENTS.md §5).

## 2. Qué leer primero

1. `AGENTS.md`.
2. La entrada `2026-10-06 | DESKTOP_NDP_SGTV88L | Claude` al final de `__andres_control/codex_handoff_adam_rr_full_override_caveman.md` (con sus addenda). Es la fuente de las decisiones.
3. `__andres_control/expand_pif_registro_2026-10-06.md`: registro de issues con verificación en código. Consúltalo por ID cuando lo necesites; no lo leas entero.
4. Bajo demanda: informes de Kimi `__andres_control/p1kimi_*` a `p5kimi_*` (literatura que respalda las decisiones; sus citas ya fueron revisadas, con las correcciones anotadas en el handoff).

## 3. Entorno y forma de trabajo

**Datos.** `ACC_DATA_KEY` está en el entorno. Nunca la imprimas ni la escribas en archivos o comandos; compruébala solo con `nzchar(Sys.getenv("ACC_DATA_KEY"))`. Lee datos solo con `_tools/acc_data.R` (`acc_data()`, `acc_deis()`, `acc_pack()`). Nada individual va a git.

**R.** Instala R y restaura con `renv::restore()`. Si `expand_pif2` (~13 h) no cabe en la sesión, prepara una checklist corta para que el usuario lo corra en su PC (`DESKTOP_NDP_SGTV88L`, Windows, R 4.4.1, Positron; correr desde PowerShell en la raíz) y sigue con lo demás.

**Git.** Trabaja en la rama `claude/cierre-expand-pif` (u otra que crees) y abre un PR a `main`. Nunca push a `main`.

**Los notebooks se corrigen Y se ejecutan dentro del notebook, guardando los outputs.** Ese es el entregable. Ejecuta con `jupyter nbconvert --to notebook --execute --inplace <archivo>.ipynb` (kernel R vía IRkernel; si falta, instala Jupyter e `IRkernel::installspec()` al inicio de la sesión). **Prohibido** reemplazar la ejecución del notebook por una corrida del código extraído a un script: eso no deja outputs en el notebook y obliga al usuario a correrlo de nuevo. Un script extraído solo sirve para una prueba rápida previa. Si el entorno no puede ejecutar notebooks, **detente y avísale al usuario en el primer mensaje**, antes de editar nada; no sigas por otra vía en silencio.

**Notebooks: autorización explícita del usuario.** Puedes editar `expand_pif.ipynb`, `expand_pif2.ipynb` y `expand_pif3.ipynb` y guardar sus outputs. Reglas:
- Cada cambio lleva un comentario en el código: `# YYYY-MM-DD cc-cloud: <qué cambió y por qué>`.
- **No cambies la estructura de los notebooks.** No muevas, fusiones ni reordenes celdas. Las celdas de la Tabla 5 (PUC) se quedan donde están, al final.
- Código **legible y autocontenido dentro de la celda**. Usa `/ponytail:ponytail` para elegir la forma más directa, pero sin agregar funciones intermedias ni archivos `source()` nuevos difíciles de auditar a ojo. El usuario tiene que poder seguir su propio notebook.
- Conserva los nombres de objetos y tablas que usan las celdas siguientes.
- R: `pkg::fun`, `.t0 <- Sys.time()` al inicio y minutos transcurridos al final, comentarios en inglés, rutas con `acc_root()` / `here::here()`.
- Valida el JSON del notebook después de editar (jsonlite).

**MACHINE_ID** de esta sesión: `cc-cloud`.

## 4. Decisiones fijadas (no reabrir sin evidencia nueva)

| ID | Decisión |
|---|---|
| **V1** | Corregir el factor OMS: el consumo **per cápita de toda la población** (abstemios y exbebedores = 0) se iguala a 0,8 × APC; la media de bebedores = 0,8 × APC / p_actual. Unir el factor por año, sin redondear ni indexar por posición. Evidencia: salida guardada `ms-apc-audit` (media de bebedores = 0,8 × APC en las 7 olas); Rehm 2010. |
| **APC** | Serie OMS GHO total SA_0000001688 (vintage 2026-06-15): 2012 = 7.21, 2014 = 7.17, 2016 = 7.23, 2018 = 6.98, 2020 = 7.09, 2022 = 6.99, 2024 = 6.58 (2024 = 2023 arrastrado). Densidad 0,789. Factor 0,8. Revisa si el usuario ya cambió estos valores en el notebook. |
| **V2** | Exbebedor = último trago hace >30 días. Sin cambio. |
| **V3** | HED faltante no se recodifica como "no"; se excluye solo del denominador del indicador HED. |
| **B1** | Sin imputación múltiple. Convención OMS (GHO 458/459) y Rehm 2010: un faltante de ítem sale solo del denominador de ese indicador; la persona sigue en la prevalencia de bebedor actual. Hoy desaparece del cálculo (`cvolaj` NA → fuera de `p_abs/p_form` y de la gamma): corregir eso. |
| **B2** | Filtrar las causas AAF = 1 a los años de ola en el `bind_rows` de la celda 49 (no en la celda 15, donde `aaf_long` todavía no existe). |
| **B5** | IHD mujeres con Tabla 5: intervalos no confiables (covarianza diagonal). Nota en la tabla; busca si el paper PUC publica SE o covarianzas que permitan mejorarlos. |
| **B14** | 2024 = provisional (DEIS semanal preliminar). No extrapolar. Se vuelve a correr cuando DEIS publique cifras oficiales. |
| **DEIS** | Usar la versión más reciente (`06102026`) y **escribir cuál se usó** en los outputs; no fijar `ACC_DEIS_VERSION`. 2024 es idéntico entre versiones. |
| **D1** | Edad 15–65 (igual que el motor de microsimulación). Cota inferior declarada. |
| **D2** | Exposición urbana aplicada a muertes nacionales: declarar. |
| **D3** | ENPG 2020 en el cálculo, marcada como no comparable en figuras y tablas. |
| **C2** | 2020 sin conglomerado: tomar el factor de diseño de **2018** (mismo régimen), no de 2022 (`revision_diseno_enpg_extension.R`, regla de fallback). |
| **C3** | Resuelto. |
| **C4** | Exportar el factor OMS por año (`oms_factor_by_year.csv`, agregado) para la microsimulación. |
| **C5** | Descartado. |
| **IHD/IS** | Tabla 5 (PUC) como fuente principal; WHO/Adam como sensibilidad. Solo cambia qué se reporta como principal; las celdas no se mueven. |
| **AAF=1 en PIF** | No entran. PIF declarado "parcial, 23 causas con RR". |
| **Q7 (λ ex-HED)** | Reportar 3 escenarios: λ = 0, 0,5 y 1. λ = 0,5 es el punto medio lineal exacto de los otros dos (también draw a draw): no requiere correr nada nuevo. Cada λ con su cambio implícito de consumo medio: corrige `volume_reduction_pct`, que hoy declara 0 en filas con λ > 0. |
| **Q4** | AAF y PIF con signo; reportar por causa y neto. Sin tabla "solo daño". |
| **Q8** | `yll_hmd` principal; GBD TMRLT como sensibilidad; legacy solo como comparación. Borrar la frase sobre una sensibilidad WPP en `expand_pif2` (celda 41), que nunca se implementó. |
| **Regla de oro** | Eliminada. No hay que reproducir 20260723 antes de corregir: se compara contra 20260723 **después**, explicando cada diferencia. |

## 5. Lo que decides tú, con fundamento breve

- **C1 (diseño por ola).** El usuario se inclina por aplicarlo; fundamenta y decide. Propuesta del usuario (en `microsim_respuestas_preguntas_2026-09-20.md`, tabla cerca de la línea 333): strata = comuna 2012–2018, `COD_COMUNA` 2022 (estrato exacto), PSU 2016 reconstruida (comuna + distrito + zona + manzana), `UPM` + `ESTRATO` 2024, 2020 sin conglomerado. Solo mueve intervalos.
- **Q18.** La optimización de una sola pasada (`return_sims = TRUE`, ahorra ~6 h en `expand_pif2`). Evalúa con `/ponytail:ponytail` si vale el riesgo.
- **Errores internos del registro** (B3, B6, B7, B10, B12, B13, B16, B17, B20 y similares): corrígelos sin consultar si no cambian decisiones. Si alguno cambia resultados puntuales, avisa antes.

**Pendiente del usuario:** Q10 (cáncer de estómago y páncreas). Propuesta: fuera del principal (IARC + Shield 2025 S6), con ellos como sensibilidad (`mortality_results_who_scope` ya existe). Pregúntale antes de la corrida de `expand_pif`.

## 6. Secuencia

1. Aplica los cambios de §4 y §5 en `expand_pif.ipynb` y scripts asociados.
2. Corre `expand_pif` (~45 min). Escribe una tabla antes/después contra 20260723 por causa × sexo, con diferencia relativa. Esperado:
   - AAF crónicos suben (V1);
   - muertes de 15–29 cambian (corrección de lactantes en DEIS 2012–2023);
   - desaparecen los años impares de AAF = 1 (B2).
   Si algo se mueve en otra dirección, investiga antes de seguir.
3. `build_ypll.R` + `test_ypll_death_base.R`. Debe pasar.
4. **GATE 1:** muéstrale al usuario la tabla antes/después y la explicación. No sigas sin su ok.
5. `expand_pif2` (~13 h), en la nube o en el PC del usuario.
6. `expand_pif3`.
7. Comprueba que la celda `ms-apc-audit` de `microsim_base` lee el bundle nuevo (7 olas, 4 columnas). Solo esa comprobación: no trabajes en microsim.
8. **GATE 2:** el usuario revisa los artefactos finales antes del merge.

**Validación** (en cada corrida):
- identidad PIF = (AAF − AAF_cf) / (1 − AAF_cf), con tolerancia 1e-9. **No** uses "PAF = PIF por eliminación total": no vale si RR_fd ≠ 1;
- mismas filas, causas, estratos sexo × edad y años; sin NA nuevos; AAF ≤ 1;
- manifiestos SHA-256 de draws regenerados;
- re-empaquetar `data_binge_sensitivity` con `acc_pack()` y pasar `_tools/check_bundles.R`.

Un test que pasa no es validación epidemiológica: dilo así.

## 7. Entregables (en el PR)

1. Notebooks y scripts corregidos, con outputs guardados.
2. Tabla antes/después (CSV agregado).
3. `__andres_control/estado_ACC_expand_pif.md`: una página en español con qué cambió, cifras antes/después, qué está validado y las limitaciones.
4. Una entrada al final del handoff canónico: `YYYY-MM-DD | cc-cloud | Claude`, en estilo caveman, con lo hecho y lo pendiente.

Los textos de métodos en inglés ya los tiene el usuario; no los redactes de nuevo salvo que una decisión cambie.

## 8. Estilo con el usuario

El usuario tiene poca memoria de trabajo disponible para esto.
- Primera línea = lo que debe hacer o decidir.
- Una decisión por mensaje, con opciones A/B y tu recomendación primero.
- Al cerrar cada sesión, 3 líneas: qué quedó hecho, qué falta, qué debe correr o responder.
- Nunca reportes como hecho algo que no corriste con datos reales.
