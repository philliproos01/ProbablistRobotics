A = [-0.2 -0.1 0;1 -0.2 -0.1;1 0 -0.1];
B = [1;0;0]; 
C = eye(3);
sys_c = ss(A,B,C,0);

T1=1; 
Ad1 = expm(A*T1); 
Bd1 = inv(A)*(Ad1 - eye(3))*B;
sys_d1 = ss(Ad1,Bd1,C,0, T1);

Tf = 50;
step(sys_c,Tf), hold on, step(sys_d1,Tf)
