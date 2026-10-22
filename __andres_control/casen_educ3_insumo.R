# casen_educ3_insumo.R
# Harmonised 3-level education (basic or less / secondary / tertiary completed) from CASEN 2013-2024,
# by sex x single age (15-65) and sex x engine age group, national population, design-based.
# Output: target shares to post-stratify the ENPG (urban) to the national population and to
# assign education to the simulated population of the alcohol microsimulation (FONDECYT 1240138).
#
# Minimum inputs (all in `dir_casen`):
#   2013.rds, 2015.rds                                  CASEN 2013 / 2015 person files (need folio, o, edad, sexo,
#                                                       e6a, e6b, [e6c in 2013], educ, expr, strata/PSU)
#   Casen2013_factor_raking_deciles_y_quintil STATA.dta  new expansion factor (Censo 2017 + raking), 2013
#   Casen2015_factor_raking_deciles_y_quintil STATA.dta  idem, 2015
#   casen_2017_dta.zip, casen_en_pandemia_2020_dta.zip, casen_2022stata.zip, casen_2024stata.zip
# R packages: haven, survey, dplyr. Runtime about 10-12 minutes (2024 file is 1.6 GB unzipped).

.t0 <- Sys.time()
dir_casen <- Sys.getenv("CASEN_DIR", "C:/Users/nDP/Desktop/CASEN")
dir_out <- file.path(dir_casen, "salidas_educ3")
dir.create(dir_out, showWarnings = FALSE)
options(survey.lonely.psu = "adjust")
num <- function(x) as.numeric(haven::zap_labels(x))

# --- Education rule from e6a (+ e6b / e6c / e6c_completo), one branch per questionnaire version ---
e3 <- function(d, y) {
  a <- num(d$e6a); b <- num(d$e6b)
  is1 <- function(x) x %in% 1                 # NA-safe "yes, completed"
  ge  <- function(x, k) !is.na(x) & x >= k
  # Secondary completed: 4th year (old Humanidades: 6th year); 2013 uses e6c instead
  med_ok <- (a %in% c(9, 10, 11) & ge(b, 4)) | (a == 8 & ge(b, 6))
  if (y == 2013) {                            # e6a 1-13 "Tipo de nivel educacional actual" + e6c "Completó el nivel"
    c <- num(d$e6c)
    high <- (a %in% 11:12 & is1(c)) | a == 13
    mid  <- (a %in% 7:10 & is1(c)) | (a %in% 11:12 & !is1(c))
    low  <- a %in% 1:10 & !mid
  } else if (y %in% c(2015, 2017, 2020)) {    # e6a 1-17, completion embedded in the code
    high <- a %in% c(13, 15, 16, 17)
    mid  <- a %in% c(12, 14) | med_ok
    low  <- a %in% 1:11 & !med_ok
  } else {                                    # 2022/2024: e6a 1-15 + e6c_completo (not asked to current students)
    c <- num(d$e6c_completo)
    high <- (a %in% 12:13 & is1(c)) | a %in% 14:15
    mid  <- (a %in% 12:13 & !is1(c)) | med_ok
    low  <- a %in% 1:11 & !med_ok
  }
  out <- ifelse(high, 3, ifelse(mid, 2, ifelse(low, 1, NA)))
  out[a == 99 | is.na(a)] <- NA
  out
}
# Ministry summary variable in 3 levels, used only to validate the rule
ref3 <- function(d, y) {
  if (y %in% c(2013, 2015)) { e <- num(d$educ); dplyr::case_when(e %in% 0:4 ~ 1, e %in% c(5, 6, 7, 9) ~ 2, e %in% c(8, 10, 11, 12) ~ 3) }
  else { e <- num(d$educc); dplyr::case_when(e %in% 0:3 ~ 1, e %in% 4:5 ~ 2, e == 6 ~ 3) }
}

