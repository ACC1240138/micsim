# =============================================================================
# Alcohol transitions - ENPG Chile (pseudo-panel + ordinal transitions)
# =============================================================================

pacman::p_load(tidyverse,
               stringr,
               MASS)
load("Alcohol Transitions FINAL.RData")
# -----------------------------------------------------------------------------
# 0) Diccionario único de estados (CANÓNICO)
# -----------------------------------------------------------------------------
ALC_LEVELS <- c("Non-drinker", "Cat1", "Cat2", "Cat3")
years_train <- 2008:2016
years_calib <- c(2018, 2020, 2022)
years_sim   <- 2008:2022

recode_enpg_cvolaj_to_state <- function(x) {
  # x: cvolaj crudo ENPG: ltabs/fd/cat1/cat2/cat3
  dplyr::case_when(
    x %in% c("ltabs", "fd") ~ "Non-drinker",
    x == "cat1" ~ "Cat1",
    x == "cat2" ~ "Cat2",
    x == "cat3" ~ "Cat3",
    TRUE ~ NA_character_
  )
}

as_state_factor <- function(x) {
  # Convierte strings a factor ordenado con niveles canónicos
  factor(x, levels = ALC_LEVELS, ordered = TRUE)
}

# -----------------------------------------------------------------------------
# 1) Preprocesamiento ENPG para alcohol (para pseudo-panel)
#    - aquí generamos: id, year, sex, agecat, gpd, state_ord (canónico)
# -----------------------------------------------------------------------------
preprocess_enpg_alcohol <- function(enpg) {
  
  enpg |>
    dplyr::mutate(
      id = dplyr::row_number(),   # <- OJO: era nrow(data), eso está MAL
      sex = dplyr::case_when(
        sexo == "Hombre" ~ "M",
        sexo == "Mujer"  ~ "F",
        TRUE ~ NA_character_
      ),
      agecat = factor(edad_tramo),
      gpd = as.numeric(volajohdia),
      
      state_ord = recode_enpg_cvolaj_to_state(cvolaj),
      state_ord = as_state_factor(state_ord),
      
      former_drinker = ifelse(cvolaj == "fd", 1L, 0L),
      lifetime_abstainer = ifelse(cvolaj == "ltabs", 1L, 0L)
    ) |>
    dplyr::filter(
      !is.na(year),
      !is.na(sex),
      !is.na(agecat),
      !is.na(gpd),
      !is.na(state_ord)
    ) |>
    dplyr::select(
      id, year, exp,sex, agecat, gpd, state_ord,
      former_drinker, lifetime_abstainer, hed
    )
}

# -----------------------------------------------------------------------------
# 2) Pseudo-panel por pares (t, t+2): rank matching dentro de (sex, agecat)
# -----------------------------------------------------------------------------
make_pseudopanel_pair <- function(df_t, df_t2, seed = 1L) {
  set.seed(seed)
  
  a <- df_t |>
    transmute(
      id_t = id,
      sex, agecat,
      year_t = year,
      gpd_t = gpd,
      state_t = state_ord,
      hed_t = hed
    )
  
  b <- df_t2 |>
    transmute(
      id_t2 = id,
      sex, agecat,
      year_t2 = year,
      gpd_t2 = gpd,
      state_t2 = state_ord,
      hed_t2 = hed
    )
  
  a |>
    group_by(sex, agecat) |>
    arrange(gpd_t, .by_group = TRUE) |>
    mutate(
      n_t = n(),
      rank_t = row_number(),
      u = (rank_t - 0.5) / n_t
    ) |>
    ungroup() |>
    left_join(
      b |>
        group_by(sex, agecat) |>
        arrange(gpd_t2, .by_group = TRUE) |>
        mutate(
          n_t2 = n(),
          rank_t2 = row_number()
        ) |>
        ungroup(),
      by = c("sex", "agecat"),
      relationship = "many-to-many"
    ) |>
    group_by(id_t) |>
    mutate(
      target_rank = pmin(pmax(round(u * n_t2), 1), n_t2),
      dist = abs(rank_t2 - target_rank)
    ) |>
    slice_min(dist, with_ties = TRUE) |>
    slice_sample(n = 1) |>
    ungroup() |>
    dplyr::select(
      id_t, sex, agecat,
      year_t, state_t, gpd_t, hed_t,
      year_t2, state_t2, gpd_t2, hed_t2
    )
}

