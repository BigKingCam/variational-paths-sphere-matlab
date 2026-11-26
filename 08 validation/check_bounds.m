function chk = check_bounds(x, lowerBound, upperBound, tol)
%CHECK_BOUNDS Check whether a quantity lies within prescribed bounds.
%   chk = CHECK_BOUNDS(x, lowerBound, upperBound, tol) checks
%
%       lowerBound - tol <= x <= upperBound + tol
%
%   at every finite sample.
%
%   Either bound may be +/-Inf.
%
%   Output fields:
%       pass               - true if all finite samples satisfy both bounds
%       minValue           - minimum finite value
%       maxValue           - maximum finite value
%       maxLowerViolation  - largest violation below lowerBound
%       maxUpperViolation  - largest violation above upperBound
%       nChecked           - number of finite samples checked
%       nNonfinite         - number of NaN/Inf samples ignored
%
%   If tol is omitted, tol = 1e-10.

arguments (Input)
    x
    lowerBound
    upperBound
    tol
end

arguments (Output)
    chk
end

if nargin < 4 || isempty(tol)
    tol = 1e-10;
end

x = x(:);
finiteMask = isfinite(x);
xf = x(finiteMask);

chk.lowerBound = lowerBound;
chk.upperBound = upperBound;
chk.tol = tol;
chk.nChecked = nnz(finiteMask);
chk.nNonfinite = nnz(~finiteMask);

if isempty(xf)
    chk.pass = false;
    chk.minValue = NaN;
    chk.maxValue = NaN;
    chk.maxLowerViolation = NaN;
    chk.maxUpperViolation = NaN;
    return
end

chk.minValue = min(xf);
chk.maxValue = max(xf);

if isfinite(lowerBound)
    chk.maxLowerViolation = max(0, lowerBound - chk.minValue);
    lowerOK = all(xf >= lowerBound - tol);
else
    chk.maxLowerViolation = 0;
    lowerOK = true;
end

if isfinite(upperBound)
    chk.maxUpperViolation = max(0, chk.maxValue - upperBound);
    upperOK = all(xf <= upperBound + tol);
else
    chk.maxUpperViolation = 0;
    upperOK = true;
end

chk.pass = lowerOK && upperOK;

end