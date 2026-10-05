options(survey.lonely.psu = "adjust", width = 220, warn = 1)
suppressPackageStartupMessages({
  library(haven)
  library(survey)
  library(readxl)
})

base <- "C:/Users/homes/Claude/Projects/gambling/analisis_suicidio/enpg"
out <- file.path(base, "_codex_temp_audit_enpg")

pick <- function(x, nms) {
  j <- match(tolower(nms), tolower(names(x)))
  if (anyNA(j)) stop("Missing variables: ", paste(nms[is.na(j)], collapse = ", "))
  x[j]
}
yes <- function(z) !is.na(z) & as.numeric(z) == 1
in12m <- function(z) !is.na(z) & as.numeric(z) %in% 1:2
any_yes <- function(x, nms) rowSums(as.data.frame(lapply(pick(x, nms), yes))) > 0
dep10 <- function(x, nms) {
  z <- as.data.frame(lapply(pick(x, nms), yes))
  stopifnot(ncol(z) == 10)
  score <- (z[[1]] | z[[2]]) + z[[3]] + (z[[4]] | z[[5]]) +
    (z[[6]] | z[[7]]) + (z[[8]] | z[[9]]) + z[[10]]
  score >= 3
}
seqnm <- function(prefix, a, b, sep = "") paste0(prefix, sep, a:b)
composite <- function(...) interaction(..., drop = TRUE, lex.order = TRUE, sep = ":")

