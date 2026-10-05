
# QUAIDS two-step with Deaton-style unit value correction
# Reproducible script for hh_model.csv (wide) as provided
# Outputs:
#  - elasticities_long_with_CI.csv (price elasticities + expenditure elasticities with 95% CI)
#  - elasticities_compact_own_exp.csv (own-price + expenditure elasticities with 95% CI)

# Packages
suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(tidyr)
  library(stringr)
  library(sandwich)
  library(lmtest)
  library(MASS)
  library(mvtnorm)
})

# ---- 0) Load data ----
df <- read_csv("hh_model.csv", show_col_types = FALSE) %>%
  select(-matches("^Unnamed")) %>%
  mutate(
    folio_v = as.integer(folio_v),
    year = as.integer(year)
  )

goods_all <- c("Beer","Wines","Spirits","NA")
goods_eq  <- c("Beer","Wines","Spirits")

w_cols <- paste0("hh_share_", goods_all)
p_cols <- paste0("hh_price_", goods_all)

# Participation indicators: in this dataset, non-buyers appear as NA in share/price
for(g in goods_all){
  w <- paste0("hh_share_", g)
  df[[paste0("D_", g)]] <- ifelse(is.na(df[[w]]), 0L, 1L)
  df[[w]] <- ifelse(is.na(df[[w]]), 0, df[[w]])
}

# Cluster-year market definition for Deaton correction
df <- df %>%
  mutate(cy = paste0(var_unit, "_", year))

covars <- c("npersonas","ing_disp_hog_hd_pc","educ_hhh","age_hhh","sex_hhh","prop_wm","prop_15yo","quintil")

# Simple missing handling for covariates
for(v in covars){
  if(anyNA(df[[v]])){
    if(is.numeric(df[[v]])){
      df[[v]][is.na(df[[v]])] <- median(df[[v]], na.rm = TRUE)
    } else {
      df[[v]][is.na(df[[v]])] <- names(sort(table(df[[v]]), decreasing = TRUE))[1]
    }
  }
}

# ---- 1) Deaton-style unit value correction (quality purging) ----
# Approach used here:
#   ln(uv_ij) = const + z_i'δ + e_ij   (WLS with weights fe, among buyers)
#   ln p_{j,cy} = const + weighted_mean(e_ij | cy)
# Then map ln p_{j,cy} to all households. Fill missing cy by year median.

deaton_lnprice <- function(data, good, covars){
  wD <- paste0("D_", good)
  p  <- paste0("hh_price_", good)

  sub <- data %>%
    filter(.data[[wD]] == 1, !is.na(.data[[p]])) %>%
    mutate(lnuv = log(.data[[p]]))

  # WLS lnuv ~ covars
  fml <- as.formula(paste0("lnuv ~ ", paste(covars, collapse=" + ")))
  fit <- lm(fml, data = sub, weights = fe)

  # Residuals = quality component + measurement error
  sub$resid <- residuals(fit)

  # Weighted mean residual by cluster-year; add intercept to get "market price component"
  const <- coef(fit)[["(Intercept)"]]
  lnprice_cy <- sub %>%
    group_by(cy) %>%
    summarise(lnp = const + weighted.mean(resid, w = fe), .groups="drop")

  list(lnprice_cy = lnprice_cy, fit = fit)
}

# Compute corrected ln prices for Beer/Wines/Spirits
for(g in goods_eq){
  tmp <- deaton_lnprice(df, g, covars)
  lnp_name <- paste0("lnp_", g)
  df <- df %>%
    left_join(tmp$lnprice_cy, by = "cy") %>%
    rename(!!lnp_name := lnp) %>%
    group_by(year) %>%
    mutate(!!lnp_name := ifelse(is.na(.data[[lnp_name]]), median(.data[[lnp_name]], na.rm = TRUE), .data[[lnp_name]])) %>%
    ungroup()
}

# NA: used only for Stone index; here set to year median of Beer corrected ln price
df <- df %>%
  group_by(year) %>%
  mutate(lnp_NA = median(lnp_Beer, na.rm = TRUE)) %>%
  ungroup()

# ---- 2) Stone price index and QUAIDS terms ----
df <- df %>%
  mutate(
    lnP = hh_share_Beer*lnp_Beer + hh_share_Wines*lnp_Wines + hh_share_Spirits*lnp_Spirits + hh_share_NA*lnp_NA,
    m   = log(pmax(hh_tot_spend, 1e-6)) - lnP,
    m2  = m^2
  )

# ---- 3) Two-step estimation per category and per equation ----
sel_covars <- c(covars, "m")
out_covars <- c("lnp_Beer","lnp_Wines","lnp_Spirits","m","m2", covars)

# Inverse Mills ratio for probit (selected observations D=1)
imr_selected <- function(xb){
  phi <- dnorm(xb)
  Phi <- pnorm(xb)
  phi / pmax(Phi, 1e-12)
}

