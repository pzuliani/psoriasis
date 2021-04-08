% This script performs modelling of the flares by estimating potential
% immune stimuli (by minimising the sum of squared errors) for each PASI
% trajectory, corresponding UVB doses and the "uv_eff" parameter value 
% stored in the "data" table.
% The script also generates figures with PASI data and model's PASI 
% output for the best fitting values of immune stimuli and saves them into
% the directory specified in the "work_dir" variable.
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

data_ids = [3, 15, 5, 11];

% extracting PASI trajectories        
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
        
% extracting UVB doses        
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
        
% obtaining scaled PASI trajectories: every PASI value is divided by the
% baseline PASI
pasis_scaled = pasis;
for i = 1:length(pasis_scaled)
%     pasis_scaled(i,:) = totC_h + (totC_p - totC_h)*(pasis_scaled(i,:)/max(pasis_scaled(i,:)));
    pasis_scaled(i,:) = pasis_scaled(i,:)/pasis_scaled(i,1);
end

% list for the UVB efficacy values
uv_eff = [];

% number of PASI points used for parameter fitting
num_pasi_points = 13;
        
% obtaining scaled PASI trajectories: every PASI value is divided by the
% baseline PASI
pasis_scaled = pasis;
for i = 1:length(pasis_scaled)
%     pasis_scaled(i,:) = totC_h + (totC_p - totC_h)*(pasis_scaled(i,:)/max(pasis_scaled(i,:)));
    pasis_scaled(i,:) = pasis_scaled(i,:)/pasis_scaled(i,1);
end

% model simulation upper time bound
stop_time = 735;

dc_stims = [];
pasi_outcome = [];

% getting the indeces of the species from the simulation data by the
% species name
species_to_plot = ["PASI"];
plot_index = [];
for i=1:length(species_to_plot)
    for j=1:length(m1.Species);
        if species_to_plot(i) == m1.Species(j).Name
            plot_index = [plot_index j];
            break;
        end
    end
end

for k=1:length(data.ID)
    data_row = data(data.ID == data.ID(k), :);
    p_id = data.ID(k);
    % only running it for the ids in data_ids
    if(~ismember(p_id, data_ids))
        continue;
    end
    
    % skipping the loop iteration if no UVB doses are present
    if(isnan(data_row.UVB_DOSE_TOTAL))
        data(data.ID == data_row.ID, ["UV_EFF_W_"]+num2str(num_pasi_points)) = {NaN};
        continue;
    end
    % obtaining the index of the row for the patient
    for i=1:length(data.ID)
        if(p_id == data.ID(i))
            index = i;
            break;
        end
    end
    % introducing an immune stimulus to induce psoriasis
    delete(m1.Events);
    addevent(m1, 'time>=150', 'dc_stim=10000');
    addevent(m1, 'time>=154', 'dc_stim=0');
    % active apoptosis pariod in days
    a_time = 0.99999;
    % adding events for the UVB doses
    for i=1:30
        if ~isnan(doses(index,i))
            addevent(m1, ['time>' num2str(time_doses(i)+300)], ['uv_dose=' num2str(doses(index,i))]);
            addevent(m1, ['time>=' num2str(time_doses(i)+a_time+300)], 'uv_dose=0');
        end
    end
    
    % initialising the best error and the best UVB efficacy values
    best_err = [1e3];
    best_uv_eff = 0;
    % transoposing the time and the PASI trajectories
    Time_full = transpose(time_pasis+300);
    PASI_full = transpose(pasis_scaled(index,:));
    % truncating the PASI trajectories up to the number of points specified
    % by <num_pasi_points>
    Time_full = Time_full(1:num_pasi_points);
    PASI_full = PASI_full(1:num_pasi_points);
    % getting the indeces of the species from the simulation data by the
    % species name
    species_to_plot = ["PASI"];
    
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
    
    m1 = sbml_set_parameter_value(m1, "uv_eff", data_row.UV_EFF_W_13);
    uv_eff = [uv_eff data_row.UV_EFF_W_13];

