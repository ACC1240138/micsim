KIMI-P8 | fecha de búsqueda: 2026-10-08 | 2 artículos leídos a texto completo + 2 informes técnicos leídos en secciones íntegras verificadas / 14 referencias leídas solo en resumen (marcadas "(solo resumen)")

# Justificación y defensa de la fuente de funciones de riesgo relativo (RR) para cardiopatía isquémica (EIC) y accidente cerebrovascular (ACV) isquémico en el estudio de mortalidad atribuible al alcohol en Chile (FONDECYT 1240138)

**Convenciones de etiquetado usadas en todo el documento:** [TEXTO] = afirmación sustentada en un pasaje leído directamente (con cita textual <30 palabras cuando fue posible); [INFERENCIA] = conclusión lógica del revisor a partir de fuentes leídas, no una afirmación literal de la fuente; "(solo resumen)" = referencia leída únicamente a nivel de resumen/abstract; NO ENCONTRADO = información buscada y no hallada, con descripción de la búsqueda en la sección 8. Los números reportados indican población, unidad, denominador y período cuando la fuente los declara, y se marca si son ESTIMADOS o ASUMIDOS.

---

## 1. Tabla de veredicto (Decisión D-a)

| Decisión [ID] | Opción | Apoyo | Referencias clave | Por qué |
|---|---|---|---|---|
| D-a | **A) OMS 2018 (GSRAHTSUD 2024) como fuente principal + "Tabla 5" PUC/SENDA como análisis de sensibilidad** (opción actual del equipo) | **Fuerte** | Shield et al. 2025 [texto completo]; Rehm et al. 2016 [texto completo]; Rehm, Sherk, Shield & Gmel 2017 (CAMH) [secciones]; Rehm et al. 2017 (solo resumen); PUC/SENDA 2018 (NO ENCONTRADO a texto completo) | OMS 2024 es la norma internacional vigente, con funciones deliberadas por el Grupo Asesor Técnico de la OMS por consenso mayoritario y trazabilidad completa (coeficientes, publicaciones de origen, matrices de incertidumbre vía Monte Carlo). La "Tabla 5" no pudo verificarse en su fuente primaria (informe inaccesible), no publica matriz de varianza-covarianza y su columna "Fact" es de significado desconocido: no cumple el estándar de trazabilidad para fuente principal, pero sí es útil como sensibilidad porque deriva de la misma familia meta-analítica (Roerecke & Rehm 2012) y coincide con OMS <40 g/día. |
| D-a | **B) "Tabla 5" PUC/SENDA como fuente principal** | **Contrario** | PUC/SENDA 2018 (NO ENCONTRADO); Roerecke & Rehm 2012 (solo resumen) | Una fuente cuya tabla no puede ser verificada en el documento original (informe 404, sin espejo accesible), sin covarianza b1–b2 publicada y con una columna de uso no documentado no puede defenderse como primaria ante revisión por pares. La ausencia de covarianza ya degenera los intervalos de la EIC femenina en los propios cálculos del equipo. |
| D-a | **C) Añadir sensibilidad "sin cardioprotección" (RR≥1 para EIC) solo si el IP lo pide** | **Moderado–fuerte a favor de implementarla proactivamente** (no esperar al IP) | Zhao et al. 2017 (solo resumen); Zhao et al. 2023 (solo resumen); Biddinger et al. 2022 (solo resumen); Carr et al. 2024 (solo resumen); Bryazka et al. 2022/GBD 2020 (solo resumen); Sherk et al. 2017 InterMAHP [secciones] | La evidencia 2017–2024 cuestiona la magnitud (no necesariamente la existencia) de la cardioprotección: estudios de mayor calidad y aleatorización mendeliana atenúan o anulan el efecto protector. El propio InterMAHP incluye una opción "sin cardioprotección" para EIC masculina (función de Zhao 2017), es decir, la comunidad de modelamiento ya la trata como escenario legítimo. Implementarla es barato (misma integración gamma, RR truncada en 1) y blinda la defensa ante revisores. |

---

## 1b. Tabla de parámetros y decisiones de modelamiento

