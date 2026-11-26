function y = guess_brachistochrone(tau, p)
%GUESS_BRACHISTOCHRONE Initial guess for brachistochrone BVP.
%   Supports both:
%       v0 = 0 : regularized release-from-rest problem
%       v0 > 0 : generalized positive-energy problem
%
%   tau is the normalized affine computational parameter.

arguments (Input)
    tau
    p
end

arguments (Output)
    y
end

%% Determine numerical starting point

if p.v0 == 0
    thetaStart = p.theta0Numerical;
else
    thetaStart = p.theta0;
end

deltaTheta = p.theta1 - thetaStart;
deltaPhi   = p.phi1 - p.phi0;

%% Construct initial guess

if p.v0 == 0

    % Preserve original release-from-rest guess
    theta = thetaStart + deltaTheta .* tau.^2;
    phi   = p.phi0 + deltaPhi .* tau.^3;

    thetaTau = 2 .* deltaTheta .* tau;
    phiTau   = 3 .* deltaPhi .* tau.^2;

else

    % Nondegenerate guess for positive initial speed
    theta = thetaStart + deltaTheta .* tau;
    phi   = p.phi0 + deltaPhi .* tau;

    thetaTau = deltaTheta .* ones(size(tau));
    phiTau   = deltaPhi .* ones(size(tau));

end

%% Output

y = [
    theta
    phi
    thetaTau
    phiTau
];

end
