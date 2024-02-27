A = [1 1; 0 1];
B = 0; 

R = [1 0.5; 0.5 0.25];


Past = R

n = 3;
recursiveCovPredict(0, n, A, B, R, Past);

function recursiveCovPredict(i, n, A, B, R, Past)
    if i <= n
        Neq = (A * Past * transpose(A)) + R
        %disp(i);
        recursiveCovPredict(i+1, n, A, B, R, Neq);
    end
end
