samplelength = 79;
predictlength = 1;
x = actual1(:,1);
y = actual1(:,2);

datalength = samplelength-predictlength-inputLengthVar+1;

sampleinput = zeros(inputLength,datalength);
sampleout = zeros(inputLength,datalength);

for i = 1:inputLengthVar;
    sampleinput(i,:) = x(i:i+datalength-1);
    sampleinput(i+inputLengthVar,:) = y(i:i+datalength-1);
end

sampleout = [x(predictlength+inputLengthVar:samplelength)';y(predictlength+inputLengthVar:samplelength)'];

sampleinput = [x(1:samplelength-1)';y(1:samplelength-1)'];
sampleout = [x(2:samplelength)';y(2:samplelength)'];

% % normalize input to range [0,1]
% for indim = 1:length(sampleinput(:,1))
%     maxVal = max(sampleinput(indim,:)); minVal = min(sampleinput(indim,:));
%     if maxVal - minVal > 0
%       sampleinput(indim,:) = (sampleinput(indim,:) - minVal)/(maxVal - minVal);
%     end
% end
% 
% % normalize output to range [-0.5,0.5]
% for outdim = 1:length(sampleout(:,1))
%     maxVal = max(sampleout(outdim,:)); minVal = min(sampleout(outdim,:));
%     if maxVal - minVal > 0
%        sampleout(outdim,:) = (sampleout(outdim,:) - minVal)/(maxVal - minVal)-0.5;
%     end
% end

% plot generated sampleout
figure(1); clf;
outdim = length(sampleout(:,1));
for k = 1:outdim
    subplot(outdim, 1, k);
    plot(sampleout(k,:));
    if k == 1
        title('sampleout','FontSize',8);
    end
end
    
% plot generated sampleinput
figure(2); clf;
outdim = length(sampleinput(:,1));
for k = 1:outdim
    subplot(outdim, 1, k);
    plot(sampleinput(k,:));
    if k == 1
        title('sampleinput','FontSize',8);
    end
end