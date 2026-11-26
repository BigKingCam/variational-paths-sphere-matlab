function p = parameters()
%PARAMETERS Legacy compatibility function; use base_params() in new code.
%   Returns the original defaults WITH the initial-state and physical
%   derived values. Existing calls expecting thetaDot0, E0, N0, etc.
%   therefore continue to work. New batch runs use experiment_params().
p = configure_experiment(base_params(),"I","unequal");
end
