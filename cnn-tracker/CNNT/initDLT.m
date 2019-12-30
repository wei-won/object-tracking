function newNN = initDLT(tmpl, L)
    load pre_cnn;
    global useGpu;
    newNN = cnn;
    %for i = 1 : 4
    %    if useGpu
    %        newNN.W{i} = gpuArray(W{i});
    %    else
    %        newNN.W{i} = W{i};
    %    end
    %end
    newNN.ffb = zeros(1, 1);
    newNN.ffW = (rand(1, 300) - 0.5) * 2 * sqrt(6 / (1 + 300));
    %newNN.weightPenaltyL2 = 2e-3;
    %newNN.activation_function = 'sigm';
    %newNN.learningRate = 1e-1;
    %newNN.momentum = 0.5;
    opts.numepochs = 20;
    opts.batchsize = 10;
    opts.alpha = 1;
    
    L(L == -1) = 0;
    
    newNN = cnntrain(newNN, reshape(tmpl.basis,[32,32,110]), L', opts);
    clear nn;
end