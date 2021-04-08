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
   
totC_p = 251431;
totC_h = 90000;

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

% d2 = adddose(m1, 'Repeat', 'repeat');
% d2.Amount = 40000;
% d2.TargetName = 'AdaSQ';
% d2.Rate = 0;
% d2.StartTime = 7;
% d2.RepeatCount = 20;
% d2.Interval = 14;
% d2.Active = true;
% 
% species_to_plot = ["totC" "AdaT" "TNF"];
% 
% plot_index = [];
% for j=1:length(m1.Species)
%     if(ismember(m1.Species(j).Name, species_to_plot))
%         plot_index = [plot_index j];
%     end
% end
% 
% stop_time = 735;
% sim_data = model_sim(m1, stop_time);
% 
% figure;
% subaxis(5, 1, [1 2], 'Spacing',0.0,'Padding',0.005,'Margin',0.005);
% plot(sim_data.Time/7, sim_data.Data(:, plot_index(1)), 'LineWidth', 8, 'Color', 'black', 'LineStyle', '-');
% legend(['Total number of' char(10) 'keratinocytes'], 'FontSize', 42);
% 
% ylim([totC_h-0.08*(totC_p-totC_h) totC_p+0.1*(totC_p-totC_h)]);
% % yline(totC_h);
% % yline(totC_p);
% xlim([-0.5 12]);
% set(gca,'XTickLabel',[]);
% xlabel('');
% set(gca,'FontSize',30);
% ylabel('Cells/mm^2', 'FontSize', 42);
% 
% subaxis(5, 1, 3, 'Spacing',0.0,'Padding',0.005,'Margin',0.005);
% plot(sim_data.Time/7, sim_data.Data(:, plot_index(2)), 'LineWidth', 6, 'Color', 'blue', 'LineStyle', '-');
% legend(['Adalimumab'], 'FontSize', 42);
% 
% ylim([0 100])
% xlim([-0.5 12]);
% set(gca,'XTickLabel',[]);
% xlabel('');
% set(gca,'FontSize',30);
% ylabel('mg', 'FontSize', 42);
% 
% subaxis(5, 1, 4, 'Spacing',0.0,'Padding',0.005,'Margin',0.005);
% plot(sim_data.Time/7, sim_data.Data(:, plot_index(3)), 'LineWidth', 6, 'Color', 'red', 'LineStyle', '-');
% legend(['TNF\alpha'], 'FontSize', 42);
% 
% ylim([0 150])
% xlim([-0.5 12]);
% set(gca,'FontSize',30);
% ylabel(['Arbitrary'], 'FontSize', 42);
% xlabel('Time (weeks)', 'FontSize', 42);
% 
% return

% figure;
count = 1;
for p_id = 6004:6004
    index = -1;
    for i=1:length(data.ID)
        if(p_id == data.ID(i))
            index = i;
            break;
        end
    end
    
    if(index == -1)
        continue;
    end
    
    disp("-----");
    disp(p_id);
    disp(data.THERAPY(index));
    
    d2 = sbiodose('Repeat', 'repeat');
    
    if(data.THERAPY(index) == "Adalimumab")
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

    Time = transpose(time_pasis);
    totC = transpose(pasis_scaled(index,:));
    
    tbl = table(Time, totC);
    
%     if(p_id == 5010)
%         delete(m1.Events);
%         addevent(m1, 'time>=7', 'dc_stim=1000');
%         addevent(m1, 'time>=28', 'dc_stim=0');
%     end
    
    grpData = groupedData(tbl, '', 'Time');
    responseMap = 'totC = totC';
%     fitAlg = 'fminsearch';
    fitAlg = 'lsqnonlin';
    if(data.THERAPY(index) == "Adalimumab")
        estimated = estimatedInfo({'ada2', 'ada2tnf', 'ada20'}, 'InitialValue', [0.05 0.01 0.1], 'Bounds', [0.05 0.2; 1e-4 1; 0.1 0.5]);
        fitConst = sbiofit(m1, grpData, responseMap, estimated, d2, fitAlg);
        m1 = sbml_set_parameter_value(m1, "ada2", fitConst.ParameterEstimates.Estimate(1));
        m1 = sbml_set_parameter_value(m1, "ada2tnf", fitConst.ParameterEstimates.Estimate(2));
        m1 = sbml_set_parameter_value(m1, "ada20", fitConst.ParameterEstimates.Estimate(3));
