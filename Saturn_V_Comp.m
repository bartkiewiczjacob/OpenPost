% ex_script.m
clc; clear;
% Vehicle definition
vehicle.L    = 363;    % Rocket length [ft]
vehicle.D    = 33; % Rocket diameter [ft]
vehicle.NC_L = 82;     % Nose cone length [ft]
vehicle.xcg  = 363/2;  % Axial cg from nosecone tip [ft]
vehicle.zcg  = 0;     % Radial cg [ft]

vehicle.rougfc = .00025;  % surface roughness [ft]

vehicle.fin_root   = 135.4/12;  % Fin root at body [ft]
vehicle.fin_tip    = 55/12;  % Fin tip [ft]
vehicle.fin_sweep  = 30;   % Fin sweep [deg]
vehicle.fin_height = 139.29/12;  % Fin Height [ft]
vehicle.fin_disp   = 0;      % Fin displacement from base of rocket [ft]
vehicle.fin_num    = 4;      % Number of fins

% vehicle.unit = 'M';
vehicle.unit = "FT";  % Supplied length dimension

datcom_input_file(vehicle);
datcom_run();
aero_statdyn = datcom_import();