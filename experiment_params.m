function out = experiment_params(scenario)
%EXPERIMENT_PARAMS Define scenarios or create a configured parameter set.
%   SCENARIOS = EXPERIMENT_PARAMS() returns the named experiment manifest.
%   P = EXPERIMENT_PARAMS(SCENARIOS(K)) returns one configured experiment:
%     1. Obtain independent defaults from base_params().
%     2. Apply only the listed independent-parameter overrides.
%     3. Call configure_experiment() to recompute all derived quantities.
%     4. Assign a unique experiment ID and output filename stem.
%
%   Edit/add manifest entries below; do not edit base_params() for each run.
%   Use MAIN to select which entries to run. The quadrature benchmark also
%   accepts these same scenario indices.
%   Indices 1:4  : current baseline experiments (not original thesis Set 2).
%   Indices 5:12 : controlled one-parameter variations.
%   Indices 13:24: original thesis Sets 1--3, four configurations each.
%
%   The equal-azimuth configuration forces phi1=phi0 and beta0=0.
%   Case II determines theta1 and phi1 from the least-action IVP.
%
%   Examples of NEW entries (uncomment to enable):
%     scenarios(end+1) = make_scenario( ...
%         "I_theta1_pi5", "I", "unequal", struct('theta1',pi/5));
%     scenarios(end+1) = make_scenario( ...
%         "II_v0_4", "II", "unequal", struct('v0',4.0));

if nargin == 0
    %% Current baseline: four comparison configurations
    scenarios = [ ...
        make_scenario("I_equal", "I", "equal", struct()), ...
        make_scenario("I_unequal", "I", "unequal", struct()), ...
        make_scenario("II_equal", "II", "equal", struct()), ...
        make_scenario("II_unequal", "II", "unequal", struct()) ...
    ];

    %% Controlled one-parameter comparisons (baselines: 2 and 4)
    % Case I: vary endpoint polar angle, holding theta0, phi0, phi1, v0 fixed.
    scenarios(end+1) = make_scenario( ...
        "I_theta1_pi7", "I", "unequal", struct('theta1',pi/7));
    scenarios(end+1) = make_scenario( ...
        "I_theta1_pi5", "I", "unequal", struct('theta1',pi/5));

    % Case I: vary azimuthal separation, holding theta0, theta1, v0 fixed.
    scenarios(end+1) = make_scenario( ...
        "I_phi1_4pi3", "I", "unequal", struct('phi1',4*pi/3));
    scenarios(end+1) = make_scenario( ...
        "I_phi1_17pi12", "I", "unequal", struct('phi1',17*pi/12));

    % Case II: vary the common prescribed initial speed.
    scenarios(end+1) = make_scenario( ...
        "II_v0_2", "II", "unequal", struct('v0',2.0));
    scenarios(end+1) = make_scenario( ...
        "II_v0_4", "II", "unequal", struct('v0',4.0));

    % Case II: vary the least-action launch direction, holding speed fixed.
    scenarios(end+1) = make_scenario( ...
        "II_beta0_5pi8", "II", "unequal", struct('beta0',5*pi/8));
    scenarios(end+1) = make_scenario( ...
        "II_beta0_7pi8", "II", "unequal", struct('beta0',7*pi/8));

    %% Original thesis experiments (three sets, four configurations per set)
    % Source: thesis Chapter 6 numerical_setup.tex, Table experiment_sets.
    % Shared values inherited from base_params: R=10, g=9.81, m=1,
    % phi0=pi, v0=3. Case II endpoints are determined by the LA IVP.
    scenarios = append_thesis_set( ...
        scenarios, "S1", pi/10, pi/4, 3*pi/2, pi/2);
    scenarios = append_thesis_set( ...
        scenarios, "S2", pi/10, pi/6, 3*pi/2, 3*pi/4);
    scenarios = append_thesis_set( ...
        scenarios, "S3", pi/8, pi/7, 1.9*pi, 0.99*pi);

    ids = string({scenarios.id});
    if numel(unique(ids)) ~= numel(ids)
        error('experiment_params:DuplicateID', ...
            'Every scenario must have a unique ID.');
    end
    out = scenarios;
    return
end

%% Validate selected scenario
if ~isstruct(scenario) || ~isscalar(scenario) || ...
        ~all(isfield(scenario, {'id','comparisonCase','azimuthCase','overrides'}))
    error('experiment_params:Scenario', ...
        'Expected one scenario struct returned by experiment_params().');
end

id = string(scenario.id);
comparisonCase = upper(string(scenario.comparisonCase));
azimuthCase = lower(string(scenario.azimuthCase));
overrides = scenario.overrides;