%         m1 = sbml_set_parameter_value(m1, "tnf_min", fitConst.ParameterEstimates.Estimate(4));
        disp(fitConst.ParameterEstimates);
    end
    if(data.THERAPY(index) == "Ustekinumab")
        estimated = estimatedInfo({'ust2','ust2il23', 'ust20'}, 'InitialValue', [0.02 0.2 0.5], 'Bounds', [0.01 1; 0.01 0.5; 0.01 0.5]);
        fitConst = sbiofit(m1, grpData, responseMap, estimated, d2, fitAlg);
        m1 = sbml_set_parameter_value(m1, "ust2", fitConst.ParameterEstimates.Estimate(1));
        m1 = sbml_set_parameter_value(m1, "ust2il23", fitConst.ParameterEstimates.Estimate(2));
        m1 = sbml_set_parameter_value(m1, "ust20", fitConst.ParameterEstimates.Estimate(3));
%         m1 = sbml_set_parameter_value(m1, "il23_min", fitConst.ParameterEstimates.Estimate(4));
        disp(fitConst.ParameterEstimates);
    end
    
    stop_time = 1100;
    sim_data = model_sim(m1, stop_time);

    species_to_plot = ["totC" "AdaT"];

    plot_index = [];
    for i=1:length(m1.Species)
        if(ismember(m1.Species(i).Name, species_to_plot))
            plot_index = [plot_index i];
        end
    end
    
%     subaxis(2, 2, count, 'Spacing',0.01,'Padding',0.04,'Margin',0.025);

%     sim_data = model_sim(m1, stop_time);

    fig = figure;
    set(fig,'defaultAxesColorOrder',[[0 0 0]; [1 0 0]]);
    set(gca, 'FontName', 'Arial')
    set(gca, 'FontSize', 64); % was 64
    
    yyaxis left;
    plot(sim_data.Time/7, sim_data.Data(:, plot_index(1)), 'LineWidth', 12, 'Color', 'black', 'LineStyle', '-');
    hold on;
    
    ylim([totC_h-0.08*(totC_p-totC_h) totC_p+0.1*(totC_p-totC_h)]);
    ylabel('Keratinocytes/mm^2', 'FontSize', 84); % was 96

    yyaxis right;
    % drawing an empty line to display the legend properly
    line(NaN,NaN,'LineWidth',3,'LineStyle','none','Marker','^','MarkerSize', 25, 'Color','red', 'MarkerFaceColor', 'red');
    scatter(time_pasis/7, pasis(index,:), 2000, '^', 'LineWidth', 3, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red');
%         scatter((time_pasis_ext+300-300)/7, pasis_scaled(index,:), 4000, 'x', 'LineWidth', 6, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red');
    ylim([0-0.05*pasis(index,1) pasis(index,1)+0.1*pasis(index,1)]);
    ylabel('PASI', 'FontSize', 96); % was 96
    hold on;

    xlim([-0.5 13]);
    xlabel('Time (weeks)', 'FontSize', 96); % was 96
        
    legend([string(['   Model simulation']) ...
            strjoin(string(['   PASI (Patient ID=' num2str(data.ID(index)) ';' char(10) '  ' data.THERAPY(index) ')']))], ...
            'FontSize', 72);


%     if(count == 4)
%         count = 0;
%         figure;
%     end
% 
%     count = count + 1;
    
%     figure;
%     plot(sim_data.Time/7, sim_data.Data(:, plot_index(2)), 'LineWidth', 12, 'Color', 'black', 'LineStyle', '-');
%     hold on;

    removedose(m1, 'Repeat');

end
