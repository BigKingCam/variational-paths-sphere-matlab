function sol = solve_brachistochrone(p)
%SOLVE_BRACHISTOCHRONE Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    p
end

arguments (Output)
    sol
end

mesh = linspace(0, 1, p.N);

solinit = bvpinit( ...
    mesh, ...
    @(tau) guess_brachistochrone(tau, p));

opts = bvpset( ...
    'RelTol', p.RelTol, ...
    'AbsTol', p.AbsTol);

sol = bvp4c( ...
    @(tau,y) ode_brachistochrone(tau, y, p), ...
    @(ya,yb) bc_brachistochrone(ya, yb, p), ...
    solinit, ...
    opts);

end