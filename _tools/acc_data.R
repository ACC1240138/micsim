# _tools/acc_data.R -- encrypted data bundles for the FONDECYT 1240138 repo (ACC1240138/micsim).
# Load once per notebook/script: source(file.path(<root>, "_tools", "acc_data.R"))
#
# Bundle format (*.tar.xz.enc): "ACC1" | rounds (int32, big endian) | salt (16) | iv (16) | ciphertext | hmac (32)
# tar.xz (base R) -> AES-256-CTR + HMAC-SHA256 (encrypt-then-MAC); key derived with bcrypt_pbkdf
# from the env var ACC_DATA_KEY (~/.Renviron locally, repository secret on GitHub).
# Note: openssl::aes_gcm_* does not verify an authentication tag, hence CTR + explicit HMAC.
# Each bundle has a plain sidecar <bundle>.md5.csv (file, bytes, md5): file names only, no data.

acc_root <- function(path = getwd()) {
  path <- normalizePath(path, winslash = "/", mustWork = TRUE)
  while (!file.exists(file.path(path, ".acc_root"))) {
    parent <- dirname(path)
    if (identical(parent, path)) stop("Project root not found: no .acc_root above ", getwd())
    path <- parent
  }
  path
}

acc_key <- function() {
  key <- Sys.getenv("ACC_DATA_KEY")
  if (!nzchar(key)) stop("ACC_DATA_KEY is not set (~/.Renviron locally, repository secret on GitHub).")
  key
}

acc_keys <- function(key, salt, rounds) {
  k <- openssl::bcrypt_pbkdf(key, salt, rounds = rounds, size = 64L)
  list(enc = k[1:32], mac = k[33:64])
}

# Pack a folder or a single file into `out` (*.tar.xz.enc) and write the sidecar `out`.md5.csv.
acc_pack <- function(src, out, key = acc_key(), rounds = 256L, level = 9L) {
  src <- normalizePath(src, winslash = "/", mustWork = TRUE)
  out <- file.path(normalizePath(dirname(out), winslash = "/", mustWork = TRUE), basename(out))
  files <- if (dir.exists(src)) list.files(src, recursive = TRUE, full.names = TRUE) else src
  sidecar <- data.frame(file = substring(files, nchar(dirname(src)) + 2L),
                        bytes = file.size(files), md5 = unname(tools::md5sum(files)))
  tmp <- tempfile(fileext = ".tar.xz")
  old <- setwd(dirname(src))
  on.exit(setwd(old), add = TRUE)
  utils::tar(tmp, basename(src), compression = "xz", compression_level = level, tar = "internal")
  setwd(old)
  salt <- openssl::rand_bytes(16)
  iv <- openssl::rand_bytes(16)
  k <- acc_keys(key, salt, rounds)
  ct <- openssl::aes_ctr_encrypt(readBin(tmp, "raw", file.size(tmp)), k$enc, iv)
  head <- c(charToRaw("ACC1"), writeBin(as.integer(rounds), raw(), size = 4, endian = "big"), salt, iv)
  writeBin(c(head, ct, as.raw(openssl::sha256(c(head, ct), key = k$mac))), out)
  utils::write.csv(sidecar, paste0(out, ".md5.csv"), row.names = FALSE)
  unlink(tmp)
  root <- tryCatch(acc_root(dirname(out)), error = function(e) NULL)
  if (!is.null(root)) unlink(acc_cache_dir(substring(out, nchar(root) + 2L)), recursive = TRUE)  # drop stale copy
  invisible(out)
}

# Decrypt and extract `file` (*.tar.xz.enc) into `exdir`. Stops on a wrong key or any altered byte.
acc_unpack <- function(file, exdir, key = acc_key()) {
  b <- readBin(file, "raw", file.size(file))
  n <- length(b)
  if (n < 72 || !identical(rawToChar(b[1:4]), "ACC1")) stop("Not an ACC bundle: ", file)
  k <- acc_keys(key, b[9:24], readBin(b[5:8], "integer", size = 4, endian = "big"))
  if (!identical(as.raw(openssl::sha256(b[1:(n - 32)], key = k$mac)), b[(n - 31):n])) {
    stop("Wrong ACC_DATA_KEY or corrupted file: ", file)
  }
  tmp <- tempfile(fileext = ".tar.xz")
  writeBin(openssl::aes_ctr_decrypt(b[41:(n - 32)], k$enc, b[25:40]), tmp)
  utils::untar(tmp, exdir = exdir, tar = "internal")
  unlink(tmp)
  invisible(exdir)
}

# Path to `file` inside a bundle (relative to the repo root), decrypted once per R session into tempdir().
# acc_data("_enpg/enpg.tar.xz.enc", "derived/ENPG_BINGE.RDS"); single-file bundles: acc_data("_deis/x.tar.xz.enc")
acc_cache_dir <- function(bundle) {
  file.path(tempdir(), "acc_data", gsub("[/\\\\]", "__", sub("\\.tar\\.xz\\.enc$", "", bundle)))
}

