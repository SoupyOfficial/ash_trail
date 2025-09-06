import json
from pathlib import Path
import subprocess
import os
import unittest

ROOT = Path(__file__).resolve().parents[2]
ASSIST = ROOT / 'scripts' / 'dev_assistant.py'


def run(args, env=None):
    return subprocess.run(['python', str(ASSIST)] + args, capture_output=True, text=True, env=env)


class TestDevCycleManifest(unittest.TestCase):
    def test_dev_cycle_manifest_skip_tests(self):
        env = os.environ.copy()
        env['DEV_ASSISTANT_SKIP_TOOL_CHECKS'] = '1'
        cov_dir = ROOT / 'coverage'
        cov_dir.mkdir(exist_ok=True)
        (cov_dir / 'lcov.info').write_text('TN:\nSF:lib/sample.dart\nDA:1,1\nend_of_record\n', encoding='utf-8')
        r = run(['dev-cycle', '--json', '--skip-tests'], env=env)
        self.assertIn(r.returncode, (0,1))
        data = json.loads(r.stdout)
        self.assertIn('manifest', data)
        manifest_path = ROOT / data['manifest']
        self.assertTrue(manifest_path.exists())
        manifest_json = json.loads(manifest_path.read_text(encoding='utf-8'))
        self.assertEqual(manifest_json['command'], 'dev-cycle')
        self.assertTrue(manifest_json['tests_passed'])
        self.assertIsNotNone(manifest_json['coverage_after'])

if __name__ == '__main__':
    unittest.main()
