% This script compares simulations of three different models of biologics
% with two different ways of defining simulation events.
%
% Author: Fedor Shmarov


% loading the main model without events
sbml = sbmlimport('../models/psor_v5.xml');

% setting parameters for modelling psoriatic state
sbml_set_parameter_value(sbml, 'c_cyto_ext', 2000);
sbml_set_parameter_value(sbml, 't_cyto_ext', 4.0);

% inducing psoriatic state
sbml.addevent('time >= 150', 'k4ext=c_cyto_ext');
sbml.addevent('time >= 150 + t_cyto_ext', 'k4ext=0.0');

% adalimumab therapy

% creating a copy of the original object
sbml_copy = sbml.copyobj;

% adding events and setting parameter values
sbml_set_parameter_value(sbml_copy, 'k6d', 0.049511);
sbml_copy.addevent('time >= 300', 'B = 30000');
sbml_copy.addevent('time >= 307', 'B = 30000');
sbml_copy.addevent('time >= 321', 'B = 30000');
sbml_copy.addevent('time >= 335', 'B = 30000');
sbml_copy.addevent('time >= 349', 'B = 30000');
sbml_copy.addevent('time >= 363', 'B = 30000');
sbml_copy.addevent('time >= 377', 'B = 30000');
sbml_copy.addevent('time >= 391', 'B = 30000');
sbml_copy.addevent('time >= 405', 'B = 30000');
sbml_copy.addevent('time >= 419', 'B = 30000');


sim_data = model_sim(sbml_copy, 1000);
sbml_plot(sim_data);

sbml_new = sbmlimport('../models/model_v5_bio/v5_adalimumab_biol_treat/v5_biol_events.xml');

sim_data_new = model_sim(sbml_new, 1000);
sbml_plot(sim_data_new);

% checking the difference between two methods.
% should be zero if the both methods are equivalent
disp(max(max(abs(sim_data.Data - sim_data_new.Data))));



% etanercept therapy

% creating a copy of the original object
sbml_copy = sbml.copyobj;

% adding events and setting parameter values
sbml_set_parameter_value(sbml_copy, 'k6d', 0.144406);
for t = 300:7:405
    sbml_copy.addevent(['time>=' num2str(t)], 'B = 30000');
end

sim_data = model_sim(sbml_copy, 1000);
sbml_plot(sim_data);

sbml_new = sbmlimport('../models/model_v5_bio/v5_etanercept_biol_treat/v5_biol_events.xml');

sim_data_new = model_sim(sbml_new, 1000);
sbml_plot(sim_data_new);

% checking the difference between two methods.
% should be zero if the both methods are equivalent
disp(max(max(abs(sim_data.Data - sim_data_new.Data))));


% ustekinumab therapy

% creating a copy of the original object
sbml_copy = sbml.copyobj;

% adding events and setting parameter values
sbml_set_parameter_value(sbml_copy, 'k6d', 0.033007);
sbml_copy.addevent('time >= 300', 'B = 30000');
sbml_copy.addevent('time >= 328', 'B = 30000');
sbml_copy.addevent('time >= 412', 'B = 30000');
sbml_copy.addevent('time >= 496', 'B = 30000');
sbml_copy.addevent('time >= 580', 'B = 30000');
sbml_copy.addevent('time >= 664', 'B = 30000');

sim_data = model_sim(sbml_copy, 1000);
sbml_plot(sim_data);

sbml_new = sbmlimport('../models/model_v5_bio/v5_ustekinumab_biol_treat/v5_biol_events.xml');

sim_data_new = model_sim(sbml_new, 1000);
sbml_plot(sim_data_new);

% checking the difference between two methods.
% should be zero if the both methods are equivalent
disp(max(max(abs(sim_data.Data - sim_data_new.Data))));

