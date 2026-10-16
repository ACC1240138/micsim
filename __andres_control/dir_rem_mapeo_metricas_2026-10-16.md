# DIR (alcohol, tabaco y otras drogas): celdas REM que alimentan las métricas

16-oct-2026, v7 (el denominador pasa a ser la población inscrita en APS y validada por FONASA, tramos A a D, a diciembre de 2023, como define DIPRES la población del programa; la población del modelo sigue siendo 15 a 64 años; reemplaza v1 a v6). Base: Serie A 2019 a 2025 y Serie P 2024 (DEIS), inscritos APS al 31-12-2023, diccionarios `SA_19 V1.3`, `SA_20 V1.2`, `SA_21 V1.2`, `SA_22 V1.1`, `SA_23 V1.4`, `SA_24 V1.1`, `SA_25 V1.5` y `SP_24 V1.1`. Cifras = suma nacional de enero a diciembre, columna `Col01` (ambos sexos). Los totales de todos los códigos de las tablas, en los 7 años, se recalcularon con awk sobre el CSV crudo: 0 diferencias con pandas.

## Lectura rápida

Las dos cifras grandes del programa salen de la Serie A del REM, no de la P.

- Tamizajes: suma de las tres filas de resultado de REM-A03 sección D.1 (bajo riesgo 03500349, riesgoso 03500290 y posible perjudicial o dependencia 03500300).
- Intervención breve (IB): suma de las tres filas de IB de REM-A27 sección G (F desde 2023): alcohol 27300929, tabaco 27300930 y drogas 27300931.

Con esas dos sumas el programa queda entre 1 y 9 % bajo el REM en 2020 a 2024. La única vez que lo supera es la IB de 2021, por 1,9 %. Descarté dos alternativas con sentido: la suma de instrumentos sin CRAFFT-SIA (el programa la supera en 2021 y en 9 de 16 regiones en 2024) y la IB más la referencia asistida (el programa queda 23 a 30 % bajo). La brecha de 1 a 9 % sigue sin explicación comprobada.

1. El REM 2019 respalda las filas. DIPRES cita para 2019 77.294 personas con consumo de riesgo, 27.634 con alto riesgo y 88.585 IB. El REM 2019 trae 83.084, 28.498 y 91.113, así que DIPRES queda 3 a 7 % bajo REM, la misma brecha de los otros años. Probé cortes por edad y por mes y ninguno reproduce las tres cifras a la vez.
2. El zip REM 2025 está incompleto: faltan 615 de los 2.944 establecimientos de 2024. Con esos establecimientos estimados, la IB 2025 da cerca de 88.000 y el programa reporta 88.236. No uses cifras 2025 de ese archivo.
3. Con REM se recalculan bien dos indicadores: el porcentaje de tamizajes con riesgo (los cuatro años comparables) y el porcentaje de tamizados en exámenes preventivos (tres de cuatro años). La variación de IB solo se reproduce dividiendo por el año actual (la fórmula pide el anterior), y así un desplome de 68 % en 2020 se publica como +212 %. El porcentaje de personas con riesgo que recibe IB cambia de denominador según el año; con el de la fórmula da 79 a 83 % todos los años.
4. Los valores 3 %, 11 %, 80 % y 90 % que pegaste son proyecciones del ex ante DIPRES para 2020 a 2022 (columna «con programa»). El 11 % de tamizajes con riesgo no aparece en REM: el máximo es 7,1 % (2019).
5. 2020 y 2021 son años sucios por la pandemia: los tamizajes cayeron 66 % en 2020 respecto de 2019. Los niveles de esos años no sirven para calibrar; los cocientes entre filas sí son estables.
6. Para calibrar la cobertura del modelo (sección 2.3 del documento de parametrización) en su población de 15 a 64 años, el REM 2024 sobre los inscritos APS validados por FONASA a diciembre de 2023 da: AUDIT del EMP en 8,9 % de los inscritos al año (14,5 % con cualquier tamizaje), 6,6 % de positivos entre los tamizados, IB de alcohol para 52 % de los positivos de riesgo y, como máximo, 10 a 33 % de las derivaciones por alcohol ingresando a especialidad. El archivo de inscritos, sin el tramo X, es el denominador clave. Detalle en «Mediciones locales para calibrar la cobertura».

Para el modelo: la IB del programa suma alcohol, tabaco y drogas, y el alcohol es cerca de la mitad (48 % en 2024). Las filas de resultado de A03 no distinguen sustancia. Un módulo solo de alcohol usa la fila 27300929 (39.059 en 2024). En 2024 hay 36 % más tamizajes que en 2019, pero 10 % menos resultados de riesgo o alto riesgo y 10 % menos IB. Hasta que el referente DIR confirme la consulta exacta, conviene no usar 2.537.634 ni 88.236 como parámetros, ni la variación de IB ni la cobertura de IB como metas.

## Dónde están las filas y qué no calza
Los 18 códigos son los mismos de 2020 a 2025. En 2019 son 17, porque CRAFFT-SIA (03600100) no existía. En A27 la sección se llama G de 2019 a 2022 y F de 2023 a 2025. En 2025 se agrega 03710010 (2.738).

Ninguna suma de filas reproduce las cifras del programa al dígito en ningún año. Las dos hipótesis para la brecha, ambas sin probar, son un corte de datos distinto y que el programa cuente solo establecimientos APS (requiere el catálogo DEIS). Las series 2020-2024 del programa dicen «personas», pero REM solo cuenta atenciones; la de 2025 ya dice «atenciones».

## Series nacionales (`Col01`)
`*` = 2025 incompleto (ver más abajo). n/d = la fila no existe ese año.

**A03 D.1** (layout 2025: Col01 total · Col02–03 sexo · Col04–19 edad×sexo · Col20 SENAME · Col21 Mejor Niñez; layout 2019: Col01 total · Col02–03 sexo · Col04–15 edad×sexo en seis tramos, de 10-14 a 65 o más)

