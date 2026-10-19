# Guia didactica para leer `bundle/outputs`

Esta guia explica, en lenguaje simple, que significan los archivos generados por el pipeline de Ley Karin x Termometro de Salud Mental.

## 1. Idea central del analisis

La pregunta no es simplemente "subio o bajo la salud mental despues de Ley Karin". La pregunta analitica es:

> Que paso con la salud mental de trabajadores dependientes, que son el grupo cubierto por la Ley Karin, comparados con trabajadores por cuenta propia, que estan en el mercado laboral pero no son el grupo cubierto como dependientes?

El diseno usa panel: sigue personas entre rondas. El tratamiento se fija en R9, antes de la entrada en vigencia operacional de Ley Karin.

Rondas:

| Ronda | Fecha aproximada | Lectura |
| --- | --- | --- |
| R7 | abril 2023 | Pre |
| R8 | diciembre 2023 | Pre |
| R9 | abril 2024 | Basal/pre-vigencia, referencia |
| R10 | noviembre 2024 | Post corto |
| R11 | abril 2025 | Post mas largo |

Grupos principales:

| Grupo | Definicion |
| --- | --- |
| `dependiente` | Asalariados/publico/privado/domestico, cubiertos como trabajadores dependientes |
| `cuenta_propia` | Control primario v0.4 |
| `empleador` | No se usa como control primario porque podria estar expuesto a carga de compliance |
| `cp_empleador` | Control antiguo/legado: cuenta propia + empleadores |
| `sin_ocupacion` | Control secundario/descriptivo |

## 2. Resultado en una frase

El resultado principal no muestra una mejora clara de salud mental atribuible al paquete de reformas 2024/Ley Karin. La estimacion principal para GHQ en R11 es positiva, pero imprecisa y no robusta a multiplicidad:

- Dependientes vs cuenta propia, GHQ R11: `+0.296` puntos, IC95 `[-0.091, +0.683]`.
- P-valor aproximado: `0.134`.
- q-BH minimo de la familia primaria: `0.64`.

Traduccion: hay una senal positiva pequena/moderada en GHQ, pero estadisticamente no es una evidencia fuerte. Despues de corregir por muchos desenlaces/contrastes, no queda una asociacion concluyente.

## 3. Como leer las columnas comunes

Muchas tablas tienen estas columnas:

| Columna | Significado |
| --- | --- |
| `ronda` | Ronda comparada contra R9. Lo mas importante suele ser R10 y R11. |
| `estimate` / `est` | Estimacion del efecto/diferencia. Positivo = mayor puntaje o mayor probabilidad en dependientes vs control. |
| `std.error` / `se` | Error estandar. Mide incertidumbre. |
| `conf.low`, `conf.high` / `lo`, `hi` | Intervalo de confianza 95%. Si cruza 0, no hay evidencia estadistica convencional. |
| `p.value` / `p` | P-valor individual, sin ajuste por multiplicidad salvo que se indique. |
| `q_BH` | P-valor ajustado por Benjamini-Hochberg/FDR. Este importa cuando hay muchos outcomes. |
| `outcome` | Desenlace: GHQ, PHQ, GAD, AUDIT-C, etc. |
| `spec` | Especificacion/modelo usado. |
| `n` | Numero de observaciones/personas usadas en ese contraste. |

Regla rapida:

- `estimate > 0` en GHQ/PHQ/GAD suele significar peor salud mental relativa en dependientes.
- `estimate < 0` suele significar mejor salud mental relativa en dependientes.
- Si el IC95 cruza 0, leer como compatible con aumento, nulo o disminucion.
- Si `q_BH` es grande, no presentar como hallazgo confirmatorio.

## 4. Diccionario de outcomes

| Outcome | Que es | Escala | Lectura |
| --- | --- | --- | --- |
| `ghq` | GHQ-12 bimodal | 0-12 | Mayor = peor malestar psicologico |
| `ghq5` | Caso GHQ | 0/1 | 1 si GHQ >= 5 |
| `ghqL` | GHQ Likert-simetrico construido | 0-36 | Mayor = peor; no vender como GHQ Likert validado estandar |
| `phq` | PHQ-9 sintomas depresivos | 0-27 | Mayor = peor |
| `phq10` | Caso PHQ-9 | 0/1 | 1 si PHQ-9 >= 10 |
| `gad` | GAD-7 ansiedad | 0-21 | Mayor = peor, pero ojo: pre-periodo tiene problema de muestra |
| `gad10` | Caso GAD-7 | 0/1 | 1 si GAD-7 >= 10 |
| `aud` | AUDIT-C alcohol | 0-12 | Mayor = mayor consumo/riesgo alcohol |
| `acoso_any` | Alguna exposicion a acoso/violencia COPSOQ | 0/1 | Solo R9-R11 y ocupados; vulnerable a sesgo de reporte |
| `fuma` | Fuma actualmente | 0/1 | Negative control outcome |
| `sedentario` | 0 dias caminata y 0 ejercicio | 0/1 | Negative control outcome |

