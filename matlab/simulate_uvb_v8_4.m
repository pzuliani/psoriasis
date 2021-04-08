% This script generates Figures 4 and 5 for our ODE modelling paper.
%
% Author: Fedor Shmarov

% SBML import of the model
m1 = sbmlimport('../models/psor_v8_4.xml');

m1 = sbml_set_parameter_value(m1, "uv_eff", 0.08);

time_doses = [];
cur_doses_time = [0 2 4];

for i=1:10
    time_doses = [time_doses cur_doses_time];
    cur_doses_time = cur_doses_time + 7;
end

time_doses = time_doses + 70;

        
uv_protocol = [0.7 0.7 0.98 0.98 1.323 1.323 1.72 1.72 2.15 2.15 ...
                2.58 2.58 2.967 2.967 3.264 3.264 3.427 3.427 3.427 3.427 ...
                3.427 3.427 3.427 3.427 3.427 3.427 3.427 3.427 3.427 3.427];

work_dir = '../../img/ode-v8-4/paper/';

%% plotting UVB protocol here
fig = figure('Units','normalized','OuterPosition',[0 0 0.4 0.75],'Visible','off');    
set(fig,'defaultAxesColorOrder',[[0 0 0]; [1 0 0]]);
set(gca, 'FontName', 'Arial');

bar(time_doses/7+0.08, uv_protocol, 0.5, 'FaceColor', 'r');
% stairs(time_doses/7, uv_protocol, 'LineWidth', 8, 'Color', 'r');

hold on;
set(gca, 'FontSize', 48);
xlabel('Time (weeks)');
ylabel('J/cm^2');
ylim([0 3.5]);
xlim([-0.5 30]);
ytickformat('%.1f');
% legend(['UVB' char(10) 'dose']);
legend(['UVB dose'], 'Location', 'northeast');
title("UVB phototherapy regime");
saveas(fig, [work_dir 'uv_protocol.png']);

%% plotting cells species
delete(m1.Events);
addevent(m1, 'time>=150', 'dc_stim=10000');
addevent(m1, 'time>=154', 'dc_stim=0');

% active apoptosis pariod in days
a_time = 0.99999;

for i=1:30
    addevent(m1, ['time>' num2str(time_doses(i)+300)], ['uv_dose=' num2str(uv_protocol(i))]);
    addevent(m1, ['time>=' num2str(time_doses(i)+a_time+300)], 'uv_dose=0');
end

stop_time = 735;
sim_data = model_sim(m1, stop_time);
    
species_to_plot = ["totC", "SC", "TA", "D", "T", "DC"];

plot_index = [];
for i=1:length(species_to_plot)
    for j=1:length(m1.Species)
        if species_to_plot(i) == m1.Species(j).Name
            plot_index = [plot_index j];
            break;
        end
    end
end

fig = figure('Units','normalized','OuterPosition',[0 0 0.4 1.0],'Visible','off');    
set(fig,'defaultAxesColorOrder',[[0 0 0]; [1 0 0]]);
set(gca, 'FontName', 'Arial');
% colours = ['k', 'r', 'b', 'm', 'g'];
colours = lines(20);
% % drawing an arrow to mark the start and the end of the therapy
% annotation('textarrow',[0.15 0.15],[0.63 0.78],'LineWidth',4,'String', ...
%             ['          Therapy' char(10) 'begins  '], 'FontSize', 40, ...
%             'HeadWidth', 36, 'HeadLength', 36);
%         
% annotation('textarrow',[0.53 0.53],[0.55 0.4],'LineWidth',4,'String', ...
%             ['     Therapy' char(10) 'ends   '], 'FontSize', 40, ...
%             'HeadWidth', 36, 'HeadLength', 36);        

% yyaxis right;
% bar(linspace(0,10,30), uv_protocol, 0.6, 'FaceColor', 'r');
% ylabel('J/cm^2');
% ylim([0 4.0]);
% 
% yyaxis left;
for i=1:length(plot_index)
    plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(i)), 'LineWidth', 6, 'LineStyle', '-', 'Color', colours(i,:));
    hold on;
end
ylabel('Cells/mm^2');
ytickformat('%.1f');
set(gca, 'FontSize', 48);
xlabel('Time (weeks)');
xlim([-0.5 30]);
ylim([10^3 5*10^5]);
set(gca, 'YScale', 'log');

