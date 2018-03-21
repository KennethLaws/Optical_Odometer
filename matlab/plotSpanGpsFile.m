%
% Read and parse the GPS/IMU file
clear all;

% load the gps data
%gpsFile = 'cartest12_14_10_11_58';
gpsPath = '../SpanCPT/';
gpsFile = 'span6_test3.txt';

[bestVel,bestPos,bestAtt] = readGpsImu_span(gpsPath,gpsFile);

% gps position data
gpsPosTime = bestPos(:,1);
gpsLat = bestPos(:,2);
gpsLon = bestPos(:,3);
gpdHght = bestPos(:,4);

% gps velocity data
% {velTime,velLatency,hSpd,headng,vSpd}
gpsVelTime = bestVel(:,1);
gpshSpd = bestVel(:,3);
gpshdng = bestVel(:,4);
gpsvSpd = bestVel(:,5);

% ins attitude
% {insTime,roll,pitch,azmth}
insTime = bestAtt(:,1);
insRoll = bestAtt(:,2);
insPitch = bestAtt(:,3);
insAzmth = bestAtt(:,4);

% plot lat lon position
figure(1), clf, hold on
plot(gpsLon,gpsLat,'.')
xlabel('position lon (m)')
ylabel('position lat (m)')


% plot velocity
figure(2), clf, hold on
plot(gpsVelTime,gpshdng,'bl')
xlabel('time (s)');
ylabel('heading (deg CWN)')

figure(3), clf, hold on;
plot(gpsVelTime,gpshSpd)
xlabel('time (sec)')
ylabel('speed (m/s)')

%plot ins attitude
figure(4), clf, hold on;
plot(insTime, insPitch,'r')
plot(insTime, insRoll,'g')
figure(5)
plot(insTime, insAzmth,'b')

