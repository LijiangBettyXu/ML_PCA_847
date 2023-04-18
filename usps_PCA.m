clear all;
clc
%%%%%%% Part 1 %%%%%%%%
% Define the data points as two row vectors
x = [0, -1, -3, 1, 3];
y = [0, 2, 6, -2, -6];

% Create a scatter plot
figure;
scatter(x, y, 'filled');
xlabel('x-axis');
ylabel('y-axis');
title('2D Scatter Plot of Data Points');
grid on;

% Set the axis to have equal scales
axis equal;

%%%%%%% Part 2 %%%%%%%%
load USPS.mat

A2 = reshape(A(2,:), 16, 16);
%imshow(A2')

%To reconstruct images using the selected principal components v1 and v2, 
% you need to project the mean-centered data onto the principal components 
% and then add back the mean. 

% Get mean of all rows for each column 
% and result in a row vector with(1, 256)
Amean = mean(A); 
% Mean centered version of A
An = A - Amean;

%PCs from part1
v1 = [1; -2];
v2 = [2; 1];
v1n = v1/norm(v1);
v2n = v2/norm(v2);

PCs = zeros(256, 2);
PCs(1:2, 1) = v1n;
PCs(1:2, 2) = v2n;

% Project the mean-centered data onto the selected principal components
ProjectedData = An * PCs;

% Reconstruct the data by projecting it back onto the original space
ReconstructedData = ProjectedData * PCs';

% Add the mean back to the reconstructed data
ReconstructedA = ReconstructedData + mean(A);

% Reshape each row of ReconstructedA back into a 16x16 image:
numImages = size(ReconstructedA, 1);
reconstructedImages = cell(1, numImages);
for i = 1:numImages
    reconstructedImages{i} = reshape(ReconstructedA(i, :), [16, 16]);
end

figure
subplot(1,2,1)
imshow(reconstructedImages{1}', [])
subplot(1,2,2)
imshow(reconstructedImages{2}', [])

% Implement Principal Component Analysis (PCA) using SVD and apply to the data
[U, S, V] = svd(An);

numPCs = [10, 50, 100, 200];

reconstructionErrors1 = zeros(1, numel(numPCs));
reconstructionErrors2 = zeros(1, numel(numPCs));
reconstructedImagesSubset = cell(numel(numPCs), 2);

for i = 1:numel(numPCs)
    p = numPCs(i);
    PCs = V(:, 1:p);
    ProjectedData = An * PCs;
    ReconstructedData = ProjectedData * PCs';
    ReconstructedA1 = ReconstructedData + mean(A);    
    % Calculate the reconstruction error
    reconstructionErrors1(i) = sum(sum((A - ReconstructedA1).^2));

    % Using the truncated SVD decomposition
    ReconstructedA2 = U(:,1:p)*S(1:p,1:p)*PCs' + mean(A);
    reconstructionErrors2(i) = sum(sum((A - ReconstructedA2).^2));
    
    % Get the first two reconstructed images
    reconstructedImagesSubset{i, 1} = reshape(ReconstructedA1(1, :), [16, 16]);
    reconstructedImagesSubset{i, 2} = reshape(ReconstructedA1(2, :), [16, 16]);
end

figure;
plot(numPCs, reconstructionErrors1, '-o');
xlabel('Number of Principal Components (p)');
ylabel('Total Reconstruction Error');
title('Reconstruction Error vs. Number of Principal Components');
grid on;
hold on;
plot(numPCs, reconstructionErrors2, '-*');
legend('Project','Using truncated SVD')

figure;
for i = 1:numel(numPCs)
    for j = 1:2
        % Calculate the index for the subplot
        subplotIndex = (i - 1) * 2 + j;
        
        % Display the reconstructed image
        subplot(numel(numPCs), 2, subplotIndex);
        imshow(reconstructedImagesSubset{i, j}', []);
        title(sprintf('p = %d, Image %d', numPCs(i), j));
    end
end



