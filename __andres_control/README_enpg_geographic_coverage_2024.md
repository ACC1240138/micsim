# Exclusión geográfica ENPG: cálculo provisional 2024

Fecha de cálculo: 2026-10-26. Resultado principal: **21,95% de la población de 15–64 años**, usando las comunas observadas en ENPG 2024 como aproximación al marco. No es un porcentaje de todas las edades ni una estimación de sesgo en consumo, pobreza o alcohol.

## Resultado y escenarios

Todas las poblaciones de esta tabla corresponden a **2024, ambos sexos, 15–64 años**, con la misma proyección INE base 2017 en numerador y denominador.

| Componente | Lista observada 2024 (109 comunas) | Lista observada 2022 aplicada a 2024 (109) | Regla hipotética ≥30.000 habitantes (135) |
|---|---:|---:|---:|
| Población nacional total | 13.619.165 | 13.619.165 | 13.619.165 |
| Población cubierta: urbana dentro de la lista | 10.630.379 | 10.630.379 | 11.083.858 |
| A: urbana + rural fuera de la lista | 2.399.620 | 2.399.620 | 1.707.092 |
| B: rural dentro de la lista | 589.166 | 589.166 | 828.215 |
| A + B | 2.988.786 | 2.988.786 | 2.535.307 |
| Porcentaje excluido | **21,94544%** | **21,94544%** | **18,61573%** |

La precisión de los CSV sirve para reproducir la aritmética; comunicar **aproximadamente 21,9%**, no exactitud demográfica aparente. No se añade intervalo de confianza. Los escenarios tampoco forman un intervalo estadístico ni límites garantizados del marco verdadero.

La lista completa observada 2024, la restringida a personas de 15–65 años con sexo válido y ponderador positivo (selección del generador histórico), y la lista observada 2022 son idénticas: 109 códigos. Esto respalda la estabilidad de la aproximación, pero no sustituye una verificación código por código contra el directorio oficial del marco 2024. No se obtuvo ese directorio nominal independiente.

El escenario de tamaño usa la población comunal **de todas las edades** exclusivamente para definir la regla ≥30.000; sus numeradores y denominador siguen siendo 15–64. Hay **29 comunas no observadas con ≥30.000 habitantes** y **3 observadas con menos de 30.000** (Mostazal, Pitrufquén y Aysén). Por eso no se puede equiparar ausencia con comuna pequeña ni presentar ese escenario como el marco ENPG.

## Fuentes y alcance