make_pseudopanel_all <- function(enpg_train,
                                 years = seq(2008, 2016, by = 2),
                                 seed = 1L) {
  stopifnot(all(years %in% unique(enpg_train$year)))
  
  panels <- lapply(seq_len(length(years) - 1), function(i) {
    y1 <- years[i]
    y2 <- years[i + 1]
    df_t  <- enpg_train |> filter(year == y1)
    df_t2 <- enpg_train |> filter(year == y2)
    make_pseudopanel_pair(df_t, df_t2, seed = seed)
  })
  
  bind_rows(panels) |>
    mutate(dt = year_t2 - year_t)
}

# -----------------------------------------------------------------------------
# 3) Ajuste del modelo ordinal "final"
#    Nota: para ORs tipo Lancet, state_t como factor nominal (no ordered)
# -----------------------------------------------------------------------------
fit_alcohol_ordinal_final <- function(pp) {
  
  pp2 <- pp |>
    mutate(
      # outcome ordinal
      state_t2 = factor(as.character(state_t2), levels = ALC_LEVELS, ordered = TRUE),
      # predictor nominal (dummies por categoría vs Non-drinker)
      state_t  = factor(as.character(state_t), levels = ALC_LEVELS),
      
      sex = factor(sex),
      agecat = factor(agecat)
    )
  
  MASS::polr(
    state_t2 ~ state_t*agecat + state_t*sex + sex*agecat,
    data = pp2,
    Hess = TRUE
  )
}

# -----------------------------------------------------------------------------
# 4) Transición 1 paso en la población simulada
#    CONTRATO POP:
#      - pop$cvolaj debe estar en niveles canónicos (Non-drinker/Cat1/Cat2/Cat3)
#      - pop$sex, pop$agecat deben existir
# -----------------------------------------------------------------------------
scale_probs <- function(probs, alpha) {
  logp <- log(probs)
  logp_scaled <- alpha * logp
  exp(logp_scaled) / rowSums(exp(logp_scaled))
}

transition_alcohol_step <- function(pop, model, alpha = 0.5,
                                    theta = NULL, seed = NULL) {
  if (!is.null(seed)) set.seed(seed)
  
  pop <- pop |> dplyr::mutate(cvolaj_prev = cvolaj)
  
  nd <- pop |>
    dplyr::transmute(
      state_t = factor(as.character(cvolaj), levels = ALC_LEVELS),
      sex = factor(sex),
      agecat = factor(agecat)
    )
  
  probs <- predict(model, newdata = nd, type = "probs")
  probs <- scale_probs(probs, alpha = alpha)
  
  if (!is.null(theta)) {
    probs <- apply_destination_offsets(probs, theta)
  }
  
  u <- runif(nrow(pop))
  cum <- t(apply(probs, 1, cumsum))
  idx <- max.col(cum >= u, ties.method = "first")
  
  pop$cvolaj <- factor(colnames(probs)[idx],
                       levels = ALC_LEVELS,
                       ordered = TRUE)
  
  pop
}

# -----------------------------------------------------------------------------
# 5) Utilidad: preparar baseline_pop (muy importante)
#    Esto debe ejecutarse UNA VEZ, antes de simular.
# -----------------------------------------------------------------------------
prepare_baseline_pop_alcohol <- function(baseline_pop,
                                         cvolaj_col = "cvolaj") {
  
  stopifnot(cvolaj_col %in% names(baseline_pop))
  stopifnot(all(c("sex","agecat") %in% names(baseline_pop)))
  
  out <- baseline_pop |>
    dplyr::mutate(
      cvolaj = recode_enpg_cvolaj_to_state(.data[[cvolaj_col]]),
      cvolaj = as_state_factor(cvolaj)
    )
  
  # chequeo explícito
  if (any(is.na(out$cvolaj))) {
    bad_vals <- unique(baseline_pop[[cvolaj_col]][is.na(out$cvolaj)])
    stop(
      "prepare_baseline_pop_alcohol(): valores no mapeados en cvolaj: ",
      paste(bad_vals, collapse = ", ")
    )
  }
  
  out
}

