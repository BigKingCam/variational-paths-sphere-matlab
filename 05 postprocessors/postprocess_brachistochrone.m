function data_t = postprocess_brachistochrone(data_u, p)
%POSTPROCESS_BRACHISTOCHRONE Convert affine parameter u to time t.
%   Supports the generalized brachistochrone with initial speed v0.
%
%   The energy relation is
%
%       v^2 = v0^2 + 2*g*R*(cos(theta0) - cos(theta)).
%
%   Physical time is recovered from
%
%       dt/du = (ds/du)/v,
%
%   where
%
%       ds/du = R*sqrt(theta_u^2 + sin(theta)^2*phi_u^2).
%
%   The original computational parameter u is preserved.

arguments (Input)
    data_u
    p
end

arguments (Output)
    data_t
end

% Preserve original computational data
data_t = data_u;

theta = data_u.theta;

%% Generalized energy

% Dimensionless initial kinetic energy
kappa = p.v0^2 / (2 * p.g * p.R);

% Energy factor
D = kappa + cos(p.theta0) - cos(theta);

% Require strictly positive available kinetic energy
if any(~isfinite(D(:))) || any(D(:) <= 0)
    error( ...
        'postprocess_brachistochrone:EnergyDomain', ...
        'Nonpositive or nonfinite kinetic-energy factor D.');
end

% Physical speed squared
v2 = 2 .* p.g .* p.R .* D;
v = sqrt(v2);

%% Spatial arc-length derivative

ds_du = p.R .* sqrt( ...
    data_u.dtheta.^2 ...
    + sin(theta).^2 .* data_u.dphi.^2);

if any(~isfinite(ds_du(:))) || any(ds_du(:) <= 0)
    error( ...
        'postprocess_brachistochrone:DegenerateCurve', ...
        'The curve has a nonpositive or nonfinite ds/du.');
end

%% Recover physical time

dt_du = ds_du ./ v;

if any(~isfinite(dt_du(:))) || any(dt_du(:) <= 0)
    error( ...
        'postprocess_brachistochrone:InvalidTime', ...
        'The time transformation is not finite and positive.');
end

% Physical elapsed time
data_t.t = cumtrapz(data_u.u, dt_du);

% Total numerical travel time
data_t.totalTime = data_t.t(end);

% Set physical time as active parameter
data_t.param = data_t.t;
data_t.paramName = 't';

%% Convert derivatives to physical time

data_t.dtheta = data_u.dtheta ./ dt_du;
data_t.dphi   = data_u.dphi   ./ dt_du;

%% Auxiliary physical quantities

% Initial mechanical energy
data_t.initialEnergy = ...
    0.5 * p.m * p.v0^2 ...
    + p.m * p.g * p.R * cos(p.theta0);

% Maximum energetically accessible height
data_t.maxAccessibleHeight = ...
    data_t.initialEnergy / (p.m * p.g);

% Store conversion quantities
data_t.D = D;
data_t.dt_du = dt_du;
data_t.ds_du = ds_du;
data_t.speed = v;

% Reconstructed mechanical energy
data_t.energy = mechanical_energy( ...
    theta, data_t.dtheta, data_t.dphi, p);

% Reconstructed outward normal force
data_t.normalForce = normal_force( ...
    theta, data_t.dtheta, data_t.dphi, p);

end
