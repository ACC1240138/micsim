pacman::p_load(tidyverse, 
               tidyr, 
               purrr, 
               fixest, 
               rio, 
               stringr, 
               systemfit)


# =========================================================
# 0) PARÁMETROS
# =========================================================

EPS   <- 1e-8
GOODS <- c("Beer", "Wines", "Spirits")

Z_VARS <- c(
  "educ_hhh", "age_hhh", "sex_hhh",
  "npersonas", "prop_wm", "prop_15yo"
)

MIN_BUYERS_CLUSTER <- 10

# =========================================================
# 1) IMPORT
# =========================================================

data_epf <- rio::import("DATA_EPS_2217_LONG.rds")

df_long <- data_epf %>%
  mutate(
    year             = as.integer(year),
    folio_v          = as.character(folio_v),
    estrato_muestreo = as.character(estrato_muestreo),
    glosa            = as.character(glosa),
    hh_id            = interaction(folio_v, year, drop = TRUE),
    cluster          = interaction(estrato_muestreo, year, drop = TRUE),
    fe               = as.numeric(fe),
    hh_spend         = as.numeric(hh_spend),
    hh_quant         = as.numeric(hh_quant),
    unit_value       = as.numeric(unit_value),
    gastot_uf        = as.numeric(gastot_uf),
    ing_uf           = as.numeric(ing_uf),
    educ_hhh         = as.numeric(educ_hhh),
    age_hhh          = as.numeric(age_hhh),
    sex_hhh          = as.numeric(sex_hhh),
    npersonas        = as.numeric(npersonas),
    prop_wm          = as.numeric(prop_wm),
    prop_15yo        = as.numeric(prop_15yo),
    quintil          = as.factor(quintil),
    ln_totexp        = log(gastot_uf + EPS)
  ) %>%
  filter(glosa %in% GOODS)

# =========================================================
# 2) FUNCIONES AUXILIARES
# =========================================================

wmean <- function(x, w) {
  ok <- is.finite(x) & is.finite(w) & w > 0
  if (!any(ok)) return(NA_real_)
  sum(x[ok] * w[ok]) / sum(w[ok])
}

# Elasticidad extensiva en probit con un precio agregado
# epsilon = [E(phi(xb)*beta)] / E(Phi(xb))
extensive_elasticity_probit <- function(model, price_var) {
  xb  <- model$linear.predictors
  Phi <- pnorm(xb)
  phi <- dnorm(xb)
  w   <- model$prior.weights
  
  Pbar <- wmean(Phi, w)
  b    <- coef(model)[price_var]
  
  MEbar <- wmean(phi * b, w)
  eps   <- MEbar / Pbar
  
  tibble(
    parameter = price_var,
    eps_ext   = as.numeric(eps),
    Pbar      = as.numeric(Pbar),
    beta      = as.numeric(b)
  )
}


# =========================================================
# 3) PRECIOS TIPO DEATON POR BEBIDA
# =========================================================

df_deaton <- df_long %>%
  mutate(
    ln_uv = log(unit_value)
  ) %>%
  filter(
    is.finite(ln_uv),
    is.finite(ln_totexp),
    is.finite(fe), fe > 0
  )

buyers_cluster <- df_deaton %>%
  group_by(glosa, cluster) %>%
  summarise(
    n_buyers = n(),
    .groups = "drop"
  )

estimate_deaton_price <- function(good, data, min_buyers = 10) {
  
  valid_clusters <- buyers_cluster %>%
    filter(glosa == good, n_buyers >= min_buyers) %>%
    pull(cluster)
  
  sub <- data %>%
    filter(glosa == good, cluster %in% valid_clusters)
  
  fml <- as.formula(
    paste0(
      "ln_uv ~ ln_totexp + ",
      paste(Z_VARS, collapse = " + "),
      " | cluster"
    )
  )
  
  m <- feols(
    fml,
    data = sub,
    weights = ~ fe
  )
  
  fe_cluster <- fixef(m)$cluster
  
  tibble(
    cluster = names(fe_cluster),
    glosa   = good,
    ln_p    = as.numeric(fe_cluster)
  )
}

df_p_deaton_long <- map_dfr(
  GOODS,
  ~ estimate_deaton_price(.x, df_deaton, min_buyers = MIN_BUYERS_CLUSTER)
)

df_p_deaton_wide <- df_p_deaton_long %>%
  pivot_wider(
    id_cols      = cluster,
    names_from   = glosa,
    values_from  = ln_p,
    names_prefix = "ln_p_"
  )

# =========================================================
# 4) PEGAR PRECIOS A LOS DATOS
# =========================================================

df_long_p <- df_long %>%
  left_join(df_p_deaton_wide, by = "cluster") %>%
  mutate(
    hh_spend = if_else(is.na(hh_spend), 0, hh_spend),
    hh_quant = if_else(is.na(hh_quant), 0, hh_quant)
  )

# =========================================================
# 5) PESOS PARA EL ÍNDICE DE PRECIO AGREGADO
#    (participación general)
# =========================================================

# Shares medios de gasto alcohólico entre hogares con gasto positivo
w_mean <- df_long_p %>%
  group_by(hh_id) %>%
  mutate(x_alc = sum(hh_spend, na.rm = TRUE)) %>%
  ungroup() %>%
  filter(x_alc > 0) %>%
  mutate(w = hh_spend / x_alc) %>%
  group_by(glosa) %>%
  summarise(
    w_mean = wmean(w, fe),
    .groups = "drop"
  )

w_Beer    <- w_mean$w_mean[w_mean$glosa == "Beer"]
w_Wines   <- w_mean$w_mean[w_mean$glosa == "Wines"]
w_Spirits <- w_mean$w_mean[w_mean$glosa == "Spirits"]

# =========================================================
# 6) BASE HOGAR-WIDE
# =========================================================

df_hh_good <- df_long_p %>%
  group_by(hh_id, year, estrato_muestreo, cluster, glosa) %>%
  summarise(
    fe         = first(fe),
    q          = sum(hh_quant, na.rm = TRUE),
    spend      = sum(hh_spend, na.rm = TRUE),
    gastot_uf  = first(gastot_uf),
    ing_uf     = first(ing_uf),
    educ_hhh   = first(educ_hhh),
    age_hhh    = first(age_hhh),
    sex_hhh    = first(sex_hhh),
    npersonas  = first(npersonas),
    prop_wm    = first(prop_wm),
    prop_15yo  = first(prop_15yo),
    quintil    = first(quintil),
    ln_totexp  = first(ln_totexp),
    ln_p_Beer    = first(ln_p_Beer),
    ln_p_Wines   = first(ln_p_Wines),
    ln_p_Spirits = first(ln_p_Spirits),
    oh_cat = first(oh_cat),
    .groups = "drop"
  ) %>%
  mutate(
    D    = as.integer(q > 0),
    ln_q = if_else(q > 0, log(q + EPS), NA_real_)
  )

