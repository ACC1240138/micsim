# ============================================================
# Sensitivity analysis for QUAIDS two-step demand elasticities
# A) No selection correction (exclude IMR from stage 2)
# B) AIDS instead of QUAIDS (exclude m^2 from stage 2)
#
# Outputs:
# - tab_*_long.csv for each sensitivity + model
# - heatmap PNGs (general + quintil facets + oh_cat facets)
#
# Input: hh_model.csv (wide) with at least:
#   folio_v, fe, hh_share_Beer, hh_share_Wines, hh_share_Spirits,
#   hh_price_Beer, hh_price_Wines, hh_price_Spirits,
#   hh_tot_spend (or other total alcohol spend),
#   quintil, oh_cat,
#   household covariates used in covars vector below.
# ============================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(purrr)
  library(tibble)
  library(ggplot2)
  library(sandwich)
})

# ----------------------------
# 0) Load data
# ----------------------------
df0 <- read.csv("hh_model.csv")

# ----------------------------
# 1) User options
# ----------------------------
R_BOOT <- 1500
MIN_GROUP_N <- 300

goods_eq <- c("Beer","Wines","Spirits")
wcol <- function(g) paste0("hh_share_", g)
pcol <- function(g) paste0("hh_price_", g)
lnpcol <- function(g) paste0("lnp_", g)

# Covariates (edit as needed to match your dataframe)
covars <- c("npersonas","ing_disp_hog_hd_pc","educ_hhh","age_hhh","sex_hhh","prop_wm","prop_15yo")

# Total alcohol expenditure variable (change if needed)
XVAR <- "hh_tot_spend"

# Cluster variable for vcovCL
CLVAR <- "folio_v"

# ----------------------------
# 2) Helpers
# ----------------------------
wmean <- function(x, w){
  ok <- is.finite(x) & is.finite(w)
  if(!any(ok)) return(NA_real_)
  sum(x[ok]*w[ok]) / sum(w[ok])
}

# robust parametric bootstrap (aligns b and V, handles non-PD V with jitter)
parametric_boot <- function(stage2, V, R=1500){
  b <- coef(stage2)
  
  keep <- !is.na(b)
  b <- b[keep]
  
  V <- V[names(b), names(b), drop = FALSE]
  V <- (V + t(V))/2
  
  jitter <- 1e-10
  ok <- FALSE
  for(k in 1:8){
    Ltry <- try(chol(V + diag(jitter, nrow(V))), silent = TRUE)
    if(!inherits(Ltry, "try-error")){
      L <- Ltry
      ok <- TRUE
      break
    }
    jitter <- jitter * 10
  }
  if(!ok) stop("Cholesky failed: V not positive definite even with jitter.")
  
  Z <- matrix(rnorm(R * length(b)), nrow = R)
  draws <- sweep(Z %*% t(L), 2, b, "+")
  colnames(draws) <- names(b)
  as.data.frame(draws)
}

# QUAIDS/AIDS Marshallian elasticities from stage2 coefficients
# This matches the transformation you used earlier:
# d w_i / d ln p_j = gamma_ij - (beta_i + 2*lambda_i*m) * w_j
# e_ij = (d w_i / d ln p_j)/w_i - 1(i=j)
# e_exp = 1 + (beta_i + 2*lambda_i*m)/w_i
elasticities <- function(coefs, wbar, mbar, eq_good, use_m2 = TRUE){
  beta_i <- coefs[["m"]]
  lam_i  <- if(use_m2) coefs[["I(m^2)"]] else 0
  if(is.na(lam_i)) lam_i <- 0
  
  wi <- wbar[[eq_good]]
  
  deriv <- list()
  for(j in goods_eq){
    gamma_ij <- coefs[[paste0("lnp_", j)]]
    if(is.na(gamma_ij)) gamma_ij <- 0
    deriv[[j]] <- gamma_ij - (beta_i + 2*lam_i*mbar) * wbar[[j]]
  }
  
  price_el <- list()
  for(j in goods_eq){
    eij <- deriv[[j]] / pmax(wi, 1e-12)
    if(j == eq_good) eij <- eij - 1
    price_el[[j]] <- as.numeric(eij)
  }
  
  exp_el <- 1 + (beta_i + 2*lam_i*mbar) / pmax(wi, 1e-12)
  list(price = price_el, expenditure = as.numeric(exp_el))
}

