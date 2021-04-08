% SBML import of the model
m1 = sbmlimport('../models/psor_v8_2.xml');

% for i=1:length(m1.Species)
%     species = m1.Species(i);
%     species.InitialAmount = 1;
% end

time_pasis = [];
cur_pasis_time = 0;
for i=1:13
    time_pasis = [time_pasis cur_pasis_time];
    cur_pasis_time = cur_pasis_time + 7;
end

data = readtable("../../data/data.xlsx");
        
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
            data.PASI_END_WEEK_11 ...
            data.PASI_END_WEEK_12];
   
totC_p = 250543;
totC_h = 84981;

pasis_scaled = pasis;
for i = 1:length(pasis_scaled)
    pasis_scaled(i,:) = totC_h + (totC_p - totC_h)*(pasis_scaled(i,:)/max(pasis_scaled(i,:)));
end

species_to_plot = ["totC"];

plot_index = [];
for j=1:length(m1.Species)
    if(ismember(m1.Species(j).Name, species_to_plot))
        plot_index = [plot_index j];
    end
end

stop_time = 735;
p_id = 5010;

index = -1;
for i=1:length(data.ID)
    if(p_id == data.ID(i))
        index = i;
        break;
    end
end

d2 = sbiodose('repeat', 'Repeat');

if(data.THERAPY(index) == "Adalimumab")
%         d2 = adddose(m1, 'Repeat', 'repeat');
    d2.Amount = 40000;
    d2.TargetName = 'AdaSQ';
    d2.Rate = 0;
    d2.StartTime = 7;
    d2.RepeatCount = 30;
    d2.Interval = 14;
    d2.Active = true;
    m1.Reactions(29).Active = true;
    m1.Reactions(32).Active = false;
end
if(data.THERAPY(index) == "Ustekinumab")
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
end

disp("-----");
disp(p_id);
disp(data.THERAPY(i));

Time = transpose(time_pasis);
totC = transpose(pasis_scaled(index,:));

tbl = table(Time, totC);

if(p_id == 5010)
    delete(m1.Events);
    addevent(m1, 'time>=7', 'dc_stim=1000');
    addevent(m1, 'time>=28', 'dc_stim=0');
end

grpData = groupedData(tbl, '', 'Time');
responseMap = 'totC = totC';
fitAlg = 'lsqnonlin';
if(data.THERAPY(index) == "Adalimumab")
    estimated = estimatedInfo({'ada2','ada2tnf', 'ada20', 'tnf_min'}, 'InitialValue', [0.04 0.1 0.5 26], 'Bounds', [0.01 1; 0.01 1; 0.01 1; 26 30]);
    fitConst = sbiofit(m1, grpData, responseMap, estimated, d2, fitAlg);
    m1 = sbml_set_parameter_value(m1, "ada2", fitConst.ParameterEstimates.Estimate(1));
    m1 = sbml_set_parameter_value(m1, "ada2tnf", fitConst.ParameterEstimates.Estimate(2));
    m1 = sbml_set_parameter_value(m1, "ada20", fitConst.ParameterEstimates.Estimate(3));
    m1 = sbml_set_parameter_value(m1, "tnf_min", fitConst.ParameterEstimates.Estimate(4));
    disp(fitConst.ParameterEstimates);
end
if(data.THERAPY(index) == "Ustekinumab")    
    estimated = estimatedInfo({'ust2','ust2il23', 'ust20', 'il23_min'}, 'InitialValue', [0.04 0.1 0.1 50], 'Bounds', [0.01 1; 0.01 1; 0.001 0.01; 50 120]);
    fitConst = sbiofit(m1, grpData, responseMap, estimated, d2, fitAlg);
    m1 = sbml_set_parameter_value(m1, "ust2", fitConst.ParameterEstimates.Estimate(1));
    m1 = sbml_set_parameter_value(m1, "ust2il23", fitConst.ParameterEstimates.Estimate(2));
    m1 = sbml_set_parameter_value(m1, "ust20", fitConst.ParameterEstimates.Estimate(3));
    m1 = sbml_set_parameter_value(m1, "il23_min", fitConst.ParameterEstimates.Estimate(4));
    disp(fitConst.ParameterEstimates);
end

stop_time = 735;
sim_data = model_sim(m1, stop_time);

species_to_plot = ["totC"];

plot_index = [];
for i=1:length(m1.Species)
    if(ismember(m1.Species(i).Name, species_to_plot))
        plot_index = [plot_index i];
    end
end

fig = figure;
set(fig,'defaultAxesColorOrder',[[0 0 0]; [1 0 0]]);
set(gca, 'FontName', 'Arial');
set(gca, 'FontSize', 64);

yyaxis left;
plot(sim_data.Time/7, sim_data.Data(:, plot_index(1)), 'LineWidth', 12, 'Color', 'black', 'LineStyle', '-');
hold on;

delete(m1.Events);
stop_time = 1100;
sim_data = model_sim(m1, stop_time);
plot(sim_data.Time/7, sim_data.Data(:, plot_index(1)), 'LineWidth', 12, 'Color', 'black', 'LineStyle', ':');
hold on;

ylim([totC_h-0.08*(totC_p-totC_h) totC_p+0.6*(totC_p-totC_h)]);
ylabel('Keratinocytes/mm^2', 'FontSize', 84);

yyaxis right;
% drawing an empty line to display the legend properly
line(NaN,NaN,'LineWidth',3,'LineStyle','none','Marker','^','MarkerSize', 25, 'Color','red', 'MarkerFaceColor', 'red');
scatter(time_pasis/7, pasis(index,:), 2000, '^', 'LineWidth', 3, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red');

ylim([0-0.05*pasis(index,1) pasis(index,1)+0.6*pasis(index,1)]);
ylabel('PASI', 'FontSize', 96);
hold on;

xlim([-0.5 13]);
xlabel('Time (weeks)', 'FontSize', 96);

legend([string(['   Model simulation (with' char(10) '   immune stimulus)']) ...
        string(['   Model simulation']) ...
        strjoin(string(['   PASI (Patient ID=' num2str(data.ID(index)) ';' char(10) '  ' data.THERAPY(index) ')']))]);

yyaxis left;
rectangle('Position', [1 1e5 3 6e4], 'FaceColor', 'y', 'LineWidth', 3);
text(1.2, 1.3e5, string(['Immune' char(10) 'Stimulus']), ...
                'FontName', 'Arial', ...
                'FontSize', 72);    
    
    
    
    