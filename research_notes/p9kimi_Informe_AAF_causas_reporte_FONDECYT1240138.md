KIMI-P9 | búsqueda: 2026-10-07 | 7 referencias leídas a texto completo o en extractos extensos del texto completo (Shield 2025 texto principal + Apéndice 1; guía InterMAHP 2017; Gawryszewski 2014; WCRF/AICR CUP 2018; Rehm 2016; OMS GSRAH 2011) / 19 leídas solo en resumen o ficha bibliográfica

# Justificación de decisiones de reporte y lista de causas para el estudio de mortalidad atribuible al alcohol (FONDECYT 1240138)

**Convenciones.** [TEXTO] = la fuente lo afirma literalmente (con cita breve cuando procede); [INFERENCIA] = deducción del equipo a partir de lo anterior. «(solo resumen)» marca referencias leídas únicamente en resumen/ficha. Los números citados llevan población/unidad/denominador/período cuando la fuente los da. Páginas de Shield 2025 refieren al PDF del Apéndice 1 (p. del PDF = p. del apéndice + 1).

---

## 1. Tabla de veredictos por decisión

| Decisión | Opción | Apoyo | Referencias clave | Por qué |
|---|---|---|---|---|
| **D-a** [Q1] | **Reportar FAA netas con signo como estimación principal Y añadir estimación «solo daño» (bruta) como análisis complementario** | **Fuerte** | Shield 2025 (DOI 10.1016/S2468-2667(25)00174-4); OMS GSRAH 2011; Rehm 2011 (10.1111/j.1360-0443.2011.03605.x); Sherk 2019 (10.3390/ijerph16244956); GBD 2020 (10.1016/S0140-6736(22)00847-9) | La convención OMS/CRA es modelar «both the detrimental and protective health effects» y reportar valores con signo (p. ej., ACV isquémico −65·5 mil muertes) [TEXTO]. Pero la magnitud neta es muy sensible al supuesto de cardioprotección (Australia: 2 933–4 570 muertes netas según escenario) [TEXTO (solo resumen)], de modo que acompañar con la cifra «solo daño» es práctica documentada y aumenta transparencia sin contradecir el estándar. |
| **D-b** [Q2] | **Estómago (C16) y páncreas (C25) FUERA de la estimación principal; análisis de sensibilidad etiquetado con el alcance IARC/WCRF/Shield** | **Fuerte** | Shield 2025 Apéndice 1, Tabla S6 (p. 60 apéndice); WCRF/AICR CUP 2018; Bagnardi 2015 (10.1038/bjc.2014.579); Rumgay 2021 (10.1016/S1470-2045(21)00279-5) | La Tabla S6 de Shield 2025 **no incluye filas para C16 ni C25** (la numeración salta de «2 Oesophagus» a «4 Colon and rectum» y de «5 Liver» a «9 Breast») [TEXTO, leído en PDF]. IARC no clasifica estómago/páncreas como causados por alcohol; WCRF: estómago «probable» solo ≥45 g/día, páncreas «limitado-sugerente». Incluirlos en la estimación principal desviaría el estudio del marco OMS 2024 que se usa para las RR. |
| **D-c** [Q2/Q11] | **Excluir cérvix (C53) justificando «sin RR utilizable», no «no causal»** | **Fuerte** | Shield 2025 Tabla S6 + figs. S2–S61; Bagnardi 2015; WCRF/AICR CUP 2018 | C53 aparece en S6 pero con fuente de RR n.º 21, que es el artículo de modelado de **VIH** (Rehm 2017) — incongruencia editorial— y **no existe figura de función RR para cérvix** en el apéndice [TEXTO, leído en PDF]. Bagnardi 2015: asociación no significativa (5 estudios) (solo resumen); WCRF: evidencia «demasiado limitada». No hay función dosis-respuesta publicada y validada: la justificación correcta es «no usable RR». |
| **D-d** [Q4/Q9] | **Mantener mapeo por máxima superposición (estrato 60–65 → banda RR 35–64), documentándolo como limitación** | **Moderado-fuerte** | Sherk 2017 (guía InterMAHP, pp. 22–23); Shield 2025 (Methods); Rehm 2016 | InterMAHP fija subgrupos «gender by age groups 15 to 34, 35 to 64, 65+» [TEXTO]; OMS 2024 modela exposición en 15–19/20–24/25–34/35–49/50–64/≥65 y aplica las FAA a grupos de mortalidad «encompassed within the alcohol population-attributable fraction age groupings» [TEXTO], es decir, por contención/superposición, no por coincidencia exacta. Solo EIC y ACV isquémico tienen RR por bandas de edad (figs. S25–S36); el resto usa una función única. |
| **D-e** [Q5/Q22] | **Documentar procedencia de cada función RR sin reemplazarlas** | **Fuerte** | Shield 2025 Tabla S6 + lista de referencias del apéndice (pp. 119–122) | S6 identifica la publicación de origen de cada RR; la tabla de la sección Q5 la reproduce con DOI verificados. Sustituir funciones rompería la coherencia con el marco OMS/TAG (RR «selected by the WHO Technical Advisory Group on the basis of majority consensus» [TEXTO]). |

## 1b. Tabla de parámetros

| ID | Parámetro/decisión | Valor/opción | Fuente (DOI + página/tabla) | Estimado/Asumido | Transportabilidad a Chile |
|---|---|---|---|---|---|
| P1 | Distribución del consumo | Gamma; integración 0,1–150 g/día (límite superior 150 g) | Shield 2025, DOI 10.1016/S2468-2667(25)00174-4, Apéndice 1 p. 57 («upper integration limit of 150 grams») [TEXTO]; método de Kehoe 2012 (Popul Health Metr 10:6) | Asumido (convención) | **Alta**: convención internacional CRA; la encuesta SENDA aporta la media/prevalencias locales. |
| P2 | Factor de corrección del APC | 0,8 | Shield 2025, Methods [TEXTO: «A correction factor of 0·8 was applied to APC data»]; base: Stockwell 2018 (Addiction 113:2245-9) | Asumido | **Alta**: corrige subcobertura encuesta vs. ventas; aplicable a Chile igual que a otros países. |
| P3 | Fórmula de FAA | Levin-PAF con exbebedores: numerador P_FD(RR_FD−1) + ∫P(x)[RR(x)−1]dx | Shield 2025 Apéndice 1, Fórmula S3 (p. 57); Sherk 2017 Fórmula 3.5 | Asumido (convención) | **Alta**: fórmula estándar; requiere prevalencias SENDA de exbebedores/abstemios. |
| P4 | Bandas de edad de las RR | 15–34 / 35–64 / ≥65 **solo** para EIC y ACV isquémico; función única para las demás causas | Shield 2025 Apéndice 1, figs. S25–S36 vs. S2–S24, S37–S45 [TEXTO, leído en PDF] | Estimado (de las figuras) | **Alta**: estructura del modelo, independiente del país. |
| P5 | Latencia («lag») | Sin lag, salvo cáncer: 10 años | Shield 2025, Methods [TEXTO: «no lag time… except for cancer, where a 10-year lag… was modelled»] | Asumido | **Alta**: convención; implica asumir reversibilidad inmediata del riesgo al cesar (no hay función de decadencia publicada para la mayoría de las causas). |
| P6 | Mapeo edad encuesta→banda RR | Por contención/máxima superposición | Shield 2025, Methods [TEXTO: «encompassed within the alcohol population-attributable fraction age groupings»] | Asumido (convención) | **Alta**: el estrato SENDA 60–65 cae dentro de 35–64; sesgo esperado pequeño porque solo EIC/ACVi usan bandas. |
| P7 | RR de hipertensión aplicada a mortalidad I10–I15 | Función de incidencia de hipertensión (Roerecke 2018) aplicada a «hypertensive heart disease» | Sherk 2017 pp. 72–73 [TEXTO: «Hypertension… ICD10 codes: I10 to I15… Sources Roerecke… (in press)»]; publicada como Roerecke 2018, DOI 10.1161/JAHA.117.008202 (solo resumen); S6 cita OMS GSRAH 2018 (ref. 40) | Estimado | **Media**: asume RR(incidencia)≈RR(mortalidad) y que I11/I13 responden como hipertensión esencial; es la convención InterMAHP/OMS, no una validación chilena. |
| P8 | RR de exbebedores, cáncer de hígado | ≈2,2 (H) / ≈2,6 (M), leídos de figs. S14–S15 (usuario: 2,23/2,68) | Shield 2025 Apéndice 1, figs. S14–S15 [TEXTO gráfico, leído en imagen]; S6 atribuye la causa a WCRF/AICR CUP 2018 | Estimado (gráfico) | **Media**: CUP publica 2,58 (1,76–3,77) combinado; los valores sexo-específicos exactos no aparecen impresos (ver sección 8). |
| P9 | RR de exbebedores, EIC | 1,25 (1,15–1,36) H; 1,54 (1,17–2,03) M | Roerecke & Rehm 2011, DOI 10.1093/aje/kwq364, citado en S6 ref. 45 [TEXTO vía PMC4203905] | Estimado | **Media-alta**: meta-análisis internacional; no hay estimación chilena. |
| P10 | RR de diabetes | Función DM2 aplicada a mortalidad por diabetes agregada (DM1+DM2) | Shield 2025, Discussion [TEXTO: «might represent an overestimate»]; fuente RR: Llamosas-Falcón et al., «In Preperation» (S6 ref. 33) — NO PUBLICADA | Estimado | **Media**: GHE no separa DM1/DM2; declarar posible sobreestimación (misma limitación aplica a Chile/DEIS). |
| P11 | Modificadores por HED («binge») | Fórmulas S4–S5 con prevalencia de HED; InterMAHP: factores 1,49 (MVC) / 1,70 (intencional) / 1,48 (no intencional) | Shield 2025 Apéndice 1 p. 57; Sherk 2017 (hojas de lesiones) [TEXTO] | Estimado | **Media**: los factores derivan de estudios de urgencias internacionales (OMS 2009); la prevalencia HED es local (SENDA). |
| P12 | Causas 100 % atribuibles | FAA = 1,0 para trastornos por uso de alcohol y miocardiopatía alcohólica | Shield 2025, tabla principal (PAF 100·0) [TEXTO] | Asumido | **Alta**: por definición CIE-10. |

