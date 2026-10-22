# ELSOC: tres escenarios de ponderación para las transiciones de consumo regular

[Cuaderno ejecutado](elsoc_weighting_scenarios_EN.ipynb) · [HTML autocontenido](../elsoc_weighting_scenarios_EN.html) · [Script de análisis](elsoc_2021_2023_exploration/weight_scenarios.R) · [Tablas `weights_*.csv`](elsoc_2021_2023_exploration/intervals/) · [Plan, decisiones y fuentes](elsoc_2021_2023_exploration/WEIGHTING_PLAN.md) · [Inspección de pesos](elsoc_2021_2023_exploration/weights_inspect_output.txt) · [Página didáctica](elsoc_ponderacion_explicado.html)

Fecha: 21-10-2026. Datos reales: `ELSOC_Wide_2016_2023.sav` leído del paquete cifrado `_elsoc/elsoc_wide_2016_2023.tar.xz.enc`. Una ejecución del cuaderno en kernel nuevo (4,7 minutos, 12 celdas sin error) y una reproducción independiente del script en otra carpeta: 22 de las 23 tablas CSV idénticas byte a byte; la restante es la de configuración, que solo difiere en la carpeta de salida que registra. Quince comprobaciones (doce sobre los datos, dos identidades de consistencia y una declaración, así etiquetadas en la tabla), todas superadas, incluida la reproducción exacta, celda a celda y límite a límite, de las tablas sin ponderar ya publicadas antes de estimar nada nuevo.

**Decisión principal.** Ponderar con los pesos longitudinales oficiales de la ola de destino mueve las dos permanencias condicionales en sentidos opuestos. Con el peso total sobre la muestra general (E2 − E1) sube «regular → regular» entre 3,2 y 6,6 puntos (el intervalo excluye el cero solo en 2021→2023) y baja «no regular → no regular» entre 3,5 y 5,7 (excluye el cero en 2016→2018 y 2018→2021), con la proporción de misma respuesta S09 entre −2,2 y +0,9. Con el peso panel sobre su subconjunto (E4 − E3) los movimientos son mayores: sube 4,9–5,9, baja 5,4–13,0 y en 2016→2018 también baja 6,0 puntos la misma respuesta. El mecanismo principal es de composición: los pesos duplican la participación de los jóvenes de 18–29, que son los menos persistentes en la no regularidad. La diferencia entre los dos escenarios ponderados tal como se entregan, `panel` frente a `total`, se explica por la ponderación aplicada al subconjunto panel y no por haber seleccionado ese subconjunto: sin pesos, el panel balanceado y la muestra general transitan casi igual (E3 − E1 no pasa de 1,6 puntos). El escenario sin ponderar sigue siendo la referencia: es la distribución observada de las mismas personas, con la mitad de la incertidumbre.

## Qué se comparó

| Estimador | Personas | Peso | Pares S09 (2016→2018 / 2018→2021 / 2021→2023) |
|---|---|---|---|
| E1 sin ponderar, general | G: todos los pares clasificables | ninguno | 1.888 / 2.261 / 1.807 |
| E2 `ponderador_long_total`, general | G | peso total de la ola de destino | 1.888 / 2.261 / 1.807 |
| E3 sin ponderar, subconjunto panel | P: pares con `ponderador_long_panel` > 0 | ninguno | 1.012 / 1.561 / 1.506 |
| E4 `ponderador_long_panel`, subconjunto panel | P | peso panel de la ola de destino | 1.012 / 1.561 / 1.506 |
| E5 `ponderador_long_total`, subconjunto panel | P | peso total | 1.012 / 1.561 / 1.506 |
| E6 sin ponderar, fuera del panel | G sin P: pares fuera del panel balanceado (faltaron a alguna ola de su cohorte, antes o después del destino) | ninguno | 876 / 700 / 301 |

Pares S10 (regulares con frecuencia válida en ambos extremos): 438 / 631 / 506 en G y 218 / 425 / 412 en P. Los 5.956 pares S09 corresponden a 2.887 personas únicas; los 1.575 pares S10, a 990. En los escenarios de ponderación ningún intervalo se agrupa con otro; las matrices de nueve estados (sección final) sí agrupan 2016–2023.

Las diferencias se calculan réplica a réplica sobre el mismo bootstrap de segmentos dentro de estratos (B = 1.999, semillas 20231022 / 20231023 / 20231021, las mismas de las tablas publicadas): E2 − E1 y E4 − E3 son **efectos de ponderar** sobre las mismas personas; E4 − E5 aísla la **variable de peso**; E3 − E1, E3 − E6 y E5 − E2 son **efectos de seleccionar la muestra**; E4 − E2 es una identidad y se muestra solo como lectura.

