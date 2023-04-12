clear all;
close all;
clc;

noisestrength=0.01;
noisestrengthstr='001';

[originshpfilename, cover_pthname] = ...
    uigetfile('*.shp', 'select embeded map');
if (originshpfilename ~= 0)
    originshpfile = strcat(cover_pthname, originshpfilename);
    originshpfile = shaperead(originshpfile);
else
    return;
end

newshp = originshpfile;
ids={};
totalvalue=[];
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


deletefactor=0.80
ocount=length(totalvalue);
flag=rand(1,ocount)>deletefactor;
noise=-noisestrength+(2*noisestrength)*rand(1,sum(flag));
cluster=1;
noisecluster=1
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
        if flag(cluster)==0 %no noise
            xarray2=[xarray2,xarray(j)];
            yarray2=[yarray2,yarray(j)];
        end
        if flag(cluster)==1 %add noise
            xarray_noise=xarray(j)+noise(noisecluster);
            yarray_noise=yarray(j)+noise(noisecluster);
            xarray2=[xarray2,xarray_noise];
            yarray2=[yarray2,yarray_noise];
            noisecluster=noisecluster+1;
        end
        cluster=cluster+1;
    end
       newshp(i).X=xarray2;
       newshp(i).Y=yarray2;
       if(length(xarray2)==0)
           newshp(i).X=xarray;
           newshp(i).Y=yarray;
       end

end
name = strcat('attacked/noise/noise_',noisestrengthstr);
name = strcat(name,originshpfilename);
shapewrite(newshp,name );