df_hh_wide <- df_hh_good %>%
  select(
    hh_id, year, estrato_muestreo, cluster, fe,
    gastot_uf, ing_uf, educ_hhh, age_hhh, sex_hhh,
    npersonas, prop_wm, prop_15yo, quintil, ln_totexp,
    ln_p_Beer, ln_p_Wines, ln_p_Spirits,
    glosa, q, spend, D, ln_q, oh_cat
  ) %>%
  pivot_wider(
    id_cols = c(
      hh_id, year, estrato_muestreo, cluster, fe,
      gastot_uf, ing_uf, educ_hhh, age_hhh, sex_hhh,
      npersonas, prop_wm, prop_15yo, quintil, ln_totexp,
      ln_p_Beer, ln_p_Wines, ln_p_Spirits, oh_cat
    ),
    names_from   = glosa,
    values_from  = c(q, spend, D, ln_q),
    values_fill  = list(q = 0, spend = 0, D = 0, ln_q = NA_real_)
  ) %>%
  mutate(
    total_alcohol_q = q_Beer + q_Wines + q_Spirits,
    drinker         = as.integer(total_alcohol_q > 0),
    
    # índice de precio agregado estilo Stone con shares medios
    ln_p_alc = w_Beer    * ln_p_Beer +
      w_Wines   * ln_p_Wines +
      w_Spirits * ln_p_Spirits
  )

# =========================================================
# 7) PARTICIPACIÓN GENERAL
# =========================================================

df_hh_wide<- df_hh_wide %>%
  mutate(mean_p_oh = rowMeans(pick(ln_p_Beer, ln_p_Wines, ln_p_Spirits)),
         d_beer = ifelse(q_Beer > 0, 1, 0),
         d_wine = ifelse(q_Wines > 0, 1, 0),
         d_spirits = ifelse(q_Spirits > 0, 1, 0))

m_part_beer <- feglm(
  d_beer ~ ln_p_Beer + ln_p_Wines+ ln_p_Spirits +
    sex_hhh + age_hhh + prop_wm + prop_15yo + quintil |
    estrato_muestreo + year,
  data   = df_hh_wide,
  family = binomial(link = "probit"),
  vcov   = ~ cluster
)

m_part_wines <- feglm(
  d_wine ~ ln_p_Beer + ln_p_Wines + ln_p_Spirits +
    sex_hhh + age_hhh + prop_wm + prop_15yo + quintil |
    estrato_muestreo + year,
  data   = df_hh_wide,
  family = binomial(link = "probit"),
  vcov   = ~ cluster
)

m_part_spirits <- feglm(
  d_spirits ~ ln_p_Beer + ln_p_Wines + ln_p_Spirits +
    sex_hhh + age_hhh + prop_wm + prop_15yo + quintil |
    estrato_muestreo + year,
  data   = df_hh_wide,
  family = binomial(link = "probit"),
  vcov   = ~ cluster
)

summary(m_part_beer)
summary(m_part_wines)
summary(m_part_spirits)



summary(m_part22)
summary(m_part)

library(margins)
# pesos fijos (ej: shares medios entre consumidores en 2017)
w_fix <- df_hh_wide %>%
  filter(year == "2017", drinker == 1) %>%
  summarise(
    wB = mean(w_Beer, na.rm = TRUE),
    wW = mean(w_Wines, na.rm = TRUE),
    wS = mean(w_Spirits, na.rm = TRUE)
  )

wB <- w_fix$wB; wW <- w_fix$wW; wS <- w_fix$wS

df_hh_wide <- df_hh_wide %>%
  mutate(lnP_fix = wB*ln_p_Beer + wW*ln_p_Wines + wS*ln_p_Spirits)

m_part_fix <- glm(
  drinker ~ lnP_fix + sex_hhh + age_hhh + prop_wm + prop_15yo +
    quintil + estrato_muestreo + year,
  family = binomial(link = "probit"),
  data = df_hh_wide
)
ame <- margins(m_part)
ame_tab <- summary(ame) %>% as.data.frame()

ame_prices <- ame_tab %>%
  filter(factor %in% c("ln_p_Wines", "ln_p_Beer", "ln_p_Spirits")) %>%
  mutate(
    mean_p = mean_p,
    elasticity_ext = AME / mean_p
  )

ame_prices

library(ggdist)
ggplot(df_hh_wide, aes(y = ln_p_Beer, x = factor(drinker))) +
  # Half violin on the right
  stat_halfeye(
    adjust = 0.5,
    width = 0.5,
    justification = -0.25,
    .width = 0,
    point_colour = NA
  ) +
  # Thin boxplot in the centre
  geom_boxplot(
    width = 0.12,
    outlier.shape = NA
  ) +
  # Jitter manually via adding noise to numeric position
  geom_point(
    aes(x = as.numeric(factor(drinker)) - 0.25 +
          runif(nrow(df_hh_wide), -0.08, 0.08)),
    alpha = 0.15,
    size = 0.7
  )

aux <- df_hh_wide %>% 
  filter(oh_cat == "ND", drinker == 1) 
# checkear

# EL GRAN PROBLEMA ES QUE A MEDIDA QUE AUMENTA EL PRECIO DEL ALCOHOL (UNIT VALUE)
# LA PROBABILIDAD DE SER DRINKER AUMENTA
# ESTO NO TIENE SENTIDO, SE ESPERA QUE EL COEFICIENTE SEA NEGATIVO.

# EXPLORACIÓN DE ESO


cluster_epf <- data_epf |>
  filter(glosa == "Spirits") |>
  mutate(
    drinker   = as.integer(total_ethanol > 0),
    ln_totexp = log(gastot_uf)
  ) |>
  group_by(cluster, year) |>
  summarise(
    price     = first(ln_p_Deaton),
    part_rate = mean(drinker,   na.rm = TRUE),
    mean_exp  = mean(ln_totexp, na.rm = TRUE),
    n         = n(),
    .groups   = "drop"
  )

cat("Clusters:", nrow(cluster_epf), "| NAs en price:", sum(is.na(cluster_epf$price)), "\n")



