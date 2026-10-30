# Precedentes para el préstamo de información por "movimientos relativos" entre estados de origen adyacentes en matrices de transición empíricas escasas (EPS Chile, FONDECYT 1240138)

No encontré ningún estudio, ni en alcohol ni en otro campo, que aplique exactamente el método propuesto: préstamo de los movimientos relativos (stay/up k/down k) desde estados de origen adyacentes del mismo estrato, con una contracción que depende de la información de cada fila y un n_eff de Kish. Sin embargo, cada uno de sus componentes tiene precedentes peer-reviewed sólidos y se puede defender en una sección de métodos. Hay además una advertencia empírica importante: en los datos de alcohol la persistencia **no** es invariante entre categorías, así que conviene modificar el préstamo de la diagonal.

## TL;DR

- **No hay precedente directo, pero sí una base defendible.** El método combina tres tradiciones consolidadas:
  - la contracción pseudo-Bayes hacia un modelo estructurado con constante elegida por los datos (Fienberg & Holland 1973; Bishop, Fienberg & Holland 1975);
  - la parametrización de tablas de transición ordinales en función de la distancia a la diagonal (diagonals-parameter symmetry de Goodman 1979; modelos topológicos de Hauser 1978; Hout 1983);
  - el uso del tamaño muestral efectivo de Kish para ponderar encuestas complejas dentro de modelos de contracción (Chen, Wakefield & Lumley 2014).
- **En alcohol, los modelos de referencia no hacen esto.** Optan por estructuras paramétricas que comparten información entre orígenes de forma implícita, más una calibración:
  - SIMAH (Kilian et al. 2025; Puka et al. 2023) usa una regresión logística ordinal con el consumo previo como predictor, o modelos multiestado de Markov que solo permiten transiciones a estados adyacentes, y calibra con history matching bayesiano;\[1\]
  - Barbosa et al. (2019) y Moid et al. (2026) usan logit multinomial o simulación bayesiana con Dirichlet, seguida de simulated annealing.
  - Ninguno documenta el préstamo explícito entre filas de origen adyacentes.
- **Hay que corregir la diagonal y comparar con el estándar.** Puka et al. (2023) estiman una persistencia anual de 90,2% en la categoría I, 31,8% en la II y 52,2% en la III (NESARC).\[2\] Prestar la persistencia de C1 a C2 sobreestimaría mucho la estabilidad de C2. Recomiendo:
  - prestar los movimientos relativos fuera de la diagonal, pero contraer la persistencia hacia la fila padre del **mismo origen**;
  - comparar el resultado con un modelo ordinal o multinomial con el origen como covariable y partial pooling jerárquico, que es la alternativa estándar.

## Hallazgos clave por campo

### A. Investigación en alcohol

