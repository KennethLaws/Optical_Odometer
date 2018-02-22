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

% compute the change in heading
delta_theta = 10*(dyPx2 - dyPx1*.978)./delta_r;

% compute the accumulated heading
accHeading = zeros(size(delta_theta));
for j = 2:length(delta_theta)
    accHeading(j) = accHeading(j-1) + delta_theta(j);
end