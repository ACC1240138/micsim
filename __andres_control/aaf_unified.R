# =============================================================================
# aaf_unified.R
# -----------------------------------------------------------------------------
# Motor UNICO de Fraccion Atribuible al Alcohol (AAF / PAF) y de Fraccion de
# Impacto Potencial (PIF) para mortalidad.
#
# Reemplaza/generaliza los 5 caminos de codigo PAF que hoy conviven y divergen:
#   confint_paf_parallel()        beta escalar,            sin HED
#   confint_paf_vcov_parallel()   multi-beta + covarianza, sin HED
#   confint_paf_hed_parallel()    beta escalar + HED (3 integrales, doble conteo)
#   .adam_confint_paf_binge()     injuries: 2 betas + HED (2 integrales, correcto)
#   .aaf_cv()/.cv_cell()          IHD/IS J-curve + binge (cap), RR_FD fijo
# y UNIFICA el PIF (antes en functions.R de injuries) con el PAF, sobre la MISMA
# poblacion: el PAF es el caso particular del PIF con eliminacion total.
#
# Una sola formula, con incorporacion OPCIONAL ("de haber") de:
#   * HED / binge          -> modelo de DOS componentes (NHED + HED), sin doble conteo
#   * multiples betas      -> vector beta + matriz de covarianza completa (mvrnorm)
#   * RR_FD + su varianza  -> RR_FD fijo, o sorteo lognormal exp(N(lnRRFormer, var))
#
# Funciones publicas:
#   aaf_point(...)    -> PAF puntual deterministica
#   aaf_confint(...)  -> PAF + IC 95% por Monte Carlo
#   pif_point(...)    -> PIF puntual deterministica (escenario HED o volumen)
#   pif_confint(...)  -> PIF + IC 95% por Monte Carlo
#
# -----------------------------------------------------------------------------
# UNIFICACION PAF/PIF (riesgo poblacional comun).  Sea, sobre la grilla x:
#   R(g)  = INT (d_g / Z_g) * RR_g dx        (Z_g = INT d_g, sobre RANGO COMPLETO)
#   R_obs = p_abs + p_form*RR_FD + cur*[(1-p_hed)*R_nhed + p_hed*R_hed]
#           con cur = 1 - (p_abs + p_form)
#   PAF   = (R_obs - 1) / R_obs              (= num/(num+1); R_cf = 1, "cero alcohol")
#   PIF   = (R_obs - R_cf) / R_obs           (R_obs IDENTICO al del PAF -> comparables)
# El denominador es el riesgo POBLACIONAL total (incluye abstemios y ex-bebedores),
# el mismo que usa el PAF; por eso PAF = PIF(eliminacion total).
#
# Contrafactuales del PIF (parametro `shift` = fraccion RETENIDA; 0.9 = -10%):
#   scenario="hed"    : una fraccion (1-shift)*p_hed deja el binge -> pasa a NHED.
#                       Que pasa con su CONSUMO al salir del binge lo gobiernan los
#                       knobs hed_exit_* (bloque siguiente). Por DEFECTO conserva su
#                       propia densidad d_hed y solo adopta RR_NHED.
#                       No se trunca el soporte en 60 g (correccion #1).
#                       R_cf usa: (1-p_hed)*R_nhed + shift*p_hed*R_hed
#                                 + (1-shift)*p_hed*R_exit
#   scenario="volume" : todos los bebedores reducen consumo (x -> x*shift); las
#                       proporciones no cambian; RR se reevalua en x*shift
#                       (equivale a escalar la gamma; s_hed intacto).
#
# -----------------------------------------------------------------------------
# [2026-07-14] HED-EXIT REASSIGNMENT: hed_exit_mix (lambda) / hed_exit_shift (rho)
# -----------------------------------------------------------------------------
# Motivation. Until now, the mass leaving binge under scenario="hed"/"both" kept
# its OWN consumption density d_hed and merely swapped onto the RR_NHED curve.
# That treats HED as a pure risk-curve attribute, decoupled from grams: quitting
# binge removed the binge-specific excess risk but not a single gram of alcohol,
# so the HED scenarios were volume-neutral by construction. Transition models
# (and Ruiz-Tagle's reallocation) instead assume the ex-binge drinker KEEPS
# DRINKING as a non-HED drinker, retaining only the residual risk of the volume he
# actually ends up consuming. Both are defensible; they are now the two ends of a
# parameterised family, and neither is hard-coded.
#
# Two orthogonal knobs describe the counterfactual consumption of the exiting
# mass. Writing R(d, rr) = INT (d/Z) * rr dx (see .aaf_risk, which normalises d):
#
#   hed_exit_shift = rho in (0, 1]   VOLUME the ex-binge drinker retains. He keeps
#       the SHAPE of his own density d_hed but drinks rho of the grams, so his RR
#       is read at x*rho:            R(d_hed, RR_NHED(x*rho))
#       rho = 1 -> keeps his full volume (legacy behaviour).
#
#   hed_exit_mix = lambda in [0, 1]  FRACTION of the exiting mass that migrates
#       outright to the NHED consumption DISTRIBUTION (drinks like an average
#       non-HED drinker):            R(d_nhed, RR_NHED) = R_nhed
#       lambda = 0 -> nobody migrates (legacy behaviour).
#       lambda = 1 -> full migration (Ruiz-Tagle; also the old scale_phed semantics
#                     of pif_scenarios.R, where the mass fell into the R_nhed bin).
#
# Because .aaf_risk normalises each density it is handed, the exiting subpopulation is
# a convex mixture of two PROPER conditional densities, and its risk is the convex
# mixture of the two subgroup risks -- exactly. So the two knobs compose in ONE line
# and cost NO extra integral:
#
#   R_exit = (1 - lambda) * R(d_hed, RR_NHED(x*rho)) + lambda * R_nhed
#
# Under scenario="both" the same expression is evaluated on the volume-reduced risk
# curves: the exiting mass reads its RR at x*shift*rho (the policy volume cut and
# its own binge-exit cut compound) and migrates toward R_nhed_cf.
#
# DEFAULTS ARE THE LEGACY BEHAVIOUR. hed_exit_mix = NULL -> lambda = 0 and
# hed_exit_shift = NULL -> rho = 1 reproduce every number computed before this date
# bit for bit (with rho = 1 the RR vector is reused, not re-evaluated).
#
# -----------------------------------------------------------------------------
# DIRECTION OF THE EFFECT -- READ THIS BEFORE REPORTING A SENSITIVITY RANGE
# -----------------------------------------------------------------------------
# It is TRUE only for MONOTONICALLY INCREASING RR families (cancers, liver, injuries,
# and every "explicit"/"nohed" cause) that d_nhed sits below d_hed, so lambda > 0 or
# rho < 1 lower R_cf and RAISE the PIF. For those causes the legacy default IS the
# conservative bound of the family and a (lambda, rho) sweep IS a one-sided range.
#
# IT IS FALSE FOR THE J-CURVE / hed_mode = "cap" FAMILY (IHD and ischaemic stroke).
# Measured on this project's own curves (GENERAL_ihd_RR_2018_03_16.R): the male IHD
# RR_NHED is PROTECTIVE (< 1) across its ENTIRE sub-60 g/day range, with a nadir of
# RR = 0.7787 at x ~ 31 g/day, and RR_HED is pinned at 1 by the cap. Moving the
# exiting mass DOWN in volume therefore walks it around the bottom of the J, and the
# PIF is NOT monotone in rho -- it can rise and then collapse, and lambda > 0 can
# LOWER the PIF outright. Reproduced numbers (male IHD, p_hed = .35, shift = 0.9):
#     lambda=0, rho=1 (legacy) -> PIF = 0.00424    <- an INTERIOR point, not a bound
#     lambda=1, rho=1          -> PIF = 0.00407    (LOWER)
#     lambda=0, rho=0.25       -> PIF = 0.00332    (LOWER)
#     lambda=0, rho=0.10       -> PIF = 0.00220    (LOWER, -48%)
#   and at a HED mean of 60 g/day, rho = 1/.75/.50/.25/.10 gives
#     0.00284 / 0.00442 / 0.00526 / 0.00504 / 0.00373   (rises, THEN falls).
# So: for IHD/IS, do NOT present a (lambda, rho) sweep as a one-sided sensitivity
# range and do NOT call the legacy default a bound. Report the response surface, or
# report min/max over the swept grid, and say that the non-monotonicity is a property
# of the cardioprotective J-curve, not a numerical artefact.
# test_hed_exit_knobs.R section (H) pins this behaviour against the real IHD curve so
# that nobody "corrects" this warning back into a monotonicity claim.
#
# Accounting caveat: with lambda > 0 or rho < 1 the HED scenarios are NO LONGER
# volume-neutral. They imply a drop in mean population consumption of
#   (1-shift) * p_hed * [ lambda*(E[d_hed]-E[d_nhed]) + (1-lambda)*(1-rho)*E[d_hed] ]
# which the scenario grid must report instead of the current 0%.
#
# PER-SUBGROUP knobs. lambda and rho are plain scalars at the CELL level, so a
# caller looping over (year, sex, age band) may hand a DIFFERENT value to each cell
# -- e.g. women 15-29 vs men 30-44, or a value monotone in age or in year, to feed
# the forthcoming alcohol-transition model. Pass the per-cell scalar directly, or use
# resolve_hed_exit() to turn a spec into it. Accepted shapes:
#     scalar                                   -> broadcasts to every cell
#     function(year, group, sex)               -> anything (monotone in age/year, ...)
#     list("2022" = list(edad_tramo_1 = ...))  -> year -> age band
#     list("2022" = 0.5)                       -> one value per year
#     list(edad_tramo_1 = ..., ...)            -> one value per age band
#     c(0.2, 0.4, 0.6, 0.8)                    -> numeric vector indexed by age band
# resolve_hed_exit() ERRORS on any cell the spec does not cover -- it deliberately
# does NOT fall back positionally the way .aaf_resolve_cell() does, because that
# fall-back silently hands a cell ANOTHER cell's lambda (see the note in its body).
#
# -----------------------------------------------------------------------------
# INCERTIDUMBRE de prevalencias (correcciones #2 y #4):
#   prev_method="dirichlet" (DEFAULT): la composicion (p_abs, p_form, p_curr) se
#     sortea de una Dirichlet con alpha = (p_abs,p_form,p_curr)*neff_eff + 0.5
#     (prior de Jeffreys). Garantiza p_abs+p_form+p_curr = 1 -> cur > 0 SIEMPRE
#     (no hay PAF=0 espurios en tramos de alta abstinencia). p_hed (fraccion HED
#     CONDICIONAL a ser bebedor actual) se sortea aparte como Beta con el mismo
#     neff_eff, y se RESAMPLEA por igual en PAF y PIF.
#   prev_method="binomial": modo legado (normales binomiales independientes),
#     disponible para reproducir resultados/tests anteriores.
#   neff_eff = neff_prev / design_factor.  El llamador pasa el n efectivo de Kish
#     por celda (year x sexo x edad_tramo),  neff_kish = (sum w)^2 / sum(w^2), y el
#     factor de conglomerado (~1.35, medido en PSU 2022/2024 a granularidad REGION)
#     como design_factor.  Ver revision_diseno_enpg.R.
#
# Convenciones que se MANTIENEN respecto del pipeline actual:
#   - Densidad de consumo: gamma ajustada (fitdistr) o densidad ya evaluada.
#   - AAF/PIF firmadas: NO se clipa el limite inferior (deja pasar efectos
#     protectores y, en el PIF, intervenciones no beneficiosas -> PIF<0). Solo se
#     acota el techo en 1 (correccion #3: PAF y PIF en (-inf, 1]).
#   - Salida con nombres point_estimate / lower_ci / upper_ci, compatible con
#     .adam_normalize_ci() del registry.
#
# Dependencias: stats (base) + MASS (mvrnorm). La Dirichlet se arma con rgamma
# base (sin MCMCpack/gtools).
# =============================================================================

if (!requireNamespace("MASS", quietly = TRUE)) {
  stop("aaf_unified.R requiere el paquete 'MASS' (mvrnorm). install.packages('MASS').")
}

# -----------------------------------------------------------------------------
# Helpers internos
# -----------------------------------------------------------------------------

# Integral trapezoidal sobre una grilla x (no requiere paso uniforme).
.aaf_trapz <- function(x, y) {
  n <- length(x)
  if (n < 2L) stop("x debe tener al menos dos puntos.")
  sum((y[-1L] + y[-n]) / 2 * diff(x))
}

# Extrae (shape, rate, scale) de un objeto gamma estilo fitdistr/fitdist.
.aaf_gamma_pars <- function(g) {
  if (is.null(g$estimate)) stop("El ajuste gamma debe tener $estimate con 'shape'.")
  est <- g$estimate
  shape <- est[["shape"]]
  rate  <- if ("rate"  %in% names(est)) est[["rate"]]  else NA_real_
  scale <- if ("scale" %in% names(est)) est[["scale"]] else NA_real_
  if (!is.finite(shape) || (!is.finite(rate) && !is.finite(scale))) {
    stop("El ajuste gamma debe exponer estimate['shape'] y estimate['rate' o 'scale'].")
  }
  list(shape = shape, rate = rate, scale = scale)
}

.aaf_gamma_density <- function(x, pars) {
  if (is.finite(pars$rate)) dgamma(x, shape = pars$shape, rate = pars$rate)
  else dgamma(x, shape = pars$shape, scale = pars$scale)
}

.aaf_gamma_draw <- function(n, pars) {
  if (is.finite(pars$rate)) rgamma(n, shape = pars$shape, rate = pars$rate)
  else rgamma(n, shape = pars$shape, scale = pars$scale)
}

# Resampleo por method-of-moments (igual que confint_paf_*): sortea n_pca consumos,
# recalcula shape/rate. Devuelve NULL si la gamma resampleada es degenerada.
.aaf_gamma_resample <- function(n_pca, pars) {
  s <- .aaf_gamma_draw(n_pca, pars)
  m <- mean(s); v <- stats::sd(s)
  if (!is.finite(m) || !is.finite(v) || v <= 0) return(NULL)
  list(shape = (m / v)^2, rate = m / (v^2), scale = NA_real_)
}

# Normaliza la entrada de covarianza a una matriz k x k simetrica.
#   NULL              -> matriz de ceros (betas fijos)
#   escalar (k==1)    -> 1x1
#   vector de length k -> diag(vector)  (interpretado como varianzas)
#   matriz k x k       -> tal cual
.aaf_as_cov <- function(cov_beta, k) {
  if (is.null(cov_beta)) return(matrix(0, k, k))
  if (is.matrix(cov_beta)) {
    if (!identical(dim(cov_beta), c(k, k))) {
      stop("cov_beta debe ser ", k, "x", k, " para un beta de largo ", k, ".")
    }
    return(cov_beta)
  }
  cov_beta <- as.numeric(cov_beta)
  if (length(cov_beta) == 1L && k == 1L) return(matrix(cov_beta, 1, 1))
  if (length(cov_beta) == k) return(diag(cov_beta, k, k))
  stop("cov_beta no compatible con beta de largo ", k, ".")
}

# Sorteo de betas: si toda la covarianza es 0 devuelve el centro (evita mvrnorm).
.aaf_draw_beta <- function(beta, cov_beta) {
  if (all(abs(cov_beta) <= 0)) return(beta)
  MASS::mvrnorm(1, mu = beta, Sigma = cov_beta)
}

# -----------------------------------------------------------------------------
# Riesgo medio y riesgo poblacional (compartidos por PAF y PIF)
# -----------------------------------------------------------------------------
# R(g) = INT (d / Z) * rr  con Z = INT d sobre el RANGO COMPLETO de x.
# Devuelve NA si la densidad no integra a un Z positivo.
.aaf_risk <- function(x, d, rr) {
  Z <- .aaf_trapz(x, d)
  if (!is.finite(Z) || Z <= 0) return(NA_real_)
  .aaf_trapz(x, (d / Z) * rr)
}

# Riesgo poblacional total: abstemios (RR=1) + ex-bebedores (RR_FD) + bebedores
# actuales (mezcla NHED/HED). cur = 1 - (p_abs + p_form).
.aaf_pop_R <- function(p_abs, p_form, rr_fd, p_hed, R_nhed, R_hed = NULL, use_hed = FALSE) {
  cur <- 1 - (p_abs + p_form)
  drinker <- if (use_hed) (1 - p_hed) * R_nhed + p_hed * R_hed else R_nhed
  p_abs + p_form * rr_fd + cur * drinker
}

