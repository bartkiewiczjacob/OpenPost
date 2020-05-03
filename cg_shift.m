function aero_statdyn = cg_shift(aero_statdyn, xcg_new, zcg_new)
% Shifts the CG for a datcom structure array and updates all coefficients
% affected by CG change. Dimension of the new CG position should be the
% same dimension used to initialize the datcom structure array.
%
% Inputs:
%    aero_statdyn - DATCOM aerodynamic data structure. 
%    xcg_new - new absolute mass center, x-axis.
%    zcg_new - new absolute mass center, z-axis.
%
% Outputs:
%    aero_statdyn - Updated DATCOM aerodynamic data structure with new CG.
%                   Can be directly used in DATCOM Forces and Moments
%                   block.
%
% Examples:
%    aero_statdyn = cg_shift(aero_statdyn, xcg, zcg)
%    aero_statdyn = cg_shift(aero_statdyn, xcg)
%
% Limitations:
% 
% Required m-files: None
%
% See also: datcom_import

%% Default parameters
if nargin < 3
    zcg_new = 0;
end

%% Updating DATCOM structure
asd_old = aero_statdyn;  % Old aerodynamic data structure
c = aero_statdyn.cbarr;  % longitdunal reference length

xcg_old = aero_statdyn.xcg;

% Updating xcg
aero_statdyn.xcg = xcg_new;
aero_statdyn.zcg = zcg_new;

% Updating xcp
aero_statdyn.xcp = (xcg_new - xcg_old + asd_old.xcp*c) / c;

% Updating cm
aero_statdyn.cm  = asd_old.cm .* (aero_statdyn.xcp ./ asd_old.xcp);

% Updating cma
aero_statdyn.cma = asd_old.cma .* (aero_statdyn.xcp ./ asd_old.xcp);

end