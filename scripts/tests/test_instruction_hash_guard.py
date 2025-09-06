import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent


def run(cmd):
    return subprocess.check_output(cmd, cwd=ROOT, text=True).strip()


class TestInstructionHashGuard(unittest.TestCase):
    def test_instruction_hash_print(self):
        out = run(['python', 'scripts/instruction_hash_guard.py', '--print'])
        self.assertEqual(len(out), 64)
        int(out, 16)

    def test_instruction_hash_expect_match(self):
        h = run(['python', 'scripts/instruction_hash_guard.py', '--print'])
        subprocess.check_call(['python', 'scripts/instruction_hash_guard.py', '--expect', h], cwd=ROOT)


if __name__ == '__main__':
    unittest.main()
