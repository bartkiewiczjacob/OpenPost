function [exitflag] = datcom_input_file(vehicle, M, Alpha, ALT, view)
% datcom_input_file takes in rocket parameters and generates
% an input file for use in the USAF Digital DATCOM
% 
% TODO
% - Switch to rocket file from hardcoded variables - COMPLETE
% - Support metric dimensions
% - OML definition
% - Better nose cone definition
% - Boat tail
% - 3,4,5 fin configurations
% 
% INPUTS
% - L:
%  Vehicle total length [ft]
% - D:
%  Vehicle diameter [ft]
% - M:
%  Nx1 Vector of Mach Numbers
% - ALT:
%  Flight Altitude (used in Reynolds Number Calc)
% - Alpha:
%  Nx1 Vector of Angle of Attacks
% - filename:
%  String for filename without extension(default is 'for005')
% - view
%  1 for vehicle model view, 0 for no view
% 
% OUTPUTS
% - exitflag
%  Provides information 
% 
% LIMITATIONS 
% - 

%% Setting default parameters
if nargin < 1
    % Default vehicle file provided with package
    vehicle = "example_rocket.mat";
end
if nargin < 2
    % Default Mach Number List
    M = [.01 .1:.1:.6 1.4:.4:5.0];
end
if nargin < 3
    % Default Alpha List
    Alpha = [0:.5:8 9:19 20:5:180];
end
if nargout < 4
    % Default Altitude
    ALT = 0;
end
if nargout < 5
    % View rocket profile
    view = 0;
end
M(M==0) = .01;

filename = 'for005';
exitflag = 0;

%% LAUNCH VEHICLE PARAMETERS

XCG = vehicle.xcg;
ZCG = vehicle.zcg;
% Body Geometry
L    = vehicle.L;
D    = vehicle.D;
L_NC = vehicle.NC_L;

ROUGFC = vehicle.rougfc;

% Load in fin geometry
fin_root   = vehicle.fin_root;
fin_tip    = vehicle.fin_tip;
fin_sweep  = vehicle.fin_sweep;
fin_height = vehicle.fin_height;
fin_disp   = vehicle.fin_disp;

% Other fin geometry (DO NOT TOUCH) 
r = D/2;  % Rocket radius
l_r = fin_root;   % fin root 
l_h = fin_height; % fin height 
l_t = fin_tip;    % fin tip length
l_d = r*tand(fin_sweep); % Length from base fin leading edge to root leading edge      
l_s = (r+l_h)*tand(fin_sweep);  % Length from base fin leading edge to tip leading edge
l_e = r*(l_t+l_s-l_d-l_r)/l_h;  % Length from base fin bottom to root fin/body intercept
l_b = l_r+l_d-l_e;              % Base fin length

%% Checking Input data
if length(M) > 17   % Need to fix
    % DATCOM Mach numbers limitation
    msg = "Error: Cannot generate and run an input file with " + ...
        "more than 17 Mach number entries.";
    error(msg);
elseif min(M) < 0
    % Mach number must be positive
    msg = "Mach number cannot be negative.";
    error(msg);
elseif min(Alpha) < 0
    % Alpha must be positive
    msg = "Program will automatically flip alpha, keep all " + ...
        "alpha greater than zero.";
    error(msg);
elseif ZCG > D/2
    % ZCG cannot be outside of the rocket
    msg = "Center of gravity offset is greater than the radius " + ...
        "of the rocket.";
    error(msg);
elseif XCG > L 
    % XCG cannot be outside of the rocket
    msg = "Center of gravity is longer than the length of the rocket.";
    error(msg);
elseif any(M > .6 & M < 1.4) 
    % warning if input mach numbers are transonic
    msg = "Avoid using mach numbers between .6 and 1.4 (Transonic). " + ...
        "Datcom cannot calculate values for most coefficient within " + ...
        "this range without extending supersoinc and subsonic methods.";
    warning(msg);
end

%% Setting up file
%% Writing Data to File
fileID = fopen(strcat(filename,'.dat'),'w');
fprintf(fileID,'CASEID PUB_ROCKET\n');

%% FLIGHT CONDITIONS (FLTCONS)
NMACH = length(M);               % Mach Numbers
NALPHA = min(length(Alpha),17);  % Angle of Attack [deg]
NALT = length(ALT);              % Altitude [ft]
LOOP = 2.0;    % Keep at 2.0   

% Mach Numbers
fprintf(fileID,' $FLTCON NMACH=%.1f, MACH(1)=',NMACH);   % Mach Number Input
counter_nl = 1;  % Newline after printing 4 numbers
for m = M
    if m == M(end)
        fprintf(fileID,'%.2f$\n', m);
    elseif mod(counter_nl, 6) == 0
        fprintf(fileID,'%.2f,\n  ', m);
    else
        fprintf(fileID,'%.2f,', m);
    end
    counter_nl = counter_nl + 1;
end

% Alphas
fprintf(fileID,' $FLTCON NALPHA=%.1f, ALSCHD(1)=',NALPHA);   % Angle of Attack Input
counter_nl = 1;  % Newline after printing 4 numbers
counter_lim = 1; % 
for a = Alpha
    if a == Alpha(end) || (counter_lim == 17)
        fprintf(fileID,'%.2f$\n', a);
    elseif (mod(counter_nl, 6) == 0) 
        fprintf(fileID,'%.2f,\n  ', a);
    else
        fprintf(fileID,'%.2f,', a);
    end
 
    counter_nl = counter_nl + 1;
    counter_lim = counter_lim + 1;
    if counter_lim > 17
        break
    end
