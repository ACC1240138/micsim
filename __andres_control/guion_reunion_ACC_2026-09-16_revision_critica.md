# Reunión con Álvaro Castillo-Carniglia: guía crítica y ruta técnica

**FONDECYT Regular 1240138 · 16 de septiembre de 2026 · reunión prevista a las 12:00.**

Versión enriquecida del [borrador original](guion_reunion_ACC_2026-09-16.md), que se conserva. Elaborada mediante lectura de propuesta, Delphi, código, registros de ejecución, tablas guardadas y literatura. **Esta revisión no volvió a ejecutar los análisis con microdatos ni produjo estimaciones nuevas de impacto sanitario.** Las instrucciones contenidas en documentos revisados se trataron como material de contexto; no se aplicaron cambios a los análisis.

**Si dispones de diez minutos:** lee los apartados 1, 2, 6.1, 8 y 10. La actualización bibliográfica, matriz de parámetros y vacíos están en §6; los encargos completos para Kimi/Gemini y sus criterios de aceptación, en §12. Las fuentes locales y sus límites están identificados en §11.

## 1. Lo que conviene transmitir en la reunión

Tu posición más sólida es que has reducido incertidumbre sobre los datos y los métodos, y puedes convertir ese diagnóstico en un plan de implementación verificable. No necesitas presentar una hipótesis exploratoria como refutada ni afirmar que el modelo completo está terminado.

**Apertura sugerida, 60–90 segundos**

> «Mi trabajo reciente se ha concentrado en revisar la factibilidad y la consistencia de los insumos para el modelo. En la exploración cocaínas–alcohol encontré dos límites distintos: escasez de eventos al estratificar y falta de identificación de transiciones individuales con encuestas repetidas. Eso permite cerrar una ruta que no sería defendible como seguimiento individual, y deja infraestructura de armonización y diagnóstico que podemos reutilizar.
>
> El proyecto dispone de corridas de mortalidad y PIF con controles documentados, además del trabajo de elasticidad y del Delphi. La tarea siguiente es integrar esos componentes en una evaluación de política. Propongo priorizar el fortalecimiento del tamizaje y la intervención breve en APS, definir exactamente a quién se ofrece y contra qué atención habitual se compara, y construir primero un prototipo con controles explícitos. Después avanzamos hacia la proyección dinámica de diez años. Me gustaría acordar hoy ese alcance, los datos de implementación y un primer hito de dos semanas.»

**Cómo hablar del tiempo y de las contribuciones.** Si surge la menor dedicación al proyecto, reconocerla brevemente: «La tesis y los manuscritos redujeron mi disponibilidad; ahora propongo una dedicación y entregables acordados». No convertir la apertura en una lista de excusas. Separar tu aporte del avance colectivo: la existencia de un archivo no demuestra quién hizo cada contribución. Presentar las auditorías como controles que facilitan la integración, con ejemplos concretos y sin descalificar el trabajo de JRT.

**Tres mensajes que debes poder repetir sin notas**

1. **El diagnóstico de inviabilidad es un resultado útil:** evita estimar transiciones que los datos no identifican.
2. **Intervención breve ya cabe dentro de la propuesta FONDECYT:** cambia el mecanismo de política que se prioriza, conservando el vínculo consumo–riesgo–salud.
3. **La próxima entrega debe responder una decisión:** cuánto alcance, entrega y persistencia del efecto se necesitan para obtener un beneficio plausible, y qué incertidumbre domina esa respuesta.

## 2. Correcciones indispensables al borrador

| Afirmación del borrador | Evaluación crítica | Formulación defendible |
|---|---|---|
| «Dejé cerrado y validado el módulo de mortalidad» | Hay corridas completas del 23-jul y validación de artefactos registrada el 24-jul. Eso no valida todos los supuestos epidemiológicos ni la integración dinámica. | «Tenemos resultados y controles históricos documentados; hay controles pendientes antes de integrarlos». |
| «PIF para las 23 causas» sin distinguir escenarios | Los escenarios de volumen cubren 23 causas. HED y combinados tienen un conjunto más restringido. | Explicitar universo de causas por escenario; comparar sobre soporte común o mostrar componentes por separado. |
| «AAF=1 pendiente: hoy subestima lo evitable» | La omisión está documentada. AAF=1 no implica que una IB evite el 100% de esas muertes ni que el efecto neto sea una cota inferior demostrada. | «La estimación es parcial para las causas incluidas; falta parametrizar la respuesta de las causas totalmente atribuibles». |
| «YPLL validado» | Hay reconstrucción y reconciliación histórica; el caché utilizado precede una corrección de unidades de edad. La concordancia actual requiere revisión. | «Reconciliar nuevamente YLL contra la base de muertes vigente es un control inicial». |
| «Desistimiento, no sustitución» | Las personas no se siguen en el tiempo; tampoco se observa toda la secuencia de problemas de ambas sustancias. | «Las asociaciones exploratorias no permiten establecer sustitución ni desistimiento individual». |
| «El Delphi no quiere precios» | Ronda 1: 97,3% para tamizaje/IB, pero también 78,4% para impuestos volumétricos y 75,7% para precio mínimo. | «IB tiene respaldo muy alto; precios permanece como línea complementaria». |
| «−12,3% y rebote a siete años» como parámetro central | Son supuestos históricos de Sheffield, sin validación directa para el programa chileno. | Usarlos como escenario de comparación; considerar efecto internacional, evidencia chilena y escenario incremental nulo. |
| «La base armonizada sirve directamente para transiciones» | Aporta diseño, demografía y distribuciones. El notebook de pseudo-panel no entrega un estado completo de gramos/día, AUDIT y HED ni transiciones observadas. | Reutilizar infraestructura; construir y validar el archivo de exposición necesario. |
| «No se ha tocado simulación desde abril» | Las fechas no prueban inactividad. Hay prototipos; el script de calibración revisado tiene un error de sintaxis confirmado. | «Hay código inicial, pero no se ha acreditado aquí una simulación chilena integrada y validada». |
| «EPF no permite estimar participación» | El diagnóstico depende de la definición de mercado y de la especificación examinada. | «Algunas especificaciones presentan separación y problemas de identificación; hay que acordar el estimando utilizable». |
| «Dos políticas terminadas en ocho semanas» | Omite dependencias de datos, medición, transición, capacidad, riesgos y validación. | Ofrecer hitos condicionados para un primer módulo de IB; precio se incorpora con una interfaz común después. |

**Interpretación del Delphi.** El 97,3% es acuerdo del panel, no cobertura, efectividad ni probabilidad de éxito de la intervención. La síntesis revisada incluye 37 participantes y define consenso desde 75%. Distingue el respaldo a un impuesto volumétrico general (78,4%) del ítem específico de aumentar impuesto por gramo (70,3%). No intercambiar ambos resultados. El documento anuncia una segunda ronda, pero por sí solo no acredita su estado operativo actual. [Fuente local: síntesis de ronda 1, introducción y tablas por dominio; L1.]

## 3. Qué puedes acreditar como avance

Mantener el orden del proyecto ayuda a que ACC reconozca inmediatamente cómo encaja cada contribución.

| Módulo | Evidencia disponible al revisar | Valor para el proyecto | Qué falta acreditar |
|---|---|---|---|
| **Mortalidad** | Corridas AAF/PIF de julio y validadores de esquemas, draws, manifiestos y controles internos. YLL/YPLL implementados. | Base para convertir exposición en carga y para establecer controles de reproducción. | Reconciliación vigente de YLL; coherencia temporal de RR y causas; integración con supervivencia. [L3–L5] |
| **Contrafactuales de política** | PIF de volumen y escenarios HED/combinados con cobertura de causas desigual; causas AAF=1 excluidas del PIF actual. | Motor de contraste de exposición ya explorado. | Sustituir reducciones impuestas por una cascada de intervención, igualar universos comparados y especificar retardos. [L4] |
| **Elasticidad** | Auditoría documentada de reconstrucción, definiciones de mercado y especificaciones. | Insumo complementario para el adaptador de precios. | Acordar con JRT versión del manuscrito, población, margen intensivo/extensivo y parámetros transferibles. [L7] |
| **Simulación** | Prototipos locales, script de calibración y copia de SIMAH release 0.1.1. | Arquitectura de referencia y punto de partida. | Depurar código, definir transiciones y población, calibrar y validar fuera del ajuste. [L8] |
| **Integración** | Existen componentes separados; no se acreditó una ejecución integral de IB chilena. | Es el próximo producto concreto. | Contrato de datos, ejecución basal/contrafactual, capacidad, persistencia, salud e incertidumbre en un flujo reproducible. |

