% This script demonstrates an example of manual estimation of the model's
% parameters using the intersection of two functions ("fun1" and "fun2") 
% for modelling 3 real positive steady states. The proposed set of 
% parameter values is then used for numerical solving of the equation 
% "fun1 - fun2 = 0" to confirm that they generate the required steady states.
%
% Author: Fedor Shmarov

% parameter values
t_act = 1880;
t_vm = 6000;
t_kp = 3e12;
t20 = 1.5;
n = 4;
il2 = 1.0;
il20 = 36.5;
k2 = 1.0;
k20 = 2.7e-6;
gf2 = 1.0;
gf20 = 36.5;
d20 = 5.05e-7;

% solving the equation "fun1 - fun2 = 0" graphically
GF = 0:0.1:4000;
fun1 = t_vm*GF.^n./(t_kp+GF.^n) + t_act;
fun2 = t20*(il20/il2)*sqrt((k20/k2))*(gf20/gf2)*GF;
plot(GF, fun1, GF, fun2, 'LineWidth', 2);

% solving the equation "fun1 - fun2 = 0" numerically
syms GF;
eqn = t_vm*GF^n/(t_kp+GF^n) + t_act - t20*(il20/il2)*(gf20/(sc2gf*sqrt(sc2/sc2ta)+ta2gf*sqrt((ta2+sc2)/ta2d)))*GF == 0;
sol = vpasolve(eqn, GF);



