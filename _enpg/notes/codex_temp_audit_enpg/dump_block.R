suppressPackageStartupMessages(library(haven))
args <- commandArgs(TRUE)
x <- if (grepl("[.]RDS$", args[1], ignore.case = TRUE)) readRDS(args[1]) else read_dta(args[1])
pat <- if (length(args) >= 2) args[2] else "."
i <- grep(pat, names(x), perl = TRUE, ignore.case = TRUE)
one <- function(z, a) {
  q <- attr(z, a, exact = TRUE)
  if (is.null(q)) "" else if (a == "labels") paste(names(q), unname(q), sep = "=", collapse = " | ") else paste(q, collapse = " | ")
}
d <- data.frame(position = i, name = names(x)[i],
                label = vapply(x[i], one, "", a = "label"),
                value_labels = vapply(x[i], one, "", a = "labels"))
print(d, row.names = FALSE)
