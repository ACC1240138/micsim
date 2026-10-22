"""Encrypted, selected-session backups for Codex and Claude Code (stdlib only)."""
import argparse
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import subprocess
import tarfile
import tempfile
import time

ROOT = next(p for p in Path(__file__).resolve().parents if (p / ".acc_root").is_file())
UUID = r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"


def session_id(value):
    if not re.fullmatch(UUID, value):
        raise ValueError("Expected a lowercase session UUID")
    return value


def agent_home(provider, home=None):
    if home:
        return Path(home).expanduser().resolve()
    variable = "CODEX_HOME" if provider == "codex" else "CLAUDE_CONFIG_DIR"
    return Path(os.environ.get(variable, str(Path.home() / ("." + provider)))).resolve()


def digest(data):
    return hashlib.sha256(data).hexdigest()


def crypto(action, source, target, rscript=None):
    executable = rscript or os.environ.get("ACC_RSCRIPT") or shutil.which("Rscript")
    if not executable:
        raise ValueError("Rscript not found: set ACC_RSCRIPT locally or use --rscript")
    subprocess.run([executable, str(ROOT / "_tools/session_crypto.R"), action,
                    str(source), str(target)], cwd=ROOT, check=True)


def collect(provider, sid, home):
    sid = session_id(sid)
    base = home / ("sessions" if provider == "codex" else "projects")
    matches = [p for p in base.rglob("*" + sid + "*") if p.is_file() and
               (re.fullmatch(r"rollout-.*-" + sid + r"\.jsonl(?:\.zst)?", p.name)
                if provider == "codex" else p.name == sid + ".jsonl")]
    if len(matches) != 1:
        raise ValueError("Expected one active standalone transcript for this ID. Archived histories "
                         "or histories without a complete rollout are not guessed.")
    source = matches[0]
    files = {source.name: source}
    if provider == "claude":
        companions = source.parent / sid / "subagents"
        for p in companions.rglob("*.jsonl"):
            if p.parent != companions:
                raise ValueError("Nested Claude subagent history is not supported")
            files[p.relative_to(source.parent).as_posix()] = p
    for p in files.values():
        if p.is_symlink() or not p.resolve().is_relative_to(base.resolve()):
            raise ValueError("Session files must stay inside the agent history directory")
    return files


def backup(provider, sid, home=None, rscript=None):
    files = collect(provider, sid, agent_home(provider, home))
    with tempfile.TemporaryDirectory(prefix="acc-session-") as temporary:
        stage = Path(temporary) / "session"
        stage.mkdir()
        hashes = {}
        for name, source in files.items():
            before = source.stat()
            data = source.read_bytes()
            after = source.stat()
            if (before.st_size, before.st_mtime_ns) != (after.st_size, after.st_mtime_ns):
                raise ValueError("Conversation changed during backup; retry when idle")
            target = stage / name
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(data)
            hashes[name] = digest(data)
        revision = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
        manifest = {"version": 1, "provider": provider, "id": sid, "commit": revision, "files": hashes}
        encoded = json.dumps(manifest, sort_keys=True).encode()
        (stage / "manifest.json").write_bytes(encoded)
        filename = f"{provider}-{sid}-{digest(encoded)[:16]}.tar.xz.enc"
        output = ROOT / "_sessions" / provider / filename
        # Always invoke crypto: an existing snapshot must not bypass the secret requirement.
        pending = Path(temporary) / filename
        crypto("pack", stage, pending, rscript)
        output.parent.mkdir(parents=True, exist_ok=True)
        if output.exists():
            verified = Path(temporary) / "existing.tar.xz"
            crypto("decrypt", output, verified, rscript)
            existing = read_archive(verified)
            if existing.get("session/manifest.json") != encoded:
                raise ValueError("Existing backup has a different manifest")
            unpack_manifest(existing)
        else:
            shutil.copyfile(pending, output.with_suffix(output.suffix + ".part"))
            os.replace(output.with_suffix(output.suffix + ".part"), output)
        shutil.copyfile(str(pending) + ".md5.csv", str(output) + ".md5.csv")
        print(output.relative_to(ROOT).as_posix())
        return output


def read_archive(archive):
    """Read regular files without ever extracting archive-controlled paths."""
    result = {}
    with tarfile.open(archive, "r:xz") as tar:
        for item in tar:
            name = PurePosixPath(item.name)
            if (name.is_absolute() or ".." in name.parts or "\\" in item.name
                    or ":" in item.name or item.name in result):
                raise ValueError("Unsafe or duplicate archive member")
            if item.isdir():
                continue
            if not item.isfile():
                raise ValueError("Links and special archive members are not allowed")
            result[item.name] = tar.extractfile(item).read()
    return result


def unpack_manifest(contents):
    if "session/manifest.json" not in contents:
        # Existing Claude backups contain one UUID.jsonl, with no envelope.
        if len(contents) != 1:
            raise ValueError("Unsupported legacy archive")
        name, data = next(iter(contents.items()))
        if not re.fullmatch(UUID + r"\.jsonl", name):
            raise ValueError("Unsupported legacy archive")
        return "claude", name[:-6], {name: data}
    manifest = json.loads(contents.pop("session/manifest.json"))
    if manifest.get("version") != 1 or manifest.get("provider") not in ("codex", "claude"):
        raise ValueError("Unsupported session manifest")
    provider, sid = manifest["provider"], session_id(manifest["id"])
    files = manifest["files"]
    if set(contents) != {"session/" + name for name in files}:
        raise ValueError("Archive and manifest disagree")
    restored = {}
    for name, checksum in files.items():
        valid = (re.fullmatch(r"rollout-.*-" + sid + r"\.jsonl(?:\.zst)?", name)
                 if provider == "codex" else
                 name == sid + ".jsonl" or re.fullmatch(sid + r"/subagents/[\w-]+\.jsonl", name))
        if not valid or "/" in name and provider == "codex":
            raise ValueError("Unexpected session filename")
        data = contents["session/" + name]
        if digest(data) != checksum:
            raise ValueError("Session checksum mismatch")
        restored[name] = data
    if not restored or provider == "claude" and sid + ".jsonl" not in restored:
        raise ValueError("Main transcript is missing")
    return provider, sid, restored


