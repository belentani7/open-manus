"""Updating an OpenManus checkout must preserve local user changes."""

import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "update-openmanus.ps1"


@unittest.skipUnless(shutil.which("git") and shutil.which("powershell"), "requires Git and Windows PowerShell")
class UpdateSafetyTests(unittest.TestCase):
    def test_uncommitted_files_block_update_without_loss(self):
        with tempfile.TemporaryDirectory() as tmp:
            repo = Path(tmp) / "OpenManus"
            repo.mkdir()
            subprocess.run(["git", "init", str(repo)], check=True, capture_output=True)
            marker = repo / "keep-me.txt"
            marker.write_text("unsaved human work", encoding="utf-8")

            result = subprocess.run(
                ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass",
                 "-File", str(SCRIPT), "-RepoDir", str(repo)],
                capture_output=True, text=True,
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(marker.read_text(encoding="utf-8"), "unsaved human work")
            self.assertIn("local changes", result.stderr + result.stdout)


if __name__ == "__main__":
    unittest.main()
