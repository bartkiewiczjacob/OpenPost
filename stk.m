clc; clear;
%Create an instance of STK
uiApplication = actxserver('STK11.application');
uiApplication.Visible = 1;

%Get our IAgStkObjectRoot interface
root = uiApplication.Personality2;
root.NewScenario('Test');
rocket = root.CurrentScenario.Children.New(10, 'Rocket');
rocket.SetTrajectoryType(6)
rocket.Trajectory.Filename = 'C:\Users\bartk\OneDrive\Desktop\OpenPost\sim.e';
root.CurrentScenario.SetTimePeriod('30 Jul 2014 16:00:05.000', '31 Jul 2014 16:00:00.000');
root.CurrentScenario.Epoch = '30 Jul 2014 16:00:05.000';
rocket.Attitude.External.Load('C:\Users\bartk\OneDrive\Desktop\OpenPost\sim.a')
root.Rewind;
root.PlayForward;




