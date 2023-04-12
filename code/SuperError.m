
function  [max_error,mean_error,rmse] = SuperError(originshpfile,watermarkedShp)


    rmse=0;
    n=0;
    max_error_list=[];
    mean_error=0;

    for i=1:length(originshpfile)
  
        xarray{i} = originshpfile(i).X;
        yarray{i} =  originshpfile(i).Y;
        xnotnanindex=find(~isnan(xarray{i}));
        ynotnanindex=find(~isnan(yarray{i}));
        xarray{i}=xarray{i}(xnotnanindex);
        yarray{i}=yarray{i}(ynotnanindex);
        %--------读取第二组数据------%
        xarray2{i} = watermarkedShp(i).X;
        yarray2{i} =  watermarkedShp(i).Y;
        xnotnanindex2=find(~isnan(xarray2{i}));
        ynotnanindex2=find(~isnan(yarray2{i}));
        xarray2{i}=xarray2{i}(xnotnanindex2);
        yarray2{i}=yarray2{i}(ynotnanindex2);
       
        dxarray = xarray{i}-xarray2{i};
        dyarray=yarray{i}- yarray2{i};
        absolute_error_2 = (dxarray.*dxarray+dyarray.*dyarray);
        

        max_error_list(i) = max(sqrt(absolute_error_2));
        rmse =rmse+ sum(absolute_error_2);
        mean_error = mean_error + sum(sqrt(absolute_error_2));
        n=n+length(xarray2{i});
    end

    max_error = max(max_error_list);
    mean_error = mean_error/n;
    rmse = sqrt(rmse/n);
end