| Referencia | Qué hicieron | Cercanía al método propuesto |
|---|---|---|
| **Kilian C, Buckley C, Lemp JM, et al. (2025).** *Targeting alcohol use in high-risk population groups: a US microsimulation study of beverage-specific pricing policies.* Lancet Public Health 10(10):e815–e823. doi:10.1016/S2468-2667(25)00165-3 (PMC12478644) | <ul><li>Microsimulación SIMAH por sexo, edad, raza/etnia y educación.</li><li>Las\[1\] transiciones entre categorías de consumo provienen de una "ordinal logistic regression modelling of pseudo-longitudinal BRFSS data (2000–10)" basada en características individuales "and previous alcohol use".</li><li>Los\[1\]\[3\] coeficientes se toman como priors y se calibran con Bayesian history matching (métrica de implausibilidad <3) contra prevalencias BRFSS 2011–15.</li><li>Validación\[1\]\[4\] con BRFSS 2016–19.</li></ul>\[1\] | Análogo parcial. El modelo ordinal con el estado previo como predictor comparte información entre orígenes mediante umbrales y pendientes comunes, pero no hay préstamo explícito fila a fila. El detalle operativo está en el apéfndice (pp 3–22), que no pude revisar. |
| **Lemp et al. (2026)**, JAMA Health Forum 7(7):e262348 (SIMAH) | <ul><li>Mismo modelo ordinal.</li><li>No\[5\] reportan resultados para "other race and ethnicity" porque "model parameters could not be reliably informed by empirical data".</li></ul>\[5\] | Ante celdas escasas, SIMAH opta por **no reportar** en lugar de suavizar. |
| **Probst C, Buckley C, Lasserre AM, et al. (2023).** SIMAH project: study design and first results. Am J Epidemiol 192(5):690–702 (PMC10423629) | <ul><li>El protocolo planeaba modelos de Markov multiestado en tiempo continuo con NESARC I–II y covariables.</li><li>Raza\[6\]\[7\] agrupada en 4 categorías porque "a more detailed grouping will not be possible ... due to small sample size".</li><li>Planeaba\[6\] calibración tipo ABC/history matching.</li></ul>\[6\] | Apoyo conceptual: la escasez se maneja agregando estratos y calibrando, no suavizando filas. |
| **Puka K, Buckley C, Mulia N, et al. (2023).** Behavioral stability of alcohol consumption... Addiction 118(1):61–70. doi:10.1111/add.16024 | <ul><li>Modelo de Markov multiestado (msm) en NESARC con categorías OMS en g/día específicas por sexo.</li><li>"Permissible\[2\] instantaneous transitions included all adjacent states", con covariables edad, sexo, educación y raza.</li><li>Pesos:\[2\] "observations were replicated in accordance with their sample weight ... confidence intervals were transformed into standard errors and corrected to the original sample size".</li><li>Evaluaron,\[2\] como alternativa, separar abstemios de por vida y exbebedores.</li></ul>\[2\] | Análogo parcial importante: <ul><li>restringir a movimientos entre estados adyacentes es una estructura de "movimiento relativo" a nivel de intensidades;</li><li>la corrección al tamaño muestral original muestra que replicar observaciones por peso infla el n, lo que es un precedente directo para usar n_eff y no Σw.</li></ul> |
| **Buckley C, et al. (2022)**, IJADR 10(1):24–33 (insumos BRFSS de SIMAH) | <ul><li>Los abstemios de 30 días se reasignaron a abstemios de por vida, exbebedores y bebedores de 12 meses con la NAS 2005, por edad, sexo y raza, mediante muestreo proporcional.</li><li>Advierten\[8\] "caution when producing subgroup summaries".</li></ul>\[8\] | Precedente para tratar N0 y FD como estados no ordinales distintos. |
| **Barbosa C, Dowd WN, Aldridge AP, et al. (2019).** Estimating long-term drinking patterns for people with lifetime AUD. Med Decis Making. doi:10.1177/0272989X19873627 | <ul><li>Logit multinomial en NESARC para las transiciones entre 4 niveles de riesgo OMS y abstinencia, por edad, sexo y raza.</li><li>Conversión\[9\] de 3 a 1 año.</li><li>Calibración\[9\] por simulated annealing.</li></ul>\[9\]\[10\] | Alternativa estándar: regresión con el origen como covariable. |
| **Moid MZI, Bray JW, van Hasselt M, Barbosa C (2026).** MDM Policy & Practice 11(1). doi:10.1177/23814683261421957 | <ul><li>Simulación bayesiana con NLSY97 y NSDUH.</li><li>"We\[10\] fitted these probabilities to Dirichlet distributions based on the estimated transitions and sample size".</li><li>Calibración\[10\] por simulated annealing.</li></ul> | Apoyo para el enfoque Dirichlet-multinomial (su forma actual de contracción hacia la fila padre), sin préstamo entre orígenes. |
| **STAPM / SAPM (Sheffield):** Brennan et al., NIHR PHR (NBK624012); Morris D, Gillespie D, Chen RKL, et al. 2025, informe GSR 81/2025 para el Gobierno de Gales (STAPM v2.6.0); Purshouse et al. 2013, Ann Oper Res, doi:10.1007/s10479-013-1451-z | <ul><li>Microsimulación dinámica a partir de encuestas transversales repetidas (HSE).</li><li>Las\[11\]\[12\] tendencias de consumo se proyectan sobre patrones por edad y no con matrices de transición longitudinales.</li><li>Las\[13\] preferencias por bebida se promedian en 120 subgrupos (edad × sexo × IMD × categoría de bebedor) para evitar celdas escasas.</li><li>En\[13\] el modelo original, las elasticidades solo convergieron en dos grandes subgrupos.</li></ul>\[14\] | Apoyo conceptual: agregan estratos ("fila padre") ante la escasez. No hay suavizado entre orígenes. |

