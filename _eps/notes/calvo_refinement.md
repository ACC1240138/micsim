# Calvo en EPS: verificación y propuesta operativa

Nota para implementación; no modifica el estimando JRT existente.

**Verificado en Calvo 2020.** Table S2 del suplemento define el promedio diario semanal como `f_b * q_b / 7`; para EPS calcula ese promedio por bebida y toma el **máximo no faltante entre bebidas**. No es máximo de cantidad por ocasión ni suma. No especifica cómo combinar las frecuencias. EPS se trata en vasos/copas genéricos, sin equivalencia a gramos; cantidades extremas se truncan a 70. La lista de pasos contempla abstinencia prolongada y corrección de inconsistencias históricas, pero no entrega código ni una regla EPS detallada para construir cuatro años. El tratamiento de binge es menos claro que la definición conceptual: Table S2 menciona aproximación mediante consumo diario y Table S4 explica que los ítems específicos reducen faltantes, sin activar directamente heavy. [Suplemento leído, Tables S2–S4](https://ars.els-cdn.com/content/image/1-s2.0-S0376871620303847-mmc1.docx).

El texto principal reconoce que EPS no pregunta consumo alguna vez y combina abstinentes de por vida/prolongados. Su Table 2 contiene desigualdades contradictorias para ocasional/moderado; **usar las desigualdades corregidas que ahora proporciona el usuario**. El esquema diario refiere promedio de la semana, distinto de cantidad por ocasión. [Calvo 2020, sección 2.2 y Table 2](https://pmc.ncbi.nlm.nih.gov/articles/PMC7585691/).

**Verificado en los cuestionarios locales.** VI, VII presencial y VIII preguntan F13 por cerveza, vino y pisco/otro licor; F14 es frecuencia semanal durante el último mes; F15 es cantidad aproximada de vasos/copas de las ocasiones de consumo. F15 no dice explícitamente última ocasión, aunque el suplemento describe así su motivación. Ninguna de estas tres preguntas verifica toda la vida ni máximo episódico. Referencias: `8_Cuestionario EPS 2015.txt` p. PDF 48, `22_EPS PRESENCIAL VIVOS.txt` p. 45, `28_Cuadernillo EPS VIII Ronda - Personas Vivas.txt` p. 47, dentro de `tmp/eps_audit/`.

## Traducción computable propuesta — decisiones del análisis

| Estado o componente | Regla pragmática | Etiqueta/flag necesario |
|---|---|---|
| Consumidor actual | Algún F13 válido = sí | Guardar contradicciones con otros ítems |
| Abstinente actual | Todos los F13 de bebidas explícitamente = no | Nunca convertir faltantes a no |
| Categoría 1 | Abstinente actual, otra abstinencia explícita observada al menos cuatro años antes, ninguna evidencia positiva anterior o intermedia | `Abstinente de larga duración (proxy Calvo)` |
| Categoría 2 | Abstinente actual sin cumplir la categoría 1 | `Abstinente actual; historia previa o no descartada` |
| Promedio diario Calvo | `d_calvo = max(f_b * pmin(q_b, 70) / 7)` sobre bebidas informadas | Conservar cobertura de cantidad/frecuencia; máximo observado puede subestimar si falta otra bebida |
| Heavy por volumen | `d_calvo > 3` hombres o `> 2` mujeres | Puede identificarse aunque falte otra bebida: superar ya basta |
| Ocasional/moderado | Si no heavy, separar con frecuencia máxima `<1`/`>=1` día por semana | El máximo de frecuencia es adaptación analítica, no regla confirmada del suplemento |

Para `<1 día`, mantener 0,5/semana como punto de trabajo y 0,25–0,75 como sensibilidad. La frontera ocasional/moderado no cambia dentro de una bebida; en varias bebidas, días distintos pueden acumular >=1. Mostrar esa ambigüedad mediante `max(f_b) <= f_cualquier_bebida <= min(7, sum(f_b))`. La igualdad inferior y superior es un límite de unión de días, no un dato observado.

**HED sin paralizar el cálculo:** conservar una clasificación Calvo por volumen/frecuencia para los registros suficientes y señalar `HED no medido`. Agregar una variante conceptual que active heavy si alguna cantidad típica por bebida supera 5 copas en hombres o 4 en mujeres, con etiqueta `señal de cantidad alta por ocasión`. Es una aproximación útil al componente HED del usuario, no prueba de un episodio máximo ni ausencia de HED cuando queda bajo el umbral. No sumar cantidades de bebidas como si se hubieran tomado simultáneamente. Comparar ambas variantes visualmente. Si se elige esta segunda variante como principal, llamarla explícitamente `Calvo adaptado a EPS` y mantener la variante por volumen como sensibilidad.

## Cuatro años: oportunidad de observación

Construir el proxy en cada entrevista utilizando solamente historia anterior y actual; no reclasificar el pasado con consumo futuro. Con fechas disponibles, usar tiempo transcurrido real. Sin fechas exactas, VI 2016 a VIII 2023–24 supera cuatro años con certeza; VII 2019–20 a VIII 2023–24 puede abarcar tres a cinco años, por lo que cuatro años nominales requieren flag o sensibilidad. No exigir una entrevista intermedia si no existe: registrar `historia incompleta` para distinguir dos observaciones separadas de seguimiento completo.

Si la historia comienza en VI, la categoría 1 puede ser cero al inicio por construcción. Mostrar un gráfico que separe **historia insuficiente** de abstinencia prolongada, o restringir una comparación secundaria a personas con >=4 años observables. Así se evita interpretar mayor oportunidad de seguimiento como aumento real de abstinencia. Buscar historia anterior compatible permitiría mejorar la primera ronda, pero no es requisito para entregar el proxy.

**Casos de comprobación:** no–no separados siete años → categoría 1; sí–no separados siete años → categoría 2; no–no separados tres años → categoría 2; no–NA–no separados siete años → categoría 1 con historia incompleta; falta una bebida y las otras no → estado de abstinencia sin determinar; d=3 hombre/d=2 mujer sin señal episódica → no heavy; d apenas superior → heavy. Mantener los códigos pedidos por el usuario (heavy=0; categorías restantes=1–4) separados del orden gráfico.
