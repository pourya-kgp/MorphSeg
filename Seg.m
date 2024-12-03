% ----------------------------------------------------------------------------------------------------
% Author        : Pourya Khodagholipour (P.KH)
% Project Name  : Implementation of the paper "Automatic Feature Extraction on Pages of Antique Books
%                                              Through a Mathematical Morphology Based Methodology"
%                 Authors: Isabel Granado, Pedro Pina, Fernando Muge
% File Name     : Seg.m
% Creation Date : 2012/03/15
% Revision Date : 2024/12/03
% ----------------------------------------------------------------------------------------------------

clear all 
close all
clc

% Read the source image
i_in = imread ('D:\GitHub\MorphSeg\Pierre_Belon_s_Book\Page_404.jpg');

% ------------------------------ Preprocessing
% Reduce the size of the image to remove the areas that do not consist of any data (blank areas)
i_crop = i_in (1700:end , 1:2450);
%figure , imshow (i_crop) , title ('cropped')

% Convert it to binary image
i_hist = imhist (i_crop);
hist_vall = find ((i_hist(50:200) < 5) == 1);
valley = (hist_vall(1) + hist_vall(end))/500 + 0.2;
i_bin = im2bw (i_crop , valley);
%figure , imshow (i_bin) , title ('binarized)

% Negative the image
i_neg = ~i_bin;
%figure , imshow (i_neg) , title ('negativated)

% Enhance the image to get rid of the small connected components
i_prepro = bwareaopen (i_neg , 35);
%figure , imshow (i_prepro) , title ('preprocessed')

% ------------------------------ Separating text from non-text (level 1) 
% 1. Reinforcement (closing) of the regions oriented in all directions except 0 and 90
%    (Directional closings with straight lines as structuring element)
angle = [30 60 120 150];
i_close = i_prepro;
for i= 1:4
    se = strel ('line' , 10 , angle(i));
    i_close = imclose (i_close , se);
    %figure , imshow (i_close) , title ('closed')
end

% 2. Suppression (opening) of the text set (Directional openings using a straight line as structuring element)
%    In this implementation, a straight-line structuring element is substituted with a rectangle structuring element
se = strel ('rectangle' , [60 15]);
i_open = imopen (i_close , se);
%figure , imshow (i_open) , title ('opened')

% 3. Reconstruction the non-text parts (Reconstruction)
i_recon = imreconstruct (i_open , i_close);
%figure , imshow (i_recon) , title ('reconstructed')

% 4. Specifying the non-text parts (Intersection)
NONTEXT = i_prepro & i_recon;
%figure , imshow (NONTEXT) , title ('NONTEXT')

% 5. Extracting the text parts (Difference)
TEXT = i_prepro - NONTEXT;
%figure , imshow (TEXT) , title ('TEXT')

% ------------------------------ Separating figures from non-figures (level 2)
% 1. Creating "strong" objects (Closing with an isotropic structuring element)
se  = strel ('square' , 50);
i_close = imclose (NONTEXT , se);
%figure , imshow (i_close) , title ('closed')

% 2. Creation of a marker of the figures (Erosion with an isotropic structuring element)
se  = strel ('square' , 370);
i_erode = imerode (i_close , se);
%figure , imshow (i_erode) , title ('eroded')

% 3. Identification of figures (Reconstruction & intersection)
i_recon = imreconstruct (i_erode , i_close);
%figure , imshow (i_recon) , title ('reconstructed')
FIGURES = NONTEXT & i_recon;
%figure , imshow (FIGURES) , title ('FIGURES')

% 4. Identification of non-figures (Difference)
NONFIGURES = NONTEXT - FIGURES;
%figure , imshow (NONFIGURES) , title ('NONFIGURES')
    
% ------------------------------ Separating stripes from drop capitals (level 3) 
% 1. Creation of pseudo-convex hulls (A closing followed by filling the holes)
se  = strel ('square' , 50);
i_close = imclose (NONFIGURES , se);
%figure , imshow (i_close) , title ('closed')
i_fill = imfill (i_close , 'holes');
%figure , imshow (i_fill) , title ('filled')

% 2. Creation of markers of the stripes (Directional erosion along the horizontal direction)
se  = strel ('line' , 400 , 0);
i_erode = imerode (i_fill , se);
%figure , imshow (i_erode) , title ('eroded')

% 3. Identification of the stripes (Reconstruction & intersection)
i_recon = imreconstruct (i_erode , i_fill);
%figure , imshow (i_recon) , title ('reconstructed')
STRIPES = NONFIGURES & i_recon;
%figure , imshow (STRIPES) , title ('STRIPES')

% 4. Identification of the illuminated letters (Difference)
DROPCAPITALS = NONFIGURES - STRIPES;
%figure , imshow (DROPCAPITALS) , title ('DROPCAPITALS')

% ------------------------------ Separating annotations from text matter (level 2) 
se  = strel ('line' , 351 , 90);
i20 = imclose (TEXT , se);
i21 = imfill (i20 , 'holes');
se  = strel ('line' , 251 , 0);
i22 = imerode (i21 , se);
i23 = imreconstruct (i22 , i21);
i24 = TEXT - i23;
ANNOTATIONS = im2bw (i24 , 0.9);
TEXTMATTER = TEXT - ANNOTATIONS;
%clear i20 i21 i22 i23 i24 TEXT

% Negative the separated images to normal mode
FIGURES = ~FIGURES;
STRIPES = ~STRIPES;
DROPCAPITALS = ~DROPCAPITALS; 
TEXTMATTER = ~TEXTMATTER;
ANNOTATIONS = ~ANNOTATIONS;

% Dipicting results
subplot (2 , 3 , 1) , imshow (i_crop)       , title ('INPUT IMAGE')
subplot (2 , 3 , 2) , imshow (TEXTMATTER)   , title ('TEXTMATTER')
subplot (2 , 3 , 3) , imshow (ANNOTATIONS)  , title ('ANNOTATIONS')
subplot (2 , 3 , 4) , imshow (DROPCAPITALS) , title ('DROPCAPITALS')
subplot (2 , 3 , 5) , imshow (STRIPES)      , title ('STRIPES')
subplot (2 , 3 , 6) , imshow (FIGURES)      , title ('FIGURES')