# --- Readers ---
read_zip_dta <- function(zipname, cols, enc = NULL) {
  z <- file.path(dir_casen, zipname)
  f <- utils::unzip(z, list = TRUE)$Name[1]
  utils::unzip(z, files = f, exdir = tempdir(), overwrite = TRUE)
  on.exit(unlink(file.path(tempdir(), f)))
  haven::read_dta(file.path(tempdir(), f), col_select = dplyr::all_of(cols), encoding = enc)
}
read_round <- function(y) {
  base <- c("edad", "sexo", "e6a", "e6b", "expr")
  if (y %in% c(2013, 2015)) {
    d <- readRDS(file.path(dir_casen, sprintf("%d.rds", y)))
    d <- d[, c("folio", "o", base, if (y == 2013) c("e6c", "var_strat", "var_unit") else c("varstrat", "varunit"), "educ")]
    if (y == 2013) { d$varstrat <- d$var_strat; d$varunit <- d$var_unit }
    # Replace the old (Censo 2002) factor with the new one (Censo 2017 + raking)
    k <- haven::read_dta(file.path(dir_casen, sprintf("Casen%d_factor_raking_deciles_y_quintil STATA.dta", y)), col_select = c("folio", "o", "expr_c2017_nm"))
    n0 <- nrow(d)
    d <- dplyr::inner_join(d, k, by = c("folio", "o"))
    stopifnot(nrow(d) == n0, all(!is.na(d$expr_c2017_nm)))
    d$expr <- d$expr_c2017_nm
    return(d)
  }
  zips <- c(`2017` = "casen_2017_dta.zip", `2020` = "casen_en_pandemia_2020_dta.zip", `2022` = "casen_2022stata.zip", `2024` = "casen_2024stata.zip")
  read_zip_dta(zips[[as.character(y)]], c(base, "varstrat", "varunit", "educc", if (y >= 2022) "e6c_completo"), enc = if (y == 2020) "latin1" else NULL)
}