---

## 2. Respuestas Q1–Q5

### Q1. ¿Cómo reportan OMS/GBD/InterMAHP las FAA netas con efectos protectores frente a «solo daño»? ¿Es estándar reportar ambas?

OMS 2011 reportó el total **neto**: «2.5 million deaths each year, with a net loss of life of 2.25 million, taking into account the estimated beneficial impact» [TEXTO, página oficial]. Rehm 2011 tabuló por separado «detrimental» (1 406 mil muertes ENT) y «beneficial» (−227 mil) antes del neto [TEXTO, Tabla 1]. Shield 2025 (marco OMS 2024) modela «both the detrimental and protective health effects» y reporta valores con signo por causa (diabetes −5·2 mil; ACV isquémico −65·5 mil; nota: «Negative values represent deaths and DALYs avoided») [TEXTO]. GBD 2020 integra protección vía TMREL/NDE (solo resumen). Sherk 2019 muestra que el neto es muy sensible al supuesto cardioprotector (Australia 2 933–4 570 muertes) (solo resumen). [INFERENCIA] El estándar es el neto con signo; añadir «solo daño» es sensibilidad documentada, no el reporte por defecto.

### Q2. Evidencia causal para estómago, páncreas y cérvix; ¿por qué está cérvix en la Tabla S6 y de qué fuente de RR depende?

IARC (vols. 96/100E, S6 refs. 28–29) reconoce causalidad para cavidad oral, faringe, esófago, colorrecto, laringe, hígado y mama; **no** para estómago, páncreas ni cérvix [TEXTO, lista IARC]. WCRF/AICR CUP 2018: estómago **«probable»** solo ≥45 g/día (RR 1,02 por 10 g/día, NS), páncreas **«limitado-sugerente»** (~60 g/día, 1,17), cérvix «evidencia demasiado limitada» [TEXTO]. Bagnardi 2015: bebedores intensos estómago 1,21 y páncreas 1,19 (significativos); cérvix no significativa (5 estudios) (solo resumen). Rumgay 2021 **sí incluyó estómago** (76 700 casos en 2020) [TEXTO, resumen]. Cérvix figura en S6 con fuente de RR n.º 21 —el artículo de modelado de VIH de Rehm 2017— y sin figura de función: incongruencia editorial [TEXTO, leído en PDF]; la tabla principal reporta PAF 0,5 % sin función documentada.

### Q3. ¿Es estándar aplicar la RR de hipertensión (Liu 2020 / Roerecke) a la mortalidad por cardiopatía hipertensiva?

Sí es la convención InterMAHP/OMS, con matices. InterMAHP asigna a «Hypertension (5).(1)» los códigos «I10 to I15» —que incluyen I11 (cardiopatía hipertensiva)— con RR de **incidencia** de hipertensión de «Roerecke et al. (in press)» [TEXTO, guía pp. 72–73], publicada luego como Roerecke 2018 (JAHA 7:e008202; solo resumen). Shield 2025 mantiene la causa «Hypertensive heart disease I10–15» pero cita como fuente de RR el GSRAH OMS 2018 (S6 ref. 40): herencia del ciclo OMS anterior [TEXTO]. Rehm 2016 declara que aplicar FAA basadas en RR a mortalidad «has become standard in comparative risk assessments» [TEXTO]. [INFERENCIA] Usar Liu F 2020 (10.1016/j.numecd.2020.03.018; asociación lineal, sin protección en mujeres; solo resumen) como sensibilidad es defendible; debe declararse el supuesto RR(incidencia)≈RR(mortalidad). **Discrepancia: el primer autor es Feiyan Liu (Liu F); «Liu Y» es el segundo autor.**

### Q4. ¿Es aceptable aplicar funciones RR por bandas a estratos de encuesta con agrupación distinta (mapeo por máxima superposición)?

Sí, con declaración. InterMAHP fija seis subgrupos «gender by age groups 15 to 34, 35 to 64, 65+» [TEXTO, guía p. 22]. OMS 2024 modela la exposición en 15–19, 20–24, 25–34, 35–49, 50–64 y ≥65, y luego «The alcohol population-attributable fractions were applied to mortality and morbidity age groupings, which were encompassed within the alcohol population-attributable fraction age groupings» [TEXTO, Methods]: el propio marco OMS mapea por contención entre agrupaciones no idénticas. Además, solo EIC y ACV isquémico tienen RR por banda (figs. S25–S36); las demás causas usan una función única [TEXTO, leído en PDF]. [INFERENCIA] Asignar el estrato 60–65 a la banda 35–64 reproduce esa lógica de máxima superposición; el sesgo es pequeño y solo afecta a EIC/ACVi. Declarar como limitación y cuantificar en sensibilidad.

### Q5. Publicación de origen de cada función RR de OMS 2024

Según la Tabla S6 de Shield 2025 (p. 60 del apéndice; numeración de referencias del apéndice, pp. 119–122) [TEXTO, leído en PDF]. Las ecuaciones están rasterizadas en las figuras S2–S61 (no extraíbles como texto); solo se verificó visualmente la de hígado.

