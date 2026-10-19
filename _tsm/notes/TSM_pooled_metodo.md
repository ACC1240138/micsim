---
title: "TSM: transiciones agrupadas y volumen de consumo"
subtitle: "Historia de consumo, IPW y modelos continuos; preparación para ENPG"
author: "Andres Gonzalez Santa Cruz"
date: last-modified
lang: es
format:
  html:
    theme: journal
    css: [_lib/styles.css, _lib/prediction_metrics_compact.css]
    toc: true
    toc-location: left
    toc-depth: 2
    number-sections: true
    code-fold: true
    code-summary: "Mostrar código R"
    code-tools: true
    embed-resources: true
    self-contained: true
    fig-cap-location: top
execute:
  echo: true
  warning: true
  error: false
lightbox: auto
---

::: {.callout-note}
## Qué responde este notebook

Estima el cambio entre **olas consecutivas de las mismas personas**, agrupando los pares disponibles.
El estudio conserva una población objetivo de **15–65 años**; TSM aporta transiciones observadas
para **18–65 años al inicio de cada par**. No se extrapola a 15–17.

El análisis principal tiene dos partes: **beber en la siguiente ola**, condicionado al estado previo,
y **cantidad positiva**, mediante Gamma o lognormal. Las matrices de tus categorías se obtienen
de esos modelos y se contrastan con probabilidades empíricas ponderadas.
Los gramos son un **proxy reconstruido**; 12 y 15,7 g/trago son escenarios separados.
**No se aplica APC ni se calibra ENPG en esta versión.**
:::

<!-- code:setup -->

## Flujo y decisiones

| Decisión | Implementación |
|---|---|
| Pares principales | R8→R9, R9→R10 y R10→R11; R7 aporta historia |
| Incorporaciones y retornos | Toda persona observada en un origen elegible; no se exige cohorte completa |
| FD | No bebe actualmente y declaró consumo en alguna ola anterior disponible |
| Otros no consumidores | Historia previa desconocida; no identificados como abstemios de vida |
| Peso | Fact_Exp de origen × inversa de probabilidad de observar la siguiente ola |
| Cantidad | Frecuencia × cantidad típica; 12 y 15,7 g/trago; sin APC |
| Modelos | Logit de participación + Gamma o lognormal para cantidad positiva |
| Estratificación | Predictores comunes en un modelo agrupado; resultados por edad, sexo y educación |
| Incertidumbre | Rama por par e, independientemente, rama agrupada por persona |

<!-- code:flow -->

## Datos, historia y participación

Se selecciona **Entrevistado=1** y se enlaza **IdPanel**. La historia se construye antes de restringir
la edad o formar pares, usando únicamente olas anteriores. Una ausencia intermedia no borra
un antecedente de consumo. La edad se restringe en el origen; se conserva a quien cumple 66 antes
de la siguiente entrevista.

**FD observado es la aproximación disponible al FD de ENPG**, definido en expand_pif como haber
bebido alguna vez pero no durante los últimos 30 días: oh2 indica >30 días o >1 año.
TSM no verifica esa ventana ni identifica abstemios de vida. “Nunca” se interpreta operativamente
como no consumo declarado en la entrevista, sin atribuirle una historia vital.
La detección de FD aumenta con la historia disponible; se conserva su longitud.
El IPW del destino no reconstruye consumo previo no observado ni identifica FD entre
quienes ya habían dejado de beber antes de su primera entrevista disponible.

<!-- code:inputs -->

“Ausencia de destino” incluye situaciones que los archivos no permiten separar: no contacto,
rechazo, inelegibilidad o fallecimiento, entre otras. No equivale a abandono definitivo.
“Primera aparición” tampoco identifica por sí sola una incorporación oficial al panel.
No se emparejan personas diferentes. Si alguien falta en R9 y vuelve en R10, R8→R10 no se cuenta
como t+1; puede aportar R10→R11.

<!-- code:attrition -->

## Conversión y homologación con ENPG

| Componente | TSM | ENPG en expand_pif | Decisión |
|---|---|---|---|
| Participación | e3a1: Nunca / frecuencia | oh1, oh2: vida y recencia | Historia desconocida y FD observado separados |
| Frecuencia | e3a1: intervalos ordinales | oh3: días en últimos 30 días | Puntos explícitos para TSM |
| Cantidad típica | e3a2: 0–2, 3–4, 5–6, 7–9, ≥10 | audit2: 0–2, 3–4, 5–6, 7–8, ≥9 | TSM: 1; 3,5; 5,5; 8; 10 |
| Episodios intensos | e3a3: frecuencia de ≥6 tragos | db; umbral 5 hombres / 4 mujeres en la fórmula | No convertir códigos ordinales en número de episodios |
| Volumen | Frecuencia/día × cantidad × gramos/trago | [max(oh3−db,0) × cantidad + db × umbral] × gramos/30 | Fórmulas distintas, documentadas |
| Ajuste APC | No aplicado | factor_CH / factor_CHMS | Comparación y calibración posteriores |

