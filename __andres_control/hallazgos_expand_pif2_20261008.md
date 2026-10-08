# Hallazgos de `expand_pif2` (corrida del 2026-10-08)

Documento para ir entendiendo los resultados, en lenguaje simple. Las cifras salen del notebook
`expand_pif2.ipynb` ejecutado completo el 2026-10-08 (kernel ark, `n_sim` = 10.000, olas ENPG 2012-2024,
edades 15-65) y de sus artefactos `pif2_*_20261008.rds`. Salvo que se diga otra cosa, las muertes son del
**año 2024** y los intervalos son percentiles de Monte Carlo al 95 %.

---

## 0. Qué hace este notebook, en una frase

Toma lo que ya calculó `expand_pif` (cuánto se bebe y cuánto riesgo da el alcohol para cada causa) y pregunta:
**si una política bajara el consumo, ¿qué fracción de las muertes se evitaría?** Esa fracción es el **PIF**.

Prueba tres tipos de política:

| Tipo | Qué cambia | Ejemplo |
|---|---|---|
| **Volumen** | baja el consumo promedio de todos los bebedores | −10 %, −20 %, −30 % |
| **HED** (atracón) | baja la proporción de bebedores que se emborrachan | −10 %, −25 %, −50 % |
| **Combinado** | las dos cosas a la vez | volumen −20 % y HED −50 % |

## 1. Cómo leer los números

- **PIF = fracción de TODAS las muertes de esa causa** que se evitaría. No es una fracción de las muertes
  atribuibles al alcohol.
- **Muertes evitadas = muertes totales × PIF.** Ejemplo: 1.000 muertes, PIF 0,06 → 60 evitadas.
- Multiplicar las muertes *atribuibles* por el PIF es un error común: subestima. En esta corrida, la convención
  antigua da **2,1 veces menos** en los escenarios de volumen y **4,5 veces menos** en los de HED.

## 2. Cuántas muertes se evitarían (2024)

| Escenario | Muertes evitadas (IC 95 %) | Causas que alcanza |
|---|---|---|
| Volumen −10 % | 222 (112–381) | 23 causas (17.644 muertes) |
| Volumen −20 % | 405 (206–682) | 23 causas |
| Volumen −30 % | 557 (284–927) | 23 causas |
| HED −10 % | 107 (36–187) | 5 causas con componente HED (8.727 muertes) |
| HED −25 % | 267 (90–468) | 5 causas |
| HED −50 % | 535 (180–936) | 5 causas |
| Combinado v−20 % / HED −50 % | 599 (235–1.022) | 5 causas |
| Combinado v−30 % / HED −50 % | 625 (256–1.058) | 5 causas |

**Ojo con los combinados (trampa de lectura).** Solo se calculan para las causas que tienen un riesgo propio del
atracón: cardiopatía isquémica (IHD), accidente cerebrovascular isquémico (IS) y lesiones. Para el resto
(cánceres, cirrosis, pancreatitis, etc.) el escenario combinado queda vacío, aunque su parte de volumen sí
tendría efecto. Por eso **"Combinado v−30 % / HED −50 %" (625) no es el efecto total de esa política**.
Sumándole el efecto del volumen −30 % en cáncer (65), "otras causas" (333) y neuropsiquiátricas (16), el total
sería **al menos ~1.040 muertes evitadas**. Esa suma es un cálculo mío y le falta todavía la parte de volumen de
la cardiopatía hipertensiva y la hemorragia cerebral, que la tabla no separa.

**La incertidumbre es amplia.** HED −50 % puede evitar entre 180 y 936 muertes en 2024. Los intervalos de HED son
más anchos que los de volumen porque la prevalencia de atracón se estima con menos precisión.

## 3. Lesiones: el atracón manda

| Lesiones, 2024 | Muertes evitadas |
|---|---|
| Volumen −30 % | 73 |
| HED −50 % | 511 |
| Combinado v−30 % / HED −50 % | 568 |

