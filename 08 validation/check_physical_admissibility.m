function chk = check_physical_admissibility(sol, p, problemType)
%CHECK_PHYSICAL_ADMISSIBILITY Test physical admissibility.
%   Checks energy accessibility and unilateral contact.
%
%   Brachistochrone:
%       z <= E_B/(m*g)
%       N >= 0
%
%   Least action:
%       N >= 0
%
%   Geodesic:
%       Not applicable.
%
%   All checks use a numerical tolerance.

arguments (Input)
    sol
    p
    problemType
end

arguments (Output)
    chk
end

%% Tolerance

if isfield(p, 'tolPhysical')
    tol = p.tolPhysical;
else
    tol = 1e-9;
end

problemType = lower(string(problemType));

chk.problemType = problemType;
chk.tol = tol;
chk.applicable = true;

%% Geodesic: not applicable

if problemType == "geodesic"

    chk.applicable = false;
    chk.isPhysical = NaN;

    chk.heightOK = NaN;
    chk.contactOK = NaN;

    chk.minNormalForce = NaN;
    chk.maxHeightExcess = NaN;
    chk.maxAccessibleHeight = NaN;

    chk.z = [];
    chk.z0 = NaN;
    chk.v2 = [];
    chk.N = [];

    chk.heightCheck = [];
    chk.contactCheck = [];

    return
end

%% Sample numerical trajectory

nCheck = max(500, numel(sol.x));

if isfield(p, 'plotN')
    nCheck = max(nCheck, p.plotN);
end

u = linspace(sol.x(1), sol.x(end), nCheck);

Y = deval(sol, u);

theta   = Y(1,:);
theta_u = Y(3,:);
phi_u   = Y(4,:);

% Physical height
z = p.R .* cos(theta);

% Initial height
z0 = p.R .* cos(p.theta0);

%% Problem-specific conditions

switch problemType

    case "brachistochrone"

        % Generalized initial energy
        E0 = 0.5 * p.m * p.v0^2 ...
            + p.m * p.g * z0;

        % Maximum energetically accessible height
        zMax = E0 / (p.m * p.g);

        % Speed squared from energy conservation
        v2 = 2 .* p.g .* (zMax - z);

        % Outward normal force
        N = p.m .* ( ...
            p.g .* cos(theta) - v2 ./ p.R);

        % Energy-accessibility check
        heightCheck = check_bounds( ...
            z, -Inf, zMax, tol);

        % Contact-force check
        contactCheck = check_nonnegative(N, tol);

        chk.heightOK = heightCheck.pass ...
            && heightCheck.nNonfinite == 0;

        chk.contactOK = contactCheck.pass ...
            && contactCheck.nNonfinite == 0;

        chk.isPhysical = ...
            chk.heightOK && chk.contactOK;

        chk.maxHeightExcess = ...
            heightCheck.maxUpperViolation;

        chk.maxAccessibleHeight = zMax;
        chk.heightCheck = heightCheck;

    case {"leastaction", "least_action", "least-action"}

        if ~isfield(p, 'T')
            error( ...
                'check_physical_admissibility:MissingT', ...
                'Least-action validation requires p.T.');
        end

        % Convert normalized-time derivatives
        % to physical-time derivatives
        thetaDot = theta_u ./ p.T;
        phiDot   = phi_u ./ p.T;

        % Physical speed squared
        v2 = speed_squared( ...
            theta, thetaDot, phiDot, p);

        % Outward normal force
        N = normal_force( ...
            theta, thetaDot, phiDot, p);

        % Contact condition
        contactCheck = check_nonnegative(N, tol);

        chk.heightOK = NaN;

        chk.contactOK = contactCheck.pass ...
            && contactCheck.nNonfinite == 0;

        chk.isPhysical = chk.contactOK;

        chk.maxHeightExcess = NaN;
        chk.maxAccessibleHeight = NaN;
        chk.heightCheck = [];

    otherwise

        error( ...
            'check_physical_admissibility:UnknownProblem', ...
            'Unknown problem type "%s".', problemType);

end

%% Common outputs

chk.z = z;
chk.z0 = z0;
chk.v2 = v2;
chk.N = N;

chk.minNormalForce = contactCheck.minValue;
chk.contactCheck = contactCheck;

end
