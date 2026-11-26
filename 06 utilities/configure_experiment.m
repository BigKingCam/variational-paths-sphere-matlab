function p = configure_experiment(p, comparisonCase, azimuthCase)
%CONFIGURE_EXPERIMENT Configure a numerical comparison experiment.
%
%   Comparison cases:
%       "I"  - Equal travel time
%       "II" - Equal initial mechanical energy
%
%   Azimuth configurations:
%       "equal"   - Equal initial/final azimuth
%       "unequal" - Unequal initial/final azimuth
%
%   Case I uses prescribed endpoints.
%   Case II obtains its endpoint from the least-action IVP.

arguments (Input)
    p
    comparisonCase (1,1) string
    azimuthCase (1,1) string
end

arguments (Output)
    p
end

comparisonCase = upper(comparisonCase);
azimuthCase = lower(azimuthCase);

%% Validate experiment selection

if ~ismember(comparisonCase, ["I", "II"])
    error('Unknown comparison case.');
end

if ~ismember(azimuthCase, ["equal", "unequal"])
    error('Unknown azimuth configuration.');
end

%% Experiment identification

p.comparisonCase = comparisonCase;
p.azimuthCase = azimuthCase;

p.case_title = sprintf( ...
    'case_%s_azimuth_%s', ...
    lower(char(comparisonCase)), ...
    char(azimuthCase));


%% Physical parameters and initial conditions

% Preserve p.R, p.g, p.m, p.theta0, p.phi0,
% p.v0, and p.beta0 from parameters.m.

%% Azimuth configuration

if azimuthCase == "equal"

    % Case II follows a meridian.
    p.beta0 = 0;

end

% For unequal azimuth, retain p.beta0 as prescribed in parameters.m.

%% Case-specific endpoints

switch comparisonCase

    case "I"

        % Keep prescribed theta1 from parameters.m.
        % Keep prescribed phi1 for unequal azimuth.

        if azimuthCase == "equal"
            p.phi1 = p.phi0;
        end

    case "II"

        % Terminal point determined by least-action IVP.
        p.theta1 = NaN;
        p.phi1 = NaN;

end

%% Recompute IVP initial conditions

% These are used by Case II.
p.thetaDot0 = ...
    (p.v0 / p.R) * cos(p.beta0);

p.phiDot0 = ...
    (p.v0 / (p.R * sin(p.theta0))) * sin(p.beta0);

p.y0_LA_IVP = [
    p.theta0
    p.phi0
    p.thetaDot0
    p.phiDot0
];

%% Initial energy and contact force

% In Case I, E0 here is the prescribed brachistochrone
% energy, NOT the unknown least-action initial energy.
p.E0 = ...
    0.5 * p.m * p.v0^2 ...
    + p.m * p.g * p.R * cos(p.theta0);

p.N0 = ...
    p.m * (p.g * cos(p.theta0) - p.v0^2 / p.R);

if p.N0 <= 0
    error( ...
        'configure_experiment:InitialContact', ...
        'Initial normal force must be positive.');
end

%% Analytical detachment latitude

p.thetaDetachExpected = acos( ...
    2 * p.E0 / (3 * p.m * p.g * p.R));

%% Brachistochrone release-point regularization

p.theta0Numerical = p.theta0 + p.epsTheta;

end