| ID | Parámetro / decisión | Valor | Fuente (DOI + página/tabla) | Estimado / Asumido | Transportabilidad a Chile |
|---|---|---|---|---|---|
| P1 | Función RR EIC hombres, OMS 2018/2024 (volumen, todas las edades) | ln RR(x) = −0,5043554·√y + 1,606235·y³ para x≤60 g/día; **ln RR = 0 (RR=1) para 60<x<100**; ln RR = 0,012·(x−100) para x≥100; con y=(x+0,01)/100 | Rehm, Sherk, Shield & Gmel 2017, informe CAMH, sección "Ischemic heart disease" (ISBN 978-1-77114-399-8; URL en §7). Base: "Source: Rehm et al., 2016 based on Roerecke & Rehm, 2012" [TEXTO] | ESTIMADO (coeficientes de meta-análisis); la meseta 60–100 es una **decisión de modelamiento** (ASUMIDA) sobre la curva estimada | Alta para Chile: curva meta-analítica global (44 estudios, 38.627 eventos EIC, 957.684 personas, 1980–2010; Roerecke & Rehm 2012); ningún estudio de la cohorte es chileno, pero es la referencia usada por OMS para todos los países |
| P2 | Origen documental de la meseta/RR≥1 desde 60 g/día (EIC hombres) | "Risk relation curve up to 100 g/day: based on [5]; **RR ≥ 1 after 60 g/day**" — presente tanto en los "New algorithms" como en los "Algorithms from GSRAH [2014]" | Rehm et al. 2016, BMC Public Health 16:363, **Tabla 1, p. 4 de 9** [TEXTO: "RR ≥ 1 after 60 g/day"]; [5] = Roerecke & Rehm 2012. Figuras 1 y 2, p. 5 de 9, muestran las curvas | ASUMIDO (regla conservadora de techo impuesta por los modeladores, no un coeficiente estimado) | Alta: regla aplicada por OMS a nivel global; su efecto en Chile depende de la masa de bebedores chilenos >60 g/día (SENDA), no de la regla en sí |
| P3 | Magnitud de la discontinuidad en 60 g/día (EIC hombres) | A x=60⁻: ln RR = −0,0436 (RR=0,957); a x=60⁺: ln RR = 0 (RR=1,000). Salto ≈ +0,044 en ln RR. En 100 g/día la función es continua (RR=1) y sube 0,012/g sobre 100 | **Cálculo propio** a partir de los coeficientes publicados en CAMH 2017 (P1) — [INFERENCIA/cómputo verificado, no una cifra publicada] | ESTIMADO (derivado de coeficientes publicados) | Alta (consecuencia matemática directa) |
| P4 | Función RR EIC mujeres, OMS 2018/2024 | ln RR(x) = 1,897718·y + 1,593365·y·ln(y) para x<30,3814 g/día; ln RR = 0,0093·(x−30,3814) para x≥30,3814; y=(x+0,01)/100. Cruza RR=1 en 30,38 g/día (verificado por cómputo propio) | Rehm, Sherk, Shield & Gmel 2017 (CAMH), sección "Ischemic heart disease" [TEXTO]; base Roerecke & Rehm 2012 | ESTIMADO | Alta (misma base meta-analítica global) |
| P5 | RR ex-bebedores, EIC | Mujeres: 1,54 (IC95% 1,17–2,03); Hombres: 1,25 (IC95% 1,15–1,36) | Roerecke & Rehm 2011, Am J Epidemiol 173(3):245-258 (solo resumen), citado y aplicado en CAMH 2017 y Rehm et al. 2016 (p. 4: "sick quitter effect" modelado solo para países de altos ingresos donde se originó la literatura) [TEXTO en Rehm 2016] | ESTIMADO | **Media**: Rehm et al. 2016 aplican RR de ex-bebedores "solo para países de altos ingresos donde se originó la literatura" [TEXTO] — Chile es ingreso alto OMS/OMS-AMRO B; el equipo debe decidir explícitamente si aplica el efecto "sick quitter" y documentarlo |
| P6 | Función RR ACV isquémico, OMS 2018/2024 | Funciones específicas por sexo y **dependientes de edad**, basadas en el meta-análisis de Patra et al. 2010; ajuste por episodios de consumo excesivo (HED): para bebedores con HED y volumen ≤60 g/día se fija RR=1 | Rehm et al. 2016, p. 4 [TEXTO: "For IS mortality, we used the alcohol RRs from the meta-analyses of Patra and colleagues … for people with heavy drinking occasions and an average volume of alcohol consumption of up to 60 g … we set the RR to 1"]; Patra et al. 2010, BMC Public Health 10:258 (solo resumen; 26 estudios observacionales, 1980–jun 2009) | ESTIMADO (curvas) + ASUMIDO (regla HED) | Alta; la concordancia OMS vs "Tabla 5" en ACV (razón 1,02–1,04 reportada por el equipo) es consistente con que ambas derivan de Patra 2010 [INFERENCIA] |
| P7 | Bandas de edad en OMS 2024 (GSRAHTSUD) | Las funciones 2018 se aplican con RR específicas por edad para EIC y ACV ("the alcohol risk for IHD and IS was modelled based on age-specific RRs estimated based on the observed effect modification of age" — Rehm et al. 2016, p. 4 [TEXTO]); detalles de la ronda 2024: apéndice 1, pp. 60–94 de Shield et al. 2025 | Rehm et al. 2016 p. 4 [TEXTO]; Shield et al. 2025 (texto completo; métodos y apéndice 1) | ESTIMADO | Alta; coherente con el diseño del equipo (PIF por año×sexo×banda etaria) |
| P8 | Factor de corrección 0,8 | Las estimaciones OMS 2024 aplican un factor de corrección de 0,8 en la cadena de cálculo de las fracciones atribuibles | Shield et al. 2025, Métodos (texto completo) | ASUMIDO (convención OMS) | Alta (convención, no parámetro biológico) |
| P9 | Opción "sin cardioprotección" para EIC hombres en InterMAHP | ln RR(x) = 0,002211·x (sin protección a ningún nivel), basada en Zhao et al. 2017 ("personal correspondence J. Zhao, 14-Oct-2017"); InterMAHP **no define función por defecto para EIC masculina** — el usuario debe elegir entre Roerecke & Rehm (con protección) y Zhao (sin protección) y documentarlo | Sherk et al. 2017, InterMAHP v1.0 Comprehensive Guide, §3.2/§6 [TEXTO leído en secciones]; Zhao et al. 2017 (solo resumen) | ESTIMADO | Alta; disponible como plantilla para la sensibilidad C |
| P10 | Extrapolación >100–150 g/día | Funciones OMS definidas 0–150 g/día ("All functions are defined from 0 to 150 g/day" [TEXTO, CAMH 2017]); InterMAHP limita la extrapolación de EIC: RR(100) o pendiente lineal 50–100 g/día por inestabilidad de las curvas más allá de ~125 g/día | CAMH 2017 [TEXTO]; Sherk et al. 2017 [TEXTO, secciones] | ASUMIDO | Alta; el equipo integra hasta 150 g/día — documentar qué regla rige el tramo >100 g/día |
| P11 | "Tabla 5" PUC/SENDA 2018: coeficientes b1, b2; matriz varianza-covarianza; columna "Fact" | **NO ENCONTRADO** (informe inaccesible; ver §8). La forma ln RR = b1·x + b2·x·ln(x) corresponde a un polinomio fraccional de primer grado con potencia repetida (1,1) — la familia ajustada por Roerecke & Rehm 2012 mediante modelos de tendencia de mínimos cuadrados generalizados [INFERENCIA a partir del resumen de R&R 2012, que describe "Generalized least-squares trend models … best-fitting dose-response curves"] | — | — | — |

---

## 2. Respuestas a las preguntas del equipo

### Q1. Evidencia actual sobre dosis-respuesta y cardioprotección en EIC/ACV isquémico (¿se recomienda sensibilidad "sin protección"?)

La meta-evidencia clásica sustenta la curva en J: Roerecke & Rehm 2012 (44 estudios; 38.627 eventos EIC; 957.684 personas; 1980–2010) confirman "some form of a cardioprotective association … in all strata" pero advierten que no puede asumirse para todos los bebedores (solo resumen) [TEXTO]. La línea crítica atenúa esa protección: Zhao et al. 2017 — al estratificar por calidad/sesgo de abstinente, el RR a bajo volumen deja de ser significativo (0,95 [0,75–1,21] en cohortes ≤55 años; 0,86 [0,68–1,09] en estudios de mayor calidad) (solo resumen); Biddinger et al. 2022 (UK Biobank, n=371.463) — aleatorización mendeliana: riesgo mínimo en consumo ligero y aumento exponencial en pesado, sin protección causal clara (solo resumen); Carr et al. 2024 — nadir RR=0,69 [0,48–1,01] a 23 g/día, IC que incluye 1, MR nula (solo resumen); Zhao et al. 2023 (107 cohortes) — RR=0,93 [0,85–1,01] (solo resumen); GBD 2020 — protección solo plausible en edades mayores, con baja certeza (solo resumen). **Advertencia: no significativo ≠ ausencia de efecto; la cardioprotección no está refutada, está disputada.** Sí se recomienda la sensibilidad "sin protección": InterMAHP ya la ofrece como opción documentada (P9) y su costo de implementación es mínimo.

