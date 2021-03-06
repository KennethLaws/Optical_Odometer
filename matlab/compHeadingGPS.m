% script to compare image processed vehicle distance data with gps

clear all

% load in the raw sequential image processed data
dataPath = 'data/';
fname = 'seq_image2d_rslt_19-Feb-2018.mat';
load([dataPath fname]);

% s = input('apply a calibration shift? (y/n): ','s');
% if s == 'y'
%     disp 'applying clalibration shift'
%     calshift = 0.85;
% else
%     disp 'using standard calibration'
    calshift = 1;
% end

% temp fix until data are reprocessed with version of proc_seq_image_2d
% that saves this variable
if ~exist('delta_r')
    delta_r = 924;
end

% compute transformation between pixels and meters (calibration factor)
vehDy = rslt1(:,4)';        % vehicle translation (meters)
vehDyPx = rslt1(:,2)';      %vehicle translation (pixels)
calFact = vehDy./vehDyPx;        % should be constant for every point
calFact = mean(calFact,'omitnan');    % mean should be equal to the constant value

% load in saved, gap filled image processed data for each image side
% see: proc_seq_image.m
% see: plot_seqImage_rslt.m
gapFillName = [dataPath 'gapFillS1_',fname];
load(gapFillName,'vehSpd', 'vehDy');
vehSpd1 = vehSpd;
gapFillName = [dataPath 'gapFillS2_',fname];
load(gapFillName,'vehSpd', 'vehDy');
vehSpd2 = vehSpd;

% set time step and image number arrays
timeStep = 10/1562;     % collected 1562 images per 10 sec
imgNum = rslt1(:,1)' - 1;
imgTime = imgNum*timeStep;

% apply extra calibration shift
vehDy = calshift*vehDy;

% load the gps data
gpsFile = 'cartest12_14_10_11_58';
[yaw, pos] = readGpsImu_stream([dataPath gpsFile]);


% there are problems with this data, remove points that are between gps
% samples
dpt = diff(pos(:,1));  % difference in time between gps points
idx = find(dpt > 0.3);
pos = pos(idx,:);

% select a start point
sp = 110;
t0 = pos(sp,1);
x0 = pos(sp,2);
y0 = pos(sp,3);

% reference position to start point
pos(:,1) = pos(:,1) - t0;
pos(:,2) = pos(:,2) - x0;
pos(:,3) = pos(:,3) - y0;

% reference yaw time to start point
yawTime = yaw(:,1);
yawAngle = yaw(:,2);
yawTime = yawTime - t0;

dx = diff(pos(:,2));
dy = diff(pos(:,3));
gpsTime = pos(:,1);
dpt = diff(gpsTime);

vx = dx./dpt;
vy = dy./dpt;
V = sqrt(vx.^2 +vy.^2);
Tv = pos(2:end,1) + dpt;



% shift to align image time with gps time results
tshift = -27.93;
tshift = -29.5;
imgTime = imgTime+tshift;

% trim gps data to match image data time
p1 = 80;
p2 = 671;
pos = pos(p1:p2,:);
Tv = Tv(p1:p2);
V = V(p1:p2);
dx = dx(p1:p2);
dy = dy(p1:p2);

% plot both image and gps speed data
figure(1), clf, hold on
plot(imgTime,vehSpd,'b-')
plot(Tv,V,'g')
ylabel('Vehicle Speed (m/s)');
xlabel('Image Number')
title(fname, 'Interpreter', 'none' ) 
xlim([-30 140])

% compute the heading and heading shift
[deltHead, heading] = heading_shift(vehSpd1,vehSpd2,timeStep,calFact,delta_r);

figure(2), clf
plot(imgTime,deltHead)

figure(3), clf, hold on
plot(imgTime,-heading+185,'b')
plot(yawTime,yawAngle,'g')
xlabel('Image Time (sec)')
ylabel('Heading Change From Initial (deg)')
xlim([-30 140])


% % compute gps translation for each point
% vehDyGps = sqrt(dx.^2 + dy.^2);