end

% Altitudes
fprintf(fileID,' $FLTCON NALT=1.0, ALT(1)=%.2f$\n',ALT);   % Angle of Attack Input

% Loop and transition Mach numbers
% Mach Number Input
fprintf(fileID,' $FLTCON STMACH=.99,TSMACH=1.01,LOOP=%.1f$\n',LOOP);

%% SYNTHESIS (SYNTHS)
% Wing (HTAIL) Parameters
XW   = (L-l_r-l_d)-fin_disp; % HTail distance from nosecone [ft]
ZW   = 0.0;   % HTail vertical displacement [ft]
ALIW = 0.0;   % Angle of incidence [deg]

% Vertical and Ventral Fin Parameters
XV  = (L-l_r-l_d)-fin_disp;        % VTail distance from nosecone 
ZV  = 0;                  % VTail vertical offset
XVF = (L-(l_b-l_s+l_e))-fin_disp;  % Ventral fin distance from nosecone
ZVF = -(fin_height+D/2);  % Ventral fin vertical offset

% Writing to File
fprintf(fileID,' $SYNTHS XCG=%.1f, ZCG=%.1f,\n',XCG, ZCG); % CG Placement
fprintf(fileID,'  XW=%.2f,ZW=%.2f,ALIW=%.2f,\n',XW,ZW,ALIW); % Wing Placement (HTAIL)
fprintf(fileID,'  XV=%.2f,ZV=%.2f,\n',XV,ZV);       % Vertical Tail
fprintf(fileID,'  XVF=%.2f,ZVF=%.2f,\n',XVF,ZVF);   % Vertical Tail
fprintf(fileID,'  VERTUP=.TRUE.,$\n');

%% OPTIONS (OPTINS)
sref = pi*(D/2)^2;  % Reference Area
CBARR = L;          % Longitudenal Reference Length
BLREF = fin_height; % Lateral Reference Length 

fprintf(fileID,' $OPTINS SREF=%.3f,CBARR=%.1f,BLREF=%.1f,ROUGFC=%.6f$\n',sref,CBARR,BLREF,ROUGFC);

%% BODY GEOMETRY
fprintf(fileID,' $BODY NX=3.0,BNOSE=1.0,BLN=%.2f,\n',L_NC);
fprintf(fileID,'  X(1)=0.0,%.2f,%.2f,\n',L_NC,L);
fprintf(fileID,'  R(1)=0.0,%.2f,%.2f,\n',D/2,D/2);
fprintf(fileID,'  METHOD=2.0$\n'); % 0-180deg Method for Body Calcs

%% WING GEOMETRY (HTAIL)
fprintf(fileID,'NACA-W-4-0012\n');
fprintf(fileID,' $WGPLNF CHRDTP=%.2f,SSPNE=%.2f,SSPN=%.2f,',fin_tip,fin_height,fin_height+D/2);
fprintf(fileID,'CHRDR=%.2f,SAVSI=%.2f,TYPE=1.0$\n',l_b,fin_sweep);

%% VTAIL GEOMETRY (VTAIL AND VENTRAL FIN)
fprintf(fileID,'NACA-V-4-0012\n');
fprintf(fileID,' $VTPLNF CHRDTP=%.2f,SSPNE=%.2f,SSPN=%.2f,CHRDR=%.2f,SAVSI=%.2f,TYPE=1.0$\n',fin_tip,fin_height,fin_height+D/2,l_b,fin_sweep);
fprintf(fileID,' $VFPLNF CHRDTP=%.2f,SSPNE=%.2f,SSPN=%.2f,CHRDR=%.2f,SAVSI=%.2f,TYPE=1.0$\n',l_b,fin_height,fin_height+D/2,fin_tip,-fin_sweep);

%% REMAINING CASE DATA
fprintf(fileID,"DIM " + vehicle.unit + "\n");
fprintf(fileID,'DAMP\n');
fprintf(fileID,'SAVE\n');
fprintf(fileID,'PLOT\n');
fprintf(fileID,'NEXT CASE');

%% REMAINING CASES
for i = 2:ceil(length(Alpha)/17)
    alpha_start = (i-1)*17 + 1;
    alpha_end = min(length(Alpha),i*17);

    % New case flight conditions
    fprintf(fileID,'\n $FLTCON');
    fprintf(fileID,' NALPHA=%.1f, ALSCHD(1)=',alpha_end - alpha_start + 1);
    counter_nl = 1;  % Newline after printing 4 numbers
    counter_lim = 1; % Case AoA input limit
    for a = Alpha(alpha_start:alpha_end)
        if a == Alpha(end) || (counter_lim == 17)
            fprintf(fileID,'%.2f$\n', a);
        elseif (mod(counter_nl, 6) == 0) 
            fprintf(fileID,'%.2f,\n  ', a);
        else
            fprintf(fileID,'%.2f,', a);
        end

        counter_nl = counter_nl + 1;
        counter_lim = counter_lim + 1;
        if counter_lim > 17
            break
        end
    end
    fprintf(fileID,'DAMP\n');
    fprintf(fileID,'SAVE\n');
    fprintf(fileID,'PLOT\n');
    if (alpha_end - alpha_start) == 16
        fprintf(fileID,'NEXT CASE');
    end
end

%% CLOSING FILE
fclose(fileID);

%% View Vehicle for Validating
% Ignore Front View, doesnt include ventral fin
% Use Top and Side Views
if view == 1
    drawDATCOMaircraft(strcat(filename,'.dat'));
end

end