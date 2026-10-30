# DIR/APS y adolescentes de 15–17 años: qué dicen las normas, qué registra el REM y qué no se puede identificar (insumo para discutir con José; solo investigación)

Las normas chilenas sí incluyen a los adolescentes en el programa DIR. El tamizaje parte a los 10 años, se usa CRAFFT para 10–19 años y la acción para el consumo de riesgo es una intervención motivacional, no la intervención breve de adultos. El REM, en cambio, no permite aislar el grupo de 15–17: las bandas son 10–14/15–19 en REM A27 y 10–13/14–19 en los puntos de corte del CRAFFT. Además, los conteos son prestaciones o evaluaciones, no personas. Por eso la inclusión de 15–17 se puede defender en lo normativo como población elegible, pero ningún parámetro específico para 15–17 sale directamente del REM. Tampoco se debe trasladar a ese grupo el efecto de la IB en adultos.

## TL;DR
- **Norma:** el DIR cubre desde los 10 años. El instrumento para 10–19 años es CRAFFT, que mide alcohol y otras drogas a la vez. En adolescentes las acciones son intervención mínima, intervención motivacional (IMA, 2 sesiones y hasta 4) y referencia asistida. En el EMP, el AUDIT se puede aplicar desde los 15 años. Las orientaciones DIR 2017 reservan AUDIT y ASSIST para los 20 años y más, así que hay una inconsistencia entre documentos que José debe resolver.
- **Registro:** el tamizaje va en REM A03 sección D.1, por instrumento, categoría de riesgo, grupo de edad y sexo. Las intervenciones van en REM A27 sección G (desde 2023/2024 aparece como "Sección F" en el índice del manual), por tipo de intervención, sustancia principal, bandas 10–14, 15–19, 20–24, 25–44, 45–64 y 65+, y sexo. No hay banda 15–17 ni variable de educación. La unidad es la evaluación o la intervención, no la persona.
- **Implicancia para micsim:** se puede representar a 15–17 en la población simulada y declararlos elegibles según la norma. Pero la cobertura, la tasa de positividad, la probabilidad de IB/IMA y el efecto para ese grupo no se pueden identificar con el REM agregado. Cualquier valor para 15–17 sería un supuesto que hay que declarar.

## Key Findings

### 1) Qué contempla la norma DIR/APS para adolescentes

**Orientaciones Técnico Administrativas DIR (MINSAL, septiembre 2017, primera versión):**
- **Población:** el tamizaje es para "población de 10 años y más".\[1\]
- **Instrumentos:**
  - "CRAFFT para población adolescente".\[1\]
  - "AUDIT (C) sólo para consumo de alcohol, desde los 20 años". El AUDIT completo se aplica cuando el AUDIT-C da riesgo.\[1\]
  - "ASSIST para el consumo de alcohol, tabaco y otras drogas, desde los 20 años".\[1\]
- **Validación del CRAFFT:** según el documento, el CRAFFT está "validado en Chile para adolescentes entre 14 y 18 años". Su uso en menores de esa edad y hasta los 19 es "referencial".\[1\]
- **Acciones por nivel de riesgo:**
  - Bajo riesgo: intervención mínima.\[1\]
  - Riesgo: intervención breve en adultos o motivacional en adolescentes.\[1\]
  - Riesgo alto: derivación asistida o referencia a tratamiento.\[1\]
- **Regla de edad:**
  - Entre 10 y 13 años, y en adolescentes embarazadas, "cualquier patrón de consumo es considerado de alto riesgo".\[1\]
  - En "mayores de 14 años", cualquier consumo se considera "de riesgo".\[1\]
- **Repetición:**
  - Tamizaje "una vez al año", y cada 6 meses en adolescentes con consumo de riesgo.\[1\]
  - Adolescentes: "2 intervenciones" motivacionales y eventualmente 2 más para derivar.\[1\]
  - Adultos: segunda sesión para 20%, tercera para 10% y cuarta para 5% de quienes tienen consumo de riesgo.\[1\]
- **Registro indicado:** tamizaje en REM A03 sección D.1 ("sólo se debe registrar un instrumento aplicado por usuario/a"). IB/IMA y referencia asistida en REM A27 sección G, "sólo… para sustancia de consumo principal".\[1\]
- **Indicadores del convenio:**
  - Tamizaje: meta 8% de la población de 10 años y más.\[1\]
  - IB/IMA: meta 90% de las personas con consumo de riesgo.\[1\]
  - Referencia asistida: meta 80%.\[1\]
  - Todos se verifican con REM.\[1\]

