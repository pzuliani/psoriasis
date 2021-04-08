% This script simulates different rates of psoriasis onset and
% generates Figure 3 of our ODE modelling paper.
%
% Author: Fedor Shmarov


% SBML import of the model
m1 = sbmlimport('../models/psor_v8_4.xml');

m1 = sbml_set_parameter_value(m1, "uv_eff", 0.08);

work_dir = '../../img/ode-v8-4/paper/';

totC_p = 266011.98;
totC_h = 79828.07;

stop_time = 10000;

% Simulating one onset scenario
delete(m1.Events);
addevent(m1, 'time>=150', 'dc_stim=2000');
addevent(m1, 'time>=154', 'dc_stim=0');
sim_data_1 = model_sim(m1, stop_time);

% plotting SC, TA and D cells count here

species_to_plot = ["totC", "D", "TA", "SC", "T", "DC", "GF", "IL23", "IL17", "TNF"];

plot_index = [];
for i=1:length(species_to_plot)
    for j=1:length(m1.Species)
        if species_to_plot(i) == m1.Species(j).Name
            plot_index = [plot_index j];
            break;
        end
    end
end

fig = figure('Units','normalized','OuterPosition',[0 0 0.2 1],'Visible','off');    
set(fig,'defaultAxesColorOrder',[[0 0 0]; [255/255 20/255 147/255]]);
set(gca, 'FontName', 'Arial');
% col = ['k', 'r', 'b', 'm', 'g', 'c'];
col = lines(10);

yyaxis right;
% ax = gca;
% ax.YAxis(2).Exponent = 3;
fill([1 1 1+4/7 1+4/7],[0 2000 2000 0], [255/255 20/255 147/255], 'facealpha', 0.5);
hold on;
ylabel('Immune stimulus (arbitrary)');
ylim([0 10000]);
% legend("Immune", 'Location', 'southeast');

yyaxis left;
for i=1:length(plot_index)-4
    plot((sim_data_1.Time-143)/7, sim_data_1.Data(:, plot_index(i)), 'LineWidth', 6, 'LineStyle', '-', 'Marker', 'none', 'Color', col(i,:));
    hold on;
end

for i=length(plot_index)-3:length(plot_index)-1
    plot((sim_data_1.Time-143)/7, sim_data_1.Data(:, plot_index(i)), 'LineWidth', 6, 'LineStyle', ':', 'Marker', 'none', 'Color', col(i,:));
    hold on;
end
i = length(plot_index);
plot((sim_data_1.Time-143)/7, sim_data_1.Data(:, plot_index(i))*0.9, 'LineWidth', 6, 'LineStyle', ':', 'Marker', 'none', 'Color', col(i,:));
hold on;
% line(NaN,NaN,'LineWidth',8,'LineStyle','none','Marker','s','MarkerEdgeColor', 'black', 'MarkerFaceColor', [255/255 20/255 147/255], 'MarkerSize', 40);
fill([NaN NaN NaN NaN],[NaN NaN NaN NaN], [255/255 20/255 147/255], 'facealpha', 0.5, 'LineStyle', '-');
hold on;

set(gca, 'FontSize', 32);
set(gca, 'YScale', 'log');
set(gca, 'XScale', 'log');
xlabel('Time (weeks)');
ylabel('Model species');
xlim([0 1500]);
ylim([10 5*10^5]);
legend(["totC (mm^{-2})", "D (mm^{-2})", "TA (mm^{-2})", "SC (mm^{-2})", "T (mm^{-2})", "DC (mm^{-2})", "GF (arb.)", "IL23 (arb.)", "IL17/22 (arb.)", "TNF (arb.)", ['Immune' char(10) 'stimulus']]);

title("Slow psoriasis onset");

saveas(fig, [work_dir 'log_onset_cells_2.svg']);
saveas(fig, [work_dir 'log_onset_cells_2.png']);


