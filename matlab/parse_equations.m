% This script parses the list of ODEs in the plain text format 
% output by the 'getequations' function from the SimBiology package
%
% Author: Fedor Shmarov


% importing an SBML model from the path
m1 = sbmlimport('../models/psor_v8_4.xml');

% getting full text and indeces for the sections
full = m1.getequations;
% each section in the text is separated by 2 empty lines (i.e., "char(10)")
sec_index = strfind(full, [char(10) char(10)]);

% parsing the sections
% parsing ODEs
odes_text = regexprep(full(1:sec_index(1)), ['ODEs:' char(10)], '');
index = strfind(odes_text, char(10));
odes = [];
cur = 1;
for i=1:length(index)
    str = odes_text(cur:index(i)-1);
    var = string(str(3:strfind(str,')')-1));
    lhs = string(str(strfind(str,'=')+1:end));
    odes = [odes [var; lhs]];
    cur = index(i)+1;
end

% parsing fluxes
flux_text = regexprep(full(sec_index(1)+2:sec_index(2)), ['Fluxes:' char(10)], '');
index = strfind(flux_text, char(10));
fluxes = [];
cur = 1;
for i=1:length(index)
    str = flux_text(cur:index(i)-1);
    var = string(str(1:strfind(str,'=')-2));
    lhs = string(str(strfind(str,'=')+1:end));
    fluxes = [fluxes [var; lhs]];
    cur = index(i)+1;
end

% parsing repeated assignments
ra_text = regexprep(full(sec_index(2)+2:sec_index(3)), ['Repeated Assignments:' char(10)], '');
index = strfind(ra_text, char(10));
ras = [];
cur = 1;
for i=1:length(index)
    str = ra_text(cur:index(i)-1);
    var = string(str(1:strfind(str,'=')-2));
    lhs = string(str(strfind(str,'=')+1:end));
    ras = [ras [var; lhs]];
    cur = index(i)+1;
end

% parsing parameter values
param_text = regexprep(full(sec_index(3)+2:sec_index(4)), ['Parameter Values:' char(10)], '');
index = strfind(param_text, char(10));
params = [];
cur = 1;
for i=1:length(index)
    str = param_text(cur:index(i)-1);
    var = string(str(1:strfind(str,'=')-2));
    lhs = string(str(strfind(str,'=')+1:end));
    params = [params [var; lhs]];
    cur = index(i)+1;
end

% parsing initial conditions
init_text = regexprep(full(sec_index(4)+2:sec_index(5)), ['Initial Conditions:' char(10)], '');
index = strfind(init_text, char(10));
inits = [];
cur = 1;
for i=1:length(index)
    str = init_text(cur:index(i)-1);
    var = string(str(1:strfind(str,'=')-2));
    lhs = string(str(strfind(str,'=')+1:end));
    if(ismember(var, odes(1,:)))
        inits = [inits [var; lhs]];
    else
        params = [params [var; lhs]];
    end
    cur = index(i)+1;
end

% reordering the list of fluxes
fluxes = transpose(fluxes);
fluxes = sortrows(fluxes, 1, 'descend');
fluxes = transpose(fluxes);

% replacing fluxes names with their values
for i=1:length(odes)
    str = odes(2,i);
    for j=1:length(fluxes)
        str = regexprep(str, string("(?<=\W)"+fluxes(1,j)+"(?=\W)"), string("("+fluxes(2,j)+")"));
    end
    odes(2,i) = str;
end

% replacing parameter names with their values
for i=1:length(odes)
    str = odes(2,i);
    for j=1:length(params)
        str = regexprep(str, string("(?<=\W)"+params(1,j)+"(?=\W)"), params(2,j));
    end
    odes(2,i) = str;
end

% this loop outputs all parsed ODEs as text in the format RHS==0 
for i=1:length(odes)
    disp(string(odes(2,i)+"==0;"));
end
    


