def restore(bundle, home=None, rscript=None):
    with tempfile.TemporaryDirectory(prefix="acc-session-") as temporary:
        archive = Path(temporary) / "session.tar.xz"
        crypto("decrypt", Path(bundle).resolve(), archive, rscript)
        provider, sid, files = unpack_manifest(read_archive(archive))
        base = agent_home(provider, home)
        if base.is_relative_to(ROOT):
            raise ValueError("Restore agent histories outside the repository")
        if provider == "codex":
            destination = base / "sessions" / "imported"
            existing = [p for folder in ("sessions", "archived_sessions")
                        for p in (base / folder).rglob("*" + sid + "*") if p.is_file()]
            expected = {destination / name for name in files}
            if any(p not in expected for p in existing):
                raise ValueError("This Codex session ID already exists; restore into a separate home")
        else:
            project = re.sub(r"[^A-Za-z0-9]", "-", str(ROOT))
            destination = base / "projects" / project
        targets = {destination / name: data for name, data in files.items()}
        for target, data in targets.items():
            if not target.resolve().is_relative_to(base):
                raise ValueError("Destination escapes agent home")
            if target.exists() and (target.is_symlink() or target.read_bytes() != data):
                raise ValueError("Refusing to overwrite an existing conversation")
        for target, data in targets.items():
            target.parent.mkdir(parents=True, exist_ok=True)
            if not target.exists():
                with target.open("xb") as stream:
                    stream.write(data)
        command = f"codex resume {sid} -C ." if provider == "codex" else f"claude --resume {sid}"
        print("Recovered. From this project root, run: " + command)
        if home:
            print("Use the same agent home override when launching the agent.")
        return provider, sid, list(targets)


def run_and_backup(provider, arguments, home=None, rscript=None):
    """Terminal entry point: back up changed project sessions when the agent exits."""
    base = agent_home(provider, home)
    folder = base / ("sessions" if provider == "codex" else "projects")
    before = {p: (p.stat().st_size, p.stat().st_mtime_ns) for p in folder.rglob("*.jsonl")}
    environment = os.environ.copy()
    if home:
        environment["CODEX_HOME" if provider == "codex" else "CLAUDE_CONFIG_DIR"] = str(base)
    executable = shutil.which(provider)
    if not executable:
        raise ValueError(provider + " executable not found")
    # Fail before launching a long session if R/key configuration is missing.
    with tempfile.TemporaryDirectory(prefix="acc-session-preflight-") as temporary:
        probe = Path(temporary) / "probe.txt"
        probe.write_text("session backup preflight", encoding="utf8")
        crypto("pack", probe, Path(temporary) / "probe.tar.xz.enc", rscript)
    try:
        result = subprocess.run([executable, *arguments], cwd=ROOT, env=environment)
    except KeyboardInterrupt:
        # subprocess.run waits for the interrupted child before unwinding its context.
        result = subprocess.CompletedProcess([executable, *arguments], 130)
    saved = set()
    for path in folder.rglob("*.jsonl"):
        stat = path.stat()
        if before.get(path) == (stat.st_size, stat.st_mtime_ns):
            continue
        with path.open(encoding="utf8") as stream:
            for line in stream:
                try:
                    row = json.loads(line)
                except ValueError:
                    continue
                metadata = row.get("payload", {}) if provider == "codex" else row
                cwd = metadata.get("cwd")
                sid = metadata.get("id") if provider == "codex" else metadata.get("sessionId")
                if cwd and sid and Path(cwd).resolve() == ROOT:
                    if re.fullmatch(UUID, sid) and sid not in saved:
                        backup(provider, sid, base, rscript)
                        saved.add(sid)
                    break
    if not saved:
        print("No changed project JSONL session found; no backup created.")
    return result.returncode


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--rscript", help="Local Rscript executable; otherwise ACC_RSCRIPT or PATH")
    parser.add_argument("--home", help="Agent home override, useful for isolated recovery")
    commands = parser.add_subparsers(dest="action", required=True)
    save = commands.add_parser("backup")
    save.add_argument("provider", choices=("codex", "claude"))
    save.add_argument("id", type=session_id)
    load = commands.add_parser("restore")
    load.add_argument("bundle")
    run = commands.add_parser("run", help="Run terminal agent, then back up changed project chats")
    run.add_argument("provider", choices=("codex", "claude"))
    run.add_argument("arguments", nargs=argparse.REMAINDER)
    commands.add_parser("list")
    args = parser.parse_args()
    if args.action == "backup":
        backup(args.provider, args.id, args.home, args.rscript)
    elif args.action == "restore":
        restore(args.bundle, args.home, args.rscript)
    elif args.action == "run":
        raise SystemExit(run_and_backup(args.provider, args.arguments, args.home, args.rscript))
    else:
        for path in sorted((ROOT / "_sessions").rglob("*.tar.xz.enc")):
            print(path.relative_to(ROOT).as_posix())


if __name__ == "__main__":
    started = time.monotonic()
    try:
        main()
    except (ValueError, OSError, subprocess.CalledProcessError, tarfile.TarError) as error:
        raise SystemExit(str(error))
    finally:
        print(f"Elapsed: {(time.monotonic() - started) / 60:.2f} min")
