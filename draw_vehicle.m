function draw_vehicle(vehicle, aero_statdyn)
% Plots vehicle fin configuration
%
% Input:
%  vehicle - structure array containing fields describing the vehicle
%           geometry
%  aero_statdyn - DATCOM aerodynamic data structure array.
%
% Output: None

%% Default Parameters
if nargin < 2
    aero_statdyn = [];
end

%% Vehicle Side View (Primary View)
figure(); ax = gca; 
set(gcf,'units','points','position',[200,200,650,250])

% 
if isempty(vehicle.oml.x) || isempty(vehicle.oml.r)
    % Setting vehicle oml
    vehicle.oml.x = [
        0;
        vehicle.L_nc;
        vehicle.L_nc + vehicle.L_af;
        vehicle.L_nc + vehicle.L_af + vehicle.L_bt;
        vehicle.L_nc + vehicle.L_af + vehicle.L_bt
    ];
    vehicle.oml.r = [
        0;
        vehicle.D/2;
        vehicle.D/2;
        vehicle.D_bt/2;
        0
    ];

    % Conical cone with blunted tip
    if strcmp(vehicle.nc, 'conical') && vehicle.r_n
        r_n = vehicle.r_n;
        L = vehicle.L_nc; R = vehicle.D/2;
        x_t = L^2/R*sqrt(r_n^2/(R^2+L^2)); y_t = x_t*R/L;
        x_o = x_t + sqrt(r_n^2 - y_t^2);
        x_1 = linspace(x_o-r_n, x_t, 10)';
        x_2 = linspace(x_t, vehicle.L_nc, 2)';
        y_1 = sqrt(r_n^2 - (x_1-x_o).^2);
        y_2 = [y_t; vehicle.D/2];
        x = [x_1; x_2]; y = [y_1; y_2];
        vehicle.oml.x = [x; vehicle.oml.x(2:end)];
        vehicle.oml.r = [y; vehicle.oml.r(2:end)]; 
        
        x_b = linspace(x_o-r_n,x_o+r_n,20);
        y_btop = sqrt(r_n^2 - (x_b-x_o).^2);
        y_bbot = -sqrt(r_n^2 - (x_b-x_o).^2);

    % Ogive cone with blunted tip
    elseif strcmp(vehicle.nc, 'ogive') && vehicle.r_n
        r_n = vehicle.r_n;
        L = vehicle.L_nc; R = vehicle.D/2; rho = (R^2 + L^2)/2/R;
        x_o = L - sqrt((rho-r_n)^2-(rho-R)^2);
        y_t = r_n*(rho-R)/(rho-r_n);
        x_t = x_o - sqrt(r_n^2-y_t^2);
        x_1 = linspace(x_o-r_n, x_t, 10)';
        x_2 = linspace(x_t, vehicle.L_nc, 10)';
        y_1 = sqrt(r_n^2 - (x_1-x_o).^2);
        y_2 = sqrt(rho^2 - (L-x_2).^2) + R - rho;
        x = [x_1; x_2]; y = [y_1; y_2];
        vehicle.oml.x = [x; vehicle.oml.x(2:end)];
        vehicle.oml.r = [y; vehicle.oml.r(2:end)]; 
        
        x_b = linspace(x_o-r_n,x_o+r_n,20);
        y_btop = sqrt(r_n^2 - (x_b-x_o).^2);
        y_bbot = -sqrt(r_n^2 - (x_b-x_o).^2);
        
    % Ogive cone, no blunted tip
    elseif strcmp(vehicle.nc, 'ogive')
        x = linspace(0, vehicle.L_nc, 10)';
        L = vehicle.L_nc; R = vehicle.D/2; rho = (R^2 + L^2)/2/R;
        y = sqrt(rho^2 - (L-x).^2) + R - rho;
        vehicle.oml.x = [x; vehicle.oml.x(2:end)];
        vehicle.oml.r = [y; vehicle.oml.r(2:end)];
    end
end

% Plotting vehicle OML
plot(ax, vehicle.oml.x, vehicle.oml.r, '-k');
hold(ax, 'on'); grid(ax, 'on'); axis(ax, 'equal');
plot(ax, vehicle.oml.x, -vehicle.oml.r, '-k');
plot(ax, [vehicle.oml.x(end), vehicle.oml.x(end)], ...
    [vehicle.oml.r(end), vehicle.oml.r(end)], 'k-');
if vehicle.r_n
    plot(ax, x_b, y_btop, '-.k');
    plot(ax, x_b, y_bbot, '-.k');
end

% Plotting fins
rot_y = @(th) [1 0 0; 0 cos(th) -sin(th); 0 sin(th) cos(th)];  % basic rotation matrix about y axis
fin = [
       [vehicle.L_nc+vehicle.L_af-vehicle.fin_disp,vehicle.D/2, 0];
       [vehicle.L_nc+vehicle.L_af-vehicle.fin_root-vehicle.fin_disp, vehicle.D/2, 0];
       [vehicle.L_nc+vehicle.L_af-vehicle.fin_root-vehicle.fin_disp+tand(vehicle.fin_sweep)*vehicle.fin_height, vehicle.D/2+vehicle.fin_height, 0];
       [vehicle.L_nc+vehicle.L_af-vehicle.fin_root-vehicle.fin_disp+tand(vehicle.fin_sweep)*vehicle.fin_height+vehicle.fin_tip, vehicle.D/2+vehicle.fin_height, 0]
       ];
fin_count = 1;
for theta = linspace(0, 2*pi, vehicle.fin_num+1)
    if theta == 2*pi
        break
    else
        fin_i = [];
        for i = 1:4
            fin_i(i,:) = (rot_y(theta)*fin(i,:)')';
        end
        fins(:,:,fin_count) = fin_i;
        fin_count =  fin_count + 1;
    end
end
% Plotting fins
for i = 1:vehicle.fin_num
    for j = 1:4
        fin = fins(:,:,i);
        plot(ax, [fin(j,1) fin(mod(j,4)+1,1)], [fin(j,2) fin(mod(j,4)+1,2)], '-k');
    end
end

% Plotting CG
viscircles(ax, [vehicle.xcg, vehicle.zcg], vehicle.D/10, 'Color', 'k', 'LineWidth', 1);

% Plotting CP if available
if ~isempty(aero_statdyn)
    alpha = find(~aero_statdyn.alpha, 1);
    mach = aero_statdyn.mach(1);
    if mach < 1
        cp = -aero_statdyn.xcp(alpha, 1)*aero_statdyn.cbar + vehicle.xcg;
        viscircles(ax, [cp, 0], vehicle.D/10, 'Color', 'r', 'LineWidth', 1);
        theta=linspace(0,2*pi,30); rho=ones(1,30)*vehicle.D/20;
        [X,Y] = pol2cart(theta, rho); X=X+cp; Y=Y+0;
        fill(X,Y,'r','LineStyle','none');
        str_annotate = sprintf("CG: %.1f%s, Subsonic CP: %.1f%s", vehicle.xcg, lower(vehicle.unit), cp, lower(vehicle.unit));
    else
        str_annotate = sprintf("CG: %.1f%s", vehicle.xcg, lower(vehicle.unit));
    end
else
    str_annotate = sprintf("CG: %.1f%s", vehicle.xcg, lower(vehicle.unit));
end

% Plot labels
title({'Side View Vehicle Drawing',str_annotate});
xlabel(lower(vehicle.unit)); ylabel(lower(vehicle.unit));
hold('off');
end