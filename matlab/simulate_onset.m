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

stop_time = 735;

% % Simulating three different values for stimulus strength
% delete(m1.Events);
% addevent(m1, 'time>=150', 'dc_stim=6000');
% addevent(m1, 'time>=157', 'dc_stim=0');
% sim_data_1 = model_sim(m1, stop_time);
% 
% delete(m1.Events);
% addevent(m1, 'time>=150', 'dc_stim=3000');
% addevent(m1, 'time>=157', 'dc_stim=0');
% sim_data_2 = model_sim(m1, stop_time);
% 
% delete(m1.Events);
% addevent(m1, 'time>=150', 'dc_stim=600');
% addevent(m1, 'time>=157', 'dc_stim=0');
% sim_data_3 = model_sim(m1, stop_time);

% Simulating three different values for stimulus duration
delete(m1.Events);
addevent(m1, 'time>=150', 'dc_stim=6000');
addevent(m1, 'time>=157', 'dc_stim=0');
sim_data_1 = model_sim(m1, stop_time);

delete(m1.Events);
addevent(m1, 'time>=150', 'dc_stim=6000');
addevent(m1, 'time>=154', 'dc_stim=0');
sim_data_2 = model_sim(m1, stop_time);

delete(m1.Events);
addevent(m1, 'time>=150', 'dc_stim=6000');
addevent(m1, 'time>=151', 'dc_stim=0');
sim_data_3 = model_sim(m1, stop_time);

% plotting SC, TA and D cells count here

species_to_plot = ["SC", "TA", "D"];

plot_index = [];
for i=1:length(species_to_plot)
    for j=1:length(m1.Species)
        if species_to_plot(i) == m1.Species(j).Name
            plot_index = [plot_index j];
            break;
        end
    end
end

fig = figure('Units','normalized','OuterPosition',[0 0 1 1],'Visible','off');    
set(fig,'defaultAxesColorOrder',[[0 0 0]; [1 0 0]]);
set(gca, 'FontName', 'Arial');
colours = ['k', 'r', 'b', 'm', 'g'];
% % drawing an arrow to mark the start and the end of the therapy
% annotation('textarrow',[0.25 0.25],[0.78 0.4],'LineWidth',4,'String', ...
%             ['          Stimulus' char(10) 'begins  '], 'FontSize', 32, ...
%             'HeadWidth', 30, 'HeadLength', 30);
        
% yyaxis right;
% bar(linspace(0,10,30), uv_protocol, 0.6, 'FaceColor', 'r');
% ylabel('J/cm^2');
% ylim([0 4.0]);
% 
% yyaxis left;
for i=1:length(plot_index)
    plot((sim_data_1.Time-143)/7, sim_data_1.Data(:, plot_index(i)), 'LineWidth', 6, 'LineStyle', '-', 'Color', colours(i));
    hold on;
end
%
for i=1:length(plot_index)
    plot((sim_data_2.Time-143)/7, sim_data_2.Data(:, plot_index(i)), 'LineWidth', 6, 'LineStyle', '-.', 'Color', colours(i));
    hold on;
end
%
for i=1:length(plot_index)
    plot((sim_data_3.Time-143)/7, sim_data_3.Data(:, plot_index(i)), 'LineWidth', 6, 'LineStyle', ':', 'Color', colours(i));
    hold on;
end

ylabel('cells/mm^2');

set(gca, 'FontSize', 48);
xlabel('Time (weeks)');
xlim([-0.5 10]);
% title(['Immune stimuli of different' char(10) 'strength for 7 days']);
title(['Immune stimuli of maximum strength' char(10) 'and different duration']);
legend(["SC", "TA", "D"]);

% annotation('textarrow',[0.32 0.35],[0.75 0.68],'LineWidth',4,'String', ...
%             "dc_{stim}=6000", 'FontSize', 40, ...
%             'HeadWidth', 36, 'HeadLength', 36, 'VerticalAlignment', 'baseline');
%         
% annotation('textarrow',[0.32 0.4],[0.62 0.55],'LineWidth',4,'String', ...
%             "dc_{stim}=3000", 'FontSize', 40, ...
%             'HeadWidth', 36, 'HeadLength', 36, 'VerticalAlignment', 'baseline');
%         
% annotation('textarrow',[0.3 0.37],[0.49 0.37],'LineWidth',4,'String', ...
%             "dc_{stim}=600", 'FontSize', 40, ...
%             'HeadWidth', 36, 'HeadLength', 36, 'VerticalAlignment', 'baseline');


annotation('textarrow',[0.32 0.35],[0.75 0.68],'LineWidth',4,'String', ...
            "\tau_{stim}=7 days", 'FontSize', 40, ...
            'HeadWidth', 36, 'HeadLength', 36, 'VerticalAlignment', 'baseline');
        
annotation('textarrow',[0.32 0.38],[0.62 0.55],'LineWidth',4,'String', ...
            "\tau_{stim}=4 days", 'FontSize', 40, ...
            'HeadWidth', 36, 'HeadLength', 36, 'VerticalAlignment', 'baseline');
        
annotation('textarrow',[0.3 0.37],[0.49 0.37],'LineWidth',4,'String', ...
            "\tau_{stim}=1 day", 'FontSize', 40, ...
            'HeadWidth', 36, 'HeadLength', 36, 'VerticalAlignment', 'baseline');

        