# ----------------------------
# 3) Build working dataset: shares, prices (logs), Stone index, m
# ----------------------------
df <- df0 %>%
  mutate(
    across(all_of(paste0("hh_share_", goods_eq)), ~replace(., is.na(.), 0)),
    # log prices from unit values; if missing, keep NA (will be handled later)
    lnp_Beer   = ifelse(is.finite(.data[[pcol("Beer")]])   & .data[[pcol("Beer")]]   > 0, log(.data[[pcol("Beer")]]),   NA_real_),
    lnp_Wines  = ifelse(is.finite(.data[[pcol("Wines")]])  & .data[[pcol("Wines")]]  > 0, log(.data[[pcol("Wines")]]),  NA_real_),
    lnp_Spirits= ifelse(is.finite(.data[[pcol("Spirits")]])& .data[[pcol("Spirits")]]> 0, log(.data[[pcol("Spirits")]]),NA_real_),
    
    # total spend
    x = .data[[XVAR]]
  )

# ---- Optional but recommended: simple price imputation by (var_unit, year)
# If you already used Deaton-corrected prices in lnp_*, skip this section.
# This fills household lnp_* when missing with cluster-year mean.
if(all(c("var_unit","year") %in% names(df))){
  df <- df %>%
    group_by(var_unit, year) %>%
    mutate(
      lnp_Beer    = ifelse(is.na(lnp_Beer),    mean(lnp_Beer,    na.rm=TRUE), lnp_Beer),
      lnp_Wines   = ifelse(is.na(lnp_Wines),   mean(lnp_Wines,   na.rm=TRUE), lnp_Wines),
      lnp_Spirits = ifelse(is.na(lnp_Spirits), mean(lnp_Spirits, na.rm=TRUE), lnp_Spirits)
    ) %>%
    ungroup()
}

# ---- Stone price index using shares of the 3 alcoholic goods
# ln P* = sum_j w_j ln p_j
# m = ln( x / P* ) = ln x - ln P*
df <- df %>%
  mutate(
    lnP = hh_share_Beer*lnp_Beer + hh_share_Wines*lnp_Wines + hh_share_Spirits*lnp_Spirits,
    m   = log(pmax(x, 1e-12)) - lnP,
    m2  = m^2
  )

# ----------------------------
# 4) Two-step estimation engines
# ----------------------------

# Stage 1 probit (quasibinomial to avoid integer warning with weights)
fit_stage1 <- function(dat, good){
  D <- as.integer(dat[[wcol(good)]] > 0)
  dat$Dtmp <- D
  
  sel_fml <- as.formula(paste0("Dtmp ~ ", paste(c(covars, "m"), collapse=" + ")))
  stage1 <- glm(
    sel_fml,
    data = dat,
    family = quasibinomial(link = "probit"),
    weights = fe,
    control = glm.control(maxit = 100)
  )
  
  xb  <- as.numeric(model.matrix(stage1) %*% coef(stage1))
  Phi <- pnorm(xb)
  phi <- dnorm(xb)
  Phi <- pmin(pmax(Phi, 1e-8), 1 - 1e-8)
  
  IMR <- rep(0, nrow(dat))
  sel <- dat$Dtmp == 1
  IMR[sel] <- phi[sel] / Phi[sel]
  dat$IMR <- IMR
  
  list(stage1 = stage1, dat = dat)
}

# Stage 2 conditional share regression
fit_stage2 <- function(part, good, include_imr = TRUE, include_m2 = TRUE){
  
  rhs <- c("lnp_Beer","lnp_Wines","lnp_Spirits","m")
  if(include_m2) rhs <- c(rhs, "I(m^2)")
  rhs <- c(rhs, covars)
  if(include_imr) rhs <- c(rhs, "IMR")
  
  fml <- as.formula(paste0(wcol(good), " ~ ", paste(rhs, collapse=" + ")))
  
  stage2 <- lm(fml, data = part, weights = fe)
  
  V <- sandwich::vcovCL(stage2, cluster = part[[CLVAR]], type = "HC1")
  list(stage2 = stage2, V = V)
}

