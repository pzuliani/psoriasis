% This script simulates UVB therapy in model psor_v5.xml.
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

% setting parameter values
sbml_set_parameter_value(sbml, 'InAmax', 396);
sbml_set_parameter_value(sbml, 'InA', 1.0);

sbml_set_parameter_value(sbml, 'g1s', 5.2);

% adding events modelling the therapy 
% week 1
sbml.addevent('time>300', 'InA=0.700*InAmax');
sbml.addevent('time>=302', 'InA=1');
sbml.addevent('time>302', 'InA=0.700*InAmax');
sbml.addevent('time>=304', 'InA=1');
sbml.addevent('time>304', 'InA=0.980*InAmax');
sbml.addevent('time>=306', 'InA=1');
% week 2
sbml.addevent('time>307', 'InA=0.980*InAmax');
sbml.addevent('time>=309', 'InA=1');
sbml.addevent('time>309', 'InA=1.323*InAmax');
sbml.addevent('time>=311', 'InA=1');
sbml.addevent('time>311', 'InA=1.323*InAmax');
sbml.addevent('time>=313', 'InA=1');
% week 3
sbml.addevent('time>314', 'InA=1.720*InAmax');
sbml.addevent('time>=316', 'InA=1');
sbml.addevent('time>316', 'InA=1.720*InAmax');
sbml.addevent('time>=318', 'InA=1');
sbml.addevent('time>318', 'InA=2.150*InAmax');
sbml.addevent('time>=320', 'InA=1');
% week 4
sbml.addevent('time>321', 'InA=2.150*InAmax');
sbml.addevent('time>=323', 'InA=1');
sbml.addevent('time>323', 'InA=2.580*InAmax');
sbml.addevent('time>=325', 'InA=1');
sbml.addevent('time>325', 'InA=2.580*InAmax');
sbml.addevent('time>=327', 'InA=1');
% week 5
sbml.addevent('time>328', 'InA=2.967*InAmax');
sbml.addevent('time>=330', 'InA=1');
sbml.addevent('time>330', 'InA=2.967*InAmax');
sbml.addevent('time>=332', 'InA=1');
sbml.addevent('time>332', 'InA=3.264*InAmax');
sbml.addevent('time>=334', 'InA=1');
% week 6
sbml.addevent('time>335', 'InA=3.264*InAmax');
sbml.addevent('time>=337', 'InA=1');
sbml.addevent('time>337', 'InA=3.427*InAmax');
sbml.addevent('time>=339', 'InA=1');
sbml.addevent('time>339', 'InA=3.427*InAmax');
sbml.addevent('time>=341', 'InA=1');
% week 7
sbml.addevent('time>342', 'InA=3.427*InAmax');
sbml.addevent('time>=344', 'InA=1');
sbml.addevent('time>344', 'InA=3.427*InAmax');
sbml.addevent('time>=346', 'InA=1');
sbml.addevent('time>346', 'InA=3.427*InAmax');
sbml.addevent('time>=348', 'InA=1');
% week 8
sbml.addevent('time>349', 'InA=3.427*InAmax');
sbml.addevent('time>=351', 'InA=1');
sbml.addevent('time>351', 'InA=3.427*InAmax');
sbml.addevent('time>=353', 'InA=1');
sbml.addevent('time>353', 'InA=3.427*InAmax');
sbml.addevent('time>=355', 'InA=1');
% week 9
sbml.addevent('time>356', 'InA=3.427*InAmax');
sbml.addevent('time>=358', 'InA=1');
sbml.addevent('time>358', 'InA=3.427*InAmax');
sbml.addevent('time>=360', 'InA=1');
sbml.addevent('time>360', 'InA=3.427*InAmax');
sbml.addevent('time>=362', 'InA=1');
% week 10 (final)
sbml.addevent('time>363', 'InA=3.427*InAmax');
sbml.addevent('time>=365', 'InA=1');
sbml.addevent('time>365', 'InA=3.427*InAmax');
sbml.addevent('time>=367', 'InA=1');
sbml.addevent('time>367', 'InA=3.427*InAmax');
sbml.addevent('time>=369', 'InA=1');
% week 11 (extra)
% sbml.addevent('time>370', 'InA=3.427*InAmax');
% sbml.addevent('time>=372', 'InA=1');
% sbml.addevent('time>372', 'InA=3.427*InAmax');
% sbml.addevent('time>=374', 'InA=1');

% simulate the model up to 450 days
sim_data = model_sim(sbml, 450);
figure;
% the output is the 10th (totC) and the 13th (InA) species in the model
plot(sim_data.Time, sim_data.Data(:,10), sim_data.Time, sim_data.Data(:,13)/10, 'LineWidth', 4);
legend([sim_data.DataNames(10) sim_data.DataNames(13)]);
% sets horizontal axis to be between 0 and 450
xlim([0 450]);

hold on

% the section below is the approximation of an average PASI dynamics with a sigmoid 
% when the uvb therapy starts and when it finishes
t_start = 300;
t_finish = 450;
% totC in psoriatic and normal states respectively
y_max = 2.3001e+03;
y_min = 840.6692;

x = t_start:0.1:t_finish;

% sigmoid parameters
x0 = 15.06678657;
k = -0.1074235;
a = 0.07203641;
b = 0.60969391;

% unscaled sigmoid
y = b./(1+exp(-k*(x-x0-t_start))) + a;

% scaled sigmoid to [0,1]
y = rescale(y);

% scaled sigmoid to [y_min,y_max]
y = y*(y_max-y_min) + y_min;

% plot sigmoid on the same plot
plot(x, y, 'LineWidth', 4);


