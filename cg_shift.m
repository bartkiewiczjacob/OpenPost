function aerostatdyn = cg_shift(aerostatdyn, xcg_new, zcg_new, unit)
% Shifts the CG for an datcom cell array and updates all coefficients
% affected by CG change.

% TODO
% Variables that change
% xcp - Complete
% cm  - Complete
% cma - Incomplete
% clp - Incomplete
% cyp - Incomplete
% cnp - Incomplete
% cnr - Incomplete
% clr - Incomplete
% 
% Implement unit flexibility (i.e. can use ft or m)

%% Default parameters
if nargin < 3
    zcg_new = 0;
end
if nargin < 4
    unit = 'ft';
end

asd_old = aerostatdyn;
c = aerostatdyn.cbarr;
b = aerostatdyn.bref;

xcg_old = aerostatdyn.xcg;
zcg_old = aerostatdyn.zcg;

d_xcg = xcg_old - xcg_new;
d_zcg = zcg_old - zcg_new;

% Updating xcg
aerostatdyn.xcg = xcg_new;
aerostatdyn.zcg = zcg_new;

% Updating xcp
aerostatdyn.xcp = (xcg_new - xcg_old + asd_old.xcp*c) / c;

% Updating cm
aerostatdyn.cm  = asd_old.cm .* (aerostatdyn.xcp ./ asd_old.xcp);

% Updating cma

% Updating clp

% Updating cyp

% Updating cnp

% Updating cnr

% Updating clr

end