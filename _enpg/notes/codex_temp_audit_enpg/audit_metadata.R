options(width = 220, warn = 1)
suppressPackageStartupMessages(library(haven))

base <- "C:/Users/homes/Claude/Projects/gambling/analisis_suicidio/enpg"
out <- file.path(base, "_codex_temp_audit_enpg")
files <- data.frame(
  id = c("2008", "2010", "2012a", "2012b", "2014", "2016", "2018", "2020", "2022", "2024", "factors"),
  path = file.path(base, c(
    "enpg2008.RDS", "enpg2010.RDS", "Base de datos ENPG 2012 (PG).dta",
    "Base de datos ENPG 2012 (PG).DTA.dta", "Base de datos ENPG 2014 (PG).DTA.dta",
    "base ENPG 2016 publico general.dta", "Base de datos ENPG 2018 (PG).DTA",
    "enpg2020.RDS", "enpg2022.RDS", "Base Publica ENPG 2024 (Stata 16).dta",
    "factoresdeexpansion.dta"
  )), stringsAsFactors = FALSE
)

read_any <- function(path) {
  if (grepl("[.]RDS$", path, ignore.case = TRUE)) readRDS(path) else read_dta(path)
}
one_label <- function(x) {
  z <- attr(x, "label", exact = TRUE)
  if (is.null(z)) "" else paste(as.character(z), collapse = " | ")
}
value_labels <- function(x) {
  z <- attr(x, "labels", exact = TRUE)
  if (is.null(z)) "" else paste0(names(z), "=", unname(z), collapse = " | ")
}
dicts <- list()
inv <- list()
for (k in seq_len(nrow(files))) {
  message("Reading ", files$id[k], ": ", basename(files$path[k]))
  x <- read_any(files$path[k])
  lab <- vapply(x, one_label, "")
  vl <- vapply(x, value_labels, "")
  d <- data.frame(
    id = files$id[k], year = suppressWarnings(as.integer(sub("[ab]$", "", files$id[k]))),
    file = basename(files$path[k]), position = seq_along(x), name = names(x),
    class = vapply(x, function(z) paste(class(z), collapse = "/"), ""),
    label = lab, value_labels = vl,
    stringsAsFactors = FALSE
  )
  dicts[[k]] <- d
  inv[[k]] <- data.frame(id = files$id[k], file = basename(files$path[k]), n = nrow(x), p = ncol(x),
                        data_class = paste(class(x), collapse = "/"))
}
dict <- do.call(rbind, dicts)
inventory <- do.call(rbind, inv)
write.csv(inventory, file.path(out, "inventory.csv"), row.names = FALSE, fileEncoding = "UTF-8")
write.csv(dict, file.path(out, "dictionary_all.csv"), row.names = FALSE, fileEncoding = "UTF-8")

txt <- paste(dict$name, dict$label)
patterns <- list(
  design = "region|regi[oó]n|estrat|upm|conglomer|segment|secci[oó]n|manzana|factor|ponder|peso|expansi[oó]n|fexp|comuna|provincia",
  treatment = "tratamiento|tratar|trat[ao]_|ayuda|consult|atenci[oó]n|rehab|necesidad",
  alcohol = "alcohol|(^|_)oh(_|$)|bebida alcoh|cerveza|licor",
  cannabis = "marihuana|cannabis|(^|_)mar(_|$)",
  cocaine = "coca[ií]na|(^|_)coc(_|$)",
  basepaste = "pasta base|(^|_)pb(_|$)",
  problem = "dependen|abuso|problem[aá]tic|cie.?10|dsm.?iv|s[ií]ntoma"
)
for (nm in names(patterns)) {
  z <- dict[grepl(patterns[[nm]], txt, ignore.case = TRUE, perl = TRUE), ]
  write.csv(z, file.path(out, paste0("dictionary_", nm, ".csv")), row.names = FALSE, fileEncoding = "UTF-8")
}
print(inventory, row.names = FALSE)
