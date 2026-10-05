# =============================================================================
# test_hed_exit_knobs.R   [2026-07-14]
# -----------------------------------------------------------------------------
# Validation suite for the HED-EXIT REASSIGNMENT knobs added to aaf_unified.R:
#
#   hed_exit_mix   = lambda in [0, 1]  share of the mass leaving binge that migrates
#                                      to the NHED consumption DISTRIBUTION (i.e. it
#                                      ends up drinking like an average non-HED
#                                      drinker, risk R_nhed).
#   hed_exit_shift = rho in (0, 1]     volume that same mass RETAINS: it keeps the
#                                      SHAPE of its own density d_hed but drinks rho
#                                      of the grams, so its RR is read at x*rho.
#
#   R_exit = (1 - lambda) * R(d_hed, RR_NHED(x*rho)) + lambda * R_nhed
#
# WHY THIS MATTERS. Before this change the exiting mass kept its own d_hed density and
# merely swapped onto the RR_NHED curve: quitting binge removed the binge-specific
# excess risk but not a single gram of alcohol, so the HED scenarios were
# volume-neutral by construction. Ruiz-Tagle's reallocation (and any alcohol
# transition model) instead assumes the ex-binge drinker KEEPS DRINKING as a non-HED
# drinker, retaining only the residual risk of the volume he actually ends up
# consuming. The knobs turn those two positions into the endpoints of one family.
#
# THE TWO PROPERTIES THIS SUITE EXISTS TO PROVE:
#
#   (A) BACKWARD COMPATIBILITY. With the defaults (NULL -> lambda = 0, rho = 1) every
#       PIF must be BIT-FOR-BIT identical to the engine at git HEAD. Anything already
#       computed and reported stays valid.
#
#   (B) SEMANTICS. lambda = 1 must reproduce EXACTLY the old scale_phed semantics of
#       pif_scenarios.R (the exiting mass falls into the R_nhed bin), which is
#       algebraically the population risk evaluated at p_hed' = shift * p_hed. Since
#       R = 1/(1 - AAF) and PIF = 1 - R_cf/R_obs, that yields a closed-form identity
#       against the INDEPENDENT AAF engine:
#
#           PIF(lambda = 1) == 1 - (1 - AAF(p_hed)) / (1 - AAF(shift * p_hed))
#
#       This is the strongest available check: it ties the new code path to a formula
#       that does not go through .pif_core at all.
#
# Run:  Rscript __andres_control/test_hed_exit_knobs.R
# =============================================================================
.t0 <- Sys.time()

if (!exists("acc_root")) source(here::here("_tools", "acc_data.R"))
ROOT     <- acc_root()
CUR      <- file.path(ROOT, "__andres_control", "aaf_unified.R")
HEAD_SRC <- file.path(tempdir(), "aaf_unified_HEAD.R")

cat("=============================================================\n")
cat(" HED-exit knobs (hed_exit_mix / hed_exit_shift) -- aaf_unified.R\n")
cat("=============================================================\n")

# ---- (0) Pull the pre-change engine straight out of git ----------------------
# The backward-compatibility half of this suite compares against the LAST COMMITTED
# engine rather than against hard-coded numbers, so it keeps working as the file
# evolves: it always asserts "the defaults changed nothing since the last commit".
have_head <- FALSE
if (nzchar(Sys.which("git"))) {
  st <- suppressWarnings(system2("git", c("-C", shQuote(ROOT), "show",
                                          "HEAD:__andres_control/aaf_unified.R"),
                                 stdout = HEAD_SRC, stderr = FALSE))
  have_head <- identical(st, 0L) && file.exists(HEAD_SRC) && file.size(HEAD_SRC) > 1000
}
if (!have_head) {
  cat("\n[WARN] Could not read aaf_unified.R from git HEAD.\n",
      "       Section (A) (bit-for-bit backward compatibility) will be SKIPPED.\n",
      "       Every other section still runs.\n", sep = "")
}