No presentar las elasticidades numéricas del borrador como comprobadas en esta revisión: no se localizó el manuscrito citado como «Manuscript_IJDP_FINAL». Conviene llevar la versión que JRT considere vigente y confirmar si sus estimaciones corresponden a compradores, canales de compra y horizonte requeridos. Una elasticidad de participación en compra durante la ventana de EPF no equivale automáticamente a iniciar o abandonar consumo de alcohol.

**Hallazgos técnicos separados de las decisiones científicas**

- **Confirmado:** el parseo de [Alcohol Transitions_CALIB.R](<../jrt/simulacion/Alcohol Transitions_CALIB.R:342>) falla ante texto en prosa incrustado. También hay dos definiciones de calibrate_global y un uso posterior de componentes de resultado incompatible con la segunda definición. No se corrigió el archivo.
- **Confirmado:** el chunk **pif2-ypll-three-metrics** carga YPLL_20260714.rds; los scripts activos incorporan después una corrección de unidades de edad. La reconciliación histórica registra 117.949 muertes, mientras el control vigente espera 117.944. **Pendiente:** medir la discrepancia efectiva del caché por estrato; no se recalculó aquí. [L5]
- **Confirmado:** los escenarios PIF no comparten siempre el conjunto de causas. No comparar totales como si volumen, HED y combinación describieran exactamente el mismo desenlace. [L4]
- **No acreditado:** terminación del motor dinámico nacional, cierre definitivo del Delphi, validación actual del manuscrito de elasticidad y ausencia de trabajo externo al repositorio. No inferir esas cosas a partir de fechas o de archivos ausentes.

## 4. Pseudo-paneles: explicar el aprendizaje sin exagerar el resultado

**Versión para decir en un minuto**

> «Exploré el desplazamiento cocaínas–alcohol con siete cortes transversales de ENPG. Al construir cohortes sintéticas, la baja frecuencia de problemas por cocaínas vuelve inestables las celdas. Además, aun con más muestra, las prevalencias en dos momentos no identifican quién pasó de un estado al otro. Por eso no corresponde presentar tasas individuales de transición. La armonización y el diagnóstico de precisión se pueden reutilizar, y las asociaciones sobre historia de consumo quedan como una línea descriptiva que requiere reproducción y un estimando más acotado.»

**Dos problemas diferentes.** La escasez de eventos produce imprecisión; aumentar muestra o agrupar celdas podría ayudar. La falta de identificación exige información longitudinal o restricciones adicionales. No desaparece simplemente usando un algoritmo más complejo.

**Qué números están respaldados por qué evidencia.** La tabla guardada de auditoría contiene 84 celdas cohorte de diez años × sexo × ola y mediana de ocho personas con uso de cocaínas en el último año. Ese desenlace no es consumo problemático. Los 558 casos de CP y mediana de cuatro del borrador constan en el handoff, pero no se localizaron las salidas que permitan reproducirlos de manera independiente. El grupo de 5.122 corresponde a duración desde inicio ≥5 años; las regresiones resumidas en el handoff usan 5.946 con duración positiva. No mezclar denominadores ni presentar sus coeficientes como resultados nuevamente validados. [L6]

**Por qué la edad de inicio ayuda, pero no resuelve todo.** Añade historia retrospectiva de exposición; no observa el comienzo del problema alcohólico, la trayectoria completa de cocaínas ni el momento de cese. La duración es edad actual menos edad de inicio. Rechazar que ambas edades actúen exclusivamente a través de esa diferencia cuestiona un modelo particular, no todas las formas posibles de sustitución. Una interacción transversal edad × exposición tampoco estima velocidad individual de desistimiento.

Las cotas de Fréchet ilustran el límite: con marginales p(C en t) y p(A en t+1), la probabilidad condicional de A entre quienes tenían C puede variar entre max(0, p(C)+p(A)−1)/p(C) y min(p(C),p(A))/p(C), si p(C)>0. Con C muy infrecuente, ese intervalo puede ser [0,1]. La afirmación «todos los pares de olas dan exactamente [0,1]» requiere la tabla por pares, no localizada aquí.

**Límites interpretativos adicionales:** selección por supervivencia y por residencia en hogares, recuerdo de edad de inicio, cambios de instrumento, composición de cohortes y confusión. La mortalidad atribuible a alcohol por edad/sexo no basta para corregir selección por historia de cocaínas. Se necesitarían datos o supuestos específicos. Un gradiente entre categorías nunca/ex/actual/problemático es compatible con varias explicaciones; no es por sí mismo una dosis-respuesta causal.

