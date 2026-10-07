# Triangulación encuesta–APC para mortalidad atribuible al alcohol en Chile: evidencia para decisiones metodológicas (FONDECYT 1240138)

**KIMI-P1 | fecha de búsqueda: 2026-10-07 | 7 fuentes a texto completo / 7 solo resumen / 6 fragmentos verificados / 5 fuentes de datos o metadatos**

Etiquetas: **[TEXTO]** = la fuente lo afirma (cita textual ≤30 palabras cuando fue posible); **[INFERENCIA]** = conclusión propia derivada de las fuentes; **ESTIMADO** = valor calculado/estimado por una fuente; **ASUMIDO** = supuesto adoptado por una fuente o por este informe (declarado). Ninguna cifra fue promediada entre fuentes discordantes: se presentan por separado.

---

## 1. Tabla de veredictos

| Decisión [ID] | Opción | Apoyo | Referencias clave | Por qué |
|---|---|---|---|---|
| D-a [V1] | **A: statu quo (media de bebedores 30d = 0,8×APC)** | **Contrario** | Rehm 2010; Sherk 2017 (guía InterMAHP); Shield 2025; GBD 2016/2019 | Las cuatro convenciones anclan el consumo **per cápita de la población total** (abstemios=0) a la fracción del APC; la media de bebedores se obtiene dividiendo por la prevalencia de bebedores, no igualándola al APC fraccionado |
| D-a [V1] | **B2: per cápita poblacional = 0,8×APC, prevalencia 12 meses** | **Fuerte** | Rehm 2010 (μ_encuesta/cobertura); Shield 2025 (factor 0,8 sobre APC, gamma por Kehoe); GBD (reescalar a agregado poblacional, ÷ %bebedores); OMS 2000 (g/día por bebedor = f(APC, % bebedores)) | Es la formulación canónica; "bebedor actual" se define como consumo en últimos 12 meses en OMS/GBD/InterMAHP |
| D-a [V1] | B1: idem con prevalencia 30 días | Débil | Buckley 2022 (reasigna abstemios 30d a categorías 12m con otra encuesta) | Ninguna convención define bebedor actual a 30 días; si el instrumento es 30d, hay que reconstruir la prevalencia 12m (Buckley 2022 lo hace con NAS 2005) |
| D-a [V1] | C: B ajustado a dominio 15–65 urbano | Débil–ninguno (convención inexistente) | GBD 2019 apéndice (fórmula de reparto por edad×sexo) | No hay estándar publicado; es factible por reparto proporcional (ver Q3) pero debe declararse como supuesto |
| D-a [V1] | D: sin escalamiento (solo sensibilidad) | Contrario | Rehm 2010; Kilian 2020; Stockwell 2018 | Coberturas típicas 30–60% → sin escalamiento las FAA se subestiman fuertemente (ej. cirrosis 55,1%→72,3% tras upshift en Rehm 2010) |
| D-b(a) | APC **total** (registrado+no registrado, ajustado turismo; SDG 3.5.2) como serie base; registrada en sensibilidad | Fuerte | OMS GHO (SA_0000001688); Shield 2025; InterMAHP guía §1.1.1/§3.3; GBD 2019 | El 0,8 se aplicó históricamente sobre APC total; Kilian 2020 usa total como base y registrada como "conservadora" |
| D-b(b) | Fracción **0,8** con sensibilidad 0,9 y 1,0 | Moderado–fuerte | Sherk 2017 §3.3 (recomendación comité técnico OMS); Stockwell 2018 (cobertura cohortes 61,7%); Shield 2025 (aplica 0,8 al APC); Rehm 2010 (sensibilidad 100/90/80%) | Origen: comité asesor técnico OMS; soporte empírico posterior: Stockwell 2018 |
| D-b(c) | Puente 15+ nacional → 15–65 urbano | Ninguno directo; [INFERENCIA] factible | GBD 2019 apéndice (reparto por Pop×%bebedores×g/día) | No existe factor estándar; reparto proporcional con pirámide y prevalencias propias |
| D-b(d) | No registrado Chile: usar estimación GHO vigente (~0,53–0,60 L), reportar legado 1,4–2,0 L y Delphi 0,05–0,5 L por separado | Moderado | OMS GHO (SA_0000001821); Agenda 2030 Chile (ficha 3.5.2, "supuesto OMS de 1,4 lts"); Cornejo 2025 | Las tres fuentes discrepan; no promediar |
| D-b(e) | 2020–2024: vintage GHO actual; congelar último valor con IC para microsimulación | Moderado | OMS GHO 2024=6,581 (IC 5,254–7,939); Banco Mundial termina 2020; OCDE llega a 2023; Manthey 2019 | Las series difieren por fuente/vintage; documentar vintage y fecha de consulta |
| D-b extra | Escalar **solo la media** gamma (σ/μ fijo); HED modelado aparte; escalamiento **antes** del tope de integración | Moderado–fuerte | Kehoe 2012 (σ/μ=1,171♂/1,258♀); Shield 2025 (HED por regresión separada); Buckley 2022 (alternativa individual: f y q ×r^(2/3), luego topes) | Convención OMS/InterMAHP/GBD escala la media; HED es input independiente |

---

## 1b. Tabla de parámetros

