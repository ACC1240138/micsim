# Pseudo-panel de Deaton sobre ENPG/SENDA — Handoff de Fase 1

**Fecha:** 2026-08-04
**Notebook asociado:** `__andres_control/pseudopanel_deaton_fase1.ipynb` (41 celdas, 22 chunks, **15 aserciones** más una compuerta que falla si alguna no corrió)
**Última revisión:** incorpora la crítica de Codex (**§14**), el trabajo previo de `__enpg` (**§14.2**), los informes oficiales 2018 y 2020 (**§15**) y los informes 2012, 2014, 2016 y 2022 (**§16**).

**Documentos hermanos, en el mismo directorio:**
- `pseudopanel_divergencias_expand_pif.md` — qué diverge de `expand_pif*`, por qué, y cómo reconciliarlo.
- `pseudopanel_decisiones_metodologicas.md` — reglas de codificación, umbrales y criterios chicos que cambian números.

**Lo más importante que salió de los informes:** la serie 2012–2024 **no es homogénea**. El marco muestral cambió en 2022. Ver §16 antes de modelar.
**Salidas:** `__andres_control/pseudopanel_fase1/*.csv` y `pseudopanel_fase1/figures/`

---

## 0. Cómo usar este documento

Está escrito para retomar el trabajo en **otro equipo**, donde están las ENPG completas y las **guías metodológicas de SENDA**. Lo marcado **[V]** se verificó ejecutando R contra los archivos crudos; no hay que rehacerlo. Lo marcado **[NV]** requiere trabajo.

**Niveles de verificación, para que sepas en qué apoyarte.** Recalculé personalmente: el registro de variables completo (§3), todo el audit de celdas (§4), el diseño complejo (§5), la batería de abuso ítem por ítem (§6), §7.1 y §7.3, la monotonicidad de prevalencia de vida (A3), el modo de aplicación (A2), el conteo de comunas y el re-etiquetado de Ñuble (A14). Las demás amenazas marcadas [V] provienen de un panel de cinco revisores adversarios independientes más un crítico, cada uno ejecutando R sobre estos mismos archivos y citando sus scripts y cifras; **las revisé pero no las reejecuté una por una.** Están marcadas así en el texto cuando corresponde.

**Regla de oro:** antes de recalcular algo que el notebook ya produce, reproduce primero el valor existente como control. Si el control no cuadra, no confíes en lo que venga después.

**Advertencia de encuadre.** La Fase 1 no era sólo un audit de tamaños de celda. Terminó produciendo **evidencia preliminar que contradice partes de la hipótesis** y varias amenazas verificadas que la fabricarían siendo falsa. Ver §7 y §8 antes que nada.

---

## 1. Decisiones tomadas (cerradas)

| # | Decisión | Motivo |
|---|---|---|
| D1 | **Olas 2012–2024** (7 bienales). Se excluyen 2008 y 2010. | 2008 usa otro instrumento, `0` como código de salto, sin PSU válida, y administra la batería de abuso a bebedores **de por vida**. 2010 no tiene ítem de completitud educacional. Además acortar la ventana **gana** dos cohortes completamente observadas. |
| D2 | Rango etario **15–65**. | Banda del trabajo de PIF. Ver amenaza A11: la edad está top-coded en 65 y eso importa. |
| D3 | Celdas = **cohorte de 10 años × sexo × ola**. | Única partición donde casi toda celda supera tamaño efectivo ~100 tras el efecto de diseño. |
| D4 | **Escolaridad como covariable de celda, no estrato.** | Estratificar baja la mediana del tamaño efectivo a 144 y deja el 100% de las celdas con <30 usuarios de cocaínas. |
| D5 | **Cocaína y pasta base agrupadas** ("cocaínas") a nivel de celda. | Por separado, pasta base no tiene media utilizable en un quinto de las celdas. |
| D6 | Índice de abuso de alcohol sobre los **ítems comunes**, no los 4 ni los 5 sin más. | Ver §6: el crítico demostró que el problema real es el **cambio de redacción**, no el quinto ítem. |
| D7 | Panel **desbalanceado** principal; balanceado (1959–1997) como sensibilidad. | Restringir descarta 21.9% y justo los tramos donde la hipótesis predice la transición. |

---

## 2. TAREAS para el equipo con las guías metodológicas

**La mayor parte de esta lista quedó cerrada con los informes 2018 y 2020 y los cuestionarios 2022 y 2024 que agregaste a `__enpg`. Ver §15.** Lo que queda:

1. ~~UPM y estrato oficiales.~~ **CERRADO (§15.1):** PSU = manzana; estrato = **comuna × grupo de tamaño de manzana**, no región. Acción pendiente: correr 2018 con el estrato oficial `comuna × grupogrande` como sensibilidad.
2. ~~Modo de aplicación y ola 2020.~~ **CERRADO (§15.2, §15.3):** 2020 fue 89% presencial / 11% telefónico, con la secuencia autoaplicada y las tarjetas **eliminadas por diseño**.
3. ~~Tasas de respuesta.~~ **CERRADO (§15.2):** TRR1 62,4% (2018) → 41,8% (2020). No hay conteo de viviendas sustituidas en ninguna ola.
4. ~~Urbano / rural.~~ **CERRADO (§15.1):** el marco es **urbano únicamente**, 109 comunas de 30.000+ habitantes, ~70% de la población nacional.
5. **Base de las proyecciones de calibración**: sigue sin declararse en ningún informe. Es lo único importante que falta pedirle a SENDA junto con el punto siguiente.
6. **Identificador de encuestador/equipo**: no existe en ningún archivo [V]. Sin él, todo efecto de diseño reportado es un **piso**.
7. **Informes de 2012, 2014, 2016, 2022 y 2024**: no están. Los de 2018 y 2020 son casi clones, así que suponer continuidad del diseño es razonable pero es suposición.
8. **Ejecutar los tres chequeos obligatorios de §9** antes de cualquier modelo.

---

## 3. Registro de variables VERIFICADO [V]

Confirmado leyendo etiquetas de variable y de valores de los archivos crudos. Esto es lo más caro de reconstruir; no lo rehagas.

| Ola | Archivo | Peso | PSU | Región | Comuna | Sexo | Edad |
|---|---|---|---|---|---|---|---|
| 2012 | `Base de datos ENPG 2012 (PG).DTA.dta` | `PONDERADOR` | `manzana` | `región` | `código_comuna` | `sexo` | `edad` |
| 2014 | `Base de datos ENPG 2014 (PG).DTA.dta` | `F2_MAY_AJUS_com` | `Segmento_n` | `Region` | `Comuna` | `sexo` | `edad` |
| 2016 | `base ENPG 2016 publico general.dta` | **externo** `enpg16_factoresdeexpansion.dta` → `Fexp` | `distrito`+`zona`+`manzana` | `región` | `comuna` | `sexo` | `edad` |
| 2018 | `Base de datos ENPG 2018 (PG).DTA` | `Fexp` | `idmanzana` | `Region` | `comuna` | `S01` | `S02` |
| 2020 | `enpg2020.RDS` | `FACT_PERS_COMUNA` | **ninguna** | `REGION` | `Nom_comuna` | `S01` | `S02` |
| 2022 | `enpg2022.RDS` | `FACTOR_EXPANSION` | `UPM` | `REGION` | `COD_COMUNA` | `SEXO` | `EDAD` |
| 2024 | `Base Publica ENPG 2024 (Stata 16).dta` | `FACTOR_EXPANSION` | `UPM` (+`ESTRATO`) | `REGION` | `COD_COMUNA` | `SEXO` | `EDAD` |

**PSU:** los identificadores de manzana y segmento **sólo son únicos dentro de comuna**. La llave de conglomerado debe construirse junto con la comuna; si no, se fusionan manzanas de comunas distintas y el factor de conglomeración sale sesgado hacia abajo.

**Corrección aplicada en 2016 (viene de `__enpg`).** 2016 publica además `distrito` y `zona`. Con `comuna+manzana` salen **2,000** conglomerados; con `comuna+distrito+zona+manzana` salen **2,356**. Mi versión anterior **colapsaba 358 manzanas distintas**. Ya corregido, y el conteo nuevo coincide exactamente con el de tu auditoría previa (2,356).

**2018 — RESUELTO, y resulta ser una no-decisión.** Instrucción: seguir lo que usa `expand_pif*.ipynb`. Rastreado hasta su fuente: los notebooks consumen `revision_diseno_enpg_extension.R`, que lee el caché de `build_enpg_design_waves_2012_2024_list.R`, donde 2018 tiene `psu_candidates = c("idmanzana")` (`Seccion` aparece sólo como candidata **no** elegida). La llave se arma como `paste(year, commune, psu, sep = "|")`, es decir cruzada con comuna, igual que en mi notebook. **Adoptado: `idmanzana`.**

Y da lo mismo: en 2018, `idmanzana` sola, `comuna+idmanzana` y `Seccion` sola dan **exactamente 3,185 conglomerados** las tres. `grupogrande` es constante dentro de `idmanzana`, así que `Seccion` es la misma partición. No había nada que decidir.

**2016 — divergencia deliberada respecto de la convención del proyecto, señalada para tu decisión.** `manzana` sola tiene **sólo 217 valores distintos** en todo el país: es un correlativo interno, no un identificador. La convención del proyecto (`comuna+manzana`) da 2,000; agregar `distrito` y `zona` da **2,358**, que es lo que obtuvo tu auditoría de `__enpg` de forma independiente. Mi notebook usa la versión de 2,358 porque la otra fusiona 358 manzanas distintas y sesga el factor de conglomeración hacia abajo. **Mi notebook no alimenta a `expand_pif`, así que esto no rompe nada aguas abajo**, pero si quieres consistencia estricta con el resto del proyecto hay que cambiarlo allá o aquí, no dejar las dos.

**Nota 2020:** existe `seccion` pero **sólo toma 10 valores distintos**, así que el fallback `REGION × comuna × seccion` da 408 pseudo-conglomerados contra 3,175 en 2018 y 2,653 en 2022. No es un diseño real: 2020 se queda sin PSU.

| Ola | Escolaridad nivel | Nivel jefe | ¿Completó? | ¿Completó jefe? | Parentesco |
|---|---|---|---|---|---|
| 2012 | `p184_1` | `p184_2` | `p185_1` | `p185_2` | `p182` |
| 2014 | `dp9_1` | `dp9_2` | `dp10_1` | `dp10_2` | `dp7` |
| 2016 | `dp_9_a` | `dp_9_b` | `dp_10_a` | `dp_10_b` | `dp_7` |
| 2018 | `T_DP_12_1` | `T_DP_12_2` | `T_DP_13_1` | `T_DP_13_2` | `DP_10` |
| 2020/2022/2024 | `DP_12` | — | `DP_13` | — | `DP_10` |

**[V] En 2012–2018 el ítem "del entrevistado" sólo se pregunta a quien NO es jefe de hogar.** Correspondencia exacta: 2014 falta para los 9,062 que declaran ser jefe; 2012 faltan 7,624 = los `p182==1`; 2016, 8,982 = los `dp_7==1`; en 2018 la etiqueta de `T_DP_11_1` dice literalmente "Entrevistado no jefe de hogar". Se recupera **sustituyendo por el ítem del jefe cuando la persona ES el jefe**.

**[V] Hay que leer el ítem de completitud junto con el de nivel.** La escala de 13 niveles nombra el nivel *alcanzado*. Con esto, el grupo de menor educación baja suave: **38.1, 35.1, 31.8, 31.2, 28.2, 26.4, 26.2** de 2012 a 2024 (salto máximo 3.3 pp).

| Ola | Alcohol últ. vez | Alcohol vida | Marihuana últ./vida | Cocaína últ./vida | Pasta base últ./vida | HED | Escala HED |
|---|---|---|---|---|---|---|---|
| 2012 | `p13` | `p10` | `p38`/`p35` | `p83`/`p80` | `p61`/`p58` | `p21` | base 0 |
| 2014 | `oh4` | `oh1` | `mar4`/`mar1` | `coc4`/`coc1` | `pb4`/`pb1` | `oh12` | base 0 |
| 2016 | `oh_4` | `oh_1` | `mar_4`/`mar_1` | `coc_4`/`coc_1` | `pb_4`/`pb_1` | `oh_16` | base 0 |
| 2018 | `OH_4` | `OH_1` | `MAR_4`/`MAR_1` | `COC_4`/`COC_1` | `PB_4`/`PB_1` | `OH_14` | **base 1** |
| 2020–2024 | `OH_4` | `OH_1` | `MAR_4`/`MAR_1` | `COC_4`/`COC_1` | `PB_4`/`PB_1` | `OH_10` | base 0 |

Recencia idéntica en todas: `1` últimos 30 días, `2` más de un mes y menos de un año, `3` más de un año, `88`/`99` no respuesta, `NA` salto de diseño = **cero sustantivo**. Último año = `1` o `2`.

**Trampa:** el ítem de *primera* vez tiene la misma escala y está a dos posiciones del de *última* vez. Por eso el notebook tiene un control de rango sobre la prevalencia de alcohol.

**[V] Advertencia general: Stata trunca las etiquetas a 80 caracteres.** En 2018 los ítems empiezan con "Piense en los últimos 12 meses" (30 caracteres), así que la búsqueda por etiqueta devuelve vacío. 2020 no trae etiquetas. **No uses regex sobre etiquetas para localizar ítems en ENPG.**

---

## 4. Resultados del audit de celdas [V] (2012–2024)

**124,104 personas de 15 a 65 años**; 16,114 a 19,326 por ola; 52,703 hombres y 71,401 mujeres.

**Efecto de diseño.** Kish efectivo = **21.6% a 47.4%** del nominal (inflación 2.11 a 4.64 sólo por pesos). Conglomeración residual ×**1.21 a 1.64** (mediana 1.46) en las seis olas con PSU. Efecto de diseño total sobre la media de celda: **1.96 (2022) a 4.28 (2014)**.

> La regla de 100–200 por celda hay que aplicarla al **tamaño efectivo**, no al conteo bruto.

| Diseño | Celdas | n mín | n mediana | n_eff mediana | % n_eff ≥100 | % n_eff ≥200 |
|---|---|---|---|---|---|---|
| 5 años × sexo × ola | 154 | 82 | 802 | 230 | 95.5 | 66.2 |
| **10 años × sexo × ola** | **84** | **235** | **1,538** | **442** | **94.1** | **88.1** |
| 10 años, balanceado | 70 | 117 | 1,531 | 411 | 82.9 | 80.0 |
| 10 años × escolaridad(3) | 252 | 1 | 477 | 144 | 68.3 | 26.2 |

