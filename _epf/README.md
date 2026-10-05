# _epf — Household Budget Survey (EPF, INE)

**Encrypted** microdata. They feed the elasticity module (`__andres_control/elasticidad_consolidado.ipynb`).

| Bundle | Contents |
|---|---|
| `epf_cache.tar.xz.enc` (folder `epf_cache/`) | `epf_2017.rds` and `epf_2022.rds`: harmonised files per wave (beer, wine, spirits). This is what the notebook uses by default |
| `raw/<file>.tar.xz.enc` | one raw INE `.dta` per bundle: `base-cantidades-{viii,ix}`, `base-personas-{viii,ix}` and `ccif-{viii,ix}` |

Each bundle has its `*.md5.csv`. The two `base-gastos-*` files are **not** included: `base-cantidades` already carries the `gasto` column (`elasticidad_epf_handoff.md` §2.1, see `notes/handoffs_historicos/`). `ccif-*` is the product-code dictionary; without it the raw files cannot be interpreted.

## Sources

INE, Household Budget Survey, public Stata files: **VIII EPF** (`*-viii-*`, "wave VIII / 2017" in the code) and **IX EPF** (`*-ix-*`, "wave IX / 2022"). `docs/` keeps the official CCIF correspondence tables (VII–VIII and VIII–IX).

## How to read them and rebuild

```r
source(here::here("_tools", "acc_data.R"))
acc_data("_epf/epf_cache.tar.xz.enc", "epf_2022.rds")                  # harmonised cache
acc_unpack_all("_epf/raw", file.path(tempdir(), "epf_raw"))           # the 6 raw .dta files
```

The notebook rebuilds each wave from the raw files and checks that it reproduces `epf_2017.rds` and `epf_2022.rds` exactly (`elx_run_rebuild`). The original harmonisation scripts are in `jrt/elasticidad/`.
