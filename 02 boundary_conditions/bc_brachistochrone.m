function res = bc_brachistochrone(ya, yb, p)
%BC_BRACHISTOCHRONE Fixed endpoint conditions.
%   Uses the true starting point for positive initial speed.
%   Retains a regularized starting point for release from rest.

arguments (Input)
    ya
    yb
    p
end

arguments (Output)
    res
end

% Choose the numerical initial point
if p.v0 == 0
    thetaStart = p.theta0Numerical;
else
    thetaStart = p.theta0;
end

% Boundary residuals
res = [
    ya(1) - thetaStart
    ya(2) - p.phi0
    yb(1) - p.theta1
    yb(2) - p.phi1
];

end
