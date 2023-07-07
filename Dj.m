%Dj算法，还未测试
function [path,cost] = Dj(graph,startNode,endNode)
% 定义图的邻接矩阵，表示节点之间的连接关系和距离
% 这里使用一个简单的示例图
%  graph = [0 10 0 0;
%      10 0 5 15;
%      0 5 0 0;
%      0 15 0 0];
% 
% startNode = 1; % 起始节点
% endNode =4; % 目标节点
numNodes = size(graph, 1); % 节点数量

distances = inf(1, numNodes); % 到各节点的最短距离
distances(startNode) = 0; % 起始节点到自身的距离为0
visited = false(1, numNodes); % 是否已访问过节点

% 逐步计算最短路径
for i = 1:numNodes
    % 找到当前未访问节点中距离最小的节点
    current = -1;
    minDist = inf;
    for j = 1:numNodes
        if ~visited(j) && distances(j) < minDist
            current = j;
            minDist = distances(j);
        end
    end
    
    % 标记当前节点为已访问
    visited(current) = true;
    
    % 更新与当前节点相邻节点的最短距离
    for j = 1:numNodes
        if graph(current, j) > 0
            distance = distances(current) + graph(current, j);
            if distance < distances(j)
                distances(j) = distance;
            end
        end
    end
end

% 构建最短路径
path = [endNode];
currentNode = endNode;
while currentNode ~= startNode
    neighbors = find(graph(:, currentNode) > 0);
    [~, prevNode] = min(distances(neighbors));
    currentNode = neighbors(prevNode);
    path = [currentNode, path];
end
cost = distances(endNode);%最短距离
% % 输出结果
% disp('最短路径：');
% disp(path);
% disp('最短距离：');
% disp(distances(endNode));
end