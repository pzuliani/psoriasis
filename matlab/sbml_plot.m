function [res] = sbml_plot(sim_data)
%PLOT_SBML_SIM Summary of this function goes here
%   Detailed explanation goes here
    figure;
    plot(sim_data.Time, sim_data.Data, 'LineWidth', 4);
    legend(sim_data.DataNames);

end



