# Plan de trabajo post-reunión con ACC — 17-sep-2026

Fuente: lineamientos de ACC (reunión 16-sep) + notas propias de Andrés. Cuando hay diferencia, manda ACC. Rutas relativas a la raíz del proyecto (`.acc_root`). Supuestos de trabajo marcados con ⚠ (no se discutieron con ACC).

> **Actualizado 21-sep-2026.** Cambios marcados con `[21-sep]` en el texto. Si tu copia local cambió después del 17-sep, no la sobrescribas: pega sólo este bloque al inicio.
>
> **Del archivo de respuestas del 20-sep** (`microsim_respuestas_preguntas_2026-09-20.md` §1–§15 y Addendum 1):
> 1. Proyección de prevalencias: **hold-last por celda** como escenario central (propuesta). La tendencia lineal entrenada 2012–2020 falla 16/16 celdas en 2022–2024 (+9,75 pts). Todo lo posterior a 2024 = condicional.
> 2. Reproducir las olas usadas para construir el motor es calibración, no validación. Validar requiere ola 2026, encuesta independiente, APC o panel.
> 3. Diseño ENPG por ola: 2016 PSU reconstruida (comuna + distrito + zona + manzana); 2020 sin conglomerado; 2022 estrato = `COD_COMUNA` (exacto); 2024 `UPM` + `ESTRATO`. QC: la serie publicada por SENDA se reproduce dentro de 0,2–0,6 pts en las 7 olas.
> 4. Definiciones que se cierran por escrito antes de calibrar: ex-bebedor (30 días vs ≥ 12 meses), HED (umbral por sexo, faltantes de `db`), puente APC (denominador, no registrado, año).
>
> **Del 21-sep** (mismo archivo, §16–§26):
> 1. Persistencia bebe/no bebe = **rasgo + AR(1)** (λ = 0,45; φ = 0,65 de partida; grilla), no AR(1) puro ρ = 0,8. Evidencia: EPS 50+. Anualizar matrices t→t+2 con raíz de matriz o `msm`, no α = 0,5 por probabilidad (§2 paso 4, §6).
> 2. Meta 5 (intensidad) se calibra **sin** factor OMS; el factor va sólo dentro de RR/AAF/PIF (§1, §2, §5).
> 3. Mortalidad del motor: m = muertes DEIS (archivo 15-09-2026) / población INE; HMD sólo como control. La deriva −3,1 → +3,8 % (2012→2024) es sistemática (§2 paso 2, §5 meta 6).
> 4. Metas nuevas de persistencia: % nunca (ENPG `OH_1`), % ex > 12 meses (`OH_4`), r EPS a 3,7 y 7,7 años (§5 meta 3).
> 5. Edad 66–76: nivel = ENPG 60–65 × razón EPS por sexo; persistencia EPS 50+; mortalidad DEIS/INE (§6). Decisión de ACC.
>
> Cambios propuestos a notebooks: `expand_pif_cambios_hallazgos_2026-09-21.md`. Entrada para el handoff canónico: `entrada_2026-09-21_para_codex_handoff_adam_rr_full_override_caveman.md`.

---

## 0. En diez líneas

| Cuándo | Qué queda listo |
|---|---|
| **Mié 30-sep-2026** | **Modelo base v0**: población sintética ENPG 2012 (15–64) → transiciones anuales de consumo 2012→2024 → comparación con las 7 olas ENPG → **calibrado** (δ global y por estado, holdout 2022/2024). Motor discreto anual tipo SIMAH; réplica MicSim del MWE como contraste. |
| Vie 30-oct-2026 | v0.5: dinámica propia de HED y ex-bebedores, intensidad (g/día) en escala encuesta (factor OMS sólo en RR) `[21-sep]`, entradas/salidas INE, repeticiones Monte Carlo. Reunión con Cristóbal Cuadrado sobre parámetros de calibración. |
| Lun 30-nov-2026 | **v1 (curso natural completo)**: mortalidad por causa enganchada al ciclo (AAF de `aaf_unified.R`), validación contra DEIS 2012–2024, proyección 2025–2034. Borrador Paper 1 a coautores. |
| Mar 15-dic-2026 | **Informe anual + rendición**: modelo base v1 etiquetado en git, README, tabla de parámetros, borrador Paper 1. |
| 2027 | Políticas sobre el modelo base (IB en APS; precio/impuestos por bebida), incertidumbre, papers 2–3. Iteración con Robin Purshouse y CC. |
| Fines mar-2028 | Cierre FONDECYT: informe final, repositorio público. |

