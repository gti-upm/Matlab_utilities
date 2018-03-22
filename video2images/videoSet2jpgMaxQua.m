function [] = videoSet2jpgMaxQua(path)
% Convert a set of video files to sequences of image files. 
% The folder with the video files should only containing the video files.
% New folders are created in the location of the video files with the same name. 
% 
% Inputs:
%  -path: string containing the path with the video files.

% Select files in folder.
listDir = dir(path);
listDir = listDir(~[listDir.isdir]);
parfor i = 1:length(listDir)
    try
        video2jpgMaxQua([path, '/', listDir(i).name])
    catch ME
        ME.message
        warning('Found file that cannot be converted. Possibly a not video file: %s', [path, '/', listDir(i).name]);
    end

end
