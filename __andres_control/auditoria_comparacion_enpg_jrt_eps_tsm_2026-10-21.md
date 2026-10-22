# Auditoría: qué se compara entre ENPG/JRT, EPS y TSM (21-10-2026)

Revisión de solo lectura del código ejecutado y de las salidas que alimentan la comparación de transiciones de consumo de alcohol. No se modificaron motores, notebooks ni resultados. Los conteos que no estaban en ninguna salida se obtuvieron con scripts R temporales fuera del repo (vía `acc_data()`, sin escribir en el repo) y van marcados **[conteo propio]**. Página explicativa: [auditoria_comparacion_enpg_jrt_eps_tsm_2026-10-21.html](auditoria_comparacion_enpg_jrt_eps_tsm_2026-10-21.html).

Abreviaturas de rutas: **FINAL** = `jrt/simulacion/Alcohol Transitions FINAL.R`; **CALIB** = `jrt/simulacion/Alcohol Transitions_CALIB.R`; **core** = `__andres_control/eps_markov_core.R`; **ts_data** / **ts_models** = `__andres_control/tsm_markov_data.R` / `tsm_markov_models.R`; **eps_out** = `__andres_control/eps_markov_outputs_v2/`; **ts_out** = `__andres_control/tsm_markov_outputs/`; **handoff** = `__andres_control/codex_handoff_adam_rr_full_override_caveman.md`.

## Resumen en cinco frases

1. JRT estima probabilidades **a dos años** con un pseudo-panel ENPG 2008–2016 hecho por rank matching (personas distintas en cada ola), sin pesos; su input de entrenamiento (`Alcohol Transitions FINAL.RData` / `ENPG_FULL.RDS`) **no está en el repo**, así que ningún N de entrenamiento es verificable.
2. EPS y TSM son **paneles reales** de 18–65 al inicio, con pesos (oficial × IPW), seis estados de origen (N0, FD, C1–C4) y cinco de destino, pero con intervalos de **3,7–4,0 años** (EPS) y **4–8 meses** (TSM); ninguno se convierte a dos años.
3. `JRT_reference` no es el modelo de JRT: reutiliza su fórmula (más `period`) y se ajusta sobre los paneles EPS o TSM con pesos.
4. El rank matching de EPS/TSM es un **diagnóstico** sobre las mismas personas del panel y muestra que el acoplamiento por rangos fabrica persistencia (C1→C1 EPS 94,0 % vs 58,3 % real en VI→VII).
5. La "versión atemperada" es J0 con sus probabilidades elevadas a α = 0,5 y renormalizadas en cada paso anual: no es un modelo distinto ni una anualización.

## 1. Fuentes, procedimientos y modelos

| Objeto | Qué es | Datos y etapa | Relación con los demás | Evidencia |
|---|---|---|---|---|
| ENPG | Encuesta transversal bienal (no panel). JRT usa 2008–2016 para entrenar y 2018–2022 como objetivos | 2008–2022, 12–65 en archivo | Fuente de datos | `_enpg/README.md` tabla de olas; FINAL:13-15 |
| Rank matching JRT | Pseudo-panel t→t+2 dentro de sexo × `agecat`: ordena por g/día y asigna a cada registro de t el de t+2 con rango cuantil más cercano; **con reemplazo**, empates al azar, sin pesos, mismo tramo de edad en ambas olas (no envejece cohortes) | pares 08→10, 10→12, 12→14, 14→16 | Construye los datos de J0 | FINAL:72-146 |
| J0, JRT original | `MASS::polr(state_t2 ~ state_t*agecat + state_t*sex + sex*agecat)`, sin pesos, sin HED, 4 estados | entrenamiento 2008–2016 | Modelo base | FINAL:152-170 |
| J0-α, "atemperada" | Mismas probabilidades de J0 transformadas `exp(α log p)/Σ`, α = 0,5, aplicadas cada año calendario | simulación 2008–2022 | **Deriva de J0** | FINAL:178-205, 292-321; `presentacion_micsim.qmd:274-278` |
| J0-cal | Mismos β de J0 con desplazamientos δ o κ ajustados por SSE de prevalencias | objetivos 2008–2022 (incluye años de entrenamiento) | **Deriva de J0**; el script no parsea | CALIB; `guion_reunion_ACC_2026-09-16_revision_critica.ipynb` celdas review-08, review-14 |
| JRT_reference | `polr(~ state0*age_group + state0*sex + sex*age_group + period)` ponderado, sobre **panel real** EPS o TSM | EPS VI→VII, VII→VIII; TSM R7→R11 | **Procedimiento distinto**: solo comparte la forma de la fórmula | core:247-248, 355, 363-365; ts_models:30-31, 157 |
| Rank matching EPS/TSM | Acople comonótono de los márgenes ponderados de categoría de **las mismas personas**, por sexo × edad; origen N0+FD → NC | EPS y TSM | **Procedimiento distinto** del RM de JRT; diagnóstico, no predice | core:682-707; ts_models:529-555 |
| A, Multinomial, Ordinal_single, Gamma, Lognormal, dos partes | Motores EPS/TSM ajustados con pesos `wn` | EPS, TSM | Ordinal_single y JRT_reference: mismo estimador, otra fórmula; Gamma/Lognormal/Ordinal_two_part comparten la parte de participación | core:347-359; ts_models:149-162 |