### B. Otros modelos de salud y uso de sustancias

- **Microsimulaciones de tabaco y cigarrillo electrónico (PATH)** (PMC10104340). Estiman 27 transiciones entre 9 estados por sexo y 4 grupos de edad con un modelo multiestado.\[15\] La escasez se controla limitando la estratificación.
- **hesim (R).** Estima los modelos de transición con un logit multinomial separado por estado de origen.\[16\] Es la práctica estándar en evaluación económica y no comparte información entre orígenes.
- **Transiciones de IMC.** Estudios como "Transitions between body mass index categories, South Africa" (PMC7716104; National Income Dynamics Study, olas 2008–2017) o los de nominal logistic regression (BMC Med Res Methodol 2014;14:32) codifican explícitamente los resultados como "upwards / downwards / no transition" y modelan esas transiciones con regresión multinomial. Esto es un análogo directo de la parametrización por movimiento relativo, aunque sin contracción.

### C. Estadística, econometría, finanzas y sociología de la movilidad

**Contracción y empirical Bayes para tablas y cadenas de Markov**

- **Fienberg SE & Holland PW (1973).** Simultaneous estimation of multinomial cell probabilities. JASA 68:683–691. También Bishop, Fienberg & Holland (1975), *Discrete Multivariate Analysis*, cap. 12, "Pseudo-Bayes estimates".
  - El estimador es (1−λ)p + λπ̃, donde π̃ es un modelo estructurado (no necesariamente uniforme) y la constante se elige con los datos.\[17\]
  - **Esta es la mejor cita para justificar su contracción.** Su "donante por movimiento relativo" es simplemente un π̃ estructurado distinto.
- **Meshkani MR & Billard L (1992).** Empirical Bayes estimators for a finite Markov chain. Biometrika 79:185–193. doi:10.1093/biomet/79.1.185
  - Aplica empirical Bayes con priors Dirichlet por fila a las probabilidades de transición.\[18\]
  - Es el precedente canónico del enfoque actual (fila padre).
- **Hausser J & Strimmer K (2009)** (arXiv:0811.3579). Muestran la equivalencia entre la intensidad de shrinkage λ y la constante Dirichlet: A = nλ/(1−λ).\[19\] Esto respalda interpretar su k como pseudo-conteos.
- **Simonoff JS (1983, 1987).** Ann Stat 11:208–218; Stat Probab Lett 5:55–63.
  - Suavizado por verosimilitud penalizada para tablas escasas con categorías ordenadas: penaliza las diferencias entre celdas vecinas.
  - Fundamenta que el suavizado entre categorías ordinales adyacentes es consistente bajo asintótica escasa.\[20\]
- **Dong J & Simonoff JS (1994).** J Comput Graph Stat 3:57–66. Boundary kernels: en los bordes de una escala ordinal, el suavizado unilateral introduce sesgo y requiere corrección. Es el paralelo técnico más claro de su sesgo por préstamo asimétrico (ver sección D).
- **Gertheiss J & Tutz G (2009).** Penalized regression with ordinal predictors. Int Stat Rev 77:345–365. Penalizan las diferencias entre parámetros de categorías adyacentes de un predictor ordinal.\[20\] Es la versión en regresión de "pedir prestado al origen vecino": el origen ordinal como predictor con penalización de primeras diferencias.

