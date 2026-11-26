function E_G = geodesic_energy( theta, dtheta, dphi, p)
%GEODESIC_ENERGY Quadratic geodesic energy.
%   Egeo = GEODESIC_ENERGY(theta, dtheta, dphi, p) returns
%
%       E_geo = (1/2) R^2 (dtheta^2 + sin(theta)^2 dphi^2).
%
%   dtheta and dphi are derivatives with respect to the affine parameter
%   used by the geodesic solver (for example u), not physical time.
%
%   If that affine parameter is arclength s, then E_geo = 1/2 for a
%   unit-speed parameterization.

arguments (Input)
    theta
    dtheta
    dphi
    p
end

arguments (Output)
    E_G
end

E_G = 0.5 .* p.R^2 .* ...
    (dtheta.^2 + sin(theta).^2 .* dphi.^2);

end