% function to estimate the distance between two points in the image frame
% using numerical integration and function obtained from calibration data

function sum = dpix2dcm(px1,px2)
C1 = -5.672e-03;
C0 = 7.604e+01;
FC = 840;

p = [C1 C0];
% numerically integrate this function to obtain distance
sum = 0;
for px = px1:px2
    x = abs(px-FC);
    sum = sum + 1/polyval(p,x);
end