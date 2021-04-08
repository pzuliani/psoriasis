function [pasi_err] = relative_pasi_error(time, fun, time_sim, fun_sim, tot_H, tot_P, PASI_BASELINE)
pasi_err = [];
for i=1:length(time)
    if(isnan(fun(i)))
        continue;
    end
    for j=1:length(time_sim)
        if(time_sim(j)>time(i))
            if(fun(i)*PASI_BASELINE >= 0)
%                 old version
                pasi_err = [pasi_err (fun(i)-fun_sim(j))/fun_sim(j)];
                % new version
%                 pasi_err = [pasi_err abs(fun(i)-fun_sim(j))/fun(i)];
            end
            break;
        end
    end
end
end