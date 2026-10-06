# Instalar `micsim` en un computador nuevo

Tiempo total: unos 20 minutos. Necesitas R ≥ 4.4, git, Positron (o RStudio) y Quarto.

## 1. Clonar (no bajes el ZIP)

```bash
cd ~/Documents
git clone https://github.com/ACC1240138/micsim.git
cd micsim
```

## 2. Paquetes con renv (~10–15 min)

Abre la carpeta `micsim` en Positron. renv se activa solo.

```r
renv::restore(prompt = FALSE)   # installs the exact versions in renv.lock
renv::isolate()                 # optional: copies packages into the project (~1-2 GB)
renv::status()                  # must report no issues
```

- **No** corras `renv::init()` (el proyecto ya existe) ni `renv::snapshot()` (solo después de agregar un paquete a propósito, y luego commitea `renv.lock`).
- Si `snapshot()` te deja un `renv.lock` con `-> *`, descártalo con `git checkout -- renv.lock`.

## 3. Clave de los datos (~2 min)

La clave está en el gestor de contraseñas. Es la misma en todos los computadores: no generes una nueva.

```r
usethis::edit_r_environ()
```

Agrega `ACC_DATA_KEY=...`, deja una línea en blanco al final, guarda y reinicia R (Session → Restart R). Luego:

```r
nzchar(Sys.getenv("ACC_DATA_KEY"))                                       # TRUE
substr(openssl::sha256(Sys.getenv("ACC_DATA_KEY")), 1, 8)                # fingerprint: must match the other PCs
```

Nunca escribas la clave en la terminal, en un script ni en un chat.

## 4. Revisiones (~2 min, desde la raíz, en una terminal nueva)

```bash
Rscript _tools/test_acc_data.R    # acc_data tests: PASS
Rscript _tools/check_bundles.R    # every bundle [OK]
Rscript _tools/smoke_data.R       # smoke_data: PASS
```

- Si **todos** los paquetes fallan en `check_bundles`, la clave no es la correcta.
- Si fallan **solo algunos**, el archivo se dañó al clonar: revisa `git config core.autocrlf` y vuelve a clonar.

## 5. Opcional

```r
source("_tools/acc_data.R")
acc_unpack_all("_bib")                                       # PDFs -> _bib/local/ (ignored by git)
```

Chats de Claude Code (para verlos con `/resume` al abrir Claude Code en `micsim`). Corre desde la raíz del repo:

```r
# Claude Code stores chats in %USERPROFILE%\.claude\projects\<cwd with non-alphanumerics as "-">
# (on Windows R's "~" is Documents, so do not use "~/.claude")
p <- file.path(Sys.getenv("USERPROFILE"), ".claude", "projects",
               gsub("[^A-Za-z0-9]", "-", normalizePath(getwd())))
dir.create(p, showWarnings = FALSE, recursive = TRUE)
acc_unpack_all("_sessions", p)
```

En macOS/Linux usa `Sys.getenv("HOME")` en lugar de `USERPROFILE`.
