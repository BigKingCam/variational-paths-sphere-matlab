function chk = check_geodesic(sol, p)
%CHECK_GEODESIC Validate a spherical geodesic BVP solution.
%   chk = CHECK_GEODESIC(sol,p) checks:
%       1. boundary conditions,
%       2. conservation of quadratic geodesic energy,
%       3. conservation of cyclic phi-momentum.
%
%   Expected state ordering in sol.y:
%       [theta; phi; theta_u; phi_u]
%
%   Required parameters:
%       p.R, p.theta0, p.phi0, p.theta1, p.phi1
%
%   Optional tolerances:
%       p.AbsTol       default 1e-8
%       p.RelTol       default 1e-6
%       p.tolBoundary  default 1e-8

[absTol, relTol, bcTol] = local_tolerances(p);

theta = sol.y(1,:);
phi = sol.y(2,:);
dtheta = sol.y(3,:);
dphi = sol.y(4,:);

bcResidual = [ ...
    theta(1) - p.theta0;
    phi(1)   - p.phi0;
    theta(end) - p.theta1;
    phi(end)   - p.phi1];

Egeo = geodesic_energy(theta, dtheta, dphi, p);
pPhi = geodesic_phi_momentum(theta, dphi, p);
greatCircle = check_great_circle(sol, p);

chk.boundaryResidual = bcResidual;
chk.maxBoundaryError = max(abs(bcResidual));
chk.boundaryOK = chk.maxBoundaryError <= bcTol;

chk.energy = check_conservation(Egeo, absTol, relTol);
chk.phiMomentum = check_conservation(pPhi, absTol, relTol);
chk.greatCircle = greatCircle;

chk.valid = ...
    chk.boundaryOK && ...
    chk.energy.pass && ...
    chk.phiMomentum.pass && ...
    chk.greatCircle.pass;

end

function [absTol, relTol, bcTol] = local_tolerances(p)
if isfield(p,'AbsTol'), absTol = p.AbsTol; else, absTol = 1e-8; end
if isfield(p,'RelTol'), relTol = p.RelTol; else, relTol = 1e-6; end
if isfield(p,'tolBoundary'), bcTol = p.tolBoundary; else, bcTol = 1e-8; end
end