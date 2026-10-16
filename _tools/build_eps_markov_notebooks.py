"""Build the Spanish and English EPS notebooks from one computational source."""
from pathlib import Path
import argparse
import hashlib
import nbformat as nb

parser = argparse.ArgumentParser()
parser.add_argument("--keep-outputs", action="store_true", help="Preserve executed cells only when their complete code is unchanged")
ARGS = parser.parse_args()

ROOT = next(p for p in Path(__file__).resolve().parents if (p / ".acc_root").is_file())
DIR = ROOT / "__andres_control"
CORE = (DIR / "eps_markov_core.R").read_text(encoding="utf-8")

def code(label, body):
    return nb.v4.new_code_cell(f'#| label: {label}\n.t0 <- Sys.time()\n' + body.strip() +
        '\ncat(sprintf("Elapsed: %.2f minutes\\n", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))\n')

sections = []
def section(es, en, label, body):
    sections.append((es, en, label, body))

section(r"""## Datos, población y estados

Se enlazan **las mismas personas** en VI→VII presencial y VII presencial→VIII. La edad es **18–65 al inicio de cada par**; el destino puede superar 65. No se extrapola a 15–17. La documentación de VII presencial señala cobertura 23+; los microdatos incluyen edad 22. Los dos grupos rotulados 18–29 no tienen idéntico soporte etario.

| Estado | Definición |
|---|---|
| N0 | No consume actualmente; no se observó consumo previo. **Historia incompleta, no abstinencia de vida.** |
| FD | No consume actualmente; se observó consumo en alguna ola anterior compatible. |
| C1 | Mujeres: >0–<20 g/día; hombres: >0–<40. |
| C2 | Mujeres: 20–<40; hombres: 40–<60. |
| C3 | Mujeres: 40–100; hombres: 60–100, incluidos los 100. |
| C4 | Más de 100 g/día en ambos sexos. |

**Calvo y abstinencia prolongada.** Se conserva una variable separada que exige dos respuestas negativas con separación mínima de cuatro años y ningún consumo previo observado. Solo usa historia disponible hasta esa entrevista. VI→VII no garantiza cuatro años; los primeros casos elegibles aparecen en VIII, sin una ola posterior para estimar sus transiciones. Por eso no se renombra N0 ni se inventa una fila de “iniciación”. Dos respuestas negativas tampoco prueban abstinencia continua entre entrevistas.

Para garantizar el mínimo de cuatro años se utiliza, conservadoramente, la cota inferior de separación entre periodos de trabajo de campo. La ausencia de orígenes elegibles se refiere a esta regla; no demuestra que ninguna persona haya pasado cuatro años sin beber.

**Consumo.** F13 pregunta por consumo de cada bebida sin ventana explícita; F14 sí pregunta frecuencia **durante el último mes**. F15 recoge cantidad típica. La conversión principal es:

$$\text{g/día}=\sum_b\frac{F_b\times Q_b\times12}{7}.$$

Para cada bebida $b$ (cerveza, vino o destilados), $F_b$ son los días de consumo por semana y $Q_b$ los tragos por día de consumo.

“Menos de un día por semana” se aproxima con 0,5 días. Se conserva 15,7 g/trago como sensibilidad. La fórmula frecuencia×cantidad/7 se apoya en Calvo (2020), pero **sumar bebidas es nuestra adaptación para ENPG/JRT**: el suplemento de Calvo utiliza el máximo por bebida para EPS. No se aplica `who_apc`. Los códigos originales se conservan en memoria y el diccionario exportado permite auditarlos.
""", r"""## Data, population and states

The **same people** are linked across VI→in-person VII and in-person VII→VIII. Eligibility is **age 18–65 at each pair's origin**; destination age may exceed 65. There is no extrapolation to ages 15–17. In-person VII documentation specifies ages 23+, while the microdata include age 22. The two groups labelled 18–29 do not have identical age support.

| State | Definition |
|---|---|
| N0 | Currently not drinking; no previous drinking observed. **Incomplete history, not lifetime abstention.** |
| FD | Currently not drinking; drinking observed at an earlier compatible interview. |
| C1 | Women: >0–<20 g/day; men: >0–<40. |
| C2 | Women: 20–<40; men: 40–<60. |
| C3 | Women: 40–100; men: 60–100, including 100. |
| C4 | More than 100 g/day in either sex. |

**Calvo and long-term abstention.** A separate flag requires two negative responses at least four years apart, with no previously observed drinking. It uses only history available by that interview. VI→VII does not guarantee four years; the first eligible flags occur at VIII, with no subsequent wave to estimate their transitions. N0 is therefore retained without inventing an initiation row. Two negative interviews do not establish continuous abstention between interviews.

The four-year minimum conservatively uses the lower bound of separation between fieldwork periods. Absence of eligible origins refers to this operational rule; it does not establish that no individual abstained for four years.

**Consumption.** F13 asks about beverage consumption without an explicit reference period; F14 explicitly asks frequency **during the last month**. F15 records typical quantity. The primary conversion is:

$$\text{g/day}=\sum_b\frac{F_b\times Q_b\times12}{7}.$$

For each beverage $b$ (beer, wine or spirits), $F_b$ is drinking days per week and $Q_b$ is drinks per drinking day.

“Less than one day per week” is approximated by 0.5 days. The 15.7 g/drink conversion is retained as a sensitivity. Calvo (2020) motivates frequency×quantity/7, but **summing beverages is our ENPG/JRT-oriented adaptation**: the supplement uses the maximum across beverages for EPS. No `who_apc` adjustment is applied. Original response codes remain in memory and an exported dictionary supports auditing.
""", "eps-data-design", r'''
ep_load()
ep_W <- ep_waves(12)
ep_risk <- ep_make_risk(ep_W)
ep_period_mass <- vapply(ep_periods,function(p) sum(ep_risk$period==p & ep_risk$complete),1)
names(ep_period_mass) <- ep_periods
ep_des <- ep_design()
ep_ip <- ep_ipw_fit(ep_risk)
ep_d <- ep_ipw_apply(ep_risk,ep_ip)
ep_check(nrow(ep_d)==length(unique(ep_d$row_id)),"One row per person and interval")
ep_check(all(ep_d$wn>0) && all(is.finite(ep_d$wn)),"Positive finite main weights")
ep_check(sum(ep_risk$longterm0)==0,"No fabricated strict long-term origin states")
ep_check(!any(ep_d$state0!="N0" & ep_d$state1=="N0") && !any(ep_d$state0=="N0" & ep_d$state1=="FD"),
 "Observed pairs respect the history-state transition map")
ep_counts <- as.data.frame(table(period=ep_d$period, sex=ep_d$sex, age_group=ep_d$age_group, state0=ep_d$state0))
names(ep_counts)[5] <- "n"
ep_save(ep_counts,"row_counts_state0_by_stratum")
ep_cohort <- do.call(rbind,lapply(ep_periods,function(p) {
 r<-ep_risk[ep_risk$period==p,]; d<-ep_d[ep_d$period==p,]
 data.frame(period=p, risk_set=nrow(r), usable_pairs=nrow(d), persons=length(unique(d$id)),
   age_min=min(d$age), age_max=max(d$age), weight_ESS=sum(d$wn)^2/sum(d$wn^2),
   main_weight=if(p=="VI_VII") "Official longitudinal + item/link-validity IPW" else "VII cross-sectional + follow-up/item IPW")
}))
ep_history_audit <- do.call(rbind,lapply(split(ep_W,ep_W$wave),function(d)
 data.frame(wave=d$wave[1], N0=sum(d$state=="N0",na.rm=TRUE), FD=sum(d$state=="FD",na.rm=TRUE),
  longterm_strict=sum(d$longterm), two_negative_proxy=sum(d$two_wave_negative))))
ep_design_audit <- data.frame(master_persons=nrow(ep_des$master),PSUs=length(unique(ep_des$master$psu)),
 strata=length(unique(ep_des$master$strata)), singleton_strata=sum(table(unique(ep_des$master[c("psu","strata")])$strata)==1),
 JKn_replicates=ncol(ep_des$multipliers), original_df=survey::degf(ep_des$survey), replicate_df=survey::degf(ep_des$replicate),
 known_VIII_deaths=sum(ep_W$wave=="VII_presencial" & ep_W$id %in% ep_dead8))
ep_save(ep_cohort,"cohort"); ep_save(ep_history_audit,"abstention_history_audit"); ep_save(ep_design_audit,"design_audit")
ep_save(as.data.frame(table(origin=ep_d$state0)),"origin_counts")
ep_show(ep_cohort,"Adjacent-wave analysis populations","Poblaciones de los pares consecutivos")
ep_show(data.frame(pairs=nrow(ep_d), persons=length(unique(ep_d$id)), persons_with_two_pairs=sum(table(ep_d$id)==2)),
 "Pairs and distinct people","Pares y personas distintas")
ep_show(ep_history_audit,"Past-only history flags; all available ages","Historia hasta cada entrevista; todas las edades disponibles")
ep_diagrams()
''')

