# ============================================================
# Deaton (1988/1997) plausibility diagnostics ("assumptions")
# for unit-value prices using EPF-like household survey data
#
# Data: data_epf with columns:
# folio_v, fe, estrato_muestreo (cluster), year, glosa (good),
# gasto_uf (expenditure), cantidad (quantity),
# plus household covariates.
#
# Cluster variable: estrato_muestreo 
# Goods: glosa (e.g., "Beer","Wines","Spirits")
#
# What this script does:
# A) Construct unit values ln_uv = log(gasto_uf / cantidad)
# B) Diagnostics for Deaton assumptions:
#   1) Between vs within cluster variation in ln_uv (per good×year)
#   2) Cluster sizes (#buyers per cluster per good×year)
#   3) "Bulk discount / nonlinear pricing" test: ln_uv ~ ln_q + cluster FE
#   4) Quality sorting test: within-cluster ln_uv correlation with income proxies
#   5) Robustness to alternative cluster definition (optional)
#
# NOTE: These are diagnostics, not proofs.
# ============================================================

rm(list=ls()); gc()

suppressPackageStartupMessages({
  library(tidyverse)
  library(tidyr)
  library(purrr)
  library(readr)
  library(broom)
  library(fixest)    # fast FE regressions
  library(haven)
})

# ----------------------------
# DATA EPF 2022-2017
# ----------------------------
data_22 <- rio::import("epf_2022.rds") %>%
  zap_labels() %>%
  mutate(year = 2022,
         folio_v = as.character(folio_v)) 
colnames(data_22)
data_17 <- rio::import("epf_2017.rds") %>%
  zap_labels() 
colnames(data_17)
data_epf <- bind_rows(data_22, data_17) %>% 
  mutate(gasto_uf = gasto/39733.94) %>% 
  dplyr::select(-gasto)

data_epf <- data_epf %>%
  mutate(ethanol_g = cantidad * (apv / 100) * 0.789) %>%
  group_by(folio_v) %>%
  summarise(total_ethanol = sum(ethanol_g, na.rm = TRUE), .groups = "drop") %>%
  left_join(data_epf, by="folio_v") %>%
  mutate(
    n_15 = npersonas * prop_15yo,
    ethanol_pc_15 = if_else(n_15 > 0, total_ethanol / n_15, NA_real_),
    hh_apc = ethanol_pc_15 / 30,
    oh_cat = case_when(
      sex_hhh == 2 & between(hh_apc, 0.1, 20) ~ "Category 1",
      sex_hhh == 1 & hh_apc <= 40 ~ "Category 1",
      sex_hhh == 2 & hh_apc > 20 & hh_apc <= 40 ~ "Category 2",
      sex_hhh == 1 & hh_apc > 40 & hh_apc <= 60 ~ "Category 2",
      sex_hhh == 2 & hh_apc > 40 ~ "Category 3",
      sex_hhh == 1 & hh_apc > 60 ~ "Category 3",
      TRUE ~ "ND"
    )
  )  %>% 
  dplyr::select(-ethanol_pc_15, -hh_apc)


# ----------------------------
# Basic setup
# ----------------------------
cluster_var <- "estrato_muestreo"
id_var      <- "folio_v"
w_var       <- "fe"
good_var    <- "glosa"
year_var    <- "year"
exp_var     <- "gasto_uf"
qty_var     <- "cantidad"

# Which goods to analyze (optional: restrict)
goods_keep <- NULL  # e.g., c("Beer","Wines","Spirits") or NULL for all in glosa

EPS <- 1e-8

