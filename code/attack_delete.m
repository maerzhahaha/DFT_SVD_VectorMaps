%-----------���ɾ�㹥��-----------%
clear all;
close all;
clc;
%-----------���ñ�������-----------%
rand('state',1);
deletefactor=0.80;
%-----------����ɾ��ǿ���ַ���-----------%
% deletefactorstr='90'

%-----------��ȡʸ����ͼ-----------%
[originshpfilename, cover_pthname] = ...
    uigetfile('*.shp', 'ѡ��Ƕ��ˮӡ�������');
if (originshpfilename ~= 0)
    originshpfile = strcat(cover_pthname, originshpfilename);
    originshpfile = shaperead(originshpfile);
else
    return;
end
%----------�����µ�ʸ����ͼ����----------%
newshp = originshpfile;
ids={};
totalvalue=[];
%----------ͳ��ʸ����ͼ����ĸ���---------%
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
        if flag(cluster)==0 %��ɾ��
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