specs <- list(
  `2008` = list(file = "enpg2008.RDS", weight = "exp", region_pos = 4, age_pos = 14,
    psu = c("region", "comuna", "seccion"),
    oh = list(ever = "q12", last = "q15", abuse = seqnm("q", 28, 31)),
    mar = list(ever = "q33", last = "q36", dep = seqnm("q", 37, 46), abuse = seqnm("q", 47, 50)),
    pb = list(ever = "q56", last = "q59", dep = seqnm("q", 60, 69), abuse = seqnm("q", 70, 73)),
    coc = list(ever = "q79", last = "q82", dep = seqnm("q", 83, 92), abuse = seqnm("q", 93, 96)),
    treatment = list(mode = "two", last = "q170", type = "q171", need_oh = "q174", need_drug = "q175")),
  `2010` = list(file = "enpg2010.RDS", weight = "factor_ajustado_com", region_pos = 2, age_pos = 7,
    psu = c("pregion", "pcodcom", "manzana"),
    oh = list(ever = "p013", last = "p016", abuse = seqnm("p", 29, 32, sep = "0")),
    mar = list(ever = "p033", last = "p036", dep = seqnm("p", 41, 50, sep = "0"), abuse = seqnm("p", 51, 54, sep = "0")),
    pb = list(ever = "p055", last = "p058", dep = seqnm("p", 63, 72, sep = "0"), abuse = seqnm("p", 73, 76, sep = "0")),
    coc = list(ever = "p077", last = "p080", dep = seqnm("p", 85, 94, sep = "0"), abuse = seqnm("p", 95, 98, sep = "0")),
    treatment = list(mode = "two", last = "p212", type = "p213", need_oh = "p216", need_drug = "p219", attempt_oh = "p217", attempt_drug = "p220")),
  `2012` = list(file = "Base de datos ENPG 2012 (PG).dta", weight = "PONDERADOR", region_pos = 446, age_pos = 3,
    psu = c("region", "codigo_comuna", "manzana"),
    oh = list(ever = "p10", last = "p13", abuse = seqnm("p", 31, 34)),
    mar = list(ever = "p35", last = "p38", dep = seqnm("p", 44, 53), abuse = seqnm("p", 54, 57)),
    pb = list(ever = "p58", last = "p61", dep = seqnm("p", 66, 75), abuse = seqnm("p", 76, 79)),
    coc = list(ever = "p80", last = "p83", dep = seqnm("p", 88, 97), abuse = seqnm("p", 98, 101)),
    treatment = list(mode = "direct", direct = "p145", attempt_combined = "p146")),
  `2014` = list(file = "Base de datos ENPG 2014 (PG).DTA.dta", weight = "F2_MAY_AJUS_com", region_pos = 7, age_pos = 3,
    psu = c("Region", "Comuna", "Segmento_n"),
    oh = list(ever = "oh1", last = "oh4", abuse = seqnm("oh", 22, 25)),
    mar = list(ever = "mar1", last = "mar4", dep = seqnm("mar", 10, 19), abuse = seqnm("mar", 20, 23)),
    pb = list(ever = "pb1", last = "pb4", dep = seqnm("pb", 9, 18), abuse = seqnm("pb", 19, 22)),
    coc = list(ever = "coc1", last = "coc4", dep = seqnm("coc", 9, 18), abuse = seqnm("coc", 19, 22)),
    treatment = list(mode = "two", last = "trata2", type = "trata3", need_combined = "trata5", attempt_combined = "trata6")),
  `2016` = list(file = "base ENPG 2016 publico general.dta", weight = "Fexp", region_pos = 469, age_pos = 468,
    psu_pos = c(469, 470, 471, 472, 473),
    oh = list(ever = "oh_1", last = "oh_4", abuse = seqnm("oh", 26, 29, sep = "_")),
    mar = list(ever = "mar_1", last = "mar_4", dep = seqnm("mar", 12, 21, sep = "_"), abuse = seqnm("mar", 22, 25, sep = "_")),
    pb = list(ever = "pb_1", last = "pb_4", dep = seqnm("pb", 9, 18, sep = "_"), abuse = seqnm("pb", 19, 22, sep = "_")),
    coc = list(ever = "coc_1", last = "coc_4", dep = seqnm("coc", 9, 18, sep = "_"), abuse = seqnm("coc", 19, 22, sep = "_")),
    treatment = list(mode = "two", last = "trata_2", type = "trata_3", need_combined = "trata_4", attempt_combined = "trata_5")),
  `2018` = list(file = "Base de datos ENPG 2018 (PG).DTA", weight = "Fexp", region_pos = 496, age_pos = 3,
    psu = c("Region", "comuna", "Seccion"),
    oh = list(ever = "OH_1", last = "OH_4", abuse = seqnm("OH", 24, 27, sep = "_")),
    mar = list(ever = "MAR_1", last = "MAR_4", dep = seqnm("MAR", 12, 21, sep = "_"), abuse = seqnm("MAR", 22, 25, sep = "_")),
    pb = list(ever = "PB_1", last = "PB_4", dep = seqnm("PB", 9, 18, sep = "_"), abuse = seqnm("PB", 19, 22, sep = "_")),
    coc = list(ever = "COC_1", last = "COC_4", dep = seqnm("COC", 9, 18, sep = "_"), abuse = seqnm("COC", 19, 22, sep = "_")),
    treatment = list(mode = "two", last = "TRATA_2", type = "TRATA_3", need_combined = "TRATA_4", attempt_combined = "TRATA_5")),
  `2020` = list(file = "enpg2020.RDS", weight = "FACT_PERS_COMUNA", region_pos = 2, age_pos = 5,
    psu = c("REGION", "Nom_comuna", "seccion"),
    oh = list(ever = "OH_1", last = "OH_4", abuse = seqnm("OH", 20, 23, sep = "_")),
    mar = list(ever = "MAR_1", last = "MAR_4", dep = seqnm("MAR", 8, 17, sep = "_"), abuse = seqnm("MAR", 18, 21, sep = "_")),
    pb = list(ever = "PB_1", last = "PB_4", dep = seqnm("PB", 6, 15, sep = "_"), abuse = seqnm("PB", 16, 19, sep = "_")),
    coc = list(ever = "COC_1", last = "COC_4", dep = seqnm("COC", 6, 15, sep = "_"), abuse = seqnm("COC", 16, 19, sep = "_")),
    treatment = list(mode = "two", last = "TRATA_2", type = "TRATA_3", need_combined = "TRATA_4", attempt_combined = "TRATA_5")),
  `2022` = list(file = "enpg2022.RDS", weight = "FACTOR_EXPANSION", region_pos = 2, age_pos = 7,
    psu = c("REGION", "UPM"),
    oh = list(ever = "OH_1", last = "OH_4", abuse = seqnm("OH", 20, 23, sep = "_")),
    mar = list(ever = "MAR_1", last = "MAR_4", dep = seqnm("MAR", 8, 17, sep = "_"), abuse = seqnm("MAR", 18, 21, sep = "_")),
    pb = list(ever = "PB_1", last = "PB_4", dep = seqnm("PB", 6, 15, sep = "_"), abuse = seqnm("PB", 16, 19, sep = "_")),
    coc = list(ever = "COC_1", last = "COC_4", dep = seqnm("COC", 6, 15, sep = "_"), abuse = seqnm("COC", 16, 19, sep = "_")),
    treatment = list(mode = "two", last = "TRATA_2", type = "TRATA_3", need_combined = "TRATA_4", attempt_combined = "TRATA_5")),
  `2024` = list(file = "Base Publica ENPG 2024 (Stata 16).dta", weight = "FACTOR_EXPANSION", region_pos = 5, age_pos = 3,
    psu = c("REGION", "UPM"), strata = "ESTRATO",
    oh = list(ever = "OH_1", last = "OH_4", abuse = seqnm("OH", 20, 23, sep = "_")),
    mar = list(ever = "MAR_1", last = "MAR_4", dep = seqnm("MAR", 8, 17, sep = "_"), abuse = seqnm("MAR", 18, 21, sep = "_")),
    pb = list(ever = "PB_1", last = "PB_4", dep = seqnm("PB", 6, 15, sep = "_"), abuse = seqnm("PB", 16, 19, sep = "_")),
    coc = list(ever = "COC_1", last = "COC_4", dep = seqnm("COC", 6, 15, sep = "_"), abuse = seqnm("COC", 16, 19, sep = "_")),
    treatment = list(mode = "two", last = "TRATA_2", type = "TRATA_3", need_combined = "TRATA_4", attempt_combined = "TRATA_5"))
)

