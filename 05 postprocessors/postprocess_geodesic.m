function data_s = postprocess_geodesic(data_u, p)
%POSTPROCESS_GEODESIC Reparameterize affine parameter u by arclength s.
%
%   Computes
%
%       ds/du = R sqrt(theta_u^2 + sin(theta)^2 phi_u^2)
%
%   and integrates to obtain arclength s with s(1) = 0.
%
%   The original computational parameter u is preserved.

arguments (Input)
    data_u
    p
end

arguments (Output)
    data_s
end

% Preserve original data
data_s = data_u;

% Metric speed with respect to computational parameter u
ds_du = p.R .* sqrt( ...
    data_u.dtheta.^2 ...
    + sin(data_u.theta).^2 .* data_u.dphi.^2 );

% Actual arclength measured from the first endpoint
data_s.s = cumtrapz(data_u.u, ds_du);

% Total numerical arclength
data_s.totalLength = data_s.s(end);

% Make arclength the active parameter
data_s.param = data_s.s;
data_s.paramName = 's';

% Coordinates are unchanged
data_s.theta = data_u.theta;
data_s.phi   = data_u.phi;

% Convert derivatives u -> s
data_s.dtheta = data_u.dtheta ./ ds_du;
data_s.dphi   = data_u.dphi   ./ ds_du;

% Useful diagnostic
data_s.ds_du = ds_du;

end