# Full two-step (no interactions)
fit_two_step_sep <- function(dat, good, include_imr=TRUE, include_m2=TRUE){
  
  # stage 1
  s1 <- fit_stage1(dat, good)
  dat1 <- s1$dat
  
  # participants for good i
  part <- dat1 %>%
    filter(Dtmp == 1) %>%
    filter(!is.na(.data[[CLVAR]])) %>%
    filter(is.finite(m), is.finite(lnp_Beer), is.finite(lnp_Wines), is.finite(lnp_Spirits))
  
  # ensure complete cases for stage2 variables
  need <- c(wcol(good), "lnp_Beer","lnp_Wines","lnp_Spirits","m", covars, "fe", CLVAR)
  if(include_m2) need <- c(need, "m2")
  if(include_imr) need <- c(need, "IMR")
  part <- part %>% filter(complete.cases(across(all_of(need))))
  
  if(nrow(part) < 30) return(NULL)
  
  # stage 2
  s2 <- fit_stage2(part, good, include_imr=include_imr, include_m2=include_m2)
  
  list(stage1 = s1$stage1, stage2 = s2$stage2, V = s2$V, part = part)
}

# Two-step pooled with interactions: prices * group_var
fit_two_step_int <- function(df, good, group_var, include_imr=TRUE, include_m2=TRUE){
  
  df <- df %>% mutate(G = factor(.data[[group_var]]))
  
  # stage 1 includes group
  D <- as.integer(df[[wcol(good)]] > 0)
  df$Dtmp <- D
  sel_fml <- as.formula(paste0("Dtmp ~ ", paste(c(covars, "m", "G"), collapse=" + ")))
  stage1 <- glm(
    sel_fml,
    data = df,
    family = quasibinomial(link = "probit"),
    weights = fe,
    control = glm.control(maxit = 100)
  )
  
  xb  <- as.numeric(model.matrix(stage1) %*% coef(stage1))
  Phi <- pnorm(xb); phi <- dnorm(xb)
  Phi <- pmin(pmax(Phi, 1e-8), 1 - 1e-8)
  
  IMR <- rep(0, nrow(df))
  sel <- df$Dtmp == 1
  IMR[sel] <- phi[sel] / Phi[sel]
  df$IMR <- IMR
  
  part <- df %>%
    filter(Dtmp == 1) %>%
    filter(!is.na(.data[[CLVAR]])) %>%
    filter(is.finite(m), is.finite(lnp_Beer), is.finite(lnp_Wines), is.finite(lnp_Spirits)) %>%
    mutate(G = factor(.data[[group_var]]))
  
  # stage2 formula
  rhs_prices <- "(lnp_Beer + lnp_Wines + lnp_Spirits) * G"
  rhs <- c(rhs_prices, "m")
  if(include_m2) rhs <- c(rhs, "I(m^2)")
  rhs <- c(rhs, covars)
  if(include_imr) rhs <- c(rhs, "IMR")
  
  fml <- as.formula(paste0(wcol(good), " ~ ", paste(rhs, collapse=" + ")))
  
  need <- c(wcol(good), "lnp_Beer","lnp_Wines","lnp_Spirits","m", covars, "fe", CLVAR, group_var)
  if(include_m2) need <- c(need, "m2")
  if(include_imr) need <- c(need, "IMR")
  part <- part %>% filter(complete.cases(across(all_of(need))))
  if(nrow(part) < 30) return(NULL)
  
  stage2 <- lm(fml, data = part, weights = fe)
  V <- sandwich::vcovCL(stage2, cluster = part[[CLVAR]], type = "HC1")
  
  list(stage1=stage1, stage2=stage2, V=V, part=part, group_var=group_var)
}

# ----------------------------
# 5) Runners to produce LONG tables with CIs
# ----------------------------

