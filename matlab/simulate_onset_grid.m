% % This script simulates different rates of psoriasis onset and
% % generates Figure 3 of our ODE modelling paper.
% %
% % Author: Fedor Shmarov
% 
% 
% % SBML import of the model
% m1 = sbmlimport('../models/psor_v8_4.xml');
% 
% m1 = sbml_set_parameter_value(m1, "uv_eff", 0.08);
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
% heat_map_data = [];
% 
% j = 1;
% for dc_stim = 0:100:6000
%     k = 1;
%     for t_stim = 0:0.1:7
%         delete(m1.Events);
%         addevent(m1, 'time>=150', sprintf('dc_stim=%d',dc_stim));
%         addevent(m1, sprintf('time>=%d',150+t_stim), 'dc_stim=0');
%         sim_data = model_sim(m1, stop_time);
%         
%         time = sim_data.Time(sim_data.Time >= 150)-150;
%         data = sim_data.Data(sim_data.Time >= 150, plot_index(1));
%         time_onset = -1;
%         index_onset = 0;
%         for i = 1:length(time)
%             if(data(i)>=tot_h+0.90*(tot_p-tot_h))
%                 time_onset = time(i);
%                 index_onset = i;
%                 break;
%             end
%         end
% %         heat_map_data = [heat_map_data; [dc_stim, t_stim, time_onset]];
%         heat_map_data(j,k) = time_onset;
%         k = k+1;
%     end
%     j = j+1;
% end
% 
% min_color = min(heat_map_data(heat_map_data~=-1));
% max_color = max(heat_map_data(heat_map_data~=-1));
% color_map = [];

heat_map_data = heat_map_data_copy;

% heat_map_data(heat_map_data==-1) = 387;
% heat_map_data_interp = interp2(0:0.1:7, 0:100:6000, heat_map_data, 0:0.1:7, 0:100:6000);
% heat_map_data = interp2(heat_map_data, 5);
% heat_map_data(heat_map_data >= 250) = -1;

figure;
ax = gca;
imagesc(0:600:6000, 0:0.05:7, heat_map_data./7);
cmap = flipud(jet(ceil(max(heat_map_data, [], 'all'))));
cmap(1,:) = [1, 1, 1];
colormap(cmap);
h = colorbar;
caxis([0 100/7]);
set( h, 'YDir', 'reverse' );
ax.YDir = 'normal';
h1 = text(1000, 3.5, 'No psoriasis', 'FontSize', 48);
set(h1, 'Rotation', 315);
xlim([0 6000]);
ylim([0 7]);
xlabel("Immune stimulus amount (arbitrary)");
ylabel("Immune stimulus duration (days)");
ylabel(h, "Weeks until psoriasis onset");
title("Psoriasis onset lag time after an immune stimulus");
% title("Psoriasis onset speed depending on the strength and the duration of the immune stimulus");
set(gca, "Fontsize", 32);





return;


