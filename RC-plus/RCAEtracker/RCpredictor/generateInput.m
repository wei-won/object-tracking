disp('Generating data ............');

load('actual1.mat');

x = actual1(:,1);
y = actual1(:,2);
z = 1:79;
t = 1:0.1:79;

xi = interp1(z,x,t,'pchip');
yi = interp1(z,y,t,'pchip');

datalength = samplelength-steplength-inputLength+1;

sampleinput = zeros(inputLength,datalength);
sampleout = zeros(inputLength,datalength);

for i = 1:inputLengthVar;
    sampleinput(i,:) = xi(i:i+datalength-1);
    sampleinput(i+inputLengthVar,:) = yi(i:i+datalength-1);
end

sampleout = [xi(steplength+inputLength:samplelength);yi(steplength+inputLength:samplelength)];


% normalize input to range [0,1]
for indim = 1:length(sampleinput(:,1))
    maxVal = max(sampleinput(indim,:)); minVal = min(sampleinput(indim,:));
    if maxVal - minVal > 0
      sampleinput(indim,:) = (sampleinput(indim,:) - minVal)/(maxVal - minVal);
    end
end

% normalize output to range [-0.5,0.5]
for outdim = 1:length(sampleout(:,1))
    maxVal = max(sampleout(outdim,:)); minVal = min(sampleout(outdim,:));
    if maxVal - minVal > 0
       sampleout(outdim,:) = (sampleout(outdim,:) - minVal)/(maxVal - minVal)-0.5;
    end
end

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

figure;
plot(x,y);
% plot(xi,yi,'r',x,y,'k');

% clear
% x=-2:0.4:2;
% y=[2.8 2.96 2.54 3.44 3.56 5.4 6.0 8.7 10.1 13.3 14.0];
% t=-2:0.01:2;
% nst=interp1(x,y,t,'nearest');
% figure(1)
% plot(x,y,'r*',t,nst)
% title('??????')
% lnr=interp1(x,y,t,'linear');
% figure(2)
% plot(x,y,'r*',t,lnr,'b:')
% title('????')
% spl=interp1(x,y,t,'spline');
% figure(3)
% plot(x,y,'r*',t,spl)
% title('????')
% cbc=interp1(x,y,t,'cubic');
% figure(4)
% plot(x,y,'r*',t,cbc,'k-')
% title('????') 