# --- Estimation, one design per round ---
years <- c(2013, 2015, 2017, 2020, 2022, 2024)
cells <- list(); grp <- list(); val <- list()
for (y in years) {
  d <- read_round(y)
  d$edad <- num(d$edad); d$sexo <- num(d$sexo); d$expr <- num(d$expr)
  d <- d[d$edad >= 15 & d$edad <= 65, ]
  d$educ3 <- e3(d, y); r <- ref3(d, y); ok <- !is.na(d$educ3) & !is.na(r)
  val[[length(val) + 1]] <- data.frame(anio = y, n = nrow(d), pct_na = round(100 * mean(is.na(d$educ3)), 2),
                                       acuerdo_15_65 = round(100 * mean(d$educ3[ok] == r[ok]), 2), pob_15_65_M = round(sum(d$expr) / 1e6, 3))
  d <- d[!is.na(d$educ3), ]
  d$ag <- cut(d$edad, c(14, 29, 44, 59, 65), labels = c("15-29", "30-44", "45-59", "60-65"))
  for (k in 1:3) d[[paste0("e", k)]] <- as.numeric(d$educ3 == k)
  des <- survey::svydesign(ids = ~varunit, strata = ~varstrat, weights = ~expr, data = d, nest = TRUE)
  s <- survey::svyby(~e1 + e2 + e3, ~sexo + edad, des, survey::svymean, vartype = "se")
  s$n <- as.vector(table(interaction(d$sexo, d$edad))[paste(s$sexo, s$edad, sep = ".")])
  s$anio <- y; cells[[length(cells) + 1]] <- s
  g <- survey::svyby(~e1 + e2 + e3, ~sexo + ag, des, survey::svymean, vartype = "se")
  g$anio <- y; grp[[length(grp) + 1]] <- g
  message(sprintf("%d done, elapsed %.2f min", y, as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
}
cells <- dplyr::bind_rows(cells); grp <- dplyr::bind_rows(grp); val <- dplyr::bind_rows(val)

# 3-age centred moving average within sex x round (single-age noise ~1.6 pp -> smoother age profile)
cells <- cells |> dplyr::arrange(anio, sexo, edad) |> dplyr::group_by(anio, sexo) |>
  dplyr::mutate(dplyr::across(c(e1, e2, e3), ~ (dplyr::lag(.x, default = dplyr::first(.x)) + .x + dplyr::lead(.x, default = dplyr::last(.x))) / 3, .names = "{.col}_s")) |>
  dplyr::ungroup()
stopifnot(all(abs(cells$e1 + cells$e2 + cells$e3 - 1) < 1e-8), nrow(cells) == length(years) * 2 * 51)

# --- ENPG years from CASEN rounds (linear interpolation in calendar time) ---
mapw <- data.frame(enpg = c(2012, 2014, 2016, 2018, 2020, 2022, 2024),
                   a = c(2013, 2013, 2015, 2017, 2020, 2022, 2024), b = c(2013, 2015, 2017, 2020, 2020, 2022, 2024),
                   wb = c(0, .5, .5, 1 / 3, 0, 0, 0))
mk <- function(tab, keys, vars) do.call(rbind, lapply(seq_len(nrow(mapw)), function(i) {
  A <- tab[tab$anio == mapw$a[i], ]; B <- tab[tab$anio == mapw$b[i], ]
  B <- B[match(do.call(paste, A[keys]), do.call(paste, B[keys])), ]
  out <- A[keys]; out$anio_enpg <- mapw$enpg[i]
  out$fuente <- if (mapw$wb[i] == 0) paste("CASEN", mapw$a[i]) else sprintf("CASEN %d (%.0f%%) + %d (%.0f%%)", mapw$a[i], 100 * (1 - mapw$wb[i]), mapw$b[i], 100 * mapw$wb[i])
  for (v in vars) out[[sub("_s$", "", v)]] <- (1 - mapw$wb[i]) * A[[v]] + mapw$wb[i] * B[[v]]
  out }))
enpg_age <- mk(as.data.frame(cells), c("sexo", "edad"), c("e1_s", "e2_s", "e3_s"))
enpg_grp <- mk(as.data.frame(grp), c("sexo", "ag"), c("e1", "e2", "e3"))
stopifnot(nrow(enpg_age) == 7 * 2 * 51, nrow(enpg_grp) == 7 * 2 * 4,
          all(abs(enpg_age$e1 + enpg_age$e2 + enpg_age$e3 - 1) < 1e-8))

# --- Check: linear trend 2013-2022 projected to 2024 vs observed 2024 ---
chk <- grp |> dplyr::filter(anio < 2024) |> dplyr::group_by(sexo, ag) |>
  dplyr::summarise(p1_proy = 100 * stats::predict(stats::lm(e1 ~ anio), data.frame(anio = 2024)),
                   p3_proy = 100 * stats::predict(stats::lm(e3 ~ anio), data.frame(anio = 2024)), .groups = "drop") |>
  dplyr::left_join(grp |> dplyr::filter(anio == 2024) |> dplyr::transmute(sexo, ag, p1_real = 100 * e1, p3_real = 100 * e3), by = c("sexo", "ag"))

utils::write.csv(enpg_grp, file.path(dir_out, "insumo_educ3_sexo_tramo_anio_enpg.csv"), row.names = FALSE)
utils::write.csv(enpg_age, file.path(dir_out, "insumo_educ3_sexo_edad_anio_enpg.csv"), row.names = FALSE)
utils::write.csv(cells, file.path(dir_out, "casen_educ3_sexo_edad_rondas.csv"), row.names = FALSE)
utils::write.csv(grp, file.path(dir_out, "casen_educ3_sexo_tramo_rondas.csv"), row.names = FALSE)
utils::write.csv(val, file.path(dir_out, "validacion.csv"), row.names = FALSE)
utils::write.csv(chk, file.path(dir_out, "chequeo_2024.csv"), row.names = FALSE)
print(val); print(as.data.frame(chk), digits = 3)
cat("SE single-age (pp): median", round(100 * stats::median(c(cells$se.e1, cells$se.e3)), 2),
    "p95", round(100 * stats::quantile(c(cells$se.e1, cells$se.e3), .95), 2), "| n single-age min", min(cells$n), "median", stats::median(cells$n), "\n")
message(sprintf("Elapsed: %.2f min", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
