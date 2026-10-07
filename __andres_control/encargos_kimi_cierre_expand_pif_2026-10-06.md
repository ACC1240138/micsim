# Prompts para Kimi Investigación Profunda K3 Max: cierre de expand_pif

## Instrucciones de uso (para Andrés)

**Qué es esto.** Son 10 prompts autocontenidos, de **P1 a P10**. Los nombré con "P" para que no se confundan con el nombre del modelo, "K3". Kimi no ve el repositorio ni los datos, así que cada prompt trae su propio contexto. Cada decisión lleva entre corchetes su ID del registro del 2026-10-06 (por ejemplo `[V2]`), para que la respuesta se pueda devolver a ese registro. Lo que entregue Kimi es **insumo para decidir; no es una decisión**. Las decisiones de ACC las firma ACC: puente APC, exbebedores si se supera la regla del 5%, fuente IHD/ACV, AAF=1 en PIF, YLL, edades 66+ y estómago/páncreas.

**Paso 0, antes de enviar nada**
- Registra lo que decidió ACC en la reunión del 16-sep (Q24): D1-D3, PSU 2016, AAF=1 en PIF, métrica YLL y alcance 15-65 vs 15+. Si algo ya está decidido, sácalo del prompt o cámbialo por «justificar la opción X, ya elegida». No mandes a investigar decisiones cerradas.
- B2 (el bloque AAF=1 suma los 13 años calendario y no solo las 7 olas) se corrige en código antes de citar cualquier total AAF=1. El número que usa P5 (1.423 muertes en las 7 olas) ya viene corregido.
- Las preguntas sobre el contenido exacto de la Tabla S6 de Shield 2025 no van a Kimi. Las resuelve Claude leyendo el PDF que ya está en `_bib/`.

**Orden de envío.** Abre una conversación nueva de Kimi por cada prompt. Los prompts de una misma ola se pueden enviar en paralelo.

| Ola | Prompts | Por qué en este orden |
|---|---|---|
| **1. Hoy (bloquean V1-V3 y la nueva corrida de expand_pif)** | P1 [V1/Q1], P2 [V2/Q5/Q6], P3 [V3/B1/Q21/Q26c], P4 [D1] (solo si ACC no lo decidió) | La dirección del parche V1 ya quedó fijada por la regla interna (caso 3). P1 sirve para sostener la elección del puente APC (Q1), que decide ACC. P2 y P3 definen las prevalencias y el volumen que entran a `expand_pif` y a `data_binge_sensitivity`. D1 cambia `expand_pif` en sí (celdas nuevas, muertes de 66-76 años, constantes del YPLL): si se adopta después de la nueva corrida, hay que repetir el ciclo. |
| **2. Antes de la corrida única de expand_pif2 (~13 h)** | P5, P6, P7, P8 | Todo lo que cambie los draws o exija cómputo nuevo en pif2 se cierra antes de esa corrida: submodelo AAF=1 (P5), factor de diseño de 2020, piso en 1 y clave PSU de 2016 (P7), fuente principal de IHD/ACV y una eventual sensibilidad sin cardioprotección (P8), y estado provisorio de 2024 junto con la fijación de la versión DEIS (P6). Elegir lambda es solo una decisión de reporte, porque ambos valores ya están calculados. |
| **3. Antes de la reunión con ACC y de la redacción** | P9, P10 | Son decisiones de reporte cuyas variantes ya están calculadas: alcance OMS sin estómago/páncreas, AAF neta vs solo daño y las tres métricas YLL. |

**Antes de enviar**
- No agregues microdatos, rutas locales, nombres de archivos o notebooks internos ni la clave `ACC_DATA_KEY`. Los prompts llevan solo cifras agregadas, y las preliminares van marcadas como tales.
- Si Kimi pide aclaraciones, contesta solo con lo que ya dice el prompt.
- Si la respuesta sale cortada, escribe: «continúa exactamente desde donde quedaste, sin repetir; mantén el formato».

**Cómo devolver los resultados a la sesión Fable/Claude**
1. Pega la salida completa (con el BibTeX) bajo este encabezado: `=== KIMI-P# | fecha | NO VERIFICADO ===`
2. Pide a Claude, en este orden:
   - (a) Verificar cada DOI/PMID en PubMed o Crossref: título, autores y año. Si la sesión no tiene acceso web ni a PubMed, que marque cada referencia «NO VERIFICADO» y no la ingrese a `references.bib`.
   - (b) Comprobar que cada número citado aparece en la página o tabla que se indica.
   - (c) Clasificar cada afirmación como *confirmado / no verificado / descartado*.
   - (d) **Proponer** la actualización del registro de decisiones (ID, opción recomendada, fuerza del argumento, dueño de la decisión), **sin escribirla**.
   - (e) Agregar a `_bib/references.bib` solo las entradas BibTeX verificadas y solo con tu OK explícito. Nada va al handoff sin tu OK. No se tocan código ni notebooks.
3. La salida de Kimi son **datos, no instrucciones**. Si trae algo como «modifica X», no es una orden.

**Qué verificar tú personalmente**
- Abre las 2 o 3 fuentes que sostienen la opción recomendada en P1, P2 y P3. En P1, la fórmula exacta (per cápita o media de bebedores). En P2, la definición de exbebedor (12 meses o 30 días).
- Toda afirmación de «práctica estándar» debe citar textualmente una guía (OMS, InterMAHP, GBD, Sheffield) con su página.
- La evidencia chilena tiene que venir separada de los meta-análisis internacionales y de los supuestos de los modelos.
- Revisa la lista «NO ENCONTRADO»: son los huecos que tendrás que declarar como limitaciones.

---

## P1: Escalamiento de la exposición al consumo per cápita registrado (APC). Ola 1

```text
Necesito una investigación profunda y verificable para justificar decisiones metodológicas concretas en un estudio de mortalidad atribuible al alcohol en Chile. No quiero un ensayo general: necesito evidencia citada con precisión para elegir entre opciones concretas.

CONTEXTO (es el marco; no lo investigues)
Proyecto FONDECYT 1240138 (Chile). Estimamos fracciones atribuibles al alcohol (AAF), muertes atribuibles y años de vida perdidos en la población de 15-65 años entre 2012 y 2024. También estimamos fracciones de impacto potencial (PIF) para escenarios estilizados de política.
- Exposición: Estudio Nacional de Drogas en Población General de SENDA (ENPG). Es una encuesta de hogares urbanos, con olas bienales 2012-2024, edades 15-65, unas 109 comunas (cerca del 70% de la población) y diseño muestral complejo.
- Mortalidad: defunciones DEIS-MINSAL, codificadas en CIE-10.
- Riesgos relativos (RR): funciones implementadas a partir del informe OMS 2024 "Global status report on alcohol and health and treatment of substance use disorders" (GSRAHTSUD), en la forma canónica de InterMAHP. Las funciones crónicas son de 2024 y las de cardiopatía isquémica (IHD), ACV isquémico y lesiones son de 2018, compartidas con InterMAHP 2018.
- Cálculo de la AAF: integra RR(x) sobre una distribución gamma del consumo diario (g/día, rango 0,1-150) por año × sexo × tramo etario. Tiene términos para abstinentes de por vida (RR = 1), exbebedores (RR constante) y bebedores actuales con y sin consumo episódico excesivo (HED).
- Etapa siguiente: una microsimulación tipo SIMAH (Kilian et al., Lancet Public Health 2025, DOI 10.1016/S2468-2667(25)00165-3).

IMPLEMENTACIÓN ACTUAL
- El volumen individual (g/día) se calcula por frecuencia-cantidad graduada, con 12 g por trago.
- Cada año se aplica un factor multiplicativo para que la media ponderada ENTRE BEBEDORES ACTUALES (bebieron en los últimos 30 días y tienen los ítems completos) iguale 0,8 × APC. El APC está en litros de alcohol puro per cápita de 15+ años y se pasa a g/día con × 0,789 × 1000 / 365.
- APC codificado: 2012 = 8,0; 2014 = 8,2; 2016 = 7,1; 2018 = 6,8; 2020 = 2022 = 2024 = 7,9 L. El último valor se arrastró sin fuente. En nuestras notas (sin verificar) figuran además totales OMS distintos: 2010 = 9,3; 2016 = 9,3; 2020 = 7,56 L. Hay que reconciliarlos.
- Así, la media POBLACIONAL implícita (abstinentes y exbebedores = 0) es p_actual × 0,8 × APC, donde p_actual es la prevalencia de consumo en 30 días, de alrededor de 0,33-0,49 según la ola. Ejemplo preliminar e ilustrativo (corrida de julio de 2026): en 2024 la media entre bebedores es de unos 13,7 g/día, pero la media per cápita implícita es de unos 4,5 g/día (unos 5,2 en 2022).
- Internamente lo identificamos como un error de implementación frente a la regla que nos fijamos (la media per cápita, no la media entre bebedores, debería igualar la fracción del APC). Te pedimos solo confirmarlo o refutarlo con las guías. Si se confirma, el volumen de los bebedores actuales estaría unas 1/p_actual veces bajo (2-3 veces). El efecto sobre cada AAF NO es proporcional y no está cuantificado: en algunos cánceres domina el término de exbebedores, y en las causas con curva en J puede ir en cualquier dirección.
- Hoy p_actual excluye a los bebedores actuales con ítems de cantidad o HED faltantes (alrededor de 4-9% por ola).
- Como el factor se recalibra, el tamaño del trago (12 vs 15,7 g) se cancela en el volumen.
- El factor se aplica solo dentro del cálculo de RR/AAF/PIF, nunca a prevalencias ni a metas de calibración.

DECISIONES Y OPCIONES
D-a [V1, confirmación]: qué cantidad se iguala a la fracción del APC.
  A. Statu quo: media entre bebedores (30 días) = 0,8 × APC. Lo identificamos internamente como error; solo confirma o refuta.
  B. Media per cápita poblacional = 0,8 × APC, es decir, media entre bebedores = 0,8 × APC / p_actual. B1: p_actual medido con 30 días. B2: con 12 meses.
  C. Como B, pero ajustando el objetivo al dominio de la encuesta (15-65, urbano) en vez de 15+ nacional, y/o usando una fracción distinta de 0,8.
  D. Sin escalamiento (encuesta cruda), solo como sensibilidad.
D-b [Q1]: elecciones del puente, que decide el investigador responsable.
  (a) Serie de APC: registrado o total (registrado + no registrado), con o sin ajuste por turismo.
  (b) La fracción 0,8.
  (c) El paso de 15+ nacional a 15-65 urbano.
  (d) El alcohol no registrado en Chile.
  (e) Los valores de 2020-2024 y el valor que se congela después del último año observado (para la microsimulación).
  Además: si se escala solo la media o también la frecuencia de HED, y en qué orden respecto del tope de 150 g/día.

PREGUNTAS
Q1 [V1]. En la metodología OMS (GISAH/GSRAH, triangulación Rehm/Kehoe), InterMAHP (guía de Sherk et al. 2017), GBD y Shield et al. 2020: ¿qué cantidad se iguala a la fracción del APC, la media per cápita de toda la población (abstinentes = 0) o la media entre bebedores? Da la fórmula exacta con página o ecuación. ¿Qué prevalencia de bebedores usan (12 meses u otra)? ¿Cómo tratan a los bebedores con ítems de cantidad faltantes?
Q2 [Q1-b]. ¿De dónde viene el factor 0,8 (alcohol no consumido: derrame, desperdicio, etc.) y qué significa? ¿Quién lo propone, qué rango de valores se usa y se aplica al APC registrado o al total?
Q3 [Q1-c]. ¿Cómo se pasa de un APC de 15+ a una subpoblación de 15-65 años? Por ejemplo, ¿se reparte por edad y sexo con razones relativas de la encuesta? ¿Hay ajuste por lo que consumen los mayores de 65?
Q4 [Q1]. ¿Qué tasas de cobertura (consumo per cápita de la encuesta / APC) se reportan internacionalmente y en Chile o América Latina?
Q5 [Q1-a,d,e]. Para Chile 2010-2024, ¿cuáles son las series de APC registrado, no registrado y total? Fuentes: OMS GISAH/GHO, Banco Mundial SH.ALC.PCAP.LI, OCDE. ¿Hay valores documentados para 2020, 2022 y 2024 o solo proyecciones? ¿Qué tan fiable es la estimación OMS de alcohol no registrado (~1,4 L) frente a una estimación Delphi publicada en Int J Drug Policy 2025 (~0,05-0,5 L; no la hemos verificado)?
Q6 [Q1]. Al escalar, ¿se ajusta solo la media de la gamma (con la razón DE/media fija) o también la frecuencia de HED? ¿Antes o después del tope superior de integración?
Q7 [Q1]. ¿Cómo escalaron Kilian et al. 2025 / SIMAH y Buckley et al. 2022 (BRFSS): con objetivo per cápita o entre bebedores, y con qué fracción del APC?
Q8 [Q1]. Si la encuesta subcubre a los bebedores intensos, ¿la literatura recomienda algo distinto de un escalamiento proporcional?
Q9 [Q1-e]. En las microsimulaciones (SIMAH u otras), ¿cómo se proyecta el APC después del último año observado?

CANDIDATOS A VERIFICAR PRIMERO (confirma DOI, título y año; si no coinciden o no tratan el tema, dilo)
- Rehm J, Kehoe T, et al. 2010, Population Health Metrics (modelado del volumen de exposición).
- Kehoe T, et al. 2012, Population Health Metrics (PMC3352241).
- Kilian C, et al. 2020 (subestimación del consumo per cápita en encuestas europeas; cobertura ~36,5%).
- Buckley C, et al. 2022 (ajuste del consumo BRFSS al APC).
- Sherk A, et al. 2017, InterMAHP User Guide.
- Shield K, et al. 2020, Lancet Public Health, DOI 10.1016/S2468-2667(19)30231-2.
- Kilian C, et al. 2025, Lancet Public Health, DOI 10.1016/S2468-2667(25)00165-3 (y su apéndice); SIMAH release 0.1.1, DOI 10.5281/zenodo.15641639.

BÚSQUEDA
En inglés y español: PubMed/MEDLINE, Scopus/Web of Science (si tienes acceso), Google Scholar, SciELO, LILACS, WHO IRIS, WHO GHO/GISAH, Banco Mundial, OCDE, documentación técnica de InterMAHP y apéndices de métodos de alcohol del GBD. Haz snowballing desde los candidatos.
Términos de ejemplo: "alcohol per capita consumption" survey coverage triangulation; "survey undercoverage" alcohol upshift; "alcohol-attributable fraction" "per capita" gamma Kehoe; "consumo per cápita de alcohol" Chile "no registrado"; "unrecorded alcohol" Chile.

REGLAS DE EVIDENCIA (obligatorias)
1. Toda afirmación sustantiva lleva una cita verificable (DOI, PMID o URL estable) y, cuando exista, página/tabla/ecuación/figura. Sin cita, no se incluye.
2. Si no encuentras algo, escribe "NO ENCONTRADO" y describe qué buscaste. No adivines DOIs, cifras, años ni autores.
3. Etiqueta cada afirmación como [TEXTO] (lo dice la fuente; agrega una cita textual de menos de 30 palabras cuando puedas) o [INFERENCIA] (deducción tuya).
4. Verifica primero los candidatos. Si un DOI no coincide, la referencia no existe o no trata lo que te digo, repórtalo; no la reemplaces en silencio.
5. Cita solo lo que leíste. Si leíste solo el resumen, marca "(solo resumen)".
6. Para cada número indica población, unidad, denominador y período, y si los autores lo ESTIMARON o lo ASUMIERON.
7. No promedies fuentes discordantes: preséntalas por separado y explica la discrepancia.
8. Un resultado no significativo no equivale a "sin efecto".
9. Los informes de gobierno, OMS o SENDA sirven para definiciones, métodos y series de datos, no como evidencia de efecto causal.
10. Separa (a) evidencia chilena, (b) latinoamericana, (c) evidencia empírica internacional y (d) convenciones o supuestos de modelos (OMS, InterMAHP, GBD, Sheffield, SIMAH), que no son evidencia empírica.
11. Sin relleno: cada referencia debe sostener una fila concreta de una tabla. Máximo unas 25 referencias.
12. Prioriza la versión más reciente de cada guía y señala las versiones que se contradicen.
13. Para series de datos y páginas web, indica la fecha de consulta, la versión o edición de la base (por ejemplo, actualización GHO o versión WDI) y el indicador exacto (código y definición: registrado/no registrado/total, 15+, ajuste por turismo sí/no).
Inclusión: estudios primarios, revisiones sistemáticas y meta-análisis, guías y documentación técnica de métodos, documentación oficial de series de datos.
Exclusión: blogs, prensa y preprints sin revisión (salvo que no haya alternativa; en ese caso, márcalos).

FORMATO DE RETORNO (en español, salvo los párrafos de métodos y el BibTeX)
0. Primera línea: "KIMI-P1 | fecha de búsqueda | n referencias leídas a texto completo / n solo resumen".
1. Veredicto por opción. Tabla: Decisión [ID] | Opción | Apoyo (fuerte/moderado/débil/ninguno/contrario) | Referencias clave | Por qué.
1b. Tabla de parámetros: ID registro | Parámetro/decisión | Valor u opción | Fuente (DOI + página/tabla) | Estimado/Asumido | Transportabilidad a Chile (alta/media/baja + por qué).
2. Respuesta a cada pregunta (Q1...Q9), de 150 palabras como máximo cada una, con citas, etiquetas [TEXTO]/[INFERENCIA] y "NO ENCONTRADO" cuando corresponda.
3. Tabla de evidencia: Referencia (autor, año, revista) | DOI/PMID/URL | Diseño/población | Qué sostiene (pregunta/opción) | Números (página/tabla, unidad, denominador, período; estimado vs asumido) | Transportabilidad a Chile | Calidad/limitaciones.
4. Evidencia chilena y latinoamericana en una sección aparte, aunque quede vacía. Incluye una tabla de la serie APC de Chile 2010-2024: Año | Indicador (código y definición) | Valor (L) | Fuente | Versión/edición | Fecha de consulta.
5. Recomendación por decisión: opción, fuerza del argumento (alta/media/baja), qué evidencia la cambiaría y qué supuesto residual hay que declarar como limitación.
6. Párrafos de métodos en inglés: uno por opción viable (2 como máximo, de 100-150 palabras cada uno), con citas (Autor Año). No afirmes nada que no esté en la tabla de evidencia ni describas nuestra implementación más allá de lo dicho en IMPLEMENTACIÓN ACTUAL.
7. BibTeX de las referencias citadas en los puntos 3 y 6, con campo doi o url. No inventes campos.
8. Lista de "NO ENCONTRADO / NO VERIFICADO" y de las discrepancias de DOI detectadas.
```

