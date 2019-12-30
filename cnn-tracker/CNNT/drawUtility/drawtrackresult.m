function drawopt = drawtrackresult(drawopt, fno, frame, tmplp1, param1,tmplp2, param2,tmplp3, param3, pts)
% function drawopt = drawtrackresult(drawopt, fno, frame, tmpl, param, pts)
%
%   drawopt : misc info for drawing, intitially []
%         [.showcoef] : shows coefficient
%         [.showcondens,thcondens] : show condensation candidates
%   fno : frame number
%   frame(fh,fw) : current frame
%   tmpl.mean(th,tw) : mean image
%       .basis(tN,nb) : basis
%   param.est : current estimate
%        .wimg : warped image
%       [.err,mask] : error, mask image
%       [.param,conf] : condensation
%
% uses: util/showimgs

% Copyright (C) 2005 Jongwoo Lim and David Ross.
% All rights reserved.


if (isempty(drawopt))
  figure(1); clf;
  set(gcf,'DoubleBuffer','on','MenuBar','none');
  colormap('gray');
  drawopt.curaxis = [];
  [fh,fw] = size(frame);  [th,tw] = size(tmplp1.mean);
  hb = th / (fh/fw*(5*tw) + 3*th);
%   drawopt.curaxis.frm  = axes('position', [0.00 0.00 1.00 1.00]);
% 
  drawopt.curaxis.frm  = axes('position', [0.00 3*hb 1.00 1-3*hb]);
%   drawopt.curaxis.frm  = axes('position', [0.00 0 1 1]);
  drawopt.curaxis.window1 = axes('position', [0.00 2*hb 0.33 hb]);
  drawopt.curaxis.window2 = axes('position', [0.34 2*hb 0.33 hb]);
  drawopt.curaxis.window3 = axes('position', [0.68 2*hb 0.33 hb]);
  drawopt.curaxis.basis1 = axes('position', [0.00 0.00 0.33 2*hb]);
  drawopt.curaxis.basis2 = axes('position', [0.34 0.00 0.33 2*hb]);
  drawopt.curaxis.basis3 = axes('position', [0.68 0.00 0.33 2*hb]);
  drawopt.showcoef = 0;  drawopt.magcoef = 3;
  drawopt.showcondens = 1;  drawopt.thcondens = 0.001;
end

sz = size(tmplp1.mean);  w = sz(2);  h = sz(1);  N = w*h;
nb = size(tmplp1.basis,2);  nbir = 4;  %% numbasis to show, numbasis in a row
ns = 40;  nbir = 5;  nb = min(nb, ns);  %% for figures

curaxis = drawopt.curaxis;

% main frame window
axes(curaxis.frm);
imagesc(frame, [0,1]); hold on;
if (drawopt.showcondens && isfield(param1,'param') && isfield(param1,'conf'))
  p = affparam2mat(param1.param(:,find(param.conf > drawopt.thcondens)));
  for i = 1:size(p,2)
    drawbox(sz, p(:,i), 'Color','g');
  end
end
if (exist('pts'))
  if (size(pts,3) > 1)  plot(pts(1,:,2),pts(2,:,2),'yx','MarkerSize',10);  end;
  if (size(pts,3) > 2)  plot(pts(1,:,3),pts(2,:,3),'rx','MarkerSize',10);  end;
end
text(5, 18, num2str(fno), 'Color','y', 'FontWeight','bold', 'FontSize',18);
drawbox(sz, param1.est, 'Color','r', 'LineWidth',2.5);
drawbox(sz, param2.est, 'Color','g', 'LineWidth',2.5);
drawbox(sz, param3.est, 'Color','c', 'LineWidth',2.5);
axis equal tight off; hold off;

