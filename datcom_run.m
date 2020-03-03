function [] = datcom_run()
% TODO
% Check if ran successfully
% Check for any errors in the output file

system("DATCOM.exe"); 
pause(1); % Datcom executable to generate files

% Delete unnecessary files
delete 'for008.dat' 'for009.dat' 'for010.dat' 'for011.dat'
delete 'for012.dat' 'for013.dat' 'for014.dat'

end