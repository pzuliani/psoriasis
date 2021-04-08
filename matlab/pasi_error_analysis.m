% SBML import of the model
m1 = sbmlimport('../models/psor_v8_4.xml');

% setting PASI measurement times
time_pasis = [];
cur_pasis_time = 0;
for i=1:13
    time_pasis = [time_pasis cur_pasis_time];
    cur_pasis_time = cur_pasis_time + 7;
end

% setting UVB doses times
time_doses = [];
cur_doses_time = [0 2 4];
% cur_doses_time = [0 3];
% cur_doses_time = [0];
for i=1:11
    time_doses = [time_doses cur_doses_time];
    cur_doses_time = cur_doses_time + 7;
end

% loading main data
data = readtable("../../data/data_matlab.xlsx");

% dropping patients without UVB doses
data = data(~isnan(data.UVB_DOSE_1), data.Properties.VariableNames);

% using only patients from the discovery cohort
data = data(data.ID <= 100, data.Properties.VariableNames);

num_pasi_points = 13;


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

% scaling the PASIs
pasis_scaled = pasis;
for i = 1:length(pasis_scaled)
%     pasis_scaled(i,:) = totC_h + (totC_p - totC_h)*(pasis_scaled(i,:)/max(pasis_scaled(i,:)));
    pasis_scaled(i,:) = pasis_scaled(i,:)/pasis_scaled(i,1);
end
        
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
        
% med = data.BASELINE_MED;
% uv_eff_data = data.UV_EFF_FULL;
% class = data.CLASS;


% getting the index of PASI species in the sim data
species_to_plot = ["PASI", "T", "A_per_1000"];
plot_index = [];
for i=1:length(species_to_plot)
    for j=1:length(m1.Species);
        if species_to_plot(i) == m1.Species(j).Name
            plot_index = [plot_index j];
            break;
        end
    end
end

pasi_vec = [];
pasi_err = [];
pasi_rel_err = [];
pasi_progress_err = [];

for index=1:size(data,1)
    
    % reinitialising all events
    delete(m1.Events);
    
    % inducing psoriasis here
    addevent(m1, 'time>=150', 'dc_stim=10000');
    addevent(m1, 'time>=154', 'dc_stim=0');
    
    % active apoptosis period in days
    a_time = 0.99999;

    % seeting UVB doses for the current patient
    for i=1:30
        if ~isnan(doses(index,i))
            addevent(m1, ['time>' num2str(time_doses(i)+300)], ['uv_dose=' num2str(doses(index,i))]);
            addevent(m1, ['time>=' num2str(time_doses(i)+a_time+300)], 'uv_dose=0');
        end
    end

    Time_full = transpose(time_pasis+300);
    PASI_full = transpose(pasis_scaled(index,:));
           
    Time_full = Time_full(1:num_pasi_points);
    PASI_full = PASI_full(1:num_pasi_points);
    
    m1 = sbml_set_parameter_value(m1, "uv_eff", data.UV_EFF_W_13(index));

%     for i=1:length(dc_stims(index, :))
%         m1 = sbml_set_parameter_value(m1, ['dc_stim_' num2str(i)], dc_stims(index, i));
%     end
            
    sim_data = model_sim(m1, 400);
    err = absolute_pasi_error(Time_full, PASI_full, sim_data.Time, sim_data.Data(:, plot_index(1)), 0, 1, pasis(index,1));
    rel_err = relative_pasi_error(Time_full, PASI_full, sim_data.Time, sim_data.Data(:, plot_index(1)), 0, 1, pasis(index,1));
    pasi_traj = pasis(index,~isnan(pasis(index,:)));
    pasi_traj = pasi_traj(2:end);
    pasi_err = cat(2, pasi_err, err(2:end));
    pasi_rel_err = cat(2, pasi_rel_err, rel_err(2:end));
    pasi_progress_err = cat(2, pasi_progress_err, err(2:end)/pasis(index,1));
    pasi_vec = cat(2, pasi_vec, pasi_traj);
    
    disp([num2str(data.ID(index)) ' (abs): ' num2str(err(2:end))]);
    disp([num2str(data.ID(index)) ' (rel): ' num2str(rel_err(2:end))]);
    disp("----------");

    
    % plotting from here on
    fig = figure('Units','normalized','OuterPosition',[0 0 1 1],'Visible','off');    
    set(fig,'defaultAxesColorOrder',[[0 0 0]; [1 0 0]]);
    set(gca, 'FontName', 'Arial');
    plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(1))*pasis(index,1), 'LineWidth', 8, 'Color', 'black', 'LineStyle', '-');
    hold on;
    % drawing an empty line to display the legend properly
    line(NaN,NaN,'LineWidth',8,'LineStyle','none','Marker','x','MarkerSize', 40, 'Color','r');
    err_index = 1;
    for i=1:length(pasis(index,:))
        color = 'red';
        marker = 'x';
        if(~isnan(pasis(index,i)))
            disp(['Rel=' num2str(rel_err(err_index)) '; Fun=' num2str(11*exp(-pasis(index,i)/3))])
            if(is_flare(err(err_index), rel_err(err_index), pasis(index,i)))
                color = 'blue';
            end
            scatter((time_pasis(i)+300-300)/7, pasis(index,i), 4000, marker, 'LineWidth', 8, 'MarkerFaceColor', color, 'MarkerEdgeColor', color);
            err_index = err_index + 1;
        end
    end
    ylim([0-0.1*max(pasis(index,:)) max(pasis(index,:))+0.1*max(pasis(index,:))]);
    ylabel('PASI');
    hold on;
    xlim([-0.5 12]);
    xlabel('Time (weeks)');
    set(gca,'FontSize',48);
    title(string(['Patient ID = ' num2str(data.ID(index)) ', UVB sensitivity = ' num2str(data.UV_EFF_W_13(index), '%.3f')]));
    legend([string([' Model simulation']) ... 
            string([' Patients data'])]);
    work_dir = '../../img/ode-v8-4/error-analysis/';
    saveas(fig, [work_dir 'patient_' num2str(data.ID(index))], 'png');

end