build <- function(year, s) {
  path <- file.path(base, s$file)
  x <- if (grepl("[.]RDS$", path, ignore.case = TRUE)) readRDS(path) else read_dta(path)
  if (year == "2016") {
    fw <- read_dta(file.path(base, "factoresdeexpansion.dta"))
    stopifnot(isTRUE(all.equal(as.vector(x$idencuesta), as.vector(fw$idencuesta), check.attributes = FALSE)))
    x$Fexp <- fw$Fexp
  }
  age <- as.numeric(x[[s$age_pos]])
  x <- x[!is.na(age) & age >= 12 & age <= 64, ]
  reg <- as.numeric(x[[s$region_pos]])
  w <- as.numeric(pick(x, s$weight)[[1]])
  if (!is.null(s$psu_pos)) psu <- do.call(composite, unclass(x[s$psu_pos])) else psu <- do.call(composite, unclass(pick(x, s$psu)))
  strata <- if (!is.null(s$strata)) as.factor(pick(x, s$strata)[[1]]) else as.factor(reg)

  py_oh <- yes(pick(x, s$oh$ever)[[1]]) & in12m(pick(x, s$oh$last)[[1]])
  py_mar <- yes(pick(x, s$mar$ever)[[1]]) & in12m(pick(x, s$mar$last)[[1]])
  py_pb <- yes(pick(x, s$pb$ever)[[1]]) & in12m(pick(x, s$pb$last)[[1]])
  py_coc <- yes(pick(x, s$coc$ever)[[1]]) & in12m(pick(x, s$coc$last)[[1]])
  prob_oh <- py_oh & any_yes(x, s$oh$abuse)
  prob_mar <- py_mar & (dep10(x, s$mar$dep) | any_yes(x, s$mar$abuse))
  prob_pb <- py_pb & (dep10(x, s$pb$dep) | any_yes(x, s$pb$abuse))
  prob_coc <- py_coc & (dep10(x, s$coc$dep) | any_yes(x, s$coc$abuse))
  py_drug <- py_mar | py_pb | py_coc
  prob_drug <- prob_mar | prob_pb | prob_coc
  py_any <- py_oh | py_drug
  prob_any <- prob_oh | prob_drug

  t <- s$treatment
  if (t$mode == "direct") {
    tr <- as.numeric(pick(x, t$direct)[[1]])
    treat_oh <- tr %in% c(1, 3)
    treat_drug <- tr %in% c(2, 3)
    treat_any <- tr %in% 1:3
  } else {
    tl <- as.numeric(pick(x, t$last)[[1]])
    tt <- as.numeric(pick(x, t$type)[[1]])
    treat_oh <- tl == 1 & tt %in% c(1, 3)
    treat_drug <- tl == 1 & tt %in% c(2, 3)
    treat_any <- tl == 1
    treat_oh[is.na(treat_oh)] <- FALSE
    treat_drug[is.na(treat_drug)] <- FALSE
    treat_any[is.na(treat_any)] <- FALSE
  }
  data.frame(year = as.integer(year), reg = reg, w = w, psu = psu, strata = strata,
    py_oh = py_oh, py_drug = py_drug, py_any = py_any,
    prob_oh = prob_oh, prob_drug = prob_drug, prob_any = prob_any,
    treat_oh = treat_oh, treat_drug = treat_drug, treat_any = treat_any,
    # Workbook uses receipt of any alcohol/drug treatment for each clinical subgroup;
    # retain substance-matched treatment above for sensitivity analyses.
    tprob_oh = prob_oh & treat_any, tprob_drug = prob_drug & treat_any,
    tprob_any = prob_any & treat_any)
}

