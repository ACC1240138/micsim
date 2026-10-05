Abre el [notebook](microsim_base_ACC_2012_2024.ipynb) y mira la sección 9: la ejecución funciona, pero la prevalencia todavía falla en la validación de 2022/2024.

# Microsimulación base: qué quedó hecho y qué falta

**Estado al 17-sep-2026:** 13 celdas R ejecutadas con datos reales, sin errores, en **0,57 minutos (unos 34 segundos)**. El notebook conserva código, tablas y figuras. No necesitas ejecutarlo para leer los resultados.

## 1. Qué abrir y cómo usarlo

1. Abre [microsim_base_ACC_2012_2024.ipynb](microsim_base_ACC_2012_2024.ipynb). La sección 1 revisa la propuesta de Claude; la 9 muestra la validación; la 13, el reajuste histórico y la proyección.
2. Para repetirlo, selecciona un kernel R con los paquetes indicados en la sección 3 y ejecuta todas las celdas. El tiempo observado corresponde a 25.000 personas iniciales y cinco repeticiones históricas en esta máquina; no es una garantía para otro equipo.
3. Revisa [validation_metrics.csv](microsim_base_outputs/validation_metrics.csv), [projection.csv](microsim_base_outputs/projection.csv) y [model_parameters.csv](microsim_base_outputs/model_parameters.csv). Los archivos se regeneran en `microsim_base_outputs/`; no se exportan microdatos de encuestados.

**Ya funciona:** población sintética, envejecimiento real, consumo continuo, HED, muertes, entradas, salidas, calibración, comparación observada/simulada y exportaciones. Todo el motor está visible en el notebook; no depende de funciones escondidas en scripts del proyecto. El formato sigue `expand_pif*`: cabecera Quarto, secciones, tablas HTML, figuras y tiempo por celda. Markdown y comentarios del notebook están en inglés.

## 2. Qué modelo construí

El ámbito es **15–65 años inclusive**: los datos disponibles incluyen los 65, aunque el plan decía 15–64. Cada enero se registra la población y su consumo; se sortean fallecimientos; los sobrevivientes envejecen; salen quienes cumplen 66; entran nuevos individuos de 15 años y se concilian los restantes grupos con INE.

La conciliación produce entradas/salidas **residuales**. No equivale a observar inmigración o emigración. Coincidir con INE es un control de contabilidad porque esos totales se imponen al motor.

La prevalencia de consumo en los últimos 30 días y la intensidad media entre consumidores se ajustan por sexo y grupo etario. La intensidad utiliza gramos/día de encuesta, una masa en cero y una distribución Gamma positiva. HED depende de intensidad, sexo y edad. Las categorías se calculan después del consumo continuo, sin huecos entre los puntos de corte.

Las trayectorias individuales dependen de una persistencia supuesta, `rho = 0,8`. Las encuestas transversales repetidas no identifican esa persistencia. El indicador de haber bebido alguna vez nunca retrocede para una persona simulada; «ex» significa aquí haber bebido y no consumir en los últimos 30 días, **no necesariamente un año de abstinencia**.

La mortalidad usa `qx` de HMD, un multiplicador por sexo calibrado con DEIS y los stocks INE. **Todavía no depende del consumo de alcohol.** Por eso esta versión no calcula supervivencia modificada por alcohol, muertes evitadas por una política, mortalidad atribuible ni YPLL.

## 3. Qué muestran los resultados

El entrenamiento utiliza 2012–2020. Los resultados de 2022/2024 se excluyen de todos los componentes ajustados y se reservan para comparación temporal. La demografía histórica sí utiliza INE/HMD de cada año: no es un pronóstico completamente prospectivo.

| Resultado en 2022/2024 | Valor | Lectura |
|---|---:|---|
| Prevalencia: error medio | +9,75 puntos porcentuales | Sobreestimación sistemática |
| Prevalencia: RMSE | 10,26 puntos porcentuales | La validación falla; 0 de 16 celdas dentro de los intervalos de referencia |
| Intensidad: RMSE | 1,08 g/día | 12 de 16 celdas dentro del intervalo de referencia |
| HED: RMSE | 5,34 puntos porcentuales | Diagnóstico secundario; 12 de 16 celdas dentro del intervalo |

El comparador que mantiene las medias de prevalencia/intensidad de 2012 obtiene RMSE de **6,34 puntos** y **0,94 g/día**, respectivamente: la tendencia calibrada no lo mejora. Sus otros componentes se estiman agrupando 2012–2020 y su mortalidad usa HMD sin escalar; no es un modelo íntegramente estimado con 2012. Usa una semilla frente a cinco del modelo calibrado.

