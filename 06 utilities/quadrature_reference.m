function ref = quadrature_reference(kind, sol, p, opts)
%QUADRATURE_REFERENCE Reconstruct a trajectory from boundary-fitted quadratures.
%   REF = QUADRATURE_REFERENCE(KIND,SOL,P) reconstructs the spherical
%   brachistochrone (KIND="B") or stationary-action trajectory (KIND="LA")
%   by quadratures of the first integrals from Chapters 4 and 5.
%
%   The BVP identifies the polar branch and seeds the constant search.
%   Its trajectory is not used in the quadrature reconstruction or in
%   the reference boundary residuals.
%
%   Supports monotone polar motion or ONE simple polar turning point. A
%   constant-latitude trajectory, multiple turns, pole crossings, and the
%   singular release-from-rest endpoint are not supported. For v0=0, the
%   numerical regularized theta0Numerical is used as the starting endpoint.
%
%   REF.theta(s), REF.phi(s) are evaluated at normalized physical time
%   s=linspace(0,1,opts.nCompare). REF.T is physical elapsed time.
%
%   Name-value options:
%       nCompare      Number of comparison points (default 201)
%       nSegment      Interpolation nodes per polar segment (default 301)
%       RelTol        Quadrature tolerance (default 1e-11)
%       AbsTol        Quadrature tolerance (default 1e-12)
%       boundaryTol   Maximum scaled boundary residual (default 1e-8)
%
%   Branch selection is not independent of the BVP. The conserved
%   quantities, however, are fitted to the prescribed boundary data
%   rather than copied from the BVP solution. The cumulative reference
%   curves use pchip interpolation, so their accuracy is resolution-limited.

arguments
    kind (1,1) string
    sol
    p
    opts.nCompare (1,1) double {mustBeInteger,mustBeGreaterThan(opts.nCompare,2)} = 201
    opts.nSegment (1,1) double {mustBeInteger,mustBeGreaterThan(opts.nSegment,10)} = 301
    opts.RelTol (1,1) double {mustBePositive} = 1e-11
    opts.AbsTol (1,1) double {mustBePositive} = 1e-12
    opts.boundaryTol (1,1) double {mustBePositive} = 1e-8
end

kind = upper(kind);
if ~ismember(kind,["B","LA"])
    error('quadrature_reference:Kind','KIND must be "B" or "LA".');
end

if kind == "B" && p.v0 == 0
    thetaA = p.theta0Numerical;
else
    thetaA = p.theta0;
end
thetaB = p.theta1;
dphi = p.phi1 - p.phi0;
if ~(thetaA>0 && thetaA<pi && thetaB>0 && thetaB<pi)
    error('quadrature_reference:Poles','Both endpoints must lie away from the poles.');
end

% Detect at most one genuine polar turn by examining BVP theta derivatives.
probe = deval(sol,linspace(sol.x(1),sol.x(end),401));
if any(probe(1,:)<=1e-5 | probe(1,:)>=pi-1e-5)
    error('quadrature_reference:PoleCrossing', ...
        'A trajectory passing through a spherical pole is not supported.');
end
v = probe(3,:);
vTol = max(1e-10,1e-5*max(abs(v)));
significant = sign(v(abs(v)>vTol));
if isempty(significant)
    error('quadrature_reference:Latitude','Constant-latitude solutions need a separate formula.');
end
nTurns = sum(diff(significant)~=0);
if nTurns>1
    error('quadrature_reference:MultipleTurns', ...
        'This reference supports at most one polar turning point.');
end
if nTurns==0
    turn = "none";
elseif significant(1)<0
    turn = "lower";
else
    turn = "upper";
end

