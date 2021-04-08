function [r_squared] = compute_r_squared(time, fun, time_sim, fun_sim, tot_H, tot_P, PASI_BASELINE)
r_squared = 0;
data_mean = PASI_BASELINE * mean(fun(~isnan(fun)));
ss_mean = sum((data_mean - PASI_BASELINE * fun(~isnan(fun))).^2);
pasi_err = [];
for i=1:length(time)
    if(isnan(fun(i)))
        continue;
    end
    for j=1:length(time_sim)
        if(time_sim(j)>time(i))
            pasi_err = [pasi_err PASI_BASELINE*(fun(i)-fun_sim(j))/(tot_P-tot_H)];
            break;
        end
    end
end
r_squared = 1 - sum((pasi_err).^2)/ss_mean;
end