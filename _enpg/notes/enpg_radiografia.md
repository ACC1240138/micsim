# Radiografía de bases ENPG

Generado: 2026-09-20 · carpeta: `__enpg/` (no recursivo)

Criterios heurísticos:

- **Ponderador candidato**: variable numérica cuya suma cae entre 1 y 20 millones (orden de magnitud de la población chilena 15–64).
- **Cardinalidad media (50–5000 niveles)**: candidatos a conglomerado / manzana / UPM / comuna.
- **Cardinalidad baja (2–20 niveles)**: candidatos a estrato, sexo, tramo etario, categóricas de consumo.

## Resumen

| Archivo | MB | Filas | Vars | Ponderador(es) | Suma |
|---|---:|---:|---:|---|---|
| `Base de datos ENPG 2012 (PG).dta` | 58.8 | 17 154 | 451 | `p41`, `p42`, `p64`, `p86`, `p127`, `p141_2_a_o`, `p189_3_b`, `p189_4_b`, `p189_5_monto`, `p189_5_b`, `p189_6_b`, `p189_7_b`, `p192_3`, `p192_4`, `p192_5`, `p192_6`, `p192_11`, `p192_14`, `PONDERADOR`, `manzana` | 6 115 760, 1 030 721, 1 443 764, 1 205 451, 13 854 956, 14 359 645, 1 315 471, 1 253 102, 11 605 088, 1 372 594, 1 359 681, 1 319 576, 12 148 594, 1 720 209, 4 610 338, 1 349 192, 1 587 795, 1 092 807, 9 940 512, 13 851 462 |
| `Base de datos ENPG 2012 (PG).DTA.dta` | 58.8 | 17 154 | 451 | `p41`, `p42`, `p64`, `p86`, `p127`, `p141_2_a_o`, `p189_3_b`, `p189_4_b`, `p189_5_monto`, `p189_5_b`, `p189_6_b`, `p189_7_b`, `p192_3`, `p192_4`, `p192_5`, `p192_6`, `p192_11`, `p192_14`, `PONDERADOR`, `manzana` | 6 115 760, 1 030 721, 1 443 764, 1 205 451, 13 854 956, 14 359 645, 1 315 471, 1 253 102, 11 605 088, 1 372 594, 1 359 681, 1 319 576, 12 148 594, 1 720 209, 4 610 338, 1 349 192, 1 587 795, 1 092 807, 9 940 512, 13 851 462 |
| `Base de datos ENPG 2014 (PG).DTA.dta` | 32.6 | 20 113 | 454 | `pb7`, `pb8`, `coc7`, `coc8`, `trans5_1`, `trans5_3`, `trans5_4`, `trans5_6`, `trans5_7`, `op2_3`, `op2_4`, `op2_5`, `dp14_5`, `F2_MAY_AJUS_com`, `RND_F2_MAY_AJUS_com` | 7 335 994, 1 043 825, 8 596 771, 4 275 764, 9 856 857, 10 852 267, 3 007 997, 1 891 387, 2 069 398, 1 032 551, 1 074 722, 1 105 051, 14 963 175, 10 088 222, 10 088 247 |
| `Base de datos ENPG 2018 (PG).DTA` | 25.4 | 19 427 | 499 | `ST_7`, `ST_9a`, `MAR_6`, `PB_8`, `I_1_DP_17a`, `I_2_DP_17a`, `I_3_DP_17a`, `Fexp` | 1 999 685, 1 249 865, 1 194 271, 14 500 319, 4 782 246, 1 935 377, 2 660 046, 10 992 349 |
| `base ENPG 2016 publico general.dta` | 16.2 | 19 147 | 473 | `mar_8`, `mar_9`, `pb_7`, `coc_7_monto` | 13 640 563, 4 075 180, 1 869 265, 1 486 110 |
| `Base Publica ENPG 2024 (Stata 16).dta` | 53.6 | 18 668 | 402 | `FACTOR_EXPANSION` | 11 396 772 |
| `enpg2008.RDS` | 1.5 | 17 113 | 367 | `c_vivienda`, `exp`, `q54`, `q55`, `q78`, `q101`, `q273`, `q274` | 3 520 562, 9 087 047, 1 466 876, 5 376 085, 2 121 599, 1 609 797, 1 472 949, 1 230 651 |
| `enpg2010.RDS` | 1.7 | 15 576 | 521 | `p039`, `p062`, `p084`, `factor_ajustado_com` | 4 470 712, 5 761 994, 3 716 146, 9 536 602 |
| `enpg2020.RDS` | 1.4 | 16 662 | 395 | `DP_4`, `FACT_PERS_COMUNA` | 14 239 847, 11 159 046 |
| `enpg2022.RDS` | 1.7 | 17 454 | 382 | `FACTOR_EXPANSION` | 12 941 545 |
| `factoresdeexpansion.dta` | 0.2 | 19 147 | 2 | `Fexp` | 10 356 863 |

## Detalle por archivo

### Base de datos ENPG 2012 (PG).dta

- Filas: 17 154 · Variables: 451
- Ponderador(es): `p41` (suma = 6 115 760); `p42` (suma = 1 030 721); `p64` (suma = 1 443 764); `p86` (suma = 1 205 451); `p127` (suma = 13 854 956); `p141_2_a_o` (suma = 14 359 645); `p189_3_b` (suma = 1 315 471); `p189_4_b` (suma = 1 253 102); `p189_5_monto` (suma = 11 605 088); `p189_5_b` (suma = 1 372 594); `p189_6_b` (suma = 1 359 681); `p189_7_b` (suma = 1 319 576); `p192_3` (suma = 12 148 594); `p192_4` (suma = 1 720 209); `p192_5` (suma = 4 610 338); `p192_6` (suma = 1 349 192); `p192_11` (suma = 1 587 795); `p192_14` (suma = 1 092 807); `PONDERADOR` (suma = 9 940 512); `manzana` (suma = 13 851 462)
- Cardinalidad media (n=23): `edad`, `p4`, `p7`, `p8`, `p12`, `p18`, `p37`, `p127`, `p173_cod`, `p175_cod`, `p189_1_monto`, `p189_2_monto`, `p189_3_monto`, `p189_4_monto`, `p189_6_monto`, `p189_7_monto`, `p192_1`, `p192_3`, `p192_9`, `p192_10`, `comuna`, `codigo_comuna`, `manzana`
- Cardinalidad baja (n=402): `sexo`, `p1_2`, `p2`, `p3`, `p5`, `p9_1`, `p9_2`, `p10`, `p11`, `p13`, `p15`, `p19`, `p20`, `p21`, `p22`, `p23`, `p24`, `p25`, `p26`, `p27`, `p28`, `p29_1`, `p29_2`, `p29_3`, `p29_4`, `p29_5`, `p29_6`, `p30_1`, `p30_2`, `p30_3`, `... (+372)`

### Base de datos ENPG 2012 (PG).DTA.dta

- Filas: 17 154 · Variables: 451
- Ponderador(es): `p41` (suma = 6 115 760); `p42` (suma = 1 030 721); `p64` (suma = 1 443 764); `p86` (suma = 1 205 451); `p127` (suma = 13 854 956); `p141_2_a_o` (suma = 14 359 645); `p189_3_b` (suma = 1 315 471); `p189_4_b` (suma = 1 253 102); `p189_5_monto` (suma = 11 605 088); `p189_5_b` (suma = 1 372 594); `p189_6_b` (suma = 1 359 681); `p189_7_b` (suma = 1 319 576); `p192_3` (suma = 12 148 594); `p192_4` (suma = 1 720 209); `p192_5` (suma = 4 610 338); `p192_6` (suma = 1 349 192); `p192_11` (suma = 1 587 795); `p192_14` (suma = 1 092 807); `PONDERADOR` (suma = 9 940 512); `manzana` (suma = 13 851 462)
- Cardinalidad media (n=23): `edad`, `p4`, `p7`, `p8`, `p12`, `p18`, `p37`, `p127`, `p173_cod`, `p175_cod`, `p189_1_monto`, `p189_2_monto`, `p189_3_monto`, `p189_4_monto`, `p189_6_monto`, `p189_7_monto`, `p192_1`, `p192_3`, `p192_9`, `p192_10`, `comuna`, `código_comuna`, `manzana`
- Cardinalidad baja (n=402): `sexo`, `p1_2`, `p2`, `p3`, `p5`, `p9_1`, `p9_2`, `p10`, `p11`, `p13`, `p15`, `p19`, `p20`, `p21`, `p22`, `p23`, `p24`, `p25`, `p26`, `p27`, `p28`, `p29_1`, `p29_2`, `p29_3`, `p29_4`, `p29_5`, `p29_6`, `p30_1`, `p30_2`, `p30_3`, `... (+372)`

### Base de datos ENPG 2014 (PG).DTA.dta

