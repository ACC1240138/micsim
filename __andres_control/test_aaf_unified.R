# =============================================================================
# test_aaf_unified.R
# Pruebas del motor unificado aaf_unified.R.
#
# Niveles de prueba:
#   [EXACTO]  el punto deterministico de aaf_point debe COINCIDIR (1e-9) con las
#             formulas ya existentes (.aaf_cv del binge IHD/IS, y la formula
#             deterministica de confint_paf_vcov_parallel), demostrando que es
#             una generalizacion fiel y no una reimplementacion divergente.
#   [TOGGLE]  cada feature opcional (HED, multi-beta+cov, RR_FD+varianza) cambia
#             el resultado en la direccion esperada.
#   [LEGADO]  la media MC de aaf_confint reproduce (tolerancia MC) a
#             confint_paf_vcov_parallel.
#   [REAL]    corre sobre un objeto RR real del registro Adam (cancer, IHD).
#
# Correr:
#   & 'C:\Program Files\R\R-4.4.1\bin\Rscript.exe' __andres_control\test_aaf_unified.R
# =============================================================================

setwd_control <- function() {
  if (file.exists("aaf_unified.R")) return(invisible())
  if (file.exists("__andres_control/aaf_unified.R")) { setwd("__andres_control"); return(invisible()) }
  stop("No encuentro aaf_unified.R")
}
setwd_control()

suppressMessages(source("aaf_unified.R"))
options(width = 150)

n_fail <- 0L
check <- function(cond, msg, extra = "") {
  status <- if (isTRUE(cond)) "PASS" else { n_fail <<- n_fail + 1L; "FAIL" }
  cat(sprintf("[%s] %s%s\n", status, msg, if (nzchar(extra)) paste0("  -> ", extra) else ""))
}
approx_eq <- function(a, b, tol = 1e-9) is.finite(a) && is.finite(b) && abs(a - b) <= tol

x <- seq(0.1, 150, length.out = 800)

# -----------------------------------------------------------------------------
cat("\n========== [EXACTO] aaf_point vs formula vcov deterministica (sin HED) ==========\n")
# Referencia: exactamente el calc_one (punto) de confint_paf_vcov_parallel.
ref_point_nohed <- function(x, rr, p_abs, p_form, rr_fd, shape, rate) {
  y <- dgamma(x, shape = shape, rate = rate)
  dx <- x[2] - x[1]
  ncg <- sum((y[-1] + y[-length(y)]) / 2) * dx
  ny <- (1 - (p_abs + p_form)) * y / ncg
  w <- ny * (rr - 1)
  num <- (rr_fd - 1) * p_form + sum((w[-1] + w[-length(w)]) / 2) * dx
  num / (num + 1)
}
rr_lin <- exp(0.02 * x)                      # RR creciente simple
shp <- 0.9; rt <- 0.04
ref1 <- ref_point_nohed(x, rr_lin, 0.30, 0.06, 1.3, shp, rt)
uni1 <- aaf_point(x, rr_nhed = rr_lin, p_abs = 0.30, p_form = 0.06, rr_fd = 1.3,
                  gamma = list(estimate = c(shape = shp, rate = rt)))
check(approx_eq(ref1, uni1), "punto sin HED == formula vcov", sprintf("ref=%.10f uni=%.10f", ref1, uni1))

# -----------------------------------------------------------------------------
cat("\n========== [EXACTO] aaf_point vs .aaf_cv (HED cap, J-curve IHD) ==========\n")
suppressMessages(source("ihd_is_binge_aaf.R"))   # define IHD/IS RR objs + .aaf_cv
obj <- IHDmaleMORT_3
rr_n <- obj$RRCurrent(x, obj$betaCurrent)
rr_h <- pmax(rr_n, 1)
y_n <- dgamma(x, shape = 0.70, rate = 0.030)
y_h <- dgamma(x, shape = 0.95, rate = 0.020)
rr_fd_ihd <- exp(obj$lnRRFormer)
ref2 <- .aaf_cv(x, y_n, y_h, rr_n, rr_h, p_abs = 0.15, p_form = 0.05, rr_fd = rr_fd_ihd, p_hed = 0.4)
uni2 <- aaf_point(x, rr_nhed = rr_n, p_abs = 0.15, p_form = 0.05, rr_fd = rr_fd_ihd,
                  y_nhed = y_n, p_hed = 0.4, rr_hed = "cap", y_hed = y_h)
