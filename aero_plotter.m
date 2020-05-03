function aero_plotter(aero_statdyn)
% Plots static aerodynamic coefficient data from a DATCOM aerodynamic data
% structure array.
%
% Inputs:
%    aero_statdyn - DATCOM aerodynamic data structure array.
%
% Outputs: None
%
% Examples:
%    aero_plotter(aero_statdyn)
%
% Required m-files: None
%
% See also: datcom_import

%% Aerodynamic coefficients to plot
mach = aero_statdyn.mach;
alpha = aero_statdyn.alpha;
cd = aero_statdyn.cd;
cla = aero_statdyn.cla;
cm = aero_statdyn.cm;
xcp = aero_statdyn.xcp;

% Finding AoA to plot
alpha_idx = find(~alpha, 1);
if isempty(alpha_idx); alpha_idx=1; end

%% Static Coefficients
figure();
ax1 = subplot(2, 2, 1);  % Drag subplot
ax2 = subplot(2, 2, 2);  % Lift derivative subplot
ax3 = subplot(2, 2, 3);  % Moment derivative subplot
ax4 = subplot(2, 2, 4);  % Center of pressure subplot

% Drag
plot(ax1, mach, cd(alpha_idx,:), '-o', 'LineWidth', 1);
grid(ax1, 'on');
title(ax1, 'C_D vs Mach Number'); 
xlabel(ax1, 'Mach Number'); ylabel(ax1, 'C_D');
xlim(ax1, [0 mach(end)]);

% Finding Machs to plot for lift derivative and moment
m_len = length(mach);
mach_idx = [round(m_len/4), round(m_len/2), round(3*m_len/4)];
% Finding range of alphas
alphas_idx = (alpha >= 0) & (alpha <= 20);
alphas = alpha(alphas_idx);

% Lift derivative
for m_idx = mach_idx
    plot(ax2, alphas, cla(alphas_idx, m_idx), '-', 'LineWidth', 1);
    hold(ax2, 'on'); grid(ax2, 'on');
end
title(ax2,'C_{L \alpha} vs Mach Number');
ylabel(ax2,'C_{L \alpha}'); xlabel(ax2,'Angle of attack (deg)');

% (Pitching) moment 
for m_idx = mach_idx
    plot(ax3, alphas, cm(alphas_idx, m_idx), '-', 'LineWidth', 1);
    hold(ax3, 'on'); grid(ax3, 'on');
end
title(ax3,'C_m vs Mach Number');
ylabel(ax3,'C_m'); xlabel(ax3,'Angle of attack (deg)');

% Center of pressure
xcp = -xcp*aero_statdyn.cbar;
plot(ax4, mach, xcp(alpha_idx,:), '-o', 'LineWidth', 1); grid(ax4, 'on');
title(ax4,'C_p Behind Mass Center vs Mach Number');
xlabel(ax4,'Mach Number'); ylabel(ax4,"C_p, behind mass center (" + aero_statdyn.dim + ")");
xlim(ax4, [0 mach(end)]);

end