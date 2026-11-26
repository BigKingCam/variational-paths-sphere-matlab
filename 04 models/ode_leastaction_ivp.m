function dydt = ode_leastaction_ivp(t, y, p)
%ODE_LEASTACTION_IVP Least-action equations in physical time.
%   Describes gravitational motion constrained to a sphere.
%
%   State vector:
%       y(1) = theta
%       y(2) = phi
%       y(3) = thetaDot
%       y(4) = phiDot
%
%   The independent variable t is physical time.

arguments (Input)
    t
    y
    p
end

arguments (Output)
    dydt
end

theta    = y(1);
thetaDot = y(3);
phiDot   = y(4);

% Euler-Lagrange equations in physical time
thetaDDot = ...
    sin(theta) * cos(theta) * phiDot^2 ...
    + (p.g / p.R) * sin(theta);

phiDDot = ...
    -2 * cot(theta) * thetaDot * phiDot;

% First-order system
dydt = [
    thetaDot
    phiDot
    thetaDDot
    phiDDot
];

end