check(approx_eq(ref2, uni2), "punto HED-cap == .aaf_cv", sprintf("ref=%.10f uni=%.10f", ref2, uni2))

# -----------------------------------------------------------------------------
cat("\n========== [EXACTO] aaf_point HED explicit (injuries) vs formula a mano ==========\n")
# Modelo de DOS componentes: NHED con beta1; HED con RRCurrent_binge(beta1,beta2).
b1 <- 0.003; b2 <- 0.70
rr_nh_fun <- function(x, beta) ifelse(x < 1, exp(beta[1]), exp(beta[1] * x))
rr_he_fun <- function(x, beta) ifelse(x < 1, exp(beta[2] + beta[1]), exp(beta[2] + beta[1] * x))
rr_nh <- rr_nh_fun(x, c(b1, b2)); rr_he <- rr_he_fun(x, c(b1, b2))
ref3 <- {
  cur <- 1 - (0.20 + 0.07)
  dn <- y_n / .aaf_trapz(x, y_n); dh <- y_h / .aaf_trapz(x, y_h)
  I_n <- .aaf_trapz(x, dn * (rr_nh - 1)); I_h <- .aaf_trapz(x, dh * (rr_he - 1))
  num <- (1 - 1) * 0.07 + cur * ((1 - 0.35) * I_n + 0.35 * I_h)
  num / (num + 1)
}
uni3 <- aaf_point(x, rr_nhed = rr_nh, p_abs = 0.20, p_form = 0.07, rr_fd = 1,
                  y_nhed = y_n, p_hed = 0.35, rr_hed = rr_he, y_hed = y_h)
check(approx_eq(ref3, uni3), "punto HED-explicit == formula 2-componentes", sprintf("ref=%.10f uni=%.10f", ref3, uni3))

# -----------------------------------------------------------------------------
cat("\n========== [TOGGLE] HED-cap sube la AAF monotonicamente con p_hed (cardio) ==========\n")
aaf_by_phed <- sapply(c(0, 0.2, 0.45, 0.8), function(ph)
  aaf_point(x, rr_nhed = rr_n, p_abs = 0.15, p_form = 0.05, rr_fd = rr_fd_ihd,
            y_nhed = y_n, p_hed = ph, rr_hed = "cap", y_hed = y_h))
cat("   p_hed 0/0.2/0.45/0.8 -> AAF:", paste(sprintf("% .4f", aaf_by_phed), collapse = "  "), "\n")
check(all(diff(aaf_by_phed) > 0), "AAF estrictamente creciente en p_hed")

# -----------------------------------------------------------------------------
cat("\n========== [TOGGLE] multi-beta + covarianza ENSANCHA el IC vs betas fijos ==========\n")
rr_quad <- function(x, beta) exp(beta[1] * x + beta[2] * x^2 / 100)
beta_q <- c(0.015, -0.004)
cov_q  <- matrix(c(0.004^2, -1e-6, -1e-6, 0.0015^2), 2, 2)
g_syn <- list(estimate = c(shape = 0.9, rate = 0.04))
ci_fixed <- aaf_confint(gamma = g_syn, rr_fun = rr_quad, beta = beta_q, cov_beta = NULL,
                        p_abs = 0.30, p_form = 0.06, rr_fd = 1.2, x = x,
                        n_sim = 1500, n_pca = 250, seed = 11, fd_uncertainty = FALSE)
ci_cov   <- aaf_confint(gamma = g_syn, rr_fun = rr_quad, beta = beta_q, cov_beta = cov_q,
                        p_abs = 0.30, p_form = 0.06, rr_fd = 1.2, x = x,
                        n_sim = 1500, n_pca = 250, seed = 11, fd_uncertainty = FALSE)
