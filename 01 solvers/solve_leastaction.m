
function sol = solve_leastaction(p, solIVP)
%SOLVE_LEASTACTION Solve the least-action BVP on the sphere.
%   Uses normalized physical time u = t/T in [0,1].
%
%   sol = solve_leastaction(p)
%       Uses a generic initial guess.
%
%   sol = solve_leastaction(p, solIVP)
%       Uses the IVP trajectory as the initial guess.
%
%   Required:
%       p.T, p.theta0, p.phi0, p.theta1, p.phi1

arguments (Input)
    p
    solIVP = []
end

arguments (Output)
    sol
end

% Normalized time mesh
mesh = linspace(0, 1, p.N);

%% Initial guess

if isempty(solIVP)

    % Existing generic linear interpolation
    solinit = bvpinit( ...
        mesh, ...
        @(u) guess_generic(u, p));

else

    % Ensure the BVP time agrees with the IVP event time
    T_IVP = solIVP.xe(end);

    if abs(p.T - T_IVP) > 1e-9 * max(1, abs(T_IVP))
        error( ...
            'solve_leastaction:TimeMismatch', ...
            'BVP time does not agree with IVP terminal time.');
    end

    % Initialize BVP using the IVP trajectory
    solinit = bvpinit( ...
        mesh, ...
        @(u) guess_leastaction_ivp(u, solIVP, p));

end

%% Solver options

opts = bvpset( ...
    'RelTol', p.RelTol, ...
    'AbsTol', p.AbsTol);

%% Solve BVP

sol = bvp4c( ...
    @(u,y) ode_leastaction(u,y,p), ...
    @(ya,yb) bc_sphere(ya,yb,p), ...
    solinit, ...
    opts);

end