- Filas: 20 113 · Variables: 454
- Ponderador(es): `pb7` (suma = 7 335 994); `pb8` (suma = 1 043 825); `coc7` (suma = 8 596 771); `coc8` (suma = 4 275 764); `trans5_1` (suma = 9 856 857); `trans5_3` (suma = 10 852 267); `trans5_4` (suma = 3 007 997); `trans5_6` (suma = 1 891 387); `trans5_7` (suma = 2 069 398); `op2_3` (suma = 1 032 551); `op2_4` (suma = 1 074 722); `op2_5` (suma = 1 105 051); `dp14_5` (suma = 14 963 175); `F2_MAY_AJUS_com` (suma = 10 088 222); `RND_F2_MAY_AJUS_com` (suma = 10 088 247)
- Cardinalidad media (n=24): `edad`, `Segmento_n`, `Segmento_t`, `Comuna`, `Nombre_Comuna`, `st5`, `st8`, `st10`, `oh3`, `oh9`, `mar3`, `trans2_1`, `trans6_esp`, `co6_COD`, `co8_COD`, `dp14_1`, `dp14_2`, `dp14_3`, `dp14_4`, `dp14_5`, `dp14_6`, `dp14_7`, `dp15_esp`, `RND_F2_MAY_AJUS_com`
- Cardinalidad baja (n=396): `sexo`, `tramo_edad`, `Region`, `st1`, `st2`, `st3`, `st4`, `st6`, `st9`, `st11`, `ce1`, `ce2`, `ce3`, `ce4`, `ce5`, `ce6`, `ce7_a`, `ce7_b`, `ce7_c`, `ce7_d`, `ce7_e`, `ce8`, `sa1`, `oh1`, `oh2`, `oh4`, `oh6`, `oh10`, `oh11`, `oh12`, `... (+366)`

### Base de datos ENPG 2018 (PG).DTA

- Filas: 19 427 · Variables: 499
- Ponderador(es): `ST_7` (suma = 1 999 685); `ST_9a` (suma = 1 249 865); `MAR_6` (suma = 1 194 271); `PB_8` (suma = 14 500 319); `I_1_DP_17a` (suma = 4 782 246); `I_2_DP_17a` (suma = 1 935 377); `I_3_DP_17a` (suma = 2 660 046); `Fexp` (suma = 10 992 349)
- Cardinalidad media (n=28): `S02`, `ST_4`, `ST_7`, `ST_9`, `OH_3`, `OH_9`, `OH_22_OTH`, `OH_23_OTH`, `MAR_3`, `MAR_8`, `T_TRANS_2_1`, `T_TRANS_2_3`, `T_ANALG_2_1`, `Q_253_S`, `Q_319_S`, `I_1_DP_17_1`, `I_2_DP_17_1`, `I_3_DP_17_1`, `I_4_DP_17_1`, `I_5_DP_17_1`, `I_6_DP_17_1`, `I_7_DP_17_1`, `DP_18_a1`, `idmanzana`, `Seccion`, `... (+3)`
- Cardinalidad baja (n=407): `S01`, `ST_1`, `ST_2`, `ST_3`, `ST_5`, `ST_8`, `ST_10`, `CE_1`, `CE_2`, `CE_3`, `CE_4`, `CE_5`, `CE_6`, `T_CE_8_1`, `T_CE_8_2`, `T_CE_8_3`, `T_CE_8_4`, `T_CE_8_5`, `T_CE_8_6`, `CE_9`, `SA_1`, `OH_1`, `OH_2`, `OH_4`, `OH_6`, `OH_10`, `T_OH_11_2`, `T_OH_11_3`, `OH_12`, `OH_13`, `... (+377)`

### base ENPG 2016 publico general.dta

- Filas: 19 147 · Variables: 473
- Ponderador(es): `mar_8` (suma = 13 640 563); `mar_9` (suma = 4 075 180); `pb_7` (suma = 1 869 265); `coc_7_monto` (suma = 1 486 110)
- Cardinalidad media (n=20): `st_5`, `st_8`, `st_10`, `oh_3`, `oh_10`, `oh_11_monto`, `mar_3`, `trans_2_a`, `trans_2_c`, `co_6_r`, `co_8_r`, `dp_14_1`, `dp_14_2`, `dp_14_3`, `dp_14_4`, `dp_14_5`, `dp_15_monto`, `edad`, `comuna`, `manzana`
- Cardinalidad baja (n=422): `st_2`, `st_3`, `st_4`, `st_6`, `st_9`, `st_11`, `ce_1`, `ce_2`, `ce_3`, `ce_4`, `ce_5`, `ce_6`, `ce_7_a`, `ce_7_b`, `ce_7_c`, `ce_7_d`, `ce_7_e`, `ce_7_f`, `ce_8`, `sa_1`, `oh_1`, `oh_2`, `oh_4`, `oh_6`, `oh_7b`, `oh_9_1`, `oh_9_2`, `oh_9_3`, `oh_9_4`, `oh_9_5`, `... (+392)`

### Base Publica ENPG 2024 (Stata 16).dta

- Filas: 18 668 · Variables: 402
- Ponderador(es): `FACTOR_EXPANSION` (suma = 11 396 772)
- Cardinalidad media (n=11): `EDAD`, `COD_COMUNA`, `ST_4`, `ST_7`, `OH_3`, `MAR_3`, `DP_6_ESP`, `DP_6A_ESP`, `DP_6B_ESP`, `UPM`, `ESTRATO`
- Cardinalidad baja (n=377): `SEXO`, `REGION`, `ST_1`, `ST_2`, `ST_3`, `ST_5`, `CE_1`, `CE_2`, `CE_3`, `CE_4`, `CE_5`, `CE_6`, `CE_7`, `CE_8`, `OH_1`, `OH_2`, `OH_4`, `OH_6`, `OH_8`, `OH_9`, `OH_10`, `OH_11`, `OH_12`, `OH_13`, `OH_14`, `OH_15`, `OH_16`, `OH_17`, `OH_181`, `OH_182`, `... (+347)`

### enpg2008.RDS

- Filas: 17 113 · Variables: 367
- Ponderador(es): `c_vivienda` (suma = 3 520 562); `exp` (suma = 9 087 047); `q54` (suma = 1 466 876); `q55` (suma = 5 376 085); `q78` (suma = 2 121 599); `q101` (suma = 1 609 797); `q273` (suma = 1 472 949); `q274` (suma = 1 230 651)
- Cardinalidad media (n=11): `area`, `narea`, `comuna`, `seccion`, `c_vivienda`, `exp`, `edad`, `q7`, `q14`, `q273`, `q274`
- Cardinalidad baja (n=334): `q286`, `q287`, `region`, `q294`, `n_per`, `sexo`, `q1`, `q2`, `q3`, `q4`, `q5`, `q6`, `q8`, `q11`, `q12`, `q13`, `q15`, `q17`, `q18`, `q19`, `q20`, `q21`, `q22`, `q23`, `q24`, `q25`, `q26`, `q27`, `q28`, `q29`, `... (+304)`

### enpg2010.RDS

- Filas: 15 576 · Variables: 521
- Ponderador(es): `p039` (suma = 4 470 712); `p062` (suma = 5 761 994); `p084` (suma = 3 716 146); `factor_ajustado_com` (suma = 9 536 602)
- Cardinalidad media (n=25): `pnomcomun`, `pcodcom`, `manzana`, `pedadent`, `p007`, `p010`, `p011`, `p015`, `p278`, `p291a_1`, `p291a_2`, `p291a_3`, `p291a_4`, `p291a_5`, `p291a_6`, `p291a_7`, `p291binfo_01`, `p291binfo_05`, `p291binfo_07`, `p291binfo_13`, `p291bm_01`, `p291bm_05`, `p291bm_07`, `p291bm_13`, `p292info`
- Cardinalidad baja (n=446): `pregion`, `psexoent`, `p001`, `p002`, `p003`, `p004`, `p005`, `p006`, `p008`, `p012`, `p013`, `p014`, `p016`, `p018`, `p019`, `p020`, `p021`, `p022`, `p023`, `p024`, `p025`, `p026`, `p027`, `p028`, `p029`, `p030`, `p031`, `p032`, `p033`, `p034`, `... (+416)`

### enpg2020.RDS

- Filas: 16 662 · Variables: 395
- Ponderador(es): `DP_4` (suma = 14 239 847); `FACT_PERS_COMUNA` (suma = 11 159 046)
- Cardinalidad media (n=8): `Nom_comuna`, `S02`, `ST_4`, `ST_7`, `OH_3`, `MAR_3`, `ESPT_COVID_1_O8`, `Q_319_S`
- Cardinalidad baja (n=376): `REGION`, `S01`, `ST_1`, `ST_2`, `ST_3`, `ST_5`, `CE_1`, `CE_2`, `CE_3`, `CE_4`, `CE_5`, `CE_6`, `CE_7`, `OH_1`, `OH_2`, `OH_4`, `OH_6`, `OH_8`, `OH_9`, `OH_10`, `OH_11`, `OH_12`, `OH_13`, `OH_14`, `OH_15`, `OH_16`, `OH_17`, `OH_18_O1`, `OH_19_O1`, `OH_18_O2`, `... (+346)`

