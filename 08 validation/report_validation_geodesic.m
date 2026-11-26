function report_validation_geodesic(val)
%REPORT_VALIDATION_GEODESIC Print geodesic validation metrics.

arguments (Input)
    val
end

arguments (Output)
end

fprintf('\n========================================\n');
fprintf('Geodesic validation\n');
fprintf('========================================\n');

fprintf('Overall:              %s\n', pass_fail(val.valid));

fprintf('\nBoundary conditions:\n');
fprintf('  Max boundary error: %.6e\n', val.maxBoundaryError);
fprintf('  Status:             %s\n', pass_fail(val.boundaryOK));

fprintf('\nGeodesic energy:\n');
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

fprintf('\nAnalytic great-circle comparison:\n');
fprintf('  Central angle:      %.12g\n', val.greatCircle.centralAngle);
fprintf('  Arc length:         %.12g\n', val.greatCircle.arcLength);
fprintf('  Max plane residual: %.6e\n', val.greatCircle.maxPlaneError);
fprintf('  Plane status:       %s\n', pass_fail(val.greatCircle.planeOK));

if val.greatCircle.slerpAvailable
    fprintf('  Max SLERP error:    %.6e\n', val.greatCircle.maxSlerpError);
else
    fprintf('  Max SLERP error:    unavailable\n');
end

end


function txt = pass_fail(tf)

if tf
    txt = 'PASS';
else
    txt = 'FAIL';
end

end