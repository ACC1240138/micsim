# Encargo Fable (nube): `expand_pif2` + `expand_pif3` en GitHub, más eficientes

Fecha: 2026-10-08. Base: commit `ecf6637`, rama `claude/pif2-pif3-nube`. Reemplaza las §6–§7 de
`__andres_control/prompt_fable_cierre_expand_pif_2026-10-06.md` (lo demás de ese encargo sigue vigente
salvo donde este lo cambie).

## 1. Objetivo

Correr `expand_pif2.ipynb` (modo `full`) y `expand_pif3.ipynb` **en la nube** con datos reales,
ejecutados dentro del notebook y con los outputs guardados. Antes, hacerlos más rápidos con
`/ponytail:ponytail`.

- **Dónde se corre:** primero GitHub Actions (el repo es público y ya tiene el secreto `ACC_DATA_KEY`).
  Si no cabe ahí, mejora el código en esta sesión de Claude Code en la nube y deja la corrida completa
  pendiente.
- **Nunca en el PC del usuario.** No prepares checklists para correrlo localmente.
- **No-objetivos:** no tocar `expand_pif.ipynb` (cerrado en `ecf6637`), `microsim_*`, `eps_*` ni
  `elasticidad_*`. No agregar causas, grupos CIE ni familias de RR (AGENTS.md §5).

## 2. Qué leer primero

1. `AGENTS.md`.
2. Este archivo.
3. En `__andres_control/codex_handoff_adam_rr_full_override_caveman.md`, las entradas desde
   `2026-10-06 | DESKTOP_NDP_SGTV88L | Claude-Fable` hasta el final (5 entradas). Son el estado real.
4. `__andres_control/prompt_fable_cierre_expand_pif_2026-10-06.md` §3 (reglas de notebooks) y §4 (decisiones).
5. Bajo demanda: `__andres_control/expand_pif_registro_2026-10-06.md` por ID; informes `p5kimi_*` a `p10kimi_*`.

## 3. Estado en `ecf6637`

- **`expand_pif.ipynb`: cerrado. No se edita ni se vuelve a ejecutar en su lugar.** Ya tiene V1, B1, B2,
  B16, B17, C2, C4, el arreglo de lactantes en DEIS y los textos corregidos (categorías `cat1`–`cat4`,
  fallback 2020 → 2018, edades 15–65, DEIS 2012–2023 + 2024). Sus artefactos `_20261007` están en git:
  `aaf_engine_inputs_bundle_20261007.rds`, `aaf_nested_by_disease_20261007.rds`,
  `aaf_table5_result_20261007.rds` y `Mortality Estimates WHO 2024_20261007.xlsx`.
- **`expand_pif2.ipynb`**: ya tiene Q7 (`_mid`, λ = 0,5 derivado draw a draw), Q18 (una sola pasada,
  `sims_cache`), B3, B10 (`PIF_ARTIFACT_STAMP`), Q8 (sin WPP) y PIF declarado parcial (23 causas).
  Smoke serial 2024 / `n_sim` 400: 15/15 PASS. **Nunca terminó una corrida `full`**: la celda 24
  (`pif2-run-grid`) no tiene output guardado.
- **`expand_pif3.ipynb`**: B6, B7, etiquetas Q7 "Half shift", B13. Nunca corrido con los artefactos nuevos.

## 4. Decisiones vigentes (no reabrir)

Las del encargo del 2026-10-06 §4, con estos cambios y cierres posteriores:

