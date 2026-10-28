# Prompt para Claude: revisar la figura del paper outline

> Estado: **a chequear**. Las cifras y descripciones de abajo son pistas para
> localizar y contrastar evidencia; no son instrucciones de reemplazo automático.

## Texto para copiar

Necesito que revises y, después de conversar conmigo sobre las discrepancias,
actualices la figura de diseño del estudio para el paper outline. La figura que
estoy usando es `__andres_control/figures_paper_outline/Fig1_study_design.png`.
Hay además una copia bajo `__andres_control/figures_paper_outline/output/` y un
generador `__andres_control/figures_paper_outline/make_figures_paper_outline.py`.
Comprueba cuál es la versión de trabajo y cómo se generó antes de editar. Conserva
la estructura general, el estilo legible y la posibilidad de reproducir la figura.

### Forma de trabajo

1. Lee primero el handoff canónico
   `__andres_control/codex_handoff_adam_rr_full_override_caveman.md`, en especial
   sus entradas más recientes, y contrástalo con el código, las salidas guardadas,
   las fuentes y los lineamientos vigentes. Una entrada posterior puede corregir
   una decisión anterior. No supongas que el handoff o este prompt son infalibles.
2. Prepara una tabla breve con **elemento de la figura, texto actual, fuente,
   propuesta y estado**: confirmado, pendiente de decisión o evidencia insuficiente.
   Indica año, población, denominador, versión y fecha cuando sean relevantes.
3. Preséntame las discrepancias y **pregúntame aquí antes de resolver cualquier
   ambigüedad, contradicción o decisión de diseño que no esté clara**. Si una cifra
   no puede verificarse, no la inventes: propón omitirla o marcarla como pendiente.
   Puedes avanzar en comprobaciones independientes mientras esperas mi respuesta.
4. Después de mi respuesta, actualiza la figura y su fuente reproducible. Distingue
   lo estimado o calibrado, lo supuesto y lo pendiente de implementar; no presentes
   propuestas como resultados. Entrega la figura y un resumen de fuentes, cambios
   y verificaciones. No edites Google Docs ni ejecutes modelos sin consultarme.

### Elementos a chequear, no cambios ya aprobados

**EPS y TSM.** La figura muestra 8.095 pares EPS y 4.175 TSM. El handoff y
salidas v4 sugieren otras cifras; confirma que corresponden a la misma población,
regla de enlace, versiones y pares que quiere representar esta figura:

- EPS: el archivo `__andres_control/eps_markov_outputs_v4/v4_2009_matrix_shift.csv`
  contiene sumas de 4.773 para VI→VII y 3.394 para VII→VIII, que dan 8.167 pares.
  Hay otra entrada del handoff que señala 3.393 para VII→VIII. Investiga la
  discrepancia y verifica si es adecuado usar esos conteos en la figura. Distingue
  pares de personas únicas, la tolerancia de edad y el uso de EPS 2009 como historia.
- TSM: `__andres_control/tsm_markov_outputs_v4/cohort.csv` registra 1.001, 906,
  1.276 y 977 pares en intervalos consecutivos; suman 4.160. Contrasta con
  `link_tolerance_evidence.csv`, el notebook v4 y el universo de la figura. Verifica
  las fechas y duraciones de los intervalos antes de usar etiquetas como «seis meses».

**ENPG y CASEN.** Chequea las siete olas 2012–2024, el rango de edad pertinente a
cada etapa y el texto sobre postestratificación por sexo, edad y educación. Distingue
la población de la encuesta, la población de calibración y la exposición propuesta
para el motor. No atribuyas a la postestratificación una corrección demostrada de
todo el sesgo rural. La comparación con ENPG 2026 es una propuesta: verifica su
disponibilidad y no la presentes como ya realizada.

**Estados y anualización.** Chequea que N0, FD, C1, C2 y C3+ sean los estados
vigentes y cuál es la definición de cada uno por fuente. Verifica la regla de
12 g/trago y los límites de categoría contra el código y la decisión documentada.
Comprueba qué capas de anualización están calculadas y cuáles faltan para EPS v4,
TSM y la integración. No presupongas que definiciones de exbebedor de encuestas
distintas son equivalentes.

**TSM, transiciones y persistencia latente de HED.** Incorpora lo que se discutió
después de preparar la figura original. Antes de proponer una modificación, revisa
la sección HED del notebook ejecutado `__andres_control/TSM_ENPG_v4_EN.ipynb`,
su HTML y las salidas `__andres_control/tsm_markov_outputs_v4/hed_persistence_*`.
El README de esa carpeta indica que el notebook es la fuente de cómputo más
reciente; comprueba versiones, ejecución y reproducibilidad, porque la reflexión
del handoff recoge un análisis anterior y puede no coincidir con los nuevos archivos.

- Separa las **transiciones observadas de HED** del modelo latente que podría
  producirlas. Comprueba denominadores, selección de personas con consumo en ambos
  extremos, ponderadores, IPW, medición del volumen y remuestreo por persona.
  No presentes las estimaciones no ponderadas anteriores como las definitivas si
  el análisis nuevo emplea otra especificación.