**Estados raros.** Celda mediana (10 años): 84 usuarios de marihuana, **8 de cocaínas**, **3 de pasta base**. 21% de celdas sin ningún usuario de pasta base; 86% con menos de 30 de cocaínas. Con escolaridad, **el 100%** de las celdas tiene <30 de cocaínas.

**Cohortes.** Trece quinquenales; **nueve** (1959–1997, 78.1%) dentro de la ventana en las siete olas.

**Espacio de estados — reestructurado tras la revisión de Codex, ver §14.** Ahora son **tres ejes separados**, no una sola variable nominal.

*Eje 1, perfil actual* (`profile_amc`), partición de las tres clases medidas: `2_alcohol_only_of_AMC` 48.0%, `1_no_AMC_use_last_year` 43.3%, `4_alcohol_and_drug` 7.8%, `3_drug_without_alcohol` 0.9%.

**El nivel más bajo NO es abstinencia** y su nombre lo dice. Está medido en el notebook: personas dentro de ese nivel que sí reportan otra droga en el último año, por ola: 53, 37, 60, 55, 67, 76 y **177** (1.84% del nivel en 2024). Y eso es un **piso**, porque la única clase no-A/M/C con escala de recencia comparable en las siete olas es la grilla de nueve tranquilizantes sin receta.

*Eje 2, perfil problemático*: pendiente para la Fase 3 (ver §14).

*Eje 3, historia* (`cocaines_status`, `lifetime_breadth_drugs`, `former_drug_use_no_current`): nunca en la vida / alguna vez pero no el último año / consumo el último año. "Nunca consumió" vive aquí y **no puede derivarse** de la ausencia de consumo del último año.

**Caída del alcohol.** Prevalencia de último año 59.4% (2012) → 45.5% (2024).

---

## 5. Diseño complejo

Hecho: `survey::svydesign(ids=~psu, strata=~region, weights=~weight, nest=TRUE)` por ola con `survey.lonely.psu="adjust"`; medias de celda vía `survey::svyby` con **error estándar de diseño** (insumo de Deaton), más Kish y binomial ingenuo para comparar. El CSV `ppd_design_based_cell_means_*.csv` ya trae `se_oh`, `se_mar`, `se_cocaines` (de diseño) junto a `se_oh_binomial`, `se_oh_kish` y `deff_total`.

Pendiente: estrato oficial (ver §16.3, cambió tres veces en la serie); escala del peso de 2016; **2020 sin PSU** (sus SE son optimistas); **2022 con pesos mucho menos dispersos** (Kish 0.47 vs 0.22–0.28), lo que **ya está explicado** por el cambio de marco muestral en esa ola — ver §16.1.

---

## 6. Batería DSM-IV de abuso de alcohol [V]

| Ola | Rol/deberes | Peligro | Legal | Familia | Peleas | N | Redacción |
|---|---|---|---|---|---|---|---|
| 2012 | `p31` | `p32` | `p33` | `p34` | — | 4 | B |
| 2014 | `oh22` | `oh23` | `oh24` | `oh25` | — | 4 | B |
| 2016 | `oh_26` | `oh_27` | `oh_28` | `oh_29` | — | 4 | B |
| 2018 | `OH_24` | `OH_25` | `OH_26` | `OH_27` | — | 4 | B |
| 2020 | `OH_20` | `OH_21` | `OH_22` | `OH_23` | — | 4 | B |
| 2022 | `OH_20` | `OH_21` | `OH_22` | `OH_23` | `OH_24` | **5** | **A** |
| 2024 | `OH_20` | `OH_21` | `OH_22` | `OH_23` | `OH_24` | **5** | **A** |

Redacción **A**: "¿Ha tenido algún problema serio en la casa, en el trabajo o donde estudia?" / "a causa del alcohol se haya expuesto a algún peligro".
Redacción **B**: "¿Ha dejado de cumplir sus deberes...?" / "¿Ha puesto en peligro su integridad física a causa del consumo recurrente...?".

**CORRECCIÓN IMPORTANTE.** Mi primera lectura culpaba al quinto ítem. El crítico lo desmintió con datos: el quinto ítem **aplana** el gradiente etario (aporte 2022 por tramo: +1.40 pp a los 15–24 pero sólo +0.48 a los 55–65; el tramo joven recibe ~3× el del viejo). **El peligro real es el cambio de redacción**: manteniendo 4 ítems fijos, el paso 2020→2022 sube el "al menos un síntoma" en **−0.28 pp (15–24), +2.11 (25–34), +1.86 (35–44), +1.48 (45–54), +1.14 (55–65)**. Esa es exactamente la forma de la hipótesis, apareciendo en un cambio de instrumento.

**Bueno [V]:** las siete olas administran el bloque a bebedores de último año (98.9%–99.8% de ellos), así que el denominador es consistente. No era cierto en 2008.

**Asimetría de instrumento [V] — importante y no obvia.** El alcohol tiene **sólo** el bloque de abuso DSM-IV. Cocaína, pasta base y marihuana tienen abuso **más** un bloque completo de dependencia CIE-10 (craving, tolerancia, pérdida de control, abstinencia). El grep de etiquetas por "deseo tan grande", "mismo efecto", "intentado controlar", "mayores cantidades" devuelve **cero** aciertos en variables `OH_` y sólo aciertos en `MAR_`/`PB_`/`COC_`. Las dos ramas de la comparación se miden con instrumentos de sensibilidad muy distinta: infla la rama de drogas en edades jóvenes y pone techo a la rama de alcohol, exagerando justo el contraste que la hipótesis predice.

---

## 7. Evidencia preliminar que YA contradice partes de la hipótesis [V]

Esto no estaba en el plan de la Fase 1, pero salió al verificar amenazas y es lo más importante del documento.

**7.1. El consumo problemático de alcohol NO sube con la edad. Baja.** Agrupado 2012–2024, ponderado, 15–65, usando **sólo los cuatro ítems de abuso comunes a todas las olas** (así el resultado no depende del quiebre de §6). Recalculado de forma independiente por mí; script `verify_s7.R`.

| Tramo | p(bebedor) | p(problemático \| bebedor) | p(problemático, incondicional) | n |
|---|---|---|---|---|
| 15–19 | .4548 | .0835 | .0380 | 9,082 |
| 20–24 | .6644 | **.1006** | **.0668** | 11,084 |
| 25–29 | .6925 | .0977 | .0677 | 12,389 |
| 30–34 | .6653 | .0756 | .0503 | 12,647 |
| 35–39 | .6473 | .0756 | .0489 | 11,880 |
| 40–44 | .6495 | .0478 | .0310 | 11,976 |
| 45–49 | .6268 | .0570 | .0357 | 11,671 |
| 50–54 | .5694 | .0495 | .0282 | 12,498 |
| 55–59 | .5576 | .0572 | .0319 | 12,119 |
| 60–65 | .4750 | **.0339** | **.0161** | 18,758 |

**El máximo está a los 20–29 y baja de forma esencialmente monótona después. No hay ningún tramo en que la serie condicional o la incondicional suba.** A los 60–65 el consumo problemático condicional es un tercio del máximo y el incondicional una cuarta parte. La rama 2 de la hipótesis ("el alcohol problemático emerge en edades mayores") **no aparece en los datos de población general**.

**7.2. Pero la hipótesis es confirmable por construcción si se enuncia como proporción.** Entre personas con *cualquier* involucramiento con sustancias en el último año, la proporción que es "alcohol problemático sin drogas" sube monótonamente: **20–24 = 8.87%, 30–34 = 11.88%, 40–44 = 17.92%, 50–54 = 34.38%, 55–59 = 40.18%**. Eso es aritmética: el denominador de usuarios de drogas se va a cero con la edad. Cualquier figura o índice basado en proporciones o razones "confirmará" la hipótesis aunque la serie de alcohol esté cayendo en niveles.

**7.3. La mayoría de los bebedores problemáticos mayores nunca usó cocaína.** Ahora sobre **las siete olas agrupadas** (antes eran sólo 2022+2024), entre personas con ≥1 síntoma de abuso sobre los cuatro ítems comunes, la proporción que **alguna vez** usó cocaína o pasta base:

| Tramo | % alguna vez cocaínas | n |
|---|---|---|
| 15–24 | 26.6 | 1,009 |
| 25–34 | 38.4 | 1,271 |
| 35–44 | **41.2** | 853 |
| 45–54 | 28.7 | 722 |
| 55–65 | **23.3** | 594 |

> ### ⚠ CORRECCIÓN 2026-08-06: la interpretación de arriba era ERRÓNEA por falta de comparador
>
> Escribí que "más de tres cuartos de los bebedores problemáticos de 55–65 nunca tocaron cocaínas, así que el mecanismo no puede cargar mucho". **Ese razonamiento no se sostiene sin saber cuánto vale esa proporción en quienes NO tienen AP.** Codex lo señaló y tenía razón. Calculado el contrafactual, la conclusión **se invierte**.
>
> Prevalencia de haber usado cocaínas alguna vez, entre AP vs no-AP, ponderado, 15–65, siete olas. RP = razón de prevalencias:
>
> | Tramo | Hombres AP | Hombres no-AP | RP | Mujeres AP | Mujeres no-AP | RP |
> |---|---|---|---|---|---|---|
> | 15–24 | 29,9% | 4,4% | **6,86** | 18,5% | 1,4% | **12,89** |
> | 25–34 | 42,1% | 10,9% | **3,85** | 25,2% | 3,8% | **6,55** |
> | 35–44 | 41,9% | 12,3% | **3,41** | 38,3% | 3,7% | **10,34** |
> | 45–54 | 31,8% | 10,5% | **3,03** | 28,2% | 2,5% | **11,30** |
> | 55–65 | 24,2% | 6,1% | **3,99** | 17,5% | 0,9% | **20,26** |
>
> **Los diez estratos muestran enriquecimiento, con razones de 3 a 20 y diferencias de +17 a +35 puntos.** Que "sólo" el 24% de los bebedores problemáticos mayores haya usado cocaínas es mucho cuando en la población general de esa edad la cifra es 6,1% en hombres y 0,9% en mujeres.
>
> **Y hay orden temporal individual.** Entre casos AP con historia de cocaínas, la edad mediana de inicio en cocaínas es **20** y la edad actual mediana es **34**; el **80,2% inició cocaínas al menos cinco años antes** de la entrevista. No prueba causalidad ni transición, pero establece la secuencia en el nivel donde sí hay potencia.
>
> El máximo en 35–44 sigue siendo firma plausible de cohorte epidémica y no de edad; eso no cambia.

**7.4. El declive de la cocaína con la edad es margen extensivo, y los que siguen intensifican.** Entre usuarios de cocaínas del último año, días de uso en los últimos 30: 15–24 media 6.18 / mediana 2 / 21.7% con ≥10 días; 25–34 media 7.22 / mediana 3.5 / 30.6%; **35–44 media 12.47 / mediana 5**. Lo que se observa es salida de la mayoría e intensificación del resto, que es lo contrario del "consumo que se atenúa y es absorbido por el alcohol".

**Cómo leer esto.** No refuta la hipótesis clínica, que es sobre personas en tratamiento. Sí dice que **la población general no muestra el patrón en niveles**, y que si aparece en un análisis de proporciones es aritmética. La hipótesis, tal como está enunciada, no es contrastable con este diseño sin datos individuales o de registro.

---

## 8. Amenazas de sesgo

Ordenadas por riesgo de hacerte creer la hipótesis siendo falsa. **[V]** = verificado ejecutando código sobre estos archivos.

### Las tres que más importan

**A1. El pseudo-panel no observa transiciones; el desplazamiento a nivel de celda no está identificado. [V]**
La hipótesis es individual ("las mismas personas pasan de cocaína a alcohol problemático"). El diseño observa sólo medias marginales de celda, con personas distintas cada ola. Se simuló N=200,000 con dos tipos **disjuntos** y **cero switching**: tipo A (15%) usa cocaína con perfil etario decreciente y riesgo de alcohol problemático **fijo** en 0.05; tipo B (85%) nunca usa cocaína y tiene riesgo de alcohol creciente. Resultado sobre edades 20–60: cocaína 0.1388 → 0.0062, alcohol problemático 0.0448 → 0.1184, y la regresión de celda de alcohol problemático sobre cocaína da **β = −0.476, t = −10.3, R² = 0.939**. Es decir, **la hipótesis nula exacta reproduce la firma de la hipótesis con mejor ajuste del que probablemente obtengas con datos reales.**
*Chequeo obligatorio:* calcular, con la microdata que ya tienes, la tabla 2×2 individual de `cocaines_ly` × alcohol problemático **dentro** de cada celda cohorte-sexo-ola, y publicarla. Si los bebedores problemáticos mayores no son desproporcionadamente ex-usuarios de cocaína (usar `COC_1`/`PB_1` y las edades de inicio, presentes en todas las olas), la historia individual no tiene huella transversal. Además, calcular cotas de Fréchet-Hoeffding sobre la matriz de transición a partir de las marginales consecutivas y publicar su **ancho** junto a cada estimación puntual. El abstract debe decir que no se observa ninguna transición.

**A2. El módulo de drogas era autoaplicado hasta 2018 y dejó de serlo. [V] — esto resuelve lo que yo había marcado como no verificado.**
En 2012–2018 el bloque de alcohol y drogas era una secuencia **autoaplicada cuyo modo elegía el entrevistado**, registrado en `p9_1` (2012), `sa1` (2014), `sa_1` (2016), `SA_1` (2018). La proporción que eligió autoaplicarse subió **3.4% → 9.7% → 9.3% → 21.0%**, y luego **la opción y la variable desaparecen**: no existen en `enpg2020.RDS`, `enpg2022.RDS` ni en el archivo 2024. El `cuestionario 2024.pdf` tiene 0 ocurrencias de "AUTOAPLIC" o "voz alta" contra 77 de "ENCUESTADOR" y 13 de "TARJETA".
Dos canales, ambos hacia la hipótesis. (a) **Dentro de ola**, los jóvenes eligen autoaplicarse mucho más que los mayores. Gradiente por tramo (chunk `ppd-response-mode`, cálculo propio):

| Ola | 15–24 | 25–34 | 35–44 | 45–54 | 55–65 |
|---|---|---|---|---|---|
| 2012 | 7.49 | 4.32 | 3.00 | 1.42 | 0.70 |
| 2014 | 13.75 | 10.87 | 9.05 | 8.39 | 7.08 |
| 2016 | 19.99 | 12.42 | 8.06 | 4.70 | 3.32 |
| 2018 | 33.73 | 27.96 | 22.80 | 15.55 | 9.30 |

Y autoaplicarse **sube** el reporte de drogas pero no el de alcohol. Razón de prevalencia reportada (autoaplicado / leído en voz alta), mediana sobre estratos edad × sexo: **marihuana 1.57, cocaínas 1.20, alcohol 1.03**. (Advertencia: el modo no está aleatorizado, así que estas razones dimensionan la exposición, no identifican un efecto causal de modo.)

