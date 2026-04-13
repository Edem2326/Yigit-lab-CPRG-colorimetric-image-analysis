%% =========================================================
% CPRG paper assay analysis using Lab a* channel (lab stack-> conversion)
% ---------------------------------------------------------
% This script:
% 1. Reads the full RGB image
% 2. Detects all circular assay spots
% 3. Converts RGB to Lab color space
% 4. Uses the a* channel as the signal (L- brigthness; a*-red/green;
% b*yellow/blue)
% 5. Measures signal in small grid blocks
% 6. Summarizes signal for each full circle
% 7. Labels circles as R1C1 ... R5C5
% 8. Saves both detailed and summary CSV files
%% =========================================================

clear; clc; close all;

%% =========================
% 1. USER SETTINGS
%% =========================
imageFile = 'CPRG_example_2x2.tif';   % your image
gridSize = 10;               % size of each small analysis block in pixels, Adjust based on pixel dimension.
minOverlapFraction = 0.95;   % only keep blocks almost fully inside circles

%% =========================
% 2. READ IMAGE
%% =========================
% Convert to double precision for processing
RGB = im2double(imread(imageFile));

% Show original image
figure;
imshow(RGB);
title('Original RGB image');

%% =========================
% 3. DETECT CIRCULAR ASSAY REGIONS
%% =========================
% Convert to grayscale for circle detection
Igray = rgb2gray(RGB);

% Detect circles
[centers, radii, metric] = imfindcircles(Igray,[40 300], ... %radii between (40 300)
    'ObjectPolarity','dark', ...  % objeccts are darker than bacground)
    'Sensitivity',0.95);

% Stop if no circles are found
if isempty(metric)
    error('No circles detected. Try changing radius range or sensitivity.');
end

% Sort circles by detection strength
[~,idx] = sort(metric,'descend');
centers = centers(idx,:);
radii   = radii(idx);
metric  = metric(idx);

% Show detected circles
figure;
imshow(RGB);
viscircles(centers,radii,'Color','b');
title('Detected assay circles');

%% =========================
% 4. BUILD A MASK FOR ALL CIRCLES
%% =========================
[H,W,~] = size(RGB); % H-hieght, W- width , color
[X,Y] = meshgrid(1:W,1:H); % every pixel has a coordinate

circleMask = false(H,W); %(binary image)

for k = 1:length(radii) % loop for every circle
    thisCircle = (X - centers(k,1)).^2 + (Y - centers(k,2)).^2 <= radii(k).^2;
    circleMask = circleMask | thisCircle; % detect pixels only inside the circle
end

figure;
imshow(circleMask);
title('dectected regions, binary')
%% =========================
% 5. CONVERT RGB TO LAB AND EXTRACT a*
%% =========================
Lab = rgb2lab(RGB);

% Lab channels 3 channel images
L = Lab(:,:,1); %#ok<NASGU> % brightness
a = Lab(:,:,2); % green-red color axis
b = Lab(:,:,3); %#ok<NASGU> % blue-yellow color axis

% Mask the a* image outside the assay circles
aMasked = a;
aMasked(~circleMask) = NaN;

% Show pixel-level a* heat map
figure;
imagesc(aMasked);
axis image off;
colormap(turbo)
colorbar;
title('Pixel-level a* heat map');

%% =========================
% 6. GRID / BLOCK ANALYSIS
%% =========================
% These are the small blocks across the WHOLE image
blockRows = ceil(H/gridSize); % number of blocks
blockCols = ceil(W/gridSize);

gridMeanA = nan(blockRows,blockCols); % create new matrices and store the variables 'nan'- some blocls will be empty
gridStdA  = nan(blockRows,blockCols);
gridFrac  = nan(blockRows,blockCols); % fraction of box in circle

% We will store detailed block results in a structure
results = struct();
blockID = 1;