| Causa (CIE-10) | Función (figura apéndice) | Publicación de origen (ref. S6) | DOI / URL | RR de exbebedor y su origen |
|---|---|---|---|---|
| Tuberculosis (A15–19, B90) | Figs. S2–S3 | Imtiaz 2017, Eur Respir J 50(1):1700216 (ref. 19) | 10.1183/13993003.00216-2017 | Mismo estudio (punto graficado); valor exacto no impreso → NO ENCONTRADO |
| VIH/SIDA (B20–24) | Figs. S4–S5 («sexually transmitted diseases») | Rehm 2017, Popul Health Metr 15:4 (ref. 21) | 10.1186/s12963-017-0121-9 | Mismo estudio; RRFD no impreso → NO ENCONTRADO |
| Infecciones respiratorias bajas (J09–22) | Figs. S6–S7 | Samokhvalov 2010, Epidemiol Infect 138(12):1789-95 (ref. 24) | 10.1017/S0950268810000774 | Mismo estudio; RRFD no impreso → NO ENCONTRADO |
| Cavidad oral/faringe (C00–14) | Figs. S8–S9 | Bagnardi 2015, Br J Cancer 112(3):580-93 (ref. 27) | 10.1038/bjc.2014.579 | Mismo estudio; RRFD no impreso → NO ENCONTRADO |
| Esófago (C15) | Figs. S10–S11 | Bagnardi 2015 (ref. 27) | 10.1038/bjc.2014.579 | Ídem |
| Colorrecto (C18–21) | Figs. S12–S13 | Vieira 2017, Ann Oncol 28(8):1788-802 (ref. 30; actualización WCRF-CUP) | 10.1093/annonc/mdx171 | Ídem |
| Hígado (C22) | Figs. S14–S15 | WCRF/AICR CUP 2018, informe experto (ref. 31) | wcrf.org/wp-content/uploads/2024/10/Alcoholic-Drinks.pdf | Punto graficado ≈2,2 (H) / ≈2,6 (M) [TEXTO gráfico]; CUP publica 2,58 (1,76–3,77) combinado; valores sexo-específicos exactos (2,23/2,68) → NO ENCONTRADO |
| Mama (C50) | Fig. S16 | Sun 2020, Alcohol Alcohol 55(3):246-53 (ref. 32) | 10.1093/alcalc/agaa012 | Punto graficado; en 2024 un meta-análisis (Sohi 2024, 10.1111/acer.15493) halló RR 1,11 (0,99–1,25) no significativa en exbebedoras (solo resumen) |
| **Cérvix (C53)** | **Sin figura** | S6 cita ref. 21 (artículo de VIH) — incongruencia editorial | — | Sin función documentada → NO ENCONTRADO |
| Laringe (C32) | Figs. S17–S18 | Bagnardi 2015 (ref. 27) | 10.1038/bjc.2014.579 | Mismo estudio; RRFD no impreso → NO ENCONTRADO |
| Diabetes mellitus (E10–14) | Figs. S19–S20 | **Llamosas-Falcón et al., «In Preperation» [sic] (ref. 33) — NO PUBLICADA**; causalidad: Knott 2015 (ref. 34) | Knott: 10.2337/dc15-0710 | Sin fuente publicada → NO ENCONTRADO |
| Epilepsia (G40–41) | Figs. S21–S22 | Samokhvalov 2010, Epilepsia 51(7):1177-84 (ref. 36) | 10.1111/j.1528-1167.2009.02426.x | InterMAHP: RRFD = 1,0 [TEXTO, guía tabla 2] |
| Cardiopatía hipertensiva (I10–15) | Figs. S23–S24 | OMS GSRAH 2018 (ref. 40; fuente secundaria). Origen primario según InterMAHP: Roerecke 2018 (antes «in press») | 10.1161/JAHA.117.008202 | InterMAHP: RRFD 1,03 (H) / 1,05 (M) [TEXTO, guía pp. 72–73] |
| EIC (I20–25), por bandas de edad | Figs. S25–S30 | Rehm 2016 (ref. 43) + Roerecke & Rehm 2012 (ref. 44); exbebedores: Roerecke & Rehm 2011 (ref. 45) | 10.1186/s12889-016-3026-9; 10.1111/j.1360-0443.2012.03780.x; 10.1093/aje/kwq364 | RRFD mortalidad EIC: 1,25 (1,15–1,36) H; 1,54 (1,17–2,03) M [TEXTO vía PMC4203905] |
| ACV isquémico, por bandas | Figs. S31–S36 | Rehm 2016 (ref. 43) + Patra 2010 (ref. 49) | 10.1186/s12889-016-3026-9; 10.1186/1471-2458-10-258 | Mismos estudios; RRFD no impreso → NO ENCONTRADO |
| ACV hemorrágico (I60–62.9…) | Figs. S37–S38 | Larsson 2016, BMC Med 14:178 (ref. 52) | 10.1186/s12916-016-0721-4 | Mismo estudio; RRFD no impreso → NO ENCONTRADO |
| Cirrosis hepática (K70, K74) | Figs. S39–S40 | Roerecke 2019, Am J Gastroenterol 114(10):1574-86 (ref. 53) | 10.14309/ajg.0000000000000340 | Mismo estudio (punto graficado); valor exacto no impreso → NO ENCONTRADO |
| Pancreatitis (K85–86) | Figs. S41–S42 | Samokhvalov 2015, EBioMedicine 2(12):1996-2002 (ref. 55) | 10.1016/j.ebiom.2015.11.023 | Mismo estudio; RRFD no impreso → NO ENCONTRADO |
| Lesiones (9 categorías: V01–Y09…) | Figs. S43–S45 | OMS GSRAH 2018 (ref. 60); causalidad: OMS 2009 estudios de urgencias (ref. 61) | who.int/substance_abuse/publications/global_alcohol_report/en/ | No aplica RRFD separado (Fórmulas S4–S5) |
| **Estómago (C16) y páncreas (C25)** | — | **NO INCLUIDOS en la Tabla S6** [TEXTO, leído en PDF: la numeración salta de 630 a 650 y de 660 a 700] | — | — |
| Nota regional | Figs. S46–S61 | Bielorrusia/Estonia/Letonia/Lituania/Moldavia/Rusia/Ucrania: Zaridze 2009 (ref. 62) + Shield & Rehm 2015 (ref. 63) | 10.1016/S0140-6736(09)60734-5 (no verificado en esta sesión); 10.1186/s12889-015-1818-y | No aplica a Chile |

---

## 3. Tabla de evidencia

