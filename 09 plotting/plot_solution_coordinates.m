function plot_solution_coordinates( data)
%PLOT_SOLUTION_COORDINATES Plot angular coordinates along active parameter.

arguments (Input)
    data
end

figure;

plot(data.param, data.theta(:), 'LineWidth', 1.5);
hold on;
plot(data.param, data.phi(:), 'LineWidth', 1.5);

xlabel(data.paramName);
ylabel('Angle');

legend( ...
    ['\theta(', data.paramName, ')'], ...
    ['\phi(', data.paramName, ')'], ...
    'Location', 'best');

grid on;

end