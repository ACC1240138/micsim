# Decisión: categorías de consumo WHO sin huecos y 12 g por trago (2026-10-26)

Decisión del usuario, registrada como **clave** en el
[handoff caveman](codex_handoff_adam_rr_full_override_caveman.md). Se aplicará a EPS v4 y servirá de base
para modificar `expand_pif[1-3]`.

## Decisión

1. **Categorías WHO, sin huecos.** El valor exacto del borde va a la categoría inferior:

   | Estado | Mujeres (g/día) | Hombres (g/día) |
   |---|---|---|
   | C1 | 0 < g ≤ 20 | 0 < g ≤ 40 |
   | C2 | 20 < g ≤ 40 | 40 < g ≤ 60 |
   | C3 | 40 < g ≤ 60 | 60 < g ≤ 100 |
   | C4 | g > 60 | g > 100 |

   Los intervalos son contiguos, sin los huecos de JRT (19,99–20, 39,99–40 y 59,99–60), que hoy quedan como NA.
2. **C3 y C4 se fusionan siempre en C3+** (g > 40 en mujeres, g > 60 en hombres) por escasez, como en
   Puka et al. 2022 y Kilian et al. 2025. C4 solo se usa como diagnóstico de la cola.
3. **12 g por trago.** Es la corrección de JRT tras los comentarios de los revisores del manuscrito ADD-25-1576.
4. **No hay sensibilidad con la convención JRT** (borde a la categoría superior) ni con 13 g. No se corre.

## Evidencia

**JRT publicado.** Ruiz-Tagle Maturana, Román Mella y Castillo-Carniglia (2026). *Public Health in Practice*
11:100798, doi:10.1016/j.puhip.2026.100798. Código en el repositorio público `ACC1240138/Sex-and-age-differences-…`,
commit `91402ee` (2025-01-27), el mismo que registra [jrt/README.md](../jrt/README.md).

- El texto del artículo modela el volumen como continuo: bebedores actuales con más de 0 y hasta 150 g/día. No usa
  categorías en los métodos que se pudieron leer. El PDF de `_bib/` es un pre-proof escaneado, sin texto y con los
  bordes de página recortados.
- El script de análisis `Paper mortality trends.R` (líneas 25–34) define `cvolaj` así:
  - mujeres: cat1 hasta 19,99, cat2 20–39,99, **cat3 40–60, cat4 > 60**;
  - hombres: cat3 60–100, cat4 > 100;
  - `ltabs` = `oh1 == "No"`; `fd` = último consumo hace más de 30 días o más de 1 año.

  Las categorías solo separan `ltabs`/`fd` y agrupan las tablas descriptivas. No entran a la AAF.
- El script de preparación `DATA PREPARATION ENPG.R` (líneas 635–645) escribe `ENPG_FULL.rds` con cat3 de mujeres
  hasta **100**. De ahí viene el 100 que heredaron `expand_pif` y el motor EPS.
  - Tiene un error en la línea 555: la cat4 de hombres usa `voltotMINSAL`.
  - Usa 13 g por trago (líneas 541–542). Esa versión quedó superada por la de 12 g.
- La convención de JRT es mixta y no es la de WHO:
  - los cortes bajos ponen el borde en la categoría superior (≥ 20 y ≥ 40 en mujeres; ≥ 40 y ≥ 60 en hombres);
  - el corte superior lo pone en la inferior (≤ 60 y ≤ 100);
  - deja huecos.

**ADD-25-1576** (manuscrito de JRT y colaboradores sobre lesiones y HED; `_bib/ADD-25-1576.pdf`, cifrado). El texto dice:
"One standard drink was assumed to contain 12 g of pure ethanol". También define HED como 5 tragos estándar o más en
una ocasión y pone un tope de 150 g/día. Que sea la versión posterior a los revisores lo informa el usuario; el PDF
no lo dice.

**Referencias de arquitectura.** Ambas tienen tres categorías de bebedor; su categoría superior equivale a nuestro C3+:

- Puka et al. 2022 (*Addiction*, doi:10.1111/add.16024; NESARC, msm): ≤ 20 / 21–40 / ≥ 41 en mujeres y
  ≤ 40 / 41–60 / ≥ 61 en hombres. Además fusiona abstemios de por vida y exbebedores (LD + FD) en un solo estado de no
  bebedor: según la nota de investigación, porque el reporte de abstención de por vida es inconsistente. La
  microsimulación puede separarlos después.
- Kilian et al. 2025 (*Lancet Public Health*): ≤ 20 / > 20–40 / > 40 en mujeres y ≤ 40 / > 40–60 / > 60 en hombres.
- El protocolo SIMAH (Probst et al. 2023) planeaba cuatro categorías (IV > 61 en mujeres y > 100 en hombres).

En ninguna de las fuentes leídas consta por qué se dejó la categoría IV. Fuente:
[trayectorias_persistencia.md](../research_notes/Microsimulación%20de%20alcohol%20y%20mortalidad/trayectorias_persistencia.md)
y [armonizacion_enpg_eps_2026_10_16.md](armonizacion_enpg_eps_2026_10_16.md).

**Pendiente:** verificar la escala WHO de cuatro niveles en fuente primaria (WHO, *International Guide for Monitoring
Alcohol Consumption and Related Harm*, 2000). La descarga del PDF falló, así que hoy está citada de memoria.

## Impacto medido en EPS (12 g)