if ~isscalar(id) || strlength(id)==0 || ...
        isempty(regexp(char(id),'^[A-Za-z0-9][A-Za-z0-9_-]*$','once'))
    error('experiment_params:ID', ...
        'The scenario ID must contain only letters, digits, underscores, or hyphens.');
end

if ~isscalar(comparisonCase) || ~ismember(comparisonCase,["I","II"]) || ...
        ~isscalar(azimuthCase) || ~ismember(azimuthCase,["equal","unequal"])
    error('experiment_params:Case', ...
        'Choose comparisonCase I/II and azimuthCase equal/unequal.');
end

if ~isstruct(overrides) || ~isscalar(overrides)
    error('experiment_params:Overrides', ...
        'overrides must be a scalar struct, for example struct(''v0'',4).');
end

% Reject overrides that the experiment protocol would silently discard.
if comparisonCase == "II" && ...
        (isfield(overrides,'theta1') || isfield(overrides,'phi1'))
    error('experiment_params:CaseIIEndpoints', ...
        'Case II obtains theta1 and phi1 from the LA IVP; do not override them.');
end
if azimuthCase == "equal" && ...
        (isfield(overrides,'phi1') || isfield(overrides,'beta0'))
    error('experiment_params:EqualAzimuth', ...
        'Equal azimuth forces phi1=phi0 and beta0=0; do not override them.');
end

%% Apply independent-input overrides
p = base_params();
fields = fieldnames(overrides);
for k = 1:numel(fields)
    field = fields{k};
    if ~isfield(p,field) || strcmp(field,'case_ver')
        error('experiment_params:UnknownOverride', ...
            'Unknown or derived parameter override: %s.',field);
    end
    p.(field) = overrides.(field);
end

%% Validate essential independent inputs before deriving quantities
for field = {'R','g','m','N','RelTol','AbsTol','ivpMaxTime', ...
             'ivpRelTol','ivpAbsTol','epsTheta'}
    validateattributes(p.(field{1}), {'numeric'}, ...
        {'real','scalar','finite','positive'}, ...
        'experiment_params',field{1});
end
validateattributes(p.N,{'numeric'},{'integer','>=',3}, ...
    'experiment_params','N');
validateattributes(p.v0,{'numeric'}, ...
    {'real','scalar','finite','nonnegative'},'experiment_params','v0');
for field = {'theta0','phi0','theta1','phi1','beta0'}
    validateattributes(p.(field{1}),{'numeric'}, ...
        {'real','scalar','finite'},'experiment_params',field{1});
end
if p.theta0<=0 || p.theta0>=pi || p.theta0+p.epsTheta>=pi
    error('experiment_params:Theta0', ...
        'Require 0 < theta0 < theta0+epsTheta < pi.');
end
if comparisonCase == "I" && (p.theta1<=0 || p.theta1>=pi)
    error('experiment_params:Theta1', ...
        'Case I requires 0 < theta1 < pi.');
end

%% Recompute all case-dependent quantities and label outputs
p = configure_experiment(p,comparisonCase,azimuthCase);
p.experimentID = id;
p.experimentOverrides = overrides;
p.case_title = sprintf('%s_%s',p.case_title,char(id));

out = p;
end

function s = make_scenario(id,comparisonCase,azimuthCase,overrides)
%MAKE_SCENARIO One named experiment plus its independent-input changes.
s = struct( ...
    'id',string(id), ...
    'comparisonCase',string(comparisonCase), ...
    'azimuthCase',string(azimuthCase), ...
    'overrides',overrides);
end

function scenarios = append_thesis_set(scenarios,setID,theta0,theta1,phi1,beta0)
%APPEND_THESIS_SET Four original thesis configurations for one parameter set.
%   The equal-azimuth protocol determines its azimuth or launch direction;
%   Case II determines its terminal point from the least-action IVP.
%   Accordingly, only independent, applicable inputs are overridden.

prefix = "Thesis_" + string(setID) + "_";

scenarios(end+1) = make_scenario( ...
    prefix + "I_equal", "I", "equal", ...
    struct('theta0',theta0, 'theta1',theta1));

scenarios(end+1) = make_scenario( ...
    prefix + "I_unequal", "I", "unequal", ...
    struct('theta0',theta0, 'theta1',theta1, 'phi1',phi1));

scenarios(end+1) = make_scenario( ...
    prefix + "II_equal", "II", "equal", ...
    struct('theta0',theta0));

scenarios(end+1) = make_scenario( ...
    prefix + "II_unequal", "II", "unequal", ...
    struct('theta0',theta0, 'beta0',beta0));
end
