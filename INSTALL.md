# Installing `micsim` on a new computer

Total time: about 20 minutes. You need R ≥ 4.4, git, Positron (or RStudio) and Quarto.

## 1. Clone (do not download the ZIP)

```bash
cd ~/Documents
git clone https://github.com/ACC1240138/micsim.git
cd micsim
```

## 2. Packages with renv (~10–15 min)

Open the `micsim` folder in Positron. renv activates itself.

```r
renv::restore(prompt = FALSE)   # installs the exact versions in renv.lock
renv::isolate()                 # optional: copies packages into the project (~1-2 GB)
renv::status()                  # must report no issues
```

- Do **not** run `renv::init()` (the project already exists) or `renv::snapshot()` (only after deliberately adding a package, and then commit `renv.lock`).
- If `snapshot()` leaves you with an `renv.lock` showing `-> *`, discard it with `git checkout -- renv.lock`.

## 3. Data key (~2 min)

The key is in the password manager. It is the same on every computer: do not generate a new one.

```r
usethis::edit_r_environ()
```

Add `ACC_DATA_KEY=...`, leave a blank line at the end, save and restart R (Session → Restart R). Then:

```r
nzchar(Sys.getenv("ACC_DATA_KEY"))                                       # TRUE
substr(openssl::sha256(Sys.getenv("ACC_DATA_KEY")), 1, 8)                # fingerprint: must match the other PCs
```

Never type the key into a terminal, a script or a chat.

## 4. Checks (~2 min, from the repository root, in a new terminal)

```bash
Rscript _tools/test_acc_data.R    # acc_data tests: PASS
Rscript _tools/check_bundles.R    # every bundle [OK]
Rscript _tools/smoke_data.R       # smoke_data: PASS
```

- If **all** bundles fail in `check_bundles`, the key is wrong.
- If **only some** fail, the files were damaged while cloning: check `git config core.autocrlf` and clone again.

## 5. Optional

```r
source("_tools/acc_data.R")
acc_unpack_all("_bib")   # PDFs -> _bib/local/ (ignored by git)
```

Claude Code chats (so they show up in `/resume` when you open Claude Code in `micsim`). Run from the repository root:

```r
# Claude Code keeps chats in <home>/.claude/projects/<clone path with non-alphanumerics as "-">.
# On Windows R's "~" is Documents, so use USERPROFILE (HOME on macOS/Linux).
home <- Sys.getenv(if (.Platform$OS.type == "windows") "USERPROFILE" else "HOME")
p <- file.path(home, ".claude", "projects", gsub("[^A-Za-z0-9]", "-", normalizePath(getwd())))
dir.create(p, showWarnings = FALSE, recursive = TRUE)
acc_unpack_all("_sessions", p)
```

## 6. Pushing from a computer with another GitHub account

Inside `micsim` only (no `--global`), one command per line; Windows `cmd` does not accept `#` comments:

```
git remote set-url origin https://ACC1240138@github.com/ACC1240138/micsim.git
git config user.name "ACC1240138"
git config user.email "173552303+ACC1240138@users.noreply.github.com"
```

The first `git push` opens the browser to sign in as ACC1240138. GitHub Desktop pushes with its own signed-in account, so use the terminal for this repo.