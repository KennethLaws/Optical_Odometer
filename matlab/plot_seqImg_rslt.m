
function plot_seqImg_rslt(rsltFile, correctedDataFile)
% Project           :: Optical Odometer
% Author            :: Kenneth Laws
%                   :: Here Technologies
% Creation Date     :: 10/16/2017
% modified:         :: 
%
% Plot the sequential image results: plots vehicle speed vs image number,
% indicates rejected points, plots snr and results after data rejection and
% gap filling
%
% Change log: 04/23/18: makes gap filling a function
% 


dataPath = 'data/';
if nargin == 0
    fname = 'seq_image_rslt_Test_Drive_041718';
    % set name to save or read filtered data set
    correctedDataFile = [fname '_filtrd.mat'];
end


% load in the raw sequential image processed data
load([dataPath rsltFile '.mat']);

% % start and end image by image number
% img_start = 0;
% img_end = 141;
% rng = (img_start+1):(img_end+1);

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


% either load corrected data or apply data rejection/gap filling algorithm
% to produce corrected data file
% if exist([dataPath correctedDataFile])
%     s = input('Use existing filtered data file? (Y/n)','s');
%     if s == 'n'
%         disp 'computing gap filling filter data' 
%         compFilt = 1;
%     else
%         disp 'using existing gap filling filter data'
%         compFilt = 0;
%     end
% else
%     compFilt = 1;
% end
% 
% if compFilt == 1
%     adjTranslt = applyDataRejection(rslt);

%     % add a new bad data filter to test
%     
% %     % find data with low snr over ambiguities
% %     idx = find(   (rslt(:,15) > 40 | rslt(:,16) > 40) & rslt(:,17) < .5        );
% %     vehSpd(idx) = NaN;
% %     rslt(idx,6) = 1;
% 
%     
%     % fill gaps
%     % sweep through data range fitting data where there are gaps avoiding
%     % extrapolation
%     save([dataPath correctedDataFile ], 'adjTranslt');
%  end


load([dataPath correctedDataFile ], 'imageTime', 'transltPix');

%total_Y = sum(rslt(rng,4));
% total_Y = sum(vehDy);
% fprintf('Total distance travelled, y = %0.2f m\n',total_Y);

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

% indicate data with low snr over ambiguities
% idx = find(   (rslt(:,15) > 40 | rslt(:,16) > 40) & rslt(:,17) < .5        );
% plot(imgNum(idx),vehSpd(idx),'g.')

ylabel('Vehicle Translation (pixels)');
xlabel('Image Number')
title(rsltFile, 'Interpreter', 'none' ) 

%rslt(step,:) = [step,deltPosPix,deltPosMeters,reject,snr_db,fracSat,fracBlk,normDiff,edgeLim,BLK,SAT,MSMTCH,deltPosAmbg,snrAmbg];

% figure(7), clf, hold on
% plot(rslt(:,1),rslt(:,11),'b.')
% plot(rslt(:,1),rslt(:,14),'g.')
% ylabel('reject codes');
% xlabel('Image Number')

figure(8), clf, hold on
plot(rslt(:,1),rslt(:,6),'b.')
plot(rslt(rslt(:,6) == 1,1),rslt(rslt(:,6) == 1,6),'r.')
ylabel('reject codes');
xlabel('Image Number')
title('Data Rejected')



