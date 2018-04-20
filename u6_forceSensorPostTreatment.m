clc %Clear the MATLAB command window
clear %Clear the MATLAB variables

filename = 'dataForce.mat';

offset = 1.9559;

dataIn = F(:,2)- offset;
windowSize = 40;
dataOut = filter(ones(1,windowSize)/windowSize,1,dataIn);


figure(2)
plot(F(1:end,1), dataIn(1:end),'r');
hold on 
plot(F(1:end,1), dataOut(1:end),'g');

moyenne = mean(dataIn)
moyenne2 = mean(dataOut)
plot(F(:,1), ones(length(F),1)*moyenne,'r--');
plot(F(:,1), ones(length(F),1)*moyenne2,'g--');


%fc = 30;
%fs = 100;
%[b,a] = butter(6,fc/(fs/2));
%freqz(b,a)
%dataOut = filter(b,a,dataIn);



%offset du crochet +ceinture : 2.1064
% largeur de la fenêtre