### Q2. Formas funcionales y bandas de edad de OMS 2024/GSRAHTSUD e InterMAHP 2018; origen de la meseta 60–100 g/día

OMS 2024 usa las funciones 2018 con RR específicas por edad para enfermedades isquémicas (Shield et al. 2025, texto completo; apéndice 1, pp. 60–94). La especificación por tramos está en el informe técnico CAMH (Rehm, Sherk, Shield & Gmel 2017) [TEXTO]: EIC hombres ln RR = −0,5043554·√y + 1,606235·y³ (x≤60), **0 para 60<x<100**, 0,012·(x−100) (x≥100), y=(x+0,01)/100; EIC mujeres 1,897718·y + 1,593365·y·ln(y), quiebre en 30,3814 g/día. El origen documental de la meseta es **Rehm et al. 2016, Tabla 1, p. 4 de 9**: "RR ≥ 1 after 60 g/day", basada en Roerecke & Rehm 2012 y ya presente en el GSRAH 2014 [TEXTO]. Es una **convención conservadora de modelamiento**, no un coeficiente meta-analítico, y produce la discontinuidad 0,957→1,000 en 60 g/día (cómputo propio, P3). ACV isquémico: funciones por sexo y edad basadas en Patra et al. 2010, con RR=1 si hay HED y volumen ≤60 g/día [TEXTO, Rehm 2016 p. 4]. InterMAHP 2018 incorpora estas funciones y para EIC masculina ofrece además la opción sin cardioprotección de Zhao 2017 (ln RR=0,002211·x), sin default, exigiendo documentar la elección [TEXTO, secciones].

### Q3. Fuente original de la "Tabla 5" del estudio PUC/SENDA 2018; matriz de varianza-covarianza; columna "Fact"

El estudio está identificado: *Estudio del Costo Económico y Social del Consumo de Alcohol en Chile: Actualización de informe final*, licitación SENDA ID 662237-9-LP17, Depto. de Salud Pública PUC (IP: Paula Margozzini; carga atribuible: Pedro Zitko; Guillermo Paraje, UAI), apoyo de OMS/CAMH; presentado el 14-03-2019 [TEXTO]. **La Tabla 5 es NO ENCONTRADA**: el PDF del informe devuelve 404 en medicina.uc.cl y no hay espejo accesible (Wayback inalcanzable; Scribd bloqueado; medios 2019 purgados del sitio UC) — rastro en §8. Por tanto, su fuente original, la publicación de la matriz de varianza-covarianza b1–b2 y el significado de la columna "Fact" son **NO ENCONTRADO / NO VERIFICADO**. Hipótesis [INFERENCIA]: la forma ln RR = b1·x + b2·x·ln(x) corresponde al polinomio fraccional (1,1) de la familia de Roerecke & Rehm 2012 (EIC), afín a Patra et al. 2010 (ACV), coherente con la coincidencia de curvas <40 g/día y la divergencia >60 g/día (sin meseta OMS). "Fact" podría ser un factor de ajuste (p. ej., morbilidad→mortalidad); no verificable. Solicitar el informe y la tabla fuente a la Dra. Margozzini o a SENDA.

---

## 3. Tabla de evidencia

