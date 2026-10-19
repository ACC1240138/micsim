# TSM: hallazgos del notebook continuo agrupado

Actualizado: 2026-10-15. Ejecución con los cinco archivos SAV reales, R7–R11.

## Abrir y reproducir

- [Informe HTML autónomo](TSM_pooled_ENPG.html): lectura, código desplegable, 13 figuras y 16 tablas.
- [Notebook ejecutado](TSM_pooled_ENPG.ipynb): análisis reproducible en R.
- [Método y decisiones](TSM_pooled_metodo.md): fuente del texto del notebook.
- [Diccionario por ola](outputs_tsm_pooled/diccionario_variables.csv): 217 entradas variable-ola, 44 variables distintas.
- [Recuentos completos](outputs_tsm_pooled/recuentos_edad_sexo_educacion_HED_categoria.csv): edad, sexo, educación, HED y categoría; incluye celdas vacías.
- [Matrices e IC empíricos](outputs_tsm_pooled/matrices_empiricas_IC.csv).
- [Modelos: IC por persona](outputs_tsm_pooled/modelos_IC_por_persona.csv) y [por par](outputs_tsm_pooled/modelos_IC_por_par.csv).

Los notebooks anteriores, sus resultados, estilos y SAV permanecen intactos: 90 archivos protegidos mediante SHA-256.
El HTML incorpora estilos, ecuaciones y figuras; para abrir sus enlaces a CSV, conservar la carpeta outputs_tsm_pooled junto al HTML.

Desde esta carpeta, con Python, R/IRkernel y Quarto disponibles:

    python crear_tsm_pooled.py
    python ejecutar_tsm_pooled.py
    quarto render TSM_pooled_ENPG.ipynb --to html --no-execute
    python verificar_tsm_pooled.py

El notebook usa el kernel local ir44. La ruta del ejecutable Quarto depende de la instalación local y no está codificada en los archivos compartibles. El análisis está en tsm_pooled_core.R; las celdas, en tsm_pooled_sections.R; los diagramas, en tsm_pooled_diagrams.R. No se instalaron paquetes.

Para cambios únicamente de presentación, el constructor admite --preserve-outputs. El script refrescar_tsm_pooled.py vuelve a ejecutar sus celdas seleccionadas y dependencias; no reemplaza una ejecución completa cuando cambia la lógica analítica. La entrega conserva los 1.000 remuestreos completados y añade una actualización de gráficos/texto.

## La probabilidad de beber sí depende del estado previo

Se ajusta una sola regresión logística con tres estados al origen, además de edad, sexo, educación, consumo previo, HED, ola y longitud de historia. La cantidad positiva también depende de ese estado.

| Estado inicial | Interpretación | Probabilidad de beber en la siguiente ola, IC95% por persona |
|---|---|---|
| ND_unknown | No bebe; sin consumo previo observado. Historia de vida desconocida | 18,4% (13,7–23,0) |
| FD observado | No bebe; declaró consumo en alguna ola anterior | 57,5% (49,9–65,8) |
| Consumo actual | Bebe al inicio del par | 76,8% (72,8–80,5) |

Son promedios ponderados sobre los orígenes de cada grupo. No son efectos causales ni probabilidades anuales. La primera fila mezcla iniciación y reanudación no identificadas: **no estima iniciación de abstemios de vida**. La historia no usa datos futuros. IPW no recupera antecedentes de consumo nunca observados.

En una futura aplicación a ENPG se puede distinguir abstinencia de vida y FD según sus preguntas; TSM no identifica por separado los parámetros necesarios para ambos estados verdaderos.

## Cuánta información aporta el panel

| Rama | Oportunidades de seguimiento | Pares observados | Personas con pares |
|---|---:|---:|---:|
| Principal: R8→R9, R9→R10, R10→R11 | 5.214 | 3.174 | 1.703 |
| Todas las olas consecutivas: añade R7→R8 | 7.337 | 4.175 | 1.934 |
| t+2 directo desde R8/R9 | 3.542 | 1.882 | 1.408 |

- Objetivo del estudio: **15–65**. Estimación TSM: **18–65 al origen**; no se extrapola a adolescentes.
- Hay 9.060 observaciones persona-ola de 18–65 años. No son 9.060 personas independientes.
- Se conservan primeras apariciones y retornos; una ausencia intermedia no se convierte en un par consecutivo.
- En el análisis principal hay 1.267 orígenes sin entrevistas previas observadas; 552 tienen destino observado. Esto no demuestra incorporación oficial al panel.
- Se conservan 64 destinos que ya superaron 65 años: la restricción es al origen.
- R7 informa historia; por sí sola no permite reconocer FD. La rama adicional conserva sus pares y explicita esa diferencia.