run_general <- function(df, R=1500, include_imr=TRUE, include_m2=TRUE){
  
  rows <- list()
  
  for(eq_good in goods_eq){
    fit <- fit_two_step_sep(df, eq_good, include_imr=include_imr, include_m2=include_m2)
    if(is.null(fit)) next
    
    wbar <- setNames(sapply(goods_eq, \(g) wmean(fit$part[[wcol(g)]], fit$part$fe)), goods_eq)
    wbar <- as.list(wbar)
    mbar <- wmean(fit$part$m, fit$part$fe)
    
    el_point <- elasticities(coef(fit$stage2), wbar, mbar, eq_good, use_m2=include_m2)
    draws <- parametric_boot(fit$stage2, fit$V, R=R)
    
    E_draw <- lapply(goods_eq, \(j) numeric(nrow(draws))); names(E_draw) <- goods_eq
    EXP_draw <- numeric(nrow(draws))
    
    for(r in seq_len(nrow(draws))){
      coefs_r <- as.list(draws[r,])
      el_r <- elasticities(coefs_r, wbar, mbar, eq_good, use_m2=include_m2)
      for(j in goods_eq) E_draw[[j]][r] <- el_r$price[[j]]
      EXP_draw[r] <- el_r$expenditure
    }
    
    for(j in goods_eq){
      ci <- quantile(E_draw[[j]], c(0.025, 0.975), na.rm=TRUE)
      rows[[length(rows)+1]] <- tibble(
        group_var = "general",
        group = "All",
        eq_good = eq_good,
        price = j,
        point = el_point$price[[j]],
        lo = ci[[1]],
        hi = ci[[2]],
        n_part = nrow(fit$part)
      )
    }
    
    ciE <- quantile(EXP_draw, c(0.025, 0.975), na.rm=TRUE)
    rows[[length(rows)+1]] <- tibble(
      group_var="general", group="All", eq_good=eq_good, price="Expenditure",
      point=el_point$expenditure, lo=ciE[[1]], hi=ciE[[2]], n_part=nrow(fit$part)
    )
  }
  
  bind_rows(rows)
}

run_interactions <- function(df, group_var, R=1500, include_imr=TRUE, include_m2=TRUE){
  
  rows <- list()
  
  for(eq_good in goods_eq){
    
    fit <- fit_two_step_int(df, eq_good, group_var=group_var, include_imr=include_imr, include_m2=include_m2)
    if(is.null(fit)) next
    
    part <- fit$part %>% mutate(G = factor(.data[[group_var]]))
    G_levels <- levels(part$G)
    
    means_by_g <- part %>%
      group_by(G) %>%
      summarise(
        mbar = wmean(m, fe),
        wBeer = wmean(hh_share_Beer, fe),
        wWines = wmean(hh_share_Wines, fe),
        wSpirits = wmean(hh_share_Spirits, fe),
        n_part = n(),
        .groups="drop"
      )
    
    # helper to get group-specific gamma_ij from base + interaction
    get_gamma <- function(coefs, price_var, glevel){
      base <- coefs[[price_var]]; if(is.na(base)) base <- 0
      if(glevel == G_levels[1]) return(base)
      term1 <- paste0(price_var, ":G", glevel)
      term2 <- paste0("G", glevel, ":", price_var)
      add <- 0
      if(!is.na(coefs[[term1]])) add <- coefs[[term1]]
      else if(!is.na(coefs[[term2]])) add <- coefs[[term2]]
      base + add
    }
    
    el_for_coefs <- function(coefs){
      out <- list()
      beta_i <- coefs[["m"]]
      lam_i  <- if(include_m2) coefs[["I(m^2)"]] else 0
      if(is.na(lam_i)) lam_i <- 0
      
      for(gv in G_levels){
        rowm <- means_by_g %>% filter(G == gv)
        wbar <- list(Beer=rowm$wBeer, Wines=rowm$wWines, Spirits=rowm$wSpirits)
        mbar <- rowm$mbar
        wi <- wbar[[eq_good]]
        
        gamma <- list(
          Beer    = get_gamma(coefs, "lnp_Beer", gv),
          Wines   = get_gamma(coefs, "lnp_Wines", gv),
          Spirits = get_gamma(coefs, "lnp_Spirits", gv)
        )
        
        deriv <- list(
          Beer    = gamma$Beer    - (beta_i + 2*lam_i*mbar)*wbar$Beer,
          Wines   = gamma$Wines   - (beta_i + 2*lam_i*mbar)*wbar$Wines,
          Spirits = gamma$Spirits - (beta_i + 2*lam_i*mbar)*wbar$Spirits
        )
        
        e <- list(
          Beer    = deriv$Beer    / pmax(wi,1e-12) - ifelse(eq_good=="Beer",1,0),
          Wines   = deriv$Wines   / pmax(wi,1e-12) - ifelse(eq_good=="Wines",1,0),
          Spirits = deriv$Spirits / pmax(wi,1e-12) - ifelse(eq_good=="Spirits",1,0)
        )
        eexp <- 1 + (beta_i + 2*lam_i*mbar)/pmax(wi,1e-12)
        
        out[[gv]] <- list(price=e, expenditure=eexp)
      }
      out
    }
    
    point_list <- el_for_coefs(coef(fit$stage2))
    
    draws <- parametric_boot(fit$stage2, fit$V, R=R)
    
    collect <- list()
    for(gv in G_levels){
      collect[[gv]] <- list(
        Beer = numeric(nrow(draws)),
        Wines = numeric(nrow(draws)),
        Spirits = numeric(nrow(draws)),
        Expenditure = numeric(nrow(draws))
      )
    }
    
    for(r in seq_len(nrow(draws))){
      coefs_r <- as.list(draws[r,])
      el_r <- el_for_coefs(coefs_r)
      for(gv in G_levels){
        collect[[gv]]$Beer[r] <- el_r[[gv]]$price$Beer
        collect[[gv]]$Wines[r] <- el_r[[gv]]$price$Wines
        collect[[gv]]$Spirits[r] <- el_r[[gv]]$price$Spirits
        collect[[gv]]$Expenditure[r] <- el_r[[gv]]$expenditure
      }
    }
    
    for(gv in G_levels){
      rowm <- means_by_g %>% filter(G == gv)
      for(pj in goods_eq){
        ci <- quantile(collect[[gv]][[pj]], c(0.025,0.975), na.rm=TRUE)
        rows[[length(rows)+1]] <- tibble(
          group_var = group_var,
          group = as.character(gv),
          eq_good = eq_good,
          price = pj,
          point = as.numeric(point_list[[gv]]$price[[pj]]),
          lo = ci[[1]],
          hi = ci[[2]],
          n_part = rowm$n_part
        )
      }
      ciE <- quantile(collect[[gv]]$Expenditure, c(0.025,0.975), na.rm=TRUE)
      rows[[length(rows)+1]] <- tibble(
        group_var=group_var, group=as.character(gv), eq_good=eq_good, price="Expenditure",
        point=as.numeric(point_list[[gv]]$expenditure), lo=ciE[[1]], hi=ciE[[2]], n_part=rowm$n_part
      )
    }
  }
  
  bind_rows(rows)
}