| ID | Parámetro/decisión | Valor/opción | Fuente (DOI + página/ecuación) | Estimado/Asumido | Transportabilidad a Chile |
|---|---|---|---|---|---|
| P1 | Cantidad anclada a 0,8×APC | Consumo **per cápita de la población** (abstemios y exbebedores = 0); media de bebedores = 0,8×APC×1000×0,793/(365×P_CD) | Rehm 2010 (doi:10.1186/1478-7954-8-3, Methods; μ_desplazada = μ_encuesta/0,529); Shield 2025 (doi:10.1016/S2468-2667(25)00174-4, Methods) | Convención (no empírico) | Alta: es la convención OMS/GBD/InterMAHP |
| P2 | Fracción del APC | 0,8 por defecto; sensibilidad 0,9 y 1,0 | Sherk 2017 §3.3 p.39-40 (drugsandalcohol.ie/28421/); Shield 2025 Methods; Rehm 2010 Discussion | Asumido (recomendación comité técnico OMS); apoyado por Stockwell 2018 (doi:10.1111/add.14392): cobertura media cohortes 61,71% | Media: el valor exacto es desconocido (lo reconoce Shield 2025); sensibilidad obligatoria |
| P3 | Serie APC | Total SDG 3.5.2, promedio 3 años, ajustado turismo | OMS GHO SA_0000001688 (consulta 2026-10-07) | Estimado OMS | Alta (indicador oficial; Chile Agenda 2030 lo usa) |
| P4 | Definición bebedor actual | ≥1 trago en últimos 12 meses | GBD 2020 (doi:10.1016/S0140-6736(22)00847-9, Methods); InterMAHP guía §2.1 (P_CD); OMS GSRAH 2018 | Convención | Alta, pero exige reconstruir 12m desde ENPG (30d): Buckley 2022 (doi:10.7895/ijadr.383) muestra cómo |
| P5 | Distribución | Gamma uniparamétrica; σ/μ = 1,171 (hombres), 1,258 (mujeres) | Kehoe 2012 (doi:10.1186/1478-7954-10-6, resumen; N=851 subpoblaciones, 66 países); GBD 2019 apéndice: "standard deviation = mean*(0.087*female + 1.171)" | Estimado (regresión internacional) | Media: derivado de encuestas GENACIS/STEPS (sin Chile); sensible a forma distributiva local |
| P6 | Tope de integración | 150 g/día (OMS/GBD); 250 g/día por defecto en InterMAHP v1.0 | Sherk 2017 §5.1 p.52; GBD 2019 apéndice (PAF integra 0–150); Rehm 2010 (150 como sensibilidad) | Asumido | Alta; declarar el tope elegido |
| P7 | Densidad etanol | 793 g/L (0,793 g/cm³) | Buckley 2022 (cita OMS 2018); OMS GSRAH 2018 Box 3.1 | Convención | Alta. **Discrepancia detectada:** su implementación usa 0,789; diferencia ~0,5% |
| P8 | No registrado Chile | 0,53–0,60 L (GHO vigente) / 1,4 L (supuesto legado MINSAL-ODEPA) / 0,05–0,5 L (Delphi) | GHO SA_0000001821; Agenda 2030 Chile ficha 3.5.2; Cornejo 2025 (doi:10.1016/j.drugpo.2025.104907, solo resumen) | Estimado (3 métodos discordantes) | Alta relevancia, baja concordancia: reportar las tres por separado |
| P9 | Cobertura encuesta/APC esperada | 30–60% encuestas hogares; ~62% cohortes epidemiológicas | Rehm 2010 (NESARC 52,9%); Kilian 2020 (doi:10.1093/alcalc/agaa048: media 36,5% Europa, 20–64 años); Stockwell 2018 (61,71%); Livingston 2015 (PMID 25486405: GF 55% vs bebida-específica 86%) | Estimado | Media: sin estimación publicada para Chile (NO ENCONTRADO) |
| P10 | HED | Modelar por separado (regresión Dirichlet/fraccional); NO escalar con 0,8 en convención OMS | Shield 2025 Methods; Manthey 2019 (doi:10.1016/S0140-6736(18)32744-2) | Convención | Alta |
| P11 | Valor congelado microsimulación | Último año GHO con IC (2024: 6,581 [5,254–7,939]) | OMS GHO (consulta 2026-10-07) | Estimado | Alta; práctica de proyección documentada: Manthey 2019 |

---

## 2. Respuestas Q1–Q9

**Q1. ¿Qué cantidad se iguala a la fracción del APC?** [TEXTO] El **consumo per cápita de la población total** (abstemios=0). Rehm 2010 define cobertura = "total volume of alcohol exposure derived from the survey divided by the adult per capita consumption" y desplaza la media de bebedores como μ/0,529, manteniendo constantes las proporciones de abstemios (doi:10.1186/1478-7954-8-3). InterMAHP: PCC 15+ único, repartido a subgrupos; la gamma integra a P_CD (guía §2.1, Fórmula 3.1). Shield 2025: "A correction factor of 0·8 was applied to APC data", separado por edad×sexo antes de modelar bebedores. GBD: "we rescaled… individual-level consumption so that they aggregated to… population-level consumption" (Griswold 2018). OMS 2000: g/día por bebedor = APC×100/(%bebedores 15+×365). **Fórmula: μ_bebedores = 0,8×APC×1000×0,793/(365×P_CD_12m).** Su statu quo subestima volúmenes en 1/P_CD. Datos faltantes de volumen: Rehm 2010 los excluyó del ajuste [TEXTO]; [INFERENCIA]: excluir de cantidades, conservar en prevalencia, declarar.

**Q2. Origen del factor 0,8.** [TEXTO] InterMAHP guía §3.3 (p.39-40): los Global Status Reports on Alcohol and Health y los estudios GBD de alcohol "have used a correction factor of 0.8… based on the recommendation of the technical advisory committee for the World Health Organization". Propósito: deflactar el PCC (registrado+no registrado) hacia el consumo capturado por los estudios epidemiológicos que generan los RR, y por alcohol vendido no consumido. Shield 2025 [TEXTO]: "to account for alcohol that was not consumed and the under-reporting… in observation studies"; "in line with… Stockwell and colleagues" (cobertura media de cohortes 61,71%, Addiction 2018, doi:10.1111/add.14392, solo resumen). Sherk 2019 (tesis UVic): el 0,8 se aplica a la **media** de la distribución. Rango: Rehm 2010 sugiere sensibilidad 100%/90%/80%; Buckley 2022 usa 0,9 (solo derrame). Se aplica sobre APC **total**.

**Q3. De 15+ nacional a 15–65 urbano.** No existe factor estándar publicado: NO ENCONTRADO (busqué "15+ to 15-64/65 adjustment per capita alcohol", guías OMS/InterMAHP/GBD). [TEXTO] La convención de reparto (GBD 2019 apéndice; InterMAHP §2.1) asigna el total a subgrupos por Población×%bebedores×g/día relativo. [INFERENCIA] El puente coherente es: APC_15-65 = APC_15+ × Σ_{15-65}(Pop×P_CD×g/día)/Σ_{15+}(Pop×P_CD×g/día), con pirámide INE y sus propias prevalencias/medias por grupo — es decir, estimar la fracción del consumo total que corresponde a 15–65. La restricción urbana (~70% población) es análoga. Ambos puentes son ASUMIDOS y deben declararse; si la cobertura de ENPG es aproximadamente constante entre grupos, el error de segundo orden es acotado (supuesto 2 de Rehm 2010: cobertura constante entre subpoblaciones [TEXTO]).

**Q4. Tasas de cobertura encuesta/APC.** [TEXTO] Internacional: NESARC EE.UU. 52,9% (Rehm 2010); Europa 39 encuestas/23 países: media 36,5% (IC95% 33,2–39,8; bebidas espirituosas 26,3%; población 20–64) (Kilian 2020); cohortes epidemiológicas: 61,71% (Stockwell 2018, solo resumen); Australia: graduated-frequency 55% vs preguntas bebida-específicas 86% (Livingston 2015, solo resumen); BRFSS EE.UU. 45%→77% tras ajuste (Buckley 2022, p.27-30). Chile/LatAm: **NO ENCONTRADO** estudio de cobertura publicado para Chile ni LatAm (busqué en español e inglés: "cobertura encuesta ventas alcohol Chile/América Latina", estudios GENACIS/OPS multicéntricos — no incluyeron Chile). [INFERENCIA] Esperar 30–60% para ENPG (encuesta hogares, graduated frequency-quantity); medirla directamente con ODEPA/OMS es factible y recomendable.

**Q5. Serie APC Chile 2010–2024 y fiabilidad del no registrado.** Ver tabla en sección 4. Tres fuentes documentadas difieren: OMS GHO vintage actual (registro 2026-06-15; consulta 2026-10-07): total 2024=6,581 L; Banco Mundial SH.ALC.PCAP.LI ("projected estimates", 15+): termina en 2020=7,56; OCDE (ventas aparentes ODEPA, 15+): 2023=6,2. Valores 2020–2024 **documentados** solo en GHO (2020=7,089…2024=6,581, promedios 3 años; 2024 parcialmente modelado); OCDE documenta 2021=7,8, 2022=6,4, 2023=6,2. Su "9,3" corresponde al indicador GHO legado SA_0000001746 (proyección vieja); su "7,56" = BM 2020; su valor 2020–2024=7,9 "sin fuente" **no coincide con ninguna fuente actual**. No registrado: GHO vigente 0,528 L (2024; IC ~0,11–1,3); legado 1,4–2,0 L (SA_0000001748 viejo; ficha Agenda 2030 Chile: "supuesto OMS de 1,4 lts"); Delphi chileno 0,05–0,5 L = 0,7–8% del APC (Cornejo 2025, solo resumen). La discrepancia OMS vs Delphi es de un orden de magnitud: declararla, no promediar.

