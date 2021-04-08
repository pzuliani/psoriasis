% SBML import of the model
m1 = sbmlimport('../models/psor_v8_4.xml');

for i=1:length(m1.Species)
    species = m1.Species(i);
    species.InitialAmount = 1;
end

time_pasis = [];
cur_pasis_time = 0;
for i=1:12
    time_pasis = [time_pasis cur_pasis_time];
    cur_pasis_time = cur_pasis_time + 7;
end

time_doses = [];
cur_doses_time = [0 2 4];
% cur_doses_time = [0 3];
% cur_doses_time = [0];
for i=1:11
    time_doses = [time_doses cur_doses_time];
    cur_doses_time = cur_doses_time + 7;
end

data = readtable("../../data/pasis_and_doses.xlsx");

% pasis = [data.PASI_SCALED_PRE_TREATMENT ...
%             data.PASI_SCALED_END_WEEK_1 ...
%             data.PASI_SCALED_END_WEEK_2 ...
%             data.PASI_SCALED_END_WEEK_3 ...
%             data.PASI_SCALED_END_WEEK_4 ...
%             data.PASI_SCALED_END_WEEK_5 ...
%             data.PASI_SCALED_END_WEEK_6 ...
%             data.PASI_SCALED_END_WEEK_7 ...
%             data.PASI_SCALED_END_WEEK_8 ...
%             data.PASI_SCALED_END_WEEK_9 ...
%             data.PASI_SCALED_END_WEEK_10 ...
%             data.PASI_SCALED_END_WEEK_11];
        
pasis = [data.PASI_PRE_TREATMENT ...
            data.PASI_END_WEEK_1 ...
            data.PASI_END_WEEK_2 ...
            data.PASI_END_WEEK_3 ...
            data.PASI_END_WEEK_4 ...
            data.PASI_END_WEEK_5 ...
            data.PASI_END_WEEK_6 ...
            data.PASI_END_WEEK_7 ...
            data.PASI_END_WEEK_8 ...
            data.PASI_END_WEEK_9 ...
            data.PASI_END_WEEK_10 ...
            data.PASI_END_WEEK_11];
        
doses = [data.UVB_DOSE_1 data.UVB_DOSE_2 data.UVB_DOSE_3 ...
            data.UVB_DOSE_4 data.UVB_DOSE_5 data.UVB_DOSE_6 ...
            data.UVB_DOSE_7 data.UVB_DOSE_8 data.UVB_DOSE_9 ...
            data.UVB_DOSE_10 data.UVB_DOSE_11 data.UVB_DOSE_12 ...
            data.UVB_DOSE_13 data.UVB_DOSE_14 data.UVB_DOSE_15 ...
            data.UVB_DOSE_16 data.UVB_DOSE_17 data.UVB_DOSE_18 ...
            data.UVB_DOSE_19 data.UVB_DOSE_20 data.UVB_DOSE_21 ...
            data.UVB_DOSE_22 data.UVB_DOSE_23 data.UVB_DOSE_24 ...
            data.UVB_DOSE_25 data.UVB_DOSE_26 data.UVB_DOSE_27 ...
            data.UVB_DOSE_28 data.UVB_DOSE_29 data.UVB_DOSE_30 ...
            data.UVB_DOSE_31 data.UVB_DOSE_32 data.UVB_DOSE_33]; 
        
uv_protocol = [0.7 0.7 0.98 0.98 1.323 1.323 1.72 1.72 2.15 2.15 ...
                2.58 2.58 2.967 2.967 3.264 3.264 3.427 3.427 3.427 3.427 ...
                3.427 3.427 3.427 3.427 3.427 3.427 3.427 3.427 3.427 3.427 ...
                3.427 3.427 3.427];
            
med = data.MED;            

totC_p = 2.3386e+05;
totC_h = 8.2614e+04;

pasis_scaled = pasis;
for i = 1:length(pasis_scaled)
    pasis_scaled(i,:) = totC_h + (totC_p - totC_h)*(pasis_scaled(i,:)/max(pasis_scaled(i,:)));
end

delete(m1.Events);
addevent(m1, 'time>=150', ['t_stim=1500']);
addevent(m1, 'time>=152', 't_stim=0');

m1 = sbml_set_parameter_value(m1, "arrest", 0.0);
m1 = sbml_set_parameter_value(m1, "uv_eff", 1.4e-5);

stop_time = 735;
sim_data = model_sim(m1, stop_time);

species_to_plot = ["totC" "T" "IL" "GF"];

plot_index = [];
for j=1:length(m1.Species)
    if(ismember(m1.Species(j).Name, species_to_plot))
        plot_index = [plot_index j];
    end
end

subaxis(14, 2, [3 5 7], 'Spacing',0.0,'Padding',0.005,'Margin',0.005);
plot((sim_data.Time-150)/7, sim_data.Data(:, plot_index(4)), 'LineWidth', 8, 'Color', 'black', 'LineStyle', '-');
legend(['Total number of' char(10) 'keratinocytes'], 'Location', 'NorthWest', 'FontSize', 36);