# ----------------------------
# 6) Plot heatmap “cor-matrix” (price elasticities only)
# ----------------------------
plot_elasticity_matrix <- function(tab_long, facet=FALSE, title=NULL, subtitle=NULL, digits=2, out_png=NULL){
  
  dd <- tab_long %>%
    filter(price %in% goods_eq) %>%
    mutate(
      eq_good = factor(eq_good, levels = goods_eq),
      price   = factor(price,   levels = goods_eq),
      label   = sprintf(paste0("%.",digits,"f"), point)
    )
  
  lim <- max(abs(dd$point), na.rm = TRUE)
  lim <- max(lim, 0.5)
  
  p <- ggplot(dd, aes(x=price, y=eq_good, fill=point)) +
    geom_tile(color="grey85", linewidth=0.4) +
    geom_text(aes(label=label), size=3) +
    coord_equal() +
    scale_fill_gradient2(low="#2b6cb0", mid="white", high="#c53030",
                         midpoint=0, limits=c(-lim, lim)) +
    labs(title=title, subtitle=subtitle, x="Price (ln p_j)", y="Equation (w_i)", fill="Elasticity") +
    theme_minimal(base_size=12) +
    theme(panel.grid=element_blank(),
          axis.title=element_text(face="bold"),
          plot.title=element_text(face="bold"))
  
  if(facet){
    p <- p + facet_wrap(~ group)
  }
  
  if(!is.null(out_png)){
    ggsave(out_png, p, width = if(facet) 10 else 6, height = if(facet) 6 else 5, dpi = 300)
  }
  
  p
}

# ============================================================
# 7) RUN SENSITIVITY A and B
# ============================================================

# --- Sensitivity A: NO IMR
tab_A_general <- run_general(df, R=R_BOOT, include_imr=FALSE, include_m2=TRUE)
tab_A_quint   <- run_interactions(df, "quintil", R=R_BOOT, include_imr=FALSE, include_m2=TRUE)
tab_A_ohcat   <- run_interactions(df, "oh_cat",  R=R_BOOT, include_imr=FALSE, include_m2=TRUE)

write.csv(tab_A_general, "elasticities_sensA_general_long.csv", row.names=FALSE)
write.csv(tab_A_quint,   "elasticities_sensA_quintil_long.csv", row.names=FALSE)
write.csv(tab_A_ohcat,   "elasticities_sensA_ohcat_long.csv", row.names=FALSE)

