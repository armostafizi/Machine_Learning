function [count,gr_mags,w] = BatchGradient(train_x,train_y,alpha,lambda, q)
s = size(train_x);
w=zeros(1,s(2));

gr_mags = [];
count = 0;
gr_mag = 10;
while gr_mag > 0.0001 && count < 100000
    
    %Gr_mag
    
    Gr = (( train_x * (transpose(w))) - train_y);
    Gr = bsxfun(@times,Gr,train_x);
    Gr = sum(Gr);
    Gr = Gr + ((lambda * q / 2) * (w.^(q-1)));
    % .^(q-1)
    w = w - (alpha * Gr);
    count = count + 1;
    gr_mag = norm(Gr);
    gr_mags = [gr_mags, gr_mag];
    
    if gr_mag > 1.0e+300
        count = 100000;
    end
end

Nans = 100000 - length(gr_mags);

for i=1:Nans
    gr_mags = [gr_mags, NaN];
end