(b) **Entre olas**, la pérdida de la opción tras 2018 deprime el reporte estigmatizado justo en 2020/2022/2024, que son las olas donde toda cohorte se observa más vieja. Drogas bajan en edades mayores y el alcohol no: eso *es* el patrón de desplazamiento, fabricado.
*Mitigación:* condicionar en el modo donde existe (2012–2018) y estandarizar; para 2020+ no se puede, así que hay que reportar el quiebre como límite. **Ya implementado:** chunk `ppd-response-mode`.

**A3. La prevalencia DE VIDA cae dentro de cohortes cerradas, lo que es imposible. [V]**
Nadie deja de haber probado una droga. Dentro de una cohorte fija, la prevalencia de vida sólo puede subir. Cae. Para cohortes cuya iniciación ya estaba completa: marihuana pierde **12% a 23%** de su máximo hacia 2024 (cohorte 1980–1989: 49.7% en 2016 → 39.7% en 2024, −10.1 pp); cocaínas pierde **18% a 38%** (cohorte 1960–1969: 6.90% en 2020 → 4.27% en 2024; cohorte 1980–1989: 12.15% en 2016 → 8.07% en 2024). La no respuesta del ítem es baja y estable (0.12%–0.76%), así que no la explica.
**Matiz del crítico, importante:** el coeficiente de −11.7% por década que estimó un lente proviene de un logit con efectos fijos de **año de nacimiento** y sin efecto de ola; dado año de nacimiento, edad ≡ ola − nacimiento, así que ese coeficiente es de **tiempo calendario**, no de edad. Es una **cota superior** del borrado, confundida con período y con atrición selectiva. El titular correcto es: *"la prevalencia de vida cae dentro de cohortes, lo que refuta conjuntamente el reporte estable y el cierre de la cohorte"*, sin repartir entre ambos — y ambas alternativas son igualmente fatales para leer el declive como cesación.
*Ya implementado:* el chunk `ppd-lifetime-monotonicity` del notebook hace este chequeo y emite advertencia.

### Amenazas de identificación y estimación

**A4. Identificación edad–período–cohorte. [V]** Cohorte = período − edad. Regresando edad media sobre efectos fijos de cohorte y ola se obtiene **R² = 0.998**, con desviación residual de 0.70 años. Con 10 años de banda y ventana 15–65, las únicas desviaciones de la colinealidad vienen de cohortes **recortadas** por la ventana. "Baja con la edad" y "es menor en cohortes más viejas" son el mismo hecho reducido bajo dos normalizaciones. La especificación que la mayoría elige (sin dummies de ola) es la que apoya la hipótesis espuriamente.

**A5. La pendiente de edad se identifica casi enteramente en cohortes truncadas por los bordes. [V]** Por Frisch–Waugh, las cuotas de apalancamiento del coeficiente de edad son: cohorte 1950–1959 = **52.6%** (hombres) / 53.1% (mujeres); cohorte 2000–2009 = 16.3% / 15.0%. **Una sola celda** (1950–1959 × 2022) concentra una fracción enorme. La pendiente estimada para alcohol en hombres se mueve entre **−0.013 (ns), −0.086 (t=−5.14), +0.009 (ns) y −0.182 (t=−3.21)** según qué cohorte truncada se retenga. Cualquier "declive con la edad" es frágil a esa elección.
*Mitigación:* excluir celdas cuyo rango etario observado sea menor que la mitad del ancho de la cohorte, o usar el panel balanceado, y reportar ambas.

**A6. Edad top-coded en 65. [V]** `max(edad) = 65` con cero casos por encima en las siete olas, y la edad 65 acumula 46%–106% más casos que la 64. Cuatro celdas de análisis tienen `mean_age` degenerada en exactamente 65.00 — **las mismas que cargan la identificación de A5**.

**A7. Celdas degeneradas y el offset arbitrario del logit. [V]** Con pasta base, 21% de celdas tiene cero casos: p̂=0, varianza estimada 0, peso infinito en una segunda etapa ponderada por precisión, y −∞ en escala logit. El offset que se elija (0.5/n, etc.) **mueve la pendiente** y no está restringido por los datos.

**A8. La ponderación de celdas en segunda etapa mueve la pendiente de cocaína hasta 3×. [V]** No está restringida por la teoría e interactúa con A5.

**A9. Diferenciar entre olas duplica el ruido**, porque las celdas contienen personas distintas: atenúa cualquier especificación dinámica hacia cero. *Dirección: en contra de la hipótesis*, pero induce a elegir la especificación que sí sobrevive.

**A10. Sobre la corrección de Deaton — CORRECCIÓN a lo que dijo un lente.** Un lente afirmó que la corrección es "inválida" porque la varianza del error depende de p. El crítico lo desmintió y tiene razón: Deaton (1985) requiere un **estimador consistente de la matriz de segundos momentos del error muestral**, no independencia entre el error y el valor verdadero. La heterocedasticidad de σ²_c es precisamente lo que absorbe una corrección **específica por celda**, que es la implementación estándar. Quedan dos preocupaciones reales pero más estrechas: (a) usar un Σ escalar agrupado en vez de Σ_c por celda; (b) que la matriz corregida deje de ser definida positiva en las celdas degeneradas. El sesgo de sustituir p(1−p) por p̂(1−p̂) es O(1/n_c) y con n_c entre 373 y 4,400 es despreciable.

### Selección fuera del marco

**A11. Atrición diferencial (muerte, cárcel, calle, institucionalización). [V] parcial** La ENPG es de **hogares**. Los consumidores más severos de pasta base salen del marco. Produce mecánicamente "declive con la edad" sin ninguna sustitución. **Advertencia [V]:** los códigos de causa de muerte por drogas en DEIS **sub-registran severamente**, así que el diagnóstico obvio de mortalidad *tranquiliza falsamente*. La magnitud verificada acota el efecto por debajo de lo que sugieren las trayectorias crudas en edades jóvenes y medias, y se vuelve dominante recién a los 48–65.

**A12. Cobertura ponderada con gradiente etario. [V]** Suma de pesos dividida por población INE, hombres: edades 25–34 = 0.628 (2012), 0.655 (2014), 0.724 (2018), 0.660 (2020), 0.914 (2022); edades 55–65 = 0.831, 0.961, 0.950, 0.934, 1.037. **La cobertura mejora a medida que la cohorte envejece**, lo que empuja la prevalencia medida de cocaína hacia abajo a lo largo de la ventana del panel. Mujeres igual.

**A13. No respuesta, esfuerzo de contacto y sustitución de hogares no están registrados en ninguna ola. [V] (la ausencia)** No existe ninguna variable de resultado de contacto, rechazo, intentos o reemplazo en ninguno de los siete archivos. El cuestionario 2016 contiene un fragmento revelador sobre abandonar la aplicación "porque las condiciones de aplicación eran muy peligrosas", confirmando que hubo viviendas abandonadas en terreno, pero sin bandera publicada. La magnitud es **[NV]**.
*Mitigación sin datos:* ejercicio de cotas asumiendo que los no respondentes tienen prevalencia k veces la de los respondentes para k ∈ {1,2,3}, y reportar el rango de pendientes.

**A14. El marco cubre ~109 de las 346 comunas de Chile, y cambia a mitad del panel. [V]** Comunas distintas con casos de 15–65: **108** en 2012, 2014 y 2016; **109** en 2018–2024. Los conjuntos 2012/2014/2016 son idénticos entre sí, y 2018/2020/2022/2024 también, pero **2016 vs 2018 comparten sólo 107**: se cae 1 comuna y entran 2. La cohorte no es una cohorte chilena, son los residentes de un conjunto fijo de comunas grandes. La pasta base está espacialmente concentrada, así que qué comunas están en el marco mueve directamente el resultado más raro. Además **no se publica ninguna variable urbano/rural** en ninguna ola (2016 sólo trae `zona`, que es zona censal), aunque la portada del cuestionario 2024 registra "1. Urbano / 2. RAU / 3. Rural".
*Mitigación:* recomputar las siete olas sobre la intersección de 107 comunas y reportar si cambia el gradiente; enunciar el estimando como "residentes de 109 comunas", no "Chile".

**CORRECCIÓN a un flag mío anterior:** yo había marcado la creación de Ñuble (región 16, 2018) como quiebre de cobertura. **Es incorrecto.** [V] Las comunas con código 16xxx pasan de 0 a 2 y las 8xxx de 12 a 11: es esencialmente un **re-etiquetado**, no un cambio de cobertura. Lo que sí cambia es la **definición del estrato** si usas `región`. Mitigación: recodificar Ñuble dentro de Biobío en todas las olas al construir el estrato.

**A15. Sin identificador de encuestador ni variable de privacidad/terceros presentes, en ninguna ola. [V] (la ausencia)** Búsqueda de `encuestador|entrevistador|supervis|equipo|team` en los siete archivos: nada (2022 sólo tiene `FOLIO`, identificador de caso). Búsqueda de `privac|solo|acompañ|terceros`: ningún ítem de privacidad ni de presencia de terceros en ninguna ola; tampoco instrucción de aplicar en privado en los cuestionarios disponibles. Consecuencias: el componente de varianza de entrevistador queda fuera de todo SE de diseño, así que **los deff reportados son un piso**; y el contexto del hogar está graduado por edad por construcción (un mayor es más probable que sea entrevistado con cónyuge o hijo adulto presente).
**Negativo útil [V]:** no hay reporte proxy en ninguna ola; el cuestionario 2024 confirma un respondente autoinformante seleccionado por Kish. **El reporte proxy NO es una amenaza para este diseño.**

**A16. Composición de hogar: vivir solo se triplica. [V]** La proporción que vive sola sube (ponderada) 0.0495 → 0.0701 → 0.0755 → 0.0813 → 0.1529 → 0.1624 entre 2012 y 2024, con casi una duplicación en el límite 2020|2022. Ajustado por edad y sexo, vivir solo eleva el alcohol problemático (OR 1.42 en 2024) **y** las cocaínas (OR 2.07). Empuja la rama de alcohol hacia arriba (a favor de la hipótesis) y la de cocaínas también (en contra de la rama 1): es un confusor con signo, no ruido simétrico. *Cuidado:* los códigos de tamaño de hogar de 2012 y 2018 están sucios y no son comparables sin limpiar.

### Cohortes no cerradas y shocks de período

**A17. Migración. [V]** Extranjeros de 15–65 (ponderado): **4.4% (2018) → 8.6% (2022) → 9.2% (2024)**, concentrado en las cohortes de los 80 y 90 (6.7%→8.5% y 5.7%→9.9%), sin cambio antes de 1970. El ítem de nacionalidad **sólo existe desde 2018**. Codificación distinta: 2018 `DP_6` con `1`=chilena y `≥2` extranjera; 2022/2024 con `1` chilena, `2` doble, `3` extranjera — **no comparables sin ajustar**.

**A18. La ola 2020 se desvía del resto, y la causa está documentada y es legítima. [V]**

**Encuadre corregido.** Antes lo redacté como si 2020 fuera sospechosa. No lo es: el terreno se levantó entre noviembre de 2020 y junio de 2021, en plena pandemia, con cuarentenas del Plan Paso a Paso, encuestadores contagiados y transporte restringido. Que la captura de participantes fuera difícil y que el patrón salga distinto es **exactamente lo esperable**, y el informe lo documenta con transparencia. No es un defecto de los datos ni un indicio de error.

Lo que sí sigue en pie es la **consecuencia analítica**, que es independiente de si la causa es comprensible: 2020 tiene 89% presencial y 11% telefónico, sin secuencia autoaplicada y sin tarjetas de apoyo, con tasa de respuesta de 41,8% contra 62,4% en 2018, sin PSU utilizable y sin etiquetas de valores en el RDS público. Cae **a mitad de cada trayectoria de cohorte**, así que su desviación no se promedia: entra directamente en la pendiente etaria estimada.

**Tratamiento recomendado, y es rutinario.** No excluir 2020 por defecto ni tratarlo como contaminado. Estimar con un indicador de ola que absorba su nivel, y reportar como sensibilidad la estimación sin 2020. Si las dos coinciden, no hay problema que discutir; si difieren, la diferencia es el tamaño del efecto de la pandemia sobre la medición y debe reportarse como tal. Lo que no es defendible es promediar 2020 con el resto sin decir nada.

**[V] NEGATIVO útil:** el rumor de que 2020 hubiera sido íntegramente telefónica es **falso**; fue mayoritariamente presencial (89%).

**A19. Rediseño del cuestionario 2018. [V]** Crea un escalón hacia abajo en alcohol problemático y recodifica el ítem de HED (base 1 en vez de base 0). La forma de V que genera apoya la hipótesis, porque la recuperación desde el mínimo de 2018 coincide con las cohortes entrando en sus 40–60.

**A20. El "gate" de alcohol de vida perdió su lista de ejemplos de bebidas en 2024. [V]** En 2018 `OH_1` decía "¿Ha tomado Ud. alcohol (cerveza / malta, chicha, vino / champaña, o licores...)"; en 2024 dice sólo "¿Ha tomado Ud. alcohol alguna vez en su vida?". Sin la lista, algunos respondentes de consumo bajo o esporádico no se reconocen como bebedores. Encoge y re-selecciona el denominador de bebedores en la última ola, que es donde toda cohorte se observa más vieja.

**A21. Instrucción de recuerdo de festividades cambió en 2024. [V]** 2016 excluía en bloque; 2024 lo condiciona a la fecha, así que el recuerdo de la mayoría de los respondentes de 2024 **incluye** Fiestas Patrias y Año Nuevo.

**A22. Hump de normalización del cannabis con máximo en 2016. [V]** Visible simultáneamente en todas las cohortes: es período nacional, no edad. Apoya espuriamente la rama de "policonsumo declina" **sólo para marihuana**; la cocaína no tiene un hump comparable.

**A23. La asignación regional de la muestra oscila fuerte entre olas adyacentes** dentro de un panel fijo de comunas. Inflación de varianza correlacionada con la ola, así que puede disfrazarse de estructura de período o edad.

### Validez de constructo y transferencia

**A24. "≥1 síntoma de abuso DSM-IV" es un indicador de consecuencias sociales sesgado a hombres jóvenes**, no una escala de severidad, y el abuso DSM-IV **no** es dependencia sub-umbral sino un constructo distinto. Deprime la serie de alcohol en edades mayores respecto de un AUD verdadero — es decir, trabaja **en contra** de detectar la rama 2 — pero invalida la interpretación en ambas direcciones.

**A25. Transferencia a población en tratamiento.** La entrada a tratamiento se selecciona por severidad, comorbilidad y desventaja social, es decir por exactamente lo que no se mide. Puede imitar la hipótesis en datos de tratamiento sin que nada se desplace en la población general. Además, los que están en tratamiento están fuera del marco de la ENPG.