% Seed quantities, never used as the final quadrature constants.
y0 = sol.y(:,1);
if kind == "B"
    D0 = p.v0^2/(2*p.g*p.R)+cos(p.theta0)-cos(y0(1));
    C0 = (y0(3)^2+sin(y0(1))^2*y0(4)^2)/D0;
    seedJ = (sin(y0(1))^2*y0(4)/D0)/sqrt(C0);
    if ~(C0>0 && isfinite(seedJ))
        error('quadrature_reference:BVPSeed','Invalid optical-speed/momentum seed.');
    end
    initial = seedJ;
else
    edot = y0(3)/p.T;
    pdot = y0(4)/p.T;
    seedE = mechanical_energy(y0(1),edot,pdot,p);
    seedL = p.m*p.R^2*sin(y0(1))^2*pdot;
    initial = [seedE,seedL];
end

% Endpoint-only nonlinear fitting of the first-integral constants.
if kind == "B"
    if abs(dphi)<1e-13
        constants = 0;
    else
        direction = sign(dphi);
        % J and DeltaPhi have the same sign on every regular branch.
        seed = abs(initial);
        if turn == "none"
            th = linspace(min(thetaA,thetaB),max(thetaA,thetaB),301);
            D = p.v0^2/(2*p.g*p.R)+cos(p.theta0)-cos(th);
            jMax = sqrt(min(sin(th).^2./D));
            if ~(isfinite(jMax) && jMax>0)
                error('quadrature_reference:Energy','No real monotone optical branch.');
            end
            jUpper = (1-1e-9)*jMax;
        else
            % A turn necessarily occurs before both endpoints, so the
            % momentum cannot exceed its turning-at-endpoint bound.
            endpoint = min(thetaA,thetaB);
            if turn == "upper", endpoint = max(thetaA,thetaB); end
            D = p.v0^2/(2*p.g*p.R)+cos(p.theta0)-cos(endpoint);
            jUpper = (1-1e-9)*sqrt(sin(endpoint)^2/D);
        end
        seed = min(max(seed,1e-12*jUpper),0.999999*jUpper);
        % Match azimuthal displacement by a scalar *root*, not by
        % simply reusing the BVP-derived momentum.
        f = @(j) phi_residual(direction*j,kind,turn,thetaA,thetaB,dphi,p,opts);
        jj = unique([linspace(1e-9*jUpper,jUpper,81),seed]);
        rr = arrayfun(f,jj);
        ix = find(isfinite(rr(1:end-1)) & isfinite(rr(2:end)) & ...
                  rr(1:end-1).*rr(2:end)<=0);
        if ~isempty(ix)
            % If several branches fit, choose the bracket nearest the
            % observed branch's momentum. This selects the branch only.
            centers=(jj(ix)+jj(ix+1))/2;
            [~,which]=min(abs(centers-seed));
            ii=ix(which);
            jOpt=fzero(f,[jj(ii),jj(ii+1)], ...
                optimset('TolX',max(1e-13,1e-12*jUpper),'Display','off'));
        else
            % Near a tangent root a signed bracket may not exist.
            % A strictly checked minimization provides a fallback.
            costs=rr.^2; costs(~isfinite(costs))=Inf;
            [~,best]=min(costs);
            il=max(1,best-1); ir=min(numel(jj),best+1);
            if il==ir
                error('quadrature_reference:NoBRoot','Could not bracket the B momentum.');
            end
            [jOpt,~]=fminbnd(@(j) scalar_cost(direction*j,kind,turn, ...
                thetaA,thetaB,dphi,p,opts),jj(il),jj(ir), ...
                optimset('TolX',max(1e-13,1e-12*jUpper),'Display','off'));
        end
        constants=direction*jOpt;

    end