w_fixed <- ci_fixed$upper_ci - ci_fixed$lower_ci
w_cov   <- ci_cov$upper_ci   - ci_cov$lower_ci
cat(sprintf("   ancho IC fijo=%.4f  con-cov=%.4f\n", w_fixed, w_cov))
check(w_cov > w_fixed * 1.5, "IC con covarianza notablemente mas ancho")
check(approx_eq(ci_fixed$point_estimate, ci_cov$point_estimate, 1e-12),
      "el punto deterministico NO cambia al activar covarianza")

# -----------------------------------------------------------------------------
cat("\n========== [TOGGLE] varianza de RR_FD ENSANCHA la cola superior (Jensen) ==========\n")
ci_fd0 <- aaf_confint(gamma = g_syn, rr_fun = rr_quad, beta = beta_q, cov_beta = cov_q,
                      p_abs = 0.20, p_form = 0.15, ln_rr_fd = log(2.5), var_ln_rr_fd = 0,
                      x = x, n_sim = 2000, n_pca = 250, seed = 22, fd_uncertainty = TRUE)
ci_fdv <- aaf_confint(gamma = g_syn, rr_fun = rr_quad, beta = beta_q, cov_beta = cov_q,
                      p_abs = 0.20, p_form = 0.15, ln_rr_fd = log(2.5), var_ln_rr_fd = 0.25^2,
                      x = x, n_sim = 2000, n_pca = 250, seed = 22, fd_uncertainty = TRUE)
cat(sprintf("   upper sin var=%.4f  con var=%.4f\n", ci_fd0$upper_ci, ci_fdv$upper_ci))
check(ci_fdv$upper_ci > ci_fd0$upper_ci, "varianza RR_FD eleva el limite superior")
check(approx_eq(ci_fd0$point_estimate, ci_fdv$point_estimate, 1e-12),
      "el punto deterministico NO cambia al activar varianza RR_FD")

# -----------------------------------------------------------------------------
cat("\n========== [LEGADO] media MC de aaf_confint ~ confint_paf_vcov_parallel ==========\n")
suppressMessages(source("confint_paf_parallel.R"))
NN <- 2500; MM <- 300; SS <- 7
leg <- confint_paf_vcov_parallel(gamma = g_syn, betas = beta_q, cov_matrix = cov_q,
                                 p_abs = 0.30, p_form = 0.06, rr_fd = 1.2,
                                 rr_function = rr_quad, x = x, n_sim = NN, n_pca = MM,
                                 seed = SS, use_parallel = FALSE, rng_parallel = FALSE,
                                 return_sims = TRUE)
uni <- aaf_confint(gamma = g_syn, rr_fun = rr_quad, beta = beta_q, cov_beta = cov_q,
                   p_abs = 0.30, p_form = 0.06, rr_fd = 1.2, x = x, n_sim = NN, n_pca = MM,
                   seed = SS, fd_uncertainty = FALSE, prev_method = "binomial", return_sims = TRUE)
mean_leg <- mean(leg$simulated_pafs); mean_uni <- mean(uni$simulated_pafs)
cat(sprintf("   media MC legado=%.4f  unif=%.4f   q025 leg=%.4f unif=%.4f   q975 leg=%.4f unif=%.4f\n",
            mean_leg, mean_uni, unname(leg$lower_ci), uni$lower_ci, unname(leg$upper_ci), uni$upper_ci))
check(approx_eq(mean_leg, mean_uni, 0.02), "media MC dentro de tolerancia (0.02)")
check(approx_eq(unname(leg$lower_ci), uni$lower_ci, 0.03) &&
        approx_eq(unname(leg$upper_ci), uni$upper_ci, 0.03), "cuantiles IC dentro de tolerancia (0.03)")

