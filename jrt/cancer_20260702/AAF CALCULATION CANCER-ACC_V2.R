#-----------------------------------------------------------#
# MORTALITY TRENDS IN CHILE ATTRIBUTABLE TO ALCOHOL- CANCER #
# RR parameters: Sherk et al. (chronicRR.R)                 #
# Estimation method: trapezoidal integration + fitdist       #
#-----------------------------------------------------------#
rm(list = ls());gc()
pacman::p_load(tidyverse, fitdistrplus, MASS)

data <- readRDS("PIF addiction/Data/data_binge_sensitivity.RDS") %>% 
  mutate(aux = ifelse(oh1 == "No" & !is.na(oh2) ,1,0)) %>% 
  filter(aux == 0) %>% 
  dplyr::select(-aux) 

input <- data %>% 
  filter(!is.na(cvolaj)) %>% 
  group_by(sexo,year, edad_tramo, cvolaj) %>% 
  summarise(weighted_count = sum(exp, na.rm = TRUE)) %>% 
  mutate(prop = round(weighted_count / sum(weighted_count), 2)) %>% 
  dplyr::select(-weighted_count)

input_male <- input %>% 
  filter(sexo == "Hombre")
input_female <- input %>% 
  filter(sexo == "Mujer")

x_vals <- seq(0.1, 150, length.out = 1500)

# TRAPEZOIDAL INTEGRATION FUNCTION
trap_int <- function(x, y, rr, prop_abs, rr_form, prop_form) {
  dx <- x[2] - x[1]
  ncgamma <- sum(y[-1] + y[-length(x)]) * dx / 2
  normalized_y <- (1 - (prop_abs + prop_form)) * y / ncgamma
  excess_rr <- rr - 1
  weighted_excess_rr <- normalized_y * excess_rr
  numerator <- (rr_form - 1) * prop_form +
    sum((weighted_excess_rr[-1] + weighted_excess_rr[-length(x)]) / 2) * dx
  denominator <- numerator + 1
  paf <- round(numerator / denominator, 3)
  return(paf)
}

# CONFIDENCE INTERVAL — MULTIPLE BETAS (covariance matrix)
confint_paf_vcov <- function(gamma, betas, cov_matrix, p_abs, p_form, rr_fd, rr_function) {
  n_sim <- 10000
  simulated_pafs <- numeric(n_sim)
  for (i in 1:n_sim) {
    pca_sim   <- rgamma(1000, shape = gamma$estimate["shape"], rate = gamma$estimate["rate"])
    mean_sim  <- mean(pca_sim)
    sd_sim    <- sd(pca_sim)
    shape_sim <- (mean_sim / sd_sim)^2
    rate_sim  <- mean_sim / (sd_sim^2)
    y_gamma_sim <- dgamma(x_vals, shape = shape_sim, rate = rate_sim)
    if (any(is.nan(y_gamma_sim))) next
    beta_sim      <- MASS::mvrnorm(1, mu = betas, Sigma = cov_matrix)
    rr_sim        <- rr_function(x_vals, beta_sim)
    prop_abs_sim  <- max(rnorm(1, mean = p_abs,  sd = sqrt(p_abs  * (1 - p_abs)  / 1000)), 0.001)
    prop_form_sim <- max(rnorm(1, mean = p_form, sd = sqrt(p_form * (1 - p_form) / 1000)), 0.001)
    simulated_pafs[i] <- trap_int(x = x_vals, y = y_gamma_sim, rr = rr_sim,
                                  prop_abs = prop_abs_sim, rr_form = rr_fd,
                                  prop_form = prop_form_sim)
  }
  simulated_pafs <- simulated_pafs[!is.nan(simulated_pafs)]
  return(list(
    point_estimate = mean(simulated_pafs),
    lower_ci       = quantile(simulated_pafs, 0.025),
    upper_ci       = quantile(simulated_pafs, 0.975)
  ))
}

#------------------------------------------------------------------------------#
# GAMMA FITTING — FEMALES
#------------------------------------------------------------------------------#

years <- c(2012, 2014, 2016, 2018, 2020, 2022, 2024)