## 5. Los archivos que si conviene mirar primero

### A. Control de calidad

| Archivo | Para que sirve |
| --- | --- |
| `qa_log.txt` | Bitacora de la corrida. Resume asserts, resultados y advertencias. |
| `tab_validacion_scoring.csv` | Verifica que GHQ/PHQ reproducen cifras oficiales de prensa dentro de tolerancia. |
| `tab_reproduccion_v03.csv` | Prueba que la version nueva reproduce 20/20 celdas legacy v0.3. |
| `sessionInfo.txt` | Versiones de R y paquetes. |
| `CODEBOOK_TSM_SAV_variables.csv` | Codebook real extraido desde los `.sav`: variables, etiquetas SPSS, tipos, missing y etiquetas de valores por ronda. |

Lectura: si `qa_log.txt` dice `[OK]`, el pipeline paso los checks internos. En esta corrida, la reproduccion v0.3 pasa 20/20.

### B. Descriptivos basales

| Archivo | Para que sirve |
| --- | --- |
| `tab1_basal_R9.csv` | Descriptivos en R9 por grupo antiguo: dependiente, cp_empleador, sin ocupacion. |
| `tab2_v04_split.csv` | Descriptivos R9 con split v0.4: cuenta propia, dependiente, empleador, sin ocupacion. |
| `tab2_v04_smd.csv` | Balance dependientes vs cuenta propia en variables basales. |

Lectura clave:

- Dependientes son mas jovenes que cuenta propia: SMD edad aprox. `-0.53`.
- Salud mental basal esta bastante balanceada: GHQ SMD aprox. `-0.086`; GHQ-L SMD aprox. `-0.005`.
- Empleadores son pocos (`n=62`) y no conviene usarlos como control principal.

### C. Resultado principal

| Archivo | Para que sirve |
| --- | --- |
| `tab_s18_split_control.csv` | Resultado principal v0.4: dependientes vs cuenta propia; empleadores separados. |
| `figs_journal/fig2_es_ghq_primary.png` | Figura principal GHQ, dependientes vs cuenta propia. |
| `figs_journal/efig_es_multioutcome_primary.png` | Figura multi-outcome. |

Lectura clave:

- GHQ R10: `+0.099`, IC95 `[-0.250, +0.449]`.
- GHQ R11: `+0.296`, IC95 `[-0.091, +0.683]`.
- Esto apunta hacia peor GHQ en dependientes, pero el intervalo cruza 0.

### D. Multiplicidad

| Archivo | Para que sirve |
| --- | --- |
| `tab_s15_bh_primaria12.csv` | Ajuste BH/FDR para la familia primaria. |
| `tab_s15_bh_v04_12.csv` | Familia v0.4 comparable. |
| `tab_s15_bh_legado10.csv` | Familia antigua v0.3. |

Lectura clave:

- q-BH minimo en familia primaria = `0.64`.
- Nada sobrevive multiplicidad.
- Por eso no conviene decir "efecto significativo" como conclusion principal.

### E. Robustez y modelos alternativos

| Archivo | Para que sirve |
| --- | --- |
| `diag_primario_cp.txt` | Resumen amable de diagnosticos de la especificacion primaria. |
| `tab_s17_ldv_bracket.csv` | Modelos con outcome rezagado / bracket Ding-Li. |
| `tab_s17b_aipw.csv` | AIPW con set rico, muestra mas pequena. |
| `tab_s17b_aipw_respec.csv` | AIPW parsimonioso; coincide con diagnostico v0.4. |
| `tab_s13_panelmatch.csv` | PanelMatch CRAN. |
| `tab_robustez.csv` | Acumulado de robusteces varias. |

Lectura clave:

- PanelMatch CRAN no reproduce el hallazgo protector fuerte de la version vieja.
- LDV/ANCOVA reduce la lectura causal fuerte; el bracket R11 queda aprox. positivo pero incierto.
- AIPW parsimonioso da GHQ R11 `+0.380 [0.005, 0.690]`, pero esto no sobrevive la familia de contrastes y depende de supuestos.

### F. Mecanismos / interpretacion

