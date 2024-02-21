A = [1 1; 0 1];
B = 0; 
%Past = [0 0; 0 0]
R = [1 0.5; 0.5 0.25];
Eq = A * Past * transpose(A) + R


%C = [0 0 1]%eye(3);
%sys = ss(A,B,C,0);

%sys1 = ss2tf(A,B,C,D)
%step(sys)%, hold on, step(sys_d1,Tf)
%impulse(sys)
A = [1 2; 0 1];
B = 0; 
Past = Eq
R = [0.25 0.5; 0.5 1];
Eq = A * Past * transpose(A) + R

A = [1 1; 0 1];
B = 0; 
Past = Eq
R = [1 0.5; 0.5 0.25];
Eq = A * Past * transpose(A) + R