section("""## Ponderación, IPW y diseño: qué hace cada uno

**VI→VII:** el ponderador longitudinal oficial ya corrige participación. Se agrega IPW únicamente por clasificación inicial/final faltante y enlace analítico incompatible. **VII→VIII:** no hay peso longitudinal específico de ese par; se usa el transversal de VII, con IPW por seguimiento y clasificación. Se excluyen fallecimientos conocidos en VIII. No se conoce completamente la supervivencia de quienes desaparecen.

La mezcla pooled fija la contribución relativa de cada periodo según sus pares observados iniciales. Es una mezcla analítica de dos poblaciones ponderadas; no es una única cohorte nacional anual. Las probabilidades de observación se limitan inferiormente a 0,02 y los pesos completos a sus percentiles 1/99. Los límites se estiman en entrenamiento y se reaplican a prueba.

**Incertidumbre principal:** jackknife estratificado JKn con `cluster_ID` y `strata_ID`. Se elimina/repondera una UPM por réplica, se mantienen juntos todos los pares de cada ID y se reajustan IPW y modelos. En estratos de una UPM se usa `survey.lonely.psu="adjust"`; no se afirma que esas UPM hayan sido seleccionadas con certeza. La convención `certainty` del informe EPS se muestra como sensibilidad.

Los IC JKn se calculan con las escalas de `survey`, centrados en el ajuste completo, y referencia t con UPM menos estratos. **No son percentiles de réplicas bootstrap.** Para probabilidades se usa transformación logit; en los límites exactos 0/1 se usan límites normales acotados. El bootstrap de **1.000 réplicas que remuestrean personas completas** queda como sensibilidad, con IPW reajustado. No se suma una segunda corrección por ID encima del JKn. Asumir Markov no hace independientes los pares de una misma persona.

La aproximación usa el diseño publicado, pero no reconstruye probabilidades de selección por etapa, FPC ni la incertidumbre interna de los ponderadores oficiales. Kish ESS solo describe dispersión de pesos: no multiplica los IC.
""", """## Weights, IPW and sampling design

**VI→VII:** the official longitudinal weight already adjusts participation. Additional IPW addresses only missing baseline/final classification and incompatible analytical links. **VII→VIII:** no pair-specific official longitudinal weight is available; VII cross-sectional weights are combined with follow-up/item-response IPW. Known VIII deaths are excluded. Survival is not completely observed among those lost to follow-up.

The pooled mixture fixes each period's relative contribution at its initial observed-pair count. This is an analytical mixture of two weighted populations, not a single national annual cohort. Observation probabilities have a 0.02 floor and completed weights are clipped at the 1st/99th percentiles. Thresholds are learned in training and applied to held-out data.

**Primary uncertainty:** stratified JKn using `cluster_ID` and `strata_ID`. Each replicate deletes/reweights a PSU, keeps all pairs of each ID together, and refits IPW and outcome models. Singleton strata use `survey.lonely.psu="adjust"`; their PSUs are not asserted to have certainty inclusion. The EPS report's `certainty` convention is a sensitivity.

JKn intervals use `survey` replication scales, centre on the full estimate and use a t reference with PSU-minus-strata degrees of freedom. **They are not bootstrap percentiles.** Probability intervals use a logit transformation; exact 0/1 boundaries use bounded normal limits. A **bootstrap with 1,000 replicates of complete person trajectories** is retained as a sensitivity, with IPW refitted. No second ID correction is added on top of JKn. A Markov assumption does not make one person's overlapping pairs independent.

This uses the published design but does not reconstruct stage-specific inclusion probabilities, FPCs or uncertainty in the official weights themselves. Kish ESS describes weight dispersion only; it does not multiply the confidence intervals.
""", "eps-weight-audit", r'''
ep_show(ep_design_audit,"Published design and replication","Diseño publicado y replicación")
ep_weight_audit <- do.call(rbind,lapply(split(ep_d,ep_d$period),function(d)
 data.frame(period=d$period[1], min_probability=min(d$p_obs),median_weight=stats::median(d$wn),max_weight=max(d$wn),
 clipped=sum(d$untrimmed!=d$wcorrected), weight_ESS=sum(d$wn)^2/sum(d$wn^2))))
ep_save(ep_weight_audit,"ipw_audit")
ep_singleton <- ep_taylor_sensitivity(); ep_save(ep_singleton,"singleton_convention_sensitivity")
ep_show(ep_weight_audit,"Weight diagnostics; ESS does not include clustering","Diagnóstico de pesos; ESS no incorpora conglomerados")
ep_show(ep_singleton,"Singleton sensitivity, descriptive fixed-IPW prevalence","Sensibilidad de estratos con una UPM; prevalencia con IPW fijo")
''')

