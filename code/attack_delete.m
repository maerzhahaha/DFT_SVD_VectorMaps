%-----------随机删点攻击-----------%
clear all;
close all;
clc;
%-----------设置保留比例-----------%
rand('state',1);
deletefactor=0.80;
%-----------设置删除强度字符串-----------%
% deletefactorstr='90'

%-----------读取矢量地图-----------%
[originshpfilename, cover_pthname] = ...
    uigetfile('*.shp', '选择嵌入水印后的数据');
if (originshpfilename ~= 0)
    originshpfile = strcat(cover_pthname, originshpfilename);
    originshpfile = shaperead(originshpfile);
else
    return;
end
%----------设置新的矢量地图变量----------%
newshp = originshpfile;
ids={};
totalvalue=[];
%----------统计矢量地图顶点的个数---------%
for i=1:length(originshpfile)
    xyvalues=[];
    xarray = originshpfile(i).X;
    yarray =  originshpfile(i).Y;

    xnotnanindex=find(~isnan(xarray));
    ynotnanindex=find(~isnan(yarray));
    xarray=xarray(xnotnanindex);
    yarray=yarray(ynotnanindex);
    totalvalue=[totalvalue,xarray];
end


ocount=length(totalvalue);

flag=rand(1,ocount)>deletefactor;
finalCount=0;
cluster=1;
charug=100;
newshp=originshpfile;


for i=1:length(originshpfile)
    xyvalues=[];
    xarray = originshpfile(i).X;
    yarray =  originshpfile(i).Y;
    xnotnanindex=find(~isnan(xarray));
    ynotnanindex=find(~isnan(yarray));
    xarray=xarray(xnotnanindex);
    yarray=yarray(ynotnanindex);
    
    xarray2=[];
    yarray2=[];
    for(j=1:length(xarray))
        if flag(cluster)==0 %不删除
            xarray2=[xarray2,xarray(j)];
            yarray2=[yarray2,yarray(j)];
        end
        cluster=cluster+1;
    end
       newshp(i).X=xarray2;
       newshp(i).Y=yarray2;
 
       if(length(xarray2)==0)
           newshp(i).X=[xarray(1),xarray(end)];
           newshp(i).Y=[xarray(1),xarray(end)];
       end
       if(length(xarray2)~=length(yarray2))
           i
       end
       finalCount =finalCount+length(newshp(i).X);
end

name = strcat('attacked/delete/delete_', num2str( 100*(1-finalCount/ocount)));
name = strcat(name,originshpfilename);
shapewrite(newshp,name );