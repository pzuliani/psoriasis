% This script performs logistic regression for predicting PASI75, PASI90
% and PASI100 using patients therapy outcome at week 2 and at week 3
%
% Author: Fedor Shmarov


% importing the data from an XLSX file
data = readtable("../../data/data_matlab.xlsx");

% extracting only the patients whose IDs are in a particular range
data = data((data.ID > 0 & data.ID <= 100),:);

pasi_outcome_w2 = (1 - data.PASI_END_WEEK_2./data.PASI_PRE_TREATMENT)*100;
pasi_outcome_w3 = (1 - data.PASI_END_WEEK_3./data.PASI_PRE_TREATMENT)*100;

pasi_75_end = (1 - data.PASI_END_TREATMENT./data.PASI_PRE_TREATMENT) >= 0.75;
pasi_90_end = (1 - data.PASI_END_TREATMENT./data.PASI_PRE_TREATMENT) >= 0.9;
pasi_100_end = (1 - data.PASI_END_TREATMENT./data.PASI_PRE_TREATMENT) >= 1;

% predicting outcomes at week 2 here
figure;
[X, Y, T, AUC1] = plot_roc(pasi_outcome_w2, pasi_75_end);
plot(X, Y, 'LineWidth', 2);
hold on;
[X, Y, T, AUC2] = plot_roc(pasi_outcome_w2, pasi_90_end);
plot(X, Y, 'LineWidth', 2);
hold on;
[X, Y, T, AUC3] = plot_roc(pasi_outcome_w2, pasi_100_end);
plot(X, Y, 'LineWidth', 2);
hold on;
plot([0 1], [0 1], 'LineWidth', 1, 'LineStyle', '--');
xlabel("False positive rate");
ylabel("True positive rate");
title(['Predicting therapy outcomes' char(10) 'at the end of week 2']);
legend([string("ROC for PASI75 (AUC="+num2str(AUC1)+")"), 
            string("ROC for PASI90 (AUC="+num2str(AUC2)+")"), 
                string("ROC for PASI100 (AUC="+num2str(AUC3)+")")], "Location", "southeast");
set(gca, "FontSize", 18);

% predicting outcomes at week 3 here
figure;
[X, Y, T, AUC1] = plot_roc(pasi_outcome_w3, pasi_75_end);
plot(X, Y, 'LineWidth', 2);
hold on;
[X, Y, T, AUC2] = plot_roc(pasi_outcome_w3, pasi_90_end);
plot(X, Y, 'LineWidth', 2);
hold on;
[X, Y, T, AUC3] = plot_roc(pasi_outcome_w3, pasi_100_end);
plot(X, Y, 'LineWidth', 2);
hold on;
plot([0 1], [0 1], 'LineWidth', 1, 'LineStyle', '--');
xlabel("False positive rate");
ylabel("True positive rate");
title(['Predicting therapy outcomes' char(10) 'at the end of week 3']);
legend([string("ROC for PASI75 (AUC="+num2str(AUC1)+")"), 
            string("ROC for PASI90 (AUC="+num2str(AUC2)+")"), 
                string("ROC for PASI100 (AUC="+num2str(AUC3)+")")], "Location", "southeast");
set(gca, "FontSize", 18);




function [X, Y, T, AUC] = plot_roc(x, y)
    mdl = fitglm(x, y, 'Distribution', 'binomial')
    [X, Y, T, AUC] = perfcurve(y, mdl.Fitted.Probability, 1);
end




