%%% main.m

clear;
clc;
close all;

%% Project setup

projectRoot = fileparts(mfilename('fullpath'));

addpath(genpath(projectRoot));

%% Scenario manifest

% Edit experiment_params.m to add scenarios or override inputs.
scenarios = experiment_params();

%% Experiment execution settings

% Scenario group indices (stable by design in experiment_params.m):
%   1:4   current base experiments
%   5:12  controlled parameter variations
%   13:16 original thesis Set 1
%   17:20 original thesis Set 2
%   21:24 original thesis Set 3
% Examples: runThese = 13:24;  % original thesis results only
%           runThese = 5:12;   % controlled variations only
runThese = 1:numel(scenarios);    % Complete 24-scenario thesis batch

% Short, descriptive identifier for the consolidated CSV and MAT filenames.
% Change this if running a subset, to avoid overwriting prior batch results.
batchID = "all_base_thesis_variations";

% Version for every individual experiment's figures and reports.
runVersion = 1;

% Optional quadrature checks on the ALREADY SOLVED BVPs (no re-solving).
% Leave false for ordinary batch experiments; use the standalone benchmark
% for formal reference-resolution or tolerance studies.
runQuadratureChecks = true;
quadratureSegmentPoints = 1601;

% Optional batch-wide figure export settings.
% Leave any setting [] to retain the value in the scenario/base_params.
batchSavePDF = false;
batchSavePNG = true;
batchPNGResolution = 300;    % Recommended for final thesis raster figures.
batchShowFigure = true;      % false = figures NOT displayed in MATLAB

% Optional batch-wide plot-style overrides ([] = use base_params.m).
% showLegend affects both exported and interactive plots.
batchShowLegend = [];          % true = plot legend, false = omit it
batchZoom = [];                % positive scale, 1.0 = no extra zoom

%% Run experiments

if isempty(runThese) || any(~ismember(runThese,1:numel(scenarios)))
    error('main:ScenarioSelection', ...
        'runThese must refer to indices in experiment_params().');
end

nRuns = numel(runThese);
results = cell(nRuns, 1);
experimentIDs = strings(nRuns,1);
quadratureRows = struct('ExperimentID',{},'Case',{},'Azimuth',{}, ...
    'Problem',{},'Status',{},'MaxError_over_R',{},'Message',{});

for k = 1:nRuns

    idx = runThese(k);

    scenario = scenarios(idx);
    comparisonCase = scenario.comparisonCase;
    azimuthCase = scenario.azimuthCase;
    experimentIDs(k) = scenario.id;

    fprintf('\n========================================\n');
    fprintf('EXPERIMENT %d OF %d\n', k, nRuns);
    fprintf('Scenario: %s\n', scenario.id);
    fprintf('Case: %s\n', comparisonCase);
    fprintf('Azimuth: %s\n', azimuthCase);
    fprintf('========================================\n');

    % Fresh defaults + scenario overrides + recomputed derived quantities
    p = experiment_params(scenario);

    % Optional batch-wide overrides of figure-export settings.
    if ~isempty(batchSavePDF), p.savePDF = batchSavePDF; end
    if ~isempty(batchSavePNG), p.savePNG = batchSavePNG; end
    if ~isempty(batchShowFigure), p.showFigure = batchShowFigure; end
    if ~isempty(batchPNGResolution)
        p.pngResolution = batchPNGResolution;
    end
    if ~isempty(batchShowLegend), p.showLegend = batchShowLegend; end
    if ~isempty(batchZoom), p.zoom = batchZoom; end

    % Assign the chosen output version
    p.case_ver = runVersion;

    % Execute the complete numerical experiment
    results{k} = run_experiment( ...
        p, string(projectRoot));

    % Optional reference checks reuse the existing BVP solutions.
    if runQuadratureChecks
        for kind = ["B","LA"]
            row = struct( ...
                'ExperimentID',scenario.id, ...
                'Case',comparisonCase, ...
                'Azimuth',azimuthCase, ...
                'Problem',kind, ...
                'Status',"FAILED", ...
                'MaxError_over_R',NaN, ...
                'Message',"");
            try
                qchk = check_quadrature_reference( ...
                    kind,results{k}.sol.(char(kind)),results{k}.p, ...
                    nSegment=quadratureSegmentPoints);
                results{k}.quadrature.(char(kind)) = qchk;
                row.Status = "OK";
                row.MaxError_over_R = qchk.maxCartesianError;
            catch ME
                row.Message = string(ME.message);
                warning('main:QuadratureCheck', ...
                    'Scenario %s, %s: %s',scenario.id,kind,ME.message);
            end
            quadratureRows(end+1) = row; %#ok<AGROW>
        end
    end
