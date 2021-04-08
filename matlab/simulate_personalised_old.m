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

med = data.BASELINE_MED;

% % Basic model simulation
% figure;
% 
% t_stim = 1000;
% plot_legend = [];

% totC_p = 2.3386e+05;
% totC_h = 8.2614e+04;

% totC_p = 266011.65;
% totC_h = 79828;

pasis_scaled = pasis;
for i = 1:length(pasis_scaled)
%     pasis_scaled(i,:) = totC_h + (totC_p - totC_h)*(pasis_scaled(i,:)/max(pasis_scaled(i,:)));
    pasis_scaled(i,:) = pasis_scaled(i,:)/max(pasis_scaled(i,1));
end

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
fitAlg = 'fminsearch';
% fitAlg = 'scattersearch';

fit_pts = 4;

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
    
    % skipping everyone whose baseline pasi is not the largest
    % in the trajectory
    if(pasis_scaled(index,1) >= max(pasis_scaled(index,:)))
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
        inc = inc + 7;
    end
   
%    Time = Time_full(1:fit_pts);
%    totC = totC_full(1:fit_pts);
    
    Time = Time_full;
    PASI = PASI_full;
    
    tbl = table(Time, PASI);
        
    grpData = groupedData(tbl, '', 'Time');
    responseMap = 'PASI = PASI';
    estimated = estimatedInfo('uv_eff', 'InitialValue', 0.5, 'Bounds', [0.01 1.2]);
%     m1 = sbml_set_parameter_value(m1, "uv_eff", 1);    
%     estimated = [estimated estimatedInfo('arrest', 'InitialValue', 0.5, 'Bounds', [0.01 1])];
    for i=1:last_pasi_index-1
        estimated = [estimated estimatedInfo(['dc_stim_' num2str(i)], 'InitialValue', 1000, 'Bounds', [0.01 4000])];
    end
    fitConst = sbiofit(m1, grpData, responseMap, estimated, d2, fitAlg);
    m1 = sbml_set_parameter_value(m1, "uv_eff", fitConst.ParameterEstimates.Estimate(1));    

    dc_stim = zeros(1,12);
    for i=1:last_pasi_index-1
        m1 = sbml_set_parameter_value(m1, ['dc_stim_' num2str(i)], fitConst.ParameterEstimates.Estimate(i+1));
%         dc_stim = [dc_stim fitConst.ParameterEstimates.Estimate(i+1)];
        dc_stim(i) = fitConst.ParameterEstimates.Estimate(i+1);
        disp(['dc_stim_' num2str(i) '=' num2str(dc_stim(i))]);
    end
    disp('----------');
    dc_stims = [dc_stims; dc_stim];
    
%     m1 = sbml_set_parameter_value(m1, "arrest", fitConst.ParameterEstimates.Estimate(2));    
    uv_eff = [uv_eff fitConst.ParameterEstimates.Estimate(1)];
%     arrest = [arrest fitConst.ParameterEstimates.Estimate(2)];
    
    stop_time = 735;
    sim_data = model_sim(m1, stop_time);
    
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
    
%     err = square_error(Time_full, PASI_full, sim_data.Time, sim_data.Data(:, plot_index(1)), 0, 1, data.PASI_PRE_TREATMENT(index));
    err = square_error(Time_full, PASI_full, sim_data.Time, sim_data.Data(:, plot_index(1)), 0, 1, max(pasis(index,:)));
    pasi_err = [pasi_err err(2:end)];
    if data.CLASS(index)==1
        pasi_err_1 = [pasi_err_1 err(2:end)];
    end
    if data.CLASS(index)==2
        pasi_err_2 = [pasi_err_2 err(2:end)];
    end
    if data.CLASS(index)==3
        pasi_err_3 = [pasi_err_3 err(2:end)];
    end
    
    sim_data = model_sim(m1, stop_time);

    work_dir = ['../../img/ode-v8-4/dc-fit/patient-' num2str(p_id)];
    mkdir(work_dir);
    work_dir = [work_dir '/'];
    
    fig = figure('Units','normalized','OuterPosition',[0 0 1 1],'Visible','off');
