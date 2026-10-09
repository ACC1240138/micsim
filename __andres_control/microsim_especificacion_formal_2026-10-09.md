# Microsimulación — especificación formal y respaldo de construcción

> **Qué documenta:** el motor BASE del notebook [`microsim_base_ACC_2012_2024.ipynb`](microsim_base_ACC_2012_2024.ipynb), con entrenamiento 2012–2020, validación fuera de muestra 2022 y 2024 y proyección condicional 2025–2034, escrito en tus términos (secciones 0–5), completado con lo que hace el código y resumido en una página en «Especificación vigente en tu formato». \
> **Fecha:** 2026-10-09. \
> **Origen de los números:** se recalcularon con los datos vigentes en una sesión en la nube (R 4.3.3 fuera de renv, porque allí Posit PPM está bloqueado); hay que volver a correrlos localmente, con renv, antes de citarlos. No se cambió ningún código del repositorio: se escribieron este archivo y el archivo de scripts `auditoria_microsim_2026-10-09/scripts_especificacion_2026-10-09.tar.gz` (sección 12).

## Cómo leer este documento

1. Las secciones 0 a 7 siguen siempre el mismo orden: Formulación → Intuición → Implementación → Estimación → Valores estimados → Supuestos y limitaciones → recuadro «Tu formulación vs el código».
2. En «Formulación» va primero tu texto, citado como «Tu texto: «…»», con tu notación. Única excepción: renombré tu $t$ como $\tau$, porque $t$ es el año.
3. Marcas sobre tu formulación:
   - **[errata]** = error interno de tu texto;
   - **[código]** = lo que hace el código (no implica que sea mejor; la sección 10 dice qué conviene);
   - **[faltaba]** = algo que tu texto no define y que se toma del código.
   Las notas del documento empiezan con «Nota:». Los corchetes quedan sólo para marcas y etiquetas.
4. El código se cita como `<celda> L<n>`, donde n es la línea dentro de esa celda del notebook BASE (la línea `#| label` es L1). En los fragmentos de código se omiten los prefijos `base::`, `stats::` y `dplyr::`.
5. Etiquetas de evidencia:
   - **[verificado con datos]** = corrido hoy con datos reales y recalculado por un verificador independiente;
   - **[corrido, sin verificación independiente]** = corrido hoy con datos reales, sin ese segundo cálculo;
   - **[álgebra verificada]** = derivación revisada por el verificador;
   - **[leído, no corrido]** = tomado de archivos o del código sin re-ejecutar;
   - **[RECALIB]** = cifra del notebook de contraste (semillas 2125–2129), no del motor BASE;
   - **[supuesto]** = elección fija que no se estima.
   «1 semilla» describe la corrida, no el grado de verificación.
6. Orden de estudio sugerido: Parámetros → Ciclo anual → Especificación vigente → 0 → 1 → 2 → 9 (persona B) → 3 → 4 → 5 → 9 (persona A) → 6 (y la fila de mortalidad de la sección 9) → 7 → 8 → 10. La tabla de la sección 10 junta todo lo que queda por decidir. El Anexo A guarda el detalle de verificación y el Anexo B, las 56 metas completas.

### Notación

| Símbolo | Significado | En el código |
|---|---|---|
| $i$ | persona sintética | `id` |
| $t$ | año calendario, 2012…2034 | `year` |
| $\tau_t$ | tiempo reescalado, $(t-2012)/10$. En el motor se usa $\tau^*_t=(\min(t,2024)-2012)/10$ | `time` (`ms-calibration-functions` L10, L78) |
| $s$ | sexo: M = mujer, H = hombre | `sex` |
| $x$ | edad simple cumplida al 1 de enero (15–65) | `age` |
| $a$ | grupo de edad: 1 = 15–29, 2 = 30–44, 3 = 45–59, 4 = 60–65 | `age_group` (`ms-annual-engine` L4) |
| $c=(s,a)$ | celda sexo × grupo de edad (8 celdas) | `cell` |
| $y$ | ola ENPG: 2012, 2014, …, 2024 | `year` en `ms_targets` |
| $t^0_i$ | año de entrada de la persona (2012, o el año en que entra a los 15 o como inflow) | — |
| $\rho$, $\varepsilon_{it}$ | persistencia interanual (0,8) e innovación $N(0,1)$ | `rho`; `rnorm` (`ms-annual-engine` L126) |
| $Z^{status}_{it}$, $Z^{amount}_{it}$, $Z^{HED}_{it}$ | latentes AR(1), cada una $N(0,1)$ | `z_current`, `z_amount`, `z_hed` |
| $U^{j}_{it}=\Phi(Z^{j}_{it})$ | percentil o posición relativa, $j\in\{status, amount, HED\}$ | `pnorm(z_*)` |
| $\Phi$; $\Phi_2(\cdot,\cdot;\rho)$ | FDA normal estándar; FDA normal bivariada estándar con correlación $\rho$ | `pnorm` |
| $pc(s,a,t)$; $\alpha_{s,a}$, $\beta_{s,a}$ | prevalencia de consumo actual; intercepto y pendiente en escala logit | `p_current`; `prevalence` |
| $C_{it}$ | $\text{Is\_Current}_{it}$ (1 = bebedor actual) | `current` |
| $ever_{it}$; $p_{former}$ ($p_F$) | alguna vez bebió (irreversible); $P(\text{ex}\mid\text{no actual},s,a)$ | `ever`; `p_ever_noncurrent` |
| $g_{it}$ | gramos de alcohol por día, en escala de encuesta | `gpd_survey` |
| $\mu(s,a,t)$ | media de $g$ entre los bebedores actuales | `mu_current` |
| $p_0$; $k$; $\phi$ | proporción de bebedores actuales con $g=0$; forma Gamma; escala Gamma $\phi=\mu/(k(1-p_0))$ | `p_zero`; `shape`; `scale` (`ms-annual-engine` L27) |
| $F^{-1}_\Gamma(\cdot;k,\phi)$; $G_k$ | cuantil Gamma de forma $k$ y escala $\phi$; FDA Gamma de forma $k$ y escala 1 | `qgamma`; `pgamma` |
| $\gamma$ | coeficientes logit del HED. Tuyos: $\gamma_0,\gamma_s,\gamma_a,\gamma_{gpd}$. Del código: $\gamma_{s,a},\gamma_{gpd}$ | `hed` (glm) |
| $p^{HED}$ | probabilidad de ≥1 episodio 5+/4+ en 30 días | `p_hed` |
| $g^{(1)}_s$, $g^{(2)}_s$ | umbrales de categoría: 20 y 40 g/d (M), 40 y 60 g/d (H) | `low`, `high` |
| $q_x$; $q^*$; $\kappa_s$ | probabilidad anual de muerte de HMD; probabilidad que usa el motor; multiplicador de riesgo por sexo | `qx`; `q` (`ms-annual-engine` L85); `mortality_scale` |
| $N^{ene}$, $N^{jun}$; $D$ | stocks INE al 1 de enero y al 30 de junio; defunciones DEIS | `pop_jan`, `pop_mid`; `deaths` |
| $\omega$; $n_{t,s,x}$ | peso unitario (personas reales por sintético); número objetivo de sintéticos | `unit_weight`; `n_target` |
| $w_i$; $v_{c,y}$ | factor de expansión ENPG; peso WLS (inverso de la varianza delta) | `weight`; `w_current`, `w_amount` |

### Glosario

- **RECALIB:** notebook de contraste [`microsim_recalib_ACC_2012_2024.ipynb`](microsim_recalib_ACC_2012_2024.ipynb). Usa el mismo motor, pero sus metas son una reconstrucción `interp_hold` sobre las 7 olas. No es tu especificación.
- **`interp_hold`:** reconstrucción de las metas año a año que interpola linealmente entre olas y mantiene el valor de la última ola hacia adelante (`microsim_base_ACC_2012_2024_explicacion.md` L104; D15).
- **Origen móvil:** reajustar con las olas hasta un corte T y evaluar la ola siguiente, repitiendo para varios cortes.
- **Comparador estático:** `ms_fit(2020, trend = FALSE)`. Fija $pc$ y $\mu$ en las medias de 2012 y usa $\kappa=1$ (`ms-calibration-functions` L20–23, L63); corre con 1 semilla (`ms-historical-validation` L5).
- **JRT:** equipo cuyo código y salidas de referencia están en la carpeta `jrt/` del repositorio ([`../jrt/README.md`](../jrt/README.md)).
- **factor_CH:** por ola, 0,8 × consumo per cápita OMS (APC), en gramos, dividido por el volumen per cápita de ENPG: `apc_grams / pc_totalvolCH` en [`oms_factor_by_year.csv`](oms_factor_by_year.csv) [leído, no corrido]. Lleva el g/d de encuesta a la escala de riesgo.
- **Decisiones** ([`notes_decisions.md`](auditoria_microsim_2026-10-09/notes_decisions.md)):
  - **D3:** el factor OMS se aplica sólo dentro de RR/AAF/PIF y se congela en 2025–2034. ACC/CC no la ha confirmado.
  - **D4:** exbebedor = último trago hace más de 30 días (confirmada por ti).
  - **D4b:** las historias simuladas (`ever`/ex) no alimentan el RR de exbebedor; ese reparto sale de la encuesta (regla vigente).
  - **D5:** HED = ítem 5+ (H) / 4+ (M) en 30 días, como *proxy* del umbral de RR de 60 g (confirmada para AAF).
  - **D6:** la ola 2020 entra al cálculo y, para AAF, toma el factor de diseño de 2018.
  - **D15:** las metas 2012–2024 se reconstruyen con `interp_hold` sobre 7 olas; ya no hay held-out intacto (propuesta de agente, no de ACC).
- **IB:** intervención breve.

---

# Microsimulación

## Parámetros

- **Período de entrenamiento (train): 2012–2020.**
  - Dónde está: `ms_cfg$train_end = 2020L` (`ms-setup` L9), que alimenta `ms_fit(2020, trend = TRUE)` (`ms-fit-and-check` L4). `ms_fit` filtra con `year <= last_year` a ENPG, a las metas y a las defunciones (`ms-calibration-functions` L7–8 y L58).
  - Qué significa: 5 olas × 8 celdas = 40 metas de diseño. De esos mismos años salen la forma Gamma, $p_0$, $p_F$, el glm del HED y $\kappa_s$.
  - Nota: lo que **no** se reserva son los stocks INE y la $q_x$ de HMD de 2021–2024, que entran observados en la corrida de validación. Sólo están reservados la exposición y el nivel de mortalidad $\kappa$.
- **Período de validación fuera de muestra (held-out): 2022 y 2024.**
  - Dónde está: `observed_end = 2024L`. Las 16 celdas se evalúan en `ms-historical-validation` L18–38.
  - Una prueba de no filtración (`ms-fit-and-check` L26–47) altera los datos posteriores a 2020 y exige que el ajuste no cambie (detalle en el Anexo A).
  - Nota: ese held-out ya no está intacto, porque el reajuste con 7 olas y RECALIB usaron 2022 y 2024 (`microsim_base_ACC_2012_2024_explicacion.md` L66, L176; decisión D15).
- **Ventana de proyección condicional: 2025–2034.**
  - Dónde está: `end_year = 2034L` (`ms-setup` L9); se usa en `ms-full-refit-projection` L5.
  - El modelo que se proyecta **no** es el de entrenamiento. Es `ms_fit(2024)`, reajustado con las 7 olas y corrido con **una** semilla.
  - El tiempo se congela en 2024 en la exposición (`ms-calibration-functions` L78) y en la mortalidad (`ms-annual-engine` L82). Los stocks son las proyecciones INE.
  - Nota: es un escenario «todo sigue como en 2024», no un pronóstico.
- **Tamaño muestral sintético: 25.000 individuos por corrida y 5 semillas Monte Carlo.**
  - Dónde está: `n_sim = 25000L` y `seeds = 20260917L + 0:4` (`ms-setup` L10).
  - **[faltaba] Peso unitario:** $\omega=\sum_{s,x}N^{ene}_{2012,s,x}/25.000 = 12.031.236/25.000 = 481{,}249$ personas reales por sintético (`ms-annual-engine` L51). Es fijo durante toda la corrida.
  - **[faltaba] Tamaño de cada año:** $n_{t,s,x}=\mathrm{round}(N^{ene}_{t,s,x}/\omega)$ (`ms-annual-engine` L52). Por eso «25.000» vale sólo el 1 de enero de 2012: después son 27.704 (2020), 28.665 (2024) y 30.091 (2034) [verificado con datos].
  - Dónde se usan las semillas:
    - Las 5 semillas sólo en la validación (`ms-historical-validation` L3–4).
    - La proyección (`ms-full-refit-projection` L5–6), el comparador estático (`ms-historical-validation` L5) y la sensibilidad a ρ (`ms-persistence-sensitivity` L4) usan **una** semilla.
    - El código sólo exige ≥ 2 semillas (`ms-setup` L14).
  - **Qué miden las 5 semillas:** sólo el ruido Monte Carlo.
    - En una corrida, la DE binomial por celda es ≈ 0,75–0,82 pp en los grupos de 15 años de ancho ($n_c$ ≈ 3.650–4.400) y ≈ 1,3–1,5 pp en 60–65 ($n_c$ ≈ 1.130–1.260) [verificado con datos].
    - Con celdas independientes, el sesgo held-out (media de 16 celdas) debería variar ≈ 0,2 pp entre semillas. Se observó una DE de 0,047 pp (9,66–9,76 pp en las 5 semillas) [verificado con datos]. Esa diferencia no está explicada.
    - En ambos casos, el ruido Monte Carlo es despreciable frente al sesgo de +9,7 pp.
  - **Qué no miden:**
    - la incertidumbre de los parámetros (el IC 95 % de $pc$ 2024 por celda tiene un semiancho de ≈ 11–17 pp);
    - el error de diseño de las metas;
    - la incertidumbre estructural ($\rho$, forma de las curvas, congelamiento).
- **Parámetro estructural de persistencia interanual: $\rho=0{,}8$.**
  - Dónde está: `rho = 0.8` (`ms-setup` L10). Se aplica a las **tres** latentes (`ms-annual-engine` L125–126) [supuesto].
  - No se estima. El propio código lo declara no identificado por las metas marginales (`ms-annual-engine` L121–122). La evidencia externa está en la sección 0.

## Insumos

### ENPG: variables de exposición

Fuente: el bundle cifrado `_enpg/enpg.tar.xz.enc`, del que se usan tres archivos:

- `derived/ENPG_BINGE.RDS`, con las variables armonizadas;
- la caché de diseño `derived/enpg_design_waves_2012_2024_list.RDS`;
- la base pública 2016, sólo para reconstruir la UPM.

Ver `ms-survey-inputs` L16–19. Nota: en el repositorio no hay ningún script que construya `ENPG_BINGE.RDS`; viene del pipeline de JRT (`expand_pif_registro_2026-10-06.md`, Q26) [leído, no corrido].

**Estado de consumo** (`ms-survey-inputs` L69–74):

$$S_i=\begin{cases}\text{nunca}&\texttt{oh1}=\text{"No"}\ \wedge\ \texttt{oh2}\ \text{vacío}\\ \text{actual}&\texttt{oh1}=\text{"Si"}\ \wedge\ \texttt{oh2}=\text{"30 dias"}\\ \text{FD (ex)}&\texttt{oh1}=\text{"Si"}\ \wedge\ \texttt{oh2}\in\{\text{">30"},\ \text{">1 año"}\}\\ \text{desconocido}&\text{otro caso (fuera de los denominadores)}\end{cases}$$

Nota: FD = no bebió en los últimos 30 días. Entre el 38,8 % y el 53,4 % de los FD (ponderado, según la ola) tiene `oh2` = ">30" [verificado con datos], que se interpreta como «bebió hace 31 días a 12 meses». Con esa lectura, el FD no es el exbebedor de 12 meses que suponen las fuentes de RR. Los desconocidos son 82–342 personas por ola entre 15 y 65 años (< 2 %).

**Intensidad, gramos de alcohol/día** (`ms-survey-inputs` L76–91). Tu texto: «Intensidad gramos de alcohol/día, puntos medios escala AUDIT y conversión 12g por trago estándar». El código usa ambos y además separa los días de *binge*. Fórmula exacta:

$$g_i=\frac{12}{30}\Big[\max(d_i-e_i,0)\,\bar q_i+e_i\,b_{s_i}\Big],\qquad g_i=0\ \text{si}\ S_i\in\{\text{nunca, FD}\},\qquad g_i=\text{NA si desconocido},$$

donde:

- $d_i$ = días con consumo en los últimos 30 (`oh3`; NA fuera de 0–30);
- $e_i$ = episodios de 5+ tragos (H) o 4+ (M) en 30 días (`db`; NA si ≥ 88);
- $\bar q_i$ = punto medio de AUDIT‑2: 1; 3,5; 5,5; 7,5; 9 para "0-2", "3-4", "5-6", "7-8", "9 o mas" (9 es el mínimo de «9 o más», no un punto medio);
- $b_H=5$, $b_M=4$ tragos por día de *binge*;
- 12 g por trago.

Nota: tu especificación nombra los puntos medios AUDIT‑2 y los 12 g por trago, pero no dice cómo se combinan con la frecuencia. El código cuenta los días sin *binge* × tragos típicos más los días de *binge* × 5 o 4 tragos, y divide por 30. Propiedades [verificado con datos]:

- El mínimo positivo es 0,4 g/d (1 día × 1 trago).
- Como $e$ no está topado en 30, el máximo llega a 160 g/d (29 personas tienen $e>30$).
- $e>d$ ocurre en el 6,6 % de los actuales.
- La función no es monótona en $e$. El 23,9 % (ponderado) de quienes tienen HED declara un día típico con más tragos que su día de *binge* ($\bar q>b_s$). De ellos:
  - en el 10,6 %, con $d>e$, un episodio más **baja** su g/día;
  - en el 13,3 %, con $e\ge d$, un episodio más **lo sube**.
- Faltantes, con caso completo: 3.744 de 48.624 bebedores actuales de 15–65 años no tienen g/d (7,7 % sin ponderar; 7,4 % ponderado; 4,5–10,1 % según la ola). Al HED le falta el 6,6 % ponderado.

**HED** (`ms-survey-inputs` L86): $h_i=\mathbf 1(e_i>0)$ entre los actuales, y 0 en los no actuales. Nota: tu texto dice «HED: episodios». En el código es un **indicador** de ≥ 1 episodio en 30 días, y la meta es una prevalencia entre bebedores. El número de episodios sólo entra en $g$.

### Diseño muestral y las 56 metas

Para cada ola $y$ y celda $c$, la meta es una media de Hájek con su EE de diseño por linealización de Taylor (primera etapa con reemplazo, sin corrección por población finita):

$$\hat\theta_{c,y}=\frac{\sum_{i\in c,y}w_i\,\delta_i\,Y_i}{\sum_{i\in c,y}w_i\,\delta_i},\qquad \widehat V=\sum_h\frac{n_h}{n_h-1}\sum_{j}(z_{hj}-\bar z_h)^2,\quad z_i=\frac{w_i\delta_i(Y_i-\hat\theta)}{\sum_k w_k\delta_k},$$

donde $\delta_i=1$ si la persona $i$ pertenece al dominio; $h$ indexa estratos y $j$ UPM; $n_h$ es el número de UPM del estrato $h$; $z_{hj}$ es la suma de los $z_i$ de la UPM $j$; y $\bar z_h$ es la media de los $z_{hj}$ del estrato.