# -----------------------------------------------------------------------------
# Per-variable effective sample size (Kish n / design factor)
# -----------------------------------------------------------------------------
# Normalise a neff/design spec to list(abs, form, hed). Accepts a scalar
# (broadcast to all three survey questions) or a list with any of abs/form/hed
# (missing entries fall back to the abs/first value). This is what lets the
# caller hand a DIFFERENT Kish n and design effect to each question
# (drinking status -> abs/form, binge -> hed).
.aaf_neff_list <- function(spec) {
  if (is.list(spec)) {
    base <- if (!is.null(spec$abs)) spec$abs else spec[[1L]]
    list(abs  = if (!is.null(spec$abs))  spec$abs  else base,
         form = if (!is.null(spec$form)) spec$form else base,
         hed  = if (!is.null(spec$hed))  spec$hed  else base)
  } else {
    list(abs = spec, form = spec, hed = spec)
  }
}

# Effective n per variable = neff / design_factor, each scalar or list(abs,form,hed).
.aaf_resolve_neff_eff <- function(neff_prev, design_factor) {
  ne <- .aaf_neff_list(neff_prev)
  df <- .aaf_neff_list(design_factor)
  out <- list(abs = ne$abs / df$abs, form = ne$form / df$form, hed = ne$hed / df$hed)
  for (nm in names(out)) {
    if (!is.finite(out[[nm]]) || out[[nm]] <= 0) {
      stop("Effective neff for '", nm, "' must be finite and > 0.")
    }
  }
  out
}

# -----------------------------------------------------------------------------
# Prevalence draw (generalized Dirichlet by default; binomial legacy)
# -----------------------------------------------------------------------------
# Returns list(p_abs, p_form, p_hed); NULL if the composition degenerates.
# neff_eff is list(abs, form, hed) of per-variable EFFECTIVE sample sizes
# (already deflated by the design factor); a scalar is broadcast to all three.
#  - dirichlet, EQUAL abs/form design -> symmetric Dirichlet, alpha = p*neff+0.5
#    (the validated default; bit-identical to the previous single-neff version).
#  - dirichlet, DIFFERENT abs/form design -> mean-preserving generalized Dirichlet
#    via stick-breaking, so abstainer and former-drinker proportions keep their
#    means while carrying independent design effects; cur = (1-V1)(1-V2) > 0.
#  - binomial : independent binomial normals per variable (legacy mode).
# p_hed is always a Beta with neff_eff$hed, conditional on being a current drinker.
.aaf_draw_prev <- function(p_abs, p_form, p_hed, use_hed, neff_eff, method) {
  ne <- .aaf_neff_list(neff_eff)
  if (identical(method, "binomial")) {
    pa <- max(rnorm(1, p_abs,  sqrt(max(p_abs  * (1 - p_abs)  / ne$abs,  0))), 0.001)
    pf <- max(rnorm(1, p_form, sqrt(max(p_form * (1 - p_form) / ne$form, 0))), 0.001)
    ph <- if (use_hed) {
      min(max(rnorm(1, p_hed, sqrt(max(p_hed * (1 - p_hed) / ne$hed, 0))), 0.001), 0.999)
    } else 0
    return(list(p_abs = pa, p_form = pf, p_hed = ph))
  }
  p_curr <- max(1 - (p_abs + p_form), 0)
  if (isTRUE(all.equal(ne$abs, ne$form))) {
    alpha <- c(p_abs, p_form, p_curr) * ne$abs + 0.5
    g <- rgamma(3L, shape = alpha, rate = 1)
    s <- sum(g)
    if (!is.finite(s) || s <= 0) return(NULL)
    d <- c(g[1L] / s, g[2L] / s)
  } else {
    v1 <- rbeta(1L, p_abs * ne$abs + 0.5, (1 - p_abs) * ne$abs + 0.5)
    mu <- if (p_abs < 1) min(max(p_form / (1 - p_abs), 0), 1) else 0
    v2 <- rbeta(1L, mu * ne$form + 0.5, (1 - mu) * ne$form + 0.5)
    d <- c(v1, v2 * (1 - v1))
  }
  ph <- if (use_hed) rbeta(1L, p_hed * ne$hed + 0.5, (1 - p_hed) * ne$hed + 0.5) else 0
  list(p_abs = d[1L], p_form = d[2L], p_hed = ph)
}

# -----------------------------------------------------------------------------
# Sorteo del RR (NHED y HED) segun el modo (cap / explicit). Devuelve tambien las
# betas usadas, para poder reevaluar el RR en x*shift en el escenario "volume".
# -----------------------------------------------------------------------------
.aaf_draw_rr <- function(x, use_hed, hed_mode, rr_fun, beta, cov_beta,
                         rr_fun_hed, beta_hed_v, cov_hed_m, share_beta1) {
  if (use_hed && identical(hed_mode, "explicit")) {
    bh <- if (!is.null(cov_hed_m)) .aaf_draw_beta(beta_hed_v, cov_hed_m) else beta_hed_v
    beta_n <- beta
    if (isTRUE(share_beta1)) beta_n[1L] <- bh[1L]
    rr_n <- rr_fun(x, beta_n)
    if (length(rr_n) == 1L) rr_n <- rep(rr_n, length(x))
    rr_h <- rr_fun_hed(x, bh)
    if (length(rr_h) == 1L) rr_h <- rep(rr_h, length(x))
    return(list(rr_n = rr_n, rr_h = rr_h, beta_n = beta_n, beta_h = bh, mode = "explicit"))
  }
  beta_i <- .aaf_draw_beta(beta, cov_beta)
  rr_n <- rr_fun(x, beta_i)
  if (length(rr_n) == 1L) rr_n <- rep(rr_n, length(x))
  rr_h <- if (use_hed) pmax(rr_n, 1) else NULL
  list(rr_n = rr_n, rr_h = rr_h, beta_n = beta_i, beta_h = NULL, mode = "cap")
}

# --- paralelizacion -----------------------------------------------------------
# Resolve worker count. Project rule: use at most the even half of
# (detected logical cores - 1). Example: detectCores()=32 -> (32-1)/2 ~= 16.
# Explicit n_cores is capped too, so notebooks asking for detectCores()-1 do not
# create too many SOCK workers on Windows.
.aaf_even_half_workers <- function(detected = parallel::detectCores(logical = TRUE)) {
  if (is.null(detected) || length(detected) != 1L || is.na(detected) || !is.finite(detected)) {
    return(1L)
  }
  reserve_one <- max(1L, as.integer(detected) - 1L)
  target <- reserve_one / 2
  workers <- as.integer(round(target))
  if (workers > 1L && workers %% 2L == 1L) {
    lower <- max(1L, workers - 1L)
    upper <- min(reserve_one, workers + 1L)
    workers <- if (abs(target - lower) <= abs(upper - target)) lower else upper
  }
  max(1L, min(workers, reserve_one))
}

.aaf_resolve_cores <- function(n_cores, n_tasks, use_parallel = TRUE) {
  if (!isTRUE(use_parallel)) return(1L)
  detected <- parallel::detectCores(logical = TRUE)
  project_cap <- .aaf_even_half_workers(detected)
  if (is.null(n_cores)) {
    n_cores <- project_cap
  } else {
    n_cores <- min(as.integer(n_cores), project_cap)
  }
  max(1L, min(as.integer(n_cores), n_tasks))
}

.aaf_note_once <- local({
  seen <- new.env(parent = emptyenv())
  function(key, text, as_warning = FALSE) {
    if (exists(key, envir = seen, inherits = FALSE)) return(invisible(FALSE))
    assign(key, TRUE, envir = seen)
    if (isTRUE(as_warning)) warning(text, call. = FALSE, immediate. = TRUE) else message(text)
    invisible(TRUE)
  }
})

# Streams RNG independientes (L'Ecuyer-CMRG): un stream por simulacion. Cada sim
# usa SU stream -> el resultado es identico con 1 o N nucleos (serial == paralelo),
# y solo depende de (seed, n_sim, n_pca). Restaura el RNG global al salir.
.aaf_make_streams <- function(seed, n) {
  if (is.null(seed)) stop("seed no puede ser NULL para Monte Carlo reproducible.")
  old_kind <- RNGkind()
  old_exists <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  old_seed <- if (old_exists) get(".Random.seed", envir = .GlobalEnv) else NULL
  on.exit({
    do.call(RNGkind, as.list(old_kind))
    if (old_exists) assign(".Random.seed", old_seed, envir = .GlobalEnv)
    else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
      rm(".Random.seed", envir = .GlobalEnv)
    }
  }, add = TRUE)
  RNGkind("L'Ecuyer-CMRG")
  set.seed(seed)
  streams <- vector("list", n)
  s <- .Random.seed
  for (i in seq_len(n)) { streams[[i]] <- s; s <- parallel::nextRNGStream(s) }
  streams
}

# Helpers globales que deben exportarse a los workers SOCK (Windows): viven en el
# env donde se cargo el archivo y NO se serializan con la closure de la simulacion.
.aaf_worker_exports <- function() {
  c(".aaf_trapz", ".aaf_gamma_draw", ".aaf_gamma_resample", ".aaf_draw_beta",
    ".aaf_risk", ".aaf_pop_R", ".aaf_draw_prev", ".aaf_neff_list", ".aaf_draw_rr",
    ".aaf_core", ".pif_core")
}

# Driver Monte Carlo comun a aaf_confint y pif_confint. `sim_fun(i)` calcula UN
# escalar (PAF o PIF) asumiendo que el RNG ya quedo posicionado en su stream.
# Devuelve el vector de simulaciones finitas. serial == paralelo (bit a bit).
.aaf_mc_run <- function(n_sim, seed, sim_fun, n_cores, use_parallel, chunk_size) {
  streams <- .aaf_make_streams(seed, n_sim)
  run_i <- function(i) {
    assign(".Random.seed", streams[[i]], envir = .GlobalEnv)
    sim_fun(i)
  }
  requested_cores <- n_cores
  auto_cores <- is.null(requested_cores)
  detected_cores <- if (isTRUE(use_parallel)) {
    parallel::detectCores(logical = TRUE)
  } else {
    NA_integer_
  }
  project_cap <- if (isTRUE(use_parallel)) .aaf_even_half_workers(detected_cores) else 1L
  n_cores <- .aaf_resolve_cores(n_cores, n_sim, use_parallel)
  if (!isTRUE(use_parallel)) {
    .aaf_note_once("parallel_disabled",
                   "aaf MC: use_parallel=FALSE; running Monte Carlo sequentially.")
  } else if (isTRUE(auto_cores) && n_cores > 1L) {
    cap_note <- if (is.finite(detected_cores)) {
      sprintf(" (detected %d logical cores; rule: even half of cores-1)", detected_cores)
    } else {
      ""
    }
    .aaf_note_once(paste0("parallel_auto_", n_cores),
                   sprintf("aaf MC: auto-selected %d parallel workers%s.", n_cores, cap_note))
  } else if (!isTRUE(auto_cores) && is.finite(as.integer(requested_cores)) &&
             as.integer(requested_cores) > n_cores) {
    .aaf_note_once(paste0("parallel_reduced_", as.integer(requested_cores), "_", n_cores),
                   sprintf("aaf MC: requested %d parallel workers but using %d (detected %s logical cores; project cap=%d).",
                           as.integer(requested_cores), n_cores,
                           if (is.finite(detected_cores)) as.character(detected_cores) else "unknown",
                           project_cap),
                   as_warning = TRUE)
  } else if (n_cores > 1L) {
    .aaf_note_once(paste0("parallel_using_", n_cores),
                   sprintf("aaf MC: using %d parallel workers.", n_cores))
  }
  if (is.null(chunk_size)) chunk_size <- max(1L, ceiling(n_sim / (n_cores * 4L)))
  chunk_size <- max(1L, as.integer(chunk_size))
  chunks <- split(seq_len(n_sim), ceiling(seq_len(n_sim) / chunk_size))
  calc_chunk <- function(idx) vapply(idx, run_i, numeric(1))

  sims <- if (n_cores == 1L || length(chunks) == 1L) {
    unlist(lapply(chunks, calc_chunk), use.names = FALSE)
  } else if (.Platform$OS.type == "windows") {
    cl <- tryCatch(parallel::makeCluster(n_cores), error = function(e) e)
    if (inherits(cl, "error")) {
      .aaf_note_once(paste0("parallel_cluster_create_failed_", n_cores),
                     sprintf("aaf MC: requested %d parallel workers but cluster creation failed (%s); falling back to sequential Monte Carlo.",
                             n_cores, conditionMessage(cl)),
                     as_warning = TRUE)
      seq_sims <- unlist(lapply(chunks, calc_chunk), use.names = FALSE)
      return(seq_sims[is.finite(seq_sims)])
    }
    on.exit(try(parallel::stopCluster(cl), silent = TRUE), add = TRUE)
    parallel::clusterExport(cl, .aaf_worker_exports(), envir = environment(.aaf_core))
    tryCatch(
      unlist(parallel::parLapply(cl, chunks, calc_chunk), use.names = FALSE),
      error = function(e) {
        .aaf_note_once(paste0("parallel_workers_failed_", n_cores),
                       paste0("aaf MC: parallel workers failed (", conditionMessage(e),
                              "); falling back to sequential Monte Carlo."),
                       as_warning = TRUE)
        unlist(lapply(chunks, calc_chunk), use.names = FALSE)
      }
    )
  } else {
    unlist(parallel::mclapply(chunks, calc_chunk, mc.cores = n_cores), use.names = FALSE)
  }
  sims[is.finite(sims)]
}

# -----------------------------------------------------------------------------
# Nucleo de la formula AAF / PAF (deterministico, vectores ya evaluados)
# -----------------------------------------------------------------------------
# x        : grilla de consumo
# d_nhed   : densidad (no necesariamente normalizada) de bebedores NO-HED
# rr_nhed  : RR evaluado en x para bebedores NO-HED
# p_abs    : prevalencia abstemios de vida
# p_form   : prevalencia ex-bebedores (former)
# rr_fd    : RR de ex-bebedores
# p_hed    : fraccion de bebedores actuales que son HED (0 = sin HED)
# d_hed    : densidad de bebedores HED (requerida si p_hed > 0)
# rr_hed   : RR evaluado en x para bebedores HED (requerido si p_hed > 0)
# cap_upper: acota AAF en 1 (no clipa el piso -> deja efectos protectores)
#
# Estructura (Levin/InterMAHP):
#   cur = 1 - (p_abs + p_form)                          # bebedores actuales
#   I_g = INT [ dens_normalizada(x) * (RR(x) - 1) ] dx  # exceso medio del grupo g
#   num = (RR_FD - 1)*p_form + cur*[(1-p_hed)*I_nhed + p_hed*I_hed]
#   AAF = num / (num + 1)
# Sin HED -> num = (RR_FD-1)*p_form + cur*I_nhed  (identico a confint_paf_vcov_parallel).
.aaf_core <- function(x, d_nhed, rr_nhed, p_abs, p_form, rr_fd,
                      p_hed = 0, d_hed = NULL, rr_hed = NULL,
                      cap_upper = TRUE) {
  cur <- 1 - (p_abs + p_form)
  nc_n <- .aaf_trapz(x, d_nhed)
  if (!is.finite(nc_n) || nc_n <= 0) return(NA_real_)
  I_nhed <- .aaf_trapz(x, (d_nhed / nc_n) * (rr_nhed - 1))

  use_hed <- is.finite(p_hed) && p_hed > 0 && !is.null(d_hed) && !is.null(rr_hed)
  if (use_hed) {
    nc_h <- .aaf_trapz(x, d_hed)
    if (!is.finite(nc_h) || nc_h <= 0) return(NA_real_)
    I_hed <- .aaf_trapz(x, (d_hed / nc_h) * (rr_hed - 1))
    current_excess <- cur * ((1 - p_hed) * I_nhed + p_hed * I_hed)
  } else {
    current_excess <- cur * I_nhed
  }

  num <- (rr_fd - 1) * p_form + current_excess
  den <- num + 1
  if (!is.finite(num) || !is.finite(den) || den == 0) return(NA_real_)
  aaf <- num / den
  if (isTRUE(cap_upper)) aaf <- min(aaf, 1)
  aaf
}