section("""## Modelos y comparación justa

**NC significa no consumo actual: N0+FD.** El destino de cantidad se modela en cinco categorías, NC y C1–C4. Después, la historia del origen distingue N0 de FD entre quienes no beben, produciendo las matrices de seis estados.

Las matrices A son la referencia empírica con contracción; las celdas pequeñas toman información de grupos más amplios. La fuerza de contracción se elige **dentro del entrenamiento**. La versión por educación se compara, pero no se impone.

Gamma, lognormal, multinomial y ordinal reciben la misma información: estado y gramos previos, sexo, edad, interacción sexo×edad, periodo y educación. Los modelos de dos partes comparten la ecuación de participación. JRT queda como **referencia separada con su especificación**, no como comparación pura de distribuciones.

Gamma/lognormal producen una distribución positiva de cantidad. Las probabilidades C1–C4 se obtienen **integrando entre los cortes**, no reclasificando solo la media. La dispersión se estima con pesos normalizados: multiplicar los pesos por diez debe dejar idénticas las predicciones.

**Educación:** se compara ausencia, efecto ordinal y sus interacciones con consumo inicial, sexo y edad. Codificar 0/1/2 presupone distancias iguales entre niveles; no equivale a años de estudio. Los faltantes tienen un indicador separado. La alternativa multinomial de cantidad permite comparar el ordinal con una opción sin odds proporcionales, mediante predicción fuera de muestra, sin un p espurio de likelihood compuesto.

Un modelo paramétrico comparte información y permite extrapolar suavemente. Eso puede ayudar con C3/C4, pero la precisión depende de acertar la forma del modelo: **no crea observaciones en la cola**. El multinomial también es paramétrico. Gamma/lognormal aprovechan la cantidad continua y restringen su distribución; pueden reducir variabilidad a costa de sesgo si esa forma es incorrecta. No son automáticamente más eficientes.
""", """## Models and fair comparison

**NC means current non-consumption: N0+FD.** Destination quantity is modelled in five categories, NC and C1–C4. Origin history then distinguishes N0 from FD among non-drinkers, yielding six-state matrices.

Matrices A provide the empirical reference with shrinkage: small cells borrow information from broader groups. Shrinkage strength is selected **inside training**. An education-stratified version is compared rather than assumed.

Gamma, lognormal, multinomial and ordinal models receive the same information: previous state and grams, sex, age, sex×age interaction, period and education. Two-part models share the participation equation. JRT is a **separate reference specification**, not a pure distribution-family comparison.

Gamma/lognormal predict a positive amount distribution. C1–C4 probabilities are obtained **by integrating between cutpoints**, not by classifying only the predicted mean. Dispersion uses normalized weights: multiplying weights by ten must leave predictions unchanged.

**Education:** compare no education, an ordinal effect, and its interactions with baseline drinking, sex and age. Coding 0/1/2 assumes equally spaced levels; it does not represent years of schooling. Missing education has a separate indicator. A multinomial amount model compares the ordinal with an option without proportional odds through held-out prediction, without a spurious composite-likelihood p-value.

Parametric models share information and support smooth extrapolation. This can help with C3/C4, but precision depends on the model's shape assumptions: **it does not create tail observations**. Multinomial regression is also parametric. Gamma/lognormal use continuous quantity and restrict its distribution; they can reduce variability at the cost of bias when that shape is incorrect. Greater efficiency is not automatic.
""", "eps-model-validation", r'''
ep_tunes <- list(ep_tune(ep_risk,FALSE),ep_tune(ep_risk,TRUE))
ep_k <- vapply(ep_tunes,function(x) x$k,1)
ep_save(rbind(ep_tunes[[1]]$scores,ep_tunes[[2]]$scores),"full_fit_shrinkage_tuning")
ep_fits <- lapply(stats::setNames(names(ep_models),names(ep_models)),function(nm) ep_fit(ep_d,nm,ep_k[if(nm=="A_education") 2 else 1]))
ep_scale_test <- lapply(c("Gamma","Lognormal","Multinomial","Ordinal_two_part"),function(nm) {
 d<-ep_d; d$wn<-10*d$wn
 diff<-max(abs(ep_prob(ep_fits[[nm]],ep_d)-ep_prob(ep_fit(d,nm,ep_k[1]),ep_d)))
 ep_check(diff<1e-7,paste("Weight-scale invariance",nm))
 data.frame(model=nm,max_absolute_difference=diff)
})
ep_save(do.call(rbind,ep_scale_test),"weight_scale_invariance")
ep_cv_result <- ep_cv(ep_risk)
ep_cvtab <- ep_cv_tables(ep_cv_result)
ep_contrasts <- ep_score_contrasts(ep_cvtab)
ep_save(ep_cv_result$audit,"CV_fold_audit"); ep_save(ep_cv_result$tuning,"CV_inner_tuning")
ep_save(ep_cvtab$scores,"CV_repeated_scores"); ep_save(ep_cvtab$summary,"cv_scores")
ep_save(ep_contrasts,"CV_paired_comparisons")
ep_show(ep_cvtab$summary,"Held-out category scores; lower log loss/Brier is better","Puntajes de categorías fuera de muestra; menor log loss/Brier es mejor",5)
ep_show(ep_contrasts[,1:8],"Paired comparisons; uncertainty uses PSU and strata","Comparaciones pareadas; incertidumbre con UPM y estratos",5)
''')

