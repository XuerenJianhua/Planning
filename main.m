clc;clear;close all
%dj f A*  aco ga 
filename = 'road.xls';
%文件字段必须为：id x1 y1 x2 y2 length
[A,G,data,uniqueValues] = makemap(filename);
start = 1;%起点
terminal = size(A,1);%终点

%% 开始寻路
%% 利用Dj 计算指定的两个点之间的最短路径及距离
tic
profile on;
[dj_path, dj_distance] = shortestpath(G, start, terminal);
profile off;
dj_time = toc;
fprintf('Dj 历时：%0.3f 秒\n',dj_time); 
fprintf('Dj 距离：%d\n',dj_distance); 
% 获取内存消耗信息
m = memory;
% 提取内存消耗结果
totalMemory = m.MemUsedMATLAB;%单位为字节 1MB=1024KB=1024^2字节
% 输出内存消耗结果
fprintf('Dj 消耗内存：%f MB\n', totalMemory/(1024^3) );
fprintf('Dj 最短路径中包含节点数目：%d\n\n',size(dj_path,2));

%% floyd算法
tic
profile on;
[path,D] = floyd(A);
profile off;
Floyd_time = toc;
fprintf('Floyd 历时：%0.3f 秒\n',Floyd_time);
fprintf('Floyd 距离：%d\n',D(start,terminal)); 
m = memory;
% 提取内存消耗结果
totalMemory = m.MemUsedMATLAB;%单位为字节 1MB=1024KB=1024^2字节
% 输出内存消耗结果
fprintf('Floyd 消耗内存：%f MB\n', totalMemory/(1024^3) );
%获取起点与目标点之间的最短路径
Floyd_path = cell2mat(path(start,terminal));
fprintf('Floyd 最短路径中包含节点数目：%d\n\n',size(Floyd_path,2));

%% Astar
tic
profile on;
[Astar_path, Astar_cost]= AStarAlgorithm(A, start, terminal);
profile off;
Astar_time = toc;
m = memory;
% 提取内存消耗结果
totalMemory = m.MemUsedMATLAB;%单位为字节 1MB=1024KB=1024^2字节
fprintf('Astar 历时：%0.3f 秒\n',Astar_time);
fprintf('Astar 距离：%d\n',Astar_cost); 
fprintf('Astar 消耗内存：%f MB\n',totalMemory/(1024^3) );
fprintf('Astar 最短路径中包含节点数目：%d\n\n',size(Astar_path,1)); 

%% ACO
%参数：迭代次数 蚂蚁个数 alpha beta 信息素挥发程度
%186个节点参数：100 30 3 8 0.3
%879个节点参数：1000 50 3 8 0.4
max_item=100;%最大迭代次数
tic
profile on;
[ACO_paths] = ACO(A,G,start,terminal,max_item);
profile off;
ACO_time = toc;
m = memory;
%挑选最短路径，并绘制路径变化曲线图
ACO_Path_length_variation=[];
min_length = inf;
best_path=[];
for i = 1:length(ACO_paths)%ACO_paths的长度与迭代次数有关
    now_length = 0;
    now_path = ACO_paths{i}; 
    for j = 1:(length(now_path)-1)
        now_length = now_length+A(now_path(j),now_path(j+1));
    end
    if now_length <min_length
        min_length = now_length;
        best_path = now_path;
    end    
    ACO_Path_length_variation = [ACO_Path_length_variation;now_length];
end    
ACO_path = best_path;
ACO_cost=min_length;
totalMemory = m.MemUsedMATLAB;%单位为字节 1MB=1024KB=1024^2字节
fprintf('ACO 历时：%0.3f 秒\n',ACO_time);
fprintf('ACO 距离：%d\n',ACO_cost); 
fprintf('ACO 消耗内存：%f MB\n',totalMemory/(1024^3) );
fprintf('ACO 最短路径中包含节点数目：%d\n\n',length(ACO_path)); 

figure;
plot(ACO_Path_length_variation,'-o', 'LineWidth', 2, 'MarkerSize',2)
xlabel('迭代次数'); % 设置 X 轴标签
ylabel('路径长度'); % 设置 Y 轴标签
title('ACO路径长度变化曲线图'); % 设置图表标题
hold off

%% GA遗传算法
number=30;%控制种群大小,路网节点越多，此数值应该越大，但消耗的资源会越大
item_max=500;%最大迭代次数
mutation_probability=0.4;%变异概率
%189个节点的参数设置 30 500 0.4
%879个节点参数设置：20 50 0.2
tic
profile on;
[GA_path,GA_cost,GA_Path_length_variation] = GA_2(A,G,number,item_max,mutation_probability);
% [GA_path,GA_cost] = GA(A,G,number,item_max,mutation_probability);
profile off;
GA_time = toc;
m = memory;
fprintf('GA 历时：%0.3f 秒\n',GA_time);
fprintf('GA 距离：%d\n',GA_cost); 
fprintf('GA 消耗内存：%f MB\n',totalMemory/(1024^3) );
fprintf('GA 最短路径中包含节点数目：%d\n\n',length(GA_path)); 

figure;
plot(GA_Path_length_variation,'-o', 'LineWidth', 2, 'MarkerSize',2)
xlabel('迭代次数'); % 设置 X 轴标签
ylabel('路径长度'); % 设置 Y 轴标签
title('GA路径长度变化曲线图'); % 设置图表标题
hold off
%% 展示路径规划结果
%Dj
dj_data = id_to_xy(dj_path',uniqueValues);%id转化为坐标
figure
show_path(data,dj_data,1)%路径规划结果展示到图中
title(' Dj 路径规划结果');
hold off
%Floyd
Floyd_data = id_to_xy(Floyd_path',uniqueValues);%id转化为坐标
figure
show_path(data,Floyd_data,2)
title(' Floyd 路径规划结果');

hold off
%Astar
Astar_data = id_to_xy(Astar_path,uniqueValues);%id转化为坐标
figure
show_path(data,Astar_data,3)
title(' Astar 路径规划结果');
hold off
%ACO
ACO_data = id_to_xy(ACO_path',uniqueValues);%id转化为坐标
figure
show_path(data,ACO_data,4)
title(' ACO 路径规划结果');
hold off
%GA
GA_data = id_to_xy(GA_path',uniqueValues);%id转化为坐标
figure
show_path(data,GA_data,4)
title(' GA 路径规划结果');
hold off

%% 集中展示
figure
show_path(data,Astar_data,0)
h1=plot(dj_data(:,1), dj_data(:,2), 'r-*'); % dj使用红色星形
h2=plot(Floyd_data(:,1), Floyd_data(:,2), 'm-s'); % Floyd使用粉色方块
h3=plot(Astar_data(:,1), Astar_data(:,2), 'k-o'); % Astar使用黑色圆圈
h4=plot(ACO_data(:,1), ACO_data(:,2), 'g-^'); % Aco使用黑绿色三角形
h5=plot(GA_data(:,1), GA_data(:,2), 'y-'); % GA使用黑绿色三角形
legend([h1,h2,h3,h4,h5],'Dj','Floyd','Astar','ACO','GA')
hold off
     
     
     
     
     