- $Y$ = actual, con dominio = celda con estado conocido.
- $Y\in\{g, h\}$, con dominio = actuales de la celda con $Y$ observado.
- El diseño se arma con la ola completa y luego se restringe al dominio (`ms-survey-inputs` L110–148).
- Las medias y los EE escritos a mano coinciden con los del paquete `survey` en 2012–2022. En 2024, el ajuste por UPM única (`ms-survey-inputs` L111) cambia el EE en ≤ 0,8 % y no está en la fórmula de arriba [verificado con datos; detalle en el Anexo A].

| Ola | UPM | Estrato | Nota |
|---|---|---|---|
| 2012, 2014, 2018, 2022 | comuna\|UPM de la caché | región (*proxy*) | — |
| 2016 | comuna\|distrito\|zona\|manzana (reconstruida: 2.358 UPM frente a 2.000 con la clave corta; `ms-survey-inputs` L42–47) | región (*proxy*) | — |
| 2020 | **ninguna**: la UPM es NA en los 16.662 registros | la región existe, pero el código no la usa (`ids = ~1`, `ms-survey-inputs` L115) | Que su EE quede subestimado es una hipótesis que no se puede verificar. Ya tiene el mayor EE medio de prevalencia (2,34 pp) y el menor n efectivo (462) |
| 2024 | UPM | `ESTRATO` (109 estratos) | En la prevalencia, 11 estratos tienen una sola UPM en el dominio; el ajuste cambia el EE en ≤ 0,8 % (Anexo A) |

EE medio de la prevalencia por ola: 2,08 / 2,26 / 2,22 / 2,12 / 2,34 / **1,56** / 1,89 pp. n efectivo medio por celda: 604 / 558 / 603 / 581 / 462 / **1.075** / 687 [verificado con datos]. Nota: la ola 2022 tiene pesos atípicos: CV de pesos 1,05 frente a 1,58–1,91 en las otras olas, n efectivo/n de 0,47 y una suma de pesos que cubre el 91 % del INE. Por eso sus intervalos son los más estrechos [leído, no corrido].

**Las 56 metas** (7 olas × 2 sexos × 4 grupos de edad). `ms_targets` contiene actual, g/d y HED, cada uno con su EE (`ms-survey-inputs` L148). Nunca y ex **no** son metas del código, pero sus medias y EE de diseño por celda están en el Anexo B. Aquí va la meta de consumo actual; las de g/d y HED están en las secciones 3 y 4, y las cinco tablas completas (actual, nunca, ex, g/d y HED, con las 7 olas) en el Anexo B. Meta de consumo actual, % (EE de diseño):

| Celda | 2012 | 2014 | 2016 | 2018 | 2020 | 2022 (held-out) | 2024 (held-out) |
|---|---|---|---|---|---|---|---|
| M 15–29 | 36,4 (1,8) | 43,2 (1,9) | 44,6 (2,0) | 38,2 (1,8) | 38,5 (1,9) | 35,3 (1,5) | 29,7 (1,9) |
| M 30–44 | 36,0 (1,7) | 47,7 (1,6) | 44,3 (2,1) | 42,3 (1,9) | 42,6 (2,0) | 40,2 (1,5) | 33,5 (1,6) |
| M 45–59 | 33,2 (1,8) | 45,0 (2,1) | 39,0 (2,1) | 31,9 (1,7) | 39,2 (2,1) | 31,5 (1,3) | 26,7 (1,5) |
| M 60–65 | 24,0 (2,0) | 38,2 (3,1) | 30,3 (2,4) | 27,6 (3,0) | 29,0 (2,5) | 23,0 (1,4) | 17,8 (1,6) |
| H 15–29 | 51,6 (2,0) | 53,7 (1,9) | 56,3 (1,9) | 54,7 (1,7) | 51,8 (2,4) | 41,5 (1,6) | 40,8 (2,3) |
| H 30–44 | 58,3 (1,8) | 65,3 (2,0) | 59,8 (1,9) | 59,9 (2,1) | 62,9 (2,3) | 55,5 (1,6) | 50,3 (1,8) |
| H 45–59 | 51,9 (2,2) | 57,4 (2,2) | 53,4 (2,1) | 54,7 (1,8) | 53,5 (2,5) | 47,8 (1,6) | 42,7 (1,9) |
| H 60–65 | 44,2 (3,3) | 54,9 (3,2) | 46,6 (3,2) | 48,4 (3,0) | 45,7 (3,1) | 38,3 (2,1) | 33,0 (2,5) |

[verificado con datos]

### Demografía y mortalidad: qué se usa exactamente

| Insumo | Qué se usa | Para qué | Qué **no** se usa |
|---|---|---|---|
| INE (`ine_proyecciones_rebuild/ine_basedatos.xlsx`, hoja `BBDD_EEPP-2024_0101`), 2012–2034, 15–65 | Stock al **1 de enero** por sexo × edad simple | Peso $\omega$, población inicial 2012, ajuste anual de stocks y calibración de $\kappa$ (`ms-annual-engine` L51–57, L103–119; `ms-calibration-functions` L61) | El stock al **30 de junio** sólo aparece en una columna diagnóstica (`ms-mortality-concordance` L14). **Ninguna celda calcula una tasa central** |
| HMD Chile 1×1 (`mltper_1x1.txt`, `fltper_1x1.txt`), 2012–2024, 15–65 | $q_x$, una **probabilidad**, no una tasa central | Riesgo de muerte del motor, elevado a $\kappa_s$ (`ms-annual-engine` L85) | $m_x$ es sólo diagnóstico (`ms-mortality-concordance` L14); $a_x$, $l_x$, $d_x$, $L_x$, $T_x$ y $e_x$ se leen y se descartan |
| DEIS: 2012–2023 (bundle, ya filtrado a `EDAD_TIPO == 1`) y 2024 (archivo semanal `06102026` vía `acc_deis()`, `AÑO == 2024`, `EDAD_TIPO == 1`), 15–65 | Total de defunciones por sexo: 399.836 en 2012–2024 (141.199 M; 258.637 H) | Calibración de $\kappa_s$ con ≤ 2020 (`ms-calibration-functions` L58–62) y concordancia | Tasas por edad, causas de muerte y defunciones a los 66+. Las filas provisionales 2025–2026 se excluyen (`ms-demography-inputs` L67–70) |

Tu texto: «INE: población al 01-Ene y al 30-Jun para estimar tasas centrales; HMD: qx y mx tasas centrales; Defunciones DEIS, 15-65». Nota: hoy el motor no estima ninguna tasa central. Usa $q_x$ de HMD, cuya exposición es la de HMD y no la del INE, la aplica a los stocks INE de enero y ajusta el nivel con un $\kappa$ por sexo. Las consecuencias están en la sección 6. Las versiones de los insumos frente a la exportación guardada están en el Anexo A.

## Ciclo anual (flujo anual)

Tu texto: «[1 de enero: Muestra de sintéticos] -> [Asignación de Exposición] (Mapeo de Z latente a variables continuas/categorías) -> [Evaluación de Mortalidad] (Sorteo uniforme vs q* -> Remoción definitiva si fallece) -> [Envejecimiento (Edad + 1)] (Salida automática de personas con edad = 66) -> [Ajuste de Stocks INE] (Entrada a los 15 años + Flujos residuales Inflow/Outflow) -> [Actualización Latente] (Transición de Z mediante Cópula Gaussiana con rho)».

Abajo, tu diagrama corregido al orden exacto del código (`ms-annual-engine` L45–145). Las marcas ★ son cambios respecto de tu versión; los números de línea son de `ms-annual-engine`, y § indica la sección de este documento que explica cada paso.

```
INICIO (sólo t = 2012)
[1 de enero 2012: población sintética]                          §7     L48–58
   ★ no es una muestra: réplica determinista de los stocks INE 01-ene,
     n(s,x) = round(N_ene / ω) por sexo × edad simple
   Z^status, Z^amount, Z^HED ~ N(0,1) independientes; ever = NA
        │
[Asignación de exposición 2012]  ms_exposure (L13–43)                  L59
   mapeo de Z, en este orden (L18–39):
   §1 actual → §3 g/día → §4 HED → §2 ever/estado → §5 categoría
        │
        ▼  CICLO DEL AÑO t
[★ Registro 1-ene t]  resumen por sexo × grupo ANTES de las      §8     L69–79
   muertes (es lo que se compara con las metas)
        │
[Evaluación de mortalidad]  U ~ U(0,1), independiente de Z      §6     L82–95
   y del consumo; muere si U < q*(min(t,2024), s, edad al 1-ene)
   → remoción definitiva
        │   (si t es el último año: fin; la población final son los sobrevivientes)
[Envejecimiento: edad + 1]                                      §7     L100
[Salida: edad > 65, es decir, con 66]                           §7     L101–102
        │
[Ajuste de stocks INE al 1-ene t+1]  por sexo × edad SIMPLE:    §7     L103–120
   Δ = n(t+1,s,x) − sobrevivientes
   Δ < 0 → outflow residual: se eliminan |Δ| al azar (sample.int)      L111
   Δ > 0 → personas nuevas (edad 15 = entradas; otra = inflow)         L115–117
   ★ las personas nuevas reciben Z frescas N(0,1) y ever = NA
        │
[Actualización latente]  sólo sobrevivientes ya conciliados;    §0     L123–126
   ★ 3 latentes, mismo ρ, innovaciones independientes
   Z_t+1 = ρ·Z_t + √(1−ρ²)·ε
        │
[★ Asignación de exposición t+1 a la EDAD ALCANZADA]        §1–§5      L127
   sobrevivientes con su Z actualizada;
   nuevos con su Z fresca, sin paso AR, y ever sorteado                L129–130
        │
[Chequeos: identidad contable, sin IDs duplicados,              §7     L131–135
   stocks INE exactos]
        └──► vuelve a [Registro 1-ene t+1]
```

Nota:

- Tu numeración 0–5 va por componente; el año la recorre en otro orden. Dentro de `ms_exposure` el orden es §1 → §3 → §4 → §2 → §5, y la actualización latente (§0) va al final del año, justo antes de asignar la exposición de $t+1$.
- La exposición del año $t$ se asigna al cierre de $t-1$, con la edad ya alcanzada. Por eso el registro del 1 de enero ya la contiene. Es mejor que asignarla con la edad del año anterior.
- Hoy la mortalidad **no** usa la exposición: el diagrama sugiere un vínculo exposición → muerte que todavía no existe (comentario `ms-annual-engine` L81).

## Especificación vigente en tu formato (motor BASE)

