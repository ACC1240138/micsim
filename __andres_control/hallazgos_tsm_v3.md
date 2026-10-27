# TSM v3: el panel del Termómetro con el motor de transiciones de la EPS

> **Versión histórica.** La vigente es TSM v4 (2026-10-26): cinco estados con C3+, bordes WHO, tolerancia de vínculo de
> ±2 años elegida con datos y todas las funciones escritas en el cuaderno. Ver [tsm_v4_explicado.html](tsm_v4_explicado.html),
> [TSM_ENPG_v4_EN.ipynb](TSM_ENPG_v4_EN.ipynb) y [tsm_markov_outputs_v4/](tsm_markov_outputs_v4/). En los orígenes con datos
> (N0, FD, C1), las matrices agregadas cambian a lo más 0,003 frente a v3.

[Cuaderno ejecutado](TSM_ENPG_v3_EN.ipynb) · [HTML autocontenido](../TSM_ENPG_v3_EN.html) · [Salidas agregadas](tsm_markov_outputs/) · [Plan y desviaciones](tsm_v3_plan_2026-10-19.md) · [Revisión crítica](tsm_v3_review.md) · [Página didáctica](https://claude.ai/artifact/LQ7Rsae6D2dAHjk9wPcLwN) (copia local: [tsm_v3_explicado.html](tsm_v3_explicado.html))

Fecha: 2026-10-19. Datos reales: rondas 7 a 11 del Termómetro de la Salud Mental (TSM), leídas del paquete cifrado `_tsm/tsm.tar.xz.enc`. Dos ejecuciones en kernels nuevos de 51 minutos cada una; 63 tablas CSV idénticas byte a byte; 56 comprobaciones registradas, todas superadas.

**Decisión principal:** el cuaderno v3 reproduce exactamente los conteos de v2 y luego aplica el motor EPS completo (estados, covariables, validación por persona, bootstrap por persona, capa anual). Fuera de muestra gana la lognormal, con A claramente detrás. Las probabilidades anuales de permanencia del TSM son mucho más bajas que las de la EPS por construcción (ventana de recuerdo inexistente e intervalos de meses), así que **los pares del TSM no sirven para calibrar la matriz anual de la EPS**; sí sirven para contrastar predictores y transiciones de corto plazo entre no beber y C1. Una decisión se cambió sobre la evidencia de la revisión: los límites de edad de la regla de enlace se ampliaron un año.

## Datos y estados

**4.121 pares de 1.915 personas**, la misma persona en rondas consecutivas, 18 a 65 años al origen.

| Intervalo | Meses | Respondientes 18–65 | Destino presente | Incompatibles | Pares usados | Regla EPS estricta |
|---|---:|---:|---:|---:|---:|---:|
| R7→R8 | 8 | 2.123 | 1.001 | 5 | 996 | 953 |
| R8→R9 | 4 | 1.405 | 907 | 6 | 901 | 845 |
| R9→R10 | 7 | 2.137 | 1.284 | 30 | 1.254 | 1.167 |
| R10→R11 | 5 | 1.672 | 983 | 13 | 970 | 923 |

Orígenes: N0 1.592, FD 431, C1 2.086, **C2 6, C3 6, C4 0**. A 12 g por trago el panel observa casi solo transiciones entre no beber y C1; todo lo que el cuaderno diga de C2 a C4 es extrapolación de modelos, y así queda marcado (`sparse`, `unobserved origin`).

**Regla de enlace.** La regla EPS exige mismo sexo y un cambio de edad compatible con el tiempo transcurrido. Con intervalos de 4 a 8 meses esa regla eliminaba 287 de 4.175 destinos presentes (6,9 %), casi todos saltos de edad de dos años. La revisión adversarial mostró que la edad (`a3`) es un valor del roster del hogar que el encuestador «revisa y corrige si es necesario», que los pares excluidos coinciden con los retenidos en identificadores, región y educación, y que empiezan a beber el doble de veces. **Los límites se ampliaron un año** (`ts_link_tolerance = 1`): quedan 4.121 pares; la regla estricta (3.888 pares, 1.845 personas) es una sensibilidad con su propia auditoría. El usuario puede volver a la regla estricta cambiando esa constante.

**FD no es el exbebedor de la EPS.** FD marca a quien no bebe hoy pero declaró beber en una entrevista compatible anterior: 0 / 219 / 390 / 342 / 399 personas en R7 a R11. Un 84 % de ellos bebió hace 12 meses o menos, y la proporción de FD entre no bebedores crece con la antigüedad en el panel (25, 34, 38 y 41 % con una a cuatro entrevistas previas). En la EPS, FD lleva años sin beber. Las comparaciones llevan una marca `comparable = FALSE` para esa fila. La marca de consumo previo viaja por la cadena de entrevistas compatibles consecutivas; la EPS también usa enlaces directos a cualquier ola anterior, pero con las fechas aproximadas del TSM esa variante y la directa producen pares que contradicen el mapa N0/FD (2 y 16 pares), y la cadena no.

**Educación.** Se infiere el nivel completado a partir del nivel alcanzado (`b4a`), el último curso aprobado (`b4b`) y si está estudiando (`b1`). Frente a la regla de v2 (nivel alcanzado) cambian 2.159 filas-ronda; frente a la regla estricta, 1.011. Ninguna variante mueve los puntajes.

## Qué modelo predice mejor

Cinco grupos de personas, tres repeticiones, IPW y contracción ajustados dentro del entrenamiento.

| Modelo | Log loss ↓ | Brier ↓ |
|---|---:|---:|
| Lognormal (dos partes) | 0,5391 | 0,3382 |
| Multinomial | 0,5401 | 0,3381 |
| Ordinal único | 0,5406 | 0,3379 |
| Gamma (dos partes) | 0,5484 | 0,3382 |
| Ordinal de dos partes | 0,5501 | 0,3385 |
| Matriz A | 0,5596 | 0,3518 |
| Referencia JRT | 0,5619 | 0,3510 |

Probabilidad típica (e elevado a menos el log loss): 58,3 % para la lognormal frente a 57,1 % para A. Contrastes pareados con las personas como conglomerados: **lognormal − A = −0,0205 [−0,0348; −0,0063]**, un cambio medio de 3,3 puntos por probabilidad de clase; lognormal − Gamma −0,0093 [−0,0201; +0,0016]; Gamma − A −0,0113 [−0,0304; +0,0078]; multinomial − lognormal +0,0011 [−0,0082; +0,0103]; lognormal − JRT −0,0229 [−0,0369; −0,0089]. La educación no aporta (A con educación − A: −0,0013 [−0,0026; −0,0000]) y los extras del TSM (PHQ-2, región, empleo, ítem 6+, antigüedad) tampoco (+0,0027 [−0,0034; +0,0088]).

**Calibración por destino (fuera de muestra):** NC observado 43,65 % (A 43,47; lognormal 43,69); C1 55,85 % (56,00; 55,79); C2 0,41 % (0,39; 0,33); C3 0,09 % (0,11; 0,14). Por celda de origen, la peor celda con soporte es A en FD de mujeres de 60 a 65 (82 pares): 71,6 % observado en NC frente a 44,1 % predicho, porque la contracción de A arrastra esa celda hacia la fila agrupada.

**Diagnóstico de Chapman–Kolmogorov:** en las cohortes de tres rondas, la transición directa NC→NC a dos pasos (0,761) supera a la encadenada (0,614), con diferencia +0,15 [+0,12; +0,18]. Es un diagnóstico marginal, no una prueba, pero apunta a heterogeneidad no capturada por el estado actual (personas que no cambian), la misma preocupación de la microsimulación sobre los abstemios de siempre. Añadir el estado de la ronda anterior no mejora la predicción (+0,081 [−0,070; +0,232]).

## La capa anual y la comparación con la EPS

Un generador en tiempo continuo se ajusta a los cuatro intervalos a la vez; la matriz anual es su exponencial. Intervalos de bootstrap por persona (1.000 réplicas con IPW y modelos reajustados).

| Estado | Pares de origen | TSM A | EPS A | TSM lognormal | EPS lognormal |
|---|---:|---|---|---|---|
| N0 | 1.592 | 0,592 [0,516; 0,663] | 0,913 [0,903; 0,922] | 0,592 [0,518; 0,663] | 0,911 [0,901; 0,921] |
| FD | 431 | 0,276 [0,229; 0,328] | 0,871 [0,818; 0,910] | 0,275 [0,231; 0,325] | 0,872 [0,830; 0,905] |
| C1 | 2.086 | 0,736 [0,701; 0,769] | 0,818 [0,789; 0,844] | 0,735 [0,700; 0,767] | 0,815 [0,790; 0,837] |
| C2 | 6 | escaso | 0,535 [0,367; 0,696] | escaso | 0,481 [0,389; 0,574] |
| C3 | 6 | escaso | 0,443 [0,245; 0,661] | escaso | 0,434 [0,326; 0,547] |
| C4 | 0 | no estimado | 0,403 [0,085; 0,830] | no estimado | 0,181 [0,000; 0,998] |

**Por qué el TSM «se mueve» tanto más.** Los ítems de alcohol del TSM no tienen ventana de recuerdo y más de la mitad de quienes beben lo hacen «una vez al mes o menos». Entre dos entrevistas separadas por pocos meses, muchas personas responden distinto sin haber cambiado de patrón; el generador lo lee como salidas y entradas reales y, al extrapolar a un año, las acumula. La EPS mide el último mes con casi cuatro años de por medio. Las dos direcciones de la comparación miden esa brecha de constructo:

- Los generadores anuales de la EPS proyectados a los intervalos del TSM obtienen log loss 0,761 sobre los pares del TSM, frente a 0,554 de una matriz TSM que solo usa el estado de origen (la referencia justa), 0,560 de A y 0,539 de la lognormal fuera de muestra.
- El generador del TSM proyectado a 3,7 y 4,0 años difiere de las matrices observadas de la EPS con RMSE ponderado de 0,20 y 0,26 y diferencias máximas de 0,38 y 0,53 (cinco destinos, sin el origen FD).

**Homogeneidad temporal.** Ajustado cada intervalo por separado (A), la permanencia anual en N0 es 0,65 / 0,47 / 0,60 / 0,58 y en C1 0,70 / 0,67 / 0,78 / 0,71; los errores de reconstrucción individuales son de 0,005 a 0,010, mientras el generador conjunto reproduce cada intervalo con errores de 0,030 a 0,091. Los intervalos se contradicen y la matriz anual es un compromiso entre ellos. Sensibilidad a reinicios y penalización: hasta 8,9 puntos (Gamma), 7,0 (A) y 5,0 (lognormal). La capa anual del TSM es exploratoria y no debe entrar en la microsimulación como motor.

**Fusionar C3 y C4** no ayuda: C3plus sigue con 6 pares de origen y una permanencia anual de 0,007.

## Sensibilidades

| Variante | Resultado |
|---|---|
| Educación (laxa, estricta, alcanzada) | log loss lognormal 0,5422 / 0,5424 / 0,5425 con una repetición; sin diferencia |
| Regla de enlace estricta (3.888 pares) | log loss lognormal 0,5278 frente a 0,5422 con los límites ampliados: los pares que la regla estricta elimina son los que más cambian, no personas distintas |
| 15,7 g por trago | C3 o C4 en la ronda siguiente pasa de 0,10 a 0,25 % (A) y de 0,18 a 0,34 % (lognormal); no dice cuál conversión es correcta |
| Banda abierta de 16 tragos | 0,10 → 0,18 % (A); 0,18 → 0,19 % (lognormal) |
| Pesos: solo Fact_Exp / recortado / IPW sin recortar / IPW recortado | bebe en la ronda siguiente 56,56 / 56,59 / 55,92 / 56,18 %; ESS 1.181 / 1.483 / 1.116 / 1.397: el recorte sube el ESS y la IPW baja un poco la prevalencia |
| Transporte entre intervalos (lognormal) | log loss 0,512 a 0,589 según el intervalo retenido; R8→R9 (4 meses) es el peor |
| Señal de cantidad típica | 9,5 % de los hombres y 2,9 % de las mujeres en C1; para mujeres es una cota inferior y no es comparable con la EPS |
| Bootstrap 500 frente a 1.000 | razón mediana de errores estándar 0,993; el percentil 90 de la diferencia relativa es 12 % |

Avisos de ajuste registrados: 130 ajustes Gamma por BFGS tras no converger IRLS (el respaldo de v2, portado), 124 avisos de no convergencia en logísticas de participación con celdas casi separadas, 1.010 reinicios del ordinal desde umbrales marginales. Están en `fit_warnings.csv`; ninguno detuvo una réplica.

## Limitaciones y qué sigue

- Sin ventana de recuerdo en los ítems de alcohol: «bebe», FD y las señales de cantidad son aproximaciones, no constructos ENPG de 30 días.
- Sin unidades primarias ni estratos; `Fact_Exp` es transversal. El bootstrap por persona es la única incertidumbre calculada.
- Fechas de ronda aproximadas (R11 sin verificar); la regla de enlace y la capa anual heredan la aproximación.
- C4 inalcanzable a 12 g con la tabla de búsqueda; C2 y C3 con seis pares de origen cada uno.
- Las tablas agrupadas «a la ronda siguiente» mezclan cuatro duraciones; las matrices por intervalo son el producto principal.
- Pendiente por decisión: calibración a prevalencias ENPG y validación independiente, en la integración del microsimulador. El TSM puede aportar allí una comprobación de corto plazo de la fila N0/FD → C1 y de los predictores, no una matriz anual.
- La procedencia y las condiciones de uso de los SAV del TSM siguen sin documentarse en `_tsm/README.md`.

## Archivos y reproducción

- Fuentes: `tsm_markov_data.R` (capa de datos, portada del código v2 en `_tsm/notes/v2_desktop_code/`), `tsm_markov_models.R` (motor EPS portado), `tsm_markov_sections.R` (cuerpos de celda), `TSM_ENPG_v3_EN.md` (narrativa); el cuaderno incrusta las dos capas.
- Herramientas: `_tools/build_tsm_markov_notebook.py`, `_tools/execute_eps_notebook.py` (opción nueva `--output-env`), `_tools/verify_tsm_reproduction.py`; pruebas `test_tsm_markov_data.R` (datos reales) y `test_tsm_markov_models.R` (sintético).
- Salidas: `tsm_markov_outputs/` (63 CSV, figuras en `en/`, `reproducibility_report.md`, `render_validation.json`); HTML en la raíz, 4,3 MB con 12 figuras y 3 ecuaciones MathML incrustadas.
- Reproducir: construir, ejecutar dos veces (la segunda con `--output-dir .quarto/tsm_markov_reproduction_en`) y verificar, como indica `reproducibility_report.md`. En este equipo R debe ir fijado a los núcleos E (`--affinity 16,…,31`); con `TSM_B=20 TSM_REPEATS=1` un ensayo completo tarda tres minutos.
