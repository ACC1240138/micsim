.t0 <- Sys.time()
# Read-only inspection of the ELSOC longitudinal weights (structure only: no transition estimates).
# Writes a single plain-text log next to this script; never exports microdata. See WEIGHTING_PLAN.md.
root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
while (!file.exists(file.path(root, ".acc_root")) && dirname(root) != root) root <- dirname(root)
stopifnot(file.exists(file.path(root, ".acc_root")))
source(file.path(root, "_tools", "acc_data.R")); root <- acc_root(root)
base <- file.path(root, "__andres_control", "elsoc_2021_2023_exploration")
sink(file.path(base, "weights_inspect_output.txt"), split = TRUE)
cat(sprintf("weights_inspect.R run on %s\n", format(Sys.time(), "%Y-%m-%d %H:%M")))
file <- acc_data("_elsoc/elsoc_wide_2016_2023.tar.xz.enc")
stopifnot(unname(tools::md5sum(file)) == "dac64998f382fc99a5688ee8b5947db3")
cat("SAV MD5 verified: dac64998f382fc99a5688ee8b5947db3 (Dataverse 10.7910/DVN/LD4BPH, V3)\n")
meta <- haven::read_sav(file, n_max = 0, user_na = TRUE)
keep <- names(meta)[grepl("^(idencuesta|muestra|tipo_atricion|segmento_disenno|estrato_disenno)$|^(ola|fecha_entr|cuestion_completo|segmento|ponderador01|ponderador02|ponderador_long_total|ponderador_long_panel)_w0[1-7]$|^(s09|s10|m0_sexo|m0_edad|m01)_w0[1357]$", names(meta))]
d <- as.data.frame(haven::read_sav(file, col_select = tidyselect::all_of(keep), user_na = TRUE))
for (v in names(d)) if (is.numeric(d[[v]])) d[[v]] <- as.numeric(d[[v]])
stopifnot(!anyDuplicated(d$idencuesta))
getv <- function(v, w) d[[paste0(v, "_w", w)]]
present <- function(w) getv("ola", w) %in% 1
sample_label <- ifelse(d$muestra == 1, "M1", "M2")
waves <- c("01", "02", "03", "04", "05", "06", "07")
cohort_waves <- list(M1 = waves, M2 = waves[3:7])
cat("\n== A. Panel-weight holders: identity across waves, balanced participation, tipo_atricion ==\n")
for (s in c("M1", "M2")) {
  sets <- lapply(cohort_waves[[s]], function(w) d$idencuesta[sample_label == s & is.finite(getv("ponderador_long_panel", w)) & getv("ponderador_long_panel", w) > 0])
  balanced <- d$idencuesta[sample_label == s & Reduce(`&`, lapply(cohort_waves[[s]], present))]
  atr1 <- d$idencuesta[sample_label == s & d$tipo_atricion %in% 1]
  cat(sprintf("%s: panel holders per wave = %s | identical sets across waves: %s | == balanced participants (n=%d): %s | == tipo_atricion==1 (n=%d): %s\n",
    s, paste(vapply(sets, length, 1L), collapse = "/"), all(vapply(sets, function(x) setequal(x, sets[[1]]), TRUE)),
    length(balanced), setequal(sets[[1]], balanced), length(atr1), setequal(sets[[1]], atr1)))
  tb <- table(d$tipo_atricion[sample_label == s], useNA = "ifany")
  cat(sprintf("   tipo_atricion codes in %s: %s\n", s, paste(names(tb), tb, sep = "=", collapse = "; ")))
}
cat("\n== B. Total weight: positive for every respondent; mean by participation pattern (missed any earlier cohort wave) ==\n")
for (w in waves) for (s in c("M1", "M2")) {
  cw <- cohort_waves[[s]]; if (!w %in% cw) next
  z <- present(w) & sample_label == s; wt <- getv("ponderador_long_total", w)
  stopifnot(all(is.finite(wt[z]) & wt[z] > 0), all(is.na(wt[sample_label == s & !present(w)])))
  earlier <- cw[seq_len(match(w, cw) - 1)]
  missed <- if (length(earlier)) !Reduce(`&`, lapply(earlier, present)) else rep(FALSE, nrow(d))
  cat(sprintf("w%s %s: n=%d sum=%.1f | continuous n=%d mean=%.3f median=%.3f | returners n=%d mean=%.3f median=%.3f | max=%.2f\n",
    w, s, sum(z), sum(wt[z]), sum(z & !missed), mean(wt[z & !missed]), stats::median(wt[z & !missed]),
    sum(z & missed), if (any(z & missed)) mean(wt[z & missed]) else NA, if (any(z & missed)) stats::median(wt[z & missed]) else NA, max(wt[z])))
}
cat("\n== B2. Transversal ponderador01: sum by sample vs n (implicit M1/M2 composite) ==\n")
for (w in c("03", "05", "07")) {
  z1 <- present(w) & sample_label == "M1"; z2 <- present(w) & sample_label == "M2"; wt <- getv("ponderador01", w); lt <- getv("ponderador_long_total", w)
  cat(sprintf("w%s: ponderador01 sum M1=%.1f (n=%d, mean %.3f) M2=%.1f (n=%d, mean %.3f); M1 share of weight=%.3f vs n share=%.3f | long_total: M1 share of weight=%.3f\n",
    w, sum(wt[z1]), sum(z1), mean(wt[z1]), sum(wt[z2]), sum(z2), mean(wt[z2]), sum(wt[z1]) / sum(wt[z1 | z2]), sum(z1) / sum(z1 | z2), sum(lt[z1]) / sum(lt[z1 | z2])))
}
cat("\n== C. Pair domains (masks as in extend_intervals.R): origin vs destination weights, panel subset, dates ==\n")
regular <- function(x) ifelse(x %in% 1:2, x, NA_real_)
frequency <- function(s09, s10) ifelse(s09 %in% 1 & s10 %in% 1:8, s10, NA_real_)
pairs <- data.frame(interval = c("2016-2018", "2018-2021", "2021-2023"), origin = c("01", "03", "05"), destination = c("03", "05", "07"), year0 = c(2016, 2018, 2021), year1 = c(2018, 2021, 2023))
seg <- as.character(d$segmento_disenno); st <- d$estrato_disenno
ess <- function(w) sum(w)^2 / sum(w^2)
for (pi in seq_len(nrow(pairs))) {
  p <- pairs[pi, ]; w0 <- p$origin; w1 <- p$destination
  date0 <- as.Date(getv("fecha_entr", w0), format = "%Y-%m-%d"); date1 <- as.Date(getv("fecha_entr", w1), format = "%Y-%m-%d")
  age0 <- getv("m0_edad", w0); age1 <- getv("m0_edad", w1); sex0 <- getv("m0_sexo", w0); sex1 <- getv("m0_sexo", w1)
  baseline <- present(w0) & !is.na(age0) & age0 >= 18 & age0 <= 65; linked <- baseline & present(w1)
  valid_dates <- !is.na(date0) & !is.na(date1) & date1 > date0 & as.integer(format(date0, "%Y")) == p$year0 & as.integer(format(date1, "%Y")) %in% if (w1 == "07") c(2023, 2024) else p$year1
  sex_ok <- sex0 %in% 1:2 & sex1 %in% 1:2 & sex0 == sex1
  quality <- linked & sex_ok & valid_dates & !is.na(age1) & age1 >= 18 & age1 <= 110
  r0 <- regular(getv("s09", w0)); r1 <- regular(getv("s09", w1)); f0 <- frequency(getv("s09", w0), getv("s10", w0)); f1 <- frequency(getv("s09", w1), getv("s10", w1))
  rp <- quality & !is.na(r0) & !is.na(r1); fp <- quality & !is.na(f0) & !is.na(f1)
  cat(sprintf("\n-- %s: primary=%d s09=%d s10=%d --\n", p$interval, sum(quality), sum(rp), sum(fp)))
  ls <- linked & sex_ok
  cat(sprintf("   date exclusions among sex-consistent links: total %d = destination date missing %d + origin date missing %d + ordered/year failures %d\n",
    sum(ls & !valid_dates), sum(ls & is.na(date1)), sum(ls & !is.na(date1) & is.na(date0)), sum(ls & !is.na(date1) & !is.na(date0) & !valid_dates)))
  cat(sprintf("   destination respondents of the sample absent at origin (all ages, context only): M1 %d, M2 %d\n", sum(present(w1) & !present(w0) & sample_label == "M1"), sum(present(w1) & !present(w0) & sample_label == "M2")))
  wt0 <- getv("ponderador_long_total", w0); wt1 <- getv("ponderador_long_total", w1); wp1 <- getv("ponderador_long_panel", w1); wp0 <- getv("ponderador_long_panel", w0)
  r <- wt1[rp] / wt0[rp]
  cat(sprintf("   ratio dest/origin long_total on s09 pairs: q05=%.2f q25=%.2f median=%.2f q75=%.2f q95=%.2f | cor(log w0, log w1)=%.3f | sum w0=%.1f sum w1=%.1f\n",
    stats::quantile(r, .05), stats::quantile(r, .25), stats::median(r), stats::quantile(r, .75), stats::quantile(r, .95), stats::cor(log(wt0[rp]), log(wt1[rp])), sum(wt0[rp]), sum(wt1[rp])))
  panel <- rp & is.finite(wp1) & wp1 > 0
  stopifnot(identical(panel, rp & d$tipo_atricion %in% 1))
  cat(sprintf("   panel-eligible s09 pairs: %d (M1 %d, M2 %d); s10: %d | panel w1/w0 ratio median=%.2f | cor(log panel w1, log total w1)=%.3f | cor(log panel w0, log panel w1)=%.3f\n",
    sum(panel), sum(panel & sample_label == "M1"), sum(panel & sample_label == "M2"), sum(fp & is.finite(wp1) & wp1 > 0),
    stats::median(wp1[panel] / wp0[panel]), stats::cor(log(wp1[panel]), log(wt1[panel])), stats::cor(log(wp0[panel]), log(wp1[panel]))))
  cat(sprintf("   long_total on s09 pairs: sum=%.1f ESS=%.0f (n=%d) | long_total on panel subset: sum=%.1f ESS=%.0f | panel on panel subset: sum=%.1f ESS=%.0f (n=%d)\n",
    sum(wt1[rp]), ess(wt1[rp]), sum(rp), sum(wt1[panel]), ess(wt1[panel]), sum(wp1[panel]), ess(wp1[panel]), sum(panel)))
  if (any(rp & sample_label == "M2")) cat(sprintf("   long_total weight share M1 on s09 pairs=%.3f vs n share=%.3f\n", sum(wt1[rp & sample_label == "M1"]) / sum(wt1[rp]), sum(rp & sample_label == "M1") / sum(rp)))
  cat("   destination total weight by stratum on s09 pairs (median; p05-p95): ", paste(sapply(sort(unique(st[rp])), function(h) { x <- wt1[rp & st == h]; sprintf("%d: %.2f (%.3f-%.2f)", h, stats::median(x), stats::quantile(x, .05), stats::quantile(x, .95)) }), collapse = " | "), "\n")
  cat("   segments per stratum (general s09 pairs / panel subset): ", paste(sapply(sort(unique(st[rp])), function(h) sprintf("%d: %d/%d", h, length(unique(seg[rp & st == h])), length(unique(seg[panel & st == h])))), collapse = " | "), "\n")
  age_group <- as.character(cut(age0, c(17, 29, 44, 59, 65), labels = c("18-29", "30-44", "45-59", "60-65")))
  sex <- ifelse(sex0 == 1, "Men", ifelse(sex0 == 2, "Women", "Unknown"))
  edu <- getv("m01", w0); edu <- ifelse(edu %in% 1:4, "Basic", ifelse(edu %in% c(5, 6, 8), "Secondary", ifelse(edu %in% c(7, 9, 10), "Higher", "Unknown")))
  for (s in c("Men", "Women")) cat(sprintf("   %s s09 general/panel by age: %s | s10 general/panel: %s\n", s,
    paste(sapply(c("18-29", "30-44", "45-59", "60-65"), function(a) sprintf("%s %d/%d", a, sum(rp & sex == s & age_group %in% a), sum(panel & sex == s & age_group %in% a))), collapse = ", "),
    paste(sapply(c("18-29", "30-44", "45-59", "60-65"), function(a) sprintf("%s %d/%d", a, sum(fp & sex == s & age_group %in% a), sum(fp & is.finite(wp1) & wp1 > 0 & sex == s & age_group %in% a))), collapse = ", ")))
  cat(sprintf("   education s09 general/panel: %s\n", paste(sapply(c("Basic", "Secondary", "Higher", "Unknown"), function(e) sprintf("%s %d/%d", e, sum(rp & edu == e), sum(panel & edu == e))), collapse = ", ")))
  cat(sprintf("   S09 origin regular (code 1) count: general %d/%d, panel subset %d/%d\n", sum(rp & r0 == 1), sum(rp), sum(panel & r0 == 1), sum(panel)))
  mid <- c("01" = "02", "03" = "04", "05" = "06")[w0]
  cat(sprintf("   absent in intermediate wave w%s and present at both ends: general %d, panel subset %d\n", mid, sum(rp & !present(mid)), sum(panel & !present(mid))))
}
cat("\n== E. segmento_wXX vs segmento_disenno ==\n")
for (w in waves) { z <- present(w); cat(sprintf("w%s: present=%d, segmento_w differs from segmento_disenno: %d, segmento_w missing: %d\n", w, sum(z), sum(z & !is.na(getv("segmento", w)) & getv("segmento", w) != d$segmento_disenno), sum(z & is.na(getv("segmento", w))))) }
cat(sprintf("segmento_disenno missing: %d; distinct segments: %d; distinct strata: %d; segments shared by M1 and M2: %d; segments in more than one stratum: %d\n",
  sum(is.na(d$segmento_disenno)), length(unique(seg)), length(unique(st)), sum(tapply(d$muestra, seg, function(z) length(unique(z))) > 1), sum(tapply(st, seg, function(z) length(unique(z))) > 1)))
