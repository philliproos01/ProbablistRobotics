A = [1 1; 0 1];
B = 0; 

R = [0.25 0.5; 0.5 1];
C = [1 0];
Q = 8;

Past = R;

n = 3;
recursiveCovPredict(0, n, A, B, R, Past);

L = [41.25 12.5; 12.5 5] %result from recursiveCovPredict for t = 5
kalman = L * transpose(C) * (C * L * transpose(C) + Q)^-1

zt = 10;
state_estimate = [0; 0]
mu = state_estimate + kalman * (zt + C * kalman)




function recursiveCovPredict(i, n, A, B, R, Past)
    if i <= n
        Neq = (A * Past * transpose(A)) + R;
        fprintf('For t = %i\n', i+2)
        disp(Neq);
        recursiveCovPredict(i+1, n, A, B, R, Neq);
        if i == 3
            fprintf('GOOOOOOOO')
            L = Neq
        end
    end
end