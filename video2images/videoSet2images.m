function [] = videoSet2images(path, imageExt)
% Convert a set of video files to sequences of image files. 
% The folder with the video files should only containing the video files.
% New folders are created in the location of the video files with the same name. 
% 
% Inputs:
%  -path: string containing the path with the video files.
%  -imageExt: string containing the image extension of the output sequence
%  of images.

% Select files in folder.
listDir = dir(path);
listDir = listDir(~[listDir.isdir]);
for i = 1:length(listDir)
    try
        video2images([path, '/', listDir(i).name], imageExt)
         fprintf(1,'%s%s',[path, '/', listDir(i).name], imageExt);
    catch
        warning('Found file that cannot be converted. Possibly a not video file');
    end

end
