function out = run_case_II(p)
%RUN_CASE_II Equal-initial-energy comparison.
%   Given:
%       - Initial position
%       - Initial speed p.v0
%       - Least-action launch direction p.beta0
%
%   Procedure:
%       1. Solve least-action IVP until N = 0.
%       2. Obtain terminal position and time T_LA.
%       3. Solve least-action BVP using IVP guess.
%       4. Solve brachistochrone with shared initial energy.
%       5. Solve geodesic between common endpoints.

arguments (Input)
    p
end

arguments (Output)
    out
end

%% 1. Solve least-action IVP

sol_LA_IVP = solve_leastaction_ivp(p);

%% 2. Extract terminal conditions

p.T = sol_LA_IVP.xe(end);

yFinal = sol_LA_IVP.ye(:,end);

p.theta1 = yFinal(1);
p.phi1   = yFinal(2);

%% 3. Solve least-action BVP

sol_LA = solve_leastaction(p, sol_LA_IVP);

%% 4. Solve brachistochrone BVP

% Uses p.v0 and the same initial position.
% The brachistochrone direction is not prescribed.
sol_B = solve_brachistochrone(p);

% Recover independent brachistochrone travel time
data_u_B = evaluate_solution(sol_B, p);

data_t_B = postprocess_brachistochrone( ...
    data_u_B, p);

%% 5. Solve geodesic BVP

sol_G = solve_geodesic(p);

%% 6. Return results

out.p = p;

out.sol_G = sol_G;
out.sol_B = sol_B;
out.sol_LA = sol_LA;

% Preserve IVP solution for comparison
out.sol_LA_IVP = sol_LA_IVP;

% Preserve brachistochrone data
out.data_u_B = data_u_B;
out.data_t_B = data_t_B;

end