Frecuencias de referencia: **0,5 y 3 días/mes; 2,5 y 5,5 días/semana**.
Un mes se representa como 365,25/12 días. Interpretar frecuencia como días y cantidad típica
como promedio son supuestos. Para el intervalo abierto se utiliza su límite inferior, **10**:
replica la regla de ENPG, donde se usa 9 para un intervalo que empieza en 9.

| Categoría | Mujeres, g/día | Hombres, g/día |
|---|---|---|
| ND_unknown: no consumo; historia desconocida | 0, sin consumo previo observado | Igual |
| FD observado | 0, con consumo previo observado | Igual |
| cat1 | >0 y <20 | >0 y <40 |
| cat2 | ≥20 y <40 | ≥40 y <60 |
| cat3 | ≥40 y ≤100 | ≥60 y ≤100 |
| cat4 | >100 | >100 |

Los cortes pertenecen al proyecto; no se presentan como una clasificación universal de la OMS.
Los intervalos continuos evitan huecos de redondeo. El HED mensual se codifica como e3a3≥3
entre quienes beben, se conserva como predictor y dimensión descriptiva, y no añade volumen.
No identifica el mismo umbral que el HED de ENPG.

<!-- code:counts -->

Los recuentos completos conservan las celdas vacías. La suma de observaciones persona-ola
no es un número de personas independientes. Las categorías altas tienen muy poco soporte:
un modelo continuo puede suavizar la distribución, pero no convierte las colas en evidencia observada.
Con la referencia de 12 g, el máximo del proxy es 10 × 5,5/7 × 12 = **94,3 g/día**:
cat4 queda vacía por la conversión elegida, no porque se haya demostrado que nadie supera
100 g/día. El intervalo ≥10 está abierto; 10 es un valor representativo, no un máximo real.

### Sensibilidad a los intervalos abiertos

La siguiente comparación cambia el valor representativo de ≥10 tragos y de ≥4 días/semana.
Es una sensibilidad descriptiva a la medición; no una búsqueda de valores que llenen categorías.

<!-- code:conversion -->

## Selección de seguimiento e IPW

El DAG expresa una hipótesis: características del origen pueden influir tanto en responder
como en el consumo posterior. La ponderación requiere que, condicionando en ellas, la ausencia
del resultado no dependa adicionalmente de su valor, además de positividad.
Las flechas discontinuas muestran una posible violación por causas no medidas; IPW no la elimina.

<!-- code:dag -->

Para cada oportunidad de seguimiento:

\[
q_i=\mathrm{Fact\_Exp}_{i,t},\qquad
\pi_i=P(R_{i,t+1}=1\mid X_{i,t}),\qquad
w_i=q_iR_{i,t+1}/\widehat{\pi}_i.
\]

X incluye ola, estado de participación/historia, edad cuadrática, sexo, educación cursada,
frecuencia y cantidad de consumo, HED mensual, PHQ-2, empleo, macrorregión, pareja y vivienda
verificadas, número de entrevistas previas y primera aparición posterior a R7. No usa
información del destino. La respuesta se modela directamente para cada par: no se exige
abandono monótono ni se multiplican pesos de origen y destino.

Un registro tiene estado conyugal desconocido y destino ausente: una categoría separada produjo
separación. Se usa el indicador **pareja verificada**, conservando el desconocido en la auditoría;
propietario verificado se codifica del mismo modo. Esto no implica que el registro desconocido
carezca de pareja.

<!-- code:ipw -->

El tamaño efectivo por pesos, (Σw)²/Σw², describe dispersión de ponderadores.
No equivale al número de personas ni reconstruye el efecto de diseño. No se añade un
factor Kish a intervalos que ya incorporan los pesos. Un buen balance global tampoco
garantiza balance en categorías escasas ni confirma el supuesto de respuesta.

El pool representa una mezcla de oportunidades persona-periodo ponderadas por Fact_Exp,
no un promedio en que cada persona o cada ola contribuye lo mismo.

## Dos partes: participación y cantidad

La primera parte distingue **no consumo con historia desconocida, FD observado y consumo actual**.
Estima respectivamente una mezcla no identificada de iniciación/reanudación, reanudación
observada, y continuidad. No se etiqueta la primera como iniciación de abstemios de vida.
La cantidad positiva también depende de ese estado de origen.

Los predictores son estado de origen, log(1+tragos/día) previo, edad cuadrática,
sexo, educación, HED mensual, ola y longitud de historia. Se ajusta un modelo conjunto,
sin estimar una regresión independiente para cada celda de edad × sexo × educación.

<!-- code:hurdle -->

