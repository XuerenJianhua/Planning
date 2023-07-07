%遗传算法
function [bestChrom,bestFitness,Path_length_variation] = GA_2(A,G,number,item_max,mutation_probability)
B = A; % 复制原方阵
index_1 = find(A~=0);
B(~eye(size(A,1))) = inf; % 将非对角线元素设为 inf
B(index_1) = A(index_1);
d = B;
n = size(d,1); % 节点数
maxDist = max(max(d)); % 最大距离，替换邻接矩阵中的 0

% 遗传算法参数设置
popSize = ceil(n*number); % 个体数目，必须为偶数
chromLength = n-1; % 染色体长度
crossoverProb = 0.7; % 交叉概率
mutateProb = mutation_probability; % 变异概率
maxGenerations = item_max; % 最大遗传代数
bestChrom=[];%记录最佳路径
Path_length_variation=[inf];%记录路径长度
% 初始化种群
pop = zeros(popSize, chromLength);
for i = 1:popSize
    temp_data = randperm(n-1,randi(chromLength));%随机生成一组数据
    pop(i,:) = padarray(temp_data, [0, n-size(temp_data,2)-1], 0, 'post'); 
end
[path, ~] = shortestpath(G, 1, n);
pop(1,:)=padarray(path, [0, n-size(path,2)-1], 0, 'post'); 

% 遗传算法迭代
bestFitness = inf;
for gen = 1:maxGenerations
    % 评估种群适应度
    fitness = zeros(popSize, 1);
    for i = 1:popSize
        chrom = [1, pop(i,:), n];
        dist = 0;
        for j = 1:n
            if(chrom(j+1)==0)
               break; 
            end    
            if d(chrom(j), chrom(j+1)) == inf
                dist = inf;
                break;
            else
                dist = dist + d(chrom(j), chrom(j+1));
            end
        end
        fitness(i) = dist;
    end
    
    % 选择操作
    [sortedFitness, index] = sort(fitness);
    parents = pop(index(1:popSize),:);
    
    % 交叉操作
    newPop = zeros(popSize, chromLength);
    for i = 1:2:popSize
        c1 = parents(i,:);
        c2 = parents(i+1,:);
        if rand <= crossoverProb
            % 选取随机交叉点
            crossPoint = randi(chromLength-1);
            % 交叉操作
            newPop(i,:) = [c1(1:crossPoint), c2(crossPoint+1:end)];
            newPop(i+1,:) = [c2(1:crossPoint), c1(crossPoint+1:end)];
        else
            newPop(i,:) = c1;
            newPop(i+1,:) = c2;
        end
    end
    
    % 变异操作
    for i = 1:popSize
        if rand <= mutateProb
            % 选取随机变异点
            mutatePoint = randi(chromLength);
            % 变异操作
            newPop(i,mutatePoint) = randperm(n-1, 1);
        end
    end
    
    % 更新种群
    pop = newPop;
    
    % 记录最优解
    if sortedFitness(1) < bestFitness
        bestFitness = sortedFitness(1);
        bestChrom = [1, parents(1,:), n];%记录最佳路径
    end
    Path_length_variation = [Path_length_variation,bestFitness];
    % 输出结果
%      fprintf('Generation %d: shortest distance = %f\n', gen, bestFitness);
end


if size(bestChrom)>0
    bestChrom = unique(bestChrom);
    bestChrom = bestChrom(1,2:end);
    % 输出最优路径
%     fprintf('Shortest path: ');
%     for i = 1:size(bestChrom,2)
%         fprintf('%d ', bestChrom(i));
%     end
else
    fprintf('未找到可行路径！ \n');
end
    
end