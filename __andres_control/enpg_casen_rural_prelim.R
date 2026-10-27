.t0 <- Sys.time()
# Preliminary composition contrast; no rural outcome effect is identified here.
source(here::here('__andres_control', 'enpg_casen_aps.R'))

eca_who <- function(g, sex, current) {
  lo <- ifelse(sex == 2, 20, 40); hi <- ifelse(sex == 2, 40, 60)
  dplyr::case_when(current == 0 ~ 'NC', current == 1 & is.finite(g) & g > 0 & g <= lo ~ 'C1',
    current == 1 & is.finite(g) & g > lo & g <= hi ~ 'C2',
    current == 1 & is.finite(g) & g > hi ~ 'C3plus', TRUE ~ NA_character_)
}

eca_history <- function(ever, current, binge) {
  # A positive binge response contradicting non-current status is unknown, not zero.
  binge[binge >= 88 | binge < 0] <- NA_real_
  data.frame(lifetime = dplyr::case_when(ever == 'No' ~ 1, ever == 'Si' ~ 0, TRUE ~ NA_real_),
    hed = dplyr::case_when(current == 0 & (is.na(binge) | binge == 0) ~ 0,
      current == 1 & !is.na(binge) ~ as.numeric(binge > 0), TRUE ~ NA_real_))
}

eca_rural_targets <- function() {
  .t0 <- Sys.time()
  rules <- new.env(parent = baseenv())
  for (e in parse(here::here('__andres_control', 'casen_educ3_insumo.R'))) {
    if (is.call(e) && identical(e[[1]], as.name('<-')) && as.character(e[[2]]) %in% c('num', 'e3')) eval(e, rules)
  }
  rounds <- dict <- list()
  for (year in c(2013, 2015, 2017, 2020, 2022, 2024)) {
    d <- eca_casen_read(year, rural = TRUE)
    dict[[as.character(year)]] <- data.frame(anio = year, variable = if (year <= 2015) 'zona' else 'area', label = attr(d$zona, 'label'),
      codes = paste(names(attr(d$zona, 'labels')), attr(d$zona, 'labels'), collapse = '; '))
    d$educ3 <- rules$e3(d, year)
    for (k in c('edad', 'sexo', 'expr', 'zona')) d[[k]] <- eca_num(d[[k]])
    stopifnot(all(d$zona %in% 1:2), all(d$expr > 0))
    d$ag <- eca_age(d$edad)
    rounds[[as.character(year)]] <- d |> dplyr::filter(!is.na(ag), sexo %in% 1:2, !is.na(educ3)) |>
      dplyr::group_by(sexo, ag, educ3) |>
      dplyr::summarise(n_urban = sum(zona == 1), n_rural = sum(zona == 2),
        rural_share = sum(expr[zona == 2]) / sum(expr), .groups = 'drop') |>
      dplyr::mutate(anio_casen = year)
    message('Rural composition completed: CASEN ', year)
  }
  rounds <- dplyr::bind_rows(rounds)
  eca_write(rounds, 'rural_casen_by_round'); eca_write(dplyr::bind_rows(dict), 'rural_casen_dictionary')
  map <- utils::read.csv(file.path(eca_dir, 'casen_year_interpolation.csv'))
  t <- utils::read.csv(file.path(eca_dir, 'casen_targets_enpg_years.csv')) |>
    tidyr::pivot_longer(c(e1, e2, e3), names_to = 'educ3', values_to = 'p_educ') |>
    dplyr::mutate(educ3 = as.integer(sub('e', '', educ3)), q_national = p_sexo_edad * p_educ)
  out <- lapply(seq_len(nrow(map)), function(i) {
    m <- map[i, ]; z <- t[t$anio == m$anio, ]
    a <- rounds[rounds$anio_casen == m$a, ]; b <- rounds[rounds$anio_casen == m$b, ]
    key <- function(x) paste(x$sexo, x$ag, x$educ3)
    a <- a[match(key(z), key(a)), ]; b <- b[match(key(z), key(b)), ]
    z$rural_share <- (1 - m$wb) * a$rural_share + m$wb * b$rural_share
    z$q_urban <- z$q_national * (1 - z$rural_share); z$q_urban <- z$q_urban / sum(z$q_urban)
    z$q_rural <- z$q_national * z$rural_share; z$q_rural <- z$q_rural / sum(z$q_rural)
    z$source_a <- m$a; z$source_b <- m$b; z$weight_b <- m$wb
    z$n_rural_a <- a$n_rural; z$n_rural_b <- b$n_rural
    stopifnot(all(is.finite(z$rural_share)), abs(sum(z$q_national) - 1) < 1e-8,
      all(z$q_urban > 0), all(z$q_rural > 0))
    z
  }) |> dplyr::bind_rows()
  eca_write(out, 'rural_composition_targets')
  message(sprintf('Elapsed: %.2f min', as.numeric(difftime(Sys.time(), .t0, units = 'mins'))))
  invisible(out)
}

