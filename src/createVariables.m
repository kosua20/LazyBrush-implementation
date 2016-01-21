function [ I, M, B, C, intensity, im_overlay ] = createVariables( imagePath, brushPath, scaling, verbose )
%% Loading
disp('Init: Loading from the files.');
im = double(imread(imagePath));
[nrow, ncol, ~] = size(im);
im_b = double(imread(brushPath));

%% Couche alpha
[~, ~, alpha_uint] = imread(brushPath);
alpha_double = double(alpha_uint);
alpha = zeros(nrow,ncol,3);
alpha(:,:,1) = alpha_double;
alpha(:,:,2) = alpha_double;
alpha(:,:,3) = alpha_double;

%% Display layers

    figure();
    movegui('west');
    subplot(3,3,1); imshow(uint8(im)), title('Sketch - Initial');
    subplot(3,3,4); imshow(uint8(im_b)), title('Brushes');
    subplot(3,3,5); imshow(uint8(alpha)), title('Brushes - Mask');


%% Display overlay

    im_overlay = im;
    im_overlay(alpha ~= 0) = im_b(alpha ~= 0);
    subplot(3,3,2);imshow(uint8(im_overlay)), title('Sketch - Overlay');

%% Finding color values
disp('Init: Finding colors.');
%We start by denoting which parts are transparent : they will be of color
%[-1, -1, -1]
im_b(alpha==0)=-1;
%We reshape everything to be able to use 'unique'
im_b_1 = permute(im_b,[3 1 2]);
im_b_2 = reshape(im_b_1,3,[])';
%colors here is sorted, -1 -1 -1 is first
colors = unique(im_b_2,'rows');

colors(1,:) = [];%we remove -1, -1, -1, for now
colorsCounts = zeros(size(colors,1),1); 
for ci=1:size(colors,1)
   colorsCounts(ci) = length(find(ismember(im_b_2,colors(ci,:),'rows')));
end

[~, sortidx] = sort(colorsCounts, 'descend');
temp_colors = colors(sortidx,:);
colors = temp_colors;

if verbose
    disp('Colors:');
    disp(['    ','R','     ','G','     ','B']);
    disp(colors);
end

    gridsize = 20;
    colorMap = zeros(gridsize*2,gridsize*size(colors,1),3);
    for ci=1:size(colors,1)
        for i=1:3
            colorMap(1:gridsize,(ci-1)*gridsize+1:(ci)*gridsize,i) = colors(ci,i);
        end
        colorMap(gridsize+1:2*gridsize,(ci-1)*gridsize+1:(ci)*gridsize,:) = ci*255/size(colors,1);
    end
    subplot(3,3,3);imshow(uint8(colorMap));title(['Colors (' int2str(size(colors,1)) ')']);


%% Creating grey pic and adjusting contrast
disp('Init: Scaling grey-levels image.');
im_grey = sum(im,3)/3;
subplot(3,3,7);imshow(uint8(im_grey)), title('Grey - Initial');

%We scale to [0,1]
img = im_grey/255;
intensity = img;
%Compute the perimeter of the picture
perimeter = 2*(nrow+ncol);
%Scaling the picture from [0,1] to [1,K]
if scaling == 1
    im_scaled = (perimeter) * (img .* img) + 1;
elseif scaling == 2
    filter = fspecial('log',[7 7],0.2);
    im_filtered = imfilter(img, filter);
    %mini = min(min(im_filtered));
    im_filtered = max(0,im_filtered);
    maxi = max(im_filtered(:));
    im_filtered = im_filtered/maxi;
    im_filtered = 1.0 - im_filtered;
    im_scaled= perimeter * im_filtered + 1;
elseif scaling == 3
    im_scaled = (perimeter) * (img .* img .* img) + 1;
elseif scaling == 4
    im_scaled = (perimeter) * round(img) + 1;
else
    im_scaled = (perimeter) * (img) + 1;
end

 subplot(3,3,8);imshow(uint8(255*(im_scaled-1)/(perimeter))), title(['Grey - Scaled (type:' int2str(scaling) ')']);
        


%% Short pause: what do we need ?
% - I, matrix of intensities (nrow, ncol), scaled to [1, perimeter]
% - M, matrix of color for each pixel (use an indexed table ?)
% - B, the picture with the brushs strokes (indexed colors ?)
% - C, a table of colors with their associated indices
% - a mask: we need to know wich pixels are unlabeled : the easy way is to
% initally fill M with 0

%% Let's create those
disp('Init: Creating work variables.');
I = im_scaled; 


C = [colors (1:size(colors,1))']; %we append the index of the colors, 
%to be able to delete some later without having to reindex everything

M = zeros(nrow,ncol); %filed with 0 at the start

%B is a bit tricky, we want to replace the colors by their indices
im_b_3 = zeros(nrow*ncol,1);
for i=1:size(C,1)
    im_b_3(ismember(im_b_2,C(i,1:3),'rows')) = i;
end
%reshape everything
B = reshape(im_b_3,nrow,ncol);

subplot(3,3,6);
imshow(uint8(B*255/size(C,1))); title('Brushes - Labels');
drawnow


end

