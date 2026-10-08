# Hallazgos de `expand_pif3` (corrida del 2026-10-08)

Documento para ir entendiendo los resultados, en lenguaje simple. Las cifras salen de `expand_pif3.ipynb` ejecutado
completo el 2026-10-08 (kernel ark, <1 min; segunda ejecución tras las correcciones de la sección 7) sobre los artefactos nuevos de `expand_pif2` (`_20261008`) y los draws
de AAF de `expand_pif` (`_20261007`). Complementa a `hallazgos_expand_pif2_20261008.md`, que explica qué es el PIF
y cómo leerlo.

---

## 0. Qué hace este notebook

`expand_pif2` calcula los PIF celda por celda (causa × sexo × edad × año × escenario). `expand_pif3` **no recalcula
nada del motor**: toma esos resultados y los convierte en lo que iría a un artículo:

- **Pondera** los PIF por la carga observada (muertes y años de vida perdidos) para resumir por causa, sexo o año.
- **Calcula la carga evitable**: muertes y años de vida perdidos (AVP) evitables.
- Produce **figuras** (TIFF 600 dpi y PDF) en `figures_expand_pif3/` y **tablas suplementarias** (CSV) en
  `tables_expand_pif3/`.
- **Compara la OMS con la Tabla 5 (PUC)** para IHD e IS.

Hay tres formas de medir los años de vida perdidos, y nunca se suman entre sí:

| Medida | Para qué |
|---|---|
| **HMD** (tablas de vida de Chile) | la principal, nacional |
| **GBD** (tabla de referencia mundial) | comparar con otros países |
| **Edad de referencia** (convención de Ruiz-Tagle) | solo continuidad con trabajos chilenos anteriores |

## 1. Qué fuentes usa (decisiones vigentes)

- **IS (ACV isquémico): Tabla 5 (PUC) como fuente principal.** El notebook reemplaza juntos el punto, los límites y
  los draws de IS. La OMS queda como comparación.
- **IHD y todas las demás causas: OMS/Adam.**
- **Estómago (C16) y páncreas (C25) fuera del análisis principal** (decisión Q10: no son causales según IARC y Shield
  2025). Se reportan aparte como complemento. El análisis principal queda con **21 causas**.

## 2. Carga evitable en 2024 (volumen −30 %)

| Alcance | Muertes evitables | AVP evitables (HMD) |
|---|---|---|
| Principal (21 causas, sin estómago ni páncreas) | **546** | **16.905** |
| Complemento (con estómago y páncreas) | 557 | 17.216 |

Estómago y páncreas aportan poco (11 muertes). La cifra de 557 coincide con la de `expand_pif2`, que las incluía.

## 3. Tasas de AVP evitables (por 100.000 personas-año, 2012-2024 agrupado)

| Escenario | Hombres | Mujeres |
|---|---|---|
| Volumen −10 % | 107 | 15 |
| Volumen −30 % | 264 | 42 |
| HED −50 %, sin cambio de consumo (λ = 0) | 362 | 53 |
| HED −50 %, cambio completo (λ = 1) | 385 | 57 |
| Combinado v−30 % / HED −50 % (λ = 0) | 404 | 60 |

- **Los hombres concentran 6-7 veces más carga evitable** que las mujeres, en todos los escenarios.
- **Las reglas λ cambian poco** (362 → 374 → 385 en hombres con HED −50 %).
- **Misma trampa que en `expand_pif2`:** los escenarios de HED y combinados cubren solo **5 causas** (IHD, IS y tres
  tipos de lesiones); los de volumen, 20-21. Por eso no se pueden comparar directamente con los de volumen ni sumar
  sin cuidado.
- Los intervalos de estas tablas son **conjuntos**: se calculan sumando draw a draw las simulaciones sincronizadas,
  no sumando los límites de cada celda. Por eso son más angostos y correctos.

## 4. Muertes atribuibles al alcohol (mediana anual 2012-2024, Tabla S2)

- **Lesiones** dominan en hombres jóvenes: ~376 muertes al año en 15-29 y ~433 en 30-44.
- **Cáncer** y **cardiovascular** pesan sobre todo desde los 45 años (cáncer en hombres 45-59: ~182 al año).
- Las causas **100 % atribuibles** se muestran como grupo aparte (hombres 45-59: ~95 al año). No tienen PIF.

## 5. OMS vs Tabla 5 (PUC): resuelve la "tabla de ceros" de `expand_pif2`

Esta es la comparación que la tabla de ceros de `expand_pif2` no mostraba (allí solo se veían filas `baseline`).
Aquí se excluye el escenario sin cambio:

