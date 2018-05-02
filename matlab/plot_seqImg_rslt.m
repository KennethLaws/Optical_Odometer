
function plot_seqImg_rslt(rsltFile, correctedDataFile)
% Project           :: Optical Odometer
% Author            :: Kenneth Laws
%                   :: Here Technologies
% Creation Date     :: 10/16/2017
% modified:         :: 
%
% Plot the sequential image results: plots vehicle translation vs image number,
% indicates rejected points, plots snr and results after data rejection and
% gap filling
%
% Change log: 
% 4/23/18: makes gap filling a function
% 4/30/18 moves the gap filling and data rejection to the processing script


if nargin == 0
    rsltFile = 'seq_image_rslt_Test_Drive_041718';
    % set name to save or read filtered data set
    correctedDataFile = [rsltFile '_filtrd.mat'];
end

dataPath = 'data/';

% load in the raw sequential image processed data
load([dataPath rsltFile '.mat']);


%timeStep = 10/1562;     % colelcted 1562 images per 10 sec
vehDy = rslt(:,2)';
% vehSpd = vehDy/timeStep;
imgNum = rslt(:,1)' - 1;


% dataGaps = imgNum(rslt(:,6) == 1);
figure(4), clf, hold on
ylabel('Vehicle translation (pixels)');
xlabel('Image Number')
title(rsltFile, 'Interpreter', 'none' ) 
plot(rslt(:,1),vehDy)
plot(rslt(rslt(:,6) == 1,1),vehDy(rslt(:,6) == 1),'r.')


figure(5), clf
plot(rslt(:,1),rslt(:,7))
ylabel('SNR (dB)');
xlabel('Image Number')


load([dataPath correctedDataFile ], 'imageTime', 'transltPix');


figure(6), clf, hold on
plot(imgNum,transltPix(:,1),'b-')
plot(imgNum,transltPix(:,1),'b.')
idx = find(rslt(:,6) == 1);

% indicate data with reject codes
plot(imgNum(idx),transltPix(idx,1),'r.');

% compute fraction of rejected data points
numReject = length(idx);
fracReject = numReject/length(vehDy)*100;
fprintf('fraction of data rejected = %0.2f\n',fracReject);

ylabel('Vehicle Translation (pixels)');
xlabel('Image Number')
title(rsltFile, 'Interpreter', 'none' ) 

figure(8), clf, hold on
plot(rslt(:,1),rslt(:,6),'b.')
plot(rslt(rslt(:,6) == 1,1),rslt(rslt(:,6) == 1,6),'r.')
ylabel('reject codes');
xlabel('Image Number')
title('Data Rejected')



