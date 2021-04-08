% This script performs analysis of the follow-up data and compares
% predictions made by the model with the patients' data
%
% Author: Fedor Shmarov


% SBML import of the model
m1 = sbmlimport('../models/psor_v8_4.xml');

% times when PASI values are recorded
time_pasis = [];
cur_pasis_time = 0;
for i=1:13
    time_pasis = [time_pasis cur_pasis_time];
    cur_pasis_time = cur_pasis_time + 7;
end

% setting the times for when the UVB doses are administered
time_doses = [];
% UVB admission pattern (days) for every week (0 = Monday, 1 = Tuesday, ...)
cur_doses_time = [0 2 4];
% generating the doses days for 11 weeks of therapy
for i=1:11
    time_doses = [time_doses cur_doses_time];
    cur_doses_time = cur_doses_time + 7;
end

% importing the data from an XLSX file
data = readtable("../../data/data_matlab.xlsx");

% extracting only the patients whose IDs are in a particular range
data = data((data.ID > 0 & data.ID <= 100),:);
        
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
        
dc_stims = [data.DC_STIM_1 data.DC_STIM_2 data.DC_STIM_3 ...
            data.DC_STIM_4 data.DC_STIM_5 data.DC_STIM_6 ...
            data.DC_STIM_7 data.DC_STIM_8 data.DC_STIM_9 data.DC_STIM_10];
        
pasis_scaled = pasis;
for i = 1:length(pasis_scaled)
    pasis_scaled(i,:) = pasis_scaled(i,:)/pasis_scaled(i,1);
end

stop_time = 735;

count = 0;

doses_num = [];
doses_used = [];

pasis_vector = [];

pasi_outcome = [];
last_fu_month = [];
with_fu_pasi = 0;

num_pasi_points = 13;
% iterating through all the IDs in the data
for k=1:length(data.ID)
    data_row = data(data.ID == data.ID(k), :);
    p_id = data.ID(k);
%     data(data.ID == p_id, "TWO_YEAR_RELAPSE_PRED") = {NaN};
    % obtaining the index of the row for the patient
    for i=1:length(data.ID)
        if(p_id == data.ID(i))
            index = i;
            break;
        end
    end
    % skipping the loop iteration if no UVB doses are present
    if(isnan(data_row.UVB_DOSE_TOTAL))
        data(data.ID == data_row.ID, ["UV_EFF_W_"]+num2str(num_pasi_points)) = {"NA"};
        continue;
    end
    