---

## 1. Lineamientos de ACC → decisión operativa

| Lo que dijo ACC | Cómo se traduce en el plan | Dónde |
|---|---|---|
| Fondecyt termina fines de marzo 2028 | Horizonte de 18 meses; 2026 = modelo base; 2027 = políticas y papers | §3 |
| Versión base del modelo: reproduce y proyecta trayectorias de consumo y mortalidad | v0 (consumo, 30-sep) → v1 (consumo + mortalidad, 30-nov); proyección 2025–2034 con INE base 2024 | §2, §4 |
| Ver qué tan bien calibrado está | Loss in-sample (2012–2020) y out-of-sample (2022/2024); cobertura de IC 95 % de la ENPG por celda; check de muertes totales vs DEIS | §5 |
| Reproducir prevalencia e intensidad; tal vez por tipo de bebida (impuestos) | Estado = {nunca, ex, actual} × categoría OMS I/II/III × HED + g/día continuo. Reparto por bebida: atributo reservado en el contrato de datos, se llena en 2027 (política de precio) | §2 |
| Calibrar: OMS per cápita quizás no para prevalencia; para intensidad tal vez sí; mortalidad ajustada por alcohol | `[21-sep]` Prevalencias **e intensidad** = ENPG con diseño complejo, sin corrección. Factor de cobertura OMS sólo dentro de RR/AAF/PIF (`g_riesgo = g × factor(año)`), como ya hace `expand_pif`. Mortalidad atribuible = AAF sobre la distribución corregida. ⚠ Confirmar con CC | §5 |
| El modelo cambia según la intervención, pero debe haber una base | Repo `R/simulation/` con núcleo fijo (población, ciclo, transiciones, mortalidad) y políticas como módulos enchufables (`apply_policy_*`) | §2 |
| Reporte a fin de año + rendición + modelo base + papers | Hito 15-dic: v1 + README + `model_parameters.csv` + borrador Paper 1 | §3 |
| Curso natural de trayectorias; artículo con parámetros del modelo; iterar con coautores | Paper 1 = descripción del modelo + calibración + baseline 2012–2034. Se circula a ACC, JRT, CC, colega Delphi, Robin Purshouse | §7 |
| Qué debe tener cada modelo por simulación: emigración, inmigración, fallecimiento | v0: entradas a los 15 años y salidas >64 desde INE; muertes totales por tablas de vida. v1: muertes por causa. Migración: sólo si la política lo exige (decisión por política) | §2, §6 |
| Dimensión socioeconómica: cuántos estratos, pros y contras | Decisión a fin de octubre con v0 corriendo: escolaridad en 3 niveles como único eje SES, o ninguno | §6 |
| Compromiso: modelo 2012–2024 a fin de mes | §4, día a día | §4 |
| Parámetros de calibración, conversar con CC | Tabla lista en §5 | §5 |
| Iterar con Robin Purshouse / CC después | Después del borrador de diciembre | §3 |

Nota: escribiste "Robin Penrose"; asumo **Robin Purshouse** (Sheffield, coautor de Kilian 2025 y del paper de elasticidades de JRT).

---

## 2. Qué es el "modelo base"

**Motor.** Discreto anual en R (`data.table`), portando el orden de `run_microsim_alt.R` de SIMAH 0.1.1 (`SIMAH/supp/`). En paralelo, réplica en MicSim (`Simulacion/MWE.R` + `patch_micSim.R`) con los mismos estados, como contraste de las prevalencias simuladas. Registrar en el README la URL del repositorio SIMAH y el release 0.1.1.

**Entidad: persona** (contrato de datos, una fila por individuo por año)