| Código | Fila | 2019 | 2020 | 2021 | 2022 | 2023 | 2024 | 2025* |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| 03500346 | AUDIT (EMP/EMPAM) | 1.061.119 | 280.818 | 319.152 | 826.730 | 1.158.003 | 1.380.511 | 1.540.424 |
| 03500347 | AUDIT aplicado | 338.904 | 176.321 | 292.531 | 419.391 | 392.965 | 378.145 | 325.649 |
| 03500402 | ASSIST (EMP/EMPAM) | 68.040 ¹ | 5.124 | 22.441 | 48.520 | 71.752 | 88.420 | 112.007 |
| 03500348 | ASSIST aplicado | 70.641 | 26.170 | 50.307 | 59.122 | 54.438 | 58.327 | 62.099 |
| 03600100 | CRAFFT en control de salud integral del adolescente (SIA) | n/d | 36.136 | 112.829 | 165.529 | 212.512 | 270.970 | 273.525 |
| 03500367 | CRAFFT aplicado | 155.584 | 25.199 | 54.267 | 72.975 | 77.076 | 81.479 | 68.647 |
| 03710010 | CRAFFT aplicado (EMP), solo 2025 | n/d | n/d | n/d | n/d | n/d | n/d | 2.738 |
| | **Σ instrumentos** | 1.694.288 | 549.768 | 851.527 | 1.592.267 | 1.966.746 | 2.257.852 | 2.385.089 |
| 03500349 | Resultado: bajo riesgo | 1.451.681 | 497.256 | 757.904 | 1.417.261 | 1.746.498 | 2.028.374 | 2.170.760 |
| 03500290 | Resultado: riesgoso / intermedio | 83.084 | 27.507 | 39.032 | 59.084 | 68.727 | 72.126 | 68.722 |
| 03500300 | Resultado: posible perjudicial o dependencia | 28.498 | 9.308 | 13.135 | 20.388 | 24.639 | 28.610 | 25.393 |
| | **Σ resultados** | **1.563.263** | **534.071** | **810.071** | **1.496.733** | **1.839.864** | **2.129.110** | **2.264.875** |

¹ En 2019 la fila se llama «ASSIST/CRAFFT (EMP/EMPAM)». Como 03600100 no existía, Σ instrumentos 2019 tiene 5 filas.

**A27 G/F** (layout 2025 y 2019: Col01 total · Col02–07 edad 10-14…65+ · Col08–09 sexo; en IB las columnas de sexo suman hasta 6 % menos que el total, las de edad cuadran)

| Código | Fila | 2019 | 2020 | 2021 | 2022 | 2023 | 2024 | 2025* |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| 27300926/27/28 | Intervención mínima (alcohol + tabaco + drogas) | 1.267.001 | 448.227 | 687.153 | 1.283.754 | 1.579.648 | 1.852.867 | 1.990.442 |
| 27300929 | IB o motivacional (riesgo), alcohol | 44.915 | 15.383 | 20.304 | 32.215 | 38.643 | 39.059 | 33.183 |
| 27300930 | IB, tabaco | 29.101 | 10.329 | 14.938 | 23.351 | 27.294 | 30.993 | 32.778 |
| 27300931 | IB, drogas | 17.097 | 3.450 | 6.869 | 8.430 | 11.156 | 11.686 | 9.744 |
| | **Σ IB** | **91.113** | **29.162** | **42.111** | **63.996** | **77.093** | **81.738** | **75.705** |
| 27300932/33/34 | Intervención referida asistida (perjudicial o dependencia), Σ | 28.362 | 9.912 | 13.404 | 20.331 | 24.551 | 29.530 | 25.215 |
| 27300932 | RA alcohol | 13.524 | 5.528 | 6.619 | 9.935 | 12.033 | 13.611 | 10.711 |

## Qué definición calza con el programa
Cociente programa / REM (1,000 = calce exacto). Producción 2019 del ex ante DIPRES, 2020-2021 del seguimiento DIPRES 2021, 2022-2025 de las tablas del programa.

| Año | Tamizajes programa | / Σ resultados | / Σ instrumentos | / Σ instr. sin CRAFFT-SIA | IB programa | / Σ IB | / (IB + RA) |
|---|---:|---:|---:|---:|---:|---:|---:|
| 2019 | n/d | n/d | n/d | n/d | 88.585 (DIPRES) | 0,972 | 0,741 |
| 2020 | 507.206 | 0,950 | 0,923 | 0,987 | 28.397 | 0,974 | 0,727 |
| 2021 | 802.230 | 0,990 | 0,942 | 1,086 | 42.911 | 1,019 | 0,773 |
| 2022 | 1.367.590 | 0,914 | 0,859 | 0,959 | 59.001 | 0,922 | 0,700 |
| 2023 | 1.750.229 | 0,951 | 0,890 | 0,998 | 74.651 | 0,968 | 0,734 |
| 2024 | 2.005.138 | 0,942 | 0,888 | 1,009 | 78.458 | 0,960 | 0,705 |
| 2025* | 2.537.634 | 1,120 (0,96–0,99 imputado) | 1,064 (0,91–0,93) | 1,202 (1,03–1,06) | 88.236 | 1,166 (1,00 imputado) | 0,874 |

- **Σ resultados** nunca es superada por el programa (0,914–0,990 en 2020–2024), gana por región (tabla siguiente) y es coherente con el indicador de riesgo (numerador y denominador salen de la misma tabla). Σ resultados = Σ instrumentos en 76–77 % de los establecimiento-mes de 2023–2024 (79 % en 2019, sin CRAFFT-SIA), así que incluye CRAFFT-SIA; la diferencia nacional (5–6 %; 8 % en 2019) son aplicaciones sin resultado registrado.
- **Σ instrumentos sin CRAFFT-SIA:** el programa la supera en 2021 (1,086) y en 9 de 16 regiones en 2024 (RM +11 %, Tarapacá +14 %). Como el programa no puede contar más que su fuente (salvo ruido de corte de ±2 %, p. ej. IB 2021 = 1,019), no puede ser su definición; el calce nacional de 2023–2024 es compensación entre regiones.
- Los cocientes de tamizajes (Σ resultados) y de IB se mueven juntos (0,950/0,974; 0,990/1,019; 0,914/0,922; 0,951/0,968; 0,942/0,960), compatible con un mismo corte de datos para ambas cifras. No discrimina entre definiciones de tamizaje.
- Búsqueda de subconjuntos: 511 combinaciones × 3 años dan varias sumas a ±2–3 %, todas sin lógica sustantiva (p. ej. IB alcohol + IB tabaco + RA drogas). Es azar, no evidencia.

