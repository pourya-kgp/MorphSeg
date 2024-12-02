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
input = imread ('D:\GitHub\MorphSeg\Pierre_Belon_s_Book\Page_005.jpg');

% Reduce the size of the image to remove the areas that do not consist of any data (blank areas)
input = input (1500:5200 , 1:2600);

% Convert it to binary image
i1 = im2bw (input , 0.5);

% Enhance the image
se1 = strel ('square' , 3);
i2 = imclose (i1 , se1);

% Negative the image
i3 = ~i2;

% Enhance the image to get rid of the small connected components
i4 = bwareaopen (i3 , 35);
clear i1 i2 i3 se1

% Separating text from non-text (level 1) 
se2 = strel ('line' , 19 , 45);
se3 = strel ('line' , 19 , 135);
i5 = imclose (i4 , se2);
i6 = imclose (i5 , se3);
se4 = strel ('rectangle' , [70 10]);
i7 = imopen (i6 , se4);
i8 = imreconstruct (i7 , i6);
i9 = i4 - i8;
TEXT = im2bw (i9 , 0.9);
NONTEXT = i4 - TEXT;
clear i4 i5 i6 i7 i8 i9 i10 se2 se3 se4

% Separating figures from non-figures (level 2)
se5 = strel ('square' , 50);
i11 = imclose (NONTEXT , se5);
se6 = strel ('square' , 350);
i12 = imerode (i11 , se6);
i13 = imreconstruct (i12 , i11);
i14 = NONTEXT - i13;
NONFIGURES = im2bw (i14 , 0.9);
FIGURES = NONTEXT - NONFIGURES;
clear i11 i12 i13 i14 i15 se5 se6

% Separating stripes from drop capitals (level 3) 
se7 = strel ('square' , 50);
i16 = imclose (NONFIGURES , se7);
i17 = imfill (i16 , 'holes');
se8 = strel ('line' , 400 , 0);
i18 = imerode (i17 , se8);
i19 = imreconstruct (i18 , i17);
i20 = NONFIGURES - i19;
DROPCAPITALS  = im2bw (i20 , 0.9);
STRIPES = NONFIGURES - DROPCAPITALS;
clear i16 i17 i18 i19 i20 i21 se7 se8 NONFIGURES

% Separating annotations from text matter (level 2) 
se9 = strel ('line' , 351 , 90);
i22 = imclose (TEXT , se9);
i23 = imfill (i22 , 'holes');
se10 = strel ('line' , 251 , 0);
i24 = imerode (i23 , se10);
i25 = imreconstruct (i24 , i23);
i26 = TEXT - i25;
ANNOTATIONS = im2bw (i26 , 0.9);
TEXTMATTER = TEXT - ANNOTATIONS;
clear i22 i23 i24 i25 i26 i27 se9 se10 TEXT

% Negative the separated images to normal mode
FIGURES = ~FIGURES;
STRIPES = ~STRIPES;
DROPCAPITALS = ~DROPCAPITALS; 
TEXTMATTER = ~TEXTMATTER;
ANNOTATIONS = ~ANNOTATIONS;

% Dipicting results
subplot (2 , 3 , 1) , imshow (input)        , title ('INPUT IMAGE')
subplot (2 , 3 , 2) , imshow (TEXTMATTER)   , title ('TEXTMATTER')
subplot (2 , 3 , 3) , imshow (ANNOTATIONS)  , title ('ANNOTATIONS')
subplot (2 , 3 , 4) , imshow (DROPCAPITALS) , title ('DROPCAPITALS')
subplot (2 , 3 , 5) , imshow (STRIPES)      , title ('STRIPES')
subplot (2 , 3 , 6) , imshow (FIGURES)      , title ('FIGURES')