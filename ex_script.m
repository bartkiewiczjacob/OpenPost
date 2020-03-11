% ex_script.m

% Vehicle definition
vehicle.L    = 27;    % Rocket length [ft]
vehicle.D    = 16/12; % Rocket diameter [ft]
vehicle.NC_L = 4;     % Nose cone length [ft]
vehicle.xcg  = 18.3;  % Axial cg from nosecone tip [ft]
vehicle.zcg  = 0;     % Radial cg [ft]

vehicle.rougfc = .00025;  % surface roughness [ft]

vehicle.fin_root   = 28/12;  % Fin root at body [ft]
vehicle.fin_tip    = 18/12;  % Fin tip [ft]
vehicle.fin_sweep  = 45.0;   % Fin sweep [deg]
vehicle.fin_height = 19/12;  % Fin Height [ft]
vehicle.fin_disp   = 0;      % Fin displacement from base of rocket [ft]
vehicle.fin_num    = 4;      % Number of fins

% vehicle.unit = 'M';
vehicle.unit = "FT";  % Supplied length dimension

datcom_input_file(vehicle);
datcom_run();
aero_statdyn = datcom_import();