| Par | Sin destino observado |
|---|---:|
| R7→R8 | 52,8% |
| R8→R9 | 35,4% |
| R9→R10 | 39,9% |
| R10→R11 | 41,2% |

Estas cifras describen ausencia en la siguiente ola, no abandono definitivo. Sus causas no están identificadas.

## Ponderación, IPW e incertidumbre

- Peso analítico: **Fact_Exp del origen × IPW del destino**. No se multiplican dos factores de expansión transversales.
- IPW estima respuesta al destino usando información del origen. Supone respuesta independiente del consumo futuro condicionada a esos predictores, positividad y una especificación adecuada.
- Probabilidad estimada mínima de respuesta: 0,147; inversa máxima: 6,80.
- Tamaño efectivo por dispersión de pesos: 883,5. No equivale a personas ni a un tamaño efectivo que incorpore todo el diseño.
- Balance global máximo: |SMD|=0,0145; dentro de cat2 y cat3 persisten 0,566 y 0,266. Las categorías escasas siguen siendo frágiles.
- Se comparan IC por par y por persona. Markov no obliga a independencia marginal entre pares del mismo ID.
- Los modelos continuos tienen **500/500 réplicas válidas en cada rama**, reestimando IPW, participación y cantidad. Gamma requirió el optimizador alternativo del mismo objetivo en 17 y 22 réplicas, respectivamente; no quedaron fallos finales.
- Los IC empíricos incorporan la estimación de IPW. Una comprobación independiente mediante derivadas numéricas reprodujo los errores estándar de cat1→FD: 0,020231 por par y 0,020584 por persona.
- No se añade un factor Kish a IC que ya incorporan la variabilidad de los pesos. No se reconstruyen UPM ni estratos desconocidos.

Official presentations describe an urban sample derived from previously interviewed households, but do not identify the original primary sampling units or strata. This does not establish that the original design lacked clustering or stratification. Available origin-wave expansion factors are used; pair-based and person-clustered uncertainty estimates are working approximations rather than a reconstruction of the original sampling design.

## Gamma y lognormal: qué se encontró

Se estima participación y cantidad positiva en tragos/día reconstruidos; luego se convierte a 12 o 15,7 g/trago. Esto mantiene la misma probabilidad de beber en ambos escenarios. Las categorías se derivan integrando la distribución predicha entre los cortes del proyecto.

Validación con cinco particiones de personas completas, referencia 12 g:

| Criterio, menor es mejor | Gamma | Lognormal |
|---|---:|---:|
| RMSE de volumen, g/día | 5,891 | 7,548 |
| Log-score negativo del proxy | 1,578 | 1,454 |
| Log-loss de categorías | 0,585 | 0,560 |

Gamma predice mejor la media bajo RMSE; lognormal obtiene mejores puntuaciones de densidad y categorías. No hay un ganador universal. Suavizar el consumo evita una regresión independiente en cada estrato, pero **no garantiza mayor eficiencia ni corrige la medición ordinal**. Las categorías altas tienen muy pocas observaciones.

## Qué permanece como supuesto o trabajo posterior

- **12 frente a 15,7 g:** escenarios explícitos; comparar con prevalencias chilenas armonizadas puede evaluar plausibilidad, pero no identificar por sí solo la conversión correcta. Ventana, selección, subdeclaración y puntos representativos también influyen. Usar una prevalencia para calibrar y luego para validar sería circular.
- **Cola:** con los puntos elegidos, 12 g produce un máximo de 94,3 g/día. Cat4 vacía es una consecuencia de la conversión. El intervalo ≥10 tragos no tiene un máximo real conocido; las probabilidades continuas superiores a ese proxy dependen del modelo.
- **FD:** aproximación por historia observada, distinta de la recencia de 30 días de ENPG. No se identifican abstinentes de vida en TSM.
- **Tiempo:** resultados para la siguiente ola disponible en el calendario consecutivo. No se convierten automáticamente en tasas homogéneas o probabilidades anuales.
- **Homologación:** se conservan los cortes de consumo del proyecto. TSM no reproduce el componente de días de binge ni el umbral 5/4 de la fórmula ENPG; sus ítems refieren ≥6 tragos.
- **APC y ENPG:** no se aplicó who_apc/factor_CH ni calibración de márgenes. El notebook documenta una ruta posterior inspirada en Moid; todavía no es esa calibración.
- **Censo:** se entregan códigos y etiquetas TSM de variables demográficas potencialmente homologables. No se inventan equivalencias con un censo externo.

Fuentes y decisiones detalladas en el notebook. La [verificación final](outputs_tsm_pooled/verificacion_entrega.json) comprueba ejecución, probabilidades, conteos, IC, archivos originales y recursos incorporados al HTML.
