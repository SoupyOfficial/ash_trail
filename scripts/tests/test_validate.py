import unittest
import yaml
from pathlib import Path
import sys

# Import the generator module functions directly by path without installing as a package.
ROOT = Path(__file__).resolve().parents[2]
SCRIPT_PATH = ROOT / 'scripts' / 'generate_from_feature_matrix.py'

# Exec the script in a temp module namespace to access validate
module_globals = {}
with open(SCRIPT_PATH, 'r', encoding='utf-8') as f:
    code = compile(f.read(), str(SCRIPT_PATH), 'exec')
exec(code, module_globals)

validate = module_globals['validate']
load_yaml = module_globals['load_yaml']

class TestValidate(unittest.TestCase):
    def test_valid_matrix(self):
        data = load_yaml()
        # Should not raise
        validate(data)

    def test_duplicate_feature_id(self):
        data = load_yaml()
        if not data.get('features'):
            self.skipTest('No features in matrix')
        # Introduce duplicate id
        data['features'].append(dict(data['features'][0]))
        with self.assertRaises(SystemExit):
            validate(data)

if __name__ == '__main__':
    unittest.main()
