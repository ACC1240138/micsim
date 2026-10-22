# Plan de ponderación ELSOC: tres escenarios por intervalo

**Estado 21-10-2026 (tarde): implementado y ejecutado con permiso del usuario.** Cuaderno nuevo en inglés [elsoc_weighting_scenarios_EN.ipynb](../elsoc_weighting_scenarios_EN.ipynb), HTML autocontenido en la raíz, script [weight_scenarios.R](weight_scenarios.R), tablas `intervals/weights_*.csv`, hallazgos en español [hallazgos_elsoc_ponderacion.md](../hallazgos_elsoc_ponderacion.md) y página didáctica [elsoc_ponderacion_explicado.html](../elsoc_ponderacion_explicado.html). El notebook anterior y sus tablas no se tocaron. Decisiones del usuario sobre las preguntas D1–D10 de la sección 0: **D1** ola de destino, con la sensibilidad de ola de origen incluida; **D2** los pesos w07 se usan y su construcción idéntica al método público queda como **supuesto declarado**, no como motivo de aplazamiento (el usuario no acepta limitar la ponderación a los pares hasta 2021; el escenario sin ponderar no depende de ese supuesto); **D3** M1 y M2 por separado y agrupados con los pesos tal como vienen; **D4** escenario panel mantenido en los tres pares con su población declarada; **D5** bootstrap con réplicas comunes más Taylor en las celdas principales; **D6** sin recorte en el principal y sensibilidad con tope p99; **D7 cambiado por el usuario**: una fecha de destino ausente **no excluye el par**, porque solo hace falta para medir los años transcurridos; los once pares de 2021→2023 se conservan sin duración (pares S09 1.796 → 1.807, S10 502 → 506; estimaciones globales sin cambio apreciable) y la regla publicada queda como comprobación y sensibilidad; **D8** S10 8×8 ponderada solo en CSV; **D9** cuaderno nuevo en lugar de editar el existente; **D10** PDF 2016 registrado sin reempaquetar el bundle. Dos ajustes de implementación respecto del texto del plan, detectados por la revisión adversarial de los entregables: la comprobación oficial de composición (sección 4.3) se calcula en la **ola de origen** entre personas de 18–65 en esa ola, porque en la ola de destino los pares llegan a 72 años y los conjuntos de referencia terminan en 65, lo que convertía la comparación en un artefacto de la celda 66+; y la regla de fechas conserva el par cuando falta una fecha pero sigue comprobando el año de la fecha presente. La tabla de cobertura del cuaderno se calcula sobre los pares de la regla nueva, no se copia de `weight_coverage.csv`. **Ampliación posterior del mismo día (pedido del usuario):** matrices de nueve estados con «no regular» como estado (NR + los ocho códigos de S10), por ola de origen × sexo × edad y agrupadas en 2016–2023, con tres estimadores como en EPS (observado, matriz A con encogimiento jerárquico, lognormal en dos partes con censura por intervalos) y los tres pesos; intervalos por bootstrap de segmentos compartido entre intervalos (los pares de una persona se mueven juntos) y, para lo observado, Taylor con estratos y segmentos y Taylor agrupado por persona. Script [state_transitions.R](state_transitions.R), tablas `intervals/states_*.csv`, resultados en [hallazgos_elsoc_ponderacion.md](../hallazgos_elsoc_ponderacion.md). La grilla de k de la matriz A se amplió a 3.000 y 10.000 porque con pesos el óptimo quedaba en 1.000. Una revisión adversarial posterior corrigió la vista de matrices del cuaderno (la línea del observado repetía la celda hacia NR en toda la fila; las tablas CSV estaban bien) y añadió una sensibilidad que lee los códigos de S10 como días redondeados, un error Taylor con pares independientes para medir qué cambia el agrupamiento por persona y comprobaciones que sí pueden fallar. Las secciones siguientes conservan el plan tal como se sometió a confirmación, con las correcciones de la revisión adversarial; donde el texto dice «pendiente de confirmación» rige lo anterior.

Fecha del plan: 21-10-2026. Estado original: propuesta de implementación revisada por tres lecturas adversariales independientes (cumplimiento del encargo, estadística de encuestas, consistencia con los archivos) cuyas correcciones ya están incorporadas. En esta etapa no se modificó, ejecutó ni renderizó el notebook [elsoc_transiciones_2016_2023.ipynb](../elsoc_transiciones_2016_2023.ipynb); no se crearon scripts de análisis ni salidas en `intervals/`. Lo único ejecutado fue [weights_inspect.R](weights_inspect.R), una inspección de solo lectura de la estructura de los pesos cuyo registro está en [weights_inspect_output.txt](weights_inspect_output.txt) (sección 10). Parte de [INTERVALS.md](INTERVALS.md), [README.md](README.md), [extend_intervals.R](extend_intervals.R) y [analysis.R](analysis.R); reutiliza todas las estimaciones sin ponderar ya publicadas en `intervals/`. El registro de sesión está en el [handoff canónico](../codex_handoff_adam_rr_full_override_caveman.md).

Objetivo: comparar, para cada intervalo por separado (2016→2018, 2018→2021, 2021→2023), tres escenarios sobre las transiciones observadas de S09 (regularidad) y S10 (frecuencia condicionada): **(1)** `ponderador_long_total`, **(2)** `ponderador_long_panel`, **(3)** sin ponderación, separando el efecto de ponderar del efecto de seleccionar la muestra. S15 queda fuera del análisis y de la armonización.

## 0. Decisiones que requieren respuesta antes de implementar

