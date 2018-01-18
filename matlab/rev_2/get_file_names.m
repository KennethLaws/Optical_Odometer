% read in a list of folder names containing the image data files
% select consecutive image files to return.  Set falg when done

function [p, fnames, flag] = get_file_names(imgPath,step)

    
persistent fileNum;
persistent fileNames;
persistent nFiles;


% on first call to this function, get a list of folders or files to process
if isempty(fileNum)
    fileNum = 1; 
    flist = dir([imgPath '*.*']);
    % extract a cell array of logicals (1 if is directory)
    dirset = {flist.isdir};
    % convert this to an array of logicals
    dirset = cell2mat(dirset);
    % use this to get all folder names
    foldNames = {flist(dirset).name};

    % if there are only two folders ( '.' and '..') then all image files are
    % located in this path
    if size(foldNames,2) == 2
        fileNames = {flist(~dirset).name};
        nFiles = length(fileNames);
    end
    % to handle multiple folders, more work needed here
end

if nargin > 1
    fileNum = step;
end


if nFiles == fileNum
    flag = 1;
    f1 = [];
    f2 = [];
    p = [];
    fnames = [];
else
    p = imgPath;
    f1 = strcat(p, fileNames(fileNum));
    f2 = strcat(p, fileNames(fileNum + 1));
    fnames = [f1 f2];
    flag = 0;
    fileNum = fileNum + 1;
end


return