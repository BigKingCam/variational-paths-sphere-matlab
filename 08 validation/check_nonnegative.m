function chk = check_nonnegative(x, tol)
%CHECK_NONNEGATIVE Check whether a quantity is nonnegative within tolerance.
%   chk = CHECK_NONNEGATIVE(x, tol) checks
%
%       x >= -tol
%
%   at every finite sample.
%
%   Output fields:
%       pass          - true if all finite samples satisfy the condition
%       minValue      - minimum finite value
%       maxViolation  - max amount by which x falls below zero
%       nChecked      - number of finite samples checked
%       nNonfinite    - number of NaN/Inf samples ignored
%
%   If tol is omitted, tol = 1e-10.

if nargin < 2 || isempty(tol)
    tol = 1e-10;
end

x = x(:);
finiteMask = isfinite(x);
xf = x(finiteMask);

chk.tol = tol;
chk.nChecked = nnz(finiteMask);
chk.nNonfinite = nnz(~finiteMask);

if isempty(xf)
    chk.pass = false;
    chk.minValue = NaN;
    chk.maxViolation = NaN;
    return
end

chk.minValue = min(xf);
chk.maxViolation = max(0, -chk.minValue);
chk.pass = all(xf >= -tol);

end