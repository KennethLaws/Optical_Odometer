% evaluate frame calibration

% location in the frame from 0 to 1920
frame_loc =  [1852 1752 1650 1552 1452 1351 1249 1150 1052 953  853 755 ...
    653  554 453 352 251 151];

% measured resolution pixels per inch
frame_res = [70.5 70.5  71   71  72.5  73.5 74  74.5 75.0 75.5 75.5 75.1 ...
    75.1 74.1 74.1 73.5 73.5 72.5];
fc = 840
fdc = abs(frame_loc - fc);

% fit an analytic function to the measured resolution c(x)
p = polyfit(fdc,frame_res,1);
fitVals = polyval(p,0:950);

% numerically integrate this function to obtain distance
sum = 0;
for px = px1:px2
    x = abs(px-fc);
    sum = sum + 1/polyval(p,x);
end

figure(1), clf, hold on;
plot(fdc, frame_res,'*')
plot(0:950,fitVals)
xlabel('Distance from frame maximum (pixels)')
ylabel('Image resolution (pixels/inch)')

txt = {};    
txt{1} = sprintf('c1 = %0.3e, c0 = %0.3e',p);
txt{2} = sprintf('Frame Maximum = %d',fc);

text(600,76.5,txt)