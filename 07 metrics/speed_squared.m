function v2 = speed_squared(theta, thetaDot, phiDot, p)
%SPEED_SQUARED Physical speed squared for motion on a sphere.
%   v2 = SPEED_SQUARED(theta, thetaDot, phiDot, p) returns
%
%       v^2 = R^2 (thetaDot^2 + sin(theta)^2 phiDot^2),
%
%   where thetaDot and phiDot are derivatives with respect to physical
%   time t, and p.R is the sphere radius.
%
%   Inputs may be scalars or compatible arrays.

arguments (Input)
    theta
    thetaDot
    phiDot
    p
end

arguments (Output)
    v2
end

v2 = p.R^2 .* (thetaDot.^2 + sin(theta).^2 .* phiDot.^2);

end