legend(species_to_plot);
% legend(["totC (mm^{-2})", "SC (mm^{-2})", "TA (mm^{-2})", "D (mm^{-2})", "T (mm^{-2})", "DC (mm^{-2})", "IL17 (arb.)", "IL23 (arb.)", "GF (arb.)", "TNF (arb.)"])
title("Cells dynamics during UVB phototherapy");
saveas(fig, [work_dir 'uv_cells.png']);

%% plotting cytokines
species_to_plot = ["IL17", "IL23", "TNF", "GF"];

plot_index = [];
for i=1:length(species_to_plot)
    for j=1:length(m1.Species)
        if species_to_plot(i) == m1.Species(j).Name
            plot_index = [plot_index j];
            break;
        end
    end
end

fig = figure('Units','normalized','OuterPosition',[0 0 0.4 1],'Visible','off');    
set(fig,'defaultAxesColorOrder',[[0 0 0]; [1 0 0]]);
set(gca, 'FontName', 'Arial');
% colours = ['k', 'r', 'b', 'm', 'g'];
colours = lines(20);
% annotation('textarrow',[0.15 0.15],[0.63 0.78],'LineWidth',4,'String', ...
%             ['          Therapy' char(10) 'begins  '], 'FontSize', 40, ...
%             'HeadWidth', 36, 'HeadLength', 36);
%         
% annotation('textarrow',[0.53 0.53],[0.55 0.4],'LineWidth',4,'String', ...
%             ['     Therapy' char(10) 'ends   '], 'FontSize', 40, ...
%             'HeadWidth', 36, 'HeadLength', 36);   

for i=1:length(plot_index)
    plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(i)), 'LineWidth', 6, 'LineStyle', '-', 'Color', colours(i,:));
    hold on;
end

set(gca, 'FontSize', 48);
xlabel('Time (weeks)');
ylabel('Arbitrary');
xlim([-0.5 30]);
ylim([10 5*10^3]);
ax = gca;
ax.YAxis.Exponent = 2;
ytickformat('%.1f');
%legend(species_to_plot);
legend(["IL17/22", "IL23", "TNF", "GF"]);
set(gca, 'YScale', 'log');
title("Cytokines dynamics during UVB phototherapy");
saveas(fig, [work_dir 'uv_cyto.png']);

%% plotting rate of apoptosis per 1000 cells
species_to_plot = ["A_per_1000"];

plot_index = [];
for i=1:length(species_to_plot)
    for j=1:length(m1.Species)
        if species_to_plot(i) == m1.Species(j).Name
            plot_index = [plot_index j];
            break;
        end
    end
end

fig = figure('Units','normalized','OuterPosition',[0 0 0.4 0.75],'Visible','off');    
set(fig,'defaultAxesColorOrder',[[0 0 0]; [1 0 0]]);
set(gca, 'FontName', 'Arial');
colours = ['k', 'r', 'b', 'm', 'g'];
% % drawing an arrow to mark the start and the end of the therapy
% annotation('textarrow',[0.17 0.17],[0.76 0.63],'LineWidth',4,'String', ...
%             ['          Therapy' char(10) 'begins  '], 'FontSize', 40, ...
%             'HeadWidth', 36, 'HeadLength', 36);
%         
% annotation('textarrow',[0.53 0.53],[0.55 0.4],'LineWidth',4,'String', ...
%             ['     Therapy' char(10) 'ends   '], 'FontSize', 40, ...
%             'HeadWidth', 36, 'HeadLength', 36);  

for i=1:length(plot_index)
    plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(i)), 'LineWidth', 6, 'LineStyle', '-', 'Color', colours(i));
    hold on;
end

set(gca, 'FontSize', 48);
xlabel('Time (weeks)');
% ylabel(char(8240));
ylabel(['Apoptotic' char(10) 'cells per 1000']);
ytickformat('%.1f');
xlim([-0.5 30]);
ylim([0 1.2]);
% legend(['A'], 'Location', 'northeast');
title("UVB-induced apoptosis");
saveas(fig, [work_dir 'uv_a_per_1000.png']);

