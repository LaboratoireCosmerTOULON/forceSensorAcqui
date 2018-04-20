clc %Clear the MATLAB command window
clear %Clear the MATLAB variables

%filename = 'dataForce.mat';


function [F offset] = computeOffset(filename)
    file=open(filename);    
    F = file.F;
    offset = mean(dataIn)
end

filename0    = 'dataForce-0.mat';
filename2204 = 'dataForce-2204.mat';
filename4231 = 'dataForce-4231.mat';
filename5191 = 'dataForce-5191.mat';
filename6193 = 'dataForce-6193.mat';
filename8216 = 'dataForce-8216.mat';

values = [];

[F0 o2204] = computeOffset(filename2204);
values = [1 o2204 2204];

[F2204 o2204] = computeOffset(filename2204);
values = [1 o2204 2204];

[F4231 o4231] = computeOffset(filename4231);
values = [1 o2204 2204];

[F5191 o5191] = computeOffset(filename5191);
values = [1 o2204 2204];

[F6193 o6193] = computeOffset(filename6193);
values = [1 o2204 2204];



%fc = 30;
%fs = 100;
%[b,a] = butter(6,fc/(fs/2));
%freqz(b,a)
%dataOut = filter(b,a,dataIn);

%dataIn = F(:,2)-    1.9559;

%offset du crochet +ceinture : 2.1064
% largeur de la fenêtre
%windowSize = 40;
%dataOut = filter(ones(1,windowSize)/windowSize,1,dataIn);

%figure(2)
%plot(F(1:end,1), dataIn(1:end),'r');
%hold on 
%plot(F(1:end,1), dataOut(1:end),'g');

%moyenne = mean(dataIn)
%moyenne2 = mean(dataOut)
%plot(F(:,1), ones(length(F),1)*moyenne,'r--');
%plot(F(:,1), ones(length(F),1)*moyenne2,'g--');


