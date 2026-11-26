function chk = check_quadrature_reference(kind,sol,p,opts)
%CHECK_QUADRATURE_REFERENCE Compare a BVP trajectory with its quadratures.
%   CHK = CHECK_QUADRATURE_REFERENCE(KIND,SOL,P) independently fits the
%   first-integral constants to the boundary data, reconstructs a B or LA
%   trajectory, and compares it with the supplied bvp4c solution.
%
%   The BVP is used to select the polar branch and seed the constant fit.
%   Agreement therefore checks the reduced trajectory on that branch; it
%   does not establish global uniqueness or optimality.
%
%   Outputs include:
%       maxCartesianError   Max. Cartesian distance divided by R
%       rmsCartesianError   RMS Cartesian distance divided by R
%       maxCartesianErrorM  Max. physical Cartesian distance (m)
%       timeError           Absolute BVP/reference time difference (s)
%       constantDifference  Absolute difference in first-integral constants
%       endpointResidual    Largest scaled quadrature boundary residual
%       reference           Reconstructed quadrature solution and metadata
%
arguments
    kind (1,1) string
    sol
    p
    opts.nCompare (1,1) double {mustBeInteger,mustBeGreaterThan(opts.nCompare,2)} = 201
    opts.nSegment (1,1) double {mustBeInteger,mustBeGreaterThan(opts.nSegment,10)} = 301
    opts.RelTol (1,1) double {mustBePositive} = 1e-11
    opts.AbsTol (1,1) double {mustBePositive} = 1e-12
    opts.boundaryTol (1,1) double {mustBePositive} = 1e-8
end

%% Reconstruct the reference and compare Cartesian trajectories

kind = upper(kind);
ref = quadrature_reference(kind,sol,p, ...
    nCompare=opts.nCompare,nSegment=opts.nSegment, ...
    RelTol=opts.RelTol,AbsTol=opts.AbsTol, ...
    boundaryTol=opts.boundaryTol);

% In both problems the BVP parameter u is affine in physical time.
% In B this follows from constant optical speed; in LA, u=t/T.
y = deval(sol,ref.s);

xyzBVP = [ ...
    sin(y(1,:)).*cos(y(2,:)); ...
    sin(y(1,:)).*sin(y(2,:)); ...
    cos(y(1,:))];

xyzQuad = [ ...
    sin(ref.theta).*cos(ref.phi); ...
    sin(ref.theta).*sin(ref.phi); ...
    cos(ref.theta)];

distanceOverR = sqrt(sum((xyzBVP-xyzQuad).^2,1));

chk.kind = kind;
chk.reference = ref;
chk.maxCartesianError = max(distanceOverR);
chk.maxCartesianErrorM = p.R*chk.maxCartesianError;
chk.rmsCartesianError = sqrt(mean(distanceOverR.^2));
chk.numBvpMeshPoints = numel(sol.x);

% Angular coordinate errors are diagnostics only; the principal error
% metric is the Cartesian distance, which avoids azimuth wrap ambiguity.
chk.maxThetaError = max(abs(y(1,:)-ref.theta));
chk.maxPhiError = max(abs(y(2,:)-ref.phi));

%% Compare the first-integral constants and elapsed times

y0 = sol.y(:,1);

if kind == "B"
    D0 = p.v0^2/(2*p.g*p.R) + cos(p.theta0) - cos(y0(1));
    opticalSpeed = sqrt( ...
        (y0(3)^2 + sin(y0(1))^2*y0(4)^2)/D0);

    chk.T_BVP = sqrt(p.R/(2*p.g))*opticalSpeed;
    chk.bvpConstants = sin(y0(1))^2*y0(4)/(D0*opticalSpeed);
else
    thetaDot0 = y0(3)/p.T;
    phiDot0 = y0(4)/p.T;

    chk.T_BVP = p.T;
    chk.bvpConstants = [ ...
        mechanical_energy(y0(1),thetaDot0,phiDot0,p), ...
        p.m*p.R^2*sin(y0(1))^2*phiDot0];
end

chk.referenceConstants = ref.constants;
chk.constantDifference = abs(chk.bvpConstants-ref.constants);
chk.T_quadrature = ref.T;
chk.timeError = abs(chk.T_BVP-ref.T);
chk.endpointResidual = max(abs(ref.endpointResidual));

end