**Q6. ¿Escalar solo la media gamma o también HED? ¿Antes o después del tope 150?** [TEXTO] Convención OMS/GBD/InterMAHP: escalar **solo la media**; σ se deriva de σ/μ fijo por sexo (Kehoe 2012: 1,171 hombres, 1,258 mujeres; GBD 2019 apéndice: sd = mean×(0,087×female+1,171)). HED es un input independiente modelado por separado (Shield 2025: regresiones Dirichlet para estatus y fraccional para HED) — el 0,8 no se aplica a prevalencias. Alternativa a nivel individual [TEXTO]: Buckley 2022 multiplica frecuencia **y** cantidad por r^(2/3) cada una y luego trunca a 30 días/mes y 200 g/día. Orden [TEXTO/INFERENCIA]: primero escalar la distribución, después aplicar el tope como límite de integración (GBD integra 0–150; Rehm 2010: 150 como sensibilidad sobre la distribución ya desplazada). Es decir: escalamiento → (forma gamma) → tope.

**Q7. ¿Cómo escalaron Kilian 2025/SIMAH y Buckley 2022?** [TEXTO] Buckley 2022 (IJADR 10(1), doi:10.7895/ijadr.383): objetivo = **per cápita poblacional** de la cohorte: r = 0,9×APC_ajustado ÷ per cápita BRFSS; f_nueva=f×r^(2/3), q_nueva=q×r^(2/3), topes 30 días/mes y 200 g/día; reasignan abstemios 30d a (vida/12m/30d) con NAS 2005; cobertura 45%→77%. Kilian 2025 (doi:10.1016/S2468-2667(25)00165-3, texto completo): microsimulación EE.UU. 18–79 años, 2000–2019; exposición = BRFSS anual; calibración bayesiana "history matching" a prevalencias ACS/BRFSS (calibración 2011–15, validación 2016–19); política implementada en 2019 vía elasticidades precio (Fogarty). **Nota de discrepancia:** el candidato se describía como estudio "tipo SIMAH" alemán; es un estudio de EE.UU. (título y DOI coinciden). Protocolo SIMAH: Probst 2023 (doi:10.1093/aje/kwad018, solo resumen). Código: zenodo 10.5281/zenodo.15641639 (v0.1.1, 2025-06-11, verificado).

**Q8. ¿Escalamiento no proporcional si la encuesta subcubre bebedores intensos?** [TEXTO] La literatura muestra subreporte **no uniforme**: Livingston 2015 (solo resumen): quienes no hacen HED subestiman proporcionalmente más (43% vs 22%); varones jóvenes 40%, mujeres de mediana edad 49%; concluye que "more robust approaches to adjusting survey data… are required". Stockwell 2018 (solo resumen): parte de la subcobertura es submuestreo de bebedores intensos. Buckley 2022 aplica sobredesplazamiento a bebedores intensos vía raíz cúbica (citando Boniface 2014). Sin embargo [INFERENCIA]: ninguna guía (OMS/InterMAHP/GBD) recomienda un escalamiento no proporcional estándar; Rehm 2010 lo asume proporcional (supuestos 1–2 declarados). Recomendación práctica: mantener escalamiento proporcional como base + análisis de sensibilidad con razón σ/μ mayor o upshift diferencial documentado.

**Q9. ¿Cómo proyectan las microsimulaciones el APC más allá del último año observado?** [TEXTO] Kilian 2025/SIMAH no proyectan más allá de lo observado: simulan 2000–2019 y la política se implementa el último año. Manthey 2019 (Lancet, doi:10.1016/S0140-6736(18)32744-2, solo resumen): pronósticos APC a 2030 con modelos multivariados (mezcla log-normal Poisson), Dirichlet para abstinencia y fraccional para HED. La OMS publicó proyecciones con valores casi congelados (indicador legado SA_0000001746: Chile 2015=9,3; 2020=9,3; 2025=9,2). [INFERENCIA] Para su microsimulación: opción defendible = congelar el último GHO (2024=6,581, con IC) y propagar incertidumbre; alternativa = ajustar tendencia tipo Manthey con las series OMS/OCDE 2010–2024. Documentar vintage, ya que el GHO retro-revisa (el viejo 9,3 vs el actual 6,9–7,2 para 2015).

---

## 3. Tabla de evidencia

