function result = run_experiment(p, projectRoot)
%RUN_EXPERIMENT Execute one complete numerical experiment.
%
%   The experiment configuration is contained in p.
%
%   Performs:
%       1. Numerical solutions
%       2. Evaluation and postprocessing
%       3. Numerical validation
%       4. Physical comparison
%       5. Reports and figure export
%
%   Returns all computed results for subsequent analysis.

arguments (Input)
    p
    projectRoot (1,1) string
end

arguments (Output)
    result
end

%% 1. Run selected comparison protocol

comparisonCase = upper(string(p.comparisonCase));

switch comparisonCase

    % "I"  : Equal travel time     -->  compare total/initial energies
    case "I"
        out = run_case_I(p);

    % "II" : Equal initial energy  -->  compare travel times
    case "II"
        out = run_case_II(p);

    otherwise
        error('run_experiment:UnknownCase', ...
            'Unknown comparison case.');
end

%% 2. Extract results

p = out.p;

sol_G  = out.sol_G;
sol_B  = out.sol_B;
sol_LA = out.sol_LA;

%% 3. Evaluate numerical solutions

data_u_G = evaluate_solution(sol_G, p);
data_u_B = out.data_u_B;
data_u_LA = evaluate_solution(sol_LA, p);

%% 4. Postprocess

data_s_G = postprocess_geodesic(data_u_G, p);
data_t_B = out.data_t_B;
data_t_LA = postprocess_leastaction(data_u_LA, p);

%% 5. Validate solutions

val_G = check_geodesic(sol_G, p);
val_B = check_brachistochrone(sol_B, p);
val_LA = check_leastaction(sol_LA, p);

%% 6. Collect physical comparison data

cmp = collect_physical_comparison( ...
    comparisonCase, p, ...
    data_u_B, data_t_B, ...
    data_u_LA, data_t_LA, ...
    val_B, val_LA);

%% 7. Report and save validation results

validationDir = fullfile( ...
    projectRoot, '10 results', 'validation');

output_validation_report( ...
    @() report_validation_geodesic(val_G), ...
    report=true, ...
    save=true, ...
    filename=string(fullfile( ...
        validationDir, ...
        sprintf('geodesic_%s_%d.txt', ...
            p.case_title, p.case_ver))));

output_validation_report( ...
    @() report_validation_brachistochrone( ...
        val_B, data_t_B), ...
    report=true, ...
    save=true, ...
    filename=string(fullfile( ...
        validationDir, ...
        sprintf('brachistochrone_%s_%d.txt', ...
            p.case_title, p.case_ver))));

output_validation_report( ...
    @() report_validation_leastaction( ...
        val_LA, data_t_LA), ...
    report=true, ...
    save=true, ...
    filename=string(fullfile( ...
        validationDir, ...
        sprintf('leastaction_%s_%d.txt', ...
            p.case_title, p.case_ver))));

%% 8. Physical comparison report

comparisonDir = fullfile( ...
    projectRoot, '10 results', 'comparison');

output_validation_report( ...
    @() report_physical_comparison(cmp), ...
    report=true, ...
    save=true, ...
    filename=string(fullfile( ...
        comparisonDir, ...
        sprintf('physical_comparison_%s_%d.txt', ...
            p.case_title, p.case_ver))));

%% 9. Generate sphere figure

figuresDir = fullfile( ...
    projectRoot, '10 results', 'figures');

plot_sphere_curves( ...
    data_u_G, data_u_B, data_u_LA, ...
    p, figuresDir, ...
    save=true, ...
    showFigure=p.showFigure, ...
    savePDF=p.savePDF, ...
    savePNG=p.savePNG, ...
    pngResolution=p.pngResolution, ...
    presentation=p.presentation, ...
    zoom=p.zoom, ...
    showLegend=p.showLegend);

%% 10. Store complete experiment results

result.p = p;
result.comparison = cmp;

% Numerical solutions
result.sol.G = sol_G;
result.sol.B = sol_B;
result.sol.LA = sol_LA;
result.sol.LA_IVP = out.sol_LA_IVP;

% Evaluated and postprocessed curves
result.data.u_G = data_u_G;
result.data.u_B = data_u_B;
result.data.u_LA = data_u_LA;

result.data.s_G = data_s_G;
result.data.t_B = data_t_B;
result.data.t_LA = data_t_LA;

% Validation
result.validation.G = val_G;
result.validation.B = val_B;
result.validation.LA = val_LA;

result.allValid = ...
    val_G.valid && val_B.valid && val_LA.valid;

if ~result.allValid
    warning('run_experiment:ValidationFailed', ...
        'One or more validations failed for %s.', ...
        p.case_title);
end

end