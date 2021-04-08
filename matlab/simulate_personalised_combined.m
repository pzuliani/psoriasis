% SBML import of the model
m1 = sbmlimport('../models/psor_v8_4.xml');

for i=1:length(m1.Species)
    species = m1.Species(i);
    species.InitialAmount = 1;
end

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

% class_data = readtable("../../data/pasis_and_doses.xlsx");
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
    pasis_scaled(i,:) = pasis_scaled(i,:)/max(pasis_scaled(i,1));
end

stop_time = 735;

count = 1;
uv_eff = [];
uv_eff_flare = [];
arrest = [];
err = [];
class = [];
med = [];
count = 1;
pasi_err = [];
pasi_err_flare = [];
dc_stims = [];

%     d2 = sbiodose('Repeat', 'repeat');
d2 = adddose(m1, 'Repeat', 'repeat');
d2.Amount = 40000;
d2.TargetName = 'AdaSQ';
d2.Rate = 0;
d2.StartTime = 0;
d2.RepeatCount = 50;
d2.Interval = 14;
d2.Active = false;
fitAlg = 'lsqcurvefit';
% fitAlg = 'lsqnonlin';
% fitAlg = 'fmincon';
% fitAlg = 'fminsearch';
% fitAlg = 'scattersearch';

for p_id = 1:100
    tic;
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
    
%     if(p_id in [7 9 19 49 51])
%         continue;
%     end
    
    % skipping everyone whose baseline pasi is not the largest
    % in the trajectory
    if(pasis_scaled(index,1) < max(pasis_scaled(index,:)))
        continue;
    end
    
    class = [class data.CLASS(index)];
    med = [med data.BASELINE_MED(index)];
    
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
    
    disp(['Patient ' num2str(p_id)]);

    % PASI = ((totC-totC_min)/(totC_max-totC_min)+(T-t_min)/(t_max-t_min)+(D-d_min)/(d_max-d_min))/3
    
    Time_full = transpose(time_pasis+300);
    PASI_full = transpose(pasis_scaled(index,:));

    Time = Time_full;
    PASI = PASI_full;
    
    tbl = table(Time, PASI);
        
    grpData = groupedData(tbl, '', 'Time');
    responseMap = 'PASI = PASI';
    estimated = estimatedInfo('uv_eff', 'InitialValue', 0.4, 'Bounds', [0.1 1.6]);
    fitConst = sbiofit(m1, grpData, responseMap, estimated, d2, fitAlg);
    m1 = sbml_set_parameter_value(m1, "uv_eff", fitConst.ParameterEstimates.Estimate(1));
    uv_eff = [uv_eff fitConst.ParameterEstimates.Estimate(1)];
    stop_time = 735;
    sim_data = model_sim(m1, stop_time);
    
    species_to_plot = ["PASI", "totC", "inflamm"];

    plot_index = [];
    for i=1:length(species_to_plot)
        for j=1:length(m1.Species)
            if species_to_plot(i) == m1.Species(j).Name
                plot_index = [plot_index j];
                break;
            end
        end
    end
    
    err = square_error(Time_full, PASI_full, sim_data.Time, sim_data.Data(:, plot_index(1)), 0, 1, max(pasis(index,:)));
    pasi_err = [pasi_err err(2:end)];
    
    work_dir = '../../img/ode-v8-4/full-fit/';
    
    fig = figure('Units','normalized','OuterPosition',[0 0 1 1],'Visible','off');    
    set(fig,'defaultAxesColorOrder',[[0 0 0]; [1 0 0]]);
    set(gca, 'FontName', 'Arial');
%     title(string(['Patient ID = ' num2str(data.ID(index)) ', UVB efficacy = ' num2str(uv_eff(end), '%.3f')]));
%     sgtitle(string(['Patient ID = ' num2str(data.ID(index)) ', UVB efficacy = ' num2str(uv_eff(end), '%.3f')]), 'FontSize', 40);

    subplot(2,2,1);
    plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(1))*pasis(index,1), 'LineWidth', 8, 'Color', 'black', 'LineStyle', '-');
    hold on;

    % drawing an empty line to display the legend properly
    line(NaN,NaN,'LineWidth',8,'LineStyle','none','Marker','x','MarkerSize', 40, 'Color','r');
