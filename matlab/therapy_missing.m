% loading the main model without events
sbml = sbmlimport('psor.v5.xml');

% setting parameters for modelling psoriatic state
sbml_set_parameter_value(sbml, 'c_cyto_ext', 2000);
sbml_set_parameter_value(sbml, 't_cyto_ext', 4.0);

% inducing psoriatic state
sbml.addevent('time >= 150', 'k4ext=c_cyto_ext');
sbml.addevent('time >= 150 + t_cyto_ext', 'k4ext=0.0');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% missing a therapy does not matter here
% adalimumab therapy

% creating a copy of the original object
sbml_copy = sbml.copyobj;

% adding events and setting parameter values
sbml_set_parameter_value(sbml_copy, 'k6d', 0.049511);
sbml_copy.addevent('time >= 300', 'B = 30000');
% sbml_copy.addevent('time >= 307', 'B = 30000');
% sbml_copy.addevent('time >= 321', 'B = 30000');
% sbml_copy.addevent('time >= 335', 'B = 30000');
% sbml_copy.addevent('time >= 349', 'B = 30000');
% sbml_copy.addevent('time >= 363', 'B = 30000');
% sbml_copy.addevent('time >= 377', 'B = 30000');
% sbml_copy.addevent('time >= 391', 'B = 30000');
% sbml_copy.addevent('time >= 405', 'B = 30000');
% sbml_copy.addevent('time >= 419', 'B = 30000');


sim_data = sbml_sim(sbml_copy, 1000);
sbml_plot(sim_data);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% what happens when a therapy is missed is shown below
% etanercept therapy

% creating a copy of the original object
sbml_copy = sbml.copyobj;

% adding events and setting parameter values
sbml_set_parameter_value(sbml_copy, 'k6d', 0.144406);
%for t = 300:dt:405
% dt = 7, 14 - everything is fine
% dt = 21 - not OK initially but then OK
% dt = 28 and higher - guaranteed psoriasis relapse
for t = 300:28:328
    sbml_copy.addevent(['time>=' num2str(t)], 'B = 30000');
end

sim_data = sbml_sim(sbml_copy, 1000);
sbml_plot(sim_data);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% missing a therapy does not matter here
% ustekinumab therapy

% creating a copy of the original object
sbml_copy = sbml.copyobj;

% adding events and setting parameter values
sbml_set_parameter_value(sbml_copy, 'k6d', 0.033007);
sbml_copy.addevent('time >= 300', 'B = 30000');
% sbml_copy.addevent('time >= 328', 'B = 30000');
% sbml_copy.addevent('time >= 412', 'B = 30000');
% sbml_copy.addevent('time >= 496', 'B = 30000');
% sbml_copy.addevent('time >= 580', 'B = 30000');
% sbml_copy.addevent('time >= 664', 'B = 30000');

sim_data = sbml_sim(sbml_copy, 1000);
sbml_plot(sim_data);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UVB therapy

% creating a copy of the original object
sbml_copy = sbml.copyobj;

% adding events and setting parameter values

sbml_set_parameter_value(sbml_copy, 'InAmax', 400);
sbml_set_parameter_value(sbml_copy, 'InA', 1.0);
sbml_set_parameter_value(sbml_copy, 't1', 1);
sbml_set_parameter_value(sbml_copy, 'tcut', 340);
sbml_set_parameter_value(sbml_copy, 'delt', 0.1);
sbml_set_parameter_value(sbml_copy, 'hill_t', 1);

