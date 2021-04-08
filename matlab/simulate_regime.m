% sbioloadproject('psor.v7.1.sbproj','m1')
% sbioloadproject('simple-cell-cycle.sbproj','m1')
% sbioloadproject('psor.v8.1.sbproj','m1')
sbioloadproject('psor.v8.4.sbproj','m1')

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

% data = readtable("../../data/pasis_and_doses.xlsx");

data = readtable("../../data/data.xlsx");

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
            
% med = data.MED;            

totC_p = 266011.65;
totC_h = 79828;

pasis_scaled = pasis;
for i = 1:length(pasis_scaled)
    pasis_scaled(i,:) = totC_h + (totC_p - totC_h)*(pasis_scaled(i,:)/max(pasis_scaled(i,:)));
end

delete(m1.Events);
addevent(m1, 'time>=150', ['dc_stim=10000']);
addevent(m1, 'time>=154', 'dc_stim=0');

m1 = sbml_set_parameter_value(m1, "arrest", 0.0);
m1 = sbml_set_parameter_value(m1, "uv_eff", 1.4e-5);

time_doses = [  0 2 4 ...       % week 1
                7 9 11 ...      % week 2
                14 16 18 ...    % week 3
                21 23 25 ...    % week 4
                28 30 32 ...    % week 5
                35 37 39 ...    % week 6
                42 44 46 ...    % week 7
                49 51 53 ...    % week 8
                56 58 60 ...    % week 9
                63 65 67 ...    % week 10
                70 72 74];      % week 11

% Total number of doses
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
subaxis(7, 2, [1 2 3 4 5 6], 'Spacing',0.0,'Padding',0.005,'Margin',0.005);
plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(1)), 'LineWidth', 8, 'Color', 'black', 'LineStyle', '-');
hold on;

ylim([totC_h-0.08*(totC_p-totC_h) totC_p+0.1*(totC_p-totC_h)]);
xlabel('Time (weeks)');
set(gca,'FontSize',30);
ylabel('Cells/mm^2', 'FontSize', 30);

subaxis(7, 2, 9, 'Spacing',0.0,'Padding',0.005,'Margin',0.005);
plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(3)), 'LineWidth', 6, 'Color', 'blue', 'LineStyle', '-');
legend(['UV dose'], 'FontSize', 28);

ylim([0 5.5]);
xlim([-0.5 6.5]);
set(gca,'XTickLabel',[]);
xlabel('');
set(gca,'FontSize',30);
ylabel('J/cm^2', 'FontSize', 30);

subaxis(7, 2, 11, 'Spacing',0.0,'Padding',0.005,'Margin',0.005);
plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(2)), 'LineWidth', 6, 'Color', 'red', 'LineStyle', '-');
legend(['Apoptosis rate'], 'FontSize', 28);

ylim([0 5]);
xlim([-0.5 6.5]);
set(gca,'FontSize',30);
ylabel(['Cells per' char(10) '1000'], 'FontSize', 30);
xlabel('Time (weeks)', 'FontSize', 30);

%%%%%%%%%%%%%%%%%%%%%%
%
% altering the regime
%
%%%%%%%%%%%%%%%%%%%%%%

time_doses = [  0 1 2 3 4 ...       % week 1
                7 8 9 10 11 ...      % week 2
                14 15 16 17 18 ...    % week 3
                21 22 23 24 25 ...    % week 4
                28 29 30 31 32 ...    % week 5
                35 37 39 ...    % week 6
                42 44 46 ...    % week 7
                49 51 53 ...    % week 8
                56 58 60 ...    % week 9
                63 65 67 ...    % week 10
                70 72 74];      % week 11

delete(m1.Events);
addevent(m1, 'time>=150', ['dc_stim=10000']);
addevent(m1, 'time>=152', 'dc_stim=0');            

% Total number of doses
for i=1:15
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

subaxis(7, 2, [1 2 3 4 5 6], 'Spacing',0.0,'Padding',0.005,'Margin',0.005);
plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(1)), 'LineWidth', 8, 'Color', 'red', 'LineStyle', '-');
hold on;
yline(totC_p - 0.9*(totC_p - totC_h), 'LineWidth', 5, 'LineStyle', ':', 'Color', 'blue');
hold on;
yline(totC_h, 'LineWidth', 2, 'LineStyle', ':');
hold on;
yline(totC_p, 'LineWidth', 2, 'LineStyle', ':');
hold on;
legend([string(['   3 per week']) ...
        string(['   Altered regime']) ...
        string(['   PASI 90'])], 'FontSize', 28);

ylim([totC_h-0.08*(totC_p-totC_h) totC_p+0.1*(totC_p-totC_h)]);
xlim([-0.5 30]);
xlabel('Time (weeks)');
set(gca,'FontSize',30);

subaxis(7, 2, 10, 'Spacing',0.0,'Padding',0.005,'Margin',0.005);
plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(3)), 'LineWidth', 6, 'Color', 'blue', 'LineStyle', '-');
legend(['UV dose'], 'FontSize', 28);

ylim([0 5.5]);
xlim([-0.5 6.5]);
set(gca,'XTickLabel',[]);
set(gca,'YTickLabel',[]);
xlabel('');
set(gca,'FontSize',30);

subaxis(7, 2, 12, 'Spacing',0.0,'Padding',0.005,'Margin',0.005);
plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(2)), 'LineWidth', 6, 'Color', 'red', 'LineStyle', '-');
legend(['Apoptosis rate'], 'FontSize', 28);

ylim([0 5]);
xlim([-0.5 6.5]);
set(gca,'YTickLabel',[]);
set(gca,'FontSize',30);
xlabel('Time (weeks)', 'FontSize', 30);



