clc;
clear;
% retrieve aerodynamic data
load('aerodata.mat');
air_data = load('air_data.csv');
warning('off', 'all');
%Average Massless Inertia Tensor % compute the average inertia tensor of
                                 % the rocket and divide each term by the mass
I = [360, 0, 0; 0, 4880, 0; 0, 0, 4880]./973.065; %[ft^2]

%Propulsion 
T = 1000;%5100; %Design Thrust [lbs]
burn_time = 10;%(200000)/T; %Engine Burn Time [s]
m_wet = 200;%1841.8; %Gross Liftoff Weight [lbs]
mdot = 10;%36.18; %Engine Mass Flow Rate [lbs/s]
m_dry = m_wet - mdot*burn_time; %Burnout Mass [lbs]
%Engine 
De = 8.4932; %Engine Exit Diameter [in]
Dt = 3.0968; %Engine Throat Diameter [in]
Pc = 250; %Engine Chamber Pressure [psi]
Pe = 10; %Engine Exit Pressure [psi]
% initial position
phi0 = 0; %Initial Roll Angle [rad] % if orientation relative to Earth is 
                                    % required set this as the angle 
                                    % between a chosen reference axis and North 
theta0 = 0.7854; %Initial Pitch Angle [rad] % down/up range
psi0 = 0; %Initial Yaw Angle [rad] % cross range 
h0 = 0;%4595; %Initial Altitude [ft]
u0 = 0.1; %Initial Upwards Velocity [ft/s]
v0 = 0.0; %Initial Northern Velocity [ft/s]
w0 = 0.0; %Initial Western Velocity [ft/s]
% wind
lat = 32.9861; %Launch Site Latitude [deg]
lon = -106.9717; %Launch Site Longitude [deg]
day = 119; %Launch Day [days since Jan 1]
sec = 12*3600; %Launch Time [sec since midnight grenwich time] 
%rail
lr = 75; %Launch Rail Length [ft]
mu = 0.42; %Launch Rail/Launch Lug Coefficient of Friction
len = 27; %Full Rocket Length [ft]
%heating data
cp = 0.217; %Analysis Material Specific Heat [BTU/lb-F]
material_density = 168.55; %Analysis MAterial Density [lb/ft^3]
eps = 0.07; %Material Emissivity
x = 5.0292/0.0254; %Analysis Location from Nose Tip [in]
t = 0.07; %Analysis Material Thickness[in]
kc = 0.20236159384; %Insulation Thermal Conductivity [BTU/h-ft-F]
tc = 0.00; %Insulation Thickness [in]
k_he = 0.0867; %Helium Thermal Conductivity [BTU/h-ft-F]
T_he = -99.67; %Helium Temperature [F]
d = 16; %Tank Diameter [in]


% fileID = fopen('sim.a', 'w');
% fprintf(fileID, 'stk.v.5.0\nBEGIN Attitude\nScenarioEpoch           1 Dec 2019 17:00:00.000\nBlockingFactor          20\nInterpolationOrder      1\nCentralBody             Earth\nCoordinateAxes        	AWB    NorthWestUp		 LaunchVehicle/LaunchVehicle1\nSequence                321\nAttitudeTimeQuaternions\n');
% A = [quat.time, quat.signals.values];
% fprintf(fileID, '%d %d %d %d %d\n', A');
% fprintf(fileID, 'END Attitude');
% B = [coords.time, coords.signals.values, vel_coords.signals.values];
% fileIDb = fopen('sim.e', 'w');
% fprintf(fileIDb, 'stk.v.4.3\nBEGIN Ephemeris\nNumberOfEphemerisPoints 7000\nScenarioEpoch           1 Jun 2002 12:00:00.000000000\nInterpolationMethod     Lagrange\nInterpolationOrder      1\nDistanceUnit			Meters\nCentralBody             Earth\nCoordinateSystem        Fixed\n EphemerisLLATimePosVel\n');
% fprintf(fileIDb, '%.10d %.10d %.10d %.10d %.10d %.10d %.10d\n', B');
% fprintf(fileIDb, 'END Ephemeris');




 

