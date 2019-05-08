function [sse_train,sse_test] = SSE_Calculator(w,train_x,test_x,train_y,test_y)
  
    sse_train = (( train_x * (transpose(w))) - train_y).^2;
    sse_train = sum(sse_train);
    
    sse_test = (( test_x * (transpose(w))) - test_y).^2;
    sse_test = sum(sse_test);
    
end