Tras evaluar ese modelo congelado, ajusté otro con las siete olas. Su error histórico dentro de muestra es **4,35 puntos** para prevalencia y **0,54 g/día** para intensidad. Es reajuste, no validación independiente; tampoco reproduce exactamente todas las olas.

En mortalidad, el valor esperado de 2024 supera DEIS en **5,17% en hombres y 3,22% en mujeres**. Se muestran muertes esperadas y sorteadas por separado para distinguir desacuerdo del modelo y ruido Monte Carlo. HMD y DEIS comparten antecedentes de registro vital: su concordancia tampoco constituye validación externa independiente.

La proyección **2025–2034** congela los parámetros de exposición y `qx` de 2024 mientras evoluciona la población INE. Es un escenario condicional; [projection_mortality.csv](microsim_base_outputs/projection_mortality.csv) permite revisar muertes por año, sexo y edad.

## 4. Auditorías que cambiaron la propuesta

| Hallazgo | Decisión aplicada |
|---|---|
| Elevar probabilidades a 0,5 y normalizar filas no anualiza una matriz bienal | Construcción anual explícita; persistencia expuesta como supuesto. No se copiaron pseudopares como si fueran seguimiento observado |
| Entrenar pares hasta 2022 o asignar entrantes desde la ola más cercana filtra información del holdout | Todos los ajustes usan sólo años de entrenamiento; una prueba altera los resultados posteriores y confirma que el ajuste no cambia |
| La caché de diseño no contiene toda la exposición; sexo/edad están vacíos en algunas olas | Unión año–ID con `ENPG_BINGE.RDS`, verificada al 100%; 124.104 registros de 15–65 años |
| PSU 2016 incompleto, estrato 2024 disponible y PSU 2020 no validado | PSU 2016 con comuna/distrito/zona/manzana, ESTRATO 2024 y precisión 2020 explícitamente provisional |
| El volumen corregido guardado falta en todos los no consumidores | Su media entre valores finitos tiene denominador de consumidores; no se impuso como consumo per cápita poblacional |

La corrección OMS requiere resolver denominador, cobertura, edad y año. No cambia automáticamente la prevalencia observada. El modelo mantiene separada la escala de encuesta y no modifica el pipeline previo de corrección.

INE incluye enero y junio: se seleccionan por separado para evitar duplicar población. HMD aporta `qx` y `mx`; la esperanza de vida `ex` no sustituye una probabilidad de muerte. DEIS 2024 se restringe a ese año y a edades expresadas en años cumplidos.

Los controles pasan para repetibilidad, balance anual, envejecimiento, historia irreversible, rangos de exposición, ausencia de filtración del holdout y conversión de muertes simuladas a cantidades poblacionales. Los hashes permiten identificar los insumos. **Estos controles de código no corrigen el fracaso predictivo.**

La sensibilidad `rho = 0 / 0,8 / 0,95` cambia las transiciones anuales de consumo aproximadamente a **48% / 20% / 10%**. Aunque la prevalencia actual de 2024 sigue cerca de 48–49%, la proporción que nunca bebió cambia a **1,25% / 5,20% / 11,23%**. Esas historias no están validadas y no deben alimentar RR de exbebedores como si fueran trayectorias observadas.

## 5. Decisiones, reglas y siguiente revisión

1. **Primero, mejorar la especificación del consumo.** Examinar tendencia, ola 2020, faltantes y cambios de medición. Después de usar 2022/2024 para revisar el modelo, esos años pasan a desarrollo; no se puede seguir llamándolos holdout intacto.
2. **Después, vincular mortalidad y alcohol.** Hace falta mortalidad por causa, riesgos individuales compatibles y evaluación de riesgos competitivos. Multiplicar muertes totales por AAF dentro del motor no crea por sí solo ese vínculo. La discrepancia previa del caché YPLL continúa documentada en el [handoff canónico](codex_handoff_adam_rr_full_override_caveman.md).
3. **Acordar alcance con los coautores.** Persistencia individual, seguimiento después de los 65, puente encuesta–APC y definiciones de HED/exbebedor siguen abiertos. Las cinco semillas miden ruido de simulación, no toda la incertidumbre científica.
4. **Añadir bebidas/SES cuando haya parámetros y una pregunta concreta.** Escolaridad permitiría estudiar desigualdad, pero divide celdas y exige nuevos parámetros; ingreso no es equivalente. Para impuestos: bebida → participación si se incluye → elasticidad → consumo continuo → categorías. No se crearon columnas vacías ni un segundo motor MicSim.