**Ficha ex ante DIPRES (Formulación 2021):**
- El DIR parte en 2011 solo con alcohol. En 2015 suma tabaco y otras drogas y "se amplía el rango etario… desde los 10 años".\[2\]
- Para 10–19 años se aplica CRAFFT, sobre todo en el Control de Salud Integral del Adolescente y en Espacios Amigables. En este grupo la IB "se denomina Intervención Motivacional".\[2\]
- En adolescentes el instrumento "podría aplicarse más de una vez al año (hasta 4 veces)".\[2\]
- El REM "no es rutificado", es decir, no identifica personas.\[2\]

**Guía Clínica AUGE "Consumo perjudicial y dependencia de alcohol y drogas en menores de 20 años" (MINSAL 2013):**
- Recomienda la detección con AUDIT (alcohol) y/o CRAFFT (alcohol y drogas) "según sea más adecuado".\[3\]
- Fija el punto de corte del CRAFFT en ≥2.

**Puntos de corte en el Manual REM, sección A03 D.1 (2021–2022):**
- CRAFFT, 10–13 años: 0 = bajo riesgo; 1 o más = riesgo alto.\[4\]\[5\]
- CRAFFT, 14–19 años: 0 = bajo riesgo; 2 o más = riesgo alto.\[4\]\[6\] La categoría intermedia no se pudo verificar en el texto completo.
- AUDIT: 0–7 bajo riesgo. Según la guía MINSAL 2011, 8–15 es riesgo y 16 o más es posible consumo perjudicial o dependencia.\[7\]
- ASSIST alcohol: 0–10 bajo, 11–20 intermedio, 21+ alto.\[1\]
- ASSIST otras sustancias: 0–3 bajo, 4–20 intermedio, 21+ alto.\[1\]\[8\]

**Inconsistencia que conviene explicitar:**
- Desde 2018 el EMP incorpora CRAFFT (aplicado a 15–19 años en ese espacio) y ASSIST (20+).\[6\]\[9\]
- El manual REM también dice "AUDIT en EMP: 15 años y más".\[8\]\[10\]
- Las orientaciones DIR 2017 dicen AUDIT "desde los 20 años".\[1\]
- En consecuencia, a un joven de 15–19 en el EMP pueden registrarle AUDIT o CRAFFT según el documento que siga el centro.

### 2) Distinción entre instrumentos
- **AUDIT y AUDIT-C:** solo alcohol. En el REM el AUDIT-C no aparece como fila aparte; es el primer paso del AUDIT.\[5\]\[10\]
- **ASSIST:** varias sustancias. Se registra la sustancia principal (la de mayor puntaje) o la que la persona plantea como problema.\[8\]
- **CRAFFT:** alcohol y drogas, para adolescentes. Su puntaje no separa alcohol de otras drogas, y se registra la sustancia principal.\[8\]\[10\]
- **Regla práctica:** no hay que sumar AUDIT + ASSIST + CRAFFT como "tamizajes de alcohol". Solo el AUDIT es específico de alcohol. En el CRAFFT, el desglose por alcohol depende de cómo se clasificó la sustancia principal.

## Tabla breve

| Instrumento / actividad | Edad según norma | Registro REM | Unidad de conteo | Fuente |
|---|---|---|---|---|
| CRAFFT (tamizaje, alcohol + drogas) | 10–19 (DIR); 15–19 en EMP; validado en Chile para 14–18 | A03, sección D.1. Puntos de corte en bandas 10–13 / 14–19. Registro por grupo de edad y sexo, separando EMP de otras prestaciones | Evaluaciones aplicadas; un instrumento por usuario y sustancia principal | OT DIR 2017 (eligenofumar.cl/wp-content/uploads/2024/04/2017.11.27_OOTT_Administrativas-Programas-Final-1.pdf); Manual REM 2019, 2021–22, 2023 y 2025–26 (repositoriodeis.minsal.cl) |
| AUDIT / AUDIT-C (solo alcohol) | ≥20 (DIR); ≥15 en EMP | A03, sección D.1, por categoría de riesgo, edad y sexo | Evaluaciones | OT DIR 2017; Manual REM 2019 (sscoquimbo.cl) y 2022 (saludchiloe.cl) |
| ASSIST (multisustancia) | ≥20 (validado en 18–60) | A03, sección D.1 | Evaluaciones; sustancia principal | OT DIR 2017; Manual REM |
| Intervención mínima | Todas las edades con bajo riesgo | A27, sección G (Sección F en el índice 2023+). Por sustancia (alcohol, tabaco, drogas), bandas 10–14 / 15–19 / 20–24 / 25–44 / 45–64 / 65+ y sexo | Intervenciones (prestaciones) | OT DIR 2017; reporte REM 2018 de webdeis.minsal.cl |
| Intervención breve (adultos) / motivacional (adolescentes) | IB en ≥20; IMA en adolescentes | A27, sección G, mismas bandas | Intervenciones; puede haber 1–4 por persona | OT DIR 2017; DIPRES 2021 |
| Referencia asistida | Riesgo alto, todas las edades | A27, sección G | Intervenciones; se cuenta como "cita para confirmación diagnóstica" | OT DIR 2017 |
| Control de Salud Integral del Adolescente (puerta de entrada del CRAFFT) | 10–19 | A01: controles en 10–14 y 15–19, por sexo | Controles | Manual REM 2021–22; OT Control Salud Integral Adolescente 2016 (diprece.minsal.cl) |

