clc;

A = [1 1; 0 1];
B = [0.5 1]'; 

noisecov = [0.25 0.5; 0.5 1];
VelPos = [5; 1]
%input = 1 + normrnd(0, noisecov);
input = normrnd(0, 1);
distribution = 1 + input;
%P2 = [2.5 2; 2 2];
%P3 = [8.75 4; 4 3];
%P4 = [21 8; 8 4];
%P5 = [41.2500 12.5000; 12.5000 5.0];

Past = noisecov;

n = 3;

fail = [];

Presolution = A * VelPos

Neq = (A * VelPos) + (B*distribution)
%recursiveCovPredict(0, n, A, B, R, Past);

