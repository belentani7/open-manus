"""Offline Windows integration checks for local OpenManus configuration safety.

Only temporary files and a fake Ollama executable are used. No cloning,
dependency installation, user configuration, models or network are touched.
"""
from __future__ import annotations

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "setup-openmanus.ps1"
CAN_RUN = os.name == "nt" and shutil.which("powershell") is not None


@unittest.skipUnless(CAN_RUN, "Requires Windows PowerShell")
class TestSafeLocalConfiguration(unittest.TestCase):
    def setUp(self):
        self.work = tempfile.TemporaryDirectory(prefix="openmanus-config-")
        root = Path(self.work.name)
        self.target = root / "OpenManus with spaces"
        config = self.target / "config"
        config.mkdir(parents=True)
        (config / "config.example.toml").write_text(
            '[llm]\nmodel = "upstream"\nbase_url = "https://example.invalid/v1"\n'
            'api_key = "example"\n',
            encoding="utf-8",
        )
        fake_bin = root / "fake-bin"
        fake_bin.mkdir()
        (fake_bin / "ollama.cmd").write_text("@echo off\r\nexit /b 0\r\n", encoding="utf-8")
        self.env = dict(os.environ)
        self.env["PATH"] = str(fake_bin) + os.pathsep + self.env.get("PATH", "")

    def tearDown(self):
        self.work.cleanup()

    def run_setup(self, model="qwen2.5:3b"):
        return subprocess.run(
            ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass",
             "-File", str(SCRIPT), "-TargetDir", str(self.target),
             "-Model", model, "-SkipDependencies"],
            capture_output=True, text=True, encoding="utf-8",
            errors="replace", env=self.env,
        )

    def test_existing_private_config_is_byte_for_byte_preserved(self):
        path = self.target / "config" / "config.toml"
        original = b'[llm]\r\napi_key = "PRIVATE-DO-NOT-CHANGE"\r\nmodel = "custom"\r\n'
        path.write_bytes(original)
        result = self.run_setup()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(path.read_bytes(), original)

    def test_new_config_uses_requested_local_model(self):
        path = self.target / "config" / "config.toml"
        result = self.run_setup()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        value = path.read_text(encoding="utf-8-sig")
        self.assertIn('model = "qwen2.5:3b"', value)
        self.assertIn('base_url = "http://localhost:11434/v1"', value)
        self.assertIn('api_key = "ollama"', value)

    def test_invalid_model_is_rejected_before_writing_config(self):
        path = self.target / "config" / "config.toml"
        result = self.run_setup('invalid"\napi_key = "external')
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(path.exists())


if __name__ == "__main__":
    unittest.main()
