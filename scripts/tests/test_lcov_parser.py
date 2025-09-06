import json
from pathlib import Path
import subprocess
import unittest

ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / 'scripts' / 'dev_assistant.py'

SAMPLE_LCOV = """TN:
SF:lib/example.dart
DA:1,1
DA:2,0
DA:3,3
end_of_record
"""

def write_sample_lcov(tmp_path: Path):
    cov_dir = ROOT / 'coverage'
    cov_dir.mkdir(exist_ok=True)
    (cov_dir / 'lcov.info').write_text(SAMPLE_LCOV, encoding='utf-8')


def run_cmd(args):
    return subprocess.run(['python', str(SCRIPT)] + args, capture_output=True, text=True)


class TestLcovParser(unittest.TestCase):
    def test_parse_lcov(self):
        write_sample_lcov(Path('.'))
        r = run_cmd(['test-coverage','--json'])
        self.assertIn(r.returncode, (0,1))
        data = json.loads(r.stdout)
        after = data['coverage_after']
        self.assertTrue(0 < after['line_coverage'] <= 100)
        self.assertEqual(after['lines_found'], 3)
        self.assertEqual(after['lines_hit'], 2)

if __name__ == '__main__':
    unittest.main()