ylim([totC_h-0.08*(totC_p-totC_h) totC_p+0.1*(totC_p-totC_h)]);
xlim([-0.5 5]);
xlabel('');
set(gca,'XTickLabel',[]);
set(gca,'FontSize',26);
ylabel(['Cells/mm^2'], 'FontSize', 36);

subaxis(14, 2, [9 11 13], 'Spacing',0.0,'Padding',0.005,'Margin',0.005);
plot((sim_data.Time-150)/7, sim_data.Data(:, plot_index(1)), 'LineWidth', 8, 'Color', 'blue', 'LineStyle', '-');
legend(['Interleukins'], 'Location', 'NorthWest', 'FontSize', 36);

ylim([35 130]);
xlim([-0.5 5]);
xlabel('');
set(gca,'XTickLabel',[]);
set(gca,'FontSize',26);
ylabel(['Arbitrary'], 'FontSize', 36);

subaxis(14, 2, [15 17 19], 'Spacing',0.0,'Padding',0.005,'Margin',0.005);
plot((sim_data.Time-150)/7, sim_data.Data(:, plot_index(2)), 'LineWidth', 8, 'Color', 'red', 'LineStyle', '-');
legend(['Immune cells'], 'Location', 'NorthWest', 'FontSize', 36);

ylim([1200 4800]);
xlim([-0.5 5]);
xlabel('');
set(gca,'XTickLabel',[]);
set(gca,'FontSize',26);
ylabel(['Cells/mm^2'], 'FontSize', 36);

subaxis(14, 2, [21 23 25], 'Spacing',0.0,'Padding',0.005,'Margin',0.005);
plot((sim_data.Time-150)/7, sim_data.Data(:, plot_index(3)), 'LineWidth', 8, 'Color', 'green', 'LineStyle', '-');
legend(['KC derived cytokines,' char(10) 'chemokines and AMPs'], 'Location', 'NorthWest', 'FontSize', 36);

% ylabel(['CXC chemokines, AMPs' char(10) '(arbitrary)']);
ylim([600 2100]);
xlim([-0.5 5]);
set(gca,'FontSize',26);
ylabel(['Arbitrary'], 'FontSize', 36);
xlabel('Time (weeks)', 'FontSize', 42);

delete(m1.Events);
addevent(m1, 'time>=150', ['t_stim=1500']);
addevent(m1, 'time>=154', 't_stim=0');

stop_time = 735;
sim_data = model_sim(m1, stop_time);

species_to_plot = ["totC" "T" "IL" "GF"];

plot_index = [];
for j=1:length(m1.Species)
    if(ismember(m1.Species(j).Name, species_to_plot))
        plot_index = [plot_index j];
    end
end

subaxis(14, 2, [4 6 8], 'Spacing',0.0,'Padding',0.005,'Margin',0.005);
plot((sim_data.Time-150)/7, sim_data.Data(:, plot_index(4)), 'LineWidth', 8, 'Color', 'black', 'LineStyle', '-');
legend(['Total number of' char(10) 'keratinocytes'], 'Location', 'NorthWest', 'FontSize', 36);

ylabel('');
ylim([totC_h-0.08*(totC_p-totC_h) totC_p+0.1*(totC_p-totC_h)]);
xlim([-0.5 5]);
xlabel('');
set(gca,'XTickLabel',[]);
set(gca,'YTickLabel',[]);
set(gca,'FontSize',26);

subaxis(14, 2, [10 12 14], 'Spacing',0.0,'Padding',0.005,'Margin',0.005);
plot((sim_data.Time-150)/7, sim_data.Data(:, plot_index(1)), 'LineWidth', 8, 'Color', 'blue', 'LineStyle', '-');
legend(['Interleukins'], 'Location', 'NorthWest', 'FontSize', 36);

ylabel(['']);
ylim([35 130]);
xlim([-0.5 5]);
xlabel('');
set(gca,'XTickLabel',[]);
set(gca,'YTickLabel',[]);
set(gca,'FontSize',26);

subaxis(14, 2, [16 18 20], 'Spacing',0.0,'Padding',0.005,'Margin',0.005);
plot((sim_data.Time-150)/7, sim_data.Data(:, plot_index(2)), 'LineWidth', 8, 'Color', 'red', 'LineStyle', '-');
legend(['Immune cells'], 'Location', 'NorthWest', 'FontSize', 36);

ylabel('');
ylim([1200 4800]);
xlim([-0.5 5]);
xlabel('');
set(gca,'XTickLabel',[]);
set(gca,'YTickLabel',[]);
set(gca,'FontSize',26);

