"""End-to-end checks for the local, no-network project generator."""

import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


REPO = Path(__file__).resolve().parents[1]
SCRIPT = REPO / "scripts" / "New-Project.ps1"
POWERSHELL = shutil.which("pwsh") or shutil.which("powershell") or shutil.which("powershell.exe")


@unittest.skipUnless(POWERSHELL, "PowerShell is required (provided by the Windows CI runner)")
class TestNewProjectScaffold(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="local-agent-factory-")
        self.addCleanup(self.temp.cleanup)
        self.workspace = Path(self.temp.name) / "projects"

    def run_script(self, name, template="general", *extra):
        return subprocess.run(
            [
                POWERSHELL,
                "-NoProfile",
                "-ExecutionPolicy",
                "Bypass",
                "-File",
                str(SCRIPT),
                "-ProjectName",
                name,
                "-Workspace",
                str(self.workspace),
                "-Template",
                template,
                *extra,
            ],
            cwd=REPO,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
        )

    def test_general_template_creates_a_project_brief_and_agent_rules(self):
        result = self.run_script("ResearchDesk")
        target = self.workspace / "ResearchDesk"
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertTrue((target / "AGENTS.md").is_file())
        self.assertTrue((target / ".cursor" / "rules" / "project.mdc").is_file())
        self.assertTrue((target / "docs" / "project-brief.md").is_file())
        self.assertEqual(
            (target / "project.json").read_text(encoding="utf-8"),
            '{\n  "name": "ResearchDesk",\n  "slug": "researchdesk",\n  "template": "general",\n  "generator": "local-agent/scripts/New-Project.ps1"\n}\n',
        )

    def test_web_template_has_keyboard_and_reduced_motion_basics(self):
        result = self.run_script("OpenStudio", "web")
        target = self.workspace / "OpenStudio"
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        html = (target / "index.html").read_text(encoding="utf-8")
        css = (target / "assets" / "css" / "styles.css").read_text(encoding="utf-8")
        self.assertIn('<html lang="es">', html)
        self.assertIn('class="skip-link"', html)
        self.assertIn('<main id="main"', html)
        self.assertIn(":focus-visible", css)
        self.assertIn("prefers-reduced-motion: reduce", css)
        self.assertNotIn("https://", html + css)

    def test_whatif_does_not_create_workspace_or_project(self):
        result = self.run_script("PreviewOnly", "general", "-WhatIf")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("What if:", result.stdout + result.stderr)
        self.assertFalse(self.workspace.exists())

    def test_nonempty_destination_is_preserved(self):
        destination = self.workspace / "KeepMe"
        destination.mkdir(parents=True)
        marker = destination / "important.txt"
        marker.write_text("preserve", encoding="utf-8")
        result = self.run_script("KeepMe")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(marker.read_text(encoding="utf-8"), "preserve")

    def test_initialize_git_is_optional_and_does_not_commit(self):
        if not shutil.which("git"):
            self.skipTest("Git is not installed")
        result = self.run_script("VersionedProject", "general", "-InitializeGit")
        target = self.workspace / "VersionedProject"
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertTrue((target / ".git").is_dir())
        self.assertFalse((target / ".git" / "index").exists())

    def test_project_name_cannot_escape_the_workspace(self):
        result = self.run_script("../Escape")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((Path(self.temp.name) / "Escape").exists())

    def test_python_template_executes_using_only_the_standard_library(self):
        result = self.run_script("PythonStarter", "python")
        target = self.workspace / "PythonStarter"
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        run = subprocess.run(
            [sys.executable, str(target / "main.py")],
            cwd=target,
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertEqual(run.returncode, 0, run.stdout + run.stderr)
        self.assertIn("'status': 'scaffolded'", run.stdout)
        self.assertEqual((target / "pyproject.toml").read_text(encoding="utf-8").count("dependencies = []"), 1)

    def test_node_template_has_a_test_command_and_no_runtime_dependencies(self):
        result = self.run_script("NodeStarter", "node")
        target = self.workspace / "NodeStarter"
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        package = __import__("json").loads((target / "package.json").read_text(encoding="utf-8"))
        self.assertEqual(package["scripts"]["test"], "node --test")
        self.assertEqual(package["type"], "module")
        self.assertNotIn("dependencies", package)
        self.assertTrue((target / "tests" / "project-status.test.js").is_file())

    def test_factory_has_no_automatic_install_or_network_command(self):
        source = SCRIPT.read_text(encoding="utf-8")
        for forbidden in ("Invoke-WebRequest", "Invoke-RestMethod", "pip install", "npm install", "Start-Process"):
            self.assertNotIn(forbidden.lower(), source.lower())


if __name__ == "__main__":
    unittest.main()
