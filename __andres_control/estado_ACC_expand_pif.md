# Estado de `expand_pif` / `expand_pif2` / `expand_pif3` (2026-10-08, cc-cloud)

Una página. Rama `claude/pif2-pif3-nube` (base: `main` = `9ae0714`, que ya incluye el encargo del 2026-10-08).

## Qué está cerrado

- **`expand_pif.ipynb`**: cerrado en `ecf6637`. No se edita ni se re-ejecuta en su lugar. Sus artefactos `_20261007`
  (`aaf_engine_inputs_bundle`, `aaf_nested_by_disease`, `aaf_table5_result`, `Mortality Estimates WHO 2024`) están en git.
  Pendiente del usuario: las celdas 11, 40 y 41 no muestran tabla bajo IRkernel (mismo arreglo que abajo; no aplicado).
- **Decisiones vigentes**: las de `prompt_fable_pif2_pif3_nube_2026-10-08.md` §4 (IHD OMS principal, IS Tabla 5, B5, B12,
  Q13, Q7, Q4, Q8, Q10, Q11, Q12, D3, B14, AAF=1 fuera del PIF, C1 no).

## Qué cambió hoy (código, sin correr con datos reales)

- **`expand_pif2.ipynb`** (parche auditable: `patch_expand_pif2_pif3_20261008.py`; comentarios `# 2026-10-08 cc-cloud:`):
  - Celda 24 (`pif2-run-grid`): la causa del desbordamiento de pila y de las horas de serialización era que
    `clusterApplyLB()` enviaba `run_one()` **con el frame completo del orquestador** (todos los jobs y sus closures RR con
    el entorno del registro) en cada tarea. Ahora los closures distintos se exportan una vez (`pif2_pool_rr`) y cada job
    viaja con índices (`pif2_run_pooled`, ligado a `globalenv()`), igual que `run_aaf_cells_parallel()`. Mismo motor, mismas
    semillas, mismos números. Lo mismo en la celda 37 (lesiones).
  - `PIF2_N_CORES` sustituye el número de workers grabado en el bundle (12, del PC) por el del runner (4).
  - `PIF2_PORTION="<año>|<sexo>"`: las celdas 24, 37 y 48 calculan un trozo y lo guardan en
    `pif2_portions/<stamp>/`; sin la variable, ensamblan los 14 trozos si están todos y si no calculan (`pif2_portion_run`).
    Las celdas 26 y 49 (draws) se detienen en un trozo: los bundles de draws los arma la corrida final.
  - Celdas 13, 28, 30, 54: `pif2_show()` muestra las tablas con `IRdisplay::display_html()` bajo Jupyter.
- **`expand_pif3.ipynb`**: celdas 7 y 63, `pif3_show()` (mismo arreglo). Nada más: ya reporta OMS como "(main)" para IHD.
- **Test**: `test_pif2_split.py` (3 tablas × 2 olas, n_sim 2000): código de `ecf6637` == nuevo, paralelo == serial,
  dividido == sin dividir (1e-12 y draws idénticos). Corre en el job `test` del smoke.
- **Workflow** `.github/workflows/expand-pif2-pif3.yml` (`workflow_dispatch`, entradas `mode`, `stamp`, `slice`):
  - `draws`: ejecuta `expand_pif` a una copia, valida, exige bundles regenerados == `_20261007` (tol. 1e-8, sin marcas
    de tiempo) y sube los draws AAF como artifact (son gitignored).
  - `test` (solo smoke), `slices` (matriz año × sexo; smoke = un trozo cronometrado), `final` (solo full: ensambla,
    `expand_pif2` en su lugar, validador, `expand_pif3` en su lugar, commit a la rama; nunca a `main`).
  - Acción compuesta `.github/actions/r-notebook`: `setup-r` (`r-version: renv`), `setup-renv` (caché), nbconvert, IRkernel.
  - `apply-notebook-patch.yml`: aplica el parche a los notebooks en el runner (de un solo uso; borrar después).

## Qué falta (en orden)

1. **Push**: la sesión nube no tiene permiso de escritura en `ACC1240138/micsim` (git 403, API 403). Hay que instalar la app
   de GitHub de Claude en el repo o subir el bundle desde el PC. Hasta entonces, nada ha corrido en GitHub.
2. Lanzar `apply-notebook-patch` en la rama → lanzar `expand-pif2-pif3` en modo `smoke` → leer tiempos (celdas 24, 37, 48 y
   draws) y el resultado del test → modo `full` → `expand_pif2` y `expand_pif3` ejecutados y commiteados → PR a `main` → GATE 2.
3. Validación epidemiológica (GATE 2, usuario): comparación con la corrida PIF 20260723 (V1 y B1 suben los AAF crónicos),
   recuento B12, draws SHA-256. Un test que pasa no es validación epidemiológica.
4. Decisión pendiente: `expand_pif3` reporta OMS como principal para IHD **e IS**. "IS Tabla 5 principal" (2026-10-06) no
   está implementado: exige sustituir las filas de IS y sus draws en el grid principal. A: dejar OMS principal en ambos y
   declarar Tabla 5 como sensibilidad (recomendado: razón PIF 1,02–1,04; evita B5). B: implementarlo en una corrida posterior.

## Actualización local — 2026-10-08

Este documento conserva arriba el informe histórico de Claude-Fable del bundle (commit `a81ed79`); no acredita ejecución local ni en GitHub. Sus pendientes describen el estado de esa sesión, no las decisiones locales posteriores.

- Se importaron los cambios de código de `expand_pif2.ipynb` y `expand_pif3.ipynb`, preservando las salidas guardadas.
- Por autorización del usuario, el código principal de `expand_pif3` selecciona ahora IS de Tabla 5 PUC, junto con sus draws sincronizados; IHD y las demás causas mantienen WHO/Adam. Esto reemplaza la decisión pendiente del punto 4 del informe histórico.
- Pasaron las comprobaciones sintéticas de selección de fuentes y de sintaxis; la ejecución completa y la validación con datos reales siguen pendientes. No se afirma que el test cloud descrito arriba haya corrido.
- Run All no se ha iniciado: falló la activación de la ventana de Positron y se pidió al usuario ponerla visible para continuar.
- Los workflows, la acción compuesta y los scripts cloud descritos arriba no se importaron. No se hizo commit ni push en esta etapa.
- Registro canónico: [handoff](codex_handoff_adam_rr_full_override_caveman.md).
