# Ampliación a tres intervalos

Alcance: nuevos análisis 2016→2018 y 2018→2021; reutilización de agregados 2021→2023. Notebook nuevo junto a los notebooks de control, HTML autocontenido en la raíz. No editar motores ni notebooks existentes; no exportar microdatos.

1. Verificar preguntas, códigos, muestras, fechas y diseño → auditoría por ola y fuentes oficiales. Control: metadatos y rutas contra respuestas observadas.
2. Calcular dos pares nuevos sin exigir panel completo → matrices y flujos con edad 18–65 al origen. Control: unicidad, denominadores, filas de probabilidades y faltantes.
3. Comparar los tres períodos conservando sus estimandos → tabla comparativa y soporte de personas repetidas. Control: último par coincide exactamente con agregados previos; sin inferencia conjunta que ignore repetición.
4. Crear y ejecutar notebook R, renderizar HTML con estilo del notebook EPS v2 → artefactos legibles y README actualizado. Control: ejecución completa, HTML autocontenido y archivos originales conservados.

Pregunta exploratoria previa: ¿se repiten la persistencia de regularidad y la dirección ordinal de frecuencia, teniendo presentes cambios de modo, composición y duración? No se presupone estabilidad ni se estima una matriz anual común.

## Cierre verificado

- Instrumentos 2018/2021 cotejados nuevamente; 2016 respaldado por revisión previa y diccionario/SAV, sin nueva descarga exitosa del PDF. 2023 mantiene pendiente CATI/modo individual. Pesos disponibles, pertinencia específica por par pendiente.
- Dos pares calculados con validaciones sobre microdatos reales. S09: 1.888/2.261/1.796; S10: 438/631/502. Edad inicial, rutas y denominadores verificados. Ninguna exigencia de participación intermedia.
- Revisión independiente de agregados: filas suman uno; eventos suman N; cuatro tablas del último par coinciden exactamente con las previas. Se contabilizaron personas repetidas sin estimar inferencia agrupada.
- Notebook ejecutado completamente: 13 celdas de código sin errores. HTML autocontenido en la raíz, 33 tablas y dos figuras; recursos incorporados y enlaces locales comprobados. Figuras inspeccionadas visualmente. README exploratorio y mapa externo actualizados.
- Hashes previos: tablas, script e informe del último par y notebooks originales permanecen iguales; únicamente se añadió un aviso de ampliación al README previo. No se modificaron motores.

Riesgo residual: bootstrap parcial de segmentos, sin resolver primera etapa de ciudades, atrición ni efecto de modalidad. No se infiere cambio poblacional ni se valida el motor anual. Las celdas S10 de mujeres 60–65 son especialmente pequeñas (9/15/19).

## Copia interna autorizada posteriormente

Se añadió `_elsoc/` con bundle cifrado y manifiesto, cuatro documentos oficiales y copia adaptada del mapa. Los dos scripts ahora leen mediante `acc_data()`; el resto del cálculo no cambió. Se reejecutó la ampliación desde el bundle y se comprobaron tamaños, hashes de las tablas previas y preservación de todos los archivos externos. Enlaces y HTML actualizados. Evidencia: [repository_copy_validation.json](intervals/repository_copy_validation.json). Los cambios de ruta de esta etapa son posteriores a la comprobación de conservación del script original registrada arriba.

## Instrucción final: ejecución y render diferidos

Con `MACHINE_ID=DELL_LR` confirmado por el usuario, se añadió el registro al [handoff principal](../codex_handoff_adam_rr_full_override_caveman.md), preservando su contenido anterior. Cinco PDF de origen se copiaron cifrados a `_elsoc/docs/elsoc_documentacion_pdf.tar.xz.enc`, con manifiesto y recuperación MD5 verificados; se conservan con la encuesta, sin duplicarlos en `_bib/`. El SAV ya cifrado se verificó de nuevo. Tras esta instrucción no se ejecutó el análisis ni el notebook y no se renderizó: el cuaderno quedó preparado con aviso de estado y el HTML anterior permanece idéntico. Solo se ejecutaron utilidades de cifrado y comprobaciones de archivos.