| Atributo | v0 (30-sep) | v1 (30-nov) | Fuente |
|---|---|---|---|
| `id`, `sex`, `age` (simple), `agecat` (15–29 / 30–44 / 45–59 / 60–64) | ✔ | ✔ | ENPG 2012 + INE |
| `edu` (3 niveles) | se carga, no se usa | según decisión §6 | ENPG |
| `alc_status` ∈ {ltabs, fd, current} | ✔ (fd y ltabs estáticos dentro de Non-drinker) | dinámica fd ↔ current | ENPG `cvolaj` |
| `alc_cat` ∈ {cat1, cat2, cat3} (OMS: M 0–19,99 / 20–39,99 / ≥40; H 0–39,99 / 40–59,99 / ≥60 g/d) | ✔ | ✔ | ENPG `volajohdia` |
| `gpd` g/día continuo (gamma por sexo×edad×cat, escala encuesta; × factor OMS sólo al calcular RR) `[21-sep]` | ✔ | ✔ | fits de `expand_pif` |
| `hed` (0/1) | ✔ como probabilidad condicional a cat×sexo×edad, re-sorteada cada año | transición propia | ENPG (definición armonizada por ola) |
| `trait_u`, `ar_a` (propensión latente rasgo + AR(1)) `[21-sep]` | ✔ | ✔ | λ y φ desde EPS VI–VIII (50+) + metas nunca/ex |
| `bev_share` cerveza/vino/destilados | columna vacía | columna vacía | EPF o ENS, 2027 |
| `weight`, `alive`, `cause` | ✔ / ✔ / — | ✔ / ✔ / ✔ | — |

**Ciclo anual (orden Kilian et al. Fig. S1, adaptado)**

1. Registrar población y consumo del año.
2. Muertes: v0 = tasa total por sexo×edad. `[21-sep]` m = muertes DEIS (archivo 15-09-2026; filtros: año de defunción + edad en años) / población INE a mitad de año; `q = m/(1+0,5m)`; HMD sólo como control (`life_tables_20260714.R` sigue para YPLL). v1 = por causa con AAF (`aaf_unified.R`) + resto no atribuible.
3. Transición de escolaridad (sólo si entra SES, 18–34 años).
4. Transición de consumo: `polr` de JRT reajustado con la ENPG 2012–2024, aplicado anualmente. `[21-sep]` Anualización con raíz de matriz (o `msm`); α = 0,5 sólo como réplica de JRT, con test Chapman–Kolmogorov (A·A vs P2, tolerancia 0,02). Bebe/no bebe en el motor por umbral de celda: propensión latente rasgo + AR(1), λ = 0,45, φ = 0,65 (grilla λ ∈ {0; 0,3; 0,45; 0,6} × φ ∈ {0,6; 0,7; 0,8}); λ = 0 reproduce el motor actual.
5. Actualizar `gpd` y `hed` dados el estado nuevo.
6. Edad +1; salen los >64; entran los que cumplen 15 (INE), con estado inicial de la ENPG 15–17 de la ola más cercana. `[21-sep]` Opción cola 66–76 (v2): siguen con nivel ENPG 60–65 × razón EPS por sexo y la misma persistencia (§6).
7. (Política, sólo desde 2027) `apply_policy_*` entre los pasos 4 y 5.

**Salidas por año × sexo × edad (× SES):** prevalencia por estado, media de g/día, prevalencia HED, N vivos, muertes por causa (v1), YPLL (v1, `build_ypll.R`).

**Calibración v0:** esquemas ya codificados por JRT en `Simulacion/Alcohol Transitions_CALIB.R` (δ global con Brent; δ por estado previo; κ umbrales) y offsets por destino θ de `IMIS ALCOHOL.R`. Pérdida: SSE ponderada por la varianza de diseño de la celda ENPG (usar las medias por celda con diseño de `pseudopanel_fase1/ppd_design_based_cell_means_*.csv` como referencia de precisión). Entrenar 2012–2020, holdout 2022 y 2024.

---

## 3. Hitos oct-2026 → mar-2028