eca_rural_enpg <- function() {
  .t0 <- Sys.time()
  w <- readRDS(acc_data('__andres_control/enpg_casen_aps_outputs/enpg_poststrat_nacional.rds.tar.xz.enc'))
  b <- readRDS(acc_data('_enpg/enpg.tar.xz.enc', 'derived/ENPG_BINGE.RDS'))
  key <- paste(b$year, as.character(b$id)); j <- match(paste(w$anio, w$id), key)
  stopifnot(!anyDuplicated(key), !anyNA(j), all(w$edad == b$edad[j]), all(w$sexo == as.integer(b$sexo[j])))
  b <- b[j, ]; days <- eca_num(b$oh3); days[days %in% c(88, 99)] <- NA_real_
  db <- eca_num(b$db); db[db >= 88] <- NA_real_
  history <- eca_history(as.character(b$oh1), w$current_30d, db)
  w$lifetime <- history$lifetime; w$hed <- history$hed
  stopifnot(!any(w$lifetime == 1 & w$current_30d == 1, na.rm = TRUE))
  q <- unname(c('0-2' = 1, '3-4' = 3.5, '5-6' = 5.5, '7-8' = 7.5, '9 o mas' = 9)[as.character(b$audit2)])
  # Reuse the project's binge-aware 12-g derivation; freeze existing APC factors across reweightings.
  g <- (pmax(days - db, 0) * q + db * ifelse(w$sexo == 1, 5, 4)) * 12 / 30
  g[w$current_30d %in% 0] <- 0
  g[(!w$current_30d %in% c(0, 1)) | (w$current_30d %in% 1 & (days > 30 | !is.finite(g) | g <= 0))] <- NA_real_
  apc <- utils::read.csv(here::here('__andres_control', 'oms_factor_by_year.csv'))
  stopifnot(!anyDuplicated(apc$year), all(is.finite(apc$factor_CH)))
  w$grams_reported <- g; w$grams_anchored <- g * apc$factor_CH[match(w$anio, apc$year)]
  w$class_reported <- eca_who(w$grams_reported, w$sexo, w$current_30d)
  w$class_anchored <- eca_who(w$grams_anchored, w$sexo, w$current_30d)
  audit <- w |> dplyr::group_by(anio) |> dplyr::summarise(n_joined = dplyr::n(),
    n_education_missing = sum(is.na(educ3)), n_current_missing = sum(is.na(current_30d)),
    n_current_volume_missing = sum(current_30d %in% 1 & is.na(grams_reported)),
    n_lifetime_missing = sum(is.na(lifetime)), n_hed_missing = sum(is.na(hed)), .groups = 'drop')
  eca_write(audit, 'rural_enpg_join_audit')
  message(sprintf('Elapsed: %.2f min', as.numeric(difftime(Sys.time(), .t0, units = 'mins'))))
  w
}