| Archivo | Para que sirve |
| --- | --- |
| `tab_s22_g3_firststage.csv` | Prevalencia descriptiva de items g3 por grupo en R11. |
| `tab_s22_g3_brechas_ajustadas.csv` | Brechas ajustadas dependientes - cuenta propia en implementacion. |
| `figs_journal/fig_s22_g3.png` | Figura first-stage g3. |
| `tab_acoso_split.csv` | Acoso/violencia reportado por grupo y ronda. |

Lectura clave:

- Hay evidencia de implementacion: dependientes reportan mas protocolos/informacion/capacitacion/canales.
- Indice g3: dependientes `0.69` vs cuenta propia `0.44`.
- Entonces el resultado nulo/no concluyente en salud mental no parece deberse simplemente a "no hubo implementacion".

### G. Ley 40 horas

| Archivo | Para que sirve |
| --- | --- |
| `tab_s21_ddd.csv` | Triple diferencia post x dependiente x altas horas basales. |
| `tab_s21_es_dentro_dep.csv` | Event-study dentro de dependientes por altas horas. |
| `tab_s21_es_placebo_cp.csv` | Placebo dentro de cuenta propia. |

Lectura clave:

- DDD post x dependiente x altas horas: `-0.144`, IC95 `[-0.781, +0.493]`, p `0.657`.
- No hay evidencia clara de que el canal 40 horas explique los resultados.

### H. Distribucion / cola superior

| Archivo | Para que sirve |
| --- | --- |
| `tab_s20_cuantiles_cambio.csv` | Diferencias en cuantiles del cambio. |
| `tab_s20_umbrales.csv` | Probabilidad de empeorar/mejorar al menos 1 o 2 puntos GHQ. |
| `tab_s20_bandas.csv` | Bandas de severidad GHQ. |
| `figs_journal/fig_s20_qdif_ghq.png` | Figura de cuantiles. |
| `figs_journal/fig_s20_ecdf_ghq.png` | ECDF GHQ. |

Lectura clave:

- Mediana del cambio GHQ: diferencia `0`.
- Pero empeorar >=2 puntos GHQ en R11: `+7.7 pp`, IC95 `[+1.9, +13.4]`, p `0.009`.
- Esto es descriptivo, no una afirmacion causal fuerte de cuantiles.

### I. Sexo / heterogeneidad

| Archivo | Para que sirve |
| --- | --- |
| `tab_sexo_primaria.csv` | Sexo en especificacion primaria. |
| `tab_eventstudy_por_sexo.csv` | Version mas amplia por sexo. |
| `tab_estratos_edad_sexo.csv` | Edad x sexo, exploratorio. |
| `figs_journal/efig_es_strata.png` | Figura estratos. |

Lectura clave:

- Hombres R11: `+0.574 [0.094, 1.053]`.
- Mujeres R11: `+0.052 [-0.541, 0.645]`.
- Pero la interaccion DDD sexo no es concluyente: `-0.480 [-1.122, +0.161]`, p `0.142`.
- Las celdas edad x sexo tienen muy poca potencia; no interpretar fuerte.

## 6. Codebook minimo de la base analitica

Este es el diccionario minimo para entender la base derivada que arma el script. Para el codebook completo de los `.sav` originales, usar `bundle/outputs/CODEBOOK_TSM_SAV_variables.csv` (2102 filas).

### Identificacion y tiempo

| Variable | Significado |
| --- | --- |
| `IdPanel` | Identificador para seguir personas entre rondas |
| `IdEncuesta` | Identificador de encuesta dentro de ronda |
| `ronda` | Ronda 7 a 11 |
| `ronda_f` | Ronda como factor para modelos |
| `fecha` | Fecha aproximada de ronda |
| `ev_mes` | Meses desde R9: R7=-12, R8=-4, R9=0, R10=7, R11=12 |
| `Fact_Exp` | Factor de expansion poblacional |
| `IdRegion` | Region |

### Demografia

| Variable | Significado |
| --- | --- |
| `a2` | Sexo original: 1 hombre, 2 mujer |
| `mujer` | Indicador derivado: 1 mujer, 0 hombre |
| `a3` | Edad |
| `edad9` | Edad basal en R9 |
| `mujer9` | Sexo basal en R9 |

### Trabajo y grupos

