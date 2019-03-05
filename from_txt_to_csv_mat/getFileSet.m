function names = getFileSet(path,imgType)
% Scan a directory for videos
%   NAMES = GETIMAGESET(PATH) scans PATH for AVI, WMV, MP4, and MPG files,
%   and returns their path into NAMES.

% Author: Andrea Vedaldi

content = dir(path);
names = {content.name};
ok = regexpi(names, imgType, 'start');
names = names(~cellfun(@isempty,ok));
end