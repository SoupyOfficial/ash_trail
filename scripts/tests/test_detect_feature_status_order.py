import unittest, tempfile, textwrap, os, json, shutil
from pathlib import Path
import subprocess

SCRIPT = Path(__file__).resolve().parents[1] / 'detect_feature_status.py'

MATRIX = textwrap.dedent('''
version: 0.1.0
features:
  - id: alpha.first
    epic: a
    order: 2
    status: planned
    priority: P0
  - id: alpha.zero
    epic: a
    order: 1
    status: planned
    priority: P1
  - id: beta.one
    epic: b
    order: 1
    status: planned
    priority: P0
''')

class TestDetectFeatureStatusOrdering(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.mkdtemp(prefix='feat_order_')
        # minimal repo structure for script ROOT assumptions
        (Path(self.tmp)/'feature_matrix.yaml').write_text(MATRIX, 'utf-8')
        scripts_dir = Path(self.tmp)/'scripts'
        scripts_dir.mkdir(exist_ok=True)
        # copy script under test
        shutil.copyfile(SCRIPT, scripts_dir/'detect_feature_status.py')

    def tearDown(self):
        shutil.rmtree(self.tmp, ignore_errors=True)

    def run_script(self, *args):
        return subprocess.run(['python', 'scripts/detect_feature_status.py', *args], cwd=self.tmp, capture_output=True, text=True)

    def test_matrix_order_mode_prefers_order_field(self):
        r = self.run_script('--suggest-next', '--order-mode', 'matrix', '--json')
        self.assertEqual(r.returncode, 0, r.stderr)
        data = json.loads(r.stdout)
        # Expect alpha.zero (order=1) before alpha.first (order=2) though alpha.first has higher priority
        self.assertEqual(data['feature_id'], 'alpha.zero', f"Unexpected suggestion in matrix mode: {data}")

    def test_priority_mode_prefers_priority(self):
        r = self.run_script('--suggest-next', '--order-mode', 'priority', '--json')
        self.assertEqual(r.returncode, 0, r.stderr)
        data = json.loads(r.stdout)
        # alpha.first has P0 and should be chosen over alpha.zero (P1)
        self.assertEqual(data['feature_id'], 'alpha.first')

    def test_appearance_mode_uses_yaml_sequence(self):
        r = self.run_script('--suggest-next', '--order-mode', 'appearance', '--json')
        self.assertEqual(r.returncode, 0, r.stderr)
        data = json.loads(r.stdout)
        # First in YAML is alpha.first
        self.assertEqual(data['feature_id'], 'alpha.first')

if __name__ == '__main__':
    unittest.main()