## Cambio de regla pedido por el usuario: fechas de destino ausentes

En 2021→2023 once personas reentrevistadas no tienen fecha de entrevista de destino en el SAV (de las 17 fechas ausentes entre los 2.726 entrevistados de la ola 2023, 13 M1 y 4 M2, según `intervals/field_dates.csv`). La regla publicada las excluía; la fecha solo sirve para medir los años transcurridos, no para observar la transición, así que ahora **se conservan sin duración**. Pares S09 de 1.796 a 1.807 y S10 de 502 a 506; la proporción con la misma respuesta pasa de 71,05 % a 71,06 %, «regular → regular» de 65,1 % a 65,2 % y «no regular → no regular» de 75,5 % a 75,5 %. Los otros dos intervalos no tienen fechas ausentes. Las tablas publicadas no se tocaron: el script las reproduce con la regla antigua como comprobación y después aplica la nueva.

## Resultados globales

Porcentajes ponderados cuando el estimador lleva pesos; N siempre sin ponderar; intervalos del 95 % del bootstrap de segmentos.

| Cantidad | Intervalo | E1 sin ponderar | E2 total | E3 sin ponderar, P | E4 panel, P |
|---|---|---|---|---|---|
| Misma respuesta S09 | 2016→2018 | 69,7 [67,5; 71,7] | 67,5 [63,2; 71,4] | 68,7 [65,9; 71,5] | 62,7 [56,5; 68,2] |
| | 2018→2021 | 71,4 [69,6; 73,2] | 70,4 [66,9; 74,0] | 72,7 [70,6; 74,9] | 71,2 [66,9; 75,6] |
| | 2021→2023 | 71,1 [68,9; 73,0] | 71,9 [67,9; 76,1] | 71,0 [68,6; 73,2] | 70,4 [65,6; 75,4] |
| Regular → regular | 2016→2018 | 64,6 [61,0; 68,2] | 68,5 [62,1; 74,5] | 63,1 [58,0; 68,2] | 68,0 [58,1; 77,1] |
| | 2018→2021 | 67,3 [64,3; 70,2] | 70,5 [65,3; 75,6] | 68,9 [65,3; 72,7] | 74,3 [67,9; 80,0] |
| | 2021→2023 | 65,2 [61,7; 68,7] | 71,8 [65,9; 77,7] | 64,4 [60,6; 68,2] | 70,3 [63,0; 77,8] |
| No regular → no regular | 2016→2018 | 72,5 [69,6; 75,2] | 66,8 [61,0; 72,2] | 71,6 [68,0; 75,0] | 58,6 [50,9; 66,3] |
| | 2018→2021 | 74,4 [72,1; 76,6] | 70,3 [65,9; 74,7] | 75,2 [72,6; 77,9] | 68,6 [63,2; 74,2] |
| | 2021→2023 | 75,5 [72,9; 78,0] | 72,0 [66,4; 77,5] | 75,9 [72,9; 78,6] | 70,5 [63,8; 77,1] |
| Cambio neto de la proporción regular (pp) | 2016→2018 | +4,5 [1,8; 7,4] | +6,7 [1,9; 11,5] | +5,8 [2,2; 9,6] | +9,7 [1,9; 18,0] |
| | 2018→2021 | +1,3 [−1,0; 3,6] | +2,1 [−2,1; 6,3] | +2,6 [−0,2; 5,3] | +5,2 [0,2; 10,1] |
| | 2021→2023 | −1,1 [−3,5; 1,3] | +0,1 [−4,6; 4,7] | −1,4 [−4,0; 1,3] | −0,3 [−5,9; 5,2] |

E5 (total sobre P) queda siempre a menos de dos puntos de E4; E6 (fuera del panel balanceado) queda dentro de ±5 puntos de E3 en las cantidades S09 y hasta 7 puntos en S10 de 2021→2023, donde E6 tiene 94 pares, siempre con intervalos anchos. Tablas completas por grupo, muestra y educación en `weights_comparison.csv`, `weights_transition_matrices.csv` y `weights_change_summary.csv`.

## Efecto de ponderar frente a efecto de seleccionar (puntos porcentuales, todos los pares)