cd_fem_list <- list()
for (year in years) {
  cd_fem_list[[as.character(year)]] <- list()
  for (i in 1:4) {
    cd_fem_list[[as.character(year)]][[i]] <- data %>%
      filter(volajohdia > 0, sexo == "Mujer", edad_tramo == i, year == !!year) %>%
      pull(volajohdia)
  }
}

g_fem_list <- list()
for (year in names(cd_fem_list)) {
  g_fem_list[[year]] <- lapply(cd_fem_list[[year]], function(data) {
    if (length(data) > 1) fitdist(data, "gamma") else NULL
  })
}

ltabs_fem <- input_female %>% filter(cvolaj == "ltabs") %>% arrange(year, edad_tramo)
p_abs_list_fem <- ltabs_fem %>%
  group_by(year, edad_tramo) %>%
  summarise(prop = list(prop), .groups = "drop") %>%
  split(.$year) %>%
  lapply(function(df) setNames(df$prop, paste0("edad_tramo_", df$edad_tramo)))

fd_fem <- input_female %>% filter(cvolaj == "fd") %>% arrange(year, edad_tramo)
p_form_list_fem <- fd_fem %>%
  group_by(year, edad_tramo) %>%
  summarise(prop = list(prop), .groups = "drop") %>%
  split(.$year) %>%
  lapply(function(df) setNames(df$prop, paste0("edad_tramo_", df$edad_tramo)))

#------------------------------------------------------------------------------#
# GAMMA FITTING — MALES
#------------------------------------------------------------------------------#

cd_male_list <- list()
for (year in years) {
  cd_male_list[[as.character(year)]] <- list()
  for (i in 1:4) {
    cd_male_list[[as.character(year)]][[i]] <- data %>%
      filter(volajohdia > 0, sexo == "Hombre", edad_tramo == i, year == !!year) %>%
      pull(volajohdia)
  }
}

g_male_list <- list()
for (year in names(cd_male_list)) {
  g_male_list[[year]] <- lapply(cd_male_list[[year]], function(data) {
    if (length(data) > 1) fitdist(data, "gamma") else NULL
  })
}

ltabs_male <- input_male %>% filter(cvolaj == "ltabs") %>% arrange(year, edad_tramo)
p_abs_list_male <- ltabs_male %>%
  group_by(year, edad_tramo) %>%
  summarise(prop = list(prop), .groups = "drop") %>%
  split(.$year) %>%
  lapply(function(df) setNames(df$prop, paste0("edad_tramo_", df$edad_tramo)))

fd_male <- input_male %>% filter(cvolaj == "fd") %>% arrange(year, edad_tramo)
p_form_list_male <- fd_male %>%
  group_by(year, edad_tramo) %>%
  summarise(prop = list(prop), .groups = "drop") %>%
  split(.$year) %>%
  lapply(function(df) setNames(df$prop, paste0("edad_tramo_", df$edad_tramo)))

#==============================================================================
# AAF ESTIMATION — SHERK RR PARAMETERS, USER ESTIMATION METHOD
#==============================================================================

set.seed(145)

# Helper: runs confint_paf_vcov for one sex × disease across all years × age groups.
# Single-beta diseases: pass betas = c(value), cov_matrix = matrix(var, 1, 1).
estimate_aaf <- function(sex, g_list, p_abs_list, p_form_list, years,
                         betas, cov_matrix, rr_fd, rr_function, disease_name) {
  prefix <- if (sex == "female") "Fem" else "Male"
  out <- data.frame(Year = years)
  for (j in 1:4) {
    out[[paste0(prefix, j, "_point")]] <- NA_real_
    out[[paste0(prefix, j, "_lower")]] <- NA_real_
    out[[paste0(prefix, j, "_upper")]] <- NA_real_
  }
  for (i in seq_along(years)) {
    yr_key <- as.character(years[i])
    for (j in 1:4) {
      gfit   <- g_list[[yr_key]][[j]]
      p_abs  <- p_abs_list[[yr_key]][[paste0("edad_tramo_", j)]]
      p_form <- p_form_list[[yr_key]][[paste0("edad_tramo_", j)]]
      if (is.null(gfit) || is.na(p_abs) || is.na(p_form)) next
      res <- tryCatch(
        confint_paf_vcov(gamma = gfit, betas = betas, cov_matrix = cov_matrix,
                         p_abs = p_abs, p_form = p_form, rr_fd = rr_fd,
                         rr_function = rr_function),
        error = function(e) NULL
      )
      if (!is.null(res)) {
        out[i, paste0(prefix, j, "_point")] <- res$point_estimate
        out[i, paste0(prefix, j, "_lower")] <- res$lower_ci
        out[i, paste0(prefix, j, "_upper")] <- res$upper_ci
      }
    }
  }
  out$disease <- disease_name
  out
}