---

## P2: Definición de exbebedor, RR de exbebedores e incertidumbre. Ola 1

```text
Necesito una investigación profunda y verificable para justificar decisiones metodológicas concretas en un estudio de mortalidad atribuible al alcohol en Chile. Responde a las opciones planteadas; no escribas un ensayo general.

CONTEXTO (es el marco; no lo investigues)
Proyecto FONDECYT 1240138 (Chile). Estimamos fracciones atribuibles al alcohol (AAF), muertes atribuibles y años de vida perdidos en la población de 15-65 años entre 2012 y 2024. También estimamos fracciones de impacto potencial (PIF) para escenarios de política.
- Exposición: Estudio Nacional de Drogas en Población General de SENDA (ENPG). Hogares urbanos, olas bienales 2012-2024, edades 15-65, diseño complejo.
- Mortalidad: DEIS-MINSAL (CIE-10).
- RR: funciones implementadas a partir del informe OMS 2024 "Global status report on alcohol and health and treatment of substance use disorders" (GSRAHTSUD), en la forma canónica de InterMAHP. Las funciones crónicas son de 2024; las de IHD, ACV isquémico y lesiones son de 2018 (InterMAHP 2018).
- La AAF tiene tres términos: abstinentes de por vida (RR = 1), exbebedores (RR_fd constante por causa y sexo) y bebedores actuales (gamma del consumo en g/día).
- Etapa siguiente: microsimulación tipo SIMAH (Kilian et al., Lancet Public Health 2025, DOI 10.1016/S2468-2667(25)00165-3).

IMPLEMENTACIÓN ACTUAL
- El estado se asigna según la recencia del consumo:
  - abstinente de por vida: nunca bebió;
  - exbebedor: el último trago fue hace más de 30 días (esto junta a quienes bebieron hace 1-12 meses con quienes bebieron hace más de 12 meses);
  - bebedor actual: bebió en los últimos 30 días.
  Se eligió así para mantener la comparabilidad con un estudio chileno previo que usó el mapeo de InterMAHP.
- Ejemplos de RR_fd: cirrosis 3,26; cáncer colorrectal en hombres 2,19; cáncer de hígado en mujeres 2,68.
- En los cánceres cuyo RR es plano en el rango de consumo observado (colorrectal, hígado, estómago, páncreas), el término de exbebedores aporta el 90-100% de la AAF. Ejemplo ilustrativo (corrida de julio de 2026, tramo 60+, antes de corregir la escala de exposición): cáncer de hígado en mujeres, 2024, AAF entre 0,006 (con RR_fd = 1) y 0,436 (con RR_fd central).
- Incertidumbre: en las causas crónicas y cardiovasculares, cada iteración Monte Carlo extrae ln(RR_fd) de una normal con su varianza publicada. En lesiones, RR_fd = 1 fijo. Nuestros límites difieren hasta en 0,27 de los de un estudio chileno previo que no propagaba la varianza de RR_fd, en algunos cánceres. No hemos aislado qué parte de esa diferencia viene de RR_fd y qué parte del remuestreo de prevalencias y de la gamma.
- En 2024 la pregunta de consumo alguna vez en la vida perdió su lista de ejemplos de bebidas. Eso puede mover, solo en esa ola, la frontera entre abstinente y exbebedor.

DECISIONES Y OPCIONES
D-a [V2]: ventana que separa al exbebedor del bebedor actual.
  A. 30 días (actual).
  B. 12 meses: el grupo de 1-12 meses pasa a bebedor actual. Para su dosis se reportaría un rango: casi cero / categoría más baja de consumo / gamma completa de los bebedores de 30 días.
  C. Tres estados explícitos.
D-b [Q6]: reportar o no una sensibilidad "sick quitter" con RR_fd = 1.
D-c [Q5]: en los intervalos, propagar la varianza de RR_fd (actual), no propagarla, o reportar ambas, una como sensibilidad.

PREGUNTAS
Q1 [V2]. En los meta-análisis que sostienen los RR de exbebedores de OMS 2024/GSRAHTSUD y de InterMAHP, ¿cómo se define al exbebedor (más de 12 meses sin beber, alguna vez bebió, otra) y al bebedor actual (últimos 12 meses u otra) para cada causa? Causas: cirrosis; cánceres de hígado, colorrectal, mama, cavidad oral/faringe, laringe y esófago; IHD; ACV isquémico; diabetes tipo 2. Cita página o tabla.
Q2 [V2]. ¿Qué recomiendan las guías de AAF (OMS, InterMAHP, GBD) cuando la encuesta solo permite separar "30 días" de "más de 30 días"? ¿Hay precedentes de mapear ventanas distintas?
Q3 [Q6]. ¿Qué evidencia hay sobre el sesgo "sick quitter" y la mala clasificación de exbebedores y abstinentes? Por ejemplo, Rehm et al. 2008 sobre la inestabilidad de la abstinencia de por vida autorreportada, y trabajos de Stockwell, Naimi o Fillmore. ¿Hay práctica publicada de reportar una sensibilidad con RR_fd = 1?
Q4 [Q5]. ¿Los intervalos de AAF que publican OMS, InterMAHP y GBD propagan la varianza de RR_fd? ¿Dónde y cómo lo documentan?
Q5 [V2]. Chile: ¿qué prevalencias de consumo de alcohol en el último año y en el último mes publicó SENDA para cada ola 2012-2024 del Estudio Nacional de Drogas en Población General? Indica el rango etario (12-64 o 12-65) y la tabla o página del informe. La diferencia entre ambas dimensiona el grupo de 1-12 meses. Es un dato descriptivo, no evidencia de efecto.

CANDIDATOS A VERIFICAR PRIMERO (confirma DOI, título y año; si no coinciden o no tratan el tema, dilo)
- Rehm J, et al. 2008, American Journal of Epidemiology (estabilidad de la abstinencia de por vida autorreportada).
- Sherk A, et al. 2017, InterMAHP User Guide (definiciones de exbebedor y RR_fd).
- WHO 2024, Global status report on alcohol and health and treatment of substance use disorders (anexo de métodos y RR).
- Shield K, et al. 2025, Lancet Public Health, DOI 10.1016/S2468-2667(25)00174-4 (y su apéndice).
- Kilian C, et al. 2025, Lancet Public Health, DOI 10.1016/S2468-2667(25)00165-3; SIMAH release 0.1.1, DOI 10.5281/zenodo.15641639.
- Meta-análisis de RR de exbebedores para cáncer: identifícalos tú; no supongas cuáles son.

BÚSQUEDA
En inglés y español: PubMed/MEDLINE, Scopus/Web of Science, Google Scholar, SciELO, LILACS, WHO IRIS, documentación de InterMAHP, apéndices del GBD, informes del Observatorio Chileno de Drogas (SENDA).
Términos de ejemplo: "former drinkers" definition "relative risk" meta-analysis; "sick quitter" alcohol bias; "lifetime abstainers" reliability; "alcohol-attributable fraction" "former drinkers" uncertainty; "exbebedores" alcohol Chile; "prevalencia último año" alcohol SENDA.

REGLAS DE EVIDENCIA (obligatorias)
1. Toda afirmación sustantiva lleva una cita verificable (DOI, PMID o URL estable) y, cuando exista, página/tabla/ecuación/figura. Sin cita, no se incluye.
2. Si no encuentras algo, escribe "NO ENCONTRADO" y describe qué buscaste. No adivines DOIs, cifras, años ni autores.
3. Etiqueta cada afirmación como [TEXTO] (lo dice la fuente; agrega una cita textual de menos de 30 palabras cuando puedas) o [INFERENCIA] (deducción tuya).
4. Verifica primero los candidatos. Si un DOI no coincide, la referencia no existe o no trata lo que te digo, repórtalo; no la reemplaces en silencio.
5. Cita solo lo que leíste. Si leíste solo el resumen, marca "(solo resumen)".
6. Para cada número indica población, unidad, denominador y período, y si los autores lo ESTIMARON o lo ASUMIERON.
7. No promedies fuentes discordantes: preséntalas por separado y explica la discrepancia.
8. Un resultado no significativo no equivale a "sin efecto".
9. Los informes de gobierno, OMS o SENDA sirven para definiciones, métodos y series de datos, no como evidencia de efecto causal.
10. Separa (a) evidencia chilena, (b) latinoamericana, (c) evidencia empírica internacional y (d) convenciones o supuestos de modelos (OMS, InterMAHP, GBD, Sheffield, SIMAH).
11. Sin relleno: cada referencia debe sostener una fila concreta de una tabla. Máximo unas 25 referencias.
12. Prioriza la versión más reciente de cada guía y señala las versiones que se contradicen.
Inclusión: estudios primarios, revisiones sistemáticas y meta-análisis, guías y documentación técnica de métodos, informes oficiales (solo para datos descriptivos).
Exclusión: blogs, prensa y preprints sin revisión (salvo que no haya alternativa; en ese caso, márcalos).

FORMATO DE RETORNO (en español, salvo los párrafos de métodos y el BibTeX)
0. Primera línea: "KIMI-P2 | fecha de búsqueda | n referencias leídas a texto completo / n solo resumen".
1. Veredicto por opción para D-a, D-b y D-c. Tabla: Decisión [ID] | Opción | Apoyo (fuerte/moderado/débil/ninguno/contrario) | Referencias clave | Por qué.
1b. Tabla de parámetros: ID registro | Parámetro/decisión | Valor u opción | Fuente (DOI + página/tabla) | Estimado/Asumido | Transportabilidad a Chile (alta/media/baja + por qué).
2. Respuesta a cada pregunta (Q1...Q5), de 150 palabras como máximo cada una, con citas, [TEXTO]/[INFERENCIA] y "NO ENCONTRADO" cuando corresponda. En Q1 agrega una tabla: Causa | Fuente del RR_fd | Definición de exbebedor | Definición de bebedor actual | Página/tabla.
3. Tabla de evidencia: Referencia | DOI/PMID/URL | Diseño/población | Qué sostiene | Números (página/tabla, unidad, denominador, período; estimado vs asumido) | Transportabilidad a Chile | Calidad/limitaciones.
4. Evidencia chilena y latinoamericana en una sección aparte, aunque quede vacía. Incluye las prevalencias SENDA de último año y último mes por ola, si las encuentras.
5. Recomendación por decisión: opción, fuerza (alta/media/baja), qué la cambiaría y qué limitación hay que declarar.
6. Párrafos de métodos en inglés: uno por opción viable (2 como máximo, de 100-150 palabras cada uno), con citas (Autor Año). No afirmes nada que no esté en la tabla de evidencia ni describas nuestra implementación más allá de lo dicho en IMPLEMENTACIÓN ACTUAL.
7. BibTeX de las referencias citadas en los puntos 3 y 6, con campo doi o url. No inventes campos.
8. Lista de "NO ENCONTRADO / NO VERIFICADO" y de las discrepancias de DOI.
```

