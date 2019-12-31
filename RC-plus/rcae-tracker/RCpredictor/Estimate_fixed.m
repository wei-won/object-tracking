
% header infos for controller learning

%%%%%%% createEmptyFigs
%%%%%%% generateNetold
netDim = 10; connectivity = 0.05; inputLength = 2; outputLength = 2;
inputLengthVar = 1;
%%%%%%% generateTrainTestData
virtualLength = 1000;
actualLength = 79;
samplelength = virtualLength+0;
%%%%%%% learnAndTest
specRad = 1; ofbSC = [0.1;0.1]; noiselevel = 0; 
linearOutputUnits = 1; linearNetwork = 0; WienerHopf = 0; 
initialRunlength = 100; sampleRunlength = 800; freeRunlength = 0; plotRunlength = 99;
inputscaling = ones(2,1); inputshift = zeros(2,1);
teacherscaling = ones(2,1); teachershift = zeros(2,1)*0.5;

maxStepLength = 40;
maxStepAngle = 30;


start = [515,215];
start_angle = atan2d(-4.5,10);
% start = randi([10 290],1,2);
% start_angle = randi([0 360]);
pre_coord = start;
pre_angle = start_angle;
for i  = 1:virtualLength
    steplength = rand([1 1])*maxStepLength;
    new_coord(1,1) = steplength*cosd(pre_angle) + pre_coord(1,1);
    new_coord(1,2) = steplength*sind(pre_angle) + pre_coord(1,2);
    start(i,:) = new_coord;
    pre_coord = new_coord;
    pre_angle = pre_angle-maxStepAngle+rand*2*maxStepAngle;
%     pre_angle = randi([pre_angle-maxStepAngle pre_angle+maxStepAngle]);
end

startFlip = flipud(start);
% newdata = [startFlip;actual1];
newdata = startFlip;
output = newdata(2:samplelength,:);

% plot(startFlip(:,1),startFlip(:,2))
% output(2:samplelength,:) = start(1:samplelength-1,:);
sampleinput = newdata(1:samplelength-1,:)';
sampleout = output';

% figure
% plot(newdata(:,1),newdata(:,2));

% a = [start(:,1),start(:,2)-min(start(:,2))+20];
% figure
% plot(a(:,1),a(:,2));
% a = round(a);




% for i = 1:5000
%     data(:,:,i) = rand(30);
% end
% 
% 
% for i = 2:5000
%     out(:,:,i) = data(:,:,i-1)-data(:,:,i);
% end


