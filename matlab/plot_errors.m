% This runs a clustering alhorithm to identify the clasters for the data
% containing two features: pasi_err and pasi_rel_err. 
% Run "pasi_error_analysis.m" to obtain this data.
%
% Author: Fedor Shmarov

% old version
labels = dbscan([transpose(pasi_err), transpose(pasi_rel_err)], 0.5, 20);

% new version
% labels = dbscan([transpose(abs(pasi_err(pasi_vec ~= 0 & pasi_err >= 0))), transpose(pasi_rel_err(pasi_vec ~= 0 & pasi_err >= 0))], 0.2, 20);
% labels = kmeans([transpose(abs(pasi_err(pasi_vec ~= 0))), transpose(pasi_rel_err(pasi_vec ~= 0))], 2);



% abs_vec = abs(pasi_err(pasi_vec ~= 0));
% rel_vec = pasi_rel_err(pasi_vec ~= 0);
% rel_rad = 0.1;
% 
% for k = 1:20
%     new_abs_vec = [];
%     new_rel_vec = [];
%     new_rel_rad = rel_rad + 0.1;
%     for i = 1:length(abs_vec)
%         if(abs_vec(i)^2/(2*new_rel_rad)^2 + rel_vec(i)^2/new_rel_rad^2 <= 1 && ...
%                 abs_vec(i)^2/(2*rel_rad)^2 + rel_vec(i)^2/rel_rad^2 > 1)
%             new_abs_vec = [new_abs_vec abs_vec(i)];
%             new_rel_vec = [new_rel_vec rel_vec(i)];
%         end
%     end
% 
% %     disp(new_abs_vec);
% %     disp("-----");
% %     disp(new_rel_vec);
%     
%     dist = [];
%     for i = 1:length(new_abs_vec)
%         for j = i+1:length(new_abs_vec)
%             dist = [dist sqrt((new_abs_vec(i)-new_abs_vec(j))^2 + (new_rel_vec(i)-new_rel_vec(j))^2)];
% %             disp(abs_vec(i));
% %             disp(abs_vec(j));
% %             disp(rel_vec(i));
% %             disp(rel_vec(j));
% %             disp(sqrt((abs_vec(i)-abs_vec(j))^2 + (rel_vec(i)-rel_vec(j))^2));
% %             disp("-----");
%         end
%     end
%     avg_dist = mean(dist);
%     disp(rel_rad);
%     disp(avg_dist);
%     disp("-----");
%     rel_rad = rel_rad + 0.1;
% end


% s_vals = [];
% for k=0.1:0.1:10
%     labels = (abs(pasi_rel_err) >= k*exp(-abs(pasi_err))) + 1;
% %     figure;
% %     [s1,h] = silhouette([transpose(abs(pasi_err)), transpose(abs(pasi_rel_err))], labels, 'Euclidean');
%     s1 = silhouette([transpose(abs(pasi_err)), transpose(abs(pasi_rel_err))], labels, 'Euclidean');
%     s_vals = [s_vals mean(s1(labels==1))];
% end
% 
% figure;
% plot(0.1:0.1:10, s_vals);
% ylim([min(s_vals)-0.01, max(s_vals)+0.01]);

% figure;
% 
% [s1,h] = silhouette([transpose(abs(pasi_err)), transpose(abs(pasi_rel_err))], labels, 'Euclidean');
% 
% disp(mean(s1(labels==1)));

% return;

figure;

% colours = ["red", "blue", "black", "green", "yellow", "magenta", "cyan"];
% markers = ["^", "o", "s"];
% colour = [];
% marker = [];
% for i = 1:length(labels)
%     if (labels(i) == -1)
%         colour = [colour,  "black"];
%         marker = [marker,  "X"];
%     else
%         colour = [colour,  colours(labels(i))];
%         marker = [marker,  markers(labels(i))];
%     end    
% %     scatter3(pasi_progress_err(i), pasi_err(i), pasi_rel_err(i), colour);
% %     scatter(abs(pasi_err(i)), abs(pasi_rel_err(i)), colour);
% %     scatter(pasi_err(i), pasi_rel_err(i), colour, marker);
% %     hold on;
% end

% old version
gscatter(pasi_err, pasi_rel_err, labels, 'rk', 'x^');

% % new version
% gscatter(abs(pasi_err(pasi_vec ~= 0 & pasi_err >= 0)), pasi_rel_err(pasi_vec ~= 0 & pasi_err >= 0), labels, 'rk', 'x^');

hold on;

x = linspace(-9, 9, 1000);
% fun = 1.8./x;
% fun = 1.8./x;
fun2 = 5*exp(-x);

% xline(mean(abs(pasi_err(pasi_vec ~= 0))));
% xline(mean(abs(pasi_err(pasi_vec ~= 0)))+std(abs(pasi_err(pasi_vec ~= 0))));
% xline(mean(abs(pasi_err(pasi_vec ~= 0)))+2*std(abs(pasi_err(pasi_vec ~= 0))));
% 
% yline(mean(abs(pasi_rel_err(pasi_vec ~= 0))));
% yline(mean(abs(pasi_rel_err(pasi_vec ~= 0)))+std(abs(pasi_rel_err(pasi_vec ~= 0))));
% yline(mean(abs(pasi_rel_err(pasi_vec ~= 0)))+2*std(abs(pasi_rel_err(pasi_vec ~= 0))));

% new version
% h = drawellipse('Center',[0,0],'SemiAxes',[2,1], 'Color', 'blue', 'FaceAlpha', 0.05, 'InteractionsAllowed', 'none');
% line(NaN, NaN, 'LineWidth', 2, 'Color', 'blue');

% plot(x, fun);
% old version
plot(x, fun2, 'b', 'LineWidth', 2);
ylim([-2, 25]);

% % new version
% ylim([0, 3]);

legend(["Outliers", "Main cluster", "Possible cut-off"]);
set(gca, "FontSize", 14);
xlabel("PASI error");
ylabel("Relative PASI error");




