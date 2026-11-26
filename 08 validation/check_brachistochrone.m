function chk = check_brachistochrone(sol, p)
%CHECK_BRACHISTOCHRONE Validate generalized brachistochrone BVP.
%   Checks:
%       1. Boundary conditions
%       2. Affine optical-metric speed
%       3. Cyclic-phi momentum
%       4. Mechanical-energy consistency
%       5. Physical admissibility
%
%   State:
%       [theta; phi; theta_u; phi_u]

[absTol, relTol, bcTol] = local_tolerances(p);

%% Boundary conditions

% Use the numerical starting point appropriate to v0
if p.v0 == 0
    thetaStart = p.theta0Numerical;
else
    thetaStart = p.theta0;
end

bcResidual = [
    sol.y(1,1)   - thetaStart
    sol.y(2,1)   - p.phi0
    sol.y(1,end) - p.theta1
    sol.y(2,end) - p.phi1
];

chk.boundaryResidual = bcResidual;
chk.maxBoundaryError = max(abs(bcResidual));
chk.boundaryOK = chk.maxBoundaryError <= bcTol;

%% Evaluate solution on a uniform diagnostic grid

nCheck = max(500, numel(sol.x));

if isfield(p, 'plotN')
    nCheck = max(nCheck, p.plotN);
end

u = linspace(sol.x(1), sol.x(end), nCheck);

Y = deval(sol, u);

theta   = Y(1,:);
theta_u = Y(3,:);
phi_u   = Y(4,:);

%% Generalized energy factor

kappa = p.v0^2 / (2 * p.g * p.R);

D = kappa + cos(p.theta0) - cos(theta);

chk.domainOK = all(isfinite(D(:))) && all(D(:) > 0);

%% Affine optical-metric first integrals

q2 = theta_u.^2 ...
    + sin(theta).^2 .* phi_u.^2;

% Constant optical-metric speed squared
C = q2 ./ D;

% Conserved momentum associated with cyclic phi
Jphi = sin(theta).^2 .* phi_u ./ D;

chk.affineSpeed = check_conservation(C, absTol, relTol);
chk.phiMomentum = check_conservation(Jphi, absTol, relTol);

% Reject nonfinite diagnostic samples
chk.affineSpeed.pass = chk.affineSpeed.pass ...
    && chk.affineSpeed.nNonfinite == 0;

chk.phiMomentum.pass = chk.phiMomentum.pass ...
    && chk.phiMomentum.nNonfinite == 0;

%% Mechanical-energy consistency

v2 = 2 .* p.g .* p.R .* D;

E = 0.5 .* p.m .* v2 ...
    + p.m .* p.g .* p.R .* cos(theta);

chk.expectedEnergy = ...
    0.5 * p.m * p.v0^2 ...
    + p.m * p.g * p.R * cos(p.theta0);

chk.energy = check_conservation(E, absTol, relTol);

chk.energy.pass = chk.energy.pass ...
    && chk.energy.nNonfinite == 0;

%% Physical admissibility

chk.physical = check_physical_admissibility( ...
    sol, p, "brachistochrone");

%% Overall status

chk.valid = ...
    chk.boundaryOK ...
    && chk.domainOK ...
    && chk.affineSpeed.pass ...
    && chk.phiMomentum.pass ...
    && chk.energy.pass ...
    && chk.physical.isPhysical;

end


function [absTol, relTol, bcTol] = local_tolerances(p)

if isfield(p, 'AbsTol')
    absTol = p.AbsTol;
else
    absTol = 1e-8;
end

if isfield(p, 'RelTol')
    relTol = p.RelTol;
else
    relTol = 1e-6;
end

if isfield(p, 'tolBoundary')
    bcTol = p.tolBoundary;
else
    bcTol = 1e-8;
end

end
