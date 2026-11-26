# Variational Path Problems on the Sphere — MATLAB Numerics

Numerical implementation and supporting evidence for the master's thesis
**_Variational Path Problems on the Sphere: Geodesic, Brachistochrone, and Least Action_**
by **Cameron L. Nolen**, California State University, Chico (Fall 2026).

The code solves and compares three variational path problems for a particle constrained to the surface of a sphere:

- **Geodesic (G):** stationary spherical length, with an analytical great-circle reference.
- **Brachistochrone (B):** stationary travel time under gravity, with reduced-quadrature reconstruction.
- **Least action (A):** stationary mechanical action at specified elapsed time, with reduced-quadrature reconstruction. The MATLAB variable names `LA` are preserved for compatibility with the thesis-era source.

The computations find particular numerical stationary branches; they do **not** establish global minimizers or exhaustive solution classifications.

## Quick start

1. Install MATLAB. The code uses `bvp4c`, `ode45`, `exportgraphics`, `fminbnd`, and `fminsearch`. The plotting implementation contains R2025a+-specific Figure Container behavior. Prefer MATLAB **R2025a or newer** when reproducing the full plotting workflow.
2. Download a **fixed release** of this repository and extract it, or clone the exact tagged commit.
3. In MATLAB, set the Current Folder to the repository root (the folder containing `main.m`).
4. Run `main` from the MATLAB Command Window. Root `main.m` adds the project subdirectories to the MATLAB search path and by default runs all **24** scenarios.
5. Inspect the generated files under `10 results/`, then run `python scripts/check_archive.py` from the repository root to inspect report/figure coverage and consolidated CSV counts.

**Be aware:** a full 24-scenario run may take substantial computation and overwrites files with matching versioned names in `10 results/`. Commit or copy the original archived results before rerunning. For an exploratory single scenario, set `runThese = 1;` in `main.m`; use a **distinct** `batchID` so partial results are not confused with the full thesis batch.

### MATLAB driver settings

The bundled `main.m` has been prepared as follows:

```matlab
runThese = 1:numel(scenarios);  % all 24 scenarios
batchID = "all_base_thesis_variations";
runVersion = 1;
runQuadratureChecks = true;
quadratureSegmentPoints = 1601;
batchSavePNG = true;
batchShowFigure = false;
```

`experiment_params.m` defines four baseline experiments (indices 1–4), eight controlled variations (5–12), and four experiments for each of the three original thesis parameter sets (13–24). The precise scenario order is recorded in `docs/scenario_index.csv`.

## Comparison protocols

**Case I — common endpoints and equal travel time.** The brachistochrone's computed travel time determines the duration of the least-action boundary-value problem. The trajectories can have different initial mechanical energies. The geodesic is a spatial, not gravity-driven, reference.

**Case II — common initial energy and event-defined endpoint.** A least-action initial-value problem (`ode45`) is integrated until the first qualifying loss-of-contact event. Its terminal point defines the common BVP endpoint; the brachistochrone is then solved with the same prescribed initial speed but not necessarily the same initial direction or travel time.

For both protocols, `bvp4c` solves the fixed-endpoint Euler–Lagrange equations. Additional routines check endpoint conditions, first integrals, the analytical geodesic, reduced quadratures, and sampled physical admissibility. See Chapter VI of the thesis for precise mathematical definitions, acceptance criteria, and limitations.

## Repository map

| Path | Contents |
| --- | --- |
| `main.m` | Batch driver and CSV/MAT consolidation |
| `base_params.m`, `experiment_params.m`, `parameters.m` | Default parameters, scenario manifest, legacy compatibility |
| `01 solvers/` | Case protocols, BVP and IVP solvers |
| `02 boundary_conditions/` | Boundary residual functions |
| `03 initial_guesses/` | Initial BVP guesses |
| `04 models/` | First-order systems derived from Euler–Lagrange equations |
| `05 postprocessors/` | Physical time and path reconstruction |
| `06 utilities/` | Batch execution, configuration, references, reporting |
| `07 metrics/` | Energies, momenta, radial reaction, speed |
| `08 validation/` | Numerical and physical validation routines |
| `09 plotting/` | Spherical plots, diagnostics, figure export |
| `10 results/comparison/` | Individual physical-comparison reports and consolidated CSV/MAT results |
| `10 results/validation/` | 72 individual validation reports (G/B/A for 24 scenarios) |
| `10 results/figures/` | 24 thesis-exported trajectory PNGs and horizontal legend PNG |
| `docs/` | Scenario index and supporting documentation |
| `scripts/` | Archive validation and MATLAB environment metadata helper |

## Numerical settings

Default physical values in `base_params.m` are `R = 10 m`, `g = 9.81 m/s^2`, and `m = 1 kg`. The initial BVP mesh has `N = 200` points with `RelTol = 1e-8` and `AbsTol = 1e-10`. The Case II IVP uses `ivpRelTol = 1e-9`, `ivpAbsTol = 1e-11`, and `ivpMaxTime = 10 s`. See `base_params.m` and the thesis for all other inputs; scenario overrides take precedence.

## Archived numerical results

The numerical archive is organized around the 24 experimental configurations defined in `experiment_params.m`. Individual physical-comparison reports, 72 per-model validation reports, and 24 thesis trajectory figures document the computed branches.

A complete batch produces the following consolidated records under `10 results/comparison/`:

```text
physical_summary_all_base_thesis_variations_v1.csv     (24 data rows)
validation_summary_all_base_thesis_variations_v1.csv   (24 data rows)
quadrature_summary_all_base_thesis_variations_v1.csv   (48 data rows)
all_experiments_all_base_thesis_variations_v1.mat      (runThese = 1:24)
```

The quadrature summary contains one record for each gravitational model per experiment. The MAT file provides the consolidated MATLAB results and batch metadata. Compare reproduced results with the archived records and the tables in Chapter VI of the thesis. Numerical agreement should be assessed using the reported tolerances and diagnostics rather than requiring bit-for-bit equality across MATLAB releases.

The optional command `python scripts/check_archive.py` checks report and figure coverage and consolidated CSV row counts using only the Python standard library. It does not execute MATLAB, inspect MAT contents, or independently verify numerical accuracy.

## Software environment record

The MATLAB release and installed product versions can be recorded by running:

```matlab
addpath('scripts');
write_environment_record
```

This creates `docs/matlab_environment.txt`. Consult the archived environment record, if included, for the software versions associated with the recorded computations.

## Archival release and citation

The project is hosted at [github.com/BigKingCam/variational-paths-sphere-matlab](https://github.com/BigKingCam/variational-paths-sphere-matlab). For reproducibility, use the fixed release or commit identified in Appendix C of the thesis rather than the evolving default branch.

Citation metadata is in [`CITATION.cff`](CITATION.cff). The fixed release should be cited together with the master's thesis, not as a substitute for it.

## License

Copyright © 2026 Cameron L. Nolen.

This project is licensed under the MIT License.
See the [LICENSE](LICENSE) file for details.
