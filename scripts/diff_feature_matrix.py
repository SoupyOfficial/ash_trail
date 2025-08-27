#!/usr/bin/env python3
"""Diff current feature_matrix.yaml against previous git version.

Outputs Markdown summary of:
  - Added features
  - Removed features
  - Status transitions
  - Priority changes

Always exits 0 (intended for PR comments).
"""
from __future__ import annotations
import subprocess
import yaml
from pathlib import Path
from typing import Dict, Any

ROOT = Path(__file__).resolve().parent.parent
FILE = ROOT / "feature_matrix.yaml"


def read_yaml(text: str) -> Dict[str, Any]:
    return yaml.safe_load(text) if text.strip() else {}


def git_show(rev: str) -> str:
    try:
        return subprocess.check_output(["git", "show", f"{rev}:{FILE.relative_to(ROOT)}"], cwd=ROOT, text=True)
    except subprocess.CalledProcessError:
        return ""


def main():
    current_text = FILE.read_text(encoding="utf-8")
    prev_text = git_show("HEAD^")
    cur = read_yaml(current_text)
    prev = read_yaml(prev_text)
    cur_feats = {f['id']: f for f in cur.get('features', [])}
    prev_feats = {f['id']: f for f in prev.get('features', [])}

    added = sorted(set(cur_feats) - set(prev_feats))
    removed = sorted(set(prev_feats) - set(cur_feats))
    status_changes = []
    priority_changes = []
    for fid, f in cur_feats.items():
        if fid in prev_feats:
            ps = prev_feats[fid].get('status')
            cs = f.get('status')
            if ps != cs:
                status_changes.append((fid, ps, cs))
            pp = prev_feats[fid].get('priority')
            cp = f.get('priority')
            if pp != cp:
                priority_changes.append((fid, pp, cp))

    print("### Feature Matrix Diff\n")
    if added:
        print("**Added Features**")
        for fid in added:
            print(f"- {fid}: {cur_feats[fid].get('title')}")
        print()
    if removed:
        print("**Removed Features**")
        for fid in removed:
            print(f"- {fid}: {prev_feats[fid].get('title')}")
        print()
    if status_changes:
        print("**Status Transitions**")
        for fid, ps, cs in status_changes:
            print(f"- {fid}: {ps} -> {cs}")
        print()
    if priority_changes:
        print("**Priority Changes**")
        for fid, pp, cp in priority_changes:
            print(f"- {fid}: {pp} -> {cp}")
        print()
    if not any([added, removed, status_changes, priority_changes]):
        print("No changes detected.")


if __name__ == "__main__":
    main()
