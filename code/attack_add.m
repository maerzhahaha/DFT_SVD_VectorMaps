%------------------������㹥��---------------%
clc;
clear;
%------------------�����������---------------%
addRatio=0.15;
addratiostr='15';
%�ȶ�ȡǶ��ˮӡ�������
[originshpfilename, cover_pthname] = ...
    uigetfile('*.shp', 'ѡ��Ƕ��ˮӡ�������');
if (originshpfilename ~= 0)
    watermarkedshp = strcat(cover_pthname, originshpfilename);
    watermarkedshp = shaperead(watermarkedshp);
else
    return;
end

%�������Ĺ������ԣ�
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
    
    %���Ӷ���
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

%------------------�����������Ľ��---------------%
name = strcat('attacked/add/',addratiostr);
name = strcat(name,originshpfilename);
shapewrite(newshp,name );