| Referencia | DOI/PMID/URL | Diseño/población | Qué sostiene | Números (página/tabla; unidad; período; estimado/asumido) | Transportabilidad a Chile | Calidad/limitaciones |
|---|---|---|---|---|---|---|
| Shield K, et al. 2025, *Lancet Public Health* 10:e751-61 + Apéndice 1 (123 pp.) | 10.1016/S2468-2667(25)00174-4 | Estudio de modelado CRA global; 194 países; mortalidad WHO GHE 2000–2019 | D-a (neto con signo), D-b/D-c (lista S6), D-d (mapeo de edades), D-e (procedencia RR), P1–P6, P10 | 2,6 (2,3–3,1) millones de muertes atribuibles 2019 (4,7 % de todas); diabetes −5·2 mil (−23·2 a 16·3); ACVi −65·5 mil (−144·6 a 40·8); PAF cérvix 0,5 % (0,3–0,8) (tabla principal); «Both the detrimental and protective health effects… were modelled» (Methods); «encompassed within the… age groupings» (Methods); corrección 0,8; gamma; límite 150 g (Apéndice p. 57). **Estimado** con 1 000 simulaciones Monte Carlo | **Alta** (es el marco OMS 2024 que el estudio replica; incluye estimaciones para Chile en Apéndice 2) | Informe OMS encargado (financiado por OMS/CAMH): sirve para definiciones/métodos; la selección de RR fue por consenso mayoritario del TAG (sesgo de juicio declarado por los autores). Tabla S6 omite C16/C25 y asigna a cérvix una referencia de VIH (incongruencia). Leído a texto completo. |
| Sherk A, Stockwell T, Rehm J, Dorocicz J, Shield KD. 2017. *InterMAHP: A comprehensive guide… v1.0* | drugsandalcohol.ie/28421/ (PDF, 105 pp.) | Guía técnica de herramienta CRA (CISUR/OMS) | D-d (subgrupos fijos 15–34/35–64/65+), Q3 (RR hipertensión→I10–I15), P3, P7, P11 | «six population subgroups… (gender by age groups 15 to 34, 35 to 64, 65+)» (p. 22); «Hypertension (5).(1)… ICD10 codes: I10 to I15… Roerecke et al. (in press)» con RRFD 1,03/1,05 (pp. 72–73); Fórmula 3.5 (Levin con exbebedores); epilepsia RRFD = 1,0 (tabla 2). **Asumido/convención** | **Alta** (especifica la forma canónica InterMAHP que el estudio emula) | Documento técnico, no evidencia causal primaria; algunas fuentes «in press» al publicarse (2017). Leído a texto completo. |
| OMS. 2011. *Global status report on alcohol and health* | who.int/publications/i/item/global-status-report-on-alcohol-and-health-2011 | Informe oficial OMS (193 Estados) | Q1: tradición de reportar neto | «2.5 million deaths each year, with a net loss of life of 2.25 million, taking into account the estimated beneficial impact» (página oficial; global; ~2004-2010). **Estimado** | **Alta** (precedente institucional directo) | Informe gubernamental: define convención de reporte, no evidencia causal. |
| Rehm J, et al. 2011. *Addiction* 107(4) (NCD) | 10.1111/j.1360-0443.2011.03605.x | Revisión + CRA global (GBD 2004) | Q1: reporte separado «detrimental» vs «beneficial» | Tabla 1: muertes ENT «detrimental» 1 406 mil; «beneficial» −227 mil; neto 1 178 mil (miles; global; 2004). **Estimado** (extracto de texto completo vía PMC3174337) | **Alta** | Modelado secundario sobre meta-análisis; cifras de 2004, desactualizadas. |
| Sherk A, et al. 2019. *IJERPH* 16(24):4956 | 10.3390/ijerph16244956; PMID 31817638 | Modelado escenarios (InterMAHP + GBD) Australia y Canadá | D-a: sensibilidad del neto al supuesto cardioprotector | Muertes AA netas: Australia 2 933–4 570; Canadá 5 179–8 024 según meta-análisis de EIC usado (resumen; años de datos administrativos nacionales). **Estimado** | **Media-alta** (método idéntico al del estudio; países de altos ingresos) | (solo resumen) Nota: título correcto es «…for National Drinking Guidelines and Alcohol Harm Monitoring Systems». |
| GBD 2020 Alcohol Collaborators. 2022. *Lancet* 400:185-235 | 10.1016/S0140-6736(22)00847-9; PMID 35911552 | CRA global GBD 2020; 204 territorios | Q1: alternativa de modelado (curvas ponderadas por carga, TMREL/NDE) | TMREL 0–0,534 y NDE 0,669–1,72 tragos/día según iteración (Tabla 2); J-shaped ≥40 años; 1,34 mil millones sobre el NDE en 2020. **Estimado** | **Media** (marco alternativo; NO mezclar sus RR con las de OMS) | (solo resumen/extractos) Curvas «burden-weighted» dependen de tasas basales de cada región. |
| Bagnardi V, et al. 2015. *Br J Cancer* 112:580-93 | 10.1038/bjc.2014.579; PMID 25422909 | Meta-análisis dosis-respuesta; 572 estudios; 486 538 casos | Q2 (estómago/páncreas/cérvix), Q5 (oral/faringe/esófago/laringe) | RR bebedores intensos: estómago 1,21; páncreas 1,19; hígado 2,07; colon 1,44; laringe 2,65; mama 1,61 (resumen; niveles de consumo definidos en el artículo). **Estimado** | **Alta** (poblaciones internacionales; base de varias funciones OMS) | (solo resumen) Cérvix: no significativa (5 estudios). No distingue subtipos histológicos para todos los sitios. |
| WCRF/AICR. 2018. *Diet, Nutrition, Physical Activity and Cancer: a Global Perspective* (CUP) | wcrf.org/wp-content/uploads/2024/10/Alcoholic-Drinks.pdf | Informe experto + revisiones sistemáticas CUP | Q2 (grados de evidencia), Q5 (hígado), P8 | Hígado: RR 1,04 (1,02–1,06) por 10 g/día, juicio «Convincing»; exbebedores hígado 2,58 (1,76–3,77); estómago «Probable» ≥45 g/día (1,02 por 10 g, NS); páncreas «Limited-suggestive» (~60 g/día, 1,17); cérvix «too limited». **Estimado** | **Alta** (criterios de juicio graduados; base declarada de la RR de hígado en OMS 2024) | Grados «probable/limited» no equivalen a causalidad suficiente; umbrales por encima de ~45 g/día. Leído en extractos extensos. |
| Sun Q, et al. 2020. *Alcohol Alcohol* 55(3):246-53 | 10.1093/alcalc/agaa012 | Meta-análisis de cohortes prospectivas (22 cohortes; 45 350 casos) | Q5 (mama) | RR 1,10 (1,08–1,13) por 10 g/día de alcohol total; posmenopausia 1,11 (1,09–1,13) (citado en revisiones; solo resumen/ficha). **Estimado** | **Alta** | (solo resumen) Efecto principalmente ER+. |
| Vieira AR, et al. 2017. *Ann Oncol* 28(8):1788-802 | 10.1093/annonc/mdx171; PMID 28407090 | RS+MA de cohortes (actualización CUP colorrectal) | Q5 (colorrecto) | Actualización WCRF-CUP; alcohol entre los factores con evidencia convincente para colorrecto (ficha verificada). **Estimado** | **Alta** | (solo ficha) |
| Roerecke M, et al. 2019. *Am J Gastroenterol* 114(10):1574-86 | 10.14309/ajg.0000000000000340; PMID 31464740 | RS+MA (9 estudios; 2 629 272 participantes; 5 505 casos) | Q5 (cirrosis) | RR 12,44 (6,65–23,27) en mujeres con 5–6 tragos/día vs 3,80 (0,85–17,02) en hombres; 1 trago/día ya eleva riesgo en mujeres (citado en Rev Gastroenterol Mex 2025). **Estimado** | **Alta** | (solo resumen) Riesgo basal de cirrosis varía por país (VHC, obesidad). |
| Samokhvalov AV, et al. 2015. *EBioMedicine* 2(12):1996-2002 | 10.1016/j.ebiom.2015.11.023; PMID 26844279 | RS+MA pancreatitis aguda/crónica | Q5 (pancreatitis) | Dosis-respuesta monótona; umbral de riesgo elevado a consumos altos (ficha verificada). **Estimado** | **Alta** | (solo ficha) |
| Samokhvalov AV, et al. 2010. *Epidemiol Infect* 138(12):1789-95 | 10.1017/S0950268810000774; PMID 20380771 | RS+MA neumonía adquirida en comunidad | Q5 (IRB) | RR 1,12 (1,02–1,23), 1,33 (1,06–1,67), 1,76 (1,13–2,77) a 24/60/120 g/día; TUA: RR 8,22 (4,85–13,95) (resumen). **Estimado** | **Alta** | (solo resumen) Incidencia de neumonía como desenlace; mortalidad IRB es desenlace derivado. |
| Samokhvalov AV, et al. 2010. *Epilepsia* 51(7):1177-84 | 10.1111/j.1528-1167.2009.02426.x; PMID 20074233 | RS+MA epilepsia/convulsiones no provocadas | Q5 (epilepsia) | RR global 2,19 (1,83–2,63); 1,81/2,44/3,27 a 4/6/8 tragos/día (resumen). **Estimado** | **Alta** | (solo resumen) Posible efecto solo en consumo intenso; causalidad discutida por los autores. |
| Imtiaz S, et al. 2017. *Eur Respir J* 50(1):1700216 | 10.1183/13993003.00216-2017; PMID 28705945 | MA + estimación de carga TB | Q5 (TB) | MA de consumo y riesgo de TB (ficha verificada). **Estimado** | **Media-alta** (la TB en Chile tiene baja incidencia; FAA grande se aplica a pocos casos) | (solo ficha) |
| Rehm J, Probst C, Shield KD, Shuper PA. 2017. *Popul Health Metr* 15:4 | 10.1186/s12963-017-0121-9 | Revisión + estrategia de modelado (vía conductual) | Q5 (VIH); anomalía cérvix S6 | Modela efecto de alcohol sobre incidencia/progresión de VIH vía decisiones sexuales de riesgo (ficha verificada). **Estimado** | **Media** (depende de prevalencia VIH local; en Chile concentrada) | (solo ficha) Mecanismo indirecto (conductual), no biológico directo. |
| Roerecke M, et al. 2018. *J Am Heart Assoc* 7:e008202 | 10.1161/JAHA.117.008202 | RS+MA incidencia de hipertensión (sexo-específica) | Q3/Q5 (cardiopatía hipertensiva) | Dosis-respuesta en hombres; en mujeres riesgo a partir de consumos moderados-altos (ficha; sucesor del «in press» de InterMAHP). **Estimado** | **Media** (incidencia, no mortalidad) | (solo resumen) |
| Liu F, et al. 2020. *Nutr Metab Cardiovasc Dis* 30(8):1249-59 | 10.1016/j.numecd.2020.03.018; PMID 32446870 | RS+MA hipertensión | Q3 (alternativa más reciente) | Asociación aproximadamente lineal; sin evidencia de protección en mujeres (resumen). **Estimado** | **Media** | (solo resumen) **Discrepancia: primer autor Feiyan Liu; «Liu Y» del candidato es el segundo autor.** |
| Knott C, Bell S, Britton A. 2015. *Diabetes Care* 38(9):1804-12 | 10.2337/dc15-0710 | RS+MA 1,9 millones de personas, 38 estudios | Q5 (causalidad diabetes; curva en U) | Reducción de riesgo de DM2 en consumo moderado, con protección máxima ~20–30 g/día y reversión a consumos altos (ficha). **Estimado** | **Media-alta** | (solo ficha) Referencia de exbebedores mezclada en varios estudios primarios. |
| Larsson SC, et al. 2016. *BMC Med* 14:178 | 10.1186/s12916-016-0721-4 | RS+MA 27 estudios prospectivos | Q5 (ACV hemorrágico) | Asociación positiva lineal con ACV hemorrágico; con ACV isquémico asociación más débil (ficha). **Estimado** | **Alta** | (solo ficha) |
| Patra J, et al. 2010. *BMC Public Health* 10:258 | 10.1186/1471-2458-10-258 | RS+MA por tipo de ACV | Q5 (ACV isquémico) | Curvas por tipo de ACV, morbilidad y mortalidad (ficha). **Estimado** | **Alta** | (solo ficha) |
| Roerecke M, Rehm J. 2012. *Addiction* 107(7):1246-60 | 10.1111/j.1360-0443.2012.03780.x; PMID 22229788 | RS+MA EIC | Q5 (EIC); D-a (base de cardioprotección) | Curva en J para EIC; formas funcionales por sexo y desenlace (Tabla 3, extracto vía PMC3348338). **Estimado** | **Media-alta** | (extracto) Heterogeneidad I² 46–59 %; controversia por «sick quitters». |
| Roerecke M, Rehm J. 2011. *Am J Epidemiol* 173(3):245-58 | 10.1093/aje/kwq364 | MA exbebedores, EIC | P9 (RRFD EIC) | RRFD mortalidad EIC 1,25 (1,15–1,36) H; 1,54 (1,17–2,03) M vs abstemios de por vida [TEXTO vía PMC4203905]. **Estimado** | **Media-alta** | (extracto de cita secundaria) |
| Rehm J, Shield KD, Roerecke M, Gmel G. 2016. *BMC Public Health* 16:363 | 10.1186/s12889-016-3026-9; PMID 27121289 | CRA mortalidad CV global 2012 | D-d, Q3, Q5 (EIC/ACVi), D-a | «AAFs… by sex, age (age groups: 15 to 34…, 35 to 64…, and 65 plus…) and country»; «This modelling strategy has become standard… both for the GBD… and the WHO GSRAH»; 780 381 muertes CV atribuibles en 2012 (26,6 % de todas las atribuibles). **Estimado** | **Alta** | Leído en extractos extensos. |
| OMS. 2024. *Global status report on alcohol and health and treatment of substance use disorders* | who.int/publications (junio 2024) | Informe oficial OMS | Marco general; base del estudio nacional | Reporte mundial basado en Shield 2025 (cita n.º 2 del artículo). **Estimado/asumido** | **Alta** | Documento institucional: métodos/definiciones; no evidencia causal por sí solo. |
| Rumgay H, et al. 2021. *Lancet Oncol* 22(8):1071-80 | 10.1016/S1470-2045(21)00279-5; PMID 34270924 | Estudio poblacional (GLOBOCAN 2020) | Q2/D-b (precedente de incluir estómago) | 741 300 casos de cáncer atribuibles al alcohol en 2020 (4,1 %); estómago 76 700 casos incluidos [TEXTO, resumen]. **Estimado** | **Alta** (método PAF comparable) | (solo resumen) Incluir estómago se justifica con WCRF «probable»; no usó el marco OMS-TAG. |
| Sohi I, et al. 2024. *Alcohol Clin Exp Res* 48:2222-41 | 10.1111/acer.15493 | RS+MA cohortes prospectivas, mama | Contexto RRFD mama | Exbebedoras vs abstemias de por vida: RR 1,11 (0,99–1,25), no significativa (Tabla 2, solo resumen). **Estimado** | **Alta** | (solo resumen) Apoya tratar RRFD mama ≈ 1 en sensibilidad. |
| Gawryszewski VP, Monteiro MG. 2014. *Addiction* 109(4):570-77 | 10.1111/add.12418; PMID 24417789 | Registros de mortalidad OPS, 16 países de las Américas (incl. Chile), 2007–09 | Sección 4 (contexto regional) | 79 456 muertes/año con alcohol como causa necesaria (84 % hombres); tasas ajustadas: El Salvador 27,4; Guatemala 22,3; Nicaragua 21,3; México 17,8 vs Colombia 1,8; Argentina 4,0; Canadá 5,7 por 100 000 (resumen + PDF completo). **Estimado** | **Alta** (incluye a Chile en la Tabla 2; fila de Chile no extraída en esta sesión) | Solo causas 100 % atribuibles («punta del iceberg»); no FAA parciales. Leído a texto completo. |
| Castillo-Carniglia A, et al. 2025. *J Stud Alcohol Drugs* 86(5):805-14 | 10.15288/jsad.24-00309; PMID 40749640 | Estudio nacional Chile (daños a terceros) | Sección 4 (evidencia chilena) | Magnitud y prevenibilidad de daños del alcohol a terceros en Chile (ficha). **Estimado** | **Alta** (estudio chileno) | (solo ficha) Daños a terceros, no mortalidad atribuible por FAA. |
| Córdova-Delgado M, et al. 2025. *Nutrients* 17(19):3104 | 10.3390/nu17193104 | Estudio chileno (cáncer colorrectal y factores de riesgo) | Sección 4 (cifra chilena de contexto) | «alcohol consumption was the eighth leading cause of death, with 6249 deaths in 2019 attributable to alcohol» en Chile, citando GBD/IHME [TEXTO, citado en el artículo]. **Estimado (fuente secundaria)** | **Alta** | (solo extracto) Cifra de IHME, no calculada con metodología OMS/InterMAHP; no verificada directamente en IHME. |