cat("\n== G. Continuity w06 -> w07 and within-wave dispersion of long_total ==\n")
z <- present("06") & present("07")
cat(sprintf("n=%d cor(log total w06, log total w07)=%.3f\n", sum(z), stats::cor(log(getv("ponderador_long_total", "06")[z]), log(getv("ponderador_long_total", "07")[z]))))
for (w in c("03", "05", "06", "07")) { wt <- getv("ponderador_long_total", w); z <- present(w); cat(sprintf("w%s total: p01=%.3f p05=%.3f p50=%.3f p95=%.3f p99=%.3f max=%.2f; n at exact min=%d, at exact max=%d\n", w, stats::quantile(wt[z], .01), stats::quantile(wt[z], .05), stats::median(wt[z]), stats::quantile(wt[z], .95), stats::quantile(wt[z], .99), max(wt[z]), sum(wt[z] == min(wt[z])), sum(wt[z] == max(wt[z])))) }
cat("\n== H. Official 2016-2022 CSV (elsoc-coes/ponderadores-long, commit 475c7e32) vs SAV values, waves 1-6 ==\n")
csv_url <- "https://raw.githubusercontent.com/elsoc-coes/ponderadores-long/475c7e32becc1451e8d40fb9b8ef0b79d4e5885f/generar%20ponderadores/resultados/pesos_longitudinales_elsoc.csv"
csv <- tryCatch({ tmp <- tempfile(fileext = ".csv"); utils::download.file(csv_url, tmp, mode = "wb", quiet = TRUE); utils::read.csv(tmp) }, error = function(e) NULL)
if (is.null(csv)) cat("download failed (offline?): comparison skipped\n") else {
  cat(sprintf("CSV rows=%d; per wave: %s\n", nrow(csv), paste(names(table(csv$ola)), table(csv$ola), sep = "=", collapse = ", ")))
  for (w in 1:6) {
    x <- csv[csv$ola == w, ]; m <- match(x$idencuesta, d$idencuesta)
    t_sav <- d[[sprintf("ponderador_long_total_w0%d", w)]][m]; p_sav <- d[[sprintf("ponderador_long_panel_w0%d", w)]][m]
    cat(sprintf("ola %d: csv n=%d matched=%d | total: max|diff|=%.3f cor=%.4f | panel non-NA csv=%d sav=%d max|diff|=%.3f\n", w, nrow(x), sum(!is.na(m)),
      max(abs(x$ponderadorlong_total - t_sav), na.rm = TRUE), stats::cor(x$ponderadorlong_total, t_sav, use = "complete.obs"),
      sum(!is.na(x$ponderadorlong_panel)), sum(!is.na(p_sav)), suppressWarnings(max(abs(x$ponderadorlong_panel - p_sav), na.rm = TRUE))))
  }
}
cat(sprintf("\nNo transition estimates computed; no repository table modified. Elapsed %.2f minutes\n", as.numeric(difftime(Sys.time(), .t0, units = "mins"))))
sink()
