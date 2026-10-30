# DIR: variables, fuentes y métricas previstas

29-oct-2026. Alcance solicitado para selección futura: REM A03, A27, A02, A05 y A07, REM P6, inscritos APS y beneficiarios, con diccionarios y catálogos históricos. Incluir A02 y A07. No son extracciones ejecutadas ni validación del modelo. Conservar nombres y códigos originales, versiones, todos los campos originales disponibles de Serie A (Col01–Col50), y controles por año; confirmar mapas con los diccionarios de cada versión.

## Unidad, identificadores y resultados

Serie A: establecimiento × mes × código de prestación, con `IdEstablecimiento`, `IdServicio`, `Ano`, `Mes`, `CodigoPrestacion` y demás identificadores originales, incluido `IdComuna` si existe en el año. `Col01` representa total ambos sexos cuando corresponda al código; comprobar cada diccionario. Una fila representa un registro agregado, no una persona.

Resultados previstos 2025–2034: muertes atribuibles evitables, años de vida perdidos (YLL) según esperanza de vida chilena (HMD/DEIS) y, secundariamente, años potenciales de vida perdidos antes de 75 (AVPP/YPLL <75). DEIS, tabla de vida, RR y motor corresponden a módulos adicionales; REM por sí sola no genera estos resultados.

## Serie A y P

| Sección | Variables y uso | Límites y controles |
|---|---|---|
| A03 D.1 | Tamizajes y resultados: Col02–03 sexo; edad × sexo desde Col04. En 2019–2020 Col04–15; desde 2021 Col04–19 según contraste, revisar diccionario anual. SENAME Col20 y Mejor Niñez Col21 en 2025. AUDIT 03500346 + 03500347; resultados 03500349, 03500290, 03500300. Conservar también ASSIST/CRAFFT y los códigos disponibles por año. | Registra aplicaciones y resultados agregados, no personas únicas; instrumentos y sustancias pueden mezclarse. No identifica 15–17 o 18–19 por separado ni repetición. |
| A27 G/F | Intervención mínima, breve y referencia por sustancia; edad Col02–07, sexo Col08–09; IB alcohol 27300929 y referencia alcohol 27300932; conservar 27300926–27300934 cuando existan. | No cruza edad × sexo ni enlaza una intervención con su tamizaje. El contraste informa que para IB alcohol los márgenes de sexo casi igualan al total nacional 2019/2024; no afirmar una brecha de 6% sin precisar código, año y evidencia. |
| A02 B | EMP por edad y sexo, Col04–31; códigos 03030101, 03030102, 03030103, 03030104, 03030350, 03030110, 03030330, 03030340, 03030120 y 03030130, verificar sección y versiones. | Porcentaje EMP con AUDIT solo si numerador y denominador corresponden a la misma unidad y población; no identifica enlace individual. Paso previo opcional del modelo. |
| A05 N | Ingresos salud mental: 09600297 y 09600298 alcohol; 05990036 drogas y alcohol desde 2023; revisar predecesores 06901500 y 06901700 en 2019–2022. | Puente entre códigos a evaluar; no asumir equivalencia ni enlace con referencias. |
| A07 | Consultas nuevas de psiquiatría adulto 07021900; conservar campos y diccionario anual. | Indicador de actividad/capacidad, no diagnóstico alcohol; cortes de edad pueden cambiar. |
| P6 | Alcohol y drogas, APS y especialidad; códigos y predecesores con diccionario anual, cortes junio y diciembre. | Existencias, no ingresos; categorías pueden superponerse y no se suman cortes. |

Incluir los metadatos, códigos y diccionarios originales por año y el catálogo de establecimientos correspondiente. La comparación independiente de las 3.306 celdas y el mapeo anual proviene del informe de Claude; no se repitió en esta actualización.

## Indicadores solicitados: 2024, 15–64

| Indicador | Numerador / denominador | Interpretación |
|---|---|---|
| Cobertura AUDIT | 1.103.414 aplicaciones (03500346 + 03500347) / 9.432.037 A–D = 11,7%; con X: /10.129.879 = 10,9% | Denominadores 2023 prorrateados con estructura INE, no conteos exactos; razón de aplicaciones. Usar como supuesto provisional de modelación, no cobertura individual observada; una aplicación por persona/año es supuesto. |
| Positividad | (03500290 + 03500300) / (03500349 + 03500290 + 03500300) = 84.971 / 1.289.663 = 6,59% | Resultados agrupados por instrumento; «8+» no es rótulo universal para AUDIT, ASSIST y CRAFFT. |
| IB alcohol | 27300929 / 03500290 = 31.370 / 60.326 = 52,00 por 100 | Cociente agregado; denominador de riesgo de varios instrumentos/sustancias. La magnitud o dirección de sesgo de una probabilidad individual no se identifica. |
| Referencia alcohol | 27300932 / 03500300 = 11.568 / 24.645 = 46,94 por 100 | Cociente agregado, sin enlace individual; el denominador incluye otros instrumentos/sustancias. No se identifica la magnitud del sesgo. |
| Ingreso especialidad / referencia | A05 09600297 + 09600298 en niveles secundario y terciario SNSS / 27300932 = 1.341 / 11.568 = 11,59 por 100; todas las edades 10,67 y 36,96 al sumar 05990036, según material proporcionado | Comparación de volúmenes de ingresos y atenciones, sin enlace ni población necesariamente equivalente; no es probabilidad ni techo individual demostrado. Verificar definición del numerador y reproducir los totales antes de usar. |

Las cifras 2024 están documentadas en la auditoría y contraste, salvo comparaciones de especialidad que deben verificarse. Las estimaciones de 2022 son sensibilidad con cortes anteriores, no cotas demostradas ni validación de 2024.

## FONASA y selección

Inscritos APS 2023: una fila por centro × tramo × edad agrupada × sexo. Campos observados: `PERIODO`, `SERVICIO_SALUD`, `REGIÓN`, `COMUNA`, `COD_CENTRO`, `NOMBRE_CENTRO`, `NOMBRE_DEPENDENCIA`, `TRAMO`, `EDAD_TRAMO`, `SEXO`, `TOTAL_INSCRITOS`. `TRAMO` A–D y X; edad 0–19, 20–39, 40–59, 60–79, 80+ y sin información. No existe el campo combinado `SEXO_TOTAL_INSCRITOS`. X y validación administrativa pendientes.

Inscritos septiembre 2022 tienen quinquenios; beneficiarios diciembre 2022 tienen `INSCRITO_APS` y `CUENTA_BENEFICIARIOS`. Conservarlos separados, con corte, definiciones y totales. Seleccionar por año las series y códigos completos necesarios para reproducir resultados y sensibilidades, junto con diccionarios y controles; no confundir estimaciones comprimidas con tamaño efectivo de cada bundle cifrado.