% % compute accumulated distance travelled by gps
% totalGpsDy = zeros(size(vehDyGps));
% for j = 2:length(vehDyGps)
%     totalGpsDy(j) = totalGpsDy(j-1) + vehDyGps(j-1);
% end

% % plot position data
% figure(1), clf, hold on
% plot(pos(:,2),pos(:,3),'.')
% plot(pos(sp,2),pos(sp,3),'r.')
% xlabel('position x, (m)')
% xlabel('position y, (m)')

% % plot heading data
% figure(2), clf, hold on
% plot(yaw(:,1),yaw(:,2),'.')
% plot(yaw(sp,1),yaw(sp,2),'r.')
% xlabel('time (s)');
% ylabel('heading (deg CWN)')

% % plot image translation data
% figure(2), clf, hold on
% plot(imgTime,totalDy,'b-')
% ylabel('Distance Traveled (m)');
% xlabel('Image Number')
% title(fname, 'Interpreter', 'none' ) 

% % plot gps translation data
% figure(3), clf, hold on;
% plot(Tv,totalGpsDy)
% xlabel('time (sec)')
% ylabel('Distance Traveled (m)');


% % plot both image and gps translation data
% figure(2), clf, hold on
% plot(imgTime,totalDy,'b-')
% plot(Tv,totalGpsDy,'g')
% ylabel('Distance Traveled (m)');
% xlabel('Image Number')
% title(fname, 'Interpreter', 'none' ) 

% % examine a selected straight section using gps start and end points as
% % check for gps total distance traveled
% % plot position data
% figure(3), clf, hold on
% plot(pos(:,2),pos(:,3),'.')
% plot(pos(sp,2),pos(sp,3),'r.')  % overplot the start point (red dot)
% xlabel('position x (m)')
% ylabel('position y (m)')

% % overplot a straight segment of the route in green
% t1 = 80.0548;
% t2 = 101.079;
% idx_gps = find(pos(:,1) > t1 & pos(:,1) < t2);
% gpsPos = pos(idx_gps,:);
% plot(gpsPos(:,2),gpsPos(:,3),'g.')


% dx = diff(gpsPos(:,2));
% dy = diff(gpsPos(:,3));
% vehGpsTrnslt = sqrt(dx.^2 + dy.^2);  
% % deltGpsTime = diff(gpsPos(:,1));  % time between points

% vx = dx./deltGpsTime;
% vy = dy./deltGpsTime;
% V = sqrt(vx.^2 +vy.^2);
% gpsTime = gpsPos(:,1);

% % compute accumulated distance travelled
% totalGpsTrnslt = zeros(size(gpsTime));
% for j = 2:length(gpsTime)
%     totalGpsTrnslt(j) = totalGpsTrnslt(j-1) + vehGpsTrnslt(j-1);
% end

% % compute total distance by GPS start and end points
% dx = gpsPos(end,2) - gpsPos(1,2);
% dy = gpsPos(end,3) - gpsPos(1,3);
% GpsTrnslt = sqrt(dx^2 + dy^2);


% % compute accumulated distance travelled by image processing
% idx_img = find(imgTime > t1 & imgTime < t2);
% imgDy = vehDy(idx_img);
% imgTimeSeg = imgTime(idx_img);
% 
% totalDy = zeros(size(imgDy));
% for j = 2:length(imgDy)
%     totalDy(j) = totalDy(j-1) + imgDy(j-1);
% end

% imgTrnslt = totalDy(end);

% plot both image and gps speed data
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
% figure(3)
% % overplot a straight segment of the route
% t1 = 308.079;
% t2 = 331.08;
% idx_gps = find(pos(:,1) > t1 & pos(:,1) < t2);
% gpsPos = pos(idx_gps,:);
% plot(gpsPos(:,2),gpsPos(:,3),'c*')
% 
% dx = diff(gpsPos(:,2));
% dy = diff(gpsPos(:,3));
% vehGpsTrnslt = sqrt(dx.^2 + dy.^2);  
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
% GpsTrnslt = sqrt(dx^2 + dy^2);
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
% fprintf('by image accumulated difference, D = %0.3f\n',totalDy(end));
