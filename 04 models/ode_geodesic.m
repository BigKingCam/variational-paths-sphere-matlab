function dyds = ode_geodesic(u,y,p)
%ODE_GEODESIC Geodesic ODE system.
%   ODE system defining the Geodesic solution curve.
arguments (Input)
    u
    y
    p
end

arguments (Output)
    dyds
end

theta  = y(1);
thetaU = y(3);
phiU   = y(4);

% Euler-Lagrange equations:
thetaUU = sin(theta) * cos(theta) * phiU^2;
phiUU   = -2 * cot(theta) * thetaU * phiU;

dyds = [
    thetaU
    phiU
    thetaUU
    phiUU
];

end