## Prueba con las cifras 2019 del ex ante DIPRES
El ex ante cita para 2019, «de acuerdo a los Registros Estadísticos Mensuales»: «el año 2019, fueron 77.294» personas con consumos de riesgo, «el año 2019, fueron 27.634» con consumos de alto riesgo y una IB que pasó «de 18.610 el año 2012 a 88.585 el año 2019». Las tres cifras se confirmaron con una segunda lectura del PDF el 16-oct-2026.

| Cifra 2019 | DIPRES ex ante | REM 2019 | DIPRES / REM |
|---|---:|---:|---:|
| Consumo de riesgo | 77.294 | 83.084 (03500290) | 0,930 |
| Alto riesgo | 27.634 | 28.498 (03500300) | 0,970 |
| IB | 88.585 | 91.113 (27300929 + 30 + 31) | 0,972 |

- Las tres filas calzan en magnitud y DIPRES queda 3 a 7 % bajo REM, la misma brecha del programa en 2020-2024 (0,92–1,02). El mapeo de filas se sostiene; el calce no es al dígito.
- No reproducen las tres cifras a la vez: solo IB de alcohol (44.915), IB + RA (119.475), solo 15 años o más (77.352 / 26.827 / 84.164) y acumulado de enero a noviembre (76.561 / 26.369 / 84.701). Solo 20 años o más queda mucho más lejos (63.774 / 17.839).
- Hipótesis sin probar para la brecha: el ex ante usó un corte anterior a las rectificaciones del archivo público, que trae fecha de junio de 2024.
- 2019 como línea base: Σ resultados 1.563.263 (2020: −66 %; 2021: −48 %; 2022: −4 %; 2023: +18 %; 2024: +36 %) y Σ IB 91.113 (2020: −68 %; 2021: −54 %; 2022: −30 %; 2023: −15 %; 2024: −10 %).

## Distribución regional 2024 (Σ resultados, REM 2024 vs «población beneficiada»)

| Región | Programa | Σ resultados | REM / programa |
|---|---:|---:|---:|
| Arica y Parinacota | 32.480 | 33.110 | 1,019 |
| Tarapacá | 67.116 | 67.915 | 1,012 |
| Antofagasta | 58.594 | 60.295 | 1,029 |
| Atacama | 10.460 | 21.126 | 2,020 |
| Coquimbo | 72.602 | 68.747 | 0,947 |
| Valparaíso | 185.763 | 189.033 | 1,018 |
| O'Higgins | 64.492 | 76.098 | 1,180 |
| Maule | 199.303 | 239.373 | 1,201 |
| Biobío | 217.050 | 226.535 | 1,044 |
| Ñuble | 30.702 | 34.693 | 1,130 |
| La Araucanía | 74.362 | 96.327 | 1,295 |
| Los Ríos | 33.655 | 37.098 | 1,102 |
| Los Lagos | 110.165 | 132.432 | 1,202 |
| Aysén | 11.275 | 11.102 | 0,985 |
| Magallanes | 9.184 | 8.968 | 0,976 |
| Metropolitana | 827.935 | 826.258 | 0,998 |
| **Total** | **2.005.138** | **2.129.110** | **1,062** |

8 de 16 regiones (70 % del total) quedan a ±5 %. El programa supera a Σ resultados en 4 regiones, con máximo +5,6 % (Coquimbo). En Atacama, O'Higgins, Maule, Ñuble, Araucanía, Los Ríos y Los Lagos el programa queda 10–50 % bajo REM (corte parcial o asignación regional distinta; sin probar). No usar esta tabla como meta regional sin revisar.

## Indicadores del programa vs REM
Efectivos 2020–2021: seguimiento DIPRES 2021. Efectivos 2023–2024: informe del programa. Proyecciones ex ante (DIPRES, evaluación ex ante 2021; columnas «2020 situación actual», «2021 y 2022 con programa»): P1 −8 % (2020) y 3 % (2021, 2022); P2 11 %; C3 80 %; C4 90 %. Fuente declarada de los cuatro: REM.

| Indicador | Efectivo programa 2020 · 2021 · 2023 · 2024 | REM (mismos años) | Lectura |
|---|---|---|---|
| Propósito 1: variación % de personas con riesgo/alto riesgo que reciben IB | 212 % · 34 % · 16 % · 18 % | Fórmula escrita con producción del programa: –67,9 % · +51,1 % · +26,5 % · +5,1 % (2020 usa IB 2019 = 88.585 del ex ante). Con el denominador del año t: 212,0 % · 33,8 % · 21,0 % · 4,9 % | 2020 y 2021 reproducen exacto con el denominador del año t: un desplome de –68 % se publica como +212 %. 2023–2024 no se reproducen con ninguna de las dos formas |
| Propósito 2: % tamizajes con riesgo y alto riesgo | 7 % · 7 % · 5,0 % · 5,0 % | (03500290 + 03500300) / Σ resultados: 6,89 % · 6,44 % · 5,07 % · 4,73 % (2019: 7,14 %) | Reproduce a ±0,6 pt. El 11 % ex ante no se observa en 2019–2025 (máximo REM: 7,1 % en 2019) |
| Complementario 3: % tamizados en exámenes preventivos | 57 % · 57 % · 72 % · 77 % | (AUDIT-EMP + ASSIST-EMP + CRAFFT-SIA) / Σ instrumentos: 58,6 % · 53,4 % · 73,3 % · 77,1 %. Solo EMP/EMPAM sobre Σ sin SIA: 55,7 % · 46,2 % · 70,1 % · 73,9 % (2019, sin SIA: 66,6 %) | La variante con SIA calza 2020, 2023 y 2024 (≤ 1,6 pt). En 2021 el programa repite 57 % y REM baja a 53 % (EMP suspendidos por pandemia) |
| Complementario 4: % con riesgo/alto riesgo que reciben IB | 84 % · 77 % · 4 % · 114 % | Σ IB / (riesgoso + perjudicial), lo que dice la fórmula: 79,2 % · 80,7 % · 82,6 % · 81,1 % (2019: 81,7 %). Σ IB / solo riesgoso: 106,0 % · 107,9 % · 112,2 % · 113,3 %. Σ IB / Σ resultados: 5,5 % · 5,2 % · 4,2 % · 3,8 % | El 84 % de 2020 es la línea base 2019 del ex ante (88.585 / (77.294 + 27.634) = 84,4 %), no REM 2020; con REM 2019 la misma cuenta da 81,7 %. 2021: 77 vs 81 %. 2023 coincide con IB / todos los tamizajes y 2024 con IB / solo riesgo. Con la fórmula correcta es ≈ 80 % siempre |

