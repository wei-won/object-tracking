function newNN = initDLT(tmpl, L, RC)
%     load pretrain;
    W = cell(1,2);
    W{1} = randn(256,513);
    W{2} = randn(1,257);
    global useGpu;
%     newNN = nnsetup([1024 2560 1024 512 256 1]);
    newNN = nnsetup([512 256 1]);
    for i = 1 : newNN.n-2
        if useGpu
            newNN.W{i} = gpuArray(W{i});
        else
            newNN.W{i} = W{i};
        end
    end
    newNN.weightPenaltyL2 = 2e-3;
    newNN.activation_function = 'sigm';
    newNN.learningRate = 1e-1;
    newNN.momentum = 0.5;
    opts.numepochs = 20;
    opts.batchsize = 10;

%     RC = generate_esn(nInputUnits, nInternalUnits, nOutputUnits, ...
%     'spectralRadius',0.5,'inputScaling',ones(nInputUnits,1),'inputShift',zeros(nInputUnits,1), ...
%     'teacherScaling',ones(nOutputUnits,1),'teacherShift',zeros(nOutputUnits,1),'feedbackScaling', 0, ...
%     'type', 'plain_esn','reservoirActivationFunction','sigmoid01','outputActivationFunction','sigmoid01',...
%     'inverseOutputActivationFunction','sigmoid01_inv');
%     RC.internalWeights = RC.spectralRadius * RC.internalWeights_UnitSR;
    
    tmplStateCollection = compute_statematrix(tmpl.basis, [], RC, 0);
    tmpl.basis = tmplStateCollection(:,1 : RC.nInternalUnits)';
    
    L(L == -1) = 0;
    
    newNN = nntrain(newNN, tmpl.basis', L, opts);
    clear nn;
end