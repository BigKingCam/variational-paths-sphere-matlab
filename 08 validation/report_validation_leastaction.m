function report_validation_leastaction(val, data_t)
%REPORT_VALIDATION_LEASTACTION Print least-action validation metrics.

arguments (Input)
    val
    data_t
end

arguments (Output)
end

fprintf('\n========================================\n');
fprintf('Least-Action validation\n');
fprintf('========================================\n');

fprintf('Overall:              %s\n', pass_fail(val.valid));

fprintf('\nBoundary conditions:\n');
fprintf('  Max boundary error: %.6e\n', val.maxBoundaryError);
fprintf('  Status:             %s\n', pass_fail(val.boundaryOK));

fprintf('\nMechanical energy:\n');
fprintf('  Initial value:      %.12g\n', val.energy.initial);
fprintf('  Minimum value:      %.12g\n', val.energy.minValue);
fprintf('  Maximum value:      %.12g\n', val.energy.maxValue);
fprintf('  Absolute range:     %.6e\n', val.energy.absRange);
fprintf('  Max abs drift:      %.6e\n', val.energy.maxAbsDrift);
fprintf('  Max rel drift:      %.6e\n', val.energy.maxRelDrift);
fprintf('  Status:             %s\n', pass_fail(val.energy.pass));

fprintf('\nAngular momentum L_z:\n');
fprintf('  Initial value:      %.12g\n', val.angularMomentumZ.initial);
fprintf('  Minimum value:      %.12g\n', val.angularMomentumZ.minValue);
fprintf('  Maximum value:      %.12g\n', val.angularMomentumZ.maxValue);
fprintf('  Absolute range:     %.6e\n', val.angularMomentumZ.absRange);
fprintf('  Max abs drift:      %.6e\n', val.angularMomentumZ.maxAbsDrift);
fprintf('  Max rel drift:      %.6e\n', val.angularMomentumZ.maxRelDrift);
fprintf('  Status:             %s\n', ...
    pass_fail(val.angularMomentumZ.pass));

fprintf('\nPhysical admissibility:\n');
fprintf('  Minimum N:          %.12g\n', val.physical.minNormalForce);
% fprintf('  Max height excess:  %.6e\n', val.physical.maxHeightExcess);
fprintf('  Contact condition:  %s\n', pass_fail(val.physical.contactOK));
% fprintf('  Height condition:   %s\n', pass_fail(val.physical.heightOK));
fprintf('  Overall physical:   %s\n', pass_fail(val.physical.isPhysical));

fprintf('\nTravel time:\n');
fprintf('  T_LA:               %.12g\n', data_t.totalTime);

end


function txt = pass_fail(tf)

if tf
    txt = 'PASS';
else
    txt = 'FAIL';
end

end