Con el 11 % ex ante, las 104.928 personas en riesgo y alto riesgo de 2019 (77.294 + 27.634) implican ≈ 954.000 tamizajes; REM 2019 tiene 1.563.263 resultados y el riesgo es 7,1 %. Cobertura declarada en el seguimiento: 61 % (2020) y 96 % (2021), población objetivo implícita ≈ 830.000–836.000.

## Calidad de datos 2019–2021
- **2019 (año de referencia):** sin quiebre. Están los doce meses; los establecimientos con tamizaje por mes van de 1.159 (ene) a 1.382 (jun); no hay duplicados ni negativos. Hay 3 celdas `Col01` vacías en filas DIR, contadas como 0 (03500349, establecimiento 107400, ene; 03500346, 115428, oct; 03500367, 200292, sep). Establecimientos distintos: 2.513 en el archivo completo y 1.719 con filas DIR. La celda más grande es 1.936 (bajo riesgo, establecimiento 105303, sep).
- **Pandemia 2020:** Σ instrumentos pasa de 127.022 en enero a 7.810 en abril (–94 %) y termina diciembre en 37.070. Enero–febrero concentran 45 % del año. Los establecimientos con tamizaje por mes bajan de 1.249 (ene) a 387 (abr) y llegan a 838 (dic); en 2021 parten en 823 (ene) y llegan a 1.273 (dic); en 2024 son ≈ 1.500–1.650. Los totales anuales 2020 no son comparables con otros años.
- **Duplicados:** 2020 ninguno; 2021 nueve pares exactos (establecimiento 101404, meses 7, 11 y 12; 18 filas); efecto +20 en Σ resultados (0,002 %), no corregido.
- **Valores faltantes o raros:** 2020 tiene 3 celdas `Col01` vacías en filas DIR (contadas como 0); no hay negativos. Hay 84 (2020) y 88 (2021) valores no numéricos en el archivo completo, ninguno en filas DIR. Celdas muy grandes (p. ej. establecimiento 105325, sep-2021: AUDIT-EMP 1.607, IB 416) son coherentes entre filas, así que parecen campañas y no errores de digitación; se mantuvieron.
- **Qué sí es robusto:** los cocientes entre filas del mismo establecimiento (cascada, abajo) casi no cambian en 2020–2021. Establecimientos distintos en el archivo completo: 2.674 (2020), 2.858 (2021), 2.873 (2022).

## Archivo REM 2025 incompleto
- Establecimientos con alguna fila en Serie A: 2.873 (2022), 2.896 (2023), 2.944 (2024), **2.364 (2025)**. 615 de los de 2024 no aparecen en 2025; 35 son nuevos.
- Se concentran en cinco regiones, por % del volumen 2024 de Σ resultados: Araucanía 54 %, Valparaíso 40 %, Los Ríos 23 %, Los Lagos 18 %, RM 17 %. Las otras 11 regiones: 0 %. Por `IdServicio` (región donde más aparece), % del volumen 2024 que falta: 7 (Valparaíso) 86 %, 13 (RM) 78 %, 33 (Los Lagos) 75 %, 29 y 21 (Araucanía) 59 % y 51 %, 22 (Los Ríos) 23 %.
- Los ausentes aportaron 14–15 % de los tamizajes y de la IB de 2024. Los 2.329 establecimientos presentes en ambos años crecieron +23,8 % en tamizajes y +8,4 % en IB.
- Imputación gruesa: «plano» = los ausentes mantienen su volumen 2024; «crecimiento» = lo escalan por el crecimiento de los continuadores.

| Familia 2025 | Observado | Imputado plano | Imputado con crecimiento | Programa | Programa / imputado |
|---|---:|---:|---:|---:|---:|
| Σ resultados | 2.264.875 | 2.565.466 | 2.637.000 | 2.537.634 | 0,99 – 0,96 |
| Σ instrumentos (7 filas) | 2.385.089 | 2.718.542 | 2.798.162 | 2.537.634 | 0,93 – 0,91 |
| Σ instrumentos sin CRAFFT-SIA | 2.111.564 | 2.394.208 | 2.461.602 | 2.537.634 | 1,06 – 1,03 |
| Σ IB | 75.705 | 87.615 | 88.615 | 88.236 | 1,01 – 1,00 |

Sin imputar, el archivo diría que la IB cayó 7,4 % en 2025 mientras el programa reporta +12,5 %; con la imputación la serie sube 7–8 % (el programa parte de una base 2024 ≈ 4 % bajo la serie). Que el cociente de IB sea ≈ 1,00 en 2025 y 0,92–1,02 en 2020–2024 es compatible con que 2025 sea conteo de atenciones y los años previos «personas»; sin probar.