# ----------------------------
# 0) Clean + construct unit values
# ----------------------------
df <- data_epf %>%
  mutate(
    across(all_of(c(w_var, exp_var, qty_var,
                    "npersonas","ing_disp_hog_hd_pc","gastot_hd_pc","educ_hhh",
                    "prop_15yo","prop_wm","age_hhh","sex_hhh")), as.numeric),
    across(all_of(c(cluster_var, id_var, good_var, year_var, "quintil", "oh_cat")), as.character)
  ) %>%
  filter(is.finite(.data[[w_var]]), .data[[w_var]] > 0) %>%
  filter(is.finite(.data[[exp_var]]), is.finite(.data[[qty_var]])) %>%
  mutate(
    buyer = as.integer(.data[[exp_var]] > 0 & .data[[qty_var]] > 0),
    uv    = if_else(buyer == 1, .data[[exp_var]] / (.data[[qty_var]] + EPS), NA_real_),
    ln_uv = if_else(is.finite(uv) & uv > 0, log(uv), NA_real_),
    ln_q  = if_else(buyer == 1 & .data[[qty_var]] > 0, log(.data[[qty_var]]), NA_real_),
    ln_x  = if_else(.data[[exp_var]] > 0, log(.data[[exp_var]]), NA_real_),
    ln_totexp = if_else(is.finite(gastot_hd_pc) & gastot_hd_pc > 0, log(gastot_hd_pc), NA_real_),
    ln_inc    = if_else(is.finite(ing_disp_hog_hd_pc) & ing_disp_hog_hd_pc > 0, log(ing_disp_hog_hd_pc), NA_real_)
  )

if(!is.null(goods_keep)){
  df <- df %>% filter(.data[[good_var]] %in% goods_keep)
}

# ============================================================
# ASSUMPTION 9) Enough observations per cluster per good×year
# ============================================================
cluster_sizes <- df %>%
  filter(buyer == 1, is.finite(ln_uv)) %>%
  group_by(across(all_of(c(year_var, good_var, cluster_var)))) %>%
  summarise(
    n_buyers = n(),
    w_buyers = sum(.data[[w_var]]),
    .groups="drop"
  )

# Summaries by good×year
cluster_size_summary <- cluster_sizes %>%
  group_by(across(all_of(c(year_var, good_var)))) %>%
  summarise(
    n_clusters = n(),
    mean_buyers = mean(n_buyers),
    median_buyers = median(n_buyers),
    p10_buyers = quantile(n_buyers, 0.10),
    p25_buyers = quantile(n_buyers, 0.25),
    p75_buyers = quantile(n_buyers, 0.75),
    p90_buyers = quantile(n_buyers, 0.90),
    share_clusters_ge10 = mean(n_buyers >= 10),
    share_clusters_ge15 = mean(n_buyers >= 15),
    .groups="drop"
  )

print(cluster_size_summary)

# Optional plot: distribution of buyers per cluster
ggplot(cluster_sizes, aes(x=n_buyers)) +
  geom_histogram(bins=40, color="white") +
  facet_grid(reformulate(year_var, good_var)) +
  theme_minimal() +
  labs(title="Buyers per cluster (estrato_muestreo) by good×year",
       x="# buyers in cluster", y="count")

# ============================================================
# ASSUMPTION 1) Price variation is mainly BETWEEN clusters
# Diagnostic: within vs between variance decomposition of ln_uv
# ============================================================

# Weighted cluster means of ln_uv
cl_means <- df %>%
  filter(buyer == 1, is.finite(ln_uv)) %>%
  group_by(across(all_of(c(year_var, good_var, cluster_var)))) %>%
  summarise(
    ln_uv_c = weighted.mean(ln_uv, w=.data[[w_var]], na.rm=TRUE),
    n_buyers = n(),
    .groups="drop"
  )

# Merge cluster mean back, compute within residual
df_wv <- df %>%
  filter(buyer == 1, is.finite(ln_uv)) %>%
  left_join(cl_means, by=c(year_var, good_var, cluster_var)) %>%
  mutate(within_resid = ln_uv - ln_uv_c)

# Weighted variance function
wvar <- function(x, w){
  ok <- is.finite(x) & is.finite(w) & w > 0
  x <- x[ok]; w <- w[ok]
  if(length(x) < 2) return(NA_real_)
  mu <- sum(w*x)/sum(w)
  sum(w*(x-mu)^2)/sum(w)
}