| ID | Decisión |
|---|---|
| **IHD** | **OMS 2018/2024 principal (ambos sexos); Tabla 5 (PUC) sensibilidad.** Revierte "IHD/IS Tabla 5 principal" del 2026-10-06 solo para IHD. Motivo: B2 de IHD hombres en Tabla 5 está redondeado (0,000001), y de él dependen 59 de 73 PIF con cambio de signo. Ajustar `expand_pif3` (qué se reporta como principal). Las celdas no se mueven. |
| **IS** | Tabla 5 principal (sin cambio). |
| **B5** | IC de IHD mujeres con Tabla 5 (covarianza diagonal): se queda así; se declara como limitación. |
| **B12** | Opción B: punto plug-in; IC = percentiles Monte Carlo sin forzar; contar las celdas con el punto fuera del IC. |
| **Q13** | Piso 1 en el factor de diseño. |
| **Q7** | Reportar λ = 0, 0,5 y 1, cada uno con su cambio implícito de consumo medio. Principal sugerido: λ = 0. |
| **Q4** | AAF y PIF con signo, netos y por causa. Sin tabla "solo daño" (es limitación). |
| **Q8** | `yll_hmd` principal; GBD TMRLT sensibilidad; legacy solo comparación. |
| **Q10** | Estómago (C16) y páncreas (C25) fuera del principal; se reportan aparte, no dentro de tablas o figuras que replican JRT. |
| **Q11** | Cérvix (C53) excluido por "sin función RR utilizable", no por "no causal". |
| **Q12** | Shield S6 estricto (X30–X39 fuera), declarado. |
| **D3** | ENPG 2020 marcada como no comparable; sin sensibilidad excluyendo 2020 (limitación). |
| **B14** | 2024 provisional (DEIS preliminar; la base oficial 1990–2024 aún no se publica). |
| **AAF=1** | No entran al PIF ("parcial, 23 causas con RR"). |
| **C1** | No (región como estrato; conservador; solo mueve IC). |

## 5. Aprendizajes técnicos (2026-10-07/08, verificados)

1. **Pila de C.** En la celda 24 (`pif2-run-grid`), R se cae por desbordamiento de la pila de C
   (señal 11, `_chkstk`) a los 30 s. ark (Positron) tiene 7,6 MB de pila; R.exe en Windows, 64 MB.
   En Linux, la pila de R es `ulimit -s`, por defecto 8 MB, igual que ark: **en el runner usa
   `ulimit -s unlimited` antes de lanzar Jupyter** y verifica con `Cstack_info()`.
   - Causa probable, no confirmada: R serializa funciones RR que arrastran el entorno completo del
     registro al enviarlas a los workers PSOCK.
   - Precedente: `run_aaf_cells_parallel()` en `aaf_unified.R` envía las funciones una vez y a cada
     tarea solo un índice. Si arreglarlo así es el camino más corto y no cambia resultados, hazlo:
     también permitiría al usuario correrlo en Positron.
2. **IRkernel no muestra `htmltools::browsable()`.** La celda queda vacía. Afecta a `expand_pif2` (celdas
   13 y 54) y `expand_pif3` (celdas 7 y 63). Arreglo de una línea que funciona en ambos kernels:
   `IRdisplay::display_html()` cuando `getOption("jupyter.in_kernel")` es TRUE (IRdisplay ya está en
   `renv.lock` y `DESCRIPTION`).
   - `expand_pif.ipynb` tiene el mismo problema (celdas 11, 40 y 41 sin tabla en `ecf6637`).
     **No lo arregles**: anótalo como pendiente del usuario.
3. **Los draws de AAF no están en git** (`aaf_synchronised_draws_*`, ~95 MB + 8,5 MB, en
   `.gitignore`), pero `expand_pif3` los necesita. Regenéralos en el runner ejecutando `expand_pif` de
   `ecf6637` **hacia una copia** (`nbconvert --output` a un archivo temporal), no en su lugar.
   - Los bundles `aaf_*` regenerados deben ser iguales a los `_20261007` de git (compara los objetos;
     ignora marcas de tiempo). Si difieren, detente y avisa.
   - No hagas commit de bundles duplicados de `expand_pif`.
4. **Tiempos locales** (PC de 20 workers): `run-grid` ~314 min, lesiones ~75, Tabla 5 ~51; ~13 h en
   total antes de Q18 (Q18 ahorra ~6 h).
   - Un runner `ubuntu-latest` (repo público) tiene 4 vCPU, 16 GB y **6 h por job**. Un job `matrix`
     puede usar hasta 20 runners en paralelo; el workflow completo, hasta 72 h.
   - El modo `full` no cabe en un job: hay que dividirlo (ver §6).
5. **Repo público.** Commits y artifacts de Actions son públicos. Solo agregados (AAF, PIF, draws de
   PIF). Nunca subas datos descifrados (AGENTS.md §7).
6. **Específico de Windows (no aplica en la nube):** el crash de R 0xC0000005 (Sophos), Git Bash
   cambiando `HOME` (R no encuentra `~/.Renviron`) y ark con `nbconvert` (metadata `null`).

