function [ cost ] = get_cost( data, i, type )

cost=0;
expi=0;

if strcmp(type,'baxter')
        
        starti = i*(data.H-1) + 1; %Time start index from total trajectory
        endi = starti + data.H-2; %End time index
        xx = data.x(starti:endi,data.feati); %Get trajectory        
        error = (xx-data.expert.x(1:end-1,:)); %Get absolute error
        cError = sum(error);
        cost = norm(cError);
            
elseif strcmp(type,'cartpole')
        starti = i*data.H + 1;
        endi = starti + data.H - 1;
        xx = data.x(starti:endi,data.feati);
        error = xx-data.expert.x(1:end,:);
        cError = sum(error);
        cost = norm(error);

end

        cost = cost/length(data.feati); %Normalise by #features
        cost = cost/data.H; %Normalise by #time steps
