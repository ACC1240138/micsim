# micsim — FONDECYT 1240138

Microsimulación de políticas de alcohol en Chile: mortalidad atribuible (PAF/AAF, YPLL), contrafactuales de política (PIF), elasticidades (EPF) y simulación. Contiene los notebooks de trabajo, los scripts que cargan, sus resultados agregados recientes y los lineamientos del proyecto (`AGENTS.md`).

Los **microdatos** (ENPG, EPS, DEIS, EPF) están en el repo **solo cifrados**; nunca en claro.

## Datos y clave

Paquetes `*.tar.xz.enc` (tar.xz + AES-256-CTR + HMAC-SHA256), cada uno con su `*.md5.csv` (nombres, tamaños y md5; no datos). La clave está en la variable de entorno `ACC_DATA_KEY`:

1. Pídela al equipo (o recupérala del gestor de contraseñas).
2. Agrégala a `~/.Renviron` con `usethis::edit_r_environ()` (`ACC_DATA_KEY=...`) y reinicia R.
3. Verifícala sin imprimirla: `nzchar(Sys.getenv("ACC_DATA_KEY"))`.

La clave **nunca** va en archivos, en la línea de comandos ni en el chat. En GitHub vive como secreto del repositorio.

Todo acceso a los datos pasa por `_tools/acc_data.R` (`source(here::here("_tools", "acc_data.R"))`): `acc_data()` descifra un paquete a `tempdir()` por sesión, `acc_deis()` entrega DEIS 2024+, `acc_pack()` escribe un paquete nuevo. Los intermedios derivados de microdatos se escriben con `acc_pack()`, nunca en claro dentro del repo.

| Carpeta | Contenido | Detalle |
|---|---|---|
| `_enpg/` | ENPG 2008–2024 y derivados | [README](_enpg/README.md) |
| `_eps/` | EPS 2012–2023 | [README](_eps/README.md) |
| `_deis/` | Defunciones DEIS 2012–2023 y 2024+ | [README](_deis/README.md) |
| `_epf/` | EPF (caché y crudo del INE) | [README](_epf/README.md) |
| `_bib/` | PDF de referencia cifrados y `references.bib` | [README](_bib/README.md) |
| `_sessions/` | transcripciones de chats de Claude Code, cifradas | ver abajo |
| `jrt/` | código y salidas de referencia del equipo JRT | [README](jrt/README.md) |
| `notes/` | handoffs históricos (no canónicos) | — |
| `__andres_control/` | notebooks, scripts, artefactos y outputs | — |

## Paquetes de R

R ≥ 4.4. Núcleo (cargador de datos y pruebas): `openssl`, `data.table`, `nanoparquet`, `arrow`, `haven`, `here`, `jsonlite`.

Los notebooks usan además: `dplyr`, `tidyr`, `purrr`, `tibble`, `stringr`, `forcats`, `tidyselect`, `readr`, `readxl`, `writexl`, `rio`, `janitor`, `ggplot2`, `scales`, `gridExtra`, `patchwork`, `htmltools`, `DT`, `knitr`, `IRdisplay`, `quarto`, `survey`, `sandwich`, `MASS`, `mvtnorm`, `fitdistrplus`, `gtools`, `MicSim`, `digest`, `withr`, `rvest`, `xml2`, `zip`, `IRkernel` y `devtools` (esta última solo para la información de sesión). La lista sale de los vectores de paquetes de cada notebook; cada uno avisa al inicio qué paquete falta.

## Entorno de R reproducible (renv)

`renv.lock` fija las **versiones exactas** de los 169 paquetes (los de `DESCRIPTION` más sus dependencias) y el repositorio: un snapshot **fechado** de Posit Package Manager (`https://packagemanager.posit.co/cran/2026-04-23`). Así el entorno es el mismo hoy que dentro de un año.

- **En un clon:** abre R en la raíz (el `.Rprofile` activa `renv` solo) y corre `renv::restore()`. Luego `Rscript _tools/test_acc_data.R`.
- **La biblioteca no va en git:** queda en la caché de `renv` del usuario (`renv::paths$library()`); lo que se versiona es `renv.lock`.
- **Si agregas un paquete:** `renv::install("paquete")`, lo anotas en `Imports` de `DESCRIPTION` y corres `renv::snapshot()`; commitea `renv.lock`.
- **Reconstruir desde cero** (solo si hay que cambiar la fecha o el conjunto de paquetes): `Rscript _tools/renv_setup.R`. Esa fecha es el día siguiente al paquete más reciente de la clausura de dependencias al momento de crearlo (`ggplot2` 4.0.3 y `curl` 7.1.0, del 2026-04-22).
- `.renvignore` excluye `jrt/`, `notes/` y las carpetas de documentos: su código heredado carga paquetes que no son del proyecto.
- La CI (`data-check`) desactiva el autoloader de `renv`: solo necesita `openssl` y `data.table`.

## Pruebas (desde la raíz)

```
Rscript _tools/test_acc_data.R   # prueba del cifrado/descifrado (~1 s)
Rscript _tools/check_bundles.R   # descifra todos los paquetes y compara md5 con su .md5.csv (~2 min)
Rscript _tools/smoke_data.R      # lectura básica de cada fuente
```

`.github/workflows/data-check.yml` corre la verificación de paquetes en GitHub (requiere el secreto `ACC_DATA_KEY`).

## Orden de los notebooks (`__andres_control/`)

1. `eps_alcohol_prevalencia_persistencia.ipynb` (EPS; ~1 min) — informe: `eps_alcohol_prevalencia_persistencia_informe.md`.
2. `elasticidad_consolidado.ipynb` (EPF).
3. `microsim_base_ACC_2012_2024.ipynb` y `microsim_recalib_ACC_2012_2024.ipynb` (~1 min cada uno) — explicación: `microsim_base_ACC_2012_2024_explicacion.md`.
4. `expand_pif.ipynb` (~45 min): AAF, mortalidad atribuible y YPLL.
5. `expand_pif2.ipynb` (~13 h) y `expand_pif3.ipynb`: PIF con draws sincronizados y tablas/figuras. **Los draws no están en el repo**; se regeneran con `expand_pif` → `expand_pif2`.
6. `guion_reunion_ACC_2026-09-16_revision_critica.ipynb`: revisión crítica (lee artefactos ya guardados).

El handoff canónico es `__andres_control/codex_handoff_adam_rr_full_override_caveman.md` (ver `AGENTS.md` §1). Hoja de ruta: `presentacion_micsim.qmd` / `.html`.

## DEIS semanal

Descarga `DEFUNCIONES_FUENTE_DEIS_2024_2026_<DDMMYYYY>.zip` a `_deis/` (git lo ignora) y corre `source("_tools/acc_data.R"); acc_deis_update()`. Detalle en [_deis/README.md](_deis/README.md).

## Chats de Claude Code

Para retomar una conversación: `source("_tools/acc_data.R"); acc_unpack_all("_sessions", "~/.claude/projects/<carpeta de la ruta del clon>")`. La carpeta se nombra según la ruta del clon (p. ej. `C--Users-nDP-Documents-micsim`); ábrela una vez con Claude Code en el clon para ver el nombre exacto.

## Política de datos

- Ningún microdato en claro: sin `.dta`, `.sav`, `.parquet`, `.zip` ni `.jsonl` en git (ver `.gitignore`).
- Solo se versionan resultados **agregados**; los outputs de notebooks no deben mostrar filas individuales.
- Se cita el paquete SIMAH por DOI (`10.5281/zenodo.15641639`) en lugar de vendorizarlo.