section("""## ¿Quién gana y por cuánto?

La tabla anterior se calcula de nuevo: **no conserva el ranking de la versión antigua**. Se usan cinco pliegues por persona, tres particiones repetidas e IPW estimado sin ver a las personas de prueba. A selecciona su contracción en tres pliegues internos.

La diferencia pareada de log loss es modelo menos referencia: un valor negativo favorece al primero. Si el IC cruza cero, esta evaluación no distingue claramente sus puntajes. También se informa el cambio relativo en la probabilidad geométrica asignada a la categoría observada y el cambio medio en las probabilidades de categoría, en puntos porcentuales. Eso ayuda a dimensionar las milésimas; no se inventa un umbral clínico de equivalencia.

Los IC de puntajes consideran UPM/estratos pero están **condicionados a las predicciones ya entrenadas**. Las tres repeticiones muestran sensibilidad a la partición, no una distribución independiente de tres estudios. La decisión debe mirar calibración y colas, además del puntaje global.

El menor puntaje medio identifica al mejor candidato en esta comparación. No demuestra superioridad frente a cada competidor: los contrastes pareados informados no cubren todas las parejas de modelos. Una ventaja detectable frente a Gamma puede seguir siendo pequeña en términos prácticos.
""", """## Which model wins, and by how much?

The preceding table is recomputed: **the old version's ranking is not retained**. Validation uses five person-blocked folds, three repeated partitions, and IPW learned without the held-out people. Matrix A selects shrinkage in three inner folds.

Paired log loss is model minus reference: negative favours the first model. If the interval crosses zero, this evaluation does not clearly distinguish their scores. The relative change in geometric probability assigned to observed categories and mean change in class probabilities, in percentage points, quantify the size of small score differences. No clinical equivalence margin is invented.

Score intervals use PSU/strata but are **conditional on already-trained predictions**. Three repetitions show partition sensitivity, not three independent studies. Decisions should consider calibration and tails as well as overall scores.

The lowest average score identifies the leading candidate in this comparison. It does not establish superiority over every competitor: the reported paired contrasts do not cover every model pair. A detectable advantage over Gamma can still be small in practical terms.
""", "eps-calibration", r'''
ep_cal <- do.call(rbind,lapply(c("A","Gamma","Lognormal","Ordinal_two_part"),function(nm) {
 P<-ep_cvtab$prob[[nm]]
 data.frame(model=nm,category=ep_Y,
  observed=vapply(ep_Y,function(s) stats::weighted.mean(ep_d$y1==s,ep_cvtab$w),1),
  predicted=colSums(P*ep_cvtab$w)/sum(ep_cvtab$w))
}))
ep_save(ep_cal,"calibration_destination")
ep_show(ep_cal,"Held-out observed and predicted shares","Proporciones observadas y predichas fuera de muestra",4)
ep_model_answer <- data.frame(best_logloss=ep_cvtab$summary$model[1],
 best_brier=ep_cvtab$summary$model[which.min(ep_cvtab$summary$brier)],
 lognormal_minus_gamma=ep_contrasts$difference[1],lower=ep_contrasts$lower[1],upper=ep_contrasts$upper[1],
 clear_gamma_lognormal_separation=ep_contrasts$lower[1]>0 | ep_contrasts$upper[1]<0)
ep_save(ep_model_answer,"model_decision_summary"); ep_show(ep_model_answer,"Current result, not a predetermined winner","Resultado actual, sin ganador predeterminado",5)
''')

