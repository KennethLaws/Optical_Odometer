%
% Read and parse the GPS/IMU file
clear all;

if exist('/Volumes/M2Ext/Test_Drive_1214/GPS_IMU/')
    imgPath = '/Volumes/M2Ext/Test_Drive_1214/GPS_IMU/';
elseif exist('/media/earthmine/M2Ext/Test_Drive_1214/GPS_IMU/')
    imgPath = '/media/earthmine/M2Ext/Test_Drive_1214/GPS_IMU/';
else
    error('Image folder not found, update image path in script');
end

gpsFile = strcat(imgPath,'cartest12_14_10_11_58.csv');

[yaw, pos] = readGpsImu(gpsFile);

% convert change in x and y and t with yaw to velocity

% select a start point
sp = 166;
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
dpt = diff(pos(:,1));

vx = dx./dpt;
vy = dy./dpt;
V = sqrt(vx.^2 +vy.^2);
Tv = pos(2:end,1) + dpt;


% plot data
figure(1), clf, hold on
plot(pos(:,2),pos(:,3),'.')
plot(pos(sp,2),pos(sp,3),'r.')
xlabel('position x, (m)')
xlabel('position y, (m)')

figure(2), clf, hold on
plot(yaw(:,1),yaw(:,2),'.')
plot(yaw(sp,1),yaw(sp,2),'r.')
xlabel('time (s)');
ylabel('heading (deg CWN)')

figure(3), clf, hold on;
plot(Tv,V)
xlabel('time (sec)')
ylabel('speed (m/s)')