---

## 4. Evidencia chilena y latinoamericana

**(a) Chile.** Se localizaron tres piezas directamente pertinentes. (i) Castillo-Carniglia et al. 2025 (*J Stud Alcohol Drugs* 86(5):805-14, DOI 10.15288/jsad.24-00309) cuantifica en Chile los daños del alcohol a terceros y su prevenibilidad por políticas (solo ficha): evidencia de carga nacional, aunque no estima FAA por causa. (ii) Córdova-Delgado et al. 2025 (*Nutrients* 17(19):3104) afirman que en Chile «alcohol consumption was the eighth leading cause of death, with 6249 deaths in 2019 attributable to alcohol», citando al GBD/IHME [TEXTO, cita secundaria; NO VERIFICADO directamente en IHME; denominador: todas las muertes Chile 2019]. (iii) Chile está incluido en la muestra de 16 países de Gawryszewski & Monteiro 2014 y en las estimaciones por país del Apéndice 2 de Shield 2025 (fila chilena no extraída en esta sesión → NO ENCONTRADO). **No se encontró ningún estudio chileno que valide localmente las funciones RR internacionales ni que compute FAA parciales con RRs propias** (búsqueda: «mortalidad atribuible al alcohol Chile DEIS fracción atribuible»; sin resultados de estimaciones CRA nacionales publicadas). [INFERENCIA] La transportabilidad de las RR OMS/InterMAHP a Chile es, por tanto, una suposición necesaria y debe declararse: las funciones proceden de cohortes predominantemente de altos ingresos; no se promediaron fuentes discordantes.

