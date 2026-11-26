function res = bc_leastaction(ya,yb,p)
%BC_LEASTACTION Fixed endpoint boundary conditions on the sphere.
%   Endpoints constraints that the curve solution must satisfy.
arguments (Input)
    ya
    yb
    p
end

arguments (Output)
    res
end

res = [
    ya(1) - p.theta0
    ya(2) - p.phi0
    yb(1) - p.theta1
    yb(2) - p.phi1
];

end