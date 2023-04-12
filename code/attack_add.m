%------------------随机增点攻击---------------%
clc;
clear;
%------------------设置增点比例---------------%
addRatio=0.15;
addratiostr='15';
%先读取嵌入水印后的数据
[originshpfilename, cover_pthname] = ...
    uigetfile('*.shp', '选择嵌入水印后的数据');
if (originshpfilename ~= 0)
    watermarkedshp = strcat(cover_pthname, originshpfilename);
    watermarkedshp = shaperead(watermarkedshp);
else
    return;
end

%随机增点的攻击策略：
newshp=watermarkedshp;
for i=1:length(watermarkedshp)
    xarray = watermarkedshp(i).X;
    yarray =  watermarkedshp(i).Y;
    xnotnanindex=find(~isnan(xarray));
    ynotnanindex=find(~isnan(yarray));
    xarray=xarray(xnotnanindex);
    yarray=yarray(ynotnanindex);
    
    xarraynew=[xarray(1)];
    yarraynew=[yarray(1)];
    
    %增加顶点
    for (j=2:length(xarray)) 
        rd1= rand;
        rd2= rand;
        if(rd1<addRatio)
            xarraynew=[xarraynew 0.5*(xarray(j-1)+xarray(j))];
            yarraynew=[yarraynew 0.5*(yarray(j-1)+yarray(j))];
        end
            xarraynew=[xarraynew xarray(j)];
            yarraynew=[yarraynew yarray(j)];
    end
    newshp(i).X = [xarraynew nan];
    newshp(i).Y =  [yarraynew nan];
end

%------------------输出随机增点后的结果---------------%
name = strcat('attacked/add/',addratiostr);
name = strcat(name,originshpfilename);
shapewrite(newshp,name );