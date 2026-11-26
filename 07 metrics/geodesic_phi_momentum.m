function pPhi = geodesic_phi_momentum( theta, dphi, p)
%GEODESIC_PHI_MOMENTUM Conserved phi-momentum for the geodesic problem.
%   pPhi = GEODESIC_PHI_MOMENTUM(theta, dphi, p) returns
%
%       p_phi = R^2 sin(theta)^2 dphi,
%
%   for the quadratic geodesic Lagrangian
%
%       L = (1/2) R^2 (dtheta^2 + sin(theta)^2 dphi^2).
%
%   Here dphi is differentiation with respect to the affine parameter
%   used by the geodesic solver (for example u), not physical time.

arguments (Input)
    theta
    dphi
    p
end

arguments (Output)
    pPhi
end

pPhi = p.R^2 .* sin(theta).^2 .* dphi;

end