| Contraste | Cantidad | 2016→2018 | 2018→2021 | 2021→2023 |
|---|---|---|---|---|
| Ponderar, misma gente G (E2 − E1) | regular → regular | +3,8 [−1,7; 8,7] | +3,2 [−1,1; 7,4] | **+6,6 [1,7; 11,4]** |
| | no regular → no regular | **−5,7 [−10,5; −1,2]** | **−4,1 [−7,7; −0,3]** | −3,5 [−8,1; 1,2] |
| | misma respuesta S09 | −2,2 [−5,9; 1,0] | −1,0 [−4,0; 1,9] | +0,9 [−2,4; 4,5] |
| Ponderar, misma gente P (E4 − E3) | regular → regular | +4,9 [−3,4; 12,8] | +5,4 [−0,3; 10,5] | +5,9 [−0,4; 11,8] |
| | no regular → no regular | **−13,0 [−19,5; −6,7]** | **−6,6 [−11,2; −2,1]** | −5,4 [−11,1; 0,2] |
| | misma respuesta S09 | **−6,0 [−11,3; −1,1]** | −1,5 [−5,3; 2,0] | −0,6 [−4,8; 3,7] |
| Variable de peso, misma gente P (E4 − E5) | no regular → no regular | −1,9 [−2,9; −1,0] | −0,7 [−1,3; −0,0] | −1,0 [−2,0; −0,1] |
| Selección sin pesos (E3 − E1) | misma respuesta S09 | −1,0 [−2,8; 0,8] | +1,3 [0,1; 2,6] | −0,1 [−1,0; 0,9] |
| | no regular → no regular | −0,9 [−3,2; 1,3] | +0,8 [−0,6; 2,3] | +0,4 [−0,7; 1,6] |
| Selección sin pesos, panel balanceado frente al resto de G (E3 − E6) | misma respuesta S09 | −2,1 [−6,2; 1,8] | +4,1 [0,2; 8,3] | −0,4 [−5,8; 5,2] |
| Selección bajo pesos total (E5 − E2) | no regular → no regular | −6,3 [−11,1; −1,0] | −1,0 [−3,8; 1,8] | −0,5 [−3,1; 2,2] |
| Diferencia entre escenarios (E4 − E2, identidad) | no regular → no regular | −8,2 [−13,3; −2,5] | −1,7 [−4,5; 1,3] | −1,6 [−4,4; 1,5] |

Lectura: solo los efectos de ponderar superan los cinco puntos con alguna regularidad (E4 − E3 en 6 de las 9 celdas S09 globales; E2 − E1 en 2 de 9). La selección del panel frente a la muestra general sin pesos (E3 − E1) no pasa de 1,6 puntos; su versión no diluida, panel balanceado frente al resto de G (E3 − E6), llega a 4–5 puntos en S09 y a 7 en S10, con intervalos anchos. El caso extremo es 2016→2018 en el subconjunto panel: ahí P exige haber respondido las siete olas hasta 2023, el peso panel calibra ese conjunto a la estructura INE de 2018 y la participación de los 18–29 pasa de 15,7 % a 31,1 %; la permanencia en no regular cae 13 puntos. Bajo pesos total, el subconjunto panel de 2016→2018 sí se separa de la muestra general (E5 − E2 = −6,3 [−11,1; −1,0]): el mismo peso total mueve la permanencia en no regular 11,1 puntos en P (E5 − E3) y 5,7 en G (E2 − E1). No es composición por edad, pues bajo peso total P tiene 28,0 % de 18–29 frente a 31,8 % en G; dentro de P los pesos altos recaen en personas menos persistentes, y las tablas no permiten ir más allá de esa descripción.

En S10 (regulares en ambos extremos) ningún efecto de ponderar (E2 − E1, E4 − E3) supera los cinco puntos y sus intervalos incluyen el cero; la variable de peso (E4 − E5) solo excluye el cero en «disminuye» 2018→2021 (+0,8 [0,1; 1,6]); el contraste panel balanceado frente al resto (E3 − E6) llega a −7,2 y +6,9 puntos en 2021→2023, con 94 pares en E6 e intervalos que incluyen el cero. La dirección por período se mantiene con y sin pesos: aumentos dominantes en 2018→2021 (40,3 % sin ponderar, 43,2 % con peso total) y disminuciones iguales o mayores que los aumentos en 2016→2018; en 2021→2023 el peso total deja aumento y disminución casi empatados (34,8 % y 35,3 %, frente a 32,4 % y 35,4 % sin ponderar).

## Permanencia en no regular por sexo y edad inicial