**A26. Errores muestrales de distintas sustancias correlacionados dentro de la celda.** Empujan a que cocaína y alcohol medidos se muevan juntos, **enmascarando** una relación negativa verdadera. *Conservador*: no puede producir un falso positivo. El crítico además señala que sólo entra si se regresa una media de celda sobre otra, y el estimando recomendado (contrastes entre perfiles etarios) nunca hace eso.

---

## 9. Los tres chequeos obligatorios antes de cualquier modelo

1. **Tabla 2×2 individual** de cocaínas × alcohol problemático dentro de cada celda, más la proporción de bebedores problemáticos mayores que alguna vez usó cocaínas. Si no son desproporcionadamente ex-usuarios, abandonar la interpretación de desplazamiento individual. (A1)
2. **Tabla cohorte × ola de prevalencia DE VIDA**, con los mismos pesos y SE de diseño, publicando `max(vida) − vida(última ola)` por cohorte con IC. Reestimar el gradiente etario inflando las celdas mayores por la razón pico/última; si la conclusión no sobrevive, decirlo. (A3)
3. **Definir el outcome de alcohol problemático sobre los slots invariantes a la redacción** (el de "hecho algo bajo los efectos del alcohol que pudiera causarle problemas": `p33`/`oh24`/`oh_28`/`OH_26`/`OH_22`; y el de familia/amigos: `p34`/`oh25`/`oh_29`/`OH_27`/`OH_23`), y correr un placebo con dummy de régimen A/B. Si el dummy de régimen absorbe la pendiente de edad, **el efecto de edad no está identificado** y hay que reportarlo así. Reportar la tasa **incondicional** como primaria. (A2, §6, §7.1)

---

## 10. Flags contra código existente del proyecto (NO se modificó nada)

En `FONDECYT-REGULAR--main/DATA PREPARATION ENPG.R` → `ENPG_FULL.RDS`:

1. **`nedu` queda vacío para los jefes de hogar** (~45% de 2012–2018), y no al azar.
2. **"media incompleta" es inalcanzable**: ambas ramas `nedu2==2` y `nedu2==1` asignan `"media completa"`.
3. **`ecivil == 2 & ecivil == 6 ~ "casado"`** es imposible (2016, 2018, 2020, 2022). Debería ser `|`.
4. **No hay pasta base**, y termina en 2022.
5. **Quiebre de nivel en el volumen de alcohol en 2018**: factores 5.26, 5.37, 4.13, **2.52**, 4.83, 5.53 para 2012–2022.

En `Sex-and-age-differences-.../Raw data/`: `enpg2012.RDS`, `enpg2014.RDS`, `enpg2016.RDS`, `enpg2018.RDS` son **placeholders de 2 bytes**. Los datos reales de esos años son los `.dta`. Hay un set RDS completo bajo `FONDECYT-REGULAR--main/rawdata/`.

---

## 11. Preguntas abiertas

1. **Escolaridad:** ¿aceptable la reconstrucción desde el ítem del jefe de hogar?
2. **Pasta base:** ¿colapsarla con cocaína a nivel de celda (D5)?
3. **Consumo problemático:** ¿umbral SENDA sobre los slots invariantes, o conteo graduado?
4. **Composición de cohorte:** ¿población total, sólo chilenos desde 2018, o proporción de extranjeros como covariable?
5. **Transferencia:** ¿hay datos de la cohorte en tratamiento, o el vínculo queda como argumento?
6. **Nueva, y la más importante:** dado §7, ¿la pregunta de investigación sigue siendo "¿ocurre el desplazamiento?", o pasa a ser "¿por qué la población general no muestra el patrón que sí se observa en tratamiento?"? La segunda es contrastable con estos datos; la primera no lo es sin registros individuales.

---

## 12. Notas operativas del notebook

- **Formato / el problema de Positron.** Honestidad sobre esto: **no pude reproducir el fallo de render**, así que la corrección no está confirmada, sólo es la más probable. Lo que sí está establecido: la versión anterior era JSON válido y pasaba `nbformat.validate`, y la **única** diferencia estructural frente a `expand_pif3.ipynb` era que `jsonlite` escribe con finales de línea **CRLF** y empaqueta cada arreglo `source` en una sola línea física. Ahora el `.ipynb` se escribe con `jsonlite` y **luego se normaliza con el serializador propio de `nbformat`** (Python/Anaconda: `C:\ProgramData\anaconda3\python.exe`, script `normalize_nb.py`), que produce la forma canónica de Jupyter. Estado actual verificado: **0 bytes CR**, un elemento de `source` por línea, `metadata.vscode.languageId = "raw"` en la celda de front-matter (igual que `expand_pif3`), `nbformat.validate` en verde, 38 celdas, sin etiquetas de chunk duplicadas. Si vuelves a generar el notebook, **no omitas el paso de normalización**. Si aun así no renderiza, el siguiente sospechoso es el entorno de Positron, no el archivo.
- **Selección de olas:** parametrizada en `ppd-setup` como `ppd_waves_included`. El registro completo (con 2008 y 2010) queda en `ppd_wave_registry_all`.
- **Aserciones:** **15** controles que abortan si fallan, más el chunk `ppd-assertion-gate` que cuenta cuántas corrieron y **falla si son menos de 15** (protege contra que un chunk se salte o se reordene). El YAML lleva **`error: false`**, de modo que una aserción fallida aborta el render en vez de imprimirse y seguir. El control de prevalencia de alcohol detecta la confusión primera-vez/última-vez; el de monotonicidad de prevalencia de vida y el del contraejemplo de abstinencia son los otros dos que importan.
- **Advertencia de evidencia:** el `.ipynb` guardado tiene los outputs vacíos porque **nunca se ejecutó como notebook**; la verificación se hizo ejecutando el `.R` plano extraído de él. Un `.ipynb` con outputs vacíos no prueba nada por sí solo. Para que se auto-evidencie hay que ejecutarlo (`jupyter nbconvert --execute --inplace`) en la máquina que tenga los datos.
- **`.gitignore`:** el repositorio usa whitelist defensiva (`*`), así que **el notebook y este .md quedan fuera de git** salvo que se agreguen explícitamente.
- **Archivo huérfano:** `pseudopanel_fase1/ppd_problematic_battery_inventory_*.csv` proviene de una versión anterior del chunk de baterías. Ya no corresponde a ningún chunk; conviene borrarlo.
- **Requisitos:** R 4.4.1 con `haven`, `survey`, `dplyr`, `tidyr`, `tibble`, `ggplot2`, `scales`, `forcats`, `knitr`, `purrr`. **No** requiere `srvyr` ni `plm`.

---

## 13. Errores que cometí y corregí (para que no se repitan)

1. Usé la variable de *primera* vez de alcohol en vez de la de *última* en 2008 → 8.9% en vez de 68.4%. Detectado por el control de rango.
2. Mi primer mapeo de escolaridad ignoraba el ítem de completitud → salto imposible de 23 puntos. Detectado comparando contra la tendencia de expansión educacional.
3. Afirmé que ENPG 2018 no tenía escolaridad. **Falso**: está bajo `T_DP_*`. La búsqueda por etiqueta fallaba por el truncamiento de Stata a 80 caracteres.
4. Mi verificación de codificación de la batería de abuso usaba un umbral mal planteado y falló espuriamente.
5. En el diagnóstico de prevalencia de vida dejé 2016 **sin ponderar** (su factor está en archivo externo), lo que fabricó una caída falsa en esa ola.
6. El chunk `ppd-lifetime-monotonicity` parseaba la etiqueta de cohorte `"1950-1959"` como entero, dando `NA`, de modo que **la advertencia no se disparaba y el chunk imprimía un mensaje tranquilizador falso**. Corregido con un `stop()` que impide que el test pase de forma vacua.
7. Marqué la creación de Ñuble como quiebre de cobertura del marco. Es sólo un re-etiquetado de estrato (ver A14).
8. Atribuí el problema de la batería de abuso al quinto ítem; el peligro real es el cambio de **redacción** (ver §6).

---

## 14. Reconciliación con la revisión de Codex y con `__enpg`

Qué acepté, qué corregí y qué queda pendiente tras la crítica de Codex y la lectura de tu trabajo previo en `C:\Users\nDP\Desktop\ACC1240138_private\__enpg`.

### 14.1 Lo que Codex tenía razón y ya está corregido en el notebook

| # | Crítica | Estado |
|---|---|---|
| C1 | Los estados propuestos mezclaban tres dimensiones (último año / historia de vida / consumo problemático) y no eran disyuntivos como una sola variable nominal. | **Aceptado.** Reestructurado en **tres ejes** (§4). Eje 1 `profile_amc` de 4 niveles; eje 3 historia (`cocaines_status`, `lifetime_breadth_drugs`, `former_drug_use_no_current`); eje 2 (perfil problemático) queda para Fase 3. |
| C2 | `A0_M0_C0` no es abstinencia ni "nunca consumió"; cobertura 97.9–99.5%, no 100%. | **Aceptado.** El nivel se llama ahora `1_no_AMC_use_last_year` y el notebook **mide el contraejemplo** en vez de asumirlo: 53, 37, 60, 55, 67, 76 y **177** personas por ola reportan otra droga estando en ese nivel. Hay una aserción que **falla si el contraejemplo desaparece**. |
| C3 | `cocaines_ly` trataba `0 + NA` como 0. El compuesto correcto es 1 si algún componente es 1, 0 sólo si todos son ceros conocidos, `NA` en el resto. | **Aceptado, era un bug real.** Implementado como `ppd_any_of()`, disyunción de Kleene, aplicado a todos los compuestos. En 2024 sola cambia 9 casos, pero el error caía casi enteramente sobre las celdas cero, que es donde más daña. |
| C4 | Las aserciones de "≤8 estados" y "los conteos suman" no prueban exhaustividad conceptual. | **Aceptado.** Reformuladas: ahora dicen explícitamente que prueban consistencia interna de las tres clases medidas, no cobertura del consumo. |
| C5 | El notebook guardado no prueba "exit 0, 11 aserciones": tiene outputs vacíos y `error: true`, que permite continuar ante errores. | **Aceptado, la crítica es justa.** Cambiado a **`error: false`** (una aserción fallida aborta el render) y agregado el chunk **`ppd-assertion-gate`**, que cuenta las aserciones ejecutadas y **falla si son menos de 15**. Mi verificación anterior venía de ejecutar el `.R` plano extraído del notebook, no del notebook renderizado; eso debí haberlo dicho. Ahora son **15 aserciones**. |
| C6 | `verify_s7.R` no estaba presente, así que el 26.4% no era certificable. | **Aceptado.** Ese script vivía en el directorio temporal de sesión, fuera del repositorio. La lógica está ahora **dentro del notebook**, chunk `ppd-problematic-alcohol-age-profile`, y con las siete olas en vez de dos. |
| C7 | `O` necesita dos versiones y Tusi no debe clasificarse como cocaína. | **Aceptado parcialmente.** Implementado `other_drug_ly` como **piso explícito**: la grilla de 9 tranquilizantes sin receta, verificada como la única clase no-A/M/C con escala de recencia idéntica en las siete olas (208–435 usuarios de último año por ola). Tusi es módulo propio y **sólo existe en 2024**; no se toca. El `O_core` completo queda pendiente, ver 14.3. |

### 14.2 Lo que `__enpg` corrigió de mi trabajo

**CORRECCIÓN GRAVE — etiqueté mal el ítem de HED.** Hay **dos ítems distintos** y yo registré el equivocado:

- **Binge / HED real, sexo-específico:** *"Pensando en los últimos 30 días… Si es hombre: ¿cuántas veces tomó **5 o más** tragos en una sola ocasión? Si es mujer: **4 o más**"*. Es un **conteo de ocasiones** (0–8). Variables: `p16` (2012), `oh7` (2014), `oh_7a`/`oh_7b` (2016, partido por sexo), `OH_7H`/`OH_7M` (2018, partido por sexo), `OH_7` (2020, 2022, 2024).
- **AUDIT-3, NO sexo-específico:** *"¿Qué tan seguido toma usted **6 o más** tragos en una sola ocasión?"*, escala Nunca…Todos los días. Variables: `p21`, `oh12`, `oh_16`, `OH_14`, `OH_10`.

Mi registro llamaba `hed_item` al segundo. **Corregido**: el campo se llama ahora `audit3_item` y se agregó `binge_item`. Esto además resuelve la nota de memoria del proyecto sobre "HED 6→5/4 tragos entre olas": no es que el umbral cambiara entre olas, son **dos instrumentos coexistentes**.

Otras correcciones y aportes de `__enpg`:

- **PSU 2016**: ver §3. Colapsaba 358 manzanas distintas.
- **2008 tiene sólo 95 comunas**, no 108. Si alguna vez se extiende hacia atrás, 2008 rompe el supuesto de marco constante.
- ~~El marco NO es sólo urbano.~~ **RETRACTADO — era inferencia de una portada de cuestionario y es falso.** Los informes oficiales lo dicen literalmente: *"esta encuesta **solo considera el área urbana** de las 109 comunas que se encuentran en el MM2015"*. El marco rural (MS2002) existe pero **se excluye de la selección**; sólo se usa para calcular denominadores de cobertura. Las comunas son las de 30.000+ habitantes y la cobertura es *"aproximadamente el **70% del total de la población nacional**"*. Ver §15.
- **`dictionary_problem.csv` vacío es un verdadero negativo, no un bug**: `abuso`, `problemátic`, `dsm`, `síntoma` aparecen **cero veces** en las etiquetas de las 4,397 variables. Las baterías DSM **no están etiquetadas como tales en ningún archivo público** y hay que localizarlas por posición. Corrobora mi advertencia de no usar regex sobre etiquetas.
- **La batería de abuso está estructuralmente ausente (no "no") para no bebedores**, por patrón de salto explícito en los cuestionarios. Coincide con la implementación.
- **2016 lleva la instrucción "No considere Fiestas Patrias"** en los ítems de 30 días; 2012 y 2014 no. Rompe la comparabilidad de todo lo de últimos 30 días en 2016.
- **`ST_1` opción 2 en 2014 y 2016 es "en papel, submuestra aleatoria"**: asignación **aleatoria** de modo. Es potencialmente un **instrumento** para identificar causalmente el efecto de modo de la amenaza A2, que hoy sólo está dimensionado. Vale la pena explotarlo.
- **Las "otras drogas" no tienen batería de dependencia ni abuso en ninguna ola**, así que no pueden alimentar un indicador de consumo problemático. Y la lista de drogas ilegales cambia en 2014 (agrega marihuana sintética) y en 2016 (agrega mefedrona/catinonas): el conjunto comparable 2012–2016 es sólo Hachís, Éxtasis/MDMA, Heroína y Crack.
- **Duplicado de 2012**: `__enpg` tiene `Base de datos ENPG 2012 (PG).dta` (nombres **sin** acento: `region`, `codigo_comuna`) y `...(PG).DTA.dta` (**con** acento). Mi pipeline lee la acentuada y la resuelve con regex de respaldo, así que funciona, pero conviene saberlo.
- **VALIDACIÓN EXTERNA FUERTE, y es lo más valioso de `__enpg`:** tu reconstrucción nacional **reproduce exactamente** las cifras publicadas por SENDA para 2012–2020, con diferencias ≤ 5e-6 puntos porcentuales y ≤ 0.7 personas ponderadas en las 45 celdas. Eso valida el mapa de variables, el filtro etario y las definiciones de caso. **Úsalo como control obligatorio antes de cualquier estimación nueva.** 2010 discrepa sólo en `prev_py` (−0.064 pp); 2008, 2022 y 2024 nunca se validaron contra el workbook.
- **La brecha de tratamiento es 94–97% en todas las olas**, estimable a nivel nacional pero **no regional** salvo en la Región Metropolitana: sólo 41 de 432 celdas región×ola×outcome quedan sin banderas, y 25 de esas 41 son RM. Restricción directa sobre cualquier diseño de celdas cohorte×región.