var_decomp <- df_wv %>%
  group_by(across(all_of(c(year_var, good_var)))) %>%
  summarise(
    var_total  = wvar(ln_uv, .data[[w_var]]),
    var_within = wvar(within_resid, .data[[w_var]]),
    # between variance: variance of cluster means, weighted by cluster "mass"
    var_between = wvar(ln_uv_c, .data[[w_var]]),
    share_between = var_between / var_total,
    share_within  = var_within  / var_total,
    .groups="drop"
  )

print(var_decomp)

# Plot share_between by good×year
ggplot(var_decomp, aes(x=.data[[year_var]], y=share_between, fill=.data[[good_var]])) +
  geom_col(position="dodge") +
  theme_minimal() +
  labs(title="Deaton plausibility: share of ln(unit value) variance BETWEEN clusters",
       x="Year", y="Between / Total variance")

# Interpretation guidance (for you, not the paper):
# - If share_between is tiny (e.g., < 0.10), cluster-level prices are weakly identified.

# ============================================================
# ASSUMPTION 3 & 4) No quantity discounts / nonlinear pricing
# Test: ln_uv ~ ln_q + cluster FE (+ year FE if pooling)
# If coefficient on ln_q is negative: larger quantities -> lower unit values (bulk discounts)
# ============================================================

bulk_discount_tests <- df %>%
  filter(buyer == 1, is.finite(ln_uv), is.finite(ln_q)) %>%
  group_by(.data[[year_var]], .data[[good_var]]) %>%
  group_modify(~{
    d <- .x
    
    # Build formula safely as text
    fml <- as.formula(paste0(
      "ln_uv ~ ln_q | ", cluster_var
    ))
    
    m <- feols(
      fml,
      data = d,
      weights = d[[w_var]]
    )
    
    # Extract ln_q coefficient
    tibble(
      year  = unique(d[[year_var]])[1],
      glosa = unique(d[[good_var]])[1],
      estimate = coef(m)[["ln_q"]],
      std.error = se(m)[["ln_q"]],
      p.value = 2 * pnorm(abs(coef(m)[["ln_q"]] / se(m)[["ln_q"]]), lower.tail = FALSE),
      n = nobs(m)
    )
  }) %>%
  ungroup()

print(bulk_discount_tests)

# Quick visualization
ggplot(bulk_discount_tests, aes(x=.data[[year_var]], y=estimate, color=.data[[good_var]])) +
  geom_hline(yintercept=0, linetype=2) +
  geom_point(position=position_dodge(width=0.2), size=2) +
  geom_errorbar(aes(ymin=estimate-1.96*std.error, ymax=estimate+1.96*std.error),
                width=0.1, position=position_dodge(width=0.2)) +
  theme_minimal() +
  labs(title="Bulk discount diagnostic: coefficient of ln(quantity) in ln(unit value) with cluster FE",
       x="Year", y="Estimate (95% CI)")

# ============================================================
# ASSUMPTION 2 & 6) Quality depends on observables; sorting / preference confounding
# Diagnostic: within-cluster "quality" correlation with income/total exp proxies
#
# Approach:
# - Regress ln_uv on ln_totalexp (or ln_inc) + demographics + cluster FE
# - If ln_totalexp strongly predicts ln_uv within cluster, that’s quality upgrading (expected).
# - The issue is whether you can "explain" that with observables.
# ============================================================

quality_models <- df %>%
  filter(buyer == 1, is.finite(ln_uv)) %>%
  mutate(
    # choose one: ln_totexp or ln_inc; you can run both
    q_proxy = ln_totexp
  ) %>%
  group_by(across(all_of(c(year_var, good_var)))) %>%
  group_modify(~{
    d <- .x %>% filter(is.finite(q_proxy))
    if(nrow(d) < 200) return(tibble())
    m <- feols(
      ln_uv ~ q_proxy + educ_hhh + age_hhh + sex_hhh + npersonas + prop_wm + prop_15yo |
        .data[[cluster_var]],
      weights = ~ .data[[w_var]],
      data = d
    )
    # report q_proxy coefficient and within-R2
    tibble(
      term = "q_proxy",
      estimate = coef(m)[["q_proxy"]],
      se = se(m)[["q_proxy"]],
      within_r2 = fitstat(m, "wr2")[["wr2"]],
      n = nobs(m)
    )
  }) %>%
  ungroup()