| Referencia | DOI/PMID/URL | Diseño/población | Qué sostiene | Números clave (población, unidad, denominador, período; ESTIMADO/ASUMIDO) | Transportabilidad | Calidad/limitaciones |
|---|---|---|---|---|---|---|
| Rehm et al. 2010, Popul Health Metr 8:3 (texto completo) | doi:10.1186/1478-7954-8-3 | Métodos; NESARC EE.UU. 2001-02 + 851 subpoblaciones 66 países | Método canónico de upshift: μ_bebedores/cobertura; cobertura definida a nivel poblacional; sensibilidad 100/90/80% | Cobertura NESARC=0,529 (ESTIMADO); σ=1,174μ+1,003×sexo, R²=0,94 (ESTIMADO); derrame "<10%" según expertos industria (ASUMIDO citado); FAA cirrosis 55,1%→72,3% (ejemplo) | Alta (es el método que su estudio implementa) | Asume cobertura constante por sexo/edad y prevalencias de abstención correctas (declarado por los autores) |
| Kehoe et al. 2012, Popul Health Metr 10:6 (solo resumen) | doi:10.1186/1478-7954-10-6; PMID 22490226 | Métodos; 41 encuestas GENACIS/ECAS + 851 datasets 66 países | Gamma recomendada; relación σ–μ lineal | σ/μ: 1,171 (IC 1,144–1,197) hombres; 1,258 (1,223–1,293) mujeres (ESTIMADO) | Media-alta (base de OMS/GBD/InterMAHP) | Sin Chile en GENACIS/STEPS; forma distributiva autorreportada |
| Sherk et al. 2017, InterMAHP guía v1.0 (texto completo PDF) | drugsandalcohol.ie/28421/ | Guía de métodos (CISUR/CAMH) | PCC 15+ único repartido a subgrupos; correction_factor 0,8 por defecto; gamma Fórmula 3.1-3.2; tope z=250 por defecto | 0,8 ASUMIDO (comité técnico OMS, §3.3 p.39-40) | Alta (modelo InterMAHP que ustedes replican) | Documento técnico no indexado; v1.0 (2017), verificar versiones posteriores |
| Shield et al. 2025, Lancet Public Health (texto completo) | doi:10.1016/S2468-2667(25)00174-4; PMC12394792 | Modelado global 194 países, 2000-2020 (companion GSRAH 2024) | Aplican 0,8 al APC; APC separado por edad×sexo; gamma por Kehoe; Dirichlet estatus; fraccional HED; promedios 3 años; 2020 anual | "A correction factor of 0·8 was applied to APC data" [TEXTO]; APC global 2019=5,5 L (IC 4,9–6,2) (ESTIMADO) | Alta (metodología OMS vigente) | Reconocen que el nivel exacto de alcohol no consumido es desconocido |
| Shield et al. 2020, Lancet Public Health 5(1):e51-e61 (solo resumen + registro) | doi:10.1016/S2468-2667(19)30231-2; PMID 31910980 | CRA global 2000-2016 | Versión anterior de la metodología OMS; exposición desde producción/impuestos + encuestas | 3,0 millones de muertes atribuibles 2016 (ESTIMADO) | Alta | Referencia candidata del usuario: verificada (título/DOI/año coinciden) |
| GBD 2016 Alcohol Collaborators 2018, Lancet 392:1015-35 (texto completo) | doi:10.1016/S0140-6736(18)31310-2; PMC6148333 | CRA 195 países 1990-2016 | Reescalan consumo individual para agregar al nivel poblacional; ajustes turismo y no registrado | "we rescaled… so that they aggregated to… population-level consumption" [TEXTO] | Alta | Métodos 80% citados por terceros; texto del apéndice 1 no accesible íntegro |
| GBD 2020 Alcohol Collaborators 2022, Lancet 400:185-235 (fragmentos texto completo) | doi:10.1016/S0140-6736(22)00847-9 | CRA 204 países 1990-2020 | Exposición combina oferta+encuestas+administrativo; bebedor actual=12 meses | "combines supply-side data, household survey data, and administrative data" [TEXTO] | Alta | Detalles en apéndice no publicado (Bryazka, no publicado) |
| GBD 2019, apéndice métodos exposición alcohol (fragmento; reproducido en apéndice Lancet Glob Health 2021, doi:10.1016/S2214-109X(21)00164-9, mmc1) | thelancet.com/cms/10.1016/S2214-109X(21)00164-9/attachment/.../mmc1.pdf | Métodos GBD 2019 | Fórmulas exactas de reparto LPC→edad×sexo; sd=mean×(0,087×female+1,171); PAF integra 0–150; ajuste no registrado LPC/(1-%no registrado) | Fórmulas [TEXTO] (ver sección 2, Q1) | Alta | URL de anexo, no versión paginada; verificar contra apéndice oficial GBD 2019 |
| Buckley et al. 2022, IJADR 10(1) (texto completo PDF) | doi:10.7895/ijadr.383; PMC10117538 | Ajuste datos individuales BRFSS 1984-2020 (base de SIMAH) | Upshift a 90% del APC de ventas; f y q ×r^(2/3); topes 30d/200g; reasignación de abstemios 30d | Cobertura 45% (DE 4%)→77% (DE 2%) (ESTIMADO); r = 0,9×APC_aj ÷ per cápita BRFSS [TEXTO p.27-28] | Alta (misma lógica que necesitan para ENPG 30d) | La aritmética r^(2/3)×r^(2/3) sobredesplaza el volumen (r^(4/3)) antes de topes; resultado final 77%≠90% |
| Kilian et al. 2025, Lancet Public Health 10(10):e815-e823 (texto completo Europe PMC) | doi:10.1016/S2468-2667(25)00165-3; PMC12478644 | Microsimulación SIMAH EE.UU. 18-79, 2000-2019 | Exposición desde BRFSS; calibración bayesiana a prevalencias; políticas de precios por bebida | Escenario 4: +50% cerveza/espirituosas, +10% vino [TEXTO] | Media (diseño transferable; datos EE.UU.) | **No escala a APC** en esta aplicación; sin proyección post-2019 |
| Probst et al. 2023, Am J Epidemiol 192(5):690-702 (solo resumen) | doi:10.1093/aje/kwad018; PMID 36702471 | Protocolo SIMAH | Diseño: Markov SES×consumo; mortalidad causa-específica | — | Media | Resumen solamente |
| Stockwell et al. 2018, Addiction 113(12):2245-2249 (solo resumen) | doi:10.1111/add.14392; PMID 30014539 | Revisión cohortes vs APC (OMS GHO) | Base empírica del 0,8 | Cobertura media cohortes 61,71% (29,19% Rusia–96,53% Japón); EE.UU. 66,22%; Europa occ. 55,35% (ESTIMADO) | Alta (justifica 0,8) | Comunicación breve; coberturas por cohorte, no encuestas hogares |
| Livingston & Callinan 2015, J Stud Alcohol Drugs 76(1):158-164 (solo resumen) | PMID 25486405 | Comparación 2 encuestas Australia (NDSHS vs IAC) | Subreporte no uniforme: cuestiona ajuste uniforme | Cobertura 55% vs 86%; subestimación 43% (sin HED) vs 22% (HED); varones jóvenes 40% (ESTIMADO) | Media-alta para Q8 | Australia; instrumentos específicos |
| Kilian et al. 2020, Alcohol Alcohol 55(5):554-563 (texto completo) | doi:10.1093/alcalc/agaa048; PMC7427154 | 39 encuestas, 23 países europeos, 20-64 años | Coberturas y determinantes; cobertura 15+ difiere de 20-64 | Media 36,5% (33,2-39,8); espirituosas 26,3%; HED explica ~10% varianza vino/espirituosas (ESTIMADO) | Media (Europa) | Solo Europa; años heterogéneos |
| OMS 2000, International Guide for Monitoring Alcohol Consumption and Related Harm (fragmento) | iris.who.int (WHO/MSD/MSB/00.5) | Guía OMS | g/día por bebedor = APC×100/(%bebedores 15+×365) | Fórmula [TEXTO] (página no verificada) | Alta | Guía antigua; la convención sigue vigente vía GSRAH |
| OMS 2018, GSRAH 2018 (fragmentos) | who.int | Informe oficial | Densidad 0,793 (Box 3.1); bebedor actual 12m; APC total ajustado turismo | 793 g/L [TEXTO] | Alta | — |
| Manthey et al. 2019, Lancet 393:2493-2502 (solo resumen) | doi:10.1016/S0140-6736(18)32744-2 | Modelado 189 países, 1990-2017 + pronóstico 2030 | Cómo proyectar APC; Dirichlet/fraccional para estatus/HED | APC global 1990→2017; pronóstico 2030 (ESTIMADO) | Alta para Q9 | — |
| Cornejo et al. 2025, Int J Drug Policy 143:104907 (solo resumen) | doi:10.1016/j.drugpo.2025.104907; PMID 40639198 | Multi-método Chile: Delphi n=21, encuesta n=138, entrevistas n=12, análisis químico n=10 | Estimación chilena de no registrado | 0,05–0,5 L = 0,7–8% del APC; casero principal fuente (31%) (ESTIMADO) | Alta (Chile) | Solo resumen leído; rango amplio |
| Sherk 2019, tesis PhD UVic (fragmentos) | dspace.library.uvic.ca/handle/1828/10715 | Tesis (cap. 4 = guía InterMAHP) | Historia del 0,8: Stockwell 2018 → "downshift"; origen comité técnico OMS | "an adjustment factor of 0.80 should be applied… originally based on the recommendation of the technical advisory committee for the WHO" [TEXTO] | Media (secundaria) | Tesis, no revisada por pares como artículo |
| OMS GHO (datos) | ghoapi.azureedge.net; SA_0000001688/1400/1821/1404/1746/1748 | Base oficial OMS | Series APC Chile (sección 4) | Ver tabla 4 (ESTIMADO OMS) | Alta | Vintage retro-revisa; registrar fecha y código |
| Banco Mundial (datos) | data.worldbank.org/indicator/SH.ALC.PCAP.LI | Serie derivada OMS | APC total 15+ "projected estimates" | Chile 2020=7,56; termina 2020 (ESTIMADO) | Alta | "Projected": no es medición directa |
| OCDE Health Statistics (datos + doc) | sdmx.oecd.org DSD_HEALTH_LVNG@DF_HEALTH_LVNG, medida AC; doc stats.oecd.org | Ventas aparentes ODEPA, 15+ | Serie alternativa documentada | Chile 2012=8,3; 2023=6,2; fuente ODEPA (vino 12°, cerveza 5°, pisco 35°); sin no registrado ni turismo | Alta (fuente primaria chilena de ventas) | Difiere de OMS por fuente/método; no promediar |
| Chile Agenda 2030, ficha 3.5.2 (metadatos) | chileagenda2030.gob.cl | Metadatos SDG Chile | MINSAL-ODEPA usa "supuesto OMS de 1,4 lts. de consumo no registrado" | 1,4 L (ASUMIDO OMS, usado por Chile) | Alta | Ficha desactualizada (último dato 2019) |
| Zenodo SIMAH release v0.1.1 (código) | doi:10.5281/zenodo.15641639 | Repositorio código | "Kilian et al. A US microsimulation study of beverage-specific pricing policies v0.1.1" (2025-06-11) | — | Alta (reproducibilidad) | Código, no documento |

