%     loads data and initializes variables
%
% Original Copyright (C) Jongwoo Lim and David Ross.
% Modified by Wei Yang & Wei Wang
% Based on the SDAE Tracker (DLT) by Naiyan Wang
% All rights reserved.

% DESCRIPTION OF OPTIONS:
%
% Following is a description of the options you can adjust for
% tracking, each proceeded by its default value.  For a new sequence
% you will certainly have to change p.  To set the other options,
% first try using the values given for one of the demonstration
% sequences, and change parameters as necessary.
%
% p = [px, py, sx, sy, theta]; The location of the target in the first
% frame.
% px and py are th coordinates of the centre of the box
% sx and sy are the size of the box in the x (width) and y (height)
%   dimensions, before rotation
% theta is the rotation angle of the box
%
% 'numsample',1000,   The number of samples used in the condensation
% algorithm/particle filter.  Increasing this will likely improve the
% results, but make the tracker slower.
%
% 'condenssig',0.01,  The standard deviation of the observation likelihood.
%
% 'affsig',[4,4,.02,.02,.005,.001]  These are the standard deviations of
% the dynamics distribution, that is how much we expect the target
% object might move from one frame to the next.  The meaning of each
% number is as follows:
%    affsig(1) = x translation (pixels, mean is 0)
%    affsig(2) = y translation (pixels, mean is 0)
%    affsig(3) = x & y scaling
%    affsig(4) = rotation angle
%    affsig(5) = aspect ratio
%    affsig(6) = skew angle
clear all;
close all;
dataPath = '../../Data';
title = 'Droneview';

switch (title)
case 'davidin';  p = [158 106 62 78 0];
    opt = struct('numsample',1000, 'affsig',[4, 4,.005,.00,.001,.00]);
case 'trellis';  p = [200 100 45 49 0];
    opt = struct('numsample',1000, 'affsig',[4,4,.00, 0.00, 0.00, 0.0]);
case 'car4';  p = [123 94 107 87 0];
    opt = struct('numsample',1000, 'affsig',[4,4,.02,.0,.001,.00]);
case 'car11';  p = [88 139 30 25 0];
    opt = struct('numsample',1000,'affsig',[4,4,.005,.0,.001,.00]);
case 'animal'; p = [350 40 100 70 0];
    opt = struct('numsample',1000,'affsig',[12, 12,.005, .0, .001, 0.00]);
case 'shaking';  p = [250 170 60 70 0];%
    opt = struct('numsample',1000, 'affsig',[4,4,.005,.00,.001,.00]);
case 'singer1';  p = [100 200 100 300 0];
    opt = struct('numsample',1000, 'affsig',[4,4,.01,.00,.001,.0000]);
case 'bolt';  p = [292 107 25 60 0];
    opt = struct('numsample',1000, 'affsig',[4,4,.005,.000,.001,.000]);
case 'woman';  p = [222 165 35 95 0.0];
    opt = struct('numsample',1000, 'affsig',[4,4,.005,.000,.001,.000]);               
case 'bird2';  p = [116 254 68 72 0.0];
    opt = struct('numsample',1000, 'affsig',[4,4,.005,.000,.001,.000]); 
case 'surfer';  p = [286 152 32 35 0.0];
    opt = struct('numsample',1000,'affsig',[8,8,.01,.000,.001,.000]);
case 'Droneview';
    p1 = [515 215 40 40 0.0];
    opt = struct('numsample',1000,'affsig',[8,8,.005,.00,.001,.000]);
    p2 = [525 255 40 40 0.0];
    p3 = [305 315 40 40 0.0];
    
        
otherwise;  error(['unknown title ' title]);
end

% The number of previous frames used as positive samples.
opt.maxbasis = 10;
opt.updateThres = 0.8;
% Indicate whether to use GPU in computation.
global useGpu;
useGpu = false;
opt.condenssig = 0.01;
opt.tmplsize = [32, 32];
opt.normalWidth = 320;
opt.normalHeight = 240;
seq.init_rect.p1 = [p1(1) - p1(3) / 2, p1(2) - p1(4) / 2, p1(3), p1(4), p1(5)];
seq.init_rect.p2 = [p2(1) - p2(3) / 2, p2(2) - p2(4) / 2, p2(3), p2(4), p2(5)];
seq.init_rect.p3 = [p3(1) - p3(3) / 2, p3(2) - p3(4) / 2, p3(3), p3(4), p3(5)];

% Load data
disp('Loading data...');
fullPath = [dataPath, '/',title];
%d = dir([fullPath,'\', '*.jpg']);
%d = dir(fullPath);
d = dir(fullfile(fullPath, '*.png'));
if size(d, 1) == 0
    d = dir([fullPath, '*.png']);
end
if size(d, 1) == 0
    d = dir([fullPath, '*.bmp']);
end
im = imread([fullPath, '/',d(1).name]);
data = zeros(size(im, 1), size(im, 2), size(d, 1));
seq.s_frames = cell(size(d, 1), 1);
for i = 1 : size(d, 1)
    seq.s_frames{i} = [fullPath,'/', d(i).name];
end
seq.opt = opt;
results = run_DLT(seq, '', false);
save([title '_res'], 'results');