print(quality_models)

# Interpretation:
# - A positive q_proxy coefficient is normal (richer households buy higher-quality -> higher uv).
# - The question is: does controlling for observables + cluster FE give a stable residual?
# - within_r2 indicates how much within-cluster variation in ln_uv is "explained".

# ============================================================
# ASSUMPTION 1 (again): Are there meaningful cluster FE differences?
# Another diagnostic: FE-only model (ln_uv ~ 1 | cluster) and its within/between fit
# ============================================================

cluster_FE_strength <- df %>%
  filter(buyer == 1, is.finite(ln_uv)) %>%
  group_by(across(all_of(c(year_var, good_var)))) %>%
  group_modify(~{
    d <- .x
    m <- feols(
      ln_uv ~ 1 | .data[[cluster_var]],
      weights = ~ .data[[w_var]],
      data = d
    )
    tibble(
      n = nobs(m),
      n_clusters = fixef_sizes(m)[[1]],
      within_r2 = fitstat(m, "wr2")[["wr2"]],  # FE-only has wr2=0 by construction; use overall R2
      r2 = fitstat(m, "r2")[["r2"]]
    )
  }) %>%
  ungroup()

print(cluster_FE_strength)

# ============================================================
# BONUS: Export a compact table you can report
# ============================================================

out_summary <- var_decomp %>%
  left_join(cluster_size_summary, by=c(year_var, good_var)) %>%
  left_join(bulk_discount_tests %>% transmute(!!year_var, !!good_var,
                                              bulk_beta = estimate,
                                              bulk_se = std.error,
                                              bulk_p = p.value),
            by=c(year_var, good_var)) %>%
  left_join(quality_models %>% transmute(!!year_var, !!good_var,
                                         qual_beta = estimate,
                                         qual_se = se,
                                         qual_within_r2 = within_r2),
            by=c(year_var, good_var)) %>%
  arrange(.data[[good_var]], .data[[year_var]])

write_csv(out_summary, "deaton_assumption_diagnostics_summary.csv")
print(out_summary)

# ============================================================
# What to look for (interpretation cheatsheet):
#
# 1) Cluster size: share_clusters_ge10 / ge15 should be reasonably high.
# 2) share_between: ideally not tiny; if <0.10 you may have weak between-cluster price variation.
# 3) bulk_beta: strongly negative suggests nonlinear pricing (volume discounts).
# 4) qual_beta: positive indicates quality upgrading with income/exp (expected).
#    If it's huge and observables explain little, quality bias may remain severe.
# ============================================================


rm(list=ls()); gc()

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(purrr)
  library(fixest)
  library(readr)
})

# ----------------------------
# Inputs
# ----------------------------
# data_epf must be in memory with:
# folio_v, fe, estrato_muestreo, year, glosa, gasto_uf, cantidad,
# npersonas, ing_disp_hog_hd_pc, gastot_hd_pc, educ_hhh, prop_15yo, prop_wm, age_hhh, sex_hhh
# and glosa includes Beer/Wines/Spirits

GOODS <- c("Beer","Wines","Spirits")
CLUSTER <- "estrato_muestreo"
ID      <- "folio_v"
YEAR    <- "year"
GOOD    <- "glosa"
W       <- "fe"
EXP     <- "gasto_uf"
QTY     <- "cantidad"

EPS <- 1e-8
MIN_BUYERS_CELL <- 10  # minimum buyers per (cluster×year×good) to keep cell FE