# -----------------------------------------------------------------------------
cat("\n========== [REAL] objeto cancer del registro Adam end-to-end ==========\n")
suppressMessages(source("rr_registry_adam.R"))
reg_c <- load_adam_rr_registry(scope = "cancer")
rec <- reg_c[["male::Livercancer_male"]]
if (is.null(rec)) rec <- reg_c[[1]]
res_c <- aaf_confint(gamma = list(estimate = c(shape = 0.85, rate = 0.03)),
                     rr_fun = rec$RRCurrent, beta = rec$betaCurrent, cov_beta = rec$covBetaCurrent,
                     p_abs = 0.30, p_form = 0.07,
                     ln_rr_fd = rec$lnRRFormer, var_ln_rr_fd = rec$varLnRRFormer,
                     x = x, n_sim = 800, n_pca = 200, seed = 2125)
cat(sprintf("   %s: point=%.4f  CI=[%.4f, %.4f]  n_used=%d\n",
            rec$source_object, res_c$point_estimate, res_c$lower_ci, res_c$upper_ci, res_c$n_used))
check(res_c$lower_ci <= res_c$point_estimate + 1e-6 && res_c$point_estimate <= res_c$upper_ci + 1e-6,
      "IC ordenado lower<=point<=upper")
check(res_c$upper_ci <= 1 + 1e-9, "AAF <= 1")

# -----------------------------------------------------------------------------
cat("\n========== [REAL] IHD J-curve+binge (cardio) deja pasar AAF firmada ==========\n")
res_ihd <- aaf_confint(gamma = list(estimate = c(shape = 0.70, rate = 0.030)),
                       rr_fun = obj$RRCurrent, beta = obj$betaCurrent, cov_beta = obj$covBetaCurrent,
                       p_abs = 0.15, p_form = 0.05,
                       ln_rr_fd = obj$lnRRFormer, var_ln_rr_fd = obj$varLnRRFormer,
                       x = x, p_hed = 0.30, gamma_hed = list(estimate = c(shape = 0.95, rate = 0.020)),
                       hed_mode = "cap", n_sim = 800, n_pca = 200, seed = 2125)
cat(sprintf("   IHD male 65+ p_hed=0.30: point=%.4f  CI=[%.4f, %.4f]\n",
            res_ihd$point_estimate, res_ihd$lower_ci, res_ihd$upper_ci))
check(res_ihd$lower_ci <= res_ihd$point_estimate + 1e-6 && res_ihd$point_estimate <= res_ihd$upper_ci + 1e-6,
      "IC IHD ordenado")
check(res_ihd$upper_ci <= 1 + 1e-9, "AAF IHD <= 1 (puede ser negativa por abajo)")

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
cat("\n========== [UNIFICACION] PAF == (R_obs - 1)/R_obs (PIF de eliminacion total) ==========\n")
# El PAF es el PIF cuyo contrafactual es R_cf = 1 (cero alcohol). Verifica que
# aaf_point coincide con la identidad poblacional armada con los helpers del PIF,
# probando que PAF y PIF usan EXACTAMENTE el mismo R_obs.
yU  <- dgamma(x, shape = shp, rate = rt)
RnU <- .aaf_risk(x, yU, rr_lin)
RoU <- .aaf_pop_R(p_abs = 0.30, p_form = 0.06, rr_fd = 1.3, p_hed = 0,
                  R_nhed = RnU, use_hed = FALSE)
paf_uni <- aaf_point(x, rr_nhed = rr_lin, p_abs = 0.30, p_form = 0.06, rr_fd = 1.3, y_nhed = yU)
check(approx_eq(paf_uni, (RoU - 1) / RoU),
      "PAF = (R_obs-1)/R_obs  -> mismo R_obs que el PIF",
      sprintf("paf=%.10f  ident=%.10f", paf_uni, (RoU - 1) / RoU))

# -----------------------------------------------------------------------------
cat("\n========== [PIF-HED] monotono en la reduccion; shift=1 -> 0 ==========\n")
pif_shift <- sapply(c(1, 0.9, 0.7, 0.5), function(s)
  pif_point(x, rr_nhed = rr_nh_fun, beta = c(b1, b2),
            p_abs = 0.20, p_form = 0.07, rr_fd = 1,
            y_nhed = y_n, p_hed = 0.35, rr_hed = rr_he_fun, y_hed = y_h,
            scenario = "hed", shift = s))