- SENDA, *Décimo Sexto Estudio Nacional de Drogas en Población General de Chile 2024*, [copia local](../_enpg/docs/2024/enpg2024.pdf), páginas impresas 7–10 (PDF 9–12). Define viviendas particulares en áreas urbanas de 109 comunas, desde el MMV 2021, basado en cartografía del Censo 2017 y actualizado. El marco considera áreas especiales susceptibles de exclusión. El 86,4% de cobertura publicado allí se refiere a viviendas respecto del marco urbano, no al porcentaje nacional de personas usado aquí. Tampoco se reutiliza el aproximado 70% de la introducción, cuyo denominador no equivale al nuestro.
- Base pública ENPG 2024, `COD_COMUNA`, contrastada con ENPG 2022; archivos Stata canónicos dentro de `_enpg/enpg.tar.xz.enc`, leídos únicamente mediante `acc_data()`. [Página SENDA de la base 2024](https://www.senda.gob.cl/base-de-datos-y-cuestionario-encuesta-nacional-de-poblacion-general-2024/). La consulta web devolvió 403; se usaron el informe y los datos disponibles localmente, con hashes registrados.
- INE, *Estimaciones y proyecciones 2002–2035, comuna y área urbana y rural*, base 2017, CSV local `estimaciones-y-proyecciones-2002-2035-comuna-y-area-urbana-y-rural11df0b16cde04242827bef3fd62529c5(EEPP comuna area).csv`, columna `Poblacion 2024`. [Portal INE](https://www.ine.gob.cl/estadisticas/sociales/demografia-y-vitales/proyecciones-de-poblacion). Se suman 10 grupos quinquenales (15–19 a 60–64), 2 sexos y 2 áreas en 346 comunas. Se trata de proyecciones, no conteos del Censo 2024.
- El otro archivo local, `estimaciones-y-proyecciones-de-población-1992-2070_base-2024_base-de-datos(BBDD_EEPP-2024_0101).csv`, contiene edades simples a nivel país, pero no la combinación comuna × área necesaria. No se mezcla su total actualizado con los numeradores de la proyección base 2017. La fuente comunal utilizada no permite calcular exactamente 18–65: **15–64 es la aproximación disponible**, sin repartir grupos quinquenales.

Se supone cubierta toda la población urbana de las comunas observadas según la clasificación INE. No se cuantifican UPM especiales excluidas ni posibles diferencias territoriales entre la proyección y el MMV. Tampoco se incluyen como exclusión geográfica las restricciones a instituciones, personas en situación de calle u otras condiciones de elegibilidad. Por tanto, esta suma no estima todas las formas de falta de cobertura de ENPG.

## Comprobación del doble conteo

Cada celda comuna × sexo × edad × área pertenece exactamente a uno de tres conjuntos: urbana cubierta, A o B. El script comprueba esa partición y que:

```text
10.630.379 + 2.399.620 + 589.166 = 13.619.165
100 × (2.399.620 + 589.166) / 13.619.165 = 21,9454423234%
100 × (1 − 10.630.379 / 13.619.165)      = 21,9454423234%
```

El rural nacional suma 1.472.410 personas (10,81%). De ellas, **883.244** viven fuera de las 109 comunas y ya están en A; sumarlas nuevamente contaría dos veces el 6,49% del denominador. B contiene solamente las otras 589.166 (4,33%). A equivale a 17,62%. La antigua suma aproximada 12% + 11% no define dos componentes excluyentes y no se conserva.

## Código, trazabilidad y validación

- [Script reproducible](calculate_enpg_geographic_coverage_2024.R): ejecutar desde la raíz con `Rscript __andres_control/calculate_enpg_geographic_coverage_2024.R`; usa la activación habitual de renv y requiere `ACC_DATA_KEY` sin imprimirla.
- [Resultados de escenarios](enpg_geographic_coverage_2024.csv), [auditoría de las 346 comunas](enpg_geographic_coverage_2024_communes.csv) y [MD5 de insumos](enpg_geographic_coverage_2024_sources.csv). La auditoría publica población agregada y pertenencia a listas, no filas individuales.
- Se ejecutó con datos reales ENPG e INE. Comprobaciones: celdas únicas y completas, población no negativa, códigos enlazados, partición exhaustiva y excluyente, igualdad de ambas fórmulas y reproducción de `pct_pop_in_enpg_comunas` de 2024 del CSV histórico. El ambiente local heredaba un locale `C.UTF-8` no admitido por R Windows; se fijaron `LANG` y `LC_ALL` a `English_United States.utf8` solo para el proceso, sin editar configuración.
- El generador histórico `enpg_rural.R` se localizó en el scratchpad temporal de la sesión `215d2ec1-a6ab-4b65-b380-e90a8722d52d`. Se conserva una copia documental exacta en [enpg_rural_tables_original.R.txt](enpg_rural_tables_original.R.txt), SHA256 `3622d2ea7fc9b15dfaeb5080c8876906e7153d375cd136a2e474a3ea5fca31b5`. Genera `enpg_rural_coverage.csv` y `enpg_rural_bias.csv`, lee el cache de diseño y selecciona personas de 15–65 con sexo válido y ponderador positivo. No se reejecutó: los CSV históricos se conservan.
- El generador `rural_gap.R`, localizado en el mismo scratchpad, calcula `noncov = 1 - urbano_en_comunas_observadas / total` con INE **2023, todas las edades**, usando la unión de comunas observadas 2022/2024. Ese indicador contextual de los modelos EPS no es el porcentaje nacional 2024 de 15–64 calculado aquí. No se modificaron ni reejecutaron esos modelos.
- Se corrigieron las tarjetas y explicaciones de cobertura de la guía; los tres indicadores históricos de cobertura incrustados se sincronizaron con su CSV. El resto de las estimaciones de consumo queda fuera de esta revisión.

## Frase para el outline

En 2024, aproximadamente el 21,9% de la población de 15–64 años quedaría fuera de la cobertura geográfica de ENPG, estimación provisional basada en proyecciones INE y en las comunas observadas como aproximación al marco.

## Extensión a 2012–2024 (2026-10-26)

Se aplica la misma partición a cada ola: población INE del año de la encuesta, ambos sexos y edades 15–64. La serie usa las comunas observadas de cada ola del cache de diseño ENPG; no se han contrastado con directorios oficiales independientes del marco de cada año. Se armoniza el código histórico de Chillán (8401 → 16101) para enlazar con INE.

| Año | Comunas observadas | Población total | Urbana cubierta | A: fuera de comunas | B: rural dentro | Excluido |
|---|---:|---:|---:|---:|---:|---:|
| 2012 | 108 | 11.998.670 | 9.222.687 | 2.239.021 | 536.962 | 23,14% |
| 2014 | 108 | 12.251.374 | 9.421.653 | 2.282.019 | 547.702 | 23,10% |
| 2016 | 108 | 12.488.678 | 9.614.859 | 2.318.731 | 555.088 | 23,01% |
| 2018 | 109 | 12.890.070 | 9.982.173 | 2.336.416 | 571.481 | 22,56% |
| 2020 | 109 | 13.361.656 | 10.404.214 | 2.372.973 | 584.469 | 22,13% |
| 2022 | 109 | 13.528.576 | 10.552.521 | 2.388.190 | 587.865 | 22,00% |
| 2024 | 109 | 13.619.165 | 10.630.379 | 2.399.620 | 589.166 | 21,95% |

El cambio de 2012 a 2024 es de −1,19 puntos porcentuales. Es descriptivo: combina evolución demográfica y cambios de la lista observada (108 a 109 comunas), no demuestra cambios de sesgo en alcohol. No se añade intervalo de confianza.

[CSV de resultados](enpg_geographic_coverage_2012_2024.csv), [listas comunales por año](enpg_geographic_coverage_2012_2024_communes.csv), [MD5 de insumos](enpg_geographic_coverage_2012_2024_sources.csv) y [script](calculate_enpg_geographic_coverage_series.R). Ejecutar desde la raíz con `Rscript __andres_control/calculate_enpg_geographic_coverage_series.R`, usando el mismo entorno indicado arriba. El script no reejecuta modelos.

Validación con insumos reales: las listas completas del cache reproducen, en todas las olas, el número de comunas y ambos porcentajes poblacionales del CSV histórico (cuyo generador filtraba personas de 15–65). Para cada año se verifica total = cubierta + A + B y la igualdad de las dos fórmulas de exclusión; 2024 reproduce además el cálculo anterior desde la base pública. La comprobación independiente en Python suma de nuevo las celdas INE según las listas exportadas. La guía permite consultar el resultado de cada año en su selector histórico.

## Exploración de 15–65: antecedente cerrado

Se exploró obtener un rango exacto de 15–65 antes de preparar el HTML. Posteriormente, el usuario decidió conservar **15–64**, descartar la imputación del año 65 con Censo 2024 y no ampliar el alcance. La búsqueda de 15–65 ya no bloquea la entrega; se conserva abajo como antecedente.

Verificación del 2026-10-26: los Excel locales con edades simples no contienen el cruce comuna × área. Se descargó y revisó el [Excel original INE comunal urbano-rural](https://www.ine.gob.cl/docs/default-source/proyecciones-de-poblacion/cuadros-estadisticos/base-2017/estimaciones-y-proyecciones-2002-2035-comuna-y-%C3%A1rea-urbana-y-rural11df0b16cde04242827bef3fd62529c5.xlsx): tiene una sola hoja, `EEPP comuna área`, con grupos 60–64 y 65–69, sin una fila independiente para 65 años. Todas sus columnas numéricas coinciden con el CSV local. SHA256 del Excel: `32c31ba17e9632cc98ca4dcd4e238fc1fffb34cdbc15447ea247eaadb6dba024`.

La [metodología INE de septiembre de 2021](https://www.ine.gob.cl/docs/default-source/proyecciones-de-poblacion/metodologia/proyecci%C3%B3n-base-2017/estimaciones-y-proyecciones-2002-2035-comunas-y-%C3%A1rea-metodolog%C3%ADa.pdf?sfvrsn=71c4ebf1_4), introducción y secciones 2.2–2.3, distingue publicación quinquenal y cálculo interno por edad simple. Esto apoya solicitar el tabulado, pero no demuestra que la base de edades simples esté disponible públicamente ni permite reconstruirla exactamente.

Insumo que se habría requerido para 15–65 (fuera del alcance final): población final ajustada INE base 2017 por año (2012, 2014, 2016, 2018, 2020, 2022 y 2024), código de comuna, área urbana/rural, sexo y edad simple de 15 a 65 inclusive. Alternativamente basta obtener la población exacta de 65 años con ese mismo cruce y base para sumarla a la serie 15–64 validada. Solicitar fecha de referencia, versión, diccionario territorial y consistencia con la publicación quinquenal. No se ha enviado ninguna solicitud externa.

El gráfico se titula subcobertura geográfica: la población excluida no identifica la dirección ni magnitud de un sesgo de consumo. La serie provisional de 15–64 queda conservada y verificada, sin convertirla en una estimación 15–65. No se añadió una nueva entrada al handoff por indicación del usuario.


## HTML exportable de 15–64 años

[**Abrir el HTML autocontenido**](enpg_cobertura_geografica_15_64.html). Contiene barras nacionales de los componentes A y B, mapa de calor de 16 regiones × 7 años y un desglose interactivo por territorio y año. Cada celda del mapa de calor usa el total de su propia región como denominador. Se conserva la geografía regional de INE a lo largo de toda la serie, incluida Ñuble antes de su creación administrativa.

El archivo funciona sin conexión e incluye botones para guardar una copia HTML, descargar datos nacionales y regionales en CSV, descargar el gráfico nacional SVG e imprimir/exportar a PDF desde el navegador. No depende de archivos locales adicionales ni servicios externos. Las fuentes y hashes están incorporados.

Generador: `build_enpg_coverage_html.py` (biblioteca estándar de Python); insumos: CSV INE, resultados nacionales y listas comunales ya verificadas. Salida regional: `enpg_geographic_coverage_regions_2012_2024.csv`, 112 filas. No se incorporaron datos censales ni se imputaron edades.

Validaciones realizadas: 112 particiones regionales, igualdad con la fórmula complementaria y sumas regionales que reproducen todos los totales nacionales. Prueba en navegador Edge sin acceso de red: controles de región/año, selección de celdas, exportación CSV/SVG/HTML, reapertura del HTML exportado, ausencia de errores JavaScript y desbordamiento general en móvil. Inspección visual a 1280 y 390 píxeles; las tablas y el gráfico admiten desplazamiento horizontal en móvil para mantener las etiquetas legibles. No se reejecutaron modelos de consumo. No se añadió una entrada al handoff para esta extensión.