Bajar el promedio casi no mueve las lesiones; bajar los atracones sí. La razón está en la curva de riesgo: quien
se emborracha tiene un riesgo fijo extra (RR ≈ 2,62 en tránsito y 1,77-2,02 en otras lesiones) **aunque su
consumo promedio sea casi cero**. Un impuesto que baje el promedio sin cambiar el patrón de atracón tendría poco
efecto en lesiones. Las dos políticas no se sustituyen.

## 4. Dónde está el efecto del volumen

Volumen −30 %, 2024, por grupo de causas:

| Grupo | Muertes evitadas | Muertes atribuibles al alcohol |
|---|---|---|
| Otras causas (cirrosis, pancreatitis, diabetes, TBC, VIH, infecciones respiratorias) | 333 | 1.017 |
| Lesiones | 73 | 1.151 |
| Cardiovascular | 70 | 525 |
| Cáncer | 65 | 699 |
| Neuropsiquiátricas (epilepsia) | 16 | 40 |

"Otras causas" concentra el 60 % del efecto del volumen: son causas cuyo riesgo sube mucho con los gramos.

## 5. ¿Qué pasa con quien deja el atracón? (reglas λ)

Cuando alguien deja de emborracharse, ¿sigue bebiendo lo mismo? El notebook reporta tres supuestos:

| Regla | λ | Supuesto | HED −50 %, 2024 |
|---|---|---|---|
| Conservadora | 0 | deja el atracón pero bebe los mismos gramos | 535 |
| Punto medio | 0,5 | mitad y mitad | 558 |
| Ruiz-Tagle (JRT) | 1 | pasa a beber como un bebedor promedio sin atracón | 581 |

En muertes, la diferencia es pequeña (±8 %). Pero con λ > 0 **la política de HED también baja los gramos**:
HED −50 % con λ = 1 implica una caída del consumo medio de **26 %**, que hay que declarar. La columna correcta
para reportarlo es `implied_vol_change_pct`, no `volume_reduction_pct`.

## 6. PIF negativos: diabetes en mujeres

Hay 50 celdas con PIF negativo y **todas son diabetes en mujeres** con políticas de volumen (mínimo −0,006). La
curva de riesgo de la OMS para diabetes en mujeres es "protectora" a consumo bajo, así que bajar el consumo sube
un poco el riesgo modelado. El notebook los **conserva sin recortarlos a cero**, que es lo correcto. Conviene
mencionarlo como limitación de la curva, no como hallazgo causal.

## 7. OMS vs Tabla 5 (PUC) para cardiopatía isquémica e ACV isquémico

PIF medio sobre los cuatro tramos de edad, 2024:

| Causa | Sexo | Escenario | OMS | Tabla 5 (PUC) |
|---|---|---|---|---|
| IHD | Hombres | Volumen −20 % | 0,006 | **0,071** |
| IHD | Mujeres | Volumen −20 % | 0,008 | **0,042** |
| IHD | Hombres | HED −50 % | 0,011 | 0,010 |
| IS | Hombres | Volumen −20 % | 0,017 | 0,016 |
| IS | Mujeres | Volumen −20 % | 0,035 | 0,031 |

- **IHD:** con la Tabla 5, una política de volumen evita entre 5 y 12 veces más. Viene de la curva de la Tabla 5
  para hombres, que depende de un coeficiente (B2) que el PDF imprime redondeado y no se puede recuperar (ver
  handoff 2026-10-07). Por eso la **OMS es la fuente principal para IHD** y la Tabla 5 queda como sensibilidad.
- **IS:** las dos fuentes dan prácticamente lo mismo, así que la elección casi no cambia el resultado. La
  **Tabla 5 es la principal para IS** y se selecciona en `expand_pif3`.
- En HED las dos fuentes dan casi lo mismo.

## 8. Evolución en el tiempo