| Fecha | Hito | Criterio de "listo" |
|---|---|---|
| 30-sep-2026 | v0 consumo calibrado | `run_microsim_base.R` corre 2012→2024 en < 10 min con semilla; figura sim vs ENPG por sexo×edad×estado; tabla de pérdida sin/con calibración; holdout 2022/2024 dentro del IC 95 % de la ENPG en ≥ 80 % de las celdas (meta, no requisito) |
| 16-oct-2026 | v0.5-a | HED con transición propia; ex-bebedor con entrada/salida (`update_former_drinker` de SIMAH como plantilla); anualización de la matriz t→t+2 (raíz de matriz vs α); réplica MicSim comparada; `[21-sep]` rasgo + AR(1) calibrado contra metas nunca/ex/EPS |
| 30-oct-2026 | v0.5-b + reunión CC | Entradas/salidas INE; 20+ repeticiones Monte Carlo con intervalos; decisión SES; reunión con CC con la tabla §5 |
| 13-nov-2026 | v1-alpha | Mortalidad por causa dentro del ciclo; muertes simuladas vs DEIS 2012–2024 por sexo×edad; YPLL |
| 30-nov-2026 | v1 + Paper 1 borrador | Proyección 2025–2034 (INE base 2024); `model_parameters.csv`; borrador a coautores |
| 15-dic-2026 | Informe anual + rendición | git tag `micsim-base-v1`; README reproducible; parámetros; Paper 1 |
| ene–mar 2027 | Paper 1 iterado + política 1 (IB en APS) | Comentarios de ACC/JRT/CC/Robin incorporados; módulo SBI (Sheffield) sobre v1; primeras muertes/YPLL evitados |
| abr–jun 2027 | Política 2 (precio) | Reparto por bebida; elasticidades de JRT (margen intensivo) + participación como sensibilidad; impuesto específico por gramo y PMU |
| jul–sep 2027 | Incertidumbre + SES | LHS sobre parámetros de política; heterogeneidad por escolaridad si se adoptó; borrador Paper 2 |
| oct–dic 2027 | Papers 2–3 | Envíos; informe |
| ene–mar 2028 | Cierre | Informe final; repositorio público (OSF/GitHub) |

---

## 4. Día a día hasta el 30-sep (8 días hábiles; 18–19 sep feriado)

Todo va a `R/simulation/` (nuevo). No se editan notebooks ni `.qmd`. Cada script parte con `.t0 <- Sys.time()` y reporta minutos; `package::function`; comentarios en inglés.

| Día | Tarea | Insumos | Salida | Check |
|---|---|---|---|---|
| **Jue 17** (hoy) | Esqueleto `R/simulation/` (`00_setup.R`, README con contrato de datos §2). Crear `.acc_root` y `_tools/paths.R` (AGENTS.md los referencia y no existen en esta máquina). Leer `run_microsim_alt.R` y `prob_alcohol_transition.R` de SIMAH y anotar el orden del ciclo. Inventario de datos en esta máquina (dell-lr): hay `.rds` de 2 bytes (`defunciones1/2`, `enpg2012–2018.RDS` en `Raw data/`); los `.dta` crudos y `enpg_design_waves_2012_2024_list.RDS` sí están | AGENTS.md, SIMAH | `R/simulation/README.md` | Lista de archivos faltantes en esta máquina |
| **Lun 21** | `build_baseline_population.R`: ENPG 2012, 15–64, desde `Sex-and-age-differences-…/Raw data/enpg_design_waves_2012_2024_list.RDS` (o el `.dta` de `__enpg/`); recode `cvolaj` con `recode_enpg_cvolaj_to_state()`; `hed`, `edu`, `gpd` (gamma por celda); remuestreo ponderado a N = 300 000 por sexo×edad simple | `build_enpg_design_waves_2012_2024_list.R`, `IPF PREP.R` | `data/interim/pop2012.rds` | Márgenes sexo×edad vs `__andres_control/ine_proyecciones_2012_2024.xlsx` (error < 1 %) |
| **Mar 22** | `fit_transitions.R`: arreglar `Alcohol Transitions_CALIB.R` (texto pegado ~l. 342; `calibrate_global` definida dos veces, l. 175 y 275) copiando funciones a `R/simulation/` sin tocar el original. Pseudo-panel por rank matching con pares 2012→14→…→22 (`make_pseudopanel_all`) y `polr` (`fit_alcohol_ordinal_final`) | `Alcohol Transitions FINAL.R` | `data/interim/model_polr_2012_2022.rds` + matrices por sexo×edad | Filas suman 1; sin NA; diagonal > 0,5 |
| **Mié 23** | `run_microsim_base.R`: ciclo anual v0 (pasos 1, 2-total, 4, 5, 6 de §2); entradas a los 15 y salidas >64 con INE; semilla fija | `age_transition_step`, `transition_alcohol_step`, tablas de vida | `outputs/sim/prev_sim_v0.csv` | N vivos 15–64 por año vs INE (± 2 %) |
| **Jue 24** | `compare_enpg.R`: prevalencias observadas 7 olas con diseño complejo (svydesign por ola) por sexo×agecat×estado + IC 95 %; figura sim vs obs; pérdida sin calibrar | `enpg_design_waves_2012_2024_list.RDS`, `make_obs_prev` | `outputs/fig/sim_vs_obs_v0.png`, `outputs/tables/loss_uncalibrated.csv` | Celdas ENPG usadas = registro de olas (PSU 2016 pendiente de autorización) |
| **Vie 25** | `calibrate_transitions.R`: δ global (Brent) y δ por estado (Nelder-Mead), train 2012–2020, holdout 2022/2024; pérdida ponderada por varianza de diseño | `calibrate_global`, `calibrate_bycat`, `apply_destination_offsets` | `outputs/tables/loss_calibrated.csv`, figura calibrada | Holdout mejora vs sin calibrar; parámetros dentro de rangos plausibles |
| **Lun 28** | Intensidad y HED: `gpd` re-sorteado al cambiar de categoría; factor OMS sobre `gpd`; `hed` condicional por cat×sexo×edad; comparación de media g/día y % HED vs ENPG | fits gamma de `expand_pif`, `data_binge_sensitivity.rds` | figura intensidad/HED sim vs obs | % HED y media g/día dentro de IC en holdout |
| **Mar 29** | Réplica MicSim: 4 estados + muerte, tasas desde las probabilidades anuales (−log(1−p)), misma población inicial; comparar prevalencias con el motor discreto. 20 repeticiones del motor discreto con semillas distintas | `MWE.R`, `patch_micSim.R` | `outputs/tables/micsim_vs_discrete.csv` | Diferencia de prevalencia < 1 punto por estado |
| **Mié 30** | Cierre v0: README, `model_parameters.csv` (nombre, valor, fuente, rango), entrada en el handoff canónico, git tag `micsim-base-v0`, resumen de 1 página para ACC | — | tag + resumen | Corre de cero en < 10 min desde `run_pipeline_sim.R` |

