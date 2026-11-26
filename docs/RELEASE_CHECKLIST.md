# GitHub repository and thesis-release checklist

## Set up and publish repository

1. Create an empty **public** repository in GitHub, e.g. `variational-paths-sphere-matlab`. Do not initialize an additional README on GitHub; this package already contains one.
2. Unzip `variational_paths_sphere_repository.zip` into a working folder. In that folder, check `README.md`, `CITATION.cff`, `docs/ARCHIVE_STATUS.md` and `docs/scenario_index.csv`.
3. Review the copyright and license decision; add a `LICENSE` only after you choose reuse terms.
4. In a terminal from the repository root, initialize Git and publish the files:

```bash
git init
git add .
git commit -m "Archive MATLAB numerical experiments for master's thesis"
git branch -M main
git remote add origin https://github.com/OWNER/REPOSITORY.git
git push -u origin main
```

Replace `OWNER` and `REPOSITORY`. Authentication must be completed by the GitHub account owner. Alternatively, upload the extracted files using GitHub's file-upload interface while preserving folder names.

## Correct and verify the consolidated output discrepancy

- [ ] In MATLAB, run `main` with `runThese = 1:numel(scenarios);`, `runQuadratureChecks = true`, and `batchID = "all_base_thesis_variations"`.
- [ ] Check `physical_summary_...csv` has **24** rows, validation summary **24** rows, quadrature summary **48** rows.
- [ ] Open `all_experiments_...mat` in MATLAB and verify `runThese` contains 1:24 and `results` contains all 24 entries.
- [ ] Compare the outputs to the reported numerical tables; inspect any failed validation or quadrature check.
- [ ] Run `python scripts/check_archive.py`.
- [ ] Run `addpath('scripts'); write_environment_record` in MATLAB and commit `docs/matlab_environment.txt`.
- [ ] If rerunning changes published figure PNGs, decide whether to retain the figures from the submitted thesis or update the thesis; the original thesis PNGs are present in the initial Git revision.
- [ ] Decide on software licensing and cite metadata.

The uploaded 1-run CSV/MAT files remain safe under `provenance/single_run_exports/`. Do not promote them as complete 24-run results.

## Archive immutable thesis version

1. Commit the reviewed code, data, and environment record.
2. Create a Git tag, e.g. `v1.0.0-thesis` (and preferably an immutable GitHub Release):

```bash
git tag -a v1.0.0-thesis -m "Thesis numerical archive"
git push origin v1.0.0-thesis
```

3. On GitHub: open **Releases** → **Draft a new release**, select `v1.0.0-thesis`, give the release a title, and publish. Optionally enable immutable release settings.
4. Optional DOI: connect the GitHub repository in Zenodo **before** publishing the release. A tagged release can then be archived and assigned a version-specific DOI (confirm the Zenodo record).
5. Verify that the public release link opens without authentication, includes the correct assets, and is fixed to the intended version. Copy the actual release URL / version-specific DOI into `appendices/numerical/source.tex` in the LaTeX thesis project.
6. Recompile the thesis at least twice, inspect Appendix C and the contents page, and confirm no references are broken. Do not submit a thesis with `[INSERT VERIFIED ARCHIVE URL OR DOI]` still present.

## Optional GitHub CLI

After GitHub CLI authentication, a release can also be published using:

```bash
gh release create v1.0.0-thesis --title "Thesis numerical archive v1.0.0" --notes "Fixed numerical source and accompanying thesis results"
```

The repository upload and DOI creation are **not** performed by the supplied ZIP. This file is a procedure, not evidence that publication has happened.
