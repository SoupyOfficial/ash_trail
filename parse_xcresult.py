#!/usr/bin/env python3
import json, sys, subprocess

path = "/Volumes/Jacob-SSD/Projects/ash_trail/build/ios_results_1770680852004.xcresult"

# Step 1: Get top-level data
result = subprocess.run(
    ["xcrun", "xcresulttool", "get", "--legacy", "--format", "json", "--path", path],
    capture_output=True, text=True
)
data = json.loads(result.stdout)

# Metrics
metrics = data.get('metrics', {})
tests_count = metrics.get('testsCount', {}).get('_value', 'N/A')
failed_count = metrics.get('testsFailedCount', {}).get('_value', 'N/A')
print(f"Tests: {tests_count}, Failed: {failed_count}")

# Issues
issues = data.get('issues', {})
for k, v in issues.items():
    if k.startswith('_'):
        continue
    vals = v.get('_values', []) if isinstance(v, dict) else []
    for item in vals:
        msg = item.get('message', {}).get('_value', '')
        print(f"  Issue [{k}]: {msg[:300]}")

# Find testsRef
actions = data.get('actions', {}).get('_values', [])
tests_ref_id = None
for action in actions:
    title = action.get('title', {}).get('_value', '')
    result_val = action.get('result', {}).get('_value', '')
    print(f"Action: {title} | result: {result_val}")
    ar = action.get('actionResult', {})
    tr = ar.get('testsRef', {}).get('id', {}).get('_value', '')
    if tr:
        tests_ref_id = tr
        print(f"  testsRef: {tr}")

# Step 2: Get test plan details via testsRef
if tests_ref_id:
    result2 = subprocess.run(
        ["xcrun", "xcresulttool", "get", "--legacy", "--format", "json",
         "--path", path, "--id", tests_ref_id],
        capture_output=True, text=True
    )
    test_data = json.loads(result2.stdout)

    # Debug: show structure of test plan data
    def show_types(obj, depth=0, max_depth=10):
        if depth > max_depth:
            return
        if isinstance(obj, dict):
            typ = obj.get('_type', {}).get('_name', '')
            if typ and typ != 'Array' and typ != 'String' and typ != 'Int' and typ != 'Double':
                indent = '  ' * depth
                extra = ''
                name = obj.get('name', {}).get('_value', '')
                if name:
                    extra = f' name="{name}"'
                status = obj.get('testStatus', {}).get('_value', '')
                if status:
                    extra += f' status={status}'
                identifier = obj.get('identifier', {}).get('_value', '')
                if identifier:
                    extra += f' id={identifier}'
                ref = obj.get('summaryRef', {}).get('id', {}).get('_value', '')
                if ref:
                    extra += f' ref={ref[:30]}...'
                dur = obj.get('duration', {}).get('_value', '')
                if dur:
                    extra += f' dur={dur}s'
                print(f'{indent}[{typ}]{extra}')
            for k, v in obj.items():
                if k.startswith('_'):
                    continue
                if isinstance(v, dict):
                    show_types(v, depth + 1, max_depth)
                elif isinstance(v, list):
                    for item in v:
                        show_types(item, depth + 1, max_depth)
        elif isinstance(obj, list):
            for item in obj:
                show_types(item, depth, max_depth)

    show_types(test_data)

    def find_test_metadata(obj, depth=0):
        if isinstance(obj, dict):
            typ = obj.get('_type', {}).get('_name', '')
            if typ == 'ActionTestMetadata':
                name = obj.get('name', {}).get('_value', '')
                status = obj.get('testStatus', {}).get('_value', '')
                duration = obj.get('duration', {}).get('_value', '')
                ref = obj.get('summaryRef', {}).get('id', {}).get('_value', '')
                print(f"  TEST [{status}]: {name} ({duration}s) ref={ref}")
                # Get detailed summary for this test
                if ref:
                    result3 = subprocess.run(
                        ["xcrun", "xcresulttool", "get", "--legacy", "--format", "json",
                         "--path", path, "--id", ref],
                        capture_output=True, text=True
                    )
                    try:
                        summary = json.loads(result3.stdout)
                        find_failure_messages(summary)
                    except:
                        pass
            for k, v in obj.items():
                if not k.startswith('_'):
                    find_test_metadata(v, depth + 1)
        elif isinstance(obj, list):
            for item in obj:
                find_test_metadata(item, depth)

    def find_failure_messages(obj):
        if isinstance(obj, dict):
            typ = obj.get('_type', {}).get('_name', '')
            if typ == 'ActionTestActivitySummary':
                title = obj.get('title', {}).get('_value', '')
                if title and ('fail' in title.lower() or 'error' in title.lower()
                              or 'exception' in title.lower() or 'assertion' in title.lower()):
                    print(f"    ACTIVITY: {title[:300]}")
            if typ == 'ActionTestFailureSummary':
                msg = obj.get('message', {}).get('_value', '')
                filename = obj.get('fileName', {}).get('_value', '')
                line = obj.get('lineNumber', {}).get('_value', '')
                print(f"    FAILURE: {msg[:300]}")
                if filename:
                    print(f"      at {filename}:{line}")
            for k, v in obj.items():
                if not k.startswith('_'):
                    find_failure_messages(v)
        elif isinstance(obj, list):
            for item in obj:
                find_failure_messages(item)

    find_test_metadata(test_data)
else:
    print("No testsRef found")
