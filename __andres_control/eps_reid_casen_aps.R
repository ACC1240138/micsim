
.t0 <- Sys.time()
# Compatibility copy of eps_reid.R: explicit VIII respondent age/sex mapping.
# Infer candidate sampling comunas; assignments remain unvalidated.
# Output is aggregate (cluster x comuna); nothing written in the repo.
source(here::here("_tools", "acc_data.R"))
out <- Sys.getenv("SCR", tempdir())
r <- acc_data("_eps/eps.tar.xz.enc")
rd <- function(f, ...) haven::read_dta(file.path(r, f), ...)
num <- function(x) suppressWarnings(as.numeric(haven::zap_labels(x)))
bands <- c("20-34", "35-49", "50-64", "65+")
brk <- c(20, 35, 50, 65, Inf)

# 1. INE 2023 profile per comuna
dirc <- here::here("__andres_control")
fine <- list.files(dirc, "EEPP comuna area")
ine <- data.table::fread(file.path(dirc, fine), sep = ";", encoding = "UTF-8", data.table = FALSE)
names(ine)[c(1, 5, 6, 7, 8, 9)] <-
  c("reg", "comuna", "nombre", "sex", "area", "ageg")
ine$pop <- ine[["Poblacion 2023"]]
ine$lo <- as.numeric(regmatches(ine$ageg,
                                regexpr("[0-9]+", ine$ageg)))
ine$band <- as.character(cut(ine$lo, brk, right = FALSE,
                             labels = bands))
# Merged units (technical report): Iquique+Alto Hospicio,
# Talcahuano+Hualpen.
ine$unit <- as.character(ine$comuna)
ine$unit[ine$comuna %in% c(1101, 1107)] <- "1101+1107"
ine$unit[ine$comuna %in% c(8110, 8112)] <- "8110+8112"
ad <- ine[!is.na(ine$band), ]
U <- data.frame(unit = sort(unique(ine$unit)))
U$reg <- as.numeric(tapply(ine$reg, ine$unit, `[`, 1)[U$unit])
nm <- tapply(ine$nombre, ine$unit,
             function(x) paste(unique(x), collapse = "+"))
U$nombre <- nm[U$unit]
U$pop20 <- as.numeric(tapply(ad$pop, ad$unit, sum)[U$unit])
rur <- tapply(ine$pop * (ine$area == 2), ine$unit, sum)
tot <- tapply(ine$pop, ine$unit, sum)
U$rural <- as.numeric((rur / tot)[U$unit])
P <- tapply(ad$pop, list(ad$unit, paste(ad$sex, ad$band)), sum)
P <- P / rowSums(P)
stopifnot(abs(rowSums(P) - 1) < 1e-9, ncol(P) == 8)

# 2. EPS design and cluster region (modal work region, 2020)
fw <- list.files(r, "[.]dta$", recursive = TRUE)
fw <- fw[grepl("factor|fact_exp", fw, ignore.case = TRUE)]
des <- unique(do.call(rbind, lapply(fw, function(f) {
  h <- rd(f, n_max = 0)
  if (!all(c("folio_n20", "cluster_ID") %in% names(h))) {
    return(NULL)
  }
  d <- rd(f, col_select = c("folio_n20", "cluster_ID"))
  data.frame(id = as.character(d$folio_n20),
             cl = num(d$cluster_ID))
})))
stopifnot(!anyDuplicated(des$id))
fb <- file.path("Bases y Documentos EPS 2020", "2020",
                "Bases_EPS2020_presencial", "01_Vivos presencial",
                "MODULO_B_Historia_Laboral_in.dta")
b <- rd(fb, col_select = c("folio_n20", "b4"))
b <- data.frame(id = as.character(b$folio_n20), reg = num(b$b4))
b <- b[b$reg %in% 1:16, ]
b$cl <- des$cl[match(b$id, des$id)]
b <- b[!is.na(b$cl), ]
fx <- file.path("Bases de datos EPS VIII Ronda", "FACT_EXP",
                "Factor_XS_EPS_2023.dta")
x <- rd(fx)
D <- data.frame(id = as.character(x$folio_n20),
                cl = num(x$cluster_ID),
                st = num(x$strata_ID),
                w = num(x$factor_XS))

# 3. Use the documented respondent file: current labels do not start with Sex/Age.
vdir <- file.path(r, "Bases de datos EPS VIII Ronda", "BBDD_VIVOS")
vf <- list.files(vdir, "[.]dta$", full.names = TRUE)
f <- file.path(vdir, "MODULO_A_ENTREVISTADO.dta")
d <- haven::read_dta(f, col_select = c("folio_n20", "a8", "a9"))
stopifnot(!anyDuplicated(d$folio_n20), all(num(d$a8) %in% 1:2))
pick <- list(f = basename(f), s = "a8", a = "a9", d = d)
sexcode <- num(d$a8)
j <- match(D$id, as.character(pick$d$folio_n20))
D$sex <- sexcode[j]
D$age <- num(pick$d[[pick$a]])[j]
cat("sex/age matched:",
    round(mean(!is.na(D$sex) & !is.na(D$age)), 3), "\n")
D$band <- as.character(cut(D$age, brk, right = FALSE,
                           labels = bands))
D$cell <- paste(D$sex, D$band)