%     line(NaN,NaN,'LineWidth',8,'LineStyle','none','Marker','x','MarkerSize', 40, 'Color','blue');
    scatter((time_pasis(1:end)+300-300)/7, pasis(index,1:end), 4000, 'x', 'LineWidth', 8, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red');
%     scatter((time_pasis(fit_pts+1:end)+300-300)/7, pasis(index,fit_pts+1:end), 4000, 'x', 'LineWidth', 8, 'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'blue');
    %         scatter((time_pasis_ext+300-300)/7, pasis_scaled(index,:), 4000, 'x', 'LineWidth', 6, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red');
    ylim([0-0.1*max(pasis(index,:)) max(pasis(index,:))+0.1*max(pasis(index,:))]);
    ylabel('PASI');
    hold on;

    xlim([-0.5 12]);
    xlabel('Time (weeks)');

    set(gca,'FontSize',40);
    
    title(string(['Patient ID = ' num2str(data.ID(index)) ', UVB efficacy = ' num2str(uv_eff(end), '%.3f')]));
    
    legend([string([' Model simulation']) ... 
            string([' Patients data'])]);
    
    subplot(2,2,3);
    yyaxis left;
    plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(2)), 'LineWidth', 8, 'Color', 'black', 'LineStyle', '-');
    ylabel('cells/mm^2');
    ylim([totC_h - 0.1*(totC_p-totC_h) totC_p + 0.3*(totC_p-totC_h)]);
    
    yyaxis right;
    plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(3)), 'LineWidth', 8, 'Color', 'red', 'LineStyle', '-');
    ylabel('arbitrary');
    ylim([0 - 0.1 1 + 0.3]);

    xlim([-0.5 12]);
    xlabel('Time (weeks)');    
    set(gca,'FontSize',40);       
    
    legend([string([' Cell density']) ... 
        string([' Inflammation'])]);
        
%     saveas(fig, [work_dir 'patient_' num2str(p_id)], 'png');
        
    % fitting flares here
    disp(['Patient ' num2str(p_id) ' with flares']);
    last_pasi_index = length(PASI_full);
    for i = length(PASI_full):-1:1
        if ~isnan(PASI_full(i))
            last_pasi_index = i;
            break;
        end
    end
   
    inc = 0;
    for i=1:last_pasi_index-1
        stim_time = 6.99;
        if(~isnan(pasis_scaled(index,i)))
            addevent(m1, ['time>' num2str(300+inc)], ['dc_stim=dc_stim_' num2str(i)]);
            addevent(m1, ['time>=' num2str(300+inc+stim_time)], 'dc_stim=0');
            stim_time = 6.99;
        else
            stim_time = stim_time + 7;
        end
        inc = inc + 7;
    end
        
    estimated = [];
    for i=1:last_pasi_index-1
        if(~isnan(pasis_scaled(index,i)))
            estimated = [estimated estimatedInfo(['dc_stim_' num2str(i)], 'InitialValue', 500, 'Bounds', [0.01 3500])];
        end    
    end
    estimated = [estimated estimatedInfo('uv_eff', 'InitialValue', uv_eff(end), 'Bounds', [0.5*uv_eff(end) 1.5*uv_eff(end)])];
%     fitConst = sbiofit(m1, grpData, responseMap, estimated, d2, fitAlg);
    fitAlg = 'lsqcurvefit';
    fitConst = sbiofit(m1, grpData, responseMap, estimated, d2, fitAlg);
    dc_stim = zeros(1,12);
    for i=1:last_pasi_index-1
        if(~isnan(pasis_scaled(index,i)))
            m1 = sbml_set_parameter_value(m1, ['dc_stim_' num2str(i)], fitConst.ParameterEstimates.Estimate(i));
            dc_stim(i) = fitConst.ParameterEstimates.Estimate(i);
            disp(['dc_stim_' num2str(i) '=' num2str(dc_stim(i))]);
        end
    end
    m1 = sbml_set_parameter_value(m1, "uv_eff", fitConst.ParameterEstimates.Estimate(end));
    uv_eff_flare = [uv_eff_flare fitConst.ParameterEstimates.Estimate(end)];
    dc_stims = [dc_stims; dc_stim];
    stop_time = 735;
    sim_data = model_sim(m1, stop_time);
    
    err = square_error(Time_full, PASI_full, sim_data.Time, sim_data.Data(:, plot_index(1)), 0, 1, max(pasis(index,:)));
    pasi_err_flare = [pasi_err_flare err(2:end)];
    