**Adaptaciones de reglas, autorizadas por tu instrucción:** la solicitud de notebook prevalece sobre el esquema de scripts y la prohibición de notebooks de la propuesta de Claude. Se usa `here::i_am()`/`here::here()` porque faltan `.acc_root` y los helpers prescritos. Para esta entrada del handoff se usa el hostname observado `DELL_LR`, identificado como tal, porque `MACHINE_ID` no está configurado. No se inventó una configuración persistente. La corrección de PSU 2016 se limita al notebook nuevo; los motores y notebooks AAF/PIF/RR existentes no se editaron.

La memoria local pide consulta previa para cambios metodológicos del pipeline AAF/PAF/PIF: esos motores no se cambiaron. Su descripción antigua del estado de integración no se usó para deshacer el código actual. `CLAUDE.md` remite a `AGENTS.md`; no se reescribió ninguno. Los hitos posteriores a septiembre se presentan como propuestas de planificación, no compromisos nuevos de ACC.

Se aplicó Ponytail al código y `/i-have-adhd` sólo a este documento. El detalle reproducible y las referencias SIMAH están en el notebook; las nuevas auditorías se agregan al handoff sin reordenar entradas anteriores.

**Siguiente acción — menos de 2 minutos:** abre la figura de prevalencia de la sección 11 y localiza las observaciones de 2022 y 2024 frente a la línea simulada.

---

Abre el [notebook de recalibración](microsim_recalib_ACC_2012_2024.ipynb) y mira la tabla de la sección 9: ninguna regla de proyección gana siempre.

# Recalibración (18-sep-2026): qué hice con las observaciones de Codex

**Estado:** notebook nuevo, `microsim_recalib_ACC_2012_2024.ipynb`, 14 celdas R, semilla **2125** (y 2126–2129 para repeticiones), ejecutado con datos reales en **~1,1 minutos**, sin errores. El notebook original y sus salidas **no se tocaron**. Salidas nuevas en `microsim_recalib_outputs/`.

## 1. En una frase

Codex tenía razón: el problema era **la curva de tendencia**, no la microsimulación. Probé cuatro curvas, las evalué con cortes temporales sucesivos, reconstruí 2012–2024 con las siete olas y proyecté con tres reglas distintas.

## 2. Qué es nuevo (y qué no)

| Igual que antes | Nuevo |
|---|---|
| Lectura de ENPG, INE, HMD, DEIS (celdas copiadas tal cual) | `ms_fit(..., spec = ...)`: cuatro curvas de tendencia |
| Motor anual persona a persona | Interruptor `drop_2020` para sensibilidad |
| Persistencia `rho = 0,8` como supuesto | Auditoría de comparabilidad por ola |
| Mortalidad independiente del alcohol | Evaluación por cortes sucesivos (2016→2018, 2018→2020, 2020→2022, 2022→2024) |
| Controles de código | Reconstrucción con 7 olas + proyección con 3 reglas |

Las cuatro curvas:

- **static2012** — todo fijo en 2012 (comparador).
- **interp_hold** — une los puntos de cada ola y mantiene el último valor hacia adelante. *Esta es la reconstrucción.*
- **linear_all** — tendencia lineal por celda (la que falló en el notebook anterior).
- **spline_shared** — curva suave compartida entre celdas, moderadamente flexible.

No agregué motor `data.table` ni `MicSim`: un segundo motor no arregla una curva mal especificada.

## 3. Resultados clave

### 3a. Comparabilidad: la ola 2022 es distinta

| Señal | 2022 | Otras olas |
|---|---:|---:|
| Dispersión de pesos (CV) | **1,05** | 1,58–1,91 |
| Muestra efectiva / n | **0,47** | 0,22–0,29 |
| Población ponderada 15–65 vs INE | **91 %** | 77–80 % |

Los pesos de 2022 se calcularon de otra forma o el diseño cambió. Los archivos no dicen cuál. **Antes de decir que "el consumo bajó en 2022", hay que pedir los informes metodológicos de SENDA.** Lo que no se puede auditar desde los datos (redacción de preguntas, modalidad, fechas de terreno, tasa de respuesta) quedó en una tabla de pendientes.

### 3b. Cortes sucesivos: ninguna regla domina

RMSE de prevalencia, en puntos porcentuales, prediciendo la ola siguiente:

