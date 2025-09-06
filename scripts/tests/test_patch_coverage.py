import json
from pathlib import Path
import subprocess
import unittest

ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / 'scripts' / 'patch_coverage.py'

SAMPLE_LCOV = """TN:
SF:lib/foo.dart
DA:1,1
DA:2,0
DA:3,2
end_of_record
"""

SAMPLE_DIFF = """diff --git a/lib/foo.dart b/lib/foo.dart
index 000..111 100644
--- a/lib/foo.dart
+++ b/lib/foo.dart
@@ -1,0 +1,3 @@
+line1
+line2
+line3
"""

def write_files():
    cov_dir = ROOT / 'coverage'
    cov_dir.mkdir(exist_ok=True)
    (cov_dir / 'lcov.info').write_text(SAMPLE_LCOV, encoding='utf-8')
    (ROOT / 'tmp_patch.diff').write_text(SAMPLE_DIFF, encoding='utf-8')

def run_cmd(args):
    return subprocess.run(['python', str(SCRIPT)] + args, capture_output=True, text=True)

class TestPatchCoverage(unittest.TestCase):
    def test_patch_coverage(self):
        write_files()
        r = run_cmd(['--diff-file', 'tmp_patch.diff', '--threshold', '50'])
        self.assertEqual(r.returncode, 0)
        data = json.loads(r.stdout)
        self.assertEqual(data['changed_lines'], 3)
        self.assertEqual(data['covered_lines'], 2)
        self.assertTrue(60 <= data['patch_coverage_pct'] <= 70)


if __name__ == '__main__':
    unittest.main()
