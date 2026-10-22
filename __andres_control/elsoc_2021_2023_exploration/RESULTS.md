# ELSOC 2021→2023: resultados observados

Generado por `analysis.R`. Resultados no ponderados, condicionados a participantes enlazados. Los intervalos del 95% son exploratorios por segmentos, no inferencia poblacional ni validación del motor. Véase [decisiones y límites](README.md).

## Flujo

| Etapa | All | M1 | M2 |
|---|---|---|---|
| w05_participants | 2740 | 1739 | 1001 |
| w07_participants | 2726 | 1737 |  989 |
| w05_age18_65 | 2300 | 1422 |  878 |
| reinterviewed_w07 | 1815 | 1142 |  673 |
| sex_consistent | 1813 | 1141 |  672 |
| dates_valid_after_sex | 1802 | 1132 |  670 |
| primary_links | 1802 | 1132 |  670 |
| strict_age_consistent_links | 1286 |  851 |  435 |
| s09_classifiable_pairs | 1796 | 1127 |  669 |
| regular_both |  504 |  315 |  189 |
| s10_classifiable_pairs |  502 |  314 |  188 |
| primary_pairs_absent_w06_return_w07 |  174 |   99 |   75 |

Las etapas strict_age y retorno w06 son diagnósticos/subconjuntos, no descartes adicionales del primario. Los participantes w07 incluyen personas fuera del conjunto inicial.

## S09: matriz de regularidad

Cada fila usa su propio N de origen. Código 1=regular; 2=no regular (no significa abstinencia). Celda: n; porcentaje [intervalo].

| Origen | N | Destino_regular | Destino_no_regular |
|---|---|---|---|
| 1 Regular |  774 | 504; 65.1% [61.7%; 68.6%] | 270; 34.9% [31.4%; 38.3%] |
| 2 No regular | 1022 | 250; 24.5% [21.9%; 27.1%] | 772; 75.5% [72.9%; 78.1%] |

## Cambios globales

S09: misma respuesta, paso a regular y paso a no regular divididos por TODOS los pares S09. Las probabilidades condicionadas al origen están en la matriz anterior. S10: solo regulares en ambos extremos y frecuencia válida en ambos.

| Item | Cambio | N | Eventos | Estimacion |
|---|---|---|---|---|
| s09 | same | 1796 | 1276 | 71.0% [68.9%; 73.0%] |
| s09 | entry_regular | 1796 |  250 | 13.9% [12.4%; 15.5%] |
| s09 | exit_regular | 1796 |  270 | 15.0% [13.5%; 16.8%] |
| s10 | same |  502 |  162 | 32.3% [28.3%; 36.2%] |
| s10 | increase |  502 |  161 | 32.1% [28.0%; 36.1%] |
| s10 | decrease |  502 |  179 | 35.7% [31.2%; 39.9%] |

Cambio pareado de proporción regular: -1.11 puntos porcentuales [-3.60; 1.26]; origen 774/1796 y destino 754/1796.

## Sexo × edad inicial: S09

| Grupo | N_regular | Permanencia_regular | N_no_regular | Permanencia_no_regular |
|---|---|---|---|---|
| Men_18-29 |  50 | 78.0% [66.7%; 89.1%] |  45 | 55.6% [40.0%; 70.7%] |
| Men_30-44 | 136 | 72.1% [64.8%; 79.0%] |  66 | 66.7% [55.1%; 78.0%] |
| Men_45-59 | 133 | 74.4% [66.9%; 82.0%] |  94 | 61.7% [52.3%; 71.6%] |
| Men_60-65 |  48 | 72.9% [59.5%; 84.4%] |  50 | 72.0% [59.6%; 84.4%] |
| Women_18-29 |  61 | 65.6% [52.6%; 78.1%] |  69 | 75.4% [64.4%; 85.5%] |
| Women_30-44 | 153 | 59.5% [51.0%; 67.6%] | 227 | 74.4% [69.2%; 79.6%] |
| Women_45-59 | 154 | 53.9% [45.9%; 61.8%] | 341 | 81.5% [77.5%; 85.5%] |
| Women_60-65 |  39 | 48.7% [33.3%; 63.6%] | 130 | 84.6% [78.0%; 90.8%] |

## Sexo × edad inicial: S10 condicionada