| Regla | →2018 | →2020 | →2022 | →2024 | Promedio |
|---|---:|---:|---:|---:|---:|
| spline_shared | 4,4 | **6,9** | 3,3 | 1,5 | **4,5** |
| interp_hold (mantener último) | 3,7 | 3,2 | 6,7 | 5,1 | 4,9 |
| static2012 | 3,5 | 4,1 | 4,8 | 8,1 | 5,4 |
| linear_all | 8,3 | 3,8 | 7,7 | 6,1 | 6,7 |

- El spline gana en promedio, pero tiene el **peor fallo individual** (2020).
- Mantener el último valor es la regla **más estable**.
- La tendencia lineal es la **peor en todos los cortes**.
- A dos olas de distancia, **nada supera a "todo sigue como en 2012"** (5,9 puntos): la prevalencia de 2022/2024 volvió al nivel de 2012.

### 3c. Sensibilidad 2020: el "acierto" del spline depende de esa ola

Prediciendo 2022 desde ≤2020: el spline erra 3,3 puntos **con** 2020 y **6,3 sin** 2020 (y el sesgo cambia de signo). Mantener el último valor casi no cambia (6,7 → 6,9). Conclusión: **no se puede presentar el spline como que "anticipó" la caída.**

### 3d. Confirmación en el motor (corte 2020, 16 celdas, 5 semillas)

| Regla | RMSE prevalencia (pp) | Sesgo (pp) |
|---|---:|---:|
| spline_shared | 3,9 | +3,1 |
| static2012 | 6,8 | +5,5 |
| interp_hold | 9,3 | +8,8 |
| linear_all | 10,4 | +9,9 |

El 10,4 de `linear_all` reproduce el 10,26 del notebook anterior con semillas nuevas. En intensidad, la mejor regla es otra (interp_hold, 0,60 g/día): **el ranking depende del resultado que mires.**

### 3e. Reconstrucción 2012–2024 (7 olas, 5 semillas)

- Prevalencia: RMSE **0,5 puntos** (ruido Monte Carlo 0,9). Intensidad: **0,11 g/día**. Es calibración reproducida, **no validación**.
- HED: sesgo **−4,5 puntos**. HED no está calibrado a un margen. Es el **siguiente ítem de calibración**, antes de conectar RR.
- Mortalidad: multiplicadores 0,970 (mujeres) y 0,945 (hombres). El error de muertes esperadas va de −3,1 % (2012) a +3,8 % (2024): un multiplicador único promedia una deriva HMD–DEIS.
- `rho` 0 / 0,8 / 0,95 → nunca-bebedores en 2024 de **1,7 % / 6,1 % / 12,6 %** con la misma prevalencia. Sigue sin identificarse.

### 3f. Proyección 2025–2034: tres reglas, tres futuros

| Regla | Prevalencia 15–65 en 2034 |
|---|---:|
| interp_hold (mantener 2024) | 36,6 % |
| linear_all | 32,2 % |
| spline_shared | **15,2 %** ← no creíble |

Una regla que gana a una ola no se puede correr diez años sin modificar. Las muertes esperadas son **idénticas** entre reglas (35.693 en 2034) porque la mortalidad todavía no depende del consumo.

## 4. Decisiones que propongo (falta acordarlas con ACC)

1. **Base 2012–2024 = reconstrucción `interp_hold` con 7 olas.** Completa, reproducible, supuestos explícitos.
2. **2025+ = mantener último valor como escenario central**; tendencia lineal como alternativa acotada; spline **no** más allá de una ola.
3. **Pesos de 2022 = pregunta abierta** antes de interpretar la caída como conducta.
4. **Calibrar HED** y decidir multiplicadores de mortalidad por año antes de integrar RR.
5. **Ya no queda holdout intacto.** Para volver a hablar de desempeño predictivo hace falta una ola nueva o una encuesta independiente.

## 5. Detalles de ejecución

- Dos errores corregidos al correr: `tidyselect` no acepta `base::c()` dentro de `pivot_wider` (se usa `c()` con comentario); el umbral fijo del control driver–motor fallaba por las celdas pequeñas de 60–65 (ahora es un z binomial; |z| máximo 3,3 en 224 celdas).
- Ejecutado con `python -m nbconvert` y kernel `ir` (el atajo `jupyter nbconvert` no está en el PATH de esta máquina).
- Hostname observado `DELL_LR`; `MACHINE_ID` sigue sin configurar. El handoff canónico tiene la entrada del 18-sep-2026 con los mismos números.
- Ponytail aplicado al código; `/i-have-adhd` sólo a este documento.

**Siguiente acción — menos de 2 minutos:** abre `microsim_recalib_outputs/rolling_origin_prevalence.png` y mira dónde cae cada regla en 2020 y en 2022.