eca_rural_preliminary <- function(rebuild_targets = TRUE) {
  .t0 <- Sys.time()
  eca_rural_tests()
  if (rebuild_targets) eca_rural_targets()
  targets <- utils::read.csv(file.path(eca_dir, 'rural_composition_targets.csv'))
  d <- eca_rural_enpg(); rows <- direct_rows <- cells <- balance <- dr <- list()
  for (year in seq(2012, 2024, 2)) {
    whole <- d[d$anio == year, ]; z <- whole[!is.na(whole$educ3), ]; t <- targets[targets$anio == year, ]
    key <- function(x) paste(x$sexo, x$ag, x$educ3)
    z$cell <- match(key(z), key(t)); stopifnot(!anyNA(z$cell))
    ww <- as.numeric(tapply(z$peso, factor(z$cell, levels = seq_len(nrow(t))), sum))
    q0 <- ww / sum(ww); wpost <- z$peso * t$q_national[z$cell] / q0[z$cell]
    stopifnot(all(is.finite(q0)), all(q0 > 0),
      max(abs(as.numeric(tapply(wpost, factor(z$cell, levels = seq_len(nrow(t))), sum)) / sum(wpost) - t$q_national)) < 1e-10)
    for (v in c('sexo', 'ag', 'educ3')) for (level in unique(t[[v]])) {
      i <- t[[v]] == level; p <- sum(t$q_national[i]); before <- sum(q0[i])
      after <- sum(wpost[z[[v]] == level]) / sum(wpost)
      balance[[paste(year, v, level)]] <- data.frame(anio = year, variable = v, level = as.character(level),
        target = p, before = before, after = after, smd_before = (before - p) / sqrt(p * (1 - p)),
        smd_after = (after - p) / sqrt(p * (1 - p)))
    }
    for (scale in c('anchored', 'reported')) for (outcome in c('lifetime', 'current', 'NC', 'C1', 'C2', 'C3plus', 'hed', 'grams')) {
      cl <- whole[[paste0('class_', scale)]]
      all_y <- if (outcome %in% c('lifetime','hed')) whole[[outcome]] else if (outcome == 'current') whole$current_30d else if (outcome == 'grams') whole[[paste0('grams_', scale)]] else as.numeric(cl == outcome)
      y <- all_y[!is.na(whole$educ3)]
      stat <- lapply(seq_len(nrow(t)), function(k) {
        all <- z$cell == k; ok <- all & is.finite(y); w <- z$peso[ok]; yy <- y[ok]
        data.frame(n = sum(ok), events = if (outcome == 'grams') sum(yy > 0) else sum(yy == 1),
          weight = sum(w), weight2 = sum(w^2), m = if (sum(ok)) stats::weighted.mean(yy, w) else NA_real_,
          missing_share = 1 - sum(w) / sum(z$peso[all]))
      }) |> dplyr::bind_rows()
      stat$kish <- with(stat, weight^2 / weight2)
      stopifnot(all(stat$n > 0), all(is.finite(stat$m)))
      stat$screen <- with(stat, n >= 60 & kish >= 30 & events >= 5 &
        (outcome == 'grams' | n - events >= 5) & missing_share <= .10)
      tab <- cbind(t, stat); tab$outcome <- outcome; tab$scale <- scale
      cells[[paste(year, scale, outcome)]] <- tab
      # A cell-constant outcome model plus exact cell calibration reduces algebraically to poststratification.
      mhat <- mean(y, na.rm = TRUE)
      ok <- is.finite(y); q_valid <- stat$weight / sum(stat$weight)
      wcal <- z$peso[ok] / sum(z$peso[ok]) * t$q_national[z$cell[ok]] / q_valid[z$cell[ok]]
      aug <- sum(t$q_national * mhat) + sum(wcal * (y[ok] - mhat))
      direct <- sum(t$q_national * stat$m)
      dr[[paste(year, scale, outcome)]] <- data.frame(anio = year, scale, outcome, poststrat = direct,
        augmented_identity = aug, abs_difference = abs(direct - aug), is_yang_high_dimensional_fit = FALSE)
      for (s in 0:2) for (age in c('All', unique(t$ag))) {
        domain <- (s == 0 | whole$sexo == s) & (age == 'All' | whole$ag == age)
        valid <- domain & is.finite(all_y)
        original <- stats::weighted.mean(all_y[valid], whole$peso[valid])
        national <- stats::weighted.mean(all_y[valid], whole$peso_nacional[valid])
        direct_rows[[paste(year, scale, outcome, s, age)]] <- data.frame(anio = year, scale, outcome, sexo = s, ag = age,
          n = sum(valid), events = sum(all_y[valid] > 0), original, national, change = national - original,
          kish = sum(whole$peso_nacional[valid])^2 / sum(whole$peso_nacional[valid]^2),
          missing_share = 1 - sum(whole$peso[valid]) / sum(whole$peso[domain]))
        idx <- (s == 0 | t$sexo == s) & (age == 'All' | t$ag == age)
        if (!any(idx)) next
        a <- tab[idx, ]; qn <- a$q_national / sum(a$q_national); qu <- a$q_urban / sum(a$q_urban)
        qr <- a$q_rural / sum(a$q_rural); qe <- a$weight / sum(a$weight)
        p0 <- sum(qe * a$m); pu <- sum(qu * a$m); pn <- sum(qn * a$m); pr <- sum(qr * a$m)
        rr <- sum(qn * a$rural_share); gap <- pu - pn
        stopifnot(abs(pn - ((1 - rr) * pu + rr * pr)) < 1e-10)
        rows[[paste(year, scale, outcome, s, age)]] <- data.frame(anio = year, scale, outcome, sexo = s, ag = age,
          n = sum(a$n), events = sum(a$events), kish = sum(a$weight)^2 / sum(a$weight2),
          original = p0, urban = pu, national = pn, rural_composition = pr, rural_share = rr,
          original_minus_national = p0 - pn, rural_composition_gap = gap,
          relative_gap_pct = if (abs(pn) > 1e-12) 100 * gap / pn else NA_real_,
          unsupported_target_share = sum(qn[!a$screen]), min_cell_n = min(a$n),
          min_cell_kish = min(a$kish), all_cells_pass = all(a$screen))
      }
    }
  }
  result <- dplyr::bind_rows(rows); cell <- dplyr::bind_rows(cells); bal <- dplyr::bind_rows(balance); aug <- dplyr::bind_rows(dr)
  direct_result <- dplyr::bind_rows(direct_rows)
  previous <- utils::read.csv(file.path(eca_dir, 'enpg_consumption_comparison.csv'))
  check <- direct_result[direct_result$sexo == 0 & direct_result$ag == 'All' & direct_result$outcome == 'current' & direct_result$scale == 'anchored', ]
  previous <- previous[previous$outcome == 'current_30d', ]; previous <- previous[match(check$anio, previous$anio), ]
  stopifnot(all(abs(check$original - previous$p_original) < 1e-10),
    all(abs(check$national - previous$p_nacional) < 1e-10),
    !anyDuplicated(direct_result[c('anio','scale','outcome','sexo','ag')]))
  stopifnot(all(aug$abs_difference < 1e-10), max(abs(bal$smd_after)) < 1e-10,
    !anyDuplicated(result[c('anio', 'scale', 'outcome', 'sexo', 'ag')]))
  cell <- cell |> dplyr::group_by(anio, scale, outcome, sexo, ag) |>
    dplyr::mutate(p_educ_urban = q_urban / sum(q_urban), p_educ_national = q_national / sum(q_national),
      contribution = (p_educ_urban - p_educ_national) * m) |> dplyr::ungroup()
  sums <- result |> dplyr::filter(outcome %in% c('NC','C1','C2','C3plus')) |>
    dplyr::group_by(anio, scale, sexo, ag) |>
    dplyr::summarise(dplyr::across(c(original, urban, national), sum), .groups = 'drop')
  contributions <- cell |> dplyr::group_by(anio, scale, outcome, sexo, ag) |>
    dplyr::summarise(total = sum(contribution), .groups = 'drop') |>
    dplyr::left_join(result, by = c('anio','scale','outcome','sexo','ag'))
  stopifnot(max(abs(as.matrix(sums[c('original','urban','national')]) - 1)) < 1e-10,
    all(abs(contributions$total - contributions$rural_composition_gap) < 1e-10))
  eca_write(result, 'rural_preliminary_estimates'); eca_write(cell, 'rural_education_contributions')
  eca_write(direct_result, 'enpg_indicators_by_group')
  eca_write(bal, 'rural_balance'); eca_write(aug, 'rural_augmented_identity')
  eca_rural_figures(result, cell, bal)
  message(sprintf('Elapsed: %.2f min', as.numeric(difftime(Sys.time(), .t0, units = 'mins'))))
  invisible(result)
}

