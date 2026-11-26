#!/usr/bin/env python3
"""Check expected original 24-run report coverage and consolidated exports.

Standard-library only. Does not execute MATLAB or validate numerical accuracy.
"""
import csv
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RESULTS = ROOT / '10 results'
errors = []
notes = []
with (ROOT / 'docs/scenario_index.csv').open(encoding='utf-8', newline='') as f:
    scenarios = list(csv.DictReader(f))
if len(scenarios) != 24:
    errors.append(f'Expected 24 manifest entries; got {len(scenarios)}.')
for row in scenarios:
    sid, case, az = row['ExperimentID'], row['Case'].lower(), row['Azimuth']
    stem = f'case_{case}_azimuth_{az}_{sid}_1'
    expected = [(RESULTS/'comparison'/f'physical_comparison_{stem}.txt')]
    expected += [RESULTS/'validation'/f'{kind}_{stem}.txt' for kind in ('geodesic','brachistochrone','leastaction')]
    expected += [RESULTS/'figures'/f'sphere_curves_{stem}.png']
    for p in expected:
        if not p.is_file(): errors.append(f'Missing: {p.relative_to(ROOT)}')
    for p in expected[1:4]:
        if p.is_file() and 'Overall:' not in p.read_text(errors='replace'):
            errors.append(f'Unexpected validation-report format: {p.relative_to(ROOT)}')

base = RESULTS/'comparison'
stem='all_base_thesis_variations_v1'
for kind, expected in [('physical',24),('validation',24),('quadrature',48)]:
    f=base/f'{kind}_summary_{stem}.csv'
    if f.is_file():
        with f.open(encoding='utf-8-sig',newline='') as src:
            table=list(csv.DictReader(src))
        if len(table) != expected:
            errors.append(f'INCOMPLETE GENERATED SUMMARY: {f.name} has {len(table)}, expected {expected}.')
        else:
            notes.append(f'Full {kind} summary: {len(table)} rows.')
    else:
        notes.append(f'Full {kind} CSV not yet generated. Run main.m for all 24 scenarios.')
mat=base/f'all_experiments_{stem}.mat'
if not mat.is_file():
    notes.append('Full batch MAT file not yet generated. Run main.m and verify runThese=1:24.')
else:
    notes.append('MAT exists; this script does not inspect its internal run count.')

print('Archive audit:')
print(f'  Manifest scenarios: {len(scenarios)}')
print(f'  Physical reports: {len(list((RESULTS/"comparison").glob("physical_comparison_*.txt")))}')
for kind in ['geodesic','brachistochrone','leastaction']:
    print(f'  {kind} validation reports: {len(list((RESULTS/"validation").glob(kind+"_*.txt")))}')
print(f'  Published sphere-curve PNGs: {len(list((RESULTS/"figures").glob("sphere_curves_*.png")))}')
for line in notes: print('  NOTE:',line)
for line in errors: print('  ERROR:',line)
if errors: sys.exit(1)
print('  PASS: checked individual report and figure coverage.')