**Entrenamiento, calibración y evaluación.**

- JRT: entrena con 2008–2016 (FINAL:13, 132-134). La "calibración" de FINAL es una comparación visual con 2018–2022 (FINAL:336-387); CALIB usa 2008–2022, incluidos los años de entrenamiento (CALIB:11-22, 321). No hay evaluación independiente.
- EPS: k de A por CV interna (rejilla 10–1000, elegido 300); evaluación con CV de 5 pliegues × 3 por persona, contrastes con diseño, "transport" **entre periodos de la EPS** (forward/retro, k fijo = 100) y Chapman-Kolmogorov (core:400-475, 657-681, 748-768). Sin calibración a ENPG.
- TSM: igual estructura; "transport" es dejar un intervalo fuera **dentro de TSM** (ts_models:498-528). El único cruce entre fuentes es TSM↔EPS con el generador anual, presentado como consistencia externa (ts_models:627-692). Sin calibración a ENPG.
- El cuaderno `TSM_ENPG_v3_EN` **no lee datos ENPG**; el nombre es herencia de la v2 (`_tsm/notes/TSM_ENPG_v2_EN.md:2`).

## 2. Flujo de N

### ENPG para JRT (registros; los pares sintéticos = registros de la ola de origen tras filtros)

| Ola | N bruto | Edad en archivo | N 15+ | Filtros de JRT (orden) | N final | Rol |
|---|---:|---|---:|---|---|---|
| 2008 | 17.113 | 12–65 | 16.422 [conteo propio] | 1) `edad>=15` (handoff:5217); 2) NA en año, sexo ("Hombre"/"Mujer"), `edad_tramo`, `volajohdia`, estado (FINAL:37-66); cat4 y `cur_na` → NA y fuera (FINAL:17-26); sin control de duplicados | PENDIENTE | origen 08→10 |
| 2010 | 15.576 | 12–64 | 14.794 [conteo propio] | ídem | PENDIENTE | destino y origen |
| 2012 | 17.154 | 12–65 | 16.322 | ídem | PENDIENTE | destino y origen |
| 2014 | 20.113 | 12–65 | 19.326 | ídem | PENDIENTE | destino y origen |
| 2016 | 19.147 | 12–65 | 18.354 | ídem | PENDIENTE | solo destino |
| 2018–2022 | 19.427 / 16.662 / 17.454 | 12–65 | 18.734 / 16.114 / 17.023 | — | PENDIENTE | objetivos de prevalencia |

Fuentes: N bruto `_enpg/notes/enpg_wave_inventory.csv:2-9`; 15+ de 2012 en adelante `__andres_control/microsim_base_outputs/data_audit.csv:2-7`. Dominio etario de JRT: **15–65** (15–64 en 2010). Pesos (`exp`, renombrado por ola; handoff:5206-5215) solo se usan en las prevalencias observadas, no en el rank matching ni en `polr`. El N por motivo de exclusión y el N final son PENDIENTES porque falta el `.RData`.

### EPS (panel real; pares = personas en cada intervalo)

| Paso | VI→VII | VII→VIII | Evidencia |
|---|---:|---:|---|
| Registros vivos en origen | 16.906 | 7.800 | eps_out/harmonization_audit.csv |
| Con peso panel 2015 (solo VI→VII) | 6.284 | — | `eps_alcohol_outputs/panel_audit.csv`; core:143-146 |
| 18–65 y sexo conocido | 5.252 | 6.107 | core:141; eps_out/v2_attrition_table.csv |
| Muertes en destino | 0 | −60 → 6.047 | core:147-148 |
| Origen sin clasificar | −153 → 5.099 | −350 → 5.697 | eps_out/cohort.csv |
| Enlace inválido o destino sin clasificar | −397 | −2.304 | core:149-151 (mismo id, sexo, Δedad 3–5) |
| **Pares completos** | **4.702** | **3.393** | eps_out/cohort.csv |
| ESS (IPW v1) | 3.154 | 1.938 | eps_out/v2_scheme_weights_audit.csv |

Total 8.095 pares de 5.365 personas (2.730 con ambos). PENDIENTE: desglose edad vs sexo en el paso 18–65 y enlace vs ítem en las pérdidas.