- Las salidas recientes informan correlaciones latentes estimadas para cinco
  distancias entre unos 4 y 24 meses. Verifica los valores, intervalos, cantidad de
  pares y personas, covarianza entre estimaciones y las 1.000 réplicas reportadas;
  aclara que distintos intervalos pueden tener composiciones distintas. No uses
  una secuencia de estimaciones puntuales como prueba automática a favor o en
  contra de un proceso AR(1).
- Distingue la **correlación efectiva anual** `r(1)` de **φ**, la retención anual
  del componente persistente. En el modelo exploratorio con componente de ocasión
  independiente, `r(d) = R × φ^d` para rezagos positivos bajo los supuestos de
  estandarización, estacionariedad e independencia correspondientes. `R` representa
  una fracción de varianza en ese modelo, no una proporción de personas con HED.
  El AR(1) del motor ya tiene innovaciones aleatorias; `R = 1` no significa ausencia
  de aleatoriedad, sino ausencia de ese componente adicional de ocasión.
- A modo de pista verificable, `hed_persistence_fit.csv` registra un mejor ajuste
  de grilla con `r(1) = 0,30` y `φ = 0,95` para cinco distancias; el archivo
  `hed_persistence_ranges.csv` registra rangos de perfil. **No adoptes esas cifras
  automáticamente**: revisa método, grilla, incertidumbre, diagnóstico de ajuste,
  sensibilidad al par de 24 meses y límites de identificación. Compara también
  rasgo estable (`φ = 1`), decaimiento y AR(1) sin componente adicional. Un mejor
  ajuste puntual no demuestra un mecanismo biológico ni selecciona por sí solo el
  proceso para el microsimulador; toda extrapolación más allá del seguimiento TSM
  necesita un supuesto.
- El `ρ = 0,8` citado para el motor actual debe comprobarse en su código y en el
  contexto de cada proceso. No confundas un coeficiente AR con la correlación
  efectiva observada de HED. Tampoco cambies un parámetro global suponiendo que
  afecta solo a HED: el handoff advierte que puede afectar participación, cantidad
  y HED. Si se propone integrar un parámetro específico, pregunta primero qué
  alcance y sensibilidad desea el usuario; no cambies notebooks ni el motor.
- La comparación con ENPG requiere una decisión de transporte explícita: TSM
  pregunta por seis o más tragos sin ventana retrospectiva clara; ENPG utiliza
  5+/4+ según sexo en 30 días. Comprueba además población, selección y medición.
  No supongas que los errores de medición son iguales ni que la dependencia es
  necesariamente mayor o menor en una fuente. Verifica si el HED previo añade
  información más allá del volumen y distingue predicción con volumen de destino
  conocido de predicción desde el origen. Una OR no identifica φ ni se convierte
  directamente en un porcentaje estable de personas.
- Evalúa cómo reflejar esto en la figura sin saturarla: por ejemplo, HED como
  proceso latente **exploratorio, por calibrar y validar**, separado de las matrices
  de transición de volumen y de sus incertidumbres. Propón una leyenda o figura
  complementaria y pregúntame cuál prefiero. Identifica escenarios y parámetros
  como candidatos, no como resultados DIR ya integrados o validados.

**Población y edades de la simulación.** Compara las entradas sucesivas del
handoff: la última marca como decisión el seguimiento de mortalidad hasta 79 años,
salida a los 80, sin nuevas entradas después de 64; también indica que falta precisar
la inicialización de 65–79. Contrasta con los lineamientos y el motor. Pregúntame
si hay incompatibilidad entre la población inicial y ese horizonte. Diferencia
exposición, edad de entrada, seguimiento de mortalidad y corte de AVPP. Comprueba
el supuesto de transiciones 18–24 aplicadas a 15–17 y qué ocurre al cumplir 65.

**Desenlaces y mortalidad.** La última entrada propone `yll_hmd` como resultado
principal y AVPP <75 para comparación; confirma definición, tabla de vida y estado
de implementación. Revisa la propuesta `D_ref × PIF`, las causas AAF=1, la fuente
y período de defunciones, y qué falta para edades 65–79. No confundas la referencia
publicada de JRT 2008–2022 con la cobertura verificada de los datos del proyecto.

**Cascada DIR.** Contrasta REM 2024, el denominador FONASA/APS y los valores 11,7 %
y 52 % con sus fuentes y definiciones. Aclara qué se observa y qué es una hipótesis
de enlace o calibración individual; las prestaciones agregadas no demuestran por sí
solas personas únicas ni una cascada individual. Revisa especialmente CRAFFT y
AUDIT en adolescentes, y pregúntame si el detalle debe aparecer en la figura.

**Efecto y escenarios.** Verifica la procedencia y traducción de −20 g/semana,
el −8 % propuesto y el supuesto de decaimiento; mantén separadas evidencia externa
y parametrización del modelo. Revisa el componente HED y los escenarios S0–S3
contra las decisiones vigentes: no muestres como implementado lo que todavía es una
propuesta. Si cambia el sentido de una etiqueta, consúltame antes de editarla.

**Cifra APS de la figura.** La imagen dice 9,43 millones de inscritos validados
FONASA 15–64 en 2023. Verifica fuente, año, unidad y denominador; no sustituyas la
cifra ni afirmes que coincide con la población simulada sin comprobarlo.

Concluye con una lista corta de decisiones pendientes para mí. Si encuentras fuentes
contradictorias o no sabes qué versión de la figura representa mi intención, pregúntame.
