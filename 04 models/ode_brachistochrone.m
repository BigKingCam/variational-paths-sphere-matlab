function dydtau = ode_brachistochrone(tau, y, p)
%ODE_BRACHISTOCHRONE General spherical brachistochrone ODEs.
%   Uses an affine parameter tau for the optical metric
%   associated with the prescribed initial speed p.v0.
%
%   State:
%       y = [theta; phi; thetaTau; phiTau]
%
%   Energy relation:
%       v^2 = 2*g*R*D
%
%       D = kappa + cos(theta0) - cos(theta)
%       kappa = v0^2/(2*g*R)
%
%   The equations are regular for D > 0 and sin(theta) ~= 0.

arguments (Input)
    tau
    y
    p
end

arguments (Output)
    dydtau
end

theta    = y(1);
thetaTau = y(3);
phiTau   = y(4);

% Dimensionless initial kinetic energy
kappa = p.v0^2 / (2 * p.g * p.R);

% Generalized energy factor
D = kappa + cos(p.theta0) - cos(theta);

% Euler-Lagrange equations
thetaTauTau = ...
    ( ...
        sin(theta) * thetaTau^2 ...
        + ( ...
            2 * D * sin(theta) * cos(theta) ...
            - sin(theta)^3 ...
        ) * phiTau^2 ...
    ) / (2 * D);

phiTauTau = ...
    ( ...
        sin(theta)^2 ...
        - 2 * D * cos(theta) ...
    ) * thetaTau * phiTau ...
    / (D * sin(theta));

dydtau = [
    thetaTau
    phiTau
    thetaTauTau
    phiTauTau
];

end