---

## 4. Evidencia chilena y latinoamericana + serie APC Chile

### 4.1 Lo que existe para Chile y la región

**(a) Chilena:** la fuente primaria de ventas es ODEPA (Ministerio de Agricultura) con datos de SAG, ACECHI, APLUS, Banco Central y Aduanas, calculada como "consumo aparente" ((stock inicial + producción + importaciones) − exportaciones)/población, con graduaciones vino 12°, cerveza 5°, pisco 35°, licores nacionales 32°, whisky e importados 40%, otros importados 20°, **sin ajuste por turismo ni no registrado propio** — Chile declara a la OCDE usar "the general estimations provided by WHO" para no registrado [TEXTO] (OCDE Health Statistics 2024, Definitions, Sources and Methods). La ficha chilena del ODS 3.5.2 documenta explícitamente "Metodología MINSAL-ODEPA en base a ventas e importaciones, usando supuesto OMS de 1,4 lts. de consumo no registrado" [TEXTO] (Agenda 2030 Chile, consulta 2026-10-07). El único estudio chileno independiente de no registrado es el multi-método de Cornejo et al. 2025 (Delphi: 0,05–0,5 L, es decir 0,7–8% del APC total; producción casera como fuente principal, 31%) [TEXTO, solo resumen]. No se encontró ningún estudio publicado de **cobertura encuesta/ventas** para Chile (NO ENCONTRADO; ver sección 8).

**(b) Latinoamericana:** el estudio multicéntrico OPS sobre Alcohol, Género, Culturas y Daño (encuestas hogares comparables 2002-2005: Argentina, Brasil, Costa Rica, México, Uruguay, EE.UU., entre 10 países) no incluyó Chile y no reporta tasas de cobertura contra ventas [TEXTO, informe OPS 2007]. PAHO reporta para las Américas consumo anual medio entre bebedores >15 L de alcohol puro [TEXTO, paho.org 2026], consistente con dividir el APC entre la prevalencia de bebedores. La evidencia de cobertura aplicable a la región es, por tanto, la internacional (sección 3, P9).

**(c) Internacional empírica y (d) convenciones de modelo:** separadas en la sección 3 (P1-P11): Rehm 2010/Stockwell 2018/Livingston 2015/Kilian 2020 son empíricas; OMS 2000/GSRAH 2018/Shield 2020-2025/InterMAHP/GBD son convenciones de modelado — estas últimas **no constituyen evidencia empírica** de que el 0,8 sea correcto para Chile, sino el estándar de comparabilidad internacional.

### 4.2 Serie APC Chile 2010–2024 (litros de alcohol puro per cápita 15+; consulta 2026-10-07)

![Series APC Chile 2010-2024](figura_APC_Chile_2010_2024.png)

| Año | OMS GHO total SDG 3.5.2 (SA_0000001688; registrado prom. 3 años + no registrado, ajustado turismo; vintage registro 2026-06-15) | OMS GHO registrado anual (SA_0000001400) | OMS GHO no registrado (SA_0000001821, prom. 3 años) | Banco Mundial SH.ALC.PCAP.LI ("total… projected estimates, 15+") | OCDE AC (ventas aparentes ODEPA, 15+) |
|---|---|---|---|---|---|
| 2010 | 7,249 | 6,607 | 0,595 | 7,79 | 7,6 |
| 2011 | — | — | — | 8,01 | 7,1 |
| 2012 | 7,206 | 6,601 | — | 7,90 | 8,3 |
| 2013 | — | — | — | 8,19 | 7,2 |
| 2014 | 7,174 | 6,553 | — | 8,04 | 7,9 |
| 2015 | 7,230 | — | — | 7,75 | 7,9 |
| 2016 | 7,226 | 6,739 | 0,569 | 7,02 | 6,4 (quiebre, flag B) |
| 2017 | — | — | — | 6,50 | 5,7 |
| 2018 | 6,983 | 6,489 | — | 6,75 | 6,3 |
| 2019 | 6,927 | — | — | 6,75 | 7,1 |
| 2020 | 7,089 | 6,384 | 0,553 | **7,56 (último)** | 6,4 |
| 2021 | 7,121 | 6,964 | — | — | 7,8 |
| 2022 | 6,986 | 6,349 | 0,534 | — | 6,4 |
| 2023 | 6,581 | 6,011 | 0,528 | — | 6,2 |
| 2024 | 6,581 (IC 5,254–7,939) | 5,804 | 0,528 | — | — |

Datos adicionales GHO: consumo **entre bebedores** (SA_0000001404, prom. 3 años): 2016=9,949 L; 2020=10,635 L (IC 7,196–14,192) — útil como chequeo de su escalamiento (media de bebedores objetivo ÷ 0,8). Vintage legado: SA_0000001746 (proyecciones): Chile 2015=9,3, 2020=9,3, 2025=9,2 — origen del "9,3" de sus notas; SA_0000001748 (no registrado, viejo): 2010=2,0 L (1,1–2,9) — origen probable del "~1,4–2,0 L".

**Advertencias de vintage:** (i) el GHO retro-revisa: el 2015 del vintage viejo (9,3) y el del actual (7,230) difieren en ~29%; fijar y citar vintage/fecha de consulta es imprescindible; (ii) los totales 2023-2024 son promedios móviles 3 años con componente modelada; (iii) OCDE difiere de OMS-registrado por fuente (ODEPA vs GHO) y método — presentar por separado, no promediar; (iv) su serie codificada 2012=8,0/2014=8,2/2016=7,1/2018=6,8 se aproxima al **Banco Mundial**, y su 2020-2024=7,9 no coincide con ninguna fuente vigente (más cercano: GHO 2015-2016 ≈ 7,2-7,3 o WB 2014 = 8,04).

