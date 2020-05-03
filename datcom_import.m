function aero_statdyn = datcom_import(filename)
% Scrapes data from DATCOM for006.dat output file. for006.dat must be in 
% the same directory as calling function. Associated for005 input file 
% must have been generated using the datcom_input_file() function to 
% guarantee all data is scraped correctly. Replacement for aerospace 
% toolbox function "datcomimport".
%
% Inputs:
%    filename - location of datcom output file, string.
%
% Outputs: 
%    aero_statdyn - DATCOM aerodynamic data structure array. Compatible
%                   with the Digital DATCOM Forces and Moments block.
%
% Examples:
%    aero_statdyn = datcom_import()
%    aero_statdyn = datcom_import('for006.dat')
%
% Limitations: Should only be used with output files originating from
% datcom input files generated from datcom_input_file.
%
% Required m-files: None
%
% See also: datcom_input_file, datcom_run

%% Default Parameters
if nargin < 1
    filename = 'for006.dat';
end

%% DATCOM Output File Parsing
% Setting up datcom structure array
% Data setup from control cards
aero_statdyn.mach   = [];  % input mach numbers
aero_statdyn.alpha  = [];  % angles of attack
aero_statdyn.nmach  = 0;   % # of mach numbers
aero_statdyn.nalpha = 0;   % # of alphas
aero_statdyn.sref   = 0;   % referance area
aero_statdyn.cbar   = 0;   % reference fin chord length
aero_statdyn.blref  = 0;   % reference length
aero_statdyn.dim    = 'ft';  % units for lengh
aero_statdyn.deriv  = 'deg'; % derivative slope unit
aero_statdyn.stmach = 0;   %* subsonic-transonic transition mach #
aero_statdyn.tsmach = 0;   %* transonic supersonic transition mach #
aero_statdyn.damp   = false; % datcom damping coeff option
aero_statdyn.build  = 0;   % datcom sub-configuration print option
aero_statdyn.version= 1976;  % USAF datcom version
aero_statdyn.mcrit  = 0;   %* critical Mach number
aero_statdyn.xcg    = 0;   % axial cg from nose cone tip
aero_statdyn.zcg    = 0;   % radial cg
aero_statdyn.save = false; % save case data flag
% Vehicle configuration
aero_statdyn.config.body  = 0;  % vehicle body
aero_statdyn.config.wing  = 0;  % vehicle wing
aero_statdyn.config.htail = 0;  % vehicle horizontal tail
aero_statdyn.config.vtail = 0;  % vehicle vertical tail
aero_statdyn.config.vfin  = 0;  % vehilce ventral fin
% Static stability data
aero_statdyn.cd   = [];  % drag coefficient
aero_statdyn.cl   = [];  % lift coefficient
aero_statdyn.cm   = [];  % pitching moment coefficient
aero_statdyn.cn   = [];  % normal coefficient
aero_statdyn.ca   = [];  % axial coefficient
aero_statdyn.xcp  = [];  % center of pressure (from cg)
aero_statdyn.cma  = [];  % pitching moment coefficient slope wrt alpha
aero_statdyn.cyb  = [];  % sideslip coefficient slope wrt beta
aero_statdyn.cnb  = [];  % yawing moment coefficient slope wrt beta
aero_statdyn.clb  = [];  % rolling moment coefficient slope wrt beta
aero_statdyn.cla  = [];  % lift coefficient slope wrt alpha
% Dynamic stability data
aero_statdyn.clq  = [];  % lift coefficient slope wrt pitch rate
aero_statdyn.cmq  = [];  % pitching coefficient slope wrt pitch rate
aero_statdyn.clad = [];  % lift wrt rate of change of alpha
aero_statdyn.cmad = [];  % pitching moment wrt rate of change of alpha
aero_statdyn.clp  = [];  % rolling moment wrt roll rate
aero_statdyn.cyp  = [];  % sideslip wrt roll-rate
aero_statdyn.cnp  = [];  % yawing moment wrt roll rate
aero_statdyn.cnr  = [];  % yawing moment wrt yaw rate
aero_statdyn.clr  = [];  % rolling moment wrt yaw rate
% Other (required by DATCOM simulink block)
aero_statdyn.case    = char(); 
aero_statdyn.rnnub   = [];     
aero_statdyn.hypers  = false;   
aero_statdyn.stype   = [];      
aero_statdyn.trim    = false;   
aero_statdyn.part    = false;   
aero_statdyn.highsym = false;   
aero_statdyn.highasy = false;  
aero_statdyn.highcon = false;  
aero_statdyn.tjet    = false;  
aero_statdyn.hypeff  = false;  
aero_statdyn.lb      = false;  
aero_statdyn.pwr     = false;  
aero_statdyn.wsspn   = 1;      
aero_statdyn.hsspn   = 1;      
aero_statdyn.ndelta  = 0;      
aero_statdyn.delta   = [];     
aero_statdyn.deltal  = [];     
aero_statdyn.deltar  = [];     
aero_statdyn.ngh     = 0;      
aero_statdyn.grnd    = false;  
aero_statdyn.grndht  = [];
aero_statdyn.nalt = 1;

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

