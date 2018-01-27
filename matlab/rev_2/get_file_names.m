% read in a list of folder names containing the image data files
% select consecutive image files to return.  Set flag when done

function [imgFold, fnames, doneflag] = get_file_names(imgPath)

    
persistent fileNum;
persistent fileNames;
persistent nFiles;
persistent foldNames;
persistent nFolders;
persistent foldNum;
persistent subFold;
persistent nSubfolders;

if nargin >1
    fileNum = step;
end

% if folder names is not populated, get a list of folders to process
if isempty(foldNames)
    flist = dir(imgPath);
    % extract a cell array of logicals (1 if is directory)
    dirset = {flist.isdir};
    % convert this to an array of logicals
    dirset = cell2mat(dirset);
    % use this to get all folder names
    foldNames = {flist(dirset).name};
    nFolders = size(foldNames,2);
    foldNum = 3;    % skip the first two folders ('.' and '..')
end

if nFolders == 2    %
    % there are only two folders ( '.' and '..')
    % located in this path, attempt to process all image files
    if isempty(fileNum)
        % file list not set, set file list
        fileNum = 1;
        fileNames = {flist(~dirset).name};
        nFiles = length(fileNames);
    end
    
    if nFiles == fileNum
        % list image in list, need two to process so done
        doneflag = 1;
        imgFold = [];
        fnames = [];
    else
           % set file name for next two images to process
        imgFold = [imgPath subFold '/'];
        f1 = strcat(imgFold, fileNames(fileNum));
        f2 = strcat(imgFold, fileNames(fileNum + 1));
        fnames = [f1 f2];
        doneflag = 0;
        fileNum = fileNum + 1;
    end
else
    % multiple folders found in path
    %if foldNum <= nFolders
    subFold = foldNames{foldNum};
    imgFold = [imgPath subFold '/'];
    % first time through, get file listing
    if isempty(fileNum)            
        flist = dir(imgFold);
        dirset = {flist.isdir};
        % convert this to an array of logicals
        dirset = cell2mat(dirset);
        % use this to get all folder names
        subfoldNames = {flist(dirset).name};
        nSubfolders = size(subfoldNames,2);
        if nSubfolders > 2
            error('Selected image path has subfolders, select new image path'); 
        end
        fileNum = 1;
        fileNames = {flist(~dirset).name};
        nFiles = length(fileNames);
    end

    % check for last file in subfolder
    if nFiles == fileNum    
        % reached end of subfolder
        % get the last file from this subfolder
        f1 = strcat(imgFold, fileNames(fileNum));
        % get listing from next subfolder
        if foldNum < nFolders
            foldNum = foldNum + 1;
            subFold = foldNames{foldNum};
            imgFold = [imgPath subFold '/'];
            flist = dir(imgFold);
            dirset = {flist.isdir};
            % convert this to an array of logicals
            dirset = cell2mat(dirset);
            % use this to get all folder names
            subfoldNames = {flist(dirset).name};
            nSubfolders = size(subfoldNames,2);
            if nSubfolders > 2
                error('Selected image path has subfolders, select new image path'); 
            end
            % set the return variables
            fileNum = 1;
            fileNames = {flist(~dirset).name};
            nFiles = length(fileNames);                
            f2 = strcat(imgFold, fileNames(fileNum));
            fnames = [f1 f2];
            doneflag = 0;
            fileNum = 1;
        else
            % no more folders to process - done
            doneflag = 1;
            fnames = [];  
        end
    else
        % still files left to process in this subfolder
        f1 = strcat(imgFold, fileNames(fileNum));
        f2 = strcat(imgFold, fileNames(fileNum + 1));
        fnames = [f1 f2];
        doneflag = 0;
        fileNum = fileNum + 1;
    end
%     else
%         doneflag = 1;
%         f1 = [];
%         f2 = [];
%         imgFold = [];
%         fnames = [];
%     end    
    
%     if nFiles == fileNum
%         flag = 1;
%         f1 = [];
%         f2 = [];
%         imgFold = [];
%         fnames = [];
%     else
%         imgFold = imgPath;
%         f1 = strcat(p, fileNames(fileNum));
%         f2 = strcat(p, fileNames(fileNum + 1));
%         fnames = [f1 f2];
%         flag = 0;
%         fileNum = fileNum + 1;
%     end
    
end
    
return