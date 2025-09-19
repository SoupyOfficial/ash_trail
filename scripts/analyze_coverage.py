#!/usr/bin/env python3

# Analysis of coverage gaps to identify biggest opportunities

# Key files with 0% coverage that could impact overall score
zero_coverage_files = [
    {'file': 'reachability_local_datasource.dart', 'lines': 64},
    {'file': 'reachability_audit_report_model.g.dart', 'lines': 29},
    {'file': 'ui_element_model.g.dart', 'lines': 24},
    {'file': 'accessibility_foundation.dart', 'lines': 22},
    {'file': 'reachability_zone_model.g.dart', 'lines': 20},
    {'file': 'audit_summary_model.g.dart', 'lines': 16},
    {'file': 'share_service.dart', 'lines': 14},
    {'file': 'audit_recommendation_model.g.dart', 'lines': 14},
    {'file': 'get_audit_reports_use_case.dart', 'lines': 3},
    {'file': 'get_reachability_zones_use_case.dart', 'lines': 3},
    {'file': 'save_audit_report_use_case.dart', 'lines': 3}
]

# Low coverage files with high impact potential
low_coverage_high_impact = [
    {'file': 'logs_screen.dart', 'hit': 4, 'total': 115, 'pct': 3.48},
    {'file': 'home_widgets_repository_impl.dart', 'hit': 26, 'total': 93, 'pct': 27.96},
    {'file': 'reachability_zone_factory.dart', 'hit': 19, 'total': 61, 'pct': 31.15},
    {'file': 'home_widgets_local_datasource_impl.dart', 'hit': 11, 'total': 46, 'pct': 23.91}
]

total_zero_lines = sum(f['lines'] for f in zero_coverage_files)
print(f'Files with 0% coverage: {len(zero_coverage_files)} files, {total_zero_lines} lines')

print('\nBiggest opportunities (0% coverage):')
for f in sorted(zero_coverage_files, key=lambda x: x['lines'], reverse=True)[:5]:
    print(f'  {f["lines"]:2d} lines: {f["file"]}')

print('\nLow coverage, high impact files:')
for f in low_coverage_high_impact:
    missing_lines = f['total'] - f['hit']
    print(f'  {missing_lines:3d} lines missing ({f["pct"]:5.1f}%): {f["file"]}')

print('\nPotential coverage gain if we test these files:')
print(f'Zero coverage files: +{total_zero_lines} lines')
low_impact_lines = sum(f['total'] - f['hit'] for f in low_coverage_high_impact)
print(f'Low coverage files: +{low_impact_lines} additional lines possible')
print(f'Total potential: +{total_zero_lines + low_impact_lines} lines')

# Calculate what coverage % this could achieve
current_hit = 2879
current_total = 3834
potential_additional_hit = total_zero_lines + low_impact_lines

new_hit = current_hit + potential_additional_hit
new_total = current_total + 0  # Assuming no new lines added
new_coverage = (new_hit / current_total) * 100

print(f'\nCurrent coverage: {current_hit}/{current_total} = {(current_hit/current_total)*100:.1f}%')
print(f'Potential with all improvements: {new_hit}/{current_total} = {new_coverage:.1f}%')

# Calculate minimum needed to reach 80%
needed_for_80 = int(current_total * 0.8) - current_hit
print(f'Lines needed to reach 80%: {needed_for_80}')

print('\nRecommendations:')
print('1. Start with reachability_local_datasource.dart (64 lines, 0% coverage)')
print('2. Add tests for logs_screen.dart (111 missing lines)')
print('3. Test home_widgets_repository_impl.dart (67 missing lines)')
print('4. Focus on .g.dart files (generated code, easy to test)')