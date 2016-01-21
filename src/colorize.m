function [ J ] = colorize( I, M, B, C, mix, verbose )
disp('Color: Starting...');
[nrow, ncol] = size(I);
lambda = 0.95;
colorCount = size(C,1);
K = 2*(nrow+ncol);
D = K*(1-lambda);
count = 0;
figure;
movegui('east');
figRows = round(sqrt(colorCount));
figCols = ceil(colorCount/figRows);

while size(C,1)>1
    disp('Color: processing new color.');
    % - pick a color c (just its index) in C.
    c = C(1,4);
    if verbose
        disp(C(1,:));
    end
    
    disp('Color: detecting empty areas.');
    % - we consider the pixels in the graph. If there is an independant
    % region of the mask (a closed component of the graph) which only touch 
    % pixels from 1 color, we can fill it automatically.
    % The mask M is then updated
    [G0, indices0, ~, ~] = buildGraph(M,I,mix);
    M = simplifyMask(G0,M,B,indices0);
   
    disp('Color: building graph (first-type edge).');
    [G, indices, S, T] = buildGraph(M,I,mix);
    
    disp('Color: adding second-type edges.');
    s = [];
    t = [];
    w = [];
    countS = 0;
    countT = 0;
    % - for each pixel in the mask: if B(pixel) == c, connect the pixel to 
    % S, and if B(pixel)~=c and ~=0, connect it to T 
    for k = 1:size(indices,1)
        i = indices(k,1);
        j = indices(k,2);
        if B(i,j) == c
            s = [s k];
            t = [t S];
            w = [w D];
            countS = countS + 1;
        elseif B(i,j)~=0
            s = [s k];
            t = [t T];
            w = [w D];
            countT = countT + 1;
        end
    end
    G = addedge(G,s,t,w);
    
    disp('Color: performing min-cut.');
    if numnodes(G) > 0
        if findnode(G,S)==0
            G = addnode(G,S);
        end
        if findnode(G,T)==0
            G = addnode(G,T);
        end
        % - maxflow/mincut S T -> get a new graph as a result
        [~,~,cs,ct] = maxflow(G,S,T);
        % - for each pixel edged to S, M(pixel) = c
        if verbose
            [countS countT]
            size(cs)
        end
    
        disp('Color: saving new attribution.');
        for l=1:size(cs,1)
            if cs(l) ~= S
                i = indices(cs(l),1);
                j = indices(cs(l),2);
                M(i,j) = c;
            end
        end
    end
    
    count = count+1;
    subplot(figRows, figCols,count);imshow(uint8(M*255/colorCount));title(strcat('Iteration ',int2str(count)));
    drawnow
    % - color c done, remove it from C.
    C(1,:) = [];
end

%Last color
disp('Color: processing last color.');
c = C(1,4);
if verbose
    disp(C(1,:))
end
M(M == 0)=c;

count = count+1;
subplot(figRows, figCols,count);imshow(uint8(M*255/colorCount));title(strcat('Iteration ',int2str(count)));
drawnow

disp('Color: done!'); 
J = M;
end
