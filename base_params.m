function p = base_params()
%BASE_PARAMS Default independent parameters for spherical path experiments.
%   P = BASE_PARAMS() returns the physical inputs, numerical tolerances,
%   and plotting settings shared by the experimental configurations.
%
%   Do not put Case-II computed endpoints or derived values here. The
%   experiment_params function applies overrides before calling
%   configure_experiment, which computes the IVP initial state, energy,
%   contact force, detachment latitude, and regularized B start.
%
%   Units: R [m], g [m/s^2], m [kg], v0 [m/s], angles [rad], time [s].

%% Plotting
% All plotting preferences can be overridden for a batch in main.m.
p.presentation = false;
p.showFigure = false; % Display generated plots in MATLAB (false = export only)
p.zoom = 1.0;       % Camera zoom for both thesis and presentation figures
p.showLegend = false; % Thesis panels use one shared horizontal legend
p.plotN = 500;

% Figure export
p.savePDF = false;
p.savePNG = true;
p.pngResolution = 300; % DPI

%% Physical parameters
p.R = 10;
p.g = 9.81;
p.m = 1;

%% Prescribed endpoints (used in comparison Case I)
p.theta0 = pi/8;
p.phi0 = pi;
p.theta1 = pi/6;
p.phi1 = 3*pi/2;

%% Brachistochrone regularization
p.epsTheta = 1e-5;

%% BVP settings
p.N = 200;
p.RelTol = 1e-8;
p.AbsTol = 1e-10;

%% Initial physical state for comparison Case II
p.v0 = 3.0;
p.beta0 = 3*pi/4;

%% IVP settings
p.ivpMaxTime = 10;
p.ivpRelTol = 1e-9;
p.ivpAbsTol = 1e-11;


end