# -----------------------------------------------------------------------------
# [2026-07-14] HED-exit knobs: validation + per-cell resolution
# -----------------------------------------------------------------------------
# Normalise (hed_exit_mix, hed_exit_shift) to list(lambda, rho) with the legacy
# defaults. NULL is the documented "leave it as it was" value:
#   lambda = 0 -> the exiting binge mass keeps its own d_hed density;
#   rho    = 1 -> and its full volume.
.pif_hed_exit_pars <- function(hed_exit_mix, hed_exit_shift, .fn = "pif") {
  # NULL is the documented "leave it as it was" value -> legacy constants.
  lambda <- if (is.null(hed_exit_mix))   0 else as.numeric(hed_exit_mix)
  rho    <- if (is.null(hed_exit_shift)) 1 else as.numeric(hed_exit_shift)
  # Both knobs are CELL-level scalars: a vector here means the caller tried to pass a
  # per-subgroup spec straight through. Resolve it with resolve_hed_exit() first.
  if (length(lambda) != 1L || !is.finite(lambda) || lambda < 0 || lambda > 1) {
    stop(.fn, ": hed_exit_mix (lambda) must be a single finite scalar in [0, 1] -- it is ",
         "the share of the exiting binge mass that migrates to the NHED consumption ",
         "distribution. Got: ", paste(format(lambda), collapse = ", "),
         ". For per-subgroup values, resolve the spec per cell with resolve_hed_exit().")
  }
  if (length(rho) != 1L || !is.finite(rho) || rho <= 0 || rho > 1) {
    stop(.fn, ": hed_exit_shift (rho) must be a single finite scalar in (0, 1] -- it is ",
         "the fraction of volume RETAINED by whoever quits binge; an ex-HED drinker who ",
         "INCREASES consumption is not a supported counterfactual. Got: ",
         paste(format(rho), collapse = ", "),
         ". For per-subgroup values, resolve the spec per cell with resolve_hed_exit().")
  }
  list(lambda = lambda, rho = rho)
}

# Resolve a per-subgroup HED-exit spec down to the scalar for ONE cell.
# `spec` accepts the same shapes as the neff / design_factor knobs:
#   * scalar                                  -> same value everywhere
#   * function(year, group, sex)              -> arbitrary (incl. monotone in age or
#                                                year, e.g. transition models)
#   * list keyed [["<year>"]][["edad_tramo_<g>"]]
#   * list keyed by group index
#   * NULL                                    -> NULL (engine default = legacy)
# Example (women 15-29 vs men 30-44):
#   lam <- function(year, group, sex) if (sex == "female" && group == 1) 0.8 else 0.4
#   pif_confint(..., hed_exit_mix = resolve_hed_exit(lam, y, g, record$sex))
resolve_hed_exit <- function(spec, year, group, sex) {
  # NULL propagates untouched: the engine then falls back to the legacy constants.
  if (is.null(spec)) return(NULL)

  # WHY THIS DOES NOT REUSE .aaf_resolve_cell() FOR LISTS.
  # "list keyed by year" and "list keyed by group index" are AMBIGUOUS shapes: a
  # year-keyed list is ALSO a valid positional lookup whenever length(spec) >= group.
  # .aaf_resolve_cell() tries spec[["<year>"]] and, when that key is MISSING, falls
  # through to spec[[group]] -- i.e. it indexes the YEAR list by the AGE-BAND index and
  # returns a perfectly finite scalar belonging to a DIFFERENT cell. A downstream
  # is.finite() guard cannot catch that, and the pif_confint() audit echo would then
  # faithfully record the wrong lambda as if the caller had asked for it. A HED-exit
  # spec that covers only some years (the natural thing for a policy assumption: e.g.
  # only the survey waves) would silently run a DIFFERENT counterfactual on every
  # uncovered year. So every list shape is resolved HERE, explicitly, with no
  # positional fall-back: a spec that does not cover a cell is an ERROR, never a guess.
  # (The same fall-through exists for neff / design_factor; it is NOT touched here --
  # that is a separate module and a separate decision.)
  fail <- function(...) {
    stop("resolve_hed_exit: ", ..., " [cell: year=", year, ", group=", group,
         ", sex=", sex, "]. A HED-exit spec must cover EVERY cell of the run: an ",
         "uncovered cell would otherwise silently run a different counterfactual than ",
         "the one the table claims.")
  }
  is_scalar_num <- function(v) is.numeric(v) && length(v) == 1L && is.finite(v)

  v <- NULL

  if (is.function(spec)) {
    # (1) function(year, group, sex) -- covers everything: per-sex, per-band, monotone
    #     in age or in year, or driven by the alcohol-transition model.
    v <- spec(year, group, sex)

  } else if (is.list(spec)) {
    nm <- names(spec)
    if (is.null(nm) || !length(nm) || any(!nzchar(nm))) {
      fail("a list spec must be NAMED (either by year, e.g. `list(\"2022\" = ...)`, or ",
           "by age band, e.g. `list(edad_tramo_1 = ..., edad_tramo_2 = ...)`)")
    }
    if (all(grepl("^[0-9]{4}$", nm))) {
      # (2) year-keyed. Demand an EXACT hit on the year -- no positional fall-back.
      yk <- as.character(year)
      if (!yk %in% nm) {
        fail("the year-keyed spec has no entry for year ", year,
             " (it covers: ", paste(nm, collapse = ", "), ")")
      }
      ycell <- spec[[yk]]
      if (is.list(ycell)) {
        # year -> edad_tramo_<g>. Demand an EXACT hit on the band too.
        key <- paste0("edad_tramo_", group)
        if (is.null(ycell[[key]])) {
          fail("the spec for year ", year, " has no entry '", key,
               "' (it covers: ", paste(names(ycell), collapse = ", "), ")")
        }
        v <- ycell[[key]]
      } else {
        v <- ycell   # a single value for the whole year (same in every age band)
      }
    } else if (all(grepl("^edad_tramo_", nm))) {
      # (3) band-keyed, constant across years.
      key <- paste0("edad_tramo_", group)
      if (is.null(spec[[key]])) {
        fail("the band-keyed spec has no entry '", key,
             "' (it covers: ", paste(nm, collapse = ", "), ")")
      }
      v <- spec[[key]]
    } else {
      fail("unrecognised list spec. Name it by YEAR (\"2022\", \"2023\", ...) or by AGE ",
           "BAND (edad_tramo_1, ...), or pass a function(year, group, sex)")
    }

  } else if (is.numeric(spec) && length(spec) > 1L) {
    # (4) plain numeric vector indexed by age band -- unambiguous (a vector, not a list).
    if (!is.numeric(group) || group < 1L || group > length(spec)) {
      fail("the per-band vector spec has length ", length(spec),
           ", which does not cover band ", group)
    }
    v <- spec[[as.integer(group)]]

  } else {
    # (5) bare scalar -- broadcasts to every cell.
    v <- spec
  }

  if (is.list(v) && length(v) == 1L) v <- v[[1L]]   # unwrap a length-1 list cell
  v <- suppressWarnings(as.numeric(v))
  if (!is_scalar_num(v)) {
    fail("the spec did not resolve to a single finite number (got: ",
         paste(format(v), collapse = ", "), ")")
  }
  v
}

# -----------------------------------------------------------------------------
# Nucleo de la formula PIF (deterministico, vectores ya evaluados)
# -----------------------------------------------------------------------------
# Comparte el R_obs poblacional con el PAF (mismo denominador).
#   scenario="hed"   : reduce binge; la masa (1-shift)*p_hed sale del binge y su
#                      riesgo contrafactual R_exit lo fijan los knobs hed_exit_*
#                      (ver abajo). Requiere use_hed.
#   scenario="volume": reduce consumo; rr_nhed_cf / rr_hed_cf son los RR evaluados
#                      en x*shift. p_hed intacto (nadie sale del binge -> los knobs
#                      hed_exit_* no aplican).
#   scenario="both"  : COMBINED counterfactual. Everyone reduces volume (x -> x*shift,
#                      so rr_*_cf are evaluated at x*shift) AND a fraction
#                      (1-shift_hed)*p_hed leaves binge, its counterfactual risk again
#                      given by the hed_exit_* knobs on the VOLUME-REDUCED curves. It
#                      is an exact superset: shift_hed=1 -> "volume"; volume shift=1
#                      (rr_*_cf==rr_*) -> "hed".
#                      `shift` is the volume retained fraction, `shift_hed` the HED one.
#
# [2026-07-14] HED-exit reassignment (see header). The exiting mass no longer has a
# hard-coded fate; its risk is the convex combination
#     R_exit = (1 - hed_exit_mix) * R(d_hed, rr_nhed_exit) + hed_exit_mix * R_nhed
# where
#   hed_exit_mix  = lambda in [0,1], fraction migrating to the NHED consumption
#                   DISTRIBUTION (drinks like an average non-HED drinker). 0 = legacy.
#   rr_nhed_exit  = RR_NHED already evaluated at the volume the ex-binge drinker
#                   retains, i.e. at x*rho ("hed") or x*shift*rho ("both"), rho being
#                   hed_exit_shift. Pass NULL when rho == 1 and the legacy vector
#                   (rr_nhed / rr_nhed_cf) is reused verbatim -> bit-for-bit identical
#                   results to the pre-2026-07-14 engine. Callers (pif_point /
#                   pif_confint) evaluate it; .pif_core keeps taking vectors only.
# rr_hed / rr_hed_cf pueden ser NULL si use_hed = FALSE.
.pif_core <- function(x, d_nhed, rr_nhed, d_hed, rr_hed,
                      p_abs, p_form, rr_fd, p_hed,
                      scenario, shift, shift_hed = NULL,
                      rr_nhed_cf = NULL, rr_hed_cf = NULL,
                      hed_exit_mix = 0, rr_nhed_exit = NULL,
                      use_hed = FALSE, cap_upper = TRUE) {
  cur <- 1 - (p_abs + p_form)
  R_nhed <- .aaf_risk(x, d_nhed, rr_nhed)
  if (!is.finite(R_nhed)) return(NA_real_)
  R_hed <- NULL
  if (use_hed) {
    R_hed <- .aaf_risk(x, d_hed, rr_hed)
    if (!is.finite(R_hed)) return(NA_real_)
  }
  R_obs <- .aaf_pop_R(p_abs, p_form, rr_fd, p_hed, R_nhed, R_hed, use_hed)
  if (!is.finite(R_obs) || R_obs <= 0) return(NA_real_)

  # [2026-07-14] lambda: fraction of the exiting binge mass that migrates to the NHED
  # consumption distribution. 0 (default) = it keeps its own d_hed density = legacy.
  lambda <- if (is.null(hed_exit_mix)) 0 else as.numeric(hed_exit_mix)
  if (length(lambda) != 1L || !is.finite(lambda) || lambda < 0 || lambda > 1) {
    # Re-checked here (not only in the public wrappers) because .pif_core is also
    # called directly by tests and by the notebook runners.
    stop(".pif_core: hed_exit_mix (lambda) must be a single finite scalar in [0, 1].")
  }

  if (identical(scenario, "hed")) {
    if (!use_hed) return(0)   # sin HED no hay binge que reducir -> PIF = 0
    # Ex-HED keeps the SHAPE of d_hed but reads RR_NHED at the volume it retains
    # (rr_nhed_exit = RR_NHED(x*rho); NULL -> rho == 1 -> the legacy RR_NHED(x)).
    rr_exit <- if (is.null(rr_nhed_exit)) rr_nhed else rr_nhed_exit
    R_hed_nhedrr <- .aaf_risk(x, d_hed, rr_exit)
    if (!is.finite(R_hed_nhedrr)) return(NA_real_)
    # Convex mixture of densities -> convex mixture of risks (.aaf_risk normalises),
    # so the migrating share simply lands on R_nhed. No extra integral.
    R_exit <- (1 - lambda) * R_hed_nhedrr + lambda * R_nhed
    drinker_cf <- (1 - p_hed) * R_nhed +
                  shift * p_hed * R_hed +
                  (1 - shift) * p_hed * R_exit
  } else if (identical(scenario, "volume")) {
    R_nhed_cf <- .aaf_risk(x, d_nhed, rr_nhed_cf)
    if (!is.finite(R_nhed_cf)) return(NA_real_)
    if (use_hed) {
      R_hed_cf <- .aaf_risk(x, d_hed, rr_hed_cf)
      if (!is.finite(R_hed_cf)) return(NA_real_)
      drinker_cf <- (1 - p_hed) * R_nhed_cf + p_hed * R_hed_cf
    } else {
      drinker_cf <- R_nhed_cf
    }
  } else if (identical(scenario, "both")) {
    # Combined: volume reduction for all drinkers (rr_*_cf at x*shift) plus a HED
    # reduction that moves (1-shift_hed)*p_hed of the binge mass out of binge; its
    # fate is again set by the hed_exit_* knobs, now on the volume-reduced curves.
    if (is.null(shift_hed)) stop(".pif_core: scenario='both' requiere shift_hed.")
    R_nhed_cf <- .aaf_risk(x, d_nhed, rr_nhed_cf)
    if (!is.finite(R_nhed_cf)) return(NA_real_)
    if (use_hed) {
      R_hed_cf <- .aaf_risk(x, d_hed, rr_hed_cf)
      # [2026-07-14] rr_nhed_exit = RR_NHED(x*shift*rho): the policy volume cut and the
      # ex-binge drinker's own volume cut compound. NULL -> rho == 1 -> legacy rr_nhed_cf.
      rr_exit_cf <- if (is.null(rr_nhed_exit)) rr_nhed_cf else rr_nhed_exit
      R_hed_nhedrr_cf <- .aaf_risk(x, d_hed, rr_exit_cf)  # ex-binge at reduced volume
      if (!is.finite(R_hed_cf) || !is.finite(R_hed_nhedrr_cf)) return(NA_real_)
      # Migrating share lands on the volume-reduced NHED risk (R_nhed_cf), not on R_nhed:
      # under "both" even an average non-HED drinker has already cut volume by `shift`.
      R_exit_cf <- (1 - lambda) * R_hed_nhedrr_cf + lambda * R_nhed_cf
      drinker_cf <- (1 - p_hed) * R_nhed_cf +
                    shift_hed * p_hed * R_hed_cf +
                    (1 - shift_hed) * p_hed * R_exit_cf
    } else {
      drinker_cf <- R_nhed_cf   # no HED mass to reassign -> equals volume path
    }
  } else {
    stop(".pif_core: unknown scenario '", scenario, "'.")
  }
  R_cf <- p_abs + p_form * rr_fd + cur * drinker_cf
  if (!is.finite(R_cf)) return(NA_real_)
  pif <- 1 - R_cf / R_obs
  if (isTRUE(cap_upper)) pif <- min(pif, 1)   # (-inf, 1], igual que el PAF
  pif
}

# Resuelve el RR HED a partir de la configuracion.
#   rr_hed == "cap" (o NULL en modo cap) -> pmax(rr_nhed, 1)  (cardio J-curve)
#   function                              -> rr_hed_fun(x, beta_hed)
#   vector numerico                       -> tal cual
.aaf_resolve_rr_hed <- function(rr_hed, rr_nhed, x, beta_hed = NULL) {
  if (is.null(rr_hed) || (is.character(rr_hed) && identical(rr_hed, "cap"))) {
    return(pmax(rr_nhed, 1))
  }
  if (is.function(rr_hed)) {
    v <- rr_hed(x, beta_hed)
    if (length(v) == 1L) v <- rep(v, length(x))
    return(v)
  }
  rr_hed
}