# IMPLEMENTACIÓN DEL FLUJO

# 1) limpiar ENPG
enpg_clean <- preprocess_enpg_alcohol(data)
enpg_train <- enpg_clean |>
  dplyr::filter(year %in% years_train)
# 2) pseudo-panel
pp <- make_pseudopanel_all(enpg_train, seed = 1)

# 3) modelo ordinal final
model_ord_final <- fit_alcohol_ordinal_final(pp)
summary(model_ord_final)

# 4) una transición y auditoría
sim1 <- transition_alcohol_step(baseline_pop, model_ord_final, seed = 1)

sim_1step <- transition_alcohol_step(
  baseline_pop, model_ord_final, alpha = 0.5, seed = 1
)

sim_2steps <- transition_alcohol_step(
  sim_1step, model_ord_final, alpha = 0.5, seed = 2
)

tab1 <- prop.table(table(baseline_pop$cvolaj, sim_1step$cvolaj), 1)
tab2 <- prop.table(table(baseline_pop$cvolaj, sim_2steps$cvolaj), 1)

tab1
tab2



age_transition_step <- function(pop) {
  pop |>
    dplyr::mutate(
      agecat = as.integer(as.character(agecat)),
      agecat = dplyr::case_when(
        agecat < max(agecat) ~ agecat + 1L,
        TRUE ~ agecat
      ),
      agecat = factor(agecat)
    )
}


# ⚠️ Supuesto fuerte, pero aceptable para MVP.
# Luego lo reemplazamos por edad continua.

#️ Función de simulación multi-año
run_simulation_alcohol <- function(pop0,
                                   model_ord,
                                   years = 2008:2022,
                                   alpha = 0.5,
                                   seed = 1) {
  
  set.seed(seed)
  
  pop <- pop0 |>
    dplyr::mutate(year = min(years))
  
  out_list <- list()
  out_list[[as.character(min(years))]] <- pop
  
  for (y in years[-1]) {
    
    pop <- pop |>
      age_transition_step() |>
      transition_alcohol_step(
        model = model_ord,
        alpha = alpha,
        seed = seed + y
      ) |>
      dplyr::mutate(year = y)
    
    out_list[[as.character(y)]] <- pop
  }
  
  dplyr::bind_rows(out_list)
}


# 3️⃣ Correr la simulación
sim_all <- run_simulation_alcohol(
  pop0 = baseline_pop,
  model_ord = model_ord_final,
  years = 2008:2022,
  seed = 123
)

stopifnot(!any(is.na(sim_all$cvolaj)))

# 4️⃣ Agregación: prevalencias simuladas
# A nivel ENPG (bienes bianuales)
sim_prev <- sim_all |>
  dplyr::filter(year %in% years_calib) |>
  dplyr::count(year, sex, agecat, cvolaj, name = "n_sim") |>
  dplyr::group_by(year, sex, agecat) |>
  dplyr::mutate(p_sim = n_sim / sum(n_sim)) |>
  dplyr::ungroup()

# 5️⃣ Prevalencias observadas ENPG (comparables)

# TOTAL SIMULADO (desde microdatos simulados)
sim_total <- sim_all |>
  dplyr::filter(year %in% years_calib) |>
  dplyr::count(year, cvolaj, name = "n_sim") |>
  dplyr::group_by(year) |>
  dplyr::mutate(p_sim = n_sim / sum(n_sim)) |>
  dplyr::ungroup()

# TOTAL OBSERVADO (ponderado por exp)
obs_total <- enpg_clean |>
  dplyr::filter(year %in% years_calib) |>
  dplyr::group_by(year, state_ord) |>
  dplyr::summarise(n_obs = sum(exp, na.rm = TRUE), .groups = "drop") |>
  dplyr::group_by(year) |>
  dplyr::mutate(p_obs = n_obs / sum(n_obs)) |>
  dplyr::ungroup() |>
  dplyr::rename(cvolaj = state_ord)

comp_total <- dplyr::full_join(sim_total, obs_total, by = c("year", "cvolaj"))