for r = 1:blockRows
    for c = 1:blockCols

        % Pixel range for this block
        rowStart = (r-1)*gridSize + 1;
        rowEnd   = min(r*gridSize, H);
        colStart = (c-1)*gridSize + 1;
        colEnd   = min(c*gridSize, W);

        % Which pixels in this block are inside a circle?
        blockMask = circleMask(rowStart:rowEnd, colStart:colEnd);

        % Fraction of this block that overlaps real assay area
        overlapFraction = nnz(blockMask) / numel(blockMask);

        % Keep only blocks that are mostly inside circles
        if overlapFraction >= minOverlapFraction

            % Extract a* values in this block
            blockA = a(rowStart:rowEnd, colStart:colEnd);

            % Only keep values inside the circle region
            vals = blockA(blockMask);

            % Store mean and standard deviation
            gridMeanA(r,c) = mean(vals,'omitnan');
            gridStdA(r,c)  = std(vals,[],'omitnan');
            gridFrac(r,c)  = overlapFraction;

            % Save details for this block
            results(blockID).BlockID = blockID;
            results(blockID).BlockRow = r;
            results(blockID).BlockCol = c;
            results(blockID).RowStart = rowStart;
            results(blockID).RowEnd = rowEnd;
            results(blockID).ColStart = colStart;
            results(blockID).ColEnd = colEnd;
            results(blockID).OverlapFraction = overlapFraction;
            results(blockID).MeanA = gridMeanA(r,c);
            results(blockID).StdA = gridStdA(r,c);

            blockID = blockID + 1;
        end
    end
end

% Convert detailed block results to a table
resultsTable = struct2table(results);

%% =========================
% 7. SHOW GRID-BASED HEAT MAP
%% =========================
figure;
imagesc(gridMeanA);
axis image;
colormap(turbo)
colorbar;
title('Grid-based mean a* heat map');
xlabel('Block column');
ylabel('Block row');

%% =========================
% 8. SHOW ORIGINAL IMAGE WITH GRID
%% =========================
figure;
imshow(RGB);
hold on;

for rr = 1:blockRows
    y = (rr-1)*gridSize + 0.5;
    line([0.5 W+0.5],[y y],'Color','cyan','LineWidth',1);
end

for cc = 1:blockCols
    x = (cc-1)*gridSize + 0.5;
    line([x x],[0.5 H+0.5],'Color','cyan','LineWidth',1);
end

viscircles(centers,radii,'Color','b');
%title('Original image with circles and analysis grid');

%% =========================
% 9. SUMMARY PER FULL CIRCLE
%% =========================
circleSummary = struct();

for k = 1:length(radii)
    thisMask = (X - centers(k,1)).^2 + (Y - centers(k,2)).^2 <= radii(k).^2;
    vals = a(thisMask);

    circleSummary(k).CircleID = k;              % original detection order
    circleSummary(k).CenterX = centers(k,1);
    circleSummary(k).CenterY = centers(k,2);
    circleSummary(k).Radius = radii(k);
    circleSummary(k).MeanA = mean(vals,'omitnan');
    circleSummary(k).MedianA = median(vals,'omitnan');
    circleSummary(k).StdA = std(vals,[],'omitnan');
    circleSummary(k).MinA = min(vals);
    circleSummary(k).MaxA = max(vals);
end

circleTable = struct2table(circleSummary);

%% =========================
% 10. SORT CIRCLES INTO THE REAL 5x5 ASSAY LAYOUT
%% =========================
% First sort by Y position (top to bottom)
circleTable = sortrows(circleTable, 'CenterY');

sampleRows = 2;
sampleCols = 2;

orderedTable = table();

for r = 1:sampleRows
    idxStart = (r-1)*sampleCols + 1;
    idxEnd   = r*sampleCols;

    rowBlock = circleTable(idxStart:idxEnd, :);

    % Then sort that row by X position (left to right)
    rowBlock = sortrows(rowBlock, 'CenterX');

    rowBlock.GridRow = repmat(r, height(rowBlock), 1);
    rowBlock.GridCol = (1:sampleCols)';

    orderedTable = [orderedTable; rowBlock];
end

circleTable = orderedTable;

%% =========================
% 11. ASSIGN SAMPLE IDs: R1C1 ... R5C7
%% =========================
sampleIDs = strings(height(circleTable),1);