### enpg2022.RDS

- Filas: 17 454 · Variables: 382
- Ponderador(es): `FACTOR_EXPANSION` (suma = 12 941 545)
- Cardinalidad media (n=10): `COD_COMUNA`, `UPM`, `EDAD`, `ST_4`, `ST_7`, `OH_3`, `MAR_3`, `DP_6_3`, `DP_6A_3`, `DP_6B_3`
- Cardinalidad baja (n=359): `REGION`, `SEXO`, `ST_1`, `ST_2`, `ST_3`, `ST_5`, `CE_1`, `CE_2`, `CE_3`, `CE_4`, `CE_5`, `CE_6`, `CE_7`, `OH_1`, `OH_2`, `OH_4`, `OH_6`, `OH_8`, `OH_9`, `OH_10`, `OH_11`, `OH_12`, `OH_13`, `OH_14`, `OH_15`, `OH_16`, `OH_17`, `OH_181`, `OH_191`, `OH_182`, `... (+329)`

### factoresdeexpansion.dta

- Filas: 19 147 · Variables: 2
- Ponderador(es): `Fexp` (suma = 10 356 863)
- Cardinalidad media (n=0): —
- Cardinalidad baja (n=0): —

## Diccionario completo — Base Publica ENPG 2024 (Stata 16).dta

> Las etiquetas vienen cortadas a 80 caracteres en el propio `.dta` (límite de Stata para variable labels); el texto completo de cada pregunta está en `__enpg/cuestionario 2024.pdf`.

