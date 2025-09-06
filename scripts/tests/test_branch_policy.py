from pathlib import Path
import subprocess
import shutil
import tempfile
import unittest, os, sys

SCRIPT = Path(__file__).resolve().parents[2] / 'scripts' / 'branch_policy.py'


def run(cmd, cwd):
    return subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)


class TestBranchPolicy(unittest.TestCase):
    def test_branch_linear_sequence(self):
        tmp = tempfile.mkdtemp(prefix='bp_')
        keep = os.environ.get('KEEP_BP_TMP') == '1'
        try:
            run(['git','init','-q'], tmp)
            (Path(tmp)/'README.md').write_text('init','utf-8')
            run(['git','add','.'], tmp)
            run(['git','commit','-m','init'], tmp)
            run(['git','checkout','-b','feat/001-one'], tmp)
            (Path(tmp)/'one.txt').write_text('1','utf-8')
            run(['git','add','.'], tmp)
            run(['git','commit','-m','one'], tmp)
            run(['git','checkout','-b','feat/002-two'], tmp)
            (Path(tmp)/'two.txt').write_text('2','utf-8')
            run(['git','add','.'], tmp)
            run(['git','commit','-m','two'], tmp)
            env = os.environ.copy()
            env['BRANCH_POLICY_REPO_ROOT'] = tmp
            r = subprocess.run(['python', str(SCRIPT)], cwd=tmp, capture_output=True, text=True, env=env)
            if r.returncode != 0:
                print('DEBUG initial policy failure stdout:\n', r.stdout, file=sys.stderr)
                print('DEBUG initial policy failure stderr:\n', r.stderr, file=sys.stderr)
            self.assertEqual(r.returncode, 0, 'Initial policy check failed')
            run(['git','checkout','main'], tmp)
            run(['git','checkout','-b','feat/004-bad-gap'], tmp)
            branches = run(['git','branch','--list'], tmp).stdout
            feature_refs = run(['git','for-each-ref','--format=%(refname:short)','refs/heads/feat/'], tmp).stdout
            r2 = subprocess.run(['python', str(SCRIPT)], cwd=tmp, capture_output=True, text=True, env=env)
            self.assertEqual(r2.returncode, 1, f'Expected gap failure; stdout={r2.stdout} stderr={r2.stderr}')
            low = (r2.stdout + '\n' + r2.stderr).lower()
            self.assertIn('missing previous sequence', low)
            self.assertIn('003', low)
        finally:
            if keep:
                print(f'KEPT TEMP REPO FOR DEBUG: {tmp}')
            else:
                shutil.rmtree(tmp, ignore_errors=True)

if __name__ == '__main__':
    unittest.main()