| # | Decisión | Recomendación | Alternativa | Por qué importa |
|---|---|---|---|---|
| D1 | Ola del peso para cada par | Peso de la **ola de destino** (`_w03`, `_w05`, `_w07`), un solo peso por persona (sección 3.1) | Sensibilidad con peso de origen, para `total` y `panel` (misma rutina, columnas adicionales) | El factor de no respuesta del peso de destino es el que cubre la no reentrevista entre origen y destino; el de origen no la cubre. Multiplicar ambos duplica el componente de diseño común. |
| D2 | Uso de los pesos w07 (2023) | **Usar, con advertencia visible**: existen en el SAV oficial (Dataverse V3), son positivos para todos los entrevistados 2023 y su construcción 2016–2023 se infiere del listado y de la comparación con la versión 2016–2022 (sección 2.2), pero no hay informe ni código publicado para 2023 | Posponer el escenario ponderado del par 2021→2023 hasta respuesta de COES | Sin esto el tercer par queda solo sin ponderar. |
| D3 | M1 y M2 en los pares 2018→2021 y 2021→2023 | Presentar **M1 y M2 por separado y también agrupados** con los pesos tal como vienen. Para `total` el informe oficial autoriza ambas muestras juntas o separadas; cada muestra está normalizada a media 1 por ola, así que el agrupado pondera las muestras en proporción a sus N. Para `panel` el informe habla de «cualquiera de los dos paneles»: el agrupado M1+M2 bajo `panel` es una elección de este plan, no una recomendación oficial, y se etiqueta así | Solo por separado | El agrupado implícito difiere del compuesto transversal (sección 2.6). |
| D4 | Escenario panel en 2016→2018 y 2018→2021 | Mantenerlo como pide el encargo, **etiquetado como condicionado a participación en todas las olas hasta 2023** (futuro respecto del destino) | Omitirlo en esos pares | Cambia la población: 1.012 de 1.888 y 1.561 de 2.261 pares S09. Es justamente el “efecto de seleccionar la muestra” que se quiere aislar, no un sustituto del análisis general. |
| D5 | Incertidumbre | Mismo bootstrap de segmentos dentro de estratos (B=1.999, mismas semillas), extendido a proporciones ponderadas, con réplicas comunes a todos los estimadores y diferencias pareadas; **además, error estándar de Taylor con `survey::svydesign` (ids=segmento, estratos, pesos; peso 1 para los estimadores sin ponderar) para las celdas principales**, con bandera cuando ambos errores difieren más de 25 % (sección 4.2) | Solo bootstrap | Con ESS de 200–660 (S09) y 53–144 (S10) y pesos máximos 16–23 veces la media, un IC percentil puede ser irregular; un segundo método con el mismo supuesto de conglomerado permite distinguir intervalo genuino de artefacto. |
| D6 | Recorte adicional de pesos | **Principal sin recortar** (pesos oficiales tal como vienen) y **una sensibilidad obligatoria** con tope en el p99 de la ola × muestra, sin recalibrar, mostrando la estimación recortada y el desplazamiento que induce en las participaciones sexo × tramo etario | Sin sensibilidad; o tope en 5 × media | El recorte oficial p5/p95 se aplicó antes del raking sobre todas las olas juntas; dentro de cada ola las colas quedan intactas (p01 ≈ 0,004, máximo/media 14–23), de modo que un «efecto de ponderar» puede deberse a pocos pesos extremos. El informe recomienda el recorte final a quien le preocupen los extremos, con el sesgo de calibración como costo. |
| D7 | Filtros vigentes (sexo discordante 20/5/2; fechas 0/0/11) | Mantenerlos como están publicados y visibles en el flujo; publicar la descomposición de las 11 fechas (sección 5.2) | Convertirlos en banderas, como la edad | Cambiarlos ahora rompería la comparabilidad con las tablas sin ponderar ya publicadas. |
| D8 | Celdas pequeñas y S10 ponderada | Mantener N origen <30, evento/complemento <5, sin IC con <10 segmentos; añadir bandera ESS origen <30 en celdas ponderadas. La matriz S10 8×8 ponderada quedará marcada casi por completo (ESS del origen S10 completo 53–73 bajo `panel`, 71–144 bajo `total`): se guarda en CSV con banderas y en el notebook S10 ponderada se muestra solo como resumen igual / aumenta / disminuye, sin colapsar categorías | Mostrar también la 8×8 ponderada | En S10 por grupo el subconjunto panel baja a 8–18 pares en mujeres 60–65. |
| D9 | Ubicación de salidas y celdas | Script nuevo `weight_scenarios.R` en esta carpeta; CSV con prefijo `weights_` en `intervals/`; seis celdas nuevas tras «Pesos, diseño e incertidumbre» y cinco ediciones de celdas existentes (código 1 y 24; texto 0, 6 y 9; sección 7.2). Requiere permiso explícito para editar el `.ipynb` (AGENTS.md §4) | Notebook separado | — |
| D10 | Cuestionario 2016 recuperado (PDF público) | Registrar URL y página (sección 6); no reempaquetar `_elsoc/docs/elsoc_documentacion_pdf.tar.xz.enc` ahora | Añadirlo al bundle cifrado en la implementación | Cambiar un bundle obliga a reempaquetar y versionar. |

Confirmaciones por defecto (se asumen salvo objeción): educación completada sigue como margen con la aproximación de tres niveles ya documentada; `ponderador01/02` no entran como escenario principal (sección 1.2); ningún ajuste de atrición adicional (IPW) sobre los pesos oficiales; ningún agrupamiento de intervalos ni prueba conjunta; no se convierte el salto de S10 en cero; no se calculan gramos/día, HED ni AUDIT; el script de inspección [weights_inspect.R](weights_inspect.R) y su registro se conservan en la carpeta como evidencia reproducible (pueden borrarse si el usuario prefiere no dejar rastro adicional).

## 1. Alcance

### 1.1 Escenarios y estimadores

Para cada intervalo *i*, con G = pares clasificables tal como están definidos en `intervals/` (S09: 1.888 / 2.261 / 1.796; S10: 438 / 631 / 502) y P = G ∩ {`ponderador_long_panel_{destino}` > 0} (≡ `tipo_atricion == 1`; S09: 1.012 / 1.561 / 1.500; S10: 218 / 425 / 410):

| Estimador | Personas | Peso | Papel |
|---|---|---|---|
| E1 `unweighted_general` | G | ninguno | **Referencia**: ya publicado en `transition_matrices_unweighted.csv` y `change_summary_unweighted.csv`; se reutiliza sin recalcular |
| E2 `total_general` | G | `ponderador_long_total_{destino}` | Escenario 1 |
| E3 `unweighted_panel_subset` | P | ninguno | Auxiliar: selección sin pesos |
| E4 `panel_panel_subset` | P | `ponderador_long_panel_{destino}` | Escenario 2 |
| E5 `total_panel_subset` | P | `ponderador_long_total_{destino}` | Auxiliar: misma gente que E4 con la otra familia de pesos; misma familia que E2 con otra gente |
| E6 `unweighted_general_minus_panel` | G \ P (S09: 876 / 700 / 296; S10: 220 / 206 / 92) | ninguno | Auxiliar: pares que después salen del panel, para leer la selección directamente |

Contrastes, todos con N sin ponderar visibles y réplicas comunes: **efecto de ponderar** = E2 − E1 (mismas personas G) y E4 − E3 (mismas personas P); **efecto de la variable de peso** = E4 − E5 (mismas personas P, `panel` frente a `total`); **efecto de seleccionar la muestra** = E3 − E1 (sin pesos; su versión no diluida es E3 − E6, entre quienes siguen y quienes salen) y E5 − E2 (misma familia `total`, P frente a G). La diferencia entre los dos escenarios tal como se entregan, E4 − E2, es una identidad: E4 − E2 = (E4 − E3) + (E3 − E1) − (E2 − E1); se muestra como fila de lectura, no como un quinto efecto. Cada intervalo se trata por separado; una persona puede aportar hasta tres pares (2.886 personas en 5.945 pares S09) y no se agrupan.

