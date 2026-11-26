function plot_sphere_curves(data_G,data_B,data_LA,p,figuresDir,opts)
%PLOT_SPHERE_CURVES Plot G, B, and LA trajectories on a sphere.
%   PLOT_SPHERE_CURVES(...,save=true) exports a figure in the formats
%   selected by savePDF and savePNG. With both enabled, the function
%   writes a vector PDF and a raster PNG using the same filename stem.
%
%   Name-value options:
%     save           - Enable figure export (default: false)
%     showFigure     - Display figure in MATLAB (default: true)
%     savePDF        - Export vector PDF when saving (default: true)
%     savePNG        - Export PNG when saving (default: true)
%     pngResolution  - PNG resolution in DPI (default: 200)
%     presentation   - Use presentation plot style (default: false)
%     zoom           - Camera zoom for all plots (default: 1.0)
%     showLegend     - Show problem-type color legend (default: true)
%     exportPass     - Internal fixed-size rendering pass (do not set)
%
%   Export geometry is fixed at 6 x 6 inches (1:1), independent of the
%   tabbed interactive Figure Container. Requires MATLAB R2025a or newer.
arguments (Input)
    data_G
    data_B
    data_LA
    p
    figuresDir
    opts.save (1,1) logical = false
    opts.showFigure (1,1) logical = true
    opts.savePDF (1,1) logical = true
    opts.savePNG (1,1) logical = true
    opts.pngResolution (1,1) double {mustBeInteger,mustBePositive} = 200
    opts.presentation (1,1) logical = false
    opts.zoom (1,1) double {mustBePositive} = 1.0
    opts.showLegend (1,1) logical = true
    opts.exportPass (1,1) logical = false
end

%% Keep tabbed figures independent of fixed-size exports.
% R2025a+ automatically undocks a figure when its Position is changed.
% Thus, render a separate invisible figure at a fixed size for export.
% The ordinary figure is then created without a Position setting and
% remains a tab in MATLAB's default Figure Container.
if opts.showLegend
    exportWidth  = 6;  % inches
    exportHeight = 6;  % inches
else
    exportWidth  = 6;  % inches
    exportHeight = 5.5;  % inches
end

if opts.save && (opts.savePDF || opts.savePNG) && ~opts.exportPass
    plot_sphere_curves( ...
        data_G,data_B,data_LA,p,figuresDir, ...
        save=true, ...
        showFigure=false, ...
        savePDF=opts.savePDF, ...
        savePNG=opts.savePNG, ...
        pngResolution=opts.pngResolution, ...
        presentation=opts.presentation, ...
        zoom=opts.zoom, ...
        showLegend=opts.showLegend, ...
        exportPass=true);
end

% Export-only mode: the export pass already created and closed its own
% invisible figure. Do not create a separate interactive figure.
if ~opts.showFigure && ~opts.exportPass
    return;
end

curveWidth = 3.5;

color_G  = [0.05 0.48 0.25];
color_B  = [0.00 0.32 0.80];
color_LA = [0.82 0.12 0.12];

if isfield(p, 'experimentID')
    figureName = char(string(p.experimentID));
else
    figureName = char(string(p.case_title));
end

if opts.exportPass
    % This figure is never docked; its aspect ratio defines the export.
    fig = figure( ...
        'Name',figureName, ...
        'NumberTitle','off', ...
        'WindowStyle','normal', ...
        'Visible','off', ...
        'Units','inches', ...
        'Position',[1 1 exportWidth exportHeight]);
else
    % Intentionally leave WindowStyle and Position at their defaults:
    % in R2025a+, figures appear as tabs in the Figure Container.
    fig = figure( ...
        'Name',figureName, ...
        'NumberTitle','off');
end

% Always target axes belonging to this figure. In particular, plotting
% functions that use gca can open a visible figure when the export figure
% has Visible='off'. Explicit targets keep the entire export hidden.
ax = axes('Parent',fig);
hold(ax,'on');

%% Plot styling

if opts.presentation
    textFontSize = 14;
    mathFontSize = 24;
else
    textFontSize = 18;
    mathFontSize = 16;
end

%% Sphere

nSphere = 100;
[X,Y,Z] = sphere(nSphere);

if opts.presentation
    Z(Z < 0) = NaN;
end

if opts.presentation
    sphereAlpha = 0.15;
else
    sphereAlpha = 0.35;
end

surf(ax, ...
    p.R*X, p.R*Y, p.R*Z, ...
    'FaceColor',[0.85 0.85 0.85], ...
    'FaceAlpha',sphereAlpha, ...
    'EdgeColor','none', ...
    'HandleVisibility','off');

%% Spherical coordinate grid

if opts.presentation
    gridColor = [0.68 0.68 0.68];
    gridWidth = 0.4;

    thetaLevels = pi/6 : pi/6 : pi/3;
    thetaGrid   = linspace(0,pi/2,300);
    phiLevels   = 0 : pi/3 : 5*pi/3;