**Parametrización por distancia a la diagonal (el análogo más cercano a "movimientos relativos")**

- **Goodman LA (1979)**, modelo diagonals-parameter symmetry: el cociente π_ij/π_ji depende solo de la distancia j−i. Tahata & Matsuda (2023, arXiv:2305.08136) lo resumen: "the ratio depends only on the distance from the main diagonal cells".\[21\]
- **Hauser RM (1978)**, modelos topológicos, y **Hout M (1983)**, *Mobility Tables* (Sage QASS). Definen "niveles" de interacción compartidos entre celdas que cruzan filas, incluidas bandas diagonales con parámetros comunes.\[22\]
  - Esto es precisamente "C1→C2 informa C2→C3": la celda (i, i+1) comparte parámetro con todas las celdas a la misma distancia.
  - Son la mejor justificación conceptual para la reparametrización relativa.
- **Fosse E & Pfeffer FT (2025).** Sociol Methods Res, doi:10.1177/00491241251358895. Revisan los diagonal reference models y la tipología de modelos según origen, destino y movilidad (f(O,M)).\[23\]\[24\] Es útil para enmarcar el "movimiento" como una dimensión propia.

**Matrices de migración de rating crediticio**

- **Weißbach R & Mollenhauer T (2011)**, "Modelling rating transitions", J Korean Stat Soc 40:469–485. Proponen un proceso de Markov en tiempo continuo con **un solo parámetro**, "the intensity to migrate to an adjacent rating state", compartido entre estados, y lo generalizan a intensidades específicas por estado con un test de razón de verosimilitudes.
  - Es el precedente formal más cercano: el movimiento a un estado adyacente se comparte entre orígenes y luego se prueba si hace falta especificidad por estado.
- **Nickell P, Perraudin W & Varotto S (2000).** Stability of rating transitions. J Bank Finance 24:203–227. doi:10.1016/S0378-4266(99)00057-6. Usan modelos ordered probit para las transiciones condicionando en industria, domicilio y ciclo.\[25\]\[26\] Es la alternativa paramétrica estándar.
- **Hu Y-T, Kiesel R & Perraudin W (2002)**, "The estimation of transition matrices for sovereign credit ratings", J Bank Finance 26(7):1383–1406, doi:10.1016/S0378-4266(02)00268-6. Combinan la matriz empírica con la del ordered probit porque esta última es "more plausible" en categorías con pocos datos. Es un precedente de mezclar la estimación empírica con una estructura ordinal.
- **Lando D & Skødeberg TM (2002).** J Bank Finance 26:423–444. **Jafry Y & Schuermann T (2004).** J Bank Finance 28:2603–2639. **Bangia A, Diebold FX, et al. (2002).** J Bank Finance 26:445–474.
  - Muestran que el estimador por intensidades (duration/generator) da probabilidades no nulas para transiciones raras y que conviene comparar matrices con métricas de movilidad.
  - Bangia et al. enfatizan la monotonicidad por filas como propiedad estilizada.\[27\]
  - Utilidad para ustedes: la (estocástica) monotonicidad es un diagnóstico a imponer o verificar tras el suavizado.
- **Perederiy V**, "Sparse Structural Approach for Rating Transitions" (arXiv:1708.00062; revisado en enero de 2020). Propone un proceso estructural que, con solo tres parámetros, describe toda una matriz típica de transición, como alternativa al "technical smoothing"; según el autor, puede aplicarse con apenas 50 transiciones observadas.

### D. Ponderación por diseño, n_eff y préstamo asimétrico

