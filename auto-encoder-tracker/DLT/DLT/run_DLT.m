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
    rand('state',0);  randn('state',0);
    if isfield(seq, 'opt') %%to check the specified field contained in the structure.
        opt = seq.opt;
    else
        trackparam_DLT;
    end
    rect=seq.init_rect;
    p1 = [rect.p1(1)+rect.p1(3)/2, rect.p1(2)+rect.p1(4)/2, rect.p1(3), rect.p1(4), 0];
    p2 = [rect.p2(1)+rect.p2(3)/2, rect.p2(2)+rect.p2(4)/2, rect.p2(3), rect.p2(4), 0];
    p3 = [rect.p3(1)+rect.p3(3)/2, rect.p3(2)+rect.p3(4)/2, rect.p3(3), rect.p3(4), 0];
    frame = imread(seq.s_frames{1});
    if size(frame,3)==3
        frame = double(rgb2gray(frame));
    end
    
    scaleHeight = size(frame, 1) / opt.normalHeight;
    scaleWidth = size(frame, 2) / opt.normalWidth;
    % p1
    p1(1) = p1(1) / scaleWidth;
    p1(3) = p1(3) / scaleWidth;
    p1(2) = p1(2) / scaleHeight;
    p1(4) = p1(4) / scaleHeight;
    % p2
    p2(1) = p2(1) / scaleWidth;
    p2(3) = p2(3) / scaleWidth;
    p2(2) = p2(2) / scaleHeight;
    p2(4) = p2(4) / scaleHeight;
    % p3
    p3(1) = p3(1) / scaleWidth;
    p3(3) = p3(3) / scaleWidth;
    p3(2) = p3(2) / scaleHeight;
    p3(4) = p3(4) / scaleHeight;
    frame = imresize(frame, [opt.normalHeight, opt.normalWidth]); %% returns an image that has the size of [opt.normalHeight, opt.normalWidth].
    frame = double(frame) / 255;
    
    
    paramOld1 = [p1(1), p1(2), p1(3)/opt.tmplsize(2), p1(5), p1(4) /p1(3) / (opt.tmplsize(1) / opt.tmplsize(2)), 0];
    paramOld2 = [p2(1), p2(2), p2(3)/opt.tmplsize(2), p2(5), p2(4) /p2(3) / (opt.tmplsize(1) / opt.tmplsize(2)), 0];
    paramOld3 = [p3(1), p3(2), p3(3)/opt.tmplsize(2), p3(5), p3(4) /p3(3) / (opt.tmplsize(1) / opt.tmplsize(2)), 0];
    
    param1 = affparam2mat(paramOld1);
    param2 = affparam2mat(paramOld2);
    param3 = affparam2mat(paramOld3);
    
    
    if ~exist('opt','var')  opt = [];  end %%exist is used to check the existence of variable, function, folder, or class.
    if ~isfield(opt,'minopt')
      opt.minopt = optimset; opt.minopt.MaxIter = 25; opt.minopt.Display='off';
    end
    reportResp1 = [];
    tmplp1.mean = warpimg(frame, param1, opt.tmplsize);
    tmplp1.basis = [];
    reportResp2 = [];
    tmplp2.mean = warpimg(frame, param2, opt.tmplsize);
    tmplp2.basis = [];
    reportResp3 = [];
    tmplp3.mean = warpimg(frame, param3, opt.tmplsize);
    tmplp3.basis = [];
    % Sample 10 positive templates for initialization
    for i = 1 : opt.maxbasis / 10
        tmplp1.basis(:, (i - 1) * 10 + 1 : i * 10) = samplePos_DLT(frame, param1, opt.tmplsize);
        tmplp2.basis(:, (i - 1) * 10 + 1 : i * 10) = samplePos_DLT(frame, param2, opt.tmplsize);
        tmplp3.basis(:, (i - 1) * 10 + 1 : i * 10) = samplePos_DLT(frame, param3, opt.tmplsize);
    end
    % Sample 100 negative templates for initialization
    %p0 = paramOld1(5);
    tmplp1.basis(:, opt.maxbasis + 1 : 100 + opt.maxbasis) = sampleNeg(frame, param1, opt.tmplsize, 100, opt, 8);
    tmplp2.basis(:, opt.maxbasis + 1 : 100 + opt.maxbasis) = sampleNeg(frame, param2, opt.tmplsize, 100, opt, 8);
    tmplp3.basis(:, opt.maxbasis + 1 : 100 + opt.maxbasis) = sampleNeg(frame, param3, opt.tmplsize, 100, opt, 8);

    paramp1.est = param1;
    paramp1.lastUpdate = 1;
    paramp2.est = param2;
    paramp2.lastUpdate = 1;
    paramp3.est = param3;
    paramp3.lastUpdate = 1;

    wimgsp1 = [];
    wimgsp2 = [];
    wimgsp3 = [];

    % draw initial track window
    drawopt = drawtrackresult([], 0, frame, tmplp1, paramp1,tmplp2, paramp2,tmplp3, paramp3, []);
    drawopt.showcondens = 0;  drawopt.thcondens = 1/opt.numsample;
    if (bSaveImage)
        imwrite(frame2im(getframe(gcf)),sprintf('%3.3d.jpg',i));    
    end
    
    % track the sequence from frame 2 onward
    duration = 0; tic;
    if (exist('dispstr','var'))  dispstr='';  end
    L = [ones(opt.maxbasis, 1); (-1) * ones(100, 1)];
    nn1 = initDLT(tmplp1, L);
    nn2 = initDLT(tmplp2, L);
    nn3 = initDLT(tmplp3, L);
    L = [];
    pos1 = tmplp1.basis(:, 1 : opt.maxbasis);
    pos1(:, opt.maxbasis + 1) = tmplp1.basis(:, 1);
    pos2 = tmplp2.basis(:, 1 : opt.maxbasis);
    pos2(:, opt.maxbasis + 1) = tmplp2.basis(:, 1);
    pos3 = tmplp3.basis(:, 1 : opt.maxbasis);
    pos3(:, opt.maxbasis + 1) = tmplp3.basis(:, 1);
    opts.numepochs = 5 ;
    position1 = [];
    position2 = [];
    position3 = [];
    for f = 1:size(seq.s_frames,1)  
      frame = imread(seq.s_frames{f});
      if size(frame,3)==3
        frame = double(rgb2gray(frame));
      end  
      frame = imresize(frame, [opt.normalHeight, opt.normalWidth]);
      frame = double(frame) / 255;

      % do tracking
       paramp1 = estwarp_condens_DLT(frame, tmplp1, paramp1, opt, nn1, f);
       paramp2 = estwarp_condens_DLT(frame, tmplp2, paramp2, opt, nn2, f);
       paramp3 = estwarp_condens_DLT(frame, tmplp3, paramp3, opt, nn3, f);

      % do update

      temp1 = warpimg(frame, paramp1.est', opt.tmplsize);
      temp2 = warpimg(frame, paramp2.est', opt.tmplsize);
      temp3 = warpimg(frame, paramp3.est', opt.tmplsize);
      pos1(:, mod(f - 1, opt.maxbasis) + 1) = temp1(:);
      pos2(:, mod(f - 1, opt.maxbasis) + 1) = temp2(:);
      pos3(:, mod(f - 1, opt.maxbasis) + 1) = temp3(:);
      if  paramp1.update
          opts.batchsize = 10;
          % Sample two set of negative samples at different range.
          neg = sampleNeg(frame, paramp1.est', opt.tmplsize, 49, opt, 8);
          neg = [neg sampleNeg(frame, paramp1.est', opt.tmplsize, 50, opt, 4)];
          nn1 = nntrain(nn1, [pos1 neg]', [ones(opt.maxbasis + 1, 1); zeros(99, 1)], opts);
      end
      if  paramp2.update
          opts.batchsize = 10;
          % Sample two set of negative samples at different range.
          neg = sampleNeg(frame, paramp2.est', opt.tmplsize, 49, opt, 8);
          neg = [neg sampleNeg(frame, paramp2.est', opt.tmplsize, 50, opt, 4)];
          nn2 = nntrain(nn2, [pos2 neg]', [ones(opt.maxbasis + 1, 1); zeros(99, 1)], opts);
      end
      
      if  paramp3.update
          opts.batchsize = 10;
          % Sample two set of negative samples at different range.
          neg = sampleNeg(frame, paramp3.est', opt.tmplsize, 49, opt, 8);
          neg = [neg sampleNeg(frame, paramp3.est', opt.tmplsize, 50, opt, 4)];
          nn3 = nntrain(nn3, [pos3 neg]', [ones(opt.maxbasis + 1, 1); zeros(99, 1)], opts);
      end

      duration = duration + toc;
      
      res1 = affparam2geom(paramp1.est);
      p1(1) = round(res1(1));
      p1(2) = round(res1(2)); 
      p1(3) = round(res1(3) * opt.tmplsize(2));
      p1(4) = round(res1(5) * (opt.tmplsize(1) / opt.tmplsize(2)) * p1(3));
      p1(5) = res1(4);
      p1(1) = p1(1) * scaleWidth;
      p1(3) = p1(3) * scaleWidth;
      p1(2) = p1(2) * scaleHeight;
      p1(4) = p1(4) * scaleHeight;
      paramOld1 = [p1(1), p1(2), p1(3)/opt.tmplsize(2), p1(5), p1(4) /p1(3) / (opt.tmplsize(1) / opt.tmplsize(2)), 0];
      res2 = affparam2geom(paramp2.est);
      p2(1) = round(res2(1));
      p2(2) = round(res2(2)); 
      p2(3) = round(res2(3) * opt.tmplsize(2));
      p2(4) = round(res2(5) * (opt.tmplsize(1) / opt.tmplsize(2)) * p2(3));
      p2(5) = res2(4);
      p2(1) = p2(1) * scaleWidth;
      p2(3) = p2(3) * scaleWidth;
      p2(2) = p2(2) * scaleHeight;
      p2(4) = p2(4) * scaleHeight;
      paramOld2 = [p2(1), p2(2), p2(3)/opt.tmplsize(2), p2(5), p2(4) /p2(3) / (opt.tmplsize(1) / opt.tmplsize(2)), 0];
      res3 = affparam2geom(paramp3.est);
      p3(1) = round(res3(1));
      p3(2) = round(res3(2)); 
      p3(3) = round(res3(3) * opt.tmplsize(2));
      p3(4) = round(res3(5) * (opt.tmplsize(1) / opt.tmplsize(2)) * p3(3));
      p3(5) = res3(4);
      p3(1) = p3(1) * scaleWidth;
      p3(3) = p3(3) * scaleWidth;
      p3(2) = p3(2) * scaleHeight;
      p3(4) = p3(4) * scaleHeight;
      paramOld3 = [p3(1), p3(2), p3(3)/opt.tmplsize(2), p3(5), p3(4) /p3(3) / (opt.tmplsize(1) / opt.tmplsize(2)), 0];
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      reportResp1 = [reportResp1;  affparam2mat(paramOld1)];
      reportResp2 = [reportResp2;  affparam2mat(paramOld2)];
      reportResp3 = [reportResp3;  affparam2mat(paramOld3)];
      
      position1 = [position1;p1];
      position2 = [position2;p2];
      position3 = [position3;p3];
      
      tmplp1.basis = [pos1];
      tmplp2.basis = [pos2];
      tmplp3.basis = [pos3];
      drawopt = drawtrackresult(drawopt, f, frame, tmplp1, paramp1,tmplp2, paramp2,tmplp3, paramp3, []);
      if (bSaveImage)
          imwrite(frame2im(getframe(gcf)),sprintf('%3.3d.jpg',i,f));
      end
      tic;
    end
    duration = duration + toc;
    fprintf('%d frames took %.3f seconds : %.3fps\n',f,duration,f/duration);
    results.res1=reportResp1;
    results.res2=reportResp2;
    results.res3=reportResp3;
    results.position1 = position1;
    results.position2 = position2;
    results.position3 = position3;
    results.type='ivtAff';
    results.tmplsize = opt.tmplsize;
    results.fps = f/duration;
end
