function [delta_theta, accHeading] = heading_shift(vehSpd1,vehSpd2,timeStep,calFact,delta_r)
% given two shifts from right and left portions of the image frame,
% determine the change in vehicle heading angle
% 
% Autors: Kenneth Laws
%         Here Technologies
%
% Date:   02/20/2018

% convert speeds back to distance
dy1 = vehSpd1*timeStep;
dy2 = vehSpd2*timeStep;

% transform back to pixels
dyPx1 = dy1/calFact;
dyPx2 = dy2/calFact;

% apply an arbitrary correction factor
dyPx1 = dyPx1*.977;
%dyPx1 = dyPx1;

% compute the difference in pixel shift
deltPix = dyPx2 - dyPx1;

% ignore shifts that are less than 2 pixels
deltPix(abs(deltPix)<2.5) = 0;

% compute the change in heading in radians
delta_theta = deltPix./delta_r;

% convert to degrees
delta_theta = delta_theta * 180/pi;

% apply an arbitrary correction factor
delta_theta = 0.2*delta_theta;

% compute the accumulated heading
accHeading = zeros(size(delta_theta));
for j = 2:length(delta_theta)
    accHeading(j) = accHeading(j-1) + delta_theta(j);
end