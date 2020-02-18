function [aerostatdyn, data, datcom_data] = datcom_import()
% Replacement function that scrapes data from datcom for006.dat output
% file.

% Replace these lines with import functionality
datcom_data = datcomimport('for006.dat',false);
data = datcom_data;

% Setting up datcom data structure
% Data setup from control cards
% aerostatdyn.mach   = [];  % input mach numbers
% aerostatdyn.alt    = [];  % alts (usually just 1)
% aerostatdyn.alpha  = [];  % angles of attack
% aerostatdyn.nmach  = 0;   % # of mach numbers
% aerostatdyn.nalt   = 0;   % # of alts
% aerostatdyn.nalpha = 0;   % # of alphas
% aerostatdyn.rnnub  = 0;   % Reynolds number
% aerostatdyn.sref   = 0;   % referance area
% aerostatdyn.cbar   = 0;   % reference fin chord length
% aerostatdyn.blref  = 0;   % reference length
% aerostatdyn.dim    = 'm';   % units for lengh
% aerostatdyn.deriv  = 'deg'; % derivative slope unit
% aerostatdyn.stmach = 0;   % subsonic-transonic transition mach #
% aerostatdyn.tsmach = 0;   % transonic supersonic transition mach #
% aerostatdyn.damp   = 0;   % datcom damping coeff option
% aerostatdyn.build  = 0;   % datcom sub-configuration print option
% aerostatdyn.version= 1976;  % USAF datcom version
% aerostatdyn.mcrit  = 0;   % critical Mach number
% aerostatdyn.xcg    = 0;   % axial cg from nose cone tip
% aerostatdyn.zcg    = 0;   % radial cg
% % Vehicle configuration
% aerostatdyn.config.body  = 0;  % vehicle body
% aerostatdyn.config.wing  = 0;  % vehicle wing
% aerostatdyn.config.htail = 0;  % vehicle horizontal tail
% aerostatdyn.config.vtail = 0;  % vehicle vertical tail
% aerostatdyn.config.vfin  = 0;  % vehilce ventral fin
% % Static stability data
% aerostatdyn.cd   = [];  % drag coefficient
% aerostatdyn.cl   = [];  % lift coefficient
% aerostatdyn.cm   = [];  % pitching moment coefficient
% aerostatdyn.cn   = [];  % normal coefficient
% aerostatdyn.ca   = [];  % axial coefficient
% aerostatdyn.xcp  = [];  % center of pressure (from cg)
% aerostatdyn.cma  = [];  % pitching moment coefficient slope wrt alpha
% aerostatdyn.cyb  = [];  % sideslip coefficient slope wrt beta
% aerostatdyn.cnb  = [];  % yawing moment coefficient slope wrt beta
% aerostatdyn.clb  = [];  % rolling moment coefficient slope wrt beta
% aerostatdyn.cla  = [];  % lift coefficient slope wrt alpha
% % Dynamic stability data
% aerostatdyn.clq  = [];  % lift coefficient slope wrt pitch rate
% aerostatdyn.cmq  = [];  % pitching coefficient slope wrt pitch rate
% aerostatdyn.clad = [];  % lift wrt rate of change of alpha
% aerostatdyn.cmad = [];  % pitching moment wrt rate of change of alpha
% aerostatdyn.clp  = [];  % rolling moment wrt roll rate
% aerostatdyn.cyp  = [];  % sideslip wrt roll-rate
% aerostatdyn.cnp  = [];  % yawing moment wrt roll rate
% aerostatdyn.cnr  = [];  % yawing moment wrt yaw rate
% aerostatdyn.clr  = [];  % rolling moment wrt yaw rate
% 
% % Line matching strings
% match_CASE = " CASEID ";
% match_FLTCON = "  $FLTCON";
% match_SYNTHS = "  $SYNTHS";
% match_OPTINS = "  $OPTINS";
% match_BODY = "  $BODY";
% match_strt = "1          THE FOLLOWING IS A LIST OF ALL";
% match_static = "ALPHA     CD       CL";
% match_static_end = "1                               AUTOMATED STABILITY AND CONTROL METHODS PER APRIL 1976 VERSION OF DATCOM";
% match_dynamic = "ALPHA       CLQ          CMQ           CLAD         CMAD         CLP          CYP          CNP          CNR          CLR";
% match_dynamic_end = "0*** NDM PRINTED WHEN NO DATCOM METHODS EXIST";
% % 1=control card, 2=flight data
% search_flag = 1;
% mach_count = 1;
% alpha_count = 1;
% fid = fopen('for006.dat');
% tline = fgetl(fid);
% while ischar(tline)
%     % Extracting data from each case
%     if search_flag == 1
%         tline = fgetl(fid);
%         if startsWith(tline,match_CASE)
%             tline = fgetl(fid);
%             while search_flag == 1
%                 if startsWith(tline, match_FLTCON)
%                     if contains(tline, 'MACH')
%                         newStr = extractAfter(tline,'MACH(1)=');
%                         m = sscanf(newStr, '%f,');
%                         aerostatdyn.mach  = [aerostatdyn.mach; m];
%                         tline = fgetl(fid);
%                         while ~startsWith(tline, match_FLTCON)
%                             m = sscanf(tline, '%f,');
%                             aerostatdyn.mach  = [aerostatdyn.mach; m];
%                             tline = fgetl(fid);
%                         end
%                     elseif contains(tline, 'ALSCHD')
%                         newStr = extractAfter(tline,'ALSCHD(1)=');
%                         a = sscanf(newStr, '%f,');
%                         aerostatdyn.alpha  = [aerostatdyn.alpha; a];
%                         tline = fgetl(fid);
%                         while ~(startsWith(tline, match_FLTCON) || startsWith(tline, ' DAMP'))
%                             a = sscanf(tline, '%f,');
%                             aerostatdyn.alpha  = [aerostatdyn.alpha; a];
%                             tline = fgetl(fid);
%                         end
%                     elseif contains(tline, 'ALT')
%                         newStr = extractAfter(tline,'ALT(1)=');
%                         aerostatdyn.alt = sscanf(newStr, '%f,');
%                         tline = fgetl(fid);
%                     else
%                         tline = fgetl(fid);
%                     end
%                 elseif startsWith(tline, match_SYNTHS)
%                     xcg = regexp(tline, 'XCG=([0-9]*[.])?[0-9]+', 'match');
%                     zcg = regexp(tline, 'ZCG=([0-9]*[.])?[0-9]+', 'match');
%                     aerostatdyn.xcg = str2double(extractAfter(xcg, 'XCG='));
%                     aerostatdyn.zcg = str2double(extractAfter(zcg, 'ZCG='));
%                     tline = fgetl(fid);
%                 elseif startsWith(tline, match_strt)
%                     search_flag = 2;
%                     aerostatdyn.cd   = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % drag coefficient
%                     aerostatdyn.cl   = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % lift coefficient
%                     aerostatdyn.cm   = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % pitching moment coefficient
%                     aerostatdyn.cn   = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % normal coefficient
%                     aerostatdyn.ca   = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % axial coefficient
%                     aerostatdyn.xcp  = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % center of pressure (from cg)
%                     aerostatdyn.cma  = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % pitching moment coefficient slope wrt alpha
%                     aerostatdyn.cyb  = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % sideslip coefficient slope wrt beta
%                     aerostatdyn.cnb  = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % yawing moment coefficient slope wrt beta
%                     aerostatdyn.clb  = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % rolling moment coefficient slope wrt beta
%                     aerostatdyn.cla  = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % lift coefficient slope wrt alpha
%                     aerostatdyn.clq  = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % lift coefficient slope wrt pitch rate
%                     aerostatdyn.cmq  = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % pitching coefficient slope wrt pitch rate
%                     aerostatdyn.clad = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % lift wrt rate of change of alpha
%                     aerostatdyn.cmad = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % pitching moment wrt rate of change of alpha
%                     aerostatdyn.clp  = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % rolling moment wrt roll rate
%                     aerostatdyn.cyp  = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % sideslip wrt roll-rate
%                     aerostatdyn.cnp  = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % yawing moment wrt roll rate
%                     aerostatdyn.cnr  = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % yawing moment wrt yaw rate
%                     aerostatdyn.clr  = zeros(length(aerostatdyn.alpha),length(aerostatdyn.mach));  % rolling moment wrt yaw rate
%                     tline = fgetl(fid);
%                 else
%                     tline = fgetl(fid);
%                 end
%             end
%         end
%     elseif search_flag == 2
%         tline = fgetl(fid);
%         fprintf(tline); fprintf('\n');
%         alpha_temp = 0;
%         if contains(tline, match_static)
%             fgetl(fid); tline = fgetl(fid);
%             stat_coeffs = strsplit(tline, ' ');
%             cd = str2double(stat_coeffs{3});
%             cl = str2double(stat_coeffs{4});
%             cm = str2double(stat_coeffs{5});
%             cn = str2double(stat_coeffs{6});
%             ca = str2double(stat_coeffs{7});
%             xcp = str2double(stat_coeffs{8});
%             cla = str2double(stat_coeffs{9});
%             cma = str2double(stat_coeffs{10});
%             cyb = str2double(stat_coeffs{11});
%             cnb = str2double(stat_coeffs{12});
%             clb = str2double(stat_coeffs{13});
%             alpha_temp = 0;
%             tline = fgetl(fid);
%             while ~startsWith(tline, match_static_end)
%                 stat_coeffs = strsplit(tline, ' ');
%                 cd = [cd; str2double(stat_coeffs{3})];
%                 cl = [cl; str2double(stat_coeffs{4})];
%                 cm = [cm; str2double(stat_coeffs{5})];
%                 cn = [cn; str2double(stat_coeffs{6})];
%                 ca = [ca; str2double(stat_coeffs{7})];
%                 xcp = [xcp; str2double(stat_coeffs{8})];
%                 cla = [cla; str2double(stat_coeffs{9})];
%                 clb = [clb; str2double(stat_coeffs{10})];
%                 cyb = [cyb; NaN]; cnb = [cnb; NaN]; cma = [cma; NaN];
%                 alpha_temp = alpha_temp + 1;
%                 tline = fgetl(fid);
%             end
%             aerostatdyn.cd(alpha_count:alpha_count+alpha_temp,mach_count) = cd;
%             aerostatdyn.cl(alpha_count:alpha_count+alpha_temp,mach_count) = cl;
%             aerostatdyn.cm(alpha_count:alpha_count+alpha_temp,mach_count) = cm;
%             aerostatdyn.cn(alpha_count:alpha_count+alpha_temp,mach_count) = cn;
%             aerostatdyn.ca(alpha_count:alpha_count+alpha_temp,mach_count) = ca;
%             aerostatdyn.xcp(alpha_count:alpha_count+alpha_temp,mach_count) = xcp;
%             aerostatdyn.cma(alpha_count:alpha_count+alpha_temp,mach_count) = cma;
%             aerostatdyn.cyb(alpha_count:alpha_count+alpha_temp,mach_count) = cyb;
%             aerostatdyn.cnb(alpha_count:alpha_count+alpha_temp,mach_count) = cnb;
%             aerostatdyn.clb(alpha_count:alpha_count+alpha_temp,mach_count) = clb;
%         elseif contains(tline, match_dynamic)
%             fprintf('2')
%             fgetl(fid); tline = fgetl(fid);
%             stat_coeffs = strsplit(tline, ' ');
%             clq = str2double(stat_coeffs{3});
%             cmq = str2double(stat_coeffs{4});
%             clad = str2double(stat_coeffs{5});
%             cmad = str2double(stat_coeffs{6});
%             clp = str2double(stat_coeffs{7});
%             cyp = str2double(stat_coeffs{8});
%             cnp = str2double(stat_coeffs{9});
%             cnr = str2double(stat_coeffs{10});
%             clr = str2double(stat_coeffs{11});
%             alpha_temp = 0;
%             tline = fgetl(fid);
%             while ~startsWith(tline, match_dynamic_end)
%                 stat_coeffs = strsplit(tline, ' ');
%                 clp = [clp; str2double(stat_coeffs{3})];
%                 cyp = [cyp; str2double(stat_coeffs{4})];
%                 cnp = [cnp; str2double(stat_coeffs{5})];
%                 cnr = [cnr; str2double(stat_coeffs{6})];
%                 clr = [clr; str2double(stat_coeffs{7})];
%                 clq = [clq; NaN]; cmq = [cmq; NaN]; 
%                 clad = [clad; NaN]; cmad = [cmad; NaN];
%                 alpha_temp = alpha_temp + 1;
%                 tline = fgetl(fid);
%             end
%             aerostatdyn.clq(alpha_count:alpha_count+alpha_temp,mach_count) = clq;
%             aerostatdyn.cmq(alpha_count:alpha_count+alpha_temp,mach_count) = cmq;
%             aerostatdyn.clad(alpha_count:alpha_count+alpha_temp,mach_count) = clad;
%             aerostatdyn.cmad(alpha_count:alpha_count+alpha_temp,mach_count) = cmad;
%             aerostatdyn.clp(alpha_count:alpha_count+alpha_temp,mach_count) = clp;
%             aerostatdyn.cyp(alpha_count:alpha_count+alpha_temp,mach_count) = cyp;
%             aerostatdyn.cnp(alpha_count:alpha_count+alpha_temp,mach_count) = cnp;
%             aerostatdyn.cnr(alpha_count:alpha_count+alpha_temp,mach_count) = cnr;
%             aerostatdyn.clr(alpha_count:alpha_count+alpha_temp,mach_count) = clr;
%             mach_count = mach_count + 1;
%         end
%         if mach_count == length(aerostatdyn.mach)
%             mach_count = 1;
%             alpha_count = alpha_count + alpha_temp;
%         end
%     end
% end