old <- if (have_head) { e <- new.env(parent = globalenv()); source(HEAD_SRC, local = e, encoding = "UTF-8"); e } else NULL
new <- new.env(parent = globalenv()); source(CUR, local = new, encoding = "UTF-8")

# ---- Fixtures ---------------------------------------------------------------
# A chronic-style, monotonically increasing RR, and an HED consumption density that
# sits well above the NHED one (mean ~60 vs ~25 g/day) -- which is the whole point:
# it is precisely that gap in grams that the legacy counterfactual threw away.
x        <- seq(0.1, 150, length.out = 1500)
g_nhed   <- list(estimate = c(shape = 1.5, rate = 0.060))   # mean ~25 g/day
g_hed    <- list(estimate = c(shape = 3.0, rate = 0.050))   # mean ~60 g/day
rr_fun   <- function(x, b) exp(b[1] * x / 100)              # increasing in volume
rr_fun_h <- function(x, b) exp(b[1] * x / 100 + b[2])       # binge shifts the curve up
beta     <- c(0.45)
beta_hed <- c(0.45, 0.20)
P        <- list(p_abs = 0.30, p_form = 0.10, p_hed = 0.35, rr_fd = 1.20)

# cap_upper = FALSE throughout: we are testing the ALGEBRA, and the upper cap at 1
# would mask a sign error by clipping it.
pif_at <- function(env, ...) {
  do.call(env$pif_point, c(list(
    x = x, rr_nhed = rr_fun, beta = beta, gamma = g_nhed, gamma_hed = g_hed,
    rr_hed = rr_fun_h, beta_hed = beta_hed,
    p_abs = P$p_abs, p_form = P$p_form, p_hed = P$p_hed, rr_fd = P$rr_fd,
    cap_upper = FALSE), list(...)))
}
aaf_at <- function(p_hed) {
  new$aaf_point(x = x, rr_nhed = rr_fun, beta = beta, gamma = g_nhed, gamma_hed = g_hed,
                rr_hed = rr_fun_h, beta_hed = beta_hed,
                p_abs = P$p_abs, p_form = P$p_form, p_hed = p_hed, rr_fd = P$rr_fd,
                cap_upper = FALSE)
}
mc_at <- function(env, ...) {
  do.call(env$pif_confint, c(list(
    gamma = g_nhed, gamma_hed = g_hed, rr_fun = rr_fun, beta = beta,
    rr_fun_hed = rr_fun_h, beta_hed = beta_hed, hed_mode = "explicit",
    p_abs = P$p_abs, p_form = P$p_form, p_hed = P$p_hed, rr_fd = P$rr_fd,
    x = x, n_sim = 200L, n_pca = 500L, seed = 145, use_parallel = FALSE,
    cap_upper = FALSE), list(...)))
}

fails <- 0L
ok <- function(label, cond, extra = "") {
  if (isTRUE(cond)) {
    cat(sprintf("[PASS] %-56s %s\n", label, extra))
  } else {
    fails <<- fails + 1L
    cat(sprintf("[FAIL] %-56s %s\n", label, extra))
  }
}
eq   <- function(a, b, tol = 1e-12) isTRUE(all.equal(a, b, tolerance = tol))
errs <- function(expr) inherits(try(expr, silent = TRUE), "try-error")

