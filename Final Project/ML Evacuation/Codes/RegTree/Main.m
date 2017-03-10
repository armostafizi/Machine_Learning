clear;
clc;

data = csvread('data.csv');
[dataRows, dataCols] = size(data);

data = data(randperm(dataRows),:);

test = data(1:54,:);
train = data(55:end,:);

train_x = train(:,2:end);
train_y = train(:,1);

test_x = test(:,2:end);
test_y = test(:,1);

names = {'PedPer','PTau','PSig','MaxDSpeed','WSpeed','WSpeedVar'};
test_errors = [];
train_errors = [];

splits = [];
range = 2:500;
for i = range
    rtree = fitrtree(train_x,train_y,'MinParentSize',i,'ResponseName','MRate','PredictorNames',names);
    ch = rtree.Children;
    sz = size(ch);
    count = 0;
    for j = 1:sz(1)
        if ch(j,1) == 0 && ch(j,2) == 0
            count = count + 1;
        end
    end
    split = sz(1) - count;
    splits = [splits, split];

    py_test = predict(rtree, test_x);
    py_train = predict(rtree, train_x);

    test_error = test_y - py_test;
    train_error = train_y - py_train;

    test_error = sum(test_error .^ 2);
    train_error = sum(train_error .^ 2);

    test_errors = [test_errors, test_error];
    train_errors = [train_errors, train_error];

end

figure;
plot(splits, test_errors,'r-.');
xlabel('Number of Splits');
ylabel('Sum of Squared Errors')
title('Errors of Testing Data');

figure;
plot(splits, train_errors,'b-.');
xlabel('Number of Splits');
ylabel('Sum of Squared Errors')
title('Errors of Training Data');


rtree = fitrtree(train_x,train_y,'MinParentSize',13);
view(rtree, 'Mode','Graph')
py_test = predict(rtree, test_x);
py_train = predict(rtree, train_x);
test_error = test_y - py_test;
sse_test = sum(test_error .^ 2)
train_error = train_y - py_train;
sse_train = sum(train_error .^ 2)

figure;
plot(test_error, 'r-');
xlabel('Index of Testing Instance');
ylabel('Error')
axis([0 55 -50 50])
title('Errors of Testing Instances');

figure;
plot(train_error,'b-');
xlabel('Index of Training Instance');
ylabel('Error')
axis([0 490 -50 50])
title('Errors of Training Instances');