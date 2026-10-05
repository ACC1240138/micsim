###############
# Calibration #
###############

library(dplyr)
library(tidyr)
library(MASS)

ALC_LEVELS <- c("Non-drinker","Cat1","Cat2","Cat3")

make_obs_prev <- function(enpg_clean) {
  enpg_clean |>
    group_by(year, sex, agecat, state_ord) |>
    summarise(n = sum(.data$exp, na.rm = TRUE), .groups = "drop") |>
    group_by(year, sex, agecat) |>
    mutate(p_obs = n / sum(n)) |>
    ungroup() |>
    transmute(year, sex, agecat, cvolaj = as.character(state_ord), p_obs) |>
    mutate(cvolaj = factor(cvolaj, levels = ALC_LEVELS, ordered = TRUE))
}

obs_prev <- make_obs_prev(enpg_clean)
# 2) Helper: correr simulación y devolver prevalencias simuladas
# Este wrapper corre la microsim y devuelve p_sim en el mismo formato que obs_prev. (Mantenlo “agregado”, no devuelvas microdatos.)

age_transition_step <- function(pop) {
  # MVP: si no tienes edad continua, reemplaza por tu lógica real
  pop |>
    mutate(
      agecat = as.integer(as.character(agecat)),
      agecat = ifelse(agecat < max(agecat), agecat + 1L, agecat),
      agecat = factor(agecat)
    )
}

run_sim_alcohol_prev <- function(pop0, model, years, calib, seed = 1L) {
  set.seed(seed)
  pop <- pop0 |> mutate(year = min(years))
  
  for (y in years[-1]) {
    pop <- pop |>
      age_transition_step() |>
      transition_alcohol_step_calib(pop = _, model = model, calib = calib, seed = seed + y) |>
      mutate(year = y)
  }
  
  pop |>
    filter(year %in% seq(min(years), max(years), by = 2)) |>
    count(year, sex, agecat, cvolaj, name = "n") |>
    group_by(year, sex, agecat) |>
    mutate(p_sim = n / sum(n)) |>
    ungroup() |>
    dplyr::select(year, sex, agecat, cvolaj, p_sim)
}
# 3) TRANSICIÓN calibrable (cambio mínimo)
# Aquí está la versión que aplica calibración sobre las probabilidades del ordinal. Implemento los tres esquemas así:
# global: suma delta al predictor lineal eta

# bycat: suma delta_k dependiendo del estado previo (state_t) para afectar persistencia/movilidad de forma simple
# (parsimonioso, pero ojo: no es idéntico a “shift por outcome”; es una aproximación estable)
# cutpoints: desplaza los umbrales zeta_j por kappa_j (lo más “correcto” para ordinal)

# Nota: para cutpoints, polr guarda los umbrales en model$zeta. Esta aproximación mantiene beta fijo y ajusta zeta.
get_design_matrix <- function(model, newdata) {
  Terms <- delete.response(terms(model))
  model.matrix(Terms, newdata)
}
# Construye X y eta para polr manteniendo coeficientes fijos
polr_linear_predictor <- function(model, newdata) {
  
  X <- model.matrix(
    delete.response(terms(model_ord_final)),
    nd
  )
  
  # eliminar intercepto explícitamente
  X <- X[, colnames(X) != "(Intercept)", drop = FALSE]
  
  beta <- model_ord_final$coefficients
  
  stopifnot(
    ncol(X) == length(beta),
    all(colnames(X) == names(beta))
  )
  
  eta <- as.vector(X %*% beta)
}
# Convierte eta + zetas a probs (K=4)
polr_probs_from_eta <- function(eta, zeta) {
  # zeta: vector length K-1 with names like "Non-drinker|Cat1", ...
  z1 <- zeta[1]; z2 <- zeta[2]; z3 <- zeta[3]
  p1 <- plogis(z1 - eta)
  p2 <- plogis(z2 - eta)
  p3 <- plogis(z3 - eta)
  cbind(
    "Non-drinker" = p1,
    "Cat1"        = p2 - p1,
    "Cat2"        = p3 - p2,
    "Cat3"        = 1 - p3
  )
}