Las mujeres de 60–65 son el grupo con mayor permanencia en no regular sin ponderar en los tres intervalos (85,1 / 89,8 / 84,7 %). Con pesos lo siguen siendo en 2018→2021 (89,4 % con peso total; 91,3 % con peso panel) y con peso total en 2016→2018 (86,4 %); con peso panel en 2016→2018 (81,5 % frente a 81,9 %) y bajo ambos pesos en 2021→2023 (74,0 % y 76,5 % frente a 82,3 % y 82,2 %) las mujeres de 45–59 pasan al primer lugar, con ESS de 28–43 en el grupo de 60–65 e intervalos que se solapan. El grupo de menor permanencia es siempre una banda masculina, incluidos los hombres de 60–65 bajo ambos pesos en 2018→2021 (44,1 % y 42,8 %, ESS 15 y 11). Con pesos, los grupos pierden entre la mitad y tres cuartos de su tamaño efectivo: la ESS por grupo queda entre 4 y 137, y 56 de las 1.530 celdas principales están marcadas en el cruce de Taylor (39 de ellas sin SE bootstrap por origen pequeño o evento en el borde), todas con N de origen de 24 o menos. Los contrastes por grupo deben leerse como indicativos; las tablas completas están en el cuaderno y en `weights_comparison.csv`.

## Composición: lo que hacen los pesos y lo que hace la selección

| Participación de los 18–29 entre los pares S09 | 2016→2018 | 2018→2021 | 2021→2023 |
|---|---|---|---|
| G sin ponderar (E1) | 17,8 % | 17,8 % | 12,6 % |
| G con peso total (E2) | 31,8 % | 31,6 % | 25,9 % |
| P sin ponderar (E3) | 15,7 % | 16,2 % | 12,2 % |
| P con peso panel (E4) | 31,1 % | 31,5 % | 29,2 % |

La mayor diferencia estandarizada de cada contraste de ponderación está siempre en los 18–29 (0,33–0,43); la de E3 − E1 no pasa de 0,12 (sexo en 2016→2018) y la de E3 − E6 llega a 0,26, también en sexo. La comprobación de composición que recomienda el informe oficial se calcula en la ola de origen, sexo × cinco tramos INE entre personas de 18–65 en esa ola (en la ola de destino los pares llegan a 72 años y los conjuntos de referencia terminan en 65, así que esa comparación no se hace); da diferencias máximas menores de 0,1 tanto frente al total de entrevistados como frente al panel balanceado: los pares se parecen un poco más al total en 2016 M1 (0,044 frente a 0,093) y en 2018 M2 (0,052 frente a 0,082), empatan en 2018 M1 (0,060 frente a 0,059) y se parecen más al panel en 2021 M1 (0,047 frente a 0,032) y más al total en 2021 M2 (0,033 frente a 0,046). El criterio oficial no inclina la balanza hacia una familia de pesos; por eso se muestran las dos.

## Precisión

Los pesos oficiales son muy dispersos dentro de cada ola: el recorte p5/p95 del procedimiento se aplicó antes del raking y sobre todas las olas juntas. Sobre los pares S09 el tamaño efectivo de Kish es el 28–30 % del N con `total` (571 / 660 / 510) y el 24–26 % con `panel` (251 / 412 / 362); el peso máximo es 9 a 21 veces la media y el 1 % superior concentra entre el 8 % y el 11 % del peso. Los intervalos ponderados son aproximadamente el doble de anchos que los sin ponderar (misma respuesta S09: 4,2 frente a 8,1 puntos en 2016→2018). El origen de la dispersión es el estrato de ciudad del diseño: mediana del peso de destino 2,2–2,8 en Gran Santiago, 0,17–0,21 en ciudades grandes, 0,02–0,04 en medianas y 0,01 en pequeñas.

El error estándar de Taylor con `survey::svydesign` (segmentos dentro de estratos; peso 1 para los estimadores sin ponderar) coincide con el bootstrap: razón mediana 1,005 (p05 0,97, p95 1,05) sobre las 1.491 celdas principales con ambos errores. Capar los pesos en el p99 de su ola × muestra toca entre 7 y 22 pares, sube la ESS entre 2 % y 20 %, mueve las permanencias S09 globales 0,5 puntos como máximo y las direcciones S10 hasta 1,3, y desplaza las participaciones ponderadas de sexo × edad 3,2 puntos como máximo: los efectos de ponderar no dependen de unos pocos pesos extremos. Usar el peso de la ola de origen en lugar del de destino cambia las permanencias S09 globales en 2,0 puntos o menos (3,2 en el cambio neto bajo peso panel en 2018→2021) y las S10 en 3,3 como máximo.

