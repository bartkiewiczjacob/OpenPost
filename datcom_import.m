function aerostatdyn = datcom_import()
% Replacement function that scrapes data from datcom for006.dat output
% file. Associated for005 input file must have been generated using the
% datcom_input_file() function to guarantee all data is scraped correctly.

% TODO
% - still need add reference area and cbar and blref - COMPLETE
% - pull critical mach number
% - parse vehicle info* - can just be done internally 
% - remove unused variables
% - preallocate aero coefficient during runtime to improve speed

% Setting up datcom data structure
% Data setup from control cards
aerostatdyn.mach   = [];  % input mach numbers
aerostatdyn.alt    = [];  % alts (usually just 1)
aerostatdyn.alpha  = [];  % angles of attack
aerostatdyn.nmach  = 0;   % # of mach numbers
aerostatdyn.nalt   = 0;   % # of alts
aerostatdyn.nalpha = 0;   % # of alphas
aerostatdyn.rnnub  = [];  % Reynolds number
aerostatdyn.sref   = 0;   % referance area
aerostatdyn.cbar   = 0;   % reference fin chord length
aerostatdyn.blref  = 0;   % reference length
aerostatdyn.dim    = 'ft';  % units for lengh
aerostatdyn.deriv  = 'deg'; % derivative slope unit
aerostatdyn.stmach = 0;   % subsonic-transonic transition mach #
aerostatdyn.tsmach = 0;   % transonic supersonic transition mach #
aerostatdyn.damp   = false; % datcom damping coeff option
aerostatdyn.build  = 0;   % datcom sub-configuration print option
aerostatdyn.version= 1976;  % USAF datcom version
aerostatdyn.mcrit  = 0;   % critical Mach number
aerostatdyn.xcg    = 0;   % axial cg from nose cone tip
aerostatdyn.zcg    = 0;   % radial cg
aerostatdyn.save = false; % save case data flag
% Vehicle configuration
aerostatdyn.config.body  = 0;  % vehicle body
aerostatdyn.config.wing  = 0;  % vehicle wing
aerostatdyn.config.htail = 0;  % vehicle horizontal tail
aerostatdyn.config.vtail = 0;  % vehicle vertical tail
aerostatdyn.config.vfin  = 0;  % vehilce ventral fin
% Defaults (Dont change on function call) 
aerostatdyn.case    = char(); % case name
aerostatdyn.rnnub   = [];     % Reynolds number 
aerostatdyn.hypers  = false;  % 
aerostatdyn.stype   = [];     % 
aerostatdyn.trim    = false;  % 
aerostatdyn.part    = false;  % 
aerostatdyn.highsym = false;  % 
aerostatdyn.highasy = false;  %
aerostatdyn.highcon = false;  %
aerostatdyn.tjet    = false;  %
aerostatdyn.hypeff  = false;  %
aerostatdyn.lb      = false;  %
aerostatdyn.pwr     = false;  %
aerostatdyn.wsspn   = 1;      %
aerostatdyn.hsspn   = 1;      %
aerostatdyn.ndelta  = 0;      %
aerostatdyn.delta   = [];     %
aerostatdyn.deltal  = [];     %
aerostatdyn.deltar  = [];     %
aerostatdyn.ngh     = 0;      %
aerostatdyn.grnd    = false;  %
aerostatdyn.grndht  = [];     %
% Static stability data
aerostatdyn.cd   = [];  % drag coefficient
aerostatdyn.cl   = [];  % lift coefficient
aerostatdyn.cm   = [];  % pitching moment coefficient
aerostatdyn.cn   = [];  % normal coefficient
aerostatdyn.ca   = [];  % axial coefficient
aerostatdyn.xcp  = [];  % center of pressure (from cg)
aerostatdyn.cma  = [];  % pitching moment coefficient slope wrt alpha
aerostatdyn.cyb  = [];  % sideslip coefficient slope wrt beta
aerostatdyn.cnb  = [];  % yawing moment coefficient slope wrt beta
aerostatdyn.clb  = [];  % rolling moment coefficient slope wrt beta
aerostatdyn.cla  = [];  % lift coefficient slope wrt alpha
% Dynamic stability data
aerostatdyn.clq  = [];  % lift coefficient slope wrt pitch rate
aerostatdyn.cmq  = [];  % pitching coefficient slope wrt pitch rate
aerostatdyn.clad = [];  % lift wrt rate of change of alpha
aerostatdyn.cmad = [];  % pitching moment wrt rate of change of alpha
aerostatdyn.clp  = [];  % rolling moment wrt roll rate
aerostatdyn.cyp  = [];  % sideslip wrt roll-rate
aerostatdyn.cnp  = [];  % yawing moment wrt roll rate
aerostatdyn.cnr  = [];  % yawing moment wrt yaw rate
aerostatdyn.clr  = [];  % rolling moment wrt yaw rate

