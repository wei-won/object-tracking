% header infos for controller learning

%%%%%%% createEmptyFigs
%%%%%%% generateNetold
netDim = 10; connectivity = 0.1;
inputVarNum = 2; inputLengthVar = 10;
inputLength = inputVarNum * inputLengthVar; 
outputLength = 2;
%%%%%%% generateTrainTestData
samplelength = 781;
steplength = 10;
%%%%%%% learnAndTest
specRad = 0.8; ofbSC = [0;0]; noiselevel = 0.0000;
linearOutputUnits = 0; linearNetwork = 0; WienerHopf = 0;
initialRunlength = 50; sampleRunlength = 500; freeRunlength = 0; plotRunlength = 200;
inputscaling = ones(inputLength,1)*0.5; inputshift = ones(inputLength,1);
teacherscaling = [0.3;0.3]; teachershift = [-0.2;-0.2];