## 3) Cifras: qué hay disponible y qué falta

- **Archivos locales:** no tuve acceso a la carpeta C:\Users\nDP\Documents\micsim.
- **Google Drive:** está la ficha DIPRES del DIR y archivos REM-06 de 2018 (salud mental). No encontré archivos REM A03 ni A27.
- **Totales nacionales oficiales, sin desglose por edad (DIPRES, a partir de REM):**
  - Personas pesquisadas con consumo de riesgo: 13.555 en 2012 y 77.294 en 2019.\[2\]
  - Personas con alto riesgo: 7.155 en 2012 y 27.634 en 2019.\[2\]
  - Intervenciones breves: 18.610 en 2012 y 88.585 en 2019.\[2\]
  - DIPRES las llama "personas", pero provienen de conteos de prestaciones del REM.
- **Por edad y sexo:** existe el reporte REM 2018 A27 sección G de webdeis.minsal.cl ("Sistema Reportes REM"), que muestra columnas 10–14, 15–19, 20–24, 25–44, 45–64, 65+, hombres y mujeres.\[11\] No pude descargarlo porque el sitio bloquea el acceso automatizado, así que no informo cifras de ahí.
- **Archivos que hay que obtener**, desde DEIS (repositoriodeis.minsal.cl, sección de datos abiertos REM, archivos por año y serie A; o webdeis.minsal.cl → Reportes REM):
  - REM A03 sección D.1 y REM A27 sección G/F, 2015–2025, nacional y por establecimiento o comuna.
  - REM A01, controles adolescentes 15–19.
  - REM A02, EMP por edad y sexo (para el denominador del EMP).
  - Manuales REM de cada año, para mapear los códigos de fila.

## 4) Unidad de conteo y comparabilidad
- La unidad es la prestación, la evaluación o la intervención, no la persona. El REM no está rutificado.\[2\]
- **Fuentes de doble conteo:**
  - En adolescentes el tamizaje puede repetirse (cada 6 meses, o hasta 4 veces al año según DIPRES).\[1\]\[2\]
  - Las IMA son 2 o más por adolescente.\[1\]
  - Por eso la razón intervenciones / tamizajes positivos no es una probabilidad condicional individual y puede superar el 100%.
- **Reglas documentadas:**
  - Un instrumento por usuario.\[1\]
  - Sustancia principal.\[1\]
  - Los registros en EMP/EMPAM excluyen a los de otras prestaciones (no se deben sumar dos veces).\[6\]
  - El total de AUDIT/ASSIST/CRAFFT en EMP debe ser consistente con los EMP registrados en REM A02.\[6\]
- **El numerador y el denominador no coinciden** en los indicadores DIR:
  - El numerador (A27) mezcla sustancias: alcohol, tabaco y drogas.
  - El denominador (A03) mezcla instrumentos y espacios.
  - Las bandas de edad difieren: 10–14/15–19 en A27 frente a 10–13/14–19 en los cortes de A03.
  - Un tamizaje y su intervención pueden caer en meses o años distintos.

## 5) Conclusión sobre 15–17
- **Respaldado por la norma:** el tamizaje con CRAFFT y la IMA o referencia asistida en adolescentes (DIR 2017, DIPRES 2021, GPC 2013). Desde 2018 el CRAFFT está en el EMP para 15–19.\[9\]
- **Registrado:** actividad agregada en 15–19, por sexo, tipo de intervención y sustancia.
- **No identificable:**
  - Valores exactos para 15–17.
  - Personas únicas.
  - Cobertura individual.
  - Secuencia tamizaje → intervención.
  - Educación.
  - Efecto de la IMA.
- **Propuesta:** mantener a 15–17 en la población simulada. Tratar la elegibilidad como un escenario explícito (base sin 15–17; sensibilidad con 15–17) y declarar como supuesto el efecto adolescente, tomado de literatura específica y no del efecto de adultos.
- **Sobre eficacia:** que exista tamizaje no prueba que la intervención funcione en este grupo. La evidencia chilena citada por DIPRES sobre la IB (Barticevic 2018) se refiere a adultos con AUDIT.\[2\]

