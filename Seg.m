% ----------------------------------------------------------------------------------------------------
% Author        : Pourya Khodagholipour (P.KH)
% Project Name  : Implementation of the paper "Automatic Feature Extraction on Pages of Antique Books
%                                              Through a Mathematical Morphology Based Methodology"
%                 Authors: Isabel Granado, Pedro Pina, Fernando Muge
% File Name     : Seg.m
% Creation Date : 2012/03/15
% Revision Date : 2024/12/02
% ----------------------------------------------------------------------------------------------------

clear all 
close all
clc

% Read the source image
i_in = imread ('D:\GitHub\MorphSeg\Pierre_Belon_s_Book\Page_495.jpg');

% ---------------------------------------- Preprocessing
% Reduce the size of the image to remove the areas that do not consist of any data (blank areas)
i0 = i_in (1700:end , 1:2450);

% Convert it to binary image
hist = imhist (i0);
hist_vall = find ((hist(50:200) < 5) == 1);
vall = (hist_vall(1) + hist_vall(end))/500 + 0.2;
i1 = im2bw (i0 , vall);

% Enhance the image
se = strel ('square' , 3);
i2 = imclose (i1 , se);

% Negative the image
i3 = ~i2;

% Enhance the image to get rid of the small connected components
i4 = bwareaopen (i3 , 35);
%clear i_in i2 i3 hist hist_vall vall
% ----------------------------------------

% Separating text from non-text (level 1) 
se = strel ('line' , 19 , 45);
i5 = imclose (i4 , se);
se = strel ('line' , 19 , 135);
i6 = imclose (i5 , se);
se = strel ('rectangle' , [70 10]);
i7 = imopen (i6 , se);
i8 = imreconstruct (i7 , i6);
i9 = i4 - i8;
TEXT = im2bw (i9 , 0.9);
NONTEXT = i4 - TEXT;
%clear i5 i6 i7 i8 i9

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
subplot (2 , 3 , 1) , imshow (i0)           , title ('INPUT IMAGE')
subplot (2 , 3 , 2) , imshow (TEXTMATTER)   , title ('TEXTMATTER')
subplot (2 , 3 , 3) , imshow (ANNOTATIONS)  , title ('ANNOTATIONS')
subplot (2 , 3 , 4) , imshow (DROPCAPITALS) , title ('DROPCAPITALS')
subplot (2 , 3 , 5) , imshow (STRIPES)      , title ('STRIPES')
subplot (2 , 3 , 6) , imshow (FIGURES)      , title ('FIGURES')