# =============================================================================
cat("\n========== (A) BACKWARD COMPATIBILITY: defaults must reproduce git HEAD ==========\n")
# The knobs are worthless if turning them OFF moves a single decimal of the numbers
# already reported. NULL must mean "the engine you had yesterday".
# =============================================================================
if (have_head) {
  for (scn in c("hed", "volume", "both")) {
    for (s in c(0.9, 0.7)) {
      a <- pif_at(old, scenario = scn, shift = s)
      b <- pif_at(new, scenario = scn, shift = s)
      ok(sprintf("pif_point defaults == HEAD [%s, shift=%.1f]", scn, s), identical(a, b),
         sprintf("PIF=%.10f", b))
    }
  }
  ok("pif_point with explicit NULL knobs == HEAD",
     identical(pif_at(old, scenario = "hed", shift = 0.8),
               pif_at(new, scenario = "hed", shift = 0.8,
                      hed_exit_mix = NULL, hed_exit_shift = NULL)))
  ok("pif_point with explicit lambda=0, rho=1 == HEAD",
     eq(pif_at(old, scenario = "both", shift = 0.8, shift_hed = 0.9),
        pif_at(new, scenario = "both", shift = 0.8, shift_hed = 0.9,
               hed_exit_mix = 0, hed_exit_shift = 1)))
  # The Monte Carlo path matters most: if the knobs consumed an RNG draw even when
  # inactive, the whole simulation stream would shift and every CI would move.
  for (scn in c("hed", "volume", "both")) {
    set.seed(1); a <- mc_at(old, scenario = scn, shift = 0.9)
    set.seed(1); b <- mc_at(new, scenario = scn, shift = 0.9)
    same <- eq(a$point_estimate, b$point_estimate, 0) &&
            eq(a$lower_ci, b$lower_ci, 0) && eq(a$upper_ci, b$upper_ci, 0)
    ok(sprintf("pif_confint MC defaults == HEAD [%s]", scn), same,
       sprintf("point=%.8f CI=[%.6f, %.6f]", b$point_estimate, b$lower_ci, b$upper_ci))
  }
} else {
  cat("[SKIP] git HEAD unavailable -- backward-compatibility checks not run.\n")
}

# =============================================================================
cat("\n========== (B) SEMANTICS: lambda=1 == the old scale_phed, checked against the AAF engine ==========\n")
# The exiting mass landing on R_nhed is algebraically identical to running the SAME
# population risk with p_hed' = shift * p_hed. So the PIF must equal a quantity built
# purely out of aaf_point(), which never touches .pif_core. If the mixture algebra in
# .pif_core were wrong, this identity would break.
# =============================================================================
for (s in c(0.9, 0.8, 0.5, 0.0)) {
  got  <- pif_at(new, scenario = "hed", shift = s, hed_exit_mix = 1)
  aaf0 <- aaf_at(P$p_hed)          # observed population
  aafc <- aaf_at(s * P$p_hed)      # scale_phed counterfactual: p_hed -> shift * p_hed
  want <- 1 - (1 - aaf0) / (1 - aafc)
  ok(sprintf("lambda=1 == 1-(1-AAF0)/(1-AAFcf) [shift=%.1f]", s), eq(got, want, 1e-10),
     sprintf("got=%.10f want=%.10f", got, want))
}
ok("shift=1 -> PIF = 0 for ANY (lambda, rho) (nobody leaves binge)",
   eq(pif_at(new, scenario = "hed", shift = 1, hed_exit_mix = 0.7, hed_exit_shift = 0.5), 0))

# =============================================================================
cat("\n========== (C) DIRECTION: lambda>0 and rho<1 must RAISE the PIF ==========\n")
# d_nhed sits below d_hed and the RR curve is increasing, so making the ex-binge
# drinker actually drink LESS can only remove more risk. The legacy default is
# therefore the CONSERVATIVE bound on the benefit of a HED reduction -- which is the
# single most important thing to state when reporting these scenarios.
# =============================================================================
lam <- sapply(c(0, 0.25, 0.5, 0.75, 1), function(l)
  pif_at(new, scenario = "hed", shift = 0.7, hed_exit_mix = l))
ok("PIF strictly increasing in lambda", all(diff(lam) > 0),
   paste(sprintf("%.5f", lam), collapse = " -> "))
rho <- sapply(c(1, 0.9, 0.7, 0.5), function(r)
  pif_at(new, scenario = "hed", shift = 0.7, hed_exit_shift = r))