eca_rural_figures <- function(result, cells, balance) {
  .t0 <- Sys.time()
  dest <- file.path(eca_dir, 'figures'); dir.create(dest, showWarnings = FALSE)
  save <- function(p, name, height = 7) {
    ggplot2::ggsave(file.path(dest, paste0(name, '.png')), p, width = 11, height = height, dpi = 150, bg = 'white')
    ggplot2::ggsave(file.path(dest, paste0(name, '.pdf')), p, width = 11, height = height, bg = 'white')
  }
  labels <- c('sexo 1' = 'Hombres', 'sexo 2' = 'Mujeres', 'educ3 1' = 'Básica o menos', 'educ3 2' = 'Media', 'educ3 3' = 'Superior')
  balance$label <- paste(balance$variable, balance$level)
  balance$label[balance$label %in% names(labels)] <- labels[balance$label[balance$label %in% names(labels)]]
  balance$label <- sub('ag ', 'Edad ', balance$label)
  b <- tidyr::pivot_longer(balance, c(smd_before, smd_after), names_to = 'stage', values_to = 'smd')
  b$stage <- ifelse(b$stage == 'smd_before', 'Antes', 'Después')
  p <- ggplot2::ggplot(b, ggplot2::aes(abs(smd), label, colour = stage, shape = stage)) + ggplot2::geom_point(size = 2) +
    ggplot2::geom_vline(xintercept = .1, linetype = 2, colour = 'grey65') + ggplot2::facet_wrap(~anio, ncol = 3) +
    ggplot2::scale_colour_manual(values = c(Antes = '#b85c36', Después = '#176854')) + ggplot2::theme_minimal(base_size = 11) +
    ggplot2::labs(title = 'Love plot: balance frente a CASEN nacional', subtitle = 'Educación conocida; línea 0,10 orientativa. Balance no prueba ausencia de sesgo rural.',
      x = '|Diferencia estandarizada| (DE binaria de CASEN)', y = NULL, colour = NULL, shape = NULL)
  save(p, 'loveplot_composition', 10)
  r <- result[result$anio == 2024 & result$sexo > 0 & result$ag != 'All' & result$outcome == 'C3plus', ]
  r$group <- paste(ifelse(r$sexo == 1, 'Hombres', 'Mujeres'), r$ag)
  v <- tidyr::pivot_longer(r, c(original, urban, national), names_to = 'target', values_to = 'p')
  v$target <- factor(v$target, c('original','urban','national'), c('ENPG original','Composición urbana','Composición nacional'))
  p <- ggplot2::ggplot(v, ggplot2::aes(p * 100, group, colour = target, shape = target)) +
    ggplot2::geom_point(size = 2.6, position = ggplot2::position_dodge(width = .45)) +
    ggplot2::facet_wrap(~scale, scales = 'free_x', labeller = ggplot2::as_labeller(c(anchored = 'Volumen anclado APC', reported = 'Volumen reportado, 12 g/trago'))) +
    ggplot2::theme_minimal(base_size = 11) + ggplot2::theme(legend.position = 'bottom') +
    ggplot2::labs(title = 'C3+ en 2024: lo que cambia al reponderar',
      subtitle = 'Estimaciones puntuales; escalas horizontales distintas. Sin intervalos de incertidumbre.',
      x = '% C3+ (>40 g/día mujeres; >60 hombres)', y = NULL, colour = NULL, shape = NULL)
  save(p, 'who_targets_2024', 6)
  r <- result[result$sexo > 0 & result$ag != 'All' & result$outcome == 'C3plus' & result$scale == 'anchored', ]
  r$group <- paste(ifelse(r$sexo == 1, 'Hombres', 'Mujeres'), r$ag)
  p <- ggplot2::ggplot(r, ggplot2::aes(factor(anio), group, fill = 100 * rural_composition_gap)) + ggplot2::geom_tile(colour = 'white') +
    ggplot2::geom_text(ggplot2::aes(label = sprintf('%+.2f', 100 * rural_composition_gap)), size = 3.3) +
    ggplot2::scale_fill_gradient2(low = '#216a83', mid = 'white', high = '#b85c36', midpoint = 0) +
    ggplot2::theme_minimal(base_size = 11) + ggplot2::labs(title = 'C3+ anclado: contraste composicional urbano − nacional',
      subtitle = 'Positivo: sobreestimación composicional; negativo: subestimación. No es el efecto rural residual.',
      x = 'Año ENPG', y = NULL, fill = 'Puntos\nporcentuales')
  save(p, 'rural_composition_heatmap', 6)
  c <- cells[cells$anio == 2024 & cells$outcome == 'C3plus' & cells$scale == 'anchored', ]
  c$group <- paste(ifelse(c$sexo == 1, 'Hombres', 'Mujeres'), c$ag)
  p <- ggplot2::ggplot(c, ggplot2::aes(factor(educ3, 1:3, c('Básica','Media','Superior')), contribution * 100, fill = screen)) +
    ggplot2::geom_col(show.legend = TRUE) + ggplot2::geom_hline(yintercept = 0) + ggplot2::facet_wrap(~group, ncol = 4) +
    ggplot2::scale_fill_manual(values = c('TRUE' = '#176854', 'FALSE' = '#b6b6b6'),
      limits = c('FALSE','TRUE'), labels = c('FALSE' = 'No', 'TRUE' = 'Sí'), drop = FALSE) +
    ggplot2::theme_minimal(base_size = 11) + ggplot2::theme(legend.position = 'bottom') +
    ggplot2::labs(title = 'Qué educación aporta al contraste de C3+ anclado en 2024',
      subtitle = 'Las tres barras suman el contraste del grupo; el filtro de n/eventos es exploratorio.',
      x = NULL, y = 'Aporte en puntos porcentuales', fill = 'Supera filtro')
  save(p, 'education_contributions_2024', 6)
  message(sprintf('Elapsed: %.2f min', as.numeric(difftime(Sys.time(), .t0, units = 'mins'))))
}

eca_rural_tests <- function() {
  .t0 <- Sys.time()
  h <- eca_history(c('No','Si','Si','Si','Si',NA,'Si'), c(0,0,1,1,1,NA,0), c(NA,0,0,2,88,NA,1))
  stopifnot(identical(h$lifetime, c(1,0,0,0,0,NA_real_,0)),
    identical(h$hed, c(0,0,0,1,NA_real_,NA_real_,NA_real_)))
  stopifnot(identical(eca_who(c(0, 20, 20.01, 40, 40.01, 40, 60, 60.01, NA), c(rep(2, 5), rep(1, 4)), c(0, rep(1, 8))),
    c('NC','C1','C2','C2','C3plus','C1','C2','C3plus',NA_character_)))
  # Composition contrast vanishes when outcome means do not differ across educational cells.
  stopifnot(abs(sum((c(.4,.4,.2) - c(.5,.3,.2)) * rep(.3, 3))) < 1e-12)
  message(sprintf('Elapsed: %.2f min', as.numeric(difftime(Sys.time(), .t0, units = 'mins'))))
}
message(sprintf('Elapsed: %.2f min', as.numeric(difftime(Sys.time(), .t0, units = 'mins'))))