**(b) América Latina.** Gawryszewski & Monteiro 2014 (OPS; 16 países, 2007–09) es el estudio regional de referencia para causas 100 % atribuibles: promedio 79 456 muertes/año en las Américas, 84–86 % hombres, con enfermedades hepáticas (63 %) y trastornos neuropsiquiátricos (32 %) dominando; tasas ajustadas más altas en Centroamérica (El Salvador 27,4 por 100 000) y más bajas en Colombia (1,8) y Argentina (4,0) [TEXTO, resumen y PDF completo]. Los autores subrayan que estas cifras son «the tip of the iceberg» al excluir causas parcialmente atribuibles [TEXTO]. La actualización continental (Chrystoja et al. 2021, *Addiction*; 2013–15) estimó 85 032 muertes/año 100 % atribuibles en 30 países (solo ficha). [INFERENCIA] La evidencia regional confirma el patrón (hombres, hepático, prematuro) que el estudio FONDECYT espera reproducir con FAA parciales, pero no aporta funciones RR latinoamericanas.

## 5. Recomendación por decisión

| Decisión | Recomendación | Fuerza | Qué la cambiaría | Limitación a declarar |
|---|---|---|---|---|
| D-a | Estimación principal neta con signo (convención OMS 2024/Shield 2025) **más** tabla complementaria «solo daño» truncando RR(x)<1 a 1 | Alta | Que el comité/editor exigiera un único indicador: entonces priorizar el neto y reportar el rango de sensibilidad cardioprotectora (Sherk 2019) | Los valores negativos son dependientes del modelo (RR de EIC/ACVi/DM2 con referente de abstemios de por vida; posible sesgo de «sick quitters») |
| D-b | C16/C25 fuera de la estimación principal; sensibilidad con Bagnardi 2015 (1,21/1,19 en bebedores intensos) y rotulada «fuera del alcance OMS-TAG 2024» | Alta | Publicación de la función de Llamosas-Falcón u otra que el TAG adopte para estas causas; o decisión explícita de replicar Rumgay 2021 (que sí incluye estómago) | La sensibilidad mezcla marcos causales distintos (WCRF «probable» vs TAG); declarar la heterogeneidad de criterios |
| D-c | Excluir C53 con la formulación «sin función RR utilizable/validada en el marco OMS 2024», citando la incongruencia de S6 | Alta | Corrección de S6 por los autores con fuente y función de RR para cérvix | No afirmar «no causal»: Bagnardi 2015 (5 estudios, NS) y WCRF («demasiado limitada») dejan la cuestión abierta |
| D-d | Mantener 60–65 → banda 35–64 (máxima superposición), análogo al mapeo por contención de OMS | Media-alta | Disponibilidad de RR quinquenales (GBD 2021 las publica por edades finas); entonces rehacer el mapeo | Posible subestimación de la FAA en 60–65 para EIC/ACVi (la RR a edad real puede diferir de la banda); cuantificar en sensibilidad |
| D-e | Tabla de procedencia (sección Q5) en el manuscrito/anexo, sin sustituir funciones | Alta | Publicación de las funciones exactas por la OMS (hoy rasterizadas en figuras) | Dos RR (diabetes, cardiopatía hipertensiva) tienen procedencia primaria débil: una «en preparación», otra circular (OMS 2018) |

---

## 6. Methods paragraphs (English)

**D-a, option 1 — Net signed AAFs as the primary estimate (recommended).**
Alcohol-attributable fractions (AAFs) were estimated using a Levin-based population-attributable-fraction approach with lifetime abstention as the theoretical minimum risk exposure level, integrating cause-specific relative risk (RR) functions over a gamma distribution of daily consumption (0·1–150 g/day) and adding the contribution of former drinkers through categorical former-drinker RRs (Sherk 2017; Shield 2025). Following the WHO comparative risk assessment convention, both detrimental and protective effects were modelled, so that AAFs and attributable deaths are reported as signed (net) quantities; negative values represent deaths avoided under the observed exposure relative to universal lifetime abstention (Shield 2025). This net reporting follows the precedent of WHO global estimates, which reported 2·5 million deaths with a net loss of 2·25 million lives after accounting for beneficial effects (WHO 2011), and of earlier comparative risk assessments that tabulated detrimental and beneficial components separately before netting (Rehm 2011).

**D-a, option 2 — Complementary “harm-only” (gross) estimates.**
Because net estimates are sensitive to assumptions about cardioprotection for ischaemic heart disease, ischaemic stroke, and type 2 diabetes, we additionally report harm-only estimates in which RR(x) is truncated at 1 wherever the function falls below unity, excluding former-drinker deficits (Sherk 2019; Shield 2025). Scenario analyses using InterMAHP showed that cardioprotective assumptions change net alcohol-attributable deaths substantially (Australia, 2 933–4 570; Canada, 5 179–8 024) while leaving cause-level detrimental fractions largely unaffected (Sherk 2019). Presenting both quantities makes the magnitude of the protective-effect assumption explicit without departing from the signed WHO convention as the headline figure (Shield 2025; Rehm 2016).

**D-b, option 1 — Stomach (C16) and pancreas (C25) excluded from the main estimate; sensitivity analysis (recommended).**
The main cause list follows the WHO Technical Advisory Group causality assessment as implemented in the 2024 WHO estimates, whose relative-risk source table does not include stomach (C16) or pancreatic (C25) cancer (Shield 2025, appendix Table S6). Both sites were therefore excluded from the primary estimate. A sensitivity analysis was conducted applying the heavy-drinking associations reported by Bagnardi 2015 (stomach RR 1·21; pancreas 1·19) and labelled as departing from the WHO-TAG scope, because international agency gradings classify the evidence for stomach cancer as probable only at intakes at or above roughly 45 g/day and for pancreatic cancer as limited-suggestive (WCRF/AICR 2018), and neither site is classified as alcohol-caused by IARC (Shield 2025).

**D-b, option 2 — Inclusion in the main estimate with explicit deviation label.**
Alternatively, stomach cancer may be included in the main estimate following the precedent of the GLOBOCAN-based study of alcohol-attributable cancer in 2020, which attributed 76 700 stomach-cancer cases to alcohol worldwide on the basis of the WCRF evidence classification (Rumgay 2021; WCRF/AICR 2018). Under this option the manuscript must state explicitly that the cause list deviates from the WHO 2024 relative-risk library (Shield 2025), that the pancreatic-cancer inclusion rests on limited-suggestive evidence (WCRF/AICR 2018), and that the relative risks applied are taken from a comprehensive dose–response meta-analysis rather than from the WHO-selected functions (Bagnardi 2015), so that estimates are not directly comparable with WHO-attributed totals (Shield 2025).

---

## 7. BibTeX