for i = 1:height(circleTable)
    sampleIDs(i) = sprintf('R%dC%d', circleTable.GridRow(i), circleTable.GridCol(i));
end

circleTable.SampleID = sampleIDs;

% Move useful columns to the front
circleTable = movevars(circleTable, {'SampleID','GridRow','GridCol'}, 'Before', 'CircleID');

%% =========================
% 12. ADD SAMPLE LABELS TO THE BLOCK-LEVEL TABLE
%% =========================
% Find the center of each small block
resultsTable.BlockCenterX = (resultsTable.ColStart + resultsTable.ColEnd) / 2;
resultsTable.BlockCenterY = (resultsTable.RowStart + resultsTable.RowEnd) / 2;

% Preallocate new columns
assignedSampleID = strings(height(resultsTable),1);
assignedSampleRow = nan(height(resultsTable),1);
assignedSampleCol = nan(height(resultsTable),1);
assignedCircleID = nan(height(resultsTable),1);

for i = 1:height(resultsTable)

    bx = resultsTable.BlockCenterX(i);
    by = resultsTable.BlockCenterY(i);

    % Distance from this block center to all circle centers
    d = sqrt((circleTable.CenterX - bx).^2 + (circleTable.CenterY - by).^2);

    % Take the nearest circle
    [~, idxMin] = min(d);

    assignedSampleID(i) = circleTable.SampleID(idxMin);
    assignedSampleRow(i) = circleTable.GridRow(idxMin);
    assignedSampleCol(i) = circleTable.GridCol(idxMin);
    assignedCircleID(i) = circleTable.CircleID(idxMin);
end

% Add these labels to the detailed table
resultsTable.SampleID = assignedSampleID;
resultsTable.SampleRow = assignedSampleRow;
resultsTable.SampleCol = assignedSampleCol;
resultsTable.AssignedCircleID = assignedCircleID;

% Move important columns near the front
resultsTable = movevars(resultsTable, ...
    {'SampleID','SampleRow','SampleCol','AssignedCircleID'}, ...
    'After', 'BlockID');

%% =========================
% 13. LABEL THE CIRCLES ON AN IMAGE FOR VISUAL CHECK
%% =========================
figure;
imshow(RGB);

hold on;
viscircles(centers,radii,'Color','b');

for i = 1:height(circleTable)
    text(circleTable.CenterX(i), circleTable.CenterY(i), ...
        circleTable.SampleID(i), ...
        'Color','white', ...
        'BackgroundColor','black', ...
        'FontSize',8, ...
        'FontWeight','bold', ...
        'HorizontalAlignment','center');
end

title('Detected circles labeled as R1C1 ... R5C7');

%% =========================
% 14. SAVE CSV FILES
%% =========================
writetable(resultsTable,'CPRG_2x2_grid_mean_a_detailed260403.csv');
writetable(circleTable,'CPRG_2x2_circle_summary_streamlined260403.csv');

disp('Done. Files saved:');
disp(' - CPRG_2x2_grid_mean_a_detailed.csv');
disp(' - CPRG_2x2_circle_summary_streamlined.csv');

disp('Circle summary preview:');
disp(circleTable(1:min(10,height(circleTable)), :));

disp('Detailed block table preview:');
disp(resultsTable(1:min(10,height(resultsTable)), :));

%%
gridMeanA =(gridMeanA)
heatmapImg = imagesc(gridMeanA);
heatmapImg = nan(H,W);

for r = 1:blockRows
    for c = 1:blockCols
        rowStart = (r-1)*gridSize + 1;
        rowEnd   = min(r*gridSize, H);
        colStart = (c-1)*gridSize + 1;
        colEnd   = min(c*gridSize, W);

        heatmapImg(rowStart:rowEnd, colStart:colEnd) = gridMeanA(r,c);
    end
end

figure;
imagesc(heatmapImg);
axis image;
set(gca,'YDir','reverse');
colormap(flipud(hot));
caxis([10 100]);   % forces color bar to span 40 to 80
colorbar;

hold on;
viscircles(centers, radii, 'Color', 'black', 'LineWidth', 1);
title('Quadrat-based assay response map_260316');