% merging all case data into a single structure
for i = flip(1:length(data)-1)
    data{end}.alpha = [data{i}.alpha data{end}.alpha];
    data{end}.cd = [data{i}.cd; data{end}.cd];
    data{end}.cl = [data{i}.cl; data{end}.cl];
    data{end}.cm = [data{i}.cm; data{end}.cm];
    data{end}.cn = [data{i}.cn; data{end}.cn];
    data{end}.ca = [data{i}.ca; data{end}.ca];
    data{end}.xcp = [data{i}.xcp; data{end}.xcp];
    data{end}.cma = [data{i}.cma; data{end}.cma];
    data{end}.cyb = [data{i}.cyb; data{end}.cyb];
    data{end}.cnb = [data{i}.cnb; data{end}.cnb];
    data{end}.clb = [data{i}.clb; data{end}.clb];
    data{end}.cla = [data{i}.cla; data{end}.cla];
    data{end}.clq = [data{i}.clq; data{end}.clq];
    data{end}.cmq = [data{i}.cmq; data{end}.cmq];
    data{end}.clad = [data{i}.clad; data{end}.clad];
    data{end}.cmad = [data{i}.cmad; data{end}.cmad];
    data{end}.clp = [data{i}.clp; data{end}.clp];
    data{end}.cyp = [data{i}.cyp; data{end}.cyp];
    data{end}.cnp = [data{i}.cnp; data{end}.cnp];
    data{end}.cnr = [data{i}.cnr; data{end}.cnr];
    data{end}.clr = [data{i}.clr; data{end}.clr];
