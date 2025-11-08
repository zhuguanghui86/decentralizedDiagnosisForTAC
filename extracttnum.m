function tnum = extracttnum(t)
% EXTRACTTNUM 从类似 t12 的变迁中解析出数字 12
%               传入的参数形式只能是: t+数字
%   See also strrep, str2double
tnum = str2double(strrep(t,'t',''));