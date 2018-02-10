%
% Read and parse the GPS/IMU file
clear all;

% load the gps data
gpsFile = 'cartest12_14_10_11_58';
[yaw, pos] = readGpsImu(gpsFile);

% there are problems with this data, remove points that are between gps
% samples
dpt = diff(pos(:,1));
idx = find(dpt > 0.3);
pos = pos(idx,:);
yaw = yaw(idx,:);

% select a start point
sp = 110;
t0 = pos(sp,1);
x0 = pos(sp,2);
y0 = pos(sp,3);

% reference position to start point
pos(:,1) = pos(:,1) - pos(sp,1);
pos(:,2) = pos(:,2) - pos(sp,2);
pos(:,3) = pos(:,3) - pos(sp,3);

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
xlabel('position x (m)')
ylabel('position y (m)')

% overplot a straight segment of the route in green
t1 = 80;
t2 = t1 + 21;
idx_pos = find(pos(:,1) > t1 & pos(:,1) < t2);
plot(pos(idx_pos,2),pos(idx_pos,3),'g.')


figure(2), clf, hold on
plot(yaw(:,1),yaw(:,2),'.')
plot(yaw(sp,1),yaw(sp,2),'r.')
xlabel('time (s)');
ylabel('heading (deg CWN)')

figure(3), clf, hold on;
plot(Tv,V)
xlabel('time (sec)')
ylabel('speed (m/s)')