%% two simulations with different number of doses
delete(m1.Events);
addevent(m1, 'time>=150', 'dc_stim=10000');
addevent(m1, 'time>=154', 'dc_stim=0');

m1 = sbml_set_parameter_value(m1, "uv_eff", 0.05);

time_doses = [];
cur_doses_time = [0 2 4];
% cur_doses_time = [0 1 2 3 4];
for i=1:10
    time_doses = [time_doses cur_doses_time];
    cur_doses_time = cur_doses_time + 7;
end

time_doses = time_doses + 7;

% active apoptosis pariod in days
a_time = 0.99999;

for i=1:30
    addevent(m1, ['time>' num2str(time_doses(i)+300)], ['uv_dose=' num2str(uv_protocol(i))]);
    addevent(m1, ['time>=' num2str(time_doses(i)+a_time+300)], 'uv_dose=0');
end

stop_time = 10000;
sim_data = model_sim(m1, stop_time);
    

species_to_plot = ["totC", "SC", "TA", "D", "DC", "T"];

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
set(fig,'defaultAxesColorOrder',[[0 0 0]; [1 0 0]]);
set(gca, 'FontName', 'Arial');
% colours = ['k', 'r', 'b', 'm', 'g'];
colours = lines(20);
% annotation('textarrow',[0.15 0.15],[0.69 0.79],'LineWidth',4,'String', ...
%             ['           Therapies' char(10) 'begin      '], 'FontSize', 40, ...
%             'HeadWidth', 36, 'HeadLength', 36);
% annotation('textarrow',[0.38 0.38],[0.74 0.52],'LineWidth',4,'String', ...
%             ['     18-dose therapy ends   '], 'FontSize', 40, ...
%             'HeadWidth', 36, 'HeadLength', 36);
% annotation('textarrow',[0.39 0.39],[0.4 0.48],'LineWidth',4,'String', ...
%             ['               19-dose therapy ends   '], 'FontSize', 40, ...
%             'HeadWidth', 36, 'HeadLength', 36);   

% yyaxis right;
% bar(linspace(0,10,30), uv_protocol, 0.6, 'FaceColor', 'r');
% ylabel('J/cm^2');
% ylim([0 4.0]);
% 
% yyaxis left;
for i=1:length(plot_index)
    plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(i)), 'LineWidth', 6, 'LineStyle', '-', 'Color', colours(i,:));
    hold on;
end
fill([1 1 1+70/7 1+70/7],[1e3 1.5*1e3 1.5*1e3 1e3], [0/255 191/255 147/255], 'facealpha', 0.5);
line(NaN,NaN,'LineWidth',8,'LineStyle','none','Marker','x','MarkerSize', 40, 'Color',[0/255 191/255 147/255]);
ylabel('Cells/mm^2');
% 
% delete(m1.Events);
% addevent(m1, 'time>=150', 'dc_stim=10000');
% addevent(m1, 'time>=154', 'dc_stim=0');
% 
% % active apoptosis pariod in days
% a_time = 0.99999;
% 
% for i=1:18
%     addevent(m1, ['time>' num2str(time_doses(i)+300)], ['uv_dose=' num2str(uv_protocol(i))]);
%     addevent(m1, ['time>=' num2str(time_doses(i)+a_time+300)], 'uv_dose=0');
% end
% 
% stop_time = 735;
% sim_data = model_sim(m1, stop_time);
%     
% 
% species_to_plot = ["SC", "TA", "D", "DC", "T"];
% 
% plot_index = [];
% for i=1:length(species_to_plot)
%     for j=1:length(m1.Species)
%         if species_to_plot(i) == m1.Species(j).Name
%             plot_index = [plot_index j];
%             break;
%         end
%     end
% end
% 
% for i=1:length(plot_index)
%     plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(i)), 'LineWidth', 6, 'LineStyle', ':', 'Color', colours(i));
%     hold on;
% end

set(gca, 'FontSize', 32);
set(gca, 'YScale', 'log');
set(gca, 'XScale', 'log');
xlabel('Time (weeks)');
xlim([1 100]);
ylim([10^3 5*10^5]);
% legend(["SC", "TA", "D", "DC", "T"]);
legend([species_to_plot "UVB"]);
        
saveas(fig, [work_dir '3x-therapy-scenario.png']);
saveas(fig, [work_dir '3x-therapy-scenario.svg']);

