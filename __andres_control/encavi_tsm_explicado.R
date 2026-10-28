.t0 <- Sys.time()
# Aggregates for encavi_tsm_explicado.html (run from the repo root). Descriptive only: no calibration, no engine reruns.
source(file.path("_tools", "acc_data.R"))
source(file.path("__andres_control", "tsm_markov_data.R"))   # definitions only (ts_education, ts_age)
out <- Sys.getenv("PAGE_OUT", file.path("__andres_control", "encavi_tsm_outputs")); dir.create(out, showWarnings = FALSE)
options(survey.lonely.psu = "certainty")   # as in the ENCAVI manual
age4 <- function(a) as.character(cut(a, c(18, 30, 45, 60, 66), right = FALSE, labels = c("18-29", "30-44", "45-59", "60-65")))

e <- new.env(); load(acc_data("_encavi2324/20260722_ENCAVI_data.RData.tar.xz.enc"), envir = e); d <- e$encavi2
print(attr(d$sexo, "labels"))
v <- function(x) as.numeric(unclass(x))
p20 <- v(d$p5_20); p21 <- v(d$p5_21); p22 <- v(d$p5_22)
d$g <- ifelse(p20 %in% 2, "A_lifetime", ifelse(p20 %in% 1 & p21 %in% 3, "B_over1y",
  ifelse(p20 %in% 1 & p21 %in% 1:2 & p22 %in% 1, "C_pastyear_never", ifelse(p20 %in% 1 & p21 %in% 1:2 & p22 %in% 2:5, "D_drinker", "U_unknown"))))
d$sex <- ifelse(v(d$sexo) == 1, "Men", "Women"); d$age4 <- age4(d$edad); d$educ4 <- v(d$educ_imp)
d$dom <- v(d$area) == 1 & d$edad >= 18 & d$edad <= 65
d$e3eq <- ifelse(d$g %in% c("A_lifetime", "B_over1y", "C_pastyear_never"), 1, ifelse(d$g == "D_drinker", p22, NA))
des <- survey::svydesign(ids = ~varunit, strata = ~varstrat, weights = ~w_personas_cal, nest = TRUE, data = d)

flow <- function(dd, label) {
  m <- survey::svymean(~g, dd); ci <- stats::confint(m)
  data.frame(domain = label, group = sub("^g", "", names(m)), n = as.integer(table(dd$variables$g)[sub("^g", "", names(m))]),
             pct = 100 * unname(coef(m)), lo = 100 * ci[, 1], hi = 100 * ci[, 2])
}
fl <- rbind(flow(des, "15+ all areas"), flow(subset(des, dom), "18-65 urban"))
print(fl, digits = 3); utils::write.csv(fl, file.path(out, "encavi_flow.csv"), row.names = FALSE)

share <- function(dd, groups, by = NULL) {
  s <- subset(dd, g %in% groups); f <- ~I(g == "A_lifetime")
  if (is.null(by)) {
    p <- survey::svyciprop(f, s, method = "logit"); m <- survey::svymean(f, s, deff = TRUE)
    return(data.frame(cell = "All", n = nrow(s$variables), pct = 100 * as.numeric(p), lo = 100 * attr(p, "ci")[1],
      hi = 100 * attr(p, "ci")[2], deff = unname(survey::deff(m))[2]))
  }
  r <- survey::svyby(f, by, s, survey::svyciprop, vartype = "ci", method = "logit")
  dm <- survey::svyby(f, by, s, survey::svymean, deff = TRUE)
  key <- do.call(paste, c(r[all.vars(by)], sep = " "))
  nn <- table(do.call(paste, c(s$variables[all.vars(by)], sep = " ")))
  data.frame(cell = key, n = as.integer(nn[key]), pct = 100 * r[[length(all.vars(by)) + 1]], lo = 100 * r$ci_l, hi = 100 * r$ci_u,
             deff = dm[[grep("^DEff.*TRUE", names(dm))[1]]])
}
dd <- subset(des, dom)
wa <- c("A_lifetime", "B_over1y"); wb <- c(wa, "C_pastyear_never")
sh <- rbind(
  cbind(window = "a", rbind(share(dd, wa), share(dd, wa, ~sex), share(dd, wa, ~age4), share(dd, wa, ~sex + age4))),
  cbind(window = "b", rbind(share(dd, wb), share(dd, wb, ~sex), share(dd, wb, ~age4), share(dd, wb, ~sex + age4))))
