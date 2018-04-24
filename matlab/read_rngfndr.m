function [rngTime, rng, errCnt] = read_rngfndr(runId,rngFndrPath)
%
% Project:      ::     Optical odometer
% Author        ::     Kenneth Laws
%               ::     Here Technologies
% Date Created  ::     12/14/2017
%
% Reads data file generated by the rangefinder (python script)

% if nargin < 1
%     rngfndrFile = 'AR700.txt';
%     
%     if exist('/Volumes/M2Ext/Test_Drive_0404/rangefinder/')
%         rngfndrPath = '/Volumes/M2Ext/Test_Drive_0404/rangefinder/';
%     elseif exist('/media/earthmine/M2Ext/Test_Drive_0404/rangefinder/')
%         rngfndrPath = '/media/earthmine/M2Ext/Test_Drive_0404/rangefinder/';
%     else
%         error('data folder not found, update path in script or plug in external drive');
%     end
% end

if exist(['data/' runId '_AR700.mat'])
    load(['data/' runId '_AR700.mat']);
else
    
    
    % open the file
    fid = fopen([rngFndrPath 'AR700.txt']);
    
    % read the data
    delimiter = ',';
    startRow = 2;
    formatSpec = '%q%q%[^\n\r]';
    data = textscan(fid, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    fclose(fid);
    
    % convert the cell arrays to arrays of numbers
    % non numeric values are converted to NaN
    rngTime = data{1};
    rng = data{2};
    rngTime = str2double(rngTime);
    rng = str2double(rng);
    
    % sum the errors
    errCnt = sum(isnan(rng));
    save(['data/' runId '_AR700.mat'],'rngTime', 'rng', 'errCnt');
end

return