return;

%% two simulations with different UVB efficacy values
m1 = sbml_set_parameter_value(m1, "uv_eff", 0.09);
delete(m1.Events);
addevent(m1, 'time>=150', 'dc_stim=10000');
addevent(m1, 'time>=154', 'dc_stim=0');

% active apoptosis pariod in days
a_time = 0.99999;

for i=1:18
    addevent(m1, ['time>' num2str(time_doses(i)+300)], ['uv_dose=' num2str(uv_protocol(i))]);
    addevent(m1, ['time>=' num2str(time_doses(i)+a_time+300)], 'uv_dose=0');
end

stop_time = 735;
sim_data = model_sim(m1, stop_time);
    

species_to_plot = ["SC", "TA", "D", "DC", "T"];

plot_index = [];
for i=1:length(species_to_plot)
    for j=1:length(m1.Species)
        if species_to_plot(i) == m1.Species(j).Name
            plot_index = [plot_index j];
            break;
        end
    end
end

fig = figure('Units','normalized','OuterPosition',[0 0 0.4 1],'Visible','off');    
set(fig,'defaultAxesColorOrder',[[0 0 0]; [1 0 0]]);
set(gca, 'FontName', 'Arial');
colours = ['k', 'r', 'b', 'm', 'g'];
annotation('textarrow',[0.15 0.15],[0.63 0.78],'LineWidth',4,'String', ...
            ['          Therapy' char(10) 'begins  '], 'FontSize', 40, ...
            'HeadWidth', 36, 'HeadLength', 36);
annotation('textarrow',[0.38 0.38],[0.65 0.52],'LineWidth',4,'String', ...
            ['     Therapy' char(10) 'ends   '], 'FontSize', 40, ...
            'HeadWidth', 36, 'HeadLength', 36);
annotation('textarrow',[0.7 0.75],[0.78 0.63],'LineWidth',4,'String', ...
            ['uv_{eff}=0.08'], 'FontSize', 40, ...
            'HeadWidth', 36, 'HeadLength', 36);
annotation('textarrow',[0.7 0.75],[0.54 0.41],'LineWidth',4,'String', ...
            ['uv_{eff}=0.09'], 'FontSize', 40, ...
            'HeadWidth', 36, 'HeadLength', 36);     
        

% yyaxis right;
% bar(linspace(0,10,30), uv_protocol, 0.6, 'FaceColor', 'r');
% ylabel('J/cm^2');
% ylim([0 4.0]);
% 
% yyaxis left;
for i=1:length(plot_index)
    plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(i)), 'LineWidth', 6, 'LineStyle', '-', 'Color', colours(i));
    hold on;
end
ylabel('cells/mm^2');


m1 = sbml_set_parameter_value(m1, "uv_eff", 0.08);
delete(m1.Events);
addevent(m1, 'time>=150', 'dc_stim=10000');
addevent(m1, 'time>=154', 'dc_stim=0');

% active apoptosis pariod in days
a_time = 0.99999;

for i=1:18
    addevent(m1, ['time>' num2str(time_doses(i)+300)], ['uv_dose=' num2str(uv_protocol(i))]);
    addevent(m1, ['time>=' num2str(time_doses(i)+a_time+300)], 'uv_dose=0');
end

stop_time = 735;
sim_data = model_sim(m1, stop_time);
    

species_to_plot = ["SC", "TA", "D", "DC", "T"];

plot_index = [];
for i=1:length(species_to_plot)
    for j=1:length(m1.Species)
        if species_to_plot(i) == m1.Species(j).Name
            plot_index = [plot_index j];
            break;
        end
    end
end

for i=1:length(plot_index)
    plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(i)), 'LineWidth', 6, 'LineStyle', ':', 'Color', colours(i));
    hold on;
end

set(gca, 'FontSize', 48);
xlabel('Time (weeks)');
xlim([-0.5 20]);
legend(["SC", "TA", "D", "DC", "T"]);
        
saveas(fig, [work_dir 'diff_efficacy.png']);

%% two simulations with different irradiation frequency
m1 = sbml_set_parameter_value(m1, "uv_eff", 0.08);
delete(m1.Events);
addevent(m1, 'time>=150', 'dc_stim=10000');
addevent(m1, 'time>=154', 'dc_stim=0');