weighted_sum <- function(z, w) sum(w[z & !is.na(z)], na.rm = TRUE)
national <- list()
regional <- list()
alldata <- list()

for (yr in names(specs)) {
  message("Build ", yr)
  d <- build(yr, specs[[yr]])
  alldata[[yr]] <- d
  rows <- lapply(c("oh", "drug", "any"), function(k) {
    py <- d[[paste0("py_", k)]]
    pr <- d[[paste0("prob_", k)]]
    tp <- d[[paste0("tprob_", k)]]
    data.frame(year = as.integer(yr), outcome = k,
      n = nrow(d), n_py = sum(py), n_problem = sum(pr), n_treated_problem = sum(tp),
      W_total = sum(d$w, na.rm = TRUE), W_py = weighted_sum(py, d$w),
      W_problem = weighted_sum(pr, d$w), W_treated_problem = weighted_sum(tp, d$w),
      prev_py = weighted_sum(py, d$w) / sum(d$w, na.rm = TRUE),
      problem_among_py = weighted_sum(pr, d$w) / weighted_sum(py, d$w),
      treatment_among_problem = weighted_sum(tp, d$w) / weighted_sum(pr, d$w),
      gap = 1 - weighted_sum(tp, d$w) / weighted_sum(pr, d$w))
  })
  national[[yr]] <- do.call(rbind, rows)

  des <- svydesign(ids = ~psu, strata = ~strata, weights = ~w, data = d, nest = TRUE)
  regs <- sort(unique(d$reg[!is.na(d$reg)]))
  rr <- list()
  idx <- 0L
  for (r in c(NA_real_, regs)) for (k in c("oh", "drug", "any")) {
    idx <- idx + 1L
    selreg <- if (is.na(r)) rep(TRUE, nrow(d)) else d$reg == r
    pr <- d[[paste0("prob_", k)]] & selreg
    tp <- d[[paste0("tprob_", k)]] & selreg
    ww <- d$w[pr]
    npr <- sum(pr)
    ntr <- sum(tp)
    kish <- if (npr) sum(ww)^2 / sum(ww^2) else NA_real_
    psu_pr <- length(unique(d$psu[pr]))
    psu_reg <- length(unique(d$psu[selreg]))
    p <- if (npr) weighted_sum(tp, d$w) / weighted_sum(pr, d$w) else NA_real_
    se <- lo <- hi <- NA_real_
    if (npr > 1 && psu_pr > 1) {
      dd <- des[pr, ]
      ftr <- as.formula(paste0("~tprob_", k))
      est <- try(svyciprop(ftr, dd, method = "beta", na.rm = TRUE), silent = TRUE)
      if (inherits(est, "try-error")) {
        est <- try(svymean(ftr, dd, na.rm = TRUE), silent = TRUE)
      }
      if (!inherits(est, "try-error")) {
        se <- as.numeric(SE(est))[1]
        ci <- try(confint(est), silent = TRUE)
        if (!inherits(ci, "try-error")) { lo <- max(0, as.numeric(ci)[1]); hi <- min(1, as.numeric(ci)[2]) }
      }
    }
    flags <- c(if (npr < 30) "n_problem<30", if (ntr < 5) "n_treated<5",
               if (!is.na(kish) && kish < 30) "kish_neff<30", if (psu_pr < 10) "PSU_problem<10",
               if (ntr == 0) "zero_numerator")
    rr[[idx]] <- data.frame(year = as.integer(yr), region = if (is.na(r)) "ALL" else as.character(r), outcome = k,
      n_region = sum(selreg), n_problem = npr, n_treated = ntr, n_psu_region = psu_reg, n_psu_problem = psu_pr,
      kish_neff_problem = kish, W_problem = weighted_sum(pr, d$w), W_treated = weighted_sum(tp, d$w),
      treat = p, treat_se = se, treat_lcl = lo, treat_ucl = hi,
      gap = 1 - p, gap_lcl = 1 - hi, gap_ucl = 1 - lo,
      ci_width = hi - lo, flags = paste(flags, collapse = ";"), stringsAsFactors = FALSE)
  }
  regional[[yr]] <- do.call(rbind, rr)
}