cat("   shift 1/0.9/0.7/0.5 -> PIF:", paste(sprintf("% .4f", pif_shift), collapse = "  "), "\n")
check(approx_eq(pif_shift[1], 0, 1e-9), "PIF(hed, shift=1) == 0")
check(all(diff(pif_shift) > 0), "PIF(hed) crece al reducir mas el binge")

# -----------------------------------------------------------------------------
cat("\n========== [PIF-VOL] reduccion de volumen 10% -> PIF en (0,1) ==========\n")
pif_vol  <- pif_point(x, rr_nhed = rr_nh_fun, beta = c(b1, b2),
                      p_abs = 0.20, p_form = 0.07, rr_fd = 1,
                      y_nhed = y_n, p_hed = 0.35, rr_hed = rr_he_fun, y_hed = y_h,
                      scenario = "volume", shift = 0.9)
pif_vol0 <- pif_point(x, rr_nhed = rr_nh_fun, beta = c(b1, b2),
                      p_abs = 0.20, p_form = 0.07, rr_fd = 1,
                      y_nhed = y_n, p_hed = 0.35, rr_hed = rr_he_fun, y_hed = y_h,
                      scenario = "volume", shift = 1)
cat(sprintf("   PIF vol(shift=0.9)=%.4f   PIF vol(shift=1)=%.4f\n", pif_vol, pif_vol0))
check(approx_eq(pif_vol0, 0, 1e-9), "PIF(vol, shift=1) == 0")
check(pif_vol > 0 && pif_vol < 1, "PIF(vol) en (0,1) para RR creciente")

# -----------------------------------------------------------------------------
cat("\n========== [PREV] Dirichlet no colapsa en alta abstinencia (cur>0) ==========\n")
set.seed(7)
cur_dir <- replicate(3000, { d <- .aaf_draw_prev(0.85, 0.12, 0.30, TRUE, 300, "dirichlet"); 1 - (d$p_abs + d$p_form) })
cur_bin <- replicate(3000, { d <- .aaf_draw_prev(0.85, 0.12, 0.30, TRUE, 300, "binomial");  1 - (d$p_abs + d$p_form) })
cat(sprintf("   cur<=0: dirichlet=%d/3000  binomial=%d/3000\n", sum(cur_dir <= 0), sum(cur_bin <= 0)))
check(all(cur_dir > 0), "Dirichlet: bebedores actuales > 0 SIEMPRE")
check(any(cur_bin <= 0), "binomial: colapsa (cur<=0) en alta abstinencia")

# -----------------------------------------------------------------------------
cat("\n========== [PIF-CI] pif_confint (injuries explicit) ordenado; serial==paralelo ==========\n")
# Caso realista de injuries: NHED con beta1, HED con RRCurrent_binge(beta1,beta2),
# share_beta1 (el b1 del sorteo binge se reusa en el NHED). PIF de reduccion de HED.
pif_args <- list(gamma = list(estimate = c(shape = 0.9, rate = 0.04)),
                 rr_fun = rr_nh_fun, beta = c(b1),
                 p_abs = 0.20, p_form = 0.07, rr_fd = 1, x = x,
                 p_hed = 0.35, gamma_hed = list(estimate = c(shape = 0.95, rate = 0.02)),
                 rr_fun_hed = rr_he_fun, beta_hed = c(b1, b2),
                 cov_beta_hed = diag(c(0.001^2, 0.1^2)),
                 hed_mode = "explicit", share_beta1 = TRUE,
                 scenario = "hed", shift = 0.9,
                 n_sim = 1500, n_pca = 250, seed = 33, return_sims = TRUE)