%     Algorithm for estimating flares
    flare = 0;
    for i=1:length(best_err)
        if(best_err(i)> 0.01)
            flare = 1;
            break;
        end
    end
    
    disp("Fitting flares in real time");
    dc_stim = [0 0 0 0 0 0 0 0 0 0];
    err_index = 0;
    for i=1:last_pasi_index-1
        best_stim = 0;
        prev_err_sum = 1e9;
        sim_data = model_sim(m1, stop_time);
        err = absolute_pasi_error(Time_full(1:i+1), PASI_full(1:i+1), sim_data.Time, sim_data.Data(:, plot_index(1)), 0, 1, pasis(index,1));
        rel_err = relative_pasi_error(Time_full(1:i+1), PASI_full(1:i+1), sim_data.Time, sim_data.Data(:, plot_index(1)), 0, 1, pasis(index,1));        
        if(~isnan(pasis(index,i+1)))
            err_index = err_index+1;
        end
        if(is_flare(err(err_index+1), rel_err(err_index+1), pasis(index,i+1)))
            for dc_stim_val = 0:100:6000
                m1 = sbml_set_parameter_value(m1, ['dc_stim_' num2str(i)], dc_stim_val);
                sim_data = model_sim(m1, stop_time);
                err = absolute_pasi_error(Time_full(1:i+1), PASI_full(1:i+1), sim_data.Time, sim_data.Data(:, plot_index(1)), 0, 1, pasis(index,1));
                rel_err = relative_pasi_error(Time_full(1:i+1), PASI_full(1:i+1), sim_data.Time, sim_data.Data(:, plot_index(1)), 0, 1, pasis(index,1));
                disp(['Patient ' num2str(p_id) '; dc_stim_' num2str(i) ' = ' num2str(dc_stim_val) '; sum of abs error = ' num2str(sum(abs(err)))]);
                if(sum(err.^2) < prev_err_sum)
                    prev_err_sum = sum(err.^2);
                    best_err = err;
                    best_stim = dc_stim_val;
                else
                    break;
                end
            end
        end
        m1 = sbml_set_parameter_value(m1, ['dc_stim_' num2str(i)], best_stim);
        dc_stim(i) = best_stim;
        data(data.ID == p_id, ["DC_STIM_"+num2str(i)]) = {best_stim};
    end
   
    dc_stims = [dc_stims; dc_stim];
    
    for i=1:length(dc_stim);
        m1 = sbml_set_parameter_value(m1, ['dc_stim_' num2str(i)], dc_stim(i));
    end
        
    sim_data = model_sim(m1, stop_time);
    
    fig = figure('Units','normalized','OuterPosition',[0 0 0.3 0.9],'Visible','off');
    set(fig,'defaultAxesColorOrder',[[0 0 0]; [1 0.4 1]]);
    set(gca, 'FontName', 'Arial');

    yyaxis right;
    h = bar(0.5:1:9.5, dc_stim, 'BarWidth', 1);
    set(h, "FaceAlpha", 0.3);
    hold on;
%     ytickformat('%.0f');
    ylabel('arbitrary');
    ylim([0 6200]);
    ax = gca;
%     ax.YAxis(2).Exponent = 3;
    
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
    
    xlim([-0.5 12]);
    xlabel('Time (weeks)');

    set(gca,'FontSize',48);
    title(string(['Patient ID = ' num2str(data.ID(index)) ', UVB sensitivity = ' num2str(uv_eff(end), '%.3f')]));
    
    legend([string([' Model simulation']) ... 
            string([' Patients data']) ...
            string([' Immune stimulus'])]);
    
    work_dir = '../../img/ode-v8-4/flares/';
    saveas(fig, [work_dir 'patient_flare_' num2str(p_id)], 'png');    

end
% saving the data-table with newly estimated "dc_stims" values to a XLSX file
writetable(data, "../../data/data_matlab.xlsx");