%     fig = figure('Units','normalized','OuterPosition',[0 0 0.5 1],'Visible','off');    
%     set(fig,'defaultAxesColorOrder',[[0 0 0]; [1 0 0]]);
%     set(gca, 'FontName', 'Arial');

    subplot(2,2,2);

    plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(1))*pasis(index,1), 'LineWidth', 8, 'Color', 'black', 'LineStyle', '-');
    hold on;

    % drawing an empty line to display the legend properly
    line(NaN,NaN,'LineWidth',8,'LineStyle','none','Marker','x','MarkerSize', 40, 'Color','r');
%     line(NaN,NaN,'LineWidth',8,'LineStyle','none','Marker','x','MarkerSize', 40, 'Color','blue');
    scatter((time_pasis(1:end)+300-300)/7, pasis(index,1:end), 4000, 'x', 'LineWidth', 8, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red');
%     scatter((time_pasis(fit_pts+1:end)+300-300)/7, pasis(index,fit_pts+1:end), 4000, 'x', 'LineWidth', 8, 'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'blue');
    %         scatter((time_pasis_ext+300-300)/7, pasis_scaled(index,:), 4000, 'x', 'LineWidth', 6, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red');
    ylim([0-0.1*max(pasis(index,:)) max(pasis(index,:))+0.1*max(pasis(index,:))]);
    ylabel('PASI');
    hold on;

    xlim([-0.5 12]);
    xlabel('Time (weeks)');

    set(gca,'FontSize',40);
    title(string(['Patient ID = ' num2str(data.ID(index)) ', UVB efficacy = ' num2str(uv_eff_flare(end), '%.3f')]));
    legend([string([' Model simulation']) ... 
            string([' Patients data'])]);
    
    subplot(2,2,4);
    yyaxis left;
    plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(2)), 'LineWidth', 8, 'Color', 'black', 'LineStyle', '-');
    ylabel('cells/mm^2');
    ylim([totC_h - 0.1*(totC_p-totC_h) totC_p + 0.3*(totC_p-totC_h)]);
    
    yyaxis right;
    plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(3)), 'LineWidth', 8, 'Color', 'red', 'LineStyle', '-');
    ylabel('arbitrary');
    ylim([0 - 0.1 1 + 0.3]);

    xlim([-0.5 12]);
    xlabel('Time (weeks)');    
    set(gca,'FontSize',40);
    
    legend([string([' Cell density']) ... 
    string([' Inflammation'])]);
        
    saveas(fig, [work_dir 'patient_' num2str(p_id)], 'png');

    
    count = count + 1;
    disp(['Time taken: ' num2str(toc) ' seconds']);
    disp('-----');

end

% figure;
fig = figure('units','normalized','outerposition',[0 0 1 1],'visible','off');
boxplot(uv_eff, class);
xlabel('CLASS');
ylabel('UVB efficacy');
set(gca,'FontSize',40);
saveas(fig, [work_dir '/eff_vs_class.png']);

% figure;
fig = figure('units','normalized','outerposition',[0 0 1 1],'visible','off');
histogram(pasi_err,30);
xlim([-10 10]);
xlabel('PASI prediction error');
ylabel('Frequency');
set(gca,'FontSize',40);
saveas(fig, [work_dir '/pasi_err_hist.png']);

save(['data_fitting_' date]);

% % figure;
% fig = figure('units','normalized','outerposition',[0 0 1 1],'visible','off');
% % class = class_data.CLASS(~isnan(class_data.CLASS));
% % class = [class(1:7); class(9:length(class))];
% boxplot(uv_eff, class);
% xlabel('CLASS');
% ylabel('Arrest');
% set(gca,'FontSize',30);
% saveas(fig, '../../img/ode-v8-4/par-fit/arrest_vs_class.png');


% % figure;
% fig = figure('units','normalized','outerposition',[0 0 1 1],'visible','off');
% % class = class_data.CLASS(~isnan(class_data.CLASS));
% % class = [class(1:7); class(9:length(class))];
% scatter(uv_eff, arrest);
% xlabel('UV efficacy');
% ylabel('Arrest');
% set(gca,'FontSize',30);
% saveas(fig, '../../img/ode-v8-4/par-fit/eff_vs_arrest.png');

