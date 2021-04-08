% sbioloadproject('psor.v7.1.sbproj','m1')
% sbioloadproject('simple-cell-cycle.sbproj','m1')
% sbioloadproject('psor.v8.1.sbproj','m1')
% sbioloadproject('psor.v8.3.sbproj','m1')
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

% % Basic model simulation
% figure;
% 
% t_stim = 1000;
% plot_legend = [];

% totC_p = 2.294490973051878e+05;
% totC_h = 8.105685676778936e+04;

totC_p = 266011.65;
totC_h = 79828;

pasis_scaled = pasis;
for i = 1:length(pasis_scaled)
%     pasis_scaled(i,:) = totC_h + (totC_p - totC_h)*(pasis_scaled(i,:)/max(pasis_scaled(i,:)));
    pasis_scaled(i,:) = totC_h + (totC_p - totC_h)*(pasis_scaled(i,:)/pasis_scaled(i,1));
end

species_to_plot = ["totC" "UV"];

plot_index = [];
for j=1:length(m1.Species)
    if(ismember(m1.Species(j).Name, species_to_plot))
        plot_index = [plot_index j];
    end
end

stop_time = 735;

for i=1:33
    addevent(m1, ['time>' num2str(time_doses(i)+300)], ['uv_dose=' num2str(uv_protocol(i))]);
    addevent(m1, ['time>=' num2str(time_doses(i)+2+300)], 'uv_dose=0');
end

count = 1;
uv_eff = [];
uv_eff_3_weeks = [];
err = [];
err_3_weeks = [];
class = [];
med = [];
count = 1;
% time_pasis_copy = time_pasis;
% figure;
for p_id = 95:95
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
    
    class = [class data.CLASS(index)];
%     med = [med data.MED(index)];
    
    delete(m1.Events);
    addevent(m1, 'time>=150', 'dc_stim=10000');
    addevent(m1, 'time>=154', 'dc_stim=0');
    
    a_time = 0.99999;
    
    for i=1:30
        if ~isnan(doses(index,i))
            addevent(m1, ['time>' num2str(time_doses(i)+300)], ['uv_dose=' num2str(doses(index,i))]);
            addevent(m1, ['time>=' num2str(time_doses(i)+a_time+300)], 'uv_dose=0');
        end
    end
    
    disp(p_id);
    disp(data.CLASS(index));

    uv_eff = 0.22;
    
    m1 = sbml_set_parameter_value(m1, "uv_eff", uv_eff);
    m1 = sbml_set_parameter_value(m1, "arrest", 0.0);
    
    stop_time = 735;
    sim_data = model_sim(m1, stop_time);

    species_to_plot = ["totC" "UV"];

    plot_index = [];
    for i=1:length(m1.Species)
        if(ismember(m1.Species(i).Name, species_to_plot))
            plot_index = [plot_index i];
        end
    end
    
    Time = transpose(time_pasis+300);
    totC = transpose(pasis_scaled(index,:));
    
%     err = [err square_error(Time, totC, sim_data.Time, sim_data.Data(:, plot_index(1)))];
    
    fig = figure('units','normalized','outerposition',[0 0 1 1],'visible','off');
    set(fig,'defaultAxesColorOrder',[[0 0 0]; [1 0 0]]);
    set(gca, 'FontName', 'Arial')

%     subaxis(2, 1, 1, 'Spacing',0.0,'Padding',0.005,'Margin',0.005);

    yyaxis left;
%     plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(1)), 'LineWidth', 12, 'Color', 'black', 'LineStyle', '-');
%     hold on;
    
%     if(p_id == 11)
%         addevent(m1, 'time>=307', 't_stim=6000');
%         addevent(m1, 'time>=314', 't_stim=0');
%         addevent(m1, 'time>=314', 't_stim=3000');
%         addevent(m1, 'time>=321', 't_stim=0');
%     end
%     if(p_id == 57)
%         addevent(m1, 'time>=300', 't_stim=1000');
%         addevent(m1, 'time>=314', 't_stim=0');
% %         addevent(m1, 'time>=328', 't_stim=300');
% %         addevent(m1, 'time>=356', 't_stim=0');
%     end
%     if(p_id == 92)
%         addevent(m1, 'time>=300', 't_stim=2500');
%         addevent(m1, 'time>=318', 't_stim=0');
%     end
    
    
    sim_data = model_sim(m1, stop_time);
    plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(1)), 'LineWidth', 12, 'Color', 'black', 'LineStyle', '-');
    hold on;
   
