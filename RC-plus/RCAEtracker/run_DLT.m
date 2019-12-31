%% Copyright (C) Naiyan Wang and Dit-Yan Yeung.
%% Learning A Deep Compact Image Representation for Visual Tracking. (NIPS2013')
%% All rights reserved.

% initialize variables
% clc; clear;
function results=run_DLT(seq, res_path, bSaveImage)
    addpath('affineUtility');
    addpath('drawUtility');
    addpath('imageUtility');
    addpath('NN');
    addpath('RCpredictor');
    rand('state',0);  randn('state',0);
    if isfield(seq, 'opt')
        opt = seq.opt;
    else
        trackparam_DLT;
    end
    rect=seq.init_rect;
    p = [rect(1)+rect(3)/2, rect(2)+rect(4)/2, rect(3), rect(4), 0];
    frame = imread(seq.s_frames{1});
    if size(frame,3)==3
        frame = double(rgb2gray(frame));
    end
    
    scaleHeight = size(frame, 1) / opt.normalHeight;
    scaleWidth = size(frame, 2) / opt.normalWidth;
    p(1) = p(1) / scaleWidth;
    p(3) = p(3) / scaleWidth;
    p(2) = p(2) / scaleHeight;
    p(4) = p(4) / scaleHeight;
    frame = imresize(frame, [opt.normalHeight, opt.normalWidth]);
    frame = double(frame) / 255;
    
    
    paramOld = [p(1), p(2), p(3)/opt.tmplsize(2), p(5), p(4) /p(3) / (opt.tmplsize(1) / opt.tmplsize(2)), 0];
    param0 = affparam2mat(paramOld);
    
    
    if ~exist('opt','var')  opt = [];  end
    if ~isfield(opt,'minopt')
      opt.minopt = optimset; opt.minopt.MaxIter = 25; opt.minopt.Display='off';
    end
    reportRes = [];
    tmpl.mean = warpimg(frame, param0, opt.tmplsize);
    tmpl.basis = [];
    % Sample 10 positive templates for initialization
    for i = 1 : opt.maxbasis / 10
        tmpl.basis(:, (i - 1) * 10 + 1 : i * 10) = samplePos_DLT(frame, param0, opt.tmplsize);
    end
    % Sample 100 negative templates for initialization
    p0 = paramOld(5);
    tmpl.basis(:, opt.maxbasis + 1 : 100 + opt.maxbasis) = sampleNeg(frame, param0, opt.tmplsize, 100, opt, 8);

    param.est = param0;
    param.lastUpdate = 1;

    wimgs = [];

    % draw initial track window
    drawopt = drawtrackresult([], 0, frame, tmpl, param, []);
    drawopt.showcondens = 0;  drawopt.thcondens = 1/opt.numsample;
    if (bSaveImage)
        imwrite(frame2im(getframe(gcf)),sprintf('%s0000.jpg',res_path));    
    end
    
    % track the sequence from frame 2 onward
    duration = 0; tic;
    if (exist('dispstr','var'))  dispstr='';  end
    L = [ones(opt.maxbasis, 1); (-1) * ones(100, 1)];
    nn = initDLT(tmpl, L);
    L = [];
    pos = tmpl.basis(:, 1 : opt.maxbasis);
    pos(:, opt.maxbasis + 1) = tmpl.basis(:, 1);
    opts.numepochs = 5 ;
    
    % build up RC predictor
    Estimate_fixed;
    generateNet;
    learnAndTest;
    samplelength = 80;
    predictlength = 1;
    datalength = samplelength-predictlength-inputLengthVar+1;
    load('actual1.mat');
    x = actual1(:,1);
    y = actual1(:,2);
    sampleinput = zeros(inputLength,datalength);
    sampleinput(:,1) = [515;215];
%     sampleinput(:,1) = [257.5;143.333333];
    sampleout = zeros(inputLength,datalength);
    sampleout = [x(predictlength+inputLengthVar-1:samplelength-1)';y(predictlength+inputLengthVar-1:samplelength-1)'];
    initialRunlength = 0;  plotRunlength = 79;
    offset = 0;
    internalState = totalstate(1:netDim);
    teacherPL = zeros(outputLength, plotRunlength);
    netOutPL = zeros(outputLength, plotRunlength);
    inputPL = zeros(inputLength, plotRunlength);
    plotindex = 0;
    msetest = zeros(1,outputLength); 
    
    for f = 1:size(seq.s_frames,1)  
      frame = imread(seq.s_frames{f});
      if size(frame,3)==3
        frame = double(rgb2gray(frame));
      end  
      frame = imresize(frame, [opt.normalHeight, opt.normalWidth]);
      frame = double(frame) / 255;
      
      ffrc;
      netOut(1) = netOut(1)/scaleWidth;
      netOut(2) = netOut(2)/scaleHeight;
      inputSource = [netOut',0.6250,0,1.3333,0];
%       inputSource = paramOld;
%       inputSource(1:2) = netOut';
      param.rcEst = affparam2mat(inputSource);
      param.estPrev = param.est;

      % do tracking
      if f<=10
          param = estwarp_condens_DLT(frame, tmpl, param, opt, nn, f);
      elseif f>10
          param = estwarp_condens_DLT_cut(frame, tmpl, param, opt, nn, f);
      end

      % do redoAE & update
      
      if  param.redoAE
          param.est = param.estPrev;
          param = estwarp_condens_DLT(frame, tmpl, param, opt, nn, f);
      end

      temp = warpimg(frame, param.est', opt.tmplsize);
      pos(:, mod(f - 1, opt.maxbasis) + 1) = temp(:);
      
      if  param.update
          opts.batchsize = 10;
          % Sample two set of negative samples at different range.
          neg = sampleNeg(frame, param.est', opt.tmplsize, 49, opt, 8);
          neg = [neg sampleNeg(frame, param.est', opt.tmplsize, 50, opt, 4)];
          nn = nntrain(nn, [pos neg]', [ones(opt.maxbasis + 1, 1); zeros(99, 1)], opts);
      end

      duration = duration + toc;
      
      res = affparam2geom(param.est);
      p(1) = round(res(1));
      p(2) = round(res(2)); 
      p(3) = round(res(3) * opt.tmplsize(2));
      p(4) = round(res(5) * (opt.tmplsize(1) / opt.tmplsize(2)) * p(3));
      p(5) = res(4);
      p(1) = p(1) * scaleWidth;
      p(3) = p(3) * scaleWidth;
      p(2) = p(2) * scaleHeight;
      p(4) = p(4) * scaleHeight;
      paramOld = [p(1), p(2), p(3)/opt.tmplsize(2), p(5), p(4) /p(3) / (opt.tmplsize(1) / opt.tmplsize(2)), 0];
      
      reportRes = [reportRes;  affparam2mat(paramOld)];
      
      sampleinput(1,f+1) = p(1);
      sampleinput(2,f+1) = p(2);

      
      tmpl.basis = [pos];
      drawopt = drawtrackresult(drawopt, f, frame, tmpl, param, []);
      if (bSaveImage)
          imwrite(frame2im(getframe(gcf)),sprintf('%s/%04d.jpg',res_path,f));
      end
      tic;
    end
    duration = duration + toc
    fprintf('%d frames took %.3f seconds : %.3fps\n',f,duration,f/duration);
    results.res=reportRes;
    results.type='ivtAff';
    results.tmplsize = opt.tmplsize;
    results.fps = f/duration;
    results.rcestTraj = netOutPL;
end
