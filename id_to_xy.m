%将节点号转化为其二维坐标
function data = id_to_xy(path,uniqueValues)
%输入
%path：路径规划结果的节点序号
%uniqueValues：节点坐标及其对应的id
%返回
% data：节点坐标
    data=[];
    for i = 1:size(path,1)
        for j = 1:size(uniqueValues,1)
           if path(i) == uniqueValues(j,3)
               data=[data;uniqueValues(j,1),uniqueValues(j,2)];
           end       
        end      
    end%for


end