library(patchwork)

p1 <- ggplot(cluster_epf |> filter(!is.na(price)),
             aes(x = price, y = part_rate)) +
  geom_point(aes(size = n), alpha = 0.6) +
  geom_smooth(method = "lm", se = TRUE, linewidth = 0.8) +
  facet_wrap(~ year) +
  labs(
    title = "Participación vs. precio de spirits por cluster",
    x = "ln(precio spirits) — Deaton",
    y = "Tasa de participación (ponderada)",
    size = "N hogares"
  ) +
  theme_minimal()

p2 <- ggplot(cluster_epf |> filter(!is.na(price)),
             aes(x = mean_exp, y = part_rate)) +
  geom_point(aes(size = n, color = price), alpha = 0.7) +
  geom_smooth(method = "lm", se = TRUE, linewidth = 0.8) +
  scale_color_viridis_c(name = "ln(precio)") +
  facet_wrap(~ year) +
  labs(
    title = "Participación vs. gasto medio del cluster",
    subtitle = "Color = precio de spirits (más claro = más caro)",
    x = "ln(gasto total) medio del cluster",
    y = "Tasa de participación (ponderada)"
  ) +
  theme_minimal()

p1 / p2





wmean <- function(x, w){
  ok <- is.finite(x) & is.finite(w) & w > 0
  sum(x[ok]*w[ok]) / sum(w[ok])
}

xb  <- m_part$linear.predictors
Phi <- pnorm(xb)
phi <- dnorm(xb)
w   <- m_part$prior.weights

Pbar <- wmean(Phi, w)

beta_p <- coef(m_part)["ln_p_alc"]

eps_part <- wmean(phi * beta_p, w) / Pbar

eps_part

# REVISAR EL SIGNO

# ==================================
# OPCIÓN 2: Bootstrap a nivel hogar 
# ==================================

set.seed(7241)
B_hh    <- 400
hh_ids  <- df_hh_wide$hh_id
boot_eps_hh <- numeric(B_hh)

for (b in seq_len(B_hh)) {
  idx  <- sample(seq_len(nrow(df_hh_wide)), replace = TRUE)
  bdat <- df_hh_wide[idx, ]
  
  m_b <- tryCatch(
    glm(f_part, data = bdat, family = binomial("probit"), weights = fe),
    error = function(e) NULL
  )
  if (is.null(m_b)) next
  
  xb_  <- m_b$linear.predictors
  w_   <- m_b$prior.weights
  b_p  <- coef(m_b)["ln_p_alc"]
  Pb   <- wmean(pnorm(xb_), w_)
  boot_eps_hh[b] <- wmean(dnorm(xb_) * b_p, w_) / Pb
}

valid_hh <- boot_eps_hh[is.finite(boot_eps_hh) & boot_eps_hh != 0]

cat(sprintf("%-26s  %.4f  %.4f  [%.4f, %.4f]\n",
    "Bootstrap hogar",
    eps_part,
    sd(valid_hh),
    quantile(valid_hh, 0.025),
    quantile(valid_hh, 0.975)))


# =========================================================
# 8) AIDS
# =========================================================

df_aids <- df_hh_wide %>%
  filter(drinker == 1) %>%
  mutate(
    x_alc = spend_Beer + spend_Wines + spend_Spirits
  ) %>%
  filter(x_alc > 0) %>%
  mutate(
    w_Beer    = spend_Beer / x_alc,
    w_Wines   = spend_Wines / x_alc,
    w_Spirits = spend_Spirits / x_alc,
    ln_x      = log(x_alc + 1e-8)
  )
df_aids <- df_aids %>%
  mutate(
    lnP = w_Beer*ln_p_Beer +
      w_Wines*ln_p_Wines +
      w_Spirits*ln_p_Spirits,
    ln_xP = ln_x - lnP
  )

# Usamos un AIDS lineal simple, con ln_xP y precios.

# Tomamos 2 ecuaciones (Beer y Wines) y dejamos Spirits implícito por la restricción de suma de shares:
df_aids$oh_cat <- relevel(factor(df_aids$oh_cat), ref = "ND")
eq_Beer <- w_Beer ~ ln_p_Beer + ln_p_Wines + ln_p_Spirits + ln_xP +
  educ_hhh + age_hhh + sex_hhh + npersonas + prop_wm + prop_15yo + quintil + oh_cat

eq_Wines <- w_Wines ~ ln_p_Beer + ln_p_Wines + ln_p_Spirits + ln_xP +
  educ_hhh + age_hhh + sex_hhh + npersonas + prop_wm + prop_15yo + quintil + oh_cat

aids_sys <- list(Beer = eq_Beer, Wines = eq_Wines)

fit_aids <- systemfit(
  aids_sys,
  method  = "SUR",
  data    = df_aids
)

summary(fit_aids)



# 7. Construir elasticidades marshallianas propias y cruzadas

coefs <- coef(fit_aids)

# Por claridad:
coefs

beta_Beer   <- coefs["Beer_ln_xP"]
beta_Wines  <- coefs["Wines_ln_xP"]
beta_Spirits <- - (beta_Beer + beta_Wines)   # por adding-up

beta_vec <- c(
  coefs["Beer_ln_xP"],
  coefs["Wines_ln_xP"],
  - (coefs["Beer_ln_xP"] + coefs["Wines_ln_xP"])  # Spirits por adding-up
)
names(beta_vec) <- GOODS   # <- 

beta_vec


gamma_Beer <- c(
  Beer    = coefs["Beer_ln_p_Beer"],
  Wines   = coefs["Beer_ln_p_Wines"],
  Spirits = coefs["Beer_ln_p_Spirits"]
)

gamma_Wines <- c(
  Beer    = coefs["Wines_ln_p_Beer"],
  Wines   = coefs["Wines_ln_p_Wines"],
  Spirits = coefs["Wines_ln_p_Spirits"]
)

gamma_Spirits <- - (gamma_Beer + gamma_Wines)   # por homogeneidad + adding-up


gamma_mat <- matrix(NA_real_, nrow = 3, ncol = 3,
                    dimnames = list(GOODS, GOODS))

# Fila Beer: efectos de precios sobre w_Beer
gamma_mat["Beer", ] <- c(
  Beer    = coefs["Beer_ln_p_Beer"],
  Wines   = coefs["Beer_ln_p_Wines"],
  Spirits = coefs["Beer_ln_p_Spirits"]
)

