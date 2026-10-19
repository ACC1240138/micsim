# TSM: hallazgos, factibilidad y ejercicio de transiciones Markov

Fecha de revisión: 2026-10-13. Archivos originales conservados sin cambios. Se analizaron datos reales de las rondas R7–R11.

## índice

1. [Conclusión de factibilidad](#1-conclusión-de-factibilidad)
2. [Limitación importante: ventana temporal](#2-limitación-importante-ventana-temporal)
3. [Archivos, muestra e identificación](#3-archivos-muestra-e-identificación)
4. [ítems, respuestas y saltos de alcohol](#4-ítems-respuestas-y-saltos-de-alcohol)
5. [Posibilidad de estimar gramos por día](#5-posibilidad-de-estimar-gramos-por-día)
6. [Atrición y retorno](#6-atrición-y-retorno)
7. [Qué permite asumir Markov](#7-qué-permite-asumir-markov)
8. [Ejercicio realizado y resultados](#8-ejercicio-realizado-y-resultados)
9. [Sensibilidades y diagnóstico exploratorio](#9-sensibilidades-y-diagnóstico-exploratorio)
10. [Variables relevantes y códigos censales](#10-variables-relevantes-y-códigos-censales)
11. [Reproducibilidad y verificaciones](#11-reproducibilidad-y-verificaciones)
12. [Fuentes](#12-fuentes)

## 1. Conclusión de factibilidad

TSM permite observar cambios individuales en las respuestas de frecuencia de consumo y frecuencia de ocasiones con seis o más tragos. Hay un identificador individual longitudinal, tres ítems de alcohol en las cinco rondas y suficientes pares para un análisis conjunto con pocas categorías.

Es factible aprovechar un panel no balanceado: no hace falta exigir cinco entrevistas por persona. El ejercicio reúne **4.101 transiciones entre rondas consecutivas, aportadas por 1.907 personas de 18–65 años en ambos extremos de cada intervalo**. En todos los adultos son **6.276 transiciones de 2.763 personas**.

La estimación directa de gramos/día, la separación entre abstinentes de vida y exbebedores, y la equivalencia con HED de ENPG no están identificadas con estos ítems. Una aproximación de volumen necesita supuestos explícitos. Una matriz anual requiere además modelar la duración desigual de los intervalos.

## 2. Limitación importante: ventana temporal

> **Los ítems de alcohol no especifican un período de referencia en los cuestionarios R7–R10 revisados. Esta es una limitación importante para interpretar prevalencias, cambios y transiciones.**

No se puede identificar si una respuesta describe los últimos 30 días, el último año o un patrón habitual más amplio. Por tanto, dos respuestas distintas entre olas no pueden interpretarse directamente como cambio de consumo mensual, y dos respuestas iguales no prueban persistencia continua durante todo el intervalo.

La expresión “últimas semanas” de la página 16 pertenece a la introducción de GHQ-12, seguida por una escala laboral antes de AUDIT-C. **No corresponde trasladarla a los ítems de alcohol.** La ausencia de ventana también afecta cualquier cálculo de gramos/día a partir de frecuencia habitual.

Para R11 se verificaron variables y etiquetas del SAV; **su cuestionario no está en la carpeta**, por lo que no se verificaron sus instrucciones y saltos directamente en el instrumento.

## 3. Archivos, muestra e identificación

Los archivos contienen un listado de integrantes del hogar, además del entrevistado seleccionado. Alcohol solo está respondido para **Entrevistado == 1**. Usar todas las filas como muestra de alcohol inflaría el denominador.

| Ronda | Fecha aproximada | Filas del hogar | Entrevistados | Entrevistados 18–65 | Declaran beber, todas las edades |
| --- | --- | --- | --- | --- | --- |
| R7 | abril 2023 | 7.684 | 3.012 | 2.123 | 1.405 |
| R8 | diciembre 2023 | 5.064 | 2.040 | 1.405 | 853 |
| R9 | abril 2024 | 7.525 | 3.056 | 2.137 | 1.297 |
| R10 | noviembre 2024 | 6.254 | 2.430 | 1.672 | 1.187 |
| R11 | abril 2025* | 6.490 | 2.547 | 1.723 | 1.147 |

Las fechas R7–R10 se verificaron en las portadas. *R11 abril 2025 proviene de la guía local; no hay cuestionario R11 para corroborarlo. Son fechas aproximadas de ronda, no fechas individuales de entrevista.

**Enlace:** usar IdPanel. Su etiqueta SPSS identifica al integrante entre rondas; está completo y es único entre entrevistados en cada ola. IdEncuesta identifica la entrevista/hogar dentro de ronda; IdPersona identifica al integrante dentro del hogar y no es único por sí solo.

**Control de calidad:** R10 tiene tres filas duplicadas por IdPanel en el listado completo del hogar; ninguna está entre los entrevistados. En pares consecutivos hubo 0/0/0/1 cambios de sexo y 19/19/52/30 cambios de edad fuera de 0–2 años, respectivamente. Se conservaron en el principal y se evaluaron sensibilidades. El ID y sus etiquetas apoyan el enlace; las inconsistencias requieren revisión, no sustitución automática del identificador.

## 4. ítems, respuestas y saltos de alcohol

Los tres ítems siguientes tienen las mismas categorías en los cuatro PDF, página 17, y las mismas etiquetas en los cinco SAV.

| Variable | Pregunta/constructo | Códigos |
| --- | --- | --- |
| e3a1 | Frecuencia de tomar alguna bebida alcohólica | 1 Nunca; 2 Una vez al mes o menos; 3 Dos a cuatro veces al mes; 4 Dos a tres veces a la semana; 5 Cuatro o más veces a la semana |
| e3a2 | Tragos en un día típico de consumo | 1 Entre 0 y 2; 2 Entre 3 y 4; 3 Entre 5 y 6; 4 Entre 7 y 9; 5 Diez o más |
| e3a3 | Frecuencia de seis o más tragos en una sola ocasión | 1 Nunca; 2 Menos de una vez al mes; 3 Mensualmente; 4 Semanalmente; 5 Todos o casi todos los días |
| e3b | Cambio respecto de antes de la pandemia | 1 Ha aumentado; 2 Se ha mantenido; 3 Ha disminuido. Solo R7 y R8. |

**Salto verificado:** e3a1=1 lleva a e4a, módulo de tabaco; e3a2/e3a3 no aplican. No se deben tratar esos vacíos como no respuesta de un bebedor. “Nunca” es una respuesta de frecuencia y no permite identificar abstinencia de vida.

En las cinco rondas no hubo cantidad ni frecuencia de seis o más faltantes entre quienes responden e3a1 en 2–5. Se encontró **una excepción en R8**: e3a1=1, e3a2=2, e3a3=1. En el ejercicio principal prevalece la respuesta explícita e3a1=1, asignando estado N; se repitió excluyendo al ID afectado.

**Umbral HED verificado:** seis o más tragos por ocasión, igual para ambos sexos. No se verificó definición de trago estándar ni equivalencia en gramos. No debe llamarse automáticamente “≥60 g” ni “HED últimos 30 días”, y difiere de la definición ENPG 5+ hombres/4+ mujeres.

Se pueden construir “alguna frecuencia de seis o más” (e3a3=2–5), “mensual o mayor” (3–5) y “semanal o mayor” (4–5), condicionando a e3a1=2–5. Son categorías de frecuencia declarada sin ventana explícita. AUDIT-C usa los códigos 1–5 de cada ítem recodificados a 0–4; los saltos de quienes declaran nunca requieren puntaje 0 en los ítems no aplicables si se construye esa escala. El puntaje AUDIT-C **no es gramos/día**.

## 5. Posibilidad de estimar gramos por día

Una aproximación sería:

`g/día ≈ días de consumo/año × tragos/día de consumo × gramos/trago ÷ 365`

Cada componente requiere decisiones: valor dentro de los intervalos de frecuencia; valor dentro de los intervalos de cantidad; tratamiento de ≥4 veces/semana y ≥10 tragos; y gramos/trago. “Entre 0 y 2” tampoco identifica exactamente un trago por día de consumo.

No se encontraron gramos por trago, volumen/gradación por bebida ni equivalencias de trago en los cuatro PDF. No se calcularon gramos/día ni categorías WHO como si fueran observadas. Antes de usar un proxy, documentar una conversión principal y sensibilidades para los extremos abiertos y gramos/trago. La ventana temporal no especificada sigue siendo una limitación aun después de elegir conversiones.

## 6. Atrición y retorno

Los porcentajes siguientes son ausencia de entrevista en la siguiente ronda entre quienes fueron entrevistados en la anterior. No son por sí mismos abandono definitivo ni una tasa oficial de no respuesta del diseño.

| Intervalo | n inicial | Reentrevistados | Ausentes | % ausente | En siguiente ola pero no en anterior |
| --- | --- | --- | --- | --- | --- |
| R7-R8 | 3.012 | 1.503 | 1.509 | 50,1% | 537 |
| R8-R9 | 2.040 | 1.379 | 661 | 32,4% | 1.677 |
| R9-R10 | 3.056 | 1.899 | 1.157 | 37,9% | 531 |
| R10-R11 | 2.430 | 1.495 | 935 | 38,5% | 1.052 |

Los que no estaban en la ola previa pueden ser retornos o incorporaciones; estos archivos no bastan para clasificarlos como nuevos reclutas. **685 entrevistados de R7 faltan en R8 y reaparecen en R9.**

De 3.012 entrevistados de R7, 1.334 vuelven a estar entrevistados en R11: retención 44,3%; ausencia al final 55,7%. Solo 674 participan en las cinco rondas (22,4%). Entre los 2.123 de 18–65 en R7, 906 están entrevistados en R11 (ausencia 57,3%) y 418 están en las cinco olas.

Para el seguimiento más corto R9→R11, de 3.056 entrevistados iniciales permanecen 1.543: ausencia al final de 49,5%. Este porcentaje tampoco distingue abandono definitivo, ausencia temporal, fallecimiento u otras causas de falta de entrevista.

La ausencia al final según características de R7 es:

| Característica R7 | Grupo | n basal | Entrevistados R11 | % ausente R11 |
| --- | --- | --- | --- | --- |
| Sexo | Mujeres | 1.922 | 866 | 54,9% |
| Sexo | Hombres | 1.090 | 468 | 57,1% |
| Edad | 66+ | 889 | 428 | 51,9% |
| Edad | 60-65 | 402 | 195 | 51,5% |
| Edad | 30-44 | 683 | 267 | 60,9% |
| Edad | 45-59 | 777 | 354 | 54,4% |
| Edad | 18-29 | 261 | 90 | 65,5% |
| Estado alcohol | N | 1.607 | 687 | 57,2% |
| Estado alcohol | D | 1.041 | 480 | 53,9% |
| Estado alcohol | H | 364 | 167 | 54,1% |

N/D/H se definen abajo. La ausencia está asociada descriptivamente con edad: 65,5% en 18–29 frente a 51,5% en 60–65. No se ajustó un modelo de respuesta ni se aplicaron pesos longitudinales. Los faltantes estructurales de alcohol no son atrición.

## 7. Qué permite asumir Markov

Sí se puede sumar información de sujetos distintos que **cada uno aporta su propia transición observada**. No hace falta que todos están en todas las rondas. Ejemplo: A aporta R7–R8, B aporta R8–R9 y C aporta R9–R10. Estas contribuciones pueden entrar en el mismo análisis.

**No se puede formar una transición con el estado de A en R7 y el de B en R8.** Si son individuos distintos y no se observa su seguimiento, solo se comparan distribuciones marginales; la propiedad de Markov no identifica las transiciones.

La hipótesis de primer orden es:

`P(S siguiente | S actual, historia previa, covariables) = P(S siguiente | S actual, covariables)`

Esto permite factorizar la verosimilitud condicional de las trayectorias por sus transiciones, bajo el modelo. **No equivale a independencia marginal de las filas aportadas por la misma persona.** Tampoco garantiza independencia entre integrantes del mismo hogar o elimina heterogeneidad individual. Se conservó IdPanel para remuestrear personas con todos sus intervalos.

También hay que separar **Markov de primer orden** de **homogeneidad temporal**: que solo importe el estado actual no implica que las probabilidades sean iguales en todas las olas. Los intervalos aproximados son 8, 4, 7 y 5 meses. Por ello:

- Cada matriz por intervalo describe ese enlace observado.
- La matriz agrupada es una mezcla descriptiva de esos intervalos, ponderada por el número de transiciones que parten de cada estado.
- No se interpreta como matriz de 12 meses ni se anualiza dividiendo probabilidades por meses.
- Para una matriz anual, un candidato es un modelo continuo con P(Δt)=exp(QΔt), justificando sus intensidades, covariables y supuestos. **No se ajustó ese modelo aquí.** La documentación de [msm](https://chjackson.github.io/msm/reference/msm.html) permite observación en tiempos arbitrarios y probabilidades dependientes de la duración.
- Personas que faltan una ola podrían aportar un enlace entre sus siguientes observaciones, con duración mayor, en un modelo que incorpore Δt. No se inventaron estados intermedios ni se incluyeron esos enlaces largos en este ejercicio.

Markov no corrige atrición informativa: quienes aportan pares pueden diferir de quienes no vuelven. Tampoco transforma respuestas de ventana desconocida en estados instantáneos perfectamente medidos.

## 8. Ejercicio realizado y resultados

### 8.1 Estados, población y estimador

Se usaron tres estados observados:

| Estado | Definición | Interpretación |
| --- | --- | --- |
| N | e3a1=1 | Declara “Nunca” a frecuencia de beber; historia de abstinencia desconocida |
| D | e3a1=2–5 y e3a3=1 | Declara beber y nunca seis o más por ocasión |
| H | e3a1=2–5 y e3a3=2–5 | Declara beber y alguna frecuencia de seis o más por ocasión |

Son estados basados en respuestas, no estados ENPG ni categorías de gramos/día. D puede incluir personas con alto volumen por frecuencia; H puede incluir episodios infrecuentes.

Principal: entrevistados, mismo IdPanel, rondas consecutivas, edad 18–65 en ambas, estados válidos en ambas. Edad y sexo no se “corrigen” automáticamente. Todos los conteos son **sin ponderar**. Fact_Exp es un factor de expansión transversal; no se asumió que fuera peso longitudinal.

Estimador por intervalo: número de transiciones a cada destino dividido por el total que parte del estado inicial. Es la estimación saturada de las probabilidades de transición observadas; no se impusieron ceros a cambios N→H.

| Intervalo | Meses aproximados | Pares, ambos 18–65 | Beben en ambos extremos |
| --- | --- | --- | --- |
| R7-R8 | 8 | 991 | 377 |
| R8-R9 | 4 | 888 | 306 |
| R9-R10 | 7 | 1.256 | 493 |
| R10-R11 | 5 | 966 | 404 |

Se obtuvieron **4.101 pares de 1.907 personas únicas**. Cada persona aporta entre uno y cuatro pares; el total de pares no equivale a ese número de sujetos independientes.

| Pares aportados por persona | Personas |
| --- | --- |
| 1 | 706 |
| 2 | 596 |
| 3 | 217 |
| 4 | 388 |

### 8.2 Matriz agrupada: mezcla descriptiva de intervalos

Cada celda presenta porcentaje por fila, conteo y un IC95% percentil obtenido mediante **2.000 réplicas de bootstrap por IdPanel**, conservando todos los intervalos de cada persona. Semilla 1240138. El IC refleja incertidumbre de esta mezcla muestral, no selección por atrición, diseño completo de encuesta ni incertidumbre del instrumento.

| Estado inicial | Transiciones iniciales | Destino N | Destino D | Destino H |
| --- | --- | --- | --- | --- |
| N | 2.011 | 76,7% (n=1.542); IC95% 74,5%–78,6% | 19,3% (n=389); IC95% 17,6%–21,2% | 4,0% (n=80); IC95% 3,2%–4,9% |
| D | 1.475 | 27,4% (n=404); IC95% 25,0%–30,0% | 57,0% (n=841); IC95% 54,0%–59,6% | 15,6% (n=230); IC95% 13,7%–17,5% |
| H | 615 | 17,2% (n=106); IC95% 14,4%–20,3% | 42,0% (n=258); IC95% 38,0%–46,3% | 40,8% (n=251); IC95% 36,4%–44,9% |

Así, 40,8% de las transiciones que parten de H terminan en H; 42,0% pasan a D y 17,2% a N. Entre las que parten de D, 15,6% terminan en H. Son cambios de respuestas entre entrevistas de distinta separación; no son probabilidades anuales ni se interpretan causalmente.

### 8.3 Matrices separadas por intervalo

#### R7-R8

| Estado inicial | Transiciones iniciales | Destino N | Destino D | Destino H |
| --- | --- | --- | --- | --- |
| N | 466 | 79,8% (n=372) | 17,8% (n=83) | 2,4% (n=11) |
| D | 365 | 30,7% (n=112) | 56,4% (n=206) | 12,9% (n=47) |
| H | 160 | 22,5% (n=36) | 34,4% (n=55) | 43,1% (n=69) |

#### R8-R9

| Estado inicial | Transiciones iniciales | Destino N | Destino D | Destino H |
| --- | --- | --- | --- | --- |
| N | 456 | 77,4% (n=353) | 18,2% (n=83) | 4,4% (n=20) |
| D | 318 | 31,4% (n=100) | 54,4% (n=173) | 14,2% (n=45) |
| H | 114 | 22,8% (n=26) | 41,2% (n=47) | 36,0% (n=41) |

#### R9-R10

| Estado inicial | Transiciones iniciales | Destino N | Destino D | Destino H |
| --- | --- | --- | --- | --- |
| N | 653 | 72,3% (n=472) | 21,3% (n=139) | 6,4% (n=42) |
| D | 423 | 21,0% (n=89) | 60,0% (n=254) | 18,9% (n=80) |
| H | 180 | 11,7% (n=21) | 43,9% (n=79) | 44,4% (n=80) |

#### R10-R11

| Estado inicial | Transiciones iniciales | Destino N | Destino D | Destino H |
| --- | --- | --- | --- | --- |
| N | 436 | 79,1% (n=345) | 19,3% (n=84) | 1,6% (n=7) |
| D | 369 | 27,9% (n=103) | 56,4% (n=208) | 15,7% (n=58) |
| H | 161 | 14,3% (n=23) | 47,8% (n=77) | 37,9% (n=61) |

La persistencia H→H oscila descriptivamente entre 36,0% y 44,4%. N→H varía entre 1,6% y 6,4%. Estas diferencias pueden reflejar duración, calendario, composición de respondentes y error de medición. No se hizo una prueba formal de homogeneidad.

## 9. Sensibilidades y diagnóstico exploratorio

### 9.1 Sensibilidades ejecutadas

Se contrastó el principal con adultos de todas las edades, primer par elegible por persona, ponderación para que cada persona aporte peso total uno, exclusión de inconsistencias demográficas, panel de cinco olas y umbral mensual de seis o más.

| Escenario | Pares | Personas | N→N | D→D | H→H |
| --- | --- | --- | --- | --- | --- |
| Todos los adultos, 18+ | 6.276 | 2.763 | 78,3% | 55,4% | 37,3% |
| Solo primer par elegible por persona | 1.907 | 1.907 | 75,6% | 56,8% | 41,4% |
| Peso total 1 por persona | 4.101 | 1.907 | 76,2% | 56,0% | 39,5% |
| Excluir pares con edad/sexo inconsistente | 4.033 | 1.887 | 76,9% | 57,0% | 40,8% |
| Solo participantes de las cinco olas | 1.599 | 414 | 78,9% | 60,2% | 44,0% |
| H=seis o más mensual o mayor | 4.101 | 1.907 | 76,7% | 68,4% | 27,5% |
| Excluir IDs con cualquier inconsistencia demográfica en enlaces | 3.944 | 1.839 | 77,0% | 57,3% | 41,1% |
| Excluir ID con salto contradictorio R8 | 4.100 | 1.906 | 76,7% | 57,1% | 40,8% |

El primer par por persona conserva 1.907 transiciones sin repetición de IDs; se aprovecha menos información y cambia la mezcla de calendarios. El peso igual por persona cambia el objetivo del promedio respecto del peso igual por transición.

Excluir IDs con inconsistencias demográficas deja 3.944 pares de 1.839 personas y H→H=41,1%, próximo al 40,8% principal. Excluir al ID del salto contradictorio R8 deja 4.100 pares de 1.906 personas.

El panel de cinco olas aporta 1.599 pares elegibles de 414 personas. Son menos que los 418 de edad basal 18–65 porque aquí se exige ese rango en ambos extremos de cada par. No se debe interpretar la diferencia con el principal como efecto exclusivo de atrición: también cambia la composición.

Con H mensual o más, H→H es 27,5%. **Esto define otro estado:** D pasa a incluir consumo sin seis o más y seis o más menos de una vez al mes. No es una sensibilidad de gramos/trago.

### 9.2 Historia previa: descripción exploratoria, sin prueba formal de Markov

Se tabularon tríos consecutivos, edad 18–65 en las tres entrevistas. La siguiente tabla fija el estado actual D y distingue el estado anterior, para examinar si las distribuciones futuras podrían depender de la historia. No ajusta por edad/sexo/educación, selección, repetición de sujetos ni error de medición, y no constituye un contraste formal del supuesto Markov.

| Trío | Estado anterior | Estado actual | n | Destino H | % destino H |
| --- | --- | --- | --- | --- | --- |
| R7-R8-R9 | N | D | 60 | 1 | 1,7% |
| R7-R8-R9 | D | D | 152 | 21 | 13,8% |
| R7-R8-R9 | H | D | 36 | 17 | 47,2% |
| R8-R9-R10 | N | D | 52 | 9 | 17,3% |
| R8-R9-R10 | D | D | 135 | 16 | 11,9% |
| R8-R9-R10 | H | D | 35 | 12 | 34,3% |
| R9-R10-R11 | N | D | 91 | 10 | 11,0% |
| R9-R10-R11 | D | D | 165 | 24 | 14,5% |
| R9-R10-R11 | H | D | 52 | 14 | 26,9% |

La tabla muestra una señal descriptiva de dependencia de la historia: en R7–R8–R9, entre quienes están en D en R8, el destino H en R9 ocurre en 1,7% si antes estaban en N, 13,8% si estaban en D y 47,2% si estaban en H. Los denominadores respectivos son 60, 152 y 36. No basta para rechazar formalmente Markov, pero impide presentar la memoria de primer orden como validada para estos tres estados agregados. La heterogeneidad individual y la clasificación gruesa pueden producir este patrón.

El supuesto de primer orden se mantuvo como supuesto de trabajo, **no como hecho validado**. Una evaluación posterior necesitaría comparar modelos con y sin historia adicional, considerar covariables y duración, y manejar la dependencia por persona. Una alternativa a evaluar es ampliar el estado o incluir el estado previo como predictor, conservando la evaluación de incertidumbre y selección.

### 9.3 Tamaños para estratificar

En cada ronda, edad (18–29/30–44/45–59/60–65) × sexo × educación cursada (tres grupos) × indicador de seis o más produce 48 celdas. En la revisión de los datos, 15–21 celdas por ola tuvieron n<10, aun antes de añadir categorías de cantidad/volumen. No se estimaron matrices completamente separadas para todas esas celdas. Para esa extensión se requiere compartir información entre estratos y evaluar tamaño por estado inicial y por transición.

## 10. Variables relevantes y códigos censales

Aquí “censales” significa variables demográficas, geográficas y del hogar contenidas en TSM. **No se incorporó una base del Censo INE.** Se tomaron los códigos reales de los SAV, no nombres supuestos de ENPG.

### 10.1 Variables principales

| Variable | Contenido | Uso/precaución |
| --- | --- | --- |
| IdPanel | Persona longitudinal | ID para enlace; no usar IdPersona solo |
| IdEncuesta | Entrevista/hogar en ronda | No reemplaza IdPanel |
| IdPersona | Integrante dentro del hogar | No es único globalmente |
| Entrevistado | Selección analítica | 0 resto integrantes; 1 entrevistado panel |
| Fact_Exp | Ponderador transversal | No usar automáticamente como peso de transición |
| IdRegion | Región | Códigos 1–16, detalle abajo |
| a2 | Sexo | 1 Hombre; 2 Mujer |
| a3 | Edad | Edad numérica en años; controlar consistencia longitudinal |
| a4 | Parentesco con entrevistado | 1 entrevistado; resto de códigos abajo |
| a6 | Estado civil/conyugal | Códigos abajo |
| a7 | Nacionalidad | Códigos abajo |
| a8 | País donde vivía la madre cuando nació la persona | No equivale directamente a nacionalidad; códigos abajo |
| a9 | Llegada a Chile: tipo de respuesta | 1 ingresa año; 2 no sabe/no recuerda |
| a9a | Llegada a Chile: año declarado | Campo numérico; no confundir con código a9 |
| a10 | Llegada a Chile: intervalo de año | Códigos abajo |
| a12 | Pertenencia/descendencia indígena | 1 Sí; 2 No |
| a12b | Pueblo indígena | Códigos abajo |
| b1 | Matrícula/asistencia educacional | 1 Sí; 2 No |
| b2 | Asistencia presencial la semana pasada | 1 Sí; 2 No; condicionado por escolaridad |
| b4a | Educación cursada | Nivel más alto alcanzado o actual; códigos abajo |
| b4b | Curso aprobado/actual | Numérico; interpretación cambia según estudia/no estudia |
| b5 | Duración carrera pregrado | Años; revisar universo |
| c1 | Trabajó la semana pasada | 1 Sí; 2 No |
| c2 | Otra actividad de trabajo ≥1 hora | 1 Sí; 2 No |
| c3 | Vínculo con empleo pese a no trabajar | Códigos cambian entre R7/R8 y R9–R11 |
| c4 | Trabajó alguna vez | 1 Sí; 2 No |
| c5 | Buscó trabajo/inició gestión de actividad | 1 Sí; 2 No |
| c6 | Razón principal de no buscar trabajo | Códigos abajo |
| c10 | Categoría ocupacional | Códigos abajo |
| c11 | Contrato escrito | Códigos abajo |
| c8_1dig / c8_4dig | Ocupación actual | Codificación de ocupación; no se expandió catálogo CIUO |
| c12_1dig / c12_4dig | Actividad del negocio | Código de actividad; catálogo no incluido aquí |
| c14ah / c14ad | Horas/días trabajados | Numéricos; no son códigos de respuesta dicotómica |
| d1 / d1m | Sueldo o salario líquido mensual | d1 tipo de respuesta; d1m monto |
| d2 / d2m | Especies/regalías laborales | d2 tipo de respuesta; d2m monto |
| d5 / d5m | Ingreso de actividad independiente | d5 tipo de respuesta; d5m monto |
| e3a1 / e3a2 / e3a3 | Alcohol a nivel de ítem | Tres ítems y códigos en sección 4 |
| e3b | Cambio de consumo respecto de prepandemia | Solo R7–R8 |

Edad, sexo y educación existen para integrantes del hogar; para alcohol deben tomarse de la fila del entrevistado. No se encontraron variables llamadas comuna/urbano/rural en el listado revisado; IdRegion sí está disponible. La carpeta no contiene un catálogo censal externo ni documentación de UPM/estratos que permita reconstruir automáticamente todo el diseño muestral.

### 10.2 Códigos sociodemográficos y ocupacionales verificados

Las variables siguientes están presentes en R7–R11. Se muestran etiquetas de R9 cuando son iguales y se separan las versiones que cambian.

#### IdRegion

**R7, R8, R9, R10, R11**: 1=De Tarapaca; 2=De Antofagasta; 3=De Atacama; 4=De Coquimbo; 5=De Valparaiso; 6=Del Lib.B. O´Higgins; 7=Del Maule; 8=Del Biobio; 9=De la Araucanía; 10=De los Lagos; 11=De Aysen; 12=De Magallanes; 13=Metropolitana; 14=De los Rios; 15=De Arica y Parinacota; 16=De Ñuble.

#### a4

**R7, R8, R9, R10, R11**: 1=Entrevistado(a); 2=Cónyuge(a) o pareja; 3=Hijo(a); 4=Padre o Madre; 5=Suegro(a); 6=Yerno o Nuera; 7=Nieto(a); 8=Hermano(a); 9=Cuñado(a); 10=Otro familiar; 11=Otro no familiar; 12=Servicio Doméstico P. Adentro.

#### a6

**R7, R8, R9, R10, R11**: 1=Casado(a); 2=Conviviente o pareja; 3=Anulado(a); 4=Separado(a); 5=Divorciado(a); 6=Viudo(a); 7=Soltero(a).

#### a7

**R7, R8, R9, R10, R11**: 1=Chilena (exclusiva); 2=Chilena y otra (doble nacionalidad); 3=Otra nacionalidad (extranjeros).

#### a8

**R7, R8, R9, R10, R11**: 1=Perú; 2=Haití; 3=Colombia; 4=Venezuela; 5=Ecuador; 6=Bolivia; 7=Argentina; 8=Otro. Especifique.

#### a9

**R7, R8, R9, R10, R11**: 1=Ingrese año; 2=No sabe/No se acuerda.

#### a10

**R7, R8, R9, R10, R11**: 1=Año 1989 o antes; 2=Entre 1990 y 1999; 3=Entre 2000 y 2004; 4=Entre 2005 y 2009; 5=Entre 2010 y 2014; 6=Entre 2015 y 2016; 7=Entre 2017 y 2018; 8=Año 2019 o después; 9=No sabe.

#### a12

**R7, R8, R9, R10, R11**: 1=Sí; 2=No.

#### a12b

**R7, R8, R9, R10, R11**: 1=Aimara; 2=Rapa-Nui o Pascuenses; 3=Quechua; 4=Mapuche; 5=Atacameño (Likan-Antai); 6=Collas; 7=Kawashkar o Alacalufes; 8=Yámana o Yagán; 9=Diaguita; 10=Chango; 11=No pertenece a ninguno de estos pueblos indígenas.

#### b4a

**R7, R8, R9, R10, R11**: 1=Nunca asistió; 2=Preescolar; 3=Especial (Diferencial); 4=Básica; 5=Media Científico-Humanista; 6=Media Técnica-Profesional; 7=Superior Técnica (CFT o I. Profesional); 8=Superior Universitaria (Pregrado); 9=Postgrado; 10=NS/NR.

#### c3

**R7, R8**: 1=Sí, por suspensión temporal de su contrato laboral por COVID-19; 2=Sí, por licencia médica por COVID-19; 3=Sí, por permiso de su empleador por cuarentena u otra razón; 4=Sí, por licencia médica por otra enfermedad; 5=Sí, por permiso pre o post-natal; 6=Sí, por huelga; 7=Sí, por enfermedad; 8=Sí, por vacaciones; 9=Sí, por otra razón. Especifique; 10=No.

**R9, R10, R11**: 4=Sí, por licencia médica por otra enfermedad; 5=Sí, por permiso pre o post-natal; 6=Sí, por huelga; 7=Sí, por enfermedad; 8=Sí, por vacaciones; 9=Sí, por otra razón. Especifique; 10=No.

#### c6

**R7, R8, R9, R10, R11**: 1=Está dedicado(a) a los quehaceres del hogar; 2=Está dedicado(a) al cuidado de menores; 3=Está dedicado(a) al cuidado de algún adulto mayor o enfermo; 4=Está estudiando; 5=Está inválido(a) o tiene alguna enfermedad crónica; 6=Está jubilado(a) o tiene alguna pensión; 7=Es menor de edad o de edad avanzada; 8=Otra razón. Especifique.

#### c10

**R7, R8, R9, R10, R11**: 1=Patrón o empleador; 2=Trabajador por cuenta propia; 3=Empleado u obrero del sector público; 4=Empleado u obrero de empresa pública; 5=Empleado u obrero del sector privado; 6=Servicio doméstico puertas adentro; 7=Servicio doméstico puertas afuera; 8=FF.AA. y de Orden; 9=Familiar no remunerado.

#### c11

**R7, R8, R9, R10, R11**: 1=Sí, tiene contrato firmado; 2=Sí, tiene contrato, pero no ha firmado; 3=No tiene contrato escrito; 4=No sabe o no se acuerda si firmó contrato.

#### c13

**R7, R8, R9, R10, R11**: 1=Sólo una persona (el entrevistado); 2=De 2 a 5 personas; 3=De 6 a 9 personas; 4=De 10 a 49 personas; 5=De 50 a 199 personas; 6=200 y más personas; 7=No sabe.

#### d1

**R7, R8, R9, R10, R11**: 1=Monto mensual $; 2=No recibió sueldo o salario; 9=NS/NR.

#### d2

**R7, R8, R9, R10, R11**: 1=Monto mensual $; 2=No recibió especies o regalías; 9=NS/NR.

#### d5

**R7, R8, R9, R10, R11**: 1=Monto mensual $; 2=No recibió ingresos; 9=NS/NR.

**Educación cursada simplificada:** b4a en 1–4 → Básica o menos; 5–6 → Media; 7–9 → Superior; 10 o faltante → sin clasificar. No exige haber completado el nivel. Nunca usar 10 (NS/NR) como una categoría educativa sustantiva.

**Grupos de edad derivados:** [18,30), [30,45), [45,60), [60,66), para el análisis adulto. TSM no proporciona entrevistados de alcohol de 15–17 años, por lo que no cubre todo el tramo ENPG 15–29.

### 10.3 Diccionario ampliado por ronda

Se entrega [diccionario_TSM_variables_relevantes.csv](diccionario_TSM_variables_relevantes.csv), extraído de los cinco SAV: variables de ID/ponderación, módulos a/b/c/d y alcohol e3, con etiqueta, códigos y n no faltante entre entrevistados. Incluye 842 filas variable-ronda. Las etiquetas SPSS originales pueden estar truncadas; no se inventó el texto faltante.

El [codebook preexistente](CODEBOOK_TSM_SAV_variables.csv) incluye todos los módulos de la encuesta. Los saltos de módulos distintos de alcohol no fueron auditados exhaustivamente: la presencia de una variable no implica que sea aplicable a toda la muestra.

## 11. Reproducibilidad y verificaciones

- [explorar_tsm_markov.R](explorar_tsm_markov.R) reproduce la lectura de SAV, auditoría, enlaces, matrices, bootstrap y sensibilidades; exporta solo resultados agregados.
- [hallazgos_TSM_resultados.json](hallazgos_TSM_resultados.json) conserva los resultados numéricos agregados y sessionInfo de esta ejecución, sin IDs individuales.
- El script usa haven y jsonlite ya disponibles. No instala paquetes ni modifica los originales.
- Ejecución desde esta carpeta con el Rscript configurado en tu equipo: `Rscript explorar_tsm_markov.R`. Escribe/reemplaza el JSON agregado; no regenera automáticamente este Markdown.
- Validaciones ejecutadas: ID único/completo entre entrevistados; códigos válidos de alcohol; estados completos en los pares; ausencia de duplicados por par/ID; suma de conteos igual al total de pares; probabilidades suman uno por fila; contribuciones del bootstrap reconciliadas; ninguna probabilidad faltante en las 2.000 réplicas.
- Bootstrap de personas con reemplazo: cada ID arrastra todos sus pares elegibles. No es una corrección completa del diseño de encuesta ni de atrición.
- Las matrices principales se estimaron en datos reales. No se validó un simulador chileno, no se calibraron transiciones anuales ni se probó definitivamente la hipótesis Markov.
- La revisión de PDF incluyó los cuatro cuestionarios completos para localizar definiciones de trago y período temporal. El instrumento R11 permanece pendiente.

### Huellas de fuentes originales

MD5 se incluye para identificar exactamente los archivos analizados; no es una garantía criptográfica de autenticidad.

| Archivo | MD5 |
| --- | --- |
| CODEBOOK_TSM_SAV_variables.csv | 8cfa6769fb8c2cfdcca7a7acf8592983 |
| Cuestionario R10.pdf | 05fa8a2c00e0f04f17e15ada2ea89899 |
| Cuestionario R7.pdf | e2c2fb954cfa953997cb3bc8bf53e6a0 |
| Cuestionario R8.pdf | a4bf71aa65fe4c01d44327a071550eaa |
| Cuestionario R9.pdf | d1146b82f4369902a1f3bafe11a04613 |
| GUIA_LECTURA_BUNDLE_OUTPUTS.md | 7b549c763d3e48cd501fc73cbde23365 |
| TSM Ronda 10.sav | 2e27dc6dfa3e889ee947fbe6dc80b100 |
| TSM Ronda 11.sav | dbe0d638df8f36b0a06731fea09eedea |
| TSM Ronda 7.sav | 2cd97e506625b0af12767e2bd6763c37 |
| TSM Ronda 8.sav | 7fcf74c1deb83ec53fe1ebdb27b09173 |
| TSM Ronda 9.sav | 8139effe4619401a8a82879eb76cc07e |

## 12. Fuentes

- SAV originales: TSM Ronda 7.sav a TSM Ronda 11.sav.
- [Cuestionario R7](<Cuestionario R7.pdf#page=17>), [R8](<Cuestionario R8.pdf#page=17>), [R9](<Cuestionario R9.pdf#page=17>) y [R10](<Cuestionario R10.pdf#page=17>): página 17 para alcohol; páginas 3–4 para selección/roster; página 7 para educación; página 16 para delimitación de la introducción GHQ.
- [GUIA_LECTURA_BUNDLE_OUTPUTS.md](GUIA_LECTURA_BUNDLE_OUTPUTS.md): contexto de rondas y fecha aproximada R11. Sus resultados de otro análisis no se tomaron como validación de estas transiciones.
- [Documentación oficial de msm](https://chjackson.github.io/msm/reference/msm.html): modelos Markov en tiempo continuo con observaciones a tiempos arbitrarios, covariables y matriz de intensidades. Se cita como opción metodológica; no se ejecutó ese modelo.
- [Documentación de cluster en survival](https://stat.ethz.ch/R-manual/R-patched/library/survival/html/cluster.html): grupos correlacionados y varianza bajo independencia de trabajo. El ejercicio usa bootstrap por persona, no un modelo Cox.


## Sampling design clarification and current weighting

### Sampling design and variance estimation (English)

Official presentations describe an urban sample derived from households previously interviewed in person, but do not identify the original primary sampling units or strata ([Round 10 presentation, p. 6](https://www.achs.cl/docs/librariesprovider2/default-document-library/presentacion-tsm-r10.pdf)). This does not establish that the original design lacked clustering or stratification; rather, these design identifiers were not identified in the publicly released materials reviewed.

Analyses use the wave-specific expansion factor (`Fact_Exp`) from the origin interview. Where specified, this factor is combined with inverse-probability weights for follow-up response; it is not a released longitudinal survey weight. Confidence intervals account for unequal weighting and within-person dependence, and the IPW analysis additionally accounts for estimation of response weights. These remain working approximations because the original sampling structure cannot be reconstructed from the available documentation.

Kish effective sample sizes describe weight dispersion only. No additional Kish multiplier is applied to the weighted variance estimator, because unequal weights already enter its influence contributions. Kish adjustment cannot recover unidentified sampling clusters or strata; the direction and magnitude of the remaining variance discrepancy are unknown.