# ----------------------------
# 0) Clean + construct UV for buyers
# ----------------------------
df <- data_epf %>%
  mutate(
    across(all_of(c(W, EXP, QTY,
                    "npersonas","ing_disp_hog_hd_pc","gastot_hd_pc","educ_hhh",
                    "prop_15yo","prop_wm","age_hhh","sex_hhh")), as.numeric),
    across(all_of(c(CLUSTER, ID, GOOD, YEAR)), as.character)
  ) %>%
  filter(.data[[GOOD]] %in% GOODS) %>%
  mutate(
    buyer = as.integer(.data[[EXP]] > 0 & .data[[QTY]] > 0),
    uv    = if_else(buyer == 1, .data[[EXP]] / (.data[[QTY]] + EPS), NA_real_),
    ln_uv = if_else(is.finite(uv) & uv > 0, log(uv), NA_real_),
    ln_q  = if_else(buyer == 1 & .data[[QTY]] > 0, log(.data[[QTY]]), NA_real_),
    ln_totexp = if_else(is.finite(gastot_hd_pc) & gastot_hd_pc > 0, log(gastot_hd_pc), NA_real_),
    ln_inc    = if_else(is.finite(ing_disp_hog_hd_pc) & ing_disp_hog_hd_pc > 0, log(ing_disp_hog_hd_pc), NA_real_)
  )

# Keep only buyers for Deaton first-stage (unit values observed only for buyers)
df_b <- df %>%
  filter(buyer == 1, is.finite(ln_uv), is.finite(.data[[W]]), .data[[W]] > 0)

# Cell sizes for feasibility (cluster×year×good)
cell_n <- df_b %>%
  group_by(across(all_of(c(CLUSTER, YEAR, GOOD)))) %>%
  summarise(n_buyers = n(), .groups="drop")

# Mark sparse cells
df_b <- df_b %>%
  left_join(cell_n, by=c(CLUSTER, YEAR, GOOD)) %>%
  filter(n_buyers >= MIN_BUYERS_CELL)

# ----------------------------
# 1) Deaton first-stage: "quality" regression
#    ln_uv = FE(cluster×year) + controls + error
#
# Controls Z_h: demographics + ln_totexp or ln_inc (choose)
# Optional nuisance: ln_q to soak up nonlinear pricing / pack size effects
# ----------------------------

# Choose your quality proxy: ln_totexp is usually better than ln_inc in expenditure surveys
quality_proxy <- "ln_totexp"

Z_controls <- c(quality_proxy, "educ_hhh","age_hhh","sex_hhh","npersonas","prop_wm","prop_15yo")

# Two variants:
# (A) baseline Deaton (no ln_q)
# (B) Deaton + ln_q nuisance control
run_deaton_uv <- function(d, include_lnq = FALSE){
  
  # cluster×year FE identifier (more stable than separate FEs)
  d <- d %>% mutate(cy = paste0(.data[[CLUSTER]], "_", .data[[YEAR]]))
  
  rhs <- paste(Z_controls, collapse = " + ")
  if(include_lnq) rhs <- paste(rhs, "+ ln_q")
  
  fml <- as.formula(paste0("ln_uv ~ ", rhs, " | cy"))
  
  m <- feols(
    fml,
    data = d,
    weights = d[[W]]
  )
  
  # Extract FE(cy) as corrected log price component up to normalization
  fe_cy <- fixef(m)$cy
  price_cy <- tibble(
    cy = names(fe_cy),
    ln_p_cy_raw = as.numeric(fe_cy)
  )
  
  # Normalize within each year×good to have mean zero (optional but convenient)
  price_cy <- price_cy %>%
    separate(cy, into=c("cluster_tmp","year_tmp"), sep="_(?=[^_]+$)", remove=FALSE) %>%
    rename(!!CLUSTER := cluster_tmp, !!YEAR := year_tmp) %>%
    select(all_of(c(CLUSTER, YEAR)), ln_p_cy_raw)
  
  list(model=m, price_cy=price_cy)
}

