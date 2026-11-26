function sol = solve_leastaction_ivp(p)
%SOLVE_LEASTACTION_IVP Solve least-action initial-value problem.
%   Integrates the physical equations of motion until the
%   particle first loses contact with the sphere.
%
%   Initial state:
%       [theta0; phi0; thetaDot0; phiDot0]
%
%   The numerical solution contains:
%       sol.x  : physical time points
%       sol.y  : solution states
%       sol.xe : terminal event time
%       sol.ye : terminal event state
%       sol.ie : terminal event index

arguments (Input)
    p
end

arguments (Output)
    sol
end

% Initial state
y0 = p.y0_LA_IVP;

% Verify positive initial contact
N0 = normal_force(y0(1), y0(3), y0(4), p);

if ~isfinite(N0) || N0 <= 0
    error( ...
        'solve_leastaction_ivp:InitialContact', ...
        'Initial normal force must be positive.');
end

% Integration interval in physical time
tspan = [0, p.ivpMaxTime];

% Solver options
opts = odeset( ...
    'RelTol', p.ivpRelTol, ...
    'AbsTol', p.ivpAbsTol, ...
    'Events', @(t,y) event_loss_of_contact(t,y,p));

% Solve initial-value problem
sol = ode45( ...
    @(t,y) ode_leastaction_ivp(t,y,p), ...
    tspan, ...
    y0, ...
    opts);

% Require successful terminal event detection
if isempty(sol.xe) || ~any(sol.ie == 1)
    error( ...
        'solve_leastaction_ivp:NoDetachment', ...
        ['No loss-of-contact event was detected ', ...
         'before t = %.6g s.'], ...
        p.ivpMaxTime);
end

end