| Causa | Sexo | PIF medio OMS | PIF medio Tabla 5 | Razón mediana Tabla 5 / OMS |
|---|---|---|---|---|
| IHD | Hombres | 0,013 | 0,054 | **3,9** |
| IHD | Mujeres | 0,009 | 0,025 | **2,5** |
| IS | Hombres | 0,021 | 0,021 | 1,01 |
| IS | Mujeres | 0,029 | 0,028 | 0,98 |

- **IS:** las dos fuentes dan prácticamente lo mismo. Usar la Tabla 5 como principal casi no cambia nada.
- **IHD:** la Tabla 5 da PIF de 2,5 a 4 veces mayores. Para hombres con volumen −10 %, los AVP evitables de IHD
  en 2024 son 234 con la OMS y **3.007** con la Tabla 5 (de 56.400 AVP observados). La diferencia viene de la curva de la Tabla 5 para
  hombres: a 150 g/día da RR 16,6 frente a 1,8 de la OMS, y depende de un coeficiente redondeado en el PDF. Por eso
  la **OMS es la fuente principal para IHD**.
- **En HED las dos fuentes coinciden** (IHD hombres 2024, HED −50 %, λ = 0: 536 vs 520 AVP). La diferencia aparece solo
  cuando la política mueve gramos (volumen, o HED con λ > 0).
- **No hay celdas con signo distinto** entre fuentes (0 de 2.464).
- **IHD mujeres con la Tabla 5 tiene intervalos enormes:** en 237 de 588 celdas el límite superior pasa del 90 %. El
  punto es pequeño (mediana 0,018), pero la curva de la Tabla 5 es muy inestable a consumo alto. Esos intervalos no
  deben interpretarse sin revisar el factor `Fact = 1/20`, cuyo uso no está documentado en la fuente.

## 6. Validaciones

- **Artefactos:** 11/11. Claves únicas, intervalos ordenados, sin celdas con el punto fuera de su intervalo, PIF de
  línea base = 0, y lesiones idénticas a la grilla principal (diferencia máxima 2,8×10⁻¹⁶).
- **Monotonía:** 1.036 escaleras de volumen elegibles pasan. 224 quedan como diagnóstico porque su curva no es
  monótona (diabetes y pancreatitis en mujeres, IHD, IS): ahí no se exige monotonía.
- **Tabla 5:** 10/10. Mismas celdas, escenarios, años y `n_sim` que la grilla principal.
- **Reconstrucción de muertes y AVP:** 117.918 muertes concilian exactamente (residuo 0).

## 7. Correcciones aplicadas el 2026-10-08 (con tu permiso)

1. **Figura 5 con las tres reglas.** "Half shift" (λ = 0,5) se borraba porque las categorías del gráfico solo
   incluían "No shift" y "Complete shift". Las filas sin categoría quedaban como `NA`; por eso aparecía un `NA` en
   la leyenda y ggplot borraba 18 filas. Ahora las tres reglas aparecen, separadas en el eje x (−1,1 / 0 / +1,1)
   para que no se superpongan.
2. **Textos al día con las salidas** (notas y leyendas que contradecían los resultados actuales):
   - **Comparación OMS vs Tabla 5:** decía "~59 % más alto", "brecha máxima 3,7 pp" y que había desacuerdos de
     signo. Ahora dice: razón mediana 3,9 (hombres) y 2,5 (mujeres), brecha máxima 10,1 pp y **0** desacuerdos de
     signo. Se agregó el contraste con la corrida de julio (1,6 / 1,3 y 73 desacuerdos).
   - **"Reversión" en IHD hombres:** el texto decía que la OMS mostraba una reversión (bajar el volumen subiría la
     carga de IHD) concentrada en hombres. Ya no ocurre; ahora el texto lo explica por la corrección V1.
   - **Nota "16 missing rows":** decía que había celdas con el punto bajo el límite inferior. Hoy no hay ninguna.
   - **Tope del gráfico:** decía "~5 %"; hoy es automático (14,2 %) y hay 15 intervalos que lo superan.
   - **Figura S1:** decía 16 escenarios; son 22.
   - **Figuras 1 y 3:** decían 23 causas; el alcance principal tiene 21.
   - **Leyenda de la Figura 5:** ahora describe las tres reglas.
   - **Nota de métodos:** ahora dice que las tablas S1-S4 usan intervalos conjuntos (draws sincronizados) y que las
     Figuras 1, 2 y 5 muestran envolventes ponderadas de los límites por celda.
   - **Erratas de tus anotaciones:** "Improtant", "cannonical", "diveregence", "coeeficients", "shif", "72 0 keys".
3. **Avisos de `tidyselect`:** 8 usos de `.data$` dentro de `select()` (celdas 11 y 46). La nueva ejecución no
   tiene ninguna advertencia.
