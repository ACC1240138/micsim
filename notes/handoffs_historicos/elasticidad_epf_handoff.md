# Modulo Elasticidad (EPF) - Handoff tecnico

**Fecha:** 2026-08-10 13:31
**Alcance:** auditoria del modulo `Elasticidad/`, reconstruccion del pipeline desde microdato INE,
diagnostico del metodo de precios, margen extensivo, y encuadre respecto de la microsimulacion.
**Notebook asociado:** `Elasticidad/elasticidad_consolidado.ipynb`
**Entorno:** `Elasticidad/env/` (snapshots BEFORE/AFTER + lockfiles)

**Leyenda de verificacion.** [V] = ejecute codigo contra los archivos reales y lo verifique.
[S] = fuente secundaria leida pero no reejecutada. [I] = inferencia. [NV] = no verificado.

---

## 0. Lo que hay que leer primero

1. **El pipeline ya es reproducible desde el microdato crudo otra vez** (seccion 2). Ambas olas se
   reconstruyen **exactas** contra los `.rds` sobrevivientes.
2. **El "precio" tipo Deaton no es un precio, es un indice de afluencia** (seccion 3). Esto explica
   los signos raros que reportaron ACC/JRT y bloquea el margen extensivo.
3. **La implementacion de referencia (SIMAH/Kilian) NO estima elasticidades**: las importa de un
   meta-analisis (seccion 5). Eso cambia la pregunta de trabajo.

---

## 1. Estado del modulo al 2026-08-10

### 1.1 Archivos

| Archivo | Estado |
|---|---|
| `Data/epf_2017.rds`, `Data/epf_2022.rds` | presentes; 44.997 y 44.883 filas (3 por hogar) |
| `Data/original_ine/` (10 archivos) | **presentes** - agregados por el usuario el 2026-08-10 |
| `quantities_*.rds`, `people_*.rds`, `quant.rds`, `*_red.rds` | ausentes (intermedios, ya no necesarios) |
| `DATA_EPS_2217_LONG.rds`, `DATA_EPS_2217_WIDE.rds`, `hh_model.csv` | ausentes |
| `Data/Bases de datos EPS VIII Ronda/` | **borrada por el usuario** (era EPS, no EPF; error de comprension ya resuelto) |

Consecuencia: `Elasticity 17_03.R`, `quaids_two_step_deaton.R` y `SENSITIVITY.R` **no pueden correr**
tal cual, porque leen los dos archivos ausentes. `EPF ARMONIZATION.R` si puede correr, ahora que estan
los crudos, salvo por el bug de la seccion 1.3.

### 1.2 Paquetes [V]

`fixest`, `systemfit` y `margins` **no estaban instalados**. Instalados el 2026-08-10:
`fixest 0.14.0`, `systemfit 1.1-30`, `marginaleffects 0.32.0` (+ `dreamerr`, `stringmagic`, `insight`).
`margins` esta **archivado en CRAN**; `marginaleffects` es su sucesor mantenido.

