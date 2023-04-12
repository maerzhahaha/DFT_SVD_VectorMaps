
clc;
clear;

[originshpfilename, cover_pthname] = ...
    uigetfile('*.shp', 'Select the shp file');
if (originshpfilename ~= 0)
    originshpfile = strcat(cover_pthname, originshpfilename);
    originshpfile = shaperead(originshpfile);
else
    return;
end

charug= 0.00005;
oCount=0;
sCount=0;
simplifiedShp = originshpfile;

for i=1:length(originshpfile)
    xyvalues=[];
    xarray = originshpfile(i).X;
    yarray =  originshpfile(i).Y;
    xnotnanindex=find(~isnan(xarray));
    ynotnanindex=find(~isnan(yarray));
    xarray=xarray(xnotnanindex)';
    yarray=yarray(ynotnanindex)';
    xys=[xarray  yarray];

    [pts ids]=Douglas(xys,charug);
    ids=ids';
    
    oCount=oCount+length(yarray);
    sCount=sCount+length(ids);
    
    simplifiedShp(i).X=xarray(ids);
    simplifiedShp(i).Y=yarray(ids);
end

deletefactorstr=1-sCount/oCount
name = strcat('attacked/simplify/simplify_',num2str(deletefactorstr));
name = strcat(name,originshpfilename);
shapewrite(simplifiedShp,name );