## Patrones para la microsimulación (cascada riesgo → intervención)
Cocientes entre filas REM, nacional, 2019 a 2025 (2025 incompleto pero los cocientes casi no se afectan):
- Intervención mínima / bajo riesgo: 0,87 · 0,90 · 0,91 · 0,91 · 0,90 · 0,91 · 0,92.
- Σ IB / riesgoso: 1,10 · 1,06 · 1,08 · 1,08 · 1,12 · 1,13 · 1,10.
- Σ RA / perjudicial o dependencia: 1,00 · 1,06 · 1,02 · 1,00 · 1,00 · 1,03 · 0,99. Casi una RA por tamizaje de alto riesgo.
- Σ IB / (riesgoso + perjudicial): 82 · 79 · 81 · 81 · 83 · 81 · 80 %.
- % riesgoso + perjudicial sobre Σ resultados: 7,1 · 6,9 · 6,4 · 5,3 · 5,1 · 4,7 · 4,2 % (2025 incompleto). Baja mientras sube el peso del tamizaje en exámenes preventivos: (EMP + SIA) / Σ instrumentos = 66,6 (2019, solo EMP) · 58,6 · 53,4 · 65,4 · 73,3 · 77,1 · 80,9 %. Hipótesis sin probar: efecto de composición (el tamizaje en EMP detecta menos riesgo que el aplicado en consulta).
- 2024 contra 2019: Σ resultados +36 %, resultados de riesgo y alto riesgo (03500290 + 03500300) –10 %, Σ IB –10 %.
- Los resultados de A03 D.1 no se separan por sustancia: «riesgo por alcohol» no existe en esa tabla; solo A27 distingue alcohol, tabaco y drogas. El alcohol es 49 % de la Σ IB en 2019 y 48 % en 2024.
- Módulo solo alcohol, último año completo (2024): AUDIT total (03500346 + 03500347) = 1.758.656; IB alcohol 39.059; RA alcohol 13.611. No usar 88.236, que mezcla tabaco y drogas.

## Mediciones locales para calibrar la cobertura

Responde a la sección 2.3 del documento «Parametrización Modelo Alcohol APS Chile». Fuentes: REM Serie A 2019 y 2023-2024, Serie P 2024 e inscritos APS validados al 31-12-2023; 2020 a 2022 quedan fuera por la pandemia y 2025 por el archivo incompleto.

Tres puntos del documento no calzan con el REM:
- El EMP no está en el REM-P2, que es la población en control infantil. El número de EMP está en REM-A02 y el AUDIT hecho en el EMP en REM-A03 sección D.1 (fila 03500346).
- El EMP usa el AUDIT completo desde los 15 años (Superintendencia de Salud). El REM no registra AUDIT-C.
- El REM entrega tres resultados: 0-7, 8-15 y 16 o más. No se pueden separar los tramos 16-19 y 20-40 que pide la sección 6 del documento.

### Cobertura basal del AUDIT en el EMP

| | 2019 | 2023 | 2024 |
|---|---:|---:|---:|
| EMP 20-64 años (A02) | 1.205.516 | 1.103.252 | 1.301.302 |
| AUDIT en el EMP, 20-64 (03500346) | 698.203 | 699.176 | 830.745 |
| % de EMP 20-64 con AUDIT | 57,9 % | 63,4 % | 63,8 % |
| EMPAM 65+ (A02) | 874.859 | 884.520 | 984.612 |
| AUDIT en el EMPAM, 65+ | 356.043 | 450.579 | 541.457 |
| % de EMPAM con AUDIT | 40,7 % | 50,9 % | 55,0 % |

**Denominador clave: población inscrita en APS y validada por FONASA al 31-12-2023.** Archivo `Inscritos_APS_2023_12.csv` (DEIS/FONASA; una fila por centro, tramo FONASA, tramo de edad y sexo): 15.051.673 inscritos en 2.057 centros, 13.949.371 de ellos en centros municipales, 960.527 en centros de Servicios de Salud y 141.775 en otras instituciones. Se usan los 14.133.444 con tramo FONASA A, B, C o D. Quedan fuera los 918.229 del tramo X: ese tramo no aparece en la base de beneficiarios FONASA de diciembre de 2023 (16.229.898 personas, solo tramos A a D), así que se tratan como inscritos no validados. Es la definición de DIPRES para el programa: población «inscrita y validada en los registros de Fonasa» (fuente: Registro de Población Inscrita Validada FONASA).

El archivo trae la edad en tramos de 20 años (0-19, 20-39, 40-59, 60-79 y 80 o más), que no coinciden con los grupos del REM; cada tramo se reparte con la proyección INE 2023 por sexo y grupo quinquenal. Repartirlo con la estructura por decenios de los beneficiarios FONASA de diciembre de 2023 cambia los totales en menos de 0,5 % (15-64: +0,49 %; 18-65: +0,15 %; 20-64: −0,07 %), así que los tramos de 20 años no son un problema práctico.

Contraste con el conteo de beneficiarios FONASA inscritos en APS a diciembre de 2022 (base `Beneficiarios-Fonasa-2022.zip`, variable `INSCRITO_APS`, trabajada con Codex: 895.728 de 15-19 años, 8.263.354 de 20-64 y 670.066 de 65-69):

| Edad | Todos los inscritos, dic-2023 | Validados (A-D), dic-2023 | FONASA inscritos en APS, dic-2022 | AUDIT en el EMP 2024 con cada denominador |
|---|---:|---:|---:|---:|
| 15-64 | 10.129.879 | 9.432.037 | 9.159.082 | 8,3 % · 8,9 % · 9,2 % |
| 18-65 | 9.747.774 | 9.079.078 | 8.755.658 | 8,9 % · 9,5 % · 9,9 % |
| 20-64 | 9.243.785 | 8.600.547 | 8.263.354 | 9,0 % · 9,7 % · 10,1 % |

