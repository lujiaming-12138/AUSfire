%% 微信公众号：数学模型（MATHmodels）
%  联系方式：mathmodels@outlook.com


%  该数据下载地址：http://www.bom.gov.au/web03/ncc/www/awap/ndvi/ndviave
%                     /month/grid/history/nat/2010120120101231.Z
aus = load('2010120120101231');
[m,n] = size(aus);

% 根据 aus 生成森林
S = 2*((rand(m,n)<sqrt(aus)) & (aus<1));
S(aus>1) = -1;

Plight = 1e-6;    % 闪电概率
Pgrowth = 0;      % 生长概率

% 邻居方位 d 和点燃概率 p
d = {[1,0], [0,1], [-1,0], [0,-1], [1,1], [-1,1], [-1,-1], [1,-1]};
p = [ones(1,4), ones(1,4)*(sqrt(1/2)-1/2)];
% % 考虑风的情况
% d = {[1,0], [0,1], [-1,0], [0,-1], [1,1], [-1,1], [-1,-1], [1,-1], [0,-2]};
% p = [ 0.80,  0.30,   0.80,   1.00,  0.12,   0.12,    0.30,   0.30,    0.8]; 

% 非=-1, 空=0, 火=1, 树=2；“非”表示非澳大利亚的部分或水域
U = -1; E = 0; F = 1; T = 2; 
isE = (S==E); isF = (S==F); isT = (S==T); isU = (S==U);

R = isF+ isU; G = isT + isU; B = isU;

imh = image([112,154],[-44,-10], flipud(cat(3,R,G,B)));

hold on
load coastlines
plot(coastlon, coastlat, 'b', 'linewidth',2); 
axis image
axis([112 154 -44 -10])

for t = 1:300

    % 计算邻居中能传播着火的个数
    sum = zeros(size(S));
    for j = 1:length(d)
        sum = sum + p(j) * (circshift(S,d{j})==F);
    end
    
    % 分别找出四种状态的元胞
    isE = (S==E); isF = (S==F); isT = (S==T); isU = (S==U);
    
    % 找出满足着火条件的元胞
    ignite = rand(m,n)<sum | (rand(m,n)<Plight);  
    
    % 规则 1: 着火
    Rule1 = T*(isT & ~ignite) + F*(isT & ignite);
    % 规则 2: 烧尽
    Rule2 = F*isF - F*isF;
    % 规则 3: 新生
    Rule3 = T*(isE & rand(m,n)<Pgrowth);
    % 规则 4: “非”不变
    Rule4 = U*isU;
    
    S = Rule1 + Rule2 + Rule3 + Rule4;
    
    R = isF + R-0.02.*(R>0&R<=1); R(R<0)=0; G = isT + isU;
    set(imh, 'cdata', flipud(cat(3, R+isU, G, B)) )
    drawnow
end
