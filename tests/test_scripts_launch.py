r"""Los lanzadores declarados en el README deben ejecutar su entrada real.

README.md linea 80-82 promete:

    powershell -ExecutionPolicy Bypass -File .\scripts\start-cli.ps1
    powershell -ExecutionPolicy Bypass -File .\scripts\start-web.ps1
    powershell -ExecutionPolicy Bypass -File .\scripts\start-mcp.ps1

Cada script debe poder recibir -TargetDir y arrancar el interprete del
entorno virtual sobre su entrada (main.py / web_run.py / run_mcp.py).
Este test usa un directorio temporal con un venv real y stubs que dejan
una marca, para no tocar nada del repo ni depender de Ollama ni de red.
"""

import os
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
SCRIPTS = REPO / "scripts"

LAUNCHERS = {
    "start-cli.ps1": "main.py",
    "start-web.ps1": "web_run.py",
    "start-mcp.ps1": "run_mcp.py",
}

STUB = (
    "import os, sys\n"
    "with open(os.environ['OPENMANUS_MARKER'], 'w', encoding='utf-8') as fh:\n"
    "    fh.write(os.path.basename(sys.argv[0]))\n"
)

PARSE_PROBE = r"""
$tokens = $null
$errors = $null
$ast = [System.Management.Automation.Language.Parser]::ParseFile($args[0], [ref]$tokens, [ref]$errors)
if ($errors.Count -gt 0) {
    foreach ($e in $errors) { Write-Output ("ERR line " + $e.Extent.StartLineNumber + ": " + $e.Message) }
    exit 1
}
if ($null -ne $ast.ParamBlock) {
    $names = @()
    foreach ($p in $ast.ParamBlock.Parameters) { $names += $p.Name.VariablePath.UserPath }
    Write-Output ("PARAMS " + ($names -join ","))
} else {
    Write-Output "PARAMS none"
}
exit 0
"""


def run_powershell(args, env=None):
    return subprocess.run(
        ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass"] + args,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        env=env,
    )


class TestDocumentedLaunchers(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.work = Path(tempfile.mkdtemp(prefix="openmanus_audit_"))
        cls.target = cls.work / "OpenManus"
        cls.target.mkdir(parents=True)
        subprocess.run(
            [
                sys.executable,
                "-m",
                "venv",
                "--without-pip",
                str(cls.target / ".venv"),
            ],
            check=True,
            capture_output=True,
        )
        for entry in LAUNCHERS.values():
            (cls.target / entry).write_text(STUB, encoding="utf-8")
        cls.marker = cls.work / "marker.txt"

    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(cls.work, ignore_errors=True)

    def test_launcher_starts_declared_entrypoint(self):
        for script, entry in LAUNCHERS.items():
            with self.subTest(script=script):
                if self.marker.exists():
                    self.marker.unlink()
                env = dict(os.environ, OPENMANUS_MARKER=str(self.marker))
                proc = run_powershell(
                    [
                        "-File",
                        str(SCRIPTS / script),
                        "-TargetDir",
                        str(self.target),
                    ],
                    env=env,
                )
                self.assertEqual(
                    proc.returncode,
                    0,
                    f"{script} salio con {proc.returncode}\n"
                    f"stdout: {proc.stdout}\nstderr: {proc.stderr}",
                )
                self.assertTrue(
                    self.marker.exists(),
                    f"{script} no ejecuto {entry}\n"
                    f"stdout: {proc.stdout}\nstderr: {proc.stderr}",
                )


class TestScriptParsing(unittest.TestCase):
    """README.md linea 74 declara setup-openmanus.ps1 como paso de preparacion.

    Un script con error de parseo no se puede ejecutar ni con parametros
    por defecto, asi que el contrato minimo es: parsea limpio y expone los
    parametros que su cabecera declara.
    """

    @classmethod
    def setUpClass(cls):
        cls.work = Path(tempfile.mkdtemp(prefix="openmanus_probe_"))
        cls.probe = cls.work / "probe.ps1"
        cls.probe.write_text(PARSE_PROBE, encoding="utf-8")

    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(cls.work, ignore_errors=True)

    def _probe(self, script):
        return run_powershell(["-File", str(self.probe), str(SCRIPTS / script)])

    def test_all_scripts_parse_clean(self):
        for script in sorted(p.name for p in SCRIPTS.glob("*.ps1")):
            with self.subTest(script=script):
                proc = self._probe(script)
                self.assertEqual(
                    proc.returncode,
                    0,
                    f"{script} no parsea\nstdout: {proc.stdout}",
                )

    def test_setup_script_declares_its_parameters(self):
        proc = self._probe("setup-openmanus.ps1")
        self.assertEqual(proc.returncode, 0, f"stdout: {proc.stdout}")
        self.assertIn("TargetDir", proc.stdout)
        self.assertIn("Model", proc.stdout)


if __name__ == "__main__":
    unittest.main()
