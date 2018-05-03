% Project           :: Optical Odometer
% Author            :: Kenneth Laws
%                   :: Here Technologies
% Creation Date     :: 10/16/2017
%
% Evaluates a comparison between gps and image derives distance travelled
%
% change log
% 5/1/18 fix bug change of gap filled outlier rejected data variable name
% fix bug that rangefinder data was not being computed for each image pair
% interval.
% Change termination criteria

clear all

% set the path to saved or partial data products
dataPath = 'data/';

% set the indictor for the data run to process
[imgPath rngFndrPath gpsPath dataSetID] = getImgPath;


% load in the raw sequential image processed data
fname = ['seq_image_rslt_' dataSetID '.mat'];
load([dataPath fname]);

% set optical time to time at the end of the measured translation
optTime = imageTime(:,2);

% load corrected data rejection/gap filling algorithm
% to create new data rejection file, see plot_seqImg_rslt.m
correctedDataFile = ['seq_image_rslt_' dataSetID '_filtrd.mat'];

load([dataPath correctedDataFile ], 'imageTime', 'transltPix');

rslt(:,2:3) = transltPix;


% load the range finder data
[rngTime, rng, errCnt, meanRng] = read_rngfndr(dataSetID,rngFndrPath);


% set image number array
imgNum = rslt(:,1)' - 1;


% load the gps data
[gpsSpd, gpsPos, insAtt] = readGpsImu_span(dataSetID);
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

%-------------------------------------------------------%
% perform an optimization to minimize squared error as a function of
% rangefinder parameters
cnt = 0;
rngOffset = 0;
lensScalefactor = 1.45;
scaleShift = .2;
offsetShift = .2;
sumSqrErr = 100;
lastErr = 100;
lowestErr = 100;
deltPosPix = rslt(:,2:3);
sumSqrErr = lastErr*[1 1 1 1];
lastMinErr = min(sumSqrErr);
s = [-1,-1;
    -1,1;
    1,-1;
    1,1];
while 1
    
    for jj = 1:4
        ss = s(jj,:);
        
        p1 = rngOffset + offsetShift*ss(1);
        p2 = lensScalefactor + scaleShift*ss(2);
        % convert to calibrated measure of translation (m)
        %deltPosMeters = compShift(deltPosPix,imageTime,rngTime,rng);
        deltPosMeters = optCompShift(deltPosPix,imageTime,meanRng,p1,...
            p2);
        
        optDl = sqrt(deltPosMeters(:,1).^2 + deltPosMeters(:,2).^2);
        %optDl = deltPosMeters(:,1);
        
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
        
        % compute the optical error in vehicle shift compared to the gps vehicle
        % shift, this neglects pitch angle and turning effect
        optErr = optIntDl - gpsDl;
        
        sumSqrErr(jj) = sum(optErr.^2, 'omitnan');
    end
    errShift = sumSqrErr - lastErr;
    lastErr = sumSqrErr;
    [minErr, idx] = min(sumSqrErr);
    if lastMinErr < minErr
        scaleShift = scaleShift*.25;
        offsetShift = offsetShift*.25;
    end
    
    ss = s(idx,:);
    rngOffset = rngOffset + offsetShift*ss(1);
    lensScalefactor = lensScalefactor + scaleShift*ss(2);
    
%     if abs(minErr - lastMinErr) < .00001
%         break;
%     end
    lastMinErr = minErr;
    
    if lowestErr - minErr > .0005
        lowestErr = minErr;
        fprintf('sum squared error = %0.5f\n',minErr);
        cnt = 0;
    else
        cnt = cnt +1;
        if cnt > 10 
            break;
        end
    end
    
end
% compare results
figure(3), clf, hold on;
plot(gpsTm,gpsDl)
plot(gpsTm,optIntDl,'r')
xlim([0 258])
xlabel('Time (sec)')
ylabel('Vehicle Translation (m)')


fprintf('optical error, mean = %0.4f, std = %0.4f\n', ...
    mean(optErr,'omitnan'), std(optErr,'omitnan'));
fprintf('lens scale factor = %0.5f\n',lensScalefactor);
fprintf('range offset = %0.5f\n',rngOffset);


