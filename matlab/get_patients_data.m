% This is a simple script that shows how to read an XLSX file into a table
% and how to save a table into an XLSX file. Also there is an example of 
% adding columns to this table and selecting rows from this table.
%
% Author: Fedor Shmarov


% reading the XLSX file
data = readtable("../../data/data_matlab.xlsx");

% adding new columns in the table
data.PASI_OUTCOME = (1-data.PASI_END_TREATMENT./data.PASI_PRE_TREATMENT)*100;
data.PASI_OUTCOME_W1 = (1-data.PASI_END_WEEK_1./data.PASI_PRE_TREATMENT)*100;
data.PASI_OUTCOME_W2 = (1-data.PASI_END_WEEK_2./data.PASI_PRE_TREATMENT)*100;
data.PASI_OUTCOME_W3 = (1-data.PASI_END_WEEK_3./data.PASI_PRE_TREATMENT)*100;
data.PASI_OUTCOME_W4 = (1-data.PASI_END_WEEK_4./data.PASI_PRE_TREATMENT)*100;
data.PASI_OUTCOME_W5 = (1-data.PASI_END_WEEK_5./data.PASI_PRE_TREATMENT)*100;

% calculating BMI based on patients' height and weight only for 
% the patients with IDs in the range [201, 241]
data.BMI(data.ID >= 201 & data.ID <= 241) = data.WEIGHT(data.ID >= 201 & data.ID <= 241)./((data.HEIGHT(data.ID >= 201 & data.ID <= 241)/100).^2);

% calculating entry age based on patients' entry data and date of birth
% data.ENTRY_AGE(data.ID >= 201 & data.ID <= 241) = floor(years(data.ENTRY_DATE(data.ID >= 201 & data.ID <= 241)-data.DOB(data.ID >= 201 & data.ID <= 241)))

% dropping patients without UVB doses
% data = data(~isnan(data.UVB_DOSE_1), data.Properties.VariableNames);

% splitting patients into 3 cohorts based on their IDs
dis = data(data.ID <= 100 & data.ID > 0, data.Properties.VariableNames);
rep = data(data.ID > 100 & data.ID < 200 & data.ID~=139, data.Properties.VariableNames);
rose = data(data.ID > 200 & data.ID < 300, data.Properties.VariableNames);

% saving the data-table to a XLSX file
% writetable(data, "../../data/data_matlab.xlsx");