---

## P3: Medición del HED, ítems faltantes y correspondencia con los RR de consumo episódico. Ola 1

```text
Necesito una investigación profunda y verificable para justificar decisiones metodológicas concretas sobre el consumo episódico excesivo (HED) y los ítems faltantes en un estudio de mortalidad atribuible al alcohol en Chile. Responde a las opciones planteadas.

CONTEXTO (es el marco; no lo investigues)
Proyecto FONDECYT 1240138 (Chile). Estimamos fracciones atribuibles al alcohol (AAF), muertes atribuibles y años de vida perdidos en la población de 15-65 años entre 2012 y 2024. También estimamos fracciones de impacto potencial (PIF) para escenarios que reducen el volumen y/o la prevalencia de HED.
- Exposición: Estudio Nacional de Drogas en Población General de SENDA (ENPG). Hogares urbanos, olas bienales 2012-2024, edades 15-65.
- RR: funciones implementadas a partir del informe OMS 2024 GSRAHTSUD, en la forma canónica de InterMAHP (crónicas de 2024; IHD, ACV isquémico y lesiones de 2018, compartidas con InterMAHP 2018).
- Etapa siguiente: microsimulación tipo SIMAH (Kilian et al., Lancet Public Health 2025, DOI 10.1016/S2468-2667(25)00165-3).

IMPLEMENTACIÓN ACTUAL
- Ítem de HED: número de ocasiones en los últimos 30 días con 5 o más tragos (hombres) o 4 o más (mujeres), según la redacción del cuestionario. Se usa en todas las olas desde 2012; no se usa el ítem 3 del AUDIT (6 o más tragos).
- HED = al menos una ocasión. La prevalencia de HED se calcula entre bebedores actuales (30 días), ponderada.
- Los códigos de no respuesta (88/99) pasan a faltante y se EXCLUYEN. El conteo de HED faltante deja faltante también el volumen y la categoría de consumo. Por eso ese bebedor sale de tres lugares: la prevalencia de HED, las distribuciones de volumen (con y sin HED) y el denominador de las prevalencias de abstinentes y exbebedores. La prevalencia de bebedores actuales queda así subestimada en ~3-4% relativo (estimación preliminar, 2024). Lo mismo ocurre cuando falta la cantidad habitual.
- Atención: recodificar solo el indicador HED (faltante = 0) no cambia nada, porque esas filas ya salieron por el volumen. Cualquier corrección tiene que hacerse en el conteo de origen o tratar volumen y HED por separado.
- Con la exclusión, nuestro HED entre bebedores queda 3-6 puntos por encima de la serie publicada por SENDA de "embriaguez" entre bebedores: 52,1 / 43,7 / 51,1 / 56,3 / 50,2 / 50,7 / 47,2 para 2012, 2014, ..., 2024. Suponemos (sin haberlo verificado) que SENDA cuenta el faltante como "no". Si lo contamos como "no", la brecha baja a 1-2 puntos.
- Volumen por frecuencia-cantidad graduada: (días de consumo − ocasiones de HED) × valor de la cantidad habitual (pregunta AUDIT-2), más ocasiones de HED × 5 tragos (hombres) o × 4 (mujeres). Todo se multiplica por 12 g y se anualiza.
  - La resta mezcla días con episodios: en ~6,6% de los bebedores las ocasiones de HED superan los días de consumo y se pierde volumen.
  - Valores de la AUDIT-2: 0-2 → 1; 3-4 → 3,5; 5-6 → 5,5. En las dos categorías superiores, el archivo derivado usa las etiquetas "7-8" y "9 o más" y les asigna 7,5 y 9, mientras que el cuestionario dice "7 a 9" y "10 o más". La correspondencia por código en el archivo derivado no está verificada, y en 2018 la escala parte en 1 en vez de 0.
- Lesiones: AAF de dos componentes (bebedores sin HED y con HED, cada uno con su función de RR). IHD y ACV isquémico: RR_HED = max(RR_sin HED, 1).
- Gamma por año × tramo × sexo × HED, ajustada por método de momentos ponderado. Integración entre 0,1 y 150 g/día.
- El volumen se recalibra al consumo per cápita registrado, así que el tamaño del trago se cancela en el volumen. Solo importa en el umbral de HED: 5 × 12 = 60 g y 4 × 12 = 48 g. Entre 2020 y 2024, los ejemplos del umbral femenino (4 tragos) repiten los volúmenes masculinos.

DECISIONES Y OPCIONES
D-a [V3a + B1, decisión conjunta]: bebedores actuales con ítems faltantes.
  A. El estado se clasifica solo con la recencia. El HED faltante se cuenta como "no" en el conteo de origen, antes de calcular el volumen. Si falta la cantidad habitual, se supone MAR dentro de la celda (se usa la gamma de los casos completos y se sube p_actual).
  B. Caso completo (actual).
  C. Reportar A y B como cotas.
  D. Imputación múltiple.
D-b [V3b]: tratar 5+/4+ tragos de ~12 g como proxy del umbral de ≥60 g por ocasión que suponen los RR de HED, o ajustarlo, o declarar la discrepancia (sobre todo los 48 g en mujeres).
D-c [Q26c / Q21]: qué valor dar a las categorías superiores de la cantidad habitual (punto medio, mínimo de la clase u otro, en particular para la categoría abierta "10 o más"), y si las ocasiones de HED se valoran en el umbral o con la cantidad real.
D-d [Q21]: modelo de distribución (gamma por momentos o por máxima verosimilitud, o razón DE/media fija) y tope de integración de 150 g/día.

PREGUNTAS
Q1 [V3b]. ¿Qué definición de HED (gramos por ocasión, frecuencia mínima, ventana) suponen los RR de HED para lesiones y para IHD/ACV de OMS, InterMAHP, WHO-EURO 2025 y Shield et al. 2025? ¿Cómo recomiendan mapear un ítem de 5+/4+ tragos en 30 días a ese umbral? ¿Hay precedentes de un umbral distinto por sexo (48 g)?
Q2 [V3b]. ¿Qué tamaño tiene el trago estándar en Chile según SENDA y, si existe, la normativa chilena? ¿Qué valor usan los estudios chilenos de AAF?
Q3 [V3a/B1]. En los insumos de AAF, ¿la convención es excluir el HED o la cantidad faltante, o tratarlos como "no" o cero? ¿Qué documentan los informes técnicos de SENDA sobre la no respuesta en "embriaguez"? ¿Hay enfoques de acotamiento publicados? ¿Hay guía explícita para clasificar el estado de consumo con la recencia aunque falten volumen o HED?
Q4 [V3]. ¿Cuál es la fuente metodológica de la AAF de lesiones en dos componentes con p_HED definido entre bebedores actuales (por ejemplo Gmel et al. 2011, Shield, anexo de lesiones de WHO-EURO 2025)? Da la fórmula con página.
Q5 [Q26c]. ¿Cómo incorporan las ocasiones de consumo excesivo los métodos de frecuencia-cantidad graduada? ¿Qué se sabe de la subestimación que produce valorarlas en el umbral? ¿Qué valor se asigna a categorías abiertas como "10 o más tragos"?
Q6 [Q21]. ¿Qué modelo de distribución recomiendan OMS, InterMAHP y Kehoe et al. 2012 (gamma, razón DE/media fija o estimada, momentos o máxima verosimilitud)? ¿Qué tope superior de integración usan (150 g/día u otro)?

CANDIDATOS A VERIFICAR PRIMERO (confirma DOI, título y año; si no coinciden o no tratan el tema, dilo)
- Gmel G, et al. 2011, BMC Medical Research Methodology, DOI 10.1186/1471-2288-11-48.
- Shield K, et al. 2025, Lancet Public Health, DOI 10.1016/S2468-2667(25)00174-4 (y su apéndice).
- WHO Regional Office for Europe 2025, anexo de lesiones atribuibles al alcohol (WHO/EURO:2025-12985-52759-82187).
- Kehoe T, et al. 2012, Population Health Metrics (PMC3352241).
- Sherk A, et al. 2017, InterMAHP User Guide.
- Informes técnicos del Estudio Nacional de Drogas en Población General de SENDA (2012-2024): metodología, cuestionario, tratamiento de la no respuesta.

BÚSQUEDA
En inglés y español: PubMed/MEDLINE, Scopus/Web of Science, Google Scholar, SciELO, LILACS, WHO IRIS, Observatorio Chileno de Drogas (SENDA).
Términos de ejemplo: "heavy episodic drinking" definition "60 g" relative risk injury; "binge drinking" "4+ women" threshold grams; "graduated quantity-frequency" binge underestimation; "alcohol-attributable fraction" injuries "heavy episodic" two-component; "consumo excesivo episódico" Chile encuesta; "trago estándar" Chile gramos.

REGLAS DE EVIDENCIA (obligatorias)
1. Toda afirmación sustantiva lleva una cita verificable (DOI, PMID o URL estable) y, cuando exista, página/tabla/ecuación/figura. Sin cita, no se incluye.
2. Si no encuentras algo, escribe "NO ENCONTRADO" y describe qué buscaste. No adivines DOIs, cifras, años ni autores.
3. Etiqueta cada afirmación como [TEXTO] (lo dice la fuente; agrega una cita textual de menos de 30 palabras cuando puedas) o [INFERENCIA] (deducción tuya).
4. Verifica primero los candidatos. Si un DOI no coincide, la referencia no existe o no trata lo que te digo, repórtalo; no la reemplaces en silencio.
5. Cita solo lo que leíste. Si leíste solo el resumen, marca "(solo resumen)".
6. Para cada número indica población, unidad, denominador y período, y si los autores lo ESTIMARON o lo ASUMIERON.
7. No promedies fuentes discordantes: preséntalas por separado y explica la discrepancia.
8. Un resultado no significativo no equivale a "sin efecto".
9. Los informes de gobierno, OMS o SENDA sirven para definiciones, métodos y series de datos, no como evidencia de efecto causal.
10. Separa (a) evidencia chilena, (b) latinoamericana, (c) evidencia empírica internacional y (d) convenciones o supuestos de modelos.
11. Sin relleno: cada referencia debe sostener una fila concreta de una tabla. Máximo unas 25 referencias.
12. No conviertas categorías AUDIT a gramos sin una fuente que haga ese puente de forma explícita.
13. Prioriza la versión más reciente de cada guía y señala las versiones que se contradicen.
Inclusión: estudios primarios, revisiones sistemáticas y meta-análisis, guías y documentación técnica de métodos, documentación técnica de encuestas.
Exclusión: blogs, prensa y preprints sin revisión (salvo que no haya alternativa; en ese caso, márcalos).

FORMATO DE RETORNO (en español, salvo los párrafos de métodos y el BibTeX)
0. Primera línea: "KIMI-P3 | fecha de búsqueda | n referencias leídas a texto completo / n solo resumen".
1. Veredicto por opción para D-a a D-d. Tabla: Decisión [ID] | Opción | Apoyo (fuerte/moderado/débil/ninguno/contrario) | Referencias clave | Por qué.
1b. Tabla de parámetros: ID registro | Parámetro/decisión | Valor u opción | Fuente (DOI + página/tabla) | Estimado/Asumido | Transportabilidad a Chile (alta/media/baja + por qué).
2. Respuesta a cada pregunta (Q1...Q6), de 150 palabras como máximo cada una, con citas, [TEXTO]/[INFERENCIA] y "NO ENCONTRADO" cuando corresponda.
3. Tabla de evidencia: Referencia | DOI/PMID/URL | Diseño/población | Qué sostiene | Números (página/tabla, unidad, denominador, período; estimado vs asumido) | Transportabilidad a Chile | Calidad/limitaciones.
4. Evidencia chilena y latinoamericana en una sección aparte, aunque quede vacía: redacción del ítem por ola, trago estándar y convención de SENDA sobre la no respuesta.
5. Recomendación por decisión: opción, fuerza (alta/media/baja), qué la cambiaría y qué limitación hay que declarar.
6. Párrafos de métodos en inglés: uno por opción viable (2 como máximo, de 100-150 palabras cada uno), con citas (Autor Año). No afirmes nada que no esté en la tabla de evidencia ni describas nuestra implementación más allá de lo dicho en IMPLEMENTACIÓN ACTUAL.
7. BibTeX de las referencias citadas en los puntos 3 y 6, con campo doi o url. No inventes campos.
8. Lista de "NO ENCONTRADO / NO VERIFICADO" y de las discrepancias de DOI.
```

