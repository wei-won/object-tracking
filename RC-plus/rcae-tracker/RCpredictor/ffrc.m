in = [diag(inputscaling) * sampleinput(:,f+offset) + inputshift];  % in is column vector
teach = [diag(teacherscaling)* sampleout(:,f+offset) + teachershift];    % teach is column vector     
    
    %write input into totalstate
    
        totalstate(netDim+1:netDim+inputLength) = in; 
    
    %update totalstate except at input positions  
    if linearNetwork       
            internalState = ([intWM, inWM, ofbWM]*totalstate);         
    else        
            internalState = fsig([intWM, inWM, ofbWM]*totalstate);          
    end    
    if linearOutputUnits
        netOut = outWM *[internalState;in];
    else
        netOut = fsig(outWM *[internalState;in]);
    end
    totalstate = [internalState;in;netOut];    
    
    %force teacher output 
    if f <= initialRunlength 
        totalstate(netDim+inputLength+1:netDim+inputLength+outputLength) = teach; 
    end
    %update msetest
    if f > initialRunlength 
        for j = 1:outputLength
            msetest(1,j) = msetest(1,j) + (teach(j,1)- netOut(j,1))^2;
        end
    end
    
    %write plotting data into various plotfiles
    if f > initialRunlength  
        plotindex = plotindex + 1;
        if inputLength > 0
            inputPL(:,plotindex) = in;
        end
        teacherPL(:,plotindex) = teach; 
        netOutPL(:,plotindex) = netOut;
        
    end
%end of the great do-loop


% print diagnostics 
msetestresult = msetest / plotRunlength;
teacherVariance = var(teacherPL');;
disp(sprintf('test NRMSE = %s', num2str(sqrt(msetestresult ./ teacherVariance))));