% saveas(fig, [work_dir 'onset_cells_big.png']);
saveas(fig, [work_dir 'onset_cells_big_2.png']);

% plotting DC and T here

species_to_plot = ["DC", "T"];

plot_index = [];
for i=1:length(species_to_plot)
    for j=1:length(m1.Species)
        if species_to_plot(i) == m1.Species(j).Name
            plot_index = [plot_index j];
            break;
        end
    end
end

fig = figure('Units','normalized','OuterPosition',[0 0 1 1],'Visible','off');    
set(fig,'defaultAxesColorOrder',[[0 0 0]; [1 0 0]]);
set(gca, 'FontName', 'Arial');
colours = ['k', 'r', 'b', 'm', 'g'];

% yyaxis right;
% bar(linspace(0,10,30), uv_protocol, 0.6, 'FaceColor', 'r');
% ylabel('J/cm^2');
% ylim([0 4.0]);
% 
% yyaxis left;
for i=1:length(plot_index)
    plot((sim_data_1.Time-143)/7, sim_data_1.Data(:, plot_index(i)), 'LineWidth', 6, 'LineStyle', '-', 'Color', colours(i));
    hold on;
end
%
for i=1:length(plot_index)
    plot((sim_data_2.Time-143)/7, sim_data_2.Data(:, plot_index(i)), 'LineWidth', 6, 'LineStyle', '-.', 'Color', colours(i));
    hold on;
end
%
for i=1:length(plot_index)
    plot((sim_data_3.Time-143)/7, sim_data_3.Data(:, plot_index(i)), 'LineWidth', 6, 'LineStyle', ':', 'Color', colours(i));
    hold on;
end
ylabel('cells/mm^2');

set(gca, 'FontSize', 48);
xlabel('Time (weeks)');
xlim([-0.5 10]);
legend(["DC", "T"]);

saveas(fig, [work_dir 'onset_cells_small.png']);
% saveas(fig, [work_dir 'onset_cells_small_2.png']);


species_to_plot = ["GF"];

plot_index = [];
for i=1:length(species_to_plot)
    for j=1:length(m1.Species)
        if species_to_plot(i) == m1.Species(j).Name
            plot_index = [plot_index j];
            break;
        end
    end
end

fig = figure('Units','normalized','OuterPosition',[0 0 1 1],'Visible','off');    
set(fig,'defaultAxesColorOrder',[[0 0 0]; [1 0 0]]);
set(gca, 'FontName', 'Arial');
colours = ['k', 'r', 'b', 'm', 'g'];

% yyaxis right;
% bar(linspace(0,10,30), uv_protocol, 0.6, 'FaceColor', 'r');
% ylabel('J/cm^2');
% ylim([0 4.0]);
% 
% yyaxis left;
for i=1:length(plot_index)
    plot((sim_data_1.Time-143)/7, sim_data_1.Data(:, plot_index(i)), 'LineWidth', 6, 'LineStyle', '-', 'Color', colours(i));
    hold on;
end
%
for i=1:length(plot_index)
    plot((sim_data_2.Time-143)/7, sim_data_2.Data(:, plot_index(i)), 'LineWidth', 6, 'LineStyle', '-.', 'Color', colours(i));
    hold on;
end
%
for i=1:length(plot_index)
    plot((sim_data_3.Time-143)/7, sim_data_3.Data(:, plot_index(i)), 'LineWidth', 6, 'LineStyle', ':', 'Color', colours(i));
    hold on;
end
ylabel('arbitrary');

set(gca, 'FontSize', 48);
xlabel('Time (weeks)');
xlim([-0.5 10]);
legend(["GF"]);

saveas(fig, [work_dir 'onset_gf.png']);
% saveas(fig, [work_dir 'onset_gf_2.png']);


% plotting cytokines here

species_to_plot = ["IL17", "IL23", "TNF"];

plot_index = [];
for i=1:length(species_to_plot)
    for j=1:length(m1.Species)
        if species_to_plot(i) == m1.Species(j).Name
            plot_index = [plot_index j];
            break;
        end
    end
end

fig = figure('Units','normalized','OuterPosition',[0 0 1 1],'Visible','off');    
set(fig,'defaultAxesColorOrder',[[0 0 0]; [1 0 0]]);
set(gca, 'FontName', 'Arial');
colours = ['k', 'r', 'b', 'm', 'g'];

for i=1:length(plot_index)
    plot((sim_data_1.Time-143)/7, sim_data_1.Data(:, plot_index(i)), 'LineWidth', 6, 'LineStyle', '-', 'Color', colours(i));
    hold on;
end
%
for i=1:length(plot_index)
    plot((sim_data_2.Time-143)/7, sim_data_2.Data(:, plot_index(i)), 'LineWidth', 6, 'LineStyle', '-.', 'Color', colours(i));
    hold on;
end
%
for i=1:length(plot_index)
    plot((sim_data_3.Time-143)/7, sim_data_3.Data(:, plot_index(i)), 'LineWidth', 6, 'LineStyle', ':', 'Color', colours(i));
    hold on;
end

set(gca, 'FontSize', 48);
xlabel('Time (weeks)');
ylabel('arbitrary');
xlim([-0.5 10]);
legend(["IL17", "IL23", "TNF"]);
        
saveas(fig, [work_dir 'onset_cyto.png']);
% saveas(fig, [work_dir 'onset_cyto_2.png']);


