% SBML import of the model
m1 = sbmlimport('../models/psor_v8_2.xml');

d2 = sbiodose('Repeat', 'repeat');

d2 = adddose(m1, 'Repeat', 'repeat');
d2.Amount = 40000;
d2.TargetName = 'AdaSQ';
d2.Rate = 0;
d2.StartTime = 7;
d2.RepeatCount = 50;
d2.Interval = 14;
d2.Active = true;
m1.Reactions(29).Active = true;
m1.Reactions(32).Active = false;

stop_time = 1100;
sim_data = model_sim(m1, stop_time);

species_to_plot = ["totC" "AdaT"];

plot_index = [];
for i=1:length(m1.Species)
    if(ismember(m1.Species(i).Name, species_to_plot))
        plot_index = [plot_index i];
    end
end
    
% subaxis(7, 1, [1 2 3 4], 'Spacing',0.01,'Padding',0.04,'Margin',0.025);
fig = figure;
set(fig,'defaultAxesColorOrder',[[0 0 0]; [1 0 0]]);
set(gca, 'FontName', 'Arial')
set(gca, 'FontSize', 64); % was 64

yyaxis left;
plot(sim_data.Time/7, sim_data.Data(:, plot_index(1)), 'LineWidth', 12, 'Color', 'black', 'LineStyle', '-');
hold on;

ylabel('Keratinocytes/mm^2', 'FontSize', 84); % was 96
ylim([5e4 2.5e5]);

yyaxis right;
plot(sim_data.Time/7, sim_data.Data(:, plot_index(2))/10, 'LineWidth', 12, 'Color', 'red', 'LineStyle', '-');
hold on;
ylim([0 1.2e4]);
ylabel('Arbitrary', 'FontSize', 84); % was 96

xlim([0 45]);
xlabel('Time (weeks)', 'FontSize', 96); % was 96
title('Adalimumab', 'FontSize', 84);

% legend(["Keratinocytes" "Adalimumab"]);

removedose(m1, 'Repeat');

d2 = adddose(m1, 'Repeat', 'repeat');
d2.Amount = 45000;
d2.TargetName = 'UstSQ';
d2.Rate = 0;
d2.StartTime = 28;
d2.RepeatCount = 4;
d2.Interval = 84;
d2.Active = true;
m1.Reactions(29).Active = false;
m1.Reactions(32).Active = true;

stop_time = 735;
sim_data = model_sim(m1, stop_time);

species_to_plot = ["totC" "UstT"];

plot_index = [];
for i=1:length(m1.Species)
    if(ismember(m1.Species(i).Name, species_to_plot))
        plot_index = [plot_index i];
    end
end
    
% subaxis(7, 1, [1 2 3 4], 'Spacing',0.01,'Padding',0.04,'Margin',0.025);
fig = figure;
set(fig,'defaultAxesColorOrder',[[0 0 0]; [0 0 1]]);
set(gca, 'FontName', 'Arial')
set(gca, 'FontSize', 64); % was 64

yyaxis left;
plot(sim_data.Time/7, sim_data.Data(:, plot_index(1)), 'LineWidth', 12, 'Color', 'black', 'LineStyle', '-');
hold on;

ylabel('Keratinocytes/mm^2', 'FontSize', 84); % was 96
ylim([5e4 2.5e5]);

yyaxis right;
plot(sim_data.Time/7, sim_data.Data(:, plot_index(2)), 'LineWidth', 12, 'Color', 'blue', 'LineStyle', '-');
hold on;
ylim([0 1e4]);
ylabel('Arbitrary', 'FontSize', 84); % was 96

xlim([0 45]);
xlabel('Time (weeks)', 'FontSize', 96); % was 96

title('Ustekinumab', 'FontSize', 84);

% legend(["Keratinocytes" "Ustekinumab"]);



