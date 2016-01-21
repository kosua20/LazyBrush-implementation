function [G, indices, S, T] = buildGraph(M, I, mix)
    mix1 = mix;
    mix2 = 1-mix;
    [nrow, ncol] = size(I);
    % - pick the pixels of the mask only
    % (not attributed : color 0)
    [i_mask, j_mask] = find(M == 0);
     % - start building the graph : connect the pixel to its neighbours using
    % the weights from I
    s = [];
    t = [];
    w = [];
    indices = [i_mask j_mask];
 
    %For each pixel of the mask
    K0 = zeros(nrow,ncol);
    for k = 1:size(indices,1)
        i = indices(k,1);
        j = indices(k,2);
        K0(i,j) = k;
    end
    S = size(indices,1)+1;
    T = size(indices,1) + 2;
    
    for k = 1:size(indices,1)
        i = indices(k,1);
        j = indices(k,2);
        
        %We check the neighbours, and add them if they are not colored
        %differently
        %(i+1,j)
        if i < nrow
            if M(i+1,j) == 0
            	s = [s, k];
                t = [t, K0(i+1,j)];
                w = [w, mix1*I(i,j)+mix2*I(i+1,j)];
            end
        end 
        %(i,j+1)
        if j < ncol
            if M(i,j+1) == 0
                s = [s, k];
                t = [t, K0(i,j+1)];
                w = [w, mix1*I(i,j)+mix2*I(i,j+1)];           
            end
        end
    end
    G = graph(s,t,w);
end