% Line matching strings
match_CASE = " CASEID ";
match_FLTCON = "  $FLTCON";
match_SYNTHS = "  $SYNTHS";
match_OPTINS = "  $OPTINS";
match_BODY = "  $BODY";
match_strt = "1          THE FOLLOWING IS A LIST OF ALL";
match_static = "ALPHA     CD       CL";
match_static_end = "1                               AUTOMATED STABILITY";
match_dynamic = "ALPHA       CLQ          CMQ           CLAD";
match_dynamic_end = "0*** NDM PRINTED WHEN NO DATCOM METHODS EXIST";

% 1=control card, 2=flight data
search_flag = 1;
mach_count = 1;
alpha_count = 1;
subsonic = true;
fid = fopen('for006.dat');
tline = fgetl(fid);
while ischar(tline)
    if search_flag == 1
        % Parsing control cards and setting up DATCOM data structure
        
        % Line starting with case id
        if startsWith(tline, match_CASE)
            % looking through each control card
            while ~startsWith(tline, match_strt)
                % Flight conditions (FLTCON)
                if startsWith(tline, match_FLTCON)
                    % Mach number definition
                    if contains(tline, "MACH(1)=")
                        mach_list = extractAfter(tline, "MACH(1)=");
                        m = sscanf(mach_list, "%f,");
                        aerostatdyn.mach = [aerostatdyn.mach, m'];
                        tline = fgetl(fid);
                        while startsWith(tline, "   ")
                            m = sscanf(tline, "%f,");
                            aerostatdyn.mach  = [aerostatdyn.mach, m'];
                            tline = fgetl(fid);
                        end
                        
                    % Angle of attack definition    
                    elseif contains(tline, "ALSCHD(1)=")
                        aoa_list = extractAfter(tline, "ALSCHD(1)=");
                        aoa = sscanf(aoa_list, "%f,");
                        aerostatdyn.alpha = [aerostatdyn.alpha, aoa'];
                        tline = fgetl(fid);
                        while startsWith(tline, "   ")
                            aoa = sscanf(tline, "%f,");
                            aerostatdyn.alpha  = [aerostatdyn.alpha, aoa'];
                            tline = fgetl(fid);
                        end
                    % ALT flight card
                    elseif contains(tline, "ALT(1)=")
                        alt_list = extractAfter(tline, "ALT(1)=");
                        aerostatdyn.alt = sscanf(alt_list, '%f,');
                        tline = fgetl(fid);
                    else
                        tline = fgetl(fid);
                    end
                % Synths (SYNTHS)
                elseif startsWith(tline, match_SYNTHS)
                    aerostatdyn.xcg = sscanf(extractAfter(tline, "XCG="), "%f");
                    aerostatdyn.zcg = sscanf(extractAfter(tline, "ZCG="), "%f");
                    tline = fgetl(fid);
                % Optional params (OPTINS)
                elseif startsWith(tline, match_OPTINS)
                    aerostatdyn.sref = sscanf(extractAfter(tline, "SREF="), "%f");
                    aerostatdyn.cbar = sscanf(extractAfter(tline, "CBARR="), "%f");
                    aerostatdyn.blref = sscanf(extractAfter(tline, "BLREF="), "%f");
                    aerostatdyn.rougfc = sscanf(extractAfter(tline, "ROUGFC"), "%f");
                    tline = fgetl(fid);
                % Body params (BODY)
                elseif startsWith(tline, match_BODY)
                    % TODO: PULL BODY DATA HERE
                    tline = fgetl(fid);
                % Damp control card input
                elseif startsWith(tline, " DAMP")
                    aerostatdyn.damp = true;
                    tline = fgetl(fid);
                % Build control card input
                elseif startsWith(tline, " BUILD")
                    aerostatdyn.build = 1;
                    tline = fgetl(fid);
                % Save control card input
                elseif startsWith(tline, " SAVE")
                    aerostatdyn.save = true;
                    tline = fgetl(fid);
                elseif startsWith(tline, " DIM")
                    dim = extractAfter(tline, " DIM ");
                    if dim == "FT"
                        aerostatdyn.dim = "ft";
                    elseif dim == "M"
                        aerostatdyn.dim = "m";
                    end
                    tline = fgetl(fid);
                else
                    tline = fgetl(fid);
                end
            end
        % Line signifying start of data output    
        elseif startsWith(tline, match_strt)
            search_flag = 2; % change search flag
            % Initializing coeffs for speed
            aerostatdyn.cd   = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % drag coefficient
            aerostatdyn.cl   = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % lift coefficient
            aerostatdyn.cm   = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % pitching moment coefficient
            aerostatdyn.cn   = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % normal coefficient
            aerostatdyn.ca   = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % axial coefficient
            aerostatdyn.xcp  = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % center of pressure (from cg)
            aerostatdyn.cma  = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % pitching moment coefficient slope wrt alpha
            aerostatdyn.cyb  = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % sideslip coefficient slope wrt beta
            aerostatdyn.cnb  = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % yawing moment coefficient slope wrt beta
            aerostatdyn.clb  = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % rolling moment coefficient slope wrt beta
            aerostatdyn.cla  = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % lift coefficient slope wrt alpha
            aerostatdyn.clq  = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % lift coefficient slope wrt pitch rate
            aerostatdyn.cmq  = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % pitching coefficient slope wrt pitch rate
            aerostatdyn.clad = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % lift wrt rate of change of alpha
            aerostatdyn.cmad = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % pitching moment wrt rate of change of alpha
            aerostatdyn.clp  = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % rolling moment wrt roll rate
            aerostatdyn.cyp  = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % sideslip wrt roll-rate
            aerostatdyn.cnp  = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % yawing moment wrt roll rate
            aerostatdyn.cnr  = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % yawing moment wrt yaw rate
            aerostatdyn.clr  = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % rolling moment wrt yaw rate
            tline = fgetl(fid);
        else
            tline = fgetl(fid);
            continue
        end

    elseif search_flag == 2
    % Parsing flight coefficient data
    
        % Getting Mach regime
        if startsWith(tline, " NUMBER")
            fgetl(fid); tline = fgetl(fid);
            line = split(tline);
            mach = str2double(line(2));
            
            if mach > 1
                subsonic = false;
            else
                subsonic = true;
            end
        % Reading through static coefficients        
        elseif contains(tline, match_static)
            % First pass
            fgetl(fid); tline = fgetl(fid);
            stat_coeffs = strsplit(tline, ' ');
            cd = str2double(stat_coeffs{3});
            cl = str2double(stat_coeffs{4});
            cm = str2double(stat_coeffs{5});
            cn = str2double(stat_coeffs{6});
            ca = str2double(stat_coeffs{7});
            xcp = str2double(stat_coeffs{8});
            cla = str2double(stat_coeffs{9});
            cma = str2double(stat_coeffs{10});
            cyb = str2double(stat_coeffs{11});
            cnb = str2double(stat_coeffs{12});
            % clb = str2double(stat_coeffs{13});
            
            alpha_temp = 0;
            tline = fgetl(fid);
            while ~startsWith(tline, match_static_end)
                % Subsequent passes
                stat_coeffs = strsplit(tline, ' ');
                cd = [cd; str2double(stat_coeffs{3})];
                cl = [cl; str2double(stat_coeffs{4})];
                cm = [cm; str2double(stat_coeffs{5})];
                cn = [cn; str2double(stat_coeffs{6})];
                ca = [ca; str2double(stat_coeffs{7})];
                xcp = [xcp; str2double(stat_coeffs{8})];
                cla = [cla; str2double(stat_coeffs{9})];
                if subsonic
                    cma = [cma; str2double(stat_coeffs{10})];
                    % clb = [clb; str2double(stat_coeffs{11})];
                else
                    cma = [cma; NaN];
                    % clb = [clb; str2double(stat_coeffs{10})];
                end
                cyb = [cyb; NaN]; cnb = [cnb; NaN]; 
                alpha_temp = alpha_temp + 1;
                tline = fgetl(fid);
            end
            aerostatdyn.cd(alpha_count:alpha_count+alpha_temp,mach_count) = cd;
            aerostatdyn.cl(alpha_count:alpha_count+alpha_temp,mach_count) = cl;
            aerostatdyn.cm(alpha_count:alpha_count+alpha_temp,mach_count) = cm;
            aerostatdyn.cn(alpha_count:alpha_count+alpha_temp,mach_count) = cn;
            aerostatdyn.ca(alpha_count:alpha_count+alpha_temp,mach_count) = ca;
            aerostatdyn.xcp(alpha_count:alpha_count+alpha_temp,mach_count) = xcp;
            aerostatdyn.cla(alpha_count:alpha_count+alpha_temp,mach_count) = cla;
            aerostatdyn.cma(alpha_count:alpha_count+alpha_temp,mach_count) = cma;
            aerostatdyn.cyb(alpha_count:alpha_count+alpha_temp,mach_count) = cyb;
            aerostatdyn.cnb(alpha_count:alpha_count+alpha_temp,mach_count) = cnb;
            % aerostatdyn.clb(alpha_count:alpha_count+alpha_temp,mach_count) = clb;
        % Reading through dynamic coefficients
        elseif contains(tline, match_dynamic)
            % first pass
            fgetl(fid); tline = fgetl(fid);
            dyn_coeffs = strsplit(tline, ' ');
            clq = str2double(dyn_coeffs{3});
            cmq = str2double(dyn_coeffs{4});
            % clad = str2double(dyn_coeffs{5});
            cmad = str2double(dyn_coeffs{6});
            clp = str2double(dyn_coeffs{7});
            cyp = str2double(dyn_coeffs{8});
            cnp = str2double(dyn_coeffs{9});
            cnr = str2double(dyn_coeffs{10});
            clr = str2double(dyn_coeffs{11});
            
            alpha_temp = 0;
            tline = fgetl(fid);
            while ~startsWith(tline, match_dynamic_end)
                % subsequent passes
                dyn_coeffs = strsplit(tline, ' ');
                clp = [clp; str2double(dyn_coeffs{3})];
                cyp = [cyp; str2double(dyn_coeffs{4})];
                cnp = [cnp; str2double(dyn_coeffs{5})];
                cnr = [cnr; str2double(dyn_coeffs{6})];
                clr = [clr; str2double(dyn_coeffs{7})];
                clq = [clq; NaN]; cmq = [cmq; NaN]; 
                % clad = [clad; NaN]; 
                cmad = [cmad; NaN];
                alpha_temp = alpha_temp + 1;
                tline = fgetl(fid);
            end
            aerostatdyn.clq(alpha_count:alpha_count+alpha_temp,mach_count) = clq;
            aerostatdyn.cmq(alpha_count:alpha_count+alpha_temp,mach_count) = cmq;
            % aerostatdyn.clad(alpha_count:alpha_count+alpha_temp,mach_count) = clad;
            aerostatdyn.cmad(alpha_count:alpha_count+alpha_temp,mach_count) = cmad;
            aerostatdyn.clp(alpha_count:alpha_count+alpha_temp,mach_count) = clp;
            aerostatdyn.cyp(alpha_count:alpha_count+alpha_temp,mach_count) = cyp;
            aerostatdyn.cnp(alpha_count:alpha_count+alpha_temp,mach_count) = cnp;
            aerostatdyn.cnr(alpha_count:alpha_count+alpha_temp,mach_count) = cnr;
            aerostatdyn.clr(alpha_count:alpha_count+alpha_temp,mach_count) = clr;
            mach_count = mach_count + 1;
        else
            tline = fgetl(fid);
            continue;
        end
        
        % Loop back if case is complete (Move on to the next batch of 
        % alphas, reset the mach counter)
        if mach_count > length(aerostatdyn.mach)
            mach_count = 1;
            alpha_count = alpha_count + alpha_temp + 1;
        end
    end
end

% Reparing Data
aerostatdyn.xcp(1,:)=aerostatdyn.xcp(2,:);
aerostatdyn.nalpha = length(aerostatdyn.alpha);
aerostatdyn.nmach = length(aerostatdyn.mach);
aerostatdyn.mach(1)=0;
aerostatdyn.alpha(end)=180;

% Repairing NaN data 
aerostatdyn.cma = fillmissing(aerostatdyn.cma, 'linear', 'SamplePoints', aerostatdyn.alpha);
aerostatdyn.clq = fillmissing(aerostatdyn.clq, 'previous');
aerostatdyn.cmq = fillmissing(aerostatdyn.cmq, 'previous');
aerostatdyn.clp = fillmissing(aerostatdyn.clp', 'previous')';
aerostatdyn.cyp = fillmissing(aerostatdyn.cyp', 'previous')';
aerostatdyn.cnp = fillmissing(aerostatdyn.cnp', 'previous')';
aerostatdyn.cnr = fillmissing(aerostatdyn.cnr', 'previous')';
aerostatdyn.clr = fillmissing(aerostatdyn.clr', 'previous')';

% Replacing all NaN data not covered with zeros
aerostatdyn.cd(isnan(aerostatdyn.cd)) = 0;
aerostatdyn.cl(isnan(aerostatdyn.cl)) = 0;
aerostatdyn.cm(isnan(aerostatdyn.cm)) = 0;
aerostatdyn.cn(isnan(aerostatdyn.cn)) = 0;
aerostatdyn.ca(isnan(aerostatdyn.ca)) = 0;
aerostatdyn.xcp(isnan(aerostatdyn.xcp)) = 0;
aerostatdyn.cma(isnan(aerostatdyn.cma)) = 0;
aerostatdyn.cyb(isnan(aerostatdyn.cyb)) = 0;
aerostatdyn.cnb(isnan(aerostatdyn.cnb)) = 0;
aerostatdyn.clb(isnan(aerostatdyn.clb)) = 0;
aerostatdyn.cla(isnan(aerostatdyn.cla)) = 0;
aerostatdyn.clq(isnan(aerostatdyn.clq)) = 0;
aerostatdyn.cmq(isnan(aerostatdyn.cmq)) = 0;
aerostatdyn.clad(isnan(aerostatdyn.clad)) = 0;
aerostatdyn.cmad(isnan(aerostatdyn.cmad)) = 0;
aerostatdyn.clp(isnan(aerostatdyn.clp)) = 0;
aerostatdyn.cyp(isnan(aerostatdyn.cyp)) = 0;
aerostatdyn.cnp(isnan(aerostatdyn.cnp)) = 0;
aerostatdyn.cnr(isnan(aerostatdyn.cnr)) = 0;
aerostatdyn.clr(isnan(aerostatdyn.clr)) = 0;

% Filling out dynamic aero coefficients
aerotab = {'cyb' 'cnb' 'clq' 'cmq','clad','cmad'};
for k = 1:length(aerotab)
    for m = 1:aerostatdyn.nmach
        for h = 1:aerostatdyn.nalt
            aerostatdyn.(aerotab{k})(:,m,h) = aerostatdyn.(aerotab{k})(1,m,h);
        end
    end
end

% Emperical sideslip data from DATCOM does not match nearly 
% as well as data wrt alpha
aerostatdyn.cyb = aerostatdyn.cla; % Copying cla data to cyb
aerostatdyn.cnb = aerostatdyn.cma; % Copying cma data to 

% Flipping and extending data for negative alpha
aerostatdyn.alpha = [-flip(aerostatdyn.alpha(2:end)) aerostatdyn.alpha];
aerostatdyn.cd = [flip(aerostatdyn.cd(2:end,:)); aerostatdyn.cd];
aerostatdyn.cl = [-flip(aerostatdyn.cl(2:end,:)); aerostatdyn.cl];
aerostatdyn.cm = [-flip(aerostatdyn.cm(2:end,:)); aerostatdyn.cm];
aerostatdyn.cn = [-flip(aerostatdyn.cn(2:end,:)); aerostatdyn.cn];
aerostatdyn.ca = [flip(aerostatdyn.ca(2:end,:)); aerostatdyn.ca];
aerostatdyn.xcp = [flip(aerostatdyn.xcp(2:end,:)); aerostatdyn.xcp];
aerostatdyn.cma = [flip(aerostatdyn.cma(2:end,:)); aerostatdyn.cma];
aerostatdyn.cyb = [flip(aerostatdyn.cyb(2:end,:)); aerostatdyn.cyb];
aerostatdyn.cnb = [flip(aerostatdyn.cnb(2:end,:)); aerostatdyn.cnb];
aerostatdyn.clb = [flip(aerostatdyn.clb(2:end,:)); aerostatdyn.clb];
aerostatdyn.cla = [flip(aerostatdyn.cla(2:end,:)); aerostatdyn.cla];
aerostatdyn.clq = [flip(aerostatdyn.clq(2:end,:)); aerostatdyn.clq];
aerostatdyn.cmq = [flip(aerostatdyn.cmq(2:end,:)); aerostatdyn.cmq];
aerostatdyn.clad = [flip(aerostatdyn.clad(2:end,:)); aerostatdyn.clad];
aerostatdyn.cmad = [flip(aerostatdyn.cmad(2:end,:)); aerostatdyn.cmad];
aerostatdyn.clp = [flip(aerostatdyn.clp(2:end,:)); aerostatdyn.clp];
aerostatdyn.cyp = [flip(aerostatdyn.cyp(2:end,:)); aerostatdyn.cyp];
aerostatdyn.cnp = [flip(aerostatdyn.cnp(2:end,:)); aerostatdyn.cnp];
aerostatdyn.cnr = [flip(aerostatdyn.cnr(2:end,:)); aerostatdyn.cnr];
aerostatdyn.clr = [flip(aerostatdyn.clr(2:end,:)); aerostatdyn.clr];

end