else
    scaleE = p.m*p.g*p.R;
    scaleL = p.m*p.R^2/p.T;
    if abs(dphi)<1e-13
        % No azimuthal winding: Lz=0, solve for energy only.
        x0 = initial(1)/scaleE;
        fun = @(x) scalar_cost([x*scaleE,0],kind,turn,thetaA,thetaB,dphi,p,opts);
        z = fminsearch(fun,x0,optimset('TolX',1e-12,'TolFun',1e-23, ...
            'MaxFunEvals',1500,'MaxIter',1000,'Display','off'));
        constants = [z*scaleE,0];
    else
        x0 = [initial(1)/scaleE, initial(2)/scaleL];
        fun = @(x) scalar_cost([x(1)*scaleE,x(2)*scaleL], ...
            kind,turn,thetaA,thetaB,dphi,p,opts);
        searchOpts = optimset('TolX',1e-12,'TolFun',1e-23, ...
            'MaxFunEvals',2500,'MaxIter',1500,'Display','off');
        x = fminsearch(fun,x0,searchOpts);
        constants = [x(1)*scaleE,x(2)*scaleL];
    end
end

[time,phiGain,thetaStar,segments] = totals(constants,kind,turn,thetaA,thetaB,p,opts);
if ~isfinite(time)
    error('quadrature_reference:NoReference','No real quadrature on the selected polar branch.');
end
if kind == "B"
    residual = (phiGain-dphi)/max(1,abs(dphi));
else
    residual = [(time-p.T)/p.T, (phiGain-dphi)/max(1,abs(dphi))];
end
if max(abs(residual))>opts.boundaryTol
    error('quadrature_reference:BoundaryFit', ...
        'Quadrature constants did not satisfy the endpoint equations (residual %.3g).', ...
        max(abs(residual)));
end

% Integrate cumulative t(theta) and phi(theta) on the selected segments.
Tcurve = []; Pcurve = []; THcurve = [];
for k=1:size(segments,1)
    a=segments(k,1); b=segments(k,2);
    startTurn = (turn~="none" && k==2);
    endTurn = (turn~="none" && k==1);
    [tloc,ploc,thloc] = cumulative_segment(a,b,constants,kind,p,opts, ...
        startTurn,endTurn);
    if ~isempty(Tcurve)
        tloc=tloc(2:end); ploc=ploc(2:end); thloc=thloc(2:end);
    end
    Tcurve=[Tcurve, last_or_zero(Tcurve)+tloc]; %#ok<AGROW>
    Pcurve=[Pcurve, last_or_zero(Pcurve)+ploc]; %#ok<AGROW>
    THcurve=[THcurve,thloc]; %#ok<AGROW>
end

if any(diff(Tcurve)<=0)
    error('quadrature_reference:Time','Quadrature time must increase strictly.');
end
sgrid = linspace(0,1,opts.nCompare);
ref.s = sgrid;
ref.theta = interp1(Tcurve./Tcurve(end),THcurve,sgrid,'pchip');
ref.phi = p.phi0+interp1(Tcurve./Tcurve(end),Pcurve,sgrid,'pchip');
ref.theta(1)=thetaA; ref.theta(end)=thetaB;
ref.phi(1)=p.phi0;
ref.T = time;
ref.constants = constants;
ref.turn = turn;
ref.thetaTurn = thetaStar;
ref.endpointResidual = residual;
ref.fitType = 'endpoint-fitted; BVP used for branch and initial guess';
ref.kind = kind;
end

function val = last_or_zero(v)
if isempty(v), val=0; else, val=v(end); end
end

function f=phi_residual(c,kind,turn,a,b,dphi,p,opts)
try
    [~,phi] = totals(c,kind,turn,a,b,p,opts);
    f=phi-dphi;
catch
    f=NaN;
end
end

function obj=scalar_cost(c,kind,turn,a,b,dphi,p,opts)
try
    [T,phi] = totals(c,kind,turn,a,b,p,opts);
    if kind=="B"
        obj = ((phi-dphi)/max(1,abs(dphi)))^2;
    else
        obj = ((T-p.T)/p.T)^2 + ((phi-dphi)/max(1,abs(dphi)))^2;
    end
    if ~isfinite(obj), obj=1e12; end
catch
    obj=1e12;
