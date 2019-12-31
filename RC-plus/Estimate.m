
% header infos for controller learning

%%%%%%% createEmptyFigs
%%%%%%% generateNetold
netDim = 4; connectivity = 0.05; inputLength = 2; outputLength = 2;
%%%%%%% generateTrainTestData
samplelength = 10000;
%%%%%%% learnAndTest
specRad = 1; ofbSC = [0.1;0.1]; noiselevel = 0; 
linearOutputUnits = 1; linearNetwork = 0; WienerHopf = 0; 
initialRunlength = 100; sampleRunlength = 2000; freeRunlength = 0; plotRunlength = 6000;
inputscaling = ones(2,1); inputshift = zeros(2,1);
teacherscaling = ones(2,1); teachershift = zeros(2,1)*0.5;






start = randi([10 290],1,2);
start_angle = randi([0 360])
pre_coord = start;
pre_angle = start_angle;
for i  = 1:10000
pre_coord(1,1) = rand([1 1])*1*sind(pre_angle) + pre_coord(1,1) ;
pre_coord(1,2) = rand([1 1])*1*cosd(pre_angle) + pre_coord(1,2) ;
start(i,:) = pre_coord;
pre_angle = randi([pre_angle-10 pre_angle+10]);
end
plot(start(:,1),start(:,2))
output(2:10000,:) = start(1:9999,:);
sampleinput = start';
sampleout = output';

a = [start(:,1),start(:,2)-min(start(:,2))+20]
figure
plot(a(:,1),a(:,2))
a = round(a);




for i = 1:5000
    data(:,:,i) = rand(30);
end


for i = 2:5000
    out(:,:,i) = data(:,:,i-1)-data(:,:,i);
end