# Fila Wines: efectos de precios sobre w_Wines
gamma_mat["Wines", ] <- c(
  Beer    = coefs["Wines_ln_p_Beer"],
  Wines   = coefs["Wines_ln_p_Wines"],
  Spirits = coefs["Wines_ln_p_Spirits"]
)

# Fila Spirits por restricción (suma de gammas = 0 por columna)
gamma_mat["Spirits", ] <- - (gamma_mat["Beer", ] + gamma_mat["Wines", ])

gamma_mat

w <- c(
  Beer    = weighted.mean(df_aids$w_Beer,    w = df_aids$fe, na.rm = TRUE),
  Wines   = weighted.mean(df_aids$w_Wines,   w = df_aids$fe, na.rm = TRUE),
  Spirits = weighted.mean(df_aids$w_Spirits, w = df_aids$fe, na.rm = TRUE)
)

elas_marshall <- matrix(NA_real_, nrow = 3, ncol = 3,
                        dimnames = list(GOODS, GOODS))

for (i in GOODS) {
  for (j in GOODS) {
    if (i == j) {
      elas_marshall[i, j] <- -1 + (gamma_mat[i, j] - beta_vec[i] * w[i]) / w[i]
    } else {
      elas_marshall[i, j] <- (gamma_mat[i, j] - beta_vec[i] * w[j]) / w[i]
    }
  }
}

E_share <- elas_marshall


# =========================================================
# BOOTSTRAP POR CLUSTER (estrato × año)
# =========================================================

library(purrr)

# Función: estima AIDS con simetría y devuelve matriz 3×3 Marshalliana
compute_elas_sym <- function(data, R_sym) {
  
  fit <- tryCatch(
    systemfit(aids_sys, method = "SUR", data = data,
              restrict.matrix = R_sym, restrict.rhs = 0),
    error = function(e) NULL
  )
  if (is.null(fit)) return(NULL)
  
  cf <- coef(fit)
  
  beta <- setNames(
    c(cf["Beer_ln_xP"],
      cf["Wines_ln_xP"],
      -(cf["Beer_ln_xP"] + cf["Wines_ln_xP"])),
    GOODS
  )
  
  gmat <- matrix(NA_real_, 3, 3, dimnames = list(GOODS, GOODS))
  gmat["Beer",  ] <- c(cf["Beer_ln_p_Beer"],  cf["Beer_ln_p_Wines"],  cf["Beer_ln_p_Spirits"])
  gmat["Wines", ] <- c(cf["Wines_ln_p_Beer"], cf["Wines_ln_p_Wines"], cf["Wines_ln_p_Spirits"])
  gmat["Spirits", ] <- -(gmat["Beer", ] + gmat["Wines", ])
  
  w <- c(
    Beer    = weighted.mean(data$w_Beer,    data$fe, na.rm = TRUE),
    Wines   = weighted.mean(data$w_Wines,   data$fe, na.rm = TRUE),
    Spirits = weighted.mean(data$w_Spirits, data$fe, na.rm = TRUE)
  )
  
  E <- matrix(NA_real_, 3, 3, dimnames = list(GOODS, GOODS))
  for (i in GOODS) {
    for (j in GOODS) {
      E[i, j] <- (gmat[i, j] - beta[i] * w[j]) / w[i]
      if (i == j) E[i, j] <- E[i, j] - 1
    }
  }
  E
}

# Bootstrap
set.seed(8372)
B       <- 400
clusters <- sort(unique(df_aids$cluster[!is.na(df_aids$cluster)]))
n_cl    <- length(clusters)

boot_mats <- vector("list", B)
n_ok <- 0

for (b in seq_len(B)) {
  drawn <- sample(clusters, size = n_cl, replace = TRUE)
  
  boot_data <- map_dfr(seq_along(drawn), function(k)
    df_aids %>% filter(cluster == drawn[k]) %>% mutate(.bid = k)
  )
  
  if (nrow(boot_data) < 500) next
  
  m <- compute_elas_sym(boot_data, R3_mat)
  if (!is.null(m) && all(is.finite(m))) {
    boot_mats[[b]] <- m
    n_ok <- n_ok + 1
  }
  
  if (b %% 100 == 0) cat(sprintf("  %d / %d  (válidas: %d)\n", b, B, n_ok))
}

cat(sprintf("\nBootstrap completo: %d iteraciones válidas de %d\n", n_ok, B))


# =========================================================
# INTERVALOS DE CONFIANZA PERCENTIL 95%
# =========================================================

valid_mats <- Filter(Negate(is.null), boot_mats)

# Stack en array 3D: [i, j, b]
boot_array <- array(
  unlist(valid_mats),
  dim = c(3, 3, length(valid_mats)),
  dimnames = list(GOODS, GOODS, NULL)
)

# Punto estimado (E_marsh del modelo con simetría)
ci_lo <- apply(boot_array, c(1, 2), quantile, 0.025)
ci_hi <- apply(boot_array, c(1, 2), quantile, 0.975)
boot_sd <- apply(boot_array, c(1, 2), sd)

# ---- Tabla resumen ----
cat("=== Elasticidades Marshallianas con IC Bootstrap 95% ===\n\n")

for (i in GOODS) {
  for (j in GOODS) {
    tipo <- if (i == j) "propia  " else "cruzada "
    cat(sprintf(
      "e(%s, %s) [%s]: %6.4f  [%6.4f, %6.4f]  SE = %.4f\n",
      i, j, tipo,
      E_marsh[i, j], ci_lo[i, j], ci_hi[i, j], boot_sd[i, j]
    ))
  }
  cat("\n")
}


# =========================================================
# VISUALIZACIÓN: heatmap con punto estimado e IC
# =========================================================

library(ggplot2)
library(tidyr)

# Construir data frame largo
res_df <- expand.grid(demand = GOODS, price = GOODS, stringsAsFactors = FALSE) |>
  mutate(
    point = as.vector(E_marsh),
    lo    = as.vector(ci_lo),
    hi    = as.vector(ci_hi),
    sig   = sign(lo) == sign(hi),   # IC no cruza cero
    label = sprintf("%.3f\n[%.3f, %.3f]", point, lo, hi),
    demand = factor(demand, levels = rev(GOODS)),
    price  = factor(price,  levels = GOODS)
  )

