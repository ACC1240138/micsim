.t0 <- Sys.time()

dir_enpg <- file.path(here::here(), "__enpg")
out_md   <- file.path(here::here(), "__andres_control", "enpg_radiografia.md")

archivos <- list.files(dir_enpg, pattern = "\\.(sav|dta|rds)$",
                       full.names = TRUE, ignore.case = TRUE, recursive = FALSE)

leer <- function(f) {
  ext <- tolower(tools::file_ext(f))
  switch(ext,
         sav = haven::read_sav(f),
         dta = haven::read_dta(f),
         rds = tibble::as_tibble(readRDS(f)))
}

trunc_vec <- function(x, n = 25) {
  if (length(x) > n) c(x[seq_len(n)], sprintf("... (+%d)", length(x) - n)) else x
}

radiografia <- function(f) {
  d <- tryCatch(leer(f), error = function(e) NULL)
  if (is.null(d)) return(list(archivo = basename(f), error = TRUE))

  sumas <- vapply(d, function(x) if (is.numeric(x)) sum(as.numeric(x), na.rm = TRUE) else NA_real_,
                  numeric(1))
  pond  <- names(sumas)[!is.na(sumas) & sumas >= 1e6 & sumas <= 2e7]
  card  <- vapply(d, function(x) length(unique(x)), integer(1))

  list(
    archivo    = basename(f),
    mb         = round(file.size(f) / 1024^2, 1),
    n_filas    = nrow(d),
    n_vars     = ncol(d),
    ponderador = pond,
    suma_pond  = round(sumas[pond]),
    card_media = names(card)[card >= 50 & card <= 5000],
    card_baja  = names(card)[card >= 2 & card <= 20],
    error      = FALSE
  )
}

res <- lapply(archivos, radiografia)

md <- c(
  "# Radiografía de bases ENPG",
  "",
  sprintf("Generado: %s · carpeta: `__enpg/` (no recursivo)", format(Sys.Date())),
  "",
  "Criterios heurísticos:",
  "",
  "- **Ponderador candidato**: variable numérica cuya suma cae entre 1 y 20 millones (orden de magnitud de la población chilena 15–64).",
  "- **Cardinalidad media (50–5000 niveles)**: candidatos a conglomerado / manzana / UPM / comuna.",
  "- **Cardinalidad baja (2–20 niveles)**: candidatos a estrato, sexo, tramo etario, categóricas de consumo.",
  "",
  "## Resumen",
  "",
  "| Archivo | MB | Filas | Vars | Ponderador(es) | Suma |",
  "|---|---:|---:|---:|---|---|"
)

for (r in res) {
  if (isTRUE(r$error)) {
    md <- c(md, sprintf("| `%s` | | | | *no se pudo leer* | |", r$archivo))
    next
  }
  md <- c(md, sprintf("| `%s` | %s | %s | %s | %s | %s |",
                      r$archivo, r$mb, format(r$n_filas, big.mark = " "), r$n_vars,
                      if (length(r$ponderador)) paste0("`", r$ponderador, "`", collapse = ", ") else "—",
                      if (length(r$suma_pond)) paste(format(r$suma_pond, big.mark = " ", trim = TRUE), collapse = ", ") else "—"))
}

md <- c(md, "", "## Detalle por archivo", "")
for (r in res) {
  if (isTRUE(r$error)) next
  md <- c(md,
    sprintf("### %s", r$archivo), "",
    sprintf("- Filas: %s · Variables: %s", format(r$n_filas, big.mark = " "), r$n_vars),
    sprintf("- Ponderador(es): %s",
            if (length(r$ponderador)) paste(sprintf("`%s` (suma = %s)", r$ponderador,
              format(r$suma_pond, big.mark = " ", trim = TRUE)), collapse = "; ") else "ninguno en rango"),
    sprintf("- Cardinalidad media (n=%d): %s", length(r$card_media),
            if (length(r$card_media)) paste0("`", trunc_vec(r$card_media), "`", collapse = ", ") else "—"),
    sprintf("- Cardinalidad baja (n=%d): %s", length(r$card_baja),
            if (length(r$card_baja)) paste0("`", trunc_vec(r$card_baja, 30), "`", collapse = ", ") else "—"),
    "")
}

# Diccionario completo de la ola más reciente disponible
f2024 <- grep("2024", archivos, value = TRUE)[1]
if (!is.na(f2024)) {
  d <- leer(f2024)
  lab <- vapply(labelled::var_label(d), function(x) if (is.null(x)) "" else as.character(x)[1], character(1))
  nlv <- vapply(d, function(x) length(labelled::val_labels(x)), integer(1))
  md <- c(md, sprintf("## Diccionario completo — %s", basename(f2024)), "",
          "> Las etiquetas vienen cortadas a 80 caracteres en el propio `.dta` (límite de Stata para variable labels); el texto completo de cada pregunta está en `__enpg/cuestionario 2024.pdf`.",
          "",
          "| Variable | Etiqueta | n niveles etiquetados |", "|---|---|---:|",
          sprintf("| `%s` | %s | %s |", names(lab),
                  gsub("|", "\\|", lab, fixed = TRUE),
                  ifelse(nlv > 0, as.character(nlv), "—")),
          "")
}

writeLines(md, out_md, useBytes = TRUE)
cat("escrito:", out_md, "\n")
cat("elapsed (min):", round(as.numeric(difftime(Sys.time(), .t0, units = "mins")), 2), "\n")
