# Contraste independiente de fuentes DIR

29-oct-2026. Modo lectura. Carpeta auditada: `Desktop/DIR`. No se modificó nada en DIR ni en micsim, ni se escribió en el handoff ni en el Google Doc. v8 sigue siendo propuesta.

## Ejecutado y no ejecutado

**Ejecutado (solo lectura; salidas en `$CLAUDE_JOB_DIR/tmp/{integrity,rem,links,me,outline}`):**
- Tamaños y MD5/SHA256 de los 76 archivos, contrastados con INVENTARIO y manifest.
- `zipfile.testzip` de los 10 ZIP y análisis de cabeceras del ZIP innominado.
- Lectura de Zone.Identifier.
- Lectura en streaming de los 7 SerieA y SerieP y de los diccionarios SA/SP de los 7 años.
- Recálculo de las 3.306 celdas de REM_nacional_filas, de los 12 valores P6 y de los indicadores 2019/2024.
- Recuento de inscritos 2022 y 2023 y de beneficiarios 2022.
- HEAD simple a 34 URL citadas.
- Lectura del outline (solo lectura; snapshot del 29-oct en `tmp/outline/outline.txt`) y del handoff (sección DIR).
- HEAD simple a las 7 URL `repositoriodeis.minsal.cl/DatosAbiertos/REM/SERIE_REM_YYYY.zip`.
- Diagnóstico del innominado: se decodificaron en el tmp del job unos 573 MB parciales del miembro, que es nominal. Solo se leyeron el encabezado y el conteo de filas, no se imprimieron filas y el archivo se borró.
- Estimación xz de extractos por año.

**No ejecutado:**
- `dir_revision.R`, `beneficiarios_revision.R` y `preparar_entrega.py`, porque escriben en DIR.
- `acc_pack`, cifrado y descifrado.
- Descarga de FONASA (responde 403; no se intentó eludir el bloqueo).
- Tabla de datos abiertos DEIS.
- Commit `54b69d6` de GitHub.
- `7z t` (no está instalado).
- Comparación de SP_24 en insumos frente a la copia dentro del ZIP 2024.
- Series BM, BS y D.
- Los diccionarios 2020–2023 y 2025 se revisaron con parser automático. A03, A05 y A27 se revisaron a mano solo en 2019 y 2024.

## Tabla de contraste (priorizada)