- **Kish L (1965, 1992)**: n_eff = (Σw)²/Σw². Es estándar, por ejemplo en el paquete PracTools: "the effective sample size is the size of an SRS that would yield the same variance as that produced by the complex design".\[28\]\[29\]
- **Chen C, Wakefield J & Lumley T (2014).** The use of sampling weights in Bayesian hierarchical models for small area estimation. Spat Spatiotemporal Epidemiol (PMC4357363).
  - Definen un tamaño muestral efectivo por área, cuyo cociente con el n real es el inverso del design effect de Kish.\[30\]
  - Lo usan dentro de modelos bayesianos jerárquicos, "separat[ing] the design-based survey computations and the model-based Bayesian shrinkage".\[30\]
  - **Esta es la cita clave para usar n_eff, y no Σw, como peso de credibilidad.** Además, sugiere una mejora: usar un n_eff basado en la varianza de diseño (Taylor/jackknife con estratos y PSU), no solo el de Kish por pesos.
- **Puka et al. (2023)**: la corrección de los errores estándar "to the original sample size" tras replicar por pesos es un precedente aplicado dentro del campo del alcohol.\[2\]
- **Préstamo asimétrico:** no encontré estudios que documenten explícitamente el sesgo de prestar solo desde estados inferiores en matrices de transición. El análogo técnico es la literatura de boundary kernels (Dong & Simonoff 1994), según la cual el suavizado unilateral en los bordes de una escala ordinal sesga las estimaciones hacia el interior. Esto respalda su diagnóstico ("regresión hacia el nivel del donante") y la preferencia por un préstamo bilateral y reparametrizado.

## Detalles: ¿qué tan defendible es el método?

**Lo que está bien fundamentado:**
1. **Contracción dependiente de la información** con una constante elegida por validación cruzada (log-loss). Es el pseudo-Bayes de Fienberg-Holland o el empirical Bayes de Meshkani-Billard. Es estándar.
2. **Préstamo en la escala de movimiento relativo.** Los modelos de diagonales y topológicos (Goodman, Hauser, Hout), el one-parameter adjacent intensity (Weißbach) y las restricciones a transiciones adyacentes (Puka) tratan la distancia origen-destino como estructura compartida. Prestar destinos absolutos de un origen vecino sí sesga hacia el nivel del donante, y su intuición coincide con la lógica de esos modelos.
3. **n_eff de Kish** en lugar de Σw (Chen-Wakefield-Lumley; Puka).
4. **N0 y FD como estados no ordinales**, con la salida a no consumo prestada como destino absoluto. Coincide con la separación entre abstemios de por vida y exbebedores de SIMAH (Buckley 2022; Puka 2023).\[8\]

**Lo que es más débil y debe corregirse:**
- **Invariancia de la persistencia.** Los resultados de Puka et al. (Tabla 2: permanecer en el mismo estado 90,2% en I, 31,8% en II y 52,2% en III) muestran que la diagonal **no** es traslacional: C2 es un estado "de paso" y C3+ es parcialmente absorbente por efecto techo.\[2\] Prestar "stay" desde C1 inflaría la estabilidad de C2.
  - Recomendación: tratar la persistencia como parámetro específico del origen y contraerla hacia la fila padre del mismo origen (período × sexo). Restringir el préstamo relativo a la *forma condicional* de los movimientos, es decir, a la distribución de up y down dado que hubo movimiento, normalizada.
- **Bordes:** colapsar en el estado superior los movimientos que exceden el tope crea una masa artificial en C3+. Conviene documentarlo y verificar con un análisis de sensibilidad.
- **Monotonicidad:** tras el suavizado conviene verificar la monotonicidad estocástica por filas (literatura de rating), como diagnóstico, no como restricción dura.

## Recomendaciones para la sección de métodos