```bibtex
@article{Shield2025,
  author  = {Shield, Kevin and Weber, Andrija and Fecioru, Andrei and Sohi, Ivneet and Bader, Marissa and Kok Tan, Ee and Gruenewald, Ida-Rebekka and Kilian, Carolin and Manthey, Jakob and Rehm, Jakob and Rehm, J{\"u}rgen and others},
  title   = {National, regional, and global statistics on alcohol consumption and associated burden of disease 2000--20: a modelling study and comparative risk assessment},
  journal = {The Lancet Public Health},
  year    = {2025},
  volume  = {10},
  pages   = {e751--e761},
  doi     = {10.1016/S2468-2667(25)00174-4}
}
@misc{Sherk2017,
  author = {Sherk, Adam and Stockwell, Tim and Rehm, J{\"u}rgen and Dorocicz, Justina and Shield, Kevin D.},
  title  = {InterMAHP: A comprehensive guide to the estimation of alcohol-attributable morbidity and mortality, version 1.0},
  year   = {2017},
  url    = {https://www.drugsandalcohol.ie/28421/}
}
@misc{WHO2011,
  author = {{World Health Organization}},
  title  = {Global status report on alcohol and health 2011},
  year   = {2011},
  url    = {https://www.who.int/publications/i/item/global-status-report-on-alcohol-and-health-2011}
}
@misc{WHO2024,
  author = {{World Health Organization}},
  title  = {Global status report on alcohol and health and treatment of substance use disorders},
  year   = {2024},
  url    = {https://www.who.int/publications/i/item/9789240096745}
}
@article{Rehm2011NCD,
  author  = {Rehm, J{\"u}rgen and Taylor, Benjamin and Room, Robin and others},
  title   = {Alcohol consumption and non-communicable diseases: epidemiology and policy implications},
  journal = {Addiction},
  year    = {2011},
  volume  = {106},
  number  = {10},
  pages   = {1718--1724},
  doi     = {10.1111/j.1360-0443.2011.03605.x}
}
@article{Sherk2019,
  author  = {Sherk, Adam and Gilmore, William and Churchill, Samuel and Lensvelt, Eveline and Stockwell, Tim and Chikritzhs, Tanya},
  title   = {Implications of Cardioprotective Assumptions for National Drinking Guidelines and Alcohol Harm Monitoring Systems},
  journal = {International Journal of Environmental Research and Public Health},
  year    = {2019},
  volume  = {16},
  number  = {24},
  pages   = {4956},
  doi     = {10.3390/ijerph16244956}
}
@article{GBD2020Alcohol,
  author  = {{GBD 2020 Alcohol Collaborators}},
  title   = {Population-level risks of alcohol consumption by amount, geography, age, sex, and year: a systematic analysis for the Global Burden of Disease Study 2020},
  journal = {The Lancet},
  year    = {2022},
  volume  = {400},
  pages   = {185--235},
  doi     = {10.1016/S0140-6736(22)00847-9}
}
@article{Bagnardi2015,
  author  = {Bagnardi, Vincenzo and Rota, Matteo and Botteri, Edoardo and others},
  title   = {Alcohol consumption and site-specific cancer risk: a comprehensive dose-response meta-analysis},
  journal = {British Journal of Cancer},
  year    = {2015},
  volume  = {112},
  number  = {3},
  pages   = {580--593},
  doi     = {10.1038/bjc.2014.579}
}
@misc{WCRF2018,
  author = {{World Cancer Research Fund / American Institute for Cancer Research}},
  title  = {Diet, Nutrition, Physical Activity and Cancer: a Global Perspective. Continuous Update Project Expert Report 2018. Alcoholic drinks and the risk of cancer},
  year   = {2018},
  url    = {https://www.wcrf.org/wp-content/uploads/2024/10/Alcoholic-Drinks.pdf}
}
@article{Sun2020,
  author  = {Sun, Qi and Xie, Wenyuan and Wang, Ying and others},
  title   = {Alcohol Consumption by Beverage Type and Risk of Breast Cancer: A Dose-Response Meta-Analysis of Prospective Cohort Studies},
  journal = {Alcohol and Alcoholism},
  year    = {2020},
  volume  = {55},
  number  = {3},
  pages   = {246--253},
  doi     = {10.1093/alcalc/agaa012}
}
@article{Vieira2017,
  author  = {Vieira, Ana Rita and Abar, Leila and Chan, Doris S. M. and others},
  title   = {Foods and beverages and colorectal cancer risk: a systematic review and meta-analysis of cohort studies, an update of the evidence of the WCRF-AICR Continuous Update Project},
  journal = {Annals of Oncology},
  year    = {2017},
  volume  = {28},
  number  = {8},
  pages   = {1788--1802},
  doi     = {10.1093/annonc/mdx171}
}
@article{Roerecke2019,
  author  = {Roerecke, Michael and Vafaei, Afshin and Hasan, Omer S. M. and others},
  title   = {Alcohol Consumption and Risk of Liver Cirrhosis: A Systematic Review and Meta-Analysis},
  journal = {American Journal of Gastroenterology},
  year    = {2019},
  volume  = {114},
  number  = {10},
  pages   = {1574--1586},
  doi     = {10.14309/ajg.0000000000000340}
}
@article{Samokhvalov2015,
  author  = {Samokhvalov, Andriy V. and Rehm, J{\"u}rgen and Roerecke, Michael},
  title   = {Alcohol Consumption as a Risk Factor for Acute and Chronic Pancreatitis: A Systematic Review and a Series of Meta-analyses},
  journal = {EBioMedicine},
  year    = {2015},
  volume  = {2},
  number  = {12},
  pages   = {1996--2002},
  doi     = {10.1016/j.ebiom.2015.11.023}
}
@article{Samokhvalov2010pneumonia,
  author  = {Samokhvalov, Andriy V. and Irving, Hyacinth M. and Rehm, J{\"u}rgen},
  title   = {Alcohol consumption as a risk factor for pneumonia: a systematic review and meta-analysis},
  journal = {Epidemiology and Infection},
  year    = {2010},
  volume  = {138},
  number  = {12},
  pages   = {1789--1795},
  doi     = {10.1017/S0950268810000774}
}
@article{Samokhvalov2010epilepsy,
  author  = {Samokhvalov, Andriy V. and Irving, Hyacinth and Mohapatra, Satya and Rehm, J{\"u}rgen},
  title   = {Alcohol consumption, unprovoked seizures, and epilepsy: A systematic review and meta-analysis},
  journal = {Epilepsia},
  year    = {2010},
  volume  = {51},
  number  = {7},
  pages   = {1177--1184},
  doi     = {10.1111/j.1528-1167.2009.02426.x}
}
@article{Imtiaz2017,
  author  = {Imtiaz, Sameer and Shield, Kevin D. and Roerecke, Michael and Samokhvalov, Andriy V. and L{\"o}nnroth, Knut and Rehm, J{\"u}rgen},
  title   = {Alcohol consumption as a risk factor for tuberculosis: meta-analyses and burden of disease},
  journal = {European Respiratory Journal},
  year    = {2017},
  volume  = {50},
  number  = {1},
  pages   = {1700216},
  doi     = {10.1183/13993003.00216-2017}
}
@article{Rehm2017HIV,
  author  = {Rehm, J{\"u}rgen and Probst, Charlotte and Shield, Kevin D. and Shuper, Paul A.},
  title   = {Does alcohol use have a causal effect on HIV incidence and disease progression? A review of the literature and a modeling strategy for quantifying the effect},
  journal = {Population Health Metrics},
  year    = {2017},
  volume  = {15},
  pages   = {4},
  doi     = {10.1186/s12963-017-0121-9}
}
@article{Roerecke2018,
  author  = {Roerecke, Michael and Tobe, Sheldon W. and Kaczorowski, Janusz and others},
  title   = {Sex-Specific Associations Between Alcohol Consumption and Incidence of Hypertension: A Systematic Review and Meta-Analysis of Cohort Studies},
  journal = {Journal of the American Heart Association},
  year    = {2018},
  volume  = {7},
  number  = {13},
  pages   = {e008202},
  doi     = {10.1161/JAHA.117.008202}
}
@article{Liu2020,
  author  = {Liu, Feiyan and Liu, Yu and Sun, Xiaoying and Yin, Ziwei and Li, Hong},
  title   = {Race- and sex-specific association between alcohol consumption and hypertension in 22 cohort studies: A systematic review and meta-analysis},
  journal = {Nutrition, Metabolism and Cardiovascular Diseases},
  year    = {2020},
  volume  = {30},
  number  = {8},
  pages   = {1249--1259},
  doi     = {10.1016/j.numecd.2020.03.018}
}
@article{Knott2015,
  author  = {Knott, Craig and Bell, Steven and Britton, Annie},
  title   = {Alcohol Consumption and the Risk of Type 2 Diabetes: A Systematic Review and Dose-response Meta-analysis of More Than 1.9 Million Individuals From 38 Observational Studies},
  journal = {Diabetes Care},
  year    = {2015},
  volume  = {38},
  number  = {9},
  pages   = {1804--1812},
  doi     = {10.2337/dc15-0710}
}
@article{Larsson2016,
  author  = {Larsson, Susanna C. and Wallin, Alice and Wolk, Alicja and Markus, Hugh S.},
  title   = {Differing association of alcohol consumption with different stroke types: a systematic review and meta-analysis},
  journal = {BMC Medicine},
  year    = {2016},
  volume  = {14},
  pages   = {178},
  doi     = {10.1186/s12916-016-0721-4}
}
@article{Patra2010,
  author  = {Patra, Jayadeep and Taylor, Benjamin and Irving, Hyacinth and others},
  title   = {Alcohol consumption and the risk of morbidity and mortality for different stroke types - a systematic review and meta-analysis},
  journal = {BMC Public Health},
  year    = {2010},
  volume  = {10},
  pages   = {258},
  doi     = {10.1186/1471-2458-10-258}
}
@article{Roerecke2012,
  author  = {Roerecke, Michael and Rehm, J{\"u}rgen},
  title   = {The cardioprotective association of average alcohol consumption and ischaemic heart disease: a systematic review and meta-analysis},
  journal = {Addiction},
  year    = {2012},
  volume  = {107},
  number  = {7},
  pages   = {1246--1260},
  doi     = {10.1111/j.1360-0443.2012.03780.x}
}
@article{Roerecke2011,
  author  = {Roerecke, Michael and Rehm, J{\"u}rgen},
  title   = {Ischemic heart disease mortality and morbidity in former drinkers: a meta-analysis},
  journal = {American Journal of Epidemiology},
  year    = {2011},
  volume  = {173},
  number  = {3},
  pages   = {245--258},
  doi     = {10.1093/aje/kwq364}
}
@article{Rehm2016,
  author  = {Rehm, J{\"u}rgen and Shield, Kevin D. and Roerecke, Michael and Gmel, Gerrit},
  title   = {Modelling the impact of alcohol consumption on cardiovascular disease mortality for comparative risk assessments: an overview},
  journal = {BMC Public Health},
  year    = {2016},
  volume  = {16},
  pages   = {363},
  doi     = {10.1186/s12889-016-3026-9}
}
@article{Rumgay2021,
  author  = {Rumgay, Harriet and Shield, Kevin and Charvat, Hadrien and others},
  title   = {Global burden of cancer in 2020 attributable to alcohol consumption: a population-based study},
  journal = {The Lancet Oncology},
  year    = {2021},
  volume  = {22},
  number  = {8},
  pages   = {1071--1080},
  doi     = {10.1016/S1470-2045(21)00279-5}
}
@article{Sohi2024,
  author  = {Sohi, Ivneet and Rehm, J{\"u}rgen and Saab, Michael and others},
  title   = {Alcoholic beverage consumption and female breast cancer risk: A systematic review and meta-analysis of prospective cohort studies},
  journal = {Alcohol: Clinical and Experimental Research},
  year    = {2024},
  volume  = {48},
  pages   = {2222--2241},
  doi     = {10.1111/acer.15493}
}
@article{Gawryszewski2014,
  author  = {Gawryszewski, Vilma Pinheiro and Monteiro, Maristela G.},
  title   = {Mortality from diseases, conditions and injuries where alcohol is a necessary cause in the Americas, 2007--09},
  journal = {Addiction},
  year    = {2014},
  volume  = {109},
  number  = {4},
  pages   = {570--577},
  doi     = {10.1111/add.12418}
}
@article{CastilloCarniglia2025,
  author  = {Castillo-Carniglia, Alvaro and others},
  title   = {Alcohol's policy-relevant harms to others in Chile: magnitude, conditions, and policy preventability},
  journal = {Journal of Studies on Alcohol and Drugs},
  year    = {2025},
  volume  = {86},
  number  = {5},
  pages   = {805--814},
  doi     = {10.15288/jsad.24-00309}
}
@article{CordovaDelgado2025,
  author  = {C{\'o}rdova-Delgado, Mat{\'i}as and others},
  title   = {Influence of Alcohol and Cigarette Consumption as Risk Factors of Cancer in Chile},
  journal = {Nutrients},
  year    = {2025},
  volume  = {17},
  number  = {19},
  pages   = {3104},
  doi     = {10.3390/nu17193104}
}
```