ok("PIF strictly increasing as rho falls", all(diff(rho) > 0),
   paste(sprintf("%.5f", rho), collapse = " -> "))
ok("the legacy default is the CONSERVATIVE bound of the family",
   eq(lam[1], min(c(lam, rho))),
   sprintf("legacy=%.5f  max=%.5f", lam[1], max(c(lam, rho))))
ok("lambda=1 makes rho irrelevant (its term carries weight zero)",
   eq(pif_at(new, scenario = "hed", shift = 0.7, hed_exit_mix = 1, hed_exit_shift = 0.3),
      pif_at(new, scenario = "hed", shift = 0.7, hed_exit_mix = 1, hed_exit_shift = 1)))

# =============================================================================
cat("\n========== (D) SCENARIO ALGEBRA: the knobs must not leak where no mass exits ==========\n")
# scenario="volume" moves nobody out of binge, so the knobs must be a strict no-op --
# otherwise a scenario grid that sets them globally would silently corrupt the
# volume-only rows.
# =============================================================================
ok("scenario='volume': knobs are a strict no-op",
   eq(pif_at(new, scenario = "volume", shift = 0.8),
      pif_at(new, scenario = "volume", shift = 0.8, hed_exit_mix = 1, hed_exit_shift = 0.4)))
ok("scenario='both' with shift_hed=1 collapses to 'volume' (superset preserved)",
   eq(pif_at(new, scenario = "both", shift = 0.8, shift_hed = 1,
             hed_exit_mix = 0.6, hed_exit_shift = 0.5),
      pif_at(new, scenario = "volume", shift = 0.8)))
ok("scenario='both' with volume shift=1 collapses to 'hed' (knobs ON)",
   eq(pif_at(new, scenario = "both", shift = 1, shift_hed = 0.7,
             hed_exit_mix = 0.6, hed_exit_shift = 0.5),
      pif_at(new, scenario = "hed", shift = 0.7,
             hed_exit_mix = 0.6, hed_exit_shift = 0.5)))
b_lam <- sapply(c(0, 0.5, 1), function(l)
  pif_at(new, scenario = "both", shift = 0.9, shift_hed = 0.7, hed_exit_mix = l))
ok("scenario='both': PIF increasing in lambda", all(diff(b_lam) > 0),
   paste(sprintf("%.5f", b_lam), collapse = " -> "))
# Under "both" the exiting mass reads its RR at x*shift*rho: the policy cut and the
# binge-exit cut COMPOUND. Setting rho=1 under 'both' must still apply the policy cut.
ok("scenario='both': rho compounds with the policy volume cut",
   pif_at(new, scenario = "both", shift = 0.9, shift_hed = 0.7, hed_exit_shift = 0.6) >
   pif_at(new, scenario = "both", shift = 0.9, shift_hed = 0.7, hed_exit_shift = 1.0))

# =============================================================================
cat("\n========== (E) GUARDRAILS: bad knobs must fail loudly, never silently ==========\n")
# A silently-ignored knob is the worst outcome here: the table would carry a label
# saying one counterfactual and the numbers of another.
# =============================================================================
ok("lambda > 1 rejected",  errs(pif_at(new, scenario = "hed", hed_exit_mix = 1.2)))
ok("lambda < 0 rejected",  errs(pif_at(new, scenario = "hed", hed_exit_mix = -0.1)))
ok("lambda NA rejected",   errs(pif_at(new, scenario = "hed", hed_exit_mix = NA_real_)))
ok("lambda vector rejected (per-subgroup spec passed unresolved)",
   errs(pif_at(new, scenario = "hed", hed_exit_mix = c(0.2, 0.8))))
ok("rho > 1 rejected (an ex-HED who drinks MORE is not a counterfactual)",
   errs(pif_at(new, scenario = "hed", hed_exit_shift = 1.3)))
