sbioloadproject('psor.v8.2.sbproj','m1')

for i=1:length(m1.Species)
    species = m1.Species(i);
    species.InitialAmount = 1;
end

stop_time = 735;
totC_h = 84981;
totC_p = 250543;

% short stimulus
delete(m1.Events);
addevent(m1, 'time>=150', ['dc_stim=1600']);
addevent(m1, 'time>=152', 'dc_stim=0');
short_sim_data = model_sim(m1, stop_time);

% long stimulus
delete(m1.Events);
addevent(m1, 'time>=150', ['dc_stim=1600']);
addevent(m1, 'time>=154', 'dc_stim=0');
long_sim_data = model_sim(m1, stop_time);

% long stimulus
delete(m1.Events);
addevent(m1, 'time>=150', ['dc_stim=6000']);
addevent(m1, 'time>=154', 'dc_stim=0');
strong_sim_data = model_sim(m1, stop_time);

% species_to_plot = ["totC" "DC" "T"];
species_to_plot = ["totC" "IL23" "TNF" "IL17"];

plot_index = [];
for j=1:length(m1.Species)
    if(ismember(m1.Species(j).Name, species_to_plot))
        plot_index = [plot_index j];
    end
end

subaxis(7, 1, [1 2 3], 'Spacing',0.0,'Padding',0.005,'Margin',0.005);
plot(short_sim_data.Time/7, short_sim_data.Data(:, plot_index(2)), 'LineWidth', 12, 'Color', 'blue', 'LineStyle', '-');
hold on;
plot(long_sim_data.Time/7, long_sim_data.Data(:, plot_index(2)), 'LineWidth', 12, 'Color', 'red', 'LineStyle', '-');
hold on;
plot(strong_sim_data.Time/7, strong_sim_data.Data(:, plot_index(2)), 'LineWidth', 12, 'Color', 'black', 'LineStyle', '-');
hold on;
yline(totC_h, 'LineWidth', 6, 'Color', [0.3 0.3 0.3], 'LineStyle', ':');
hold on;
yline(totC_p, 'LineWidth', 6, 'Color', [0.3 0.3 0.3], 'LineStyle', ':');
hold on;

text(27, 5.0e4, string(['Healthy state']), ...
                'FontName', 'Arial', ...
                'FontAngle', 'italic', ...
                'FontSize', 64);
            
text(27, 2.0e5, string(['Psoriatic state']), ...
                'FontName', 'Arial', ...
                'FontAngle', 'italic', ...
                'FontSize', 64);

title("Keratinocytes")
legend(["Stimulus(\times1) for 2 days" "Stimulus(\times1) for 4 days" "Stimulus(\times4) for 4 days"], 'Location', 'East');

set(gca, 'FontName', 'Arial');
set(gca, 'FontSize', 64);
set(gca, 'XTickLabel',[]);

ylabel("Cells/mm^2");
xlim([0 40]);
ylim([0 3e5]);


subaxis(7, 1, [5 6 7], 'Spacing',0.0,'Padding',0.005,'Margin',0.005);
plot(short_sim_data.Time/7, short_sim_data.Data(:, plot_index(1))+ ...
                                short_sim_data.Data(:, plot_index(3))+ ...
                                short_sim_data.Data(:, plot_index(4)), 'LineWidth', 12, 'Color', 'blue', 'LineStyle', '-');
hold on;
plot(long_sim_data.Time/7, long_sim_data.Data(:, plot_index(1))+...
                                long_sim_data.Data(:, plot_index(3))+...
                                long_sim_data.Data(:, plot_index(4)), 'LineWidth', 12, 'Color', 'red', 'LineStyle', '-');
hold on;
plot(strong_sim_data.Time/7, strong_sim_data.Data(:, plot_index(1))+...
                                strong_sim_data.Data(:, plot_index(3))+...
                                strong_sim_data.Data(:, plot_index(4)), 'LineWidth', 12, 'Color', 'black', 'LineStyle', '-');
hold on;

title("Interleukins (IL17+IL23+TNF\alpha)")
legend(["Stimulus(\times1) for 2 days" "Stimulus(\times1) for 4 days" "Stimulus(\times4) for 4 days"], 'Location', 'East');

set(gca, 'FontName', 'Arial');
set(gca, 'FontSize', 64);

ylabel("Alrbitrary");
xlabel("Time (weeks)");
xlim([0 40]);
% ylim([0 550])

return;


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
addevent(m1, 'time>=150', ['dc_stim=1500']);
addevent(m1, 'time>=154', 'dc_stim=0');

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

