# EPS v4: hallazgos

**Archivos**

- Cuaderno: [eps_markov_transitions_v4_EN.ipynb](eps_markov_transitions_v4_EN.ipynb), ejecutado en su lugar el
  2026-10-26 en núcleos E (30,6 min, sin errores, 72 controles en TRUE).
- Salidas agregadas: [eps_markov_outputs_v4/](eps_markov_outputs_v4/); las tablas v4 se llaman `v4_*`.
- Código: [eps_markov_v4_extra.R](eps_markov_v4_extra.R), [eps_markov_v4_sections.R](eps_markov_v4_sections.R) y
  [eps_markov_v4_narrative.md](eps_markov_v4_narrative.md).
- Constructor: `_tools/build_eps_markov_v4_notebook.py`.
- Decisiones: [decision_categorias_who_12g_2026-10-26.md](decision_categorias_who_12g_2026-10-26.md).

**Reproducibilidad.** Se hizo una sola ejecución, como en v2, sin segunda corrida de reproducción. Las cifras
coinciden con la corrida exploratoria salvo por el cambio de tolerancia de ±1 a ±3.

## Configuración

- **Cinco estados:** N0, FD, C1, C2 y C3+.
  - C3 y C4 se fusionan siempre, como en Puka 2022 y Kilian 2025. Puka además funde abstemios de por vida y
    exbebedores (LD + FD) en un solo estado de no bebedor.
  - C4 queda solo como diagnóstico de la cola.
- **Categorías y conversión:** bordes WHO sin huecos y 12 g por trago, sin sensibilidad JRT.
- **EPS 2009 solo como historia:**
  - Ventana de enlace 2009→VI: 6–8 años ± tolerancia.
  - F14 de 2009 recodificada de 1–8 a 0–7.
  - Abstención prolongada según Calvo 2020, propagada por la cadena de entrevistas.
- **Enlaces:** mismo folio y mismo sexo, con tolerancia de edad de ±3 años; los pares con sexo distinto quedan fuera.
- **Cuaderno autocontenido:**
  - El núcleo v1 aparece en 11 bloques explicados que, juntos, reproducen el archivo byte a byte.
  - Las tres celdas que `ep_load()` ejecuta desde el cuaderno de persistencia se muestran y se verifican por md5.
  - Con todos los cambios v4 apagados, el código v4 reproduce exactamente las olas v1.

## Bordes

Con 12 g, los gramos por día van en pasos de 6/7 g, así que solo 60 g se puede alcanzar exactamente. La regla WHO
mueve únicamente a los hombres con 60 g exactos (21 filas-ola en VI–VIII) de C3+ a C2. En mujeres no cambia nada.

## Historia 2009 (antes de cualquier modelo de cantidad)

**Enlaces 2009→VI aceptados:** 8.450 con la ventana estricta, 8.661 con ±1 y **8.729 con ±3**.

| Ola | Sexo | N0 sin 2009 | N0→FD | % de N0 | Abstención prolongada sin 2009 | con 2009 | Borradas por consumo en 2009 |
|---|---|---|---|---|---|---|---|
| VI | Hombres | 2.919 | 548 | 18,8 | 0 | 765 | 0 |
| VI | Mujeres | 5.236 | 432 | 8,3 | 0 | 2.132 | 0 |
| VII | Hombres | 770 | 96 | 12,5 | 0 | 160 | 0 |
| VII | Mujeres | 1.951 | 94 | 4,8 | 0 | 723 | 0 |
| VIII | Hombres | 2.421 | 90 | 3,7 | 600 | 512 | 88 |
| VIII | Mujeres | 4.062 | 117 | 2,9 | 1.744 | 1.628 | 116 |

- **Totales:** 980 N0 pasan a FD en VI (12,0 %), 190 en VII y 207 en VIII. Hay 2.897 candidatos nuevos a abstención
  prolongada en VI y 883 en VII.
- **Pares:** los pares completos y sus destinos son idénticos con y sin 2009, y no hay violaciones del mapa de
  transiciones.
- **Orígenes:** FD pasa de 0 a 372 en VI→VII y de 421 a 542 en VII→VIII. Los orígenes C1, C2 y C3+ no cambian.

**Matrices observadas, con el IPW reajustado.**

| Intervalo | Origen | Destino | Sin 2009 | Con 2009 | Cambio |
|---|---|---|---|---|---|
| VI→VII | N0 | NC | 0,733 | 0,764 | +0,031 |
| VI→VII | N0 | C1 | 0,247 | 0,217 | −0,030 |
| VI→VII | FD | NC | — | 0,571 | nuevo |
| VI→VII | FD | C1 | — | 0,406 | nuevo |
| VI→VII | FD | C3+ | — | 0,016 | nuevo |
| VII→VIII | N0 | NC | 0,853 | 0,858 | +0,006 |
| VII→VIII | FD | NC | 0,659 | 0,685 | +0,025 |
| VII→VIII | FD | C1 | 0,334 | 0,310 | −0,025 |

- **Filas de bebedores (C1, C2, C3+):** cambian a lo más 0,001 con el IPW reajustado y nada con el IPW fijo.
- **Lectura:** el 12 % de los N0 de VI había bebido seis o siete años antes. Al reclasificarlos, N0 queda más estable y
  aparece una fila FD en VI→VII, donde el 41 % vuelve a C1.
- **Advertencias:**
  - Con 2009, FD mezcla dos antigüedades: "bebió hace unos 7 años" y "bebió hace unos 3,7 años".
  - La abstención prolongada es una aproximación, no una prueba de que la persona nunca bebió.

## Comparación distribucional (5 pliegues × 3 repeticiones; mismo modelo de participación para todos)