sbml_copy.addevent('time>300', 'InA=0.700*(1.0 + (InAmax-1.0)*exp(-(time-tcut)/delt)/(1+exp(-(time-tcut)/delt)))');
sbml_copy.addevent('time>=302', 'InA=1');
sbml_copy.addevent('time>302', 'InA=0.700*(1.0 + (InAmax-1.0)*exp(-(time-tcut)/delt)/(1+exp(-(time-tcut)/delt)))');
sbml_copy.addevent('time>=304', 'InA=1');
sbml_copy.addevent('time>304', 'InA=0.980*(1.0 + (InAmax-1.0)*exp(-(time-tcut)/delt)/(1+exp(-(time-tcut)/delt)))');
sbml_copy.addevent('time>=306', 'InA=1');
sbml_copy.addevent('time>307', 'InA=0.980*(1.0 + (InAmax-1.0)*exp(-(time-tcut)/delt)/(1+exp(-(time-tcut)/delt)))');
sbml_copy.addevent('time>=309', 'InA=1');
sbml_copy.addevent('time>309', 'InA=1.323*(1.0 + (InAmax-1.0)*exp(-(time-tcut)/delt)/(1+exp(-(time-tcut)/delt)))');
sbml_copy.addevent('time>=311', 'InA=1');
sbml_copy.addevent('time>311', 'InA=1.323*(1.0 + (InAmax-1.0)*exp(-(time-tcut)/delt)/(1+exp(-(time-tcut)/delt)))');
sbml_copy.addevent('time>=313', 'InA=1');
sbml_copy.addevent('time>314', 'InA=1.720*(1.0 + (InAmax-1.0)*exp(-(time-tcut)/delt)/(1+exp(-(time-tcut)/delt)))');
sbml_copy.addevent('time>=316', 'InA=1');
sbml_copy.addevent('time>316', 'InA=1.720*(1.0 + (InAmax-1.0)*exp(-(time-tcut)/delt)/(1+exp(-(time-tcut)/delt)))');
sbml_copy.addevent('time>=318', 'InA=1');
sbml_copy.addevent('time>318', 'InA=2.150*(1.0 + (InAmax-1.0)*exp(-(time-tcut)/delt)/(1+exp(-(time-tcut)/delt)))');
sbml_copy.addevent('time>=320', 'InA=1');
sbml_copy.addevent('time>321', 'InA=2.150*(1.0 + (InAmax-1.0)*exp(-(time-tcut)/delt)/(1+exp(-(time-tcut)/delt)))');
sbml_copy.addevent('time>=323', 'InA=1');
% sbml_copy.addevent('time>323', 'InA=2.580*(1.0 + (InAmax-1.0)*exp(-(time-tcut)/delt)/(1+exp(-(time-tcut)/delt)))');
% sbml_copy.addevent('time>=325', 'InA=1');
% sbml_copy.addevent('time>325', 'InA=2.580*(1.0 + (InAmax-1.0)*exp(-(time-tcut)/delt)/(1+exp(-(time-tcut)/delt)))');
% sbml_copy.addevent('time>=327', 'InA=1');
% sbml_copy.addevent('time>328', 'InA=2.967*(1.0 + (InAmax-1.0)*exp(-(time-tcut)/delt)/(1+exp(-(time-tcut)/delt)))');
% sbml_copy.addevent('time>=330', 'InA=1');
% sbml_copy.addevent('time>330', 'InA=2.967*(1.0 + (InAmax-1.0)*exp(-(time-tcut)/delt)/(1+exp(-(time-tcut)/delt)))');
% sbml_copy.addevent('time>=332', 'InA=1');
% sbml_copy.addevent('time>332', 'InA=3.264*(1.0 + (InAmax-1.0)*exp(-(time-tcut)/delt)/(1+exp(-(time-tcut)/delt)))');
% sbml_copy.addevent('time>=334', 'InA=1');
% sbml_copy.addevent('time>335', 'InA=3.264*(1.0 + (InAmax-1.0)*exp(-(time-tcut)/delt)/(1+exp(-(time-tcut)/delt)))');
% sbml_copy.addevent('time>=337', 'InA=1');
sbml_copy.addevent('time>337', 'InA=3.427*(1.0 + (InAmax-1.0)*exp(-(time-tcut)/delt)/(1+exp(-(time-tcut)/delt)))');
sbml_copy.addevent('time>=339', 'InA=1');
sbml_copy.addevent('time>339', 'InA=3.427*(1.0 + (InAmax-1.0)*exp(-(time-tcut)/delt)/(1+exp(-(time-tcut)/delt)))');
sbml_copy.addevent('time>=341', 'InA=1');
sbml_copy.addevent('time>342', 'InA=3.427*(1.0 + (InAmax-1.0)*exp(-(time-tcut)/delt)/(1+exp(-(time-tcut)/delt)))');
sbml_copy.addevent('time>=344', 'InA=1');
sbml_copy.addevent('time>344', 'InA=3.427*(1.0 + (InAmax-1.0)*exp(-(time-tcut)/delt)/(1+exp(-(time-tcut)/delt)))');
sbml_copy.addevent('time>=346', 'InA=1');
sbml_copy.addevent('time>346', 'InA=3.427*(1.0 + (InAmax-1.0)*exp(-(time-tcut)/delt)/(1+exp(-(time-tcut)/delt)))');
sbml_copy.addevent('time>=348', 'InA=1');
sbml_copy.addevent('time>349', 'InA=3.427*(1.0 + (InAmax-1.0)*exp(-(time-tcut)/delt)/(1+exp(-(time-tcut)/delt)))');
sbml_copy.addevent('time>=351', 'InA=1');
sbml_copy.addevent('time>351', 'InA=3.427*(1.0 + (InAmax-1.0)*exp(-(time-tcut)/delt)/(1+exp(-(time-tcut)/delt)))');
sbml_copy.addevent('time>=353', 'InA=1');
sbml_copy.addevent('time>353', 'InA=3.427*(1.0 + (InAmax-1.0)*exp(-(time-tcut)/delt)/(1+exp(-(time-tcut)/delt)))');
sbml_copy.addevent('time>=355', 'InA=1');
sbml_copy.addevent('time>356', 'InA=3.427*(1.0 + (InAmax-1.0)*exp(-(time-tcut)/delt)/(1+exp(-(time-tcut)/delt)))');
sbml_copy.addevent('time>=358', 'InA=1');
sbml_copy.addevent('time>358', 'InA=3.427*(1.0 + (InAmax-1.0)*exp(-(time-tcut)/delt)/(1+exp(-(time-tcut)/delt)))');
sbml_copy.addevent('time>=360', 'InA=1');
sbml_copy.addevent('time>360', 'InA=3.427*(1.0 + (InAmax-1.0)*exp(-(time-tcut)/delt)/(1+exp(-(time-tcut)/delt)))');
sbml_copy.addevent('time>=362', 'InA=1');
sbml_copy.addevent('time>363', 'InA=3.427*(1.0 + (InAmax-1.0)*exp(-(time-tcut)/delt)/(1+exp(-(time-tcut)/delt)))');
sbml_copy.addevent('time>=365', 'InA=1');
sbml_copy.addevent('time>365', 'InA=3.427*(1.0 + (InAmax-1.0)*exp(-(time-tcut)/delt)/(1+exp(-(time-tcut)/delt)))');
sbml_copy.addevent('time>=367', 'InA=1');
sbml_copy.addevent('time>367', 'InA=3.427*(1.0 + (InAmax-1.0)*exp(-(time-tcut)/delt)/(1+exp(-(time-tcut)/delt)))');
sbml_copy.addevent('time>=369', 'InA=1');



sim_data = sbml_sim(sbml_copy, 1000);
sbml_plot(sim_data);


