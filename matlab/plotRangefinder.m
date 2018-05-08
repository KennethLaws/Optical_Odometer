% Project           :: Optical Odometer
% Author            :: Kenneth Laws
%                   :: Here Technologies
% Creation Date     :: 5/7/2018
%
%
% Read and parse the rangefinder file
% plot the results
% Note: this script has a problem.  If saved .mat file does not exist, will
% fail because image time has not been passed.  The rangefinder reading
% function should be changed to not do averaging over image time intervals.
%  That should be in a separate function, or a subfunction of read_rngfndr
%
% Change log:
% 

clear all;

% load the rangfinder data
dataSetID = 'Test_Drive_041718';

[rngTime, rng, errCnt, meanRng] = read_rngfndr(dataSetID);



% plot 
figure(1), clf, hold on
plot(rngTime,rng)
xlabel('Time (sec)')
ylabel('Height Above Offset (cm)')