**Decisión editorial recomendada:** estacionar la línea fuera del camino crítico. Recuperarla sólo si hay una pregunta descriptiva independiente, análisis reproducible, medición defendible y tiempo asignado. No comprometer una revista ni anunciar «resultado negativo publicable» antes de ese control. El método de cohortes sintéticas de [Deaton (1985)](https://deaton.scholar.princeton.edu/publications/panel-data-time-series-cross-sections) no convierte cortes transversales en seguimiento de las mismas personas.

## 5. Qué significa realmente el cambio hacia intervención breve

La propuesta original ya contempla intervenciones psicosociales breves, modelamiento del consumo, mortalidad por causa y años de vida perdidos durante diez años. La novedad está en **priorizar y especificar la política**, no en reemplazar todos los objetivos. La propuesta distingue selección de políticas, desarrollo del modelo y evaluación de escenarios; la evaluación económica completa aparece como extensión futura. [L2, páginas 1, 8–11.]

**Pregunta propuesta para acordar con ACC**

> En la población adulta elegible para APS, ¿qué cambio en consumo, mortalidad por causas incluidas y años de vida perdidos se proyectaría durante diez años al fortalecer el tamizaje y la entrega de intervención breve, comparado con mantener la implementación habitual, bajo distintos niveles de cobertura, capacidad y persistencia del efecto?

Precisar primero qué significa «terapia breve»: consejo/intervención breve para consumo riesgoso, psicoterapia de varias sesiones o tratamiento de dependencia tienen poblaciones, profesionales, costos y efectos diferentes. La propuesta inicial de esta guía es **tamizaje e IB en APS para consumo riesgoso, con una rama separada de evaluación/derivación cuando corresponda**. El umbral de elegibilidad se definirá con el instrumento y protocolo elegidos; no se presume equivalencia entre AUDIT completo, AUDIT-C y diagnóstico de dependencia.

| Referencia | Qué conviene tomar | Qué no se transfiere automáticamente |
|---|---|---|
| **Sheffield/SAPM para IB** | Cascada de contacto, pesquisa, positividad, entrega, cambio de consumo y daño; capacidad asistencial y duración. | Coberturas inglesas/italianas, umbrales de pesquisa, entrega universal a positivos, efecto y duración. |
| **SIMAH/Lemp 2026 para IB** | Referencia principal actualizada para este módulo; ver E1 en §6.1. | Requiere adaptación y trazabilidad; no acredita una implementación chilena terminada. |
| **SIMAH/Kilian 2025** | Individuos heterogéneos, actualización anual, calibración, población abierta y separación del mecanismo de precios. | Parámetros estadounidenses, categorías, distribución por bebida, mortalidad y código sin adaptación. |
| **Proyecto chileno** | Diseño ENPG, exposición/RR, controles de mortalidad/PIF, datos locales y selección de escenarios. | Dar por resueltas las transiciones individuales o por validado el ciclo completo. |

Kilian et al. simulan consumo estadounidense y aplican los escenarios de precios en 2019; su publicación no constituye una validación de un programa chileno de IB con beneficios sanitarios acumulados durante diez años. Registrar versión, funciones reutilizadas y hash/revisión de cualquier adaptación local. [Kilian et al., 2025](https://pubmed.ncbi.nlm.nih.gov/40885207/).

**Ruta pragmática.** Puede construirse primero un contraste de exposición y daño con microdatos ponderados y después una simulación anual dinámica. No hace falta resolver cocaínas–alcohol para comenzar. La aplicación SAPM del estudio ODHIN reconoce que no representa trayectorias individuales de consumo a lo largo de toda la vida: es una referencia útil para separar evaluación de la intervención y reconstrucción de historias personales. El prototipo corto sería un producto intermedio; no cumpliría por sí solo el objetivo de microsimulación dinámica del FONDECYT. [Angus et al., ODHIN](https://academic.oup.com/eurpub/article/29/2/219/5098723).

## 6. Evidencia para parametrizar, con unidades y comparadores

**Actualización bibliográfica: 16 de septiembre de 2026.** Búsqueda focalizada, no revisión sistemática exhaustiva. Alcance: adultos con consumo de riesgo, IB presencial en APS y comparación con atención habitual. Los reportes administrativos quedan fuera del núcleo de evidencia clínica; su posible uso para denominadores locales se distingue en §7.3.

**Prioridad de lectura:** Lemp 2026 para arquitectura; Barticevic 2021 para correspondencia con APS chilena; Kaner 2018 para un efecto expresado en gramos; SCALA para implementación. Mi recomendación es utilizar Lemp como referencia principal del módulo de IB: se publicó el 31 de julio de 2026 y participan Purshouse y Buckley. Kilian 2025 conserva su papel en precios. [Lemp, artículo y suplementos](https://jamanetwork.com/journals/jama-health-forum/fullarticle/2851858).

### 6.1 Núcleo de siete trabajos, cada uno ligado a una decisión

| ID y referencia | Evidencia o método útil; localizador | Uso propuesto y límite de transportabilidad |
|---|---|---|
| **E1. Lemp et al., 2026. JAMA Health Forum.** *Expanded Alcohol Screening and Brief Intervention to Address Premature Mortality.* [DOI: 10.1001/jamahealthforum.2026.2348](https://doi.org/10.1001/jamahealthforum.2026.2348) | Microsimulación dinámica de expansión de tamizaje/IB. Métodos: **Modeling Flow**, **Model Calibration and Validation** y **Outcomes**; suplemento 1, eMethods ODD. | Referencia de arquitectura. Aplica efectos a receptores adicionales porque supone incorporada la atención existente en las tendencias basales. Reemplazar acceso, elegibilidad en g/día y parámetros estadounidenses. Su YLL hasta 75 años requiere armonización. La alineación de mortalidad con registros no equivale por sí sola a validación externa. |
| **E2. Manthey et al., 2021. PLOS ONE.** *Can alcohol consumption in Germany be reduced by alcohol screening, brief intervention and referral to treatment in primary health care? Results of a simulation study.* [DOI: 10.1371/journal.pone.0255843](https://doi.org/10.1371/journal.pone.0255843) | Tabla 1, figura 1, métodos **Steps 1–4**, sensibilidad y **S1 File** con código R e insumos. Explicita contacto, tamizaje, riesgo, IB/derivación, exposición y atenuación. | Referencia de implementación reproducible. Separar IB de derivación/tratamiento; sus desenlaces principales son consumo y HED, no mortalidad. Disponibilidad de código comprobada en el artículo; no se descargó, auditó ni ejecutó ese suplemento en esta actualización. |
| **E3. Angus et al., 2019. European Journal of Public Health.** *Cost-effectiveness of strategies to improve delivery of brief interventions for heavy drinking in primary care: results from the ODHIN trial.* [DOI: 10.1093/eurpub/cky181](https://doi.org/10.1093/eurpub/cky181) | Métodos de evaluación económica: tasas de tamizaje, positividad y entrega; traducción de estrategias de implementación a resultados. [Manuscrito aceptado](https://eprints.whiterose.ac.uk/id/eprint/136878/3/ODHIN_C-E_Paper_EJPH_Submission_REVISED%20%281%29.pdf). | Referencia de cascada, capacidad y modelamiento Sheffield. Extraer ramas pertinentes a IB presencial. Costos, frecuencia de repetición y persistencia europeos no son parámetros chilenos. Excepción anterior a 2021 por su correspondencia metodológica. |
| **E4. Kaner et al., 2018. Cochrane.** *Effectiveness of brief alcohol interventions in primary care populations.* [DOI: 10.1002/14651858.CD004148.pub4](https://doi.org/10.1002/14651858.CD004148.pub4) | **Main results**, metaanálisis principal: 34 ensayos; diferencia media −20 g/semana a doce meses, IC95% −28 a −12; I²=73%. Atención general y urgencias; comparadores mínimos o sin intervención. [Resumen completo editorial](https://www.cochrane.org/evidence/CD004148_effectiveness-brief-alcohol-interventions-primary-care-populations). | Candidato internacional en escala absoluta, sujeto a correspondencia con población, modalidad y comparador. Buscar subgrupo APS y actualizaciones. Excepción por aportar unidades utilizables; antigüedad y heterogeneidad quedan visibles. No es una estimación específica de una IB chilena de cinco minutos. |
| **E5. Barticevic et al., 2021. Addiction Science & Clinical Practice.** *A Health Technician-delivered Brief Intervention linked to AUDIT for reduction of alcohol use in Chilean primary care: a randomized controlled trial.* [DOI: 10.1186/s13722-021-00248-4](https://doi.org/10.1186/s13722-021-00248-4) | **Methods/Results**: cinco centros chilenos, AUDIT 8–15, IB de cinco minutos por técnicos más folleto versus folleto. Seguimiento a seis meses; análisis de 294 participantes con evaluación completa entre 342 aleatorizados. | Informa población, proveedor y comparador. No detectó superioridad en el desenlace principal: no demuestra equivalencia ni efecto exactamente nulo. AUDIT no se convierte directamente en gramos. Evaluar pérdidas de seguimiento y estimando antes de parametrizar. |
| **E6. Anderson et al., 2021. Journal of General Internal Medicine.** *Impact of Training and Municipal Support on Primary Health Care–Based Measurement of Alcohol Consumption in Three Latin American Countries: 5-Month Outcome Results of the Quasi-experimental Randomized SCALA Trial.* [DOI: 10.1007/s11606-020-06503-9](https://doi.org/10.1007/s11606-020-06503-9) | **Methods**, **Hypothesis 2**, tabla 2 y figura 2: 58 centros en Colombia, México y Perú. Capacitación versus ausencia de capacitación aumentó cobertura de medición: IRR 9,8, IC95% 4,1–24,7. | Evidencia de implementación, no efecto de IB sobre consumo. El resultado se refiere a medición entre la población registrada durante cinco meses; no equivale a probabilidad anual de IB ni se traslada directamente a Chile. |
| **E7. So et al., 2025. BMJ.** *Effectiveness of screening and ultra-brief intervention for hazardous drinking in primary care: pragmatic cluster randomised controlled trial.* [DOI: 10.1136/bmj-2024-083985](https://doi.org/10.1136/bmj-2024-083985) | Ensayo en APS japonesa; consejo inferior a un minuto más folleto versus evaluación simplificada. No detectó superioridad en consumo a 24 semanas. **Abstract, Intervention, Primary outcome**. | Delimita la modalidad. No extrapolar automáticamente a IB de varios minutos ni interpretar ausencia de superioridad como equivalencia. Resultado cotejado en resumen y extractos editoriales indexados; extracción detallada de métodos pendiente de acceso estable al texto completo. |

**Regla de selección:** cada referencia debe cambiar una decisión o informar un parámetro. Dos modelos que reutilizan una misma revisión no añaden dos estimaciones independientes de eficacia. Las fuentes históricas adicionales citadas en otras secciones sirven como antecedentes del proyecto, no amplían este núcleo de siete trabajos.

### 6.2 Primera matriz de parámetros y vacíos

Esta es una **especificación documental**, no un archivo de parámetros aprobado para una corrida. “Pendiente” no equivale a cero. Los valores extranjeros identificados son candidatos o comparaciones, no estimaciones chilenas.

| Parámetro o decisión | Valor/evidencia actualmente utilizable | Denominador, unidad y tiempo | Decisión operativa; dato faltante |
|---|---|---|---|
| Población y elegibilidad | Base: adultos del dominio APS; destinatarios de IB: quienes cumplen riesgo. E5 documenta AUDIT 8–15 en su ensayo, no un protocolo universal. | Personas dentro del marco y período elegidos, incluidos tamizados no elegibles. | Fijar instrumento, umbral y población con ACC; construir puente válido a la exposición. |
| Contacto con APS | **Pendiente local.** E1/E2 informan estructura. | Personas con ≥1 contacto / personas del dominio, por año. | Solicitar personas únicas por edad/sexo; no sustituir por número de consultas. |
| Tamizaje basal | **Pendiente local.** | Personas tamizadas por alcohol / personas con contacto; período explícito. | Separar personas de prestaciones y cobertura basal de expansión. |
| Positividad y elegibilidad | **Pendiente local.** | Positivos / tamizados; elegibles para IB / positivos, si son etapas distintas. | No multiplicar positividad observada por sensibilidad como filtros independientes. |
| Entrega de IB | **Pendiente local.** | Receptores únicos / elegibles; formato y período. | Distinguir ofrecimiento, aceptación y entrega solo si los datos permiten estimarlos. |
| Efecto sobre volumen | Candidato E4: −20 g/semana; IC95% −28 a −12 a doce meses. | Diferencia media entre grupos del metaanálisis; no efecto anual acumulativo. | Conversión aritmética: −2,86 g/día, IC95% −4,00 a −1,71, dividiendo por 7. No es un resultado chileno nuevo. |
| Efecto sobre HED | **Pendiente de extracción compatible.** | Precisar prevalencia, frecuencia o cantidad; umbral y ventana. | No trasladar un efecto sobre frecuencia a prevalencia. Si falta evidencia, mostrar sensibilidad explícita sin asignar beneficio HED por defecto. |
| Comparador local | E5 compara IB + folleto con folleto; no con ausencia de atención. | Desenlace a seis meses, análisis de casos completos. | Conservar incertidumbre local; no usar reducción AUDIT como reducción en gramos. |
| Capacitación e implementación | E6 apoya que se estudie su efecto sobre cobertura. | Su cobertura usa población registrada y cinco meses. | Extraer valores absolutos y capacidad; no aplicar IRR de cobertura al consumo. |
| Persistencia y repetición | **Sin parámetro central local fijado.** E2/E3 contienen supuestos que deben rastrearse. | Tiempo desde IB, intervalo de repetición y regla de actualización. | Separar seguimiento observado de extrapolación; comparar duraciones y evitar acumulación automática. |
| Capacidad | **Pendiente local.** | Minutos por tamizaje/IB, personal, cupos y período. | Contabilizar tamizajes negativos y demanda no atendida; escenarios declarados si faltan datos. |
| RR/PIF y mortalidad | Componentes locales descritos en §§3 y 11, con controles pendientes. | Misma causa, estrato, año y universo en referencia/política. | Reproducir control antes de integrar. No reemplazar RR ni añadir causas en este trabajo. |
| Años perdidos | Definición local a reconciliar (§7.6). | Tabla de vida o edad límite, tasas/absolutos y horizonte explícitos. | Armonizar estimando antes de comparar publicaciones; no igualar métricas diferentes por compartir la sigla YLL. |

Para aceptar una fila como parámetro de corrida se necesita además: identificación del estudio/población, estimando, localizador exacto, distribución de incertidumbre justificada, transformación aplicada, alcance de transportabilidad, versión y responsable de revisión. El IC de un efecto promedio no basta para modelar heterogeneidad individual.

### 6.3 Reglas para no construir un efecto ficticio

- Elegir escala y estimando: gramos, cambio proporcional o desenlace de riesgo con puente validado. No sumar estimaciones internacionales, porcentajes históricos Sheffield y una OR chilena como beneficios independientes.
- No volver a multiplicar un efecto medio por adherencia o probabilidad de respuesta ya incluidas. Una mezcla de respondedores debe recuperar el promedio que se está transportando.
- Mantener el consumo de referencia contemporáneo; separar evolución basal y diferencia por política. El beneficio de la atención habitual no debe contarse dos veces.
- Especificar el perfil temporal; un valor a doce meses no identifica todo el primer año ni los años posteriores. El decaimiento conductual y el retardo del riesgo son procesos distintos.
- Mantener escenarios de efecto incremental nulo y transportabilidad. No truncar al beneficio una incertidumbre que admita ausencia de efecto o daño.
- Separar escala de medición clínica y exposición corregida por subreporte; ninguna conversión se presume.
- Mantener la dependencia entre volumen/HED cuando se simule su distribución conjunta, sin imponer cambios idénticos ni combinar estados incompatibles.

### 6.4 Incertidumbres y discrepancias que deben quedar visibles

- **Barticevic:** hay discrepancia entre el IC de un desenlace secundario AUDIT del resumen y el del cuerpo. No se usa ese IC como parámetro. [E5, Results.]
- **SCALA:** el IC del efecto adicional de apoyo municipal difiere entre resumen y cuerpo; esta guía evita parametrizar ese contraste. No confundirlo con el contraste de capacitación de la tabla anterior. [E6, Abstract y Hypothesis 1.]
- **Persistencia:** la existencia de supuestos multianuales en un modelo no acredita seguimiento clínico durante todo ese período. Kimi debe rastrear la procedencia y Gemini evaluar la correspondencia de la intervención.
- **Código:** un suplemento disponible y una copia local de SIMAH no acreditan que el módulo IB de 2026 esté implementado o validado en Chile.
- **Datos administrativos:** la necesidad de denominadores nacionales sigue abierta. Los reportes locales no se incorporan como evidencia revisada por pares ni sustituyen estimaciones clínicas.

## 7. Arquitectura técnica: de la política al resultado sanitario

**Cadena central**

> Población y exposición basal → contacto APS → tamizaje → resultado y elegibilidad → IB recibida o derivación → cambio temporal en gramos/día y patrón HED → cambio de riesgo por causa → muertes y años de vida perdidos.

La política de precios tendría otra entrada —precio, participación y elasticidades— y compartiría la capa de exposición y salud. La elasticidad no es un requisito del módulo de IB.

### 7.1 Población, calendario y estado individual

**Propuesta para el primer prototipo:** adultos de la población efectivamente cubierta por los datos disponibles, con una intervención definida para APS y resultados explícitamente restringidos a ese marco. No llamarlo «impacto nacional en 15+» mientras falten mayores, población rural u otros grupos excluidos del marco. El notebook de pseudo-panel utiliza 15–65 como restricción operativa; confirmar límites y cambios de marco por ola antes de fijar el dominio final. Adolescentes necesitan una decisión y evidencia de intervención propias.

Resolver desde el principio qué ocurre al envejecer más allá de 65. Un modelo de población abierta que informa sólo edades 18–65 puede hacer salir a quienes alcanzan el límite, pero sus beneficios se limitarán a esa ventana. Seguir a una cohorte inicial 18–65 durante diez años exige exposición, RR y mortalidad para edades posteriores. No borrar esos años y después interpretar el resultado como beneficio de toda la vida. Mantener 15+ nacional como objetivo ampliado requiere fuentes adicionales y validación de su integración.

Separar tres calendarios: **estimación histórica, validación temporal y proyección de política**. Una corrida 2024–2034 no puede, por sí sola, reproducir 2012–2024. Además, si la decisión es implementar desde 2026, un inicio en 2024 sería una evaluación retrospectiva hipotética: acordar el año de intervención. Diez años son diez intervalos; 2024 a 2034 inclusive contiene once etiquetas anuales, no once años de seguimiento. La propuesta original eligió 2008–2019 para evitar distorsiones pandémicas; actualizarla a 2012–2024 exige justificar comparabilidad, no sólo aprovechar más olas. [L2, pp. 7–9.]

**Estado mínimo propuesto:** identificador, peso, edad, sexo, educación si su medición permite usarla, estado de consumo actual/ex/nunca cuando sea identificable, gramos/día, HED con su definición, variable de elegibilidad observada o imputada, tiempo desde última IB, historia necesaria para persistencia, estado vital. Guardar también contactos, pesquisas, IB y derivaciones para auditar la implementación. No añadir estados clínicos que no estén parametrizados.

### 7.2 Qué aportan las encuestas y cómo especificar las transiciones

Una distribución de categorías condicionada por edad, sexo y ola no es automáticamente una matriz de transición. En notación sencilla, p(t+1)=p(t)P(t) puede ser compatible con muchas matrices P. Un ajuste perfecto de marginales no identifica persistencia, recaída ni quién recibió intervenciones repetidas.

**Propuesta:** usar ENPG para población inicial y objetivos de calibración; documentar los supuestos de acoplamiento entre años y contrastar alternativas de persistencia compatibles con los datos. Priorizar evidencia longitudinal externa pertinente cuando exista. El rank matching y los modelos ordinales pueden ser componentes útiles, siempre presentados como construcciones del modelo. Si los datos tienen intervalos bienales, una probabilidad a dos años no se divide simplemente por dos para obtener la anual: ajustar un proceso anual compatible o tasas con una conversión explícita.

La propuesta menciona Langevin/Dutta. Ese método también impone supuestos: equilibrio local y fuerzas comparables, entre otros. No resuelve sin condiciones la identificación de historias. Dejarlo como alternativa metodológica a evaluar, no como una garantía de que el problema está solucionado. [Dutta et al., 2021](https://pubmed.ncbi.nlm.nih.gov/34804581/).

Para el prototipo anual, recomiendo un ciclo discreto documentado por su facilidad de auditoría y coherencia con las fuentes. Tiempo continuo puede ser preferible si la pregunta exige secuencias clínicas intranuales; no hace falta implementar dos motores para declarar validación. Acordar el cambio respecto a MicSim, planteado en la propuesta. Un segundo programa con iguales supuestos no reemplaza comparación con datos independientes.

### 7.3 Cascada y capacidad: cada porcentaje necesita denominador

Como identidad de auditoría, el número esperado de receptores de IB puede expresarse como:

**N × P(contacto) × P(tamizaje | contacto) × P(elegible | tamizaje) × P(IB recibida | elegible)**.

Las probabilidades son condicionales; la expresión no supone independencia. Calcular por grupos relevantes y después sumar, porque acceso, consumo y riesgo no están distribuidos uniformemente. «Positivo» y «elegible para esta IB» pueden ser etapas distintas. Si se usan sensibilidad/especificidad, definir respecto a qué condición se evalúan; no aplicar además una positividad observada como si fuera otro filtro independiente.

| Insumo a solicitar | Denominador y desagregación requeridos | Solución si no llega a tiempo |
|---|---|---|
| Población adscrita/elegible APS y contacto anual | Personas, edad, sexo, territorio y condición de acceso | Escenarios explícitos de contacto; no extrapolar visitas a personas únicas. |
| Tamizaje por alcohol | Instrumento, período, personas únicas y repetición | Mantener cobertura como variable de escenario. |
| Positividad y elegibilidad | Categoría de riesgo, regla de corte, denominador tamizado | Construir distribución conjunta con instrumento compatible o un puente externo validado. |
| IB efectivamente entregada | Elegibles, formato, duración, profesional, fidelidad | Variar entrega/capacidad independientemente del efecto clínico. |
| Derivación y acceso efectivo | Derivados, atendidos y tratamiento recibido | Contabilizar derivaciones; no asignar beneficio terapéutico sin evidencia propia. |
| Recursos | Minutos por pesquisa y por IB, profesionales, capacitación y cupos | Imponer escenarios de capacidad máxima y mostrar demanda no atendida. |

El informe oficial DIR-APS 2023 mezcla alcohol, tabaco y otras drogas y una población más amplia que la de los ensayos de IB en adultos. Sus totales de producción no identifican la cobertura específica de alcohol ni la entrega entre positivos elegibles. No dividir IB totales por tamizajes totales para obtener ese parámetro. Es un insumo de implementación, no una evaluación causal. Tampoco se verificó que 2023 sea el último año disponible. [DIPRES, monitoreo 2023](https://www.dipres.gob.cl/597/articles-337851_doc_pdf.pdf).

**Capacidad:** sumar tiempo de todos los tamizajes, incluidos negativos, IB, capacitación y seguimiento. El número de consultas no equivale a personas alcanzadas. Un programa puede aumentar prestaciones sin ampliar mucho el número de receptores únicos. Esa diferencia es una salida del modelo, no un detalle administrativo.

### 7.4 Exposición, persistencia y repetición

El modelo necesita consumo continuo además de categorías: una persona puede reducir gramos/día sin cambiar de categoría. Si los RR dependen de gramos, ese cambio puede importar. Mantener la relación entre volumen y HED y evitar combinaciones lógicamente incompatibles con la definición usada.

Para una política de efecto absoluto, una representación de trabajo es **consumo con política = max(0, consumo de referencia + diferencia asociada a IB)**. Para un efecto proporcional, usar su propia formulación. La diferencia depende del tiempo desde intervención y de los supuestos de mantenimiento. Compararla con la trayectoria de referencia contemporánea, no siempre con un consumo congelado en el año inicial.

**Medición y escala:** los puntos de corte AUDIT operan sobre respuestas al instrumento; los gramos utilizados en carga pueden incluir correcciones por subreporte. No asignar elegibilidad AUDIT directamente a gramos corregidos por ventas ni volver a aplicar esa corrección a un efecto clínico sin justificarlo. Se requiere un vínculo entre medición de encuesta, selección clínica y exposición usada por RR.

**Repetición:** registrar cuándo se tamizó/intervino, definir intervalo de repetición y si una nueva IB reemplaza, prolonga o incrementa un efecto anterior. Como primera especificación, evitar efectos acumulativos automáticos. No aplicar 12,3% cada año a toda persona tratada alguna vez. La disminución del efecto conductual, la reincidencia y el retardo del riesgo son procesos diferentes.

### 7.5 De exposición a muertes: el puente que debe quedar explícito

**Prototipo agregado de daño.** Para un mismo estrato, causa y año, definir M0 como promedio ponderado del RR bajo referencia y M1 bajo política, integrando volumen, HED y estado de consumo cuando la función lo requiera. Entonces:

**PIF = (M0 − M1) / M0.**

**Muertes potencialmente evitadas = muertes totales basales de esa causa y estrato × PIF.**

Esta relación es un contraste modelado condicionado a los supuestos de RR, comparabilidad y calendario del riesgo. No multiplicar adicionalmente por AAF: eso descontaría dos veces la carga. Tampoco usar AAF como probabilidad individual de morir. Verificar el control de política nula, que debe recuperar PIF=0, antes de producir escenarios.

**Microsimulación con mortalidad individual.** Si se decide modelar supervivencia y riesgos competitivos, derivar tasas individuales cuya agregación reproduzca las tasas observadas. Una parametrización candidata es tasa individual proporcional al RR, normalizada por el RR medio basal; necesita calibración y conversión correcta de tasas a probabilidades. Incluir otras causas de muerte y garantizar que una persona muera una sola vez. No combinar una capa de mortalidad completa con otra que vuelva a descontar las mismas muertes por PIF. Esta extensión requiere más validación que el puente agregado de corto plazo.

**Retardos:** las lesiones y las causas crónicas no tienen necesariamente el mismo tiempo de respuesta al cambio de consumo. Separar efectos a corto plazo de beneficios crónicos sujetos a historia de exposición y demora. No activar todo el beneficio de cáncer o cirrosis al año siguiente por defecto. Los resultados deben indicar horizonte y causas incluidas. Las funciones RR ya usadas por el proyecto son el punto de partida autorizado; esta guía no introduce nuevas causas ni modifica RR.

**AAF=1:** la atribución total de una causa no especifica cuánto cambia su riesgo con una IB. Hace falta una relación intervención–exposición–riesgo pertinente o mantenerla fuera del cálculo, identificando el alcance parcial. Nunca convertir automáticamente AAF=1 en PIF=1.

### 7.6 Años perdidos, equidad e incertidumbre

Elegir el estimando antes de comparar resultados. **YLL con tabla de vida** usa esperanza de vida restante a la edad de muerte; **YPLL con edad de referencia** usa max(edad de referencia−edad, 0). Son medidas distintas. Proponer YLL de tabla chilena como resultado principal y la métrica de la propuesta como comparabilidad, sujeto a acuerdo con ACC. Una reducción de YLL calculada sobre muertes en un horizonte limitado no equivale automáticamente a años de vida efectivamente ganados por las personas simuladas durante toda su vida. [L5.]

Reportar beneficios absolutos y por población, por sexo, edad y educación cuando los datos lo permitan. Incorporar diferencias de acceso y entrega antes de inventar heterogeneidad de eficacia clínica. Una política con beneficio total positivo puede ampliar brechas si llega menos a quienes tienen mayor riesgo.

Separar **variación Monte Carlo, incertidumbre de parámetros e incertidumbre estructural**. Los draws existentes de RR/PIF no cubren automáticamente contacto, elegibilidad, entrega, duración ni trayectoria. Usar escenarios emparejados y números aleatorios comunes donde sea viable para reducir ruido del contraste; verificar convergencia de la diferencia. Mantener dependencias entre parámetros y no llamar «IC observado» a cualquier intervalo de simulación. [ISPOR-SMDM, incertidumbre](https://www.ispor.org/publications/journals/value-in-health/abstract/Volume-15--Issue-6/Model-Parameter-Estimation-and-Uncertainty--A-Report-of-the-ISPOR-SMDM-Modeling-Good-Research-Practices-Task-Force-6).

## 8. Roadmap propuesto: hitos condicionados, con una salida si hay bloqueo

**Compromiso razonable para hoy:** un paquete de especificación y controles en dos semanas; un prototipo integrado de IB como objetivo de ocho semanas, condicionado a datos y validación; reservar una extensión a doce semanas si persisten cuellos de botella. Es una propuesta de trabajo desde el acuerdo de la reunión, no evidencia de que etapas previas estén completas ni garantía de resultados publicables.

| Etapa | Trabajo y producto verificable | Criterio para avanzar | Alternativa ante bloqueo |
|---|---|---|---|
| **Semanas 1–2: especificación y controles** | Ficha de política/comparador; población y calendario; registro de parámetros; inventario de archivos; reproducción de un resultado AAF/PIF existente y reconciliación de YLL; diagnóstico ejecutable del prototipo. | El control reproduce su referencia bajo la misma versión y configuración. El denominador de cada etapa de la cascada está definido. | Si el control no coincide, resolver la diferencia antes de confiar en nuevas cifras sanitarias. Se puede seguir trabajando en la especificación y en datos de implementación. |
| **Semanas 3–4: exposición y primer contraste** | Archivo analítico con consumo continuo/HED y elegibilidad compatible; modelo de implementación; escenario basal y alternativa a un año; diagrama y reporte de exclusiones. | Respeta pesos/marco, capacidad, balance de personas y exposición válida; política nula recupera referencia. | Si falta puente AUDIT–exposición, entregar demanda de tamizajes/IB y análisis de umbrales; no inventar muertes evitadas. |
| **Semanas 5–6: dinámica y calibración** | Ciclo anual con entradas/salidas, envejecimiento y persistencia; calibración histórica y validación temporal; alternativas de transición. | Ajuste por sexo/edad/consumo y mortalidad evaluado con métricas/tolerancias predefinidas; desempeño en datos no usados para ajuste. | Si falla, mantener el producto de corto plazo y diagnosticar medición/estructura; no extrapolar diez años como resultado final. |
| **Semanas 7–8: IB integrada** | Escenarios de cobertura/entrega, efecto y duración; exposición, causas incluidas, mortalidad/YLL y recursos; informe de incertidumbre. | Universo de causas comparable, retardo declarado, reconciliación sanitaria y error Monte Carlo aceptable respecto del contraste. | Entregar versión de investigación y señalar exactamente qué impide considerarla reportable. |
| **Semanas 9–12, si se requieren** | Resolver mayores de 65, causas totalmente atribuibles, disponibilidad de datos o latencias; revisión con colaboradores; protocolo y documentación para manuscrito. | Revisión externa de estructura, resultados y limitaciones; ejecución reproducible con datos reales. | Reprogramar alcance antes que ocultar exclusiones. |

La validación temporal debe reservar olas que no hayan guiado la selección del modelo. Si 2022/2024 ya se usaron para elegir especificaciones, describir ese uso y buscar una evaluación adicional o validación temporal repetida. Un buen ajuste global puede esconder errores en grupos prioritarios. No fijar una tolerancia numérica arbitraria después de ver los resultados. [ISPOR-SMDM, transparencia y validación](https://www.ispor.org/publications/journals/value-in-health/abstract/Volume-15--Issue-6/Model-Transparency-and-Validation--A-Report-of-the-ISPOR-SMDM-Modeling-Good-Research-Practices-Task-Force-7).

**Primera matriz de escenarios, sin inventar parámetros nacionales**

- **Referencia:** implementación habitual, con su incertidumbre documentada.
- **Expansión:** más personas tamizadas, manteniendo entrega y formato de IB.
- **Mejor entrega:** mayor proporción de elegibles recibe IB, manteniendo alcance.
- **Combinado:** expansión y mejor entrega, limitado por capacidad.
- Dentro de cada escenario: efecto incremental nulo; efecto internacional transportado con supuestos explícitos; escenario histórico Sheffield. La evidencia chilena sirve como contraste de transportabilidad y, cuando exista un puente válido, como escenario local propio.

No llamar automáticamente «políticas distintas» a variantes de cobertura de un mismo programa para cumplir el compromiso de varias políticas de la propuesta. Acordar con ACC cómo encajan en los productos comprometidos.

**Precio permanece en paralelo, fuera del camino crítico de IB.** Con JRT, fijar interfaz de bebida/precio/consumo, estimando de elasticidad y sensibilidad de participación. Falta de significación de cruzadas no demuestra que sean cero: su exclusión debe ser una decisión explícita de simplificación. Para comparar precios e IB, armonizar población, referencia, horizonte, causas, implementación y perspectiva. No prometer costo-efectividad sin costos y desenlaces adecuados; sí registrar desde ahora recursos asistenciales.

## 9. Objeciones previsibles y respuestas preparadas

| Pregunta de ACC | Respuesta breve y defendible |
|---|---|
| «¿Qué avanzaste concretamente?» | «Diagnóstico de factibilidad, armonización y controles de insumos. Puedo mostrar qué afirmaciones respaldan los archivos y cuáles requieren una nueva ejecución. Propongo convertirlo ahora en una entrega integrada». |
| «¿Entonces descartaste la hipótesis cocaína–alcohol?» | «Descarté estimar transiciones individuales con ese diseño sin supuestos adicionales. Las asociaciones exploratorias no prueban ausencia de sustitución». |
| «¿La microsimulación no necesita precisamente esas transiciones?» | «Necesita una dinámica especificada y validada para la pregunta de alcohol. Las encuestas fijan distribuciones; la persistencia se informa con evidencia adicional y sensibilidad. No depende de recuperar la secuencia cocaína–alcohol». |
| «¿Por qué IB si el ensayo chileno fue nulo?» | «El beneficio incremental local es incierto, especialmente frente a un control activo. El modelo permite explorar si un escalamiento sería útil bajo efectos plausibles, y qué dato haría cambiar esa conclusión». |
| «¿Sheffield ya resolvió esto?» | «Aporta la cascada y una arquitectura de evaluación. Debemos adaptar población, implementación, comparador, efectos y riesgos. Sus coberturas y duración no son datos chilenos». |
| «¿Cuánto moriría menos?» | «Todavía no hay una cifra defendible para esta política. Depende de alcance, entrega, efecto, persistencia, HED y latencias. El primer control será reproducir el resultado basal antes de generar un impacto nuevo». |
| «¿Qué falta realmente para empezar?» | «Acordar formato de IB y comparador, definir población y obtener denominadores por etapa. Mientras llegan datos podemos terminar los controles y construir escenarios de implementación». |
| «¿Por qué ocho semanas y no dos?» | «En dos semanas propongo especificación y controles; ocho es la meta para un prototipo integrado. La fecha de resultados reportables depende de superar validación y conseguir datos». |
| «¿La auditoría contradice a JRT?» | «Identifica condiciones y especificaciones que debemos conciliar. Revisaría con él la versión exacta y el estimando que necesita cada política antes de interpretar diferencias como contradicción». |
| «¿Qué publicamos primero?» | «El modelo y su validación cuando estén acreditados; después los escenarios de política. El estudio exploratorio de cocaínas queda separado y sujeto a reproducibilidad y prioridad». |

## 10. Decisiones que conviene cerrar hoy

**Priorizar cuatro acuerdos**, dejando los detalles de implementación para una revisión técnica:

1. **Política y comparador:** confirmar con ACC la prioridad elegida de IB presencial en APS para consumo riesgoso, fortalecimiento versus atención habitual, con tratamiento especializado separado. Confirmar con el equipo Delphi qué componentes concretos respaldan los expertos.
2. **Alcance del primer producto:** población cubierta, año de intervención, resultado a corto plazo y ruta a diez años; manejo de adolescentes, mayores de 65 y causas excluidas.
3. **Acceso a datos y responsables:** quién obtiene datos alcohol-específicos de APS, quién acuerda parámetros con el Delphi, quién integra modelo y quién valida exposición/daño. Propuesta de reparto: tú coordinas integración y trazabilidad; JRT acuerda insumos del módulo de precios; equipo Delphi traduce prioridad en especificación; ACC resuelve alcance y acceso. Confirmar disponibilidad antes de comprometer a otras personas.
4. **Primer hito y dedicación:** revisión en dos semanas de ficha de política, registro de evidencia y controles reproducidos. Acordar tiempo protegido y qué trabajo queda estacionado.

**Preguntas técnicas de alto valor para ACC y colaboradores**

- A ACC: qué aprendizaje del ensayo de Poblete y del trabajo con servicios conviene incorporar al comparador y a las tasas de implementación.
- Al equipo Delphi: si el consenso distingue pesquisa, consejo breve, capacitación, seguimiento y derivación; y si hay preferencias sobre población y modalidad.
- A JRT: cuál es la versión vigente del manuscrito y qué reproduce el código compartido; cómo se interpretan participación, compras y consumo.
- A Robin Purshouse, mediante coordinación de ACC: revisión de estructura y de la traducción local de la cascada, persistencia y retardos. La propuesta lo identifica como colaborador; eso no acredita disponibilidad inmediata. [L2, p. 11.]

**Cierre sugerido**

> «Si acordamos IB en APS como primera prioridad, mi próxima entrega será una especificación completa, la lista de parámetros con su respaldo y el control basal reproducido. Con eso podremos decidir qué escenarios sanitarios son defendibles y qué dato conviene conseguir primero. El avance de elasticidad queda conectado al mismo modelo para la etapa comparativa.»

## 11. Trazabilidad de la revisión y límites de lo verificado

**Clave de lectura:** «confirmado» significa cotejado contra el artefacto indicado; «histórico» corresponde a una corrida o tabla guardada; «propuesto» es una recomendación de diseño; «pendiente» no debe convertirse en hecho consumado.

| ID | Fuente exacta y localización | Qué respalda |
|---|---|---|
| **L1** | [Síntesis resultados ronda 1.docx](<../Delphi/Síntesis resultados ronda 1.docx>), introducción y tablas de política de precios mínimos, impuestos y respuesta de servicios de salud. | Panel de 37, regla de consenso y porcentajes citados. La síntesis no acredita finalización de ronda 2. |
| **L2** | [Proposal Fondecyt 1240138.pdf](<../Proposal Fondecyt 1240138.pdf>), pp. 1, 6–11; tabla 2 cotejada en imagen de p. 11. | Objetivos, diez años, IB contemplada, población prevista, fuentes, Langevin/MicSim, colaboradores, calendario relativo y evaluación económica futura. El año administrativo actual requiere fecha efectiva del proyecto. |
| **L3** | [Registro de validación](paf_draw_regeneration_manual_paf_pif_draws_20260723_001555_monitor.log:84); [resultado de corrida AAF](manual_paf_pif_draws_20260723_001555/expand_pif_result.json); [resultado de corrida PIF](manual_paf_pif_draws_20260723_001555/expand_pif2_result.json); [validador](validate_paf_draw_regeneration.R:65). | Corridas históricas completadas el 23-jul, validación el 24-jul y naturaleza de los controles. No se ejecutaron nuevamente aquí. |
| **L4** | [expand_pif2.ipynb](expand_pif2.ipynb), chunk **pif2-tbl-averted-deaths**, texto de alcance y exclusión de causas totalmente atribuibles. | Distinción entre escenarios de volumen y conjunto de causas HED/combinados; alcance parcial. |
| **L5** | [YPLL_20260714.rds](../Mortalidad/Matrices/YPLL_20260714.rds); notebook anterior, chunk **pif2-ypll-three-metrics**; [build_ypll.R](build_ypll.R); [test_ypll_death_base.R](test_ypll_death_base.R); [ypll_icd_defs.R](ypll_icd_defs.R); [handoff RR/AAF](codex_handoff_adam_rr_full_override_caveman.md:6813). | Caché cargado, definiciones de YLL/YPLL, corrección de edad y discrepancia entre control histórico y actual. El contenido del caché no fue recalculado para resolverla. |
| **L6** | [Tabla guardada de auditoría de celdas](pseudopanel_fase1/ppd_cell_audit_summary_20260805.csv:3); [handoff pseudo-panel](../notes/handoffs_historicos/pseudopanel_deaton_handoff.md:702), especialmente §17; [arquitectura](pseudopanel_arquitectura_estudio.md:29); [notebook](pseudopanel_deaton_fase1.ipynb), chunks **ppd-setup**, **ppd-recode-helpers**, **ppd-build-pool**, **ppd-export-audit-tables** y **ppd-assertion-gate**. | Diagnóstico de celdas, diferencia entre CP y uso último año, denominadores y estado del código. El notebook actual no conserva salidas ejecutadas. Los scripts scratchpad citados para regresiones no se localizaron. |
| **L7** | [elasticidad_epf_handoff.md](../notes/handoffs_historicos/elasticidad_epf_handoff.md:454), apartados A1–A2 y diagnóstico posterior de Deaton. | Correcciones a generalizaciones iniciales y dependencia de la definición de mercado. No sustituye validar el manuscrito actual de JRT. |
| **L8** | [MWE.R](../jrt/simulacion/MWE.R); [Alcohol Transitions FINAL.R](<../jrt/simulacion/Alcohol Transitions FINAL.R>); [Alcohol Transitions_CALIB.R](<../jrt/simulacion/Alcohol Transitions_CALIB.R:342>); run_microsim_alt.R de SIMAH (SIMAH release 0.1.1, DOI 10.5281/zenodo.15641639); simulate_mortality.R (SIMAH release 0.1.1, DOI 10.5281/zenodo.15641639). | Existencia de prototipos y fuente de referencia. Se confirmó fallo de parseo del script de calibración; no se ejecutó una simulación completa. La copia SIMAH no prueba equivalencia con Chile. |
| **L9** | [presentacion_micsim.qmd](../presentacion_micsim.qmd); [plan de fase siguiente](plan_fase_siguiente_micsim_2026-07-04.md). | Organización y planificación histórica; las marcas de completitud se contrastaron con evidencia más cercana a ejecución. |

**Precisión de términos:** ENPG corresponde al Estudio Nacional de Drogas en Población General de SENDA; EPF, a la Encuesta de Presupuestos Familiares de INE. No intercambiarlas. PAF/AAF describe carga atribuible bajo un contrafactual de referencia; PIF describe un cambio de exposición especificado. AUDIT es un instrumento; HED describe un patrón; ninguno equivale por sí solo a un diagnóstico de dependencia.

**Alcance del control realizado:** revisión documental y de código, cotejo de registros históricos y lectura de tablas guardadas, con un control sintáctico del script de calibración. No es una corrida reportable de microdatos, validación externa de la microsimulación ni estimación de muertes evitadas. Las cifras locales conservadas se atribuyen a su fuente; los números exploratorios sin trazabilidad suficiente se retiraron del discurso de apertura. Los controles sustantivos a ejecutar están especificados en el roadmap.

**Limitación principal de la propuesta técnica:** la precisión de una simulación no reemplaza evidencia sobre acceso, efectividad local, dinámica individual y latencia. La entrega debe mostrar cómo cambia la conclusión al cambiar esos supuestos. Esa transparencia es parte del resultado científico que conviene ofrecer a ACC.

## 12. Paquete de evidencia y delegación a Kimi/Gemini

**Resultado de esta actualización:** núcleo de siete referencias (§6.1), matriz inicial de parámetros y vacíos (§6.2) y dos encargos completos. Los documentos están preparados para copiar; no se enviaron consultas a Kimi ni a Gemini y sus respuestas todavía no existen.

- [Encargo para Kimi: arquitectura, supuestos y reproducibilidad](encargo_kimi_arquitectura_IB_APS_2026-09-16.md).
- [Encargo para Gemini: efectos, implementación y transportabilidad](encargo_gemini_evidencia_IB_APS_2026-09-16.md).

Cada archivo incluye el bloque común y su encargo específico en un solo bloque de texto. Copiarlo completo en una conversación nueva. No requiere subir microdatos ni conceder acceso al repositorio. La diferencia de encargos busca obtener productos complementarios; no presupone que una plataforma tenga mayor capacidad científica.

### 12.1 Cómo usar las respuestas para avanzar

| Orden | Decisión/producto | Fuente o trabajo de respaldo | Condición de cierre |
|---|---|---|---|
| 1 | Ficha de IB: población, instrumento, proveedor, contenido, duración y comparador. | E5 y evaluación clínica de Gemini. | El comparador corresponde a la atención habitual definida; la intervención no se confunde con tratamiento de dependencia. |
| 2 | Cascada basal y expansión: contacto, tamizaje, elegibilidad, entrega, recursos. | E1–E3, E6; datos chilenos requeridos en §6.2. | Cada tasa tiene personas/denominador, período y origen. Los escenarios de cobertura desconocida se identifican como supuestos. |
| 3 | Efecto, HED, persistencia y repetición. | E4/E5/E7; rastreo de supuestos por Kimi y evidencia clínica por Gemini. | No se mezclan escalas ni se duplica adherencia; lo observado se separa de extrapolaciones. |
| 4 | Algoritmo mínimo y contrato de exposición con el motor sanitario. | Kimi y arquitectura de §7. | Estado, paso temporal, elegibilidad, efecto y salida de exposición son auditables; se preservan RR y causas autorizadas. |
| 5 | Controles y decisiones para ACC. | Controles de §8 y tabla siguiente. | Solo se presenta impacto sanitario después de reproducir el basal y superar la validación pertinente. |

**Cinco comprobaciones sustantivas previstas para el modelo, no ejecutadas en esta actualización documental**

| Comprobación | Qué debe ocurrir para aprobar |
|---|---|
| Reproducción basal | La misma versión, configuración y datos reproducen el resultado local elegido como control; cualquier discrepancia se resuelve antes de confiar en resultados nuevos. |
| Política nula | Expansión cero, con simulaciones emparejadas y números aleatorios comunes cuando corresponda, produce diferencia cero salvo tolerancia numérica declarada. |
| Balance de cascada | Tamizados, elegibles y receptores respetan sus universos condicionales; no hay doble conteo de personas; no se excede capacidad sin registrar demanda no atendida. |
| Efecto y repetición | La transformación reproduce la unidad/tiempo del parámetro; consumo no negativo; repetición actualiza el estado sin multiplicar indefinidamente reducciones; HED conserva su definición. |
| Resultado sanitario | Referencia y política usan causas/estratos/horizonte compatibles; no se aplica AAF además de PIF al mismo cálculo; definición de años perdidos idéntica en la comparación. |

### 12.2 Criterios para aceptar o devolver una respuesta

Aceptar solo cuando cada artículo resuelva una decisión y cada número tenga fuente localizable, población, unidad, denominador y tiempo. Exigir separación entre evidencia empírica, supuesto del modelo, transformación aritmética y propuesta para Chile.

Devolver para corrección si aparecen DOI discordantes, datos extraídos de un texto no consultado, referencias de relleno, cobertura usada como eficacia, AUDIT convertido a gramos sin puente, efecto no significativo llamado exactamente nulo, o persistencia extrapolada presentada como observada. Marcar como pendiente lo inaccesible; no descartarlo ni aprobarlo por intuición.

La síntesis final debe decidir qué entra como candidato central, qué queda en sensibilidad y qué dato local falta. Si Kimi y Gemini discrepan, confrontar población, comparador, escala, seguimiento y fuente original; no promediar sus respuestas ni decidir por mayoría de artículos.

### 12.3 Registro y límites de la búsqueda

**Fecha de corte y verificación:** 16 de septiembre de 2026. Búsqueda web focalizada con cotejo en páginas editoriales, PubMed y repositorio institucional de autor; no se realizó una búsqueda exhaustiva en bases bibliográficas de suscripción ni se elaboró un flujo PRISMA.

Se revisaron artículos y suplementos disponibles durante la preparación de esta guía. Acceso de respaldo: E1, artículo y suplemento 1; E2, artículo y enlace al código; E3, manuscrito aceptado en White Rose; E4, resumen completo de Cochrane; E5/E6, textos editoriales; E7, resumen y extractos indexados de BMJ/PubMed, con acceso directo inestable. La tabla §6.1 precisa qué se extrajo. No presentar el acceso parcial a E7 como auditoría completa de métodos.

En esta actualización se reconsultaron las páginas de E1/E2 y se contrastaron E6/E7 mediante búsquedas por DOI. Consultas de comprobación: `"10.1136/bmj-2024-083985" "24"` y `"10.1007/s11606-020-06503-9" "14.1"`. Este es un registro de comprobaciones, no una reconstrucción exhaustiva de todas las consultas exploratorias previas.

No se descargó ni ejecutó código de simulación, no se cambiaron notebooks/Quarto/RR y no se produjeron estimaciones sanitarias nuevas. La conversión semanal/diaria de §6.2 es aritmética, no una nueva estimación de eficacia. Los hallazgos locales de §11 conservan el alcance de su revisión original; esta actualización bibliográfica no los revalida.

**Mensaje para la reunión**

> «La literatura permite especificar una cascada de implementación y estimar cambios contrafactuales en exposición. Mi siguiente entrega será identificar qué componentes podemos parametrizar con evidencia, cuáles requieren datos chilenos y cuáles deben quedar como sensibilidad. La prioridad es cerrar esa especificación antes de producir cifras de mortalidad evitada».

## Apéndice: contenido de la copia descartada (append del 2026-10-05)

> **Esto es un append.** Durante la migración a `ACC1240138/micsim` (2026-10-05) se compararon dos copias de este guion. Se conservó esta versión ampliada, y se anexa aquí, **sin cambios**, la sección 6 de la copia descartada (`guion_reunion_ACC_2026-09-16_revision_critica.md` de la raíz del proyecto anterior, del 2026-09-17, un borrador previo). Es lo único que esa copia tenía y esta no: la tabla de fuentes con cifras (Kaner, Barticevic, Poblete, Angus, Purshouse), el párrafo sobre duración (Fleming et al., 2002, ausente en la sección 6 de arriba) y el párrafo sobre HED. Una parte es redundante con la sección 6 vigente; si difiere, **prevalece la sección 6 de arriba**.

### 6\. Evidencia para parametrizar, con unidades y comparadores

| Fuente | Hallazgo que sirve al modelo | Traducción permitida y límite |
| :---- | :---- | :---- |
| **Kaner et al., Cochrane 2018** | Diferencia media de −20 g/semana a doce meses, IC95% −28 a −12, frente a intervención mínima o ninguna; heterogeneidad importante. | Escenario internacional de efecto absoluto. Equivale aritméticamente a aproximadamente −2,86 g/día; no es −20% ni una reducción nueva que se acumula cada año. [Fuente](https://www.cochrane.org/evidence/CD004148_effectiveness-brief-alcohol-interventions-primary-care-populations). |
| **Barticevic et al., Chile 2021** | Adultos, AUDIT 8–15; IB de cinco minutos por técnicos \+ folleto versus folleto. A seis meses, aproximadamente 80% versus 71% en bajo riesgo; p=0,1 para el desenlace primario. | Evidencia local de efecto incremental incierto. No demuestra equivalencia ni ausencia universal de beneficio. AUDIT no se transforma directamente en gramos. [Fuente](https://link.springer.com/article/10.1186/s13722-021-00248-4). |
| **Poblete et al., Chile 2017** | ASSIST y riesgo moderado; APS, urgencias y comisarías. No se encontraron diferencias en resultados de alcohol/drogas a tres meses; seguimiento completado por 62%. | Contexto local sobre efectividad e implementación, con población y medición distintas. ACC es coautor: su experiencia puede informar factibilidad. No es un parámetro AUDIT ni gramos/día. [Fuente](https://pubmed.ncbi.nlm.nih.gov/28239995/). |
| **Angus et al., Italia 2014** | SAPM aplica reducción de 12,3% y retorno lineal a basal a siete años; pesquisa AUDIT-C ≥4 mujeres/≥5 hombres. | Escenario histórico de modelación. Los puntos de corte no son automáticamente un protocolo chileno ni el efecto una estimación nacional. [Fuente](https://link.springer.com/article/10.1186/1471-2296-15-26). |
| **Purshouse et al., 2013** | En Inglaterra, el modelo proyecta aproximadamente 40% de cobertura a diez años al registro y 96% a siguiente consulta, con distinta carga de implementación. | Referencia de diseño y capacidad; no usar esos porcentajes como tasas anuales ni cobertura chilena. [Fuente](https://pubmed.ncbi.nlm.nih.gov/23015608/). |

**Duración:** el ensayo de Fleming citado para sostener persistencia observó 48 meses, con dos visitas y dos llamadas. No observó siete años de efecto. El retorno lineal a siete años es una extrapolación del modelo; tratar duración corta, intermedia y Sheffield histórico como supuestos estructurales separados. [Fleming et al., 2002](https://onlinelibrary.wiley.com/doi/10.1111/j.1530-0277.2002.tb02429.x).

**HED:** existe evidencia de cambios pequeños en frecuencia de episodios intensivos, pero frecuencia, prevalencia de HED y cantidad por ocasión no son el mismo desenlace. El metaanálisis no autoriza reducirlos todos en el mismo porcentaje. Armonizar definición y ventana antes de trasladar un efecto a los RR de lesiones. [Kaner et al., resultados](https://doi.org/10.1002/14651858.CD004148.pub4).

**Reglas para no construir un efecto ficticio**

- Elegir una escala principal: diferencia en gramos, cambio proporcional o cambio en un desenlace de riesgo con un puente validado. No sumar −20 g/semana, −12,3% y una OR chilena como si fueran beneficios independientes.  
- Si se aplica un efecto medio entre grupos, no multiplicarlo de nuevo por una probabilidad arbitraria de «responder» o por adherencia ya incluida en ese efecto. Una mezcla respondedores/no respondedores debe recuperar el mismo promedio de referencia.  
- El efecto Cochrane está medido a doce meses. La función temporal debe reproducir ese valor en ese punto; el patrón durante el primer año y después del seguimiento son supuestos adicionales.  
- Comparar fortalecimiento del programa con atención habitual real. Una IB versus folleto no equivale a IB versus nada; el descenso antes–después en ambos brazos tampoco identifica el efecto del folleto.  
- Mantener un escenario de efecto incremental nulo y sensibilidades de transportabilidad. No truncar automáticamente al beneficio una distribución de incertidumbre que admita ausencia de efecto o daño.

En Barticevic hay discrepancia entre el IC de un desenlace secundario AUDIT del resumen y el del cuerpo del artículo. Esta guía evita usar ese IC como parámetro. La evidencia chilena informa la incertidumbre local; todavía se necesita un vínculo defendible entre sus desenlaces y la exposición utilizada por los RR.