| Referencia | DOI / PMID / URL | Diseño / población | Qué sostiene | Números clave (página/tabla; unidad; denominador; período; estimado/asumido) | Transportabilidad | Calidad / limitaciones |
|---|---|---|---|---|---|---|
| Roerecke & Rehm 2012, Addiction 107(7):1246-1260 (solo resumen) | doi:10.1111/j.1360-0443.2012.03780.x; PMID 22229788 | Revisión sistemática + meta-análisis dosis-respuesta continuo (GLS); 44 estudios observacionales; 38.627 eventos EIC; 957.684 participantes; literatura 1980–2010 | Base meta-analítica de las curvas EIC de OMS 2018/2024 (P1–P4); confirma asociación cardioprotectora en todos los estratos pero con heterogeneidad sustancial no explicada | "38,627 IHD events … among 957,684 participants" (resumen); curvas por sexo y desenlace (mortalidad/morbilidad), Figuras 2–3; ESTIMADO | Alta (global; sin cohortes chilenas) | Alta calidad metodológica; heterogeneidad residual amplia, IC anchos a 1–2 tragos/día; el propio abstract advierte que la protección "cannot be assumed for all drinkers" |
| Roerecke & Rehm 2011, Am J Epidemiol 173(3):245-258 (solo resumen) | doi:10.1093/aje/kwq378 | Meta-análisis de RR de ex-bebedores vs abstinentes de por vida | RR de ex-bebedores para EIC (P5): mujeres 1,54 (1,17–2,03); hombres 1,25 (1,15–1,36) | Valores citados y aplicados en CAMH 2017 y Rehm et al. 2016 (p. 4); ESTIMADO | Media: Rehm 2016 aplica estos RR solo donde se originó la literatura (países de altos ingresos) | Meta-análisis estándar; definición de ex-bebedor heterogénea entre estudios |
| Patra et al. 2010, BMC Public Health 10:258 (solo resumen) | doi:10.1186/1471-2458-10-258; PMID 20482788 | Revisión sistemática + meta-análisis; 26 estudios observacionales (cohorte/casos-controles); búsqueda 1980–jun 2009; ACV isquémico y hemorrágico por sexo y desenlace | Base de las funciones RR de ACV isquémico de OMS 2018/2024 (P6) | 26 estudios; separación morbilidad/mortalidad "is the first to explicitly separate morbidity and mortality" (resumen); ESTIMADO | Alta (global) | Referencia canónica para ACV en OMS; heterogeneidad por tipo de ACV y sexo; datos antiguos (hasta 2009) |
| Roerecke & Rehm 2014, BMC Med 12:182 (solo resumen) | doi:10.1186/s12916-014-0182-6 | Meta-análisis; EIC mortalidad/morbilidad | La protección desaparece con episodios de consumo excesivo: moderado sin HED RR=0,64 (0,53–0,71); con HED RR=1,12 (0,91–1,37, no significativo) | IC95% reportados en resumen; ESTIMADO; nota: no significativo ≠ sin efecto | Alta | Apoya el ajuste por HED (P6) y la idea de que la cardioprotección depende del patrón |
| Roerecke & Rehm 2014, Open Heart 1:e000135 (solo resumen) | doi:10.1136/openhrt-2014-000135 | Meta-análisis; consumo crónico pesado ≥60 g/día e incidencia de EIC | A ≥60 g/día la incidencia de EIC no aumenta significativamente: RR=1,04 (0,83–1,31) | Resumen; ESTIMADO; intervalo amplio | Alta | Sustenta indirectamente la meseta RR≥1 desde 60 g/día (P2), aunque con incertidumbre amplia |
| Zhao, Stockwell, Roemer, Naimi & Chikritzhs 2017, J Stud Alcohol Drugs 78(3):375-386 (solo resumen) | doi:10.15288/jsad.2017.78.375; PMID 28499102 | Meta-análisis de 45 cohortes longitudinales; mortalidad por EIC | La cardioprotección se atenúa/anula en estratos de mayor calidad (sesgo de abstinente): ajustado completo RR=0,80 (0,69–0,93); cohortes ≤55 años RR=0,95 (0,75–1,21) NS; con control de salud cardiaca RR=0,87 (0,71–1,06) NS; mayor calidad RR=0,86 (0,68–1,09) NS | Resumen; 45 cohortes; ESTIMADO | Alta | Base de la opción "sin cardioprotección" de InterMAHP (P9); clave para sensibilidad C |
| Biddinger et al. 2022, JAMA Netw Open 5(3):e223849 (solo resumen) | doi:10.1001/jamanetworkopen.2022.3849 | Cohorte UK Biobank n=371.463 + aleatorización mendeliana (lineal y no lineal); seguimiento ~9,5 años | MR lineal: 1 DE genética de consumo → hipertensión 1,3× (1,2–1,4) y enfermedad coronaria 1,4× (1,1–1,8); MR no lineal: riesgo mínimo en consumo ligero, aumento exponencial en pesado | Resumen; n=371.463; ESTIMADO | Media: biobanco europeo, patrón de consumo distinto al chileno | MR reduce confusión y causalidad inversa; supuestos de MR (pleiotropía) discutidos en la literatura |
| Zhao et al. 2023, JAMA Netw Open 6(3):e236185 (solo resumen) | doi:10.1001/jamanetworkopen.2023.6185 | Meta-análisis de 107 cohortes; mortalidad por todas las causas | Sin protección significativa a bajo volumen: RR=0,93 (0,85–1,01) | Resumen; 107 cohortes; ESTIMADO | Alta | Mortalidad total (no EIC); corrobora dirección del sesgo de abstinente |
| Stockwell et al. 2024, J Stud Alcohol Drugs 85(4):441-452 (solo resumen) | doi:10.15288/jsad.23-00283 | Meta-análisis actualizado con gradación de calidad | La aparente protección se concentra en estudios de menor calidad/mayor edad de medición | Resumen; ESTIMADO | Alta | Actualización más reciente de la línea crítica |
| Carr et al. 2024, Nat Commun (solo resumen) | doi:10.1038/s41467-024-47632-7 | Meta-análisis "burden of proof" (EIC) + MR | Curva en J con nadir RR=0,69 (0,48–1,01) a 23 g/día — el IC incluye 1 —; MR no confirma protección | Resumen; ESTIMADO | Alta | Marco BoP conservador; calificación de evidencia baja para protección |
| GBD 2020 Alcohol Collaborators (Bryazka et al. 2022), Lancet 400:185-235 (solo resumen) | doi:10.1016/S0140-6736(22)00847-9; PMID 35843246 | Análisis de riesgo sistemático GBD 2020; 204 países; 1990–2020 | Nivel teórico de riesgo mínimo (TMREL) dependiente de edad: protección solo plausible en edades mayores y con baja certeza; para poblaciones jóvenes el TMREL es ~0 | Resumen; ESTIMADO | Alta | Convención GBD distinta de OMS (usar como contraste, no mezclar funciones) |
| Rehm, Shield, Roerecke & Gmel 2016, BMC Public Health 16:363 **[texto completo]** | doi:10.1186/s12889-016-3026-9; PMID 27121289 | Re-análisis de evaluación comparativa de riesgo (mortalidad EIC/ACV isquémico, 2012, global) | **Origen documental de la meseta**: Tabla 1, p. 4/9 ("RR ≥ 1 after 60 g/day", basada en Roerecke & Rehm 2012; ya presente en GSRAH 2014); Figuras 1–2, p. 5/9 (curvas EIC hombres/mujeres); base de ACV = Patra 2010 con regla HED (p. 4); bandas de edad por modificación de efecto (p. 4) | Carga EIC 2012 global nueva metodología: 204.620 muertes (IC95% 162.064–247.176; Tabla 2–3); ESTIMADO; la regla de techo es ASUMIDA | Alta | Documento puente entre meta-análisis y OMS 2018; Rusia modelada aparte (no aplicable a Chile) |
| Rehm et al. 2017, Addiction 112(6):968-1001 (solo resumen) | doi:10.1111/add.13757 | Actualización de la relación dosis-enfermedad para evaluaciones comparativas | Lista canónica de condiciones causales y funciones RR que usa OMS 2018/GSRAHTSUD 2024 | Referencia n.º 32 de Shield et al. 2025 [TEXTO]; resumen | Alta | Base conceptual; la especificación por tramos está en CAMH 2017, no en este artículo |
| Rehm, Sherk, Shield & Gmel 2017, *Risk relations between alcohol use and non-injury causes of death*, v2, CAMH, Toronto **[secciones íntegras]** | ISBN 978-1-77114-399-8; https://www.camh.ca/-/media/files/pdfs---reports-and-books---research/camh-risk-relations-between-alcohol-use-and-non-injury-causes-of-death-sept2017-pdf.pdf | Informe técnico (estándar GATHER) | **Especificación matemática exacta** de las funciones OMS 2018/2024 (P1, P4), incluida la meseta ln RR=0 en 60–100 g/día; dominio 0–150 g/día ("All functions are defined from 0 to 150 g/day"); fuentes de cada función | Funciones citadas en P1/P4 (sección "Ischemic heart disease"; página exacta NO VERIFICADA — ver §8); ASUMIDO (techo) sobre ESTIMADO (curvas) | Alta | Documento técnico no revisado por pares en revista, pero es la referencia operativa oficial de OMS/InterMAHP |
| Sherk, Stockwell, Rehm, Dorocicz & Shield 2017, InterMAHP v1.0 Comprehensive Guide, CISUR/CARBC, U. Victoria **[secciones íntegras]** | https://www.drugsandalcohol.ie/28421/ | Guía metodológica de modelamiento | Estructura de la librería RR (Outcome, RR_FD, BingeF, Function; §3.2); para EIC hombres **no hay default**: opción Roerecke & Rehm (con protección) vs Zhao 2017 ln RR=0,002211·x (sin protección, "personal correspondence J. Zhao, 14-Oct-2017"); límite de extrapolación EIC >100 g/día | §3.2, §6; ASUMIDO (convenciones) | Alta | Guía técnica; demuestra que "sin cardioprotección" es escenario reconocido internacionalmente |
| Shield et al. 2025, Lancet Public Health 10(9):e751-e761 **[texto completo]** | doi:10.1016/S2468-2667(25)00174-4; PMID 40883042 | Estimación de carga atribuible global 2019 (base de OMS 2024 GSRAHTSUD); PAF tipo Levin, exposición gamma (método de Kehoe et al.), factor de corrección 0,8; RR de meta-análisis (apéndice 1, pp. 60–94); funciones deliberadas por el Grupo Asesor Técnico OMS (consenso mayoritario) | Métodos y convenciones de OMS 2024 (P7–P8); magnitudes globales: EIC 2019 = 208.300 muertes atribuibles (IU −6.400 a 422.200 — el intervalo cruza cero); ACV isquémico = −65.500 (−144.600 a 40.800; efecto neto protector en la estimación puntual) | Métodos y resultados, texto completo; 2,6 millones de muertes atribuibles al alcohol en 2019 (4,7% del total); ESTIMADO | Alta | Demuestra que incluso la OMS obtiene estimaciones puntuales "protectoras" para ACV isquémico con IU que cruzan cero — argumento para reportar sensibilidad C |
| OMS 2024, *Global status report on alcohol and health and treatment of substance use disorders* | ISBN 9789240096745; https://www.who.int/publications/i/item/9789240096745 | Informe normativo OMS (334 pp.) | Marco de definiciones y métodos de la fuente principal del equipo | **NO LEÍDO a texto completo** (verificado a nivel de ficha/ISBN y vía Shield et al. 2025); las funciones provienen de 2018 + bandas de edad (según equipo, coherente con Shield 2025) | Alta | Informe gubernamental/normativo: define convenciones, no constituye por sí solo evidencia causal |
| Castillo-Carniglia, Kaufman & Pino 2013, Alcohol Alcohol 48(6):729-736 (solo resumen) | doi:10.1093/alcalc/agt066; PMID 23831731 | Estimación de mortalidad y AVPP atribuibles al alcohol, Chile 2009; ≥15 años; exposición triangulada consumo per cápita + VIII Estudio Nacional de Drogas 2008; RR de meta-análisis previos; IC por Monte Carlo | Precedente chileno directo del diseño del equipo (misma arquitectura FAA/gamma/Monte Carlo) | 8.753 muertes atribuibles (IC95% 6.257–11.584) = **9,8%** (7,01–12,98) de todas las muertes 2009; 195.475 AVPP (164.287–227.726) = 21,5%; ESTIMADO | **Chilena (máxima)** | No separa publicadamente funciones EIC/ACV; años 2008–2009 |
| Ruiz-Tagle Maturana, Román Mella & Castillo-Carniglia 2026, Public Health in Practice, 100798 (solo resumen) | doi:10.1016/j.puhip.2026.100798 | Mortalidad atribuible al alcohol por sexo y edad, Chile 2008–2022 (PMC13195772) | Tendencia chilena reciente: fracción atribuible desciende de ~14,6% a ~9,6% en el período | Cifras de proporción leídas en fuente secundaria/abstract; ESTIMADO | **Chilena (máxima)** | Corrigendum asociado (doi:10.1016/j.puhip.2026.100812) — revisar antes de citar cifras finas |
| PUC/SENDA 2018, *Estudio del Costo Económico y Social del Consumo de Alcohol en Chile* (licitación 662237-9-LP17) | Informe NO ENCONTRADO (ver §8); noticia: https://facultadmedicina.uc.cl/noticias/estudio-uc-senda-estima-el-costo-economico-atribuible-al-consumo-abusivo-de-alcohol-en-chile-en-1-5-billones-de-pesos-anuales/ ; presentación: https://uchile.cl/dam/jcr:52cd4405-3dda-4c8b-8ad0-a6b7fb9b054e/dra-paula-margozzini.pdf | Estudio de costos y carga atribuible, Chile; mortalidad 2014, costos 2017 | Estudio del que proviene la "Tabla 5"; resultados globales verificados: **13.260 muertes atribuibles en 2014 (13%; 36/día)**; costo total $1.488.776.225.023 CLP-2017 (30,1% salud, 52,2% mortalidad prematura, 15,5% crimen) | Cifras globales vía noticia Facultad de Medicina UC y presentaciones [TEXTO]; **coeficientes de la Tabla 5: NO ENCONTRADO** | **Chilena (máxima)** | Informe gubernamental/universitario sin revisión por pares externa; inaccesible → no usable como fuente primaria verificable |

