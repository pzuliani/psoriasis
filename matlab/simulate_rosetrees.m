% sbioloadproject('psor.v7.1.sbproj','m1')
sbioloadproject('simple-cell-cycle.sbproj','m1')

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

data = readtable("~/psoriasis/data/pasis_and_doses.xlsx");

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
            
% % Basic model simulation
% figure;
% 
% t_stim = 1000;
% plot_legend = [];

totC_p = 2.3386e+05;
totC_h = 8.2614e+04;

% figure;
for p_id = 218:224
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
    
    delete(m1.Events);
    addevent(m1, 'time>=150', 't_stim=1600');
    addevent(m1, 'time>=154', 't_stim=0');
    a_time = 1;

    for i=1:30
        if ~isnan(doses(index,i))
            addevent(m1, ['time>' num2str(time_doses(i)+300)], ['uv_dose=' num2str(doses(index,i))]);
            addevent(m1, ['time>=' num2str(time_doses(i)+a_time+300)], 'uv_dose=0');
        end
    end
    
    disp(p_id);
    
    if(p_id == 201)
        m1 = sbml_set_parameter_value(m1, "uv_eff", 1e-5);
    end

    if(p_id == 206)
        m1 = sbml_set_parameter_value(m1, "uv_eff", 3e-5);
    end

    if(p_id == 213)
        m1 = sbml_set_parameter_value(m1, "uv_eff", 2e-5);
    end

    if(p_id == 218)            
        m1 = sbml_set_parameter_value(m1, "uv_eff", 2.5e-5);
    end
    
    if(p_id == 219)            
        m1 = sbml_set_parameter_value(m1, "uv_eff", 2.2e-5);
    end

    if(p_id == 220)
        m1 = sbml_set_parameter_value(m1, "uv_eff", 1.7e-5);
    end

    if(p_id == 224)
        m1 = sbml_set_parameter_value(m1, "uv_eff", 3e-5);
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
    set(gca, 'FontName', 'Arial')
    yyaxis left
    
    if(p_id ~= 220 && p_id ~= 224 && p_id ~= 219)
        plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(1)), 'LineWidth', 12, 'LineStyle', ':', 'Color', 'black');
        hold on;
    end

    if(p_id == 201)
        addevent(m1, 'time>=324', 't_stim=500');
        addevent(m1, 'time>=356', 't_stim=0');
%         rectangle('Position', [24/7 5.5e4 32/7 2e4*150/700], 'FaceColor', [0.4940, 0.1840, 0.5560]);
    end

    if(p_id == 206)
        addevent(m1, 'time>=314', 't_stim=1200');
        addevent(m1, 'time>=324', 't_stim=0');
%         rectangle('Position', [18/7 5.5e4 4/7 2e4*700/700], 'FaceColor', [0.4940, 0.1840, 0.5560]);
    end

    if(p_id == 213)
        addevent(m1, 'time>=310', 't_stim=700');
        addevent(m1, 'time>=340', 't_stim=0');
%         rectangle('Position', [10/7 5.5e4 30/7 2e4*300/700], 'FaceColor', [0.4940, 0.1840, 0.5560]);
    end

    if(p_id == 218)            
        addevent(m1, 'time>=324', 't_stim=1000');
        addevent(m1, 'time>=356', 't_stim=0');
%         rectangle('Position', [24/7 5.5e4 32/7 2e4*300/700], 'FaceColor', [0.4940, 0.1840, 0.5560]);
    end
    
    sim_data = model_sim(m1, stop_time);
    
    plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(1)), 'LineWidth', 12, 'Color', 'black', 'LineStyle', '-');
    hold on;

    set(gca,'FontSize',48);
    xlim([0 12]);

    ylim([totC_h-0.1*(totC_p-totC_h) totC_p+0.1*(totC_p-totC_h)]);
    xlabel('Time (weeks)', 'FontSize', 72);
    ylabel('Cells/mm^2', 'FontSize', 72);

    yyaxis right
    scatter((time_pasis+300-300)/7, pasis(index, :), 1000, '^', 'LineWidth', 3, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red');
    hold on;
    pasi_min = 0;
    pasi_max = pasis(index, 1);
    ylim([pasi_min-0.1*(pasi_max-pasi_min) pasi_max+0.1*(pasi_max-pasi_min)]);
    ylabel('PASI', 'FontSize', 72, 'Color', 'r');

    %         plot(time_doses+300, doses(index,:), 'LineWidth', 6, 'LineStyle', '-');        

%         ylabel('J/cm2');

%         legend([sim_data.DataNames(plot_index(1)) ['Patient ' num2str(data.ID(index)) ' PASI'] ['Patient ' num2str(data.ID(index)) ' UVB']]); 

%         legend([string(['   Model simulation']) ...
%                 string(['   Rescaled PASI' char(10) '   (Patient ID=' num2str(data.ID(index)-200) ')'])]); 
    
    yyaxis left

    if(p_id == 201)
        rectangle('Position', [24/7 5e4 32/7 2e4*500/700], 'FaceColor', 'y', 'LineWidth', 3);
        text(24/7+0.7, 5.8e4, 'Immune Stimulus', ...
                        'FontName', 'Arial', ...
                        'FontSize', 48);
    end

    if(p_id == 206)
        rectangle('Position', [14/7 5e4 11/7 2e4*1200/700], 'FaceColor', 'y', 'LineWidth', 3);
        text(14/7, 7e4, ['Immune' char(10) 'Stimulus'], ...
                    'FontName', 'Arial', ...
                    'FontSize', 48);
    end

    if(p_id == 213)
        rectangle('Position', [10/7 5e4 30/7 2e4*700/700], 'FaceColor', 'y', 'LineWidth', 3);
        text(10/7+0.5, 6.2e4, ['Immune Stimulus'], ...
                'FontName', 'Arial', ...
                'FontSize', 48);
    end

    if(p_id == 218)            
        rectangle('Position', [24/7 5e4 32/7 2e4*1000/700], 'FaceColor', 'y', 'LineWidth', 3);
        text(24/7+0.7, 6.5e4, ['Immune Stimulus'], ...
                'FontName', 'Arial', ...
                'FontSize', 48);
    end
    
%     if(p_id ~= 220 && p_id ~= 224 && p_id ~= 219)
%         line(NaN,NaN,'LineWidth',12,'LineStyle','-','Color',[0.4940, 0.1840, 0.5560]);
%     end

    line(NaN,NaN,'LineWidth',3,'LineStyle','none','Marker','^','MarkerSize', 25, 'Color','red', 'MarkerFaceColor', 'red');
    
    if(p_id ~= 220 && p_id ~= 224 && p_id ~= 219)
        legend([string(['   Model simulation']) ...
                string(['   Model simulation (with' char(10) '   immune stimulus)']) ...
                string(['   PASI (Patient ID=' num2str(data.ID(index)-200) ')']) ... 
                ], 'FontSize', 56);
    else
        legend([string(['   Model simulation']) ...
                string(['   PASI (Patient ID=' num2str(data.ID(index)-200) ')']) ... 
                ], 'FontSize', 56);
    end    

end