pif_ci_s <- do.call(pif_confint, c(pif_args, list(use_parallel = FALSE)))
pif_ci_p <- do.call(pif_confint, c(pif_args, list(use_parallel = TRUE, n_cores = 4L)))
cat(sprintf("   PIF point=%.4f CI=[%.4f, %.4f]\n", pif_ci_s$point_estimate, pif_ci_s$lower_ci, pif_ci_s$upper_ci))
check(pif_ci_s$point_estimate > 0, "PIF(hed) explicit > 0 (reducir binge evita riesgo)")
check(pif_ci_s$lower_ci <= pif_ci_s$point_estimate + 1e-6 && pif_ci_s$point_estimate <= pif_ci_s$upper_ci + 1e-6, "IC PIF ordenado")
check(pif_ci_s$upper_ci <= 1 + 1e-9, "PIF <= 1")
check(identical(length(pif_ci_s$simulated_pifs), length(pif_ci_p$simulated_pifs)) &&
        max(abs(pif_ci_s$simulated_pifs - pif_ci_p$simulated_pifs)) < 1e-12,
      "PIF serial == paralelo (bit a bit)")

# -----------------------------------------------------------------------------
cat("\n========== [PARALELO] serial == paralelo (reproducible, bit a bit) ==========\n")
serial <- aaf_confint(gamma = g_syn, rr_fun = rr_quad, beta = beta_q, cov_beta = cov_q,
                      p_abs = 0.30, p_form = 0.06, ln_rr_fd = log(2.2), var_ln_rr_fd = 0.2^2,
                      x = x, n_sim = 2000, n_pca = 250, seed = 99,
                      use_parallel = FALSE, return_sims = TRUE)
par4 <- aaf_confint(gamma = g_syn, rr_fun = rr_quad, beta = beta_q, cov_beta = cov_q,
                    p_abs = 0.30, p_form = 0.06, ln_rr_fd = log(2.2), var_ln_rr_fd = 0.2^2,
                    x = x, n_sim = 2000, n_pca = 250, seed = 99,
                    use_parallel = TRUE, n_cores = 4L, return_sims = TRUE)
cat(sprintf("   serial point=%.6f CI=[%.6f,%.6f] | par(4) point=%.6f CI=[%.6f,%.6f]\n",
            serial$point_estimate, serial$lower_ci, serial$upper_ci,
            par4$point_estimate, par4$lower_ci, par4$upper_ci))
check(identical(length(serial$simulated_pafs), length(par4$simulated_pafs)) &&
        max(abs(serial$simulated_pafs - par4$simulated_pafs)) < 1e-12,
      "vector completo de simulaciones IDENTICO serial vs 4 cores",
      sprintf("max|diff|=%.2e", max(abs(serial$simulated_pafs - par4$simulated_pafs))))

cat("\n========== [PARALELO] usa multiples nucleos + speedup ==========\n")
nc <- parallel::detectCores(logical = TRUE)
cat(sprintf("   detectCores=%d\n", nc))
if (is.finite(nc) && nc >= 4L) {
  t1 <- system.time(aaf_confint(gamma = g_syn, rr_fun = rr_quad, beta = beta_q, cov_beta = cov_q,
                                p_abs = 0.30, p_form = 0.06, rr_fd = 1.2, x = x,
                                n_sim = 6000, n_pca = 400, seed = 5, use_parallel = FALSE))[["elapsed"]]
  t4 <- system.time(aaf_confint(gamma = g_syn, rr_fun = rr_quad, beta = beta_q, cov_beta = cov_q,
                                p_abs = 0.30, p_form = 0.06, rr_fd = 1.2, x = x,
                                n_sim = 6000, n_pca = 400, seed = 5, use_parallel = TRUE, n_cores = 4L))[["elapsed"]]
  cat(sprintf("   t(1 core)=%.2fs  t(4 cores)=%.2fs  speedup=%.2fx\n", t1, t4, t1 / t4))
  check(t4 < t1, "4 cores mas rapido que 1 (hay paralelizacion real)")
} else {
  cat("   (maquina con <4 cores: se omite la prueba de speedup)\n")
}

# -----------------------------------------------------------------------------
cat("\n=============================================================\n")
if (n_fail == 0L) {
  cat("TODOS LOS TESTS DE aaf_unified PASARON.\n")
} else {
  cat(sprintf("FALLARON %d test(s) de aaf_unified.\n", n_fail))
  quit(status = 1L)
}
