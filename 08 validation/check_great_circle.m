function gc = check_great_circle(sol, p)
%CHECK_GREAT_CIRCLE Compare numerical geodesic with great circle.
%
%   The primary check verifies that the numerical Cartesian points lie in
%   the plane through the origin and the two prescribed endpoints.
%
%   A secondary SLERP comparison checks the pointwise agreement with the
%   minor great-circle arc parameterized affinely by u in [0,1].
%
%   Required:
%       p.R, p.theta0, p.phi0, p.theta1, p.phi1
%
%   Optional:
%       p.tolGreatCircle   default 1e-6

arguments (Input)
    sol
    p
end

arguments (Output)
    gc
end

theta = sol.y(1,:);
phi   = sol.y(2,:);
u     = sol.x;

% Unit Cartesian vectors for numerical solution
rhat = [ ...
    sin(theta).*cos(phi);
    sin(theta).*sin(phi);
    cos(theta)];

% Endpoint unit vectors
r0 = [ ...
    sin(p.theta0)*cos(p.phi0);
    sin(p.theta0)*sin(p.phi0);
    cos(p.theta0)];

r1 = [ ...
    sin(p.theta1)*cos(p.phi1);
    sin(p.theta1)*sin(p.phi1);
    cos(p.theta1)];

%% Great-circle plane check

normalRaw = cross(r0, r1);
normalNorm = norm(normalRaw);

if normalNorm < 1e-12
    error(['Great-circle plane is not uniquely determined because ', ...
           'the endpoints are coincident or antipodal.']);
end

n = normalRaw / normalNorm;

% Signed dimensionless distance from the great-circle plane
planeResidual = n.' * rhat;

gc.planeResidual = planeResidual;
gc.maxPlaneError = max(abs(planeResidual));

if isfield(p, 'tolGreatCircle')
    tolGC = p.tolGreatCircle;
else
    tolGC = 1e-6;
end

gc.planeOK = gc.maxPlaneError <= tolGC;

%% Analytic minor-arc solution (SLERP)

dot01 = dot(r0, r1);

% Protect acos from floating-point overshoot
dot01 = max(-1, min(1, dot01));

alpha = acos(dot01);

gc.centralAngle = alpha;
gc.arcLength = p.R * alpha;  % exact, analytic arc length (not numerical)

sinAlpha = sin(alpha);

if abs(sinAlpha) < 1e-12
    gc.slerpError = NaN(size(u));
    gc.maxSlerpError = NaN;
    gc.slerpAvailable = false;
else
    A = sin((1-u)*alpha) / sinAlpha;
    B = sin(u*alpha) / sinAlpha;

    rhatExact = r0*A + r1*B;

    % Euclidean chord error on the unit sphere
    slerpError = vecnorm(rhat - rhatExact, 2, 1);

    gc.slerpError = slerpError;
    gc.maxSlerpError = max(slerpError);
    gc.slerpAvailable = true;
end

% The plane test is the branch-independent analytic great-circle test.
gc.pass = gc.planeOK;

end