---

## P4: Exposición en edades 66+ cuando la encuesta llega solo hasta los 65. Ola 1 (solo si ACC no lo decidió)

```text
Necesito una investigación profunda y verificable para justificar UNA decisión de alcance etario en un estudio de mortalidad atribuible al alcohol en Chile. Responde a las opciones planteadas.

CONTEXTO (es el marco; no lo investigues)
Proyecto FONDECYT 1240138 (Chile). Estimamos fracciones atribuibles al alcohol (AAF), muertes atribuibles, años de vida perdidos y fracciones de impacto potencial en la población de 15-65 años entre 2012 y 2024.
- Exposición: Estudio Nacional de Drogas en Población General de SENDA (ENPG). Hogares urbanos, olas bienales 2012-2024. No hay nadie mayor de 65, y la edad 65 parece acumular respuestas.
- Mortalidad: DEIS-MINSAL (CIE-10, nacional).
- RR: funciones del informe OMS 2024 GSRAHTSUD (forma canónica de InterMAHP), algunas con bandas etarias 15-34 / 35-64 / 65+.
- Buena parte de la mortalidad crónica atribuible ocurre después de los 65 años, así que el alcance etario mueve mucho los totales.

DECISIÓN Y OPCIONES
D-a [D1]: exposición para 66-76 años.
  A. Mantener el alcance 15-65 y declararlo como limitación.
  B. Puente de razones por sexo: p_ENPG(66-70) = p_ENPG(60-65) × p_EPS(66-70) / p_EPS(60-65), usando la Encuesta de Protección Social (EPS). La EPS sí cubre a mayores, pero no mide HED ni consumo alguna vez en la vida.
  C. Usar otra encuesta chilena que cubra a mayores de 65 (por ejemplo, la Encuesta Nacional de Salud).
  D. Otro método publicado.

PREGUNTAS
Q1 [D1]. Cuando la encuesta llega solo hasta los 64 o 65 años, ¿cómo asignan la exposición a las personas de 65+ los estudios nacionales de AAF (InterMAHP, Shield 2020 y 2025, OMS)? ¿Extrapolan, arrastran el último grupo o usan encuestas externas? Cita página.
Q2 [D1]. ¿Qué gradientes etarios del consumo en adultos de 50+ reportan Calvo et al. 2020 (Drug and Alcohol Dependence, 21 países) y Calvo et al. 2021 (Addiction, 22 países)? ¿Incluyen a Chile y con qué encuesta? ¿Sostienen un puente de razones 60-65 → 66-76?
Q3 [D1]. ¿Hay estudios publicados que usen los ítems de alcohol de la Encuesta de Protección Social de Chile, o de la Encuesta Nacional de Salud 2009-2010 / 2016-2017, para describir el consumo en mayores de 65? ¿Qué prevalencias reportan por edad y sexo?
Q4 [D1]. ¿Hay precedentes de puentes de razones entre encuestas con instrumentos distintos para estimar la exposición al alcohol? ¿Qué supuestos y sesgos se reconocen?

CANDIDATOS A VERIFICAR PRIMERO (confirma DOI, título y año; si no coinciden o no tratan el tema, dilo)
- Calvo E, et al. 2020, Drug and Alcohol Dependence, DOI 10.1016/j.drugalcdep.2020.108219.
- Calvo E, et al. 2021, Addiction, DOI 10.1111/add.15292.
- Shield K, et al. 2020, Lancet Public Health, DOI 10.1016/S2468-2667(19)30231-2.
- Shield K, et al. 2025, Lancet Public Health, DOI 10.1016/S2468-2667(25)00174-4.
- Sherk A, et al. 2017, InterMAHP User Guide.
- Documentación de la Encuesta Nacional de Salud de Chile y de la Encuesta de Protección Social (módulos de alcohol).

BÚSQUEDA
En inglés y español: PubMed/MEDLINE, Scopus/Web of Science, Google Scholar, SciELO, LILACS, WHO IRIS, sitios del MINSAL (ENS) y de la Subsecretaría de Previsión Social (EPS).
Términos de ejemplo: "alcohol-attributable" "older adults" survey extrapolation "65 and over"; alcohol consumption older adults Chile; "Encuesta de Protección Social" alcohol; "Encuesta Nacional de Salud" alcohol adultos mayores.

REGLAS DE EVIDENCIA (obligatorias)
1. Toda afirmación sustantiva lleva una cita verificable (DOI, PMID o URL estable) y, cuando exista, página/tabla/ecuación/figura. Sin cita, no se incluye.
2. Si no encuentras algo, escribe "NO ENCONTRADO" y describe qué buscaste. No adivines DOIs, cifras, años ni autores.
3. Etiqueta cada afirmación como [TEXTO] (lo dice la fuente; agrega una cita textual de menos de 30 palabras cuando puedas) o [INFERENCIA] (deducción tuya).
4. Verifica primero los candidatos. Si un DOI no coincide, la referencia no existe o no trata lo que te digo, repórtalo; no la reemplaces en silencio.
5. Cita solo lo que leíste. Si leíste solo el resumen, marca "(solo resumen)".
6. Para cada número indica población, unidad, denominador y período, y si los autores lo ESTIMARON o lo ASUMIERON.
7. No promedies fuentes discordantes: preséntalas por separado y explica la discrepancia.
8. Un resultado no significativo no equivale a "sin efecto".
9. Los informes de gobierno u OMS sirven para definiciones, métodos y series de datos, no como evidencia de efecto causal.
10. Separa (a) evidencia chilena, (b) latinoamericana, (c) evidencia empírica internacional y (d) convenciones de modelos.
11. Sin relleno: cada referencia debe sostener una fila concreta de una tabla. Máximo unas 15 referencias.
12. Prioriza la versión más reciente de cada documento y señala las versiones que se contradicen.
Inclusión: estudios primarios, revisiones sistemáticas, documentación técnica oficial, guías de métodos.
Exclusión: blogs, prensa y preprints sin revisión (salvo que no haya alternativa; en ese caso, márcalos).

FORMATO DE RETORNO (en español, salvo los párrafos de métodos y el BibTeX)
0. Primera línea: "KIMI-P4 | fecha de búsqueda | n referencias leídas a texto completo / n solo resumen".
1. Veredicto por opción. Tabla: Decisión [ID] | Opción | Apoyo (fuerte/moderado/débil/ninguno/contrario) | Referencias clave | Por qué.
1b. Tabla de parámetros: ID registro | Parámetro/decisión | Valor u opción | Fuente (DOI + página/tabla) | Estimado/Asumido | Transportabilidad a Chile (alta/media/baja + por qué).
2. Respuesta a cada pregunta (Q1...Q4), de 150 palabras como máximo cada una, con citas, [TEXTO]/[INFERENCIA] y "NO ENCONTRADO" cuando corresponda.
3. Tabla de evidencia: Referencia | DOI/PMID/URL | Diseño/población | Qué sostiene | Números (página/tabla, unidad, denominador, período; estimado vs asumido) | Transportabilidad a Chile | Calidad/limitaciones.
4. Evidencia chilena y latinoamericana en una sección aparte, aunque quede vacía.
5. Recomendación: opción, fuerza (alta/media/baja), qué la cambiaría y qué limitación hay que declarar.
6. Párrafos de métodos y limitaciones en inglés: uno por opción viable (2 como máximo, de 100-150 palabras cada uno), con citas (Autor Año), sin afirmar nada que no esté en la tabla de evidencia.
7. BibTeX de las referencias citadas en los puntos 3 y 6, con campo doi o url. No inventes campos.
8. Lista de "NO ENCONTRADO / NO VERIFICADO" y de las discrepancias de DOI.
```

---

## P5: Métodos de contrafactuales PIF (causas AAF=1, salida de HED, latencia, agregación). Ola 2

