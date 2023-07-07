function show_path(data,path,color_flag)
start_point=data(:,2:3);%记录起点坐标
end_point=data(:,4:5);%记录终点坐标
%color_flag 改变绘制的颜色
hold on;
for i = 1:size(start_point, 1)
    x = [start_point(i, 1), end_point(i, 1)];
    y = [start_point(i, 2), end_point(i, 2)];
    %在图中显示坐标id
%     text(start_point(i, 1),start_point(i, 2),num2str(i),'color','k');
    plot(x, y, 'b-o'); % 使用蓝色圆形标记连线
end
if color_flag ~=0
for i = 1:size(path, 1)-1
    x = [path(i, 1), path(i+1, 1)];
    y = [path(i, 2), path(i+1, 2)];
    if color_flag==1
     plot(x, y, 'r-o'); % 使用红色
    end
    if color_flag==2
     plot(x, y, 'm-o'); % 使用粉色
    end
    if color_flag==3
     plot(x, y, 'k-o'); % 使用黑色
    end
    if color_flag==4
     plot(x, y, 'g-o'); % 使用绿色
    end
    if color_flag==5
     plot(x, y, 'y-+'); % 使用黄色
    end
end
end
% 设置坐标轴范围和标签
xlabel('X轴');
ylabel('Y轴');
% 添加标题和图例
title('路径规划结果');
legend('收费站');


end