%     subaxis(2, 1, 2, 'Spacing',0.0,'Padding',0.005,'Margin',0.005);
%     plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(2)), 'LineWidth', 2, 'Color', 'black', 'LineStyle', '-');
%     hold on;
%     xlim([-0.5 12]);
%     ylim([0 20]);
    
    % altering the regime
    delete(m1.Events);
    addevent(m1, 'time>=150', 'dc_stim=10000');
    addevent(m1, 'time>=154', 'dc_stim=0');
    
%     if(p_id == 11)
%         addevent(m1, 'time>=307', 't_stim=6000');
%         addevent(m1, 'time>=314', 't_stim=0');
%         addevent(m1, 'time>=314', 't_stim=3000');
%         addevent(m1, 'time>=321', 't_stim=0');
%     end
%     if(p_id == 57)
% %         addevent(m1, 'time>=300', 't_stim=700');
% %         addevent(m1, 'time>=328', 't_stim=0');
%     end
%     if(p_id == 92)
%         addevent(m1, 'time>=300', 't_stim=2500');
%         addevent(m1, 'time>=318', 't_stim=0');
%     end

%     time_doses = [0 2 4 7 9 11 14 16 18 21 22 23 24 25 28 29 30 31 32 35 37 ...
%                     39 42 44 46 49 51 53 56 58 60 63 65];
%     time_doses = [0 2 4 7 9 11 14 16 18 21 22 23 24 25 28 29 30 31 32 35 37 ...
%                 39 42 44];    
           
      time_doses = [0 2 4 ...
                    7 9 11 ...
                    14 16 18 ...
                    21 22 23 24 25 ...
                    28 29 30 31 32 ...
                    35 36 37 38 39 ...
                    42 43 44 45 46 ...
                    49];
                
    for i=1:30
        if ~isnan(doses(index,i))
            addevent(m1, ['time>' num2str(time_doses(i)+300)], ['uv_dose=' num2str(doses(index,i))]);
            addevent(m1, ['time>=' num2str(time_doses(i)+a_time+300)], 'uv_dose=0');
        end
    end
    
    sim_data = model_sim(m1, stop_time);
    
%     err = [err square_error(Time, totC, sim_data.Time, sim_data.Data(:, plot_index(1)))];

%     subaxis(2, 1, 1, 'Spacing',0.0,'Padding',0.005,'Margin',0.005);
    
    yyaxis left;
    plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(1)), 'LineWidth', 12, 'Color', 'black', 'LineStyle', ':');
    hold on;
    
% %     rectangle('Position', [-1 5e4 1 4.8e4], 'FaceColor', 'w', 'LineWidth', 3);
%     text(-1.1, 5.3e4, 'UVB', ...
%                         'FontName', 'Arial', ...
%                         'FontSize', 42);
%     
%     rectangle('Position', [0 5.4e4 56/7 2.4e4], 'FaceColor', 'w', 'LineWidth', 3);
%     text(3.4, 6.7e4, '3 per week', ...
%                         'FontName', 'Arial', ...
%                         'FontSize', 42);
%     
% %     rectangle('Position', [0 5e4 66/7 2.4e4], 'FaceColor', 'black', 'LineWidth', 3);
%     rectangle('Position', [0 3e4 39/7 2.4e4], 'FaceColor', 'w', 'LineWidth', 3);
%     rectangle('Position', [21/7 3e4 18/7 2.4e4], 'FaceColor', 'c', 'LineWidth', 3);
% %     rectangle('Position', [8 7.4e4 10/7 2.4e4], 'FaceColor', 'black', 'LineWidth', 3);
%     text(0.7, 4.3e4, '3 per week', ...
%                         'FontName', 'Arial', ...
%                         'FontSize', 42);
%                     
%     text(3.4, 4.3e4, '5 per week', ...
%                         'FontName', 'Arial', ...
%                         'FontSize', 42);
%                     
% %     text(5, 4.3e4, '3 per week', ...
% %                         'FontName', 'Arial', ...
% %                         'FontSize', 42);
% %     text(8.1, 8.7e4, 'No UV', ...
% %                         'FontName', 'Arial', ...
% %                         'FontSize', 42, ...
% %                         'Color', 'w');
%                       
%     text(8.2, 4.3e4, '- Altered regime', ...
%                         'FontName', 'Arial', ...
%                         'FontSize', 42, ...
%                         'Color', 'black');
%                     
%     text(8.2, 6.7e4, '- Regular regime', ...
%                         'FontName', 'Arial', ...
%                         'FontSize', 42, ...
%                         'Color', 'black');
                    
