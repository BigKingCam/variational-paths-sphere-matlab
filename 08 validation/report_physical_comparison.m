function report_physical_comparison(cmp)
%REPORT_PHYSICAL_COMPARISON Print physical comparison results.
%   Focuses on the physical properties of the brachistochrone
%   and least-action trajectories, rather than numerical
%   validation statistics.

arguments (Input)
    cmp
end

fprintf('\n========================================\n');
fprintf('Physical Comparison Report\n');
fprintf('========================================\n');

fprintf('Experiment: Case %s\n', char(cmp.case));
fprintf('Configuration: %s\n', char(cmp.title));

%% Experiment definition

fprintf('\nEXPERIMENT DEFINITION\n');

switch cmp.case
    case "I"
        fprintf('Protocol: Equal travel time\n');
        fprintf('Prescribed: Endpoints, B initial speed\n');
        fprintf('Constraint: T_LA = T_B\n');

    case "II"
        fprintf('Protocol: Equal initial energy\n');
        fprintf('Prescribed: LA initial position and velocity\n');
        fprintf('Constraint: E_LA(0) = E_B(0)\n');
        fprintf('Terminal point: LA first loss of contact\n');
end

fprintf('\nPhysical parameters:\n');
fprintf('  Sphere radius: %.9f m\n', cmp.R);
fprintf('  Particle mass: %.9f kg\n', cmp.m);
fprintf('  Gravity:       %.9f m/s^2\n', cmp.g);

fprintf('\nCommon endpoints (radians):\n');
fprintf('  theta0 = %.12f\n', cmp.theta0);
fprintf('  phi0   = %.12f\n', cmp.phi0);
fprintf('  theta1 = %.12f\n', cmp.theta1);
fprintf('  phi1   = %.12f\n', cmp.phi1);

%% Initial conditions and energy

fprintf('\nINITIAL PHYSICAL CONDITIONS\n');

print_row('Quantity', 'Brachistochrone', 'Least Action');

print_number('Initial speed (m/s)', ...
    cmp.B.v0, cmp.LA.v0);

print_text('Initial direction (deg)', ...
    format_angle(cmp.B.beta0), ...
    format_angle(cmp.LA.beta0));

print_number('Initial kinetic energy (J)', ...
    cmp.B.K0, cmp.LA.K0);

print_number('Initial mechanical energy (J)', ...
    cmp.B.E0, cmp.LA.E0);

fprintf('\nInitial energy difference (LA - B): %.9e J\n', ...
    cmp.deltaEnergy);

%% Travel times and path lengths

fprintf('\nMOTION AND PATH GEOMETRY\n');

print_row('Quantity', 'Brachistochrone', 'Least Action');

print_number('Travel time (s)', ...
    cmp.B.T, cmp.LA.T);

print_number('Arc length (m)', ...
    cmp.B.length, cmp.LA.length);

print_number('Mean speed (m/s)', ...
    cmp.B.meanSpeed, cmp.LA.meanSpeed);

print_number('Final speed (m/s)', ...
    cmp.B.v1, cmp.LA.v1);

fprintf('\nComparative differences (LA - B):\n');

fprintf('  Travel time: %.12f s\n', cmp.deltaTime);
fprintf('  Arc length:  %.12f m\n', cmp.deltaLength);

fprintf('  Relative time difference: %+.6f %%\n', ...
    cmp.percentTimeDifference);

fprintf('  (Positive means B has shorter travel time.)\n');

%% Contact conditions

fprintf('\nCONTACT CONDITIONS\n');

print_row('Quantity', 'Brachistochrone', 'Least Action');

print_number('Initial normal force (N)', ...
    cmp.B.N0, cmp.LA.N0);

print_number('Terminal normal force (N)', ...
    cmp.B.N1, cmp.LA.N1);

print_text('Physically admissible', ...
    yes_no(cmp.B.isPhysical), ...
    yes_no(cmp.LA.isPhysical));

%% Notes

fprintf('\nINTERPRETATION NOTES\n');

if cmp.case == "I"
    fprintf(['  Travel time is prescribed equally; ', ...
        'initial mechanical energy may differ.\n']);
else
    fprintf(['  Initial mechanical energy is prescribed ', ...
        'equally; travel times may differ.\n']);
end

fprintf(['  Reported travel times describe the ', ...
    'computed trajectories.\n']);

fprintf(['  Numerical convergence does not, by itself, ', ...
    'establish global optimality.\n']);

if cmp.B.regularizedStart
    fprintf(['  Brachistochrone: release-from-rest ', ...
        'regularization omits a small initial segment.\n']);
end

if ~cmp.B.isPhysical || ~cmp.LA.isPhysical
    fprintf(['  WARNING: At least one computed trajectory ', ...
        'is not physically admissible.\n']);
end

fprintf(['  See individual validation reports for ', ...
    'numerical accuracy and constraint checks.\n']);

fprintf('\n========================================\n');

end


%% Formatting helpers

function print_row(label, B, LA)

fprintf('\n%-33s %18s %18s\n', label, B, LA);
fprintf('%s\n', repmat('-', 1, 71));

end


function print_number(label, B, LA)

fprintf('%-33s %18.9g %18.9g\n', label, B, LA);

end


function print_text(label, B, LA)

fprintf('%-33s %18s %18s\n', label, B, LA);

end


function txt = format_angle(beta)

if isnan(beta)
    txt = 'undefined';
else
    txt = sprintf('%.6f', rad2deg(beta));
end

end


function txt = yes_no(tf)

if tf
    txt = 'YES';
else
    txt = 'NO';
end

end
