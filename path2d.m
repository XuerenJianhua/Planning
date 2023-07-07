%% 函数功能：
%(1)读取arcmap数据，进行点合并，绘制路网图，保存处理后的数据
%(2)坐标编号，坐标关系转化为点关系，根据点关系得到邻接矩阵
%(3)根据邻接矩阵构造图
%data属性:fid id x1 y1 x2 y2 length

%% 返回值：
%A：邻接矩阵
%G：无向图
%data：原始数据的所有坐标
%uniqueValues:不重复的节点坐标及其对应的唯一id
%% 读取数据
%文件名
filename = 'road.xls';
% 指定要读取的文件名和工作表名
sheet = 1;  % 第一个工作表
% 使用xlsread函数读取数据  header为列名称
[data, header] = xlsread(filename, sheet);
data=data(:,2:7);%读取列
%data属性:id x1 y1 x2 y2 length
name_id = data(:,1);%记录id
start_point=data(:,2:3);%记录起点坐标x1 y1
end_point=data(:,4:5);%记录终点坐标x2 y2
length_list=data(:,6);%记录路径长度length

%% 处理数据：合并距离很近的点
distanceThreshold=3;%距离阈值，两点距离小于此阈值则合并两个点
numNodes = size(start_point, 1);
for  kk = 1:5%通过迭代，不断减少距离阈值
    distanceThreshold=distanceThreshold/2;
    Preprocessed_data=[];%记录要替换的数据
    for i = 1:numNodes
        for j = 1:numNodes
            if i ~= j
                distance1 = norm(start_point(i, :) - start_point(j, :));
                if distance1 <= distanceThreshold%两点距离过近
                    Preprocessed_data=[Preprocessed_data;start_point(i, :),start_point(j, :)];
                end
                distance2 = norm(end_point(i, :) - end_point(j, :));
                if distance2 <= distanceThreshold%两点距离过近
                    Preprocessed_data=[Preprocessed_data;end_point(i, :),end_point(j, :)];
                end
                distance3 = norm(start_point(i, :) - end_point(j, :));
                if distance3 <= distanceThreshold%两点距离过近
                    Preprocessed_data=[Preprocessed_data;start_point(i, :),end_point(j, :)];
                end
            end
        end
    end%for
    %根据记录处理原始数据
    for i = 1:size(data,1)
        for j = 1:size(Preprocessed_data,1)
            if data(i,2)==Preprocessed_data(j,1) && data(i,3)==Preprocessed_data(j,2)
                data(i,2)=Preprocessed_data(j,3);
                data(i,3)=Preprocessed_data(j,4);
            end    
            if data(i,4)==Preprocessed_data(j,1) && data(i,5)==Preprocessed_data(j,2)
                data(i,4)=Preprocessed_data(j,3);
                data(i,5)=Preprocessed_data(j,4);
            end    
        end    

    end%for    

   %重新读取数据
    name_id = data(:,1);%记录id
    start_point=data(:,2:3);%记录起点坐标
    end_point=data(:,4:5);%记录终点坐标
    length_list=data(:,6);%记录路径长度
end
% %重新计算路径长度
% data(:,6) = norm(data(:,2:3) - data(:, 4:5));
%% 绘制路网
figure(1);
hold on;
% 逐个连接起点和终点
for i = 1:size(start_point, 1)
    x = [start_point(i, 1), end_point(i, 1)];
    y = [start_point(i, 2), end_point(i, 2)];
    distance=sqrt((start_point(i, 1)-start_point(i, 2))^2+(end_point(i, 1)-end_point(i, 2))^2);
    if distance>0.1%两点距离过近则删除
        %  text(start_point(i, 1),start_point(i, 2),num2str(i),'color','r','FontSize', 12);%图上打上名称
        plot(x, y, 'b-o'); % 使用蓝色圆形标记连线
    end
end
% 设置坐标轴范围和标签
xlabel('X轴');
ylabel('Y轴');
% 添加标题和图例
title('路网');
legend('节点');
hold off;

%% 保存数据到表格
% 创建表格
T = array2table(data, 'VariableNames', {'Id', 'x1', 'y1','x2','y2','length'});
% 保存表格数据到 CSV 文件
filename = 'data.csv';
writetable(T, filename);

%% 二维数组去重值,计算剩余的节点数
uniqueValues = unique(data(:,2:3), 'rows');
node_length = size(uniqueValues,1);
fprintf('路网中包含节点的数目为：%d \n\n',node_length)

%% 给数据的坐标编号，使每个坐标具有唯一id
for i = 1:node_length
    uniqueValues(i,3)=i;
end    

%% 将data数据中的点的关系转化为id的关系
new_data = zeros(size(data,1),3);
for i = 1:size(data,1)
    for j = 1:size(uniqueValues,1)
         if data(i,2)==uniqueValues(j,1) && data(i,3)==uniqueValues(j,2)
             new_data(i,1)=uniqueValues(j,3);
         end
         if data(i,4)==uniqueValues(j,1) && data(i,5)==uniqueValues(j,2)
             new_data(i,2)=uniqueValues(j,3);
         end

    end
end
new_data(:,3)=data(:,6);%载入路径权值，即路径长度
save('data.mat', 'new_data');

%% 根据id的关系绘制邻接矩阵
edges=new_data(:,1:2);%载入边的关系
% 提取节点数量
numNodes = max(edges(:));
% 创建空的邻接矩阵
adjMatrix = zeros(numNodes);
% 根据边关系设置邻接矩阵
numEdges = size(edges, 1);
for i = 1:numEdges
    startNode = edges(i, 1);
    endNode = edges(i, 2);
    if startNode==0 ||endNode==0
       continue 
    end     
    adjMatrix(startNode, endNode) = new_data(i, 3);%记录权值
end
A = adjMatrix+adjMatrix';%转置得到对称阵
G = graph(A, 'upper', 'omitselfloops');%创建无向图 
figure(2);%开启画图
h = plot(G, 'EdgeLabel', G.Edges.Weight,'EdgeLabelColor','r');
layout(h, 'force');   % 使用强制布局算法进行节点布局

