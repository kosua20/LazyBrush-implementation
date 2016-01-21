function [ result ] = lazybrush( base_name, mode, save )
%% Creating the variables
verbose = 0;
[I, M, B, C, intensity, initial] = createVariables(strcat(base_name,'.png'),strcat(base_name,'_brushes.png'),mode,verbose);
%% Running the colorization
mix = 0.0;%mixing factor for type-1 edges
tic;
map = colorize(I,M,B,C,mix,verbose);
toc;
%% Recover the colors
disp('Displaying the result.');
result = zeros(size(I,1),size(I,2),3);
%We multiply the grey image by the colors
for i=1:size(I,1)
    for j = 1:size(I,2)
        for k =1:3
            if map(i,j) > 0 && map(i,j)<=size(C,1)
                    result(i,j,k) = intensity(i,j) * C(map(i,j),k);
            %{ 
            Additional settings for detecting errors
            elseif map(i,j)<=0
               if k==1
                    result(i,j,k) = 255;
               end
            else
               if k==2
                    result(i,j,k) = 255;
               end
            %}
            end
           
        end
    end
end
figure;
movegui('center');
subplot(1,2,1);imshow(uint8(initial));title('Initial image');
subplot(1,2,2);imshow(uint8(result));title('Final image');
if save
    imwrite(uint8(result), strcat(base_name, '_output.png'));
end
end