acc_data <- function(bundle, file = NULL) {
  dest <- acc_cache_dir(bundle)
  if (!dir.exists(dest)) {
    part <- paste0(dest, ".part")
    unlink(part, recursive = TRUE)
    acc_unpack(file.path(acc_root(), bundle), part)
    file.rename(part, dest)
  }
  top <- list.files(dest, full.names = TRUE)
  if (length(top) != 1L) stop("Unexpected bundle layout: ", bundle)
  path <- if (is.null(file)) top else file.path(top, file)
  if (!file.exists(path)) stop("Not in ", bundle, ": ", file)
  path
}

# Newest file by the DDMMYYYY date in its name (never by modification time).
acc_latest <- function(dir, pattern = "^DEFUNCIONES_FUENTE_DEIS_2024_2026_([0-9]{8})\\.tar\\.xz\\.enc$") {
  f <- list.files(dir, pattern, full.names = TRUE)
  if (!length(f)) stop("No file matching ", pattern, " in ", dir)
  f[which.max(as.Date(sub(pattern, "\\1", basename(f)), "%d%m%Y"))]
}

# Weekly DEIS deaths file (2024 onwards) as a data.frame with the original DEIS column names.
# Newest version by default; pin one with ACC_DEIS_VERSION=DDMMYYYY in ~/.Renviron.
acc_deis <- function(version = Sys.getenv("ACC_DEIS_VERSION")) {
  dir <- file.path(acc_root(), "_deis")
  enc <- if (nzchar(version)) {
    file.path(dir, sprintf("DEFUNCIONES_FUENTE_DEIS_2024_2026_%s.tar.xz.enc", version))
  } else {
    acc_latest(dir)
  }
  if (!file.exists(enc)) stop("DEIS version not found: ", enc)
  csv <- acc_data(file.path("_deis", basename(enc)))
  message(sprintf("[acc_deis] %s | md5 %s", basename(csv), unname(tools::md5sum(csv))))
  d <- data.table::fread(csv, sep = ";", encoding = "Latin-1", data.table = FALSE, showProgress = FALSE)
  names(d) <- iconv(names(d), "latin1", "UTF-8")  # fread does not re-encode the header ("AÑO")
  d
}

# Pack the newest DEFUNCIONES_FUENTE_DEIS_2024_2026_DDMMYYYY.zip dropped in _deis/ (zips are git-ignored)
# and print deaths per year next to the previous packed version.
acc_deis_update <- function(dir = file.path(acc_root(), "_deis")) {
  pat <- "^DEFUNCIONES_FUENTE_DEIS_2024_2026_([0-9]{8})\\.zip$"
  zip <- acc_latest(dir, pat)
  stamp <- sub(pat, "\\1", basename(zip))
  out <- file.path(dir, sprintf("DEFUNCIONES_FUENTE_DEIS_2024_2026_%s.tar.xz.enc", stamp))
  if (file.exists(out)) stop("Already packed: ", basename(out))
  prev <- tryCatch(acc_latest(dir), error = function(e) NULL)
  tmp <- file.path(tempdir(), paste0("deis_", stamp))
  csv <- utils::unzip(zip, exdir = tmp)
  csv <- csv[grepl("\\.csv$", csv)]
  if (length(csv) != 1L) stop("Expected one CSV inside ", basename(zip))
  d <- data.table::fread(csv, sep = ";", encoding = "Latin-1", data.table = FALSE, showProgress = FALSE)
  if (!identical(names(d)[2:5], c("FECHA_DEF", "SEXO_NOMBRE", "EDAD_TIPO", "EDAD_CANT"))) {
    stop("Unexpected columns in ", basename(csv), ": ", paste(names(d)[1:5], collapse = ", "))
  }
  counts <- data.frame(year = sort(unique(d[[1]])), new = as.vector(table(d[[1]])))
  if (!is.null(prev)) {
    p <- acc_deis(sub(".*_([0-9]{8})\\.tar\\.xz\\.enc$", "\\1", basename(prev)))
    counts$previous <- as.vector(table(factor(p[[1]], levels = counts$year)))
  }
  message(sprintf("[acc_deis_update] %s: %d rows, last death %s", basename(csv), nrow(d), max(d$FECHA_DEF)))
  print(counts, row.names = FALSE)
  acc_pack(csv, out)
  unlink(tmp, recursive = TRUE)
  invisible(out)
}

# Decrypt every per-file bundle in `dir` (e.g. "_bib", "_sessions") into `exdir` (git-ignored).
acc_unpack_all <- function(dir, exdir = file.path(dir, "local")) {
  for (f in list.files(dir, "\\.tar\\.xz\\.enc$", full.names = TRUE)) acc_unpack(f, exdir)
  invisible(exdir)
}
