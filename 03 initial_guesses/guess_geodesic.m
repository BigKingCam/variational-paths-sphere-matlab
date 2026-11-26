function y = guess_geodesic(s,p)
%GUESS_GEODESIC
%   Provides the exact geodesic analytic solution as the starting point
%   from which to iterate and find numerical solutions.
arguments (Input)
    s
    p
end

arguments (Output)
    y
end

theta = ...;
phi   = ...;

y = [
    theta
    phi
    p.theta1 - p.theta0
    p.phi1 - p.phi0
];

end