---

## 4. Evidencia chilena y latinoamericana (sección separada, según regla 10)

**Chile.** Existen tres antecedentes nacionales de estimación de carga atribuible al alcohol, todos con la misma arquitectura metodológica del estudio del equipo (fracciones atribuibles que integran funciones RR meta-analíticas internacionales sobre la distribución de exposición local): (i) Castillo-Carniglia et al. 2013 estimaron 8.753 muertes atribuibles (9,8% del total) y 195.475 AVPP en 2009, triangulando consumo per cápita con el VIII Estudio Nacional de Drogas 2008 y aplicando RR "from previously published meta-analyses" con Monte Carlo (solo resumen) [TEXTO]; (ii) el estudio PUC/SENDA 2018 (licitación 662237-9-LP17) estimó 13.260 muertes atribuibles en 2014 (13% del total; 36 por día) y un costo de $1,489 billones CLP-2017, con el 36,5% del costo directo de salud en enfermedades cardiovasculares (noticia Facultad de Medicina UC, 14-03-2019; presentaciones de la Dra. Margozzini, 14-03-2019 y 13-06-2019) [TEXTO]; y (iii) Ruiz-Tagle Maturana et al. 2026 documentan el descenso de la fracción atribuible entre 2008 y 2022 (~14,6%→9,6%) (solo resumen). Ninguno de los tres publica funciones RR propias para EIC o ACV: en todos los casos las funciones se toman de la literatura meta-analítica internacional [INFERENCIA a partir de los métodos leídos]. Para la "Tabla 5" del estudio PUC/SENDA 2018 específicamente, ni su procedencia, ni su matriz de varianza-covarianza, ni su columna "Fact" pudieron verificarse (NO ENCONTRADO, §8).

**Latinoamérica.** NO ENCONTRADO: no se identificó ningún meta-análisis latinoamericano ni función RR regional para EIC/ACV isquémico; las evaluaciones de la región (incluido Chile) usan las funciones globales de la familia OMS/Rehm o GBD. Esto significa que la transportabilidad de las funciones OMS 2024 a Chile no tiene contrincante regional: la elección real es entre versiones de la misma familia internacional y sus variantes de modelamiento (con/sin meseta, con/sin cardioprotección), no entre evidencia local e internacional [INFERENCIA].

