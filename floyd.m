% 找到最短路径,同时返回所有可行路径的最短路径
%注意：单独一条边的路径也不一定是最佳路径
function [path,dist] = floyd(A)
    %A为邻接矩阵
    index = A==0;
    A(index) = inf;
    dist = A;
    [n, ~] = size(dist);
%     path = cell(n);
    path = cell(n, n); % 修改此处，创建 n×n 的路径矩阵
    % 初始化路径矩阵
    for i = 1:n
        for j = 1:n
            if dist(i, j) ~= Inf
                path{i, j} = [i, j];
            end
        end
    end
    % 动态规划求解最小路径
    for k = 1:n
        for i = 1:n
            for j = 1:n
                if dist(i, k) + dist(k, j) < dist(i, j)
                    dist(i, j) = dist(i, k) + dist(k, j);
                    path{i, j} = [path{i, k}, path{k, j}(2:end)];
                end
            end
        end
    end
end


% function D=floyd(A,start,terminal)%此函数可以找到最短路径
% index = A==0;
% A(index) = inf;
% D = A;
% n = size(A, 1);
% for k = 1:n
%     for i = 1:n
%         for j = 1:n
%             if D(i,j) > D(i,k) + D(k,j)
%                 D(i,j) = D(i,k) + D(k,j);
%             end
%         end
%     end
% end
% end