# 4. Rurality signal: any answer coded "Posta rural"
is_posta <- function(z) {
  any(grepl("posta rural", names(attr(z, "labels")),
            ignore.case = TRUE))
}
pr <- character()
for (f in vf) {
  h <- haven::read_dta(f, n_max = 0)
  if (!"folio_n20" %in% names(h)) next
  v <- names(h)[vapply(h, is_posta, TRUE)]
  if (!length(v)) next
  cols <- c("folio_n20", v)
  d <- haven::read_dta(f, col_select = dplyr::all_of(cols))
  hit <- Reduce(`|`, lapply(v, function(k) {
    cd <- attr(d[[k]], "labels")
    cd <- cd[grepl("posta rural", names(cd), ignore.case = TRUE)]
    num(d[[k]]) %in% as.numeric(cd)
  }))
  cat("posta rural:", basename(f), paste(v, collapse = ","), "\n")
  pr <- c(pr, as.character(d$folio_n20[hit]))
}
D$posta <- D$id %in% pr

# 5. Cluster profiles
C <- aggregate(w ~ cl + st, D, sum)
C$n <- as.vector(table(D$cl)[as.character(C$cl)])
pw <- tapply(D$w * D$posta, D$cl, sum)
C$posta <- as.vector(pw[as.character(C$cl)]) / C$w
modal <- function(k) {
  z <- b$reg[b$cl == k]
  if (!length(z)) return(c(NA, NA, 0))
  t <- table(z)
  c(as.numeric(names(t)[which.max(t)]), max(t) / sum(t), sum(t))
}
rg <- t(sapply(C$cl, modal))
C$reg <- rg[, 1]
C$reg_share <- round(rg[, 2], 2)
C$reg_n <- rg[, 3]
ok <- D$cell %in% colnames(P)
Q <- matrix(0, nrow(C), ncol(P),
            dimnames = list(as.character(C$cl), colnames(P)))
qq <- tapply(D$w[ok], list(as.character(D$cl[ok]), D$cell[ok]), sum)
qq[is.na(qq)] <- 0
Q[rownames(qq), colnames(qq)] <- qq
Q <- Q / pmax(rowSums(Q), 1e-12)

# 6. Score every (self-representing cluster, comuna in region)
# shortcut: score weights are judgement calls (size dominates,
# posta rural is weak); tune them if margins are thin.
score_one <- function(i) {
  u <- U[U$reg == C$reg[i], ]
  q <- Q[as.character(C$cl[i]), ]
  pu <- P[u$unit, , drop = FALSE]
  data.frame(cl = C$cl[i], reg = C$reg[i], n = C$n[i],
             unit = u$unit, nombre = u$nombre,
             rural = round(100 * u$rural, 1),
             ratio = round(C$w[i] / u$pop20, 2),
             d_size = abs(log(C$w[i] / u$pop20)),
             #d_agesex = 0.5 * rowSums(abs(sweep(pu, 2, q))),
             d_agesex = 0.5 * rowSums(
                abs(
                  sweep(pu, 2, q, FUN = "-")
                )
              ),
             d_rural = abs(C$posta[i] - u$rural))
}
idx <- which(C$st == 0 & !is.na(C$reg))
S <- do.call(rbind, lapply(idx, score_one))
S$score <- S$d_size / 0.15 +
  S$d_agesex / (0.05 + 0.5 / sqrt(S$n)) +
  S$d_rural / 0.25

# 7. One-to-one greedy assignment (each comuna used once)
S <- S[order(S$score), ]
A <- S[0, ]
for (k in seq_len(nrow(S))) {
  if (!S$cl[k] %in% A$cl && !S$unit[k] %in% A$unit) {
    A <- rbind(A, S[k, ])
  }
}
stopifnot(!anyDuplicated(A$unit), !anyDuplicated(A$cl))
alt_one <- function(k) {
  z <- S[S$cl == A$cl[k] & S$unit != A$unit[k], ]
  z <- z[which.min(z$score), ]
  c(z$nombre, round(z$score - A$score[k], 2))
}
alt <- t(sapply(seq_len(nrow(A)), alt_one))
A$alt <- alt[, 1]
A$margin <- as.numeric(alt[, 2])
A$conf <- ifelse(A$margin > 2 & A$d_size < 0.2, "alta",
                 ifelse(A$margin > 0.75, "media", "baja"))
A <- A[order(A$cl), ]
A$posta <- round(100 * C$posta[match(A$cl, C$cl)], 1)
rc <- c("d_size", "d_agesex", "d_rural", "score")
A[rc] <- lapply(A[rc], round, 2)
fo <- file.path(out, "eps_cluster_comuna_assigned.csv")
write.csv(A, fo, row.names = FALSE)
options(width = 220)
show <- c("cl", "reg", "n", "nombre", "rural", "ratio", "d_agesex",
          "posta", "score", "alt", "margin", "conf")
print(A[show], row.names = FALSE)
tc <- table(A$conf)
cat("\nconfidence:", paste(names(tc), tc, collapse = "  "), "\n")
cat("cor(posta %, INE rural %):",
    round(cor(A$posta, A$rural), 2), "\n")
cat("unassigned self-rep clusters:",
    setdiff(C$cl[C$st == 0], A$cl), "\n")
cat("written:", fo, "\n")
el <- as.numeric(difftime(Sys.time(), .t0, units = "mins"))
cat(sprintf("Elapsed: %.2f min\n", el))
