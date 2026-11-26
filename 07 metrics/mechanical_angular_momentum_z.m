function lz = mechanical_angular_momentum_z( theta, phiDot, p)
%MECHANICAL_ANGULAR_MOMENTUM_Z z-component of angular momentum.
%   Lz = MECHANICAL_ANGULAR_MOMENTUM_Z(theta, phiDot, p) returns
%
%       L_z = m R^2 sin(theta)^2 phiDot.
%
%   phiDot is the derivative of phi with respect to physical time t.

arguments (Input)
    theta
    phiDot
    p
end

arguments (Output)
    lz
end

lz = p.m .* p.R^2 .* sin(theta).^2 .* phiDot;

end