else
    gridColor = [0.55 0.55 0.55];
    gridWidth = 0.4;

    thetaLevels = pi/6 : pi/6 : 5*pi/6;
    thetaGrid   = linspace(0,pi,300);
    phiLevels   = 0 : pi/4 : 7*pi/4; % 0 : pi/6 : 11*pi/6;
end

phiGrid = linspace(0,2*pi,300);

for theta = thetaLevels
    plot3(ax, ...
        p.R*sin(theta).*cos(phiGrid), ...
        p.R*sin(theta).*sin(phiGrid), ...
        p.R*cos(theta).*ones(size(phiGrid)), ...
        'Color',gridColor, ...
        'LineWidth',gridWidth, ...
        'HandleVisibility','off');
end

for phi = phiLevels
    plot3(ax, ...
        p.R*sin(thetaGrid).*cos(phi), ...
        p.R*sin(thetaGrid).*sin(phi), ...
        p.R*cos(thetaGrid), ...
        'Color',gridColor, ...
        'LineWidth',gridWidth, ...
        'HandleVisibility','off');
end

%% Gravity direction

plot3(ax, ...
    [0 0],[0 0],1.2*p.R*[-1 1], ...
    'k--', ...
    'LineWidth',0.8, ...
    'HandleVisibility','off');

quiver3(ax, ...
    0,0,1.35*p.R, ...
    0,0,-0.45*p.R, ...
    0, ...
    'k', ...
    'LineWidth',1.5, ...
    'MaxHeadSize',0.5, ...
    'HandleVisibility','off');

text(ax, ...
    0,0,1.08*p.R, ...
    '$\mathbf{g}$', ...
    'Interpreter','latex', ...
    'FontSize',mathFontSize);

%% Equatorial plane z = 0

if opts.presentation
    discColor = [0.75 0.75 0.75];
    discAlpha = 0.8;
else
    % Keep the equatorial reference plane visible without obscuring
    % the sphere or the trajectories behind it.
    discColor = [0.55 0.55 0.55];
    discAlpha = 0.24;
end
    
rho = linspace(0,p.R,50);
psi = linspace(0,2*pi,150);

[RR,PP] = meshgrid(rho,psi);

Xeq = RR .* cos(PP);
Yeq = RR .* sin(PP);
Zeq = zeros(size(Xeq));

% Filled translucent disk
surf(ax, ...
    Xeq,Yeq,Zeq, ...
    'FaceColor',discColor, ...
    'FaceAlpha',discAlpha, ...
    'EdgeColor','none', ...
    'HandleVisibility','off');

% Circular boundary of the disk
psiEdge = linspace(0,2*pi,400);

plot3(ax, ...
    p.R*cos(psiEdge), ...
    p.R*sin(psiEdge), ...
    zeros(size(psiEdge)), ...
    '--', ...
    'Color',discColor, ...
    'LineWidth',1.2, ...
    'HandleVisibility','off');

% Label of disc
% text(ax, ...
%     0.78*p.R, ...
%     0.12*p.R, ...
%     0.03*p.R, ...
%     '$z=0$', ...
%     'Interpreter','latex', ...
%     'FontSize',11, ...
%     'Color',[0.5 0.5 0.5]);

%% Plot curves slightly above sphere

epsPlot = 0.003;

cart_Gp = spherical_to_cartesian( ...
    data_G.theta, data_G.phi, p.R*(1 + epsPlot));

cart_Bp = spherical_to_cartesian( ...
    data_B.theta, data_B.phi, p.R*(1 + epsPlot));

cart_LAp = spherical_to_cartesian( ...
    data_LA.theta, data_LA.phi, p.R*(1 + epsPlot));

hG = plot3(ax, ...
    cart_Gp.x,cart_Gp.y,cart_Gp.z, ...
    'Color',color_G, ...
    'LineWidth',curveWidth, ...
    'DisplayName','Geodesic');

hB = plot3(ax, ...
    cart_Bp.x,cart_Bp.y,cart_Bp.z, ...
    'Color',color_B, ...
    'LineWidth',curveWidth, ...
    'DisplayName','Brachistochrone');

hLA = plot3(ax, ...
    cart_LAp.x,cart_LAp.y,cart_LAp.z, ...
    'Color',color_LA, ...
    'LineWidth',curveWidth, ...
    'DisplayName','Least Action');

%% Endpoints

epsPoint = 0.006;

cart_0p = spherical_to_cartesian( ...
    p.theta0,p.phi0,p.R*(1 + epsPoint));

cart_1p = spherical_to_cartesian( ...
    p.theta1,p.phi1,p.R*(1 + epsPoint));

if opts.presentation
    endpointSize = 110;
