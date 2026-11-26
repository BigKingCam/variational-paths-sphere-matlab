function y = guess_leastaction_ivp(u, solIVP, p)
%GUESS_LEASTACTION_IVP Construct BVP guess from an IVP solution.
%   Converts the IVP state in physical time t to the
%   normalized BVP state in u = t/T.
%
%   IVP state:
%       [theta; phi; thetaDot; phiDot]
%
%   BVP state:
%       [theta; phi; thetaU; phiU]

arguments (Input)
    u
    solIVP
    p
end

arguments (Output)
    y
end

% Convert normalized parameter to physical time
t = p.T .* u;

% Evaluate the IVP solution at physical time t
Y = deval(solIVP, t);

% Convert physical-time derivatives to u-derivatives
y = Y;

y(3,:) = p.T .* Y(3,:);
y(4,:) = p.T .* Y(4,:);

end