# -----------------------------------------------------------------------------
# aaf_point: PAF puntual deterministica
# -----------------------------------------------------------------------------
aaf_point <- function(x,
                      rr_nhed,                 # vector numerico O function(x, beta)
                      beta = NULL,
                      p_abs, p_form,
                      rr_fd = 1,
                      gamma = NULL, y_nhed = NULL,
                      p_hed = 0,
                      rr_hed = NULL,           # vector, function(x,beta), o "cap"
                      beta_hed = NULL,
                      gamma_hed = NULL, y_hed = NULL,
                      cap_upper = TRUE) {
  if (is.null(y_nhed)) {
    if (is.null(gamma)) stop("aaf_point: entregue gamma o y_nhed.")
    y_nhed <- .aaf_gamma_density(x, .aaf_gamma_pars(gamma))
  }
  rr_n <- if (is.function(rr_nhed)) rr_nhed(x, beta) else rr_nhed
  if (length(rr_n) == 1L) rr_n <- rep(rr_n, length(x))

  use_hed <- is.finite(p_hed) && p_hed > 0
  d_hed <- NULL; rr_h <- NULL
  if (use_hed) {
    if (is.null(y_hed)) {
      gh <- if (!is.null(gamma_hed)) gamma_hed else gamma
      if (is.null(gh)) stop("aaf_point: HED activo pero sin gamma_hed/y_hed.")
      y_hed <- .aaf_gamma_density(x, .aaf_gamma_pars(gh))
    }
    d_hed <- y_hed
    rr_h <- .aaf_resolve_rr_hed(rr_hed, rr_n, x, beta_hed = if (!is.null(beta_hed)) beta_hed else beta)
  }
  .aaf_core(x, y_nhed, rr_n, p_abs, p_form, rr_fd,
            p_hed = if (use_hed) p_hed else 0,
            d_hed = d_hed, rr_hed = rr_h, cap_upper = cap_upper)
}

# -----------------------------------------------------------------------------
# pif_point: PIF puntual deterministica
# -----------------------------------------------------------------------------
# Mismos insumos que aaf_point + scenario y shift. Para scenario="volume" se
# necesita rr_nhed/rr_hed como FUNCION (para reevaluar en x*shift); si se pasan
# como vector, el contrafactual de volumen no puede construirse.
pif_point <- function(x,
                      rr_nhed,                 # function(x,beta) (recomendado) o vector
                      beta = NULL,
                      p_abs, p_form,
                      rr_fd = 1,
                      gamma = NULL, y_nhed = NULL,
                      p_hed = 0,
                      rr_hed = NULL,           # function(x,beta), "cap", o vector
                      beta_hed = NULL,
                      gamma_hed = NULL, y_hed = NULL,
                      scenario = c("hed", "volume", "both"), shift = 0.9,
                      shift_hed = NULL,
                      # [2026-07-14] HED-exit reassignment; NULL = legacy (lambda=0, rho=1)
                      hed_exit_mix = NULL,     # lambda in [0,1]: share migrating to d_nhed
                      hed_exit_shift = NULL,   # rho in (0,1]: volume retained by the ex-HED
                      cap_upper = TRUE) {
  scenario <- match.arg(scenario)
  hx <- .pif_hed_exit_pars(hed_exit_mix, hed_exit_shift, "pif_point")
  # For a combined scenario, default the HED retained fraction to the volume one
  # unless the caller passes an explicit (possibly different) shift_hed.
  if (identical(scenario, "both") && is.null(shift_hed)) shift_hed <- shift
  if (is.null(y_nhed)) {
    if (is.null(gamma)) stop("pif_point: entregue gamma o y_nhed.")
    y_nhed <- .aaf_gamma_density(x, .aaf_gamma_pars(gamma))
  }
  rr_n <- if (is.function(rr_nhed)) rr_nhed(x, beta) else rr_nhed
  if (length(rr_n) == 1L) rr_n <- rep(rr_n, length(x))

  use_hed <- is.finite(p_hed) && p_hed > 0
  if (scenario == "hed" && !use_hed) {
    stop("pif_point: scenario='hed' requiere p_hed>0 (no hay binge que reducir).")
  }

  d_hed <- NULL; rr_h <- NULL
  if (use_hed) {
    if (is.null(y_hed)) {
      gh <- if (!is.null(gamma_hed)) gamma_hed else gamma
      if (is.null(gh)) stop("pif_point: HED activo pero sin gamma_hed/y_hed.")
      y_hed <- .aaf_gamma_density(x, .aaf_gamma_pars(gh))
    }
    d_hed <- y_hed
    rr_h <- .aaf_resolve_rr_hed(rr_hed, rr_n, x, beta_hed = if (!is.null(beta_hed)) beta_hed else beta)
  }

  rr_n_cf <- NULL; rr_h_cf <- NULL
  if (scenario %in% c("volume", "both")) {
    if (!is.function(rr_nhed)) {
      stop("pif_point: scenario='", scenario, "' requiere rr_nhed como funcion(x,beta).")
    }
    rr_n_cf <- rr_nhed(x * shift, beta)
    if (length(rr_n_cf) == 1L) rr_n_cf <- rep(rr_n_cf, length(x))
    if (use_hed) {
      rr_h_cf <- .aaf_resolve_rr_hed(
        rr_hed, rr_n_cf, x * shift,
        beta_hed = if (!is.null(beta_hed)) beta_hed else beta
      )
    }
  }

  # [2026-07-14] RR_NHED read at the volume the exiting binge mass RETAINS: x*rho for
  # "hed", x*shift*rho for "both" (policy cut and binge-exit cut compound). Only the
  # scenarios with exiting mass need it, and only when rho < 1 and lambda < 1 (with
  # lambda == 1 the whole mass migrates to d_nhed and this term gets weight zero).
  # rho == 1 -> stays NULL -> .pif_core reuses the legacy vector -> identical results.
  rr_n_exit <- NULL
  if (use_hed && scenario %in% c("hed", "both") && hx$rho != 1 && hx$lambda < 1) {
    if (!is.function(rr_nhed)) {
      stop("pif_point: hed_exit_shift < 1 requires rr_nhed as a function(x, beta): the ",
           "NHED risk curve has to be RE-EVALUATED at the volume the ex-binge drinker ",
           "retains (x * rho), which a pre-evaluated RR vector cannot provide.")
    }
    x_exit <- if (identical(scenario, "both")) x * shift * hx$rho else x * hx$rho
    rr_n_exit <- rr_nhed(x_exit, beta)
    if (length(rr_n_exit) == 1L) rr_n_exit <- rep(rr_n_exit, length(x))
  }

  .pif_core(x, y_nhed, rr_n, d_hed, rr_h, p_abs, p_form, rr_fd,
            if (use_hed) p_hed else 0,
            scenario = scenario, shift = shift, shift_hed = shift_hed,
            rr_nhed_cf = rr_n_cf, rr_hed_cf = rr_h_cf,
            hed_exit_mix = hx$lambda, rr_nhed_exit = rr_n_exit,
            use_hed = use_hed, cap_upper = cap_upper)
}

# -----------------------------------------------------------------------------
# aaf_confint: PAF puntual + IC 95% por Monte Carlo
# -----------------------------------------------------------------------------
# Fuentes de incertidumbre, todas OPCIONALES:
#   1. Distribucion de consumo  -> resampleo gamma por momentos (n_pca)
#   2. Betas del RR             -> mvrnorm(beta, cov_beta) ; cov_beta=0 -> fijo
#   3. Prevalencias             -> Dirichlet(abs,form,curr) + Beta(p_hed) (default),
#                                  o normal binomial (prev_method="binomial")
#   4. RR_FD                    -> exp(N(ln_rr_fd, var_ln_rr_fd)) si fd_uncertainty
#
# HED (binge): hed_mode
#   "cap"      -> RR_HED = pmax(RR_NHED, 1). Mismo sorteo de betas para ambos.
#                 (cardioprotectoras IHD/IS: se aplana el hoyo protector.)
#   "explicit" -> RR_HED tiene su propia funcion (rr_fun_hed) y betas
#                 (beta_hed, cov_beta_hed). Si share_beta1=TRUE, el elemento 1 del
#                 sorteo binge se reusa como beta1 del NHED (caso injuries: beta1
#                 compartido, beta2 = coef de binge).
aaf_confint <- function(
    gamma,                      # ajuste gamma NHED (fitdistr/fitdist)
    rr_fun,                     # function(x, beta) RR NHED
    beta,                       # vector numerico (largo >= 1)
    cov_beta = NULL,            # matriz k x k, escalar, o NULL (= betas fijos)
    p_abs, p_form,
    rr_fd = NULL,               # RR_FD fijo; alternativa: ln_rr_fd
    ln_rr_fd = NULL,            # log(RR_FD); usado si rr_fd es NULL
    var_ln_rr_fd = 0,           # varianza de ln(RR_FD); >0 + fd_uncertainty -> lognormal
    x = seq(0.1, 150, length.out = 1500),
    # --- bloque HED (opcional) ---
    p_hed = NULL,               # non-NULL y >0 -> HED activo
    gamma_hed = NULL,           # ajuste gamma HED; NULL -> reusa `gamma`
    rr_fun_hed = NULL,          # function(x,beta); NULL en modo "cap" -> pmax(rr_nhed,1)
    beta_hed = NULL,            # betas binge (modo explicit)
    cov_beta_hed = NULL,        # covarianza binge (modo explicit)
    hed_mode = c("cap", "explicit"),
    share_beta1 = TRUE,         # explicit: NHED y HED comparten el elemento 1 del sorteo
    # --- incertidumbre de prevalencias ---
    prev_method = c("dirichlet", "binomial"),
    # Kish n and cluster design factor PER SURVEY QUESTION. Each is a scalar (one
    # value for all questions) OR a list(abs=, form=, hed=) to give the drinking-
    # status and binge questions their own effective sample size.
    neff_prev = 1000,
    design_factor = 1,
    # Consumption (gamma) design: if given, the gamma resample uses this effective
    # n instead of n_pca, tying volume uncertainty to the consumption question.
    neff_consumption = NULL,
    design_factor_consumption = 1,
    # --- controles ---
    n_sim = 10000, n_pca = 1000, seed = 145,
    fd_uncertainty = TRUE,      # sortea RR_FD ~ lognormal cuando var_ln_rr_fd > 0
    cap_upper = TRUE,
    round_digits = NULL,        # NULL = sin redondeo (cuantiles crudos)
    return_sims = FALSE,
    # --- paralelizacion ---
    n_cores = NULL,             # NULL = auto (Windows: min(detect-1,8)); explicito se respeta
    use_parallel = TRUE,        # FALSE si se llama DENTRO de un driver ya paralelo (no anidar)
    chunk_size = NULL
) {
  hed_mode    <- match.arg(hed_mode)
  prev_method <- match.arg(prev_method)
  n_sim <- as.integer(n_sim); n_pca <- as.integer(n_pca)
  if (!is.finite(n_sim) || n_sim < 1L) stop("n_sim debe ser >= 1.")
  if (!is.finite(n_pca) || n_pca < 2L) stop("n_pca debe ser >= 2.")
  if (length(x) < 2L) stop("x debe tener al menos dos puntos.")
  neff_eff <- .aaf_resolve_neff_eff(neff_prev, design_factor)   # list(abs, form, hed)
  # Consumption design: effective n for the gamma resample (falls back to n_pca).
  n_pca_eff <- if (!is.null(neff_consumption)) {
    max(2L, as.integer(round(neff_consumption / design_factor_consumption)))
  } else as.integer(n_pca)

  beta <- as.numeric(beta)
  k <- length(beta)
  cov_beta <- .aaf_as_cov(cov_beta, k)

  # RR_FD central + parametro log
  if (!is.null(rr_fd)) {
    ln_rr_fd <- log(rr_fd)
  } else if (!is.null(ln_rr_fd)) {
    rr_fd <- exp(ln_rr_fd)
  } else {
    rr_fd <- 1; ln_rr_fd <- 0
  }
  fd_sd <- if (isTRUE(fd_uncertainty) && is.finite(var_ln_rr_fd) && var_ln_rr_fd > 0) {
    sqrt(var_ln_rr_fd)
  } else 0

  use_hed <- !is.null(p_hed) && length(p_hed) == 1L && is.finite(p_hed) && p_hed > 0
  pars_n <- .aaf_gamma_pars(gamma)
  pars_h <- if (use_hed) .aaf_gamma_pars(if (!is.null(gamma_hed)) gamma_hed else gamma) else NULL

  beta_hed_v <- if (!is.null(beta_hed)) as.numeric(beta_hed) else NULL
  cov_hed_m  <- if (!is.null(beta_hed_v)) .aaf_as_cov(cov_beta_hed, length(beta_hed_v)) else NULL

  # ---- estimacion puntual (deterministica, betas centrales, gamma ajustada) ----
  y_n0 <- .aaf_gamma_density(x, pars_n)
  rr_n0 <- rr_fun(x, beta)
  if (length(rr_n0) == 1L) rr_n0 <- rep(rr_n0, length(x))
  rr_h0 <- NULL; y_h0 <- NULL
  if (use_hed) {
    y_h0 <- .aaf_gamma_density(x, pars_h)
    if (hed_mode == "cap") {
      rr_h0 <- pmax(rr_n0, 1)
    } else {
      rr_h0 <- rr_fun_hed(x, if (!is.null(beta_hed_v)) beta_hed_v else beta)
      if (length(rr_h0) == 1L) rr_h0 <- rep(rr_h0, length(x))
    }
  }
  point <- .aaf_core(x, y_n0, rr_n0, p_abs, p_form, rr_fd,
                     p_hed = if (use_hed) p_hed else 0,
                     d_hed = y_h0, rr_hed = rr_h0, cap_upper = cap_upper)

  # ---- una simulacion (RNG ya posicionado por .aaf_mc_run) ----
  one_sim <- function(i) {
    gn <- .aaf_gamma_resample(n_pca_eff, pars_n)
    if (is.null(gn)) return(NA_real_)
    y_n <- dgamma(x, shape = gn$shape, rate = gn$rate)
    if (any(is.nan(y_n))) return(NA_real_)

    y_h <- NULL
    if (use_hed) {
      gh <- .aaf_gamma_resample(n_pca_eff, pars_h)
      if (is.null(gh)) return(NA_real_)
      y_h <- dgamma(x, shape = gh$shape, rate = gh$rate)
      if (any(is.nan(y_h))) return(NA_real_)
    }

    rd <- .aaf_draw_rr(x, use_hed, hed_mode, rr_fun, beta, cov_beta,
                       rr_fun_hed, beta_hed_v, cov_hed_m, share_beta1)
    pv <- .aaf_draw_prev(p_abs, p_form, p_hed, use_hed, neff_eff, prev_method)
    if (is.null(pv)) return(NA_real_)
    rfd <- if (fd_sd > 0) exp(rnorm(1, ln_rr_fd, fd_sd)) else rr_fd

    .aaf_core(x, y_n, rd$rr_n, pv$p_abs, pv$p_form, rfd,
              p_hed = pv$p_hed, d_hed = y_h, rr_hed = rd$rr_h, cap_upper = cap_upper)
  }

  sims <- .aaf_mc_run(n_sim, seed, one_sim, n_cores, use_parallel, chunk_size)
  if (!length(sims)) stop("Todas las simulaciones AAF fallaron. Revise insumos.")

  rnd <- function(v) if (is.null(round_digits)) v else round(v, round_digits)
  out <- list(
    point_estimate = rnd(point),
    lower_ci = unname(rnd(quantile(sims, 0.025))),
    upper_ci = unname(rnd(quantile(sims, 0.975))),
    n_used   = length(sims)
  )
  if (isTRUE(return_sims)) out$simulated_pafs <- sims
  out
}