---

## 5. Recomendación por decisión

**D-a [V1] — Recomendado: B2.** El consumo per cápita de la población 15–65 (o 15+) del dominio de estudio, con abstemios y exbebedores = 0, debe igualar 0,8×APC; la media de bebedores resulta de dividir por la prevalencia de bebedores de **12 meses**. Fuerza del argumento: **fuerte** — es la formulación explícita de Rehm 2010, InterMAHP, OMS (Shield 2025) y GBD; su statu quo (A) subestima los volúmenes de bebedores en 1/P_CD (≈1,7–3× según la prevalencia 12m real) y, por tanto, las FAA. Qué evidencia lo cambiaría: un documento OMS/InterMAHP que defina el ancla a nivel de bebedores (ninguno localizado). Supuesto residual a declarar: cobertura constante entre sexo×edad (supuesto 2 de Rehm 2010) y prevalencia 12m reconstruida desde ENPG 30d (método Buckley 2022).

**D-b(a) — Recomendado: APC total SDG 3.5.2 (GHO, vintage actual) como base; registrada (SA_0000001400 u OCDE-ODEPA) como sensibilidad.** Fuerza: fuerte (el 0,8 se definió sobre total; GBD/OMS ajustan turismo+no registrado). Evidencia que lo cambiaría: estimación chilena robusta de no registrado que invalide la del GHO (Cornejo 2025 va en esa dirección pero con rango 0,05–0,5 L). Residual: el componente no registrado es el eslabón más débil.

**D-b(b) — Recomendado: 0,8 como base + sensibilidad 0,9 y 1,0.** Fuerza: moderado-fuerte (convención OMS + Stockwell 2018; Rehm 2010 sugiere exactamente esa rejilla). Evidencia que lo cambiaría: publicación del estudio de cobertura de cohortes "internacional" anunciado en InterMAHP §3.3 (no localizado; posiblemente = Stockwell 2018). Residual: el 0,8 es ASUMIDO por recomendación de comité; declararlo.

**D-b(c) — Recomendado: reparto proporcional documentado** (fórmula Q3) en vez de un factor fijo; si se opta por C, declarar que no existe convención publicada. Fuerza: ninguno directo; inferencia desde GBD/InterMAHP. Residual: distribución etaria del consumo fuera de ENPG (65+, rural) tomada de relaciones internacionales.

**D-b(d) — Recomendado: usar GHO vigente (0,53–0,60 L) en el escenario base** por consistencia con la serie total SDG 3.5.2; reportar sensibilidad con Delphi (0,05–0,5 L, que implicaría APC total ≈ registrado) y con el legado 1,4 L solo como contexto histórico. Fuerza: moderada. Residual: ninguna de las tres es medición directa.

**D-b(e) — Recomendado: 2012-2024 desde GHO vintage actual; para la microsimulación congelar 2024=6,581 L (IC 5,254–7,939)** propagando el IC por Monte Carlo; alternativa documentada: tendencia tipo Manthey 2019. Evidencia que lo cambiaría: nueva edición GHO o serie ODEPA oficial anual completa. Residual: 2023-2024 incorporan promedio móvil/modelado OMS.

**Escalamiento (Q6) — Recomendado: escalar solo la media gamma (σ/μ de Kehoe 2012 fijo por sexo), sin tocar la prevalencia HED; escalamiento antes del tope de integración (150 g/día como en OMS/GBD).** Si trabajan con microdatos individuales en la microsimulación, la alternativa Buckley (f y q ×r^(2/3) + topes) es citable pero produce cobertura final ≠ objetivo (77% vs 90%): documentar la cobertura efectiva alcanzada.

---

## 6. Methods paragraphs (English)

**Paragraph 1 (exposure calibration).** Survey-derived alcohol exposure (SENDA ENPG waves 2012–2024, ages 15–65) was calibrated to World Health Organization adult (15+) per capita alcohol consumption (APC; SDG indicator 3.5.2, recorded plus unrecorded, tourist-adjusted, 3-year moving average; Global Health Observatory indicator SA_0000001688, vintage accessed 7 October 2026). Following the standard triangulation procedure (Rehm et al. 2010), the survey mean among current drinkers was divided by the survey coverage rate so that population-level per capita consumption (abstainers and former drinkers = 0) equalled 80% of APC; the 0.8 factor follows the WHO technical advisory committee recommendation implemented in the Global Status Reports on Alcohol and Health and InterMAHP (Sherk et al. 2017; Shield et al. 2025), with 90% and 100% as sensitivity analyses. Drinkers were defined as past-12-month consumers; past-30-day abstainers were reallocated to lifetime, former and current categories following Buckley et al. (2022).

**Paragraph 2 (dose–response modelling).** Among current drinkers, daily consumption was modelled with a one-parameter gamma distribution in which the standard deviation is a sex-specific linear function of the mean (σ/μ = 1.171 in men and 1.258 in women; Kehoe et al. 2012). Alcohol-attributable fractions were computed with the InterMAHP continuous–categorical formulation, integrating condition-specific relative risk functions over 0.03–150 g/day and adding the former-drinker term (Sherk et al. 2017). Heavy episodic drinking prevalence was modelled separately and not rescaled by the 0.8 factor (Shield et al. 2025). Calibration used the gamma mean before applying the integration cap. Sensitivity analyses varied the APC fraction (0.8/0.9/1.0), the unrecorded-consumption component (WHO estimate versus a Chilean Delphi estimate; Cornejo et al. 2025) and the 15+ to 15–65 bridging assumption.

---

## 7. BibTeX

