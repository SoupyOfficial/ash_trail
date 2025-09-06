import unittest
import yaml
from pathlib import Path
import sys

# Import the generator module functions directly by path without installing as a package.
ROOT = Path(__file__).resolve().parents[2]
SCRIPT_PATH = ROOT / 'scripts' / 'generate_from_feature_matrix.py'

# Exec the script in a temp module namespace to access validate
module_globals = {'__file__': str(SCRIPT_PATH)}
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

    def test_invalid_enum_status(self):
        data = load_yaml()
        feats = data.get('features') or []
        if not feats:
            self.skipTest('No features in matrix')
        # Set first feature status to invalid value
        feats[0]['status'] = '__not_a_valid_status__'
        with self.assertRaises(SystemExit):
            validate(data)

    def test_duplicate_index_name(self):
        data = load_yaml()
        ents = data.get('entities') or []
        if not ents:
            self.skipTest('No entities in matrix')
        # Find or create indexes list
        ent = ents[0]
        existing = ent.setdefault('indexes', [])
        # If empty, add a base index
        if not existing:
            existing.append({'name': 'idx_a', 'fields': ['id']})
        # Duplicate first index name
        existing.append({'name': existing[0]['name'], 'fields': existing[0].get('fields', [])})
        with self.assertRaises(SystemExit):
            validate(data)

    def test_invalid_priority(self):
        data = load_yaml()
        feats = data.get('features') or []
        if not feats:
            self.skipTest('No features in matrix')
        feats[0]['priority'] = '__not_a_valid_priority__'
        with self.assertRaises(SystemExit):
            validate(data)

    def test_duplicate_epic_order(self):
        data = load_yaml()
        feats = data.get('features') or []
        if not feats:
            self.skipTest('No features in matrix')
        # Attempt to find two features in same epic; if not, clone one to induce duplicate order
        epic_groups = {}
        for f in feats:
            epic = f.get('epic')
            order = f.get('order')
            if epic is not None and order is not None:
                epic_groups.setdefault(epic, {}).setdefault(order, []).append(f)
        duplicate_preexisting = any(len(v) > 1 for grp in epic_groups.values() for v in grp.values())
        if duplicate_preexisting:
            # Already invalid; skip to avoid failing for the wrong reason
            self.skipTest('Matrix already has duplicate epic order; test not applicable')
        # Choose a feature with defined epic/order
        target = None
        for f in feats:
            if f.get('epic') is not None and f.get('order') is not None:
                target = f
                break
        if not target:
            self.skipTest('No feature with epic+order to duplicate')
        clone = dict(target)
        # Ensure unique id to avoid the duplicate id failure path
        existing_ids = {f['id'] for f in feats if 'id' in f}
        i = 0
        while True:
            new_id = f"dup_epic_order_{i}"
            if new_id not in existing_ids:
                break
            i += 1
        clone['id'] = new_id
        feats.append(clone)
        with self.assertRaises(SystemExit):
            validate(data)

    def test_duplicate_entity_name(self):
        data = load_yaml()
        ents = data.get('entities') or []
        if len(ents) < 1:
            self.skipTest('No entities to duplicate')
        dup = dict(ents[0])
        # Ensure we don't trigger other failures first
        ents.append(dup)
        with self.assertRaises(SystemExit):
            validate(data)

    def test_invalid_index_missing_name(self):
        data = load_yaml()
        ents = data.get('entities') or []
        if len(ents) < 1:
            self.skipTest('No entities present')
        ent = ents[0]
        idxs = ent.setdefault('indexes', [])
        # Add invalid index without name
        idxs.append({'fields': ['id']})
        with self.assertRaises(SystemExit):
            validate(data)

if __name__ == '__main__':
    unittest.main()
