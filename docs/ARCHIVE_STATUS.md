# Archive status and provenance (25 November 2026)

## Verified from the uploaded archives

- `numerics_20261125_064731.zip`: complete MATLAB source files, `experiment_params.m` manifest with 24 scenarios, individual text reports for all 24 scenarios, three validation report types for all 24, and **one** numerical PNG.
- `thesis_20261125_041819.zip`: 24 thesis sphere-curve PNGs and a separate horizontal legend PNG. Those 25 images have been placed under `10 results/figures/` to preserve the figures actually included in the thesis source.
- The one numerical ZIP PNG differs in bytes from the identically named thesis-source PNG. It is preserved in `provenance/numerics_zip_figure/`. The thesis-source version is used under `10 results/figures/`.
- All 72 supplied individual validation reports say `Overall: PASS`. This is a report-status check, **not** independent execution or proof of accuracy.

## Critical discrepancy

Although the source ZIP's consolidated files were named `all_base_thesis_variations_v1`, the supplied physical and validation CSVs have **one data row**, the quadrature CSV has **two** (one scenario times two models), and the MAT file records `runThese=1`. These are **single-scenario artifacts**, not 24-scenario batch outputs.

Those four original files, unchanged, have been moved into `provenance/single_run_exports/`. This repository intentionally does not present them as complete batch outputs.

For a complete 24-run consolidated archive, execute the repository's `main.m` in MATLAB (`runThese = 1:numel(scenarios)`), then inspect the generated files under `10 results/comparison/` and confirm they have 24/24/48 CSV rows and a MAT run selection of 24. Do not replace the original provenance snapshot.

## Changes made for repository preparation

1. Changed the single line selecting scenarios in root `main.m` from the uploaded `runThese = 1` to `runThese = 1:numel(scenarios)`.
2. Kept the uploaded `main.m` byte-for-byte in `provenance/main_uploaded_20261125.m.txt`.
3. Removed only the autosave editor backup `09 plotting/plot_sphere_curves.asv` from the public source tree.
4. Added README, metadata, archive audit, environment-record helper, and file-integrity manifest.

No MATLAB numerical computations were rerun for this package. MATLAB installation/release and toolbox inventory have **not** been independently verified. Capture the real environment before publishing the fixed thesis release.
