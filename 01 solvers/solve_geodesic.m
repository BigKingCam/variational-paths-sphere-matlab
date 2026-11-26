function sol = solve_geodesic(p)
%SOLVE_GEODESIC Solve the spherical geodesic as a boundary-value problem.
%   Solves the affine geodesic equations connecting the endpoints specified
%   in p using MATLAB's bvp4c.
arguments (Input)
    p
end

arguments (Output)
    sol
end

% Normalized affine parameter u in [0,1]
mesh = linspace(0, 1, p.N);

% Initial guess for the entire solution curve
solinit = bvpinit( ...
    mesh, ...
    @(u) guess_generic(u, p));

% Solver tolerances
opts = bvpset( ...
    'RelTol', p.RelTol, ...
    'AbsTol', p.AbsTol);

% Solve boundary-value problem
sol = bvp4c( ...
    @(u, y) ode_geodesic(u, y, p), ...
    @(ya, yb) bc_sphere(ya, yb, p), ...
    solinit, ...
    opts);

end