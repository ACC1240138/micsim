# ELSOC: factibilidad y mapa de armonización con EPS y TSM

## Archivos internos y próxima ejecución

Se conserva la documentación de origen en esta carpeta, junto a la encuesta. `_bib/` está en la raíz del repositorio y se reserva aquí para bibliografía general; no se duplican allí estos archivos ELSOC.

| Copia interna | Contenido | Acceso |
|---|---|---|
| `elsoc_wide_2016_2023.tar.xz.enc` | `ELSOC_Wide_2016_2023.sav` (Harvard Dataverse [10.7910/DVN/LD4BPH](https://doi.org/10.7910/DVN/LD4BPH), «Estudio Longitudinal Social de Chile 2016-2023», **versión 3.0, 27-12-2024**; MD5 `dac64998f382fc99a5688ee8b5947db3` coincide con el listado de archivos de esa versión; licencia CC0 1.0. Verificado 21-10-2026 por API, sin descargar) | `acc_data("_elsoc/elsoc_wide_2016_2023.tar.xz.enc")` |
| `docs/elsoc_documentacion_pdf.tar.xz.enc` | `LIBRO_2016.pdf`, `LIBRO_2017.pdf`, `LIBRO_2018.pdf`, `LIBRO_2019.pdf` y `Radiografia-Cohesion-social-2016-2023-Calidad-de-los-vinculos-sociales.pdf` | `acc_data("_elsoc/docs/elsoc_documentacion_pdf.tar.xz.enc", "LIBRO_2016.pdf")`; cambiar el nombre para otro PDF. |

Ambos bundles incluyen su manifiesto `.tar.xz.enc.md5.csv`. Usar primero `source(here::here("_tools", "acc_data.R"))`; los archivos se descifran en `tempdir()`. Las copias recuperadas se verificaron por MD5 contra los originales. No hay SAV ni PDF sueltos en `_elsoc/`; los documentos CSV/Rmd permanecen legibles. Los enlaces a los PDF cifrados descargan el bundle, no un PDF directamente.

**Estado solicitado:** lectores y notebook preparados para ejecutar después. Tras esta última instrucción no se ejecutó ni renderizó el notebook; el HTML conserva la versión generada anteriormente. La comprobación de cifrado no ejecuta el análisis. Los originales de la carpeta ELSOC siguen intactos.

> Copia incorporada a MiCSim el 20-10-2026. La carpeta ELSOC original permanece intacta. Los datos del análisis se guardan en `elsoc_wide_2016_2023.tar.xz.enc`, con manifiesto `elsoc_wide_2016_2023.tar.xz.enc.md5.csv`; se leen mediante `_tools/acc_data.R` y `acc_data()`, descifrando solamente en `tempdir()`. Se requiere `ACC_DATA_KEY` configurada localmente, nunca escrita en archivos compartidos.
>
> `docs/` conserva copias exactas del listado global, los dos cuestionarios CAPI 2023 y el manual metodológico Rmd (documentación, no pipeline ejecutable). Los enlaces a auditorías históricas no copiadas apuntan a la carpeta externa; no son dependencias del cálculo. El mapa documental original sigue debajo, con sus enlaces ajustados.
>
> Reproducción desde la raíz: `Rscript __andres_control/elsoc_2021_2023_exploration/extend_intervals.R`. Conservar `tables/` de esa carpeta: contiene los agregados 2021→2023 reutilizados. El notebook y el HTML permanecen en sus ubicaciones actuales. El MD5 del SAV recuperado debe ser `dac64998f382fc99a5688ee8b5947db3`.

## Ampliación empírica: tres intervalos

Los tres enlaces son analizables, sin exigir participación en todas las olas. La estabilidad global de regularidad se repite cerca del 70%; **la dirección de frecuencia no se repite**: predominan disminuciones en 2016→2018 y 2021→2023, y aumentos en 2018→2021. Son resultados descriptivos sin ponderar, condicionados a reentrevista y respuesta válida; los intervalos y cambios de modalidad impiden interpretarlos como una dinámica anual constante.

| Intervalo | Muestras | Edad 18–65 inicial | Reentrevistados | Enlaces tras controles | Pares S09 | Pares S10 | Duración mediana, años [mín.; máx.] |
|---|---|---:|---:|---:|---:|---:|---|
| 2016→2018 | M1 | 2.562 | 1.937 | 1.917 | 1.888 | 438 | 2,026 [1,736; 2,283] |
| 2018→2021 | M1 + M2 | 3.221 | 2.286 | 2.281 | 2.261 | 631 | 2,423 [2,190; 2,872] |
| 2021→2023 | M1 + M2 | 2.300 | 1.815 | 1.802 | 1.796 | 502 | 2,930 [2,442; 3,253] |

Duraciones entre fechas individuales, sobre enlaces tras controles; no son intervalos nominales. M2 ingresa en 2018: no puede aportar origen 2016. [Tabla comparativa completa, incluidas M1/M2](../__andres_control/elsoc_2021_2023_exploration/intervals/interval_comparison.csv).

| Intervalo | S09 misma respuesta | Sigue regular, dado regular | Sigue no regular, dado no regular | S10 igual | S10 aumenta | S10 disminuye |
|---|---:|---:|---:|---:|---:|---:|
| 2016→2018 | 69,7% | 64,6% | 72,5% | 33,1% | 29,7% | 37,2% |
| 2018→2021 | 71,4% | 67,3% | 74,4% | 31,4% | 40,3% | 28,4% |
| 2021→2023 | 71,0% | 65,1% | 75,5% | 32,3% | 32,1% | 35,7% |

S10 se restringe a **regulares en ambos extremos y frecuencia válida en ambos**. S09/S10 **no constituyen AUDIT**. «No regular» puede incluir consumo ocasional: no es abstinencia. Omitir S10 por salto no significa frecuencia cero. No se calculan gramos/día, HED ni puntuaciones AUDIT.


[Notebook nuevo](../__andres_control/elsoc_transiciones_2016_2023.ipynb) · [HTML en la raíz de MiCSim](../elsoc_transiciones_2016_2023.html) · [Métodos, fuentes y decisiones de los tres pares](../__andres_control/elsoc_2021_2023_exploration/INTERVALS.md).

Se reutilizan las estimaciones previas 2021→2023 sin recalcular sus intervalos. No se exige panel completo. Los 5.945 pares S09 corresponden a 2.886 personas y los 1.571 pares S10 a 988; no se estima una matriz agrupada suponiendo independencia. Pesos disponibles no acreditan pertinencia específica de cada par: resultados sin ponderar, incertidumbre exploratoria por segmentos. Los escenarios ponderados (`total` / `panel` / sin ponderar) y las matrices de nueve estados con «no regular» como estado (observado, matriz A y lognormal como en EPS) se ejecutaron el 21-10-2026 en [elsoc_weighting_scenarios_EN.ipynb](../__andres_control/elsoc_weighting_scenarios_EN.ipynb), con hallazgos en [hallazgos_elsoc_ponderacion.md](../__andres_control/hallazgos_elsoc_ponderacion.md). Las secciones siguientes conservan la auditoría del último par y el mapa documental.

## Actualización empírica: enlace 2021→2023 verificado

Actualizado el 20-10-2026. **El enlace es analizable: 1.796 pares S09 y 502 pares S10**, entre participantes de 18–65 años en 2021, después de los controles descritos abajo. Son cambios entre entrevistas separadas por aproximadamente **2,93 años reales**, no transiciones anuales. Resultados sin ponderar, condicionados a reentrevistados; no constituyen validación del motor EPS.

El 71,0% conserva su respuesta de regularidad. Entre regulares en ambos extremos con frecuencia válida, 32,3% conserva categoría, 32,1% aumenta y 35,7% disminuye. El cambio pareado de regularidad es −1,11 puntos porcentuales (intervalo exploratorio del 95%: −3,60 a +1,26). No identifica un descenso poblacional concluyente.

[Análisis, decisiones y mapa operativo](../__andres_control/elsoc_2021_2023_exploration/README.md) · [Matrices y resultados por grupo](../__andres_control/elsoc_2021_2023_exploration/RESULTS.md) · [Script independiente](../__andres_control/elsoc_2021_2023_exploration/analysis.R).

Esta verificación reemplaza los pendientes de presencia y respuestas del SAV consignados en la revisión documental anterior. El análisis permanece separado de motores y notebooks; solo se exportan agregados.

| Ola / muestra | Entrevistados | S09=1 | S09=2 | S09 especial | S10 válido | S10 especial | S10 ausente por sistema |
|---|---:|---:|---:|---:|---:|---:|---:|
| 2021 M1 | 1.739 | 728 | 1.010 | 1 | 726 | 2 | 1.011 |
| 2021 M2 | 1.001 | 417 | 583 | 1 | 417 | 0 | 584 |
| 2023 M1 | 1.737 | 647 | 1.084 | 6 | 647 | 0 | 1.090 |
| 2023 M2 | 989 | 428 | 560 | 1 | 427 | 1 | 561 |

La tabla anterior usa todas las edades. En el dominio basal 18–65: 2.300 participantes, 1.815 reentrevistados (485 sin reentrevista: 21,1%), 1.802 enlaces tras controles, 1.796 pares S09 (1.127 M1; 669 M2) y 502 pares S10 (314 M1; 188 M2). Hay 174 retornos observados tras ausencia w06. No hay participantes basales de 18–19 años.

**Pesos:** el SAV sí contiene `ponderador_long_total_w07` y `ponderador_long_panel_w07`. El total cubre todos los pares S09; el panel completo cubre 1.500 y deja 296 sin peso. Falta confirmar construcción y pertinencia para w05→w07, M1/M2 y dominio; no se usó el CSV antiguo de olas 1–6 ni se inventaron pesos. Resultados no ponderados, con incertidumbre exploratoria por segmentos estratificados; no inferencia plenamente ajustada al diseño.

**Calidad y modo:** se excluyen dos discordancias de sexo y once fechas faltantes/inválidas adicionales. Se conservan marcados 516 enlaces cuya variación de edad discrepa del lapso real; sensibilidad estricta disponible. Fechas observadas: 29-01–12-07-2021 y 16-12-2023–14-05-2024. Mediana del intervalo 2,93 años; no dos años exactos. No se identificó modo individual CAPI/CATI: M1/M2 son muestras, no modos.

### Corrección empírica del universo S15

En M1 2023 hay **1.690 respuestas no negativas de 1.737 entrevistados**: 560 ceros, 1.130 positivas, 47 NS/NR; mediana 1, rango 0–24. Entre S09=2 hay 1.048 respuestas válidas, incluidas **495 positivas**. Entre S09=1 hay 640 válidas, de las cuales seis son cero. M2: 989 ausentes por sistema, ninguna respuesta válida. Son todas las edades, sin imponer el dominio de transiciones.

El orden y salto documental sugerían que S15 se restringía a regulares; **los microdatos contradicen esa inferencia**. No excluir las respuestas de no regulares ni corregirlas a cero. Pedir regla de administración/programación y significado de cero; lo observado no basta para asegurar cómo se preguntó en cada modo. [Auditoría S15](../__andres_control/elsoc_2021_2023_exploration/tables/s15_2023_audit.csv).

S15 aporta una distribución de vasos/copas en la última ocasión para M1, sin enlace de cantidad a 2021, donde el ítem no está disponible. Convertirla requeriría conocer volumen por recipiente, bebida/graduación y mezcla, recencia de esa ocasión y su representatividad de ocasiones habituales. Combinarla con S10 además exige modelar el universo de no regulares, la categoría <1 día, ocasiones por día y covariación entre frecuencia/cantidad. Ninguno de esos supuestos se impone ni se implementa gramos/día; tampoco se interpreta un umbral de copas como frecuencia de episodios intensivos.

### Decisión de armonización

S09/S10 permiten regularidad y frecuencia ordinal condicionada dentro de ELSOC; S09=2 no es abstinencia y el salto S10 no es cero. Las matrices EPS/TSM de no consumo y sus estados de volumen no tienen aquí escala común para comparar magnitudes. La triangulación por grupos es descriptiva, con tiempos y selección distintos. Si ELSOC se usa para calibrar el motor, ese mismo enlace no será evaluación independiente. Los detalles, fuentes, pesos separados de cada encuesta y decisiones pendientes están en el análisis enlazado.

Revisión documental y exploración empírica separada · 20 de octubre de 2026. No se modifican motores ni notebooks.

ELSOC permite estudiar persistencia del **consumo regular declarado** y cambios de frecuencia entre mediciones comparables. Las mediciones confirmadas de estos ítems son 2016, 2018, 2021 y 2023: intervalos nominales de dos y tres años, no enlaces anuales. Cantidad de la última ocasión se documenta en 2017, 2019 y, solo para la muestra original, en 2023. En 2023 M1 coinciden frecuencia y cantidad, pero no identifican gramos/día, abstinencia vitalicia ni episodios intensivos observados. Véase la actualización siguiente.

## Actualización 2023: documentos aportados el 20 de octubre de 2026 (antecedente documental)

**2023 ya puede incorporarse al mapa documental de armonización.** Esta actualización resuelve el pendiente sobre alcohol 2023 y complementa las tablas históricas de las secciones 3–5, cuyo alcance por ola se conserva cuando no incluyen expresamente 2023. En esa etapa documental no se analizaron respuestas individuales. La verificación empírica posterior se presenta arriba; no se estiman modelos.

### Fuente y versión

Repositorio oficial indicado por el usuario: **[elsoc-coes/manual-elsoc](https://github.com/elsoc-coes/manual-elsoc/)**. Rama `main`; commit consultado [`edd00962c2e7df86ccf90f28bf9fc7fade186b37`](https://github.com/elsoc-coes/manual-elsoc/commit/edd00962c2e7df86ccf90f28bf9fc7fade186b37), consulta 20-10-2026. Los enlaces siguientes fijan esa versión.

| Archivo local aportado | Fuente oficial cotejada | Resultado |
|---|---|---|
| [Listado global 2023](<docs/0A_Listado_Variables_Global_ELSOC_v2023(2_Items_Total).csv>) | [XLSX global](https://github.com/elsoc-coes/manual-elsoc/blob/edd00962c2e7df86ccf90f28bf9fc7fade186b37/inputs/0A_Listado_Variables_Global_ELSOC_v2023.xlsx), hoja `2_Items_Total` | Disponibilidad por ola/muestra y contenido de S09/S10/S15 concordantes. |
| [Cuestionario CAPI M1](<docs/cuestionario_2023_v18(seguimiento_capi_M1).csv>) | [XLSX cuestionario](https://github.com/elsoc-coes/manual-elsoc/blob/edd00962c2e7df86ccf90f28bf9fc7fade186b37/inputs/cuestionario_2023_v18.xlsx), hoja `seguimiento_capi_M1` | Muestra original: filas completas de S09/S10/S15 coinciden con la hoja oficial. |
| [Cuestionario CAPI M2](<docs/cuestionario_2023_v18(seguimiento_capi_M2).csv>) | Mismo XLSX, hoja `seguimiento_capi_M2` | Refresco: S09/S10 coinciden; S15 ausente en ambas versiones cotejadas. |
| [Manual inglés local](docs/manual-metodologico-elsoc-english.Rmd) | [Rmd del repositorio](https://github.com/elsoc-coes/manual-elsoc/blob/edd00962c2e7df86ccf90f28bf9fc7fade186b37/manual-metodologico-elsoc-english.Rmd) | Fuente documental adicional, no ejecutada. |

Los CSV usan separador **punto y coma** y `|` dentro de opciones/códigos. El listado inglés anterior no reemplaza al global 2023. `atriciones_encuestas(Usociety).csv` y `atriciones_encuestas(NZ AV).csv` contienen comparadores internacionales: **no son tasas de atrición ELSOC**. El Rmd calcula su tabla de atrición desde un objeto de datos; no contiene los resultados de esa tabla como cifras fijas.

### Alcohol 2023: pregunta, códigos y flujo

| Variable | Pregunta original | M1 original / M2 refresco | Códigos y referencia | Universo / comparabilidad |
|---|---|---|---|---|
| `s09` | ¿Consume usted regularmente bebidas alcohólicas como cerveza, vino, pisco u otros licores? | Sí / Sí | 1 Sí; 2 No; sin período explícito. | Si 1 pasa S10; si 2, −888 o −999 pasa S11_01. Misma regularidad declarada de 2016/2018/2021; no equivale a cualquier consumo EPS/TSM. |
| `s10` | En el último mes, ¿cuántos días a la semana consumió alguna bebida alcohólica? | Sí / Sí | 1 menos de un día; 2 un día; 3 dos; 4 tres; 5 cuatro; 6 cinco; 7 seis; 8 siete. | Solo S09=1. Mismo ítem que en 2016/2018/2021, sujeto a modo/versión; permanecen las diferencias de §3.2 respecto de EPS/TSM. |
| `s15` | Pensando en la última vez que usted consumió bebidas alcohólicas, ¿cuántos vasos o copas tomó aproximadamente? | **Sí / No** | Conteo abierto; última ocasión sin fecha ni gramos por copa. | La ruta sugería filtro S09=1, pero el SAV lo contradice: hay respuestas de no regulares. Ver corrección empírica arriba; programación pendiente. |

S15 aparece físicamente más abajo en el CSV, pero `Orden_Preguntas=226` la sitúa antes de S11_01: no usar el orden de filas como orden de administración. Los tres ítems incluyen −999 NR, −888 NS, −777 error técnico y −666 encuesta incompleta. El salto de S09 no explicita qué ocurre con −777/−666.

**Corrección a la conclusión anterior:** frecuencia y cantidad ya no están siempre en olas distintas; coinciden en 2023 M1. Aun así, última ocasión no es ocasión típica y no hay conversión documentada a gramos. No se propone gramos/día ni HED. S15 de 2023 tampoco debe compararse directamente con 2017/2019 sin resolver la discrepancia entre ruta documental y universo observado. La ausencia de S15 en M2 es estructural, no cero consumo.

### Covariables, seguimiento y pendientes

El listado y ambos cuestionarios documentan `m0_sexo`, `m0_edad`, `m01`, `m02`, `m33`, `m36`, `s08`, `s03` y `s11_01…09`. Sus definiciones/códigos conservan el mapa de §4: sexo 1/2; fecha de nacimiento para edad; educación 1…10; actividad principal último mes 1…9; vivienda 1…7; estado civil 1…9; cigarrillos/día último mes; salud 1…5; síntomas de dos semanas 1…5. Permanecen las pérdidas y supuestos de armonización con EPS/TSM.

Flujos adicionales: M01=1 (sin estudios) excluye M02=3/4 (estudia y trabaja/solo estudia); M02=1…3 pasa M03, otras respuestas válidas y NS/NR pasan M19. S08 admite 0…100 cigarrillos. Los dos cuestionarios son **CAPI**: M1/M2 distinguen muestras, no modalidades. Falta verificar instrumento y cobertura **CATI**.

El listado define `muestra`: 1 original, 2 refresco, y marca disponibles en 2023 `estrato`, `segmento`, `ponderador01/02`. Las variables creadas longitudinales pueden tener “No” en columnas de cuestionario y existir en el combinado: no inferir ausencia definitiva de esas banderas. Desde 2022 `tipo_atricion` usa 1 sin atrición / 2 con atrición; no describe por sí sola la secuencia completa de ausencias y retornos.

El CSV local de pesos contiene solo **olas 1…6**, verificado en su columna `ola`: no cubre w07. El listado describe pesos longitudinales construidos con 2016–2023, aunque conserva etiquetas 2016–2022. Se deben verificar los pesos de la entrega 2023 antes de ponderar pares con destino w07.

Hay una discrepancia de fechas: el Rmd nuevo describe terreno hasta **20 de mayo de 2024**, mientras la Radiografía citada antes indicaba hasta marzo. Su frase sobre el día de semana del 11-12-2023 también es discordante. Usar fechas individuales/versión final de terreno antes de fijar duraciones; no resolver la discrepancia por intuición.

**Uso verificado:** enlace nominal 2021→2023 analizado arriba con fechas reales y pares clasificables. Siguen pendientes modo individual, construcción de edad, programación S15 y pertinencia de pesos w07. No hay enlace anual por ausencia de alcohol en 2022.

## 1. Alcance, evidencia y antecedentes

Este README permanece en la carpeta exploratoria ELSOC, separada de MiCSim. Conserva intactos [la auditoría anterior](../../ELSOC/elsoc_auditoria_alcohol_2026-10.md), su script y los archivos originales. No existía un README en esta carpeta. Los enlaces `../` apuntan al repositorio hermano; no se copiaron documentos ni datos a sus carpetas principales.

**Convenciones de evidencia**

- **V — verificado:** cuestionario, diccionario o documento oficial leído; se especifica su alcance temporal.
- **A — ausente:** el instrumento revisado no incluye la medición buscada. No significa que nunca exista en otra versión.
- **P — pendiente:** falta fuente, diccionario de la entrega o verificación del filtro. Una columna con nombre parecido no resuelve el pendiente.
- **D — directamente comparable:** mismo constructo, referencia, universo y opciones, después de una recodificación inequívoca. No garantiza igual cobertura poblacional.
- **H — armonizable bajo supuestos:** se propone una categoría común más amplia o una aproximación; hay pérdida de información o diferencias residuales.
- **N — no comparable:** no existe transformación respaldada para el constructo solicitado.

Las preguntas se describen en forma abreviada; los cuestionarios enlazados conservan su redacción y flujo completos. Una fila que agrupa olas enumera aquellas a las que corresponde el mismo mapa; las excepciones están separadas. **Disponibilidad documental no equivale a observaciones válidas, ni a pares completos.** Esa limitación correspondía a la revisión documental inicial: la actualización empírica superior sí verifica el SAV y calcula nuevos conteos.

### Fuentes oficiales ELSOC

| Clave | Fuente y alcance revisado |
|---|---|
| E1 | [Cuestionario 2016, original](https://coes.cl/wp-content/uploads/2025/08/1_Cuestionario_Ola_1_Muestra_Original.pdf), salud/alcohol p.23, síntomas p.24, caracterización pp.25–29. |
| E2 | [Cuestionario 2017](https://coes.cl/wp-content/uploads/2025/08/2_Cuestionario_Ola_2_Muestra_Original.pdf), salud S3 y síntomas p.18, cantidad p.19, educación/actividad p.22. |
| E3 | [2018 original](https://coes.cl/wp-content/uploads/2025/08/3_Cuestionario_Ola_3_Muestra_Original.pdf), salud pp.21–23, caracterización pp.24–28; [2018 refresco](https://coes.cl/wp-content/uploads/2025/08/3_Cuestionario_Ola_3_Muestra_Refresco.pdf), salud pp.23–24, caracterización pp.25–30. |
| E4 | [2019 original](https://coes.cl/wp-content/uploads/2025/08/4_Cuestionario_Ola_4_Muestra_Original.pdf), salud/cantidad p.21, caracterización pp.22–23; [2019 refresco](https://coes.cl/wp-content/uploads/2025/08/4_Cuestionario_Ola_4_Muestra_Refresco.pdf), pp.23–25. |
| E5 | 2021 original [llamado A](https://coes.cl/wp-content/uploads/2025/08/5_Cuestionario_Ola_5_Muestra_Original_llamado_A.pdf), salud p.7, caracterización pp.9–13; [llamado B](https://coes.cl/wp-content/uploads/2025/08/5_Cuestionario_Ola_5_Muestra_Original_llamado_B.pdf), vivienda p.11. Refresco [llamado A](https://coes.cl/wp-content/uploads/2025/08/5_Cuestionario_Ola_5_Muestra_Refresco_llamado_A.pdf), salud pp.10–11; [llamado B](https://coes.cl/wp-content/uploads/2025/08/5_Cuestionario_Ola_5_Muestra_Refresco_llamado_B.pdf), vivienda p.13. |
| E6 | 2022 [original](https://drive.google.com/file/d/1jY5wi9fDkbJg0KR3TkkZiv_nXTcQeRoM/view) y [refresco](https://drive.google.com/file/d/17c90MUDxQXxLxFpF-gD1MlyzOK5xsLUi/view), enlazados por COES. Original: salud p.63, síntomas pp.64–66, educación/actividad pp.76–77, estado civil p.81; versiones instrumentales presencial `_p` y telefónica `_ta`. |
| E7 | [Radiografía COES 2016–2023, calidad de los vínculos sociales](https://coes.cl/wp-content/uploads/2025/05/Radiografia-Cohesion-social-2016-2023-Calidad-de-los-vinculos-sociales.pdf), p.5: terreno sexta ola julio–octubre2022 y séptima diciembre2023–marzo2024, modo mixto y adaptación telefónica. No es diccionario ni cuestionario2023. |
| EC | Libro oficial: [salud y bienestar](https://manual-metodologico-elsoc.netlify.app/m%C3%B3dulo-de-salud-y-bienestar.html), [sociodemografía](https://manual-metodologico-elsoc.netlify.app/m%C3%B3dulo-sociodemogr%C3%A1fico.html), [identificación y diseño](https://manual-metodologico-elsoc.netlify.app/variables-de-identificacion-y-otras-variables). Estas páginas conservan el rótulo 2016–2021, aunque el manual principal se actualizó a 2016–2022: no prueban por sí solas presencia en 2022/2023. |
| EM | Manual: [ficha técnica](https://manual-metodologico-elsoc.netlify.app/fichas-t%C3%A9cnicas.html), [cambios de instrumento y modo](https://manual-metodologico-elsoc.netlify.app/dis-cuestionario), [atrición](https://manual-metodologico-elsoc.netlify.app/atricion), [ponderadores transversales](https://manual-metodologico-elsoc.netlify.app/dis_ponderadores). |
| EL | [Informe oficial de ponderadores longitudinales](https://pondedradores-long-elsoc.netlify.app/), enlazado desde EM. El dominio contiene literalmente «pondedradores». |
| EP | [Portal de cuestionarios](https://coes.cl/cuestionarios/) y [listado de variables](https://manual-metodologico-elsoc.netlify.app/listado-de-variables). |

Los archivos locales `BASE_2016_COD.xlsx`…`BASE_2019_COD.xlsx` y `LIBRO_2016.pdf`…`LIBRO_2019.pdf` están identificados en la auditoría previa como documentación territorial; no se utilizaron para inferir los ítems individuales. `05-libro-codigos.Rmd` contiene advertencias editoriales sin resolver y cifras contradictorias: no se usó como versión definitiva.

### Fuentes EPS y TSM

| Clave | Documentación oficial local / alcance |
|---|---|
| P6 | [EPS VI: cuestionario 2015](<../_eps/docs/2015/instrucciones/Cuestionario EPS 2015.pdf>), terreno 2016; alcohol p.48 del PDF. |
| P7 | [EPS VII: cuestionario presencial vivos](<../_eps/docs/Bases y Documentos EPS 2020/Documentos EPS 2020/Cuestionarios EPS VII Ronda/EPS PRESENCIAL VIVOS.pdf>), alcohol p.45; [libro de códigos presencial](<../_eps/docs/Bases y Documentos EPS 2020/2020/Bases_EPS2020_presencial/01 Libro_de_Códigos EPS Presencial_Vivo.xlsx>), módulos A, B, D, F, I. |
| P8 | [EPS VIII: cuestionario vivos](<../_eps/docs/Documentos EPS VIII Ronda/Cuestionarios/Cuadernillo EPS VIII Ronda - Personas Vivas.pdf>), alcohol p.47, síntomas p.52 del PDF; [diccionario VIII](<../_eps/docs/Bases de datos EPS VIII Ronda/Diccionario de variables VIII EPS.xlsx>). |
| PM | [Informe metodológico VII](<../_eps/docs/Bases y Documentos EPS 2020/Documentos EPS 2020/EPS - Informe Metodologico-Muestreo, Atrición, Factores, Errores Muestrales.pdf>); [informe técnico VIII](<../_eps/docs/Documentos EPS VIII Ronda/Informe técnico/Informe Técnico EPS VIII Ronda.pdf>), §§4.2–4.3 y 5.3. [Inventario EPS](../_eps/README.md) para continuidad/reentrevista telefónica y otras rondas. |
| T7–T10 | Cuestionarios institucionales [R7](<../_tsm/docs/Cuestionario R7.pdf>), [R8](<../_tsm/docs/Cuestionario R8.pdf>), [R9](<../_tsm/docs/Cuestionario R9.pdf>), [R10](<../_tsm/docs/Cuestionario R10.pdf>): alcohol/tabaco p.17; roster pp.3–4; educación p.7; trabajo p.8; vivienda/salud pp.28–29. Síntomas p.22 en R7/R8 y p.21 en R9/R10. |
| TM | [ACHS: TSM](https://www.achs.cl/termometro-salud-mental), [ACHS: novena ronda](https://www.achs.cl/centro-de-noticias/noticia/2024/novena-ronda-del-term%C3%B3metro-de-la-salud-mental-achs-uc), [UC: inicio R11, marzo 2025](https://encuestas.uc.cl/?p=2525). |
| TL | [Metadatos SAV exportados por el proyecto](../_tsm/notes/CODEBOOK_TSM_SAV_variables.csv) y [diccionario de trabajo](../_tsm/notes/diccionario_TSM_variables_relevantes.csv). Son evidencia auxiliar de nombres/etiquetas, **no un diccionario oficial publicado**. R11 está respaldada aquí solo por metadatos; falta cotejar cuestionario y saltos. |

El [índice oficial de documentación EPS](https://previsionsocial.gob.cl/datos-estadisticos/documentos-eps-y-otras-encuestas/) permite localizar las publicaciones originales; para esta revisión se utilizaron las copias oficiales locales enlazadas.

## 2. Calendario y enlaces: qué se repite realmente

| ELSOC, ola | Regularidad `s09` y frecuencia `s10` | Cantidad última ocasión `s15` | Enlace del mismo constructo y cambios |
|---|---|---|---|
| w01 / 2016 | V, E1 p.23 | A | Origen del panel original; entrevista presencial. |
| w02 / 2017 | A, E2 | V, E2 p.19 | No proporciona destino anual de `s09/s10` de 2016. |
| w03 / 2018 | V, E3 original p.22 y refresco p.23 | A | 2016→2018: dos años nominales para regularidad/frecuencia; refresco entra en 2018, no tiene origen 2016. |
| w04 / 2019 | A, E4 | V, original p.21 y refresco p.23 | 2017→2019: dos años nominales para cantidad última ocasión. El trabajo de campo de esta ola se extendió a 2020; usar fechas. |
| 2020 | Sin ola independiente en esta secuencia | — | No crear observación anual por el año de una entrevista de ola 2019. |
| w05 / 2021 | V, E5 llamado A, ambas muestras | A, llamados A/B revisados | 2018→2021: tres años nominales; 2016→2021: cinco. CATI en dos llamados, cambio de modo confirmado por EM. |
| w06 / 2022 | A, E6 original y refresco | A, E6 original y refresco | Confirmación independiente: ambos instrumentos carecen de estos ítems de alcohol. No hay enlace2021→2022. Modo mixto CAPI/CATI; terreno julio–octubre2022. |
| w07 / 2023 | V en CAPI M1/M2 y SAV, respuestas válidas en ambas muestras | V en M1; A en M2 | Enlace analizado arriba. S15 también respondida por no regulares; modo individual y ruta efectiva pendientes. Fechas observadas hasta mayo de 2024. |

**Resultado confirmado hasta w07:** S09/S10 se repiten en 2023, pero no hay enlace anual 2022→2023 porque 2022 carece de alcohol. La alternancia 2016 frecuencia → 2017 cantidad → 2018 frecuencia tampoco constituye una serie anual homogénea.

EPS VI (rótulo 2015, terreno 2016), VII presencial (2019–2020) y VIII (2023–2024) tampoco observan transiciones anuales. La VII telefónica mide cambio relativo y no reemplaza F13–F15. TSM R7 abril 2023, R8 diciembre 2023, R9 abril 2024 y R10 noviembre 2024 tiene separaciones aproximadas de 8, 4 y 7 meses; R7→R9 es aproximadamente anual. Para R11, ACHS la sitúa en abril 2025 y UC anuncia inicio en marzo: falta fecha individual y límites exactos de terreno. Usar diferencias de fechas, no número de ronda.

## 3. Alcohol: mapas por constructo

### 3.1 Consumo / no consumo declarado

| Fuente y olas | Original, disponibilidad, pregunta / referencia | Códigos, universo y saltos | Definición común propuesta, transformación, pérdida y clase |
|---|---|---|---|
| ELSOC 2016, 2018, 2021 | `s09`, V. Consumo **regular** de cerveza, vino, pisco u otros licores; sin ventana retrospectiva explícita. E1/E3/E5. | 1 sí, 2 no; −888 NS, −999 NR. Entrevistado; 2/NS/NR saltan S10 y van a S11. | Conservar `regular_declared=1/0` para respuestas 1/2. **N** frente a «cualquier consumo» EPS/TSM; H solo como indicador propio, comparado descriptivamente con advertencia de umbral distinto. “No regular” puede incluir consumo ocasional. |
| ELSOC 2017, 2019 | A para `s09`. `s15` es cantidad de última ocasión. | Sin pregunta de consumo regular. | No inferir no consumo de cero copas, ni consumo actual de cantidad positiva sin fecha. **N**. |
| EPS VI, VII presencial, VIII | `f13_1`, `f13_2`, `f13_3`, V: consumo de cerveza, vino, pisco/otros licores, por separado; sin referencia explícita de período. P6–P8. | 1 sí, 2 no; faltantes por ola en §6. Todos los entrevistados; frecuencia/cantidad solo para bebidas consumidas. | `any_declared`: sí si alguna bebida=1; no solo si las tres=2; desconocido si no hay sí y falta alguna. Pierde bebida. **H** respecto de TSM; **N** como equivalente exacto a regularidad ELSOC. |
| TSM R7, R8, R9, R10; R11 solo TL | `e3a1`, V en R7–R10: frecuencia habitual, sin ventana explícita. | 1 nunca; 2 ≤1 vez/mes; 3 2–4 veces/mes; 4 2–3/semana; 5 ≥4/semana. Entrevistado; 1 salta a `e4a` y omite cantidad/HED. | `any_declared`: 1→0, 2:5→1. **H** con EPS, no prevalencia de últimos 12 meses; **N** con abstinencia vitalicia y con “no regular” ELSOC. |
| EPS VII teléfono | `fc101_1`: cambio de consumo relativo a habitual, referencia último mes. | Continuidad: 1 menos, 2 igual, 3 más; 7 NA, 8 NR, 9 NS. Formulario de reentrevista presenta inconsistencia de códigos: verificar diccionario. | **N** para consumo/no consumo absoluto. “Igual” no significa cero. |

### 3.2 Frecuencia e intensidad inicial para IPW

| Fuente y olas | Original y referencia | Códigos / universo | Propuesta, supuestos y pérdida |
|---|---|---|---|
| ELSOC 2016, 2018, 2021 | `s10`, V: días por semana durante el último mes. | Solo `s09=1`. 1 <1 día; 2=1, 3=2, 4=3, 5=4, 6=5, 7=6, 8=7 días. NS/NR negativos. | Para IPW interno: estado inicial propio `no_regular`, `regular_<1d`, `regular_1–2d`, `regular_≥3d`; conservar respuesta original. Para `s09=1` y S10 faltante, intensidad desconocida. **H**, no estados de gramos del motor. No convertir código1 en cero días. |
| EPS VI, VII presencial, VIII | `f14_1…3`, V: días/semana último mes, por bebida. | Solo bebidas declaradas. 0 <1 día; 1…7 días exactos; faltantes por ola. | Recodificación del ítem: ELSOC `s10−1` y EPS F14 comparten etiquetas **por ítem**, pero no universo ni cobertura de bebidas. **N** como frecuencia total exacta; H si se declara aproximación. No sumar días de bebidas: puede haber consumo simultáneo. El máximo es una cota inferior del total de días, no el total observado. |
| TSM R7–R10; R11 TL | `e3a1`, V/P según ola; frecuencia habitual sin período definido. | Categorías 1…5 de §3.1. | Una clasificación común semanal/no semanal exige asumir equivalencia de “veces” y “días” y cómo tratar 2–4/mes (puede aproximarse a semanal). **H** solo con sensibilidad; no existe cruce determinista completo a las bandas ELSOC. No sustituir frecuencias por puntos medios sin declarar el supuesto. |
| ELSOC 2017, 2019 | A para frecuencia | Cantidad no recupera frecuencia. | **N** como intensidad inicial de frecuencia en esos años. |

**Estado inicial del motor:** `state5`, `lg0`, `N0`, `FD`, `C1`, `C2`, `C3plus` son derivados de implementación, no nombres del cuestionario. ELSOC no observa `lg0` (consumo continuo) ni puede reproducir las categorías por gramos. Un IPW ELSOC puede incorporar S09/S10 iniciales, pero no será la misma especificación del IPW EPS. Mantener la historia observada separada de historia vitalicia.

### 3.3 Cantidad

| Fuente y olas | Original, disponibilidad y referencia | Opciones, universo y cambios | Transformación común / clase |
|---|---|---|---|
| ELSOC 2017, 2019 | `s15`, V: número aproximado de vasos/copas **la última vez** que consumió. E2/E4. | Respuesta numérica abierta; NS −888, NR −999. Sin filtro previo de consumo en el bloque revisado. No fecha de esa ocasión, ni tamaño/graduación del vaso. | Conservar conteo y referencia “última ocasión”. **N** frente a cantidad típica; H solo bajo supuesto explícito de representatividad de esa ocasión, que no se recomienda para validación principal. |
| ELSOC 2016, 2018, 2021 | A para `s15` | Se mide frecuencia, no cantidad. | No trasladar S15 de olas vecinas: supondría estabilidad no observada. |
| EPS VI, VII presencial, VIII | `f15_1…3`, V: vasos/copas de las veces que tomó, por bebida. | Numérica; solo bebida consumida. No dice última ocasión ni máximo. Sin tamaño y graduación observados en estos ítems. | Puede agruparse cantidad por bebida, pero no identificar cantidad total de una misma ocasión. **N** como equivalente directo de S15 o TSM; H con supuestos adicionales. |
| TSM R7–R10; R11 TL | `e3a2`, V/P: tragos en un día típico de consumo. | Solo consumidores. 1=0–2, 2=3–4, 3=5–6, 4=7–9, 5=10+. Primera banda incluye cero. | Retener ordinal. **N** como conteo exacto o última ocasión. Agrupar ELSOC en esas bandas no arregla la referencia temporal diferente. |

**Gramos/día: no identificados en ELSOC.** Hasta 2021 frecuencia y cantidad se miden en olas diferentes; en 2023 coinciden en M1, pero cantidad es de última ocasión y no hay conversión documentada de vaso a gramos. Tampoco los gramos derivados por el pipeline EPS/TSM son mediciones originales: requieren supuestos de bebida, tamaño, graduación o puntos representativos. No validar esos supuestos con una variable que no mide volumen.

### 3.4 Episodios intensivos e historia previa

| Constructo / fuente y olas | Original / disponibilidad / referencia | Opciones y universo | Correspondencia |
|---|---|---|---|
| Episodios intensivos, ELSOC 2016–2022 revisadas | A: no ítem de umbral y frecuencia de episodios en E1–E6. | Cantidad última ocasión no mide frecuencia de episodios. | **N** para HED;2023pendiente, no extender ausencia a esa ola. |
| Episodios intensivos, EPS VI/VII/VIII | A como medición directa en F13–F15. | No umbral por ocasión con período explícito. | **N**; cantidad elevada no es HED observado ni cantidades por bebida prueban misma ocasión. |
| Episodios intensivos, TSM R7–R10; R11 TL | `e3a3`: frecuencia de seis o más tragos en una ocasión; sin ventana explícita. | Solo consumidores; 1 nunca, 2 menos de mensual, 3 mensual, 4 semanal, 5 diaria/casi diaria. Mismo umbral para ambos sexos. | Conservar ordinal o 2:5 frente a1 **entre consumidores**. **N** frente a ELSOC/EPS y frente a umbrales 4/5 por sexo o ≥60 g últimos30 días. |
| Historia vitalicia, ELSOC E1–E6 | A: no edad de inicio, nunca en la vida o cesación fechada en el bloque alcohol;2022sin alcohol. | S09 no distingue exbebedores de ocasionales o abstemios. | **N** para “nunca”/“exbebedor”. Un sí previo→no posterior solo documenta salida del consumo regular declarado entre observaciones. |
| Historia vitalicia, EPS VI/VII/VIII | A en F13–F15. | Positivos previos permiten historia observada. | **N** para abstinencia vitalicia; “FD” necesita etiqueta “consumo previo observado”. |
| Cambio previo, TSM R7/R8 | `e3b`, V: respecto de antes de la pandemia. | Consumidores: 1 aumentó, 2 igual, 3 disminuyó. A en R9–R11 según TL. | **N** para historia vitalicia, inicio o cesación; no rellenar rondas posteriores. |

## 4. Covariables IPW: definición común y recodificaciones

Usar covariables medidas **en el origen del intervalo**. Una medición posterior no debe rellenar automáticamente el origen para predecir observación posterior. Los supuestos de transporte entre encuestas son distintos de los de ajuste de atrición dentro de cada encuesta.

### 4.1 Disponibilidad ELSOC por ola revisada

Los nombres son longitudinales del libro EC; el formulario puede usar M1/M2 en lugar de M01/M02. En base ancha se agregan sufijos `_w01`, etc.; no son nuevos constructos.

| Constructo / variable | 2016 | 2017 | 2018 original/refresco | 2019 original/refresco | 2021 original/refresco | 2022 / 2023 |
|---|---|---|---|---|---|---|
| Estado/intensidad `s09/s10` | V | A | V/V | A/A | V/V, llamado A | A / V CAPI |
| Sexo `m0_sexo`, edad `m0_edad` | V, origen Kish | V, EC | V/V | V/V, EC | V/V | P / V CAPI; edad desde nacimiento |
| Educación `m01` | V | V, formulario M1 | V/V | V/V, M1 | V/V, llamado A | V `_p/_ta` / V CAPI |
| Empleo/actividad `m02` | V | V, M2 | V/V | V/V, M2 | V/V, llamado A | V `_p/_ta` / V CAPI |
| Residencia `region/region_cod` | V, metadatos EC | V, EC | V, EC | V, EC | V, CUT2018 | P/P para versión/códigos |
| Vivienda `m33` | V | A en cuestionario | V/V | A/A en cuestionarios | V/V, **llamado B** | A / V CAPI |
| Pareja/estado civil `m36` | V | A en cuestionario | V/V | V/V | V/V, llamado A | V `_p/_ta` / V CAPI |
| Tabaco `s08` | V | A | V/V | A/A | V/V, llamado A | A / V CAPI |
| Síntomas `s11_01…09` | V | V | V/V | V/V | V/V, llamado A | V `_p/_ta` / V CAPI |
| Salud autopercibida `s03` | V | V, formulario S3 | V/V | V/V | V/V, llamado A | V `_p/_ta` / V CAPI |

La tenencia2021 puede faltar por no completar llamado B aunque se haya medido alcohol en A: esto es falta parcial, distinta de ausencia de ola. La presencia administrativa de sexo/edad/región no prueba que se repreguntó todo cada año. En2022 los nombres `_p`/`_ta` son instrumentales: pendiente corroborar nombre fusionado en base. E6 conserva códigos y referencias de educación, actividad, estado civil, salud y síntomas de las tablas siguientes, con NS−888/NR−999; sus filtros son secuencia de módulos/modalidad, sin restricción sustantiva identificada. No trasladar vivienda/tabaco de2021 sin marcar fecha.

### 4.2 Sexo y edad

| Fuente y olas | Original / pregunta y códigos / universo | Definición común, cambios, pérdida, clase |
|---|---|---|
| ELSOC, olas de §4.1 | `m0_sexo`:1 hombre,2 mujer; `m0_edad`: años. Respondente; ola1 desde Kish. Desde ola3 fecha mes/año de nacimiento y edad calculada al trabajo de campo; EC señala fecha completa desde ola6. | Sexo registrado y edad al origen. **D** con EPS/TSM para el constructo registrado; no identidad de género. Comprobar inconsistencias longitudinales antes de tratar sexo como fijo. |
| EPS VI/VII/VIII | `a8`:1 hombre,2 mujer; `a9`:edad. Roster: seleccionar entrevistado, no todos los familiares. | **D** tras seleccionar persona y fecha; VIII tiene preguntas distintas de identidad, no sustitutos de A8. |
| TSM R7–R10; R11 TL | `a2`:1 hombre,2 mujer; `a3`: años cumplidos, roster; seleccionar `Entrevistado=1`. | **D**; correcciones de edad no equivalen necesariamente a fallos de enlace. Bandas comunes pierden información. |

**Población común:** decidir rango etario y cobertura urbana antes de comparar. ELSOC selecciona originalmente 18–75 años, luego envejece; EPS VII pondera 23+; TSM tiene cobertura urbana adulta. Una comparación 18+ sin restricciones no representa el mismo universo.

### 4.3 Educación completada

| Fuente y olas | Variables / medición / códigos y filtros | Propuesta común, pérdida y clasificación |
|---|---|---|
| ELSOC, `m01`, §4.1 | Nivel actual si estudia, último aprobado si no. 1 sin estudios; 2 básica incompleta; 3 básica completa; 4 media incompleta; 5 media completa; 6 técnica superior incompleta; 7 técnica completa; 8 universitaria incompleta; 9 universitaria completa; 10 posgrado. Entrevistado; sin filtro de trabajo. | Tres niveles **completados** propuestos: básica o menos={1,2,3,4}; media={5,6,8}; superior={7,9,10}. **H**: 10 presupone pregrado completado; nivel incompleto no acredita título previo distinto. Pierde trayectoria técnica/universitaria y posgrado; no prueba titulación. |
| EPS VI | `a12n` nivel; `a12e` completitud no superior1sí2no; `a12d` superior:1 titulado,2 todos cursos aprobados sin título,3 no todos. Roster, seleccionar entrevistado. | **H**: decidir “cursos terminados” frente a “título obtenido”. No reducir a `a12n` solo. |
| EPS VII/VIII | `a12_n`, `a12_e`, `a12_d`; D cambia:1 titulado,2 licenciado,3 egresado,4 suspendió,5 sigue estudiando. | **H**; recodificar el significado de D por ola, nunca reutilizar el código2 o3 de VI sin conversión. |
| TSM R7–R10; R11 TL | `b1` estudia actualmente: 1 sí, 2 no; `b4a` nivel: 1 nunca, 2 preescolar, 3 especial, 4 básica, 5 media CH, 6 media TP, 7 técnica superior, 8 universidad, 9 posgrado, 10 NS/NR. `b4b`: curso aprobado si no estudia, **curso actual** si estudia; `b5` duración pregrado solo si posgrado. Roster, seleccionar entrevistado. | **H** solo con umbrales de duración y tratamiento de estudiantes explícitos; completitud/título no observados directamente: **pendiente, no implementar**. Alternativa de nivel alcanzado: B4a={1:4} básica o menos, {5,6} media, {7:9} superior, 10 faltante; educación especial exige revisión. Esta alternativa cambia el constructo y pierde completitud. |

Mantener códigos y banderas de completitud desconocida. No imponer educación máxima de todas las olas para IPW de línea base: usar información futura introduce otra definición y puede ocultar cambios/correcciones. La auditoría previa no demuestra que ELSOC sea inutilizable para educación; documenta problemas empíricos que requerirían revisión aparte.

**Códigos EPS de nivel (VI/VII/VIII):**1preescolar/parvularia;2básica;3diferencial;4preparatoria;5humanidades;6media científico-humanista;7técnica/comercial/industrial/normalista antigua;8media técnico-profesional;9CFT;10IP;11universitaria;12posgrado;13ninguno;88NR99NS. VI pregunta nivel alcanzado **o actual**; VII/VIII último nivel/curso aprobado (`a12_c`). A12e aplica a niveles1…8, con8NR9NS; A12d a9…12, con8NR9NS enVI y88NR99NS enVII/VIII. Los saltos de educación superior no son no respuesta de completitud. Antes de implementar hay que resolver educación diferencial, sistemas antiguos y finalización de superior; no se propone una equivalencia automática de todos los códigos a tres niveles.

**Regla EPS candidata, sin implementar:** niveles1,2,4,13 → básica o menos; niveles5…8 → media si A12e=1 y básica o menos si A12e=2; niveles9…12 → superior si termina cursos (VI A12d∈{1,2}; VII/VIII∈{1,2,3}), y media si no, bajo supuesto de media previa completa. Nivel3 diferencial y completitud desconocida quedan pendientes. Si se exige título, solo A12d=1 acredita ese criterio y cambia el mapa. Se pierde tipo de enseñanza y la distinción egreso/licenciatura/título; cotejar sistemas antiguos antes de adoptar.

### 4.4 Región / macrozona

| Fuente y olas | Variable y medición | Armonización |
|---|---|---|
| ELSOC, §4.1 | `region`, `region_cod`, residencia; EC indica actualización CUT2018 desde ola5. `estrato` representa tipo/tamaño de ciudad, no región. | **H**: usar código territorial y fecha; resolver Ñuble/Biobío y cambios administrativos. No usar `estrato` como macrozona. |
| EPS VI/VII/VIII | `a6a` es **región de nacimiento**, no residencia. No se verificó variable pública de residencia utilizable en la entrega del motor. | **N** con residencia ELSOC/TSM usando A6a. **P** obtener residencia oficial si se requiere; no inferirla de UPM/estrato anonimizado. |
| TSM R7–R11, TL | `IdRegion`, códigos1…16 de residencia;13 RM,14 Los Ríos,15 Arica y Parinacota,16 Ñuble. Metadato administrativo. | **H** con ELSOC al fijar territorio común. Propuesta explícita de macrozonas usada en pipeline: Norte={1,2,3,4,15}; Centro={5,6,7}; RM={13}; Sur={8,9,10,11,12,14,16}. Es una decisión analítica, no una equivalencia oficial. |

### 4.5 Tenencia de vivienda

| Fuente y olas | Original / referencia / códigos y universo | Definición común y pérdidas |
|---|---|---|
| ELSOC 2016,2018,2021 | `m33`: vivienda actual:1 propia pagada,2 propia pagando,3 arrendada,4 cedida por trabajo,5 propia compartida familias,6 cedida familiar/amigo,7 otra. Todos; 2021 llamado B. A en2017/2019 revisadas. | Propia={1,2,5}; no propia={3,4,6};7 indeterminada salvo aclaración. **H**: condición de vivienda, no propiedad individual. Pierde deuda, arriendo/cesión y propiedad compartida. |
| EPS VI | `d7`:1 propia pagada,2 pagando,3 compartida hogares,4 arrendada,5 cedida empresa,6 familiar/amigo,7 allegado,8 usufructo. | Propia={1,2,3}; resto “otra tenencia”, distinguiendo usufructo si importa. **H** con ELSOC. |
| EPS VII/VIII | `d7`, añade9 **heredada**,88 NR,99 NS. | Revisar si propia incluye9. El motor actual agrupa propia=1:3: no copiar esa regla sin resolver heredada. No es código de no respuesta. |
| TSM R7–R10; R11 TL | `f1`:1 arrendada,2 propia pagada/pagándose,3 cedida empleador,4 cedida familiar/amigo. **Módulo F solo nuevos entrevistados**; restantes saltan a `f7b`. | Propia=2, otras={1,3,4}. **H** solo si se verifica fecha de medición/arrastre. Una columna poblada por ronda no acredita tenencia actual repetida. |

### 4.6 Pareja

| Fuente y olas | Original / códigos / universo | Definición común y pérdida |
|---|---|---|
| ELSOC 2016,2018,2019,2021;2022 E6 | `m36` (2022 `_p/_ta`): estado civil actual;1 casado,2 conviviente sin AUC,3 con AUC,4 soltero,5 viudo,6 anulado,7 divorciado,8 separado,9 otro. A en2017 revisada. | Unión conyugal/convivencia={1,2,3}; no={4…8};9 desconocido. **H** con EPS/TSM; no mide toda pareja sentimental. |
| EPS VI | `i1`:1 casado,2 conviviente,3 anulado,4 separado legal,5 separado hecho,6 viudo,7 soltero,8 divorciado,9 acuerdo vida pareja. | Sí={1,2,9}; no={3…8}. **H**; revisar flujo I1/I2 de actualización para panel. |
| EPS VII/VIII | `i1`:1 casado,2 conviviente,3 anulado,4 AUC,5 separado legal,6 separado hecho,7 viudo,8 soltero,9 divorciado. | Sí={1,2,4}; no={3,5,6,7,8,9}. **H**; código9 cambia completamente respecto de VI. |
| TSM R7–R10; R11 TL | `a6`: estado civil/conyugal, personas≥15:1 casado,2 conviviente/pareja,3 anulado,4 separado,5 divorciado,6 viudo,7 soltero. | Sí={1,2}; no={3…7}. **H**. Seleccionar entrevistado; no usar parentesco `a4` como sustituto. |

### 4.7 Empleo

| Fuente y olas | Original / referencia y opciones / flujo | Propuesta y diferencia residual |
|---|---|---|
| ELSOC, `m02`, §4.1 | Actividad **principal último mes**:1 trabajo jornada completa,2 parcial/ocasional,3 estudia y trabaja,4 solo estudia,5 jubilado,6 desempleado buscando,7 cuidados/tareas no remuneradas,8 enfermo/discapacidad,9 ni estudia/trabaja/busca. Todos; ramas4…9 omiten preguntas específicas de empleo. | `paid_main_activity`=1 si1:3;0 si4:9. **H** frente a ocupación EPS/TSM: una actividad secundaria remunerada podría quedar oculta. No llamar tasa de ocupación OIT. |
| EPS VI | `b2`, situación del último episodio de historia laboral. | **H** para situación actual solo comprobando que episodio llega a entrevista. |
| EPS VII/VIII | `b2a_SO` / `b2a_so`:1 trabajando,2 cesante,3 primera búsqueda,4 inactivo. Pregunta situación actual y desde cuándo. | 1→ocupado;2:4→no. **H**: no es documentalmente “semana pasada”, aunque así lo describa un informe del motor. |
| TSM R7–R10; R11 TL | `c1`: trabajó≥1hora semana pasada1sí2no; si sí→C8. Si no, `c2` rescata actividad remunerada1sí2no; si sí→C8. Si no, `c3` empleo con ausencia temporal:1…9 razones,10 no. Entrevistado≥15. | Ocupado si C1=1 o C2=1 o C3∈1:9; no ocupado si rama válida termina C3=10. **H** frente a actividad principal mensual/actual; no convertir saltos en no. |

### 4.8 Tabaco

| Fuente y olas | Original / referencia / opciones / universo | Transformación y pérdida |
|---|---|---|
| ELSOC 2016,2018,2021 | `s08`, cantidad media cigarrillos/día **último mes**, numérica; todos, NS/NR negativos. A2017/2019. | >0 frente a0 aproxima fumador reciente; **H** con EPS/TSM, pues cero promedio/redondeo puede ocultar ocasional y no incluye otros productos. No equivale a nunca fumador. |
| EPS VI/VII `f12a`; VIII `f12_a` | Fuma actualmente1sí2no; VIII8NR9NS. Cantidad F12b solo fumadores. | Sí/no actual, **H** por ventana y producto respecto de ELSOC/TSM. Mantener intensidad separada. |
| TSM R7–R10; R11 TL | `e4a`: consumo actual de tabaco1sí2no; entrevistado, incluidos quienes saltaron alcohol. | Sí/no actual, **H**; pierde tipo/intensidad. La fuente lo contiene aunque el IPW TSM actual no lo utilice. |

### 4.9 Síntomas depresivos

| Fuente y olas | Original / referencia / opciones y universo | Definición común propuesta y límites |
|---|---|---|
| ELSOC 2016,2017,2018,2019,2021,2022 | `s11_01…09` (2022 `_p/_ta`), últimas2semanas;1 nunca,2 algunos días,3 más mitad días,4 casi todos,5 todos. Todos; autoadministrada en olas presenciales, lectura telefónica2021 y modo mixto2022. Ítems01 anhedonia y02 decaimiento/pesadez/desesperanza. | **H**, no PHQ idéntico. Propuesta exploratoria por ítem1→0,2→1,3→2,4/5→3; pierde distinción casi todos/todos y persisten diferencias de redacción (incluido ítem psicomotor). No trasladar validez clínica o umbral PHQ≥10 automáticamente. |
| EPS VI/VII/VIII | `f69_1…9`, últimas2semanas,1 nunca,2 varios días,3 más mitad,4 casi todos. Entrevistado. | Restar1 por ítem; suma0–27 solo con regla de faltantes definida. PHQ2 usa primeros2. **D** con TSM al cotejar ítems/ventana; **H** con recodificación ELSOC. |
| TSM R7–R10; R11 TL | `f15a…f15i`, últimas 2 semanas, 1…4 como EPS; ítems del módulo E, solo entrevistado, sin restricción a nuevos entrevistados. | PHQ2=(a−1)+(b−1), 0–6; pérdida de otros 7 síntomas. Para IPW común más defendible usar los 2 ítems/indicadores ordinales con sensibilidad a formulación, no llamar idénticas las escalas. |

Diagnóstico médico (`s19_03`) y tratamiento (`s14`) ELSOC son constructos distintos, no sustitutos de síntomas. No rellenar un PHQ faltante con tratamiento/diagnóstico, ni interpretar una covariable IPW como diagnóstico clínico.

### 4.10 Salud autopercibida

| Fuente y olas | Original / referencia / opciones y universo | Definición común propuesta, pérdida, clase |
|---|---|---|
| ELSOC 2016,2017,2018,2019,2021,2022 | `s03` (formulario2017 S3;2022 `_p/_ta`), salud general al momento;1 mala,2 regular,3 buena,4 muy buena,5 excelente. Todos. | Regular o peor={1,2}, mejor={3,4,5}. **H** con EPS: ELSOC no distingue muy mala. |
| EPS VI/VII/VIII | `a10`:1 excelente,2 muy buena,3 buena,4 regular,5 mala,6 muy mala;8NR9NS. Roster, seleccionar entrevistado y comprobar informante. | Regular o peor={4,5,6}; mejor={1,2,3}. **H** con ELSOC, pierde extremo inferior y puede diferir informante. |
| TSM R7–R10; R11 TL | `f7a`, salud actual nota1muy mal…7muy bien;9NS. Módulo F inicial **solo nuevos entrevistados**; demás saltan F7b. | **N** para corte verbal “regular o peor” sin validación. H solo como ordinal/indicador específico de fuente, con cortes analíticos sometidos a sensibilidad. Confirmar fecha/arrastre antes de llamarla salud actual en cada ronda. |

## 5. Diseño y seguimiento: no intercambiar pesos entre encuestas

### 5.1 ELSOC

| Componente | Variables/documentación verificada | Uso operativo / pendiente |
|---|---|---|
| Persona y ola | `idencuesta` es identificador longitudinal del participante (EC), pese al nombre. En largo, `ola`; en ancho sufijos `_w01…`. CSV local de pesos tiene encabezado `idencuesta,ola,ponderadorlong_total,ponderadorlong_panel`. | Unir persona×ola, validar unicidad, distinguir muestra original/refresco y versión. No enlazar por sexo/edad/comuna. |
| Fecha | `annio_entr`, `mes_entr`, `dia_entr`; `prob_entr`, `prob_n_entr`, `prob_cierre_entr`, `prob_cierre_n_entr` documentan problemas de fecha. | Construir tiempo efectivo solo con fechas válidas; modo2021dos llamados puede necesitar fecha del bloque de alcohol, no cierre. |
| Marco y selección | EM: vivienda particular, selección original18–75; urbano; probabilístico estratificado multietápico. Ciudades=UPM, luego manzanas, subbloques/viviendas, persona. | No confundir segmento publicado con ciudad-UPM. La representación inicial no cubre todo Chile rural. |
| Estratos | `estrato`:1 Gran Santiago,2 Gran Valparaíso,3 Gran Concepción,4 ciudades grandes,5 medianas,6 pequeñas. `estrato_disenno` conserva diseño original, añadido en longitudinales desde ola5. | Para varianza longitudinal, utilizar diseño original documentado; no reemplazarlo por región actual tras mudanza. |
| Conglomerados | `segmento`, `segmento_disenno`; este último conserva segmento original. | Verificar receta oficial de declaración del diseño y anidamiento ciudad/segmento/cohorte; no declarar sin más que `segmento` es la UPM teórica. |
| Pesos transversales | `ponderador01/02`; `fact_exp01/02`. 01 ajusta población;02 población y sexo. EM: inverso selección × no respuesta de manzana × postestratificación; normalización distingue peso de factor expansor. | Usar peso de ola/población apropiada para prevalencia; no asumir que corrige selección de pares de alcohol completos. |
| Pesos longitudinales | EL denomina `ponderador_long_total`, `ponderador_long_panel`; encabezado local omite guion bajo tras “ponderador”. Total usa observaciones disponibles; panel, participantes de todas las olas de su cohorte. Código oficial público: [elsoc-coes/ponderadores-long](https://github.com/elsoc-coes/ponderadores-long), commit `475c7e32becc1451e8d40fb9b8ef0b79d4e5885f` (26-03-2024), insumos 2016–2022 v1.00; su CSV de olas 1–6 es el mismo archivo local antiguo. | Verificado 21-10-2026: el SAV 2016–2023 (Dataverse V3) trae pesos w01–w07 **recalculados con datos 2016–2023** (panel 1.176 M1 / 661 M2 = `tipo_atricion==1`, frente a 1.304 / 772 en el CSV); etiqueta «(2016-2022)» desactualizada; método de w07 sin documento propio. Plan de uso por pares: [WEIGHTING_PLAN.md](../__andres_control/elsoc_2021_2023_exploration/WEIGHTING_PLAN.md); resultados: [hallazgos_elsoc_ponderacion.md](../__andres_control/hallazgos_elsoc_ponderacion.md) y [elsoc_weighting_scenarios_EN.html](../elsoc_weighting_scenarios_EN.html). |
| Ajustes ya incorporados | EL: diseño/no respuesta inicial; en seguimiento modela participación con datos administrativos, cuestionario basal y proceso de campo; recorta extremos, calibra sexo×edad y reescala. | IPW adicional requiere definir selección residual: respuesta de ítem/par, no volver a corregir la misma atrición sin justificarlo. Panel completo y pares de olas son poblaciones analíticas distintas. |
| Pesos replicados | No identificados en fuentes revisadas. | **P**, no prueba de inexistencia institucional. Réplicas construidas por analista deben etiquetarse como tales. |
| Participación | `tipo_atricion`: patrón participación; `tipo_caso`:0 consistente,1 inconsistencia menor,2 mayor; `cuestion_completo`:1completo,2incompleto desde2021. | Patrón observado permite ausencia seguida de retorno; no determina causa ni salida permanente. Confirmar códigos completos de `tipo_atricion` en entrega. |
| Disposición final | E3 p.2:110 completa,120parcial;211rechazo,212interrumpida;225-0no ubicable/no puede atender,225-1mudanza conocida,225-2desconocida,225-3fuera país permanentemente;231muerte,232impedimento físico/mental;311no enviado a terreno; otros códigos de elegibilidad. | Distingue salidas conocidas de falta temporal **si se obtiene registro CDF por persona/ola**. Su presencia en cuestionario no prueba que se publique el archivo de seguimiento. No asignar muerte a ausencia. |

Tamaños **documentados**, no recalculados: EM, tabla3.8 de atrición, publica muestra original2016=2.927;2017=2.473;2018=2.229;2019=2.153;2021=1.739;2022=1.728. Refresco2018=1.519;2019=1.264;2021=1.001;2022=1.002. Son entrevistas por muestra/ola, **no pares completos de alcohol**. El aumento de una muestra entre olas no identifica individualmente retornos; se necesita trayectoria. No se reproducen aquí los conteos empíricos de pares/estratos de la auditoría anterior como si fueran documentación oficial.

### 5.2 EPS

| Componente | VI / VII / VIII | Implicación |
|---|---|---|
| ID | `folio_n20` en entrega utilizada; módulos de entrevistado y roster deben vincularse respetando su unidad. | Verificar identidad por ronda y no multiplicar entrevistado por familiares/episodios. |
| Tiempo | VI terreno2016; VII presencial2019–2020 y teléfono2020; VIII2023–2024. | No son intervalos anuales ni todas las modalidades miden alcohol comparable. |
| Pesos transversales | VI `factor_EPS2015`; VII `factor_XS`; VIII `factor_xs`. | No uniformar mayúsculas sin comprobar archivo. VII pondera23+; VIII incorpora refresco18+. |
| Panel | VII `factor_Panel_2015`; VIII `factor_panel_2002`, `factor_panel_2004`, `factor_panel_2015`. | VIII factor2015 corresponde panel2015–2020–2023 según PM§5.3, no automáticamente pares de extremos. |
| Diseño publicado | VII `cluster_ID`, `strata_ID`; VIII `cluster_id`, `strata_id`; VI entrega sin diseño público completo identificado. | Recuperar diseño para enlazados desde otra ronda no equivale a disponer diseño de toda VI. |
| Atrición/no respuesta | PM documenta ajustes y postestratificación. | Evitar multiplicar peso longitudinal y un IPW de la misma selección sin definir estimando y base. |
| Réplicas | No identificadas como pesos oficiales en diccionarios revisados. | Las111JKn del motor son construidas con `survey::as.svrepdesign`, no publicadas por EPS. |
| Seguimiento/salidas | Bases separadas fallecidos e impedidos; teléfono puede ser seguimiento con alcohol no comparable. | Separar fallecido, impedido, teléfono solamente, ausencia, retorno y falta de ítem; verificar códigos de disposición por ronda antes de implementar. |

### 5.3 TSM

| Componente | Variables / evidencia | Implicación |
|---|---|---|
| Identificación | `IdPanel` persona longitudinal; `IdEncuesta` entrevista; `IdPersona` integrante; `Entrevistado`0resto/1entrevistado. T7–T10/TL. | Alcohol solo entrevistado. No usar IdPersona aislado como ID longitudinal. |
| Tiempo/modo | T7–T10 portadas y TM: panel telefónico; calendario §2. | Fecha individual/variable exacta **P**; no asumir12meses por ronda. |
| Cobertura | TM: población urbana adulta, selección aleatoria desde hogares. | No extender comparación a rural ni a menores con peso urbano. |
| Peso | `Fact_Exp`, factor población entrevistada mayor18, por ronda según entrega. | No se verificó fórmula de ajuste/no respuesta/atrición/calibración en documentación local: **P**. No llamarlo longitudinal. |
| Estratos, UPM, panel, réplicas | No identificados en codebooks revisados. | **P** pedir documentación; ausencia de columnas no demuestra muestreo simple ni inexistencia institucional. |
| Ausencia/retorno | Puede reconstruirse presencia de `IdPanel` por ronda. | No identifica fallecimiento/emigración/rechazo permanente. No respuesta una ronda ≠ salida definitiva. |
| Repetición real | F1 y F7a restringidos a nuevos entrevistados en R7–R10. | Aclarar arrastre/actualización de variables publicadas antes de IPW con covariable “actual”. |

No se reportan conteos locales TSM como tamaños oficiales de terreno. ACHS describe R11 con aproximadamente2.300 entrevistas; el total del archivo local anotado en inventarios no debe sustituirse por esa cifra ni darse por reconciliado.

## 6. Faltantes, filtros y contrato de armonización

| Fuente / ítems | Códigos originales que deben conservarse | Tratamiento propuesto |
|---|---|---|
| ELSOC EC | −999 NR;−888 NS;−777 error técnico;−666 encuesta incompleta. Saltos pueden ser missing de sistema. | Crear valor armonizado separado y motivo: NR,NS,técnico,incompleto,salto,no medido,ausencia de ola. No convertir negativos a cero. |
| ELSOC S10 | S09=2/NS/NR omite S10. | Solo S09=2 da estado “no regular”; S09faltante no da no consumo. S10omitida no significa cero días. |
| EPS VI/VII F13/F14 | VI F13:8NR; VII añade9NS en diccionario. F14:8NR9NS. | Ítem/ola específicos; EPS F14=0 es consumo<1día, no falta ni abstinencia. |
| EPS VIII F13/F14/F15 | F13:88NR. F14:88NR99NS. F15 diccionario:888NR999NS; formulario:8888NR9999NS. | Discrepancia real: conservar metadatos y verificar archivo antes de decidir unión de códigos; no interpretar999 como cantidad válida. |
| EPS VI/VII F15 | Formulario8888NR9999NS. | Confirmar códigos almacenados por archivo. |
| EPS educación/pareja/vivienda | Niveles/categorías9 pueden ser respuestas sustantivas; ejemplo D7=9heredada. | Prohibida regla global “8/9 faltantes”. |
| TSM | B4a=10NS/NR; F7a=9NS; alcohol1…5 son respuestas válidas. No se verificó lista exhaustiva SPSS user-missing. | Faltantes E3a2/E3a3 pueden ser salto por E3a1=1; mantener motivo. No asignar cero por falta genérica. |

Cada variable futura debe conservar: `fuente`, `version`, `ola`, fecha, identificador, variable original, valor original, motivo de falta/filtro, variable común, regla y clasificación D/H/N. Es una especificación documental, **no un nuevo archivo de datos**. La comparación necesita el mismo denominador: todos los elegibles, consumidores declarados o consumidores regulares según corresponda.

## 7. Qué se podría contrastar del motor EPS

| Objeto de evaluación | Aporte ELSOC | Lo que no queda validado |
|---|---|---|
| Persistencia y movilidad observada | Matrices propias de regularidad/frecuencia para2016→2018 y2018→2021, con fechas y pesos adecuados, población común y sensibilidad al modo2021. | No son matrices anuales de gramos ni cesación/inicio reales entre entrevistas. |
| Dinámica anual propuesta | Proyectar el motor sobre el intervalo efectivo y comparar únicamente un resultado que pueda mapearse al mismo constructo. Para un generador continuo usar su transición del intervalo; para pasos discretos justificar composición y fracciones temporales. | Ajuste a extremos plurianuales no identifica un generador anual único, ni prueba Markov/homogeneidad. No tomar raíz matricial o dividir probabilidades como validación empírica. |
| Coherencia externa | Señalar discrepancias de dirección/magnitud que sobreviven a restricciones poblacionales y de medición. | “Regular” ELSOC no coincide con “cualquier consumo” EPS: sin función de observación defendible solo hay triangulación, no validación cuantitativa del mismo estado. |
| Selección/atrición | Comparar composición basal y retención; usar pesos oficiales y, si hace falta, ajuste de selección residual bien definido. | MAR, positividad o ausencia de sesgo no quedan demostradas por aplicar IPW. |
| Intensidad/HED/políticas | No aporta una medición común suficiente. | No valida gramos/día, elasticidades, efectos de precio, HED, RR, PAF/PIF, mortalidad o YPLL. |

No se adopta la afirmación de la auditoría previa de que ELSOC sea una “cota superior” y rank matching una “cota inferior” de movilidad: el error de medición no garantiza esas cotas matemáticas. Tampoco se concluye insuficiencia de potencia por educación sin un análisis nuevo. El antecedente se conserva, pero esas conclusiones no son resultados de esta revisión documental.

## 8. Decisiones pendientes antes de implementar

1. Cuestionario CAPI/listado2023 ya obtenidos y cotejados con el repositorio oficial (actualización inicial). Verificar CATI, nombres publicados w07 y nombres fusionados2022; comprobar flujo S15 y cobertura por modo/muestra antes de implementar.
2. Elegir estimando: consumo regular, cualquier consumo declarado, frecuencia entre consumidores o volumen. ELSOC solo ofrece los primeros constructos con las limitaciones descritas; no hay equivalencia automática al estado EPS.
3. Fijar población urbana/edad/cohorte y fechas de referencia. Separar pandemia/cambio de modo de cambio conductual.
4. Resolver educación completada frente a título y nivel alcanzado; no adoptar umbrales TSM como hechos observados.
5. Resolver tenencia heredada EPS, actualización de pareja EPS, empleo actual frente a semana/mes y arrastre de vivienda/salud TSM.
6. Elegir representación de síntomas ELSOC sin atribuirle automáticamente puntuación/umbral validado PHQ. Salud TSM tampoco tiene un corte verbal equivalente identificado.
7. Obtener/confirmar CDF ELSOC, diseño de varianza y pesos adecuados para el subconjunto de pares; comprobar cobertura temporal del CSV de pesos. Definir selección residual antes de cualquier IPW adicional.
8. Resolver discrepancias de faltantes EPS y documentar user-missing TSM. Validar unicidad persona×ola, filtros, denominadores y fechas antes de calcular transiciones.

**Conclusión:** es viable una armonización parcial de covariables y una evaluación externa de persistencia de regularidad/frecuencia a intervalos observados. ELSOC no valida directamente la dinámica anual del motor EPS ni sus estados de volumen, HED o historia vitalicia. El siguiente paso requiere cerrar las decisiones de medición, cobertura y ponderación; no ajustar modelos todavía.
