% This script computes the steady states of the ODE model psor.v8.4 and 
% outputs only the ones where all solutions are real positive numbers.
% Also it generates two figures () and stores them in the directory
% specified in the "work_dir" variable
%
% Author: Fedor Shmarov


% declaring species of the model as symbolic variabels 
syms IL17 T GF D A R SC TA AdaT AdaSQ TNF DC IL23 UstSQ UstT

% the system of equations defining the steady states of the ODE model
% psor.v8.4, obtained from the script "parse_equations.m"
eqn = [ 
 1/ 1*((  0.5*T) - (  36.5*IL17))==0;
 1/ 1*((  55*IL23) - (  1.51*T) - (  0* 0.16*(T- 1556.1)+ 0.0036*T))==0;
 1/ 1*(-(  36.5*GF) + (  1*SC) + (  1*TA))==0;
 1/ 1*(-(  5.05e-07*power(D,2)) + (  0.0018063*TA*(IL17+TNF)) - (  0.0036*D) - (  0.0047529*D))==0;
 1/ 1*((  0* 0.16*(T- 1556.1)+ 0.0036*T) - (  36*A) + ( (1- 0)* 0* 0.16*(SC- 3947.2)+ 0.0036*SC) + ( (1- 0)* 0* 0.16*(TA- 22224)+ 0.0036*TA) + (  0* 0.16*(DC- 1563.1)+ 0.0036*DC) + (  0.0036*D))==0;
 1/ 1*(-(  6e-07*power(R,2)) + (  0* 0* 0.16*(TA- 22224)) + (  0* 0* 0.16*(SC- 3947.2)))==0;
 1/ 1*(-(  1.8135e-05*power(SC,2)) + (  0.0017635*(IL17+TNF)*SC) - ( (1- 0)* 0* 0.16*(SC- 3947.2)+ 0.0036*SC) - (  0* 0* 0.16*(SC- 3947.2)))==0;
 1/ 1*(-(  3.7321e-06*power(TA,2)) + (  0.0017562*(IL17+TNF)*TA) - ( (1- 0)* 0* 0.16*(TA- 22224)+ 0.0036*TA) - (  0* 0* 0.16*(TA- 22224)) + (  0.0015415*SC*(IL17+TNF)))==0;
 1/ 1*(-(  0.1*AdaT) + (  0.05*AdaSQ))==0;
 1/ 1*(-(  0.05*AdaSQ))==0;
 1/ 1*(-(  36.5*TNF) + (  0.5*T))==0;
 1/ 1*((  6000*power(GF, 4)/( 3e+12+power(GF, 4))) - (  1.51*DC) + (  1880+ 0) - (  0* 0.16*(DC- 1563.1)+ 0.0036*DC))==0;
 1/ 1*(-(  36.5*IL23) + (  1*DC))==0;
 1/ 1*(-(  0.02*UstSQ))==0;
 1/ 1*((  0.02*UstSQ) - (  0.5*UstT))==0;
        ];
    
% using numerical solver to solve the system of equations above
sol = vpasolve(eqn, [IL17 T GF D A R SC TA AdaT AdaSQ TNF DC IL23 UstSQ UstT]);
% sol = solve(eqn, [IL17 T GF D A R SC TA AdaT AdaSQ TNF DC IL23 UstSQ UstT]);

% vectors holding the values of different cell counts ("cell_count") and 
% their propostions ("prop") in different steady states
cell_count = [];
prop = [];

% iterating through the solutions of the system of equations above and
% displaying only the ones where all variables take real positive values
for i = 1:length(sol.A)
    if (sol.IL17(i)>0 && isreal(sol.IL17(i)) && ... 
            sol.IL23(i)>0 && isreal(sol.IL23(i)) && ... 
            sol.TNF(i)>0 && isreal(sol.TNF(i)) && ... 
            sol.GF(i)>0 && isreal(sol.GF(i)) && ...    
            sol.DC(i)>0 && isreal(sol.DC(i)) && ... 
            sol.T(i)>0 && isreal(sol.T(i)) && ...
            sol.D(i)>0 && isreal(sol.D(i)) && ...
            sol.A(i)>0 && isreal(sol.A(i)) && ...
            sol.SC(i)>0 && isreal(sol.SC(i)) && ...
            sol.TA(i)>0 && isreal(sol.TA(i)))
%     if (sol.GF(i)>0 && isreal(sol.GF(i)))
        disp("-----");
        disp(['IL17 = ' string(sol.IL17(i))]);
        disp(['T = ' string(sol.T(i))]);
        disp([num2str(i) "GF = " string(sol.GF(i))]);
        disp(['D = ' string(sol.D(i))]);
        disp(['R = ' string(sol.R(i))]);
        disp(['SC = ' string(sol.SC(i))]);
        disp(['TA = ' string(sol.TA(i))]);
        disp(['A = ' string(sol.A(i))]);
        disp(['TNF = ' string(sol.TNF(i))]);
        disp(['DC = ' string(sol.DC(i))]);
        disp(['IL23 = ' string(sol.IL23(i))]);
        cell_count = [cell_count; sol.T(i) sol.DC(i) sol.SC(i) sol.TA(i) sol.D(i)];
        tot = sol.T(i) + sol.DC(i) + sol.SC(i) + sol.TA(i) + sol.D(i);
        prop = [prop; sol.T(i)/tot sol.DC(i)/tot sol.SC(i)/tot sol.TA(i)/tot sol.D(i)/tot];
    end
end

% path to the directory where the generated figures will be saved
work_dir = '../../img/ode-v8-4/paper';

% generating a stacked bar plot for the cell counts in the obtained steady
% states
fig = figure('Units','normalized','OuterPosition',[0 0 0.2 1],'Visible','off');
set(gca, 'FontName', 'Arial');
bar(cell_count, 'stacked');
hold on;
set(gca,'FontSize',30);
legend(["T" "DC" "SC" "TA" "D"]);
ylabel("Cells/mm^2");
% xlabel("Model steady state");
ylim([0 270000]);
xticklabels(["Psoriatic" "Transition" "Healthy"]);
title("Cell species densities", 'FontSize', 40);

% saving the image as PNG in the "word_dir" directory
saveas(fig, [work_dir '/epi-comp.png']);

% generating a stacked bar plot for the proportions of different cell types
% in the obtained steady states
fig = figure('Units','normalized','OuterPosition',[0 0 0.2 1],'Visible','off');
bar(100*prop, 'stacked');
hold on;
set(gca,'FontSize',30);
% ylabel("proportion");
% xlabel("Model steady state");
legend(["T" "DC" "SC" "TA" "D"]);
ylabel("Percentage (%)");
xticklabels(["Psoriatic" "Transition" "Healthy"]);
title("Cell species proportions", 'FontSize', 40);


% saving the image as PNG in the "word_dir" directory
saveas(fig, [work_dir '/epi-comp-prop.png']);