# -----------------------------------------------------------------------------
# pif_confint: PIF puntual + IC 95% por Monte Carlo
# -----------------------------------------------------------------------------
# Misma maquinaria y argumentos que aaf_confint, mas:
#   scenario = "hed" | "volume" | "both"   (ver .pif_core)
#   shift    = fraccion RETENIDA de VOLUMEN (0.9 = reduccion del 10%)
#   shift_hed= fraccion RETENIDA de HED, solo scenario="both" (default = shift)
#   [2026-07-14]
#   hed_exit_mix   = lambda in [0,1]: share of the exiting binge mass that migrates to
#                    the NHED consumption distribution. NULL/0 = legacy (keeps d_hed).
#   hed_exit_shift = rho in (0,1]: volume the exiting binge mass retains. NULL/1 = legacy.
#   Both are CELL-level scalars, so the caller may pass a different value per
#   (year, sex, age band) -- use resolve_hed_exit() on a per-subgroup spec. In the MC
#   loop the exit RR is re-evaluated with the SAME drawn beta as the rest of the cell,
#   so the knobs carry no extra uncertainty of their own (they are policy assumptions,
#   not estimated parameters): vary them as a sensitivity, not as a random draw.
# Comparte el R_obs poblacional con el PAF -> PAF y PIF son comparables.
# IC en (-inf, 1] (sin clamp inferior), igual que el PAF: un PIF negativo senala
# una intervencion no beneficiosa o una incoherencia del modelo, y NO se oculta.
pif_confint <- function(
    gamma,
    rr_fun,
    beta,
    cov_beta = NULL,
    p_abs, p_form,
    rr_fd = NULL,
    ln_rr_fd = NULL,
    var_ln_rr_fd = 0,
    x = seq(0.1, 150, length.out = 1500),
    scenario = c("hed", "volume", "both"), shift = 0.9, shift_hed = NULL,
    # --- [2026-07-14] reasignacion de la masa que sale del binge; NULL = legacy ---
    hed_exit_mix = NULL,     # lambda in [0,1]: share migrating to the d_nhed distribution
    hed_exit_shift = NULL,   # rho in (0,1]: volume retained by the ex-HED drinker
    # --- bloque HED (opcional) ---
    p_hed = NULL,
    gamma_hed = NULL,
    rr_fun_hed = NULL,
    beta_hed = NULL,
    cov_beta_hed = NULL,
    hed_mode = c("cap", "explicit"),
    share_beta1 = TRUE,
    # --- incertidumbre de prevalencias ---
    prev_method = c("dirichlet", "binomial"),
    # Per-question Kish n and design factor (scalar or list(abs=, form=, hed=)).
    neff_prev = 1000,
    design_factor = 1,
    neff_consumption = NULL,
    design_factor_consumption = 1,
    # --- controles ---
    n_sim = 10000, n_pca = 1000, seed = 145,
    fd_uncertainty = TRUE,
    cap_upper = TRUE,
    round_digits = NULL,
    return_sims = FALSE,
    # --- paralelizacion ---
    n_cores = NULL,
    use_parallel = TRUE,
    chunk_size = NULL
) {
  hed_mode    <- match.arg(hed_mode)
  prev_method <- match.arg(prev_method)
  scenario    <- match.arg(scenario)
  n_sim <- as.integer(n_sim); n_pca <- as.integer(n_pca)
  if (!is.finite(n_sim) || n_sim < 1L) stop("n_sim debe ser >= 1.")
  if (!is.finite(n_pca) || n_pca < 2L) stop("n_pca debe ser >= 2.")
  if (length(x) < 2L) stop("x debe tener al menos dos puntos.")
  if (!is.finite(shift)) stop("shift debe ser finito.")
  # Combined scenario: default the HED retained fraction to the volume one unless
  # the caller passes an explicit shift_hed (allows different volume/HED reductions).
  if (identical(scenario, "both") && is.null(shift_hed)) shift_hed <- shift
  if (identical(scenario, "both") && !is.finite(shift_hed)) stop("shift_hed debe ser finito para scenario='both'.")
  hx <- .pif_hed_exit_pars(hed_exit_mix, hed_exit_shift, "pif_confint")  # [2026-07-14]
  neff_eff <- .aaf_resolve_neff_eff(neff_prev, design_factor)   # list(abs, form, hed)
  # Consumption design: effective n for the gamma resample (falls back to n_pca).
  n_pca_eff <- if (!is.null(neff_consumption)) {
    max(2L, as.integer(round(neff_consumption / design_factor_consumption)))
  } else as.integer(n_pca)

  beta <- as.numeric(beta)
  k <- length(beta)
  cov_beta <- .aaf_as_cov(cov_beta, k)

  if (!is.null(rr_fd)) {
    ln_rr_fd <- log(rr_fd)
  } else if (!is.null(ln_rr_fd)) {
    rr_fd <- exp(ln_rr_fd)
  } else {
    rr_fd <- 1; ln_rr_fd <- 0
  }
  fd_sd <- if (isTRUE(fd_uncertainty) && is.finite(var_ln_rr_fd) && var_ln_rr_fd > 0) {
    sqrt(var_ln_rr_fd)
  } else 0

  use_hed <- !is.null(p_hed) && length(p_hed) == 1L && is.finite(p_hed) && p_hed > 0
  if (scenario == "hed" && !use_hed) {
    stop("pif_confint: scenario='hed' requiere p_hed>0 (no hay binge que reducir).")
  }
  pars_n <- .aaf_gamma_pars(gamma)
  pars_h <- if (use_hed) .aaf_gamma_pars(if (!is.null(gamma_hed)) gamma_hed else gamma) else NULL

  beta_hed_v <- if (!is.null(beta_hed)) as.numeric(beta_hed) else NULL
  cov_hed_m  <- if (!is.null(beta_hed_v)) .aaf_as_cov(cov_beta_hed, length(beta_hed_v)) else NULL

  # ---- helper local: RR contrafactual de volumen para un set de betas ----
  rr_vol_cf <- function(beta_n, beta_h, mode) {
    rn <- rr_fun(x * shift, beta_n)
    if (length(rn) == 1L) rn <- rep(rn, length(x))
    rh <- NULL
    if (use_hed) {
      rh <- if (identical(mode, "explicit")) {
        v <- rr_fun_hed(x * shift, beta_h)
        if (length(v) == 1L) rep(v, length(x)) else v
      } else {
        pmax(rn, 1)
      }
    }
    list(rr_n = rn, rr_h = rh)
  }

  # ---- [2026-07-14] local helper: RR_NHED at the volume the ex-HED drinker RETAINS ----
  # Evaluated at x*rho under "hed", and at x*shift*rho under "both" (the policy volume
  # cut and the drinker's own binge-exit cut compound). The grid is precomputed once;
  # only the RR evaluation is redone per simulation, with the SAME drawn beta_n as the
  # rest of the cell -- the knobs are policy ASSUMPTIONS, not estimated parameters, so
  # they must not consume RNG draws or widen the CI on their own.
  # Returns NULL when there is nothing to re-evaluate:
  #   * no exiting mass (no HED, or scenario = "volume"),
  #   * rho == 1  -> the ex-HED keeps its full volume: the legacy RR vector is correct,
  #   * lambda == 1 -> the whole mass migrates to d_nhed and this term carries weight 0.
  # In every one of those cases .pif_core reuses the legacy vector, so results stay
  # bit-for-bit identical to the pre-2026-07-14 engine.
  x_exit <- if (use_hed && scenario %in% c("hed", "both") && hx$rho != 1 && hx$lambda < 1) {
    if (identical(scenario, "both")) x * shift * hx$rho else x * hx$rho
  } else NULL
  rr_exit_of <- function(beta_n) {
    if (is.null(x_exit)) return(NULL)
    v <- rr_fun(x_exit, beta_n)
    if (length(v) == 1L) v <- rep(v, length(x))
    v
  }

  # ---- estimacion puntual (deterministica) ----
  y_n0 <- .aaf_gamma_density(x, pars_n)
  rr_n0 <- rr_fun(x, beta)
  if (length(rr_n0) == 1L) rr_n0 <- rep(rr_n0, length(x))
  y_h0 <- NULL; rr_h0 <- NULL
  if (use_hed) {
    y_h0 <- .aaf_gamma_density(x, pars_h)
    if (hed_mode == "cap") {
      rr_h0 <- pmax(rr_n0, 1)
    } else {
      rr_h0 <- rr_fun_hed(x, if (!is.null(beta_hed_v)) beta_hed_v else beta)
      if (length(rr_h0) == 1L) rr_h0 <- rep(rr_h0, length(x))
    }
  }
  rr_n0_cf <- NULL; rr_h0_cf <- NULL
  if (scenario %in% c("volume", "both")) {
    cf0 <- rr_vol_cf(beta, if (!is.null(beta_hed_v)) beta_hed_v else beta, hed_mode)
    rr_n0_cf <- cf0$rr_n; rr_h0_cf <- cf0$rr_h
  }
  point <- .pif_core(x, y_n0, rr_n0, y_h0, rr_h0, p_abs, p_form, rr_fd,
                     if (use_hed) p_hed else 0,
                     scenario = scenario, shift = shift, shift_hed = shift_hed,
                     rr_nhed_cf = rr_n0_cf, rr_hed_cf = rr_h0_cf,
                     hed_exit_mix = hx$lambda, rr_nhed_exit = rr_exit_of(beta),
                     use_hed = use_hed, cap_upper = cap_upper)

  # ---- una simulacion ----
  one_sim <- function(i) {
    gn <- .aaf_gamma_resample(n_pca_eff, pars_n)
    if (is.null(gn)) return(NA_real_)
    y_n <- dgamma(x, shape = gn$shape, rate = gn$rate)
    if (any(is.nan(y_n))) return(NA_real_)

    y_h <- NULL
    if (use_hed) {
      gh <- .aaf_gamma_resample(n_pca_eff, pars_h)
      if (is.null(gh)) return(NA_real_)
      y_h <- dgamma(x, shape = gh$shape, rate = gh$rate)
      if (any(is.nan(y_h))) return(NA_real_)
    }

    rd <- .aaf_draw_rr(x, use_hed, hed_mode, rr_fun, beta, cov_beta,
                       rr_fun_hed, beta_hed_v, cov_hed_m, share_beta1)
    pv <- .aaf_draw_prev(p_abs, p_form, p_hed, use_hed, neff_eff, prev_method)
    if (is.null(pv)) return(NA_real_)
    rfd <- if (fd_sd > 0) exp(rnorm(1, ln_rr_fd, fd_sd)) else rr_fd

    rr_n_cf <- NULL; rr_h_cf <- NULL
    if (scenario %in% c("volume", "both")) {
      cf <- rr_vol_cf(rd$beta_n, rd$beta_h, rd$mode)
      rr_n_cf <- cf$rr_n; rr_h_cf <- cf$rr_h
    }

    .pif_core(x, y_n, rd$rr_n, y_h, rd$rr_h, pv$p_abs, pv$p_form, rfd, pv$p_hed,
              scenario = scenario, shift = shift, shift_hed = shift_hed,
              rr_nhed_cf = rr_n_cf, rr_hed_cf = rr_h_cf,
              # same drawn beta_n as the rest of this simulation -> no extra RNG draw,
              # so seeds/streams are untouched when the knobs are at their defaults.
              hed_exit_mix = hx$lambda, rr_nhed_exit = rr_exit_of(rd$beta_n),
              use_hed = use_hed, cap_upper = cap_upper)
  }

  sims <- .aaf_mc_run(n_sim, seed, one_sim, n_cores, use_parallel, chunk_size)
  if (!length(sims)) stop("Todas las simulaciones PIF fallaron. Revise insumos.")

  rnd <- function(v) if (is.null(round_digits)) v else round(v, round_digits)
  out <- list(
    point_estimate = rnd(point),
    lower_ci = unname(rnd(quantile(sims, 0.025))),
    upper_ci = unname(rnd(quantile(sims, 0.975))),
    n_used   = length(sims),
    scenario = scenario,
    shift    = shift,
    # [2026-07-14] echo the HED-exit assumptions so the caller can record WHICH
    # counterfactual produced this number (they are assumptions, not estimates).
    hed_exit_mix   = hx$lambda,
    hed_exit_shift = hx$rho
  )
  if (isTRUE(return_sims)) out$simulated_pifs <- sims
  out
}

# =============================================================================
# TRANSPARENT REGISTRY ORCHESTRATION
# -----------------------------------------------------------------------------
# compute_*_aaf_from_registry(): one transparent function per cause family. They
# call aaf_confint() DIRECTLY (no global knobs, no AAF_ENGINE switch, no separate
# wiring/binge file). Everything that affects a number is an EXPLICIT argument:
#   * data inputs : registry (RR curves), gamma lists, prevalence lists
#   * age bands   : age_groups + age_scope
#   * uncertainty : prev_method, neff, design_factor (per question), fd_uncertainty
#
# Each statistical knob (neff, design_factor, neff_consumption,
# design_factor_consumption) is resolved PER CELL via .aaf_resolve_cell(), which
# accepts any of:
#   * scalar                      -> same value for every cell and question
#   * list(abs=, form=, hed=)     -> per survey question (Kish/design per question)
#   * function(year, group, sex)  -> per cell (may itself return a per-question list)
#   * nested list [["<year>"]][["edad_tramo_<g>"]] or [[group]]  -> per cell, like
#                                    the p_abs_list / p_hed_list you already pass
#
# Parallelism: aaf_confint() parallelises its OWN Monte-Carlo loop, so the task
# loop here is SEQUENTIAL and `use_parallel` / `n_cores` control the INNER MC.
# =============================================================================

# -----------------------------------------------------------------------------
# SILENT FLAG LOG (skipped / errored / degraded cells, not omitted anymore)
# -----------------------------------------------------------------------------
# A module-level accumulator that the family loops write to whenever a cell is
# SKIPPED (invalid inputs), ERRORS (aaf_confint threw), loses Monte-Carlo draws
# (n_used < n_sim -> silently narrowed CI), or returns a non-finite point. Each
# row is keyed by output_name (location/table), disease (cause), sex, year,
# age_group, and type, so you can pull one table of everything that went wrong.
#
#   aaf_error_log()        -> data.frame of flagged cells (empty df if none)
#   aaf_error_log_reset()  -> clear the accumulator (call before a fresh batch)
#
# It is SILENT: writing a row prints nothing (existing message()/warning() from
# the family loops are unchanged). Logging happens on the MASTER (the family loops
# run there in both the sequential path and, for run_aaf_cells_parallel, in the
# PASS-2 replay), so it captures every mode of loss in one place. The driver
# resets the log before PASS 2, so aaf_error_log() reflects the real run only.
.aaf_run_log <- new.env(parent = emptyenv())
.aaf_run_log$rows <- list()

aaf_error_log_reset <- function() { .aaf_run_log$rows <- list(); invisible(NULL) }

.aaf_log_add <- function(output_name, disease, sex, year, group, type,
                         detail = NA_character_, n_sim = NA_integer_, n_used = NA_integer_) {
  chr <- function(v) if (is.null(v) || !length(v)) NA_character_ else as.character(v)[[1L]]
  n_sim_i  <- if (is.null(n_sim)  || !length(n_sim)  || !is.finite(suppressWarnings(as.numeric(n_sim))))  NA_integer_ else as.integer(n_sim)
  n_used_i <- if (is.null(n_used) || !length(n_used) || !is.finite(suppressWarnings(as.numeric(n_used)))) NA_integer_ else as.integer(n_used)
  frac <- if (is.na(n_sim_i) || is.na(n_used_i) || n_sim_i == 0L) NA_real_ else n_used_i / n_sim_i
  i <- length(.aaf_run_log$rows) + 1L
  .aaf_run_log$rows[[i]] <- data.frame(
    output_name = chr(output_name), disease = chr(disease), sex = chr(sex),
    year = if (is.null(year) || !length(year)) NA_integer_ else as.integer(year),
    age_group = if (is.null(group) || !length(group)) NA_integer_ else as.integer(group),
    type = chr(type), detail = chr(detail),
    n_sim = n_sim_i, n_used = n_used_i, frac_used = frac,
    stringsAsFactors = FALSE)
  invisible(NULL)
}

aaf_error_log <- function() {
  if (!length(.aaf_run_log$rows)) {
    return(data.frame(output_name = character(0), disease = character(0), sex = character(0),
                      year = integer(0), age_group = integer(0), type = character(0),
                      detail = character(0), n_sim = integer(0), n_used = integer(0),
                      frac_used = numeric(0), stringsAsFactors = FALSE))
  }
  do.call(rbind, .aaf_run_log$rows)
}

# ---- output table skeleton: Year + <prefix><g>_{point,lower,upper} -----------
.aaf_make_output_df <- function(years, prefix, age_groups) {
  out <- data.frame(Year = years, check.names = FALSE)
  for (g in age_groups) {
    out[[paste0(prefix, g, "_point")]] <- NA_real_
    out[[paste0(prefix, g, "_lower")]] <- NA_real_
    out[[paste0(prefix, g, "_upper")]] <- NA_real_
  }
  out
}

