function N = normal_force(theta, thetaDot, phiDot, p)
%NORMAL_FORCE Normal force for motion on the exterior of a sphere.
%   N = NORMAL_FORCE(theta, thetaDot, phiDot, p) returns
%
%       N = m * (g*cos(theta) - v^2/R).
%
%   thetaDot and phiDot are derivatives with respect to
%   physical time t.
%
%   N > 0 : positive contact force
%   N = 0 : loss of contact
%   N < 0 : constrained trajectory is physically inadmissible

arguments (Input)
    theta
    thetaDot
    phiDot
    p
end

arguments (Output)
    N
end

% Physical speed squared
v2 = speed_squared(theta, thetaDot, phiDot, p);

% Outward normal reaction
N = p.m .* (p.g .* cos(theta) - v2 ./ p.R);

end