end

%% Construct summary table

summary = experiment_summary_table(results);
summary = addvars(summary,experimentIDs, ...
    'Before','Case','NewVariableNames','ExperimentID');

%% Display compact physical summary

fprintf(['\n========================================' ...
    '========================================\n']);
fprintf('CROSS-EXPERIMENT PHYSICAL SUMMARY\n');
fprintf(['========================================' ...
    '========================================\n']);
disp(summary(:, { ...
    'Case', 'Azimuth', ...
    'TB_s', 'TLA_s', 'DeltaT_s', ...
    'EB_J', 'ELA_J'}));

%% Construct and display validation summary

% Reuse experiment identifiers from the physical summary
validationSummary = summary(:, {'ExperimentID', 'Case', 'Azimuth'});

% Initialize all results as FAIL
validationSummary.Geodesic = repmat("FAIL", nRuns, 1);
validationSummary.Brachistochrone = repmat("FAIL", nRuns, 1);
validationSummary.LeastAction = repmat("FAIL", nRuns, 1);

% Extract overall validation status for each curve
for k = 1:nRuns

    if results{k}.validation.G.valid
        validationSummary.Geodesic(k) = "PASS";
    end

    if results{k}.validation.B.valid
        validationSummary.Brachistochrone(k) = "PASS";
    end

    if results{k}.validation.LA.valid
        validationSummary.LeastAction(k) = "PASS";
    end

end

% Display validation summary
fprintf(['\n========================================' ...
    '========================================\n']);
fprintf('CROSS-EXPERIMENT VALIDATION SUMMARY\n');
fprintf(['========================================' ...
    '========================================\n']);

disp(validationSummary);

%% Save consolidated results

% A short batch identifier prevents excessively long filenames when
% all 24 experiments run together. Per-experiment files remain unique
% because experiment_params includes each scenario ID in p.case_title.
if ~isscalar(batchID) || isempty(regexp(char(batchID), ...
        '^[A-Za-z0-9][A-Za-z0-9_-]*$', 'once'))
    error('main:BatchID', ...
        'batchID must contain only letters, digits, underscores, or hyphens.');
end
selectionTag = char(batchID);

comparisonDir = fullfile( ...
    projectRoot, '10 results', 'comparison');

if ~isfolder(comparisonDir)
    mkdir(comparisonDir);
end

% Export the full physical table as CSV
csvFile = fullfile( ...
    comparisonDir, ...
    sprintf('physical_summary_%s_v%d.csv', ...
        selectionTag, runVersion));

writetable(summary, csvFile);

% Export the validation summary as CSV
validationCsvFile = fullfile( ...
    comparisonDir, ...
    sprintf('validation_summary_%s_v%d.csv', ...
        selectionTag, runVersion));

writetable(validationSummary, validationCsvFile);

% Save all computed MATLAB data for later analysis
matFile = fullfile( ...
    comparisonDir, ...
    sprintf('all_experiments_%s_v%d.mat', ...
        selectionTag, runVersion));

save(matFile, 'results', 'summary', 'validationSummary', ...
    'scenarios', 'runThese', 'runVersion', 'batchID');

if runQuadratureChecks
    quadratureSummary = struct2table(quadratureRows);
    quadCsvFile = fullfile(comparisonDir, ...
        sprintf('quadrature_summary_%s_v%d.csv',selectionTag,runVersion));
    writetable(quadratureSummary,quadCsvFile);
    save(matFile,'quadratureSummary','-append');
    fprintf('Saved quadrature summary:\n%s\n',quadCsvFile);
end

fprintf('\nSaved summary table:\n%s\n', csvFile);
fprintf('\nSaved MATLAB results:\n%s\n', matFile);

fprintf('\nCompleted %d experiments.\n', nRuns);


%% END