fit_two_step <- function(data_cat, good){
  Dname <- paste0("D_", good)
  wname <- paste0("hh_share_", good)

  # Stage 1: probit with weights fe
  fml1 <- as.formula(paste0(Dname, " ~ ", paste(sel_covars, collapse=" + ")))
  m1 <- glm(fml1, data = data_cat, family = binomial(link="probit"), weights = fe)

  xb <- predict(m1, type = "link")
  IMR <- rep(NA_real_, nrow(data_cat))
  sel <- data_cat[[Dname]] == 1
  IMR[sel] <- imr_selected(xb[sel])

  # Stage 2: QUAIDS approx on participants only + IMR
  part <- data_cat[sel, , drop = FALSE] %>% mutate(IMR = IMR[sel])

  fml2 <- as.formula(paste0(wname, " ~ ", paste(c(out_covars, "IMR"), collapse=" + ")))
  m2 <- lm(fml2, data = part, weights = fe)

  # Cluster-robust vcov by household (folio_v)
  V <- vcovCL(m2, cluster = part$folio_v, type = "HC1")

  list(stage1 = m1, stage2 = m2, V = V, part = part)
}

# Elasticity formulas (Stone index approximation)
elasticities <- function(coefs, wbar, mbar, good_i){
  beta  <- coefs[["m"]]
  lam   <- coefs[["m2"]]
  wi    <- wbar[[good_i]]

  deriv <- list()
  for(j in goods_eq){
    gamma <- coefs[[paste0("lnp_", j)]]
    deriv[[j]] <- gamma - (beta + 2*lam*mbar)*wbar[[j]]
  }

  e <- list()
  for(j in goods_eq){
    val <- deriv[[j]] / max(wi, 1e-12)
    if(j == good_i) val <- val - 1
    e[[j]] <- val
  }

  exp_el <- 1 + (beta + 2*lam*mbar) / max(wi, 1e-12)

  list(price = e, expenditure = exp_el)
}

# Parametric bootstrap for stage-2 coefficients only (fast)
# Note: this ignores additional uncertainty from stage 1 selection.
parametric_boot <- function(fit, R = 1500){
  b  <- coef(fit$stage2)
  V  <- fit$V
  draws <- rmvnorm(R, mean = b, sigma = as.matrix(V))
  colnames(draws) <- names(b)
  draws
}

cats <- sort(unique(df$oh_cat))
cats <- cats[!is.na(cats)]

rows <- list()
rows_compact <- list()

for(cat in cats){
  dfc <- df %>% filter(oh_cat == cat)
  if(nrow(dfc) < 300) next

  for(good in goods_eq){
    fit <- fit_two_step(dfc, good)

    # Weighted means among participants
    wbar <- sapply(goods_eq, function(g) weighted.mean(fit$part[[paste0("hh_share_", g)]], w = fit$part$fe))
    names(wbar) <- goods_eq
    mbar <- weighted.mean(fit$part$m, w = fit$part$fe)

    # Point elasticities
    el_point <- elasticities(coef(fit$stage2), as.list(wbar), mbar, good)

    # Parametric bootstrap CIs (stage2 only)
    draws <- parametric_boot(fit, R = 1500)

    # For each draw compute elasticities
    E_draw <- lapply(goods_eq, function(j) numeric(nrow(draws))); names(E_draw) <- goods_eq
    EXP_draw <- numeric(nrow(draws))

    for(r in seq_len(nrow(draws))){
      coefs_r <- as.list(draws[r, ])
      el_r <- elasticities(coefs_r, as.list(wbar), mbar, good)
      for(j in goods_eq) E_draw[[j]][r] <- el_r$price[[j]]
      EXP_draw[r] <- el_r$expenditure
    }

    # Save long rows (all cross + own + expenditure)
    for(j in goods_eq){
      lo <- quantile(E_draw[[j]], 0.025, na.rm = TRUE)
      hi <- quantile(E_draw[[j]], 0.975, na.rm = TRUE)

      rows[[length(rows)+1]] <- tibble(
        oh_cat = cat,
        `Equation (w_i)` = good,
        `Price (ln p_j)` = j,
        `Elasticity (point)` = el_point$price[[j]],
        `CI 2.5%` = lo,
        `CI 97.5%` = hi,
        `N participants` = nrow(fit$part)
      )
    }

    lo <- quantile(EXP_draw, 0.025, na.rm = TRUE)
    hi <- quantile(EXP_draw, 0.975, na.rm = TRUE)

    rows[[length(rows)+1]] <- tibble(
      oh_cat = cat,
      `Equation (w_i)` = good,
      `Price (ln p_j)` = "Expenditure",
      `Elasticity (point)` = el_point$expenditure,
      `CI 2.5%` = lo,
      `CI 97.5%` = hi,
      `N participants` = nrow(fit$part)
    )

    # Compact: own + expenditure only
    own <- E_draw[[good]]
    own_ci <- quantile(own, c(0.025, 0.975), na.rm = TRUE)
    exp_ci <- quantile(EXP_draw, c(0.025, 0.975), na.rm = TRUE)

    rows_compact[[length(rows_compact)+1]] <- tibble(
      oh_cat = cat,
      Good = good,
      `Own-price (95% CI)` = sprintf("%.3f [%.3f, %.3f]", el_point$price[[good]], own_ci[[1]], own_ci[[2]]),
      `Expenditure (95% CI)` = sprintf("%.3f [%.3f, %.3f]", el_point$expenditure, exp_ci[[1]], exp_ci[[2]]),
      `N (participants)` = nrow(fit$part)
    )
  }
}

tab_long <- bind_rows(rows)
tab_compact <- bind_rows(rows_compact)

write_csv(tab_long, "elasticities_long_with_CI.csv")
write_csv(tab_compact, "elasticities_compact_own_exp.csv")

message("Done. Files written: elasticities_long_with_CI.csv, elasticities_compact_own_exp.csv")
