
clc;
clear;

deleteRatio=0.30;
deletefactorstr='30';

[originshpfilename, cover_pthname] = ...
    uigetfile('*.shp', 'Select the shp file');
if (originshpfilename ~= 0)
    originshpfile = strcat(cover_pthname, originshpfilename);
    originshpfile = shaperead(originshpfile);
else
    return;
end

count = length(originshpfile);

reservedFs = rand(1,count)>deleteRatio;
indexs = find(reservedFs==1);
reservedFe = originshpfile(indexs);

name = strcat('attacked/deleteFeature/delete_',deletefactorstr);
name = strcat(name,originshpfilename);
shapewrite(reservedFe,name );
