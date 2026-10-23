"""Offline source-level safety contracts for the Windows OpenManus setup script.

These checks are NOT a substitute for parsing/executing the script in PowerShell.
"""

from pathlib import Path
import shutil
import subprocess
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "setup-openmanus.ps1"


class SetupContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.source = SCRIPT.read_text(encoding="utf-8")

    def test_single_script_and_closed_model_validator(self):
        self.assertEqual(self.source.count("param("), 1)
        self.assertEqual(self.source.count('Write-Host "OpenManus prepared'), 1)
        self.assertIn("if ($Model -notmatch '^[A-Za-z0-9][A-Za-z0-9._:/-]{0,127}$') {", self.source)
        self.assertNotIn("\n) {\n", self.source)

    def test_validate_before_clone_and_abort_failed_clone(self):
        self.assertLess(self.source.index("if ($Model -notmatch"), self.source.index("git clone --"))
        self.assertLess(self.source.index("Refusing to configure an existing folder"), self.source.index("git clone --"))
        self.assertIn('if ($LASTEXITCODE -ne 0) { throw "OpenManus clone failed', self.source)
        self.assertIn("Push-Location -LiteralPath $TargetDir", self.source)

    def test_existing_private_configuration_is_not_rewritten(self):
        self.assertIn("Existing config.toml preserved unchanged", self.source)
        self.assertIn("if (Test-Path -LiteralPath $configTarget -PathType Leaf)", self.source)
        self.assertIn("elseif (Test-Path -LiteralPath $configExample -PathType Leaf)", self.source)

    @unittest.skipUnless(shutil.which("powershell") or shutil.which("pwsh"), "PowerShell unavailable")
    def test_powershell_parser_reports_no_errors(self):
        shell = shutil.which("powershell") or shutil.which("pwsh")
        command = (
            "$tokens=$null;$errors=$null;"
            "[System.Management.Automation.Language.Parser]::ParseFile($args[0],[ref]$tokens,[ref]$errors)|Out-Null;"
            "if($errors.Count -gt 0){$errors|ForEach-Object{Write-Error $_.Message};exit 1}"
        )
        run = subprocess.run([shell, "-NoProfile", "-Command", command, str(SCRIPT)], capture_output=True, text=True)
        self.assertEqual(run.returncode, 0, run.stdout + run.stderr)


if __name__ == "__main__":
    unittest.main()