---

## 8. NO ENCONTRADO / NO VERIFICADO y discrepancias

1. **Función RR de diabetes (S6 ref. 33): «Llamosas-Falcón L, Probst C… Alcohol consumption and diabetes mellitus: a systematic review and meta-analysis. In Preperation [sic]».** NO ENCONTRADO: no existe versión publicada indexada (búsquedas por autor y título, oct-2026). La RR de diabetes de OMS 2024 carece, por ahora, de fuente primaria publicada y trazable.
2. **Valores exactos de RR de exbebedor de cáncer de hígado 2,23 (H) / 2,68 (M).** NO ENCONTRADO en documentos públicos: las figuras S14–S15 del Apéndice 1 grafican puntos de exbebedores compatibles (≈2,2 y ≈2,6, leído en la imagen renderizada); S6 atribuye la causa al informe WCRF/AICR CUP 2018, cuyo SLR publica para exbebedores un RR combinado de 2,58 (1,76–3,77). La derivación sexo-específica exacta no está impresa.
3. **«RRFD mama 1,44 (versión 2016)» (candidato del brief).** NO VERIFICADO: la guía InterMAHP 2017 documenta RRFD mama 1,03 (Schütze 2011); un meta-análisis de 2024 (Sohi et al.) estima 1,11 (0,99–1,25, NS). No se localizó ninguna fuente con 1,44 para exbebedoras de mama.
4. **Fila de cérvix (C53) en Tabla S6.** Incongruencia NO RESUELTA: la fila cita como fuente de RR la ref. 21 (artículo de modelado de **VIH**, Rehm 2017) y como causalidad refs. 22–23 (idénticas a la fila de VIH/SIDA); no existe figura de función RR para cérvix (S2–S61), aunque la tabla principal reporta un PAF de cérvix de 0,5 %. Todo sugiere un error editorial del apéndice; se reporta sin corregir.
5. **Discrepancia de candidato «Liu Y, et al. 2020».** La referencia real es **Liu F (Feiyan Liu) et al. 2020**, *Nutr Metab Cardiovasc Dis* 30(8):1249-59, DOI 10.1016/j.numecd.2020.03.018, PMID 32446870; Yu Liu figura como segundo autor. Reportado conforme a la regla 4; no se reemplazó silenciosamente.
6. **GBD 2020 (candidato «Lancet 2022;399:2371-406»).** Paginación correcta verificada: *Lancet* **2022;400:185-235** (errata en *Lancet* 2022;400:358). El DOI 10.1016/S0140-6736(22)00847-9 es correcto.
7. **Sherk 2019 (candidato «Implications of Cardioprotective Assumptions for National Alcohol Harms Estimates»).** Título real: «Implications of Cardioprotective Assumptions for National **Drinking Guidelines and Alcohol Harm Monitoring Systems**», *IJERPH* 2019;16(24):4956, DOI 10.3390/ijerph16244956, PMID 31817638.
8. **Cifra chilena de 6 249 muertes atribuibles en 2019** (citada por Córdova-Delgado et al. 2025 desde GBD/IHME). NO VERIFICADO directamente en la base IHME en esta sesión; úsese como contexto, no como estimación propia.
9. **Ecuaciones impresas de las funciones RR del Apéndice 1.** NO EXTRAÍBLES: están rasterizadas en las figuras S2–S61 (el texto de las ecuaciones no forma parte de la capa de texto del PDF). Solo se verificó visualmente la coherencia de la curva de hígado (≈1,8 a 150 g/día, compatible con 1,04 por 10 g/día de WCRF) y los puntos de exbebedores de hígado.
10. **DOI de Zaridze 2009** (10.1016/S0140-6736(09)60734-5): citado desde la lista de referencias del apéndice; NO VERIFICADO de forma independiente en esta sesión (solo relevante para la región de Rusia, no para Chile).
11. **Estimaciones por país para Chile del Apéndice 2 de Shield 2025 y fila de Chile en Gawryszewski 2014 (Tabla 2).** NO EXTRAÍDAS en esta sesión; ambas fuentes están identificadas y son recuperables.

*Contenido con fines exclusivamente informativos para el equipo investigador; no constituye asesoría metodológica formal ni sustituye la revisión por pares.*
