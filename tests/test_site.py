import json
import shutil
import subprocess
import unittest
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]


class TestSiteIntegrity(unittest.TestCase):
    def test_vercel_and_package_json_are_valid(self):
        pkg_path = REPO / "package.json"
        vercel_path = REPO / "vercel.json"
        self.assertTrue(pkg_path.exists(), "package.json must exist for @vercel/static-build")
        self.assertTrue(vercel_path.exists(), "vercel.json must exist")

        pkg = json.loads(pkg_path.read_text(encoding="utf-8"))
        vercel = json.loads(vercel_path.read_text(encoding="utf-8"))

        self.assertIn("build", pkg.get("scripts", {}))
        self.assertIn("lint", pkg.get("scripts", {}))
        self.assertIn("test", pkg.get("scripts", {}))
        self.assertEqual(vercel.get("version"), 2)

    def test_html_pages_have_required_metadata(self):
        pages = ["index.html", "404.html", "docs.html", "accesibilidad.html", "privacidad.html"]
        for name in pages:
            with self.subTest(page=name):
                path = REPO / name
                self.assertTrue(path.exists(), f"{name} must exist")
                content = path.read_text(encoding="utf-8")
                self.assertIn('<html lang="es">', content)
                self.assertIn('name="viewport"', content)
                self.assertIn("<title>", content)

    @unittest.skipUnless(shutil.which("node"), "Node.js is required for syntax check")
    def test_hero_js_syntax_is_valid(self):
        proc = subprocess.run(
            ["node", "--check", str(REPO / "hero.js")],
            capture_output=True,
            text=True,
        )
        self.assertEqual(proc.returncode, 0, proc.stderr)