transition_alcohol_step_calib <- function(pop, model, calib, seed = NULL) {
  if (!is.null(seed)) set.seed(seed)
  
  nd <- baseline_pop |>
    dplyr::mutate(
      state_t = factor(
        as.character(cvolaj),
        levels = levels(model_ord_final$model$state_t)
      ),
      sex = factor(
        sex,
        levels = levels(model_ord_final$model$sex)
      ),
      agecat = factor(
        agecat,
        levels = levels(model_ord_final$model$agecat)
      )
    ) |>
    as.data.frame()
  
  # eta base + zetas base
  nd <- nd %>% dplyr::select("state_t", "sex", "agecat")  
  eta <- polr_linear_predictor(model, nd)
  zeta <- model$zeta
  
  # --- aplicar esquema de calibración ---
  if (calib$type == "global") {
    eta <- eta + calib$delta
  }
  
  if (calib$type == "bycat") {
    # delta por estado previo (Non, Cat1, Cat2, Cat3)
    dmap <- calib$delta_state
    # asegurar nombres
    stopifnot(all(ALC_LEVELS %in% names(dmap)))
    eta <- eta + unname(dmap[as.character(pop$state_t)])
  }
  
  if (calib$type == "cutpoints") {
    # kappa para zeta1,zeta2,zeta3
    k <- calib$kappa
    stopifnot(length(k) == 3)
    zeta <- zeta + k
  }
  
  probs <- polr_probs_from_eta(eta, zeta)
  
  # muestreo
  u <- runif(nrow(pop))
  cum <- probs
  cum[,2] <- cum[,1] + cum[,2]
  cum[,3] <- cum[,2] + cum[,3]
  cum[,4] <- 1
  idx <- max.col(cum >= u, ties.method = "first")
  
  pop$cvolaj <- factor(colnames(probs)[idx], levels = ALC_LEVELS, ordered = TRUE)
  pop
}
# 4) Función de pérdida (loss) y helper para comparar con obs
# Para empezar, uso SSE sobre prevalencias agregadas (puedes ponderar por tamaño si quieres).

make_loss <- function(sim_prev, obs_prev) {
  df <- sim_prev |>
    left_join(obs_prev, by = c("year","sex","agecat","cvolaj")) |>
    filter(!is.na(p_obs))
  
  # SSE
  sum((df$p_sim - df$p_obs)^2)
}
# 5) Calibración determinista para cada esquema
# 5.1 Shift global (1 parámetro)

calibrate_global <- function(pop0, model, years, obs_prev, seed = 1L,
                             lower = -5, upper = 5) {
  
  f <- function(delta) {
    sim_prev <- run_sim_alcohol_prev(pop0, model, years, calib = list(type="global", delta=delta), seed = seed)
    make_loss(sim_prev, obs_prev)
  }
  
  opt <- optim(par = 0, fn = f, method = "Brent", lower = lower, upper = upper)
  list(opt = opt, calib = list(type="global", delta = opt$par))
}
# 5.2 Shift por estado previo (4 parámetros, pero fijamos Non-drinker = 0 para identificabilidad → 3 parámetros)



nd <- nd[, c("state_t", "sex", "agecat"), drop = FALSE]


nd <- baseline_pop[, c("state_t", "sex", "agecat"), drop = FALSE]

X <- model.matrix(delete.response(terms(model_ord_final)), nd)
beta <- model_ord_final$coefficients

c(
  ncol_X = ncol(X),
  length_beta = length(beta)
)