**Separación de planos (regla 10):** (a) evidencia chilena = cargas y costos estimados con funciones importadas; (b) latinoamericana = inexistente para funciones RR; (c) meta-análisis internacionales = Roerecke & Rehm 2012 y Patra et al. 2010 (base OMS), Zhao et al. 2017/2023, Biddinger et al. 2022, Carr et al. 2024 (línea crítica); (d) convenciones de modelo = OMS GSRAH 2014/2018/2024 (meseta 60–100, factor 0,8, bandas de edad), InterMAHP (opciones documentadas, límites de extrapolación) y GBD 2020 (TMREL por edad). Las convenciones de (d) no deben citarse como si fueran evidencia causal de (c).

---

## 5. Recomendación

**Opción recomendada: A — mantener OMS 2018/2024 (GSRAHTSUD) como fuente principal y la "Tabla 5" PUC/SENDA como análisis de sensibilidad — con una modificación de la opción C: implementar proactivamente la sensibilidad "sin cardioprotección" (RR truncada en 1 para EIC), sin esperar a que el IP la solicite.**

- **Fuerza de la recomendación: ALTA** para A (la fuente principal debe ser trazable, vigente y defendible: OMS 2024 cumple; la Tabla 5 no puede verificarse en su fuente primaria); **MEDIA-ALTA** para incorporar C proactivamente (la literatura 2017–2024 y la propia arquitectura de InterMAHP la legitiman, y blinda la tesis ante revisores que citen a Zhao, Biddinger o Carr).
- **Qué cambiaría la recomendación:** (i) que el equipo obtuviera el informe PUC/SENDA 2018 completo (o de su autores la tabla fuente y la matriz de varianza-covarianza) y verificara que la Tabla 5 corresponde a coeficientes publicados de Roerecke & Rehm 2012/Patra et al. 2010 — en ese caso la Tabla 5 pasaría de "sensibilidad de procedencia dudosa" a "sensibilidad con procedencia documentada" (sigue sin reemplazar a OMS, pero se cita mejor); (ii) que una futura edición OMS o un meta-análisis definitivo eliminara la cardioprotección de las funciones oficiales (entonces C se transformaría en la estimación principal); (iii) que el PI decidiera alinearse con GBD en lugar de OMS (decisión de marco, no de evidencia).
- **Limitación a declarar explícitamente en el manuscrito:** "Las funciones OMS 2018/2024 para EIC masculina incorporan una meseta RR=1 entre 60 y 100 g/día (convención de modelamiento conservadora introducida en el GSRAH 2014; Rehm et al. 2016, Tabla 1), que genera PIF de reducción de volumen ≈0 en ese tramo; la evidencia reciente sobre la existencia y magnitud de la cardioprotección es contradictoria (Zhao 2017/2023; Biddinger 2022; Carr 2024 vs Roerecke & Rehm 2012/2014); por ello reportamos análisis de sensibilidad con la parametrización sin meseta del estudio PUC/SENDA 2018 (Tabla 5) y con un escenario sin cardioprotección (RR≥1, análogo a la opción de Zhao 2017 en InterMAHP). La ausencia de la matriz de varianza-covarianza b1–b2 de la Tabla 5 obliga a usar covarianza diagonal en esa sensibilidad, lo que degenera los intervalos de la EIC femenina y debe interpretarse con cautela."

---

## 6. Methods paragraphs (English)

**Paragraph 1 — Primary RR source.** Relative-risk (RR) functions for ischaemic heart disease (IHD) and ischaemic stroke were taken from the WHO Global Status Report on Alcohol and Health and Treatment of Substance Use Disorders (WHO 2024), which applies the 2018 WHO comparative risk assessment functions with age-specific RRs for ischaemic diseases (Rehm et al. 2016; Shield et al. 2025). The male IHD volume function is piecewise: a fractional polynomial up to 60 g/day, a plateau fixed at RR=1 for 60–100 g/day, and a linear rise of 0.012 in ln(RR) per gram above 100 g/day (Rehm et al. 2017, CAMH technical report). The plateau is a conservative modelling convention first documented in the 2014 GSRAH re-analysis (Rehm et al. 2016, Table 1), itself based on the meta-analysis of Roerecke and Rehm (2012); it implies that male IHD potential impact fractions for volume reductions within 60–100 g/day are approximately zero by construction. Ischaemic stroke functions follow Patra et al. (2010), with age modification and an RR set to 1 for heavy-occasion drinkers averaging ≤60 g/day (Rehm et al. 2016).

**Paragraph 2 — Sensitivity analyses.** Two sensitivity analyses bracket the disputed cardioprotective assumption. First, the sex-specific ln RR = b1·x + b2·x·ln(x) parameterization reported in "Tabla 5" of the PUC/SENDA (2018) Chilean cost-of-alcohol study (Licitación ID 662237-9-LP17) was applied without the WHO plateau; this table derives from the same meta-analytic family (Roerecke and Rehm 2012) but lacks a published b1–b2 covariance matrix, so Monte Carlo draws used a diagonal covariance, which is acknowledged to degenerate uncertainty intervals for female IHD. Second, a no-cardioprotection scenario truncated IHD RRs at 1, mirroring the Zhao et al. (2017) option offered alongside the Roerecke and Rehm functions in the InterMAHP v1.0 framework (Sherk et al. 2017). This scenario reflects evidence that the apparent protection is attenuated or null in higher-quality cohorts and in Mendelian randomization (Zhao et al. 2017; Biddinger et al. 2022; Zhao et al. 2023; Carr et al. 2024).

---

## 7. BibTeX

