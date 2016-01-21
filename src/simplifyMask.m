function [M] = simplifyMask(G0,M,B,indices)
    bins = conncomp(G0,'OutputForm','cell');
    binsToDelete = {};
    cb = 1;
    for bi = 1:length(bins)
        currentBin = bins{bi};
        shouldContinue = true;
        index = 1;
        lastColorEncountered = -1;
        while shouldContinue && index <= length(currentBin)
            i = indices(currentBin(index),1);
            j = indices(currentBin(index),2);
            if B(i,j)~=0
                %Init case
                if lastColorEncountered == -1
                    lastColorEncountered = B(i,j);
                else
                   if B(i,j) ~= lastColorEncountered
                      shouldContinue = false;
                   end
                end
            end
            index = index + 1;
        end
        % if we never encountered two points of different colors,
        % shouldContinue is still true
        % and the lastColorEncountered is not -1
        % so we can fill the bin
        if shouldContinue && lastColorEncountered ~=-1
            disp('Color: A monochrome bin will be filled');
            binsToDelete{cb} = currentBin;
            cb = cb + 1;
            for ind = 1:length(currentBin)
               i = indices(currentBin(ind),1);
               j = indices(currentBin(ind),2); 
               M(i,j) = lastColorEncountered;
            end 
        end     
    end
end

