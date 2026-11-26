function summary = experiment_summary_table(results)
%EXPERIMENT_SUMMARY_TABLE Summarize physical comparison results.
%
%   Input:
%       results - cell array of run_experiment outputs
%
%   Output:
%       summary - MATLAB table with one row per experiment.
%
%   Focuses on physical quantities rather than
%   numerical validation residuals.

arguments (Input)
    results cell
end

arguments (Output)
    summary
end

n = numel(results);

%% Initialize columns

Case = strings(n,1);
Azimuth = strings(n,1);

Theta1_rad = zeros(n,1);
Phi1_rad = zeros(n,1);

EB_J = zeros(n,1);
ELA_J = zeros(n,1);
DeltaE_J = zeros(n,1);

TB_s = zeros(n,1);
TLA_s = zeros(n,1);
DeltaT_s = zeros(n,1);
DeltaT_pct = zeros(n,1);

LB_m = zeros(n,1);
LLA_m = zeros(n,1);
DeltaL_m = zeros(n,1);

B_Physical = false(n,1);
LA_Physical = false(n,1);

%% Populate columns

for k = 1:n

    r = results{k};

    p = r.p;
    cmp = r.comparison;

    % Experiment identification
    Case(k) = string(p.comparisonCase);
    Azimuth(k) = string(p.azimuthCase);

    % Common terminal point
    Theta1_rad(k) = p.theta1;
    Phi1_rad(k) = p.phi1;

    % Mechanical energies
    EB_J(k) = cmp.B.E0;
    ELA_J(k) = cmp.LA.E0;
    DeltaE_J(k) = cmp.deltaEnergy;

    % Travel times
    TB_s(k) = cmp.B.T;
    TLA_s(k) = cmp.LA.T;
    DeltaT_s(k) = cmp.deltaTime;
    DeltaT_pct(k) = cmp.percentTimeDifference;

    % Path lengths
    LB_m(k) = cmp.B.length;
    LLA_m(k) = cmp.LA.length;
    DeltaL_m(k) = cmp.deltaLength;

    % Physical admissibility
    B_Physical(k) = cmp.B.isPhysical;
    LA_Physical(k) = cmp.LA.isPhysical;

end

%% Construct MATLAB table

summary = table( ...
    Case, Azimuth, ...
    Theta1_rad, Phi1_rad, ...
    EB_J, ELA_J, DeltaE_J, ...
    TB_s, TLA_s, DeltaT_s, DeltaT_pct, ...
    LB_m, LLA_m, DeltaL_m, ...
    B_Physical, LA_Physical);

end