section("""## Matrices, IC y parámetros exportados

Cada fila promedia predicciones **entre las personas realmente observadas en ese origen**, conservando sus gramos y educación. Ya no se reemplaza la cantidad previa por una mediana sintética. Una fila sin personas se marca NA; una transición estructuralmente imposible se distingue de una fila no observada.

El JKn reajusta los modelos y el IPW. La contracción y la familia elegidas se mantienen fijas: los IC son condicionales a esa selección. Si una fila desaparece en alguna réplica, se informa y no se fabrica su IC. Los coeficientes Gamma/lognormal incluyen SE de replicación, no los SE ordinarios de `summary(glm)`.
""", """## Matrices, confidence intervals and exported parameters

Each row averages predictions **among people actually observed in that origin**, retaining their previous grams and education. Previous quantity is no longer replaced by a synthetic median. Rows without people are NA; structural impossibility is distinct from an unobserved row.

JKn refits outcome models and IPW. Selected shrinkage and model family remain fixed, so intervals are conditional on those choices. If an origin disappears in a replicate, it is reported without fabricating an interval. Gamma/lognormal coefficient SEs use replication rather than ordinary `summary(glm)` output.
""", "eps-design-inference", r'''
ep_points <- ep_targets(ep_d,ep_fits[ep_main_models])
ep_pool_tab <- do.call(rbind,lapply(c("A","Gamma","Lognormal"),function(nm) {
 d<-ep_d; d$pooled<-"All"
 ep_matrices(d,ep_prob(ep_fits[[nm]],d),nm,by="pooled")
}))
ep_jk <- ep_jackknife()
ep_jkmat <- do.call(rbind,lapply(ep_jk,function(x) x$target[names(ep_vector(ep_points))]))
ep_ci <- cbind(ep_points,ep_interval(ep_vector(ep_points),ep_jkmat))
ep_save(ep_ci,"transition_matrices_design_CI")
ep_engine <- ep_coef(ep_fits)
ep_coef_names <- paste(ep_engine$model,ep_engine$component,ep_engine$term,sep="::")
ep_engine <- cbind(ep_engine,ep_interval(ep_engine$estimate,do.call(rbind,lapply(ep_jk,function(x) x$coefficients[ep_coef_names])),probability=FALSE))
ep_save(ep_engine,"engine_coefficients_design_CI")
ep_show(ep_ci[ep_ci$model=="Gamma" & ep_ci$from=="C1" & ep_ci$to=="C1",c("period","sex","age_group","n_origin","estimate","lower","upper")],
 "Example: remaining in C1, Gamma model","Ejemplo: permanecer en C1, modelo Gamma")
ep_person <- ep_bootstrap_person()
ep_personmat <- do.call(rbind,lapply(ep_person,function(x) x$target))
ep_perpoint <- ep_points[ep_points$model %in% c("Gamma","Lognormal"),]
ep_person_ci <- cbind(ep_perpoint,ep_interval(ep_vector(ep_perpoint),ep_personmat,"person"))
ep_save(ep_person_ci,"transition_matrices_person_CI")
ep_mc <- do.call(rbind,lapply(c(100,250,500,1000),function(B) {
 s<-apply(ep_personmat[seq_len(B),,drop=FALSE],2,stats::sd)
 ref<-apply(ep_personmat,2,stats::sd); good<-is.finite(s)&is.finite(ref)&ref>0
 data.frame(replicates=B,median_SE_ratio_to_1000=stats::median(s[good]/ref[good]),
  p90_absolute_relative_difference=as.numeric(stats::quantile(abs(s[good]/ref[good]-1),.9)))
}))
ep_save(ep_mc,"bootstrap_stability"); ep_show(ep_mc,"Bootstrap stability; 1,000 whole-person replicas","Estabilidad del bootstrap; 1.000 réplicas por persona")
''')

section("""## Transporte, historia anterior y rank matching

Se evalúan ambos sentidos **entre periodos**, siempre prediciendo hacia adelante dentro de cada par: entrenar VI→VII y evaluar VII→VIII; y entrenar VII→VIII y evaluar VI→VII. Se excluyen del entrenamiento todas las personas de prueba, se usa soporte común 23–65 y se informa la exclusión de FD donde el entrenamiento no tiene ejemplos. Nunca se transforma FD en N0 silenciosamente.

**No es factible validar alcohol en V/2012 con los archivos entregados.** Sus 21 bases no contienen variables/etiquetas de alcohol; el enlace RAR suministrado contiene documentación, no nuevas variables. Además, el dossier oficial (p. 23) desaconseja inferencias estadísticas con esa ronda. Reconstruir V sería un escenario sin validación, no retrotransporte observado.

El análisis de historia compara modelos ajustados por estado y gramos actuales, sexo, edad y educación, **con y sin la información de VI**. Se repite con educación interactuada. La comparación se restringe a historias completas de tres olas. Chapman–Kolmogorov queda como diagnóstico marginal de composición, sin p de “rechazo de Markov”.

Para aislar el efecto del rank matching se usan las **mismas personas, pesos, grupos iniciales y distribuciones marginales** del panel observado. Solo se reemplaza la asociación individual por acoplamiento de rangos. Una mayor permanencia puede aparecer por construcción aunque las marginales coincidan exactamente.

En las figuras se conservan los códigos: `Men` = hombres, `Women` = mujeres, `Observed_panel` = panel observado y `Rank_matching` = emparejamiento por rangos. `NC` reúne N0 y FD.
""", """## Transport, earlier history and rank matching

Both **period directions** are evaluated while always predicting forward within a pair: train VI→VII/test VII→VIII, and train VII→VIII/test VI→VII. All test persons are excluded from training; ages are restricted to common support 23–65; unsupported FD origins are reported. FD is never silently recoded to N0.

**Alcohol validation in V/2012 is not feasible with the delivered files.** Its 21 databases contain no alcohol variables/labels; the supplied RAR contains documentation, not additional alcohol variables. The official dossier (p. 23) also advises against statistical inference with that round. Reconstructing V would be an unvalidated scenario rather than observed reverse-period transport.

The history analysis compares models adjusted for current state and grams, sex, age and education, **with and without VI history**. It is repeated with education interactions and restricted to complete three-wave histories. Chapman–Kolmogorov is a marginal composition diagnostic without a formal “Markov rejection” p-value.

To isolate rank matching, the benchmark uses **the same people, weights, baseline groups and endpoint margins** as the observed panel. Only individual association is replaced by rank coupling. Persistence can increase by construction even when margins match exactly.
""", "eps-transport-history", r'''
ep_trans <- ep_transport(); ep_save(ep_trans$scores,"transport_scores");ep_save(ep_trans$coverage,"transport_support")
ep_transport_summary <- do.call(rbind,lapply(split(ep_trans$scores,paste(ep_trans$scores$direction,ep_trans$scores$model)),function(z)
 data.frame(direction=z$direction[1],model=z$model[1],logloss=stats::weighted.mean(z$logloss,z$weight_sum),
  brier=stats::weighted.mean(z$brier,z$weight_sum),n=sum(z$n))))
ep_save(ep_transport_summary,"transport_summary")
ep_show(ep_transport_summary,
 "Person-disjoint forward and reverse-period transport","Transporte y retrotransporte sin compartir personas",4)
ep_hist <- ep_history_check(); ep_save(ep_hist,"adjusted_history_validation")
ep_show(ep_hist,"Does earlier history add predictive information after adjustment?","¿La historia anterior aporta información después del ajuste?",5)
ep_ck_tab <- ep_ck();ep_save(ep_ck_tab,"chapman_kolmogorov_descriptive")
ep_rank_tab <- ep_rank(ep_d);ep_save(ep_rank_tab,"rank_matching_vs_panel")
ep_show(ep_rank_tab[ep_rank_tab$from=="C1" & ep_rank_tab$to=="C1",],
 "C1 persistence: matched margins, different dependence","Permanencia en C1: mismas marginales, distinta dependencia",3)
''')

