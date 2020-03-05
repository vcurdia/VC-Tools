function dname = checkdir(dname)
    if ~isdir(dname), mkdir(dname), end
end
