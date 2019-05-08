clear
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initializing %%%%%%%%%%%%%%%%%%%%

% Reading the files

%%%data = csvread('dataLinear.csv'); % Linear Data, comment or uncomment
data = csvread('dataNonLinear.csv'); % NonLinear Data, comment or uncomment
[dataRows, dataCols] = size(data);

data = data(randperm(dataRows),:);

% Adjusting features values to 0-1 range

mins = [];
ranges = [];
adjData = data;
for i = 1:dataCols
    mx = max(data(:,i));
    mn = min(data(:,i));
    mins = [mins, mn];
    ranges = [ranges, mx-mn];
    adjData(:,i)=( data(:,i) - mn ) / (mx - mn);
end

orig_test = data(1:54,:);
adj_test = adjData(1:54,:);
[ test_rows , test_cols ] = size(adj_test);
orig_train = data(55:end,:);
adj_train = adjData(55:end,:);
[ train_rows , train_cols ] = size(adj_train);


% Dividing parts
orig_train_x = orig_train(:,2:train_cols);
train_x = adj_train(:,2:train_cols);
ones = zeros(train_rows,1);
ones(:,1)=1;
orig_train_x = [ones, orig_train_x];
train_x = [ones, train_x];

orig_test_x = orig_test(:,2:test_cols);
test_x = adj_test(:,2:test_cols);
ones = zeros(test_rows,1);
ones(:,1)=1;
orig_test_x = [ones, orig_test_x];
test_x = [ones, test_x];

orig_train_y = orig_train(:,1);
train_y = adj_train(:,1);
orig_test_y = orig_test(:,1);
test_y = adj_test(:,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MAIN %%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%   Tuning alpha   %%%%%%%%%%%%%%%%
best_alphas = [];
figure;
magLLs = [];
wLLs = [];
for q = [1, 2, 4]
magnitudeList = [];
counts = [];
log_alphas = -6:0.25:0;
alphas = 10.^log_alphas;
wList = [];
for alpha = alphas
    [count,magnitudes,w] = BatchGradient(train_x,train_y,alpha,1,q);
    magnitudeList = [magnitudeList; magnitudes];
    wList = [wList; w];
    counts = [counts, count];
end


plot(log_alphas,counts,'-*');
hold on;


[mn ind] = min(counts);
magLLs = [magLLs; magnitudeList(ind,:)];
wLLs = [wLLs; wList(ind,:)];
best_alphas =  [best_alphas, alphas(ind)];

end

xlabel('Log(Learning Rate) - Alpha');
ylabel('Time to Convergence - # of Trials');
title('Time to Convergence vs. Log(Learning Rate)')


%%%%%%%%%%%%%%%%%%%%%%%%%%%  Tuning Lambda  %%%%%%%%%%%

SSEss_test = [];
SSEss_train = [];
best_lambdas = [];
inds = [];
i = 1;
for q = [1, 2, 4]
log_lambdas = -3:0.1:3;
lambdas = 10.^log_lambdas;
lambda_counts = [];
SSEs_test = [];
SSEs_train = [];
for lambda = lambdas
    [lambda_count,m,w] = BatchGradient(train_x,train_y,best_alphas(i),lambda,q);
    lambda_counts = [lambda_counts, lambda_count];
    [SSE_train, SSE_test] = SSE_Calculator(w,train_x,test_x,train_y,test_y);
    SSEs_test = [SSEs_test, SSE_test];
    SSEs_train = [SSEs_train, SSE_train];
end
i = i + 1;
SSEss_test = [SSEss_test; SSEs_test];
SSEss_train = [SSEss_train; SSEs_train];

[mn ind] = min(SSEs_test);
inds = [inds, ind];
best_lambdas = [best_lambdas, lambdas(ind)];
end

figure;
for i = 1:3
till = inds(i) + 5;
if till > 61
    till = 61;
end
till = 45;
plot(log_lambdas(1,1:till), SSEss_test(i,1:till),'-.');
hold on;
end
xlabel('Log(Regularization Coefficient) - Lambda');
ylabel('SSE');
title('SSE of TESTING data')

figure;
for i = 1:3
till = inds(i) + 5;
if till > 61
    till = 61;
end
till = 45;
plot(log_lambdas(1,1:till), SSEss_train(i,1:till),'-.');
hold on;
end

xlabel('Log(Regularization Coefficient) - Lambda');
ylabel('SSE');
title('SSE of TRAINING data');

%%%%%%%%%%%%%% Finding the real model

keepRanges = ranges;
keepMins =  mins;

i = 1;
ws = [];
ms = [];
for q = [1]
[c,m,w] = BatchGradient(train_x,train_y,best_alphas(i),best_lambdas(i),q);
ranges = keepRanges;
mins = keepMins;
ms = [ms; m];

w = w * ranges(1);
ranges(1) = 1;
w = w ./ ranges;

minMR = mins(1);
mins(1) = -1;
alire = w .* (mins * -1);
w(1) = sum(alire) + minMR;
ws = [ws; w];
i = i + 1;
end


figure;
plot((orig_train_x * transpose(w) - orig_train_y),'b-')
xlabel('Index of Training Instance');
ylabel('Error')
axis([0 490 -50 50])
title('Errors of Training Instances');


figure;
plot((orig_test_x * transpose(w) - orig_test_y),'r-')
xlabel('Index of Testing Instance');
ylabel('Error')
title('Errors of Testing Instances');
axis([0 55 -50 50])
