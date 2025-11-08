function v = t2vector(t, n)
% T2VECTOR 函数作用通过下例说明：如果传入 (t2,4)，则输出 [0,1,0,0]'(列向量)
%           如果传入 (t3,5)，则输出 [0,0,1,0,0]'(列向量);
%           如果不按上述格式传入参数结果未知;
%   See also strrep, str2double
v = zeros(n,1);
tnum = str2double(strrep(t,'t',''));
v(tnum) = 1;