else
    endpointSize = 50;
end
m0Marker = 'o';
m1Marker = '^';
endpointFace = [1 1 1];
endpointEdge = [0 0 0];
endpointAlpha = 0.8;

scatter3(ax, ...
    cart_0p.x,cart_0p.y,cart_0p.z, ...
    endpointSize, ...
    'Marker', m0Marker, ...
    'MarkerFaceColor',endpointFace, ...
    'MarkerEdgeColor',endpointEdge, ...
    'MarkerFaceAlpha',endpointAlpha, ...
    'LineWidth',1.8, ...
    'HandleVisibility','off');

scatter3(ax, ...
    cart_1p.x,cart_1p.y,cart_1p.z, ...
    endpointSize, ...
    'Marker', m1Marker, ...
    'MarkerFaceColor',endpointFace, ...
    'MarkerEdgeColor',endpointEdge, ...
    'MarkerFaceAlpha',endpointAlpha, ...
    'LineWidth',1.8, ...
    'HandleVisibility','off');

% label p0

offset_p0 = [0.00, 0.00, 0.14] * p.R;

text(ax, ...
    cart_0p.x + offset_p0(1), ...
    cart_0p.y + offset_p0(2), ...
    cart_0p.z + offset_p0(3), ...
    '$p_0$', ...
    'Interpreter','latex', ...
    'FontSize',mathFontSize, ...
    'Color',[0 0 0], ...
    'Margin',2, ...
    'EdgeColor','none', ...
    'HorizontalAlignment','center');

% label p1

offset_p1 = [-0.14, -0.22, 0.] * p.R;

text(ax, ...
    cart_1p.x + offset_p1(1), ...
    cart_1p.y + offset_p1(2), ...
    cart_1p.z + offset_p1(3), ...
    '$p_1$', ...
    'Interpreter','latex', ...
    'FontSize',mathFontSize, ...
    'Color',[0 0 0], ...
    'Margin',2, ...
    'EdgeColor','none', ...
    'HorizontalAlignment','center');

%% Endpoint Annotation Box

theta0Str = angle_to_pi_string(p.theta0);
phi0Str   = angle_to_pi_string(p.phi0);
theta1Str = angle_to_pi_string(p.theta1);
phi1Str   = angle_to_pi_string(p.phi1);

if opts.showLegend
    paramText = sprintf( ...
        ['$p_0 = (%s,\\,%s)$\n' ...
         '$p_1 = (%s,\\,%s)$'], ...
        theta0Str,phi0Str,theta1Str,phi1Str);

    endpointBoxPosition = [0.035 0.875 0.57 0.10]; % upper-left
    endpointTextAlignment = 'left';

    hParam = annotation( ...
        fig,'textbox', ...
        endpointBoxPosition, ...
        'String',paramText, ...
        'Interpreter','latex', ...
        'FontSize',textFontSize, ...
        'FitBoxToText','off', ...
        'Margin',0, ...
        'HorizontalAlignment',endpointTextAlignment, ...
        'VerticalAlignment','middle', ...
        'EdgeColor','none');
else
    paramTextp0 = sprintf( ...
        '$p_0 = (%s,\\,%s)$', ...
        theta0Str,phi0Str);

    paramTextp1 = sprintf( ...
        '$p_1 = (%s,\\,%s)$', ...
        theta1Str,phi1Str);

    annotation( ...
        fig,'textbox', ...
        [0.18 0.86 0.30 0.10], ...
        'String',paramTextp0, ...
        'Interpreter','latex', ...
        'FontSize',textFontSize, ...
        'FitBoxToText','off', ...
        'Margin',0, ...
        'HorizontalAlignment','left', ...
        'VerticalAlignment','middle', ...
        'EdgeColor','none');

    annotation( ...
        fig,'textbox', ...
        [0.58 0.86 0.30 0.10], ...
        'String',paramTextp1, ...
        'Interpreter','latex', ...
        'FontSize',textFontSize, ...
        'FitBoxToText','off', ...
        'Margin',0, ...
        'HorizontalAlignment','left', ...
        'VerticalAlignment','middle', ...
        'EdgeColor','none');
end

%% Figure geometry

fig.Color = 'w';
fig.InvertHardcopy = 'off';

set(fig, 'Theme', 'Light');

ax.Units = 'normalized';
ax.Color = 'w';

%% Common axes and camera settings

axis(ax, 'equal');
axis(ax, 'vis3d');

view(ax, -30, 27);
camproj(ax, 'orthographic');
camva(ax, 10);

grid(ax, 'off');
box(ax, 'off');

%% Problem-Type Color Legend

