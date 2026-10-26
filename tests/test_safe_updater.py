"""Offline Windows integration tests for the OpenManus updater.

Creates a local bare Git remote; never touches the user's OpenManus checkout,
downloads dependencies, contacts an API, or needs an Ollama installation.
"""
from __future__ import annotations

import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

SCRIPTS = Path(__file__).resolve().parents[1] / "scripts"
CAN_RUN = bool(shutil.which("powershell") and shutil.which("git"))


@unittest.skipUnless(CAN_RUN, "Requires Windows PowerShell and Git")
class TestSafeUpdater(unittest.TestCase):
    def setUp(self):
        self.work = tempfile.TemporaryDirectory(prefix="openmanus-updater-")
        base = Path(self.work.name)
        self.remote = base / "remote.git"
        self.seed = base / "seed"
        self.target = base / "OpenManus"
        self.git("init", "--bare", "--initial-branch=main", self.remote)
        self.git("clone", self.remote, self.seed)
        self.git("config", "user.name", "Test Agent", cwd=self.seed)
        self.git("config", "user.email", "local@example.invalid", cwd=self.seed)
        (self.seed / "main.py").write_text("print('v1')\n", encoding="utf-8")
        self.git("add", "main.py", cwd=self.seed)
        self.git("commit", "-m", "initial", cwd=self.seed)
        self.git("push", "-u", "origin", "HEAD", cwd=self.seed)
        self.git("clone", self.remote, self.target)

    def tearDown(self):
        self.work.cleanup()

    @staticmethod
    def git(*args, cwd=None):
        return subprocess.run(
            ["git", *[str(x) for x in args]], cwd=cwd, capture_output=True,
            text=True, check=True,
        ).stdout.strip()

    def update(self):
        return subprocess.run(
            ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File",
             str(SCRIPTS / "update-openmanus.ps1"), "-RepoDir", str(self.target),
             "-SkipDependencies"],
            capture_output=True, text=True, encoding="utf-8", errors="replace",
        )

    def test_clean_working_tree_fast_forwards_from_local_remote(self):
        (self.seed / "main.py").write_text("print('v2')\n", encoding="utf-8")
        self.git("add", "main.py", cwd=self.seed)
        self.git("commit", "-m", "v2", cwd=self.seed)
        expected = self.git("rev-parse", "HEAD", cwd=self.seed)
        self.git("push", cwd=self.seed)

        process = self.update()
        self.assertEqual(process.returncode, 0, process.stdout + process.stderr)
        self.assertEqual(self.git("rev-parse", "HEAD", cwd=self.target), expected)
        self.assertIn("v2", (self.target / "main.py").read_text(encoding="utf-8"))

    def test_local_edits_are_never_overwritten(self):
        base_sha = self.git("rev-parse", "HEAD", cwd=self.target)
        path = self.target / "main.py"
        path.write_text("private local change\n", encoding="utf-8")

        process = self.update()
        self.assertNotEqual(process.returncode, 0)
        self.assertEqual(self.git("rev-parse", "HEAD", cwd=self.target), base_sha)
        self.assertEqual(path.read_text(encoding="utf-8"), "private local change\n")
        self.assertIn("local modifications", process.stdout + process.stderr)

    def test_untracked_files_are_protected(self):
        (self.target / "scratch.txt").write_text("do not remove\n", encoding="utf-8")

        process = self.update()
        self.assertNotEqual(process.returncode, 0)
        self.assertTrue((self.target / "scratch.txt").exists())


if __name__ == "__main__":
    unittest.main()
