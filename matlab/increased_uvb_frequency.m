% In this script we increase the frequency of UVB irradiation from
% 3 times a week to 5 times a week for those patients who flared in the 
% first 3 weeks.
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
% standard UVB admission pattern (days) (0 = Monday, 1 = Tuesday, ...)
cur_doses_time = [0 2 4];
% generating the doses days for 11 weeks of therapy
for i=1:11
    time_doses = [time_doses cur_doses_time];
    cur_doses_time = cur_doses_time + 7;
end


% new time verctor for the modified irradiation regime
time_doses_new = [];
% UVB admission pattern (days) for the first 3 weeks (0 = Monday, 1 = Tuesday, ...)
cur_doses_time = [0 2 4];
% generating the doses days for the first 3 weeks of therapy
for i=1:2
    time_doses_new = [time_doses_new cur_doses_time];
    cur_doses_time = cur_doses_time + 7;
end
% UVB admission pattern (days) for the remaining doses (0 = Monday, 1 = Tuesday, ...)
cur_doses_time = [14 15 16 17 18];
% generating the doses days for 5 weeks max of the more intense regime;
% the resulting time vector will have a maximum of 34 doses
for i=1:5
    time_doses_new = [time_doses_new cur_doses_time];
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

count = 0;

doses_num = [];
doses_used = [];

pasis_vector = [];

pasi_outcome = [];
last_fu_month = [];
with_fu_pasi = 0;

% simulating the model for 2 years (735 days)
stop_time = 735;
% simulating everyone's trajectory for the first 
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
%         data(data.ID == data_row.ID, ["UV_EFF_W_"]+num2str(num_pasi_points)) = {"NA"};
        continue;
    end
    % skipping if the patient didn't flare in the first 3 weeks
    if(sum(dc_stims(index,1:3)) == 0)
        continue;
    end
    
    %% simulating standard UVB regime
    % inducing psoriasis via a strong immune stimulus for 4 days
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
        end
    end
    
    % setting the efficacy parameter value
    m1 = sbml_set_parameter_value(m1, "uv_eff", data_row.UV_EFF_W_13);
    % defining the immune stimuli
    inc = 0;
    for i=1:length(dc_stims(index,:))
        addevent(m1, ['time>' num2str(300+inc)], ['dc_stim=dc_stim_' num2str(i)]);
        addevent(m1, ['time>=' num2str(300+inc+6.99)], 'dc_stim=0');
        if(isnan(dc_stims(index,i)))
            m1 = sbml_set_parameter_value(m1, ['dc_stim_' num2str(i)], 0);
        else
            m1 = sbml_set_parameter_value(m1, ['dc_stim_' num2str(i)], dc_stims(index,i));    
        end
        inc = inc + 7;
    end
        
    % simulating the model
    sim_data = model_sim(m1, stop_time);
    
    
    %% simulating modified UVB regime
    % inducing psoriasis via a strong immune stimulus for 4 days
    delete(m1.Events);
    addevent(m1, 'time>=150', 'dc_stim=10000');
    addevent(m1, 'time>=154', 'dc_stim=0');
    
    % active apoptosis pariod in days
    a_time = 0.99999;

    num = 0;
    for i=1:30
        if ~isnan(doses(index,i))
            addevent(m1, ['time>' num2str(time_doses_new(i)+300)], ['uv_dose=' num2str(doses(index,i))]);
            addevent(m1, ['time>=' num2str(time_doses_new(i)+a_time+300)], 'uv_dose=0');
        end
    end
    
    % setting the efficacy parameter value
    m1 = sbml_set_parameter_value(m1, "uv_eff", data_row.UV_EFF_W_13);
    % defining the immune stimuli
    inc = 0;
    for i=1:length(dc_stims(index,:))
        addevent(m1, ['time>' num2str(300+inc)], ['dc_stim=dc_stim_' num2str(i)]);
        addevent(m1, ['time>=' num2str(300+inc+6.99)], 'dc_stim=0');
        if(isnan(dc_stims(index,i)))
            m1 = sbml_set_parameter_value(m1, ['dc_stim_' num2str(i)], 0);
        else
            m1 = sbml_set_parameter_value(m1, ['dc_stim_' num2str(i)], dc_stims(index,i));    
        end
        inc = inc + 7;
    end
        
    % simulating the model
    sim_data_new = model_sim(m1, stop_time);
    
    
    disp(['Patient ' num2str(p_id)]);
    
    %% creating the figure here
    % choosing what species to plot
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
    
    % producing the figure
    fig = figure('Units','normalized','OuterPosition',[0 0 1 1],'Visible','off');    
    set(fig,'defaultAxesColorOrder',[[0 0 0]; [1 0.4 1]]);
    set(gca, 'FontName', 'Arial');

    yyaxis right;
    h = bar(0.5:1:9.5, dc_stims(index,:), 'BarWidth', 1);
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
    plot((sim_data_new.Time-300)/7, sim_data_new.Data(:, plot_index(1))*pasis(index,1), 'LineWidth', 8, 'Color', 'blue', 'LineStyle', '-');
    hold on;
    
    % drawing an empty line to display the legend properly
    line(NaN,NaN,'LineWidth',8,'LineStyle','none','Marker','x','MarkerSize', 40, 'Color','r');
    l1 = line(NaN,NaN,'LineWidth',1,'LineStyle','none','Marker','s','MarkerSize', 40, 'MarkerFaceColor',[1 0.4 1]);
    scatter((time_pasis(1:end)+300-300)/7, pasis(index,1:end), 4000, 'x', 'LineWidth', 8, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red');
    ylim([0-0.1*max(pasis(index,:)) max(pasis(index,:))+0.1*max(pasis(index,:))]);
    ylabel('PASI');
    hold on;

    xlim([-0.5 12]);
%     xlim([-0.5 105]);
    
    xlabel('Time (weeks)');
    set(gca,'FontSize',48);
    title(string(['Patient ID = ' num2str(data.ID(index)) ', UVB efficacy = ' num2str(data_row.UV_EFF_W_13, '%.3f')]));
    legend([string([' Standard UVB regime']) ... 
            string([' Modifed UVB regime']) ...
            string([' Patients data']) ...
            string([' Immune stimulus'])]);
    work_dir = '../../img/ode-v8-4/increased_uvb_frequency/';
    saveas(fig, [work_dir 'patient_' num2str(p_id)], 'png');
end

