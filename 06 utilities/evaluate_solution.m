function data = evaluate_solution(sol, p)
%EVALUATE_SOLUTION Evaluate a BVP solution on a uniform parameter grid.
%   Preserves the computational BVP parameter u and initializes the
%   active curve parameter to u.

arguments (Input)
    sol
    p
end

arguments (Output)
    data
end

% Computational BVP parameter
data.u = linspace(sol.x(1), sol.x(end), p.plotN);

% Evaluate BVP solution
Y = deval(sol, data.u);

% State components; derivatives are initially with respect to u
data.theta  = Y(1,:);
data.phi    = Y(2,:);
data.dtheta = Y(3,:);
data.dphi   = Y(4,:);

% Active curve parameter
data.param = data.u;
data.paramName = 'u';

end