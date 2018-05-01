% Project           :: Optical Odometer
% Author            :: Kenneth Laws
%                   :: Here Technologies
% Creation Date     :: 10/16/2017
% Modified          :: 
%
% Evaluates a comparison between gps and image derived distance travelled

clear all

% set the path to saved or partial data products
dataPath = 'data/';

% set the indictor for the data run to process
%[imgPath rngFndrPath gpsPath dataSetID] = getImgPath;

% set drive data set to operate on
dataSetID = 'Test_Drive_041718';

% load in the raw sequential image processed data
fname = ['seq_image_rslt_' dataSetID '.mat'];
load([dataPath fname]);

% load corrected data rejection/gap filling algorithm
% to create new data rejection file, see plot_seqImg_rslt.m
correctedDataFile = ['seq_image_rslt_' dataSetID '_filtrd.mat'];
load([dataPath correctedDataFile ],'adjTranslt');
rslt(:,2:3) = adjTranslt;


% load the range finder data
[rngTime, rng, errCnt] = read_rngfndr(dataSetID,rngFndrPath);

% set time step and image number arrays
%timeStep = 10/1562;     % colelcted 1562 images per 10 sec
imgNum = rslt(:,1)' - 1;

% convert to calibrated measure of translation (m)
deltPosPix = rslt(:,2:3);
deltPosMeters = compShift(deltPosPix,imageTime,rngTime,rng);
optTime = imageTime(:,2);   % time at the end of the measured translation, time converted to seconds

%for now, ignore the component of motion perpendicular to camera long axis
%(long axis should be roughly parallel to axis of car
optDl = deltPosMeters(:,1);


% load the gps data
[gpsSpd, gpsPos, insAtt] = readGpsImu_span(dataSetID,gpsPath);
gpsTime = gpsPos(:,1)';


% convert gps data to horizontal position in meters + altitude
[gpsX gpsY gpsZ] = latlon2xyz(gpsPos);
    

% compute the gps translations in x an y vs time
gpsDx = diff(gpsX);
gpsDy = diff(gpsY);
gpsTm = gpsTime(2:end);     % time at end of translation
gpsDl = sqrt(gpsDx.^2 + gpsDy.^2);  % compute horizontal translation


% shift to align image time with gps time results
gpsTm = gpsTm - gpsTime(1);  % reference gps time to the time of the first gps measurement
optTime = optTime - optTime(1);
optTimeShift = 0;
optTime = optTime - optTimeShift;  % manually sync times

% compute the integrated optical distance per gps time step
lastGpsTm = 0;
optIntDl = zeros(size(gpsTm));
for timeIdx = 1:length(gpsTm)
    idx = find(optTime <= gpsTm(timeIdx) & optTime > lastGpsTm);
    if isempty(idx)
        optIntDl(timeIdx) = NaN;
    else
        optIntDl(timeIdx) = sum(optDl(optTime <= gpsTm(timeIdx) & optTime > lastGpsTm));
    end
    lastGpsTm = gpsTm(timeIdx);
end


figure(3), clf, hold on;
plot(gpsTm,gpsDl)
plot(gpsTm,optIntDl,'r')
xlim([0 258])
xlabel('Time (sec)')
ylabel('Vehicle Translation (m)')

% compute the optical error in vehicle shift compared to the gps vehicle
% shift, this neglects pitch angle and turning effect
optErr = optIntDl - gpsDl;

fprintf('optical error, mean = %0.4f, std = %0.4f\n', ...
    mean(optErr,'omitnan'), std(optErr,'omitnan'));