| Grupo | N | Igual | Aumento | Disminucion |
|---|---|---|---|---|
| Men_18-29 | 39 | 38.5% [23.9%; 53.7%] | 33.3% [18.2%; 48.4%] | 28.2% [14.6%; 43.2%] |
| Men_30-44 | 98 | 26.5% [17.9%; 35.4%] | 28.6% [19.0%; 38.8%] | 44.9% [34.8%; 54.6%] |
| Men_45-59 | 98 | 28.6% [20.0%; 37.9%] | 35.7% [26.9%; 44.4%] | 35.7% [26.5%; 44.9%] |
| Men_60-65 | 35 | 28.6% [14.3%; 43.2%] | 37.1% [21.4%; 51.9%] | 34.3% [19.2%; 51.5%] |
| Women_18-29 | 40 | 37.5% [23.1%; 54.3%] | 30.0% [15.8%; 44.1%] | 32.5% [16.3%; 50.0%] |
| Women_30-44 | 90 | 34.4% [25.0%; 44.7%] | 33.3% [24.0%; 42.9%] | 32.2% [22.2%; 42.4%] |
| Women_45-59 | 83 | 39.8% [29.1%; 50.6%] | 27.7% [17.9%; 37.3%] | 32.5% [22.9%; 43.8%] |
| Women_60-65 | 19 | 21.1% [5.0%; 41.7%] * | 36.8% [15.4%; 60.0%] * | 42.1% [20.0%; 64.7%] * |

* N de origen <30. Las categorías 18–29 no incluyen personas de 18–19 en esta entrega. No inferir diferencias entre grupos por comparar intervalos marginales.

## S10: matriz completa en categorías originales

1=<1 día/semana; 2=1; 3=2; 4=3; 5=4; 6=5; 7=6; 8=7 días. Celda: n (porcentaje de fila). Sin frecuencia cero imputada. Intervalos y banderas de cada celda: [CSV completo](tables/transition_matrices_unweighted.csv).

| Origen | N | Destino1 | Destino2 | Destino3 | Destino4 | Destino5 | Destino6 | Destino7 | Destino8 |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 115 | 47 (40.9%) | 43 (37.4%) | 18 (15.7%) | 5 (4.3%) | 2 (1.7%) | 0 (0.0%) | 0 (0.0%) | 0 (0.0%) |
| 2 | 175 | 39 (22.3%) | 76 (43.4%) | 38 (21.7%) | 8 (4.6%) | 9 (5.1%) | 1 (0.6%) | 1 (0.6%) | 3 (1.7%) |
| 3 | 101 | 23 (22.8%) | 31 (30.7%) | 26 (25.7%) | 8 (7.9%) | 5 (5.0%) | 2 (2.0%) | 3 (3.0%) | 3 (3.0%) |
| 4 |  49 | 10 (20.4%) | 8 (16.3%) | 13 (26.5%) | 9 (18.4%) | 3 (6.1%) | 4 (8.2%) | 0 (0.0%) | 2 (4.1%) |
| 5 |  22 | 2 (9.1%) | 7 (31.8%) | 7 (31.8%) | 4 (18.2%) | 2 (9.1%) | 0 (0.0%) | 0 (0.0%) | 0 (0.0%) |
| 6 |  11 | 0 (0.0%) | 3 (27.3%) | 2 (18.2%) | 3 (27.3%) | 1 (9.1%) | 0 (0.0%) | 0 (0.0%) | 2 (18.2%) |
| 7 |   4 | 0 (0.0%) | 1 (25.0%) | 0 (0.0%) | 1 (25.0%) | 0 (0.0%) | 1 (25.0%) | 0 (0.0%) | 1 (25.0%) |
| 8 |  25 | 5 (20.0%) | 7 (28.0%) | 5 (20.0%) | 3 (12.0%) | 1 (4.0%) | 2 (8.0%) | 0 (0.0%) | 2 (8.0%) |

## Muestras y educación basal (aproximación)

M1/M2 se muestran por separado; educación se ofrece como margen adicional, no como equivalencia exacta de títulos completados. La tabla conjunta sexo×edad×educación está en [soporte](tables/education_joint_support.csv).

| Grupo | N_S09 | Misma_regularidad | N_S10 | Misma_frecuencia |
|---|---|---|---|---|
| M1 | 1127 | 71.2% [68.6%; 73.7%] | 314 | 31.8% [26.8%; 37.1%] |
| M2 |  669 | 70.9% [67.4%; 74.1%] | 188 | 33.0% [26.4%; 40.3%] |
| Education_Basic_or_less |  513 | 72.7% [69.0%; 76.2%] | 117 | 35.9% [27.6%; 44.6%] |
| Education_Secondary |  771 | 71.2% [68.0%; 74.4%] | 218 | 36.7% [30.1%; 43.6%] |
| Education_Higher |  512 | 69.1% [65.0%; 73.2%] | 167 | 24.0% [17.6%; 30.5%] |
| Education_Unknown |    0 | — |   0 | — |

## Sensibilidad de calidad