- Con 12 g, los gramos por día de EPS caen en múltiplos de 6/7 (0,857 g), porque "menos de una vez por semana" se
  codifica como 0,5 días a la semana.
  - 20, 40 y 100 no se pueden alcanzar exactamente: 0 casos.
  - Solo 60 es alcanzable (70 × 6/7; por ejemplo, 5 tragos diarios): **21 filas-ola, todas de hombres** (VI 15,
    VII 4, VIII 2), de 14.043 bebedores actuales con gramos.
  - No hay observaciones dentro de los huecos de JRT.
- **Efecto de WHO frente a la convención actual:** esas 21 filas pasan de C3+ a C2. C3+ de hombres baja de 324 a 303
  filas-ola (−6,5 %). Las mujeres no cambian.
- En los modelos continuos (gamma, lognormal) ≤ y < dan la misma probabilidad. La convención solo cambia las etiquetas
  observadas y, por eso, la calibración de C3+.
- **Estado del código hoy:**
  - `eps_markov_core.R`, `tsm_markov_data.R` y `tsm_markov_models.R` ya usan 60 g como tope de C3 en mujeres
    (corrección del 2026-10-26), pero siguen con el borde a la categoría superior en los cortes bajos.
  - El cambio a WHO entra en EPS v4. Aplicarlo al motor base y a TSM queda pendiente.

## Qué implica para `expand_pif[1-3]` (aún sin modificar)

- **`expand_pif.ipynb`**
  - Celda 7, líneas 105–127: `cvolaj`/`cvolajms` con cat3 de mujeres 40–100, cat4 > 100 y los huecos. Hay que
    llevarlos a WHO sin huecos.
  - La misma celda ya usa 12 g (`voltotal = … * 12`) y 15,7 g en `voltotMS`.
  - `cvolaj` solo entra al motor como `ltabs`/`fd`, así que AAF, PIF y YPLL no deberían cambiar. Hay que comprobarlo
    después de reejecutar.
  - Reejecutarlo regenera `data_binge_sensitivity.rds` (cifrado).
- **`expand_pif2.ipynb` y `expand_pif3.ipynb`** no definen cortes. Leen `ltabs`/`fd` desde el `.rds`.
- **Copias que habría que alinear:**
  - `revision_diseno_enpg_extension.R` (líneas 231–238);
  - `patch_expand_pif_20261008.py`, que si se vuelve a ejecutar revierte la prosa a 40–100;
  - `tsm_r7_r11_comparators.R`, `recat()` (líneas 196–197);
  - la reconstrucción JRT `jrt/simulacion/Alcohol Transitions FINAL.R`, donde cat4 queda como NA: con WHO, las
    mujeres de 60–100 g pasarían a cat4 y saldrían de la reconstrucción.
- **ENPG:** con el factor anual de reescalamiento al consumo per cápita de WHO, `volajohdia` es continuo. Antes de
  cambiar hay que contar los casos exactos en los bordes en la ENPG (no se hizo).

## Decisiones posteriores del mismo día (2026-10-26)

- **Enlace en EPS: tolerancia de ±3 años en la diferencia de edad.** Se excluyen los pares con distinto sexo
  entre olas.
  - Ningún archivo EPS trae fecha de nacimiento ni fecha de entrevista; `folio_n20` identifica a la persona.
  - `edad_corregida` de VI no se usa: no está documentada y no corresponde a un desfase uniforme.
  - Pares completos VI→VII: 4.702 con la regla estricta, 4.755 con ±1, 4.773 con ±3 y 4.798 solo con folio y sexo.
  - VII→VIII queda en 3.393 con cualquier regla: lo que se pierde ahí son personas que salen del panel.
- **TSM: bordes WHO y C3+ como resultado principal.**
  - TSM no tiene ninguna observación exacta en 20, 40, 60 o 100 g/día, así que no cambia ninguna etiqueta.
  - Se dejó sin cola Pareto: con 12 g por trago solo 3 destinos superan el corte de C3+ y el logístico del hurdle
    queda separado.
  - La tolerancia de TSM quedó en ±1 en ese paso; TSM v4 la subió a ±2 (último punto).
- **`expand_pif` (verificado con datos, sin modificar):** `cvolaj`/`cvolajms` no cambian ninguna estimación puntual.
  - Los 24 casos que caen en huecos (todos de 2016) van a `cur_na` y se quedan en el denominador.
  - Con categorías WHO, `ltabs`/`fd` quedan iguales fila por fila (Δp_abs = Δp_form = 0).
  - `cvolajms` no se usa en ningún cálculo.
  - Pasar `expand_pif` a WHO es, por lo tanto, solo un cambio de etiquetas.
  - Problema aparte: `revision_diseno_enpg_extension.R` construye `cvolajms` sin la regla `cur_na` y excluye a 3.756
    bebedores actuales con volumen NA o 0. Eso cambia el tamaño efectivo de la Dirichlet entre −2 % y +17 %, es
    decir, el ancho de los intervalos, no la estimación central. **Resuelto el mismo día:** el script ahora replica
    fila por fila la derivación de `expand_pif`, con `cur_na` y categorías WHO
    ([revision_diseno_enpg_extension.md](revision_diseno_enpg_extension.md)). Falta reejecutar `expand_pif` para que
    sus IC usen los nuevos factores.
- **TSM v4:** cinco estados (C3 y C4 fusionados en C3plus en el propio motor, no solo en el resumen) y tolerancia de
  enlace de ±2 años elegida con datos, con el mismo criterio de concordancia educacional usado en EPS. El cuaderno v3
  ejecutado queda como historia.
