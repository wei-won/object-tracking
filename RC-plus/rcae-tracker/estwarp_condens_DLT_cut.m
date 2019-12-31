function param = estwarp_condens_DLT_cut(frm, tmpl, param, opt, nn, frameNum)

global useGpu;
n = opt.numsample_cut;
sz = size(tmpl.mean);
N = sz(1)*sz(2);

% if ~isfield(param,'param')
  param.param = repmat(affparam2geom(param.rcEst(:)), [1,n]);
% else
%   cumconf = cumsum(param.conf);
% %   idx = floor(sum(repmat(rand(1,n),[n,1]) > repmat(gather(cumconf),[1,n])))+1;
%   idx = floor(sum(repmat(rand(1,n),size(cumconf)) > repmat(gather(cumconf),[1,n])))+1;
%   param.param = param.param(:,idx);
% end
param.param = param.param + randn(6,n).*repmat(opt.affsigrc(:),[1,n]);
wimgs = warpimg(frm, affparam2mat(param.param), sz);
if useGpu
    data = gpuArray(reshape(wimgs,[N,n]));
else
    data = reshape(wimgs,[N,n]);
end

t = nnff(nn, data', zeros(n, 1));
confidence = t.a{6}';

disp(max(confidence));
if max(confidence) <= opt.redoAEThres
    param.redoAE = true;
elseif max(confidence) > opt.redoAEThres && ...
        (max(confidence) < opt.updateThres || frameNum - param.lastUpdate >= 50)
    param.redoAE = false;
    param.update = true;
    param.lastUpdate = frameNum;
else
    param.redoAE = false;
    param.update = false;
%     n = opt.numsample;
%     param.param = repmat(affparam2geom(param.est(:)), [1,n]);   
%     param.param = param.param + randn(6,n).*repmat(opt.affsig(:),[1,n]);
%     wimgs = warpimg(frm, affparam2mat(param.param), sz);
%     if useGpu
%         data = gpuArray(reshape(wimgs,[N,n]));
%     else
%         data = reshape(wimgs,[N,n]);
%     end
%     t = nnff(nn, data', zeros(n, 1));
%     confidence = t.a{6}';
%     disp(max(confidence));
end
% if max(confidence) < opt.updateThres || frameNum - param.lastUpdate >= 50
%     param.update = true;
%     param.lastUpdate = frameNum;
% else
%     param.update = false;
% end
confidence = confidence - min(confidence);
param.conf = exp(double(confidence) ./opt.condenssig)';
param.conf = param.conf ./ sum(param.conf);
[maxprob,maxidx] = max(param.conf);
if maxprob == 0 || isnan(maxprob)
    error('overflow!');
end
param.est = affparam2mat(param.param(:,maxidx));
param.wimg = reshape(data(:,maxidx), sz);

if exist('coef', 'var')
    param.bestCoef = coef(:,maxidx);
end