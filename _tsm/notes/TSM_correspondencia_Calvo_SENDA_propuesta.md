# TSM → Calvo/SENDA: correspondencia y propuesta

Fecha: 2026-10-15. Documento de decisión; no recodifica datos ni modifica notebooks.

**Propuesta:** conservar Gamma y las categorías originales; añadir una clasificación de patrones inspirada en Calvo, con el umbral episódico objetivo 5+ hombres/4+ mujeres. TSM permite aproximar ese objetivo, pero no identificar HED en los últimos 30 días.

## Gamma y reclasificación posterior

La idea es viable: predecir si la persona bebe en t+1, predecir la distribución de cantidad si bebe y obtener las categorías a partir de esa distribución. El notebook actual ya integra la distribución Gamma entre los cortes de gramos/día; se conserva esa alternativa.

No conviene asignar a cada persona la categoría de su media predicha: eso reduce artificialmente la dispersión y puede eliminar consumos altos. Para matrices se calculan probabilidades de cada intervalo; para microsimulación se sortea participación y, si corresponde, una cantidad de la distribución. Por ejemplo, una media de 15 g/día puede coexistir con una probabilidad apreciable de superar 20 g/día.

Gamma no garantiza mayor eficiencia. La regresión multinomial también es paramétrica y puede parametrizar un modelo de Markov. Un modelo continuo puede aprovechar diferencias de cantidad dentro de una categoría y necesitar menos parámetros que matrices independientes para cada grupo; esa ventaja depende de que la distribución y las relaciones elegidas sean razonables. Una Gamma equivocada puede dar intervalos estrechos alrededor de probabilidades equivocadas. [Documentación de modelos Markov con regresión multinomial](https://hesim-dev.github.io/hesim/articles/mlogit.html).

Para las categorías Calvo hace falta algo más: frecuencia y episodios intensivos. Dos personas con el mismo promedio de gramos/día pueden tener patrones distintos. Gamma de volumen por sí sola no determina ocasional/moderado/heavy. Una extensión posible predice participación, frecuencia y señal episódica, y cantidad condicionada a ellos; después aplica las reglas. Otra conserva Gamma para volumen y estima por separado la transición de patrones, comprobando su coherencia conjunta. No se ha ajustado todavía esa extensión.

## Correspondencia de variables

“Observado” significa respuesta declarada disponible, no ausencia de error de medición. “Aproximado” requiere una regla explícita. “No identificable” significa que las preguntas disponibles no bastan.

| TSM | Constructo común | Categoría o función Calvo/SENDA | Identificación |
|---|---|---|---|
| e3a1=1, “Nunca” | No consumo declarado en la entrevista | Abstinencia actual operativa | Respuesta observada; no verifica los últimos 30 días ni abstinencia de vida |
| e3a1=1 y e3a1=2–5 en cualquier ola estrictamente anterior del mismo IdPanel | No consumo actual con antecedente observado | FD observado, dentro de abstinencia actual de Calvo | Antecedente observado; aproximación a FD de ENPG por diferencia de ventana |
| e3a1=1 sin antecedente positivo observado | No consumo; historia vital desconocida | Abstinencia actual de Calvo, porque no puede descartarse consumo pasado | No permite distinguir verdadero abstemio de vida de exbebedor no detectado |
| Sin pregunta vital ni historia disponible de cuatro años | Nunca bebió, <12 tragos de vida, o abstinencia prolongada | Abstinencia de vida/prolongada de Calvo | No identificable en R7–R11; no asignar esa categoría por acumular negativas |
| e3a1=2: una vez al mes o menos; =3: 2–4 veces al mes | Frecuencia inferior a semanal en la conversión principal | Ocasional, si no cumple heavy | Frecuencia ordinal observada; equivalencia a días/semana aproximada |
| e3a1=4: 2–3 veces/semana; =5: ≥4 veces/semana | Frecuencia semanal o mayor | Moderado, si no cumple heavy | Banda de frecuencia observada; número exacto de días aproximado |
| e3a2: 0–2; 3–4; 5–6; 7–9; ≥10 | Cantidad en un día típico de consumo | Cantidad para promedio diario; señal indirecta de cantidad alta | Intervalo observado; valor puntual y equivalencia día/ocasión aproximados |
| Frecuencia en días/semana × cantidad típica / 7 | Promedio diario durante la semana, incluidos días sin beber | Heavy por volumen si >3 tragos/día en hombres o >2 en mujeres | Aproximado; no confundir con cantidad solo en días de consumo |
| e3a3=2–5 frente a =1 | Declaración de ocasiones de ≥6 tragos; frecuencia ordinal | Señal episódica para heavy | Observado para ≥6 y su frecuencia declarada; no identifica 5+/4+ en 30 días |
| e3a2 y sexo a2, como complemento de e3a3 | Señal de cantidad típica compatible con 5+/4+ | Aproximación adicional al objetivo SENDA | No verifica una ocasión ni su fecha; no es HED observado |
| a2, a3, b4a | Sexo, edad y educación cursada | Predictores y perfiles para matrices | Variables disponibles; mantener códigos originales y agrupaciones documentadas |

La limitación principal es la **ventana temporal no verificada de los ítems de alcohol**. “Mensualmente” en e3a3 describe una frecuencia habitual declarada; no confirma que haya ocurrido un episodio en los últimos 30 días. Cambiar el umbral no resuelve esa diferencia.

## Clasificación principal propuesta

Nombre sugerido: **Calvo–SENDA adaptado a TSM**. Cinco estados operativos:

1. No consumo, historia desconocida.
2. FD observado: no consume y existe consumo en cualquier ola previa.
3. Ocasional, sin señal heavy identificada.
4. Moderado, sin señal heavy identificada.
5. Heavy por volumen o señal episódica aproximada.

Estos cinco estados no son los cinco estados originales de Calvo: desagregan su abstinencia actual por antecedente y no inventan su estado de abstinencia vital/prolongada. En una tabla estricta Calvo se agrupan los dos primeros como abstinencia actual; la categoría vital/prolongada queda no identificada, no como prevalencia cero.

### Orden de decisión

- Primero, resolver no consumo y antecedente; los saltos estructurales no se convierten en cantidades positivas. Mantener las contradicciones de respuestas como banderas.
- Entre consumidores, evaluar heavy antes de separar ocasional/moderado.
- Heavy por volumen: promedio semanal diario >3 en hombres o >2 en mujeres. La igualdad exacta 3/2 queda del lado no heavy.
- Señal episódica principal, orientada al objetivo SENDA: e3a3=2–5 **o** intervalo de cantidad típica cuyo límite inferior alcanza 5 en hombres o 4 en mujeres. En las bandas TSM, esto último corresponde a e3a2=3–5 en ambos sexos. Es un proxy; presupone que un día típico informa sobre una ocasión.
- Mujeres en e3a2=2 (3–4) sin otra señal quedan marcadas como ambiguas respecto de 4+. No se afirma que sean negativas. En el escenario principal no se activa heavy solo por esa banda; una sensibilidad sí lo activa.
- Si no cumple heavy, e3a1=2/3 se clasifica ocasional; e3a1=4/5, moderado. “Sin señal identificada” no significa ausencia demostrada de HED.
- Una señal positiva suficiente permite clasificar heavy aunque falte otro componente. Sin señal positiva y con datos necesarios faltantes, dejar la clasificación indeterminada; no reemplazar faltantes por “no”.

La señal de cantidad típica no demuestra HED: beber durante un día no equivale necesariamente a una sola ocasión. El indicador exacto “HED 5+/4+ en últimos 30 días” permanece no identificable en TSM; no se exportaría como si estuviera medido.

### Conversión de referencia

- Frecuencia: 0,5 y 3 días/mes; 2,5 y 5,5 días/semana. Convertir meses con 365,25/12 días.
- Cantidad típica: 1; 3,5; 5,5; 8; 10 tragos. El último valor es representativo del intervalo abierto, no su máximo.
- Conservar en paralelo 12 y 15,7 g/trago, sin APC en esta etapa.
- Los cortes Calvo se expresan aquí en tragos armonizados. Multiplicar los mismos tragos por distintos gramos no cambia por sí solo estos estados; sí cambia los gramos y las categorías originales basadas en gramos. No confundir incertidumbre de unidades con un cambio observado del patrón.

La regla 2–4 veces/mes → ocasional se basa en la conversión promedio; puede incluir personas que describen su consumo como semanal. Esa frontera se examina en sensibilidad.

## Sensibilidades prioritarias

| Cambio | Para qué sirve |
|---|---|
| Heavy por volumen + solo e3a3 positivo, sin señal de cantidad típica | Mostrar cuánto depende la clasificación principal de tratar cantidad por día como señal por ocasión |
| Mujeres con 3–4 tragos típicos: activar o no la señal 4+ | Mostrar la incertidumbre de la banda que cruza el umbral femenino; no son límites formales del HED verdadero |
| e3a1=3 (2–4/mes) como semanal en vez de sub-semanal | Examinar la frontera ocasional/moderado sin cambiar a quienes tienen frecuencia inequívoca |
| Extremos abiertos: ≥10 representado por 10/12/16 y ≥4 días por 4/5,5/7 | Evaluar la dependencia del volumen respecto de puntos representativos; mantener 12/15,7 g en paralelo |
| Exigir ≥1 o ≥2 entrevistas previas al origen | Evaluar detección de FD con más historia; reportar los pares/IDs que se pierden |
| Heavy solo por volumen, excluyendo toda señal episódica | Comparación secundaria con EPS, que no pregunta directamente HED; no presentarla como equivalencia completa |

FD siempre usa cualquier consumo anterior observado y nunca respuestas futuras. Para distinguir FD no hace falta borrar a todas las personas sin antecedentes: se pueden conservar en el estado de historia desconocida. Si se restringe a quienes alguna vez declararon beber, el resultado describe a ese grupo y deja fuera iniciación entre personas sin consumo previo observado.

## Qué se verificó en las publicaciones

**Calvo 2020:** Table 2 imprime ≥3/≥2 para ocasionales, incompatible con su regla heavy >3/>2; también deja problemas en las igualdades de moderado. No se copia literalmente. La regla propuesta ≤3/≤2 para no heavy evita solapamientos y huecos, pero es una decisión explícita del análisis, no una errata formal confirmada por autores. [Texto, sección 2.2 y Table 2](https://pmc.ncbi.nlm.nih.gov/articles/PMC7585691/).

**Calvo 2021:** el texto usa ≤3/≤2 para ocasionales, pero <2 para mujeres moderadas. Persiste un problema en la igualdad femenina. Se verificó el texto completo; no se logró recuperar el suplemento de 2021 como archivo legible en esta revisión, por lo que no se le atribuye una corrección. [Texto](https://pmc.ncbi.nlm.nih.gov/articles/PMC8131222/).

**Keyes 2019 relevante para EPS:** es el artículo sobre episodios depresivos en 19 países, no el artículo distinto sobre mortalidad en HRS. Usa negativas repetidas para aproximar abstinencia prolongada en EPS/ELSA. Describe umbrales episódicos >4 hombres/>3 mujeres, numéricamente 5+/4+, pero eso no establece la ventana de 30 días de ENPG. Su redacción sobre cantidad en días de consumo tampoco debe confundirse con el promedio semanal de Calvo 2020. [Keyes et al., 2019, sección 2.2](https://pmc.ncbi.nlm.nih.gov/articles/PMC7362478/).

**Suma frente a máximo:** el texto principal de Calvo 2020 describe sumar cantidades armonizadas. Su suplemento, Table S2, distingue encuestas: para EPS calcula primero frecuencia × cantidad / 7 por bebida y toma el máximo no faltante. Se verificó esa excepción directamente en el DOCX. Table S4 también limita el uso operativo del ítem binge, de modo que la definición conceptual no equivale a una receta uniforme aplicada a cada encuesta. [Suplemento 2020, Tables S2–S4](https://ars.els-cdn.com/content/image/1-s2.0-S0376871620303847-mmc1.docx).

Para TSM no hay que escoger suma o máximo: e3a1/e3a2 ya preguntan por cualquier bebida alcohólica. Para estimar volumen total en EPS, preferiría sumar los promedios por bebida cuando frecuencia y cantidad representen el mismo período y un consumo típico comparable. Esa suma no exige beberlas simultáneamente. El máximo conservaría una rama de réplica de Calvo; generalmente no representa el volumen total. Si cantidades describen solo ocasiones puntuales no comparables, ninguna operación elimina esa incertidumbre. Para frecuencia de cualquier bebida o máximo por ocasión, sumar las respuestas de bebidas sí puede ser incorrecto por desconocer su coincidencia.

## Conservación y alcance

Se conservaron sin cambios e3a1–e3a3, categorías originales, transformaciones de gramos y la alternativa Gamma del notebook. Este documento propone nuevas variables, no reemplazos: estado adaptado, antecedente positivo, longitud de historia, señal ≥6, proxy 5+/4+, ambigüedad femenina, frontera de frecuencia, componentes faltantes y ventana no verificada.

No se calcularon nuevas prevalencias ni matrices con esta propuesta; por ello no se afirma todavía cuántos casos ganaría heavy. Antes de adoptarla, corresponde contar casos por regla de activación y contrastar ambas encuestas con la misma definición operativa. Elegir una regla solo porque reproduce una prevalencia sería calibración, no validación independiente.