### 1.2 Por qué la referencia es el escenario sin ponderar y por qué `ponderador01` no es escenario principal

- E1 es la distribución condicional observada entre los reentrevistados con respuesta válida, sin supuestos de modelo; es lo ya publicado para los tres pares con sus intervalos, y la única base sobre la que “efecto de ponderar” tiene una definición limpia (misma gente, con y sin peso).
- La pertinencia de cada peso para un estimando de pares no está certificada por ELSOC (sección 2.3); por eso los escenarios ponderados se leen como variaciones respecto de E1, no al revés.
- `ponderador01` (y `02`) son pesos **transversales**: diseño × no respuesta inicial de la manzana × postestratificación (01 «ajuste por población»; 02 «población y sexo», según las etiquetas del SAV; el informe longitudinal los nombra al revés, «TRV Sexo» para 01 y «TRV Sexo Región» para 02, discrepancia que se anota sin resolver). El manual los describe como pesos que «ignoran los problemas derivados de su naturaleza longitudinal»: no modelan la participación posterior a la primera ola, que es la selección relevante para un par. Los longitudinales parten de la misma base de diseño y reemplazan ese ajuste por un modelo de participación año a año, recortan colas antes de calibrar y calibran sexo × tramo etario a proyecciones INE urbanas 18+ (sección 2.2). Además el compuesto M1/M2 implícito en los transversales difiere del longitudinal (sección 2.6). Se reportan solo en la tabla de cobertura, no como escenario.

## 2. Pesos verificados por intervalo y cohorte

### 2.1 Nombre, ola, archivo, versión y fuente oficial