if (isfield(curaxis,'basis1'))
  axes(curaxis.basis1);
  mag = drawopt.magcoef;
  if (drawopt.showcoef && nb > 0)
    basisimg1 = reshape(tmplp1.basis(:,1:nb), [sz,nb]);
    basisimg1(:,w+1,:) = zeros(h,1,nb);
    ipos = find(coef > 0);  ineg = find(coef < 0);
    for i = 1:length(ipos)
      basisimg1(h+1-(1:min(h,ceil(mag*coef(ipos(i))))),w+1,ipos(i)) = 1;
    end
    for i = 1:length(ineg)
      basisimg1(h+1-(1:min(h,ceil(-mag*coef(ineg(i))))),w+1,ineg(i)) = -1;
    end
    showimgs(zscore(basisimg1),[nbir, -mag,mag]);
  else
    if (nb > 0)
      basisimg1 = cat(2, zscore(tmplp1.basis), zeros(N,ns-nb));
    else
      basisimg1 = zeros(N,ns);
    end
    showimgs(reshape(basisimg1(:, 1 : ns), [sz,ns]), [nbir,-mag,mag]);
  end
  axis equal tight off;
  %    text(5,-3, 'basis');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (isfield(curaxis,'basis2'))
  axes(curaxis.basis2);
  mag = drawopt.magcoef;
  if (drawopt.showcoef && nb > 0)
    basisimg2 = reshape(tmplp2.basis(:,1:nb), [sz,nb]);
    basisimg2(:,w+1,:) = zeros(h,1,nb);
    ipos = find(coef > 0);  ineg = find(coef < 0);
    for i = 1:length(ipos)
      basisimg2(h+1-(1:min(h,ceil(mag*coef(ipos(i))))),w+1,ipos(i)) = 1;
    end
    for i = 1:length(ineg)
      basisimg2(h+1-(1:min(h,ceil(-mag*coef(ineg(i))))),w+1,ineg(i)) = -1;
    end
    showimgs(zscore(basisimg2),[nbir, -mag,mag]);
  else
    if (nb > 0)
      basisimg2 = cat(2, zscore(tmplp2.basis), zeros(N,ns-nb));
    else
      basisimg2 = zeros(N,ns);
    end
    showimgs(reshape(basisimg2(:, 1 : ns), [sz,ns]), [nbir,-mag,mag]);
  end
  axis equal tight off;
  %    text(5,-3, 'basis');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (isfield(curaxis,'basis3'))
  axes(curaxis.basis3);
  mag = drawopt.magcoef;
  if (drawopt.showcoef && nb > 0)
    basisimg3 = reshape(tmplp3.basis(:,1:nb), [sz,nb]);
    basisimg3(:,w+1,:) = zeros(h,1,nb);
    ipos = find(coef > 0);  ineg = find(coef < 0);
    for i = 1:length(ipos)
      basisimg3(h+1-(1:min(h,ceil(mag*coef(ipos(i))))),w+1,ipos(i)) = 1;
    end
    for i = 1:length(ineg)
      basisimg3(h+1-(1:min(h,ceil(-mag*coef(ineg(i))))),w+1,ineg(i)) = -1;
    end
    showimgs(zscore(basisimg3),[nbir, -mag,mag]);
  else
    if (nb > 0)
      basisimg3 = cat(2, zscore(tmplp3.basis), zeros(N,ns-nb));
    else
      basisimg3 = zeros(N,ns);
    end
    showimgs(reshape(basisimg3(:, 1 : ns), [sz,ns]), [nbir,-mag,mag]);
  end
  axis equal tight off;
  %    text(5,-3, 'basis');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (isfield(curaxis, 'window1'))
  axes(curaxis.window1);
  %    showimgs(cat(3, tmpl.mean, tmpl.window, recon, abs(diff)*2),[4,0,1]);
  %imgdisp = tmpl.mean;  str = 'mean';
  imgdisp1 = [];  str1 = 'mean';
  if (isfield(param1,'wimg'))
    imgdisp1 = cat(3, imgdisp1, param1.wimg);  str1 = [str1 ', patch'];
  end
  if (isfield(param1,'err'))
    imgdisp1 = cat(3, imgdisp1, abs(param1.err)*2);  str1 = [str1, 'err'];
  end
  if (isfield(param1, 'recon'))
    imgdisp1 = cat(3, imgdisp1, param1.recon);  str1 = [str1 ', recon'];
  end
  showimgs(imgdisp1 ,[size(imgdisp1,3),0,1]);
  if (exist('pts') & ~isempty(pts))
    hold on; plot(pts(1,:,1)+w,pts(2,:,1),'yx'); hold off;
  end
  axis equal tight off;
  %    text(5,-4, str);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (isfield(curaxis, 'window2'))
  axes(curaxis.window2);
  %    showimgs(cat(3, tmpl.mean, tmpl.window, recon, abs(diff)*2),[4,0,1]);
  %imgdisp = tmpl.mean;  str = 'mean';
  imgdisp2 = [];  str2 = 'mean';
  if (isfield(param2,'wimg'))
    imgdisp2 = cat(3, imgdisp2, param2.wimg);  str2 = [str2 ', patch'];
  end
  if (isfield(param2,'err'))
    imgdisp2 = cat(3, imgdisp2, abs(param2.err)*2);  str2 = [str2, 'err'];
  end
  if (isfield(param2, 'recon'))
    imgdisp2 = cat(3, imgdisp2, param2.recon);  str2 = [str2 ', recon'];
  end
  showimgs(imgdisp2 ,[size(imgdisp2,3),0,1]);
  if (exist('pts') & ~isempty(pts))
    hold on; plot(pts(1,:,1)+w,pts(2,:,1),'yx'); hold off;
  end
  axis equal tight off;
  %    text(5,-4, str);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (isfield(curaxis, 'window3'))
  axes(curaxis.window3);
  %    showimgs(cat(3, tmpl.mean, tmpl.window, recon, abs(diff)*2),[4,0,1]);
  %imgdisp = tmpl.mean;  str = 'mean';
  imgdisp3 = [];  str3 = 'mean';
  if (isfield(param1,'wimg'))
    imgdisp3 = cat(3, imgdisp3, param3.wimg);  str3 = [str3 ', patch'];
  end
  if (isfield(param3,'err'))
    imgdisp3 = cat(3, imgdisp3, abs(param3.err)*2);  str3 = [str3, 'err'];
  end
  if (isfield(param3, 'recon'))
    imgdisp3 = cat(3, imgdisp3, param3.recon);  str3 = [str3 ', recon'];
  end
  showimgs(imgdisp3 ,[size(imgdisp3,3),0,1]);
  if (exist('pts') & ~isempty(pts))
    hold on; plot(pts(1,:,1)+w,pts(2,:,1),'yx'); hold off;
  end
  axis equal tight off;
  %    text(5,-4, str);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (isfield(curaxis, 'graph') && isfield(param1,'err') && fno > 0)
  axes(curaxis.graph);
  plot(param1.err);
%  drawopt.sumsqerr(fno) = mean(param.err(:).^2);
%  plot(drawopt.sumsqerr);
end
drawnow;