# 7️⃣ Inspección visual (primer gráfico clave)
# Total población (colapsando sexo/edad)
library(ggplot2)

ggplot(comp_total, aes(x = year)) +
  geom_line(aes(y = p_obs, color = "Observado"), linewidth = 1) +
  geom_point(aes(y = p_obs, color = "Observado"), size = 2) +
  geom_line(aes(y = p_sim, color = "Simulado"),
            linewidth = 1,
            linetype = "dashed") +
  geom_point(aes(y = p_sim, color = "Simulado"), size = 2) +
  facet_wrap(~ cvolaj, scales = "free_y") +
  scale_color_manual(values = c(
    "Observado" = "black",
    "Simulado"  = "red"
  )) +
  labs(
    x = "Año",
    y = "Prevalencia",
    color = ""
  ) +
  theme_minimal()



# REVISION DE LOS SIMS
# TOTAL SIMULADO (desde microdatos simulados)
sim_total <- sim_all |>
  dplyr::filter(year %in% seq(2008, 2022, by = 2)) |>
  dplyr::count(year, cvolaj, name = "n_sim") |>
  dplyr::group_by(year) |>
  dplyr::mutate(p_sim = n_sim / sum(n_sim)) |>
  dplyr::ungroup()

# TOTAL OBSERVADO (ponderado por exp)
obs_total <- enpg_clean |>
  dplyr::filter(year %in% seq(2008, 2022, by = 2)) |>
  dplyr::group_by(year, state_ord) |>
  dplyr::summarise(n_obs = sum(exp, na.rm = TRUE), .groups = "drop") |>
  dplyr::group_by(year) |>
  dplyr::mutate(p_obs = n_obs / sum(n_obs)) |>
  dplyr::ungroup() |>
  dplyr::rename(cvolaj = state_ord)

comp_total <- dplyr::full_join(sim_total, obs_total, by = c("year", "cvolaj"))


obs_long <- enpg_clean |>
  filter(year %in% 2008:2014) %>% 
  dplyr::group_by(year, sex, agecat, state_ord,hed) |>
  dplyr::summarise(
    n = sum(.data$exp, na.rm = TRUE),
    .groups = "drop"
  ) |>
  dplyr::group_by(year, sex, agecat) |>
  dplyr::mutate(p = n / sum(n)) |>
  dplyr::ungroup() |>
  dplyr::rename(cvolaj = state_ord) |>
  dplyr::mutate(
    source = "ENPG observada",
    linetype = "Observado"
  )

pseudo_long <- pp |>
  dplyr::group_by(year = year_t, sex, hed = hed_t,agecat, cvolaj = state_t) |>
  dplyr::summarise(
    n = n(),
    .groups = "drop"
  ) |>
  dplyr::group_by(year, sex, agecat) |>
  dplyr::mutate(p = n / sum(n)) |>
  dplyr::ungroup() |>
  dplyr::mutate(
    source = "Pseudo-longitudinal",
    linetype = "Pseudo"
  )

plot_df <- dplyr::bind_rows(obs_long, pseudo_long)
plot_df <- plot_df |>
  dplyr::mutate(
    hed = factor(hed, levels = c(0, 1), labels = c("No HED", "HED")),
    sex = factor(sex, levels = c("F", "M")),
    agecat = factor(agecat, levels = 1:4, labels = c("15-29", "30-44", "45-59", ">60"))
  )
ggplot(
  plot_df,
  aes(
    x = year,
    y = p,
    color = cvolaj,
    linetype = linetype,
    group = interaction(cvolaj, source)
  )
) +
  geom_line(linewidth = 0.9) +
  facet_grid(
    agecat ~ sex + hed
  ) +
  scale_linetype_manual(
    values = c(
      "Observado" = "dashed",
      "Pseudo"    = "solid"
    )
  ) +
  scale_y_continuous(
    limits = c(0, 1),
    labels = scales::percent_format(accuracy = 1)
  ) +
  labs(
    x = "Año",
    y = "Proporción",
    color = "Categoría de consumo",
    linetype = ""
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "bottom",
    strip.text = element_text(face = "bold"),
    strip.background = element_rect(fill = "grey90", color = NA)
  )