### 14.3 Lo que queda pendiente

1. **`O_core_ly`**: el conjunto exacto de "otras drogas" comparable entre olas. Requiere los cuestionarios de 2018, 2020, 2022 y 2024, que **no están en `__enpg`**. El piso de tranquilizantes ya implementado es un sustituto conservador, no la solución.
2. **Eje 2, perfil problemático** (`AP`/`MP`/`CP` armonizados). El material ya existe: las baterías de dependencia de 10 ítems con el colapso a 6 criterios y umbral ≥3 están en `__enpg\_codex_temp_audit_enpg\audit_gap.R`, validadas contra SENDA. **Reusar eso en vez de reconstruirlo.**
3. **Explotar la submuestra aleatoria en papel de 2014 y 2016** para identificar causalmente el efecto de modo.
4. ~~Decidir la llave de PSU de 2018.~~ **Cerrado**: `idmanzana`, siguiendo `expand_pif*.ipynb`; y las tres alternativas dan el mismo resultado. Ver §3.
5. **Verificar el cuestionario 2018** para confirmar que el patrón `a`/`b` de escolaridad se mantiene; hoy es inferencia, no evidencia.

### 14.4 El límite formal del diseño, aceptado y adoptado

Codex lo enuncia mejor que yo y lo adopto. Con K estados, dos distribuciones marginales consecutivas dejan **(K−1)² parámetros de transición sin identificar**. El pseudo-panel permite estudiar cómo cambia la **distribución** de estados de una pseudo-cohorte; **no** permite saber que las mismas personas pasaron de cocaínas a alcohol. Referencias: Deaton (1985), doi 10.1016/0304-4076(85)90134-4; Verbeek y Nijman (1992); Moffitt (1993), doi 10.1016/0304-4076(93)90041-3.

Formulación defendible:

> Trayectorias etarias de la distribución de estados de consumo en pseudo-cohortes, y compatibilidad de esas trayectorias con una hipótesis de sustitución o abandono.

No:

> Probabilidades individuales de transición desde cocaínas hacia alcohol o abstinencia.

Y la población representada son **residentes de viviendas particulares de las 109 comunas cubiertas**, no "los chilenos".

---

## 15. Diseño oficial, extraído de los informes ENPG 2018 y 2020

Fuentes: `__enpg\ENPEG-2018.pdf` y `__enpg\ENPG-2020-WEB.pdf`, más los cuestionarios `Cuestionario ENPG_2022.pdf` y `cuestionario 2024.pdf`. Esto cierra la mayor parte de §2 y **corrige varias cosas** que estaban como inferencia.

### 15.1 El diseño muestral, ahora con la definición oficial

> *"Unidad de primera etapa: **manzanas**. Unidad de segunda etapa: **viviendas particulares ocupadas**."* Tercera etapa: la persona seleccionada por **tabla de Kish**.

> *"El diseño muestral corresponde a una muestra probabilística, **estratificada geográficamente y por tamaño poblacional en el área urbana, trietápica**, con probabilidad de selección de la unidad de primera etapa (manzanas) **proporcional al tamaño**."*

**El estrato oficial NO es la región.** Es *"la **intersección de comuna con los grupos de tamaño**"* de manzana. Hay seis grupos de tamaño por número de viviendas (0 = 1–7, excluido de la selección; 1 = 8–23; 2 = 24–44; 3 = 45–81; 4 = 82–154; 5 = 155+), sobre un marco de 113.166 manzanas y 3.595.622 viviendas.

**Consecuencia práctica, y es accionable:** la variable `grupogrande` de 2018 está etiquetada *"Grupo de Tamaño de la manzana"* — **es el componente de tamaño del estrato oficial**. Es decir, en 2018 el estrato oficial es reconstruible como `comuna × grupogrande`. Mi notebook usa `región` en todas las olas por comparabilidad entre olas, que es una aproximación gruesa y ahora está documentada como tal. Vale correr 2018 con el estrato oficial como sensibilidad.

**El marco es urbano.** *"La encuesta considera el **área urbana** de 109 comunas del país"*, comunas de 30.000+ habitantes, cobertura *"aproximadamente el **70% del total de la población nacional**"* (87,5% de las viviendas urbanas del MM2015; 84,6% sobre el marco combinado; rango regional 59,0% Ñuble a 97,8% Arica y Parinacota). El marco cartográfico es **Censo 2002 actualizado a 2015 (MM2015)**, verificado contra PreCenso 2016 — **no** es base Censo 2017.

**Población objetivo, textual:** *"personas de edades comprendidas entre **12 y 65 años**, que residen habitualmente en viviendas particulares en las **zonas urbanas de las 109 comunas**"*. Y la exclusión que confirma la amenaza A11 desde la fuente oficial: *"**Se excluye población que vive o se encuentra en situación de calle y en instituciones como hospitales y cárceles**, entre otras."*

**Ponderación:** siete ajustes secuenciales (selección de 1ª, 2ª y 3ª etapa; elegibilidad; no respuesta; suavizamiento; calibración). La calibración es a *"proyecciones de población por **comuna, región, sexo y tramo de edad**"* para 12–65 en el área urbana de cada comuna. **La base de las proyecciones no se declara en ninguno de los dos informes.** El truncamiento de pesos de 2018 usa punto de corte **5 × media comunal**; 2020 no declara el valor. Esto es candidato a explicar la anomalía de dispersión de pesos de 2022 (amenaza A7): puede ser simplemente otro punto de corte.

### 15.2 La ola 2020, ahora documentada — la amenaza A18 queda confirmada y cuantificada

| | 2018 | 2020 |
|---|---|---|
| Terreno | sep 2018 – mar 2019 | **nov 2020 – jun 2021** |
| Ejecutor | GfK Adimark | Ipsos Chile |
| Modo | **100% CAPI presencial** | **89,0% CAPI / 11,0% CATI telefónico** |
| Tarjetas de apoyo | sí | **eliminadas** |
| Secuencia autoaplicada | sí (`SA_1`) | **eliminada** |
| Muestra objetivo | 20.056 viviendas | 23.556 viviendas |
| Lograda | 19.427 (**96,9%**) | 16.662 (**70,7%**) |
| Tasa de respuesta TRR1 | **62,4%** | **41,8%** |
| Cooperación TCC1 | 84,5% | 72,4% |
| Contacto TC1 | 73,8% | 57,8% |
| Rechazo TR1 | 11,2% | **15,5%** |

El informe 2020 afirma que las adaptaciones *"mantienen la comparabilidad de la serie"*, pero también describe explícitamente el daño: cuarentenas del Plan Paso a Paso, encuestadores contagiados, negativa de personal a salir a terreno, transporte reducido (*"no se lograba trabajar después de las 17 h"*), supervisión telefónica. **Ninguna región alcanzó el 100% de logro en 2020**, contra cinco regiones sobre 100% en 2018. La región Metropolitana bajó a 27,3% de respuesta.

Esto convierte a **A13 (no respuesta) de "[NV] magnitud desconocida" a magnitud medida**: la tasa de respuesta cayó 20,6 puntos entre 2018 y 2020. Si la no respuesta correlaciona con consumo, eso solo mueve la prevalencia medida en la dirección del declive.

### 15.3 La amenaza A2 se agrava: la autoaplicación no "desapareció del archivo", fue eliminada por diseño

El informe 2020 lo dice como adaptación sanitaria deliberada: se eliminó la sección autoaplicada y se eliminaron las tarjetas. Es decir, el quiebre de modo entre 2018 y 2020 **no es un artefacto de publicación de datos, es un cambio de instrumento documentado**, y afecta justamente al módulo estigmatizado. Los cuestionarios 2022 y 2024 tampoco traen bloque autoaplicado. Y **no existe ítem de modo de captura** en 2022 ni 2024, así que desde 2020 en adelante el modo no es condicionable.

### 15.4 Instrucción de recuerdo de festividades: cuatro regímenes distintos en cuatro olas

| Ola | Exclusión en los ítems de 30 días |
|---|---|
| 2016 y 2018 | *"No considere Fiestas Patrias"*, **en bloque, incondicional** |
| 2020 | **ninguna** (cero ocurrencias en todo el informe y su cuestionario) |
| 2022 | **condicional a la fecha**, y **sólo Año Nuevo**: *"SI FECHA ES >= A 01/01/2023 Y <= 31/01/2023, MOSTRAR: No considere Celebraciones de Año nuevo"* |
| 2024 | **condicional a la fecha**, Fiestas Patrias **y** Año Nuevo apiladas |

Cualquier medida de 30 días (volumen, binge) arrastra este cambio. Y hay tres defectos de instrumento en 2024 que conviene conocer: dos erratas de fecha (`01/01/20232025`, `01/012025`) y el ítem `OD_14` que **quedó sin actualizar**, todavía con las fechas de 2022.

### 15.5 Confirmaciones que cierran pendientes

- **El binge `OH_7` es idéntico palabra por palabra en 2022 y 2024**, sexo-específico 5+/4+, y su respuesta es un **conteo abierto de ocasiones, rango 0–99**, no una escala. Confirma la corrección de §14.2. (Defecto menor heredado: las equivalencias en ml de la versión femenina repiten los números de la masculina, en ambos años.)
- **`OH_10` es el AUDIT-3**, sin marco de 12 meses y sin exclusión de festividades, en ambos años. Confirma que son dos ítems distintos.
- **Escolaridad 2022/2024 se pregunta una sola vez, al entrevistado** (`DP_11`–`DP_14`), con *"nivel educacional más alto alcanzado… **de usted**"*. Sin división a/b. Confirma el registro de §3.
- **El cambio de redacción de la batería de abuso en 2022 se aplicó en paralelo a marihuana (`MAR_18`), pasta base (`PB_16`) y cocaína (`COC_16`)**, no sólo a alcohol. El quiebre de §6 afecta a las cuatro sustancias.
- **No hay ítem de sustitución de viviendas** en ninguna ola; el remedio de no respuesta es sobremuestreo y hasta cinco visitas. En 2020 hubo reemplazo a nivel de **manzana**, en gabinete, contra PreCenso 2016, sin conteo publicado.

### 15.6 Lo que sigue sin resolverse

- **Base de las proyecciones de población** usadas en la calibración: no declarada en ninguno de los dos informes.
- **Punto de corte del truncamiento de pesos en 2020**: no declarado (2018 sí: 5).
- **Número de manzanas seleccionadas en 2020**: el informe omite la frase equivalente al *"3.388 manzanas"* de 2018.
- **Informes de 2012, 2014, 2016, 2022 y 2024**: no están. Los de 2018 y 2020 son casi clones entre sí, así que es razonable suponer continuidad del diseño, pero es suposición.

---

## 16. La serie 2012–2024 NO es homogénea: cambios de marco, estratificación y calibración

Fuentes: informes oficiales de 2012, 2014, 2016, 2018, 2020 y 2022 en `__enpg`. (`ENPG-2024.pdf` **no es un informe metodológico**: son 16 láminas de resultados con una ficha técnica de 10 viñetas, sin diseño muestral, sin tasas de respuesta y sin ponderación.)

Esto es lo más importante que salió de los informes, y **cambia cómo hay que modelar la serie**.

### 16.1 El quiebre grande está en 2022: cambió el marco muestral

Textual, informe 2022:

> *"El marco muestral utilizado en este estudio es generado a partir de la cartografía digital proveniente del **Censo de Población y Vivienda de 2017**, y fue actualizado a 2020 bajo la denominación de **Marco Muestral de Viviendas 2020 (MMV 2020)**. A diferencia del **Marco Muestral de Manzanas 2015 (MMM 2015)** —conformado por manzanas y utilizado para la versión anterior del estudio (ENPG 2020)—, el MMV 2020 está constituido por unidades primarias de muestreo, en adelante, UPM."*

O sea: **2012–2020 corren sobre un marco de manzanas de linaje Censo 2002; 2022 y 2024 corren sobre un marco de viviendas de linaje Censo 2017.** La UPM deja de ser la manzana y pasa a ser un conglomerado de ~200 viviendas (rango 160–240), del que se seleccionan 12 viviendas.

Esto explica de una vez la **anomalía de dispersión de pesos de 2022** que había quedado abierta en §5 y en el `FLAG 7` del notebook: no es un error ni un recorte caprichoso, es que el diseño entero cambió. UPM más grandes con toma fija de 12 viviendas producen probabilidades de selección más parejas, y por lo tanto pesos menos dispersos y un Kish más alto. **Queda explicada, no eliminada**: sigue habiendo un quiebre, pero ahora se sabe por qué y se puede modelar.

### 16.2 La calibración también cambió, y el salto es enorme

| | 2012–2020 | 2022 |
|---|---|---|
| Base de proyecciones | INE sobre **Censo 2002** (nombrado sólo en el informe 2012) | INE sobre **Censo 2017**, fecha de referencia 28-02-2023 |
| Método | razón simple, comuna urbana × sexo, 12–65 | **Raking** |
| Márgenes | comuna urbana × sexo | nacional sexo × 3 tramos [12-24] [25-40] [41-65]; regional sexo; regional × 3 tramos |
| Pasos del ponderador | 2 en 2012 y 2014; **8** en 2016 | 8 |

**Esto cierra la pregunta que quedaba abierta desde §15**: la base de las proyecciones. El informe **2012** la nombra —*"las proyecciones poblacionales del INE, basadas en el CENSO del año 2002"*— y el **2022** la nombra —Censo 2017—. Los de 2014, 2016, 2018 y 2020 usan una fórmula sin institución ni base, pero su linaje de marco es Censo 2002, así que la continuidad es razonable de suponer hasta 2020.

