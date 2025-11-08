function v = sigma2vector(sigma,n)
% SIGMA2VECTOR v = sigma2vector(sigma,n)
%       传入一个触发字符串 sigma，获得各变迁触发次数并以向量返回，
%       示例如下：sigma2vector('t2t1t2t3',4) 计算结果为 [1,2,1,0]' (列向量)
%   输入参数：
%       sigma 字符串，如 't2t1t2t3'形式，其它形式结果未知;
%       n |T| 的值，即集合T中的元素数
%   输出参数:
%       如 [1,2,1,0]'形式 (列向量)
%   See also strfind, length
v = zeros(n,1); %列向量
C = strsplit(sigma, 't');
len = length(C);
for i=2:len % 第1个为 '' 字符串，从第二个开始才是数字
    index = str2double(C{i});
    v(index) = v(index) + 1;
end