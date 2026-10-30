.t0 <- Sys.time()
# ENPG age/sex/education support descriptives for the 2012-2024 rounds used in micsim.
# Read-only: no raw file, filter, engine object or scenario is modified. Only aggregate tables are written.
# Variable specs copied from enpg_casen_aps.R (eca_enpg); quantity/HED rules copied from
# enpg_casen_rural_prelim.R (eca_rural_enpg, eca_history). Run from the project root with ACC_DATA_KEY set.
source(here::here("_tools", "acc_data.R"))
out <- file.path(acc_root(), "__andres_control", "enpg_soporte_edad_outputs")
dir.create(out, showWarnings = FALSE, recursive = TRUE)
num <- function(x) as.numeric(haven::zap_labels(x))
wcsv <- function(x, name) utils::write.csv(x, file.path(out, paste0(name, ".csv")), row.names = FALSE, fileEncoding = "UTF-8")
band <- function(a) dplyr::case_when(is.na(a) ~ "age_missing", a < 12 ~ "<12 (quality)", a <= 14 ~ "12-14",
  a <= 17 ~ "15-17", a <= 29 ~ "18-29", a <= 44 ~ "30-44", a <= 59 ~ "45-59", a <= 64 ~ "60-64",
  a == 65 ~ "65", TRUE ~ ">65 (quality)")
educ3 <- function(level, complete) dplyr::case_when(level %in% 1:4 ~ 1L,
  level %in% 5:8 & complete == 1 ~ 2L, level %in% 5:8 & complete == 2 ~ 1L,
  level %in% 9:10 & complete == 1 ~ 3L, level %in% 9:10 & complete == 2 ~ 2L,
  level %in% 11:13 ~ 3L, TRUE ~ NA_integer_)
kish <- function(w) if (length(w)) sum(w)^2 / sum(w^2) else NA_real_
wmean <- function(y, w) { ok <- !is.na(y); if (any(ok)) sum(w[ok] * y[ok]) / sum(w[ok]) else NA_real_ }

raw <- acc_data("_enpg/enpg.tar.xz.enc")
spec <- data.frame(anio = seq(2012, 2024, 2),
  file = c("Base de datos ENPG 2012 (PG).DTA.dta", "Base de datos ENPG 2014 (PG).DTA.dta",
    "base ENPG 2016 publico general.dta", "Base de datos ENPG 2018 (PG).DTA", "enpg2020.RDS",
    "BD - ENPG 2022 (Stata 16).dta", "Base Publica ENPG 2024 (Stata 16).dta"),
  id = c("idencuesta", "idencuesta", "idencuesta", "SbjNum", "SbjNum", "FOLIO", "RESPONDENT_SERIAL"),
  weight = c("PONDERADOR", "F2_MAY_AJUS_com", "Fexp", "Fexp", "FACT_PERS_COMUNA", "FACTOR_EXPANSION", "FACTOR_EXPANSION"),
  sex = c("sexo", "sexo", "sexo", "S01", "S01", "SEXO", "SEXO"),
  age = c("edad", "edad", "edad", "S02", "S02", "EDAD", "EDAD"),
  level = c("p184_1", "dp9_1", "dp_9_a", "T_DP_12_1", "DP_12", "DP_12", "DP_12"),
  complete = c("p185_1", "dp10_1", "dp_10_a", "T_DP_13_1", "DP_13", "DP_13", "DP_13"),
  head = c("p182", "dp7", "dp_7", "DP_10", NA, NA, NA),
  head_level = c("p184_2", "dp9_2", "dp_9_b", "T_DP_12_2", NA, NA, NA),
  head_complete = c("p185_2", "dp10_2", "dp_10_b", "T_DP_13_2", NA, NA, NA),
  ever = c("p10", "oh1", "oh_1", "OH_1", "OH_1", "OH_1", "OH_1"),
  last = c("p13", "oh4", "oh_4", "OH_4", "OH_4", "OH_4", "OH_4"))
b <- readRDS(file.path(raw, "derived", "ENPG_BINGE.RDS"))
bkey <- paste(b$year, as.character(b$id)); stopifnot(!anyDuplicated(bkey))