```text
Necesito una investigación profunda y verificable sobre métodos para calcular fracciones de impacto potencial (PIF) y muertes evitables por alcohol en escenarios de política. Es para justificar decisiones concretas en un estudio chileno. Responde a las opciones planteadas.

CONTEXTO (es el marco; no lo investigues)
Proyecto FONDECYT 1240138 (Chile). Estimamos fracciones atribuibles al alcohol (AAF), muertes atribuibles y años de vida perdidos en la población de 15-65 años entre 2012 y 2024.
- Exposición: encuesta nacional de drogas de SENDA (ENPG).
- Mortalidad: DEIS-MINSAL (CIE-10).
- RR: funciones del informe OMS 2024 GSRAHTSUD en la forma canónica de InterMAHP.
Sobre esa base calculamos PIF para escenarios estilizados de política. El paso siguiente es una microsimulación con la arquitectura de SIMAH (Kilian et al., Lancet Public Health 2025, DOI 10.1016/S2468-2667(25)00165-3): precio → participación → elasticidad por bebida → consumo continuo → recodificación → riesgo.

IMPLEMENTACIÓN ACTUAL
- PIF para 23 causas parcialmente atribuibles, en 16 escenarios: reducciones relativas del volumen, reducciones de la prevalencia de HED y combinaciones. Se calculan por 7 olas × 4 tramos etarios × sexo.
- Contrafactual de volumen: se evalúa el RR en x × factor de cambio, manteniendo fija la densidad gamma ("desplazamiento de la curva de riesgo").
- El término de exbebedores (p_exbebedor × RR_fd) no cambia en los contrafactuales. Por eso, eliminar todo el consumo no da PIF = AAF. La identidad que validamos es PIF = (AAF − AAF_cf) / (1 − AAF_cf).
- Muertes evitables = muertes TOTALES de la causa × PIF, en estado estacionario y sin rezagos. Las PIF agregadas se calculan como suma(evitables) / suma(totales); no se promedian entre causas.
- Hay 226 celdas con PIF negativa en causas con curva en J (IHD, ACV isquémico, diabetes tipo 2 en mujeres). Se conservan con su signo.
- Salida de HED: quien deja de tener HED puede, con lambda = 0 (conservador), conservar su distribución de volumen con el riesgo de no-HED; con lambda = 1 (redistribución usada por Ruiz-Tagle et al.), pasa a la distribución de volumen de los bebedores sin HED. rho = 1 está fijo. Con lambda = 1, reducir 50% la prevalencia de HED implica un cambio de −26,5% en el consumo medio, aunque la palanca de volumen sea 0%. En IHD y ACV el barrido de lambda/rho no da un rango unilateral, por la curva en J. Ambos valores de lambda ya están calculados.
- Causas 100% atribuibles (AAF = 1): F10, G31.2, G62.1, G72.1, Q86.0, I42.6, K86.0, K29.2, X45, X65, Y15. Suman 1.423 muertes en las 7 olas (145 en 2024). Entran en las muertes atribuibles, pero NO en la PIF, así que los totales evitables cubren solo las 23 causas con RR.

DECISIONES Y OPCIONES
D-a [Q2]: causas AAF = 1 en la PIF.
  A. Declarar la PIF como "parcial, solo causas con RR".
  B. Submodelo, por ejemplo escalar según el cambio contrafactual del volumen per cápita, de la prevalencia de HED o de la de bebedores intensos.
  C. Otro método publicado.
D-b [Q7]: lambda principal. 0, 1, o reportar ambos mostrando el consumo implícito. Es una elección de reporte.
D-c [Q25] (para la microsimulación; no bloquea este cierre): quienes dejan de beber por la política, ¿pasan a exbebedores (con RR_fd) o a abstinentes? ¿Debe moverse el término de exbebedores en el contrafactual?
D-d: estado estacionario o muertes evitables con rezago por causa.
D-e [Q4, solo agregación]: cómo agregar y presentar las PIF negativas dentro de totales de muertes evitables.

PREGUNTAS
Q1 [Q2]. ¿Cómo calculan los cambios contrafactuales en condiciones 100% atribuibles InterMAHP, GBD, el Sheffield Alcohol Policy Model (SAPM) y SIMAH? ¿Con qué métrica de exposición (volumen per cápita, HED, prevalencia de trastorno por uso) y con qué forma funcional? Da página o ecuación.
Q2. ¿Desplazar la curva de riesgo (RR evaluado en x × factor, con densidad fija) equivale a reescalar la distribución de exposición? ¿Cuál es el procedimiento estándar? ¿Qué pasa con los límites de integración?
Q3 [Q7]. ¿Qué suponen los modelos publicados sobre quienes dejan el HED: siguen bebiendo con el volumen de los no-HED, conservan su volumen o dejan de beber? ¿Hay una fuente publicada y revisada por pares de la redistribución de Ruiz-Tagle?
Q4 [Q25]. ¿Cómo tratan los modelos de política el exceso de riesgo de los exbebedores y a quienes dejan de beber por la política?
Q5 [Q4]. ¿Cómo agregan y comunican las PIF negativas (curvas en J) las publicaciones de política dentro de los totales evitables?
Q6. ¿Las muertes evitables deben calcularse en estado estacionario o con rezago temporal (cáncer y cirrosis con latencia, lesiones inmediatas)? ¿Qué estructuras de rezago usan SAPM, SIMAH y otros modelos?
Q7. ¿El denominador aceptado de las muertes evitables es muertes totales de la causa × PIF? ¿Algún texto metodológico advierte contra aplicar la AAF sobre la PIF?

CANDIDATOS A VERIFICAR PRIMERO (confirma DOI, título y año; si no coinciden o no tratan el tema, dilo)
- Kilian C, et al. 2025, Lancet Public Health, DOI 10.1016/S2468-2667(25)00165-3 (y su apéndice); SIMAH release 0.1.1, DOI 10.5281/zenodo.15641639.
- Artículo o documento técnico de métodos del SAPM que define los rezagos temporales y el tratamiento de las condiciones 100% atribuibles: identifícalo y verifícalo tú (por ejemplo, Purshouse et al. 2010, Lancet, o trabajos de Meier o Holmes).
- Purshouse RC, et al. 2013, Alcohol and Alcoholism 48(2):180-8, DOI 10.1093/alcalc/ags103. Es el modelo SAPM de intervenciones breves en atención primaria; úsalo solo si documenta rezagos o condiciones 100% atribuibles.
- Sherk A, et al. 2017, InterMAHP User Guide.
- Ruiz-Tagle et al. 2026, Public Health in Practice, DOI 10.1016/j.puhip.2026.100798, y cualquier trabajo publicado de Ruiz-Tagle sobre PIF de HED y lesiones en Chile.

BÚSQUEDA
En inglés y español: PubMed/MEDLINE, Scopus/Web of Science, Google Scholar, SciELO, LILACS, WHO IRIS, Sheffield Alcohol Research Group, documentación de InterMAHP, Zenodo/GitHub de SIMAH.
Términos de ejemplo: "potential impact fraction" alcohol policy counterfactual; "wholly attributable" alcohol "potential impact fraction"; "Sheffield Alcohol Policy Model" "time lag" mortality; "heavy episodic drinking" reduction counterfactual assumption; "fracción de impacto potencial" alcohol Chile.

REGLAS DE EVIDENCIA (obligatorias)
1. Toda afirmación sustantiva lleva una cita verificable (DOI, PMID o URL estable) y, cuando exista, página/tabla/ecuación/figura. Sin cita, no se incluye.
2. Si no encuentras algo, escribe "NO ENCONTRADO" y describe qué buscaste. No adivines DOIs, cifras, años ni autores.
3. Etiqueta cada afirmación como [TEXTO] (lo dice la fuente; agrega una cita textual de menos de 30 palabras cuando puedas) o [INFERENCIA] (deducción tuya).
4. Verifica primero los candidatos. Si un DOI no coincide, la referencia no existe o no trata lo que te digo, repórtalo; no la reemplaces en silencio.
5. Cita solo lo que leíste. Si leíste solo el resumen, marca "(solo resumen)".
6. Para cada número indica población, unidad, denominador y período, y si los autores lo ESTIMARON o lo ASUMIERON.
7. No promedies fuentes discordantes: preséntalas por separado y explica la discrepancia.
8. Un resultado no significativo no equivale a "sin efecto".
9. Los informes de gobierno u OMS sirven para definiciones y métodos, no como evidencia de eficacia de una política.
10. Separa (a) evidencia chilena, (b) latinoamericana, (c) evidencia empírica internacional y (d) convenciones o supuestos de modelos (SAPM, InterMAHP, GBD, SIMAH), que no son evidencia empírica.
11. Sin relleno: cada referencia debe sostener una fila concreta de una tabla. Máximo unas 25 referencias.
12. Prioriza la versión más reciente de cada modelo y señala las versiones que se contradicen.
Inclusión: estudios primarios, revisiones sistemáticas, documentación técnica de modelos, guías de métodos.
Exclusión: blogs, prensa y preprints sin revisión (salvo que no haya alternativa; en ese caso, márcalos).

FORMATO DE RETORNO (en español, salvo los párrafos de métodos y el BibTeX)
0. Primera línea: "KIMI-P5 | fecha de búsqueda | n referencias leídas a texto completo / n solo resumen".
1. Veredicto por opción para D-a a D-e. Tabla: Decisión [ID] | Opción | Apoyo (fuerte/moderado/débil/ninguno/contrario) | Referencias clave | Por qué.
1b. Tabla de parámetros: ID registro | Parámetro/decisión | Valor u opción | Fuente (DOI + página/tabla) | Estimado/Asumido | Transportabilidad a Chile (alta/media/baja + por qué).
2. Respuesta a cada pregunta (Q1...Q7), de 150 palabras como máximo cada una, con citas, [TEXTO]/[INFERENCIA] y "NO ENCONTRADO" cuando corresponda. En Q1 agrega una tabla: Modelo | Tratamiento de AAF=1 | Métrica de exposición | Fórmula | Página.
3. Tabla de evidencia: Referencia | DOI/PMID/URL | Diseño/población | Qué sostiene | Números (página/tabla, unidad, denominador, período; estimado vs asumido) | Transportabilidad a Chile | Calidad/limitaciones.
4. Evidencia chilena y latinoamericana en una sección aparte, aunque quede vacía.
5. Recomendación por decisión: opción, fuerza (alta/media/baja), qué la cambiaría y qué limitación hay que declarar.
6. Párrafos de métodos en inglés: uno por opción viable de D-a y de D-b (2 como máximo por decisión, de 100-150 palabras cada uno), con citas (Autor Año). No afirmes nada que no esté en la tabla de evidencia ni describas nuestra implementación más allá de lo dicho en IMPLEMENTACIÓN ACTUAL.
7. BibTeX de las referencias citadas en los puntos 3 y 6, con campo doi o url. No inventes campos.
8. Lista de "NO ENCONTRADO / NO VERIFICADO" y de las discrepancias de DOI.
```

---

## P6: Marco urbano, comparabilidad entre olas, DEIS 2024 preliminar y precedentes CIE-10. Ola 2

```text
Necesito una investigación profunda y verificable para justificar decisiones de ALCANCE y COMPARABILIDAD en un estudio de mortalidad atribuible al alcohol en Chile. Responde a las opciones planteadas.

CONTEXTO (es el marco; no lo investigues)
Proyecto FONDECYT 1240138 (Chile). Estimamos fracciones atribuibles al alcohol (AAF), muertes atribuibles, años de vida perdidos y fracciones de impacto potencial en la población de 15-65 años entre 2012 y 2024.
- Exposición: Estudio Nacional de Drogas en Población General de SENDA (ENPG). Olas bienales 2012-2024 de hogares URBANOS, unas 109 comunas (cerca del 70% de la población).
- Mortalidad: defunciones DEIS-MINSAL (CIE-10, nacional).
- RR: funciones del informe OMS 2024 GSRAHTSUD (forma canónica de InterMAHP).
- El mapa de causas sigue la Tabla S6 de Shield et al. 2025 (Lancet Public Health, DOI 10.1016/S2468-2667(25)00174-4).

PROBLEMAS Y OPCIONES
D-a [D2]: la exposición urbana se aplica a las muertes de todo el país. Eso supone que se bebe igual en zonas rurales que urbanas, y deja fuera a personas en situación de calle o institucionalizadas. La cobertura regional va de 57,6% a 99,4%. Opciones: declararlo como limitación, acotarlo con otras encuestas, u otro método publicado.
D-b [D3 / Q20]: comparabilidad entre olas.
  - 2018: rediseño del cuestionario.
  - 2020: pandemia; modo telefónico y presencial, sin autoaplicación ni tarjetas.
  - 2022: nuevo marco muestral y pesos calibrados al Censo 2017, con un salto de +65,7% en el total ponderado.
  - 2024: la pregunta de consumo alguna vez en la vida perdió los ejemplos de bebidas.
  - Las ventanas de recuerdo de 30 días excluyen meses festivos (Fiestas Patrias, Año Nuevo) de forma distinta según la ola.
  - La tasa de respuesta bajó de ~62-70% a 41,8% (2020) y 45,0% (2022).
  Opciones para 2020: marcarla en las tendencias, excluirla de las tendencias, o usar un indicador de ola con una sensibilidad sin 2020.
D-c [B14]: DEIS 2024. Hipótesis sin verificar: los años 2012-2023 vienen de la base de "cifras oficiales", y 2024 de una base semanal 2024-2026 que sería preliminar, cuya codificación de causa básica podría cambiar. Descomposición preliminar e ilustrativa, hecha antes de corregir la escala de exposición: entre 2022 y 2024, en hombres de 15-65 años, las muertes DEIS por cirrosis bajaron ~40%, las de tránsito ~29% y las de VIH ~40%, y las de infecciones respiratorias bajas casi se duplicaron. Una parte importante de la caída de la tasa estandarizada atribuible en hombres (45,9 → 34,4 por 100.000) vendría del número de muertes y no de la AAF. Opciones: reportar 2024 como provisorio, excluirlo de las tendencias o esperar las cifras oficiales. (Los posibles problemas de código de la base los revisamos nosotros localmente; no los investigues.)
D-d [Q12, solo precedentes]: ¿hay precedentes publicados para incluir o excluir las lesiones X30-X39 y W47-W48, y el cáncer de nasofaringe C11, en estudios de AAF? (El contenido exacto de la Tabla S6 lo revisamos nosotros; no lo transcribas.)

PREGUNTAS
Q1 [D2]. ¿Qué evidencia hay sobre diferencias urbano-rurales en el consumo de alcohol en Chile (Encuesta Nacional de Salud, otras) y sobre la subcobertura de bebedores intensos en encuestas de hogares? ¿Cómo justifican otros estudios aplicar exposición urbana a la mortalidad nacional?
Q2 [D3/Q20]. ¿Qué documentan los informes técnicos de SENDA sobre el rediseño de 2018, el modo de 2020, el marco y la calibración de 2022 y el cambio de redacción de 2024?
Q3 [D3/Q20]. ¿Qué evidencia hay sobre el efecto de excluir meses festivos de la ventana de recuerdo y del cambio de modo (autoaplicado vs entrevistador, telefónico) sobre la prevalencia de consumo y de HED en 30 días y sobre el volumen reportado? ¿Cómo se recomienda tratar estas rupturas en tendencias de varias olas?
Q4 [B14]. ¿Cómo distingue DEIS-MINSAL las cifras oficiales de las bases preliminares o semanales? ¿Cuándo se cierran y publican las cifras oficiales de un año? ¿Qué se sabe de las revisiones de la causa básica entre la base preliminar y la oficial (por ejemplo, muertes pendientes de autopsia del Servicio Médico Legal, códigos R99 o de intención no determinada)?
Q5 [Q12]. ¿Hay estudios de AAF o documentos de métodos (OMS, GBD, InterMAHP, Shield) que discutan explícitamente la inclusión de X30-X39 (fuerzas de la naturaleza), W47-W48 o C11 en las categorías atribuibles al alcohol?

CANDIDATOS A VERIFICAR PRIMERO (confirma DOI, título y año; si no coinciden o no tratan el tema, dilo)
- Shield K, et al. 2025, Lancet Public Health, DOI 10.1016/S2468-2667(25)00174-4.
- Shield K, et al. 2020, Lancet Public Health, DOI 10.1016/S2468-2667(19)30231-2.
- Informes metodológicos del Estudio Nacional de Drogas en Población General (SENDA, Observatorio Chileno de Drogas), olas 2012-2024.
- Documentación de las bases de defunciones de DEIS-MINSAL (cifras oficiales vs bases preliminares).
- Encuesta Nacional de Salud de Chile 2016-2017 (módulo de alcohol, desagregación urbano-rural).

BÚSQUEDA
En inglés y español: PubMed/MEDLINE, Scopus/Web of Science, Google Scholar, SciELO, LILACS, WHO IRIS, sitios de SENDA, DEIS-MINSAL, INE y MINSAL (ENS).
Términos de ejemplo: "urban rural" alcohol consumption Chile; "consumo de alcohol" rural urbano Chile "Encuesta Nacional de Salud"; "mode effect" alcohol survey telephone; "recall period" holiday alcohol survey; "defunciones" "cifras oficiales" DEIS preliminar; "causa básica de muerte" revisión Chile.

REGLAS DE EVIDENCIA (obligatorias)
1. Toda afirmación sustantiva lleva una cita verificable (DOI, PMID o URL estable) y, cuando exista, página/tabla/ecuación/figura. Sin cita, no se incluye.
2. Si no encuentras algo, escribe "NO ENCONTRADO" y describe qué buscaste. No adivines DOIs, cifras, años ni autores.
3. Etiqueta cada afirmación como [TEXTO] (lo dice la fuente; agrega una cita textual de menos de 30 palabras cuando puedas) o [INFERENCIA] (deducción tuya).
4. Verifica primero los candidatos. Si un DOI no coincide, la referencia no existe o no trata lo que te digo, repórtalo; no la reemplaces en silencio.
5. Cita solo lo que leíste. Si leíste solo el resumen, marca "(solo resumen)".
6. Para cada número indica población, unidad, denominador y período, y si los autores lo ESTIMARON o lo ASUMIERON.
7. No promedies fuentes discordantes: preséntalas por separado y explica la discrepancia.
8. Un resultado no significativo no equivale a "sin efecto".
9. Los informes de gobierno (SENDA, DEIS, INE, MINSAL, OMS) sirven para definiciones, métodos, calendarios y series de datos, no como evidencia de efecto causal.
10. Separa (a) evidencia chilena, (b) latinoamericana, (c) evidencia empírica internacional y (d) convenciones de modelos.
11. Sin relleno: cada referencia debe sostener una fila concreta de una tabla. Máximo unas 25 referencias.
12. Prioriza la versión más reciente de cada documento y señala las versiones que se contradicen.
13. Para bases de datos y páginas web, indica la fecha de consulta, la versión o fecha de publicación de la base y el nombre exacto del archivo o producto.
Inclusión: estudios primarios, revisiones sistemáticas, documentación técnica oficial, guías de métodos.
Exclusión: blogs, prensa y preprints sin revisión (salvo que no haya alternativa; en ese caso, márcalos).

FORMATO DE RETORNO (en español, salvo los párrafos de métodos y el BibTeX)
0. Primera línea: "KIMI-P6 | fecha de búsqueda | n referencias leídas a texto completo / n solo resumen".
1. Veredicto por opción para D-a a D-d. Tabla: Decisión [ID] | Opción | Apoyo (fuerte/moderado/débil/ninguno/contrario) | Referencias clave | Por qué.
1b. Tabla de parámetros: ID registro | Parámetro/decisión | Valor u opción | Fuente (DOI + página/tabla) | Estimado/Asumido | Transportabilidad a Chile (alta/media/baja + por qué).
2. Respuesta a cada pregunta (Q1...Q5), de 150 palabras como máximo cada una, con citas, [TEXTO]/[INFERENCIA] y "NO ENCONTRADO" cuando corresponda.
3. Tabla de evidencia: Referencia | DOI/PMID/URL | Diseño/población | Qué sostiene | Números (página/tabla, unidad, denominador, período; estimado vs asumido) | Transportabilidad a Chile | Calidad/limitaciones.
4. Evidencia chilena y latinoamericana en una sección aparte (SENDA, DEIS, ENS, INE).
5. Recomendación por decisión: opción, fuerza (alta/media/baja), qué la cambiaría y qué limitación hay que declarar.
6. Párrafos de limitaciones en inglés: uno por decisión D-a a D-c (100-150 palabras cada uno), con citas (Autor Año), sin afirmar nada que no esté en la tabla de evidencia.
7. BibTeX de las referencias citadas en los puntos 3 y 6, con campo doi o url. No inventes campos.
8. Lista de "NO ENCONTRADO / NO VERIFICADO" y de las discrepancias de DOI.
```

