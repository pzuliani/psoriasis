% Trying developing a simple 2-equation model.
%
% Author: Fedor Shmarov

% proliferative keratinocytes per mm^2 of healthy epidermis
K_H = 30000;
% psoriatic epidermis is 3 times thicker
K_P = 3*K_H;
% transition state is at 10% of the thickness difference between
% psoriatic and healthy epidermis
K_T = K_H + 0.1*(K_P-K_H);

% number of immune cells per mm^2 in healthy epidermis
T_H = 1500;

% turnover time of healthy proliferative compartment in days
t_H = 21;
% epidermal turnover time for psoriatic epidermis is 3 timesget
% smaller than for the healthy one
t_P = t_H/3;

% immune cells infiltration (assumed value)
k4 = 100;

k2 = (K_H/t_H)/K_H^2;
k1 = k2*(K_H/T_H);

kp = K_H*K_T+K_T*K_P+K_H*K_P;
k3 = (k4*kp*k1/k2)/(K_H*K_T*K_P);
kvm = (K_H+K_T+K_P)*k3*k2/k1-k4;
n = 2;

syms K;
eqn = kvm*K^n/(kp+K^n)+k4-k3*(k2/k1)*K == 0;
sol = vpasolve(eqn, K)

K = 0:100:300000;
fun1 = kvm*K.^n./(kp+K.^n)+k4;
fun2 = k3*(k2/k1)*K;
plot(K, fun1, K, fun2);

return;

% kvm = 5.5;
% kp = 1e19;
% k4 = 1.8;
% n = 4;

% kvm = 70;
% k4 = 20;
% n = 4;
% kp = 6.75e4^n;
% 
% k3 = 0.014;
% K = 0:100:300000;
% 
% fun3 = kvm*K.^n./(kp+K.^n)+k4;
% fun4 = k3*(k2/k1)*K;
% % plot(K, fun1, K, fun2);
% plot(K, fun3, K, fun4);
% 
% syms K;
% eqn = kvm*K^n/(kp+K^n)+k4-k3*(k2/k1)*K == 0;
% sol = vpasolve(eqn, K)