```bibtex
@article{Rehm2010,
  author  = {Rehm, J{\"u}rgen and Kehoe, Tara and Gmel, Gerhard and Stinson, Frederick and Grant, Bridget and Gmel, Gerrit},
  title   = {Statistical modeling of volume of alcohol exposure for epidemiological studies of population health: the {US} example},
  journal = {Population Health Metrics},
  year    = {2010}, volume = {8}, pages = {3},
  doi     = {10.1186/1478-7954-8-3},
  url     = {https://pmc.ncbi.nlm.nih.gov/articles/PMC2841092/}
}
@article{Kehoe2012,
  author  = {Kehoe, Tara and Gmel, Gerhard and Shield, Kevin D. and Gmel, Gerrit and Rehm, J{\"u}rgen},
  title   = {Determining the best population-level alcohol consumption model and its impact on estimates of alcohol-attributable harms},
  journal = {Population Health Metrics},
  year    = {2012}, volume = {10}, pages = {6},
  doi     = {10.1186/1478-7954-10-6}
}
@techreport{Sherk2017,
  author      = {Sherk, Adam and Shield, Kevin and Rehm, J{\"u}rgen and others},
  title       = {{InterMAHP}: A comprehensive guide to the estimation of alcohol-attributable morbidity and mortality, version 1.0},
  institution = {Canadian Institute for Substance Use Research, University of Victoria},
  year        = {2017},
  url         = {https://www.drugsandalcohol.ie/28421/}
}
@article{Shield2025,
  author  = {Shield, Kevin and Franklin, Avery and Wettlaufer, Ashley and Sohi, Ivneet and others},
  title   = {National, regional, and global statistics on alcohol consumption and associated burden of disease 2000--20: a modelling study and comparative risk assessment},
  journal = {The Lancet Public Health},
  year    = {2025},
  doi     = {10.1016/S2468-2667(25)00174-4},
  url     = {https://pmc.ncbi.nlm.nih.gov/articles/PMC12394792/}
}
@article{Shield2020,
  author  = {Shield, Kevin and Manthey, Jakob and Rylett, Margaret and Probst, Charlotte and Wettlaufer, Ashley and Parry, Charles D. H. and Rehm, J{\"u}rgen},
  title   = {National, regional, and global burdens of disease from 2000 to 2016 attributable to alcohol use: a comparative risk assessment study},
  journal = {The Lancet Public Health},
  year    = {2020}, volume = {5}, number = {1}, pages = {e51--e61},
  doi     = {10.1016/S2468-2667(19)30231-2}
}
@article{GBD2016alcohol,
  author  = {{GBD 2016 Alcohol Collaborators}},
  title   = {Alcohol use and burden for 195 countries and territories, 1990--2016: a systematic analysis for the Global Burden of Disease Study 2016},
  journal = {The Lancet},
  year    = {2018}, volume = {392}, number = {10152}, pages = {1015--1035},
  doi     = {10.1016/S0140-6736(18)31310-2}
}
@article{GBD2020alcohol,
  author  = {{GBD 2020 Alcohol Collaborators}},
  title   = {Population-level risks of alcohol consumption by amount, geography, age, sex, and year: a systematic analysis for the Global Burden of Disease Study 2020},
  journal = {The Lancet},
  year    = {2022}, volume = {400}, number = {10347}, pages = {185--235},
  doi     = {10.1016/S0140-6736(22)00847-9}
}
@misc{GBD2019appendix,
  author = {{GBD 2019 Risk Factors Collaborators}},
  title  = {Supplementary appendix: alcohol exposure estimation methods (reproduced in appendix of GBD 2019 nervous system disorders analysis)},
  year   = {2021},
  doi    = {10.1016/S2214-109X(21)00164-9},
  url    = {https://www.thelancet.com/cms/10.1016/S2214-109X(21)00164-9/attachment/26ff536c-3eec-45f7-897a-183dc4e7777e/mmc1.pdf}
}
@article{Buckley2022,
  author  = {Buckley, Charlotte and Ye, Yu and Kerr, William C. and Mulia, Nina and Puka, Klajdi and Rehm, J{\"u}rgen and Probst, Charlotte},
  title   = {Improved estimates for individual and population-level alcohol use in the {United States}, 1984--2020},
  journal = {International Journal of Alcohol and Drug Research},
  year    = {2022}, volume = {10}, number = {1}, pages = {23--39},
  doi     = {10.7895/ijadr.383},
  url     = {https://pmc.ncbi.nlm.nih.gov/articles/PMC10117538/}
}
@article{Kilian2025,
  author  = {Kilian, Carolin and Buckley, Charlotte and Lemp, Julia M. and Kou, Xinyi and Kerr, William C. and Mulia, Nina and Purshouse, Robin C. and Rehm, J{\"u}rgen and Probst, Charlotte},
  title   = {Targeting alcohol use in high-risk population groups: a {US} microsimulation study of beverage-specific pricing policies},
  journal = {The Lancet Public Health},
  year    = {2025}, volume = {10}, number = {10}, pages = {e815--e823},
  doi     = {10.1016/S2468-2667(25)00165-3},
  url     = {https://pmc.ncbi.nlm.nih.gov/articles/PMC12478644/}
}
@article{Probst2023,
  author  = {Probst, Charlotte and Buckley, Charlotte and Lasserre, Aurelie M. and Kerr, William C. and Mulia, Nina and Puka, Klajdi and Purshouse, Robin C. and Ye, Yu and Rehm, J{\"u}rgen},
  title   = {Simulation of Alcohol Control Policies for Health Equity ({SIMAH}) Project: study design and first results},
  journal = {American Journal of Epidemiology},
  year    = {2023}, volume = {192}, number = {5}, pages = {690--702},
  doi     = {10.1093/aje/kwad018}
}
@article{Stockwell2018,
  author  = {Stockwell, Tim and Zhao, Jinhui and Sherk, Adam and Rehm, J{\"u}rgen and Shield, Kevin and Naimi, Timothy},
  title   = {Underestimation of alcohol consumption in cohort studies and implications for alcohol's contribution to the global burden of disease},
  journal = {Addiction},
  year    = {2018}, volume = {113}, number = {12}, pages = {2245--2249},
  doi     = {10.1111/add.14392}
}
@article{Livingston2015,
  author  = {Livingston, Michael and Callinan, Sarah},
  title   = {Underreporting in alcohol surveys: whose drinking is underestimated?},
  journal = {Journal of Studies on Alcohol and Drugs},
  year    = {2015}, volume = {76}, number = {1}, pages = {158--164},
  url     = {https://pubmed.ncbi.nlm.nih.gov/25486405/}
}
@article{Kilian2020,
  author  = {Kilian, Carolin and Manthey, Jakob and Probst, Charlotte and Brunborg, Geir S. and Bye, Elin K. and Ekholm, Ola and Kraus, Ludwig and Moskalewicz, Jacek and others},
  title   = {Why Is Per Capita Consumption Underestimated in Alcohol Surveys? Results from 39 Surveys in 23 European Countries},
  journal = {Alcohol and Alcoholism},
  year    = {2020}, volume = {55}, number = {5}, pages = {554--563},
  doi     = {10.1093/alcalc/agaa048},
  url     = {https://pmc.ncbi.nlm.nih.gov/articles/PMC7427154/}
}
@book{WHO2000guide,
  author    = {{World Health Organization}},
  title     = {International Guide for Monitoring Alcohol Consumption and Related Harm},
  publisher = {WHO},
  address   = {Geneva},
  year      = {2000},
  url       = {https://iris.who.int/handle/10665/66529}
}
@book{WHO2018GSRAH,
  author    = {{World Health Organization}},
  title     = {Global status report on alcohol and health 2018},
  publisher = {WHO},
  address   = {Geneva},
  year      = {2018},
  url       = {https://www.who.int/publications/i/item/9789241565639}
}
@article{Manthey2019,
  author  = {Manthey, Jakob and Shield, Kevin D. and Rylett, Margaret and Hasan, Omer S. M. and Probst, Charlotte and Rehm, J{\"u}rgen},
  title   = {Global alcohol exposure between 1990 and 2017 and forecasts until 2030: a modelling study},
  journal = {The Lancet},
  year    = {2019}, volume = {393}, number = {10190}, pages = {2493--2502},
  doi     = {10.1016/S0140-6736(18)32744-2}
}
@article{Cornejo2025,
  author  = {Cornejo, Cristian and Gilmore, David M. and {Mateo Pinones}, Marta and {Norambuena Cardenas}, Paula and Lachenmeier, Dirk W. and Rehm, J{\"u}rgen},
  title   = {Enhancing the estimation of unrecorded alcohol consumption in {Chile}: a multi-methods study},
  journal = {International Journal of Drug Policy},
  year    = {2025}, volume = {143}, pages = {104907},
  doi     = {10.1016/j.drugpo.2025.104907}
}
@phdthesis{Sherk2019,
  author = {Sherk, Adam},
  title  = {An Evaluation of the Alcohol Total Consumption Model and the Continued Development of InterMAHP},
  school = {University of Victoria},
  year   = {2019},
  url    = {https://dspace.library.uvic.ca/bitstream/handle/1828/10715/Sherk_Adam_PhD_2019.pdf}
}
@misc{WHOGHO2026,
  author = {{World Health Organization}},
  title  = {Global Health Observatory API: indicators SA\_0000001688, SA\_0000001400, SA\_0000001821, SA\_0000001404, SA\_0000001746, SA\_0000001748, Chile},
  year   = {2026},
  url    = {https://ghoapi.azureedge.net/api/},
  note   = {Consulta: 2026-10-07; registro de datos 2026-06-15}
}
@misc{WB2026,
  author = {{World Bank}},
  title  = {SH.ALC.PCAP.LI: Total alcohol consumption per capita (liters of pure alcohol, projected estimates, 15+)},
  year   = {2026},
  url    = {https://data.worldbank.org/indicator/SH.ALC.PCAP.LI?locations=CL},
  note   = {Consulta: 2026-10-07}
}
@misc{OECD2026,
  author = {{OECD}},
  title  = {Health Statistics: Risk factors for health (DSD\_HEALTH\_LVNG@DF\_HEALTH\_LVNG), measure AC, Chile; Definitions, Sources and Methods 2024},
  year   = {2026},
  url    = {https://www.oecd.org/en/data/indicators/alcohol-consumption.html},
  note   = {Consulta: 2026-10-07; fuente Chile: ODEPA}
}
@misc{Agenda2030Chile,
  author = {{Gobierno de Chile}},
  title  = {Indicador 3.5.2 Consumo de alcohol per c{\'a}pita (15+), Chile Agenda 2030},
  year   = {2023},
  url    = {https://www.chileagenda2030.gob.cl/indicador/3-5-2-consumo-de-alcohol-per-capita-a-partir-de-los-15-anos-de-edad-durante-un-ano-civil-en-litros-de-alcohol-puro/},
  note   = {Consulta: 2026-10-07}
}
@misc{SIMAHzenodo,
  author = {Probst, Charlotte and {SIMAH team}},
  title  = {SIMAH\_release: Kilian et al. A US microsimulation study of beverage-specific pricing policies v0.1.1},
  year   = {2025},
  doi    = {10.5281/zenodo.15641639}
}
```

