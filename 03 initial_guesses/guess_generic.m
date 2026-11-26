function y = guess_generic(u,p)
%GUESS_GENERIC Linear coordinate interpolation used as BVP initial guess.
%   Provides a generic solution as the starting point from which to iterate
%   and find numerical solutions.

arguments (Input)
    u  % in [0,1]; for LA by t = p.T * u
    p
end

arguments (Output)
    y
end

% Linear interpolation of coordinates
theta = p.theta0 + u * (p.theta1 - p.theta0);
phi   = p.phi0   + u * (p.phi1 - p.phi0);

% Corresponding constant derivatives with respect to u
thetaU = p.theta1 - p.theta0;
phiU   = p.phi1   - p.phi0;

y = [
    theta
    phi
    thetaU
    phiU
];

end