ok("rho = 0 rejected",     errs(pif_at(new, scenario = "hed", hed_exit_shift = 0)))
ok("rho vector rejected",  errs(pif_at(new, scenario = "hed", hed_exit_shift = c(0.5, 0.6))))
rr_vec <- rr_fun(x, beta)
ok("rho<1 with a PRE-EVALUATED rr_nhed vector rejected (cannot re-evaluate at x*rho)",
   errs(new$pif_point(x = x, rr_nhed = rr_vec, gamma = g_nhed, gamma_hed = g_hed,
                      rr_hed = "cap", p_abs = P$p_abs, p_form = P$p_form,
                      p_hed = P$p_hed, rr_fd = P$rr_fd,
                      scenario = "hed", shift = 0.8, hed_exit_shift = 0.7)))
ok("rho=1 with a pre-evaluated rr_nhed vector still works (legacy path untouched)",
   is.finite(new$pif_point(x = x, rr_nhed = rr_vec, gamma = g_nhed, gamma_hed = g_hed,
                           rr_hed = "cap", p_abs = P$p_abs, p_form = P$p_form,
                           p_hed = P$p_hed, rr_fd = P$rr_fd,
                           scenario = "hed", shift = 0.8)))

# =============================================================================
cat("\n========== (F) PER-SUBGROUP SPECS: resolve_hed_exit() ==========\n")
# The knobs are CELL-level scalars, so the runner can hand a DIFFERENT value to each
# (year, sex, age band) -- e.g. women 15-29 quitting binge more completely than men
# 30-44, or a value monotone in age/year to feed the alcohol-transition model.
# resolve_hed_exit() accepts the same spec shapes as the neff / design_factor knobs.
# =============================================================================
lam_fun <- function(year, group, sex) if (identical(sex, "female") && group == 1L) 0.8 else 0.4
ok("spec: function(year, group, sex) -- female / band 1 (15-29)",
   eq(new$resolve_hed_exit(lam_fun, 2022, 1L, "female"), 0.8))
ok("spec: function(year, group, sex) -- male / band 3 (30-44)",
   eq(new$resolve_hed_exit(lam_fun, 2022, 3L, "male"), 0.4))
lam_mono <- function(year, group, sex) min(1, 0.2 * group)
ok("spec: monotone in age band (transition-model friendly)",
   eq(sapply(1:4, function(g) new$resolve_hed_exit(lam_mono, 2022, g, "male")),
      c(0.2, 0.4, 0.6, 0.8)))
lam_yr <- function(year, group, sex) min(1, 0.1 * (year - 2019))
ok("spec: monotone in year (exit deepens as the policy matures)",
   eq(sapply(c(2020, 2022, 2024), function(y) new$resolve_hed_exit(lam_yr, y, 1L, "male")),
      c(0.1, 0.3, 0.5)))
ok("spec: nested list keyed year -> edad_tramo_<g>",
   eq(new$resolve_hed_exit(list("2022" = list(edad_tramo_1 = 0.9, edad_tramo_2 = 0.5)),
                           2022, 1L, "female"), 0.9))
ok("spec: list keyed by year with one value per year",
   eq(new$resolve_hed_exit(list("2022" = 0.4, "2023" = 0.6), 2023, 3L, "male"), 0.6))
ok("spec: list keyed by age band, constant across years",
   eq(new$resolve_hed_exit(list(edad_tramo_1 = 0.7, edad_tramo_2 = 0.2), 2024, 2L, "male"), 0.2))
ok("spec: plain numeric vector indexed by age band",
   eq(new$resolve_hed_exit(c(0.2, 0.4, 0.6, 0.8), 2022, 3L, "male"), 0.6))
ok("spec: bare scalar broadcasts to every cell",
   eq(new$resolve_hed_exit(0.33, 2022, 2L, "male"), 0.33))
ok("spec: NULL stays NULL (engine falls back to the legacy counterfactual)",
   is.null(new$resolve_hed_exit(NULL, 2022, 2L, "male")))