---

## 8. NO ENCONTRADO / NO VERIFICADO y discrepancias de candidatos

**NO ENCONTRADO:**
1. **Tasa de cobertura encuesta/APC para Chile** (ni para otros países de LatAm contra ventas): busqué "cobertura encuesta alcohol ventas Chile", "survey coverage alcohol sales Latin America/Chile", revisé estudios multicéntricos OPS/GENACIS (Chile no incluido). Existe para Europa (36,5%, Kilian 2020), EE.UU. (52,9% NESARC; 45%→77% BRFSS), Australia (55%/86%) y cohortes globales (61,7%).
2. **Factor estándar publicado 15+ → 15–65 (o nacional → urbano)** para APC: no existe en guías OMS/InterMAHP/GBD; solo el procedimiento general de reparto proporcional.
3. **Tratamiento prescrito de bebedores con ítems de cantidad faltantes**: solo se halló la práctica de Rehm 2010 (exclusión de 298 valores faltantes de volumen en el ajuste). Ninguna guía prescribe imputación.
4. **Texto primario del "80%" en apéndices GBD 2016/2020** (pp. 18-49): el apéndice completo no fue accesible (PMC bloquea binarios; Lancet 403). Se verificó vía fuentes secundarias (Alcohol Research Forum, citando Kehoe et al.) y el resumen de Stockwell 2018 ("uplifting survey estimates to 80% of total population consumption in global burden of disease studies appears to be appropriate"). El equivalente OMS vigente (0,8 sobre APC) sí está en texto primario (Shield 2025).
5. **Estudio "internacional" de cobertura de cohortes** anunciado como en preparación en la guía InterMAHP v1.0 (2017, §3.3): probablemente publicado como Stockwell et al. 2018 (Addiction), pero no se pudo confirmar que sea el mismo estudio.
6. **Documento OMS que justifique numéricamente el 0,8** (acta del comité técnico asesor): solo referencias de segunda mano (Sherk 2017 §3.3; Sherk 2019).

**NO VERIFICADO / discrepancias en candidatos propuestos:**
- **Kilian 2025**: el candidato lo describía como estudio "tipo SIMAH" (contexto alemán implícito); el artículo verificado (DOI coincide) es una **microsimulación de EE.UU.** (18-79 años, 2000-2019, precios por bebida). Título, DOI y autores coinciden con lo propuesto.
- **SIMAH release 0.1.1 (zenodo 10.5281/zenodo.15641639)**: verificado; título real: "SIMAH_release: Kilian et al. A US microsimulation study of beverage-specific pricing policies v0.1.1" (2025-06-11).
- **Kehoe 2012 (PMC3352241)**: verificado (Popul Health Metr 2012;10:6, doi:10.1186/1478-7954-10-6). Leído solo el resumen.
- **Shield 2020 (10.1016/S2468-2667(19)30231-2)**: verificado (Lancet Public Health 5(1):e51-e61). Ojo: existe una versión **más reciente** con datos 2000-2020 (Shield et al. 2025, doi:10.1016/S2468-2667(25)00174-4) que es la que enuncia explícitamente el factor 0,8; recomiendo citar ambas y priorizar la 2025.
- **OMS GSRAH 2018, Box 3.1**: densidad 0,793 g/cm³ (citado igualmente por Buckley 2022 como "793 g/L (WHO, 2018)"). **Su implementación usa 0,789**: discrepancia menor (~0,5%), pero conviene alinearse con la convención OMS citada.
- **"OMS unrecorded Chile ~1,4 L"**: corresponde a vintages **antiguos** (GHO SA_0000001748: 2,0 L en 2010, vintage viejo; ficha Agenda 2030 Chile: "supuesto OMS de 1,4 lts"). El vintage **vigente** (SA_0000001821, consulta 2026-10-07) estima **0,53-0,60 L**. Cornejo 2025 (Delphi): 0,05-0,5 L. Tres cifras discordantes presentadas por separado.
- **"APC Chile 9,3"**: vintage viejo GHO (SA_0000001746, proyección); vintage actual 2015-2016 ≈ 7,2-7,23.
- **Banco Mundial SH.ALC.PCAP.LI**: "projected estimates"; la serie **termina en 2020** (7,56) — no usar para 2021-2024.
- **Buckley 2022, r^(2/3)**: tal como está publicado, f y q × r^(2/3) implican volumen × r^(4/3) antes de los topes; la cobertura final alcanzada (77%) quedó bajo el objetivo (90%). Citar con esa advertencia aritmética.
- **Apéndice Kilian 2025 (pp. 3-22, protocolo ODD)**: referenciado en el texto completo leído; el PDF del apéndice no fue descargado por separado (Lancet bloquea acceso directo).

---

*Contenido con fines exclusivamente metodológicos e informativos para el proyecto FONDECYT 1240138; no constituye asesoría profesional en salud pública.*
