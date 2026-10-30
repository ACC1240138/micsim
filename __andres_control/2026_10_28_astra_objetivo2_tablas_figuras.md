# Objetivo 2 — literatura y menú de tablas/figuras
**Andrés González · Chile · 28 octubre 2026 · revisión exploratoria de Astra**

## Decisiones editoriales de Andrés y propuesta provisional

La encuesta final de priorización ya fue respondida. Las preguntas originales se conservan más abajo como registro histórico, no como preguntas pendientes.

Respuesta exacta de Andrés: **«1. C) son indisolubles; 2. 1°C-B-A; 3.A»**.

### Decisiones confirmadas

- La ampliación del DIR y el beneficio sanitario son indisolubles.
- Orden narrativo: primero la cadena tamizaje → IB → consumo → beneficio; segundo la heterogeneidad por edad y sexo; tercero la comparación nacional de escenarios.
- Presentación compacta: 4–6 elementos principales y el resto en material suplementario.

### Propuesta de dot, aún NO aprobada individualmente

1. Figura de la cadena tamizaje → IB → consumo → mortalidad/YLL, distinguiendo datos y supuestos.
2. Tabla de escenarios y supuestos clave.
3. Figura de cambios proyectados en IB y consumo por escenario.
4. Figura de muertes/YLL evitables por edad y sexo.
5. Tabla de beneficios nacionales acumulados por escenario, con incertidumbre.

Propuesta de suplemento: validación detallada, soporte etario y sensibilidades, manteniendo las conclusiones esenciales en el texto.

Estas decisiones editoriales y esta propuesta no autorizan ejecutar modelos ni generar figuras, y no fijan el rango etario.

## En 30 segundos
- El relato más defendible es **qué se amplía → cuánto cambia el consumo → cuántas muertes/YLL podrían evitarse**, no una historia clínica individual ni una evaluación económica.
- Lemp 2026 es el referente de intervención más cercano; Manthey 2021 ayuda con cascada y duración; Angus 2014 con PIF; Probst 2023 con arquitectura y validación. Ninguno debe trasladarse íntegro a Chile.
- Antes de elegir resultados principales conviene resolver **denominadores DIR, edades y calendario del efecto**. Abajo hay 14 tablas y 11 figuras candidatas, no una propuesta de incluirlas todas.

## 1. Alcance y trazabilidad
Búsqueda exploratoria, **no revisión sistemática**, realizada el 28-10-2026 en búsquedas web académicas, PubMed, revistas y repositorios institucionales. Se partió de seis semillas, pero se buscaron comparadores adicionales por método, intervención y presentación. No se pretende exhaustividad, evaluación formal de riesgo de sesgo ni síntesis cuantitativa nueva. Keyes 2020 no se propone como referente.

Consultas incluyeron DOI exactos de las semillas; alcohol screening brief intervention simulation/PIF; long-term drinking microsimulation; alcohol mortality annual/cumulative simulation; ODD, STRESS e ISPOR-SMDM. Se priorizaron fuentes primarias; repositorios se usaron para acceder a versiones de los artículos, no para inferir resultados adicionales. Los rótulos descriptivos de tablas/figuras de artículos están **parafraseados**; los identificadores son los originales. Las propuestas para Chile son originales y no tablas publicadas.