---

## P7: Varianza de diseño muestral e incertidumbre Monte Carlo. Ola 2

```text
Necesito una investigación profunda y verificable sobre cómo propagar la incertidumbre (diseño muestral complejo, parámetros de RR y agregación) en estimaciones Monte Carlo de fracciones atribuibles y de impacto potencial del alcohol. Es para justificar decisiones concretas en un estudio chileno. Estas decisiones afectan los intervalos, no las estimaciones puntuales.

CONTEXTO (es el marco; no lo investigues)
Proyecto FONDECYT 1240138 (Chile). Estimamos fracciones atribuibles al alcohol (AAF), muertes atribuibles y fracciones de impacto potencial (PIF) en la población de 15-65 años entre 2012 y 2024.
- Exposición: encuesta nacional de drogas de SENDA (ENPG). Hogares urbanos, olas bienales, diseño complejo con estratos, conglomerados y pesos.
- Mortalidad: DEIS-MINSAL.
- RR: funciones del informe OMS 2024 GSRAHTSUD (forma canónica de InterMAHP).
- Etapa siguiente: microsimulación tipo SIMAH (Kilian et al., Lancet Public Health 2025, DOI 10.1016/S2468-2667(25)00165-3).

IMPLEMENTACIÓN ACTUAL
- Monte Carlo con 10.000 iteraciones por celda (año × sexo × tramo etario × causa).
- Las prevalencias (abstinente, exbebedor, actual) se extraen de una Dirichlet, y p_HED de una distribución análoga. Ambas usan un n efectivo = n_eff de Kish / factor de diseño.
  - El factor de diseño es (SE_diseño / SE_Kish)^2, calculado por año × tramo × sexo × variable.
  - Se estima con estratos aproximados (región) y conglomerados (manzana o UPM).
  - En 2016 el conglomerado es la manzana sola (unos 2.000 conglomerados). Una clave reconstruida que incluya comuna, distrito y zona daría unos 2.358.
- El n_eff de Kish es 21,6-47,4% del n nominal. El factor de conglomerado residual va de 1,21 a 1,64, y algunos factores salen menores que 1 por la estratificación.
- Los parámetros de la gamma de consumo se remuestrean.
- Los coeficientes de RR se extraen de normales con las varianzas publicadas. Cuando falta la covarianza, se usa una matriz diagonal. En una fuente alternativa de IHD, con ln RR = b1·x + b2·x·ln(x) y sin covarianza publicada, los intervalos de mujeres degeneran: 231 de 420 celdas tienen límite superior de PIF > 0,5 con un punto de ~0,005.
- La ola 2020 no tiene identificadores de conglomerado. Su factor se toma de la ola 2022, que usa otro marco muestral. La alternativa es tomarlo de 2018, que usa el mismo marco.
- Agregados: parte de los agregados actuales (tasas estandarizadas, porcentajes de carga) todavía suma los límites de cada celda, lo que da una envolvente. Las tablas finales usan extracciones alineadas: misma semilla y flujo por celda, con la iteración i alineada entre celdas, sumando las extracciones. Esto supone una alineación comonótona del generador, no una covarianza empírica.
- El punto es determinista y el intervalo son percentiles Monte Carlo. El código fuerza límite inferior ≤ punto ≤ límite superior.

DECISIONES Y OPCIONES
D-a [C1]: ¿es aceptable el factor combinado Kish × conglomerado, o hay un método preferido (réplicas bootstrap con pesos, linealización)?
D-b [Q13]: factores < 1: aplicar o no un piso en 1.
D-c [C2]: ola sin conglomerados: tomar el factor de una ola del mismo marco, usar una pseudo-UPM como cota superior, o declarar los intervalos como optimistas.
D-d [Q15/B13]: intervalos de agregados: extracciones alineadas (números aleatorios comunes), envolvente de límites u otra forma de correlación.
D-e [B5]: covarianza de RR no publicada: reconstruirla, usar una fuente alternativa, reportar solo el punto o declararlo como limitación. No se trunca.
D-f [B12]: punto fuera del intervalo Monte Carlo: forzar el orden (actual), reportar la mediana Monte Carlo, o reportar el punto con una advertencia.
D-g [C1]: clave de conglomerado (manzana sola o reconstruida con comuna en 2016) y estratos (región o comuna).

PREGUNTAS
Q1 [C1]. ¿Cómo propagan la incertidumbre de las prevalencias de encuestas complejas los métodos publicados de intervalos de AAF (Gmel et al. 2011; OMS; InterMAHP; GBD)? ¿Se acepta un n efectivo con efecto de diseño en extracciones Beta/Dirichlet?
Q2 [Q13]. ¿Se recomienda poner piso en 1 a un efecto de diseño estimado menor que 1?
Q3 [C2]. ¿Cómo se aproxima el efecto de diseño de una ola sin identificadores de conglomerado?
Q4 [Q15]. ¿Son aceptables los números aleatorios comunes entre causas y estratos como base de intervalos conjuntos para sumas de muertes atribuibles o evitables? ¿Qué dicen las guías de análisis de incertidumbre en modelos (ISPOR-SMDM, Task Forces 6 y 7) sobre la correlación entre parámetros y sobre reportar el error Monte Carlo?
Q5 [B5]. ¿Cómo se maneja en AAF/PIF la covarianza de los coeficientes de RR cuando solo se publican errores estándar marginales, sobre todo con términos colineales como x y x·ln(x)?
Q6 [B12]. ¿Qué recomiendan las guías cuando la estimación puntual determinista queda fuera del intervalo de percentiles Monte Carlo (no linealidad, desigualdad de Jensen)?
Q7 [C1]. ¿Qué recomienda la literatura de encuestas sobre la definición de la UPM y de los estratos cuando el marco cambia entre olas, y sobre no mezclar variables de diseño de marcos distintos?

CANDIDATOS A VERIFICAR PRIMERO (confirma DOI, título y año; si no coinciden o no tratan el tema, dilo)
- Gmel G, et al. 2011, BMC Medical Research Methodology, DOI 10.1186/1471-2288-11-48.
- Briggs AH, et al. 2012, ISPOR-SMDM Modeling Good Research Practices Task Force-6 (incertidumbre), Value in Health 15(6).
- Eddy DM, et al. 2012, ISPOR-SMDM Task Force-7 (transparencia y validación), Value in Health 15(6).
- Kish L. (efecto de diseño y tamaño efectivo de muestra): identifica tú la referencia canónica.
- Documentación de incertidumbre de InterMAHP y del GBD para alcohol.

BÚSQUEDA
En inglés y español: PubMed/MEDLINE, Scopus/Web of Science, Google Scholar, JSTOR, Survey Methodology, Journal of Survey Statistics and Methodology, WHO IRIS, documentación del GBD e InterMAHP.
Términos de ejemplo: "alcohol-attributable fraction" "confidence interval" Monte Carlo survey design; "design effect" "effective sample size" Dirichlet prevalence; "design effect less than 1" stratification; "common random numbers" uncertainty aggregation; "probabilistic sensitivity analysis" correlated parameters; "efecto de diseño" encuesta Chile.

REGLAS DE EVIDENCIA (obligatorias)
1. Toda afirmación sustantiva lleva una cita verificable (DOI, PMID o URL estable) y, cuando exista, página/tabla/ecuación/figura. Sin cita, no se incluye.
2. Si no encuentras algo, escribe "NO ENCONTRADO" y describe qué buscaste. No adivines DOIs, cifras, años ni autores.
3. Etiqueta cada afirmación como [TEXTO] (lo dice la fuente; agrega una cita textual de menos de 30 palabras cuando puedas) o [INFERENCIA] (deducción tuya).
4. Verifica primero los candidatos. Si un DOI no coincide, la referencia no existe o no trata lo que te digo, repórtalo; no la reemplaces en silencio.
5. Cita solo lo que leíste. Si leíste solo el resumen, marca "(solo resumen)".
6. Para cada número indica población, unidad, denominador y período, y si los autores lo ESTIMARON o lo ASUMIERON.
7. No promedies fuentes discordantes: preséntalas por separado y explica la discrepancia.
8. Un resultado no significativo no equivale a "sin efecto".
9. Los informes de gobierno u OMS sirven para definiciones y métodos.
10. Separa (a) evidencia chilena, (b) latinoamericana, (c) literatura metodológica internacional y (d) convenciones de modelos.
11. Sin relleno: cada referencia debe sostener una fila concreta de una tabla. Máximo unas 20 referencias.
12. Prioriza la versión más reciente de cada guía y señala las versiones que se contradicen.
Inclusión: literatura de métodos estadísticos y de encuestas, guías de modelación, métodos publicados de intervalos de AAF.
Exclusión: blogs, prensa y preprints sin revisión (salvo que no haya alternativa; en ese caso, márcalos).

FORMATO DE RETORNO (en español, salvo los párrafos de métodos y el BibTeX)
0. Primera línea: "KIMI-P7 | fecha de búsqueda | n referencias leídas a texto completo / n solo resumen".
1. Veredicto por opción para D-a a D-g. Tabla: Decisión [ID] | Opción | Apoyo (fuerte/moderado/débil/ninguno/contrario) | Referencias clave | Por qué.
1b. Tabla de parámetros: ID registro | Parámetro/decisión | Valor u opción | Fuente (DOI + página/tabla) | Estimado/Asumido | Transportabilidad a Chile (alta/media/baja + por qué).
2. Respuesta a cada pregunta (Q1...Q7), de 150 palabras como máximo cada una, con citas, [TEXTO]/[INFERENCIA] y "NO ENCONTRADO" cuando corresponda.
3. Tabla de evidencia: Referencia | DOI/PMID/URL | Diseño/población | Qué sostiene | Números (página/tabla, unidad, denominador, período; estimado vs asumido) | Transportabilidad a Chile | Calidad/limitaciones.
4. Evidencia chilena y latinoamericana en una sección aparte (efectos de diseño de encuestas chilenas, si existen).
5. Recomendación por decisión: opción, fuerza (alta/media/baja), qué la cambiaría y qué limitación hay que declarar.
6. Párrafos de métodos en inglés: uno por opción viable de D-a y de D-d (2 como máximo por decisión, de 100-150 palabras cada uno), con citas (Autor Año), sin afirmar nada que no esté en la tabla de evidencia.
7. BibTeX de las referencias citadas en los puntos 3 y 6, con campo doi o url. No inventes campos.
8. Lista de "NO ENCONTRADO / NO VERIFICADO" y de las discrepancias de DOI.
```

---

## P8: Fuente principal de RR para cardiopatía isquémica y ACV isquémico. Ola 2

