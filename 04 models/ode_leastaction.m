function dydt = ode_leastaction(u,y,p)
%ODE_LEASTACTION Least Action ODE system.
%   ODE system defining the Least Action curve.
arguments (Input)
    u
    y
    p
end

arguments (Output)
    dydt
end

theta  = y(1);
% phi    = y(2);
thetaU = y(3);
phiU   = y(4);

% Euler-Lagrange equations in u = t / T:
thetaUU = ...
    sin(theta) * cos(theta) * phiU^2 ...
    + (p.g * p.T^2 / p.R) * sin(theta);

phiUU = -2 * cot(theta) * thetaU * phiU;


dydt = [
    thetaU
    phiU
    thetaUU
    phiUU
];

end