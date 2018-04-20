function [F, offset] = computeOffset(filename)
    file=open(filename);    
    F = file.F;
    dataIn = F(:,2);
    offset = mean(dataIn);
end