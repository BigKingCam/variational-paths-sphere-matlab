function chk = check_conservation(q, absTol, relTol)
%CHECK_CONSERVATION Quantify numerical drift of an expected invariant.
%   chk = CHECK_CONSERVATION(q, absTol, relTol) compares all finite samples
%   of q with the first finite sample q0.
%
%   A sample passes when
%
%       |q - q0| <= absTol + relTol*max(1,|q0|).
%
%   Output fields include the initial value, extrema, absolute range,
%   relative range, maximum absolute/relative drift, and pass/fail status.
%
%   Defaults:
%       absTol = 1e-8
%       relTol = 1e-6

if nargin < 2 || isempty(absTol)
    absTol = 1e-8;
end
if nargin < 3 || isempty(relTol)
    relTol = 1e-6;
end

q = q(:);
finiteMask = isfinite(q);
qf = q(finiteMask);

chk.absTol = absTol;
chk.relTol = relTol;
chk.nChecked = nnz(finiteMask);
chk.nNonfinite = nnz(~finiteMask);

if isempty(qf)
    chk.pass = false;
    chk.initial = NaN;
    chk.minValue = NaN;
    chk.maxValue = NaN;
    chk.absRange = NaN;
    chk.relRange = NaN;
    chk.maxAbsDrift = NaN;
    chk.maxRelDrift = NaN;
    chk.allowedDrift = NaN;
    return
end

q0 = qf(1);
drift = abs(qf - q0);

chk.initial = q0;
chk.minValue = min(qf);
chk.maxValue = max(qf);
chk.absRange = chk.maxValue - chk.minValue;

scale = max(1, abs(q0));
chk.relRange = chk.absRange / scale;
chk.maxAbsDrift = max(drift);
chk.maxRelDrift = chk.maxAbsDrift / scale;
chk.allowedDrift = absTol + relTol * scale;
chk.pass = chk.maxAbsDrift <= chk.allowedDrift;

end