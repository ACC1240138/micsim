# EPS como candidato a motor de transición de consumo

[English notebook](eps_markov_transitions_EN.ipynb) · [English HTML](../eps_markov_transitions_EN.html)

La versión española del notebook y sus figuras se retiraron; este documento conserva la explicación histórica en español. La comparación de reproducibilidad entre idiomas registrada en su momento es histórica y no puede repetirse con los archivos actuales.

**Decisión principal:** EPS, con su diseño muestral y todos los pares de cada
persona unidos en la estimación de incertidumbre. Lognormal obtiene el mejor
puntaje medio; Gamma se conserva. Su diferencia predictiva es pequeña. Todavía
falta calibrar a ENPG y validar externamente.

## Datos y categorías

**8.095 pares de 5.365 personas:** 4.702 VI→VII presencial y 3.393 VII→VIII.
Hay 2.730 personas con ambos pares. Edad: 18–65 al inicio; sin información para
15–17. VII presencial tiene cobertura documentada 23+, aunque los datos incluyen
edad 22. Los grupos 18–29 no tienen idéntica composición en ambos periodos.

| Estado inicial | Pares | Significado |
|---|---:|---|
| N0 | 4.622 | No bebe actualmente; consumo previo no observado, historia incompleta. |
| FD | 412 | No bebe actualmente; consumo previo observado. |
| C1 | 2.822 | Mujeres: >0–<20 g/día; hombres: >0–<40. |
| C2 | 141 | Mujeres: 20–<40; hombres: 40–<60. |
| C3 | 67 | Mujeres: 40–60; hombres: 60–100, incluido el límite superior (60 y 100 g/día respectivamente). |
| C4 | 31 | Mujeres: más de 60 g/día; hombres: más de 100 g/día. |

Por sexo, edad y periodo, **57 de 96 filas tienen menos de 30 pares**; 18 están
vacías. Compartir información mediante modelos conjuntos ayuda, pero no crea
observaciones de transiciones raras.

**Conversión:** sumar cerveza, vino y destilados, calculando para cada bebida
`días/semana × tragos por día de consumo × gramos/trago ÷ 7`.
Principal: 12 g; sensibilidad: 15,7 g. Frecuencia inferior a semanal: 0,5 días.
No se aplica `who_apc`.

