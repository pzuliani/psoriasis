% This script compares two different simulation scenarios: 1) UVB induces
% 100% apoptosis and 0% arrest, and 2) UVB induces 0% apoptosis and 100%
% arrest.
%
% Author: Fedor Shmarov


% SBML import of the model
m1 = sbmlimport('../models/psor_v8_4.xml');

for i=1:length(m1.Species)
    species = m1.Species(i);
    species.InitialAmount = 1;
end

time_doses = [];
cur_doses_time = [0 2 4];
for i=1:11
    time_doses = [time_doses cur_doses_time];
    cur_doses_time = cur_doses_time + 7;
end

uv_protocol = [0.7 0.7 0.98 0.98 1.323 1.323 1.72 1.72 2.15 2.15 ...
                2.58 2.58 2.967 2.967 3.264 3.264 3.427 3.427 3.427 3.427 ...
                3.427 3.427 3.427 3.427 3.427 3.427 3.427 3.427 3.427 3.427 ...
                3.427 3.427 3.427];

delete(m1.Events);
addevent(m1, 'time>=150', ['dc_stim=10000']);
addevent(m1, 'time>=154', 'dc_stim=0');

for i=1:18
    addevent(m1, ['time>' num2str(time_doses(i)+300)], ['uv_dose=' num2str(uv_protocol(i))]);
    addevent(m1, ['time>=' num2str(time_doses(i)+300) '+a_time'], 'uv_dose=0');
end

m1 = sbml_set_parameter_value(m1, "a_time", 0.99999);
m1 = sbml_set_parameter_value(m1, "uv_eff", 0.15);
m1 = sbml_set_parameter_value(m1, "arrest", 0);
m1 = sbml_set_parameter_value(m1, "r20", 5.05e-7);

stop_time = 735;
sim_data = model_sim(m1, stop_time);

species_to_plot = ["totC"];
plot_index = [];
for j=1:length(m1.Species)
    if(ismember(m1.Species(j).Name, species_to_plot))
        plot_index = [plot_index j];
    end
end

figure;
plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(1)), 'LineWidth', 8, 'Color', 'black', 'LineStyle', '-');
hold on;

m1 = sbml_set_parameter_value(m1, "arrest", 1);

stop_time = 735;
sim_data = model_sim(m1, stop_time);

plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(1)), 'LineWidth', 8, 'Color', 'red', 'LineStyle', '-');
hold on;

set(gca,'FontSize', 40);

rectangle('Position', [0/7 6e4 42/7 2e4*700/700], 'FaceColor', 'y', 'LineWidth', 3);
text(9/7+0.7, 7.1e4, 'UVB therapy', ...
                'FontName', 'Arial', ...
                'FontSize', 40);

legend([string('Apoptosis') string('Growth arrest')], 'Location', 'NorthEast', 'FontSize', 40);

xlim([-0.5 10]);
xlabel('Time (weeks)', 'FontSize', 40);
ylabel(['Total number of cells' char(10)  '(Cells/mm^2)'], 'FontSize', 40);