ok("spec: a spec that does not resolve to a finite scalar is rejected",
   errs(new$resolve_hed_exit(function(year, group, sex) "not a number", 2022, 1L, "male")))

# ---- THE SILENT-LEAK REGRESSION -----------------------------------------------
# A year-keyed list is ALSO a valid positional lookup whenever length(spec) >= group.
# The shared .aaf_resolve_cell() resolves that ambiguity by falling through to
# spec[[group]] when the year key is missing -- handing this cell ANOTHER cell's
# lambda, finite and plausible, which no downstream is.finite() check can catch and
# which the pif_confint() audit echo would then record as if it had been requested.
# resolve_hed_exit() must NEVER do that: an uncovered cell is an ERROR.
partial <- list("2022" = list(edad_tramo_1 = 0.20, edad_tramo_2 = 0.80),
                "2023" = list(edad_tramo_1 = 0.30, edad_tramo_2 = 0.90))
ok("covered cell still resolves correctly",
   eq(new$resolve_hed_exit(partial, 2022, 2L, "male"), 0.80))
ok("REGRESSION: uncovered YEAR errors, does not leak another year's value",
   errs(new$resolve_hed_exit(partial, 2024, 2L, "male")))
ok("REGRESSION: uncovered year + band 1 errors (leaked 0.20 before the fix)",
   errs(new$resolve_hed_exit(partial, 2024, 1L, "male")))
ok("REGRESSION: uncovered BAND inside a covered year errors",
   errs(new$resolve_hed_exit(partial, 2022, 3L, "male")))
ok("REGRESSION: the shared .aaf_resolve_cell DOES leak (documents why we bypass it)",
   eq(suppressWarnings(as.numeric(new$.aaf_resolve_cell(partial, 2024, 2L, "male"))), 0.30),
   "leaks 2023's edad_tramo_1 -- resolve_hed_exit must not delegate to it")
ok("spec: unnamed list rejected", errs(new$resolve_hed_exit(list(0.2, 0.8), 2022, 1L, "male")))
ok("spec: list with unrecognised names rejected",
   errs(new$resolve_hed_exit(list(a = 0.2, b = 0.8), 2022, 1L, "male")))

# The knob must actually bite: two different subgroups must get two different PIFs.
p_f1 <- pif_at(new, scenario = "hed", shift = 0.7,
               hed_exit_mix = new$resolve_hed_exit(lam_fun, 2022, 1L, "female"))
p_m3 <- pif_at(new, scenario = "hed", shift = 0.7,
               hed_exit_mix = new$resolve_hed_exit(lam_fun, 2022, 3L, "male"))
ok("a per-subgroup lambda produces genuinely different PIFs", p_f1 > p_m3,
   sprintf("female 15-29 = %.5f  >  male 30-44 = %.5f", p_f1, p_m3))

# =============================================================================
cat("\n========== (G) MONTE CARLO honours the knobs (point AND interval move) ==========\n")
# =============================================================================
set.seed(1); m0 <- mc_at(new, scenario = "hed", shift = 0.7)
set.seed(1); m1 <- mc_at(new, scenario = "hed", shift = 0.7, hed_exit_mix = 1)
set.seed(1); m2 <- mc_at(new, scenario = "hed", shift = 0.7, hed_exit_shift = 0.6)
ok("pif_confint honours lambda (point and lower CI both shift up)",
   m1$point_estimate > m0$point_estimate && m1$lower_ci > m0$lower_ci,
   sprintf("point %.5f -> %.5f", m0$point_estimate, m1$point_estimate))
ok("pif_confint honours rho (point shifts up)",
   m2$point_estimate > m0$point_estimate,
   sprintf("point %.5f -> %.5f", m0$point_estimate, m2$point_estimate))
ok("pif_confint CIs stay ordered under the knobs",
   m1$lower_ci <= m1$point_estimate && m1$point_estimate <= m1$upper_ci)
