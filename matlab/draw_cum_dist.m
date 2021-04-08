data = readtable("../../data/data_matlab.xlsx");
data.PASI_OUTCOME = (1-data.PASI_END_TREATMENT./data.PASI_PRE_TREATMENT)*100;

data.BASELINE_MED(data.BASELINE_MED==2)=1.51;
% dropping patients without UVB doses
% data = data(~isnan(data.UVB_DOSE_1), data.Properties.VariableNames);

% using only patients from the discovery cohort
dis = data(data.ID <= 100 & data.ID > 0, data.Properties.VariableNames);
rep = data(data.ID > 100 & data.ID < 200 & data.ID~=139, data.Properties.VariableNames);

h1=histogram(1-dis.PASI_END_TREATMENT./dis.PASI_PRE_TREATMENT);
h1.BinWidth=0.05;
dis_freq=h1.BinCounts;
dis_bins=h1.BinEdges;

h2=histogram(1-rep.PASI_END_TREATMENT./rep.PASI_PRE_TREATMENT);
h2.BinWidth=0.05;
rep_freq=h2.BinCounts(end-length(dis_freq)+1:end);
rep_bins=h2.BinEdges(end-length(dis_bins)+1:end);

% cum_rep_freq=flip(cumsum(flip(rep_freq)))
% rep_bins
% cum_dis_freq=flip(cumsum(flip(dis_freq)))
% dis_bins
com_cum_scaled_freq=[transpose([cum_dis_freq sum(dis.PASI_END_TREATMENT==0)]/size(dis,1)) transpose([cum_rep_freq sum(rep.PASI_END_TREATMENT==0)]/size(rep,1))];
com_cum_freq=[transpose([cum_dis_freq sum(dis.PASI_END_TREATMENT==0)]) transpose([cum_rep_freq sum(rep.PASI_END_TREATMENT==0)])];

com_cum_freq = com_cum_freq(end-4:end,:);
bins = 100*dis_bins(end-4:end);

for i=1:length(bins)
    disp(['PASI' num2str(bins(i))]);
    testdata = [com_cum_freq(i,1), size(dis,1)-com_cum_freq(i,1); com_cum_freq(i,2), size(rep,1)-com_cum_freq(i,2)];
    [h,p,stats] = fishertest(testdata);
    disp(['p-value = ' num2str(p)]);
    disp('----------')
end


% bar(100*dis_bins, 100*com_cum_scaled_freq,'BarWidth',1)
% xlabel("PASI X")
% ylabel("% of patients")
% legend(["Discovery" "Replication"])
% set(gca, "FontSize", 28)

