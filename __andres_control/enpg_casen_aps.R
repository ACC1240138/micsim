.t0 <- Sys.time()
# Independent input preparation; existing mortality and simulation pipelines are not changed.
source(here::here("_tools", "acc_data.R"))
eca_dir <- file.path(acc_root(), "__andres_control", "enpg_casen_aps_outputs")
dir.create(eca_dir, recursive = TRUE, showWarnings = FALSE)
eca_num <- function(x) as.numeric(haven::zap_labels(x))
eca_write <- function(x, name) utils::write.csv(x, file.path(eca_dir, paste0(name, ".csv")), row.names = FALSE, fileEncoding = "UTF-8")
eca_age <- function(x) as.character(cut(x, c(14, 29, 44, 59, 65), labels = c("15-29", "30-44", "45-59", "60-65")))

eca_educ <- function(level, complete) {
  # Unknown completion is not evidence of non-completion.
  dplyr::case_when(level %in% 1:4 ~ 1L,
    level %in% 5:8 & complete == 1 ~ 2L,
    level %in% 5:8 & complete == 2 ~ 1L,
    level %in% 9:10 & complete == 1 ~ 3L,
    level %in% 9:10 & complete == 2 ~ 2L,
    level %in% 11:13 ~ 3L, TRUE ~ NA_integer_)
}

eca_poststrat <- function(d, targets) {
  keys <- c("anio", "sexo", "ag", "educ3")
  stopifnot(!anyDuplicated(targets[keys]), all(is.finite(d$peso)), all(d$peso > 0),
    all(is.finite(targets$p_casen)), all(targets$p_casen >= 0 & targets$p_casen <= 1))
  sums <- targets |> dplyr::group_by(anio, sexo, ag) |> dplyr::summarise(s = sum(p_casen), .groups = "drop")
  stopifnot(all(abs(sums$s - 1) < 1e-10))
  counts <- d |> dplyr::filter(!is.na(educ3)) |>
    dplyr::group_by(dplyr::across(dplyr::all_of(keys))) |>
    dplyr::summarise(n = dplyr::n(), w = sum(peso), .groups = "drop") |>
    dplyr::group_by(anio, sexo, ag) |> dplyr::mutate(p_enpg = w / sum(w)) |> dplyr::ungroup()
  factors <- dplyr::left_join(targets, counts, by = keys)
  if (any(factors$p_casen > 0 & (is.na(factors$w) | factors$w <= 0))) stop("Positive target without ENPG support")
  factors$factor_educ <- ifelse(factors$p_casen == 0, 0, factors$p_casen / factors$p_enpg)
  result <- dplyr::left_join(d, factors[c(keys, "factor_educ")], by = keys)
  result$factor_educ[is.na(result$educ3)] <- 1
  stopifnot(nrow(result) == nrow(d), !anyNA(result$factor_educ))
  result$peso_educ <- result$peso * result$factor_educ
  totals <- result |> dplyr::group_by(anio, sexo, ag) |>
    dplyr::summarise(before = sum(peso), after = sum(peso_educ), .groups = "drop")
  stopifnot(all(abs(totals$after / totals$before - 1) < 1e-10),
    all(result$peso_educ[is.na(result$educ3)] == result$peso[is.na(result$educ3)]))
  achieved <- result |> dplyr::filter(!is.na(educ3)) |>
    dplyr::group_by(dplyr::across(dplyr::all_of(keys))) |>
    dplyr::summarise(w_after = sum(peso_educ), .groups = "drop") |>
    dplyr::group_by(anio, sexo, ag) |> dplyr::mutate(p_after = w_after / sum(w_after)) |> dplyr::ungroup()
  factors <- dplyr::left_join(factors, achieved, by = keys)
  stopifnot(all(abs(factors$p_after[factors$p_casen > 0] - factors$p_casen[factors$p_casen > 0]) < 1e-10))
  list(data = result, factors = factors, totals = totals)
}