## 6. Plan

1. **Medir.** Un workflow de prueba en modo `demo` (o un año y un tramo) para medir tiempo, RAM y pila
   por celda pesada (24, 37, 48 y la de draws).
2. **`/ponytail:ponytail`** (si el skill no existe en la nube, aplica su escalera: ¿hace falta? → ¿ya
   existe en el repo? → base R → la forma más corta que funcione). Reglas:
   - Mismo estimador, mismas semillas y números aleatorios comunes; el invariante serial == paralelo se
     conserva.
   - Prueba: una porción pequeña antes y después del cambio, idéntica a 1e-12.
   - Sin funciones intermedias ni archivos `source()` nuevos que el usuario no pueda auditar a ojo.
   - Sin mover, fusionar ni reordenar celdas. Comentario `# 2026-10-08 cc-cloud: <qué y por qué>` en
     cada cambio.
3. **Dividir el modo `full` en porciones** (p. ej., año × sexo), lo más simple posible:
   - Una variable de entorno hace que cada celda pesada corra solo su porción y guarde un `.rds` parcial.
   - El job final ejecuta `expand_pif2` en su lugar: las celdas pesadas cargan las porciones combinadas
     si están todas, y si no, calculan.
   - Comprueba en una porción pequeña que dividido == sin dividir.
4. **Workflow** `.github/workflows/expand-pif2-pif3.yml` (`workflow_dispatch`), con estos pasos:
   1. `setup-r` con `r-version: renv` y `use-public-rspm: false` (ver `data-check.yml`).
   2. `renv::restore()` completo.
   3. Jupyter + `IRkernel::installspec()`.
   4. `ulimit -s unlimited`.
   5. Regenerar los draws de AAF.
   6. Matriz de porciones.
   7. Job final: `expand_pif2` en su lugar → validadores → `expand_pif3` en su lugar.
   8. Commit de los notebooks ejecutados y los artefactos permitidos **a esta rama** (`contents: write`).
      Nunca a `main`.
5. **Si GitHub no alcanza** (tiempo o RAM aun dividido): deja el código mejorado, el workflow y un smoke
   ejecutado en esta sesión. Explica qué falta y cuánto tardaría. No lo mandes al PC del usuario.

## 7. Validación (cada corrida)

- Identidad PIF = (AAF − AAF_cf) / (1 − AAF_cf), tolerancia 1e-9. No usar "PAF = PIF por eliminación
  total" (falla si RR_fd ≠ 1).
- Validador de `expand_pif2`; `validate_paf_draw_regeneration.R`.
- Mismas filas, causas, estratos sexo × edad y años; sin NA nuevos en celdas aplicables; AAF ≤ 1.
- Manifiestos SHA-256 de draws.
- B12: número de celdas con el punto fuera del IC.
- Comparación con la corrida PIF 20260723, explicando las diferencias (V1 y B1 suben los AAF crónicos).
- Un test que pasa no es validación epidemiológica: dilo así.

## 8. Gates

- **Antes de la corrida `full`:** si un cambio de eficiencia modifica cualquier resultado, detente y
  avisa. Si son idénticos, sigue sin preguntar.
- **GATE 2:** el usuario revisa los artefactos finales antes del merge. PR a `main`; nunca push a `main`.

## 9. Entregables (en el PR)

1. `expand_pif2.ipynb` y `expand_pif3.ipynb` ejecutados con outputs guardados (o, si GitHub no alcanza,
   mejorados con smoke ejecutado).
2. El workflow.
3. Actualizar `__andres_control/estado_ACC_expand_pif.md` (crearlo si no existe): una página en español.
4. Una entrada al final del handoff canónico: `YYYY-MM-DD | cc-cloud | Claude-Fable`, estilo caveman.

## 10. Estilo con el usuario

Igual que en el encargo del 2026-10-06 §8:
- primera línea = lo que debe hacer o decidir;
- una decisión por mensaje, con opciones A/B y tu recomendación primero;
- al cerrar, 3 líneas: hecho, falta, qué debe correr o responder;
- nunca reportes como hecho algo que no corriste con datos reales.

MACHINE_ID: `cc-cloud`.