section(r"""## Probabilidades anuales: una capa de modelación

Se ajusta un generador continuo común a ambos intervalos, con tasas no negativas fuera de la diagonal:

$$P(\Delta)=\exp(Q\Delta),\qquad P(1)=\exp(Q).$$

Las tasas son homogéneas por supuesto. La capa anual no transforma cuatro años observados en un año observado. Se comparan inicios y penalizaciones, se verifica que las filas sumen uno y que se cumpla la composición del mismo generador. El ajuste anual es **pooled**, sin pretender identificar generadores separados en C4 por edad/sexo. Los IC usan el reajuste del generador en cada réplica JKn, con penalización fija.

Estas matrices son candidatos para calibración ENPG. Un motor que cambie covariables o tasas con la edad necesita una validación adicional de sus trayectorias; la identidad matricial comprobada aquí no valida ese motor completo.

**Estabilidad:** la tabla de sensibilidad compara el ajuste principal con varios reinicios y penalizaciones. Objetivos casi iguales pueden producir probabilidades anuales diferentes. Los IC condicionan a la inicialización y penalización principales; no cubren toda esa ambigüedad. La síntesis inicial muestra la magnitud observada. Si es grande, esta capa se conserva como exploratoria y las probabilidades entre olas siguen siendo el resultado principal.

**Historia observada y latente:** el ajuste anual compara N0+FD con el destino observado sin consumo. Puede representar una trayectoria N0→consumo→FD entre entrevistas que no observamos. Por tanto, FD en esta capa anual incluye historia imputada por el modelo; FD en las olas de encuesta exige consumo previo observado. Esa separación depende de supuestos y no queda identificada por los destinos agrupados.
""", r"""## Annual probabilities: an additional modelling layer

A common continuous-time generator is fitted to both intervals, with nonnegative off-diagonal rates:

$$P(\Delta)=\exp(Q\Delta),\qquad P(1)=\exp(Q).$$

Time-homogeneous rates are an assumption. Annualization does not turn an observed four-year interval into observed one-year transitions. Starting values and penalties are compared; row sums and composition under the same generator are checked. Annual estimates are **pooled**, without claiming separate age/sex generators are identified for C4. Confidence intervals refit the generator in each JKn replicate, conditional on its fixed penalty.

These matrices are candidates for ENPG calibration. A simulation that changes covariates or rates with age needs additional trajectory validation; the matrix identity checked here does not validate that full engine.

**Stability:** the sensitivity table compares the primary fit with multiple restarts and penalties. Nearly equal objectives can yield different annual probabilities. Intervals condition on the primary initialization and penalty and do not cover this entire ambiguity. The opening summary reports its observed magnitude. Large differences keep this layer exploratory, with between-wave probabilities remaining the primary result.

**Observed and latent history:** annual fitting compares N0+FD with the observed non-drinking destination. It can represent an unobserved N0→drinking→FD path between interviews. Annual FD therefore includes model-imputed drinking history, whereas survey-wave FD requires observed previous drinking. This distinction depends on assumptions and is not identified by the collapsed destinations.
""", "eps-annual-layer", r'''
ep_annual_full <- lapply(ep_fits[c("A","Gamma","Lognormal")],function(f) ep_annual(ep_d,f,starts=.05,check_gradient=TRUE))
ep_ann_point <- unlist(lapply(ep_annual_full,function(x) as.vector(x$P)))
ep_ann_rep <- do.call(rbind,lapply(ep_jk,function(x) x$annual))
ep_ann <- do.call(rbind,lapply(names(ep_annual_full),function(nm) {
 z<-ep_annual_full[[nm]]
 ep_check(max(abs(rowSums(z$P)-1))<1e-8 && min(z$P)>-1e-10,paste("Annual stochastic matrix",nm))
 ep_check(z$semigroup_error<1e-8,paste("Annual semigroup",nm))
 data.frame(model=nm,from=rep(ep_ST,6),to=rep(ep_ST,each=6),estimate=as.vector(z$P),
  weighted_reconstruction_RMSE=z$rmse,optimizer_code=z$convergence,semigroup_error=z$semigroup_error)
}))
ep_ann <- cbind(ep_ann,ep_interval(ep_ann_point,ep_ann_rep))
ep_save(ep_ann,"annual_pooled_matrices_design_CI")
ep_ann_sens <- do.call(rbind,lapply(c(1e-5,5e-5,2e-4),function(pen) {
 z<-ep_annual(ep_d,ep_fits$Gamma,lambda=pen)
 data.frame(penalty=pen,weighted_reconstruction_RMSE=z$rmse,
  start_objective_range=z$start_objective_range,max_annual_difference=max(abs(z$P-ep_annual_full$Gamma$P)),
  optimizer_code=z$convergence)
}))
ep_save(ep_ann_sens,"annual_generator_sensitivity")
ep_show(ep_ann[ep_ann$model=="Gamma" & ep_ann$from==ep_ann$to,],
 "Annual staying probabilities: model-derived, pooled Gamma","Permanencia anual: resultado modelado, Gamma agrupado")
ep_show(ep_ann_sens,"Annual reconstruction sensitivity","Sensibilidad de reconstrucción anual",5)
''')

