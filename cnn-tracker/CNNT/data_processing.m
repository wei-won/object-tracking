% data processing
load Droneview_res.mat;
load actualpos.mat;
pos1 = results.position1;
pos2 = results.position2;
pos3 = results.position3;
pos1 = pos1(2:end,:);
pos2 = pos2(2:end,:);
pos3 = pos3(2:end,:);

actualpos1 = actualpos(1:3:end,:);
actualpos2 = actualpos(2:3:end,:);
actualpos3 = actualpos(3:3:end,:);
est1 = [pos1(:,1) + pos1(:,3)/2,pos1(:,2) + pos1(:,4)/2  ];
est2 = [pos2(:,1) + pos2(:,3)/2,pos2(:,2) + pos2(:,4)/2  ];
est3 = [pos3(:,1) + pos3(:,3)/2,pos3(:,2) + pos3(:,4)/2  ];

res1 = actualpos1 - est1;
res2 = actualpos2 - est2;
res3 = actualpos3 - est3;

T = 1:78;
T= T(:);
error1 = cumsum(sqrt(sum(res1.^2,2)))./T;
error2 = cumsum(sqrt(sum(res2.^2,2)))./T;
error3 = cumsum(sqrt(sum(res3.^2,2)))./T;

 figure(2);
 clear title xlabel ylabel;
%title('Mean square error curves for three trailers');
plot(T,error1,'r--',T,error2,'g--',T,error3,'c--');
title('Mean square error curves for the three trailers');
xlabel('# frame');
ylabel('Mean square error');
legend('red-box trailer','green-box trailer','cyan-box trailer');
% hold off;
axis equal;
