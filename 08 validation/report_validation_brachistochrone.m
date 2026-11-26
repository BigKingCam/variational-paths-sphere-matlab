function report_validation_brachistochrone(val, data_t)
%REPORT_VALIDATION_BRACHISTOCHRONE Print brachistochrone validation metrics.

arguments (Input)
    val
    data_t
end

arguments (Output)
end

fprintf('\n========================================\n');
fprintf('Brachistochrone validation\n');
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

fprintf('\nPhi momentum:\n');
fprintf('  Initial value:      %.12g\n', val.phiMomentum.initial);
fprintf('  Minimum value:      %.12g\n', val.phiMomentum.minValue);
fprintf('  Maximum value:      %.12g\n', val.phiMomentum.maxValue);
fprintf('  Absolute range:     %.6e\n', val.phiMomentum.absRange);
fprintf('  Max abs drift:      %.6e\n', val.phiMomentum.maxAbsDrift);
fprintf('  Max rel drift:      %.6e\n', val.phiMomentum.maxRelDrift);
fprintf('  Status:             %s\n', pass_fail(val.phiMomentum.pass));

fprintf('\nPhysical admissibility:\n');
fprintf('  Minimum N:          %.12g\n', val.physical.minNormalForce);
fprintf('  Max height excess:  %.6e\n', val.physical.maxHeightExcess);
fprintf('  Contact condition:  %s\n', pass_fail(val.physical.contactOK));
fprintf('  Height condition:   %s\n', pass_fail(val.physical.heightOK));
fprintf('  Overall physical:   %s\n', pass_fail(val.physical.isPhysical));

fprintf('\nTravel time:\n');
fprintf('  T_B:                %.12g\n', data_t.totalTime);

end


function txt = pass_fail(tf)

if tf
    txt = 'PASS';
else
    txt = 'FAIL';
end

end