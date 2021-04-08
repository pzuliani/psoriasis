% SBML import of the model
m1 = sbmlimport('../models/psor_v8_4.xml');

time_pasis = [];
cur_pasis_time = 0;
for i=1:13
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

data = readtable("../../data/data_matlab.xlsx");
        
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
        
uv_protocol = [0.7 0.7 0.98 0.98 1.323 1.323 1.72 1.72 2.15 2.15 ...
                2.58 2.58 2.967 2.967 3.264 3.264 3.427 3.427 3.427 3.427 ...
                3.427 3.427 3.427 3.427 3.427 3.427 3.427 3.427 3.427 3.427 ...
                3.427 3.427 3.427];

pasis_scaled = pasis;
for i = 1:length(pasis_scaled)
%     pasis_scaled(i,:) = totC_h + (totC_p - totC_h)*(pasis_scaled(i,:)/max(pasis_scaled(i,:)));
    pasis_scaled(i,:) = pasis_scaled(i,:)/pasis_scaled(i,1);
end

pasis_saved = pasis;

stop_time = 735;

count = 1;
uv_eff = [];
arrest = [];
err = [];
class = [];
med = [];
count = 1;
pasi_err = [];
pasi_err_1 = [];
pasi_err_2 = [];
pasi_err_3 = [];
dc_stims = [];

base_errors = [];

for p_id = 1:100
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
    
    if(isnan(data.UVB_DOSE_1(index)))
        continue;
    end
    
    delete(m1.Events);
    addevent(m1, 'time>=150', 'dc_stim=10000');
    addevent(m1, 'time>=154', 'dc_stim=0');
    
    % active apoptosis pariod in days
    a_time = 0.99999;

    for i=1:30
        if ~isnan(doses(index,i))
            addevent(m1, ['time>' num2str(time_doses(i)+300)], ['uv_dose=' num2str(doses(index,i))]);
            addevent(m1, ['time>=' num2str(time_doses(i)+a_time+300)], 'uv_dose=0');
        end
    end
    
    Time_full = transpose(time_pasis+300);
    PASI_full = transpose(pasis_scaled(index,:));
    
%     Time_full = Time_full(1:7);
%     PASI_full = PASI_full(1:7);
    
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
    
    fig = figure('Units','normalized','OuterPosition',[0 0 1 1],'Visible','off');    
    set(fig,'defaultAxesColorOrder',[[0 0 0]; [1 0 0]]);
    set(gca, 'FontName', 'Arial');
    hold on;
    largest_pasi = max(pasis(index,:));
    
    rng(posixtime(datetime('now')));

%     Experiment to try to find out the distribution that was used in that
%     study by C. Fink 2018.
%     base_errors = [base_errors normrnd(0, 0.47*pasis(index,1), 100)];
%     base_errors = [base_errors normrnd(0, 5)];
%     disp(['Patient ' num2str(p_id)]);
%     continue;
    
    iter_num = 10;

    base_err = normrnd(0, 0.47*pasis(index,1), iter_num);

    for j=1:iter_num
        best_err = [1e3];
        best_uv_eff = 0;
                
%         base_err = normrnd(0, 0.47*pasis(index,1));
        pasis = pasis_saved;
        pasis(index,1)=pasis(index,1)+base_err(j);
        if(pasis(index,1) > largest_pasi)
            largest_pasi = pasis(index,1);
        end
        base_errors = [base_errors base_err];
        
        PASI_full = transpose(pasis_scaled(index,:));
        PASI_full_old = PASI_full;
        PASI_full(1) = PASI_full(1) + base_err(j)/pasis_saved(index,1);
        PASI_full = PASI_full/(PASI_full(1));

        disp(transpose(PASI_full));
        for uv_eff_val=0:0.01:1
            m1 = sbml_set_parameter_value(m1, "uv_eff", uv_eff_val);    
            sim_data = model_sim(m1, stop_time);
            err = absolute_pasi_error(Time_full, PASI_full, sim_data.Time, sim_data.Data(:, plot_index(1)), 0, 1, pasis(index,1));
            disp(['Patient ' num2str(p_id) '; uv_eff = ' num2str(uv_eff_val) '; sum of abs error = ' num2str(sum(abs(err)))]);
            if(sum(abs(err.^2)) < sum(abs(best_err.^2)))
                best_err = err;
                best_uv_eff = uv_eff_val;
            end
        end
        uv_eff = [uv_eff best_uv_eff];
        pasi_err = [pasi_err best_err(2:end)];

        m1 = sbml_set_parameter_value(m1, "uv_eff", best_uv_eff);
        sim_data = model_sim(m1, stop_time);

        plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(1))*pasis(index,1), 'LineWidth', 2, 'Color', 'black', 'LineStyle', '-');
        hold on;
        scatter((time_pasis(1:1)+300-300)/7, pasis(index,1:1), 4000, 'x', 'LineWidth', 8, 'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'blue');
    end
        
    % drawing an empty line to display the legend properly
    line(NaN,NaN,'LineWidth',8,'LineStyle','none','Marker','x','MarkerSize', 40, 'Color','r');
%     line(NaN,NaN,'LineWidth',8,'LineStyle','none','Marker','x','MarkerSize', 40, 'Color','blue');
    scatter((time_pasis(1:end)+300-300)/7, pasis_old(index,1:end), 4000, 'x', 'LineWidth', 8, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red');
%     scatter((time_pasis(fit_pts+1:end)+300-300)/7, pasis(index,fit_pts+1:end), 4000, 'x', 'LineWidth', 8, 'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'blue');
    %         scatter((time_pasis_ext+300-300)/7, pasis_scaled(index,:), 4000, 'x', 'LineWidth', 6, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red');
%     ylim([0-0.1*max(pasis(index,:)) max(pasis(index,:))+0.1*max(pasis(index,:))]);
    ylim([0-0.1*largest_pasi largest_pasi+0.1*largest_pasi]);
    ylabel('PASI');
    hold on;

    xlim([-0.5 12]);
    xlabel('Time (weeks)');

    set(gca,'FontSize',48);
    
    title(string(['Patient ID = ' num2str(data.ID(index)) ', UVB efficacy = ' num2str(mean(uv_eff), '%.3f')]));
    
    legend([string([' Model simulation']) ... 
            string([' Patients data'])]);
    
    work_dir = '../../img/ode-v8-4/full-fit/';
    saveas(fig, [work_dir 'patient_sampling_baseline' num2str(p_id)], 'png');

end
