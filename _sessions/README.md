# Codex and Claude Code conversation backups

Run `_tools/chat_sessions.py` from the project root with Python 3.9+ and Rscript from the project renv environment. No new packages are needed. Substitute `python3` where appropriate. If Rscript is not on PATH, set `ACC_RSCRIPT` in your local shell configuration, or pass `--rscript` before the subcommand. Never put machine-specific executable paths in shared files.

## Secret and storage

Every backup and every recovery requires `ACC_DATA_KEY`, supplied through the same local R environment used for data bundles (see [installation](../INSTALL.md)). The GitHub repository secret is not automatically available on your computer. The key is never a command argument and is never included in a backup.

The helper reuses `acc_pack()` and its authenticated ACC1 encryption. Only `.tar.xz.enc` bundles and `.md5.csv` manifests belong in git. Conversation content, original working directories and the associated git commit are inside the encrypted archive. Public filenames expose the agent, session ID and snapshot digest; sidecars expose member names, sizes and hashes, not conversation text. The key gives access to the entire conversation, including any sensitive material previously pasted into it.

Recovery authenticates before reading the TAR, rejects links and unsafe archive members, verifies hashes for new snapshots, and refuses to overwrite a different local transcript. Temporary plaintext is removed on normal completion or handled errors. Recovery installs a **local plaintext history** because the agent needs it to resume; anyone with access to that OS account can then read it without the backup key. An OS crash may leave temporary plaintext; use normal disk/account protection. These are encrypted backups, not an application login barrier.

## Terminal use with automatic backup on exit

```bash
python _tools/chat_sessions.py run codex
python _tools/chat_sessions.py run claude
```

Arguments after the agent name are forwarded, for example `run codex resume SESSION_ID`. The wrapper checks encryption setup before launching, then saves changed JSONL conversations whose recorded working directory is this project root. It does not collect other projects. A file changed during copying is rejected. A killed wrapper or machine shutdown cannot guarantee a final backup. Conversations started directly in the desktop app, IDE or another terminal do not pass through this wrapper.

## Selected desktop or remote conversation

On the host where the conversation is stored, obtain its actual session UUID, then run:

```bash
python _tools/chat_sessions.py backup codex SESSION_ID
python _tools/chat_sessions.py backup claude SESSION_ID
```

Replace `SESSION_ID`; do not guess it from a title. Codex defaults to `CODEX_HOME` or the OS user's `.codex`; Claude defaults to `CLAUDE_CONFIG_DIR` or `.claude`. `--home` before the subcommand overrides the agent home for isolated testing or recovery. A remote session must be backed up on its execution host, not on the phone or computer displaying it.

Snapshots go to `_sessions/codex/` or `_sessions/claude/`. An unchanged snapshot verifies the existing encrypted copy instead of creating another. A new transcript or git commit creates a new snapshot. Only the selected transcript and Claude's direct subagent JSONL companions are included; credentials, settings, global SQLite databases, attachments and code files are not bundled. Git carries the code separately. The recorded commit is provenance, not an automatic checkout or a backup of uncommitted code.

Commit the printed bundle and its `.md5.csv`, then push through the project's ordinary git workflow. The tool does not commit or push unrelated work. No background service or scheduled upload is installed.

## Recover on another machine

```bash
git pull --ff-only
python _tools/chat_sessions.py list
python _tools/chat_sessions.py restore _sessions/PROVIDER/BUNDLE.tar.xz.enc
```

Use the exact bundle path from `list`. Listing paths requires no key; recovery always requires it, even after a previous successful recovery. Older Claude bundles directly in `_sessions/` remain readable with this command.

From the project root, use the command printed after recovery:

```bash
codex resume SESSION_ID -C .
claude --resume SESSION_ID
```

Codex installs the intact rollout under `sessions/imported` and rebuilds its local history index. Claude installs the transcript and direct subagent histories in the project directory encoded for the current machine. Identical files are accepted; differing files stop recovery. For an older snapshot of an existing ID, use a separate agent home and launch with that same home override. Do not overwrite a newer conversation.

## Compatibility and checks

Codex 0.163.0 on Windows was tested with synthetic legacy JSONL and JSONL migrated to paginated history: a fresh agent home recovered the same ID, both messages and the completed turn without copying SQLite. The legacy test also passed after restarting the server. Preserve the complete rollout; do not strip `history_mode`, IDs or ordinals. The [Codex app-server protocol](https://learn.chatgpt.com/docs/app-server) documents read/resume and history pagination.

Compressed `.jsonl.zst` files are preserved as opaque files; their native resume has not been validated here. Histories without a standalone complete rollout, archived sessions, missing external attachments, and future storage formats are outside this implementation. Claude byte-for-byte recovery is tested; interactive Claude resume and Windows-to-macOS/Linux recovery still need native checks.

```bash
python _tools/test_chat_sessions.py
Rscript _tools/test_acc_data.R
```

Tests use synthetic conversations and a synthetic key, covering both providers, repeated recovery, conflicting files, missing/wrong keys, corruption and unsafe TAR members. They do not read real conversations or require the team's secret.
