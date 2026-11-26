function validationTable = run_quadrature_benchmarks(opts)
%RUN_QUADRATURE_BENCHMARKS Compare BVP solutions with reduced quadratures.
%   TABLE = RUN_QUADRATURE_BENCHMARKS() verifies the brachistochrone (B)
%   and least-action (LA) solutions for all four existing configurations.
%   Each experiment's endpoints and prescribed LA time are fixed before
%   the BVP solver tolerances are changed.
%
%   Name-value options:
%       runThese        Scenario indices from experiment_params (default 1:4)
%       tolerancePairs  [RelTol, AbsTol] per row       (default [1e-8,1e-10])
%       nCompare        Shared time comparison points  (default 201)
%       nSegment        Quadrature points per segment  (default 1601)
%       outputTag       Suffix for saved files         (default "final")
%       saveResults     Write CSV and MAT files        (default true)
%
%   The BVP selects the polar branch and provides initial guesses, but
%   the reference constants are fitted to boundary data independently.
%   This is a trajectory-agreement test, not a proof of solver convergence.
%
%   Examples:
%       tbl = run_quadrature_benchmarks();
%       tbl = run_quadrature_benchmarks(runThese=[2,4], nSegment=801);
%
%   Output files (when saveResults=true):
%       10 results/quadrature_benchmarks/quadrature_benchmarks_final.csv
%       10 results/quadrature_benchmarks/quadrature_benchmarks_final.mat
%
arguments
    opts.runThese (1,:) double {mustBeInteger} = 1:4
    opts.tolerancePairs (:,2) double {mustBePositive} = [1e-8,1e-10]
    opts.nCompare (1,1) double {mustBeInteger,mustBeGreaterThan(opts.nCompare,2)} = 201
    opts.nSegment (1,1) double {mustBeInteger,mustBeGreaterThan(opts.nSegment,10)} = 1601
    opts.outputTag (1,1) string = "final"
    opts.saveResults (1,1) logical = true
end

%% Set up experiment selection

% Validate scenario indices after the manifest is loaded below.
if isempty(opts.runThese)
    error('run_quadrature_benchmarks:Selection', ...
        'Choose at least one experiment index.');
end

if isempty(opts.tolerancePairs)
    error('run_quadrature_benchmarks:Tolerances', ...
        'Specify at least one [RelTol, AbsTol] pair.');
end

if strlength(opts.outputTag)==0
    error('run_quadrature_benchmarks:OutputTag', ...
        'outputTag must not be empty.');
end

% The runner works from the project root OR from 06 utilities.
projectRoot = fileparts(mfilename('fullpath'));
if ~isfile(fullfile(projectRoot,'base_params.m'))
    projectRoot = fileparts(projectRoot);
end
if ~isfile(fullfile(projectRoot,'base_params.m'))
    error('run_quadrature_benchmarks:ProjectRoot', ...
        'Cannot find base_params.m in the project root.');
end
addpath(genpath(projectRoot));

scenarios = experiment_params();
if any(~ismember(opts.runThese,1:numel(scenarios)))
    error('run_quadrature_benchmarks:Selection', ...
        'runThese must contain indices from experiment_params().');
end

records = struct( ...
    'ExperimentID',{},'Case',{},'Azimuth',{},'Problem',{}, ...
    'RelTol',{},'AbsTol',{},'MeshPoints',{}, ...
    'MaxError_over_R',{},'RMSError_over_R',{}, ...
    'TravelTimeError_s',{},'EndpointResidual',{}, ...
    'JDifference',{},'EnergyDifference_J',{},'LzDifference',{}, ...
    'Turn',{},'Status',{},'FailureId',{},'FailureMessage',{});

fixedCases = struct('ExperimentID',{},'Case',{},'Azimuth',{},'Parameters',{});

%% Execute fixed-boundary comparisons

