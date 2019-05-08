clear;
clc;

data = csvread('data.csv');
[dataRows, dataCols] = size(data);

data = data(randperm(dataRows),:);

data_x = data(:, 2:end);
data_y = data(:, 1);

test = data(1:54, :);
test_x = test(:, 2:end);
test_y = test(:, 1);

trn = data(55:end, :);
train_x = trn(:, 2:end);
train_y = trn(:, 1);

x = train_x';
t = train_y';

% Choose a Training Function
% For a list of all training functions type: help nntrain
% 'trainlm' is usually fastest.
% 'trainbr' takes longer but may be better for challenging problems.
% 'trainscg' uses less memory. NFTOOL falls back to this in low memory situations.
trainFcn = 'trainlm';  % Levenberg-Marquardt

% Create a Fitting Network
hiddenLayerSize = 50;
net = fitnet(hiddenLayerSize,trainFcn);

% Setup Division of Data for Training, Validation, Testing
net.divideParam.trainRatio = 95/100;
net.divideParam.valRatio = 5/100;
net.divideParam.testRatio = 0/100;

% Train the Network
[net,tr] = train(net,x,t);

% Test the Network
y = net(x);
e = gsubtract(t,y);
performance = perform(net,t,y)

% View the Network
%view(net)

% Plots
% Uncomment these lines to enable various plots.
%figure, plotperform(tr)
%figure, plottrainstate(tr)
%figure, plotfit(net,x,t)
%figure, plotregression(t,y)
%figure, ploterrhist(e)

figure;
train_errors = train_y - transpose(sim(net,transpose(train_x)));
plot(train_errors, 'b-');
xlabel('Index of Training Instance');
ylabel('Error')
axis([0 490 -50 50])
title('Errors of Training Instances');

figure;
test_errors = test_y - transpose(sim(net,transpose(test_x)));
plot(test_errors, 'r-');
xlabel('Index of Testing Instance');
ylabel('Error')
axis([0 55 -50 50])
title('Errors of Testing Instances');