end
data{end}.nmach = length(data{end}.mach);
data{end}.nalpha = length(data{end}.alpha);


% Reparing Data
data{end}.xcp(1,:)=data{end}.xcp(2,:);
data{end}.nalpha = length(data{end}.alpha);
data{end}.nmach = length(data{end}.mach);
data{end}.mach(1)=0;
data{end}.alpha(end)=180;

% Replacing all NaN Data
data{end}.cd(isnan(data{end}.cd)) = 0;
data{end}.cl(isnan(data{end}.cl)) = 0;
data{end}.cm(isnan(data{end}.cm)) = 0;
data{end}.cn(isnan(data{end}.cn)) = 0;
data{end}.ca(isnan(data{end}.ca)) = 0;
data{end}.xcp(isnan(data{end}.xcp)) = 0;
data{end}.cma(isnan(data{end}.cma)) = 0;
data{end}.cyb(isnan(data{end}.cyb)) = 0;
data{end}.cnb(isnan(data{end}.cnb)) = 0;
data{end}.clb(isnan(data{end}.clb)) = 0;
data{end}.cla(isnan(data{end}.cla)) = 0;
data{end}.clq(isnan(data{end}.clq)) = 0;
data{end}.cmq(isnan(data{end}.cmq)) = 0;
data{end}.clad(isnan(data{end}.clad)) = 0;
data{end}.cmad(isnan(data{end}.cmad)) = 0;
data{end}.clp(isnan(data{end}.clp)) = 0;
data{end}.cyp(isnan(data{end}.cyp)) = 0;
data{end}.cnp(isnan(data{end}.cnp)) = 0;
data{end}.cnr(isnan(data{end}.cnr)) = 0;
data{end}.clr(isnan(data{end}.clr)) = 0;