- Validados y FONASA 2022 son el mismo concepto con un año de diferencia: quedan a 3 a 4 % de distancia, del orden de lo que creció FONASA en 2023 (sumó 380 mil personas en 2022 y proyectaba cerca de un millón en dos años al cierre de 2023). Los inscritos con edad sin información también calzan: 2.645 validados en diciembre de 2023 y 2.314 en el conteo de 2022.
- Para el REM 2024 se usa diciembre de 2023. El conteo de diciembre de 2022 sirve para el REM 2023.
- Pasar de todos los inscritos a los validados sube las coberturas por población en 7 %: 0,6 a 0,7 puntos en el AUDIT del EMP y cerca de 1 punto en EMP y en tamizaje total. Positividad y entrega de IB no cambian, porque no usan población.

**Población del modelo: 15 a 64 años**, según el plan de trabajo del 17-sep (entradas a los 15, salidas después de los 64). También se calcula 18 a 65, repartiendo en partes iguales las edades dentro de los quinquenios 15-19 y 65-69 del REM.

| Edad | Inscritos | EMP | AUDIT en el EMP | Cualquier AUDIT | Cualquier tamizaje | Positivos | IB de alcohol |
|---|---:|---:|---:|---:|---:|---:|---:|
| 15-19 | 831.489 | 2,4 % | 1,0 % | 1,0 % | 18,5 % | 11,03 % | 59,0 % |
| 20-24 | 917.087 | 18,0 % | 11,8 % | 14,8 % | 16,4 % | 5,50 % | 55,9 % |
| 25-44 | 4.234.559 | 16,6 % | 10,5 % | 13,2 % | 14,6 % | 6,38 % | 51,3 % |
| 45-64 | 3.448.902 | 12,6 % | 8,1 % | 11,6 % | 12,8 % | 5,76 % | 48,3 % |
| 65+ | 2.192.582 | 44,9 % | 24,7 % | 29,9 % | 31,3 % | 1,72 % | 58,0 % |
| **15-64 (modelo)** | **9.432.037** | **14,0 %** | **8,9 %** | **11,7 %** | **14,5 %** | **6,59 %** | **52,0 %** |
| 18-65 (aprox.) | 9.079.078 | 15,0 % | 9,5 % | 12,5 % | 14,5 % | 6,17 % | 51,4 % |
| 20-64 | 8.600.547 | 15,1 % | 9,7 % | 12,7 % | 14,1 % | 6,05 % | 50,8 % |

EMP, AUDIT y tamizaje son porcentaje de los inscritos validados (REM 2024 sobre inscritos validados a diciembre de 2023). Cualquier tamizaje suma AUDIT, ASSIST y CRAFFT. Positivos es el porcentaje de los tamizados con 8 puntos o más; IB de alcohol, las IB por cada resultado de riesgo (8-15). En 15-19 el instrumento es casi siempre CRAFFT, por eso el AUDIT es bajo y el tamizaje total no. En 18-65, la IB y la referencia de los 65 años toman la parte del grupo 65-69 en los resultados de 65 o más, porque A27 no separa ese grupo.

Para el modelo (15 a 64 años), la probabilidad anual de recibir AUDIT en el EMP es 8,9 %, con cualquier AUDIT 11,7 % y con cualquier instrumento 14,5 %, suponiendo que nadie se tamiza dos veces en el año. Con todos los inscritos, incluido el tramo X, serían 8,3; 10,9 y 13,5 %. A02 y A03 también traen sexo, y el archivo de inscritos trae sexo, centro, comuna y servicio de salud, así que se puede desagregar con los códigos del anexo.

Resultados del tamizaje en adultos (filas de resultado de A03 D.1; entre 20 y 64 años, 90 % de los instrumentos son AUDIT y el resto ASSIST):

| | 2019 | 2024 |
|---|---:|---:|
| Tamizajes con resultado, 20-64 | 971.186 | 1.149.368 |
| Bajo riesgo (0-7) | 92,55 % | 93,95 % |
| Riesgo (8-15) | 5,78 % | 4,49 % |
| Perjudicial o dependencia (16+) | 1,67 % | 1,56 % |
| 65+: riesgo / 16+ | 1,81 % / 0,39 % | 1,35 % / 0,37 % |

- La positividad del REM en adultos (6 % en 2024) es cerca de un tercio del 16,6 % del ensayo de Barticevic y queda bajo el rango de 12 a 23 % del documento. Calibrar con el REM achica la cohorte en riesgo.
- El grupo 16+ es 26 % de los positivos de 20 a 64 años en 2024 (22 % en 2019). El documento usa 16,3 % (Cowell).
- Entrega de IB: 26.233 IB de alcohol en 20 a 64 años contra 51.612 resultados de riesgo, 51 % en 2024 (56 % en 2019). La referencia asistida de alcohol cubre 51 % de los resultados 16+ (57 % en 2019). El documento usa 69,8 % (Cowell). Como 10 % de los tamizajes de ese tramo son ASSIST, la entrega real para alcohol puede ser algo mayor.

### Capacidad de APS para absorber la IB

Quién hizo los 2.306.290 EMP de 2024 (A02 sección A): enfermera 54,9 %, TENS 17,0 %, nutricionista 11,2 %, otro profesional 9,9 %, matrona 5,8 % y médico 1,3 %. Los TENS ya hacen uno de cada seis EMP (14,9 % en 2019).

La guía MINSAL de intervenciones breves (2011) da 5 a 10 minutos para la intervención mínima, 15 a 30 minutos para la IB (hasta cuatro sesiones) y 15 a 30 minutos para la derivación asistida. El documento usa 5 a 15 minutos, que es la duración de los ensayos.

Horas al año que implica el REM 2024 con los tiempos de la guía:
- 39.059 IB de alcohol: 9.800 a 19.500 horas.
- 13.611 referencias asistidas de alcohol: 3.400 a 6.800 horas.
- 1.605.270 intervenciones mínimas de alcohol: 133.800 a 267.500 horas. El REM no registra cuánto duran; si en la práctica son consejos de menos de un minuto, So et al. (2025) no les encuentran efecto.