4. **Gráficos legibles dentro del notebook.** Las vistas previas usaban letra 20-23 y etiquetas de tamaño 12
   sobre una imagen que ark dibuja a 800 × 600 px, sin importar `fig-width`/`fig-height`. Por eso se cortaban las
   franjas laterales ("Road Injuries"…) y los porcentajes de la Figura 3 se encimaban. Ahora hay un solo ajuste,
   `pif3_preview_base_size <- 14` (celda 27), y las etiquetas de la vista previa usan tamaño 4. **Los TIFF y PDF
   exportados no cambian:** se guardan con `pif3_save_plot()` desde el gráfico base, con su propio tamaño de letra.

## 8. ¿Por qué 21 causas?

Sí: son las 23 causas con curva de riesgo menos **cáncer de estómago (C16)** y **cáncer de páncreas (C25)**. La
decisión Q10 (2026-10-07) los saca del análisis principal porque IARC y Shield 2025 (tabla S6) no los consideran
causados por el alcohol. No se borran: se reportan aparte como complemento (Figura 3 y Tabla S3).

## 9. Comparación con la corrida anterior (2026-07-24)

La corrida anterior de `expand_pif3` usaba los resultados de `expand_pif2` del 23 de julio.

| Indicador | 2026-07-24 | 2026-10-08 | Cambio |
|---|---|---|---|
| Escenarios | 16 | 22 | + λ = 0,5 (`_mid`) |
| Celdas con PIF calculado | 8.400 | 10.080 | por los escenarios nuevos |
| Celdas con PIF negativo | 226 | 50 | ahora solo diabetes en mujeres |
| Tasa AVP evitable, hombres, volumen −10 % | 52,0 | 106,6 | ×2,0 |
| Tasa AVP evitable, hombres, volumen −30 % | 133,4 | 263,7 | ×2,0 |
| Tasa AVP evitable, mujeres, volumen −30 % | 17,9 | 41,9 | ×2,3 |
| Tasa AVP evitable, hombres, HED −50 % (λ = 0) | 348,7 | 361,8 | +4 % |
| Tasa AVP evitable, hombres, HED −50 % (λ = 1) | 359,8 | 385,3 | +7 % |
| Tasa AVP evitable, hombres, combinado 20/50 (λ = 0) | 361,7 | 391,1 | +8 % |
| IHD: razón Tabla 5 / OMS, hombres | 1,59 | 3,92 | |
| IHD: razón Tabla 5 / OMS, mujeres | 1,27 | 2,50 | |
| IS: razón Tabla 5 / OMS | ~1,03 | ~1,00 | sin cambio |
| Celdas con signo distinto entre OMS y Tabla 5 | 73 | 0 | |

(Tasas por 100.000 personas-año, 2012-2024 agrupado.)

**Por qué cambió:**

- **Lo principal es la corrección V1 del 2026-10-06** en `expand_pif`. Antes, el consumo medio **de los
  bebedores** se ajustaba a 0,8 × el consumo per cápita de la OMS (APC). Lo correcto es que **el promedio de toda
  la población**, contando a abstemios y exbebedores como 0 g, sea igual a 0,8 × APC. Con la corrección, los
  bebedores quedan con más gramos: las muertes atribuibles subieron 13,4 % y la AAF de cirrosis en hombres pasó de
  0,59 a 0,71. Por eso **los PIF de volumen casi se duplican**: más gramos significa más riesgo que se puede evitar
  al bajarlos.
- **Los escenarios de HED casi no cambian** (+4-8 %). Su efecto viene sobre todo del riesgo fijo del atracón, que
  no depende de los gramos (ver `hallazgos_expand_pif2_20261008.md`, sección 3).
- **La serie de APC** pasó a la serie oficial de la OMS (GHO): antes se usaba una serie antigua parecida a la del
  Banco Mundial, con un valor sin fuente.
- **IHD con la Tabla 5:** con más gramos, la curva de la Tabla 5 (que sube muy rápido a consumo alto) se separa más
  de la de la OMS. Por eso la razón sube de 1,6 a 3,9. Al mismo tiempo, probablemente porque hay menos personas en la
  zona "protectora" de la curva J (interpretación mía, no verificada celda a celda), desaparecen las celdas con signo distinto y casi todos los PIF negativos.
- **Otros cambios menores:** datos DEIS más recientes (versión del 06-10-2026), edades 15-65 inclusive, factor de
  diseño 2020 tomado de 2018 y prevalencias ponderadas.

**Lectura:** las cifras de julio subestimaban el efecto de las políticas de volumen aproximadamente a la mitad.
Cualquier número de julio que se haya usado en presentaciones o borradores (escenarios de volumen) hay que
actualizarlo.
