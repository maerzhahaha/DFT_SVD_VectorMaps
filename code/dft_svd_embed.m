
clc;
clear;
close all;
[originshpfilename, cover_pthname] = ...
    uigetfile('*.shp', 'Select the shp file');
if (originshpfilename ~= 0)
    originshpfile = strcat(cover_pthname, originshpfilename);
    originshpfile = shaperead(originshpfile);
else
    return;
end

[watermark_fname, watermark_pthname] = ...
    uigetfile('*.jpg; *.png; *.tif; *.bmp', 'Select the Watermark Logo');
if (watermark_fname ~= 0)
    w = strcat(watermark_pthname, watermark_fname);
%     w = double( im2bw( rgb2gray( imread( w ) ) ) );
%     w = imresize(w, [50 50], 'bilinear');
    w=im2bw(imread(w));
else
    return;
end

w=logisticE(w,0.98);
sizew=size(w)
M=sizew(1)*sizew(2);
xarray=[];
yarray=[];
xarray2=[];
yarray2=[];
lengtharray=[];
c_count=0;
m_count=0;
expd=10^9;
THRatio=0.1;
R=10;
watermarkedShp=originshpfile;
for i=1:length(originshpfile)
    xarray = originshpfile(i).X;
    yarray =  originshpfile(i).Y;
    xnotnanindex=find(~isnan(xarray));%nan index
    ynotnanindex=find(~isnan(yarray));
   
     %---------------------------------remove nan------------------------------%
    xarray=xarray(xnotnanindex)';
    yarray=yarray(ynotnanindex)';
    xys=[xarray  yarray];
    c_count=c_count+length(yarray);

   %---------------------------------d-p to get feture points-----------------------------%

    vertV=[xys(end,2)-xys(1,2),-xys(end,1)+xys(1,1)];
    if vertV(1)==0 & vertV(2)==0
        continue
    end
    baseL=abs(sum((xys-xys(1,:)).*vertV./norm(vertV),2));
    TH = max(baseL)*THRatio;
    [ps,ids] = Douglas(xys,TH);

  
    
     Feature_xys=xarray(ids)+yarray(ids)*1i;
    
    
    ak=fft(Feature_xys); 
    xw=angle(ak);   
    fd=abs(ak);
	[v,s,u]=svd(fd(2:end),'econ');
    
    v_mod = v*expd;

    for n=1:length(v_mod)
        p=mod(floor(v_mod(n)/100),M)+1;
        if w(p)==0 &&  mod(v_mod(n),R)>R/2
            v_mod(n)=v_mod(n)-R/2;
        elseif w(p)==1 && mod(v_mod(n),R)<R/2
            v_mod(n)=v_mod(n)+R/2;
        end
    end
    v_mod = v_mod / expd;
    fd_mod = v_mod*s*u';
    fd_mod=[fd(1);fd_mod];
    xy=fd_mod.*cos(xw)+fd_mod.*sin(xw)*1i;
    zz=ifft(xy);
    x_mod=real(zz);
    y_mod=imag(zz);
    m_count = m_count+length(x_mod);
    watermarkedShp(i).X(ids) = x_mod;
    watermarkedShp(i).Y(ids) =y_mod;
end
simplifyratio=(1-m_count/c_count);
[max_error,mean_error,rmse] = SuperError(watermarkedShp,originshpfile);
embedshp=strcat('Embed/embed_',originshpfilename);
shapewrite(watermarkedShp,embedshp );
outputres= sprintf('maxerror£º%.10f',max_error);
disp(outputres);
outputres= sprintf('Compression rate£º%.5f',simplifyratio);
disp(outputres);



