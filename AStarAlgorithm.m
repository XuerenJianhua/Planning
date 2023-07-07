function [shortestPath,cost] = AStarAlgorithm(graph, startNode, goalNode)
    %输入
    %graph：邻接矩阵
    %startNode, goalNode：起点与终点索引
    %输出
    %shortestPath：最短路径
    
    % 获取图的节点数量
    numNodes = size(graph, 1);
    all_point_length=size(graph,1);
    max_item=1000;%最大迭代次数
     % 初始化起始节点和目标节点的启发式函数值和代价函数值
    hScores = zeros(numNodes, 1);
    gScores = Inf(numNodes, 1);
    % 初始化起始节点的代价函数值为0
    gScores(startNode) = 0;
    % 初始化起始节点到目标节点的启发式函数值
    hScores(startNode) = heuristicFunction(all_point_length,startNode, goalNode);
    
    % 初始化起始节点的父节点
    parentNodes = zeros(numNodes, 1);
    
    % 创建开放集合和关闭集合
    openSet = startNode;
    closedSet = [];
    item=0;
    %_______________________________开始循环___________________________
    while item<=max_item
        item=item+1;
        
        % 选择启发式函数值加代价函数值最小的节点作为当前节点
        [~, index] = min(hScores(openSet) + gScores(openSet));
        currentNode=openSet(index);
%         fprintf('%d  %d\n',item,currentNode);
        % 如果当前节点是目标节点，结束算法
        if currentNode == goalNode 
            shortestPath = getPath(parentNodes, goalNode);
            cost = gScores(currentNode);
            return;
        end
        
        %将当前节点从开放集合中移除
%         openSet = setdiff(openSet, currentNode);
%         openSet = openSet(openSet ~= currentNode);
        neighborNodes= find(graph(currentNode, :) > 0);
        for i = 1:length(neighborNodes)
            neighborNode = neighborNodes(i);
           % 如果邻居节点已在关闭集合中，跳过
            if ismember(neighborNode, closedSet)
%                 openSet = openSet(openSet ~= neighborNode);
                continue;
            end
            
            % 计算从起始节点经过当前节点到邻居节点的代价
           tentativeGScore = gScores(currentNode)+  graph(currentNode, neighborNode);

            % 如果邻居节点在开放集合中且新的代价更小
            if ~ismember(neighborNode, openSet) || tentativeGScore < gScores(neighborNode)
                % 更新邻居节点的父节点和代价函数值
                parentNodes(neighborNode) = currentNode;
                gScores(neighborNode) = tentativeGScore;

                % 更新邻居节点的启发式函数值
                hScores(neighborNode) = heuristicFunction(all_point_length ,neighborNode, goalNode);
                 % 如果邻居节点不在开放集合中，加入开放集合
                 if ~ismember(neighborNode, openSet)
                     openSet = [openSet; neighborNode];
                 end
            end

        end
        %删除当前节点
        openSet = openSet(openSet ~= currentNode);
        % 将当前节点加入关闭集合
        if ~ismember(currentNode, closedSet)
        closedSet = [closedSet; currentNode];
        end
        
      
    end
  
    % 如果无法找到最短路径，返回空
    shortestPath = [];
    
end

function heuristicValue = heuristicFunction(all_point_length,node, goalNode)
     %索引转化为坐标，方便计算距离
     [row_node, col_node] = ind2sub(all_point_length, node);
     [row_goalNode, col_goalNode] = ind2sub(all_point_length, goalNode);
    % 计算节点和目标节点之间的启发式函数值（例如欧氏距离）
    heuristicValue = sqrt((row_goalNode-row_node)^2+(col_goalNode-col_node)^2);
%      heuristicValue = sqrt((node-goalNode)^2);

end

function path = getPath(parentNodes, goalNode)
    % 获取最短路径
    path = [];
    currentNode = goalNode;
    
    while currentNode~= 0
    path = [currentNode; path];
    currentNode = parentNodes(currentNode);
    end
      
end