1. **Citas núcleo:**
   - Fienberg & Holland 1973 y Bishop-Fienberg-Holland 1975 (pseudo-Bayes hacia un modelo estructurado);
   - Meshkani & Billard 1992 (empirical Bayes en cadenas de Markov);
   - Goodman 1979, Hauser 1978 y Hout 1983 (parametrización por distancia a la diagonal);
   - Weißbach & Mollenhauer 2011 (intensidad adyacente compartida);
   - Chen, Wakefield & Lumley 2014 y Kish 1965 (n_eff en contracción con datos de encuesta);
   - Puka et al. 2023 y Kilian et al. 2025 (contexto de alcohol);
   - Simonoff 1987 y Dong & Simonoff 1994 (suavizado ordinal y sesgo de borde).
2. **Presentar el método como un estimador pseudo-Bayes** cuyo prior es una mezcla de (a) la fila padre del mismo origen y (b) un "prior de movimiento relativo" construido con los orígenes adyacentes del mismo estrato. Los pseudo-conteos deben ser proporcionales a k/(k + n_eff).
3. **Comparar con la alternativa estándar** como análisis de sensibilidad:
   - un logit ordinal o multinomial con el origen como covariable (con interacción origen × sexo y efectos aleatorios de estrato), o
   - un modelo bayesiano jerárquico multinomial con partial pooling (por ejemplo, brms/Stan) ajustado con pesos.
   - Si ambas aproximaciones coinciden en las filas con datos suficientes y su método mejora el log-loss fuera de muestra en las filas escasas, la justificación queda cerrada.
4. **Validación externa** al estilo SIMAH y Puka: proyectar la EPS hacia adelante y comparar con las prevalencias observadas en olas posteriores o en la ENPG/ENS.

## Advertencias

- No pude acceder a los apéndices operativos de SIMAH (Kilian 2025, pp 3–22; Lemp 2026, eMethods) ni al Supplementary Material 2 de STAPM. Por tanto, no confirmo si el modelo ordinal de SIMAH incluye interacciones origen × estrato ni cómo usa los pesos BRFSS.
- No encontré literatura específica que analice la invariancia traslacional de las transiciones de consumo de alcohol. El argumento contra prestar la persistencia se apoya en las estimaciones descriptivas de Puka et al. (EE. UU.), que podrían no replicarse en Chile.
- Las referencias de rating crediticio y de movilidad social son análogos metodológicos, no aplicaciones de salud.

## Fuentes