eca_enpg <- function() {
  .t0 <- Sys.time()
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
  waves <- audits <- list()
  for (i in seq_len(nrow(spec))) {
    s <- spec[i, ]; f <- file.path(raw, s$file)
    d <- if (grepl("RDS$", f)) readRDS(f) else haven::read_dta(f)
    if (s$anio == 2016) {
      w <- haven::read_dta(file.path(raw, "enpg16_factoresdeexpansion.dta"))
      stopifnot(!anyDuplicated(w$idencuesta), !anyDuplicated(d$idencuesta))
      d <- dplyr::left_join(d, w[c("idencuesta", "Fexp")], by = "idencuesta")
    }
    get <- function(k) eca_num(d[[k]])
    level <- get(s$level); completed <- get(s$complete); use_head <- rep(FALSE, nrow(d))
    if (!is.na(s$head)) {
      use_head <- get(s$head) %in% 1
      level[use_head] <- get(s$head_level)[use_head]
      completed[use_head] <- get(s$head_complete)[use_head]
    }
    ever <- get(s$ever); last <- get(s$last)
    monthly <- dplyr::case_when(ever == 2 ~ 0, ever == 1 & last == 1 ~ 1,
      ever == 1 & last %in% 2:3 ~ 0, TRUE ~ NA_real_)
    annual <- dplyr::case_when(ever == 2 ~ 0, ever == 1 & last %in% 1:2 ~ 1,
      ever == 1 & last == 3 ~ 0, TRUE ~ NA_real_)
    x <- data.frame(anio = s$anio, id = as.character(d[[s$id]]), sexo = get(s$sex), edad = get(s$age),
      peso = get(s$weight), educ3 = eca_educ(level, completed), current_30d = monthly, current_12m = annual)
    stopifnot(!anyDuplicated(x$id))
    keep <- !is.na(x$edad) & x$edad >= 15 & x$edad <= 65 & x$sexo %in% 1:2 & is.finite(x$peso) & x$peso > 0
    audits[[i]] <- data.frame(anio = s$anio, n_raw = nrow(x), n_eligible = sum(keep),
      n_excluded = sum(!keep), n_head_selected = sum(use_head & keep),
      n_educ_missing = sum(is.na(x$educ3[keep])),
      pct_educ_missing_weighted = 100 * stats::weighted.mean(is.na(x$educ3[keep]), x$peso[keep]),
      n_completion_unknown = sum(keep & level %in% 5:10 & !completed %in% 1:2),
      n_alcohol_inconsistent = sum(keep & ever == 2 & last %in% 1:2, na.rm = TRUE))
    waves[[i]] <- x[keep, ]
  }
  d <- dplyr::bind_rows(waves); d$ag <- eca_age(d$edad)
  target_file <- file.path(eca_dir, "casen_targets_enpg_years.csv")
  target <- utils::read.csv(target_file) |>
    tidyr::pivot_longer(c(e1, e2, e3), names_to = "educ3", values_to = "p_casen") |>
    dplyr::mutate(educ3 = as.integer(sub("e", "", educ3)))
  fit <- eca_poststrat(d, target)
  estimates <- lapply(c("current_30d", "current_12m"), function(outcome) {
    fit$data |> dplyr::group_by(anio) |>
      dplyr::summarise(outcome = outcome, n_valid = sum(!is.na(.data[[outcome]])),
        p_original = stats::weighted.mean(.data[[outcome]], peso, na.rm = TRUE),
        p_educ = stats::weighted.mean(.data[[outcome]], peso_educ, na.rm = TRUE),
        .groups = "drop") |> dplyr::mutate(change_pp = 100 * (p_educ - p_original))
  }) |> dplyr::bind_rows()
  diagnostics <- fit$data |> dplyr::group_by(anio) |>
    dplyr::summarise(n = dplyr::n(), min_factor = min(factor_educ), max_factor = max(factor_educ),
      neff_original = sum(peso)^2 / sum(peso^2), neff_educ = sum(peso_educ)^2 / sum(peso_educ^2), .groups = "drop")
  eca_write(spec, "enpg_variable_map"); eca_write(dplyr::bind_rows(audits), "enpg_audit")
  eca_write(fit$factors, "enpg_factors_educ3"); eca_write(fit$totals, "enpg_total_checks")
  eca_write(estimates, "enpg_consumption_comparison"); eca_write(diagnostics, "enpg_weight_diagnostics")
  tmp <- file.path(tempdir(), "enpg_poststrat_educ3.rds")
  saveRDS(fit$data, tmp)
  bundle <- file.path(eca_dir, "enpg_poststrat_educ3.rds.tar.xz.enc")
  acc_pack(tmp, bundle)
  restored <- readRDS(acc_data("__andres_control/enpg_casen_aps_outputs/enpg_poststrat_educ3.rds.tar.xz.enc"))
  stopifnot(identical(restored, fit$data))
  eca_write(data.frame(source = c(paste0("_enpg/enpg.tar.xz.enc::", spec$file),
    "__andres_control/enpg_casen_aps_outputs/casen_targets_enpg_years.csv"),
    md5 = unname(tools::md5sum(c(file.path(raw, spec$file), target_file)))), "enpg_sources")
  print(dplyr::bind_rows(audits)); print(estimates); print(diagnostics)
  message(sprintf("Elapsed: %.2f min", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
  invisible(fit)
}

eca_demography <- function() {
  .t0 <- Sys.time()
  p <- list.files(file.path(acc_root(), "__andres_control"), "EEPP comuna area", full.names = TRUE)
  stopifnot(length(p) == 1)
  d <- data.table::fread(p, sep = ";", encoding = "UTF-8", data.table = FALSE)
  names(d)[c(1, 5, 6, 7, 8, 9)] <- c("region", "comuna", "nombre", "sexo", "area", "age5")
  d$lo <- as.numeric(regmatches(d$age5, regexpr("[0-9]+", d$age5)))
  # shortcut: INE has five-year ages; use 60-64, never allocate one fifth of 65-69 to age 65.
  d <- d[d$lo >= 15 & d$lo <= 60, ]
  d$ag <- as.character(cut(d$lo, c(14, 29, 44, 59, 64), labels = c("15-29", "30-44", "45-59", "60-64")))
  d <- d |> tidyr::pivot_longer(dplyr::all_of(paste("Poblacion", seq(2012, 2024, 2))), names_to = "anio", values_to = "population") |>
    dplyr::mutate(anio = as.integer(sub("Poblacion ", "", anio))) |>
    dplyr::group_by(anio, region, comuna, nombre, sexo, ag) |>
    dplyr::summarise(population = sum(population), .groups = "drop") |>
    dplyr::group_by(anio, comuna) |> dplyr::mutate(p_sexo_edad_en_comuna = population / sum(population)) |>
    dplyr::ungroup() |> dplyr::group_by(anio, sexo, ag) |>
    dplyr::mutate(p_comuna_dado_sexo_edad = population / sum(population)) |> dplyr::ungroup()
  sums <- d |> dplyr::group_by(anio, comuna) |> dplyr::summarise(p = sum(p_sexo_edad_en_comuna), .groups = "drop")
  stopifnot(nrow(d) == 7 * 346 * 2 * 4, all(abs(sums$p - 1) < 1e-10), all(d$population >= 0))
  eca_write(d, "ine_sexo_edad_comuna_2012_2024")
  eca_write(data.frame(source = basename(p), md5 = unname(tools::md5sum(p)), age_scope = "15-64", population_base = "Existing INE projections, census 2017 base"), "ine_sources")
  print(data.frame(rows = nrow(d), communes = length(unique(d$comuna)), age_scope = "15-64"))
  message(sprintf("Elapsed: %.2f min", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
  invisible(d)
}

eca_casen_read <- function(year, health = FALSE, rural = FALSE) {
  base <- c("edad", "sexo", "e6a", "e6b", "expr")
  if (year %in% c(2013, 2015)) {
    d <- readRDS(acc_data(sprintf("_casen/%d.rds.tar.xz.enc", year)))
    k <- haven::read_dta(acc_data(sprintf("_casen/Casen%d_factor_raking_deciles_y_quintil STATA.dta.tar.xz.enc", year)),
      col_select = c("folio", "o", "expr_c2017_nm"))
    stopifnot(!anyDuplicated(k[c("folio", "o")]), !anyDuplicated(d[c("folio", "o")]))
    j <- match(paste(d$folio, d$o), paste(k$folio, k$o))
    stopifnot(!anyNA(j))
    d$expr <- k$expr_c2017_nm[j]
    if (year == 2013) { d$varstrat <- d$var_strat; d$varunit <- d$var_unit }
    vars <- c(base, "varstrat", "varunit", "educ", if (year == 2013) "e6c")
    if (rural) vars <- c(vars, "zona")
    if (health) vars <- c(vars, "folio", "o", "region", "comuna", "expc",
      if (year == 2013) c("s22a", "s22b", "s29a", "s29c") else c("s19a", "s19b", "s26a", "s26c"))
    return(d[vars])
  }
  files <- c(`2017` = "casen_2017_dta.zip", `2020` = "casen_en_pandemia_2020_dta.zip",
    `2022` = "casen_2022stata.zip", `2024` = "casen_2024stata.zip")
  vars <- c(base, "varstrat", "varunit", "educc", if (year >= 2022) "e6c_completo")
  if (rural) vars <- c(vars, "area")
  if (health) vars <- c(vars, "region", "folio", if (year == 2017) "o" else "id_persona",
    if (year == 2017) c("s19a", "s19b", "s26a", "s26c") else
    if (year == 2020) c("s16", "s17") else c("s20a_preg", "s20b", "s26a", "s26c"))
  if (year %in% c(2017, 2024)) {
    d <- readRDS(acc_data(sprintf("_casen/casen_%d_eca.rds.tar.xz.enc", year)))
    stopifnot(all(vars %in% names(d)))
    d <- d[, names(d) %in% vars]
  } else {
    z <- acc_data(file.path("_casen", paste0(files[[as.character(year)]], ".tar.xz.enc")))
    inside <- utils::unzip(z, list = TRUE)$Name
    inside <- inside[grepl("[.]dta$", inside, ignore.case = TRUE)]
    stopifnot(length(inside) == 1, !grepl("(^/|[.][.])", inside))
    dest <- file.path(tempdir(), paste0("eca_casen_", year))
    f <- file.path(dest, inside)
    if (!file.exists(f)) utils::unzip(z, files = inside, exdir = dest)
    d <- haven::read_dta(f, col_select = dplyr::all_of(vars), encoding = if (year == 2020) "UTF-8" else NULL)
  }
  if (rural) names(d)[names(d) == "area"] <- "zona"
  d
}

eca_casen_targets <- function() {
  .t0 <- Sys.time()
  # Reuse only the audited harmonisation functions; do not execute the old script's local paths or writes.
  rules <- new.env(parent = baseenv())
  expressions <- parse(file.path(acc_root(), "__andres_control", "casen_educ3_insumo.R"))
  for (e in expressions) if (is.call(e) && identical(e[[1]], as.name("<-")) && as.character(e[[2]]) %in% c("num", "e3", "ref3")) eval(e, rules)
  stopifnot(all(vapply(c("num", "e3", "ref3"), exists, logical(1), envir = rules, inherits = FALSE)))
  old <- options(survey.lonely.psu = "adjust", survey.adjust.domain.lonely = TRUE)
  on.exit(options(old), add = TRUE)
  targets <- validation <- ages <- list()
  for (y in c(2013, 2015, 2017, 2020, 2022, 2024)) {
    d <- eca_casen_read(y)
    d$educ3 <- rules$e3(d, y); reference <- rules$ref3(d, y)
    for (v in c("edad", "sexo", "expr", "varstrat", "varunit")) d[[v]] <- eca_num(d[[v]])
    stopifnot(all(is.finite(d$expr)), all(d$expr > 0), !anyNA(d$varstrat), !anyNA(d$varunit))
    eligible <- !is.na(d$edad) & d$edad >= 15 & d$edad <= 65 & d$sexo %in% 1:2
    compare <- eligible & !is.na(d$educ3) & !is.na(reference)
    validation[[as.character(y)]] <- data.frame(anio = y, n = sum(eligible),
      pct_missing = 100 * mean(is.na(d$educ3[eligible])), agreement_pct = 100 * mean(d$educ3[compare] == reference[compare]),
      population_15_65 = sum(d$expr[eligible]))
    d$ag <- eca_age(d$edad)
    for (k in 1:3) d[[paste0("e", k)]] <- as.numeric(d$educ3 == k)
    design <- survey::svydesign(ids = ~varunit, strata = ~varstrat, weights = ~expr, data = d, nest = TRUE)
    domain <- subset(design, edad >= 15 & edad <= 65 & sexo %in% 1:2 & !is.na(educ3))
    g <- as.data.frame(survey::svyby(~e1 + e2 + e3, ~sexo + ag, domain, survey::svymean, vartype = "se"))
    pop <- d[eligible, ] |> dplyr::group_by(sexo, ag) |>
      dplyr::summarise(population = sum(expr), .groups = "drop") |> dplyr::mutate(p_sexo_edad = population / sum(population))
    g <- dplyr::left_join(g, pop, by = c("sexo", "ag")); g$anio_casen <- y
    targets[[as.character(y)]] <- g
    a <- d[eligible & !is.na(d$educ3), ] |> dplyr::group_by(sexo, edad) |>
      dplyr::summarise(n = dplyr::n(), neff_kish = sum(expr)^2 / sum(expr^2),
        e1 = stats::weighted.mean(e1, expr), e2 = stats::weighted.mean(e2, expr),
        e3 = stats::weighted.mean(e3, expr), .groups = "drop")
    a$anio_casen <- y; ages[[as.character(y)]] <- a
    message("CASEN targets verified: ", y)
  }
  targets <- dplyr::bind_rows(targets)
  ages <- dplyr::bind_rows(ages) |> dplyr::arrange(anio_casen, sexo, edad) |>
    dplyr::group_by(anio_casen, sexo) |>
    dplyr::mutate(dplyr::across(c(e1, e2, e3), ~rowMeans(cbind(dplyr::lag(.x), .x, dplyr::lead(.x)), na.rm = TRUE), .names = "{.col}_smooth")) |>
    dplyr::ungroup()
  stopifnot(nrow(ages) == 6 * 2 * 51)
  map <- data.frame(anio = seq(2012, 2024, 2), a = c(2013, 2013, 2015, 2017, 2020, 2022, 2024),
    b = c(2013, 2015, 2017, 2020, 2020, 2022, 2024), wb = c(0, .5, .5, 1 / 3, 0, 0, 0))
  interpolated <- lapply(seq_len(nrow(map)), function(i) {
    a <- targets[targets$anio_casen == map$a[i], ]; b <- targets[targets$anio_casen == map$b[i], ]
    b <- b[match(paste(a$sexo, a$ag), paste(b$sexo, b$ag)), ]
    z <- a[c("sexo", "ag")]; z$anio <- map$anio[i]
    for (k in c("e1", "e2", "e3", "p_sexo_edad")) z[[k]] <- (1 - map$wb[i]) * a[[k]] + map$wb[i] * b[[k]]
    z
  }) |> dplyr::bind_rows()
  age_targets <- lapply(seq_len(nrow(map)), function(i) {
    a <- ages[ages$anio_casen == map$a[i], ]; b <- ages[ages$anio_casen == map$b[i], ]
    b <- b[match(paste(a$sexo, a$edad), paste(b$sexo, b$edad)), ]
    z <- a[c("sexo", "edad")]; z$anio <- map$anio[i]
    for (k in c("e1", "e2", "e3")) z[[k]] <- (1 - map$wb[i]) * a[[paste0(k, "_smooth")]] + map$wb[i] * b[[paste0(k, "_smooth")]]
    z
  }) |> dplyr::bind_rows()
  stopifnot(nrow(age_targets) == 714, all(abs(rowSums(age_targets[c("e1", "e2", "e3")]) - 1) < 1e-10))
  stopifnot(nrow(interpolated) == 56, all(abs(rowSums(interpolated[c("e1", "e2", "e3")]) - 1) < 1e-10))
  legacy <- utils::read.csv(file.path(acc_root(), "__andres_control", "insumo_educ3_sexo_tramo_anio_enpg.csv"))
  j <- match(paste(interpolated$anio, interpolated$sexo, interpolated$ag), paste(legacy$anio_enpg, legacy$sexo, legacy$ag))
  stopifnot(!anyNA(j))
  check <- data.frame(max_abs_difference_existing = max(abs(as.matrix(interpolated[c("e1", "e2", "e3")]) - as.matrix(legacy[j, c("e1", "e2", "e3")]))))
  comparison <- interpolated[c("anio", "sexo", "ag")]
  for (k in c("e1", "e2", "e3")) comparison[[paste0(k, "_difference_pp")]] <- 100 * (interpolated[[k]] - legacy[[k]][j])
  eca_write(comparison, "casen_existing_targets_differences")
  eca_write(targets, "casen_targets_by_round"); eca_write(interpolated, "casen_targets_enpg_years")
  eca_write(ages, "casen_single_age_rounds"); eca_write(age_targets, "casen_single_age_targets_enpg_years")
  eca_write(map, "casen_year_interpolation"); eca_write(dplyr::bind_rows(validation), "casen_education_validation")
  eca_write(check, "casen_existing_targets_check")
  print(dplyr::bind_rows(validation)); print(check)
  message(sprintf("Elapsed: %.2f min", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
  invisible(interpolated)
}

eca_national_weights <- function() {
  .t0 <- Sys.time()
  d <- readRDS(acc_data("__andres_control/enpg_casen_aps_outputs/enpg_poststrat_educ3.rds.tar.xz.enc"))
  targets <- utils::read.csv(file.path(eca_dir, "casen_targets_enpg_years.csv"))
  groups <- d |> dplyr::group_by(anio, sexo, ag) |> dplyr::summarise(w = sum(peso), .groups = "drop") |>
    dplyr::group_by(anio) |> dplyr::mutate(p_enpg_sexo_edad = w / sum(w)) |> dplyr::ungroup()
  groups <- dplyr::left_join(groups, targets[c("anio", "sexo", "ag", "p_sexo_edad")], by = c("anio", "sexo", "ag"))
  groups$factor_sexo_edad <- groups$p_sexo_edad / groups$p_enpg_sexo_edad
  stopifnot(nrow(groups) == 56, all(is.finite(groups$factor_sexo_edad)), all(groups$factor_sexo_edad > 0))
  d <- dplyr::left_join(d, groups[c("anio", "sexo", "ag", "factor_sexo_edad")], by = c("anio", "sexo", "ag"))
  d$peso_nacional <- d$peso_educ * d$factor_sexo_edad
  check <- d |> dplyr::group_by(anio, sexo, ag) |> dplyr::summarise(w = sum(peso_nacional), .groups = "drop") |>
    dplyr::group_by(anio) |> dplyr::mutate(p = w / sum(w)) |> dplyr::ungroup() |>
    dplyr::left_join(targets[c("anio", "sexo", "ag", "p_sexo_edad")], by = c("anio", "sexo", "ag"))
  stopifnot(all(abs(check$p - check$p_sexo_edad) < 1e-10))
  total_check <- d |> dplyr::group_by(anio) |> dplyr::summarise(before = sum(peso), after = sum(peso_nacional), .groups = "drop")
  stopifnot(all(abs(total_check$after / total_check$before - 1) < 1e-10))
  estimates <- lapply(c("current_30d", "current_12m"), function(outcome) {
    d |> dplyr::group_by(anio) |> dplyr::summarise(outcome = outcome,
      p_original = stats::weighted.mean(.data[[outcome]], peso, na.rm = TRUE),
      p_educ = stats::weighted.mean(.data[[outcome]], peso_educ, na.rm = TRUE),
      p_nacional = stats::weighted.mean(.data[[outcome]], peso_nacional, na.rm = TRUE), .groups = "drop") |>
      dplyr::mutate(change_national_pp = 100 * (p_nacional - p_original))
  }) |> dplyr::bind_rows()
  eca_write(groups, "enpg_factors_sexo_edad"); eca_write(check, "enpg_national_target_checks")
  eca_write(total_check, "enpg_national_total_checks"); eca_write(estimates, "enpg_consumption_comparison")
  diagnostics <- d |> dplyr::group_by(anio) |> dplyr::summarise(n = dplyr::n(),
    min_factor = min(peso_nacional / peso), max_factor = max(peso_nacional / peso),
    neff_original = sum(peso)^2 / sum(peso^2), neff_nacional = sum(peso_nacional)^2 / sum(peso_nacional^2), .groups = "drop")
  eca_write(diagnostics, "enpg_national_weight_diagnostics")
  tmp <- file.path(tempdir(), "enpg_poststrat_nacional.rds"); saveRDS(d, tmp)
  acc_pack(tmp, file.path(eca_dir, "enpg_poststrat_nacional.rds.tar.xz.enc"))
  stopifnot(identical(d, readRDS(acc_data("__andres_control/enpg_casen_aps_outputs/enpg_poststrat_nacional.rds.tar.xz.enc"))))
  print(estimates)
  message(sprintf("Elapsed: %.2f min", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
  invisible(d)
}

eca_health_summary <- function(d, outcome, keys, weight) {
  d$x <- d[[outcome]]; d$analysis_weight <- d[[weight]]
  d$weight_available <- is.finite(d$analysis_weight) & d$analysis_weight > 0
  if (weight != "expc") stopifnot(all(d$weight_available))
  # Excluded domains contribute zero; placeholder only retains full-sample PSU structure.
  d$analysis_weight[!d$weight_available] <- 1
  stopifnot(all(is.finite(d$analysis_weight)), all(d$analysis_weight > 0),
    !anyNA(d$varstrat), !anyNA(d$varunit))
  des <- survey::svydesign(ids = ~varunit, strata = ~varstrat, weights = ~analysis_weight, data = d, nest = TRUE)
  des <- subset(des, edad >= 15 & edad <= 64 & sexo %in% 1:2 & weight_available)
  tab <- as.data.frame(survey::svyby(~x, stats::reformulate(keys), des, survey::svymean, na.rm = TRUE, vartype = "se", keep.names = FALSE))
  names(tab)[names(tab) == "x"] <- "p"; names(tab)[names(tab) == "se"] <- "se"
  counts <- d |> dplyr::filter(edad >= 15, edad <= 64, sexo %in% 1:2, weight_available) |>
    dplyr::group_by(dplyr::across(dplyr::all_of(keys))) |>
    dplyr::summarise(n_total = dplyr::n(), n_valid = sum(!is.na(x)), events = sum(x == 1, na.rm = TRUE),
      weighted_population = sum(analysis_weight), weighted_valid = sum(analysis_weight[!is.na(x)]),
      weighted_events = sum(analysis_weight * x, na.rm = TRUE),
      neff_kish = sum(analysis_weight[!is.na(x)])^2 / sum(analysis_weight[!is.na(x)]^2),
      n_psu = dplyr::n_distinct(paste(varstrat[!is.na(x)], varunit[!is.na(x)])), .groups = "drop")
  tab <- dplyr::left_join(counts, tab, by = keys)
  stopifnot(all(abs(tab$p - tab$weighted_events / tab$weighted_valid) < 1e-8, na.rm = TRUE))
  tab$missing_weight_share <- 1 - tab$weighted_valid / tab$weighted_population
  tab$cv <- ifelse(tab$p > 0, tab$se / tab$p, NA_real_)
  interior <- !is.na(tab$p) & tab$p > 0 & tab$p < 1 & is.finite(tab$se)
  tab$lo95 <- tab$hi95 <- NA_real_
  eta <- stats::qlogis(tab$p[interior]); se_eta <- tab$se[interior] / (tab$p[interior] * (1 - tab$p[interior]))
  tab$lo95[interior] <- stats::plogis(eta - stats::qnorm(.975) * se_eta)
  tab$hi95[interior] <- stats::plogis(eta + stats::qnorm(.975) * se_eta)
  tab$passes_screen <- with(tab, n_valid >= 60 & neff_kish >= 30 & events >= 5 & n_valid - events >= 5 & n_psu >= 2 & cv <= .30 & missing_weight_share <= .10)
  tab$passes_screen[is.na(tab$passes_screen)] <- FALSE
  tab$outcome <- outcome; tab$weight <- weight
  tab
}

eca_health_presence <- function(n, place, yes_codes, valid_codes, count = TRUE) {
  # Nonresponse counts/places remain missing; explicit non-use is zero.
  no <- if (count) n == 0 else n == 2
  used <- if (count) n > 0 & n < 99 else n == 1
  dplyr::case_when(no ~ 0, used & place %in% yes_codes ~ 1,
    used & place %in% setdiff(valid_codes, yes_codes) ~ 0, TRUE ~ NA_real_)
}

eca_illness_contact <- function(illness, consultation) {
  dplyr::case_when(illness == 2 ~ 0, illness == 1 & consultation == 1 ~ 1,
    illness == 1 & consultation == 2 ~ 0, TRUE ~ NA_real_)
}

eca_health_round <- function(y) {
  .t0 <- Sys.time()
  old <- options(survey.lonely.psu = "adjust", survey.adjust.domain.lonely = TRUE)
  on.exit(options(old), add = TRUE)
  d <- eca_casen_read(y, health = TRUE)
  dictionary <- lapply(names(d), function(k) data.frame(anio = y, variable = k,
    label = paste(attr(d[[k]], "label"), collapse = ""),
    codes = paste(names(attr(d[[k]], "labels")), attr(d[[k]], "labels"), sep = "=", collapse = "; ")))
  geo_path <- if (y == 2024) "_casen/casen_2024_provincia_comuna.dta.tar.xz.enc" else sprintf("_casen/casen_%d_geography.dta.tar.xz.enc", y)
  geo <- haven::read_dta(acc_data(geo_path))
  keys <- c("folio", if (y <= 2017) "o" else "id_persona")
  stopifnot(!anyDuplicated(d[keys]), !anyDuplicated(geo[keys]))
  n0 <- nrow(d)
  d <- dplyr::left_join(d[setdiff(names(d), c("comuna", "expc"))], geo[c(keys, "comuna", "expc")], by = keys)
  stopifnot(nrow(d) == n0, !anyNA(d$comuna))
  territory <- unique(as.data.frame(data.table::fread(file.path(eca_dir, "ine_sexo_edad_comuna_2012_2024.csv"), encoding = "UTF-8"))[c("region", "comuna", "nombre")])
  codes <- eca_num(d$comuna); unmatched <- setdiff(unique(codes), territory$comuna)
  crosswalk <- data.frame(source_comuna = numeric(), comuna = numeric(), name = character())
  if (length(unmatched)) {
    labels <- attr(geo$comuna, "labels")
    norm <- function(x) gsub("[^A-Z0-9]", "", toupper(iconv(x, to = "ASCII//TRANSLIT")))
    names_old <- names(labels)[match(unmatched, as.numeric(labels))]
    stopifnot(!anyNA(names_old), !anyDuplicated(norm(territory$nombre)))
    j <- match(norm(names_old), norm(territory$nombre))
    if (anyNA(j)) stop("Unmatched commune labels: ", paste(names_old[is.na(j)], collapse = "; "))
    crosswalk <- data.frame(source_comuna = unmatched, comuna = territory$comuna[j], name = names_old)
    for (i in seq_len(nrow(crosswalk))) codes[codes == crosswalk$source_comuna[i]] <- crosswalk$comuna[i]
  }
  for (k in names(d)) d[[k]] <- eca_num(d[[k]])
  d$comuna <- codes
  # Fixed current commune geography, without changing survey strata or PSUs.
  d$region <- territory$region[match(d$comuna, territory$comuna)]
  stopifnot(!anyNA(d$region))
  d$ag <- as.character(cut(d$edad, c(14, 29, 44, 59, 64), labels = c("15-29", "30-44", "45-59", "60-64")))
  if (y <= 2017) {
    general_n <- d[[if (y == 2013) "s22a" else "s19a"]]
    general_place <- d[[if (y == 2013) "s22b" else "s19b"]]
    control_n <- d[[if (y == 2013) "s29a" else "s26a"]]
    control_place <- d[[if (y == 2013) "s29c" else "s26c"]]
    valid <- if (y == 2013) 1:14 else 1:15
    d$public_general_3m <- eca_health_presence(general_n, general_place, 1:7, valid)
    d$public_control_3m <- eca_health_presence(control_n, control_place, 1:7, valid)
    g <- eca_health_presence(general_n, general_place, 1:2, valid)
    c <- eca_health_presence(control_n, control_place, 1:2, valid)
    d$aps_general_or_control_3m <- dplyr::case_when(g == 1 | c == 1 ~ 1, g == 0 & c == 0 ~ 0, TRUE ~ NA_real_)
    outcomes <- c("public_general_3m", "public_control_3m", "aps_general_or_control_3m")
  } else if (y == 2020) {
    stopifnot(!any(c("s19a", "s20a_preg", "s20b", "s26a") %in% names(d)))
    d$illness_consultation_3m <- eca_illness_contact(d$s16, d$s17)
    outcomes <- "illness_consultation_3m"
  } else {
    d$public_general_3m <- eca_health_presence(d$s20a_preg, d$s20b, 1, 1:3, count = FALSE)
    # In recent rounds negative labelled values denote unknown counts.
    d$public_control_12m <- dplyr::case_when(d$s26a == 0 ~ 0, d$s26a > 0 & d$s26c == 1 ~ 1,
      d$s26a > 0 & d$s26c %in% 2:3 ~ 0, TRUE ~ NA_real_)
    outcomes <- c("public_general_3m", "public_control_12m")
  }
  results <- list(); warnings <- character()
  for (outcome in outcomes) for (level in c("national", "region", "comuna")) {
    tab <- withCallingHandlers(eca_health_summary(d, outcome, c(if (level != "national") level, "sexo", "ag"),
      if (level == "comuna") "expc" else "expr"), warning = function(w) {
        warnings <<- c(warnings, conditionMessage(w)); invokeRestart("muffleWarning")
      })
    tab$anio_casen <- y; tab$geography <- level
    tab$reference_months <- if (grepl("12m$", outcome)) 12L else 3L
    results[[paste(outcome, level)]] <- tab
    message("Health domain completed: ", y, " / ", outcome, " / ", level)
  }
  result <- dplyr::bind_rows(results)
  eca_write(result, paste0("casen_health_domains_", y))
  eca_write(dplyr::bind_rows(dictionary), paste0("casen_health_dictionary_", y))
  eca_write(as.data.frame(table(warnings)), paste0("casen_health_warnings_", y))
  eca_write(crosswalk, paste0("casen_health_geography_crosswalk_", y))
  eca_write(data.frame(anio = y, rows_before = n0, rows_after = nrow(d), unmatched = 0,
    duplicated_keys = 0, missing_commune_weight = sum(is.na(d$expc)),
    communes_with_weight = dplyr::n_distinct(d$comuna[!is.na(d$expc)]),
    source = geo_path, commune_weight = "expc", commune_weight_label = attr(geo$expc, "label"),
    fixed_geography = "INE commune geography; official survey strata/PSUs unchanged"), paste0("casen_health_join_audit_", y))
  message(sprintf("Elapsed: %.2f min", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
  invisible(result)
}

eca_health_series <- function() {
  .t0 <- Sys.time()
  years <- c(2013, 2015, 2017, 2020, 2022, 2024)
  read <- function(prefix, y) utils::read.csv(file.path(eca_dir, paste0(prefix, y, ".csv")), encoding = "UTF-8")
  res <- dplyr::bind_rows(lapply(years, function(y) read("casen_health_domains_", y)))
  dict <- dplyr::bind_rows(lapply(years, function(y) read("casen_health_dictionary_", y)))
  stopifnot(setequal(unique(res$anio_casen), years))
  eca_write(res, "casen_health_domains"); eca_write(dict, "casen_health_dictionary")
  # This is a temporal scenario, never an observed 2018/2020 public-care estimate.
  map <- data.frame(anio = seq(2012, 2024, 2), a = c(2013, 2013, 2015, 2017, 2017, 2022, 2024),
    b = c(2013, 2015, 2017, 2022, 2022, 2022, 2024), wb = c(0, .5, .5, .2, .6, 0, 0),
    method = c("Proxy CASEN 2013 (no CASEN 2012)", "Interpolation CASEN 2013/2015", "Interpolation CASEN 2015/2017",
      "Scenario interpolating 2017/2022; crosses pandemic", "Unobserved in CASEN 2020; scenario interpolating 2017/2022",
      "Observed CASEN 2022", "Observed CASEN 2024"))
  pop <- as.data.frame(data.table::fread(file.path(eca_dir, "ine_sexo_edad_comuna_2012_2024.csv"), encoding = "UTF-8"))
  one <- function(y, level, outcome) res[res$anio_casen == y & res$geography == level & res$outcome == outcome, ]
  result <- lapply(seq_len(nrow(map)), function(i) {
    m <- map[i, ]; d <- pop[pop$anio == m$anio, ]
    for (level in c("region", "comuna")) {
      keys <- c(level, "sexo", "ag")
      a <- one(m$a, level, "public_general_3m"); b <- one(m$b, level, "public_general_3m")
      key <- function(x) do.call(paste, x[keys])
      ja <- match(key(d), key(a)); jb <- match(key(d), key(b))
      tag <- if (level == "region") "region" else "commune"
      d[[paste0("p_scenario_", tag)]] <- (1 - m$wb) * a$p[ja] + m$wb * b$p[jb]
      d[[paste0("n_source_a_", tag)]] <- a$n_valid[ja]; d[[paste0("n_source_b_", tag)]] <- b$n_valid[jb]
      d[[paste0("source_cells_pass_", tag)]] <- a$passes_screen[ja] & b$passes_screen[jb]
      # No interpolated design CI: covariance across rounds and temporal model error are unestimated.
      d[[paste0("p_observed_", tag)]] <- if (m$anio == m$a && m$a == m$b) a$p[ja] else NA_real_
    }
    d$source_a <- m$a; d$source_b <- m$b; d$weight_b <- m$wb; d$method <- m$method
    d$p_aps_3m <- NA_real_
    # APS identification only exists in the old questionnaire; do not extrapolate it into 2022/2024.
    if (m$b <= 2017) {
      a <- one(m$a, "region", "aps_general_or_control_3m"); b <- one(m$b, "region", "aps_general_or_control_3m")
      ka <- paste(a$region, a$sexo, a$ag); kb <- paste(b$region, b$sexo, b$ag); kd <- paste(d$region, d$sexo, d$ag)
      d$p_aps_3m <- (1 - m$wb) * a$p[match(kd, ka)] + m$wb * b$p[match(kd, kb)]
    }
    d$aps_status <- if (m$b <= 2017) "Historical regional temporal scenario: consultorio/posta general-or-control" else "Not identified by a comparable contemporary APS question"
    d$regional_assumption <- "Regional sex-age rate assigned to commune; does not estimate within-region variation"
    d
  }) |> dplyr::bind_rows()
  stopifnot(nrow(result) == 19376, !anyDuplicated(result[c("anio", "comuna", "sexo", "ag")]),
    all(is.finite(result$p_scenario_region)), all(result$p_scenario_region >= 0 & result$p_scenario_region <= 1),
    all(is.na(result$p_observed_region[result$anio < 2022])), all(is.na(result$p_aps_3m[result$anio >= 2018])))
  coverage <- expand.grid(anio_casen = years, outcome = c("public_general_3m", "public_control_3m", "public_control_12m", "aps_general_or_control_3m", "illness_consultation_3m"))
  coverage$available <- vapply(seq_len(nrow(coverage)), function(i) any(res$anio_casen == coverage$anio_casen[i] & res$outcome == coverage$outcome[i]), logical(1))
  stopifnot(setequal(coverage$anio_casen[coverage$available & coverage$outcome == "public_general_3m"], c(2013, 2015, 2017, 2022, 2024)),
    setequal(coverage$anio_casen[coverage$available & coverage$outcome == "aps_general_or_control_3m"], c(2013, 2015, 2017)))
  eca_write(coverage, "casen_health_indicator_availability")
  eca_write(map, "health_year_alignment")
  eca_write(result, "insumo_contacto_comuna_anios_enpg")
  print(res |> dplyr::group_by(anio_casen, geography, outcome) |> dplyr::summarise(cells = dplyr::n(), pass = sum(passes_screen), .groups = "drop"))
  message(sprintf("Elapsed: %.2f min", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
  invisible(result)
}

eca_health <- function() {
  .t0 <- Sys.time()
  for (y in c(2013, 2015, 2017, 2020, 2022, 2024)) eca_health_round(y)
  result <- eca_health_series()
  message(sprintf("Elapsed: %.2f min", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
  invisible(result)
}

eca_eps_audit <- function() {
  .t0 <- Sys.time()
  old_scr <- Sys.getenv("SCR", unset = NA_character_)
  on.exit(if (is.na(old_scr)) Sys.unsetenv("SCR") else Sys.setenv(SCR = old_scr), add = TRUE)
  Sys.setenv(SCR = tempdir())
  env <- new.env(parent = globalenv())
  invisible(utils::capture.output(sys.source(file.path(acc_root(), "__andres_control", "eps_reid_casen_aps.R"), envir = env)))
  stopifnot(exists("S", env, inherits = FALSE), exists("A", env, inherits = FALSE))
  candidates <- env$S; assigned <- env$A
  assigned$status <- "Heuristic ecological candidate; not confirmed residence or individual rurality"
  names(assigned)[names(assigned) == "conf"] <- "heuristic_label_not_probability"
  eca_write(candidates, "eps_all_comuna_candidates"); eca_write(assigned, "eps_heuristic_assignment_audit")
  eca_write(data.frame(source = "__andres_control/eps_reid_casen_aps.R",
    md5 = unname(tools::md5sum(file.path(acc_root(), "__andres_control", "eps_reid_casen_aps.R"))),
    adaptation = "Original discovery fails on current VIII labels; explicitly select respondent a8/a9",
    candidates = nrow(candidates), assignments = nrow(assigned),
    negative_margins = sum(assigned$margin < 0), use_for_base_weights = FALSE), "eps_script_audit")
  historical <- utils::read.csv(file.path(acc_root(), "__andres_control", "rg_T1_ratios.csv"))
  historical <- historical[historical$waves == "VIII" & historical$exposure == "rural_asg" & historical$region_FE, ]
  historical$models_reexecuted <- FALSE
  historical$role <- "Historical ecological sensitivity only; not a transport factor"
  eca_write(historical, "eps_rural_historical_reference")
  print(data.frame(candidates = nrow(candidates), assignments = nrow(assigned), negative_margins = sum(assigned$margin < 0)))
  message(sprintf("Elapsed: %.2f min", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
  invisible(assigned)
}

eca_tests <- function() {
  .t0 <- Sys.time()
  stopifnot(identical(eca_illness_contact(c(2, 1, 1, 1, 9, NA), c(NA, 1, 2, 9, 1, NA)),
    c(0, 1, 0, NA_real_, NA_real_, NA_real_)))
  stopifnot(identical(eca_health_presence(c(0, 1, 2, 99, NA, 1), c(NA, 1, 8, 1, 1, 99), 1:7, 1:15),
    c(0, 1, 0, NA_real_, NA_real_, NA_real_)),
    identical(eca_health_presence(c(2, 1, 1, -88), c(NA, 1, 2, 1), 1, 1:3, count = FALSE),
      c(0, 1, 0, NA_real_)))
  stopifnot(identical(eca_educ(c(4, 6, 6, 9, 9, 12, 88, 6), c(77, 1, 2, 1, 2, 2, 1, 99)),
    c(1L, 2L, 1L, 3L, 2L, 3L, NA_integer_, NA_integer_)))
  x <- data.frame(anio = 2024, sexo = 1, ag = "30-44", educ3 = c(1L, 2L, 3L, NA_integer_), peso = c(2, 3, 5, 7))
  t <- data.frame(anio = 2024, sexo = 1, ag = "30-44", educ3 = 1:3, p_casen = c(.3, .3, .4))
  z <- eca_poststrat(x, t)
  stopifnot(max(abs(z$data$peso_educ - c(3, 3, 4, 7))) < 1e-10,
    inherits(try(eca_poststrat(x[x$educ3 %in% c(1, 2), ], t), silent = TRUE), "try-error"),
    inherits(try(eca_poststrat(x, rbind(t, t[1, ])), silent = TRUE), "try-error"))
  cat("PASS: education, missing completion, missing education, totals, duplicate targets, unsupported cells\n")
  message(sprintf("Elapsed: %.2f min", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
}
message(sprintf("Elapsed: %.2f min", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