rows <- lapply(seq_len(nrow(spec)), function(i) {
  s <- spec[i, ]; f <- file.path(raw, s$file)
  d <- if (grepl("RDS$", f)) readRDS(f) else haven::read_dta(f)
  if (s$anio == 2016) {
    w <- haven::read_dta(file.path(raw, "enpg16_factoresdeexpansion.dta"))
    stopifnot(!anyDuplicated(w$idencuesta), !anyDuplicated(d$idencuesta))
    d <- dplyr::left_join(d, w[c("idencuesta", "Fexp")], by = "idencuesta")
  }
  g <- function(k) num(d[[k]])
  level <- g(s$level); comp <- g(s$complete); use_head <- rep(FALSE, nrow(d))
  if (!is.na(s$head)) { use_head <- g(s$head) %in% 1; level[use_head] <- g(s$head_level)[use_head]
    comp[use_head] <- g(s$head_complete)[use_head] }
  ever <- g(s$ever); last <- g(s$last)
  x <- data.frame(anio = s$anio, id = as.character(d[[s$id]]), sexo = g(s$sex), edad = g(s$age), peso = g(s$weight),
    educ3 = educ3(level, comp), educ_completion_unknown = level %in% 5:10 & !comp %in% 1:2,
    current = dplyr::case_when(ever == 2 ~ 0, ever == 1 & last == 1 ~ 1, ever == 1 & last %in% 2:3 ~ 0, TRUE ~ NA_real_))
  stopifnot(!anyDuplicated(x$id))
  x$band <- band(x$edad)
  # Engine-consistent quantity and HED (ENPG_BINGE: oh3 days, audit2 typical drinks, db 5+/4+ occasions), ages 15-65.
  inm <- !is.na(x$edad) & x$edad >= 15 & x$edad <= 65
  j <- match(paste(x$anio, x$id), bkey)
  stopifnot(!anyNA(j[inm & x$sexo %in% 1:2 & is.finite(x$peso) & x$peso > 0]))
  days <- num(b$oh3[j]); days[days %in% c(88, 99)] <- NA_real_
  db <- num(b$db[j]); db[db >= 88 | db < 0] <- NA_real_
  q <- unname(c("0-2" = 1, "3-4" = 3.5, "5-6" = 5.5, "7-8" = 7.5, "9 o mas" = 9)[as.character(b$audit2[j])])
  gr <- (pmax(days - db, 0) * q + db * ifelse(x$sexo == 1, 5, 4)) * 12 / 30
  x$quantity_valid <- x$current %in% 1 & is.finite(gr) & gr > 0 & !(days > 30) %in% TRUE
  x$hed <- dplyr::case_when(x$current == 0 & (is.na(db) | db == 0) ~ 0, x$current == 1 & !is.na(db) ~ as.numeric(db > 0),
    TRUE ~ NA_real_)
  x$hed[!inm] <- NA_real_; x$quantity_valid[!inm] <- FALSE
  x
})
x <- dplyr::bind_rows(rows)
okw <- is.finite(x$peso) & x$peso > 0

# T0: per-round data quality (all raw rows, before any analytic filter).
t0 <- x |> dplyr::group_by(anio) |> dplyr::summarise(n_raw = dplyr::n(), age_min = min(edad, na.rm = TRUE),
  age_max = max(edad, na.rm = TRUE), n_age_missing = sum(is.na(edad)), n_age_outside_12_65 = sum(edad < 12 | edad > 65, na.rm = TRUE),
  n_sex_missing_or_other = sum(!sexo %in% 1:2), n_weight_missing_or_nonpositive = sum(!(is.finite(peso) & peso > 0)),
  n_12_14 = sum(edad %in% 12:14), n_15_65 = sum(edad >= 15 & edad <= 65, na.rm = TRUE), .groups = "drop")
wcsv(t0, "T0_round_quality")

# T1: age band x sex, unweighted n and expanded population (sum of expansion factors; not a sample size).
t1 <- x |> dplyr::group_by(anio, band, sexo) |> dplyr::summarise(n = dplyr::n(), n_weight_ok = sum(is.finite(peso) & peso > 0),
  expanded_pop = sum(peso[is.finite(peso) & peso > 0]), .groups = "drop")
wcsv(t1, "T1_age_sex_counts")

# T2: indicator support, ages 15-65 with valid sex and weight (the engine universe).
m <- x[okw & x$sexo %in% 1:2 & !is.na(x$edad) & x$edad >= 15 & x$edad <= 65, ]
t2 <- m |> dplyr::group_by(anio, band, sexo) |> dplyr::summarise(n = dplyr::n(),
  current_known = sum(!is.na(current)), current_yes = sum(current %in% 1), current_no = sum(current %in% 0),
  current_unknown = sum(is.na(current)), quantity_valid = sum(quantity_valid),
  current_without_valid_quantity = sum(current %in% 1 & !quantity_valid),
  hed_valid = sum(!is.na(hed)), hed_yes = sum(hed %in% 1), hed_valid_among_current = sum(current %in% 1 & !is.na(hed)),
  w_pct_current = 100 * wmean(current, peso), w_pct_hed_population = 100 * wmean(hed, peso),
  w_pct_hed_among_current = 100 * wmean(ifelse(current %in% 1, hed, NA), peso),
  kish_current = kish(peso[!is.na(current)]), .groups = "drop")
wcsv(t2, "T2_indicator_support_age_sex")

# T3: age band x sex x education (attained level; head-of-household columns read for heads in 2012-2018).
t3 <- m |> dplyr::group_by(anio, band, sexo, educ3) |> dplyr::summarise(n = dplyr::n(), current_yes = sum(current %in% 1),
  quantity_valid = sum(quantity_valid), hed_yes = sum(hed %in% 1), completion_unknown = sum(educ_completion_unknown),
  expanded_pop = sum(peso), .groups = "drop") |>
  dplyr::group_by(anio, band, sexo) |> dplyr::mutate(w_pct_of_age_sex = 100 * expanded_pop / sum(expanded_pop)) |> dplyr::ungroup()
wcsv(t3, "T3_age_sex_education")

# T4: single ages at the borders (15-19 and 60-65).
t4 <- m[m$edad %in% c(15:19, 60:65), ] |> dplyr::group_by(anio, edad, sexo) |> dplyr::summarise(n = dplyr::n(),
  current_yes = sum(current %in% 1), quantity_valid = sum(quantity_valid), hed_yes = sum(hed %in% 1), .groups = "drop")
wcsv(t4, "T4_single_age_borders")
wcsv(data.frame(file = list.files(raw, recursive = TRUE), md5 = unname(tools::md5sum(list.files(raw, recursive = TRUE, full.names = TRUE)))),
  "input_manifest")
cat(sprintf("Elapsed: %.2f minutes\n", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
