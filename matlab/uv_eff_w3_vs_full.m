data = readtable("../../data/data_matlab.xlsx");

data = data((data.ID > 0 & data.ID <= 100),:);

lm = fitlm(data.UV_EFF_W_3, data.UV_EFF_W_13);

figure;
plot(lm);
title(['Predicting UVB sensitivity after' char(10) '3 weeks of UVB phototherapy']);
xlabel("UVB sensitivity at week 3");
ylabel(['UVB sensitivity for full PASI trajectory']);
set(gca, 'FontSize', 16);