### TSM (panel real; pares de entrevistados `Entrevistado==1`)

| Paso | R7→R8 | R8→R9 | R9→R10 | R10→R11 | Evidencia |
|---|---:|---:|---:|---:|---|
| Meses | 8 | 4 | 7 | 5 | ts_data:19-29 |
| Entrevistados en origen | 3.012 | 2.040 | 3.056 | 2.430 | ts_out/input_manifest.csv |
| Excluidos >65 [conteo propio] | 889 | 635 | 919 | 758 | ts_data:201 |
| 18–65 | 2.123 | 1.405 | 2.137 | 1.672 | ts_out/harmonization_audit.csv |
| Sin destino | 1.122 | 498 | 853 | 689 | ts_out/link_audit.csv |
| Incompatibles (sexo; edad fuera de [−1, 2]) | 0; 5 | 0; 6 | 0; 30 | 1; 12 | ts_data:203 |
| **Pares usados** | **996** | **901** | **1.254** | **970** | ts_out/cohort.csv |
| ESS | 359 | 264 | 448 | 336 | ts_out/link_audit.csv |

Total 4.121 pares de 1.915 personas. Sin faltantes por construcción (`stopifnot`, ts_data:119-121). Mujeres 65,8 % de los pares sin ponderar; proporción ponderada PENDIENTE.

## 3. Estados

| | ENPG / JRT | EPS | TSM |
|---|---|---|---|
| Ítems | uso alguna vez, último uso, `oh3` días en 30 días, `audit2` tragos, `db` episodios (`expand_pif.ipynb`, celda enpg-consolidate) | `f13` bebe (sin ventana), `f14` días/semana último mes, `f15` vasos por ocasión | `e3a1` frecuencia, `e3a2` tragos día típico, `e3a3` 6+ tragos (sin ventana) |
| g/día | `(db×5|4 + max(oh3−db,0)×punto medio audit2)×12 g`, 30 días → año, × factor APC OMS, /365 | Σ bebidas 12·días·vasos/7; "menos de 1 día" = 0,5 (prevalencia notebook, celda 9) | 12·días/sem·tragos/7 con puntos de banda; máx. 94,3 g/día: **C4 inalcanzable** (ts_data:147-153) |
| No consumo | ltabs = nunca; fd = no bebió en **30 días** (incluye >1 año) | N0 = no bebe y sin consumo previo observado; FD = no bebe y bebió en una ola anterior (**años**) (core:118-135) | igual regla por cadena de rondas; FD bebió hace **4–24 meses** (ts_data:177-195) |
| Estados del modelo | Non-drinker (ltabs+fd), Cat1–Cat3; **sin Cat4** (FINAL:12, 17-26) | origen N0, FD, C1–C4; destino NC, C1–C4 (core:171) | igual que EPS (ts_data:223) |
| Cortes | M 20/40/100, H 40/60/100 (celda enpg-consolidate L106-118) | M 20/40/100, H 40/60/100 (core:48-54) | igual (ts_data:73-79) |
| HED | 5+/4+ en 30 días; no entra en `polr` | no existe; solo señal auxiliar | `e3a3`, solo en IPW y variante extras |
| Edad | 15–29, 30–44, 45–59, 60–65 | 18–29, 30–44, 45–59, 60–65 | igual que EPS |

**NC→NC.** En los tres, el destino no bebedor es la suma N0+FD. JRT mezcla ltabs y fd también en el origen, con la proporción de la ola t. EPS y TSM separan el origen y reasignan el destino NC a N0 si el origen es N0 y a FD en otro caso (core:482; ts_models:296); N0→FD y C→N0 son ceros estructurales. Mezcla de origen sin ponderar: EPS VI→VII todo N0 (2.936), VII→VIII N0 1.686 + FD 412 (eps_out/row_counts_state0_by_stratum.csv); TSM N0 1.592 + FD 431 (21,3 % FD, de 0 % en R7 a 32 % en R10). Mezclas ponderadas: PENDIENTE. Las filas NC del rank matching y de la proyección TSM→EPS mezclan ambos orígenes.

## 4. Comparabilidad

| Dimensión | JRT (J0 / J0-α) | EPS | TSM | ¿Comparable? |
|---|---|---|---|---|
| Unidad | registros transversales, pares sintéticos con reemplazo | personas reales enlazadas | personas reales enlazadas | No: el pseudo-panel no observa cambio individual |
| Edad al inicio | 15–65 | 18–65 (VII→VIII en la práctica 22–65) | 18–65 | Parcial: JRT incluye 15–17 |
| Intervalo | 2 años; aplicado cada año con α | 3,671 y 4,03 años | 0,33–0,67 años | No: sin conversión común a 2 años |
| Pesos | ninguno en el modelo | oficial × IPW | `Fact_Exp` × IPW | No |
| FD | 30 días sin beber | años sin beber | meses sin beber | No: constructos distintos (ts_models:684) |
| C4 | no existe | sí | inalcanzable | No |
| Estratos | celdas sexo × edad, sin envejecer en el RM; envejece 15 años por paso anual en la simulación (FINAL:270-285) | sexo × edad × periodo | sexo × edad × periodo | Parcial |