\[
P(B_{t+1}=1\mid S_t,Q_t,X_t)=\operatorname{logit}^{-1}(\eta_t).
\]
\[
Q_{t+1}\mid B_{t+1}=1,S_t,Q_t,X_t
\sim \mathrm{Gamma}(\mu_t,k)
\quad\text{o}\quad
\log Q_{t+1}\sim N(\eta^+_t,\sigma^2).
\]

El ajuste se realiza en **tragos/día reconstruidos**, una unidad común a ambos escenarios.
Después se multiplica por 12 o 15,7 y se integran probabilidades entre los cortes de tus
categorías. Así se evita confundir un cambio de unidades con dos ajustes independientes.
En la lognormal, la media positiva es exp(η + σ²/2).

Estas regresiones pueden parametrizar un proceso de Markov en un **estado ampliado**
(cantidad, participación e historia conocida). Markov no exige odds proporcionales ni
hace marginalmente independientes las observaciones de una persona.
Una multinomial sería otra parametrización; aquí se prioriza la alternativa continua solicitada.

**Ceros por definición:** en pares consecutivos, FD o consumo actual no pueden regresar
a “sin consumo previo observado”. Este último grupo tampoco puede convertirse en FD sin
que se observe primero consumo. Se describe el estado observado, no todos los cambios
que podrían ocurrir entre entrevistas.

<!-- code:fit -->

### Distribución de la cantidad positiva

Las curvas muestran la probabilidad de superar cada umbral, entre quienes beben al destino,
según su estado de origen. El escalonamiento del proxy refleja sus intervalos de respuesta;
las curvas suaves son distribuciones ajustadas. Esta es una comprobación interna.
La comparación con personas reservadas se presenta a continuación.

<!-- code:continuous -->

### Comparación predictiva por persona

Se usan cinco particiones de **IDs completos**. En cada partición se reajusta IPW con todos
los orígenes de entrenamiento y los modelos de consumo con los destinos observados.
Los pesos de evaluación se predicen sin usar la respuesta de la persona reservada.
La evaluación corresponde a esta mezcla de olas; no es validación temporal externa.

Se comparan densidad predictiva del proxy, error en gramos y probabilidades de categorías.
Menor es mejor. Las densidades Gamma y lognormal se evalúan en las mismas unidades originales.
Un buen promedio puede ocultar errores en la cola: se muestra la calibración por categoría.
**Los modelos se comparan dentro de cada conversión.** NLL y RMSE cambian mecánicamente
al cambiar unidades y no permiten elegir entre 12 y 15,7 g.

<!-- code:cv -->

### Resultados por edad y sexo

Las probabilidades se promedian sobre los **orígenes completos**, incluidos quienes no
responden después, usando Fact_Exp. Educación y demás predictores mantienen su distribución
observada dentro de cada grupo. No se crean combinaciones inexistentes.
Los CSV incluyen también el cruce con educación y los recuentos que lo sustentan.

<!-- code:stratified -->

## Matrices agrupadas: evidencia y predicción

Las matrices empíricas usan Σw × I(origen,destino) / Σw × I(origen).
Las de los modelos promedian las probabilidades sobre todos los orígenes del estado usando
Fact_Exp. Ambos se apoyan en supuestos de seguimiento/modelo diferentes.
Una fila sin orígenes queda sin estimar, incluso si se podría construir un perfil hipotético.
Para los cortes de ambos extremos se usa el sexo del origen; las discordancias se auditan.

<!-- code:matrices -->

### Dos ramas de incertidumbre

**Por par:** inferencia de trabajo que trata las contribuciones de cada par como independientes.
**Por persona:** agrupa las contribuciones del mismo IdPanel y mantiene las estimaciones puntuales.
No es una penalización automática por usar Markov: acomoda la dependencia dentro del ID.
No corrige el sesgo de un modelo de respuesta o de consumo incorrecto.

Para las matrices empíricas, ambas ramas incorporan la estimación de IPW mediante ecuaciones
apiladas; los no respondedores aportan al modelo de respuesta. Para los modelos continuos,
se remuestrean pares o personas y se reajustan **IPW, participación y cantidad** en cada réplica.
Se usan 500 réplicas por rama. Si Gamma no converge mediante IRLS, se minimiza el mismo
objetivo con BFGS y se comprueba su gradiente; el uso de ese método queda registrado.

Los IC son condicionales a la conversión, al modelo y a la interpretación de los ítems:
no incorporan incertidumbre de esos supuestos ni de la selección de familia.
Los ceros estructurales se identifican. Los límites empíricos 0/1 no reciben un IC artificial
de ancho cero. Filas con menos de diez personas de origen no reciben IC de modelo; es una
regla de presentación exploratoria, no garantía de precisión.

<!-- code:bootstrap -->

## Análisis adicionales