**Este proyecto NO usa renv** [V]. No existe `renv.lock` ni carpeta `renv/` en el repositorio; se
trabaja contra la libreria de usuario `C:/Users/nDP/AppData/Local/R/win-library/4.4`. El unico
`renv.lock` de la maquina esta en `C:\Users\nDP\Desktop\josefina\` (otro proyecto).

Snapshots creados en `Elasticidad/env/`:
- `library_snapshot_BEFORE.csv` / `renv_BEFORE.lock` (313 paquetes, antes de instalar)
- `library_snapshot_AFTER.csv` / `renv_AFTER.lock` (319 paquetes)
- **Verificacion de compatibilidad [V]: 6 paquetes agregados, 0 eliminados, 0 cambios de version en
  paquetes preexistentes.** La instalacion fue puramente aditiva.

Nota: `microsimpackage 0.0.0.9000` esta instalado desde fuente desconocida (es el paquete de SIMAH,
vendorizado en `SIMAH/supp/SIMAH_release-0.1.1/`). renv advierte que no podra restaurarlo.

### 1.3 Bugs confirmados en el codigo heredado [V]

| # | Archivo:linea | Problema |
|---|---|---|
| B1 | `EPF ARMONIZATION.R:598` | `hh_bev` no se asigna en ninguna parte -> el script **aborta** ahi; `DATA_EPS_2217_WIDE.rds` nunca se produjo |
| B2 | `Elasticity 17_03.R:290,291,314,419,422,426,448` | `m_part`, `m_part22`, `f_part` **usados y nunca definidos** en todo el repo -> toda la seccion 7 es codigo muerto |
| B3 | `Elasticity 17_03.R:67` | `extensive_elasticity_probit()` definida y **nunca llamada** (1 solo grep hit) |
| B4 | `EPF ARMONIZATION.R:513,514,534` | ambas olas divididas por **la misma** constante UF 39.733,94 -> **no hay deflactacion**, solo cambio de unidades |
| B5 | `EPF ARMONIZATION.R:402-407` | mapa 2017 **omite** `OTROS LICORES N.C.P.` (gasto 3.174.524) e incluye `DESTILADOS Y LICORES (ND)`, cadena que **no existe** en la ola VIII |
| B6 | `EPF ARMONIZATION.R:13-28` | mapa 2022 **omite todo el alcohol de consumo fuera del hogar** (~28,5 millones, ~13,5% del gasto en alcohol de la ola IX) |
| B7 | `quaids_two_step_deaton.R:115`, `SENSITIVITY.R:168,241` | el probit de etapa 1 **no incluye ningun precio** -> la elasticidad de participacion no esta identificada ahi |
| B8 | `EPF ARMONIZATION.R:36-45` | `gasto_tot` se calcula sobre el archivo de **cantidades**, que cubre solo ~25% del gasto del hogar (ver 2.4) |
| B9 | `EPF ARMONIZATION.R:69` | en 2022 `unidad_medida` se fija a `"ML"` sin convertir; hay filas con `-77` y `UNID` que quedan tratadas como ML |
| B10 | `EPF ARMONIZATION.R:356-370` | el algoritmo de quintil de 2017 duplica el peso de los hogares frontera (fe + distancia + distancia_2 = 2*fe); el de 2022 no. Efecto numerico chico (4 hogares) pero es asimetria real |

---

## 2. RECONSTRUCCION DESDE MICRODATO INE [V] - lo mas importante de este handoff

### 2.1 Los archivos crudos y que es cada uno

Carpeta: `Elasticidad/Data/original_ine/`

| Archivo | Ola | ncol | nrow | Rol |
|---|---|---|---|---|
| `base-cantidades-viii-epf-(stata).dta` | VIII (2016-17) | 19 | 1.026.055 | **gasto + cantidad** por hogar x producto |
| `base-cantidades-ix-epf-stata.dta` | IX (2021-22) | 22 | 958.198 | idem |
| `base-gastos-viii-epf-(stata).dta` | VIII | 14 | 1.064.239 | gasto sin cantidad (no se usa) |
| `base-gastos-ix-epf-stata.dta` | IX | 14 | 970.773 | idem |
| `base-personas-viii-epf-(stata).dta` | VIII | 247 | 48.308 | sociodemografia + ingreso/gasto del hogar |
| `base-personas-ix-epf-stata.dta` | IX | 314 | 44.688 | idem |
| `ccif-viii-epf-(stata).dta` | VIII | 7 | 1.668 | diccionario codigo -> glosa |
| `ccif-ix-epf-stata.dta` | IX | 7 | 1.666 | idem |
| `tabla-de-correspondencia-*.xlsx` | - | - | - | mapeo CCIF entre olas |

**El archivo `gastos` NO se necesita**: `cantidades` ya trae la columna `gasto`. [V]

### 2.2 Las trampas de casing e identificadores (lo que costo mas caro)

| Aspecto | Ola VIII (2017) | Ola IX (2022) |
|---|---|---|
| casing de `cantidades` | **minuscula** | minuscula |
| casing de `personas` | **MAYUSCULA** | minuscula |
| glosa de producto | `glosa` | `glosa_ccif` |
| estrato | `varstrat` | `estrato_muestreo` |
| conglomerado | `varunit` | `var_unit` |
| unidad de cantidad | **`LT`** (litros) | **`ML`** (mililitros) |
| `folio_v` en `cantidades` | **numerico** (1, 2, 3...) | numerico |
| `folio_v` en `personas` | **caracter con ceros** (`"00001"`) | numerico |

**TRAMPA CRITICA [V]:** en la ola VIII, `personas.FOLIO_V` viene como caracter rellenado con ceros
(`"00001"`) mientras `cantidades.folio_v` es numerico (`1`). Si se hace `as.character()` sin
`as.numeric()` primero, el join conserva **solo 5.000 de 14.999 hogares** (los que ya tienen 5
digitos, es decir 10000-14999) y **no da error**. Por eso `EPF ARMONIZATION.R:266` hace
`as.numeric(folio_v)`: no es gratuito, es el arreglo. Yo cai en esta trampa y la detecte con el
control de la seccion 2.3.

**Unidades [V]:** la conversion `LT -> ML` de 2017 es correcta y necesaria; la ausencia de conversion
en 2022 tambien es correcta porque el crudo ya viene en ML. La mediana de cantidad positiva queda
comparable entre olas (cerveza 5.914 ml en 2017 vs 5.468 ml en 2022).

### 2.3 Receta de reconstruccion, y el CONTROL que la valida

Pasos (implementados y probados; el codigo vive en el notebook, chunk `elx-rebuild-from-ine`):

1. Leer `cantidades` de la ola. Renombrar a nombres canonicos (`glosa_ccif`->`glosa_raw`,
   `varstrat`/`estrato_muestreo`->`estrato_muestreo`, `varunit`/`var_unit`->`var_unit`).
2. Convertir unidades a **ML** de forma explicita, abortando ante unidades desconocidas.
3. Mapear la glosa a Beer / Wines / Spirits (ver 2.5 para los mapas verificados).
4. `hogares` = por `folio_v`: `first()` del diseno + `gasto_tot = sum(gasto)`.
5. `alcohol_sum` = por `folio_v` x bebida: suma de `cantidad` y `gasto`.
6. `crossing()` -> panel balanceado de **3 filas por hogar**, ceros donde no hubo compra.
7. Leer `personas`. **Si es la ola VIII, `as.numeric(FOLIO_V)` antes de nada.** Construir
   `educ_hhh` (recodificacion de 5 niveles con `edunivel` x `edutermina`), `age_hhh`, `sex_hhh`,
   `prop_wm`, `prop_15yo`, `npersonas`, y el quintil ponderado por `fe`.
8. Sufijar `folio_v` y `var_unit` con la ola (`_17` / `_22`).
9. `inner_join` por `folio_v`, `fe`, `var_unit`, `estrato_muestreo`.

**CONTROL [V] - la condicion de aprobacion.** Reconstruir y comparar contra los `.rds` sobrevivientes:

| Ola | filas nuevas / viejas | hogares nuevos / viejos | variables con filas discrepantes |
|---|---|---|---|
| IX (2022) | 44.883 / 44.883 | 14.961 / 14.961 | **0** en las 9 comparadas |
| VIII (2017) | 44.997 / 44.997 | 14.999 / 14.999 | **0** en las 9 comparadas |

Variables comparadas: `cantidad_oh`, `gasto_oh`, `gasto_tot`, `npersonas`, `age_hhh`, `sex_hhh`,
`educ_hhh`, `prop_wm`, `prop_15yo`. (Dos dan `all.equal FALSE` con **0 filas** discrepantes: es
diferencia de atributos `haven` labelled vs numerico, no de valores.)

**Conclusion: el pipeline es reproducible de extremo a extremo otra vez.**

### 2.4 `gasto_tot` NO es el gasto total del hogar [V]

| Medida (ola VIII) | Mediana |
|---|---|
| `sum(gasto)` sobre el archivo `cantidades` | 181.742 |
| `GASTOT_HD` del archivo `personas` | 752.657 |
| **razon** | **0,248** |

El archivo `cantidades` solo cubre bienes con cantidad medible (~25% del gasto). El pipeline usa ese
subtotal como `gastot_uf` y por lo tanto como `ln_totexp` en la primera etapa de Deaton y como
presupuesto del hogar. **La variable correcta es `GASTOT_HD` / `gastot_hd` de `personas`.** Cambiarlo
altera el control de calidad de Deaton y la elasticidad gasto.

### 2.5 Mapas de categoria verificados contra el dato real [V]

Glosas de alcohol **efectivamente presentes en el archivo de compras** (no en el diccionario):

**Ola VIII (2017)** - unidad LT: `CERVEZA`, `VINO`, `PISCO`, `WHISKY`, `VINOS ESPUMOSOS`,
`CÓCTELES Y CREMAS DE LICOR`, `RON`, `OTROS LICORES N.C.P.`, `VODKA`,
`CHICHA, SIDRA Y OTROS VINOS N.C.P.`

**Ola IX (2022)** - unidad ML: `CERVEZAS CON ALCOHOL`, `VINO DE UVAS`, `WHISKY`,
`VINO ESPUMOSO DE UVAS`, `PISCO`, `CÓCTELES Y CREMAS DE LICOR CON ALCOHOL`,
`OTROS DESTILADOS Y LICORES N.C.P.`, `CERVEZAS CON BAJO CONTENIDO DE ALCOHOL O SIN ALCOHOL`, `RON`,
`VODKA`, `OTROS VINOS DE UVAS N.C.P.`, `OTRAS BEBIDAS ALCOHÓLICAS CON ALCOHOL...N.C.P.`,
`VINO DE UVAS Y VINO ESPUMOSO...SIN ALCOHOL`, `VINO DE OTRAS FRUTAS Y CEREALES`,
`CÓCTELES Y CREMAS DE LICOR CON BAJO CONTENIDO...`, `VINO DE OTRAS FRUTAS O CEREALES CON BAJO...`
**mas** las de consumo fuera del hogar (ver abajo).

**ASIMETRIA DE COBERTURA ENTRE OLAS - importante y no obvia [V].** En la ola IX el archivo de
cantidades **si** incluye alcohol consumido fuera del hogar (`CERVEZAS ADQUIRIDAS EN RESTAURANTES...`,
`VINOS ADQUIRIDOS EN RESTAURANTES...`, `OTRAS BEBIDAS ALCOHÓLICAS...RESTAURANTES...`,
`BEBIDAS ALCOHÓLICAS...COMERCIO AMBULANTE`), por unos **28,5 millones de pesos**, ~13,5% del gasto
en alcohol de la ola. En la ola VIII esas categorias **no aparecen en el archivo de cantidades**.
El mapa heredado las descarta en ambas olas, lo que por casualidad mantiene comparabilidad, pero:
- si se decide **incluirlas**, hay que hacerlo solo en IX y documentar que VIII no las tiene;
- si se decide **excluirlas**, hay que decir que el estimando es alcohol **off-premise**.
Esta decision esta pendiente y afecta la comparabilidad entre olas mas que la deflactacion.

Ademas, `GASTOS NO DESGLOSADOS EN BEBIDAS ALCOHÓLICAS, TABACO Y ESTUPEFACIENTES` (12,8M en VIII;
10,3M en IX, unidad `COMPRA`) es alcohol+tabaco sin desagregar: correctamente excluido, pero es una
fuente adicional de censura.

---

## 3. El diagnostico central: el precio no es un precio [V]

`Elasticity 17_03.R:109-139` estima el precio como **efecto fijo de cluster** de la regresion de
`ln(valor unitario)` sobre gasto total y demografia. El "mercado" es `estrato_muestreo` x ola.

Reproduje esa especificacion exacta y la audite:

| Bebida | corr(precio Deaton, riqueza del cluster) | R2(precio ~ riqueza + ola) |
|---|---|---|
| Cerveza | +0,574 | 0,523 |
| Vino | +0,755 | 0,685 |
| Destilados | +0,675 | 0,592 |

**Entre 52% y 69% del "precio" es riqueza del cluster mas inflacion.** El control por gasto del hogar
en la primera etapa no lo arregla **por construccion**: opera *dentro* del cluster, y la diferencia de
calidad *entre* clusters es exactamente lo que el efecto fijo absorbe y luego se usa como precio.

Gradiente de participacion (deberia ser negativo en las tres columnas):

| Bebida | crudo | + riqueza | + riqueza + ola |
|---|---|---|---|
| Cerveza | -0,0122 | -0,0416 | **+0,0406** |
| Vino | +0,0170 | -0,0013 | **+0,1380** |
| Destilados | +0,0551 | +0,0029 | **+0,0736** |

El signo salta con la especificacion y **con el proxy de riqueza que se use**. Eso, en si mismo, es
la evidencia de que no hay senal de precio a nivel de `estrato_muestreo`.

**Esto explica el comentario del autor en `Elasticity 17_03.R:353-355`** ("EL GRAN PROBLEMA ES QUE A
MEDIDA QUE AUMENTA EL PRECIO... LA PROBABILIDAD DE SER DRINKER AUMENTA. ESTO NO TIENE SENTIDO") y
**explica los signos raros que reportaron ACC/JRT** en su matriz de participacion (vino positiva,
spirits negativa, cerveza 0). No es un bug del probit; el regresor no es un precio.

### Censura [V]

58,0% (2017) y 64,0% (2022) de los hogares, ponderado, **no registran ninguna compra de alcohol**.
Por bebida: cerveza 28,0% -> 23,6%; vino 23,0% -> 17,8%; destilados 9,0% -> 9,4% de hogares compradores.
La EPF es un diario corto: un cero es "no compro en la ventana", no "no bebe".

---

## 4. Margen extensivo: estado y diseno

**El usuario tenia razon: no se calcula en ninguna parte.** Detalle en 1.3 (B2, B3, B7).

Descomposicion correcta, implementada en el notebook (`elx-extensive-margin`, `elx-total-elasticity`):

```
E[q] = Pr(D=1) * E[q | D=1]
eps_total = eps_extensivo + eps_intensivo
eps_extensivo = E[phi(xb) * beta_p] / E[Phi(xb)]     <- probit CON precio
```

**Orden obligatorio:** arreglar el precio (seccion 6.1) **antes** de creerle al numero. Con el precio
actual sale con signo positivo para cerveza y destilados.

---

## 5. Como lo hace la referencia (SIMAH / Kilian et al. 2025) [V]

Fuentes locales leidas: `__andres_control/_bib/PIIS2468266725001653.pdf` (paper),
`__andres_control/_bib/mmc1.pdf` (suplemento/ODD), y **el codigo fuente**:
`SIMAH/supp/SIMAH_release-0.1.1/microsimpackage/R/apply_tax_policy.R` y `run_microsim_alt.R`.

### 5.1 Secuencia de aplicacion de la politica (4 pasos, no 5)

a) `assign_beverage_preferences()` - asignar consumo por bebida
b) aplicar **elasticidad de participacion** (bloque `if (participation == 1)`)
c) aplicar **elasticidad de consumo por bebida**; el total nuevo se suma **dentro del mismo paso**
d) `update_alcohol_cat()` - recodificar categorias, **fuera** de `apply_tax_policy()`

La nota del proyecto lista 5 pasos; "update continuous consumption" **no es un paso separado**, es la
ultima linea de (c). El bloque completo va **al inicio** del ciclo del ano de politica, antes de
mortalidad, transiciones, envejecimiento y natalidad -> efecto inmediato en el mismo ano.

### 5.2 Los valores que usan

**Elasticidades de consumo (Tabla S6, de Fogarty 2010, meta-analisis):**

| Bebida | Media | SE |
|---|---|---|
| Cerveza | **-0,52** | 0,08 |
| Vino | **-0,55** | 0,08 |
| Destilados | **-0,60** | 0,08 |

**Elasticidad de participacion:** **-0,297** (SE 0,399, *no implementado*), **NO especifica por
bebida**, de Ruhm et al. 2012 (que la estimo con scanner AC Nielsen 2004, 25 estados).

**Cruzadas: NO las implementan, y es deliberado.** Paper e817: *"We refrained from implementing
cross-price elasticities... given mixed evidence of their presence in the USA and elsewhere."*
Suplemento p21 lo lista como supuesto explicito del modelo.

### 5.3 Detalles de implementacion a replicar

- Forma funcional **lineal/arco**, no elasticidad constante: `nuevo = gpd * (1 + e_i * dp)`.
- Elasticidades individuales **acotadas por abajo en -1**; gpd total **topeado en 200 g/dia**.
- **Heterogeneidad por nivel de consumo**: elasticidad individual sorteada con `faux::rnorm_pre()`
  correlacionada con `log(gpd)^2` a `r = 0,60` (U invertida: los muy bajos y muy altos responden
  menos). Sensibilidades con r = 0,40 y 0,80.
- **20 ciclos anuales** (2000-2019), poblacion sintetica de 1.000.000, politica en 2019 (ultimo ciclo),
  **600 corridas** por escenario (60 combinaciones de parametros x 10 semillas), IC = **min/max**.
- Incertidumbre **solo** sobre las elasticidades de consumo, 60 draws latin hypercube.

### 5.4 Hallazgo para el espejo chileno [I]

En el codigo de SIMAH los que dejan de beber por la politica quedan como `"Non-drinker"` y
**`update_former_drinker()` no se llama en la ruta de politica**. En SIMAH da lo mismo porque ese
paper no modela mortalidad. **En Chile si importa**, porque las RR de ex-bebedores son parte del
AAF/PIF. Hay que cerrar ese hueco al portar.

---

## 6. Que hacer, en orden

### 6.1 Prioridad 1 - arreglar el precio (bloquea todo lo demas)

| # | Arreglo | Costo |
|---|---|---|
| A | Deflactar cada ola por IPC de su periodo de terreno + efecto fijo de ola | bajo |
| B | Usar `GASTOT_HD` en vez del subtotal de `cantidades` como gasto del hogar | bajo |
| C | Controlar/purgar la afluencia del cluster antes de usar el efecto fijo como precio | bajo |
| D | Redefinir el mercado como region x zona x trimestre de terreno | medio |
| E | **Anclar en precios externos**: IPC de bebidas alcoholicas del INE, o tasas ILA del SII | alto, correcto |

### 6.2 Prioridad 2 - decidir si hace falta estimar elasticidades

Ver seccion 7. La referencia **no las estima**.

### 6.3 Prioridad 3 - margen extensivo, con validacion externa

Ver seccion 8.

### 6.4 EPF X

La proxima ola es **X EPF 2026-2027** (confirmado por el usuario con la tabla oficial). Series:
I 1956-57, II 1968-69, III 1977-78, IV 1987-88, V 1996-97, VI 2006-07, VII 2011-12, VIII 2016-17,
IX 2021-22, **X 2026-27**. IX EPF: recoleccion mixta CAPI/PAPI, cobertura **nacional urbana**
(capitales regionales y conurbaciones), representativa por macrozona Norte/Centro/Sur/Gran Santiago.
Hasta entonces **no hay tercera ola posible**, y no se necesita: la elasticidad es un parametro que se
transporta; la exposicion 2024 viene de ENPG/SENDA.

---

## 7. Fuentes externas para validar participacion y cuantificar subreporte [V/S]

### 7.1 EL HALLAZGO: INE ya lo hace oficialmente, sobre la EPF, para alcohol [V]

El **Manual Metodologico del IPC base 2023=100** del INE tiene la seccion **4.3.3 "Subdeclaracion del
gasto en alcohol y tabaco"** (p. 24 del manual). Corrige el gasto en alcohol de la IX EPF contra
Cuentas Nacionales del Banco Central:

> "...algunos gastos son considerados sensibles y no se declaran en las encuestas de hogares, porque
> el gasto en estos se encuentra socialmente estigmatizado, por ejemplo, el gasto en consumo de
> alcohol y tabaco (ILO et al., 2020). Con el fin de corregir esta subdeclaracion, se utiliza la
> informacion preliminar de Cuentas Nacionales de Consumo Final de hogares... division de Bebidas
> Alcoholicas y Tabaco, para ser comparada con el gasto de la IX EPF de la misma division."

Procedimiento: CCNN reescalado a la cobertura geografica de la EPF con la participacion del ingreso
monetario de los hogares en comunas EPF (**CASEN 2022 = 75,2%**), dividido por hogares proyectados de
ENE 2022. **Con informacion adicional del BCCh se desagrego a nivel de grupo, obteniendo factores
separados para Bebidas Alcoholicas y para Tabaco.**

**El valor numerico del factor NO se publica** (el manual muestra las formulas como imagenes).
**ACCION CONCRETA DE ALTO VALOR: pedir a INE (unidad IPC) o al BCCh (Cuentas Nacionales) el factor de
ajuste de division 02 a nivel de grupo.** Seria una razon de subdeclaracion **oficial, chilena y
especifica de la EPF**. Es exactamente lo que se necesita.

Otros datos verificados del mismo manual: division 2 pesa **3,68125%** de la canasta base 2023;
IX EPF, terreno 01-oct-2021 a 30-sep-2022.

### 7.2 Encuestas chilenas con consumo individual

| Fuente | Ultima ola | Instrumento | Uso |
|---|---|---|---|
| **ENPG / SENDA** | 2024 | prevalencia ultimo ano por sustancia + AUDIT completo | **el ancla canonica**; el proyecto ya la tiene 2012-2024 |
| **ENS** | 2016-17 [S] | AUDIT, corte >=8 | 11,7% consumo de riesgo 12 meses |
| **ENCAVI** | 2023-24 [S] | por confirmar equivalencia | cifra mas reciente |
| **CASEN** | 2022 | **ninguno** [V] | **VERIFICADO NEGATIVO**: cero items de alcohol |
| INJUV, ELSOC | varias | parcial | secundarias |

### 7.3 Datos administrativos / ventas

- **SII - ILA**: es **ad valorem sobre el precio de venta, no volumetrico**. Cerveza 5° y vino 12°
  pagan el mismo 20,5%. Recaudacion / tasa recupera **valor gravado, no litros**. Ademas la serie
  publica de ingresos tributarios **no trae linea ILA ni desglose por bebida** [V]. El codigo de
  20,5% **agrupa cerveza y vino**, que es justo la distincion que se necesita.
- **ODEPA**: la mejor via para una serie de **volumen** de vino y cerveza.
- **INE IPC**: sub-indice de bebidas alcoholicas; series regionales por confirmar.
- **WHO GISAH**: APC registrado y no registrado para Chile. WHO carga **1,4 L** no registrado.
- **Alcohol no registrado en Chile (IJDP 2025)** [S]: panel Delphi estima **0,05-0,5 L**, es decir
  0,7%-8% del APC total, con alcohol casero como fuente principal (31%). **Contradice el 1,4 L de
  WHO** y cambia materialmente el denominador de cualquier calculo de cobertura. Confirmar contra
  el paper antes de usar.

### 7.4 El metodo estandar: tasa de cobertura

`cobertura = APC estimado por encuesta / APC de impuestos-ventas`.

- **Kilian et al. 2020** (23 paises europeos): cobertura media del APC total **36,5%** (IC 33,2-39,8),
  rango 17,1%-64,3%. Por bebida: **cerveza 43,6%** (la mas alta), **destilados 26,3%** (la mas baja),
  vino intermedio. Tasas de no respuesta, periodo de referencia y marco muestral **no** se asociaron
  significativamente a la cobertura.
- **Buckley et al. 2022** (EE.UU.): BRFSS **45% antes -> 77% despues** del upshifting. Esta es la
  familia de metodos que usa Kilian et al. 2025.
- **No existe una tasa de cobertura publicada para Chile** [V]. **Es calculable con material que el
  proyecto ya tiene**: numerador desde ENPG 2012-2024, denominador desde la serie APC de WHO/Shield.
  Seria un resultado propio y publicable.

**Advertencia conceptual:** la EPF mide **gasto de compra del hogar**, no consumo de personas. El
factor de INE es sobre **gasto**, no sobre volumen ni etanol. No son intercambiables.

### 7.5 Elasticidades ya publicadas para Chile [V/S]

**Paraje & Araya 2018 (PLoS One) y Paraje, Araya & Monteiro 2024 (IJDP)** - usan encuestas de gasto
de hogares:

| Estimacion | Valor |
|---|---|
| Alcohol puro off-premise, Chile | **-0,656** |
| Cerveza | **-0,93** |
| Vino | **-0,77** |
| Destilados | **-0,14** (marginalmente significativa) |

**Anomalia a interrogar [I]:** internacionalmente los destilados son los **mas** elasticos (-0,80);
en Chile se estiman como los **menos** (-0,14). Puede reflejar la maquinaria de valores
unitarios/sustitucion de calidad, la concentracion del pisco, o estructura de mercado distinta. Pero
implica que un impuesto a destilados seria casi inocuo en consumo, asi que hay que resolverlo antes
de que maneje un escenario de politica.

**Meta-analisis internacionales (Wagenaar et al. 2009, 1003 estimaciones / 112 estudios):**
cerveza **-0,46**, vino **-0,69**, destilados **-0,80**, total **-0,51**; **bebedores intensos -0,28**.
Otros: Gallet 2007 -0,36/-0,70/-0,68; Fogarty 2006 -0,38/-0,77/-0,70.

**Sobre el "0,2 de EE.UU.":** -0,2 esta **por debajo de toda elasticidad propia meta-analitica** para
toda bebida. Esta cerca de (a) la elasticidad de **bebedores intensos** de Wagenaar (-0,28) y (b) la
**elasticidad de participacion** de SIMAH (-0,297). **Muy probablemente la cifra que circulo en la
reunion es una elasticidad de participacion o de bebedores intensos, no una elasticidad de consumo.**
Vale la pena fijar cual antes de usarla.

---

## 8. Preguntas abiertas / decisiones pendientes

1. **Alcohol fuera del hogar**: incluirlo (solo IX lo tiene) o declarar el estimando como off-premise.
2. **Deflactor**: IPC general o IPC de bebidas alcoholicas; y periodo de terreno exacto por ola.
3. **`gasto_tot`**: cambiar al `GASTOT_HD` oficial (recomendado) rompe comparabilidad con lo ya corrido.
4. **Estimar vs transportar**: ver seccion 7.5 y 5.2. Si se transporta, cual fuente y con que IC.
5. **Cruzadas**: la referencia las omite deliberadamente; ACC las quiere. Decidir y documentar.
6. **renv**: este proyecto no lo usa. Decidir si se inicializa (cambia el flujo de trabajo) o si
   bastan los snapshots CSV/lock de `Elasticidad/env/`.
7. **Factor de subdeclaracion INE/BCCh**: pedirlo formalmente.

---

---

# ADENDA 2026-08-10 15:45 — correcciones tras la revision de Codex, y factibilidad de Deaton completo

## A1. Correcciones a lo que yo habia escrito. Codex tenia razon.

| # | Lo que yo dije | Lo correcto | Estado |
|---|---|---|---|
| A | "ambas olas se reconstruyen **exactas**" | El control comparaba 9 variables, omitia `quintil`, y usaba `na.rm = TRUE`, que puntua `-88` vs `NA` como **acuerdo**. Habia **9 hogares** discrepantes (24 celdas `sex_hhh` en 2022 = 8 hogares; 3 celdas `age_hhh` en 2017 = 1 hogar) | **corregido**: control NA-aware sobre todas las columnas compartidas, limpieza de centinelas por ola, `quintil` implementado. Ahora **0 celdas discrepantes** de verdad |
| B | "el precio de Deaton es en gran medida un indice de afluencia" | Demostrado solo bajo **una** de las dos definiciones de mercado que usan los propios scripts | **corregido**: ver A2 |
| C | "el total es una **cota inferior**" | El termino omitido tiene **signo desconocido**; no es cota de nada | **corregido**: se llama descomposicion parcial/diagnostica |
| D | "precio Deaton" | Es un **proxy de precio basado en valores unitarios** (efecto fijo de cluster). No es Deaton completo | **renombrado** |
| E | `m` en la etapa 1 del probit | `m = log(pmax(gasto_alcohol, 1e-6)) - lnP`; para el 63% de hogares colapsa a la constante `log(1e-6)`. Es funcion deterministica del resultado: **endogeneidad por construccion**. Esta en los scripts heredados tambien | **corregido**: `m` fuera de la etapa 1 |
| F | aserciones y paquetes | Solo declaraba `sandwich` aunque usa `haven` y `dplyr`; `elx-inventory` **fallaba si aparecia** `DATA_EPS_2217_LONG.rds`; los CSV se sobrescribian el mismo dia | **corregidos los tres** |

## A2. Las DOS definiciones de mercado, y por que importa

Los scripts del proyecto **no coinciden** en que es un mercado:

| Script | Definicion | Celdas |
|---|---|---|
| `Elasticity 17_03.R:37` | `interaction(estrato_muestreo, year)` | **135** |
| `quaids_two_step_deaton.R:43` | `paste0(var_unit, "_", year)` | **3.703** |
| `SENSITIVITY.R:140` | agrupa por `var_unit, year` | 3.703 |

Confundido con afluencia, medido bajo ambas:

| Mercado | Cerveza | Vino | Destilados | Compradores retenidos |
|---|---|---|---|---|
| `estrato_muestreo x year` | R2 **0,523** | **0,685** | **0,592** | 100 / 100 / 93% |
| `var_unit x year` | R2 **0,160** | **0,193** | **0,015** | 55 / 56 / 37% |

**Enunciado defendible:** la definicion gruesa esta gravemente confundida con afluencia y ola; la fina
cambia ese confundido por celdas demasiado delgadas. Ninguna entrega un precio creible para las tres
bebidas. **No existe "el" resultado de JRT** mientras no se diga script y definicion de cluster.

## A3. Hallazgo nuevo: el margen de participacion NO es estimable como esta especificado

Al sacar `m` de la etapa 1 (la correccion correcta), el probit **deja de converger**:

```
Beer     converged: TRUE  | coef precio propio  0,1093      (signo equivocado)
Wines    converged: FALSE | coef precio propio -3,004e+14
Spirits  converged: FALSE | coef precio propio -1,301e+14
```

Coeficientes de 1e14 son separacion. No es que la participacion este mal estimada: **no es estimable**.
El notebook ahora reporta la convergencia y anula las elasticidades no convergidas.

## A4. FACTIBILIDAD DE DEATON COMPLETO — respuesta con numeros [V]

Deaton (1988/1997) requiere: (i) ecuacion de shares sobre el gasto **total**, (ii) regresiones
intra-cluster de share y de ln(valor unitario), (iii) separacion calidad/cantidad, (iv) correccion de
errores en variables sobre las medias de cluster.

**Requisito 1 — gasto total del hogar. DISPONIBLE.** `GASTOT_HD_PC x npersonas`. Pero el share de
alcohol sobre el gasto **total** es de **0,84%–0,89%** (todos los hogares) y **2,2%–2,5%** entre
compradores; por bebida, 1,4%–1,8% entre compradores. Deaton trabaja con shares de alimentos de
10%–30%. Con w tan chico, la elasticidad (que divide por w) amplifica el ruido fuertemente.

**Requisito 2 — grados de libertad intra-cluster. DISPONIBLE en la definicion gruesa.**
`estrato_muestreo x year`: **221,9 hogares por cluster**. `var_unit x year`: **8,1**. La primera sirve,
la segunda no.

**Requisito 3 — CONFIABILIDAD de la media de cluster del valor unitario. ESTE ES EL NUMERO CLAVE.**
lambda = sigma2_entre / (sigma2_entre + sigma2_dentro / n_c): la fraccion de la varianza observada
entre clusters que es senal y no ruido muestral. Es exactamente lo que la correccion de errores en
variables tiene que deshacer.

| Mercado | Cerveza | Vino | Destilados |
|---|---|---|---|
| `estrato_muestreo x year` (min 10 compradores) | **0,946** | **0,921** | **0,801** |
| `var_unit x year` (min 5 compradores) | 0,653 | 0,710 | **0,056** |

**A nivel de estrato la confiabilidad es de 0,80 a 0,95.** Es decir, la correccion de errores en
variables seria **modesta** (corrige entre 5% y 20%), que es precisamente el regimen para el que el
metodo fue disenado. **La parte EIV de Deaton es perfectamente factible.**

**Requisito 4 — sistema de precios cruzados. NO FACTIBLE sin extension.** Solo **752 hogares (2,51%)**
compran las tres bebidas; 3.159 compran exactamente dos; **58%–64% no compra ninguna**. Las ecuaciones
de share estan **censuradas en cero** para la mayoria, y el metodo de Deaton supone soluciones
interiores. Una version censurada (Shonkwiler-Yen) ya no es Deaton.

### Veredicto

**SI es factible, con la informacion actual, un Deaton bastante mas completo que el implementado:**
ecuacion de shares sobre gasto total, primera etapa intra-cluster, separacion calidad/cantidad y
correccion EIV, **a nivel `estrato_muestreo x year`, para elasticidades PROPIAS**. Y vale la pena,
porque la separacion calidad/cantidad es **justamente el remedio** al confundido por premiumizacion
que documenta la seccion 3: lo que hicieron los scripts heredados fue un Deaton **truncado**, que se
salto el remedio. Este es el punto central de la adenda.

**NO es factible, con la informacion actual:**
1. El **sistema completo con cruzadas**, por censura (2,51% compra las tres).
2. Cualquier cosa a nivel `var_unit` para destilados (lambda = 0,056).
3. Superar el supuesto de fondo: `estrato_muestreo` **no es un mercado**. Deaton corrige el sesgo de
   calidad; **no** corrige que el cluster no separe mercados. Por eso el ancla externa de precios
   (IPC de bebidas alcoholicas del INE por region, tasas ILA) sigue siendo la mejora de primer orden.

**Orden recomendado:** (1) cambiar `gasto_tot` por `GASTOT_HD` y deflactar por ola; (2) implementar
Deaton completo de elasticidades **propias** a nivel estrato; (3) cruzadas solo con un modelo
censurado, o importarlas / fijarlas en cero como hace SIMAH; (4) ancla externa de precios.

## A5. Cambio atomico del notebook (autorizado, ejecutado 2026-08-10 15:45)

- **Movido** a `__andres_control/elasticidad_consolidado.ipynb`. Corre desde ahi: resuelve
  `../Elasticidad/Data` y escribe en `__andres_control/elasticidad_outputs/`.
- **Whitelist** agregada al `.gitignore` (notebook, handoff, outputs, `Elasticidad/env/`,
  `Elasticidad/Scripts/*.R`). Verificado que el microdato crudo (~1,2 GB) y los `.rds` **siguen
  ignorados**.
- **Dependencias** declaradas y verificadas: `sandwich`, `haven`, `dplyr`.
- **Salidas no destructivas**: sello `YYYYMMDD_HHMM`.
- **Corre desde crudos**: la seccion 3 ahora agrupa desde `elx_new17` / `elx_new22` reconstruidos, no
  desde los `.rds`. El notebook ya no depende de dos archivos que acaba de probar que puede regenerar.
- Control: **0 celdas discrepantes** en 16 (2022) y 17 (2017) columnas comparadas, NA-aware;
  `quintil` concuerda 100% / 99,99%. Aserciones **20/20**.

**Pendiente de decision tuya:** `Elasticidad/outputs/` quedo con 4 CSV de corridas previas al arreglo
de `m`, o sea con **numeros superados**. No los borre. Conviene eliminarlos para que nadie los levante.

---

## 9. Archivos a revisar (rutas exactas)

- `Elasticidad/elasticidad_consolidado.ipynb` - notebook consolidado, ejecutable, con aserciones
- `Elasticidad/Data/original_ine/` - microdato crudo INE, ambas olas
- `Elasticidad/env/` - snapshots BEFORE/AFTER y lockfiles
- `Elasticidad/Scripts/*.R` - los cinco scripts heredados (no modificados)
- `SIMAH/supp/SIMAH_release-0.1.1/microsimpackage/R/apply_tax_policy.R` - el motor de politica
- `SIMAH/supp/SIMAH_release-0.1.1/microsimpackage/R/run_microsim_alt.R` - el ciclo anual
- `__andres_control/_bib/PIIS2468266725001653.pdf` + `mmc1.pdf` - paper y suplemento Kilian
- `presentacion_micsim.qmd` - roadmap; **declara Elasticidad como "Completo", lo que hay que revisar**
- `__andres_control/plan_fase_siguiente_micsim_2026-07-04.md` - menciona `R/elasticity/policy_to_shift.R`
  como el puente pendiente hacia PIF (**archivo aun no escrito**)