ok("pif_confint ECHOES the knobs it actually used (auditability)",
   eq(m0$hed_exit_mix, 0) && eq(m0$hed_exit_shift, 1) &&
   eq(m1$hed_exit_mix, 1) && eq(m1$hed_exit_shift, 1) &&
   eq(m2$hed_exit_mix, 0) && eq(m2$hed_exit_shift, 0.6))
# The knobs are ASSUMPTIONS, not estimated parameters: they must not inject extra
# randomness. Same seed + same knobs => identical simulation vector, every time.
set.seed(1); r1 <- mc_at(new, scenario = "hed", shift = 0.7, hed_exit_mix = 0.5, return_sims = TRUE)
set.seed(1); r2 <- mc_at(new, scenario = "hed", shift = 0.7, hed_exit_mix = 0.5, return_sims = TRUE)
ok("knobs inject NO extra randomness (identical sim vector, bit for bit)",
   identical(r1$simulated_pifs, r2$simulated_pifs))

# =============================================================================
cat("\n========== (H) J-CURVE (IHD/IS, hed_mode='cap'): the knobs are NOT monotone ==========\n")
# THE MOST IMPORTANT SECTION IN THIS FILE.
#
# Everything above uses a monotonically increasing RR, where lambda>0 / rho<1 always
# RAISE the PIF and the legacy default is a genuine conservative bound. That is TRUE
# for cancers, liver, injuries -- and FALSE for the cardioprotective J-curve family.
#
# The project's own male IHD curve (GENERAL_ihd_RR_2018_03_16.R) is PROTECTIVE across
# its entire sub-60 g/day range, nadir RR ~ 0.78 at ~31 g/day, while rr_hed = "cap"
# pins RR_HED at 1. Pushing the exiting mass DOWN in volume therefore walks it around
# the bottom of the J: the PIF can FALL, and it is non-monotone in rho.
#
# This section exists so that nobody reads the (C) results, concludes "the knobs are a
# one-sided sensitivity range", and reports IHD/IS that way. If someone ever "fixes"
# the warning in the aaf_unified.R header back into a monotonicity claim, this fails.
# =============================================================================
IHD_RR <- file.path(ROOT, "__andres_control", "GENERAL_ihd_RR_2018_03_16.R")
if (!file.exists(IHD_RR)) {
  cat("[SKIP] GENERAL_ihd_RR_2018_03_16.R not found -- J-curve section not run.\n")
} else {
  jenv <- new.env(parent = globalenv()); source(IHD_RR, local = jenv, encoding = "UTF-8")
  rec <- jenv$IHDmaleMORT_1
  if (is.null(rec) || !is.function(rec$RRCurrent)) {
    cat("[SKIP] IHDmaleMORT_1$RRCurrent not available -- J-curve section not run.\n")
  } else {
    rr_j  <- rec$RRCurrent(x, rec$betaCurrent)
    below <- x < 60
    cat(sprintf("   IHD male RR_NHED: min = %.4f at x = %.1f g/day;  %.0f%% of the sub-60 g range is PROTECTIVE (RR<1)\n",
                min(rr_j[below]), x[below][which.min(rr_j[below])],
                100 * mean(rr_j[below] < 1)))
    ok("the real IHD curve IS protective below 60 g/day (premise of this section)",
       all(rr_j[below] < 1))

    # Same drinking population as (C), but the CV inputs: rr_hed = "cap" (RR_HED = 1
    # wherever RR_NHED dips below 1), which is exactly what expand_pif2 drives for CV.
    jpif <- function(...) {
      do.call(new$pif_point, c(list(
        x = x, rr_nhed = rec$RRCurrent, beta = rec$betaCurrent, rr_hed = "cap",
        gamma = list(estimate = c(shape = 1.3, rate = 1 / 14)),          # NHED mean ~18
        gamma_hed = list(estimate = c(shape = 2.0, rate = 2 / 30)),      # HED  mean ~30
        p_abs = 0.20, p_form = 0.10, p_hed = 0.35, rr_fd = 1.25,
        scenario = "hed", shift = 0.9, cap_upper = FALSE), list(...)))
    }
    j_legacy <- jpif()
    j_lam1   <- jpif(hed_exit_mix = 1)
    j_rho25  <- jpif(hed_exit_shift = 0.25)
    j_rho10  <- jpif(hed_exit_shift = 0.10)
    cat(sprintf("   PIF: legacy=%.6f  lambda=1 -> %.6f   rho=0.25 -> %.6f   rho=0.10 -> %.6f\n",
                j_legacy, j_lam1, j_rho25, j_rho10))
    ok("J-curve: lambda=1 LOWERS the PIF (the opposite of the monotone families)",
       j_lam1 < j_legacy, sprintf("%.6f < %.6f", j_lam1, j_legacy))
    ok("J-curve: rho<1 LOWERS the PIF", j_rho25 < j_legacy && j_rho10 < j_legacy)
    ok("J-curve: the legacy default is an INTERIOR point, NOT a conservative bound",
       j_legacy > min(c(j_lam1, j_rho25, j_rho10)))

    # Non-monotonicity in rho: with a heavier HED density the sweep rises, then falls.
    jpif60 <- function(r) {
      new$pif_point(x = x, rr_nhed = rec$RRCurrent, beta = rec$betaCurrent, rr_hed = "cap",
                    gamma = list(estimate = c(shape = 1.3, rate = 1 / 14)),
                    gamma_hed = list(estimate = c(shape = 2.0, rate = 2 / 60)),  # HED mean ~60
                    p_abs = 0.20, p_form = 0.10, p_hed = 0.35, rr_fd = 1.25,
                    scenario = "hed", shift = 0.9, hed_exit_shift = r, cap_upper = FALSE)
    }
    sweep <- sapply(c(1.00, 0.75, 0.50, 0.25, 0.10), jpif60)
    cat(sprintf("   rho sweep (HED mean 60 g/day): %s\n",
                paste(sprintf("%.6f", sweep), collapse = " -> ")))
    ok("J-curve: the rho sweep is NON-MONOTONE (rises, then falls)",
       any(diff(sweep) > 0) && any(diff(sweep) < 0),
       "a (lambda, rho) sweep on IHD/IS is NOT a one-sided sensitivity range")
    ok("J-curve: sanity -- a monotone RR under the SAME cap mode still behaves",
       new$pif_point(x = x, rr_nhed = function(x, b) exp(b[1] * x / 100), beta = c(1.5),
                     rr_hed = "cap",
                     gamma = list(estimate = c(shape = 1.3, rate = 1 / 14)),
                     gamma_hed = list(estimate = c(shape = 2.0, rate = 2 / 30)),
                     p_abs = 0.20, p_form = 0.10, p_hed = 0.35, rr_fd = 1.25,
                     scenario = "hed", shift = 0.9, hed_exit_mix = 1, cap_upper = FALSE) >
       new$pif_point(x = x, rr_nhed = function(x, b) exp(b[1] * x / 100), beta = c(1.5),
                     rr_hed = "cap",
                     gamma = list(estimate = c(shape = 1.3, rate = 1 / 14)),
                     gamma_hed = list(estimate = c(shape = 2.0, rate = 2 / 30)),
                     p_abs = 0.20, p_form = 0.10, p_hed = 0.35, rr_fd = 1.25,
                     scenario = "hed", shift = 0.9, cap_upper = FALSE),
       "isolates the J-curve (not the cap) as the cause of the sign flip")
  }
}

# =============================================================================
cat(sprintf("\n=============================================================\n%s  (%d failure%s)   elapsed: %.2f min\n=============================================================\n",
            if (fails == 0L) "ALL HED-EXIT KNOB TESTS PASSED." else "*** HED-EXIT KNOB TESTS FAILED ***",
            fails, if (fails == 1L) "" else "s",
            as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
if (fails > 0L) quit(status = 1L)