Prioridad si falta tiempo: **imprescindible** = lun 21 → vie 25 (población, transiciones, ciclo, comparación, calibración). **Deseable** = lun 28 y mar 29; si no alcanzan, pasan a la semana del 5-oct.

**§4-bis `[21-sep]` Tareas agregadas esta semana (≈ 3 h en total; no mueven el 30-sep)**

1. Lun 21, 20 min: metas ENPG % nunca y % ex > 12 meses por ola × sexo × tramo (`targets_never_former.csv`).
2. Lun 21, 15 min: muertes 2024 en DEIS 09-06-2026 vs 15-09-2026; fijar un archivo en el manifiesto.
3. Mar 22, 30 min: diagnóstico de dos cocientes (`mortality_input_diagnostic.csv`).
4. Mié 23, 2 h: `run_microsim_base.R` con latente rasgo + AR(1) y mortalidad DEIS/INE.
5. Lun 28: intensidad calibrada sin factor OMS; factor sólo dentro de la función de RR.

---

## 5. Parámetros de calibración — para conversar con CC

| # | Target (observado) | Fuente | Estratos | Parámetro que se mueve | Comentario |
|---|---|---|---|---|---|
| 1 | Prevalencia por estado (Non-drinker / cat1 / cat2 / cat3) | ENPG 2012–2024, diseño complejo | año × sexo × agecat | δ global; δ por estado previo; θ offsets por destino | Sin corrección OMS (ACC). Loss ponderada por varianza de diseño |
| 2 | Cortes entre categorías | ENPG | sexo | κ₁–κ₃ (umbrales del polr) | Sólo si 1 no basta |
| 3 | % nunca bebedor y % ex-bebedor (> 12 meses); `[21-sep]` + r entre entrevistas a 3,7 y 7,7 años (50+) | ENPG `OH_1`, `OH_4`; EPS VI–VIII | año × sexo × agecat | λ y φ de la propensión latente; tasas de entrada/salida a fd (v0.5) | Definición de "ex" ≥ 1 año sin consumo (ENPG). Nunca bebedores solos = necesario, no suficiente |
| 4 | Prevalencia HED | ENPG (5+/4+ tragos; 6+ en olas antiguas: usar armonización) | año × sexo × agecat × cat | P(hed \| cat, sexo, edad) y su transición (v0.5) | 2020 ola pandémica: ¿peso reducido o sólo validación? |
| 5 | Media g/día entre bebedores | ENPG gamma, escala encuesta `[21-sep]` | sexo × agecat | parámetros gamma | `[21-sep]` **Sin** factor OMS al calibrar. El factor (el mismo de `expand_pif`) se aplica sólo al calcular RR/AAF/PIF, para que AAF y simulación coincidan |
| 6 | Muertes totales por sexo × edad | `[21-sep]` DEIS (archivo 15-09-2026) / población INE; HMD como control | año × sexo × edad | ninguno (insumo) | Verifica N vivos e inmortalidad. Con qx HMD × INE el error va de −3,1 % (2012) a +3,8 % (2024): deriva sistemática que desaparece con DEIS/INE |
| 7 | Muertes atribuibles por causa (23 causas + AAF=1) | `expand_pif` (AAF 2012–2024) × DEIS | año × sexo × agecat × causa | ninguno: es **validación** (v1) | Si la distribución de consumo calza, la mortalidad atribuible calza por construcción; lo que se valida es la trayectoria |
| 8 | Población 15–64 y entradas a los 15 | INE proyecciones 2012–2024 y base 2024 (1992–2070) | año × sexo × edad | ninguno (insumo) | Migración sólo si la política lo exige |