%     if(string(cell2mat(data.LAST_FU_PASI(index))) == "WD" || string(cell2mat(data.LAST_FU_PASI(index))) == "LTFU" || ...
%             data.LAST_FU_MONTH(index) == 19)
%         continue;
%     end
    
    delete(m1.Events);
    addevent(m1, 'time>=150', 'dc_stim=10000');
    addevent(m1, 'time>=154', 'dc_stim=0');
    
    % active apoptosis pariod in days
    a_time = 0.99999;

    num = 0;
    for i=1:30
        if ~isnan(doses(index,i))
            addevent(m1, ['time>' num2str(time_doses(i)+300)], ['uv_dose=' num2str(doses(index,i))]);
            addevent(m1, ['time>=' num2str(time_doses(i)+a_time+300)], 'uv_dose=0');
            num = num + 1;
            doses_used = [doses_used doses(index,i)];
        end
    end
    doses_num = [doses_num num];
    
    best_err = [1e3];
    best_uv_eff = 1;
    
    Time_full = transpose(time_pasis+300);
    PASI_full = transpose(pasis_scaled(index,:));
    
    last_pasi_index = length(PASI_full);
    for i = length(PASI_full):-1:1
        if ~isnan(PASI_full(i))
            last_pasi_index = i;
            break;
        end
    end
   
    inc = 0;
    for i=1:last_pasi_index-1
        addevent(m1, ['time>' num2str(300+inc)], ['dc_stim=dc_stim_' num2str(i)]);
        addevent(m1, ['time>=' num2str(300+inc+6.99)], 'dc_stim=0');
        m1 = sbml_set_parameter_value(m1, ['dc_stim_' num2str(i)], 0);
        inc = inc + 7;
    end
    
    species_to_plot = ["PASI"];
    plot_index = [];
    for i=1:length(species_to_plot)
        for j=1:length(m1.Species)
            if species_to_plot(i) == m1.Species(j).Name
                plot_index = [plot_index j];
                break;
            end
        end
    end
    
    m1 = sbml_set_parameter_value(m1, "uv_eff", data_row.UV_EFF_W_13);

    for i=1:length(dc_stims(index,:))
        m1 = sbml_set_parameter_value(m1, ['dc_stim_' num2str(i)], dc_stims(index,i));
    end
        
    sim_data = model_sim(m1, stop_time);
    last_pasi = sim_data.Data(end, plot_index(1))*pasis(index,1);

    disp("Patient " + num2str(p_id))
    disp("PASI relapse month: " + num2str(data_row.LAST_FU_MONTH));
    disp("PASI prediction after 2 years: " + num2str(last_pasi));
    if(last_pasi >= 0.1)
        disp("Relapse");
        data(data.ID == p_id, "TWO_YEAR_RELAPSE_PRED") = {1};
    else
        disp("Remission");
        data(data.ID == p_id, "TWO_YEAR_RELAPSE_PRED") = {0};
    end
    disp("----------");
    
    
    fig = figure('Units','normalized','OuterPosition',[0 0 1 1],'Visible','off');    
    set(fig,'defaultAxesColorOrder',[[0 0 0]; [1 0.4 1]]);
    set(gca, 'FontName', 'Arial');

    yyaxis right;
    h = bar(0.5:1:9.5, dc_stims(index,i), 'BarWidth', 1);
    set(h, "FaceAlpha", 0.3);
    hold on;
    ytickformat('%.0f');
    ylabel('arbitrary');
    ylim([0 6000]);
    ax = gca;
    ax.YAxis(2).Exponent = 3;
    
    yyaxis left;
    plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(1))*pasis(index,1), 'LineWidth', 8, 'Color', 'black', 'LineStyle', '-');
    hold on;

    % drawing an empty line to display the legend properly
    line(NaN,NaN,'LineWidth',8,'LineStyle','none','Marker','x','MarkerSize', 40, 'Color','r');
    l1 = line(NaN,NaN,'LineWidth',1,'LineStyle','none','Marker','s','MarkerSize', 40, 'MarkerFaceColor',[1 0.4 1]);
    scatter((time_pasis(1:end)+300-300)/7, pasis(index,1:end), 4000, 'x', 'LineWidth', 8, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red');
    ylim([0-0.1*max(pasis(index,:)) max(pasis(index,:))+0.1*max(pasis(index,:))]);
    ylabel('PASI');
    hold on;

    if(isnan(data.LAST_FU_PASI(index)))
        scatter(data.LAST_FU_MONTH(index)*4+last_pasi_index, data.LAST_FU_PASI(index), 4000, 'x', 'LineWidth', 8, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red')
        xlim([-0.5 data.LAST_FU_MONTH(index)*4+last_pasi_index+12]);
        with_fu_pasi = with_fu_pasi + 1;
        pasi_outcome = [pasi_outcome 1-pasis(index, last_pasi_index)/pasis(index, 1)];
        last_fu_month = [last_fu_month data.LAST_FU_MONTH(index)];
    else
        xlim([-0.5 12]);
    end
    
    xlabel('Time (weeks)');
    set(gca,'FontSize',48);
    title(string(['Patient ID = ' num2str(data.ID(index)) ', UVB efficacy = ' num2str(data_row.UV_EFF_W_13, '%.3f')]));
    legend([string([' Model simulation']) ... 
            string([' Patients data']) ...
            string([' Immune stimulus'])]);
    work_dir = '../../img/ode-v8-4/relapse/';
    saveas(fig, [work_dir 'patient_relapse_' num2str(p_id)], 'png');
end
% saving the data-table to a XLSX file
writetable(data, "../../data/data_matlab.xlsx");

% getting all patients with predicted remission period over two years
pred_remission_data = data((data.TWO_YEAR_RELAPSE_PRED==0 & ~isnan(data.LAST_FU_PASI) & data.LAST_FU_MONTH <= 18),:);
% getting all patients with predicted relapse within two years
pred_relapse_data = data((data.TWO_YEAR_RELAPSE_PRED==1 & ~isnan(data.LAST_FU_PASI) & data.LAST_FU_MONTH <= 18),:);
% Kuskal-Wallis test for the LAST_FU_MONTH variables in the two groups above
kruskalwallis([pred_remission_data.LAST_FU_MONTH; pred_relapse_data.LAST_FU_MONTH], [pred_remission_data.TWO_YEAR_RELAPSE_PRED; pred_relapse_data.TWO_YEAR_RELAPSE_PRED])

figure;
boxplot([pred_remission_data.LAST_FU_MONTH; pred_relapse_data.LAST_FU_MONTH], [repelem("Remission", length(pred_remission_data.TWO_YEAR_RELAPSE_PRED)); repelem("Relapse", length(pred_relapse_data.TWO_YEAR_RELAPSE_PRED))])
xlabel("Predicted group");
ylabel("Month of relapse");