# ---- capture one complete, position-preserving AAF simulation vector --------
# `run_aaf_cells_parallel()` executes the family wrappers twice. During its
# collection pass, the placeholder result deliberately has no simulated_pafs;
# that placeholder is ignored here. During the real replay, however, capture is
# strict: every cell must contain exactly n_sim finite values and report that all
# simulations were used. This makes draw position auditable across cells and
# prevents a ragged vector from silently masquerading as synchronized draws.
.aaf_capture_cell_draws <- function(res, return_sims, n_sim, output_name,
                                    disease, sex, year, age_group, hed_mode,
                                    source_object = NA_character_) {
  if (!base::isTRUE(return_sims)) return(NULL)

  if (base::is.null(res$simulated_pafs)) {
    collection_placeholder <-
      base::identical(base::as.integer(res$n_used), 0L) &&
      base::isTRUE(base::is.na(res$point_estimate))
    if (collection_placeholder) return(NULL)
    base::stop(
      "AAF draw capture was requested but simulated_pafs is missing for ",
      output_name, ", year ", year, ", age group ", age_group, "."
    )
  }

  draws <- base::as.numeric(res$simulated_pafs)
  n_used <- if (base::is.null(res$n_used)) NA_integer_ else base::as.integer(res$n_used)
  if (
    base::length(draws) != base::as.integer(n_sim) ||
    !base::all(base::is.finite(draws)) ||
    base::is.na(n_used) ||
    n_used != base::as.integer(n_sim)
  ) {
    base::stop(
      "AAF synchronization failed for ", output_name,
      ", year ", year, ", age group ", age_group,
      ": expected ", n_sim, " finite draws with n_used = ", n_sim,
      "; received length = ", base::length(draws),
      " and n_used = ", n_used, "."
    )
  }

  cell_key <- base::paste(output_name, sex, year, age_group, sep = "|")
  list(
    cell_key = cell_key,
    draws = draws,
    metadata = base::data.frame(
      cell_key = cell_key,
      output_name = base::as.character(output_name),
      disease = base::as.character(disease),
      sex = base::as.character(sex),
      year = base::as.integer(year),
      age_group = base::as.integer(age_group),
      hed_mode = base::as.character(hed_mode),
      source_object = if (base::is.null(source_object)) NA_character_ else base::as.character(source_object),
      point_estimate_raw = base::as.numeric(res$point_estimate),
      lower_ci_raw = base::as.numeric(res$lower_ci),
      upper_ci_raw = base::as.numeric(res$upper_ci),
      n_used = n_used,
      stringsAsFactors = FALSE
    )
  )
}

.aaf_bind_draw_metadata <- function(rows) {
  if (!base::length(rows)) {
    return(base::data.frame(
      cell_key = character(0), output_name = character(0), disease = character(0),
      sex = character(0), year = integer(0), age_group = integer(0),
      hed_mode = character(0), source_object = character(0),
      point_estimate_raw = numeric(0), lower_ci_raw = numeric(0),
      upper_ci_raw = numeric(0), n_used = integer(0),
      stringsAsFactors = FALSE
    ))
  }
  out <- base::do.call(base::rbind, base::unname(rows))
  base::row.names(out) <- NULL
  out
}

# ---- pick a prevalence keyed [["<year>"]][["edad_tramo_<group>"]] -------------
.aaf_pick_prop <- function(prop_list, year, group) {
  year_entry <- prop_list[[as.character(year)]]
  if (is.null(year_entry)) return(NA_real_)
  val <- year_entry[[paste0("edad_tramo_", group)]]
  if (is.null(val) || !length(val)) return(NA_real_)
  as.numeric(val[[1L]])
}

# ---- pick p_hed, which may be keyed [["<year>"]][["edad_tramo_<g>"]] OR -------
# ---- [[group]][year_index] (the two shapes the pipeline uses) ----------------
.aaf_prop_from_group_list <- function(prop_list, row_index, group, year = NULL) {
  if (!is.null(year)) {
    year_entry <- prop_list[[as.character(year)]]
    if (!is.null(year_entry)) {
      val <- year_entry[[paste0("edad_tramo_", group)]]
      if (!is.null(val) && length(val)) return(as.numeric(val[[1L]]))
    }
  }
  group_entry <- prop_list[[group]]
  if (is.null(group_entry) || length(group_entry) < row_index) return(NA_real_)
  as.numeric(group_entry[[row_index]])
}

# ---- resolve a knob (neff / design_factor) for one (year, group, sex) cell ----
# Returns a scalar or a per-question list(abs, form, hed) that aaf_confint reads.
.aaf_resolve_cell <- function(spec, year, group, sex) {
  if (is.null(spec)) return(spec)
  if (is.function(spec)) return(spec(year, group, sex))
  if (is.list(spec)) {
    nm <- names(spec)
    # per-question spec: hand straight to aaf_confint
    if (!is.null(nm) && length(nm) && all(nm %in% c("abs", "form", "hed"))) return(spec)
    # per-cell nested list keyed by year
    yk <- as.character(year)
    if (!is.null(spec[[yk]])) {
      ycell <- spec[[yk]]
      if (is.list(ycell)) {
        v <- ycell[[paste0("edad_tramo_", group)]]
        if (is.null(v)) v <- ycell[[group]]
        if (!is.null(v)) return(if (length(v) >= 1L) v[[1L]] else v)
      } else {
        return(ycell)
      }
    }
    # group-keyed list
    if (is.numeric(group) && length(spec) >= group) {
      gv <- spec[[group]]
      if (!is.null(gv)) return(if (length(gv) >= 1L) gv[[1L]] else gv)
    }
  }
  spec  # scalar
}

# ---- light, knob-aware audit row (transparent record of what was actually run)-
.aaf_audit_row <- function(output_name, record, prefix, hed_mode,
                           prev_method, neff, design_factor,
                           neff_consumption, design_factor_consumption,
                           fd_uncertainty, n_sim, n_pca, seed, n_errors) {
  flat <- function(v) {
    if (is.null(v)) return(NA_character_)
    if (is.function(v)) return("function(year,group,sex)")
    if (is.list(v)) {
      return(paste(names(v),
                   vapply(v, function(z) if (is.numeric(z) && length(z) == 1L) format(z) else "<...>", character(1)),
                   sep = "=", collapse = "; "))
    }
    paste(format(v), collapse = "; ")
  }
  data.frame(
    output_name = output_name,
    disease = if (is.null(record$pipeline_disease)) record$disease else record$pipeline_disease,
    sex = record$sex,
    source_object = if (is.null(record$source_object)) NA_character_ else record$source_object,
    hed_mode = hed_mode,
    prev_method = prev_method,
    neff = flat(neff),
    design_factor = flat(design_factor),
    neff_consumption = flat(neff_consumption),
    design_factor_consumption = flat(design_factor_consumption),
    fd_uncertainty = isTRUE(fd_uncertainty),
    rr_form_used = exp(record$lnRRFormer),
    varLnRRFormer = if (is.null(record$varLnRRFormer)) NA_real_ else record$varLnRRFormer,
    n_sim = n_sim, n_pca = n_pca, seed = seed, n_errors = n_errors,
    stringsAsFactors = FALSE
  )
}

# ---- pipeline age-group -> Adam age-band mapping (for the age-banded IHD/IS) --
# 15_64 : group 4 (60-64) folds into Adam band 35-64 (the 15-64 pipeline).
# 15_65 : group 4 (60-65) folds into Adam band 35-64 (the 15-65 pipeline). The
#         ENPG survey frame is 12-65, so group 4 spans 60-65. The Adam band is
#         IDENTICAL to 15_64 (35-64): the whole 60-65 group uses the 35-64 RR
#         curve; the age-65 slice is deliberately NOT split out to the Adam 65+
#         band (group is mostly 60-64; see handoff 2026-07-10). The "15_65" name
#         exists only to document the real 60-65 support -- it changes no numbers
#         relative to "15_64".
# 15_plus: legacy, group 4 (60+) -> 65+.
aaf_age_band_mapping <- function(age_scope = c("15_64", "15_65", "15_plus")) {
  age_scope <- match.arg(age_scope)
  # 15_64 and 15_65 share the same Adam-band mapping (group 4 -> 35-64); only the
  # underlying age support of group 4 differs (60-64 vs 60-65), which is handled
  # upstream in the death/exposure filters, not here.
  if (identical(age_scope, "15_64") || identical(age_scope, "15_65")) {
    data.frame(
      group = 1:4,
      adam_age_band = c("15-34", "35-64", "35-64", "35-64"),
      stringsAsFactors = FALSE
    )
  } else {
    data.frame(
      group = 1:4,
      adam_age_band = c("15-34", "35-64", "35-64", "65+"),
      stringsAsFactors = FALSE
    )
  }
}

# ---- generic NO-HED bridge: one RR record -> wide AAF table (cancer/chronic/HHD)
# `record` carries RRCurrent / betaCurrent / covBetaCurrent / lnRRFormer /
# varLnRRFormer. Loops year x age_group, calls aaf_confint(hed_mode none).
compute_aaf_from_rr_record <- function(
    record,
    g_list,
    p_abs_list,
    p_form_list,
    x_vals,
    years = c(2008, 2010, 2012, 2014, 2016, 2018, 2020, 2022),
    age_groups = 1:4,
    prev_method = "dirichlet",
    neff = 1000,
    design_factor = 1.35,
    neff_consumption = NULL,
    design_factor_consumption = 1,
    fd_uncertainty = TRUE,
    n_sim = 10000,
    n_pca = 1000,
    seed = 2125,
    n_cores = NULL,
    use_parallel = TRUE,
    stop_on_error = FALSE,
    output_name = NA_character_,
    return_sims = FALSE
) {
  prefix <- if (identical(record$sex, "female")) "Fem" else "Male"
  out <- .aaf_make_output_df(years = years, prefix = prefix, age_groups = age_groups)
  errors <- list()
  draws <- list()
  draw_metadata <- list()

  for (i in seq_along(years)) {
    y <- years[[i]]
    for (g in age_groups) {
      gamma_fit <- g_list[[as.character(y)]][[g]]
      p_abs <- .aaf_pick_prop(p_abs_list, y, g)
      p_form <- .aaf_pick_prop(p_form_list, y, g)
      if (is.null(gamma_fit) || is.na(p_abs) || is.na(p_form)) {
        msg <- paste("Skipping", record$pipeline_disease, record$sex, y, "group", g, "- invalid inputs")
        message(msg)
        errors[[length(errors) + 1L]] <- data.frame(year = y, group = g, message = msg, stringsAsFactors = FALSE)
        .aaf_log_add(output_name, record$pipeline_disease, record$sex, y, g, "skipped_invalid_inputs",
                     detail = paste0(c(if (is.null(gamma_fit)) "gamma_null", if (is.na(p_abs)) "p_abs_NA",
                                       if (is.na(p_form)) "p_form_NA"), collapse = ","))
        next
      }
      res <- tryCatch(
        aaf_confint(
          gamma = gamma_fit, rr_fun = record$RRCurrent,
          beta = record$betaCurrent, cov_beta = record$covBetaCurrent,
          p_abs = p_abs, p_form = p_form,
          ln_rr_fd = record$lnRRFormer,
          var_ln_rr_fd = if (is.null(record$varLnRRFormer)) 0 else record$varLnRRFormer,
          fd_uncertainty = fd_uncertainty,
          x = x_vals, prev_method = prev_method,
          neff_prev = .aaf_resolve_cell(neff, y, g, record$sex),
          design_factor = .aaf_resolve_cell(design_factor, y, g, record$sex),
          neff_consumption = .aaf_resolve_cell(neff_consumption, y, g, record$sex),
          design_factor_consumption = .aaf_resolve_cell(design_factor_consumption, y, g, record$sex),
          n_sim = n_sim, n_pca = n_pca, seed = seed,
          n_cores = n_cores, use_parallel = use_parallel,
          return_sims = return_sims
        ),
        error = function(e) e
      )
      if (inherits(res, "error")) {
        msg <- paste("Error for", record$pipeline_disease, record$sex, "year", y, "group", g, "->", conditionMessage(res))
        message(msg)
        errors[[length(errors) + 1L]] <- data.frame(year = y, group = g, message = msg, stringsAsFactors = FALSE)
        .aaf_log_add(output_name, record$pipeline_disease, record$sex, y, g, "cell_error",
                     detail = conditionMessage(res))
        if (isTRUE(stop_on_error)) stop(msg)
        next
      }
      out[i, paste0(prefix, g, "_point")] <- min(res$point_estimate, 1)
      out[i, paste0(prefix, g, "_lower")] <- min(res$lower_ci, res$point_estimate)
      out[i, paste0(prefix, g, "_upper")] <- min(max(res$upper_ci, res$point_estimate), 1)
      captured <- .aaf_capture_cell_draws(
        res = res, return_sims = return_sims, n_sim = n_sim,
        output_name = output_name, disease = record$pipeline_disease,
        sex = record$sex, year = y, age_group = g, hed_mode = "none",
        source_object = record$source_object
      )
      if (!base::is.null(captured)) {
        draws[[captured$cell_key]] <- captured$draws
        draw_metadata[[captured$cell_key]] <- captured$metadata
      }
      if (!is.null(res$point_estimate) && !is.finite(res$point_estimate)) {
        .aaf_log_add(output_name, record$pipeline_disease, record$sex, y, g, "na_point_estimate",
                     detail = "point estimate not finite", n_sim = n_sim,
                     n_used = if (is.null(res$n_used)) NA_integer_ else res$n_used)
      } else if (!is.null(res$n_used) && res$n_used > 0L && res$n_used < n_sim) {
        .aaf_log_add(output_name, record$pipeline_disease, record$sex, y, g, "partial_sims_dropped",
                     detail = sprintf("%d/%d sims used", res$n_used, n_sim), n_sim = n_sim, n_used = res$n_used)
      }
    }
  }
  out$disease <- record$pipeline_disease

  audit <- .aaf_audit_row(output_name, record, prefix, "none", prev_method, neff, design_factor,
                          neff_consumption, design_factor_consumption, fd_uncertainty,
                          n_sim, n_pca, seed, length(errors))
  list(
    aaf = out,
    audit = audit,
    errors = if (length(errors)) do.call(rbind, errors) else data.frame(),
    draws = draws,
    draw_metadata = .aaf_bind_draw_metadata(draw_metadata)
  )
}

# ---- shared loop over a `targets` table for the NO-HED cause families ---------
# `targets` must have output_name, sex; `find_record(targets_row)` returns the
# record and `set_meta(record, targets_row)` stamps pipeline labels onto it.
.aaf_run_cause_tables <- function(registry, targets, find_record, set_meta,
                                  g_fem_list, g_male_list,
                                  p_abs_list_fem, p_abs_list_male,
                                  p_form_list_fem, p_form_list_male,
                                  target_output_names, dots) {
  if (!is.null(target_output_names)) {
    targets <- targets[targets$output_name %in% target_output_names, , drop = FALSE]
  }
  if (!nrow(targets)) stop("No target outputs selected.")
  tables <- list(); audits <- list(); errors <- list()
  draws <- list(); draw_metadata <- list()
  for (i in seq_len(nrow(targets))) {
    record <- set_meta(find_record(targets[i, , drop = FALSE]), targets[i, , drop = FALSE])
    g_list <- if (record$sex == "female") g_fem_list else g_male_list
    p_abs_list <- if (record$sex == "female") p_abs_list_fem else p_abs_list_male
    p_form_list <- if (record$sex == "female") p_form_list_fem else p_form_list_male
    computed <- do.call(compute_aaf_from_rr_record, c(
      list(record = record, g_list = g_list, p_abs_list = p_abs_list, p_form_list = p_form_list,
           output_name = targets$output_name[[i]]), dots))
    tables[[targets$output_name[[i]]]] <- computed$aaf
    audits[[length(audits) + 1L]] <- computed$audit
    if (base::length(computed$draws)) draws <- base::c(draws, computed$draws)
    if (base::nrow(computed$draw_metadata)) {
      draw_metadata[[base::length(draw_metadata) + 1L]] <- computed$draw_metadata
    }
    if (nrow(computed$errors)) {
      computed$errors$output_name <- targets$output_name[[i]]
      errors[[length(errors) + 1L]] <- computed$errors
    }
  }
  list(tables = tables,
       audit = do.call(rbind, audits),
       errors = if (length(errors)) do.call(rbind, errors) else data.frame(),
       draws = draws,
       draw_metadata = .aaf_bind_draw_metadata(draw_metadata))
}