## Qué distribución edad/sexo se puede describir para adultos
- **REM A27 (intervenciones):** bandas 20–24, 25–44, 45–64 y 65+, más totales por sexo, por tipo de intervención y por sustancia (alcohol por separado).\[11\]
- **REM A03 D.1 (tamizajes):** AUDIT por categoría de riesgo, edad y sexo, separando EMP de otras prestaciones.\[5\]\[6\]
- **Lo que no se puede asumir:** que el cruce edad × sexo esté disponible en todas las secciones. En el reporte 2018 el sexo aparece como total marginal. Hay que verificarlo en los archivos de datos abiertos.
- **Educación:** no hay esta variable en el REM.

## Preguntas para José
1. ¿La población elegible para la intervención en micsim parte en 15, en 18 o en 20 años? ¿Mantenemos 15–17 en la población simulada aunque no sean elegibles en el escenario base?
2. ¿Aceptamos modelar la intervención adolescente como IMA, con un efecto distinto o nulo en sensibilidad, y no como la IB de adultos?
3. ¿Cómo resolvemos la discrepancia AUDIT ≥15 (EMP) frente a ≥20 (DIR) en 15–19?
4. ¿Prorrateamos 15–19 hacia 15–17 usando población INE (sería un supuesto explícito) o solo informamos 15–19?
5. ¿Usamos solo filas de alcohol del A27 y CRAFFT con sustancia principal alcohol, o el total de sustancias?
6. ¿Calibramos la cobertura con prestaciones, sabiendo que no son personas, o buscamos datos individuales (RAS/ficha clínica) por convenio?
7. ¿Qué años usamos, dado el quiebre de 2015 (10 años y más, multisustancia), 2018 (CRAFFT/ASSIST en EMP) y 2020–21 (pandemia y modalidad remota)?

## Caveats
- No leí el texto completo de los manuales REM 2023–2026: el PDF venía como binario o el sitio bloqueaba la descarga. Los puntos de corte y bandas salen de extractos de los manuales 2019–2023, y la numeración de secciones puede haber cambiado entre años.
- El reporte webdeis 2018 solo lo pude ver como fragmento del buscador. Las cifras que contiene no se usaron.

## Sources

1. <https://eligenofumar.cl/wp-content/uploads/2024/04/2017.11.27_OOTT_Administrativas-Programas-Final-1.pdf>
2. <https://www.dipres.gob.cl/597/articles-212526_doc_pdf1.pdf>
3. [Consumo perjudicial y Dependencia de Alcohol y otras ...](https://diprece.minsal.cl/wrdprss_minsal/wp-content/uploads/2016/03/GUIA-CLINICA-CONSUMO-ALCOHOL-MENORES-20-IMPRESA.pdf)
4. [Ministerio de Salud](https://inteligenciasanitaria.saludchiloe.cl/estadistica/manuales/Versiones%20REM/REM%20Versiones/2021/Manual/2.%20Manual%20Series%20REM%20V1.2%202021-2022.pdf)
5. [Ministerio de Salud](https://desammaullin.cl/wp-content/uploads/2021/02/Manual-Series-REM-V1.0-2021-2022.pdf)
6. [Ministerio de Salud](https://www.sscoquimbo.cl/gob-cl/documentos/files/estadisticas/series/2019/Manual%20Series%20REM%20V1.0%202019.pdf)
7. [INTERVENCIONES BREVES PARA REDUCIR EL CONSUMO ...](https://diprece.minsal.cl/wrdprss_minsal/wp-content/uploads/2016/02/5.-MINSAL_2011_-Intervenciones-breves-alcohol.pdf)
8. [Ministerio de Salud](https://inteligenciasanitaria.saludchiloe.cl/estadistica/manuales/Versiones%20REM/REM%20Versiones/2020/Manual%20Series%20REM%20V1.1.pdf)
9. [MINISTERIO DE SALUD](https://estadistica.ssmso.cl/wp-content/uploads/2022/11/Manual-Series-REM-2023-V1.pdf)
10. [Ministerio de Salud](https://inteligenciasanitaria.saludchiloe.cl/estadistica/manuales/Versiones%20REM/REM%20Versiones/2022/Manuales%20y%20aclaraciones/Version%201.2/Manual%20Series%20REM%20V1.2%202022.pdf)
11. [Sistema Reportes REM](https://webdeis.minsal.cl/rem2018/?mes_final=12&mes_inicio=1&periodo=2018&regiones=-1&regionesReload=-1&rem=39&seccion_id=406&serie=1&servicios=0&serviciosReload=0&tipo=4&tipoReload=4)
