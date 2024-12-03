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
i_in = imread ('D:\GitHub\MorphSeg\Pierre_Belon_s_Book\Page_298.jpg');

% ------------------------------ Preprocessing
% Reduce the size of the image to remove the areas that do not consist of any data (blank areas)
i_crop = i_in (1700:end , 1:2450);

% Convert it to binary image
i_hist = imhist (i_crop);
hist_vall = find ((i_hist(50:200) < 5) == 1);
valley = (hist_vall(1) + hist_vall(end))/500 + 0.2;
i_bin = im2bw (i_crop , valley);

% Negative the image
i_neg = ~i_bin;

% Enhance the image to get rid of the small connected components
i_prepro = bwareaopen (i_neg , 35);
%clear i_in i2 i3 hist hist_vall vall

% ------------------------------ Separating text from non-text (level 1) 
% Reinforcement (closing) of the regions oriented in all directions except 0 and 90
angle = [30 60 120 150];
i_close = i_prepro;
for i= 1:4
    se = strel ('line' , 10 , angle(i));
    i_close = imclose (i_close , se);
    %figure , imshow (i_close)
end

% Suppression (opening) of the text set
se = strel ('rectangle' , [60 10]);
i_open = imopen (i_close , se);
%figure , imshow (i_open)

% Reconstruction the non-text part
i_recon = imreconstruct (i_open , i_close);
%figure , imshow (i_recon)
NONTEXT = i_prepro & i_recon;
figure , imshow (NONTEXT)

% Extracting the text part
TEXT = i_prepro - NONTEXT;
figure , imshow (TEXT)

% Separating figures from non-figures (level 2)
se  = strel ('square' , 50);
i10 = imclose (NONTEXT , se);
se  = strel ('square' , 350);
i11 = imerode (i10 , se);
i12 = imreconstruct (i11 , i10);
i13 = NONTEXT - i12;
NONFIGURES = im2bw (i13 , 0.9);
FIGURES = NONTEXT - NONFIGURES;
%clear i10 i11 i12 i13

% Separating stripes from drop capitals (level 3) 
se  = strel ('square' , 50);
i15 = imclose (NONFIGURES , se);
i16 = imfill (i15 , 'holes');
se  = strel ('line' , 400 , 0);
i17 = imerode (i16 , se);
i18 = imreconstruct (i17 , i16);
i19 = NONFIGURES - i18;
DROPCAPITALS  = im2bw (i19 , 0.9);
STRIPES = NONFIGURES - DROPCAPITALS;
%clear i15 i16 i17 i18 i19 NONFIGURES

% Separating annotations from text matter (level 2) 
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
subplot (2 , 3 , 1) , imshow (i_crop)         , title ('INPUT IMAGE')
subplot (2 , 3 , 2) , imshow (TEXTMATTER)   , title ('TEXTMATTER')
subplot (2 , 3 , 3) , imshow (ANNOTATIONS)  , title ('ANNOTATIONS')
subplot (2 , 3 , 4) , imshow (DROPCAPITALS) , title ('DROPCAPITALS')
subplot (2 , 3 , 5) , imshow (STRIPES)      , title ('STRIPES')
subplot (2 , 3 , 6) , imshow (FIGURES)      , title ('FIGURES')