# Find the single registry record matching a (field == value) set.
.aaf_find_one <- function(registry, ...) {
  crit <- list(...)
  keep <- vapply(registry, function(r) all(vapply(names(crit), function(k) identical(r[[k]], crit[[k]]), logical(1))), logical(1))
  hits <- registry[keep]
  if (length(hits) != 1L) {
    stop("Expected one registry record for ", paste(names(crit), unlist(crit), sep = "=", collapse = " / "),
         ", found ", length(hits))
  }
  hits[[1L]]
}

# ---- cancer (no HED). Output names + shared oral/pharynx RR preserved ---------
compute_cancer_aaf_from_registry <- function(
    registry, g_fem_list, g_male_list,
    p_abs_list_fem, p_abs_list_male, p_form_list_fem, p_form_list_male,
    x_vals, years = c(2008, 2010, 2012, 2014, 2016, 2018, 2020, 2022), age_groups = 1:4,
    target_output_names = NULL, ...) {
  targets <- data.frame(
    output_name = c("locan_female", "locan_male", "opcan_female", "opcan_male",
                    "oescan_female", "oescan_male", "crcan_female", "crcan_male",
                    "lican_female", "lican_male", "lxcan_female", "lxcan_male",
                    "bcan_female", "stomcan_female", "stomcan_male",
                    "panccan_female", "panccan_male"),
    disease = c("Oral_Cavity_and_Pharynx_Cancer", "Oral_Cavity_and_Pharynx_Cancer",
                "Oral_Cavity_and_Pharynx_Cancer", "Oral_Cavity_and_Pharynx_Cancer",
                "Oesophagus_Cancer", "Oesophagus_Cancer", "Colorectal_Cancer", "Colorectal_Cancer",
                "Liver_Cancer", "Liver_Cancer", "Larynx_Cancer", "Larynx_Cancer",
                "Breast_Cancer", "Stomach_Cancer", "Stomach_Cancer",
                "Pancreas_Cancer", "Pancreas_Cancer"),
    sex = c("female", "male", "female", "male", "female", "male", "female", "male",
            "female", "male", "female", "male", "female", "female", "male", "female", "male"),
    pipeline_disease = c("Oral Cavity and Pharynx Cancer", "Oral Cavity and Pharynx Cancer",
                         "Other Pharyngeal Cancer", "Other Pharyngeal Cancer",
                         "Oesophagus Cancer", "Oesophagus Cancer", "Colon and rectum Cancer",
                         "Colon and rectum Cancer", "Liver Cancer", "Liver Cancer",
                         "Larynx Cancer", "Larynx Cancer", "Breast Cancer", "Stomach Cancer",
                         "Stomach Cancer", "Pancreatic Cancer", "Pancreatic Cancer"),
    stringsAsFactors = FALSE)
  .aaf_run_cause_tables(
    registry, targets,
    find_record = function(row) .aaf_find_one(registry, disease = row$disease, sex = row$sex),
    set_meta = function(rec, row) { rec$pipeline_disease <- row$pipeline_disease; rec },
    g_fem_list, g_male_list, p_abs_list_fem, p_abs_list_male, p_form_list_fem, p_form_list_male,
    target_output_names,
    dots = list(x_vals = x_vals, years = years, age_groups = age_groups, ...))
}

# ---- HHD (no HED) ------------------------------------------------------------
compute_hhd_aaf_from_registry <- function(
    registry, g_fem_list, g_male_list,
    p_abs_list_fem, p_abs_list_male, p_form_list_fem, p_form_list_male,
    x_vals, years = c(2008, 2010, 2012, 2014, 2016, 2018, 2020, 2022), age_groups = 1:4,
    target_output_names = NULL, ...) {
  targets <- data.frame(
    output_name = c("hhd_female", "hhd_male"),
    disease = c("Hypertension", "Hypertension"),
    sex = c("female", "male"),
    pipeline_disease = c("Hypertensive Heart Disease", "Hypertensive Heart Disease"),
    stringsAsFactors = FALSE)
  .aaf_run_cause_tables(
    registry, targets,
    find_record = function(row) .aaf_find_one(registry, disease = row$disease, sex = row$sex),
    set_meta = function(rec, row) { rec$pipeline_disease <- row$pipeline_disease; rec },
    g_fem_list, g_male_list, p_abs_list_fem, p_abs_list_male, p_form_list_fem, p_form_list_male,
    target_output_names,
    dots = list(x_vals = x_vals, years = years, age_groups = age_groups, ...))
}

# ---- output-name helpers (the notebook uses these to pick target tables) -----
adam_general_rr_targets <- function() data.frame(
  output_name = c("epi_female", "epi_male", "dm_fem", "dm_male", "tb_female", "tb_male",
                  "hiv_female", "hiv_male", "lri_female", "lri_male", "lc_fem", "lc_male",
                  "panc_fem", "panc_male", "ich_female", "ich_male"),
  stringsAsFactors = FALSE)
adam_injury_rr_targets <- function() data.frame(
  output_name = c("ri_fem", "ri_male", "injuries_fem", "injuries_male", "violence_fem", "violence_male"),
  stringsAsFactors = FALSE)

# ---- general chronic causes (no HED), matched by source_object ---------------
compute_general_aaf_from_registry <- function(
    registry, g_fem_list, g_male_list,
    p_abs_list_fem, p_abs_list_male, p_form_list_fem, p_form_list_male,
    x_vals, years = c(2008, 2010, 2012, 2014, 2016, 2018, 2020, 2022), age_groups = 1:4,
    target_output_names = NULL, ...) {
  targets <- data.frame(
    output_name = c("epi_female", "epi_male", "dm_fem", "dm_male", "tb_female", "tb_male",
                    "hiv_female", "hiv_male", "lri_female", "lri_male", "lc_fem", "lc_male",
                    "panc_fem", "panc_male", "ich_female", "ich_male"),
    source_object = c("epilepsyfemale", "epilepsymale", "diabetesfemale", "diabetesmale",
                      "tuberculosisfemale", "tuberculosismale", "HIVfemale", "HIVmale",
                      "lowerrespfemale", "lowerrespmale", "livercirrhosisfemale", "livercirrhosismale",
                      "pancreatitisfemale", "pancreatitismale", "hemorrhagicstrokefemale", "hemorrhagicstrokemale"),
    sex = c("female", "male", "female", "male", "female", "male", "female", "male",
            "female", "male", "female", "male", "female", "male", "female", "male"),
    pipeline_disease = c("Epilepsy", "Epilepsy", "DM2", "DM2", "Tuberculosis", "Tuberculosis",
                         "HIV", "HIV", "Lower Respiratory Infection", "Lower Respiratory Infection",
                         "Liver Cirrhosis", "Liver Cirrhosis", "Acute Pancreatitis", "Acute Pancreatitis",
                         "Intracerebral Haemorrhage", "Intracerebral Haemorrhage"),
    stringsAsFactors = FALSE)
  .aaf_run_cause_tables(
    registry, targets,
    find_record = function(row) .aaf_find_one(registry, source_object = row$source_object, sex = row$sex),
    set_meta = function(rec, row) { rec$pipeline_disease <- row$pipeline_disease; rec },
    g_fem_list, g_male_list, p_abs_list_fem, p_abs_list_male, p_form_list_fem, p_form_list_male,
    target_output_names,
    dots = list(x_vals = x_vals, years = years, age_groups = age_groups, ...))
}

# ---- shared HED cell loop (cap = IHD/IS J-curve; explicit = injuries) ---------
# get_record(group) returns the RR record for that pipeline group (age-banded for
# CV, constant for injuries). hed_mode picks RR_HED = pmax(RR_NHED,1) (cap) vs an
# explicit RRCurrent_binge with shared beta1 (explicit).
.aaf_run_hed_table <- function(output_name, prefix, get_record, g_hed_list,
                               p_abs_list, p_form_list, p_hed_list, x_vals, years, age_groups,
                               hed_mode, fd_uncertainty, prev_method, neff, design_factor,
                               neff_consumption, design_factor_consumption,
                               n_sim, n_pca, seed, n_cores, use_parallel, stop_on_error,
                               return_sims = FALSE) {
  out <- .aaf_make_output_df(years, prefix, age_groups)
  errors <- list()
  draws <- list()
  draw_metadata <- list()
  for (i in seq_along(years)) {
    y <- years[[i]]
    for (g in age_groups) {
      record <- tryCatch(get_record(g), error = function(e) NULL)
      hed_entry <- g_hed_list[[as.character(y)]][[g]]
      g_nhed <- if (!is.null(hed_entry)) hed_entry$nhed else NULL
      g_hed  <- if (!is.null(hed_entry)) hed_entry$hed  else NULL
      p_abs <- .aaf_pick_prop(p_abs_list, y, g)
      p_form <- .aaf_pick_prop(p_form_list, y, g)
      p_hed <- .aaf_prop_from_group_list(p_hed_list, i, g, y)
      if (is.null(record) || is.null(g_nhed) || is.null(g_hed) ||
          is.na(p_abs) || is.na(p_form) || is.na(p_hed)) {
        msg <- paste("Skipping", output_name, y, "group", g, "- invalid inputs"); message(msg)
        errors[[length(errors) + 1L]] <- data.frame(year = y, group = g, message = msg, stringsAsFactors = FALSE)
        .aaf_log_add(output_name, if (!is.null(record)) record$pipeline_disease else NA_character_,
                     if (identical(prefix, "Fem")) "female" else "male", y, g, "skipped_invalid_inputs",
                     detail = paste0(c(if (is.null(record)) "record_null", if (is.null(g_nhed)) "gamma_nhed_null",
                                       if (is.null(g_hed)) "gamma_hed_null", if (is.na(p_abs)) "p_abs_NA",
                                       if (is.na(p_form)) "p_form_NA", if (is.na(p_hed)) "p_hed_NA"), collapse = ","))
        next
      }
      args <- list(
        gamma = g_nhed, gamma_hed = g_hed, rr_fun = record$RRCurrent, beta = record$betaCurrent,
        p_abs = p_abs, p_form = p_form, p_hed = p_hed,
        ln_rr_fd = record$lnRRFormer,
        var_ln_rr_fd = if (is.null(record$varLnRRFormer)) 0 else record$varLnRRFormer,
        fd_uncertainty = fd_uncertainty, hed_mode = hed_mode, x = x_vals, prev_method = prev_method,
        neff_prev = .aaf_resolve_cell(neff, y, g, record$sex),
        design_factor = .aaf_resolve_cell(design_factor, y, g, record$sex),
        neff_consumption = .aaf_resolve_cell(neff_consumption, y, g, record$sex),
        design_factor_consumption = .aaf_resolve_cell(design_factor_consumption, y, g, record$sex),
        n_sim = n_sim, n_pca = n_pca, seed = seed, n_cores = n_cores,
        use_parallel = use_parallel, return_sims = return_sims)
      if (identical(hed_mode, "cap")) {
        args$cov_beta <- record$covBetaCurrent   # J-curve betas drawn jointly
      } else {
        args$cov_beta <- NULL                     # NHED fixed bar shared beta1
        args$rr_fun_hed <- record$RRCurrent_binge
        args$beta_hed <- record$betaCurrent_binge
        args$cov_beta_hed <- record$covBetaCurrent_binge
        args$share_beta1 <- TRUE
      }
      res <- tryCatch(do.call(aaf_confint, args), error = function(e) e)
      if (inherits(res, "error")) {
        msg <- paste("Error", output_name, y, "group", g, "->", conditionMessage(res)); message(msg)
        errors[[length(errors) + 1L]] <- data.frame(year = y, group = g, message = msg, stringsAsFactors = FALSE)
        .aaf_log_add(output_name, if (!is.null(record)) record$pipeline_disease else NA_character_,
                     if (identical(prefix, "Fem")) "female" else "male", y, g, "cell_error",
                     detail = conditionMessage(res))
        if (isTRUE(stop_on_error)) stop(msg)
        next
      }
      out[i, paste0(prefix, g, "_point")] <- min(res$point_estimate, 1)
      out[i, paste0(prefix, g, "_lower")] <- min(res$lower_ci, res$point_estimate)
      out[i, paste0(prefix, g, "_upper")] <- min(max(res$upper_ci, res$point_estimate), 1)
      captured <- .aaf_capture_cell_draws(
        res = res, return_sims = return_sims, n_sim = n_sim,
        output_name = output_name, disease = record$pipeline_disease,
        sex = record$sex, year = y, age_group = g, hed_mode = hed_mode,
        source_object = record$source_object
      )
      if (!base::is.null(captured)) {
        draws[[captured$cell_key]] <- captured$draws
        draw_metadata[[captured$cell_key]] <- captured$metadata
      }
      if (!is.null(res$point_estimate) && !is.finite(res$point_estimate)) {
        .aaf_log_add(output_name, if (!is.null(record)) record$pipeline_disease else NA_character_,
                     if (identical(prefix, "Fem")) "female" else "male", y, g, "na_point_estimate",
                     detail = "point estimate not finite", n_sim = n_sim,
                     n_used = if (is.null(res$n_used)) NA_integer_ else res$n_used)
      } else if (!is.null(res$n_used) && res$n_used > 0L && res$n_used < n_sim) {
        .aaf_log_add(output_name, if (!is.null(record)) record$pipeline_disease else NA_character_,
                     if (identical(prefix, "Fem")) "female" else "male", y, g, "partial_sims_dropped",
                     detail = sprintf("%d/%d sims used", res$n_used, n_sim), n_sim = n_sim, n_used = res$n_used)
      }
    }
  }
  list(
    out = out,
    errors = errors,
    draws = draws,
    draw_metadata = .aaf_bind_draw_metadata(draw_metadata)
  )
}

# ---- IHD / IS J-curve + binge (cap). Replaces ihd_is_binge_aaf.R -------------
# Pass the ihd OR is registry (load_adam_rr_registry(scope="ihd"|"is")). Produces
# one wide table per sex (ihd_female/ihd_male or is_female/is_male). Age-banded:
# pipeline group -> Adam band via age_scope.
compute_cv_aaf_from_registry <- function(
    registry, g_fem_hed_list, g_male_hed_list,
    p_abs_list_fem, p_abs_list_male, p_form_list_fem, p_form_list_male,
    p_hed_list_fem, p_hed_list_male,
    x_vals, years = c(2008, 2010, 2012, 2014, 2016, 2018, 2020, 2022), age_groups = 1:4,
    age_scope = "15_64",
    prev_method = "dirichlet", neff = 1000, design_factor = 1.35,
    neff_consumption = NULL, design_factor_consumption = 1, fd_uncertainty = TRUE,
    n_sim = 10000, n_pca = 1000, seed = 2125, n_cores = NULL, use_parallel = TRUE,
    target_output_names = NULL, stop_on_error = FALSE, return_sims = FALSE) {
  disease <- registry[[1L]]$pipeline_disease
  key <- if (grepl("Heart", disease)) "ihd" else "is"
  age_map <- aaf_age_band_mapping(age_scope)
  age_map <- age_map[age_map$group %in% age_groups, , drop = FALSE]

  tables <- list(); audits <- list(); errors <- list()
  draws <- list(); draw_metadata <- list()
  for (sex in c("female", "male")) {
    output_name <- paste0(key, "_", sex)
    if (!is.null(target_output_names) && !(output_name %in% target_output_names)) next
    prefix <- if (sex == "female") "Fem" else "Male"
    g_hed_list <- if (sex == "female") g_fem_hed_list else g_male_hed_list
    p_abs_list <- if (sex == "female") p_abs_list_fem else p_abs_list_male
    p_form_list <- if (sex == "female") p_form_list_fem else p_form_list_male
    p_hed_list <- if (sex == "female") p_hed_list_fem else p_hed_list_male
    get_record <- function(g) {
      band <- age_map$adam_age_band[age_map$group == g]
      .aaf_find_one(registry, sex = sex, adam_age_band = band)
    }
    run <- .aaf_run_hed_table(output_name, prefix, get_record, g_hed_list,
      p_abs_list, p_form_list, p_hed_list, x_vals, years, age_groups,
      hed_mode = "cap", fd_uncertainty = fd_uncertainty, prev_method = prev_method,
      neff = neff, design_factor = design_factor, neff_consumption = neff_consumption,
      design_factor_consumption = design_factor_consumption,
      n_sim = n_sim, n_pca = n_pca, seed = seed, n_cores = n_cores,
      use_parallel = use_parallel, stop_on_error = stop_on_error,
      return_sims = return_sims)
    run$out$disease <- disease
    tables[[output_name]] <- run$out
    if (base::length(run$draws)) draws <- base::c(draws, run$draws)
    if (base::nrow(run$draw_metadata)) {
      draw_metadata[[base::length(draw_metadata) + 1L]] <- run$draw_metadata
    }
    audits[[length(audits) + 1L]] <- .aaf_audit_row(output_name, get_record(age_groups[[1L]]), prefix,
      "cap", prev_method, neff, design_factor, neff_consumption, design_factor_consumption,
      fd_uncertainty, n_sim, n_pca, seed, length(run$errors))
    if (length(run$errors)) {
      ed <- do.call(rbind, run$errors); ed$output_name <- output_name
      errors[[length(errors) + 1L]] <- ed
    }
  }
  list(tables = tables, audit = do.call(rbind, audits),
       errors = if (length(errors)) do.call(rbind, errors) else data.frame(),
       draws = draws, draw_metadata = .aaf_bind_draw_metadata(draw_metadata))
}

