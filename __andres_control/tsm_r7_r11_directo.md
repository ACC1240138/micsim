# Las mismas personas, de R7 a R11

Versión Markdown de la página publicada (https://claude.ai/artifact/KZzq8pfaJU8QGWqitvsbv2; copia local `tsm_r7_r11_directo_explicado.html`). Los gráficos se omiten: sus datos están en las tablas. Tablas fuente: `tsm_r7_r11_direct_outputs/`.

Comparación directa a unos 24 meses, sin exigir entrevistas intermedias y sin encadenar ni anualizar matrices.

**En breve.** Con 902 personas seguidas 24 meses, 71 % de los no bebedores de R7 siguen sin beber en R11 (IC 62 %–80 %) y 77 % de los bebedores C1 siguen en C1 (70 %–83 %). Frente a eso, el JRT original y el rank matching predicen más estabilidad (90 % y 94 % en C1). EPS y JRT_reference predicen algo menos en C1 (68 % y 66 %) y más en no bebedores (85 %). El motor TSM coincide en C1 (72 %) y queda muy bajo en no bebedores (50 %). Son diferencias descriptivas: los modelos son puntuales y el desgaste no está corregido.

- **2.123** personas de 18–65 años en R7

- **906** vuelven a ser entrevistadas en R11 (42,7 %); es el N de 906 informado antes

- **902** analizables tras el control de vínculo (tolerancia ±1 año)

- **847** analizables con límites estrictos de EPS (sensibilidad)

## 1. Cómo se armó la cohorte

Se usó el código de datos TSM v3 sin modificarlo: personas con edad de 18 a 65 años en R7, buscadas por su identificador en R11. El vínculo exige mismo sexo y un cambio de edad compatible con 24 meses (de 1 a 3 años; ±1 año de tolerancia, la regla acordada para TSM v3, es decir de 0 a 4). Los 4 pares descartados tienen un cambio de edad fuera de ese rango. Con los límites estrictos de EPS quedan 847. Los 24 meses salen de las fechas aproximadas de campo (abril de 2023 y abril de 2025; el mes de R11 no está verificado).

| Paso | N |
|----|----|
| Personas de 18–65 años en R7 | 2.123 |
| Entrevistadas otra vez en R11 (cualquier edad) | 906 |
| Vínculo compatible, tolerancia ±1 año (regla principal) | 902 |
| Analizables: origen y destino clasificados (no hay casos sin clasificar) | 902 |
| Sensibilidad: límites estrictos de EPS (tolerancia 0), analizables | 847 |

En R7 no hay historia previa, así que el origen «NC» mezcla a quienes nunca bebieron con exbebedores: no equivale al N0 de EPS. El destino se mantiene en dos grupos, «NC» (no bebe) y consumo C1 a C4, porque separar exbebedores en R11 exigiría las entrevistas intermedias que este análisis evita.

## 2. Tamaños de muestra

**Marcadores de celda.** ∅ vacía (0), ▲ muy pequeña (1 a 9), △ pequeña (10 a 29). El resto tiene 30 o más. Las dos últimas columnas no tienen casos sin clasificar, pero se dejan visibles.

### Sexo × edad al inicio

| Sexo × edad en R7 | N inicial R7 | N observado R11 | Seguimiento | Vínculo descartado | N analizable | Origen NC | C1 | C2 | C3 | C4 | Sin clasificar origen / destino |
|----|----|----|----|----|----|----|----|----|----|----|----|
| Hombres 18-29 | 119 | 40 | 33,6 % | 0 | 40 | 8▲ | 32 | 0∅ | 0∅ | 0∅ | 0 / 0 |
| Hombres 30-44 | 241 | 94 | 39,0 % | 0 | 94 | 29△ | 64 | 0∅ | 1▲ | 0∅ | 0 / 0 |
| Hombres 45-59 | 243 | 108 | 44,4 % | 1 | 107 | 30 | 77 | 0∅ | 0∅ | 0∅ | 0 / 0 |
| Hombres 60-65 | 152 | 72 | 47,4 % | 0 | 72 | 24△ | 48 | 0∅ | 0∅ | 0∅ | 0 / 0 |
| Hombres, todas las edades | 755 | 314 | 41,6 % | 1 | 313 | 91 | 221 | 0∅ | 1▲ | 0∅ | 0 / 0 |
| Mujeres 18-29 | 142 | 50 | 35,2 % | 0 | 50 | 26△ | 23△ | 1▲ | 0∅ | 0∅ | 0 / 0 |
| Mujeres 30-44 | 442 | 173 | 39,1 % | 2 | 171 | 81 | 88 | 1▲ | 1▲ | 0∅ | 0 / 0 |
| Mujeres 45-59 | 534 | 246 | 46,1 % | 1 | 245 | 131 | 114 | 0∅ | 0∅ | 0∅ | 0 / 0 |
| Mujeres 60-65 | 250 | 123 | 49,2 % | 0 | 123 | 81 | 42 | 0∅ | 0∅ | 0∅ | 0 / 0 |
| Mujeres, todas las edades | 1.368 | 592 | 43,3 % | 3 | 589 | 319 | 267 | 2▲ | 1▲ | 0∅ | 0 / 0 |
| Total | 2.123 | 906 | 42,7 % | 4 | 902 | 410 | 488 | 2▲ | 2▲ | 0∅ | 0 / 0 |

### Educación completada al inicio

| Educación en R7 | N inicial R7 | N observado R11 | Seguimiento | Vínculo descartado | N analizable | Origen NC | C1 | C2 | C3 | C4 | Sin clasificar origen / destino |
|----|----|----|----|----|----|----|----|----|----|----|----|
| Básica o menos | 427 | 167 | 39,1 % | 0 | 167 | 96 | 70 | 1▲ | 0∅ | 0∅ | 0 / 0 |
| Media | 857 | 371 | 43,3 % | 1 | 370 | 180 | 189 | 1▲ | 0∅ | 0∅ | 0 / 0 |
| Superior | 816 | 360 | 44,1 % | 3 | 357 | 130 | 225 | 0∅ | 2▲ | 0∅ | 0 / 0 |
| Sin dato (visible) | 23 | 8 | 34,8 % | 0 | 8▲ | 4▲ | 4▲ | 0∅ | 0∅ | 0∅ | 0 / 0 |
| Total | 2.123 | 906 | 42,7 % | 4 | 902 | 410 | 488 | 2▲ | 2▲ | 0∅ | 0 / 0 |

La fila «Sin dato» corresponde a personas sin información de educación en R7 y se conserva a la vista. No se cruzó educación con sexo y edad: serían unas 24 celdas de alrededor de 37 analizables, demasiado pocas para tasas de transición.

### Seguimiento según el estado de consumo en R7

| Origen en R7   | N inicial | N observado en R11 | Seguimiento | N analizable |
|----------------|-----------|--------------------|-------------|--------------|
| NC             | 999       | 411                | 41,1 %      | 410          |
| C1             | 1.118     | 491                | 43,9 %      | 488          |
| C2             | 4▲        | 2▲                 | 50,0 %      | 2▲           |
| C3             | 2▲        | 2▲                 | 100,0 %     | 2▲           |
| C4             | 0∅        | 0∅                 | —           | 0∅           |
| Sin clasificar | 0∅        | 0∅                 | —           | 0∅           |

El seguimiento es similar entre no bebedores (41,1 %) y bebedores C1 (43,9 %). Es mucho menor en edades jóvenes (34 % en hombres de 18–29) que en mayores (47 % en hombres de 60–65), así que la pérdida no es aleatoria. El seguimiento total (42,7 %) deja la comparación expuesta a sesgo por desgaste que aquí no se corrige.

| Educación | Origen NC: inicial → observado | Origen C1: inicial → observado |
|----|----|----|
| Básica o menos | 262 → 96 (36,6 %) | 164 → 70 (42,7 %) |
| Media | 439 → 181 (41,2 %) | 417 → 189 (45,3 %) |
| Superior | 289 → 130 (45,0 %) | 523 → 228 (43,6 %) |
| Sin dato (visible) | 9 → 4 (44,4 %) | 14 → 4 (28,6 %) |

## 3. Transiciones observadas a dos años

Cada persona aporta un solo par R7 → R11. La estimación ponderada usa el peso transversal de R7 y no corrige desgaste; el intervalo es un percentil de bootstrap de personas. Se muestra también la proporción cruda (conteo/N). **Regla de confiabilidad**: con menos de 10 personas de origen solo se muestra el conteo; entre 10 y 29, el conteo y una advertencia; entre 30 y 99 la estimación se marca como exploratoria; desde 100 se presenta sin marca.

### Global

| Origen | Destino NC | Destino C1 | Destino C2 o más |
|----|----|----|----|
| NC | 71 % (62 %–80 %) 322/410 | 29 % (20 %–38 %) 88/410 | 0 % (0 %–0 %) 0/410 |
| C1 | 21 % (15 %–28 %) 123/488 | 77 % (70 %–83 %) 361/488 | 2 % (0 %–6 %) 4/488 |
| C2 o más | 0/4 solo conteo | 3/4 solo conteo | 1/4 solo conteo |

Con límites estrictos de EPS el resultado casi no cambia: 70 % permanecen NC (N = 383) y 78 % permanecen C1 (N = 460). El origen «C2 o más» tiene 4 personas: solo conteos.

### Por sexo

| Sexo | NC → sigue NC | C1 → sigue C1 | C1 → deja de beber (NC) |
|----|----|----|----|
| Hombres | 63 % (44 %–81 %) 62/91 exploratoria | 84 % (74 %–92 %) 184/221 | 16 % (8 %–26 %) 36/221 |
| Mujeres | 76 % (67 %–84 %) 260/319 | 68 % (57 %–77 %) 177/267 | 28 % (20 %–37 %) 87/267 |

### Por sexo × edad

| Sexo × edad | NC → sigue NC | C1 → sigue C1 | C1 → deja de beber (NC) |
|----|----|----|----|
| Hombres 18-29 | 7/8 solo conteo | 93 % (79 %–99 %) 28/32 exploratoria | 7 % (1 %–21 %) 4/32 exploratoria |
| Hombres 30-44 | 19/29 inestable, no interpretar (60 %) | 75 % (54 %–91 %) 53/64 exploratoria | 25 % (9 %–46 %) 10/64 exploratoria |
| Hombres 45-59 | 54 % (31 %–78 %) 19/30 exploratoria | 86 % (74 %–96 %) 67/77 exploratoria | 14 % (4 %–26 %) 10/77 exploratoria |
| Hombres 60-65 | 17/24 inestable, no interpretar (72 %) | 91 % (82 %–96 %) 36/48 exploratoria | 9 % (4 %–18 %) 12/48 exploratoria |
| Mujeres 18-29 | 13/26 inestable, no interpretar (35 %) | 16/23 inestable, no interpretar (74 %) | 6/23 inestable, no interpretar (15 %) |
| Mujeres 30-44 | 83 % (71 %–93 %) 69/81 exploratoria | 71 % (52 %–86 %) 68/88 exploratoria | 22 % (10 %–37 %) 18/88 exploratoria |
| Mujeres 45-59 | 88 % (80 %–94 %) 110/131 | 63 % (51 %–74 %) 66/114 | 37 % (26 %–49 %) 48/114 |
| Mujeres 60-65 | 77 % (60 %–93 %) 68/81 exploratoria | 60 % (35 %–83 %) 27/42 exploratoria | 40 % (17 %–65 %) 15/42 exploratoria |

### Por educación (margen)

| Educación en R7 | NC → sigue NC | C1 → sigue C1 | C1 → deja de beber (NC) |
|----|----|----|----|
| Básica o menos | 86 % (74 %–95 %) 86/96 exploratoria | 62 % (46 %–79 %) 42/70 exploratoria | 37 % (21 %–54 %) 27/70 exploratoria |
| Media | 70 % (57 %–81 %) 136/180 | 82 % (74 %–89 %) 136/189 | 17 % (11 %–26 %) 52/189 |
| Superior | 67 % (49 %–84 %) 98/130 | 76 % (65 %–86 %) 181/225 | 20 % (12 %–31 %) 42/225 |
| Sin dato (visible) | 2/4 solo conteo | 2/4 solo conteo | 2/4 solo conteo |

**Educación: qué sí y qué no.** Como margen, con origen NC o C1, hay entre 70 y 225 personas por celda y los intervalos son anchos. No hay datos para sexo × edad × educación. Para compartir información sin presentar estimaciones inestables, se propone usar sexo × edad (o solo edad por sexo) como base y estimar el efecto de la educación con una regresión logística aditiva o con contracción hacia esa base, y publicar solo las estimaciones con intervalo. Mientras tanto, las celdas pequeñas se comparten como conteos.

## 4. Qué es cada comparador

Los cinco comparadores pedidos más uno adicional. No son sinónimos. **Rank matching** es un modo de construir pares (un pseudo-panel) a partir de dos encuestas transversales. **JRT original** es un motor completo: rank matching sobre ENPG, luego un modelo ordinal y luego un escalamiento anual. **JRT_reference** solo toma la fórmula de JRT y la ajusta a pares reales del panel EPS, sin rank matching ni escalamiento.

| Comparador | Datos y plazo original | Especificación | Pesos | Calibración o escalamiento | Conversión a dos años | Incertidumbre aquí |
|----|----|----|----|----|----|----|
| **1. Observado TSM R7 → R11** | Las mismas 902 personas, 24 meses. | Proporciones de destino por origen. | Peso transversal R7 (Fact_Exp) sin corrección por desgaste; también sin ponderar. | Ninguna. | Ninguna: plazo nativo. | IC 95 % por bootstrap de personas (solo muestral). |
| **2. Motor EPS** (A y Lognormal) | Panel EPS real, VI → VII (3,7 años) y VII → VIII (4,0 años), 18–65 años. Seis estados: N0, FD, C1–C4. | A: matrices por celda sexo × edad con contracción. Lognormal: participación más cantidad lognormal, con origen, sexo × edad, periodo, gramos previos y educación. | Longitudinal oficial o transversal VII, más IPW. | Generador continuo de seis estados ajustado a las matrices de intervalo; la matriz anual publicada sale de ahí. | Generador reajustado por estrato con el mismo método y masas ponderadas; matriz a dos años = exp(2Q). Verificado contra la anual publicada (ver abajo). | Puntual: las réplicas JKn existen en el notebook pero no se exportaron. |
| **3. JRT original** | ENPG transversal. Original: pares bienales 2008 → 2010 → … → 2016. Aquí reconstruido con 2012 → 2014 → 2016 (33.789 pseudo-pares). | Pseudo-panel por rank matching de g/día dentro de sexo × tramo de edad; MASS::polr ordinal de 4 estados (no bebe = abstinente de vida + exbebedor; Cat1–Cat3; cat4 excluida): destino ~ origen × edad + origen × sexo + sexo × edad. | Ninguno: ni el emparejamiento ni el polr usan pesos. | En la simulación cada año eleva las probabilidades a α = 0,5 y renormaliza. Los offsets de calibración (theta) de `Alcohol Transitions_CALIB.R` no se aplican y ese script no se puede leer (error de sintaxis). | El polr se entrena con pares t → t + 2, así que su predicción ya es a dos años: sin conversión. Como diagnóstico se muestran también dos pasos atemperados, que es lo que hace la simulación en dos años. | Puntual; ajuste reconstruido, no el original. |
| **4. JRT_reference** (notebook EPS) | Los mismos pares reales EPS que el motor EPS, 3,7 y 4,0 años. | Modelo ordinal único con la fórmula literal de JRT: origen × edad + origen × sexo + sexo × edad + periodo. Seis orígenes EPS, sin educación. | Los del motor EPS. | Ninguno. El notebook EPS lo usa como referencia de validación cruzada y no lo anualiza. | Generador por estrato y exp(2Q), igual que el motor EPS. Esta conversión se deriva aquí; no existía. | Puntual. |
| **5. Motor TSM** (A y Lognormal) | Panel TSM R7 a R11, cuatro intervalos de 4 a 8 meses. | El motor EPS portado a TSM. | Fact_Exp de origen más IPW de vínculo. | Generador anual publicado. | Generador por estrato y exp(2Q). | Puntual: no se exportaron réplicas bootstrap de las matrices. |
| **Adicional: acoplamiento por rangos** | Márgenes R7 y R11 de las mismas 902 personas, 24 meses. | Acoplamiento comonótono de categorías ordenadas dentro de sexo × edad que preserva ambos márgenes (la forma por categorías del rank matching de JRT). | Peso R7 o sin ponderar. | Ninguno. | Ninguna: plazo nativo. | No aplica. |

**Qué mide el acoplamiento por rangos.** Usa exactamente los márgenes observados, pero ignora quién es quién: empareja a la persona que más bebía en R7 con la que más bebe en R11. Por eso entrega la persistencia máxima compatible con esos márgenes. La diferencia con lo observado mide cuánto sesgo introduce construir pares por rangos. EPS ya lo había medido en su propio plazo: con 3,7 y 4,0 años, rank matching daba 94 % y 77 % de permanencia C1, frente a 58 % y 52 % en el panel real. Esos valores a cuatro años no se comparan con los de dos años.

**Ningún par de comparadores es idéntico.** JRT original con volumen anclado a la OMS y con volumen crudo de 12 g por trago dan casi lo mismo en NC → NC (97,4 % y 97,4 %), pero difieren en C1 (89,9 % y 92,2 %). EPS A y JRT_reference quedan cerca a nivel global, pero no coinciden por estrato. El JRT_reference ajustado dentro del notebook TSM es otro modelo y no se usa aquí.

### Reconstrucción del JRT original: qué falta y qué se cambió

- **Falta el ajuste original.** El script carga `Alcohol Transitions FINAL.RData`, que no existe en el repositorio ni en la carpeta de origen. Sin ese archivo no hay coeficientes ni población base originales.
- **Faltan dos de cuatro pares de entrenamiento.** ENPG 2008 y 2010 están en el bundle cifrado, pero no armonizados al formato JRT. La reconstrucción usa 2012–2016, con las funciones originales del script sin modificar, evaluadas aparte.
- **Cambio necesario.** En el archivo armonizado actual, abstinentes y exbebedores tienen volumen NA, y el preprocesamiento JRT descarta los NA: quedaría un modelo sin no bebedores. Se les asignó 0 g, como supone la codificación de estados de JRT.
- **Volumen.** El volumen ENPG actual está anclado al consumo per cápita de la OMS (factor de 4,3 a 5,0 en 2012–2016). Con ese volumen, la Cat1 de ENPG no equivale a C1 de TSM, que usa 12 g por trago sin anclaje. Por eso se muestra también una variante con volumen crudo. Además, «no bebe» en ENPG es no haber bebido en los últimos 30 días, mientras que TSM pregunta con qué frecuencia toma, sin fijar período (e3a1). NC → NC y C1 → NC son comparables en categoría, pero no en ventana de referencia; parte de la alta permanencia NC de JRT puede venir de esa diferencia.
- **Edad.** El tramo 1 de JRT es 15–29 años, frente a 18–29 en TSM. La simulación original además sube el tramo de edad un nivel por año (`run_simulation_alcohol`); aquí no se usa ese paso.
- **Verificación.** El emparejamiento rápido usado aquí reproduce exactamente el de `make_pseudopanel_pair` en un estrato de prueba. El polr convergió en ambas variantes.

**Por qué dos pasos con α = 0,5 no son una anualización.** Elevar probabilidades a 0,5 y renormalizar no es la raíz de una matriz de transición: una matriz simétrica 0,90/0,10 pasa a 0,75/0,25 por paso y a 0,625 en dos pasos, no 0,90. La auditoría de `microsim_base_ACC_2012_2024.ipynb` ya lo había señalado. Se muestra solo como diagnóstico de lo que la simulación aplica.

## 5. «No consumo» armonizado y verificación de la proyección

TSM observa no consumo (NC) sin separar abstinentes de vida (N0) y exbebedores (FD) de forma comparable. En los motores entrenados con estados EPS, la probabilidad de seguir sin beber desde un origen no bebedor suma los **dos** destinos N0 y FD, porque pasar de uno a otro sigue siendo no consumir. La proyección conserva los seis estados y solo agrega N0 + FD al leer el resultado. El cálculo anterior de esta página ya sumaba ambos destinos: se revisó y era correcto.

**Mezcla de orígenes.** El NC de R7 no se puede separar en N0 y FD: es la primera ronda y no hay historia. Para EPS y JRT_reference se muestran dos límites: todos N0 y todos FD. Además se muestra un escenario con la proporción de FD entre los no bebedores EPS del mismo sexo y edad (conteos sin ponderar, ambos periodos sumados). Este rango es incertidumbre de composición, separada del intervalo muestral de lo observado. El motor TSM usa su fila N0, porque los no bebedores de R7 son N0 por construcción. JRT original ya une ambos grupos en un solo estado.

| Estrato       | N0 en EPS | FD en EPS | FD entre no bebedores (escenario) |
|---------------|-----------|-----------|-----------------------------------|
| Hombres 18-29 | 450       | 41        | 8,4 %                             |
| Hombres 30-44 | 187       | 38        | 16,9 %                            |
| Hombres 45-59 | 454       | 63        | 12,2 %                            |
| Hombres 60-65 | 197       | 20        | 9,2 %                             |
| Mujeres 18-29 | 1.015     | 62        | 5,8 %                             |
| Mujeres 30-44 | 620       | 51        | 7,6 %                             |
| Mujeres 45-59 | 1.215     | 101       | 7,7 %                             |
| Mujeres 60-65 | 484       | 36        | 6,9 %                             |

**Verificación de la proyección.** Antes de mirar los estratos se fijó una condición: el generador reajustado a las matrices agregadas debía reproducir la matriz anual publicada con diferencia menor a 0,02 en cada celda. Con conteos como masas no pasó en tres motores, porque los conteos cambian la composición del promedio. Con las masas ponderadas que usa la publicación pasa en todos, y las celdas a dos años que se informan difieren en 0,002 o menos. Dentro de un estrato esa composición no interviene.

| Motor | Masas | Diferencia máxima, matriz anual | Diferencia máxima, celdas informadas a 2 años | Condición |
|----|----|----|----|----|
| EPS A | conteos | 0,140 | 0,0113 | no pasa |
| EPS A | ponderadas (como en la publicación) | 0,014 | 0,0017 | pasa |
| EPS Lognormal | conteos | 0,030 | 0,0211 | no pasa |
| EPS Lognormal | ponderadas (como en la publicación) | 0,014 | 0,0003 | pasa |
| TSM A | conteos | 0,010 | 0,0064 | pasa |
| TSM A | ponderadas (como en la publicación) | 0,006 | 0,0018 | pasa |
| TSM Lognormal | conteos | 0,039 | 0,0532 | no pasa |
| TSM Lognormal | ponderadas (como en la publicación) | 0,002 | 0,0009 | pasa |

**Filas sin datos.** Algunos orígenes no tienen personas en ciertos estratos (sobre todo C3 y C4). Sus tasas quedan fijadas solo por la penalización débil del generador. Con una penalización diez veces menor o mayor, las celdas informadas cambian a lo más 0,009 en EPS y 0,028 en TSM. La fila C4 publicada de TSM no tiene datos; ya no se usa como absorbente, porque la proyección por estrato no la necesita.

**Composición.** Los valores globales de los modelos son el promedio de las predicciones por estrato, ponderado por la composición R7 de las personas analizables con ese origen. No se repite una predicción global en todos los estratos. Con esa estandarización, la permanencia C1 de EPS A pasa de 69,6 % (composición de entrenamiento EPS) a 68,2 % (composición de la cohorte TSM).

## 6. Comparación global a dos años

Todas las columnas son a dos años. El observado lleva su intervalo muestral; los comparadores son predicciones puntuales. En NC → NC, EPS y JRT_reference muestran el escenario de mezcla y, entre paréntesis, los límites todos N0 y todos FD. **↑ / ↓** indican que el valor puntual queda sobre o bajo el IC observado: es una lectura descriptiva, no una prueba, porque el intervalo no incluye la incertidumbre del modelo ni el desgaste.

| Transición | N origen | Observado ponderado (IC) | Sin ponderar | EPS A | EPS Lognormal | JRT_reference (EPS) | TSM A | TSM Lognormal | JRT original | JRT, 2 pasos atemperados | Rangos, ponderado | Rangos, sin ponderar |
|----|----|----|----|----|----|----|----|----|----|----|----|----|
| NC → sigue NC | 410 | 71 % (62 %–80 %) | 79 % | 85 % (77 %–86 %)↑ | 85 % (80 %–86 %)↑ | 85 % (81 %–86 %)↑ | 50 %↓ | 52 %↓ | 97 %↑ | 77 % | 94 %↑ | 98 %↑ |
| C1 → sigue C1 | 488 | 77 % (70 %–83 %) | 74 % | 68 %↓ | 67 %↓ | 66 %↓ | 72 % | 73 % | 90 %↑ | 54 %↓ | 94 %↑ | 91 %↑ |
| C1 → deja de beber (NC) | 488 | 21 % (15 %–28 %) | 25 % | 27 % | 29 %↑ | 29 %↑ | 25 % | 25 % | 9 %↓ | 35 %↑ | 6 %↓ | 9 %↓ |

## 7. Por sexo × edad al inicio

Cada predicción usa el modelo del propio estrato; no se repite el valor global. Se reutilizan las tablas de permanencia ya calculadas. Con menos de 30 personas de origen no hay veredicto: se muestra la predicción, pero no se marca. Celdas con 30 a 99 personas son exploratorias.

### NC → sigue NC

| Estrato | N origen | Observado ponderado (IC) | Sin ponderar | EPS A | EPS Lognormal | JRT_reference (EPS) | TSM A | TSM Lognormal | JRT original | JRT, 2 pasos atemperados | Rangos, ponderado | Rangos, sin ponderar |
|----|----|----|----|----|----|----|----|----|----|----|----|----|
| Hombres 18-29 | 8 | 7/8 solo conteo | — | 79 % (75 %–79 %) | 75 % (69 %–76 %) | 74 % (69 %–74 %) | 50 % | 52 % | 99 % | 81 % | 100 % | 100 % |
| Hombres 30-44 | 29 | 60 % inestable | 66 % | 80 % (76 %–81 %) | 78 % (73 %–80 %) | 79 % (75 %–79 %) | 50 % | 44 % | 98 % | 80 % | 100 % | 100 % |
| Hombres 45-59 | 30 | 54 % (31 %–78 %) exploratoria | 63 % | 82 %↑ (78 %–82 %) | 82 %↑ (76 %–83 %) | 83 %↑ (80 %–83 %) | 49 % | 45 % | 99 %↑ | 82 %↑ | 93 %↑ | 97 %↑ |
| Hombres 60-65 | 24 | 72 % inestable | 71 % | 83 % (77 %–83 %) | 83 % (77 %–84 %) | 85 % (78 %–85 %) | 49 % | 43 % | 99 % | 88 % | 99 % | 100 % |
| Mujeres 18-29 | 26 | 35 % inestable | 50 % | 83 % (78 %–83 %) | 82 % (77 %–82 %) | 81 % (73 %–81 %) | 49 % | 38 % | 97 % | 75 % | 48 % | 73 % |
| Mujeres 30-44 | 81 | 83 % (71 %–93 %) exploratoria | 85 % | 87 % (78 %–88 %) | 88 % (83 %–88 %) | 88 % (83 %–89 %) | 49 %↓ | 47 %↓ | 95 %↑ | 71 %↓ | 100 %↑ | 100 %↑ |
| Mujeres 45-59 | 131 | 88 % (80 %–94 %) | 84 % | 89 % (77 %–90 %) | 90 % (87 %–91 %) | 91 % (87 %–91 %) | 51 %↓ | 61 %↓ | 97 %↑ | 76 %↓ | 100 %↑ | 100 %↑ |
| Mujeres 60-65 | 81 | 77 % (60 %–93 %) exploratoria | 84 % | 89 % (78 %–90 %) | 91 % (86 %–91 %) | 92 % (85 %–92 %) | 51 %↓ | 75 % | 98 %↑ | 79 % | 100 %↑ | 100 %↑ |

### C1 → sigue C1

| Estrato | N origen | Observado ponderado (IC) | Sin ponderar | EPS A | EPS Lognormal | JRT_reference (EPS) | TSM A | TSM Lognormal | JRT original | JRT, 2 pasos atemperados | Rangos, ponderado | Rangos, sin ponderar |
|----|----|----|----|----|----|----|----|----|----|----|----|----|
| Hombres 18-29 | 32 | 93 % (79 %–99 %) exploratoria | 88 % | 76 %↓ | 77 %↓ | 73 %↓ | 74 %↓ | 76 %↓ | 93 % | 57 %↓ | 95 % | 91 % |
| Hombres 30-44 | 64 | 75 % (54 %–91 %) exploratoria | 83 % | 75 % | 75 % | 72 % | 74 % | 77 % | 92 %↑ | 56 % | 97 %↑ | 100 %↑ |
| Hombres 45-59 | 77 | 86 % (74 %–96 %) exploratoria | 87 % | 73 %↓ | 71 %↓ | 69 %↓ | 73 %↓ | 75 % | 93 % | 58 %↓ | 100 %↑ | 100 %↑ |
| Hombres 60-65 | 48 | 91 % (82 %–96 %) exploratoria | 75 % | 72 %↓ | 71 %↓ | 70 %↓ | 74 %↓ | 76 %↓ | 82 % | 47 %↓ | 100 %↑ | 90 % |
| Mujeres 18-29 | 23 | 74 % inestable | 70 % | 62 % | 66 % | 67 % | 71 % | 75 % | 90 % | 54 % | 92 % | 100 % |
| Mujeres 30-44 | 88 | 71 % (52 %–86 %) exploratoria | 77 % | 59 % | 59 % | 60 % | 71 % | 74 % | 89 %↑ | 54 % | 91 %↑ | 92 %↑ |
| Mujeres 45-59 | 114 | 63 % (51 %–74 %) | 58 % | 57 % | 54 % | 55 % | 70 % | 61 % | 89 %↑ | 53 % | 78 %↑ | 76 %↑ |
| Mujeres 60-65 | 42 | 60 % (35 %–83 %) exploratoria | 64 % | 61 % | 53 % | 56 % | 69 % | 47 % | 83 % | 47 % | 95 %↑ | 95 %↑ |

### C1 → deja de beber (NC)

| Estrato | N origen | Observado ponderado (IC) | Sin ponderar | EPS A | EPS Lognormal | JRT_reference (EPS) | TSM A | TSM Lognormal | JRT original | JRT, 2 pasos atemperados | Rangos, ponderado | Rangos, sin ponderar |
|----|----|----|----|----|----|----|----|----|----|----|----|----|
| Hombres 18-29 | 32 | 7 % (1 %–21 %) exploratoria | 12 % | 19 % | 18 % | 19 % | 24 %↑ | 22 %↑ | 5 % | 28 %↑ | 5 % | 9 % |
| Hombres 30-44 | 64 | 25 % (9 %–46 %) exploratoria | 16 % | 21 % | 21 % | 21 % | 24 % | 21 % | 7 %↓ | 32 % | 3 %↓ | 0 %↓ |
| Hombres 45-59 | 77 | 14 % (4 %–26 %) exploratoria | 13 % | 23 % | 25 % | 26 % | 25 % | 22 % | 6 % | 29 %↑ | 0 %↓ | 0 %↓ |
| Hombres 60-65 | 48 | 9 % (4 %–18 %) exploratoria | 25 % | 23 %↑ | 27 %↑ | 24 %↑ | 24 %↑ | 22 %↑ | 17 % | 47 %↑ | 0 %↓ | 10 % |
| Mujeres 18-29 | 23 | 15 % inestable | 26 % | 33 % | 28 % | 29 % | 25 % | 21 % | 9 % | 35 % | 0 % | 0 % |
| Mujeres 30-44 | 88 | 22 % (10 %–37 %) exploratoria | 20 % | 37 % | 38 %↑ | 37 %↑ | 27 % | 25 % | 10 %↓ | 35 % | 9 %↓ | 7 %↓ |
| Mujeres 45-59 | 114 | 37 % (26 %–49 %) | 42 % | 39 % | 44 % | 44 % | 27 % | 36 % | 10 %↓ | 36 % | 22 %↓ | 24 %↓ |
| Mujeres 60-65 | 42 | 40 % (17 %–65 %) exploratoria | 36 % | 35 % | 45 % | 41 % | 27 % | 50 % | 17 %↓ | 45 % | 5 %↓ | 5 %↓ |

### Resumen por estrato con 30 o más personas de origen

Número de estratos donde el valor puntual queda dentro / sobre / bajo el IC observado. Es un recuento descriptivo: con ocho estratos, intervalos anchos y sin incertidumbre del modelo, no demuestra diferencias.

| Comparador               | NC → sigue NC  | C1 → sigue C1  | C1 → deja de beber |
|--------------------------|----------------|----------------|--------------------|
| EPS A                    | 3 / 1 / 0 de 4 | 4 / 0 / 3 de 7 | 6 / 1 / 0 de 7     |
| EPS Lognormal            | 3 / 1 / 0 de 4 | 4 / 0 / 3 de 7 | 5 / 2 / 0 de 7     |
| JRT_reference (EPS)      | 3 / 1 / 0 de 4 | 4 / 0 / 3 de 7 | 5 / 2 / 0 de 7     |
| TSM A                    | 1 / 0 / 3 de 4 | 4 / 0 / 3 de 7 | 5 / 2 / 0 de 7     |
| TSM Lognormal            | 2 / 0 / 2 de 4 | 5 / 0 / 2 de 7 | 5 / 2 / 0 de 7     |
| JRT original             | 0 / 4 / 0 de 4 | 4 / 3 / 0 de 7 | 3 / 0 / 4 de 7     |
| JRT, 2 pasos atemperados | 1 / 1 / 2 de 4 | 4 / 0 / 3 de 7 | 4 / 3 / 0 de 7     |
| Rangos, ponderado        | 0 / 4 / 0 de 4 | 1 / 6 / 0 de 7 | 1 / 0 / 6 de 7     |
| Rangos, sin ponderar     | 0 / 4 / 0 de 4 | 2 / 5 / 0 de 7 | 2 / 0 / 5 de 7     |

**Orígenes altos.** Solo hay seis personas con origen C2 o más en R7 (4 C2, 2 C3, ninguna C4). No sirven para validar la persistencia de estados altos en ningún comparador.

## 8. Educación

La educación queda como margen observado (sección 3). Las matrices exportadas de los motores están solo por sexo × edad; el motor EPS Lognormal usa educación, pero sus predicciones por nivel educativo no se exportaron. Obtenerlas exige volver a evaluar el modelo sobre la cohorte, no solo leer salidas. No se forzaron matrices sexo × edad × educación: serían celdas de unas 37 personas.

## 9. Conclusión

Se describen diferencias puntuales frente al intervalo observado; ninguna es una prueba. Estar en el mismo estado en R7 y R11 no prueba permanencia continua: alguien pudo cambiar y volver entre ambas entrevistas. Esta comprobación tampoco valida por sí sola las trayectorias anuales de ningún motor.

- **JRT original sobreestima la estabilidad a nivel global.** Predice que 97 % de los no bebedores y 90 % de C1 siguen igual a dos años, frente a 71 % y 77 % observados; ambos valores quedan sobre el IC. Por estrato con 30 o más personas queda sobre el IC en 4 de 4 en NC y en 3 de 7 en C1. Es coherente con su construcción: el acoplamiento por rangos de los mismos márgenes TSM da 94 % y 94 %. Aplicado como en su simulación, con dos pasos α = 0,5, pasa a quedar bajo lo observado en C1 (54 %) y dentro del IC en NC (77 %).
- **El rank matching sobreestima la estabilidad** a dos años en estos datos, como ya se veía a cuatro años en EPS.
- **JRT_reference y EPS quedan cerca entre sí.** En C1 predicen 66 % y 68 % de permanencia, algo bajo el IC observado (70 %–83 %) y también bajo el valor sin ponderar (74 %). En no bebedores predicen cerca de 85 %, sobre el observado ponderado y sin ponderar (71 % y 79 %); el límite todo FD (77 %) cae dentro del IC. Las diferencias son de 6 a 14 puntos y dependen del peso y de la mezcla N0/FD.
- **El motor TSM reproduce C1 y no reproduce NC.** Predice 72 % en C1, dentro del IC, pero solo 50 % de no bebedores que siguen sin beber, muy bajo lo observado. La proyección desde intervalos de 4 a 8 meses implica más inicio de consumo del que se observa a 24 meses.
- **Por sexo × edad** el patrón global se repite en general, con mucho ruido. Los estratos con 30 o más personas tienen intervalos anchos, y el resumen de la sección 7 debe leerse como descripción.
- **El peso importa.** Lo observado ponderado y sin ponderar difiere hasta 7 puntos. La ponderación usa el peso R7 sin corregir el desgaste, que no está resuelto.

## Decisiones pendientes

- **Desgaste.** ¿Corregir el seguimiento de 24 meses con un IPW propio antes de usar esta comparación como validación?
- **Incertidumbre de los modelos.** ¿Exportar las réplicas de las matrices por grupo (JKn en EPS, bootstrap en TSM) para proyectar cada réplica a dos años? Hoy los modelos son puntuales.
- **JRT original.** ¿Armonizar ENPG 2008 y 2010 para completar los cuatro pares originales, y confirmar con JRT qué volumen y qué tratamiento de no bebedores usó? Sin el RData original, la reconstrucción es aproximada.
- **Mezcla N0/FD.** ¿Qué composición usar para los no bebedores de R7? En EPS, el rango entre todo N0 y todo FD es de unos 8 puntos a nivel global.
- **Educación.** ¿Evaluar el motor EPS Lognormal por nivel educativo sobre la cohorte?
- **Uso de TSM.** Dado que la proyección de intervalos cortos subestima la permanencia sin consumo, ¿restringir TSM a validación externa y no a estimar dinámica anual?

## Límites

- Seguimiento de 43 %, más bajo en jóvenes, sin corrección por desgaste: el peso R7 no ajusta la pérdida. El IPW de TSM se ajusta por intervalo corto y no se traslada a 24 meses.
- Las predicciones de los modelos son puntuales; el intervalo observado solo refleja muestreo.
- El JRT original se reconstruyó con 2 de sus 4 pares de entrenamiento y con un cambio necesario en el volumen de no bebedores; no es el ajuste original.
- Los 24 meses suponen abril de 2025 para R11, fecha no verificada. Las proyecciones a dos años de EPS y TSM suponen tiempo homogéneo: EPS proyecta hacia abajo desde 3,7–4 años y TSM hacia arriba desde menos de un año.
- Exploratorio: no cambia motores, esquema ni notebooks. Código: `__andres_control/tsm_r7_r11_direct.R` y `__andres_control/tsm_r7_r11_comparators.R`; tablas: `__andres_control/tsm_r7_r11_direct_outputs/` (comparadores con prefijo `cmp_`).