Las muertes evitadas son estables entre 2012 y 2022 y **bajan en 2024**. Por ejemplo, volumen −10 % evita 296 en
2012, 309 en 2022 y 222 en 2024 (−87 respecto de 2022).

**Por qué (revisado el 2026-10-08):**

- **El 90 % de la caída se explica porque hay menos muertes, no porque el PIF baje.** Separando el cambio 2022 →
  2024: −78 por menos muertes y −9 por un PIF algo menor.
- **Casi todo es cirrosis hepática:** −77 de esas −78. Las muertes por cirrosis (K70 + K74, 15-65 años) caen de
  1.828 en 2022 a 1.181 en 2024.
- **No es un problema del archivo DEIS de 2024.** 2023, que viene del mismo archivo que 2012-2022, ya muestra la
  caída (1.287), y 2025 la confirma (1.130):

| Año | Muertes 15-65 (todas) | Cirrosis (K70 + K74) | K70 (hepatopatía alcohólica) |
|---|---|---|---|
| 2018 | 28.736 | 1.405 | 854 |
| 2019 | 29.523 | 1.415 | 991 |
| 2021 | 38.139 | **2.059** | **1.422** |
| 2022 | 34.290 | **1.828** | **1.270** |
| 2023 | 31.476 | 1.287 | 802 |
| 2024 | 31.806 | 1.181 | 662 |
| 2025 | 31.244 | 1.130 | 627 |

- **Lectura:** 2021-2022 fueron un pico de pandemia (exceso de muertes en general y de cirrosis en particular).
  2024 vuelve a niveles algo bajo los de 2018-2019. Como la ENPG solo tiene olas pares, el notebook salta de 2022
  (pico) a 2024 (post-pico) y la caída parece brusca.
- **Lo que no está explicado:** K70 baja 37 % en un solo año (1.270 → 802, de 2022 a 2023) y queda por debajo de
  2018. Puede ser real o un cambio en la forma de codificar las causas de muerte. Vale la pena preguntarlo a DEIS o
  revisarlo con más años antes de interpretarlo.
- Las caídas de VIH (436 → 256) y tránsito (1.659 → 1.224) aportan poco a las muertes evitadas, porque su PIF de
  volumen es pequeño.

## 9. Qué tan confiable es (validaciones)

- **Pasaron:** identidad de línea base (PIF = 0 sin cambio), cobertura de las 45 tablas, reproducibilidad con
  semilla, diseño muestral aplicado una sola vez, recuperación de la covarianza, congruencia PIF/PAF, prueba
  completa de lesiones (21/21), Tabla 5 (10/10 + 5 celdas extra de congruencia).
- **Fase 7 (celda 44): 17/17.** La prueba `monotone_increasing_rr` fallaba porque mezclaba los 7 años al ordenar
  (el mismo tipo de error que tenía la escalera HED). Se corrigió el 2026-10-08 para revisar cada año por separado.
- **Reutilización:** la grilla principal y la prueba de lesiones se reutilizaron de la corrida de la mañana
  (12:28), después de verificar hashes de archivos, motor, registro, configuración y escenarios. La Tabla 5 se
  calculó completa (38 min).

## 10. Alcance y límites

- **PIF parcial:** cubre 23 causas con curva de riesgo. Las causas 100 % atribuibles (intoxicación alcohólica,
  trastornos por uso de alcohol, hepatopatía alcohólica: 145 muertes en 2024) **no están incluidas**, aunque
  también responden a las políticas. Las muertes evitadas son entonces conservadoras.
- **Edades 15-65**, como la ENPG.
- **Exbebedores:** ninguna política los toca. Por eso el PIF nunca llega a igualar la AAF.
- **Años de vida perdidos:** el notebook los calcula para las 23 causas (caché `YPLL_20261006.rds`). Este
  documento no los resume.

## 11. Próximos pasos

1. `expand_pif3`: integrar con las fuentes principales (OMS para IHD, Tabla 5 para IS).
2. Al reportar combinados, sumar la parte de volumen de las causas sin componente HED (sección 2).