## Hechos verificados y fuentes

| Hecho | Fuente |
|---|---|
| El SAV local (126.679.314 bytes, MD5 `dac64998f382fc99a5688ee8b5947db3`) es exactamente `ELSOC_Wide_2016_2023.sav` de la **versión 3.0 (27-12-2024)** del registro Dataverse «Estudio Longitudinal Social de Chile 2016-2023»; las versiones 1.0 (25-11-2024) y 2.0 (27-11-2024) tienen otros MD5. Licencia CC0 1.0. | API de Harvard Dataverse, DOI [10.7910/DVN/LD4BPH](https://doi.org/10.7910/DVN/LD4BPH), consulta 21-10-2026 |
| Definición oficial: `ponderador_long_total` «para todas las observaciones disponibles de ELSOC, ya sea con ambas muestras juntas o cada muestra por separado»; `ponderador_long_panel` «para el subconjunto de personas que han respondido a todas las olas, ya sea para la muestra original o la muestra de refresco». Recomendación para combinaciones de olas: comparar la composición por sexo y tramo etario con el total y con el panel balanceado. Recorte final a criterio del analista. | «Ponderadores longitudinales ELSOC. Documento de referencia», Equipo ELSOC, marzo 2023, [pondedradores-long-elsoc.netlify.app](https://pondedradores-long-elsoc.netlify.app/) |
| Construcción: peso de diseño; primera ola con no respuesta transversal de manzana; olas siguientes divididas por la tasa de respuesta de celdas de cuartil de predicción GEE (AR-1, un modelo por muestra, selección backward por QICu) dentro de ola × estrato; recorte p5/p95 una sola vez sobre todas las olas juntas; raking (`survey::rake`, `svydesign(id=~segmento_disenno)`) a proyecciones INE urbanas 18+ por sexo y cinco tramos (18–29, 30–39, 40–49, 50–59, 60+) por año y muestra; panel = `tipo_atricion == 1`; reescalamiento a N por muestra × ola. Insumos 2016–2022 v1.00. | Repositorio público [elsoc-coes/ponderadores-long](https://github.com/elsoc-coes/ponderadores-long), commit `475c7e32becc1451e8d40fb9b8ef0b79d4e5885f` (26-03-2024): `generar ponderadores/IV-generar master pesos.R`, `funciones/*.R`, `modelamiento NR/crear modelos gee con algoritmo backward.R` |
| El CSV oficial de olas 1–6 (18.035 filas) **no coincide** con los pesos del SAV 2016–2023: correlación 0,997–1,000 pero diferencias de hasta 2,46; el panel del CSV es 1.304 M1 / 772 M2 y el del SAV 1.176 M1 / 661 M2. Los pesos del SAV son una corrida nueva con datos 2016–2023; la etiqueta «(2016-2022)» quedó desactualizada y el listado 2023 dice «construido a partir de datos 2016-2023». El método de la ola 2023 no tiene documento propio: se usa bajo el supuesto de que es el mismo. | Comparación persona × ola en [weights_inspect_output.txt](elsoc_2021_2023_exploration/weights_inspect_output.txt), sección H; listado global 2023 (`_elsoc/docs/`), filas 28–29 |
| `ponderador_long_panel_wXX` tiene exactamente el mismo conjunto de titulares en todas las olas y coincide con `tipo_atricion == 1` y con haber respondido todas las olas de la cohorte (M1 siete olas, 1.176; M2 cinco olas, 661). `ponderador_long_total_wXX` es positivo para el 100 % de los entrevistados de cada ola y nulo fuera; suma N por muestra × ola; los retornos tras ausencias pesan más que los participantes continuos. | Inspección de solo lectura, secciones A y B |
| `segmento_disenno` y `estrato_disenno` son el segmento y el estrato del diseño original de cada muestra; `segmento_wXX` coincide con `segmento_disenno` en todas las olas; 1.009 segmentos en seis estratos, 362 compartidos por M1 y M2. No hay receta oficial de varianza ni pesos replicados. | Inspección, sección E; listado 2023 filas 18 y 24; manual metodológico, commit `edd00962c2e7df86ccf90f28bf9fc7fade186b37` |
| Los transversales `ponderador01/02` combinan M1 y M2 con el 73–74 % del peso en M1 en 2021 y 2023 (63–64 % de los entrevistados); los longitudinales ponderan cada muestra en proporción a su N. | Inspección, sección B2 |
| Cuestionario 2016: S09 «¿Consume usted regularmente bebidas alcohólicas como cerveza, vino, pisco u otros licores?» 1 Sí, 2 No → S11, NS/NR → S11; S10 «En el último mes, ¿cuántos días a la semana consumió alguna bebida alcohólica?» ocho categorías. Idéntico a 2018, 2021 y 2023 CAPI. | [PDF público COES](https://coes.cl/wp-content/uploads/2025/08/1_Cuestionario_Ola_1_Muestra_Original.pdf), p. 23, módulo S; cotejos 2018/2021/2023 en INTERVALS.md |
| Las 11 fechas ausentes de 2021→2023 (antes excluidas, ahora conservadas) son fechas de destino; no hay fechas de origen ausentes ni fechas desordenadas o fuera del año de terreno en ningún intervalo. | Inspección, sección C; `weights_sample_flow.csv` |

## Matrices con «no regular» como estado (ampliación del 21-10-2026)

Pedido del usuario: probabilidades de transición por sexo, edad y ola de origen con IC 95% y n de los estratos; «no regular» como estado de la matriz; matriz A y lognormal como en EPS con los distintos pesos; y probabilidades ponderadas agrupadas en los tres intervalos, con IC que reconozcan que una persona aporta varios pares. Script [state_transitions.R](elsoc_2021_2023_exploration/state_transitions.R), tablas `intervals/states_*.csv`, sección nueva del [cuaderno](elsoc_weighting_scenarios_EN.ipynb) y sección 9 de la [página «ELSOC transiciones explicadas»](elsoc_transiciones_explicado.html). Ejecución completa: 2,8 minutos; 16 comprobaciones (13 sobre los datos, 2 identidades entre dos cálculos y 1 declaración), todas superadas.

**Estados.** Nueve: NR (no regular, S09 = 2) y F1–F8, los regulares según los ocho códigos originales de S10 (menos de un día; uno a siete días por semana). El salto de S10 no se recodifica. Quedan fuera solo los regulares sin S10 válido en algún extremo: 15, 7 y 2 pares, de modo que quedan 1.873, 2.254 y 1.805 pares (5.932 pares de 2.880 personas). Los conteos NR→NR y el bloque de frecuencia reproducen exactamente las tablas publicadas de S09 y S10.

**Estimadores, como en `eps_markov_core.R`.**

- Observado: proporción ponderada por encuesta.
- Matriz A (`ep_Afit`, `ep_tune`): conteos por intervalo × sexo × edad encogidos hacia la matriz del sexo, la del intervalo y la de los tres intervalos, con intensidad k elegida por validación cruzada de 3 pliegues por persona. La grilla EPS (10 a 1.000) se amplió a 3.000 y 10.000 porque con pesos el óptimo quedaba en el borde. k elegido: 300 sin ponderar, 3.000 con peso total y 10.000 con peso panel, el borde de la grilla, donde la curva es plana (log loss 1,4931 con 3.000 y 1,4929 con 10.000). Un solo k rige los tres niveles y los conteos ponderados tienen un tamaño efectivo de un cuarto a un tercio de los pares, así que con pesos A lleva cada estrato e intervalo hacia la matriz de todos los intervalos (ver más abajo).
- Lognormal (`ep_fit`, tipo lognormal): logit de ser regular en destino y, entre regulares, días por semana lognormales con censura por intervalos (código 1 = menos de un día; código k = entre k − 1 y k días; código 8 = siete o más). Ambas partes usan estado de origen, sexo × edad e intervalo. La lectura de los códigos es un supuesto: el probit de la distribución acumulada de S10 es casi lineal en log días (R² de 0,992 a 0,998 por intervalo, hasta 0,999 al agrupar; en escala lineal de días, 0,878 a 0,942), pero leer los códigos como días redondeados al entero más cercano ajusta casi igual (0,981 a 0,999), y una distribución agrupada no prueba el σ común del modelo condicional. Como sensibilidad, la validación cruzada reajusta la lognormal con los límites redondeados (0,5 a 6,5 días): no predice mejor. Diferencia de log loss redondeo − principal: +0,0004 [−0,0020; +0,0027] sin ponderar, +0,0052 [+0,0002; +0,0102] con peso total y +0,0065 [−0,0002; +0,0131] con peso panel.

**Pesos y estratos.** Sin ponderar, `ponderador_long_total` y `ponderador_long_panel` de la ola de destino, este último en el subconjunto del panel; los modelos se ajustan con pesos reescalados a media 1 por intervalo, como la masa por período de EPS. Estratos: ola de origen × sexo × edad inicial, todos los pares de cada intervalo y los mismos grupos agrupados en 2016–2023.

**Incertidumbre.** Un bootstrap de segmentos dentro de estratos compartido por los tres intervalos (1.999 réplicas, semilla 20231024): cada persona está en un solo segmento, así que todos sus pares se mueven juntos; los modelos se reajustan en cada réplica con k fijo (falló 1 réplica de 1.999 de la lognormal, en el esquema panel). Para el observado se añaden Taylor con estratos y segmentos, y Taylor agrupado solo por persona (`ids = idencuesta`) en lo agrupado; en lo agrupado se calcula además, solo para comparar, el error Taylor que trata los pares como independientes (`ids = ~1`). Todas estas formas omiten la etapa de ciudades y tratan los pesos como fijos.

### Qué modelo predice mejor

| Peso | Log loss A | Log loss lognormal | Diferencia lognormal − A [IC 95%] |
|---|---:|---:|---|
| Sin ponderar | 1,2527 | 1,2378 | −0,0149 [−0,0208; −0,0089] |
| Total | 1,4300 | 1,3962 | −0,0338 [−0,0479; −0,0197] |
| Panel | 1,4968 | 1,4436 | −0,0532 [−0,0780; −0,0283] |

Cinco pliegues por persona repetidos tres veces, k ajustado dentro de cada entrenamiento. La lognormal gana en los nueve intervalo × peso; el intervalo excluye el cero en siete (no en 2021→2023 sin ponderar ni con peso total). En calibración agregada (intervalo × origen con al menos 30 pares) la matriz A queda más cerca de lo observado (error absoluto medio 0,013 / 0,031 / 0,030 frente a 0,019 / 0,036 / 0,035). A queda más cerca en la calibración por intervalo × origen, el nivel que estima directamente, sobre todo en quedarse en la misma frecuencia (diagonal 0,014 / 0,023 / 0,028 frente a 0,030 / 0,041 / 0,044); la ventaja de la lognormal en log loss es compatible con que conserve sexo y edad, pero no se descompuso. Los mayores desvíos de la lognormal están en los orígenes de tres días o más (con peso panel, también en uno y dos días), por ejemplo 4 días → 2 días en 2018→2021 sin ponderar (observado 37,8%, lognormal fuera de muestra 17,2%; 37 pares).

### Resultados agrupados 2016–2023 con peso total

Todos los pares (IC bootstrap de segmentos): seguir como no regular 69,6% [66,5; 72,7]; pasar de no regular a menos de un día 10,2% y a un día 11,1%; volver a no regular desde menos de un día 33,6% [27,6; 40,3], desde un día 31,4% [25,9; 37,3] y desde dos días 25,6% [18,7; 33,4]; mantener menos de un día 24,8% y un día 28,4%; seguir bebiendo a diario 11,8% [1,6; 25,1]. En la columna hacia NR la lognormal coincide casi exactamente con lo observado al agrupar todo (exactamente sin ponderar): el logit con el origen como factor reproduce por construcción la proporción de cada origen con los pesos del ajuste, que difieren de los de la encuesta solo en una constante por intervalo. Las diferencias aparecen dentro de los estratos.

Las matrices agrupadas son un promedio del período, no una matriz de duración definida: los intervalos duran en mediana 2,0, 2,4 y 2,9 años y entran según sus pares ponderados (32 / 37 / 31% con peso total; 24 / 38 / 38% con peso panel). Con peso panel el conjunto es el panel balanceado, que en 2016→2018 y 2018→2021 exige haber respondido hasta 2023, y con cualquier peso 2016→2018 tiene solo M1. No deben convertirse en una matriz anual o de ciclo sin un supuesto de duración.

| Grupo | Pares / personas | Sigue no regular, observado [IC estratos+segmentos] | Matriz A | Lognormal | De menos de un día a NR, observado |
|---|---|---|---:|---:|---|
| Hombres 18–29 | 397 / 237 | 59,6% [46,8; 71,2] | 68,1% | 59,8% | 37,3% |
| Hombres 30–44 | 688 / 396 | 62,0% [50,0; 72,7] | 68,3% | 58,5% | 28,2% |
| Hombres 45–59 | 782 / 427 | 61,6% [52,3; 70,2] | 68,2% | 63,7% | 25,7% |
| Hombres 60–65 | 273 / 188 | 61,4% [45,3; 75,3] | 68,5% | 63,0% | 20,9% |
| Mujeres 18–29 | 564 / 326 | 64,8% [56,5; 72,4] | 70,1% | 68,3% | 29,7% |
| Mujeres 30–44 | 1.216 / 675 | 70,2% [63,3; 76,2] | 70,5% | 69,1% | 32,2% |
| Mujeres 45–59 | 1.528 / 790 | 82,8% [78,8; 86,1] | 71,5% | 80,9% | 51,9% |
| Mujeres 60–65 | 484 / 316 | 83,7% [75,6; 89,5] | 70,9% | 84,1% | 43,1% |

Con peso total la matriz A deja la permanencia en no regular entre 68% y 72% en todos los grupos (con peso panel, entre 66% y 67%): su k alto, uno solo para todos los niveles, borra las diferencias por sexo y edad que lo observado y la lognormal sí muestran, y achica mucho las diferencias por ola de origen (con peso panel casi las borra). No es que los grupos sean homogéneos: los conteos ponderados son ruidosos. Sin ponderar, A conserva cerca de la mitad de la dispersión observada entre grupos. Solo lo observado da patrones por sexo × edad propios de cada ola: la lognormal aplica los mismos efectos de sexo × edad y de origen en todas las olas, desplazados por un término de intervalo, como la especificación EPS. La lognormal, a cambio, suaviza la frecuencia: subestima quedarse en las frecuencias comunes (menos de un día a dos días, y a diario), por ejemplo mantener un día 25,3% frente a 28,4% observado y seguir a diario 10,0% frente a 11,8% (sin ponderar 23,5% frente a 27,9% y 6,5% frente a 11,1%), y sobrestima quedarse en cuatro a seis días, donde casi no se observa (cuatro días: 6,4% frente a 0,4%).

**Agrupamiento por persona.** En las celdas agrupadas las formas de calcular el error casi coinciden. El Taylor agrupado por persona frente al que trata los pares como independientes: razón mediana 1,00 en los tres pesos (percentiles 10 y 90 entre 0,95 y 1,03); la mayor diferencia está en seguir no regular de todos los pares, la fila con más personas repetidas (1,07 sin ponderar, 1,02 con peso total, 1,04 con peso panel). Persona frente a estratos + segmentos: razón mediana 0,998–0,999 (percentiles 10 y 90 entre 0,98 y 1,02), aunque esta comparación no aísla los segmentos, porque también cambia la estratificación. El bootstrap es algo más ancho (razón mediana 1,015–1,054) y bastante más en las celdas muy escasas (percentil 90 de la razón: 1,08 sin ponderar, 1,44 con peso total y 1,69 con peso panel). Agrupar por persona es el supuesto correcto y se mantiene, pero cambia poco los intervalos.

**Soporte.** Con peso total, de las 243 filas de origen por intervalo (27 grupos × 9 orígenes) solo 71 tienen 30 pares o más, 149 tienen entre 1 y 29 y 23 están vacías; en lo agrupado, 40, 40 y 1 de 81. Las filas de tres días o más casi nunca llegan a 30 pares por intervalo y estrato, y tampoco muchas de menos de un día a dos días. Para usar matrices por estrato en la microsimulación la elección es del usuario: lo observado es ruidoso en esas filas, la matriz A con pesos pierde la heterogeneidad por sexo, edad y ola, y la lognormal conserva la de sexo y edad (no la propia de cada ola) y predice mejor fuera de muestra, pero subestima la persistencia en las frecuencias comunes. Las matrices agrupadas, además, mezclan tres duraciones.

## Límites

- Los pesos corrigen la participación en la ola de destino dado el inicio en la muestra; no modelan la participación conjunta en dos olas ni la validez del ítem. Quienes están en el destino pero faltaron en el origen quedan fuera sin ajuste (116 M1 en 2018→2021; 324 M1 y 210 M2 en 2021→2023, todas las edades). No se añadió ningún IPW propio.
- El bootstrap de segmentos omite la etapa de ciudades y trata los pesos como fijos; el cruce de Taylor comparte el mismo supuesto de conglomerado. Los intervalos son exploratorios.
- «No regular» no es abstinencia; coincidir en ambos extremos no prueba permanencia continua; el salto de S10 no es cero; S09/S10 no son AUDIT, gramos/día ni HED. S15 queda fuera. La comparación con EPS sigue siendo triangulación exploratoria y, si estas tablas se usan para calibrar el motor, dejan de ser evaluación independiente.
- Pendientes: confirmación de COES del método de los pesos 2023 y de la pertinencia de `total`/`panel` para pares; instrumento CATI 2023 y modo individual; coherencia edad–fecha.
