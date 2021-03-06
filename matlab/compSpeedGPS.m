% script to compare image processed vehicle speed data with gps

clear all

% load in the raw sequential image processed data
dataPath = 'data/';
fname = 'seq_image_rslt_05-Feb-2018.mat';
load([dataPath fname]);

% load in saved, gap filled image processed data 
% see: proc_seq_image.m
% see: plot_seqImage_rslt.m
gapFillName = [dataPath 'gapFill_',fname];
load(gapFillName,'vehSpd', 'vehDy');

% set time step and image number arrays
timeStep = 10/1562;     % colelcted 1562 images per 10 sec
imgNum = rslt(:,1)' - 1;
imgTime = imgNum*timeStep;

% load the gps data
gpsFile = 'cartest12_14_10_11_58';
[yaw, pos] = readGpsImu_stream([dataPath gpsFile]);

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
pos(:,4) = pos(:,4) - pos(166,4);

% reference yaw time to start time
yaw(:,1) = yaw(:,1) - yaw(166,1);

dx = diff(pos(:,2));
dy = diff(pos(:,3));
dz = diff(pos(:,4));
dpt = diff(pos(:,1));


vx = dx./dpt;
vy = dy./dpt;
vz = dz./dpt;
V = sqrt(vx.^2 +vy.^2 + vz.^2);
Tv = pos(2:end,1) + dpt;

% try to sync up the results by shifting the image time variable
tshift = -85;

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

% plot gps speed data
figure(1), clf, hold on;
plot(Tv,V)
xlabel('time (sec)')
ylabel('speed (m/s)')

% plot image speed data
figure(2), clf, hold on
plot(imgTime,vehSpd,'b-')
ylabel('Vehicle Speed (m/s)');
xlabel('Image Number')
title(fname, 'Interpreter', 'none' ) 

% plot both image and gps speed data
figure(3), clf, hold on
plot(imgTime+tshift,vehSpd,'b-')
plot(Tv,V,'g')

ylabel('Vehicle Speed (m/s)');
xlabel('Image Number')
title(fname, 'Interpreter', 'none' ) 