```text
Necesito una investigación profunda y verificable sobre las funciones de riesgo relativo (RR) del alcohol para cardiopatía isquémica (IHD) y ACV isquémico usadas en un estudio chileno de mortalidad atribuible. Es para justificar qué fuente es la principal. No buscamos reemplazar RR sin razón: queremos documentar y defender la elección.

CONTEXTO (es el marco; no lo investigues)
Proyecto FONDECYT 1240138 (Chile). Estimamos fracciones atribuibles al alcohol (AAF) y fracciones de impacto potencial (PIF) en la población de 15-65 años entre 2012 y 2024.
- Exposición: encuesta nacional de drogas de SENDA.
- Mortalidad: DEIS-MINSAL, CIE-10.
- La AAF integra RR(x) sobre una distribución gamma del consumo (0,1-150 g/día) por año × sexo × tramo etario.
- Las funciones de IHD y ACV isquémico de la estimación principal vienen del informe OMS 2024 GSRAHTSUD: son funciones de 2018 con bandas etarias, compartidas con InterMAHP 2018 y en la forma canónica de InterMAHP.

IMPLEMENTACIÓN ACTUAL Y PROBLEMAS
- La función OMS 2018 de IHD en hombres tiene un desplazamiento aditivo codificado que deja el RR en ~1 entre 60 y 100 g/día, con discontinuidades. Por eso las PIF de reducción de volumen en hombres quedan en ~0 o negativas.
- Alternativa: las funciones de la "Tabla 5" de un estudio chileno PUC/SENDA (2018), de forma ln RR = b1·x + b2·x·ln(x). Con ellas, 73 celdas de PIF cambian de signo (59 en IHD de hombres). Ejemplo preliminar: IHD en hombres, 2024, escenario de −10% de volumen: 0,42 muertes evitables con la función OMS frente a 20,1 con la Tabla 5. En ACV isquémico ambas fuentes coinciden (razón 1,02-1,04). Por debajo de ~40 g/día las curvas coinciden.
- La Tabla 5 no publica la covarianza entre b1 y b2. Con covarianza diagonal, los intervalos de IHD en mujeres degeneran. La tabla tiene además una columna "Fact" de significado incierto, que no aplicamos.

DECISIÓN Y OPCIONES
D-a [Q3]: fuente principal para IHD/ACV.
  A. Función OMS 2018 como principal y Tabla 5 como sensibilidad (actual).
  B. Tabla 5 como principal.
  C. Agregar una sensibilidad "sin cardioprotección" (RR ≥ 1). Solo si el investigador responsable lo pide, porque implica cómputo nuevo.

PREGUNTAS
Q1 [Q3]. ¿Qué dice la evidencia actual sobre la dosis-respuesta y la cardioprotección del alcohol en IHD y ACV isquémico? Considera Roerecke & Rehm 2012; Zhao, Stockwell et al. 2017 sobre el sesgo de abstinentes; Biddinger et al. 2022 con aleatorización mendeliana; y revisiones posteriores. ¿Se recomienda una sensibilidad sin protección?
Q2 [Q3]. ¿Qué formas funcionales y bandas etarias usan OMS 2024/GSRAHTSUD e InterMAHP 2018 para IHD y ACV? ¿De dónde viene la meseta o desplazamiento entre 60 y 100 g/día de la función de IHD en hombres (publicación de origen y página)?
Q3 [Q3/B5]. ¿Cuál es la fuente original de las funciones de RR de IHD y ACV del estudio PUC/SENDA 2018 ("Tabla 5")? ¿Está publicada su matriz de varianza-covarianza completa, por ejemplo en un anexo? ¿Qué significa la columna "Fact"?

CANDIDATOS A VERIFICAR PRIMERO (confirma DOI, título y año; si no coinciden o no tratan el tema, dilo)
- Roerecke M, Rehm J. 2012 (meta-análisis de IHD).
- Zhao J, Stockwell T, et al. 2017, Journal of Studies on Alcohol and Drugs.
- Biddinger KJ, et al. 2022, JAMA Network Open.
- Sherk A, et al. 2017, InterMAHP (documentación de IHD y ACV isquémico).
- Rehm J, et al. 2016 (función publicada de IHD; verifícala).
- Estudio PUC/SENDA 2018 sobre la carga atribuible al alcohol en Chile: identifica la referencia exacta.
- WHO 2024, Global status report on alcohol and health and treatment of substance use disorders (anexo de RR).

BÚSQUEDA
En inglés y español: PubMed/MEDLINE, Scopus/Web of Science, Google Scholar, SciELO, LILACS, WHO IRIS, documentación de InterMAHP, repositorio de SENDA.
Términos de ejemplo: alcohol "ischemic heart disease" dose-response meta-analysis cardioprotection; "abstainer bias" alcohol mortality; Mendelian randomization alcohol cardiovascular; "relative risk function" alcohol WHO; "carga de enfermedad atribuible al alcohol" Chile 2018.

REGLAS DE EVIDENCIA (obligatorias)
1. Toda afirmación sustantiva lleva una cita verificable (DOI, PMID o URL estable) y, cuando exista, página/tabla/ecuación/figura. Sin cita, no se incluye.
2. Si no encuentras algo, escribe "NO ENCONTRADO" y describe qué buscaste. No adivines DOIs, cifras, años ni autores.
3. Etiqueta cada afirmación como [TEXTO] (lo dice la fuente; agrega una cita textual de menos de 30 palabras cuando puedas) o [INFERENCIA] (deducción tuya).
4. Verifica primero los candidatos. Si un DOI no coincide, la referencia no existe o no trata lo que te digo, repórtalo; no la reemplaces en silencio.
5. Cita solo lo que leíste. Si leíste solo el resumen, marca "(solo resumen)".
6. Para cada número indica población, unidad, denominador y período, y si los autores lo ESTIMARON o lo ASUMIERON.
7. No promedies fuentes discordantes: preséntalas por separado y explica la discrepancia.
8. Un resultado no significativo no equivale a "sin efecto".
9. Los informes de gobierno u OMS sirven para definiciones y métodos; por sí solos no son evidencia de efecto causal.
10. Separa (a) evidencia chilena, (b) latinoamericana, (c) meta-análisis internacionales y (d) convenciones de modelos (OMS, InterMAHP, GBD).
11. Sin relleno: cada referencia debe sostener una fila concreta de una tabla. Máximo unas 20 referencias.
12. Prioriza la versión más reciente de cada guía y señala las versiones que se contradicen.
Inclusión: estudios primarios, revisiones sistemáticas y meta-análisis, documentación técnica de RR.
Exclusión: blogs, prensa y preprints sin revisión (salvo que no haya alternativa; en ese caso, márcalos).

FORMATO DE RETORNO (en español, salvo los párrafos de métodos y el BibTeX)
0. Primera línea: "KIMI-P8 | fecha de búsqueda | n referencias leídas a texto completo / n solo resumen".
1. Veredicto por opción. Tabla: Decisión [ID] | Opción | Apoyo (fuerte/moderado/débil/ninguno/contrario) | Referencias clave | Por qué.
1b. Tabla de parámetros: ID registro | Parámetro/decisión | Valor u opción | Fuente (DOI + página/tabla) | Estimado/Asumido | Transportabilidad a Chile (alta/media/baja + por qué).
2. Respuesta a cada pregunta (Q1...Q3), de 200 palabras como máximo cada una, con citas, [TEXTO]/[INFERENCIA] y "NO ENCONTRADO" cuando corresponda.
3. Tabla de evidencia: Referencia | DOI/PMID/URL | Diseño/población | Qué sostiene | Números (página/tabla, unidad, denominador, período; estimado vs asumido) | Transportabilidad a Chile | Calidad/limitaciones.
4. Evidencia chilena y latinoamericana en una sección aparte (en particular, el estudio PUC/SENDA 2018).
5. Recomendación: opción, fuerza (alta/media/baja), qué la cambiaría y qué limitación hay que declarar.
6. Párrafos de métodos en inglés: uno por opción viable (2 como máximo, de 100-150 palabras cada uno), con citas (Autor Año), sin afirmar nada que no esté en la tabla de evidencia.
7. BibTeX de las referencias citadas en los puntos 3 y 6, con campo doi o url. No inventes campos.
8. Lista de "NO ENCONTRADO / NO VERIFICADO" y de las discrepancias de DOI.
```

---

## P9: Lista de causas, AAF con signo, mapeo etario y procedencia de los RR. Ola 3

```text
Necesito una investigación profunda y verificable para justificar decisiones de REPORTE y de LISTA DE CAUSAS en un estudio chileno de mortalidad atribuible al alcohol. No buscamos agregar causas ni reemplazar RR: queremos documentar y defender lo que usamos.

CONTEXTO (es el marco; no lo investigues)
Proyecto FONDECYT 1240138 (Chile). Estimamos fracciones atribuibles al alcohol (AAF) y fracciones de impacto potencial (PIF) en la población de 15-65 años entre 2012 y 2024.
- Exposición: encuesta nacional de drogas de SENDA.
- Mortalidad: DEIS-MINSAL, CIE-10.
- La AAF integra RR(x) sobre una gamma del consumo (0,1-150 g/día).
- RR: funciones implementadas a partir del informe OMS 2024 GSRAHTSUD, en la forma canónica de InterMAHP. Las funciones crónicas son de 2024; las de IHD, ACV isquémico y lesiones son de 2018 (InterMAHP 2018).
- Las 23 causas parcialmente atribuibles son la lista de la Tabla S6 de Shield et al. 2025 (Lancet Public Health, DOI 10.1016/S2468-2667(25)00174-4) con RR utilizable, más los cánceres de estómago (C16) y páncreas (C25). Estos dos están en los RR OMS 2024, pero no en la Tabla S6 ni en la lista IARC.

IMPLEMENTACIÓN ACTUAL
- Las AAF y PIF se reportan con signo, con tope en 1 y sin piso en 0. Hay valores negativos en ACV isquémico (ambos sexos), diabetes tipo 2 en mujeres y algunas celdas de IHD. Se reporta el neto. No se ha decidido si agregar una tabla "solo daño".
- Estómago y páncreas: en 2022 cambian la proporción de cánceres atribuibles en mujeres de 32,6% a 22,4% (valor preliminar). Ya existe una variante calculada sin ellos.
- Cáncer cervicouterino (C53): figura en la Tabla S6, pero no tenemos un RR utilizable.
- Cardiopatía hipertensiva (I10-I15): se usa el RR de hipertensión (Liu et al. 2020).
- Mapeo etario: las funciones con bandas 15-34 / 35-64 / 65+ se aplican por mayor solapamiento a los grupos de la encuesta 15-29, 30-44, 45-59 y 60-65 (el grupo 60-65 usa la banda 35-64).
- La procedencia de algunos RR no está clara: cáncer de hígado exp(0,003922·x) con RR de exbebedor 2,23 (hombres) y 2,68 (mujeres); el RR de exbebedor de cáncer de mama pasó de 1,44 (versión 2016) a 1 (2024).

DECISIONES Y OPCIONES
D-a [Q4]: reporte neto con signo, o agregar además estimaciones "solo daño".
D-b [Q10]: estómago y páncreas en la estimación principal, o como sensibilidad etiquetada con el alcance IARC/Shield.
D-c [Q11]: cervicouterino. Justificar su exclusión como "sin RR utilizable" (no como "no causal").
D-d [Q9]: mantener y justificar el mapeo etario por solapamiento, o adoptar una alternativa.
D-e [Q22]: documentar la procedencia de cada función de RR (sin reemplazarlas).

PREGUNTAS
Q1 [Q4]. ¿Cómo reportan OMS, GBD e InterMAHP las AAF netas con efectos protectores frente a las AAF "solo daño"? ¿Es estándar reportar ambas?
Q2 [Q10/Q11]. ¿Qué evidencia causal hay (IARC, OMS 2024, Shield 2025) para el alcohol en cáncer de estómago, de páncreas y cervicouterino? ¿Qué lista de causas recomiendan las guías? Para el cervicouterino, ¿por qué figura en la Tabla S6 y de qué fuente de RR depende?
Q3 [Q22]. ¿Es estándar aplicar el RR de hipertensión (Liu et al. 2020) a la mortalidad por cardiopatía hipertensiva?
Q4 [Q9]. ¿Es aceptable aplicar funciones de RR con bandas etarias a estratos de encuesta agrupados de otra forma, por mayor solapamiento? ¿Qué hacen InterMAHP y la OMS?
Q5 [Q22]. ¿Cuál es la publicación de origen de cada función OMS 2024 usada, incluidos los RR de exbebedores? Una fila por causa: cirrosis, cánceres (cavidad oral, faringe, esófago, colorrectal, hígado, laringe, mama, estómago, páncreas), diabetes tipo 2, cardiopatía hipertensiva, epilepsia, tuberculosis, VIH, infecciones respiratorias bajas, pancreatitis, ACV hemorrágico, IHD, ACV isquémico y lesiones.

CANDIDATOS A VERIFICAR PRIMERO (confirma DOI, título y año; si no coinciden o no tratan el tema, dilo)
- Shield K, et al. 2025, Lancet Public Health, DOI 10.1016/S2468-2667(25)00174-4.
- WHO 2024, Global status report on alcohol and health and treatment of substance use disorders (anexo de RR).
- Sherk A, et al. 2017, InterMAHP User Guide.
- Liu Y, et al. 2020 (alcohol e hipertensión).
- Knott CS, et al. 2015 (diabetes tipo 2).
- Larsson SC, et al. 2016 (ACV hemorrágico e isquémico).
- Monografías IARC sobre alcohol y cáncer (volumen más reciente).

BÚSQUEDA
En inglés y español: PubMed/MEDLINE, Scopus/Web of Science, Google Scholar, SciELO, LILACS, WHO IRIS, monografías IARC, documentación de InterMAHP.
Términos de ejemplo: "alcohol-attributable fraction" net protective "harmful only"; alcohol stomach cancer pancreatic cancer IARC causal; alcohol cervical cancer relative risk; alcohol hypertension relative risk meta-analysis; "relative risk function" alcohol WHO 2024 source.

REGLAS DE EVIDENCIA (obligatorias)
1. Toda afirmación sustantiva lleva una cita verificable (DOI, PMID o URL estable) y, cuando exista, página/tabla/ecuación/figura. Sin cita, no se incluye.
2. Si no encuentras algo, escribe "NO ENCONTRADO" y describe qué buscaste. No adivines DOIs, cifras, años ni autores.
3. Etiqueta cada afirmación como [TEXTO] (lo dice la fuente; agrega una cita textual de menos de 30 palabras cuando puedas) o [INFERENCIA] (deducción tuya).
4. Verifica primero los candidatos. Si un DOI no coincide, la referencia no existe o no trata lo que te digo, repórtalo; no la reemplaces en silencio.
5. Cita solo lo que leíste. Si leíste solo el resumen, marca "(solo resumen)".
6. Para cada número indica población, unidad, denominador y período, y si los autores lo ESTIMARON o lo ASUMIERON.
7. No promedies fuentes discordantes: preséntalas por separado y explica la discrepancia.
8. Un resultado no significativo no equivale a "sin efecto".
9. Los informes de gobierno u OMS sirven para definiciones y métodos; por sí solos no son evidencia de efecto causal.
10. Separa (a) evidencia chilena, (b) latinoamericana, (c) meta-análisis internacionales y (d) convenciones de modelos (OMS, InterMAHP, GBD).
11. Sin relleno: cada referencia debe sostener una fila concreta de una tabla. Máximo unas 20 referencias.
12. Prioriza la versión más reciente de cada guía y señala las versiones que se contradicen.
Inclusión: estudios primarios, revisiones sistemáticas y meta-análisis, monografías IARC, documentación técnica de RR.
Exclusión: blogs, prensa y preprints sin revisión (salvo que no haya alternativa; en ese caso, márcalos).

FORMATO DE RETORNO (en español, salvo los párrafos de métodos y el BibTeX)
0. Primera línea: "KIMI-P9 | fecha de búsqueda | n referencias leídas a texto completo / n solo resumen".
1. Veredicto por opción para D-a a D-e. Tabla: Decisión [ID] | Opción | Apoyo (fuerte/moderado/débil/ninguno/contrario) | Referencias clave | Por qué.
1b. Tabla de parámetros: ID registro | Parámetro/decisión | Valor u opción | Fuente (DOI + página/tabla) | Estimado/Asumido | Transportabilidad a Chile (alta/media/baja + por qué).
2. Respuesta a cada pregunta (Q1...Q5), de 150 palabras como máximo cada una, con citas, [TEXTO]/[INFERENCIA] y "NO ENCONTRADO" cuando corresponda. En Q5 agrega una tabla: Causa | Función | Publicación de origen | DOI | RR de exbebedor y su origen.
3. Tabla de evidencia: Referencia | DOI/PMID/URL | Diseño/población | Qué sostiene | Números (página/tabla, unidad, denominador, período; estimado vs asumido) | Transportabilidad a Chile | Calidad/limitaciones.
4. Evidencia chilena y latinoamericana en una sección aparte, aunque quede vacía.
5. Recomendación por decisión: opción, fuerza (alta/media/baja), qué la cambiaría y qué limitación hay que declarar.
6. Párrafos de métodos en inglés: uno por opción viable de D-a y de D-b (2 como máximo por decisión, de 100-150 palabras cada uno), con citas (Autor Año), sin afirmar nada que no esté en la tabla de evidencia.
7. BibTeX de las referencias citadas en los puntos 3 y 6, con campo doi o url. No inventes campos.
8. Lista de "NO ENCONTRADO / NO VERIFICADO" y de las discrepancias de DOI.
```