#------------------------------------------------------------------------------#
# 1. ORAL CAVITY AND PHARYNX CANCER
# Sherk: exp(x*beta[2] + x^2*beta[3]) — same betas M/F (beta[1]=beta[4]=0)
# lnRRFormer: log(1.2) — same for both sexes
#------------------------------------------------------------------------------#
rr_oral_fun <- function(x, betas) exp(betas[1]*x + betas[2]*x^2)

betas_oral <- c(0.02474, -0.00004)
cov_matrix_oral <- matrix(c(
   0.000002953, -0.0000000127,
  -0.0000000127,  0.000000000102
), 2, 2, byrow = TRUE)

oralcan_female <- estimate_aaf("female", g_fem_list, p_abs_list_fem, p_form_list_fem,
                               years, betas_oral, cov_matrix_oral,
                               rr_fd = 1.2, rr_oral_fun, "Oral Cavity and Pharynx Cancer")
oralcan_male   <- estimate_aaf("male",   g_male_list, p_abs_list_male, p_form_list_male,
                               years, betas_oral, cov_matrix_oral,
                               rr_fd = 1.2, rr_oral_fun, "Oral Cavity and Pharynx Cancer")

#------------------------------------------------------------------------------#
# 2. OESOPHAGUS CANCER
# Sherk: exp(x*beta[2] + x^3*beta[4]) — same betas M/F (beta[1]=beta[3]=0)
# lnRRFormer: log(1.16) — same for both sexes
#------------------------------------------------------------------------------#
rr_oes_fun <- function(x, betas) exp(betas[1]*x + betas[2]*x^3)

betas_oes <- c(0.0132063596418668, -4.14801974664481e-8)
cov_matrix_oes <- matrix(c(
  1.52570625075510e-07, -6.88520511004078e-13,
  -6.88520511004078e-13,  8.09350992351893e-18
), 2, 2, byrow = TRUE)

oescan_female <- estimate_aaf("female", g_fem_list, p_abs_list_fem, p_form_list_fem,
                              years, betas_oes, cov_matrix_oes,
                              rr_fd = 1.16, rr_oes_fun, "Oesophagus Cancer")
oescan_male   <- estimate_aaf("male",   g_male_list, p_abs_list_male, p_form_list_male,
                              years, betas_oes, cov_matrix_oes,
                              rr_fd = 1.16, rr_oes_fun, "Oesophagus Cancer")

#------------------------------------------------------------------------------#
# 3. COLORECTAL CANCER
# Sherk: exp(x*beta[2]) — same beta M/F (0.006765865)
# lnRRFormer: log(2.19) male, log(1.05) female
#------------------------------------------------------------------------------#
rr_crcan_fun <- function(x, betas) exp(x * betas[1])

betas_crcan      <- c(0.006765865)
cov_matrix_crcan <- matrix(0.000953764^2, 1, 1)

crcan_female <- estimate_aaf("female", g_fem_list, p_abs_list_fem, p_form_list_fem,
                             years, betas_crcan, cov_matrix_crcan,
                             rr_fd = 1.05, rr_crcan_fun, "Colorectal Cancer")
crcan_male   <- estimate_aaf("male",   g_male_list, p_abs_list_male, p_form_list_male,
                             years, betas_crcan, cov_matrix_crcan,
                             rr_fd = 2.19, rr_crcan_fun, "Colorectal Cancer")

