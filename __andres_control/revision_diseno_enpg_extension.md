# `revision_diseno_enpg_extension.R`: qué hace, dónde se usa y la revisión del 2026-10-26

## Para qué sirve

El script calcula la precisión de diseño de la ENPG por celda año × tramo de edad × sexo, para cuatro preguntas:

- `abs`: abstemio de por vida;
- `form`: exbebedor;
- `hed`: episodio de consumo intenso (HED) en el último mes;
- `consumption`: gramos por día.

Para cada celda entrega el tamaño muestral efectivo de Kish (`neff_kish`) y un factor de conglomerado: el cuadrado de
la razón entre el error estándar con diseño (PSU + región) y el de Kish. En 2020 la PSU no está validada, así que la
celda toma el factor de 2018, que usa el mismo marco muestral.

**Uso.** Solo lo usa `expand_pif.ipynb`:

- La celda `enpg-kish-PSU-corr` lo ejecuta.
- La celda de AAF llama a `design_table_to_engine_lists()` y pasa `neff`, `design_factor`, `neff_consumption` y
  `design_factor_consumption` a `aaf_unified.R`.
- Ahí determinan cuánto varían las simulaciones Monte Carlo de prevalencias (Dirichlet) y de la gamma de consumo.
- Afectan **solo el ancho de los IC** de AAF, PIF y AVPP, nunca la estimación puntual.

**Salidas** (agregadas, en `__andres_control/`): `enpg_design_join_audit.csv`,
`enpg_cluster_factors_by_year_variable_tramo.csv` y `enpg_design_table_cells_extension.csv`.

## Revisión del 2026-10-26: misma población que `expand_pif`

Antes, el script derivaba las variables a su manera, y cada celda medía la precisión de una población distinta de la
que usa el motor de AAF. Ahora replica fila por fila la celda `enpg-consolidate` de `expand_pif`.

| Diferencia corregida | Antes | Ahora (= `expand_pif`) |
|---|---|---|
| Bebedores actuales sin volumen o con volumen 0 | sin categoría: fuera de las celdas `abs`/`form` | `cur_na`: dentro del denominador de `abs`/`form` |
| "Sí ha bebido" sin fecha del último consumo (`oh2` faltante) | contado como exbebedor | estado desconocido: fuera |
| Filas con más de 30 días de consumo, o abstemio con fecha de consumo | se mantenían | se excluyen |
| Población de `hed` y `consumption` | todo bebedor actual con datos | bebedores actuales con volumen positivo, la misma población de la gamma y de las proporciones de HED |
| Volumen | 15,7 g por trago, anclaje fijo de 7,9 L para todos los años | 12 g por trago, factor WHO por año leído de `oms_factor_by_year.csv` |
| Categorías | cortes JRT con huecos (mujeres cat3 hasta 100) | bordes WHO sin huecos ([decisión](decision_categorias_who_12g_2026-10-26.md)); solo `ltabs`, `fd` y `cur_na` entran a los factores |

El factor WHO solo reescala los gramos dentro de un año, así que no cambia ningún factor de diseño.

**Verificación con datos reales.** Contra `data_binge_sensitivity.rds`, los datos que guarda `expand_pif`:

- La tabla año × estado (`ltabs`, `fd`, bebedor actual, desconocido) es idéntica.
- Los bebedores con volumen positivo coinciden en cada año.
- El volumen medio por año coincide exactamente.

El script, además, se detiene si las cuatro poblaciones no son las esperadas.

**Efecto, comparado con la versión anterior** (56 celdas por variable):

| Variable | n total antes → ahora | `neff_kish` ahora / antes | n efectivo corregido (`neff_kish / factor`) ahora / antes |
|---|---|---|---|
| `abs` | 120.015 → 122.968 | mediana 1,02 (0,87 a 1,17) | 0,90 a 1,12 |
| `form` | 120.015 → 122.968 | mediana 1,02 (0,87 a 1,17) | 0,92 a 1,24 |
| `hed` | 45.361 → 44.868 | mediana 0,99 (0,94 a 1,01) | 0,95 a 1,01 |
| `consumption` | 44.880 → 44.868 | 1,00 (0,99 a 1,00) | 1,00 a 1,00 |

Las fuentes de los factores no cambian: 192 celdas tienen factor propio y 32 (2020) toman el de 2018.

**Pendiente.** `expand_pif.ipynb` no se reejecutó. Sus IC de AAF, PIF y AVPP siguen calculados con los factores
anteriores. Al reejecutarlo, la celda `enpg-kish-PSU-corr` toma los nuevos factores; las estimaciones puntuales no se
mueven.