La rama sin separar FD incorpora R7→R8 para cuantificar la ganancia de pares. Otra conserva
todos los orígenes R7–R10 con FD observado, reconociendo que R7 no puede identificarlo.
Se añaden destinos directos t+2 desde R8/R9; no se presentan como probabilidades anuales
ni se elevan matrices a potencias. En t+2, una entrevista intermedia puede aportar
historia de consumo para clasificar FD en el destino.

Truncamiento IPW y exclusión de discordancias demográficas son sensibilidades.
No sustituyen el análisis principal. La comparación de coherencia excluye cambio de sexo,
descenso de edad o aumento mayor al número de olas del intervalo.

<!-- code:sensitivities -->

## Comparación posterior con ENPG

Se conservan tus cortes por sexo y una regla de conversión equivalente para intervalos
de cantidad. Persisten diferencias en ventana temporal, frecuencia, episodios intensos y
antecedentes de abstinencia. Por ello no se ha transferido factor_CH a TSM.
APC es una referencia de consumo poblacional, no una corrección exclusiva de AUDIT;
el problema aquí es justificar la medida y población a las que se aplicaría.

La ruta posterior inspirada en [Moid et al.](https://journals.sagepub.com/doi/10.1177/23814683261421957)
utilizaría información longitudinal para iniciar transiciones y calibraría después las
distribuciones poblacionales. Los márgenes de ENPG no identifican por sí solos una matriz
única: harían falta restricciones y evaluación en datos reservados. Esa etapa **no se ejecuta** aquí.

[Puka et al.](https://doi.org/10.1111/add.16024) modelan transiciones en tiempo continuo.
Aquí se estima el siguiente intervalo observado. Una parametrización con tasas homogéneas
podría permitir proyecciones posteriores; no convierte automáticamente estos pares de
distinta duración en transiciones anuales.

El prototipo local jrt/simulacion/Alcohol Transitions FINAL.R usa rank matching entre
personas distintas y MASS::polr, con odds proporcionales, agrupando FD con no bebedores
y sin cat4. No se ejecuta ni se reutiliza ese emparejamiento en TSM.

### Diseño e inferencia: declaración conservada en inglés

Official presentations describe an urban sample derived from households previously interviewed
in person, but do not identify the original primary sampling units or strata. This does not
establish that the original design lacked clustering or stratification; those identifiers were
not identified in the publicly released materials reviewed. Analyses use the available
origin-wave expansion factor and estimated follow-up response weights. Pair-based and
person-clustered uncertainty estimates are working approximations, not a reconstruction of the
original sampling design. No PSU or stratum is inferred from region or interview identifiers.

### Códigos y fuentes

El diccionario incluye variables demográficas para una futura homologación censal: sexo a2,
edad a3, región IdRegion, educación cursada b4a, relación con entrevistado a4, estado conyugal a6,
nacionalidad a7, otros campos disponibles a8–a12b y vivienda f1. Se conservan las etiquetas
exactas por ola; no se atribuyen códigos de un censo externo aún no seleccionado.

- Fuentes primarias: cinco SAV locales y sus etiquetas; cuestionarios R7–R10. R11 tiene etiquetas SAV, no cuestionario verificado.
- Conversión: expand_pif.ipynb, celda enpg-consolidate, definiciones cvolaj y cvolajms.
- [TSM R10, metodología](https://www.achs.cl/docs/librariesprovider2/default-document-library/presentacion-tsm-r10.pdf).
- [Markov y parametrización de regresión](https://chjackson.github.io/msm/reference/msm.html).
- [Cole y Hernán: supuestos y diagnóstico de pesos](https://pmc.ncbi.nlm.nih.gov/articles/PMC2732954/).
- [Diccionario por ola](outputs_tsm_pooled/diccionario_variables.csv).
- [Recuentos edad × sexo × categoría](outputs_tsm_pooled/recuentos_edad_sexo_categoria.csv).
- [Recuentos con educación y HED](outputs_tsm_pooled/recuentos_edad_sexo_educacion_HED_categoria.csv).
- [Matrices empíricas e IC](outputs_tsm_pooled/matrices_empiricas_IC.csv).
- [Modelos continuos, IC por persona](outputs_tsm_pooled/modelos_IC_por_persona.csv).

El HTML contiene estilos y figuras. Los CSV enlazados requieren conservar outputs_tsm_pooled/.
No se exportan registros individuales.

<!-- code:dictionary -->

## Verificación y límites del resultado

La ejecución comprueba datos reales, historia sin información futura, identidad de las personas,
sumas de probabilidades, ceros estructurales, escalas 12/15,7 e incertidumbre.
Estos controles no validan la ventana temporal, MAR, una distribución continua verdadera
ni la extrapolación a categorías sin observaciones. Los IC expresan incertidumbre estadística
condicional, no todos los errores de medición y transportabilidad.

<!-- code:validation -->