| Modelo | Log loss | Dif. vs lognormal [IC 95 %] | C3+ P/O total | Hombres | Mujeres | C4 P/O | E[g \| C3+] pred. / obs. | PIT de la cola: media, KS |
|---|---|---|---|---|---|---|---|---|
| Lognormal (v1) | 0,6925 | — | 0,76 | 0,75 | 0,82 | 0,74 | 78,6 / 77,1 | 0,57, 0,11 |
| Gamma (v1) | 0,6997 | +0,0067 [0,0028; 0,0106] | 0,58 | 0,63 | 0,38 | 0,25 | 74,6 / 77,1 | 0,65, 0,23 |
| Lognormal, var. sexo × edad | 0,6925 | −0,0001 [−0,0006; 0,0005] | 0,79 | 0,81 | 0,74 | 0,78 | 79,7 / 77,1 | 0,56, 0,10 |
| Lognormal + Pareto | **0,6918** | −0,0007 [−0,0017; 0,0003] | 0,87 | 0,85 | 0,94 | 1,15 | 81,3 / 77,1 | 0,54, 0,11 |
| **Hurdle + Pareto (adoptado)** | 0,6934 | +0,0007 [−0,0018; 0,0032] | **1,00** | 1,01 | 0,97 | 0,92 | 77,5 / 77,1 | 0,54, **0,08** |
| *Hurdle + Pareto ridge (sensibilidad)* | 0,6921 | −0,0005 [−0,0027; 0,0017] | 1,00 | 0,94 | 1,20 | 0,92 | 75,9 / 77,1 | 0,54, 0,08 |
| *A (referencia)* | 0,7005 | +0,0078 [0,0020; 0,0137] | 1,04 | 0,96 | 1,33 | — | — | — |

- **P/O** es la proporción predicha sobre la observada, fuera de muestra, en todos los pares.
- **E[g | C3+]** es la media de gramos de los destinos en C3+, truncada a 150 g/día.
- **Exponentes de la cola:**
  - Hurdle: hombres α = 2,25 y mujeres α = 3,14, con al menos 51 y 20 excedencias por ajuste.
  - Lognormal + Pareto: α = 1,66 y 1,80.
  - Nunca hizo falta usar el α conjunto de ambos sexos.

**Decisión según la regla prefijada.**

- Lognormal + Pareto y Hurdle + Pareto cumplen las tres condiciones. Gana Hurdle + Pareto: su peor error en una celda
  no escasa es 0,029, frente a 0,069.
- Gamma y la lognormal con varianza por sexo × edad no cumplen la condición de calibración de C3+.
- **Ojos:**
  - El P/O ≈ 1 del hurdle es casi automático, porque su logístico se ajusta directamente sobre C3+.
  - El logístico está casi separado: `edu_missing` vale −15,0 y mujer × 60–65 vale −13,6, porque las mujeres de 60–65
    tienen 0 destinos en C3+. Eso deja P(C3+) ≈ 0 para ellas, un cero estructural en la microsimulación.
  - La variante ridge evita ese cero pero sobrestima C3+ en mujeres (1,20). Queda como sensibilidad declarada.
- **Segunda opción:** Lognormal + Pareto, mejor en log loss y en la puntuación de gramos.
- **Tope de muestreo:** cualquier cola Pareto se trunca a 150 g/día.

## Matriz final agregada (Hurdle + Pareto, ambos intervalos, IC 95 % por jackknife JKn)

| Origen (n) | N0 | FD | C1 | C2 | C3+ |
|---|---|---|---|---|---|
| N0 (4.166) | 0,801 [0,780; 0,820] | 0 | 0,188 [0,170; 0,208] | 0,006 [0,004; 0,007] | 0,006 [0,004; 0,009] |
| FD (914) | 0 | 0,625 [0,577; 0,670] | 0,355 [0,309; 0,403] | 0,012 [0,009; 0,015] | 0,009 [0,003; 0,028] |
| C1 (2.845) | 0 | 0,389 [0,361; 0,417] | 0,560 [0,532; 0,587] | 0,030 [0,027; 0,033] | 0,022 [0,016; 0,029] |
| C2 (150) | 0 | 0,392 [0,303; 0,490] | 0,492 [0,407; 0,578] | 0,071 [0,051; 0,098] | 0,045 [0,022; 0,088] |
| C3+ (92) | 0 | 0,281 [0,183; 0,405] | 0,595 [0,480; 0,700] | 0,051 [0,034; 0,075] | 0,074 [0,028; 0,182] |

**Frente a v2** (lognormal, peso oficial, colapsado a cinco estados):

- C3+→C3+ pasa de 0,050 a 0,074 (+0,025).
- FD→FD pasa de 0,672 a 0,625 (−0,047), y FD→C1 de 0,318 a 0,355 (+0,037). Es efecto de 2009: los FD de VI tienen un
  consumo más antiguo.
- N0→N0 pasa de 0,781 a 0,801 (+0,020).
- El resto de las celdas cambia ≤ 0,02.

## Pendientes

- **Capa anual:** el generador continuo para las matrices de cinco estados no está en v4. Es el siguiente paso para la
  microsimulación.
- **Escala WHO:** falta verificar la escala de cuatro niveles en su fuente primaria (guía WHO 2000).
- **`expand_pif`:** pasar a WHO es solo un cambio de etiquetas (verificado: Δp_abs = Δp_form = 0).
  `revision_diseno_enpg_extension.R` ya replica la derivación de `expand_pif` (con `cur_na` y categorías WHO; ver
  [revision_diseno_enpg_extension.md](revision_diseno_enpg_extension.md)). Falta reejecutar `expand_pif`.
