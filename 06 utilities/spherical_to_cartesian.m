function cart = spherical_to_cartesian(theta,phi,R)
%SPHERICAL_TO_CARTESIAN Coordinate conversion from spherical to Cartesian.
%   Converts spherical coordinates (theta, phi, R)
%   to Cartesian coordinates (x, y, z).
arguments (Input)
    theta
    phi
    R
end

arguments (Output)
    cart
end

cart.x = R * sin(theta) .* cos(phi) ;
cart.y = R * sin(theta) .* sin(phi) ;
cart.z = R * cos(theta) ;

end