#------------------------------------------------------------------------------#
# 4. LIVER CANCER
# Sherk: exp(x*beta[2]) — simple linear, same beta M/F
# lnRRFormer: log(2.23) male, log(2.68) female
#------------------------------------------------------------------------------#
rr_liver_fun <- function(x, betas) exp(x * betas[1])

betas_liver      <- c(0.003922071)
cov_matrix_liver <- matrix(0.000981283^2, 1, 1)

lican_female <- estimate_aaf("female", g_fem_list, p_abs_list_fem, p_form_list_fem,
                             years, betas_liver, cov_matrix_liver,
                             rr_fd = 2.68, rr_liver_fun, "Liver Cancer")
lican_male   <- estimate_aaf("male",   g_male_list, p_abs_list_male, p_form_list_male,
                             years, betas_liver, cov_matrix_liver,
                             rr_fd = 2.23, rr_liver_fun, "Liver Cancer")

#------------------------------------------------------------------------------#
# 5. LARYNX CANCER
# Sherk: exp(x*beta[2] + x^2*beta[3]) — same betas M/F (beta[1]=beta[4]=0)
# lnRRFormer: log(1.18) — same for both sexes
#------------------------------------------------------------------------------#
rr_larynx_fun <- function(x, betas) exp(betas[1]*x + betas[2]*x^2)

betas_larynx <- c(0.01462, -0.00002)
cov_matrix_larynx <- matrix(c(
   0.000003585, -0.0000000162,
  -0.0000000162,  0.000000000126
), 2, 2, byrow = TRUE)

lxcan_female <- estimate_aaf("female", g_fem_list, p_abs_list_fem, p_form_list_fem,
                             years, betas_larynx, cov_matrix_larynx,
                             rr_fd = 1.18, rr_larynx_fun, "Larynx Cancer")
lxcan_male   <- estimate_aaf("male",   g_male_list, p_abs_list_male, p_form_list_male,
                             years, betas_larynx, cov_matrix_larynx,
                             rr_fd = 1.18, rr_larynx_fun, "Larynx Cancer")

#------------------------------------------------------------------------------#
# 6. BREAST CANCER (females only)
# Sherk: spline — exp(x*beta[2] + beta[3]*spline(x)); lnRRFormer = log(1)
# Note: knots at 5, 15, 37.5 g/day (scaled by (37.5-5)^(2/3))
#------------------------------------------------------------------------------#
rr_breast_fun <- function(x, betas) {
  scale <- (37.5 - 5.0)^(2/3)
  spline_term <- pmax((x - 5.0) / scale, 0)^3 +
    ((15.0 - 5.0) * pmax((x - 37.5) / scale, 0)^3 -
     (37.5 - 5.0) * pmax((x - 15.0) / scale, 0)^3) / (37.5 - 15.0)
  exp(betas[1] * x + betas[2] * spline_term)
}

betas_bcan      <- c(0.0095, -0.0087)
cov_matrix_bcan <- matrix(c(
   6.78e-7, -1.13e-6,
  -1.13e-6,  2.39e-6
), 2, 2, byrow = TRUE)

bcan_female <- estimate_aaf("female", g_fem_list, p_abs_list_fem, p_form_list_fem,
                            years, betas_bcan, cov_matrix_bcan,
                            rr_fd = 1.0, rr_breast_fun, "Breast Cancer")

#------------------------------------------------------------------------------#
# 7. PANCREATIC CANCER
# Sherk: exp(x*beta[2]) — simple linear, same beta M/F
# lnRRFormer: log(1.21) male, log(1.44) female
#------------------------------------------------------------------------------#
rr_pancreatic_fun <- function(x, betas) exp(x * betas[1])

betas_pancreatic      <- c(0.002089)
cov_matrix_pancreatic <- matrix(0.0000002426, 1, 1)

pancreatic_female <- estimate_aaf("female", g_fem_list, p_abs_list_fem, p_form_list_fem,
                                  years, betas_pancreatic, cov_matrix_pancreatic,
                                  rr_fd = 1.44, rr_pancreatic_fun, "Pancreatic Cancer")