subaxis(14, 2, [22 24 26], 'Spacing',0.0,'Padding',0.005,'Margin',0.005);
plot((sim_data.Time-150)/7, sim_data.Data(:, plot_index(3)), 'LineWidth', 8, 'Color', 'green', 'LineStyle', '-');
legend(['KC derived cytokines,' char(10) 'chemokines and AMPs'], 'Location', 'NorthWest', 'FontSize', 36);

ylabel(['']);
ylim([600 2100]);
xlim([-0.5 5]);
set(gca,'YTickLabel',[]);
set(gca,'FontSize',26);
xlabel('Time (weeks)', 'FontSize', 42);


% return;

for i=1:18
    addevent(m1, ['time>' num2str(time_doses(i)+300)], ['uv_dose=' num2str(uv_protocol(i))]);
    addevent(m1, ['time>=' num2str(time_doses(i)+300) '+a_time'], 'uv_dose=0');
end

species_to_plot = ["totC" "UV" "A_per_1000"];

plot_index = [];
for j=1:length(m1.Species)
    if(ismember(m1.Species(j).Name, species_to_plot))
        plot_index = [plot_index j];
    end
end

m1 = sbml_set_parameter_value(m1, "a_time", 0.99999);

stop_time = 735;
sim_data = model_sim(m1, stop_time);

figure;
subaxis(5, 1, [1 2], 'Spacing',0.0,'Padding',0.005,'Margin',0.005);
plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(1)), 'LineWidth', 8, 'Color', 'black', 'LineStyle', '-');
legend(['Total number of' char(10) 'keratinocytes'], 'FontSize', 42);

ylim([totC_h-0.08*(totC_p-totC_h) totC_p+0.1*(totC_p-totC_h)]);
% yline(totC_h);
% yline(totC_p);
xlim([-0.5 6.5]);
set(gca,'XTickLabel',[]);
xlabel('');
set(gca,'FontSize',30);
ylabel('Cells/mm^2', 'FontSize', 42);

subaxis(5, 1, 3, 'Spacing',0.0,'Padding',0.005,'Margin',0.005);
plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(3)), 'LineWidth', 6, 'Color', 'blue', 'LineStyle', '-');
legend(['UV dose'], 'FontSize', 42);

ylim([0 5.5])
xlim([-0.5 6.5]);
set(gca,'XTickLabel',[]);
xlabel('');
set(gca,'FontSize',30);
ylabel('J/cm^2', 'FontSize', 42);

subaxis(5, 1, 4, 'Spacing',0.0,'Padding',0.005,'Margin',0.005);
plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(2)), 'LineWidth', 6, 'Color', 'red', 'LineStyle', '-');
legend(['Apoptosis rate'], 'FontSize', 42);

ylim([0 3.5])
xlim([-0.5 6.5]);
set(gca,'FontSize',30);
ylabel(['Cells per' char(10) '1000'], 'FontSize', 42);
xlabel('Time (weeks)', 'FontSize', 42);


% return;

% Apoptosis of keratinocytes vs immune cells

stop_time = 735;
sim_data = model_sim(m1, stop_time);

figure;

line(NaN,NaN,'LineWidth',3,'LineStyle','none');
hold on;    

m1 = sbml_set_parameter_value(m1, "x", 0.0);
m1 = sbml_set_parameter_value(m1, "y", 1.0);
sim_data = model_sim(m1, stop_time);

plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(1)), 'LineWidth', 12, 'Color', 'red', 'LineStyle', '-');
hold on;

m1 = sbml_set_parameter_value(m1, "x", 1.0);
m1 = sbml_set_parameter_value(m1, "y", 0.0);
sim_data = model_sim(m1, stop_time);

plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(1)), 'LineWidth', 12, 'Color', 'blue', 'LineStyle', '-');
hold on;

m1 = sbml_set_parameter_value(m1, "x", 1.0);
m1 = sbml_set_parameter_value(m1, "y", 1.0);
sim_data = model_sim(m1, stop_time);
plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(1)), 'LineWidth', 12, 'Color', 'black', 'LineStyle', '-');
hold on;


rectangle('Position', [0 8e4 42/7 1.5e4], 'FaceColor', 'y', 'LineWidth', 3);
text(0.5, 8.8e4, 'UV (3 per week)', ...
                    'FontName', 'Arial', ...
                    'FontSize', 48);

legend([string(['Apoptosis of:']) ...
        string(['   Immune cells']) ... 
        string(['   Keratinocytes']) ...
        string(['   Keratinocytes +' char(10) '   Immune cells'])], 'FontSize', 56);
ylim([totC_h-0.08*(totC_p-totC_h) totC_p+0.1*(totC_p-totC_h)]);
% yline(totC_h);
% yline(totC_p);
xlim([-0.5 20]);
% set(gca,'XTickLabel',[]);
set(gca,'FontSize',42);
ylabel('Cells/mm^2', 'FontSize', 72);
xlabel('Time (weeks)', 'FontSize', 72);