% % 
% %     rectangle('Position', [1 1.2e5 1 5e4], 'FaceColor', 'y', 'LineWidth', 3);
% %     rectangle('Position', [2 1.2e5 1 2.5e4], 'FaceColor', 'y', 'LineWidth', 3);
% %     rectangle('Position', [1.5 1.214e5 1 2.22e4], 'FaceColor', 'y', 'EdgeColor', 'y', 'LineWidth', 3);
% %     text(1.2, 1.34e5, 'Stimulus', ...
% %                     'FontName', 'Arial', ...
% %                     'FontSize', 42, ...
% %                     'Color', 'black');  
%     plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(1)), 'LineWidth', 12, 'Color', 'blue', 'LineStyle', '-');
%     hold on;

    ylim([totC_h-0.08*(totC_p-totC_h) totC_p+0.1*(totC_p-totC_h)]);
    ylabel('Cells/mm^2', 'FontSize', 30);

    yyaxis right;
    % drawing an empty line to display the legend properly
%     line(NaN,NaN,'LineWidth',6,'LineStyle','none','Marker','x','MarkerSize', 40, 'Color','r');
    %scatter((time_pasis+300-300)/7, pasis(index,:), 4000, 'x', 'LineWidth', 6, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red');
%     line(NaN,NaN,'LineWidth',3,'LineStyle','none','Marker','^','MarkerSize', 25, 'Color','black', 'MarkerFaceColor', 'red');
    
    line(NaN,NaN,'LineWidth',6,'LineStyle','none','Marker','x','MarkerSize', 40, 'Color','r');
    line(NaN,NaN,'LineWidth',6,'LineStyle','none','Marker','x','MarkerSize', 40, 'Color','blue');

%     scatter((time_pasis+300-300)/7, pasis(index, :), 1000, '^', 'LineWidth', 3, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'black');
    scatter((time_pasis(1:fit_pts)+300-300)/7, pasis(index,1:fit_pts), 4000, 'x', 'LineWidth', 6, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red');
    scatter((time_pasis(1:fit_pts)+300-300)/7, pasis(index,1:fit_pts), 4000, 'x', 'LineWidth', 6, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red');
    scatter((time_pasis(fit_pts+1:end)+300-300)/7, pasis(index,fit_pts+1:end), 4000, 'x', 'LineWidth', 6, 'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'blue');
    scatter((time_pasis(fit_pts+1:end)+300-300)/7, pasis(index,fit_pts+1:end), 4000, 'x', 'LineWidth', 6, 'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'blue');
 
    ylim([0-0.08*pasis(index,1) pasis(index,1)+0.1*pasis(index,1)]);
    ylabel('PASI', 'FontSize', 30);
    hold on;
    xlim([-0.5 12]);
    xlabel('Time (weeks)', 'FontSize', 30);
    
    title(string(['        Patient ID = ' num2str(data.ID(index)) ', CLASS = ' num2str(data.CLASS(index))]));
    legend([string(['   Regular regime']) ...
            string(['   Altered regime']) ...        
            string(['   PASI used for fitting' ...
                char(10) '   (UVB efficacy = ' num2str(uv_eff(end), '%.2f') ')']) ...
            string(['   Unused PASI value'])], 'FontSize', 30);
    
    set(gca,'FontSize', 40);
    saveas(fig, ['../../img/ode-v8-4/alter-regime/alter_regime_' num2str(p_id) '.png']);
            
   
    
%     subaxis(2, 1, 2, 'Spacing',0.0,'Padding',0.005,'Margin',0.005);
%     plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(2)), 'LineWidth', 2, 'Color', 'red', 'LineStyle', '-');
%     hold on;
%     xlim([-0.5 12]);
%     ylim([0 20]);    
        
end


