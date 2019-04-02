function [f, df] = irl_trajectory_cost(featExp, expertFeatExp, cost)
%df == df/dfeatExp

%This implementation uses the 'matching trajectory' method for every time
%step
if strcmp(cost.type,'TRAJ')

    %This section of code passes checkgrad.m
    f = cost.scale.*norm(featExp - expertFeatExp)^2; 
    df = cost.scale.*2.*(featExp - expertFeatExp);

%    for i = 1:size(featExp,1) % loop over number of time steps
%       f = f + cost.scale.*norm(featExp(i,:) - expertFeatExp(i,:))^2;
%       df = df + cost.scale.*2.*(featExp(i,:)- expertFeatExp(i,:));
%    end

%Standard feature expectation implementation for entire trajectory
elseif strcmp(cost.type,'FEATEXP')

    f = cost.scale*norm(featExp-expertFeatExp)^2;

    %Compute df
    df = cost.scale*2.*(featExp-expertFeatExp); % derivative

    end

end %end function

