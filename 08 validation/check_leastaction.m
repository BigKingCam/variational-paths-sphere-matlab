function chk = check_leastaction(sol, p)
%CHECK_LEASTACTION Validate a least-action BVP solution on the sphere.
%   chk = CHECK_LEASTACTION(sol,p) checks:
%       1. boundary conditions,
%       2. conservation of mechanical energy,
%       3. conservation of physical z-angular momentum,
%       4. physical admissibility.
%
%   The solver parameter is u in [0,1], with physical time t = T*u.
%
%   Expected state ordering in sol.y:
%       [theta; phi; theta_u; phi_u]
%
%   Required parameters:
%       p.R, p.m, p.g, p.T,
%       p.theta0, p.phi0, p.theta1, p.phi1

[absTol, relTol, bcTol] = local_tolerances(p);

theta = sol.y(1,:);
phi = sol.y(2,:);
theta_u = sol.y(3,:);
phi_u = sol.y(4,:);

thetaDot = theta_u ./ p.T;
phiDot = phi_u ./ p.T;

bcResidual = [ ...
    theta(1) - p.theta0;
    phi(1)   - p.phi0;
    theta(end) - p.theta1;
    phi(end)   - p.phi1];

E = mechanical_energy(theta, thetaDot, phiDot, p);
Lz = mechanical_angular_momentum_z(theta, phiDot, p);

chk.boundaryResidual = bcResidual;
chk.maxBoundaryError = max(abs(bcResidual));
chk.boundaryOK = chk.maxBoundaryError <= bcTol;

chk.energy = check_conservation(E, absTol, relTol);
chk.angularMomentumZ = check_conservation(Lz, absTol, relTol);
chk.physical = check_physical_admissibility(sol, p, "leastaction");

chk.valid = chk.boundaryOK ...
    && chk.energy.pass ...
    && chk.angularMomentumZ.pass ...
    && chk.physical.isPhysical;

end

function [absTol, relTol, bcTol] = local_tolerances(p)
if isfield(p,'AbsTol'), absTol = p.AbsTol; else, absTol = 1e-8; end
if isfield(p,'RelTol'), relTol = p.RelTol; else, relTol = 1e-6; end
if isfield(p,'tolBoundary'), bcTol = p.tolBoundary; else, bcTol = 1e-8; end
end