| scope | item | event | n | n_event | proportion |
|---|---|---|---|---|---|
| all_linked_no_quality_exclusion | s09 | same | 1809 | 1284 | 0.7097844 |
| all_linked_no_quality_exclusion | s09 | increase | 1809 |  254 | 0.1404091 |
| all_linked_no_quality_exclusion | s09 | decrease | 1809 |  271 | 0.1498065 |
| all_linked_no_quality_exclusion | s10 | same |  506 |  163 | 0.3221344 |
| all_linked_no_quality_exclusion | s10 | increase |  506 |  164 | 0.3241107 |
| all_linked_no_quality_exclusion | s10 | decrease |  506 |  179 | 0.3537549 |
| primary_quality | s09 | same | 1796 | 1276 | 0.7104677 |
| primary_quality | s09 | increase | 1796 |  250 | 0.1391982 |
| primary_quality | s09 | decrease | 1796 |  270 | 0.1503341 |
| primary_quality | s10 | same |  502 |  162 | 0.3227092 |
| primary_quality | s10 | increase |  502 |  161 | 0.3207171 |
| primary_quality | s10 | decrease |  502 |  179 | 0.3565737 |
| strict_age_consistency | s09 | same | 1283 |  906 | 0.7061574 |
| strict_age_consistency | s09 | increase | 1283 |  182 | 0.1418550 |
| strict_age_consistency | s09 | decrease | 1283 |  195 | 0.1519875 |
| strict_age_consistency | s10 | same |  340 |  116 | 0.3411765 |
| strict_age_consistency | s10 | increase |  340 |  103 | 0.3029412 |
| strict_age_consistency | s10 | decrease |  340 |  121 | 0.3558824 |
| primary_complete_questionnaires | s09 | same | 1792 | 1274 | 0.7109375 |
| primary_complete_questionnaires | s09 | increase | 1792 |  248 | 0.1383929 |
| primary_complete_questionnaires | s09 | decrease | 1792 |  270 | 0.1506696 |
| primary_complete_questionnaires | s10 | same |  502 |  162 | 0.3227092 |
| primary_complete_questionnaires | s10 | increase |  502 |  161 | 0.3207171 |
| primary_complete_questionnaires | s10 | decrease |  502 |  179 | 0.3565737 |

## S15: toda la muestra de 2023, sin restricción 18–65

| sample | s09 | n_respondents | n_valid | n_zero | n_positive | n_over30 | n_system_missing | n_special_missing | median | q25 | q75 | max |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| M1 | All | 1737 | 1690 | 560 | 1130 | 0 |   0 | 47 | 1.0 | 0.00 | 2.00 | 24 |
| M1 | 1 |  647 |  640 |   6 |  634 | 0 |   0 |  7 | 2.0 | 1.00 | 3.00 | 20 |
| M1 | 2 | 1084 | 1048 | 553 |  495 | 0 |   0 | 36 | 0.0 | 0.00 | 1.00 | 24 |
| M1 | Missing |    6 |    2 |   1 |    1 | 0 |   0 |  4 | 2.5 | 1.25 | 3.75 |  5 |
| M2 | All |  989 |    0 |   0 |    0 | 0 | 989 |  0 | NA | NA | NA | NA |
| M2 | 1 |  428 |    0 |   0 |    0 | 0 | 428 |  0 | NA | NA | NA | NA |
| M2 | 2 |  560 |    0 |   0 |    0 | 0 | 560 |  0 | NA | NA | NA | NA |
| M2 | Missing |    1 |    0 |   0 |    0 | 0 |   1 |  0 | NA | NA | NA | NA |

## Contexto observado EPS/TSM

Estos porcentajes describen no consumo declarado, NO no regularidad. Difieren intervalos, pesos y selección. No comparar magnitudes con S09 como si fuera la misma medida.

| survey | period | construct | persistence | source |
|---|---|---|---|---|
| EPS | VI_VII | no_declared_use | 0.7339479 | ../eps_markov_outputs_v2/rank_matching_vs_panel.csv |
| EPS | VII_VIII | no_declared_use | 0.8214185 | ../eps_markov_outputs_v2/rank_matching_vs_panel.csv |
| TSM | R7_R8 | no_declared_use | 0.7638746 | ../tsm_markov_outputs/rank_matching_vs_panel.csv |
| TSM | R8_R9 | no_declared_use | 0.7705432 | ../tsm_markov_outputs/rank_matching_vs_panel.csv |
| TSM | R9_R10 | no_declared_use | 0.6689334 | ../tsm_markov_outputs/rank_matching_vs_panel.csv |
| TSM | R10_R11 | no_declared_use | 0.7492368 | ../tsm_markov_outputs/rank_matching_vs_panel.csv |