section("""## Conversión, pesos alternativos y señal de cantidad alta

Se reajustan Gamma y lognormal con 12 y 15,7 g/trago. La diferencia entre conversiones cuantifica sensibilidad de clasificación, no valida por sí sola el tamaño del trago. También se compara peso base frente a peso con IPW, manteniendo el propósito longitudinal de VI→VII; no se usa el peso de VI–VII–VIII como si fuera específico VII→VIII.

La señal de cantidad habitual **≥5 tragos en hombres / ≥4 en mujeres**, en alguna bebida, permanece separada. No es una medición de episodios HED ENPG de 30 días. No se interpreta la ausencia de cantidad en una bebida como ausencia de señal. Su regresión usa diseño EPS, aunque sus IC descriptivos condicionan a los IPW ya estimados; no entra como predictor principal de volumen ni se exporta como HED validado.
""", """## Conversion, alternative weights and high typical quantity

Gamma and lognormal are refitted at 12 and 15.7 g/drink. Their difference measures classification sensitivity; it does not validate drink size on its own. Base weights are also compared with IPW-corrected weights, retaining VI→VII's longitudinal-weight purpose; the VI–VII–VIII weight is not treated as pair-specific VII→VIII weighting.

The typical-quantity signal **≥5 drinks for men / ≥4 for women**, in any beverage, remains separate. It is not observed ENPG 30-day HED. Missing beverage quantity is not treated as absence of the signal. Its regression uses EPS design, although descriptive intervals condition on estimated IPW; it is not a main volume predictor or an export of validated HED.
""", "eps-sensitivities", r'''
ep_sensitivity <- do.call(rbind,lapply(c(12,15.7),function(g) {
 r<-ep_make_risk(ep_waves(g)); d<-ep_ipw_apply(r,ep_ipw_fit(r))
 do.call(rbind,lapply(c("Gamma","Lognormal"),function(nm) {
  pr<-ep_prob(ep_fit(d,nm),d)
  data.frame(grams_per_drink=g,model=nm,quantity=c("Drinking_t1","Escalation_from_C1","C3_C4_t1"),
   probability=c(stats::weighted.mean(1-pr[,1],d$wn),
    stats::weighted.mean(rowSums(pr[d$state0=="C1",3:5,drop=FALSE]),d$wn[d$state0=="C1"]),
    stats::weighted.mean(rowSums(pr[,4:5,drop=FALSE]),d$wn)))
 }))
}))
ep_save(ep_sensitivity,"conversion_sensitivity")
ep_weight_sens <- do.call(rbind,lapply(c("base_only","base_plus_IPW"),function(s) {
 d<-ep_d
 if(s=="base_only") for(p in ep_periods) {ii<-d$period==p;d$wn[ii]<-d$wbase[ii]/sum(d$wbase[ii])*ep_period_mass[[p]]}
 pr<-ep_prob(ep_fit(d,"Gamma"),d)
 data.frame(scenario=s,current_t1=stats::weighted.mean(1-pr[,1],d$wn),
  C3_C4_t1=stats::weighted.mean(rowSums(pr[,4:5]),d$wn))
}))
ep_save(ep_weight_sens,"weight_refit_sensitivity")
ep_hed_result<-ep_hed();ep_save(ep_hed_result$coef,"typical_quantity_signal_design_coefficients")
ep_save(ep_hed_result$proportions,"typical_quantity_signal_by_category")
ep_show(ep_sensitivity,"Conversion sensitivity, refitted models","Sensibilidad a la conversión, modelos reajustados",4)
ep_show(ep_weight_sens,"Refitted weight sensitivity","Sensibilidad de pesos con reajuste",4)
ep_plots()
''')

section("""## Revisión y reproducibilidad

El informe `eps_markov_review.md` documenta los hallazgos, correcciones y límites pendientes. La revisión incluye clases ausentes, etiquetas FD/N0, dispersión invariante a la escala de pesos, ausencia de fuga de personas, soporte de filas, conservación de marginales del rank matching y propiedades del generador.

Las versiones ES/EN se generan desde el mismo código y se ejecutan en sesiones nuevas con las mismas semillas. El chequeo externo compara las tablas numéricas exportadas; el resultado se adjunta después de ambas ejecuciones. Reproducir resultados no prueba que los supuestos estadísticos sean verdaderos.

**Para microsimulación:** mantener Gamma y lognormal como candidatos, A como referencia y categorías C1–C4 sin cambios. La calibración a ENPG y la validación independiente siguen pendientes. La cola escasa, la historia incompleta y la varianza no identificable de estratos singleton limitan la interpretación.
""", """## Review and reproducibility

`eps_markov_review.md` documents findings, fixes and remaining limitations. Checks include absent classes, FD/N0 labels, weight-scale-invariant dispersion, disjoint person folds, origin support, rank-matching margins and generator properties.

ES/EN versions are built from the same computation and executed in fresh sessions with identical seeds. An external check compares exported numerical tables; its result is attached after both executions. Reproducing results does not prove the statistical assumptions true.

**For microsimulation:** retain Gamma and lognormal as candidates, A as reference, and unchanged C1–C4 definitions. ENPG calibration and independent validation remain pending. Sparse tails, incomplete history and unidentified singleton-stratum variance constrain interpretation.
""", "eps-reproducibility", r'''
ep_checks_table<-data.frame(check=names(ep_checks),passed=unlist(ep_checks),row.names=NULL)
ep_save(ep_checks_table,"analysis_checks")
ep_save(data.frame(seed=ep_seed,person_bootstrap_replicates=ep_B,CV_repetitions=ep_repeats,
 JKn_replicates=ncol(ep_des$multipliers),same_ID_same_multiplier=TRUE),"analysis_configuration")
ww<-as.data.frame(table(ep_warnings),stringsAsFactors=FALSE); names(ww)<-c("warning","n")
ep_save(ww,"fit_warnings")
ep_check(all(ep_checks_table$passed),"All recorded checks passed")
ep_show(ep_checks_table,"Executed checks on real EPS data","Comprobaciones ejecutadas con datos EPS reales")
si<-utils::capture.output(utils::sessionInfo())
writeLines(si[!grepl("[A-Za-z]:[/\\\\]",si)],file.path(ep_out,"session_info.txt"))
''')

