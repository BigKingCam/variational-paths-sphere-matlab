function [outputArg1,outputArg2] = export_figure(inputArg1,inputArg2)
%EXPORT_FIGURE Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    inputArg1
    inputArg2
end

arguments (Output)
    outputArg1
    outputArg2
end

exportgraphics( ...
    gcf, ...
    'sphere_comparison.pdf', ...
    'ContentType','vector');

end