# ---- injuries (explicit two-component HED, beta1 shared, no former excess) ----
compute_injury_aaf_from_registry <- function(
    registry, g_fem_hed_list, g_male_hed_list,
    p_abs_list_fem, p_abs_list_male, p_form_list_fem, p_form_list_male,
    p_hed_list_fem, p_hed_list_male,
    x_vals_nhed = seq(0.1, 150, length.out = 1500),
    years = c(2008, 2010, 2012, 2014, 2016, 2018, 2020, 2022), age_groups = 1:4,
    prev_method = "dirichlet", neff = 1000, design_factor = 1.35,
    neff_consumption = NULL, design_factor_consumption = 1, fd_uncertainty = FALSE,
    n_sim = 10000, n_pca = 1000, seed = 2125, n_cores = NULL, use_parallel = TRUE,
    target_output_names = NULL, stop_on_error = FALSE, return_sims = FALSE) {
  targets <- data.frame(
    output_name = c("ri_fem", "ri_male", "injuries_fem", "injuries_male", "violence_fem", "violence_male"),
    source_object = c("injuries_MVA", "injuries_MVA", "injuries_other_unit", "injuries_other_unit",
                      "injuries_other_int", "injuries_other_int"),
    sex = c("female", "male", "female", "male", "female", "male"),
    pipeline_disease = c("Road Injuries", "Road Injuries", "Unintentional Injuries",
                         "Unintentional Injuries", "Intentional Injuries", "Intentional Injuries"),
    stringsAsFactors = FALSE)
  if (!is.null(target_output_names)) targets <- targets[targets$output_name %in% target_output_names, , drop = FALSE]
  if (!nrow(targets)) stop("No injury outputs selected.")

  tables <- list(); audits <- list(); errors <- list()
  draws <- list(); draw_metadata <- list()
  for (i in seq_len(nrow(targets))) {
    sex <- targets$sex[[i]]; output_name <- targets$output_name[[i]]
    prefix <- if (sex == "female") "Fem" else "Male"
    record <- .aaf_find_one(registry, source_object = targets$source_object[[i]], sex = sex)
    record$pipeline_disease <- targets$pipeline_disease[[i]]
    g_hed_list <- if (sex == "female") g_fem_hed_list else g_male_hed_list
    p_abs_list <- if (sex == "female") p_abs_list_fem else p_abs_list_male
    p_form_list <- if (sex == "female") p_form_list_fem else p_form_list_male
    p_hed_list <- if (sex == "female") p_hed_list_fem else p_hed_list_male
    run <- .aaf_run_hed_table(output_name, prefix, function(g) record, g_hed_list,
      p_abs_list, p_form_list, p_hed_list, x_vals_nhed, years, age_groups,
      hed_mode = "explicit", fd_uncertainty = fd_uncertainty, prev_method = prev_method,
      neff = neff, design_factor = design_factor, neff_consumption = neff_consumption,
      design_factor_consumption = design_factor_consumption,
      n_sim = n_sim, n_pca = n_pca, seed = seed, n_cores = n_cores,
      use_parallel = use_parallel, stop_on_error = stop_on_error,
      return_sims = return_sims)
    run$out$disease <- record$pipeline_disease
    tables[[output_name]] <- run$out
    if (base::length(run$draws)) draws <- base::c(draws, run$draws)
    if (base::nrow(run$draw_metadata)) {
      draw_metadata[[base::length(draw_metadata) + 1L]] <- run$draw_metadata
    }
    audits[[length(audits) + 1L]] <- .aaf_audit_row(output_name, record, prefix, "explicit",
      prev_method, neff, design_factor, neff_consumption, design_factor_consumption,
      fd_uncertainty, n_sim, n_pca, seed, length(run$errors))
    if (length(run$errors)) {
      ed <- do.call(rbind, run$errors); ed$output_name <- output_name
      errors[[length(errors) + 1L]] <- ed
    }
  }
  list(tables = tables, audit = do.call(rbind, audits),
       errors = if (length(errors)) do.call(rbind, errors) else data.frame(),
       draws = draws, draw_metadata = .aaf_bind_draw_metadata(draw_metadata))
}

# =============================================================================
# COARSE-GRAINED (CELL-LEVEL) PARALLEL DRIVER
# -----------------------------------------------------------------------------
# Problem this solves: compute_*_aaf_from_registry() loop year x age x cause x sex
# SEQUENTIALLY, and each cell calls aaf_confint(), which on Windows spins up and
# tears down its OWN PSOCK cluster for the INNER Monte-Carlo loop. With ~1300 cells
# that is ~1300 makeCluster()/stopCluster() cycles, each parallelising only a few
# seconds of tiny per-sim work over the even-half-capped ~16 workers while the rest
# of the machine idles -> ~2x effective speedup out of 16 cores (poor efficiency).
#
# This driver INVERTS the parallelism granularity: ONE persistent, load-balanced
# PSOCK cluster runs the ~1300 INDEPENDENT cells, each cell's MC serial inside its
# worker. It changes NO number (bit-for-bit): every cell re-seeds its own L'Ecuyer
# streams from the fixed `seed` in .aaf_make_streams(), so a cell's output is a pure
# function of its inputs, independent of which worker runs it or in what order. That
# is the same serial==parallel invariant the engine already relies on.
#
# It does NOT touch the estimator, the public signatures, the object names, or the
# table structure. It works by SHADOWING aaf_confint() in the engine's own env so the
# UNMODIFIED family functions still drive cell selection, .aaf_resolve_cell knob
# resolution, input picking, skip logic, min() clamps, and audit/error assembly:
#   PASS 1 (collect): aaf_confint -> a collector that records each cell's fully
#                     resolved argument list (fast, no MC), in call order.
#   RUN            :  all cells run on ONE clusterApplyLB cluster; each worker calls
#                     the REAL aaf_confint(..., use_parallel=FALSE, n_cores=1) so the
#                     inner MC runs serially (the n_cores==1 path, bit-identical to
#                     the parallel path).
#   PASS 2 (replay):  aaf_confint -> a replayer that returns each precomputed result;
#                     a failed cell is returned as a condition object, so the families'
#                     own tryCatch(inherits(res,"error")) branch records and skips it
#                     EXACTLY as in the sequential run.
#
# Worker setup: each worker source()s the engine file (which defines aaf_confint + all
# .aaf_* helpers and checks for MASS). RR-curve closures travel serialized with each
# task (their private registry env is carried along), so the RR registry does NOT need
# re-sourcing on workers; pass extra files via `worker_source` only if a closure
# resolves a symbol through the global environment.
#
# IMPORTANT: byte-for-byte equality with the sequential run holds IFF the engine's
# serial==parallel invariant holds. Verify it once on a handful of real cells (compare
# aaf_confint(use_parallel=FALSE) vs the old parallel result) before trusting a full run.
# =============================================================================

# Best-effort capture of THIS file's path at source() time, so run_aaf_cells_parallel
# can default `engine_file` and hand it to the workers. NULL if it cannot be inferred
# (e.g. sourced without a path) -> the caller must then pass engine_file explicitly.
.aaf_engine_file <- local({
  p <- NULL
  for (i in rev(seq_len(sys.nframe()))) {
    of <- sys.frame(i)$ofile
    if (!is.null(of) && is.character(of) && nzchar(of)) { p <- of; break }
  }
  if (is.null(p)) NULL else tryCatch(normalizePath(p, winslash = "/"), error = function(e) p)
})

run_aaf_cells_parallel <- function(
    run_families,                                          # zero-arg thunk: runs the family compute_* calls
    engine_file   = .aaf_engine_file,                      # path to aaf_unified.R (sourced on each worker)
    n_cores       = parallel::detectCores(logical = TRUE) - 1L,  # OUTER workers (NOT even-half capped)
    worker_source = NULL,                                  # extra file(s) to source on each worker (rarely needed)
    pilot         = NULL,                                  # list(n_sim=, n_pca=) -> PROVISIONAL fast run (MC noise only)
    verbose       = TRUE
) {
  .t0 <- Sys.time()
  if (!is.function(run_families)) stop("run_families must be a zero-arg function (thunk).")
  env <- environment(aaf_confint)
  if (!identical(env, environment(compute_aaf_from_rr_record))) {
    stop("aaf_confint and compute_* live in different environments; collect/replay interception is unsafe.")
  }
  real_fn <- get("aaf_confint", envir = env)
  on.exit(assign("aaf_confint", real_fn, envir = env), add = TRUE)  # always un-shadow, even on error

  # ---- PASS 1: collect fully-resolved per-cell argument lists, in call order ----
  tasks <- list(); k <- 0L
  collector <- function(...) {
    k <<- k + 1L
    tasks[[k]] <<- list(...)
    list(point_estimate = NA_real_, lower_ci = NA_real_, upper_ci = NA_real_, n_used = 0L)
  }
  assign("aaf_confint", collector, envir = env)
  invisible(run_families())
  assign("aaf_confint", real_fn, envir = env)
  n_tasks <- length(tasks)
  if (!n_tasks) stop("No AAF cells were collected; check run_families().")
  if (isTRUE(verbose)) {
    message(sprintf("[run_aaf_cells_parallel] collected %d cells in %.2f min.",
                    n_tasks, as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
  }

  # ---- optional PILOT down-scaling (reduces Monte-Carlo draws only, same estimator) ----
  if (!is.null(pilot)) {
    tasks <- lapply(tasks, function(a) {
      if (!is.null(pilot$n_sim)) a$n_sim <- pilot$n_sim
      if (!is.null(pilot$n_pca)) a$n_pca <- pilot$n_pca
      a
    })
    message("[run_aaf_cells_parallel] PILOT MODE: reduced n_sim/n_pca -> CIs are PROVISIONAL, not final. ",
            "If neff_consumption is set it (not n_pca) governs the gamma resample size.")
  }

  # ---- RUN: real aaf_confint per cell, INNER MC forced serial, ONE cluster ----
  # CRITICAL for Windows PSOCK: the heavy objects in each task are the RR closures
  # (rr_fun / rr_fun_hed). Each carries its whole sys.source()'d registry environment
  # (all RR functions + kept srcrefs) because rr_registry_adam.R builds them with
  # new.env(parent = globalenv()) + sys.source(..., keep.source = TRUE). Serialising
  # that into EVERY one of ~1300 tasks is what makes a naive clusterApplyLB crawl for
  # hours (and hang if a worker OOMs). So DE-DUPLICATE: there are only a handful of
  # distinct RR closures (one per disease x sex), reused across all year x age cells.
  # Ship the unique closures to each worker ONCE via clusterExport (a single serialise
  # per worker, with shared registry envs written once), strip them out of the tasks,
  # and let each task carry a tiny integer index the worker uses to re-attach them.
  .aaf_dedup_field <- function(tk, field) {
    uniq <- list(); idx <- integer(length(tk))
    for (t in seq_along(tk)) {
      f <- tk[[t]][[field]]
      if (is.null(f)) { idx[t] <- 0L; next }
      hit <- 0L
      for (u in seq_along(uniq)) if (identical(uniq[[u]], f)) { hit <- u; break }
      if (hit == 0L) { uniq[[length(uniq) + 1L]] <- f; hit <- length(uniq) }
      idx[t] <- hit
      tk[[t]][[field]] <- NULL   # strip the heavy closure out of the task payload
    }
    list(tk = tk, uniq = uniq, idx = idx)
  }
  n_use <- max(1L, min(as.integer(n_cores), n_tasks))
  .t1 <- Sys.time()
  results <- if (n_use == 1L) {
    # serial path on the master: call the captured real engine directly (no de-dup needed)
    lapply(tasks, function(a) tryCatch(
      do.call(real_fn, utils::modifyList(a, list(use_parallel = FALSE, n_cores = 1L))),
      error = function(e) e))
  } else {
    if (is.null(engine_file) || !file.exists(engine_file)) {
      stop("engine_file not found. Pass engine_file = path to aaf_unified.R (workers must source it).")
    }
    worker_source <- unique(c(normalizePath(engine_file, winslash = "/"),
                              if (!is.null(worker_source)) normalizePath(worker_source, winslash = "/")))
    d1 <- .aaf_dedup_field(tasks, "rr_fun")
    d2 <- .aaf_dedup_field(d1$tk, "rr_fun_hed")
    light_tasks <- d2$tk
    for (t in seq_along(light_tasks)) {
      light_tasks[[t]]$.rr_idx    <- d1$idx[t]
      light_tasks[[t]]$.rrhed_idx <- d2$idx[t]
    }
    .aaf_rr_pool    <- d1$uniq   # unique rr_fun closures (shared registry envs -> serialised once)
    .aaf_rrhed_pool <- d2$uniq   # unique rr_fun_hed closures (injuries explicit HED)
    if (isTRUE(verbose)) {
      message(sprintf("[run_aaf_cells_parallel] de-duplicated RR closures: %d rr_fun + %d rr_fun_hed for %d cells (was shipping %d).",
                      length(.aaf_rr_pool), length(.aaf_rrhed_pool), n_tasks, n_tasks))
    }
    # Tiny worker closure (globalenv-bound so serialisation drags nothing extra):
    # re-attach the RR closures from the exported pools, then run the real engine serially.
    run_one <- function(a) {
      if (!is.null(a$.rr_idx)    && a$.rr_idx    > 0L) a$rr_fun     <- .aaf_rr_pool[[a$.rr_idx]]
      if (!is.null(a$.rrhed_idx) && a$.rrhed_idx > 0L) a$rr_fun_hed <- .aaf_rrhed_pool[[a$.rrhed_idx]]
      a$.rr_idx <- NULL; a$.rrhed_idx <- NULL
      tryCatch(do.call(aaf_confint, utils::modifyList(a, list(use_parallel = FALSE, n_cores = 1L))),
               error = function(e) e)
    }
    environment(run_one) <- globalenv()
    cl <- parallel::makeCluster(n_use)
    on.exit(try(parallel::stopCluster(cl), silent = TRUE), add = TRUE)
    parallel::clusterExport(cl, c("worker_source", ".aaf_rr_pool", ".aaf_rrhed_pool"), envir = environment())
    parallel::clusterEvalQ(cl, { for (.f in worker_source) source(.f); TRUE })
    parallel::clusterApplyLB(cl, light_tasks, run_one)   # results returned in task order
  }
  if (isTRUE(verbose)) {
    message(sprintf("[run_aaf_cells_parallel] ran %d cells on %d workers in %.2f min.",
                    n_tasks, n_use, as.numeric(difftime(Sys.time(), .t1, units = "mins"))))
  }

  # ---- PASS 2: replay real results through the UNMODIFIED family code ----
  # Reset the flag log so aaf_error_log() reflects ONLY this real pass, not the
  # PASS-1 collection (whose skipped cells would otherwise be double-counted).
  aaf_error_log_reset()
  j <- 0L
  replayer <- function(...) { j <<- j + 1L; results[[j]] }
  assign("aaf_confint", replayer, envir = env)
  out <- run_families()
  assign("aaf_confint", real_fn, envir = env)
  if (j != length(results)) {
    warning(sprintf("[run_aaf_cells_parallel] replay consumed %d of %d results; cell call order diverged between passes.",
                    j, length(results)))
  }
  if (isTRUE(verbose)) {
    message(sprintf("[run_aaf_cells_parallel] TOTAL %.2f min.",
                    as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
  }
  out
}