print(sh, digits = 3); utils::write.csv(sh, file.path(out, "encavi_lifetime_share.csv"), row.names = FALSE)

eq <- survey::svymean(~factor(e3eq), subset(dd, !is.na(e3eq)))
enc_e3 <- data.frame(source = "ENCAVI (constructed)", code = 1:5, n = as.integer(table(dd$variables$e3eq)),
                     pct = 100 * unname(coef(eq)), lo = 100 * stats::confint(eq)[, 1], hi = 100 * stats::confint(eq)[, 2])
ed <- survey::svymean(~factor(educ4), subset(dd, g %in% wb))
enc_edu <- data.frame(code = 1:4, n = as.integer(table(subset(dd, g %in% wb)$variables$educ4)), pct = 100 * unname(coef(ed)))
print(enc_edu, digits = 3); utils::write.csv(enc_edu, file.path(out, "encavi_nondrinker_educ.csv"), row.names = FALSE)

# TSM round 7, respondents 18-65 (same selection as ts_load: Entrevistado == 1).
top <- acc_data("_tsm/tsm.tar.xz.enc")
r7 <- as.data.frame(haven::read_sav(file.path(top, "TSM Ronda 7.sav")))
r7 <- r7[r7$Entrevistado %in% 1, ]; r7$age <- as.numeric(r7$a3); r7 <- r7[r7$age >= 18 & r7$age <= 65, ]
r7$e3a1 <- as.numeric(r7$e3a1); r7$w <- as.numeric(r7$Fact_Exp)
r7$sex <- ifelse(as.numeric(r7$a2) == 1, "Men", "Women"); r7$age4 <- age4(r7$age)
r7$edu_len <- ts_education(r7$b4a, r7$b4b, r7$b1, "lenient"); r7$edu_rea <- ts_education(r7$b4a, r7$b4b, r7$b1, "reached")
tdes <- survey::svydesign(ids = ~1, weights = ~w, data = r7)   # no PSU/strata published for TSM
te <- survey::svymean(~factor(e3a1), tdes)
tsm_e3 <- data.frame(source = "TSM R7", code = 1:5, n = as.integer(table(r7$e3a1)), pct = 100 * unname(coef(te)),
                     lo = 100 * stats::confint(te)[, 1], hi = 100 * stats::confint(te)[, 2])
e3 <- rbind(enc_e3, tsm_e3); print(e3, digits = 3); utils::write.csv(e3, file.path(out, "e3a1_compare.csv"), row.names = FALSE)

nd <- r7[r7$e3a1 == 1, ]
cells <- stats::aggregate(cbind(n = 1, w = nd$w) ~ sex + age4, data = data.frame(nd[c("sex", "age4")], w = nd$w), FUN = sum)
cells$share_w <- 100 * cells$w / sum(cells$w)
for (wn in c("a", "b")) {   # illustration only: ENCAVI sex x age share applied to TSM R7 non-drinkers
  s <- sh[sh$window == wn, ]; k <- match(paste(cells$sex, cells$age4), s$cell)
  cells[[paste0("p_", wn)]] <- s$pct[k]; cells[[paste0("lo_", wn)]] <- s$lo[k]; cells[[paste0("hi_", wn)]] <- s$hi[k]
  cat("window", wn, ": implied lifetime abstainers among TSM R7 non-drinkers (weighted):",
      round(sum(cells$w * s$pct[k]) / sum(cells$w), 1), "%; unweighted n:", round(sum(cells$n * s$pct[k] / 100)), "\n")
}
print(cells, digits = 4); utils::write.csv(cells, file.path(out, "tsm_r7_nondrinkers.csv"), row.names = FALSE)
cat("TSM R7 18-65:", nrow(r7), "respondents;", nrow(nd), "non-drinkers\n")
print(table(lenient = nd$edu_len, reached = nd$edu_rea, useNA = "ifany"))
utils::write.csv(as.data.frame(table(lenient = nd$edu_len, reached = nd$edu_rea, useNA = "ifany")),
                 file.path(out, "tsm_r7_nondrinker_edu_rules.csv"), row.names = FALSE)
cat("Elapsed:", round(as.numeric(difftime(Sys.time(), .t0, units = "mins")), 2), "min\n")
