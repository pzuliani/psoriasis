function outcome = is_flare(err, rel_err, pasi)
    outcome = 0;
%     if(rel_err>=2.5*exp(-pasi/3)+0.5 || err>=2.3627 || err<=-1.7162)
%     if(rel_err>=2.5*exp(-pasi/3)+0.5 || err>=2.3627)
%     if(rel_err>=2.5*exp(-pasi/3)+0.5)
%     if(abs(rel_err)>=abs(1.8/err))
    if(err > 0 && rel_err >= 5*exp(-err))
%     if(pasi > 0 && err^2/(2.5379)^2 + rel_err^2/(0.9565)^2 >= 1)
%     if(pasi > 0 && err > 0 && err^2/2^2 + rel_err^2/1^2 >= 1)
        outcome = 1;
    end
end