references = """## References / Referencias

- Calvo E et al. (2020). *Cross-country and historical variation in alcohol consumption among older men and women*. [Article, Table 2](https://pmc.ncbi.nlm.nih.gov/articles/PMC7585691/) and [supplement, Table S2](https://ars.els-cdn.com/content/image/1-s2.0-S0376871620303847-mmc1.docx).
- Calvo et al. (2021). [Alcohol transitions and harmonized history definitions](https://pmc.ncbi.nlm.nih.gov/articles/PMC8131222/).
- EPS official design: `_eps/notes/34_Informe Técnico EPS VIII Ronda.txt`, sections on longitudinal weights and sampling variance; `_eps/notes/16_EPS - Informe Metodologico-Muestreo, Atrición, Factores, Errores Muestrales.txt`.
- EPS V limitations: `_eps/docs/2012/Dossier_Resultados_VRondaEPS2012.pdf`, p. 23; [official documentation archive](https://www.previsionsocial.gob.cl/sps/download/estudios-previsionales/encuesta-de-proteccion-social/bases-de-datos-eps/instrucciones-bd-eps-2012.rar).
- Lumley, `survey`: [singleton strata](https://r-survey.r-forge.r-project.org/survey/exmample-lonely.html), [JKn replication](https://r-survey.r-forge.r-project.org/pkgdown/docs/reference/as.svrepdesign.html), [replicate variance](https://r-survey.r-forge.r-project.org/pkgdown/docs/reference/svrVar.html).
- JRT comparison: `jrt/simulacion/Alcohol Transitions FINAL.R`; harmonization source: `eps_alcohol_prevalencia_persistencia.ipynb`.
- Architecture for subsequent microsimulation integration: [Kilian et al. (2025), Lancet Public Health](https://pubmed.ncbi.nlm.nih.gov/40885207/), DOI 10.1016/S2468-2667(25)00165-3; [SIMAH release 0.1.1](https://doi.org/10.5281/zenodo.15641639). This notebook estimates Chilean transition components; it does not execute SIMAH or import US parameter values.
"""

for lang in ("es", "en"):
    filename = "eps_markov_transiciones.ipynb" if lang == "es" else "eps_markov_transitions_EN.ipynb"
    title = "EPS: transiciones de consumo de alcohol" if lang == "es" else "EPS: alcohol consumption transitions"
    sub = "Diseño muestral, modelos agrupados y validación por persona" if lang == "es" else "Survey design, pooled models and person-blocked validation"
    first = f'''---
title: "{title}"
subtitle: "{sub}"
author: "Andres Gonzalez Santa Cruz"
lang: {lang}
format:
  html:
    theme: journal
    css: [_lib/styles.css, _lib/prediction_metrics_compact.css]
    toc: true
    toc-location: left
    toc-depth: 2
    number-sections: false
    code-fold: true
    code-summary: "{'Ver código R' if lang=='es' else 'Show R code'}"
    code-tools: true
    embed-resources: true
    self-contained: true
    html-math-method: mathml
execute:
  echo: true
  warning: false
  error: false
---

{'**Lectura rápida:** los resultados se recalculan con el diseño EPS; cada persona mantiene juntos todos sus pares. Gamma y lognormal se comparan con la misma información, conservando N0, FD y C1–C4.' if lang=='es' else '**Quick orientation:** results are recomputed using EPS design; all pairs of each person stay together. Gamma and lognormal are compared using the same information, retaining N0, FD and C1–C4.'}
'''
    setup = f'''ep_lang <- "{lang}"
if (.Platform$OS.type == "windows") invisible(Sys.setlocale("LC_ALL", "English_United States.utf8")) else invisible(Sys.setlocale("LC_CTYPE", ""))
suppressMessages(here::i_am("__andres_control/{filename}"))
required <- c("survey","haven","nnet","MASS","ggplot2","jsonlite","IRdisplay","htmltools","knitr")
stopifnot(all(vapply(required,requireNamespace,logical(1),quietly=TRUE)))
ep_checks <- list(); ep_warnings <- character()
'''
    cells = [nb.v4.new_markdown_cell(first),code("eps-session-setup",setup),code("eps-shared-definitions",CORE)]
    for es, en, label, body in sections:
        cells.extend([nb.v4.new_markdown_cell(es if lang=="es" else en),code(label,body)])
    cells.append(nb.v4.new_markdown_cell(references))
    doc = nb.v4.new_notebook(cells=cells,metadata={
        "kernelspec":{"display_name":"R","language":"R","name":"ir"},
        "language_info":{"name":"R","file_extension":".r","mimetype":"text/x-r-source"},
        "eps_revision":{"core_sha256":hashlib.sha256(CORE.encode()).hexdigest(),"language":lang}})
    if ARGS.keep_outputs and (DIR/filename).exists():
        old = nb.read(DIR/filename, as_version=4)
        executed = {c.source: c for c in old.cells if c.cell_type == "code"}
        doc.cells = [executed.get(c.source,c) if c.cell_type=="code" else c for c in doc.cells]
    nb.write(doc,DIR/filename)
    print(filename, len(cells), "cells")