1. [Targeting alcohol use in high-risk population groups: a US microsimulation study of beverage-specific pricing policies - PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC12478644)
2. <https://eprints.whiterose.ac.uk/id/eprint/190647/1/Addiction%20-%202022%20-%20Puka%20-%20Behavioral%20stability%20of%20alcohol%20consumption%20and%20socio%E2%80%90demographic%20correlates%20of%20change%20among%20a.pdf>
3. [Simulation of Alcohol Control Policies for Health Equity (SIMAH): Study Design and First Results](https://www.researchgate.net/publication/367412451_Simulation_of_Alcohol_Control_Policies_for_Health_Equity_SIMAH_Study_Design_and_First_Results)
4. [Targeting alcohol use in high-risk population groups: a US microsimulation study of beverage-specific pricing policies - The Lancet Public Health](<https://www.thelancet.com/journals/lanpub/article/PIIS2468-2667(25)00165-3/fulltext>)
5. [Expanded Alcohol Screening and Brief Intervention to Address Premature Mortality](https://jamanetwork.com/journals/jama-health-forum/fullarticle/2851858)
6. [Simulation of alcohol control policies for health equity ( ...](https://eprints.whiterose.ac.uk/id/eprint/198292/1/SIMAH_protocol_technical%20review.pdf)
7. [Simulation of Alcohol Control Policies for Health Equity (SIMAH) Project: Study Design and First Results - PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC10423629/)
8. <https://ijadr.org/index.php/ijadr/article/download/383/529/>
9. [Estimating Long-Term Drinking Patterns for People with Lifetime Alcohol Use Disorder - Carolina Barbosa, William N. Dowd, Arnie P. Aldridge, Christine Timko, Gary A. Zarkin, 2019](https://doi.org/10.1177/0272989x19873627)
10. [Estimating Lifetime Drinking Trajectories for Alcohol Use from Adolescence to Older Adulthood in the United States: A Three-Step Approach - Md Zubab Ibne Moid, Jeremy W. Bray, Martijn Van Hasselt, Carolina Barbosa, 2026](https://doi.org/10.1177/23814683261421957)
11. [Estimating the effect of transitioning to a strength-based alcohol tax system on alcohol consumption and health outcomes: a modelling study of tax reform in England - The Lancet Public Health](<https://www.thelancet.com/journals/lanpub/article/PIIS2468-2667(24)00191-9/fulltext>)
12. [Appraisal of joint tobacco and alcohol tax interventions for harm reduction in the UK: the SYNTAX integrated evidence synthesis project - NCBI Bookshelf](https://www.ncbi.nlm.nih.gov/books/NBK624012/)
13. <https://www.gov.wales/sites/default/files/statistics-and-research/2025-07/new-modelling-of-alcohol-pricing-policies-alcohol-consumption-and-harm-in-wales_0.pdf>
14. [Developing policy analytics for public health strategy and decisions—the Sheffield alcohol policy model framework - PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC4710054/)
15. [Longitudinal transitions in initiation, cessation, and relapse of cigarette smoking and e-cigarette use among US youth and adults: Validation of a microsimulation model](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC10104340/)
16. [Markov models with multinomial logistic regression](https://cloud.r-project.org/web/packages/hesim/vignettes/mlogit.html)
17. [Bayesian Inference for Categorical Data Analysis: A Survey Alan Agresti](https://people.stat.sc.edu/hitchcock/bayesfinal.pdf)
18. [(PDF) A Bayesian model for binary Markov chains](https://www.researchgate.net/publication/26533662_A_Bayesian_model_for_binary_Markov_chains)
19. [Entropy inference and the James-Stein estimator, with application to nonlinear gene association networks](https://arxiv.org/pdf/0811.3579)
20. [Smoothing Methods for Discrete Data](https://www.researchgate.net/publication/265568048_Smoothing_Methods_for_Discrete_Data)
21. [Diagonals-parameter symmetry model and its property for square contingency tables with ordinal categories](https://arxiv.org/pdf/2305.08136)
22. [Sage Research Methods - Mobility Tables - Topological Models](https://methods.sagepub.com/book/mono/mobility-tables/chpt/topological-models)
23. [Beyond the Diagonal Reference Model: Critiques and New Directions in the Analysis of Mobility Effects - Ethan Fosse, Fabian T. Pfeffer, 2025](https://doi.org/10.1177/00491241251358895)
24. [Beyond the Diagonal Reference Model: Critiques and New Directions in the Analysis of Mobility Effects - Ethan Fosse, Fabian T. Pfeffer, 2025](https://journals.sagepub.com/doi/full/10.1177/00491241251358895)
25. [\[PDF\] Stability of rating transitions q](https://www.semanticscholar.org/paper/Stability-of-rating-transitions-q-Nickell-Perraudin/996d4574510331fba55553549c2cc9a76f317dac)
26. [(PDF) Estimation and prediction of credit risk based on rating transition systems](https://www.researchgate.net/publication/304787317_Estimation_and_prediction_of_credit_risk_based_on_rating_transition_systems)
27. [Ratings migration and the business cycle,](https://www.sas.upenn.edu/~fdiebold/papers/paper37/bds.pdf)
28. [Design Effects and Effective Sample Size - CRAN - R Project](https://cran.r-project.org/web/packages/PracTools/vignettes/Design-effects.html)
29. [Effective Sample Size](https://www.healthcare-economist.com/2013/08/22/effective-sample-size/)
30. [The use of sampling weights in Bayesian hierarchical models for small area estimation - PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC4357363/)
