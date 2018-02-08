% script to compare image processed vehicle distance data with gps

clear all

% load in the raw sequential image processed data
fname = 'seq_image_rslt_05-Feb-2018.mat';
load(fname);

% load in saved, gap filled image processed data 
% see: proc_seq_image.m
% see: plot_seqImage_rslt.m
gapFillName = ['gapFill_',fname];
load(gapFillName,'vehSpd', 'vehDy');

% set time step and image number arrays
timeStep = 10/1562;     % colelcted 1562 images per 10 sec
imgNum = rslt(:,1)' - 1;
imgTime = imgNum*timeStep;

% compute accumulated distance travelled
totalDy = zeros(size(vehDy));
for j = 2:length(vehDy)
    totalDy(j) = totalDy(j-1) + vehDy(j-1);
end

% load the gps data
if exist('/Volumes/M2Ext/Test_Drive_1214/GPS_IMU/')
    imgPath = '/Volumes/M2Ext/Test_Drive_1214/GPS_IMU/';
elseif exist('/media/earthmine/M2Ext/Test_Drive_1214/GPS_IMU/')
    imgPath = '/media/earthmine/M2Ext/Test_Drive_1214/GPS_IMU/';
else
    error('Image folder not found, update image path in script');
end

gpsFile = strcat(imgPath,'cartest12_14_10_11_58.csv');

[yaw, pos] = readGpsImu(gpsFile);

% there are problems with this data, remove points that are between gps
% samples
dpt = diff(pos(:,1));
idx = find(dpt > 0.3);
pos = pos(idx,:);
yaw = yaw(idx,:);


% convert change in x and y and t with yaw to velocity

% select a start point
sp = 110;
t0 = pos(sp,1);
x0 = pos(sp,2);
y0 = pos(sp,3);

% reference position to start point
pos(:,1) = pos(:,1) - pos(166,1);
pos(:,2) = pos(:,2) - pos(166,2);
pos(:,3) = pos(:,3) - pos(166,3);

% reference yaw time to start time
yaw(:,1) = yaw(:,1) - yaw(166,1);

dx = diff(pos(:,2));
dy = diff(pos(:,3));
vehDyGps = sqrt(dx.^2 + dy.^2);  % use same convention as image (dy is || vehicle axis)
deltGpsTime = diff(pos(:,1));  % time between points

vx = dx./deltGpsTime;
vy = dy./deltGpsTime;
V = sqrt(vx.^2 +vy.^2);
Tv = pos(2:end,1) + deltGpsTime;

% compute accumulated distance travelled
totalGpsDy = zeros(size(vehDyGps));
for j = 2:length(vehDyGps)
    totalGpsDy(j) = totalGpsDy(j-1) + vehDyGps(j-1);
end

% try to sync up the results by shifting the image time variable
tshift = -85;
imgTime = imgTime+tshift;

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

% plot image translation data
figure(2), clf, hold on
plot(imgTime,totalDy,'b-')
ylabel('Distance Traveled (m)');
xlabel('Image Number')
title(fname, 'Interpreter', 'none' ) 

% plot gps translation data
figure(1), clf, hold on;
plot(Tv,totalGpsDy)
xlabel('time (sec)')
ylabel('Distance Traveled (m)');


% plot both image and gps speed data
figure(3), clf, hold on
plot(imgTime,totalDy,'b-')
plot(Tv,totalGpsDy,'g')
ylabel('Distance Traveled (m)');
xlabel('Image Number')
title(fname, 'Interpreter', 'none' ) 

% examine a selected straight section using gps start and end points as
% check for gps total distance traveled

t1 = 80;
t2 = t1 + 21;
idx_gps = find(pos(:,1) > t1 & pos(:,1) < t2);
gpsPos = pos(idx_gps,:);


dx = diff(gpsPos(:,2));
dy = diff(gpsPos(:,3));
vehDyGps = sqrt(dx.^2 + dy.^2);  % use same convention as image (dy is || vehicle axis)
deltGpsTime = diff(gpsPos(:,1));  % time between points

vx = dx./deltGpsTime;
vy = dy./deltGpsTime;
V = sqrt(vx.^2 +vy.^2);
Tv = gpsPos(2:end,1) + deltGpsTime;

% compute accumulated distance travelled
totalGpsDy = zeros(size(vehDyGps));
for j = 2:length(vehDyGps)
    totalGpsDy(j) = totalGpsDy(j-1) + vehDyGps(j-1);
end

% compute total distance by start and end points



% compute accumulated distance travelled
totalGpsDy = zeros(size(vehDyGps));
for j = 2:length(vehDyGps)
    totalGpsDy(j) = totalGpsDy(j-1) + vehDyGps(j-1);
end
gpsTime = Tv(idx_gps);

idx_img = find(imgTime > t1 & imgTime < t2);
imgDy = vehDy(idx_img);
imgTime = imgTime(idx_img);

% compute accumulated distance travelled
totalDy = zeros(size(imgDy));
for j = 2:length(imgDy)
    totalDy(j) = totalDy(j-1) + imgDy(j-1);
end

% plot both image and gps speed data
figure(4), clf, hold on
plot(imgTime,totalDy,'b-')
plot(gpsTime,totalGpsDy,'g')
ylabel('Distance Traveled (m)');
xlabel('Image Number')
title(fname, 'Interpreter', 'none' ) 