ggplot(res_df, aes(x = price, y = demand, fill = point)) +
  geom_tile(color = "white", linewidth = 0.6) +
  geom_text(aes(label = label, fontface = ifelse(sig, "bold", "plain")),
            size = 2.9, lineheight = 1.2) +
  scale_fill_gradient2(
    low = "#2166ac", mid = "white", high = "#d6604d",
    midpoint = 0, name = "Elasticidad"
  ) +
  labs(
    title    = "Elasticidades Marshallianas — AIDS con simetría",
    subtitle = "IC Bootstrap 95% (400 replicas, cluster = estrato×año)\nNegritas: IC no cruza cero",
    x = "Precio del bien j",
    y = "Demanda del bien i"
  ) +
  theme_minimal(base_size = 11) +
  theme(panel.grid = element_blank())


# =========================================================
# CALCULAR IC: función genérica para cualquier lista bootstrap
# =========================================================

extract_ci <- function(boot_list, point_elas, group_var) {
  
  valid <- Filter(Negate(is.null), boot_list)
  groups <- names(point_elas)
  
  purrr::map_dfr(groups, function(g) {
    
    # Marshallianas: 3×3
    E_boots <- purrr::map(valid, ~ .x[[g]]$E)
    E_arr   <- array(unlist(E_boots), dim = c(3, 3, length(E_boots)),
                     dimnames = list(GOODS, GOODS, NULL))
    
    marsh_df <- expand.grid(demand = GOODS, price = GOODS,
                            stringsAsFactors = FALSE) %>%
      mutate(
        point = as.vector(point_elas[[g]]$E),
        lo    = apply(E_arr, c(1,2), quantile, 0.025),
        hi    = apply(E_arr, c(1,2), quantile, 0.975),
        se    = apply(E_arr, c(1,2), sd),
        type  = "Marshalliana",
        group = g,
        group_var = group_var
      )
    
    # Gasto: vector 3
    eta_boots <- purrr::map(valid, ~ .x[[g]]$eta)
    eta_mat   <- do.call(rbind, eta_boots)
    
    eta_df <- tibble(
      demand    = GOODS,
      price     = "Gasto",
      point     = as.numeric(point_elas[[g]]$eta),
      lo        = apply(eta_mat, 2, quantile, 0.025),
      hi        = apply(eta_mat, 2, quantile, 0.975),
      se        = apply(eta_mat, 2, sd),
      type      = "Gasto",
      group     = g,
      group_var = group_var
    )
    
    bind_rows(marsh_df, eta_df)
  }) %>%
  mutate(sig = sign(lo) == sign(hi))
}

ci_q <- extract_ci(boot_q_list, elas_q, "quintil")
ci_c <- extract_ci(boot_c_list, elas_c, "cons_cat")

cat("IC calculados:\n")
cat("  Quintil:  ", nrow(ci_q), "filas\n")
cat("  Cons_cat: ", nrow(ci_c), "filas\n")
# =========================================================
# INTERVALOS DE CONFIANZA PERCENTIL 95%
# =========================================================

valid_mats <- Filter(Negate(is.null), boot_mats)

# Stack en array 3D: [i, j, b]
boot_array <- array(
  unlist(valid_mats),
  dim = c(3, 3, length(valid_mats)),
  dimnames = list(GOODS, GOODS, NULL)
)

# Punto estimado (E_marsh del modelo con simetría)
ci_lo <- apply(boot_array, c(1, 2), quantile, 0.025)
ci_hi <- apply(boot_array, c(1, 2), quantile, 0.975)
boot_sd <- apply(boot_array, c(1, 2), sd)

# ---- Tabla resumen ----
cat("=== Elasticidades Marshallianas con IC Bootstrap 95% ===\n\n")

for (i in GOODS) {
  for (j in GOODS) {
    tipo <- if (i == j) "propia  " else "cruzada "
    cat(sprintf(
      "e(%s, %s) [%s]: %6.4f  [%6.4f, %6.4f]  SE = %.4f\n",
      i, j, tipo,
      E_marsh[i, j], ci_lo[i, j], ci_hi[i, j], boot_sd[i, j]
    ))
  }
  cat("\n")
}

# =========================================================
# VISUALIZACIÓN: heatmap con punto estimado e IC
# =========================================================

extract_ci <- function(boot_list, point_elas, group_var) {
  
  valid  <- Filter(Negate(is.null), boot_list)
  groups <- names(point_elas)
  
  purrr::map_dfr(groups, function(g) {
    
    # ---- Marshallianas ----
    E_boots <- purrr::map(valid, ~ .x[[g]]$E)
    E_arr   <- array(unlist(E_boots),
                     dim = c(3, 3, length(E_boots)),
                     dimnames = list(GOODS, GOODS, NULL))
    
    ci_lo_m <- apply(E_arr, c(1, 2), quantile, 0.025)
    ci_hi_m <- apply(E_arr, c(1, 2), quantile, 0.975)
    se_m    <- apply(E_arr, c(1, 2), sd)
    
    marsh_df <- expand.grid(demand = GOODS, price = GOODS,
                            stringsAsFactors = FALSE) %>%
      mutate(
        point     = as.vector(point_elas[[g]]$E),
        lo        = as.vector(ci_lo_m),
        hi        = as.vector(ci_hi_m),
        se        = as.vector(se_m),
        type      = "Marshalliana",
        group     = g,
        group_var = group_var
      )
    
    # ---- Gasto ----
    eta_boots <- purrr::map(valid, ~ as.numeric(.x[[g]]$eta))
    eta_mat   <- do.call(rbind, eta_boots)   # B × 3
    colnames(eta_mat) <- GOODS
    
    eta_df <- tibble(
      demand    = GOODS,
      price     = "Gasto",
      point     = as.numeric(point_elas[[g]]$eta),
      lo        = apply(eta_mat, 2, quantile, 0.025),
      hi        = apply(eta_mat, 2, quantile, 0.975),
      se        = apply(eta_mat, 2, sd),
      type      = "Gasto",
      group     = g,
      group_var = group_var
    )
    
    bind_rows(marsh_df, eta_df)
  }) %>%
  mutate(sig = sign(lo) == sign(hi))
}

ci_q <- extract_ci(boot_q_list, elas_q, "quintil")
ci_c <- extract_ci(boot_c_list, elas_c, "cons_cat")

cat("IC calculados — filas ci_q:", nrow(ci_q),
    "| filas ci_c:", nrow(ci_c), "\n")
library(ggplot2)
library(tidyr)

