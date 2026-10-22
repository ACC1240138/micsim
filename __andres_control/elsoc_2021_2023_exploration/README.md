# ELSOC 2021→2023: exploración de persistencia y cambios

**Ampliación disponible: tres intervalos.** El [análisis comparativo 2016→2018, 2018→2021 y 2021→2023](INTERVALS.md) reutiliza íntegramente las estimaciones de este informe y añade dos pares. [Notebook nuevo](../elsoc_transiciones_2016_2023.ipynb) · [HTML en la raíz](../../elsoc_transiciones_2016_2023.html) · [tabla comparativa](intervals/interval_comparison.csv). N S09: 1.888 / 2.261 / 1.796; N S10: 438 / 631 / 502. Se repite estabilidad global S09 próxima al 70%, pero cambia la dirección de frecuencia. Las duraciones medianas son 2,026 / 2,423 / 2,930 años; no son matrices bienales uniformes ni anuales. Los párrafos siguientes conservan el informe original del último par.

Actualizado el 20-10-2026. **El enlace es analizable: 1.796 pares S09 y 502 pares S10**, entre participantes de 18–65 años en 2021, después de los controles descritos abajo. Son cambios entre entrevistas separadas por aproximadamente **2,93 años reales**, no transiciones anuales. Resultados sin ponderar, condicionados a reentrevistados; no constituyen validación del motor EPS.

El 71,0% conserva su respuesta de regularidad. Entre regulares en ambos extremos con frecuencia válida, 32,3% conserva categoría, 32,1% aumenta y 35,7% disminuye. El cambio pareado de regularidad es −1,11 puntos porcentuales (intervalo exploratorio del 95%: −3,60 a +1,26). No identifica un descenso poblacional concluyente.

[Resultados y tablas legibles](RESULTS.md) · [mapa documental completo ELSOC/EPS/TSM](../../_elsoc/README.md) · [script reproducible](analysis.R). Se conservan motores, notebooks y microdatos originales. Esta carpeta solo añade código independiente, documentación y agregados.

## Evidencia, archivos y reproducción

Se leyó en su ubicación original `../../../ELSOC/ELSOC_Wide_2016_2023.sav`: 4.447 registros con `idencuesta` único; MD5 `dac64998f382fc99a5688ee8b5947db3`. No se exportaron filas individuales. Los conteos de este informe son **cálculos de esta entrega**, no tamaños oficiales de terreno. Los 2.928 registros M1 del archivo no deben confundirse con las 2.927 entrevistas iniciales publicadas: una fila del combinado no demuestra participación inicial.

Fuentes documentales oficiales utilizadas junto al README previo:

| Fuente | Uso y alcance |
|---|---|
| [Repositorio manual-elsoc](https://github.com/elsoc-coes/manual-elsoc/), commit [edd00962c2e7df86ccf90f28bf9fc7fade186b37](https://github.com/elsoc-coes/manual-elsoc/commit/edd00962c2e7df86ccf90f28bf9fc7fade186b37) | Versión fijada del mapa documental. |
| [Listado global 2023](https://github.com/elsoc-coes/manual-elsoc/blob/edd00962c2e7df86ccf90f28bf9fc7fade186b37/inputs/0A_Listado_Variables_Global_ELSOC_v2023.xlsx), hoja `2_Items_Total` | Disponibilidad, definiciones y metadatos, cotejados con CSV local. |
| [Cuestionario 2023 v18](https://github.com/elsoc-coes/manual-elsoc/blob/edd00962c2e7df86ccf90f28bf9fc7fade186b37/inputs/cuestionario_2023_v18.xlsx), hojas `seguimiento_capi_M1/M2` | Preguntas, códigos y rutas CAPI de ambas muestras. No prueba cobertura CATI. |
| [2021 M1 llamado A](https://coes.cl/wp-content/uploads/2025/08/5_Cuestionario_Ola_5_Muestra_Original_llamado_A.pdf), p.7; [M2 llamado A](https://coes.cl/wp-content/uploads/2025/08/5_Cuestionario_Ola_5_Muestra_Refresco_llamado_A.pdf), pp.10–11 | Ítems de salud repetidos y administración telefónica 2021; llamados B y fuentes restantes en el mapa completo. |
| [Manual metodológico](https://github.com/elsoc-coes/manual-elsoc/blob/edd00962c2e7df86ccf90f28bf9fc7fade186b37/manual-metodologico-elsoc-english.Rmd) | Muestras, modalidades, construcción de edad y diseño. |
| [Informe de ponderadores longitudinales](https://pondedradores-long-elsoc.netlify.app/) | Documento de marzo de 2023, construcción hasta 2022; no acredita por sí solo los pesos w07 del SAV. |

Desde la raíz de MiCSim: `Rscript __andres_control/elsoc_2021_2023_exploration/analysis.R`. Usa renv existente y lee `_elsoc/elsoc_wide_2016_2023.tar.xz.enc` mediante `acc_data()`, descifrando en `tempdir()`; requiere `ACC_DATA_KEY` configurada localmente. La lectura externa inicial fue reemplazada por esta copia interna idéntica por MD5; los agregados originales se conservan. Requiere los paquetes ya disponibles `haven` y `tidyselect`. No descarga datos ni instala paquetes. La `.Rprofile` es la copia del stub del proyecto.

Se ejecutó el análisis completo sobre el SAV: comprobaciones de unicidad, variables requeridas, códigos, participación, saltos, denominadores y suma de filas de las matrices aprobadas. Semilla 20231021, 1.999 réplicas exploratorias. [Proveniencia](tables/provenance.csv), [sesión R](tables/session_info.txt), [inventario de variables](tables/variable_inventory.csv), [etiquetas originales](tables/value_labels.csv). La ejecución avisó que Windows no reconoce la configuración regional `C.UTF-8`; el informe se escribió y verificó como UTF-8 sin caracteres de control.

## Preguntas, códigos, universo y cobertura comprobada

| Ítem y ola | Variable original y pregunta | Referencia, códigos y universo | Decisión operativa |
|---|---|---|---|
| S09 2021 | `s09_w05`: ¿Consume usted regularmente bebidas alcohólicas como cerveza, vino, pisco u otros licores? | Sin ventana explícita; 1 sí, 2 no. M1 y M2; pregunta inicial del bloque. | Conservar 1/2 como regular/no regular; no etiquetar 2 como abstinencia. |
| S09 2023 | `s09_w07`: misma pregunta | Mismos códigos; documentada en CAPI M1/M2 y respuestas presentes en ambas muestras del SAV. | Comparable con S09 2021 en contenido; posible efecto de modo sin resolver. |
| S10 2021 | `s10_w05`: En el último mes, ¿cuántos días a la semana consumió alguna bebida alcohólica? | Solo S09=1. 1 menos de un día; 2 un día; 3 dos; 4 tres; 5 cuatro; 6 cinco; 7 seis; 8 siete. | Categoría ordinal original 1–8. Menos de un día no es cero días. |
| S10 2023 | `s10_w07`: misma pregunta | Misma referencia y categorías, CAPI M1/M2. La base no contiene frecuencia válida con S09=2. | Matriz condicionada a S09=1 en ambos extremos; no representa a todos los consumidores ni a todo el panel. |
| S15 2023 | `s15_w07`: Pensando en la última vez que usted consumió bebidas alcohólicas, ¿cuántos vasos o copas tomó aproximadamente? | Conteo abierto de última ocasión sin fecha, tamaño ni graduación; M1. M2: todos ausentes. | Descripción separada, sin imputar cantidad habitual ni gramos/día. Universo observado más amplio que S09=1; discrepancia con ruta documental. |

S09=2/−888/−999 salta S10 hacia S11_01 en los instrumentos revisados. Los códigos especiales documentados son −999 no responde, −888 no sabe, −777 error técnico y −666 encuesta incompleta. Se conservan por separado en las tablas originales y se excluyen de cada par clasificable, sin recodificarlos como respuestas sustantivas. El salto no explicita −777/−666. Ausencia de entrevista, falta de ítem y omisión estructural son situaciones distintas.

| Ola / muestra | Entrevistados | S09=1 | S09=2 | S09 especial | S10 válido | S10 especial | S10 ausente por sistema |
|---|---:|---:|---:|---:|---:|---:|---:|
| 2021 M1 | 1.739 | 728 | 1.010 | 1 | 726 | 2 | 1.011 |
| 2021 M2 | 1.001 | 417 | 583 | 1 | 417 | 0 | 584 |
| 2023 M1 | 1.737 | 647 | 1.084 | 6 | 647 | 0 | 1.090 |
| 2023 M2 | 989 | 428 | 560 | 1 | 427 | 1 | 561 |

Esta tabla usa todas las edades para auditar cobertura; no es el denominador de las transiciones. [Códigos y frecuencias](tables/raw_code_counts.csv), [cruce de rutas](tables/s10_routing.csv). S10 ausente entre no regulares es omisión estructural; entre S09 desconocido no permite asignar regularidad ni frecuencia. No hay alcohol comparable en 2022: `ola_w06` solo ayuda a reconstruir seguimiento.

**Muestra no es modalidad.** `muestra=1` identifica original M1 y `muestra=2` refresco M2. 2021 fue CATI en dos llamados; 2023 tiene documentación de modo mixto. No se identificó una variable individual inequívoca CAPI/CATI en nombres y etiquetas del SAV. Consentimiento telefónico o experiencia CAPI del encuestador no son el modo individual. Se verifica respuesta válida por muestra; queda pendiente separar modalidades y confirmar instrumento CATI, incluidas su ruta y cobertura S09/S10. La fecha de entrevista tampoco garantiza ser la fecha del bloque de alcohol del llamado A.

## Enlace, edad, sexo y pérdida de seguimiento

El combinado ya vincula por `idencuesta`; se comprobó que no hay duplicados ni identificadores faltantes. `ola_w05/w06/w07` usa **1 participante y 2 ausente**, no el número de ola. Su presencia coincide con disponer de `cuestion_completo_wXX`. `tipo_atricion` distingue sin/con atrición, pero no reemplaza la trayectoria por ola ni documenta causas de salida.

| Etapa | Total | M1 | M2 |
|---|---:|---:|---:|
| Participantes 2021 de 18–65 años | 2.300 | 1.422 | 878 |
| Reentrevistados 2023 | 1.815 | 1.142 | 673 |
| Sexo válido y coincidente | 1.813 | 1.141 | 672 |
| Fechas válidas y edad de destino plausible: enlaces primarios | 1.802 | 1.132 | 670 |
| S09 clasificable en ambos extremos | 1.796 | 1.127 | 669 |
| Regulares en ambos extremos | 504 | 315 | 189 |
| S10 válido en ambos extremos | 502 | 314 | 188 |

Se pierde reentrevista de **485/2.300=21,1%**; M1 280/1.422=19,7%, M2 205/878=23,3%. Es no reentrevista entre estos extremos y este dominio, no una tasa oficial de abandono definitivo. La retención fue 78,3% entre regulares iniciales y 79,5% entre no regulares. No implica ausencia de selección en otras variables. Hay **174 enlaces primarios con ausencia w06 y retorno w07**: 99 M1 y 75 M2. No se dispone aquí de una clasificación validada de fallecimiento, emigración o rechazo permanente; no se atribuyen esas causas a las 485 ausencias.

Filtros: edad basal `m0_edad_w05` entre 18 y 65, sin volver a limitar edad en destino; sexo `m0_sexo_w05/w07` 1 hombre/2 mujer coincidente (dos discordancias excluidas, no prueba de error de identidad); fechas interpretables, ordenadas, origen en 2021 y destino en 2023–2024 (11 descartes adicionales); edad de destino 18–110 válida (sin descartes adicionales). Los seis faltantes S09 y dos faltantes S10 se excluyen solo de su análisis. Se conservan cuestionarios incompletos si tienen respuestas válidas; sensibilidad restringida a completos disponible.

No hay participantes de 18–19 años en el dominio basal de esta entrega: el grupo solicitado 18–29 contiene efectivamente 20–29. No representa todos los adultos jóvenes. Las bandas son 18–29, 30–44, 45–59 y 60–65 al inicio, separadas por sexo.

`fecha_entr_w05`: 29-01-2021 a 12-07-2021; `fecha_entr_w07`: 16-12-2023 a 14-05-2024, con 17 fechas ausentes entre todos los entrevistados w07. Entre los 1.804 reentrevistados elegibles con ambas fechas, antes de excluir dos discordancias de sexo, el intervalo mediano es 2,930 años (rango 2,442–3,253). El nombre «2023» no fija la fecha de observación ni un lapso de dos años.

**Edad pendiente:** en 516/1.802 enlaces primarios, el cambio de edad difiere del tiempo transcurrido en más de 1,05 años. Se comparan edades enteras con tolerancia de cumpleaños; el manual describe nacimiento por mes/año en 2021 y fecha completa desde 2022. No hay evidencia suficiente para corregir edades, suponer edad referida al año nominal o invalidar todos esos IDs. Se conservan marcados; sensibilidad estricta deja 1.286 enlaces, 1.283 S09 y 340 S10. La permanencia S09 cambia de 71,0% a 70,6%; S10 de 32,3% a 34,1%. La estabilidad global no resuelve la clasificación por edad.

[Flujo](tables/sample_flow.csv), [descartes](tables/exclusion_flow.csv), [retención por origen y grupo](tables/retention_by_origin_group.csv), [fechas](tables/field_dates.csv), [coherencia temporal](tables/intervals_and_age_checks.csv), [distribución de edad](tables/age_change_distribution.csv), [sensibilidades](tables/quality_sensitivity.csv).

## Pesos y diseño: decisiones por encuesta

| Fuente | Verificado | Decisión y pendiente |
|---|---|---|
| ELSOC | `ponderador_long_total_w07` existe y es positivo para todos los participantes M1/M2 y los 1.796 pares S09. `ponderador_long_panel_w07` cubre 1.176 M1 y 661 M2 del panel completo; cubre 1.500 pares S09 y omite 296. `ponderador02_w07` también existe. | No reutilizar el CSV antiguo de olas 1–6. Tampoco aplicar automáticamente total w07 al par 2021→2023. Faltan ficha/código de construcción w07 y recomendación para este par, sus muestras y dominio. Resultados principales sin pesos; no se inventan pesos ni se añade IPW. |
| ELSOC: ajuste documentado hasta 2022 | Peso inicial de diseño/no respuesta; participación mediante GEE logístico, celdas de ajuste por cuartiles de predicción dentro de estrato/año, recorte percentiles 5/95, calibración sexo×edad a población urbana INE y normalización por año. | Es antecedente metodológico, no confirmación de aplicación idéntica a w07. El informe recomienda evaluar pesos para combinaciones de olas; un peso de panel completo no es automáticamente peso de dos extremos. No duplicar ajuste por atrición si luego se usa un peso que ya lo incorpora. |
| ELSOC: diseño disponible | `estrato_disenno`, `segmento_disenno` sin faltantes en enlaces; cada segmento pertenece a un estrato. Hay 1.009 segmentos en el combinado, 362 compartidos por M1/M2. Dominio basal: 925 segmentos y seis estratos publicados. | La selección original incluye ciudades como primera etapa; no se recuperó un diseño completo de ciudades para inferencia. No dividir segmentos compartidos por muestra. No se identificaron pesos replicados oficiales. Las réplicas de este análisis son propias. |
| EPS VI/VII/VIII | Pesos transversales `factor_EPS2015`, `factor_XS`, `factor_xs`; panel VII `factor_Panel_2015`, VIII `factor_panel_2002/2004/2015`; diseño VII `cluster_ID/strata_ID`, VIII `cluster_id/strata_id`. Ajustes oficiales de no respuesta/atrición y postestratificación documentados. | Panel2015 de VIII corresponde a la trayectoria 2015–2020–2023, no automáticamente cualquier par. Diseño público VI incompleto en fuentes revisadas. Réplicas JKn del motor son construidas, no pesos replicados oficiales. No se recalculan EPS aquí. |
| TSM R7–R11 | `IdPanel` longitudinal, `IdEncuesta` entrevista, `Entrevistado=1`; `Fact_Exp` por ronda. | Fórmula de no respuesta/atrición y diseño estratos/UPM no verificados en documentación disponible; no llamar longitudinal a `Fact_Exp`. No se identificaron réplicas oficiales. No se recalculan pesos TSM aquí. |

Detalles y fuentes EPS/TSM: [mapa, secciones 5.2–5.3](../../_elsoc/README.md). En ELSOC, la suma de `ponderador_long_total_w07` coincide por separado con los tamaños M1/M2; el tamaño efectivo por variabilidad de ese peso sobre pares S09 sería aproximadamente 299 M1 y 216 M2, sin incorporar conglomeración. Es diagnóstico de concentración, no tamaño de muestra analítico ni justificación para usar el peso. [Cobertura y rangos](tables/weight_coverage.csv); [composición por ola, muestra y dominio](tables/composition_for_weight_choice.csv). La comparación de composiciones no resuelve por sí sola el estimando.

**Incertidumbre disponible:** bootstrap de segmentos completos, estratificado en los seis estratos publicados, con pesos individuales iguales. Se remuestrean los 925 segmentos del dominio basal dentro de estrato; se conserva conjuntamente cada par y las personas M1/M2 de un segmento. Intervalos percentiles 95%, 1.999 réplicas. Aproxima dependencia dentro de segmento, pero no reconstruye la etapa de ciudades ni corrige atrición/selección; puede subestimar dependencia superior. No es inferencia poblacional plenamente ajustada al diseño.

Las tablas marcan origen N<30 y evento/complemento <5; no se ofrece intervalo con menos de diez segmentos, origen vacío o proporción 0/1. Un cero observado no demuestra probabilidad nula. La matriz S10 tiene orígenes pequeños (categorías 5–8: N=22,11,4,25). No se sustituyen intervalos degenerados por falsa precisión. [Diseño de réplicas](tables/bootstrap_design.csv), [matrices con banderas e intervalos](tables/transition_matrices_unweighted.csv).

## Lectura de las matrices y educación

Cada fila de matriz divide por su **N de origen**. S09: 504/774=65,1% de los regulares siguen regulares; 772/1.022=75,5% de los no regulares siguen no regulares. Los otros destinos son 34,9% y 24,5%, respectivamente. No se denominan cesación e inicio de consumo. La tabla global de cambios usa todos los pares: paso a regular 250/1.796 y paso a no regular 270/1.796; son proporciones conjuntas, no las probabilidades condicionales anteriores.

S10 mantiene ocho categorías y solo incluye regulares en ambas mediciones. La selección excluye entradas/salidas de regularidad y no permite afirmar que su distribución describa a los 1.796 pares ni a todos los consumidores. Aumento/disminución es movimiento ordinal entre categorías; no cambio en gramos ni número exacto de días cuando aparece la categoría <1 día. [RESULTS](RESULTS.md) presenta matrices globales, permanencia por sexo×edad con N de origen e intervalos, cambios de frecuencia por grupo y márgenes M1/M2/educación. Las matrices completas por grupo están en el CSV.

Educación basal `m01_w05`: se pregunta por nivel actual si estudia o último nivel completado. Se conserva el código original y se aproxima **nivel completado amplio**: 1 sin estudios, 2 básica incompleta, 3 básica completa y 4 media incompleta → básica o menos; 5 media completa, 6 técnica superior incompleta y 8 universitaria incompleta → media; 7 técnica superior completa, 9 universitaria completa y 10 posgrado → superior. Supone requisitos previos habituales; posgrado no certifica título completado. Pierde años, rama técnica/universitaria y trayectoria actual. Correspondencia H bajo supuestos, no título exacto.

Soporte S09: 513 básica o menos, 771 media, 512 superior; S10: 117, 218, 167. No hay educación desconocida en enlaces primarios. El cruce completo sexo×edad×educación tiene celdas pequeñas/vacías: [soporte conjunto](tables/education_joint_support.csv). Se ofrece educación como margen adicional; no se ajusta un modelo de interacciones. Mujeres 60–65 tienen solo 19 pares S10, marcados como pequeños.

## Mapa operativo de triangulación

D: directamente comparable en contenido; H: armonizable bajo supuestos; N: no comparable como misma medida. La equivalencia de contenido no garantiza igual selección, modo o período entre entrevistas.

| Constructo | Originales por fuente/ola | Definición común y transformación | Pérdida / clasificación |
|---|---|---|---|
| Regularidad repetida | ELSOC `s09_w05/w07` 1/2 | Mantener regular/no regular y desconocido separado. | D entre ítems ELSOC; pendiente efecto CATI/CAPI. No permite abstinencia, historia vitalicia ni consumo anual. |
| Participación en consumo | EPS VI/VII presencial/VIII `f13_1…3`; TSM R7–R10 `e3a1` (R11 respaldada por metadatos) | EPS cualquier sí→sí, tres no→no, restantes desconocido; TSM 1 nunca→no, 2–5→sí. ELSOC no dispone del equivalente. | EPS/TSM H con diferencias de referencia; pérdida de bebida y frecuencia. ELSOC S09 frente a ese estado: N, no debe entrar en la misma matriz. |
| Frecuencia observada | ELSOC `s10_w05/w07`; EPS VI/VII/VIII `f14_1…3`; TSM `e3a1` R7–R11 | ELSOC conservar 1–8; EPS 0=<1 día, 1–7 días por bebida; TSM 2≤1/mes, 3=2–4/mes, 4=2–3/semana, 5≥4/semana. Un contraste ordinal de dirección puede mantenerse dentro de cada fuente. | D dentro de ELSOC con mismo filtro; N como frecuencia total exacta EPS (no sumar días de bebidas). Una banda semanal/no semanal con TSM es H solo asumiendo veces≈días y resolviendo 2–4/mes; no implementada. |
| Cantidad | ELSOC `s15_w07` M1; EPS `f15_1…3` VI/VII/VIII; TSM `e3a2` R7–R11 | Mantener última ocasión, cantidad por bebida y cantidad típica como medidas separadas. | N como cantidad habitual común sin supuestos de ocasión, copa y bebida. No convertir a gramos/día ni a HED. |
| Sexo y edad | ELSOC `m0_sexo_w05/w07`, `m0_edad_w05/w07`; EPS/TSM variables originales detalladas en mapa completo | Sexo registrado 1/2; edad inicial 18–65 y bandas solicitadas, no edad de destino. | H por cobertura y posibles discordancias de edad. ELSOC no contiene 18–19 basales; EPS enlazado también tiene cobertura juvenil incompleta. |
| Educación | ELSOC `m01_w05`; EPS/TSM niveles/cursos y títulos del mapa completo | Aproximación de tres niveles completados, descrita arriba; conservar código y fuente. | H: no aplicar corte por número de código de otra encuesta. No se recodificaron EPS/TSM en esta exploración. |

**Contrastes existentes reutilizados:** se extrajeron únicamente `source=Observed_panel, from=NC, to=NC` de [EPS](../eps_markov_outputs_v2/rank_matching_vs_panel.csv) y [TSM](../tsm_markov_outputs/rank_matching_vs_panel.csv). No se usaron matrices anualizadas/modeladas como observaciones. El archivo EPS dentro de `outputs_v2` contiene ese contraste de la ejecución v1; no se presenta como resultado IPW v2 Super Learner. NC agrupa no consumo declarado, no equivale a no regularidad ni abstinencia vitalicia. Permanencias ponderadas existentes: EPS VI→VII 73,4%, VII→VIII 82,1%; TSM R7→R8 76,4%, R8→R9 77,1%, R9→R10 66,9%, R10→R11 74,9%. Son contexto separado, **no comparaciones de magnitud contra 75,5% ELSOC**: intervalos EPS plurianuales, TSM aproximadamente 4–8 meses y ELSOC cerca de tres años, con diferente medición y ponderación.

Para grupos se reutiliza la columna empírica `observed`, modelo A y destino NC, de [TSM](../tsm_markov_outputs/calibration_by_origin_cell.csv), no la predicción. Agrupa cuatro intervalos, por lo que una persona puede contribuir varias veces; N es soporte de pares, no individuos independientes. N0 significa no consumo sin consumo previo observado en el panel; FD incorpora consumo previo observado. No son historias vitalicias verificadas. [Extracto con N y celdas pequeñas](tables/tsm_observed_group_context.csv).

La señal descriptiva compatible es mayor persistencia de no regularidad entre mujeres mayores en ELSOC (75,4%, 74,4%, 81,5%, 84,6% por banda) y mayor persistencia de no consumo N0 en mujeres mayores en TSM (73,9%, 75,3%, 83,8%, 88,6%). No es un patrón estrictamente monótono en todas las bandas ni una igualdad de estados; los hombres no muestran el mismo gradiente. La persistencia de regularidad ELSOC baja entre mujeres con la edad (65,6%, 59,5%, 53,9%, 48,7%). No hay en las salidas reutilizadas un contraste observado equivalente de regularidad/frecuencia EPS/TSM por grupo que permita comprobar esa dirección como la misma variable. No se fuerza un signo común a partir de volumen o estados modelados. No hay escala común defendida aquí para comparar magnitudes.

## S15: aporte independiente y discrepancia de universo

En M1 2023 hay **1.690 respuestas no negativas de 1.737 entrevistados**: 560 ceros, 1.130 positivas, 47 NS/NR; mediana 1, rango 0–24. Entre S09=2 hay 1.048 respuestas válidas, incluidas **495 positivas**. Entre S09=1 hay 640 válidas, de las cuales seis son cero. M2: 989 ausentes por sistema, ninguna respuesta válida. Son todas las edades, sin imponer el dominio de transiciones.

El orden y salto documental sugerían que S15 se restringía a regulares; **los microdatos contradicen esa inferencia**. No excluir las respuestas de no regulares ni corregirlas a cero. Pedir regla de administración/programación y significado de cero; lo observado no basta para asegurar cómo se preguntó en cada modo. [Auditoría S15](tables/s15_2023_audit.csv).

S15 aporta una distribución de vasos/copas en la última ocasión para M1, sin enlace de cantidad a 2021, donde el ítem no está disponible. Convertirla requeriría conocer volumen por recipiente, bebida/graduación y mezcla, recencia de esa ocasión y su representatividad de ocasiones habituales. Combinarla con S10 además exige modelar el universo de no regulares, la categoría <1 día, ocasiones por día y covariación entre frecuencia/cantidad. Ninguno de esos supuestos se impone ni se implementa gramos/día; tampoco se interpreta un umbral de copas como frecuencia de episodios intensivos.

## Pendientes antes de ponderar, armonizar o usar para calibración

1. Obtener de COES/ELSOC ficha y código de pesos 2016–2023, aclaración total/panel para el par w05→w07 y cobertura M1/M2, edades/calibración/atrición y diseño completo por etapas; confirmar existencia de réplicas oficiales.
2. Obtener modo individual, instrumento/programación CATI 2023 y ruta efectiva S15; aclarar fecha del bloque alcohol de los dos llamados 2021.
3. Resolver construcción de edades y discordancias con fechas; revisar las dos discrepancias de sexo sin asumir error ni corregir identidad automáticamente. Obtener disposiciones de seguimiento para distinguir salidas conocidas de no reentrevista.
4. Si se desea una comparación cuantitativa EPS/TSM, predefinir un estimando observable común y sus supuestos de frecuencia, población y tiempo. No reutilizar S09 como cualquier consumo ni estados de gramos/HED.

La armonización viable ahora es **interna a ELSOC para regularidad y frecuencia ordinal condicionada**, con covariables amplias sujetas a los límites del mapa; aporta triangulación descriptiva de persistencia por grupos. No identifica una matriz anual ni valida los estados de volumen, HED o historia del motor EPS. Si estos datos se usan después para ajustar MiCSim, ese mismo enlace dejará de ser evaluación independiente.
