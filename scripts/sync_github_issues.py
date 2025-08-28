#!/usr/bin/env python3
"""Sync features from feature_matrix.yaml to GitHub issues.

Title format: [<epic>] <title> (<id>)
Labels: feature, epic:<epic>, priority:<priority>, status:<status>

Body section auto-managed between:
<!-- AUTOGEN:FEATURE_HEADER START -->
...generated content...
<!-- AUTOGEN:FEATURE_HEADER END -->

Dry run if GH_TOKEN not set.
"""
from __future__ import annotations
import os
import sys
import yaml
import requests
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FEATURE_MATRIX = ROOT / "feature_matrix.yaml"
REPO = os.environ.get("GITHUB_REPOSITORY")  # e.g. owner/name when in Actions
GH_TOKEN = os.environ.get("GH_TOKEN") or os.environ.get("REPO_TOKEN")

SESSION = requests.Session()
if GH_TOKEN:
    SESSION.headers["Authorization"] = f"Bearer {GH_TOKEN}"
SESSION.headers["Accept"] = "application/vnd.github+json"

API = f"https://api.github.com/repos/{REPO}" if REPO else None

START = "<!-- AUTOGEN:FEATURE_HEADER START -->"
END = "<!-- AUTOGEN:FEATURE_HEADER END -->"


def load_yaml():
    with FEATURE_MATRIX.open("r", encoding="utf-8") as f:
        return yaml.safe_load(f)


def get_all_issues():
    if not API:
        return []
    issues = []
    page = 1
    while True:
        r = SESSION.get(f"{API}/issues", params={"state": "all", "per_page": 100, "page": page})
        if r.status_code != 200:
            print(f"WARN: unable to list issues: {r.status_code} {r.text}")
            break
        batch = r.json()
        if not batch:
            break
        issues.extend(batch)
        page += 1
    return issues


def ensure_labels(epic: str, priority: str, status: str):
    needed = ["feature", f"epic:{epic}", f"priority:{priority}", f"status:{status}"]
    if not API or not GH_TOKEN:
        return needed
    # Create labels if missing (best effort)
    for label in needed:
        r = SESSION.get(f"{API}/labels/{label}")
        if r.status_code == 200:
            continue
        SESSION.post(f"{API}/labels", json={"name": label, "color": "ededed"})
    return needed


def build_autogen_section(feature):
    lines = [START]
    lines.append(f"ID: {feature['id']}")
    lines.append(f"Epic: {feature.get('epic')}")
    lines.append(f"Status: {feature.get('status')}")
    lines.append(f"Priority: {feature.get('priority')}")
    if feature.get('acceptance'):
        lines.append("")
        lines.append("Acceptance:")
        for a in feature['acceptance']:
            lines.append(f"- {a}")
    lines.append(END)
    return "\n".join(lines)


def upsert_issue(existing_map, feature, dry_run: bool):
    title = f"[{feature.get('epic')}] {feature.get('title')} ({feature.get('id')})"
    labels = ensure_labels(feature.get('epic'), feature.get('priority'), feature.get('status'))
    autogen = build_autogen_section(feature)
    body = autogen + "\n\n(Body outside AUTOGEN section is preserved.)"
    issue = existing_map.get(title)
    if issue:
        current_body = issue.get("body") or ""
        # Only update autogen section
        if START in current_body and END in current_body:
            pre = current_body.split(START)[0].rstrip()
            post = current_body.split(END)[-1].lstrip()
            new_body = pre + autogen + post
        else:
            new_body = autogen + "\n\n" + current_body
        if dry_run:
            print(f"DRY-RUN update issue #{issue['number']}: {title}")
        else:
            # Update labels & body (even if closed; do not reopen)
            SESSION.patch(f"{API}/issues/{issue['number']}", json={"body": new_body, "labels": labels})
            print(f"Updated issue #{issue['number']}: {title}")
    else:
        if dry_run:
            print(f"DRY-RUN create issue: {title}")
        else:
            r = SESSION.post(f"{API}/issues", json={"title": title, "body": body, "labels": labels})
            if r.status_code >= 300:
                print(f"Failed creating issue: {title} -> {r.status_code} {r.text}")
            else:
                print(f"Created issue: {title}")


def main():
    data = load_yaml()
    features = data.get("features", [])
    if not features:
        print("No features found.")
        return
    dry_run = not GH_TOKEN or not API
    if dry_run:
        print("Running in DRY-RUN mode (missing GH_TOKEN or REPO context).")
    issues = get_all_issues() if not dry_run else []
    existing_map = {i["title"]: i for i in issues}
    for feat in features:
        # Skip closed issue creation, but allow update of existing closed issue.
        upsert_issue(existing_map, feat, dry_run)


if __name__ == "__main__":
    if not REPO:
        print("WARNING: GITHUB_REPOSITORY not set; dry-run implied.")
    main()
