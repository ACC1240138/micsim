"""Synthetic round trips and failure checks; never reads real conversations or keys."""
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import tarfile
import tempfile
import time
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("chat_sessions", Path(__file__).with_name("chat_sessions.py"))
sessions = importlib.util.module_from_spec(spec)
spec.loader.exec_module(sessions)
CODE_ROOT = sessions.ROOT
SID = "11111111-2222-4333-8444-555555555555"
TEST_KEY = "synthetic-session-test-key-not-a-real-secret"


class SessionTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="acc-session-test-")
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.repo = self.base / "project"
        self.repo.mkdir()
        subprocess.run(["git", "init", "-q", str(self.repo)], check=True)
        subprocess.run(["git", "-C", str(self.repo), "-c", "user.name=Test", "-c",
                        "user.email=test@example.invalid", "commit", "--allow-empty", "-qm", "fixture"], check=True)
        self.patch = patch.object(sessions, "ROOT", self.repo)
        self.patch.start()
        self.addCleanup(self.patch.stop)
        self.env = patch.dict(os.environ, {"ACC_DATA_KEY": TEST_KEY,
                                          "R_ENVIRON_USER": str(self.base / "absent.Renviron")})
        self.env.start()
        self.addCleanup(self.env.stop)
        original_crypto = sessions.crypto

        def crypto(*args):
            with patch.object(sessions, "ROOT", CODE_ROOT):
                return original_crypto(*args)
        self.crypto_patch = patch.object(sessions, "crypto", crypto)
        self.crypto_patch.start()
        self.addCleanup(self.crypto_patch.stop)

    def fixture(self, provider):
        home = self.base / (provider + "-source")
        if provider == "codex":
            filename = "rollout-2026-10-22T12-00-00-" + SID + ".jsonl"
            path = home / "sessions" / "2026" / filename
            data = {"type": "session_meta", "payload": {"id": SID, "cwd": "/old/project"}}
        else:
            path = home / "projects" / "old-project" / (SID + ".jsonl")
            data = {"sessionId": SID, "type": "user", "message": {"content": "private synthetic message"}}
        path.parent.mkdir(parents=True)
        path.write_text(json.dumps(data) + "\n", encoding="utf8")
        return home, path

    def test_both_providers_roundtrip_and_collision(self):
        for provider in ("codex", "claude"):
            home, source = self.fixture(provider)
            bundle = sessions.backup(provider, SID, home)
            self.assertNotIn(b"private synthetic message", bundle.read_bytes())
            self.assertEqual(bundle, sessions.backup(provider, SID, home))
            target_home = self.base / (provider + "-target")
            recovered_provider, sid, files = sessions.restore(bundle, target_home)
            self.assertEqual((recovered_provider, sid), (provider, SID))
            self.assertEqual(files[0].read_bytes(), source.read_bytes())
            sessions.restore(bundle, target_home)  # Identical recovery is safe.
            files[0].write_text("newer local conversation", encoding="utf8")
            with self.assertRaisesRegex(ValueError, "overwrite"):
                sessions.restore(bundle, target_home)
            self.assertEqual(files[0].read_text(), "newer local conversation")

    def test_key_required_wrong_key_tamper_and_existing_corruption(self):
        home, _ = self.fixture("codex")
        bundle = sessions.backup("codex", SID, home)
        target = self.base / "destination"
        for key in ("", "wrong-key"):
            with patch.dict(os.environ, {"ACC_DATA_KEY": key}):
                with self.assertRaises(subprocess.CalledProcessError):
                    sessions.restore(bundle, target)
            self.assertFalse(target.exists())
        data = bytearray(bundle.read_bytes())
        data[60] ^= 1
        bundle.write_bytes(data)
        with self.assertRaises(subprocess.CalledProcessError):
            sessions.restore(bundle, target)
        with self.assertRaises(subprocess.CalledProcessError):
            sessions.backup("codex", SID, home)
        self.assertFalse(target.exists())

    def test_archive_traversal_and_links(self):
        for name, kind in (("../escape", tarfile.REGTYPE), ("/absolute", tarfile.REGTYPE),
                           ("session/link", tarfile.SYMTYPE)):
            archive = self.base / "bad.tar.xz"
            with tarfile.open(archive, "w:xz") as tar:
                item = tarfile.TarInfo(name)
                item.type = kind
                item.linkname = "../escape"
                item.size = 1 if kind == tarfile.REGTYPE else 0
                tar.addfile(item, io.BytesIO(b"x") if item.size else None)
            with self.assertRaises(ValueError):
                sessions.read_archive(archive)

    def test_legacy_claude_archive(self):
        provider, sid, files = sessions.unpack_manifest({SID + ".jsonl": b"fixture"})
        self.assertEqual((provider, sid), ("claude", SID))
        self.assertEqual(files[SID + ".jsonl"], b"fixture")

    def test_terminal_wrapper_only_backs_up_changed_project_sessions(self):
        home = self.base / "run-home"

        interrupted = False

        def launch(*args, **kwargs):
            folder = home / "sessions"
            folder.mkdir(parents=True, exist_ok=True)
            for sid, cwd in ((SID, str(self.repo)),
                             ("aaaaaaaa-2222-4333-8444-555555555555", "/other/project")):
                row = {"type": "session_meta", "payload": {"id": sid, "cwd": cwd}}
                (folder / (sid + ".jsonl")).write_text(json.dumps(row) + "\n", encoding="utf8")
            if interrupted:
                raise KeyboardInterrupt
            return subprocess.CompletedProcess(args, 7)

        with patch.object(sessions, "crypto"), patch.object(sessions.shutil, "which", return_value="codex"), \
                patch.object(sessions.subprocess, "run", side_effect=launch), patch.object(sessions, "backup") as save:
            status = sessions.run_and_backup("codex", ["resume", SID], home)
            self.assertEqual(status, 7)
            save.assert_called_once_with("codex", SID, home, None)
            save.reset_mock()
            interrupted = True
            status = sessions.run_and_backup("codex", [], home)
            self.assertEqual(status, 130)
            save.assert_called_once_with("codex", SID, home, None)


if __name__ == "__main__":
    started = time.monotonic()
    try:
        unittest.main()
    finally:
        print(f"Elapsed: {(time.monotonic() - started) / 60:.2f} min")
