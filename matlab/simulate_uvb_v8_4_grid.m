% % This script generates the heat maps from Figure 5.
% %
% % Author: Fedor Shmarov
% 
% % SBML import of the model
% m1 = sbmlimport('../models/psor_v8_4.xml');
% 
% time_doses = [];
% % cur_doses_time = [0 2 4];
% cur_doses_time = [0 1 2 3 4];
% 
% for i=1:10
%     time_doses = [time_doses cur_doses_time];
%     cur_doses_time = cur_doses_time + 7;
% end
%         
% uv_protocol = [0.7 0.7 0.98 0.98 1.323 1.323 1.72 1.72 2.15 2.15 ...
%                 2.58 2.58 2.967 2.967 3.264 3.264 3.427 3.427 3.427 3.427 ...
%                 3.427 3.427 3.427 3.427 3.427 3.427 3.427 3.427 3.427 3.427];
% 
% work_dir = '../../img/ode-v8-4/paper/';
% 
% stop_time = 735;
% 
% tot_h = 79828.07;
% tot_p = 266011.98;
% 
% species_to_plot = ["totC"];
% plot_index = [];
% for i=1:length(species_to_plot)
%     for j=1:length(m1.Species)
%         if species_to_plot(i) == m1.Species(j).Name
%             plot_index = [plot_index j];
%             break;
%         end
%     end
% end
% 
% therapy_heat_map_data = [];
% j = 1;
% for uv_eff = 0:0.05:1
%     k = 1;
%     for num_treat = 0:1:30
%         delete(m1.Events);
%         addevent(m1, 'time>=150', 'dc_stim=6000');
%         addevent(m1, 'time>=157', 'dc_stim=0');
%         
%         for i=1:num_treat
%             addevent(m1, ['time>' num2str(time_doses(i)+300)], ['uv_dose=' num2str(uv_protocol(i))]);
%             addevent(m1, ['time>=' num2str(time_doses(i)+a_time+300)], 'uv_dose=0');
%         end
%         
%         m1 = sbml_set_parameter_value(m1, "uv_eff", uv_eff);
%         
%         sim_data = model_sim(m1, stop_time);
%         
%         time = sim_data.Time;
%         data = sim_data.Data(:, plot_index(1));
% %         figure;
% %         plot(time, data);
%         if(data(end)>=tot_h+0.90*(tot_p-tot_h))
%             therapy_heat_map_data(j,k) = 0;
%         else
%             therapy_heat_map_data(j,k) = 1;
%         end 
%         k = k+1;
%     end
%     j = j+1;
% end

heat_map_data = therapy_heat_map_data;

figure;
ax = gca;
%imagesc([-0.1 1.1], [-5 35], heat_map_data);
x = repmat(0:0.05:1,31,1);
x = x';
y = repmat(0:1:30,21,1);
% cmap = jet(ceil(max(heat_map_data, [], 'all')));
cmap(1,:) = [0.8, 0.8, 0.8];
cmap(2,:) = [0, 0.7, 0];
colormap(cmap);
s = pcolor(x,y,heat_map_data);
s.EdgeColor = "none";
% h = colorbar;
% caxis([0 100/7]);
ax.YDir = 'normal';
% xlim([0 1]);
% ylim([0 30]);
for i=0:0.1:1
    xline(i, 'Color', [0.5 0.5 0.5]);
end
for i=0:5:30
    yline(i, 'Color', [0.5 0.5 0.5]);
end
t1 = text(0.5, 23, 'Remission', 'FontSize', 48);
t2 = text(0.1, 10, 'Relapse', 'FontSize', 48);
set(t1, 'Rotation', 315);
set(t2, 'Rotation', 315);
xlabel("UVB efficacy value (arbitrary)");
ylabel("Number of UVB doses");
% ylabel(h, "Weeks until psoriasis onset");
title("5 times per week UVB therapy");
set(gca, "Fontsize", 32);
% grid on;