```bibtex
@article{roerecke2012ihd,
  author  = {Roerecke, Michael and Rehm, J{\"u}rgen},
  title   = {The cardioprotective association of average alcohol consumption and ischaemic heart disease: a systematic review and meta-analysis},
  journal = {Addiction},
  year    = {2012},
  volume  = {107},
  number  = {7},
  pages   = {1246--1260},
  doi     = {10.1111/j.1360-0443.2012.03780.x}
}

@article{roerecke2011former,
  author  = {Roerecke, Michael and Rehm, J{\"u}rgen},
  title   = {Ischemic heart disease mortality and morbidity among former drinkers: a meta-analysis},
  journal = {American Journal of Epidemiology},
  year    = {2011},
  volume  = {173},
  number  = {3},
  pages   = {245--258},
  doi     = {10.1093/aje/kwq378}
}

@article{roerecke2014bmcmed,
  author  = {Roerecke, Michael and Rehm, J{\"u}rgen},
  title   = {Alcohol consumption, drinking patterns, and ischemic heart disease: a narrative review of meta-analyses and a systematic review and meta-analysis of the impact of heavy drinking occasions on risk for moderate drinkers},
  journal = {BMC Medicine},
  year    = {2014},
  volume  = {12},
  pages   = {182},
  doi     = {10.1186/s12916-014-0182-6}
}

@article{roerecke2014openheart,
  author  = {Roerecke, Michael and Rehm, J{\"u}rgen},
  title   = {Chronic heavy drinking and ischaemic heart disease: a systematic review and meta-analysis},
  journal = {Open Heart},
  year    = {2014},
  volume  = {1},
  pages   = {e000135},
  doi     = {10.1136/openhrt-2014-000135}
}

@article{patra2010stroke,
  author  = {Patra, Jayadeep and Taylor, Benjamin and Irving, Hyacinth and Roerecke, Michael and Baliunas, Dolly and Mohapatra, Satya and Rehm, J{\"u}rgen},
  title   = {Alcohol consumption and the risk of morbidity and mortality for different stroke types--a systematic review and meta-analysis},
  journal = {BMC Public Health},
  year    = {2010},
  volume  = {10},
  pages   = {258},
  doi     = {10.1186/1471-2458-10-258}
}

@article{zhao2017abstainer,
  author  = {Zhao, Jinhui and Stockwell, Tim and Roemer, Audra and Naimi, Timothy and Chikritzhs, Tanya},
  title   = {Alcohol Consumption and Mortality From Coronary Heart Disease: An Updated Meta-Analysis of Cohort Studies},
  journal = {Journal of Studies on Alcohol and Drugs},
  year    = {2017},
  volume  = {78},
  number  = {3},
  pages   = {375--386},
  doi     = {10.15288/jsad.2017.78.375}
}

@article{biddinger2022mr,
  author  = {Biddinger, Kiran J. and others},
  title   = {Association of Habitual Alcohol Intake With Risk of Cardiovascular Disease},
  journal = {JAMA Network Open},
  year    = {2022},
  volume  = {5},
  number  = {3},
  pages   = {e223849},
  doi     = {10.1001/jamanetworkopen.2022.3849}
}

@article{zhao2023allcause,
  author  = {Zhao, Jinhui and Stockwell, Tim and Naimi, Timothy and Churchill, Sam and Clay, James and Sherk, Adam},
  title   = {Association Between Daily Alcohol Intake and Risk of All-Cause Mortality: A Systematic Review and Meta-analyses},
  journal = {JAMA Network Open},
  year    = {2023},
  volume  = {6},
  number  = {3},
  doi     = {10.1001/jamanetworkopen.2023.6185}
}

@article{stockwell2024,
  author  = {Stockwell, Tim and others},
  title   = {Exploring the association between alcohol use and mortality in cohort studies of alcohol consumption and mortality: a meta-analysis},
  journal = {Journal of Studies on Alcohol and Drugs},
  year    = {2024},
  volume  = {85},
  number  = {4},
  pages   = {441--452},
  doi     = {10.15288/jsad.23-00283}
}

@article{carr2024bop,
  author  = {Carr, Sarah and others},
  title   = {A burden of proof study on alcohol consumption and ischemic heart disease},
  journal = {Nature Communications},
  year    = {2024},
  doi     = {10.1038/s41467-024-47632-7}
}

@article{gbd2020alcohol,
  author  = {{GBD 2020 Alcohol Collaborators}},
  title   = {Population-level risks of alcohol consumption by amount, geography, age, sex, and year: a systematic analysis for the Global Burden of Disease Study 2020},
  journal = {The Lancet},
  year    = {2022},
  volume  = {400},
  number  = {10347},
  pages   = {185--235},
  doi     = {10.1016/S0140-6736(22)00847-9}
}

@article{rehm2016cvd,
  author  = {Rehm, J{\"u}rgen and Shield, Kevin D. and Roerecke, Michael and Gmel, Gerrit},
  title   = {Modelling the impact of alcohol consumption on cardiovascular disease mortality for comparative risk assessments: an overview},
  journal = {BMC Public Health},
  year    = {2016},
  volume  = {16},
  pages   = {363},
  doi     = {10.1186/s12889-016-3026-9}
}

@article{rehm2017update,
  author  = {Rehm, J{\"u}rgen and Gmel, Gerhard E. and Gmel, Gerrit and Hasan, Omer S. M. and Imtiaz, Sameer and Popova, Svetlana and Probst, Charlotte and Roerecke, Michael and Room, Robin and Samokhvalov, Andriy V. and Shield, Kevin D. and Shuper, Paul A.},
  title   = {The relationship between different dimensions of alcohol use and the burden of disease--an update},
  journal = {Addiction},
  year    = {2017},
  volume  = {112},
  number  = {6},
  pages   = {968--1001},
  doi     = {10.1111/add.13757}
}

@techreport{rehm2017camh,
  author      = {Rehm, J{\"u}rgen and Sherk, Adam and Shield, Kevin D. and Gmel, Gerrit},
  title       = {Risk relations between alcohol use and non-injury causes of death. Version 2: September 2017},
  institution = {Centre for Addiction and Mental Health, Toronto},
  year        = {2017},
  url         = {https://www.camh.ca/-/media/files/pdfs---reports-and-books---research/camh-risk-relations-between-alcohol-use-and-non-injury-causes-of-death-sept2017-pdf.pdf}
}

@techreport{sherk2017intermahp,
  author      = {Sherk, Adam and Stockwell, Tim and Rehm, J{\"u}rgen and Dorocicz, John and Shield, Kevin D.},
  title       = {The International Model of Alcohol Harms and Policies (InterMAHP) Version 1.0: A comprehensive guide to the estimation of alcohol-attributable morbidity and mortality},
  institution = {Centre for Addictions Research of British Columbia, University of Victoria},
  year        = {2017},
  url         = {https://www.drugsandalcohol.ie/28421/}
}

@article{shield2025who,
  author  = {Shield, Kevin D. and others},
  title   = {National, regional, and global statistics on alcohol-attributable deaths and disability-adjusted life-years in 2019: a comprehensive analysis for the WHO Global Status Report on Alcohol and Health and Treatment of Substance Use Disorders},
  journal = {The Lancet Public Health},
  year    = {2025},
  volume  = {10},
  number  = {9},
  pages   = {e751--e761},
  doi     = {10.1016/S2468-2667(25)00174-4}
}

@techreport{who2024gsrahtsud,
  author      = {{World Health Organization}},
  title       = {Global status report on alcohol and health and treatment of substance use disorders},
  institution = {World Health Organization, Geneva},
  year        = {2024},
  url         = {https://www.who.int/publications/i/item/9789240096745}
}

@article{castillocarniglia2013,
  author  = {Castillo-Carniglia, {\'A}lvaro and Kaufman, Jay S. and Pino, Paulina},
  title   = {Alcohol-attributable mortality and years of potential life lost in Chile in 2009},
  journal = {Alcohol and Alcoholism},
  year    = {2013},
  volume  = {48},
  number  = {6},
  pages   = {729--736},
  doi     = {10.1093/alcalc/agt066}
}

@article{ruiztagle2026,
  author  = {Ruiz-Tagle Maturana, Jaime and Rom{\'a}n Mella, Felipe and Castillo-Carniglia, {\'A}lvaro},
  title   = {Sex and age differences in alcohol-attributable mortality in Chile between 2008 and 2022},
  journal = {Public Health in Practice},
  year    = {2026},
  doi     = {10.1016/j.puhip.2026.100798}
}

@techreport{pucsenda2018,
  author      = {Margozzini, Paula and Paraje, Guillermo and Zitko, Pedro and Espinoza, Manuel and Balmaceda, Carlos and Abbot, Tom{\'a}s and Bedregal, Paula},
  title       = {Estudio del Costo Econ{\'o}mico y Social del Consumo de Alcohol en Chile: Actualizaci{\'o}n de informe final (Licitaci{\'o}n SENDA ID 662237-9-LP17)},
  institution = {Departamento de Salud P{\'u}blica, Pontificia Universidad Cat{\'o}lica de Chile / SENDA},
  year        = {2018},
  url         = {https://facultadmedicina.uc.cl/noticias/estudio-uc-senda-estima-el-costo-economico-atribuible-al-consumo-abusivo-de-alcohol-en-chile-en-1-5-billones-de-pesos-anuales/},
  note        = {Informe completo no accesible en l{\'i}nea al 2026-10-08; URL corresponde a la noticia institucional que documenta el estudio}
}
```

