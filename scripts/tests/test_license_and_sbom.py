import json
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent


class TestLicenseAndSbom(unittest.TestCase):
    def test_license_check_runs(self):
        subprocess.check_call(['python', 'scripts/license_check.py'], cwd=ROOT)

    def test_sbom_generation(self):
        out_file = ROOT / 'build' / 'sbom.cdx.json'
        if out_file.exists():
            out_file.unlink()
        subprocess.check_call(['python', 'scripts/sbom_generate.py'], cwd=ROOT)
        self.assertTrue(out_file.exists())
        data = json.loads(out_file.read_text())
        self.assertEqual(data['bomFormat'], 'CycloneDX')
        self.assertIn('components', data)
        self.assertIsInstance(data['components'], list)


if __name__ == '__main__':
    unittest.main()
