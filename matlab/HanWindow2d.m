
function P = HanWindow2d(M)
% apply a 2 dimensional Han window to the data in the matrix M
% M must be 2 dim

% get the size of M
[a b] = size(M);

% generate the cosine scaling arrays
x = (1 - cos(2*(0:(b-1))*pi/(b)))/2;
y = (1 - cos(2*(0:(a-1))*pi/(a)))/2;

% compile these into 2 matrices with repeated rows (columns)
[X,Y] = meshgrid(x,y);

% form the 2d scaling matrix and apply it to the input M
P = (X.*Y).*M;
return;