Las diferencias de persistencia entre JRT y EPS/TSM vienen sobre todo de **cómo se construyen los datos**, no del modelo: el rank matching fabrica persistencia (EPS C1→C1 94,0 % vs 58,3 %; TSM NC→NC 0,969 vs 0,764 en R7→R8; eps_out/rank_matching_vs_panel.csv, ts_out/rank_matching_vs_panel.csv), α = 0,5 la aplana en otra dirección, y los intervalos difieren. Las cifras agrupadas o del generador anual son globales: no deben citarse como si fueran específicas de un estrato; las matrices por estrato existen en eps_out/transition_matrices_design_CI.csv y ts_out/transition_matrices_person_CI.csv.

## 5. Discrepancias entre documentos y código

1. `__andres_control/README.md` no existe.
2. `presentacion_micsim.qmd:219` llama a la ENPG "Encuesta Nacional de Presupuestos y Gastos" (es la EPF).
3. `presentacion_micsim.qmd:221` atribuye representatividad a los pesos; el modelo JRT no los usa.
4. `presentacion_micsim.qmd:307-309, 339` marca el modelo ordinal y la calibración como completos; FINAL no es reproducible (falta el `.RData`), CALIB no parsea y `apply_destination_offsets` no está definida (FINAL:201).
5. `TSM_ENPG_v3_EN.md:115, 131` llama a JRT_reference "the published JRT specification"; agrega `period`, pesos, seis orígenes, C4 y panel real.
6. `_enpg/README.md:38` atribuye `ENPG_BINGE.RDS` al pipeline JRT, pero cubre solo 2012–2024 y FINAL exige 2008 y 2010.
7. En el derivado actual `data_binge_sensitivity`, `volajohdia` es NA en todas las filas ltabs y fd [conteo propio]: con ese objeto, el filtro `!is.na(gpd)` de FINAL eliminaría a todos los no bebedores. Cómo estaba en el `.RData` de JRT: PENDIENTE.
8. `armonizacion_enpg_eps_2026_10_16.md:93, 97` propone FD a 12 meses y otros tramos de edad; el código usa 30 días (ENPG), historia de olas (EPS/TSM) y 18–29/30–44/45–59/60–65.
9. `eps_markov_v2_observaciones_2026-10-16.md:240` describe JRT como t→t+2 anualizado con α; α no es una anualización.
10. `eps_markov_v2_narrative.md:22` dice `log(g/día + 1)`; el código usa `log(g)` (core:168).
11. El transport EPS usa k = 100 fijo y el ajuste principal k = 300; las notas no lo dicen.
12. `_tsm/README.md:39` cita los N de v2 (4.175 / 1.934); v3 usa 4.121 / 1.915.
13. Peso ENPG 2014: el crosswalk dice `F2_MAY_AJUS_com`; JRT usa `RND_F2_MAY_AJUS_com` (redondeado).
14. Sexo: FINAL solo acepta "Hombre"/"Mujer"; los crudos 2010 y 2012 traen otras etiquetas. Si `ENPG_FULL` no las armonizó, esos registros se pierden: PENDIENTE.

## 6. Qué estamos estimando y qué es defendible

- **JRT** estima cómo cambia la *distribución* de consumo entre dos encuestas transversales a la misma edad, y la convierte en transiciones individuales por un supuesto de rangos. No mide transiciones individuales.
- **EPS y TSM** estiman transiciones individuales observadas en sus propios intervalos (≈4 años y meses), con pesos y en 18–65.
- **Defendible hoy:** comparar EPS y TSM con JRT_reference y los demás modelos *dentro de cada panel*; usar el rank matching como diagnóstico de cuánta persistencia fabrica el supuesto JRT; comparar márgenes (prevalencias) ENPG con los de la simulación.
- **No defendible:** comparar celda a celda las matrices JRT con EPS o TSM, o la fila FD, o C4, sin armonizar intervalo, edad, FD y pesos.
- **Falta corregir o confirmar:** recuperar `Alcohol Transitions FINAL.RData` o `ENPG_FULL.RDS` para fijar los N de JRT; un horizonte común (o comparar márgenes en vez de matrices); FD con una misma ventana; excluir 15–17 o justificarlo; las mezclas ponderadas N0/FD; renombrar o aclarar `TSM_ENPG` y "JRT_reference"; corregir las discrepancias de la sección 5.