---

## 8. Lista NO ENCONTRADO / NO VERIFICADO y discrepancias de DOI

**NO ENCONTRADO (con descripción de la búsqueda, regla 2):**

1. **Informe completo PUC/SENDA 2018 (incluye la "Tabla 5" con coeficientes b1/b2, su matriz de varianza-covarianza y la columna "Fact").** Búsqueda realizada: (i) URL original en medicina.uc.cl (`/wp-content/uploads/2019/06/COSTO-ALCOHOL_Actualización-2018_Informe.pdf`) en dos codificaciones Unicode → 404; (ii) Wayback Machine (web.archive.org) → inalcanzable desde este entorno (tiempos de espera agotados en shell y en navegador); (iii) archive.ph → error; (iv) resumen de 35 páginas en Scribd (documento 482780675) → la página carga solo el primer pliego; el visor y el embed fueron bloqueados; (v) API REST de WordPress de medicina.uc.cl (`/wp-json/wp/v2/media`) → los archivos de 2019 fueron purgados en la migración del sitio (la biblioteca solo conserva medios de 2025); (vi) búsquedas en Dipres (bibliotecadigital y artículos 597), SENDA (senda.gob.cl), MercadoPúblico (licitación 662237-9-LP17 sin adjuntos públicos indexados), ResearchGate, SciELO y repositorios UC/UChile → sin el informe; (vii) noticias (Facultad de Medicina UC 14-03-2019, radio Presidente Ibáñez, BioBioChile, IPS-USS) y presentaciones (U. de Chile, 13-06-2019) → confirman identidad, equipo y cifras globales, pero no contienen la Tabla 5. **Recomendación al equipo:** solicitar el informe directamente a la Dra. Paula Margozzini (Depto. Salud Pública PUC) o a SENDA (contraparte: José Marín), y pedir además la tabla fuente con la matriz de varianza-covarianza.
2. **Significado de la columna "Fact" de la Tabla 5** — NO ENCONTRADO. Hipótesis no verificables [INFERENCIA]: (a) factor de ajuste morbilidad→mortalidad; (b) análogo al "BingeFactor" de la librería RR de InterMAHP (que aplica solo a lesiones, Sherk et al. 2017 §3.2); (c) factor de escalamiento de unidades (g/día vs. y=(x+0,01)/100). Dado que el equipo confirma que "Fact" no se aplica en el cálculo, la cautela documental exige declararlo como columna de significado no verificado.
3. **Matriz de varianza-covarianza b1–b2 de las funciones de la Tabla 5** — NO ENCONTRADO. Tampoco se verificó que Roerecke & Rehm 2012 (artículo de pago, leído solo en resumen) publique coeficientes y covarianza completos; el informe CAMH 2017 publica las funciones pero no la matriz de covarianza de los polinomios fraccionales.
4. **Página exacta de la tabla de funciones EIC dentro del informe CAMH 2017** — NO VERIFICADO (el índice y las secciones fueron leídos; la sección "Ischemic heart disease" contiene las funciones citadas, pero la paginación exacta del PDF no quedó registrada).
5. **Lectura a texto completo del informe OMS 2024 (GSRAHTSUD, 334 pp.)** — NO LEÍDO; su contenido se verificó a nivel de ficha oficial (ISBN 9789240096745) y a través del artículo de métodos y resultados de Shield et al. 2025 (texto completo), que declara las funciones RR en su apéndice 1 (pp. 60–94).
6. **Evidencia latinoamericana de funciones RR propias para EIC/ACV** — NO ENCONTRADO: no existe meta-análisis regional; toda la modelación latinoamericana identificada importa las funciones internacionales.

**Discrepancias de DOI / datos bibliográficos detectadas y resueltas (regla 4):**

- **Roerecke & Rehm 2012**: rango de páginas 1246–1260 (PubMed y mayoría de fuentes) vs. 1246–1270 (una fuente secundaria). Se adopta **1246–1260**; DOI verificado: 10.1111/j.1360-0443.2012.03780.x; PMID 22229788.
- **Patra et al. 2010**: DOI verificado por EuropePMC: 10.1186/1471-2458-10-258; **PMID correcto: 20482788** (una búsqueda inicial por PMID arrojó el 20470463, que corresponde a un artículo brasileño no relacionado — descartado).
- **Castillo-Carniglia et al. 2013**: páginas verificadas **729–736** (Alcohol and Alcoholism 48(6)); DOI 10.1093/alcalc/agt066; PMID 23831731 (circulan citas con páginas distintas; se usa la verificada).
- **Ruiz-Tagle Maturana et al. 2026**: existe un corrigendum (doi:10.1016/j.puhip.2026.100812); verificar cifras finas contra la versión corregida antes de citar.
- **Informe PUC/SENDA 2018**: la cita que aparece en la "Estrategia Nacional de Drogas 2021–2030" y en documentos Dipres ("Departamento de Salud Pública - Pontificia Universidad Católica de Chile, 2018, licitación ID 662237-9-LP17") es bibliográficamente correcta, pero el enlace original de medicina.uc.cl está muerto.

---

*Nota final (regla de alto riesgo): este documento es de apoyo metodológico para investigación en salud pública; no constituye asesoría clínica ni de política pública por sí solo. Las decisiones finales de modelamiento corresponden al equipo investigador y a su comité.*
