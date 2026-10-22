# CLAUDE.md

Shared project instructions live in `AGENTS.md` (single source for Claude Code and Codex).

@AGENTS.md

## Claude-specific notes

- Machine-specific notes go in `CLAUDE.local.md` (untracked, one per computer). Never put them here.
- Handoff question (`AGENTS.md` §1): if the request does not say whether to append to the caveman handoff,
  ask it with AskUserQuestion as the very first tool call, before any other work.
- If `AGENTS.md` and a handoff disagree, follow the rules in `AGENTS.md` §1 and ask the user.