Dato para el audit: en 2022 la calibración **infla el total ponderado en 65,7%** (7.808.498 → 12.941.545). Y de 2022 a 2024 la población representada **cae 11,9%** (12.941.545 → 11.396.772) mientras el n logrado **sube** (17.454 → 18.668). Ningún informe explica esa caída.

### 16.3 La estratificación cambió dos veces

| Olas | Estrato |
|---|---|
| 2012 y 2014 | comuna, con subgrupos de tamaño **implícitos** (30 subgrupos según el informe 2016 en retrospectiva) |
| 2016, 2018 y 2020 | **explícito: comuna × grupo de tamaño de manzana**, condensado a **5** grupos |
| 2022 y 2024 | **109 estratos = área urbana de cada comuna**, más estratificación **implícita por NSE** en el orden de selección |

El informe 2016 dice explícitamente que antes *"la estratificación del marco muestral sólo correspondía a nivel comunal"*. Usar `región` como estrato en toda la serie —que es lo que hacemos tanto yo como `expand_pif`— es una aproximación que ahora está documentada frente a tres esquemas oficiales distintos.

### 16.4 La instrucción de Fiestas Patrias: el cambio es de protocolo, no sólo de redacción

Antes de 2016 el problema se resolvía **en terreno**: 2012 y 2014 dicen *"en el levantamiento de terreno **se excluye el período de un mes posterior a las Fiestas Patrias**"*. En 2016 esa frase **desaparece** y se sustituye por una instrucción dentro del cuestionario, más una lámina del tarjetero que tacha el 18 y 19 de septiembre. El informe 2016 documenta incluso que la primera versión probada en el pretest *"tendía a generar confusión en los encuestados"*.

O sea, para las medidas de últimos 30 días hay **cuatro regímenes** (ver §15.4) y además un cambio de protocolo de terreno en 2016. No afecta a las prevalencias de último año, que son las que usa la Fase 1, pero **sí a cualquier medida de volumen o binge**.

### 16.5 Serie de tasas de respuesta, ahora completa

| Ola | Respuesta | Cooperación | Contacto | Rechazo | Logro |
|---|---|---|---|---|---|
| 2012 | 61,8% | 83,2% | 74,3% | 11,5% | 83,4% |
| 2014 | 69,6% | 88,1% | 79,0% | 7,8% | 83,6% |
| 2016 | 64,0% | 86,9% | 73,7% | 9,0% | 79,6% |
| 2018 | 62,4% | 84,5% | 73,8% | 11,2% | 96,9% |
| 2020 | **41,8%** | 72,4% | 57,8% | 15,5% | 70,7% |
| 2022 | **45,0%** | 74,7% | 60,2% | 14,2% | 75,1% |
| 2024 | no publicada | — | — | — | — |

**La caída no es sólo de la pandemia.** 2022 se levantó íntegramente presencial, sin CATI y sin restricciones sanitarias relevantes, y aun así quedó en 45,0%. La serie tiene un escalón permanente de ~20 puntos entre 2018 y 2020–2022. La amenaza A13 deja de ser hipotética.

### 16.6 El modo de aplicación, serie completa — y la autoaplicación fue abolida, no suspendida

| Ola | Modo | Autoaplicación |
|---|---|---|
| 2012 | tablet, con opción de papel ofrecida al entrevistado | sí, ítem `p9_1` |
| 2014 | tablet, papel de respaldo en zonas peligrosas | sí, `sa1` |
| 2016 | **100% CAPI tablet** | sí en el archivo (`sa_1`), pero el informe dice que *"la mayoría de los encuestados prefiere que se aplique el cuestionario"* |
| 2018 | 100% CAPI tablet | sí, `SA_1`, 21,0% |
| 2020 | **89% CAPI / 11% CATI** | **eliminada** por protocolo sanitario |
| 2022 | 100% CAPI | **abolida explícitamente** |
| 2024 | "entrevista cara a cara" | no documentado |

Textual, informe 2022: *"**No se considera en ninguna instancia la opción de entregar respuestas del tipo autoaplicada**; vale decir, el encuestador debe aplicar la encuesta en su totalidad y, sin excepción, debe leer la totalidad de las preguntas."*

Es decir, la amenaza A2 no es un accidente de 2020: es un **cambio permanente de protocolo**. El módulo estigmatizado se responde en voz alta al encuestador desde 2020 en adelante, y eso no va a volver.

### 16.7 Consecuencia para el diseño del pseudo-panel

**Los quiebres se apilan en el mismo lugar.** Entre 2020 y 2022 cambian a la vez: el marco muestral, la base censal de la calibración, el método de calibración, el esquema de estratificación, la redacción de la batería de abuso, el número de ítems de abuso, y la abolición de la autoaplicación. Están **perfectamente confundidos entre sí**: con siete olas no hay forma de separarlos.

**Qué NO hacer:** partir la serie en 2012–2020 y 2022–2024. Con siete puntos, dos tramos de tres y cuatro no sostienen un pseudo-panel.

**Qué hacer:**
1. Mantener las siete olas con **efectos de ola libres**, no con una tendencia lineal de período. Un efecto de ola absorbe el nivel del quiebre; una tendencia lineal lo reparte sobre la pendiente etaria, que es justo lo que no se quiere.
2. Reportar como sensibilidad la estimación **sin 2022 ni 2024**, y la estimación **sin 2020**. Si las conclusiones sobreviven a las tres, se puede afirmar algo. Si no, el resultado es sobre instrumentos, no sobre conducta.
3. Enunciar en limitaciones que el diseño muestral cambió de marco en 2022 y que ningún informe oficial advierte de un quiebre de serie. **Los informes afirman continuidad**: 2012, 2014, 2016 y 2022 repiten casi textualmente que *"el formato de las preguntas… ha sido siempre el mismo"* y que *"las muestras no han variado sustancialmente"*. Eso es cierto de la redacción de las preguntas de prevalencia, y **no** es cierto del marco, la calibración ni el modo.

### 16.8 Un dato que conviene tener a mano

La cobertura del marco está cuantificada: **~70% de la población nacional** en todas las olas, y el detalle de 2022 es 86,4% de las viviendas urbanas y 86,2% de las UPM del MMV 2020, con rango regional de 57,6% (Ñuble) a 99,4% (Arica y Parinacota). Es decir, **el sesgo de cobertura no es uniforme entre regiones**, lo que importa si alguna vez se estratifican celdas por región.

Y la exclusión de población fuera del marco es explícita y constante en todas las olas: *"Se excluye población que vive o se encuentra en situación de calle y en instituciones como hospitales y cárceles, entre otras."* Es la confirmación oficial de la amenaza A11.

---

## CAVEMAN HANDOFF - 2026-08-06 12:09

### Decisiones tomadas

- **Banda 15-65** como base analitica, por congruencia con `expand_pif`. El control contra el workbook corre en 12-64 porque esa es la base del workbook. Ambas conviven; la banda mueve el estimando <=0.13 pp, es inmaterial.
- **Indice de abuso = 4 items comunes** en las 7 olas. Para 2012-2020 eso ES la definicion oficial SENDA (esas olas tienen 4 items). La divergencia empieza solo en 2022.
- **AUDIT-C sirve como ancla externa** para detectar quiebres del instrumento DSM. Validado: los 3 items tienen 5 niveles en las 7 olas, offset detectado por dato (2018 es base 1).
- 2018 PSU = `idmanzana`, siguiendo `expand_pif`. Indiferente: `idmanzana`, `comuna+idmanzana` y `Seccion` dan los mismos 3.185 conglomerados.
- 2016 PSU = `comuna+distrito+zona+manzana` (2.358), divergiendo de `expand_pif` (2.000). Justificado en `pseudopanel_divergencias_expand_pif.md`.

### Evidencia actual / mejor resultado

- **CONTROL DE REPRODUCCION PASADO, EXACTO.** Contra `__enpg/consumo problematico enpg 2020.xlsx`, fila Alcohol del bloque de consumo problematico, 12-64, N ponderado: 2012 421.929,9 / 2014 463.241,8 / 2016 501.463,3 / 2018 387.746,8 / 2020 422.532,1. Diferencia relativa maxima **0,0000%**. Porcentajes iguales al 4o decimal. Desgloses por sexo y denominador de bebedores tambien exactos.
- El 422.532 de 2020 es el numero citado en la Estrategia Nacional 2021-2030.
- **Error en el workbook, no mio**: la columna "12-17 anos" de la hoja 2012 contiene 12-19 (mi corte <=19 da 61.387,7, +0,0 exacto). La de "18-64" es 20-64. Total no afectado. Las otras 4 olas cuadran en el corte correcto.
- 2022 y 2024 NO estan en el workbook. Con mi definicion de 4 items: 7,329% y 6,409% sobre 12-64.
- **EL QUIEBRE DEL INSTRUMENTO ESTA EN 2018, NO EN 2022.** Razon DSM(4 items)/AUDIT-C positivo entre bebedores de ultimo ano: 0,285 / 0,317 / 0,305 | 0,222 / 0,217 / 0,247 / 0,223. Dos regimenes: 2012-2016 ~0,30 y 2018-2024 ~0,22-0,25. P(DSM|AUDIT+) cae de 22-24% a 14,5-16,3%.
- Los dos instrumentos **divergen en direcciones opuestas** desde 2018: DSM_any baja (7,72 / 7,31 / 7,73 -> 5,93 / 6,57 / 7,32 / 6,31) mientras AUDIT-C positivo sube (27,1 / 23,0 / 25,4 -> 26,7 / 30,3 / 29,6 / 28,3).
- **El 5o item de 2022/2024 es benigno y constante**: pasa de 7,315 a 7,982 en 2022 y de 6,312 a 6,889 en 2024, es decir **+9,1% relativo en ambas olas**. El indice de 4 items es una deflacion constante del oficial.
- Item que mas se mueve: **familia**, con caida persistente desde 2018 (-32%, -35%, -23%, -39% vs media 2012-2016). 2018 baja en 3 de 4 items a la vez. 2020 colapsa el item **rol** (-37%).
- Anomalia sin explicar: razon DSM/AUDIT en **mujeres 2020 = 0,076**, contra 0,159-0,258 en el resto.

### Bugs y problemas abiertos

- **No se sabe POR QUE se rompe 2018.** Candidatos no verificados: rediseno del cuestionario 2018; salto de autoaplicacion a 21,0% (era 9,3% en 2016); escala base 1 en los items AUDIT de esa ola; factor de calibracion de volumen 2,52 vs ~5 en el resto.
- El ancla AUDIT-C esta verificada en **estructura** (5 niveles, sin instruccion de Fiestas Patrias) pero la **redaccion** de los items 1 y 2 solo se leyo en algunas olas. Falta confirmarla en las 7.
- La razon de mujeres en 2020 (0,076) no tiene explicacion.
- Sin validar: filas Drogas y Sustancias del workbook (mi notebook no construye el indicador problematico de drogas). `__enpg/_codex_temp_audit_enpg/audit_gap.R` ya las valido exacto; reusar, no reconstruir.
- Sin validar: 2022 y 2024 contra cifra oficial. Prediccion contrastable: mi cifra de 2022 debe quedar **9,1% por debajo** de la oficial, porque uso 4 items y el oficial usa 5.
- El `.ipynb` sigue con `execution_count` vacio y sin outputs. No es un run auditable.
- Pendiente decidir el alcance del articulo (estrecho de compatibilidad vs ambicioso). Sin eso no se puede congelar protocolo.

### Archivos a revisar (rutas exactas)

- `C:\Users\nDP\Desktop\ACC1240138_private\__enpg\consumo problematico enpg 2020.xlsx` (hojas 2010-2020; bloque filas 14-16; col 6 = %, col 13 = N)
- `C:\Users\nDP\Desktop\ACC1240138_private\__andres_control\pseudopanel_deaton_fase1.ipynb`
- `C:\Users\nDP\Desktop\ACC1240138_private\__andres_control\pseudopanel_deaton_handoff.md`
- `C:\Users\nDP\Desktop\ACC1240138_private\__andres_control\pseudopanel_divergencias_expand_pif.md`
- `C:\Users\nDP\Desktop\ACC1240138_private\__andres_control\pseudopanel_decisiones_metodologicas.md`
- `C:\Users\nDP\Desktop\ACC1240138_private\__enpg\_codex_temp_audit_enpg\audit_gap.R` (baterias de dependencia ya validadas)
- `C:\Users\nDP\Desktop\ACC1240138_private\__andres_control\build_enpg_design_waves_2012_2024_list.R` (specs autoritativas de `expand_pif`)

### Proximas acciones

1. Convertir el control del workbook en chunk del notebook, como asercion que corre sola y falla si alguien rompe el mapeo. Es el control externo mas fuerte que hay.
2. Cambiar la base analitica del notebook a lo ya decidido y dejar el control en 12-64 en paralelo.
3. Investigar el quiebre de 2018: condicionar en el item de autoaplicacion (`SA_1`, existe hasta 2018) y ver si la razon DSM/AUDIT se estabiliza.
4. Revisar la anomalia de mujeres 2020.
5. Confirmar redaccion de los items AUDIT 1 y 2 en las 7 olas.
6. Decidir alcance del articulo; recien ahi congelar protocolo, ejecutar el notebook completo con log, manifiesto SHA-256 y `sessionInfo()`.

---

## CAVEMAN HANDOFF - 2026-08-06 13:42

### Decisiones tomadas

- **CP validado y adoptado**: consumo problematico de cocainas = uso ultimo ano de cocaina o pasta base Y (dependencia CIE-10 >=3 de 6 criterios colapsados de los 10 items, O >=1 de los 4 items de abuso DSM-IV), por sustancia. Colapso tomado de `audit_gap.R`, no reconstruido.
- **"OP = otras sustancias" NO se puede construir.** Tranquilizantes, analgesicos, inhalables, alucinogenos y el resto **no tienen bateria de abuso ni de dependencia en ninguna ola**. Las unicas sustancias con bateria son alcohol (solo abuso), marihuana, cocaina y pasta base. El eje OP pasa a ser **MP = marihuana problematica** o desaparece.
- **CP no puede ser desenlace de celda.** Se usa `C_use` (uso ultimo ano de cocainas) como C del test de compatibilidad, y CP queda como descriptivo nacional.
- Tratamiento: `TRATA_2==1` es recibido ultimo ano; `TRATA_4 in {1,2,3}` es **necesidad sentida**, no deseo; `TRATA_5` es intento. 2012 usa `p145` (recibido+tipo) y `p146` (intento).

### Evidencia actual / mejor resultado

