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

sizes = 3:30:63;

x = data_x';
t = data_y';

% Choose a Training Function
% For a list of all training functions type: help nntrain
% 'trainlm' is usually fastest.
% 'trainbr' takes longer but may be better for challenging problems.
% 'trainscg' uses less memory. NFTOOL falls back to this in low memory situations.
trainFcn = 'trainlm';  % Levenberg-Marquardt

performances = [];
trainPerformances = [];
valPerformances = [];
testPerformances = [];

for hiddenLayerSize = sizes
    pers = [];
    trains = [];
    vals = [];
    tests = [];
    for i = 1:5
        %hiddenLayerSize = 50;

        net = fitnet(hiddenLayerSize,trainFcn);

        % Choose Input and Output Pre/Post-Processing Functions
        % For a list of all processing functions type: help nnprocess
        net.input.processFcns = {'removeconstantrows','mapminmax'};
        net.output.processFcns = {'removeconstantrows','mapminmax'};

        % Setup Division of Data for Training, Validation, Testing
        % For a list of all data division functions type: help nndivide
        net.divideFcn = 'dividerand';  % Divide data randomly
        net.divideMode = 'sample';  % Divide up every sample
        net.divideParam.trainRatio = 80/100;
        net.divideParam.valRatio = 10/100;
        net.divideParam.testRatio = 10/100;

        % Choose a Performance Function
        % For a list of all performance functions type: help nnperformance
        % net.performFcn = 'mse';  % Mean squared error
        net.performFcn = 'mse';  % Sum squared error


        % Choose Plot Functions
        % For a list of all plot functions type: help nnplot
        net.plotFcns = {'plotperform','plottrainstate','ploterrhist', ...
          'plotregression', 'plotfit'};

        % Train the Network
        [net,tr] = train(net,x,t);

        % Test the Network
        y = net(x);
        e = gsubtract(t,y);
        performance = perform(net,t,y);


        pers = [pers, performance];

        % Recalculate Training, Validation and Test Performance
        trainTargets = t .* tr.trainMask{1};
        valTargets = t  .* tr.valMask{1};
        testTargets = t  .* tr.testMask{1};

        trainPerformance = perform(net,trainTargets,y);
        trains = [trains, trainPerformance];


        valPerformance = perform(net,valTargets,y);
        vals = [vals, valPerformance];

        testPerformance = perform(net,testTargets,y);
        tests = [tests, testPerformance];


    end

    performances = [performances, mean(pers)];
    trainPerformances = [trainPerformances, mean(trains)];
    valPerformances = [valPerformances, mean(vals)];
    testPerformances = [testPerformances, mean(tests)];


    %figure, plotperform(tr)

    %view(net)
    %figure, plottrainstate(tr)
    %figure, plotregression(t,y)
    %figure, ploterrhist(e)


end


figure;
plot(sizes,performances);
hold on;
plot(sizes,trainPerformances);
hold on;
plot(sizes,valPerformances);
hold on;
plot(sizes,testPerformances);
title('Perfromace Function vs. Hidden Layer Size');
xlabel('Number of Neurons');
ylabel ('Mean Standard Error');
legend('Total','Training','Validation','Testing');

% error = test_y - transpose(sim(net,transpose(test_x)));
% %plot(errors, '.')
% plot(sizes, errors);



