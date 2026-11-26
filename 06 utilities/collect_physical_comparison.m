function cmp = collect_physical_comparison( ...
    comparisonCase, p, ...
    data_u_B, data_t_B, ...
    data_u_LA, data_t_LA, ...
    val_B, val_LA)
%COLLECT_PHYSICAL_COMPARISON Collect physical comparison quantities.
%
%   Compares brachistochrone and least-action solutions.
%   No numerical residuals or conservation drifts are included.
%
%   Case I:  equal travel time   -->  compare physical energies
%   Case II: equal initial mechanical energy  -->  compare travel times

arguments (Input)
    comparisonCase
    p
    data_u_B
    data_t_B
    data_u_LA
    data_t_LA
    val_B
    val_LA
end

arguments (Output)
    cmp
end

%% Experiment information

cmp.case = upper(string(comparisonCase));
cmp.title = string(p.case_title);

cmp.R = p.R;
cmp.m = p.m;
cmp.g = p.g;

cmp.theta0 = p.theta0;
cmp.phi0 = p.phi0;
cmp.theta1 = p.theta1;
cmp.phi1 = p.phi1;

%% Initial potential energy

V0 = p.m * p.g * p.R * cos(p.theta0);

cmp.initialPotentialEnergy = V0;

%% Brachistochrone

% Initial speed is prescribed by the energy model
cmp.B.v0 = p.v0;

% Final speed obtained from reconstructed physical motion
cmp.B.v1 = sqrt(speed_squared( ...
    data_t_B.theta(end), ...
    data_t_B.dtheta(end), ...
    data_t_B.dphi(end), p));

% Initial and total mechanical energy
cmp.B.K0 = 0.5 * p.m * cmp.B.v0^2;
cmp.B.E0 = cmp.B.K0 + V0;

% Travel time
cmp.B.T = data_t_B.totalTime;

% Spatial arc length
cmp.B.length = curve_length(data_u_B, p);

% Mean physical speed
cmp.B.meanSpeed = cmp.B.length / cmp.B.T;

% Initial tangent direction, if speed is nonzero
if p.v0 > 0
    cmp.B.beta0 = tangent_angle( ...
        data_t_B.theta(1), ...
        data_t_B.dtheta(1), ...
        data_t_B.dphi(1));
else
    cmp.B.beta0 = NaN;
end

% Normal force at true initial position
cmp.B.N0 = p.m * ( ...
    p.g * cos(p.theta0) - p.v0^2 / p.R);

% Normal force at terminal position
cmp.B.N1 = normal_force( ...
    data_t_B.theta(end), ...
    data_t_B.dtheta(end), ...
    data_t_B.dphi(end), p);

% Physical admissibility classification
cmp.B.isPhysical = val_B.physical.isPhysical;

% Release-from-rest numerical regularization
cmp.B.regularizedStart = (p.v0 == 0);

%% Least action

% Initial and terminal physical speeds
cmp.LA.v0 = sqrt(speed_squared( ...
    data_t_LA.theta(1), ...
    data_t_LA.dtheta(1), ...
    data_t_LA.dphi(1), p));

cmp.LA.v1 = sqrt(speed_squared( ...
    data_t_LA.theta(end), ...
    data_t_LA.dtheta(end), ...
    data_t_LA.dphi(end), p));

% Initial kinetic and mechanical energy
cmp.LA.K0 = 0.5 * p.m * cmp.LA.v0^2;

cmp.LA.E0 = mechanical_energy( ...
    data_t_LA.theta(1), ...
    data_t_LA.dtheta(1), ...
    data_t_LA.dphi(1), p);

% Travel time
cmp.LA.T = data_t_LA.totalTime;

% Spatial arc length
cmp.LA.length = curve_length(data_u_LA, p);

% Mean physical speed
cmp.LA.meanSpeed = cmp.LA.length / cmp.LA.T;

% Initial tangent direction
if cmp.LA.v0 > 0
    cmp.LA.beta0 = tangent_angle( ...
        data_t_LA.theta(1), ...
        data_t_LA.dtheta(1), ...
        data_t_LA.dphi(1));
else
    cmp.LA.beta0 = NaN;
end

% Normal forces
cmp.LA.N0 = normal_force( ...
    data_t_LA.theta(1), ...
    data_t_LA.dtheta(1), ...
    data_t_LA.dphi(1), p);

cmp.LA.N1 = normal_force( ...
    data_t_LA.theta(end), ...
    data_t_LA.dtheta(end), ...
    data_t_LA.dphi(end), p);

% Physical admissibility
cmp.LA.isPhysical = val_LA.physical.isPhysical;

%% Comparative quantities

% Sign convention: Least Action minus Brachistochrone
cmp.deltaEnergy = cmp.LA.E0 - cmp.B.E0;
cmp.deltaTime = cmp.LA.T - cmp.B.T;
cmp.deltaLength = cmp.LA.length - cmp.B.length;

% Percentage travel-time difference relative to Least Action
cmp.percentTimeDifference = ...
    100 * cmp.deltaTime / cmp.LA.T;

end


%% Local helper: spherical arc length

function L = curve_length(data_u, p)

theta = data_u.theta;

ds_du = p.R .* sqrt( ...
    data_u.dtheta.^2 ...
    + sin(theta).^2 .* data_u.dphi.^2);

L = trapz(data_u.u, ds_du);

end


%% Local helper: tangent direction

function beta = tangent_angle(theta, thetaDot, phiDot)
% Angle from the +e_theta direction toward +e_phi.

vTheta = thetaDot;
vPhi = sin(theta) * phiDot;

beta = atan2(vPhi, vTheta);

end
