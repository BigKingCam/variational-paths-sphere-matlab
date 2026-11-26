function E = mechanical_energy( theta, thetaDot, phiDot, p)
%MECHANICAL_ENERGY Total mechanical energy for motion on the sphere.
%   E = MECHANICAL_ENERGY(theta, thetaDot, phiDot, p) returns
%
%       E = T + V
%         = (1/2) m R^2 (thetaDot^2 + sin(theta)^2 phiDot^2)
%           + m g R cos(theta).
%
%   The gravitational field points in the -z direction, with
%   z = R cos(theta), so V = m g z = m g R cos(theta).
%
%   thetaDot and phiDot are derivatives with respect to physical time t.

arguments (Input)
    theta
    thetaDot
    phiDot
    p
end

arguments (Output)
    E
end

v2 = speed_squared( theta, thetaDot, phiDot, p);

E = 0.5 .* p.m .* v2 + p.m .* p.g .* p.R .* cos(theta);

end