% Filling out dynamic aero coefficients
aerotab = {'cyb' 'cnb' 'clq' 'cmq','clad','cmad'};
for k = 1:length(aerotab)
    for m = 1:data{end}.nmach
        for h = 1:data{end}.nalt
            data{end}.(aerotab{k})(:,m,h) = data{end}.(aerotab{k})(1,m,h);
        end
    end
end

% Copying cla data to cyb
data{end}.cyb = data{end}.cla;

% Flipping and extending data for negative alpha
data{end}.alpha = [-flip(data{end}.alpha(2:end)) data{end}.alpha];
data{end}.cd = [flip(data{end}.cd(2:end,:)); data{end}.cd];
data{end}.cl = [-flip(data{end}.cl(2:end,:)); data{end}.cl];
data{end}.cm = [-flip(data{end}.cm(2:end,:)); data{end}.cm];
data{end}.cn = [-flip(data{end}.cn(2:end,:)); data{end}.cn];
data{end}.ca = [flip(data{end}.ca(2:end,:)); data{end}.ca];
data{end}.xcp = [flip(data{end}.xcp(2:end,:)); data{end}.xcp];
data{end}.cma = [flip(data{end}.cma(2:end,:)); data{end}.cma];
data{end}.cyb = [flip(data{end}.cyb(2:end,:)); data{end}.cyb];
data{end}.cnb = [flip(data{end}.cnb(2:end,:)); data{end}.cnb];
data{end}.clb = [flip(data{end}.clb(2:end,:)); data{end}.clb];
data{end}.cla = [flip(data{end}.cla(2:end,:)); data{end}.cla];
data{end}.clq = [flip(data{end}.clq(2:end,:)); data{end}.clq];
data{end}.cmq = [flip(data{end}.cmq(2:end,:)); data{end}.cmq];
data{end}.clad = [flip(data{end}.clad(2:end,:)); data{end}.clad];
data{end}.cmad = [flip(data{end}.cmad(2:end,:)); data{end}.cmad];
data{end}.clp = [flip(data{end}.clp(2:end,:)); data{end}.clp];
data{end}.cyp = [flip(data{end}.cyp(2:end,:)); data{end}.cyp];
data{end}.cnp = [flip(data{end}.cnp(2:end,:)); data{end}.cnp];
data{end}.cnr = [flip(data{end}.cnr(2:end,:)); data{end}.cnr];
data{end}.clr = [flip(data{end}.clr(2:end,:)); data{end}.clr];

aerostatdyn = data{end};  % Variable for use in Datcom Block (Digital Datcom Structure)

% Also cleans data after import
end
