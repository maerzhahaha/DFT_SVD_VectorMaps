
clc;
clear;
close all;
[watermarkedShp, cover_pthname] = ...
    uigetfile('*.shp', 'Select the shp file');
if (watermarkedShp ~= 0)
    watermarkedShp = strcat(cover_pthname, watermarkedShp);
    watermarkedShp = shaperead(watermarkedShp);
else
    return;
end
[watermark_fname, watermark_pthname] = ...
    uigetfile('*.jpg; *.png; *.tif; *.bmp', 'Select the Watermark Logo');
if (watermark_fname ~= 0)
    w2 = strcat(watermark_pthname, watermark_fname);
    w2=im2bw(imread(w2));
else
    return;
end

ww={};

sizew=size(w2)
M=sizew(1)*sizew(2);
for i=1:M
   ww{i}=[];
end
expd=10^9;
THRatio=0.1;
R=10;
xarray=[];
yarray=[];
lengtharray=[];
for i=1:length(watermarkedShp)
    xarray = watermarkedShp(i).X;
    yarray =  watermarkedShp(i).Y;
    xnotnanindex=find(~isnan(xarray));
    ynotnanindex=find(~isnan(yarray));
  
    xarray=2*xarray(xnotnanindex)'+100;
    yarray=2*yarray(ynotnanindex)'+100;
    xys=[xarray  yarray];
    
    
    
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
        if mod(v_mod(n),R)<=R/2
            ww{p}=[ww{p},0];
        else
            ww{p}=[ww{p},1];
        end
    end
end


w=[];
w(1:M)=0;

% voting
for i=1:M
    v = sum(ww{i})/length(ww{i});
    if( v <0.5)
      w(i)=0;
    else
      w(i)=1;
    end
end
extracted_logo=w;
extracted_logo=reshape(w,[sizew(1),sizew(2)]);
figure;
subplot(2, 1, 1);
imshow(extracted_logo);
subplot(2, 1, 1);
imshow(w2,[]);
title('original watermark');
subplot(2, 1, 2);


extracted_logo=logisticD(extracted_logo,0.98);
imshow(extracted_logo,[]);
imshow(extracted_logo);
nc=NC(extracted_logo,w2);
title('extracted watermark');