| Variable | Significado |
| --- | --- |
| `c10` | Categoria ocupacional |
| `grupo_cont` | Grupo antiguo: dependiente, cp_empleador, sin_ocupacion |
| `grupo_split` | Grupo split: dependiente, cuenta_propia, empleador, sin_ocupacion |
| `grupo9` | `grupo_cont` fijado en R9 |
| `grupo9s` | `grupo_split` fijado en R9 |
| `trat` | 1 si dependiente/cubierto, 0 si control en la muestra usada |
| `c11` | Contrato firmado |
| `c12_1dig` | Rama economica 1 digito |
| `c13` | Tamano de empresa |
| `c13a` | Jefatura |
| `c14ah` / `horas` | Horas semanales, usado para analisis 40 horas |

Codificacion de grupos laborales:

| Categoria `c10` | Grupo |
| --- | --- |
| 1 | empleador |
| 2 | cuenta_propia |
| 3-7 | dependiente |
| otros/no ocupado | sin_ocupacion u otro/no clasificado segun contexto |

### Salud mental y conducta

| Variable | Significado |
| --- | --- |
| `ghq` | GHQ-12 bimodal 0-12 |
| `ghq5` | 1 si GHQ >= 5 |
| `ghqL` | GHQ Likert-simetrico 0-36 |
| `phq` | PHQ-9 0-27 |
| `phq10` | 1 si PHQ >= 10 |
| `gad` | GAD-7 0-21 |
| `gad10` | 1 si GAD >= 10 |
| `aud` | AUDIT-C 0-12 |
| `fuma` | Fuma actualmente |
| `sedentario` | Sedentarismo extremo usado como negative control |

Items usados:

| Escala | Items fuente |
| --- | --- |
| GHQ positivos | `e1a`, `e1c`, `e1d`, `e1g`, `e1h`, `e1l` |
| GHQ negativos | `e1b`, `e1e`, `e1f`, `e1i`, `e1j`, `e1k` |
| PHQ-9 | `f15a` a `f15i` |
| GAD-7 | `e21a`, `e21b`, `e21c`, `e21d`, `e21f`, `e21g`, `e21h` |
| AUDIT-C | `e3a1`, `e3a2`, `e3a3` |
| Acoso/COPSOQ | `sh1`, `al`, `hq`, `pv1`, `cq1`, `ut1`, `hsm1` |

### Implementacion Ley Karin, modulo g3

El modulo `g3` existe en R11. Se usa como first-stage descriptivo, no como ajuste causal.

| Variable | Significado |
| --- | --- |
| `g3a` | Protocolo/politica de prevencion |
| `g3b` | Informacion del empleador en ultimos 12 meses |
| `g3c` | Correo informativo |
| `g3d` | Reuniones informativas |
| `g3e` | Carteles/afiches |
| `g3f` | Capacitacion ofrecida |
| `g3g` | Participo en capacitacion, condicional |
| `g3h` | Canal de denuncia informado |
| `g3i` | Sabe donde denunciar |

## 7. Mapa corto por pregunta

| Pregunta | Archivo que miro |
| --- | --- |
| Paso el pipeline? | `qa_log.txt` |
| Reproduce cifras oficiales? | `tab_validacion_scoring.csv` |
| Cual es el resultado principal? | `tab_s18_split_control.csv` |
| Hay efecto en GHQ? | `tab_s18_split_control.csv`, `fig2_es_ghq_primary.png` |
| Sobrevive multiplicidad? | `tab_s15_bh_primaria12.csv` |
| Hay implementacion de Ley Karin? | `tab_s22_g3_brechas_ajustadas.csv` |
| Puede ser 40 horas? | `tab_s21_ddd.csv` |
| Hay problemas de tendencias/placebos? | `diag_primario_cp.txt` |
| Que pasa en la cola de empeoramiento? | `tab_s20_umbrales.csv` |
| Que pasa por sexo? | `tab_sexo_primaria.csv` |
| Que archivos van al paper? | `tablas_v04.txt` y figuras en `figs_journal/` |

## 8. Lectura final recomendada

Una forma honesta y simple de resumir el bundle:

> El panel permite comparar trabajadores dependientes con cuenta propia antes y despues de la implementacion de Ley Karin. Hay evidencia descriptiva de implementacion efectiva de protocolos e informacion. Sin embargo, los resultados de salud mental no muestran una mejora clara. Para GHQ, la estimacion principal en R11 apunta a mayor malestar relativo en dependientes, pero es imprecisa y no sobrevive correccion por multiples contrastes. Los diagnosticos muestran que la inferencia causal debe ser cautelosa: algunos placebos/negative controls fallan, GAD tiene problemas de comparabilidad pre, y los resultados dependen de supuestos. El hallazgo mas interesante, pero descriptivo, es que la diferencia parece concentrarse en la cola de empeoramiento de GHQ.