% active apoptosis pariod in days
a_time = 0.99999;

for i=1:18
    addevent(m1, ['time>' num2str(time_doses(i)+300)], ['uv_dose=' num2str(uv_protocol(i))]);
    addevent(m1, ['time>=' num2str(time_doses(i)+a_time+300)], 'uv_dose=0');
end

stop_time = 735;
sim_data = model_sim(m1, stop_time);
    

species_to_plot = ["SC", "TA", "D", "DC", "T"];

plot_index = [];
for i=1:length(species_to_plot)
    for j=1:length(m1.Species)
        if species_to_plot(i) == m1.Species(j).Name
            plot_index = [plot_index j];
            break;
        end
    end
end

fig = figure('Units','normalized','OuterPosition',[0 0 0.4 1],'Visible','off');    
set(fig,'defaultAxesColorOrder',[[0 0 0]; [1 0 0]]);
set(gca, 'FontName', 'Arial');
colours = ['k', 'r', 'b', 'm', 'g'];
annotation('textarrow',[0.15 0.15],[0.55 0.78],'LineWidth',4,'String', ...
            ['            Therapies' char(10) 'begin    '], 'FontSize', 40, ...
            'HeadWidth', 36, 'HeadLength', 36);
annotation('textarrow',[0.38 0.38],[0.62 0.52],'LineWidth',4,'String', ...
            ['                        3x a week (18 doses)' char(10) 'therapy ends          '], 'FontSize', 40, ...
            'HeadWidth', 36, 'HeadLength', 36);
annotation('textarrow',[0.29 0.29],[0.78 0.53],'LineWidth',4,'String', ...
            ['              5x a week (18 doses)' char(10) 'therapy ends          '], 'FontSize', 40, ...
            'HeadWidth', 36, 'HeadLength', 36);            


% yyaxis right;
% bar(linspace(0,10,30), uv_protocol, 0.6, 'FaceColor', 'r');
% ylabel('J/cm^2');
% ylim([0 4.0]);
% 
% yyaxis left;
for i=1:length(plot_index)
    plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(i)), 'LineWidth', 6, 'LineStyle', ':', 'Color', colours(i));
    hold on;
end
ylabel('cells/mm^2');

% new time verctor for the modified irradiation regime (5 times per week)
time_doses = [];
% UVB admission pattern (days) (0 = Monday, 1 = Tuesday, ...)
cur_doses_time = [0 1 2 3 4];
% generating the doses days for the first 3 weeks of therapy
for i=1:7
    time_doses = [time_doses cur_doses_time];
    cur_doses_time = cur_doses_time + 7;
end

m1 = sbml_set_parameter_value(m1, "uv_eff", 0.08);
delete(m1.Events);
addevent(m1, 'time>=150', 'dc_stim=10000');
addevent(m1, 'time>=154', 'dc_stim=0');

% active apoptosis pariod in days
a_time = 0.99999;

for i=1:18
    addevent(m1, ['time>' num2str(time_doses(i)+300)], ['uv_dose=' num2str(uv_protocol(i))]);
    addevent(m1, ['time>=' num2str(time_doses(i)+a_time+300)], 'uv_dose=0');
end

stop_time = 735;
sim_data = model_sim(m1, stop_time);
    

species_to_plot = ["SC", "TA", "D", "DC", "T"];

plot_index = [];
for i=1:length(species_to_plot)
    for j=1:length(m1.Species)
        if species_to_plot(i) == m1.Species(j).Name
            plot_index = [plot_index j];
            break;
        end
    end
end

for i=1:length(plot_index)
    plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(i)), 'LineWidth', 6, 'LineStyle', '-', 'Color', colours(i));
    hold on;
end

set(gca, 'FontSize', 48);
xlabel('Time (weeks)');
xlim([-0.5 20]);
legend(["SC", "TA", "D", "DC", "T"]);
        
saveas(fig, [work_dir 'diff_frequency.png']);


%% two simulations with 5 times a week and different doses
m1 = sbml_set_parameter_value(m1, "uv_eff", 0.08);
delete(m1.Events);
addevent(m1, 'time>=150', 'dc_stim=10000');
addevent(m1, 'time>=154', 'dc_stim=0');