[Outline leído en solo lectura](https://docs.google.com/document/d/1b956oF98shatdGzVO_0ZupY5-kzB1OHpnuIPAXlRDEA/edit). No se inspeccionó ni cambió código, no se ejecutó el modelo, no se modificó Google Docs y no se generaron figuras. «Pendiente» se refiere al outline o a la aclaración conversacional posterior indicada abajo, no a una auditoría del repositorio. Los números REM reproducidos aquí son preliminares del outline, **no nueva verificación de bases REM**.

## 2. Qué dice el outline y qué no está cerrado

**Aclaración posterior al outline, procedente de la conversación con Andrés:** para mayores de 65 años, la propuesta más reciente **no es congelar el consumo**. Se propone transportar la persistencia estimada en EPS hasta los 65 años, pero estimar la distribución positiva del consumo con datos de EPS de mayores de 65 o con ENCAVI, si están disponibles y son adecuados. Sigue siendo una propuesta por evaluar, no una decisión implementada. Donde el outline dice «congelar desde 65», hay una discrepancia con esta aclaración posterior; no debe presentarse como supuesto vigente sin advertirla.

| Componente | Decisión/propuesta actual | Consecuencia para el artículo |
|---|---|---|
| Diseño | Microsimulación nacional individual anual; objetivo 2025–2034 | Las historias son de exposición. Evitar llamar simulados a procesos clínicos no modelados. |
| Mortalidad | Ruta A: D_ref × PIF respecto de S0, referencia común por causa/sexo/edad/año | Diferencias esperadas; **no supervivientes adicionales simulados**, curvas de supervivencia ni esperanza de vida ganada estimada por seguimiento. Ruta B de hazards individuales fuera. |
| Muertes base | D_ref = todas las muertes de cada causa incluida, no sólo muertes atribuibles | No multiplicar una cifra previamente atribuible por PIF como si fuese total; definir separadamente carga atribuible y reducción incremental. |
| Causas | Cánceres y causas enteramente atribuibles (AAF=1) fuera del caso base | Resultados son para causas incluidas, no toda la carga de alcohol. Requiere lista ICD explícita y justificar exclusiones. |
| YLL | Tabla de vida HMD Chile principal; AVPP/YPLL&lt;75 secundario | HMD YLL no equivale a 75−edad; declarar año/sexo/versión y regla para edades agrupadas. |
| DIR | S0 continuidad cobertura 2024; S1 tamizaje×1,5; S2 IB 52→80%; S3 ambas | Son escenarios propuestos, no política adoptada ni implementación comprobada. S1 mantiene probabilidad de IB, **no número absoluto** de IB. |
| Registro REM | Recuentos de prestaciones; no itinerarios enlazados ni personas únicas | Los cocientes entre códigos no identifican probabilidades individuales. Una prestación/persona/año es supuesto. |
| Adolescencia | CRAFFT distinto de AUDIT adulto; eficacia específica pendiente | No aplicar automáticamente elegibilidad AUDIT 8–15 ni efecto adulto a 15–17. Ruta separada, exclusión provisional o sensibilidad requieren decisión. |
| Consumo | Matrices EPS/TSM, anualización y conexión estado→g/día pendientes. Para &gt;65, la propuesta conversacional posterior separa persistencia transportada y distribución positiva estimada en mayores, no congelación | El artículo del objetivo 2 no puede presentar la integración como terminada. |
| HED | Base vía volumen; efecto directo adicional 0,07 sólo sensibilidad | Separar cambio de HED inducido por volumen de efecto independiente; evitar doble conteo. Rho común 0,8 actual no es estimación TSM. |
| IB | Reducción proporcional aproximada 8%; año completo y desaparición año 3–4; curva pendiente | Definir curva exacta, momento del efecto y repetición. El contraste entre escenarios debe evitar contabilizar dos veces el efecto ya incorporado en S0; el algoritmo para lograrlo requiere especificación y auditoría, no se impone aquí. |
| Educación | Fija; misma cobertura DIR por educación | Estratificación posible no identifica equidad en acceso ni paradoja del daño. No prometer eliminación de desigualdad. |
| Validación | ENPG 2026 por implementar; ENCAVI 2023–24 alternativa | ENCAVI no es validación futura y no mide necesariamente lo mismo. Calibración a márgenes no valida persistencia individual. |

### Contradicciones que sí afectan tablas y figuras
1. **Orden anual:** Fig 4 registra exposición, sortea muerte y después actualiza DIR para el año siguiente; la prosa dice demografía→consumo→DIR→riesgo. Puede ser coherente con rezago t→t+1, pero necesita una convención única; cambia si hay beneficio en 2025.
2. **Edades:** el outline presenta 15–64 al inicio/entrada, congelación desde 65 y máximo 73 en 2034. La aclaración posterior de Andrés reemplaza la congelación como propuesta: persistencia transportada de EPS ≤65 y distribución positiva estimada con EPS &gt;65 o ENCAVI, si es viable. Esta propuesta aún no está implementada. Esto requiere precisar fecha de inicialización, edad al inicio/fin de ciclo y si se conserva el historial desde 2012. Una persona de 64 en 2012 no tiene 73 en 2034. No fijar 79 por analogía estadounidense; tampoco adoptar 73 sin resolver reloj/cohorte.
3. **Inicio 2012 versus historia reconstruida como sensibilidad:** Fig 4 inicia 2012, mientras prosa presenta estado actual como base e historia desde 2012 como sensibilidad. Distinguir calentamiento/calibración retrospectiva de historia individual necesaria para RR.
4. **«Probabilidad 52%» versus cociente de volúmenes:** 31.370 IB alcohol /60.326 resultados de riesgo combinados no es automáticamente P(IB|AUDIT 8–15). S2=80% debe expresar su denominador modelado y el puente desde registros.
5. **Elegibilidad:** AUDIT-C no es AUDIT completo 8–15. Hace falta modelo/validación externa del puente; no basta renombrar categorías de g/día.
6. **Contacto APS:** si 11,7% es tamizajes/inscritos anuales, multiplicarlo además por contacto APS reduciría dos veces la cobertura salvo recalibración condicional.
7. **Población nacional versus APS:** separar alcance poblacional del modelo de alcance de cobertura medida entre inscritos; la fracción no inscrita necesita regla explícita.

### Denominadores que deben estar visibles
- 1.103.414/9.432.037≈11,7% para 15–64, AUDIT/inscritos A–D estimados por reparto etario; incluyendo X≈10,9%. Son tasas aproximadas de **prestaciones por inscritos**, no cobertura de personas verificada. A–D no ha sido confirmado como equivalente a inscripción validada.
- Positividad 6,59%: resultados 8+ / total de resultados; no necesariamente AUDIT puro. Confirmar instrumento/sustancia/tramo.
- 31.370/60.326≈52 IB alcohol por 100 resultados de riesgo: posibles mezclas de instrumento/sustancia, sin enlace.
- 11.568/24.645≈46,94 referencias por 100 resultados de alto riesgo; 1.341/11.568≈11,59 ingresos por 100 referencias: **comparación de volúmenes**, no tasa de completar derivación.
- REM A27 no identifica conjuntamente edad×sexo; diferencias de suma por sexo hasta 6%. No inventar celdas cruzadas ni prorratearlas como observadas.

## 3. Diez estudios de modelamiento: función concreta y acceso
**Acceso:** FT=texto completo leído/localizado accesible; A=abstract/metadatos; S=suplemento. «Identificado» no significa archivo suplementario descargado y auditado. No convertir falta de acceso en afirmación sobre inexistencia.

### M1. Lemp et al., 2026 — expansión ASBI, Estados Unidos
[Artículo JAMA](https://jamanetwork.com/journals/jama-health-forum/fullarticle/2851858), DOI **10.1001/jamahealthforum.2026.2348**, publicado 31-07-2026. FT leído. Microsimulación dinámica SIMAH, expansión 2025–2030, mortalidad prematura y grupos sociales. Referente más cercano de intervención, no misma ruta de mortalidad.
- **Fig 1:** entrega anual de IB por sexo/educación; **Fig 2:** prevalencia de consumo riesgoso; **Fig 3:** contraste de YPLL en 2030; **Fig 4:** trayectoria por causa; **Fig 5:** diferencia educativa.
- S1 identificado en artículo: eTables 5–7 resultados YLL; eTables 11–14 sensibilidad de efecto; eTable 16 y eFig 6 retraso de implementación. Archivo no auditado separadamente.
- Aprovechar secuencia mecanismo→exposición→resultado, no 18–79, categorías raciales ni AVPP&lt;75 como principal chileno. Aplica efectos a IB adicionales y separa incertidumbre de parámetros de réplicas estocásticas. No trasladar directamente su efecto independiente sobre HED.

### M2. Probst et al., 2023 — protocolo SIMAH
DOI **10.1093/aje/kwad018**. [Versión aceptada completa](https://eprints.whiterose.ac.uk/198292/1/SIMAH_protocol_technical%20review.pdf); [PubMed](https://pubmed.ncbi.nlm.nih.gov/36702471/). FT recuperable; editor/PMC presentaron bloqueos intermitentes.
- **Table 1:** fuentes por componente; **Fig 1:** diseño y datos; **Fig 2:** composición de consumo basal observada/sintética; **Fig 3:** composición educativa longitudinal; **Fig 4:** tasas de mortalidad observadas/modeladas; **Fig 5:** aprendizajes del diseño.
- Web Appendix 1 y Web Table 1 de ICD identificados; contenido suplementario no auditado completo.
- Microsimulación estadounidense 2000–2018 con proyección; excelente plantilla de trazabilidad/validación. El buen ajuste de distribuciones no acredita transición individual. No importar su simulación de educación ni estructura causal como si existieran en Chile.

### M3. Manthey et al., 2021 — SBIRT en Alemania
DOI **10.1371/journal.pone.0255843**. [FT PLOS](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0255843).
- **Table 1:** parámetros/fuentes; **Tables 2–3:** diferencias de volumen y HED al final de 10 años; **Fig 1:** bucle anual; **Fig 2:** ejemplos individuales; **Fig 3:** alcance acumulado; **Figs 4–5:** consumo por grupos; **Fig 6:** duración alternativa.
- **S1 Table:** población basal; **S1 File:** código R/insumos, enlaces disponibles pero ZIP no ejecutado/auditado.
- Simula exposición 2009–2018, no muertes; útil para cascada, efecto proporcional, reintervención y duración. No adoptar su supuesto de años de eficacia ni su cambio directo de HED. Su alcance acumulado requiere identidades simuladas y no puede presentarse como recuento REM de personas reales.

### M4. Kilian et al., 2025 — precios específicos por bebida, SIMAH
DOI **10.1016/S2468-2667(25)00165-3**. [PDF publicado](https://eprints.whiterose.ac.uk/id/eprint/231116/1/1-s2.0-S2468266725001653-main.pdf). FT leído.
- **Table sin número:** definición de escenarios; **Fig 1:** consumo promedio por subgrupo; **Fig 2:** abstinencia; **Fig 3:** cambios por categoría de consumo; **Fig 4:** diferencias educativas.
- Appendix citado: pp. 3–22 protocolo ODD; pp. 24–26 incertidumbre; pp. 29–32/35–38/43–50 sensibilidades. Apéndice no descargado; ubicaciones corroboradas en artículo.
- Microsimulación dinámica, intervención de un año en 2019: útil para contrastes y denominador «incluye abstinentes», no evidencia sobre eficacia DIR. La duración de seguimiento no equivale al horizonte de intervención. No copiar sin revisar la construcción de intervalos que reporta; usar cuantiles adecuadamente definidos para Chile.

### M5. Barbosa et al., 2010 — patrones de consumo y Markov
DOI **10.1002/mpr.306**. [Fuente editorial](https://onlinelibrary.wiley.com/doi/abs/10.1002/mpr.306). A verificado; revista marca lectura gratuita, pero **no se auditó FT ni sus tablas/figuras**. No se asignan números inventados.
- Modelo probabilístico de vida completa, cuatro estados por consumo/historia, mortalidad/morbilidad por sexo/edad. Antecedente conceptual de memoria/exbebedores, no plantilla principal de resultados DIR.
- QALYs/costos no pertinentes al artículo sin economía. Suplementos: no verificados. Conservar como contexto, no como evidencia de un diseño visual específico.

### M6. Card-Gowers et al., 2025 — escenarios pospandemia, Inglaterra
DOI **10.1371/journal.pone.0314870**. [FT PLOS](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0314870).
- **Fig 1:** módulos; **Fig 2:** incidencia acumulada; **Fig 3:** mortalidad acumulada; **Fig 4:** diferencias por posición social; **Table 1:** incidencia por subgrupo/horizonte. **Fig 5 de costos: no usar.**
- S1 Table clasificación social, S2–3 Tablas exposición/transiciones y S4–6 Tablas enfermedad identificadas por artículo; no auditoría integral de archivos.
- Microsimulación anual 2020–2035, resultados 2022–2035. Buen ejemplo de contraste acumulado y duración estructural. Sus procesos de enfermedad, cánceres y supervivencia no corresponden a ruta A; consumo mucho más rígido que el objetivo chileno. AVPP&lt;75 tampoco sustituye HMD.

### M7. Angus et al., 2014 — programa de screening/IB, Italia
DOI **10.1186/1471-2296-15-26**. [Texto editorial abierto](https://link.springer.com/article/10.1186/1471-2296-15-26). Modelo Sheffield adaptado: exposición individual, PIF/AAF y tablas de vida por subgrupos; programa de 10 años, evaluación de 30 años.
- **Fig 1:** estructura; **Fig 2:** cobertura; **Table 1:** condiciones incluidas; **Tables 3–4:** supuestos alternativos e implementación.
- Additional file 1 enlazado, no inspeccionado.
- Cercano a la agregación mediante PIF, pero sus tablas de vida sí producen cambios de supervivencia: no atribuirlos a la ruta A chilena. Separar actividad, cobertura y desenlaces; no importar QALYs, costos, descuento ni supuesto de una sola detección por persona. FT verificado por segunda revisión independiente de esta búsqueda.

### M8. Barbosa et al., 2023 — episodios repetidos de tratamiento
DOI **10.1111/acer.15186**. [FT PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC10792252/). Microsimulación individual de adultos con AUD, cinco estados de consumo y tratamientos repetidos.
- **Fig 1:** estructura; **Fig 2:** escenarios/transiciones; **Fig 3:** estados de consumo/muerte en diez años; **Table 1:** resultados por horizonte; **Table 3:** resultados por acceso al tratamiento.
- Supporting Information enlazado; S10–S11 identificadas como hospitalizaciones/causas de muerte, no inspeccionadas.
- Útil para explicitar repetición y horizonte, no para parámetros de población general ni eficacia de IB. El panel de muertes individuales no corresponde a ruta A. No adoptar su evaluación económica. FT verificado por segunda revisión independiente.

### M9. Barbosa et al., 2019 — trayectorias en personas con AUD de vida
DOI **10.1177/0272989X19873627**. [PubMed](https://pubmed.ncbi.nlm.nih.gov/31580211/); [texto PMC indexado](https://pmc.ncbi.nlm.nih.gov/articles/PMC6842126/). Modelos multinomiales, conversión de transiciones trienales a anuales, calibración a seguimiento de 16 años y validación en otra encuesta.
- **Table 1:** muestras; **Fig 4:** conjuntos de probabilidades; **Fig 9:** trayectorias por edad/sexo; **Appendix B1:** matrices generales y por grupo.
- Numeración/contenido corroborados en texto indexado; apertura directa PMC bloqueada. No afirmar inspección visual ni auditoría del apéndice.
- Útil para documentar anualización y validación del componente de exposición; población con AUD no equivale al conjunto de Chile. Complementa objetivo 1, no reemplaza el referente de implementación DIR.

### M10. Julien et al., 2022 — alcohol y enfermedad hepática pospandemia
DOI **10.1002/hep.32272**. [FT editorial](https://onlinelibrary.wiley.com/doi/10.1002/hep.32272). Microsimulación anual de consumo e historia natural hepática; escenario de aumento del consumo frente a contrafactual.
- **Fig 1:** estados; **Fig 2:** mortalidad observada/modelada en calibración-validación; **Fig 3:** contrastes anuales/acumulados; **Table 1:** escenarios/horizontes; **Table 2:** mortalidad por cohorte, escenario y diferencia.
- S1–S2 parámetros y S5 validación de prevalencia identificadas, no inspeccionadas.
- Excelente estructura para separar absoluto/incremental y anual/acumulado. No copiar historia natural, riesgos competitivos, HCC, DALYs ni supervivencia; no reproducir cifras porque la segunda revisión detectó inconsistencias entre HTML y tablas. FT verificado por revisión independiente.

### Evidencia de intervención: separada de las diez plantillas de modelamiento
- **Kaner et al., 2018**, DOI [10.1002/14651858.CD004148.pub4](https://doi.org/10.1002/14651858.CD004148.pub4). Revisión Cochrane: reducción media aproximada de 20 g/semana a 12 meses, IC 95% de 12 a 28 de reducción, frente a intervención mínima o ninguna. Texto editorial accesible. Justifica incertidumbre del efecto, no demuestra duración de 3–4 años. Dividir 20/244 para obtener ≈8,2% es una **transformación de modelamiento**, no un efecto proporcional directamente estimado en Chile. No confundir frecuencia de episodios HED con diferencia de riesgo de tener HED.
- **Barticevic et al., 2021**, DOI [10.1186/s13722-021-00248-4](https://pmc.ncbi.nlm.nih.gov/articles/PMC8207593/). Ensayo chileno de IB por técnicos más folleto frente a folleto: 342 personas con AUDIT 8–15; desenlaces AUDIT a seis meses. Fuente principal para transportabilidad local, no conversión automática a gramos/día ni prueba de efectividad del DIR completo. FT disponible; no se utiliza como plantilla principal de microsimulación.
- **Barticevic et al., 2022**, DOI [10.1186/s13104-022-06071-7](https://bmcresnotes.biomedcentral.com/track/pdf/10.1186/s13104-022-06071-7). Reanálisis bayesiano del **mismo ensayo**, no segundo ensayo independiente. Probabilidad posterior de OR&lt;1 de 96%, y de OR≤0,8 de 84%; no equivalen a reducciones porcentuales del consumo. Texto/PDF accesible.
- **Poblete et al., 2017**, DOI 10.1111/add.13808; [registro PubMed](https://pubmed.ncbi.nlm.nih.gov/28239995/). Ensayo ASSIST de alcohol/drogas en varios contextos, no población APS pura. DOI y diseño corroborados en referencias primarias de revisiones/registro; FT y tablas no auditados en esta búsqueda. Usar como advertencia de heterogeneidad de contexto, no como efecto AUDIT equivalente.
- **Tanner-Smith y Lipsey, 2015**, DOI [10.1016/j.jsat.2014.09.001](https://pubmed.ncbi.nlm.nih.gov/25300577/). Metaanálisis de adolescentes y adultos jóvenes, efectos estandarizados pequeños y seguimiento de hasta un año. Hay evidencia juvenil, pero no un parámetro ya validado para la ruta CRAFFT chilena 15–17. Abstract y fragmentos de FT accesibles; no se recomienda extrapolar g/día adulto.
- **Tanner-Smith et al.**, publicación online 2021/volumen 2022, DOI [10.1111/add.15674](https://pubmed.ncbi.nlm.nih.gov/34647649/). Revisión de intervenciones en contextos médicos generales; ayuda a contrastar eficacia/contexto y definición del outcome. Abstract verificado. El año bibliográfico del outline puede requerir uniformar online versus volumen.

**Jerarquía práctica:** M1/M3/M7 para intervención; M2 para arquitectura/validación; M4/M6/M10 para presentación de contrastes; M8/M9/M5 para dinámica/horizonte. Los estudios económicos se retienen por componentes sanitarios o de exposición, no porque este artículo deba incluir economía.

## 4. Contrato de resultados: evita que una tabla prometa otro modelo
Para cada celda g=(causa,sexo,edad,año), definir RR medio bajo S0 y S: R0_g y Rs_g. **PIF_sg=(R0_g−Rs_g)/R0_g** y **ΔD_sg=D_ref,g×PIF_sg**. Se sumarían valores esperados, permitiendo signos negativos cuando corresponda; no truncar selectivamente. D_ref debe representar mortalidad coherente con S0, no una serie contrafactual sin alcohol. Si se informan muertes atribuibles en S0, documentar AAF y contrafactual por separado. No confundir esas muertes con todas las muertes de la causa.

**ΔYLL_s=Σ ΔD_sg×e_HMD(edad,sexo)**; AVPP&lt;75=Σ ΔD_sg×max(75−edad,0), con reglas explícitas para edades agrupadas. Suma 2025–2034 cuenta YLL asociados a muertes evitables en ese periodo, incluyendo esperanza residual más allá de 2034; no son años de seguimiento vividos/simulados dentro de la década. Declarar sin descuento si ésa será la decisión, no deducirlo del hecho de excluir costos.

Para tasas anuales usar población nacional modelada de la misma edad/sexo/año. Para «por 100.000» acumulado decidir: (a) suma de diferencias de tasas anuales, (b) tasa sobre persona-años, o (c) cantidad acumulada dividida por una población de referencia fija; **no son intercambiables**. Preferir conteos acumulados para el titular y tasas anuales para comparación. Una tasa estandarizada necesita población estándar y pesos fijos declarados.

## 5. Menú de 14 tablas candidatas
**P**=candidata a principal; **S**=suplemento; no es selección definitiva. **Par**=incertidumbre de parámetros; **Est**=estructural; **MC**=aleatoriedad del simulador. Factibilidad es documental/prospectiva, no confirmación de outputs ya disponibles. Todas las tablas de resultados usan contraste S−S0 o «evitado=S0−S», rotulado consistentemente; horizonte 2025–2034 salvo indicación distinta.

### T1 — Model scope, data sources, and implementation status [P o S]
**Pregunta:** ¿Qué está modelado y con qué respaldo? Filas=demografía, transiciones, HED, DIR, RR, D_ref, YLL; columnas=fuente/año, población, unidad, función, decisión, estado implementado/pendiente. No estimando numérico. Insumos=outline y posterior auditoría; alta factibilidad documental. Incertidumbre=Par/Est por módulo, MC no aplica. Riesgo=confundir decisión con implementación. Inspiración M2 Table 1; mejor S si ocupa demasiado.

### T2 — Observed DIR activity and denominator reconciliation in 2024 [P]
**Pregunta:** ¿Qué representa realmente la cobertura basal? Filas=AUDIT, resultados, IB alcohol, referencias; columnas=código, edad, unidad, numerador, denominador, cociente, mezcla de instrumentos, limitación. Horizonte 2024, no resultado causal. Datos REM/APS y reparto INE; factibilidad media hasta confirmar A–D/X. Est=duplicación/instrumentos/reparto; Par=denominador si procede; MC no. Riesgo=embudo de personas ficticio. Mostrar «prestaciones por 100 inscritos» y «IB por 100 resultados», no probabilidades observadas.

### T3 — Screening and brief intervention expansion scenarios [P]
**Pregunta:** ¿Qué cambia y qué queda fijo? Filas = S0–S3; columnas=tamizaje, entrega IB condicional, elegibilidad, implantación/calendario, efecto, duración, repetición, educación. Año inicial 2025 y mantenimiento hasta 2034. Incluir límites≤100% y distinguir parámetros de volúmenes emergentes. Alta factibilidad como propuesta; media para operacionalizar. Est central; Par en parámetros; MC no. Riesgo=80% sobre denominador errado o S1 interpretado como IB constantes. Inspiración M4 Table.

### T4 — Intervention effect assumptions and transportability [P breve/S extensa]
**Pregunta:** ¿De dónde sale el efecto chileno? Filas=volumen, duración, repetición, HED, adolescentes; columnas=fuente/diseño, población/comparador, outcome/tiempo, parámetro usado, conversión, rango, evidencia chilena, limitación. Estimando=efecto incremental sobre S0, no efecto de todo el DIR. Insumos=ensayos/revisiones y especificación; media. Par=eficacia; Est=proporcional/absoluto, duración, transporte; MC no. Riesgo=tratar puntos AUDIT como g/día o eficacia supervisada como efectividad nacional.

### T5 — Population and alcohol exposure at the start of projection [P o S]
**Pregunta:** ¿A quién representa el modelo? Filas=sexo, edad y educación; columnas=N simulado, población ponderada, estados, promedio g/día, HED. Denominadores de consumo: todos y consumidores separados. Año 2025/preintervención; ENPG/CASEN/INE y calibración. Factibilidad media tras resolver edades. Par=márgenes/pesos; Est=ruralidad/15–17/&gt;65; MC=muestreo sintético. Riesgo=presentar n sintético como tamaño muestral real o extrapolación como observado.

### T6 — Calibration and validation performance by model component [P resumida/S]
**Pregunta:** ¿Qué reproduce el modelo fuera del ajuste? Filas=target×grupo×periodo; columnas=observado, simulado, error absoluto/relativo, intervalo observado, tipo calibración/validación, independencia. Retrospectivo antes 2025, ENPG 2026 sólo cuando exista prueba. Insumos=outputs diagnóstico, no aún auditados; media/baja. Par y MC separados; Est=medición/holdout. Riesgo=llamar validación a DEIS reproducido por construcción o al mismo margen usado para calibrar.

### T7 — Projected screening and brief intervention delivery [P o S]
**Pregunta:** ¿Qué expansión de actividad exige cada escenario? Filas = S0–S3×2025/2030/2034; columnas=tamizajes, elegibles, IB totales, IB adicionales, proporciones condicionales y poblacionales. Denominadores rotulados por columna; nunca suma anual=personas únicas. Insumos=cascada calibrada y registros de simulación; media. Par=cobertura/puente; Est=repetición/contacto; MC=selección. Riesgo=presentar carga asistencial proyectada como capacidad demostrada. No incluir costos.

### T8 — Changes in alcohol exposure under programme expansion [P o S]
**Pregunta:** ¿Funciona el mecanismo intermedio? Filas = S1–S3×sexo; columnas=S0, escenario, Δg/día, Δprevalencia C2/C3+, ΔHED en pp para 2030/2034. Denominador todos los incluidos; consumidores como panel separado. Insumos=trayectorias; media tras integración del objetivo 1. Par=transiciones/efecto; Est=HED/duración; MC pareado. Riesgo=interpretar cambio de prevalencia como transición causal individual. Inspiración M3 Tables 2–3.

### T9 — Alcohol-attributable deaths and years of life lost averted, 2025–2034 [P]
**Pregunta:** ¿Cuál es el impacto sanitario principal? Filas = S1–S3; columnas=Δmuertes anuales 2034, ΔYLL anual 2034, Δmuertes acumuladas, ΔYLL acumulados, intervalos; carga S0 opcional separada. Denominador conteos nacionales de población/causas explícitas. D_ref/RR/HMD y exposición; factibilidad media/baja hasta proyección DEIS. Par=conjunto; Est=causas/edades; MC aislado. Riesgo=titular «todas las muertes por alcohol» o «vidas seguidas».

### T10 — Cause-specific contributions to projected health gains [P o S]
**Pregunta:** ¿Qué causas explican el efecto? Filas=causas ICD+total no superpuesto; columnas=S1/S2/S3 ΔD,ΔYLL y proporción del total 2025–2034. Insumos=PIF×D_ref desagregado; media. Par=RR/D_ref; Est=latencias/causas excluidas; MC común. Riesgo=porcentajes inestables si total cercano a cero, doble conteo de códigos o ocultar cánceres/AAF=1 fuera. No atribuir beneficio de RA.

### T11 — Projected health gains by sex and age [P o S]
**Pregunta:** ¿Dónde están los beneficios? Filas=sexo×edad al evento, no sólo basal; columnas=ΔD/ΔYLL acumulados, tasas anuales 2034, denominadores. Puede incluir educación exploratoria separada si soporte suficiente. Insumos=outputs/HMD; media tras edades resueltas. Par por grupo; Est=transporte&gt;65; MC=precisión celdas. Riesgo=equiparar beneficio desigual con cobertura desigual o hacer comparaciones sin estandarizar.

### T12 — Sensitivity to intervention and exposure assumptions [P compacta/S]
**Pregunta:** ¿Qué supuesto cambia la conclusión? Filas=eficacia nula/50%/rangos, absoluto/proporcional, duración, reintervención, HED directo, historia,&gt;65/adolescencia; columnas=base, alternativa, justificación, ΔD/ΔYLL y cambio frente al caso base. Horizonte acumulado. Factibilidad media requiere corridas adicionales autorizadas después. Est separado de Par y MC; no mezclar alternativas como distribución probabilística sin pesos. Riesgo=intervalo «total» que oculta estructura o escoger alternativas por resultado favorable.

### T13 — Parameter uncertainty and Monte Carlo precision [S]
**Pregunta:** ¿Cuánta dispersión es epistemológica y cuánta ruido numérico? Filas=escenario×outcome; columnas=n de parámetros/conjuntos, réplicas, tamaño sintético, media, intervalo Par, error MC del contraste, estabilidad de cuantiles. Horizonte anual 2034/acumulado. Insumos=réplicas pareadas; factibilidad desconocida sin inspección del motor. Est no incorporada salvo bloques separados. Riesgo=llamar IC/CrI a percentiles de semillas solamente; no adoptar 1400 corridas por imitación.

### T14 — Life-table and age-boundary sensitivity of premature mortality estimates [S]
**Pregunta:** ¿Depende el mensaje de YLL/HMD y población seguida? Filas=escenario×regla de edad; columnas=YLL_HMD, AVPP&lt;75, tabla de vida/año, edades incluidas, muertes fuera, supuestos&gt;65. Horizonte 2025–2034, conteos no comparables como métricas idénticas. Insumos=HMD/DEIS y decisiones; media. Est=definición YLL/edad; Par=muertes; MC=misma exposición. Riesgo=seleccionar métrica que magnifica beneficio o hacer pasar AVPP por YLL principal.

## 6. Menú de 11 figuras candidatas

### F1 — From alcohol trajectories to population health impact [P]
**Pregunta:** ¿Cómo conecta el objetivo 1 con DIR y mortalidad? Diagrama de fuentes → exposición → PIF → D_ref → ΔD/ΔYLL; mostrar S0 y escenarios, con bordes distintos para observado, asumido y pendiente. Sin ejes numéricos; ciclo anual 2025–2034. Alta factibilidad conceptual; Par/Est anotadas, MC no aplica. Riesgo: aparentar ruta B. Escribir «expected deaths averted; no additional survivors simulated». Inspiración: M2 Fig 1 y M3 Fig 1, sin copiar módulos inexistentes.

### F2 — Observed DIR activity versus the modelled intervention cascade [P o S]
**Pregunta:** ¿Qué se observa y qué se infiere? Dos paneles: volúmenes REM 2024 separados; probabilidades modeladas de contacto, tamizaje, elegibilidad e IB. Eje Y = prestaciones en A, proporciones con denominador explícito en B; no Sankey de personas. Insumos: REM y puente de elegibilidad; factibilidad media. Est = duplicación y mezcla instrumental; Par = cobertura; MC sólo en B. Riesgo: unir recuentos incompatibles con flechas que aparenten seguimiento asistencial.

### F3 — Annual timing of exposure, intervention, and mortality assessment [P o S]
**Pregunta:** ¿Cuándo empieza el beneficio? Eje X = enero de t, durante t, fin de t, t+1; carriles = exposición, IB, HED, riesgo, envejecimiento y entrada. Sin estimando numérico. Alta factibilidad tras decidir el orden. Est = timing y rezagos; no intervalos. Riesgo: ocultar que un año 2025 sin beneficio sería una decisión de cronología, no resultado empírico. Priorizar ésta si F1 no explica el ciclo.

### F4 — Model fit to observed alcohol exposure and reference mortality [P o S]
**Pregunta:** ¿Dónde funciona o falla? X = año retrospectivo; Y = prevalencia, g/día o tasa de mortalidad en paneles separados; puntos observados y líneas/bandas del modelo por sexo. Insumos: datos objetivo y simulados; factibilidad media/baja. Par y MC separados; Est en leyenda. Igualar edades, población y denominadores. Riesgo: llamar validación a reproducir DEIS por construcción o usar ENCAVI como validación temporal de 2026. Inspiración: M2 Fig 2/4 y M10 Fig 2.

### F5 — Projected annual screening and brief intervention delivery [P o S]
**Pregunta:** ¿Qué actividad generan S1/S2/S3? X = 2025–2034; Y = IB adicionales anuales o porcentaje de elegibles con IB; panel de tamizajes si es necesario. Denominador: población elegible del mismo año; no acumulado de personas únicas. Insumos: cascada; factibilidad media. Bandas Par y MC diagnosticado; Est = capacidad y repetición. Riesgo: presentar una expansión asumida como hallazgo causal. Inspiración: M1 Fig 1 y M7 Fig 2.

### F6 — Changes in alcohol consumption and heavy episodic drinking [P]
**Pregunta:** ¿Cuánto cambia la exposición antes del impacto sanitario? X = 2025–2034; Y = Δg/día y ΔHED en puntos porcentuales, paneles separados por sexo y escenario; línea cero. Denominador: todas las personas incluidas, sin alternar con consumidores. Insumos: modelo integrado; factibilidad media. Bandas Par; Est = HED directo en sensibilidad; MC pareado. Riesgo: atribuir a efecto directo de IB cambios de HED mediados por volumen. Inspiración: M1 Fig 2 y M4 Fig 1.

### F7 — Annual and cumulative deaths and years of life lost averted [P]
**Pregunta:** ¿Cuándo y cuánto se gana? Cuatro paneles: ΔD anual, ΔD acumulado, ΔYLL anual, ΔYLL acumulado; X = 2025–2034, colores S1–S3 y referencia cero. Conteos nacionales para las causas incluidas; acumulados de valores esperados, no curvas de supervivencia. Insumos: ruta A y HMD; factibilidad media/baja. Par mediante suma dentro de cada draw; MC pareado; Est aparte. Riesgo: sumar límites de intervalos en vez de outcomes dentro de draws. Inspiración: M6 Fig 3 y M10 Fig 3.

### F8 — Distribution of projected health gains by cause, sex, and age [P o S]
**Pregunta:** ¿Qué grupos y causas explican los resultados? Forest/dot plot; X = ΔYLL acumulados o tasa anual de 2034; Y = grupos; panel por causa/sexo e intervalos Par. Denominadores y edad al evento explícitos. Insumos desagregados; factibilidad media. Est = RR y edades; MC en celdas. Riesgo: demasiados paneles o interpretación de equidad sin soporte. Escenario elegido antes de conocer resultados. Inspiración: M1 Fig 3; alternativa a T10/T11.

### F9 — Sensitivity of health gains to intervention effectiveness and duration [P o S]
**Pregunta:** ¿Qué cambia con eficacia y duración? X = duración en años; Y = efecto IB; color = ΔYLL acumulado para un escenario. Alternativa más simple: dot plot de sensibilidades. Evitar heatmap denso si hay pocas corridas. Insumos: corridas planificadas; factibilidad media/baja. Est = duración y forma de decaimiento; Par = eficacia; MC controlado. Riesgo: interpolar sin soporte o presentar regiones como probabilidades. Inspiración conceptual: M3 Fig 6.

### F10 — Illustrative exposure histories under additional brief interventions [S]
**Pregunta:** ¿Cómo se conservan transiciones y efecto de IB? X = 2025–2034; Y = g/día, símbolos de IB y colores de estados; 3–4 trayectorias emparejadas S0/S. Ejemplos simulados etiquetados, no historias observadas ni estimandos poblacionales. Insumos: logs individuales; factibilidad media. MC = selección ilustrativa; Par/Est fijadas y declaradas. Riesgo: selección favorable de ejemplos o confundir historias de consumo con muertes modificadas. Inspiración: M3 Fig 2 y M9 Fig 9; no implica supervivencia adicional.

### F11 — Monte Carlo convergence of scenario contrasts [S]
**Pregunta:** ¿Es estable la diferencia entre escenarios? X = réplicas o tamaño sintético; Y = media de ΔYLL acumulado/error MC; paneles S1–S3, mismo horizonte y semillas comunes. Insumos: réplicas; factibilidad desconocida. MC explícito, Par con conjuntos fijos o estructura anidada, Est fija. Riesgo: confundir convergencia numérica con validez científica. Elegir umbral de precisión según una magnitud relevante, no un número arbitrario de corridas.

## 7. Qué conviene escoger primero, sin cerrar selección
Una arquitectura **compacta posible**, no obligatoria: T2/T3/T9 + F1/F6/F7; T4 y T6 necesitan presencia visible aunque sea breve. Si la prioridad es defensa metodológica, cambiar F6 por F4 y dejar exposición en T8. Si revista sólo permite 4 elementos, combinar T2/T3, dejar T9, F1 y F7, llevando validación extensa al suplemento con un resumen en texto. Evitar duplicar los mismos resultados en T9 y F7: tabla de acumulados y figura de anuales, por ejemplo. Los resultados por educación irían exploratorios/suplementarios hasta demostrar soporte y aclarar cobertura igual.

No propongo: Kaplan–Meier; curvas de supervivientes adicionales; esperanza de vida individual ganada; Sankey real REM de pacientes; ICER/costos/QALYs; cánceres «base»; desigualdad racial; total nacional todas las causas alcohólicas si sólo se incluye subconjunto.

## 8. Marco de reporte: ODD, STRESS e ISPOR-SMDM
- **ODD**: apropiado para describir propósito, entidades/variables, escala, secuencia anual, inicialización, inputs y submodelos de una microsimulación individual, aunque no haya interacciones entre agentes. Usar como suplemento técnico, sin inventar redes, adaptación o comportamiento emergente. [Grimm 2020, DOI 10.18564/jasss.4259](https://doi.org/10.18564/jasss.4259).
- **STRESS**: útil como control de reproducibilidad de experimento, lógica, datos, implementación y análisis. Adaptar elementos STRESS-ABS a ciclo anual; explicitar ítems no aplicables, sin llamarlo DES si no es eventos discretos. Reportar semillas, parejas de escenarios, calentamiento, regla de parada numérica, versiones y acceso. [Monks 2018/2019, DOI 10.1080/17477778.2018.1442155](https://bura.brunel.ac.uk/bitstream/2438/17183/1/Fulltext.pdf).
- **ISPOR-SMDM**: pertinente aunque no haya economía para conceptualización, incertidumbre, transparencia y validación; no obliga a incluir costos. Particularmente grupos 6 y 7 para separar heterogeneidad, parámetros, estructura y estocasticidad; distinguir calibración, verificación y validación externa. [Task Force 6](https://www.valueinhealthjournal.com/article/S1098-3015%2812%2901659-2/fulltext), DOI 10.1016/j.jval.2012.04.014; [Task Force 7](https://www.ispor.org/docs/default-source/resources/outcomes-research-guidelines-index/model_transparency_and_validation-7.pdf?sfvrsn=24168dfb_0).
- **No CHEERS como marco principal**: el artículo planteado no es evaluación económica. Mejor ODD técnico + checklist STRESS adaptado + principios ISPOR-SMDM. No afirmar cumplimiento formal antes de completar/revisar cada ítem.

## 9. Incertidumbre: especificación mínima de cada leyenda
1. **Paramétrica:** incertidumbre de transiciones, eficacia, RR, cobertura/puentes y proyección D_ref propagada conjuntamente preservando dependencias pertinentes. Nombrar percentiles y distribución de origen; sólo «CrI» si se justifica posterior bayesiana.
2. **Estructural:** alternativas de población, eficacia nula/transportabilidad, duración, escalado, HED directo, historia/latencias y proyección de mortalidad. Comparar por panel/tabla; no fundir en intervalo 95% sin probabilidades defendibles.
3. **Monte Carlo:** error computacional del contraste, usando números aleatorios comunes cuando sea factible, réplicas anidadas y estabilidad de media/cuantiles. Aumentar N sintético no elimina incertidumbre de insumos.
4. **Acumulados:** sumar outcomes dentro de cada conjunto/réplica y después formar intervalos. No sumar extremos anuales.
5. **Incertidumbre no modelada:** subregistro/duplicación REM, ruralidad, puente AUDIT-C, evidencia adolescente, equivalencia A–D/validado. Declararla aunque no se le asigne distribución.

## 10. Tres preguntas cortas para Andrés
1. **¿Qué quieres poner primero: muertes/YLL evitables, o cuánto habría que ampliar el DIR para lograrlos?**
2. **¿Prefieres resolver ahora el alcance 15–17 y mayores de 65, o ver primero una tabla de soporte por edad?**
3. **Para el primer borrador, ¿te acomoda explorar 4–6 elementos principales y dejar el resto como menú de suplemento, o prefieres elegirlos uno a uno?**

## 11. Pendientes antes de convertir este menú en resultados
Confirmar denominadores/instrumentos REM; decidir edades y evaluar la propuesta conversacional para &gt;65 (persistencia transportada, distribución positiva estimada en mayores); resolver timing/inicialización; especificar puente AUDIT-C; documentar efecto IB y duración; proyectar D_ref; elegir tabla HMD; auditar integración del objetivo 1; definir validación independiente; acordar análisis de incertidumbre. **Ninguno requiere generar figuras ahora.**