Escenario de techo: AUDIT anual para todos los inscritos validados de 15 a 64 años con la positividad del REM 2024 (4,68 % en riesgo) produce 441.000 IB, es decir 110.400 a 220.700 horas. Con 1.500 horas clínicas al año por jornada de 44 horas (supuesto), son 74 a 147 jornadas en todo el país, o 0,03 a 0,07 jornadas por cada uno de los 2.151 establecimientos con EMP. Con 16,6 % de positivos serían 261 a 522 jornadas.

En el agregado nacional la IB suma pocas horas, así que el límite probable está en el tiempo de cada cupo de EMP y en la agenda de cada CESFAM. El REM no trae horas disponibles. Para medirlas se necesita la programación anual de cada establecimiento (horas por estamento y actividad, que consolida el Servicio de Salud) y la dotación APS de cada comuna (Ley 19.378).

### Brecha de absorción en especialidad (COSAM)

Sin el catálogo DEIS, los establecimientos se clasificaron así: APS si registra EMP; especialidad si no registra EMP y tiene consultas nuevas de salud mental de especialidad (A06) o psiquiatría (A07). En 2024 hay 2.151 de APS y 187 de especialidad (COSAM, hospitales y otros centros).

| 2024 | Cifra | Fuente REM |
|---|---:|---|
| Referencias asistidas por alcohol (AUDIT 16+), desde APS | 13.611 | A27, 27300932 |
| Ingresos a salud mental de especialidad por alcohol | 1.303 | A05 N, 09600297 + 09600298 |
| Ingresos de especialidad por «drogas y alcohol» | 3.192 | A05 N, 05990036 |
| Ingresos a salud mental de APS por alcohol | 5.791 | A05 N, 09600297 + 09600298 |
| En control en especialidad por alcohol, diciembre | 3.889 (+6.559 drogas y alcohol) | P6 B.1, 151 establecimientos |
| En control en APS por alcohol, diciembre | 15.482 (+8.379 drogas y alcohol) | P6 A.1 |
| Consultas nuevas de psiquiatría adulto, 15+ | 43.078 (22.616 derivadas de APS) | A07, 07021900 |

- Techo de absorción: aunque todos los ingresos de especialidad por alcohol vinieran de esas derivaciones, la especialidad recibiría a lo más 9,6 % de ellas, o 33 % si se suman los ingresos por drogas y alcohol. En 2019 el techo con solo alcohol era 15,9 %. Así, al menos dos de cada tres derivaciones por alcohol no aparecen como ingreso a especialidad de la red pública ese año. Una parte entra al programa de salud mental de APS y otra puede ir a centros SENDA que no reportan REM.
- Las referencias asistidas cuentan atenciones y los ingresos cuentan personas, así que el cociente mezcla unidades.
- Oferta SENDA para adultos, todas las sustancias y prestadores públicos y privados: población objetivo de 19.409 personas por año en 2020 a 2023 y 19.784 tratados en 2019, frente a 109.503 personas con consumo problemático dispuestas a tratarse (ENPG 2018). DIPRES calcula una brecha de 90.542.
- Los adultos no tienen garantía GES de oportunidad por alcohol. El GES 53 cubre a menores de 20 años, con 10 días desde la confirmación diagnóstica.

Para el modelo, la probabilidad de ingresar a especialidad después de una derivación por AUDIT 16+ es como máximo 0,10 al año con los códigos de alcohol y 0,33 si se incluyen drogas y alcohol. Para la tasa real hacen falta datos vinculados por persona; SISTRAT registra el origen de la derivación y las fechas de cada tratamiento SENDA.

## Pendiente
1. Bajar de DEIS la Serie A 2025 completa (o su versión más reciente) y repetir los cálculos; verificar que traiga ≈ 2.900 establecimientos. Desde el sandbox DEIS responde 403.
2. Probar la hipótesis «solo APS»: filtrar por tipo de establecimiento con el catálogo DEIS y ver si explica el 1–9 % bajo la serie pública (y la brecha de 3–7 % de 2019).
3. Manual REM Serie A 2025-26 (V1.3), A03 sección D.1 (p. 65): definición de «EMP/EMPAM» vs «aplicado». No se pudo leer (la lectura web corta a ~100 mil caracteres).
4. Pedir al referente DIR (MINSAL) la consulta exacta detrás de 2.537.634, 88.236 y la serie 2020–2024, y si «personas» es un conteo único. Hasta entonces no usar 2.537.634 ni 88.236 como parámetros, ni los indicadores P1 y C4 como metas.
5. No revisado: denominadores de EMP en otras secciones de la Serie A para C3; años anteriores a 2019 (la Serie A 2018 serviría como segundo año limpio); las entradas exactas de P1 en 2023 y 2024 (16 % y 18 %); el tamizaje 2019 del programa (no hay fuente).
6. Inscritos validados a diciembre de 2024, para emparejar con REM 2025. La edad simple ya no es prioridad: repartir los tramos de 20 años con la estructura de FONASA en vez de la del INE mueve los totales menos de 0,5 %.
7. Programación anual de horas por estamento y actividad (Servicios de Salud) y dotación APS por comuna, para medir los minutos disponibles para IB.
8. SISTRAT: origen de la derivación desde APS, días hasta el ingreso y proporción de derivados que ingresa. Catálogo DEIS de establecimientos para separar COSAM de hospitales.