if opts.showLegend
    hLeg = legend(ax,[hG hB hLA], ...
        {'Geodesic','Brachistochrone','Least Action'}, ...
        'Location','none', ...
        'Interpreter','latex', ...
        'FontSize',textFontSize, ...
        'AutoUpdate','off', ...
        'Box','off');

    hLeg.Units = 'normalized';
    hLeg.Position = [0.68 0.825 0.26 0.16];
end

%% Sphere/Curves Plot

if opts.presentation

    % Raise the image so it does not sit below an oversized header.
    if opts.showLegend
        ax.Position = [0.05 0.12 0.90 0.83];
    else
        ax.Position = [0.05 0.12 0.90 0.83];
    end

    % Frame the upper hemisphere
    xlim(ax, 1.12*p.R*[-1 1]);
    ylim(ax, 1.12*p.R*[-1 1]);
    zlim(ax, [0 1.12*p.R]);

    % Focus on the upper sphere
    camtarget(ax, [0 0 0.55*p.R]);

    % Hide axes and tick labels
    axis(ax, 'off');

else

    % Thesis: use the full canvas beneath the corner annotations.
    % Raising the axes also prevents x/y labels clipping at the bottom.
    if opts.showLegend
        ax.Position = [0.06 0.08 0.88 0.88];
    else
        ax.Position = [0.06 0.08 0.88 0.94];
    end

    xlabel(ax, '$x$', 'Interpreter', 'latex');
    ylabel(ax, '$y$', 'Interpreter', 'latex');
    zlabel(ax, '$z$', 'Interpreter', 'latex');

    xlim(ax, 1.15*p.R*[-1 1]);
    ylim(ax, 1.15*p.R*[-1 1]);
    zlim(ax, 1.15*p.R*[-1 1]);

end

% Apply one camera zoom setting after both layout branches.
% Zoom = 1.0 leaves the chosen framing unchanged.
camzoom(ax,opts.zoom);

%% Lighting

lighting(ax,'gouraud');
camlight(ax,'left');
camlight(ax,'right');
material(ax,'dull');


%% Export

if opts.exportPass && opts.save && (opts.savePDF || opts.savePNG)

    if ~isfolder(figuresDir)
        mkdir(figuresDir);
    end

    if opts.presentation
        suffix = '_presentation';
    else
        suffix = '';
    end

    % Both formats share the same filename stem.
    fileBase = sprintf( ...
        'sphere_curves_%s_%d%s', ...
        p.case_title, ...
        p.case_ver, ...
        suffix);

    % Fixed 1:1 full-figure export; includes the endpoint annotation
    % and, when opts.showLegend is true, the color legend.
    drawnow;

    if opts.savePDF
        pdfFile = fullfile(figuresDir, sprintf('%s.pdf',fileBase));
        exportgraphics( ...
            fig,pdfFile, ...
            'ContentType','vector', ...
            'Width',exportWidth, ...
            'Height',exportHeight, ...
            'Units','inches', ...
            'PreserveAspectRatio','on', ...
            'BackgroundColor','white', ...
            'Padding','figure');
    end

    if opts.savePNG
        pngFile = fullfile(figuresDir, sprintf('%s.png',fileBase));
        exportgraphics( ...
            fig,pngFile, ...
            'Resolution',opts.pngResolution, ...
            'Width',exportWidth, ...
            'Height',exportHeight, ...
            'Units','inches', ...
            'PreserveAspectRatio','on', ...
            'BackgroundColor','white', ...
            'Padding','figure');
    end

end

if opts.exportPass
    close(fig);
end

end



%% Helper function for pi/radian LaTeX output

function str = angle_to_pi_string(angle)
%ANGLE_TO_PI_STRING Format angles for LaTeX figure labels.
%   Uses rational multiples of pi only when they are
%   sufficiently simple and numerically accurate.
%
%   Otherwise, displays the angle numerically in radians.

%% Settings

maxDenominator = 24;
tol = 1e-8;
decimalPlaces = 3;

%% Look for a simple rational multiple of pi

ratio = angle / pi;

for d = 1:maxDenominator

    n = round(ratio * d);

    approximation = (n / d) * pi;

    if abs(angle - approximation) <= tol

        if n == 0

            str = '0';

        elseif d == 1

            if n == 1
                str = '\pi';
            elseif n == -1
                str = '-\pi';
            else
                str = sprintf('%d\\pi', n);
            end

        else

            if n == 1
                %str = sprintf('\\frac{\\pi}{%d}', d);
                str = sprintf('\\pi / %d', d);
            elseif n == -1
                %str = sprintf('-\\frac{\\pi}{%d}', d);
                str = sprintf('-\\pi / %d', d);
            else
                %str = sprintf('\\frac{%d\\pi}{%d}', n, d);
                str = sprintf('%d\\pi / %d', n, d);
            end

        end

        return;

    end

end

%% Otherwise use numerical radians

str = sprintf('%.*f', decimalPlaces, angle);  % \\,\\mathrm{rad}

end