end
end

function [T,phi,star,segs]=totals(c,kind,turn,a,b,p,opts)
star=NaN;
if turn=="none"
    segs=[a,b];
else
    star=find_turn(c,kind,turn,a,b,p);
    segs=[a,star;star,b];
end
T=0; phi=0;
for k=1:size(segs,1)
    isTurn=(turn~="none");
    [dt,dp]=segment_total(segs(k,1),segs(k,2),c,kind,p,opts,isTurn);
    T=T+dt;
    phi=phi+dp;
end
end

function star=find_turn(c,kind,turn,a,b,p)
if turn=="lower"
    edge=min(a,b);
    search=linspace(edge,1e-5,401);
else
    edge=max(a,b);
    search=linspace(edge,pi-1e-5,401);
end
vals=radicand(search,c,kind,p);
if ~isfinite(vals(1)) || vals(1)<=0
    error('quadrature_reference:TurnDomain','Endpoint outside the allowed polar region.');
end
idx=find(vals(2:end)<=0 & isfinite(vals(2:end)),1,'first');
if isempty(idx)
    error('quadrature_reference:NoTurn','No turning point outside the endpoint interval.');
end
star=fzero(@(th) radicand(th,c,kind,p),[search(idx),search(idx+1)]);
if kind=="B"
    Dstar=p.v0^2/(2*p.g*p.R)+cos(p.theta0)-cos(star);
    if Dstar<=1e-10
        error('quadrature_reference:OpticalDegeneracy', ...
            'The polar zero is at D=0, not a regular optical turn.');
    end
end
if abs(star-edge)<1e-9
    error('quadrature_reference:DegenerateSegment','Turning point coincides with endpoint.');
end
end

function [dt,dp]=segment_total(a,b,c,kind,p,opts,hasTurn)
if a==b
    dt=0;dp=0;return
end
if hasTurn
    % A simple polar turning point is at one endpoint of each segment.
    % totals() constructs segments [a,theta*] and [theta*,b].
    if abs(radicand(a,c,kind,p))<abs(radicand(b,c,kind,p))
        turnTheta=a; outer=b;
    else
        turnTheta=b; outer=a;
    end
    lim=sqrt(abs(outer-turnTheta));
    ft=@(z) turn_integrand(z,turnTheta,sign(outer-turnTheta),c,kind,p,false);
    fp=@(z) turn_integrand(z,turnTheta,sign(outer-turnTheta),c,kind,p,true);
    dt=integral(ft,0,lim,'RelTol',opts.RelTol,'AbsTol',opts.AbsTol);
    dp=integral(fp,0,lim,'RelTol',opts.RelTol,'AbsTol',opts.AbsTol);
else
    lo=min(a,b); hi=max(a,b);
    check=radicand(linspace(lo,hi,25),c,kind,p);
    if any(~isfinite(check)|check<=0)
        error('quadrature_reference:Radicand','Nonpositive radicand on a monotone branch.');
    end
    ft=@(th) base_t_integrand(th,c,kind,p);
    fp=@(th) ft(th).*omega(th,c,kind,p);
    dt=integral(ft,lo,hi,'RelTol',opts.RelTol,'AbsTol',opts.AbsTol);
    dp=integral(fp,lo,hi,'RelTol',opts.RelTol,'AbsTol',opts.AbsTol);
end
end