---

## P10: Definición de YLL/YPLL y tabla de vida de referencia. Ola 3

```text
Necesito una investigación profunda y verificable para elegir la métrica principal de años de vida perdidos y la tabla de vida de referencia en un estudio de mortalidad atribuible al alcohol en Chile. Responde a las opciones planteadas.

CONTEXTO (es el marco; no lo investigues)
Proyecto FONDECYT 1240138 (Chile). Estimamos muertes atribuibles al alcohol y muertes evitables en escenarios de política, en la población de 15-65 años entre 2012 y 2024 (mortalidad: DEIS-MINSAL, CIE-10; exposición: encuesta nacional de drogas de SENDA). A partir de ahí calculamos años de vida perdidos atribuibles (YLL totales de la causa × AAF) y evitables (YLL totales de la causa × PIF). Etapa siguiente: microsimulación tipo SIMAH (Kilian et al., Lancet Public Health 2025, DOI 10.1016/S2468-2667(25)00165-3).

IMPLEMENTACIÓN ACTUAL
Se calculan tres métricas, que nunca se suman ni se mezclan. Las diferencias que siguen son preliminares (cálculo de julio de 2026, antes de una corrección menor de edades en la base de defunciones):
(1) YLL con tablas de vida de período de Chile de la Human Mortality Database (HMD): esperanza de vida restante a la edad de muerte. Es la candidata a principal.
(2) YLL con la tabla de vida de referencia teórica del GBD 2019 (TMRLT): ~+26% frente a HMD en 2012-2024.
(3) YPLL con edad de referencia (e0 − edad, con piso en 0): ~−8% frente a HMD en total y ~−19,5% en el grupo de 60-65 años.
- Las tablas de HMD, INE y ONU (WPP 2024) difieren hasta en ~1 año en el nivel de la esperanza de vida y en la profundidad de la caída por COVID. No se empalman fuentes.
- Hay una sensibilidad con WPP 2024 planificada, pero no implementada.
- No se aplica descuento ni ponderación por edad.

DECISIÓN Y OPCIONES
D-a [Q8]:
  A. YLL con HMD como principal y GBD para comparabilidad.
  B. YLL con la TMRLT del GBD como principal (comparabilidad internacional).
  C. YPLL con edad de referencia (e0 − edad, o 65/70/75 años) como principal.
  D. Agregar la sensibilidad WPP 2024 (o INE).

PREGUNTAS
Q1 [Q8]. Para la carga atribuible al alcohol, ¿qué se recomienda: YLL de tabla de vida (esperanza restante) o YPLL con edad de referencia? ¿Qué sesgos conocidos tiene e0 − edad para las muertes a edades mayores?
Q2 [Q8]. ¿Cuándo corresponde una tabla de vida nacional de período (HMD/INE) y cuándo la TMRLT del GBD 2019 (DOI 10.6069/1D4Y-YQ37)? ¿Qué recomiendan el GBD, la OMS (Global Health Estimates) y la literatura metodológica?
Q3 [Q8]. ¿Cómo definen los años de vida perdidos Kilian et al. 2025 (Lancet Public Health) y Lemp et al. 2026 (JAMA Health Forum, DOI 10.1001/jamahealthforum.2026.2348)? ¿Usan un horizonte hasta los 75 años, qué tabla de vida usan y aplican descuento?
Q4 [Q8]. ¿Qué diferencias documentadas hay entre las esperanzas de vida de Chile 2012-2024 según HMD, INE y ONU WPP 2024, incluidos 2020-2021? ¿Cómo se manejan en los análisis de sensibilidad?
Q5 [Q8]. ¿La literatura reciente sobre YLL por alcohol usa descuento o ponderación por edad? Esperamos que no, pero verifícalo.

CANDIDATOS A VERIFICAR PRIMERO (confirma DOI, título y año; si no coinciden o no tratan el tema, dilo)
- GBD 2019 Theoretical Minimum Risk Life Table, DOI 10.6069/1D4Y-YQ37.
- Human Mortality Database, Methods Protocol (versión 6).
- United Nations, World Population Prospects 2024.
- Lemp JM, et al. 2026, JAMA Health Forum, DOI 10.1001/jamahealthforum.2026.2348.
- Kilian C, et al. 2025, Lancet Public Health, DOI 10.1016/S2468-2667(25)00165-3.

BÚSQUEDA
En inglés y español: PubMed/MEDLINE, Scopus/Web of Science, Google Scholar, SciELO, LILACS, WHO IRIS, IHME GHDx, HMD, ONU WPP, INE Chile.
Términos de ejemplo: "years of life lost" "standard life table" alcohol-attributable; "potential years of life lost" reference age bias; "theoretical minimum risk life table"; "años de vida potencialmente perdidos" alcohol Chile; "tablas de mortalidad" Chile INE HMD comparación.

REGLAS DE EVIDENCIA (obligatorias)
1. Toda afirmación sustantiva lleva una cita verificable (DOI, PMID o URL estable) y, cuando exista, página/tabla/ecuación/figura. Sin cita, no se incluye.
2. Si no encuentras algo, escribe "NO ENCONTRADO" y describe qué buscaste. No adivines DOIs, cifras, años ni autores.
3. Etiqueta cada afirmación como [TEXTO] (lo dice la fuente; agrega una cita textual de menos de 30 palabras cuando puedas) o [INFERENCIA] (deducción tuya).
4. Verifica primero los candidatos. Si un DOI no coincide, la referencia no existe o no trata lo que te digo, repórtalo; no la reemplaces en silencio.
5. Cita solo lo que leíste. Si leíste solo el resumen, marca "(solo resumen)".
6. Para cada número indica población, unidad, denominador y período, y si los autores lo ESTIMARON o lo ASUMIERON.
7. No promedies fuentes discordantes: preséntalas por separado y explica la discrepancia.
8. Un resultado no significativo no equivale a "sin efecto".
9. Los documentos oficiales (INE, ONU, OMS) sirven para definiciones, métodos y series de datos.
10. Separa (a) evidencia chilena, (b) latinoamericana, (c) guías y estudios internacionales y (d) convenciones (GBD, OMS).
11. Sin relleno: cada referencia debe sostener una fila concreta de una tabla. Máximo unas 20 referencias.
12. Prioriza la versión más reciente de cada guía y señala las versiones que se contradicen.
13. Para series de datos y páginas web, indica la fecha de consulta y la versión o edición de la base (por ejemplo, WPP 2024, fecha "last modified" de HMD, publicación del INE).
Inclusión: guías de métodos, estudios metodológicos, documentación oficial de tablas de vida, estudios de carga por alcohol que reporten YLL.
Exclusión: blogs, prensa y preprints sin revisión (salvo que no haya alternativa; en ese caso, márcalos).

FORMATO DE RETORNO (en español, salvo los párrafos de métodos y el BibTeX)
0. Primera línea: "KIMI-P10 | fecha de búsqueda | n referencias leídas a texto completo / n solo resumen".
1. Veredicto por opción. Tabla: Decisión [ID] | Opción | Apoyo (fuerte/moderado/débil/ninguno/contrario) | Referencias clave | Por qué.
1b. Tabla de parámetros: ID registro | Parámetro/decisión | Valor u opción | Fuente (DOI + página/tabla) | Estimado/Asumido | Transportabilidad a Chile (alta/media/baja + por qué).
2. Respuesta a cada pregunta (Q1...Q5), de 150 palabras como máximo cada una, con citas, [TEXTO]/[INFERENCIA] y "NO ENCONTRADO" cuando corresponda.
3. Tabla de evidencia: Referencia | DOI/PMID/URL | Diseño/población | Qué sostiene | Números (página/tabla, unidad, denominador, período; estimado vs asumido) | Transportabilidad a Chile | Calidad/limitaciones.
4. Evidencia chilena y latinoamericana en una sección aparte, aunque quede vacía. Incluye una tabla de e0 de Chile por fuente: Año | Sexo | HMD | INE | WPP 2024 | Versión/fecha de consulta.
5. Recomendación: métrica principal, tabla de vida, sensibilidades que hay que reportar, fuerza (alta/media/baja) y qué la cambiaría.
6. Párrafos de métodos en inglés: uno por opción viable (2 como máximo, de 100-150 palabras cada uno), con citas (Autor Año), sin afirmar nada que no esté en la tabla de evidencia.
7. BibTeX de las referencias citadas en los puntos 3 y 6, con campo doi o url. No inventes campos.
8. Lista de "NO ENCONTRADO / NO VERIFICADO" y de las discrepancias de DOI.
```

---

### Correspondencia entre prompts e ítems del registro

| Prompt | Ítems del registro | Dueño de la decisión |
|---|---|---|
| P1 | V1 (solo confirmación), Q1, B14 (parte de exposición) | Andrés (V1, ya decidido por regla interna) / ACC (puente APC) |
| P2 | V2, Q5, Q6 | ACC (V2 si supera la regla del 5%) / Andrés |
| P3 | V3, B1, Q21, Q26c | Andrés (incluye si se aplica también a pif2) |
| P4 | D1 | ACC |
| P5 | Q2, Q7, Q25 (solo microsimulación), Q4 (solo agregación de PIF negativas) | ACC (AAF=1) / Andrés (lambda) |
| P6 | D2, D3, Q20, B14 (DEIS 2024), Q12 (solo precedentes) | ACC |
| P7 | C1, C2, Q13, Q15, B5 (covarianza), B12 | Andrés / ACC (PSU 2016) |
| P8 | Q3, B5 (fuente de la covarianza) | ACC |
| P9 | Q4 (reporte con signo), Q9, Q10, Q11, Q22 | ACC (estómago/páncreas) / Andrés |
| P10 | Q8 | ACC |

**Ítems que no necesitan investigación bibliográfica (ingeniería o redacción):**
- C3, C4, C5
- B2, B3, B4, B6-B11, B13 (pies de figura), B15-B21
- Q16, Q17, Q18, Q19, Q24, Q26 (a, b, d, e), Q27, Q28
- El contenido exacto de la Tabla S6 de Shield 2025 (lo lee Claude desde `_bib/`).