%     set(fig,'defaultAxesColorOrder',[[0 0 0]; [1 0 0]]);
    set(gca, 'FontName', 'Arial')

    plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(1))*pasis(index,1), 'LineWidth', 8, 'Color', 'black', 'LineStyle', '-');
    hold on;

    % drawing an empty line to display the legend properly
    line(NaN,NaN,'LineWidth',8,'LineStyle','none','Marker','x','MarkerSize', 40, 'Color','r');
    line(NaN,NaN,'LineWidth',8,'LineStyle','none','Marker','x','MarkerSize', 40, 'Color','blue');
    scatter((time_pasis(1:fit_pts)+300-300)/7, pasis(index,1:fit_pts), 4000, 'x', 'LineWidth', 8, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red');
    scatter((time_pasis(fit_pts+1:end)+300-300)/7, pasis(index,fit_pts+1:end), 4000, 'x', 'LineWidth', 8, 'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'blue');
    %         scatter((time_pasis_ext+300-300)/7, pasis_scaled(index,:), 4000, 'x', 'LineWidth', 6, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red');
    ylim([0-0.1*max(pasis(index,:)) max(pasis(index,:))+0.1*max(pasis(index,:))]);
    ylabel('PASI');
    hold on;

    xlim([-0.5 12]);
    xlabel('Time (weeks)');

    set(gca,'FontSize',40);
   
    title(string(['  Patient ID = ' num2str(data.ID(index)) ', CLASS = ' num2str(data.CLASS(index))]));
    
    legend([string([' Model simulation']) ... 
            string([' PASI used for fitting' ...
                char(10) ' (UVB efficacy = ' num2str(uv_eff(end), '%.3f') ')' ]) ...
            string([' Unused PASI value'])]);
        
    saveas(fig, [work_dir 'pasi'], 'epsc');
    
    
    fig = figure('Units','normalized','OuterPosition',[0 0 1 1],'Visible','off');
    set(gca, 'FontName', 'Arial')

    plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(2)), 'LineWidth', 8, 'Color', 'black', 'LineStyle', '-');
    hold on;
    stairs(-1:3,[0 dc_stim(1:4)], 'LineWidth', 8, 'Color', 'red', 'LineStyle', '-');
    stairs(3:12, [dc_stim(4:end) 0], 'LineWidth', 8, 'Color', 'blue', 'LineStyle', '-');
    
%     stairs(0:last_pasi_index-2, dc_stim, 'LineWidth', 12, 'Color', 'red', 'LineStyle', '-');
    
    ylabel('Cells/mm2');
    xlim([-0.5 12]);
    xlabel('Time (weeks)');

    set(gca,'FontSize',40);
   
    title(string(['  Patient ID = ' num2str(data.ID(index)) ', CLASS = ' num2str(data.CLASS(index))]));
    
    legend([string([' T-cells']) ... 
        string([' Stimulus (first 3 weeks)']) ...
        string([' Stimulus (after 3 weeks)'])]);
    
    saveas(fig, [work_dir 't_cells'], 'epsc');

    % Plotting apoptosis
    fig = figure('Units','normalized','OuterPosition',[0 0 1 1],'Visible','off');
    set(gca, 'FontName', 'Arial')

    plot((sim_data.Time-300)/7, sim_data.Data(:, plot_index(3)), 'LineWidth', 6, 'Color', 'black', 'LineStyle', '-');
       
    ylabel('A per 1000');
    xlim([-0.5 12]);
    xlabel('Time (weeks)');

    set(gca,'FontSize',40);
   
    title(string(['  Patient ID = ' num2str(data.ID(index)) ', CLASS = ' num2str(data.CLASS(index))]));
    
    saveas(fig, [work_dir 'a_per_1000'], 'epsc');

    
    count = count + 1;

end

% figure;
fig = figure('units','normalized','outerposition',[0 0 1 1],'visible','off');
boxplot(uv_eff, class);
xlabel('CLASS');
ylabel('UVB efficacy');
set(gca,'FontSize',40);
saveas(fig, [work_dir '../eff_vs_class.png']);

% figure;
fig = figure('units','normalized','outerposition',[0 0 1 1],'visible','off');
histogram(pasi_err,30);
xlim([-10 10]);
xlabel('PASI prediction error');
ylabel('Frequency');
set(gca,'FontSize',40);
saveas(fig, [work_dir '../pasi_err_hist.png']);

save('fit_dc_stim_above_baseline');

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

