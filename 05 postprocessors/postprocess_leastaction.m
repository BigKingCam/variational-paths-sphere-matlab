function data_t = postprocess_leastaction(data_u, p)
%POSTPROCESS_LEASTACTION Reparameterize least-action solution u -> t.
%   Converts the normalized computational parameter u in [0,1] to
%   physical time t in [0,T].
%
%   The angular coordinates theta and phi are unchanged. Their
%   derivatives are converted from derivatives with respect to u to
%   derivatives with respect to physical time t.
%
%       t = T u
%
%       dtheta/dt = (1/T) dtheta/du
%       dphi/dt   = (1/T) dphi/du

arguments (Input)
    data_u
    p
end

arguments (Output)
    data_t
end

% Copy all existing solution data
data_t = data_u;

% Preserve computational parameter explicitly
data_t.u = data_u.u;

% Total physical travel time: brachistochrone OR from least-action IVP
data_t.totalTime = p.T;

% Physical time
data_t.t = p.T .* data_u.u;

% Set physical time as the active curve parameter
data_t.param = data_t.t;
data_t.paramName = 't';

% Coordinates do not change under reparameterization
data_t.theta = data_u.theta;
data_t.phi   = data_u.phi;

% Convert derivatives from u to physical time
data_t.dtheta = data_u.dtheta ./ p.T;
data_t.dphi   = data_u.dphi   ./ p.T;

end