for k = opts.runThese

    % Establish the endpoints and LA time ONCE for this configuration.
    % In Case I, T_LA comes from the baseline brachistochrone solution;
    % in Case II, the terminal event comes from the least-action IVP.
    pFixed = experiment_params(scenarios(k));
    solIVP = [];

    if pFixed.comparisonCase == "I"
        baselineB = solve_brachistochrone(pFixed);
        baselineData = evaluate_solution(baselineB,pFixed);
        baselinePhysical = postprocess_brachistochrone(baselineData,pFixed);
        pFixed.T = baselinePhysical.totalTime;
    else
        solIVP = solve_leastaction_ivp(pFixed);
        pFixed.T = solIVP.xe(end);
        pFixed.theta1 = solIVP.ye(1,end);
        pFixed.phi1 = solIVP.ye(2,end);
    end

    if ~(isfinite(pFixed.T) && pFixed.T>0 && ...
            isfinite(pFixed.theta1) && isfinite(pFixed.phi1))
        error('run_quadrature_benchmarks:FixedBoundary', ...
            'Invalid fixed boundary data for configuration %d.',k);
    end

    fixedCases(end+1) = struct( ...
        'ExperimentID',pFixed.experimentID, ...
        'Case',pFixed.comparisonCase, ...
        'Azimuth',pFixed.azimuthCase, ...
        'Parameters',pFixed); %#ok<AGROW>

    fprintf('\nScenario %s: Case %s (%s), theta1=%.10g, phi1=%.10g, T_LA=%.10g s\n', ...
        pFixed.experimentID,pFixed.comparisonCase,pFixed.azimuthCase, ...
        pFixed.theta1,pFixed.phi1,pFixed.T);

    for it = 1:size(opts.tolerancePairs,1)
        p = pFixed;
        p.RelTol = opts.tolerancePairs(it,1);
        p.AbsTol = opts.tolerancePairs(it,2);

        fprintf('  RelTol=%g, AbsTol=%g\n',p.RelTol,p.AbsTol);

        for kind = ["B","LA"]
            row = empty_record(p,kind);

            try
                if kind == "B"
                    sol = solve_brachistochrone(p);
                else
                    sol = solve_leastaction(p,solIVP);
                end

                row.MeshPoints = numel(sol.x);

                chk = check_quadrature_reference(kind,sol,p, ...
                    nCompare=opts.nCompare,nSegment=opts.nSegment);

                values = [chk.maxCartesianError, chk.rmsCartesianError, ...
                    chk.timeError, chk.endpointResidual, ...
                    chk.constantDifference(:)'];
                if any(~isfinite(values))
                    error('run_quadrature_benchmarks:NonfiniteResult', ...
                        'Validation returned a nonfinite error metric.');
                end

                row.MaxError_over_R = chk.maxCartesianError;
                row.RMSError_over_R = chk.rmsCartesianError;
                row.TravelTimeError_s = chk.timeError;
                row.EndpointResidual = chk.endpointResidual;
                row.Turn = chk.reference.turn;

                if kind == "B"
                    row.JDifference = chk.constantDifference;
                else
                    row.EnergyDifference_J = chk.constantDifference(1);
                    row.LzDifference = chk.constantDifference(2);
                end

                row.Status = "OK";
                fprintf('    %-2s: max distance/R = %.4e; turn = %s\n', ...
                    kind,row.MaxError_over_R,row.Turn);

            catch ME
                row.Status = "FAILED";
                row.FailureId = string(ME.identifier);
                row.FailureMessage = string(ME.message);
                fprintf(2,'    %-2s: FAILED (%s) %s\n', ...
                    kind,ME.identifier,ME.message);
            end

            records(end+1) = row; %#ok<AGROW>
        end
    end
end

%% Summarize and export

validationTable = struct2table(records);
nPassed = sum(validationTable.Status=="OK");
nTotal = height(validationTable);

fprintf('\nQuadrature validations: %d/%d passed.\n',nPassed,nTotal);
disp(validationTable);

if opts.saveResults
    outputDir = fullfile(projectRoot,'10 results','quadrature_benchmarks');
    if ~isfolder(outputDir)
        mkdir(outputDir);
    end

    safeTag = regexprep(char(opts.outputTag),'[^a-zA-Z0-9_-]','_');
    baseName = ['quadrature_benchmarks_',safeTag];
    csvFile = fullfile(outputDir,[baseName,'.csv']);
    matFile = fullfile(outputDir,[baseName,'.mat']);

    metadata = struct( ...
        'runThese',opts.runThese, ...
        'tolerancePairs',opts.tolerancePairs, ...
        'nCompare',opts.nCompare, ...
        'nSegment',opts.nSegment, ...
        'outputTag',opts.outputTag, ...
        'generatedAt',datetime('now'));

    writetable(validationTable,csvFile);
    save(matFile,'validationTable','metadata','fixedCases');
    fprintf('Saved CSV: %s\nSaved MAT: %s\n',csvFile,matFile);
end

if nPassed<nTotal
    warning('run_quadrature_benchmarks:PartialFailure', ...
        '%d of %d quadrature comparisons failed. Inspect Status and FailureMessage.', ...
        nTotal-nPassed,nTotal);
end

end

function row = empty_record(p,kind)
%EMPTY_RECORD Initialize every output field, including failure diagnostics.

row = struct( ...
    'ExperimentID',string(p.experimentID), ...
    'Case',string(p.comparisonCase), ...
    'Azimuth',string(p.azimuthCase), ...
    'Problem',kind, ...
    'RelTol',p.RelTol, ...
    'AbsTol',p.AbsTol, ...
    'MeshPoints',NaN, ...
    'MaxError_over_R',NaN, ...
    'RMSError_over_R',NaN, ...
    'TravelTimeError_s',NaN, ...
    'EndpointResidual',NaN, ...
    'JDifference',NaN, ...
    'EnergyDifference_J',NaN, ...
    'LzDifference',NaN, ...
    'Turn',"unknown", ...
    'Status',"NOT_RUN", ...
    'FailureId',"", ...
    'FailureMessage',"");

end