| # | Afirmación | Evidencia | Evaluación | Implicación | Corrección sugerida |
|---|---|---|---|---|---|
| 1 | Handoff 27-oct «DECIDIDO DIR: P(cualquier AUDIT) 11,7 %»; outline 1.103.414/9.432.037 | v8 §Mediciones locales retira esos denominadores; handoff l.8779; outline §Derivadas | **Refutada como dato**. La cifra queda vigente solo como decisión provisional | La cascada decidida descansa en un denominador prorrateado que v8 retira | Rotular 11,7 % como supuesto. Ver #2 para un rango observado |
| 2 | «Los tramos etarios amplios no identifican 15–64» (README, v8) | `Inscritos APS 2022.csv` (Sep-2022) y beneficiarios dic-2022 vienen en quinquenios | **Refutada en parte**. Es cierta para 2023, pero 2022 da conteos directos 15–64 por sexo: inscritos Sep-22 A–D 8.646.552; X 608.076; total 9.254.628; beneficiarios Si 9.159.082 (H 4.200.928, M 4.958.027) | AUDIT 2024 15–64 sobre esos denominadores da 11,92 %, 12,05 % y 12,76 % (H 8,8–9,5 %; M 14,6–15,5 %). Los denominadores tienen 15–27 meses más que REM 2024 (crecimiento de ~10 %), así que el rango es un **límite superior**: ajustado quedaría en ~10,8–11,6 % y acota el 11,7 % prorrateado. No es U/N | Usar 2022 como cota observada de sensibilidad, con su corte; no como validado |
| 3 | v7: «Validados (A–D) y FONASA 2022 son el mismo concepto» | Inscritos Sep-22 total 13.585.016 vs beneficiarios Si dic-22 13.572.688 (−0,09 %); A–D 12.797.410 (−5,7 %). En 15–64: −1,0 % frente a +5,9 % | **Pendiente; igualdad no demostrada, con indicio en contra de A–D = Si**. Ajustando 3 meses de crecimiento (~0,7 %/mes observado entre Sep-22 y Dic-23): A–D dic-22 ≈ 13,06 M (Si +4,0 %) y total ≈ 13,87 M (Si −2,1 %). Si queda entre ambos, más cerca del total. No se comprobó la inscripción múltiple. Beneficiarios solo trae TRAMO A–D | «Mismo concepto» de v7 no tiene base | Mantener «subconjunto A–D» y pedir el diccionario a FONASA. No excluir X sin una definición documentada |
| 4 | Outline: «excluye tramo X (918.229, no validados) (criterio DIPRES; ¿¿…??)»; figura APS «equivalence unconfirmed» | Outline §Fuentes | **Pendiente**. El outline se contradice: una frase afirma y la siguiente lo pone en duda | Riesgo de citar X = no validado en el paper | Quitar «no validados». Dejar «tramo X (definición pendiente)» |
| 5 | Procedencia de los ZIP REM «pendiente de comprobar» (README; auditoría §Fuentes) | Zone.Identifier HostUrl `https://repositoriodeis.minsal.cl/DatosAbiertos/REM/SERIE_REM_YYYY.zip` en los 7 ZIP; ZoneId=3 | **Refutada**. HEAD 29-oct: 2019–2024 responden 200 con Content-Length **idéntico** al local (descarga constatada por URL y tamaño; hash no recomparado). **2025: el servidor tiene 154.998.562 B (Last-Modified 22-oct-2026) frente a 132.569.190 B locales**, así que el ZIP local es una versión anterior | Hay procedencia trazable; la copia local de 2025 está superada | Registrar HostUrl, tamaño, Last-Modified y SHA256 por año. Para 2025, volver a descargar o rotular «versión jun-2026» |
| 6 | Beneficiarios-Innominada-2023.zip «falla al abrir» | Solo 1 cabecera local, sin directorio central. Miembro `Beneficiarios Fonasa 2023.csv`: declara 234.532.193 bytes comprimidos y 2.524.490.768 sin comprimir; presente 53.338.364 (22,74 %). Deflate legible: 3.679.332 filas, MES 202312, nominal (CÓDIGO_BENEFICIARIO) | **Confirmada y precisada**: descarga **truncada**, no corrupción. HostUrl fonasa 2024/09 | Sin uso posible. Completo pesaría unos 234,5 MB, es por persona y no trae INSCRITO_APS | No usar ni borrar. Reobtenerlo o descartarlo explícitamente. Tiene identificador seudonimizado: tratarlo como microdato |
| 7 | «CSV y ZIP de inscritos 2022 son idénticos por MD5» (README) | MD5 del miembro = MD5 del CSV = `617debcd…`. ReferrerUrl del CSV = el ZIP local | **Confirmada** (miembro idéntico; los archivos en disco difieren, como es esperable) | El CSV es redundante | Conservar solo el ZIP (5.207.954 bytes) |
| 8 | Inscritos 2022 = recurso del catálogo «Inscritos APS 2022 12» | El catálogo declara 13.639 KB; el local tiene 41.367.014 bytes, corte Sep-2022, quinquenios, `REGION` sin tilde, HostUrl fonasa 2024/09 | **Refutada**. Es otro producto (septiembre, quinquenal) | No sirve como corte de diciembre ni enlaza con 2023 | Citar la URL `fonasa.gob.cl/wp-content/uploads/2024/09/Inscritos-APS-2022.zip` y el corte Sep-2022 |
| 9 | Manifest como registro de procedencia | 19 filas que coinciden. Faltan SERIE_REM_2025, inscritos 2022 (CSV y ZIP), el innominado, la Cuenta Pública, SP_24 y los HTML/JSON | **Pendiente o incompleta** | 2025 no tiene hash de referencia | Completar el manifest antes de cualquier bundle |
| 10 | README enlaza `PROMPT_CONTRASTE_CLAUDE.md` | El archivo no existe | **Refutada** | Enlace roto | Crear el archivo o quitar el enlace |
| 11 | «REM 2025 incompleto: faltan 615 establecimientos» (v7/v8) | 12 meses presentes, 15 % menos filas. Miembros fechados jun-2026. **Último registro truncado** (`9;13;2025;113329;03600220;`, 6 de 57 campos); el CRC del ZIP es válido | **Confirmada y ampliada**: además de incompleto, la versión local termina cortada, y DEIS republicó 2025 el 22-oct-2026 (fila 5) | Hay riesgo de pérdida al final del archivo, además de la falta de consolidación | Excluir 2025 de la calibración. Anotar el truncamiento. Volver a descargar más adelante |
| 12 | Script: SerieA tiene Col01–38 | Encabezado de 57 campos, Col01–Col50, en las 7 series | **Refutada** (sin efecto en los indicadores) | Un extracto con 38 columnas pierde datos de A05 (Col39–47: gestantes, pueblos originarios, migrantes…) y de A07 (Col39–48) | Extraer Col01–50 (cuesta 25–60 KB xz más por año) |
| 13 | Outline: A03 D.1 tiene 8 tramos (Col04–19) en v2025 y Col04–15 en 2019 | Diccionarios SA_19…SA_25 | **Refutada en parte** (diccionario: nCol 15 en 2020 y 19 desde 2021; rótulos de tramo según parser, revisados a mano en 2019 y 2024): los 8 tramos parten en **2021**; 2019–20 tienen 6 tramos y 65+ sin partir. SENAME y Mejor Niñez (Col20–21) solo desde 2025 | Afecta la lectura 65–69 y cualquier serie larga | Corregir el texto del outline |
| 14 | Mapeo del script: A03 Col06–13, A27 Col03–06, A05 Col10–29 = 15–64 | Diccionarios de los 7 años | **Confirmada** | Las cifras 15–64 son exactas en edad | Ninguna |
| 15 | La «verificación independiente» Python confirma los resultados | `preparar_entrega.py` reutiliza los mismos códigos y columnas | **Confirmada como aritmética, no como mapeo** (el mapeo se confirma recién en #14) | La auditoría sobrevaloraba su independencia | Decir «re-suma» en vez de «independiente» |
| 16 | Cifras REM 2019/2024 (6,59 %; 52,00; 46,94; 1.103.414; P6) | Recálculo en streaming: 3.306/3.306 celdas y 12/12 P6 | **Confirmada** | Son datos agregados reproducibles | Ninguna |
| 17 | Outline: «en la IB, las columnas de sexo suman hasta 6 % menos que el total» | (Col08+09)/Col01: 27300929 da 0,9995 (2019) y 0,9994 (2024); rango 2019–25 de 0,9985 a 1,0007 | **Refutada** a nivel nacional | No hay sesgo por sexo que corregir | Quitar la frase |
| 18 | A27 no cruza edad × sexo | Diccionarios: Col02–07 edad, Col08–09 sexo, en los 7 años | **Confirmada** | IB/RA por sexo dentro de 15–64 no son identificables | Mantener sin prorratear |
| 19 | 09600297/298 no existen en 2019; 06901500 es la alternativa | 06901500/06901700 están en 2019–22; 09600297/298/05990036 en 2023–25 | **Confirmada**. Los códigos nuevos existen desde 2023: la auditoría solo comprobó 2019 y 2024, y el outline («06901500 hasta 2022») es correcto | Hay ruptura de serie en 2023 | Documentar el puente 06901500 → 09600297+298 como no equivalente |
| 20 | P6241110…121 (2024) | Existen solo desde 2023. Predecesores 2019–22: P6221900/2000/2100 y P6223230/40/50. Junio 2020 casi vacío (26.000 frente a 429.000 filas) | **Confirmada y ampliada** | Serie P6 larga solo con un mapeo explícito | Incluir el mapeo de predecesores y excluir junio 2020 |
| 21 | Duplicados REM 2021: 6 | 14 líneas exactas, establecimiento 101404 (meses 7, 11 y 12); los 6 citados son los de los 17 códigos. SerieP 2021: 3 (101702) | **Confirmada y ampliada** | Efecto despreciable (03500349 +20) | Registrarlos y no corregir la fuente |
| 22 | Diccionarios REM: SA_.*\.xlsm | SA_20 es `.xlsx`. La ruta del miembro cambia por año (plano, `2021/`, `Datos/*.txt`, `Datos/*.csv`). El nombre SBS 2023 tiene la codificación rota | **Confirmada como riesgo de loader** | Un patrón único falla | Registrar por año el nombre exacto del miembro |
| 23 | URL DIPRES ex ante | README cita `articles-212526_doc_pdf.pdf` (134.624 B) y v8 cita `…_doc_pdf1.pdf` (254.438 B); ambos responden 200 | **Discrepancia**: son dos PDF distintos | Cita ambigua | Fijar cuál respalda «inscrita y validada en Fonasa», con página |
| 24 | FONASA: URL exactas «devolvieron 403» | Hoy 403 en adjuntos y portal. Los stubs locales de 118 B son el nginx 403 del 27-oct. El catálogo declara 14.193 KB para 2023 y coincide con el local | **Confirmada**. Para inscritos 2023 se constata el tamaño frente al catálogo, pero no el hash | Descarga original no verificable en línea | Mantener «procedencia por HostUrl y tamaño; contenido no recomparado» |
| 25 | Catálogos DEIS y manuales «descargados el 27-oct» | 6 XLSX, diccionario 2024, 4 manuales y SP_24: tamaño exacto frente al servidor. Hashes iguales a los documentados | **Confirmada** (descarga constatada por tamaño y hash local) | Hay trazabilidad | Ninguna |
| 26 | `catalogo_ben.html` documenta beneficiarios | Es byte-idéntico a `catalogo_fonasa_busqueda.html`, un listado genérico sin «fonasa». `catalogo_metadata.json` es metadata DEIS de establecimientos 2026 | **Refutada** | No hay evidencia guardada para beneficiarios ni para el innominado | Renombrar o anotar en el inventario |
| 27 | Beneficiarios 2022: 193.927 filas; 15.613.584; Si 13.572.688; 15–19, 20–64 y 65–69 | Recuento propio | **Confirmada** | Dato reproducible | Ninguna |
| 28 | Inscritos 2023: 15.051.673; A–D 14.133.444; X 918.229; 80.854 filas; 2.057 centros | Recuento propio | **Confirmada** | Dato reproducible | Ninguna |
| 29 | v7 SHA256 `1628dda…` intacto | Recalculado | **Confirmada** | — | — |
| 30 | Outline: columnas de inscritos «SEXO_TOTAL_INSCRITOS… [verificar]» | Esquema real: PERIODO, SERVICIO_SALUD, REGIÓN, COMUNA, COD_CENTRO, NOMBRE_CENTRO, NOMBRE_DEPENDENCIA, TRAMO, EDAD_TRAMO, SEXO, TOTAL_INSCRITOS; EDAD_TRAMO incluye «Sin información» | **Refutada** (error tipográfico) | — | Corregir en el outline |
| 31 | Script: «blanco REM = 0» y cifras del programa en `program <- data.frame(...)` | `dir_revision.R` | **Supuesto heredado de v7**, no dato | La brecha programa/REM depende de cifras sin fuente reproducible | Etiquetarlo así; la serie del programa necesita su fuente |
| 32 | Cuenta Pública FONASA en el inventario | PDF de 99 páginas, «Cuenta Pública FONASA 2025» (gestión 2024), §1.5.5 sobre población inscrita APS (p.19). No se cita en ningún documento | **Pendiente** | Fuente posible sobre la definición de inscrito/validado no explotada | Leer la p.19 antes de pedir el diccionario |

## Outline frente a v7 y v8

- **v7:** A–D = «validados por FONASA como define DIPRES». Reparte las edades con INE (18–65 en partes iguales). Da 8,9/11,7/14,5 % como probabilidades anuales, el techo de 441.000 IB y la «brecha COSAM» con un clasificador basado en EMP.
- **v8:** A–D pasa a ser un filtro operativo. Retira los denominadores prorrateados, las probabilidades derivadas y el techo de 441.000. Reemplaza el clasificador EMP por el catálogo DEIS. Corrige AUDIT-C, las etiquetas 0–7/8–15/16+ y el signo de P1 2020. No prorratea 18–65.
- **Outline:** ya incorpora parte de v8: «9.432.037… estimado repartido», el techo como «comparación de volúmenes» y la figura con «equivalence unconfirmed». Pero conserva 11,7 % como cobertura derivada, «no validados» para X y el texto de A03/A27 en las filas 13, 17 y 30.
- **Handoff:** la decisión del 27-oct usa 11,7 %, 52 % y la regla «una prestación = una persona/año». Siguen siendo decisiones de modelado, no datos.

## Qué informa cada serie al modelo DIR 2025–2034

| Serie | Datos que aporta | Lo que no identifica | Supuestos o decisiones necesarios |
|---|---|---|---|
| A03 D.1 | Aplicaciones de AUDIT dentro y fuera del EMP, ASSIST y CRAFFT. Resultados agrupados en tres filas. Por establecimiento y mes. Sexo × edad cruzados: 15–19, 20–24, 25–44 y 45–64 exactos; 65–69 desde 2021 | Personas, repetición en el año, sustancia de los resultados y versión AUDIT-C/AUDIT. 18–19 y 65 sueltos. 15–17 | «Una aplicación = una persona/año» (supuesto). Positividad multisustancia usada como objetivo de calibración agregado |
| A27 G/F | IB, intervención mínima y RA por sustancia (alcohol separado). Márgenes de edad (6 tramos) y de sexo | Cruce edad × sexo, enlace con el resultado, persona y repetición | IB/resultado de riesgo = cociente de actividad. P(IB\|8–15)=52 % es una decisión |
| A02 | EMP por profesional; por edad × sexo en la sección B (14 tramos); edad × sexo en la sección A solo desde 2025 | Personas únicas; AUDIT dentro del EMP por persona | El EMP como paso previo es opcional (decisión) |
| A05 N | Ingresos al programa de salud mental por alcohol y drogas, quinquenios × sexo, grupos especiales en Col38+ | Origen (si viene de una RA en APS), persona, no ingreso. Ruptura de códigos 2022→2023 | Solo comparación de volúmenes; no sirve como transición |
| A07 | Consultas de psiquiatría adulto 07021900, quinquenios | Diagnóstico por alcohol. En 2025 cambian los cortes (15–17/18–19) | Contraste de capacidad, si se usa |
| P6 | Población en control por alcohol en APS y especialidad, existencias a junio y diciembre (desde 2023 con estos códigos) | Ingresos, flujos, personas únicas (diagnósticos superpuestos) | No sumar cortes; solo existencias de contraste |
| Inscritos 2023 | Total por centro × tramo × edad de 20 años × sexo, corte 31-12-2023 | 15–64 exacto; significado de X | Prorrateo INE = supuesto |
| Inscritos Sep-2022 | Lo mismo en quinquenios, con X | Corte de diciembre; significado de X | Denominador 15–64 observado, desfasado |
| Beneficiarios 2022 | FONASA A–D con `INSCRITO_APS`, quinquenios × sexo, dic-2022 | Validación; X | Denominador alternativo observado |

Denominador de personas únicas tamizadas, repetición, entrega a cada elegible e ingreso tras RA: ningún archivo de DIR los identifica. Requieren registros nominales o SISTRAT, y mientras tanto quedan como escenarios.

## Selección mínima propuesta (no aplicada)

Por año REM, 2019 y 2021–2024. 2020 entra solo como contraste y 2025 como contraste marcado «truncado e incompleto».

1. **`rem_dir_<año>`**: filas de SerieA con estos códigos, todas las columnas originales (Mes … IdComuna, Col01–Col50) como texto:
   - A03 D.1: 03500346, 03500347, 03500402, 03500348, 03600100, 03500367, 03500349, 03500290, 03500300 y 03710010 (2025).
   - A27: 27300926–27300934.
   - A05: 06901500/600/700 (2019–22) y 09600297/298/299, 05990035/36 (2023+).
   - Opcionales: A02 (03030101/102/103/104/350/110/330/340/120/130) y A07 07021900.

   Agregar las filas SerieP de P6 alcohol/drogas y sus predecesores. Tamaño medido en xz: 0,55–1,46 MB por año (núcleo con Col01–50) o 1,2–3,1 MB con A02 y A07.
2. Por año, los diccionarios SA_ y SP_ originales (1,3–2,2 MB) y `FICHA.pdf` donde exista.
3. **Controles por año** (`*.md5.csv` más un JSON de control):
   - HostUrl, SHA256 del ZIP origen, nombre exacto del miembro y su CRC.
   - Filas totales y seleccionadas, meses y suma Col01 por código.
   - Duplicados exactos y truncamientos (2025).
   - Mapa Col→(edad, sexo) por código y año.
4. **FONASA:** `Inscritos APS 2023 12.csv` (14,5 MB), `Inscritos-APS-2022.zip` (5,2 MB, sin el CSV duplicado) y `Beneficiarios-Fonasa-2022.zip` (2,5 MB), cada uno con HostUrl, corte, esquema y totales de control. El innominado no se incluye.
5. **Catálogos DEIS 2019–2024 y diccionario 2024**, más los manuales y SP_24, con URL, tamaño y hash. Son públicos y publicables, así que conviene dejarlos en texto plano y no cifrarlos.
6. Las tablas agregadas de resultados (indicadores, brecha, P6) son publicables y no se cifran. Solo las extracciones derivadas, si se decide tratarlas como intermedios, irían con `acc_pack`.

**Exigencias antes de cualquier traslado:**
- Medir cada `.tar.xz.enc` y cada `.md5.csv` final, estrictamente por debajo de 50.000.000 bytes. Las estimaciones xz (todas bajo 3,2 MB) no reemplazan esa medición.
- Descifrar en tempdir y comparar MD5 y valores con el ZIP origen.
- Conservar los ZIP REM originales fuera del repositorio, porque los siete superan el límite.

**Decisiones abiertas para el usuario:**
- Si 2020 y 2025 entran al bundle.
- Si entran A02 y A07.
- Si se aplica v8.
- Qué hacer con el 11,7 %: tratarlo como supuesto, acotado por arriba con la cota observada 2022 (11,9–12,8 %, sin ajustar por crecimiento).
- Si se vuelve a descargar REM 2025 (versión del 22-oct-2026).

Este archivo vive en el tmp del job y se borra junto con el job.
