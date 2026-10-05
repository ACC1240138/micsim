# _epf — Encuesta de Presupuestos Familiares (EPF, INE)

Microdatos **cifrados**. Alimentan el módulo de elasticidades (`__andres_control/elasticidad_consolidado.ipynb`).

| Paquete | Contenido |
|---|---|
| `epf_cache.tar.xz.enc` (carpeta `epf_cache/`) | `epf_2017.rds` y `epf_2022.rds`: bases armonizadas por ola (cerveza, vino, destilados). Es lo que usa el notebook por defecto |
| `raw/<archivo>.tar.xz.enc` | un `.dta` crudo del INE por paquete: `base-cantidades-{viii,ix}`, `base-personas-{viii,ix}` y `ccif-{viii,ix}` |

Cada paquete trae su `*.md5.csv`. Los dos archivos `base-gastos-*` **no** se incluyen: `base-cantidades` ya trae la columna `gasto` (`elasticidad_epf_handoff.md` §2.1, ver `notes/handoffs_historicos/`). `ccif-*` es el diccionario de códigos de producto; sin él el crudo no se interpreta.

## Fuentes

INE, Encuesta de Presupuestos Familiares, bases públicas en Stata: **VIII EPF** (`*-viii-*`, «wave VIII / 2017» en el código) y **IX EPF** (`*-ix-*`, «wave IX / 2022»). `docs/` guarda las tablas oficiales de correspondencia CCIF (VII–VIII y VIII–IX).

## Cómo leerlos y reconstruir

```r
source(here::here("_tools", "acc_data.R"))
acc_data("_epf/epf_cache.tar.xz.enc", "epf_2022.rds")                  # caché armonizada
acc_unpack_all("_epf/raw", file.path(tempdir(), "epf_raw"))           # los 6 .dta crudos
```

El notebook reconstruye cada ola desde el crudo y controla que reproduzca exactamente `epf_2017.rds` y `epf_2022.rds` (`elx_run_rebuild`). Los scripts de armonización originales están en `jrt/elasticidad/`.