# Run per good separately (recommended)
deaton_by_good <- function(include_lnq = FALSE){
  map(GOODS, function(g){
    d <- df_b %>%
      filter(.data[[GOOD]] == g) %>%
      filter(if_all(all_of(Z_controls), ~ is.finite(.x))) %>%
      { if(include_lnq) filter(., is.finite(ln_q)) else . }
    
    res <- run_deaton_uv(d, include_lnq = include_lnq)
    list(
      good = g,
      model = res$model,
      price = res$price_cy %>% mutate(glosa = g)
    )
  })
}

res_base <- deaton_by_good(include_lnq = FALSE)
res_lnq  <- deaton_by_good(include_lnq = TRUE)

# Stack prices
prices_base <- bind_rows(lapply(res_base, `[[`, "price"))
prices_lnq  <- bind_rows(lapply(res_lnq,  `[[`, "price"))

# Rename price columns
prices_base <- prices_base %>% rename(lnp_deaton = ln_p_cy_raw)
prices_lnq  <- prices_lnq  %>% rename(lnp_deaton_lnq = ln_p_cy_raw)

# ----------------------------
# 2) Merge corrected prices back to household×good (ALL households)
#    This is where you keep non-buyers: everyone in the cluster×year gets the price.
# ----------------------------
df_all <- df %>%
  select(all_of(c(ID, W, CLUSTER, YEAR, GOOD, EXP, QTY,
                  "npersonas","ing_disp_hog_hd_pc","gastot_hd_pc","educ_hhh",
                  "prop_15yo","prop_wm","age_hhh","sex_hhh","quintil", "var_unit", "oh_cat"))) %>%
  distinct()

df_all <- df_all %>%
  left_join(prices_base, by=c(CLUSTER, YEAR, "glosa")) %>%
  left_join(prices_lnq,  by=c(CLUSTER, YEAR, "glosa"))

# Diagnostics: missing prices after MIN_BUYERS_CELL filter
miss_check <- df_all %>%
  group_by(year, glosa) %>%
  summarise(
    share_missing_base = mean(!is.finite(lnp_deaton)),
    share_missing_lnq  = mean(!is.finite(lnp_deaton_lnq)),
    .groups="drop"
  )
print(miss_check)

# ----------------------------
# 3) Build household-wide dataset with shares and Deaton prices
# ----------------------------
hh_good <- df_all %>%
  group_by(folio_v, glosa) %>%
  summarise(
    hh_spend = sum(gasto_uf, na.rm=TRUE),
    hh_quant = sum(cantidad, na.rm=TRUE),
    .groups="drop"
  ) %>%
  group_by(folio_v) %>%
  mutate(
    hh_tot_spend = sum(hh_spend, na.rm=TRUE),
    hh_share = if_else(hh_tot_spend > 0, hh_spend / hh_tot_spend, 0)
  ) %>%
  ungroup() %>%
  left_join(df_all %>% select(folio_v, fe, estrato_muestreo, var_unit, year,
                              npersonas, ing_disp_hog_hd_pc, gastot_hd_pc, educ_hhh,
                              prop_15yo, prop_wm, age_hhh, sex_hhh, quintil, oh_cat) %>%
              distinct(),
            by="folio_v") %>%
  # attach Deaton prices at household×good (same within cluster×year×good)
  left_join(prices_base, by=c("estrato_muestreo","year","glosa")) %>%
  left_join(prices_lnq,  by=c("estrato_muestreo","year","glosa"))

# Wide format
hh_wide_deaton <- hh_good %>%
  select(folio_v, fe, estrato_muestreo, var_unit, year,
         npersonas, ing_disp_hog_hd_pc, gastot_hd_pc, educ_hhh, prop_15yo, prop_wm, age_hhh, sex_hhh, quintil,
         glosa, hh_share, hh_tot_spend, lnp_deaton, lnp_deaton_lnq, oh_cat) %>%
  pivot_wider(
    names_from = glosa,
    values_from = c(hh_share, lnp_deaton, lnp_deaton_lnq),
    names_sep = "_"
  )

write.csv(hh_wide_deaton, "hh_wide_deaton.csv")