- **VALIDACION EXACTA de CP contra el workbook, fila "Drogas"** (problematico entre usuarios ultimo ano de mar/coc/pb, 12-64): 2012 201.226,4 / 2014 268.990,7 / 2016 337.489,3 / 2018 378.718,8 / 2020 331.172,9. **Diferencia 0,0000% en las cinco olas.** Junto con la validacion previa de la fila Alcohol, quedan validadas las dos baterias.
- **RAZON DSM/AUDIT-C POR ANO Y SEXO** (entre bebedores ultimo ano, 15-65). El quiebre de 2018 es **fenomeno masculino**:

| ano | Hombre razon | Hombre P(DSM\|AUD+) | Mujer razon | Mujer P(DSM\|AUD+) |
|---|---|---|---|---|
| 2012 | 0,3468 | 27,31 | 0,1579 | 11,69 |
| 2014 | 0,3481 | 25,74 | 0,2578 | 20,59 |
| 2016 | 0,3950 | 28,63 | 0,1652 | 12,45 |
| 2018 | 0,2547 | 19,81 | 0,1590 | 9,42 |
| 2020 | 0,3022 | 20,40 | **0,0757** | **4,96** |
| 2022 | 0,2956 | 20,74 | 0,1688 | 9,28 |
| 2024 | 0,2638 | 18,17 | 0,1610 | 8,78 |

  En hombres hay escalon limpio y persistente: 0,35-0,40 hasta 2016, luego 0,25-0,30. En mujeres la serie es ruidosa de punta a punta, con 2014 alto y 2020 bajo como outliers opuestos; **no hay escalon interpretable en mujeres**.
- **El espacio de 8 estados AP x CP x MP ES disyuntivo y exhaustivo** (verificado: particiona los 124.104 casos). Pero cuatro de los ocho estados son inestimables.
- **Conteos no ponderados por ola (15-65)**: AP_solo 369-661 | CP_solo 13-31 | MP_solo 104-227 | AP&CP 19-29 | AP&MP 73-124 | CP&MP 4-13 | AP&CP&MP 11-42 | ninguno 15.354-18.310.
- **CP total en las 7 olas = 558 personas (0,450%)**. Por ola: 77, 103, 64, 101, 65, 70, 78.
- **Factibilidad de CP por agregacion** (mediana de casos por celda / % celdas <20):
  - cohorte10 x sexo x ola (84 celdas): **4 / 91,7%** -> inviable
  - cohorte20 x sexo x ola (52): **4,5 / 76,9%** -> inviable
  - cohorte10 x ola, sexos juntos (42): 13 / 76,2% -> inviable
  - **sexo x ola (14): 36 / 35,7%, min 12 -> unico nivel que lo sostiene**, pero sin dimension de cohorte
  - ola sola (7): 77 / 0% -> descriptivo nacional
- Colapso 2x2 AP x CP por ola: CP_sin_AP 19-44 y AP_y_CP 38-68 **a nivel nacional**. En celdas: mediana 1 y 2. El colapso no salva nada.
- **Tratamiento, prevalencias no condicionales 15-65**: recibido ultimo ano 0,37-0,78% (n=52-126 por ola); necesidad sentida 0,73-1,07%; intento 0,23-0,48%. Modulo aplicado a **toda la muestra**, sin filtro por consumo.
- Denominadores del workbook confirmados por back-solve, razon 1,000000: tratados es sobre problematicos; "desearon" sobre problematicos no tratados; "intentaron" sobre problematicos no tratados que desearon.

### Bugs y problemas abiertos

- **`TRATA_4` es NECESIDAD SENTIDA, no deseo.** El workbook lo rotula "Personas que desearon Tratarse". La pregunta dice "¿Ha sentido la necesidad de recibir algun tipo de tratamiento?". No son lo mismo.
- **2012 NO tiene variable de necesidad/deseo.** El workbook rellena esa fila copiando los porcentajes de `p146` (intento) y deja las N vacias. Cualquier serie 2012-2020 de "desearon tratarse" compara una tasa de intento contra una de necesidad.
- **`TRATA_4` se pregunta solo a los NO tratados en el ultimo ano.** Tratado y necesidad son mutuamente excluyentes por diseno: se pueden sumar, nunca intersectar.
- **`TRATA_2` se pregunta solo a `TRATA_1==1`** (tratamiento alguna vez). Quien recibio tratamiento el ultimo ano pero respondio mal el item de vida queda excluido por estructura.
- **Anomalia de peso 2014**: la N ponderada de tratados es MAYOR en 15-65 (53.737) que en 12-64 (43.883) pese a tener un caso menos. Al menos un tratado de 65 anos carga un peso anomalo. Revisar antes de publicar cifras 2014.
- 2014 tiene 95 casos con `trata1==99` que se propagan a NA; el denominador de necesidad es 19.927, no 20.022.
- `TRATA_6_*` (razones para no buscar ayuda) existe solo en 2016 y 2018.
- El workbook no tiene hojas 2022 ni 2024: esas dos olas siguen sin validacion externa.
- Sigue sin explicarse la razon DSM/AUDIT de mujeres en 2020 (0,0757).
- Sigue sin explicarse el quiebre masculino de 2018.

### Archivos a revisar (rutas exactas)

- `C:\Users\nDP\Desktop\ACC1240138_private\__enpg\_codex_temp_audit_enpg\audit_gap.R` (mapa de items dep/abuso por ola, ya validado)
- `C:\Users\nDP\Desktop\ACC1240138_private\__enpg\consumo problematico enpg 2020.xlsx` (bloques: r14-16 problematico, r21-26 tratados, r30-35 desearon, r39-44 intentaron)
- `C:\Users\nDP\Desktop\ACC1240138_private\__andres_control\pseudopanel_deaton_fase1.ipynb`
- `C:\Users\nDP\Desktop\ACC1240138_private\__andres_control\pseudopanel_decisiones_metodologicas.md`

### Proximas acciones

1. Renombrar el espacio de estados: AP/CP/MP como marginales, y los 8 cruces con nombre explicito de "solo". Eliminar "ABS": el estado bajo es "sin consumo problematico medido", incluye no consumidores.
2. Reemplazar C del test de compatibilidad por `C_use` (uso ultimo ano de cocainas, mediana 8 por celda) y dejar CP como descriptivo nacional y por sexo x ola.
3. Incorporar al notebook: CP, MP, los 8 estados, las tres variables de tratamiento, y el control del workbook como asercion.
4. Decidir si MP entra como eje o como covariable.
5. Revisar la anomalia de peso 2014 y el outlier de mujeres 2020.

---

## CAVEMAN HANDOFF - 2026-08-06 15:20

### Decisiones tomadas

- **OP eliminado.** No hay bateria de abuso ni dependencia para tranquilizantes, analgesicos ni el resto en ninguna ola. El eje no existe y se cierra.
- **El desenlace es CP, no el uso.** Decision del investigador: interesa consumo problematico/dependencia de cocainas, no el consumo. Se descarta mi propuesta de usar `C_use` como C del test.
- **ABS se reformula y sale del foco.** El estado "sin consumo problematico medido" incluye a no consumidores y a consumidores sin sintomas, y no es informativo para la pregunta. Deja de ser un estado del modelo y pasa a ser el complemento del denominador.
- **MP en revision.** Se puede eliminar para simplificar; queda abierto si aporta como dinamica etaria propia de marihuana.
- **Tratamiento: se replica el criterio del workbook** (condicional a consumo problematico), documentando los problemas de comparabilidad.
- El universo de analisis pasa a ser **las personas con algun consumo problematico** (n=6.012, 4,84%), no la poblacion total.

### Evidencia actual / mejor resultado

- **CORRECCION MAYOR a §7.3.** Mi lectura previa ("solo 23% de los bebedores problematicos mayores uso cocainas, el mecanismo no carga") **era erronea por falta de comparador**. Con el contrafactual, **los diez estratos edad x sexo muestran enriquecimiento**, RP de 3 a 20:
  - hombres 55-65: 24,2% (AP) vs 6,1% (no-AP), RP 3,99
  - mujeres 55-65: 17,5% vs 0,9%, **RP 20,26**
  - maximo en hombres 25-34 RP 3,85 y mujeres 15-24 RP 12,89
- **Orden temporal individual verificado**: entre AP con historia de cocainas, inicio mediano de cocainas a los **20**, edad actual mediana **34**, y **80,2% inicio al menos 5 anos antes** de la entrevista.
- **CP SI es estimable, pero no en celdas de cohorte.** Precision basada en diseno (IC logit):
  - por ola: 0,48-0,74%, 64-103 eventos, **RSE 16-24%** -> usable
  - por sexo (7 olas): hombres 0,955% RSE 7%; mujeres 0,227% RSE 17% -> usable
  - ola x sexo: hombres RSE 19-22% usable; **mujeres RSE 34-54% NO usable**
  - **por tramo etario (7 olas): 15-24 0,491% | 25-34 0,952% | 35-44 0,822% | 45-54 0,533% | 55-65 0,147%, RSE 11-26%, todos usables**
  - cohorte10 x sexo x ola: mediana 4 eventos, 92% de celdas <20 -> **inviable**
- **El gradiente etario de CP existe y es fuerte**: U invertida con maximo en 25-34 y caida de **seis veces** hasta 55-65. Es la mitad de la hipotesis y es estimable.
- **Composicion entre quienes tienen algun consumo problematico** (ponderado):
  - solo AP: 62,6% (2012) -> 44,8% (2024), **baja**
  - solo MP: 14,4% -> 32,3%, **sube**
  - CP con AP: 8,5% -> 5,1% | CP sin AP: 3,8% -> 5,5%
  - Denominador por celda cohorte10 x sexo x ola: mediana 57, min 1, 33% <30
- **La composicion se desplaza hacia marihuana, no hacia alcohol.** Es contrario a la hipotesis leida como participacion relativa.

### Bugs y problemas abiertos

- Con CP como desenlace obligatorio, **el pseudo-panel clasico de Deaton queda descartado**: 558 eventos en 7 olas, mediana 4 por celda.
- Mujeres: CP no es estimable a nivel ola x sexo (RSE 34-54%). Cualquier contraste por sexo y ola en mujeres es ruido.
- La composicion hacia marihuana puede ser artefacto: coincide con la abolicion de la autoaplicacion, que baja el reporte de marihuana por factor 1,57.
- Sigue el quiebre masculino de 2018 sin explicacion.
- Sigue el outlier de mujeres 2020 (razon DSM/AUDIT 0,076).
- Anomalia de peso 2014 sin revisar.
- Arquitectura del estudio en elaboracion por panel de diseno; pendiente de integrar.

### Archivos a revisar (rutas exactas)

- `C:\Users\nDP\Desktop\ACC1240138_private\__andres_control\pseudopanel_deaton_handoff.md` (§7.3 lleva la correccion marcada)
- `C:\Users\nDP\Desktop\ACC1240138_private\__andres_control\pseudopanel_decisiones_metodologicas.md`
- `C:\Users\nDP\Desktop\ACC1240138_private\__enpg\_codex_temp_audit_enpg\audit_gap.R`
- `C:\Users\nDP\Desktop\ACC1240138_private\__enpg\consumo problematico enpg 2020.xlsx`

### Proximas acciones

1. Integrar la arquitectura del panel de diseno y fijar estimandos.
2. Incorporar al notebook CP, MP, los estados, tratamiento y el control del workbook como asercion.
3. Decidir MP: eje propio o fuera.
4. Testear si la subida de marihuana en la composicion sobrevive al condicionamiento por modo de aplicacion (`SA_1`, existe hasta 2018).
5. Revisar peso 2014 y outlier mujeres 2020.


---

## 17. La prueba de coherencia, en seis especificaciones, y la escalera dosis-respuesta (2026-08-06)

Ejecutado en `scratchpad/coherence.R` y `scratchpad/coh2.R` sobre las siete olas 2012–2024, 15–65 años, diseño complejo (estrato = ola×región, UPM = comuna+manzana, comuna sola en 2020, `survey.lonely.psu="adjust"`). Todo ponderado, con errores estándar basados en diseño.

### 17.1 Hallazgo previo que cambia la pregunta: "problemático alguna vez" NO es medible

Pediste añadir al gradiente la categoría *"consumo problemático/dependencia de cocaínas alguna vez en la vida"*, con su desdoble *"alguna vez pero no en el último año"*. **No se puede construir.** Verificado ítem por ítem en 2016, 2018 y 2024: no existe ningún ítem de dependencia o abuso con marco temporal de vida en ninguna ola (`<NINGUNO>` en las tres búsquedas). Todas las baterías están enmarcadas a doce meses y, además, sólo se aplican a quienes declararon consumo en el último año. El enunciado literal de 2018 lo confirma: *"Piense en los últimos 12 meses ¿Ha sentido un deseo tan grande de usar marihuana…"*.

Consecuencia: **el estatus problemático sólo existe en presente**. Una persona que fue dependiente de cocaína a los 25 y hoy no consume aparece en los datos como "ex consumidor", indistinguible de quien probó tres veces. Esa es una limitación estructural del instrumento, no una decisión de diseño, y es probablemente la restricción más severa de todo el estudio: **la variable que la hipótesis clínica necesita en la historia es justamente la que la encuesta nunca midió**.

Lo que sí se puede armar es una escalera anclada en la **historia de uso** más el **estatus problemático actual**.

### 17.2 La escalera dosis-respuesta: monótona y fuerte

Desenlace: AP (abuso de alcohol DSM-IV, últimos 12 meses).

| Peldaño | n | eventos | Pr(AP) | IC 95% |
|---|---|---|---|---|
| E0 nunca usó cocaínas | 117.904 | 3.162 | **3,00%** | 2,79–3,23 |
| E1 usó, **no** en el último año | 5.027 | 843 | **15,96%** | 14,21–17,87 |
| E2 usó el último año, sin criterio problemático | 615 | 185 | **27,51%** | 22,05–33,72 |
| E3 CP actual (problemático/dependencia cocaínas o PBC) | 558 | 340 | **59,48%** | 53,05–65,60 |

Ajustado por edad (spline natural, 4 gl), sexo y ola, con RP de Poisson robusto y referencia E0: **E1 4,11 [3,57–4,73] · E2 5,82 [4,58–7,39] · E3 13,39 [11,68–15,36]**.

Por sexo el orden se conserva íntegro (H 4,72 / 17,27 / 26,75 / 60,35; M 1,45 / 11,50 / 31,43 / 55,91). En mujeres E2 y E3 se cruzan pero con n = 137 y 115, dentro del ruido.

**El gradiente sobrevive dentro de cada tramo etario** (sección C de `coh2.R`): en 15–24 va 4,07 → 26,64 → 34,13 → 72,82; en 45–54 va 2,36 → 11,06 → 30,66 → 37,22. No es un artefacto de que los expuestos sean más jóvenes.