% Parsing DATCOM file
search_flag = 1;  % 1=control card, 2=flight data
mach_count = 1;
alpha_count = 1;
subsonic = true;
fid = fopen(filename);
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
                        aero_statdyn.mach = [aero_statdyn.mach, m'];
                        tline = fgetl(fid);
                        while startsWith(tline, "   ")
                            m = sscanf(tline, "%f,");
                            aero_statdyn.mach  = [aero_statdyn.mach, m'];
                            tline = fgetl(fid);
                        end
                        
                    % Angle of attack definition    
                    elseif contains(tline, "ALSCHD(1)=")
                        aoa_list = extractAfter(tline, "ALSCHD(1)=");
                        aoa = sscanf(aoa_list, "%f,");
                        aero_statdyn.alpha = [aero_statdyn.alpha, aoa'];
                        tline = fgetl(fid);
                        while startsWith(tline, "   ")
                            aoa = sscanf(tline, "%f,");
                            aero_statdyn.alpha  = [aero_statdyn.alpha, aoa'];
                            tline = fgetl(fid);
                        end
                    % ALT flight card
                    elseif contains(tline, "ALT(1)=")
                        alt_list = extractAfter(tline, "ALT(1)=");
                        aero_statdyn.alt = sscanf(alt_list, '%f,');
                        tline = fgetl(fid);
                    else
                        tline = fgetl(fid);
                    end
                % Synths (SYNTHS)
                elseif startsWith(tline, match_SYNTHS)
                    aero_statdyn.xcg = sscanf(extractAfter(tline, "XCG="), "%f");
                    aero_statdyn.zcg = sscanf(extractAfter(tline, "ZCG="), "%f");
                    tline = fgetl(fid);
                % Optional params (OPTINS)
                elseif startsWith(tline, match_OPTINS)
                    aero_statdyn.sref = sscanf(extractAfter(tline, "SREF="), "%f");
                    aero_statdyn.cbar = sscanf(extractAfter(tline, "CBARR="), "%f");
                    aero_statdyn.blref = sscanf(extractAfter(tline, "BLREF="), "%f");
                    aero_statdyn.rougfc = sscanf(extractAfter(tline, "ROUGFC"), "%f");
                    tline = fgetl(fid);
                % Body params (BODY)
                elseif startsWith(tline, match_BODY)
                    % TODO: PULL BODY DATA HERE
                    tline = fgetl(fid);
                % Damp control card input
                elseif startsWith(tline, " DAMP")
                    aero_statdyn.damp = true;
                    tline = fgetl(fid);
                % Build control card input
                elseif startsWith(tline, " BUILD")
                    aero_statdyn.build = 1;
                    tline = fgetl(fid);
                % Save control card input
                elseif startsWith(tline, " SAVE")
                    aero_statdyn.save = true;
                    tline = fgetl(fid);
                elseif startsWith(tline, " DIM")
                    dim = extractAfter(tline, " DIM ");
                    if dim == "FT"
                        aero_statdyn.dim = "ft";
                    elseif dim == "M"
                        aero_statdyn.dim = "m";
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
            aero_statdyn.cd   = zeros(length(aero_statdyn.alpha),length(aero_statdyn.mach));  % drag coefficient
            aero_statdyn.cl   = zeros(length(aero_statdyn.alpha),length(aero_statdyn.mach));  % lift coefficient
            aero_statdyn.cm   = zeros(length(aero_statdyn.alpha),length(aero_statdyn.mach));  % pitching moment coefficient
            aero_statdyn.cn   = zeros(length(aero_statdyn.alpha),length(aero_statdyn.mach));  % normal coefficient
            aero_statdyn.ca   = zeros(length(aero_statdyn.alpha),length(aero_statdyn.mach));  % axial coefficient
            aero_statdyn.xcp  = zeros(length(aero_statdyn.alpha),length(aero_statdyn.mach));  % center of pressure (from cg)
            aero_statdyn.cma  = zeros(length(aero_statdyn.alpha),length(aero_statdyn.mach));  % pitching moment coefficient slope wrt alpha
            aero_statdyn.cyb  = zeros(length(aero_statdyn.alpha),length(aero_statdyn.mach));  % sideslip coefficient slope wrt beta
            aero_statdyn.cnb  = zeros(length(aero_statdyn.alpha),length(aero_statdyn.mach));  % yawing moment coefficient slope wrt beta
            aero_statdyn.clb  = zeros(length(aero_statdyn.alpha),length(aero_statdyn.mach));  % rolling moment coefficient slope wrt beta
            aero_statdyn.cla  = zeros(length(aero_statdyn.alpha),length(aero_statdyn.mach));  % lift coefficient slope wrt alpha
            aero_statdyn.clq  = zeros(length(aero_statdyn.alpha),length(aero_statdyn.mach));  % lift coefficient slope wrt pitch rate
            aero_statdyn.cmq  = zeros(length(aero_statdyn.alpha),length(aero_statdyn.mach));  % pitching coefficient slope wrt pitch rate
            aero_statdyn.clad = zeros(length(aero_statdyn.alpha),length(aero_statdyn.mach));  % lift wrt rate of change of alpha
            aero_statdyn.cmad = zeros(length(aero_statdyn.alpha),length(aero_statdyn.mach));  % pitching moment wrt rate of change of alpha
            aero_statdyn.clp  = zeros(length(aero_statdyn.alpha),length(aero_statdyn.mach));  % rolling moment wrt roll rate
            aero_statdyn.cyp  = zeros(length(aero_statdyn.alpha),length(aero_statdyn.mach));  % sideslip wrt roll-rate
            aero_statdyn.cnp  = zeros(length(aero_statdyn.alpha),length(aero_statdyn.mach));  % yawing moment wrt roll rate
            aero_statdyn.cnr  = zeros(length(aero_statdyn.alpha),length(aero_statdyn.mach));  % yawing moment wrt yaw rate
            aero_statdyn.clr  = zeros(length(aero_statdyn.alpha),length(aero_statdyn.mach));  % rolling moment wrt yaw rate
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
            aero_statdyn.cd(alpha_count:alpha_count+alpha_temp,mach_count) = cd;
            aero_statdyn.cl(alpha_count:alpha_count+alpha_temp,mach_count) = cl;
            aero_statdyn.cm(alpha_count:alpha_count+alpha_temp,mach_count) = cm;
            aero_statdyn.cn(alpha_count:alpha_count+alpha_temp,mach_count) = cn;
            aero_statdyn.ca(alpha_count:alpha_count+alpha_temp,mach_count) = ca;
            aero_statdyn.xcp(alpha_count:alpha_count+alpha_temp,mach_count) = xcp;
            aero_statdyn.cla(alpha_count:alpha_count+alpha_temp,mach_count) = cla;
            aero_statdyn.cma(alpha_count:alpha_count+alpha_temp,mach_count) = cma;
            aero_statdyn.cyb(alpha_count:alpha_count+alpha_temp,mach_count) = cyb;
            aero_statdyn.cnb(alpha_count:alpha_count+alpha_temp,mach_count) = cnb;
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
            aero_statdyn.clq(alpha_count:alpha_count+alpha_temp,mach_count) = clq;
            aero_statdyn.cmq(alpha_count:alpha_count+alpha_temp,mach_count) = cmq;
            % aero_statdyn.clad(alpha_count:alpha_count+alpha_temp,mach_count) = clad;
            aero_statdyn.cmad(alpha_count:alpha_count+alpha_temp,mach_count) = cmad;
            aero_statdyn.clp(alpha_count:alpha_count+alpha_temp,mach_count) = clp;
            aero_statdyn.cyp(alpha_count:alpha_count+alpha_temp,mach_count) = cyp;
            aero_statdyn.cnp(alpha_count:alpha_count+alpha_temp,mach_count) = cnp;
            aero_statdyn.cnr(alpha_count:alpha_count+alpha_temp,mach_count) = cnr;
            aero_statdyn.clr(alpha_count:alpha_count+alpha_temp,mach_count) = clr;
            mach_count = mach_count + 1;
        elseif contains(tline, 'CREST CRITICAL MACH =')
            aero_statdyn.mcrit = sscanf(extractAfter(tline, '='), '%f');
            tline = fgetl(fid);
        else
            tline = fgetl(fid);
            continue;
        end
        
        % Loop back if case is complete (Move on to the next batch of 
        % alphas, reset the mach counter)
        if mach_count > length(aero_statdyn.mach)
            mach_count = 1;
            alpha_count = alpha_count + alpha_temp + 1;
        end
    end
end

% Reparing Data
aero_statdyn.xcp(1,:)=aero_statdyn.xcp(2,:);
aero_statdyn.nalpha = length(aero_statdyn.alpha);
aero_statdyn.nmach = length(aero_statdyn.mach);
aero_statdyn.mach(1)=0;
aero_statdyn.alpha(end)=180;

% Repairing NaN data 
aero_statdyn.cma = fillmissing(aero_statdyn.cma, 'linear', 'SamplePoints', aero_statdyn.alpha);
aero_statdyn.clq = fillmissing(aero_statdyn.clq, 'previous');
aero_statdyn.cmq = fillmissing(aero_statdyn.cmq, 'previous');
aero_statdyn.clp = fillmissing(aero_statdyn.clp', 'previous')';
aero_statdyn.cyp = fillmissing(aero_statdyn.cyp', 'previous')';
aero_statdyn.cnp = fillmissing(aero_statdyn.cnp', 'previous')';
aero_statdyn.cnr = fillmissing(aero_statdyn.cnr', 'previous')';
aero_statdyn.clr = fillmissing(aero_statdyn.clr', 'previous')';

% Replacing all NaN data not covered with zeros
aero_statdyn.cd(isnan(aero_statdyn.cd)) = 0;
aero_statdyn.cl(isnan(aero_statdyn.cl)) = 0;
aero_statdyn.cm(isnan(aero_statdyn.cm)) = 0;
aero_statdyn.cn(isnan(aero_statdyn.cn)) = 0;
aero_statdyn.ca(isnan(aero_statdyn.ca)) = 0;
aero_statdyn.xcp(isnan(aero_statdyn.xcp)) = 0;
aero_statdyn.cma(isnan(aero_statdyn.cma)) = 0;
aero_statdyn.cyb(isnan(aero_statdyn.cyb)) = 0;
aero_statdyn.cnb(isnan(aero_statdyn.cnb)) = 0;
aero_statdyn.clb(isnan(aero_statdyn.clb)) = 0;
aero_statdyn.cla(isnan(aero_statdyn.cla)) = 0;
aero_statdyn.clq(isnan(aero_statdyn.clq)) = 0;
aero_statdyn.cmq(isnan(aero_statdyn.cmq)) = 0;
aero_statdyn.clad(isnan(aero_statdyn.clad)) = 0;
aero_statdyn.cmad(isnan(aero_statdyn.cmad)) = 0;
aero_statdyn.clp(isnan(aero_statdyn.clp)) = 0;
aero_statdyn.cyp(isnan(aero_statdyn.cyp)) = 0;
aero_statdyn.cnp(isnan(aero_statdyn.cnp)) = 0;
aero_statdyn.cnr(isnan(aero_statdyn.cnr)) = 0;
aero_statdyn.clr(isnan(aero_statdyn.clr)) = 0;

% Filling out dynamic aero coefficients
aerotab = {'cyb' 'cnb' 'clq' 'cmq','clad','cmad'};
for k = 1:length(aerotab)
    for m = 1:aero_statdyn.nmach
        aero_statdyn.(aerotab{k})(:,m,1) = aero_statdyn.(aerotab{k})(1,m,1);
    end
end

% Emperical sideslip data from DATCOM does not match nearly 
% as well as data wrt alpha
aero_statdyn.cyb = aero_statdyn.cla; % Copying cla data to cyb
aero_statdyn.cnb = aero_statdyn.cma; % Copying cma data to 

% Flipping and extending data for negative alpha
aero_statdyn.alpha = [-flip(aero_statdyn.alpha(2:end)) aero_statdyn.alpha];
aero_statdyn.cd = [flip(aero_statdyn.cd(2:end,:)); aero_statdyn.cd];
aero_statdyn.cl = [-flip(aero_statdyn.cl(2:end,:)); aero_statdyn.cl];
aero_statdyn.cm = [-flip(aero_statdyn.cm(2:end,:)); aero_statdyn.cm];
aero_statdyn.cn = [-flip(aero_statdyn.cn(2:end,:)); aero_statdyn.cn];
aero_statdyn.ca = [flip(aero_statdyn.ca(2:end,:)); aero_statdyn.ca];
aero_statdyn.xcp = [flip(aero_statdyn.xcp(2:end,:)); aero_statdyn.xcp];
aero_statdyn.cma = [flip(aero_statdyn.cma(2:end,:)); aero_statdyn.cma];
aero_statdyn.cyb = [flip(aero_statdyn.cyb(2:end,:)); aero_statdyn.cyb];
aero_statdyn.cnb = [flip(aero_statdyn.cnb(2:end,:)); aero_statdyn.cnb];
aero_statdyn.clb = [flip(aero_statdyn.clb(2:end,:)); aero_statdyn.clb];
aero_statdyn.cla = [flip(aero_statdyn.cla(2:end,:)); aero_statdyn.cla];
aero_statdyn.clq = [flip(aero_statdyn.clq(2:end,:)); aero_statdyn.clq];
aero_statdyn.cmq = [flip(aero_statdyn.cmq(2:end,:)); aero_statdyn.cmq];
aero_statdyn.clad = [flip(aero_statdyn.clad(2:end,:)); aero_statdyn.clad];
aero_statdyn.cmad = [flip(aero_statdyn.cmad(2:end,:)); aero_statdyn.cmad];
aero_statdyn.clp = [flip(aero_statdyn.clp(2:end,:)); aero_statdyn.clp];
aero_statdyn.cyp = [flip(aero_statdyn.cyp(2:end,:)); aero_statdyn.cyp];
aero_statdyn.cnp = [flip(aero_statdyn.cnp(2:end,:)); aero_statdyn.cnp];
aero_statdyn.cnr = [flip(aero_statdyn.cnr(2:end,:)); aero_statdyn.cnr];
aero_statdyn.clr = [flip(aero_statdyn.clr(2:end,:)); aero_statdyn.clr];
end