% standard 3-times-a-week regime
time_doses = [];
cur_doses_time = [0 2 4];

for i=1:10
    time_doses = [time_doses cur_doses_time];
    cur_doses_time = cur_doses_time + 7;
end

% active apoptosis pariod in days
a_time = 0.99999;

for i=1:18
    addevent(m1, ['time>' num2str(time_doses(i)+300)], ['uv_dose=' num2str(uv_protocol(i))]);
    addevent(m1, ['time>=' num2str(time_doses(i)+a_time+300)], 'uv_dose=0');
end

stop_time = 735;
sim_data = model_sim(m1, stop_time);
    

species_to_plot = ["SC", "TA", "D", "DC", "T"];

plot_index = [];
for i=1:length(species_to_plot)
    for j=1:length(m1.Species)
        if species_to_plot(i) == m1.Species(j).Name
            plot_index = [plot_index j];
            break;
        end
    end
end

fig = figure('Units','normalized','OuterPosition',[0 0 0.4 1],'Visible','off');    
set(fig,'defaultAxesColorOrder',[[0 0 0]; [1 0 0]]);
set(gca, 'FontName', 'Arial');
colours = ['k', 'r', 'b', 'm', 'g'];
annotation('textarrow',[0.15 0.15],[0.55 0.78],'LineWidth',4,'String', ...
            ['            Therapies' char(10) 'begin    '], 'FontSize', 40, ...
            'HeadWidth', 36, 'HeadLength', 36);
annotation('textarrow',[0.38 0.38],[0.62 0.52],'LineWidth',4,'String', ...
            ['                  3x a week (18 doses)' char(10) '         therapy ends'], 'FontSize', 40, ...
            'HeadWidth', 36, 'HeadLength', 36, 'HorizontalAlignment', 'center');
annotation('textarrow',[0.27 0.27],[0.78 0.57],'LineWidth',4,'String', ...
            ['               5x a week (16 doses)' char(10) '       therapy ends'], 'FontSize', 40, ...
            'HeadWidth', 36, 'HeadLength', 36, 'HorizontalAlignment', 'center');            


% yyaxis right;
% bar(linspace(0,10,30), uv_protocol, 0.6, 'FaceColor', 'r');
% ylabel('J/cm^2');
% ylim([0 4.0]);
% 
% yyaxis left;
for i=1:length(plot_index)
    plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(i)), 'LineWidth', 6, 'LineStyle', ':', 'Color', colours(i));
    hold on;
end
ylabel('cells/mm^2');

% new time verctor for the modified irradiation regime (5 times per week)
time_doses = [];
% UVB admission pattern (days) (0 = Monday, 1 = Tuesday, ...)
cur_doses_time = [0 1 2 3 4];
% generating the doses days for the first 3 weeks of therapy
for i=1:7
    time_doses = [time_doses cur_doses_time];
    cur_doses_time = cur_doses_time + 7;
end

m1 = sbml_set_parameter_value(m1, "uv_eff", 0.08);
delete(m1.Events);
addevent(m1, 'time>=150', 'dc_stim=10000');
addevent(m1, 'time>=154', 'dc_stim=0');

% active apoptosis pariod in days
a_time = 0.99999;

for i=1:16
    addevent(m1, ['time>' num2str(time_doses(i)+300)], ['uv_dose=' num2str(uv_protocol(i))]);
    addevent(m1, ['time>=' num2str(time_doses(i)+a_time+300)], 'uv_dose=0');
end

stop_time = 735;
sim_data = model_sim(m1, stop_time);
    

species_to_plot = ["SC", "TA", "D", "DC", "T"];

plot_index = [];
for i=1:length(species_to_plot)
    for j=1:length(m1.Species)
        if species_to_plot(i) == m1.Species(j).Name
            plot_index = [plot_index j];
            break;
        end
    end
end

for i=1:length(plot_index)
    plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(i)), 'LineWidth', 6, 'LineStyle', '-', 'Color', colours(i));
    hold on;
end

set(gca, 'FontSize', 48);
xlabel('Time (weeks)');
xlim([-0.5 20]);
legend(["SC", "TA", "D", "DC", "T"]);
        
saveas(fig, [work_dir 'diff_frequency_and_doses.png']);

