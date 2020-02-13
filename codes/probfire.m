%% 微信公众号：数学模型（MATHmodels）
%  联系方式：mathmodels@outlook.com

m = 10;               % 森林尺寸 nxn
Rho = 0.1:0.01:1;     % “树”元胞密度
n = zeros(size(Rho)); % 贯穿次数
N = 10000;            % 测试次数
 
for k = 1:length(Rho)
    rho = Rho(k)
    for i = 1:N
        S = zeros(m);
        S(randperm(m^2,round(m^2*rho))) = 1;
        
        A = bwlabel(S,4); % 标记所有四连通域
        
        % 查看首尾两列是否具有相同通域的元胞
        B = A(:,1); C = A(:,end); 
        if ~isempty(intersect(B(B>0),C(C>0)))
           n(k) = n(k)+1;
        end
    end
end

plot(Rho, n/N)