# Construir data frame largo
res_df <- expand.grid(demand = GOODS, price = GOODS, stringsAsFactors = FALSE) |>
  mutate(
    point = as.vector(E_marsh),
    lo    = as.vector(ci_lo),
    hi    = as.vector(ci_hi),
    sig   = sign(lo) == sign(hi),   # IC no cruza cero
    label = sprintf("%.3f\n[%.3f, %.3f]", point, lo, hi),
    demand = factor(demand, levels = rev(GOODS)),
    price  = factor(price,  levels = GOODS)
  )

ggplot(res_df, aes(x = price, y = demand, fill = point)) +
  geom_tile(color = "white", linewidth = 0.6) +
  geom_text(aes(label = label, fontface = ifelse(sig, "bold", "plain")),
            size = 2.9, lineheight = 1.2) +
  scale_fill_gradient2(
    low = "#2166ac", mid = "white", high = "#d6604d",
    midpoint = 0, name = "Elasticidad"
  ) +
  labs(
    title    = "Elasticidades Marshallianas — AIDS con simetría",
    subtitle = "IC Bootstrap 95% (400 replicas, cluster = estrato×año)\nNegritas: IC no cruza cero",
    x = "Precio del bien j",
    y = "Demanda del bien i"
  ) +
  theme_minimal(base_size = 11) +
  theme(panel.grid = element_blank())


library(ggplot2)
library(patchwork)

# ---- Paleta y tema base ----
good_colors <- c(Beer = "#1f78b4", Wines = "#33a02c", Spirits = "#e31a1c")

theme_elas <- theme_minimal(base_size = 11) +
  theme(panel.grid.minor = element_blank(),
        legend.position  = "bottom")

# =========================================================
# PLOT 1 — Elasticidades PROPIAS por quintil (con IC)
# =========================================================
p_own_q <- ci_q %>%
  filter(type == "Marshalliana", demand == price) %>%
  mutate(demand = factor(demand, levels = GOODS),
         group  = factor(group, levels = as.character(1:5))) %>%
  ggplot(aes(x = group, y = point, color = demand, group = demand)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
  geom_ribbon(aes(ymin = lo, ymax = hi, fill = demand), alpha = 0.15,
              color = NA) +
  geom_line(linewidth = 0.9) +
  geom_point(aes(shape = sig), size = 3) +
  scale_color_manual(values = good_colors) +
  scale_fill_manual(values  = good_colors) +
  scale_shape_manual(values = c("TRUE" = 16, "FALSE" = 1),
                     guide  = "none") +
  labs(title    = "Elasticidades propias por quintil",
       subtitle = "Punto lleno = IC no cruza cero | IC Bootstrap 95%",
       x = "Quintil de ingreso", y = NULL, color = NULL, fill = NULL) +
  theme_elas

# =========================================================
# PLOT 2 — Elasticidades de GASTO por quintil
# =========================================================
p_eta_q <- ci_q %>%
  filter(type == "Gasto") %>%
  mutate(demand = factor(demand, levels = GOODS),
         group  = factor(group, levels = as.character(1:5))) %>%
  ggplot(aes(x = group, y = point, color = demand, group = demand)) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "grey60") +
  geom_ribbon(aes(ymin = lo, ymax = hi, fill = demand), alpha = 0.15,
              color = NA) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 3) +
  scale_color_manual(values = good_colors) +
  scale_fill_manual(values  = good_colors) +
  labs(title    = "Elasticidades de gasto por quintil",
       subtitle = "Línea punteada = η = 1",
       x = "Quintil de ingreso", y = NULL, color = NULL, fill = NULL) +
  theme_elas

p_own_q / p_eta_q
# =========================================================
# PLOT 3 — Heatmap con IC para nivel de consumo
# =========================================================
p_cons <- ci_c %>%
  filter(type == "Marshalliana") %>%
  mutate(
    demand = factor(demand, levels = rev(GOODS)),
    price  = factor(price,  levels = GOODS),
    label  = sprintf("%.3f\n[%.3f, %.3f]", point, lo, hi),
    group  = factor(group, levels = c("Moderado","Riesgo/Perjudicial"))
  ) %>%
  ggplot(aes(x = price, y = demand, fill = point)) +
  geom_tile(color = "white", linewidth = 0.6) +
  geom_text(aes(label = label,
                fontface = ifelse(sig, "bold", "plain")),
            size = 2.7, lineheight = 1.2) +
  scale_fill_gradient2(low = "#2166ac", mid = "white", high = "#d6604d",
                       midpoint = 0, name = NULL) +
  facet_wrap(~ group, ncol = 2) +
  labs(title    = "Elasticidades Marshallianas por nivel de consumo",
       subtitle = "IC Bootstrap 95% (300 réplicas) | Negritas: IC no cruza cero",
       x = "Precio j", y = "Demanda i") +
  theme_minimal(base_size = 11) +
  theme(panel.grid = element_blank(), legend.position = "right")

# =========================================================
# PLOT 4 — Elasticidades de gasto por consumo
# =========================================================
p_eta_c <- ci_c %>%
  filter(type == "Gasto") %>%
  mutate(demand = factor(demand, levels = GOODS),
         group  = factor(group, levels = c("Moderado","Riesgo/Perjudicial"))) %>%
  ggplot(aes(x = demand, y = point, color = demand)) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "grey60") +
  geom_pointrange(aes(ymin = lo, ymax = hi), linewidth = 0.8, size = 0.7) +
  scale_color_manual(values = good_colors, guide = "none") +
  facet_wrap(~ group) +
  labs(title    = "Elasticidades de gasto por nivel de consumo",
       subtitle = "IC Bootstrap 95%",
       x = NULL, y = NULL) +
  theme_elas

p_cons / p_eta_c + plot_layout(heights = c(2, 1))

# STRATIFIED ANALYSES

# oh_cat está en formato long — pegarla a df_aids vía hh_id
oh_cat_hh <- df_long_p %>%
  distinct(hh_id, oh_cat)

cat("¿Hay duplicados de hh_id?\n")
cat(sum(duplicated(oh_cat_hh$hh_id)), "duplicados\n\n")

# Si hay duplicados, tomar el primer valor por hh_id
oh_cat_hh <- df_long_p %>%
  group_by(hh_id) %>%
  summarise(oh_cat = first(oh_cat), .groups = "drop")

# Unir a df_aids
df_aids <- df_aids %>%
  left_join(oh_cat_hh, by = "hh_id")

cat("Distribución oh_cat en df_aids (drinkers):\n")
print(table(df_aids$oh_cat, useNA = "ifany"))

