% vehicle_definition.m
case_id = "example_rocket";

vehicle.unit = "FT";
% vehicle.unit = "M";
%% Body Geometry
vehicle.L    = 27;    % Vehicle Total length [ft]
vehicle.D    = 16/12; % Vehicle diameter [ft]
vehicle.L_nc = 4;     % Nose cone segment length [ft]
vehicle.L_af = 23;    % Afterbody segment length [ft]
vehicle.L_bt = 0;     % Boattail segment length [ft]

vehicle.nc = 'ogive'; % Nosecone type
vehicle.r_n = .12;    % Nose cone bluntness radius [ft]

vehicle.xcg  = 15;    % Axial cg from nosecone tip [ft]
vehicle.zcg  = 0;     % Radial cg [ft]
vehicle.D_bt = 0;     % Boattail diameter [ft]

% Optional
vehicle.oml.x = [];
vehicle.oml.r = [];

%% Fin Geometry
vehicle.fin_root   = 40/12;  % Fin root at body [ft]
vehicle.fin_tip    = 22/12;  % Fin tip [ft]
vehicle.fin_sweep  = 40.0;   % Fin sweep [deg]
vehicle.fin_height = 20/12;  % Fin Height [ft]
vehicle.fin_disp   = 0;      % Fin displacement from base of rocket [ft]
vehicle.fin_num    = 4;      % Number of fins

vehicle.fin_shape = 'S-3-10.0-2.5-80.0';  % Airfoil shape
% S-3-10.0-2.5-80.0
% S-1-50.0-2.5

%% Misc
vehicle.R_a = .00025;  % surface roughness [ft]

save("vehicles/" + case_id + ".mat", 'vehicle')