El peldaño que importa para tu pregunta clínica es **E1**: gente que **ya no consume cocaínas** y aun así tiene cuatro veces más abuso de alcohol que quien nunca consumió, ajustando por edad. Ése es el sustrato empírico del mecanismo que propones. Existe, es grande y es robusto.

### 17.3 La prueba de coherencia: la hipótesis dinámica se cae, y se cae seis veces

La predicción propia de la hipótesis de desplazamiento es que los síntomas **migran con el tiempo**: cuanto más tiempo ha pasado desde el inicio del consumo de cocaínas, más se habrá desplazado el cuadro hacia alcohol. Formalmente, Pr(AP) debería ser función de D = edad − inicio, y por tanto **β_edad + β_inicio = 0**. Población: 5.946 expuestos con inicio válido y D > 0; 1.299 eventos AP.

| Espec. | Qué hace | Resultado |
|---|---|---|
| **1** | Restricción lineal β_edad + β_inicio = 0 | β_edad = −0,0336 (p<0,001); **β_inicio = −0,0021 (p = 0,817)**; suma = −0,0357, z = −4,53, **p < 0,001 → rechazada**. H (−0,0359 / +0,0057, p suma = 0,001); M (−0,0225 / −0,0423, p suma = 0,001) |
| **2** | Wald de diseño sobre splines y AIC | edad p < 0,0001; **inicio p = 0,966**. AIC: **sólo edad 5.877,3** < completo 5.890,2 < sólo duración 5.922,8 < sólo inicio 5.991,3 |
| **3** | Contrastes de margen a 15 años | Envejecer 15 años con inicio fijo: **−8,24 pp** (H). Iniciar 15 años antes a edad fija: **+0,43 pp**. C = −8,68 pp |
| **4** | No paramétrica, edad × inicio | Las **filas** (edad) se ordenan 30 → 24 → 18 → 17; las **columnas** (inicio) no se ordenan; la diagonal no muestra nada |
| **5** | Inicio dentro de bandas estrechas de edad | β_inicio = +0,005 / −0,011 / +0,012 / −0,020; **p = 0,87 / 0,59 / 0,52 / 0,17**. Ninguno se acerca al +0,034 que exige la duración |
| **6** | Edad dentro de bandas estrechas de inicio | β_edad = −0,027 / −0,035 / −0,035 / −0,028, **todos significativos**. Notablemente estable |
| **7** | Sólo ex consumidores (E1), donde el desplazamiento debería ser máximo | n = 4.865, ev = 810. β_edad = −0,036 (p<0,001); **β_inicio = +0,009 (p = 0,43)**; suma p = 0,002 |

**No es falta de potencia.** En hombres, β_inicio = +0,0057 con ee = 0,0101, IC 95% [−0,014; +0,026]. El valor que la hipótesis de duración exige es +0,0359: queda **3,0 errores estándar fuera** del intervalo. Está excluido, no simplemente no detectado.

**Y el resultado A es peor todavía para la hipótesis.** La interacción edad × expuesto es **−0,0138 (p = 0,015)**: el abuso de alcohol cae con la edad *más rápido* entre quienes tienen historia de cocaínas (−0,034/año) que entre quienes no (−0,020/año). Si hubiera desplazamiento, los expuestos deberían caer **más lento** o subir, porque estarían adquiriendo problemas de alcohol conforme abandonan la cocaína. Caen más rápido.

**Lectura:** existe un solo reloj y es la **edad alcanzada**, no el tiempo transcurrido desde el inicio. Lo que se observa es **desistimiento general**, más pronunciado en los expuestos, no sustitución de sustancia.

### 17.4 La única evidencia a favor, y por qué no vale

Entre quienes tienen **algún** problema, la fracción "sólo alcohol" sube monótonamente con la edad (hombres 33,8 → 39,1 → 61,5 → 70,4 → **85,6%**; mujeres 45,0 → 50,7 → 49,8 → 63,3 → **81,5%**) y "sólo droga" cae de 40,5% a 5,3% en hombres. Visto así, el desplazamiento parece evidente.

**No lo es.** Es aritmética. Si CP cae seis veces entre 25–34 y 55–65 (0,952% → 0,147%) y AP cae menos, la participación del alcohol sube **por construcción**, aunque el desplazamiento individual sea exactamente cero. Ésta es la objeción de Codex sobre niveles absolutos versus proporciones, y aquí se materializa en el sentido más peligroso: **la composición es el único corte donde la hipótesis "gana", y es justo el corte que no puede distinguirla de la nada**. Regla que queda fijada: la composición entre problemáticos se reporta como descripción, nunca como evidencia del mecanismo.

### 17.5 Estilo de respuesta y responsabilidad común

Si la escalera fuera sólo aquiescencia (quien endosa síntomas los endosa en todas las baterías), CP y MP darían saltos iguales. No los dan (**RP bruta CP 15,4 vs MP 11,4**), así que aquiescencia pura queda descartada. Pero **son del mismo orden**, y eso apunta a una **dimensión general de gravedad/responsabilidad común**: cualquier consumo problemático, de cocaína o de marihuana, viene acompañado de un RP de once a quince veces en alcohol. Esa es la firma de responsabilidad común, no la de un desplazamiento específico de cocaína a alcohol.

### 17.6 Marihuana como control activo: veredicto negativo, por dos razones distintas

Preguntaste si los problemas propios de la marihuana (percepción de riesgo, uso analgésico/medicinal en edades mayores) alcanzan a invalidarla como control activo. Respuesta: sí, pero la razón decisiva resultó ser otra.

**Razón 1 — lo que temías, verificado y peor de lo esperado.** El **uso medicinal de marihuana no está medido en ninguna ola**. Búsqueda literal en 2016, 2018 y 2024: `<NINGUNA>` coincidencia. Lo único cercano es `T_OP_4_3` en 2018, *"Permitir el uso de marihuana para fines terapéuticos"*, que es un ítem de **opinión**, no de uso propio. El canal analgésico/medicinal es por tanto **inobservable**: no se puede ajustar, no se puede testear, sólo se puede declarar. La percepción de riesgo **sí** existe (batería `PR_1`, p. ej. `T_PR_1_5` en 2024), pero ajustar por ella es peligroso porque es plausiblemente **consecuencia** del consumo, no antecedente: sería un colisionador/mediador. A lo más, análisis de sensibilidad.

**Razón 2 — la decisiva, que no habíamos anticipado.** La marihuana **no se comporta como control** porque su firma es distinta, no nula. Misma prueba, n = 32.712, 3.076 eventos: **β_edad = −0,0176 (p<0,001) y β_inicio = −0,0677 (p<0,001)**. Ambos negativos, y el de inicio casi cuatro veces mayor. Es decir: a igual edad y misma ola, **iniciar marihuana más temprano predice mucho más abuso de alcohol**, que es la firma clásica de **inicio precoz / responsabilidad común**. En cocaínas ese coeficiente es cero.

Un control negativo tiene que ser nulo y no lo es; un control positivo tendría que reproducir la firma de la exposición de interés y tampoco lo hace. **Recomendación: degradar la marihuana de "control activo" a "segunda exposición", reportada de forma simétrica.** Su valor está precisamente en el contraste de firmas — cocaína sin efecto de inicio, marihuana con un efecto de inicio grande —, y ese contraste es más interesante que el papel de control que se le había asignado. La escalera análoga en marihuana también es monótona pero más plana (M1 ex 5,47% · M2 uso actual sin problema 11,01% · M3 MP actual 37,34%).

Nota de identificación que sostiene todo lo anterior: con edad y **efectos fijos de ola** en el modelo, la cohorte queda absorbida (cohorte ≡ ola − edad), de modo que β_inicio se identifica con variación de edad de inicio **dentro** de celdas edad×ola. El inicio no es una recodificación de la cohorte. Éste es el argumento del inicio como cuarta coordenada temporal, y aquí opera.

### 17.7 La amenaza que sí podría explicar el nulo, y que no puedo descartar

**Sesgo de supervivencia diferencial por edad de inicio (A-serie).** Para ser observado a la edad *a* con inicio en *O*, hay que haber sobrevivido y ser captado en un hogar. Los de inicio precoz en cocaínas tienen mortalidad e institucionalización más altas, de modo que los que quedan en la muestra son los más sanos de su grupo. Eso **atenúa β_inicio hacia cero**, que es exactamente el resultado observado. No puedo distinguir "el inicio no importa" de "los que iniciaron temprano y siguieron mal ya no están en la encuesta".

No es descartable con los datos de la encuesta. Sí es acotable con los datos de mortalidad del propio proyecto: la cadena `expand_pif*` entrega mortalidad atribuible a alcohol por edad y sexo, y con eso se puede montar una reponderación de supervivencia o un análisis de sesgo cuantitativo. **Es la conexión natural entre las dos mitades de la tesis y queda como trabajo pendiente prioritario.** Mientras no esté hecho, el nulo de β_inicio se reporta como *"no se observa efecto de la edad de inicio, con la salvedad de que la supervivencia diferencial atenúa este coeficiente en dirección desconocida pero probablemente hacia cero"*.

### 17.8 Qué queda en pie de la hipótesis

Sobrevive, y es publicable:
1. **Enriquecimiento residual en ex consumidores.** E1 tiene RP 4,11 ajustado. Quien dejó las cocaínas conserva un exceso grande de abuso de alcohol.
2. **Gradiente dosis-respuesta monótono y estable dentro de cada edad.**
3. **Desistimiento más rápido, no más lento, entre expuestos** (interacción −0,0138).

No sobrevive:
4. **La versión dinámica**: que el desplazamiento se acumule con el tiempo desde el inicio. Rechazada en seis especificaciones independientes, con el valor predicho fuera del IC.
5. **La lectura composicional** como evidencia: es aritmética de denominadores.

El estudio cambia de signo pero no de valor: pasa de *"documentamos un desplazamiento"* a *"sometimos el desplazamiento a su propia predicción temporal y la encuesta no la sostiene; lo que hay es un exceso residual estable compatible con responsabilidad común"*. Es un resultado negativo bien diseñado, con un contraste de firmas entre sustancias, y eso es más defendible ante revisores que la versión afirmativa.

### 17.9 Preguntas abiertas para Codex

1. **¿Existe alguna batería de síntomas con marco de vida en alguna ola que yo no haya encontrado?** Busqué por etiqueta en 2016/2018/2024 y salió `<NINGUNO>`. Las etiquetas de Stata se truncan a 80 caracteres y ya me hizo fallar una detección antes (educación 2018, percepción de riesgo). ¿Conviene buscar por estructura de bloque en vez de por etiqueta?
2. **¿Hay ítem de edad de término/último consumo de cocaínas**, no sólo recencia categórica? Con eso el intervalo de exposición sería un segmento y no una semirrecta, y la prueba de coherencia ganaría muchísimo poder.
3. **¿Tabaco tiene batería de dependencia y edad de inicio en estas olas?** Sería un tercer control con mortalidad alta pero sin la connotación de ilegalidad, útil para separar responsabilidad común de efecto de sustancia.
4. **Sobre el ajuste por percepción de riesgo (`PR_1`)**: ¿es defendible como sensibilidad o es directamente colisionador y conviene no tocarlo?
5. **Sobre el sesgo de supervivencia**: ¿la reponderación por mortalidad atribuible de `expand_pif*` es viable con la granularidad disponible (edad×sexo×año), o hace falta algo por causa específica?
6. **¿La interacción edad × expuesto (−0,0138) puede ser piso por el efecto techo de AP en los jóvenes expuestos** (26–34% en E1/E2 a los 15–24), en vez de desistimiento genuino? No lo tengo resuelto.

---

## CAVEMAN HANDOFF - 2026-08-06 13:58

### Decisiones tomadas
- Escalera dosis-respuesta se ancla en E0/E1/E2/E3 (nunca / ex / uso actual sin problema / CP actual). La categoría que pediste, "problemático alguna vez", **no existe en los datos**.
- Marihuana **degradada** de control activo a segunda exposición reportada en paralelo.
- Composición entre problemáticos = descriptivo, **nunca** evidencia de mecanismo.
- Objeto del artículo pasa a falsación diseñada de la versión dinámica de la hipótesis.

### Evidencia actual / mejor resultado
- Escalera AP: 3,00 / 15,96 / 27,51 / 59,48%. RP ajustada 4,11 / 5,82 / 13,39. Sobrevive dentro de cada tramo etario.
- Prueba de coherencia: β_inicio = −0,002 (p = 0,82) vs β_edad = −0,034 (p<0,001). Restricción de duración rechazada (p<0,001) en 6 especificaciones. Valor exigido +0,036 está a 3,0 ee del IC → no es falta de potencia.
- Interacción edad × expuesto = −0,0138 (p = 0,015): los expuestos desisten **más rápido**.
- Marihuana: β_inicio = −0,068 (p<0,001), firma de inicio precoz, opuesta a cocaínas.
- Uso medicinal de marihuana: `<NINGUNA>` en todas las olas revisadas. Inobservable.

### Bugs y problemas abiertos
- Sesgo de supervivencia diferencial por edad de inicio atenúa β_inicio hacia cero. **No descartado.** Es la explicación alternativa más fuerte del nulo.
- Efecto techo posible en la interacción edad × expuesto.
- E2/E3 en mujeres (n = 137/115) se cruzan; ruido.
- Celda 55–65 E3 tiene n = 31; el 73,2% no es interpretable.
- Percepción de riesgo `PR_1` no detectada por regex antes de 2024; truncamiento de etiquetas Stata a 80 caracteres.

### Archivos a revisar (rutas exactas)
- `C:\Users\nDP\Desktop\ACC1240138_private\__andres_control\pseudopanel_deaton_handoff.md` (§17, este bloque)
- `C:\Users\nDP\Desktop\ACC1240138_private\__andres_control\pseudopanel_arquitectura_estudio.md` (requiere reescritura de estimandos y de F1–F13)
- `C:\Users\nDP\Desktop\ACC1240138_private\__andres_control\pseudopanel_decisiones_metodologicas.md` (§10)
- `C:\Users\nDP\Desktop\ACC1240138_private\__andres_control\pseudopanel_deaton_fase1.ipynb` (faltan los chunks de escalera y coherencia)
- Scratchpad: `coherence.R`, `coh2.R`, `pool_coh.rds`

### Proximas acciones
1. Reescribir `pseudopanel_arquitectura_estudio.md`: el estudio es ahora una falsación, no una confirmación. Rehacer estimandos, F1–F13 y el título.
2. Portar escalera y prueba de coherencia al notebook como chunks con aserciones.
3. Montar el análisis de sesgo por supervivencia con la mortalidad de `expand_pif*`.
4. Resolver las 6 preguntas para Codex de §17.9.