cat("\nCorresponde a:\n")
cat("Category 1 = bebedor moderado\n")
cat("Category 2 = bebedor de riesgo\n")
cat("Category 3 = bebedor perjudicial/dependiente\n")
cat("ND         = no determinado\n")


# Category 3 tiene solo 284 obs — fusionar Cat2 y Cat3 para robustez
# ND (7 obs) se excluyen

df_aids_int <- df_aids %>%
  filter(oh_cat != "ND", !is.na(oh_cat)) %>%
  mutate(
    quintil  = factor(quintil),
    cons_cat = factor(
      case_when(
        oh_cat == "Category 1" ~ "Moderado",
        oh_cat %in% c("Category 2", "Category 3") ~ "Riesgo/Perjudicial"
      ),
      levels = c("Moderado", "Riesgo/Perjudicial")
    )
  )

cat("N final en df_aids_int:", nrow(df_aids_int), "\n\n")
cat("quintil:\n");    print(table(df_aids_int$quintil))
cat("\ncons_cat:\n"); print(table(df_aids_int$cons_cat))


# =========================================================
# AIDS CON INTERACCIONES
# Estrategia: interactuar ln_p_* y ln_xP con cada variable 
# de grupo (quintil y cons_cat).
# Grupo de referencia: quintil 1 y Moderado.
# =========================================================

# Ecuaciones con interacciones para QUINTIL
eq_Beer_q <- w_Beer ~ 
  # precios base + interacciones con quintil
  ln_p_Beer  + ln_p_Beer:quintil  +
  ln_p_Wines + ln_p_Wines:quintil +
  ln_p_Spirits + ln_p_Spirits:quintil +
  # gasto base + interacción con quintil
  ln_xP + ln_xP:quintil +
  # controles
  educ_hhh + age_hhh + sex_hhh + npersonas + prop_wm + prop_15yo + quintil

eq_Wines_q <- w_Wines ~
  ln_p_Beer  + ln_p_Beer:quintil  +
  ln_p_Wines + ln_p_Wines:quintil +
  ln_p_Spirits + ln_p_Spirits:quintil +
  ln_xP + ln_xP:quintil +
  educ_hhh + age_hhh + sex_hhh + npersonas + prop_wm + prop_15yo + quintil

fit_q <- systemfit(
  list(Beer = eq_Beer_q, Wines = eq_Wines_q),
  method = "SUR",
  data   = df_aids_int
)

# Ecuaciones con interacciones para CONS_CAT
eq_Beer_c <- w_Beer ~
  ln_p_Beer  + ln_p_Beer:cons_cat  +
  ln_p_Wines + ln_p_Wines:cons_cat +
  ln_p_Spirits + ln_p_Spirits:cons_cat +
  ln_xP + ln_xP:cons_cat +
  educ_hhh + age_hhh + sex_hhh + npersonas + prop_wm + prop_15yo + cons_cat

eq_Wines_c <- w_Wines ~
  ln_p_Beer  + ln_p_Beer:cons_cat  +
  ln_p_Wines + ln_p_Wines:cons_cat +
  ln_p_Spirits + ln_p_Spirits:cons_cat +
  ln_xP + ln_xP:cons_cat +
  educ_hhh + age_hhh + sex_hhh + npersonas + prop_wm + prop_15yo + cons_cat

fit_c <- systemfit(
  list(Beer = eq_Beer_c, Wines = eq_Wines_c),
  method = "SUR",
  data   = df_aids_int
)

cat("Modelos estimados correctamente\n")
cat("fit_q (por quintil): R² Beer =",
    round(summary(fit_q)$eq[[1]]$r.squared, 4),
    " Wines =", round(summary(fit_q)$eq[[2]]$r.squared, 4), "\n")
cat("fit_c (por consumo): R² Beer =",
    round(summary(fit_c)$eq[[1]]$r.squared, 4),
    " Wines =", round(summary(fit_c)$eq[[2]]$r.squared, 4), "\n")

# =========================================================
# FUNCIÓN: elasticidades por grupo desde modelo con interacciones
# =========================================================

aids_elas_by_group <- function(fit, data, group_var) {
  
  cf  <- coef(fit)
  grp <- levels(data[[group_var]])
  
  results <- purrr::map(grp, function(g) {
    
    # Sufijo de interacción (vacío para grupo referencia)
    ref <- grp[1]
    suf <- if (g == ref) "" else paste0(group_var, g)
    
    # Helper: extrae coef base + interacción del grupo g
    pick_g <- function(base_name) {
      base <- if (base_name %in% names(cf)) cf[[base_name]] else 0
      if (suf == "") return(base)
      int_name <- paste0(base_name, ":", suf)
      # systemfit puede ordenar el nombre al revés
      int_name2 <- paste0(suf, ":", base_name)
      inter <- if (int_name  %in% names(cf)) cf[[int_name]]  else
               if (int_name2 %in% names(cf)) cf[[int_name2]] else 0
      base + inter
    }
    
    # Gamma 2×3 (Beer y Wines estimados)
    gmat <- matrix(NA_real_, 3, 3, dimnames = list(GOODS, GOODS))
    for (eq in c("Beer","Wines")) {
      for (p in GOODS) {
        base_nm  <- paste0(eq, "_ln_p_", p)
        gmat[eq, p] <- pick_g(base_nm)
      }
    }
    gmat["Spirits", ] <- -(gmat["Beer", ] + gmat["Wines", ])
    
    # Beta (expenditure slope)
    beta <- setNames(
      c(pick_g("Beer_ln_xP"),
        pick_g("Wines_ln_xP"),
        -(pick_g("Beer_ln_xP") + pick_g("Wines_ln_xP"))),
      GOODS
    )
    
    # Shares medios ponderados para el grupo
    sub <- data %>% filter(.data[[group_var]] == g)
    w_g <- c(
      Beer    = weighted.mean(sub$w_Beer,    sub$fe, na.rm = TRUE),
      Wines   = weighted.mean(sub$w_Wines,   sub$fe, na.rm = TRUE),
      Spirits = weighted.mean(sub$w_Spirits, sub$fe, na.rm = TRUE)
    )
    
    # Elasticidades Marshallianas
    E <- matrix(NA_real_, 3, 3, dimnames = list(GOODS, GOODS))
    for (i in GOODS) for (j in GOODS) {
      E[i, j] <- (gmat[i, j] - beta[i] * w_g[j]) / w_g[i]
      if (i == j) E[i, j] <- E[i, j] - 1
    }
    
    # Elasticidad de gasto
    eta <- 1 + beta / w_g
    
    list(group = g, E = E, eta = eta, w = w_g, beta = beta, gamma = gmat)
  })
  
  setNames(results, grp)
}