Lo que hace hoy el código, escrito con tu esqueleto. Es una descripción, no una recomendación: cada línea remite a la sección (§) donde se explica y a la fila (#) de decisiones de la sección 10.

**Parámetros.**

- Entrenamiento 2012–2020 (`ms_fit(2020)`); held-out 2022 y 2024 (§8).
- Proyección 2025–2034 con `ms_fit(2024)` (7 olas), 1 semilla y $\tau$, $q_x$ congelados en 2024 (§8; #12, #13).
- 25.000 sintéticos sólo el 1 de enero de 2012; $\omega=481{,}249$ fijo; después $n_{t,s,x}=\mathrm{round}(N^{ene}_{t,s,x}/\omega)$ (§7; #16). 5 semillas sólo en la validación.
- $\rho=0{,}8$ para las tres latentes (§0; #4).

**Insumos.**

- ENPG: estado (nunca / FD / actual); $g=\tfrac{12}{30}[\max(d-e,0)\,\bar q+e\,b_s]$; HED $=\mathbf 1(e>0)$ (Insumos).
- Metas de diseño (media de Hájek y EE) para actual, g/d y HED en 56 celdas; nunca y FD no son metas (Insumos; Anexo B).
- INE: stock al 1 de enero. HMD: $q_x$. DEIS: total de muertes 15–65 por sexo (§6).

**Flujo anual.** [Registro 1-ene] → [Mortalidad: $U^{death}<q^*$] → [Edad + 1; salida con 66] → [Ajuste INE por sexo × edad simple: entradas a los 15, inflow/outflow residual; nuevos con $Z\sim N(0,1)$ y `ever` = NA] → [AR(1) de las 3 latentes en los sobrevivientes] → [Exposición $t+1$ a la edad alcanzada] (Ciclo anual; §7).

0. **LATENTES:** $Z^{j}_{it}=\rho Z^{j}_{i,t-1}+\sqrt{1-\rho^2}\,\varepsilon^{j}_{it}$, $j\in\{status, amount, HED\}$, independientes entre sí; $Z^j\sim N(0,1)$ al entrar; $U^j=\Phi(Z^j)$ (§0; #4).
1. **ACTUAL:** $\operatorname{logit}pc_c(t)=\alpha_c+\beta_c\tau^*_t$, con $\tau^*_t=(\min(t,2024)-2012)/10$ y WLS delta sobre 40 metas; $C_{it}=\mathbf 1\{U^{status}_{it}<pc\}$ (§1; #11, #12).
2. **ESTADO HISTÓRICO:** al entrar, $ever=C\vee\mathbf 1\{V<p_F(s,a)\}$, con $V\sim U(0,1)$ independiente de $Z$ y $p_F$ agrupada 2012–2020; después $ever_t=ever_{t-1}\vee C_t$. Estado: actual si $C=1$; ex si $C=0$ y $ever=1$; nunca en otro caso (§2; #1, #2).
3. **INTENSIDAD** (si $C=1$): $\mu_c(t)=\exp(\alpha^\mu_c+\beta^\mu_c\tau^*_t)$ (WLS en log); $U^{amount}=\Phi(Z^{amount})$, independiente de $Z^{status}$; $g=0$ si $U^{amount}\le p_{0,c}$; si no, $g=F^{-1}_\Gamma\big((U^{amount}-p_0)/(1-p_0);\,k_c,\,\mu/(k(1-p_0))\big)$; $k_c$ y $p_{0,c}$ agrupados 2012–2020 (§3; #3, #5, #9).
4. **HED** (si $C=1$ y $g>0$): $\operatorname{logit}p^{HED}=\gamma_c+\gamma_{gpd}\log(1+g)$ (glm cuasi-binomial, sin año); HED $=\mathbf 1\{U^{HED}<p^{HED}\}$ (§4; #6, #7, #8).
5. **CATEGORÍAS:** `noncurrent` si $C=0$; si $C=1$: cat1 si $g<g^{(1)}_s$, cat2 si $g^{(1)}_s\le g<g^{(2)}_s$, cat3 si $g\ge g^{(2)}_s$, con (20, 40) g/d en mujeres y (40, 60) en hombres, en escala de encuesta (§5; #10).
6. **MORTALIDAD:** $q^*=1-(1-q^{HMD}_{\min(t,2024),s,x})^{\kappa_s}$, con $\kappa_s$ calibrado a DEIS 2012–2020; muere si $U^{death}<q^*$; no depende del consumo (§6; #14, #18).
7. **ENVEJECIMIENTO Y STOCKS:** ver el flujo anual (§7; #16, #17).

---

## 0. Proceso base de propensión latente y cópula gaussiana (persistencia AR(1))

### Formulación

$$Z_{it}=\rho\,Z_{i,t-1}+\sqrt{1-\rho^2}\,\varepsilon_{it},\qquad \varepsilon_{it}\sim N(0,1),\qquad \rho=0{,}8,\qquad Z_{it}\sim N(0,1),\qquad U_{it}=\Phi(Z_{it}).$$

Tu texto: «qué tan proclive es esta persona, respecto del resto de la población, a pertenecer a cierta categoría»; «U_it = Phi(Z_it) (posición relativa, percentil)».

**[código] Número de latentes.** El código tiene tres procesos independientes por persona, $j\in\{status, amount, HED\}$:

$$Z^{j}_{it}=\rho\,Z^{j}_{i,t-1}+\sqrt{1-\rho^2}\,\varepsilon^{j}_{it},\qquad \varepsilon^{j}_{it}\ \text{iid}\ N(0,1)\ \text{entre personas, latentes y años},\qquad U^{j}_{it}=\Phi(Z^{j}_{it}).$$

Nota: tu texto reutiliza una sola $U_{it}$ de estado en las secciones 2 y 3, y en la 4 pide «una latente persistente AR(1)», que puede leerse como una latente propia o como el proceso base. El código usa `z_current` para el estado, `z_amount` para la intensidad y `z_hed` para el HED. La sección 2 no usa ninguna latente.

**[faltaba]** Lo que el código fija y tu texto no define:

- **Condición inicial:** $Z^{j}_{i,t^0_i}\sim N(0,1)$ en el año de entrada $t^0_i$. Vale para la población 2012, para los que entran a los 15 años y para el inflow residual.
- **Momento de la actualización:** después del ajuste de stocks INE y antes de la exposición de $t+1$. Quien entra en $t+1$ no se actualiza ese año.
- **Dependencia entre latentes:** ninguna, $\operatorname{corr}(Z^{j},Z^{j'})=0$.

### Intuición

- $Z$ es la posición de la persona frente a quienes comparten su sexo y edad. Cada año su $Z$ pesa 0,8 su valor anterior y 0,6 un shock nuevo ($\sqrt{1-0{,}64}=0{,}6$). En varianza, 64 % es memoria ($\rho^2$) y 36 % es nuevo.
- Como $Z\sim N(0,1)$ todos los años, la prevalencia actual simulada reproduce **en esperanza** la curva ajustada $pc(s,a,t)$ de la sección 1, cualquiera sea $\rho$. No reproduce la meta ENPG: la distancia meta–curva es el residuo del ajuste (sección 1) y fuera de muestra llega a +9,7 pp (sección 8). Para el estado actual, $\rho$ decide **quién** bebe, no **cuántos**. Esto no vale para nunca/ex (ver los valores más abajo).
- La memoria decae geométricamente: a 10 años la correlación es $0{,}8^{10}=0{,}107$.

### Implementación

```r
# ms-annual-engine L8–10: toda persona nueva (población 2012, entradas a 15, inflow)
data.frame(id = ..., sex = sex, age = age,
  z_current = rnorm(n), z_amount = rnorm(n), z_hed = rnorm(n), ever = rep(NA, n))
# ms-annual-engine L123–127: después del ajuste INE (L120), sólo sobrevivientes
for (z in c("z_current", "z_amount", "z_hed"))
  pop[[z]] <- rho * pop[[z]] + sqrt(1 - rho^2) * rnorm(transition_n)
pop <- ms_exposure(pop, year + 1L, drivers)          # L127; los nuevos se agregan en L129–130
```

### Estimación

- **$\rho$ no se estima** [supuesto]. Las encuestas transversales repetidas no identifican la persistencia de los márgenes calibrados (actual, g/d, HED).
- **Derivaciones** [álgebra verificada]:
  1. **Varianza 1 en todo año.** Si $\operatorname{Var}(Z_{t-1})=1$ y $\varepsilon_t\perp Z_{t-1}$, entonces $\operatorname{Var}(Z_t)=\rho^2+(1-\rho^2)=1$. Como $Z_e\sim N(0,1)$ al entrar, la propiedad vale por inducción, y $Z_t$ es normal por ser combinación lineal de normales.
  2. **Autocorrelación.** Para un rezago de $r$ años, $Z_{t+r}=\rho^rZ_t+\sqrt{1-\rho^2}\sum_{m=0}^{r-1}\rho^m\varepsilon_{t+r-m}$, de donde $\operatorname{corr}(Z_t,Z_{t+r})=\rho^r$. El par $(U_t,U_{t+r})$ sigue una **cópula gaussiana** de parámetro $\rho^r$.
  3. **Transformada integral de probabilidad.** $P(\Phi(Z)\le u)=u$, así que $P(U^{status}_{it}<pc)=pc$.
  4. **Tasa anual de cambio de estado.** Como $C_t=\mathbf 1\{Z_t<\Phi^{-1}(p_t)\}$ y $(Z_t,Z_{t+1})$ es normal bivariada con correlación $\rho$, $P(C_t=C_{t+1}=1)=\Phi_2\big(\Phi^{-1}(p_t),\Phi^{-1}(p_{t+1});\rho\big)$, y entonces $P(C_t\ne C_{t+1})=p_t+p_{t+1}-2\,\Phi_2\big(\Phi^{-1}(p_t),\Phi^{-1}(p_{t+1});\rho\big)$, donde $p_t$ es la $pc$ de la persona en el año $t$. Con $p=0{,}45$ fijo y $\rho=0{,}8$ da 20,32 %.
  5. **Las salidas no seleccionan por $Z$:** muerte, salida a los 66 y outflow residual no dependen de $Z$ (`ms-annual-engine` L85–87, L101–102, L111). Por eso los sobrevivientes conservan $N(0,1)$. Esto dejará de valer cuando la mortalidad dependa del consumo.

### Valores estimados

| Medida (5 semillas, 2012–2024) | Simulado | Teórico |
|---|---:|---:|
| corr$(Z^{status}_t,Z^{status}_{t+r})$, $r$ = 1 / 5 / 10 años | 0,801 / 0,330 / 0,110 | 0,800 / 0,328 / 0,107 |
| Varianza de $Z^{status}$ en 65 cortes año × semilla | 0,988–1,028 | 1 |
| KS de $U$ contra Uniforme(0,1) | rechaza en 1 de 65 cortes (mín. p 0,041) | ≈ 3 por azar |
| Cambio anual del estado actual | 19,92 % | 19,92 % (fórmula 4 por persona) |

[verificado con datos; el teórico por persona: corrido, sin verificación independiente]

Tres cifras de cambio anual que no deben confundirse: 20,32 % es la fórmula con $p=0{,}45$ fijo; 19,92 % es la misma fórmula aplicada a cada persona con su $pc_t$ y $pc_{t+1}$, y coincide con lo simulado con 5 semillas; 19,89 % (tabla siguiente) es lo simulado con 1 semilla.

Sensibilidad a $\rho$ (`ms-persistence-sensitivity`, 1 semilla, población 15–65 en 2024) [corrido, sin verificación independiente]:

| $\rho$ | Cambio anual de estado | Actual 2024 | Nunca 2024 | Ex 2024 |
|---:|---:|---:|---:|---:|
| 0 | 48,19 % | 48,72 % | 1,21 % | 50,06 % |
| 0,8 | 19,89 % | 48,08 % | 5,19 % | 46,72 % |
| 0,95 | 9,77 % | 48,27 % | 11,29 % | 40,43 % |

Nota: la exportación guardada (`microsim_base_outputs/persistence_sensitivity.csv`, con el DEIS anterior) da valores parecidos: cambio anual 48,2 / 19,8 / 9,8 % y nunca 1,2 / 5,2 / 11,2 % [leído, no corrido]. El estado actual no se mueve con $\rho$, pero nunca/ex sí se mueven, porque `ever` acumula. El margen HED tampoco depende de $\rho$: con 5 semillas, el sesgo de entrenamiento es −4,92 pp con $\rho=0$ y −5,10 pp con $\rho=0{,}8$, una diferencia menor que su DE Monte Carlo (≈ 0,28 pp) [verificado con datos].

**Evidencia externa sobre $\rho$ (EPS, 50+ años, n = 1.744)** [leído, no corrido; `auditoria_microsim_2026-10-09/persistence.md` y `persistence_verify.md`]:

| Rezago $r$ (años) | 3,67 | 4,02 | 7,69 |
|---|---:|---:|---:|
| EPS, correlación tetracórica bebe/no bebe | 0,566 | 0,588 | 0,478 |
| Motor, $\rho^r$ | 0,441 | 0,408 | 0,180 |
| Rasgo + AR(1) ajustado ($\lambda=0{,}453$, $\varphi_{AR}=0{,}679$) | 0,585 | 0,568 | 0,481 |

Cómo leer la tabla:

- Bajo el modelo de umbral gaussiano, la tetracórica de bebe/no bebe estima $\operatorname{corr}(Z_t,Z_{t+r})$, así que se compara directamente con $\rho^r$.
- **Rasgo + AR(1):** $Z=\sqrt\lambda\,u+\sqrt{1-\lambda}\,a_t$, con un rasgo fijo $u\sim N(0,1)$ y un AR(1) anual $a_t$. Entonces $\operatorname{corr}(Z_t,Z_{t+r})=\lambda+(1-\lambda)\varphi_{AR}^{\,r}$, donde $\lambda$ es la fracción de varianza del rasgo fijo y $\varphi_{AR}$ la persistencia anual del componente AR. $r(1)$ es esa correlación a 1 año (0,824 con los valores ajustados).

### Supuestos y limitaciones

- La EPS rechaza un AR(1) puro con $\rho=0{,}8$ como modelo de memoria larga. Un rasgo estable más un AR(1) ajusta.
- El paso de un año no está identificado, porque los rezagos de la EPS son ≥ 3,67 años. En la región compatible con la EPS, $r(1)$ va de 0,51 a 0,88, y el cambio anual implicado, de 15,6 % a 32,7 % [leído, no corrido].
- **Mismo $\rho$ para las tres latentes** [supuesto]:
  - En la EPS, la persistencia de g/día entre quienes beben en ambas entrevistas es plana (0,33 / 0,39 / 0,38), contra 0,18 implicado a 7,7 años.
  - La EPS no tiene un ítem HED. `persistence.md` usa como *proxy* la ocasión típica de 5+/4+ tragos [leído, no corrido].
- Las tres latentes son independientes: no hay un rasgo común entre participación, monto y HED.

> **Tu formulación vs el código**
>
> | Elemento | Tu formulación | Código | Estado | Consecuencia |
> |---|---|---|---|---|
> | Ecuación AR(1) y $U=\Phi(Z)$ | la escrita arriba | idéntica (`ms-annual-engine` L125–126; `pnorm`) | coincide | — |
> | Número de latentes | $U^{status}$, reutilizada para historia e intensidad; HED con «latente persistente» (¿propia o la base?) | 3 independientes; la historia usa `runif` | difiere | Ver las secciones 2 y 3 |
> | $\rho$ por latente | un único $\rho$ estructural = 0,8 | el mismo $\rho$ para las 3 | coincide | Es la lectura literal de tu texto, pero para g/d no hay evidencia de esa persistencia (EPS plana) |
> | Condición inicial | $Z_{it}\sim N(0,1)$; no dices qué pasa al entrar | $N(0,1)$ al entrar; los nuevos no se actualizan en su año | no definido | Los inmigrantes entran sin historia latente |
> | Momento de la actualización | después del ajuste INE (tu diagrama) | ídem; sólo los sobrevivientes | coincide | — |
> | Umbral | $U\le p$ | $U<p$ | coincide | Probabilidad cero de empate |
> | Correlación entre latentes | no la defines | 0 | no definido | Participación y monto quedan independientes (margen extensivo) |

---

## 1. DGP prevalencia de consumo actual

### Formulación

$$\operatorname{logit}pc(s,a,t)=\alpha_{s,a}+\beta_{s,a}\,\tau_t,\qquad pc(s,a,t)=\frac{1}{1+e^{-(\alpha_{s,a}+\beta_{s,a}\tau_t)}},\qquad \tau_t=\frac{t-2012}{10}.$$

$$\text{Is\_Current}_{it}=\mathbf 1\{U^{status}_{it}\le pc(s_i,a_i,t)\}.$$

Tu texto: «más bajo, más propenso; memoria 0,8»; «s sexo; a grupo de edad; t = (año-2012)/10» (aquí $\tau$).

Lo que el código agrega:

- **[faltaba] Tiempo en el motor:** $\tau^*_t=(\min(t,2024)-2012)/10$. De 2025 en adelante, $pc$ queda fija en su valor de 2024.
- **[faltaba] Estimador:** mínimos cuadrados ponderados (WLS) sobre el logit de las 40 metas de diseño, con pesos de varianza inversa por método delta:

$$(\hat\alpha,\hat\beta)=\arg\min\sum_{c}\sum_{y\le2020}v_{c,y}\big(\operatorname{logit}\hat p_{c,y}-\alpha_c-\beta_c\tau_y\big)^2,\qquad v_{c,y}=\Big(\frac{\hat p_{c,y}(1-\hat p_{c,y})}{\widehat{EE}_{c,y}}\Big)^2.$$

Nota: no es una regresión logística individual.

### Intuición

- Para cada ola, sexo y grupo de edad, la encuesta dice qué fracción bebió en el último mes y con qué precisión. Esa fracción se pasa a logit y se ajusta una recta en el tiempo por celda; las olas más precisas pesan más.
- En el motor, cada persona bebe si su percentil persistente cae bajo la curva de su celda ese año.

### Implementación

```r
# ms-calibration-functions L14, L16, L22, L24: estimación
target$y_current <- qlogis(target$current_mean)
target$w_current <- (target$current_mean * (1 - target$current_mean) / target$current_se)^2
formula_current <- if (trend) y_current ~ 0 + cell + cell:time else y_current ~ 0 + cell
prevalence <- lm(formula_current, data = fit_data, weights = w_current)
# ms-calibration-functions L78–79: tiempo congelado en 2024
grid$time <- (pmin(grid$year, ms_cfg$observed_end) - ms_cfg$start_year) / 10
grid$p_current <- plogis(predict(model$prevalence, newdata = grid))
# ms-annual-engine L18: asignación individual
pop$current <- pnorm(pop$z_current) < d$p_current
```

### Estimación

- **Pesos por método delta.** Con $g(p)=\operatorname{logit}p$ y $g'(p)=1/[p(1-p)]$, se tiene $\operatorname{Var}(\operatorname{logit}\hat p)\approx\widehat{EE}^2/[\hat p(1-\hat p)]^2$; su inverso es $v_{c,y}$. Como $\widehat{EE}$ ya es de diseño, el efecto de diseño queda incluido. Un chequeo Monte Carlo dio un error relativo máximo de 1,06 %.
- **Forma cerrada.** La matriz `0 + cell + cell:time` es diagonal por bloques, así que el ajuste se separa en 8 rectas WLS de 5 puntos:

$$\hat\beta_c=\frac{\sum_y v_{cy}(\tau_y-\bar\tau_c)(\ell_{cy}-\bar\ell_c)}{\sum_y v_{cy}(\tau_y-\bar\tau_c)^2},\qquad \hat\alpha_c=\bar\ell_c-\hat\beta_c\bar\tau_c,\qquad \ell_{cy}=\operatorname{logit}\hat p_{cy}.$$

- **Varianza.** `lm` estima $\hat\sigma^2=\sum v e^2/(40-16)$ y reporta $\hat\sigma^2(X^\top VX)^{-1}$. Esa incertidumbre **no** se propaga al motor, que usa sólo los puntos estimados.
- **Diferencia con la logística individual.** Las ecuaciones de *score* de la logística individual, agregadas por ola, son $\sum_yW_{cy}(\hat p_{cy}-\pi_{cy})=0$ y $\sum_yW_{cy}\tau_y(\hat p_{cy}-\pi_{cy})=0$, donde $W_{cy}=\sum_{i\in c,y}w_i$ es el total expandido de la celda en la ola y $\pi_{cy}=\operatorname{logit}^{-1}(\alpha_c+\beta_c\tau_y)$ es la probabilidad del modelo. Ponderan por el total expandido $W_{cy}$, no por la precisión, así que difieren del WLS salvo con un modelo saturado.

### Valores estimados

Coeficientes de `ms_fit(2020)` y $pc$ de 2024, en % (IC 95 % con $t_{24}$) [verificado con datos]:

| Celda | $\hat\alpha$ | $\hat\beta$ (por década) | EE($\hat\beta$) | Estadístico t de $\hat\beta$ | $pc$ 2024, ajuste 2012–2020 | Observado 2024 | $pc$ 2024, reajuste 2012–2024 |
|---|---:|---:|---:|---:|---|---:|---:|
| M 15–29 | −0,400 | −0,009 | 0,258 | −0,03 | 39,9 [29,7; 51,1] | 29,7 | 33,9 |
| M 30–44 | −0,347 | 0,146 | 0,250 | 0,58 | 45,7 [34,9; 56,9] | 33,5 | 38,0 |
| M 45–59 | −0,509 | −0,028 | 0,272 | −0,10 | 36,8 [26,5; 48,4] | 26,7 | 29,8 |
| M 60–65 | −0,920 | 0,105 | 0,390 | 0,27 | 31,1 [18,3; 47,7] | 17,8 | 21,3 |
| H 15–29 | 0,127 | 0,067 | 0,271 | 0,25 | 55,2 [43,2; 66,6] | 40,8 | 43,1 |
| H 30–44 | 0,412 | 0,093 | 0,282 | 0,33 | 62,8 [50,2; 73,9] | 50,3 | 53,8 |
| H 45–59 | 0,157 | 0,026 | 0,295 | 0,09 | 54,7 [41,9; 66,9] | 42,7 | 46,0 |
| H 60–65 | −0,047 | −0,081 | 0,419 | −0,19 | 46,4 [29,7; 64,0] | 33,0 | 36,4 |

Lectura de la tabla:

- **Ajuste.** $\hat\sigma^2=4{,}26$ con 24 gl ($\chi^2=102{,}2$; $p=1{,}2\cdot10^{-11}$): la varianza residual es 4,3 veces la de diseño, y el exceso entre olas, ≈ 3,3 veces.
- **Choques comunes por ola.** El residuo estandarizado medio es −1,71 en 2012 (0/8 celdas positivas) y +2,23 en 2014 (8/8).
- **Pendientes.** Ninguna está identificada: el máximo del estadístico $\lvert t\rvert$ es 0,58.
- **Prevalencia nacional 15–65** (ponderada por INE): 47,05 % en 2012, 48,36 % en 2024 y 48,32 % congelada en 2034. Lo observado fue 41,00 % (2022) y 36,28 % (2024). El reajuste 2012–2024, el modelo que se proyecta, da 39,80 % en 2024 y 32,14 % en 2034 si no se congela.
- **El motor reproduce $pc$ en esperanza.** En 104 año-celdas, $z=(\hat p^{sim}-pc)/\sqrt{pc(1-pc)/n}$, con $\hat p^{sim}$ la prevalencia simulada de la celda, tiene media 0,050, DE 1,016 y máximo 2,41.

### Supuestos y limitaciones

- **La tendencia lineal no está identificada en 2012–2020, y el fracaso fuera de muestra es de nivel.** El 93 % del sesgo held-out persiste si se quita la pendiente: 9,07 / 9,76 = 0,93 (sección 8).
- **El estimador.** Una logística individual ponderada con el mismo predictor cambia los coeficientes hasta en 0,18 (la pendiente de M 60–65 pasa de +0,105 a −0,076). Su RMSE held-out es 9,72 pp, frente a 10,30 pp del WLS [verificado con datos].
- **2020.** Tiene un diseño sin UPM y pesa el 17,4 % del ajuste. **2022** tiene pesos atípicos (ver Insumos).
- **$pc$ es constante dentro de cada grupo de edad,** con saltos a los 30, 45 y 60 años. El grupo 60–65 tiene sólo 6 edades y un n efectivo de 216 a 1.028.

> **Tu formulación vs el código**
>
> | Elemento | Tu formulación | Código | Estado | Consecuencia |
> |---|---|---|---|---|
> | Forma funcional | logit lineal con $\alpha_{s,a}$, $\beta_{s,a}$ | `0 + cell + cell:time`: 8 α + 8 β (`ms-calibration-functions` L22) | coincide | — |
> | $\tau$ | $(t-2012)/10$ en todo año | igual hasta 2024; después congelado (`ms-calibration-functions` L78) | difiere | Sólo en 2025–2034. Reajuste 2012–2024 en 2034: 39,8 % congelado frente a 32,1 % sin congelar (hasta −11,5 pp en H 60–65) |
> | Estimador e incertidumbre | no los defines | WLS delta; σ̂² común; sin propagación al motor | no definido | IC de $pc$ 2024 de ±11–17 pp, invisible para las 5 semillas |
> | Metas («UPM y estratos/regiones») | diseño completo | región como estrato *proxy*; 2020 sin UPM; 2024 con `ESTRATO` | difiere | Sobre todo en 2020: su EE tal vez está subestimado (no verificable) |
> | Asignación | $U\le pc$ | `pnorm(z_current) < p_current` | coincide | — |
> | Cortes de edad | «4 grupos» | 15–29, 30–44, 45–59, 60–65 | no definido | Saltos de $pc$ entre grupos |

---

## 2. DGP estado histórico (Former vs Never)

> **Tres variantes que se comparan en esta sección** (mismos números aleatorios, 5 semillas):
>
> - **V0** = el código: sorteo independiente (`runif`) una sola vez, al entrar.
> - **V1** = propuesta de este documento: tu regla latente, pero aplicada sólo al entrar.
> - **V2** = tu regla literal: la regla latente cada año, para todo no actual con $ever_{t-1}=0$.

### Formulación

Sólo si $\text{Is\_Current}_{it}=0$:

- Si $ever_{i,t-1}=1$: Status = former y $ever_{it}=1$.
- Si $ever_{i,t-1}=0$:

$$U^{history}_{it}=\frac{U_{it}-pc}{1-pc},\qquad \begin{cases}U^{history}_{it}\le p_{former}\ \Rightarrow\ \text{former},\ ever_{it}=1\\ \text{si no}\ \Rightarrow\ \text{never},\ ever_{it}=0\end{cases}$$

Tu texto: «como U_it > pc, se reescala el tramo (pc,1] a (0,1)»; «usamos esa tendencia histórica del individuo, en vez de un sorteo condicional independiente».

**[código] Lo que hace el código:**

$$ever_{i,t^0_i}=C_{i,t^0_i}\ \vee\ \mathbf 1\{V_i<p_F(s_i,a_i)\},\quad V_i\sim U(0,1)\ \text{independiente de } Z;\qquad ever_{it}=ever_{i,t-1}\vee C_{it}\ \ (t>t^0_i).$$

- El sorteo independiente se hace **una sola vez**, al entrar ($ever$ = NA). Eso incluye a **toda** la población inicial de 2012, a los que entran a los 15 años y al inflow residual.
- Después, `ever` sólo puede pasar de 0 a 1 si la persona es bebedora actual algún año.
- Estado: actual si $C=1$; ex si $C=0$ y $ever=1$; nunca en otro caso.

**[faltaba]** Lo que tu texto no define:

- $ever_{t-1}$ de quien entra.
- La definición operativa de $p_{former}$. En el código es

$$\hat p_F(s,a)=\frac{\sum_{y\le2020}\sum_{i\in c,y,\,C_i=0}w_i\,\mathbf 1[ever_i]}{\sum_{y\le2020}\sum_{i\in c,y,\,C_i=0}w_i},$$

  agrupada sobre 2012–2020, ponderada por el factor de expansión, **constante en el tiempo** y sin EE de diseño.

**Forma equivalente de tu regla.** Con $pc$ y $p_F$ fijos, y **sólo para quien tiene $ever_{t-1}=0$**:

$$U^{history}\le p_F\iff \frac{U-pc}{1-pc}\le p_F\iff U\le pc+p_F(1-pc)=1-(1-pc)(1-p_F)=1-p_{never},$$

donde $p_{never}=(1-pc)(1-p_F)$ es la proporción de nunca bebedores de la celda.

Nota: tu regla es un modelo ordinal sobre una sola latente: actual, luego ex, luego nunca. El ex es el no bebedor más cercano al umbral de consumo. Con $ever_{t-1}=1$ el resultado es ex, cualquiera sea $U$.

### Intuición

- Tu regla clasifica como «ex» a los no bebedores más propensos a beber y como «nunca» a los más alejados del umbral. El código hace el reparto al azar, una sola vez.
- Como `ever` es absorbente y $Z$ olvida su posición ($\rho^r\to0$), todo nunca bebedor termina cruzando algún umbral. La proporción de nunca se erosiona en las tres variantes. No llega a cero: converge a un nivel estacionario mayor que 0 (y ex/(ex + nunca), a uno menor que 1), fijado por la renovación (entradas a los 15, salidas a los 66), pero ese nivel está lejos del observado.
- **En V2, alguien pasa a ex sin haber bebido en ningún año simulado.** Basta que su $U$ entre en la franja $(pc,\,1-p_{never}]$ sin bajar de $pc$ (la persona B de la sección 9 es un ejemplo). Eso contradice la definición de FD, que exige haber bebido alguna vez.
- **Advertencia.** $U^{history}$ es uniforme entre **todos** los no actuales (de hecho, $P(U^{history}\le p_F)=0{,}631$–$0{,}638$, igual a la media de $p_F$). No es uniforme entre quienes fueron nunca el año anterior: para ellos $Z_{t-1}$ era alto, y $P(U^{history}\le p_F)$ baja a 0,25–0,33.

### Implementación

```r
# ms-calibration-functions L38–41: p_former agrupada 2012–2020
former <- train |> filter(current == 0, !is.na(ever)) |> group_by(sex, age_group) |>
  summarise(p_ever_noncurrent = weighted.mean(ever, weight))
# ms-annual-engine L30–34: sorteo al entrar, acumulación y estado
fresh <- is.na(pop$ever)
pop$ever[fresh] <- pop$current[fresh] | runif(sum(fresh)) < d$p_ever_noncurrent[fresh]
pop$ever <- pop$ever | pop$current
pop$alc_status <- ifelse(pop$current, "current", ifelse(pop$ever, "former", "never"))
```

### Estimación

$\hat p_F=\sum_y\psi_y\hat p_{F,y}$, donde $\psi_y$ es la participación de la ola en los pesos de no actuales de la celda (0,16–0,24). Es decir, cada ola pesa según su población expandida. La prueba de no filtración pone `current = 0` a todos los respondentes fuera de muestra y exige un `shape` idéntico (ese objeto contiene $p_F$). `ever` no se altera.

### Valores estimados

$\hat p_F$ [verificado con datos]:

| Celda | Agrupada 2012–2020 (la que usa el motor) | 2012 | 2024 |
|---|---:|---:|---:|
| M 15–29 / 30–44 / 45–59 / 60–65 | 0,590 / 0,651 / 0,633 / 0,573 | 0,511 / 0,549 / 0,487 / 0,433 | 0,502 / 0,632 / 0,572 / 0,548 |
| H 15–29 / 30–44 / 45–59 / 60–65 | 0,559 / 0,705 / 0,704 / 0,721 | 0,430 / 0,596 / 0,594 / 0,587 | 0,578 / 0,674 / 0,615 / 0,711 |

- **Entradas a los 15 años.** Usan el valor de 15–29 (0,590 / 0,559), cuando el dato a los 15 años es 0,348 (M) / 0,296 (H).
- **Brecha de 2012.** En 2012, nunca simulado es 23,4 % (M) y 15,7 % (H), frente a 32,2 % y 21,8 % observado (con los mismos pesos de celda). De esa brecha, usar la $p_F$ propia de 2012 cerraría 6,7 y 5,3 pp.

Nunca y ex, población 15–65, %. Se comparan V0 (código), V1 (propuesta: tu regla sólo al entrar) y V2 (tu regla cada año, tal como está escrita). Las tres usan los mismos números aleatorios y 5 semillas; la DE Monte Carlo es ≤ 0,7 pp en nunca y ≤ 0,8 pp en ex [verificado con datos]:

| Año | Nunca ENPG (EE) | Nunca V0 / V1 / V2 | Ex ENPG (EE) | Ex V0 / V1 / V2 |
|---|---|---|---|---|
| 2012 | 27,5 (1,0) | 19,4 / 19,6 / 19,6 | 29,2 (0,7) | 33,6 / 33,4 / 33,4 |
| 2014 | 18,2 (0,6) | 13,5 / 17,2 / 9,1 | 30,8 (0,8) | 39,4 / 35,7 / 43,7 |
| 2016 | 16,7 (0,6) | 10,3 / 13,8 / 5,3 | 35,0 (0,8) | 42,2 / 38,7 / 47,1 |
| 2018 | 19,4 (0,7) | 8,2 / 11,1 / 3,7 | 34,9 (0,7) | 44,1 / 41,2 / 48,5 |
| 2020 | 16,4 (0,6) | 6,8 / 9,2 / 2,8 | 36,9 (0,8) | 45,4 / 43,0 / 49,4 |
| 2022 | 20,8 (0,6) | 5,7 / 7,7 / 2,3 | 38,6 (0,6) | 46,2 / 44,2 / 49,7 |
| 2024 | 25,8 (0,7) | 5,0 / 6,6 / 2,0 | 38,3 (0,7) | 46,7 / 45,1 / 49,6 |

| Variante | MAE nunca: entrenamiento / held-out (pp) | Nunca→actual por año | Nunca→ex por año | Ex→actual por año | Ex/(ex + nunca) en 2024 (ENPG 0,597) |
|---|---|---:|---:|---:|---:|
| V0 (código) | 8,0 / 18,5 | 15,3 % | 0 | 19,9 % | 0,903 |
| V1 (latente al entrar) | 5,6 / 16,8 | 10,6 % | 0 | 21,7 % | 0,872 |
| V2 (latente cada año) | 11,8 / 21,8 | 3,2 % | 23–33 % | 21,1 % | 0,961 |

[verificado con datos]

- **Orden por $Z$ en V1.** No se ve dentro de V1 (V0 también tiene ex→actual > nunca→actual): se ve en la diferencia V1 − V0. Ex→actual sube 1,7 pp (21,7 frente a 19,9 %) y nunca→actual baja 4,6 pp (10,6 frente a 15,3 %).
- **V1 no olvida rápido su posición** ($\rho^3=0{,}51$, $\rho^4=0{,}41$). Su tasa nunca→actual sube de 2,5–5,8 % en 2012→13 a 9,9–16,1 % en 2023→24, todavía 2–3 pp bajo V0 (12,1–19,1 %).
- **Todas las variantes tienen tasas de inicio implausibles.** El riesgo retrospectivo de inicio en ENPG es ≤ 0,7 %/año desde los 31 años y 1,6–2,5 %/año entre los 26 y los 29 [leído, no corrido]. En V0 y V1, nunca→actual (6–21 %/año según sexo y edad) ya es 9–30 veces mayor. La conversión nunca→ex de V2 (23–33 %/año) lo es 10–50 veces.

### Supuestos y limitaciones

- **La erosión de «nunca» es estructural, no un problema del valor de $\rho$.** Con el mismo motor, un rasgo más AR(1) sólo lleva nunca 2024 a 7,6–8,1 %. Una clase absorbente de abstemios de por vida («stayers») lo lleva a 15,8–17,4 % (1 semilla) [RECALIB]. Eso detiene la erosión, pero no valida $\lambda$ ni $\varphi_{AR}$ [leído, no corrido].
- **ENPG «nunca» no se comporta como absorbente:** 16,4 % (2020) → 20,8 % (2022) → 25,8 % (2024). Hay efectos de ola dentro de las cohortes. Ningún `ever` irreversible reproduce a la vez 2012 y 2024, así que conviene validar contra 2014–2022 con una banda de tolerancia.
- **Ex de 30 días frente a RR de exbebedor**, que supone ≥ 12 meses (D4).
- **Las historias no alimentan el RR** (regla vigente D4b, `auditoria_microsim_2026-10-09/notes_decisions.md`). Si lo hicieran, en mujeres de 60–65 años en 2024 habría:
  - ex 62,8 / 60,6 / 68,1 % (V0/V1/V2), frente a 45,1 % en ENPG;
  - nunca 6,4 / 8,5 / 1,1 %, frente a 37,1 %.

  Nota: el RR de ex se aplicaría a demasiadas personas y casi no quedaría un grupo de referencia de abstemios de por vida. V2 además daría RR de ex a personas que no bebieron en ningún año simulado.
- Con $\rho=1$ y $p$ constantes, las tres variantes serían estables. La erosión viene de $\rho<1$ y del cambio de $pc$ entre grupos de edad.

> **Tu formulación vs el código**
>
> | Elemento | Tu formulación | Código | Estado | Consecuencia |
> |---|---|---|---|---|
> | Regla para quien no tiene historia | latente reescalada $U^{history}\le p_F$ | `runif < p_F`, independiente de $Z$ (`ms-annual-engine` L31–32) | difiere | Misma esperanza el primer año. V1 frente a V0: nunca 2024 6,6 frente a 5,0 %; MAE de entrenamiento 5,6 frente a 8,0 pp |
> | Frecuencia | cada año, si $ever_{t-1}=0$ | una vez, al entrar | difiere | Literal (V2): nunca 2024 2,0 %, nunca→ex 23–33 %/año |
> | $ever_{t-1}$ al entrar | no lo defines | NA, tratado como «fresco» | no definido | Población 2012, entradas e inflow se sortean |
> | $p_{former}$ | $P(\text{Former}\mid\text{no actual},s,a)$ | agrupada 2012–2020, fija, sin EE | no definido | 6,7 / 5,3 pp de la brecha de 2012 |
> | $p_F$ de quienes entran a los 15 | no la defines | la de 15–29 (0,59 / 0,56) | no definido | El dato a los 15 es 0,35 / 0,30 |
> | Irreversibilidad; actual ⇒ ever | sí | sí (`ms-annual-engine` L33; `stopifnot` L41) | coincide | Ninguna variante reproduce el alza de nunca 2022–2024 |
> | Uso para RR | no lo dices | D4b: no alimenta el RR | no definido | Ver arriba |

---

## 3. DGP intensidad (gpd_survey)

### Formulación

Sólo si $\text{Is\_Current}=1$.

a) Media entre consumidores actuales:

$$\mu(s,a,t)=\exp(\theta_0+\theta_s+\theta_a+\theta_t\,\tau_t).$$

Tu texto: «media log-lineal entre consumidores».

**[código]** Un par de parámetros por celda (16 en total) y tiempo congelado:

$$\mu_c(t)=\exp(\alpha^\mu_c+\beta^\mu_c\,\tau^*_t).$$

b) Mezcla cero-inflada/Gamma. Tu texto: «p0 = proporción de ceros entre consumidores actuales; "U_it^amount = U_it/p0 posición (percentil entre 0 y 1) de la persona dentro del subgrupo de consumidores actuales"; SI U_amount <= p0: gpd = 0; SINO: U_pos = (U_amount - p0)/(1 - p0); gpd = F_Gamma^{-1}(U_pos; shape = k, scale = mu(s,a,t)/(k*(1-p0)))». En notación:

$$U^{amount}\le p_0\Rightarrow g=0;\qquad \text{si no}\ \ U^{pos}=\frac{U^{amount}-p_0}{1-p_0},\quad g=F^{-1}_{\Gamma}\Big(U^{pos};\ k,\ \phi=\frac{\mu(s,a,t)}{k(1-p_0)}\Big).$$

**[errata] Latente del monto.** Tú escribes $U^{amount}=U_{it}/p_0$. Eso no es un percentil: es > 1 casi siempre, y es ∞ si $p_0=0$. Por ejemplo, para una persona con $U=0{,}274$ en M 45–59 ($p_0=8{,}9\cdot10^{-4}$) vale 307. Parece una errata de $U_{it}/pc$, que sí es la «posición dentro del subgrupo de consumidores actuales». Pero con una sola latente, $U$ bajo significa «más propenso», y entonces **los más propensos a beber beberían menos**: el orden queda invertido. **[código]** El código usa una latente propia:

$$U^{amount}_{it}=\Phi(Z^{amount}_{it}),\qquad Z^{amount}\perp Z^{status}.$$

**[faltaba]** $p_0$ y $k$ se estiman agrupando 2012–2020 y no dependen de $t$. Por lo tanto sólo la escala $\phi_{c,t}$ cambia con el año.

### Intuición

- La media de g/d entre bebedores sigue una recta en escala log por celda.
- Alrededor de esa media, los bebedores se reparten según una Gamma muy asimétrica ($k\approx0{,}4$–$0{,}6$): muchos beben muy poco y pocos beben mucho.
- La escala se elige para que el promedio de la celda sea $\mu$ en esperanza.
- El percentil de monto persiste con $\rho$, así que quien bebe mucho tiende a seguir bebiendo mucho.

### Implementación

```r
# ms-calibration-functions L15, L17, L23, L25: media por WLS en log
target$y_amount <- log(target$gpd_mean)
target$w_amount <- (target$gpd_mean / target$gpd_se)^2
formula_amount <- if (trend) y_amount ~ 0 + cell + cell:time else y_amount ~ 0 + cell
amount <- lm(formula_amount, data = fit_data, weights = w_amount)
# ms-calibration-functions L28–37: k por momentos ponderados sobre g > 0; p0 ponderado;
# ambos agrupados con year <= last_year
# ms-annual-engine L20–27: mezcla (p0 = d$p_zero, k = d$shape)
u <- pnorm(pop$z_amount)
positive <- pop$current & u > d$p_zero
pop$gpd_survey <- 0
pop$gpd_survey[positive] <- qgamma(
  pmin(1 - 1e-12, pmax(1e-12,
    (u[positive] - d$p_zero[positive]) / (1 - d$p_zero[positive]))),
  shape = d$shape[positive],
  scale = d$mu_current[positive] / ((1 - d$p_zero[positive]) * d$shape[positive]))
```

### Estimación

- **μ.** $\ell_{c,y}=\log\bar g_{c,y}$, con peso delta $v_{c,y}=(\bar g_{c,y}/\widehat{EE}_{c,y})^2$, en 8 rectas WLS de 5 puntos. La meta $\bar g_{c,y}$ es la media de diseño entre bebedores actuales con g/d observado, **ceros incluidos** (sólo hay 12 ceros, todos de 2014).
- **$p_0$ y $k$.** $\hat p_{0,c}$ es la proporción ponderada de $g=0$. $\hat k_c=\hat m_c^2/\hat s^2_c$, donde $\hat m_c$ y $\hat s^2_c$ son la media y la varianza ponderadas de $g$ entre quienes tienen $g>0$, con olas agrupadas (la varianza incluye la variación entre olas, lo que baja $k$).
- **Derivaciones:**
  1. **La media se cumple:** $E[g\mid\text{actual}]=(1-p_0)k\phi=\mu\Rightarrow\phi=\mu/(k(1-p_0))$.
  2. **Varianza:** $(1-p_0)k(k+1)\phi^2-\mu^2$. Si $p_0=0$, el CV es $1/\sqrt k$.
  3. **Familia de escala:** un cambio de $\mu$ multiplica todos los cuantiles; la forma no cambia en el tiempo.
  4. **$k<1$:** la densidad Gamma $\propto x^{k-1}e^{-x/\phi}$ diverge en 0.
  5. **Persistencia de rango:** la correlación de Spearman entre $g_t$ y $g_{t+1}$ de un bebedor que sigue bebiendo en la misma celda es $\frac6\pi\arcsin(\rho/2)=0{,}786$, la de dos normales con correlación $\rho$ (el cuantil Gamma es monótono en $Z^{amount}$).

### Valores estimados

Meta de g/d entre actuales (EE) y $\hat\mu$ en g/d de encuesta; las olas 2014 y 2018 están en el Anexo B [verificado con datos]:

| Celda | 2012 | 2016 | 2020 | 2022 | 2024 | $\hat\beta^\mu$ (estadístico t) | $\hat\mu$ 2016 | $\hat\mu$ 2024 |
|---|---|---|---|---|---|---:|---:|---:|
| M 15–29 | 4,87 (0,54) | 4,65 (0,38) | 4,41 (0,30) | 4,40 (0,33) | 4,58 (0,67) | 0,055 (0,38) | 4,40 | 4,59 |
| M 30–44 | 2,99 (0,23) | 4,51 (0,52) | 3,40 (0,21) | 4,02 (0,30) | 3,81 (0,28) | 0,118 (0,91) | 3,37 | 3,70 |
| M 45–59 | 3,14 (0,54) | 2,60 (0,22) | 3,48 (0,35) | 3,00 (0,23) | 3,10 (0,23) | 0,184 (1,02) | 2,73 | 3,16 |
| M 60–65 | 2,25 (0,27) | 3,01 (0,36) | 3,06 (0,47) | 3,16 (0,34) | 2,57 (0,37) | 0,417 (1,72) | 2,76 | 3,85 |
| H 15–29 | 7,63 (0,37) | 7,72 (0,48) | 6,62 (0,54) | 6,81 (0,42) | 5,33 (0,46) | −0,099 (−0,85) | 7,44 | 6,88 |
| H 30–44 | 6,38 (0,32) | 7,42 (0,52) | 7,72 (0,58) | 7,19 (0,39) | 6,70 (0,53) | 0,316 (2,81) | 7,39 | 9,52 |
| H 45–59 | 7,90 (0,53) | 7,78 (0,61) | 7,61 (1,33) | 7,25 (0,49) | 7,09 (0,56) | 0,052 (0,32) | 7,67 | 7,99 |
| H 60–65 | 5,97 (0,58) | 5,77 (0,61) | 7,16 (0,72) | 7,53 (0,90) | 6,00 (0,60) | 0,103 (0,58) | 5,96 | 6,47 |

Ajuste: $\hat\sigma^2=1{,}302$ con 24 gl ($p=0{,}147$).

**Comparación con tu modelo aditivo**, ajustado sobre las mismas 40 metas (sólo 6 parámetros):

| Modelo | RMSE entrenamiento | RMSE held-out | Sesgo held-out |
|---|---:|---:|---:|
| Aditivo (tu modelo) | 0,693 g/d | 1,277 g/d | +0,529 g/d |
| Por celda (código) | 0,412 g/d | 1,070 g/d | +0,537 g/d |

El aditivo ajusta peor dentro de la muestra: F(10, 24) = 4,89, $p$ = 0,0007. Ninguno de los dos corrige el sesgo held-out. Los mayores errores held-out (observado / por celda / aditivo) son:

- H 30–44, 2024: 6,70 / 9,52 / 8,09;
- H 30–44, 2022: 7,19 / 8,93 / 7,88;
- H 15–29, 2024: 5,33 / 6,88 / 9,32;
- M 60–65, 2024: 2,57 / 3,85 / 3,05.

| Celda | M 15–29 | M 30–44 | M 45–59 | M 60–65 | H 15–29 | H 30–44 | H 45–59 | H 60–65 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| $\hat k$ | 0,592 | 0,495 | 0,355 | 0,443 | 0,610 | 0,589 | 0,383 | 0,500 |
| $\hat p_0$ (·10⁻⁴) | 1,6 | 1,5 | 8,9 | 0 | 2,2 | 0 | 0,5 | 5,4 |

[verificado con datos; idénticos a `microsim_base_outputs/gamma_parameters_train2020.csv`]

**Masa cerca de cero** (olas de entrenamiento, % de los bebedores actuales) [verificado con datos]:

| Sexo | < 0,4 g/d, motor | < 0,4 g/d, ENPG | < 1 g/d, motor | < 1 g/d, ENPG |
|---|---:|---:|---:|---:|
| Mujeres | 29,6 | ≈ 0 | 43,7 | 33,3 |
| Hombres | 18,5 | ≈ 0 | 28,8 | 15,8 |

Nota: las cifras de la auditoría (30,0 / 18,7 y 43,8 / 29,1) [RECALIB] promedian 7 olas: tienen el mismo orden de magnitud, pero no son la misma cantidad.

### Supuestos y limitaciones

- **Escala de encuesta:** 12 g por trago, puntos medios de AUDIT‑2 y ningún factor OMS. La decisión D3 reserva `factor_CH` para RR/AAF/PIF, pero ACC/CC no la ha confirmado (`notes_decisions.md` L43).
- **Faltantes:** se supone que faltan al azar (MAR) para el 7,7 % de los bebedores sin g/d.
- **La forma Gamma está mal** cerca de cero, aunque la media cuadra. La alternativa de la auditoría son cuantiles empíricos ponderados, reescalados a la media de cada año [leído, no corrido].
- **Pendientes no identificadas:** sólo H 30–44 tiene un estadístico $\lvert t\rvert>2$, y su extrapolación a 2024 sobreestima en +2,8 g/d.
- **Participación y monto independientes:** quien deja de beber por una política es una muestra al azar del reparto de montos. Una respuesta en el margen extensivo (participación) no cambia, entonces, la distribución del monto entre quienes siguen bebiendo.

> **Tu formulación vs el código**
>
> | Elemento | Tu formulación | Código | Estado | Consecuencia |
> |---|---|---|---|---|
> | $\mu$ | aditiva, 6 parámetros, una tendencia común | por celda, 8 + 8 (`ms-calibration-functions` L23) | difiere | Aditivo: RMSE de entrenamiento 0,69 frente a 0,41; held-out 1,28 frente a 1,07; mismo sesgo |
> | $\tau$ | $(t-2012)/10$ | congelado desde 2024 | difiere | Sólo en 2025+: $\mu$ fija desde 2024 |
> | $U^{amount}$ | $U/p_0$ | $\Phi(Z^{amount})$ propia | difiere | $U/p_0$ no es un percentil (errata); $U/pc$ invierte el orden; $1-U/pc$ ata el monto por completo a la propensión |
> | $p_0$ | proporción de ceros entre actuales | ídem, agrupada 2012–2020 y fija | coincide | $p_0\le8{,}9\cdot10^{-4}$: la mezcla está casi inactiva |
> | $k$ | sin método | momentos ponderados, agrupado 2012–2020, fijo | no definido | La varianza entre olas baja $k$ |
> | Escala y regla del cero | $\phi=\mu/(k(1-p_0))$; $U\le p_0\Rightarrow0$ | ídem, con recorte a $[10^{-12},1-10^{-12}]$ | coincide | La media de la celda es $\mu$ en esperanza |

---

## 4. DGP HED

### Formulación

Sólo si $\text{Is\_Current}=1$:

$$\operatorname{logit}p^{HED}=\gamma_0+\gamma_s+\gamma_a+\gamma_{gpd}\log(1+gpd),\qquad \text{HED}=\mathbf 1\{U^{HED}\le p^{HED}\},\qquad U^{HED}=\Phi(Z^{HED}),\ Z^{HED}\ \text{AR(1)}.$$

Tu texto: «el HED no depende sólo de sexo, edad y consumo; también de una heterogeneidad individual persistente no observada que se arrastra entre años»; «probabilidad según edad, sexo y año calendario»; «log para incrementos decrecientes»; «U_it^HED de una latente persistente AR(1) transformada con la CDF normal». Nota: tu texto no dice si esa latente es propia del HED o el proceso base de la sección 0.

**[código]**

$$\operatorname{logit}p^{HED}_{c}(g)=\gamma_{s,a}+\gamma_{gpd}\log(1+g),\qquad \text{HED}_{it}=\mathbf 1(g_{it}>0)\cdot\mathbf 1\{\Phi(Z^{HED}_{it})<p^{HED}_c(g_{it})\}.$$

- Hay 8 interceptos de celda y una pendiente común.
- **No hay término de año**, aunque tu texto dice «según edad, sexo y año calendario».
- El HED se asigna sólo si $g>0$.

### Intuición

- Entre bebedores, la probabilidad de algún episodio intenso sube rápido con g/d y se satura cerca de 1 pasados unos 10 g/d.
- La «tendencia propia» $Z^{HED}$ persiste con $\rho$ y no depende de cuánto bebe la persona.

### Implementación

```r
# ms-calibration-functions L49–50, L52–54 (se omite L51, que arma `cell`)
hed_data <- train[train$current %in% 1 & is.finite(train$gpd_survey) & train$gpd_survey > 0 & !is.na(train$hed), ]
hed_data$w_fit <- hed_data$weight / mean(hed_data$weight)
hed <- glm(hed ~ 0 + cell + log1p(gpd_survey), data = hed_data, weights = w_fit, family = quasibinomial())
# ms-annual-engine L28–29
p_hed <- plogis(d$hed_intercept + d$hed_slope * log1p(pop$gpd_survey))
pop$hed <- positive & pnorm(pop$z_hed) < p_hed
```

### Estimación

- **Datos y método.** Cuasi-verosimilitud binomial ponderada sobre los bebedores de 2012–2020 con $g>0$ y HED observado ($n$ = 34.132).
- **Normalización de pesos.** Los pesos se normalizan a media 1. No es cosmética: con los pesos crudos, `glm()` no converge.
- **EE.** Son de modelo (dispersión estimada 1,379), no de diseño.
- **Lo que garantiza.** Con interceptos por celda, la media ponderada de la probabilidad ajustada $\hat p^{HED}$ iguala a la observada, agrupando las olas.
- **Derivaciones:**
  1. **Incrementos en logit por g/d adicional.** De 1 a 2 g/d suma $2{,}343\log(3/2)=0{,}95$; de 10 a 11, 0,20; de 20 a 21, 0,11. En odds la relación es una potencia: $e^{\gamma_c}(1+g)^{2{,}343}$.
  2. **El margen HED no depende de $\rho$.** Cada año, $U^{amount}$ y $U^{HED}$ son Uniforme(0,1), independientes entre sí y de $U^{status}$, cualquiera sea $\rho$ (sección 0). Condicionar en «actual» no les cambia la ley. Por eso

$$E[\text{HED}\mid\text{actual},c,t]=(1-p_0)\int_0^1\operatorname{logit}^{-1}\big(\gamma_c+\gamma_{gpd}\log(1+F^{-1}_\Gamma(u;k_c,\phi_{c,t}))\big)\,du,$$

Esa expresión no contiene $\rho$: $\rho$ cambia **quién** tiene HED, no **cuántos**.

  3. **Forma de $p^{HED}(g)$.** Con $p=p^{HED}(g)$ y $\gamma=\gamma_{gpd}$,

$$\frac{d^2p}{dg^2}=\frac{\gamma\,p(1-p)}{(1+g)^2}\big[\gamma(1-2p)-1\big]>0\iff p<\frac{1-1/\gamma}{2}=\frac{1-1/2{,}343}{2}=0{,}287.$$

Entonces $p^{HED}(g)$ es **convexa** para $g<1{,}1$–$2{,}9$ g/d (según la celda) y cóncava por encima, y el sesgo no se puede deducir con Jensen. Lo que pasa es que, con la misma media, la Gamma pone el 18–30 % de los bebedores bajo 0,4 g/d (donde $p^{HED}\le0{,}134$), y ENPG casi ninguno. El efecto neto se **mide** (ver la descomposición, más abajo).

### Valores estimados

Coeficientes y $p^{HED}$ implícita [verificado con datos]:

| Celda | $\hat\gamma_{s,a}$ | $p^{HED}$ a 0,4 g/d | a 1 | a 5 | a 10 | a 20 |
|---|---:|---:|---:|---:|---:|---:|
| M 15–29 | −2,658 | 0,134 | 0,262 | 0,824 | 0,951 | 0,989 |
| M 30–44 | −2,917 | 0,106 | 0,215 | 0,783 | 0,937 | 0,985 |
| M 45–59 | −3,063 | 0,093 | 0,192 | 0,757 | 0,928 | 0,983 |
| M 60–65 | −3,331 | 0,073 | 0,154 | 0,704 | 0,908 | 0,978 |
| H 15–29 | −3,013 | 0,098 | 0,200 | 0,766 | 0,931 | 0,984 |
| H 30–44 | −3,100 | 0,090 | 0,186 | 0,750 | 0,926 | 0,983 |
| H 45–59 | −3,443 | 0,066 | 0,140 | 0,680 | 0,898 | 0,976 |
| H 60–65 | −4,127 | 0,034 | 0,076 | 0,518 | 0,816 | 0,953 |

$\hat\gamma_{gpd}=2{,}343$ (EE 0,030).

Meta HED entre actuales, % (EE):

| Celda | 2012 | 2014 | 2016 | 2018 | 2020 | 2022 | 2024 |
|---|---|---|---|---|---|---|---|
| M 15–29 | 54,7 (2,8) | 50,1 (2,9) | 59,4 (3,3) | 64,5 (3,2) | 57,3 (3,2) | 49,8 (2,7) | 54,7 (4,1) |
| M 30–44 | 41,7 (2,8) | 40,5 (2,8) | 47,2 (3,1) | 56,4 (3,4) | 45,5 (3,2) | 49,0 (2,3) | 48,8 (3,1) |
| M 45–59 | 36,1 (3,2) | 33,8 (2,3) | 37,0 (3,6) | 42,7 (3,7) | 37,8 (3,4) | 42,5 (2,5) | 41,4 (3,3) |
| M 60–65 | 21,0 (3,5) | 29,4 (4,8) | 35,1 (4,5) | 47,7 (7,2) | 31,2 (5,4) | 36,5 (3,5) | 31,2 (4,1) |
| H 15–29 | 71,3 (2,7) | 63,9 (2,5) | 66,8 (2,6) | 65,3 (3,1) | 61,4 (3,5) | 61,1 (2,7) | 50,1 (4,1) |
| H 30–44 | 58,2 (2,4) | 60,6 (2,7) | 60,3 (2,8) | 69,9 (3,3) | 64,4 (3,3) | 60,2 (2,5) | 54,7 (2,8) |
| H 45–59 | 59,9 (2,9) | 50,3 (2,9) | 49,7 (3,0) | 61,9 (2,7) | 53,5 (3,9) | 54,5 (2,5) | 50,3 (3,2) |
| H 60–65 | 42,5 (4,6) | 39,4 (4,6) | 37,0 (5,5) | 39,9 (4,6) | 44,6 (4,8) | 48,8 (3,8) | 37,6 (3,9) |

**Descomposición del sesgo HED**, $R-T=(A-T)+(B-A)+(G-B)+(R-G)$, en pp y como media por celda [verificado con datos]:

- $T$ = meta;
- $A$ = observado en la muestra del glm;
- $B$ = glm aplicado al g/d **observado**;
- $G$ = esperanza del motor: glm sobre la Gamma con la $\hat\mu$ ajustada;
- $R$ = realizado en la simulación, con 5 semillas.

| Período | $A-T$ | $B-A$ (sin término de año) | $G-B$ (ley Gamma con $\hat\mu$ ajustada) | $R-G$ (Monte Carlo) | $R-T$ |
|---|---:|---:|---:|---:|---:|
| Entrenamiento (40 celdas) | −0,08 | 0,00 | **−4,68** | −0,33 | **−5,10** (RMSE 7,18; 19/32) |
| Held-out (16 celdas) | −0,22 | +1,14 | −2,34 | +0,06 | **−1,35** (RMSE 5,58; 10/16) |

«19/32» y «10/16» cuentan las celdas dentro de ±1,96 EE de la meta; en entrenamiento son 32 y no 40 porque 2020 no cuenta para la cobertura (`ms-historical-validation` L30).

Lectura:

- $G-B$ mezcla dos cosas: la forma Gamma (sobre todo su masa cerca de cero) y el error de $\hat\mu$ frente al g/d observado.
- $G-B<0$ en 48 de 56 celdas.
- Por ola, el sesgo de 15–65 es de −10,96 pp en 2018 y de +1,22 pp en 2024.
- El buen resultado held-out viene de **dos compensaciones**:
  1. En 2024, la $\mu$ extrapolada de los hombres es demasiado alta, y eso reduce $G-B$ a −0,48 pp.
  2. Sin término de año, el glm predice más HED que lo observado al g/d observado de 2022/2024: $B-A=+1{,}14$ pp (+1,66 en 2024; +5,6 en H 30–44 2024).
- **Alternativas** (esperanza del motor):

  | Modelo | RMSE entrenamiento | RMSE held-out |
  |---|---:|---:|
  | Tus interceptos aditivos | 7,01 pp | 5,08 pp |
  | Interceptos por celda (código) | 6,91 pp | 5,51 pp |

  Agregar tiempo lineal no es significativo ($p=0{,}20$). Un efecto fijo de ola 2018 sí lo es: +0,257 en logit ($p=2{,}4\cdot10^{-6}$).

### Supuestos y limitaciones

- **La meta es de caso completo** y queda 2,1–6,0 pp sobre la serie SENDA de 15–65, que cuenta el faltante como «no» [leído, no corrido].
- **El indicador cambia entre olas** (exclusiones de festividades, tarjetas, códigos de 2018).
- **5+/4+ tragos de 12 g son 60/48 g.** El umbral OMS de HED es 60 g para ambos sexos, así que en mujeres se mezclan definiciones (D5 lo acepta como *proxy*, declarando los gramos).
- **$\rho_{HED}$ no está identificado** (la EPS no tiene ítem HED).

> **Tu formulación vs el código**
>
> | Elemento | Tu formulación | Código | Estado | Consecuencia |
> |---|---|---|---|---|
> | Interceptos | $\gamma_0+\gamma_s+\gamma_a$ (5 parámetros) | $\gamma_{s,a}$ (8) | difiere | Pequeña (RMSE 7,01 frente a 6,91 en entrenamiento); ninguno corrige el sesgo |
> | Año calendario | lo nombras, pero la fórmula no lo tiene | sin término de año | no definido | No captura 2018; produce $B-A=+1{,}14$ en held-out |
> | Pendiente $\log(1+g)$ | sí | `log1p(gpd_survey)`, común a todas las celdas | coincide | — |
> | Dominio | todo actual | sólo $g>0$ | difiere | Tu regla agregaría ≤ 0,004 pp |
> | Latente | AR(1) (tu texto no dice si es propia o la del proceso base) | `z_hed` propia, mismo $\rho$ | coincide | Coincide con la lectura «propia» |
> | Muestra de estimación | no la defines | $g>0$ y HED observado, 2012–2020 | no definido | El glm se ajusta sobre g/d observado y se aplica a la Gamma: $G-B=-4{,}68$ pp |

---

## 5. Categorías

### Formulación

- Mujeres: cat0 si $gpd=0$; cat1 si $0<gpd\le20$; cat2 si $20<gpd\le40$; cat3 si $gpd>40$.
- Hombres: cat0 si $gpd=0$; cat1 si $0<gpd\le40$; cat2 si $40<gpd\le60$; cat3 si $gpd>60$.

**[código]** Con $g^{(1)}_s$ = 20 (M) / 40 (H) y $g^{(2)}_s$ = 40 (M) / 60 (H):

$$\text{cat}_{it}=\begin{cases}\text{noncurrent}&C_{it}=0\ \ (\text{nunca y ex van aparte})\\ \text{cat1}&C_{it}=1,\ g<g^{(1)}_s\ \ (\text{incluye } g=0)\\ \text{cat2}&g^{(1)}_s\le g<g^{(2)}_s\\ \text{cat3}&g\ge g^{(2)}_s\end{cases}$$

**[faltaba] Escala de $g$.** El código aplica los umbrales OMS/SIMAH a g/d de **encuesta**. Convención propuesta (D3, sin confirmar por ACC/CC): aplicar los umbrales a $g\cdot\text{factor\_CH}(\text{año})$, donde factor_CH es el cociente APC OMS / volumen ENPG (4,347 en 2016; 5,972 en 2024; `oms_factor_by_year.csv`) [leído, no corrido].

### Intuición

Las categorías son etiquetas que se calculan después del g/d continuo y no tienen dinámica propia. Como el g/d de encuesta es 4–6 veces menor que el volumen de riesgo, casi nadie llega a cat2 o cat3 en la escala de encuesta.

### Implementación

```r
# ms-annual-engine L35–39 (se omite el comentario de L37)
low <- ifelse(pop$sex == "female", 20, 40)
high <- ifelse(pop$sex == "female", 40, 60)
pop$alc_cat <- ifelse(!pop$current, "noncurrent",
  ifelse(pop$gpd_survey < low, "cat1", ifelse(pop$gpd_survey < high, "cat2", "cat3")))
```

### Estimación

No se estima nada: las categorías son funciones de (sexo, actual, $g$). Analíticamente,

$$P(\text{cat3}\mid\text{actual})=(1-p_0)\big[1-G_k(g^{(2)}_s/(\phi f))\big],$$

con $f=1$ en escala de encuesta o $f$ = factor_CH en escala de riesgo. Nota: multiplicar $g$ por $f$ equivale a dividir los umbrales por $f$; en 2024, el umbral masculino de cat3 baja a 60 / 5,972 = 10,05 g/d de encuesta.

### Valores estimados

% de los bebedores actuales [verificado con datos]:

| Fuente | 2016 M: cat1 / cat2 / cat3 | 2016 H | 2024 M | 2024 H |
|---|---|---|---|---|
| Motor, escala encuesta (5 semillas) | 98,4 / 1,6 / 0,05 | 98,1 / 1,4 / 0,45 | 97,7 / 2,1 / 0,15 | 97,3 / 2,0 / 0,74 |
| Motor analítico × factor_CH | 75,0 / 14,3 / 10,7 | 73,5 / 9,6 / 17,0 | 65,5 / 15,9 / 18,7 | 63,4 / 10,1 / 26,5 |
| ENPG × factor_CH | 73,0 / 17,6 / 9,4 | 76,3 / 11,1 / 12,6 | 67,8 / 17,8 / 14,4 | 69,9 / 13,0 / 17,1 |

- **cat2 + cat3:** 1,6–2,8 % en escala de encuesta, frente a 25–37 % en el motor × factor y 24–32 % en ENPG × factor. Nota: el motor tiene la cola alta más pesada que ENPG, también dentro de la muestra (hombres cat3 2016: 17,0 frente a 12,6).
- **Cola sobre 150 g/d × factor, BASE, 2024:** 7,6 % de los hombres y 1,2 % de las mujeres bebedoras. En RECALIB son 4,3 % y 1,2 % [RECALIB].
- **Empates exactos en un borde,** en ENPG: 0,004–0,31 % ponderado.

### Supuestos y limitaciones

- Para RR y para elegibilidad a una IB, las categorías tendrían que calcularse sobre $g\times$factor_CH (si se adopta D3). `rr_bridge.md` muestra que la microsimulación reproduce la escala de `expand_pif` sólo si aplica el factor antes de cualquier umbral [leído, no corrido].
- El factor no está definido para los años impares ni para 2025–2034 (D3 lo congela, sin confirmar por ACC/CC).

> **Tu formulación vs el código**
>
> | Elemento | Tu formulación | Código | Estado | Consecuencia |
> |---|---|---|---|---|
> | cat0 | $gpd=0$: junta no bebedores y bebedores con 0 g/d | `noncurrent` aparte; actual con $g=0$ → cat1 | difiere | Los bebedores con 0 g/d son ≤ 0,089 % agrupado (hasta 0,43 % en M 45–59 2014; 0 fuera de 2014). Nunca y ex llevan RR distintos y no deben mezclarse |
> | Bordes | $(0,20]$, $(20,40]$ (convención OMS/SIMAH) | $[0,20)$, $[20,40)$ | difiere | Cero en el motor (continuo); 0,004–0,31 % en ENPG |
> | Escala | no la defines | encuesta, sin factor | no definido | cat2 + cat3 = 1,6–2,8 % frente a 25–37 % con factor |
> | Orden | después del g/d | ídem (comentario `ms-annual-engine` L37) | coincide | — |

---

## 6. Mortalidad (q*)

### Formulación

Tu texto: «[Evaluación de Mortalidad] (Sorteo uniforme vs q* -> Remoción definitiva si fallece)» y «HMD: qx y mx tasas centrales». **[faltaba] Definición de $q^*$**, tomada del código:

$$q^*_{t,s,x}=1-\big(1-q^{HMD}_{\min(t,2024),s,x}\big)^{\kappa_s},\qquad \sum_{t=2012}^{2020}\sum_{x=15}^{65}N^{ene}_{t,s,x}\,q^*_{t,s,x}(\kappa_s)=\sum_{t=2012}^{2020}\sum_{x=15}^{65}D_{t,s,x}.$$

La persona muere si $U^{death}_{it}<q^*_{t,s_i,x_i}$, con $U^{death}\sim U(0,1)$ independiente de todo, y $x_i$ es la edad al 1 de enero. Nota: hoy $q^*$ no depende del consumo.

### Intuición

HMD aporta la forma por edad, y $\kappa_s$ sube o baja todo el riesgo de un sexo para que, aplicado a los stocks INE, la suma dé las muertes DEIS de 2012–2020. Elevar a $\kappa$, en vez de multiplicar, mantiene $q^*$ en $[0,1]$ y equivale a escalar el riesgo instantáneo.

### Implementación

```r
# ms-calibration-functions L58–64
f <- function(log_scale) sum(d$pop_jan * (-expm1(log1p(-d$qx) * exp(log_scale)))) - sum(d$deaths)
exp(uniroot(f, interval = c(-3, 3))$root)          # kappa = 1 en el comparador estático (L63)
# (pseudocódigo: L59–65 aplican esto por sexo dentro de vapply)
# ms-annual-engine L82–87
mortality_year <- min(year, ms_cfg$observed_end)    # qx congelada en 2024
q <- -expm1(log1p(-mortality$qx[k]) * model$mortality_scale[pop$sex])
dead <- runif(start_n) < q
```

### Estimación

- **Forma de potencia.** Con riesgo instantáneo $h(x)$ y riesgo acumulado en el año $\Lambda=\int h$, se tiene $1-q=e^{-\Lambda}$. Si el riesgo es proporcional, $h^*=\kappa h$, de modo que $\Lambda^*=\kappa\Lambda$ y $1-q^*=(1-q)^\kappa$ (verificado con error de punto flotante). Para $q$ chico, $q^*\approx\kappa q$ (diferencia ≤ 4,3·10⁻⁴ relativa).
- **Unicidad.** $\partial_\kappa q^*=-(1-q)^\kappa\ln(1-q)>0$, así que la raíz es única.
- **Por qué un $\kappa$ constante no elimina la deriva.** Sea $\kappa_t$ el valor que cuadra el año $t$ y $\text{err}_t$ el error relativo de las muertes esperadas. Con $q$ chico, $q^*\approx\kappa q$: las esperadas son ≈ $\kappa\sum Nq$ y las observadas, $\kappa_t\sum Nq$, así que $\text{err}_t\approx\kappa/\kappa_t-1$. Con $\kappa_t$ en tendencia, el error es negativo al inicio, cero en promedio en el entrenamiento y positivo después.

### Valores estimados

- **$\kappa$:** 0,969940 (M) y 0,952405 (H) con 2012–2020. Con 2012–2024, para la proyección: 0,964468 y 0,941262. Los guardados (0,9767 / 0,9571) usaban el DEIS anterior [verificado con datos].
- **Muertes esperadas** 2012–2024: 403.655, idénticas en las 5 semillas, porque la población del 1 de enero es exacta.

| Año | Sexo | DEIS 15–65 | Esperadas ($\kappa$ train) | Error | $\kappa_t$ del año | $\sum N^{jun}m_x/D$ |
|---|---|---:|---:|---:|---:|---:|
| 2012 | M | 9.916 | 9.816 | −1,00 % | 0,980 | 1,037 |
| 2016 | M | 10.223 | 10.209 | −0,14 % | 0,971 | 1,045 |
| 2020 | M | 11.983 | 12.098 | +0,96 % | 0,961 | 1,053 |
| 2022 | M | 11.832 | 11.986 | +1,30 % | 0,957 | 1,056 |
| 2024 | M | 11.609 | 11.903 | +2,54 % | 0,946 | 1,066 |
| 2012 | H | 17.908 | 17.579 | −1,84 % | 0,970 | 1,048 |
| 2016 | H | 18.520 | 18.472 | −0,26 % | 0,955 | 1,064 |
| 2020 | H | 22.151 | 22.592 | +1,99 % | 0,934 | 1,084 |
| 2022 | H | 22.458 | 23.158 | +3,11 % | 0,924 | 1,096 |
| 2024 | H | 20.197 | 21.142 | +4,68 % | 0,910 | 1,110 |

[verificado con datos]

- **Deriva.** El error crece +0,26 pp/año (M) y +0,53 pp/año (H), y $\kappa_t$ cae 0,0025 y 0,0050 por año.
- **De dónde sale.** De la exposición de HMD, que queda cada vez más bajo los stocks INE:
  - Ponderada por muertes, $\sum N^{jun}m_x/D$ sube de 1,037 a 1,066 (M) y de 1,048 a 1,110 (H). Por qué mide la brecha: como $m_x=D^{HMD}_x/E^{HMD}_x$ y $D^{HMD}\approx D$, $\sum_x N^{jun}_x m_x/D=\sum_x(D_x/D)(N^{jun}_x/E^{HMD}_x)$, el cociente de exposición INE/HMD ponderado por las muertes de cada edad.
  - Ponderada por exposición, la exposición HMD queda 2,5 → 6,3 % (M) y 4,1 → 9,5 % (H) bajo el stock INE de junio (auditoría).
  - El resto del nivel, $\sum N^{ene}q/\sum N^{jun}m$, sube de 0,984 a 0,992 (M) y de 0,983 a 0,990 (H). Aporta ≈ 22 % (M) y ≈ 11 % (H) de la deriva.
- **Edad de referencia.** Quien tiene $x$ años el 1 de enero pasa, en promedio, medio año con $x$ y medio con $x+1$. Por eso el paralelogramo de Lexis $1-e^{-(m_x+m_{x+1})/2}$ es la probabilidad que corresponde, y da 3,9–5,0 % más que $q_x$. $\kappa$ absorbe ese desfase en el nivel.
- **Ruido Monte Carlo.** Una corrida tiene 49–85 muertes sintéticas por año (corrida reajustada 2012–2034; 53–85 en la validación con la semilla 1). La DE condicional de las muertes de una corrida, por año y sexo y en personas reales, es 2.169–2.515 en mujeres (19–22 % de las esperadas) y 2.900–3.500 en hombres (14–17 %). Entre las 5 semillas, la DE va de 730 a 4.948 personas reales (6–29 %), con sólo 4 gl.

### Supuestos y limitaciones

- **La mortalidad de 2021–2024 no es una validación independiente.** La $q_x$ de HMD de esos años está construida con las muertes DEIS de esos mismos años, y la validación la usa observada.
- **COVID.** 2020 (dentro del entrenamiento) y 2021 tienen exceso de mortalidad.
- **Proyección.** Usa la $q_x$ de 2024 congelada, sin tendencia de mortalidad (−1 a −3 % anual antes del COVID), y parte con un nivel +1,96 % (M) y +3,46 % (H) sobre DEIS 2024.
- **Sin vínculo con el alcohol:** hoy una política no puede cambiar las muertes.
- **Propuesta de la auditoría:** usar tasas DEIS/INE convertidas a la edad al 1 de enero (paralelogramo). Reproduce el objetivo coherente con la cohorte dentro de ±0,2 %, sin parámetros ajustados [leído, no corrido; `auditoria_microsim_2026-10-09/mortality_deis_verify.md`].

> **Tu formulación vs el código**
>
> | Elemento | Tu formulación | Código | Estado | Consecuencia |
> |---|---|---|---|---|
> | Sorteo | uniforme frente a $q^*$ | `runif < q` (`ms-annual-engine` L87) | coincide | — |
> | $q^*$ | no la defines | $1-(1-q^{HMD})^{\kappa_s}$ | no definido | Deriva: 2024 +2,54 % (M) y +4,68 % (H) |
> | Fuente de la tasa | INE enero y junio para tasas centrales; HMD $q_x$ y $m_x$ | $q_x$ de HMD (exposición HMD) sobre stocks INE de enero | difiere | Coincide en $q_x$; $m_x$ e INE junio no se usan. Brecha de denominador ponderada por muertes de 3,7 → 6,6 % (M) y 4,8 → 11,0 % (H) |
> | Un $\kappa$ por sexo | no lo defines | constante 2012–2020 | no definido | No puede quitar una deriva con tendencia (error 2024 +2,54 / +4,68 %) |
> | Edad de referencia | no la defines | edad al 1 de enero con $q_x$ de período | no definido | El paralelogramo da 3,9–5,0 % más; $\kappa$ lo absorbe |
> | Después de 2024 | no lo defines | $q_x$ de 2024 congelada; $\kappa$ reajustado | no definido | Sin tendencia de mortalidad |

---

## 7. Envejecimiento, salida a los 66 y ajuste de stocks INE

### Formulación

Tu texto: «[1 de enero: Muestra de sintéticos]»; «[Envejecimiento (Edad + 1)] (Salida automática de personas con edad = 66) -> [Ajuste de Stocks INE] (Entrada a los 15 años + Flujos residuales Inflow/Outflow)».

**[faltaba]** Todo lo que sigue se toma del código (`ms-annual-engine` L51–52, L100–135):

$$\omega=\frac{\sum_{s,x}N^{ene}_{2012,s,x}}{25.000},\qquad n_{t,s,x}=\mathrm{round}\Big(\frac{N^{ene}_{t,s,x}}{\omega}\Big),\qquad \Delta_{t+1,s,x}=n_{t+1,s,x}-\#\{\text{sobrevivientes con edad } x \text{ tras envejecer}\}.$$

- $\Delta<0$: se eliminan $\lvert\Delta\rvert$ personas al azar (outflow residual).
- $\Delta>0$: se crean $\Delta$ personas nuevas, con latentes frescas y `ever` = NA. Son entradas si $x=15$ e inflow si $x>15$.
- Identidad contable:

$$\text{Fin}_t=\text{Inicio}_t-\text{Muertes}_t-\text{Salidas}_t-\text{Outflow}_t+\text{Entradas}_t+\text{Inflow}_t=\sum_{s,x}n_{t+1,s,x}.$$

### Intuición

- Cada 1 de enero se «fotografía» la población.
- Durante el año algunos mueren y los que cumplen 66 salen.
- Para que la población siga al INE, entran los que cumplen 15 años. Si faltan personas de alguna edad (sobre todo por inmigración), se crean; si sobran, se sacan al azar.

### Implementación

```r
# ms-annual-engine L100–120
pop$age <- pop$age + 1L                                # L100
age_exits <- sum(pop$age > ms_cfg$max_age)             # L101: salida a los 66, ANTES del ajuste
pop <- pop[pop$age <= ms_cfg$max_age, ]                # L102
delta <- next_stock$n_target[j] - length(ix)           # L108, por sexo × edad simple
# delta < 0: remove <- ix[sample.int(length(ix), -delta)]   (L111)
# delta > 0: ms_new_people(sex, age, delta, last_id)        (L115); edad 15 = entrada (L117)
```

### Estimación

No se estima nada. Los insumos son exógenos: stocks INE, $q^*$ y $\rho$.

### Valores estimados

$\omega=481{,}249$. La población sintética es de 25.000 (2012), 28.665 (2024) y 30.091 (2034). Flujos de la corrida del notebook con el modelo reajustado (semilla 20260917), en personas sintéticas [verificado con datos]. La última columna, en personas reales, es el **neto INE implícito**: $\sum_s\sum_{x=15}^{64}\big[N^{ene}_{t+1,s,x+1}-N^{ene}_{t,s,x}(1-q^*_{t,s,x})\big]$, lo que el stock INE del año siguiente tiene de más (o de menos) frente a los sobrevivientes esperados de este año.

| Año | Inicio | Muertes (esperadas) | Salidas a 66 | Entradas a 15 | Inflow | Outflow | Fin | Neto INE implícito (personas reales) |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 2012 | 25.000 | 62 (56,4) | 249 | 547 | 70 | 7 | 25.299 | 26.340 |
| 2016 | 26.150 | 59 (59,0) | 296 | 518 | 228 | 10 | 26.531 | 106.606 |
| 2018 | 26.938 | 77 (59,5) | 327 | 500 | 332 | 2 | 27.364 | 149.950 |
| 2020 | 27.704 | 58 (71,4) | 352 | 498 | 100 | 18 | 27.874 | 43.638 |
| 2024 | 28.665 | 70 (68,0) | 422 | 558 | 178 | 1 | 28.908 | 81.455 |
| 2030 | 29.778 | 72 (72,0) | 490 | 560 | 137 | 8 | 29.905 | 61.967 |
| 2034 | 30.091 | 68 | 0 | 0 | 0 | 0 | 30.023 (sobrevivientes) | — |

- **Totales 2012–2023** (en personas reales): inflow 1.040.461; outflow 46.681 (su esperanza binomial exacta es 46.061); neto INE implícito 993.116. Inflow − outflow (993.780) no es igual al neto implícito, porque el neto realizado depende de las muertes sorteadas y del redondeo a sintéticos.
- **Totales 2024–2033** (en personas reales): inflow 684.337; outflow 29.356; neto INE implícito 661.719.
- **Las entradas a los 15 son deterministas** (= $n_{t+1,s,15}$).
- **Las salidas a los 66** difieren de su esperanza en 0–3,6 personas por año.
- **El outflow es en buena parte estructural.** En 2–20 de las 100 celdas sexo × edad de cada año, el stock INE siguiente queda bajo los sobrevivientes esperados.
- **Muertes fuera de la ventana.** El 79,5 % (M) y el 66,2 % (H) de las muertes DEIS de 15+ años en 2012–2024 ocurre a los 66+ años y queda fuera del modelo. En causas con AAF = 1, la proporción a los 66+ es 26,1 % y 30,5 % [leído, no corrido].

### Supuestos y limitaciones

- **El residuo INE** junta la migración internacional neta y la diferencia entre la mortalidad implícita del INE y $q^*$. No es migración observada (comentario `ms-annual-engine` L110).
- **Los inmigrantes no traen historia:** reciben latentes frescas, `ever` sorteado y los hábitos de su celda.
- **El ajuste a stocks borra las ganancias de supervivencia de un brazo de intervención.** Los sobrevivientes extra se eliminan como outflow, y los dos brazos dejan de compartir números aleatorios. En una primera etapa, la auditoría propone «supervivencia compartida»; más adelante, repetir los $\Delta$ del brazo control [leído, no corrido; `auditoria_microsim_2026-10-09/engine_ponytail.md` §2.4].
- **El último año** no envejece ni concilia: el final de 2034 son sobrevivientes, no un stock.

> **Tu formulación vs el código**
>
> | Elemento | Tu formulación | Código | Estado | Consecuencia |
> |---|---|---|---|---|
> | Registro | no aparece | resumen al 1 de enero, antes de las muertes (`ms-annual-engine` L69–79) | no definido | Las salidas anuales describen el 1 de enero |
> | «Muestra de sintéticos» | muestra | réplica determinista de INE 2012; sin donantes ENPG | difiere | No hay variación muestral en sexo × edad |
> | 25.000 | por corrida | sólo en 2012; después sigue al INE | difiere | 30.091 en 2034 |
> | Edad + 1 y salida a los 66 | sí | `ms-annual-engine` L100–102, antes del ajuste | coincide | Las muertes a los 66+ quedan fuera |
> | Entrada a los 15 e inflow/outflow | sí | por sexo × edad simple; nuevos con latentes frescas | coincide | Los nuevos reciben `ever` sorteado (sección 2): los inmigrantes no traen historia |
> | Actualización latente | AR(1) | la forma coincide; la estructura difiere (3 latentes; `ever` sin latente) | difiere | Ver secciones 0 y 2 |
> | Último año | no lo defines | sin envejecimiento ni ajuste | no definido | — |

---

## 8. Validación fuera de muestra (2022, 2024) y proyección 2025–2034

### Validación con `ms_fit(2020)` y 5 semillas

Métricas, simulado − observado [verificado con datos]:

| Período | Variable | Sesgo | RMSE | Celdas dentro de ±1,96·EE |
|---|---|---:|---:|---:|
| Entrenamiento | actual | −0,09 pp | 3,61 pp | 23/32 |
| Entrenamiento | g/d | −0,089 g/d | 0,446 g/d | 30/32 |
| Entrenamiento | HED | −5,10 pp | 7,18 pp | 19/32 |
| **Held-out** | **actual** | **+9,71 pp** | **10,22 pp** | **0/16** |
| Held-out | g/d | +0,60 g/d | 1,11 g/d | 11/16 |
| Held-out | HED | −1,35 pp | 5,58 pp | 10/16 |

Notas:

- 2020 no cuenta para la cobertura (`ms-historical-validation` L30): en entrenamiento son 32 celdas y no 40.
- Estos valores difieren un poco de la exportación guardada (`microsim_base_outputs/validation_metrics.csv`) sólo por el DEIS corregido; la comparación y su prueba están en el Anexo A.

Sesgo de prevalencia por ola, en pp: 2012 +3,42; 2014 −5,35; 2016 −0,76; 2018 +1,39; 2020 +0,85; **2022 +7,31**; **2024 +12,1**.

Celdas held-out de prevalencia, en %:

| Año | Celda | Observado (EE) | Simulado | Error | Error/EE |
|---|---|---|---:|---:|---:|
| 2022 | M 15–29 / 30–44 / 45–59 / 60–65 | 35,3 (1,5) / 40,2 (1,5) / 31,5 (1,3) / 23,0 (1,4) | 39,8 / 44,7 / 36,8 / 31,3 | +4,5 / +4,5 / +5,3 / +8,3 | 3,0 / 3,0 / 4,2 / 6,0 |
| 2022 | H 15–29 / 30–44 / 45–59 / 60–65 | 41,5 (1,6) / 55,5 (1,6) / 47,8 (1,6) / 38,3 (2,1) | 54,9 / 62,8 / 54,2 / 47,0 | +13,4 / +7,4 / +6,4 / +8,7 | 8,3 / 4,7 / 4,1 / 4,2 |
| 2024 | M 15–29 / 30–44 / 45–59 / 60–65 | 29,7 (1,9) / 33,5 (1,6) / 26,7 (1,5) / 17,8 (1,6) | 40,3 / 45,3 / 36,8 / 30,9 | +10,6 / +11,9 / +10,1 / +13,1 | 5,5 / 7,5 / 6,7 / 8,4 |
| 2024 | H 15–29 / 30–44 / 45–59 / 60–65 | 40,8 (2,3) / 50,3 (1,8) / 42,7 (1,9) / 33,0 (2,5) | 55,3 / 62,9 / 54,8 / 45,2 | +14,4 / +12,6 / +12,1 / +12,2 | 6,2 / 6,9 / 6,5 / 4,9 |

Reglas analíticas ajustadas con 2012–2020 y evaluadas en las 16 celdas held-out [verificado con datos]:

| Regla | Sesgo | RMSE | Dentro de ±1,96·EE |
|---|---:|---:|---:|
| Tendencia lineal WLS (el código) | +9,76 pp | 10,30 pp | 0/16 |
| Media plana 2012–2020 | +9,07 pp | 9,67 pp | 1/16 |
| Mantener 2020 | +8,67 pp | 9,20 pp | 1/16 |
| Mantener 2012 | +5,23 pp | 6,64 pp | 5/16 |
| Logística individual, mismo predictor | +9,23 pp | 9,72 pp | — |

**Lectura:**

1. **La prevalencia falla fuera de muestra, y por nivel, no por pendiente.** El 93 % del sesgo lineal persiste sin pendiente. La caída de 2022/2024 no está en los datos de 2012–2020, y ninguna regla ajustada con ellos la anticipa.
   - El motor no es la causa: su sesgo (+9,71 pp) es el de la curva analítica (+9,76 pp).
   - El comparador estático 2012 «gana» (6,34 pp con 1 semilla; 6,64 pp analítico) porque 2012 fue una ola baja. La diferencia de 0,3 pp entre esas dos cifras es ruido de una semilla, así que no se deben ordenar reglas por diferencias de ese tamaño.
2. **Con un intervalo predictivo** en escala logit, $\operatorname{Var}_{pred}=\hat\sigma^2x_0^\top(X^\top VX)^{-1}x_0+\hat\sigma^2/v_{c,y}$ y $z=(\operatorname{logit}\hat p_{obs}-x_0^\top\hat\beta)/\sqrt{\operatorname{Var}_{pred}}$, comparado con $t_{24}$, 15 de 16 celdas caen dentro ($x_0$ es la fila de diseño de la celda y el año). Pero en **las 16** lo observado queda bajo lo predicho ($z<0$), y los errores están correlacionados por el choque de ola. Lectura: la incertidumbre del modelo es grande **y** la desviación es sistemática.
3. **Origen móvil** [RECALIB] [leído, no corrido]. RMSE agrupado: spline compartido 4,5; `interp_hold` 4,9; estático 2012 5,4; lineal 6,7 pp. La lineal no es la peor en todos los cortes: en →2020 gana al estático y en →2024 el estático es peor.
4. **g/d:** +0,60 g/d, causado sobre todo por la pendiente de H 30–44.
5. **HED:** el −1,35 pp held-out sale de las dos compensaciones de la sección 4. El sesgo de entrenamiento es −5,10 pp.
6. **Nunca/ex no tienen metas de diseño en el código.** Contra ENPG, el MAE held-out de nunca es 18,5 pp (V0).
7. **Mortalidad 2022/2024** (+1,30 / +3,11 % y +2,54 / +4,68 %, M/H): es una concordancia, no una validación independiente.

### Proyección 2025–2034 (lo que hace el notebook)

Modelo `ms_fit(2024)`, 1 semilla, tiempo y $q_x$ congelados en 2024, stocks INE proyectados:

| Año | $pc$ nacional, motor | $pc$ analítica | g/d medio poblacional (encuesta) | Población 15–65 | Muertes esperadas (M + H) |
|---|---:|---:|---:|---:|---:|
| 2024 | 39,52 % | 39,80 % | 2,33 | 13.795.015 | 32.725 |
| 2025 | 39,24 % | ≈ 39,8 % | 2,26 | 13.911.959 | 33.168 |
| 2030 | 39,35 % | ≈ 39,8 % | 2,26 | 14.330.646 | 34.647 |
| 2034 | 39,19 % | 39,77 % | 2,25 | 14.481.277 | 35.532 |

1 semilla [verificado con datos]

- El motor queda 0,2–0,6 pp bajo la curva analítica (39,77–39,83 %). Es coherente con una desviación aleatoria que persiste por $\rho$: el máximo $\lvert z\rvert$ por celda es 3,20 en 80 año-celdas, con Bonferroni $p\approx0{,}11$.
- **Sin congelar el tiempo,** la prevalencia de 2034 sería 32,14 % (−7,6 pp; −11,5 pp en H 60–65).
- **Con el modelo de entrenamiento,** congelado, sería 48,32 %.
- **Muertes esperadas analíticas:** 11.996 (M) y 21.166 (H) en 2025; 12.718 y 22.812 en 2034. Las tasas brutas suben de 1,718 a 1,759 (M) y de 3,054 a 3,147 (H) por 1.000, sólo por composición etaria.
- **Ajuste dentro de muestra del modelo reajustado** (1 semilla, no es validación): actual −0,34 / 4,31 pp; g/d −0,079 / 0,605 g/d; HED −4,76 / 7,34 pp (sesgo / RMSE) [corrido, sin verificación independiente].

**Lectura.** La proyección es un escenario «todo como en 2024» del modelo reajustado. Tiene tres debilidades:

- no tiene dispersión Monte Carlo (1 semilla);
- no tiene incertidumbre de parámetros;
- arrastra el nivel de mortalidad +2,0 / +3,5 % sobre DEIS 2024.

Tampoco tiene todavía ningún efecto del alcohol sobre la mortalidad.

---

## 9. Ejemplo trabajado

Persona A: hombre de 35 años en 2016 (celda H 30–44), modelo `ms_fit(2020)`. Las latentes se eligieron a mano: $Z^{status}=-0{,}6$, $Z^{amount}=0{,}9$, $Z^{HED}=-0{,}3$. Las innovaciones de 2017 son $\varepsilon=(0{,}3;\,-0{,}5;\,1{,}2)$. Una persona idéntica pasada por `ms_exposure` da los mismos resultados en las filas de estado, $g$, HED y categoría de encuesta [verificado con datos]. Las filas de mortalidad son aritmética sobre la tabla HMD [verificado con datos]; `ms_exposure` no las calcula, ni tampoco la categoría en escala de riesgo.

Las filas siguen el orden del código dentro del año: actual → $g$ → HED → `ever` → categoría → mortalidad → fin de año. La columna 2017 empieza con el AR(1) aplicado al cierre de 2016 (sección 0), justo antes de asignar la exposición de 2017.

| Paso | Fórmula | 2016 | 2017 |
|---|---|---:|---:|
| Parámetros del año (`drivers`) | $\tau^*$; $pc$; $\mu$; $k$; $p_0$; $\phi$ | 0,4; 0,610437; 7,39145; 0,588681; 0; 12,55596 | 0,5; 0,612638; 7,62871; 0,588681; 0; 12,95900 |
| Latente de estado | $Z'=0{,}8Z+0{,}6\varepsilon$ | −0,6 | 0,8·(−0,6) + 0,6·0,3 = −0,30 |
| $U^{status}$ | $\Phi(Z^{status})$ | 0,274253 | 0,382089 |
| Is_Current | $U<pc$ | 0,274 < 0,610 → **1** | 0,382 < 0,613 → **1** |
| Latente de monto | — | 0,9 | 0,8·0,9 + 0,6·(−0,5) = 0,42 |
| $U^{amount}$ = $U^{pos}$ (porque $p_0=0$) | $\Phi(Z^{amount})$ | 0,815940 | 0,662757 |
| $g$ | $F^{-1}_\Gamma(U^{pos};k,\phi)$ | **13,0116 g/d** | **7,4344 g/d** |
| $\eta$ | $\gamma_{H,30-44}+\gamma_{gpd}\log(1+g)$ = −3,09972 + 2,34350·log1p(g) | 3,08684 | 1,89735 |
| $p^{HED}$ | $\operatorname{logit}^{-1}\eta$ | 0,956347 | 0,869592 |
| Latente HED | — | −0,3 | 0,8·(−0,3) + 0,6·1,2 = 0,48 |
| $U^{HED}$; HED | $g>0$ y $U^{HED}<p^{HED}$ | 0,382089 → **1** | 0,684386 → **1** |
| Estado / ever | actual ⇒ ever = 1 | actual, ever = 1 | actual, ever = 1 |
| Categoría (encuesta) | H: $g<40$ | cat1 | cat1 |
| Categoría (riesgo) [propuesta; no está en el código] | $g\times$factor_CH | 13,01 × 4,34733 = 56,57 → cat2 | factor no definido (2017 no es año de ola) |
| Mortalidad | $q^*=1-(1-q_x)^{0{,}952405}$ | $q_{35}$ = 0,00157 → $q^*$ = 0,001495 | $q_{36}$ = 0,00152 → $q^*$ = 0,001448 |
| Fin de año | edad + 1; ajuste INE de la celda (H, 36); AR(1) | 35 → 36: sigue en 30–44; sólo saldría si la celda tuviera exceso y lo eligiera `sample.int` | — |

Nota:

- Su percentil de monto baja de 0,816 a 0,663, así que su g/d cae de 13,0 a 7,4 aunque $\mu$ suba.
- Perdería el HED si $Z^{HED}\ge1{,}1245$ en 2017.
- Con tu fórmula literal, $U^{amount}=U/p_0=\infty$. Con $U/pc$ = 0,449 su g/d sería 3,09: el más propenso bebería menos. Con $1-U/pc$ = 0,551 sería 4,70, y en 2017 caería a 2,26 porque su $U^{status}$ sube.

Persona B, para la sección 2: misma celda y parámetros del año, $Z^{status}_{2016}=1{,}5$ e innovación $-0{,}5$ [verificado con datos]:

| Paso | 2016 | 2017 |
|---|---:|---:|
| $Z^{status}$; $U^{status}$ | 1,5; 0,933193 | 0,8·1,5 + 0,6·(−0,5) = 0,9; 0,815940 |
| Is_Current | 0,933 > 0,610 → 0 | 0,816 > 0,613 → 0 |
| $U^{history}=(U-pc)/(1-pc)$ | 0,828507 | 0,524837 |
| Tu regla ($p_F$ = 0,704766) | 0,829 > 0,705 → **nunca** | si se aplica cada año (V2): 0,525 ≤ 0,705 → **ex**, sin haber bebido |
| Umbral equivalente $1-(1-pc)(1-p_F)$ | 0,884988 (U lo supera → nunca) | 0,885638 (U no lo supera → ex) |
| Código (V0) | si es «fresca», es ex con probabilidad 0,705 vía `runif`, sin mirar $U$ | conserva el `ever` de 2016: sigue nunca (o ex) |
| V1 (latente sólo al entrar) | nunca | sigue nunca |

---

## 10. Diferencias entre tu formulación y el código: decisiones

Las recomendaciones son propuestas; ninguna está implementada. Cada fila da una opción por defecto y, cuando corresponde, la alternativa («si …»).

- **Tipo:** «redactar» = basta escribir en la especificación lo que el código ya hace; «cambia el modelo» = cambia el código o las metas; «cambia la corrida» = cambia cómo se corre el notebook.
- No asigno responsables ni prioridades, porque ninguna fuente los fija. Sólo se indica cuando la decisión depende de ACC/CC (D3).

| # | Tema (§) | Tipo | Tu formulación | Código | Consecuencia simulada | Recomendación |
|---|---|---|---|---|---|---|
| 1 | Regla ex/nunca (§2) | cambia el modelo | latente reescalada, cada año | `runif` una vez al entrar | Nunca 2024: V0 5,0 / V1 6,6 / V2 2,0 % (ENPG 25,8). Ex: 46,7 / 45,1 / 49,6 % (38,3). MAE de nunca en entrenamiento 8,0 / 5,6 / 11,8 pp; held-out 18,5 / 16,8 / 21,8 | Por defecto: tu regla latente **sólo al entrar** (V1), **no** cada año, y mantener D4b (las historias no alimentan el RR). Si las historias deben alimentar el RR: agregar abstemios de por vida absorbentes, que frenan la erosión [RECALIB] |
| 2 | $p_F$ (§2) | redactar y cambia el modelo | $P(\text{Former}\mid\text{no actual},s,a)$ | agrupada 2012–2020, fija, sin EE; a los 15 años usa la de 15–29 | Explica 6,7 / 5,3 pp de la brecha de 2012. A los 15: 0,59 / 0,56 usada frente a 0,35 / 0,30 observada | Escribir el estimador; agregar el EE de diseño; usar $p_F$ por edad simple (15–17) para quienes entran |
| 3 | $U^{amount}$ (§3) | redactar | $U/p_0$ [errata] | latente propia $\Phi(Z^{amount})$ | La tuya no es un percentil; $U/pc$ invierte el orden | Escribir $U^{amount}=\Phi(Z^{amount})$, independiente. Correlación participación–monto sólo como sensibilidad |
| 4 | $\rho$ por latente (§0) | cambia el modelo (sensibilidad) | un único $\rho$ = 0,8 | el mismo para las 3 | EPS: participación con rasgo + AR(1); g/d plano; HED sin dato | Por defecto: mantener 0,8 y exponer un $\rho$ por latente para correr sensibilidad. No trasladar los parámetros de la EPS a g/d ni a HED |
| 5 | $\mu$ (§3) | redactar | aditiva, 6 parámetros | por celda, 16 | Aditiva: peor en entrenamiento (F, $p$ = 0,0007); held-out 1,28 frente a 1,07 g/d | Adoptar la forma por celda en la especificación. Ninguna corrige el nivel de 2024 |
| 6 | $\gamma$ del HED (§4) | redactar | aditiva | por celda | RMSE 7,01 frente a 6,91 pp en entrenamiento; 5,08 frente a 5,51 pp en held-out | Indiferente. Mantener por celda y declararlo |
| 7 | Año en el HED (§4) | redactar | «año calendario» | sin año | Lineal $p$ = 0,20; ola 2018 +0,257 en logit | No agregar tendencia lineal. Si hace falta, un efecto por ola declarado como calibración |
| 8 | Dominio del HED (§4) | redactar | todo actual | sólo $g>0$ | ≤ 0,004 pp | Escribir «si $g>0$» |
| 9 | Ley de g/d (§3, §4) | cambia el modelo | Gamma | Gamma | 18–30 % bajo 0,4 g/d (ENPG ≈ 0). $G-B$ = −4,68 pp de HED (incluye el error de $\hat\mu$) | Cuantiles empíricos ponderados reescalados a $\mu$ (auditoría) antes de tocar el glm |
| 10 | Categorías (§5) | cambia el modelo; la escala depende de D3 (ACC/CC) | cat0 = $g=0$; $(\cdot,\cdot]$; escala sin definir | `noncurrent`; $[\cdot,\cdot)$; escala de encuesta | cat2 + cat3: 1,6–2,8 % (encuesta) frente a 25–37 % (motor) y 24–32 % (ENPG) en escala de riesgo | cat0 = no actual, con nunca/ex aparte; bordes OMS ($\le$). Si se confirma D3: categorías sobre $g\times$factor_CH para RR/IB, y definir el factor en años sin ola y en 2025+ |
| 11 | Estimador de $pc$ (§1) | redactar; propagar la incertidumbre cambia el modelo | no lo defines | WLS delta | La logística individual cambia la pendiente de M 60–65 de signo | Declarar WLS como mínima distancia; logística como sensibilidad; propagar la incertidumbre de los parámetros (sorteos) |
| 12 | Tiempo en la proyección (§1, §8) | redactar | $\tau=(t-2012)/10$ siempre | congelado en 2024 | 2034: 39,8 % frente a 32,1 % | Escribir $\tau^*$; tendencia sólo como escenario acotado |
| 13 | Modelo y semillas de la proyección (§8) | cambia la corrida | no defines el modelo de la proyección; pides 5 semillas por corrida | reajuste con 7 olas, 1 semilla | 2034: 39,8 % (reajuste) frente a 48,3 % (modelo de entrenamiento); sin DE Monte Carlo | Correr con `ms_cfg$seeds`; declarar que el held-out ya se usó |
| 14 | Mortalidad: fuente de la tasa y $\kappa$ (§6) | cambia el modelo | INE ene/jun para tasas centrales; HMD $q_x$ y $m_x$; $\kappa$ no lo defines | HMD $q_x$ elevada a un $\kappa$ por sexo, constante 2012–2020 | Brecha de denominador 3,7 → 6,6 % (M) y 4,8 → 11,0 % (H); error 2024 +2,54 % (M) y +4,68 % (H) | Por defecto: tasas DEIS/INE a la edad al 1 de enero (paralelogramo), según la auditoría. Si se mantiene HMD: declarar $q_x$ y su deriva, y usar un $\kappa$ con tendencia |
| 15 | Diseño 2020 (Insumos, §1) | cambia el modelo (metas) | UPM y estratos | sin UPM; región no usada | El EE quizá es pequeño; 2020 pesa el 17,4 % del ajuste | Por defecto: inflar el EE con el efecto de diseño de 2018 (como D6 para AAF). Si se consigue la UPM validada, usarla |
| 16 | Registro, «muestra» y 25.000 (§7) | redactar | — | réplica INE; $\omega$ fijo | La población crece hasta 30.091 | Renombrar «población sintética INE»; definir $\omega$ y $n_{2012}$ |
| 17 | Ajuste INE frente a política (§7) | cambia el modelo | — | borra las ganancias de supervivencia | Brazos desincronizados | En una primera etapa, supervivencia compartida; después, repetir los $\Delta$ del control |
| 18 | Mortalidad sin vínculo con la exposición (§6) | cambia el modelo | tu diagrama pone la exposición antes de la mortalidad | $q^*$ no depende del consumo | Una política no puede cambiar las muertes | Es el ítem 3 del plan de integración ([`plan_microsim_integracion_2026-10-09.md`](plan_microsim_integracion_2026-10-09.md)) |
| 19 | FD de 30 días frente al RR de ex (Insumos, §2) | redactar | FD = exconsumidor > 30 días | ídem (D4) | El 38,8–53,4 % de los FD tiene `oh2` = ">30"; el RR de ex supone ≥ 12 meses | D4 está confirmada: mantenerla y declararla. El registro (`expand_pif_registro_2026-10-06.md`, V2) mantiene abierta, para AAF, una sensibilidad 2024 con la definición de 12 meses |
| 20 | HED 5+/4+ frente a 60 g (§4) | redactar | «HED: episodios» | indicador de ≥ 1 episodio 5+ (H) / 4+ (M) | En mujeres, 4 tragos son 48 g, bajo los 60 g de la OMS | D5 (confirmada para AAF): mantener como *proxy* y declarar los gramos |
| 21 | Truncamiento 15–65 (§7) | redactar | «Defunciones DEIS, 15-65» | ídem | Quedan fuera el 79,5 % (M) y el 66,2 % (H) de las muertes de 15+ años y el 26–31 % de las muertes con AAF = 1 | Tu especificación fija 15–65: declarar la pérdida y que se truncan los beneficios rezagados |
| 22 | Scripts de esta sesión (§12) | reproducibilidad | — | archivados con rutas de marcador | No corren tal cual desde el repositorio | Restituir rutas y re-correrlos localmente con renv |

---

## 11. Limitaciones conocidas (índice)

Cada limitación se discute en la sección indicada.

1. **$\rho=0{,}8$ frente a la EPS:** 0,180 a 7,69 años frente a 0,478; el paso de un año no está identificado (§0).
2. **Gamma cerca de cero:** la ley Gamma, sobre todo su masa cerca de cero, explica la mayor parte del sesgo HED ($G-B$ = −4,68 de −5,10 pp, que incluye el error de $\hat\mu$) (§3, §4).
3. **Extrapolación de tendencias lineales:** la prevalencia falla por nivel (+9,71 pp; 0/16); el g/d sube por H 30–44 (§1, §8).
4. **Deriva de mortalidad:** el error de las muertes esperadas crece +0,26 / +0,53 pp/año, sobre todo porque la exposición HMD diverge del stock INE (≈ 78 % de la deriva en M, ≈ 89 % en H); la mortalidad posterior a 2020 no es validación independiente (§6).
5. **Truncamiento 15–65** (§7; decisión #21).
6. **DEIS 2024 provisional:** R99 está +33 % sobre 2018–2023, y las lesiones de tránsito, −20 %, según `mortality_deis.md` (la fila 14 de `mortality_deis_verify.md` da 1.224 frente a 1.395–1.659) [leído, no corrido]. No se discute en otra sección.
7. **Erosión estructural de «nunca»** (§2).
8. **Ninguna incertidumbre de parámetros llega al motor;** las 5 semillas sólo miden ruido Monte Carlo (Parámetros, §1, §8).
9. **El held-out ya se usó** en el reajuste y en RECALIB (Parámetros, §8).
10. **Procedencia y entorno:** `ENPG_BINGE.RDS` no tiene constructor en el repositorio (Insumos); hay que correr en un locale UTF-8 (Anexo A); los scripts de esta sesión están archivados con rutas de marcador y no corren tal cual (§12).

---

## 12. Trazabilidad

- **Código fuente:** el notebook [`microsim_base_ACC_2012_2024.ipynb`](microsim_base_ACC_2012_2024.ipynb) y su explicación [`microsim_base_ACC_2012_2024_explicacion.md`](microsim_base_ACC_2012_2024_explicacion.md). Las salidas guardadas en [`microsim_base_outputs/`](microsim_base_outputs/) usan el DEIS anterior al arreglo.
- **Contraste:** [`microsim_recalib_ACC_2012_2024.ipynb`](microsim_recalib_ACC_2012_2024.ipynb) usa el mismo motor con `interp_hold` sobre 7 olas. No es tu especificación.
- **Auditoría que respalda este documento** (en cada par, el archivo *verify* prevalece sobre el original; usaron sobre todo RECALIB y las semillas 2125–2129). Están en [`auditoria_microsim_2026-10-09/`](auditoria_microsim_2026-10-09/):
  - [`persistence.md`](auditoria_microsim_2026-10-09/persistence.md) y [`persistence_verify.md`](auditoria_microsim_2026-10-09/persistence_verify.md);
  - [`hed_diagnostic.md`](auditoria_microsim_2026-10-09/hed_diagnostic.md) y [`hed_diagnostic_verify.md`](auditoria_microsim_2026-10-09/hed_diagnostic_verify.md);
  - [`mortality_deis.md`](auditoria_microsim_2026-10-09/mortality_deis.md) y [`mortality_deis_verify.md`](auditoria_microsim_2026-10-09/mortality_deis_verify.md);
  - [`rr_bridge.md`](auditoria_microsim_2026-10-09/rr_bridge.md) y [`rr_bridge_verify.md`](auditoria_microsim_2026-10-09/rr_bridge_verify.md);
  - [`engine_ponytail.md`](auditoria_microsim_2026-10-09/engine_ponytail.md) (sin verify) y [`notes_decisions.md`](auditoria_microsim_2026-10-09/notes_decisions.md).
- **Informe de literatura y plan:** el informe [`Microsimulación de alcohol y mortalidad.md`](<../reports/Microsimulación de alcohol y mortalidad.md>) y el plan [`plan_microsim_integracion_2026-10-09.md`](plan_microsim_integracion_2026-10-09.md).
- **Referencia de arquitectura:** Kilian C, et al. *Lancet Public Health* 2025, DOI 10.1016/S2468-2667(25)00165-3; SIMAH, DOI 10.5281/zenodo.15641639.
- **Scripts de esta sesión.** Están archivados en `auditoria_microsim_2026-10-09/scripts_especificacion_2026-10-09.tar.gz` (carpeta `spec/`, 49 archivos con sus logs; las rutas de la nube se reemplazaron por los marcadores `<scratch>`, `<repo>` y `<R tempdir>`, así que no corren tal cual). Los scripts anteriores de la auditoría están en `scripts_nube_2026-10-09.tar.gz`. Son:
  - el cargador `load_base_engine.R`, que corre las celdas BASE literalmente con tres sustituciones de texto (lista de paquetes, `ms_table` sin efecto y lectura del parquet con python hacia `tempdir()`), más `setwd` y el locale `C.UTF-8`;
  - los cuatro dossieres (`dossier_latente_historia.R`, `prev_validation.R` y sus scripts auxiliares `prev_*.R`, `dossier_intensidad_hed.R`, `dossier_insumos_demografia.R`);
  - sus verificaciones (`verify_latente.R`, `verify_prev*.R`, `verify_ihc.R`, `verify_demo*.R`, `verify_locale*.R`);
  - `final/ejemplo_extra.R` (filas de mortalidad del ejemplo y persona B), `final/tables56.R` (tablas del Anexo B) y la revisión del ejemplo, `review_fid/check_example.R`.

  Sólo escribieron agregados (tablas por celda, coeficientes y resúmenes simulados). Los microdatos quedaron en memoria o en el `tempdir()` de R. Para reproducir este documento hay que restituir las rutas y volver a correrlos localmente con renv.

---

## Anexo A — Verificación y procedencia

Detalle de verificación que no hace falta para estudiar el modelo.

**A.1 Prueba de no filtración** (`ms-fit-and-check` L26–47). Altera los datos posteriores a 2020 (L32–38):

- en ENPG: pone `current = 0` a todos los respondentes, `gpd_survey = 999` y `hed = 1`;
- en las metas: sólo `current_mean` y `gpd_mean`;
- en DEIS: las defunciones.

Después exige coeficientes, `shape` (que contiene $k$, $p_0$ y $p_F$) y $\kappa$ idénticos. `ever` no se altera.

**A.2 Metas de diseño** [verificado con datos]:

- Las medias de Hájek coinciden con medias ponderadas simples (diferencia 8,9·10⁻¹⁶).
- El EE escrito a mano coincide con `svymean` (diferencia relativa ≤ 9,8·10⁻¹⁵ en 2012, 2016 y 2020). El cociente EE propio / EE del código es exactamente 1 en 2012–2022 y 0,992–1,000 en 2024, por el ajuste de UPM única (`ms-survey-inputs` L111).
- En 2024 hay 257 avisos de UPM única, sumados sobre `current`, `gpd` y `hed` (11 / 123 / 123). En la prevalencia son 11 estratos, con efecto ≤ 0,8 % en el EE.
- La tabla de metas exportada (`spec/out_demo/targets_56_full.csv`) es igual a `ms_targets` (diferencia ≤ 5,3·10⁻¹⁵).

**A.3 Versiones de los insumos frente a la exportación guardada** [verificado con datos]:

- ENPG (3 archivos) e INE: mismo md5.
- HMD: difiere sólo en los finales de línea (LF frente a CRLF). Con CRLF reproduce los md5 guardados.
- DEIS 2012–2023: cambió (`8652ad19…`, sin 1.815 defunciones de lactantes mal codificadas).
- DEIS 2024: archivo semanal `06102026`; la exportación guardada usó el `09062026`.

**A.4 Validación de hoy frente a la exportación guardada** (`microsim_base_outputs/validation_metrics.csv`) [verificado con datos]:

| Período | Variable | Hoy (sesgo / RMSE / dentro) | Guardado (sesgo / RMSE / dentro) |
|---|---|---|---|
| Entrenamiento | actual | −0,09 pp / 3,61 pp / 23/32 | −0,12 / 3,64 / 22/32 |
| Entrenamiento | g/d | −0,089 / 0,446 g/d / 30/32 | −0,079 / 0,434 / 31/32 |
| Entrenamiento | HED | −5,10 pp / 7,18 pp / 19/32 | −5,08 / 7,15 / 19/32 |
| Held-out | actual | +9,71 pp / 10,22 pp / 0/16 | +9,75 / 10,26 / 0/16 |
| Held-out | g/d | +0,60 / 1,11 g/d / 11/16 | +0,56 / 1,08 / 12/16 |
| Held-out | HED | −1,35 pp / 5,58 pp / 10/16 | −1,14 / 5,34 / 12/16 |

Difieren sólo por el DEIS corregido, que cambia $\kappa$, cambia quién muere y desincroniza el generador aleatorio. Prueba directa: con el $\kappa$ guardado (0,976676 / 0,957069), el motor reproduce las 6 métricas guardadas con diferencia ≤ 4,4·10⁻¹⁵.

**A.5 EPS a 7,69 años.** La tetracórica observada es 0,478 en `persistence.md`; `engine_ponytail.md` L73 da 0,485 [leído, no corrido].

**A.6 Locale.** La regla «>1 año» (`ms-survey-inputs` L69–71) funciona en la celda literal, en cualquier locale. Pero en `LC_ALL=C`, una reescritura en una línea de `Rscript` con otros escapes la deja sin coincidencias (24.457 FD pasarían a «desconocido»), y `ms-demography-inputs` L62 (`"AÑO"`) falla. Hay que correr siempre en un locale UTF-8 [verificado con datos].

## Anexo B — Las 56 metas completas

Media (EE de diseño) por celda y ola, 15–65 años. Actual, nunca y ex en % de quienes tienen estado conocido; g/d entre bebedores actuales con g/d observado; HED en % de los bebedores actuales con HED observado. 2022 y 2024 son held-out. Fuente: `spec/out_demo/targets_56_full.csv` (carpeta de trabajo de la sesión).

- Actual, g/d y HED: [verificado con datos].
- Nunca y ex: medias [verificado con datos]; EE [corrido, sin verificación independiente]. No son metas del código; nunca + ex + actual = 100 % en cada celda.

**B.1 Consumo actual, %**

| Celda | 2012 | 2014 | 2016 | 2018 | 2020 | 2022 | 2024 |
|---|---|---|---|---|---|---|---|
| M 15–29 | 36,4 (1,8) | 43,2 (1,9) | 44,6 (2,0) | 38,2 (1,8) | 38,5 (1,9) | 35,3 (1,5) | 29,7 (1,9) |
| M 30–44 | 36,0 (1,7) | 47,7 (1,6) | 44,3 (2,1) | 42,3 (1,9) | 42,6 (2,0) | 40,2 (1,5) | 33,5 (1,6) |
| M 45–59 | 33,2 (1,8) | 45,0 (2,1) | 39,0 (2,1) | 31,9 (1,7) | 39,2 (2,1) | 31,5 (1,3) | 26,7 (1,5) |
| M 60–65 | 24,0 (2,0) | 38,2 (3,1) | 30,3 (2,4) | 27,6 (3,0) | 29,0 (2,5) | 23,0 (1,4) | 17,8 (1,6) |
| H 15–29 | 51,6 (2,0) | 53,7 (1,9) | 56,3 (1,9) | 54,7 (1,7) | 51,8 (2,4) | 41,5 (1,6) | 40,8 (2,3) |
| H 30–44 | 58,3 (1,8) | 65,3 (2,0) | 59,8 (1,9) | 59,9 (2,1) | 62,9 (2,3) | 55,5 (1,6) | 50,3 (1,8) |
| H 45–59 | 51,9 (2,2) | 57,4 (2,2) | 53,4 (2,1) | 54,7 (1,8) | 53,5 (2,5) | 47,8 (1,6) | 42,7 (1,9) |
| H 60–65 | 44,2 (3,3) | 54,9 (3,2) | 46,6 (3,2) | 48,4 (3,0) | 45,7 (3,1) | 38,3 (2,1) | 33,0 (2,5) |

**B.2 Nunca, %**

| Celda | 2012 | 2014 | 2016 | 2018 | 2020 | 2022 | 2024 |
|---|---|---|---|---|---|---|---|
| M 15–29 | 31,1 (1,8) | 22,4 (1,5) | 21,8 (1,4) | 26,2 (1,5) | 21,1 (1,6) | 24,6 (1,3) | 35,0 (1,9) |
| M 30–44 | 28,8 (2,0) | 18,1 (1,4) | 16,0 (1,4) | 19,6 (1,5) | 17,9 (1,6) | 18,5 (1,0) | 24,5 (1,3) |
| M 45–59 | 34,2 (2,3) | 20,8 (1,4) | 19,3 (1,3) | 24,0 (1,6) | 17,7 (1,3) | 23,5 (1,1) | 31,4 (1,4) |
| M 60–65 | 43,1 (2,8) | 28,5 (2,9) | 27,8 (2,2) | 28,8 (2,0) | 23,8 (1,8) | 31,8 (1,4) | 37,1 (1,7) |
| H 15–29 | 27,6 (1,9) | 21,4 (1,7) | 16,7 (1,3) | 18,8 (1,3) | 17,9 (1,6) | 25,7 (1,4) | 25,0 (1,8) |
| H 30–44 | 16,8 (1,5) | 10,6 (1,0) | 10,0 (1,0) | 12,3 (1,1) | 8,4 (1,0) | 12,7 (1,0) | 16,2 (1,1) |
| H 45–59 | 19,6 (1,8) | 11,0 (1,0) | 12,2 (1,2) | 12,8 (1,3) | 12,5 (1,4) | 15,4 (1,1) | 22,0 (1,5) |
| H 60–65 | 23,0 (3,5) | 13,7 (1,7) | 12,9 (1,6) | 11,5 (1,3) | 13,6 (2,4) | 17,3 (1,6) | 19,4 (1,7) |

**B.3 Ex (FD), %**

| Celda | 2012 | 2014 | 2016 | 2018 | 2020 | 2022 | 2024 |
|---|---|---|---|---|---|---|---|
| M 15–29 | 32,5 (2,2) | 34,4 (2,1) | 33,7 (1,7) | 35,5 (1,6) | 40,3 (2,0) | 40,1 (1,5) | 35,3 (1,9) |
| M 30–44 | 35,1 (1,7) | 34,2 (1,5) | 39,7 (1,8) | 38,1 (1,7) | 39,5 (1,9) | 41,3 (1,4) | 42,1 (1,6) |
| M 45–59 | 32,5 (1,7) | 34,2 (2,0) | 41,7 (1,9) | 44,1 (1,9) | 43,1 (2,1) | 45,0 (1,3) | 41,9 (1,6) |
| M 60–65 | 32,9 (2,2) | 33,3 (2,7) | 41,9 (2,8) | 43,6 (2,7) | 47,2 (2,6) | 45,2 (1,5) | 45,1 (2,0) |
| H 15–29 | 20,8 (1,4) | 24,9 (1,7) | 27,1 (1,7) | 26,5 (1,6) | 30,4 (2,1) | 32,7 (1,5) | 34,2 (2,1) |
| H 30–44 | 24,8 (1,5) | 24,1 (1,9) | 30,2 (1,8) | 27,8 (2,0) | 28,8 (2,2) | 31,9 (1,4) | 33,5 (1,6) |
| H 45–59 | 28,6 (1,8) | 31,5 (2,2) | 34,4 (2,1) | 32,5 (1,7) | 34,1 (2,3) | 36,8 (1,5) | 35,3 (1,8) |
| H 60–65 | 32,7 (2,9) | 31,5 (3,0) | 40,5 (2,9) | 40,1 (2,7) | 40,7 (3,0) | 44,5 (2,1) | 47,6 (2,7) |

**B.4 g/d entre bebedores actuales (escala de encuesta)**

| Celda | 2012 | 2014 | 2016 | 2018 | 2020 | 2022 | 2024 |
|---|---|---|---|---|---|---|---|
| M 15–29 | 4,87 (0,54) | 3,95 (0,26) | 4,65 (0,38) | 4,55 (0,26) | 4,41 (0,30) | 4,40 (0,33) | 4,58 (0,67) |
| M 30–44 | 2,99 (0,23) | 3,42 (0,39) | 4,51 (0,52) | 3,43 (0,18) | 3,40 (0,21) | 4,02 (0,30) | 3,81 (0,28) |
| M 45–59 | 3,14 (0,54) | 2,64 (0,16) | 2,60 (0,22) | 2,59 (0,18) | 3,48 (0,35) | 3,00 (0,23) | 3,10 (0,23) |
| M 60–65 | 2,25 (0,27) | 2,52 (0,24) | 3,01 (0,36) | 2,97 (0,47) | 3,06 (0,47) | 3,16 (0,34) | 2,57 (0,37) |
| H 15–29 | 7,63 (0,37) | 7,52 (0,71) | 7,72 (0,48) | 7,71 (0,57) | 6,62 (0,54) | 6,81 (0,42) | 5,33 (0,46) |
| H 30–44 | 6,38 (0,32) | 7,18 (0,63) | 7,42 (0,52) | 8,51 (0,56) | 7,72 (0,58) | 7,19 (0,39) | 6,70 (0,53) |
| H 45–59 | 7,90 (0,53) | 6,74 (0,54) | 7,78 (0,61) | 7,98 (0,57) | 7,61 (1,33) | 7,25 (0,49) | 7,09 (0,56) |
| H 60–65 | 5,97 (0,58) | 5,98 (0,70) | 5,77 (0,61) | 5,37 (0,46) | 7,16 (0,72) | 7,53 (0,90) | 6,00 (0,60) |

**B.5 HED entre bebedores actuales, %**

| Celda | 2012 | 2014 | 2016 | 2018 | 2020 | 2022 | 2024 |
|---|---|---|---|---|---|---|---|
| M 15–29 | 54,7 (2,8) | 50,1 (2,9) | 59,4 (3,3) | 64,5 (3,2) | 57,3 (3,2) | 49,8 (2,7) | 54,7 (4,1) |
| M 30–44 | 41,7 (2,8) | 40,5 (2,8) | 47,2 (3,1) | 56,4 (3,4) | 45,5 (3,2) | 49,0 (2,3) | 48,8 (3,1) |
| M 45–59 | 36,1 (3,2) | 33,8 (2,3) | 37,0 (3,6) | 42,7 (3,7) | 37,8 (3,4) | 42,5 (2,5) | 41,4 (3,3) |
| M 60–65 | 21,0 (3,5) | 29,4 (4,8) | 35,1 (4,5) | 47,7 (7,2) | 31,2 (5,4) | 36,5 (3,5) | 31,2 (4,1) |
| H 15–29 | 71,3 (2,7) | 63,9 (2,5) | 66,8 (2,6) | 65,3 (3,1) | 61,4 (3,5) | 61,1 (2,7) | 50,1 (4,1) |
| H 30–44 | 58,2 (2,4) | 60,6 (2,7) | 60,3 (2,8) | 69,9 (3,3) | 64,4 (3,3) | 60,2 (2,5) | 54,7 (2,8) |
| H 45–59 | 59,9 (2,9) | 50,3 (2,9) | 49,7 (3,0) | 61,9 (2,7) | 53,5 (3,9) | 54,5 (2,5) | 50,3 (3,2) |
| H 60–65 | 42,5 (4,6) | 39,4 (4,6) | 37,0 (5,5) | 39,9 (4,6) | 44,6 (4,8) | 48,8 (3,8) | 37,6 (3,9) |