national <- do.call(rbind, national)
regional <- do.call(rbind, regional)
write.csv(national, file.path(out, "national_reconstruction.csv"), row.names = FALSE)
write.csv(regional, file.path(out, "regional_gap_feasibility.csv"), row.names = FALSE)

# Workbook comparison (rows 4:6 past-year, 14:16 problem, 24:26 treatment).
wb <- "C:/Users/homes/OneDrive/Escritorio/consumo problematico enpg 2020.xlsx"
work <- list()
for (si in 1:6) {
  x <- suppressMessages(read_excel(wb, sheet = si, col_names = FALSE))
  rr <- c(4:6, 14:16, 24:26)
  work[[si]] <- data.frame(year = 2008 + 2 * si,
    metric = rep(c("prev_py", "problem_among_py", "treatment_among_problem"), each = 3),
    outcome = rep(c("drug", "oh", "any"), 3),
    workbook_pct = as.numeric(x[[6]][rr]) / 100,
    workbook_N = as.numeric(x[[13]][rr]))
}
work <- do.call(rbind, work)
calc <- rbind(
  data.frame(year = national$year, metric = "prev_py", outcome = national$outcome, calc_pct = national$prev_py, calc_N = national$W_py),
  data.frame(year = national$year, metric = "problem_among_py", outcome = national$outcome, calc_pct = national$problem_among_py, calc_N = national$W_problem),
  data.frame(year = national$year, metric = "treatment_among_problem", outcome = national$outcome, calc_pct = national$treatment_among_problem, calc_N = national$W_treated_problem)
)
validation <- merge(work, calc, by = c("year", "metric", "outcome"), all.x = TRUE)
validation$pct_diff_pp <- 100 * (validation$calc_pct - validation$workbook_pct)
validation$N_diff <- validation$calc_N - validation$workbook_N
write.csv(validation, file.path(out, "workbook_validation.csv"), row.names = FALSE)

cat("\nNATIONAL\n")
print(national[, c("year", "outcome", "n_problem", "n_treated_problem", "W_problem", "problem_among_py", "treatment_among_problem", "gap")], row.names = FALSE)
cat("\nWORKBOOK MAX ABS DIFFERENCE\n")
print(aggregate(cbind(pct_diff_pp, N_diff) ~ metric, validation, function(z) max(abs(z), na.rm = TRUE)), row.names = FALSE)
cat("\nREGIONAL GLOBAL FEASIBILITY SUMMARY\n")
g <- subset(regional, outcome == "any" & region != "ALL")
g$cells <- 1
g$n_problem_ge30 <- g$n_problem >= 30
g$treated_ge5 <- g$n_treated >= 5
g$kish_ge30 <- g$kish_neff_problem >= 30
g$psu_ge10 <- g$n_psu_problem >= 10
print(aggregate(cbind(cells, n_problem_ge30, treated_ge5, kish_ge30, psu_ge10) ~ year,
                g, sum, na.rm = TRUE), row.names = FALSE)