# Calcular por quintil y por cons_cat
elas_q <- aids_elas_by_group(fit_q, df_aids_int, "quintil")
elas_c <- aids_elas_by_group(fit_c, df_aids_int, "cons_cat")

cat("Elasticidades calculadas para", length(elas_q), "quintiles y",
    length(elas_c), "categorías de consumo\n")
# =========================================================
# TABLAS DE RESULTADOS
# =========================================================

# --- Función auxiliar para imprimir tabla por grupo ---
print_elas_table <- function(elas_list, title) {
  cat(sprintf("\n%s\n%s\n", title, strrep("=", nchar(title))))
  for (g in names(elas_list)) {
    res <- elas_list[[g]]
    cat(sprintf("\n[%s]\n", g))
    cat("  Marshallianas:\n")
    print(round(res$E, 3))
    cat("  Gasto: Beer=", round(res$eta["Beer"], 3),
        " Wines=", round(res$eta["Wines"], 3),
        " Spirits=", round(res$eta["Spirits"], 3), "\n")
  }
}

print_elas_table(elas_q, "ELASTICIDADES POR QUINTIL DE INGRESO")
print_elas_table(elas_c, "ELASTICIDADES POR NIVEL DE CONSUMO")


library(ggplot2)
library(tidyr)
library(dplyr)
library(patchwork)

# Construir data frame largo para visualización
build_plot_df <- function(elas_list, group_label) {
  purrr::map_dfr(names(elas_list), function(g) {
    res <- elas_list[[g]]
    # Marshallianas
    E_df <- as.data.frame(as.table(res$E)) %>%
      rename(demand = Var1, price = Var2, value = Freq) %>%
      mutate(type = "Marshalliana", group = g)
    # Gasto
    eta_df <- data.frame(
      demand = GOODS, price = "Gasto",
      value = as.numeric(res$eta),
      type = "Gasto", group = g
    )
    bind_rows(E_df, eta_df)
  }) %>%
  mutate(group_var = group_label)
}

df_plot <- bind_rows(
  build_plot_df(elas_q, "Quintil de ingreso"),
  build_plot_df(elas_c, "Nivel de consumo")
)

# ---- Plot 1: elasticidades propias por quintil ----
p1 <- df_plot %>%
  filter(group_var == "Quintil de ingreso",
         type == "Marshalliana", demand == price) %>%
  mutate(demand = factor(demand, levels = GOODS)) %>%
  ggplot(aes(x = group, y = value, color = demand, group = demand)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  labs(title = "Elasticidades propias por quintil",
       x = "Quintil de ingreso", y = "Elasticidad", color = NULL) +
  theme_minimal()

# ---- Plot 2: elasticidad de gasto por quintil ----
p2 <- df_plot %>%
  filter(group_var == "Quintil de ingreso", type == "Gasto") %>%
  mutate(demand = factor(demand, levels = GOODS)) %>%
  ggplot(aes(x = group, y = value, color = demand, group = demand)) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "grey60") +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  labs(title = "Elasticidades de gasto por quintil",
       x = "Quintil de ingreso", y = "Elasticidad de gasto", color = NULL) +
  theme_minimal()

# ---- Plot 3: heatmap por nivel de consumo ----
p3 <- df_plot %>%
  filter(group_var == "Nivel de consumo", type == "Marshalliana") %>%
  mutate(
    demand = factor(demand, levels = rev(GOODS)),
    price  = factor(price,  levels = GOODS),
    label  = round(value, 3)
  ) %>%
  ggplot(aes(x = price, y = demand, fill = value)) +
  geom_tile(color = "white") +
  geom_text(aes(label = label), size = 3) +
  scale_fill_gradient2(low = "#2166ac", mid = "white", high = "#d6604d",
                       midpoint = 0, name = NULL) +
  facet_wrap(~ group, ncol = 2) +
  labs(title = "Elasticidades Marshallianas por nivel de consumo",
       x = "Precio j", y = "Demanda i") +
  theme_minimal() +
  theme(panel.grid = element_blank())

(p1 | p2) / p3


# =========================================================
# BOOTSTRAP CONJUNTO: un solo loop, dos modelos por réplica
# =========================================================

set.seed(3847)
B       <- 300
cl_int  <- sort(unique(df_aids_int$cluster[!is.na(df_aids_int$cluster)]))
n_cl    <- length(cl_int)

boot_q_list <- vector("list", B)
boot_c_list <- vector("list", B)
n_ok <- 0

for (b in seq_len(B)) {
  
  drawn <- sample(cl_int, size = n_cl, replace = TRUE)
  
  boot_data <- purrr::map_dfr(seq_along(drawn), function(k)
    df_aids_int %>% filter(cluster == drawn[k]) %>% mutate(.bid = k)
  )
  
  if (nrow(boot_data) < 500) next
  
  # Verificar que todos los niveles de ambos factores están presentes
  if (length(unique(boot_data$quintil))  < 5) next
  if (length(unique(boot_data$cons_cat)) < 2) next
  
  # Modelo por quintil
  fit_q_b <- tryCatch(
    systemfit(list(Beer = eq_Beer_q, Wines = eq_Wines_q),
              method = "SUR", data = boot_data),
    error = function(e) NULL
  )
  
  # Modelo por cons_cat
  fit_c_b <- tryCatch(
    systemfit(list(Beer = eq_Beer_c, Wines = eq_Wines_c),
              method = "SUR", data = boot_data),
    error = function(e) NULL
  )
  
  if (is.null(fit_q_b) || is.null(fit_c_b)) next
  
  elas_q_b <- tryCatch(
    aids_elas_by_group(fit_q_b, boot_data, "quintil"),  error = function(e) NULL)
  elas_c_b <- tryCatch(
    aids_elas_by_group(fit_c_b, boot_data, "cons_cat"), error = function(e) NULL)
  
  if (is.null(elas_q_b) || is.null(elas_c_b)) next
  
  boot_q_list[[b]] <- elas_q_b
  boot_c_list[[b]] <- elas_c_b
  n_ok <- n_ok + 1
  
  if (b %% 100 == 0) cat(sprintf("  %d / %d  (válidas: %d)\n", b, B, n_ok))
}

cat(sprintf("\nBootstrap completo: %d válidas de %d\n", n_ok, B))