| Variable | Etiqueta | n niveles etiquetados |
|---|---|---:|
| `RESPONDENT_SERIAL` |  | — |
| `SEXO` |  | 2 |
| `EDAD` |  | — |
| `COD_COMUNA` |  | — |
| `REGION` | REGION | 16 |
| `ST_1` | ST_1. Hablando de su salud, ¿Cómo calificaría Ud. su estado de salud, en general | 8 |
| `ST_2` | ST_2. ¿Ha fumado Ud. cigarrillos alguna vez en su vida? | 4 |
| `ST_3` | ST_3. ¿Cuándo fue la primera vez que Ud. fumó cigarrillos? | 5 |
| `ST_4` | ST_4. ¿Qué edad tenía cuando fumó cigarrillos por primera vez? | 3 |
| `ST_5` | ST_5. ¿Cuándo fue la última vez que fumó cigarrillos? | 5 |
| `ST_6` | ST_6. Piense solamente en los últimos 30 días, ¿cuántos días ha fumado cigarrill | 3 |
| `ST_7` | ST_7. ¿Más o menos cuántos cigarrillos diarios ha fumado Ud. en estos últimos 30 | 3 |
| `CE_1` | CE_1. ¿Ud. conoce o ha escuchado hablar de los cigarrillos electrónicos? | 4 |
| `CE_2` | CE_2. ¿Ha usado Ud. cigarrillos electrónicos alguna vez en su vida? | 4 |
| `CE_3` | CE_3. ¿Cuándo fue la primera vez que Ud. usó cigarrillos electrónicos? | 5 |
| `CE_4` | CE_4. ¿Cuándo fue la última vez que usó cigarrillos electrónicos? | 5 |
| `CE_5` | CE_5. Piense solamente en los últimos 30 días, ¿cuántos días ha usado cigarrillo | 3 |
| `CE_6` | CE_6. Respecto a la última vez que Ud. usó cigarrillos electrónicos, ¿sabía Ud. | 3 |
| `CE_7` | CE_7. ¿Tiene Ud. actualmente algún dispositivo de cigarrillo electrónico? | 4 |
| `CE_8` | CE_8. ¿Usted ha intentado consumir otras drogas o sustancias incorporándolas en | 4 |
| `CE_8_ESP` | CE_8. Especifique | — |
| `OH_1` | OH_1. ¿Ha tomado Ud. alcohol  alguna vez en su vida? | 4 |
| `OH_2` | OH_2. ¿Cuándo fue la primera vez que Ud. consumió alcohol en su vida? | 5 |
| `OH_3` | OH_3. ¿Qué edad tenía cuando consumió por primera vez alcohol? (No considere cua | 3 |
| `OH_4` | OH_4. ¿Cuándo fue la última vez que Ud. consumió alcohol? | 5 |
| `OH_5` | OH_5. Pensando solamente en los últimos 30 días, ¿cuántos días del mes ha tomado | 3 |
| `OH_6` | OH_6. Durante los últimos 30 días, ¿qué tipo de bebida alcohólica tomó con más f | 6 |
| `OH_7` | OH_7. Pensando en los últimos 30 días:&nbsp;&nbsp;...&nbsp;...&nbsp; | 3 |
| `OH_8` | OH_8. ¿Qué tan seguido toma usted alguna bebida alcohólica? | 5 |
| `OH_9` | OH_9. ¿Cuántos tragos suele tomar usted en un día típico de consumo de alcohol? | 5 |
| `OH_10` | OH_10. ¿Qué tan seguido toma usted 6 o más tragos en una sola ocasión? | 5 |
| `OH_11` | OH_11. Y con la misma escala… ¿Qué tan seguido, en el curso de los últimos 12 me | 5 |
| `OH_12` | OH_12. ¿Qué tan seguido, en el curso de los últimos 12 meses, su consumo de alco | 5 |
| `OH_13` | OH_13. ¿Qué tan seguido, en el curso de los últimos 12 meses, usted necesitó beb | 5 |
| `OH_14` | OH_14. ¿Qué tan seguido, en el curso de los últimos 12 meses, usted tuvo remordi | 5 |
| `OH_15` | OH_15. ¿Qué tan seguido, en el curso de los últimos 12 meses, usted no fue capaz | 5 |
| `OH_16` | OH_16. ¿Usted o alguna otra persona ha resultado físicamente herido debido a que | 3 |
| `OH_17` | OH_17. ¿Algún familiar, amigo, médico u otro profesional de la salud ha mostrado | 3 |
| `OH_181` | OH_18. Pensando en los últimos 30 días, ¿ha comprado alcohol en alguno de los si | 7 |
| `OH_182` | OH_18. Pensando en los últimos 30 días, ¿ha comprado alcohol en alguno de los si | 7 |
| `OH_183` | OH_18. Pensando en los últimos 30 días, ¿ha comprado alcohol en alguno de los si | 7 |
| `OH_184` | OH_18. Pensando en los últimos 30 días, ¿ha comprado alcohol en alguno de los si | 7 |
| `OH_185` | OH_18. Pensando en los últimos 30 días, ¿ha comprado alcohol en alguno de los si | 7 |
| `OH_186` | OH_18. Pensando en los últimos 30 días, ¿ha comprado alcohol en alguno de los si | 7 |
| `OH_191` | OH_19. Durante los últimos 30 días, ¿ha comprado alcohol en alguno de los siguie | 7 |
| `OH_192` | OH_19. Durante los últimos 30 días, ¿ha comprado alcohol en alguno de los siguie | 7 |
| `OH_193` | OH_19. Durante los últimos 30 días, ¿ha comprado alcohol en alguno de los siguie | 7 |
| `OH_194` | OH_19. Durante los últimos 30 días, ¿ha comprado alcohol en alguno de los siguie | 7 |
| `OH_195` | OH_19. Durante los últimos 30 días, ¿ha comprado alcohol en alguno de los siguie | 7 |
| `OH_196` | OH_19. Durante los últimos 30 días, ¿ha comprado alcohol en alguno de los siguie | 7 |
| `OH_20` | OH_20. ¿Ha tenido algún problema serio en la casa, en el trabajo o donde estudia | 4 |
| `OH_21` | OH_21. ¿Le ha sucedido que a causa del alcohol se haya expuesto a algún peligro | 4 |
| `OH_22` | OH_22. ¿Ha hecho algo bajo los efectos del alcohol que pudiera causarle problema | 4 |
| `OH_23` | OH_23. ¿Ha tenido algún problema o han aumentado los problemas con su familia o | 4 |
| `OH_24` | OH_24. ¿Se ha visto envuelto en alguna pelea a golpes o ha agredido a alguien ba | 4 |
| `MAR_1` | MAR_1. ¿Ha probado Ud. marihuana alguna vez en su vida? | 4 |
| `MAR_2` | MAR_2. ¿Cuándo fue la primera vez que Ud. consumió marihuana en su vida? | 5 |
| `MAR_3` | MAR_3. ¿Qué edad tenía cuando probó marihuana por primera vez? | 3 |
| `MAR_4` | MAR_4. ¿Cuándo fue la última vez que Ud. consumió marihuana? (Respuesta espontán | 5 |
| `MAR_5` | MAR_5. Pensando solamente en los últimos 30 días, ¿cuántos días del mes ha consu | 3 |
| `MAR_6` | MAR_6. ¿Cuántos cigarros de marihuana consume Ud. al mes? Considere su consumo h | 3 |
| `MAR_7` | MAR_7. ¿Qué tipo de marihuana consumió con mayor frecuencia? | 7 |
| `MAR_8` | ¿Ha consumido marihuana para eliminar problemas como éstos o para evitar que se | 4 |
| `MAR_9` | MAR_9. ¿Ha presentado estos problemas cuando suspendía o disminuía el consumo de | 4 |
| `MAR_10` | MAR_10. ¿Ha sentido un deseo tan grande de usar marihuana que no pudo resistir o | 4 |
| `MAR_11` | MAR_11. ¿Ha observado que para obtener el mismo efecto con marihuana ha consumid | 4 |
| `MAR_12` | MAR_12. ¿Ha notado que la misma cantidad de marihuana tiene menos efecto en Ud. | 4 |
| `MAR_13` | MAR_13. ¿Ha intentado controlar, disminuir o dejar su consumo de marihuana, pero | 4 |
| `MAR_14` | MAR_14. ¿Ha terminado consumiendo marihuana en mayores cantidades o por mayor ti | 4 |
| `MAR_15` | MAR_15. ¿Ha dejado de hacer o ha suspendido actividades sociales, laborales o re | 4 |
| `MAR_16` | MAR_16. ¿Ha dedicado más tiempo que antes a conseguir y consumir marihuana, o pa | 4 |
| `MAR_17` | MAR_17. ¿Ha continuado consumiendo marihuana a pesar de que le ocasione problema | 4 |
| `MAR_18` | MAR_18. ¿Ha tenido algún problema serio en la casa, en el trabajo o donde estudi | 4 |
| `MAR_19` | MAR_19. ¿Le ha sucedido que a causa de la marihuana se haya expuesto a algún pel | 4 |
| `MAR_20` | MAR_20. ¿Ha hecho algo bajo los efectos de la marihuana que pudiera causarle pro | 4 |
| `MAR_21` | MAR_21. ¿Ha tenido algún problema o han aumentado los problemas con su familia o | 4 |
| `MAR_21A` | MAR_21A. ¿Se ha visto envuelto en alguna pelea a golpes o ha agredido a alguien | 4 |
| `MAR_21B` | MAR_21B. ¿Algún familiar o persona cercana a usted ha resultado dañada física o | 4 |
| `MAR_22` | MAR_22. Piense en los últimos 12 meses, ¿Ha consumido marihuana por una vía dist | 4 |
| `MAR_2301` | Piense en los últimos 12 meses, ¿Ha consumido marihuana por alguna de las siguie | 1 |
| `MAR_2302` | Piense en los últimos 12 meses, ¿Ha consumido marihuana por alguna de las siguie | 1 |
| `MAR_2303` | Piense en los últimos 12 meses, ¿Ha consumido marihuana por alguna de las siguie | 1 |
| `MAR_2304` | Piense en los últimos 12 meses, ¿Ha consumido marihuana por alguna de las siguie | 1 |
| `MAR_2305` | Piense en los últimos 12 meses, ¿Ha consumido marihuana por alguna de las siguie | 1 |
| `MAR_2306` | Piense en los últimos 12 meses, ¿Ha consumido marihuana por alguna de las siguie | 1 |
| `MAR_2307` | Piense en los últimos 12 meses, ¿Ha consumido marihuana por alguna de las siguie | 1 |
| `MAR_2308` | Piense en los últimos 12 meses, ¿Ha consumido marihuana por alguna de las siguie | 1 |
| `MAR_2309` | Piense en los últimos 12 meses, ¿Ha consumido marihuana por alguna de las siguie | 1 |
| `MAR_2310` | Piense en los últimos 12 meses, ¿Ha consumido marihuana por alguna de las siguie | 1 |
| `MAR_23_ESP` | MAR_23 Especifique | — |
| `PB_1` | PB_1. ¿Ha probado Ud. pasta base alguna vez en su vida? | 4 |
| `PB_2` | PB_2. ¿Cuándo fue la primera vez que Ud. consumió pasta base en su vida? | 5 |
| `PB_3` | PB_3. ¿Qué edad tenía cuando probó pasta base por primera vez? | 3 |
| `PB_4` | PB_4. ¿Cuándo fue la última vez que Ud. consumió pasta base? (Respuesta espontán | 5 |
| `PB_5` | PB_5. Pensando solamente en los últimos 30 días, ¿cuántos días del mes ha consum | 3 |
| `PB_6` | PB_6. ¿Ha consumido pasta base para eliminar problemas como éstos o para evitar | 4 |
| `PB_7` | PB_7. ¿Ha presentado estos problemas cuando suspendía o disminuía el consumo de | 4 |
| `PB_8` | PB_8. ¿Ha sentido un deseo tan grande de consumir pasta base que no pudo resisti | 4 |
| `PB_9` | PB_9. ¿Ha observado que para obtener el mismo efecto con pasta base ha consumido | 4 |
| `PB_10` | PB_10. ¿Ha notado que la misma cantidad de pasta base tiene menos efecto en Ud. | 4 |
| `PB_11` | PB_11. ¿Ha intentado controlar, disminuir o dejar su consumo de pasta base, pero | 4 |
| `PB_12` | PB_12. ¿Ha terminado consumiendo pasta base en mayores cantidades o por mayor ti | 4 |
| `PB_13` | PB_13. ¿Ha dejado de hacer o ha suspendido actividades sociales, laborales o rec | 4 |
| `PB_14` | PB_14. ¿Ha dedicado más tiempo que antes a conseguir y consumir pasta base, o pa | 4 |
| `PB_15` | PB_15. ¿Ha continuado consumiendo pasta base a pesar de que le ocasione problema | 4 |
| `PB_16` | PB_16. ¿Ha tenido algún problema serio en la casa, en el trabajo o donde estudia | 4 |
| `PB_17` | PB_17. ¿Le ha sucedido que a causa de la pasta base se haya expuesto a algún pel | 4 |
| `PB_18` | PB_18. ¿Ha hecho algo bajo los efectos de la pasta base que pudiera causarle pro | 4 |
| `PB_19` | PB_19. ¿Ha tenido algún problema o han aumentado los problemas con su familia o | 4 |
| `PB_20` | PB_20. ¿Se ha visto envuelto en alguna pelea a golpes o ha agredido a alguien ba | 4 |
| `PB_21` | PB_21. ¿Algún familiar o persona cercana a usted ha resultado dañada física o ps | 4 |
| `COC_1` | COC_1. ¿Ha probado Ud. cocaína alguna vez en su vida? | 4 |
| `COC_2` | COC_2. ¿Cuándo fue la primera vez que Ud. consumió cocaína en su vida? (Respuest | 5 |
| `COC_3` | COC_3. ¿Qué edad tenía cuando probó cocaína por primera vez? | 3 |
| `COC_4` | COC_4. ¿Cuándo fue la última vez que Ud. consumió cocaína? (Respuesta espontánea | 5 |
| `COC_5` | COC_5. Pensando solamente en los últimos 30 días, ¿cuántos días del mes ha consu | 3 |
| `COC_6` | COC_6. ¿Ha consumido cocaína para eliminar problemas como éstos o para evitar qu | 4 |
| `COC_7` | COC_7. ¿Ha presentado estos problemas cuando suspendía o disminuía el consumo de | 4 |
| `COC_8` | COC_8. ¿Ha sentido un deseo tan grande de consumir cocaína que no pudo resistir | 4 |
| `COC_9` | COC_9. ¿Ha observado que para obtener el mismo efecto con cocaína ha consumido m | 4 |
| `COC_10` | COC_10. ¿Ha notado que la misma cantidad de cocaína tiene menos efecto en Ud. qu | 4 |
| `COC_11` | COC_11. ¿Ha intentado controlar, disminuir o dejar su consumo de cocaína, pero n | 4 |
| `COC_12` | COC_12. ¿Ha terminado consumiendo cocaína en mayores cantidades o por mayor tiem | 4 |
| `COC_13` | COC_13. ¿Ha dejado de hacer o ha suspendido actividades sociales, laborales o re | 4 |
| `COC_14` | COC_14. ¿Ha dedicado más tiempo que antes a conseguir y consumir cocaína, o pasa | 4 |
| `COC_15` | COC_15. ¿Ha continuado consumiendo cocaína a pesar de que le ocasione problemas | 4 |
| `COC_16` | COC_16. ¿Ha tenido algún problema serio en la casa, en el trabajo o donde estudi | 4 |
| `COC_17` | COC_17. ¿Le ha sucedido que a causa de la cocaína se haya expuesto a algún pelig | 4 |
| `COC_18` | COC_18. ¿Ha hecho algo bajo los efectos de la cocaína que pudiera causarle probl | 4 |
| `COC_19` | COC_19. ¿Ha tenido algún problema o han aumentado los problemas con su familia o | 4 |
| `COC_20` | COC_20. ¿Se ha visto envuelto en alguna pelea a golpes o ha agredido a alguien b | 4 |
| `COC_21` | COC_21. ¿Algún familiar o persona cercana a usted ha resultado dañada física o p | 4 |
| `TUS_1` | TUS_1. ¿Ha probado Ud. tusi o cocaína rosada alguna vez en su vida? | 4 |
| `TUS_2` | TUS_2. ¿Cuándo fue la primera vez que Ud. consumió tusi en su vida? | 5 |
| `TUS_3` | TUS_3. ¿Qué edad tenía cuando probó tusi por primera vez? | 3 |
| `TUS_4` | TUS_4. ¿Cuándo fue la última vez que Ud. consumió tusi? (Respuesta Espontánea) | 5 |
| `TUS_5` | TUS_5. Pensando en la última vez que Ud. consumió Tusi. ¿Cuál era su forma de pr | 9 |
| `TUS_6` | TUS_6. ¿Cuál es la principal vía de administración que Ud. emplea para consumir | 7 |
| `TUS_6_ESP` | TUS_6 Especifique | — |
| `TUS_7` | TUS_7. Pensando solamente en los últimos 30 días, ¿cuántos días del mes ha consu | 3 |
| `TRANS_101` | TRANS_1. Tranquilizantes s/r alguna vez en su vida: Alprazolam | — |
| `TRANS_102` | TRANS_1. Tranquilizantes s/r alguna vez en su vida: Diazepam (Valium) | — |
| `TRANS_103` | TRANS_1. Tranquilizantes s/r alguna vez en su vida: Clonazepam (Ravotril, Valpax | — |
| `TRANS_104` | TRANS_1. Tranquilizantes s/r alguna vez en su vida: Lorazepam (Amparax) | — |
| `TRANS_105` | TRANS_1. Tranquilizantes s/r alguna vez en su vida: Clordiazepóxido | — |
| `TRANS_106` | TRANS_1. Tranquilizantes s/r alguna vez en su vida: Bromazepam | — |
| `TRANS_107` | TRANS_1. Tranquilizantes s/r alguna vez en su vida: Zopiclona (Zolpidem, Somno) | — |
| `TRANS_108` | TRANS_1. Tranquilizantes s/r alguna vez en su vida: Midazolam (Dormonid) | — |
| `TRANS_109` | TRANS_1. Tranquilizantes s/r alguna vez en su vida: Flunitrazepam (Rohypnol, Ipn | — |
| `TRANS_2_1_Rp` | TRANS_2. Tranquilizantes sin receta médica última vez: Alprazolam | 5 |
| `TRANS_2_2_Rp` | TRANS_2. Tranquilizantes sin receta médica última vez: Diazepam (Valium) | 5 |
| `TRANS_2_3_Rp` | TRANS_2. Tranquilizantes sin receta médica última vez: Clonazepam (Ravotril, Val | 5 |
| `TRANS_2_4_Rp` | TRANS_2. Tranquilizantes sin receta médica última vez: Lorazepam (Amparax) | 5 |
| `TRANS_2_5_Rp` | TRANS_2. Tranquilizantes sin receta médica última vez: Clordiazepóxido | 5 |
| `TRANS_2_6_Rp` | TRANS_2. Tranquilizantes sin receta médica última vez: Bromazepam | 5 |
| `TRANS_2_7_Rp` | TRANS_2. Tranquilizantes sin receta médica última vez: Zopiclona (Zolpidem, Somn | 5 |
| `TRANS_2_8_Rp` | TRANS_2. Tranquilizantes sin receta médica última vez: Midazolam (Dormonid) | 5 |
| `TRANS_2_9_Rp` | TRANS_2. Tranquilizantes sin receta médica última vez: Flunitrazepam (Rohypnol, | 5 |
| `TRANS_3` | TRANS_3. Piense en la última vez que Ud. consumió tranquilizantes sin receta méd | 9 |
| `TRANS_4` | TRANS_4. Piense en la última vez que Ud. consumió tranquilizantes sin receta méd | 10 |
| `TRANS_4_ESP` | TRANS_4 Especifique | — |
| `ANALG_11` | ANALG_1. Analgésicos sin receta médica alguna vez en su vida: Tramadol (Tramal) | — |
| `ANALG_12` | ANALG_1. Analgésicos sin receta médica alguna vez en su vida: Codeína (Codetol, | — |
| `ANALG_13` | ANALG_1. Analgésicos sin receta médica alguna vez en su vida: Morfina | — |
| `ANALG_14` | ANALG_1. Analgésicos sin receta médica alguna vez en su vida: Metadona | — |
| `ANALG_15` | ANALG_1. Analgésicos sin receta médica alguna vez en su vida: Petidina | — |
| `ANALG_16` | ANALG_1. Analgésicos sin receta médica alguna vez en su vida: Fentanilo | — |
| `ANALG_17` | ANALG_1. Analgésicos sin receta médica alguna vez en su vida: Oxycodona (OxyCont | — |
| `ANALG_18` | ANALG_1. Analgésicos sin receta médica alguna vez en su vida: Hidrocodona (Vicod | — |
| `ANALG_2_1_Rp` | ANALG_2. Analgésicos sin receta médica última vez: Tramadol (Tramal) | 5 |
| `ANALG_2_2_Rp` | ANALG_2. Analgésicos sin receta médica última vez: Codeína (Codetol, Tosilab, Fl | 5 |
| `ANALG_2_3_Rp` | ANALG_2. Analgésicos sin receta médica última vez: Morfina | 5 |
| `ANALG_2_4_Rp` | ANALG_2. Analgésicos sin receta médica última vez: Metadona | 5 |
| `ANALG_2_5_Rp` | ANALG_2. Analgésicos sin receta médica última vez: Petidina | 5 |
| `ANALG_2_6_Rp` | ANALG_2. Analgésicos sin receta médica última vez: Fentanilo | 5 |
| `ANALG_2_7_Rp` | ANALG_2. Analgésicos sin receta médica última vez: Oxycodona (OxyContin) | 5 |
| `ANALG_2_8_Rp` | ANALG_2. Analgésicos sin receta médica última vez: Hidrocodona (Vicodin) | 5 |
| `ANALG_3` | ANALG_3. Piense en la última vez que Ud. consumió analgésicos sin receta médica, | 9 |
| `ANALG_4` | ANALG_4. Piense en la última vez que Ud. consumió analgésicos sin receta médica, | 10 |
| `ANALG_4_ESP` | ANALG_4 Especifique | — |
| `OD_101` | OD_1. ¿Ha probado Ud. alguna de las siguientes drogas alguna vez en su vida?: Ha | — |
| `OD_102` | OD_1. ¿Ha probado Ud. alguna de las siguientes drogas alguna vez en su vida?: Ma | — |
| `OD_103` | OD_1. ¿Ha probado Ud. alguna de las siguientes drogas alguna vez en su vida?: Éx | — |
| `OD_104` | OD_1. ¿Ha probado Ud. alguna de las siguientes drogas alguna vez en su vida?: Me | — |
| `OD_105` | OD_1. ¿Ha probado Ud. alguna de las siguientes drogas alguna vez en su vida?: He | — |
| `OD_106` | OD_1. ¿Ha probado Ud. alguna de las siguientes drogas alguna vez en su vida?: DM | — |
| `OD_107` | OD_1. ¿Ha probado Ud. alguna de las siguientes drogas alguna vez en su vida?: Cr | — |
| `OD_108` | OD_1. ¿Ha probado Ud. alguna de las siguientes drogas alguna vez en su vida?: Kr | — |
| `OD_109` | OD_1. ¿Ha probado Ud. alguna de las siguientes drogas alguna vez en su vida?: Es | — |
| `OD_2_1_Rp` | OD_2. ¿Cuándo fue la última vez que consumió?: Hachís (resina de cannabis) | 5 |
| `OD_2_2_Rp` | OD_2. ¿Cuándo fue la última vez que consumió?: Marihuana sintética o cannabinoid | 5 |
| `OD_2_3_Rp` | OD_2. ¿Cuándo fue la última vez que consumió?: Éxtasis o MDMA | 5 |
| `OD_2_4_Rp` | OD_2. ¿Cuándo fue la última vez que consumió?: Mefedrona, Metilona o Sales de ba | 5 |
| `OD_2_5_Rp` | OD_2. ¿Cuándo fue la última vez que consumió?: Heroína | 5 |
| `OD_2_6_Rp` | OD_2. ¿Cuándo fue la última vez que consumió?: DMT o Foxy (triptaminas o acetilp | 5 |
| `OD_2_7_Rp` | OD_2. ¿Cuándo fue la última vez que consumió?: Crack | 5 |
| `OD_2_8_Rp` | OD_2. ¿Cuándo fue la última vez que consumió?: Kratom o mitraginina | 5 |
| `OD_2_9_Rp` | OD_2. ¿Cuándo fue la última vez que consumió?: Escopolamina o burundanga | 5 |
| `OD_31` | OD_3. ¿Ha probado estimulantes s/r alguna vez en su vida?: Anfetaminas | — |
| `OD_32` | OD_3. ¿Ha probado estimulantes s/r alguna vez en su vida?: Cidrín | — |
| `OD_33` | OD_3. ¿Ha probado estimulantes s/r alguna vez en su vida?: Modafinilo (Mentix) | — |
| `OD_34` | OD_3. ¿Ha probado estimulantes s/r alguna vez en su vida?: Metilfenidato (Ritali | — |
| `OD_35` | OD_3. ¿Ha probado estimulantes s/r alguna vez en su vida?: Escancil | — |
| `OD_36` | OD_3. ¿Ha probado estimulantes s/r alguna vez en su vida?: Pemolina (Cylert) | — |
| `OD_37` | OD_3. ¿Ha probado estimulantes s/r alguna vez en su vida?: Anfepramona (Fenpropo | — |
| `OD_4_1_Rp` | OD_4. ¿Cuándo fue la última vez que consumió sin receta médica?: Anfetaminas | 5 |
| `OD_4_2_Rp` | OD_4. ¿Cuándo fue la última vez que consumió sin receta médica?: Cidrín | 5 |
| `OD_4_3_Rp` | OD_4. ¿Cuándo fue la última vez que consumió sin receta médica?: Modafinilo (Men | 5 |
| `OD_4_4_Rp` | OD_4. ¿Cuándo fue la última vez que consumió sin receta médica?: Metilfenidato ( | 5 |
| `OD_4_5_Rp` | OD_4. ¿Cuándo fue la última vez que consumió sin receta médica?: Escancil | 5 |
| `OD_4_6_Rp` | OD_4. ¿Cuándo fue la última vez que consumió sin receta médica?: Pemolina (Cyler | 5 |
| `OD_4_7_Rp` | OD_4. ¿Cuándo fue la última vez que consumió sin receta médica?: Anfepramona (Fe | 5 |
| `OD_51` | OD_5. ¿Ha probado metanfetaminas alguna vez en su vida?: Meth, Crystal o Speed ( | — |
| `OD_52` | OD_5. ¿Ha probado metanfetaminas alguna vez en su vida?: Cristina, Anteta o Crac | — |
| `OD_6_1_Rp` | OD_6. ¿Cuándo fue la última vez que consumió?: Meth, Crystal o Speed (Hielo, Ice | 5 |
| `OD_6_2_Rp` | OD_6. ¿Cuándo fue la última vez que consumió?: Cristina, Anteta o Crack Mexicano | 5 |
| `OD_701` | OD_7. ¿Ha probado sustancias inhalables alguna vez en su vida?: Neoprén | — |
| `OD_702` | OD_7. ¿Ha probado sustancias inhalables alguna vez en su vida?: Bencina o parafi | — |
| `OD_703` | OD_7. ¿Ha probado sustancias inhalables alguna vez en su vida?: Tolueno | — |
| `OD_704` | OD_7. ¿Ha probado sustancias inhalables alguna vez en su vida?: Desodorantes amb | — |
| `OD_705` | OD_7. ¿Ha probado sustancias inhalables alguna vez en su vida?: Pinturas en spra | — |
| `OD_706` | OD_7. ¿Ha probado sustancias inhalables alguna vez en su vida?: Acetona | — |
| `OD_707` | OD_7. ¿Ha probado sustancias inhalables alguna vez en su vida?: Éter u otros sol | — |
| `OD_708` | OD_7. ¿Ha probado sustancias inhalables alguna vez en su vida?: Poppers (nitrito | — |
| `OD_709` | OD_7. ¿Ha probado sustancias inhalables alguna vez en su vida?: Solventes para e | — |
| `OD_710` | OD_7. ¿Ha probado sustancias inhalables alguna vez en su vida?: Cloruro de etilo | — |
| `OD_711` | OD_7. ¿Ha probado sustancias inhalables alguna vez en su vida?: Óxido nitroso (g | — |
| `OD_8_1_Rp` | OD_8. ¿Cuándo fue la última vez que consumió?: Neoprén | 5 |
| `OD_8_2_Rp` | OD_8. ¿Cuándo fue la última vez que consumió?: Bencina o parafina | 5 |
| `OD_8_3_Rp` | OD_8. ¿Cuándo fue la última vez que consumió?: Tolueno | 5 |
| `OD_8_4_Rp` | OD_8. ¿Cuándo fue la última vez que consumió?: Desodorantes ambientales o corpor | 5 |
| `OD_8_5_Rp` | OD_8. ¿Cuándo fue la última vez que consumió?: Pinturas en spray | 5 |
| `OD_8_6_Rp` | OD_8. ¿Cuándo fue la última vez que consumió?: Acetona | 5 |
| `OD_8_7_Rp` | OD_8. ¿Cuándo fue la última vez que consumió?: Éter u otros solventes volátiles | 5 |
| `OD_8_8_Rp` | OD_8. ¿Cuándo fue la última vez que consumió?: Poppers (nitritos de alquilo) | 5 |
| `OD_8_9_Rp` | OD_8. ¿Cuándo fue la última vez que consumió?: Solventes para extintores de ince | 5 |
| `OD_8_10_Rp` | OD_8. ¿Cuándo fue la última vez que consumió?: Cloruro de etilo | 5 |
| `OD_8_11_Rp` | OD_8. ¿Cuándo fue la última vez que consumió?: Óxido nitroso (gas de la risa o h | 5 |
| `OD_901` | OD_9. ¿Ha probado alucinógenos alguna vez en su vida?: LSD, tripi, sello u otros | — |
| `OD_902` | OD_9. ¿Ha probado alucinógenos alguna vez en su vida?: Polvo de ángel (PCP o fen | — |
| `OD_903` | OD_9. ¿Ha probado alucinógenos alguna vez en su vida?: 25B-NBOMe o 25C-NBOMe (Nb | — |
| `OD_904` | OD_9. ¿Ha probado alucinógenos alguna vez en su vida?: Feniletilamina (2-CB) | — |
| `OD_905` | OD_9. ¿Ha probado alucinógenos alguna vez en su vida?: Peyote, San Pedro | — |
| `OD_906` | OD_9. ¿Ha probado alucinógenos alguna vez en su vida?: Floripondio | — |
| `OD_907` | OD_9. ¿Ha probado alucinógenos alguna vez en su vida?: Hongos o Cucumelo | — |
| `OD_908` | OD_9. ¿Ha probado alucinógenos alguna vez en su vida?: Mescalina | — |
| `OD_909` | OD_9. ¿Ha probado alucinógenos alguna vez en su vida?: Belladona | — |
| `OD_910` | OD_9. ¿Ha probado alucinógenos alguna vez en su vida?: Ayahuasca | — |
| `OD_10_1_Rp` | OD_10. ¿Cuándo fue la última vez que consumió?: LSD, tripi, sello u otros ácidos | 5 |
| `OD_10_2_Rp` | OD_10. ¿Cuándo fue la última vez que consumió?: Polvo de ángel (PCP o fenciclidi | 5 |
| `OD_10_3_Rp` | OD_10. ¿Cuándo fue la última vez que consumió?: 25B-NBOMe o 25C-NBOMe (Nboom) | 5 |
| `OD_10_4_Rp` | OD_10. ¿Cuándo fue la última vez que consumió?: Feniletilamina (2-CB) | 5 |
| `OD_10_5_Rp` | OD_10. ¿Cuándo fue la última vez que consumió?: Peyote, San Pedro | 5 |
| `OD_10_6_Rp` | OD_10. ¿Cuándo fue la última vez que consumió?: Floripondio | 5 |
| `OD_10_7_Rp` | OD_10. ¿Cuándo fue la última vez que consumió?: Hongos o Cucumelo | 5 |
| `OD_10_8_Rp` | OD_10. ¿Cuándo fue la última vez que consumió?: Mescalina | 5 |
| `OD_10_9_Rp` | OD_10. ¿Cuándo fue la última vez que consumió?: Belladona | 5 |
| `OD_10_10_Rp` | OD_10. ¿Cuándo fue la última vez que consumió?: Ayahuasca | 5 |
| `OD_111` | OD_11. ¿Ha probado medicamentos s/r alguna vez en su vida?: Fluoxetina (Pragmate | — |
| `OD_112` | OD_11. ¿Ha probado medicamentos s/r alguna vez en su vida??: Clormezanona (Calmo | — |
| `OD_113` | OD_11. ¿Ha probado medicamentos s/r alguna vez en su vida??: Sedantol | — |
| `OD_114` | OD_11. ¿Ha probado medicamentos s/r alguna vez en su vida??: Dietilpropión o Fen | — |
| `OD_115` | OD_11. ¿Ha probado medicamentos s/r alguna vez en su vida??: Quetiapina | — |
| `OD_116` | OD_11. ¿Ha probado medicamentos s/r alguna vez en su vida??: Clorpromazina | — |
| `OD_12_1_Rp` | OD_12. ¿Cuándo fue la última vez que consumió sin receta médica?: Fluoxetina (Pr | 5 |
| `OD_12_2_Rp` | OD_12. ¿Cuándo fue la última vez que consumió sin receta médica?: Clormezanona ( | 5 |
| `OD_12_3_Rp` | OD_12. ¿Cuándo fue la última vez que consumió sin receta médica?: Sedantol | 5 |
| `OD_12_4_Rp` | OD_12. ¿Cuándo fue la última vez que consumió sin receta médica?: Dietilpropión | 5 |
| `OD_12_5_Rp` | OD_12. ¿Cuándo fue la última vez que consumió sin receta médica?: Quetiapina | 5 |
| `OD_12_6_Rp` | OD_12. ¿Cuándo fue la última vez que consumió sin receta médica?: Clorpromazina | 5 |
| `OD_1301` | OD_13. ¿Ha probado Ud. alguna de las siguientes sustancias alguna vez en su vida | — |
| `OD_1302` | OD_13. ¿Ha probado Ud. alguna de las siguientes sustancias alguna vez en su vida | — |
| `OD_1303` | OD_13. ¿Ha probado Ud. alguna de las siguientes sustancias alguna vez en su vida | — |
| `OD_1304` | OD_13. ¿Ha probado Ud. alguna de las siguientes sustancias alguna vez en su vida | — |
| `OD_1305` | OD_13. ¿Ha probado Ud. alguna de las siguientes sustancias alguna vez en su vida | — |
| `OD_1306` | OD_13. ¿Ha probado Ud. alguna de las siguientes sustancias alguna vez en su vida | — |
| `OD_1307` | OD_13. ¿Ha probado Ud. alguna de las siguientes sustancias alguna vez en su vida | — |
| `OD_1308` | OD_13. ¿Ha probado Ud. alguna de las siguientes sustancias alguna vez en su vida | — |
| `OD_1309` | OD_13. ¿Ha probado Ud. alguna de las siguientes sustancias alguna vez en su vida | — |
| `OD_1310` | OD_13. ¿Ha probado Ud. alguna de las siguientes sustancias alguna vez en su vida | — |
| `OD_1311` | OD_13. ¿Ha probado Ud. alguna de las siguientes sustancias alguna vez en su vida | — |
| `OD_14_1_Rp` | OD_14. ¿Cuándo fue la última vez que consumió?: Bebidas Energéticas (Battery, Re | 5 |
| `OD_14_2_Rp` | OD_14. ¿Cuándo fue la última vez que consumió?: Bebida Energética combinada con | 5 |
| `OD_14_3_Rp` | OD_14. ¿Cuándo fue la última vez que consumió?: Sibutramina | 5 |
| `OD_14_4_Rp` | OD_14. ¿Cuándo fue la última vez que consumió?: Tonaril sin receta médica (Trihe | 5 |
| `OD_14_5_Rp` | OD_14. ¿Cuándo fue la última vez que consumió?: Anabólicos | 5 |
| `OD_14_6_Rp` | OD_14. ¿Cuándo fue la última vez que consumió?: Esteroides | 5 |
| `OD_14_7_Rp` | OD_14. ¿Cuándo fue la última vez que consumió?: Ketamina (“el key”, vitamina K o | 5 |
| `OD_14_8_Rp` | OD_14. ¿Cuándo fue la última vez que consumió?: GHB | 5 |
| `OD_14_9_Rp` | OD_14. ¿Cuándo fue la última vez que consumió?: PCP (Fenciclidina) | 5 |
| `OD_14_10_Rp` | OD_14. ¿Cuándo fue la última vez que consumió?: BZP (Benzilpiperazina) | 5 |
| `OD_14_11_Rp` | OD_14. ¿Cuándo fue la última vez que consumió?: GBL o Éxtasis líquido (Gammabuti | 5 |
| `OD_15` | OD_15. ¿Alguna vez en su vida se ha inyectado alguna droga o sustancia? | — |
| `CC_1` | CC_1. ¿Tiene licencia de conducir? | 4 |
| `CC_2` | CC_2. Durante los últimos 12 meses, ¿ha manejado algún vehículo después de haber | 4 |
| `CC_3` | CC_3. Durante los últimos 12 meses, ¿ha manejado algún vehículo después de haber | 4 |
| `CC_4` | CC_4. Durante los últimos 12 meses, ¿ha manejado algún vehículo después de haber | 4 |
| `CC_4_ESP` | CC_4. Especifique | — |
| `T_SG_1_C` | SG_1. ¿Ha sentido que está jugando un papel útil en la vida? | 4 |
| `T_SG_1_D` | SG_1. ¿Se ha sentido capaz de tomar decisiones? | 4 |
| `T_SG_1_G` | SG_1. ¿Ha sido capaz de disfrutar sus actividades normales cada día? | 4 |
| `T_SG_1_H` | SG_1. ¿Ha sido capaz de hacer frente a sus problemas? | 4 |
| `T_SG_1_B` | SG_1. ¿Sus preocupaciones le han hecho perder mucho sueño? | 4 |
| `T_SG_1_E` | SG_1. ¿Se ha sentido constantemente agobiado/a o en tensión? | 4 |
| `T_SG_1_F` | SG_1. ¿Ha sentido que no puede superar sus dificultades? | 4 |
| `T_SG_1_I` | SG_1. ¿Se ha sentido poco feliz y deprimido/a? | 4 |
| `T_SG_1_J` | SG_1. ¿Ha perdido confianza en sí mismo? | 4 |
| `T_SG_1_K` | SG_1. ¿Ha pensado que usted es una persona que no vale para nada? | 4 |
| `T_SG_1_A` | SG_1. ¿Ha podido concentrarse bien en lo que hace? | 4 |
| `T_SG_1_L` | SG_1. ¿Se siente razonablemente feliz considerando todas las circunstancias? | 4 |
| `SG_2` | SG_2. En los últimos 12 meses, ¿Un médico le ha recetado cannabis como parte de | 2 |
| `TRATA_1` | TRATA_1. ¿Ha recibido Ud. alguna vez en su vida algún tipo de tratamiento por el | 2 |
| `TRATA_2` | TRATA_2. ¿Durante los últimos 12 meses ha recibido Ud. algún tipo de tratamiento | 2 |
| `TRATA_3` | TRATA_3. ¿Este tratamiento que Ud. recibió durante los últimos 12 meses fue sólo | 3 |
| `TRATA_4` | TRATA_4. Durante los últimos 12 meses, ¿Ha sentido la necesidad de recibir algún | 4 |
| `TRATA_5` | TRATA_5. Durante los últimos 12 meses, ¿Ha intentado obtener algún tipo de ayuda | 4 |
| `T_PR_1_1` | PR_1. ¿Cuál cree Ud. que es el riesgo que corre una persona que: Fuma una o más | 5 |
| `T_PR_1_2` | PR_1. ¿Cuál cree Ud. que es el riesgo que corre una persona que: Toma tres o más | 5 |
| `T_PR_1_3` | PR_1. ¿Cuál cree Ud. que es el riesgo que corre una persona que: Toma cinco o má | 5 |
| `T_PR_1_4` | PR_1. ¿Cuál cree Ud. que es el riesgo que corre una persona que: Prueba marihuan | 5 |
| `T_PR_1_5` | PR_1. ¿Cuál cree Ud. que es el riesgo que corre una persona que: Fuma marihuana | 5 |
| `T_PR_1_6` | PR_1. ¿Cuál cree Ud. que es el riesgo que corre una persona que: Prueba cocaína | 5 |
| `T_PR_1_7` | PR_1. ¿Cuál cree Ud. que es el riesgo que corre una persona que: Usa cocaína fre | 5 |
| `T_PR_1_8` | PR_1. ¿Cuál cree Ud. que es el riesgo que corre una persona que: Prueba pasta ba | 5 |
| `T_PR_1_9` | PR_1. ¿Cuál cree Ud. que es el riesgo que corre una persona que: Usa pasta base | 5 |
| `T_PR_1_10` | PR_1. ¿Cuál cree Ud. que es el riesgo que corre una persona que: Prueba éxtasis | 5 |
| `T_PR_1_11` | PR_1. ¿Cuál cree Ud. que es el riesgo que corre una persona que: Usa éxtasis fre | 5 |
| `T_PR_1_12` | PR_1. ¿Cuál cree Ud. que es el riesgo que corre una persona que: Prueba tusi una | 5 |
| `T_PR_1_13` | PR_1. ¿Cuál cree Ud. que es el riesgo que corre una persona que: Usa tusi frecue | 5 |
| `EB_1` | EB_1 Hasta donde Ud. sabe, ¿alguien en su casa, distinto de usted, ha tenido pro | 6 |
| `T_EB_2_1` | EB_2. En su casa, y hasta donde Ud. conoce, ¿alguien usa o consume alguna de est | 4 |
| `T_EB_2_2` | EB_2. En su casa, y hasta donde Ud. conoce, ¿alguien usa o consume alguna de est | 4 |
| `T_EB_2_3` | EB_2. En su casa, y hasta donde Ud. conoce, ¿alguien usa o consume alguna de est | 4 |
| `T_EB_3_1` | EB_3 Hasta donde Ud. conoce, ¿cuánto hay de las siguientes situaciones en su bar | 7 |
| `T_EB_3_2` | EB_3 Hasta donde Ud. conoce, ¿cuánto hay de las siguientes situaciones en su bar | 7 |
| `T_EB_3_3` | EB_3 Hasta donde Ud. conoce, ¿cuánto hay de las siguientes situaciones en su bar | 7 |
| `T_EB_3_4` | EB_3 Hasta donde Ud. conoce, ¿cuánto hay de las siguientes situaciones en su bar | 7 |
| `T_EB_3_5` | EB_3 Hasta donde Ud. conoce, ¿cuánto hay de las siguientes situaciones en su bar | 7 |
| `T_EB_3_6` | EB_3 Hasta donde Ud. conoce, ¿cuánto hay de las siguientes situaciones en su bar | 7 |
| `T_EB_3_7` | EB_3 Hasta donde Ud. conoce, ¿cuánto hay de las siguientes situaciones en su bar | 7 |
| `T_EB_3_8` | EB_3 Hasta donde Ud. conoce, ¿cuánto hay de las siguientes situaciones en su bar | 7 |
| `T_EB_4_1` | EB_4 ¿Cuán difícil le sería a Ud. conseguir alguna de las siguientes drogas?  Ma | 7 |
| `T_EB_4_2` | EB_4 ¿Cuán difícil le sería a Ud. conseguir alguna de las siguientes drogas?  Co | 7 |
| `T_EB_4_3` | EB_4 ¿Cuán difícil le sería a Ud. conseguir alguna de las siguientes drogas?  Pa | 7 |
| `T_EB_4_4` | EB_4 ¿Cuán difícil le sería a Ud. conseguir alguna de las siguientes drogas?  Éx | 7 |
| `T_EB_4_5` | EB_4 ¿Cuán difícil le sería a Ud. conseguir alguna de las siguientes drogas?  Tu | 7 |
| `T_EB_5_1` | EB_5 ¿Y cuándo fue la última vez que una persona, conocida o desconocida, le ofr | 4 |
| `T_EB_5_2` | EB_5 ¿Y cuándo fue la última vez que una persona, conocida o desconocida, le ofr | 4 |
| `T_EB_5_3` | EB_5 ¿Y cuándo fue la última vez que una persona, conocida o desconocida, le ofr | 4 |
| `T_EB_5_4` | EB_5 ¿Y cuándo fue la última vez que una persona, conocida o desconocida, le ofr | 4 |
| `T_EB_5_5` | EB_5 ¿Y cuándo fue la última vez que una persona, conocida o desconocida, le ofr | 4 |
| `T_EB_6_1` | EB_6 La última vez que le ofrecieron, ¿en qué lugar se la ofrecieron?: Marihuana | 7 |
| `T_EB_6_2` | EB_6 La última vez que le ofrecieron, ¿en qué lugar se la ofrecieron?: Cocaína | 7 |
| `T_EB_6_3` | EB_6 La última vez que le ofrecieron, ¿en qué lugar se la ofrecieron?: Pasta bas | 7 |
| `T_EB_6_4` | EB_6 La última vez que le ofrecieron, ¿en qué lugar se la ofrecieron?: Extasis | 7 |
| `T_EB_6_5` | EB_6 La última vez que le ofrecieron, ¿en qué lugar se la ofrecieron?: Tusi o co | 7 |
| `T_OP_1_1` | OP_1. ¿Cuán de acuerdo estás con las siguientes frases?: La mayoría de los jóven | 6 |
| `T_OP_1_2` | OP_1. ¿Cuán de acuerdo estás con las siguientes frases?: La marihuana produce me | 6 |
| `T_OP_1_3` | OP_1. ¿Cuán de acuerdo estás con las siguientes frases?: El consumo y el tráfico | 6 |
| `T_OP_1_4` | OP_1. ¿Cuán de acuerdo estás con las siguientes frases?: La marihuana debería se | 6 |
| `T_OP_1_5` | OP_1. ¿Cuán de acuerdo estás con las siguientes frases?: Las drogas han hecho má | 6 |
| `T_OP_1_6` | OP_1. ¿Cuán de acuerdo estás con las siguientes frases?: Se debería dejar tranqu | 6 |
| `T_OP_2_1` | OP_2. ¿Cuán de acuerdo está Ud. con las siguientes medidas?: Suspender el juicio | 6 |
| `T_OP_2_2` | OP_2. ¿Cuán de acuerdo está Ud. con las siguientes medidas?: Dar la misma pena a | 6 |
| `T_OP_2_3` | OP_2. ¿Cuán de acuerdo está Ud. con las siguientes medidas?: Autorizar que se re | 6 |
| `T_OP_2_4` | OP_2. ¿Cuán de acuerdo está Ud. con las siguientes medidas?: Penalizar el porte | 6 |
| `CO_1` | CO_1. La semana pasada, ¿trabajó al menos una hora, sin considerar los quehacere | 2 |
| `CO_2` | CO_2. Aunque no trabajó la semana pasada, ¿realizó alguna actividad por lo menos | 2 |
| `CO_3` | CO_3. Aunque no trabajó la semana pasada, ¿tenía empleo del cual estuvo ausente | 2 |
| `CO_4` | CO_4. ¿Buscó trabajo remunerado o realizó alguna gestión para iniciar una activi | 2 |
| `CO_5` | CO_5. ¿Cuál es la razón por la que no buscó trabajo o realizó alguna gestión par | 23 |
| `CO_6` | CO_6. En su trabajo o negocio principal, ¿usted trabaja como? | 9 |
| `DP_1` | DP_1. ¿Cuántas personas viven en este hogar? | 2 |
| `DP_2` | DP_2. ¿Cuál es su estado civil actual (legal)? | 6 |
| `DP_3` | DP_3. ¿Actualmente cuál es su estado de hecho? | 4 |
| `DP_4` | DP_4. En Chile, la ley reconoce nueve pueblos indígenas (originarios), ¿pertenec | 13 |
| `DP_5` | DP_5. ¿Cuál es su religión o credo? | 12 |
| `DP_6` | DP_6. ¿Cuál es su nacionalidad? | 3 |
| `DP_6_ESP` | DP_6_ESP Especifique | — |
| `DP_6A` | DP_6A. Cuando usted nació, ¿en qué comuna o país vivía su madre? | 4 |
| `DP_6A_ESP` | DP_6A_ESP Especifique | — |
| `DP_6B` | DP_6B. ¿En qué comuna o país vivía usted hace 5 años ...? | 4 |
| `DP_6B_ESP` | DP_6B_ESP Especifique | — |
| `DP_8` | DP_8. En cuánto a su género, ¿usted se identifica como? | 7 |
| `DP_8_ESP` | DP_8_ESP Especifique | — |
| `DP_8A` | DP_8A. ¿Ud. se identifica como trans? | 4 |
| `DP_8B` | DP_8B. ¿Cuál de estas alternativas define mejor su orientación sexual? (ENCUESTA | 6 |
| `DP_8B_ESP` | DP_8B_ESP Especifique | — |
| `DP_9` | DP_9. ¿A qué sistema previsional de salud pertenece usted? | 11 |
| `DP_10` | DP_10. ¿Qué relación de parentesco tiene con el/la jefe/a de hogar? Jefe de hoga | 13 |
| `DP_11` | DP_11. Actualmente, ¿asiste a algún establecimiento educacional? | 4 |
| `DP_12` | DP_12. ¿Cuál es el nivel educacional más alto alcanzado o el nivel educacional a | 14 |
| `DP_13` | DP_13. ¿Completó el nivel educacional anteriormente declarado? | 3 |
| `DP_14` | DP_14. En este nivel educacional ¿Cuál fue el último curso que aprobó? | 12 |
| `DP_15` | DP_15. ¿Cuál de estas situaciones se aplica mejor a su caso? | 7 |
| `DP_16` | DP_16. Aproximadamente y considerando un mes normal, ¿a cuánto asciende el ingre | 12 |
| `DP_17` | DP_17. Calidad de la vivienda | — |
| `DP_18` | DP_18. Calidad del barrio | — |
| `FACTOR_EXPANSION` |  | — |
| `UPM` | Unidad Primaria de Muestreo | — |
| `ESTRATO` | Estrato | — |
| `AÑO` |  | — |