pA_gen <- plot_elasticity_matrix(tab_A_general, facet=FALSE,
                                 title="Sensitivity A (No IMR): General", subtitle="Price elasticities (Marshallian)",
                                 out_png="heatmap_sensA_general.png"
)
pA_q   <- plot_elasticity_matrix(tab_A_quint, facet=TRUE,
                                 title="Sensitivity A (No IMR): By quintile (interactions)", subtitle="Facets = quintile",
                                 out_png="heatmap_sensA_quintil.png"
)
pA_oh  <- plot_elasticity_matrix(tab_A_ohcat, facet=TRUE,
                                 title="Sensitivity A (No IMR): By OH category (interactions)", subtitle="Facets = OH category",
                                 out_png="heatmap_sensA_ohcat.png"
)

# --- Sensitivity B: AIDS (no m^2)
tab_B_general <- run_general(df, R=R_BOOT, include_imr=TRUE, include_m2=FALSE)
tab_B_quint   <- run_interactions(df, "quintil", R=R_BOOT, include_imr=TRUE, include_m2=FALSE)
tab_B_ohcat   <- run_interactions(df, "oh_cat",  R=R_BOOT, include_imr=TRUE, include_m2=FALSE)

write.csv(tab_B_general, "elasticities_sensB_general_long.csv", row.names=FALSE)
write.csv(tab_B_quint,   "elasticities_sensB_quintil_long.csv", row.names=FALSE)
write.csv(tab_B_ohcat,   "elasticities_sensB_ohcat_long.csv", row.names=FALSE)

pB_gen <- plot_elasticity_matrix(tab_B_general, facet=FALSE,
                                 title="Sensitivity B (AIDS: no m^2): General", subtitle="Price elasticities (Marshallian)",
                                 out_png="heatmap_sensB_general.png"
)
pB_q   <- plot_elasticity_matrix(tab_B_quint, facet=TRUE,
                                 title="Sensitivity B (AIDS: no m^2): By quintile (interactions)", subtitle="Facets = quintile",
                                 out_png="heatmap_sensB_quintil.png"
)
pB_oh  <- plot_elasticity_matrix(tab_B_ohcat, facet=TRUE,
                                 title="Sensitivity B (AIDS: no m^2): By OH category (interactions)", subtitle="Facets = OH category",
                                 out_png="heatmap_sensB_ohcat.png"
)

message("Done. Files saved in working directory:
- elasticities_sensA_*_long.csv, heatmap_sensA_*.png
- elasticities_sensB_*_long.csv, heatmap_sensB_*.png
")



# DESCRIPTIVES
df %>%
  summarise(
    zero_beer    = mean(hh_share_Beer == 0),
    zero_wines   = mean(hh_share_Wines == 0),
    zero_spirits = mean(hh_share_Spirits == 0)
  )

df2 <- df %>%
  mutate(
    D_beer    = as.integer(hh_share_Beer > 0),
    D_wines   = as.integer(hh_share_Wines > 0),
    D_spirits = as.integer(hh_share_Spirits > 0)
  )
cor(df2[,c("D_beer","D_wines","D_spirits")])

# total
var_total <- var(df_main$lnp_Beer_deaton, na.rm=TRUE)

# between
between_df <- df_main %>%
  group_by(cluster_psu_year) %>%
  summarise(mean_cluster = mean(lnp_Beer_deaton, na.rm=TRUE),
            n = n(),
            .groups="drop")

var_between <- var(between_df$mean_cluster)

# within (weighted by cluster size)
var_within <- df_main %>%
  group_by(cluster_psu_year) %>%
  summarise(v = var(lnp_Beer_deaton, na.rm=TRUE),
            .groups="drop") %>%
  summarise(mean(v, na.rm=TRUE)) %>%
  pull()

var_total
var_between
var_within
var_between + var_within

df_main %>%
  group_by(cluster_psu_year) %>%
  summarise(n = n()) %>%
  summarise(
    clusters = n(),
    mean_n = mean(n),
    median_n = median(n),
    p10 = quantile(n, 0.10),
    p90 = quantile(n, 0.90)
  )
df_main %>%
  mutate(cluster_estrato_year = paste0(estrato_muestreo, "_", year)) %>%
  count(cluster_estrato_year, name="n") %>%
  summarise(
    clusters = n(),
    mean_n = mean(n),
    median_n = median(n),
    p10 = quantile(n, 0.10),
    p90 = quantile(n, 0.90),
    share_lt10 = mean(n < 10),
    share_lt20 = mean(n < 20)
  )