| Elemento | Verificado |
|---|---|
| Archivo | `ELSOC_Wide_2016_2023.sav`, 126.679.314 bytes, MD5 `dac64998f382fc99a5688ee8b5947db3`, copia cifrada en `_elsoc/elsoc_wide_2016_2023.tar.xz.enc`. |
| Versión oficial | Harvard Dataverse, «Estudio Longitudinal Social de Chile 2016-2023», DOI [10.7910/DVN/LD4BPH](https://doi.org/10.7910/DVN/LD4BPH), **versión 3.0 publicada el 27-12-2024** (la API de Dataverse lista ese mismo MD5 para la V3; las V1 de 25-11-2024 y V2 de 27-11-2024 tienen otros MD5). Licencia CC0 1.0. Depositante: Reproducible Research, COES. |
| Variables | `ponderador_long_total_w01…w07`, `ponderador_long_panel_w01…w07`; etiquetas SAV «Ponderador longitudinal (2016-2022). Muestra completa / Muestra sin atrición (año)». También `ponderador01/02_w01…w07` (transversales). |
| Listado global 2023 (filas 28–29) | Describe `ponderador_long_total/panel` como «construido por el equipo ELSOC a partir de datos **2016-2023**», pero marca «No» en las columnas 2023 de ambas muestras (suma 6/4 mediciones). La disponibilidad real la decide el SAV: hay valores positivos en 2023 para todos los entrevistados M1 y M2. |
| Informe metodológico | «Ponderadores longitudinales ELSOC. Documento de referencia. Equipo ELSOC. Marzo 2023», [pondedradores-long-elsoc.netlify.app](https://pondedradores-long-elsoc.netlify.app/) (una sola página; su `index.html` es byte a byte el archivo del repositorio de código). Describe la construcción con datos 2016–2022. |
| Código oficial | Repositorio público [elsoc-coes/ponderadores-long](https://github.com/elsoc-coes/ponderadores-long), commit `475c7e32becc1451e8d40fb9b8ef0b79d4e5885f` (26-03-2024, «Bug qic modelo nr»). Insumos `ELSOC_Long/Wide_2016_2022_v1.00`; salida `generar ponderadores/resultados/pesos_longitudinales_elsoc.csv` (18.035 filas, olas 1–6, columnas `idencuesta, ola, ponderadorlong_total, ponderadorlong_panel`). Es el mismo CSV «olas 1–6» que la exploración anterior descartó para w07. |
| Manual metodológico | [manual-elsoc](https://github.com/elsoc-coes/manual-elsoc/) commit `edd00962c2e7df86ccf90f28bf9fc7fade186b37`, sección *Design of Weights* (transversales) y remisión al informe longitudinal. |

### 2.2 Construcción documentada (informe + código) y qué cambia en la entrega 2016–2023

Pasos, por muestra y por año (`generar ponderadores/IV-generar master pesos.R`):

1. **Base**: primera ola de cada muestra (2016 M1, 2018 M2) = peso de diseño × ajuste de no respuesta transversal de manzana (`pd_nr`); olas siguientes = peso de diseño (`pd_diseno`) dividido por la tasa de respuesta de su celda de ajuste de esa ola.
2. **Modelo de participación**: regresión logística GEE (AR-1 por persona, `geepack`), **un modelo por muestra**, selección *backward* por QICu; respuesta `responde` = tener `ponderador02` en la ola; covariables candidatas: ola, sexo, estrato, tramo etario inicial (18–29/30–44/45–59/60+), educación (4 niveles), estado civil, no respuesta de ítems y visitas en la primera ola, e indicadores territoriales de la zona censal del CIT basados en el censo 2017 (el informe enumera cinco; el código ingresa seis). Se modela solo sobre participantes de la primera ola; no se filtra elegibilidad (muertes y cambios de país cuentan como no respuesta).
3. **Celdas de ajuste**: cuartiles de la predicción dentro de ola × `estrato_disenno`; ajuste = inverso de la tasa de respuesta observada en la celda.
4. **Recorte** p5/p95 del peso resultante, aplicado **una sola vez sobre el conjunto de todas las olas y muestras juntas** (`trimpesos_unev(elsoc_nr, 5, 95, …)`), antes del raking.
5. **Raking** (`survey::rake`) por ola a totales INE (proyecciones 2002–2035, población urbana 18+, área 1) de sexo y tramo etario en **cinco tramos** (18–29, 30–39, 40–49, 50–59, 60+). `total`: raking sobre todos los entrevistados de la ola de cada muestra; `panel`: raking sobre `tipo_atricion == 1` de cada muestra. El `svydesign(id=~segmento_disenno)` del código solo alimenta `rake()`; no es una receta oficial de varianza.
6. **Reescalamiento**: suma de pesos = N de entrevistados de la ola dentro de cada muestra (media 1 por muestra × ola).

Diferencias verificadas entre el CSV oficial 2016–2022 y el SAV 2016–2023 (comparación por persona × ola, olas 1–6, sección H del registro): correlación 0,997–1,000 pero diferencias máximas de hasta 2,46 en `total`; el conjunto con `panel` pasa de 1.304 M1 / 772 M2 (todas las olas 2016–2022) a **1.176 M1 / 661 M2** (todas las olas 2016–2023). Conclusión: los pesos del SAV son una **nueva corrida con datos 2016–2023** (consistente con la observación del listado), no la copia del CSV; la etiqueta «(2016-2022)» quedó desactualizada. El código de esa corrida no está publicado: la construcción de w07 se asume idéntica al método público (D2), pendiente de confirmación de COES. Indicio de continuidad: correlación de log-pesos w06–w07 de 0,999 entre presentes en ambas olas.

### 2.3 Población y patrón de participación al que se aplica cada peso (verificado en el SAV)

| Peso | A quién se aplica | Patrón de participación | Evidencia (registro de `weights_inspect.R`) |
|---|---|---|---|
| `ponderador_long_total_wXX` | Todos los entrevistados de la ola XX, dentro de cada muestra | Cualquier patrón: incluye retornos tras ausencias. El factor de no respuesta cubre la probabilidad de **estar en la ola XX** dado el inicio en la muestra; no modela la participación conjunta en dos olas concretas | Positivo para el 100 % de presentes en cada ola y ausente (NA) para no presentes; suma = N por muestra × ola. Los retornos reciben más peso: en w07 M1 media 1,155 (n=561) frente a 0,926 en participantes continuos (n=1.176); en w05 M1 1,248 (n=226) frente a 0,963 (n=1.513) |
| `ponderador_long_panel_wXX` | Solo el panel balanceado de cada muestra | M1: las siete olas 2016–2023 (1.176); M2: las cinco olas 2018–2023 (661) | El conjunto es idéntico en todas las olas y coincide exactamente con `tipo_atricion == 1` y con `ola_w01…w07 == 1` (M1) / `ola_w03…w07 == 1` (M2) |
| `ponderador01/02_wXX` | Entrevistados de la ola, ambas muestras juntas | Transversal | Media 1 en ambas muestras en 2018; media 1,16 / 1,17 en M1 y 0,73 / 0,71 en M2 en 2021 / 2023 |

El informe oficial recomienda `panel` «cuando se utilicen cualquiera de los dos paneles» y, con el total de observaciones, transversal o longitudinal indistintamente. Para «una combinación de olas y muestras» (su ejemplo: quienes responden 2016 y 2019 sin importar 2017–2018) recomienda, si el analista no construye un peso específico, **comparar la composición por sexo y tramo etario del conjunto filtrado con la del total de observaciones y con la del panel balanceado**, y usar el peso cuya población se le parezca más. Ese diagnóstico se implementa literalmente (sección 4.3); ninguna de las dos poblaciones oficiales coincide con «pares de dos olas», lo que se declara explícitamente.

### 2.4 Cobertura sobre los pares (peso de destino; fuente `intervals/weight_coverage.csv`, dominio `s09_pairs`, y registro de inspección)

| Intervalo | Muestra | S09 pares | `total`: positivos / ausentes / ≤0 | suma; ESS; mín–máx | `panel`: positivos / ausentes / ≤0 | suma; ESS; mín–máx | S10 pares: total / panel |
|---|---|---:|---|---|---|---|---|
| 2016→2018 (w03) | M1 | 1.888 | 1.888 / 0 / 0 | 1.971,3; 571; 0,0037–8,95 | 1.012 / 876 / 0 | 1.059,8; 251; 0,0031–12,17 | 438 / 218 |
| 2016→2018 | M2 | 0 | sin origen 2016 | — | — | — | 0 / 0 |
| 2018→2021 (w05) | M1 | 1.367 | 1.367 / 0 / 0 | 1.404,5; 371; 0,0036–13,81 | 983 / 384 / 0 | 1.052,7; 235; 0,0033–15,89 | 394 / 280 |
| 2018→2021 | M2 | 894 | 894 / 0 / 0 | 909,0; 296; 0,0064–8,65 | 578 / 316 / 0 | 603,6; 188; 0,0062–9,26 | 237 / 145 |
| 2021→2023 (w07) | M1 | 1.127 | 1.127 / 0 / 0 | 1.222,4; 299; 0,0035–16,38 | 934 / 193 / 0 | 1.026,3; 200; 0,0031–23,26 | 314 / 254 |
| 2021→2023 | M2 | 669 | 669 / 0 / 0 | 696,0; 216; 0,0075–8,91 | 566 / 103 / 0 | 614,6; 171; 0,0069–11,10 | 188 / 156 |

Agregado: S09 total 1.888 / 2.261 / 1.796 con ESS 571 / 660 / 508 (efecto de ponderación desigual de Kish n/ESS ≈ 3,3 / 3,4 / 3,5); subconjunto panel 1.012 / 1.561 / 1.500 con ESS 251 / 412 / 360 (≈ 4,0 / 3,8 / 4,2). S10 panel: 218 / 425 / 410. No hay pesos cero ni negativos. La dispersión dentro de cada ola es grande (p01 ≈ 0,004, p99 ≈ 7, máximo/media 14–23 en w05–w07) porque el recorte oficial se hizo antes del raking y sobre todas las olas juntas. Su origen es el estrato de ciudad: sobre los pares S09 la mediana del peso de destino es 2,5–2,8 en Gran Santiago (estrato 1), 0,18–0,19 en ciudades grandes, 0,03 en medianas y 0,01 en pequeñas, en los tres intervalos (registro de inspección, sección C); `weights_diagnostics.csv` lo repetirá (D6). En la implementación esta tabla se genera desde `weight_coverage.csv` (dominio `s09_pairs`), no a mano.

Soporte del subconjunto panel por sexo × edad inicial (pares S09 general/panel; entre paréntesis S10):

| Intervalo | Hombres 18–29 | 30–44 | 45–59 | 60–65 | Mujeres 18–29 | 30–44 | 45–59 | 60–65 |
|---|---|---|---|---|---|---|---|---|
| 2016→2018 | 146/56 (61/24) | 226/94 (99/35) | 265/136 (82/47) | 75/36 (21/10) | 190/103 (38/18) | 375/210 (74/44) | 473/296 (54/32) | 138/81 (9/8) |
| 2018→2021 | 159/95 (70/41) | 264/150 (128/71) | 294/198 (111/76) | 100/68 (34/24) | 244/158 (59/36) | 461/322 (115/88) | 564/439 (99/75) | 175/131 (15/14) |
| 2021→2023 | 95/72 (39/31) | 202/151 (98/70) | 227/182 (98/77) | 98/86 (35/30) | 130/112 (40/31) | 380/314 (90/76) | 495/432 (83/77) | 169/151 (19/18) |

Educación (S09 general/panel): 622/327, 783/434, 482/251, desconocida 1/0; 631/479, 1.019/697, 610/384, 1/1; 513/450, 771/648, 512/402, 0/0. Composición de origen sin ponderar: regulares al inicio 690/1.888 frente a 350/1.012; 942/2.261 frente a 621/1.561; 774/1.796 frente a 641/1.500 (el subconjunto panel tiene algo menos de regulares; es composición, no transición).

### 2.5 Estratos y conglomerados

- `estrato_disenno` (6 estratos: Gran Santiago, Gran Valparaíso, Gran Concepción, ciudades grandes, medianas, pequeñas) y `segmento_disenno` (1.009 segmentos, cada uno dentro de un solo estrato; 362 compartidos por M1 y M2) son el **estrato y la manzana/sub-bloque del diseño original de cada muestra** (M1: diseño 2016; M2: refresco 2018, que seleccionó sus manzanas entre las del listado 2016 de la muestra original), agregados a las bases longitudinales desde la ola 5 «para usar al considerar diseño complejo» (listado, filas 18 y 24). `segmento_wXX` coincide con `segmento_disenno` en el 100 % de los presentes de cada ola: el combinado no actualiza el segmento tras mudanzas.
- No hay receta oficial de varianza: el código oficial declara `segmento_disenno` como conglomerado solo para calibrar. La primera etapa (40 ciudades) no es recuperable desde las variables publicadas; no hay pesos replicados oficiales. El bootstrap de segmentos dentro de estratos ya usado es exploratorio (sortea n_h y no n_h − 1 segmentos por estrato, omite la etapa de ciudades), de ahí el cruce con Taylor de D5.

### 2.6 Compuesto M1/M2

Con `ponderador_long_total` cada muestra suma su propio N: el agrupado M1+M2 pondera las muestras ≈ en proporción a sus pares (participación del peso M1 = 0,607 y 0,637 frente a participación de N = 0,605 y 0,628). Con `ponderador01` el compuesto oficial da a M1 el 73–74 % del peso en 2021 y 2023 (63–64 % de los entrevistados). Son compuestos distintos y legítimos; el plan usa el longitudinal tal como viene (D3) y muestra siempre M1 y M2 por separado.

## 3. Ola del peso, producto de pesos y ajuste de atrición

### 3.1 Ola de destino (D1)

Para el par w0→w1 se usa `ponderador_long_{total|panel}_{w1}`:

- El factor de no respuesta de la ola w1 es el que apunta a la selección relevante del par: estar presente en w1 habiendo iniciado en la muestra. El peso de w0 solo ajusta la participación hasta w0 y no contiene información sobre la no reentrevista en w1.
- Cuando el origen es la **primera ola de la muestra** (M1 2016→2018; M2 2018→2021) el factor de w1 es exactamente P(presente en w1 | participante de la primera ola): coincide con la no reentrevista del par salvo por los filtros de ítem y calidad, y nadie puede estar en w1 sin haber estado en w0. Para M1 en 2018→2021 y para ambas muestras en 2021→2023 el factor cubre además a quienes faltaron en w0, que no pueden ser pares: ahí sí hay una selección residual sin ajuste, cuyo tamaño se publica en el flujo (`destination_present_origin_absent`; en todas las edades: 116 M1 en 2018→2021; 324 M1 y 210 M2 en 2021→2023; registro de inspección). No se añade IPW adicional (regla del encargo).
- Los pares son un subconjunto de los entrevistados de w1; el peso de w1 está calibrado a sexo × tramo etario INE del año de w1.
- No multiplicar `_w0 × _w1`: ambos comparten el peso de diseño y el ajuste inicial, y el producto no es un peso documentado. La razón destino/origen de `total` dentro de los pares S09 tiene medianas 1,15 / 0,97 / 1,04 y rangos p5–p95 de 0,58–1,99, 0,32–3,17 y 0,40–2,25 (correlación de log-pesos 0,98, 0,94, 0,97). La mediana 1,15 de 2016→2018 es el ajuste de atrición del peso w03 respecto de w01 (suma sobre los mismos pares: 1.971,3 frente a 1.781,2); la elección de ola cambia pesos individuales, de ahí la sensibilidad opcional de D1.
- Para `panel`, el conjunto es el mismo en todas las olas; la ola de destino cambia tanto el factor de no respuesta por celda de esa ola como la calibración anual. Si se corre la sensibilidad de origen, se corre también para `panel`.
- Hipótesis a verificar, no resultado: en el subconjunto P, log(`panel_w1`) y log(`total_w1`) correlacionan 0,998–0,999, por lo que se anticipa E4 ≈ E5 (efecto pequeño de la variable de peso) y que la mayor parte de E4 − E2 provenga de la selección (E5 − E2 y E3 − E1).

### 3.2 Sin ajuste adicional por atrición

Los pesos oficiales ya incorporan el ajuste de participación por celdas (sección 2.2). No se multiplica por ningún IPW propio; la selección residual (ítem válido en ambos extremos, ausente en w0 cuando aplica) se cuantifica en el flujo y se discute, sin corregirla.

## 4. Diseño de la comparación

### 4.1 Estimación

Para cada intervalo, ítem (S09 2×2; S10 8×8 solo regulares con frecuencia válida en ambos extremos), grupo (All, M1, M2, sexo × edad inicial 18–29/30–44/45–59/60–65, educación aproximada) y estimador E1–E6: N de origen sin ponderar, eventos sin ponderar, suma de pesos, ESS de origen, proporción de fila (ponderada en E2/E4/E5), IC, banderas. Además: resumen de cambios (S09 igual / paso a regular / paso a no regular sobre todos los pares; S10 igual / aumenta / disminuye), cambio neto pareado de la proporción regular, y **permanencia en no regular** `P(S09=2 destino | S09=2 origen)` destacada por intervalo y sexo × edad con N e IC.

### 4.2 Incertidumbre y precisión (D5, D6)

- Se regeneran las réplicas de segmentos dentro de estratos con las mismas unidades y semillas (20231022 para 2016→2018, 20231023 para 2018→2021, 20231021 para 2021→2023; B=1.999) y se **verifica que reproducen exactamente** los límites publicados de E1 en los tres intervalos antes de usarlas para E2–E6. Así las réplicas son comunes a todos los estimadores.
- Proporción ponderada por réplica: totales ponderados por segmento multiplicados por los conteos bootstrap (extensión mínima de `estimate()`: `tabulate()` → suma ponderada por segmento; con un vector de unos reproduce la función actual).
- Cada estimador devuelve el vector completo de B réplicas, con `NA` cuando el origen remuestreado queda vacío; los deltas se calculan réplica a réplica sobre las posiciones no faltantes de ambos vectores (nunca sobre vectores filtrados por separado) y la regla de soporte ≥ 95 % de B se aplica al número de diferencias pareadas válidas. IC percentil para estimaciones y deltas.
- **Cruce de Taylor** (D5): `survey::svydesign(ids = ~segmento_disenno, strata = ~estrato_disenno, weights = ~w, nest = TRUE)` construido sobre el dominio basal completo del intervalo y restringido con `subset()` (para que los segmentos sin miembros del dominio conserven su papel de diseño), con `w = 1` para E1/E3/E6; `survey::svyby`/`svyciprop` para la matriz S09, el resumen de cambios y la permanencia en no regular de All, M1, M2 y los ocho grupos sexo × edad; `survey.lonely.psu = "adjust"` declarado. Se reportan ambos errores estándar y se marca `se_ratio_flag` cuando difieren más de 25 %.
- Precisión: ancho del IC, ESS de Kish del origen y n/ESS (etiquetado como efecto de ponderación desigual, no como efecto de diseño), y el efecto de diseño realizado `deff_boot = Var_boot(p) / (p(1−p)/n_origen)`. Lo que falta y en qué dirección: el bootstrap omite la etapa de ciudades y sortea n_h segmentos (tiende a subcubrir) y trata los pesos calibrados como fijos (conservador para ese componente). Los IC siguen siendo exploratorios; el peso no resuelve por sí solo la varianza.
- **Sensibilidad de recorte** (D6): el mismo `estimate_w` con `pmin(w, p99_{ola×muestra})`, sin recalibrar, para E2/E4/E5; columnas adicionales en `weights_comparison.csv` con la estimación recortada y el desplazamiento de las participaciones ponderadas de sexo × cinco tramos (espejo del `trim_pesos()` de revisión del repositorio oficial).
- Reglas de celdas: N<30, evento/complemento <5, orígenes vacíos, <10 segmentos sin IC, más ESS<30 (D8).

### 4.3 Composición

Dos bloques en `weights_composition.csv`:

1. **Comprobación oficial** (informe, «combinación de olas y muestras»): composición **sin ponderar** por sexo × tramo etario oficial (18–29, 30–39, 40–49, 50–59, 60–65, dentro del dominio de edad inicial 18–65) de los pares G, comparada con (i) todos los entrevistados de la ola de destino de la misma muestra con 18–65 en origen y (ii) el panel balanceado de la misma muestra en esa ola; SMD de G frente a cada una; la menor es el criterio del informe y se imprime junto al peso elegido en `weights_documentation.csv`. Reutiliza la construcción `composition_for_weight_choice` de `analysis.R` (que ya cubre w05/w07) y la extiende a w03.
2. **Diagnóstico de balance al estilo EPS** (`v2_balance_smd.csv`): participaciones de sexo × edad, muestra, educación y estado S09 de origen bajo E1–E6 con SMD para G ponderado frente a G sin ponderar (qué cambia el peso), P frente a G sin ponderar y P frente a G \ P (qué cambia la selección) y P ponderado frente a P sin ponderar.

### 4.4 Tabla comparativa por intervalo

Filas: S09 misma respuesta, sigue regular, sigue no regular, cambio neto; S10 igual / aumenta / disminuye. Columnas: para E1–E6, N sin ponderar, ESS, estimación, IC percentil, ancho, error estándar bootstrap y de Taylor; luego los deltas E2 − E1, E4 − E3, E4 − E5, E3 − E1, E3 − E6, E5 − E2 con IC pareado, la fila de lectura E4 − E2 con su identidad, y la estimación recortada (D6). Permite leer por separado cambio de estimación (deltas), composición (sección 4.3) y precisión (ESS, anchos, errores estándar, `deff_boot`).

## 5. Población, enlace y filtros

### 5.1 Filtros vigentes (sin descartes silenciosos)

| Filtro | Regla actual | Descartes 2016→2018 / 2018→2021 / 2021→2023 | Tipo | Propuesta |
|---|---|---|---|---|
| Presente en origen | `ola_w0 == 1` (coincide con `cuestion_completo_w0` informado) | define el universo (2.927 / 3.748 / 2.740 entrevistados) | definición | mantener |
| Edad inicial | `m0_edad_w0` no faltante y 18–65 | fuera o faltante: 365 / 527 / 440 | definición | mantener; añadir conteo de edad faltante por separado |
| Reentrevista | `ola_w1 == 1` | no reentrevistados 625 / 935 / 485 | selección (es lo que los pesos intentan ajustar) | mantener; mostrar retención por estado S09 de origen |
| Sexo | 1/2 válido en ambos extremos e igual | 20 / 5 / 2 | control de identidad | mantener (D7) |
| Fechas | ambas presentes, destino > origen, año nominal de origen y año(s) de destino (2023–2024 para w07) | 0 / 0 / 11 | control | mantener (D7); publicar la descomposición fecha de destino ausente / fecha de origen ausente / orden o año inválidos como etapas del flujo (el registro de inspección ya la trae: las 11 de 2021→2023 son fecha de destino ausente) |
| Edad de destino | 18–110 no faltante | 0 / 0 / 0 | control | mantener |
| Edad–tiempo | diferencia > 1,05 años | 198 / 143 / 516 **marcados, no excluidos** | indicador de revisión | mantener como bandera y sensibilidad estricta |
| S09 válido | 1/2 en ambos extremos | 29 / 20 / 6 | ítem | mantener; faltantes se excluyen solo del ítem |
| S10 válido | S09=1 y S10 1–8 en ambos extremos | define S10 (438 / 631 / 502) | universo del ítem | mantener; el salto no es cero |
| Panel elegible (nuevo) | `ponderador_long_panel_w1 > 0` ≡ `tipo_atricion == 1` | S09 fuera de P: 876 / 700 / 296 | selección del escenario 2 | solo para E3/E4/E5/E6 |

### 5.2 Flujo a producir (`weights_sample_flow.csv`, `weights_unique_persons.csv`, `weights_durations.csv`)

Las etapas existentes de `sample_flow.csv` más: `origin_age_missing`, `destination_date_missing`, `origin_date_missing`, `date_order_or_year_invalid`, `panel_eligible_links`, `s09_pairs_panel_eligible`, `s10_pairs_panel_eligible`, `destination_present_origin_absent` (contexto: entrevistados de w1 de la muestra ausentes en w0, sin ajuste posible), por intervalo y muestra. Dentro de un intervalo participantes = pares = personas (una fila por persona). Se añade una tabla por etapa con el número de **personas únicas** que la cumplen en al menos un intervalo y en los tres, para que los N de los períodos no se sumen como individuos. Las duraciones reales entre entrevistas (mediana, mínimo, máximo en años, a partir de las fechas individuales) se publican por intervalo × muestra para G, P y G \ P: los intervalos no son bienales ni se anualizan.

## 6. Indicadores S09 y S10 por ola (verificación cerrada para 2016, 2018, 2021 y CAPI 2023; instrumento CATI 2023 y modo individual pendientes)

| Ola / muestra | Fuente verificada | S09 | S10 | Modalidad |
|---|---|---|---|---|
| 2016 M1 | Cuestionario «Encuesta Conflicto y Cohesión Social COES 2016», p. 23, módulo S ([PDF público](https://coes.cl/wp-content/uploads/2025/08/1_Cuestionario_Ola_1_Muestra_Original.pdf), recuperado en esta sesión; en la ampliación anterior no se pudo descargar) | «¿Consume usted regularmente bebidas alcohólicas como cerveza, vino, pisco u otros licores?» 1 Sí; 2 No →Pase a S11; −888 NS →S11; −999 NR →S11 | «En el último mes, ¿cuántos días a la semana consumió alguna bebida alcohólica?» 1 menos de un día … 8 siete días; −888; −999 | CAPI |
| 2018 M1/M2 | PDF oficiales p. 22 / p. 23 (ya cotejados en INTERVALS) | idéntico | idéntico | CAPI |
| 2021 M1/M2 | Llamado A p. 7 / p. 10 | idéntico, con lectura de alternativas | idéntico | CATI (dos llamados) |
| 2023 M1/M2 | Hojas CAPI M1/M2 del cuestionario v18 | idéntico | idéntico | mixto; instrumento CATI y modo individual pendientes |

Listado global 2023 (filas 496–497): S09/S10 «INTERCALADO, DOS MUESTRAS», medidas en 2016, 2018, 2021 (llamado A) y 2023 en M1 y en 2018, 2021 (A) y 2023 en M2; ausentes en 2017, 2019 y 2022. Códigos especiales −999/−888/−777/−666 se conservan separados (`intervals/raw_code_counts.csv`, `s10_routing.csv`, `value_labels.csv`); en ninguna ola hay S10 válida con S09=2. Reglas de lectura que se mantienen en todas las salidas: «no regular» no es abstinencia; coincidir en ambos extremos no prueba permanencia continua; el salto de S10 no es frecuencia cero; las transiciones de frecuencia se restringen a regulares con respuesta válida en ambos extremos; S09/S10 no son AUDIT ni gramos/día ni HED. La disponibilidad exclusiva de 2023 M1 corresponde a S15, que queda fuera.

## 7. Implementación propuesta (para después de la confirmación)

### 7.1 Script nuevo `weight_scenarios.R` (misma carpeta; nada existente se modifica)

Contrato: empieza con `.t0` y termina informando minutos; funciones como `paquete::función`; lee el SAV con `acc_data()` y comprueba el MD5; reconstruye las máscaras de los tres pares con la misma lógica de `extend_intervals.R` y **exige** que los conteos coincidan con `intervals/sample_flow.csv`; define `w_total`, `w_panel` de la ola de destino y `panel` (comprobando `panel == (tipo_atricion == 1)` dentro de los pares y ausencia de pesos ≤0 o faltantes dentro de cada dominio); regenera las réplicas y comprueba que `estimate_w(den, num, rep(1, nrow(d)))` reproduce límite a límite las tablas publicadas; calcula E2–E6, deltas, cruce de Taylor, sensibilidad de recorte, composición, diagnósticos, flujo y duraciones; escribe solo archivos con prefijo `weights_` en `intervals/`; comprueba por hash que ningún archivo previo cambió; guarda `session_info`. Núcleo del cambio de código (único punto nuevo de lógica; el resto reutiliza objetos `seg`, `units`, `unit_index`, `boot` y las reglas de estado de `estimate()`):

```r
# A vector of ones reproduces the published unweighted estimate(); weights enter as per-segment totals.
estimate_w <- function(den, num, w) {
  stopifnot(all(!num | den), length(w) == length(den), all(is.finite(w[den]) & w[den] > 0))
  n <- sum(den); k <- sum(num); g <- length(unique(seg[den]))
  p <- if (n) sum(w[num]) / sum(w[den]) else NA_real_
  reps <- rep(NA_real_, ncol(boot))
  if (n && g >= 10 && k > 0 && k < n) {
    cd <- cn <- numeric(nrow(units))
    a <- rowsum(w[den], unit_index[den]); cd[as.integer(rownames(a))] <- a
    b <- rowsum(w[num], unit_index[num]); cn[as.integer(rownames(b))] <- b
    dd <- as.numeric(crossprod(cd, boot)); nn <- as.numeric(crossprod(cn, boot))
    reps <- ifelse(dd > 0, nn / dd, NA_real_)   # full-length vector: deltas pair replicate by replicate
  }
  # percentile CI from reps when >= 95% are non-missing; same ci_status rules as estimate();
  # ess = sum(w[den])^2 / sum(w[den]^2); deff_boot = var(reps, na.rm = TRUE) / (p * (1 - p) / n)
}
```

Comprobado en esta sesión sin datos: con `w = rep(1, length(den))` las sumas por segmento coinciden exactamente con `tabulate()`; con `den` vacío `rowsum()` devuelve una matriz sin filas y la asignación es inocua; un `w` escalar **no** sirve (`1[den]` produce `NA`), de ahí la comprobación de longitud.

Salidas (todas con `interval`, `estimator` ∈ {unweighted_general, total_general, unweighted_panel_subset, panel_panel_subset, total_panel_subset, unweighted_general_minus_panel}, `sample_set`, `weight_variable`):

| Archivo | Contenido |
|---|---|
| `weights_documentation.csv` | una fila por intervalo × peso: nombre, ola, archivo/versión/MD5, fuente, población, patrón de participación, componentes, si el origen es la primera ola de la muestra, cobertura (n, positivos, ausentes, ≤0) sobre G y P, suma, ESS, mín/máx del dominio de pares, SMD de la comprobación oficial (4.3), decisión |
| `weights_sample_flow.csv`, `weights_unique_persons.csv`, `weights_durations.csv` | sección 5.2 |
| `weights_transition_matrices.csv` | esquema de `transition_matrices_unweighted.csv` + `n_event_weighted`, `sum_w_origin`, `ess_origin`, `deff_boot`, `small_ess` |
| `weights_change_summary.csv`, `weights_paired_regular_share_change.csv` | mismos esquemas actuales + columnas ponderadas |
| `weights_comparison.csv` | tabla 4.4 (una fila por intervalo × cantidad; columnas por estimador, deltas con IC pareado, Taylor, recorte) |
| `weights_taylor_check.csv` | celdas principales: estimación, SE bootstrap, SE Taylor, razón, bandera |
| `weights_shift_table.csv` | por intervalo × ítem × contraste: celdas, desplazamiento absoluto medio y máximo, celda del máximo y su N (espejo de `v2_scheme_shift_table.csv`) |
| `weights_composition.csv` | sección 4.3, dos bloques |
| `weights_diagnostics.csv` | por estimador × intervalo × ítem: n, suma, ESS, n/ESS, `deff_boot`, media, máximo, máximo/media, participación del 1 % superior, mediana y p05–p95 del peso por estrato |
| `weights_validation.csv` | comprobaciones: conteos de flujo iguales a los publicados; panel ≡ `tipo_atricion`; sin pesos ≤0 o faltantes en los dominios; réplicas reproducen E1 con vector de unos; filas suman 1; eventos suman N; deltas pareados sobre réplicas alineadas; archivos previos intactos; sin inferencia agrupada |

### 7.2 Celdas del notebook (requiere permiso; posiciones sobre el notebook actual de 25 celdas)

- Celda 1 `elsoc-analysis`: una línea más, `source(file.path(elsoc_base,"weight_scenarios.R"), local=new.env(parent=globalenv()))`.
- Celda 0: «Lectura rápida» pasa de «sin ponderar» a «tres escenarios; referencia sin ponderar».
- Celda 6 (markdown «Instrumentos y comparabilidad»): fila 2016 actualizada con el PDF recuperado.
- Celda 9 (markdown «Pesos, diseño e incertidumbre»): columna «Decisión» actualizada y fuentes de la sección 2.1.
- Nuevas, tras la celda 10: markdown «Escenarios de ponderación» + código `elsoc-weights-documentation`, `elsoc-weights-flow` (flujo, personas únicas y duraciones), `elsoc-weights-comparison` (tabla 4.4 y figura de puntos con IC por intervalo), `elsoc-weights-groups` (permanencia regular y no regular por sexo × edad bajo E1–E5 con N y ESS), `elsoc-weights-composition`. Cada celda de código empieza con `.t0 <- Sys.time()` y termina con `cat(sprintf("Elapsed: %.2f minutes\n", …))`, como las celdas 1–24.
- Celda 24 `elsoc-validation`: `stopifnot(all(read_table("weights_validation")$passed))`.

Tiempo esperado: del orden del script actual (minutos), cinco estimadores adicionales con las mismas réplicas más el cruce de Taylor. HTML en la raíz solo cuando el usuario lo indique.

## 8. Relación con EPS (sin armonizar ahora)

| Elemento EPS v2 | Equivalente ELSOC propuesto | Nota |
|---|---|---|
| Población inicial 18–65 por período, riesgo tras salidas | Dominio basal 18–65 por intervalo; no hay registro de fallecidos: ausencia ≠ salida | `v2_attrition_table` ↔ `weights_sample_flow` + retención por estado de origen |
| Esquemas `official / ipw_v1 / ipw_v2_sl` | Estimadores `unweighted / total / panel` sobre conjuntos declarados | ELSOC no ajusta IPW propio |
| `v2_transition_matrices_schemes_design_CI` | `weights_transition_matrices` | estados distintos: S09 1/2 y S10 1–8, no N0/FD/C1–C4 |
| `v2_scheme_shift_table`, `v2_balance_smd`, `v2_weight_diagnostics` | `weights_shift_table`, `weights_composition`, `weights_diagnostics` | mismos nombres de columnas donde aplica |
| Réplicas JKn construidas por el motor EPS (no oficiales) | Bootstrap propio de segmentos + Taylor | ninguna de las dos encuestas publica réplicas oficiales |

Definiciones comunes posibles y pérdidas se mantienen como en el [mapa documental](../../_elsoc/README.md): regularidad ELSOC no equivale a cualquier consumo EPS; S10 (días/semana, cualquier bebida, solo regulares) no equivale a gramos/día ni HED; sexo, edad inicial y educación completada son H bajo supuestos. Nada de esto se implementa en esta etapa. La comparación con EPS seguirá siendo triangulación exploratoria; si ELSOC se usa después para ajustar el motor, dejará de ser evaluación independiente.

## 9. Pendientes y fuentes oficiales

Pendientes: (a) confirmación COES del método para w07 y de la pertinencia de `total`/`panel` para pares; (b) instrumento CATI 2023 y modo individual; (c) coherencia edad–fecha; (d) registro de disposiciones de seguimiento para separar salidas conocidas de no reentrevista; (e) año y detalle del diseño de segmentos del refresco en la documentación oficial. Fuentes: Dataverse DOI 10.7910/DVN/LD4BPH (V3, 27-12-2024); informe «Ponderadores longitudinales ELSOC» (marzo 2023); repositorio `elsoc-coes/ponderadores-long` commit `475c7e3`; `manual-elsoc` commit `edd0096`; listado global 2023 local; cuestionarios 2016 (p. 23), 2018, 2021 y 2023 citados en la sección 6.

## 10. Qué se ejecutó en esta sesión y qué no

Ejecutado, solo lectura: [weights_inspect.R](weights_inspect.R) (en la carpeta, con `.t0`, `acc_data()` y comprobación de MD5), que descifró el SAV en `tempdir()`, reconstruyó las máscaras de los tres pares (conteos idénticos a los publicados: 1.917/1.888/438, 2.281/2.261/631, 1.802/1.796/502) y midió solo estructura de pesos: identidad del conjunto panel, positividad y sumas, medias por patrón de participación, razones destino/origen, tamaños del subconjunto panel por grupo, segmentos y dispersión por estrato, descomposición de las exclusiones por fecha, comparación con el CSV oficial 2016–2022 (descargado al vuelo desde el commit fijado). Su registro íntegro es [weights_inspect_output.txt](weights_inspect_output.txt); todas las cifras de las secciones 2–3 que no provienen de `intervals/` provienen de ahí. Consultas web: API de Dataverse (versiones y MD5), repositorio de código y PDF 2016. **No** se calculó ninguna transición ponderada, no se modificó ningún archivo de `intervals/` ni `tables/`, y no se tocó el notebook. Documentación actualizada mínimamente: este plan, un párrafo y una celda de tabla en [INTERVALS.md](INTERVALS.md), dos filas en [_elsoc/README.md](../../_elsoc/README.md) y una entrada en el handoff canónico.
