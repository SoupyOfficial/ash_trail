#!/usr/bin/env python3

import os
import sys
from pathlib import Path

def parse_lcov_file(lcov_path):
    """Parse LCOV file and extract coverage data for each source file."""
    if not os.path.exists(lcov_path):
        print(f"Error: LCOV file not found at {lcov_path}")
        return {}
    
    coverage_data = {}
    current_file = None
    
    with open(lcov_path, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if line.startswith('SF:'):
                # Source file
                current_file = line[3:].replace('\\', '/')
                coverage_data[current_file] = {'lines_found': 0, 'lines_hit': 0}
            elif line.startswith('LF:'):
                # Lines found (total executable lines)
                if current_file:
                    coverage_data[current_file]['lines_found'] = int(line[3:])
            elif line.startswith('LH:'):
                # Lines hit (covered lines)
                if current_file:
                    coverage_data[current_file]['lines_hit'] = int(line[3:])
            elif line == 'end_of_record':
                current_file = None
    
    return coverage_data

def analyze_coverage():
    """Analyze coverage data and identify improvement opportunities."""
    script_dir = Path(__file__).parent
    repo_root = script_dir.parent
    lcov_path = repo_root / 'coverage' / 'lcov.info'
    
    coverage_data = parse_lcov_file(lcov_path)
    
    if not coverage_data:
        print("No coverage data found. Run 'flutter test --coverage' first.")
        return
    
    # Calculate file-level statistics
    file_stats = []
    total_lines_found = 0
    total_lines_hit = 0
    
    for file_path, data in coverage_data.items():
        lines_found = data['lines_found']
        lines_hit = data['lines_hit']
        
        if lines_found > 0:
            coverage_pct = (lines_hit / lines_found) * 100
            missing_lines = lines_found - lines_hit
            
            # Extract just the filename for cleaner display
            filename = os.path.basename(file_path)
            
            file_stats.append({
                'file': filename,
                'path': file_path,
                'hit': lines_hit,
                'total': lines_found,
                'missing': missing_lines,
                'pct': coverage_pct
            })
            
            total_lines_found += lines_found
            total_lines_hit += lines_hit
    
    # Sort by potential impact (files with most missing lines)
    file_stats.sort(key=lambda x: x['missing'], reverse=True)
    
    # Calculate overall coverage
    overall_coverage = (total_lines_hit / total_lines_found) * 100 if total_lines_found > 0 else 0
    
    # Identify zero coverage files
    zero_coverage_files = [f for f in file_stats if f['hit'] == 0]
    
    # Identify low coverage high impact files (< 50% coverage, > 20 missing lines)
    low_coverage_high_impact = [f for f in file_stats if f['pct'] < 50 and f['missing'] > 20 and f['hit'] > 0]
    
    # Display results
    print("=== COVERAGE ANALYSIS ===")
    print(f'Overall coverage: {total_lines_hit}/{total_lines_found} = {overall_coverage:.1f}%')
    
    if zero_coverage_files:
        total_zero_lines = sum(f['total'] for f in zero_coverage_files)
        print(f'\nFiles with 0% coverage: {len(zero_coverage_files)} files, {total_zero_lines} lines')
        
        print('\nBiggest opportunities (0% coverage):')
        for f in sorted(zero_coverage_files, key=lambda x: x['total'], reverse=True)[:10]:
            print(f'  {f["total"]:3d} lines: {f["file"]}')
    
    if low_coverage_high_impact:
        print('\nLow coverage, high impact files:')
        for f in low_coverage_high_impact[:10]:
            print(f'  {f["missing"]:3d} lines missing ({f["pct"]:5.1f}%): {f["file"]}')
    
    # Calculate potential improvements
    if zero_coverage_files or low_coverage_high_impact:
        total_zero_lines = sum(f['total'] for f in zero_coverage_files)
        total_low_coverage_missing = sum(f['missing'] for f in low_coverage_high_impact)
        
        print('\nPotential coverage gain:')
        if zero_coverage_files:
            print(f'Zero coverage files: +{total_zero_lines} lines')
        if low_coverage_high_impact:
            print(f'Low coverage files: +{total_low_coverage_missing} additional lines possible')
        
        potential_additional_hit = total_zero_lines + total_low_coverage_missing
        potential_new_coverage = ((total_lines_hit + potential_additional_hit) / total_lines_found) * 100
        
        print(f'Potential with improvements: {total_lines_hit + potential_additional_hit}/{total_lines_found} = {potential_new_coverage:.1f}%')
    
    # Calculate what's needed for 80%
    needed_for_80 = int(total_lines_found * 0.8) - total_lines_hit
    if needed_for_80 > 0:
        print(f'\nLines needed to reach 80%: {needed_for_80}')
        
        print('\nRecommendations:')
        count = 1
        remaining_needed = needed_for_80
        
        # Recommend zero coverage files first (biggest bang for buck)
        for f in sorted(zero_coverage_files, key=lambda x: x['total'], reverse=True):
            if remaining_needed <= 0:
                break
            print(f'{count}. Test {f["file"]} ({f["total"]} lines, 0% coverage)')
            remaining_needed -= f['total']
            count += 1
            if count > 5:  # Limit recommendations
                break
        
        # Then recommend low coverage files
        if remaining_needed > 0:
            for f in low_coverage_high_impact:
                if remaining_needed <= 0 or count > 5:
                    break
                print(f'{count}. Improve {f["file"]} ({f["missing"]} missing lines, {f["pct"]:.1f}% coverage)')
                remaining_needed -= f['missing']
                count += 1
    else:
        print(f'\n✅ Already above 80% coverage target!')

if __name__ == '__main__':
    analyze_coverage()