F14 sí pregunta por **el último mes**; F13 no explicita una ventana. Calvo
fundamenta frecuencia×cantidad/7, pero sumar bebidas es nuestra adaptación a
ENPG/JRT: su suplemento utiliza el máximo entre bebidas para EPS.
[Artículo](https://pmc.ncbi.nlm.nih.gov/articles/PMC7585691/),
[suplemento, Tabla S2](https://ars.els-cdn.com/content/image/1-s2.0-S0376871620303847-mmc1.docx).

**Abstinencia prolongada:** bandera separada con dos negativas, mínimo garantizado
de cuatro años y ningún consumo previo observado. Se utiliza conservadoramente
la separación mínima entre periodos de campo. Solo aparecen casos en VIII,
sin una ola posterior para estimar transiciones. N0 no se convierte en
abstinencia de vida ni su retorno al consumo en iniciación pura. Se corrigió un
FD→N0 causado por pérdida de historia, sin cambiar los tamaños de muestra.

## Ponderación y varianza

| Componente | Implementación |
|---|---|
| VI→VII | Peso longitudinal oficial + IPW por clasificación/enlace analítico. Sin duplicar corrección de seguimiento. |
| VII→VIII | Peso transversal VII + IPW por seguimiento y clasificación. Excluye fallecimientos conocidos. |
| Diseño principal | JKn con `cluster_ID` y `strata_ID`: 111 UPM, 33 estratos. |
| Personas repetidas | El mismo multiplicador se aplica a todos sus pares. |
| IPW | Se reajusta, incluidos los recortes, en las réplicas principales. |
| Sensibilidad | 1.000 réplicas que remuestrean personas completas y reajustan IPW. |
| Kish | Diagnóstico de dispersión de pesos; no multiplica la varianza. |

**Sí se contempla el anidamiento.** JKn conserva las trayectorias dentro de su
UPM. No se añade otra VCE independiente por ID. Markov no vuelve independientes
los pares superpuestos de una persona.

Hay **32 estratos con una sola UPM**. Se usa `adjust`; `certainty` queda como
sensibilidad descriptiva. Los IC usan la varianza JKn y referencia t con 78
grados de libertad, no percentiles de réplicas. Se utilizan los identificadores
publicados, sin reconstruir FPC ni incertidumbre interna de pesos oficiales.

IPW depende de variables observadas y soporte suficiente. La supervivencia de
quienes desaparecen no está completamente documentada; muerte no es abstención.

## Qué modelo gana y cuánto importa

**Cinco grupos de personas, repetidos tres veces.** IPW se aprende en
entrenamiento; A elige su contracción en pliegues internos. Los comparadores
principales reciben la misma información previa. JRT conserva una especificación
separada, por lo que su comparación no aísla solo la distribución.

| Modelo | Log loss ↓ | Brier ↓ |
|---|---:|---:|
| Lognormal de dos partes | 0,70553 | 0,41653 |
| Ordinal único | 0,70805 | 0,41677 |
| Multinomial | 0,70805 | 0,41695 |
| Ordinal de dos partes | 0,71052 | 0,41689 |
| Matrices A | 0,71479 | 0,42153 |
| Gamma de dos partes | 0,71764 | 0,41669 |
| Referencia JRT | 0,72208 | 0,42213 |

**Lognormal−Gamma:** −0,01211; IC 95%: −0,01919 a −0,00504. Corresponde a
**1,22% de mejora en probabilidad geométrica de lo observado** y un cambio medio
de **0,35 puntos porcentuales por probabilidad de categoría**. Es detectable
en esta comparación, pero pequeño. Los IC consideran UPM/estratos condicionados
a las predicciones entrenadas; no incorporan todo el reentrenamiento ni prueban
superioridad frente a cada competidor cercano.

**Gamma se conserva.** Su diferencia frente a A es incierta. Gamma/lognormal
producen distribuciones: las probabilidades C1–C4 se obtienen integrando entre
cortes. Clasificar únicamente la media perdería esa información. El multinomial
también es paramétrico; mayor eficiencia de Gamma/lognormal no es automática.

**Educación:** estratificar matrices, añadir un efecto ordinal e introducir
interacciones no muestra mejoras claras. Se conserva como covariable candidata,
sin multiplicar las matrices principales. Codificar 0/1/2 supone niveles
equidistantes, no años de escolaridad.

**Odds proporcionales:** la alternativa de cantidad sin ese supuesto mejora
ligeramente el puntaje puntual, pero su IC frente al ordinal incluye cero. Se
eliminó el rechazo formal basado en un likelihood ponderado aproximado.

## Historia, retrotransporte y rank matching

La comparación de historia ajusta por estado y gramos actuales, sexo, edad y
educación; se repite con educación interactuada. Usa historias completas de
tres olas. En las **2.730 personas**, añadir historia cambia el log loss Gamma
en +0,00343 (IC: −0,00504 a +0,01191); con educación interactuada, +0,00302
(−0,00541 a +0,01146). **No mejora claramente la predicción ajustada.** Esto
no demuestra que el proceso sea Markov. Chapman–Kolmogorov es un diagnóstico
marginal separado, que puede discrepar sin identificar una causa única.
Resultados: `eps_markov_outputs/adjusted_history_validation.csv` y
`chapman_kolmogorov_descriptive.csv`.

**Retrotransporte sí:** entrenar VII→VIII y evaluar VI→VII, prediciendo siempre
hacia adelante dentro del par. Se excluyen del entrenamiento las personas de
prueba; soporte común 23–65. **Validar alcohol en V/2012 no es factible con los
archivos entregados:** las 21 bases no contienen esos ítems y el RAR contiene
documentación. El dossier oficial, p. 23, también desaconseja inferencias con
esa ronda. Reconstruir V no sería validación observada.

En el transporte hacia VII→VIII, lognormal tiene el mejor log loss puntual:
0,6613, frente a 0,6702 de A y 0,6718 de Gamma (2.943 pares evaluables).
En retrotransporte, multinomial obtiene 0,7743, A 0,7918, lognormal 0,7937 y
Gamma 0,8455 (3.908 pares). **La ventaja cambia según el periodo**; no hay un
ganador universal. Estos puntajes corresponden a poblaciones de prueba distintas
y no son una comparación directa de dificultad entre periodos.

Rank matching y panel real utilizan ahora las mismas personas, pesos y
marginales. La permanencia en C1 es **94,0% frente a 58,3%** en VI→VII, y
**77,4% frente a 52,3%** en VII→VIII, respectivamente. Reproducir prevalencias
no garantiza reproducir movilidad individual.

## Qué puede pasar a microsimulación

- **Disponible:** coeficientes Gamma/lognormal, matrices de intervalo por sexo
  y edad, IC con diseño y una capa anual pooled.
- **Anualización:** generador común, contrastado entre penalizaciones. Sus
  probabilidades anuales son modeladas; no se estiman generadores independientes
  para todas las celdas escasas.
- **Inestabilidad anual importante:** con la misma penalización, otros inicios
  cambian alguna probabilidad hasta 10,5 puntos porcentuales. Al explorar también
  penalizaciones, la diferencia máxima llega a 33,8 puntos. Ajustar casi igual
  las transiciones observadas no identifica una única matriz anual. Los IC
  condicionan a una inicialización/penalización; no cubren toda esta ambigüedad.
  **La capa anual se conserva como exploratoria, no como motor definitivo.**
- **FD anual:** puede incluir consumo imputado entre entrevistas; difiere de
  la historia observada que define FD en las olas.
- **HED:** 5+/4+ de cantidad habitual es una señal auxiliar, no episodios ENPG
  medidos en 30 días. Requiere contrastación/calibración.
- **Pendiente:** calibración ENPG, validación independiente y motor que actualice
  edad y covariables. [Kilian et al. (2025)](https://pubmed.ncbi.nlm.nih.gov/40885207/)
  y [SIMAH 0.1.1](https://doi.org/10.5281/zenodo.15641639) siguen como referencias
  para integrar el motor. Aquí no se importan parámetros estadounidenses.

Con 15,7 g/trago, la escalada desde C1 pasa de 5,49% a 8,93% en Gamma y de
4,98% a 7,28% en lognormal. Es una sensibilidad material de clasificación,
no una prueba de que alguna conversión sea la correcta.

## Códigos y auditoría

| Uso | Variables originales |
|---|---|
| Persona | `folio_n20` |
| Sexo / edad | `a8` / `a9` |
| Educación VI | `a12n`, `a12e`, `a12d` |
| Educación VII/VIII | `a12_n`, `a12_e`, `a12_d` |
| Consumo por bebida | `f13_1`, `f13_2`, `f13_3` |
| Frecuencia último mes | `f14_1`, `f14_2`, `f14_3` |
| Cantidad típica | `f15_1`, `f15_2`, `f15_3` |
| Diseño | `cluster_ID`, `strata_ID` |
| Pesos principales | `factor_Panel_2015` para VI→VII; `factor_XS` de VII para VII→VIII |

El [diccionario](eps_markov_outputs/variable_dictionary.csv) conserva etiquetas
y códigos de respuesta. Los originales no se sobrescriben ni se publican sin
cifrar. Las tablas de resultados son agregadas.

**Reproducibilidad comprobada:** dos sesiones R nuevas, 11 celdas completas por
idioma, 42 CSV idénticos y 47 comprobaciones aprobadas. Todas las 111 réplicas
JKn y las 1.000 por persona terminaron en cada sesión. Los HTML incluyen las
ecuaciones y diez figuras; no requieren descargar recursos para mostrarlas.
Este PASS computacional no resuelve la inestabilidad anual ni sustituye la
validación externa.

[Revisión crítica](eps_markov_review.md) ·
[Reproducción](eps_markov_outputs/reproducibility_report.md) ·
[Hashes](eps_markov_outputs/reproducibility_check.csv)
