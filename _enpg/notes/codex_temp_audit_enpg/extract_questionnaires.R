.libPaths(c("C:/Users/homes/Claude/Projects/gambling/analisis_suicidio/enpg/_codex_temp_audit_enpg/Rlib", .libPaths()))
suppressPackageStartupMessages(library(pdftools))
base <- "C:/Users/homes/Claude/Projects/gambling/analisis_suicidio/enpg"
out <- file.path(base, "_codex_temp_audit_enpg")
files <- c(
  `2012` = "Cuestionario ENPG 2012.pdf.pdf",
  `2014` = "Cuestionario ENPG 2014.pdf.pdf",
  `2016` = "Cuestionario_Senda2016.pdf"
)
for (yr in names(files)) {
  p <- pdf_text(file.path(base, files[[yr]]))
  writeLines(paste0("===== PAGE ", seq_along(p), " =====\n", p),
             file.path(out, paste0("questionnaire_", yr, ".txt")), useBytes = TRUE)
  cat(yr, "pages", length(p), "chars", sum(nchar(p)), "\n")
}
