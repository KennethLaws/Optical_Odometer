% Project           :: Optical Odometer
% Author            :: Kenneth Laws
%                   :: Here Technologies
% Creation Date     :: 10/16/2017
% Modified          :: 
%
% Evaluates a comparison between gps and image derives distance travelled

clear all

% set the path to saved or partial data products
dataPath = 'data/';

% set the indictor for the data run to process
[imgPath rngFndrPath gpsPath dataSetID] = getImgPath;


% load in the raw sequential image processed data
fname = ['seq_image_rslt_' dataSetID '.mat'];
load([dataPath fname]);

% s = input('apply a calibration shift? (y/n): ','s');
% if s == 'y'
%     disp 'applying clalibration shift'
%     calshift = 1.1;
% else
%     disp 'using standard calibration'
%     calshift = 1;
% end

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

% convert to caibrated measure of translation (m)
deltPosPix = rslt(:,2:3);
deltPosMeters = compShift(deltPosPix,imageTime,rngTime,rng);
optTime = imageTime(:,2);   % time at the end of the measured translation, time converted to seconds

%for now, ignore the component of motion perpendicular to camera long axis
%(long axis should be roughly parallel to axis of car
optDl = deltPosMeters(:,1);

% % compute accumulated distance travelled
% totalDy = zeros(size(vehDy));
% for j = 2:length(vehDy)
%     totalDy(j) = totalDy(j-1) + vehDy(j-1);
% end

% load the gps data
[gpsSpd, gpsPos, insAtt] = readGpsImu_span(dataSetID,gpsPath);
gpsTime = gpsPos(:,1)';


% select a start point
% sp = 110;
% t0 = gps_xyz(sp,1);
% x0 = gps_xyz(sp,2);
% y0 = gps_xyz(sp,3);
% z0 = gps_xyz(sp,4);

% reference position to start point
% gps_xyz(:,1) = gps_xyz(:,1) - gps_xyz(sp,1);
% gps_xyz(:,2) = gps_xyz(:,2) - gps_xyz(sp,2);
% gps_xyz(:,3) = gps_xyz(:,3) - gps_xyz(sp,3);
% gps_xyz(:,4) = gps_xyz(:,4) - gps_xyz(sp,4);

% reference yaw time to start point
% yaw(:,1) = yaw(:,1) - yaw(sp,1);

% convert gps data to horizontal position in meters + altitude
[gpsX gpsY gpsZ] = latlon2xyz(gpsPos);
    

% compute the gps translations in x an y vs time
gpsDx = diff(gpsX);
gpsDy = diff(gpsY);
gpsTm = gpsTime(2:end);     % time at end of translation
gpsDl = sqrt(gpsDx.^2 + gpsDy.^2);  % compute horizontal translation


% vx = dx./dpt;
% vy = dy./dpt;
% vz = dz./dpt;
% V = sqrt(vx.^2 +vy.^2 + vz.^2);
% Tv = gps_xyz(2:end,1) + dpt;

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


%L = length(
figure(3), clf, hold on;
plot(gpsTm,gpsDl)
plot(gpsTm,optIntDl,'r')
xlim([0 258])

% compute the optical error in vehicle shift compared to the gps vehicle
% shift, this neglects pitch angle and turning effect
optErr = mean(optIntDl - gpsDl, 'omitnan' );

fprintf('optical error, mean = %0.4f\n',optErr)
% 
% % trim gps data to match image data time
% p1 = 80;
% p2 = 671;
% gps_xyz = gps_xyz(p1:p2,:);
% Tv = Tv(p1:p2);
% V = V(p1:p2);
% dx = dx(p1:p2);
% dy = dy(p1:p2);
% dz = dz(p1:p2);
% 
% % plot both image and gps speed data
% figure(1), clf, hold on
% plot(imgTime,vehSpd,'b-')
% plot(Tv,V,'g')
% ylabel('Vehicle Speed (m/s)');
% xlabel('Image Number')
% title(fname, 'Interpreter', 'none' ) 
% 
% 
% % compute gps translation for each point
% vehTrnsltGps = sqrt(dx.^2 + dy.^2 +dz.^2);
% 
% % compute accumulated distance travelled by gps
% totalGpsTrnslt = zeros(size(vehTrnsltGps));
% for j = 2:length(vehTrnsltGps)
%     totalGpsTrnslt(j) = totalGpsTrnslt(j-1) + vehTrnsltGps(j-1);
% end
% 
% % % plot position data
% % figure(1), clf, hold on
% % plot(pos(:,2),pos(:,3),'.')
% % plot(pos(sp,2),pos(sp,3),'r.')
% % xlabel('position x, (m)')
% % xlabel('position y, (m)')
% 
% % % plot heading data
% % figure(2), clf, hold on
% % plot(yaw(:,1),yaw(:,2),'.')
% % plot(yaw(sp,1),yaw(sp,2),'r.')
% % xlabel('time (s)');
% % ylabel('heading (deg CWN)')
% 
% % % plot image translation data
% % figure(2), clf, hold on
% % plot(imgTime,totalDy,'b-')
% % ylabel('Distance Traveled (m)');
% % xlabel('Image Number')
% % title(fname, 'Interpreter', 'none' ) 
% 
% % % plot gps translation data
% % figure(3), clf, hold on;
% % plot(Tv,totalGpsDy)
% % xlabel('time (sec)')
% % ylabel('Distance Traveled (m)');
% 
% 
% % plot both image and gps translation data
% figure(2), clf, hold on
% plot(imgTime,totalDy,'b-')
% plot(Tv,totalGpsTrnslt,'g')
% ylabel('Distance Traveled (m)');
% xlabel('Image Number')
% title(fname, 'Interpreter', 'none' ) 
% 
% % examine a selected straight section using gps start and end points as
% % check for gps total distance traveled
% % plot position data
% %**************************** there is a problem here ******************
% % position in these coordinates is 3d, x,y is not a projection on a 2d
% % plane of flat earth
% % figure(3), clf, hold on
% % plot(gps_xyz(:,2),gps_xyz(:,3),'.')
% % plot(gps_xyz(sp,2),gps_xyz(sp,3),'r.')  % overplot the start point (red dot)
% % xlabel('position x (m)')
% % ylabel('position y (m)')
% 
% % overplot a straight segment of the route in green
% t1 = 80.0548;
% t2 = 101.079;
% idx_gps = find(gps_xyz(:,1) > t1 & gps_xyz(:,1) < t2);
% gpsPos = gps_xyz(idx_gps,:);
% % plot(gpsPos(:,2),gpsPos(:,3),'g.')
% 
% 
% dx = diff(gpsPos(:,2));
% dy = diff(gpsPos(:,3));
% dz = diff(gpsPos(:,4));
% vehGpsTrnslt = sqrt(dx.^2 + dy.^2 + dz.^2);  
% % % deltGpsTime = diff(gpsPos(:,1));  % time between points
% 
% % vx = dx./deltGpsTime;
% % vy = dy./deltGpsTime;
% % V = sqrt(vx.^2 +vy.^2);
% gpsTime = gpsPos(:,1);
% 
% % compute accumulated distance travelled
% totalGpsTrnslt = zeros(size(gpsTime));
% for j = 2:length(gpsTime)
%     totalGpsTrnslt(j) = totalGpsTrnslt(j-1) + vehGpsTrnslt(j-1);
% end
% 
% % compute total distance by GPS start and end points
% dx = gpsPos(end,2) - gpsPos(1,2);
% dy = gpsPos(end,3) - gpsPos(1,3);
% dz = gpsPos(end,4) - gpsPos(1,4);
% GpsTrnslt = sqrt(dx^2 + dy^2 + dz^2);
% 
% 
% % compute accumulated distance travelled by image processing
% idx_img = find(imgTime > t1 & imgTime < t2);
% imgDy = vehDy(idx_img);
% imgTimeSeg = imgTime(idx_img);
% 
% totalDy = zeros(size(imgDy));
% for j = 2:length(imgDy)
%     totalDy(j) = totalDy(j-1) + imgDy(j-1);
% end
% 
% imgTrnslt = totalDy(end);
% 
% % plot both image and gps speed data
% figure(5), clf, hold on
% plot(imgTimeSeg,totalDy,'b-')
% plot(gpsTime,totalGpsTrnslt,'g')
% ylabel('Distance Traveled (m)');
% xlabel('Time After Start (sec)')
% title(fname, 'Interpreter', 'none' ) 
% 
% fprintf('comparing translation for a straight section of road\n')
% fprintf('by gps accumulated difference, D = %0.3f\n',totalGpsTrnslt(end));
% fprintf('by gps difference between start and end points, D = %0.3f\n',GpsTrnslt);
% fprintf('by image accumulated difference, D = %0.3f\n',totalDy(end));
% 
% % repeat the comparison for the second pass over the same roadway
% % figure(3)
% % overplot a straight segment of the route
% t1 = 308.079;
% t2 = 331.08;
% idx_gps = find(gps_xyz(:,1) > t1 & gps_xyz(:,1) < t2);
% gpsPos = gps_xyz(idx_gps,:);
% %plot(gpsPos(:,2),gpsPos(:,3),'c*')
% 
% dx = diff(gpsPos(:,2));
% dy = diff(gpsPos(:,3));
% dz = diff(gpsPos(:,4));
% vehGpsTrnslt = sqrt(dx.^2 + dy.^2 + dz.^2);  
% gpsTime = gpsPos(:,1);
% 
% % compute accumulated distance travelled
% totalGpsTrnslt = zeros(size(gpsTime));
% for j = 2:length(gpsTime)
%     totalGpsTrnslt(j) = totalGpsTrnslt(j-1) + vehGpsTrnslt(j-1);
% end
% 
% % compute total distance by GPS start and end points
% dx = gpsPos(end,2) - gpsPos(1,2);
% dy = gpsPos(end,3) - gpsPos(1,3);
% dz = gpsPos(end,4) - gpsPos(1,4);
% GpsTrnslt = sqrt(dx^2 + dy^2 + dz.^2);
% 
% % compute accumulated distance travelled by image processing
% idx_img = find(imgTime > t1 & imgTime < t2);
% imgDy = vehDy(idx_img);
% imgTimeSeg = imgTime(idx_img);
% 
% totalDy = zeros(size(imgDy));
% for j = 2:length(imgDy)
%     totalDy(j) = totalDy(j-1) + imgDy(j-1);
% end
% 
% imgTrnslt = totalDy(end);
% 
% % plot both image and gps speed data for the segment
% figure(5), clf, hold on
% plot(imgTimeSeg,totalDy,'b-')
% plot(gpsTime,totalGpsTrnslt,'g')
% ylabel('Distance Traveled (m)');
% xlabel('Time After Start (sec)')
% title(fname, 'Interpreter', 'none' ) 
% 
% fprintf('comparing translation for a straight section of road\n')
% fprintf('by gps accumulated difference, D = %0.3f\n',totalGpsTrnslt(end));
% fprintf('by gps difference between start and end points, D = %0.3f\n',GpsTrnslt);
% fprintf('by image accumulated difference, D = %0.3f\n\n\n',totalDy(end));