setdiff(colnames(X), names(beta))
setdiff(names(beta), colnames(X))
calibrate_bycat <- function(pop0, model, years, obs_prev, seed = 1L) {
  
  f <- function(par) {
    d <- c("Non-drinker"=0, "Cat1"=par[1], "Cat2"=par[2], "Cat3"=par[3])
    sim_prev <- run_sim_alcohol_prev(pop0, model, years,
                                     calib = list(type="bycat", delta_state=d),
                                     seed = seed)
    make_loss(sim_prev, obs_prev)
  }
  if (nrow(nd) == 0) {
    return(pop)
  }
  opt <- optim(par = c(0,0,0), fn = f, method = "Nelder-Mead",
               control = list(maxit = 200))
  d <- c("Non-drinker"=0, "Cat1"=opt$par[1], "Cat2"=opt$par[2], "Cat3"=opt$par[3])
  list(opt = opt, calib = list(type="bycat", delta_state = d))
}
loss_fn <- function(comp) {
  
  comp |>
    dplyr::filter(!is.na(p_obs)) |>
    dplyr::summarise(
      loss = sum((p_sim - p_obs)^2)
    ) |>
    dplyr::pull(loss)
}
simulate_with_calibration <- function(baseline_pop,
                                      model_ord,
                                      years,
                                      theta,
                                      seed = NULL) {
  
  if (!is.null(seed)) set.seed(seed)
  
  pop <- baseline_pop
  
  # aquí vamos a guardar resultados por año
  out_list <- vector("list", length(years))
  names(out_list) <- years
  
  for (t in seq_along(years)) {
    
    year <- years[t]
    
    # 1. aplicar transición de alcohol (UN SOLO PASO)
    pop <- transition_alcohol_step_calib(
      pop   = pop,
      model = model_ord,
      theta = theta,
      seed  = seed + t
    )
    
    # 2. resumir prevalencias simuladas ESTE año
    sim_prev_t <- pop |>
      dplyr::count(sex, agecat, cvolaj, name = "n") |>
      dplyr::group_by(sex, agecat) |>
      dplyr::mutate(
        p_sim = n / sum(n),
        year  = year
      ) |>
      dplyr::ungroup() |>
      dplyr::select(year, sex, agecat, cvolaj, p_sim)
    
    # 3. guardar
    out_list[[t]] <- sim_prev_t
  }
  
  # 4. concatenar todos los años
  dplyr::bind_rows(out_list)
}
calibrate_global <- function(baseline_pop,
                             model_ord,
                             years,
                             obs_prev,
                             seed = NULL) {
  
  obj_fn <- function(theta) {
    
    sim_prev <- simulate_with_calibration(
      baseline_pop = baseline_pop,
      model_ord    = model_ord,
      years        = years,
      theta        = theta,
      seed         = seed
    )
    
    comp <- compare_to_observed(sim_prev, obs_prev)
    
    loss_fn(comp)
  }
  
  optim(
    par    = 0,
    fn     = obj_fn,
    method = "Brent",
    lower  = -5,
    upper  =  5
  )
}
# 5.3 Calibrar cutpoints (3 parámetros: κ₁, κ₂, κ₃)

calibrate_cutpoints <- function(pop0, model, years, obs_prev, seed = 1L) {
  
  f <- function(kappa) {
    sim_prev <- run_sim_alcohol_prev(pop0, model, years,
                                     calib = list(type="cutpoints", kappa = kappa),
                                     seed = seed)
    make_loss(sim_prev, obs_prev)
  }
  
  opt <- optim(par = c(0,0,0), fn = f, method = "Nelder-Mead",
               control = list(maxit = 300))
  list(opt = opt, calib = list(type="cutpoints", kappa = opt$par))
}
# 6) Ejecutar los tres y comparar

years <- 2008:2022   # ajusta si tu obs llega a 2024

fit_g <- calibrate_global(baseline_pop, model_ord_final, years, obs_prev, seed = 123)
fit_b <- calibrate_bycat (baseline_pop, model_ord_final, years, obs_prev, seed = 123)
fit_c <- calibrate_cutpoints(baseline_pop, model_ord_final, years, obs_prev, seed = 123)

fit_g$opt$value
fit_b$opt$value
fit_c$opt$value
# 7) Generar curvas comparables (para inspección visual)

get_comp <- function(calib) {
  sim_prev <- run_sim_alcohol_prev(baseline_pop, model_ord_final, years, calib = calib, seed = 123)
  sim_prev |>
    left_join(obs_prev, by = c("year","sex","agecat","cvolaj")) |>
    filter(!is.na(p_obs))
}

comp_g <- get_comp(fit_g$calib)
comp_b <- get_comp(fit_b$calib)
comp_c <- get_comp(fit_c$calib)
Un gráfico simple total (colapsando sex/age) para cada ajuste:
  
  r
Copiar código
library(ggplot2)

plot_comp_total <- function(comp, title) {
  df <- comp |>
    group_by(year, cvolaj) |>
    summarise(p_obs = mean(p_obs), p_sim = mean(p_sim), .groups="drop")
  
  ggplot(df, aes(x = year)) +
    geom_line(aes(y = p_obs), color = "black") +
    geom_line(aes(y = p_sim), color = "red") +
    facet_wrap(~cvolaj, scales="free_y") +
    theme_minimal() +
    labs(title = title, y = "Prevalencia", x = "Año")
}

plot_comp_total(comp_g, "Calibración: shift global")
plot_comp_total(comp_b, "Calibración: shift por estado previo")
plot_comp_total(comp_c, "Calibración: ajuste de cutpoints")