pancreatic_male   <- estimate_aaf("male",   g_male_list, p_abs_list_male, p_form_list_male,
                                  years, betas_pancreatic, cov_matrix_pancreatic,
                                  rr_fd = 1.21, rr_pancreatic_fun, "Pancreatic Cancer")

#------------------------------------------------------------------------------#
# 8. STOMACH CANCER
# Sherk: exp(x*beta[2] + x^2*beta[3]) — same betas M/F (beta[1]=beta[4]=0)
# lnRRFormer: log(1.21) male, log(1.44) female
#------------------------------------------------------------------------------#
rr_stomach_fun <- function(x, betas) exp(betas[1]*x + betas[2]*x^2)

betas_stomcan      <- c(-0.00058, 0.000034)
cov_matrix_stomcan <- matrix(c(
   0.000001038, -0.00000000479,
  -0.00000000479,  0.0000000000225
), 2, 2, byrow = TRUE)

stomcan_female <- estimate_aaf("female", g_fem_list, p_abs_list_fem, p_form_list_fem,
                               years, betas_stomcan, cov_matrix_stomcan,
                               rr_fd = 1.44, rr_stomach_fun, "Stomach Cancer")
stomcan_male   <- estimate_aaf("male",   g_male_list, p_abs_list_male, p_form_list_male,
                               years, betas_stomcan, cov_matrix_stomcan,
                               rr_fd = 1.21, rr_stomach_fun, "Stomach Cancer")

#==============================================================================
# BIND RESULTS
# ag = age group (1 = 15-29, 2 = 30-44, 3 = 45-59, 4 = 60-65)
#==============================================================================

aaf_cancer_fem <- bind_rows(
  oralcan_female, oescan_female, crcan_female, lican_female,
  lxcan_female, bcan_female, pancreatic_female, stomcan_female
) |>
  rename(AAF_ag1 = Fem1_point, LL_ag1 = Fem1_lower, UL_ag1 = Fem1_upper,
         AAF_ag2 = Fem2_point, LL_ag2 = Fem2_lower, UL_ag2 = Fem2_upper,
         AAF_ag3 = Fem3_point, LL_ag3 = Fem3_lower, UL_ag3 = Fem3_upper,
         AAF_ag4 = Fem4_point, LL_ag4 = Fem4_lower, UL_ag4 = Fem4_upper) %>% 
  mutate(sex = "Female")

aaf_cancer_male <- bind_rows(
  oralcan_male, oescan_male, crcan_male, lican_male,
  lxcan_male, pancreatic_male, stomcan_male
) |>
  rename(AAF_ag1 = Male1_point, LL_ag1 = Male1_lower, UL_ag1 = Male1_upper,
         AAF_ag2 = Male2_point, LL_ag2 = Male2_lower, UL_ag2 = Male2_upper,
         AAF_ag3 = Male3_point, LL_ag3 = Male3_lower, UL_ag3 = Male3_upper,
         AAF_ag4 = Male4_point, LL_ag4 = Male4_lower, UL_ag4 = Male4_upper)

#==============================================================================
# LONG FORMAT
# age_group: 15-29 / 30-44 / 45-59 / 60+
#==============================================================================

aaf_cancer <- bind_rows(
  aaf_cancer_fem  |> mutate(sex = "Female"),
  aaf_cancer_male |> mutate(sex = "Male")
) |>
  pivot_longer(
    cols = matches("^(AAF|LL|UL)_ag"),
    names_to  = c(".value", "age_group"),
    names_pattern = "^(AAF|LL|UL)_(ag\\d)$"
  ) |>
  mutate(
    age_group = recode(age_group,
                       ag1 = "15-29",
                       ag2 = "30-44",
                       ag3 = "45-59",
                       ag4 = "60+"
    ),
    across(c(AAF, LL, UL), \(x) round(x, 3))
  ) |>
  arrange(disease, sex, Year, age_group)

rio::export(aaf_cancer, "AAF_CANCER_SHERKV2.XLSX")

