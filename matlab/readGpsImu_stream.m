
function [yaw, gps_xyz] = readGpsImu_stream(gpsFile)
% Reads data file generated by gpsImu phone ap
% returns the gps position in cartesian coordinates (reference
% unknown)(meters)
% and the yaw angle (degrees) probably relative to true north, positive
% clockwise

% the file format has the following keys to the data
%   1:  ['gps', 'lat', 'lon', 'alt'],     # deg, deg, meters MSL WGS84
%   3:  ['accel', 'x', 'y', 'z'],         # m/s/s
%   4:  ['gyro', 'x', 'y', 'z'],          # rad/s
%   5:  ['mag', 'x', 'y', 'z'],           # microTesla
%   6:  ['gpscart', 'x', 'y', 'z'],       # (Cartesian XYZ) meters
%   7:  ['gpsv', 'x', 'y', 'z'],          # m/s
%   8:  ['gpstime', ''],                  # ms
%   81: ['orientation', 'x', 'y', 'z'],   # degrees
%   82: ['lin_acc',     'x', 'y', 'z'],
%   83: ['gravity',     'x', 'y', 'z'],   # m/s/s
%   84: ['rotation',    'x', 'y', 'z'],   # radians
%   85: ['pressure',    ''],              # ???
%   86: ['battemp', ''],                  # centigrade

if ~exist([gpsFile, '_GPS.mat']);

    if exist('/Volumes/M2Ext/Test_Drive_1214/GPS_IMU/')
        imgPath = '/Volumes/M2Ext/Test_Drive_1214/GPS_IMU/';
    elseif exist('/media/earthmine/M2Ext/Test_Drive_1214/GPS_IMU/')
        imgPath = '/media/earthmine/M2Ext/Test_Drive_1214/GPS_IMU/';
    else
        error('Image folder not found, update image path in script');
    end
    
    % load in the data
    data = csvread([imgPath gpsFile '.csv']);
    
    % find the gps time tags in column 18, discard this data and shift over
    % so that these single data value entries are removed.  Need to keep the
    % colums that contain tags lined up
    idx = find(data(:,18)==8);
    data(idx,18:33) = data(idx,20:35);
    data(idx,34:35) = 0;
    
    idx = find(data(:,22)==8);
    data(idx,22:33) = data(idx,24:35);
    data(idx,34:35) = 0;
    
    idx = find(data(:,26)==8);
    data(idx,26:33) = data(idx,28:35);
    data(idx,34:35) = 0;
    
    % -----------------------------------------------------------
    % parse the data to form arrays of
    % gps lat, lon
    % gps x,y,z
    % angles a,b,c
    % gps velocity x,y,z
    
    % gps lat, lon, altitude
    % put time, lat, lon in the array
    idx = find(data(:,2) == 1);
    gps = [data(idx,1), data(idx,3:4)];
    
    % gps orientation x,y,z angles
    % put attitude into an array, time, x,y,z
    idx = find(data(:,6) == 81);
    angles = [data(idx,1), data(idx,7:9)];
    
    % gps orientation x,y,z angles
    % put attitude into an array, time, x,y,z
    idx = find(data(:,10) == 81);
    tmp = [data(idx,1), data(idx,11:13)];
    angles = [angles; tmp];
    
    % gps cartesian cooridnates
    % put gps position into an array, time,x,y,z
    idx = find(data(:,10) == 6);
    tmp = [data(idx,1), data(idx,11:13)];
    gps_xyz = [tmp];
    
    % gps orientation x,y,z angles
    idx = find(data(:,14) == 81);
    tmp = [data(idx,1), data(idx,15:17)];
    angles = [angles; tmp];
    
    % gps cartesian cooridnates
    % put gps position into an array, time,x,y,z
    idx = find(data(:,14) == 6);
    tmp = [data(idx,1), data(idx,15:17)];
    gps_xyz = [gps_xyz; tmp];
    
    % gps speed (m/s)
    idx = find(data(:,14) == 7);
    gpsv = [data(idx,1), data(idx,15:17)];
    
    % gps speed (m/s)
    idx = find(data(:,18) == 7);
    tmp = [data(idx,1), data(idx,15:17)];
    gpsv = [gpsv; tmp];
    
    % gps cartesian cooridnates (m)
    % put gps position into an array, time,x,y,z
    idx = find(data(:,18) == 6);
    tmp = [data(idx,1), data(idx,19:21)];
    gps_xyz = [gps_xyz; tmp];
    
    % gps orientation x,y,z angles
    idx = find(data(:,18) == 81);
    tmp = [data(idx,1), data(idx,19:21)];
    angles = [angles; tmp];
    
    % gps speed (m/s)
    idx = find(data(:,22) == 7);
    tmp = [data(idx,1), data(idx,23:25)];
    gpsv = [gpsv; tmp];
    
    % gps orientation x,y,z angles
    idx = find(data(:,22) == 81);
    tmp = [data(idx,1), data(idx,23:25)];
    angles = [angles; tmp];
    
    % gps orientation x,y,z angles
    idx = find(data(:,26) == 81);
    tmp = [data(idx,1), data(idx,27:29)];
    angles = [angles; tmp];
    
    yaw = angles(:,[1 2]);  % keep just the heading and the time
    gps_xyz(:,1:3);   % keep just x,y, time
    
    [b,I] = sort(yaw(:,1));  % sort the heading by time
    yaw = yaw(I,:);
    
    [b,I] = sort(gps_xyz(:,1));  % sort the cartesion position by time
    gps_xyz = gps_xyz(I,:);
    
    save([gpsFile, '_GPS.mat'], 'gps_xyz', 'yaw');
else
    fprintf([' Loading saved gps file: ' gpsFile, '_GPS.mat from disk\n']);
    load([gpsFile, '_GPS.mat']);
end
