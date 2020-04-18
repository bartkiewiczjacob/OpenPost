% retrieve aerodynamic data
air_data = load('air_data.csv');
warning('off', 'all');
%Average Mass Normalized Inertia Tensor % compute the average inertia tensor of
                                 % the rocket and divide each term by the mass
I = [360, 0, 0; 0, 4880, 0; 0, 0, 4880]./973.065; %[ft^2]

%Propulsion 
%For constant Thrust testing enter Thrust.time = [0, 1], Thrust.thrust =
%[Thrust, Thrust]
Thrust.time = [0, 1]; % Engine Test Time Array [s]
Thrust.thrust = [5000, 5000]; %Engine Test Thrust Values [lbf]
burn_time = 40;%(200000)/T; %Engine Burn Time [s]
m_wet = 1404;%1841.8; %Gross Liftoff Weight [lbs]
mdot = 21.5; %Engine Mass Flow Rate [lbs/s]
m_dry = m_wet - mdot*burn_time; %Burnout Mass [lbs]
%Engine 
De = 8.4932; %Engine Exit Diameter [in]
Pe = 10; %Engine Exit Pressure [psi]
% initialization
phi0 = 0; %Initial Roll Angle [rad] % if orientation relative to Earth is 
                                    % required set this as the angle 
                                    % between a chosen reference axis and North 
theta0 = pi/4; %Initial Pitch Angle [rad] % down/up range
psi0 = 0; %Initial Yaw Angle [rad] % cross range 
h0 = 4595; %Initial Altitude [ft]
u0 = 0.1; %Initial Upwards Velocity [ft/s]
v0 = 0.0; %Initial Northern Velocity [ft/s]
w0 = 0.0; %Initial Western Velocity [ft/s]
lat = 32.9861; %Launch Site Latitude [deg]
lon = -106.9717; %Launch Site Longitude [deg]
%rail
lr = 75; %Launch Rail Length [ft]
mu = 0.42; %Launch Rail/Launch Lug Coefficient of Friction
len = 27; %Full Rocket Length [ft]
%heating data
thermal = 0; %Do you require aeroheating results? [logical]
cp = 0.217; %Analysis Material Specific Heat [BTU/lb-F]
material_density = 168.55; %Analysis Material Density [lb/ft^3]
k_m = 136; %Analysis Material Thermal Conductivity [BTU/(hr-ft-F)]
epsi = 0.07; %Material Emissivity
x = 5.0292/0.0254; %Analysis Location from Nose Tip [in]
t = 0.07; %Analysis Material Thickness[in]
insulation = 0; %Does the material have a protective insulation coating? [Logical]
kc = 0.20236159384; %Insulation Thermal Conductivity [BTU/h-ft-F]
tc = 0.00; %Insulation Thickness [in]
Kl = 1;%0; Is this a liquid conatiner? [logical]
Kg = 1;%0; Is this material in contact with internal gases? [logical] 
k_he = 0.0867; %Tank Contents Thermal Conductivity [BTU/h-ft-F]
T_he = -99.67; %Tank Contents Temperature [F]
d = 16; %Tank Diameter [in]
fl.value = [6/0.0254 6/0.0254]; %Liquid Level from Nose Tip [in]
fl.time = [0 1]; %Liquid level time array [sec] %Follows same instruction as Thrust
Tf = 38.93; %Liquid Temperature [F]
%wind
wind = 1; %1; Do you want wind considered in the simulation? [Logical]
%Gust Based Wind (Used to analyze vehicle responses as it flies through
    %wind gusts. This may commonly be used to test robustness in critical
    %events such as liftoff and max q. All values should be given with respect to the body frame)
t_gust = 0; %The start time of a gust [sec]
gust_len = 1; %The distance the rocket must travel to clear a gust [ft] (Must be >0)
gust_y = 0; %The wind speed of the gust in the body-y direction [ft/s]
gust_z = 0; %The wind speed of the gust in the body-z direction [ft/s]
%Constant Wind (Used to analyze vehicle response to constant wind in an
    %inertial direction. Not accurate to reality but useful to test control steady state error.)
wind_const = 20; %Constant wind speed magnitude [ft/s]
wind_direc = 60; %Direction of wind speed from North [deg] (Also used for Wind Shear)
%Wind Shear Based Wind (Most accurate to reality. Uses wind measurements to
    %estimate wind speed as altitude changes.)
wind_read_speed = 0; %Wind speed reading just before launch [ft/s]
%optionals
controls = 0; %Do you want to implement your controller? [Logical] (Control logic entered in Simulink)
allow_rot = 1; %Do you want to allow the vehicle to rotate? [Logical] (Reduces model to 1-DOF)
visualization = 1; %Do you want to visualize you results in Flight Gear? [Logical] (Must first load FlightGear Scenario)
stop_on_apogee = 1; %Do you want the simulation to stop when the vehicle reaches apogee? [Logical]
stop_on_landing = 0; %Do you want the simulation to stop when the vehicle contacts the ground? [Logical]
aero = 1; %Do you want to include aerodynamic effects? [Logical]
%Special
inner_m = [1/2*0.0762^2*13.6*3141.6, 0, 0]; %Angular momentum of interal machinery such as pumps of turbines [kg-m/s^2]
if thermal
    set_param('eqns_motion_mdl/Aeroheating', 'commented', 'off')
else
    set_param('eqns_motion_mdl/Aeroheating', 'commented', 'on')
end
if controls
    set_param('eqns_motion_mdl/Controls', 'commented', 'off')
else
    set_param('eqns_motion_mdl/Controls', 'commented', 'on')
end
if visualization
    set_param('eqns_motion_mdl/Visualization', 'commented', 'off')
else
    set_param('eqns_motion_mdl/Visualization', 'commented', 'on')
end
if insulation
else
    kc = 1;
    tc = 0;
end
    
save_system('eqns_motion_mdl')
sim('eqns_motion_mdl.slx'); %Runs Simulation
%plot(trajectory) %Plots trajectory
if visualization
    fileID = fopen('sim.a', 'w');
    fprintf(fileID, 'stk.v.5.0\nBEGIN Attitude\nScenarioEpoch 1 Dec 2019 17:00:00.000\nBlockingFactor 20\nInterpolationOrder 1\nCentralBody Earth\nCoordinateAxes AWB UpWestSouth LaunchVehicle/LaunchVehicle1\nSequence 123\nAttitudeTimeEulerAngles\n');
    A = [angles.time, angles.signals.values];
    fprintf(fileID, '%d %d %d %d\n', A');
    fprintf(fileID, 'END Attitude');
    B = [coords.time, coords.signals.values, vel_coords.signals.values];
    fileIDb = fopen('sim.e', 'w');
    fprintf(fileIDb, 'stk.v.4.3\nBEGIN Ephemeris\nNumberOfEphemerisPoints 7000\nScenarioEpoch           1 Dec 2019 17:00:00.000\nInterpolationMethod     Lagrange\nInterpolationOrder      1\nDistanceUnit			Metershel\nCentralBody             Earth\nCoordinateSystem        Fixed\n EphemerisLLATimePosVel\n');
    fprintf(fileIDb, '%.10d %.10d %.10d %.10d %.10d %.10d %.10d\n', B');
    fprintf(fileIDb, 'END Ephemeris');
    uiApplication = actxserver('STK11.application');
    uiApplication.Visible = 1;
    root = uiApplication.Personality2;
    root.LoadScenario('C:\Users\bartk\OneDrive\Desktop\OpenPost\PSR.sc')
    pause(10)
    root.PlayForward;
end






 

