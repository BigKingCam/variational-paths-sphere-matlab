function [value, isterminal, direction] = event_loss_of_contact(t, y, p)
%EVENT_LOSS_OF_CONTACT Stop IVP at first loss of contact.
%   Detects the first downward zero crossing of the
%   outward normal force N.
%
%   State vector:
%       y = [theta; phi; thetaDot; phiDot]
%
%   All derivatives are with respect to physical time t.

arguments (Input)
    t
    y
    p
end

theta    = y(1);
thetaDot = y(3);
phiDot   = y(4);

% Event occurs when N = 0
value = normal_force(theta, thetaDot, phiDot, p);

% Stop the integration at the event
isterminal = 1;

% Detect only positive-to-negative zero crossings
direction = -1;

end