Preguntas para CC: (a) loss ponderada (χ²-like) vs SSE simple; (b) optim vs calibración bayesiana (IMIS/ABC, como exploró JRT en `IMIS ALCOHOL.R`) para llevar incertidumbre de calibración a los intervalos; (c) qué años como holdout y qué hacer con 2020; (d) tolerancia aceptable (cobertura del IC 95 % por celda); (e) si el factor OMS debe aplicarse igual en todos los años o seguir la serie de APC; (f) cuántos estratos SES aguanta la ENPG por celda; `[21-sep]` (g) rasgo + AR(1): ¿las metas nunca/ex + EPS bastan para fijar λ y φ, o se reportan sólo como sensibilidad?

---

## 6. Decisiones abiertas y supuestos de trabajo

| Decisión | Supuesto hasta nuevo aviso | Pros / contras breves | Cuándo se decide |
|---|---|---|---|
| Motor ⚠ | Discreto anual tipo SIMAH; MicSim como contraste | SIMAH: código completo y probado, políticas ya implementadas; MicSim: propuesta original, tiempo continuo, más difícil de calibrar | 30-sep con la réplica |
| Anualizar un modelo t→t+2 | `[21-sep]` Raíz de matriz por celda (Higham) o `msm` en tiempo continuo; α = 0,5 sólo como réplica de JRT | α a cada probabilidad no reproduce P2 (ej.: permanencia 0,81 → 0,54 al aplicarlo dos veces). Test Chapman–Kolmogorov de 30 min | 16-oct |
| Persistencia bebe/no bebe `[21-sep]` | Rasgo + AR(1): λ = 0,45, φ = 0,65 (EPS 50+); λ = 0 = motor actual | AR(1) puro con ρ = 0,8 da r(10 años) = 0,11; EPS ≈ 0,47. Contras: sólo 50+, pregunta EPS sin plazo, sobrevivientes | 16-oct, con metas §5-3 |
| Fuente de mortalidad del motor `[21-sep]` ⚠ | DEIS 15-09-2026 (numerador) + INE (denominador); HMD como control | DEIS e INE son las fuentes oficiales; HMD reprocesa el mismo registro civil | Tras el diagnóstico de dos cocientes (30 min) |
| SES | Sin SES en v0; escolaridad 3 niveles candidata | A favor: está en ENPG y en el certificado de defunción (permite mortalidad por escolaridad); política de precio es regresiva/progresiva por ingreso. En contra: 2×4×3×4 = 96 celdas, precisión ENPG cae (ver `ppd_cell_audit_summary`), más parámetros que calibrar. Ingreso: no consistente en ENPG ni en DEIS | 30-oct con CC |
| Edad >64 ⚠ | Fuera del modelo (ENPG llega a 64). `[21-sep]` Opción concreta: cola 66–76 con nivel = ENPG 60–65 × p_EPS(66–70)/p_EPS(60–65) por sexo, persistencia EPS 50+, mortalidad DEIS/INE | El grueso de la mortalidad está en 65+. EPS VIII (consumo declarado, sin plazo): hombres 36,8 % (66–70 y 71–76); mujeres 20,4 % y 14,8 % | Paper 1 (limitación) o v2 |
| Demografía | Entradas a 15 y salidas >64 desde INE; migración no | Migración importa poco para IB; podría importar para precio por regiones (no modelado) | Por política |
| ENPG 2020 | Entra al entrenamiento con peso normal | Pandemia + cambio de modo; alternativa: sólo validación | Con CC |
| Reparto por bebida | Columna vacía hasta 2027 | Necesario sólo para impuestos por bebida; fuente EPF (shares por sexo×edad×quintil) vs ENS | abr-2027 |
| Paper cocaína→alcohol ⚠ | Estacionado | No se discutió | Cuando ACC lo pida |
| Autorizaciones pendientes del guion ⚠ | PSU 2016 sin alinear; AAF=1 fuera del PIF | Afectan IC de 2016 y lo evitable en PIF; no bloquean v0 | Cuando ACC lo pida |

