function Route_best = ACO(A,G,start,terminal,max_item)
index_zeros = find(A == 0);
A(index_zeros) = inf;%将0转化为无穷大
begin = start; % 起点
ending= terminal; % 终点
iter_max=max_item;%最大迭代次数
n=size(A,1);%节点个数
m=30;%蚂蚁个数
ant = ones(1,m);%记录当前蚂蚁是否具有可行路径，为1表示无可行路径，为0表示有可行路径------？
Heu_F = 1./A; %距离的倒数矩阵
[path, ~] = shortestpath(G, 1, n);%引导路径
Tau=zeros(n,n); %信息素矩阵
index_1 = find(A~=0);
Tau(index_1) =1;
alpha=3;%信息素重要程度因子 要小于1 alpha与beta是越小越重要
beta=7;%启发式信息（距离）重要程度因子 要小于1
vol=0.3;%信息素挥发程度
Q=size(A,1)*10;%信息素增益常数，即已走过的路径对后续蚂蚁的影响大小
for i =1:length(path)-1
    Tau(path(i),path(i+1)) = 5;
end    
% Tau(path) = 10;%信息素矩阵初始化
% Route_best;%记录最短路径
%Table  %记录每只蚂蚁的路径
for iter = 1:iter_max    %迭代开始，用for不用再设置加一（原程序是while）
      
      % 构建解空间
      citys_index = 1:n;
      
      % 逐个蚂蚁选择
      for i = 1:m 
          route = begin;
          % 逐个城市路径选择
         for j = 2:n
             
             %table是路径记录表，每次j之前的城市都是被选择过的
             has_visited = route(1:(j-1));    % 已访问的城市集合(禁忌表)
             allow_index = ~ismember(citys_index,has_visited);    
             allow = citys_index(allow_index);  % 剩下待访问的城市集合
             c = size(allow,2);
             P = zeros(1,c);
             % 计算城市间转移概率
             for k = 1:length(allow)
                 P(k) = Tau(has_visited(end),allow(k))^alpha * Heu_F(has_visited(end),allow(k))^beta;
                 %Heu_F是距离的倒数矩阵，所以说越远概率就会越低
             end
             
             P = P/sum(P);%（参照转移概率公式，注意对于向量sum是全部元素求和，cumsum同样）
             if isnan(P(1))==1%P/sum(p)=nan,0/0=nan,P的所有元素为0，即P能到达的点已全部走过，该路径不可行
%                  disp('这只蚂蚁无法到达');%当前路径之后不一定有通路
                 ant(i) = 1;%标识符
                 break;
             else 
                 ant(i) = 0;
             end
                
             % 轮盘赌法选择下一个访问城市
                Pc = cumsum(P);     %累加函数，把前几个累加到1（即一个面积为1的轮盘，累计后的Pc数组两两相邻数字为对应节点的概率区间）
                target_index = find(Pc >= rand);%（rand模拟轮盘的指针，随机指向一个区域）
                target = allow(target_index(1));%(大于等于rand的第一个区间即为选中的节点)
                %这里和遗传算法不一样,没有采用二分法
                    route = [route target];
            if target == ending
                break;
            end%break只跳出一层for循环
         end
         if ant(i)==0
             Table{i} = route;
         else
             Table{i} = 1:n;%不可行路径，使其路径为周游所有点
         end
      end
           
%% 首先记录上一次迭代之后的最佳路线放在第一个位置(类似一个学习的效果)
    
    if iter>=2
      Table{1} = Route_best{iter-1};      
    end 
      %% 计算各个蚂蚁的路径距离
      Length = zeros(m,1);
      for i = 1:m
          Route = Table{i}; %取出一条路径
          
          %for循环累加后是第一个点———》最后一个点之间的距离
          for j = 1:(length(Route)-1)
              Length(i) = Length(i) + A(Route(j),Route(j + 1));
          end
      end
      
      %% 计算最短路径距离及平均距离(这是原程序的代码，感觉冗长。而且我们一般不把判断和选择放在一起)
      [min_Length,min_index] = min(Length);      %找到最短距离的值的大小和位置
      Length_best(iter,:)= min_Length;           %此次迭代的路线最小值记录
      Route_best{iter} = Table{min_index};   %此次迭代的路线最小值记录
      L1 = Length;
      L1(find(L1==inf)) = 0;%不可达蚂蚁的路径长不予考虑
      L2 = [];
      for h = 1:length(L1)
          if L1(h)~=0
              L2 = [L2 L1(h)];
          else
              continue;
          end
      end
      Length_ave(iter) = mean(L2);       %此次迭代的路线平均值记录
      
      %% 更新信息素
      Delta_Tau = zeros(n,n);
      % 逐个蚂蚁计算
      for i = 1:m
          if ant(i)==1%一只参考路径可行的蚂蚁
              route = Table{i};
              % 逐个路径上的城市计算
              for j = 1:(length(route)-1)
                  Delta_Tau(route(j),route(j+1)) = Delta_Tau(route(j),route(j+1)) + Q/Length(i);
                  %这里可以理解成每只蚂蚁带着等量Q的信息素，均匀撒在路线上
              end
          else
              continue;
          end
      end
      Tau = (1-vol)* Tau + Delta_Tau;   %信息素挥发一部分再加上增加的
%     Table = cell(1,m);  %清空路线表
    for k = 1:m
        Table{k} = [];
    end
end
% disp(Route_best(end))%最短路径