## Código (vectores de códigos)
```r
.t0 <- Sys.time()
# REM-A03 D.1 and REM-A27 G/F rows used for DIR; read CodigoPrestacion as character (leading zeros)
# 2019 has 17 of these codes: 03600100 and 03710010 do not exist, and 03500402 is labelled ASSIST/CRAFFT (EMP/EMPAM)
rem_dir <- c(
  tam_audit_emp = "03500346", tam_audit = "03500347", tam_assist_emp = "03500402", tam_assist = "03500348",
  tam_crafft_sia = "03600100", tam_crafft_emp = "03710010", tam_crafft = "03500367",
  res_bajo = "03500349", res_riesgo = "03500290", res_perj = "03500300",
  imin_alc = "27300926", imin_tab = "27300927", imin_dro = "27300928",
  ib_alc = "27300929", ib_tab = "27300930", ib_dro = "27300931",
  ra_alc = "27300932", ra_tab = "27300933", ra_dro = "27300934"
)
# Families that reproduce the DIR figures (see tables above); tam_res is the recommended screening count
dir_fam <- list(
  tam_res     = unname(rem_dir[c("res_bajo", "res_riesgo", "res_perj")]),
  tam_riesgo  = unname(rem_dir[c("res_riesgo", "res_perj")]),
  tam_instr   = unname(rem_dir[grepl("^tam_", names(rem_dir))]),   # upper bound, about 6% above tam_res
  ib          = unname(rem_dir[c("ib_alc", "ib_tab", "ib_dro")]),
  ra          = unname(rem_dir[c("ra_alc", "ra_tab", "ra_dro")])
)
message(sprintf("Elapsed: %.2f min", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
```

```r
.t0 <- Sys.time()
# Rows used for the local coverage measurements (EMP, alcohol mental-health intakes, population in control, psychiatry)
rem_cal <- list(
  emp_by_prof   = c(medico = "03030101", enfermera = "03030102", matrona = "03030103", nutricionista = "03030104",
                    otro_prof = "03030350", tens = "03030110"),             # REM-A02 section A, Col01
  emp_by_age    = c("03030330", "03030340", "03030120", "03030130"),        # REM-A02 section B; Col04-Col31 = 14 age bands x sex
  mh_in_alc     = c(old = "06901500", perj = "09600297", dep = "09600298"), # REM-A05 section N; old code used until 2022
  mh_in_alc_drg = c(old_poly = "06901700", new = "05990036"),               # policonsumo until 2022, drogas y alcohol from 2023
  p6_alc        = c(aps_perj = "P6241110", aps_dep = "P6241111", aps_mix = "P6241114",
                    esp_perj = "P6241117", esp_dep = "P6241118", esp_mix = "P6241121"), # REM-P6 2024, June and December cuts
  psiq_adulto   = "07021900"                                                # REM-A07; new 15+ from APS = Col27 (Col28 in 2019)
)
message(sprintf("Elapsed: %.2f min", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
```

```r
.t0 <- Sys.time()
# Key denominator: APS inscribed population at 2023-12-31 (latin1; one row per centre x FONASA tramo x 20-year age band x sex)
insc <- readr::read_csv("Inscritos_APS_2023_12.csv", locale = readr::locale(encoding = "latin1"), show_col_types = FALSE)
stopifnot(sum(insc$TOTAL_INSCRITOS) == 15051673)  # national total in the December 2023 file
# Tramo X = inscribed without a FONASA tramo (absent from the FONASA beneficiary base); DIPRES counts validated inscribed only
insc_band_sex <- insc |>
  dplyr::filter(TRAMO != "X") |>
  dplyr::group_by(EDAD_TRAMO, SEXO) |>
  dplyr::summarise(inscritos = sum(TOTAL_INSCRITOS), .groups = "drop")
stopifnot(sum(insc_band_sex$inscritos) == 14133444)  # validated inscribed, tramos A-D
message(sprintf("Elapsed: %.2f min", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
```

Fuentes: DIPRES, [Programa DIR APS Alcohol, Tabaco y otras Drogas, evaluación ex ante 2021](https://www.dipres.gob.cl/597/articles-212526_doc_pdf1.pdf) (proyecciones 2020–2022 y cifras 2019, citadas textualmente) y [seguimiento 2021](https://www.dipres.gob.cl/597/articles-275874_doc_pdf.pdf) (efectivos y producción 2020–2021). Datos: DEIS, REM Serie A 2019–2025 (archivos aportados por el usuario; el de 2019 trae fecha de junio de 2024).

Panel con estas cifras: artefacto «Cascada alcohol APS 2024» (https://claude.ai/artifact/L4VA3QQNrWYvttKpBaif9a).

Fuentes de las mediciones locales: población inscrita en APS al 31-12-2023 (`Inscritos_APS_2023_12.csv`, aportado por el usuario); [DIPRES, evaluación ex ante del programa DIR](https://www.dipres.gob.cl/597/articles-212526_doc_pdf1.pdf) (población potencial «inscrita y validada en los registros de Fonasa»); beneficiarios FONASA a diciembre de 2023 (`Beneficiarios 2023.csv` de [datos abiertos FONASA](https://datosabiertos.fonasa.cl/dimensiones-beneficiarios/), copia en [bastianolea/fonasa_beneficiarios](https://github.com/bastianolea/fonasa_beneficiarios), commit 54b69d6); beneficiarios FONASA inscritos en APS a diciembre de 2022 (`Beneficiarios-Fonasa-2022.zip`, conteo hecho con Codex, no revisado aquí); [Diario Financiero, 21-nov-2023](https://www.df.cl/empresas/salud/fonasa-sumara-un-millon-de-beneficiarios-en-dos-anos-al-cierre-de-2023-y) (crecimiento de FONASA); [INE, proyecciones de población](https://www.ine.gob.cl/estadisticas/sociales/demografia-y-vitales/proyecciones-de-poblacion) 2023 por grupo quinquenal y sexo, cifras tomadas de [telencuestas.com](https://telencuestas.com/censos-de-poblacion/chile/2023); [Superintendencia de Salud, examen de medicina preventiva](https://www.superdesalud.gob.cl/examen-de-medicina-preventiva/) (AUDIT desde 15 años); [MINSAL 2011, guía de intervenciones breves](https://diprece.minsal.cl/wrdprss_minsal/wp-content/uploads/2016/02/5.-MINSAL_2011_-Intervenciones-breves-alcohol.pdf) (tiempos); [DIPRES, programa de tratamiento para población adulta de SENDA](http://www.dipres.gob.cl/597/articles-212495_doc_pdf1.pdf) (población objetivo y brecha); [Superintendencia de Salud, GES 53](https://www.superdesalud.gob.cl/app/uploads/2024/03/articles-18832_archivo_fuente.pdf). REM Serie P 2024 aportada por el usuario.
