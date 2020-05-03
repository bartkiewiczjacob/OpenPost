function exitflag = datcom_run()
% datcom_run runs the USAF DATCOM 1976 executable which requires a
% for005.dat DATCOM input file. Both the DATCOM executable and for005.dat
% input file must be in the same directory the function is called. 
% 
% Inputs: None
% 
% Outputs: 
%    exitflag - DATCOM exit status
%               0: DATCOM ran successfully, does not mean input was correct
%               1: DATCOM could not be run
%               2: DATCOM encountered an error during runtime
%
% Examples:
%    datcom_run()
%    exitflag = datcom_run()
% 
% Required m-files: None
% 
% See also: datcom_input_file, datcom_run
[exitflag, cmdout] = system("DATCOM.exe"); 

% Delete unnecessary files
delete 'for008.dat' 'for009.dat' 'for010.dat' 'for011.dat'
delete 'for012.dat' 'for013.dat' 'for014.dat'

% command exit status check
if exitflag == 1
    str_error = "Could not run DATCOM.exe. It is either missing or " + ...
        "cannot be run on this system.\n%s";
    error(str_error, string(cmdout));
elseif exitflag == 2
    str_error = "Error during runtime of DATCOM.exe\n%s";
    error(str_error, string(cmdout));
elseif ~exitflag
    error(string(cmdout));
end

end