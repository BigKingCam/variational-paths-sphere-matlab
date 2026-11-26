function out = run_case_I(p)
%RUN_CASE_I Equal-travel-time comparison.
%   Given:
%       - Initial and final positions
%       - Initial brachistochrone speed p.v0
%
%   Procedure:
%       1. Solve brachistochrone BVP.
%       2. Determine its physical travel time T_B.
%       3. Set least-action travel time T = T_B.
%       4. Solve least-action and geodesic BVPs.
%
%   The least-action initial energy is not prescribed.

arguments (Input)
    p
end

arguments (Output)
    out
end

%% 1. Solve brachistochrone

sol_B = solve_brachistochrone(p);

%% 2. Determine brachistochrone travel time

data_u_B = evaluate_solution(sol_B, p);

data_t_B = postprocess_brachistochrone( ...
    data_u_B, p);

T_B = data_t_B.totalTime;

if ~isfinite(T_B) || T_B <= 0
    error( ...
        'run_case_I:InvalidTime', ...
        'Brachistochrone travel time must be positive.');
end

%% 3. Set common travel time

p.T = T_B;

%% 4. Solve remaining BVPs

sol_G = solve_geodesic(p);

% Generic initial guess; no least-action IVP
sol_LA = solve_leastaction(p);

%% 5. Return results

out.p = p;

out.sol_G = sol_G;
out.sol_B = sol_B;
out.sol_LA = sol_LA;

% No IVP is performed in Case I
out.sol_LA_IVP = [];

% Retain computed brachistochrone data
out.data_u_B = data_u_B;
out.data_t_B = data_t_B;

end