---

## 7. Paper 1 (borrador para el 30-nov): "The Chilean alcohol microsimulation model"

Estructura mínima, para que los coautores puedan iterar sobre parámetros:

1. Objetivo y alcance (15–64, 2012–2024 observado, 2025–2034 proyectado).
2. Estructura del modelo: entidad, estados, ciclo anual (figura tipo Fig. S1), motor.
3. Insumos: tabla de fuentes (ENPG 7 olas, INE, DEIS, RR OMS 2024 / Shield 2025, tablas de vida).
4. Modelo de transiciones: pseudo-panel, `polr`, anualización.
5. Calibración y validación: targets §5, pérdida, holdout, cobertura de IC; réplica MicSim.
6. Resultados baseline: prevalencias, intensidad, HED, muertes atribuibles y YPLL 2012–2034 con intervalos Monte Carlo + draws de AAF ya existentes.
7. Tabla de parámetros (`model_parameters.csv`) con fuente y rango: es lo que ACC pidió poder discutir.
8. Limitaciones: sin >64, sin migración, margen extensivo, definición HED por ola.

---

## 8. Tus notas → dónde quedan

| Tu nota | En el plan |
|---|---|
| Transiciones sin calibración primero (no bebe → moderado → alto) | Mar 22 – Mié 23 (§4) |
| Volumen + HED + nunca/ex desde el inicio; calibrar volumen primero, luego HED y FD | Contrato de datos §2 (atributos desde v0); dinámica HED/FD en v0.5 (16-oct) |
| Comparar con la ENPG (2020 simulado ≈ ENPG 2020) | Jue 24 (§4), target 1 (§5) |
| Calibrar hasta acercar prevalencias | Vie 25 (§4) |
| Elasticidades después | abr–jun 2027 (§3) |
| Conectar mortalidad, PIF y YPLL reutilizando `expand_pif` | v1, 13-nov (§3); target 7 (§5) |

---

## 9. Riesgos y qué hacer

| Riesgo | Mitigación |
|---|---|
| 8 días hábiles para v0 | Reusar código de JRT tal cual (polr, calibración, ciclo); nada nuevo que no sea el pegamento |
| Datos stub en dell-lr (`defunciones*.RDS`, `enpg2012–2018.RDS`) | v0 no necesita defunciones; ENPG desde `.dta` o del `RDS` armonizado. Mortalidad (v1) en la máquina nDP o restaurando los datos |
| `Alcohol Transitions_CALIB.R` no parsea | Copiar funciones a `R/simulation/` y arreglar ahí; no tocar el original |
| Anualización heurística (α) | `[21-sep]` Raíz de matriz o `msm`; test Chapman–Kolmogorov sobre la matriz de JRT (30 min) |
| Deriva de mortalidad HMD vs DEIS (−3,1 → +3,8 %) `[21-sep]` | Tasas DEIS/INE en el motor; diagnóstico de dos cocientes INE/HMD y HMD/DEIS (30 min) |
| AR(1) puro subestima la memoria a 10 años `[21-sep]` | Rasgo + AR(1) y grilla λ × φ; reportar sensibilidad |
| Definición HED cambia por ola | Usar la armonización de `pseudopanel_*`; sensibilidad con dos definiciones |
| Sobre-ajuste con 3+ esquemas de calibración | Holdout obligatorio; reportar siempre sin calibrar vs calibrado |

---

Entrega de este plan: copia en `__andres_control/` y en el proyecto Claude. `[21-sep]` Entrada fechada para el handoff canónico (`codex_handoff_adam_rr_full_override_caveman.md`): `entrada_2026-09-21_para_codex_handoff_adam_rr_full_override_caveman.md`, para pegar al final.
