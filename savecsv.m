function savecsv(fn,var,tid,data)

    fidcsv = fopen([fn,'.csv'],'wt');
    [ntid,nvar] = size(data);

    if ~iscell(tid)
        tid = num2cell(tid);
    end
    for t=1:ntid
        if ~ischar(tid{t})
            tid{t} = num2str(tid{t});
        end
    end

    fprintf(fidcsv,',%s',var{:});
    fprintf(fidcsv,'\n');
    for t=1:ntid
        fprintf(fidcsv,'%s',tid{t});
        fprintf(fidcsv,',%.6f',data(t,:));
        fprintf(fidcsv,'\n');
    end
    
    fclose(fidcsv);

end