function [t,ph,th]=cumulative_segment(a,b,c,kind,p,opts,startTurn,endTurn)
n=opts.nSegment;
if startTurn||endTurn
    if startTurn, star=a; outer=b; else, star=b; outer=a; end
    sg=sign(outer-star);
    z=linspace(0,sqrt(abs(outer-star)),n);
    thAtZ=star+sg*z.^2;
    tAtZ=zeros(1,n);pAtZ=zeros(1,n);
    ft=@(q) turn_integrand(q,star,sg,c,kind,p,false);
    fp=@(q) turn_integrand(q,star,sg,c,kind,p,true);
    for j=2:n
        tAtZ(j)=integral(ft,0,z(j),'RelTol',opts.RelTol,'AbsTol',opts.AbsTol);
        pAtZ(j)=integral(fp,0,z(j),'RelTol',opts.RelTol,'AbsTol',opts.AbsTol);
    end
    if startTurn
        th=thAtZ; t=tAtZ; ph=pAtZ;
    else
        th=fliplr(thAtZ);
        t=fliplr(tAtZ(end)-tAtZ);
        ph=fliplr(pAtZ(end)-pAtZ);
    end
else
    th=linspace(a,b,n);
    t=zeros(1,n);ph=zeros(1,n);
    ft=@(q) base_t_integrand(q,c,kind,p);
    fp=@(q) ft(q).*omega(q,c,kind,p);
    for j=2:n
        lo=min(a,th(j)); hi=max(a,th(j));
        t(j)=integral(ft,lo,hi,'RelTol',opts.RelTol,'AbsTol',opts.AbsTol);
        ph(j)=integral(fp,lo,hi,'RelTol',opts.RelTol,'AbsTol',opts.AbsTol);
    end
end
end

function y=turn_integrand(z,thetaStar,sg,c,kind,p,forPhi)
theta=thetaStar+sg.*z.^2;
q=radicand(theta,c,kind,p);
if kind=="B"
    factor=sqrt(p.R/(2*p.g));
else
    factor=sqrt(p.m*p.R^2/2);
end
% Analytical limiting value removes the integrable square-root
% singularity and round-off cancellation at z=0.
der=radicand_derivative(thetaStar,c,kind,p);
if ~(isfinite(der) && sg*der>0)
    error('quadrature_reference:MultipleRoot','Not a simple turning point.');
end
y=zeros(size(z));
near=(abs(z)<1e-4);
y(near)=2*factor/sqrt(sg*der);
if any(~near)
    rad=q(~near);
    if any(rad<=0 | ~isfinite(rad))
        error('quadrature_reference:TurnRadicand','Invalid polar turning branch.');
    end
    y(~near)=2*factor.*z(~near)./sqrt(rad);
end
if forPhi, y=y.*omega(theta,c,kind,p); end
end

function y=base_t_integrand(theta,c,kind,p)
if kind=="B", factor=sqrt(p.R/(2*p.g));
else, factor=sqrt(p.m*p.R^2/2); end
rad=radicand(theta,c,kind,p);
if any(~isfinite(rad)|rad<=0)
    error('quadrature_reference:Radicand','Nonpositive reduced radicand.');
end
y=factor./sqrt(rad);
end

function y=omega(theta,c,kind,p)
if kind=="B"
    D=p.v0^2/(2*p.g*p.R)+cos(p.theta0)-cos(theta);
    y=sqrt(2*p.g/p.R).*c.*D./sin(theta).^2;
else
    y=c(2)./(p.m*p.R^2*sin(theta).^2);
end
end

function rad=radicand(theta,c,kind,p)
if kind=="B"
    D=p.v0^2/(2*p.g*p.R)+cos(p.theta0)-cos(theta);
    rad=D-c.^2.*D.^2./sin(theta).^2;
else
    V=p.m*p.g*p.R*cos(theta)+c(2).^2./(2*p.m*p.R^2*sin(theta).^2);
    rad=c(1)-V;
end
end

function der=radicand_derivative(th,c,kind,p)
if kind=="B"
    D=p.v0^2/(2*p.g*p.R)+cos(p.theta0)-cos(th);
    der=sin(th)-2*c.^2.*D./sin(th) ...
        +2*c.^2.*D.^2.*cos(th)./sin(th).^3;
else
    der=p.m*p.g*p.R*sin(th)+c(2).^2.*cos(th)./(p.m*p.R^2*sin(th).^3);
end
end
